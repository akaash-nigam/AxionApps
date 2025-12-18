import SwiftUI

struct SettingsView: View {
    @Environment(AppState.self) private var appState
    @State private var selectedTab: SettingsTab = .general

    var body: some View {
        NavigationSplitView {
            List(SettingsTab.allCases, selection: $selectedTab) { tab in
                Label(tab.rawValue, systemImage: tab.icon)
                    .tag(tab)
            }
            .navigationTitle("Settings")
        } detail: {
            Group {
                switch selectedTab {
                case .general:
                    GeneralSettings(preferences: appState.preferences)
                case .display:
                    DisplaySettings(preferences: appState.preferences)
                case .advanced:
                    AdvancedSettings(preferences: appState.preferences)
                }
            }
            .navigationTitle(selectedTab.rawValue)
        }
    }
}

enum SettingsTab: String, CaseIterable, Identifiable {
    case general = "General"
    case display = "Display"
    case advanced = "Advanced"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .general: return "gearshape"
        case .display: return "display"
        case .advanced: return "slider.horizontal.3"
        }
    }
}

// MARK: - General Settings

struct GeneralSettings: View {
    @Bindable var preferences: UserPreferences

    var body: some View {
        Form {
            Section("Workspace") {
                Toggle("Auto-save", isOn: .constant(true))

                Picker("Auto-save interval", selection: .constant(5)) {
                    Text("1 minute").tag(1)
                    Text("5 minutes").tag(5)
                    Text("10 minutes").tag(10)
                }

                Picker("Undo steps", selection: .constant(50)) {
                    Text("25 steps").tag(25)
                    Text("50 steps").tag(50)
                    Text("100 steps").tag(100)
                }
            }

            Section("Appearance") {
                Picker("Theme", selection: .constant(UserPreferences.Theme.system)) {
                    Text("Light").tag(UserPreferences.Theme.light)
                    Text("Dark").tag(UserPreferences.Theme.dark)
                    Text("System").tag(UserPreferences.Theme.system)
                }
            }
        }
        .formStyle(.grouped)
    }
}

// MARK: - Display Settings

struct DisplaySettings: View {
    @Bindable var preferences: UserPreferences

    var body: some View {
        Form {
            Section("Grid") {
                Picker("Grid size", selection: .constant(0.5)) {
                    Text("25 cm").tag(0.25)
                    Text("50 cm").tag(0.50)
                    Text("1 m").tag(1.0)
                }

                Toggle("Snap to grid", isOn: $preferences.snapToGrid)
                Toggle("Show dimensions", isOn: $preferences.showDimensions)
            }

            Section("Rendering") {
                Picker("Quality", selection: $preferences.renderQuality) {
                    Text("Low").tag(UserPreferences.RenderQuality.low)
                    Text("Medium").tag(UserPreferences.RenderQuality.medium)
                    Text("High").tag(UserPreferences.RenderQuality.high)
                    Text("Ultra").tag(UserPreferences.RenderQuality.ultra)
                }
            }
        }
        .formStyle(.grouped)
    }
}

// MARK: - Advanced Settings

struct AdvancedSettings: View {
    var preferences: UserPreferences

    var body: some View {
        Form {
            Section("Performance") {
                Toggle("Enable GPU acceleration", isOn: .constant(true))
                Toggle("Use object pooling", isOn: .constant(true))
            }

            Section("Developer") {
                Toggle("Enable logging", isOn: .constant(Configuration.enableLogging))
                Toggle("Use mock data", isOn: .constant(Configuration.useMockData))
            }

            Section {
                Button("Reset to Defaults") {
                    // Reset preferences
                }
                .foregroundStyle(.red)
            }
        }
        .formStyle(.grouped)
    }
}
