//
//  MatchmakingView.swift
//  Spatial Arena Championship
//
//  Matchmaking and lobby interface
//

import SwiftUI

struct MatchmakingView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss

    @State private var matchmakingState: MatchmakingState = .idle
    @State private var selectedGameMode: GameMode = .teamDeathmatch
    @State private var selectedArena: Arena = .cyberArena()
    @State private var isHost: Bool = false
    @State private var lobbyPlayers: [LobbyPlayer] = []
    @State private var searchDuration: TimeInterval = 0
    @State private var estimatedWaitTime: TimeInterval = 30

    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [.black, .blue.opacity(0.3), .black],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                headerSection

                // Main content based on state
                Group {
                    switch matchmakingState {
                    case .idle:
                        modeSelectionSection
                    case .searching:
                        searchingSection
                    case .lobby:
                        lobbySection
                    case .starting:
                        countdownSection
                    }
                }

                Spacer()

                // Footer actions
                footerSection
            }
            .padding()
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 8) {
            Text("MATCHMAKING")
                .font(.system(size: 48, weight: .black, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.cyan, .blue],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )

            if matchmakingState == .searching {
                Text("Finding Players...")
                    .font(.title3)
                    .foregroundColor(.secondary)
            } else if matchmakingState == .lobby {
                Text(isHost ? "HOSTING LOBBY" : "IN LOBBY")
                    .font(.title3)
                    .foregroundColor(.cyan)
            }
        }
        .padding(.vertical, 24)
    }

    // MARK: - Mode Selection

    private var modeSelectionSection: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Game Mode Selection
                VStack(alignment: .leading, spacing: 16) {
                    Text("SELECT GAME MODE")
                        .font(.headline)
                        .foregroundColor(.secondary)

                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        ForEach(GameMode.allCases, id: \.self) { mode in
                            GameModeCard(
                                mode: mode,
                                isSelected: selectedGameMode == mode
                            ) {
                                selectedGameMode = mode
                            }
                        }
                    }
                }

                Divider()
                    .background(.white.opacity(0.3))

                // Arena Selection
                VStack(alignment: .leading, spacing: 16) {
                    Text("SELECT ARENA")
                        .font(.headline)
                        .foregroundColor(.secondary)

                    let arenas: [Arena] = [.cyberArena(), .ancientTemple(), .spaceStation()]

                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        ForEach(arenas, id: \.id) { arena in
                            ArenaCard(
                                arena: arena,
                                isSelected: selectedArena.id == arena.id
                            ) {
                                selectedArena = arena
                            }
                        }
                    }
                }

                Divider()
                    .background(.white.opacity(0.3))

                // Match Type Selection
                VStack(spacing: 12) {
                    Button {
                        startHosting()
                    } label: {
                        HStack {
                            Image(systemName: "antenna.radiowaves.left.and.right")
                            Text("HOST MATCH")
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.cyan)
                        .foregroundColor(.black)
                        .cornerRadius(12)
                    }

                    Button {
                        startSearching()
                    } label: {
                        HStack {
                            Image(systemName: "magnifyingglass")
                            Text("FIND MATCH")
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                }
            }
            .padding()
        }
    }

    // MARK: - Searching

    private var searchingSection: some View {
        VStack(spacing: 32) {
            // Animated searching indicator
            ZStack {
                Circle()
                    .stroke(.cyan.opacity(0.3), lineWidth: 4)
                    .frame(width: 200, height: 200)

                Circle()
                    .trim(from: 0, to: 0.6)
                    .stroke(.cyan, lineWidth: 4)
                    .frame(width: 200, height: 200)
                    .rotationEffect(.degrees(searchDuration * 60))

                Image(systemName: "person.3.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.cyan)
            }

            VStack(spacing: 12) {
                Text("Searching for Players")
                    .font(.title2.bold())

                Text("Time elapsed: \(formatDuration(searchDuration))")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Text("Est. wait time: \(formatDuration(estimatedWaitTime))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            // Match criteria
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Game Mode:")
                    Spacer()
                    Text(selectedGameMode.displayName)
                        .foregroundColor(.cyan)
                }

                HStack {
                    Text("Skill Rating:")
                    Spacer()
                    Text("\(appState.localPlayer.skillRating) ± 200")
                        .foregroundColor(.cyan)
                }

                HStack {
                    Text("Region:")
                    Spacer()
                    Text("North America")
                        .foregroundColor(.cyan)
                }
            }
            .font(.subheadline)
            .padding()
            .background(.white.opacity(0.05))
            .cornerRadius(12)
        }
        .padding()
        .onAppear {
            startSearchTimer()
        }
    }

    // MARK: - Lobby

    private var lobbySection: some View {
        VStack(spacing: 24) {
            // Lobby info
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(selectedGameMode.displayName)
                        .font(.title3.bold())
                    Text(selectedArena.name)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(lobbyPlayers.count)/10")
                        .font(.title3.bold())
                        .foregroundColor(.cyan)
                    Text("Players")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(.white.opacity(0.05))
            .cornerRadius(12)

            // Teams
            HStack(spacing: 16) {
                // Blue Team
                teamColumn(team: .blue)

                Divider()
                    .background(.white.opacity(0.3))

                // Red Team
                teamColumn(team: .red)
            }

            // Ready check
            if isHost {
                Button {
                    startMatch()
                } label: {
                    HStack {
                        Image(systemName: "play.fill")
                        Text("START MATCH")
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(canStartMatch ? .green : .gray)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .disabled(!canStartMatch)
            }
        }
        .padding()
    }

    private func teamColumn(team: TeamColor) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(team == .blue ? "BLUE TEAM" : "RED TEAM")
                .font(.headline)
                .foregroundColor(team == .blue ? .cyan : .red)

            let teamPlayers = lobbyPlayers.filter { $0.team == team }

            ForEach(teamPlayers) { player in
                LobbyPlayerRow(player: player)
            }

            // Empty slots
            ForEach(0..<(5 - teamPlayers.count), id: \.self) { _ in
                EmptySlotRow()
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Countdown

    private var countdownSection: some View {
        VStack(spacing: 32) {
            Text("MATCH STARTING")
                .font(.system(size: 48, weight: .black))
                .foregroundColor(.cyan)

            Text("3")
                .font(.system(size: 120, weight: .black))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.cyan, .blue],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

            VStack(spacing: 8) {
                Text(selectedGameMode.displayName)
                    .font(.title2.bold())
                Text(selectedArena.name)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }

    // MARK: - Footer

    private var footerSection: some View {
        HStack {
            Button {
                cancelMatchmaking()
            } label: {
                HStack {
                    Image(systemName: "xmark")
                    Text("CANCEL")
                }
                .padding()
                .background(.red.opacity(0.2))
                .foregroundColor(.red)
                .cornerRadius(8)
            }

            Spacer()

            if matchmakingState == .lobby && !isHost {
                Button {
                    toggleReady()
                } label: {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                        Text("READY")
                    }
                    .padding()
                    .background(.green.opacity(0.2))
                    .foregroundColor(.green)
                    .cornerRadius(8)
                }
            }
        }
        .padding()
    }

    // MARK: - Computed Properties

    private var canStartMatch: Bool {
        lobbyPlayers.count >= 2 && lobbyPlayers.allSatisfy { $0.isReady }
    }

    // MARK: - Actions

    private func startHosting() {
        isHost = true
        matchmakingState = .lobby

        // Add local player
        let localPlayer = LobbyPlayer(
            id: appState.localPlayer.id,
            username: appState.localPlayer.username,
            skillRating: appState.localPlayer.skillRating,
            team: .blue,
            isReady: true,
            isHost: true
        )
        lobbyPlayers = [localPlayer]

        // TODO: Start network hosting
    }

    private func startSearching() {
        isHost = false
        matchmakingState = .searching
        searchDuration = 0

        // TODO: Start matchmaking search
    }

    private func startSearchTimer() {
        Task {
            while matchmakingState == .searching {
                try? await Task.sleep(for: .seconds(1))
                searchDuration += 1

                // Simulate finding match after 5 seconds
                if searchDuration >= 5 {
                    joinLobby()
                    break
                }
            }
        }
    }

    private func joinLobby() {
        matchmakingState = .lobby

        // Simulate lobby players
        lobbyPlayers = [
            LobbyPlayer(id: UUID(), username: "Player1", skillRating: 1500, team: .blue, isReady: true, isHost: true),
            LobbyPlayer(id: UUID(), username: "Player2", skillRating: 1520, team: .blue, isReady: false, isHost: false),
            LobbyPlayer(id: UUID(), username: "Player3", skillRating: 1480, team: .red, isReady: true, isHost: false),
            LobbyPlayer(id: UUID(), username: "Player4", skillRating: 1510, team: .red, isReady: false, isHost: false),
        ]
    }

    private func toggleReady() {
        // TODO: Send ready state to host
    }

    private func startMatch() {
        matchmakingState = .starting

        Task {
            try? await Task.sleep(for: .seconds(3))

            // Create match
            let match = Match(
                matchType: .competitive,
                gameMode: selectedGameMode,
                arena: selectedArena,
                team1: createTeam(from: lobbyPlayers.filter { $0.team == .blue }, color: .blue),
                team2: createTeam(from: lobbyPlayers.filter { $0.team == .red }, color: .red)
            )

            appState.startMatch(match)
            dismiss()
        }
    }

    private func createTeam(from players: [LobbyPlayer], color: TeamColor) -> Team {
        Team(
            color: color,
            players: players.map { Player(
                username: $0.username,
                skillRating: $0.skillRating,
                team: color
            )}
        )
    }

    private func cancelMatchmaking() {
        // TODO: Leave lobby / cancel search
        dismiss()
    }

    // MARK: - Utilities

    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// MARK: - Matchmaking State

enum MatchmakingState {
    case idle
    case searching
    case lobby
    case starting
}

// MARK: - Lobby Player

struct LobbyPlayer: Identifiable {
    let id: UUID
    var username: String
    var skillRating: Int
    var team: TeamColor
    var isReady: Bool
    var isHost: Bool
}

// MARK: - Game Mode Card

struct GameModeCard: View {
    let mode: GameMode
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: mode.iconName)
                    .font(.system(size: 40))
                    .foregroundColor(isSelected ? .cyan : .white)

                VStack(spacing: 4) {
                    Text(mode.displayName)
                        .font(.headline)
                    Text(mode.shortDescription)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(isSelected ? .cyan.opacity(0.2) : .white.opacity(0.05))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? .cyan : .clear, lineWidth: 2)
            )
            .cornerRadius(12)
        }
    }
}

// MARK: - Arena Card

struct ArenaCard: View {
    let arena: Arena
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(LinearGradient(
                            colors: [.blue, .cyan],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(height: 80)

                    Text(arena.theme.emoji)
                        .font(.system(size: 40))
                }

                Text(arena.name)
                    .font(.caption.bold())
                    .foregroundColor(isSelected ? .cyan : .white)
            }
            .background(isSelected ? .cyan.opacity(0.2) : .clear)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? .cyan : .clear, lineWidth: 2)
            )
            .cornerRadius(12)
        }
    }
}

// MARK: - Lobby Player Row

struct LobbyPlayerRow: View {
    let player: LobbyPlayer

    var body: some View {
        HStack {
            Circle()
                .fill(player.isReady ? .green : .gray)
                .frame(width: 8, height: 8)

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Text(player.username)
                        .font(.subheadline.bold())
                    if player.isHost {
                        Image(systemName: "crown.fill")
                            .font(.caption2)
                            .foregroundColor(.yellow)
                    }
                }

                Text("SR: \(player.skillRating)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding(8)
        .background(.white.opacity(0.05))
        .cornerRadius(8)
    }
}

// MARK: - Empty Slot Row

struct EmptySlotRow: View {
    var body: some View {
        HStack {
            Circle()
                .stroke(style: StrokeStyle(lineWidth: 1, dash: [2]))
                .foregroundColor(.gray)
                .frame(width: 8, height: 8)

            Text("Empty Slot")
                .font(.subheadline)
                .foregroundColor(.gray)

            Spacer()
        }
        .padding(8)
        .background(.white.opacity(0.02))
        .cornerRadius(8)
    }
}

// MARK: - Extensions

extension GameMode {
    var iconName: String {
        switch self {
        case .elimination: return "person.2.slash"
        case .domination: return "flag.2.crossed"
        case .artifactHunt: return "cube"
        case .teamDeathmatch: return "target"
        case .freeForAll: return "person.3"
        case .kingOfTheHill: return "crown"
        case .custom: return "gearshape"
        }
    }

    var shortDescription: String {
        switch self {
        case .elimination: return "Last team standing"
        case .domination: return "Control territories"
        case .artifactHunt: return "Collect artifacts"
        case .teamDeathmatch: return "First to 50 kills"
        case .freeForAll: return "Every player for themselves"
        case .kingOfTheHill: return "Control the zone"
        case .custom: return "Custom rules"
        }
    }
}

extension Arena {
    var theme: ArenaTheme {
        switch name {
        case "Cyber Arena": return ArenaTheme(emoji: "🌐", primaryColor: .cyan)
        case "Ancient Temple": return ArenaTheme(emoji: "🏛️", primaryColor: .orange)
        case "Space Station": return ArenaTheme(emoji: "🛸", primaryColor: .purple)
        default: return ArenaTheme(emoji: "⚔️", primaryColor: .blue)
        }
    }
}

struct ArenaTheme {
    let emoji: String
    let primaryColor: Color
}

// MARK: - Preview

#Preview {
    MatchmakingView()
        .environment(AppState())
}
