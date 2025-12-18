//
//  MainMenuView.swift
//  Reality Minecraft
//
//  Main menu view for the game
//

import SwiftUI

struct MainMenuView: View {
    @EnvironmentObject var appModel: AppModel
    @EnvironmentObject var gameStateManager: GameStateManager
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
    @Environment(\.openWindow) var openWindow

    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [.blue.opacity(0.3), .green.opacity(0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 40) {
                // Title
                VStack(spacing: 10) {
                    Text("Reality Minecraft")
                        .font(.system(size: 60, weight: .bold, design: .rounded))
                    Text("Build in Your World")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 60)

                Spacer()

                // Menu Buttons
                VStack(spacing: 20) {
                    MenuButton(title: "New World", icon: "plus.circle.fill") {
                        createNewWorld()
                    }

                    MenuButton(title: "Load World", icon: "folder.fill") {
                        showWorldSelection()
                    }

                    MenuButton(title: "Settings", icon: "gearshape.fill") {
                        openSettings()
                    }

                    MenuButton(title: "How to Play", icon: "questionmark.circle.fill") {
                        showTutorial()
                    }
                }
                .frame(maxWidth: 400)

                Spacer()

                // Version info
                Text("Version 1.0.0 • visionOS 2.0+")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.bottom)
            }
            .padding()
        }
    }

    // MARK: - Actions

    private func createNewWorld() {
        Task {
            // Create new world
            let world = WorldData.createNew(name: "New World")
            appModel.currentWorld = world

            // Start game
            await startGame()
        }
    }

    private func showWorldSelection() {
        // Show world selection view
        openWindow(id: "WorldSelection")
    }

    private func openSettings() {
        openWindow(id: "Settings")
    }

    private func showTutorial() {
        // Show tutorial
        print("📖 Show tutorial")
    }

    private func startGame() async {
        gameStateManager.transitionTo(.loading(progress: 0.0))

        // Open immersive space
        await openImmersiveSpace(id: "GameWorld")

        // Transition to playing
        gameStateManager.transitionTo(.playing(mode: .creative))
    }
}

// MARK: - Menu Button

struct MenuButton: View {
    let title: String
    let icon: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 15) {
                Image(systemName: icon)
                    .font(.title2)
                    .frame(width: 30)

                Text(title)
                    .font(.title3)
                    .fontWeight(.semibold)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    MainMenuView()
        .environmentObject(AppModel())
        .environmentObject(GameStateManager())
}
