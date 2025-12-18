import Foundation

/// Personality model based on Big Five traits
struct Personality: Codable, Equatable {
    // MARK: - Big Five Traits (0.0 to 1.0)
    var openness: Float
    var conscientiousness: Float
    var extraversion: Float
    var agreeableness: Float
    var neuroticism: Float

    // MARK: - Derived Traits
    var traits: Set<PersonalityTrait>

    init(
        openness: Float = 0.5,
        conscientiousness: Float = 0.5,
        extraversion: Float = 0.5,
        agreeableness: Float = 0.5,
        neuroticism: Float = 0.5,
        traits: Set<PersonalityTrait> = []
    ) {
        self.openness = Self.clamp(openness)
        self.conscientiousness = Self.clamp(conscientiousness)
        self.extraversion = Self.clamp(extraversion)
        self.agreeableness = Self.clamp(agreeableness)
        self.neuroticism = Self.clamp(neuroticism)
        self.traits = traits

        // If no traits provided, derive from Big Five
        if traits.isEmpty {
            self.traits = Self.deriveTraits(
                openness: self.openness,
                conscientiousness: self.conscientiousness,
                extraversion: self.extraversion,
                agreeableness: self.agreeableness,
                neuroticism: self.neuroticism
            )
        }
    }

    /// Create a balanced personality
    static var balanced: Personality {
        Personality(
            openness: 0.5,
            conscientiousness: 0.5,
            extraversion: 0.5,
            agreeableness: 0.5,
            neuroticism: 0.5
        )
    }

    /// Create a random personality
    static func random() -> Personality {
        Personality(
            openness: Float.random(in: 0.0...1.0),
            conscientiousness: Float.random(in: 0.0...1.0),
            extraversion: Float.random(in: 0.0...1.0),
            agreeableness: Float.random(in: 0.0...1.0),
            neuroticism: Float.random(in: 0.0...1.0)
        )
    }

    /// Clamp value to 0.0-1.0 range
    private static func clamp(_ value: Float) -> Float {
        max(0.0, min(1.0, value))
    }

    /// Derive personality traits from Big Five scores
    private static func deriveTraits(
        openness: Float,
        conscientiousness: Float,
        extraversion: Float,
        agreeableness: Float,
        neuroticism: Float
    ) -> Set<PersonalityTrait> {
        var derivedTraits: Set<PersonalityTrait> = []

        // Conscientiousness-based traits
        if conscientiousness > 0.7 {
            derivedTraits.insert(.neat)
            derivedTraits.insert(.ambitious)
        } else if conscientiousness < 0.3 {
            derivedTraits.insert(.messy)
            derivedTraits.insert(.lazy)
        }

        // Extraversion-based traits
        if extraversion > 0.7 {
            derivedTraits.insert(.outgoing)
        } else if extraversion < 0.3 {
            derivedTraits.insert(.shy)
        }

        // Agreeableness-based traits
        if agreeableness > 0.7 {
            derivedTraits.insert(.romantic)
        } else if agreeableness < 0.3 {
            derivedTraits.insert(.unromantic)
        }

        // Neuroticism-based traits
        if neuroticism > 0.7 {
            derivedTraits.insert(.hotHeaded)
        } else if neuroticism < 0.3 {
            derivedTraits.insert(.calm)
        }

        // Openness-based traits
        if openness > 0.7 {
            derivedTraits.insert(.creative)
        } else if openness < 0.3 {
            derivedTraits.insert(.practical)
        }

        return derivedTraits
    }

    /// Mutate personality based on life experience
    mutating func evolve(by experience: LifeExperience, age: Int) {
        let plasticityMultiplier = Self.plasticityMultiplier(for: age)
        let changes = experience.personalityChanges

        openness = Self.clamp(openness + changes.openness * plasticityMultiplier)
        conscientiousness = Self.clamp(conscientiousness + changes.conscientiousness * plasticityMultiplier)
        extraversion = Self.clamp(extraversion + changes.extraversion * plasticityMultiplier)
        agreeableness = Self.clamp(agreeableness + changes.agreeableness * plasticityMultiplier)
        neuroticism = Self.clamp(neuroticism + changes.neuroticism * plasticityMultiplier)

        // Re-derive traits
        traits = Self.deriveTraits(
            openness: openness,
            conscientiousness: conscientiousness,
            extraversion: extraversion,
            agreeableness: agreeableness,
            neuroticism: neuroticism
        )
    }

    /// Calculate personality plasticity based on age
    private static func plasticityMultiplier(for age: Int) -> Float {
        switch age {
        case 0...12:   return 2.0   // Children change rapidly
        case 13...19:  return 1.5   // Teens still forming
        case 20...30:  return 1.0   // Young adults moderate
        case 31...50:  return 0.5   // Adults more stable
        default:       return 0.25  // Seniors very stable
        }
    }

    /// Calculate compatibility with another personality
    static func calculateCompatibility(_ personA: Personality, _ personB: Personality) -> Float {
        var compatibility: Float = 0.0

        // Complementary extraversion (not too different)
        let extraversionDiff = abs(personA.extraversion - personB.extraversion)
        compatibility += extraversionDiff < 0.3 ? 0.2 : 0.0

        // High agreeableness helps
        compatibility += (personA.agreeableness + personB.agreeableness) / 2 * 0.3

        // Similar openness
        let opennessMatch = 1.0 - abs(personA.openness - personB.openness)
        compatibility += opennessMatch * 0.2

        // Low neuroticism helps
        compatibility += (2.0 - personA.neuroticism - personB.neuroticism) * 0.15

        // Similar conscientiousness
        let conscientiousnessMatch = 1.0 - abs(personA.conscientiousness - personB.conscientiousness)
        compatibility += conscientiousnessMatch * 0.15

        return min(1.0, max(0.0, compatibility))
    }
}

// MARK: - Personality Traits

enum PersonalityTrait: String, Codable, CaseIterable {
    case neat, messy
    case outgoing, shy
    case romantic, unromantic
    case ambitious, lazy
    case creative, practical
    case hotHeaded, calm
    case friendly, unfriendly
    case active, sedentary
    case genius, average
    case goodHumored, serious
}

// MARK: - Life Experiences

struct LifeExperience {
    let name: String
    let personalityChanges: PersonalityDelta

    static let promotion = LifeExperience(
        name: "Promotion",
        personalityChanges: PersonalityDelta(
            conscientiousness: +0.01,
            neuroticism: -0.01
        )
    )

    static let fired = LifeExperience(
        name: "Fired",
        personalityChanges: PersonalityDelta(
            neuroticism: +0.02,
            conscientiousness: -0.01
        )
    )

    static let marriage = LifeExperience(
        name: "Marriage",
        personalityChanges: PersonalityDelta(
            agreeableness: +0.01,
            openness: +0.005
        )
    )

    static let divorce = LifeExperience(
        name: "Divorce",
        personalityChanges: PersonalityDelta(
            neuroticism: +0.02,
            agreeableness: -0.01
        )
    )

    static let newBaby = LifeExperience(
        name: "New Baby",
        personalityChanges: PersonalityDelta(
            conscientiousness: +0.02,
            neuroticism: +0.01
        )
    )

    static let deathOfLovedOne = LifeExperience(
        name: "Death of Loved One",
        personalityChanges: PersonalityDelta(
            neuroticism: +0.03,
            extraversion: -0.02
        )
    )

    static let newFriendship = LifeExperience(
        name: "New Friendship",
        personalityChanges: PersonalityDelta(
            extraversion: +0.01,
            agreeableness: +0.01
        )
    )
}

struct PersonalityDelta {
    var openness: Float = 0.0
    var conscientiousness: Float = 0.0
    var extraversion: Float = 0.0
    var agreeableness: Float = 0.0
    var neuroticism: Float = 0.0

    init(
        openness: Float = 0.0,
        conscientiousness: Float = 0.0,
        extraversion: Float = 0.0,
        agreeableness: Float = 0.0,
        neuroticism: Float = 0.0
    ) {
        self.openness = openness
        self.conscientiousness = conscientiousness
        self.extraversion = extraversion
        self.agreeableness = agreeableness
        self.neuroticism = neuroticism
    }
}
