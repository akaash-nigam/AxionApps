import Foundation
import RealityKit

// MARK: - Story
struct Story: Identifiable, Codable {
    let id: UUID
    let title: String
    let genre: Genre
    let estimatedDuration: TimeInterval

    var chapters: [Chapter]
    var characters: [Character]
    var branches: [StoryBranch]
    var achievements: [Achievement]
}

enum Genre: String, Codable {
    case mystery
    case drama
    case sciFi
    case fantasy
    case thriller
    case romance
}

// MARK: - Chapter
struct Chapter: Identifiable, Codable {
    let id: UUID
    let title: String
    var scenes: [Scene]
    var completionState: CompletionState
}

enum CompletionState: String, Codable {
    case notStarted
    case inProgress
    case completed
}

// MARK: - Scene
struct Scene: Identifiable, Codable {
    let id: UUID
    let location: SceneLocation
    let characterIDs: [UUID]
    let storyBeats: [StoryBeat]
    let requiredFlags: Set<String>
    var spatialConfiguration: SpatialConfiguration
}

enum SceneLocation: String, Codable {
    case playerHome
    case characterHome
    case outdoor
    case abstract
}

// MARK: - Story Beat
struct StoryBeat: Identifiable, Codable {
    let id: UUID
    let type: BeatType
    let content: AnyBeatContent
    let emotionalWeight: Float
    let pacing: PacingHint
}

enum BeatType: String, Codable {
    case dialogue
    case choice
    case event
    case revelation
}

enum PacingHint: String, Codable {
    case slow
    case normal
    case fast
    case urgent
}

// MARK: - Beat Content (Type-erased)
struct AnyBeatContent: Codable {
    private let _content: Any

    init<T: Codable>(_ content: T) {
        self._content = content
    }

    func get<T>() -> T? {
        return _content as? T
    }

    // Codable conformance
    init(from decoder: Decoder) throws {
        // Implementation depends on actual beat content types
        _content = ""
    }

    func encode(to encoder: Encoder) throws {
        // Implementation depends on actual beat content types
    }
}

// MARK: - Dialogue
struct DialogueNode: Identifiable, Codable {
    let id: UUID
    let speakerID: UUID
    let text: String
    let audioClip: String? // Asset name

    let responses: [DialogueResponse]
    let conditions: [StoryCondition]

    let displayDuration: TimeInterval
    let autoAdvance: Bool

    let emotionalTone: Emotion
    let facialAnimation: String? // Animation name
}

struct DialogueResponse: Identifiable, Codable {
    let id: UUID
    let text: String
    let nextNodeID: UUID?

    let relationshipChange: [UUID: Float]
    let flagsToSet: Set<String>
    let emotionalImpact: EmotionalImpact
}

// MARK: - Choice
struct Choice: Identifiable, Codable {
    let id: UUID
    let prompt: String
    let options: [ChoiceOption]
    let timeLimit: TimeInterval?
    let emotionalContext: EmotionalContext
}

struct ChoiceOption: Identifiable, Codable {
    let id: UUID
    let text: String
    let icon: String?

    let storyBranchID: UUID?
    let relationshipImpacts: [UUID: Float]
    let flagsSet: Set<String>
    let emotionalTone: Emotion

    let spatialPosition: ChoicePosition
    let visualStyle: ChoiceStyle
}

enum ChoicePosition: String, Codable {
    case center
    case left
    case right
    case radial
}

enum ChoiceStyle: String, Codable {
    case standard
    case positive
    case negative
    case neutral
}

// MARK: - Character
struct Character: Identifiable, Codable {
    let id: UUID
    let name: String
    let bio: String

    var appearance: CharacterAppearance
    var personality: Personality
    var emotionalState: EmotionalState

    var narrativeRole: NarrativeRole
    var relationshipWithPlayer: Relationship
    var storyFlags: Set<String>
}

struct CharacterAppearance: Codable {
    let modelName: String
    let texturePaths: [String: String]
    let clothingLayers: [String]
}

struct Personality: Codable {
    var openness: Float
    var conscientiousness: Float
    var extraversion: Float
    var agreeableness: Float
    var neuroticism: Float

    var loyalty: Float
    var deception: Float
    var vulnerability: Float
}

struct EmotionalState: Codable {
    var currentEmotion: Emotion
    var intensity: Float
    var trust: Float
    var stress: Float
    var attraction: Float
    var fear: Float
    var history: [EmotionalEvent]
}

struct EmotionalEvent: Codable {
    let timestamp: Date
    let trigger: String
    let emotionBefore: Emotion
    let emotionAfter: Emotion
    let intensity: Float
}

enum Emotion: String, Codable {
    case neutral
    case happy
    case sad
    case angry
    case surprised
    case fearful
    case disgusted
    case loving
    case mysterious
}

enum EmotionalImpact: String, Codable {
    case positive
    case negative
    case neutral
    case complex
}

enum EmotionalContext: String, Codable {
    case calm
    case tense
    case urgent
    case intimate
}

enum NarrativeRole: String, Codable {
    case protagonist
    case antagonist
    case ally
    case mentor
    case mysterious
}

// MARK: - Relationship
struct Relationship: Codable {
    let characterID: UUID
    var trustLevel: Float = 0.5 // 0.0 to 1.0
    var bondLevel: BondLevel = .stranger
    var interactions: [InteractionRecord] = []
}

enum BondLevel: String, Codable {
    case stranger
    case acquaintance
    case friend
    case confidant
    case soulmate
    case nemesis
}

struct InteractionRecord: Codable {
    let timestamp: Date
    let type: InteractionType
    let outcome: InteractionOutcome
}

enum InteractionType: String, Codable {
    case conversation
    case choice
    case help
    case betray
}

enum InteractionOutcome: String, Codable {
    case positive
    case negative
    case neutral
}

// MARK: - Story Branch
struct StoryBranch: Identifiable, Codable {
    let id: UUID
    let name: String
    let condition: StoryCondition
    let scenes: [Scene]
}

struct StoryCondition: Codable {
    let requiredFlags: Set<String>
    let relationshipThresholds: [UUID: Float]
    let choiceHistory: [UUID] // Required previous choices
}

// MARK: - Spatial Configuration
struct SpatialConfiguration: Codable {
    var characterPositions: [UUID: Position] = [:]
    var objectPlacements: [String: Position] = [:]
    var lightingState: LightingConfiguration = LightingConfiguration()
    var environmentalEffects: [EnvironmentalEffect] = []

    struct Position: Codable {
        var x: Float = 0
        var y: Float = 0
        var z: Float = 0
    }
}

struct LightingConfiguration: Codable {
    var brightness: Float = 1.0
    var colorTemperature: Float = 6500 // Kelvin
    var mood: LightingMood = .neutral
}

enum LightingMood: String, Codable {
    case neutral
    case warm
    case cool
    case dramatic
    case intimate
}

struct EnvironmentalEffect: Codable {
    let type: EffectType
    let intensity: Float
    let position: SpatialConfiguration.Position?
}

enum EffectType: String, Codable {
    case particles
    case lighting
    case fog
    case colorGrading
}

// MARK: - Achievement
struct Achievement: Identifiable, Codable {
    let id: UUID
    let title: String
    let description: String
    let icon: String
    let condition: AchievementCondition
    var unlocked: Bool = false
}

enum AchievementCondition: Codable {
    case completeChapter(Int)
    case makeChoice(UUID)
    case reachBondLevel(BondLevel)
    case discoverSecret(String)
}

// MARK: - Story State
struct StoryState: Codable {
    var currentStoryID: UUID?
    var currentChapterID: UUID?
    var currentSceneID: UUID?

    var completedScenes: Set<UUID> = Set()
    var activeFlags: Set<String> = Set()
    var choiceHistory: [ChoiceRecord] = []

    var characterRelationships: [UUID: Relationship] = [:]
    var examinedObjects: Set<String> = Set()

    var spatialAnchors: [UUID: AnchorData] = [:]

    var playTime: TimeInterval = 0
    var lastSaveDate: Date?
    var version: String = "1.0.0"
}

struct AnchorData: Codable {
    let id: UUID
    let worldPosition: SIMD3<Float>
    let rotation: simd_quatf
    let associatedObjectID: String?
}

// MARK: - Codable Extensions for SIMD types
extension SIMD3: Codable where Scalar == Float {
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        let x = try container.decode(Float.self)
        let y = try container.decode(Float.self)
        let z = try container.decode(Float.self)
        self.init(x, y, z)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(self.x)
        try container.encode(self.y)
        try container.encode(self.z)
    }
}

extension simd_quatf: Codable {
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        let x = try container.decode(Float.self)
        let y = try container.decode(Float.self)
        let z = try container.decode(Float.self)
        let w = try container.decode(Float.self)
        self.init(ix: x, iy: y, iz: z, r: w)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(self.imag.x)
        try container.encode(self.imag.y)
        try container.encode(self.imag.z)
        try container.encode(self.real)
    }
}
