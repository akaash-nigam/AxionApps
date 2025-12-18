import XCTest
@testable import VirtualPetEcosystem

final class BreedingSystemTests: XCTestCase {
    var breedingSystem: BreedingSystem!

    override func setUp() async throws {
        breedingSystem = BreedingSystem()
    }

    func testSuccessfulBreeding() async {
        // Create two adult pets with good health
        let adultBirthDate = Date().addingTimeInterval(-86400 * 120)

        var parent1 = Pet(
            name: "Parent1",
            species: .luminos,
            birthDate: adultBirthDate,
            health: 0.9
        )
        parent1.updateLifeStage()

        var parent2 = Pet(
            name: "Parent2",
            species: .luminos,
            birthDate: adultBirthDate,
            health: 0.9
        )
        parent2.updateLifeStage()

        let result = await breedingSystem.breed(parent1, parent2)

        switch result {
        case .success(let offspring):
            XCTAssertEqual(offspring.species, .luminos)
            XCTAssertEqual(offspring.lifeStage, .baby)
            XCTAssertFalse(offspring.name.isEmpty)

        case .failure(let error):
            XCTFail("Breeding should succeed, but got error: \(error)")
        }
    }

    func testBreedingFailsForBaby() async {
        let baby = Pet(name: "Baby", species: .luminos)

        var adult = Pet(name: "Adult", species: .luminos, birthDate: Date().addingTimeInterval(-86400 * 120))
        adult.updateLifeStage()

        let result = await breedingSystem.breed(baby, adult)

        switch result {
        case .success:
            XCTFail("Breeding should fail for baby pet")

        case .failure(let error):
            // Expected error
            XCTAssertTrue(error.localizedDescription.contains("stage"))
        }
    }

    func testBreedingFailsForLowHealth() async {
        let adultBirthDate = Date().addingTimeInterval(-86400 * 120)

        var parent1 = Pet(
            name: "Sick",
            species: .luminos,
            birthDate: adultBirthDate,
            health: 0.3 // Low health
        )
        parent1.updateLifeStage()

        var parent2 = Pet(
            name: "Healthy",
            species: .luminos,
            birthDate: adultBirthDate,
            health: 0.9
        )
        parent2.updateLifeStage()

        let result = await breedingSystem.breed(parent1, parent2)

        switch result {
        case .success:
            XCTFail("Breeding should fail when parent has low health")

        case .failure(let error):
            XCTAssertTrue(error.localizedDescription.contains("health"))
        }
    }

    func testBreedingFailsForDifferentSpecies() async {
        let adultBirthDate = Date().addingTimeInterval(-86400 * 120)

        var luminos = Pet(
            name: "Light",
            species: .luminos,
            birthDate: adultBirthDate,
            health: 0.9
        )
        luminos.updateLifeStage()

        var fluffkins = Pet(
            name: "Fluffy",
            species: .fluffkins,
            birthDate: adultBirthDate,
            health: 0.9
        )
        fluffkins.updateLifeStage()

        let result = await breedingSystem.breed(luminos, fluffkins)

        switch result {
        case .success:
            XCTFail("Breeding should fail for different species")

        case .failure(let error):
            if case BreedingError.speciesMismatch = error {
                // Expected error
            } else {
                XCTFail("Wrong error type: \(error)")
            }
        }
    }

    func testOffspringGeneticsInheritance() async {
        let adultBirthDate = Date().addingTimeInterval(-86400 * 120)

        // Create parents with specific traits
        let parent1Genetics = GeneticData(
            traits: [
                GeneticTrait(name: "Blue Eyes", dominance: .dominant, rarity: .common)
            ],
            generation: 0
        )

        let parent2Genetics = GeneticData(
            traits: [
                GeneticTrait(name: "Blue Eyes", dominance: .dominant, rarity: .common)
            ],
            generation: 0
        )

        var parent1 = Pet(
            name: "Parent1",
            species: .luminos,
            birthDate: adultBirthDate,
            genetics: parent1Genetics,
            health: 0.9
        )
        parent1.updateLifeStage()

        var parent2 = Pet(
            name: "Parent2",
            species: .luminos,
            birthDate: adultBirthDate,
            genetics: parent2Genetics,
            health: 0.9
        )
        parent2.updateLifeStage()

        let result = await breedingSystem.breed(parent1, parent2)

        switch result {
        case .success(let offspring):
            // Offspring should inherit "Blue Eyes" (both parents have it)
            XCTAssertTrue(offspring.genetics.hasTrait("Blue Eyes"))
            XCTAssertEqual(offspring.genetics.generation, 1)

        case .failure:
            XCTFail("Breeding should succeed")
        }
    }

    func testOffspringPersonalityBlending() async {
        let adultBirthDate = Date().addingTimeInterval(-86400 * 120)

        let parent1Personality = PetPersonality(
            playfulness: 0.9,
            loyalty: 0.8,
            intelligence: 0.7
        )

        let parent2Personality = PetPersonality(
            playfulness: 0.3,
            loyalty: 0.4,
            intelligence: 0.5
        )

        var parent1 = Pet(
            name: "Playful",
            species: .luminos,
            birthDate: adultBirthDate,
            personality: parent1Personality,
            health: 0.9
        )
        parent1.updateLifeStage()

        var parent2 = Pet(
            name: "Calm",
            species: .luminos,
            birthDate: adultBirthDate,
            personality: parent2Personality,
            health: 0.9
        )
        parent2.updateLifeStage()

        let result = await breedingSystem.breed(parent1, parent2)

        switch result {
        case .success(let offspring):
            // Offspring personality should be between parents (with some randomness)
            // Playfulness should be roughly average of 0.9 and 0.3 = 0.6
            XCTAssertGreaterThan(offspring.personality.playfulness, 0.3)
            XCTAssertLessThan(offspring.personality.playfulness, 0.9)

            // Check that it's somewhat close to average
            let expectedPlayfulness: Float = 0.6
            XCTAssertEqual(offspring.personality.playfulness, expectedPlayfulness, accuracy: 0.3)

        case .failure:
            XCTFail("Breeding should succeed")
        }
    }

    func testBreedingPrediction() async {
        let adultBirthDate = Date().addingTimeInterval(-86400 * 120)

        let parent1Genetics = GeneticData(
            traits: [
                GeneticTrait(name: "Blue Eyes", dominance: .dominant, rarity: .common),
                GeneticTrait(name: "Fluffy Tail", dominance: .recessive, rarity: .rare)
            ],
            generation: 0
        )

        let parent2Genetics = GeneticData(
            traits: [
                GeneticTrait(name: "Blue Eyes", dominance: .dominant, rarity: .common),
                GeneticTrait(name: "Sharp Claws", dominance: .dominant, rarity: .uncommon)
            ],
            generation: 0
        )

        var parent1 = Pet(
            name: "Parent1",
            species: .luminos,
            birthDate: adultBirthDate,
            genetics: parent1Genetics,
            health: 0.9
        )
        parent1.updateLifeStage()

        var parent2 = Pet(
            name: "Parent2",
            species: .luminos,
            birthDate: adultBirthDate,
            genetics: parent2Genetics,
            health: 0.9
        )
        parent2.updateLifeStage()

        let prediction = await breedingSystem.predictOffspring(parent1, parent2)

        // Should predict "Blue Eyes" with 100% probability (both parents have it)
        let blueEyesPrediction = prediction.possibleTraits.first(where: { $0.trait.name == "Blue Eyes" })
        XCTAssertNotNil(blueEyesPrediction)
        XCTAssertEqual(blueEyesPrediction?.probability, 1.0)

        // Should predict mutation chance
        XCTAssertEqual(prediction.mutationChance, 0.05)

        // Should have personality range predictions
        XCTAssertFalse(prediction.personalityRange.playfulness.isEmpty)
    }

    func testMultipleBreedingProducesDifferentOffspring() async {
        let adultBirthDate = Date().addingTimeInterval(-86400 * 120)

        var parent1 = Pet(
            name: "Parent1",
            species: .luminos,
            birthDate: adultBirthDate,
            health: 0.9
        )
        parent1.updateLifeStage()

        var parent2 = Pet(
            name: "Parent2",
            species: .luminos,
            birthDate: adultBirthDate,
            health: 0.9
        )
        parent2.updateLifeStage()

        // Breed multiple times
        let result1 = await breedingSystem.breed(parent1, parent2)
        let result2 = await breedingSystem.breed(parent1, parent2)

        guard case .success(let offspring1) = result1,
              case .success(let offspring2) = result2 else {
            XCTFail("Breeding should succeed")
            return
        }

        // Offspring should have different IDs
        XCTAssertNotEqual(offspring1.id, offspring2.id)

        // Personalities may vary slightly
        // (Due to randomness in personality blending)
    }

    func testBreedingErrorDescriptions() {
        let errors: [BreedingError] = [
            .parentNotReady("TestPet"),
            .wrongLifeStage("TestPet", .baby),
            .insufficientHealth("TestPet", 0.3),
            .speciesMismatch,
            .sameParent
        ]

        for error in errors {
            XCTAssertFalse(error.localizedDescription.isEmpty)
        }
    }

    func testOffspringIsHealthy() async {
        let adultBirthDate = Date().addingTimeInterval(-86400 * 120)

        var parent1 = Pet(
            name: "Parent1",
            species: .luminos,
            birthDate: adultBirthDate,
            health: 0.9
        )
        parent1.updateLifeStage()

        var parent2 = Pet(
            name: "Parent2",
            species: .luminos,
            birthDate: adultBirthDate,
            health: 0.9
        )
        parent2.updateLifeStage()

        let result = await breedingSystem.breed(parent1, parent2)

        switch result {
        case .success(let offspring):
            XCTAssertEqual(offspring.health, 1.0)
            XCTAssertGreaterThan(offspring.happiness, 0.8)
            XCTAssertEqual(offspring.energy, 1.0)
            XCTAssertEqual(offspring.hunger, 1.0)

        case .failure:
            XCTFail("Breeding should succeed")
        }
    }
}
