import SwiftUI
import SwiftData

@main
struct SpatialHCMApp: App {
    // MARK: - State
    @State private var appState = AppState()
    @State private var showImmersiveSpace = false
    @State private var immersiveSpaceID = "talent-galaxy"

    // MARK: - SwiftData Model Container
    let modelContainer: ModelContainer

    // MARK: - Initialization
    init() {
        // Configure SwiftData model container
        do {
            let schema = Schema([
                Employee.self,
                Department.self,
                Team.self,
                PerformanceData.self,
                Skill.self,
                Goal.self,
                Achievement.self,
                Feedback.self
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

            print("✅ SwiftData model container initialized successfully")
        } catch {
            fatalError("❌ Failed to create ModelContainer: \(error.localizedDescription)")
        }
    }

    // MARK: - Body
    var body: some Scene {
        // Main Dashboard Window
        WindowGroup(id: "main-dashboard") {
            ContentView()
                .environment(appState)
                .modelContainer(modelContainer)
        }
        .defaultSize(width: 900, height: 700)
        .windowStyle(.plain)

        // Employee Profile Window
        WindowGroup(id: "employee-profile", for: UUID.self) { $employeeID in
            if let id = employeeID {
                EmployeeProfileView(employeeID: id)
                    .environment(appState)
                    .modelContainer(modelContainer)
            }
        }
        .defaultSize(width: 700, height: 900)

        // Analytics Dashboard Window
        WindowGroup(id: "analytics-dashboard") {
            AnalyticsDashboardView()
                .environment(appState)
                .modelContainer(modelContainer)
        }
        .defaultSize(width: 1000, height: 700)

        // Settings Window
        WindowGroup(id: "settings") {
            SettingsView()
                .environment(appState)
                .modelContainer(modelContainer)
        }
        .defaultSize(width: 600, height: 800)

        // MARK: - Volumetric Windows

        // Organizational Chart Volume
        WindowGroup(id: "org-chart-volume") {
            OrganizationalChartVolumeView()
                .environment(appState)
                .modelContainer(modelContainer)
        }
        .windowStyle(.volumetric)
        .defaultSize(width: 1.2, height: 1.2, depth: 1.2, in: .meters)

        // Team Dynamics Volume
        WindowGroup(id: "team-dynamics-volume", for: UUID.self) { $teamID in
            if let id = teamID {
                TeamDynamicsVolumeView(teamID: id)
                    .environment(appState)
                    .modelContainer(modelContainer)
            }
        }
        .windowStyle(.volumetric)
        .defaultSize(width: 0.8, height: 0.8, depth: 0.8, in: .meters)

        // Career Path Volume
        WindowGroup(id: "career-path-volume", for: UUID.self) { $employeeID in
            if let id = employeeID {
                CareerPathVolumeView(employeeID: id)
                    .environment(appState)
                    .modelContainer(modelContainer)
            }
        }
        .windowStyle(.volumetric)
        .defaultSize(width: 1.0, height: 0.6, depth: 0.4, in: .meters)

        // MARK: - Immersive Spaces

        // Organizational Galaxy (Full Immersive)
        ImmersiveSpace(id: "talent-galaxy") {
            TalentGalaxyView()
                .environment(appState)
                .modelContainer(modelContainer)
        }
        .immersionStyle(selection: $appState.immersionLevel, in: .mixed, .progressive, .full)

        // Talent Landscape (Full Immersive)
        ImmersiveSpace(id: "talent-landscape") {
            TalentLandscapeView()
                .environment(appState)
                .modelContainer(modelContainer)
        }
        .immersionStyle(selection: $appState.immersionLevel, in: .mixed, .progressive, .full)

        // Culture Climate Visualization
        ImmersiveSpace(id: "culture-climate") {
            CultureClimateView()
                .environment(appState)
                .modelContainer(modelContainer)
        }
        .immersionStyle(selection: $appState.immersionLevel, in: .mixed, .progressive, .full)
    }
}

// MARK: - App State
@Observable
final class AppState {
    // Current User
    var currentUser: User?

    // Selected Entities
    var selectedEmployee: Employee?
    var selectedTeam: Team?
    var selectedDepartment: Department?

    // Navigation
    var activeView: AppView = .dashboard
    var immersiveSpaceOpen: Bool = false
    var immersionLevel: ImmersionStyle = .mixed

    // Services
    let hrService: HRDataService
    let analyticsService: AnalyticsService
    let aiService: AIService
    let authService: AuthenticationService

    // Feature States
    var organizationState: OrganizationState
    var analyticsState: AnalyticsState
    var performanceState: PerformanceState

    init() {
        // Initialize services
        let apiClient = APIClient(baseURL: Configuration.apiBaseURL)
        let networkClient = NetworkClient()

        self.hrService = HRDataService(apiClient: apiClient)
        self.analyticsService = AnalyticsService(apiClient: apiClient)
        self.aiService = AIService()
        self.authService = AuthenticationService()

        // Initialize states
        self.organizationState = OrganizationState()
        self.analyticsState = AnalyticsState()
        self.performanceState = PerformanceState()

        print("✅ AppState initialized")
    }
}

// MARK: - App View Enum
enum AppView {
    case dashboard
    case employees
    case analytics
    case orgChart
    case settings
}

// MARK: - Configuration
enum Configuration {
    static let apiBaseURL: URL = {
        #if DEBUG
        return URL(string: "https://dev-api.spatial-hcm.com")!
        #else
        return URL(string: "https://api.spatial-hcm.com")!
        #endif
    }()

    static let enableMockData = true
    static let enableAIFeatures = true
    static let enableVoiceCommands = true
}
