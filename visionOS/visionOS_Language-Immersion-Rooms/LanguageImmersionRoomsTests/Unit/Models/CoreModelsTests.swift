//
//  CoreModelsTests.swift
//  Language Immersion Rooms Tests
//
//  Unit tests for core data models
//

import XCTest
@testable import LanguageImmersionRooms

final class CoreModelsTests: XCTestCase {

    // MARK: - Language Tests

    func testLanguageRawValues() {
        XCTAssertEqual(Language.english.rawValue, "en")
        XCTAssertEqual(Language.spanish.rawValue, "es")
        XCTAssertEqual(Language.french.rawValue, "fr")
        XCTAssertEqual(Language.japanese.rawValue, "ja")
        XCTAssertEqual(Language.german.rawValue, "de")
    }

    func testLanguageDisplayName() {
        XCTAssertEqual(Language.english.displayName, "English")
        XCTAssertEqual(Language.spanish.displayName, "Spanish")
        XCTAssertEqual(Language.french.displayName, "French")
        XCTAssertEqual(Language.japanese.displayName, "Japanese")
        XCTAssertEqual(Language.german.displayName, "German")
    }

    func testLanguageNativeName() {
        XCTAssertEqual(Language.english.nativeName, "English")
        XCTAssertEqual(Language.spanish.nativeName, "Español")
        XCTAssertEqual(Language.french.nativeName, "Français")
        XCTAssertEqual(Language.japanese.nativeName, "日本語")
        XCTAssertEqual(Language.german.nativeName, "Deutsch")
    }

    func testLanguageFlag() {
        XCTAssertEqual(Language.english.flag, "🇺🇸")
        XCTAssertEqual(Language.spanish.flag, "🇪🇸")
        XCTAssertEqual(Language.french.flag, "🇫🇷")
        XCTAssertEqual(Language.japanese.flag, "🇯🇵")
        XCTAssertEqual(Language.german.flag, "🇩🇪")
    }

    func testLanguageCodable() throws {
        let language = Language.spanish
        let encoded = try JSONEncoder().encode(language)
        let decoded = try JSONDecoder().decode(Language.self, from: encoded)
        XCTAssertEqual(decoded, language)
    }

    // MARK: - VocabularyWord Tests

    func testVocabularyWordInitialization() {
        let word = VocabularyWord(
            word: "mesa",
            translation: "table",
            category: .kitchen,
            language: .spanish
        )

        XCTAssertEqual(word.word, "mesa")
        XCTAssertEqual(word.translation, "table")
        XCTAssertEqual(word.category, .kitchen)
        XCTAssertEqual(word.language, .spanish)
        XCTAssertNotNil(word.id)
    }

    func testVocabularyWordCodable() throws {
        let word = VocabularyWord(
            word: "mesa",
            translation: "table",
            category: .kitchen,
            language: .spanish
        )

        let encoded = try JSONEncoder().encode(word)
        let decoded = try JSONDecoder().decode(VocabularyWord.self, from: encoded)

        XCTAssertEqual(decoded.word, word.word)
        XCTAssertEqual(decoded.translation, word.translation)
        XCTAssertEqual(decoded.category, word.category)
        XCTAssertEqual(decoded.language, word.language)
    }

    func testVocabularyCategory() {
        XCTAssertEqual(VocabularyCategory.kitchen.rawValue, "kitchen")
        XCTAssertEqual(VocabularyCategory.livingRoom.rawValue, "living_room")
        XCTAssertEqual(VocabularyCategory.bedroom.rawValue, "bedroom")
        XCTAssertEqual(VocabularyCategory.bathroom.rawValue, "bathroom")
        XCTAssertEqual(VocabularyCategory.office.rawValue, "office")
        XCTAssertEqual(VocabularyCategory.general.rawValue, "general")
    }

    // MARK: - DetectedObject Tests

    func testDetectedObjectInitialization() {
        let object = DetectedObject(
            label: "table",
            confidence: 0.95,
            boundingBox: CGRect(x: 0, y: 0, width: 100, height: 100),
            position: SIMD3<Float>(1.0, 0.5, -2.0)
        )

        XCTAssertEqual(object.label, "table")
        XCTAssertEqual(object.confidence, 0.95, accuracy: 0.001)
        XCTAssertEqual(object.boundingBox.width, 100)
        XCTAssertEqual(object.position?.x, 1.0)
        XCTAssertNotNil(object.id)
    }

    func testDetectedObjectWithoutPosition() {
        let object = DetectedObject(
            label: "chair",
            confidence: 0.85,
            boundingBox: CGRect(x: 0, y: 0, width: 50, height: 50),
            position: nil
        )

        XCTAssertNil(object.position)
        XCTAssertEqual(object.label, "chair")
    }

    // MARK: - ConversationMessage Tests

    func testConversationMessageInitialization() {
        let message = ConversationMessage(
            content: "Hola, ¿cómo estás?",
            isUser: true,
            timestamp: Date()
        )

        XCTAssertEqual(message.content, "Hola, ¿cómo estás?")
        XCTAssertTrue(message.isUser)
        XCTAssertNotNil(message.timestamp)
        XCTAssertNotNil(message.id)
    }

    func testConversationMessageCodable() throws {
        let message = ConversationMessage(
            content: "Test message",
            isUser: false,
            timestamp: Date()
        )

        let encoded = try JSONEncoder().encode(message)
        let decoded = try JSONDecoder().decode(ConversationMessage.self, from: encoded)

        XCTAssertEqual(decoded.content, message.content)
        XCTAssertEqual(decoded.isUser, message.isUser)
    }

    // MARK: - AICharacter Tests

    func testAICharacterMaria() {
        let maria = AICharacter.maria

        XCTAssertEqual(maria.name, "Maria")
        XCTAssertEqual(maria.language, .spanish)
        XCTAssertEqual(maria.personalityTraits.count, 4)
        XCTAssertTrue(maria.personalityTraits.contains("Friendly"))
        XCTAssertTrue(maria.personalityTraits.contains("Patient"))
        XCTAssertNotNil(maria.voiceId)
        XCTAssertNotNil(maria.greeting)
    }

    func testAICharacterJean() {
        let jean = AICharacter.jean

        XCTAssertEqual(jean.name, "Jean")
        XCTAssertEqual(jean.language, .french)
        XCTAssertEqual(jean.personalityTraits.count, 4)
        XCTAssertNotNil(jean.greeting)
    }

    func testAICharacterYuki() {
        let yuki = AICharacter.yuki

        XCTAssertEqual(yuki.name, "Yuki")
        XCTAssertEqual(yuki.language, .japanese)
        XCTAssertNotNil(yuki.greeting)
    }

    func testAICharacterAllCharacters() {
        let allCharacters = AICharacter.allCharacters

        XCTAssertEqual(allCharacters.count, 3)
        XCTAssertTrue(allCharacters.contains { $0.name == "Maria" })
        XCTAssertTrue(allCharacters.contains { $0.name == "Jean" })
        XCTAssertTrue(allCharacters.contains { $0.name == "Yuki" })
    }

    // MARK: - GrammarError Tests

    func testGrammarErrorInitialization() {
        let error = GrammarError(
            type: .verbConjugation,
            incorrectText: "yo es",
            correctText: "yo soy",
            explanation: "Incorrect conjugation of 'ser'",
            range: NSRange(location: 0, length: 5)
        )

        XCTAssertEqual(error.type, .verbConjugation)
        XCTAssertEqual(error.incorrectText, "yo es")
        XCTAssertEqual(error.correctText, "yo soy")
        XCTAssertEqual(error.explanation, "Incorrect conjugation of 'ser'")
        XCTAssertEqual(error.range.location, 0)
        XCTAssertEqual(error.range.length, 5)
        XCTAssertNotNil(error.id)
    }

    func testGrammarErrorType() {
        XCTAssertEqual(GrammarErrorType.verbConjugation.rawValue, "verb_conjugation")
        XCTAssertEqual(GrammarErrorType.articleGender.rawValue, "article_gender")
        XCTAssertEqual(GrammarErrorType.wordOrder.rawValue, "word_order")
        XCTAssertEqual(GrammarErrorType.preposition.rawValue, "preposition")
        XCTAssertEqual(GrammarErrorType.spelling.rawValue, "spelling")
        XCTAssertEqual(GrammarErrorType.other.rawValue, "other")
    }

    // MARK: - UserProfile Tests

    func testUserProfileInitialization() {
        let profile = UserProfile(
            username: "testuser",
            email: "test@example.com",
            targetLanguage: .spanish,
            currentLevel: .beginner
        )

        XCTAssertEqual(profile.username, "testuser")
        XCTAssertEqual(profile.email, "test@example.com")
        XCTAssertEqual(profile.targetLanguage, .spanish)
        XCTAssertEqual(profile.currentLevel, .beginner)
        XCTAssertNotNil(profile.id)
        XCTAssertNotNil(profile.createdDate)
        XCTAssertEqual(profile.currentStreak, 0)
        XCTAssertEqual(profile.longestStreak, 0)
    }

    func testProficiencyLevel() {
        XCTAssertEqual(ProficiencyLevel.beginner.rawValue, "beginner")
        XCTAssertEqual(ProficiencyLevel.intermediate.rawValue, "intermediate")
        XCTAssertEqual(ProficiencyLevel.advanced.rawValue, "advanced")
        XCTAssertEqual(ProficiencyLevel.native.rawValue, "native")
    }

    // MARK: - LearningSession Tests

    func testLearningSessionInitialization() {
        let session = LearningSession(
            startDate: Date(),
            wordsEncountered: 10,
            conversationTime: 120.0
        )

        XCTAssertNotNil(session.id)
        XCTAssertNotNil(session.startDate)
        XCTAssertEqual(session.wordsEncountered, 10)
        XCTAssertEqual(session.conversationTime, 120.0, accuracy: 0.001)
        XCTAssertNil(session.endDate)
    }
}
