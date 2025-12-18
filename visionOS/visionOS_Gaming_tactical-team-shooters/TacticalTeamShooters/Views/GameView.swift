import SwiftUI
import RealityKit

/// Main game view - immersive spatial gameplay
struct GameView: View {

    @EnvironmentObject private var gameCoordinator: GameCoordinator
    @EnvironmentObject private var appState: AppState

    @State private var rootEntity = Entity()

    var body: some View {
        RealityView { content in
            // Setup spatial scene
            content.add(rootEntity)

            // Initialize game scene
            await setupGameScene()

        } update: { content in
            // Update scene based on game state
        }
        .overlay(alignment: .topLeading) {
            // In-game HUD
            GameHUD()
        }
        .overlay(alignment: .center) {
            if gameCoordinator.isLoading {
                LoadingView()
            }
        }
        .gesture(TapGesture().onEnded { _ in
            // Handle tap for firing
        })
    }

    private func setupGameScene() async {
        // TODO: Setup RealityKit scene with game entities
    }
}

/// In-game HUD overlay
struct GameHUD: View {
    @EnvironmentObject private var gameCoordinator: GameCoordinator

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Match timer
            if let matchState = gameCoordinator.matchState {
                Text("Round: 1/25")
                    .font(.headline)
                    .foregroundColor(.white)

                Text("1:45")
                    .font(.system(.title, design: .monospaced))
                    .foregroundColor(.white)
            }

            Spacer()

            // Health and ammo (placeholder)
            HStack {
                VStack(alignment: .leading) {
                    Text("HP: 100")
                        .font(.headline)
                        .foregroundColor(.green)

                    Text("Armor: 100")
                        .font(.headline)
                        .foregroundColor(.blue)

                    Text("Ammo: 30 / 90")
                        .font(.headline)
                        .foregroundColor(.white)
                }
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(12)

                Spacer()
            }
        }
        .padding()
    }
}

/// Loading overlay
struct LoadingView: View {
    var body: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)

            Text("Loading...")
                .font(.title2)
                .foregroundColor(.white)
        }
        .padding(40)
        .background(.ultraThinMaterial)
        .cornerRadius(20)
    }
}

#Preview {
    GameView()
        .environmentObject(GameCoordinator())
        .environmentObject(AppState())
}
