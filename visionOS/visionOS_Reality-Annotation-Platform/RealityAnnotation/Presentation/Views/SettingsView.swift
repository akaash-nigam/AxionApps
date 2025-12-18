//
//  SettingsView.swift
//  Reality Annotation Platform
//
//  Settings and preferences view
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var appState: AppState
    @State private var showingAbout = false

    @ViewBuilder
    private var syncStatusView: some View {
        switch appState.syncStatus {
        case .idle:
            HStack(spacing: 6) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                Text("Ready")
                    .foregroundStyle(.secondary)
            }
        case .syncing:
            HStack(spacing: 6) {
                ProgressView()
                    .scaleEffect(0.7)
                Text("Syncing...")
                    .foregroundStyle(.secondary)
            }
        case .error(let message):
            HStack(spacing: 6) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(.orange)
                Text("Error")
                    .foregroundStyle(.secondary)
            }
        case .offline:
            HStack(spacing: 6) {
                Image(systemName: "wifi.slash")
                    .foregroundStyle(.gray)
                Text("Offline")
                    .foregroundStyle(.secondary)
            }
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                // Account Section
                Section("Account") {
                    if appState.isAuthenticated {
                        HStack {
                            Image(systemName: "person.circle.fill")
                                .font(.title)
                                .foregroundStyle(.blue)

                            VStack(alignment: .leading) {
                                Text(appState.currentUser?.displayName ?? "User")
                                    .font(.headline)
                                Text("Free Plan")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    } else {
                        Button("Sign In with Apple") {
                            // TODO: Implement Sign in with Apple
                        }
                    }
                }

                // Sync Section
                Section("CloudKit Sync") {
                    // Sync Status
                    HStack {
                        Text("Status")
                        Spacer()
                        syncStatusView
                    }

                    // Last Sync Time
                    if let lastSync = appState.lastSyncTime {
                        HStack {
                            Text("Last Sync")
                            Spacer()
                            Text(lastSync, style: .relative)
                                .foregroundStyle(.secondary)
                        }
                    }

                    // Manual Sync Button
                    Button {
                        Task {
                            await appState.syncNow()
                        }
                    } label: {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                            Text("Sync Now")
                        }
                    }
                    .disabled(appState.isSyncing)

                    // Auto Sync Toggle
                    Toggle("Automatic Sync", isOn: Binding(
                        get: { appState.syncStatus != .offline },
                        set: { enabled in
                            Task {
                                if enabled {
                                    await appState.startSync()
                                } else {
                                    appState.stopSync()
                                }
                            }
                        }
                    ))
                } footer: {
                    Text("Annotations sync automatically with iCloud when online. You can also manually trigger a sync.")
                }

                // Display Section
                Section("Display") {
                    Toggle("Show Annotations on Startup", isOn: .constant(true))
                    Stepper("Display Distance: 10m", value: .constant(10), in: 5...50, step: 5)
                }

                // About Section
                Section("About") {
                    Button("About Reality Annotations") {
                        showingAbout = true
                    }

                    Link("Privacy Policy", destination: URL(string: "https://example.com/privacy")!)
                    Link("Terms of Service", destination: URL(string: "https://example.com/terms")!)

                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0 (MVP)")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showingAbout) {
                AboutView()
            }
        }
    }
}

// MARK: - About View

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Image(systemName: "visionpro")
                    .font(.system(size: 80))
                    .foregroundStyle(.blue)

                Text("Reality Annotation Platform")
                    .font(.title)
                    .bold()

                Text("Leave notes in physical space")
                    .font(.headline)
                    .foregroundStyle(.secondary)

                VStack(alignment: .leading, spacing: 12) {
                    Text("Version 1.0.0 (MVP)")
                    Text("Built with SwiftUI, RealityKit, and CloudKit")
                    Text("© 2024 Reality Annotations")
                }
                .font(.caption)
                .foregroundStyle(.secondary)

                Spacer()
            }
            .padding()
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.inline)
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

// MARK: - Preview

#Preview {
    SettingsView()
        .environmentObject(AppState.shared)
}
