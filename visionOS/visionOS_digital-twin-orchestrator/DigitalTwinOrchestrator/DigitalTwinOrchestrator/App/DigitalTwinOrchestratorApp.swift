import SwiftUI
import SwiftData
import Logging

@main
struct DigitalTwinOrchestratorApp: App {
    // State management (split into focused objects)
    @State private var sessionState = SessionState()
    @State private var navigationState = NavigationState()
    @State private var alertState = AlertState()

    @State private var immersionLevel: ImmersionStyle = .mixed

    // SwiftData model container
    let modelContainer: ModelContainer

    // Service container
    let services = ServiceContainer.shared

    // Logger
    private let logger = Logger(label: "com.twinspace.app")

    init() {
        // Configure SwiftData
        do {
            let schema = Schema([
                DigitalTwin.self,
                Sensor.self,
                Component.self,
                Prediction.self,
                SpatialAnnotation.self
            ])

            let configuration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false,
                allowsSave: true,
                cloudKitDatabase: .none  // Enterprise on-premise only
            )

            modelContainer = try ModelContainer(
                for: schema,
                configurations: configuration
            )

            logger.info("SwiftData ModelContainer initialized successfully")

            // Configure services
            configureServices()

        } catch {
            // Log the error and create an in-memory fallback
            logger.critical("Failed to create persistent ModelContainer: \(error.localizedDescription)")

            // Attempt in-memory fallback for graceful degradation
            do {
                let schema = Schema([
                    DigitalTwin.self,
                    Sensor.self,
                    Component.self,
                    Prediction.self,
                    SpatialAnnotation.self
                ])

                let fallbackConfig = ModelConfiguration(
                    schema: schema,
                    isStoredInMemoryOnly: true,
                    allowsSave: true
                )

                modelContainer = try ModelContainer(
                    for: schema,
                    configurations: fallbackConfig
                )

                logger.warning("Using in-memory storage as fallback")
            } catch {
                fatalError("Failed to create even in-memory ModelContainer: \(error)")
            }
        }
    }

    private func configureServices() {
        // Determine configuration based on build
        #if DEBUG
        let config = ServiceContainer.Configuration(
            baseURL: URL(string: "https://api.dev.twinspace.io")!,
            enableLogging: true,
            environment: .development
        )
        #else
        let config = ServiceContainer.Configuration(
            baseURL: URL(string: "https://api.twinspace.io")!,
            enableLogging: false,
            environment: .production
        )
        #endif

        services.configure(with: config)
    }

    var body: some Scene {
        // MARK: - Primary Dashboard Window
        WindowGroup(id: "main-dashboard") {
            DashboardView()
                .environment(sessionState)
                .environment(navigationState)
                .environment(alertState)
                .withServices(services)
                .onAppear {
                    configureDataServicesIfNeeded()
                }
        }
        .windowStyle(.plain)
        .defaultSize(width: 1400, height: 900)
        .modelContainer(modelContainer)

        // MARK: - Asset Browser Window
        WindowGroup(id: "asset-browser") {
            AssetBrowserView()
                .environment(sessionState)
                .environment(navigationState)
                .environment(alertState)
                .withServices(services)
        }
        .windowStyle(.plain)
        .defaultSize(width: 800, height: 600)
        .modelContainer(modelContainer)

        // MARK: - Analytics Window
        WindowGroup(id: "analytics") {
            AnalyticsView()
                .environment(sessionState)
                .environment(navigationState)
                .environment(alertState)
                .withServices(services)
        }
        .windowStyle(.automatic)
        .defaultSize(width: 1000, height: 700)
        .modelContainer(modelContainer)

        // MARK: - Digital Twin Volume (3D)
        WindowGroup(id: "twin-volume", for: UUID.self) { $twinId in
            if let twinId {
                DigitalTwinVolumeView(twinId: twinId)
                    .environment(sessionState)
                    .environment(navigationState)
                    .environment(alertState)
                    .withServices(services)
            } else {
                ContentUnavailableView(
                    "No Twin Selected",
                    systemImage: "gearshape.2",
                    description: Text("Select an asset to view its digital twin")
                )
            }
        }
        .windowStyle(.volumetric)
        .defaultSize(width: 1.5, height: 1.5, depth: 1.5, in: .meters)
        .modelContainer(modelContainer)

        // MARK: - Component Detail Volume
        WindowGroup(id: "component-detail", for: UUID.self) { $componentId in
            if let componentId {
                ComponentDetailView(componentId: componentId)
                    .environment(sessionState)
                    .environment(navigationState)
                    .environment(alertState)
                    .withServices(services)
            }
        }
        .windowStyle(.volumetric)
        .defaultSize(width: 0.8, height: 0.8, depth: 0.8, in: .meters)
        .modelContainer(modelContainer)

        // MARK: - Full Facility Immersive Space
        ImmersiveSpace(id: "facility-immersive") {
            FacilityImmersiveView()
                .environment(sessionState)
                .environment(navigationState)
                .environment(alertState)
                .withServices(services)
        }
        .immersionStyle(selection: $immersionLevel, in: .mixed, .progressive, .full)

        // MARK: - Simulation Space
        ImmersiveSpace(id: "simulation") {
            SimulationSpaceView()
                .environment(sessionState)
                .environment(navigationState)
                .environment(alertState)
                .withServices(services)
        }
        .immersionStyle(selection: .constant(.progressive), in: .progressive)
    }

    @MainActor
    private func configureDataServicesIfNeeded() {
        // Configure data services with model context on first window appearance
        if services.digitalTwinService == nil {
            services.configureDataServices(modelContext: modelContainer.mainContext)
        }
    }
}

// MARK: - Split State Objects

/// Session State - Manages user authentication and session data
@Observable
class SessionState {
    var currentUser: User?
    var isAuthenticated: Bool = false
    var authenticationError: Error?

    func signIn(user: User) {
        currentUser = user
        isAuthenticated = true
        authenticationError = nil
    }

    func signOut() {
        currentUser = nil
        isAuthenticated = false
    }
}

/// Navigation State - Manages window and space navigation
@Observable
class NavigationState {
    var activeWindow: WindowType = .dashboard
    var isImmersiveSpaceActive: Bool = false
    var showingSettings: Bool = false

    // Twin selection
    var selectedTwin: DigitalTwin?
    var selectedComponent: Component?

    // Collaboration
    var collaborativeSession: CollaborativeSession?
    var connectedUsers: [User] = []

    func selectTwin(_ twin: DigitalTwin?) {
        selectedTwin = twin
        selectedComponent = nil
    }

    func openWindow(_ type: WindowType) {
        activeWindow = type
    }
}

/// Alert State - Manages notifications and alerts
@Observable
class AlertState {
    var activeAlerts: [Alert] = []
    var unreadCount: Int = 0

    func addAlert(_ alert: Alert) {
        activeAlerts.insert(alert, at: 0)
        unreadCount += 1
    }

    func markAsRead(_ alert: Alert) {
        if unreadCount > 0 {
            unreadCount -= 1
        }
    }

    func dismissAlert(_ alert: Alert) {
        activeAlerts.removeAll { $0.id == alert.id }
    }

    func clearAll() {
        activeAlerts.removeAll()
        unreadCount = 0
    }
}

enum WindowType {
    case dashboard
    case assetBrowser
    case analytics
    case twinVolume
    case componentDetail
}

// MARK: - Legacy AppState (for backward compatibility during migration)
// TODO: Remove after all views are updated to use split state objects

@Observable
class AppState {
    var currentUser: User? {
        get { sessionState.currentUser }
        set { sessionState.currentUser = newValue }
    }
    var isAuthenticated: Bool {
        get { sessionState.isAuthenticated }
        set { sessionState.isAuthenticated = newValue }
    }
    var selectedTwin: DigitalTwin? {
        get { navigationState.selectedTwin }
        set { navigationState.selectedTwin = newValue }
    }
    var activeTwins: [DigitalTwin] = []
    var activeWindow: WindowType {
        get { navigationState.activeWindow }
        set { navigationState.activeWindow = newValue }
    }
    var isImmersiveSpaceActive: Bool {
        get { navigationState.isImmersiveSpaceActive }
        set { navigationState.isImmersiveSpaceActive = newValue }
    }
    var showingSettings: Bool {
        get { navigationState.showingSettings }
        set { navigationState.showingSettings = newValue }
    }
    var collaborativeSession: CollaborativeSession? {
        get { navigationState.collaborativeSession }
        set { navigationState.collaborativeSession = newValue }
    }
    var connectedUsers: [User] {
        get { navigationState.connectedUsers }
        set { navigationState.connectedUsers = newValue }
    }
    var activeAlerts: [Alert] {
        get { alertState.activeAlerts }
        set { alertState.activeAlerts = newValue }
    }
    var unreadCount: Int {
        get { alertState.unreadCount }
        set { alertState.unreadCount = newValue }
    }

    private let sessionState: SessionState
    private let navigationState: NavigationState
    private let alertState: AlertState

    init(
        sessionState: SessionState = SessionState(),
        navigationState: NavigationState = NavigationState(),
        alertState: AlertState = AlertState()
    ) {
        self.sessionState = sessionState
        self.navigationState = navigationState
        self.alertState = alertState
    }
}

// MARK: - User Model

struct User: Codable, Identifiable {
    let id: UUID
    var name: String
    var email: String
    var role: UserRole
    var avatarURL: URL?

    enum UserRole: String, Codable {
        case `operator`
        case engineer
        case manager
        case admin
    }
}

// MARK: - Collaborative Session

struct CollaborativeSession: Identifiable {
    let id: UUID
    var twinId: UUID
    var participants: [User]
    var startedAt: Date
    var isActive: Bool
}
