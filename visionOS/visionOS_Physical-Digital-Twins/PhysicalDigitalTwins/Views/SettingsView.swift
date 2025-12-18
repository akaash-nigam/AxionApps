//
//  SettingsView.swift
//  PhysicalDigitalTwins
//
//  App settings and preferences
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            Form {
                Section("About") {
                    LabeledContent("Version", value: "1.0.0 (MVP)")
                    LabeledContent("Build", value: "1")
                }

                Section("Storage") {
                    Button("Export Inventory") {
                        // TODO: Implement export
                    }

                    Button("Clear All Data", role: .destructive) {
                        // TODO: Implement with confirmation
                    }
                }

                Section {
                    Link("Privacy Policy", destination: URL(string: "https://example.com/privacy")!)
                    Link("Terms of Service", destination: URL(string: "https://example.com/terms")!)
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
}
