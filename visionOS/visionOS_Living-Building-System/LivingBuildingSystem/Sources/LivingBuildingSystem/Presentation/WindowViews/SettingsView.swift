import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Query private var homes: [Home]

    var body: some View {
        NavigationStack {
            Form {
                // Home Section
                Section("Home") {
                    if let currentHome = appState.currentHome {
                        HStack {
                            Text("Name")
                            Spacer()
                            Text(currentHome.name)
                                .foregroundStyle(.secondary)
                        }

                        if let address = currentHome.address {
                            HStack {
                                Text("Address")
                                Spacer()
                                Text(address)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    } else {
                        Button("Set Up Home") {
                            createDefaultHome()
                        }
                    }
                }

                // Devices Section
                Section("Devices") {
                    HStack {
                        Text("Total Devices")
                        Spacer()
                        Text("\(appState.devices.count)")
                            .foregroundStyle(.secondary)
                    }

                    HStack {
                        Text("Active")
                        Spacer()
                        Text("\(appState.activeDeviceCount)")
                            .foregroundStyle(.secondary)
                    }

                    HStack {
                        Text("Reachable")
                        Spacer()
                        Text("\(appState.reachableDeviceCount)")
                            .foregroundStyle(.secondary)
                    }
                }

                // About Section
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }

                    HStack {
                        Text("Build")
                        Spacer()
                        Text("1")
                            .foregroundStyle(.secondary)
                    }
                }

                // Debug Section (only in debug builds)
                #if DEBUG
                Section("Debug") {
                    Button("Load Sample Data") {
                        loadSampleData()
                    }

                    Button("Clear All Data", role: .destructive) {
                        clearAllData()
                    }
                }
                #endif
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func createDefaultHome() {
        let home = Home(name: "My Home")
        modelContext.insert(home)
        appState.currentHome = home

        do {
            try modelContext.save()
        } catch {
            Logger.shared.log("Failed to save home", level: .error, error: error)
        }
    }

    private func loadSampleData() {
        // Create sample home
        let home = Home.preview
        modelContext.insert(home)
        appState.currentHome = home

        // Create sample devices
        for device in SmartDevice.previewList {
            appState.addDevice(device)
        }

        do {
            try modelContext.save()
        } catch {
            Logger.shared.log("Failed to load sample data", level: .error, error: error)
        }
    }

    private func clearAllData() {
        // Clear app state
        appState.devices.removeAll()
        appState.currentHome = nil
        appState.currentRoom = nil

        // Clear SwiftData
        do {
            try modelContext.delete(model: Home.self)
            try modelContext.delete(model: Room.self)
            try modelContext.delete(model: SmartDevice.self)
            try modelContext.delete(model: DeviceState.self)
            try modelContext.delete(model: User.self)
            try modelContext.delete(model: UserPreferences.self)
            try modelContext.save()
        } catch {
            Logger.shared.log("Failed to clear data", level: .error, error: error)
        }
    }
}

// MARK: - Preview

#Preview {
    SettingsView()
        .environment(AppState.preview)
        .modelContainer(for: [Home.self, Room.self, SmartDevice.self])
}
