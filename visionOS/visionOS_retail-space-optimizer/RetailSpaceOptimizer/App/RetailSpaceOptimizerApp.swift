import SwiftUI
import SwiftData

@main
struct RetailSpaceOptimizerApp: App {
    @State private var appModel = AppModel()
    @State private var immersionStyle: ImmersionStyle = .mixed

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Store.self,
            Fixture.self,
            Product.self,
            StoreAnalytics.self,
            OptimizationSuggestion.self
        ])

        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            allowsSave: true
        )

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        // Primary window for controls and dashboards
        WindowGroup("Retail Optimizer", id: "main") {
            ContentView()
                .environment(appModel)
        }
        .windowStyle(.plain)
        .defaultSize(width: 1200, height: 800)
        .modelContainer(sharedModelContainer)

        // 3D store visualization volume
        WindowGroup("Store View", id: "store-volume", for: Store.ID.self) { $storeID in
            if let storeID = storeID {
                StoreVolumeView(storeID: storeID)
                    .environment(appModel)
            } else {
                Text("No store selected")
            }
        }
        .windowStyle(.volumetric)
        .defaultSize(width: 2, height: 1.5, depth: 2, in: .meters)
        .modelContainer(sharedModelContainer)

        // Analytics detail window
        WindowGroup("Analytics", id: "analytics", for: Store.ID.self) { $storeID in
            if let storeID = storeID {
                AnalyticsView(storeID: storeID)
                    .environment(appModel)
            } else {
                Text("No store selected")
            }
        }
        .windowStyle(.plain)
        .defaultSize(width: 900, height: 700)
        .modelContainer(sharedModelContainer)

        // Immersive store walkthrough
        ImmersiveSpace(id: "store-immersive") {
            StoreImmersiveView()
                .environment(appModel)
        }
        .immersionStyle(selection: $immersionStyle, in: .mixed, .progressive, .full)
    }
}
