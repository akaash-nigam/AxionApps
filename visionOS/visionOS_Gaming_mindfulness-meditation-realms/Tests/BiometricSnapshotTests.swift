import XCTest
@testable import MindfulnessMeditationRealms

/// Unit tests for BiometricSnapshot model
final class BiometricSnapshotTests: XCTestCase {

    // MARK: - Initialization Tests

    func testSnapshotCreation() {
        let snapshot = BiometricSnapshot(
            estimatedStressLevel: 0.7,
            estimatedCalmLevel: 0.4,
            breathingRate: 18.0,
            movementStillness: 0.6,
            focusLevel: 0.5
        )

        XCTAssertEqual(snapshot.estimatedStressLevel, 0.7)
        XCTAssertEqual(snapshot.estimatedCalmLevel, 0.4)
        XCTAssertEqual(snapshot.breathingRate, 18.0)
        XCTAssertEqual(snapshot.movementStillness, 0.6)
        XCTAssertEqual(snapshot.focusLevel, 0.5)
        XCTAssertNotNil(snapshot.timestamp)
    }

    // MARK: - Wellness Score Tests

    func testWellnessScore() {
        let snapshot = BiometricSnapshot(
            estimatedStressLevel: 0.2,
            estimatedCalmLevel: 0.9,
            movementStillness: 0.85,
            focusLevel: 0.8
        )

        let expectedScore = (0.9 + 0.85 + 0.8) / 3.0
        XCTAssertEqual(snapshot.wellnessScore, Float(expectedScore), accuracy: 0.01)
    }

    func testWellnessScoreRange() {
        // High wellness
        let highSnapshot = BiometricSnapshot(
            estimatedStressLevel: 0.1,
            estimatedCalmLevel: 0.95,
            movementStillness: 0.9,
            focusLevel: 0.9
        )
        XCTAssertGreaterThan(highSnapshot.wellnessScore, 0.9)

        // Low wellness
        let lowSnapshot = BiometricSnapshot(
            estimatedStressLevel: 0.9,
            estimatedCalmLevel: 0.2,
            movementStillness: 0.3,
            focusLevel: 0.2
        )
        XCTAssertLessThan(lowSnapshot.wellnessScore, 0.3)
    }

    // MARK: - Quality Rating Tests

    func testQualityRating() {
        let perfect = BiometricSnapshot(
            estimatedStressLevel: 0.0,
            estimatedCalmLevel: 1.0,
            movementStillness: 1.0,
            focusLevel: 1.0
        )
        XCTAssertEqual(perfect.qualityRating, 5)

        let excellent = BiometricSnapshot(
            estimatedStressLevel: 0.1,
            estimatedCalmLevel: 0.9,
            movementStillness: 0.85,
            focusLevel: 0.88
        )
        XCTAssertEqual(excellent.qualityRating, 4)

        let good = BiometricSnapshot(
            estimatedStressLevel: 0.3,
            estimatedCalmLevel: 0.7,
            movementStillness: 0.65,
            focusLevel: 0.7
        )
        XCTAssertEqual(good.qualityRating, 3)

        let fair = BiometricSnapshot(
            estimatedStressLevel: 0.5,
            estimatedCalmLevel: 0.5,
            movementStillness: 0.5,
            focusLevel: 0.5
        )
        XCTAssertEqual(fair.qualityRating, 2)

        let poor = BiometricSnapshot(
            estimatedStressLevel: 0.8,
            estimatedCalmLevel: 0.3,
            movementStillness: 0.25,
            focusLevel: 0.3
        )
        XCTAssertLessThanOrEqual(poor.qualityRating, 1)
    }

    // MARK: - Meditation Depth Tests

    func testMeditationDepth() {
        let deep = BiometricSnapshot(
            estimatedStressLevel: 0.1,
            estimatedCalmLevel: 0.95,
            movementStillness: 0.9,
            focusLevel: 0.9
        )
        XCTAssertEqual(deep.meditationDepth, .deep)

        let moderate = BiometricSnapshot(
            estimatedStressLevel: 0.3,
            estimatedCalmLevel: 0.7,
            movementStillness: 0.65,
            focusLevel: 0.7
        )
        XCTAssertEqual(moderate.meditationDepth, .moderate)

        let light = BiometricSnapshot(
            estimatedStressLevel: 0.5,
            estimatedCalmLevel: 0.5,
            movementStillness: 0.5,
            focusLevel: 0.5
        )
        XCTAssertEqual(light.meditationDepth, .light)

        let settling = BiometricSnapshot(
            estimatedStressLevel: 0.8,
            estimatedCalmLevel: 0.3,
            movementStillness: 0.3,
            focusLevel: 0.3
        )
        XCTAssertEqual(settling.meditationDepth, .settling)
    }

    // MARK: - Factory Methods Tests

    func testCalmFactory() {
        let snapshot = BiometricSnapshot.calm()

        XCTAssertLessThan(snapshot.estimatedStressLevel, 0.3)
        XCTAssertGreaterThan(snapshot.estimatedCalmLevel, 0.8)
        XCTAssertGreaterThan(snapshot.movementStillness, 0.8)
        XCTAssertGreaterThan(snapshot.focusLevel, 0.7)
        XCTAssertLessThan(snapshot.breathingRate ?? 0, 13.0)
    }

    func testStressedFactory() {
        let snapshot = BiometricSnapshot.stressed()

        XCTAssertGreaterThan(snapshot.estimatedStressLevel, 0.8)
        XCTAssertLessThan(snapshot.estimatedCalmLevel, 0.3)
        XCTAssertLessThan(snapshot.movementStillness, 0.4)
        XCTAssertLessThan(snapshot.focusLevel, 0.5)
        XCTAssertGreaterThan(snapshot.breathingRate ?? 0, 20.0)
    }

    func testNeutralFactory() {
        let snapshot = BiometricSnapshot.neutral()

        XCTAssertEqual(snapshot.estimatedStressLevel, 0.5)
        XCTAssertEqual(snapshot.estimatedCalmLevel, 0.5)
        XCTAssertEqual(snapshot.breathingRate, 16.0)
    }

    // MARK: - Breathing Pattern Tests

    func testBreathingPatternAnalysis() {
        let shallow = BreathingPattern.analyze(breathingRate: 22.0, regularity: 0.4)
        XCTAssertEqual(shallow.quality, .shallow)

        let normal = BreathingPattern.analyze(breathingRate: 15.0, regularity: 0.7)
        XCTAssertEqual(normal.quality, .normal)

        let deep = BreathingPattern.analyze(breathingRate: 10.0, regularity: 0.8)
        XCTAssertEqual(deep.quality, .deep)

        let yogic = BreathingPattern.analyze(breathingRate: 6.0, regularity: 0.95)
        XCTAssertEqual(yogic.quality, .yogic)
    }

    func testBreathingPatternVariability() {
        let pattern = BreathingPattern.analyze(breathingRate: 12.0, regularity: 0.8)

        XCTAssertEqual(pattern.variability, 0.2, accuracy: 0.01)
        XCTAssertEqual(pattern.regularity, 0.8)
        XCTAssertEqual(pattern.averageRate, 12.0)
    }

    // MARK: - Codable Tests

    func testSnapshotCodable() throws {
        let snapshot = BiometricSnapshot(
            estimatedStressLevel: 0.6,
            estimatedCalmLevel: 0.5,
            breathingRate: 15.5,
            movementStillness: 0.7,
            focusLevel: 0.65,
            headMovementVariance: 0.3,
            eyeMovementRate: 0.4,
            gestureFrequency: 0.2
        )

        let encoder = JSONEncoder()
        let data = try encoder.encode(snapshot)

        let decoder = JSONDecoder()
        let decodedSnapshot = try decoder.decode(BiometricSnapshot.self, from: data)

        XCTAssertEqual(snapshot.estimatedStressLevel, decodedSnapshot.estimatedStressLevel)
        XCTAssertEqual(snapshot.estimatedCalmLevel, decodedSnapshot.estimatedCalmLevel)
        XCTAssertEqual(snapshot.breathingRate, decodedSnapshot.breathingRate)
        XCTAssertEqual(snapshot.movementStillness, decodedSnapshot.movementStillness)
        XCTAssertEqual(snapshot.focusLevel, decodedSnapshot.focusLevel)
    }
}
