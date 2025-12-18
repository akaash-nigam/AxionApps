import SwiftUI

/// Settings view for game configuration
struct SettingsView: View {
    @Environment(GameViewModel.self) private var gameViewModel
    @AppStorage("difficulty") private var preferredDifficulty = "beginner"
    @AppStorage("audioVolume") private var audioVolume: Double = 0.7
    @AppStorage("hintsEnabled") private var hintsEnabled = true
    @AppStorage("showFPS") private var showFPS = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 30) {
                // Header
                Text("Settings")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Divider()

                // Gameplay Settings
                SettingSection(title: "Gameplay") {
                    Picker("Preferred Difficulty", selection: $preferredDifficulty) {
                        Text("Beginner").tag("beginner")
                        Text("Intermediate").tag("intermediate")
                        Text("Advanced").tag("advanced")
                        Text("Expert").tag("expert")
                    }

                    Toggle("Enable Hints", isOn: $hintsEnabled)
                }

                // Audio Settings
                SettingSection(title: "Audio") {
                    VStack(alignment: .leading) {
                        Text("Volume: \(Int(audioVolume * 100))%")
                        Slider(value: $audioVolume, in: 0...1)
                    }
                }

                // Accessibility Settings
                SettingSection(title: "Accessibility") {
                    Toggle("High Contrast Mode", isOn: .constant(false))
                    Toggle("Reduce Motion", isOn: .constant(false))
                    Toggle("Larger Text", isOn: .constant(false))
                }

                // Developer Settings
                SettingSection(title: "Developer") {
                    Toggle("Show FPS Counter", isOn: $showFPS)
                    Toggle("Debug Mode", isOn: .constant(false))
                }

                Divider()

                // Account Section
                SettingSection(title: "Account") {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Level \(gameViewModel.playerLevel)")
                                .font(.headline)
                            Text("\(gameViewModel.playerXP) XP")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }

                        Spacer()

                        Button("View Profile") {
                            // Open profile
                        }
                        .buttonStyle(.bordered)
                    }
                }

                // About Section
                SettingSection(title: "About") {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Escape Room Network")
                            .font(.headline)
                        Text("Version 1.0.0")
                            .foregroundColor(.secondary)
                        Text("© 2025 Escape Room Network")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(40)
        }
    }
}

/// Reusable settings section component
struct SettingSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text(title)
                .font(.title2)
                .fontWeight(.semibold)

            VStack(alignment: .leading, spacing: 12) {
                content
            }
            .padding()
            .background(Color.secondary.opacity(0.1))
            .cornerRadius(10)
        }
    }
}

#Preview {
    SettingsView()
        .environment(GameViewModel())
}
