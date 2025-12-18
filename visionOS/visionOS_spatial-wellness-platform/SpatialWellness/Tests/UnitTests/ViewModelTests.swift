//
//  ViewModelTests.swift
//  SpatialWellnessTests
//
//  Created by Claude on 2025-11-17.
//  Copyright © 2025 Spatial Wellness Platform. All rights reserved.
//

import XCTest
@testable import SpatialWellness

/// Unit tests for ViewModels
@MainActor
final class ViewModelTests: XCTestCase {

    // MARK: - DashboardViewModel Tests

    func testDashboardViewModelInitialization() {
        // Given
        let viewModel = DashboardViewModel()

        // Then
        XCTAssertEqual(viewModel.heartRateValue, "72")
        XCTAssertEqual(viewModel.heartRateStatus, .optimal)
        XCTAssertEqual(viewModel.stepsValue, "8,543")
        XCTAssertEqual(viewModel.dailyGoals.count, 0)
        XCTAssertNil(viewModel.topInsight)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
    }

    func testLoadDashboard() async {
        // Given
        let viewModel = DashboardViewModel()
        let userId = UUID()

        // When
        await viewModel.loadDashboard(userId: userId)

        // Then
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertEqual(viewModel.dailyGoals.count, 3) // Sample data creates 3 goals
        XCTAssertNotNil(viewModel.topInsight)
        XCTAssertEqual(viewModel.topInsight?.category, .sleep)
    }

    func testUpdateMetricFromBiometricReading() {
        // Given
        let viewModel = DashboardViewModel()
        let heartRateReading = BiometricReading(
            userId: UUID(),
            type: .heartRate,
            value: 85.0,
            unit: "BPM"
        )

        // When
        viewModel.updateMetric(heartRateReading)

        // Then
        XCTAssertEqual(viewModel.heartRateValue, "85")
        XCTAssertEqual(viewModel.heartRateStatus, .optimal)
    }

    func testUpdateMetricWithSteps() {
        // Given
        let viewModel = DashboardViewModel()
        let stepsReading = BiometricReading(
            userId: UUID(),
            type: .stepCount,
            value: 10250.0,
            unit: "steps"
        )

        // When
        viewModel.updateMetric(stepsReading)

        // Then
        XCTAssertEqual(viewModel.stepsValue, "10,250")
    }

    func testUpdateMetricWithStress() {
        // Given
        let viewModel = DashboardViewModel()
        let stressReading = BiometricReading(
            userId: UUID(),
            type: .stressLevel,
            value: 8.0,
            unit: "level"
        )

        // When
        viewModel.updateMetric(stressReading)

        // Then
        XCTAssertEqual(viewModel.stressValue, "8")
        XCTAssertEqual(viewModel.stressStatus, .warning)
    }

    func testUpdateGoal() {
        // Given
        let viewModel = DashboardViewModel()
        let goal = HealthGoal(
            userId: UUID(),
            title: "Test Goal",
            goalDescription: "Test Description",
            category: .fitness,
            targetValue: 100,
            currentValue: 50,
            unit: "units",
            targetDate: Date()
        )

        // When
        viewModel.updateGoal(goal)

        // Then
        XCTAssertEqual(viewModel.dailyGoals.count, 1)
        XCTAssertEqual(viewModel.dailyGoals.first?.id, goal.id)
        XCTAssertEqual(viewModel.dailyGoals.first?.currentValue, 50)
    }

    func testUpdateExistingGoal() {
        // Given
        let viewModel = DashboardViewModel()
        var goal = HealthGoal(
            userId: UUID(),
            title: "Test Goal",
            goalDescription: "Test Description",
            category: .fitness,
            targetValue: 100,
            currentValue: 50,
            unit: "units",
            targetDate: Date()
        )

        viewModel.updateGoal(goal)
        XCTAssertEqual(viewModel.dailyGoals.first?.currentValue, 50)

        // When - Update the same goal
        goal.currentValue = 75
        viewModel.updateGoal(goal)

        // Then
        XCTAssertEqual(viewModel.dailyGoals.count, 1) // Still only 1 goal
        XCTAssertEqual(viewModel.dailyGoals.first?.currentValue, 75) // Updated value
    }

    func testRemoveGoal() {
        // Given
        let viewModel = DashboardViewModel()
        let goal = HealthGoal(
            userId: UUID(),
            title: "Test Goal",
            goalDescription: "Test Description",
            category: .fitness,
            targetValue: 100,
            unit: "units",
            targetDate: Date()
        )

        viewModel.updateGoal(goal)
        XCTAssertEqual(viewModel.dailyGoals.count, 1)

        // When
        viewModel.removeGoal(goal.id)

        // Then
        XCTAssertEqual(viewModel.dailyGoals.count, 0)
    }

    func testRefresh() async {
        // Given
        let viewModel = DashboardViewModel()
        let userId = UUID()

        // When
        await viewModel.refresh(userId: userId)

        // Then
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertEqual(viewModel.dailyGoals.count, 3)
        XCTAssertNotNil(viewModel.topInsight)
    }
}

// MARK: - AppState Tests

final class AppStateTests: XCTestCase {

    func testAppStateInitialization() {
        // Given
        let appState = AppState()

        // Then
        XCTAssertNil(appState.currentUser)
        XCTAssertFalse(appState.isAuthenticated)
        XCTAssertEqual(appState.selectedTab, .dashboard)
        XCTAssertNil(appState.activeWindow)
        XCTAssertFalse(appState.immersiveSpaceActive)
        XCTAssertEqual(appState.latestBiometrics.count, 0)
        XCTAssertEqual(appState.currentGoals.count, 0)
        XCTAssertEqual(appState.activeChallenges.count, 0)
        XCTAssertEqual(appState.notifications.count, 0)
        XCTAssertFalse(appState.isLoading)
        XCTAssertNil(appState.errorMessage)
    }

    func testAuthenticate() {
        // Given
        let appState = AppState()
        let user = UserProfile(
            firstName: "John",
            lastName: "Doe",
            email: "john@example.com",
            dateOfBirth: Date()
        )

        // When
        appState.authenticate(user: user)

        // Then
        XCTAssertNotNil(appState.currentUser)
        XCTAssertTrue(appState.isAuthenticated)
        XCTAssertEqual(appState.currentUser?.firstName, "John")
        XCTAssertFalse(appState.showingOnboarding)
    }

    func testSignOut() {
        // Given
        let appState = AppState()
        let user = UserProfile(
            firstName: "John",
            lastName: "Doe",
            email: "john@example.com",
            dateOfBirth: Date()
        )
        appState.authenticate(user: user)
        appState.latestBiometrics[.heartRate] = BiometricReading(
            userId: user.id,
            type: .heartRate,
            value: 72,
            unit: "BPM"
        )

        // When
        appState.signOut()

        // Then
        XCTAssertNil(appState.currentUser)
        XCTAssertFalse(appState.isAuthenticated)
        XCTAssertEqual(appState.latestBiometrics.count, 0)
        XCTAssertEqual(appState.currentGoals.count, 0)
    }

    func testUpdateBiometric() {
        // Given
        let appState = AppState()
        let reading = BiometricReading(
            userId: UUID(),
            type: .heartRate,
            value: 75,
            unit: "BPM"
        )

        // When
        appState.updateBiometric(reading)

        // Then
        XCTAssertEqual(appState.latestBiometrics.count, 1)
        XCTAssertEqual(appState.latestBiometrics[.heartRate]?.value, 75)
    }

    func testUpdateMultipleBiometrics() {
        // Given
        let appState = AppState()
        let heartRate = BiometricReading(userId: UUID(), type: .heartRate, value: 75, unit: "BPM")
        let steps = BiometricReading(userId: UUID(), type: .stepCount, value: 8543, unit: "steps")

        // When
        appState.updateBiometric(heartRate)
        appState.updateBiometric(steps)

        // Then
        XCTAssertEqual(appState.latestBiometrics.count, 2)
        XCTAssertEqual(appState.latestBiometrics[.heartRate]?.value, 75)
        XCTAssertEqual(appState.latestBiometrics[.stepCount]?.value, 8543)
    }

    func testAddNotification() {
        // Given
        let appState = AppState()
        let notification = WellnessNotification(
            title: "Goal Achieved",
            message: "You reached 10,000 steps!",
            type: .goalAchieved,
            timestamp: Date()
        )

        // When
        appState.addNotification(notification)

        // Then
        XCTAssertEqual(appState.notifications.count, 1)
        XCTAssertEqual(appState.notificationCount, 1) // Unread count
        XCTAssertEqual(appState.notifications.first?.title, "Goal Achieved")
    }

    func testMarkNotificationRead() {
        // Given
        let appState = AppState()
        let notification = WellnessNotification(
            title: "Test",
            message: "Message",
            type: .reminder,
            timestamp: Date()
        )
        appState.addNotification(notification)
        XCTAssertEqual(appState.notificationCount, 1)

        // When
        appState.markNotificationRead(notification.id)

        // Then
        XCTAssertEqual(appState.notificationCount, 0) // No unread notifications
        XCTAssertTrue(appState.notifications.first?.isRead ?? false)
    }

    func testClearNotifications() {
        // Given
        let appState = AppState()
        let notification1 = WellnessNotification(title: "1", message: "1", type: .reminder, timestamp: Date())
        let notification2 = WellnessNotification(title: "2", message: "2", type: .reminder, timestamp: Date())
        appState.addNotification(notification1)
        appState.addNotification(notification2)
        XCTAssertEqual(appState.notifications.count, 2)

        // When
        appState.clearNotifications()

        // Then
        XCTAssertEqual(appState.notifications.count, 0)
    }

    func testEnterImmersiveSpace() {
        // Given
        let appState = AppState()

        // When
        appState.enterImmersiveSpace(.meditation)

        // Then
        XCTAssertTrue(appState.immersiveSpaceActive)
        XCTAssertEqual(appState.currentImmersiveSpace, .meditation)
    }

    func testExitImmersiveSpace() {
        // Given
        let appState = AppState()
        appState.enterImmersiveSpace(.meditation)
        appState.immersionLevel = 0.75

        // When
        appState.exitImmersiveSpace()

        // Then
        XCTAssertFalse(appState.immersiveSpaceActive)
        XCTAssertNil(appState.currentImmersiveSpace)
        XCTAssertEqual(appState.immersionLevel, 0.0)
    }

    func testShowError() {
        // Given
        let appState = AppState()

        // When
        appState.showError("Test error message")

        // Then
        XCTAssertEqual(appState.errorMessage, "Test error message")
    }

    func testClearError() {
        // Given
        let appState = AppState()
        appState.showError("Test error")

        // When
        appState.clearError()

        // Then
        XCTAssertNil(appState.errorMessage)
    }

    func testNotificationCount() {
        // Given
        let appState = AppState()

        // Add 3 notifications
        appState.addNotification(WellnessNotification(title: "1", message: "1", type: .reminder, timestamp: Date()))
        appState.addNotification(WellnessNotification(title: "2", message: "2", type: .reminder, timestamp: Date()))
        appState.addNotification(WellnessNotification(title: "3", message: "3", type: .reminder, timestamp: Date()))

        // Then
        XCTAssertEqual(appState.notificationCount, 3)

        // Mark one as read
        appState.markNotificationRead(appState.notifications[0].id)

        // Then
        XCTAssertEqual(appState.notificationCount, 2)
    }
}

// MARK: - Activity Summary Tests

final class ActivitySummaryTests: XCTestCase {

    func testActivitySummaryStepProgress() {
        // Given
        let summary = ActivitySummary(
            date: Date(),
            steps: 8543,
            activeMinutes: 45,
            caloriesBurned: 450,
            distanceMeters: 6500,
            floorsClimbed: 10
        )

        // When
        let progress = summary.stepGoalProgress

        // Then
        XCTAssertEqual(progress, 0.8543, accuracy: 0.0001)
    }

    func testActivitySummaryActiveMinutesProgress() {
        // Given
        let summary = ActivitySummary(
            date: Date(),
            steps: 10000,
            activeMinutes: 30,
            caloriesBurned: 500,
            distanceMeters: 8000,
            floorsClimbed: 12
        )

        // When
        let progress = summary.activeMinutesProgress

        // Then
        XCTAssertEqual(progress, 1.0, accuracy: 0.01)
    }
}

// MARK: - Health Insight Tests

final class HealthInsightTests: XCTestCase {

    func testHealthInsightInitialization() {
        // Given
        let insight = HealthInsight(
            title: "Sleep Improved",
            message: "Your sleep quality is up 15%",
            category: .sleep,
            priority: .medium,
            timestamp: Date(),
            actionable: true,
            actionTitle: "View Details"
        )

        // Then
        XCTAssertEqual(insight.title, "Sleep Improved")
        XCTAssertEqual(insight.category, .sleep)
        XCTAssertEqual(insight.priority, .medium)
        XCTAssertTrue(insight.actionable)
        XCTAssertNotNil(insight.actionTitle)
    }
}

// MARK: - Performance Tests

final class PerformanceTests: XCTestCase {

    func testBiometricCreationPerformance() {
        measure {
            for _ in 0..<1000 {
                let _ = BiometricReading(
                    userId: UUID(),
                    type: .heartRate,
                    value: Double.random(in: 60...100),
                    unit: "BPM"
                )
            }
        }
    }

    func testActivityCreationPerformance() {
        measure {
            for _ in 0..<1000 {
                let _ = Activity(
                    userId: UUID(),
                    type: .running,
                    startTime: Date(),
                    durationSeconds: 3600
                )
            }
        }
    }

    func testGoalProgressCalculationPerformance() {
        let goals = (0..<100).map { i in
            HealthGoal(
                userId: UUID(),
                title: "Goal \(i)",
                goalDescription: "Description",
                category: .fitness,
                targetValue: 10000,
                currentValue: Double.random(in: 0...10000),
                unit: "units",
                targetDate: Date()
            )
        }

        measure {
            for var goal in goals {
                let _ = goal.progressPercentage
                let _ = goal.remainingValue
                let _ = goal.isCompleted
            }
        }
    }
}
