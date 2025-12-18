//
//  GameLogicTests.swift
//  Mystery Investigation Tests
//
//  Unit tests for game logic and calculations
//

import XCTest
@testable import MysteryInvestigation

final class GameLogicTests: XCTestCase {

    // MARK: - Score Calculation Tests

    func testBasicScoreForCorrectSolution() {
        // Given
        let coordinator = GameCoordinator()
        setupTestCase(coordinator)

        // When - Correct solution with all evidence
        let testCase = coordinator.activeCase!
        let evaluation = coordinator.submitSolution(
            accusedSuspect: testCase.solution.culpritID,
            evidence: testCase.solution.criticalEvidence,
            theory: "Test theory"
        )

        // Then
        XCTAssertTrue(evaluation.correct)
        XCTAssertGreaterThan(evaluation.score, 0)
    }

    func testScoreForWrongSolution() {
        // Given
        let coordinator = GameCoordinator()
        setupTestCase(coordinator)

        // When - Wrong suspect
        let evaluation = coordinator.submitSolution(
            accusedSuspect: UUID(),
            evidence: [],
            theory: "Wrong theory"
        )

        // Then
        XCTAssertFalse(evaluation.correct)
        XCTAssertEqual(evaluation.score, 0)
    }

    func testHintPenalty() {
        // Given
        let coordinator = GameCoordinator()
        setupTestCase(coordinator)

        // When - Use hints
        coordinator.progress?.hintsUsed = 3

        let testCase = coordinator.activeCase!
        let evaluation = coordinator.submitSolution(
            accusedSuspect: testCase.solution.culpritID,
            evidence: testCase.solution.criticalEvidence,
            theory: "Test theory"
        )

        // Then
        XCTAssertTrue(evaluation.correct)
        // Score should be reduced by 150 (3 hints × 50 points)
        XCTAssertEqual(evaluation.hintsUsed, 3)
    }

    func testTimeBonusForFastCompletion() {
        // Given
        let coordinator = GameCoordinator()
        setupTestCase(coordinator)

        // When - Very fast completion (1 minute)
        coordinator.progress?.timeElapsed = 60

        let testCase = coordinator.activeCase!
        let evaluation = coordinator.submitSolution(
            accusedSuspect: testCase.solution.culpritID,
            evidence: testCase.solution.criticalEvidence,
            theory: "Test theory"
        )

        // Then
        XCTAssertTrue(evaluation.correct)
        XCTAssertGreaterThan(evaluation.score, 1000) // Should have time bonus
    }

    func testEvidenceCollectionBonus() {
        // Given
        let coordinator = GameCoordinator()
        setupTestCase(coordinator)

        // When - Collect all evidence
        let testCase = coordinator.activeCase!
        for evidence in testCase.evidence {
            coordinator.progress?.discoveredEvidence.insert(evidence.id)
        }

        let evaluation = coordinator.submitSolution(
            accusedSuspect: testCase.solution.culpritID,
            evidence: testCase.solution.criticalEvidence,
            theory: "Test theory"
        )

        // Then
        XCTAssertEqual(evaluation.evidenceCollected, testCase.evidence.count)
    }

    // MARK: - Rating System Tests

    func testSRating() {
        // Given
        let evaluation = CaseEvaluation(correct: true, score: 1500)

        // Then
        XCTAssertEqual(evaluation.rating, "S")
    }

    func testARating() {
        // Given
        let evaluation = CaseEvaluation(correct: true, score: 1200)

        // Then
        XCTAssertEqual(evaluation.rating, "A")
    }

    func testBRating() {
        // Given
        let evaluation = CaseEvaluation(correct: true, score: 900)

        // Then
        XCTAssertEqual(evaluation.rating, "B")
    }

    func testCRating() {
        // Given
        let evaluation = CaseEvaluation(correct: true, score: 600)

        // Then
        XCTAssertEqual(evaluation.rating, "C")
    }

    func testFailedRating() {
        // Given
        let evaluation = CaseEvaluation(correct: false, score: 0)

        // Then
        XCTAssertEqual(evaluation.rating, "Failed")
    }

    // MARK: - Investigation Progress Tests

    func testInvestigationProgressInitialization() {
        // Given
        let caseID = UUID()

        // When
        let progress = InvestigationProgress(caseID: caseID)

        // Then
        XCTAssertEqual(progress.caseID, caseID)
        XCTAssertTrue(progress.discoveredEvidence.isEmpty)
        XCTAssertEqual(progress.hintsUsed, 0)
        XCTAssertEqual(progress.timeElapsed, 0)
    }

    func testEvidenceDiscoveryTracking() {
        // Given
        var progress = InvestigationProgress(caseID: UUID())
        let evidenceIDs = [UUID(), UUID(), UUID()]

        // When
        for id in evidenceIDs {
            progress.discoveredEvidence.insert(id)
        }

        // Then
        XCTAssertEqual(progress.discoveredEvidence.count, 3)
        for id in evidenceIDs {
            XCTAssertTrue(progress.discoveredEvidence.contains(id))
        }
    }

    // MARK: - Game State Transitions Tests

    func testGameStateTransitions() {
        // Given
        let coordinator = GameCoordinator()

        // Initial state
        XCTAssertEqual(coordinator.currentState, .mainMenu)

        // When - Start case
        setupTestCase(coordinator)

        // Then
        XCTAssertEqual(coordinator.currentState, .investigating)

        // When - Pause
        coordinator.pauseGame()

        // Then
        XCTAssertEqual(coordinator.currentState, .paused)

        // When - Resume
        coordinator.resumeGame()

        // Then
        XCTAssertEqual(coordinator.currentState, .investigating)

        // When - Complete case
        let testCase = coordinator.activeCase!
        let evaluation = coordinator.submitSolution(
            accusedSuspect: testCase.solution.culpritID,
            evidence: testCase.solution.criticalEvidence,
            theory: "Test"
        )
        coordinator.completeCase(evaluation: evaluation)

        // Then
        XCTAssertEqual(coordinator.currentState, .caseComplete)
    }

    // MARK: - Difficulty Validation Tests

    func testTutorialCaseDifficulty() {
        // Given
        let manager = CaseManager()
        let tutorialCase = manager.availableCases.first { $0.difficulty == .tutorial }

        // Then
        XCTAssertNotNil(tutorialCase)
        XCTAssertEqual(tutorialCase?.difficultyStars, 1)
        XCTAssertLessThanOrEqual(tutorialCase?.suspects.count ?? 0, 3)
    }

    // MARK: - Theory Validation Tests

    func testTheoryStructure() {
        // Given
        let suspectID = UUID()
        let evidenceIDs = [UUID(), UUID()]

        let theory = Theory(
            suspectID: suspectID,
            motive: "Financial gain",
            method: "Poisoning",
            supportingEvidence: evidenceIDs,
            confidence: 0.8
        )

        // Then
        XCTAssertEqual(theory.suspectID, suspectID)
        XCTAssertEqual(theory.supportingEvidence.count, 2)
        XCTAssertEqual(theory.confidence, 0.8)
    }

    // MARK: - Edge Cases Tests

    func testNegativeScoreHandling() {
        // Given - Lots of hints used
        let coordinator = GameCoordinator()
        setupTestCase(coordinator)
        coordinator.progress?.hintsUsed = 100 // Extreme case

        let testCase = coordinator.activeCase!
        let evaluation = coordinator.submitSolution(
            accusedSuspect: testCase.solution.culpritID,
            evidence: testCase.solution.criticalEvidence,
            theory: "Test"
        )

        // Then - Score should never be negative
        XCTAssertGreaterThanOrEqual(evaluation.score, 0)
    }

    func testEmptyEvidenceList() {
        // Given
        let coordinator = GameCoordinator()
        setupTestCase(coordinator)

        // When - Submit with no evidence
        let testCase = coordinator.activeCase!
        let evaluation = coordinator.submitSolution(
            accusedSuspect: testCase.solution.culpritID,
            evidence: [],
            theory: "Test"
        )

        // Then - Should fail due to insufficient evidence
        XCTAssertFalse(evaluation.correct)
    }

    // MARK: - Case Completion Tracking Tests

    func testCaseCompletionRecording() {
        // Given
        var progress = PlayerProgress()
        let caseID = UUID()
        let evaluation = CaseEvaluation(correct: true, score: 1200)

        // When
        progress.addCompletedCase(caseID, evaluation: evaluation)

        // Then
        XCTAssertTrue(progress.completedCases.keys.contains(caseID))
        XCTAssertEqual(progress.completedCases[caseID]?.evaluation.score, 1200)
        XCTAssertEqual(progress.totalXP, 1200)
    }

    func testMultipleCaseCompletions() {
        // Given
        var progress = PlayerProgress()
        let case1 = UUID()
        let case2 = UUID()

        // When
        progress.addCompletedCase(case1, evaluation: CaseEvaluation(correct: true, score: 1000))
        progress.addCompletedCase(case2, evaluation: CaseEvaluation(correct: true, score: 1500))

        // Then
        XCTAssertEqual(progress.completedCases.count, 2)
        XCTAssertEqual(progress.totalXP, 2500)
    }

    // MARK: - Player Statistics Tests

    func testStatisticsInitialization() {
        // Given & When
        let stats = PlayerStatistics()

        // Then
        XCTAssertEqual(stats.totalCasesPlayed, 0)
        XCTAssertEqual(stats.totalCasesSolved, 0)
        XCTAssertEqual(stats.totalPlayTime, 0)
        XCTAssertEqual(stats.perfectSolves, 0)
    }

    // MARK: - Helper Methods

    private func setupTestCase(_ coordinator: GameCoordinator) {
        let manager = CaseManager()
        let testCase = manager.availableCases.first!
        coordinator.startNewCase(testCase)
    }
}

// MARK: - Performance Tests

final class PerformanceTests: XCTestCase {

    func testCaseLoadingPerformance() {
        measure {
            let manager = CaseManager()
            _ = manager.availableCases
        }
    }

    func testEvidenceSearchPerformance() {
        // Given
        let manager = EvidenceManager()
        for _ in 0..<100 {
            manager.discoverEvidence(createTestEvidence())
        }

        // When
        measure {
            _ = manager.getAllEvidence()
        }
    }

    func testScoreCalculationPerformance() {
        // Given
        let coordinator = GameCoordinator()
        let manager = CaseManager()
        let testCase = manager.availableCases.first!
        coordinator.startNewCase(testCase)

        // When
        measure {
            _ = coordinator.submitSolution(
                accusedSuspect: testCase.solution.culpritID,
                evidence: testCase.solution.criticalEvidence,
                theory: "Performance test"
            )
        }
    }

    private func createTestEvidence() -> Evidence {
        Evidence(
            id: UUID(),
            type: .fingerprint,
            name: "Test",
            description: "Test",
            detailedDescription: "Test",
            spatialAnchor: SpatialAnchorData(
                persistenceKey: "test",
                surfaceType: .floor,
                relativePosition: SIMD3<Float>(0, 0, 0),
                scale: 1.0
            ),
            isRedHerring: false,
            relatedSuspects: [],
            requiresTool: nil,
            forensicData: nil,
            discoveryDifficulty: .obvious,
            hintText: nil
        )
    }
}
