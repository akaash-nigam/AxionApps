import Foundation
import CoreML

/// AI system for generating dynamic, context-aware dialogue
@MainActor
class DialogueGenerator {

    // MARK: - Properties
    // In production, this would be an actual Core ML model
    // For now, we'll use template-based generation
    private let templates: DialogueTemplates

    init() {
        self.templates = DialogueTemplates()
    }

    // MARK: - Dialogue Generation

    /// Generate contextual dialogue based on character state and situation
    func generateDialogue(
        context: DialogueContext,
        personality: Personality,
        emotion: EmotionalState
    ) async throws -> String {
        // In production, this would use a Core ML model for generation
        // For now, use template-based system with personality filtering

        let baseDialogue = selectTemplate(for: context, emotion: emotion)
        let personalizedDialogue = applyPersonalityVoice(
            baseDialogue,
            personality: personality
        )
        let emotionalDialogue = applyEmotionalTone(
            personalizedDialogue,
            emotion: emotion
        )

        return emotionalDialogue
    }

    /// Generate multiple variations of the same dialogue line
    func generateVariations(baseLine: String, count: Int) async -> [String] {
        var variations: [String] = [baseLine]

        for i in 1..<count {
            // Generate variations by adjusting word choice and structure
            let variation = await createVariation(baseLine, index: i)
            variations.append(variation)
        }

        return variations
    }

    /// Generate dynamic response based on player's choice
    func generateResponseTo(
        playerChoice: ChoiceOption,
        character: Character
    ) async -> String {
        let context = DialogueContext(
            recentEvents: [],
            relationshipLevel: character.relationshipWithPlayer.trustLevel,
            narrativePhase: .rising,
            conversationTone: determineConversationTone(
                choice: playerChoice,
                relationship: character.relationshipWithPlayer.trustLevel
            )
        )

        return try! await generateDialogue(
            context: context,
            personality: character.personality,
            emotion: character.emotionalState
        )
    }

    // MARK: - Private Methods

    private func selectTemplate(for context: DialogueContext, emotion: EmotionalState) -> String {
        switch context.conversationTone {
        case .friendly:
            return templates.friendly[emotion.currentEmotion] ?? templates.neutral

        case .tense:
            return templates.tense[emotion.currentEmotion] ?? templates.neutral

        case .intimate:
            if context.relationshipLevel > 0.7 {
                return templates.intimate[emotion.currentEmotion] ?? templates.neutral
            } else {
                return templates.awkward
            }

        case .professional:
            return templates.professional[emotion.currentEmotion] ?? templates.neutral
        }
    }

    private func applyPersonalityVoice(_ dialogue: String, personality: Personality) -> String {
        var modifiedDialogue = dialogue

        // High openness → more descriptive, creative language
        if personality.openness > 0.7 {
            modifiedDialogue = addCreativeLanguage(modifiedDialogue)
        }

        // High extraversion → more enthusiastic
        if personality.extraversion > 0.7 {
            modifiedDialogue = addEnthusiasm(modifiedDialogue)
        }

        // High conscientiousness → more formal, structured
        if personality.conscientiousness > 0.7 {
            modifiedDialogue = makeFormal(modifiedDialogue)
        }

        // High agreeableness → softer language
        if personality.agreeableness > 0.7 {
            modifiedDialogue = softenLanguage(modifiedDialogue)
        }

        // High neuroticism → more hesitant, uncertain
        if personality.neuroticism > 0.7 {
            modifiedDialogue = addHesitation(modifiedDialogue)
        }

        return modifiedDialogue
    }

    private func applyEmotionalTone(_ dialogue: String, emotion: EmotionalState) -> String {
        var toned = dialogue

        switch emotion.currentEmotion {
        case .happy:
            toned = addPositiveInflection(toned)
        case .sad:
            toned = addSadness(toned)
        case .angry:
            toned = makeAssertive(toned)
        case .fearful:
            toned = addUncertainty(toned)
        case .surprised:
            toned = addExclamation(toned)
        default:
            break
        }

        return toned
    }

    private func createVariation(_ baseLine: String, index: Int) async -> String {
        // Simple variation: change some words
        var varied = baseLine

        let synonyms: [String: [String]] = [
            "think": ["believe", "suppose", "imagine"],
            "want": ["need", "wish", "desire"],
            "good": ["great", "wonderful", "excellent"],
            "bad": ["terrible", "awful", "unfortunate"]
        ]

        for (word, replacements) in synonyms {
            if varied.contains(word) && index < replacements.count {
                varied = varied.replacingOccurrences(of: word, with: replacements[index % replacements.count])
            }
        }

        return varied
    }

    private func determineConversationTone(choice: ChoiceOption, relationship: Float) -> ConversationTone {
        switch choice.emotionalTone {
        case .happy, .loving:
            return .friendly
        case .angry:
            return .tense
        case .sad, .fearful:
            return relationship > 0.6 ? .intimate : .professional
        default:
            return .professional
        }
    }

    // Helper methods for language modification
    private func addCreativeLanguage(_ text: String) -> String {
        // Add metaphors or descriptive words
        return text
    }

    private func addEnthusiasm(_ text: String) -> String {
        return text + "!"
    }

    private func makeFormal(_ text: String) -> String {
        return text.replacingOccurrences(of: " gonna ", with: " going to ")
                   .replacingOccurrences(of: " wanna ", with: " want to ")
    }

    private func softenLanguage(_ text: String) -> String {
        return text.replacingOccurrences(of: "must", with: "should")
                   .replacingOccurrences(of: "demand", with: "ask")
    }

    private func addHesitation(_ text: String) -> String {
        return "I... " + text.replacingOccurrences(of: "I know", with: "I think")
    }

    private func addPositiveInflection(_ text: String) -> String {
        return text
    }

    private func addSadness(_ text: String) -> String {
        return text.replacingOccurrences(of: "!", with: "...")
    }

    private func makeAssertive(_ text: String) -> String {
        return text.replacingOccurrences(of: "maybe", with: "definitely")
    }

    private func addUncertainty(_ text: String) -> String {
        return text.replacingOccurrences(of: "I will", with: "I might")
    }

    private func addExclamation(_ text: String) -> String {
        return text + "!"
    }
}

// MARK: - Supporting Types

struct DialogueContext {
    let recentEvents: [String]
    let relationshipLevel: Float
    let narrativePhase: StoryPhase
    let conversationTone: ConversationTone
}

enum StoryPhase {
    case introduction
    case rising
    case climax
    case falling
    case resolution
}

enum ConversationTone {
    case friendly
    case tense
    case intimate
    case professional
}

/// Template library for dialogue generation
struct DialogueTemplates {
    let neutral = "I see."

    let friendly: [Emotion: String] = [
        .happy: "That's wonderful! I'm so glad to hear it.",
        .sad: "I understand. That must be difficult.",
        .neutral: "I appreciate you sharing that with me."
    ]

    let tense: [Emotion: String] = [
        .angry: "This isn't what I expected from you.",
        .fearful: "I'm not sure I can trust this situation.",
        .neutral: "We need to talk about this."
    ]

    let intimate: [Emotion: String] = [
        .loving: "You mean everything to me.",
        .sad: "I wish things were different between us.",
        .happy: "Being with you makes everything better."
    ]

    let professional: [Emotion: String] = [
        .neutral: "Let's focus on what we can accomplish.",
        .happy: "This is progressing well.",
        .angry: "This is unacceptable."
    ]

    let awkward = "I... I'm not sure how to say this."
}
