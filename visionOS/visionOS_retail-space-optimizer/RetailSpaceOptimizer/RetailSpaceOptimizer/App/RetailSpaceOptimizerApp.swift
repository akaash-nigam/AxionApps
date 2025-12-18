import SwiftUI
import SwiftData

@main
struct RetailSpaceOptimizerApp: App {
    @State private var appState = AppState()
    @Environment(\.openWindow) var openWindow
    @Environment(\.dismissWindow) var dismissWindow
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Store.self,
            StoreLayout.self,
            Fixture.self,
            Product.self,
            StoreZone.self,
            PerformanceMetric.self,
            CustomerJourney.self,
            ABTest.self
        ])

        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .automatic
        )

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        // Main control window (always visible)
        WindowGroup(id: "main") {
            MainControlView()
                .environment(appState)
        }
        .windowStyle(.plain)
        .defaultSize(width: 800, height: 600)
        .modelContainer(sharedModelContainer)

        // Store editor window
        WindowGroup(id: "editor", for: UUID.self) { $storeId in
            if let storeId = storeId {
                StoreEditorView(storeId: storeId)
                    .environment(appState)
            }
        }
        .windowStyle(.plain)
        .defaultSize(width: 1000, height: 800)
        .modelContainer(sharedModelContainer)

        // Analytics dashboard
        WindowGroup(id: "analytics", for: UUID.self) { $storeId in
            if let storeId = storeId {
                AnalyticsDashboardView(storeId: storeId)
                    .environment(appState)
            }
        }
        .windowStyle(.plain)
        .defaultSize(width: 900, height: 700)
        .modelContainer(sharedModelContainer)

        // 3D Store preview volume
        WindowGroup(id: "storePreview", for: UUID.self) { $storeId in
            if let storeId = storeId {
                StorePreviewVolume(storeId: storeId)
                    .environment(appState)
            }
        }
        .windowStyle(.volumetric)
        .defaultSize(width: 1.5, height: 1.2, depth: 1.0, in: .meters)
        .modelContainer(sharedModelContainer)

        // Settings window
        WindowGroup(id: "settings") {
            SettingsView()
                .environment(appState)
        }
        .windowStyle(.plain)
        .defaultSize(width: 600, height: 500)
        .modelContainer(sharedModelContainer)

        // Immersive store walkthrough
        ImmersiveSpace(id: "storeWalkthrough", for: UUID.self) { $storeId in
            if let storeId = storeId {
                ImmersiveStoreView(storeId: storeId)
                    .environment(appState)
            }
        }
        .immersionStyle(selection: .constant(.progressive), in: .progressive)
    }
}
