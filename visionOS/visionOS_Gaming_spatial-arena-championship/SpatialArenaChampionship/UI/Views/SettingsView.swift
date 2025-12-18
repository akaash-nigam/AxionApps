//
//  SettingsView.swift
//  Spatial Arena Championship
//
//  Settings and configuration view
//

import SwiftUI

struct SettingsView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss

    @State private var settings: GameSettings

    init(settings: GameSettings) {
        _settings = State(initialValue: settings)
    }

    var body: some View {
        NavigationStack {
            Form {
                // Audio Settings
                Section("Audio") {
                    VStack(alignment: .leading, spacing: 12) {
                        SliderSetting(
                            title: "Master Volume",
                            value: $settings.audioSettings.masterVolume
                        )

                        SliderSetting(
                            title: "Music Volume",
                            value: $settings.audioSettings.musicVolume
                        )

                        SliderSetting(
                            title: "SFX Volume",
                            value: $settings.audioSettings.sfxVolume
                        )

                        SliderSetting(
                            title: "Voice Volume",
                            value: $settings.audioSettings.voiceVolume
                        )

                        Toggle("Spatial Audio", isOn: $settings.audioSettings.spatialAudioEnabled)
                    }
                }

                // Graphics Settings
                Section("Graphics") {
                    Picker("Quality", selection: $settings.graphicsSettings.quality) {
                        ForEach(GraphicsSettings.GraphicsQuality.allCases, id: \.self) { quality in
                            Text(quality.displayName).tag(quality)
                        }
                    }

                    Toggle("Particle Effects", isOn: $settings.graphicsSettings.particleEffects)
                    Toggle("Bloom", isOn: $settings.graphicsSettings.bloomEnabled)
                    Toggle("Dynamic Resolution", isOn: $settings.graphicsSettings.dynamicResolution)
                }

                // Control Settings
                Section("Controls") {
                    SliderSetting(
                        title: "Sensitivity",
                        value: $settings.controlSettings.sensitivity,
                        range: 0.5...2.0
                    )

                    Toggle("Aim Assist", isOn: $settings.controlSettings.aimAssist)

                    SliderSetting(
                        title: "Gesture Threshold",
                        value: $settings.controlSettings.gestureThreshold,
                        range: 0.3...1.0
                    )

                    Picker("Handedness", selection: $settings.controlSettings.handedness) {
                        Text("Left").tag(ControlSettings.Handedness.left)
                        Text("Right").tag(ControlSettings.Handedness.right)
                        Text("Ambidextrous").tag(ControlSettings.Handedness.ambidextrous)
                    }
                }

                // Accessibility
                Section("Accessibility") {
                    Picker("Colorblind Mode", selection: $settings.accessibilitySettings.colorBlindMode) {
                        ForEach(AccessibilitySettings.ColorBlindMode.allCases, id: \.self) { mode in
                            Text(mode.displayName).tag(mode)
                        }
                    }

                    Picker("Text Size", selection: $settings.accessibilitySettings.textSize) {
                        Text("Small").tag(AccessibilitySettings.TextSize.small)
                        Text("Medium").tag(AccessibilitySettings.TextSize.medium)
                        Text("Large").tag(AccessibilitySettings.TextSize.large)
                        Text("Extra Large").tag(AccessibilitySettings.TextSize.extraLarge)
                    }

                    Toggle("Motion Sickness Mode", isOn: $settings.accessibilitySettings.motionSicknessMode)

                    SliderSetting(
                        title: "Visual Effects Intensity",
                        value: $settings.accessibilitySettings.visualEffectsIntensity,
                        range: 0.0...1.0
                    )
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        appState.settings = settings
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Slider Setting Component

struct SliderSetting: View {
    let title: String
    @Binding var value: Float
    var range: ClosedRange<Float> = 0...1

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(title)
                    .font(.subheadline)

                Spacer()

                Text("\(Int(value * 100))%")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Slider(value: $value, in: range)
        }
    }
}

// MARK: - Preview

#Preview {
    SettingsView(settings: GameSettings())
        .environment(AppState())
}
