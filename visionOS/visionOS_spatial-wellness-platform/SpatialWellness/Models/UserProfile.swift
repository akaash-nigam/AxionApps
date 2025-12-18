//
//  UserProfile.swift
//  SpatialWellness
//
//  Created by Claude on 2025-11-17.
//  Copyright © 2025 Spatial Wellness Platform. All rights reserved.
//

import Foundation
import SwiftData

/// User profile model representing a user in the wellness platform
/// Stores personal information, health goals, and privacy settings
@Model
final class UserProfile {

    // MARK: - Properties

    /// Unique identifier
    @Attribute(.unique) var id: UUID

    /// User's first name
    var firstName: String

    /// User's last name
    var lastName: String

    /// Email address
    var email: String

    /// Date of birth
    var dateOfBirth: Date

    /// Account creation date
    var createdAt: Date

    /// Last updated timestamp
    var updatedAt: Date

    // MARK: - Privacy Settings

    /// Privacy level for data sharing
    var privacyLevel: PrivacyLevel

    /// Specific sharing preferences
    var sharingPreferences: SharingPreferences

    // MARK: - Health Profile

    /// Active health goals
    var healthGoals: [HealthGoal]

    /// Chronic health conditions
    var chronicConditions: [String]

    /// Current medications
    var medications: [String]

    /// Known allergies
    var allergies: [String]

    // MARK: - Relationships

    /// Biometric readings (one-to-many)
    @Relationship(deleteRule: .cascade)
    var biometricReadings: [BiometricReading]?

    /// Activities (one-to-many)
    @Relationship(deleteRule: .cascade)
    var activities: [Activity]?

    /// Achievements (one-to-many)
    @Relationship(deleteRule: .cascade)
    var achievements: [Achievement]?

    // MARK: - Initialization

    init(
        id: UUID = UUID(),
        firstName: String,
        lastName: String,
        email: String,
        dateOfBirth: Date,
        privacyLevel: PrivacyLevel = .private,
        sharingPreferences: SharingPreferences = SharingPreferences()
    ) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.dateOfBirth = dateOfBirth
        self.createdAt = Date()
        self.updatedAt = Date()
        self.privacyLevel = privacyLevel
        self.sharingPreferences = sharingPreferences
        self.healthGoals = []
        self.chronicConditions = []
        self.medications = []
        self.allergies = []
    }

    // MARK: - Computed Properties

    /// Full name
    var fullName: String {
        "\(firstName) \(lastName)"
    }

    /// Age in years
    var age: Int {
        Calendar.current.dateComponents([.year], from: dateOfBirth, to: Date()).year ?? 0
    }

    /// Initials for avatar
    var initials: String {
        let first = firstName.prefix(1).uppercased()
        let last = lastName.prefix(1).uppercased()
        return "\(first)\(last)"
    }

    // MARK: - Methods

    /// Update profile information
    func update(firstName: String? = nil, lastName: String? = nil, email: String? = nil) {
        if let firstName = firstName {
            self.firstName = firstName
        }
        if let lastName = lastName {
            self.lastName = lastName
        }
        if let email = email {
            self.email = email
        }
        self.updatedAt = Date()
    }

    /// Add health goal
    func addGoal(_ goal: HealthGoal) {
        healthGoals.append(goal)
        updatedAt = Date()
    }

    /// Remove health goal
    func removeGoal(_ goalId: UUID) {
        healthGoals.removeAll { $0.id == goalId }
        updatedAt = Date()
    }

    /// Update privacy settings
    func updatePrivacy(level: PrivacyLevel) {
        self.privacyLevel = level
        self.updatedAt = Date()
    }
}

// MARK: - Supporting Types

/// Privacy level for user data
enum PrivacyLevel: String, Codable {
    case `private` = "private"
    case friendsOnly = "friends_only"
    case organization = "org_visible"
    case publicAnonymized = "public_anonymized"

    var description: String {
        switch self {
        case .private:
            return "Private (only you)"
        case .friendsOnly:
            return "Friends only"
        case .organization:
            return "Organization (anonymized)"
        case .publicAnonymized:
            return "Public (anonymized)"
        }
    }
}

/// Sharing preferences for different data types
struct SharingPreferences: Codable {
    var shareActivityData: Bool = false
    var shareBiometricData: Bool = false
    var shareGoalProgress: Bool = true
    var shareAchievements: Bool = true
    var shareChallengeParticipation: Bool = true
    var allowFriendRequests: Bool = true
    var showOnLeaderboards: Bool = true

    /// All sharing disabled (maximum privacy)
    static var allDisabled: SharingPreferences {
        SharingPreferences(
            shareActivityData: false,
            shareBiometricData: false,
            shareGoalProgress: false,
            shareAchievements: false,
            shareChallengeParticipation: false,
            allowFriendRequests: false,
            showOnLeaderboards: false
        )
    }

    /// All sharing enabled
    static var allEnabled: SharingPreferences {
        SharingPreferences(
            shareActivityData: true,
            shareBiometricData: true,
            shareGoalProgress: true,
            shareAchievements: true,
            shareChallengeParticipation: true,
            allowFriendRequests: true,
            showOnLeaderboards: true
        )
    }
}
