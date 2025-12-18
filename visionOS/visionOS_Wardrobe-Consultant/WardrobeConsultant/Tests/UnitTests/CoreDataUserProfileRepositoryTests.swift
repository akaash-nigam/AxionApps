//
//  CoreDataUserProfileRepositoryTests.swift
//  WardrobeConsultantTests
//
//  Created by Claude Code
//  Copyright © 2025 Wardrobe Consultant. All rights reserved.
//

import XCTest
import CoreData
@testable import WardrobeConsultant

@MainActor
final class CoreDataUserProfileRepositoryTests: XCTestCase {
    var repository: CoreDataUserProfileRepository!
    var persistenceController: PersistenceController!
    var testFactory: TestDataFactory!

    override func setUp() async throws {
        try await super.setUp()

        persistenceController = PersistenceController(inMemory: true)
        repository = CoreDataUserProfileRepository(persistenceController: persistenceController)
        testFactory = TestDataFactory.shared
    }

    override func tearDown() async throws {
        try await persistenceController.deleteAllData()
        try? await repository.deleteBodyMeasurements()
        repository = nil
        persistenceController = nil
        testFactory = nil

        try await super.tearDown()
    }

    // MARK: - Fetch Tests

    func testFetchCreatesDefaultProfile() async throws {
        // When
        let profile = try await repository.fetch()

        // Then
        XCTAssertNotNil(profile.id)
        XCTAssertNotNil(profile.createdAt)
        XCTAssertEqual(profile.primaryStyle, .casual) // Default style
    }

    func testFetchExistingProfile() async throws {
        // Given
        let originalProfile = testFactory.createTestUserProfile(
            primaryStyle: .minimalist,
            favoriteColors: ["#000000", "#FFFFFF"]
        )
        try await repository.update(originalProfile)

        // When
        let fetchedProfile = try await repository.fetch()

        // Then
        XCTAssertEqual(fetchedProfile.id, originalProfile.id)
        XCTAssertEqual(fetchedProfile.primaryStyle, .minimalist)
        XCTAssertEqual(fetchedProfile.favoriteColors, ["#000000", "#FFFFFF"])
    }

    // MARK: - Update Tests

    func testUpdateProfile() async throws {
        // Given
        var profile = try await repository.fetch()

        // When
        profile.topSize = "L"
        profile.bottomSize = "34"
        profile.primaryStyle = .bohemian
        profile.favoriteColors = ["#FF0000", "#0000FF"]
        try await repository.update(profile)

        // Then
        let updatedProfile = try await repository.fetch()
        XCTAssertEqual(updatedProfile.topSize, "L")
        XCTAssertEqual(updatedProfile.bottomSize, "34")
        XCTAssertEqual(updatedProfile.primaryStyle, .bohemian)
        XCTAssertEqual(updatedProfile.favoriteColors, ["#FF0000", "#0000FF"])
    }

    func testUpdateProfileStylePreferences() async throws {
        // Given
        var profile = try await repository.fetch()

        // When
        profile.primaryStyle = .classic
        profile.secondaryStyle = .preppy
        profile.comfortLevel = .veryComfortable
        profile.budgetRange = .luxury
        try await repository.update(profile)

        // Then
        let updatedProfile = try await repository.fetch()
        XCTAssertEqual(updatedProfile.primaryStyle, .classic)
        XCTAssertEqual(updatedProfile.secondaryStyle, .preppy)
        XCTAssertEqual(updatedProfile.comfortLevel, .veryComfortable)
        XCTAssertEqual(updatedProfile.budgetRange, .luxury)
    }

    func testUpdateProfileSettings() async throws {
        // Given
        var profile = try await repository.fetch()

        // When
        profile.enableWeatherIntegration = false
        profile.enableCalendarIntegration = false
        profile.enableNotifications = false
        profile.temperatureUnit = .celsius
        try await repository.update(profile)

        // Then
        let updatedProfile = try await repository.fetch()
        XCTAssertFalse(updatedProfile.enableWeatherIntegration)
        XCTAssertFalse(updatedProfile.enableCalendarIntegration)
        XCTAssertFalse(updatedProfile.enableNotifications)
        XCTAssertEqual(updatedProfile.temperatureUnit, .celsius)
    }

    func testUpdateProfileColors() async throws {
        // Given
        var profile = try await repository.fetch()

        // When
        profile.favoriteColors = ["#FF0000", "#00FF00", "#0000FF", "#FFFF00", "#FF00FF"]
        profile.avoidColors = ["#FFA500", "#800080"]
        try await repository.update(profile)

        // Then
        let updatedProfile = try await repository.fetch()
        XCTAssertEqual(updatedProfile.favoriteColors.count, 5)
        XCTAssertEqual(updatedProfile.avoidColors.count, 2)
        XCTAssertTrue(updatedProfile.favoriteColors.contains("#FF0000"))
        XCTAssertTrue(updatedProfile.avoidColors.contains("#FFA500"))
    }

    func testUpdateProfileStyleIcons() async throws {
        // Given
        var profile = try await repository.fetch()

        // When
        profile.styleIcons = ["Coco Chanel", "David Bowie", "Grace Kelly"]
        try await repository.update(profile)

        // Then
        let updatedProfile = try await repository.fetch()
        XCTAssertEqual(updatedProfile.styleIcons.count, 3)
        XCTAssertTrue(updatedProfile.styleIcons.contains("Coco Chanel"))
    }

    // MARK: - Delete Tests

    func testDeleteProfile() async throws {
        // Given
        let profile = try await repository.fetch()
        XCTAssertNotNil(profile.id)

        // When
        try await repository.delete()

        // Then - Should create a new default profile when fetched
        let newProfile = try await repository.fetch()
        XCTAssertNotEqual(newProfile.id, profile.id)
    }

    // MARK: - Body Measurements Tests

    func testSaveBodyMeasurements() async throws {
        // Given
        let measurements = testFactory.createTestBodyMeasurements(
            height: 175.0,
            weight: 70.0,
            chest: 95.0,
            waist: 80.0,
            hips: 100.0
        )

        // When
        try await repository.saveBodyMeasurements(measurements)

        // Then
        let retrieved = try await repository.getBodyMeasurements()
        XCTAssertNotNil(retrieved)
        XCTAssertEqual(retrieved?.height, 175.0)
        XCTAssertEqual(retrieved?.weight, 70.0)
        XCTAssertEqual(retrieved?.chest, 95.0)
        XCTAssertEqual(retrieved?.waist, 80.0)
        XCTAssertEqual(retrieved?.hips, 100.0)
    }

    func testGetBodyMeasurementsNotFound() async throws {
        // When
        let measurements = try await repository.getBodyMeasurements()

        // Then
        XCTAssertNil(measurements)
    }

    func testUpdateBodyMeasurements() async throws {
        // Given
        let original = testFactory.createTestBodyMeasurements(height: 170.0)
        try await repository.saveBodyMeasurements(original)

        // When
        let updated = testFactory.createTestBodyMeasurements(height: 175.0)
        try await repository.saveBodyMeasurements(updated)

        // Then
        let retrieved = try await repository.getBodyMeasurements()
        XCTAssertEqual(retrieved?.height, 175.0)
    }

    func testDeleteBodyMeasurements() async throws {
        // Given
        let measurements = testFactory.createTestBodyMeasurements()
        try await repository.saveBodyMeasurements(measurements)

        // When
        try await repository.deleteBodyMeasurements()

        // Then
        let retrieved = try await repository.getBodyMeasurements()
        XCTAssertNil(retrieved)
    }

    func testDeleteBodyMeasurementsNotFound() async throws {
        // When/Then - Should not throw
        try await repository.deleteBodyMeasurements()
    }

    // MARK: - Complete Profile Tests

    func testCompleteProfileSetup() async throws {
        // Given - Complete profile setup
        var profile = try await repository.fetch()

        profile.topSize = "M"
        profile.bottomSize = "32"
        profile.dressSize = "8"
        profile.shoeSize = "9.5"
        profile.fitPreference = .slim

        profile.primaryStyle = .minimalist
        profile.secondaryStyle = .classic
        profile.favoriteColors = ["#000000", "#FFFFFF", "#808080"]
        profile.avoidColors = ["#FFFF00", "#FF1493"]

        profile.comfortLevel = .moderate
        profile.budgetRange = .medium
        profile.sustainabilityPreference = true

        profile.styleIcons = ["Steve Jobs", "Audrey Hepburn"]

        profile.temperatureUnit = .fahrenheit
        profile.enableWeatherIntegration = true
        profile.enableCalendarIntegration = true
        profile.enableNotifications = true

        try await repository.update(profile)

        let measurements = testFactory.createTestBodyMeasurements(
            height: 175.0,
            weight: 68.0,
            chest: 92.0,
            waist: 76.0,
            hips: 96.0,
            inseam: 81.0
        )
        try await repository.saveBodyMeasurements(measurements)

        // When
        let savedProfile = try await repository.fetch()
        let savedMeasurements = try await repository.getBodyMeasurements()

        // Then
        XCTAssertEqual(savedProfile.topSize, "M")
        XCTAssertEqual(savedProfile.primaryStyle, .minimalist)
        XCTAssertEqual(savedProfile.favoriteColors.count, 3)
        XCTAssertTrue(savedProfile.sustainabilityPreference)
        XCTAssertNotNil(savedMeasurements)
        XCTAssertEqual(savedMeasurements?.height, 175.0)
    }

    // MARK: - Size Preferences Tests

    func testAllSizeFields() async throws {
        // Given
        var profile = try await repository.fetch()

        // When
        profile.topSize = "XL"
        profile.bottomSize = "36"
        profile.dressSize = "12"
        profile.shoeSize = "10.5"
        profile.fitPreference = .relaxed
        try await repository.update(profile)

        // Then
        let updatedProfile = try await repository.fetch()
        XCTAssertEqual(updatedProfile.topSize, "XL")
        XCTAssertEqual(updatedProfile.bottomSize, "36")
        XCTAssertEqual(updatedProfile.dressSize, "12")
        XCTAssertEqual(updatedProfile.shoeSize, "10.5")
        XCTAssertEqual(updatedProfile.fitPreference, .relaxed)
    }

    // MARK: - Sustainability Tests

    func testSustainabilityPreference() async throws {
        // Given
        var profile = try await repository.fetch()

        // When
        profile.sustainabilityPreference = true
        try await repository.update(profile)

        // Then
        let updatedProfile = try await repository.fetch()
        XCTAssertTrue(updatedProfile.sustainabilityPreference)
    }

    // MARK: - Multiple Updates Tests

    func testMultipleSequentialUpdates() async throws {
        // Given
        var profile = try await repository.fetch()

        // When - Multiple updates
        profile.primaryStyle = .casual
        try await repository.update(profile)

        profile.primaryStyle = .minimalist
        profile.favoriteColors = ["#000000"]
        try await repository.update(profile)

        profile.topSize = "L"
        try await repository.update(profile)

        // Then
        let finalProfile = try await repository.fetch()
        XCTAssertEqual(finalProfile.primaryStyle, .minimalist)
        XCTAssertEqual(finalProfile.favoriteColors, ["#000000"])
        XCTAssertEqual(finalProfile.topSize, "L")
    }

    // MARK: - Body Measurements Unit System Tests

    func testBodyMeasurementsMetricSystem() async throws {
        // Given
        var measurements = testFactory.createTestBodyMeasurements(height: 175.0)
        measurements.unitSystem = .metric

        // When
        try await repository.saveBodyMeasurements(measurements)

        // Then
        let retrieved = try await repository.getBodyMeasurements()
        XCTAssertEqual(retrieved?.unitSystem, .metric)
    }

    func testBodyMeasurementsImperialSystem() async throws {
        // Given
        var measurements = testFactory.createTestBodyMeasurements(height: 69.0)
        measurements.unitSystem = .imperial

        // When
        try await repository.saveBodyMeasurements(measurements)

        // Then
        let retrieved = try await repository.getBodyMeasurements()
        XCTAssertEqual(retrieved?.unitSystem, .imperial)
    }
}
