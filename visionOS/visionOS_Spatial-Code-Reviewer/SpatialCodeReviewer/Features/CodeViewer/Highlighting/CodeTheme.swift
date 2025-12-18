//
//  CodeTheme.swift
//  SpatialCodeReviewer
//
//  Created by Claude on 2025-11-24.
//  Story 0.6: Syntax Highlighting
//

import SwiftUI

/// Color theme for syntax highlighting
struct CodeTheme {
    let name: String
    let background: Color
    let foreground: Color
    let keyword: Color
    let string: Color
    let comment: Color
    let number: Color
    let function: Color
    let type: Color
    let variable: Color
    let `operator`: Color
    let punctuation: Color

    /// Returns color for a given token type
    func color(for tokenType: TokenType) -> Color {
        switch tokenType {
        case .keyword:
            return keyword
        case .string:
            return string
        case .comment:
            return comment
        case .number:
            return number
        case .function:
            return function
        case .type:
            return type
        case .variable:
            return variable
        case .operator:
            return `operator`
        case .punctuation:
            return punctuation
        case .whitespace:
            return foreground
        case .unknown:
            return foreground
        }
    }

    // MARK: - Current Theme

    static var current: CodeTheme = .visionOSDark

    // MARK: - Built-in Themes

    /// visionOS Dark theme (default)
    static let visionOSDark = CodeTheme(
        name: "visionOS Dark",
        background: Color(red: 0.1, green: 0.1, blue: 0.12),
        foreground: Color(red: 0.95, green: 0.95, blue: 0.97),
        keyword: Color(red: 0.98, green: 0.31, blue: 0.64),      // Hot pink
        string: Color(red: 0.99, green: 0.44, blue: 0.33),      // Coral red
        comment: Color(red: 0.45, green: 0.48, blue: 0.51),     // Gray
        number: Color(red: 0.83, green: 0.69, blue: 0.52),      // Tan
        function: Color(red: 0.64, green: 0.78, blue: 0.35),    // Yellow-green
        type: Color(red: 0.41, green: 0.73, blue: 0.80),        // Sky blue
        variable: Color(red: 0.76, green: 0.83, blue: 0.91),    // Light blue
        operator: Color(red: 0.95, green: 0.95, blue: 0.97),    // White
        punctuation: Color(red: 0.71, green: 0.74, blue: 0.77)  // Light gray
    )

    /// visionOS Light theme
    static let visionOSLight = CodeTheme(
        name: "visionOS Light",
        background: Color(red: 0.98, green: 0.98, blue: 0.99),
        foreground: Color(red: 0.15, green: 0.15, blue: 0.17),
        keyword: Color(red: 0.70, green: 0.10, blue: 0.55),      // Purple
        string: Color(red: 0.78, green: 0.10, blue: 0.09),      // Red
        comment: Color(red: 0.45, green: 0.52, blue: 0.54),     // Gray
        number: Color(red: 0.11, green: 0.33, blue: 0.62),      // Blue
        function: Color(red: 0.32, green: 0.44, blue: 0.02),    // Green
        type: Color(red: 0.11, green: 0.46, blue: 0.61),        // Teal
        variable: Color(red: 0.25, green: 0.37, blue: 0.81),    // Blue
        operator: Color(red: 0.15, green: 0.15, blue: 0.17),    // Black
        punctuation: Color(red: 0.25, green: 0.28, blue: 0.31)  // Dark gray
    )

    /// Xcode Dark theme (familiar to iOS/macOS developers)
    static let xcodeDark = CodeTheme(
        name: "Xcode Dark",
        background: Color(red: 0.16, green: 0.16, blue: 0.17),
        foreground: Color(red: 0.93, green: 0.94, blue: 0.95),
        keyword: Color(red: 0.99, green: 0.26, blue: 0.60),      // Pink
        string: Color(red: 1.00, green: 0.42, blue: 0.33),      // Orange-red
        comment: Color(red: 0.42, green: 0.51, blue: 0.46),     // Green-gray
        number: Color(red: 0.78, green: 0.68, blue: 0.54),      // Tan
        function: Color(red: 0.60, green: 0.76, blue: 0.34),    // Green
        type: Color(red: 0.51, green: 0.71, blue: 0.92),        // Light blue
        variable: Color(red: 0.78, green: 0.83, blue: 0.89),    // Light blue-gray
        operator: Color(red: 0.93, green: 0.94, blue: 0.95),    // White
        punctuation: Color(red: 0.71, green: 0.74, blue: 0.77)  // Light gray
    )

    /// Monokai theme (popular dark theme)
    static let monokai = CodeTheme(
        name: "Monokai",
        background: Color(red: 0.16, green: 0.16, blue: 0.14),
        foreground: Color(red: 0.97, green: 0.96, blue: 0.89),
        keyword: Color(red: 0.98, green: 0.15, blue: 0.45),      // Pink
        string: Color(red: 0.90, green: 0.86, blue: 0.45),      // Yellow
        comment: Color(red: 0.46, green: 0.44, blue: 0.37),     // Brown-gray
        number: Color(red: 0.68, green: 0.51, blue: 1.00),      // Purple
        function: Color(red: 0.65, green: 0.89, blue: 0.18),    // Green
        type: Color(red: 0.40, green: 0.85, blue: 0.94),        // Cyan
        variable: Color(red: 0.97, green: 0.96, blue: 0.89),    // Cream
        operator: Color(red: 0.98, green: 0.15, blue: 0.45),    // Pink
        punctuation: Color(red: 0.97, green: 0.96, blue: 0.89)  // Cream
    )

    /// Solarized Dark theme
    static let solarizedDark = CodeTheme(
        name: "Solarized Dark",
        background: Color(red: 0.00, green: 0.17, blue: 0.21),
        foreground: Color(red: 0.51, green: 0.58, blue: 0.59),
        keyword: Color(red: 0.71, green: 0.54, blue: 0.00),      // Yellow
        string: Color(red: 0.16, green: 0.63, blue: 0.60),      // Cyan
        comment: Color(red: 0.36, green: 0.43, blue: 0.44),     // Gray
        number: Color(red: 0.86, green: 0.20, blue: 0.18),      // Red
        function: Color(red: 0.15, green: 0.55, blue: 0.82),    // Blue
        type: Color(red: 0.71, green: 0.54, blue: 0.00),        // Yellow
        variable: Color(red: 0.51, green: 0.58, blue: 0.59),    // Base0
        operator: Color(red: 0.58, green: 0.63, blue: 0.63),    // Base1
        punctuation: Color(red: 0.58, green: 0.63, blue: 0.63)  // Base1
    )

    /// GitHub Light theme
    static let githubLight = CodeTheme(
        name: "GitHub Light",
        background: Color.white,
        foreground: Color(red: 0.14, green: 0.16, blue: 0.18),
        keyword: Color(red: 0.82, green: 0.11, blue: 0.52),      // Pink
        string: Color(red: 0.03, green: 0.42, blue: 0.75),      // Blue
        comment: Color(red: 0.42, green: 0.47, blue: 0.51),     // Gray
        number: Color(red: 0.00, green: 0.40, blue: 0.74),      // Blue
        function: Color(red: 0.49, green: 0.32, blue: 0.89),    // Purple
        type: Color(red: 0.82, green: 0.36, blue: 0.00),        // Orange
        variable: Color(red: 0.22, green: 0.49, blue: 0.67),    // Blue
        operator: Color(red: 0.14, green: 0.16, blue: 0.18),    // Black
        punctuation: Color(red: 0.14, green: 0.16, blue: 0.18)  // Black
    )

    /// Dracula theme
    static let dracula = CodeTheme(
        name: "Dracula",
        background: Color(red: 0.16, green: 0.17, blue: 0.21),
        foreground: Color(red: 0.95, green: 0.96, blue: 0.98),
        keyword: Color(red: 1.00, green: 0.47, blue: 0.78),      // Pink
        string: Color(red: 0.95, green: 0.98, blue: 0.55),      // Yellow
        comment: Color(red: 0.38, green: 0.47, blue: 0.64),     // Blue-gray
        number: Color(red: 0.74, green: 0.58, blue: 0.98),      // Purple
        function: Color(red: 0.31, green: 0.98, blue: 0.48),    // Green
        type: Color(red: 0.55, green: 0.91, blue: 0.82),        // Cyan
        variable: Color(red: 0.95, green: 0.96, blue: 0.98),    // White
        operator: Color(red: 1.00, green: 0.47, blue: 0.78),    // Pink
        punctuation: Color(red: 0.95, green: 0.96, blue: 0.98)  // White
    )

    // MARK: - Theme Management

    /// All available themes
    static let allThemes: [CodeTheme] = [
        .visionOSDark,
        .visionOSLight,
        .xcodeDark,
        .monokai,
        .solarizedDark,
        .githubLight,
        .dracula
    ]

    /// Sets the current theme
    static func setTheme(_ theme: CodeTheme) {
        current = theme
    }

    /// Sets theme by name
    static func setTheme(name: String) {
        if let theme = allThemes.first(where: { $0.name == name }) {
            current = theme
        }
    }
}

// MARK: - Theme Preview Helper

extension CodeTheme {
    /// Generates a preview of the theme with sample code
    func preview() -> String {
        """
        // \(name) Theme Preview
        import SwiftUI

        class Example {
            var count = 42

            func hello() -> String {
                return "Hello, World!"
            }
        }
        """
    }
}
