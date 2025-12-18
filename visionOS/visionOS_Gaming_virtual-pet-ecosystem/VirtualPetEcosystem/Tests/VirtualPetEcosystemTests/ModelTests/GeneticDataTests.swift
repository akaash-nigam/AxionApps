import XCTest
@testable import VirtualPetEcosystem

final class GeneticDataTests: XCTestCase {
    func testRandomGeneration() {
        let genetics = GeneticData.random(for: .luminos)

        XCTAssertGreaterThan(genetics.traits.count, 0)
        XCTAssertEqual(genetics.generation, 0)
        XCTAssertTrue(genetics.parentIDs.isEmpty)
    }

    func testSpeciesBaseTraits() {
        let luminosGenetics = GeneticData.random(for: .luminos)
        let fluffkinsGenetics = GeneticData.random(for: .fluffkins)

        // Luminos should have light-related traits
        XCTAssertTrue(luminosGenetics.hasTrait("Bioluminescence") || luminosGenetics.hasTrait("Light Affinity"))

        // Fluffkins should have fur-related traits
        XCTAssertTrue(fluffkinsGenetics.hasTrait("Dense Fur") || fluffkinsGenetics.hasTrait("Soft Coat"))
    }

    func testTraitInheritance() {
        let parent1 = GeneticData(
            traits: [
                GeneticTrait(name: "Blue Eyes", dominance: .dominant, rarity: .common),
                GeneticTrait(name: "Fluffy Tail", dominance: .recessive, rarity: .uncommon)
            ],
            generation: 0
        )

        let parent2 = GeneticData(
            traits: [
                GeneticTrait(name: "Blue Eyes", dominance: .dominant, rarity: .common),
                GeneticTrait(name: "Sharp Claws", dominance: .dominant, rarity: .rare)
            ],
            generation: 0
        )

        let offspring = GeneticData.combine(parent1, parent2)

        // Offspring should definitely have "Blue Eyes" (both parents have it)
        XCTAssertTrue(offspring.hasTrait("Blue Eyes"))

        // Generation should be incremented
        XCTAssertEqual(offspring.generation, 1)
    }

    func testMultipleGenerations() {
        let gen0Parent1 = GeneticData(traits: [], generation: 0)
        let gen0Parent2 = GeneticData(traits: [], generation: 0)

        let gen1 = GeneticData.combine(gen0Parent1, gen0Parent2)
        XCTAssertEqual(gen1.generation, 1)

        let gen2Parent2 = GeneticData(traits: [], generation: 1)
        let gen2 = GeneticData.combine(gen1, gen2Parent2)
        XCTAssertEqual(gen2.generation, 2)
    }

    func testTraitRarities() {
        for rarity in TraitRarity.allCases {
            XCTAssertFalse(rarity.colorHex.isEmpty)
            XCTAssertFalse(rarity.emoji.isEmpty)
        }

        XCTAssertEqual(TraitRarity.common.emoji, "⚪")
        XCTAssertEqual(TraitRarity.legendary.emoji, "🟠")
    }

    func testMutations() {
        let mutation = Mutation.random()

        XCTAssertFalse(mutation.name.isEmpty)
        XCTAssertNotNil(mutation.effect)
    }

    func testRandomTraitGeneration() {
        // Generate multiple random traits and verify they're valid
        for _ in 0..<10 {
            if let trait = GeneticTrait.random() {
                XCTAssertFalse(trait.name.isEmpty)
                XCTAssertTrue([Dominance.dominant, Dominance.recessive].contains(trait.dominance))
            }
        }
    }

    func testHasTrait() {
        let genetics = GeneticData(
            traits: [
                GeneticTrait(name: "Sparkle", dominance: .dominant, rarity: .rare)
            ]
        )

        XCTAssertTrue(genetics.hasTrait("Sparkle"))
        XCTAssertFalse(genetics.hasTrait("Glow"))
    }

    func testCountTraitsByRarity() {
        let genetics = GeneticData(
            traits: [
                GeneticTrait(name: "Common1", dominance: .dominant, rarity: .common),
                GeneticTrait(name: "Common2", dominance: .dominant, rarity: .common),
                GeneticTrait(name: "Rare1", dominance: .recessive, rarity: .rare),
                GeneticTrait(name: "Legendary1", dominance: .recessive, rarity: .legendary)
            ]
        )

        XCTAssertEqual(genetics.countTraits(ofRarity: .common), 2)
        XCTAssertEqual(genetics.countTraits(ofRarity: .rare), 1)
        XCTAssertEqual(genetics.countTraits(ofRarity: .legendary), 1)
        XCTAssertEqual(genetics.countTraits(ofRarity: .uncommon), 0)
    }

    func testTraitNames() {
        let genetics = GeneticData(
            traits: [
                GeneticTrait(name: "Trait1", dominance: .dominant, rarity: .common),
                GeneticTrait(name: "Trait2", dominance: .recessive, rarity: .rare)
            ]
        )

        let names = genetics.traitNames
        XCTAssertEqual(names.count, 2)
        XCTAssertTrue(names.contains("Trait1"))
        XCTAssertTrue(names.contains("Trait2"))
    }

    func testCodable() throws {
        let genetics = GeneticData(
            traits: [
                GeneticTrait(name: "Test Trait", dominance: .dominant, rarity: .rare)
            ],
            mutations: [
                Mutation(name: "Test Mutation", effect: .newTrait)
            ],
            generation: 2
        )

        // Encode
        let encoder = JSONEncoder()
        let data = try encoder.encode(genetics)

        // Decode
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(GeneticData.self, from: data)

        XCTAssertEqual(decoded.generation, 2)
        XCTAssertEqual(decoded.traits.count, 1)
        XCTAssertEqual(decoded.traits.first?.name, "Test Trait")
        XCTAssertEqual(decoded.mutations.count, 1)
    }

    func testDominanceInheritance() {
        // Test that dominant traits have higher inheritance probability
        var dominantInheritances = 0
        var recessiveInheritances = 0
        let trials = 1000

        for _ in 0..<trials {
            let parent1 = GeneticData(
                traits: [GeneticTrait(name: "Dominant", dominance: .dominant, rarity: .common)],
                generation: 0
            )
            let parent2 = GeneticData(traits: [], generation: 0)

            let offspring = GeneticData.combine(parent1, parent2)

            if offspring.hasTrait("Dominant") {
                dominantInheritances += 1
            }
        }

        for _ in 0..<trials {
            let parent1 = GeneticData(
                traits: [GeneticTrait(name: "Recessive", dominance: .recessive, rarity: .common)],
                generation: 0
            )
            let parent2 = GeneticData(traits: [], generation: 0)

            let offspring = GeneticData.combine(parent1, parent2)

            if offspring.hasTrait("Recessive") {
                recessiveInheritances += 1
            }
        }

        // Dominant should inherit ~50% of the time, recessive ~25%
        // Allow some variance in randomness
        XCTAssertGreaterThan(dominantInheritances, trials / 3) // At least 33%
        XCTAssertLessThan(recessiveInheritances, trials / 2) // Less than 50%
        XCTAssertGreaterThan(dominantInheritances, recessiveInheritances) // Dominant > Recessive
    }
}
