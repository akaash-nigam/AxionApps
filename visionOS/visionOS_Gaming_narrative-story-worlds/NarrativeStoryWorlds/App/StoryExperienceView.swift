import SwiftUI
import RealityKit

struct StoryExperienceView: View {
    @Environment(AppModel.self) private var appModel

    @State private var rootEntity = Entity()
    @State private var spatialManager = SpatialManager()
    @State private var characterManager = CharacterManager()

    var body: some View {
        RealityView { content in
            // Add root entity
            content.add(rootEntity)

            // Initialize spatial tracking
            await spatialManager.initialize()

            // Set up the story world
            await setupStoryWorld()

        } update: { content in
            // Update based on state changes
            updateStoryWorld()
        }
        .task {
            // Start game loop
            await runGameLoop()
        }
        .gesture(
            SpatialTapGesture()
                .targetedToAnyEntity()
                .onEnded { value in
                    handleTap(on: value.entity)
                }
        )
    }

    // MARK: - Setup
    private func setupStoryWorld() async {
        // Scan room
        await spatialManager.scanRoom()

        // Load first character
        if let character = await characterManager.loadCharacter(id: "main_character") {
            // Position character in room
            let position = spatialManager.getCharacterPosition(for: character)
            character.position = position

            // Add to scene
            rootEntity.addChild(character)
        }

        // Load initial dialogue
        await appModel.storyManager.startStory()
    }

    // MARK: - Update
    private func updateStoryWorld() {
        // Update character positions
        characterManager.updateCharacterPositions(in: spatialManager.roomFeatures)
    }

    // MARK: - Game Loop
    private func runGameLoop() async {
        let targetFrameTime = 1.0 / 90.0 // 90 FPS
        var lastTime = CACurrentMediaTime()

        while appModel.currentState == .playingStory {
            let currentTime = CACurrentMediaTime()
            let deltaTime = currentTime - lastTime
            lastTime = currentTime

            // Update all systems
            appModel.gameStateManager.update(deltaTime: deltaTime)
            characterManager.update(deltaTime: deltaTime)
            appModel.storyManager.update(deltaTime: deltaTime)

            // Sleep to maintain frame rate
            let elapsed = CACurrentMediaTime() - currentTime
            let sleepTime = max(0, targetFrameTime - elapsed)
            try? await Task.sleep(for: .seconds(sleepTime))
        }
    }

    // MARK: - Input Handling
    private func handleTap(on entity: Entity) {
        // Check if tapped on a choice
        if let choice = entity as? ChoiceEntity {
            Task {
                await appModel.storyManager.selectChoice(choice.choiceOption)
            }
        }
        // Check if tapped on an interactable object
        else if let interactable = entity as? InteractableEntity {
            Task {
                await handleObjectInteraction(interactable)
            }
        }
    }

    private func handleObjectInteraction(_ object: InteractableEntity) async {
        // Examine the object
        await object.examine()
        // Update story state
        await appModel.storyManager.objectExamined(object.id)
    }
}

#Preview {
    StoryExperienceView()
        .environment(AppModel())
}
