//
//  AppState.swift
//  Legal Discovery Universe
//
//  Created by Claude Code
//  Copyright © 2024 Legal Discovery Universe. All rights reserved.
//

import Foundation
import SwiftUI
import Observation

/// Global application state using Swift's @Observable macro
@Observable
@MainActor
class AppState {
    // MARK: - User & Session
    var currentUser: User?
    var isAuthenticated: Bool = false
    var sessionId: UUID = UUID()

    // MARK: - Current Case
    var activeCase: LegalCase?
    var activeCaseId: UUID?

    // MARK: - Navigation
    var navigationPath: [Route] = []
    var presentedWindows: Set<WindowIdentifier> = []
    var immersiveSpaceActive: Bool = false

    // MARK: - Settings
    var settings: AppSettings = AppSettings()

    // MARK: - Services
    let documentService: DocumentService
    let aiService: AIService
    let visualizationService: VisualizationService
    let collaborationService: CollaborationService
    let securityService: SecurityService
    let networkService: NetworkService

    // MARK: - State
    var isLoading: Bool = false
    var errorMessage: String?

    // MARK: - Initialization
    init() {
        // Initialize services
        self.securityService = SecurityServiceImpl()
        self.networkService = NetworkServiceImpl(securityService: securityService)
        self.documentService = DocumentServiceImpl()
        self.aiService = AIServiceImpl()
        self.visualizationService = VisualizationServiceImpl()
        self.collaborationService = CollaborationServiceImpl()

        // Load user session if exists
        Task {
            await loadSession()
        }
    }

    // MARK: - Session Management
    func loadSession() async {
        // Load saved session from secure storage
        // Implementation would check Keychain for saved session
    }

    func logout() {
        currentUser = nil
        isAuthenticated = false
        activeCase = nil
        sessionId = UUID()
    }
}

// MARK: - Supporting Types

struct User: Codable, Identifiable {
    let id: UUID
    var email: String
    var name: String
    var role: UserRole
    var firm: String
    var settings: UserSettings?
}

enum UserRole: String, Codable {
    case attorney
    case paralegal
    case ediscoveryManager
    case administrator
}

struct UserSettings: Codable {
    var theme: Theme = .auto
    var autoSavePositions: Bool = true
    var enableAISuggestions: Bool = true
    var showConfidenceScores: Bool = true
    var offlineMode: Bool = false
}

enum Theme: String, Codable {
    case light
    case dark
    case auto
}

struct AppSettings: Codable {
    var dataRetentionDays: Int = 2555 // 7 years
    var encryptionLevel: EncryptionLevel = .maximum
    var auditLevel: AuditLevel = .comprehensive
    var performanceMode: PerformanceMode = .balanced
}

enum EncryptionLevel: String, Codable {
    case standard
    case high
    case maximum
}

enum AuditLevel: String, Codable {
    case minimal
    case standard
    case comprehensive
}

enum PerformanceMode: String, Codable {
    case quality
    case balanced
    case performance
}

enum Route: Hashable {
    case caseList
    case caseDetail(UUID)
    case documentList
    case documentDetail(UUID)
    case search(String)
    case settings
}

enum WindowIdentifier: String, Hashable {
    case mainWorkspace = "main-workspace"
    case documentDetail = "document-detail"
    case evidenceUniverse = "evidence-universe"
    case timeline = "timeline-volume"
    case network = "network-volume"
    case settings = "settings"
    case caseInvestigation = "case-investigation"
    case presentationMode = "presentation-mode"
}
