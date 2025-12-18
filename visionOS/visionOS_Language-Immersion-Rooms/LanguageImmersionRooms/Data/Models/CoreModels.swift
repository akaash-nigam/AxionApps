//
//  CoreModels.swift
//  Language Immersion Rooms
//
//  Core data models for MVP
//

import Foundation

// MARK: - User Profile

struct UserProfile: Codable, Identifiable {
    let id: UUID
    var username: String
    var email: String
    var createdAt: Date
    var nativeLanguage: Language
    var targetLanguage: Language

    init(id: UUID = UUID(), username: String, email: String, nativeLanguage: Language = .english, targetLanguage: Language = .spanish) {
        self.id = id
        self.username = username
        self.email = email
        self.createdAt = Date()
        self.nativeLanguage = nativeLanguage
        self.targetLanguage = targetLanguage
    }
}

// MARK: - Language

enum Language: String, Codable, CaseIterable {
    case english = "en"
    case spanish = "es"
    case french = "fr"
    case japanese = "ja"
    case german = "de"
    case mandarin = "zh"

    var name: String {
        switch self {
        case .english: return "English"
        case .spanish: return "Spanish"
        case .french: return "French"
        case .japanese: return "Japanese"
        case .german: return "German"
        case .mandarin: return "Mandarin"
        }
    }

    var flag: String {
        switch self {
        case .english: return "🇺🇸"
        case .spanish: return "🇪🇸"
        case .french: return "🇫🇷"
        case .japanese: return "🇯🇵"
        case .german: return "🇩🇪"
        case .mandarin: return "🇨🇳"
        }
    }
}

// MARK: - Vocabulary Word

struct VocabularyWord: Codable, Identifiable {
    let id: UUID
    let word: String
    let translation: String
    let language: Language
    let category: String
    let audioURL: String?

    init(id: UUID = UUID(), word: String, translation: String, language: Language, category: String = "general", audioURL: String? = nil) {
        self.id = id
        self.word = word
        self.translation = translation
        self.language = language
        self.category = category
        self.audioURL = audioURL
    }
}

// MARK: - Detected Object

struct DetectedObject: Identifiable {
    let id: UUID
    let label: String
    let confidence: Float
    let position: SIMD3<Float>?

    init(id: UUID = UUID(), label: String, confidence: Float, position: SIMD3<Float>? = nil) {
        self.id = id
        self.label = label
        self.confidence = confidence
        self.position = position
    }
}

// MARK: - Conversation Message

struct ConversationMessage: Identifiable, Codable {
    let id: UUID
    let sender: MessageSenderType
    let content: String
    let timestamp: Date

    enum MessageSenderType: String, Codable {
        case user
        case ai
        case system
    }
}

// MARK: - Learning Session

struct LearningSession: Identifiable {
    let id: UUID
    let language: Language
    let startTime: Date
    var endTime: Date?
    var wordsEncountered: Int = 0
    var conversationCount: Int = 0

    init(id: UUID = UUID(), language: Language, startTime: Date) {
        self.id = id
        self.language = language
        self.startTime = startTime
    }
}

// MARK: - AI Character

struct AICharacter: Identifiable {
    let id: String
    let name: String
    let language: Language
    let voiceID: String
    let description: String
    let personality: String

    // MVP: Single character - Maria
    static let maria = AICharacter(
        id: "maria_spanish",
        name: "Maria",
        language: .spanish,
        voiceID: "es-ES-Neural2-A",
        description: "Friendly Spanish tutor from Madrid",
        personality: "patient, encouraging, conversational"
    )
}

// MARK: - Grammar Error

struct GrammarError: Identifiable {
    let id: UUID
    let incorrectPhrase: String
    let correctPhrase: String
    let explanation: String
    let errorType: String

    init(id: UUID = UUID(), incorrectPhrase: String, correctPhrase: String, explanation: String, errorType: String = "general") {
        self.id = id
        self.incorrectPhrase = incorrectPhrase
        self.correctPhrase = correctPhrase
        self.explanation = explanation
        self.errorType = errorType
    }
}
