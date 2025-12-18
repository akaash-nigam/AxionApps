//
//  AppState.swift
//  SpatialWellness
//
//  Created by Claude on 2025-11-17.
//  Copyright © 2025 Spatial Wellness Platform. All rights reserved.
//

import SwiftUI
import Observation

/// Global application state using Swift 6.0 @Observable macro
/// Manages user session, navigation, health data cache, and UI state
@Observable
class AppState {

    // MARK: - User State

    /// Current authenticated user profile
    var currentUser: UserProfile?

    /// Authentication status
    var isAuthenticated: Bool = false

    // MARK: - Navigation State

    /// Currently selected tab
    var selectedTab: TabSelection = .dashboard

    /// Active window identifier
    var activeWindow: WindowIdentifier?

    /// Whether an immersive space is currently active
    var immersiveSpaceActive: Bool = false

    /// Current immersive space type
    var currentImmersiveSpace: ImmersiveSpaceType?

    // MARK: - Health Data State (Cached)

    /// Latest biometric readings by type
    var latestBiometrics: [BiometricType: BiometricReading] = [:]

    /// Today's activity summary
    var todayActivity: ActivitySummary?

    /// Current active health goals
    var currentGoals: [HealthGoal] = []

    /// Health insights from AI
    var healthInsights: [HealthInsight] = []

    // MARK: - Social State

    /// Active challenges user is participating in
    var activeChallenges: [Challenge] = []

    /// Unread notifications
    var notifications: [WellnessNotification] = []

    /// Notification badge count
    var notificationCount: Int {
        notifications.filter { !$0.isRead }.count
    }

    // MARK: - Environment State

    /// Current wellness environment (for immersive spaces)
    var currentEnvironment: WellnessEnvironment?

    /// Immersion level (0.0 - 1.0 for progressive)
    var immersionLevel: Double = 0.0

    // MARK: - UI State

    /// Global loading indicator
    var isLoading: Bool = false

    /// Error message to display (if any)
    var errorMessage: String?

    /// Whether settings window is showing
    var showingSettings: Bool = false

    /// Whether onboarding should be shown
    var showingOnboarding: Bool = false

    // MARK: - Initialization

    init() {
        // Initialize with default state
        // Will be populated after authentication
    }

    // MARK: - State Management Methods

    /// Update authentication state
    func authenticate(user: UserProfile) {
        self.currentUser = user
        self.isAuthenticated = true
        self.showingOnboarding = false
    }

    /// Sign out and clear state
    func signOut() {
        self.currentUser = nil
        self.isAuthenticated = false
        self.latestBiometrics = [:]
        self.todayActivity = nil
        self.currentGoals = []
        self.activeChallenges = []
        self.notifications = []
    }

    /// Update latest biometric reading
    func updateBiometric(_ reading: BiometricReading) {
        latestBiometrics[reading.type] = reading
    }

    /// Add notification
    func addNotification(_ notification: WellnessNotification) {
        notifications.insert(notification, at: 0)
    }

    /// Mark notification as read
    func markNotificationRead(_ notificationId: UUID) {
        if let index = notifications.firstIndex(where: { $0.id == notificationId }) {
            notifications[index].isRead = true
        }
    }

    /// Clear all notifications
    func clearNotifications() {
        notifications.removeAll()
    }

    /// Enter immersive space
    func enterImmersiveSpace(_ type: ImmersiveSpaceType) {
        immersiveSpaceActive = true
        currentImmersiveSpace = type
    }

    /// Exit immersive space
    func exitImmersiveSpace() {
        immersiveSpaceActive = false
        currentImmersiveSpace = nil
        immersionLevel = 0.0
    }

    /// Show error message
    func showError(_ message: String) {
        self.errorMessage = message
    }

    /// Clear error message
    func clearError() {
        self.errorMessage = nil
    }
}

// MARK: - Supporting Types

/// Tab selection enum
enum TabSelection {
    case dashboard
    case activity
    case nutrition
    case social
    case meditation
}

/// Window identifier enum
enum WindowIdentifier: String {
    case dashboard
    case biometrics
    case community
    case settings
    case analytics
}

/// Immersive space type enum
enum ImmersiveSpaceType: String {
    case meditation
    case virtualGym
    case relaxationBeach
    case yogaStudio
}

/// Activity summary for today
struct ActivitySummary: Codable {
    var date: Date
    var steps: Int
    var activeMinutes: Int
    var caloriesBurned: Double
    var distanceMeters: Double
    var floorsClimbed: Int

    var stepGoalProgress: Double {
        Double(steps) / 10000.0
    }

    var activeMinutesProgress: Double {
        Double(activeMinutes) / 30.0
    }
}

/// Health insight from AI
struct HealthInsight: Identifiable, Codable {
    var id: UUID = UUID()
    var title: String
    var message: String
    var category: InsightCategory
    var priority: InsightPriority
    var timestamp: Date
    var actionable: Bool
    var actionTitle: String?

    enum InsightCategory: String, Codable {
        case sleep, activity, nutrition, stress, heart, general
    }

    enum InsightPriority: String, Codable {
        case low, medium, high, critical
    }
}

/// Wellness notification
struct WellnessNotification: Identifiable, Codable {
    var id: UUID = UUID()
    var title: String
    var message: String
    var type: NotificationType
    var timestamp: Date
    var isRead: Bool = false
    var actionable: Bool = false
    var actionUrl: String?

    enum NotificationType: String, Codable {
        case goalAchieved
        case challengeUpdate
        case healthAlert
        case socialActivity
        case reminder
        case insight
    }
}
