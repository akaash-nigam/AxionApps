import XCTest
@testable import MindfulnessMeditationRealms

/// Unit tests for MeditationSession model
final class MeditationSessionTests: XCTestCase {

    // MARK: - Initialization Tests

    func testSessionCreation() {
        let userID = UUID()
        let session = MeditationSession(
            userID: userID,
            environmentID: "ZenGarden",
            technique: .breathAwareness,
            targetDuration: 600
        )

        XCTAssertNotNil(session.id)
        XCTAssertEqual(session.userID, userID)
        XCTAssertEqual(session.environmentID, "ZenGarden")
        XCTAssertEqual(session.technique, .breathAwareness)
        XCTAssertEqual(session.targetDuration, 600)
        XCTAssertEqual(session.duration, 0)
        XCTAssertEqual(session.completionPercentage, 0)
    }

    // MARK: - Duration & Completion Tests

    func testUpdateDuration() {
        var session = MeditationSession(
            userID: UUID(),
            environmentID: "ZenGarden",
            technique: .breathAwareness,
            targetDuration: 600
        )

        session.updateDuration(300)
        XCTAssertEqual(session.duration, 300)
        XCTAssertEqual(session.completionPercentage, 0.5)

        session.updateDuration(600)
        XCTAssertEqual(session.duration, 600)
        XCTAssertEqual(session.completionPercentage, 1.0)

        session.updateDuration(700)
        XCTAssertEqual(session.duration, 700)
        XCTAssertEqual(session.completionPercentage, 1.0) // Capped at 1.0
    }

    func testSessionCompletion() {
        var session = MeditationSession(
            userID: UUID(),
            environmentID: "ZenGarden",
            technique: .breathAwareness,
            targetDuration: 600
        )

        XCTAssertFalse(session.isCompleted)

        session.updateDuration(540) // 90%
        XCTAssertTrue(session.isCompleted) // >= 90% is completed

        session.updateDuration(600) // 100%
        XCTAssertTrue(session.isCompleted)
    }

    func testCompleteSession() {
        var session = MeditationSession(
            userID: UUID(),
            environmentID: "ZenGarden",
            technique: .breathAwareness,
            targetDuration: 600
        )

        let startTime = session.startTime
        let endTime = startTime.addingTimeInterval(550)

        session.complete(with: endTime)

        XCTAssertEqual(session.endTime, endTime)
        XCTAssertEqual(session.duration, 550)
        XCTAssertGreaterThan(session.completionPercentage, 0.9)
    }

    // MARK: - Biometric Tests

    func testAddBiometricSnapshot() {
        var session = MeditationSession(
            userID: UUID(),
            environmentID: "ZenGarden",
            technique: .breathAwareness,
            targetDuration: 600
        )

        let snapshot1 = BiometricSnapshot(
            estimatedStressLevel: 0.8,
            estimatedCalmLevel: 0.3,
            movementStillness: 0.4,
            focusLevel: 0.5
        )

        session.addBiometricSnapshot(snapshot1)

        XCTAssertEqual(session.biometricSnapshots.count, 1)
        XCTAssertNotNil(session.initialBiometrics)
        XCTAssertNotNil(session.finalBiometrics)
        XCTAssertEqual(session.initialBiometrics?.estimatedStressLevel, 0.8)

        let snapshot2 = BiometricSnapshot(
            estimatedStressLevel: 0.3,
            estimatedCalmLevel: 0.8,
            movementStillness: 0.9,
            focusLevel: 0.85
        )

        session.addBiometricSnapshot(snapshot2)

        XCTAssertEqual(session.biometricSnapshots.count, 2)
        XCTAssertEqual(session.finalBiometrics?.estimatedStressLevel, 0.3)
    }

    func testStressReduction() {
        var session = MeditationSession(
            userID: UUID(),
            environmentID: "ZenGarden",
            technique: .breathAwareness,
            targetDuration: 600
        )

        XCTAssertNil(session.stressReduction)

        let initialSnapshot = BiometricSnapshot(
            estimatedStressLevel: 0.9,
            estimatedCalmLevel: 0.2,
            movementStillness: 0.3,
            focusLevel: 0.4
        )

        session.addBiometricSnapshot(initialSnapshot)

        let finalSnapshot = BiometricSnapshot(
            estimatedStressLevel: 0.3,
            estimatedCalmLevel: 0.8,
            movementStillness: 0.85,
            focusLevel: 0.9
        )

        session.addBiometricSnapshot(finalSnapshot)

        XCTAssertEqual(session.stressReduction, 0.6, accuracy: 0.01)
    }

    func testCalmIncrease() {
        var session = MeditationSession(
            userID: UUID(),
            environmentID: "ZenGarden",
            technique: .breathAwareness,
            targetDuration: 600
        )

        let initialSnapshot = BiometricSnapshot(
            estimatedStressLevel: 0.8,
            estimatedCalmLevel: 0.3,
            movementStillness: 0.4,
            focusLevel: 0.5
        )

        session.addBiometricSnapshot(initialSnapshot)

        let finalSnapshot = BiometricSnapshot(
            estimatedStressLevel: 0.2,
            estimatedCalmLevel: 0.9,
            movementStillness: 0.95,
            focusLevel: 0.88
        )

        session.addBiometricSnapshot(finalSnapshot)

        XCTAssertEqual(session.calmIncrease, 0.6, accuracy: 0.01)
    }

    // MARK: - Quality Score Tests

    func testQualityScoreCalculation() {
        var session = MeditationSession(
            userID: UUID(),
            environmentID: "ZenGarden",
            technique: .breathAwareness,
            targetDuration: 600
        )

        // Complete session with good metrics
        session.updateDuration(600)
        session.focusScore = 0.8

        let initialSnapshot = BiometricSnapshot(
            estimatedStressLevel: 0.9,
            estimatedCalmLevel: 0.2,
            movementStillness: 0.3,
            focusLevel: 0.4
        )
        session.addBiometricSnapshot(initialSnapshot)

        let finalSnapshot = BiometricSnapshot(
            estimatedStressLevel: 0.2,
            estimatedCalmLevel: 0.9,
            movementStillness: 0.95,
            focusLevel: 0.9
        )
        session.addBiometricSnapshot(finalSnapshot)

        let qualityScore = session.qualityScore

        // Quality score should be high with these metrics
        XCTAssertGreaterThan(qualityScore, 0.7)
        XCTAssertLessThanOrEqual(qualityScore, 1.0)
    }

    // MARK: - Meditation Technique Tests

    func testTechniqueDefaults() {
        XCTAssertEqual(MeditationTechnique.breathAwareness.defaultDuration, 300)
        XCTAssertEqual(MeditationTechnique.bodyScan.defaultDuration, 600)
        XCTAssertEqual(MeditationTechnique.lovingKindness.defaultDuration, 900)
        XCTAssertEqual(MeditationTechnique.visualizationJourney.defaultDuration, 1800)
    }

    func testTechniqueDifficulty() {
        XCTAssertEqual(MeditationTechnique.breathAwareness.difficultyLevel, 1)
        XCTAssertEqual(MeditationTechnique.bodyScan.difficultyLevel, 2)
        XCTAssertEqual(MeditationTechnique.lovingKindness.difficultyLevel, 3)
        XCTAssertEqual(MeditationTechnique.visualizationJourney.difficultyLevel, 4)
    }

    // MARK: - Session State Tests

    func testSessionStateTransitions() {
        XCTAssertTrue(SessionState.idle.canTransitionTo.contains(.preparing))
        XCTAssertFalse(SessionState.idle.canTransitionTo.contains(.active))

        XCTAssertTrue(SessionState.active.canTransitionTo.contains(.paused))
        XCTAssertTrue(SessionState.active.canTransitionTo.contains(.completing))

        XCTAssertTrue(SessionState.paused.canTransitionTo.contains(.active))
        XCTAssertTrue(SessionState.paused.canTransitionTo.contains(.completing))

        XCTAssertTrue(SessionState.completing.canTransitionTo.contains(.ended))
        XCTAssertEqual(SessionState.completing.canTransitionTo.count, 1)
    }

    // MARK: - Codable Tests

    func testSessionCodable() throws {
        let session = MeditationSession(
            userID: UUID(),
            environmentID: "ZenGarden",
            technique: .breathAwareness,
            targetDuration: 600
        )

        let encoder = JSONEncoder()
        let data = try encoder.encode(session)

        let decoder = JSONDecoder()
        let decodedSession = try decoder.decode(MeditationSession.self, from: data)

        XCTAssertEqual(session.id, decodedSession.id)
        XCTAssertEqual(session.userID, decodedSession.userID)
        XCTAssertEqual(session.environmentID, decodedSession.environmentID)
        XCTAssertEqual(session.technique, decodedSession.technique)
        XCTAssertEqual(session.targetDuration, decodedSession.targetDuration)
    }
}
