//
//  ScriptFormatter.swift
//  SpatialScreenplayWorkshop
//
//  Created on 2025-11-24
//

import Foundation

/// Formats screenplay text according to industry standards
struct ScriptFormatter {

    // MARK: - Formatting Specifications

    /// Industry-standard screenplay margins (in points, 72 pts = 1 inch)
    struct Margins {
        static let pageWidth: CGFloat = 612  // 8.5 inches
        static let pageHeight: CGFloat = 792  // 11 inches

        // Left margins (from left edge)
        static let slugLine: CGFloat = 108     // 1.5"
        static let action: CGFloat = 108       // 1.5"
        static let character: CGFloat = 266    // 3.7"
        static let parenthetical: CGFloat = 223 // 3.1"
        static let dialogue: CGFloat = 180     // 2.5"
        static let transition: CGFloat = 432   // 6.0"

        // Right margins (from left edge)
        static let actionRight: CGFloat = 540   // ~7.5"
        static let dialogueRight: CGFloat = 468 // ~6.5"
    }

    // MARK: - Formatting Methods

    /// Format text for a given element type
    static func format(_ text: String, as type: DetectedElementType) -> FormattedText {
        switch type {
        case .slugLine:
            return formatSlugLine(text)
        case .action:
            return formatAction(text)
        case .character:
            return formatCharacter(text)
        case .parenthetical:
            return formatParenthetical(text)
        case .dialogue:
            return formatDialogue(text)
        case .transition:
            return formatTransition(text)
        case .empty:
            return FormattedText(text: "", leftMargin: 0, rightMargin: 0, isUppercase: false)
        }
    }

    private static func formatSlugLine(_ text: String) -> FormattedText {
        let cleaned = text.trimmingCharacters(in: .whitespaces)
        return FormattedText(
            text: cleaned.uppercased(),
            leftMargin: Margins.slugLine,
            rightMargin: Margins.actionRight,
            isUppercase: true,
            isBold: false
        )
    }

    private static func formatAction(_ text: String) -> FormattedText {
        return FormattedText(
            text: text.trimmingCharacters(in: .whitespaces),
            leftMargin: Margins.action,
            rightMargin: Margins.actionRight,
            isUppercase: false,
            isBold: false
        )
    }

    private static func formatCharacter(_ text: String) -> FormattedText {
        let cleaned = ElementDetector.extractCharacterName(text)
        return FormattedText(
            text: cleaned.uppercased(),
            leftMargin: Margins.character,
            rightMargin: Margins.dialogueRight,
            isUppercase: true,
            isBold: false
        )
    }

    private static func formatParenthetical(_ text: String) -> FormattedText {
        return FormattedText(
            text: text.trimmingCharacters(in: .whitespaces),
            leftMargin: Margins.parenthetical,
            rightMargin: Margins.dialogueRight,
            isUppercase: false,
            isBold: false
        )
    }

    private static func formatDialogue(_ text: String) -> FormattedText {
        return FormattedText(
            text: text.trimmingCharacters(in: .whitespaces),
            leftMargin: Margins.dialogue,
            rightMargin: Margins.dialogueRight,
            isUppercase: false,
            isBold: false
        )
    }

    private static func formatTransition(_ text: String) -> FormattedText {
        let cleaned = text.trimmingCharacters(in: .whitespaces)
        // Remove forced transition prefix if present
        let withoutPrefix = cleaned.hasPrefix(">") ? String(cleaned.dropFirst()) : cleaned
        return FormattedText(
            text: withoutPrefix.uppercased(),
            leftMargin: Margins.transition,
            rightMargin: Margins.pageWidth,
            isUppercase: true,
            isBold: false
        )
    }

    // MARK: - Text Analysis

    /// Analyze script text and return formatted elements
    static func analyzeScript(_ text: String) -> [FormattedElement] {
        let lines = text.components(separatedBy: .newlines)
        var elements: [FormattedElement] = []
        var currentDialogue: DialogueBlock?

        for (index, line) in lines.enumerated() {
            let type = ElementDetector.detectType(from: line)

            // Handle dialogue blocks
            if type == .character {
                // Save previous dialogue block if exists
                if let dialogue = currentDialogue {
                    elements.append(.dialogue(dialogue))
                }
                // Start new dialogue block
                currentDialogue = DialogueBlock(
                    characterName: ElementDetector.extractCharacterName(line),
                    parenthetical: nil,
                    lines: []
                )
                continue
            } else if type == .parenthetical, currentDialogue != nil {
                currentDialogue?.parenthetical = line
                continue
            } else if type == .action || type == .slugLine || type == .transition || type == .empty {
                // End dialogue block
                if let dialogue = currentDialogue {
                    elements.append(.dialogue(dialogue))
                    currentDialogue = nil
                }
            } else if type == .dialogue, currentDialogue != nil {
                currentDialogue?.lines.append(line)
                continue
            }

            // Add non-dialogue elements
            switch type {
            case .slugLine:
                elements.append(.slugLine(line))
            case .action:
                elements.append(.action(line))
            case .transition:
                elements.append(.transition(line))
            case .empty:
                elements.append(.empty)
            default:
                break
            }
        }

        // Add final dialogue block if exists
        if let dialogue = currentDialogue {
            elements.append(.dialogue(dialogue))
        }

        return elements
    }
}

// MARK: - Formatted Text

/// Text with formatting information
struct FormattedText {
    let text: String
    let leftMargin: CGFloat
    let rightMargin: CGFloat
    let isUppercase: Bool
    let isBold: Bool

    init(
        text: String,
        leftMargin: CGFloat,
        rightMargin: CGFloat,
        isUppercase: Bool,
        isBold: Bool = false
    ) {
        self.text = text
        self.leftMargin = leftMargin
        self.rightMargin = rightMargin
        self.isUppercase = isUppercase
        self.isBold = isBold
    }

    /// Width of content area
    var contentWidth: CGFloat {
        rightMargin - leftMargin
    }
}

// MARK: - Formatted Element

/// Formatted screenplay element
enum FormattedElement {
    case slugLine(String)
    case action(String)
    case dialogue(DialogueBlock)
    case transition(String)
    case empty

    var text: String {
        switch self {
        case .slugLine(let text),
             .action(let text),
             .transition(let text):
            return text
        case .dialogue(let block):
            return block.fullText
        case .empty:
            return ""
        }
    }
}

/// Dialogue block with character, parenthetical, and lines
struct DialogueBlock {
    var characterName: String
    var parenthetical: String?
    var lines: [String]

    var fullText: String {
        var text = characterName
        if let paren = parenthetical {
            text += "\n\(paren)"
        }
        text += "\n" + lines.joined(separator: "\n")
        return text
    }
}
