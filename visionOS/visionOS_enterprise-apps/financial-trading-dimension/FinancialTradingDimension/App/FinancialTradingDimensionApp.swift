import SwiftUI
import SwiftData

@main
struct FinancialTradingDimensionApp: App {
    @State private var appModel = AppModel()

    var modelContainer: ModelContainer = {
        let schema = Schema([
            Portfolio.self,
            Position.self,
            Order.self,
            MarketData.self
        ])

        let config = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            allowsSave: true
        )

        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        // Primary trading windows
        WindowGroup(id: "market-overview") {
            MarketOverviewView()
                .environment(appModel)
        }
        .defaultSize(width: 1200, height: 800)

        WindowGroup(id: "portfolio") {
            PortfolioView()
                .environment(appModel)
        }
        .defaultSize(width: 1000, height: 900)

        WindowGroup(id: "trading-execution") {
            TradingExecutionView()
                .environment(appModel)
        }
        .defaultSize(width: 600, height: 800)

        WindowGroup(id: "alerts") {
            AlertsView()
                .environment(appModel)
        }
        .defaultSize(width: 400, height: 600)

        // 3D visualization volumes
        WindowGroup(id: "correlation-volume") {
            CorrelationVolumeView()
                .environment(appModel)
        }
        .windowStyle(.volumetric)
        .defaultSize(width: 1.0, height: 1.0, depth: 1.0, in: .meters)

        WindowGroup(id: "risk-volume") {
            RiskVolumeView()
                .environment(appModel)
        }
        .windowStyle(.volumetric)
        .defaultSize(width: 1.0, height: 1.0, depth: 0.8, in: .meters)

        WindowGroup(id: "technical-analysis-volume") {
            TechnicalAnalysisVolumeView()
                .environment(appModel)
        }
        .windowStyle(.volumetric)
        .defaultSize(width: 1.5, height: 1.0, depth: 0.8, in: .meters)

        // Immersive trading floor
        ImmersiveSpace(id: "trading-floor") {
            TradingFloorImmersiveView()
                .environment(appModel)
        }
        .immersionStyle(selection: .constant(.progressive), in: .progressive)

        // Collaboration space
        ImmersiveSpace(id: "collaboration-space") {
            CollaborationSpaceView()
                .environment(appModel)
        }
        .immersionStyle(selection: .constant(.mixed), in: .mixed)
    }
}
