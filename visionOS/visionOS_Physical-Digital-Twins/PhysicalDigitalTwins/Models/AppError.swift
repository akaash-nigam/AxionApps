//
//  AppError.swift
//  PhysicalDigitalTwins
//
//  App-wide error types
//

import Foundation

struct AppError: LocalizedError, Identifiable {
    let id = UUID()
    let type: ErrorType
    let underlyingError: Error?

    init(type: ErrorType, underlyingError: Error? = nil) {
        self.type = type
        self.underlyingError = underlyingError
    }

    init(from error: Error) {
        if let appError = error as? AppError {
            self = appError
        } else if let networkError = error as? NetworkError {
            self.type = .network(networkError)
            self.underlyingError = error
        } else if let dataError = error as? DataError {
            self.type = .data(dataError)
            self.underlyingError = error
        } else {
            self.type = .unknown
            self.underlyingError = error
        }
    }

    var errorDescription: String? {
        type.errorDescription
    }

    var recoverySuggestion: String? {
        type.recoverySuggestion
    }
}

// MARK: - Error Types

enum ErrorType {
    case network(NetworkError)
    case data(DataError)
    case recognition(RecognitionError)
    case unknown

    var errorDescription: String? {
        switch self {
        case .network(let error):
            return error.errorDescription
        case .data(let error):
            return error.errorDescription
        case .recognition(let error):
            return error.errorDescription
        case .unknown:
            return "An unknown error occurred"
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .network(let error):
            return error.recoverySuggestion
        case .data(let error):
            return error.recoverySuggestion
        case .recognition(let error):
            return error.recoverySuggestion
        case .unknown:
            return "Please try again"
        }
    }
}

// MARK: - Network Errors

enum NetworkError: LocalizedError {
    case offline
    case timeout
    case serverError(Int)
    case invalidResponse
    case rateLimitExceeded
    case notFound

    var errorDescription: String? {
        switch self {
        case .offline:
            return "No internet connection"
        case .timeout:
            return "Request timed out"
        case .serverError(let code):
            return "Server error (\(code))"
        case .invalidResponse:
            return "Invalid server response"
        case .rateLimitExceeded:
            return "Too many requests"
        case .notFound:
            return "Not found"
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .offline:
            return "Check your connection and try again"
        case .timeout:
            return "Check your connection speed"
        case .serverError:
            return "The service may be temporarily unavailable"
        case .invalidResponse:
            return "Please update the app"
        case .rateLimitExceeded:
            return "Wait a few minutes before trying again"
        case .notFound:
            return "The item was not found in our database"
        }
    }
}

// MARK: - Data Errors

enum DataError: LocalizedError {
    case saveFailed
    case fetchFailed
    case deleteFailed
    case corruptedData
    case notFound

    var errorDescription: String? {
        switch self {
        case .saveFailed:
            return "Failed to save data"
        case .fetchFailed:
            return "Failed to load data"
        case .deleteFailed:
            return "Failed to delete item"
        case .corruptedData:
            return "Data is corrupted"
        case .notFound:
            return "Item not found"
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .saveFailed, .deleteFailed:
            return "Please try again"
        case .fetchFailed:
            return "Try restarting the app"
        case .corruptedData:
            return "You may need to reinstall the app"
        case .notFound:
            return "The item may have been deleted"
        }
    }
}

// MARK: - Recognition Errors

enum RecognitionError: LocalizedError {
    case unrecognized
    case lowConfidence
    case poorLighting
    case objectTooFar
    case cameraPermissionDenied
    case modelLoadFailed

    var errorDescription: String? {
        switch self {
        case .unrecognized:
            return "Couldn't identify this object"
        case .lowConfidence:
            return "Not sure what this object is"
        case .poorLighting:
            return "Lighting is too poor"
        case .objectTooFar:
            return "Object is too far away"
        case .cameraPermissionDenied:
            return "Camera permission denied"
        case .modelLoadFailed:
            return "Recognition model failed to load"
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .unrecognized, .lowConfidence:
            return "Try scanning a barcode or entering details manually"
        case .poorLighting:
            return "Move to better lighting or turn on lights"
        case .objectTooFar:
            return "Move closer to the object (10-50cm optimal)"
        case .cameraPermissionDenied:
            return "Enable camera access in Settings"
        case .modelLoadFailed:
            return "Restart the app or reinstall if problem persists"
        }
    }
}
