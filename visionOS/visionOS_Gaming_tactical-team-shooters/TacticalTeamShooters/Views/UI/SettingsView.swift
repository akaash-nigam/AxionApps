import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("sensitivity") private var sensitivity: Double = 1.0
    @AppStorage("aimAssist") private var aimAssist: Bool = false
    @AppStorage("graphicsQuality") private var graphicsQuality: GraphicsQuality = .high
    @AppStorage("audioVolume") private var audioVolume: Double = 0.7
    @AppStorage("dominantHand") private var dominantHand: Hand = .right
    @AppStorage("spatialAudio") private var spatialAudio: Bool = true
    @AppStorage("voiceChat") private var voiceChat: Bool = true
    @AppStorage("colorBlindMode") private var colorBlindMode: Bool = false
    @AppStorage("reduceMotion") private var reduceMotion: Bool = false

    var body: some View {
        NavigationStack {
            Form {
                // Controls Section
                Section("Controls") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Sensitivity")
                            .font(.headline)
                        Slider(value: $sensitivity, in: 0.1...3.0)
                        Text("\(sensitivity, specifier: "%.2f")")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Toggle("Aim Assist", isOn: $aimAssist)

                    Picker("Dominant Hand", selection: $dominantHand) {
                        Text("Right").tag(Hand.right)
                        Text("Left").tag(Hand.left)
                    }
                }

                // Graphics Section
                Section("Graphics") {
                    Picker("Quality", selection: $graphicsQuality) {
                        ForEach(GraphicsQuality.allCases, id: \.self) { quality in
                            Text(quality.rawValue.capitalized).tag(quality)
                        }
                    }

                    Toggle("Anti-Aliasing", isOn: .constant(true))
                        .disabled(true)

                    Toggle("Dynamic Shadows", isOn: .constant(true))
                        .disabled(true)
                }

                // Audio Section
                Section("Audio") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Master Volume")
                            .font(.headline)
                        Slider(value: $audioVolume, in: 0...1)
                        Text("\(Int(audioVolume * 100))%")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Toggle("Spatial Audio", isOn: $spatialAudio)
                    Toggle("Voice Chat", isOn: $voiceChat)
                }

                // Accessibility Section
                Section("Accessibility") {
                    Toggle("Color Blind Mode", isOn: $colorBlindMode)
                    Toggle("Reduce Motion", isOn: $reduceMotion)
                    Toggle("High Contrast", isOn: .constant(false))
                        .disabled(true)
                }

                // About Section
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

// MARK: - Enums

enum GraphicsQuality: String, Codable, CaseIterable {
    case low
    case medium
    case high
    case ultra
}

enum Hand: String, Codable {
    case left
    case right
}
