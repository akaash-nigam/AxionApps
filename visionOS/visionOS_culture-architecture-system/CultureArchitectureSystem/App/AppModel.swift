//
//  AppModel.swift
//  CultureArchitectureSystem
//
//  Created on 2025-01-20
//

import SwiftUI
import Observation

@Observable
final class AppModel {
    // Current state
    var currentOrganization: Organization?
    var currentUser: AnonymousUser?
    var navigationPath: [Route] = []
    var isImmersiveSpaceActive: Bool = false
    var cultureHealthScore: Double = 0
    var isLoading: Bool = false
    var error: Error?

    // Services
    private(set) var cultureService: CultureService
    private(set) var analyticsService: AnalyticsService
    private(set) var recognitionService: RecognitionService
    private(set) var visualizationService: VisualizationService

    // Networking
    private var authManager: AuthenticationManager
    private var apiClient: APIClient

    init() {
        // Initialize networking first
        let authMgr = AuthenticationManager()
        let apiCli = APIClient(authManager: authMgr)

        self.authManager = authMgr
        self.apiClient = apiCli

        // Initialize services
        self.cultureService = CultureService(apiClient: apiCli, authManager: authMgr)
        self.analyticsService = AnalyticsService(apiClient: apiCli)
        self.recognitionService = RecognitionService(apiClient: apiCli)
        self.visualizationService = VisualizationService()

        setupNotifications()
    }

    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            forName: .cultureUpdated,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let self = self else { return }
            // Extract update before crossing isolation boundary
            if let update = notification.object as? CultureUpdate {
                Task { @MainActor in
                    await self.refreshDashboard()
                }
            }
        }
    }

    @MainActor
    func refreshDashboard() async {
        isLoading = true
        defer { isLoading = false }

        do {
            if let orgId = currentOrganization?.id {
                let health = try await cultureService.fetchHealthScore(for: orgId)
                self.cultureHealthScore = health
            }
        } catch {
            self.error = error
        }
    }
}

// MARK: - Supporting Types

struct AnonymousUser: Identifiable {
    let id: UUID
    let teamId: UUID
    let role: String
    let permissions: UserPermissions
}

struct UserPermissions {
    var canViewDashboard: Bool = true
    var canGiveRecognition: Bool = true
    var canViewAnalytics: Bool = true
    var canManageValues: Bool = false
    var canAccessImmersive: Bool = true
}

enum Route: Hashable {
    case dashboard
    case analytics
    case recognition
    case teamCulture(UUID)
    case valueExplorer(UUID)
    case cultureCampus
    case settings
}

struct CultureUpdate: Codable {
    let type: UpdateType
    let organizationId: UUID
    let regionId: UUID?
    let healthScore: Double?
    let timestamp: Date

    enum UpdateType: String, Codable {
        case healthChange
        case newRecognition
        case ritualCompleted
        case behaviorEvent
    }
}

// Notification names
extension Notification.Name {
    static let cultureUpdated = Notification.Name("cultureUpdated")
    static let recognitionGiven = Notification.Name("recognitionGiven")
    static let immersiveSpaceOpened = Notification.Name("immersiveSpaceOpened")
}
