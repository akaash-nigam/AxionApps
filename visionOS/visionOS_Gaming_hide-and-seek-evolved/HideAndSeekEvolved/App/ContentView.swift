import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var gameManager: GameManager
    @EnvironmentObject private var immersiveSpaceManager: ImmersiveSpaceManager
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace

    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                // Title
                Text("Hide and Seek Evolved")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundStyle(.linearGradient(
                        colors: [.blue, .purple],
                        startPoint: .leading,
                        endPoint: .trailing
                    ))

                // Subtitle
                Text("The ultimate game of stealth in augmented reality")
                    .font(.title3)
                    .foregroundColor(.secondary)

                Spacer()

                // Main Menu Options
                VStack(spacing: 20) {
                    // Play Button
                    Button(action: startGame) {
                        Label("Play Game", systemImage: "play.fill")
                            .font(.title2)
                            .frame(maxWidth: 300)
                            .padding()
                            .background(.blue.gradient)
                            .foregroundColor(.white)
                            .cornerRadius(15)
                    }
                    .buttonStyle(.plain)

                    // Players Button
                    NavigationLink {
                        PlayerManagementView()
                    } label: {
                        Label("Manage Players", systemImage: "person.2.fill")
                            .font(.title3)
                            .frame(maxWidth: 300)
                            .padding()
                            .background(.purple.opacity(0.2))
                            .cornerRadius(15)
                    }
                    .buttonStyle(.plain)

                    // Settings Button
                    NavigationLink {
                        SettingsView()
                    } label: {
                        Label("Settings", systemImage: "gearshape.fill")
                            .font(.title3)
                            .frame(maxWidth: 300)
                            .padding()
                            .background(.gray.opacity(0.2))
                            .cornerRadius(15)
                    }
                    .buttonStyle(.plain)

                    // Achievements Button
                    NavigationLink {
                        AchievementsView()
                    } label: {
                        Label("Achievements", systemImage: "trophy.fill")
                            .font(.title3)
                            .frame(maxWidth: 300)
                            .padding()
                            .background(.yellow.opacity(0.2))
                            .cornerRadius(15)
                    }
                    .buttonStyle(.plain)
                }

                Spacer()

                // Stats Summary
                if gameManager.hasPlayers {
                    VStack(spacing: 10) {
                        Text("Game Stats")
                            .font(.headline)
                        HStack {
                            StatView(title: "Games Played", value: "\(gameManager.totalGamesPlayed)")
                            StatView(title: "Total Players", value: "\(gameManager.playerCount)")
                        }
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(10)
                }
            }
            .padding(40)
        }
    }

    private func startGame() {
        Task {
            do {
                try await immersiveSpaceManager.enterImmersiveSpace(using: openImmersiveSpace)
                await gameManager.startNewGame()
            } catch {
                print("Failed to start game: \(error)")
            }
        }
    }
}

struct StatView: View {
    let title: String
    let value: String

    var body: some View {
        VStack {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// Placeholder views for navigation
struct PlayerManagementView: View {
    var body: some View {
        Text("Player Management")
            .font(.title)
    }
}

struct SettingsView: View {
    var body: some View {
        Text("Settings")
            .font(.title)
    }
}

struct AchievementsView: View {
    var body: some View {
        Text("Achievements")
            .font(.title)
    }
}

#Preview {
    ContentView()
        .environmentObject(GameManager())
        .environmentObject(ImmersiveSpaceManager())
}
