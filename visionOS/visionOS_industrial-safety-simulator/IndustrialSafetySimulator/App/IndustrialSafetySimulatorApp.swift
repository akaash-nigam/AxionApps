import SwiftUI
import SwiftData

@main
struct IndustrialSafetySimulatorApp: App {
    // MARK: - State

    @State private var appState = AppState()
    @State private var immersionStyle: ImmersionStyle = .progressive

    // MARK: - SwiftData Configuration

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            SafetyUser.self,
            TrainingModule.self,
            SafetyScenario.self,
            Hazard.self,
            TrainingSession.self,
            ScenarioResult.self,
            PerformanceMetrics.self
        ])

        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .private("iCloud.com.company.IndustrialSafety")
        )

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    // MARK: - Body

    var body: some Scene {
        // Main Dashboard Window
        WindowGroup(id: "dashboard") {
            DashboardView()
                .environment(appState)
        }
        .modelContainer(sharedModelContainer)
        .windowStyle(.plain)
        .defaultSize(width: 1400, height: 900)

        // Analytics Window
        WindowGroup(id: "analytics") {
            AnalyticsView()
                .environment(appState)
        }
        .modelContainer(sharedModelContainer)
        .defaultSize(width: 1200, height: 800)

        // Settings Window
        WindowGroup(id: "settings") {
            SettingsView()
                .environment(appState)
        }
        .modelContainer(sharedModelContainer)
        .defaultSize(width: 800, height: 600)

        // Equipment Viewer Volume
        WindowGroup(id: "equipment-viewer") {
            EquipmentVolumeView()
                .environment(appState)
        }
        .modelContainer(sharedModelContainer)
        .windowStyle(.volumetric)
        .defaultSize(width: 1.0, height: 1.0, depth: 1.0, in: .meters)

        // Hazard Identification Volume
        WindowGroup(id: "hazard-trainer") {
            HazardVolumeView()
                .environment(appState)
        }
        .modelContainer(sharedModelContainer)
        .windowStyle(.volumetric)
        .defaultSize(width: 1.5, height: 1.5, depth: 1.5, in: .meters)

        // Immersive Training Environment
        ImmersiveSpace(id: "training-environment") {
            SafetyTrainingEnvironmentView()
                .environment(appState)
        }
        .immersionStyle(selection: $immersionStyle, in: .progressive)
    }
}
