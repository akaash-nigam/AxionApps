//
//  SyntaxHighlighter.swift
//  SpatialCodeReviewer
//
//  Created by Claude on 2025-11-24.
//  Story 0.6: Syntax Highlighting
//

import Foundation
import SwiftUI

/// Token types for syntax highlighting
enum TokenType {
    case keyword
    case string
    case comment
    case number
    case function
    case type
    case variable
    case `operator`
    case punctuation
    case whitespace
    case unknown
}

/// Represents a highlighted token in code
struct SyntaxToken {
    let type: TokenType
    let text: String
    let range: Range<String.Index>

    var color: Color {
        CodeTheme.current.color(for: type)
    }
}

/// Main syntax highlighting engine
@MainActor
class SyntaxHighlighter {

    // MARK: - Public Interface

    /// Highlights code and returns an array of tokens
    static func highlight(code: String, language: String) -> [SyntaxToken] {
        let highlighter = languageHighlighter(for: language)
        return highlighter.tokenize(code)
    }

    /// Returns attributed string with syntax highlighting (for 2D preview)
    static func attributedString(code: String, language: String, fontSize: CGFloat = 14) -> AttributedString {
        let tokens = highlight(code: code, language: language)
        var attributedString = AttributedString()

        for token in tokens {
            var substring = AttributedString(token.text)
            substring.foregroundColor = token.color
            substring.font = .system(size: fontSize, design: .monospaced)
            attributedString.append(substring)
        }

        return attributedString
    }

    // MARK: - Language-Specific Highlighters

    private static func languageHighlighter(for language: String) -> LanguageHighlighter {
        switch language.lowercased() {
        case "swift":
            return SwiftHighlighter()
        case "javascript", "typescript", "jsx", "tsx":
            return JavaScriptHighlighter()
        case "python":
            return PythonHighlighter()
        case "java":
            return JavaHighlighter()
        case "cpp", "c":
            return CppHighlighter()
        case "rust":
            return RustHighlighter()
        case "go":
            return GoHighlighter()
        case "json":
            return JSONHighlighter()
        case "html", "xml":
            return HTMLHighlighter()
        case "css":
            return CSSHighlighter()
        case "markdown", "md":
            return MarkdownHighlighter()
        default:
            return PlainTextHighlighter()
        }
    }
}

// MARK: - Language Highlighter Protocol

protocol LanguageHighlighter {
    func tokenize(_ code: String) -> [SyntaxToken]
}

// MARK: - Swift Highlighter

class SwiftHighlighter: LanguageHighlighter {
    private let keywords = [
        "class", "struct", "enum", "protocol", "extension", "func", "var", "let",
        "if", "else", "guard", "switch", "case", "default", "for", "while", "repeat",
        "return", "break", "continue", "throw", "throws", "try", "catch", "defer",
        "import", "public", "private", "internal", "fileprivate", "static", "final",
        "override", "mutating", "nonmutating", "convenience", "required", "lazy",
        "weak", "unowned", "in", "inout", "associatedtype", "typealias", "where",
        "self", "Self", "super", "nil", "true", "false", "as", "is", "async", "await"
    ]

    private let types = [
        "Int", "UInt", "Float", "Double", "Bool", "String", "Character", "Array",
        "Dictionary", "Set", "Optional", "Result", "Error", "Any", "AnyObject",
        "Void", "Never"
    ]

    func tokenize(_ code: String) -> [SyntaxToken] {
        var tokens: [SyntaxToken] = []
        let lines = code.components(separatedBy: .newlines)
        var currentIndex = code.startIndex

        for line in lines {
            let lineTokens = tokenizeLine(line, startIndex: currentIndex)
            tokens.append(contentsOf: lineTokens)

            // Add newline
            if currentIndex < code.endIndex {
                let newlineStart = code.index(currentIndex, offsetBy: line.count)
                let newlineEnd = code.index(after: newlineStart)
                if newlineEnd <= code.endIndex {
                    tokens.append(SyntaxToken(
                        type: .whitespace,
                        text: "\n",
                        range: newlineStart..<newlineEnd
                    ))
                    currentIndex = newlineEnd
                }
            }
        }

        return tokens
    }

    private func tokenizeLine(_ line: String, startIndex: String.Index) -> [SyntaxToken] {
        var tokens: [SyntaxToken] = []
        var current = line.startIndex

        // Check for comments first
        if let commentRange = line.range(of: "//") {
            // Process before comment
            if commentRange.lowerBound > line.startIndex {
                let beforeComment = String(line[..<commentRange.lowerBound])
                tokens.append(contentsOf: tokenizeCode(beforeComment, startIndex: startIndex))
            }

            // Add comment
            let commentText = String(line[commentRange.lowerBound...])
            let commentStart = line.distance(from: line.startIndex, to: commentRange.lowerBound)
            tokens.append(SyntaxToken(
                type: .comment,
                text: commentText,
                range: commentRange.lowerBound..<line.endIndex
            ))

            return tokens
        }

        // No comments, tokenize normally
        return tokenizeCode(line, startIndex: startIndex)
    }

    private func tokenizeCode(_ text: String, startIndex: String.Index) -> [SyntaxToken] {
        var tokens: [SyntaxToken] = []
        var current = text.startIndex

        while current < text.endIndex {
            let char = text[current]

            // Whitespace
            if char.isWhitespace {
                let start = current
                while current < text.endIndex && text[current].isWhitespace {
                    current = text.index(after: current)
                }
                tokens.append(SyntaxToken(
                    type: .whitespace,
                    text: String(text[start..<current]),
                    range: start..<current
                ))
                continue
            }

            // String literals
            if char == "\"" {
                let start = current
                current = text.index(after: current)
                while current < text.endIndex {
                    if text[current] == "\"" && text[text.index(before: current)] != "\\" {
                        current = text.index(after: current)
                        break
                    }
                    current = text.index(after: current)
                }
                tokens.append(SyntaxToken(
                    type: .string,
                    text: String(text[start..<current]),
                    range: start..<current
                ))
                continue
            }

            // Numbers
            if char.isNumber {
                let start = current
                while current < text.endIndex && (text[current].isNumber || text[current] == ".") {
                    current = text.index(after: current)
                }
                tokens.append(SyntaxToken(
                    type: .number,
                    text: String(text[start..<current]),
                    range: start..<current
                ))
                continue
            }

            // Identifiers and keywords
            if char.isLetter || char == "_" {
                let start = current
                while current < text.endIndex && (text[current].isLetter || text[current].isNumber || text[current] == "_") {
                    current = text.index(after: current)
                }

                let word = String(text[start..<current])
                let type: TokenType
                if keywords.contains(word) {
                    type = .keyword
                } else if types.contains(word) {
                    type = .type
                } else if word.first?.isUppercase == true {
                    type = .type
                } else {
                    type = .variable
                }

                tokens.append(SyntaxToken(
                    type: type,
                    text: word,
                    range: start..<current
                ))
                continue
            }

            // Operators and punctuation
            let operators = ["=", "+", "-", "*", "/", "%", "!", "&", "|", "^", "~", "<", ">", "?", ":"]
            let punctuation = ["(", ")", "{", "}", "[", "]", ",", ";", "."]

            let charStr = String(char)
            if operators.contains(charStr) {
                tokens.append(SyntaxToken(
                    type: .operator,
                    text: charStr,
                    range: current..<text.index(after: current)
                ))
            } else if punctuation.contains(charStr) {
                tokens.append(SyntaxToken(
                    type: .punctuation,
                    text: charStr,
                    range: current..<text.index(after: current)
                ))
            } else {
                tokens.append(SyntaxToken(
                    type: .unknown,
                    text: charStr,
                    range: current..<text.index(after: current)
                ))
            }

            current = text.index(after: current)
        }

        return tokens
    }
}

// MARK: - JavaScript/TypeScript Highlighter

class JavaScriptHighlighter: LanguageHighlighter {
    private let keywords = [
        "async", "await", "break", "case", "catch", "class", "const", "continue",
        "debugger", "default", "delete", "do", "else", "export", "extends", "finally",
        "for", "function", "if", "import", "in", "instanceof", "let", "new", "return",
        "super", "switch", "this", "throw", "try", "typeof", "var", "void", "while",
        "with", "yield", "true", "false", "null", "undefined"
    ]

    func tokenize(_ code: String) -> [SyntaxToken] {
        // Similar implementation to Swift highlighter
        // For brevity, using simplified version
        return SwiftHighlighter().tokenize(code) // Placeholder
    }
}

// MARK: - Python Highlighter

class PythonHighlighter: LanguageHighlighter {
    private let keywords = [
        "and", "as", "assert", "async", "await", "break", "class", "continue", "def",
        "del", "elif", "else", "except", "False", "finally", "for", "from", "global",
        "if", "import", "in", "is", "lambda", "None", "nonlocal", "not", "or", "pass",
        "raise", "return", "True", "try", "while", "with", "yield"
    ]

    func tokenize(_ code: String) -> [SyntaxToken] {
        // Simplified - using Swift highlighter as base
        return SwiftHighlighter().tokenize(code)
    }
}

// MARK: - Other Language Highlighters (Simplified)

class JavaHighlighter: LanguageHighlighter {
    func tokenize(_ code: String) -> [SyntaxToken] {
        return SwiftHighlighter().tokenize(code)
    }
}

class CppHighlighter: LanguageHighlighter {
    func tokenize(_ code: String) -> [SyntaxToken] {
        return SwiftHighlighter().tokenize(code)
    }
}

class RustHighlighter: LanguageHighlighter {
    func tokenize(_ code: String) -> [SyntaxToken] {
        return SwiftHighlighter().tokenize(code)
    }
}

class GoHighlighter: LanguageHighlighter {
    func tokenize(_ code: String) -> [SyntaxToken] {
        return SwiftHighlighter().tokenize(code)
    }
}

class JSONHighlighter: LanguageHighlighter {
    func tokenize(_ code: String) -> [SyntaxToken] {
        var tokens: [SyntaxToken] = []
        var current = code.startIndex

        while current < code.endIndex {
            let char = code[current]

            if char == "\"" {
                let start = current
                current = code.index(after: current)
                while current < code.endIndex && code[current] != "\"" {
                    current = code.index(after: current)
                }
                if current < code.endIndex {
                    current = code.index(after: current)
                }
                tokens.append(SyntaxToken(
                    type: .string,
                    text: String(code[start..<current]),
                    range: start..<current
                ))
            } else if char.isNumber || char == "-" {
                let start = current
                while current < code.endIndex && (code[current].isNumber || code[current] == "." || code[current] == "-") {
                    current = code.index(after: current)
                }
                tokens.append(SyntaxToken(
                    type: .number,
                    text: String(code[start..<current]),
                    range: start..<current
                ))
            } else {
                tokens.append(SyntaxToken(
                    type: .punctuation,
                    text: String(char),
                    range: current..<code.index(after: current)
                ))
                current = code.index(after: current)
            }
        }

        return tokens
    }
}

class HTMLHighlighter: LanguageHighlighter {
    func tokenize(_ code: String) -> [SyntaxToken] {
        return SwiftHighlighter().tokenize(code) // Simplified
    }
}

class CSSHighlighter: LanguageHighlighter {
    func tokenize(_ code: String) -> [SyntaxToken] {
        return SwiftHighlighter().tokenize(code) // Simplified
    }
}

class MarkdownHighlighter: LanguageHighlighter {
    func tokenize(_ code: String) -> [SyntaxToken] {
        return SwiftHighlighter().tokenize(code) // Simplified
    }
}

class PlainTextHighlighter: LanguageHighlighter {
    func tokenize(_ code: String) -> [SyntaxToken] {
        return [SyntaxToken(
            type: .unknown,
            text: code,
            range: code.startIndex..<code.endIndex
        )]
    }
}
