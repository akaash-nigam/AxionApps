import SwiftUI
import RealityKit

/// Main game view in immersive space
struct GameView: View {
    @Environment(GameViewModel.self) private var gameViewModel

    var body: some View {
        RealityView { content in
            // Create root entity
            let rootEntity = Entity()
            content.add(rootEntity)

        } update: { content in
            // Update game content
            gameViewModel.updateGameContent(content)
        }
        .gesture(
            SpatialTapGesture()
                .targetedToAnyEntity()
                .onEnded { value in
                    gameViewModel.handleTap(on: value.entity)
                }
        )
        .overlay(alignment: .topLeading) {
            GameHUD()
        }
        .task {
            // Initialize game systems when view appears
            await initializeGameSystems()
        }
    }

    // MARK: - Private Methods

    @MainActor
    private func initializeGameSystems() async {
        // Initialize spatial mapping if available
        if let spatialMappingManager = gameViewModel.spatialMappingManager {
            await spatialMappingManager.startRoomScanning()
        }
    }
}

/// Game HUD overlay
struct GameHUD: View {
    @Environment(GameViewModel.self) private var gameViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Timer
            if let puzzle = gameViewModel.currentPuzzle {
                HStack {
                    Image(systemName: "clock.fill")
                    Text("15:00")
                        .font(.title3)
                        .monospacedDigit()
                }
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(10)

                // Objectives
                VStack(alignment: .leading, spacing: 5) {
                    Text("Objectives")
                        .font(.headline)

                    ForEach(puzzle.objectives) { objective in
                        HStack {
                            Image(systemName: objective.isCompleted ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(objective.isCompleted ? .green : .secondary)

                            Text(objective.title)
                                .font(.subheadline)
                        }
                    }
                }
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(10)

                // Hint Button
                Button(action: {
                    // Request hint
                }) {
                    HStack {
                        Image(systemName: "lightbulb.fill")
                        Text("Hint")
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(10)
                }
                .buttonStyle(.plain)
            }

            Spacer()
        }
        .padding()
    }
}

#Preview {
    GameView()
        .environment(GameViewModel())
}
