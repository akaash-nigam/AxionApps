import SwiftUI
import SwiftData
import OSLog

/// Main app entry point for Executive Briefing visionOS app
@main
struct ExecutiveBriefingApp: App {
    @State private var appState = AppState()

    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "ExecutiveBriefing", category: "App")

    /// Shared model container for SwiftData
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            BriefingSection.self,
            ContentBlock.self,
            UseCase.self,
            Metric.self,
            DecisionPoint.self,
            DecisionOption.self,
            InvestmentPhase.self,
            ChecklistItem.self,
            ActionItem.self,
            UserProgress.self
        ])

        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            allowsSave: true
        )

        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            Logger(subsystem: Bundle.main.bundleIdentifier ?? "ExecutiveBriefing", category: "App")
                .info("✅ Model container initialized successfully")
            return container
        } catch {
            Logger(subsystem: Bundle.main.bundleIdentifier ?? "ExecutiveBriefing", category: "App")
                .error("❌ Failed to create ModelContainer: \(error.localizedDescription)")
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        // Main navigation window
        WindowGroup(id: "main") {
            ContentView()
                .environment(appState)
                .modelContainer(sharedModelContainer)
                .task {
                    await initializeApp()
                }
        }
        .windowStyle(.plain)
        .defaultSize(width: 1000, height: 800)
        .windowResizability(.contentSize)

        // Data visualization volumes
        WindowGroup(id: "roi-visualization", for: VisualizationType.self) { $vizType in
            if let type = vizType {
                DataVisualizationVolume(type: type)
                    .environment(appState)
                    .modelContainer(sharedModelContainer)
            }
        }
        .windowStyle(.volumetric)
        .defaultSize(width: 600, height: 600, depth: 600, in: .points)

        // Immersive environment (optional, for future)
        ImmersiveSpace(id: "immersive-briefing") {
            ImmersiveBriefingView()
                .environment(appState)
                .modelContainer(sharedModelContainer)
        }
        .immersionStyle(selection: .constant(.mixed), in: .mixed)
    }

    /// Initialize app on first launch
    @MainActor
    private func initializeApp() async {
        logger.info("Initializing app...")

        // Check if data needs to be seeded
        let context = ModelContext(sharedModelContainer)
        let descriptor = FetchDescriptor<BriefingSection>()

        do {
            let existingSections = try context.fetch(descriptor)

            if existingSections.isEmpty {
                logger.info("No existing data found, seeding database...")
                let seeder = DataSeeder()
                try await seeder.seedInitialData(modelContext: context)
                logger.info("✅ Database seeded successfully")
            } else {
                logger.info("Database already contains \(existingSections.count) sections")
            }
        } catch {
            logger.error("❌ Failed to initialize app: \(error.localizedDescription)")
        }
    }
}
