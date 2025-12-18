//
//  DashboardViewModel.swift
//  SpatialWellness
//
//  Created by Claude on 2025-11-17.
//  Copyright © 2025 Spatial Wellness Platform. All rights reserved.
//

import Foundation
import Observation

/// ViewModel for Dashboard view
/// Manages health data, goals, and insights for the main dashboard
@Observable
class DashboardViewModel {

    // MARK: - Published Properties

    var heartRateValue: String = "72"
    var heartRateStatus: BiometricStatus = .optimal

    var stepsValue: String = "8,543"
    var stepsStatus: BiometricStatus = .normal

    var stressValue: String = "3"
    var stressStatus: BiometricStatus = .optimal

    var dailyGoals: [HealthGoal] = []
    var topInsight: HealthInsight?

    var isLoading: Bool = false
    var errorMessage: String?

    // MARK: - Methods

    /// Load dashboard data
    func loadDashboard(userId: UUID) async {
        isLoading = true
        defer { isLoading = false }

        // Simulate loading
        try? await Task.sleep(for: .seconds(0.5))

        // Load sample data
        await loadHealthMetrics(userId: userId)
        await loadDailyGoals(userId: userId)
        await loadInsights(userId: userId)
    }

    /// Load health metrics
    private func loadHealthMetrics(userId: UUID) async {
        // In real implementation, fetch from HealthKit/API
        // For now, using sample data

        heartRateValue = "72"
        heartRateStatus = .optimal

        stepsValue = "8,543"
        stepsStatus = .normal

        stressValue = "3"
        stressStatus = .optimal
    }

    /// Load daily goals
    private func loadDailyGoals(userId: UUID) async {
        // In real implementation, fetch from SwiftData
        // For now, create sample goals

        let stepsGoal = HealthGoal(
            userId: userId,
            title: "Steps",
            goalDescription: "Walk 10,000 steps today",
            category: .fitness,
            targetValue: 10000,
            currentValue: 8543,
            unit: "steps",
            targetDate: Date(),
            frequency: .daily
        )

        let hydrationGoal = HealthGoal(
            userId: userId,
            title: "Hydration",
            goalDescription: "Drink 8 glasses of water",
            category: .hydration,
            targetValue: 8,
            currentValue: 8,
            unit: "glasses",
            targetDate: Date(),
            frequency: .daily
        )

        let meditationGoal = HealthGoal(
            userId: userId,
            title: "Meditation",
            goalDescription: "Meditate for 10 minutes",
            category: .mindfulness,
            targetValue: 10,
            currentValue: 4,
            unit: "minutes",
            targetDate: Date(),
            frequency: .daily
        )

        dailyGoals = [stepsGoal, hydrationGoal, meditationGoal]
    }

    /// Load AI insights
    private func loadInsights(userId: UUID) async {
        // In real implementation, fetch from AI service
        // For now, create sample insight

        topInsight = HealthInsight(
            title: "Sleep Quality Improved",
            message: "Your sleep quality improved 15% this week. Consider maintaining your 10 PM bedtime to continue this positive trend.",
            category: .sleep,
            priority: .medium,
            timestamp: Date(),
            actionable: true,
            actionTitle: "View Sleep Trends"
        )
    }

    /// Refresh all data
    func refresh(userId: UUID) async {
        await loadDashboard(userId: userId)
    }

    /// Update health metric from biometric reading
    func updateMetric(_ reading: BiometricReading) {
        switch reading.type {
        case .heartRate:
            heartRateValue = String(format: "%.0f", reading.value)
            heartRateStatus = reading.status

        case .stepCount:
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            stepsValue = formatter.string(from: NSNumber(value: reading.value)) ?? "\(Int(reading.value))"
            stepsStatus = reading.status

        case .stressLevel:
            stressValue = String(format: "%.0f", reading.value)
            stressStatus = reading.status

        default:
            break
        }
    }

    /// Add or update goal
    func updateGoal(_ goal: HealthGoal) {
        if let index = dailyGoals.firstIndex(where: { $0.id == goal.id }) {
            dailyGoals[index] = goal
        } else {
            dailyGoals.append(goal)
        }
    }

    /// Remove goal
    func removeGoal(_ goalId: UUID) {
        dailyGoals.removeAll { $0.id == goalId }
    }
}
