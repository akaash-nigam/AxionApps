import SwiftUI

/// Main menu view for the app
struct MainMenuView: View {
    @Environment(GameViewModel.self) private var gameViewModel
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissWindow) private var dismissWindow

    var body: some View {
        VStack(spacing: 30) {
            // Title
            Text("ESCAPE ROOM NETWORK")
                .font(.system(size: 48, weight: .bold))
                .foregroundColor(.cyan)

            Text("Turn any room into an impossible escape challenge")
                .font(.title3)
                .foregroundColor(.secondary)

            Spacer()

            // Menu Buttons
            VStack(spacing: 20) {
                MenuButton(
                    title: "Play Solo",
                    icon: "person.fill",
                    color: .blue
                ) {
                    startSoloGame()
                }

                MenuButton(
                    title: "Play with Friends",
                    icon: "person.3.fill",
                    color: .purple
                ) {
                    startMultiplayerGame()
                }

                MenuButton(
                    title: "Daily Challenge",
                    icon: "calendar",
                    color: .orange
                ) {
                    startDailyChallenge()
                }

                MenuButton(
                    title: "Browse Puzzles",
                    icon: "square.grid.2x2.fill",
                    color: .green
                ) {
                    browsePuzzles()
                }

                MenuButton(
                    title: "Settings",
                    icon: "gearshape.fill",
                    color: .gray
                ) {
                    openSettings()
                }
            }

            Spacer()

            // Player Info
            HStack {
                Image(systemName: "person.circle.fill")
                    .font(.title2)
                Text("Level \(gameViewModel.playerLevel)")
                    .font(.headline)

                Spacer()

                Text("\(gameViewModel.playerXP) XP")
                    .font(.headline)
            }
            .padding()
            .background(Color.secondary.opacity(0.2))
            .cornerRadius(10)
        }
        .padding(40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.8))
    }

    // MARK: - Actions

    private func startSoloGame() {
        Task {
            await openImmersiveSpace(id: "game-space")
            dismissWindow(id: "main-menu")

            // Generate a puzzle
            let roomData = RoomData()
            let puzzle = gameViewModel.puzzleEngine?.generatePuzzle(
                type: .logic,
                difficulty: .beginner,
                roomData: roomData
            )

            if let puzzle = puzzle {
                gameViewModel.startGame(puzzle: puzzle)
            }
        }
    }

    private func startMultiplayerGame() {
        // Start multiplayer flow
        print("Starting multiplayer game...")
    }

    private func startDailyChallenge() {
        // Start daily challenge
        print("Starting daily challenge...")
    }

    private func browsePuzzles() {
        // Open puzzle browser
        print("Opening puzzle browser...")
    }

    private func openSettings() {
        // Open settings window
        print("Opening settings...")
    }
}

/// Reusable menu button component
struct MenuButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void

    @State private var isHovered = false

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .frame(width: 40)

                Text(title)
                    .font(.title3)
                    .fontWeight(.semibold)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.title3)
            }
            .padding()
            .frame(maxWidth: 600)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(color.opacity(isHovered ? 0.3 : 0.2))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(color, lineWidth: isHovered ? 3 : 1)
            )
            .scaleEffect(isHovered ? 1.05 : 1.0)
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovered = hovering
            }
        }
    }
}

#Preview {
    MainMenuView()
        .environment(GameViewModel())
}
