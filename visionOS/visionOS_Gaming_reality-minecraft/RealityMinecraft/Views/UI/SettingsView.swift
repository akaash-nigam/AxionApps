//
//  SettingsView.swift
//  Reality Minecraft
//
//  Settings view
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appModel: AppModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            Form {
                // Graphics Settings
                Section("Graphics") {
                    Picker("Detail Level", selection: $appModel.settings.detailLevel) {
                        Text("Low").tag(GameSettings.DetailLevel.low)
                        Text("Medium").tag(GameSettings.DetailLevel.medium)
                        Text("High").tag(GameSettings.DetailLevel.high)
                    }

                    Stepper("Render Distance: \(appModel.settings.renderDistance) chunks",
                            value: $appModel.settings.renderDistance,
                            in: 4...12)

                    Toggle("Shadows", isOn: $appModel.settings.enableShadows)
                    Toggle("Particles", isOn: $appModel.settings.enableParticles)
                }

                // Audio Settings
                Section("Audio") {
                    Slider(value: $appModel.settings.masterVolume, in: 0...1) {
                        Text("Master Volume")
                    }

                    Slider(value: $appModel.settings.musicVolume, in: 0...1) {
                        Text("Music Volume")
                    }

                    Slider(value: $appModel.settings.sfxVolume, in: 0...1) {
                        Text("Sound Effects")
                    }

                    Toggle("Spatial Audio", isOn: $appModel.settings.enableSpatialAudio)
                }

                // Controls Settings
                Section("Controls") {
                    Slider(value: $appModel.settings.handTrackingSensitivity, in: 0.5...2.0) {
                        Text("Hand Tracking Sensitivity")
                    }

                    Toggle("Voice Commands", isOn: $appModel.settings.enableVoiceCommands)
                    Toggle("Controller Support", isOn: $appModel.settings.enableController)
                }

                // Gameplay Settings
                Section("Gameplay") {
                    Picker("Difficulty", selection: $appModel.settings.difficulty) {
                        Text("Peaceful").tag(GameMode.Difficulty.peaceful)
                        Text("Easy").tag(GameMode.Difficulty.easy)
                        Text("Normal").tag(GameMode.Difficulty.normal)
                        Text("Hard").tag(GameMode.Difficulty.hard)
                    }

                    Toggle("Tutorial Hints", isOn: $appModel.settings.showTutorialHints)
                }

                // Comfort Settings
                Section("Comfort") {
                    Toggle("Break Reminders", isOn: $appModel.settings.enableBreakReminders)
                    Toggle("Safety Boundaries", isOn: $appModel.settings.enableSafetyBoundaries)

                    Slider(value: $appModel.settings.uiDistance, in: 0.3...1.0) {
                        Text("UI Distance")
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
}

#Preview {
    SettingsView()
        .environmentObject(AppModel())
}
