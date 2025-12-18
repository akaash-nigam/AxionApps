//
//  PerformanceTests.swift
//  WardrobeConsultantPerformanceTests
//
//  Created by Claude Code
//  Copyright © 2025 Wardrobe Consultant. All rights reserved.
//

import XCTest
import CoreData
@testable import WardrobeConsultant

/// Performance tests for measuring app performance metrics
///
/// NOTE: These tests require Xcode and cannot be run in command-line environment.
/// They use XCTMetric APIs for precise performance measurement.
///
/// To run these tests:
/// 1. Open project in Xcode
/// 2. Select a device or simulator
/// 3. Press Cmd+U or Product > Test > Performance Tests
/// 4. View results in Test Report
@MainActor
final class WardrobeConsultantPerformanceTests: XCTestCase {
    var persistenceController: PersistenceController!
    var wardrobeRepository: CoreDataWardrobeRepository!
    var outfitRepository: CoreDataOutfitRepository!
    var outfitGenerator: OutfitGenerationService!
    var testFactory: TestDataFactory!

    override func setUp() async throws {
        try await super.setUp()

        persistenceController = PersistenceController(inMemory: true)
        wardrobeRepository = CoreDataWardrobeRepository(persistenceController: persistenceController)
        outfitRepository = CoreDataOutfitRepository(persistenceController: persistenceController)
        outfitGenerator = OutfitGenerationService(
            wardrobeRepository: wardrobeRepository,
            userProfileRepository: CoreDataUserProfileRepository(persistenceController: persistenceController)
        )
        testFactory = TestDataFactory.shared

        // Pre-populate with data
        let items = testFactory.createSampleWardrobe(itemCount: 100)
        for item in items {
            _ = try await wardrobeRepository.create(item)
        }
    }

    override func tearDown() async throws {
        try await persistenceController.deleteAllData()
        wardrobeRepository = nil
        outfitRepository = nil
        outfitGenerator = nil
        persistenceController = nil
        testFactory = nil
        try await super.tearDown()
    }

    // MARK: - Repository Performance Tests

    func testFetchAllItemsPerformance() async throws {
        // Measure time to fetch all items from repository
        measure(metrics: [XCTClockMetric(), XCTMemoryMetric()]) {
            Task { @MainActor in
                _ = try? await wardrobeRepository.fetchAll()
            }
        }

        // Expected: < 100ms for 100 items
    }

    func testCreateItemPerformance() async throws {
        // Measure time to create a single item
        measure(metrics: [XCTClockMetric(), XCTMemoryMetric()]) {
            Task { @MainActor in
                let item = testFactory.createTestWardrobeItem()
                _ = try? await wardrobeRepository.create(item)
            }
        }

        // Expected: < 50ms per item
    }

    func testBatchCreatePerformance() async throws {
        // Measure time to create 50 items in batch
        measure(metrics: [XCTClockMetric(), XCTMemoryMetric()]) {
            Task { @MainActor in
                let items = testFactory.createSampleWardrobe(itemCount: 50)
                for item in items {
                    _ = try? await wardrobeRepository.create(item)
                }
            }
        }

        // Expected: < 2 seconds for 50 items
    }

    func testSearchPerformance() async throws {
        // Measure time to search through 100 items
        measure(metrics: [XCTClockMetric()]) {
            Task { @MainActor in
                _ = try? await wardrobeRepository.search(query: "Nike")
            }
        }

        // Expected: < 50ms
    }

    func testFetchByCategoryPerformance() async throws {
        // Measure time to filter by category
        measure(metrics: [XCTClockMetric()]) {
            Task { @MainActor in
                _ = try? await wardrobeRepository.fetchByCategory(.tShirt)
            }
        }

        // Expected: < 50ms
    }

    func testUpdateItemPerformance() async throws {
        // Given: An existing item
        let item = testFactory.createTestWardrobeItem()
        var createdItem = try await wardrobeRepository.create(item)

        // Measure time to update an item
        measure(metrics: [XCTClockMetric()]) {
            Task { @MainActor in
                createdItem.timesWorn += 1
                try? await wardrobeRepository.update(createdItem)
            }
        }

        // Expected: < 30ms
    }

    func testDeleteItemPerformance() async throws {
        // Measure time to delete an item
        measure(metrics: [XCTClockMetric()]) {
            Task { @MainActor in
                let item = testFactory.createTestWardrobeItem()
                let created = try? await wardrobeRepository.create(item)
                if let created = created {
                    try? await wardrobeRepository.delete(created.id)
                }
            }
        }

        // Expected: < 30ms
    }

    // MARK: - AI Service Performance Tests

    func testOutfitGenerationPerformance() async throws {
        // Measure time to generate 3 outfits from 100 items
        measure(metrics: [XCTClockMetric(), XCTCPUMetric(), XCTMemoryMetric()]) {
            Task { @MainActor in
                _ = try? await outfitGenerator.generateOutfits(for: .casual, limit: 3)
            }
        }

        // Expected: < 500ms for 3 outfits from 100 items
    }

    func testColorHarmonyCalculationPerformance() throws {
        // Measure color compatibility calculation
        let colorHarmony = ColorHarmonyService.shared

        measure(metrics: [XCTClockMetric()]) {
            for _ in 0..<1000 {
                _ = colorHarmony.compatibilityScore(color1: "#FF0000", color2: "#0000FF")
            }
        }

        // Expected: < 100ms for 1000 calculations
    }

    func testStyleMatchingPerformance() throws {
        // Measure style scoring calculation
        let styleMatching = StyleMatchingService.shared
        let profile = testFactory.createTestUserProfile(primaryStyle: .casual)
        let item = testFactory.createTestWardrobeItem()

        measure(metrics: [XCTClockMetric()]) {
            for _ in 0..<1000 {
                _ = styleMatching.styleScore(item: item, profile: profile)
            }
        }

        // Expected: < 100ms for 1000 calculations
    }

    func testWeatherRecommendationPerformance() throws {
        // Measure weather suitability calculation
        let weatherRec = WeatherRecommendationService.shared
        let item = testFactory.createTestWardrobeItem()

        measure(metrics: [XCTClockMetric()]) {
            for _ in 0..<1000 {
                _ = weatherRec.weatherSuitability(item: item, temperature: 20, condition: .clear)
            }
        }

        // Expected: < 100ms for 1000 calculations
    }

    // MARK: - Photo Storage Performance Tests

    func testPhotoSavePerformance() async throws {
        // Measure time to save photo with thumbnail
        let photoService = PhotoStorageService.shared
        let image = testFactory.createTestImage(color: .blue)
        let itemID = UUID()

        measure(metrics: [XCTClockMetric(), XCTMemoryMetric(), XCTStorageMetric()]) {
            Task {
                _ = try? await photoService.savePhoto(image, for: itemID)
            }
        }

        // Expected: < 200ms per photo

        // Cleanup
        try await photoService.deletePhotos(for: itemID)
    }

    func testPhotoLoadPerformance() async throws {
        // Given: A saved photo
        let photoService = PhotoStorageService.shared
        let image = testFactory.createTestImage(color: .blue)
        let itemID = UUID()
        let (photoURL, _) = try await photoService.savePhoto(image, for: itemID)

        // Measure time to load photo
        measure(metrics: [XCTClockMetric(), XCTMemoryMetric()]) {
            Task {
                _ = try? Data(contentsOf: photoURL)
            }
        }

        // Expected: < 50ms

        // Cleanup
        try await photoService.deletePhotos(for: itemID)
    }

    func testBatchPhotoSavePerformance() async throws {
        // Measure time to save 10 photos
        let photoService = PhotoStorageService.shared
        let images = (0..<10).map { _ in testFactory.createTestImage(color: .blue) }
        let itemIDs = (0..<10).map { _ in UUID() }

        measure(metrics: [XCTClockMetric(), XCTMemoryMetric(), XCTStorageMetric()]) {
            Task {
                for (index, image) in images.enumerated() {
                    _ = try? await photoService.savePhoto(image, for: itemIDs[index])
                }
            }
        }

        // Expected: < 2 seconds for 10 photos

        // Cleanup
        for itemID in itemIDs {
            try? await photoService.deletePhotos(for: itemID)
        }
    }

    // MARK: - Core Data Performance Tests

    func testCoreDataBatchFetchPerformance() async throws {
        // Measure batch fetch performance
        measure(metrics: [XCTClockMetric(), XCTMemoryMetric()]) {
            Task { @MainActor in
                let context = persistenceController.container.viewContext
                let request = WardrobeItemMO.fetchRequest()
                request.fetchBatchSize = 20
                _ = try? context.fetch(request)
            }
        }

        // Expected: < 50ms
    }

    func testCoreDataPredicatePerformance() async throws {
        // Measure predicate-based fetch performance
        measure(metrics: [XCTClockMetric()]) {
            Task { @MainActor in
                let context = persistenceController.container.viewContext
                let request = WardrobeItemMO.fetchRequest()
                request.predicate = NSPredicate(format: "category == %@", "tShirt")
                _ = try? context.fetch(request)
            }
        }

        // Expected: < 50ms
    }

    func testCoreDataSortPerformance() async throws {
        // Measure sorted fetch performance
        measure(metrics: [XCTClockMetric()]) {
            Task { @MainActor in
                let context = persistenceController.container.viewContext
                let request = WardrobeItemMO.fetchRequest()
                request.sortDescriptors = [
                    NSSortDescriptor(key: "timesWorn", ascending: false),
                    NSSortDescriptor(key: "purchaseDate", ascending: false)
                ]
                _ = try? context.fetch(request)
            }
        }

        // Expected: < 100ms
    }

    func testCoreDataSavePerformance() async throws {
        // Measure context save performance after multiple changes
        measure(metrics: [XCTClockMetric()]) {
            Task { @MainActor in
                let context = persistenceController.container.viewContext

                // Make 10 changes
                for _ in 0..<10 {
                    let mo = WardrobeItemMO(context: context)
                    mo.id = UUID()
                    mo.category = "tShirt"
                    mo.primaryColor = "#0000FF"
                    mo.timesWorn = 0
                    mo.isFavorite = false
                    mo.dateAdded = Date()
                }

                try? context.save()
            }
        }

        // Expected: < 100ms
    }

    // MARK: - Concurrent Operations Performance

    func testConcurrentFetchPerformance() async throws {
        // Measure concurrent fetch operations
        measure(metrics: [XCTClockMetric(), XCTMemoryMetric()]) {
            Task { @MainActor in
                await withTaskGroup(of: Void.self) { group in
                    for _ in 0..<10 {
                        group.addTask {
                            _ = try? await self.wardrobeRepository.fetchAll()
                        }
                    }
                }
            }
        }

        // Expected: < 500ms for 10 concurrent fetches
    }

    func testConcurrentCreatePerformance() async throws {
        // Measure concurrent create operations
        measure(metrics: [XCTClockMetric(), XCTMemoryMetric()]) {
            Task { @MainActor in
                await withTaskGroup(of: Void.self) { group in
                    for _ in 0..<10 {
                        group.addTask {
                            let item = self.testFactory.createTestWardrobeItem()
                            _ = try? await self.wardrobeRepository.create(item)
                        }
                    }
                }
            }
        }

        // Expected: < 500ms for 10 concurrent creates
    }

    func testConcurrentOutfitGenerationPerformance() async throws {
        // Measure concurrent outfit generation
        measure(metrics: [XCTClockMetric(), XCTCPUMetric(), XCTMemoryMetric()]) {
            Task { @MainActor in
                await withTaskGroup(of: Void.self) { group in
                    let occasions: [OccasionType] = [.casual, .work, .party, .dateNight, .gym]
                    for occasion in occasions {
                        group.addTask {
                            _ = try? await self.outfitGenerator.generateOutfits(for: occasion, limit: 2)
                        }
                    }
                }
            }
        }

        // Expected: < 2 seconds for 5 concurrent generations
    }

    // MARK: - Memory Stress Tests

    func testLargeDatasetMemoryUsage() async throws {
        // Test memory usage with 500 items
        measure(metrics: [XCTMemoryMetric()]) {
            Task { @MainActor in
                let items = testFactory.createSampleWardrobe(itemCount: 500)
                for item in items {
                    _ = try? await wardrobeRepository.create(item)
                }

                _ = try? await wardrobeRepository.fetchAll()

                // Cleanup
                for item in items {
                    try? await wardrobeRepository.delete(item.id)
                }
            }
        }

        // Expected: < 50MB peak memory
    }

    func testPhotoMemoryUsage() async throws {
        // Test memory usage with 20 photos
        let photoService = PhotoStorageService.shared
        var itemIDs: [UUID] = []

        measure(metrics: [XCTMemoryMetric()]) {
            Task {
                for _ in 0..<20 {
                    let image = testFactory.createTestImage(color: .blue)
                    let itemID = UUID()
                    itemIDs.append(itemID)
                    _ = try? await photoService.savePhoto(image, for: itemID)
                }
            }
        }

        // Expected: < 100MB peak memory

        // Cleanup
        for itemID in itemIDs {
            try? await photoService.deletePhotos(for: itemID)
        }
    }

    // MARK: - App Launch Performance

    func testAppLaunchPerformance() throws {
        // This test would measure app launch time
        // Requires XCTest launch metrics which are available in UI tests

        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }

        // Expected: < 2 seconds cold launch
        // Expected: < 500ms warm launch
    }

    // MARK: - Scrolling Performance

    func testScrollingPerformance() throws {
        // This test would measure scrolling performance in wardrobe grid
        // Requires UI testing framework

        let app = XCUIApplication()
        app.launch()

        measure(metrics: [XCTOSSignpostMetric.scrollDecelerationMetric]) {
            let collectionView = app.collectionViews.firstMatch
            collectionView.swipeUp(velocity: .fast)
            collectionView.swipeDown(velocity: .fast)
        }

        // Expected: Smooth 60 FPS scrolling
    }

    // MARK: - Animation Performance

    func testAnimationPerformance() throws {
        // This test would measure animation performance
        // Requires UI testing framework with XCTOSSignpostMetric

        let app = XCUIApplication()
        app.launch()

        measure(metrics: [XCTOSSignpostMetric.animationMetric]) {
            app.tabBars.buttons["Wardrobe"].tap()
            app.tabBars.buttons["Outfits"].tap()
            app.tabBars.buttons["AI"].tap()
        }

        // Expected: Smooth 60 FPS animations
    }
}
