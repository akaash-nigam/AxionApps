import Foundation

/// Represents a word/prompt to be drawn in the game
struct Word: Identifiable, Codable, Equatable {
    // MARK: - Properties

    let id: UUID
    var text: String
    var category: Category
    var difficulty: Difficulty
    var language: String
    var metadata: [String: String]

    // MARK: - Enums

    enum Difficulty: String, Codable, CaseIterable {
        case easy = "Easy"       // 1 point base
        case medium = "Medium"   // 2 points base (1.5x multiplier)
        case hard = "Hard"       // 3 points base (2.0x multiplier)

        var pointMultiplier: Float {
            switch self {
            case .easy: return 1.0
            case .medium: return 1.5
            case .hard: return 2.0
            }
        }

        var targetGuessRate: ClosedRange<Float> {
            switch self {
            case .easy: return 0.85...0.95
            case .medium: return 0.60...0.75
            case .hard: return 0.35...0.50
            }
        }
    }

    enum Category: String, Codable, CaseIterable {
        case animals, objects, actions, places, food
        case vehicles, nature, sports, occupations, abstract
        case educational, holiday, movie, custom

        var displayName: String {
            rawValue.capitalized
        }

        var icon: String {
            switch self {
            case .animals: return "🐾"
            case .objects: return "📦"
            case .actions: return "⚡"
            case .places: return "🌍"
            case .food: return "🍽️"
            case .vehicles: return "🚗"
            case .nature: return "🌳"
            case .sports: return "⚽"
            case .occupations: return "💼"
            case .abstract: return "💭"
            case .educational: return "📚"
            case .holiday: return "🎉"
            case .movie: return "🎬"
            case .custom: return "✏️"
            }
        }
    }

    // MARK: - Initialization

    init(
        id: UUID = UUID(),
        text: String,
        category: Category,
        difficulty: Difficulty,
        language: String = "en",
        metadata: [String: String] = [:]
    ) {
        self.id = id
        self.text = text
        self.category = category
        self.difficulty = difficulty
        self.language = language
        self.metadata = metadata
    }
}

// MARK: - Word Extensions

extension Word {
    /// Check if a guess matches this word
    func matches(_ guess: String) -> Bool {
        let normalizedGuess = guess.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        let normalizedWord = text.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)

        // Exact match
        if normalizedGuess == normalizedWord {
            return true
        }

        // Partial match for close guesses (optional feature)
        // Could use Levenshtein distance for fuzzy matching
        return false
    }

    /// Mock word for testing
    static func mock(
        text: String = "cat",
        category: Category = .animals,
        difficulty: Difficulty = .easy
    ) -> Word {
        Word(
            text: text,
            category: category,
            difficulty: difficulty
        )
    }

    /// Sample word database for testing
    static let sampleWords: [Word] = [
        Word(text: "cat", category: .animals, difficulty: .easy),
        Word(text: "dog", category: .animals, difficulty: .easy),
        Word(text: "elephant", category: .animals, difficulty: .medium),
        Word(text: "octopus", category: .animals, difficulty: .medium),
        Word(text: "chameleon", category: .animals, difficulty: .hard),
        Word(text: "car", category: .vehicles, difficulty: .easy),
        Word(text: "airplane", category: .vehicles, difficulty: .medium),
        Word(text: "helicopter", category: .vehicles, difficulty: .hard),
        Word(text: "apple", category: .food, difficulty: .easy),
        Word(text: "pizza", category: .food, difficulty: .easy),
        Word(text: "sushi", category: .food, difficulty: .medium),
    ]
}
