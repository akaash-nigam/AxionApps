//
//  AIAgentCoordinatorApp.swift
//  AI Agent Coordinator
//
//  Created by Claude Code on 2025-01-20.
//  Platform: visionOS 2.0+
//

import SwiftUI
import SwiftData

@main
struct AIAgentCoordinatorApp: App {
    @State private var appModel = AppModel()
    @State private var immersionStyle: ImmersionStyle = .mixed
    @Environment(\.scenePhase) private var scenePhase

    // SwiftData model container with graceful error handling
    let modelContainer: ModelContainer = {
        let schema = Schema([
            AIAgent.self,
            AgentMetrics.self,
            UserWorkspace.self
        ])

        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            allowsSave: true
        )

        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            // Fallback to in-memory storage if persistent storage fails
            print("Warning: Failed to create persistent ModelContainer: \(error). Using in-memory storage.")
            let fallbackConfig = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: true
            )
            do {
                return try ModelContainer(for: schema, configurations: [fallbackConfig])
            } catch {
                fatalError("Failed to create ModelContainer: \(error)")
            }
        }
    }()

    var body: some Scene {
        // MARK: - Main Control Panel Window
        WindowGroup(id: "control-panel") {
            ControlPanelView()
                .environment(appModel)
                .modelContainer(modelContainer)
                .onChange(of: scenePhase) { oldPhase, newPhase in
                    handleScenePhaseChange(from: oldPhase, to: newPhase)
                }
        }
        .windowStyle(.plain)
        .defaultSize(width: 900, height: 700)
        .windowResizability(.contentSize)

        // MARK: - Agent List Window
        WindowGroup(id: "agent-list") {
            AgentListView()
                .environment(appModel)
                .modelContainer(modelContainer)
        }
        .defaultSize(width: 400, height: 600)

        // MARK: - Settings Window
        WindowGroup(id: "settings") {
            SettingsView()
                .environment(appModel)
        }
        .defaultSize(width: 500, height: 400)

        // MARK: - Agent Detail Volume
        WindowGroup(id: "agent-detail", for: UUID.self) { $agentId in
            if let agentId {
                AgentDetailWrapper(agentId: agentId)
                    .environment(appModel)
                    .modelContainer(modelContainer)
            }
        }
        .windowStyle(.volumetric)
        .defaultSize(width: 0.6, height: 0.6, depth: 0.6, in: .meters)

        // MARK: - Immersive Spaces

        // Main 3D agent galaxy visualization
        ImmersiveSpace(id: "agent-galaxy") {
            AgentGalaxyView()
                .environment(appModel)
                .modelContainer(modelContainer)
        }
        .immersionStyle(selection: $immersionStyle, in: .mixed, .progressive, .full)

        // Performance landscape visualization
        ImmersiveSpace(id: "performance-landscape") {
            PerformanceLandscapeView()
                .environment(appModel)
                .modelContainer(modelContainer)
        }
        .immersionStyle(selection: .constant(.progressive), in: .progressive)

        // Decision flow river visualization
        ImmersiveSpace(id: "decision-flow") {
            DecisionFlowView()
                .environment(appModel)
                .modelContainer(modelContainer)
        }
        .immersionStyle(selection: .constant(.full), in: .full)
    }

    // MARK: - Scene Phase Handling

    /// Handle scene phase changes to manage background operations
    private func handleScenePhaseChange(from oldPhase: ScenePhase, to newPhase: ScenePhase) {
        switch newPhase {
        case .background:
            // Pause expensive operations when app goes to background
            Task {
                await appModel.pauseBackgroundOperations()
            }
        case .active:
            // Resume operations when app becomes active
            Task {
                await appModel.resumeBackgroundOperations()
            }
        case .inactive:
            // App is transitioning - reduce update frequency
            Task {
                await appModel.reduceUpdateFrequency()
            }
        @unknown default:
            break
        }
    }
}

// MARK: - App Model

@Observable
@MainActor
class AppModel {
    // MARK: - Services

    /// Metrics collector for monitoring agent performance
    let metricsCollector = MetricsCollector()

    /// Agent coordinator for managing agent lifecycle
    let coordinator: AgentCoordinator

    // MARK: - User Session
    var currentUser: User?
    var workspace: UserWorkspace?

    // MARK: - Navigation
    var selectedView: NavigationDestination = .dashboard
    var isPresentingImmersiveSpace = false
    var activeImmersiveSpaceId: String?

    // MARK: - Agent Management
    var agents: [UUID: AIAgent] = [:]
    var selectedAgentId: UUID?
    var agentFilter: AgentFilter?

    // MARK: - Metrics and Monitoring
    var latestMetrics: [UUID: AgentMetrics] = [:]
    var alerts: [AppAlert] = []

    /// Whether background monitoring is currently paused
    private(set) var isMonitoringPaused = false

    // MARK: - Collaboration
    var collaborationSession: CollaborationSession?
    var participants: [AppParticipant] = []

    // MARK: - UI State
    var isLoading = false
    var error: AppError?

    // MARK: - Spatial State
    var spatialLayout: SpatialLayout = .galaxy

    // MARK: - Initialization

    init() {
        self.coordinator = AgentCoordinator()
        // Initialize with sample data for testing
        self.loadSampleData()
    }

    func loadSampleData() {
        // TODO: Load from persistence or backend
        self.workspace = UserWorkspace(name: "Default Workspace")
    }

    // MARK: - Scene Phase Management

    /// Pause expensive background operations when app enters background
    func pauseBackgroundOperations() async {
        guard !isMonitoringPaused else { return }

        isMonitoringPaused = true
        await metricsCollector.stopAllMonitoring()
    }

    /// Resume background operations when app becomes active
    func resumeBackgroundOperations() async {
        guard isMonitoringPaused else { return }

        isMonitoringPaused = false

        // Restart monitoring for all active agents
        for (agentId, agent) in agents where agent.status == .active {
            await metricsCollector.startMonitoring(agentId: agentId)
        }
    }

    /// Reduce update frequency during inactive state
    func reduceUpdateFrequency() async {
        // In a full implementation, this would adjust the metrics collector's
        // update frequency to reduce resource usage during transitions
    }
}

// MARK: - Supporting Types

enum NavigationDestination {
    case dashboard
    case agentList
    case settings
    case galaxy
    case landscape
    case decisionFlow
}

enum SpatialLayout: String, Codable {
    case galaxy
    case landscape
    case river
    case hierarchical
    case custom
}

struct User: Codable, Identifiable {
    let id: UUID
    var name: String
    var email: String
    var role: UserRole

    init(id: UUID = UUID(), name: String, email: String, role: UserRole = .viewer) {
        self.id = id
        self.name = name
        self.email = email
        self.role = role
    }
}

enum UserRole: String, Codable {
    case admin
    case `operator`
    case viewer
}

struct CollaborationSession: Codable, Identifiable {
    let id: UUID
    var name: String
    var participants: [UUID]
    var startedAt: Date

    init(id: UUID = UUID(), name: String, participants: [UUID] = [], startedAt: Date = Date()) {
        self.id = id
        self.name = name
        self.participants = participants
        self.startedAt = startedAt
    }
}

/// Participant in the app's collaboration session (distinct from SharePlay Participant)
struct AppParticipant: Codable, Identifiable, Sendable {
    let id: UUID
    var user: User
    var joinedAt: Date
    var isActive: Bool

    init(id: UUID = UUID(), user: User, joinedAt: Date = Date(), isActive: Bool = true) {
        self.id = id
        self.user = user
        self.joinedAt = joinedAt
        self.isActive = isActive
    }
}

struct AppAlert: Codable, Identifiable {
    let id: UUID
    var severity: AppAlertSeverity
    var title: String
    var message: String
    var agentId: UUID?
    var timestamp: Date
    var acknowledged: Bool

    init(id: UUID = UUID(), severity: AppAlertSeverity, title: String, message: String, agentId: UUID? = nil, timestamp: Date = Date(), acknowledged: Bool = false) {
        self.id = id
        self.severity = severity
        self.title = title
        self.message = message
        self.agentId = agentId
        self.timestamp = timestamp
        self.acknowledged = acknowledged
    }
}

enum AppAlertSeverity: String, Codable {
    case critical
    case warning
    case info
}

struct AppError: Error, Identifiable {
    let id: UUID
    let message: String
    let underlyingError: Error?

    init(id: UUID = UUID(), message: String, underlyingError: Error? = nil) {
        self.id = id
        self.message = message
        self.underlyingError = underlyingError
    }
}

struct AgentFilter: Codable {
    var searchQuery: String = ""
    var statusFilter: Set<AgentStatus> = []
    var typeFilter: Set<AgentType> = []
    var platformFilter: Set<AIPlatform> = []
}

/// Wrapper view that fetches an agent from SwiftData by UUID
struct AgentDetailWrapper: View {
    let agentId: UUID
    @Query private var agents: [AIAgent]

    init(agentId: UUID) {
        self.agentId = agentId
        self._agents = Query(filter: #Predicate<AIAgent> { agent in
            agent.id == agentId
        })
    }

    var body: some View {
        if let agent = agents.first {
            AgentDetailVolumeView(agent: agent)
        } else {
            ContentUnavailableView(
                "Agent Not Found",
                systemImage: "exclamationmark.triangle",
                description: Text("The requested agent could not be found.")
            )
        }
    }
}
