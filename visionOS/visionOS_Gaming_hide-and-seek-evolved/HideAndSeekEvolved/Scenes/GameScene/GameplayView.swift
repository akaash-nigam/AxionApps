import SwiftUI
import RealityKit

struct GameplayView: View {
    @EnvironmentObject private var gameManager: GameManager
    @State private var rootEntity = Entity()

    var body: some View {
        RealityView { content in
            // Add root entity to scene
            content.add(rootEntity)

            // Setup initial scene
            await setupScene(rootEntity: rootEntity)
        } update: { content in
            // Update scene based on game state
            await updateScene(rootEntity: rootEntity)
        }
        .gesture(
            SpatialTapGesture()
                .targetedToAnyEntity()
                .onEnded { value in
                    handleTap(on: value.entity)
                }
        )
        .overlay(alignment: .top) {
            GameHUDView()
        }
        .overlay(alignment: .bottom) {
            GameControlsView()
        }
    }

    // MARK: - Scene Setup

    private func setupScene(rootEntity: Entity) async {
        // Add lighting
        var directionalLight = DirectionalLightComponent()
        directionalLight.intensity = 1000
        directionalLight.color = .white

        let lightEntity = Entity()
        lightEntity.components[DirectionalLightComponent.self] = directionalLight
        lightEntity.position = SIMD3(0, 3, 0)
        rootEntity.addChild(lightEntity)

        // Add ambient light
        var ambientLight = AmbientLightComponent()
        ambientLight.intensity = 500

        let ambientEntity = Entity()
        ambientEntity.components[AmbientLightComponent.self] = ambientLight
        rootEntity.addChild(ambientEntity)

        print("Scene setup complete")
    }

    private func updateScene(rootEntity: Entity) async {
        // Update scene based on current game state
        switch gameManager.gameState {
        case .hiding:
            // Show hiding indicators
            break
        case .seeking:
            // Show clues and seeking tools
            break
        default:
            break
        }
    }

    // MARK: - Interaction Handlers

    private func handleTap(on entity: Entity) {
        print("Tapped on entity: \(entity.name)")

        // Handle different entity types
        if entity.components[HidingSpotComponent.self] != nil {
            handleHidingSpotTap(entity)
        }
    }

    private func handleHidingSpotTap(_ entity: Entity) {
        print("Selected hiding spot")
        // Implement hiding spot selection logic
    }
}

// MARK: - Game HUD View

struct GameHUDView: View {
    @EnvironmentObject private var gameManager: GameManager

    var body: some View {
        VStack {
            // Top bar with timer and role
            HStack {
                // Role indicator
                RoleIndicator(role: getCurrentPlayerRole())

                Spacer()

                // Timer
                TimerView(state: gameManager.gameState)

                Spacer()

                // Round counter
                Text("Round \(gameManager.currentRound)")
                    .font(.headline)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(.ultraThinMaterial)
                    .cornerRadius(20)
            }
            .padding()
        }
    }

    private func getCurrentPlayerRole() -> PlayerRole {
        // Get current player role
        // In a real implementation, this would be based on the actual player
        return .hider
    }
}

struct RoleIndicator: View {
    let role: PlayerRole

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: role == .hider ? "eye.slash.fill" : "eye.fill")
            Text(role == .hider ? "HIDER" : "SEEKER")
                .font(.headline)
                .fontWeight(.bold)
        }
        .foregroundColor(.white)
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(role == .hider ? Color.blue.gradient : Color.orange.gradient)
        .cornerRadius(25)
    }
}

struct TimerView: View {
    let state: GameState

    var body: some View {
        Text(timeString)
            .font(.system(size: 48, weight: .bold, design: .rounded))
            .monospacedDigit()
            .foregroundColor(timeColor)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(.ultraThinMaterial)
            .cornerRadius(20)
    }

    private var timeString: String {
        let seconds: TimeInterval

        switch state {
        case .hiding(let timeRemaining), .seeking(let timeRemaining):
            seconds = timeRemaining
        default:
            seconds = 0
        }

        let minutes = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%d:%02d", minutes, secs)
    }

    private var timeColor: Color {
        let seconds: TimeInterval

        switch state {
        case .hiding(let timeRemaining), .seeking(let timeRemaining):
            seconds = timeRemaining
        default:
            seconds = 0
        }

        if seconds < 30 {
            return .red
        } else if seconds < 60 {
            return .orange
        } else {
            return .primary
        }
    }
}

// MARK: - Game Controls View

struct GameControlsView: View {
    var body: some View {
        HStack(spacing: 20) {
            // Pause button
            ControlButton(icon: "pause.fill", color: .gray) {
                // Pause game
                print("Pause tapped")
            }

            Spacer()

            // Emergency stop
            ControlButton(icon: "hand.raised.fill", color: .red) {
                // Emergency stop
                print("Emergency stop tapped")
            }
        }
        .padding()
    }
}

struct ControlButton: View {
    let icon: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(.white)
                .frame(width: 60, height: 60)
                .background(color.gradient)
                .cornerRadius(30)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Custom Components

struct HidingSpotComponent: Component {
    var spotId: UUID
    var quality: Float
    var isOccupied: Bool = false
    var occupantId: UUID?
}

#Preview {
    GameplayView()
        .environmentObject(GameManager())
}
