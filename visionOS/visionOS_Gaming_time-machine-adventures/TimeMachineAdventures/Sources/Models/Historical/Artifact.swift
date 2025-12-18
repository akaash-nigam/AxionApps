import Foundation

/// Represents a historical artifact that can be discovered and examined
struct Artifact: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let era: HistoricalEra
    let category: ArtifactCategory
    let description: String
    let historicalContext: String
    let dateCreated: String
    let origin: String

    // Educational content
    let learningObjectives: [LearningObjective]
    let curriculumStandards: [String]  // Standard IDs
    let funFacts: [String]
    let relatedArtifacts: [String]  // Artifact IDs

    // Discovery & Gameplay
    let discoveryHints: [String]
    let discoveryLocation: DiscoveryLocation
    let rarity: Rarity
    let requiredLevel: EducationalLevel

    // 3D Model information
    let modelResourceName: String
    let thumbnailImageName: String
    let interactionType: InteractionType

    // Metadata
    let createdDate: Date
    let lastModifiedDate: Date

    init(id: String,
         name: String,
         era: HistoricalEra,
         category: ArtifactCategory,
         description: String,
         historicalContext: String,
         dateCreated: String,
         origin: String,
         learningObjectives: [LearningObjective] = [],
         curriculumStandards: [String] = [],
         funFacts: [String] = [],
         relatedArtifacts: [String] = [],
         discoveryHints: [String] = [],
         discoveryLocation: DiscoveryLocation = .anywhere,
         rarity: Rarity = .common,
         requiredLevel: EducationalLevel = .explorer,
         modelResourceName: String,
         thumbnailImageName: String,
         interactionType: InteractionType = .examine) {
        self.id = id
        self.name = name
        self.era = era
        self.category = category
        self.description = description
        self.historicalContext = historicalContext
        self.dateCreated = dateCreated
        self.origin = origin
        self.learningObjectives = learningObjectives
        self.curriculumStandards = curriculumStandards
        self.funFacts = funFacts
        self.relatedArtifacts = relatedArtifacts
        self.discoveryHints = discoveryHints
        self.discoveryLocation = discoveryLocation
        self.rarity = rarity
        self.requiredLevel = requiredLevel
        self.modelResourceName = modelResourceName
        self.thumbnailImageName = thumbnailImageName
        self.interactionType = interactionType
        self.createdDate = Date()
        self.lastModifiedDate = Date()
    }
}

// MARK: - Supporting Types

/// Category of artifact
enum ArtifactCategory: String, Codable, CaseIterable {
    case everydayObject = "everyday"
    case artAndCulture = "art"
    case technology = "technology"
    case historicalDocument = "document"
    case naturalHistory = "natural"
    case weaponAndArmor = "weapon"
    case religiousObject = "religious"
    case architecturalElement = "architectural"

    var displayName: String {
        switch self {
        case .everydayObject: return "Everyday Objects"
        case .artAndCulture: return "Art & Culture"
        case .technology: return "Technology"
        case .historicalDocument: return "Historical Documents"
        case .naturalHistory: return "Natural History"
        case .weaponAndArmor: return "Weapons & Armor"
        case .religiousObject: return "Religious Objects"
        case .architecturalElement: return "Architectural Elements"
        }
    }

    var icon: String {
        switch self {
        case .everydayObject: return "🏺"
        case .artAndCulture: return "🎨"
        case .technology: return "⚙️"
        case .historicalDocument: return "📜"
        case .naturalHistory: return "🦴"
        case .weaponAndArmor: return "⚔️"
        case .religiousObject: return "🕌"
        case .architecturalElement: return "🏛️"
        }
    }
}

/// Rarity level of artifact
enum Rarity: String, Codable, Comparable {
    case common
    case uncommon
    case rare
    case epic
    case legendary

    static func < (lhs: Rarity, rhs: Rarity) -> Bool {
        let order: [Rarity] = [.common, .uncommon, .rare, .epic, .legendary]
        guard let lhsIndex = order.firstIndex(of: lhs),
              let rhsIndex = order.firstIndex(of: rhs) else {
            return false
        }
        return lhsIndex < rhsIndex
    }

    var color: String {
        switch self {
        case .common: return "#808080"      // Gray
        case .uncommon: return "#00FF00"    // Green
        case .rare: return "#0070FF"        // Blue
        case .epic: return "#A335EE"        // Purple
        case .legendary: return "#FF8000"   // Orange
        }
    }

    var sparkleIntensity: Float {
        switch self {
        case .common: return 0.0
        case .uncommon: return 0.2
        case .rare: return 0.4
        case .epic: return 0.6
        case .legendary: return 1.0
        }
    }
}

/// Where an artifact can be discovered
enum DiscoveryLocation: String, Codable {
    case anywhere
    case specificRoom         // E.g., temple, palace
    case nearCharacter        // Discovered during conversation
    case mysteryReward        // Unlocked by solving mystery
    case timeline             // Found on timeline exploration
    case hidden               // Requires special action to reveal

    var hint: String {
        switch self {
        case .anywhere:
            return "Can be found anywhere in the era"
        case .specificRoom:
            return "Found in a specific location"
        case .nearCharacter:
            return "Talk to historical figures to discover"
        case .mysteryReward:
            return "Solve mysteries to unlock"
        case .timeline:
            return "Explore the timeline carefully"
        case .hidden:
            return "Look closely for hidden clues"
        }
    }
}

/// How the artifact can be interacted with
enum InteractionType: String, Codable {
    case examine              // Can be picked up and examined
    case read                 // Text content to read
    case use                  // Can be used/activated
    case assemble             // Multi-part puzzle
    case compare              // Compare with other artifacts

    var instructions: String {
        switch self {
        case .examine:
            return "Pinch to pick up, rotate to examine all sides"
        case .read:
            return "Tap to open and read the content"
        case .use:
            return "Tap to activate or use this item"
        case .assemble:
            return "Find all pieces and assemble them together"
        case .compare:
            return "Place next to similar artifacts to compare"
        }
    }
}

/// Learning objective associated with artifact
struct LearningObjective: Codable, Hashable {
    let id: String
    let concept: String
    let description: String
    let bloomsLevel: BloomsLevel

    enum BloomsLevel: String, Codable {
        case remember
        case understand
        case apply
        case analyze
        case evaluate
        case create

        var level: Int {
            switch self {
            case .remember: return 1
            case .understand: return 2
            case .apply: return 3
            case .analyze: return 4
            case .evaluate: return 5
            case .create: return 6
            }
        }
    }
}

// MARK: - Artifact Progress

/// Tracks player interaction with an artifact
struct ArtifactProgress: Codable {
    let artifactID: String
    var discoveryDate: Date?
    var examinationCount: Int = 0
    var timeSpentExamining: TimeInterval = 0
    var hasReadAllContent: Bool = false
    var relatedArtifactsExamined: Set<String> = []
    var quizScore: Float?  // 0.0 - 1.0
    var notes: String = ""

    var isDiscovered: Bool {
        discoveryDate != nil
    }

    var isMastered: Bool {
        hasReadAllContent &&
        examinationCount >= 3 &&
        (quizScore ?? 0) >= 0.8
    }

    mutating func recordExamination(duration: TimeInterval) {
        examinationCount += 1
        timeSpentExamining += duration
    }

    mutating func recordDiscovery() {
        if discoveryDate == nil {
            discoveryDate = Date()
        }
    }
}

// MARK: - Artifact Factory

extension Artifact {
    /// Create a sample artifact for testing
    static func sample(id: String = "sample_artifact",
                      era: HistoricalEra = .ancientEgypt,
                      category: ArtifactCategory = .everydayObject) -> Artifact {
        Artifact(
            id: id,
            name: "Ancient Pottery Shard",
            era: era,
            category: category,
            description: "A fragment of pottery from daily life in ancient times.",
            historicalContext: "Pottery like this was used for storing food and water.",
            dateCreated: "1400 BCE",
            origin: "Thebes, Egypt",
            learningObjectives: [
                LearningObjective(
                    id: "pottery_making",
                    concept: "Ancient Pottery Techniques",
                    description: "Understand how ancient people created and used pottery",
                    bloomsLevel: .understand
                )
            ],
            funFacts: [
                "Ancient Egyptian pottery was made without a potter's wheel",
                "The red clay came from the Nile River banks"
            ],
            discoveryHints: [
                "Look near the river",
                "Check the marketplace"
            ],
            rarity: .common,
            modelResourceName: "pottery_shard_01",
            thumbnailImageName: "pottery_shard_thumb"
        )
    }
}

// MARK: - Codable Conformance

extension Artifact {
    enum CodingKeys: String, CodingKey {
        case id, name, era, category, description, historicalContext
        case dateCreated, origin, learningObjectives, curriculumStandards
        case funFacts, relatedArtifacts, discoveryHints, discoveryLocation
        case rarity, requiredLevel, modelResourceName, thumbnailImageName
        case interactionType, createdDate, lastModifiedDate
    }
}
