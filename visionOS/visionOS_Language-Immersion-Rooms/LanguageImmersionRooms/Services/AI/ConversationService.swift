//
//  ConversationService.swift
//  Language Immersion Rooms
//
//  AI conversation service using OpenAI GPT-4
//

import Foundation

class ConversationService: ConversationServiceProtocol {
    private let apiKey: String
    private let baseURL = "https://api.openai.com/v1"
    private let model = "gpt-4"

    // For MVP, we'll use a simple HTTP client
    private let session: URLSession

    init() {
        // In production, retrieve from Keychain
        // For MVP, you can set this in environment or hardcode for testing
        self.apiKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] ?? ""

        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30.0
        self.session = URLSession(configuration: config)

        print("🤖 ConversationService initialized")
    }

    // MARK: - Generate Greeting

    func generateGreeting(character: AICharacter) async throws -> String {
        let prompt = buildGreetingPrompt(for: character)
        return try await callOpenAI(messages: [
            ChatMessage(role: "system", content: buildSystemPrompt(for: character)),
            ChatMessage(role: "user", content: prompt)
        ])
    }

    // MARK: - Generate Response

    func generateResponse(
        to message: String,
        history: [ConversationMessage],
        character: AICharacter
    ) async throws -> String {
        var messages: [ChatMessage] = []

        // System prompt
        messages.append(ChatMessage(
            role: "system",
            content: buildSystemPrompt(for: character)
        ))

        // Conversation history (last 10 messages for context)
        let recentHistory = Array(history.suffix(10))
        for msg in recentHistory {
            let role = msg.sender == .user ? "user" : "assistant"
            messages.append(ChatMessage(role: role, content: msg.content))
        }

        // Current message
        messages.append(ChatMessage(role: "user", content: message))

        return try await callOpenAI(messages: messages)
    }

    // MARK: - Grammar Checking

    func checkGrammar(_ text: String, language: Language) async -> [GrammarError] {
        // For MVP: Basic grammar checking
        // In production, use more sophisticated NLP

        var errors: [GrammarError] = []

        // Example: Check for common Spanish errors
        if language == .spanish {
            errors = checkSpanishGrammar(text)
        }

        return errors
    }

    private func checkSpanishGrammar(_ text: String) -> [GrammarError] {
        var errors: [GrammarError] = []

        // Simple pattern matching for common errors
        // Example: "Yo va" should be "Yo voy"
        if text.lowercased().contains("yo va ") {
            errors.append(GrammarError(
                incorrectPhrase: "Yo va",
                correctPhrase: "Yo voy",
                explanation: "First person singular of 'ir' (to go) is 'voy', not 'va'",
                errorType: "verb_conjugation"
            ))
        }

        // Example: Missing articles
        if text.contains("mesa") && !text.contains("la mesa") && !text.contains("una mesa") {
            errors.append(GrammarError(
                incorrectPhrase: "mesa",
                correctPhrase: "la mesa",
                explanation: "In Spanish, nouns typically require an article",
                errorType: "article_missing"
            ))
        }

        return errors
    }

    // MARK: - OpenAI API Call

    private func callOpenAI(messages: [ChatMessage]) async throws -> String {
        guard !apiKey.isEmpty else {
            throw ServiceError.apiKeyMissing
        }

        let url = URL(string: "\(baseURL)/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let requestBody = OpenAIRequest(
            model: model,
            messages: messages,
            temperature: 0.7,
            max_tokens: 150
        )

        request.httpBody = try JSONEncoder().encode(requestBody)

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw ServiceError.invalidResponse
        }

        switch httpResponse.statusCode {
        case 200:
            let result = try JSONDecoder().decode(OpenAIResponse.self, from: data)
            guard let content = result.choices.first?.message.content else {
                throw ServiceError.invalidResponse
            }
            return content

        case 429:
            throw ServiceError.rateLimitExceeded

        case 402, 403:
            throw ServiceError.quotaExceeded

        default:
            throw ServiceError.networkError
        }
    }

    // MARK: - Prompt Building

    private func buildSystemPrompt(for character: AICharacter) -> String {
        """
        You are \(character.name), a \(character.description).

        Personality: \(character.personality)

        Guidelines:
        - Speak in \(character.language.name) ONLY
        - Use natural, conversational language
        - Keep responses under 50 words
        - Be encouraging and patient with learners
        - Use simple grammar for beginners
        - If the user makes a grammar mistake, gently correct it in your response
        - Stay in character at all times
        - Be friendly and supportive

        Remember: You're helping someone learn \(character.language.name), so be patient and encouraging!
        """
    }

    private func buildGreetingPrompt(for character: AICharacter) -> String {
        "Please greet the user warmly in \(character.language.name) and introduce yourself. Ask how they're doing today."
    }
}

// MARK: - OpenAI Models

struct ChatMessage: Codable {
    let role: String // "system", "user", "assistant"
    let content: String
}

struct OpenAIRequest: Codable {
    let model: String
    let messages: [ChatMessage]
    let temperature: Double
    let max_tokens: Int
}

struct OpenAIResponse: Codable {
    let choices: [Choice]

    struct Choice: Codable {
        let message: Message

        struct Message: Codable {
            let content: String
        }
    }
}
