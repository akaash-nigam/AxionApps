//
//  SettingsView.swift
//  Science Lab Sandbox
//
//  Settings and preferences view
//

import SwiftUI

struct SettingsView: View {

    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                // Gameplay Settings
                Section("Gameplay") {
                    Picker("Difficulty Mode", selection: $appState.difficultyMode) {
                        ForEach(DifficultyMode.allCases) { mode in
                            Text(mode.displayName).tag(mode)
                        }
                    }

                    // Note: Immersion style is set in the app's ImmersiveSpace declaration
                    // and cannot be changed at runtime
                }

                // Audio Settings
                Section("Audio") {
                    Toggle("Spatial Audio", isOn: $appState.enableSpatialAudio)
                    Toggle("Haptic Feedback", isOn: $appState.enableHaptics)
                    Toggle("Voice Commands", isOn: $appState.enableVoiceCommands)
                }

                // Accessibility
                Section("Accessibility") {
                    Picker("Accessibility Mode", selection: $appState.accessibilityMode) {
                        ForEach(AccessibilityMode.allCases) { mode in
                            Text(mode.displayName).tag(mode)
                        }
                    }
                }

                // About
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }

                    HStack {
                        Text("Build")
                        Spacer()
                        Text("1")
                            .foregroundStyle(.secondary)
                    }

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

#Preview {
    SettingsView()
        .environmentObject(AppState())
}
