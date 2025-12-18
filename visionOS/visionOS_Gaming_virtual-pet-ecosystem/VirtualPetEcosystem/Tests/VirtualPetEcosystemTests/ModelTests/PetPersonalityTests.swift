import XCTest
@testable import VirtualPetEcosystem

final class PetPersonalityTests: XCTestCase {
    func testDefaultInitialization() {
        let personality = PetPersonality()

        // All traits should be at default 0.5
        XCTAssertEqual(personality.openness, 0.5)
        XCTAssertEqual(personality.conscientiousness, 0.5)
        XCTAssertEqual(personality.extraversion, 0.5)
        XCTAssertEqual(personality.agreeableness, 0.5)
        XCTAssertEqual(personality.neuroticism, 0.5)
        XCTAssertEqual(personality.playfulness, 0.5)
        XCTAssertEqual(personality.independence, 0.5)
        XCTAssertEqual(personality.loyalty, 0.5)
        XCTAssertEqual(personality.intelligence, 0.5)
        XCTAssertEqual(personality.affectionNeed, 0.5)
    }

    func testClamping() {
        let personality = PetPersonality(
            openness: 1.5,  // Should be clamped to 1.0
            extraversion: -0.5,  // Should be clamped to 0.0
            playfulness: 0.7  // Should remain 0.7
        )

        XCTAssertEqual(personality.openness, 1.0)
        XCTAssertEqual(personality.extraversion, 0.0)
        XCTAssertEqual(personality.playfulness, 0.7)
    }

    func testRandomPersonality() {
        let personality = PetPersonality.random()

        // All traits should be within 0.0 - 1.0
        XCTAssertGreaterThanOrEqual(personality.openness, 0.0)
        XCTAssertLessThanOrEqual(personality.openness, 1.0)

        XCTAssertGreaterThanOrEqual(personality.playfulness, 0.0)
        XCTAssertLessThanOrEqual(personality.playfulness, 1.0)

        XCTAssertGreaterThanOrEqual(personality.loyalty, 0.0)
        XCTAssertLessThanOrEqual(personality.loyalty, 1.0)
    }

    func testSpeciesInfluence() {
        let luminosPersonality = PetPersonality.forSpecies(.luminos)
        let shadowlingPersonality = PetPersonality.forSpecies(.shadowlings)

        // Luminos should be more extraverted than shadowlings
        XCTAssertGreaterThan(luminosPersonality.extraversion, shadowlingPersonality.extraversion)

        // Fluffkins should be more loyal
        let fluffkinsPersonality = PetPersonality.forSpecies(.fluffkins)
        XCTAssertGreaterThan(fluffkinsPersonality.loyalty, 0.5)
        XCTAssertGreaterThan(fluffkinsPersonality.affectionNeed, 0.5)

        // Crystalites should be more intelligent
        let crystalitesPersonality = PetPersonality.forSpecies(.crystalites)
        XCTAssertGreaterThan(crystalitesPersonality.intelligence, 0.5)
        XCTAssertGreaterThan(crystalitesPersonality.conscientiousness, 0.5)
    }

    func testPersonalityEvolution() {
        var personality = PetPersonality()
        let initialPlayfulness = personality.playfulness

        // Play interaction should increase playfulness
        personality.evolve(basedOn: .playing, amount: 0.1)

        XCTAssertGreaterThan(personality.playfulness, initialPlayfulness)
    }

    func testPlayingEvolution() {
        var personality = PetPersonality(playfulness: 0.5, extraversion: 0.5)

        personality.evolve(basedOn: .playing, amount: 0.01)

        // Playing should increase playfulness and extraversion
        XCTAssertGreaterThan(personality.playfulness, 0.5)
        XCTAssertGreaterThan(personality.extraversion, 0.5)
    }

    func testPettingEvolution() {
        var personality = PetPersonality(affectionNeed: 0.5, loyalty: 0.5)

        personality.evolve(basedOn: .petting, amount: 0.01)

        // Petting should increase affection need and loyalty
        XCTAssertGreaterThan(personality.affectionNeed, 0.5)
        XCTAssertGreaterThan(personality.loyalty, 0.5)
    }

    func testFeedingEvolution() {
        var personality = PetPersonality(conscientiousness: 0.5, loyalty: 0.5)

        personality.evolve(basedOn: .feeding, amount: 0.01)

        // Feeding should increase conscientiousness and loyalty
        XCTAssertGreaterThan(personality.conscientiousness, 0.5)
        XCTAssertGreaterThan(personality.loyalty, 0.5)
    }

    func testClampingAfterEvolution() {
        var personality = PetPersonality(playfulness: 0.98)

        // Large evolution amount
        personality.evolve(basedOn: .playing, amount: 0.1)

        // Should be clamped to 1.0
        XCTAssertLessThanOrEqual(personality.playfulness, 1.0)
    }

    func testPersonalityDescription() {
        let playfulPet = PetPersonality(playfulness: 0.9, loyalty: 0.85, affectionNeed: 0.8)
        let description = playfulPet.description()

        XCTAssertTrue(description.contains("playful"))
        XCTAssertTrue(description.contains("loyal"))
        XCTAssertTrue(description.contains("affectionate"))
    }

    func testComputedProperties() {
        let personality = PetPersonality(
            neuroticism: 0.2,
            agreeableness: 0.8,
            extraversion: 0.7,
            playfulness: 0.6
        )

        // Happiness should be derived from low neuroticism and high agreeableness
        XCTAssertGreaterThan(personality.happiness, 0.5)

        // Energy level should be derived from extraversion and playfulness
        XCTAssertEqual(personality.energyLevel, (0.7 + 0.6) / 2.0)
    }

    func testCodable() throws {
        let personality = PetPersonality(
            openness: 0.7,
            playfulness: 0.8,
            loyalty: 0.9
        )

        // Encode
        let encoder = JSONEncoder()
        let data = try encoder.encode(personality)

        // Decode
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(PetPersonality.self, from: data)

        XCTAssertEqual(decoded.openness, 0.7)
        XCTAssertEqual(decoded.playfulness, 0.8)
        XCTAssertEqual(decoded.loyalty, 0.9)
    }
}
