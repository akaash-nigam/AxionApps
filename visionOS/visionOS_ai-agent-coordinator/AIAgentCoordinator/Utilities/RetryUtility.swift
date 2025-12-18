//
//  RetryUtility.swift
//  AIAgentCoordinator
//
//  Utilities for retrying failed operations with exponential backoff
//  Created by AI Agent Coordinator on 2025-01-20.
//

import Foundation

// MARK: - Retry Configuration

/// Configuration for retry behavior
struct RetryConfiguration: Sendable {
    /// Maximum number of retry attempts
    let maxAttempts: Int

    /// Initial delay before first retry
    let initialDelay: Duration

    /// Maximum delay between retries
    let maxDelay: Duration

    /// Multiplier for exponential backoff (delay * multiplier each attempt)
    let backoffMultiplier: Double

    /// Whether to add jitter to delay (helps prevent thundering herd)
    let useJitter: Bool

    /// Default configuration with 3 retries and exponential backoff
    static let `default` = RetryConfiguration(
        maxAttempts: 3,
        initialDelay: .seconds(1),
        maxDelay: .seconds(30),
        backoffMultiplier: 2.0,
        useJitter: true
    )

    /// Aggressive retry configuration for critical operations
    static let aggressive = RetryConfiguration(
        maxAttempts: 5,
        initialDelay: .milliseconds(500),
        maxDelay: .seconds(60),
        backoffMultiplier: 2.0,
        useJitter: true
    )

    /// Conservative configuration for non-critical operations
    static let conservative = RetryConfiguration(
        maxAttempts: 2,
        initialDelay: .seconds(2),
        maxDelay: .seconds(10),
        backoffMultiplier: 1.5,
        useJitter: false
    )

    /// No retry configuration
    static let none = RetryConfiguration(
        maxAttempts: 1,
        initialDelay: .zero,
        maxDelay: .zero,
        backoffMultiplier: 1.0,
        useJitter: false
    )
}

// MARK: - Retry Error

/// Error thrown when all retry attempts have been exhausted
struct RetryExhaustedError: Error, LocalizedError {
    let attempts: Int
    let lastError: Error

    var errorDescription: String? {
        "Operation failed after \(attempts) attempts. Last error: \(lastError.localizedDescription)"
    }
}

// MARK: - Retry Result

/// Result of a retry operation including metadata
struct RetryResult<T> {
    let value: T
    let attempts: Int
    let totalDuration: Duration
}

// MARK: - Retry Utility

/// Utility for executing operations with automatic retry on failure
enum RetryUtility {

    /// Execute an async operation with retry logic
    /// - Parameters:
    ///   - configuration: Retry configuration to use
    ///   - shouldRetry: Optional closure to determine if error is retryable
    ///   - operation: The async operation to execute
    /// - Returns: The result of the successful operation
    /// - Throws: RetryExhaustedError if all attempts fail, or the last error if not retryable
    static func withRetry<T>(
        configuration: RetryConfiguration = .default,
        shouldRetry: ((Error) -> Bool)? = nil,
        operation: @Sendable () async throws -> T
    ) async throws -> T {
        var lastError: Error?
        var currentDelay = configuration.initialDelay

        for attempt in 1...configuration.maxAttempts {
            do {
                return try await operation()
            } catch {
                lastError = error

                // Check if we should retry this error
                if let shouldRetry = shouldRetry, !shouldRetry(error) {
                    throw error
                }

                // Don't sleep after the last attempt
                if attempt < configuration.maxAttempts {
                    // Calculate delay with optional jitter
                    var delay = currentDelay
                    if configuration.useJitter {
                        let jitter = Duration.milliseconds(Int.random(in: 0...500))
                        delay = delay + jitter
                    }

                    // Cap at max delay
                    if delay > configuration.maxDelay {
                        delay = configuration.maxDelay
                    }

                    try await Task.sleep(for: delay)

                    // Increase delay for next attempt
                    let delayNanos = Double(delay.components.seconds) * 1_000_000_000 +
                                     Double(delay.components.attoseconds) / 1_000_000_000
                    let newDelayNanos = delayNanos * configuration.backoffMultiplier
                    currentDelay = .nanoseconds(Int64(newDelayNanos))
                }
            }
        }

        throw RetryExhaustedError(attempts: configuration.maxAttempts, lastError: lastError!)
    }

    /// Execute an async operation with retry logic and return metadata
    static func withRetryAndMetadata<T>(
        configuration: RetryConfiguration = .default,
        shouldRetry: ((Error) -> Bool)? = nil,
        operation: @Sendable () async throws -> T
    ) async throws -> RetryResult<T> {
        let startTime = ContinuousClock.now
        var attempts = 0

        let value = try await withRetry(
            configuration: configuration,
            shouldRetry: { error in
                attempts += 1
                return shouldRetry?(error) ?? true
            },
            operation: operation
        )

        let duration = ContinuousClock.now - startTime

        return RetryResult(
            value: value,
            attempts: attempts + 1, // +1 for successful attempt
            totalDuration: duration
        )
    }
}

// MARK: - Retryable Error Protocol

/// Protocol for errors that can indicate whether they should be retried
protocol RetryableError: Error {
    /// Whether this error is retryable
    var isRetryable: Bool { get }
}

// MARK: - Network Error Classification

/// Common network errors with retry classification
enum NetworkError: Error, RetryableError, LocalizedError {
    case connectionFailed
    case timeout
    case serverError(statusCode: Int)
    case clientError(statusCode: Int)
    case noInternet
    case rateLimited(retryAfter: Duration?)
    case unknown(underlying: Error)

    var isRetryable: Bool {
        switch self {
        case .connectionFailed, .timeout, .noInternet:
            return true
        case .serverError(let code):
            // Retry on 5xx errors except 501 (Not Implemented)
            return code >= 500 && code != 501
        case .rateLimited:
            return true
        case .clientError, .unknown:
            return false
        }
    }

    var errorDescription: String? {
        switch self {
        case .connectionFailed:
            return "Connection failed"
        case .timeout:
            return "Request timed out"
        case .serverError(let code):
            return "Server error (\(code))"
        case .clientError(let code):
            return "Client error (\(code))"
        case .noInternet:
            return "No internet connection"
        case .rateLimited(let retryAfter):
            if let retryAfter {
                return "Rate limited. Retry after \(retryAfter)"
            }
            return "Rate limited"
        case .unknown(let error):
            return "Unknown error: \(error.localizedDescription)"
        }
    }
}

// MARK: - Extension for Common Retry Patterns

extension RetryUtility {

    /// Retry with default network error handling
    static func withNetworkRetry<T>(
        maxAttempts: Int = 3,
        operation: @Sendable () async throws -> T
    ) async throws -> T {
        try await withRetry(
            configuration: RetryConfiguration(
                maxAttempts: maxAttempts,
                initialDelay: .seconds(1),
                maxDelay: .seconds(30),
                backoffMultiplier: 2.0,
                useJitter: true
            ),
            shouldRetry: { error in
                if let retryable = error as? RetryableError {
                    return retryable.isRetryable
                }
                // Default: retry on any error
                return true
            },
            operation: operation
        )
    }
}
