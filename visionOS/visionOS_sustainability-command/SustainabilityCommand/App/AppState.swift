import Foundation
import SwiftUI
import Observation

/// App-wide state container using Swift's Observation framework
@Observable
final class AppState {
    // MARK: - User Session

    var currentUser: User?
    var organization: Organization?

    // MARK: - Sustainability Data

    var currentFootprint: CarbonFootprint?
    var goals: [SustainabilityGoal] = []
    var facilities: [Facility] = []
    var supplyChains: [SupplyChain] = []

    // MARK: - UI State

    var activeWindows: Set<WindowIdentifier> = []
    var immersiveMode: ImmersiveMode?
    var selectedFacility: Facility?
    var selectedGoal: SustainabilityGoal?

    // MARK: - Settings

    var preferences: UserPreferences
    var visualizationSettings: VisualizationSettings

    // MARK: - Services

    let sustainabilityService: SustainabilityService
    let carbonTrackingService: CarbonTrackingService
    let aiAnalyticsService: AIAnalyticsService
    let visualizationService: VisualizationService

    // MARK: - Loading State

    var isLoading: Bool = false
    var error: AppError?

    // MARK: - Initialization

    init() {
        // Initialize preferences
        self.preferences = UserPreferences()
        self.visualizationSettings = VisualizationSettings()

        // Initialize services
        let apiClient = APIClient(baseURL: Configuration.apiBaseURL)
        let dataStore = DataStore()

        self.sustainabilityService = SustainabilityService(
            apiClient: apiClient,
            dataStore: dataStore
        )
        self.carbonTrackingService = CarbonTrackingService(
            apiClient: apiClient
        )
        self.aiAnalyticsService = AIAnalyticsService(
            apiClient: apiClient
        )
        self.visualizationService = VisualizationService()

        // Load initial data
        Task {
            await loadInitialData()
        }
    }

    // MARK: - Data Loading

    @MainActor
    func loadInitialData() async {
        isLoading = true
        defer { isLoading = false }

        do {
            // Load current footprint
            currentFootprint = try await sustainabilityService.fetchCurrentFootprint()

            // Load facilities
            facilities = try await sustainabilityService.fetchFacilities()

            // Load goals
            goals = try await sustainabilityService.fetchGoals()

            // Load supply chains
            supplyChains = try await sustainabilityService.fetchSupplyChains()

        } catch {
            self.error = .dataLoadFailed(error)
            print("Failed to load initial data: \(error)")
        }
    }

    // MARK: - Window Management

    func openWindow(_ identifier: WindowIdentifier) {
        activeWindows.insert(identifier)
    }

    func closeWindow(_ identifier: WindowIdentifier) {
        activeWindows.remove(identifier)
    }
}

// MARK: - Supporting Types

enum WindowIdentifier: String, Hashable {
    case dashboard = "sustainability-dashboard"
    case goalsTracker = "goals-tracker"
    case analytics = "analytics-detail"
    case carbonFlow = "carbon-flow-volume"
    case energyChart = "energy-3d-chart"
    case supplyChain = "supply-chain-volume"
    case earthImmersive = "earth-immersive"
}

enum ImmersiveMode {
    case mixed
    case progressive
    case full
}

struct UserPreferences: Codable {
    var unit: MeasurementUnit = .metric
    var currency: Currency = .usd
    var language: String = "en"
    var notifications: Bool = true
    var soundEnabled: Bool = true
    var hapticsEnabled: Bool = true

    enum MeasurementUnit: String, Codable {
        case metric
        case imperial
    }

    enum Currency: String, Codable {
        case usd = "USD"
        case eur = "EUR"
        case gbp = "GBP"
    }
}

struct VisualizationSettings: Codable {
    var showEmissionHeatMap: Bool = true
    var showFacilityMarkers: Bool = true
    var showSupplyChainPaths: Bool = true
    var showImpactZones: Bool = false
    var showRenewableEnergy: Bool = true
    var earthRotationSpeed: Double = 1.0
    var particleDensity: ParticleDensity = .medium

    enum ParticleDensity: String, Codable {
        case low
        case medium
        case high
    }
}

enum AppError: LocalizedError {
    case dataLoadFailed(Error)
    case networkError(Error)
    case authenticationFailed
    case insufficientPermissions

    var errorDescription: String? {
        switch self {
        case .dataLoadFailed(let error):
            return "Failed to load data: \(error.localizedDescription)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .authenticationFailed:
            return "Authentication failed. Please sign in again."
        case .insufficientPermissions:
            return "You don't have permission to access this resource."
        }
    }
}

struct User {
    let id: UUID
    let name: String
    let email: String
    let role: Role

    enum Role: String {
        case admin
        case manager
        case analyst
        case viewer
    }
}

struct Organization {
    let id: UUID
    let name: String
    let industry: String
    let targetNetZeroYear: Int
}
