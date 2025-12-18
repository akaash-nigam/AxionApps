import SwiftUI
import SwiftData

@main
struct SustainabilityCommandApp: App {
    // MARK: - State

    @State private var appState = AppState()
    @State private var immersionLevel: ImmersionStyle = .progressive

    // MARK: - SwiftData Container

    let modelContainer: ModelContainer = {
        let schema = Schema([
            CarbonFootprintModel.self,
            FacilityModel.self,
            EmissionSourceModel.self,
            SustainabilityGoalModel.self,
            SupplyChainModel.self
        ])

        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )

        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }()

    // MARK: - Scene

    var body: some Scene {
        // MARK: Main Dashboard Window
        WindowGroup(id: "sustainability-dashboard") {
            SustainabilityDashboardView()
                .environment(appState)
        }
        .modelContainer(modelContainer)
        .defaultSize(width: 1400, height: 900)
        .windowResizability(.contentSize)

        // MARK: Goals Tracking Window
        WindowGroup(id: "goals-tracker") {
            GoalsTrackerView()
                .environment(appState)
        }
        .modelContainer(modelContainer)
        .defaultSize(width: 600, height: 800)
        .windowStyle(.plain)

        // MARK: Analytics Detail Window
        WindowGroup(id: "analytics-detail") {
            AnalyticsDetailView()
                .environment(appState)
        }
        .modelContainer(modelContainer)
        .defaultSize(width: 1000, height: 700)

        // MARK: Carbon Flow Volume (3D)
        WindowGroup(id: "carbon-flow-volume") {
            CarbonFlowVolumeView()
                .environment(appState)
        }
        .windowStyle(.volumetric)
        .defaultSize(width: 1.5, height: 1.2, depth: 1.0, in: .meters)

        // MARK: Energy Chart Volume (3D)
        WindowGroup(id: "energy-3d-chart") {
            EnergyConsumption3DView()
                .environment(appState)
        }
        .windowStyle(.volumetric)
        .defaultSize(width: 1.0, height: 1.0, depth: 1.0, in: .meters)

        // MARK: Supply Chain Volume (3D)
        WindowGroup(id: "supply-chain-volume") {
            SupplyChainNetworkView()
                .environment(appState)
        }
        .windowStyle(.volumetric)
        .defaultSize(width: 2.0, height: 1.5, depth: 1.5, in: .meters)

        // MARK: Immersive Earth Visualization
        ImmersiveSpace(id: "earth-immersive") {
            EarthImmersiveView()
                .environment(appState)
        }
        .immersionStyle(selection: $immersionLevel, in: .mixed, .progressive, .full)
    }
}
