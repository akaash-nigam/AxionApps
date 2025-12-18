import Foundation

/// Errors related to file format operations
public enum FileFormatError: LocalizedError {

    case unsupportedFormat(extension: String)
    case fileNotFound(path: String)
    case fileCorrupted(path: String)
    case invalidFileHeader(format: String)
    case importFailed(format: String, reason: String)
    case exportFailed(format: String, reason: String)
    case conversionFailed(from: String, to: String, reason: String)
    case fileAccessDenied(path: String)
    case fileTooLarge(size: Int64, maximum: Int64)
    case invalidEncoding(expected: String)
    case missingRequiredData(field: String)
    case parsingError(line: Int, reason: String)

    public var errorDescription: String? {
        switch self {
        case .unsupportedFormat(let ext):
            return "Unsupported file format: .\(ext)"
        case .fileNotFound(let path):
            return "File not found: \(path)"
        case .fileCorrupted(let path):
            return "File is corrupted: \(path)"
        case .invalidFileHeader(let format):
            return "Invalid \(format) file header"
        case .importFailed(let format, let reason):
            return "Failed to import \(format) file: \(reason)"
        case .exportFailed(let format, let reason):
            return "Failed to export to \(format): \(reason)"
        case .conversionFailed(let from, let to, let reason):
            return "Failed to convert from \(from) to \(to): \(reason)"
        case .fileAccessDenied(let path):
            return "Access denied to file: \(path)"
        case .fileTooLarge(let size, let maximum):
            return "File size \(ByteCountFormatter.string(fromByteCount: size, countStyle: .file)) exceeds maximum of \(ByteCountFormatter.string(fromByteCount: maximum, countStyle: .file))"
        case .invalidEncoding(let expected):
            return "Invalid file encoding (expected: \(expected))"
        case .missingRequiredData(let field):
            return "Missing required data: \(field)"
        case .parsingError(let line, let reason):
            return "Parse error at line \(line): \(reason)"
        }
    }

    public var recoverySuggestion: String? {
        switch self {
        case .unsupportedFormat:
            return "Convert the file to a supported format (STEP, IGES, STL)"
        case .fileCorrupted:
            return "Try re-exporting the file from the source application"
        case .fileTooLarge:
            return "Simplify the model or split into smaller files"
        default:
            return nil
        }
    }
}
