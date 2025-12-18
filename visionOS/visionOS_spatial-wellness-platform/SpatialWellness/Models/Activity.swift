//
//  Activity.swift
//  SpatialWellness
//
//  Created by Claude on 2025-11-17.
//  Copyright © 2025 Spatial Wellness Platform. All rights reserved.
//

import Foundation
import SwiftData

/// Activity model representing physical activities and wellness sessions
/// Tracks exercises, meditation, and other health activities
@Model
final class Activity {

    // MARK: - Properties

    /// Unique identifier
    @Attribute(.unique) var id: UUID

    /// User ID (foreign key)
    var userId: UUID

    /// Type of activity
    var type: ActivityType

    /// Activity start time
    var startTime: Date

    /// Activity end time (nil if active)
    var endTime: Date?

    /// Duration in seconds
    var durationSeconds: TimeInterval

    /// Calories burned during activity
    var caloriesBurned: Double

    /// Distance covered (if applicable, in meters)
    var distanceMeters: Double?

    /// Average heart rate during activity
    var averageHeartRate: Double?

    /// Maximum heart rate during activity
    var maxHeartRate: Double?

    /// Activity metadata (additional info)
    var metadata: ActivityMetadata

    /// Spatial space type used (if in app)
    var spaceType: SpatialSpaceType?

    /// Notes or comments about activity
    var notes: String?

    // MARK: - Initialization

    init(
        id: UUID = UUID(),
        userId: UUID,
        type: ActivityType,
        startTime: Date = Date(),
        durationSeconds: TimeInterval = 0,
        caloriesBurned: Double = 0,
        distanceMeters: Double? = nil,
        averageHeartRate: Double? = nil,
        maxHeartRate: Double? = nil,
        metadata: ActivityMetadata = ActivityMetadata(),
        spaceType: SpatialSpaceType? = nil,
        notes: String? = nil
    ) {
        self.id = id
        self.userId = userId
        self.type = type
        self.startTime = startTime
        self.endTime = nil
        self.durationSeconds = durationSeconds
        self.caloriesBurned = caloriesBurned
        self.distanceMeters = distanceMeters
        self.averageHeartRate = averageHeartRate
        self.maxHeartRate = maxHeartRate
        self.metadata = metadata
        self.spaceType = spaceType
        self.notes = notes
    }

    // MARK: - Computed Properties

    /// Whether activity is currently active
    var isActive: Bool {
        endTime == nil
    }

    /// Duration in minutes
    var durationMinutes: Int {
        Int(durationSeconds / 60)
    }

    /// Duration formatted as string (HH:MM:SS)
    var formattedDuration: String {
        let hours = Int(durationSeconds) / 3600
        let minutes = (Int(durationSeconds) % 3600) / 60
        let seconds = Int(durationSeconds) % 60

        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%d:%02d", minutes, seconds)
        }
    }

    /// Distance in miles (if applicable)
    var distanceMiles: Double? {
        guard let meters = distanceMeters else { return nil }
        return meters * 0.000621371 // meters to miles
    }

    /// Formatted distance
    var formattedDistance: String? {
        guard let miles = distanceMiles else { return nil }
        return String(format: "%.2f mi", miles)
    }

    /// Average pace (min/mile) if applicable
    var averagePace: Double? {
        guard let miles = distanceMiles, miles > 0, durationSeconds > 0 else {
            return nil
        }
        return (durationSeconds / 60) / miles
    }

    /// Formatted pace
    var formattedPace: String? {
        guard let pace = averagePace else { return nil }
        let minutes = Int(pace)
        let seconds = Int((pace - Double(minutes)) * 60)
        return String(format: "%d:%02d /mi", minutes, seconds)
    }

    // MARK: - Methods

    /// Complete the activity
    func complete() {
        guard isActive else { return }
        endTime = Date()
        durationSeconds = endTime!.timeIntervalSince(startTime)
    }

    /// Update duration for active activity
    func updateDuration() {
        guard isActive else { return }
        durationSeconds = Date().timeIntervalSince(startTime)
    }

    /// Add companion to activity
    func addCompanion(_ companionId: UUID) {
        if metadata.companionIds == nil {
            metadata.companionIds = []
        }
        metadata.companionIds?.append(companionId)
    }
}

// MARK: - Activity Type

/// Types of activities
enum ActivityType: String, Codable, CaseIterable, Identifiable {
    var id: String { rawValue }

    // Cardio
    case walking
    case running
    case cycling
    case swimming
    case hiking

    // Strength
    case strengthTraining
    case weightlifting
    case calisthenics

    // Flexibility
    case yoga
    case pilates
    case stretching

    // Mind-Body
    case meditation
    case breathingExercise
    case tai chi

    // Sports
    case basketball
    case tennis
    case soccer
    case volleyball

    // Group
    case teamChallenge
    case groupClass

    // Other
    case posturePractice
    case other

    var displayName: String {
        switch self {
        case .walking:
            return "Walking"
        case .running:
            return "Running"
        case .cycling:
            return "Cycling"
        case .swimming:
            return "Swimming"
        case .hiking:
            return "Hiking"
        case .strengthTraining:
            return "Strength Training"
        case .weightlifting:
            return "Weightlifting"
        case .calisthenics:
            return "Calisthenics"
        case .yoga:
            return "Yoga"
        case .pilates:
            return "Pilates"
        case .stretching:
            return "Stretching"
        case .meditation:
            return "Meditation"
        case .breathingExercise:
            return "Breathing Exercise"
        case .taiChi:
            return "Tai Chi"
        case .basketball:
            return "Basketball"
        case .tennis:
            return "Tennis"
        case .soccer:
            return "Soccer"
        case .volleyball:
            return "Volleyball"
        case .teamChallenge:
            return "Team Challenge"
        case .groupClass:
            return "Group Class"
        case .posturePractice:
            return "Posture Practice"
        case .other:
            return "Other"
        }
    }

    var iconName: String {
        switch self {
        case .walking:
            return "figure.walk"
        case .running:
            return "figure.run"
        case .cycling:
            return "bicycle"
        case .swimming:
            return "figure.pool.swim"
        case .hiking:
            return "mountain.2.fill"
        case .strengthTraining, .weightlifting:
            return "dumbbell.fill"
        case .calisthenics:
            return "figure.strengthtraining.traditional"
        case .yoga, .pilates, .stretching:
            return "figure.mind.and.body"
        case .meditation, .breathingExercise:
            return "figure.meditation"
        case .taiChi:
            return "figure.tai.chi"
        case .basketball:
            return "basketball.fill"
        case .tennis:
            return "tennis.racket"
        case .soccer:
            return "soccerball"
        case .volleyball:
            return "volleyball.fill"
        case .teamChallenge:
            return "person.3.fill"
        case .groupClass:
            return "person.2.fill"
        case .posturePractice:
            return "figure.stand"
        case .other:
            return "figure.mixed.cardio"
        }
    }

    var category: ActivityCategory {
        switch self {
        case .walking, .running, .cycling, .swimming, .hiking:
            return .cardio
        case .strengthTraining, .weightlifting, .calisthenics:
            return .strength
        case .yoga, .pilates, .stretching:
            return .flexibility
        case .meditation, .breathingExercise, .taiChi:
            return .mindBody
        case .basketball, .tennis, .soccer, .volleyball:
            return .sports
        case .teamChallenge, .groupClass:
            return .social
        case .posturePractice, .other:
            return .other
        }
    }

    /// Average calories burned per minute (estimate)
    var caloriesPerMinute: Double {
        switch self {
        case .walking:
            return 3.5
        case .running:
            return 10.0
        case .cycling:
            return 7.5
        case .swimming:
            return 9.0
        case .hiking:
            return 6.0
        case .strengthTraining, .weightlifting:
            return 6.0
        case .calisthenics:
            return 7.0
        case .yoga, .pilates:
            return 3.0
        case .stretching:
            return 2.0
        case .meditation, .breathingExercise:
            return 1.5
        case .taiChi:
            return 4.0
        case .basketball, .tennis, .soccer, .volleyball:
            return 8.0
        case .teamChallenge:
            return 7.0
        case .groupClass:
            return 6.0
        case .posturePractice:
            return 2.0
        case .other:
            return 5.0
        }
    }
}

// MARK: - Activity Category

enum ActivityCategory: String, Codable {
    case cardio
    case strength
    case flexibility
    case mindBody
    case sports
    case social
    case other

    var displayName: String {
        switch self {
        case .cardio:
            return "Cardio"
        case .strength:
            return "Strength"
        case .flexibility:
            return "Flexibility"
        case .mindBody:
            return "Mind & Body"
        case .sports:
            return "Sports"
        case .social:
            return "Social"
        case .other:
            return "Other"
        }
    }
}

// MARK: - Spatial Space Type

/// Type of spatial space used for activity
enum SpatialSpaceType: String, Codable {
    case window
    case volume
    case immersive

    var displayName: String {
        rawValue.capitalized
    }
}

// MARK: - Activity Metadata

/// Additional metadata for activities
struct ActivityMetadata: Codable {
    var locationName: String?
    var weatherConditions: String?
    var companionIds: [UUID]?
    var averageSpeed: Double?
    var elevationGain: Double?
    var equipmentUsed: [String]?
    var difficulty: ActivityDifficulty?
    var enjoymentRating: Int? // 1-5

    enum ActivityDifficulty: String, Codable {
        case easy, moderate, hard, expert

        var displayName: String {
            rawValue.capitalized
        }
    }
}
