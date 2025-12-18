import SwiftUI
import SwiftData

@main
struct LivingBuildingSystemApp: App {
    // State management
    @State private var appState = AppState()

    // Immersive space state
    @State private var immersionStyle: ImmersionStyle = .mixed

    // SwiftData model container
    let modelContainer: ModelContainer

    init() {
        // Initialize SwiftData container
        do {
            modelContainer = try ModelContainer(
                for: Home.self,
                     Room.self,
                     RoomAnchor.self,
                     SmartDevice.self,
                     DeviceState.self,
                     User.self,
                     UserPreferences.self,
                     EnergyConfiguration.self,
                     EnergyReading.self,
                     EnergyAnomaly.self
            )
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        // Main dashboard window
        WindowGroup(id: "dashboard") {
            DashboardView()
                .environment(appState)
                .modelContainer(modelContainer)
        }
        .windowStyle(.plain)
        .defaultSize(width: 600, height: 800)

        // Device detail window
        WindowGroup(id: "device-detail", for: UUID.self) { $deviceID in
            if let deviceID = deviceID,
               let device = appState.devices[deviceID] {
                DeviceDetailView(device: device)
                    .environment(appState)
            } else {
                ContentUnavailableView(
                    "Device Not Found",
                    systemImage: "exclamationmark.triangle",
                    description: Text("The selected device could not be found.")
                )
            }
        }
        .windowStyle(.plain)
        .defaultSize(width: 400, height: 500)

        // Settings window
        WindowGroup(id: "settings") {
            SettingsView()
                .environment(appState)
                .modelContainer(modelContainer)
        }
        .windowStyle(.plain)
        .defaultSize(width: 500, height: 700)

        // Energy dashboard window
        WindowGroup(id: "energy") {
            EnergyDashboardView()
                .environment(appState)
                .modelContainer(modelContainer)
        }
        .windowStyle(.plain)
        .defaultSize(width: 700, height: 900)

        // MARK: - Immersive Spaces

        // Main home immersive view
        ImmersiveSpace(id: "home-view") {
            HomeImmersiveView()
                .environment(appState)
        }
        .immersionStyle(selection: $immersionStyle, in: .mixed, .progressive, .full)

        // Room scanning view
        ImmersiveSpace(id: "room-scan") {
            RoomScanView()
                .environment(appState)
        }
        .immersionStyle(selection: .constant(.full), in: .full)
    }
}
