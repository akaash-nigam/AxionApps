import SwiftUI

/// Main application entry point for Spatial Pictionary
@main
struct SpatialPictionaryApp: App {
    // MARK: - State

    @State private var gameState = GameState()

    // MARK: - Body

    var body: some Scene {
        // Main window scene for menus and 2D UI
        WindowGroup {
            ContentView()
                .environment(gameState)
        }

        // Immersive space for 3D drawing gameplay
        ImmersiveSpace(id: "GameSpace") {
            GameSpaceView()
                .environment(gameState)
        }
    }
}

/// Main content view - entry point for the app UI
struct ContentView: View {
    @Environment(GameState.self) private var gameState

    var body: some View {
        NavigationStack {
            MainMenuView()
        }
    }
}

/// Game space view - 3D immersive drawing environment
struct GameSpaceView: View {
    @Environment(GameState.self) private var gameState

    var body: some View {
        RealityView { content in
            // Setup RealityKit scene
            setupGameScene(content: content)
        } update: { content in
            // Update scene based on game state
            updateGameScene(content: content)
        }
    }

    private func setupGameScene(content: RealityViewContent) {
        // TODO: Initialize RealityKit entities
        // - Canvas anchor
        // - Drawing volume
        // - Tool palette
        // - Player avatars
    }

    private func updateGameScene(content: RealityViewContent) {
        // TODO: Update entities based on game state
        // - Sync player positions
        // - Update drawings
        // - Update UI elements
    }
}

/// Main menu view
struct MainMenuView: View {
    @Environment(GameState.self) private var gameState
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace

    var body: some View {
        VStack(spacing: 30) {
            // Title
            Text("Spatial Pictionary")
                .font(.largeTitle)
                .bold()

            // Tagline
            Text("Draw in the air, guess in three dimensions")
                .font(.title3)
                .foregroundStyle(.secondary)

            Spacer()

            // Menu buttons
            VStack(spacing: 20) {
                Button(action: startQuickPlay) {
                    Label("Quick Play", systemImage: "play.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)

                Button(action: hostMultiplayer) {
                    Label("Host Multiplayer", systemImage: "person.3.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)

                Button(action: joinGame) {
                    Label("Join Game", systemImage: "arrow.right.circle.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)

                Button(action: practiceMode) {
                    Label("Practice Mode", systemImage: "pencil.and.scribble")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
            }
            .padding(.horizontal)

            Spacer()

            // Footer buttons
            HStack {
                Button("Gallery") {
                    // Navigate to gallery
                }

                Spacer()

                Button("Settings") {
                    // Navigate to settings
                }

                Spacer()

                Button("Tutorial") {
                    // Navigate to tutorial
                }
            }
            .padding(.horizontal)
        }
        .padding()
    }

    // MARK: - Actions

    private func startQuickPlay() {
        Task {
            // Add local player
            let localPlayer = Player(
                name: "You",
                avatar: .default,
                isLocal: true,
                deviceID: UIDevice.current.identifierForVendor?.uuidString ?? "local"
            )
            gameState.addPlayer(localPlayer)

            // Start game
            await openImmersiveSpace(id: "GameSpace")
        }
    }

    private func hostMultiplayer() {
        Task {
            // Setup multiplayer host
            await openImmersiveSpace(id: "GameSpace")
        }
    }

    private func joinGame() {
        // Show join game sheet
    }

    private func practiceMode() {
        Task {
            // Start practice mode (no timer, no scoring)
            await openImmersiveSpace(id: "GameSpace")
        }
    }
}

// MARK: - Preview

#Preview {
    ContentView()
        .environment(GameState())
}
