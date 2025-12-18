import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var audioEngine: SpatialAudioEngine

    @State private var masterVolume: Float = 0.75
    @State private var enableHaptics: Bool = true
    @State private var enableAIAssistance: Bool = true
    @State private var audioQuality: AudioQuality = .high

    var body: some View {
        NavigationStack {
            Form {
                Section("Audio") {
                    VStack(alignment: .leading) {
                        Text("Master Volume")
                        Slider(value: $masterVolume, in: 0...1)
                        Text("\(Int(masterVolume * 100))%")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Picker("Audio Quality", selection: $audioQuality) {
                        Text("Standard").tag(AudioQuality.standard)
                        Text("High").tag(AudioQuality.high)
                        Text("Professional").tag(AudioQuality.professional)
                    }
                }

                Section("Interaction") {
                    Toggle("Enable Haptic Feedback", isOn: $enableHaptics)
                    Toggle("AI Assistance", isOn: $enableAIAssistance)
                }

                Section("Display") {
                    Picker("Immersion Style", selection: $appCoordinator.immersionPreference) {
                        ForEach(ImmersionPreference.allCases, id: \.self) { preference in
                            Text(preference.rawValue).tag(preference)
                        }
                    }
                }

                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(AppConfiguration.version)
                            .foregroundStyle(.secondary)
                    }

                    HStack {
                        Text("Build")
                        Spacer()
                        Text(AppConfiguration.buildNumber)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
        }
        .frame(width: 600, height: 400)
    }
}

enum AudioQuality: String, CaseIterable {
    case standard = "Standard"
    case high = "High"
    case professional = "Professional"
}

#Preview {
    SettingsView()
        .environmentObject(AppCoordinator())
        .environmentObject(SpatialAudioEngine.shared)
}
