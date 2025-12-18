import SwiftUI
import Observation

@Observable
class AppState {
    // MARK: - User State
    var currentUser: User?
    var userPreferences: UserPreferences = UserPreferences()

    // MARK: - Session State
    var activeProjects: [DesignProject] = []
    var currentProject: DesignProject?
    var selectedParts: Set<UUID> = []

    // MARK: - UI State
    var activeWorkspace: WorkspaceMode = .windows
    var immersionLevel: ImmersionStyle = .mixed
    var toolPaletteState: ToolPaletteState = ToolPaletteState()

    // MARK: - Collaboration State
    var activeSessions: [CollaborationSession] = []
    var connectedUsers: [User] = []
    var isCollaborating: Bool = false

    // MARK: - View State
    var showInspector: Bool = true
    var showLibrary: Bool = false
    var currentTool: DesignTool = .select

    // MARK: - Initialization
    init() {
        // Initialize default state
        self.currentUser = User.defaultUser
    }

    // MARK: - Methods
    func selectPart(_ partID: UUID) {
        selectedParts.insert(partID)
    }

    func deselectPart(_ partID: UUID) {
        selectedParts.remove(partID)
    }

    func clearSelection() {
        selectedParts.removeAll()
    }

    func setCurrentTool(_ tool: DesignTool) {
        currentTool = tool
    }
}

// MARK: - Supporting Types
enum WorkspaceMode {
    case windows
    case mixedReality
    case fullImmersive
}

enum DesignTool {
    case select
    case move
    case rotate
    case scale
    case extrude
    case revolve
    case fillet
    case chamfer
    case measure
    case section
}

@Observable
class ToolPaletteState {
    var isVisible: Bool = true
    var position: SIMD3<Float> = SIMD3<Float>(0, -0.3, -0.5)
    var activeTool: DesignTool = .select
}

struct UserPreferences {
    var units: UnitSystem = .metric
    var gridSize: Float = 10.0
    var snapToGrid: Bool = true
    var showGrid: Bool = true
    var showAxes: Bool = true
    var theme: ColorTheme = .dark
    var language: String = "en"
}

enum UnitSystem {
    case metric // mm, cm, m
    case imperial // in, ft
}

enum ColorTheme {
    case light
    case dark
    case auto
}
