//
//  ProfileView.swift
//  Spatial Arena Championship
//
//  Player profile and stats view
//

import SwiftUI
import Charts

struct ProfileView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 30) {
                    // Player Header
                    PlayerHeaderSection(profile: appState.localPlayer)

                    // Rank Progress
                    RankProgressSection(profile: appState.localPlayer)

                    // Career Stats
                    CareerStatsSection(profile: appState.localPlayer)

                    // Recent Performance
                    RecentPerformanceSection()
                }
                .padding()
            }
            .background(Color(hex: 0x1a1a2e))
            .navigationTitle("Profile")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Player Header Section

struct PlayerHeaderSection: View {
    let profile: PlayerProfile

    var body: some View {
        VStack(spacing: 15) {
            // Avatar (placeholder)
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color(hex: 0x00d4ff), Color(hex: 0x00bfff)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 100, height: 100)
                .overlay(
                    Text(String(profile.username.prefix(2)).uppercased())
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.white)
                )

            // Username
            Text(profile.username)
                .font(.title)
                .fontWeight(.bold)

            // Rank Badge
            HStack(spacing: 10) {
                Image(systemName: "medal.fill")
                    .foregroundColor(rankColor(profile.rank))

                Text(profile.rank.displayName)
                    .font(.title3)
                    .fontWeight(.semibold)

                Text("•")
                    .foregroundColor(.secondary)

                Text("\(profile.skillRating) SR")
                    .font(.title3)
                    .foregroundColor(.secondary)
            }

            // Level
            HStack {
                Text("Level \(profile.level)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Text("•")
                    .foregroundColor(.secondary)

                Text("\(profile.experience) XP")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func rankColor(_ rank: RankTier) -> Color {
        switch rank {
        case .bronze: return Color(hex: 0xCD7F32)
        case .silver: return Color(hex: 0xC0C0C0)
        case .gold: return Color(hex: 0xFFD700)
        case .platinum: return Color(hex: 0xE5E4E2)
        case .diamond: return Color(hex: 0xB9F2FF)
        case .master: return Color(hex: 0xFF6B6B)
        case .grandMaster: return Color(hex: 0xA020F0)
        case .champion: return Color(hex: 0xFFD700)
        }
    }
}

// MARK: - Rank Progress Section

struct RankProgressSection: View {
    let profile: PlayerProfile

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Rank Progress")
                .font(.headline)

            VStack(alignment: .leading, spacing: 8) {
                // Current rank range
                let range = profile.rank.srRange
                let progress = Float(profile.skillRating - range.lowerBound) / Float(range.upperBound - range.lowerBound)

                HStack {
                    Text("\(range.lowerBound) SR")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Spacer()

                    Text("\(profile.skillRating) SR")
                        .font(.caption)
                        .fontWeight(.semibold)

                    Spacer()

                    Text("\(range.upperBound) SR")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                ProgressView(value: progress)
                    .tint(Color(hex: 0x00d4ff))
            }

            // Win/Loss Record
            HStack(spacing: 30) {
                VStack {
                    Text("\(profile.totalWins)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Color(hex: 0x00ff88))

                    Text("Wins")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                VStack {
                    Text("\(profile.totalLosses)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Color(hex: 0xff4444))

                    Text("Losses")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                VStack {
                    Text(String(format: "%.1f%%", profile.winRate * 100))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Color(hex: 0x00d4ff))

                    Text("Win Rate")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Career Stats Section

struct CareerStatsSection: View {
    let profile: PlayerProfile

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Career Stats")
                .font(.headline)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                StatCard(
                    title: "Kills",
                    value: "\(profile.careerStats.kills)",
                    icon: "target",
                    color: Color(hex: 0xff4444)
                )

                StatCard(
                    title: "Deaths",
                    value: "\(profile.careerStats.deaths)",
                    icon: "xmark.circle",
                    color: Color(hex: 0xaaaaaa)
                )

                StatCard(
                    title: "Assists",
                    value: "\(profile.careerStats.assists)",
                    icon: "hand.thumbsup",
                    color: Color(hex: 0x00ff88)
                )

                StatCard(
                    title: "K/D/A",
                    value: String(format: "%.2f", profile.careerStats.kda),
                    icon: "chart.bar",
                    color: Color(hex: 0x00d4ff)
                )

                StatCard(
                    title: "Accuracy",
                    value: String(format: "%.1f%%", profile.careerStats.accuracy * 100),
                    icon: "scope",
                    color: Color(hex: 0xffaa00)
                )

                StatCard(
                    title: "Objectives",
                    value: "\(profile.careerStats.objectivesCaptured)",
                    icon: "flag",
                    color: Color(hex: 0xaa00ff)
                )
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Stat Card

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)

            Text(value)
                .font(.title3)
                .fontWeight(.bold)

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Recent Performance Section

struct RecentPerformanceSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Performance")
                .font(.headline)

            // Placeholder for SR trend chart
            VStack {
                Text("SR Trend")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Text("Chart Coming Soon")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.vertical, 30)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 150)
            .background(Color.white.opacity(0.05))
            .clipShape(RoundedRectangle(cornerRadius: 12))

            // Recent Matches
            Text("Recent Matches")
                .font(.subheadline)
                .foregroundColor(.secondary)

            VStack(spacing: 8) {
                ForEach(0..<3, id: \.self) { _ in
                    MatchHistoryCard()
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Match History Card

struct MatchHistoryCard: View {
    var body: some View {
        HStack {
            // Win/Loss indicator
            Circle()
                .fill(Color(hex: 0x00ff88))
                .frame(width: 10, height: 10)

            VStack(alignment: .leading, spacing: 4) {
                Text("Elimination • Cyber Arena")
                    .font(.caption)
                    .foregroundColor(.primary)

                Text("12/4/8 • +18 SR")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Text("2h ago")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.white.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - Preview

#Preview {
    ProfileView()
        .environment(AppState())
}
