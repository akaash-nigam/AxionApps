import XCTest
@testable import MySpatialLife

final class PersonalityTests: XCTestCase {

    // MARK: - Initialization Tests

    func testPersonalityInitialization() {
        let personality = Personality(
            openness: 0.8,
            conscientiousness: 0.6,
            extraversion: 0.7,
            agreeableness: 0.9,
            neuroticism: 0.3
        )

        XCTAssertEqual(personality.openness, 0.8, accuracy: 0.01)
        XCTAssertEqual(personality.conscientiousness, 0.6, accuracy: 0.01)
        XCTAssertEqual(personality.extraversion, 0.7, accuracy: 0.01)
        XCTAssertEqual(personality.agreeableness, 0.9, accuracy: 0.01)
        XCTAssertEqual(personality.neuroticism, 0.3, accuracy: 0.01)
    }

    func testPersonalityValuesClamped() {
        // Values should be clamped to 0.0-1.0 range
        let personality = Personality(
            openness: 1.5,  // Over 1.0
            conscientiousness: -0.5,  // Below 0.0
            extraversion: 0.5,
            agreeableness: 0.5,
            neuroticism: 2.0  // Way over 1.0
        )

        XCTAssertEqual(personality.openness, 1.0)
        XCTAssertEqual(personality.conscientiousness, 0.0)
        XCTAssertEqual(personality.neuroticism, 1.0)
    }

    func testBalancedPersonality() {
        let balanced = Personality.balanced

        XCTAssertEqual(balanced.openness, 0.5)
        XCTAssertEqual(balanced.conscientiousness, 0.5)
        XCTAssertEqual(balanced.extraversion, 0.5)
        XCTAssertEqual(balanced.agreeableness, 0.5)
        XCTAssertEqual(balanced.neuroticism, 0.5)
    }

    func testRandomPersonality() {
        let random = Personality.random()

        // All values should be in valid range
        XCTAssertGreaterThanOrEqual(random.openness, 0.0)
        XCTAssertLessThanOrEqual(random.openness, 1.0)
        XCTAssertGreaterThanOrEqual(random.conscientiousness, 0.0)
        XCTAssertLessThanOrEqual(random.conscientiousness, 1.0)
        XCTAssertGreaterThanOrEqual(random.extraversion, 0.0)
        XCTAssertLessThanOrEqual(random.extraversion, 1.0)
        XCTAssertGreaterThanOrEqual(random.agreeableness, 0.0)
        XCTAssertLessThanOrEqual(random.agreeableness, 1.0)
        XCTAssertGreaterThanOrEqual(random.neuroticism, 0.0)
        XCTAssertLessThanOrEqual(random.neuroticism, 1.0)
    }

    // MARK: - Trait Derivation Tests

    func testHighConscientiousnessDerivesNeatTrait() {
        let personality = Personality(
            openness: 0.5,
            conscientiousness: 0.8,  // High
            extraversion: 0.5,
            agreeableness: 0.5,
            neuroticism: 0.5
        )

        XCTAssertTrue(personality.traits.contains(.neat))
    }

    func testLowConscientiousnessDerivesMessyTrait() {
        let personality = Personality(
            openness: 0.5,
            conscientiousness: 0.2,  // Low
            extraversion: 0.5,
            agreeableness: 0.5,
            neuroticism: 0.5
        )

        XCTAssertTrue(personality.traits.contains(.messy))
    }

    func testHighExtraversionDerivesOutgoingTrait() {
        let personality = Personality(
            openness: 0.5,
            conscientiousness: 0.5,
            extraversion: 0.8,  // High
            agreeableness: 0.5,
            neuroticism: 0.5
        )

        XCTAssertTrue(personality.traits.contains(.outgoing))
    }

    func testLowExtraversionDerivesShyTrait() {
        let personality = Personality(
            openness: 0.5,
            conscientiousness: 0.5,
            extraversion: 0.2,  // Low
            agreeableness: 0.5,
            neuroticism: 0.5
        )

        XCTAssertTrue(personality.traits.contains(.shy))
    }

    // MARK: - Personality Evolution Tests

    func testPersonalityEvolvesWithPromotion() {
        var personality = Personality.balanced

        // Apply promotion experience
        personality.evolve(by: .promotion, age: 30)

        // Conscientiousness should increase slightly
        XCTAssertGreaterThan(personality.conscientiousness, 0.5)

        // Neuroticism should decrease slightly
        XCTAssertLessThan(personality.neuroticism, 0.5)
    }

    func testPersonalityEvolvesWithFiring() {
        var personality = Personality.balanced

        // Apply firing experience
        personality.evolve(by: .fired, age: 30)

        // Neuroticism should increase
        XCTAssertGreaterThan(personality.neuroticism, 0.5)

        // Conscientiousness should decrease
        XCTAssertLessThan(personality.conscientiousness, 0.5)
    }

    func testYoungerCharactersChangeMoreRapidly() {
        var youngPersonality = Personality.balanced
        var oldPersonality = Personality.balanced

        // Same experience at different ages
        youngPersonality.evolve(by: .promotion, age: 15)
        oldPersonality.evolve(by: .promotion, age: 60)

        // Younger character should change more
        let youngChange = abs(youngPersonality.conscientiousness - 0.5)
        let oldChange = abs(oldPersonality.conscientiousness - 0.5)

        XCTAssertGreaterThan(youngChange, oldChange)
    }

    func testPersonalityStaysInValidRange() {
        var personality = Personality(
            openness: 0.9,
            conscientiousness: 0.9,
            extraversion: 0.9,
            agreeableness: 0.9,
            neuroticism: 0.1
        )

        // Apply many positive experiences
        for _ in 0..<100 {
            personality.evolve(by: .promotion, age: 25)
        }

        // Should not exceed 1.0
        XCTAssertLessThanOrEqual(personality.conscientiousness, 1.0)
        XCTAssertGreaterThanOrEqual(personality.neuroticism, 0.0)
    }

    // MARK: - Compatibility Tests

    func testIdenticalPersonalitiesHighCompatibility() {
        let personA = Personality(
            openness: 0.7,
            conscientiousness: 0.6,
            extraversion: 0.8,
            agreeableness: 0.9,
            neuroticism: 0.3
        )

        let personB = personA  // Identical

        let compatibility = Personality.calculateCompatibility(personA, personB)

        XCTAssertGreaterThan(compatibility, 0.7)
    }

    func testHighAgreeablenessIncreasesCompatibility() {
        let personA = Personality(
            openness: 0.5,
            conscientiousness: 0.5,
            extraversion: 0.5,
            agreeableness: 0.9,  // High
            neuroticism: 0.5
        )

        let personB = Personality(
            openness: 0.5,
            conscientiousness: 0.5,
            extraversion: 0.5,
            agreeableness: 0.9,  // High
            neuroticism: 0.5
        )

        let compatibility = Personality.calculateCompatibility(personA, personB)

        XCTAssertGreaterThan(compatibility, 0.5)
    }

    func testHighNeuroticismDecreasesCompatibility() {
        let personA = Personality(
            openness: 0.5,
            conscientiousness: 0.5,
            extraversion: 0.5,
            agreeableness: 0.5,
            neuroticism: 0.9  // High (bad)
        )

        let personB = Personality(
            openness: 0.5,
            conscientiousness: 0.5,
            extraversion: 0.5,
            agreeableness: 0.5,
            neuroticism: 0.9  // High (bad)
        )

        let compatibility = Personality.calculateCompatibility(personA, personB)

        XCTAssertLessThan(compatibility, 0.5)
    }

    func testCompatibilityInValidRange() {
        // Test many random personalities
        for _ in 0..<100 {
            let personA = Personality.random()
            let personB = Personality.random()

            let compatibility = Personality.calculateCompatibility(personA, personB)

            XCTAssertGreaterThanOrEqual(compatibility, 0.0)
            XCTAssertLessThanOrEqual(compatibility, 1.0)
        }
    }

    // MARK: - Codable Tests

    func testPersonalityCodable() throws {
        let original = Personality(
            openness: 0.8,
            conscientiousness: 0.6,
            extraversion: 0.7,
            agreeableness: 0.9,
            neuroticism: 0.3
        )

        let encoder = JSONEncoder()
        let decoder = JSONDecoder()

        let data = try encoder.encode(original)
        let decoded = try decoder.decode(Personality.self, from: data)

        XCTAssertEqual(original, decoded)
    }
}
