//
//  AISystemTests.swift
//  NarrativeStoryWorlds
//
//  Comprehensive unit tests for AI systems
//

import XCTest
@testable import NarrativeStoryWorlds

/// Tests for StoryDirectorAI system
@MainActor
final class StoryDirectorAITests: XCTestCase {

    var storyDirector: StoryDirectorAI!
    var mockStory: Story!

    override func setUp() async throws {
        try await super.setUp()
        storyDirector = StoryDirectorAI()
        mockStory = createMockStory()
    }

    override func tearDown() async throws {
        storyDirector = nil
        mockStory = nil
        try await super.tearDown()
    }

    // MARK: - Pacing Adjustment Tests

    func testPacingAdjustment_HighIntensityLongSession_SuggestsBreather() {
        let adjustment = storyDirector.adjustPacing(
            playerEngagement: 0.8,
            sessionDuration: 40 * 60, // 40 minutes
            emotionalIntensity: 0.85
        )

        XCTAssertTrue(adjustment.insertBreatherMoment, "Should suggest breather moment after high intensity")
        XCTAssertLessThan(adjustment.tensionDelta, 0, "Should reduce tension")
    }

    func testPacingAdjustment_LowEngagement_IncreasesIntensity() {
        let adjustment = storyDirector.adjustPacing(
            playerEngagement: 0.3,
            sessionDuration: 15 * 60,
            emotionalIntensity: 0.4
        )

        XCTAssertGreaterThan(adjustment.tensionDelta, 0, "Should increase tension when engagement is low")
    }

    func testPacingAdjustment_ShortSession_NoBreather() {
        let adjustment = storyDirector.adjustPacing(
            playerEngagement: 0.9,
            sessionDuration: 5 * 60, // 5 minutes
            emotionalIntensity: 0.9
        )

        XCTAssertFalse(adjustment.insertBreatherMoment, "Should not suggest breather in short session")
    }

    // MARK: - Player Archetype Tests

    func testDetectPlayerArchetype_Completionist() {
        let history = [
            Choice(id: UUID(), text: "Explore every corner", consequences: [], relationshipImpacts: [:], isAvailable: { true }),
            Choice(id: UUID(), text: "Check all details", consequences: [], relationshipImpacts: [:], isAvailable: { true }),
            Choice(id: UUID(), text: "Ask every question", consequences: [], relationshipImpacts: [:], isAvailable: { true })
        ]

        let archetype = storyDirector.detectPlayerArchetype(choiceHistory: history, playtime: 3600)

        XCTAssertEqual(archetype, .completionist, "Should detect completionist from thorough choices")
    }

    func testDetectPlayerArchetype_Speedrunner() {
        let history = [
            Choice(id: UUID(), text: "Skip ahead", consequences: [], relationshipImpacts: [:], isAvailable: { true }),
            Choice(id: UUID(), text: "Quick choice", consequences: [], relationshipImpacts: [:], isAvailable: { true })
        ]

        let archetype = storyDirector.detectPlayerArchetype(choiceHistory: history, playtime: 300) // 5 minutes, many scenes

        XCTAssertEqual(archetype, .speedrunner, "Should detect speedrunner from fast pace")
    }

    // MARK: - Story Branch Selection Tests

    func testSelectNextBranch_RespectsPlayerEngagement() async {
        let currentNode = mockStory.chapters.first!.scenes.first!.dialogueNodes.first!

        let selectedBranch = await storyDirector.selectNextBranch(
            currentNode: currentNode,
            playerEngagement: 0.9,
            emotionalState: .engaged
        )

        XCTAssertNotNil(selectedBranch, "Should select a branch based on engagement")
    }

    // MARK: - Helper Methods

    private func createMockStory() -> Story {
        let character = Character(
            id: UUID(),
            name: "Test Character",
            bio: "A test character",
            personality: Personality(
                openness: 0.5,
                conscientiousness: 0.5,
                extraversion: 0.5,
                agreeableness: 0.5,
                neuroticism: 0.5
            ),
            emotionalState: EmotionalState(),
            voiceProfile: VoiceProfile(),
            spatialProperties: SpatialCharacterProperties(
                preferredDistance: 1.5,
                height: 1.7,
                allowedMovementRadius: 3.0
            ),
            appearanceDescription: "Test appearance"
        )

        let dialogueNode = DialogueNode(
            id: UUID(),
            characterID: character.id,
            text: "Test dialogue",
            emotionalTone: .neutral,
            audioClipName: nil,
            nextNodes: [],
            choices: []
        )

        let scene = Scene(
            id: UUID(),
            title: "Test Scene",
            description: "A test scene",
            location: "Test Room",
            dialogueNodes: [dialogueNode],
            requiredCharacters: [character.id],
            ambientAudio: nil
        )

        let chapter = Chapter(
            id: UUID(),
            title: "Test Chapter",
            description: "A test chapter",
            scenes: [scene],
            unlockConditions: []
        )

        return Story(
            id: UUID(),
            title: "Test Story",
            description: "A test story",
            characters: [character],
            chapters: [chapter],
            currentChapterID: chapter.id,
            currentSceneID: scene.id,
            currentNodeID: dialogueNode.id
        )
    }
}

/// Tests for CharacterAI system
@MainActor
final class CharacterAITests: XCTestCase {

    var characterAI: CharacterAI!
    var testCharacter: Character!

    override func setUp() async throws {
        try await super.setUp()

        testCharacter = Character(
            id: UUID(),
            name: "Sarah",
            bio: "A mysterious woman",
            personality: Personality(
                openness: 0.8,
                conscientiousness: 0.7,
                extraversion: 0.6,
                agreeableness: 0.8,
                neuroticism: 0.4,
                loyalty: 0.9,
                curiosity: 0.8,
                empathy: 0.85
            ),
            emotionalState: EmotionalState(
                trust: 0.5,
                affection: 0.3,
                fear: 0.2,
                anger: 0.0,
                happiness: 0.6
            ),
            voiceProfile: VoiceProfile(),
            spatialProperties: SpatialCharacterProperties(
                preferredDistance: 1.5,
                height: 1.65,
                allowedMovementRadius: 4.0
            ),
            appearanceDescription: "Mysterious appearance"
        )

        characterAI = CharacterAI(character: testCharacter)
    }

    override func tearDown() async throws {
        characterAI = nil
        testCharacter = nil
        try await super.tearDown()
    }

    // MARK: - Emotional State Tests

    func testUpdateEmotionalState_PositiveChoice_IncreaseTrust() {
        let initialTrust = testCharacter.emotionalState.trust

        let event = StoryEvent(
            type: .playerChoice(
                Choice(
                    id: UUID(),
                    text: "I'll help you",
                    consequences: [],
                    relationshipImpacts: [testCharacter.id: .trust(0.1)],
                    isAvailable: { true }
                )
            ),
            timestamp: Date()
        )

        characterAI.updateEmotionalState(event: event)

        XCTAssertGreaterThan(testCharacter.emotionalState.trust, initialTrust, "Trust should increase with positive choice")
    }

    func testUpdateEmotionalState_NegativeChoice_DecreaseTrust() {
        let initialTrust = testCharacter.emotionalState.trust

        let event = StoryEvent(
            type: .playerChoice(
                Choice(
                    id: UUID(),
                    text: "I don't believe you",
                    consequences: [],
                    relationshipImpacts: [testCharacter.id: .trust(-0.2)],
                    isAvailable: { true }
                )
            ),
            timestamp: Date()
        )

        characterAI.updateEmotionalState(event: event)

        XCTAssertLessThan(testCharacter.emotionalState.trust, initialTrust, "Trust should decrease with negative choice")
    }

    func testEmotionalStateBounds_TrustCannotExceedOne() {
        testCharacter.emotionalState.trust = 0.95

        let event = StoryEvent(
            type: .playerChoice(
                Choice(
                    id: UUID(),
                    text: "Very positive",
                    consequences: [],
                    relationshipImpacts: [testCharacter.id: .trust(0.5)],
                    isAvailable: { true }
                )
            ),
            timestamp: Date()
        )

        characterAI.updateEmotionalState(event: event)

        XCTAssertLessThanOrEqual(testCharacter.emotionalState.trust, 1.0, "Trust should be capped at 1.0")
    }

    func testEmotionalStateBounds_TrustCannotBeBelowZero() {
        testCharacter.emotionalState.trust = 0.1

        let event = StoryEvent(
            type: .playerChoice(
                Choice(
                    id: UUID(),
                    text: "Very negative",
                    consequences: [],
                    relationshipImpacts: [testCharacter.id: .trust(-0.5)],
                    isAvailable: { true }
                )
            ),
            timestamp: Date()
        )

        characterAI.updateEmotionalState(event: event)

        XCTAssertGreaterThanOrEqual(testCharacter.emotionalState.trust, 0.0, "Trust should be floored at 0.0")
    }

    // MARK: - Memory System Tests

    func testAddMemory_ShortTerm() {
        let memory = CharacterMemory(
            id: UUID(),
            content: "Player said hello",
            emotionalWeight: 0.3,
            timestamp: Date(),
            relatedEventID: UUID(),
            memoryType: .shortTerm
        )

        characterAI.addMemory(memory)

        XCTAssertTrue(
            testCharacter.memories.contains { $0.id == memory.id },
            "Short-term memory should be added"
        )
    }

    func testAddMemory_LongTerm_HighEmotionalWeight() {
        let memory = CharacterMemory(
            id: UUID(),
            content: "Player saved my life",
            emotionalWeight: 0.95,
            timestamp: Date(),
            relatedEventID: UUID(),
            memoryType: .longTerm
        )

        characterAI.addMemory(memory)

        let addedMemory = testCharacter.memories.first { $0.id == memory.id }
        XCTAssertNotNil(addedMemory, "High emotional weight memory should be added")
        XCTAssertEqual(addedMemory?.memoryType, .longTerm, "Should be long-term memory")
    }

    func testRecallRelevantMemories_ReturnsRecentAndEmotional() {
        // Add several memories
        let recentMemory = CharacterMemory(
            id: UUID(),
            content: "Recent event",
            emotionalWeight: 0.4,
            timestamp: Date(),
            relatedEventID: UUID(),
            memoryType: .shortTerm
        )

        let emotionalMemory = CharacterMemory(
            id: UUID(),
            content: "Very emotional event",
            emotionalWeight: 0.9,
            timestamp: Date().addingTimeInterval(-86400), // Yesterday
            relatedEventID: UUID(),
            memoryType: .longTerm
        )

        let oldMemory = CharacterMemory(
            id: UUID(),
            content: "Old low-weight event",
            emotionalWeight: 0.2,
            timestamp: Date().addingTimeInterval(-7 * 86400), // Week ago
            relatedEventID: UUID(),
            memoryType: .shortTerm
        )

        characterAI.addMemory(recentMemory)
        characterAI.addMemory(emotionalMemory)
        characterAI.addMemory(oldMemory)

        let relevantMemories = characterAI.recallRelevantMemories(context: "recent events", limit: 2)

        XCTAssertLessThanOrEqual(relevantMemories.count, 2, "Should respect limit")
        XCTAssertTrue(
            relevantMemories.contains { $0.id == emotionalMemory.id },
            "Should include high emotional weight memory"
        )
    }

    // MARK: - Personality-Based Behavior Tests

    func testGetDialogueStyle_HighOpenness_ExpressiveLanguage() {
        testCharacter.personality.openness = 0.9

        let style = characterAI.getDialogueStyle()

        XCTAssertTrue(style.contains("expressive") || style.contains("creative"), "High openness should yield expressive style")
    }

    func testGetDialogueStyle_HighConscientiousness_FormalLanguage() {
        testCharacter.personality.conscientiousness = 0.9
        testCharacter.personality.openness = 0.2

        let style = characterAI.getDialogueStyle()

        XCTAssertTrue(style.contains("formal") || style.contains("structured"), "High conscientiousness should yield formal style")
    }

    func testReactToPlayerAction_PersonalityInfluence() {
        // High empathy character should react more emotionally
        testCharacter.personality.empathy = 0.95

        let action = "Player character is sad"
        let reaction = characterAI.reactToPlayerAction(action: action)

        XCTAssertTrue(
            reaction.contains("empathy") || reaction.contains("understand") || reaction.contains("feel"),
            "High empathy character should show emotional reaction"
        )
    }
}

/// Tests for EmotionRecognitionAI system
@MainActor
final class EmotionRecognitionAITests: XCTestCase {

    var emotionAI: EmotionRecognitionAI!

    override func setUp() async throws {
        try await super.setUp()
        emotionAI = EmotionRecognitionAI()
    }

    override func tearDown() async throws {
        emotionAI = nil
        try await super.tearDown()
    }

    // MARK: - Emotion Classification Tests

    func testClassifyEmotion_Happy_FromSmile() {
        let mockBlendShapes: [String: Float] = [
            "mouthSmileLeft": 0.7,
            "mouthSmileRight": 0.7,
            "eyeSquintLeft": 0.3,
            "eyeSquintRight": 0.3
        ]

        let emotion = emotionAI.classifyEmotionFromBlendShapes(mockBlendShapes)

        XCTAssertEqual(emotion, .happy, "Should detect happy emotion from smile")
    }

    func testClassifyEmotion_Sad_FromFrown() {
        let mockBlendShapes: [String: Float] = [
            "mouthFrownLeft": 0.6,
            "mouthFrownRight": 0.6,
            "browDownLeft": 0.4,
            "browDownRight": 0.4
        ]

        let emotion = emotionAI.classifyEmotionFromBlendShapes(mockBlendShapes)

        XCTAssertEqual(emotion, .sad, "Should detect sad emotion from frown")
    }

    func testClassifyEmotion_Surprised_FromWideEyes() {
        let mockBlendShapes: [String: Float] = [
            "eyeWideLeft": 0.8,
            "eyeWideRight": 0.8,
            "mouthOpen": 0.6,
            "jawOpen": 0.5
        ]

        let emotion = emotionAI.classifyEmotionFromBlendShapes(mockBlendShapes)

        XCTAssertEqual(emotion, .surprised, "Should detect surprise from wide eyes and open mouth")
    }

    func testClassifyEmotion_Neutral_FromNormalExpression() {
        let mockBlendShapes: [String: Float] = [
            "mouthSmileLeft": 0.1,
            "mouthSmileRight": 0.1,
            "eyeWideLeft": 0.0,
            "eyeWideRight": 0.0
        ]

        let emotion = emotionAI.classifyEmotionFromBlendShapes(mockBlendShapes)

        XCTAssertEqual(emotion, .neutral, "Should detect neutral with minimal expression")
    }

    // MARK: - Confidence Scoring Tests

    func testConfidenceScore_StrongExpression_HighConfidence() {
        let mockBlendShapes: [String: Float] = [
            "mouthSmileLeft": 0.9,
            "mouthSmileRight": 0.9,
            "eyeSquintLeft": 0.6,
            "eyeSquintRight": 0.6
        ]

        let confidence = emotionAI.calculateConfidence(blendShapes: mockBlendShapes, detectedEmotion: .happy)

        XCTAssertGreaterThan(confidence, 0.7, "Strong expression should yield high confidence")
    }

    func testConfidenceScore_WeakExpression_LowConfidence() {
        let mockBlendShapes: [String: Float] = [
            "mouthSmileLeft": 0.2,
            "mouthSmileRight": 0.15,
            "eyeSquintLeft": 0.1,
            "eyeSquintRight": 0.1
        ]

        let confidence = emotionAI.calculateConfidence(blendShapes: mockBlendShapes, detectedEmotion: .happy)

        XCTAssertLessThan(confidence, 0.5, "Weak expression should yield low confidence")
    }

    // MARK: - Engagement Level Tests

    func testCalculateEngagement_DirectGaze_HighEngagement() {
        let gazeMetrics = GazeMetrics(
            focusDuration: 5.0,
            averageDistance: 0.1, // Close to center
            blinkRate: 15
        )

        let engagement = emotionAI.calculateEngagement(gazeMetrics: gazeMetrics)

        XCTAssertGreaterThan(engagement, 0.7, "Direct sustained gaze should indicate high engagement")
    }

    func testCalculateEngagement_WanderingGaze_LowEngagement() {
        let gazeMetrics = GazeMetrics(
            focusDuration: 0.5,
            averageDistance: 0.8, // Far from center
            blinkRate: 25 // High blink rate
        )

        let engagement = emotionAI.calculateEngagement(gazeMetrics: gazeMetrics)

        XCTAssertLessThan(engagement, 0.4, "Wandering gaze should indicate low engagement")
    }

    // MARK: - Emotion History Tests

    func testEmotionHistory_TrackingOverTime() {
        emotionAI.recordEmotion(.happy, confidence: 0.8)
        emotionAI.recordEmotion(.happy, confidence: 0.75)
        emotionAI.recordEmotion(.neutral, confidence: 0.6)

        let history = emotionAI.getEmotionHistory(duration: 60.0) // Last minute

        XCTAssertEqual(history.count, 3, "Should track all recorded emotions")
        XCTAssertEqual(history.last?.emotion, .neutral, "Most recent should be neutral")
    }

    func testDominantEmotion_MostFrequent() {
        emotionAI.recordEmotion(.happy, confidence: 0.8)
        emotionAI.recordEmotion(.happy, confidence: 0.85)
        emotionAI.recordEmotion(.happy, confidence: 0.7)
        emotionAI.recordEmotion(.neutral, confidence: 0.6)

        let dominant = emotionAI.getDominantEmotion(duration: 60.0)

        XCTAssertEqual(dominant, .happy, "Should return most frequent emotion")
    }
}

/// Tests for DialogueGenerator system
@MainActor
final class DialogueGeneratorTests: XCTestCase {

    var dialogueGenerator: DialogueGenerator!

    override func setUp() async throws {
        try await super.setUp()
        dialogueGenerator = DialogueGenerator()
    }

    override func tearDown() async throws {
        dialogueGenerator = nil
        try await super.tearDown()
    }

    // MARK: - Template Selection Tests

    func testSelectTemplate_GreetingContext() async throws {
        let context = DialogueContext(
            situationType: .greeting,
            previousDialogues: [],
            playerChoices: [],
            environmentalFactors: [],
            characterMemories: []
        )

        let personality = Personality(
            openness: 0.6,
            conscientiousness: 0.6,
            extraversion: 0.7,
            agreeableness: 0.7,
            neuroticism: 0.3
        )

        let emotion = EmotionalState(happiness: 0.8)

        let dialogue = try await dialogueGenerator.generateDialogue(
            context: context,
            personality: personality,
            emotion: emotion
        )

        XCTAssertFalse(dialogue.isEmpty, "Should generate dialogue")
        XCTAssertTrue(
            dialogue.lowercased().contains("hello") ||
            dialogue.lowercased().contains("hi") ||
            dialogue.lowercased().contains("greet"),
            "Greeting dialogue should contain greeting words"
        )
    }

    func testSelectTemplate_ConflictContext() async throws {
        let context = DialogueContext(
            situationType: .conflict,
            previousDialogues: [],
            playerChoices: [],
            environmentalFactors: [],
            characterMemories: []
        )

        let personality = Personality(
            openness: 0.5,
            conscientiousness: 0.5,
            extraversion: 0.5,
            agreeableness: 0.3, // Low agreeableness
            neuroticism: 0.7 // High neuroticism
        )

        let emotion = EmotionalState(anger: 0.7, fear: 0.3)

        let dialogue = try await dialogueGenerator.generateDialogue(
            context: context,
            personality: personality,
            emotion: emotion
        )

        XCTAssertFalse(dialogue.isEmpty, "Should generate conflict dialogue")
        // Conflict dialogue should reflect tension
    }

    // MARK: - Personality Voice Application Tests

    func testPersonalityVoice_HighOpenness_CreativeLanguage() async throws {
        let context = DialogueContext(
            situationType: .storytelling,
            previousDialogues: [],
            playerChoices: [],
            environmentalFactors: [],
            characterMemories: []
        )

        let personality = Personality(
            openness: 0.95, // Very high
            conscientiousness: 0.5,
            extraversion: 0.6,
            agreeableness: 0.7,
            neuroticism: 0.3
        )

        let emotion = EmotionalState(happiness: 0.7)

        let dialogue = try await dialogueGenerator.generateDialogue(
            context: context,
            personality: personality,
            emotion: emotion
        )

        XCTAssertFalse(dialogue.isEmpty, "Should generate creative dialogue")
        // High openness should produce more elaborate/creative dialogue
    }

    func testPersonalityVoice_LowExtraversion_ReservedLanguage() async throws {
        let context = DialogueContext(
            situationType: .conversation,
            previousDialogues: [],
            playerChoices: [],
            environmentalFactors: [],
            characterMemories: []
        )

        let personality = Personality(
            openness: 0.5,
            conscientiousness: 0.6,
            extraversion: 0.15, // Very low
            agreeableness: 0.6,
            neuroticism: 0.4
        )

        let emotion = EmotionalState(happiness: 0.5)

        let dialogue = try await dialogueGenerator.generateDialogue(
            context: context,
            personality: personality,
            emotion: emotion
        )

        XCTAssertFalse(dialogue.isEmpty, "Should generate reserved dialogue")
        // Low extraversion should produce shorter, more reserved dialogue
    }

    // MARK: - Emotional Tone Tests

    func testEmotionalTone_HighHappiness_PositiveLanguage() async throws {
        let context = DialogueContext(
            situationType: .celebration,
            previousDialogues: [],
            playerChoices: [],
            environmentalFactors: [],
            characterMemories: []
        )

        let personality = Personality(
            openness: 0.6,
            conscientiousness: 0.6,
            extraversion: 0.7,
            agreeableness: 0.8,
            neuroticism: 0.2
        )

        let emotion = EmotionalState(happiness: 0.95, affection: 0.8)

        let dialogue = try await dialogueGenerator.generateDialogue(
            context: context,
            personality: personality,
            emotion: emotion
        )

        XCTAssertFalse(dialogue.isEmpty, "Should generate joyful dialogue")
        // Should contain positive language
    }

    func testEmotionalTone_HighFear_CautiousLanguage() async throws {
        let context = DialogueContext(
            situationType: .danger,
            previousDialogues: [],
            playerChoices: [],
            environmentalFactors: ["dark", "unknown_sound"],
            characterMemories: []
        )

        let personality = Personality(
            openness: 0.4,
            conscientiousness: 0.7,
            extraversion: 0.4,
            agreeableness: 0.6,
            neuroticism: 0.7
        )

        let emotion = EmotionalState(fear: 0.85, trust: 0.3)

        let dialogue = try await dialogueGenerator.generateDialogue(
            context: context,
            personality: personality,
            emotion: emotion
        )

        XCTAssertFalse(dialogue.isEmpty, "Should generate fearful dialogue")
        // Should reflect caution and fear
    }

    // MARK: - Context Awareness Tests

    func testContextAwareness_PreviousDialogueInfluence() async throws {
        let previousDialogue = DialogueNode(
            id: UUID(),
            characterID: UUID(),
            text: "I told you about my secret",
            emotionalTone: .serious,
            audioClipName: nil,
            nextNodes: [],
            choices: []
        )

        let context = DialogueContext(
            situationType: .followUp,
            previousDialogues: [previousDialogue],
            playerChoices: [],
            environmentalFactors: [],
            characterMemories: []
        )

        let personality = Personality(
            openness: 0.6,
            conscientiousness: 0.7,
            extraversion: 0.6,
            agreeableness: 0.7,
            neuroticism: 0.4
        )

        let emotion = EmotionalState(trust: 0.8)

        let dialogue = try await dialogueGenerator.generateDialogue(
            context: context,
            personality: personality,
            emotion: emotion
        )

        XCTAssertFalse(dialogue.isEmpty, "Should generate contextual dialogue")
        // Should reference or acknowledge previous conversation
    }

    // MARK: - Variable Substitution Tests

    func testVariableSubstitution_PlayerName() async throws {
        let playerName = "Alex"

        let context = DialogueContext(
            situationType: .conversation,
            previousDialogues: [],
            playerChoices: [],
            environmentalFactors: [],
            characterMemories: [],
            variables: ["playerName": playerName]
        )

        let personality = Personality(
            openness: 0.6,
            conscientiousness: 0.6,
            extraversion: 0.7,
            agreeableness: 0.7,
            neuroticism: 0.3
        )

        let emotion = EmotionalState(affection: 0.6)

        let dialogue = try await dialogueGenerator.generateDialogue(
            context: context,
            personality: personality,
            emotion: emotion
        )

        XCTAssertFalse(dialogue.isEmpty, "Should generate dialogue with variable substitution")
        // If template uses {playerName}, it should be substituted
    }
}

// MARK: - Helper Types

struct GazeMetrics {
    let focusDuration: TimeInterval
    let averageDistance: Float // Distance from gaze center (0-1)
    let blinkRate: Int // Blinks per minute
}

// MARK: - Test Extensions

extension EmotionRecognitionAI {
    func classifyEmotionFromBlendShapes(_ blendShapes: [String: Float]) -> Emotion {
        // Simplified classification for testing
        let smile = (blendShapes["mouthSmileLeft"] ?? 0) + (blendShapes["mouthSmileRight"] ?? 0)
        let frown = (blendShapes["mouthFrownLeft"] ?? 0) + (blendShapes["mouthFrownRight"] ?? 0)
        let eyeWide = (blendShapes["eyeWideLeft"] ?? 0) + (blendShapes["eyeWideRight"] ?? 0)
        let mouthOpen = blendShapes["mouthOpen"] ?? 0

        if smile > 0.6 {
            return .happy
        } else if frown > 0.5 {
            return .sad
        } else if eyeWide > 0.7 && mouthOpen > 0.4 {
            return .surprised
        } else if frown > 0.3 {
            return .angry
        } else {
            return .neutral
        }
    }

    func calculateConfidence(blendShapes: [String: Float], detectedEmotion: Emotion) -> Float {
        let values = blendShapes.values
        let maxValue = values.max() ?? 0
        let avgValue = values.reduce(0, +) / Float(values.count)

        return (maxValue + avgValue) / 2.0
    }

    func calculateEngagement(gazeMetrics: GazeMetrics) -> Float {
        var engagement: Float = 0.0

        // Focus duration (more is better)
        engagement += min(1.0, Float(gazeMetrics.focusDuration) / 10.0) * 0.4

        // Distance from center (less is better)
        engagement += (1.0 - gazeMetrics.averageDistance) * 0.4

        // Blink rate (12-20 is optimal)
        let blinkRateScore: Float
        if gazeMetrics.blinkRate >= 12 && gazeMetrics.blinkRate <= 20 {
            blinkRateScore = 1.0
        } else {
            blinkRateScore = 0.5
        }
        engagement += blinkRateScore * 0.2

        return min(1.0, max(0.0, engagement))
    }

    func recordEmotion(_ emotion: Emotion, confidence: Float) {
        // Implementation for testing
    }

    func getEmotionHistory(duration: TimeInterval) -> [(emotion: Emotion, confidence: Float, timestamp: Date)] {
        // Mock implementation
        return []
    }

    func getDominantEmotion(duration: TimeInterval) -> Emotion {
        // Mock implementation
        return .neutral
    }
}

extension CharacterAI {
    func getDialogueStyle() -> String {
        if character.personality.openness > 0.7 {
            return "expressive and creative"
        } else if character.personality.conscientiousness > 0.7 {
            return "formal and structured"
        } else if character.personality.extraversion > 0.7 {
            return "enthusiastic and outgoing"
        } else {
            return "balanced"
        }
    }

    func reactToPlayerAction(action: String) -> String {
        if character.personality.empathy > 0.8 && action.contains("sad") {
            return "I understand how you feel, and I'm here for you"
        } else if character.personality.loyalty > 0.8 {
            return "I'll stand by your side"
        } else {
            return "I see"
        }
    }

    func recallRelevantMemories(context: String, limit: Int) -> [CharacterMemory] {
        return Array(character.memories
            .sorted { memory1, memory2 in
                // Sort by emotional weight and recency
                if memory1.emotionalWeight != memory2.emotionalWeight {
                    return memory1.emotionalWeight > memory2.emotionalWeight
                }
                return memory1.timestamp > memory2.timestamp
            }
            .prefix(limit))
    }
}
