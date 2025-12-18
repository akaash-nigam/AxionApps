import Foundation

/// Represents a persistent virtual pet with spatial awareness
public struct Pet: Codable, Identifiable, Sendable {
    // MARK: - Identity

    public let id: UUID
    public var name: String
    public let species: PetSpecies
    public let birthDate: Date

    // MARK: - Life Stage

    public private(set) var lifeStage: LifeStage

    // MARK: - Personality and AI

    public var personality: PetPersonality
    public var emotionalState: EmotionalState

    // MARK: - Genetics

    /// Genetic data for breeding
    public var genetics: GeneticData

    // MARK: - Physical Attributes (0.0 - 1.0)

    /// Overall health of the pet
    public var health: Float

    /// Current happiness level
    public var happiness: Float

    /// Current energy level
    public var energy: Float

    /// Hunger level (0.0 = starving, 1.0 = full)
    public var hunger: Float

    // MARK: - Timestamps

    /// Last time the pet was fed
    public var lastFedTime: Date?

    /// Last time the pet was petted
    public var lastPettedTime: Date?

    /// Last time the pet played
    public var lastPlayedTime: Date?

    /// Last time any interaction occurred
    public var lastInteractionTime: Date?

    // MARK: - Experience and Level

    /// Experience points
    public var experience: Int

    /// Current level (derived from experience)
    public var level: Int {
        experienceToLevel(experience)
    }

    // MARK: - Breeding

    /// Whether this pet can breed (adult stage only)
    public var canBreed: Bool {
        lifeStage.canBreed && health > 0.5
    }

    // MARK: - Initialization

    public init(
        id: UUID = UUID(),
        name: String,
        species: PetSpecies,
        birthDate: Date = Date(),
        personality: PetPersonality? = nil,
        genetics: GeneticData? = nil,
        health: Float = 1.0,
        happiness: Float = 0.8,
        energy: Float = 1.0,
        hunger: Float = 1.0
    ) {
        self.id = id
        self.name = name
        self.species = species
        self.birthDate = birthDate
        self.lifeStage = .baby

        // Generate species-appropriate personality if not provided
        self.personality = personality ?? PetPersonality.forSpecies(species)

        // Generate random genetics if not provided
        self.genetics = genetics ?? GeneticData.random(for: species)

        // Initialize emotional state
        self.emotionalState = EmotionalState(primaryEmotion: .content, intensity: 0.7)

        // Set initial stats
        self.health = Self.clamp(health)
        self.happiness = Self.clamp(happiness)
        self.energy = Self.clamp(energy)
        self.hunger = Self.clamp(hunger)

        // Initialize timestamps
        self.lastFedTime = nil
        self.lastPettedTime = nil
        self.lastPlayedTime = nil
        self.lastInteractionTime = nil

        // Initialize experience
        self.experience = 0
    }

    // MARK: - Aging

    /// Calculate the current age in days
    public var ageInDays: Double {
        Date().timeIntervalSince(birthDate) / 86400.0
    }

    /// Update life stage based on current age
    public mutating func updateLifeStage() {
        let newStage = LifeStage.stage(for: ageInDays)

        if newStage != lifeStage {
            lifeStage = newStage
            onLifeStageChange(to: newStage)
        }
    }

    /// Called when life stage changes
    private mutating func onLifeStageChange(to newStage: LifeStage) {
        switch newStage {
        case .baby:
            break

        case .youth:
            personality.independence += 0.1
            experience += 100

        case .adult:
            personality.independence += 0.2
            experience += 200

        case .elder:
            personality.independence += 0.1
            experience += 300
        }
    }

    // MARK: - Need Decay

    /// Update pet needs based on time elapsed
    public mutating func updateNeeds(deltaTime: TimeInterval) {
        let hours = Float(deltaTime / 3600.0)

        // Decay rates (per hour)
        let hungerDecay: Float = 0.1
        let happinessDecay: Float = 0.05
        let energyRecovery: Float = 0.1

        // Apply decay
        hunger = Self.clamp(hunger - (hungerDecay * hours))
        happiness = Self.clamp(happiness - (happinessDecay * hours))

        // Energy recovery if not playing
        if let lastPlayed = lastPlayedTime {
            let timeSincePlay = Date().timeIntervalSince(lastPlayed) / 3600.0
            if timeSincePlay > 1.0 { // Resting for > 1 hour
                energy = Self.clamp(energy + (energyRecovery * hours))
            }
        } else {
            energy = Self.clamp(energy + (energyRecovery * hours))
        }

        // Update health based on needs
        if hunger < 0.2 || happiness < 0.2 {
            health = Self.clamp(health - 0.01 * hours)
        } else if hunger > 0.8 && happiness > 0.8 {
            health = Self.clamp(health + 0.01 * hours)
        }

        // Update emotional state
        updateEmotionalState()
    }

    /// Update emotional state based on current needs
    public mutating func updateEmotionalState() {
        emotionalState = EmotionalState.calculate(
            hunger: hunger,
            happiness: happiness,
            energy: energy,
            health: health,
            lastInteractionTime: lastInteractionTime
        )
    }

    // MARK: - Care Actions

    /// Feed the pet
    public mutating func feed(food: FoodType) {
        hunger = Self.clamp(hunger + food.nutritionValue)
        happiness = Self.clamp(happiness + food.happinessBonus)
        lastFedTime = Date()
        lastInteractionTime = Date()

        // Evolve personality
        personality.evolve(basedOn: .feeding, amount: 0.001)

        // Gain experience
        experience += 5

        updateEmotionalState()
    }

    /// Pet the pet
    public mutating func pet(duration: TimeInterval, quality: Float = 1.0) {
        let baseGain = Float(duration) * 0.01
        let affectionGain = baseGain * quality

        happiness = Self.clamp(happiness + affectionGain)
        lastPettedTime = Date()
        lastInteractionTime = Date()

        // Evolve personality
        personality.evolve(basedOn: .petting, amount: affectionGain * 0.1)

        // Gain experience
        experience += Int(affectionGain * 10)

        updateEmotionalState()
    }

    /// Play with the pet
    public mutating func play(activity: PlayActivity) -> Bool {
        guard energy >= activity.energyCost else {
            return false
        }

        energy -= activity.energyCost
        happiness = Self.clamp(happiness + activity.happinessGain)
        lastPlayedTime = Date()
        lastInteractionTime = Date()

        // Evolve personality
        personality.evolve(basedOn: .playing, amount: 0.002)

        // Gain experience
        experience += 10

        updateEmotionalState()

        return true
    }

    // MARK: - Helper Methods

    /// Clamp value to 0.0 - 1.0 range
    private static func clamp(_ value: Float) -> Float {
        max(0.0, min(1.0, value))
    }

    /// Convert experience points to level
    private func experienceToLevel(_ xp: Int) -> Int {
        // Level formula: level = sqrt(xp / 100)
        return max(1, Int(sqrt(Double(xp) / 100.0)))
    }

    /// Get overall status score (0.0 - 1.0)
    public var overallStatus: Float {
        (health + happiness + energy + hunger) / 4.0
    }

    /// Whether the pet needs immediate attention
    public var needsAttention: Bool {
        hunger < 0.3 || happiness < 0.3 || health < 0.4
    }

    /// Get a summary description of the pet
    public func summary() -> String {
        """
        \(name) (\(species.displayName))
        Age: \(Int(ageInDays)) days (\(lifeStage.rawValue))
        Level: \(level)
        Health: \(Int(health * 100))%
        Happiness: \(Int(happiness * 100))%
        Feeling: \(emotionalState.primaryEmotion.emoji) \(emotionalState.primaryEmotion.rawValue)
        Personality: \(personality.description())
        """
    }
}

// MARK: - Play Activity

/// Types of play activities
public enum PlayActivity: String, Codable, Sendable {
    case fetch = "Fetch"
    case tugOfWar = "Tug of War"
    case hideAndSeek = "Hide and Seek"
    case training = "Training"

    /// Energy cost of this activity (0.0 - 1.0)
    public var energyCost: Float {
        switch self {
        case .fetch:
            return 0.2
        case .tugOfWar:
            return 0.3
        case .hideAndSeek:
            return 0.1
        case .training:
            return 0.15
        }
    }

    /// Happiness gained from this activity (0.0 - 1.0)
    public var happinessGain: Float {
        switch self {
        case .fetch:
            return 0.3
        case .tugOfWar:
            return 0.25
        case .hideAndSeek:
            return 0.2
        case .training:
            return 0.15
        }
    }
}

// MARK: - Equatable Conformance

extension Pet: Equatable {
    public static func == (lhs: Pet, rhs: Pet) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Hashable Conformance

extension Pet: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
