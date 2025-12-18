import SwiftUI
import SwiftData

@Observable
class AppState {
    var selectedStore: Store?
    var activeLayout: StoreLayout?
    var isImmersiveSpaceActive: Bool = false
    var currentUser: User?
    var preferences: UserPreferences = UserPreferences()

    // Services
    let storeService: StoreService
    let layoutService: LayoutService
    let analyticsService: AnalyticsService
    let simulationService: SimulationService
    let fixtureLibraryService: FixtureLibraryService
    let collaborationService: CollaborationService

    init() {
        // Initialize services
        let apiClient = APIClient(baseURL: URL(string: Configuration.apiURL)!)
        let dataStore = DataStore()
        let cache = CacheService()

        self.storeService = StoreService(apiClient: apiClient, dataStore: dataStore, cache: cache)
        self.layoutService = LayoutService(apiClient: apiClient)
        self.analyticsService = AnalyticsService(apiClient: apiClient)
        self.simulationService = SimulationService()
        self.fixtureLibraryService = FixtureLibraryService(apiClient: apiClient, cache: cache)
        self.collaborationService = CollaborationService()
    }

    // MARK: - Store Management

    func selectStore(_ store: Store) {
        selectedStore = store
    }

    func deselectStore() {
        selectedStore = nil
        activeLayout = nil
    }

    func activateLayout(_ layout: StoreLayout) {
        activeLayout = layout
    }

    // MARK: - Immersive Mode

    func startImmersiveExperience() async throws {
        isImmersiveSpaceActive = true
    }

    func endImmersiveExperience() async throws {
        isImmersiveSpaceActive = false
    }
}

// MARK: - User Preferences

struct UserPreferences: Codable {
    var gridSize: Float = 0.5 // meters
    var snapToGrid: Bool = true
    var showDimensions: Bool = true
    var renderQuality: RenderQuality = .high
    var autoSaveInterval: TimeInterval = 300 // 5 minutes
    var undoSteps: Int = 50
    var theme: Theme = .system

    enum RenderQuality: String, Codable {
        case low, medium, high, ultra
    }

    enum Theme: String, Codable {
        case light, dark, system
    }
}

// MARK: - User Model

struct User: Codable, Identifiable {
    let id: UUID
    var email: String
    var name: String
    var role: UserRole
    var permissions: [Permission]

    enum UserRole: String, Codable {
        case viewer, editor, admin, owner
    }

    enum Permission: String, Codable {
        case viewStore
        case editStore
        case deleteStore
        case manageUsers
        case viewAnalytics
        case exportData
        case configureIntegrations
    }
}

// MARK: - Configuration

enum Configuration {
    #if DEBUG
    static let apiURL = "https://dev-api.retailoptimizer.com"
    static let enableLogging = true
    static let useMockData = true
    #else
    static let apiURL = "https://api.retailoptimizer.com"
    static let enableLogging = false
    static let useMockData = false
    #endif
}
