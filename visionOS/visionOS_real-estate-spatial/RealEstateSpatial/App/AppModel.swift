//
//  AppModel.swift
//  RealEstateSpatial
//
//  Main application state management
//

import Foundation
import SwiftUI
import SwiftData

@Observable
@MainActor
final class AppModel {
    // MARK: - User State

    var currentUser: User?
    var isAuthenticated: Bool = false

    // MARK: - Navigation State

    var selectedProperty: Property?
    var selectedPropertyID: UUID?
    var showingImmersiveSpace: Bool = false
    var immersionLevel: ImmersionStyle = .mixed

    // MARK: - UI State

    var searchQuery: SearchQuery = SearchQuery()
    var searchResults: [Property] = []
    var isLoading: Bool = false
    var error: Error?

    // MARK: - Services

    let propertyService: PropertyService
    let networkClient: NetworkClient
    let cacheManager: CacheManager

    // MARK: - Initialization

    init() {
        // Initialize network client
        let baseURL = URL(string: Configuration.apiBaseURL)!
        self.networkClient = NetworkClient(baseURL: baseURL)

        // Initialize cache manager
        self.cacheManager = CacheManager()

        // Initialize services (will need model context later)
        // For now, we'll use a placeholder
        self.propertyService = MockPropertyService()

        // Set up initial state
        setupInitialState()
    }

    init(modelContext: ModelContext) {
        // Initialize network client
        let baseURL = URL(string: Configuration.apiBaseURL)!
        self.networkClient = NetworkClient(baseURL: baseURL)

        // Initialize cache manager
        self.cacheManager = CacheManager()

        // Initialize property service with context
        self.propertyService = PropertyServiceImpl(
            networkClient: networkClient,
            cacheManager: cacheManager,
            context: modelContext
        )

        setupInitialState()
    }

    // MARK: - Setup

    private func setupInitialState() {
        // Load saved user session
        // In production, check keychain for auth token
    }

    // MARK: - Actions

    func searchProperties() async {
        isLoading = true
        error = nil

        defer { isLoading = false }

        do {
            searchResults = try await propertyService.fetchProperties(query: searchQuery)
        } catch {
            self.error = error
        }
    }

    func selectProperty(_ property: Property) async {
        selectedProperty = property
        selectedPropertyID = property.id

        // Preload any spatial assets
        // In production, would load 3D models here
    }

    func toggleFavorite(_ property: Property) async {
        guard let user = currentUser else { return }

        if user.savedProperties.contains(where: { $0.id == property.id }) {
            // Remove from favorites
            user.savedProperties.removeAll(where: { $0.id == property.id })
        } else {
            // Add to favorites
            user.savedProperties.append(property)
        }
    }

    func startImmersiveTour(property: Property) async {
        selectedProperty = property
        showingImmersiveSpace = true

        // In production, would load spatial data here
    }

    func endImmersiveTour() {
        showingImmersiveSpace = false
    }

    func signIn(email: String, password: String) async throws {
        // In production, authenticate with backend
        // For now, create a mock user
        let profile = UserProfile(
            firstName: "Demo",
            lastName: "User"
        )

        let user = User(
            email: email,
            profile: profile,
            role: .buyer
        )

        currentUser = user
        isAuthenticated = true
    }

    func signOut() {
        currentUser = nil
        isAuthenticated = false
        selectedProperty = nil
    }
}

// MARK: - Configuration

enum Configuration {
    static var apiBaseURL: String {
        #if DEBUG
        return "https://api-dev.realestatespatial.com"
        #else
        return "https://api.realestatespatial.com"
        #endif
    }

    static var enableAnalytics: Bool {
        #if DEBUG
        return false
        #else
        return true
        #endif
    }

    static var logLevel: LogLevel {
        #if DEBUG
        return .debug
        #else
        return .info
        #endif
    }
}

enum LogLevel {
    case debug
    case info
    case warning
    case error
}

// MARK: - Mock Service for Testing

final class MockPropertyService: PropertyService {
    func fetchProperties(query: SearchQuery) async throws -> [Property] {
        // Return mock data
        return [.preview]
    }

    func fetchProperty(id: UUID) async throws -> Property {
        return .preview
    }

    func saveProperty(_ property: Property) async throws {
        // No-op
    }

    func updateProperty(_ property: Property) async throws {
        // No-op
    }

    func deleteProperty(id: UUID) async throws {
        // No-op
    }

    func searchProperties(criteria: SearchCriteria) async throws -> [Property] {
        return [.preview]
    }
}
