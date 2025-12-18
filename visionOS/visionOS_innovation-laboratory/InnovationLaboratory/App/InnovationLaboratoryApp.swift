import SwiftUI
import SwiftData

@main
struct InnovationLaboratoryApp: App {
    // MARK: - State
    @State private var appState = AppState()
    @State private var immersionLevel: ImmersionStyle = .progressive

    // MARK: - SwiftData Model Container
    let modelContainer: ModelContainer

    init() {
        do {
            let schema = Schema([
                InnovationIdea.self,
                Prototype.self,
                User.self,
                Team.self,
                IdeaAnalytics.self,
                Comment.self,
                Attachment.self
            ])

            let configuration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false,
                allowsSave: true
            )

            modelContainer = try ModelContainer(
                for: schema,
                configurations: configuration
            )
        } catch {
            fatalError("Failed to create model container: \\(error.localizedDescription)")
        }
    }

    // MARK: - Scene Configuration
    var body: some Scene {
        // Main Dashboard Window
        WindowGroup(id: "dashboard") {
            DashboardView()
                .environment(appState)
                .modelContainer(modelContainer)
        }
        .windowStyle(.plain)
        .defaultSize(width: 1200, height: 800)

        // Quick Idea Capture Window
        WindowGroup(id: "ideaCapture") {
            IdeaCaptureView()
                .environment(appState)
                .modelContainer(modelContainer)
        }
        .windowStyle(.plain)
        .defaultSize(width: 600, height: 700)

        // Settings/Control Panel Window
        WindowGroup(id: "controlPanel") {
            ControlPanelView()
                .environment(appState)
                .modelContainer(modelContainer)
        }
        .windowStyle(.plain)
        .defaultSize(width: 500, height: 600)

        // Prototype Studio Volume (3D Bounded Space)
        WindowGroup(id: "prototypeStudio") {
            PrototypeStudioView()
                .environment(appState)
                .modelContainer(modelContainer)
        }
        .windowStyle(.volumetric)
        .defaultSize(width: 1.0, height: 1.0, depth: 1.0, in: .meters)

        // Mind Map Volume
        WindowGroup(id: "mindMap") {
            MindMapView()
                .environment(appState)
                .modelContainer(modelContainer)
        }
        .windowStyle(.volumetric)
        .defaultSize(width: 1.5, height: 1.0, depth: 1.5, in: .meters)

        // Analytics Dashboard Volume
        WindowGroup(id: "analyticsVolume") {
            AnalyticsVolumeView()
                .environment(appState)
                .modelContainer(modelContainer)
        }
        .windowStyle(.volumetric)
        .defaultSize(width: 1.2, height: 0.8, depth: 0.6, in: .meters)

        // Innovation Universe Immersive Space
        ImmersiveSpace(id: "innovationUniverse") {
            InnovationUniverseView()
                .environment(appState)
                .modelContainer(modelContainer)
        }
        .immersionStyle(selection: $immersionLevel, in: .progressive)
    }
}

// MARK: - App State
@Observable
class AppState {
    var currentUser: User?
    var activeIdeas: [InnovationIdea] = []
    var selectedIdea: InnovationIdea?
    var activePrototype: Prototype?
    var collaborationSession: CollaborationSession?
    var isImmersed: Bool = false
    var currentView: NavigationDestination = .dashboard
    var showingIdeaCapture: Bool = false
    var showingPrototypeWorkshop: Bool = false
    var showingAnalytics: Bool = false
    var notifications: [AppNotification] = []

    enum NavigationDestination {
        case dashboard
        case ideas
        case prototypes
        case analytics
        case collaboration
        case settings
    }
}

// MARK: - App Notification
struct AppNotification: Identifiable {
    let id = UUID()
    let title: String
    let message: String
    let type: NotificationType
    let timestamp: Date

    enum NotificationType {
        case info
        case success
        case warning
        case error
    }
}
