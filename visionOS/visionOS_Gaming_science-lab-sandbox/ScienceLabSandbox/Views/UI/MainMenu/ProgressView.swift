//
//  ProgressView.swift
//  Science Lab Sandbox
//
//  Player progress and achievements view
//

import SwiftUI

struct ProgressView: View {

    @EnvironmentObject var gameCoordinator: GameCoordinator
    @Environment(\.dismiss) private var dismiss

    var progress: PlayerProgress {
        gameCoordinator.playerProgress
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 30) {
                    // Level and XP
                    levelSection

                    // Statistics
                    statisticsSection

                    // Skill Levels
                    skillLevelsSection

                    // Achievements
                    achievementsSection
                }
                .padding()
            }
            .navigationTitle("My Progress")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }

    // MARK: - Level Section

    private var levelSection: some View {
        VStack(spacing: 15) {
            Text("Level \(progress.currentLevel)")
                .font(.system(size: 60, weight: .bold, design: .rounded))
                .foregroundStyle(.yellow)

            let xpProgress = progress.xpProgressInCurrentLevel()
            VStack(spacing: 8) {
                SwiftUI.ProgressView(value: Double(xpProgress.current), total: Double(xpProgress.needed))
                    .tint(.yellow)

                Text("\(xpProgress.current) / \(xpProgress.needed) XP")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal)
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(20)
    }

    // MARK: - Statistics Section

    private var statisticsSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Statistics")
                .font(.title2)
                .fontWeight(.bold)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                StatCard(
                    title: "Experiments",
                    value: "\(progress.totalExperiments)",
                    icon: "flask.fill",
                    color: .blue
                )

                StatCard(
                    title: "Lab Time",
                    value: formatLabTime(progress.totalLabTime),
                    icon: "clock.fill",
                    color: .green
                )

                StatCard(
                    title: "Measurements",
                    value: "\(progress.totalMeasurements)",
                    icon: "ruler.fill",
                    color: .purple
                )

                StatCard(
                    title: "Observations",
                    value: "\(progress.totalObservations)",
                    icon: "eye.fill",
                    color: .orange
                )

                StatCard(
                    title: "Hypotheses",
                    value: "\(progress.hypothesesFormed)",
                    icon: "lightbulb.fill",
                    color: .yellow
                )

                StatCard(
                    title: "Safety Record",
                    value: progress.safetyViolations == 0 ? "Perfect" : "\(progress.safetyViolations) violations",
                    icon: "shield.fill",
                    color: progress.safetyViolations == 0 ? .green : .red
                )
            }
        }
    }

    // MARK: - Skill Levels Section

    private var skillLevelsSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Skill Levels")
                .font(.title2)
                .fontWeight(.bold)

            VStack(spacing: 12) {
                ForEach(ScientificDiscipline.allCases) { discipline in
                    let skillLevel = progress.getSkillLevel(for: discipline)

                    HStack {
                        Image(systemName: discipline.icon)
                            .font(.title3)
                            .frame(width: 40)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(discipline.displayName)
                                .fontWeight(.semibold)

                            Text(skillLevel.name)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        HStack(spacing: 4) {
                            ForEach(1...5, id: \.self) { level in
                                Image(systemName: level <= skillLevel.level ? "star.fill" : "star")
                                    .font(.caption)
                                    .foregroundStyle(.yellow)
                            }
                        }
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(12)
                }
            }
        }
    }

    // MARK: - Achievements Section

    private var achievementsSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Achievements (\(progress.achievements.count))")
                .font(.title2)
                .fontWeight(.bold)

            if progress.achievements.isEmpty {
                Text("No achievements yet. Keep experimenting!")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(12)
            } else {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                    ForEach(progress.achievements) { achievement in
                        AchievementCard(achievement: achievement)
                    }
                }
            }
        }
    }

    // MARK: - Helpers

    private func formatLabTime(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60

        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

// MARK: - Stat Card

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title)
                .foregroundStyle(color)

            Text(value)
                .font(.title3)
                .fontWeight(.bold)

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(12)
    }
}

// MARK: - Achievement Card

struct AchievementCard: View {
    let achievement: Achievement

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: achievement.iconName)
                .font(.largeTitle)
                .foregroundStyle(rarityColor)

            Text(achievement.name)
                .font(.headline)
                .multilineTextAlignment(.center)

            Text(achievement.description)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Text(achievement.rarity.displayName)
                .font(.caption2)
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(rarityColor.opacity(0.2))
                .cornerRadius(8)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(rarityColor, lineWidth: 2)
        )
    }

    private var rarityColor: Color {
        switch achievement.rarity {
        case .common: return .gray
        case .rare: return .blue
        case .epic: return .purple
        case .legendary: return .orange
        }
    }
}

#Preview {
    ProgressView()
        .environmentObject(GameCoordinator())
}
