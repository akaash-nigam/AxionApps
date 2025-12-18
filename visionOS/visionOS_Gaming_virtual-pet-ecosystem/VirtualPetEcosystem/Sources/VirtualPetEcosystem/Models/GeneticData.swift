import Foundation

/// Represents the genetic makeup of a pet
public struct GeneticData: Codable, Sendable {
    /// Genetic traits carried by the pet
    public var traits: [GeneticTrait]

    /// Mutations that have occurred
    public var mutations: [Mutation]

    /// Generation number (0 = original, 1 = first offspring, etc.)
    public let generation: Int

    /// Parent IDs (if bred)
    public var parentIDs: [UUID]

    public init(
        traits: [GeneticTrait] = [],
        mutations: [Mutation] = [],
        generation: Int = 0,
        parentIDs: [UUID] = []
    ) {
        self.traits = traits
        self.mutations = mutations
        self.generation = generation
        self.parentIDs = parentIDs
    }

    /// Generate random genetics for a species
    public static func random(for species: PetSpecies) -> GeneticData {
        var traits: [GeneticTrait] = []

        // Add base traits for species
        traits.append(contentsOf: speciesBaseTraits(for: species))

        // Add some random traits
        let randomTraitCount = Int.random(in: 2...5)
        for _ in 0..<randomTraitCount {
            if let randomTrait = GeneticTrait.random() {
                traits.append(randomTrait)
            }
        }

        return GeneticData(traits: traits, generation: 0)
    }

    /// Base traits for each species
    private static func speciesBaseTraits(for species: PetSpecies) -> [GeneticTrait] {
        switch species {
        case .luminos:
            return [
                GeneticTrait(name: "Bioluminescence", dominance: .dominant, rarity: .common),
                GeneticTrait(name: "Light Affinity", dominance: .dominant, rarity: .common)
            ]

        case .fluffkins:
            return [
                GeneticTrait(name: "Dense Fur", dominance: .dominant, rarity: .common),
                GeneticTrait(name: "Soft Coat", dominance: .dominant, rarity: .common)
            ]

        case .crystalites:
            return [
                GeneticTrait(name: "Crystalline Structure", dominance: .dominant, rarity: .common),
                GeneticTrait(name: "Geometric Form", dominance: .dominant, rarity: .common)
            ]

        case .aquarians:
            return [
                GeneticTrait(name: "Fluid Movement", dominance: .dominant, rarity: .common),
                GeneticTrait(name: "Translucent Body", dominance: .dominant, rarity: .common)
            ]

        case .shadowlings:
            return [
                GeneticTrait(name: "Shadow Form", dominance: .dominant, rarity: .common),
                GeneticTrait(name: "Stealth", dominance: .dominant, rarity: .common)
            ]
        }
    }

    /// Combine genetics from two parents
    public static func combine(_ parent1: GeneticData, _ parent2: GeneticData) -> GeneticData {
        var offspringTraits: [GeneticTrait] = []

        // Combine traits from both parents
        let allParentTraits = Set(parent1.traits + parent2.traits)

        for trait in allParentTraits {
            // Check if both parents have this trait
            let parent1HasTrait = parent1.traits.contains(where: { $0.name == trait.name })
            let parent2HasTrait = parent2.traits.contains(where: { $0.name == trait.name })

            if parent1HasTrait && parent2HasTrait {
                // Both have it - definitely inherited
                offspringTraits.append(trait)
            } else if parent1HasTrait || parent2HasTrait {
                // Only one parent has it - check dominance
                if trait.dominance == .dominant {
                    // 50% chance to inherit
                    if Bool.random() {
                        offspringTraits.append(trait)
                    }
                } else {
                    // 25% chance for recessive
                    if Float.random(in: 0...1) < 0.25 {
                        offspringTraits.append(trait)
                    }
                }
            }
        }

        // Possible mutation (5% chance)
        var mutations: [Mutation] = []
        if Float.random(in: 0...1) < 0.05 {
            let mutation = Mutation.random()
            mutations.append(mutation)

            // Apply mutation
            if mutation.effect == .newTrait, let newTrait = GeneticTrait.random() {
                offspringTraits.append(newTrait)
            }
        }

        let generation = max(parent1.generation, parent2.generation) + 1

        return GeneticData(
            traits: offspringTraits,
            mutations: mutations,
            generation: generation,
            parentIDs: parent1.parentIDs + parent2.parentIDs
        )
    }

    /// Get all trait names
    public var traitNames: [String] {
        traits.map { $0.name }
    }

    /// Check if has specific trait
    public func hasTrait(_ traitName: String) -> Bool {
        traits.contains(where: { $0.name == traitName })
    }

    /// Count traits by rarity
    public func countTraits(ofRarity rarity: TraitRarity) -> Int {
        traits.filter { $0.rarity == rarity }.count
    }
}

/// Represents a genetic trait
public struct GeneticTrait: Codable, Hashable, Sendable {
    /// Name of the trait
    public let name: String

    /// Whether the trait is dominant or recessive
    public let dominance: Dominance

    /// Rarity of the trait
    public let rarity: TraitRarity

    /// Description of the trait
    public var description: String?

    public init(name: String, dominance: Dominance, rarity: TraitRarity, description: String? = nil) {
        self.name = name
        self.dominance = dominance
        self.rarity = rarity
        self.description = description
    }

    /// Generate a random trait
    public static func random() -> GeneticTrait? {
        let allTraits: [GeneticTrait] = [
            // Appearance traits
            GeneticTrait(name: "Vibrant Colors", dominance: .dominant, rarity: .uncommon),
            GeneticTrait(name: "Pastel Colors", dominance: .recessive, rarity: .uncommon),
            GeneticTrait(name: "Sparkle Effect", dominance: .recessive, rarity: .rare),
            GeneticTrait(name: "Extra Large Size", dominance: .dominant, rarity: .uncommon),
            GeneticTrait(name: "Miniature Size", dominance: .recessive, rarity: .rare),

            // Behavioral traits
            GeneticTrait(name: "High Energy", dominance: .dominant, rarity: .common),
            GeneticTrait(name: "Calm Demeanor", dominance: .recessive, rarity: .common),
            GeneticTrait(name: "Extra Playful", dominance: .dominant, rarity: .uncommon),
            GeneticTrait(name: "Highly Intelligent", dominance: .recessive, rarity: .rare),

            // Special abilities
            GeneticTrait(name: "Fast Learner", dominance: .dominant, rarity: .uncommon),
            GeneticTrait(name: "Empathic Bond", dominance: .recessive, rarity: .rare),
            GeneticTrait(name: "Long Lifespan", dominance: .recessive, rarity: .epic),
            GeneticTrait(name: "Unique Vocalization", dominance: .dominant, rarity: .uncommon),

            // Legendary traits
            GeneticTrait(name: "Magical Aura", dominance: .recessive, rarity: .legendary),
            GeneticTrait(name: "Shape Shifter", dominance: .recessive, rarity: .legendary),
        ]

        // Weight selection by rarity
        let roll = Float.random(in: 0...1)

        let rarityFilter: TraitRarity
        if roll < 0.5 {
            rarityFilter = .common
        } else if roll < 0.8 {
            rarityFilter = .uncommon
        } else if roll < 0.95 {
            rarityFilter = .rare
        } else if roll < 0.99 {
            rarityFilter = .epic
        } else {
            rarityFilter = .legendary
        }

        let filteredTraits = allTraits.filter { $0.rarity == rarityFilter }
        return filteredTraits.randomElement()
    }
}

/// Dominance of a genetic trait
public enum Dominance: String, Codable, Sendable {
    case dominant = "Dominant"
    case recessive = "Recessive"
}

/// Rarity of a genetic trait
public enum TraitRarity: String, Codable, CaseIterable, Sendable {
    case common = "Common"
    case uncommon = "Uncommon"
    case rare = "Rare"
    case epic = "Epic"
    case legendary = "Legendary"

    /// Color associated with rarity
    public var colorHex: String {
        switch self {
        case .common:
            return "#FFFFFF" // White
        case .uncommon:
            return "#1EFF00" // Green
        case .rare:
            return "#0070DD" // Blue
        case .epic:
            return "#A335EE" // Purple
        case .legendary:
            return "#FF8000" // Orange
        }
    }

    /// Emoji representation
    public var emoji: String {
        switch self {
        case .common:
            return "⚪"
        case .uncommon:
            return "🟢"
        case .rare:
            return "🔵"
        case .epic:
            return "🟣"
        case .legendary:
            return "🟠"
        }
    }
}

/// Represents a genetic mutation
public struct Mutation: Codable, Sendable {
    /// Unique identifier
    public let id: UUID

    /// Name of the mutation
    public let name: String

    /// Effect of the mutation
    public let effect: MutationEffect

    /// When the mutation occurred
    public let occurredAt: Date

    public init(name: String, effect: MutationEffect) {
        self.id = UUID()
        self.name = name
        self.effect = effect
        self.occurredAt = Date()
    }

    /// Generate a random mutation
    public static func random() -> Mutation {
        let mutations: [(String, MutationEffect)] = [
            ("Chromatic Shift", .newTrait),
            ("Size Variation", .traitModification),
            ("Behavioral Change", .personalityShift),
            ("Enhanced Ability", .newTrait),
            ("Color Mutation", .traitModification),
        ]

        let (name, effect) = mutations.randomElement()!
        return Mutation(name: name, effect: effect)
    }
}

/// Effects a mutation can have
public enum MutationEffect: String, Codable, Sendable {
    case newTrait = "New Trait"
    case traitModification = "Trait Modification"
    case personalityShift = "Personality Shift"
}
