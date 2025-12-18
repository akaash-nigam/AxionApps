//
//  SettingsView.swift
//  AIAgentCoordinator
//
//  Created by AI Agent Coordinator on 2025-01-20.
//

import SwiftUI
import SwiftData

/// Settings and preferences view
struct SettingsView: View {
    @Query private var workspaces: [UserWorkspace]
    @Environment(\.modelContext) private var modelContext

    @AppStorage("refreshInterval") private var refreshInterval = 5.0
    @AppStorage("maxAgentsDisplayed") private var maxAgentsDisplayed = 10_000
    @AppStorage("enableRealTimeMonitoring") private var enableRealTimeMonitoring = true
    @AppStorage("saveSpatialLayout") private var saveSpatialLayout = true
    @AppStorage("autoArrangeAgents") private var autoArrangeAgents = true
    @AppStorage("enableSpatialAudio") private var enableSpatialAudio = false
    @AppStorage("visualQuality") private var visualQuality = "medium"
    @AppStorage("enableLOD") private var enableLOD = true
    @AppStorage("showLabels") private var showLabels = true
    @AppStorage("showConnections") private var showConnections = true
    @AppStorage("particleEffects") private var particleEffects = true
    @AppStorage("enableCollaboration") private var enableCollaboration = true
    @AppStorage("enableNotifications") private var enableNotifications = true

    @State private var selectedTab: SettingsTab = .general

    enum SettingsTab: String, CaseIterable {
        case general = "General"
        case visualization = "Visualization"
        case performance = "Performance"
        case integrations = "Integrations"
        case privacy = "Privacy & Security"
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            generalSettings
                .tabItem {
                    Label("General", systemImage: "gearshape")
                }
                .tag(SettingsTab.general)

            visualizationSettings
                .tabItem {
                    Label("Visualization", systemImage: "cube")
                }
                .tag(SettingsTab.visualization)

            performanceSettings
                .tabItem {
                    Label("Performance", systemImage: "speedometer")
                }
                .tag(SettingsTab.performance)

            integrationsSettings
                .tabItem {
                    Label("Integrations", systemImage: "link")
                }
                .tag(SettingsTab.integrations)

            privacySettings
                .tabItem {
                    Label("Privacy", systemImage: "lock.shield")
                }
                .tag(SettingsTab.privacy)
        }
        .frame(width: 600, height: 500)
        .navigationTitle("Settings")
    }

    // MARK: - General Settings

    @ViewBuilder
    private var generalSettings: some View {
        Form {
            Section("Workspace") {
                Toggle("Save spatial layout", isOn: $saveSpatialLayout)
                    .help("Remember window and agent positions between sessions")

                Toggle("Auto-arrange new agents", isOn: $autoArrangeAgents)
                    .help("Automatically position new agents in the visualization")

                Toggle("Enable spatial audio cues", isOn: $enableSpatialAudio)
                    .help("Play audio cues for agent events")
            }

            Section("Updates") {
                HStack {
                    Text("Refresh interval:")
                    Slider(value: $refreshInterval, in: 1...60, step: 1)
                    Text("\(Int(refreshInterval))s")
                        .frame(width: 40)
                        .monospacedDigit()
                }

                Toggle("Real-time monitoring", isOn: $enableRealTimeMonitoring)
                    .help("Continuously update agent metrics")
            }

            Section("Collaboration") {
                Toggle("Enable SharePlay", isOn: $enableCollaboration)
                    .help("Allow multi-user collaboration sessions")
            }

            Section("Notifications") {
                Toggle("Enable notifications", isOn: $enableNotifications)
                    .help("Show system notifications for important events")
            }
        }
        .formStyle(.grouped)
        .scrollContentBackground(.hidden)
    }

    // MARK: - Visualization Settings

    @ViewBuilder
    private var visualizationSettings: some View {
        Form {
            Section("Display") {
                Picker("Visual quality", selection: $visualQuality) {
                    Text("Low").tag("low")
                    Text("Medium").tag("medium")
                    Text("High").tag("high")
                    Text("Ultra").tag("ultra")
                }

                Toggle("Enable Level of Detail (LOD)", isOn: $enableLOD)
                    .help("Reduce detail for distant objects to improve performance")

                Toggle("Show agent labels", isOn: $showLabels)
                    .help("Display names and info for agents")

                Toggle("Show connections", isOn: $showConnections)
                    .help("Visualize data flow between agents")
            }

            Section("Effects") {
                Toggle("Particle effects", isOn: $particleEffects)
                    .help("Show animated particles for data flow")
            }

            Section("3D Scene") {
                HStack {
                    Text("Max agents displayed:")
                    Slider(value: .init(
                        get: { Double(maxAgentsDisplayed) },
                        set: { maxAgentsDisplayed = Int($0) }
                    ), in: 1000...50000, step: 1000)
                    Text("\(maxAgentsDisplayed)")
                        .frame(width: 60)
                        .monospacedDigit()
                }
            }
        }
        .formStyle(.grouped)
        .scrollContentBackground(.hidden)
    }

    // MARK: - Performance Settings

    @ViewBuilder
    private var performanceSettings: some View {
        Form {
            Section("Optimization") {
                Toggle("Enable aggressive LOD", isOn: $enableLOD)

                Text("These settings affect rendering performance and frame rate")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section("Resource Usage") {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Memory Usage")
                            .font(.caption)
                        Text("~2.4 GB")
                            .font(.title3.monospacedDigit())
                    }

                    Spacer()

                    VStack(alignment: .leading) {
                        Text("Frame Rate")
                            .font(.caption)
                        Text("60 fps")
                            .font(.title3.monospacedDigit())
                    }
                }
                .padding(.vertical, 8)
            }

            Section {
                Button("Clear Cache") {
                    clearCache()
                }

                Button("Reset Performance Settings") {
                    resetPerformanceSettings()
                }
            }
        }
        .formStyle(.grouped)
        .scrollContentBackground(.hidden)
    }

    // MARK: - Integrations Settings

    @ViewBuilder
    private var integrationsSettings: some View {
        Form {
            Section("AI Platforms") {
                integrationRow(name: "OpenAI", icon: "brain", isConnected: false)
                integrationRow(name: "Anthropic", icon: "sparkles", isConnected: false)
                integrationRow(name: "AWS SageMaker", icon: "cloud", isConnected: false)
                integrationRow(name: "Azure AI", icon: "cloud", isConnected: false)
                integrationRow(name: "Google Cloud", icon: "cloud", isConnected: false)
            }

            Section("Custom Endpoints") {
                Button {
                    // Add custom endpoint
                } label: {
                    Label("Add Custom Endpoint", systemImage: "plus.circle")
                }
            }
        }
        .formStyle(.grouped)
        .scrollContentBackground(.hidden)
    }

    // MARK: - Privacy Settings

    @ViewBuilder
    private var privacySettings: some View {
        Form {
            Section("Data Collection") {
                Text("AI Agent Coordinator does not collect or transmit any personal data.")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text("All agent data is stored locally on your device.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section("SharePlay") {
                Text("When using SharePlay, agent data is shared only with participants in your session.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section {
                Button("View Privacy Policy") {
                    // Open privacy policy
                }

                Button("View Terms of Service") {
                    // Open terms
                }
            }
        }
        .formStyle(.grouped)
        .scrollContentBackground(.hidden)
    }

    // MARK: - Helper Views

    @ViewBuilder
    private func integrationRow(name: String, icon: String, isConnected: Bool) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(.secondary)

            Text(name)

            Spacer()

            if isConnected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                Text("Connected")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                Button("Connect") {
                    // Connect to platform
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }
        }
    }

    // MARK: - Actions

    private func clearCache() {
        // Clear caches
    }

    private func resetPerformanceSettings() {
        visualQuality = "medium"
        enableLOD = true
        maxAgentsDisplayed = 10_000
    }
}

#Preview {
    SettingsView()
        .modelContainer(for: UserWorkspace.self, inMemory: true)
}
