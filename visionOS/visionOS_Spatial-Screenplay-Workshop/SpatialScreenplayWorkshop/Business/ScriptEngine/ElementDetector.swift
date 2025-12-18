//
//  ElementDetector.swift
//  SpatialScreenplayWorkshop
//
//  Created on 2025-11-24
//

import Foundation

/// Detects screenplay element types from text
struct ElementDetector {

    /// Detect element type from a line of text
    static func detectType(from text: String) -> DetectedElementType {
        let trimmed = text.trimmingCharacters(in: .whitespaces)

        // Empty line
        if trimmed.isEmpty {
            return .empty
        }

        // Slug line (scene heading)
        if isSlugLine(trimmed) {
            return .slugLine
        }

        // Transition
        if isTransition(trimmed) {
            return .transition
        }

        // Character name
        if isCharacterName(trimmed) {
            return .character
        }

        // Parenthetical
        if isParenthetical(trimmed) {
            return .parenthetical
        }

        // Default to action
        return .action
    }

    /// Check if text is a slug line
    static func isSlugLine(_ text: String) -> Bool {
        let upper = text.uppercased()

        // Must start with INT, EXT, INT./EXT, or EXT./INT
        let slugPrefixes = ["INT.", "EXT.", "INT./EXT.", "EXT./INT.", "I/E."]

        for prefix in slugPrefixes {
            if upper.hasPrefix(prefix) {
                // Should contain location and time
                // Format: INT. LOCATION - TIME
                if upper.contains(" - ") {
                    return true
                }
                // Also accept just INT. LOCATION (will add TIME later)
                return true
            }
        }

        // Check for forced slug line with dot prefix (Fountain syntax)
        if text.hasPrefix(".") && text.count > 1 {
            return true
        }

        return false
    }

    /// Check if text is a transition
    static func isTransition(_ text: String) -> Bool {
        let upper = text.uppercased()

        // Common transitions
        let transitions = [
            "CUT TO:",
            "FADE TO:",
            "FADE IN:",
            "FADE OUT:",
            "DISSOLVE TO:",
            "SMASH CUT TO:",
            "JUMP CUT TO:",
            "WIPE TO:",
            "MATCH CUT TO:"
        ]

        for transition in transitions {
            if upper == transition || upper.hasSuffix(transition) {
                return true
            }
        }

        // Generic "TO:" pattern (must be all caps and end with TO:)
        if upper == text && upper.hasSuffix(" TO:") {
            return true
        }

        // Forced transition with > prefix (Fountain syntax)
        if text.hasPrefix(">") && text.hasSuffix(":") {
            return true
        }

        return false
    }

    /// Check if text is a character name
    static func isCharacterName(_ text: String) -> Bool {
        let trimmed = text.trimmingCharacters(in: .whitespaces)

        // Must be all uppercase
        guard trimmed == trimmed.uppercased() else {
            return false
        }

        // Should not be empty
        guard !trimmed.isEmpty else {
            return false
        }

        // Should not be a slug line
        if isSlugLine(trimmed) {
            return false
        }

        // Should not be a transition
        if isTransition(trimmed) {
            return false
        }

        // Common patterns:
        // - "CHARACTER NAME"
        // - "CHARACTER NAME (CONT'D)"
        // - "CHARACTER NAME (V.O.)"
        // - "CHARACTER NAME (O.S.)"

        // Remove common suffixes
        let withoutSuffix = trimmed
            .replacingOccurrences(of: " (CONT'D)", with: "")
            .replacingOccurrences(of: " (V.O.)", with: "")
            .replacingOccurrences(of: " (O.S.)", with: "")
            .replacingOccurrences(of: " (O.C.)", with: "")

        // Should be relatively short (character names are typically 2-4 words)
        let words = withoutSuffix.components(separatedBy: .whitespaces)
        if words.count > 5 {
            return false
        }

        // Should not contain certain punctuation
        let invalidChars = [".", "!", "?", ",", ";"]
        for char in invalidChars {
            if trimmed.contains(char) && !trimmed.contains("(") {
                return false
            }
        }

        // Forced character with @ prefix (Fountain syntax)
        if text.hasPrefix("@") {
            return true
        }

        return true
    }

    /// Check if text is a parenthetical
    static func isParenthetical(_ text: String) -> Bool {
        let trimmed = text.trimmingCharacters(in: .whitespaces)

        // Must start with ( and end with )
        return trimmed.hasPrefix("(") && trimmed.hasSuffix(")")
    }

    /// Parse slug line components
    static func parseSlugLine(_ text: String) -> (setting: String, location: String, timeOfDay: String)? {
        var cleanText = text.trimmingCharacters(in: .whitespaces)

        // Remove forced slug line prefix if present
        if cleanText.hasPrefix(".") {
            cleanText = String(cleanText.dropFirst())
        }

        let upper = cleanText.uppercased()

        // Find setting
        var setting = ""
        let settings = ["INT./EXT.", "EXT./INT.", "I/E.", "INT.", "EXT."]
        for s in settings {
            if upper.hasPrefix(s) {
                setting = s.replacingOccurrences(of: ".", with: "")
                cleanText = String(cleanText.dropFirst(s.count)).trimmingCharacters(in: .whitespaces)
                break
            }
        }

        guard !setting.isEmpty else { return nil }

        // Split by " - " to get location and time
        let components = cleanText.components(separatedBy: " - ")

        if components.count >= 2 {
            let location = components[0].trimmingCharacters(in: .whitespaces)
            let timeOfDay = components[1].trimmingCharacters(in: .whitespaces)
            return (setting, location, timeOfDay)
        } else if components.count == 1 {
            // Location only, default time to DAY
            let location = components[0].trimmingCharacters(in: .whitespaces)
            return (setting, location, "DAY")
        }

        return nil
    }

    /// Extract character name (without suffixes like CONT'D, V.O.)
    static func extractCharacterName(_ text: String) -> String {
        var cleaned = text.trimmingCharacters(in: .whitespaces)

        // Remove forced character prefix
        if cleaned.hasPrefix("@") {
            cleaned = String(cleaned.dropFirst())
        }

        // Remove common suffixes
        let suffixes = [" (CONT'D)", " (V.O.)", " (O.S.)", " (O.C.)", " (V.O)", " (O.S)", " (O.C)"]
        for suffix in suffixes {
            cleaned = cleaned.replacingOccurrences(of: suffix, with: "")
        }

        return cleaned.trimmingCharacters(in: .whitespaces)
    }
}

/// Detected element type
enum DetectedElementType {
    case slugLine
    case action
    case character
    case parenthetical
    case dialogue
    case transition
    case empty
}
