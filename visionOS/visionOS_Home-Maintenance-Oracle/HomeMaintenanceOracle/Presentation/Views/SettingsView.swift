//
//  SettingsView.swift
//  HomeMaintenanceOracle
//
//  Created on 2025-11-24.
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

                Section("Data") {
                    Button("Export Data") {
                        // TODO: Implement
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
}
