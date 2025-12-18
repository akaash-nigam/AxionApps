//
//  ErrorHandling.swift
//  BusinessOperatingSystem
//
//  Created by BOS Team on 2025-01-20.
//

import Foundation

// MARK: - BOS Errors

enum BOSError: LocalizedError {
    // Authentication Errors
    case authenticationFailed
    case biometricsNotAvailable
    case userNotAuthenticated

    // Data Errors
    case dataNotFound
    case invalidData
    case decodingFailed(Error)
    case encodingFailed(Error)

    // Network Errors
    case networkUnavailable
    case serverError(Int)
    case invalidResponse
    case timeout

    // Repository Errors
    case fetchFailed(String)
    case saveFailed(String)
    case deleteFailed(String)

    // Sync Errors
    case syncFailed
    case conflictDetected
    case versionMismatch

    // Permission Errors
    case insufficientPermissions
    case resourceAccessDenied

    // Validation Errors
    case validationFailed(String)
    case requiredFieldMissing(String)

    var errorDescription: String? {
        switch self {
        case .authenticationFailed:
            return "Authentication failed. Please try again."
        case .biometricsNotAvailable:
            return "Biometric authentication is not available on this device."
        case .userNotAuthenticated:
            return "You must be logged in to perform this action."

        case .dataNotFound:
            return "The requested data could not be found."
        case .invalidData:
            return "The data is invalid or corrupted."
        case .decodingFailed(let error):
            return "Failed to decode data: \(error.localizedDescription)"
        case .encodingFailed(let error):
            return "Failed to encode data: \(error.localizedDescription)"

        case .networkUnavailable:
            return "Network connection is unavailable. Please check your internet connection."
        case .serverError(let code):
            return "Server error occurred (HTTP \(code)). Please try again later."
        case .invalidResponse:
            return "Invalid response from server."
        case .timeout:
            return "Request timed out. Please try again."

        case .fetchFailed(let resource):
            return "Failed to fetch \(resource). Please try again."
        case .saveFailed(let resource):
            return "Failed to save \(resource). Please try again."
        case .deleteFailed(let resource):
            return "Failed to delete \(resource). Please try again."

        case .syncFailed:
            return "Data synchronization failed. Some data may be outdated."
        case .conflictDetected:
            return "A conflict was detected with server data. Please refresh and try again."
        case .versionMismatch:
            return "Data version mismatch. Please update the app."

        case .insufficientPermissions:
            return "You don't have permission to perform this action."
        case .resourceAccessDenied:
            return "Access to this resource is denied."

        case .validationFailed(let message):
            return "Validation failed: \(message)"
        case .requiredFieldMissing(let field):
            return "Required field '\(field)' is missing."
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .authenticationFailed:
            return "Try logging in again or contact support if the problem persists."
        case .biometricsNotAvailable:
            return "Please use password authentication instead."
        case .networkUnavailable:
            return "Check your Wi-Fi or cellular connection and try again."
        case .serverError:
            return "The server is experiencing issues. Please try again in a few moments."
        case .syncFailed:
            return "Pull to refresh to retry synchronization."
        case .conflictDetected:
            return "Refresh your data and make the changes again."
        default:
            return "If the problem persists, please contact support."
        }
    }
}

// MARK: - Error Handler

actor ErrorHandler {
    static let shared = ErrorHandler()

    private var errors: [UUID: (error: Error, timestamp: Date)] = [:]
    private let maxErrorAge: TimeInterval = 300  // 5 minutes

    func record(error: Error) -> UUID {
        let id = UUID()
        errors[id] = (error, Date())
        cleanupOldErrors()
        return id
    }

    func getError(for id: UUID) -> Error? {
        errors[id]?.error
    }

    func clearError(for id: UUID) {
        errors.removeValue(forKey: id)
    }

    private func cleanupOldErrors() {
        let cutoff = Date().addingTimeInterval(-maxErrorAge)
        errors = errors.filter { $0.value.timestamp > cutoff }
    }

    func clearAll() {
        errors.removeAll()
    }
}

// MARK: - Result Extensions

extension Result {
    /// Convert to BOSError if failure
    func mapBOSError() -> Result<Success, BOSError> where Failure == Error {
        mapError { error in
            if let bosError = error as? BOSError {
                return bosError
            }
            return .invalidData
        }
    }
}

// MARK: - Error Recovery

enum ErrorRecoveryAction {
    case retry
    case cancel
    case useCache
    case skip
    case custom(String, () async -> Void)

    var title: String {
        switch self {
        case .retry: return "Retry"
        case .cancel: return "Cancel"
        case .useCache: return "Use Cached Data"
        case .skip: return "Skip"
        case .custom(let title, _): return title
        }
    }
}

// MARK: - Error Alert Configuration

struct ErrorAlertConfig: Equatable {
    let title: String
    let message: String
    let actions: [ErrorRecoveryAction]

    static func == (lhs: ErrorAlertConfig, rhs: ErrorAlertConfig) -> Bool {
        // Compare only title and message since actions contain closures
        lhs.title == rhs.title && lhs.message == rhs.message
    }

    static func from(error: Error) -> ErrorAlertConfig {
        if let bosError = error as? BOSError {
            return ErrorAlertConfig(
                title: "Error",
                message: bosError.errorDescription ?? "An error occurred",
                actions: suggestedActions(for: bosError)
            )
        }

        return ErrorAlertConfig(
            title: "Error",
            message: error.localizedDescription,
            actions: [.retry, .cancel]
        )
    }

    private static func suggestedActions(for error: BOSError) -> [ErrorRecoveryAction] {
        switch error {
        case .networkUnavailable, .timeout:
            return [.retry, .useCache, .cancel]

        case .serverError:
            return [.retry, .cancel]

        case .authenticationFailed:
            return [.retry, .cancel]

        case .syncFailed:
            return [.retry, .skip, .cancel]

        default:
            return [.retry, .cancel]
        }
    }
}
