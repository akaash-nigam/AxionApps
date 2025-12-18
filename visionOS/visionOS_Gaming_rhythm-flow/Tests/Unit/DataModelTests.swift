//
//  DataModelTests.swift
//  RhythmFlowTests
//
//  Unit tests for data models (Song, BeatMap, PlayerProfile, etc.)
//

import XCTest
@testable import RhythmFlow

final class DataModelTests: XCTestCase {

    // MARK: - Song Model Tests

    func testSongInitialization() {
        // When
        let song = Song(
            title: "Test Song",
            artist: "Test Artist",
            duration: 180.0,
            bpm: 128.0,
            genre: .edm,
            audioFileName: "test_audio",
            beatMapFileNames: [.easy: "test_easy", .normal: "test_normal"],
            artworkName: "test_artwork"
        )

        // Then
        XCTAssertEqual(song.title, "Test Song")
        XCTAssertEqual(song.artist, "Test Artist")
        XCTAssertEqual(song.duration, 180.0)
        XCTAssertEqual(song.bpm, 128.0)
        XCTAssertEqual(song.genre, .edm)
    }

    func testSongCodable() throws {
        // Given
        let song = Song.sampleSong
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()

        // When
        let encoded = try encoder.encode(song)
        let decoded = try decoder.decode(Song.self, from: encoded)

        // Then
        XCTAssertEqual(decoded.id, song.id)
        XCTAssertEqual(decoded.title, song.title)
        XCTAssertEqual(decoded.artist, song.artist)
        XCTAssertEqual(decoded.bpm, song.bpm)
    }

    // MARK: - BeatMap Model Tests

    func testBeatMapGeneration() {
        // Given
        let difficulty = Difficulty.normal
        let duration: TimeInterval = 180.0
        let bpm: Double = 128.0

        // When
        let beatMap = BeatMap.generateSample(difficulty: difficulty, songDuration: duration, bpm: bpm)

        // Then
        XCTAssertEqual(beatMap.difficulty, difficulty)
        XCTAssertTrue(beatMap.noteCount > 0, "Beat map should have notes")
        XCTAssertTrue(beatMap.generatedByAI)
        XCTAssertNotNil(beatMap.aiVersion)
    }

    func testBeatMapNoteOrdering() {
        // Given
        let beatMap = BeatMap.generateSample(difficulty: .normal, songDuration: 60.0, bpm: 120.0)

        // When
        let notes = beatMap.loadNoteEvents()

        // Then
        for i in 0..<(notes.count - 1) {
            XCTAssertLessThanOrEqual(notes[i].timestamp, notes[i + 1].timestamp,
                                    "Notes should be ordered by timestamp")
        }
    }

    func testBeatMapDifficultyScaling() {
        // Given
        let duration: TimeInterval = 60.0
        let bpm: Double = 120.0

        // When
        let easyMap = BeatMap.generateSample(difficulty: .easy, songDuration: duration, bpm: bpm)
        let expertMap = BeatMap.generateSample(difficulty: .expert, songDuration: duration, bpm: bpm)

        // Then
        XCTAssertLessThan(easyMap.noteCount, expertMap.noteCount,
                         "Expert should have more notes than Easy")
    }

    func testBeatMapCodable() throws {
        // Given
        let beatMap = BeatMap.generateSample(difficulty: .normal, songDuration: 60.0, bpm: 120.0)
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()

        // When
        let encoded = try encoder.encode(beatMap)
        let decoded = try decoder.decode(BeatMap.self, from: encoded)

        // Then
        XCTAssertEqual(decoded.difficulty, beatMap.difficulty)
        XCTAssertEqual(decoded.noteCount, beatMap.noteCount)
        XCTAssertEqual(decoded.noteEvents.count, beatMap.noteEvents.count)
    }

    // MARK: - NoteEvent Model Tests

    func testNoteEventInitialization() {
        // When
        let note = NoteEvent(
            timestamp: 2.5,
            type: .punch,
            position: SIMD3<Float>(0, 1.5, 0.8),
            hand: .right,
            gesture: .punch,
            points: 100
        )

        // Then
        XCTAssertEqual(note.timestamp, 2.5)
        XCTAssertEqual(note.type, .punch)
        XCTAssertEqual(note.hand, .right)
        XCTAssertEqual(note.gesture, .punch)
        XCTAssertEqual(note.points, 100)
    }

    func testNoteEventDefaultColor() {
        // When
        let leftNote = NoteEvent(timestamp: 1.0, type: .punch, position: .zero, hand: .left, gesture: .punch)
        let rightNote = NoteEvent(timestamp: 1.0, type: .punch, position: .zero, hand: .right, gesture: .punch)
        let bothNote = NoteEvent(timestamp: 1.0, type: .punch, position: .zero, hand: .both, gesture: .punch)

        // Then
        XCTAssertEqual(leftNote.color, .blue)
        XCTAssertEqual(rightNote.color, .red)
        XCTAssertEqual(bothNote.color, .green)
    }

    // MARK: - PlayerProfile Model Tests

    func testPlayerProfileInitialization() {
        // When
        let profile = PlayerProfile(username: "TestUser", displayName: "Test Player")

        // Then
        XCTAssertEqual(profile.username, "TestUser")
        XCTAssertEqual(profile.displayName, "Test Player")
        XCTAssertEqual(profile.level, 1)
        XCTAssertEqual(profile.experience, 0)
        XCTAssertEqual(profile.totalScore, 0)
        XCTAssertEqual(profile.totalSongsPlayed, 0)
    }

    func testPlayerProfileStatisticsUpdate() {
        // Given
        var profile = PlayerProfile(username: "TestUser", displayName: "Test Player")
        var session = GameSession(songID: UUID(), difficulty: .normal)

        // Configure session
        session.registerHit(.perfect, points: 100)
        session.registerHit(.great, points: 100)
        session.registerHit(.miss, points: 100)

        // When
        profile.updateStatistics(from: session)

        // Then
        XCTAssertEqual(profile.totalSongsPlayed, 1)
        XCTAssertGreaterThan(profile.totalScore, 0)
        XCTAssertEqual(profile.statistics.perfectHits, 1)
        XCTAssertEqual(profile.statistics.greatHits, 1)
        XCTAssertEqual(profile.statistics.missedHits, 1)
    }

    func testPlayerProfileLevelUp() {
        // Given
        var profile = PlayerProfile(username: "TestUser", displayName: "Test Player")
        let initialLevel = profile.level

        // Create high-scoring sessions
        for _ in 0..<10 {
            var session = GameSession(songID: UUID(), difficulty: .expert)
            for _ in 0..<100 {
                session.registerHit(.perfect, points: 100)
            }
            profile.updateStatistics(from: session)
        }

        // Then
        XCTAssertGreaterThan(profile.level, initialLevel, "Player should level up")
        XCTAssertGreaterThan(profile.experience, 0, "Player should have experience")
    }

    func testPlayerProfileCodable() throws {
        // Given
        let profile = PlayerProfile(username: "TestUser", displayName: "Test Player")
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()

        // When
        let encoded = try encoder.encode(profile)
        let decoded = try decoder.decode(PlayerProfile.self, from: encoded)

        // Then
        XCTAssertEqual(decoded.id, profile.id)
        XCTAssertEqual(decoded.username, profile.username)
        XCTAssertEqual(decoded.level, profile.level)
    }

    // MARK: - GameSession Model Tests

    func testGameSessionInitialization() {
        // When
        let session = GameSession(songID: UUID(), difficulty: .normal)

        // Then
        XCTAssertNotNil(session.id)
        XCTAssertEqual(session.difficulty, .normal)
        XCTAssertEqual(session.score, 0)
        XCTAssertEqual(session.currentCombo, 0)
        XCTAssertNil(session.endTime)
    }

    func testGameSessionHitRegistration() {
        // Given
        var session = GameSession(songID: UUID(), difficulty: .normal)

        // When
        session.registerHit(.perfect, points: 100)
        session.registerHit(.great, points: 100)
        session.registerHit(.good, points: 100)
        session.registerHit(.miss, points: 100)

        // Then
        XCTAssertEqual(session.perfectHits, 1)
        XCTAssertEqual(session.greatHits, 1)
        XCTAssertEqual(session.goodHits, 1)
        XCTAssertEqual(session.missedHits, 1)
        XCTAssertEqual(session.totalHits, 3)
        XCTAssertEqual(session.totalNotes, 4)
    }

    func testGameSessionAccuracy() {
        // Given
        var session = GameSession(songID: UUID(), difficulty: .normal)

        // When - All perfect
        for _ in 0..<10 {
            session.registerHit(.perfect, points: 100)
        }

        // Then
        XCTAssertEqual(session.calculateAccuracy(), 1.0, accuracy: 0.01)
    }

    func testGameSessionGradeCalculation() {
        // Given
        var session = GameSession(songID: UUID(), difficulty: .normal)

        // When - 96% accuracy for S+
        for _ in 0..<96 {
            session.registerHit(.perfect, points: 100)
        }
        for _ in 0..<4 {
            session.registerHit(.great, points: 100)
        }

        // Then
        XCTAssertEqual(session.calculateGrade(), .sPlus)
    }

    func testGameSessionEnd() {
        // Given
        var session = GameSession(songID: UUID(), difficulty: .normal)
        XCTAssertNil(session.endTime)

        // When
        session.end()

        // Then
        XCTAssertNotNil(session.endTime)
    }

    // MARK: - Difficulty Model Tests

    func testDifficultyMultipliers() {
        // Then
        XCTAssertEqual(Difficulty.easy.multiplier, 0.7, accuracy: 0.01)
        XCTAssertEqual(Difficulty.normal.multiplier, 1.0, accuracy: 0.01)
        XCTAssertEqual(Difficulty.hard.multiplier, 1.3, accuracy: 0.01)
        XCTAssertEqual(Difficulty.expert.multiplier, 1.6, accuracy: 0.01)
        XCTAssertEqual(Difficulty.expertPlus.multiplier, 2.0, accuracy: 0.01)
    }

    // MARK: - HitQuality Model Tests

    func testHitQualityScoreMultipliers() {
        // Then
        XCTAssertEqual(HitQuality.perfect.scoreMultiplier, 1.15, accuracy: 0.01)
        XCTAssertEqual(HitQuality.great.scoreMultiplier, 1.0, accuracy: 0.01)
        XCTAssertEqual(HitQuality.good.scoreMultiplier, 0.75, accuracy: 0.01)
        XCTAssertEqual(HitQuality.miss.scoreMultiplier, 0.0, accuracy: 0.01)
    }

    // MARK: - NoteColor Tests

    func testNoteColorRGBValues() {
        // Then
        let blue = NoteColor.blue.rgbValues
        XCTAssertEqual(blue.x, 0.0, accuracy: 0.01)
        XCTAssertEqual(blue.y, 0.85, accuracy: 0.01)
        XCTAssertEqual(blue.z, 1.0, accuracy: 0.01)

        let red = NoteColor.red.rgbValues
        XCTAssertEqual(red.x, 1.0, accuracy: 0.01)
        XCTAssertEqual(red.y, 0.0, accuracy: 0.01)
        XCTAssertEqual(red.z, 0.33, accuracy: 0.01)
    }

    // MARK: - Performance Tests

    func testSongEncodingPerformance() throws {
        let song = Song.sampleSong
        let encoder = JSONEncoder()

        measure {
            _ = try? encoder.encode(song)
        }
    }

    func testBeatMapGenerationPerformance() {
        measure {
            _ = BeatMap.generateSample(difficulty: .normal, songDuration: 180.0, bpm: 128.0)
        }
    }
}
