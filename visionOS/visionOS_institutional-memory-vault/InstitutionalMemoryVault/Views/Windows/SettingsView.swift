//
//  SettingsView.swift
//  Institutional Memory Vault
//
//  Application settings and preferences
//

import SwiftUI

struct SettingsView: View {
    @State private var enableNotifications = true
    @State private var autoSync = true
    @State private var reduceMotion = false

    var body: some View {
        NavigationStack {
            Form {
                Section("General") {
                    Toggle("Enable Notifications", isOn: $enableNotifications)
                    Toggle("Automatic Sync", isOn: $autoSync)
                }

                Section("Accessibility") {
                    Toggle("Reduce Motion", isOn: $reduceMotion)
                }

                Section("About") {
                    LabeledContent("Version", value: "1.0.0")
                    LabeledContent("Build", value: "1")
                }
            }
            .formStyle(.grouped)
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
}
