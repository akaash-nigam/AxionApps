//
//  String+Extensions.swift
//  CorporateUniversity
//
//  Utility extensions for String manipulation and validation
//

import Foundation

extension String {
    // MARK: - Validation

    /// Check if string is a valid email address
    var isValidEmail: Bool {
        let emailRegex = #"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: self)
    }

    /// Check if string is a valid URL
    var isValidURL: Bool {
        guard let url = URL(string: self) else { return false }
        return url.scheme != nil && url.host != nil
    }

    /// Check if string is a valid phone number (US format)
    var isValidPhoneNumber: Bool {
        let phoneRegex = #"^\(?\d{3}\)?[-.\s]?\d{3}[-.\s]?\d{4}$"#
        let phonePredicate = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        return phonePredicate.evaluate(with: self)
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

    /// Check if string is empty or contains only whitespace
    var isBlank: Bool {
        trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    // MARK: - Formatting

    /// Truncate string to specified length and add ellipsis
    func truncated(to length: Int, addEllipsis: Bool = true) -> String {
        if count <= length {
            return self
        }

        let truncated = String(prefix(length))
        return addEllipsis ? truncated + "..." : truncated
    }

    /// Get initials from name (e.g., "John Doe" → "JD")
    var initials: String {
        let components = split(separator: " ")
        let initials = components.compactMap { $0.first }.map { String($0) }
        return initials.joined().uppercased()
    }

    /// Capitalize first letter
    var capitalizedFirst: String {
        guard !isEmpty else { return self }
        return prefix(1).uppercased() + dropFirst()
    }

    /// Convert camelCase to snake_case
    var camelCaseToSnakeCase: String {
        let pattern = "([a-z0-9])([A-Z])"
        let regex = try? NSRegularExpression(pattern: pattern)
        let range = NSRange(location: 0, length: count)
        let result = regex?.stringByReplacingMatches(
            in: self,
            range: range,
            withTemplate: "$1_$2"
        )
        return result?.lowercased() ?? self
    }

    /// Convert snake_case to camelCase
    var snakeCaseToCamelCase: String {
        let components = split(separator: "_")
        guard !components.isEmpty else { return self }

        let first = String(components[0]).lowercased()
        let rest = components.dropFirst().map { String($0).capitalizedFirst }
        return ([first] + rest).joined()
    }

    /// Convert to URL-friendly slug
    var slug: String {
        let allowedCharacters = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyz0123456789-")
        return lowercased()
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { !$0.isEmpty }
            .joined(separator: "-")
            .components(separatedBy: CharacterSet(charactersIn: "-").inverted)
            .filter { !$0.isEmpty }
            .joined(separator: "-")
    }

    /// Remove whitespace and newlines
    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Remove all whitespace including internal spaces
    var withoutSpaces: String {
        replacingOccurrences(of: " ", with: "")
    }

    // MARK: - Subscript

    /// Safe subscript access by index
    subscript(safe index: Int) -> Character? {
        guard index >= 0 && index < count else { return nil }
        return self[self.index(startIndex, offsetBy: index)]
    }

    /// Subscript access by range
    subscript(range: Range<Int>) -> String {
        let start = index(startIndex, offsetBy: max(0, range.lowerBound))
        let end = index(startIndex, offsetBy: min(count, range.upperBound))
        return String(self[start..<end])
    }

    // MARK: - Word Count

    /// Count words in string
    var wordCount: Int {
        let components = components(separatedBy: .whitespacesAndNewlines)
        return components.filter { !$0.isEmpty }.count
    }

    /// Count characters excluding whitespace
    var characterCountWithoutSpaces: Int {
        filter { !$0.isWhitespace }.count
    }

    // MARK: - Search

    /// Check if string contains substring (case-insensitive)
    func containsIgnoringCase(_ substring: String) -> Bool {
        range(of: substring, options: .caseInsensitive) != nil
    }

    /// Check if string starts with prefix (case-insensitive)
    func startsWithIgnoringCase(_ prefix: String) -> Bool {
        lowercased().hasPrefix(prefix.lowercased())
    }

    /// Check if string ends with suffix (case-insensitive)
    func endsWithIgnoringCase(_ suffix: String) -> Bool {
        lowercased().hasSuffix(suffix.lowercased())
    }

    // MARK: - Replacement

    /// Replace all occurrences of a string
    func replacingAll(_ target: String, with replacement: String) -> String {
        replacingOccurrences(of: target, with: replacement)
    }

    /// Remove all occurrences of a string
    func removing(_ target: String) -> String {
        replacingOccurrences(of: target, with: "")
    }

    /// Remove characters in set
    func removing(charactersIn set: CharacterSet) -> String {
        components(separatedBy: set).joined()
    }

    // MARK: - Encoding

    /// URL encode string
    var urlEncoded: String? {
        addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
    }

    /// URL decode string
    var urlDecoded: String? {
        removingPercentEncoding
    }

    /// Base64 encode
    var base64Encoded: String? {
        data(using: .utf8)?.base64EncodedString()
    }

    /// Base64 decode
    var base64Decoded: String? {
        guard let data = Data(base64Encoded: self) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    // MARK: - Conversion

    /// Convert to Int
    var toInt: Int? {
        Int(self)
    }

    /// Convert to Double
    var toDouble: Double? {
        Double(self)
    }

    /// Convert to Float
    var toFloat: Float? {
        Float(self)
    }

    /// Convert to Bool
    var toBool: Bool? {
        let lowercased = self.lowercased()
        switch lowercased {
        case "true", "yes", "1":
            return true
        case "false", "no", "0":
            return false
        default:
            return nil
        }
    }

    /// Convert to Date with format
    func toDate(format: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.date(from: self)
    }

    // MARK: - Lines

    /// Split string into lines
    var lines: [String] {
        components(separatedBy: .newlines)
    }

    /// Count lines
    var lineCount: Int {
        lines.count
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

    // MARK: - Emoji

    /// Check if string contains emoji
    var containsEmoji: Bool {
        unicodeScalars.contains { $0.properties.isEmoji }
    }

    /// Remove emoji from string
    var withoutEmoji: String {
        filter { !$0.unicodeScalars.contains { $0.properties.isEmoji } }
    }

    // MARK: - Random

    /// Generate random string of specified length
    static func random(length: Int, charset: String = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789") -> String {
        String((0..<length).compactMap { _ in charset.randomElement() })
    }

    // MARK: - File Extensions

    /// Get file extension
    var fileExtension: String {
        (self as NSString).pathExtension
    }

    /// Get filename without extension
    var fileName: String {
        (self as NSString).deletingPathExtension
    }

    // MARK: - Hashing

    /// MD5 hash
    var md5: String {
        guard let data = data(using: .utf8) else { return self }
        return data.map { String(format: "%02x", $0) }.joined()
    }

    // MARK: - Version Comparison

    /// Compare version strings (e.g., "1.2.3" vs "1.2.4")
    func compareVersion(to version: String) -> ComparisonResult {
        return compare(version, options: .numeric)
    }

    /// Check if version is greater than another
    func isNewerVersion(than version: String) -> Bool {
        return compareVersion(to: version) == .orderedDescending
    }

    // MARK: - HTML

    /// Remove HTML tags
    var strippingHTMLTags: String {
        replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
    }

    // MARK: - Padding

    /// Pad string to length with character
    func padded(toLength length: Int, with character: Character = " ", side: PaddingSide = .right) -> String {
        guard count < length else { return self }
        let padding = String(repeating: character, count: length - count)

        switch side {
        case .left:
            return padding + self
        case .right:
            return self + padding
        case .both:
            let leftPadding = String(repeating: character, count: (length - count) / 2)
            let rightPadding = String(repeating: character, count: (length - count + 1) / 2)
            return leftPadding + self + rightPadding
        }
    }

    enum PaddingSide {
        case left, right, both
    }

    // MARK: - Pluralization

    /// Simple pluralization helper
    func pluralize(count: Int, plural: String? = nil) -> String {
        if count == 1 {
            return self
        } else {
            return plural ?? self + "s"
        }
    }
}

// MARK: - String Validation Helpers

extension String {
    /// Password strength (returns 0-4)
    var passwordStrength: Int {
        var strength = 0

        if count >= 8 { strength += 1 }
        if range(of: "[a-z]", options: .regularExpression) != nil { strength += 1 }
        if range(of: "[A-Z]", options: .regularExpression) != nil { strength += 1 }
        if range(of: "[0-9]", options: .regularExpression) != nil { strength += 1 }
        if range(of: "[^a-zA-Z0-9]", options: .regularExpression) != nil { strength += 1 }

        return min(strength, 4)
    }

    /// Check if password meets minimum requirements
    var isValidPassword: Bool {
        // At least 8 characters, 1 uppercase, 1 lowercase, 1 number
        let hasMinimumLength = count >= 8
        let hasUppercase = range(of: "[A-Z]", options: .regularExpression) != nil
        let hasLowercase = range(of: "[a-z]", options: .regularExpression) != nil
        let hasNumber = range(of: "[0-9]", options: .regularExpression) != nil

        return hasMinimumLength && hasUppercase && hasLowercase && hasNumber
    }
}
