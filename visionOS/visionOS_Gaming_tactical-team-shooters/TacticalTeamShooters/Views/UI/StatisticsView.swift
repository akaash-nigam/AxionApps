import SwiftUI

/// Player statistics view
struct StatisticsView: View {

    @EnvironmentObject private var appState: AppState

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    if let player = appState.currentPlayer {
                        // Combat Stats
                        StatsSection(title: "Combat") {
                            StatRow(label: "K/D Ratio", value: String(format: "%.2f", player.statistics.killDeathRatio))
                            StatRow(label: "Total Kills", value: "\(player.statistics.totalKills)")
                            StatRow(label: "Total Deaths", value: "\(player.statistics.totalDeaths)")
                            StatRow(label: "Headshot %", value: String(format: "%.1f%%", player.statistics.headshotPercentage * 100))
                        }

                        // Match Stats
                        StatsSection(title: "Matches") {
                            StatRow(label: "Matches Played", value: "\(player.statistics.matchesPlayed)")
                            StatRow(label: "Win Rate", value: String(format: "%.1f%%", player.statistics.winRate * 100))
                            StatRow(label: "Accuracy", value: String(format: "%.1f%%", player.statistics.accuracy * 100))
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Statistics")
        }
    }
}

struct StatsSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
                .foregroundColor(.secondary)

            VStack(spacing: 8) {
                content
            }
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(12)
        }
    }
}

struct StatRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
        }
    }
}

#Preview {
    StatisticsView()
        .environmentObject(AppState())
}
