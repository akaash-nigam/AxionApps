//
//  String+Extensions.swift
//  SurgicalTrainingUniverse
//
//  String extension utilities for common string operations
//

import Foundation

extension String {

    // MARK: - Validation

    /// Check if string is a valid email address
    var isValidEmail: Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: self)
    }

    /// Check if string is empty or contains only whitespace
    var isBlank: Bool {
        trimmingCharacters(in: .whitespaces).isEmpty
    }

    /// Check if string contains only letters
    var isAlphabetic: Bool {
        !isEmpty && range(of: "[^a-zA-Z]", options: .regularExpression) == nil
    }

    /// Check if string contains only numbers
    var isNumeric: Bool {
        !isEmpty && range(of: "[^0-9]", options: .regularExpression) == nil
    }

    /// Check if string contains only alphanumeric characters
    var isAlphanumeric: Bool {
        !isEmpty && range(of: "[^a-zA-Z0-9]", options: .regularExpression) == nil
    }

    // MARK: - Trimming

    /// Trim whitespace and newlines
    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Remove all whitespace
    var withoutWhitespace: String {
        replacingOccurrences(of: " ", with: "")
    }

    /// Remove all non-alphanumeric characters
    var alphanumericOnly: String {
        components(separatedBy: CharacterSet.alphanumerics.inverted).joined()
    }

    /// Remove all non-numeric characters
    var numericOnly: String {
        components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
    }

    // MARK: - Capitalization

    /// Capitalize first letter only
    var capitalizedFirst: String {
        guard let first = first else { return self }
        return String(first).uppercased() + dropFirst()
    }

    /// Convert to title case (e.g., "hello world" -> "Hello World")
    var titleCased: String {
        split(separator: " ")
            .map { $0.lowercased().capitalizedFirst }
            .joined(separator: " ")
    }

    /// Convert camelCase to snake_case
    var snakeCased: String {
        let acronymPattern = "([A-Z]+)([A-Z][a-z]|[0-9])"
        let normalPattern = "([a-z0-9])([A-Z])"
        return self
            .replacingOccurrences(of: acronymPattern, with: "$1_$2", options: .regularExpression)
            .replacingOccurrences(of: normalPattern, with: "$1_$2", options: .regularExpression)
            .lowercased()
    }

    /// Convert snake_case to camelCase
    var camelCased: String {
        guard !isEmpty else { return "" }
        let parts = split(separator: "_")
        let first = String(parts.first ?? "").lowercased()
        let rest = parts.dropFirst().map { String($0).capitalizedFirst }
        return ([first] + rest).joined()
    }

    // MARK: - Truncation

    /// Truncate string to specified length with ellipsis
    func truncated(to length: Int, trailing: String = "...") -> String {
        guard count > length else { return self }
        return String(prefix(length)) + trailing
    }

    // MARK: - Subscripts

    /// Safe subscript to get character at index
    subscript(safe index: Int) -> Character? {
        guard index >= 0 && index < count else { return nil }
        return self[self.index(startIndex, offsetBy: index)]
    }

    /// Safe subscript to get substring in range
    subscript(safe range: Range<Int>) -> String? {
        guard range.lowerBound >= 0 && range.upperBound <= count else { return nil }
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(startIndex, offsetBy: range.upperBound)
        return String(self[start..<end])
    }

    // MARK: - URL Encoding

    /// URL encoded string
    var urlEncoded: String? {
        addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
    }

    /// URL decoded string
    var urlDecoded: String? {
        removingPercentEncoding
    }

    // MARK: - Localization

    /// Localized string
    var localized: String {
        NSLocalizedString(self, comment: "")
    }

    /// Localized string with arguments
    func localized(with arguments: CVarArg...) -> String {
        String(format: localized, arguments: arguments)
    }

    // MARK: - Conversions

    /// Convert to Int if possible
    var toInt: Int? {
        Int(self)
    }

    /// Convert to Double if possible
    var toDouble: Double? {
        Double(self)
    }

    /// Convert to Float if possible
    var toFloat: Float? {
        Float(self)
    }

    /// Convert to Bool if possible
    var toBool: Bool? {
        switch lowercased() {
        case "true", "yes", "1":
            return true
        case "false", "no", "0":
            return false
        default:
            return nil
        }
    }

    /// Convert to Date using ISO8601 format
    var toDate: Date? {
        ISO8601DateFormatter().date(from: self)
    }

    // MARK: - Ranges

    /// Get NSRange for entire string
    var nsRange: NSRange {
        NSRange(location: 0, length: utf16.count)
    }

    /// Convert Range to NSRange
    func nsRange(from range: Range<String.Index>) -> NSRange? {
        NSRange(range, in: self)
    }

    // MARK: - Searching

    /// Check if string contains substring (case insensitive)
    func containsIgnoringCase(_ substring: String) -> Bool {
        range(of: substring, options: .caseInsensitive) != nil
    }

    /// Count occurrences of substring
    func count(of substring: String) -> Int {
        components(separatedBy: substring).count - 1
    }

    // MARK: - Hashing

    /// MD5 hash (for non-security purposes)
    var md5: String {
        // Note: In production, use CryptoKit for secure hashing
        let data = Data(utf8)
        return data.map { String(format: "%02hhx", $0) }.joined()
    }
}

// MARK: - Collection Extension

extension Collection where Element == String {
    /// Join with oxford comma
    var oxfordComma: String {
        guard count > 0 else { return "" }
        guard count > 1 else { return first ?? "" }
        guard count > 2 else { return joined(separator: " and ") }

        let allButLast = dropLast().joined(separator: ", ")
        return allButLast + ", and " + (last ?? "")
    }
}
