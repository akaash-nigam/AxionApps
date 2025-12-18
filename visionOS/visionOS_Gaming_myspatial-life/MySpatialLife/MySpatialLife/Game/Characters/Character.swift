import Foundation

/// Main character class representing a sim in the game
class Character: Identifiable, Codable {
    // MARK: - Identity
    let id: UUID
    var firstName: String
    var lastName: String
    var age: Int
    var gender: Gender
    var avatarConfiguration: AvatarConfig

    // MARK: - Personality
    var personality: Personality

    // MARK: - Life State
    var lifeStage: LifeStage
    var birthDate: Date
    var deathDate: Date?

    // MARK: - Needs (0.0 = critical, 1.0 = fully satisfied)
    var hunger: Float = 1.0
    var energy: Float = 1.0
    var social: Float = 1.0
    var fun: Float = 1.0
    var hygiene: Float = 1.0
    var bladder: Float = 1.0

    // MARK: - Relationships
    var relationships: [UUID: CharacterRelationship] = [:]

    // MARK: - Career
    var currentJob: Job?
    var careerLevel: Int = 1
    var workPerformance: Float = 0.5

    // MARK: - Skills (1-10 scale)
    var skills: [Skill: Int] = [:]

    // MARK: - Spatial
    var homeAnchorID: UUID?
    var favoriteSpots: [SpatialLocation] = []

    // MARK: - Memory
    var memories: [Memory] = []

    // MARK: - Genetics (for offspring)
    var genetics: Genetics

    // MARK: - Current Activity
    var currentAction: Action = .relax
    var currentTarget: UUID?  // Target character or object

    init(
        id: UUID = UUID(),
        firstName: String,
        lastName: String,
        age: Int,
        gender: Gender,
        personality: Personality,
        avatarConfiguration: AvatarConfig = AvatarConfig()
    ) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.age = age
        self.gender = gender
        self.personality = personality
        self.avatarConfiguration = avatarConfiguration

        // Determine life stage from age
        self.lifeStage = Self.lifeStageForAge(age)

        // Set birthday
        var calendar = Calendar.current
        self.birthDate = calendar.date(byAdding: .year, value: -age, to: Date()) ?? Date()

        // Initialize genetics from personality
        self.genetics = Genetics.fromPersonality(personality)

        // Initialize default skills
        for skill in Skill.allCases {
            skills[skill] = 1
        }
    }

    /// Get full name
    var fullName: String {
        "\(firstName) \(lastName)"
    }

    /// Get need value by type
    func needValue(for needType: NeedType) -> Float {
        switch needType {
        case .hunger: return hunger
        case .energy: return energy
        case .social: return social
        case .fun: return fun
        case .hygiene: return hygiene
        case .bladder: return bladder
        }
    }

    /// Set need value by type
    func setNeed(_ needType: NeedType, to value: Float) {
        let clampedValue = max(0.0, min(1.0, value))
        switch needType {
        case .hunger: hunger = clampedValue
        case .energy: energy = clampedValue
        case .social: social = clampedValue
        case .fun: fun = clampedValue
        case .hygiene: hygiene = clampedValue
        case .bladder: bladder = clampedValue
        }
    }

    /// Get most critical need
    func mostCriticalNeed() -> NeedType? {
        let needValues: [(NeedType, Float)] = [
            (.hunger, hunger),
            (.energy, energy),
            (.social, social),
            (.fun, fun),
            (.hygiene, hygiene),
            (.bladder, bladder)
        ]

        let sorted = needValues.sorted { $0.1 < $1.1 }
        return sorted.first?.0
    }

    /// Check if any need is critical (below 0.2)
    var hasCriticalNeed: Bool {
        needValue(for: .hunger) < 0.2 ||
        needValue(for: .energy) < 0.2 ||
        needValue(for: .social) < 0.2 ||
        needValue(for: .fun) < 0.2 ||
        needValue(for: .hygiene) < 0.2 ||
        needValue(for: .bladder) < 0.2
    }

    /// Determine life stage from age
    static func lifeStageForAge(_ age: Int) -> LifeStage {
        switch age {
        case 0...2:
            return .baby
        case 3...5:
            return .toddler
        case 6...12:
            return .child
        case 13...19:
            return .teen
        case 20...30:
            return .youngAdult
        case 31...50:
            return .adult
        default:
            return .elder
        }
    }

    /// Age the character by one year
    func ageUp() {
        age += 1
        let newStage = Self.lifeStageForAge(age)
        if newStage != lifeStage {
            lifeStage = newStage
        }
    }

    /// Get relationship with another character
    func relationship(with characterID: UUID) -> CharacterRelationship? {
        relationships[characterID]
    }

    /// Add or update relationship
    func setRelationship(_ relationship: CharacterRelationship, with characterID: UUID) {
        relationships[characterID] = relationship
    }
}

// MARK: - Supporting Types

enum Gender: String, Codable {
    case male
    case female
    case nonBinary
}

struct AvatarConfig: Codable {
    var hairStyle: String = "default"
    var hairColor: String = "brown"
    var skinTone: String = "medium"
    var eyeColor: String = "brown"
    var bodyType: String = "average"
}

enum Skill: String, Codable, CaseIterable {
    // Creative
    case painting
    case music
    case writing
    case cooking

    // Physical
    case fitness
    case sports
    case dancing

    // Social
    case charisma
    case comedy
    case romance

    // Mental
    case logic
    case programming
    case science

    // Practical
    case handiness
    case gardening
    case cleaning
}

struct SpatialLocation: Codable, Equatable {
    let x: Float
    let y: Float
    let z: Float
    let roomID: UUID?

    init(x: Float, y: Float, z: Float, roomID: UUID? = nil) {
        self.x = x
        self.y = y
        self.z = z
        self.roomID = roomID
    }
}
