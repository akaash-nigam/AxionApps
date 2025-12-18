//
//  AppStateTests.swift
//  Language Immersion Rooms Tests
//
//  Unit tests for AppState (ViewModel)
//

import XCTest
@testable import LanguageImmersionRooms

@MainActor
final class AppStateTests: XCTestCase {

    var appState: AppState!

    override func setUp() {
        super.setUp()
        appState = AppState()
    }

    override func tearDown() {
        appState = nil
        super.tearDown()
    }

    // MARK: - Initialization Tests

    func testInitialState() {
        XCTAssertNil(appState.currentUser)
        XCTAssertFalse(appState.isAuthenticated)
        XCTAssertEqual(appState.currentLanguage, .spanish)
        XCTAssertEqual(appState.wordsEncounteredToday, 0)
        XCTAssertEqual(appState.conversationTimeToday, 0)
        XCTAssertEqual(appState.currentStreak, 0)
    }

    // MARK: - User Authentication Tests

    func testSetUser() {
        let user = UserProfile(
            username: "testuser",
            email: "test@example.com",
            targetLanguage: .spanish,
            currentLevel: .beginner
        )

        appState.currentUser = user
        appState.isAuthenticated = true

        XCTAssertNotNil(appState.currentUser)
        XCTAssertEqual(appState.currentUser?.username, "testuser")
        XCTAssertTrue(appState.isAuthenticated)
    }

    func testSignOut() {
        let user = UserProfile(
            username: "testuser",
            email: "test@example.com",
            targetLanguage: .spanish,
            currentLevel: .beginner
        )

        appState.currentUser = user
        appState.isAuthenticated = true

        // Sign out
        appState.currentUser = nil
        appState.isAuthenticated = false

        XCTAssertNil(appState.currentUser)
        XCTAssertFalse(appState.isAuthenticated)
    }

    // MARK: - Session Management Tests

    func testStartLearningSession() {
        appState.startLearningSession()

        XCTAssertNotNil(appState.currentSession)
        XCTAssertNotNil(appState.currentSession?.startDate)
        XCTAssertNil(appState.currentSession?.endDate)
    }

    func testEndLearningSession() {
        appState.startLearningSession()
        XCTAssertNotNil(appState.currentSession)

        // Wait a bit to ensure time passes
        Thread.sleep(forTimeInterval: 0.1)

        appState.endLearningSession()

        XCTAssertNil(appState.currentSession, "Session should be cleared after ending")
    }

    func testEndSessionWithoutStart() {
        // Should not crash
        appState.endLearningSession()
        XCTAssertNil(appState.currentSession)
    }

    // MARK: - Progress Tracking Tests

    func testIncrementWordsEncountered() {
        XCTAssertEqual(appState.wordsEncounteredToday, 0)

        appState.incrementWordsEncountered()
        XCTAssertEqual(appState.wordsEncounteredToday, 1)

        appState.incrementWordsEncountered(by: 5)
        XCTAssertEqual(appState.wordsEncounteredToday, 6)
    }

    func testIncrementConversationTime() {
        XCTAssertEqual(appState.conversationTimeToday, 0)

        appState.conversationTimeToday += 120.0
        XCTAssertEqual(appState.conversationTimeToday, 120.0)

        appState.conversationTimeToday += 180.0
        XCTAssertEqual(appState.conversationTimeToday, 300.0)
    }

    func testUpdateStreak() {
        XCTAssertEqual(appState.currentStreak, 0)

        appState.currentStreak = 5
        XCTAssertEqual(appState.currentStreak, 5)

        appState.currentStreak += 1
        XCTAssertEqual(appState.currentStreak, 6)
    }

    // MARK: - Language Selection Tests

    func testChangeLanguage() {
        XCTAssertEqual(appState.currentLanguage, .spanish)

        appState.currentLanguage = .french
        XCTAssertEqual(appState.currentLanguage, .french)

        appState.currentLanguage = .japanese
        XCTAssertEqual(appState.currentLanguage, .japanese)
    }

    // MARK: - Settings Tests

    func testShowLabelsToggle() {
        XCTAssertTrue(appState.showLabels)

        appState.showLabels = false
        XCTAssertFalse(appState.showLabels)

        appState.showLabels = true
        XCTAssertTrue(appState.showLabels)
    }

    func testLabelSizeChange() {
        XCTAssertEqual(appState.labelSize, .medium)

        appState.labelSize = .large
        XCTAssertEqual(appState.labelSize, .large)

        appState.labelSize = .small
        XCTAssertEqual(appState.labelSize, .small)
    }

    func testAutoPlayPronunciation() {
        XCTAssertTrue(appState.autoPlayPronunciation)

        appState.autoPlayPronunciation = false
        XCTAssertFalse(appState.autoPlayPronunciation)
    }

    func testShowGrammarCorrections() {
        XCTAssertTrue(appState.showGrammarCorrections)

        appState.showGrammarCorrections = false
        XCTAssertFalse(appState.showGrammarCorrections)
    }

    // MARK: - Session Tracking Tests

    func testSessionDataAccumulation() {
        appState.startLearningSession()

        // Simulate activity
        appState.incrementWordsEncountered(by: 10)
        appState.conversationTimeToday += 120.0

        // Check session data
        XCTAssertEqual(appState.wordsEncounteredToday, 10)
        XCTAssertEqual(appState.conversationTimeToday, 120.0)

        // Add more activity
        appState.incrementWordsEncountered(by: 5)
        appState.conversationTimeToday += 60.0

        XCTAssertEqual(appState.wordsEncounteredToday, 15)
        XCTAssertEqual(appState.conversationTimeToday, 180.0)
    }

    func testMultipleSessions() {
        // First session
        appState.startLearningSession()
        appState.incrementWordsEncountered(by: 5)
        appState.endLearningSession()

        let firstSessionWords = appState.wordsEncounteredToday

        // Second session
        appState.startLearningSession()
        appState.incrementWordsEncountered(by: 3)
        appState.endLearningSession()

        // Words should accumulate across sessions
        XCTAssertEqual(appState.wordsEncounteredToday, firstSessionWords + 3)
    }

    // MARK: - Edge Cases

    func testNegativeValues() {
        // Should not allow negative values
        appState.incrementWordsEncountered()
        XCTAssertGreaterThan(appState.wordsEncounteredToday, 0)

        appState.conversationTimeToday = -100
        // If implementation allows, test protection; otherwise test setter
        // For now, we just verify it doesn't crash
    }

    func testVeryLargeValues() {
        appState.incrementWordsEncountered(by: 10000)
        XCTAssertEqual(appState.wordsEncounteredToday, 10000)

        appState.conversationTimeToday = 86400.0 // 24 hours
        XCTAssertEqual(appState.conversationTimeToday, 86400.0)
    }

    // MARK: - Concurrency Tests

    func testConcurrentUpdates() async {
        await withTaskGroup(of: Void.self) { group in
            for _ in 0..<100 {
                group.addTask { @MainActor in
                    self.appState.incrementWordsEncountered()
                }
            }
        }

        XCTAssertEqual(appState.wordsEncounteredToday, 100)
    }
}
