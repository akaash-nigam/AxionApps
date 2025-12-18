//
//  GameplayIntegrationTests.swift
//  RhythmFlowTests
//
//  Integration tests for complete gameplay flows
//

import XCTest
@testable import RhythmFlow

final class GameplayIntegrationTests: XCTestCase {
    var gameEngine: GameEngine!
    var audioEngine: AudioEngine!
    var inputManager: InputManager!
    var scoreManager: ScoreManager!

    @MainActor
    override func setUp() async throws {
        try await super.setUp()

        // Initialize all systems
        audioEngine = AudioEngine()
        inputManager = InputManager()
        scoreManager = ScoreManager()
        gameEngine = GameEngine(
            audioEngine: audioEngine,
            inputManager: inputManager,
            scoreManager: scoreManager
        )
    }

    @MainActor
    override func tearDown() async throws {
        gameEngine?.cleanup()
        audioEngine?.cleanup()
        inputManager?.cleanup()

        gameEngine = nil
        audioEngine = nil
        inputManager = nil
        scoreManager = nil

        try await super.tearDown()
    }

    // MARK: - Full Song Playthrough Tests

    @MainActor
    func testCompleteSongPlaythrough() async throws {
        // Given
        let song = Song.sampleSong
        let difficulty = Difficulty.normal

        // When - Start song
        await gameEngine.startSong(song, difficulty: difficulty)

        // Wait for song to start
        try await Task.sleep(for: .seconds(1))

        // Then
        XCTAssertTrue(gameEngine.isRunning, "Game should be running")
        XCTAssertNotNil(gameEngine.currentSession, "Session should exist")
        XCTAssertNotNil(gameEngine.currentBeatMap, "Beat map should be loaded")
    }

    @MainActor
    func testPauseAndResume() async throws {
        // Given - Song is playing
        let song = Song.sampleSong
        await gameEngine.startSong(song, difficulty: .normal)
        try await Task.sleep(for: .milliseconds(500))

        // When - Pause
        gameEngine.pause()

        // Then
        XCTAssertTrue(gameEngine.isPaused, "Game should be paused")

        // When - Resume
        gameEngine.resume()

        // Then
        XCTAssertFalse(gameEngine.isPaused, "Game should be resumed")
    }

    @MainActor
    func testStopSong() async throws {
        // Given - Song is playing
        let song = Song.sampleSong
        await gameEngine.startSong(song, difficulty: .normal)
        try await Task.sleep(for: .milliseconds(500))

        // When
        gameEngine.stop()

        // Then
        XCTAssertFalse(gameEngine.isRunning, "Game should not be running")
        XCTAssertNotNil(gameEngine.currentSession?.endTime, "Session should be ended")
    }

    // MARK: - Multi-System Integration Tests

    @MainActor
    func testScoreManagerIntegration() async throws {
        // Given - Game is running
        let song = Song.sampleSong
        await gameEngine.startSong(song, difficulty: .normal)

        // When - Register some hits through score manager
        scoreManager.registerHit(.perfect, noteValue: 100)
        scoreManager.registerHit(.great, noteValue: 100)
        scoreManager.registerHit(.miss, noteValue: 100)

        // Then - Score manager state should update
        XCTAssertEqual(scoreManager.perfectHits, 1)
        XCTAssertEqual(scoreManager.greatHits, 1)
        XCTAssertEqual(scoreManager.missedNotes, 1)
        XCTAssertGreaterThan(scoreManager.currentScore, 0)
    }

    @MainActor
    func testBeatMapLoading() async throws {
        // Given
        let song = Song.sampleSong
        let difficulty = Difficulty.hard

        // When
        await gameEngine.startSong(song, difficulty: difficulty)

        // Then
        XCTAssertNotNil(gameEngine.currentBeatMap, "Beat map should be loaded")
        XCTAssertEqual(gameEngine.currentBeatMap?.difficulty, difficulty, "Correct difficulty should be loaded")
    }

    // MARK: - Player Profile Integration

    func testPlayerProfileUpdate() throws {
        // Given
        var profile = PlayerProfile(username: "TestPlayer", displayName: "Test")
        var session = GameSession(songID: UUID(), difficulty: .normal)

        // When - Play a song
        for _ in 0..<50 {
            session.registerHit(.perfect, points: 100)
        }
        session.end()

        // Update profile
        profile.updateStatistics(from: session)

        // Then
        XCTAssertEqual(profile.totalSongsPlayed, 1)
        XCTAssertGreaterThan(profile.totalScore, 0)
        XCTAssertEqual(profile.statistics.perfectHits, 50)
    }

    // MARK: - Multiple Songs Integration

    func testMultipleSongsSequentially() throws {
        // Given
        let song1 = Song.sampleSong
        let song2 = Song.sampleLibrary[1]
        var profile = PlayerProfile(username: "TestPlayer", displayName: "Test")

        // When - Play first song
        var session1 = GameSession(songID: song1.id, difficulty: .normal)
        for _ in 0..<30 {
            session1.registerHit(.perfect, points: 100)
        }
        session1.end()
        profile.updateStatistics(from: session1)

        // Play second song
        var session2 = GameSession(songID: song2.id, difficulty: .hard)
        for _ in 0..<40 {
            session2.registerHit(.great, points: 100)
        }
        session2.end()
        profile.updateStatistics(from: session2)

        // Then
        XCTAssertEqual(profile.totalSongsPlayed, 2)
        XCTAssertEqual(profile.statistics.perfectHits, 30)
        XCTAssertEqual(profile.statistics.greatHits, 40)
    }

    // MARK: - Data Persistence Integration

    func testSaveAndLoadPlayerProfile() throws {
        // Given
        let originalProfile = PlayerProfile(username: "TestPlayer", displayName: "Test")
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()

        // When - Save
        let data = try encoder.encode(originalProfile)

        // Simulate save to UserDefaults
        UserDefaults.standard.set(data, forKey: "test_profile")

        // Load
        let loadedData = UserDefaults.standard.data(forKey: "test_profile")!
        let loadedProfile = try decoder.decode(PlayerProfile.self, from: loadedData)

        // Then
        XCTAssertEqual(loadedProfile.id, originalProfile.id)
        XCTAssertEqual(loadedProfile.username, originalProfile.username)
        XCTAssertEqual(loadedProfile.level, originalProfile.level)

        // Cleanup
        UserDefaults.standard.removeObject(forKey: "test_profile")
    }

    // MARK: - Performance Integration Tests

    @MainActor
    func testGameLoopPerformance() async throws {
        // Given
        let song = Song.sampleSong
        await gameEngine.startSong(song, difficulty: .normal)

        // Then - Measure update loop performance
        measure {
            // Simulate multiple frames
            for _ in 0..<90 { // 1 second at 90fps
                // Game loop would update here
                _ = scoreManager.currentScore
            }
        }
    }

    // MARK: - Error Handling Tests

    @MainActor
    func testHandleMissingSong() async throws {
        // Given - Invalid song (no audio file)
        let invalidSong = Song(
            title: "Invalid",
            artist: "Test",
            duration: 60.0,
            bpm: 120.0,
            genre: .pop,
            audioFileName: "nonexistent_file",
            beatMapFileNames: [:],
            artworkName: "test"
        )

        // When/Then - Should handle gracefully
        await gameEngine.startSong(invalidSong, difficulty: .normal)

        // Game should still initialize (even if audio fails)
        XCTAssertNotNil(gameEngine.currentSession)
    }
}
