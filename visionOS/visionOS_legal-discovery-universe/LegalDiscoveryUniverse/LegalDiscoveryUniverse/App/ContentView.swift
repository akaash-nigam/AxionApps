//
//  ContentView.swift
//  Legal Discovery Universe
//
//  Created on 2025-11-17.
//

import SwiftUI
import RealityKit

struct ContentView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        @Bindable var appState = appState

        TabView {
            CaseDashboardView()
                .tabItem {
                    Label("Cases", systemImage: "folder.fill")
                }

            Text("Search")
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }

            Text("Analytics")
                .tabItem {
                    Label("Analytics", systemImage: "chart.bar.fill")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
    }
}

// MARK: - Settings View

struct SettingsView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        Form {
            Section("General") {
                Toggle("Enable AI Analysis", isOn: .constant(true))
                Toggle("Auto 3D Visualization", isOn: .constant(false))
                Toggle("Show Tutorial", isOn: .constant(true))
            }

            Section("Display") {
                Picker("Theme", selection: .constant(Theme.auto)) {
                    Text("Light").tag(Theme.light)
                    Text("Dark").tag(Theme.dark)
                    Text("Auto").tag(Theme.auto)
                }
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

#Preview {
    ContentView()
        .environment(AppState())
}
