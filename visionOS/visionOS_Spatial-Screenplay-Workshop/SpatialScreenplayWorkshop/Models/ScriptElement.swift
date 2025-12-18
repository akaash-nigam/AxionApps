//
//  ScriptElement.swift
//  SpatialScreenplayWorkshop
//
//  Created on 2025-11-24
//

import Foundation

/// Represents different types of screenplay elements
enum ScriptElement: Codable, Hashable, Identifiable {
    case action(ActionElement)
    case dialogue(DialogueElement)
    case transition(TransitionElement)
    case shot(ShotElement)

    var id: UUID {
        switch self {
        case .action(let element):
            return element.id
        case .dialogue(let element):
            return element.id
        case .transition(let element):
            return element.id
        case .shot(let element):
            return element.id
        }
    }

    /// Type name for display
    var typeName: String {
        switch self {
        case .action:
            return "Action"
        case .dialogue:
            return "Dialogue"
        case .transition:
            return "Transition"
        case .shot:
            return "Shot"
        }
    }
}

// MARK: - Action Element

struct ActionElement: Codable, Hashable, Identifiable {
    let id: UUID
    var text: String
    var isCharacterIntro: Bool

    init(id: UUID = UUID(), text: String, isCharacterIntro: Bool = false) {
        self.id = id
        self.text = text
        self.isCharacterIntro = isCharacterIntro
    }

    /// Formatting specifications for action lines
    struct Formatting {
        static let leftMargin: CGFloat = 108  // 1.5"
        static let rightMargin: CGFloat = 72  // 1"
        static let lineHeight: CGFloat = 12   // 12pt
    }
}

// MARK: - Dialogue Element

struct DialogueElement: Codable, Hashable, Identifiable {
    let id: UUID
    var characterId: UUID?
    var characterName: String
    var parenthetical: String?
    var lines: [String]
    var isDualDialogue: Bool

    init(
        id: UUID = UUID(),
        characterId: UUID? = nil,
        characterName: String,
        parenthetical: String? = nil,
        lines: [String],
        isDualDialogue: Bool = false
    ) {
        self.id = id
        self.characterId = characterId
        self.characterName = characterName
        self.parenthetical = parenthetical
        self.lines = lines
        self.isDualDialogue = isDualDialogue
    }

    /// Full dialogue text (all lines joined)
    var fullText: String {
        lines.joined(separator: " ")
    }

    /// Formatting specifications for dialogue
    struct Formatting {
        static let characterIndent: CGFloat = 266      // 3.7" from left
        static let parentheticalIndent: CGFloat = 223  // 3.1" from left
        static let dialogueIndent: CGFloat = 180       // 2.5" from left
        static let dialogueRightMargin: CGFloat = 144  // 2" from right
        static let lineHeight: CGFloat = 12            // 12pt
    }
}

// MARK: - Transition Element

struct TransitionElement: Codable, Hashable, Identifiable {
    let id: UUID
    var type: TransitionType
    var customText: String?

    init(id: UUID = UUID(), type: TransitionType, customText: String? = nil) {
        self.id = id
        self.type = type
        self.customText = customText
    }

    /// Display text for transition
    var displayText: String {
        if type == .custom, let custom = customText {
            return custom
        }
        return type.rawValue
    }

    /// Formatting specifications for transitions
    struct Formatting {
        static let indent: CGFloat = 432  // 6" from left (right-aligned)
        static let lineHeight: CGFloat = 12
    }
}

enum TransitionType: String, Codable, CaseIterable {
    case cutTo = "CUT TO:"
    case fadeTo = "FADE TO:"
    case dissolve = "DISSOLVE TO:"
    case fadeIn = "FADE IN:"
    case fadeOut = "FADE OUT:"
    case smashCut = "SMASH CUT TO:"
    case jumpCut = "JUMP CUT TO:"
    case wipeTo = "WIPE TO:"
    case matchCut = "MATCH CUT TO:"
    case custom = "CUSTOM"
}

// MARK: - Shot Element

struct ShotElement: Codable, Hashable, Identifiable {
    let id: UUID
    var text: String

    init(id: UUID = UUID(), text: String) {
        self.id = id
        self.text = text
    }

    /// Formatting specifications for shots
    struct Formatting {
        static let leftMargin: CGFloat = 108
        static let lineHeight: CGFloat = 12
    }
}

// MARK: - Scene Content

/// Container for all script elements in a scene
struct SceneContent: Codable, Hashable {
    var elements: [ScriptElement]

    init(elements: [ScriptElement] = []) {
        self.elements = elements
    }

    /// Count of each element type
    var elementCounts: ElementCounts {
        var counts = ElementCounts()
        for element in elements {
            switch element {
            case .action:
                counts.action += 1
            case .dialogue:
                counts.dialogue += 1
            case .transition:
                counts.transition += 1
            case .shot:
                counts.shot += 1
            }
        }
        return counts
    }

    /// Total word count in scene
    var wordCount: Int {
        var count = 0
        for element in elements {
            switch element {
            case .action(let action):
                count += action.text.components(separatedBy: .whitespacesAndNewlines).count
            case .dialogue(let dialogue):
                count += dialogue.fullText.components(separatedBy: .whitespacesAndNewlines).count
            case .transition:
                break  // Don't count transitions
            case .shot(let shot):
                count += shot.text.components(separatedBy: .whitespacesAndNewlines).count
            }
        }
        return count
    }

    struct ElementCounts {
        var action: Int = 0
        var dialogue: Int = 0
        var transition: Int = 0
        var shot: Int = 0
    }
}
