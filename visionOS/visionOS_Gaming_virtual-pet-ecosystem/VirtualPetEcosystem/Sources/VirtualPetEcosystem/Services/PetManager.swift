import Foundation

/// Manages the collection of pets and their lifecycle
@MainActor
public class PetManager: ObservableObject {
    /// All pets currently managed
    @Published public private(set) var pets: [Pet] = []

    /// Persistence manager for saving/loading
    private let persistenceManager = PersistenceManager()

    /// Breeding system
    private let breedingSystem = BreedingSystem()

    /// Last update time for need decay
    private var lastUpdateTime: Date = Date()

    public init() {}

    // MARK: - Pet Management

    /// Add a new pet
    /// - Parameter pet: The pet to add
    public func addPet(_ pet: Pet) {
        pets.append(pet)
        Task {
            try? await persistenceManager.save(pet)
        }
    }

    /// Remove a pet
    /// - Parameter id: UUID of the pet to remove
    public func removePet(id: UUID) {
        pets.removeAll { $0.id == id }
        Task {
            try? await persistenceManager.deletePet(id: id)
        }
    }

    /// Get a pet by ID
    /// - Parameter id: UUID of the pet
    /// - Returns: The pet if found
    public func getPet(id: UUID) -> Pet? {
        pets.first { $0.id == id }
    }

    /// Update a pet
    /// - Parameter pet: The updated pet
    public func updatePet(_ pet: Pet) {
        if let index = pets.firstIndex(where: { $0.id == pet.id }) {
            pets[index] = pet
            Task {
                try? await persistenceManager.save(pet)
            }
        }
    }

    // MARK: - Pet Care

    /// Feed a pet
    /// - Parameters:
    ///   - id: UUID of the pet to feed
    ///   - food: Type of food to give
    public func feedPet(id: UUID, food: FoodType) {
        guard let index = pets.firstIndex(where: { $0.id == id }) else { return }

        pets[index].feed(food: food)

        Task {
            try? await persistenceManager.save(pets[index])
        }
    }

    /// Pet a pet
    /// - Parameters:
    ///   - id: UUID of the pet to pet
    ///   - duration: How long to pet (seconds)
    ///   - quality: Quality of petting (0.0 - 1.0)
    public func petPet(id: UUID, duration: TimeInterval, quality: Float = 1.0) {
        guard let index = pets.firstIndex(where: { $0.id == id }) else { return }

        pets[index].pet(duration: duration, quality: quality)

        Task {
            try? await persistenceManager.save(pets[index])
        }
    }

    /// Play with a pet
    /// - Parameters:
    ///   - id: UUID of the pet
    ///   - activity: Type of play activity
    /// - Returns: True if play was successful
    @discardableResult
    public func playWithPet(id: UUID, activity: PlayActivity) -> Bool {
        guard let index = pets.firstIndex(where: { $0.id == id }) else { return false }

        let success = pets[index].play(activity: activity)

        if success {
            Task {
                try? await persistenceManager.save(pets[index])
            }
        }

        return success
    }

    // MARK: - Breeding

    /// Breed two pets
    /// - Parameters:
    ///   - parent1ID: UUID of first parent
    ///   - parent2ID: UUID of second parent
    /// - Returns: Result containing the offspring or error
    public func breedPets(parent1ID: UUID, parent2ID: UUID) async -> Result<Pet, BreedingError> {
        guard let parent1 = getPet(id: parent1ID),
              let parent2 = getPet(id: parent2ID) else {
            return .failure(.parentNotReady("Pet not found"))
        }

        let result = await breedingSystem.breed(parent1, parent2)

        if case .success(let offspring) = result {
            addPet(offspring)
        }

        return result
    }

    /// Predict offspring from two pets
    /// - Parameters:
    ///   - parent1ID: UUID of first parent
    ///   - parent2ID: UUID of second parent
    /// - Returns: Breeding prediction if both pets exist
    public func predictOffspring(parent1ID: UUID, parent2ID: UUID) async -> BreedingPrediction? {
        guard let parent1 = getPet(id: parent1ID),
              let parent2 = getPet(id: parent2ID) else {
            return nil
        }

        return await breedingSystem.predictOffspring(parent1, parent2)
    }

    // MARK: - Lifecycle Management

    /// Update all pets (call regularly to update needs and age)
    /// - Parameter deltaTime: Time since last update (optional, uses actual time if nil)
    public func updateAllPets(deltaTime: TimeInterval? = nil) {
        let now = Date()
        let actualDelta = deltaTime ?? now.timeIntervalSince(lastUpdateTime)
        lastUpdateTime = now

        for index in pets.indices {
            // Update needs
            pets[index].updateNeeds(deltaTime: actualDelta)

            // Update life stage
            pets[index].updateLifeStage()
        }

        // Save all updated pets
        Task {
            try? await persistenceManager.save(pets)
        }
    }

    /// Get pets that need attention
    /// - Returns: Array of pets needing care
    public func getPetsNeedingAttention() -> [Pet] {
        pets.filter { $0.needsAttention }
    }

    /// Get pets by species
    /// - Parameter species: Species to filter by
    /// - Returns: Array of pets of that species
    public func getPets(ofSpecies species: PetSpecies) -> [Pet] {
        pets.filter { $0.species == species }
    }

    /// Get pets by life stage
    /// - Parameter lifeStage: Life stage to filter by
    /// - Returns: Array of pets in that life stage
    public func getPets(inLifeStage lifeStage: LifeStage) -> [Pet] {
        pets.filter { $0.lifeStage == lifeStage }
    }

    /// Get breedable pets
    /// - Returns: Array of pets that can breed
    public func getBreedablePets() -> [Pet] {
        pets.filter { $0.canBreed }
    }

    // MARK: - Persistence

    /// Save all pets to disk
    public func saveAllPets() async throws {
        try await persistenceManager.save(pets)
    }

    /// Load all pets from disk
    public func loadAllPets() async throws {
        let loadedPets = try await persistenceManager.loadAllPets()
        pets = loadedPets
    }

    /// Clear all pets (use with caution!)
    public func clearAllPets() {
        pets.removeAll()
        Task {
            try? await persistenceManager.deleteAllPets()
        }
    }

    // MARK: - Statistics

    /// Get total count of pets
    public var petCount: Int {
        pets.count
    }

    /// Get average happiness across all pets
    public var averageHappiness: Float {
        guard !pets.isEmpty else { return 0 }
        return pets.reduce(0) { $0 + $1.happiness } / Float(pets.count)
    }

    /// Get average health across all pets
    public var averageHealth: Float {
        guard !pets.isEmpty else { return 0 }
        return pets.reduce(0) { $0 + $1.health } / Float(pets.count)
    }

    /// Get total experience points across all pets
    public var totalExperience: Int {
        pets.reduce(0) { $0 + $1.experience }
    }

    /// Get species distribution
    /// - Returns: Dictionary of species to count
    public func getSpeciesDistribution() -> [PetSpecies: Int] {
        var distribution: [PetSpecies: Int] = [:]

        for pet in pets {
            distribution[pet.species, default: 0] += 1
        }

        return distribution
    }
}
