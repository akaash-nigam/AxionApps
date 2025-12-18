import Foundation
import UniformTypeIdentifiers

/// Utilities for CAD file format validation and detection
public enum FileFormatUtilities {

    // MARK: - Supported Formats

    /// Supported CAD file formats
    public enum CADFileFormat: String, CaseIterable {
        case step = "stp"
        case stepAlternate = "step"
        case iges = "igs"
        case igesAlternate = "iges"
        case stl = "stl"
        case obj = "obj"
        case dxf = "dxf"
        case dwg = "dwg"
        case parasolid = "x_t"
        case parasolidBinary = "x_b"
        case jt = "jt"
        case catia = "CATPart"

        var displayName: String {
            switch self {
            case .step, .stepAlternate:
                return "STEP (ISO 10303)"
            case .iges, .igesAlternate:
                return "IGES"
            case .stl:
                return "STL"
            case .obj:
                return "OBJ"
            case .dxf:
                return "DXF"
            case .dwg:
                return "DWG"
            case .parasolid, .parasolidBinary:
                return "Parasolid"
            case .jt:
                return "JT"
            case .catia:
                return "CATIA"
            }
        }

        var isTextBased: Bool {
            switch self {
            case .step, .stepAlternate, .iges, .igesAlternate, .obj, .dxf:
                return true
            case .stl, .dwg, .parasolid, .parasolidBinary, .jt, .catia:
                return false
            }
        }

        var supportsAssemblies: Bool {
            switch self {
            case .step, .stepAlternate, .iges, .igesAlternate, .parasolid, .parasolidBinary, .jt, .catia:
                return true
            case .stl, .obj, .dxf, .dwg:
                return false
            }
        }

        var supportsPMI: Bool { // Product Manufacturing Information
            switch self {
            case .step, .stepAlternate, .jt, .catia:
                return true
            default:
                return false
            }
        }
    }

    // MARK: - File Detection

    /// Detect CAD file format from file extension
    /// - Parameter url: File URL
    /// - Returns: Detected format or nil
    public static func detectFormat(from url: URL) -> CADFileFormat? {
        let fileExtension = url.pathExtension.lowercased()
        return CADFileFormat.allCases.first { $0.rawValue == fileExtension }
    }

    /// Detect CAD file format from file path
    /// - Parameter path: File path
    /// - Returns: Detected format or nil
    public static func detectFormat(fromPath path: String) -> CADFileFormat? {
        let url = URL(fileURLWithPath: path)
        return detectFormat(from: url)
    }

    /// Check if file has a supported CAD format
    /// - Parameter url: File URL
    /// - Returns: True if format is supported
    public static func isSupportedFormat(_ url: URL) -> Bool {
        return detectFormat(from: url) != nil
    }

    // MARK: - File Validation

    /// Validate STEP file header
    /// - Parameter url: File URL
    /// - Returns: True if valid STEP file
    public static func validateSTEPFile(_ url: URL) -> Bool {
        guard let data = try? Data(contentsOf: url, options: .mappedIfSafe) else {
            return false
        }

        // Read first few lines
        guard let content = String(data: data.prefix(1024), encoding: .utf8) else {
            return false
        }

        // STEP files should start with ISO-10303
        let hasValidHeader = content.contains("ISO-10303") ||
                           content.contains("STEP") ||
                           content.hasPrefix("ISO-10303-21")

        return hasValidHeader
    }

    /// Validate IGES file header
    /// - Parameter url: File URL
    /// - Returns: True if valid IGES file
    public static func validateIGESFile(_ url: URL) -> Bool {
        guard let data = try? Data(contentsOf: url, options: .mappedIfSafe) else {
            return false
        }

        // Read first line (80 characters for IGES)
        guard let content = String(data: data.prefix(160), encoding: .utf8) else {
            return false
        }

        // IGES files have 'S' in column 73 of first record
        let lines = content.components(separatedBy: .newlines)
        guard let firstLine = lines.first, firstLine.count >= 73 else {
            return false
        }

        let columnIndex = firstLine.index(firstLine.startIndex, offsetBy: 72)
        return firstLine[columnIndex] == "S"
    }

    /// Validate STL file header
    /// - Parameter url: File URL
    /// - Returns: True if valid STL file
    public static func validateSTLFile(_ url: URL) -> Bool {
        guard let data = try? Data(contentsOf: url, options: .mappedIfSafe) else {
            return false
        }

        if data.count < 84 {
            return false
        }

        // Check if it's ASCII STL
        if let content = String(data: data.prefix(100), encoding: .utf8),
           content.lowercased().hasPrefix("solid") {
            return true
        }

        // Binary STL has 80-byte header + 4-byte triangle count
        return data.count >= 84
    }

    /// Validate OBJ file
    /// - Parameter url: File URL
    /// - Returns: True if valid OBJ file
    public static func validateOBJFile(_ url: URL) -> Bool {
        guard let data = try? Data(contentsOf: url, options: .mappedIfSafe) else {
            return false
        }

        guard let content = String(data: data.prefix(1024), encoding: .utf8) else {
            return false
        }

        // OBJ files contain vertex (v), texture (vt), normal (vn), or face (f) declarations
        let hasOBJKeywords = content.contains("v ") ||
                            content.contains("vt ") ||
                            content.contains("vn ") ||
                            content.contains("f ")

        return hasOBJKeywords
    }

    /// Validate CAD file based on format
    /// - Parameter url: File URL
    /// - Returns: True if valid
    public static func validateCADFile(_ url: URL) -> Bool {
        guard let format = detectFormat(from: url) else {
            return false
        }

        switch format {
        case .step, .stepAlternate:
            return validateSTEPFile(url)
        case .iges, .igesAlternate:
            return validateIGESFile(url)
        case .stl:
            return validateSTLFile(url)
        case .obj:
            return validateOBJFile(url)
        default:
            // For formats we can't validate content, just check extension
            return true
        }
    }

    // MARK: - File Info

    /// Get file size in human-readable format
    /// - Parameter url: File URL
    /// - Returns: Formatted file size string
    public static func formatFileSize(_ url: URL) -> String? {
        guard let attributes = try? FileManager.default.attributesOfItem(atPath: url.path),
              let fileSize = attributes[.size] as? Int64 else {
            return nil
        }

        return ByteCountFormatter.string(fromByteCount: fileSize, countStyle: .file)
    }

    /// Get estimated complexity based on file size
    /// - Parameter url: File URL
    /// - Returns: Complexity level
    public static func estimateComplexity(from url: URL) -> String {
        guard let attributes = try? FileManager.default.attributesOfItem(atPath: url.path),
              let fileSize = attributes[.size] as? Int64 else {
            return "Unknown"
        }

        let sizeMB = Double(fileSize) / 1_048_576.0 // Convert to MB

        if sizeMB < 1.0 {
            return "Simple"
        } else if sizeMB < 10.0 {
            return "Moderate"
        } else if sizeMB < 50.0 {
            return "Complex"
        } else {
            return "Very Complex"
        }
    }

    // MARK: - File Name Validation

    /// Validate file name for CAD operations
    /// - Parameter fileName: File name to validate
    /// - Returns: True if valid
    public static func isValidFileName(_ fileName: String) -> Bool {
        // Check for empty name
        guard !fileName.isEmpty else { return false }

        // Check for invalid characters
        let invalidCharacters = CharacterSet(charactersIn: "/\\:*?\"<>|")
        if fileName.rangeOfCharacter(from: invalidCharacters) != nil {
            return false
        }

        // Check length (max 255 characters)
        guard fileName.count <= 255 else { return false }

        return true
    }

    /// Sanitize file name for safe storage
    /// - Parameter fileName: Original file name
    /// - Returns: Sanitized file name
    public static func sanitizeFileName(_ fileName: String) -> String {
        let invalidCharacters = CharacterSet(charactersIn: "/\\:*?\"<>|")
        let components = fileName.components(separatedBy: invalidCharacters)
        var sanitized = components.joined(separator: "_")

        // Limit length
        if sanitized.count > 255 {
            let index = sanitized.index(sanitized.startIndex, offsetBy: 255)
            sanitized = String(sanitized[..<index])
        }

        return sanitized.isEmpty ? "unnamed" : sanitized
    }

    // MARK: - MIME Types

    /// Get MIME type for CAD file format
    /// - Parameter format: CAD file format
    /// - Returns: MIME type string
    public static func mimeType(for format: CADFileFormat) -> String {
        switch format {
        case .step, .stepAlternate:
            return "application/step"
        case .iges, .igesAlternate:
            return "application/iges"
        case .stl:
            return "model/stl"
        case .obj:
            return "model/obj"
        case .dxf:
            return "application/dxf"
        case .dwg:
            return "application/dwg"
        default:
            return "application/octet-stream"
        }
    }

    // MARK: - Export Recommendations

    /// Recommend export format based on use case
    /// - Parameter useCase: Intended use case
    /// - Returns: Recommended format
    public static func recommendedFormat(for useCase: ExportUseCase) -> CADFileFormat {
        switch useCase {
        case .manufacturing:
            return .step
        case .visualization:
            return .stl
        case .interchange:
            return .step
        case .archival:
            return .step
        case .printing3D:
            return .stl
        case .simulation:
            return .iges
        }
    }

    public enum ExportUseCase {
        case manufacturing
        case visualization
        case interchange
        case archival
        case printing3D
        case simulation
    }

    // MARK: - Batch Validation

    /// Validate multiple files
    /// - Parameter urls: Array of file URLs
    /// - Returns: Dictionary of URL to validation result
    public static func validateFiles(_ urls: [URL]) -> [URL: Bool] {
        var results: [URL: Bool] = [:]
        for url in urls {
            results[url] = validateCADFile(url)
        }
        return results
    }

    /// Filter valid CAD files from array of URLs
    /// - Parameter urls: Array of file URLs
    /// - Returns: Array of valid CAD file URLs
    public static func filterValidCADFiles(_ urls: [URL]) -> [URL] {
        return urls.filter { isSupportedFormat($0) && validateCADFile($0) }
    }
}
