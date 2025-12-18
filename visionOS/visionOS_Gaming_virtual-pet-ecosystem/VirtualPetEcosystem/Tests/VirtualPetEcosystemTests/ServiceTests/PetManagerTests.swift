import XCTest
@testable import VirtualPetEcosystem

@MainActor
final class PetManagerTests: XCTestCase {
    var petManager: PetManager!

    override func setUp() async throws {
        petManager = PetManager()
        petManager.clearAllPets()
    }

    override func tearDown() async throws {
        petManager.clearAllPets()
    }

    func testAddPet() {
        let pet = Pet(name: "NewPet", species: .luminos)

        petManager.addPet(pet)

        XCTAssertEqual(petManager.petCount, 1)
        XCTAssertNotNil(petManager.getPet(id: pet.id))
    }

    func testRemovePet() {
        let pet = Pet(name: "ToRemove", species: .fluffkins)

        petManager.addPet(pet)
        XCTAssertEqual(petManager.petCount, 1)

        petManager.removePet(id: pet.id)
        XCTAssertEqual(petManager.petCount, 0)
    }

    func testGetPet() {
        let pet = Pet(name: "GetTest", species: .crystalites)

        petManager.addPet(pet)

        let retrievedPet = petManager.getPet(id: pet.id)
        XCTAssertNotNil(retrievedPet)
        XCTAssertEqual(retrievedPet?.name, "GetTest")
    }

    func testUpdatePet() {
        var pet = Pet(name: "Original", species: .aquarians, happiness: 0.5)

        petManager.addPet(pet)

        // Modify pet
        pet.happiness = 0.9
        petManager.updatePet(pet)

        let updated = petManager.getPet(id: pet.id)
        XCTAssertEqual(updated?.happiness, 0.9)
    }

    func testFeedPet() {
        let pet = Pet(name: "Hungry", species: .shadowlings, hunger: 0.3)
        petManager.addPet(pet)

        let initialHunger = pet.hunger

        petManager.feedPet(id: pet.id, food: .premiumFood)

        let fed = petManager.getPet(id: pet.id)
        XCTAssertNotNil(fed)
        XCTAssertGreaterThan(fed!.hunger, initialHunger)
    }

    func testPetPet() {
        let pet = Pet(name: "Affectionate", species: .fluffkins, happiness: 0.5)
        petManager.addPet(pet)

        petManager.petPet(id: pet.id, duration: 5.0, quality: 1.0)

        let petted = petManager.getPet(id: pet.id)
        XCTAssertNotNil(petted)
        XCTAssertGreaterThan(petted!.happiness, 0.5)
    }

    func testPlayWithPet() {
        let pet = Pet(name: "Playful", species: .luminos, energy: 1.0, happiness: 0.5)
        petManager.addPet(pet)

        let success = petManager.playWithPet(id: pet.id, activity: .fetch)

        XCTAssertTrue(success)

        let played = petManager.getPet(id: pet.id)
        XCTAssertNotNil(played)
        XCTAssertGreaterThan(played!.happiness, 0.5)
        XCTAssertLessThan(played!.energy, 1.0)
    }

    func testBreedPets() async {
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

        petManager.addPet(parent1)
        petManager.addPet(parent2)

        let result = await petManager.breedPets(parent1ID: parent1.id, parent2ID: parent2.id)

        switch result {
        case .success(let offspring):
            XCTAssertEqual(petManager.petCount, 3) // 2 parents + 1 offspring
            XCTAssertNotNil(petManager.getPet(id: offspring.id))

        case .failure(let error):
            XCTFail("Breeding should succeed: \(error)")
        }
    }

    func testPredictOffspring() async {
        let adultBirthDate = Date().addingTimeInterval(-86400 * 120)

        var parent1 = Pet(name: "P1", species: .fluffkins, birthDate: adultBirthDate, health: 0.9)
        parent1.updateLifeStage()

        var parent2 = Pet(name: "P2", species: .fluffkins, birthDate: adultBirthDate, health: 0.9)
        parent2.updateLifeStage()

        petManager.addPet(parent1)
        petManager.addPet(parent2)

        let prediction = await petManager.predictOffspring(parent1ID: parent1.id, parent2ID: parent2.id)

        XCTAssertNotNil(prediction)
        XCTAssertGreaterThan(prediction!.possibleTraits.count, 0)
    }

    func testUpdateAllPets() {
        let pet = Pet(name: "NeedsUpdate", species: .crystalites, hunger: 1.0, happiness: 1.0)
        petManager.addPet(pet)

        // Simulate 1 hour passing
        petManager.updateAllPets(deltaTime: 3600)

        let updated = petManager.getPet(id: pet.id)
        XCTAssertNotNil(updated)

        // Hunger and happiness should have decayed
        XCTAssertLessThan(updated!.hunger, 1.0)
        XCTAssertLessThan(updated!.happiness, 1.0)
    }

    func testGetPetsNeedingAttention() {
        let healthyPet = Pet(name: "Healthy", species: .luminos, hunger: 0.9, happiness: 0.9, health: 0.9)
        let needyPet = Pet(name: "Needy", species: .fluffkins, hunger: 0.2, happiness: 0.9, health: 0.9)

        petManager.addPet(healthyPet)
        petManager.addPet(needyPet)

        let needingAttention = petManager.getPetsNeedingAttention()

        XCTAssertEqual(needingAttention.count, 1)
        XCTAssertEqual(needingAttention.first?.name, "Needy")
    }

    func testGetPetsBySpecies() {
        petManager.addPet(Pet(name: "Light1", species: .luminos))
        petManager.addPet(Pet(name: "Light2", species: .luminos))
        petManager.addPet(Pet(name: "Fluffy1", species: .fluffkins))

        let luminosPets = petManager.getPets(ofSpecies: .luminos)
        XCTAssertEqual(luminosPets.count, 2)

        let fluffkinsPets = petManager.getPets(ofSpecies: .fluffkins)
        XCTAssertEqual(fluffkinsPets.count, 1)
    }

    func testGetPetsByLifeStage() {
        let baby = Pet(name: "Baby", species: .luminos, birthDate: Date())

        let adultBirthDate = Date().addingTimeInterval(-86400 * 120)
        var adult = Pet(name: "Adult", species: .fluffkins, birthDate: adultBirthDate)
        adult.updateLifeStage()

        petManager.addPet(baby)
        petManager.addPet(adult)

        let babies = petManager.getPets(inLifeStage: .baby)
        XCTAssertEqual(babies.count, 1)

        let adults = petManager.getPets(inLifeStage: .adult)
        XCTAssertEqual(adults.count, 1)
    }

    func testGetBreedablePets() {
        let baby = Pet(name: "Baby", species: .luminos)

        let adultBirthDate = Date().addingTimeInterval(-86400 * 120)
        var adult = Pet(name: "Adult", species: .fluffkins, birthDate: adultBirthDate, health: 0.9)
        adult.updateLifeStage()

        petManager.addPet(baby)
        petManager.addPet(adult)

        let breedable = petManager.getBreedablePets()
        XCTAssertEqual(breedable.count, 1)
        XCTAssertEqual(breedable.first?.name, "Adult")
    }

    func testAverageHappiness() {
        petManager.addPet(Pet(name: "Happy", species: .luminos, happiness: 0.8))
        petManager.addPet(Pet(name: "VeryHappy", species: .fluffkins, happiness: 1.0))

        let average = petManager.averageHappiness
        XCTAssertEqual(average, 0.9, accuracy: 0.01)
    }

    func testAverageHealth() {
        petManager.addPet(Pet(name: "Healthy", species: .crystalites, health: 0.9))
        petManager.addPet(Pet(name: "VerHealthy", species: .aquarians, health: 1.0))

        let average = petManager.averageHealth
        XCTAssertEqual(average, 0.95, accuracy: 0.01)
    }

    func testTotalExperience() {
        var pet1 = Pet(name: "Experienced", species: .shadowlings)
        pet1.experience = 100

        var pet2 = Pet(name: "Expert", species: .luminos)
        pet2.experience = 250

        petManager.addPet(pet1)
        petManager.addPet(pet2)

        XCTAssertEqual(petManager.totalExperience, 350)
    }

    func testGetSpeciesDistribution() {
        petManager.addPet(Pet(name: "L1", species: .luminos))
        petManager.addPet(Pet(name: "L2", species: .luminos))
        petManager.addPet(Pet(name: "F1", species: .fluffkins))
        petManager.addPet(Pet(name: "C1", species: .crystalites))

        let distribution = petManager.getSpeciesDistribution()

        XCTAssertEqual(distribution[.luminos], 2)
        XCTAssertEqual(distribution[.fluffkins], 1)
        XCTAssertEqual(distribution[.crystalites], 1)
        XCTAssertNil(distribution[.aquarians])
    }

    func testClearAllPets() {
        petManager.addPet(Pet(name: "Pet1", species: .luminos))
        petManager.addPet(Pet(name: "Pet2", species: .fluffkins))

        XCTAssertEqual(petManager.petCount, 2)

        petManager.clearAllPets()

        XCTAssertEqual(petManager.petCount, 0)
    }

    func testPetCountStartsAtZero() {
        XCTAssertEqual(petManager.petCount, 0)
    }

    func testAveragesWithNoPets() {
        XCTAssertEqual(petManager.averageHappiness, 0)
        XCTAssertEqual(petManager.averageHealth, 0)
        XCTAssertEqual(petManager.totalExperience, 0)
    }
}
