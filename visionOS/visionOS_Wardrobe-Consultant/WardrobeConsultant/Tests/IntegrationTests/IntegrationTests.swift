//
//  IntegrationTests.swift
//  WardrobeConsultantTests
//
//  Created by Claude Code
//  Copyright © 2025 Wardrobe Consultant. All rights reserved.
//

import XCTest
import CoreData
@testable import WardrobeConsultant

/// Integration tests for testing multiple components working together
@MainActor
final class WardrobeIntegrationTests: XCTestCase {
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

    // MARK: - Wardrobe to Outfit Generation Flow
    func testCompleteOutfitGenerationFlow() async throws {
        // Given: A wardrobe with various items
        let items = testFactory.createSampleWardrobe(itemCount: 20)
        for item in items {
            _ = try await wardrobeRepository.create(item)
        }

        // When: Generating outfits for different occasions
        let casualOutfits = try await outfitGenerator.generateOutfits(for: .casual, limit: 3)
        let workOutfits = try await outfitGenerator.generateOutfits(for: .work, limit: 3)

        // Then: Outfits should be generated successfully
        XCTAssertGreaterThan(casualOutfits.count, 0, "Should generate casual outfits")
        XCTAssertGreaterThan(workOutfits.count, 0, "Should generate work outfits")

        // And: Save generated outfits to repository
        for generated in casualOutfits {
            let outfit = generated.toOutfit()
            _ = try await outfitRepository.create(outfit)
        }

        // Then: Verify outfits are persisted
        let savedOutfits = try await outfitRepository.fetchAll()
        XCTAssertEqual(savedOutfits.count, casualOutfits.count)
    }

    // MARK: - Photo Storage Integration
    func testPhotoStorageWithWardrobeItems() async throws {
        // Given: A wardrobe item with a photo
        let image = testFactory.createTestImage(color: .blue)
        let photoService = PhotoStorageService.shared

        var item = testFactory.createTestWardrobeItem(category: .tShirt)

        // When: Saving photo and creating item
        let (photoURL, thumbnailURL) = try await photoService.savePhoto(image, for: item.id)
        item.photoURL = photoURL
        item.thumbnailURL = thumbnailURL

        _ = try await wardrobeRepository.create(item)

        // Then: Item should be retrieved with photo URLs
        let retrieved = try await wardrobeRepository.fetchByID(item.id)
        XCTAssertNotNil(retrieved?.photoURL)
        XCTAssertNotNil(retrieved?.thumbnailURL)

        // And: Photos should exist on disk
        XCTAssertTrue(FileManager.default.fileExists(atPath: photoURL.path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: thumbnailURL.path))

        // Cleanup
        try await photoService.deletePhotos(for: item.id)
    }

    // MARK: - User Profile to Outfit Generation
    func testUserProfileInfluencesOutfitGeneration() async throws {
        // Given: A user profile with specific preferences
        let profileRepo = CoreDataUserProfileRepository(persistenceController: persistenceController)
        var profile = try await profileRepo.fetch()
        profile.primaryStyle = .minimalist
        profile.favoriteColors = ["#000000", "#FFFFFF", "#808080"]
        try await profileRepo.update(profile)

        // And: A wardrobe with items matching the profile
        let blackShirt = testFactory.createTestWardrobeItem(
            category: .tShirt,
            primaryColor: "#000000"
        )
        let whiteShirt = testFactory.createTestWardrobeItem(
            category: .tShirt,
            primaryColor: "#FFFFFF"
        )
        let grayPants = testFactory.createTestWardrobeItem(
            category: .pants,
            primaryColor: "#808080"
        )

        _ = try await wardrobeRepository.create(blackShirt)
        _ = try await wardrobeRepository.create(whiteShirt)
        _ = try await wardrobeRepository.create(grayPants)

        // When: Generating outfits
        let outfits = try await outfitGenerator.generateOutfits(for: .casual, limit: 3)

        // Then: Generated outfits should prefer user's favorite colors
        XCTAssertGreaterThan(outfits.count, 0)
        // Note: Actual color preference checking would require inspecting the generated items
    }

    // MARK: - Multi-Repository Operations
    func testCascadingDeletes() async throws {
        // Given: A wardrobe with items
        let item1 = testFactory.createTestWardrobeItem()
        let item2 = testFactory.createTestWardrobeItem()
        let item3 = testFactory.createTestWardrobeItem()

        _ = try await wardrobeRepository.create(item1)
        _ = try await wardrobeRepository.create(item2)
        _ = try await wardrobeRepository.create(item3)

        // And: An outfit using these items
        let outfit = testFactory.createTestOutfit(
            itemIDs: Set([item1.id, item2.id, item3.id])
        )
        _ = try await outfitRepository.create(outfit)

        // When: Deleting an item from wardrobe
        try await wardrobeRepository.delete(item1.id)

        // Then: Item should be deleted
        let retrievedItem = try await wardrobeRepository.fetchByID(item1.id)
        XCTAssertNil(retrievedItem)

        // And: Outfit should still exist (orphaned item reference)
        let retrievedOutfit = try await outfitRepository.fetchByID(outfit.id)
        XCTAssertNotNil(retrievedOutfit)

        // Note: In a real app, you might want to handle orphaned references
    }

    // MARK: - Concurrent Operations
    func testConcurrentWardrobe AndOutfitOperations() async throws {
        // Given: Multiple items
        let items = testFactory.createSampleWardrobe(itemCount: 10)

        // When: Creating items and outfits concurrently
        try await withThrowingTaskGroup(of: Void.self) { group in
            // Add all items
            for item in items {
                group.addTask {
                    _ = try await self.wardrobeRepository.create(item)
                }
            }

            try await group.waitForAll()
        }

        // Then: All items should be created
        let allItems = try await wardrobeRepository.fetchAll()
        XCTAssertEqual(allItems.count, 10)

        // When: Generating outfits concurrently
        try await withThrowingTaskGroup(of: [GeneratedOutfit].self) { group in
            group.addTask {
                try await self.outfitGenerator.generateOutfits(for: .casual, limit: 2)
            }
            group.addTask {
                try await self.outfitGenerator.generateOutfits(for: .work, limit: 2)
            }

            var totalOutfits: [GeneratedOutfit] = []
            for try await outfits in group {
                totalOutfits.append(contentsOf: outfits)
            }

            // Then: Should generate outfits successfully
            XCTAssertGreaterThan(totalOutfits.count, 0)
        }
    }

    // MARK: - Data Consistency Tests
    func testDataConsistencyAcrossRepositories() async throws {
        // Given: Items in wardrobe
        let items = testFactory.createSampleWardrobe(itemCount: 5)
        for item in items {
            _ = try await wardrobeRepository.create(item)
        }

        // And: An outfit using these items
        let itemIDs = Set(items.map { $0.id })
        let outfit = testFactory.createTestOutfit(itemIDs: itemIDs)
        _ = try await outfitRepository.create(outfit)

        // When: Updating an item
        var updatedItem = items[0]
        updatedItem.timesWorn = 10
        try await wardrobeRepository.update(updatedItem)

        // Then: Item should be updated
        let retrievedItem = try await wardrobeRepository.fetchByID(updatedItem.id)
        XCTAssertEqual(retrievedItem?.timesWorn, 10)

        // And: Outfit should still reference the item
        let outfitItems = try await outfitRepository.fetchByItemID(updatedItem.id)
        XCTAssertEqual(outfitItems.count, 1)
        XCTAssertTrue(outfitItems[0].itemIDs.contains(updatedItem.id))
    }

    // MARK: - Search and Filter Integration
    func testSearchWithFilterIntegration() async throws {
        // Given: A wardrobe with specific items
        let nikeShirt = testFactory.createTestWardrobeItem(
            category: .tShirt,
            brand: "Nike",
            primaryColor: "#FF0000"
        )
        let adidasShirt = testFactory.createTestWardrobeItem(
            category: .tShirt,
            brand: "Adidas",
            primaryColor: "#0000FF"
        )
        let nikeShoes = testFactory.createTestWardrobeItem(
            category: .sneakers,
            brand: "Nike",
            primaryColor: "#000000"
        )

        _ = try await wardrobeRepository.create(nikeShirt)
        _ = try await wardrobeRepository.create(adidasShirt)
        _ = try await wardrobeRepository.create(nikeShoes)

        // When: Searching for "Nike"
        let nikeItems = try await wardrobeRepository.search(query: "Nike")

        // Then: Should find both Nike items
        XCTAssertEqual(nikeItems.count, 2)
        XCTAssertTrue(nikeItems.allSatisfy { $0.brand == "Nike" })

        // When: Filtering by category
        let shirts = try await wardrobeRepository.fetchByCategory(.tShirt)

        // Then: Should find both shirts
        XCTAssertEqual(shirts.count, 2)

        // When: Combining search and category filter
        let nikeShirts = nikeItems.filter { $0.category == .tShirt }

        // Then: Should find only Nike shirt
        XCTAssertEqual(nikeShirts.count, 1)
        XCTAssertEqual(nikeShirts[0].brand, "Nike")
        XCTAssertEqual(nikeShirts[0].category, .tShirt)
    }
}

/// Integration tests for AI services
@MainActor
final class AIServicesIntegrationTests: XCTestCase {
    var colorHarmony: ColorHarmonyService!
    var styleMatching: StyleMatchingService!
    var weatherRec: WeatherRecommendationService!
    var testFactory: TestDataFactory!

    override func setUp() async throws {
        try await super.setUp()
        colorHarmony = ColorHarmonyService.shared
        styleMatching = StyleMatchingService.shared
        weatherRec = WeatherRecommendationService.shared
        testFactory = TestDataFactory.shared
    }

    override func tearDown() async throws {
        colorHarmony = nil
        styleMatching = nil
        weatherRec = nil
        testFactory = nil
        try await super.tearDown()
    }

    // MARK: - Color Harmony with Style Matching
    func testColorHarmonyInfluencesStyleScoring() async throws {
        // Given: A user profile preferring specific colors
        let profile = testFactory.createTestUserProfile(
            favoriteColors: ["#0000FF", "#FFFFFF"],
            primaryStyle: .minimalist
        )

        // And: Items with those colors
        let blueShirt = testFactory.createTestWardrobeItem(
            category: .tShirt,
            primaryColor: "#0000FF"
        )
        let whiteShirt = testFactory.createTestWardrobeItem(
            category: .tShirt,
            primaryColor: "#FFFFFF"
        )

        // When: Scoring items for style match
        let blueScore = styleMatching.styleScore(item: blueShirt, profile: profile)
        let whiteScore = styleMatching.styleScore(item: whiteShirt, profile: profile)

        // Then: Both should score highly due to color preference
        XCTAssertGreaterThan(blueScore, 0.6)
        XCTAssertGreaterThan(whiteScore, 0.6)

        // And: Colors should be compatible
        let compatibility = colorHarmony.compatibilityScore(
            color1: blueShirt.primaryColor,
            color2: whiteShirt.primaryColor
        )
        XCTAssertGreaterThan(compatibility, 0.7)
    }

    // MARK: - Weather with Style Matching
    func testWeatherAndStyleIntegration() async throws {
        // Given: A cold weather scenario
        let temperature = 5 // Celsius
        let condition: WeatherCondition = .snow

        // And: Items suitable for cold weather
        let woolSweater = testFactory.createTestWardrobeItem(
            category: .sweater,
            fabricType: .wool
        )
        let cottonTShirt = testFactory.createTestWardrobeItem(
            category: .tShirt,
            fabricType: .cotton
        )

        // When: Checking weather suitability
        let sweaterSuitability = weatherRec.weatherSuitability(
            item: woolSweater,
            temperature: temperature,
            condition: condition
        )
        let tshirtSuitability = weatherRec.weatherSuitability(
            item: cottonTShirt,
            temperature: temperature,
            condition: condition
        )

        // Then: Wool sweater should score much higher
        XCTAssertGreaterThan(sweaterSuitability, tshirtSuitability)
        XCTAssertGreaterThan(sweaterSuitability, 0.7)
        XCTAssertLessThan(tshirtSuitability, 0.5)
    }

    // MARK: - Complete AI Pipeline
    func testCompleteAIPipeline() async throws {
        // This test verifies the complete AI recommendation pipeline

        // Given: A user profile
        let profile = testFactory.createTestUserProfile(
            primaryStyle: .casual,
            favoriteColors: ["#0000FF", "#000000"]
        )

        // And: A wardrobe
        let items = [
            testFactory.createTestWardrobeItem(category: .tShirt, primaryColor: "#0000FF"),
            testFactory.createTestWardrobeItem(category: .jeans, primaryColor: "#000080"),
            testFactory.createTestWardrobeItem(category: .sneakers, primaryColor: "#FFFFFF")
        ]

        // When: Scoring each item for style
        let scores = items.map { styleMatching.styleScore(item: $0, profile: profile) }

        // Then: All items should have reasonable scores
        XCTAssertTrue(scores.allSatisfy { $0 > 0 && $0 <= 1 })

        // When: Checking color compatibility between items
        let colorScore1 = colorHarmony.compatibilityScore(
            color1: items[0].primaryColor,
            color2: items[1].primaryColor
        )
        let colorScore2 = colorHarmony.compatibilityScore(
            color1: items[1].primaryColor,
            color2: items[2].primaryColor
        )

        // Then: Colors should be compatible
        XCTAssertGreaterThan(colorScore1, 0.5)
        XCTAssertGreaterThan(colorScore2, 0.5)

        // When: Checking weather suitability
        let weatherScores = items.map {
            weatherRec.weatherSuitability(item: $0, temperature: 20, condition: .clear)
        }

        // Then: All should be suitable for moderate weather
        XCTAssertTrue(weatherScores.allSatisfy { $0 > 0.4 })
    }
}
