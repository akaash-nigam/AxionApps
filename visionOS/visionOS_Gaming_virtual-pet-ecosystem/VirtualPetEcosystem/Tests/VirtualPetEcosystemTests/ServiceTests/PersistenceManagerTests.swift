import XCTest
@testable import VirtualPetEcosystem

final class PersistenceManagerTests: XCTestCase {
    var persistenceManager: PersistenceManager!

    override func setUp() async throws {
        persistenceManager = PersistenceManager()
        // Clean up any existing test data
        try? await persistenceManager.deleteAllPets()
    }

    override func tearDown() async throws {
        // Clean up test data
        try? await persistenceManager.deleteAllPets()
    }

    func testSavePet() async throws {
        let pet = Pet(name: "TestPet", species: .luminos)

        try await persistenceManager.save(pet)

        // Verify pet was saved
        let exists = await persistenceManager.petExists(id: pet.id)
        XCTAssertTrue(exists)
    }

    func testLoadPet() async throws {
        let pet = Pet(name: "LoadTest", species: .fluffkins, health: 0.8, happiness: 0.7)

        // Save pet
        try await persistenceManager.save(pet)

        // Load pet
        let loadedPet = try await persistenceManager.loadPet(id: pet.id)

        XCTAssertEqual(loadedPet.id, pet.id)
        XCTAssertEqual(loadedPet.name, pet.name)
        XCTAssertEqual(loadedPet.species, pet.species)
        XCTAssertEqual(loadedPet.health, pet.health)
        XCTAssertEqual(loadedPet.happiness, pet.happiness)
    }

    func testLoadNonexistentPet() async {
        let randomID = UUID()

        do {
            _ = try await persistenceManager.loadPet(id: randomID)
            XCTFail("Should throw petNotFound error")
        } catch PersistenceError.petNotFound(let id) {
            XCTAssertEqual(id, randomID)
        } catch {
            XCTFail("Wrong error type: \(error)")
        }
    }

    func testSaveMultiplePets() async throws {
        let pets = [
            Pet(name: "Pet1", species: .luminos),
            Pet(name: "Pet2", species: .fluffkins),
            Pet(name: "Pet3", species: .crystalites)
        ]

        try await persistenceManager.save(pets)

        let count = try await persistenceManager.getSavedPetCount()
        XCTAssertEqual(count, 3)
    }

    func testLoadAllPets() async throws {
        let pets = [
            Pet(name: "Pet1", species: .luminos),
            Pet(name: "Pet2", species: .fluffkins)
        ]

        try await persistenceManager.save(pets)

        let loadedPets = try await persistenceManager.loadAllPets()

        XCTAssertEqual(loadedPets.count, 2)
        XCTAssertTrue(loadedPets.contains { $0.name == "Pet1" })
        XCTAssertTrue(loadedPets.contains { $0.name == "Pet2" })
    }

    func testDeletePet() async throws {
        let pet = Pet(name: "ToDelete", species: .shadowlings)

        // Save pet
        try await persistenceManager.save(pet)

        // Verify it exists
        XCTAssertTrue(await persistenceManager.petExists(id: pet.id))

        // Delete pet
        try await persistenceManager.deletePet(id: pet.id)

        // Verify it's gone
        XCTAssertFalse(await persistenceManager.petExists(id: pet.id))
    }

    func testDeleteAllPets() async throws {
        let pets = [
            Pet(name: "Pet1", species: .luminos),
            Pet(name: "Pet2", species: .fluffkins),
            Pet(name: "Pet3", species: .crystalites)
        ]

        try await persistenceManager.save(pets)

        // Verify all exist
        var count = try await persistenceManager.getSavedPetCount()
        XCTAssertEqual(count, 3)

        // Delete all
        try await persistenceManager.deleteAllPets()

        // Verify all gone
        count = try await persistenceManager.getSavedPetCount()
        XCTAssertEqual(count, 0)
    }

    func testPetExists() async throws {
        let pet = Pet(name: "ExistsTest", species: .aquarians)

        // Should not exist initially
        XCTAssertFalse(await persistenceManager.petExists(id: pet.id))

        // Save pet
        try await persistenceManager.save(pet)

        // Should exist now
        XCTAssertTrue(await persistenceManager.petExists(id: pet.id))
    }

    func testGetSavedPetCount() async throws {
        // Should be 0 initially
        var count = try await persistenceManager.getSavedPetCount()
        XCTAssertEqual(count, 0)

        // Add pets one by one
        for i in 1...5 {
            let pet = Pet(name: "Pet\(i)", species: .luminos)
            try await persistenceManager.save(pet)
        }

        count = try await persistenceManager.getSavedPetCount()
        XCTAssertEqual(count, 5)
    }

    func testPersistenceAcrossReload() async throws {
        // Create and save pet
        let originalPet = Pet(
            name: "Persistent",
            species: .luminos,
            health: 0.9,
            happiness: 0.85,
            energy: 0.7,
            hunger: 0.6
        )

        try await persistenceManager.save(originalPet)

        // Create new persistence manager (simulating app restart)
        let newPersistenceManager = PersistenceManager()

        // Load pet with new manager
        let loadedPet = try await newPersistenceManager.loadPet(id: originalPet.id)

        // Verify all data persisted correctly
        XCTAssertEqual(loadedPet.id, originalPet.id)
        XCTAssertEqual(loadedPet.name, originalPet.name)
        XCTAssertEqual(loadedPet.species, originalPet.species)
        XCTAssertEqual(loadedPet.health, originalPet.health, accuracy: 0.001)
        XCTAssertEqual(loadedPet.happiness, originalPet.happiness, accuracy: 0.001)
        XCTAssertEqual(loadedPet.energy, originalPet.energy, accuracy: 0.001)
        XCTAssertEqual(loadedPet.hunger, originalPet.hunger, accuracy: 0.001)
    }

    func testPersonalityPersistence() async throws {
        let personality = PetPersonality(
            openness: 0.8,
            playfulness: 0.9,
            loyalty: 0.7
        )

        let pet = Pet(
            name: "PersonalityTest",
            species: .fluffkins,
            personality: personality
        )

        try await persistenceManager.save(pet)

        let loadedPet = try await persistenceManager.loadPet(id: pet.id)

        XCTAssertEqual(loadedPet.personality.openness, 0.8, accuracy: 0.001)
        XCTAssertEqual(loadedPet.personality.playfulness, 0.9, accuracy: 0.001)
        XCTAssertEqual(loadedPet.personality.loyalty, 0.7, accuracy: 0.001)
    }

    func testGeneticsPersistence() async throws {
        let genetics = GeneticData(
            traits: [
                GeneticTrait(name: "Blue Eyes", dominance: .dominant, rarity: .common)
            ],
            generation: 2
        )

        let pet = Pet(
            name: "GeneticsTest",
            species: .crystalites,
            genetics: genetics
        )

        try await persistenceManager.save(pet)

        let loadedPet = try await persistenceManager.loadPet(id: pet.id)

        XCTAssertEqual(loadedPet.genetics.generation, 2)
        XCTAssertTrue(loadedPet.genetics.hasTrait("Blue Eyes"))
    }

    func testLoadAllPetsEmptyDirectory() async throws {
        // Delete all pets first
        try await persistenceManager.deleteAllPets()

        let pets = try await persistenceManager.loadAllPets()

        XCTAssertTrue(pets.isEmpty)
    }
}
