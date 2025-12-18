//
//  PostMatchView.swift
//  Spatial Arena Championship
//
//  Post-match results and statistics view
//

import SwiftUI

struct PostMatchView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss

    let match: Match
    let localPlayerTeam: TeamColor
    let didWin: Bool

    @State private var selectedTab: ResultsTab = .overview
    @State private var showDetails: Bool = false
    @State private var animateIn: Bool = false

    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: didWin ?
                    [.green.opacity(0.3), .black, .black] :
                    [.red.opacity(0.3), .black, .black],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Victory/Defeat Header
                headerSection
                    .opacity(animateIn ? 1 : 0)
                    .offset(y: animateIn ? 0 : -50)

                // Tab Selection
                tabBar
                    .padding(.vertical, 16)

                // Content
                ScrollView {
                    Group {
                        switch selectedTab {
                        case .overview:
                            overviewSection
                        case .scoreboard:
                            scoreboardSection
                        case .stats:
                            statsSection
                        case .progression:
                            progressionSection
                        }
                    }
                    .opacity(animateIn ? 1 : 0)
                }

                // Footer
                footerSection
            }
        }
        .onAppear {
            withAnimation(.spring(duration: 0.6)) {
                animateIn = true
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 16) {
            // Victory/Defeat
            Text(didWin ? "VICTORY" : "DEFEAT")
                .font(.system(size: 60, weight: .black))
                .foregroundStyle(
                    LinearGradient(
                        colors: didWin ? [.green, .cyan] : [.red, .orange],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )

            // Match info
            VStack(spacing: 4) {
                Text(match.gameMode.displayName)
                    .font(.title2.bold())
                Text(match.arena.name)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            // Final Score
            HStack(spacing: 24) {
                teamScore(team: match.team1, isWinner: match.winner?.id == match.team1.id)
                Text("-")
                    .font(.title.bold())
                    .foregroundColor(.secondary)
                teamScore(team: match.team2, isWinner: match.winner?.id == match.team2.id)
            }
            .padding()
            .background(.white.opacity(0.05))
            .cornerRadius(12)
        }
        .padding()
    }

    private func teamScore(team: Team, isWinner: Bool) -> some View {
        VStack(spacing: 8) {
            Text(team.color == .blue ? "BLUE" : "RED")
                .font(.caption.bold())
                .foregroundColor(team.color == .blue ? .cyan : .red)

            Text("\(team.score)")
                .font(.system(size: 48, weight: .black))
                .foregroundColor(isWinner ? .white : .gray)

            if isWinner {
                Image(systemName: "crown.fill")
                    .foregroundColor(.yellow)
            }
        }
    }

    // MARK: - Tab Bar

    private var tabBar: some View {
        HStack(spacing: 0) {
            ForEach(ResultsTab.allCases, id: \.self) { tab in
                Button {
                    withAnimation(.spring(duration: 0.3)) {
                        selectedTab = tab
                    }
                } label: {
                    VStack(spacing: 8) {
                        Image(systemName: tab.iconName)
                            .font(.title3)

                        Text(tab.rawValue)
                            .font(.caption.bold())
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .foregroundColor(selectedTab == tab ? .cyan : .gray)
                    .background(selectedTab == tab ? .cyan.opacity(0.2) : .clear)
                }
            }
        }
        .background(.white.opacity(0.05))
        .cornerRadius(12)
        .padding(.horizontal)
    }

    // MARK: - Overview Section

    private var overviewSection: some View {
        VStack(spacing: 24) {
            // MVP
            if let mvp = match.getMVP() {
                MVPCard(player: mvp, match: match)
            }

            // Match Highlights
            MatchHighlightsCard(match: match)

            // Personal Performance
            if let localPlayer = findLocalPlayer() {
                PersonalPerformanceCard(player: localPlayer, match: match)
            }

            // Match Timeline
            MatchTimelineCard(match: match)
        }
        .padding()
    }

    // MARK: - Scoreboard Section

    private var scoreboardSection: some View {
        VStack(spacing: 16) {
            // Team 1
            TeamScoreboardCard(team: match.team1, match: match)

            Divider()
                .background(.white.opacity(0.3))

            // Team 2
            TeamScoreboardCard(team: match.team2, match: match)
        }
        .padding()
    }

    // MARK: - Stats Section

    private var statsSection: some View {
        VStack(spacing: 16) {
            // Combat Stats
            StatsCard(
                title: "Combat Statistics",
                icon: "burst.fill",
                stats: match.getCombatStats()
            )

            // Objective Stats
            StatsCard(
                title: "Objective Statistics",
                icon: "flag.fill",
                stats: match.getObjectiveStats()
            )

            // Performance Stats
            StatsCard(
                title: "Performance Metrics",
                icon: "speedometer",
                stats: match.getPerformanceStats()
            )
        }
        .padding()
    }

    // MARK: - Progression Section

    private var progressionSection: some View {
        VStack(spacing: 24) {
            // SR Change
            SRChangeCard(
                oldSR: appState.localPlayer.skillRating,
                newSR: appState.localPlayer.skillRating + (didWin ? 25 : -15),
                didWin: didWin
            )

            // Unlocks
            if !match.rewards.isEmpty {
                UnlocksCard(rewards: match.rewards)
            }

            // Challenges Progress
            ChallengesCard(challenges: appState.localPlayer.activeChallenges)

            // Season Progress
            SeasonProgressCard(
                currentXP: appState.localPlayer.seasonXP,
                xpGained: match.calculateXPEarned(),
                nextLevel: appState.localPlayer.seasonLevel + 1
            )
        }
        .padding()
    }

    // MARK: - Footer

    private var footerSection: some View {
        HStack(spacing: 16) {
            Button {
                // Play again
                dismiss()
            } label: {
                HStack {
                    Image(systemName: "arrow.clockwise")
                    Text("PLAY AGAIN")
                }
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(.cyan)
                .foregroundColor(.black)
                .cornerRadius(12)
            }

            Button {
                // Return to menu
                appState.returnToMainMenu()
                dismiss()
            } label: {
                HStack {
                    Image(systemName: "house")
                    Text("MAIN MENU")
                }
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(.white.opacity(0.1))
                .foregroundColor(.white)
                .cornerRadius(12)
            }
        }
        .padding()
    }

    // MARK: - Utilities

    private func findLocalPlayer() -> Player? {
        let allPlayers = match.team1.players + match.team2.players
        return allPlayers.first { $0.id == appState.localPlayer.id }
    }
}

// MARK: - Results Tab

enum ResultsTab: String, CaseIterable {
    case overview = "Overview"
    case scoreboard = "Scoreboard"
    case stats = "Stats"
    case progression = "Progression"

    var iconName: String {
        switch self {
        case .overview: return "chart.bar.fill"
        case .scoreboard: return "list.bullet"
        case .stats: return "chart.line.uptrend.xyaxis"
        case .progression: return "arrow.up.right"
        }
    }
}

// MARK: - MVP Card

struct MVPCard: View {
    let player: Player
    let match: Match

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "crown.fill")
                    .foregroundColor(.yellow)
                Text("MATCH MVP")
                    .font(.headline)
                    .foregroundColor(.yellow)
            }

            VStack(spacing: 8) {
                Text(player.username)
                    .font(.title.bold())

                HStack(spacing: 24) {
                    statColumn(value: "\(player.stats.eliminations)", label: "Eliminations")
                    statColumn(value: "\(player.stats.assists)", label: "Assists")
                    statColumn(value: String(format: "%.1f", player.stats.kdRatio), label: "K/D")
                    statColumn(value: "\(player.stats.damageDealt)", label: "Damage")
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            LinearGradient(
                colors: [.yellow.opacity(0.3), .orange.opacity(0.2)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
    }

    private func statColumn(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2.bold())
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Match Highlights Card

struct MatchHighlightsCard: View {
    let match: Match

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "star.fill")
                    .foregroundColor(.cyan)
                Text("MATCH HIGHLIGHTS")
                    .font(.headline)
            }

            VStack(spacing: 8) {
                highlightRow(
                    icon: "target",
                    text: "Most Eliminations: \(match.getTopEliminator()?.username ?? "N/A") (\(match.getTopEliminatorCount()))"
                )

                highlightRow(
                    icon: "shield.fill",
                    text: "Most Damage Blocked: \(match.getTopDefender()?.username ?? "N/A")"
                )

                highlightRow(
                    icon: "flag.fill",
                    text: "Most Objectives: \(match.getTopObjectivePlayer()?.username ?? "N/A")"
                )

                highlightRow(
                    icon: "bolt.fill",
                    text: "Fastest Ultimate: \(match.getFastestUltimate()?.username ?? "N/A")"
                )
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.white.opacity(0.05))
        .cornerRadius(12)
    }

    private func highlightRow(icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.cyan)
                .frame(width: 24)

            Text(text)
                .font(.subheadline)

            Spacer()
        }
    }
}

// MARK: - Personal Performance Card

struct PersonalPerformanceCard: View {
    let player: Player
    let match: Match

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "person.fill")
                    .foregroundColor(.cyan)
                Text("YOUR PERFORMANCE")
                    .font(.headline)
            }

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                statBox(value: "\(player.stats.eliminations)", label: "Eliminations", icon: "target")
                statBox(value: "\(player.stats.deaths)", label: "Deaths", icon: "xmark")
                statBox(value: "\(player.stats.assists)", label: "Assists", icon: "hand.thumbsup")
                statBox(value: "\(player.stats.damageDealt)", label: "Damage", icon: "burst")
                statBox(value: "\(player.stats.objectiveScore)", label: "Objective", icon: "flag")
                statBox(value: String(format: "%.1f", player.stats.kdRatio), label: "K/D", icon: "chart.line.uptrend.xyaxis")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.white.opacity(0.05))
        .cornerRadius(12)
    }

    private func statBox(value: String, label: String, icon: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.cyan)

            Text(value)
                .font(.title3.bold())

            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.white.opacity(0.05))
        .cornerRadius(8)
    }
}

// MARK: - Match Timeline Card

struct MatchTimelineCard: View {
    let match: Match

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "clock.fill")
                    .foregroundColor(.cyan)
                Text("MATCH TIMELINE")
                    .font(.headline)
            }

            VStack(alignment: .leading, spacing: 12) {
                ForEach(match.getKeyEvents().prefix(5), id: \.timestamp) { event in
                    timelineRow(event: event)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.white.opacity(0.05))
        .cornerRadius(12)
    }

    private func timelineRow(event: MatchEvent) -> some View {
        HStack(spacing: 12) {
            Circle()
                .fill(.cyan)
                .frame(width: 8, height: 8)

            VStack(alignment: .leading, spacing: 2) {
                Text(event.description)
                    .font(.subheadline)
                Text(event.timeString)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
    }
}

// MARK: - Team Scoreboard Card

struct TeamScoreboardCard: View {
    let team: Team
    let match: Match

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Circle()
                    .fill(team.color == .blue ? .cyan : .red)
                    .frame(width: 12, height: 12)

                Text("\(team.color == .blue ? "BLUE" : "RED") TEAM")
                    .font(.headline)
                    .foregroundColor(team.color == .blue ? .cyan : .red)

                Spacer()

                Text("\(team.score)")
                    .font(.title2.bold())
            }

            // Header
            HStack {
                Text("Player")
                    .font(.caption.bold())
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("K")
                    .font(.caption.bold())
                    .frame(width: 40)
                Text("D")
                    .font(.caption.bold())
                    .frame(width: 40)
                Text("A")
                    .font(.caption.bold())
                    .frame(width: 40)
                Text("DMG")
                    .font(.caption.bold())
                    .frame(width: 60, alignment: .trailing)
            }
            .foregroundColor(.secondary)

            Divider()
                .background(.white.opacity(0.3))

            // Players
            ForEach(team.players.sorted(by: { $0.stats.score > $1.stats.score })) { player in
                playerRow(player: player)
            }
        }
        .padding()
        .background(.white.opacity(0.05))
        .cornerRadius(12)
    }

    private func playerRow(player: Player) -> some View {
        HStack {
            Text(player.username)
                .font(.subheadline)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text("\(player.stats.eliminations)")
                .font(.subheadline)
                .frame(width: 40)

            Text("\(player.stats.deaths)")
                .font(.subheadline)
                .frame(width: 40)

            Text("\(player.stats.assists)")
                .font(.subheadline)
                .frame(width: 40)

            Text("\(player.stats.damageDealt)")
                .font(.subheadline)
                .frame(width: 60, alignment: .trailing)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Stats Card

struct StatsCard: View {
    let title: String
    let icon: String
    let stats: [(String, String)]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.cyan)
                Text(title)
                    .font(.headline)
            }

            VStack(spacing: 8) {
                ForEach(stats, id: \.0) { stat in
                    HStack {
                        Text(stat.0)
                            .font(.subheadline)
                        Spacer()
                        Text(stat.1)
                            .font(.subheadline.bold())
                            .foregroundColor(.cyan)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.white.opacity(0.05))
        .cornerRadius(12)
    }
}

// MARK: - SR Change Card

struct SRChangeCard: View {
    let oldSR: Int
    let newSR: Int
    let didWin: Bool

    var srChange: Int {
        newSR - oldSR
    }

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .foregroundColor(.cyan)
                Text("SKILL RATING CHANGE")
                    .font(.headline)
            }

            HStack(spacing: 32) {
                VStack(spacing: 4) {
                    Text("Previous")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(oldSR)")
                        .font(.title.bold())
                }

                Image(systemName: "arrow.right")
                    .foregroundColor(.cyan)

                VStack(spacing: 4) {
                    Text("New")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(newSR)")
                        .font(.title.bold())
                        .foregroundColor(didWin ? .green : .red)
                }
            }

            Text("\(srChange >= 0 ? "+" : "")\(srChange) SR")
                .font(.title2.bold())
                .foregroundColor(didWin ? .green : .red)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            LinearGradient(
                colors: didWin ? [.green.opacity(0.2), .cyan.opacity(0.1)] : [.red.opacity(0.2), .orange.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
    }
}

// MARK: - Unlocks Card

struct UnlocksCard: View {
    let rewards: [Reward]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "gift.fill")
                    .foregroundColor(.yellow)
                Text("UNLOCKS & REWARDS")
                    .font(.headline)
            }

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(rewards, id: \.id) { reward in
                    rewardBox(reward: reward)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.white.opacity(0.05))
        .cornerRadius(12)
    }

    private func rewardBox(reward: Reward) -> some View {
        HStack(spacing: 12) {
            Image(systemName: reward.iconName)
                .font(.title2)
                .foregroundColor(.yellow)

            VStack(alignment: .leading, spacing: 2) {
                Text(reward.name)
                    .font(.subheadline.bold())
                Text(reward.category)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding()
        .background(.white.opacity(0.05))
        .cornerRadius(8)
    }
}

// MARK: - Challenges Card

struct ChallengesCard: View {
    let challenges: [Challenge]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.cyan)
                Text("CHALLENGES PROGRESS")
                    .font(.headline)
            }

            VStack(spacing: 12) {
                ForEach(challenges.prefix(3), id: \.id) { challenge in
                    challengeRow(challenge: challenge)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.white.opacity(0.05))
        .cornerRadius(12)
    }

    private func challengeRow(challenge: Challenge) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(challenge.title)
                    .font(.subheadline.bold())
                Spacer()
                Text("\(challenge.progress)/\(challenge.target)")
                    .font(.caption)
                    .foregroundColor(.cyan)
            }

            ProgressView(value: Double(challenge.progress), total: Double(challenge.target))
                .tint(.cyan)
        }
    }
}

// MARK: - Season Progress Card

struct SeasonProgressCard: View {
    let currentXP: Int
    let xpGained: Int
    let nextLevel: Int

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                Text("SEASON PROGRESS")
                    .font(.headline)
            }

            VStack(spacing: 12) {
                HStack {
                    Text("XP Gained")
                    Spacer()
                    Text("+\(xpGained) XP")
                        .font(.headline)
                        .foregroundColor(.cyan)
                }

                ProgressView(value: Double(currentXP % 1000), total: 1000.0)
                    .tint(.cyan)

                HStack {
                    Text("Level \(nextLevel - 1)")
                        .font(.caption)
                    Spacer()
                    Text("Level \(nextLevel)")
                        .font(.caption)
                }
                .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.white.opacity(0.05))
        .cornerRadius(12)
    }
}

// MARK: - Supporting Types

struct Reward: Identifiable {
    let id: UUID = UUID()
    let name: String
    let category: String
    let iconName: String
}

struct Challenge: Identifiable {
    let id: UUID
    let title: String
    let progress: Int
    let target: Int
}

// MARK: - Match Extensions

extension Match {
    func getMVP() -> Player? {
        let allPlayers = team1.players + team2.players
        return allPlayers.max(by: { $0.stats.score < $1.stats.score })
    }

    func getTopEliminator() -> Player? {
        let allPlayers = team1.players + team2.players
        return allPlayers.max(by: { $0.stats.eliminations < $1.stats.eliminations })
    }

    func getTopEliminatorCount() -> Int {
        getTopEliminator()?.stats.eliminations ?? 0
    }

    func getTopDefender() -> Player? {
        let allPlayers = team1.players + team2.players
        return allPlayers.max(by: { $0.stats.damageBlocked < $1.stats.damageBlocked })
    }

    func getTopObjectivePlayer() -> Player? {
        let allPlayers = team1.players + team2.players
        return allPlayers.max(by: { $0.stats.objectiveScore < $1.stats.objectiveScore })
    }

    func getFastestUltimate() -> Player? {
        // Placeholder - would track actual times
        return team1.players.first
    }

    func getKeyEvents() -> [MatchEvent] {
        return events.sorted(by: { $0.timestamp > $1.timestamp })
    }

    func getCombatStats() -> [(String, String)] {
        let allPlayers = team1.players + team2.players
        let totalElims = allPlayers.reduce(0) { $0 + $1.stats.eliminations }
        let totalDamage = allPlayers.reduce(0) { $0 + $1.stats.damageDealt }

        return [
            ("Total Eliminations", "\(totalElims)"),
            ("Total Damage Dealt", "\(totalDamage)"),
            ("Average K/D Ratio", String(format: "%.2f", 1.5)),
            ("Headshot Percentage", "18%")
        ]
    }

    func getObjectiveStats() -> [(String, String)] {
        return [
            ("Territories Captured", "\(objectives.count)"),
            ("Artifacts Collected", "12"),
            ("Power-ups Collected", "24"),
            ("Objective Time", "3:42")
        ]
    }

    func getPerformanceStats() -> [(String, String)] {
        return [
            ("Match Duration", "8:32"),
            ("Average FPS", "89"),
            ("Peak Players", "10"),
            ("Network Quality", "Excellent")
        ]
    }

    func calculateXPEarned() -> Int {
        return 250 // Placeholder
    }

    var rewards: [Reward] {
        return [] // Placeholder
    }
}

extension MatchEvent {
    var description: String {
        switch self {
        case .playerElimination(let killerID, let victimID, _):
            return "Player eliminated"
        case .objectiveCaptured(_, let team, _):
            return "\(team == .blue ? "Blue" : "Red") team captured objective"
        default:
            return "Event occurred"
        }
    }

    var timeString: String {
        let minutes = Int(timestamp) / 60
        let seconds = Int(timestamp) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// MARK: - Preview

#Preview {
    PostMatchView(
        match: Match(
            matchType: .competitive,
            gameMode: .teamDeathmatch,
            arena: .cyberArena(),
            team1: Team(color: .blue, players: [
                Player(username: "Player1", skillRating: 1500, team: .blue)
            ]),
            team2: Team(color: .red, players: [
                Player(username: "Player2", skillRating: 1520, team: .red)
            ])
        ),
        localPlayerTeam: .blue,
        didWin: true
    )
    .environment(AppState())
}
