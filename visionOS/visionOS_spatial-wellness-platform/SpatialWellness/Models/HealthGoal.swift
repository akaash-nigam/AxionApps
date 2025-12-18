//
//  HealthGoal.swift
//  SpatialWellness
//
//  Created by Claude on 2025-11-17.
//  Copyright © 2025 Spatial Wellness Platform. All rights reserved.
//

import Foundation
import SwiftData

/// Health goal model representing user wellness objectives
/// Tracks progress toward fitness, nutrition, sleep, and other health targets
@Model
final class HealthGoal: Identifiable {

    // MARK: - Properties

    /// Unique identifier
    @Attribute(.unique) var id: UUID

    /// User ID (foreign key)
    var userId: UUID

    /// Goal title
    var title: String

    /// Detailed description
    var goalDescription: String

    /// Goal category
    var category: GoalCategory

    /// Target value to achieve
    var targetValue: Double

    /// Current progress value
    var currentValue: Double

    /// Unit of measurement
    var unit: String

    /// Goal start date
    var startDate: Date

    /// Target completion date
    var targetDate: Date

    /// How often to track (daily, weekly, etc.)
    var frequency: GoalFrequency

    /// Current status
    var status: GoalStatus

    /// Milestones along the way
    var milestones: [Milestone]

    /// Reminder settings
    var reminderEnabled: Bool

    /// Reminder time
    var reminderTime: Date?

    /// Created timestamp
    var createdAt: Date

    /// Last updated timestamp
    var updatedAt: Date

    // MARK: - Initialization

    init(
        id: UUID = UUID(),
        userId: UUID,
        title: String,
        goalDescription: String,
        category: GoalCategory,
        targetValue: Double,
        currentValue: Double = 0,
        unit: String,
        startDate: Date = Date(),
        targetDate: Date,
        frequency: GoalFrequency = .daily,
        status: GoalStatus = .active,
        milestones: [Milestone] = [],
        reminderEnabled: Bool = false,
        reminderTime: Date? = nil
    ) {
        self.id = id
        self.userId = userId
        self.title = title
        self.goalDescription = goalDescription
        self.category = category
        self.targetValue = targetValue
        self.currentValue = currentValue
        self.unit = unit
        self.startDate = startDate
        self.targetDate = targetDate
        self.frequency = frequency
        self.status = status
        self.milestones = milestones
        self.reminderEnabled = reminderEnabled
        self.reminderTime = reminderTime
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    // MARK: - Computed Properties

    /// Progress as percentage (0-100)
    var progressPercentage: Double {
        guard targetValue > 0 else { return 0 }
        let progress = (currentValue / targetValue) * 100
        return min(progress, 100)
    }

    /// Remaining value to reach goal
    var remainingValue: Double {
        max(targetValue - currentValue, 0)
    }

    /// Days remaining until target date
    var daysRemaining: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: Date(), to: targetDate)
        return components.day ?? 0
    }

    /// Whether goal is overdue
    var isOverdue: Bool {
        Date() > targetDate && status != .completed
    }

    /// Whether goal is completed
    var isCompleted: Bool {
        status == .completed || currentValue >= targetValue
    }

    /// Next milestone to achieve
    var nextMilestone: Milestone? {
        milestones.first { $0.achievedDate == nil && currentValue < $0.targetValue }
    }

    /// Completed milestones count
    var completedMilestonesCount: Int {
        milestones.filter { $0.achievedDate != nil }.count
    }

    /// Daily target (for daily goals)
    var dailyTarget: Double {
        let daysInPeriod = max(Double(daysRemaining), 1)
        return remainingValue / daysInPeriod
    }

    // MARK: - Methods

    /// Update progress
    func updateProgress(_ newValue: Double) {
        currentValue = newValue
        updatedAt = Date()

        // Check milestones
        checkMilestones()

        // Auto-complete if target reached
        if currentValue >= targetValue && status == .active {
            complete()
        }
    }

    /// Increment progress by amount
    func incrementProgress(by amount: Double) {
        updateProgress(currentValue + amount)
    }

    /// Check and mark achieved milestones
    private func checkMilestones() {
        for i in 0..<milestones.count {
            if milestones[i].achievedDate == nil &&
               currentValue >= milestones[i].targetValue {
                milestones[i].achievedDate = Date()
            }
        }
    }

    /// Mark goal as completed
    func complete() {
        status = .completed
        currentValue = targetValue
        updatedAt = Date()
    }

    /// Pause goal
    func pause() {
        status = .paused
        updatedAt = Date()
    }

    /// Resume goal
    func resume() {
        status = .active
        updatedAt = Date()
    }

    /// Abandon goal
    func abandon() {
        status = .abandoned
        updatedAt = Date()
    }

    /// Add milestone
    func addMilestone(_ milestone: Milestone) {
        milestones.append(milestone)
        milestones.sort { $0.targetValue < $1.targetValue }
        updatedAt = Date()
    }

    /// Remove milestone
    func removeMilestone(_ milestoneId: UUID) {
        milestones.removeAll { $0.id == milestoneId }
        updatedAt = Date()
    }
}

// MARK: - Goal Category

enum GoalCategory: String, Codable, CaseIterable, Identifiable {
    var id: String { rawValue }

    case fitness
    case nutrition
    case sleep
    case stress
    case weight
    case mindfulness
    case social
    case hydration

    var displayName: String {
        rawValue.capitalized
    }

    var iconName: String {
        switch self {
        case .fitness:
            return "figure.run"
        case .nutrition:
            return "fork.knife"
        case .sleep:
            return "bed.double.fill"
        case .stress:
            return "brain.head.profile"
        case .weight:
            return "scalemass.fill"
        case .mindfulness:
            return "figure.mind.and.body"
        case .social:
            return "person.2.fill"
        case .hydration:
            return "drop.fill"
        }
    }

    var color: String {
        switch self {
        case .fitness:
            return "red"
        case .nutrition:
            return "green"
        case .sleep:
            return "purple"
        case .stress:
            return "orange"
        case .weight:
            return "blue"
        case .mindfulness:
            return "indigo"
        case .social:
            return "pink"
        case .hydration:
            return "cyan"
        }
    }
}

// MARK: - Goal Frequency

enum GoalFrequency: String, Codable {
    case daily
    case weekly
    case monthly
    case oneTime

    var displayName: String {
        switch self {
        case .daily:
            return "Daily"
        case .weekly:
            return "Weekly"
        case .monthly:
            return "Monthly"
        case .oneTime:
            return "One-Time"
        }
    }
}

// MARK: - Goal Status

enum GoalStatus: String, Codable {
    case active
    case paused
    case completed
    case abandoned

    var displayName: String {
        rawValue.capitalized
    }

    var emoji: String {
        switch self {
        case .active:
            return "🎯"
        case .paused:
            return "⏸️"
        case .completed:
            return "✅"
        case .abandoned:
            return "❌"
        }
    }
}

// MARK: - Milestone

struct Milestone: Identifiable, Codable {
    var id: UUID = UUID()
    var title: String
    var targetValue: Double
    var achievedDate: Date?
    var rewardPoints: Int = 0

    var isAchieved: Bool {
        achievedDate != nil
    }

    /// Create preset milestones for a goal
    static func createPresets(for targetValue: Double, count: Int = 4) -> [Milestone] {
        guard count > 0 else { return [] }

        let increment = targetValue / Double(count + 1)
        var milestones: [Milestone] = []

        for i in 1...count {
            let value = increment * Double(i)
            let percentage = Int((value / targetValue) * 100)
            milestones.append(Milestone(
                title: "\(percentage)% Complete",
                targetValue: value,
                rewardPoints: 10 * i
            ))
        }

        return milestones
    }
}

// MARK: - Preset Goals

extension HealthGoal {
    /// Common preset goals
    static func presetGoals(for userId: UUID) -> [HealthGoal] {
        let oneMonthFromNow = Calendar.current.date(byAdding: .month, value: 1, to: Date())!

        return [
            // Fitness: 10,000 steps daily
            HealthGoal(
                userId: userId,
                title: "10,000 Steps Daily",
                goalDescription: "Walk 10,000 steps every day for better cardiovascular health",
                category: .fitness,
                targetValue: 10000,
                unit: "steps",
                targetDate: oneMonthFromNow,
                frequency: .daily,
                milestones: Milestone.createPresets(for: 10000)
            ),

            // Sleep: 8 hours nightly
            HealthGoal(
                userId: userId,
                title: "8 Hours of Sleep",
                goalDescription: "Get 8 hours of quality sleep each night",
                category: .sleep,
                targetValue: 8,
                unit: "hours",
                targetDate: oneMonthFromNow,
                frequency: .daily
            ),

            // Mindfulness: 10 minutes daily
            HealthGoal(
                userId: userId,
                title: "Daily Meditation",
                goalDescription: "Practice mindfulness for 10 minutes every day",
                category: .mindfulness,
                targetValue: 10,
                unit: "minutes",
                targetDate: oneMonthFromNow,
                frequency: .daily
            ),

            // Hydration: 8 glasses daily
            HealthGoal(
                userId: userId,
                title: "Stay Hydrated",
                goalDescription: "Drink 8 glasses of water daily",
                category: .hydration,
                targetValue: 8,
                unit: "glasses",
                targetDate: oneMonthFromNow,
                frequency: .daily
            )
        ]
    }
}
