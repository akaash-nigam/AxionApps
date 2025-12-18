//
//  CoreDataOutfitRepositoryTests.swift
//  WardrobeConsultantTests
//
//  Created by Claude Code
//  Copyright © 2025 Wardrobe Consultant. All rights reserved.
//

import XCTest
import CoreData
@testable import WardrobeConsultant

@MainActor
final class CoreDataOutfitRepositoryTests: XCTestCase {
    var repository: CoreDataOutfitRepository!
    var persistenceController: PersistenceController!
    var testFactory: TestDataFactory!

    override func setUp() async throws {
        try await super.setUp()

        persistenceController = PersistenceController(inMemory: true)
        repository = CoreDataOutfitRepository(persistenceController: persistenceController)
        testFactory = TestDataFactory.shared
    }

    override func tearDown() async throws {
        try await persistenceController.deleteAllData()
        repository = nil
        persistenceController = nil
        testFactory = nil

        try await super.tearDown()
    }

    // MARK: - Create Tests

    func testCreateOutfit() async throws {
        // Given
        let itemIDs: Set<UUID> = [UUID(), UUID(), UUID()]
        let outfit = testFactory.createTestOutfit(
            name: "Test Outfit",
            occasionType: .casual,
            itemIDs: itemIDs
        )

        // When
        let createdOutfit = try await repository.create(outfit)

        // Then
        XCTAssertEqual(createdOutfit.id, outfit.id)
        XCTAssertEqual(createdOutfit.name, "Test Outfit")
        XCTAssertEqual(createdOutfit.itemIDs, itemIDs)
        XCTAssertNotNil(createdOutfit.createdAt)
    }

    func testCreateOutfitWithMinimalData() async throws {
        // Given
        let outfit = testFactory.createTestOutfit(
            itemIDs: [UUID(), UUID()]
        )

        // When
        let createdOutfit = try await repository.create(outfit)

        // Then
        XCTAssertEqual(createdOutfit.itemIDs.count, 2)
        XCTAssertEqual(createdOutfit.occasionType, .casual)
    }

    // MARK: - Fetch Tests

    func testFetchAll() async throws {
        // Given
        let outfit1 = testFactory.createTestOutfit(name: "Outfit 1", itemIDs: [UUID()])
        let outfit2 = testFactory.createTestOutfit(name: "Outfit 2", itemIDs: [UUID()])
        _ = try await repository.create(outfit1)
        _ = try await repository.create(outfit2)

        // When
        let outfits = try await repository.fetchAll()

        // Then
        XCTAssertEqual(outfits.count, 2)
    }

    func testFetchByID() async throws {
        // Given
        let outfit = testFactory.createTestOutfit(itemIDs: [UUID()])
        _ = try await repository.create(outfit)

        // When
        let fetchedOutfit = try await repository.fetchByID(outfit.id)

        // Then
        XCTAssertNotNil(fetchedOutfit)
        XCTAssertEqual(fetchedOutfit?.id, outfit.id)
    }

    func testFetchByIDNotFound() async throws {
        // Given
        let nonExistentID = UUID()

        // When
        let outfit = try await repository.fetchByID(nonExistentID)

        // Then
        XCTAssertNil(outfit)
    }

    func testFetchByOccasion() async throws {
        // Given
        _ = try await repository.create(testFactory.createTestOutfit(
            occasionType: .work,
            itemIDs: [UUID()]
        ))
        _ = try await repository.create(testFactory.createTestOutfit(
            occasionType: .work,
            itemIDs: [UUID()]
        ))
        _ = try await repository.create(testFactory.createTestOutfit(
            occasionType: .party,
            itemIDs: [UUID()]
        ))

        // When
        let workOutfits = try await repository.fetchByOccasion(.work)

        // Then
        XCTAssertEqual(workOutfits.count, 2)
        XCTAssertTrue(workOutfits.allSatisfy { $0.occasionType == .work })
    }

    func testFetchByWeather() async throws {
        // Given
        _ = try await repository.create(testFactory.createTestOutfit(
            itemIDs: [UUID()],
            minTemperature: 10,
            maxTemperature: 20
        ))
        _ = try await repository.create(testFactory.createTestOutfit(
            itemIDs: [UUID()],
            minTemperature: 20,
            maxTemperature: 30
        ))
        _ = try await repository.create(testFactory.createTestOutfit(
            itemIDs: [UUID()],
            minTemperature: 5,
            maxTemperature: 15
        ))

        // When
        let outfits = try await repository.fetchByWeather(minTemperature: 15, maxTemperature: 25)

        // Then
        XCTAssertEqual(outfits.count, 2)
        XCTAssertTrue(outfits.allSatisfy { $0.minTemperature <= 25 && $0.maxTemperature >= 15 })
    }

    func testFetchFavorites() async throws {
        // Given
        _ = try await repository.create(testFactory.createTestOutfit(
            itemIDs: [UUID()],
            isFavorite: true
        ))
        _ = try await repository.create(testFactory.createTestOutfit(
            itemIDs: [UUID()],
            isFavorite: false
        ))
        _ = try await repository.create(testFactory.createTestOutfit(
            itemIDs: [UUID()],
            isFavorite: true
        ))

        // When
        let favorites = try await repository.fetchFavorites()

        // Then
        XCTAssertEqual(favorites.count, 2)
        XCTAssertTrue(favorites.allSatisfy { $0.isFavorite })
    }

    func testFetchAIGenerated() async throws {
        // Given
        _ = try await repository.create(testFactory.createTestOutfit(
            itemIDs: [UUID()],
            isAIGenerated: true
        ))
        _ = try await repository.create(testFactory.createTestOutfit(
            itemIDs: [UUID()],
            isAIGenerated: false
        ))
        _ = try await repository.create(testFactory.createTestOutfit(
            itemIDs: [UUID()],
            isAIGenerated: true
        ))

        // When
        let aiOutfits = try await repository.fetchAIGenerated()

        // Then
        XCTAssertEqual(aiOutfits.count, 2)
        XCTAssertTrue(aiOutfits.allSatisfy { $0.isAIGenerated })
    }

    func testFetchByItemID() async throws {
        // Given
        let sharedItemID = UUID()
        let otherItemID = UUID()

        _ = try await repository.create(testFactory.createTestOutfit(
            itemIDs: [sharedItemID, UUID()]
        ))
        _ = try await repository.create(testFactory.createTestOutfit(
            itemIDs: [otherItemID, UUID()]
        ))
        _ = try await repository.create(testFactory.createTestOutfit(
            itemIDs: [sharedItemID, UUID()]
        ))

        // When
        let outfits = try await repository.fetchByItemID(sharedItemID)

        // Then
        XCTAssertEqual(outfits.count, 2)
        XCTAssertTrue(outfits.allSatisfy { $0.itemIDs.contains(sharedItemID) })
    }

    // MARK: - Update Tests

    func testUpdateOutfit() async throws {
        // Given
        var outfit = testFactory.createTestOutfit(
            name: "Original Name",
            itemIDs: [UUID()],
            isFavorite: false
        )
        _ = try await repository.create(outfit)

        // When
        outfit.name = "Updated Name"
        outfit.isFavorite = true
        outfit.timesWorn = 5
        try await repository.update(outfit)

        // Then
        let updatedOutfit = try await repository.fetchByID(outfit.id)
        XCTAssertEqual(updatedOutfit?.name, "Updated Name")
        XCTAssertEqual(updatedOutfit?.isFavorite, true)
        XCTAssertEqual(updatedOutfit?.timesWorn, 5)
    }

    func testUpdateOutfitItemIDs() async throws {
        // Given
        let initialIDs: Set<UUID> = [UUID(), UUID()]
        var outfit = testFactory.createTestOutfit(itemIDs: initialIDs)
        _ = try await repository.create(outfit)

        // When
        let newIDs: Set<UUID> = [UUID(), UUID(), UUID(), UUID()]
        outfit.itemIDs = newIDs
        try await repository.update(outfit)

        // Then
        let updatedOutfit = try await repository.fetchByID(outfit.id)
        XCTAssertEqual(updatedOutfit?.itemIDs.count, 4)
        XCTAssertEqual(updatedOutfit?.itemIDs, newIDs)
    }

    // MARK: - Delete Tests

    func testDelete() async throws {
        // Given
        let outfit = testFactory.createTestOutfit(itemIDs: [UUID()])
        _ = try await repository.create(outfit)

        // When
        try await repository.delete(outfit.id)

        // Then
        let fetchedOutfit = try await repository.fetchByID(outfit.id)
        XCTAssertNil(fetchedOutfit)
    }

    func testDeleteNonExistentOutfit() async throws {
        // Given
        let nonExistentID = UUID()

        // When/Then - Should not throw
        try await repository.delete(nonExistentID)
    }

    func testDeleteAll() async throws {
        // Given
        for i in 0..<5 {
            _ = try await repository.create(testFactory.createTestOutfit(
                name: "Outfit \(i)",
                itemIDs: [UUID()]
            ))
        }

        // When
        try await repository.deleteAll()

        // Then
        let remainingOutfits = try await repository.fetchAll()
        XCTAssertEqual(remainingOutfits.count, 0)
    }

    // MARK: - Statistics Tests

    func testGetMostWorn() async throws {
        // Given
        _ = try await repository.create(testFactory.createTestOutfit(
            itemIDs: [UUID()],
            timesWorn: 5
        ))
        _ = try await repository.create(testFactory.createTestOutfit(
            itemIDs: [UUID()],
            timesWorn: 15
        ))
        _ = try await repository.create(testFactory.createTestOutfit(
            itemIDs: [UUID()],
            timesWorn: 10
        ))

        // When
        let mostWorn = try await repository.getMostWorn(limit: 2)

        // Then
        XCTAssertEqual(mostWorn.count, 2)
        XCTAssertEqual(mostWorn[0].timesWorn, 15)
        XCTAssertEqual(mostWorn[1].timesWorn, 10)
    }

    func testGetRecentlyCreated() async throws {
        // Given
        let oldDate = Calendar.current.date(byAdding: .day, value: -30, to: Date())!
        var oldOutfit = testFactory.createTestOutfit(itemIDs: [UUID()])
        oldOutfit.createdAt = oldDate
        _ = try await repository.create(oldOutfit)

        let newOutfit = testFactory.createTestOutfit(itemIDs: [UUID()])
        _ = try await repository.create(newOutfit)

        // When
        let recentOutfits = try await repository.getRecentlyCreated(limit: 1)

        // Then
        XCTAssertEqual(recentOutfits.count, 1)
        XCTAssertEqual(recentOutfits[0].id, newOutfit.id)
    }

    func testGetTotalOutfitCount() async throws {
        // Given
        for _ in 0..<7 {
            _ = try await repository.create(testFactory.createTestOutfit(itemIDs: [UUID()]))
        }

        // When
        let count = try await repository.getTotalOutfitCount()

        // Then
        XCTAssertEqual(count, 7)
    }

    // MARK: - Predefined Outfit Tests

    func testCasualWeekendOutfit() async throws {
        // Given
        let (_, outfit) = testFactory.casualWeekendOutfit()

        // When
        let createdOutfit = try await repository.create(outfit)

        // Then
        XCTAssertEqual(createdOutfit.name, "Casual Weekend")
        XCTAssertEqual(createdOutfit.occasionType, .casual)
        XCTAssertEqual(createdOutfit.itemIDs.count, 3)
    }

    func testProfessionalWorkOutfit() async throws {
        // Given
        let (_, outfit) = testFactory.professionalWorkOutfit()

        // When
        let createdOutfit = try await repository.create(outfit)

        // Then
        XCTAssertEqual(createdOutfit.name, "Professional Work")
        XCTAssertEqual(createdOutfit.occasionType, .work)
        XCTAssertEqual(createdOutfit.itemIDs.count, 4)
    }

    // MARK: - Weather Condition Tests

    func testFetchByWeatherConditions() async throws {
        // Given
        _ = try await repository.create(testFactory.createTestOutfit(
            itemIDs: [UUID()],
            weatherConditions: [.clear, .sunny]
        ))
        _ = try await repository.create(testFactory.createTestOutfit(
            itemIDs: [UUID()],
            weatherConditions: [.rain, .cloudy]
        ))

        // When - Fetch outfits suitable for clear weather
        let allOutfits = try await repository.fetchAll()
        let clearWeatherOutfits = allOutfits.filter { $0.weatherConditions.contains(.clear) }

        // Then
        XCTAssertEqual(clearWeatherOutfits.count, 1)
    }

    // MARK: - Concurrent Access Tests

    func testConcurrentReads() async throws {
        // Given
        let outfit = testFactory.createTestOutfit(itemIDs: [UUID()])
        _ = try await repository.create(outfit)

        // When - Multiple concurrent reads
        await withTaskGroup(of: Outfit?.self) { group in
            for _ in 0..<10 {
                group.addTask {
                    try? await self.repository.fetchByID(outfit.id)
                }
            }

            var results: [Outfit?] = []
            for await result in group {
                results.append(result)
            }

            // Then
            XCTAssertEqual(results.count, 10)
            XCTAssertTrue(results.allSatisfy { $0?.id == outfit.id })
        }
    }

    // MARK: - Outfit Wear Tracking Tests

    func testIncrementTimesWorn() async throws {
        // Given
        var outfit = testFactory.createTestOutfit(itemIDs: [UUID()])
        outfit.timesWorn = 0
        _ = try await repository.create(outfit)

        // When
        outfit.timesWorn = 1
        outfit.lastWornDate = Date()
        try await repository.update(outfit)

        outfit.timesWorn = 2
        outfit.lastWornDate = Date()
        try await repository.update(outfit)

        // Then
        let updatedOutfit = try await repository.fetchByID(outfit.id)
        XCTAssertEqual(updatedOutfit?.timesWorn, 2)
        XCTAssertNotNil(updatedOutfit?.lastWornDate)
    }
}
