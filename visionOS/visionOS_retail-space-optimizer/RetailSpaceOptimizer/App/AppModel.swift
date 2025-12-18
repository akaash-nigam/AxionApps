import SwiftUI
import Observation

/// Global application state model
@Observable
final class AppModel {
    // MARK: - Store Management
    var selectedStore: Store?
    var activeStores: [Store] = []

    // MARK: - User State
    var currentUser: User?
    var preferences: UserPreferences = UserPreferences()

    // MARK: - Collaboration State
    var activeSession: CollaborationSession?
    var connectedUsers: [User] = []

    // MARK: - View State
    var showingAnalytics: Bool = false
    var showingSettings: Bool = false
    var currentViewMode: ViewMode = .layout

    // MARK: - Services
    let serviceContainer: ServiceContainer

    // MARK: - Initialization
    init() {
        self.serviceContainer = ServiceContainer()
        loadUserPreferences()
    }

    // MARK: - Methods
    func selectStore(_ store: Store) {
        selectedStore = store
        if !activeStores.contains(where: { $0.id == store.id }) {
            activeStores.append(store)
        }
    }

    func closeStore(_ store: Store) {
        activeStores.removeAll { $0.id == store.id }
        if selectedStore?.id == store.id {
            selectedStore = activeStores.first
        }
    }

    private func loadUserPreferences() {
        // Load from UserDefaults or iCloud
        if let data = UserDefaults.standard.data(forKey: "userPreferences"),
           let preferences = try? JSONDecoder().decode(UserPreferences.self, from: data) {
            self.preferences = preferences
        }
    }

    func saveUserPreferences() {
        if let data = try? JSONEncoder().encode(preferences) {
            UserDefaults.standard.set(data, forKey: "userPreferences")
        }
    }
}

// MARK: - Supporting Types

struct User: Identifiable, Codable {
    let id: UUID
    var name: String
    var email: String
    var role: UserRole
    var avatarURL: URL?
}

enum UserRole: String, Codable {
    case viewer
    case designer
    case admin

    var permissions: Set<Permission> {
        switch self {
        case .viewer:
            return [.viewStore, .viewAnalytics]
        case .designer:
            return [.viewStore, .editStore, .viewAnalytics, .generateSuggestions]
        case .admin:
            return Set(Permission.allCases)
        }
    }
}

enum Permission: String, Codable, CaseIterable {
    case viewStore
    case editStore
    case deleteStore
    case viewAnalytics
    case generateSuggestions
    case manageUsers
    case exportData
}

struct UserPreferences: Codable {
    var gridSnapping: Bool = true
    var gridSize: Double = 0.5 // meters
    var showMeasurements: Bool = true
    var autoSave: Bool = true
    var autoSaveInterval: TimeInterval = 300 // 5 minutes
    var analyticsOverlayOpacity: Double = 0.7
    var enableSpatialAudio: Bool = true
    var preferredUnits: MeasurementUnit = .metric
}

enum MeasurementUnit: String, Codable {
    case metric
    case imperial
}

enum ViewMode: String, Codable {
    case layout
    case analytics
    case simulation
    case presentation
}

struct CollaborationSession: Identifiable, Codable {
    let id: UUID
    var storeID: UUID
    var hostID: UUID
    var participants: [UUID]
    var createdAt: Date
    var isActive: Bool
}
