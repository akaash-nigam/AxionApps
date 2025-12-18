import Foundation

/// System responsible for breeding pets and generating offspring
public actor BreedingSystem {
    public init() {}

    /// Breed two pets and generate offspring
    /// - Parameters:
    ///   - parent1: First parent pet
    ///   - parent2: Second parent pet
    /// - Returns: Result containing the offspring pet or an error
    public func breed(_ parent1: Pet, _ parent2: Pet) -> Result<Pet, BreedingError> {
        // Validate breeding eligibility
        if let error = validateBreeding(parent1, parent2) {
            return .failure(error)
        }

        // Generate offspring
        let offspring = generateOffspring(parent1: parent1, parent2: parent2)

        return .success(offspring)
    }

    /// Validate if two pets can breed
    private func validateBreeding(_ parent1: Pet, _ parent2: Pet) -> BreedingError? {
        // Check if both pets can breed
        if !parent1.canBreed {
            return .parentNotReady(parent1.name)
        }

        if !parent2.canBreed {
            return .parentNotReady(parent2.name)
        }

        // Check if both are adults
        if parent1.lifeStage != .adult {
            return .wrongLifeStage(parent1.name, parent1.lifeStage)
        }

        if parent2.lifeStage != .adult {
            return .wrongLifeStage(parent2.name, parent2.lifeStage)
        }

        // Check if health is sufficient
        if parent1.health < 0.5 {
            return .insufficientHealth(parent1.name, parent1.health)
        }

        if parent2.health < 0.5 {
            return .insufficientHealth(parent2.name, parent2.health)
        }

        // Check if they're the same species (for now, only same-species breeding)
        if parent1.species != parent2.species {
            return .speciesMismatch
        }

        return nil
    }

    /// Generate offspring from two parent pets
    private func generateOffspring(parent1: Pet, parent2: Pet) -> Pet {
        // Combine genetics
        let offspringGenetics = GeneticData.combine(parent1.genetics, parent2.genetics)

        // Combine personalities (weighted average with some randomness)
        let offspringPersonality = combinePersonalities(parent1.personality, parent2.personality)

        // Generate offspring name (can be customized by user later)
        let offspringName = generateOffspringName(parent1: parent1, parent2: parent2)

        // Create offspring pet
        let offspring = Pet(
            name: offspringName,
            species: parent1.species,
            birthDate: Date(),
            personality: offspringPersonality,
            genetics: offspringGenetics,
            health: 1.0,
            happiness: 0.9,
            energy: 1.0,
            hunger: 1.0
        )

        return offspring
    }

    /// Combine personalities from two parents
    private func combinePersonalities(_ p1: PetPersonality, _ p2: PetPersonality) -> PetPersonality {
        // Average the traits with some randomness
        func blend(_ t1: Float, _ t2: Float) -> Float {
            let average = (t1 + t2) / 2.0
            let randomness = Float.random(in: -0.1...0.1)
            return max(0.0, min(1.0, average + randomness))
        }

        return PetPersonality(
            openness: blend(p1.openness, p2.openness),
            conscientiousness: blend(p1.conscientiousness, p2.conscientiousness),
            extraversion: blend(p1.extraversion, p2.extraversion),
            agreeableness: blend(p1.agreeableness, p2.agreeableness),
            neuroticism: blend(p1.neuroticism, p2.neuroticism),
            playfulness: blend(p1.playfulness, p2.playfulness),
            independence: blend(p1.independence, p2.independence),
            loyalty: blend(p1.loyalty, p2.loyalty),
            intelligence: blend(p1.intelligence, p2.intelligence),
            affectionNeed: blend(p1.affectionNeed, p2.affectionNeed)
        )
    }

    /// Generate a default name for offspring
    private func generateOffspringName(parent1: Pet, parent2: Pet) -> String {
        let prefixes = ["Baby", "Little", "Tiny", "Young"]
        let prefix = prefixes.randomElement()!

        // Combine parts of parent names
        let parent1FirstPart = String(parent1.name.prefix(3))
        let parent2LastPart = String(parent2.name.suffix(3))

        return "\(prefix) \(parent1FirstPart)\(parent2LastPart)"
    }

    /// Predict possible offspring traits
    /// - Parameters:
    ///   - parent1: First parent pet
    ///   - parent2: Second parent pet
    /// - Returns: Prediction of possible traits and their probabilities
    public func predictOffspring(_ parent1: Pet, _ parent2: Pet) -> BreedingPrediction {
        var predictedTraits: [(GeneticTrait, Float)] = []

        // Analyze all traits from both parents
        let allTraits = Set(parent1.genetics.traits + parent2.genetics.traits)

        for trait in allTraits {
            let parent1Has = parent1.genetics.hasTrait(trait.name)
            let parent2Has = parent2.genetics.hasTrait(trait.name)

            var probability: Float = 0.0

            if parent1Has && parent2Has {
                // Both have it
                probability = 1.0
            } else if parent1Has || parent2Has {
                // Only one has it
                if trait.dominance == .dominant {
                    probability = 0.5
                } else {
                    probability = 0.25
                }
            }

            if probability > 0 {
                predictedTraits.append((trait, probability))
            }
        }

        // Sort by probability
        predictedTraits.sort { $0.1 > $1.1 }

        // Calculate personality range
        let personalityPrediction = predictPersonalityRange(parent1.personality, parent2.personality)

        return BreedingPrediction(
            possibleTraits: predictedTraits,
            personalityRange: personalityPrediction,
            mutationChance: 0.05
        )
    }

    /// Predict personality range
    private func predictPersonalityRange(_ p1: PetPersonality, _ p2: PetPersonality) -> PersonalityRange {
        func range(_ t1: Float, _ t2: Float) -> ClosedRange<Float> {
            let minValue = max(0.0, (t1 + t2) / 2.0 - 0.15)
            let maxValue = min(1.0, (t1 + t2) / 2.0 + 0.15)
            return minValue...maxValue
        }

        return PersonalityRange(
            playfulness: range(p1.playfulness, p2.playfulness),
            loyalty: range(p1.loyalty, p2.loyalty),
            intelligence: range(p1.intelligence, p2.intelligence),
            affectionNeed: range(p1.affectionNeed, p2.affectionNeed)
        )
    }
}

/// Errors that can occur during breeding
public enum BreedingError: Error, LocalizedError {
    case parentNotReady(String)
    case wrongLifeStage(String, LifeStage)
    case insufficientHealth(String, Float)
    case speciesMismatch
    case sameParent

    public var errorDescription: String? {
        switch self {
        case .parentNotReady(let name):
            return "\(name) is not ready to breed yet."

        case .wrongLifeStage(let name, let stage):
            return "\(name) cannot breed at \(stage.rawValue) stage. Must be Adult."

        case .insufficientHealth(let name, let health):
            return "\(name) has insufficient health (\(Int(health * 100))%). Must be above 50%."

        case .speciesMismatch:
            return "Cannot breed pets of different species."

        case .sameParent:
            return "Cannot breed a pet with itself."
        }
    }
}

/// Prediction of breeding results
public struct BreedingPrediction: Sendable {
    /// Possible traits and their probabilities
    public let possibleTraits: [(trait: GeneticTrait, probability: Float)]

    /// Expected personality trait ranges
    public let personalityRange: PersonalityRange

    /// Chance of mutation occurring
    public let mutationChance: Float
}

/// Range of personality traits for offspring
public struct PersonalityRange: Sendable {
    public let playfulness: ClosedRange<Float>
    public let loyalty: ClosedRange<Float>
    public let intelligence: ClosedRange<Float>
    public let affectionNeed: ClosedRange<Float>
}
