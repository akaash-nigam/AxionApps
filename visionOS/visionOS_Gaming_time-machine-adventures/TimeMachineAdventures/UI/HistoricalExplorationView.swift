import SwiftUI
import RealityKit

struct HistoricalExplorationView: View {
    @EnvironmentObject var coordinator: GameCoordinator
    @State private var rootEntity: Entity = Entity()

    var body: some View {
        RealityView { content in
            // Setup root entity
            coordinator.rootEntity = rootEntity
            content.add(rootEntity)

            // Initialize AR session
            await setupARSession()

            // Transform environment to current era
            if let era = coordinator.currentEra {
                await coordinator.startJourney(era: era)
            }
        } update: { content in
            // Update scene based on game state
        }
        .gesture(
            SpatialTapGesture()
                .targetedToAnyEntity()
                .onEnded { value in
                    handleEntityTap(value.entity)
                }
        )
        .onAppear {
            coordinator.startGameLoop()
        }
        .onDisappear {
            coordinator.pauseGame()
        }
    }

    private func setupARSession() async {
        // Setup ARKit tracking
        // This would be implemented with actual ARKit code
    }

    private func handleEntityTap(_ entity: Entity) {
        // Handle interaction with tapped entity
        if entity.components.has(ArtifactComponent.self) {
            // Examine artifact
            if let artifactComp = entity.components[ArtifactComponent.self] {
                coordinator.stateManager.transition(to: .examiningArtifact(artifact: artifactComp.artifactData))
            }
        } else if entity.components.has(CharacterComponent.self) {
            // Talk to character
            if let characterComp = entity.components[CharacterComponent.self] {
                coordinator.stateManager.transition(to: .conversing(character: characterComp.characterData))
            }
        }
    }
}
