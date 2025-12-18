//
//  CoreDataWardrobeRepositoryTests.swift
//  WardrobeConsultantTests
//
//  Created by Claude Code
//  Copyright © 2025 Wardrobe Consultant. All rights reserved.
//

import XCTest
import CoreData
@testable import WardrobeConsultant

@MainActor
final class CoreDataWardrobeRepositoryTests: XCTestCase {
    var repository: CoreDataWardrobeRepository!
    var persistenceController: PersistenceController!
    var testFactory: TestDataFactory!

    override func setUp() async throws {
        try await super.setUp()

        // Create in-memory persistence controller for testing
        persistenceController = PersistenceController(inMemory: true)
        repository = CoreDataWardrobeRepository(persistenceController: persistenceController)
        testFactory = TestDataFactory.shared
    }

    override func tearDown() async throws {
        // Clean up
        try await persistenceController.deleteAllData()
        repository = nil
        persistenceController = nil
        testFactory = nil

        try await super.tearDown()
    }

    // MARK: - Create Tests

    func testCreateWardrobeItem() async throws {
        // Given
        let item = testFactory.createTestWardrobeItem(category: .tShirt, primaryColor: "#FF0000")

        // When
        let createdItem = try await repository.create(item)

        // Then
        XCTAssertEqual(createdItem.id, item.id)
        XCTAssertEqual(createdItem.category, .tShirt)
        XCTAssertEqual(createdItem.primaryColor, "#FF0000")
        XCTAssertNotNil(createdItem.createdAt)
    }

    func testCreateMultipleItems() async throws {
        // Given
        let items = testFactory.createSampleWardrobe(itemCount: 10)

        // When
        for item in items {
            _ = try await repository.create(item)
        }

        // Then
        let fetchedItems = try await repository.fetchAll()
        XCTAssertEqual(fetchedItems.count, 10)
    }

    // MARK: - Fetch Tests

    func testFetchAll() async throws {
        // Given
        let item1 = testFactory.createTestWardrobeItem(category: .tShirt)
        let item2 = testFactory.createTestWardrobeItem(category: .jeans)
        _ = try await repository.create(item1)
        _ = try await repository.create(item2)

        // When
        let items = try await repository.fetchAll()

        // Then
        XCTAssertEqual(items.count, 2)
    }

    func testFetchByID() async throws {
        // Given
        let item = testFactory.createTestWardrobeItem(category: .dress)
        _ = try await repository.create(item)

        // When
        let fetchedItem = try await repository.fetchByID(item.id)

        // Then
        XCTAssertNotNil(fetchedItem)
        XCTAssertEqual(fetchedItem?.id, item.id)
        XCTAssertEqual(fetchedItem?.category, .dress)
    }

    func testFetchByIDNotFound() async throws {
        // Given
        let nonExistentID = UUID()

        // When
        let item = try await repository.fetchByID(nonExistentID)

        // Then
        XCTAssertNil(item)
    }

    func testFetchByCategory() async throws {
        // Given
        _ = try await repository.create(testFactory.createTestWardrobeItem(category: .tShirt))
        _ = try await repository.create(testFactory.createTestWardrobeItem(category: .tShirt))
        _ = try await repository.create(testFactory.createTestWardrobeItem(category: .jeans))

        // When
        let tshirts = try await repository.fetchByCategory(.tShirt)

        // Then
        XCTAssertEqual(tshirts.count, 2)
        XCTAssertTrue(tshirts.allSatisfy { $0.category == .tShirt })
    }

    func testFetchBySeason() async throws {
        // Given
        _ = try await repository.create(testFactory.createTestWardrobeItem(
            category: .tShirt,
            season: [.summer]
        ))
        _ = try await repository.create(testFactory.createTestWardrobeItem(
            category: .coat,
            season: [.winter]
        ))
        _ = try await repository.create(testFactory.createTestWardrobeItem(
            category: .jacket,
            season: [.fall, .spring]
        ))

        // When
        let summerItems = try await repository.fetchBySeason(.summer)

        // Then
        XCTAssertEqual(summerItems.count, 1)
        XCTAssertTrue(summerItems[0].season.contains(.summer))
    }

    func testFetchByColor() async throws {
        // Given
        _ = try await repository.create(testFactory.createTestWardrobeItem(primaryColor: "#FF0000"))
        _ = try await repository.create(testFactory.createTestWardrobeItem(primaryColor: "#FF0000"))
        _ = try await repository.create(testFactory.createTestWardrobeItem(primaryColor: "#0000FF"))

        // When
        let redItems = try await repository.fetchByColor("#FF0000")

        // Then
        XCTAssertEqual(redItems.count, 2)
        XCTAssertTrue(redItems.allSatisfy { $0.primaryColor == "#FF0000" })
    }

    func testFetchFavorites() async throws {
        // Given
        _ = try await repository.create(testFactory.createTestWardrobeItem(isFavorite: true))
        _ = try await repository.create(testFactory.createTestWardrobeItem(isFavorite: false))
        _ = try await repository.create(testFactory.createTestWardrobeItem(isFavorite: true))

        // When
        let favorites = try await repository.fetchFavorites()

        // Then
        XCTAssertEqual(favorites.count, 2)
        XCTAssertTrue(favorites.allSatisfy { $0.isFavorite })
    }

    // MARK: - Update Tests

    func testUpdateWardrobeItem() async throws {
        // Given
        var item = testFactory.createTestWardrobeItem(
            category: .tShirt,
            timesWorn: 5,
            isFavorite: false
        )
        _ = try await repository.create(item)

        // When
        item.timesWorn = 10
        item.isFavorite = true
        item.notes = "Updated notes"
        try await repository.update(item)

        // Then
        let updatedItem = try await repository.fetchByID(item.id)
        XCTAssertEqual(updatedItem?.timesWorn, 10)
        XCTAssertEqual(updatedItem?.isFavorite, true)
        XCTAssertEqual(updatedItem?.notes, "Updated notes")
    }

    func testUpdateNonExistentItem() async throws {
        // Given
        let item = testFactory.createTestWardrobeItem()

        // When/Then - Should not throw, just create new
        try await repository.update(item)
        let fetchedItem = try await repository.fetchByID(item.id)
        XCTAssertNotNil(fetchedItem)
    }

    // MARK: - Delete Tests

    func testDelete() async throws {
        // Given
        let item = testFactory.createTestWardrobeItem()
        _ = try await repository.create(item)

        // When
        try await repository.delete(item.id)

        // Then
        let fetchedItem = try await repository.fetchByID(item.id)
        XCTAssertNil(fetchedItem)
    }

    func testDeleteNonExistentItem() async throws {
        // Given
        let nonExistentID = UUID()

        // When/Then - Should not throw
        try await repository.delete(nonExistentID)
    }

    func testDeleteAll() async throws {
        // Given
        let items = testFactory.createSampleWardrobe(itemCount: 5)
        for item in items {
            _ = try await repository.create(item)
        }

        // When
        try await repository.deleteAll()

        // Then
        let remainingItems = try await repository.fetchAll()
        XCTAssertEqual(remainingItems.count, 0)
    }

    // MARK: - Search Tests

    func testSearch() async throws {
        // Given
        _ = try await repository.create(testFactory.createTestWardrobeItem(
            brand: "Nike",
            notes: "Great running shoes"
        ))
        _ = try await repository.create(testFactory.createTestWardrobeItem(
            brand: "Adidas",
            notes: "Comfortable sneakers"
        ))
        _ = try await repository.create(testFactory.createTestWardrobeItem(
            brand: "Nike",
            notes: "Blue shirt"
        ))

        // When
        let results = try await repository.search(query: "Nike")

        // Then
        XCTAssertEqual(results.count, 2)
        XCTAssertTrue(results.allSatisfy { $0.brand?.contains("Nike") ?? false })
    }

    func testSearchEmptyQuery() async throws {
        // Given
        _ = try await repository.create(testFactory.createTestWardrobeItem())

        // When
        let results = try await repository.search(query: "")

        // Then
        XCTAssertEqual(results.count, 0)
    }

    func testSearchNoResults() async throws {
        // Given
        _ = try await repository.create(testFactory.createTestWardrobeItem(brand: "Nike"))

        // When
        let results = try await repository.search(query: "NonExistentBrand")

        // Then
        XCTAssertEqual(results.count, 0)
    }

    // MARK: - Statistics Tests

    func testGetMostWorn() async throws {
        // Given
        _ = try await repository.create(testFactory.createTestWardrobeItem(timesWorn: 5))
        _ = try await repository.create(testFactory.createTestWardrobeItem(timesWorn: 20))
        _ = try await repository.create(testFactory.createTestWardrobeItem(timesWorn: 10))

        // When
        let mostWorn = try await repository.getMostWorn(limit: 2)

        // Then
        XCTAssertEqual(mostWorn.count, 2)
        XCTAssertEqual(mostWorn[0].timesWorn, 20)
        XCTAssertEqual(mostWorn[1].timesWorn, 10)
    }

    func testGetLeastWorn() async throws {
        // Given
        _ = try await repository.create(testFactory.createTestWardrobeItem(timesWorn: 5))
        _ = try await repository.create(testFactory.createTestWardrobeItem(timesWorn: 0))
        _ = try await repository.create(testFactory.createTestWardrobeItem(timesWorn: 10))

        // When
        let leastWorn = try await repository.getLeastWorn(limit: 2)

        // Then
        XCTAssertEqual(leastWorn.count, 2)
        XCTAssertEqual(leastWorn[0].timesWorn, 0)
        XCTAssertEqual(leastWorn[1].timesWorn, 5)
    }

    func testGetRecentlyAdded() async throws {
        // Given
        let oldDate = Calendar.current.date(byAdding: .day, value: -30, to: Date())!
        var oldItem = testFactory.createTestWardrobeItem()
        oldItem.createdAt = oldDate
        _ = try await repository.create(oldItem)

        let newItem = testFactory.createTestWardrobeItem()
        _ = try await repository.create(newItem)

        // When
        let recentItems = try await repository.getRecentlyAdded(limit: 1)

        // Then
        XCTAssertEqual(recentItems.count, 1)
        XCTAssertEqual(recentItems[0].id, newItem.id)
    }

    func testGetTotalItemCount() async throws {
        // Given
        let items = testFactory.createSampleWardrobe(itemCount: 15)
        for item in items {
            _ = try await repository.create(item)
        }

        // When
        let count = try await repository.getTotalItemCount()

        // Then
        XCTAssertEqual(count, 15)
    }

    func testGetItemCountByCategory() async throws {
        // Given
        _ = try await repository.create(testFactory.createTestWardrobeItem(category: .tShirt))
        _ = try await repository.create(testFactory.createTestWardrobeItem(category: .tShirt))
        _ = try await repository.create(testFactory.createTestWardrobeItem(category: .jeans))

        // When
        let counts = try await repository.getItemCountByCategory()

        // Then
        XCTAssertEqual(counts[.tShirt], 2)
        XCTAssertEqual(counts[.jeans], 1)
    }

    // MARK: - Batch Operations Tests

    func testBatchCreate() async throws {
        // Given
        let items = testFactory.createSampleWardrobe(itemCount: 50)

        // When
        let startTime = Date()
        for item in items {
            _ = try await repository.create(item)
        }
        let duration = Date().timeIntervalSince(startTime)

        // Then
        let fetchedItems = try await repository.fetchAll()
        XCTAssertEqual(fetchedItems.count, 50)

        // Performance check (should complete in reasonable time)
        XCTAssertLessThan(duration, 5.0, "Batch creation took too long")
    }

    // MARK: - Concurrent Access Tests

    func testConcurrentReads() async throws {
        // Given
        let item = testFactory.createTestWardrobeItem()
        _ = try await repository.create(item)

        // When - Multiple concurrent reads
        await withTaskGroup(of: WardrobeItem?.self) { group in
            for _ in 0..<10 {
                group.addTask {
                    try? await self.repository.fetchByID(item.id)
                }
            }

            var results: [WardrobeItem?] = []
            for await result in group {
                results.append(result)
            }

            // Then
            XCTAssertEqual(results.count, 10)
            XCTAssertTrue(results.allSatisfy { $0?.id == item.id })
        }
    }
}
