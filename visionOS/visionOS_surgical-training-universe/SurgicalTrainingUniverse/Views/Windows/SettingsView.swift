//
//  SettingsView.swift
//  Surgical Training Universe
//
//  Application settings and preferences
//

import SwiftUI

/// Settings and preferences view
struct SettingsView: View {

    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss

    @State private var enableHapticFeedback = true
    @State private var enableSpatialAudio = true
    @State private var enableAICoaching = true
    @State private var difficultyLevel = 2
    @State private var handedness: Handedness = .right
    @State private var voiceCommandsEnabled = false

    var body: some View {
        NavigationStack {
            Form {
                // User Profile Section
                Section("User Profile") {
                    if let user = appState.currentUser {
                        LabeledContent("Name", value: user.name)
                        LabeledContent("Email", value: user.email)
                        LabeledContent("Specialization", value: user.specialization.rawValue)
                        LabeledContent("Level", value: user.level.rawValue)
                        LabeledContent("Institution", value: user.institution)
                    }

                    Button("Edit Profile") {
                        // Edit profile
                    }
                }

                // Training Preferences
                Section("Training Preferences") {
                    Toggle("Enable AI Coaching", isOn: $enableAICoaching)
                    Toggle("Haptic Feedback", isOn: $enableHapticFeedback)
                    Toggle("Spatial Audio", isOn: $enableSpatialAudio)
                    Toggle("Voice Commands", isOn: $voiceCommandsEnabled)

                    Picker("Handedness", selection: $handedness) {
                        Text("Right-Handed").tag(Handedness.right)
                        Text("Left-Handed").tag(Handedness.left)
                        Text("Ambidextrous").tag(Handedness.ambidextrous)
                    }

                    Picker("Default Difficulty", selection: $difficultyLevel) {
                        Text("Beginner").tag(1)
                        Text("Intermediate").tag(2)
                        Text("Advanced").tag(3)
                        Text("Expert").tag(4)
                    }
                }

                // Accessibility
                Section("Accessibility") {
                    NavigationLink("Accessibility Options") {
                        AccessibilitySettingsView()
                    }

                    Toggle("High Contrast Mode", isOn: .constant(false))
                    Toggle("Reduce Transparency", isOn: .constant(false))
                }

                // Privacy & Security
                Section("Privacy & Security") {
                    NavigationLink("Data & Privacy") {
                        PrivacySettingsView()
                    }

                    Button("Clear Cache") {
                        clearCache()
                    }

                    Button("Export My Data") {
                        exportUserData()
                    }
                }

                // About
                Section("About") {
                    LabeledContent("Version", value: "1.0.0")
                    LabeledContent("Build", value: "2025.11.17")

                    NavigationLink("Licenses") {
                        LicensesView()
                    }

                    Link("Privacy Policy", destination: URL(string: "https://example.com/privacy")!)
                    Link("Terms of Service", destination: URL(string: "https://example.com/terms")!)
                }

                // Sign Out
                Section {
                    Button("Sign Out", role: .destructive) {
                        signOut()
                    }
                }
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

    private func clearCache() {
        print("Clearing cache...")
    }

    private func exportUserData() {
        print("Exporting user data...")
    }

    private func signOut() {
        appState.signOut()
        dismiss()
    }
}

enum Handedness: String {
    case right = "Right"
    case left = "Left"
    case ambidextrous = "Ambidextrous"
}

// MARK: - Accessibility Settings

struct AccessibilitySettingsView: View {
    @State private var voiceOverEnabled = false
    @State private var largerText = false
    @State private var reduceMotion = false

    var body: some View {
        Form {
            Section("Visual") {
                Toggle("Larger Text", isOn: $largerText)
                Toggle("Reduce Motion", isOn: $reduceMotion)
            }

            Section("Audio") {
                Toggle("VoiceOver Support", isOn: $voiceOverEnabled)
            }
        }
        .navigationTitle("Accessibility")
    }
}

// MARK: - Privacy Settings

struct PrivacySettingsView: View {
    @State private var analyticsEnabled = true
    @State private var crashReporting = true

    var body: some View {
        Form {
            Section("Data Collection") {
                Toggle("Anonymous Analytics", isOn: $analyticsEnabled)
                Toggle("Crash Reporting", isOn: $crashReporting)

                Text("We collect anonymous usage data to improve the training experience. All data is de-identified and HIPAA compliant.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section {
                Button("Delete All My Data", role: .destructive) {
                    // Delete all user data
                }
            }
        }
        .navigationTitle("Data & Privacy")
    }
}

// MARK: - Licenses View

struct LicensesView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Open Source Licenses")
                    .font(.title2)
                    .fontWeight(.semibold)

                Text("This application uses the following open source software:")
                    .foregroundStyle(.secondary)

                // License entries would go here
                LicenseEntry(
                    name: "Swift",
                    license: "Apache License 2.0",
                    url: "https://swift.org"
                )
            }
            .padding()
        }
        .navigationTitle("Licenses")
    }
}

struct LicenseEntry: View {
    let name: String
    let license: String
    let url: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(name)
                .font(.headline)

            Text(license)
                .font(.caption)
                .foregroundStyle(.secondary)

            Link(url, destination: URL(string: url)!)
                .font(.caption)
        }
        .padding()
        .background(.thinMaterial)
        .cornerRadius(12)
    }
}

#Preview {
    SettingsView()
        .environment(AppState())
}
