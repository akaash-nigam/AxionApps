import Foundation

/// Represents a character in a theatrical performance
struct CharacterModel: Codable, Identifiable, Sendable {
    let id: UUID
    let name: String
    let role: CharacterRole

    // AI Personality
    let personality: PersonalityTraits
    var emotionalState: EmotionalState
    let relationshipMap: [UUID: Relationship]

    // Narrative
    let backstory: String
    let motivations: [String]
    let currentObjectives: [Objective]

    // Appearance
    let visualAssetID: String
    let costumes: [CostumeData]
    let animations: [AnimationData]

    // Performance
    let dialogueTree: DialogueTree
    let voiceProfile: VoiceProfile
    let behaviorPatterns: [BehaviorPattern]

    init(
        id: UUID = UUID(),
        name: String,
        role: CharacterRole,
        personality: PersonalityTraits,
        emotionalState: EmotionalState,
        relationshipMap: [UUID: Relationship] = [:],
        backstory: String,
        motivations: [String],
        currentObjectives: [Objective],
        visualAssetID: String,
        costumes: [CostumeData],
        animations: [AnimationData],
        dialogueTree: DialogueTree,
        voiceProfile: VoiceProfile,
        behaviorPatterns: [BehaviorPattern]
    ) {
        self.id = id
        self.name = name
        self.role = role
        self.personality = personality
        self.emotionalState = emotionalState
        self.relationshipMap = relationshipMap
        self.backstory = backstory
        self.motivations = motivations
        self.currentObjectives = currentObjectives
        self.visualAssetID = visualAssetID
        self.costumes = costumes
        self.animations = animations
        self.dialogueTree = dialogueTree
        self.voiceProfile = voiceProfile
        self.behaviorPatterns = behaviorPatterns
    }
}

// MARK: - Supporting Types

enum CharacterRole: String, Codable, Sendable {
    case protagonist
    case antagonist
    case supporting
    case minor
    case narrator
}

struct PersonalityTraits: Codable, Sendable {
    // Big Five personality model (0.0 - 1.0)
    let openness: Float
    let conscientiousness: Float
    let extraversion: Float
    let agreeableness: Float
    let neuroticism: Float

    // Custom theatrical traits (0.0 - 1.0)
    let honor: Float
    let ambition: Float
    let loyalty: Float
    let compassion: Float

    init(
        openness: Float = 0.5,
        conscientiousness: Float = 0.5,
        extraversion: Float = 0.5,
        agreeableness: Float = 0.5,
        neuroticism: Float = 0.5,
        honor: Float = 0.5,
        ambition: Float = 0.5,
        loyalty: Float = 0.5,
        compassion: Float = 0.5
    ) {
        self.openness = openness
        self.conscientiousness = conscientiousness
        self.extraversion = extraversion
        self.agreeableness = agreeableness
        self.neuroticism = neuroticism
        self.honor = honor
        self.ambition = ambition
        self.loyalty = loyalty
        self.compassion = compassion
    }
}

struct EmotionalState: Codable, Sendable {
    let primaryEmotion: Emotion
    let emotionIntensity: Float // 0.0 - 1.0
    let emotionTrigger: String?
    let emotionDuration: TimeInterval

    init(
        primaryEmotion: Emotion,
        emotionIntensity: Float,
        emotionTrigger: String? = nil,
        emotionDuration: TimeInterval = 60.0
    ) {
        self.primaryEmotion = primaryEmotion
        self.emotionIntensity = emotionIntensity
        self.emotionTrigger = emotionTrigger
        self.emotionDuration = emotionDuration
    }
}

enum Emotion: String, Codable, Sendable {
    case joy, sadness, anger, fear, surprise, disgust
    case love, grief, guilt, pride, shame, anxiety
}

struct Relationship: Codable, Sendable {
    let targetCharacterID: UUID
    var trust: Float // 0.0 - 1.0
    var affection: Float // -1.0 to 1.0
    var respect: Float // 0.0 - 1.0
    var history: [RelationshipEvent]

    init(
        targetCharacterID: UUID,
        trust: Float = 0.5,
        affection: Float = 0.0,
        respect: Float = 0.5,
        history: [RelationshipEvent] = []
    ) {
        self.targetCharacterID = targetCharacterID
        self.trust = trust
        self.affection = affection
        self.respect = respect
        self.history = history
    }
}

struct RelationshipEvent: Codable, Sendable {
    let timestamp: Date
    let eventDescription: String
    let impactOnTrust: Float
    let impactOnAffection: Float
    let impactOnRespect: Float
}

struct Objective: Codable, Identifiable, Sendable {
    let id: UUID
    let description: String
    let priority: Int
    let isComplete: Bool
}

struct CostumeData: Codable, Identifiable, Sendable {
    let id: UUID
    let name: String
    let period: String
    let assetID: String
}

struct AnimationData: Codable, Identifiable, Sendable {
    let id: UUID
    let name: String
    let type: AnimationType
    let assetID: String
}

enum AnimationType: String, Codable, Sendable {
    case idle
    case walking
    case speaking
    case gesture
    case emotional
}

struct DialogueTree: Codable, Sendable {
    let rootNodeID: UUID
    let nodes: [DialogueNode]
}

struct DialogueNode: Codable, Identifiable, Sendable {
    let id: UUID
    let speakerID: UUID
    let text: String
    let emotion: Emotion
    let responses: [DialogueResponse]
}

struct DialogueResponse: Codable, Identifiable, Sendable {
    let id: UUID
    let text: String
    let nextNodeID: UUID?
    let consequences: [String]
}

struct VoiceProfile: Codable, Sendable {
    let pitch: Float
    let speed: Float
    let accent: String
    let timbre: String
}

struct BehaviorPattern: Codable, Identifiable, Sendable {
    let id: UUID
    let name: String
    let triggerCondition: String
    let behaviorDescription: String
}
