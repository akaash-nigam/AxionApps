//
//  RateLimiter.swift
//  AIAgentCoordinator
//
//  Token bucket rate limiter for controlling API request rates
//  Created by AI Agent Coordinator on 2025-01-20.
//

import Foundation

// MARK: - Rate Limiter

/// Token bucket rate limiter for controlling request rates
/// Supports multiple time windows (per second, minute, hour)
actor RateLimiter {

    // MARK: - Configuration

    /// Configuration for the rate limiter
    struct Configuration: Sendable {
        /// Maximum requests per second (0 = unlimited)
        let requestsPerSecond: Int

        /// Maximum requests per minute (0 = unlimited)
        let requestsPerMinute: Int

        /// Maximum requests per hour (0 = unlimited)
        let requestsPerHour: Int

        /// Whether to enable burst capacity
        let allowBurst: Bool

        /// Burst capacity multiplier (e.g., 1.5 = 50% burst capacity)
        let burstMultiplier: Double

        /// Default configuration with reasonable limits
        static let `default` = Configuration(
            requestsPerSecond: 10,
            requestsPerMinute: 600,
            requestsPerHour: 10_000,
            allowBurst: true,
            burstMultiplier: 1.5
        )

        /// Conservative configuration for strict rate limiting
        static let conservative = Configuration(
            requestsPerSecond: 5,
            requestsPerMinute: 300,
            requestsPerHour: 5_000,
            allowBurst: false,
            burstMultiplier: 1.0
        )

        /// Unlimited configuration (no rate limiting)
        static let unlimited = Configuration(
            requestsPerSecond: 0,
            requestsPerMinute: 0,
            requestsPerHour: 0,
            allowBurst: false,
            burstMultiplier: 1.0
        )

        /// Create configuration from RateLimitConfig model
        init(from config: RateLimitConfig) {
            self.requestsPerSecond = config.requestsPerSecond
            self.requestsPerMinute = config.requestsPerMinute
            self.requestsPerHour = config.requestsPerHour
            self.allowBurst = true
            self.burstMultiplier = 1.5
        }

        init(
            requestsPerSecond: Int,
            requestsPerMinute: Int,
            requestsPerHour: Int,
            allowBurst: Bool = true,
            burstMultiplier: Double = 1.5
        ) {
            self.requestsPerSecond = requestsPerSecond
            self.requestsPerMinute = requestsPerMinute
            self.requestsPerHour = requestsPerHour
            self.allowBurst = allowBurst
            self.burstMultiplier = burstMultiplier
        }
    }

    // MARK: - Token Bucket

    /// Internal token bucket for a specific time window
    private struct TokenBucket {
        let maxTokens: Int
        let refillRate: Double // tokens per second
        var currentTokens: Double
        var lastRefillTime: Date

        init(maxTokens: Int, refillRate: Double) {
            self.maxTokens = maxTokens
            self.refillRate = refillRate
            self.currentTokens = Double(maxTokens)
            self.lastRefillTime = Date()
        }

        mutating func refill() {
            let now = Date()
            let elapsed = now.timeIntervalSince(lastRefillTime)
            let tokensToAdd = elapsed * refillRate
            currentTokens = min(Double(maxTokens), currentTokens + tokensToAdd)
            lastRefillTime = now
        }

        mutating func tryConsume(tokens: Int = 1) -> Bool {
            refill()
            if currentTokens >= Double(tokens) {
                currentTokens -= Double(tokens)
                return true
            }
            return false
        }

        func timeUntilAvailable(tokens: Int = 1) -> TimeInterval {
            let tokensNeeded = Double(tokens) - currentTokens
            if tokensNeeded <= 0 { return 0 }
            return tokensNeeded / refillRate
        }
    }

    // MARK: - Properties

    private let configuration: Configuration
    private var secondBucket: TokenBucket?
    private var minuteBucket: TokenBucket?
    private var hourBucket: TokenBucket?

    /// Total requests made
    private(set) var totalRequests: Int = 0

    /// Requests blocked due to rate limiting
    private(set) var blockedRequests: Int = 0

    /// Requests allowed through
    private(set) var allowedRequests: Int = 0

    // MARK: - Initialization

    init(configuration: Configuration = .default) {
        self.configuration = configuration

        // Initialize buckets based on configuration
        if configuration.requestsPerSecond > 0 {
            let maxTokens = configuration.allowBurst
                ? Int(Double(configuration.requestsPerSecond) * configuration.burstMultiplier)
                : configuration.requestsPerSecond
            secondBucket = TokenBucket(
                maxTokens: maxTokens,
                refillRate: Double(configuration.requestsPerSecond)
            )
        }

        if configuration.requestsPerMinute > 0 {
            let maxTokens = configuration.allowBurst
                ? Int(Double(configuration.requestsPerMinute) * configuration.burstMultiplier)
                : configuration.requestsPerMinute
            minuteBucket = TokenBucket(
                maxTokens: maxTokens,
                refillRate: Double(configuration.requestsPerMinute) / 60.0
            )
        }

        if configuration.requestsPerHour > 0 {
            let maxTokens = configuration.allowBurst
                ? Int(Double(configuration.requestsPerHour) * configuration.burstMultiplier)
                : configuration.requestsPerHour
            hourBucket = TokenBucket(
                maxTokens: maxTokens,
                refillRate: Double(configuration.requestsPerHour) / 3600.0
            )
        }
    }

    // MARK: - Rate Limiting

    /// Check if a request should be allowed (non-blocking)
    func shouldAllow() -> Bool {
        totalRequests += 1

        // Check all buckets - all must allow
        var allowed = true

        if var bucket = secondBucket {
            if !bucket.tryConsume() {
                allowed = false
            }
            secondBucket = bucket
        }

        if var bucket = minuteBucket {
            if !bucket.tryConsume() {
                allowed = false
            }
            minuteBucket = bucket
        }

        if var bucket = hourBucket {
            if !bucket.tryConsume() {
                allowed = false
            }
            hourBucket = bucket
        }

        if allowed {
            allowedRequests += 1
        } else {
            blockedRequests += 1
        }

        return allowed
    }

    /// Wait until a request can be made, then consume a token
    func waitAndConsume() async throws {
        let waitTime = timeUntilAvailable()

        if waitTime > 0 {
            try await Task.sleep(for: .seconds(waitTime))
        }

        _ = shouldAllow()
    }

    /// Get time until next request is available
    func timeUntilAvailable() -> TimeInterval {
        var maxWait: TimeInterval = 0

        if let bucket = secondBucket {
            maxWait = max(maxWait, bucket.timeUntilAvailable())
        }
        if let bucket = minuteBucket {
            maxWait = max(maxWait, bucket.timeUntilAvailable())
        }
        if let bucket = hourBucket {
            maxWait = max(maxWait, bucket.timeUntilAvailable())
        }

        return maxWait
    }

    /// Get current rate limiting statistics
    func statistics() -> RateLimiterStatistics {
        RateLimiterStatistics(
            totalRequests: totalRequests,
            allowedRequests: allowedRequests,
            blockedRequests: blockedRequests,
            blockRate: totalRequests > 0 ? Double(blockedRequests) / Double(totalRequests) : 0,
            currentSecondTokens: secondBucket?.currentTokens ?? 0,
            currentMinuteTokens: minuteBucket?.currentTokens ?? 0,
            currentHourTokens: hourBucket?.currentTokens ?? 0
        )
    }

    /// Reset all statistics
    func resetStatistics() {
        totalRequests = 0
        blockedRequests = 0
        allowedRequests = 0
    }
}

// MARK: - Statistics

/// Rate limiter statistics
struct RateLimiterStatistics: Sendable {
    let totalRequests: Int
    let allowedRequests: Int
    let blockedRequests: Int
    let blockRate: Double
    let currentSecondTokens: Double
    let currentMinuteTokens: Double
    let currentHourTokens: Double
}

// MARK: - Rate Limited Platform Adapter

/// Wrapper that adds rate limiting to any PlatformAdapter
actor RateLimitedPlatformAdapter: PlatformAdapter {
    private let underlying: any PlatformAdapter
    private let rateLimiter: RateLimiter

    var platformName: String {
        get async { await underlying.platformName }
    }

    var isConnected: Bool {
        get async { await underlying.isConnected }
    }

    init(adapter: any PlatformAdapter, configuration: RateLimiter.Configuration = .default) {
        self.underlying = adapter
        self.rateLimiter = RateLimiter(configuration: configuration)
    }

    func connect(credentials: PlatformCredentials) async throws {
        try await rateLimiter.waitAndConsume()
        try await underlying.connect(credentials: credentials)
    }

    func disconnect() async {
        await underlying.disconnect()
    }

    func listAgents() async throws -> [PlatformAgent] {
        try await rateLimiter.waitAndConsume()
        return try await underlying.listAgents()
    }

    func getAgentDetails(id: String) async throws -> PlatformAgent {
        try await rateLimiter.waitAndConsume()
        return try await underlying.getAgentDetails(id: id)
    }

    func getMetrics(agentId: String) async throws -> PlatformMetrics {
        try await rateLimiter.waitAndConsume()
        return try await underlying.getMetrics(agentId: agentId)
    }

    func startAgent(id: String, configuration: [String: String]?) async throws {
        try await rateLimiter.waitAndConsume()
        try await underlying.startAgent(id: id, configuration: configuration)
    }

    func stopAgent(id: String) async throws {
        try await rateLimiter.waitAndConsume()
        try await underlying.stopAgent(id: id)
    }

    func sendRequest(agentId: String, payload: Data) async throws -> Data {
        try await rateLimiter.waitAndConsume()
        return try await underlying.sendRequest(agentId: agentId, payload: payload)
    }

    /// Get rate limiter statistics
    func getRateLimiterStatistics() async -> RateLimiterStatistics {
        await rateLimiter.statistics()
    }
}

// MARK: - Rate Limit Error

/// Error thrown when rate limit is exceeded
enum RateLimitError: Error, LocalizedError {
    case limitExceeded(retryAfter: TimeInterval)
    case configurationError

    var errorDescription: String? {
        switch self {
        case .limitExceeded(let retryAfter):
            return "Rate limit exceeded. Retry after \(String(format: "%.1f", retryAfter)) seconds."
        case .configurationError:
            return "Rate limiter configuration error"
        }
    }
}
