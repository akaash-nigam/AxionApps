import SwiftUI

struct SettingsView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        NavigationStack {
            Form {
                userSection
                audioSection
                spatialSection
                accessibilitySection
                aboutSection
            }
            .navigationTitle("Settings")
        }
    }

    // MARK: - Sections

    private var userSection: some View {
        Section("User Profile") {
            if let user = appState.currentUser {
                LabeledContent("Name", value: user.displayName)
                LabeledContent("Email", value: user.email)
                LabeledContent("Status", value: appState.isAuthenticated ? "Online" : "Offline")
            }
        }
    }

    private var audioSection: some View {
        Section("Audio Settings") {
            if let user = appState.currentUser {
                Picker("Audio Quality", selection: .constant(user.preferences.audioQuality)) {
                    Text("Low").tag(AudioQuality.low)
                    Text("Medium").tag(AudioQuality.medium)
                    Text("High").tag(AudioQuality.high)
                    Text("Ultra High").tag(AudioQuality.ultrahigh)
                }

                Toggle("Spatial Audio", isOn: .constant(user.preferences.spatialAudioEnabled))
                Toggle("Auto Join Audio", isOn: .constant(user.preferences.autoJoinAudio))
            }
        }
    }

    private var spatialSection: some View {
        Section("Spatial Computing") {
            if let user = appState.currentUser {
                Toggle("Hand Tracking", isOn: .constant(user.preferences.handTrackingEnabled))
                Toggle("Eye Tracking", isOn: .constant(user.preferences.eyeTrackingEnabled))
                Toggle("Haptic Feedback", isOn: .constant(user.preferences.hapticFeedbackEnabled))
            }
        }
    }

    private var accessibilitySection: some View {
        Section("Accessibility") {
            NavigationLink("VoiceOver Settings") {
                Text("VoiceOver configuration")
            }

            NavigationLink("Display Settings") {
                Text("Display configuration")
            }

            NavigationLink("Motor Settings") {
                Text("Motor configuration")
            }
        }
    }

    private var aboutSection: some View {
        Section("About") {
            LabeledContent("Version", value: "1.0.0")
            LabeledContent("Build", value: "1")

            Link("Privacy Policy", destination: URL(string: "https://spatialmeeting.app/privacy")!)
            Link("Terms of Service", destination: URL(string: "https://spatialmeeting.app/terms")!)
        }
    }
}

#Preview {
    SettingsView()
        .environment(AppState())
}
