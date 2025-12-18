import SwiftUI

struct TeamLobbyView: View {
    let configuration: LobbyConfiguration
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissWindow) private var dismissWindow
    @EnvironmentObject private var gameStateManager: GameStateManager

    @State private var attackersTeam: [Player] = []
    @State private var defendersTeam: [Player] = []
    @State private var selectedMap: GameMap = .warehouse

    var body: some View {
        VStack(spacing: 30) {
            // Header
            Text("Team Lobby")
                .font(.system(size: 36, weight: .bold))
                .padding()

            // Teams
            HStack(spacing: 40) {
                // Attackers Team
                TeamView(
                    teamName: "ATTACKERS",
                    players: attackersTeam,
                    color: .orange,
                    maxPlayers: configuration.teamSize
                )

                Divider()

                // Defenders Team
                TeamView(
                    teamName: "DEFENDERS",
                    players: defendersTeam,
                    color: .blue,
                    maxPlayers: configuration.teamSize
                )
            }
            .padding()

            // Map Selection
            MapSelectionView(selectedMap: $selectedMap)
                .padding()

            // Start Button
            Button {
                startMatch()
            } label: {
                Text("START MATCH")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 300, height: 50)
                    .background(canStartMatch ? Color.green : Color.gray)
                    .cornerRadius(12)
            }
            .disabled(!canStartMatch)
            .padding()
        }
        .padding()
        .glassBackgroundEffect()
    }

    private var canStartMatch: Bool {
        attackersTeam.count >= 1 && defendersTeam.count >= 1
    }

    private func startMatch() {
        gameStateManager.transition(to: .inGame(.warmup))
        Task {
            await openImmersiveSpace(id: "battlefield")
            dismissWindow(id: "lobby")
        }
    }
}

// MARK: - Team View

struct TeamView: View {
    let teamName: String
    let players: [Player]
    let color: Color
    let maxPlayers: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(teamName)
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(color)

            ForEach(0..<maxPlayers, id: \.self) { index in
                if index < players.count {
                    PlayerSlotView(player: players[index])
                } else {
                    EmptyPlayerSlotView()
                }
            }
        }
        .frame(width: 300)
    }
}

struct PlayerSlotView: View {
    let player: Player

    var body: some View {
        HStack {
            Image(systemName: "person.fill")
                .foregroundStyle(.white)

            VStack(alignment: .leading) {
                Text(player.username)
                    .font(.system(size: 16, weight: .semibold))

                Text(player.rank.displayName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text("\(player.stats.kdr, specifier: "%.2f") KDR")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(8)
    }
}

struct EmptyPlayerSlotView: View {
    var body: some View {
        HStack {
            Image(systemName: "person.badge.plus")
                .foregroundStyle(.secondary)

            Text("Waiting for player...")
                .font(.system(size: 16))
                .foregroundStyle(.secondary)

            Spacer()
        }
        .padding()
        .background(.ultraThinMaterial.opacity(0.5))
        .cornerRadius(8)
    }
}

// MARK: - Map Selection

struct MapSelectionView: View {
    @Binding var selectedMap: GameMap

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Select Map")
                .font(.headline)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(GameMap.allMaps) { map in
                        MapCardView(map: map, isSelected: map.id == selectedMap.id)
                            .onTapGesture {
                                selectedMap = map
                            }
                    }
                }
            }
        }
    }
}

struct MapCardView: View {
    let map: GameMap
    let isSelected: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            RoundedRectangle(cornerRadius: 8)
                .fill(.gray)
                .frame(width: 200, height: 120)
                .overlay {
                    Text(map.displayName)
                        .font(.headline)
                        .foregroundStyle(.white)
                }

            Text(map.description)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(2)
                .frame(width: 200)
        }
        .padding()
        .background(isSelected ? Color.blue.opacity(0.3) : Color.clear)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
        )
    }
}
