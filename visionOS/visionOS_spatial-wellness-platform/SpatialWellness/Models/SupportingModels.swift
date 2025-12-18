//
//  SupportingModels.swift
//  SpatialWellness
//
//  Created by Claude on 2025-11-17.
//  Copyright © 2025 Spatial Wellness Platform. All rights reserved.
//

import Foundation
import SwiftData

// MARK: - Challenge

/// Challenge model for social wellness competitions
@Model
final class Challenge: Identifiable {
    @Attribute(.unique) var id: UUID
    var title: String
    var challengeDescription: String
    var creatorId: UUID
    var type: ChallengeType
    var category: ActivityType
    var startDate: Date
    var endDate: Date
    var isPublic: Bool
    var organizationId: UUID?

    var isActive: Bool {
        let now = Date()
        return now >= startDate && now <= endDate
    }

    init(
        id: UUID = UUID(),
        title: String,
        challengeDescription: String,
        creatorId: UUID,
        type: ChallengeType = .individual,
        category: ActivityType = .walking,
        startDate: Date = Date(),
        endDate: Date,
        isPublic: Bool = true,
        organizationId: UUID? = nil
    ) {
        self.id = id
        self.title = title
        self.challengeDescription = challengeDescription
        self.creatorId = creatorId
        self.type = type
        self.category = category
        self.startDate = startDate
        self.endDate = endDate
        self.isPublic = isPublic
        self.organizationId = organizationId
    }
}

enum ChallengeType: String, Codable {
    case individual
    case team
    case organization
    case stepCompetition
    case meditationStreak
    case weightLoss
    case sleepQuality

    var displayName: String {
        switch self {
        case .individual: return "Individual"
        case .team: return "Team"
        case .organization: return "Organization"
        case .stepCompetition: return "Step Competition"
        case .meditationStreak: return "Meditation Streak"
        case .weightLoss: return "Weight Loss"
        case .sleepQuality: return "Sleep Quality"
        }
    }
}

// MARK: - Achievement

/// Achievement model for gamification
@Model
final class Achievement: Identifiable {
    @Attribute(.unique) var id: UUID
    var userId: UUID
    var title: String
    var achievementDescription: String
    var category: AchievementCategory
    var earnedDate: Date
    var points: Int
    var iconName: String
    var badgeLevel: BadgeLevel

    init(
        id: UUID = UUID(),
        userId: UUID,
        title: String,
        achievementDescription: String,
        category: AchievementCategory,
        earnedDate: Date = Date(),
        points: Int = 10,
        iconName: String = "star.fill",
        badgeLevel: BadgeLevel = .bronze
    ) {
        self.id = id
        self.userId = userId
        self.title = title
        self.achievementDescription = achievementDescription
        self.category = category
        self.earnedDate = earnedDate
        self.points = points
        self.iconName = iconName
        self.badgeLevel = badgeLevel
    }
}

enum AchievementCategory: String, Codable {
    case fitness
    case mindfulness
    case social
    case consistency
    case milestone

    var displayName: String {
        rawValue.capitalized
    }
}

enum BadgeLevel: String, Codable {
    case bronze
    case silver
    case gold
    case platinum

    var displayName: String {
        rawValue.capitalized
    }

    var emoji: String {
        switch self {
        case .bronze: return "🥉"
        case .silver: return "🥈"
        case .gold: return "🥇"
        case .platinum: return "💎"
        }
    }
}

// MARK: - WellnessEnvironment

/// Wellness environment for immersive experiences
@Model
final class WellnessEnvironment: Identifiable {
    @Attribute(.unique) var id: UUID
    var name: String
    var environmentDescription: String
    var type: EnvironmentType
    var category: EnvironmentCategory
    var sceneBundleName: String
    var thumbnailAsset: String
    var durationSeconds: TimeInterval?
    var audioTrackName: String?
    var isAvailable: Bool
    var requiresDownload: Bool
    var fileSizeBytes: Int64?

    // Accessibility
    var hasAudioGuidance: Bool
    var hasHapticFeedback: Bool
    var motionIntensity: MotionIntensity

    init(
        id: UUID = UUID(),
        name: String,
        environmentDescription: String,
        type: EnvironmentType,
        category: EnvironmentCategory,
        sceneBundleName: String,
        thumbnailAsset: String,
        durationSeconds: TimeInterval? = nil,
        audioTrackName: String? = nil,
        isAvailable: Bool = true,
        requiresDownload: Bool = false,
        fileSizeBytes: Int64? = nil,
        hasAudioGuidance: Bool = false,
        hasHapticFeedback: Bool = false,
        motionIntensity: MotionIntensity = .low
    ) {
        self.id = id
        self.name = name
        self.environmentDescription = environmentDescription
        self.type = type
        self.category = category
        self.sceneBundleName = sceneBundleName
        self.thumbnailAsset = thumbnailAsset
        self.durationSeconds = durationSeconds
        self.audioTrackName = audioTrackName
        self.isAvailable = isAvailable
        self.requiresDownload = requiresDownload
        self.fileSizeBytes = fileSizeBytes
        self.hasAudioGuidance = hasAudioGuidance
        self.hasHapticFeedback = hasHapticFeedback
        self.motionIntensity = motionIntensity
    }
}

enum EnvironmentType: String, Codable {
    case meditation
    case exercise
    case relaxation
    case visualization
    case education
    case social

    var displayName: String {
        rawValue.capitalized
    }
}

enum EnvironmentCategory: String, Codable {
    case nature
    case abstract
    case architectural
    case underwater
    case cosmic
    case minimalist

    var displayName: String {
        rawValue.capitalized
    }
}

enum MotionIntensity: String, Codable {
    case none
    case low
    case medium
    case high

    var displayName: String {
        rawValue.capitalized
    }
}
