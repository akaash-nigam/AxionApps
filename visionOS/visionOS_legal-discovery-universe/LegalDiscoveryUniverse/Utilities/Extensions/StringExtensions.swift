//
//  StringExtensions.swift
//  Legal Discovery Universe
//
//  Created by Claude Code
//  Copyright © 2024 Legal Discovery Universe. All rights reserved.
//

import Foundation
import CryptoKit

extension String {
    /// SHA-256 hash of the string
    var sha256: String {
        let data = Data(self.utf8)
        let hash = SHA256.hash(data: data)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }

    /// Checks if string contains legal privilege markers
    var hasPrivilegeMarkers: Bool {
        let markers = [
            "attorney-client",
            "privileged",
            "work product",
            "confidential",
            "attorney work product"
        ]
        let lowercased = self.lowercased()
        return markers.contains { lowercased.contains($0) }
    }

    /// Extracts email addresses from text
    var extractedEmails: [String] {
        let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        let matches = detector?.matches(
            in: self,
            options: [],
            range: NSRange(location: 0, length: self.utf16.count)
        )

        return matches?.compactMap { match in
            guard let url = match.url,
                  url.scheme == "mailto" else { return nil }
            return url.absoluteString.replacingOccurrences(of: "mailto:", with: "")
        } ?? []
    }

    /// Redacts sensitive information
    func redactSensitiveInfo() -> String {
        var redacted = self

        // Redact SSN patterns (XXX-XX-XXXX)
        let ssnPattern = "\\b\\d{3}-\\d{2}-\\d{4}\\b"
        redacted = redacted.replacingOccurrences(
            of: ssnPattern,
            with: "XXX-XX-XXXX",
            options: .regularExpression
        )

        // Redact credit card patterns
        let ccPattern = "\\b\\d{4}[\\s-]?\\d{4}[\\s-]?\\d{4}[\\s-]?\\d{4}\\b"
        redacted = redacted.replacingOccurrences(
            of: ccPattern,
            with: "XXXX-XXXX-XXXX-XXXX",
            options: .regularExpression
        )

        return redacted
    }

    /// Generates summary of text (first N sentences)
    func summary(sentences: Int = 3) -> String {
        let components = self.components(separatedBy: ". ")
        let summary = components.prefix(sentences).joined(separator: ". ")
        return summary.isEmpty ? self : summary + (components.count > sentences ? "..." : "")
    }

    /// Word count
    var wordCount: Int {
        let words = self.components(separatedBy: .whitespacesAndNewlines)
        return words.filter { !$0.isEmpty }.count
    }

    /// Truncate string to specified length
    func truncate(length: Int, trailing: String = "...") -> String {
        if self.count > length {
            return String(self.prefix(length)) + trailing
        }
        return self
    }

    /// Remove extra whitespace
    var normalizedWhitespace: String {
        self.components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }

    /// Extract Bates numbers (legal document numbering)
    var extractedBatesNumbers: [String] {
        let pattern = "\\b[A-Z]{2,}[-_]?\\d{6,}\\b"
        let regex = try? NSRegularExpression(pattern: pattern)
        let matches = regex?.matches(
            in: self,
            range: NSRange(location: 0, length: self.utf16.count)
        )

        return matches?.compactMap { match in
            if let range = Range(match.range, in: self) {
                return String(self[range])
            }
            return nil
        } ?? []
    }

    /// Check if string appears to be a legal citation
    var isLegalCitation: Bool {
        // Simple check for patterns like "123 F.3d 456" or "567 U.S. 890"
        let pattern = "\\b\\d+\\s+[A-Z][a-z.]+\\s+\\d+\\b"
        let regex = try? NSRegularExpression(pattern: pattern)
        let range = NSRange(location: 0, length: self.utf16.count)
        return regex?.firstMatch(in: self, range: range) != nil
    }
}

extension Data {
    /// SHA-256 hash of data
    func sha256Hash() -> String {
        let hash = SHA256.hash(data: self)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }
}
