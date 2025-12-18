//
//  SettingsView.swift
//  Legal Discovery Universe
//
//  Created by Claude Code
//  Copyright © 2024 Legal Discovery Universe. All rights reserved.
//

import SwiftUI

struct SettingsView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        NavigationSplitView {
            List {
                NavigationLink("General") {
                    GeneralSettingsView()
                }
                NavigationLink("Security") {
                    SecuritySettingsView()
                }
                NavigationLink("Display") {
                    DisplaySettingsView()
                }
                NavigationLink("Privacy") {
                    PrivacySettingsView()
                }
                NavigationLink("About") {
                    AboutView()
                }
            }
            .navigationTitle("Settings")
        } detail: {
            GeneralSettingsView()
        }
    }
}

struct GeneralSettingsView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        Form {
            Section("Account") {
                if let user = appState.currentUser {
                    LabeledContent("Email", value: user.email)
                    LabeledContent("Role", value: user.role.rawValue.capitalized)
                }
            }

            Section("Preferences") {
                Toggle("Auto-save document positions", isOn: .constant(true))
                Toggle("Enable AI suggestions", isOn: .constant(true))
                Toggle("Show confidence scores", isOn: .constant(true))
                Toggle("Offline mode", isOn: .constant(false))
            }
        }
        .navigationTitle("General")
    }
}

struct SecuritySettingsView: View {
    var body: some View {
        Form {
            Section("Encryption") {
                Picker("Encryption Level", selection: .constant(EncryptionLevel.maximum)) {
                    Text("Standard").tag(EncryptionLevel.standard)
                    Text("High").tag(EncryptionLevel.high)
                    Text("Maximum").tag(EncryptionLevel.maximum)
                }
            }

            Section("Authentication") {
                Toggle("Require biometric authentication", isOn: .constant(true))
                Button("Change Password") { }
            }
        }
        .navigationTitle("Security")
    }
}

struct DisplaySettingsView: View {
    var body: some View {
        Form {
            Section("Appearance") {
                Picker("Theme", selection: .constant(Theme.auto)) {
                    Text("Light").tag(Theme.light)
                    Text("Dark").tag(Theme.dark)
                    Text("Auto").tag(Theme.auto)
                }
            }
        }
        .navigationTitle("Display")
    }
}

struct PrivacySettingsView: View {
    var body: some View {
        Form {
            Section("Data Collection") {
                Toggle("Usage analytics", isOn: .constant(false))
                Toggle("Crash reporting", isOn: .constant(true))
            }
        }
        .navigationTitle("Privacy")
    }
}

struct AboutView: View {
    var body: some View {
        Form {
            Section {
                LabeledContent("Version", value: "1.0.0")
                LabeledContent("Build", value: "1")
            }

            Section {
                Link("Privacy Policy", destination: URL(string: "https://example.com/privacy")!)
                Link("Terms of Service", destination: URL(string: "https://example.com/terms")!)
            }
        }
        .navigationTitle("About")
    }
}
