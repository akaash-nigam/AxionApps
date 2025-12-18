import Foundation

/// Extensions for UUID to support common operations
public extension UUID {

    // MARK: - Short Identifiers

    /// Get short identifier (first 8 characters)
    var shortID: String {
        return String(uuidString.prefix(8))
    }

    /// Get medium identifier (first 13 characters, includes first hyphen)
    var mediumID: String {
        return String(uuidString.prefix(13))
    }

    /// Get compact representation (no hyphens)
    var compact: String {
        return uuidString.replacingOccurrences(of: "-", with: "")
    }

    // MARK: - Formatting

    /// Get lowercase UUID string
    var lowercased: String {
        return uuidString.lowercased()
    }

    /// Get uppercase UUID string
    var uppercased: String {
        return uuidString.uppercased()
    }

    // MARK: - Display

    /// Get user-friendly display string
    var displayString: String {
        return shortID.uppercased()
    }

    /// Get display string with prefix
    /// - Parameter prefix: Prefix to add
    /// - Returns: Formatted string
    func displayString(withPrefix prefix: String) -> String {
        return "\(prefix)-\(shortID.uppercased())"
    }

    // MARK: - Validation

    /// Check if UUID is nil UUID (all zeros)
    var isNil: Bool {
        return self == UUID(uuidString: "00000000-0000-0000-0000-000000000000")
    }

    // MARK: - Comparison

    /// Compare UUIDs for sorting
    /// - Parameter other: UUID to compare with
    /// - Returns: Comparison result
    func compare(with other: UUID) -> ComparisonResult {
        return uuidString.compare(other.uuidString)
    }

    // MARK: - Creation Helpers

    /// Create UUID from short ID (attempts to match)
    /// - Parameter shortID: Short ID string
    /// - Returns: UUID if valid format
    static func from(shortID: String) -> UUID? {
        // Can't reliably recreate full UUID from short ID
        // This would require lookup in a registry
        return nil
    }

    /// Create UUID from compact string (no hyphens)
    /// - Parameter compact: Compact UUID string
    /// - Returns: UUID if valid
    static func from(compact: String) -> UUID? {
        guard compact.count == 32 else { return nil }

        // Insert hyphens at correct positions
        var formatted = compact
        formatted.insert("-", at: formatted.index(formatted.startIndex, offsetBy: 8))
        formatted.insert("-", at: formatted.index(formatted.startIndex, offsetBy: 13))
        formatted.insert("-", at: formatted.index(formatted.startIndex, offsetBy: 18))
        formatted.insert("-", at: formatted.index(formatted.startIndex, offsetBy: 23))

        return UUID(uuidString: formatted)
    }

    // MARK: - Hash for Testing

    /// Generate deterministic UUID from string (for testing)
    /// - Parameter string: Input string
    /// - Returns: UUID
    /// - Note: Not cryptographically secure, use only for testing
    static func deterministic(from string: String) -> UUID {
        // Simple hash-based generation for testing
        var hash = string.hashValue
        let uuidString = String(format: "%08x-0000-0000-0000-%012x",
                               hash & 0xFFFFFFFF,
                               abs(hash) & 0xFFFFFFFFFFFF)
        return UUID(uuidString: uuidString) ?? UUID()
    }

    // MARK: - Groups

    /// Get UUID group (first section before hyphen)
    var group1: String {
        let components = uuidString.components(separatedBy: "-")
        return components.count > 0 ? components[0] : ""
    }

    /// Get second UUID group
    var group2: String {
        let components = uuidString.components(separatedBy: "-")
        return components.count > 1 ? components[1] : ""
    }

    /// Get third UUID group
    var group3: String {
        let components = uuidString.components(separatedBy: "-")
        return components.count > 2 ? components[2] : ""
    }

    /// Get fourth UUID group
    var group4: String {
        let components = uuidString.components(separatedBy: "-")
        return components.count > 3 ? components[3] : ""
    }

    /// Get fifth UUID group
    var group5: String {
        let components = uuidString.components(separatedBy: "-")
        return components.count > 4 ? components[4] : ""
    }
}

// MARK: - Set Extensions

public extension Set where Element == UUID {

    /// Get short IDs for all UUIDs
    var shortIDs: [String] {
        return map { $0.shortID }
    }

    /// Get display strings for all UUIDs
    var displayStrings: [String] {
        return map { $0.displayString }
    }
}

// MARK: - Array Extensions

public extension Array where Element == UUID {

    /// Get short IDs for all UUIDs
    var shortIDs: [String] {
        return map { $0.shortID }
    }

    /// Get display strings for all UUIDs
    var displayStrings: [String] {
        return map { $0.displayString }
    }

    /// Sort UUIDs
    func sorted() -> [UUID] {
        return sorted { $0.uuidString < $1.uuidString }
    }
}

// MARK: - Optional UUID Extensions

public extension Optional where Wrapped == UUID {

    /// Get short ID or placeholder
    var shortIDOrPlaceholder: String {
        return self?.shortID ?? "--------"
    }

    /// Get display string or placeholder
    var displayStringOrPlaceholder: String {
        return self?.displayString ?? "NO-ID"
    }

    /// Check if nil or nil UUID
    var isNilOrEmpty: Bool {
        return self == nil || self?.isNil == true
    }
}
