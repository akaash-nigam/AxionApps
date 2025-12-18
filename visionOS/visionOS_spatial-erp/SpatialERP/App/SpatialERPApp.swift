import SwiftUI
import SwiftData
import RealityKit

@main
struct SpatialERPApp: App {
    @State private var appState = AppState()
    @State private var immersionStyle: ImmersionStyle = .mixed

    // SwiftData container
    private var modelContainer: ModelContainer = {
        let schema = Schema([
            GeneralLedgerEntry.self,
            CostCenter.self,
            Budget.self,
            ProductionOrder.self,
            WorkCenter.self,
            Equipment.self,
            Inventory.self,
            Supplier.self,
            PurchaseOrder.self,
            Employee.self,
            Department.self,
            Location.self
        ])

        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            allowsSave: true,
            groupContainer: .identifier("group.com.enterprise.spatial-erp"),
            cloudKitDatabase: .none
        )

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        // Primary Window: Dashboard & Control Panel
        WindowGroup(id: "dashboard") {
            DashboardWindow()
                .environment(appState)
        }
        .windowStyle(.automatic)
        .defaultSize(width: 1400, height: 900)
        .modelContainer(modelContainer)

        // Secondary Window: Financial Analysis
        WindowGroup(id: "financial") {
            FinancialWindow()
                .environment(appState)
        }
        .windowStyle(.automatic)
        .defaultSize(width: 1200, height: 800)
        .modelContainer(modelContainer)

        // 3D Volume: Operations Factory Floor
        WindowGroup(id: "operations-volume") {
            OperationsVolumeView()
                .environment(appState)
        }
        .windowStyle(.volumetric)
        .defaultSize(width: 1.5, height: 1.2, depth: 1.5, in: .meters)
        .modelContainer(modelContainer)

        // 3D Volume: Supply Chain Galaxy
        WindowGroup(id: "supply-chain-volume") {
            SupplyChainVolumeView()
                .environment(appState)
        }
        .windowStyle(.volumetric)
        .defaultSize(width: 2.0, height: 1.5, depth: 2.0, in: .meters)
        .modelContainer(modelContainer)

        // Full Immersive Space: Operations Command Center
        ImmersiveSpace(id: "operations-center") {
            OperationsCenterSpace()
                .environment(appState)
        }
        .immersionStyle(selection: $immersionStyle, in: .mixed, .full)
        .upperLimbVisibility(.visible)

        // Full Immersive Space: Financial Universe
        ImmersiveSpace(id: "financial-universe") {
            FinancialUniverseSpace()
                .environment(appState)
        }
        .immersionStyle(selection: $immersionStyle, in: .mixed, .full)
        .upperLimbVisibility(.visible)

        // Collaboration Space
        ImmersiveSpace(id: "collaboration") {
            CollaborationSpace()
                .environment(appState)
        }
        .immersionStyle(selection: .constant(.mixed), in: .mixed)
    }
}
