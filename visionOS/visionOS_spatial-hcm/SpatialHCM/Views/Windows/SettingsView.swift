import SwiftUI

struct SettingsView: View {
    @Environment(AppState.self) private var appState
    @State private var selectedSection: SettingsSection? = .general

    var body: some View {
        NavigationSplitView {
            List(selection: $selectedSection) {
                Section("Preferences") {
                    NavigationLink(value: SettingsSection.general) {
                        Label("General", systemImage: "gearshape")
                    }

                    NavigationLink(value: SettingsSection.appearance) {
                        Label("Appearance", systemImage: "paintbrush")
                    }

                    NavigationLink(value: SettingsSection.privacy) {
                        Label("Privacy", systemImage: "hand.raised")
                    }
                }

                Section("Advanced") {
                    NavigationLink(value: SettingsSection.integrations) {
                        Label("Integrations", systemImage: "link")
                    }

                    NavigationLink(value: SettingsSection.about) {
                        Label("About", systemImage: "info.circle")
                    }
                }
            }
            .navigationTitle("Settings")
        } detail: {
            if let section = selectedSection {
                SettingsDetailView(section: section)
            } else {
                Text("Select a setting")
                    .foregroundStyle(.secondary)
            }
        }
    }
}

enum SettingsSection {
    case general
    case appearance
    case privacy
    case integrations
    case about
}

struct SettingsDetailView: View {
    let section: SettingsSection

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                switch section {
                case .general:
                    GeneralSettingsView()
                case .appearance:
                    AppearanceSettingsView()
                case .privacy:
                    PrivacySettingsView()
                case .integrations:
                    IntegrationsSettingsView()
                case .about:
                    AboutSettingsView()
                }
            }
            .padding()
        }
    }
}

// MARK: - General Settings
struct GeneralSettingsView: View {
    @State private var enableNotifications = true
    @State private var enableSounds = true

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("General")
                .font(.largeTitle)
                .fontWeight(.bold)

            Toggle("Enable Notifications", isOn: $enableNotifications)
            Toggle("Enable Sounds", isOn: $enableSounds)
        }
    }
}

// MARK: - Appearance Settings
struct AppearanceSettingsView: View {
    @State private var colorScheme: AppColorScheme = .system

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Appearance")
                .font(.largeTitle)
                .fontWeight(.bold)

            Picker("Color Scheme", selection: $colorScheme) {
                Text("System").tag(AppColorScheme.system)
                Text("Light").tag(AppColorScheme.light)
                Text("Dark").tag(AppColorScheme.dark)
            }
            .pickerStyle(.segmented)
        }
    }
}

enum AppColorScheme {
    case system, light, dark
}

// MARK: - Privacy Settings
struct PrivacySettingsView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Privacy")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Your data is encrypted and secure.")
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Integrations Settings
struct IntegrationsSettingsView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Integrations")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Connect with other HR systems")
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - About Settings
struct AboutSettingsView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("About")
                .font(.largeTitle)
                .fontWeight(.bold)

            VStack(alignment: .leading, spacing: 8) {
                Text("Spatial HCM")
                    .font(.headline)

                Text("Version 1.0.0")
                    .foregroundStyle(.secondary)

                Text("© 2024 Spatial HCM Inc.")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
    }
}

#Preview {
    SettingsView()
        .environment(AppState())
}
