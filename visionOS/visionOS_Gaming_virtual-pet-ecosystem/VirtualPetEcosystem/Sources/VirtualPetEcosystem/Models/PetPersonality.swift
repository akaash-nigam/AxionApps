import Foundation

/// AI-driven personality traits that evolve over time
public struct PetPersonality: Codable, Sendable {
    // Big Five personality traits (0.0 - 1.0)

    /// Curiosity and exploration tendency
    public var openness: Float

    /// Routine adherence and organization
    public var conscientiousness: Float

    /// Social engagement and energy from interaction
    public var extraversion: Float

    /// Friendliness and cooperation
    public var agreeableness: Float

    /// Emotional stability (lower is more stable)
    public var neuroticism: Float

    // Pet-specific traits (0.0 - 1.0)

    /// Tendency to engage in play
    public var playfulness: Float

    /// Preference for solo vs social activities
    public var independence: Float

    /// Attachment and faithfulness to owner
    public var loyalty: Float

    /// Learning speed and problem-solving ability
    public var intelligence: Float

    /// Need for physical affection
    public var affectionNeed: Float

    /// Initialize with default balanced personality
    public init(
        openness: Float = 0.5,
        conscientiousness: Float = 0.5,
        extraversion: Float = 0.5,
        agreeableness: Float = 0.5,
        neuroticism: Float = 0.5,
        playfulness: Float = 0.5,
        independence: Float = 0.5,
        loyalty: Float = 0.5,
        intelligence: Float = 0.5,
        affectionNeed: Float = 0.5
    ) {
        self.openness = Self.clamp(openness)
        self.conscientiousness = Self.clamp(conscientiousness)
        self.extraversion = Self.clamp(extraversion)
        self.agreeableness = Self.clamp(agreeableness)
        self.neuroticism = Self.clamp(neuroticism)
        self.playfulness = Self.clamp(playfulness)
        self.independence = Self.clamp(independence)
        self.loyalty = Self.clamp(loyalty)
        self.intelligence = Self.clamp(intelligence)
        self.affectionNeed = Self.clamp(affectionNeed)
    }

    /// Create a random personality
    public static func random() -> PetPersonality {
        PetPersonality(
            openness: Float.random(in: 0.3...0.9),
            conscientiousness: Float.random(in: 0.3...0.9),
            extraversion: Float.random(in: 0.3...0.9),
            agreeableness: Float.random(in: 0.4...0.95),
            neuroticism: Float.random(in: 0.2...0.7),
            playfulness: Float.random(in: 0.4...0.95),
            independence: Float.random(in: 0.3...0.8),
            loyalty: Float.random(in: 0.5...0.95),
            intelligence: Float.random(in: 0.4...0.9),
            affectionNeed: Float.random(in: 0.3...0.9)
        )
    }

    /// Create personality influenced by species defaults
    public static func forSpecies(_ species: PetSpecies) -> PetPersonality {
        var personality = PetPersonality.random()

        switch species {
        case .luminos:
            // Light creatures: open, extraverted, low neuroticism
            personality.openness += 0.2
            personality.extraversion += 0.2
            personality.neuroticism -= 0.2

        case .fluffkins:
            // Furry companions: loyal, affectionate, agreeable
            personality.loyalty += 0.3
            personality.affectionNeed += 0.3
            personality.agreeableness += 0.2

        case .crystalites:
            // Geometric beings: conscientious, intelligent, independent
            personality.conscientiousness += 0.3
            personality.intelligence += 0.2
            personality.independence += 0.2

        case .aquarians:
            // Floating creatures: calm, low neuroticism, playful
            personality.neuroticism -= 0.3
            personality.playfulness += 0.2
            personality.openness += 0.1

        case .shadowlings:
            // Shy creatures: low extraversion, high neuroticism, independent
            personality.extraversion -= 0.3
            personality.neuroticism += 0.2
            personality.independence += 0.3
        }

        // Clamp all values after modification
        personality.clampAll()

        return personality
    }

    /// Evolve personality based on interaction
    public mutating func evolve(basedOn interaction: InteractionType, amount: Float = 0.001) {
        let delta = Self.clamp(amount)

        switch interaction {
        case .feeding:
            self.conscientiousness += delta * 0.5
            self.loyalty += delta * 0.5

        case .playing:
            self.playfulness += delta
            self.extraversion += delta * 0.7
            self.happiness += delta * 0.3

        case .petting:
            self.affectionNeed += delta * 0.5
            self.agreeableness += delta * 0.7
            self.loyalty += delta * 0.8

        case .training:
            self.intelligence += delta
            self.conscientiousness += delta * 0.6
            self.openness += delta * 0.4

        case .socializing:
            self.extraversion += delta
            self.agreeableness += delta * 0.5

        case .exploring:
            self.openness += delta
            self.intelligence += delta * 0.3
            self.independence += delta * 0.5

        case .resting:
            self.neuroticism -= delta * 0.5
            self.independence += delta * 0.2
        }

        self.clampAll()
    }

    /// Clamp all personality values to 0.0 - 1.0 range
    private mutating func clampAll() {
        self.openness = Self.clamp(openness)
        self.conscientiousness = Self.clamp(conscientiousness)
        self.extraversion = Self.clamp(extraversion)
        self.agreeableness = Self.clamp(agreeableness)
        self.neuroticism = Self.clamp(neuroticism)
        self.playfulness = Self.clamp(playfulness)
        self.independence = Self.clamp(independence)
        self.loyalty = Self.clamp(loyalty)
        self.intelligence = Self.clamp(intelligence)
        self.affectionNeed = Self.clamp(affectionNeed)
    }

    /// Clamp value to 0.0 - 1.0 range
    private static func clamp(_ value: Float) -> Float {
        max(0.0, min(1.0, value))
    }

    /// Get a description of the pet's personality
    public func description() -> String {
        var traits: [String] = []

        if playfulness > 0.7 {
            traits.append("very playful")
        } else if playfulness < 0.3 {
            traits.append("calm")
        }

        if loyalty > 0.8 {
            traits.append("extremely loyal")
        }

        if affectionNeed > 0.7 {
            traits.append("affectionate")
        } else if affectionNeed < 0.3 {
            traits.append("independent")
        }

        if intelligence > 0.7 {
            traits.append("intelligent")
        }

        if extraversion > 0.7 {
            traits.append("sociable")
        } else if extraversion < 0.3 {
            traits.append("shy")
        }

        return traits.joined(separator: ", ")
    }
}

/// Types of interactions that can influence personality
public enum InteractionType: String, Codable, Sendable {
    case feeding
    case playing
    case petting
    case training
    case socializing
    case exploring
    case resting
}

/// Extension for computed properties
extension PetPersonality {
    /// Overall happiness tendency (derived from personality)
    var happiness: Float {
        get {
            // Happiness correlates with low neuroticism and high agreeableness
            return ((1.0 - neuroticism) + agreeableness) / 2.0
        }
        set {
            // When setting happiness, adjust neuroticism inversely
            neuroticism = 1.0 - newValue
        }
    }

    /// Energy level tendency (derived from personality)
    public var energyLevel: Float {
        // Energy correlates with extraversion and playfulness
        (extraversion + playfulness) / 2.0
    }

    /// Curiosity level (derived from personality)
    public var curiosity: Float {
        openness
    }
}
