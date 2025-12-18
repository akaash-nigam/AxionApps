import Foundation
import RealityKit

// MARK: - Historical Era
struct HistoricalEra: Codable, Identifiable, Hashable {
    let id: UUID
    let name: String
    let period: String  // e.g., "3100 BCE - 30 BCE"
    let civilization: String
    let difficulty: DifficultyLevel
    let description: String
    let artifacts: [UUID]  // References to artifacts
    let characters: [HistoricalCharacter]
    let mysteries: [UUID]  // References to mysteries
    let unlockRequirements: UnlockRequirements
    var isUnlocked: Bool = false

    // Assets
    let environmentAssets: String  // Folder name for environment assets
    let thumbnailImage: String
    let iconImage: String

    // Educational
    let educationalStandards: [String]  // CCSS codes
    let learningObjectives: [String]
    let keyHistoricalFacts: [String]

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: HistoricalEra, rhs: HistoricalEra) -> Bool {
        lhs.id == rhs.id
    }

    // Predefined eras
    static let ancientEgypt = HistoricalEra(
        id: UUID(),
        name: "Ancient Egypt",
        period: "3100 BCE - 30 BCE",
        civilization: "Egyptian",
        difficulty: .beginner,
        description: "Explore the land of pyramids, pharaohs, and the mighty Nile River.",
        artifacts: [],
        characters: [],
        mysteries: [],
        unlockRequirements: UnlockRequirements(minimumLevel: 1),
        isUnlocked: true,
        environmentAssets: "AncientEgypt",
        thumbnailImage: "egypt_thumbnail",
        iconImage: "egypt_icon",
        educationalStandards: ["CCSS.ELA-LITERACY.RH.6-8.1"],
        learningObjectives: ["Understand ancient Egyptian society", "Learn about hieroglyphics"],
        keyHistoricalFacts: ["The pyramids were built around 2560 BCE", "Cleopatra was the last pharaoh"]
    )
}

// MARK: - Artifact
struct Artifact: Codable, Identifiable, Hashable {
    let id: UUID
    let name: String
    let era: HistoricalEra
    let type: ArtifactType
    let rarity: ArtifactRarity
    let description: String
    let historicalContext: String
    let period: String
    let material: Material
    let dimensions: Dimensions

    // 3D Model
    let modelResource: String
    let thumbnailImage: String

    // Interaction
    let interactionPoints: [InteractionPoint]
    let mass: Float  // in kg

    // Educational
    let educationalValue: [String]  // Learning points
    let relatedFacts: [String]
    let primarySources: [String]

    // Discovery
    let unlockConditions: [Condition]
    var isDiscovered: Bool = false

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Artifact, rhs: Artifact) -> Bool {
        lhs.id == rhs.id
    }
}

enum ArtifactType: String, Codable {
    case pottery
    case jewelry
    case tool
    case weapon
    case document
    case sculpture
    case textile
    case coin
    case building
    case other
}

enum ArtifactRarity: String, Codable {
    case common
    case uncommon
    case rare
    case epic
    case legendary

    var color: String {
        switch self {
        case .common: return "gray"
        case .uncommon: return "green"
        case .rare: return "blue"
        case .epic: return "purple"
        case .legendary: return "gold"
        }
    }
}

enum Material: String, Codable {
    case pottery
    case metal
    case stone
    case wood
    case textile
    case papyrus
    case glass
    case bone
}

struct Dimensions: Codable {
    let width: Float
    let height: Float
    let depth: Float
}

struct InteractionPoint: Codable, Identifiable {
    let id: UUID
    let name: String
    let position: SIMD3<Float>
    let description: String
    let educationalContent: String
}

// MARK: - Historical Character
struct HistoricalCharacter: Codable, Identifiable, Hashable {
    let id: UUID
    let name: String
    let era: HistoricalEra
    let role: String  // e.g., "Pharaoh", "Philosopher", "Merchant"
    let biography: String
    let knowledgeDomains: [String]
    let personalityTraits: [PersonalityTrait]
    let teachingStyle: TeachingStyle

    // Visual
    let modelResource: String
    let portraitImage: String

    // AI Configuration
    let dialogueSystemPrompt: String
    let conversationStarters: [String]

    // Educational
    let historicalAccuracy: Double  // 0.0-1.0
    let educationalFocus: [String]

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: HistoricalCharacter, rhs: HistoricalCharacter) -> Bool {
        lhs.id == rhs.id
    }
}

enum PersonalityTrait: String, Codable {
    case wise
    case patient
    case enthusiastic
    case strict
    case humorous
    case serious
    case kind
    case ambitious
    case cautious
    case bold
}

enum TeachingStyle: String, Codable {
    case socratic  // Question-based
    case demonstrative  // Show and tell
    case narrative  // Storytelling
    case interactive  // Hands-on
    case lecture  // Direct instruction

    var description: String {
        switch self {
        case .socratic:
            return "Asks questions to guide learning"
        case .demonstrative:
            return "Shows examples and demonstrates concepts"
        case .narrative:
            return "Tells engaging stories to teach"
        case .interactive:
            return "Encourages hands-on exploration"
        case .lecture:
            return "Provides direct instruction"
        }
    }
}

// MARK: - Mystery
struct Mystery: Codable, Identifiable {
    let id: UUID
    let title: String
    let era: HistoricalEra
    let difficulty: DifficultyLevel
    let description: String
    let story: String
    let objectives: [MysteryObjective]
    let clues: [Clue]
    let solution: String
    let educationalStandards: [String]
    let learningOutcomes: [String]
    let estimatedDuration: TimeInterval  // in seconds
    let requiredArtifacts: [UUID]
    var isCompleted: Bool = false
}

struct MysteryObjective: Codable, Identifiable {
    let id: UUID
    let description: String
    let required: Bool
    var completed: Bool = false
}

struct Clue: Codable, Identifiable {
    let id: UUID
    let description: String
    let location: SIMD3<Float>?
    let relatedArtifact: UUID?
    let relatedCharacter: UUID?
    let hintText: String
    var discovered: Bool = false
}

enum DifficultyLevel: String, Codable {
    case beginner
    case intermediate
    case advanced
    case expert

    var description: String {
        switch self {
        case .beginner: return "Ages 8-10"
        case .intermediate: return "Ages 11-13"
        case .advanced: return "Ages 14-16"
        case .expert: return "Ages 17+"
        }
    }
}

// MARK: - Player Progress
struct PlayerProgress: Codable {
    var id: UUID
    var age: Int
    var gradeLevel: Int
    var currentLevel: Int = 1
    var experiencePoints: Int = 0
    var exploredEras: Set<UUID> = []
    var discoveredArtifacts: Set<UUID> = []
    var completedMysteries: Set<UUID> = []
    var metCharacters: Set<UUID> = []
    var learningProfile: LearningProfile
    var assessmentResults: [AssessmentResult]
    var playTime: TimeInterval = 0
    var lastPlayed: Date

    // Skills
    var researchSkill: Int = 1
    var observationSkill: Int = 1
    var conversationSkill: Int = 1
    var deductionSkill: Int = 1

    // Achievements
    var achievements: [UUID] = []

    var experienceToNextLevel: Int {
        return currentLevel * 100
    }

    mutating func gainExperience(_ xp: Int, for activity: Activity) {
        experiencePoints += xp

        // Level up
        while experiencePoints >= experienceToNextLevel {
            experiencePoints -= experienceToNextLevel
            currentLevel += 1
        }

        // Improve relevant skill
        switch activity {
        case .artifactDiscovery:
            observationSkill = min(10, observationSkill + 1)
        case .mysteryCompletion:
            deductionSkill = min(10, deductionSkill + 1)
        case .characterConversation:
            conversationSkill = min(10, conversationSkill + 1)
        default:
            break
        }
    }
}

struct LearningProfile: Codable {
    var preferredLearningStyle: LearningStyle = .visual
    var difficultyPreference: DifficultyLevel = .intermediate
    var knowledgeAreas: [String: Double] = [:]  // Topic -> Mastery (0.0-1.0)
    var strengthAreas: [String] = []
    var improvementAreas: [String] = []
    var lastAssessment: Date?
}

enum LearningStyle: String, Codable {
    case visual
    case auditory
    case kinesthetic
    case reading
}

struct AssessmentResult: Codable, Identifiable {
    let id: UUID
    let date: Date
    let topic: String
    let score: Double  // 0.0-1.0
    let questionsAttempted: Int
    let correctAnswers: Int
    let timeSpent: TimeInterval
    let improvementSuggestions: [String]
}

// MARK: - Room Model
struct RoomModel: Codable {
    let id: UUID
    let bounds: SIMD3<Float>
    let surfaces: [Surface]
    let calibrationDate: Date
}

struct Surface: Codable, Identifiable {
    let id: UUID
    let type: SurfaceType
    let position: SIMD3<Float>
    let normal: SIMD3<Float>
    let bounds: Bounds2D
    var transform: simd_float4x4

    enum SurfaceType: String, Codable {
        case floor
        case wall
        case ceiling
        case table
        case desk
        case other
    }
}

struct Bounds2D: Codable {
    let width: Float
    let height: Float

    var area: Float {
        return width * height
    }
}

// MARK: - Unlock Requirements
struct UnlockRequirements: Codable {
    let minimumLevel: Int
    let requiredArtifacts: [UUID] = []
    let requiredMysteries: [UUID] = []
    let requiredExperience: Int = 0

    func isSatisfied(by progress: PlayerProgress) -> Bool {
        guard progress.currentLevel >= minimumLevel else { return false }
        guard progress.experiencePoints >= requiredExperience else { return false }

        for artifactId in requiredArtifacts {
            if !progress.discoveredArtifacts.contains(artifactId) {
                return false
            }
        }

        for mysteryId in requiredMysteries {
            if !progress.completedMysteries.contains(mysteryId) {
                return false
            }
        }

        return true
    }
}

struct Condition: Codable {
    let type: ConditionType
    let value: String

    enum ConditionType: String, Codable {
        case minimumLevel
        case discoveredArtifact
        case completedMystery
        case metCharacter
        case exploredEra
    }
}

// MARK: - Achievement
struct Achievement: Codable, Identifiable {
    let id: UUID
    let name: String
    let description: String
    let iconName: String
    let requirements: [Condition]
    let experienceReward: Int
    let unlocks: [UUID]  // What this achievement unlocks
}

// MARK: - Placed Artifact
struct PlacedArtifact {
    let artifact: Artifact
    let position: SIMD3<Float>
    let rotation: simd_quatf
    let surface: Surface
    let isHidden: Bool
}

// MARK: - Conversation Context
struct ConversationContext {
    let character: HistoricalCharacter
    let studentLevel: EducationLevel
    let currentTopic: String?
    let previousTopics: [String]
    let relatedArtifacts: [Artifact]
    let currentMystery: Mystery?
}

enum EducationLevel: String, Codable {
    case elementary  // Ages 8-11
    case middle      // Ages 12-14
    case high        // Ages 15-18
    case adult       // Ages 18+

    init(age: Int) {
        switch age {
        case 8...11:
            self = .elementary
        case 12...14:
            self = .middle
        case 15...17:
            self = .high
        default:
            self = .adult
        }
    }
}

// MARK: - Gestures
struct PinchGesture {
    let chirality: HandChirality
    let position: SIMD3<Float>
    let strength: Float  // 0.0-1.0
}

struct GrabGesture {
    let chirality: HandChirality
    let position: SIMD3<Float>
    let strength: Float
}

struct PointGesture {
    let chirality: HandChirality
    let origin: SIMD3<Float>
    let direction: SIMD3<Float>
}

struct TwoHandedGesture {
    let leftPosition: SIMD3<Float>
    let rightPosition: SIMD3<Float>
    let center: SIMD3<Float>
    let distance: Float
}

enum HandChirality {
    case left
    case right
}

// MARK: - Audio
struct PositionedAudioSource {
    let file: String
    let position: SIMD3<Float>
    let volume: Float
    let looping: Bool
    let falloffDistance: Float
}

// MARK: - Input Delegate Protocol
protocol InputSystemDelegate: AnyObject {
    func didDetectPinch(at position: SIMD3<Float>)
    func didDetectGaze(at entity: Entity)
}
