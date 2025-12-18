import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appState: AppState

    var body: some View {
        NavigationStack {
            Form {
                // Game Settings
                Section("Game Settings") {
                    Picker("Difficulty", selection: $appState.settings.difficulty) {
                        ForEach(DifficultyLevel.allCases, id: \.self) { level in
                            Text(level.displayName).tag(level)
                        }
                    }

                    Picker("Hint Frequency", selection: $appState.settings.hintFrequency) {
                        ForEach(HintFrequency.allCases, id: \.self) { freq in
                            Text(freq.rawValue.capitalized).tag(freq)
                        }
                    }

                    Picker("Case Length", selection: $appState.settings.caseLength) {
                        ForEach(CaseLength.allCases, id: \.self) { length in
                            Text(length.rawValue.capitalized).tag(length)
                        }
                    }

                    Picker("Gore Level", selection: $appState.settings.goreLevel) {
                        ForEach(GoreLevel.allCases, id: \.self) { level in
                            Text(level.rawValue.capitalized).tag(level)
                        }
                    }
                }

                // Accessibility
                Section("Accessibility") {
                    Toggle("Seated Mode", isOn: $appState.settings.seatedMode)
                    Toggle("One-Handed Controls", isOn: $appState.settings.oneHandedMode)
                    Toggle("High Contrast Evidence", isOn: $appState.settings.highContrastEvidence)
                    Toggle("Audio Descriptions", isOn: $appState.settings.audioDescriptions)
                    Toggle("Reduced Motion", isOn: $appState.settings.reducedMotion)
                    Toggle("Extended Timeouts", isOn: $appState.settings.extendedTimeouts)
                }

                // Spatial Settings
                Section("Spatial Settings") {
                    Picker("Play Area Size", selection: $appState.settings.playAreaSize) {
                        ForEach(PlayAreaSize.allCases, id: \.self) { size in
                            Text(size.rawValue.capitalized).tag(size)
                        }
                    }

                    VStack(alignment: .leading) {
                        Text("UI Distance")
                        Slider(value: $appState.settings.uiDistance, in: 0.5...3.0, step: 0.1) {
                            Text("UI Distance")
                        }
                        Text("\(appState.settings.uiDistance, specifier: "%.1f") meters")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    VStack(alignment: .leading) {
                        Text("Evidence Scale")
                        Slider(value: $appState.settings.evidenceScale, in: 0.5...2.0, step: 0.1) {
                            Text("Evidence Scale")
                        }
                        Text("\(Int(appState.settings.evidenceScale * 100))%")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                // About
                Section("About") {
                    LabeledContent("Version", value: "1.0.0")
                    LabeledContent("Build", value: "1")

                    Link("Privacy Policy", destination: URL(string: "https://example.com/privacy")!)
                    Link("Terms of Service", destination: URL(string: "https://example.com/terms")!)
                }
            }
            .navigationTitle("Settings")
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
}

// MARK: - ProfileView

struct ProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appState: AppState

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Profile Header
                    profileHeader

                    // Statistics
                    statisticsSection

                    // Achievements
                    achievementsSection
                }
                .padding()
            }
            .navigationTitle("Profile")
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

    private var profileHeader: some View {
        VStack(spacing: 12) {
            Image(systemName: "person.circle.fill")
                .font(.system(size: 100))
                .foregroundColor(.accentColor)

            Text(appState.playerProgress.currentRank.rawValue)
                .font(.title2)
                .fontWeight(.bold)

            ProgressView(value: Float(appState.playerProgress.experience % 500), total: 500)
                .tint(.yellow)
                .frame(width: 200)

            Text("XP: \(appState.playerProgress.experience) / \((appState.playerProgress.experience / 500 + 1) * 500)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.regularMaterial)
        .cornerRadius(12)
    }

    private var statisticsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Statistics")
                .font(.headline)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                StatCard(title: "Cases Solved", value: "\(appState.playerProgress.casesCompleted)")
                StatCard(title: "Accuracy", value: "\(Int(appState.playerProgress.deductionAccuracy * 100))%")
                StatCard(title: "Play Time", value: "\(Int(appState.playerProgress.totalPlayTime / 3600))h")
                StatCard(title: "Perfect Cases", value: "\(appState.playerProgress.perfectSolutions)")
            }
        }
    }

    private var achievementsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Achievements")
                .font(.headline)

            if appState.playerProgress.achievements.isEmpty {
                Text("No achievements yet. Keep investigating!")
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                ForEach(appState.playerProgress.achievements) { achievement in
                    AchievementRow(achievement: achievement)
                }
            }
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.title)
                .fontWeight(.bold)

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.regularMaterial)
        .cornerRadius(8)
    }
}

struct AchievementRow: View {
    let achievement: Achievement

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: achievement.icon)
                .font(.title2)
                .foregroundColor(.yellow)
                .frame(width: 40)

            VStack(alignment: .leading, spacing: 4) {
                Text(achievement.title)
                    .font(.headline)

                Text(achievement.description)
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text(achievement.earnedDate.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding()
        .background(.regularMaterial)
        .cornerRadius(8)
    }
}

// MARK: - EvidenceExaminationView

struct EvidenceExaminationView: View {
    @EnvironmentObject var gameCoordinator: GameCoordinator
    @State private var selectedEvidence: Evidence?

    var body: some View {
        VStack {
            if let evidence = selectedEvidence {
                Text(evidence.name)
                    .font(.title)

                Text(evidence.description)
                    .font(.body)
                    .padding()
            } else {
                Text("Select evidence to examine")
                    .foregroundColor(.secondary)
            }
        }
    }
}

// MARK: - Preview

#Preview("Settings") {
    SettingsView()
        .environmentObject(AppState())
}

#Preview("Profile") {
    ProfileView()
        .environmentObject(AppState())
}
