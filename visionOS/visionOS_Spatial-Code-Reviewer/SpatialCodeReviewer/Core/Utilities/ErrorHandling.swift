//
//  ErrorHandling.swift
//  SpatialCodeReviewer
//
//  Created by Claude on 2025-11-25.
//  Story 0.10: Polish & Bug Fixes - Error Handling
//

import Foundation

// MARK: - Application Errors

/// Comprehensive error types for the application
enum AppError: LocalizedError {
    // File System Errors
    case fileNotFound(String)
    case fileTooBig(String, Int)
    case binaryFile(String)
    case invalidEncoding(String)
    case directoryNotFound(String)
    case permissionDenied(String)

    // Network Errors
    case networkTimeout
    case noInternetConnection
    case serverError(Int)
    case rateLimitExceeded
    case invalidResponse

    // Repository Errors
    case repositoryNotCloned
    case repositoryEmpty
    case invalidRepository
    case branchNotFound(String)
    case gitOperationFailed(String)

    // Authentication Errors
    case authenticationFailed
    case tokenExpired
    case tokenInvalid
    case missingPermissions([String])

    // Parsing Errors
    case jsonDecodingFailed(String)
    case syntaxHighlightingFailed
    case invalidFileStructure

    // 3D Rendering Errors
    case textureGenerationFailed
    case entityCreationFailed
    case sceneSetupFailed

    var errorDescription: String? {
        switch self {
        // File System
        case .fileNotFound(let path):
            return "File not found: \(path)"
        case .fileTooBig(let name, let size):
            let mb = Double(size) / 1_000_000.0
            return "File '\(name)' is too large (\(String(format: "%.1f", mb))MB). Maximum size is 50KB for performance."
        case .binaryFile(let name):
            return "'\(name)' is a binary file and cannot be displayed as text."
        case .invalidEncoding(let name):
            return "File '\(name)' has an unsupported text encoding."
        case .directoryNotFound(let path):
            return "Directory not found: \(path)"
        case .permissionDenied(let path):
            return "Permission denied accessing: \(path)"

        // Network
        case .networkTimeout:
            return "Network request timed out. Please check your internet connection and try again."
        case .noInternetConnection:
            return "No internet connection. Please connect to the internet and try again."
        case .serverError(let code):
            return "Server error (HTTP \(code)). Please try again later."
        case .rateLimitExceeded:
            return "GitHub API rate limit exceeded. Please wait a few minutes and try again."
        case .invalidResponse:
            return "Received invalid response from server."

        // Repository
        case .repositoryNotCloned:
            return "Repository has not been downloaded yet. Please download it first."
        case .repositoryEmpty:
            return "This repository is empty. No files to display."
        case .invalidRepository:
            return "Invalid repository format."
        case .branchNotFound(let branch):
            return "Branch '\(branch)' not found."
        case .gitOperationFailed(let operation):
            return "Git operation failed: \(operation)"

        // Authentication
        case .authenticationFailed:
            return "Authentication failed. Please sign in again."
        case .tokenExpired:
            return "Your session has expired. Please sign in again."
        case .tokenInvalid:
            return "Invalid authentication token. Please sign in again."
        case .missingPermissions(let perms):
            return "Missing required permissions: \(perms.joined(separator: ", "))"

        // Parsing
        case .jsonDecodingFailed(let type):
            return "Failed to decode \(type) from JSON."
        case .syntaxHighlightingFailed:
            return "Syntax highlighting failed. Showing plain text."
        case .invalidFileStructure:
            return "Invalid file structure."

        // 3D Rendering
        case .textureGenerationFailed:
            return "Failed to generate texture for code display."
        case .entityCreationFailed:
            return "Failed to create 3D entity."
        case .sceneSetupFailed:
            return "Failed to setup 3D scene."
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .fileTooBig:
            return "Try viewing a smaller file or adjust the file size limit in settings."
        case .binaryFile:
            return "Binary files cannot be displayed as code. Try a text file instead."
        case .networkTimeout, .noInternetConnection:
            return "Check your internet connection and try again."
        case .rateLimitExceeded:
            return "Wait for the rate limit to reset (usually 60 minutes) or authenticate to increase your limit."
        case .authenticationFailed, .tokenExpired, .tokenInvalid:
            return "Go to settings and sign in again."
        case .repositoryEmpty:
            return "This repository has no files. Try selecting a different repository."
        case .invalidEncoding:
            return "The file may be corrupted or use an unsupported encoding."
        default:
            return "Please try again or contact support if the problem persists."
        }
    }
}

// MARK: - File Validation

/// Validates files before processing
struct FileValidator {

    /// Maximum file size (50KB)
    static let maxFileSize: Int = 50_000

    /// Binary file extensions
    static let binaryExtensions: Set<String> = [
        "png", "jpg", "jpeg", "gif", "bmp", "ico", "svg",
        "mp4", "mov", "avi", "mkv",
        "mp3", "wav", "aac",
        "zip", "tar", "gz", "7z", "rar",
        "pdf", "doc", "docx", "xls", "xlsx", "ppt", "pptx",
        "exe", "dll", "so", "dylib", "o", "a",
        "ttf", "otf", "woff", "woff2"
    ]

    /// Validates a file for display
    static func validate(path: String, content: Data) throws {
        // Check file size
        if content.count > maxFileSize {
            let fileName = URL(fileURLWithPath: path).lastPathComponent
            throw AppError.fileTooBig(fileName, content.count)
        }

        // Check if binary
        let ext = URL(fileURLWithPath: path).pathExtension.lowercased()
        if binaryExtensions.contains(ext) {
            let fileName = URL(fileURLWithPath: path).lastPathComponent
            throw AppError.binaryFile(fileName)
        }

        // Check if content is valid text
        if isBinaryContent(content) {
            let fileName = URL(fileURLWithPath: path).lastPathComponent
            throw AppError.binaryFile(fileName)
        }

        // Try to decode as UTF-8
        if String(data: content, encoding: .utf8) == nil {
            let fileName = URL(fileURLWithPath: path).lastPathComponent
            throw AppError.invalidEncoding(fileName)
        }
    }

    /// Detects if content is binary based on null bytes
    private static func isBinaryContent(_ data: Data) -> Bool {
        // Check first 8KB for null bytes (common binary indicator)
        let sampleSize = min(data.count, 8192)
        let sample = data.prefix(sampleSize)

        // If more than 10% null bytes, likely binary
        let nullCount = sample.filter { $0 == 0 }.count
        return Double(nullCount) / Double(sampleSize) > 0.1
    }

    /// Returns user-friendly file type description
    static func fileTypeDescription(path: String) -> String {
        let ext = URL(fileURLWithPath: path).pathExtension.lowercased()

        if binaryExtensions.contains(ext) {
            switch ext {
            case "png", "jpg", "jpeg", "gif", "bmp", "ico", "svg":
                return "Image"
            case "mp4", "mov", "avi", "mkv":
                return "Video"
            case "mp3", "wav", "aac":
                return "Audio"
            case "zip", "tar", "gz", "7z", "rar":
                return "Archive"
            case "pdf":
                return "PDF Document"
            case "exe", "dll", "so", "dylib":
                return "Binary"
            default:
                return "Binary File"
            }
        }

        return "Text File"
    }
}

// MARK: - Network Error Handling

extension URLError {
    var appError: AppError {
        switch code {
        case .notConnectedToInternet, .networkConnectionLost:
            return .noInternetConnection
        case .timedOut:
            return .networkTimeout
        default:
            return .invalidResponse
        }
    }
}

extension HTTPURLResponse {
    var appError: AppError? {
        switch statusCode {
        case 200...299:
            return nil
        case 401, 403:
            return .authenticationFailed
        case 404:
            return .invalidResponse
        case 429:
            return .rateLimitExceeded
        case 500...599:
            return .serverError(statusCode)
        default:
            return .invalidResponse
        }
    }
}

// MARK: - User-Friendly Error Presenter

/// Formats errors for display to users
struct ErrorPresenter {

    /// Converts any error to a user-friendly message
    static func message(for error: Error) -> (title: String, message: String, suggestion: String?) {
        if let appError = error as? AppError {
            return (
                title: "Error",
                message: appError.errorDescription ?? "An unknown error occurred.",
                suggestion: appError.recoverySuggestion
            )
        }

        if let urlError = error as? URLError {
            let appError = urlError.appError
            return (
                title: "Network Error",
                message: appError.errorDescription ?? "Network error occurred.",
                suggestion: appError.recoverySuggestion
            )
        }

        // Fallback
        return (
            title: "Error",
            message: error.localizedDescription,
            suggestion: "Please try again or contact support if the problem persists."
        )
    }

    /// Logs error with context
    static func log(_ error: Error, context: String) {
        let (title, message, suggestion) = ErrorPresenter.message(for: error)

        print("❌ [\(context)] \(title): \(message)")
        if let suggestion = suggestion {
            print("   💡 \(suggestion)")
        }
        print("   🔍 Raw error: \(error)")
    }
}
