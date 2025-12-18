//
//  ModelTests.swift
//  SpatialWellnessTests
//
//  Created by Claude on 2025-11-17.
//  Copyright © 2025 Spatial Wellness Platform. All rights reserved.
//

import XCTest
@testable import SpatialWellness

/// Unit tests for data models
final class ModelTests: XCTestCase {

    // MARK: - UserProfile Tests

    func testUserProfileInitialization() {
        // Given
        let userId = UUID()
        let firstName = "John"
        let lastName = "Doe"
        let email = "john.doe@example.com"
        let dateOfBirth = Date(timeIntervalSince1970: 0)

        // When
        let profile = UserProfile(
            id: userId,
            firstName: firstName,
            lastName: lastName,
            email: email,
            dateOfBirth: dateOfBirth
        )

        // Then
        XCTAssertEqual(profile.id, userId)
        XCTAssertEqual(profile.firstName, firstName)
        XCTAssertEqual(profile.lastName, lastName)
        XCTAssertEqual(profile.email, email)
        XCTAssertEqual(profile.dateOfBirth, dateOfBirth)
        XCTAssertEqual(profile.privacyLevel, .private)
    }

    func testUserProfileFullName() {
        // Given
        let profile = UserProfile(
            firstName: "Jane",
            lastName: "Smith",
            email: "jane@example.com",
            dateOfBirth: Date()
        )

        // When
        let fullName = profile.fullName

        // Then
        XCTAssertEqual(fullName, "Jane Smith")
    }

    func testUserProfileInitials() {
        // Given
        let profile = UserProfile(
            firstName: "Alice",
            lastName: "Brown",
            email: "alice@example.com",
            dateOfBirth: Date()
        )

        // When
        let initials = profile.initials

        // Then
        XCTAssertEqual(initials, "AB")
    }

    func testUserProfileUpdate() {
        // Given
        var profile = UserProfile(
            firstName: "Bob",
            lastName: "Jones",
            email: "bob@example.com",
            dateOfBirth: Date()
        )
        let originalUpdateTime = profile.updatedAt

        // Small delay to ensure updatedAt changes
        Thread.sleep(forTimeInterval: 0.01)

        // When
        profile.update(firstName: "Robert")

        // Then
        XCTAssertEqual(profile.firstName, "Robert")
        XCTAssertGreaterThan(profile.updatedAt, originalUpdateTime)
    }

    // MARK: - BiometricReading Tests

    func testBiometricReadingInitialization() {
        // Given
        let userId = UUID()
        let type = BiometricType.heartRate
        let value = 72.0
        let unit = "BPM"

        // When
        let reading = BiometricReading(
            userId: userId,
            type: type,
            value: value,
            unit: unit
        )

        // Then
        XCTAssertEqual(reading.userId, userId)
        XCTAssertEqual(reading.type, type)
        XCTAssertEqual(reading.value, value)
        XCTAssertEqual(reading.unit, unit)
        XCTAssertEqual(reading.source, .manualEntry)
        XCTAssertEqual(reading.confidence, 1.0)
    }

    func testBiometricReadingFormattedValue() {
        // Given
        let reading = BiometricReading(
            userId: UUID(),
            type: .heartRate,
            value: 72.5,
            unit: "BPM"
        )

        // When
        let formatted = reading.formattedValue

        // Then
        XCTAssertEqual(formatted, "72 BPM") // Heart rate has 0 decimal places
    }

    func testBiometricReadingStatus() {
        // Given
        let normalReading = BiometricReading(
            userId: UUID(),
            type: .heartRate,
            value: 75.0,
            unit: "BPM"
        )

        let highReading = BiometricReading(
            userId: UUID(),
            type: .heartRate,
            value: 125.0,
            unit: "BPM"
        )

        // When & Then
        XCTAssertEqual(normalReading.status, .optimal)
        XCTAssertEqual(highReading.status, .warning)
    }

    func testBiometricReadingIsRecent() {
        // Given - Reading from 30 minutes ago
        let recentReading = BiometricReading(
            timestamp: Date().addingTimeInterval(-1800),
            userId: UUID(),
            type: .heartRate,
            value: 72.0,
            unit: "BPM"
        )

        // Old reading from 2 hours ago
        let oldReading = BiometricReading(
            timestamp: Date().addingTimeInterval(-7200),
            userId: UUID(),
            type: .heartRate,
            value: 72.0,
            unit: "BPM"
        )

        // When & Then
        XCTAssertTrue(recentReading.isRecent())
        XCTAssertFalse(oldReading.isRecent())
    }

    // MARK: - Activity Tests

    func testActivityInitialization() {
        // Given
        let userId = UUID()
        let type = ActivityType.running
        let startTime = Date()

        // When
        let activity = Activity(
            userId: userId,
            type: type,
            startTime: startTime
        )

        // Then
        XCTAssertEqual(activity.userId, userId)
        XCTAssertEqual(activity.type, type)
        XCTAssertEqual(activity.startTime, startTime)
        XCTAssertNil(activity.endTime)
        XCTAssertTrue(activity.isActive)
    }

    func testActivityComplete() {
        // Given
        var activity = Activity(
            userId: UUID(),
            type: .running,
            startTime: Date().addingTimeInterval(-3600) // 1 hour ago
        )

        // When
        activity.complete()

        // Then
        XCTAssertFalse(activity.isActive)
        XCTAssertNotNil(activity.endTime)
        XCTAssertGreaterThan(activity.durationSeconds, 3500) // Approximately 1 hour
    }

    func testActivityFormattedDuration() {
        // Given
        var activity = Activity(
            userId: UUID(),
            type: .walking,
            durationSeconds: 3665 // 1 hour, 1 minute, 5 seconds
        )

        // When
        let formatted = activity.formattedDuration

        // Then
        XCTAssertEqual(formatted, "1:01:05")
    }

    func testActivityDistanceConversion() {
        // Given
        var activity = Activity(
            userId: UUID(),
            type: .running,
            distanceMeters: 1609.34 // 1 mile
        )

        // When
        let miles = activity.distanceMiles

        // Then
        XCTAssertNotNil(miles)
        XCTAssertEqual(miles!, 1.0, accuracy: 0.01)
    }

    // MARK: - HealthGoal Tests

    func testHealthGoalInitialization() {
        // Given
        let userId = UUID()
        let title = "10,000 Steps"
        let targetValue = 10000.0

        // When
        let goal = HealthGoal(
            userId: userId,
            title: title,
            goalDescription: "Walk 10,000 steps daily",
            category: .fitness,
            targetValue: targetValue,
            unit: "steps",
            targetDate: Date()
        )

        // Then
        XCTAssertEqual(goal.userId, userId)
        XCTAssertEqual(goal.title, title)
        XCTAssertEqual(goal.targetValue, targetValue)
        XCTAssertEqual(goal.currentValue, 0)
        XCTAssertEqual(goal.status, .active)
    }

    func testHealthGoalProgressPercentage() {
        // Given
        var goal = HealthGoal(
            userId: UUID(),
            title: "Steps",
            goalDescription: "Daily steps",
            category: .fitness,
            targetValue: 10000,
            currentValue: 7500,
            unit: "steps",
            targetDate: Date()
        )

        // When
        let progress = goal.progressPercentage

        // Then
        XCTAssertEqual(progress, 75.0, accuracy: 0.1)
    }

    func testHealthGoalRemainingValue() {
        // Given
        var goal = HealthGoal(
            userId: UUID(),
            title: "Steps",
            goalDescription: "Daily steps",
            category: .fitness,
            targetValue: 10000,
            currentValue: 7500,
            unit: "steps",
            targetDate: Date()
        )

        // When
        let remaining = goal.remainingValue

        // Then
        XCTAssertEqual(remaining, 2500, accuracy: 0.1)
    }

    func testHealthGoalCompletion() {
        // Given
        var goal = HealthGoal(
            userId: UUID(),
            title: "Steps",
            goalDescription: "Daily steps",
            category: .fitness,
            targetValue: 10000,
            unit: "steps",
            targetDate: Date()
        )

        // When
        goal.updateProgress(10000)

        // Then
        XCTAssertTrue(goal.isCompleted)
        XCTAssertEqual(goal.status, .completed)
    }

    func testHealthGoalAutoCompletion() {
        // Given
        var goal = HealthGoal(
            userId: UUID(),
            title: "Steps",
            goalDescription: "Daily steps",
            category: .fitness,
            targetValue: 10000,
            unit: "steps",
            targetDate: Date()
        )

        // When
        goal.updateProgress(10500) // Exceed target

        // Then
        XCTAssertTrue(goal.isCompleted)
        XCTAssertEqual(goal.status, .completed)
    }

    func testHealthGoalIncrementProgress() {
        // Given
        var goal = HealthGoal(
            userId: UUID(),
            title: "Steps",
            goalDescription: "Daily steps",
            category: .fitness,
            targetValue: 10000,
            currentValue: 5000,
            unit: "steps",
            targetDate: Date()
        )

        // When
        goal.incrementProgress(by: 2500)

        // Then
        XCTAssertEqual(goal.currentValue, 7500, accuracy: 0.1)
    }

    // MARK: - Milestone Tests

    func testMilestonePresetCreation() {
        // Given
        let targetValue = 10000.0
        let milestoneCount = 4

        // When
        let milestones = Milestone.createPresets(for: targetValue, count: milestoneCount)

        // Then
        XCTAssertEqual(milestones.count, milestoneCount)
        XCTAssertEqual(milestones[0].targetValue, 2500, accuracy: 0.1) // 25%
        XCTAssertEqual(milestones[1].targetValue, 5000, accuracy: 0.1) // 50%
        XCTAssertEqual(milestones[2].targetValue, 7500, accuracy: 0.1) // 75%
        XCTAssertEqual(milestones[3].targetValue, 10000, accuracy: 0.1) // 100%
    }

    // MARK: - BiometricType Tests

    func testBiometricTypeDisplayNames() {
        XCTAssertEqual(BiometricType.heartRate.displayName, "Heart Rate")
        XCTAssertEqual(BiometricType.stepCount.displayName, "Steps")
        XCTAssertEqual(BiometricType.sleepDuration.displayName, "Sleep Duration")
    }

    func testBiometricTypeDefaultUnits() {
        XCTAssertEqual(BiometricType.heartRate.defaultUnit, "BPM")
        XCTAssertEqual(BiometricType.stepCount.defaultUnit, "steps")
        XCTAssertEqual(BiometricType.weight.defaultUnit, "lbs")
    }

    func testBiometricTypeStatusCalculation() {
        // Test heart rate status
        XCTAssertEqual(BiometricType.heartRate.status(for: 75), .optimal)
        XCTAssertEqual(BiometricType.heartRate.status(for: 125), .warning)

        // Test blood oxygen
        XCTAssertEqual(BiometricType.bloodOxygenSaturation.status(for: 98), .optimal)
        XCTAssertEqual(BiometricType.bloodOxygenSaturation.status(for: 88), .warning)

        // Test stress level
        XCTAssertEqual(BiometricType.stressLevel.status(for: 2), .optimal)
        XCTAssertEqual(BiometricType.stressLevel.status(for: 8), .warning)
    }

    // MARK: - ActivityType Tests

    func testActivityTypeCaloriesPerMinute() {
        // Given
        let running = ActivityType.running
        let walking = ActivityType.walking
        let meditation = ActivityType.meditation

        // When & Then
        XCTAssertEqual(running.caloriesPerMinute, 10.0)
        XCTAssertEqual(walking.caloriesPerMinute, 3.5)
        XCTAssertEqual(meditation.caloriesPerMinute, 1.5)
    }

    func testActivityTypeCategories() {
        XCTAssertEqual(ActivityType.running.category, .cardio)
        XCTAssertEqual(ActivityType.yoga.category, .flexibility)
        XCTAssertEqual(ActivityType.meditation.category, .mindBody)
        XCTAssertEqual(ActivityType.weightlifting.category, .strength)
    }
}
