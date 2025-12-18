import SwiftUI
import Observation

@Observable
final class AppState {
    // MARK: - Authentication & User

    var currentUser: SafetyUser?
    var isAuthenticated: Bool = false
    var userPermissions: Set<Permission> = []

    // MARK: - Navigation

    var selectedView: AppView = .dashboard
    var navigationPath: [AppView] = []
    var activeScenario: SafetyScenario?

    // MARK: - Training Session

    var currentSession: TrainingSession?
    var sessionProgress: SessionProgress?
    var immersionLevel: ImmersionStyle = .mixed

    // MARK: - UI State

    var showsAnalytics: Bool = false
    var showsSettings: Bool = false
    var isLoading: Bool = false
    var errorMessage: String?

    // MARK: - Initialization

    init() {
        // Initialize with default state
        // In production, load saved state and authenticate user
        setupDefaultUser()
    }

    // MARK: - Methods

    private func setupDefaultUser() {
        // For demo purposes, create a default user
        // In production, this would come from authentication
        currentUser = SafetyUser(
            name: "Demo User",
            role: .operator,
            department: "Manufacturing",
            hireDate: Date()
        )
        isAuthenticated = true
        userPermissions = [.viewTraining, .completeScenarios]
    }

    func startTrainingSession(_ module: TrainingModule) {
        currentSession = TrainingSession(
            user: currentUser!,
            module: module,
            startTime: Date()
        )
    }

    func endTrainingSession() {
        currentSession?.endTime = Date()
        currentSession = nil
        sessionProgress = nil
    }

    func showError(_ message: String) {
        errorMessage = message
    }

    func clearError() {
        errorMessage = nil
    }
}

// MARK: - Supporting Types

enum AppView {
    case dashboard
    case training
    case analytics
    case settings
    case scenarioDetail(SafetyScenario)
}

enum Permission: String, Codable, Hashable {
    case viewTraining
    case completeScenarios
    case viewTeamMetrics
    case createScenarios
    case assessUsers
    case manageUsers
    case viewReports
    case exportData

    static var all: Set<Permission> {
        Set([
            .viewTraining, .completeScenarios, .viewTeamMetrics,
            .createScenarios, .assessUsers, .manageUsers,
            .viewReports, .exportData
        ])
    }
}

struct SessionProgress {
    var completedObjectives: [String]
    var currentScore: Double
    var hazardsDetected: Int
    var hazardsMissed: Int
    var timeElapsed: TimeInterval
}
