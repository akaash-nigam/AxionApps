import SwiftUI

struct SettingsView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss

    @AppStorage("difficultyLevel") private var difficultyLevel = "Adaptive"
    @AppStorage("aiCoachingEnabled") private var aiCoachingEnabled = true
    @AppStorage("voiceGuidanceEnabled") private var voiceGuidanceEnabled = true
    @AppStorage("breakReminderInterval") private var breakReminderInterval = 20
    @AppStorage("soundEffectsVolume") private var soundEffectsVolume = 80.0
    @AppStorage("voiceCoachVolume") private var voiceCoachVolume = 75.0
    @AppStorage("voiceOverEnabled") private var voiceOverEnabled = false
    @AppStorage("highContrastEnabled") private var highContrastEnabled = false

    var body: some View {
        NavigationStack {
            Form {
                // Profile Section
                profileSection

                // Training Preferences
                trainingPreferencesSection

                // Comfort Settings
                comfortSettingsSection

                // Accessibility
                accessibilitySection

                // Privacy
                privacySection
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }

    // MARK: - Profile Section

    private var profileSection: some View {
        Section("Profile") {
            VStack(alignment: .leading, spacing: 8) {
                Text(appState.currentUser?.name ?? "Unknown User")
                    .font(.headline)

                Text(appState.currentUser?.roleDescription ?? "No Role")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                if let employeeId = appState.currentUser?.employeeId {
                    Text("Employee ID: \(employeeId)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.vertical, 8)

            Button("Edit Profile", systemImage: "person.circle") {
                // Edit profile action
            }
        }
    }

    // MARK: - Training Preferences

    private var trainingPreferencesSection: some View {
        Section("Training Preferences") {
            Picker("Difficulty Level", selection: $difficultyLevel) {
                Text("Beginner").tag("Beginner")
                Text("Intermediate").tag("Intermediate")
                Text("Advanced").tag("Advanced")
                Text("Adaptive").tag("Adaptive")
            }

            Toggle("AI Coaching", isOn: $aiCoachingEnabled)
                .help("Enable real-time AI coaching during training scenarios")

            Toggle("Voice Guidance", isOn: $voiceGuidanceEnabled)
                .help("Enable voice instructions and guidance")

            Picker("Break Reminders", selection: $breakReminderInterval) {
                Text("Every 15 min").tag(15)
                Text("Every 20 min").tag(20)
                Text("Every 30 min").tag(30)
                Text("Every 60 min").tag(60)
                Text("Off").tag(0)
            }
        }
    }

    // MARK: - Comfort Settings

    private var comfortSettingsSection: some View {
        Section("Comfort Settings") {
            Picker("Comfort Mode", selection: .constant("Standard")) {
                Text("Low Motion").tag("Low")
                Text("Standard").tag("Standard")
                Text("High Performance").tag("High")
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Sound Effects Volume")
                    .font(.callout)

                HStack {
                    Image(systemName: "speaker.fill")
                        .foregroundStyle(.secondary)

                    Slider(value: $soundEffectsVolume, in: 0...100, step: 5)

                    Text("\(Int(soundEffectsVolume))%")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(width: 40)
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Voice Coach Volume")
                    .font(.callout)

                HStack {
                    Image(systemName: "speaker.wave.2.fill")
                        .foregroundStyle(.secondary)

                    Slider(value: $voiceCoachVolume, in: 0...100, step: 5)

                    Text("\(Int(voiceCoachVolume))%")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(width: 40)
                }
            }
        }
    }

    // MARK: - Accessibility

    private var accessibilitySection: some View {
        Section("Accessibility") {
            Toggle("VoiceOver", isOn: $voiceOverEnabled)
                .help("Enable VoiceOver for screen reading")

            Picker("Text Size", selection: .constant("Large")) {
                Text("Small").tag("Small")
                Text("Medium").tag("Medium")
                Text("Large").tag("Large")
                Text("Extra Large").tag("XLarge")
            }

            Toggle("High Contrast", isOn: $highContrastEnabled)
                .help("Increase visual contrast for better visibility")

            Picker("Alternative Controls", selection: .constant("Voice")) {
                Text("Standard").tag("Standard")
                Text("Voice Commands").tag("Voice")
                Text("Dwell Control").tag("Dwell")
                Text("External Controller").tag("Controller")
            }
        }
    }

    // MARK: - Privacy

    private var privacySection: some View {
        Section("Privacy") {
            Toggle("Performance Analytics", isOn: .constant(true))
                .help("Share anonymous performance data to improve training")

            Button("View Privacy Policy", systemImage: "doc.text") {
                // Show privacy policy
            }

            Button("Delete My Data", systemImage: "trash", role: .destructive) {
                // Delete user data
            }
        }
    }
}

#Preview {
    SettingsView()
        .environment(AppState())
}
