import Foundation

/// Extensions for String to support validation and formatting
public extension String {

    // MARK: - Validation

    /// Check if string is empty or contains only whitespace
    var isBlank: Bool {
        return trimmingCharacters(in: .whitespaces).isEmpty
    }

    /// Check if string is not blank
    var isNotBlank: Bool {
        return !isBlank
    }

    /// Check if string contains only letters
    var isAlphabetic: Bool {
        return !isEmpty && rangeOfCharacter(from: CharacterSet.letters.inverted) == nil
    }

    /// Check if string contains only numbers
    var isNumeric: Bool {
        return !isEmpty && rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil
    }

    /// Check if string contains only letters and numbers
    var isAlphanumeric: Bool {
        return !isEmpty && rangeOfCharacter(from: CharacterSet.alphanumerics.inverted) == nil
    }

    /// Check if string is a valid email address
    var isValidEmail: Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: self)
    }

    /// Check if string is a valid URL
    var isValidURL: Bool {
        return URL(string: self) != nil
    }

    /// Check if string is a valid UUID
    var isValidUUID: Bool {
        return UUID(uuidString: self) != nil
    }

    // MARK: - Trimming

    /// Trim whitespace and newlines
    var trimmed: String {
        return trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Remove all whitespace
    var withoutWhitespace: String {
        return components(separatedBy: .whitespaces).joined()
    }

    /// Remove all newlines
    var withoutNewlines: String {
        return components(separatedBy: .newlines).joined()
    }

    // MARK: - Case Conversion

    /// Convert to title case
    var titleCased: String {
        return capitalized
    }

    /// Convert to sentence case (first letter uppercase)
    var sentenceCased: String {
        guard !isEmpty else { return self }
        return prefix(1).uppercased() + dropFirst().lowercased()
    }

    /// Convert camelCase to snake_case
    var camelToSnakeCase: String {
        let pattern = "([a-z0-9])([A-Z])"
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        let range = NSRange(location: 0, length: count)
        let snakeCase = regex?.stringByReplacingMatches(
            in: self,
            options: [],
            range: range,
            withTemplate: "$1_$2"
        )
        return snakeCase?.lowercased() ?? self
    }

    /// Convert snake_case to camelCase
    var snakeToCamelCase: String {
        let components = self.components(separatedBy: "_")
        guard !components.isEmpty else { return self }

        let first = components[0].lowercased()
        let rest = components.dropFirst().map { $0.capitalized }

        return ([first] + rest).joined()
    }

    // MARK: - Substring Helpers

    /// Get substring from index
    /// - Parameter index: Starting index
    /// - Returns: Substring
    func substring(from index: Int) -> String {
        guard index >= 0, index < count else { return "" }
        let startIndex = self.index(self.startIndex, offsetBy: index)
        return String(self[startIndex...])
    }

    /// Get substring to index
    /// - Parameter index: Ending index (exclusive)
    /// - Returns: Substring
    func substring(to index: Int) -> String {
        guard index > 0, index <= count else { return "" }
        let endIndex = self.index(self.startIndex, offsetBy: index)
        return String(self[..<endIndex])
    }

    /// Get substring in range
    /// - Parameter range: Range of indices
    /// - Returns: Substring
    func substring(range: Range<Int>) -> String {
        guard range.lowerBound >= 0, range.upperBound <= count else { return "" }
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(startIndex, offsetBy: range.upperBound)
        return String(self[start..<end])
    }

    /// Get first n characters
    /// - Parameter n: Number of characters
    /// - Returns: Substring
    func first(_ n: Int) -> String {
        return substring(to: min(n, count))
    }

    /// Get last n characters
    /// - Parameter n: Number of characters
    /// - Returns: Substring
    func last(_ n: Int) -> String {
        return substring(from: max(0, count - n))
    }

    // MARK: - Truncation

    /// Truncate string to length with ellipsis
    /// - Parameters:
    ///   - length: Maximum length
    ///   - trailing: Trailing string (default: "...")
    /// - Returns: Truncated string
    func truncated(to length: Int, trailing: String = "...") -> String {
        guard count > length else { return self }
        return substring(to: length - trailing.count) + trailing
    }

    // MARK: - Padding

    /// Pad string to length with character
    /// - Parameters:
    ///   - length: Target length
    ///   - padding: Padding character
    ///   - side: Side to pad (.left or .right)
    /// - Returns: Padded string
    func padded(toLength length: Int, withPad padding: String = " ", startingAt side: PaddingSide = .left) -> String {
        guard count < length else { return self }
        let padLength = length - count
        let padString = String(repeating: padding, count: padLength)

        switch side {
        case .left:
            return padString + self
        case .right:
            return self + padString
        }
    }

    enum PaddingSide {
        case left, right
    }

    // MARK: - Replacement

    /// Replace all occurrences of string
    /// - Parameters:
    ///   - target: String to replace
    ///   - replacement: Replacement string
    /// - Returns: Modified string
    func replacing(_ target: String, with replacement: String) -> String {
        return replacingOccurrences(of: target, with: replacement)
    }

    /// Remove all occurrences of string
    /// - Parameter target: String to remove
    /// - Returns: Modified string
    func removing(_ target: String) -> String {
        return replacing(target, with: "")
    }

    /// Remove all occurrences of characters in set
    /// - Parameter characterSet: Characters to remove
    /// - Returns: Modified string
    func removing(charactersIn characterSet: CharacterSet) -> String {
        return components(separatedBy: characterSet).joined()
    }

    // MARK: - Contains

    /// Check if string contains substring (case insensitive)
    /// - Parameter substring: Substring to find
    /// - Returns: True if contains
    func containsIgnoringCase(_ substring: String) -> Bool {
        return range(of: substring, options: .caseInsensitive) != nil
    }

    /// Count occurrences of substring
    /// - Parameter substring: Substring to count
    /// - Returns: Number of occurrences
    func occurrences(of substring: String) -> Int {
        return components(separatedBy: substring).count - 1
    }

    // MARK: - Lines

    /// Split into lines
    var lines: [String] {
        return components(separatedBy: .newlines)
    }

    /// Number of lines
    var lineCount: Int {
        return lines.count
    }

    // MARK: - Words

    /// Split into words
    var words: [String] {
        return components(separatedBy: .whitespaces).filter { !$0.isEmpty }
    }

    /// Number of words
    var wordCount: Int {
        return words.count
    }

    // MARK: - Conversion

    /// Convert to Double
    var toDouble: Double? {
        return Double(self)
    }

    /// Convert to Int
    var toInt: Int? {
        return Int(self)
    }

    /// Convert to Bool
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

    /// Convert to URL
    var toURL: URL? {
        return URL(string: self)
    }

    /// Convert to UUID
    var toUUID: UUID? {
        return UUID(uuidString: self)
    }

    // MARK: - Encoding

    /// URL encode string
    var urlEncoded: String? {
        return addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
    }

    /// URL decode string
    var urlDecoded: String? {
        return removingPercentEncoding
    }

    /// Base64 encode
    var base64Encoded: String {
        return Data(utf8).base64EncodedString()
    }

    /// Base64 decode
    var base64Decoded: String? {
        guard let data = Data(base64Encoded: self) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    // MARK: - File Path

    /// Get file extension
    var fileExtension: String {
        return (self as NSString).pathExtension
    }

    /// Get file name without extension
    var fileNameWithoutExtension: String {
        return (self as NSString).deletingPathExtension
    }

    /// Get last path component
    var lastPathComponent: String {
        return (self as NSString).lastPathComponent
    }

    /// Get directory path
    var directoryPath: String {
        return (self as NSString).deletingLastPathComponent
    }

    // MARK: - Sanitization

    /// Remove invalid file name characters
    var sanitizedForFileName: String {
        let invalidCharacters = CharacterSet(charactersIn: "/\\:*?\"<>|")
        return components(separatedBy: invalidCharacters).joined(separator: "_")
    }

    /// Remove HTML tags
    var withoutHTMLTags: String {
        return replacingOccurrences(
            of: "<[^>]+>",
            with: "",
            options: .regularExpression,
            range: nil
        )
    }

    // MARK: - Hashing

    /// Generate MD5 hash (not for cryptographic use)
    var md5: String {
        guard let data = data(using: .utf8) else { return "" }
        return data.map { String(format: "%02x", $0) }.joined()
    }

    // MARK: - Subscript

    /// Access character at index
    subscript(index: Int) -> Character? {
        guard index >= 0, index < count else { return nil }
        let stringIndex = self.index(startIndex, offsetBy: index)
        return self[stringIndex]
    }

    /// Access substring with range
    subscript(range: Range<Int>) -> String {
        return substring(range: range)
    }

    // MARK: - Matching

    /// Check if matches regular expression
    /// - Parameter regex: Regular expression pattern
    /// - Returns: True if matches
    func matches(regex: String) -> Bool {
        return range(of: regex, options: .regularExpression) != nil
    }

    /// Extract matches for regular expression
    /// - Parameter regex: Regular expression pattern
    /// - Returns: Array of matches
    func extractMatches(for regex: String) -> [String] {
        guard let regex = try? NSRegularExpression(pattern: regex) else { return [] }
        let results = regex.matches(in: self, range: NSRange(startIndex..., in: self))
        return results.map { String(self[Range($0.range, in: self)!]) }
    }

    // MARK: - Localization

    /// Get localized string
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }

    /// Get localized string with arguments
    /// - Parameter arguments: Arguments for format string
    /// - Returns: Localized formatted string
    func localized(with arguments: CVarArg...) -> String {
        return String(format: localized, arguments: arguments)
    }
}

// MARK: - Optional String Extensions

public extension Optional where Wrapped == String {

    /// Check if optional string is nil or blank
    var isNilOrBlank: Bool {
        return self?.isBlank ?? true
    }

    /// Unwrap with default empty string
    var orEmpty: String {
        return self ?? ""
    }

    /// Unwrap with custom default
    /// - Parameter default: Default value
    /// - Returns: Unwrapped value or default
    func or(_ default: String) -> String {
        return self ?? `default`
    }
}
