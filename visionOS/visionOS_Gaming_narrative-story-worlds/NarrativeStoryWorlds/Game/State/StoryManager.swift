import Foundation

/// Manages the overall story state, progression, and branching
@MainActor
class StoryManager: @unchecked Sendable {
    // MARK: - Properties
    private(set) var currentStory: Story?
    private(set) var currentChapter: Chapter?
    private(set) var currentScene: Scene?
    private(set) var storyState: StoryState

    private var dialogueSystem: DialogueSystem
    private var choiceSystem: ChoiceSystem

    // MARK: - Initialization
    init() {
        self.storyState = StoryState()
        self.dialogueSystem = DialogueSystem()
        self.choiceSystem = ChoiceSystem()
    }

    // MARK: - Story Loading
    func loadEpisode(_ episodeNumber: Int) async {
        // Load story data from bundle or remote
        // For now, create a sample story
        currentStory = createSampleStory()
        currentChapter = currentStory?.chapters.first
        currentScene = currentChapter?.scenes.first

        // Update state
        if let story = currentStory,
           let chapter = currentChapter {
            storyState.currentStoryID = story.id
            storyState.currentChapterID = chapter.id
        }
    }

    func startStory() async {
        guard let scene = currentScene else { return }

        // Begin first scene
        await playScene(scene)
    }

    // MARK: - Story Progression
    func update(deltaTime: TimeInterval) {
        // Update dialogue system
        dialogueSystem.update(deltaTime: deltaTime)

        // Check for scene completion
        if isSceneComplete() {
            Task {
                await advanceToNextScene()
            }
        }
    }

    private func playScene(_ scene: Scene) async {
        currentScene = scene
        storyState.currentSceneID = scene.id

        // Play all story beats in the scene
        for beat in scene.storyBeats {
            await playStoryBeat(beat)
        }
    }

    private func playStoryBeat(_ beat: StoryBeat) async {
        switch beat.type {
        case .dialogue:
            if let dialogueNode = beat.content as? DialogueNode {
                await dialogueSystem.presentDialogue(dialogueNode)
            }

        case .choice:
            if let choice = beat.content as? Choice {
                await presentChoice(choice)
            }

        case .event:
            // Handle story event
            break

        case .revelation:
            // Handle revelation moment
            break
        }
    }

    // MARK: - Choice Handling
    func presentChoice(_ choice: Choice) async {
        let selectedOption = await choiceSystem.presentChoice(choice)
        await processChoiceSelection(choice, option: selectedOption)
    }

    func selectChoice(_ option: ChoiceOption) async {
        // Record choice in history
        storyState.choiceHistory.append(
            ChoiceRecord(
                choiceID: UUID(),
                optionID: option.id,
                timestamp: Date()
            )
        )

        // Apply consequences
        applyChoiceConsequences(option)

        // Continue story
        await advanceToNextScene()
    }

    private func processChoiceSelection(_ choice: Choice, option: ChoiceOption) async {
        // Apply relationship changes
        for (characterID, change) in option.relationshipImpacts {
            if var relationship = storyState.characterRelationships[characterID] {
                relationship.trustLevel += change
                relationship.trustLevel = max(0, min(1, relationship.trustLevel))
                storyState.characterRelationships[characterID] = relationship
            }
        }

        // Set story flags
        option.flagsSet.forEach { flag in
            storyState.activeFlags.insert(flag)
        }
    }

    private func applyChoiceConsequences(_ option: ChoiceOption) {
        // Update story state based on choice
        for (characterID, impact) in option.relationshipImpacts {
            updateRelationship(characterID: characterID, delta: impact)
        }

        // Set flags
        option.flagsSet.forEach { flag in
            storyState.activeFlags.insert(flag)
        }
    }

    // MARK: - Scene Management
    private func isSceneComplete() -> Bool {
        guard let scene = currentScene else { return false }
        return storyState.completedScenes.contains(scene.id)
    }

    private func advanceToNextScene() async {
        guard let chapter = currentChapter else { return }

        // Mark current scene as complete
        if let sceneID = currentScene?.id {
            storyState.completedScenes.insert(sceneID)
        }

        // Find next scene
        if let currentIndex = chapter.scenes.firstIndex(where: { $0.id == currentScene?.id }),
           currentIndex + 1 < chapter.scenes.count {
            let nextScene = chapter.scenes[currentIndex + 1]
            await playScene(nextScene)
        } else {
            // Chapter complete
            await advanceToNextChapter()
        }
    }

    private func advanceToNextChapter() async {
        guard let story = currentStory,
              let currentChapterIndex = story.chapters.firstIndex(where: { $0.id == currentChapter?.id }),
              currentChapterIndex + 1 < story.chapters.count else {
            // Story complete!
            await completeStory()
            return
        }

        let nextChapter = story.chapters[currentChapterIndex + 1]
        currentChapter = nextChapter
        currentScene = nextChapter.scenes.first
        storyState.currentChapterID = nextChapter.id

        if let scene = currentScene {
            await playScene(scene)
        }
    }

    private func completeStory() async {
        print("✨ Story complete!")
        // Show ending credits, etc.
    }

    // MARK: - Relationship Management
    private func updateRelationship(characterID: UUID, delta: Float) {
        var relationship = storyState.characterRelationships[characterID] ?? Relationship(characterID: characterID)
        relationship.trustLevel += delta
        relationship.trustLevel = max(0, min(1, relationship.trustLevel))
        storyState.characterRelationships[characterID] = relationship
    }

    // MARK: - Object Interaction
    func objectExamined(_ objectID: String) async {
        // Record that player examined this object
        storyState.examinedObjects.insert(objectID)

        // Trigger any related story events
        // ...
    }

    // MARK: - Save/Load Support
    func getCurrentState() -> StoryState {
        return storyState
    }

    func restoreFrom(_ savedState: StoryState) async {
        self.storyState = savedState

        // Reload story based on saved state
        // ...
    }

    // MARK: - Sample Story Creation
    private func createSampleStory() -> Story {
        let story = Story(
            id: UUID(),
            title: "The Visitor",
            genre: .mystery,
            estimatedDuration: 3600, // 60 minutes
            chapters: [createSampleChapter()],
            characters: [],
            branches: [],
            achievements: []
        )
        return story
    }

    private func createSampleChapter() -> Chapter {
        return Chapter(
            id: UUID(),
            title: "Chapter 1: The Arrival",
            scenes: [createSampleScene()],
            completionState: .notStarted
        )
    }

    private func createSampleScene() -> Scene {
        let dialogueNode = DialogueNode(
            id: UUID(),
            speakerID: UUID(),
            text: "Hello. I've been waiting for you.",
            audioClip: nil,
            responses: [],
            conditions: [],
            displayDuration: 3.0,
            autoAdvance: true,
            emotionalTone: .mysterious,
            facialAnimation: nil
        )

        let storyBeat = StoryBeat(
            id: UUID(),
            type: .dialogue,
            content: dialogueNode,
            emotionalWeight: 0.5,
            pacing: .normal
        )

        return Scene(
            id: UUID(),
            location: .playerHome,
            characterIDs: [],
            storyBeats: [storyBeat],
            requiredFlags: Set(),
            spatialConfiguration: SpatialConfiguration()
        )
    }
}

// MARK: - Supporting Types
struct ChoiceRecord: Codable {
    let choiceID: UUID
    let optionID: UUID
    let timestamp: Date
}
