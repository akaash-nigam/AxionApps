//
//  ServiceIntegrationTests.swift
//  Language Immersion Rooms Tests
//
//  Integration tests for service layer interactions
//
//  ⚠️  REQUIRES: OpenAI API key and network connection
//  These tests interact with real external services
//

import XCTest
@testable import LanguageImmersionRooms

final class ServiceIntegrationTests: XCTestCase {

    var vocabularyService: VocabularyService!
    var objectDetectionService: ObjectDetectionService!
    var conversationService: ConversationService!

    override func setUp() {
        super.setUp()
        vocabularyService = VocabularyService()
        objectDetectionService = ObjectDetectionService()

        // Check if API key is available
        guard let apiKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"],
              !apiKey.isEmpty else {
            print("⚠️  Skipping conversation service tests - no API key")
            return
        }

        conversationService = ConversationService(apiKey: apiKey)
    }

    override func tearDown() {
        vocabularyService = nil
        objectDetectionService = nil
        conversationService = nil
        super.tearDown()
    }

    // MARK: - Object Detection + Vocabulary Integration

    func testDetectAndTranslateObjects() async throws {
        // Detect objects
        let objects = try await objectDetectionService.detectObjects()
        XCTAssertFalse(objects.isEmpty)

        // Translate detected objects to Spanish
        var translatedCount = 0
        for object in objects {
            if let translation = vocabularyService.translate(object.label, to: .spanish) {
                translatedCount += 1
                print("✅ \(object.label) → \(translation)")
            }
        }

        // Should be able to translate at least some objects
        XCTAssertGreaterThan(translatedCount, 0,
                           "Should be able to translate at least some detected objects")
    }

    func testDetectObjectsAndCreateVocabularyWords() async throws {
        // Detect objects
        let objects = try await objectDetectionService.detectObjects()

        // Convert to vocabulary words
        let vocabularyWords = objects.compactMap { object in
            vocabularyService.getWord(for: object.label, language: .spanish)
        }

        XCTAssertFalse(vocabularyWords.isEmpty)
        print("📚 Created \(vocabularyWords.count) vocabulary words from detected objects")

        // Verify all words have required properties
        for word in vocabularyWords {
            XCTAssertFalse(word.word.isEmpty)
            XCTAssertFalse(word.translation.isEmpty)
            XCTAssertNotNil(word.category)
        }
    }

    // MARK: - Conversation Service Integration (Requires API Key)

    func testConversationWithVocabulary() async throws {
        guard conversationService != nil else {
            throw XCTSkip("Skipping - No OpenAI API key available")
        }

        // Get some vocabulary words
        let word = vocabularyService.getWord(for: "table", language: .spanish)!

        // Generate conversation about the word
        let message = "¿Cómo se dice '\(word.translation)' en inglés?"
        let response = try await conversationService.generateResponse(
            to: message,
            history: [],
            character: .maria
        )

        XCTAssertFalse(response.isEmpty)
        print("🤖 AI Response: \(response)")

        // Response should mention the word or its translation
        XCTAssertTrue(
            response.lowercased().contains(word.word.lowercased()) ||
            response.lowercased().contains(word.translation.lowercased()),
            "Response should reference the word"
        )
    }

    func testConversationGreeting() async throws {
        guard conversationService != nil else {
            throw XCTSkip("Skipping - No OpenAI API key available")
        }

        let greeting = try await conversationService.generateGreeting(for: .maria)

        XCTAssertFalse(greeting.isEmpty)
        print("👋 Greeting: \(greeting)")

        // Should be in Spanish
        XCTAssertTrue(
            greeting.lowercased().contains("hola") ||
            greeting.lowercased().contains("buenos"),
            "Greeting should be in Spanish"
        )
    }

    func testConversationGrammarCheck() async throws {
        guard conversationService != nil else {
            throw XCTSkip("Skipping - No OpenAI API key available")
        }

        // Test with incorrect Spanish
        let incorrectText = "yo es estudiante"
        let errors = await conversationService.checkGrammar(incorrectText, language: .spanish)

        XCTAssertFalse(errors.isEmpty, "Should detect grammar error in 'yo es'")
        print("📝 Found \(errors.count) grammar errors")

        if let error = errors.first {
            print("   Error: \(error.incorrectText) → \(error.correctText)")
            XCTAssertEqual(error.type, .verbConjugation)
        }
    }

    // MARK: - Full Pipeline Integration

    func testFullLearningPipeline() async throws {
        // Step 1: Detect objects
        let objects = try await objectDetectionService.detectObjects()
        XCTAssertFalse(objects.isEmpty)
        print("🔍 Step 1: Detected \(objects.count) objects")

        // Step 2: Translate to Spanish
        let translations = objects.compactMap { object -> (String, String)? in
            guard let spanish = vocabularyService.translate(object.label, to: .spanish) else {
                return nil
            }
            return (object.label, spanish)
        }
        XCTAssertFalse(translations.isEmpty)
        print("🌐 Step 2: Translated \(translations.count) objects")

        // Step 3: Create vocabulary words
        let vocabularyWords = translations.compactMap { (english, spanish) in
            vocabularyService.getWord(for: english, language: .spanish)
        }
        XCTAssertFalse(vocabularyWords.isEmpty)
        print("📚 Step 3: Created \(vocabularyWords.count) vocabulary entries")

        // Step 4: Verify conversation service can use these words
        guard conversationService != nil else {
            print("⏭️  Step 4: Skipped conversation (no API key)")
            return
        }

        if let firstWord = vocabularyWords.first {
            let message = "¿Qué es una \(firstWord.word)?"
            let response = try await conversationService.generateResponse(
                to: message,
                history: [],
                character: .maria
            )
            XCTAssertFalse(response.isEmpty)
            print("🤖 Step 4: AI responded to vocabulary question")
        }

        print("✅ Full pipeline completed successfully!")
    }

    // MARK: - Performance Integration Tests

    func testConcurrentDetectionAndTranslation() async throws {
        let iterations = 5

        await withTaskGroup(of: (Int, [DetectedObject]).self) { group in
            for i in 0..<iterations {
                group.addTask {
                    let objects = try! await self.objectDetectionService.detectObjects()
                    return (i, objects)
                }
            }

            for await (index, objects) in group {
                XCTAssertFalse(objects.isEmpty)
                print("🔄 Concurrent detection \(index + 1) completed: \(objects.count) objects")
            }
        }
    }

    func testServiceMemoryUsage() async throws {
        // Detect memory before
        let memoryBefore = getMemoryUsage()

        // Perform multiple operations
        for _ in 0..<10 {
            let objects = try await objectDetectionService.detectObjects()
            _ = objects.compactMap { object in
                vocabularyService.translate(object.label, to: .spanish)
            }
        }

        // Detect memory after
        let memoryAfter = getMemoryUsage()

        print("💾 Memory usage: \(memoryBefore)MB → \(memoryAfter)MB")

        // Memory should not increase dramatically
        XCTAssertLessThan(memoryAfter - memoryBefore, 100,
                         "Memory increase should be less than 100MB")
    }

    // MARK: - Helper Methods

    private func getMemoryUsage() -> Double {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4

        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_,
                         task_flavor_t(MACH_TASK_BASIC_INFO),
                         $0,
                         &count)
            }
        }

        if kerr == KERN_SUCCESS {
            return Double(info.resident_size) / 1024.0 / 1024.0
        }

        return 0
    }
}
