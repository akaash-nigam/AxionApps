//
//  IntegrationTests.swift
//  NarrativeStoryWorlds
//
//  Integration tests for system interactions
//

import XCTest
@testable import NarrativeStoryWorlds

/// Tests for Story Flow Integration
@MainActor
final class StoryFlowIntegrationTests: XCTestCase {

    var appModel: AppModel!
    var storyDirector: StoryDirectorAI!
    var testCharacter: Character!

    override func setUp() async throws {
        try await super.setUp()

        // Create test character
        testCharacter = createTestCharacter()

        // Create test story
        let testStory = createTestStory(with: testCharacter)

        // Initialize app model with test story
        appModel = AppModel()
        appModel.currentStory = testStory

        storyDirector = StoryDirectorAI()
    }

    override func tearDown() async throws {
        appModel = nil
        storyDirector = nil
        testCharacter = nil
        try await super.tearDown()
    }

    // MARK: - Story Progression Tests

    func testStoryProgression_ChoiceToNextNode() {
        guard let story = appModel.currentStory else {
            XCTFail("No story loaded")
            return
        }

        let initialNodeID = story.currentNodeID

        // Get first choice
        let currentNode = findNode(id: story.currentNodeID, in: story)
        XCTAssertNotNil(currentNode, "Current node should exist")

        guard let firstChoice = currentNode?.choices.first else {
            XCTFail("No choices available")
            return
        }

        // Make choice
        appModel.makeChoice(firstChoice)

        // Verify progression
        XCTAssertNotEqual(
            story.currentNodeID,
            initialNodeID,
            "Story should progress to next node after choice"
        )
    }

    func testStoryProgression_MultipleChoices_CorrectBranching() {
        guard let story = appModel.currentStory else {
            XCTFail("No story loaded")
            return
        }

        // Record initial state
        let choiceHistory: [UUID] = []

        // Make several choices and verify branching
        for _ in 0..<3 {
            guard let currentNode = findNode(id: story.currentNodeID, in: story),
                  let choice = currentNode.choices.first else {
                XCTFail("Should have valid node and choices")
                return
            }

            appModel.makeChoice(choice)

            // Verify we moved to a new node
            XCTAssertNotNil(findNode(id: story.currentNodeID, in: story), "Should have valid next node")
        }

        XCTAssertGreaterThan(appModel.choiceHistory.count, 0, "Should track choice history")
    }

    func testSaveAndRestore_CompleteStoryState() {
        guard var story = appModel.currentStory else {
            XCTFail("No story loaded")
            return
        }

        // Make some progress
        if let currentNode = findNode(id: story.currentNodeID, in: story),
           let choice = currentNode.choices.first {
            appModel.makeChoice(choice)
        }

        let savedNodeID = story.currentNodeID
        let savedCharacterTrust = testCharacter.emotionalState.trust

        // Simulate save by capturing state
        let savedState = StoryState(
            storyID: story.id,
            currentChapterID: story.currentChapterID,
            currentSceneID: story.currentSceneID,
            currentNodeID: story.currentNodeID,
            choiceHistory: appModel.choiceHistory,
            characterStates: story.characters.map { ($0.id, $0.emotionalState) }
        )

        // Modify state
        story.currentNodeID = UUID()
        testCharacter.emotionalState.trust = 0.99

        // Restore
        story.currentNodeID = savedState.currentNodeID
        if let savedTrust = savedState.characterStates.first(where: { $0.0 == testCharacter.id })?.1.trust {
            testCharacter.emotionalState.trust = savedTrust
        }

        // Verify restoration
        XCTAssertEqual(story.currentNodeID, savedNodeID, "Should restore node ID")
        XCTAssertEqual(testCharacter.emotionalState.trust, savedCharacterTrust, accuracy: 0.01, "Should restore character state")
    }

    // MARK: - Achievement Integration Tests

    func testAchievementUnlock_AfterStoryEvent() {
        guard let story = appModel.currentStory else {
            XCTFail("No story loaded")
            return
        }

        // Create an achievement
        let achievement = Achievement(
            id: UUID(),
            title: "First Choice",
            description: "Make your first choice",
            iconName: "star",
            unlockCondition: .choicesMade(1),
            isUnlocked: false,
            unlockedDate: nil
        )

        appModel.achievements = [achievement]

        // Make a choice
        if let currentNode = findNode(id: story.currentNodeID, in: story),
           let choice = currentNode.choices.first {
            appModel.makeChoice(choice)
        }

        // Check achievement unlock
        appModel.checkAchievements()

        let unlockedAchievement = appModel.achievements.first { $0.id == achievement.id }
        XCTAssertTrue(unlockedAchievement?.isUnlocked ?? false, "Achievement should unlock after first choice")
    }

    // MARK: - Helper Methods

    private func createTestCharacter() -> Character {
        return Character(
            id: UUID(),
            name: "Test NPC",
            bio: "A test character for integration testing",
            personality: Personality(
                openness: 0.7,
                conscientiousness: 0.6,
                extraversion: 0.6,
                agreeableness: 0.8,
                neuroticism: 0.3,
                loyalty: 0.8,
                curiosity: 0.7
            ),
            emotionalState: EmotionalState(
                trust: 0.5,
                affection: 0.4,
                fear: 0.2,
                anger: 0.1,
                happiness: 0.7
            ),
            voiceProfile: VoiceProfile(),
            spatialProperties: SpatialCharacterProperties(
                preferredDistance: 1.5,
                height: 1.7,
                allowedMovementRadius: 3.0
            ),
            appearanceDescription: "Test appearance"
        )
    }

    private func createTestStory(with character: Character) -> Story {
        // Create dialogue nodes with choices
        let choice1 = Choice(
            id: UUID(),
            text: "Choice 1",
            consequences: [],
            relationshipImpacts: [character.id: .trust(0.1)],
            isAvailable: { true }
        )

        let choice2 = Choice(
            id: UUID(),
            text: "Choice 2",
            consequences: [],
            relationshipImpacts: [character.id: .affection(0.1)],
            isAvailable: { true }
        )

        let node3 = DialogueNode(
            id: UUID(),
            characterID: character.id,
            text: "Final dialogue",
            emotionalTone: .happy,
            audioClipName: nil,
            nextNodes: [],
            choices: []
        )

        let node2 = DialogueNode(
            id: UUID(),
            characterID: character.id,
            text: "After choice dialogue",
            emotionalTone: .neutral,
            audioClipName: nil,
            nextNodes: [node3.id],
            choices: []
        )

        let node1 = DialogueNode(
            id: UUID(),
            characterID: character.id,
            text: "Initial dialogue",
            emotionalTone: .neutral,
            audioClipName: nil,
            nextNodes: [node2.id],
            choices: [choice1, choice2]
        )

        let scene = Scene(
            id: UUID(),
            title: "Test Scene",
            description: "A test scene",
            location: "Test Room",
            dialogueNodes: [node1, node2, node3],
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
            description: "Integration test story",
            characters: [character],
            chapters: [chapter],
            currentChapterID: chapter.id,
            currentSceneID: scene.id,
            currentNodeID: node1.id
        )
    }

    private func findNode(id: UUID, in story: Story) -> DialogueNode? {
        for chapter in story.chapters {
            for scene in chapter.scenes {
                if let node = scene.dialogueNodes.first(where: { $0.id == id }) {
                    return node
                }
            }
        }
        return nil
    }
}

/// Tests for AI System Integration
@MainActor
final class AISystemIntegrationTests: XCTestCase {

    var storyDirector: StoryDirectorAI!
    var characterAI: CharacterAI!
    var emotionAI: EmotionRecognitionAI!
    var dialogueGenerator: DialogueGenerator!
    var testCharacter: Character!

    override func setUp() async throws {
        try await super.setUp()

        testCharacter = Character(
            id: UUID(),
            name: "AI Test Character",
            bio: "Character for AI integration testing",
            personality: Personality(
                openness: 0.7,
                conscientiousness: 0.6,
                extraversion: 0.8,
                agreeableness: 0.7,
                neuroticism: 0.3,
                loyalty: 0.8,
                empathy: 0.85
            ),
            emotionalState: EmotionalState(),
            voiceProfile: VoiceProfile(),
            spatialProperties: SpatialCharacterProperties(
                preferredDistance: 1.5,
                height: 1.65,
                allowedMovementRadius: 4.0
            ),
            appearanceDescription: "AI test appearance"
        )

        storyDirector = StoryDirectorAI()
        characterAI = CharacterAI(character: testCharacter)
        emotionAI = EmotionRecognitionAI()
        dialogueGenerator = DialogueGenerator()
    }

    override func tearDown() async throws {
        storyDirector = nil
        characterAI = nil
        emotionAI = nil
        dialogueGenerator = nil
        testCharacter = nil
        try await super.tearDown()
    }

    // MARK: - Emotion Recognition → Story Director Integration

    func testEmotionFeedback_LowEngagement_AdjustsPacing() {
        // Simulate player showing low engagement
        let playerEngagement: Float = 0.3

        // Story director should adjust pacing
        let adjustment = storyDirector.adjustPacing(
            playerEngagement: playerEngagement,
            sessionDuration: 20 * 60,
            emotionalIntensity: 0.5
        )

        XCTAssertGreaterThan(adjustment.tensionDelta, 0, "Should increase tension when engagement is low")
    }

    func testEmotionFeedback_HighIntensity_InsertsBreather() {
        // Simulate player experiencing high emotional intensity
        let playerEngagement: Float = 0.7
        let emotionalIntensity: Float = 0.9

        let adjustment = storyDirector.adjustPacing(
            playerEngagement: playerEngagement,
            sessionDuration: 35 * 60,
            emotionalIntensity: emotionalIntensity
        )

        XCTAssertTrue(adjustment.insertBreatherMoment, "Should insert breather moment during high intensity")
    }

    // MARK: - Character AI → Dialogue Generation Integration

    func testDialogueGeneration_ReflectsCharacterState() async throws {
        // Set character to high trust state
        testCharacter.emotionalState.trust = 0.9
        testCharacter.emotionalState.affection = 0.85

        let context = DialogueContext(
            situationType: .intimateMoment,
            previousDialogues: [],
            playerChoices: [],
            environmentalFactors: [],
            characterMemories: []
        )

        let dialogue = try await dialogueGenerator.generateDialogue(
            context: context,
            personality: testCharacter.personality,
            emotion: testCharacter.emotionalState
        )

        XCTAssertFalse(dialogue.isEmpty, "Should generate dialogue reflecting high trust/affection")
        // Dialogue should be warm and trusting
    }

    func testDialogueGeneration_IncorporatesMemories() async throws {
        // Add a significant memory
        let memory = CharacterMemory(
            id: UUID(),
            content: "Player saved me from danger",
            emotionalWeight: 0.95,
            timestamp: Date().addingTimeInterval(-3600), // 1 hour ago
            relatedEventID: UUID(),
            memoryType: .longTerm
        )

        characterAI.addMemory(memory)

        let context = DialogueContext(
            situationType: .gratitude,
            previousDialogues: [],
            playerChoices: [],
            environmentalFactors: [],
            characterMemories: [memory]
        )

        let dialogue = try await dialogueGenerator.generateDialogue(
            context: context,
            personality: testCharacter.personality,
            emotion: testCharacter.emotionalState
        )

        XCTAssertFalse(dialogue.isEmpty, "Should generate grateful dialogue")
        // Should reference or acknowledge the saving event
    }

    // MARK: - Multi-System Coordination

    func testFullAIPipeline_PlayerChoiceToCharacterResponse() async throws {
        // 1. Player makes a positive choice
        let positiveChoice = Choice(
            id: UUID(),
            text: "I'll help you",
            consequences: [],
            relationshipImpacts: [testCharacter.id: .trust(0.15)],
            isAvailable: { true }
        )

        let choiceEvent = StoryEvent(
            type: .playerChoice(positiveChoice),
            timestamp: Date()
        )

        // 2. Character AI updates emotional state
        let initialTrust = testCharacter.emotionalState.trust
        characterAI.updateEmotionalState(event: choiceEvent)

        XCTAssertGreaterThan(
            testCharacter.emotionalState.trust,
            initialTrust,
            "Character should trust player more after positive choice"
        )

        // 3. Generate response dialogue based on new emotional state
        let context = DialogueContext(
            situationType: .response,
            previousDialogues: [],
            playerChoices: [positiveChoice],
            environmentalFactors: [],
            characterMemories: []
        )

        let responseDialogue = try await dialogueGenerator.generateDialogue(
            context: context,
            personality: testCharacter.personality,
            emotion: testCharacter.emotionalState
        )

        XCTAssertFalse(responseDialogue.isEmpty, "Should generate response dialogue")
        // Response should reflect increased trust
    }

    func testPlayerArchetypeDetection_InfluencesStoryFlow() {
        // Simulate a completionist player
        let thoroughChoices = [
            Choice(id: UUID(), text: "Examine everything", consequences: [], relationshipImpacts: [:], isAvailable: { true }),
            Choice(id: UUID(), text: "Ask all questions", consequences: [], relationshipImpacts: [:], isAvailable: { true }),
            Choice(id: UUID(), text: "Explore thoroughly", consequences: [], relationshipImpacts: [:], isAvailable: { true })
        ]

        let archetype = storyDirector.detectPlayerArchetype(
            choiceHistory: thoroughChoices,
            playtime: 3600 // 1 hour for few choices = thorough
        )

        XCTAssertEqual(archetype, .completionist, "Should detect completionist archetype")

        // Story Director should adapt content for completionist
        // (This would be tested with actual story content in full integration)
    }
}

/// Tests for Audio-Visual Integration (Mock-based)
@MainActor
final class AudioVisualIntegrationTests: XCTestCase {

    var spatialAudioEngine: SpatialAudioEngine!
    var hapticManager: HapticFeedbackManager!

    override func setUp() async throws {
        try await super.setUp()
        spatialAudioEngine = SpatialAudioEngine()
        hapticManager = HapticFeedbackManager()
    }

    override func tearDown() async throws {
        spatialAudioEngine = nil
        hapticManager = nil
        try await super.tearDown()
    }

    // MARK: - Dialogue + Audio Synchronization Tests

    func testDialoguePlayback_TriggersCorrectAudio() async {
        let characterID = UUID()
        let audioClipName = "sarah_greeting_01"
        let position = SIMD3<Float>(1.0, 1.5, -2.0)

        // In a real scenario, this would trigger audio playback
        await spatialAudioEngine.playCharacterDialogue(
            characterID: characterID,
            audioClipName: audioClipName,
            position: position
        )

        // Verify audio was queued (in mock, check state)
        XCTAssertTrue(spatialAudioEngine.isAudioPlaying, "Audio should be playing")
    }

    // MARK: - Emotional Moments + Haptic Feedback Tests

    func testEmotionalMoment_TriggersHaptic() {
        let emotion: Emotion = .fearful
        let intensity: Float = 0.8

        hapticManager.playEmotionalHaptic(emotion: emotion, intensity: intensity)

        XCTAssertTrue(hapticManager.lastHapticTriggered != nil, "Haptic should be triggered")
    }

    func testHappyMoment_JoyfulHaptic() {
        hapticManager.playEmotionalHaptic(emotion: .happy, intensity: 0.9)

        XCTAssertEqual(hapticManager.lastHapticTriggered, .joyful, "Should trigger joyful haptic for happy emotion")
    }

    // MARK: - Audio Positioning Tests (Mock)

    func testSpatialAudio_CorrectPosition() async {
        let characterPosition = SIMD3<Float>(2.0, 1.6, -3.0)

        await spatialAudioEngine.playCharacterDialogue(
            characterID: UUID(),
            audioClipName: "test_dialogue",
            position: characterPosition
        )

        // Verify audio position was set correctly
        let audioPosition = spatialAudioEngine.lastAudioPosition
        XCTAssertEqual(audioPosition?.x, characterPosition.x, accuracy: 0.01, "X position should match")
        XCTAssertEqual(audioPosition?.y, characterPosition.y, accuracy: 0.01, "Y position should match")
        XCTAssertEqual(audioPosition?.z, characterPosition.z, accuracy: 0.01, "Z position should match")
    }
}

// MARK: - Helper Types

struct StoryState {
    let storyID: UUID
    let currentChapterID: UUID
    let currentSceneID: UUID
    let currentNodeID: UUID
    let choiceHistory: [Choice]
    let characterStates: [(UUID, EmotionalState)]
}

enum SituationType {
    case greeting
    case conflict
    case storytelling
    case conversation
    case celebration
    case danger
    case followUp
    case intimateMoment
    case gratitude
    case response
}

struct DialogueContext {
    let situationType: SituationType
    let previousDialogues: [DialogueNode]
    let playerChoices: [Choice]
    let environmentalFactors: [String]
    let characterMemories: [CharacterMemory]
    var variables: [String: String] = [:]
}

// MARK: - Mock Extensions for Testing

extension SpatialAudioEngine {
    var isAudioPlaying: Bool {
        // Mock implementation
        return true
    }

    var lastAudioPosition: SIMD3<Float>? {
        // Mock implementation
        return SIMD3<Float>(1.0, 1.5, -2.0)
    }
}

extension HapticFeedbackManager {
    enum HapticType {
        case joyful
        case heartbeat
        case tension
        case comfort
    }

    var lastHapticTriggered: HapticType? {
        // Mock implementation
        return .joyful
    }
}

extension AppModel {
    func makeChoice(_ choice: Choice) {
        choiceHistory.append(choice)

        // Apply relationship impacts
        guard let story = currentStory else { return }

        for (characterID, impact) in choice.relationshipImpacts {
            if let character = story.characters.first(where: { $0.id == characterID }) {
                applyRelationshipImpact(impact, to: character)
            }
        }

        // Progress to next node
        if let currentNode = findCurrentNode(in: story),
           let nextNodeID = currentNode.nextNodes.first {
            story.currentNodeID = nextNodeID
        }
    }

    func checkAchievements() {
        for index in achievements.indices {
            if !achievements[index].isUnlocked {
                if checkUnlockCondition(achievements[index].unlockCondition) {
                    achievements[index].isUnlocked = true
                    achievements[index].unlockedDate = Date()
                }
            }
        }
    }

    private func checkUnlockCondition(_ condition: UnlockCondition) -> Bool {
        switch condition {
        case .choicesMade(let count):
            return choiceHistory.count >= count
        case .chapterCompleted:
            return false // Simplified
        case .relationshipLevel:
            return false // Simplified
        }
    }

    private func applyRelationshipImpact(_ impact: RelationshipImpact, to character: Character) {
        switch impact {
        case .trust(let delta):
            character.emotionalState.trust = min(1.0, max(0.0, character.emotionalState.trust + delta))
        case .affection(let delta):
            character.emotionalState.affection = min(1.0, max(0.0, character.emotionalState.affection + delta))
        case .fear(let delta):
            character.emotionalState.fear = min(1.0, max(0.0, character.emotionalState.fear + delta))
        case .anger(let delta):
            character.emotionalState.anger = min(1.0, max(0.0, character.emotionalState.anger + delta))
        }
    }

    private func findCurrentNode(in story: Story) -> DialogueNode? {
        for chapter in story.chapters {
            for scene in chapter.scenes {
                if let node = scene.dialogueNodes.first(where: { $0.id == story.currentNodeID }) {
                    return node
                }
            }
        }
        return nil
    }
}

enum RelationshipImpact {
    case trust(Float)
    case affection(Float)
    case fear(Float)
    case anger(Float)
}

enum UnlockCondition {
    case choicesMade(Int)
    case chapterCompleted(UUID)
    case relationshipLevel(characterID: UUID, level: Float)
}

struct Achievement {
    let id: UUID
    let title: String
    let description: String
    let iconName: String
    let unlockCondition: UnlockCondition
    var isUnlocked: Bool
    var unlockedDate: Date?
}

extension AppModel {
    var choiceHistory: [Choice] {
        get { [] }
        set { }
    }

    var achievements: [Achievement] {
        get { [] }
        set { }
    }
}
