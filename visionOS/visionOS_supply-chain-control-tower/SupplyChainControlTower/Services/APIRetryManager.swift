//
//  APIRetryManager.swift
//  SupplyChainControlTower
//
//  Retry logic and circuit breaker for API requests
//

import Foundation

/// Manages retry logic with exponential backoff
actor RetryManager {

    // MARK: - Properties

    private let maxRetries: Int
    private let baseDelay: TimeInterval
    private let maxDelay: TimeInterval

    // MARK: - Initialization

    init(maxRetries: Int = 3, baseDelay: TimeInterval = 1.0, maxDelay: TimeInterval = 30.0) {
        self.maxRetries = maxRetries
        self.baseDelay = baseDelay
        self.maxDelay = maxDelay
    }

    // MARK: - Public Methods

    /// Execute an operation with retry logic
    func execute<T: Sendable>(_ operation: @Sendable () async throws -> T) async throws -> T {
        var lastError: Error?

        for attempt in 0..<maxRetries {
            do {
                let result = try await operation()
                if attempt > 0 {
                    AppConfiguration.Logger.info("Retry: Succeeded on attempt \(attempt + 1)")
                }
                return result
            } catch {
                lastError = error

                // Don't retry on certain errors
                if !shouldRetry(error: error) {
                    AppConfiguration.Logger.warning("Retry: Error not retryable - \(error)")
                    throw error
                }

                // Don't wait after last attempt
                guard attempt < maxRetries - 1 else { break }

                // Calculate delay with exponential backoff
                let delay = calculateDelay(attempt: attempt)

                AppConfiguration.Logger.warning("Retry: Attempt \(attempt + 1) failed - \(error.localizedDescription). Retrying in \(delay)s...")

                try await Task.sleep(for: .seconds(delay))
            }
        }

        AppConfiguration.Logger.error("Retry: All attempts failed")
        throw lastError ?? RetryError.maxAttemptsExceeded
    }

    // MARK: - Private Methods

    private func shouldRetry(error: Error) -> Bool {
        // Don't retry on certain error types
        if let apiError = error as? APIError {
            switch apiError {
            case .httpError(let statusCode):
                // Don't retry client errors (4xx except 429)
                if (400...499).contains(statusCode) && statusCode != 429 {
                    return false
                }
                return true
            case .invalidResponse, .decodingError:
                return false
            case .networkError:
                return true
            }
        }

        // Retry on network errors
        if let urlError = error as? URLError {
            switch urlError.code {
            case .timedOut, .networkConnectionLost, .notConnectedToInternet:
                return true
            default:
                return false
            }
        }

        return true
    }

    private func calculateDelay(attempt: Int) -> TimeInterval {
        // Exponential backoff: baseDelay * 2^attempt + jitter
        let exponentialDelay = baseDelay * Double(1 << attempt)
        let jitter = Double.random(in: 0...1.0)
        let delay = min(exponentialDelay + jitter, maxDelay)
        return delay
    }
}

// MARK: - Circuit Breaker

/// Circuit breaker pattern for API resilience
actor CircuitBreaker {

    // MARK: - State

    enum State {
        case closed      // Normal operation
        case open        // Failing, reject requests
        case halfOpen    // Testing if service recovered

        var description: String {
            switch self {
            case .closed: return "CLOSED"
            case .open: return "OPEN"
            case .halfOpen: return "HALF-OPEN"
            }
        }
    }

    // MARK: - Properties

    private var state: State = .closed
    private var failureCount: Int = 0
    private var lastFailureTime: Date?
    private var successCount: Int = 0

    private let failureThreshold: Int
    private let timeout: TimeInterval
    private let halfOpenSuccessThreshold: Int

    // MARK: - Initialization

    init(failureThreshold: Int = 5,
         timeout: TimeInterval = 60,
         halfOpenSuccessThreshold: Int = 2) {
        self.failureThreshold = failureThreshold
        self.timeout = timeout
        self.halfOpenSuccessThreshold = halfOpenSuccessThreshold
    }

    // MARK: - Public Methods

    /// Execute an operation through the circuit breaker
    func execute<T: Sendable>(_ operation: @Sendable () async throws -> T) async throws -> T {
        // Check state transition
        await checkStateTransition()

        // If circuit is open, fail fast
        guard state != .open else {
            AppConfiguration.Logger.warning("CircuitBreaker: OPEN - Rejecting request")
            throw CircuitBreakerError.circuitOpen
        }

        do {
            let result = try await operation()
            await recordSuccess()
            return result
        } catch {
            await recordFailure(error: error)
            throw error
        }
    }

    /// Get current circuit breaker state
    func currentState() -> State {
        return state
    }

    /// Reset circuit breaker
    func reset() {
        state = .closed
        failureCount = 0
        successCount = 0
        lastFailureTime = nil
        AppConfiguration.Logger.info("CircuitBreaker: RESET to CLOSED")
    }

    // MARK: - Private Methods

    private func checkStateTransition() {
        guard state == .open else { return }

        // Check if timeout has elapsed
        if let lastFailure = lastFailureTime,
           Date().timeIntervalSince(lastFailure) >= timeout {
            state = .halfOpen
            successCount = 0
            AppConfiguration.Logger.info("CircuitBreaker: Transitioning to HALF-OPEN after timeout")
        }
    }

    private func recordSuccess() {
        switch state {
        case .closed:
            failureCount = 0

        case .halfOpen:
            successCount += 1
            if successCount >= halfOpenSuccessThreshold {
                state = .closed
                failureCount = 0
                successCount = 0
                AppConfiguration.Logger.info("CircuitBreaker: Transitioning to CLOSED after \(successCount) successful calls")
            }

        case .open:
            // Shouldn't happen
            break
        }
    }

    private func recordFailure(error: Error) {
        switch state {
        case .closed:
            failureCount += 1
            lastFailureTime = Date()

            if failureCount >= failureThreshold {
                state = .open
                AppConfiguration.Logger.error("CircuitBreaker: Transitioning to OPEN after \(failureCount) failures")
            }

        case .halfOpen:
            state = .open
            failureCount = 0
            successCount = 0
            lastFailureTime = Date()
            AppConfiguration.Logger.error("CircuitBreaker: Transitioning back to OPEN from HALF-OPEN")

        case .open:
            lastFailureTime = Date()
        }
    }
}

// MARK: - Rate Limiter

/// Token bucket rate limiter
actor RateLimiter {

    // MARK: - Properties

    private var tokens: Double
    private let maxTokens: Double
    private let refillRate: Double // tokens per second
    private var lastRefillTime: Date

    // MARK: - Initialization

    init(maxTokens: Double = 10, refillRate: Double = 1.0) {
        self.maxTokens = maxTokens
        self.tokens = maxTokens
        self.refillRate = refillRate
        self.lastRefillTime = Date()
    }

    // MARK: - Public Methods

    /// Attempt to acquire a token (throttle if needed)
    func acquire() async throws {
        await refillTokens()

        if tokens >= 1.0 {
            tokens -= 1.0
        } else {
            // Calculate wait time until token available
            let waitTime = (1.0 - tokens) / refillRate

            AppConfiguration.Logger.debug("RateLimiter: Throttling request, waiting \(waitTime)s")

            try await Task.sleep(for: .seconds(waitTime))
            await refillTokens()
            tokens -= 1.0
        }
    }

    /// Reset rate limiter
    func reset() {
        tokens = maxTokens
        lastRefillTime = Date()
    }

    // MARK: - Private Methods

    private func refillTokens() {
        let now = Date()
        let timePassed = now.timeIntervalSince(lastRefillTime)
        let tokensToAdd = timePassed * refillRate

        tokens = min(tokens + tokensToAdd, maxTokens)
        lastRefillTime = now
    }
}

// MARK: - API Request Manager

/// Combines retry, circuit breaker, and rate limiting
actor APIRequestManager {

    // MARK: - Properties

    private let retryManager: RetryManager
    private let circuitBreaker: CircuitBreaker
    private let rateLimiter: RateLimiter

    // MARK: - Initialization

    init(maxRetries: Int = 3,
         failureThreshold: Int = 5,
         rateLimit: Double = 10) {
        self.retryManager = RetryManager(maxRetries: maxRetries)
        self.circuitBreaker = CircuitBreaker(failureThreshold: failureThreshold)
        self.rateLimiter = RateLimiter(maxTokens: rateLimit, refillRate: rateLimit / 10)
    }

    // MARK: - Public Methods

    /// Execute a request with retry, circuit breaker, and rate limiting
    func execute<T: Sendable>(_ operation: @Sendable () async throws -> T) async throws -> T {
        // Apply rate limiting
        try await rateLimiter.acquire()

        // Execute with circuit breaker
        return try await circuitBreaker.execute {
            // Execute with retry logic
            try await retryManager.execute(operation)
        }
    }

    /// Get circuit breaker state
    func getCircuitState() async -> CircuitBreaker.State {
        await circuitBreaker.currentState()
    }

    /// Reset all managers
    func reset() async {
        await circuitBreaker.reset()
        await rateLimiter.reset()
    }
}

// MARK: - Errors

enum RetryError: LocalizedError {
    case maxAttemptsExceeded

    var errorDescription: String? {
        switch self {
        case .maxAttemptsExceeded:
            return "Maximum retry attempts exceeded"
        }
    }
}

enum CircuitBreakerError: LocalizedError {
    case circuitOpen

    var errorDescription: String? {
        switch self {
        case .circuitOpen:
            return "Circuit breaker is open - service unavailable"
        }
    }
}
