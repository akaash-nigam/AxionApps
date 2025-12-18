//
//  ServiceProtocols.swift
//  Language Immersion Rooms
//
//  Protocol definitions for services
//

import Foundation

// MARK: - Conversation Service Protocol

protocol ConversationServiceProtocol {
    func generateGreeting(character: AICharacter) async throws -> String
    func generateResponse(to message: String, history: [ConversationMessage], character: AICharacter) async throws -> String
    func checkGrammar(_ text: String, language: Language) async -> [GrammarError]
}

// MARK: - Speech Service Protocol

protocol SpeechServiceProtocol {
    func startRecognition(language: Language) async throws -> String
    func stopRecognition()
    func speak(_ text: String, voice: String) async
    func playPronunciation(word: String, language: Language) async
}

// MARK: - Vocabulary Service Protocol

protocol VocabularyServiceProtocol {
    func translate(_ word: String, to language: Language) async -> String?
    func getVocabulary(for category: String, language: Language) -> [VocabularyWord]
    func saveWord(_ word: VocabularyWord)
}

// MARK: - Object Detection Service Protocol

protocol ObjectDetectionServiceProtocol {
    func detectObjects() async throws -> [DetectedObject]
}

// MARK: - Service Errors

enum ServiceError: Error, LocalizedError {
    case apiKeyMissing
    case networkError
    case invalidResponse
    case rateLimitExceeded
    case quotaExceeded
    case speechRecognitionFailed
    case translationNotFound

    var errorDescription: String? {
        switch self {
        case .apiKeyMissing:
            return "API key not configured"
        case .networkError:
            return "Network connection error"
        case .invalidResponse:
            return "Invalid response from server"
        case .rateLimitExceeded:
            return "Rate limit exceeded. Please try again later."
        case .quotaExceeded:
            return "Usage quota exceeded"
        case .speechRecognitionFailed:
            return "Speech recognition failed"
        case .translationNotFound:
            return "Translation not found"
        }
    }
}
