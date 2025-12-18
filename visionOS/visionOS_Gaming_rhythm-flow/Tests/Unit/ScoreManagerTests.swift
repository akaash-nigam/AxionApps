//
//  ScoreManagerTests.swift
//  RhythmFlowTests
//
//  Unit tests for ScoreManager
//

import XCTest
@testable import RhythmFlow

final class ScoreManagerTests: XCTestCase {
    var scoreManager: ScoreManager!

    override func setUp() {
        super.setUp()
        scoreManager = ScoreManager()
    }

    override func tearDown() {
        scoreManager = nil
        super.tearDown()
    }

    // MARK: - Hit Registration Tests

    func testPerfectHitScoring() {
        // Given
        let noteValue = 100

        // When
        scoreManager.registerHit(.perfect, noteValue: noteValue)

        // Then
        XCTAssertEqual(scoreManager.perfectHits, 1, "Should register 1 perfect hit")
        XCTAssertEqual(scoreManager.currentCombo, 1, "Combo should be 1")
        XCTAssertEqual(scoreManager.currentScore, 115, "Score should be 115 (100 + 15 bonus)")
    }

    func testGreatHitScoring() {
        // Given
        let noteValue = 100

        // When
        scoreManager.registerHit(.great, noteValue: noteValue)

        // Then
        XCTAssertEqual(scoreManager.greatHits, 1, "Should register 1 great hit")
        XCTAssertEqual(scoreManager.currentCombo, 1, "Combo should be 1")
        XCTAssertEqual(scoreManager.currentScore, 100, "Score should be 100")
    }

    func testGoodHitScoring() {
        // Given
        let noteValue = 100

        // When
        scoreManager.registerHit(.good, noteValue: noteValue)

        // Then
        XCTAssertEqual(scoreManager.goodHits, 1, "Should register 1 good hit")
        XCTAssertEqual(scoreManager.currentCombo, 1, "Combo should be 1")
        XCTAssertEqual(scoreManager.currentScore, 75, "Score should be 75 (100 * 0.75)")
    }

    func testMissBreaksCombo() {
        // Given - Build up a combo
        for _ in 0..<5 {
            scoreManager.registerHit(.perfect, noteValue: 100)
        }
        XCTAssertEqual(scoreManager.currentCombo, 5, "Combo should be 5")

        // When - Miss a note
        scoreManager.registerHit(.miss, noteValue: 100)

        // Then
        XCTAssertEqual(scoreManager.missedNotes, 1, "Should register 1 miss")
        XCTAssertEqual(scoreManager.currentCombo, 0, "Combo should be broken")
        XCTAssertEqual(scoreManager.multiplier, 1.0, "Multiplier should reset to 1.0")
    }

    // MARK: - Combo Multiplier Tests

    func testComboMultiplierAt10() {
        // Given - Build combo to 10
        for _ in 0..<10 {
            scoreManager.registerHit(.perfect, noteValue: 100)
        }

        // Then
        XCTAssertEqual(scoreManager.currentCombo, 10, "Combo should be 10")
        XCTAssertEqual(scoreManager.multiplier, 1.1, accuracy: 0.01, "Multiplier should be 1.1x")
    }

    func testComboMultiplierAt25() {
        // Given - Build combo to 25
        for _ in 0..<25 {
            scoreManager.registerHit(.perfect, noteValue: 100)
        }

        // Then
        XCTAssertEqual(scoreManager.currentCombo, 25, "Combo should be 25")
        XCTAssertEqual(scoreManager.multiplier, 1.25, accuracy: 0.01, "Multiplier should be 1.25x")
    }

    func testComboMultiplierAt50() {
        // Given - Build combo to 50
        for _ in 0..<50 {
            scoreManager.registerHit(.perfect, noteValue: 100)
        }

        // Then
        XCTAssertEqual(scoreManager.currentCombo, 50, "Combo should be 50")
        XCTAssertEqual(scoreManager.multiplier, 1.5, accuracy: 0.01, "Multiplier should be 1.5x")
    }

    func testComboMultiplierAt100() {
        // Given - Build combo to 100
        for _ in 0..<100 {
            scoreManager.registerHit(.perfect, noteValue: 100)
        }

        // Then
        XCTAssertEqual(scoreManager.currentCombo, 100, "Combo should be 100")
        XCTAssertEqual(scoreManager.multiplier, 2.0, accuracy: 0.01, "Multiplier should be 2.0x")
    }

    // MARK: - Max Combo Tests

    func testMaxComboTracking() {
        // Given - Build combo to 20
        for _ in 0..<20 {
            scoreManager.registerHit(.perfect, noteValue: 100)
        }
        XCTAssertEqual(scoreManager.maxCombo, 20)

        // When - Break combo and build to 15
        scoreManager.registerHit(.miss, noteValue: 100)
        for _ in 0..<15 {
            scoreManager.registerHit(.perfect, noteValue: 100)
        }

        // Then - Max should still be 20
        XCTAssertEqual(scoreManager.maxCombo, 20, "Max combo should remain 20")
        XCTAssertEqual(scoreManager.currentCombo, 15, "Current combo should be 15")
    }

    // MARK: - Accuracy Tests

    func testAccuracyWithAllPerfect() {
        // Given - All perfect hits
        for _ in 0..<10 {
            scoreManager.registerHit(.perfect, noteValue: 100)
        }

        // Then
        XCTAssertEqual(scoreManager.accuracy, 1.0, accuracy: 0.01, "Accuracy should be 100%")
    }

    func testAccuracyWithMixedHits() {
        // Given
        scoreManager.registerHit(.perfect, noteValue: 100) // 100%
        scoreManager.registerHit(.great, noteValue: 100)   // 85%
        scoreManager.registerHit(.good, noteValue: 100)    // 70%
        scoreManager.registerHit(.miss, noteValue: 100)    // 0%

        // Then - (100 + 85 + 70 + 0) / (4 * 100) = 255 / 400 = 0.6375
        XCTAssertEqual(scoreManager.accuracy, 0.6375, accuracy: 0.01, "Accuracy should be 63.75%")
    }

    func testAccuracyWithNoHits() {
        // Given - No hits yet

        // Then
        XCTAssertEqual(scoreManager.accuracy, 0.0, "Accuracy should be 0% with no hits")
    }

    // MARK: - Grade Calculation Tests

    func testGradeSPlus() {
        // Given - 96% accuracy
        for _ in 0..<96 {
            scoreManager.registerHit(.perfect, noteValue: 100)
        }
        for _ in 0..<4 {
            scoreManager.registerHit(.great, noteValue: 100)
        }

        // Then
        let grade = scoreManager.calculateGrade()
        XCTAssertEqual(grade, .sPlus, "Grade should be S+")
    }

    func testGradeS() {
        // Given - 92% accuracy
        for _ in 0..<92 {
            scoreManager.registerHit(.perfect, noteValue: 100)
        }
        for _ in 0..<8 {
            scoreManager.registerHit(.great, noteValue: 100)
        }

        // Then
        let grade = scoreManager.calculateGrade()
        XCTAssertEqual(grade, .s, "Grade should be S")
    }

    func testGradeA() {
        // Given - 82% accuracy
        for _ in 0..<82 {
            scoreManager.registerHit(.perfect, noteValue: 100)
        }
        for _ in 0..<18 {
            scoreManager.registerHit(.good, noteValue: 100)
        }

        // Then
        let grade = scoreManager.calculateGrade()
        XCTAssertEqual(grade, .a, "Grade should be A")
    }

    // MARK: - Reset Tests

    func testReset() {
        // Given - Some score state
        for _ in 0..<10 {
            scoreManager.registerHit(.perfect, noteValue: 100)
        }
        XCTAssertNotEqual(scoreManager.currentScore, 0)

        // When
        scoreManager.reset()

        // Then
        XCTAssertEqual(scoreManager.currentScore, 0, "Score should be reset")
        XCTAssertEqual(scoreManager.currentCombo, 0, "Combo should be reset")
        XCTAssertEqual(scoreManager.maxCombo, 0, "Max combo should be reset")
        XCTAssertEqual(scoreManager.perfectHits, 0, "Perfect hits should be reset")
        XCTAssertEqual(scoreManager.greatHits, 0, "Great hits should be reset")
        XCTAssertEqual(scoreManager.goodHits, 0, "Good hits should be reset")
        XCTAssertEqual(scoreManager.missedNotes, 0, "Misses should be reset")
    }

    // MARK: - Statistics Export Tests

    func testExportStatistics() {
        // Given
        scoreManager.registerHit(.perfect, noteValue: 100)
        scoreManager.registerHit(.great, noteValue: 100)
        scoreManager.registerHit(.good, noteValue: 100)
        scoreManager.registerHit(.miss, noteValue: 100)

        // When
        let stats = scoreManager.exportStatistics()

        // Then
        XCTAssertEqual(stats.perfectHits, 1)
        XCTAssertEqual(stats.greatHits, 1)
        XCTAssertEqual(stats.goodHits, 1)
        XCTAssertEqual(stats.missedNotes, 1)
        XCTAssertEqual(stats.totalHits, 3)
        XCTAssertEqual(stats.totalNotes, 4)
        XCTAssertNotNil(stats.grade)
    }

    // MARK: - Performance Tests

    func testPerformanceManyHits() {
        measure {
            for _ in 0..<1000 {
                scoreManager.registerHit(.perfect, noteValue: 100)
            }
        }
    }
}
