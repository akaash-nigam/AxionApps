import XCTest
@testable import VirtualPetEcosystem

final class PetTests: XCTestCase {
    func testPetCreation() {
        let pet = Pet(name: "Sparky", species: .luminos)

        XCTAssertEqual(pet.name, "Sparky")
        XCTAssertEqual(pet.species, .luminos)
        XCTAssertEqual(pet.lifeStage, .baby)
        XCTAssertEqual(pet.health, 1.0)
        XCTAssertEqual(pet.happiness, 0.8)
        XCTAssertEqual(pet.energy, 1.0)
        XCTAssertEqual(pet.hunger, 1.0)
    }

    func testUniqueIdentifiers() {
        let pet1 = Pet(name: "Pet1", species: .luminos)
        let pet2 = Pet(name: "Pet2", species: .fluffkins)

        XCTAssertNotEqual(pet1.id, pet2.id)
    }

    func testSpeciesAppropriatePersonality() {
        let luminos = Pet(name: "Light", species: .luminos)
        let shadowling = Pet(name: "Shadow", species: .shadowlings)

        // Luminos should be more extraverted
        XCTAssertGreaterThan(luminos.personality.extraversion, shadowling.personality.extraversion)

        let fluffkins = Pet(name: "Fluffy", species: .fluffkins)
        // Fluffkins should be more loyal and affectionate
        XCTAssertGreaterThan(fluffkins.personality.loyalty, 0.5)
    }

    func testFeeding() {
        var pet = Pet(name: "Hungry", species: .luminos, hunger: 0.3)
        let initialHunger = pet.hunger
        let initialExperience = pet.experience

        pet.feed(food: .premiumFood)

        XCTAssertGreaterThan(pet.hunger, initialHunger)
        XCTAssertGreaterThan(pet.experience, initialExperience)
        XCTAssertNotNil(pet.lastFedTime)
        XCTAssertNotNil(pet.lastInteractionTime)
    }

    func testFeedingIncreasesHappiness() {
        var pet = Pet(name: "Test", species: .fluffkins, happiness: 0.5)
        let initialHappiness = pet.happiness

        pet.feed(food: .treat) // Treats give high happiness bonus

        XCTAssertGreaterThan(pet.happiness, initialHappiness)
    }

    func testFeedingDoesNotExceedMaxHunger() {
        var pet = Pet(name: "Full", species: .luminos, hunger: 0.95)

        pet.feed(food: .premiumFood) // +0.5 nutrition

        XCTAssertLessThanOrEqual(pet.hunger, 1.0)
    }

    func testPetting() {
        var pet = Pet(name: "Affectionate", species: .fluffkins)
        let initialHappiness = pet.happiness

        pet.pet(duration: 5.0, quality: 1.0)

        XCTAssertGreaterThan(pet.happiness, initialHappiness)
        XCTAssertNotNil(pet.lastPettedTime)
        XCTAssertNotNil(pet.lastInteractionTime)
    }

    func testPettingQuality() {
        var highQualityPet = Pet(name: "A", species: .luminos, happiness: 0.5)
        var lowQualityPet = Pet(name: "B", species: .luminos, happiness: 0.5)

        highQualityPet.pet(duration: 5.0, quality: 1.0)
        lowQualityPet.pet(duration: 5.0, quality: 0.5)

        XCTAssertGreaterThan(highQualityPet.happiness, lowQualityPet.happiness)
    }

    func testPlaying() {
        var pet = Pet(name: "Playful", species: .luminos, energy: 1.0, happiness: 0.5)
        let initialEnergy = pet.energy
        let initialHappiness = pet.happiness

        let success = pet.play(activity: .fetch)

        XCTAssertTrue(success)
        XCTAssertLessThan(pet.energy, initialEnergy)
        XCTAssertGreaterThan(pet.happiness, initialHappiness)
        XCTAssertNotNil(pet.lastPlayedTime)
    }

    func testPlayingRequiresEnergy() {
        var pet = Pet(name: "Tired", species: .luminos, energy: 0.1)

        let success = pet.play(activity: .fetch) // Costs 0.2 energy

        XCTAssertFalse(success, "Should fail when not enough energy")
    }

    func testNeedDecay() {
        var pet = Pet(name: "Aging", species: .luminos, hunger: 1.0, happiness: 1.0, energy: 0.5)

        // Simulate 1 hour
        pet.updateNeeds(deltaTime: 3600)

        // Hunger and happiness should decrease
        XCTAssertLessThan(pet.hunger, 1.0)
        XCTAssertLessThan(pet.happiness, 1.0)

        // Energy should increase (resting)
        XCTAssertGreaterThan(pet.energy, 0.5)
    }

    func testNeedDecayAffectsHealth() {
        var pet = Pet(name: "Neglected", species: .luminos, hunger: 0.1, happiness: 0.1, health: 1.0)

        // Simulate several hours
        pet.updateNeeds(deltaTime: 3600 * 5)

        // Health should decrease due to low hunger and happiness
        XCTAssertLessThan(pet.health, 1.0)
    }

    func testAging() {
        let birthDate = Date().addingTimeInterval(-86400 * 35) // 35 days ago
        var pet = Pet(name: "Older", species: .luminos, birthDate: birthDate)

        XCTAssertEqual(pet.ageInDays, 35, accuracy: 0.1)

        pet.updateLifeStage()

        XCTAssertEqual(pet.lifeStage, .youth)
    }

    func testLifeStageProgression() {
        // Baby
        var babyPet = Pet(name: "Baby", species: .luminos, birthDate: Date())
        babyPet.updateLifeStage()
        XCTAssertEqual(babyPet.lifeStage, .baby)

        // Youth
        let youthBirthDate = Date().addingTimeInterval(-86400 * 45)
        var youthPet = Pet(name: "Youth", species: .luminos, birthDate: youthBirthDate)
        youthPet.updateLifeStage()
        XCTAssertEqual(youthPet.lifeStage, .youth)

        // Adult
        let adultBirthDate = Date().addingTimeInterval(-86400 * 120)
        var adultPet = Pet(name: "Adult", species: .luminos, birthDate: adultBirthDate)
        adultPet.updateLifeStage()
        XCTAssertEqual(adultPet.lifeStage, .adult)

        // Elder
        let elderBirthDate = Date().addingTimeInterval(-86400 * 400)
        var elderPet = Pet(name: "Elder", species: .luminos, birthDate: elderBirthDate)
        elderPet.updateLifeStage()
        XCTAssertEqual(elderPet.lifeStage, .elder)
    }

    func testBreedingRequirements() {
        // Baby cannot breed
        let baby = Pet(name: "Baby", species: .luminos, birthDate: Date())
        XCTAssertFalse(baby.canBreed)

        // Adult with good health can breed
        let adultBirthDate = Date().addingTimeInterval(-86400 * 100)
        var adult = Pet(name: "Adult", species: .luminos, birthDate: adultBirthDate, health: 0.8)
        adult.updateLifeStage()
        XCTAssertTrue(adult.canBreed)

        // Adult with low health cannot breed
        adult.health = 0.3
        XCTAssertFalse(adult.canBreed)
    }

    func testExperienceAndLeveling() {
        var pet = Pet(name: "Leveling", species: .luminos)

        XCTAssertEqual(pet.level, 1)

        // Gain experience through interactions
        pet.feed(food: .premiumFood)
        pet.pet(duration: 5.0)
        _ = pet.play(activity: .fetch)

        XCTAssertGreaterThan(pet.experience, 0)

        // Add enough experience to level up
        pet.experience = 500
        XCTAssertGreaterThan(pet.level, 1)
    }

    func testEmotionalStateUpdates() {
        var pet = Pet(name: "Emotional", species: .luminos)

        // High happiness and energy = happy
        pet.happiness = 0.9
        pet.energy = 0.8
        pet.hunger = 0.8
        pet.updateEmotionalState()

        XCTAssertEqual(pet.emotionalState.primaryEmotion, .happy)

        // Low hunger = hungry
        pet.hunger = 0.2
        pet.updateEmotionalState()

        XCTAssertEqual(pet.emotionalState.primaryEmotion, .hungry)
    }

    func testOverallStatus() {
        let pet = Pet(
            name: "Balanced",
            species: .luminos,
            health: 0.8,
            happiness: 0.7,
            energy: 0.9,
            hunger: 0.8
        )

        let expectedStatus = (0.8 + 0.7 + 0.9 + 0.8) / 4.0
        XCTAssertEqual(pet.overallStatus, expectedStatus, accuracy: 0.01)
    }

    func testNeedsAttention() {
        var pet = Pet(name: "Needs", species: .luminos, hunger: 0.9, happiness: 0.9, health: 0.9)

        XCTAssertFalse(pet.needsAttention)

        pet.hunger = 0.2
        XCTAssertTrue(pet.needsAttention)

        pet.hunger = 0.9
        pet.happiness = 0.2
        XCTAssertTrue(pet.needsAttention)

        pet.happiness = 0.9
        pet.health = 0.3
        XCTAssertTrue(pet.needsAttention)
    }

    func testSummary() {
        let pet = Pet(name: "Sparky", species: .luminos)
        let summary = pet.summary()

        XCTAssertTrue(summary.contains("Sparky"))
        XCTAssertTrue(summary.contains("Luminos"))
        XCTAssertTrue(summary.contains("Baby"))
    }

    func testCodable() throws {
        let pet = Pet(
            name: "Codable",
            species: .fluffkins,
            happiness: 0.7,
            hunger: 0.8
        )

        // Encode
        let encoder = JSONEncoder()
        let data = try encoder.encode(pet)

        // Decode
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(Pet.self, from: data)

        XCTAssertEqual(decoded.id, pet.id)
        XCTAssertEqual(decoded.name, pet.name)
        XCTAssertEqual(decoded.species, pet.species)
        XCTAssertEqual(decoded.happiness, pet.happiness)
        XCTAssertEqual(decoded.hunger, pet.hunger)
    }

    func testEquality() {
        let id = UUID()
        let pet1 = Pet(id: id, name: "Same", species: .luminos)
        let pet2 = Pet(id: id, name: "Different Name", species: .fluffkins)

        XCTAssertEqual(pet1, pet2, "Pets with same ID should be equal")

        let pet3 = Pet(name: "Other", species: .luminos)
        XCTAssertNotEqual(pet1, pet3, "Pets with different IDs should not be equal")
    }

    func testHashable() {
        let pet1 = Pet(name: "Hash1", species: .luminos)
        let pet2 = Pet(name: "Hash2", species: .fluffkins)

        var set = Set<Pet>()
        set.insert(pet1)
        set.insert(pet2)

        XCTAssertEqual(set.count, 2)
        XCTAssertTrue(set.contains(pet1))
        XCTAssertTrue(set.contains(pet2))
    }

    func testPersonalityEvolutionThroughCare() {
        var pet = Pet(name: "Evolving", species: .luminos)
        let initialPlayfulness = pet.personality.playfulness

        // Play multiple times
        for _ in 0..<10 {
            _ = pet.play(activity: .fetch)
        }

        XCTAssertGreaterThan(pet.personality.playfulness, initialPlayfulness)
    }
}
