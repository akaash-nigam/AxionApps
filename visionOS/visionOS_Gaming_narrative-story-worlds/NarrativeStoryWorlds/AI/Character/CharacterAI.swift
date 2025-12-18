import Foundation

/// AI engine for character behavior, personality, and emotional responses
@MainActor
class CharacterAI {

    // MARK: - Properties
    private var character: Character
    private var memory: CharacterMemory

    // MARK: - Initialization
    init(character: Character) {
        self.character = character
        self.memory = CharacterMemory(characterID: character.id)
    }

    // MARK: - Behavior Generation

    /// Generate contextual behavior based on personality, emotion, and situation
    func generateBehavior(context: StoryContext) -> CharacterAction {
        // Combine personality + emotional state + memory
        let personality = character.personality
        let emotion = character.emotionalState

        // Determine action based on personality traits
        if emotion.stress > 0.7 {
            // High stress overrides personality somewhat
            return generateStressResponse(context: context)
        }

        // Normal behavior based on personality
        if personality.extraversion > 0.6 {
            return .approach // Extroverts approach situations
        } else if personality.neuroticism > 0.6 {
            return .hesitate // Neurotic characters hesitate
        } else {
            return .observe // Default: observe before acting
        }
    }

    /// Update emotional state based on story events
    func updateEmotionalState(event: StoryEvent) {
        var newState = character.emotionalState

        switch event.type {
        case .playerChoice(let choice):
            if choice.isPositiveForCharacter {
                newState.trust = min(1.0, newState.trust + 0.1)
                newState.stress = max(0.0, newState.stress - 0.05)
            } else {
                newState.trust = max(0.0, newState.trust - 0.15)
                newState.stress = min(1.0, newState.stress + 0.1)
            }

        case .revelation(let secret):
            newState.stress = min(1.0, newState.stress + 0.2)
            newState.fear = min(1.0, newState.fear + 0.15)

        case .support:
            newState.trust = min(1.0, newState.trust + 0.15)
            newState.currentEmotion = .happy

        case .betrayal:
            newState.trust = max(0.0, newState.trust - 0.3)
            newState.currentEmotion = .angry
        }

        // Record event in emotional history
        newState.history.append(EmotionalEvent(
            timestamp: Date(),
            trigger: event.description,
            emotionBefore: character.emotionalState.currentEmotion,
            emotionAfter: newState.currentEmotion,
            intensity: newState.intensity
        ))

        character.emotionalState = newState
    }

    /// Determine appropriate reaction to player's choice
    func generateReaction(to choice: ChoiceOption) -> CharacterReaction {
        let personality = character.personality
        let emotionalState = character.emotionalState

        // Calculate emotional impact
        let impactScore = calculateEmotionalImpact(choice, personality: personality)

        // Generate facial expression
        let expression: FacialExpression
        if impactScore > 0.5 {
            expression = emotionalState.trust > 0.6 ? .smile : .concern
        } else if impactScore < -0.5 {
            expression = .frown
        } else {
            expression = .neutral
        }

        // Generate body language
        let bodyLanguage: BodyLanguage
        if choice.relationshipImpacts[character.id] ?? 0 > 0 {
            bodyLanguage = .openPosture
        } else if choice.relationshipImpacts[character.id] ?? 0 < 0 {
            bodyLanguage = .defensivePosture
        } else {
            bodyLanguage = .neutral
        }

        // Determine if character moves closer or farther
        let distanceChange: Float
        if emotionalState.trust > 0.7 {
            distanceChange = -0.2 // Move closer
        } else if emotionalState.trust < 0.3 {
            distanceChange = 0.3 // Move away
        } else {
            distanceChange = 0 // Stay put
        }

        return CharacterReaction(
            facialExpression: expression,
            bodyLanguage: bodyLanguage,
            distanceChange: distanceChange,
            emotionalIntensity: abs(impactScore)
        )
    }

    /// Record interaction in character memory
    func recordInteraction(_ interaction: InteractionRecord) {
        memory.interactions.append(interaction)
        character.relationshipWithPlayer.interactions.append(interaction)
    }

    // MARK: - Private Methods

    private func generateStressResponse(context: StoryContext) -> CharacterAction {
        let personality = character.personality

        if personality.conscientiousness > 0.6 {
            return .focusOnProblem // Organized approach to stress
        } else if personality.neuroticism > 0.7 {
            return .panic // Overwhelmed by stress
        } else {
            return .seekHelp // Ask for assistance
        }
    }

    private func calculateEmotionalImpact(_ choice: ChoiceOption, personality: Personality) -> Float {
        var impact: Float = 0

        // Base impact from choice
        if let relationshipImpact = choice.relationshipImpacts[character.id] {
            impact = relationshipImpact
        }

        // Modify based on personality
        if personality.agreeableness > 0.7 {
            // Agreeable characters are more affected by relationship changes
            impact *= 1.5
        }

        if personality.openness > 0.7 {
            // Open characters appreciate novel choices
            impact += 0.1
        }

        return impact
    }
}

// MARK: - Supporting Types

struct CharacterMemory: Codable {
    let characterID: UUID
    var conversationHistory: [DialogueNode] = []
    var playerChoices: [ChoiceOption] = []
    var sharedExperiences: [String] = []
    var emotionalMoments: [EmotionalMoment] = []
    var interactions: [InteractionRecord] = []
}

struct EmotionalMoment: Codable {
    let timestamp: Date
    let description: String
    let intensity: Float
    let emotion: Emotion
}

enum CharacterAction {
    case approach
    case retreat
    case observe
    case hesitate
    case focusOnProblem
    case panic
    case seekHelp
}

struct CharacterReaction {
    let facialExpression: FacialExpression
    let bodyLanguage: BodyLanguage
    let distanceChange: Float
    let emotionalIntensity: Float
}

enum FacialExpression {
    case smile
    case frown
    case concern
    case surprise
    case neutral
    case angry
    case sad
}

enum BodyLanguage {
    case openPosture
    case defensivePosture
    case neutral
    case leaning
    case crossing
}

struct StoryContext {
    let currentScene: Scene?
    let recentEvents: [StoryEvent]
    let activeCharacters: [Character]
    let playerRelationshipLevel: Float
}

struct StoryEvent {
    let type: EventType
    let description: String
    var isPositiveForCharacter: Bool = false

    enum EventType {
        case playerChoice(ChoiceOption)
        case revelation(String)
        case support
        case betrayal
    }
}
