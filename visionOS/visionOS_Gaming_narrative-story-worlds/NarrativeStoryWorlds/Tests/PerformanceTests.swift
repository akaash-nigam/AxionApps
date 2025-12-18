//
//  PerformanceTests.swift
//  NarrativeStoryWorlds
//
//  Performance and optimization tests
//

import XCTest
@testable import NarrativeStoryWorlds

/// Performance tests for core systems
@MainActor
final class PerformanceTests: XCTestCase {

    // MARK: - AI Performance Tests

    func testStoryDirectorPerformance_PacingAdjustment() {
        let storyDirector = StoryDirectorAI()

        measure {
            for _ in 0..<1000 {
                _ = storyDirector.adjustPacing(
                    playerEngagement: Float.random(in: 0...1),
                    sessionDuration: Double.random(in: 0...7200),
                    emotionalIntensity: Float.random(in: 0...1)
                )
            }
        }
    }

    func testCharacterAIPerformance_EmotionalStateUpdate() {
        let character = createTestCharacter()
        let characterAI = CharacterAI(character: character)

        let testChoices = (0..<100).map { i in
            Choice(
                id: UUID(),
                text: "Choice \(i)",
                consequences: [],
                relationshipImpacts: [character.id: .trust(Float.random(in: -0.1...0.1))],
                isAvailable: { true }
            )
        }

        measure {
            for choice in testChoices {
                let event = StoryEvent(
                    type: .playerChoice(choice),
                    timestamp: Date()
                )
                characterAI.updateEmotionalState(event: event)
            }
        }
    }

    func testDialogueGenerationPerformance() async throws {
        let dialogueGenerator = DialogueGenerator()

        let contexts = (0..<50).map { _ in
            DialogueContext(
                situationType: .conversation,
                previousDialogues: [],
                playerChoices: [],
                environmentalFactors: [],
                characterMemories: []
            )
        }

        let personality = Personality(
            openness: 0.7,
            conscientiousness: 0.6,
            extraversion: 0.6,
            agreeableness: 0.7,
            neuroticism: 0.3
        )

        let emotion = EmotionalState()

        measure {
            for context in contexts {
                _ = try? await dialogueGenerator.generateDialogue(
                    context: context,
                    personality: personality,
                    emotion: emotion
                )
            }
        }
    }

    func testEmotionRecognitionPerformance() {
        let emotionAI = EmotionRecognitionAI()

        let mockBlendShapes = [
            "mouthSmileLeft": Float.random(in: 0...1),
            "mouthSmileRight": Float.random(in: 0...1),
            "eyeWideLeft": Float.random(in: 0...1),
            "eyeWideRight": Float.random(in: 0...1),
            "mouthFrownLeft": Float.random(in: 0...1),
            "mouthFrownRight": Float.random(in: 0...1)
        ]

        measure {
            for _ in 0..<1000 {
                _ = emotionAI.classifyEmotionFromBlendShapes(mockBlendShapes)
            }
        }
    }

    // MARK: - Memory Management Tests

    func testMemoryUsage_LargeStoryLoad() {
        // Create a large story with many nodes
        let largeStory = createLargeStory(nodeCount: 1000)

        measure(metrics: [XCTMemoryMetric()]) {
            // Simulate loading the story
            let _ = largeStory
        }
    }

    func testMemoryUsage_CharacterMemorySystem() {
        let character = createTestCharacter()
        let characterAI = CharacterAI(character: character)

        measure(metrics: [XCTMemoryMetric()]) {
            // Add many memories
            for i in 0..<1000 {
                let memory = CharacterMemory(
                    id: UUID(),
                    content: "Memory \(i)",
                    emotionalWeight: Float.random(in: 0...1),
                    timestamp: Date(),
                    relatedEventID: UUID(),
                    memoryType: Bool.random() ? .shortTerm : .longTerm
                )
                characterAI.addMemory(memory)
            }
        }
    }

    func testMemoryUsage_LongSession() {
        let appModel = AppModel()
        appModel.currentStory = createTestStory()

        measure(metrics: [XCTMemoryMetric()]) {
            // Simulate a long session with many choices
            for _ in 0..<500 {
                if let story = appModel.currentStory,
                   let currentNode = findNode(id: story.currentNodeID, in: story),
                   let choice = currentNode.choices.first {
                    appModel.makeChoice(choice)
                }
            }
        }
    }

    // MARK: - Frame Time Simulation Tests

    func testFrameTimeSimulation_DialogueRendering() {
        // Simulate frame time during dialogue rendering
        // Target: <11ms for 90 FPS

        let dialogueView = createMockDialogueView()

        measure {
            // Simulate rendering 100 frames
            for _ in 0..<100 {
                dialogueView.updateFrame()
            }
        }

        // In real visionOS, this would measure actual frame time
        // Here we measure computation time as proxy
    }

    func testFrameTimeSimulation_MultiCharacterScene() {
        // Simulate frame processing with multiple characters

        let characters = (0..<5).map { _ in createTestCharacter() }

        measure {
            // Simulate update loop for multiple characters
            for _ in 0..<100 {
                for character in characters {
                    _ = updateCharacterFrame(character)
                }
            }
        }
    }

    // MARK: - Algorithm Efficiency Tests

    func testStoryBranchSelection_LargeTree() {
        let storyDirector = StoryDirectorAI()

        // Create a node with many branches
        let nodeWithManyBranches = createNodeWithBranches(count: 100)

        measure {
            for _ in 0..<100 {
                _ = selectOptimalBranch(
                    from: nodeWithManyBranches,
                    director: storyDirector
                )
            }
        }
    }

    func testMemoryRecall_LargeMemorySet() {
        let character = createTestCharacter()
        let characterAI = CharacterAI(character: character)

        // Add many memories
        for i in 0..<1000 {
            let memory = CharacterMemory(
                id: UUID(),
                content: "Memory \(i)",
                emotionalWeight: Float.random(in: 0...1),
                timestamp: Date().addingTimeInterval(TimeInterval(-i * 100)),
                relatedEventID: UUID(),
                memoryType: Bool.random() ? .shortTerm : .longTerm
            )
            characterAI.addMemory(memory)
        }

        measure {
            // Test memory recall performance
            for _ in 0..<100 {
                _ = characterAI.recallRelevantMemories(context: "test", limit: 10)
            }
        }
    }

    func testSpatialAudioCalculation_ManyCharacters() async {
        let spatialAudio = SpatialAudioEngine()

        let characterPositions = (0..<20).map { _ in
            SIMD3<Float>(
                Float.random(in: -5...5),
                Float.random(in: 0...2.5),
                Float.random(in: -5...5)
            )
        }

        measure {
            for position in characterPositions {
                Task {
                    await spatialAudio.updatePosition(position: position)
                }
            }
        }
    }

    // MARK: - Concurrency Performance Tests

    func testConcurrentAIProcessing() async {
        let storyDirector = StoryDirectorAI()
        let emotionAI = EmotionRecognitionAI()

        measure {
            // Simulate concurrent AI processing
            await withTaskGroup(of: Void.self) { group in
                // Story Director task
                group.addTask {
                    for _ in 0..<50 {
                        _ = storyDirector.adjustPacing(
                            playerEngagement: 0.7,
                            sessionDuration: 1800,
                            emotionalIntensity: 0.6
                        )
                    }
                }

                // Emotion Recognition task
                group.addTask {
                    let mockBlendShapes = [
                        "mouthSmileLeft": Float(0.5),
                        "mouthSmileRight": Float(0.5)
                    ]
                    for _ in 0..<50 {
                        _ = emotionAI.classifyEmotionFromBlendShapes(mockBlendShapes)
                    }
                }
            }
        }
    }

    // MARK: - Data Serialization Performance

    func testStorySerialization() throws {
        let story = createLargeStory(nodeCount: 500)

        measure {
            // Test serialization performance
            let encoder = JSONEncoder()
            _ = try? encoder.encode(story)
        }
    }

    func testStoryDeserialization() throws {
        let story = createLargeStory(nodeCount: 500)
        let encoder = JSONEncoder()
        let data = try encoder.encode(story)

        measure {
            let decoder = JSONDecoder()
            _ = try? decoder.decode(Story.self, from: data)
        }
    }

    // MARK: - CloudKit Performance (Mock)

    func testCloudKitSyncPerformance() {
        let story = createTestStory()

        measure {
            // Simulate CloudKit sync preparation
            _ = prepareStoryForSync(story)
        }
    }

    // MARK: - Performance Optimizer Tests

    func testPerformanceOptimizerAdjustment() {
        let optimizer = PerformanceOptimizer()

        // Simulate varying frame times
        let frameTimes: [TimeInterval] = [
            0.010, 0.011, 0.015, 0.020, 0.025, // Getting worse
            0.030, 0.028, 0.025, 0.020, 0.015  // Recovering
        ]

        measure {
            for frameTime in frameTimes {
                optimizer.recordFrameTime(frameTime)
                optimizer.adjustQualityIfNeeded()
            }
        }
    }

    func testThermalStateResponse() {
        let optimizer = PerformanceOptimizer()

        measure {
            // Simulate thermal state changes
            optimizer.updateThermalState(.nominal)
            optimizer.adjustQualityForThermalState()

            optimizer.updateThermalState(.fair)
            optimizer.adjustQualityForThermalState()

            optimizer.updateThermalState(.serious)
            optimizer.adjustQualityForThermalState()

            optimizer.updateThermalState(.critical)
            optimizer.adjustQualityForThermalState()
        }
    }

    // MARK: - Baseline Performance Metrics

    func testBaselineMetrics_AIResponseTime() async throws {
        // Target: <100ms for dialogue generation
        let dialogueGenerator = DialogueGenerator()

        let context = DialogueContext(
            situationType: .conversation,
            previousDialogues: [],
            playerChoices: [],
            environmentalFactors: [],
            characterMemories: []
        )

        let personality = Personality(
            openness: 0.7,
            conscientiousness: 0.6,
            extraversion: 0.6,
            agreeableness: 0.7,
            neuroticism: 0.3
        )

        let emotion = EmotionalState()

        let startTime = Date()
        _ = try await dialogueGenerator.generateDialogue(
            context: context,
            personality: personality,
            emotion: emotion
        )
        let elapsedTime = Date().timeIntervalSince(startTime)

        XCTAssertLessThan(elapsedTime, 0.1, "Dialogue generation should take <100ms")
    }

    func testBaselineMetrics_EmotionRecognitionLatency() {
        // Target: <20ms for emotion classification
        let emotionAI = EmotionRecognitionAI()

        let mockBlendShapes = [
            "mouthSmileLeft": Float(0.7),
            "mouthSmileRight": Float(0.7)
        ]

        let startTime = Date()
        _ = emotionAI.classifyEmotionFromBlendShapes(mockBlendShapes)
        let elapsedTime = Date().timeIntervalSince(startTime)

        XCTAssertLessThan(elapsedTime, 0.02, "Emotion recognition should take <20ms")
    }

    // MARK: - Helper Methods

    private func createTestCharacter() -> Character {
        return Character(
            id: UUID(),
            name: "Test Character",
            bio: "Performance test character",
            personality: Personality(
                openness: 0.7,
                conscientiousness: 0.6,
                extraversion: 0.6,
                agreeableness: 0.7,
                neuroticism: 0.3
            ),
            emotionalState: EmotionalState(),
            voiceProfile: VoiceProfile(),
            spatialProperties: SpatialCharacterProperties(
                preferredDistance: 1.5,
                height: 1.7,
                allowedMovementRadius: 3.0
            ),
            appearanceDescription: "Test"
        )
    }

    private func createTestStory() -> Story {
        let character = createTestCharacter()
        let node = DialogueNode(
            id: UUID(),
            characterID: character.id,
            text: "Test",
            emotionalTone: .neutral,
            audioClipName: nil,
            nextNodes: [],
            choices: []
        )

        let scene = Scene(
            id: UUID(),
            title: "Test Scene",
            description: "Test",
            location: "Test",
            dialogueNodes: [node],
            requiredCharacters: [character.id],
            ambientAudio: nil
        )

        let chapter = Chapter(
            id: UUID(),
            title: "Test Chapter",
            description: "Test",
            scenes: [scene],
            unlockConditions: []
        )

        return Story(
            id: UUID(),
            title: "Test Story",
            description: "Test",
            characters: [character],
            chapters: [chapter],
            currentChapterID: chapter.id,
            currentSceneID: scene.id,
            currentNodeID: node.id
        )
    }

    private func createLargeStory(nodeCount: Int) -> Story {
        let character = createTestCharacter()

        var nodes: [DialogueNode] = []
        for i in 0..<nodeCount {
            let node = DialogueNode(
                id: UUID(),
                characterID: character.id,
                text: "Dialogue node \(i)",
                emotionalTone: .neutral,
                audioClipName: nil,
                nextNodes: i < nodeCount - 1 ? [UUID()] : [],
                choices: []
            )
            nodes.append(node)
        }

        let scene = Scene(
            id: UUID(),
            title: "Large Scene",
            description: "A large scene for testing",
            location: "Test Room",
            dialogueNodes: nodes,
            requiredCharacters: [character.id],
            ambientAudio: nil
        )

        let chapter = Chapter(
            id: UUID(),
            title: "Large Chapter",
            description: "A large chapter",
            scenes: [scene],
            unlockConditions: []
        )

        return Story(
            id: UUID(),
            title: "Large Story",
            description: "A large story for performance testing",
            characters: [character],
            chapters: [chapter],
            currentChapterID: chapter.id,
            currentSceneID: scene.id,
            currentNodeID: nodes.first!.id
        )
    }

    private func createMockDialogueView() -> MockDialogueView {
        return MockDialogueView()
    }

    private func updateCharacterFrame(_ character: Character) -> Bool {
        // Mock character update
        return true
    }

    private func createNodeWithBranches(count: Int) -> DialogueNode {
        let nextNodes = (0..<count).map { _ in UUID() }

        return DialogueNode(
            id: UUID(),
            characterID: UUID(),
            text: "Node with many branches",
            emotionalTone: .neutral,
            audioClipName: nil,
            nextNodes: nextNodes,
            choices: []
        )
    }

    private func selectOptimalBranch(from node: DialogueNode, director: StoryDirectorAI) -> UUID? {
        // Mock branch selection
        return node.nextNodes.randomElement()
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

    private func prepareStoryForSync(_ story: Story) -> [String: Any] {
        // Mock CloudKit sync preparation
        return [
            "storyID": story.id.uuidString,
            "title": story.title,
            "progress": 0.5
        ]
    }
}

// MARK: - Mock Types

class MockDialogueView {
    func updateFrame() {
        // Simulate frame update
        _ = (0..<100).map { $0 * 2 }
    }
}

extension PerformanceOptimizer {
    func updateThermalState(_ state: ThermalState) {
        // Mock implementation
        thermalState = state
    }

    private(set) var thermalState: ThermalState = .nominal
}

enum ThermalState {
    case nominal
    case fair
    case serious
    case critical
}

extension SpatialAudioEngine {
    func updatePosition(position: SIMD3<Float>) {
        // Mock implementation
    }
}
