//
//  InventoryItemTests.swift
//  PhysicalDigitalTwinsTests
//
//  Unit tests for InventoryItem model
//

import XCTest
@testable import PhysicalDigitalTwins

final class InventoryItemTests: XCTestCase {

    // MARK: - Test Data

    func createSampleBookTwin() -> BookTwin {
        BookTwin(
            title: "Test Book",
            author: "Test Author",
            isbn: "9781234567890",
            recognitionMethod: .manual
        )
    }

    // MARK: - Initialization Tests

    func testInventoryItemInitialization() {
        // Given
        let bookTwin = createSampleBookTwin()

        // When
        let item = InventoryItem(digitalTwin: bookTwin)

        // Then
        XCTAssertNotNil(item.id)
        XCTAssertEqual(item.digitalTwin.displayName, "Test Book")
        XCTAssertEqual(item.condition, .good, "Default condition should be good")
        XCTAssertTrue(item.photosPaths.isEmpty, "Photos should be empty by default")
        XCTAssertFalse(item.isLent, "isLent should be false by default")
        XCTAssertFalse(item.isFavorite, "isFavorite should be false by default")
    }

    func testInventoryItemWithCustomID() {
        // Given
        let bookTwin = createSampleBookTwin()
        let customID = UUID()

        // When
        let item = InventoryItem(
            id: customID,
            digitalTwin: bookTwin
        )

        // Then
        XCTAssertEqual(item.id, customID)
    }

    // MARK: - Mutability Tests

    func testInventoryItemMutability() {
        // Given
        let bookTwin = createSampleBookTwin()
        var item = InventoryItem(digitalTwin: bookTwin)

        // When
        item.purchasePrice = Decimal(29.99)
        item.purchaseStore = "Test Store"
        item.locationName = "Living Room"
        item.specificLocation = "Shelf 2"
        item.condition = .excellent
        item.notes = "Test notes"
        item.tags = ["fiction", "bestseller"]
        item.isFavorite = true

        // Then
        XCTAssertEqual(item.purchasePrice, Decimal(29.99))
        XCTAssertEqual(item.purchaseStore, "Test Store")
        XCTAssertEqual(item.locationName, "Living Room")
        XCTAssertEqual(item.specificLocation, "Shelf 2")
        XCTAssertEqual(item.condition, .excellent)
        XCTAssertEqual(item.notes, "Test notes")
        XCTAssertEqual(item.tags.count, 2)
        XCTAssertTrue(item.isFavorite)
    }

    func testPhotoPathsModification() {
        // Given
        let bookTwin = createSampleBookTwin()
        var item = InventoryItem(digitalTwin: bookTwin)

        // When
        item.photosPaths = ["photo1.jpg", "photo2.jpg", "photo3.jpg"]

        // Then
        XCTAssertEqual(item.photosPaths.count, 3)
        XCTAssertEqual(item.photosPaths[0], "photo1.jpg")
    }

    // MARK: - Lending Tests

    func testLendingFunctionality() {
        // Given
        let bookTwin = createSampleBookTwin()
        var item = InventoryItem(digitalTwin: bookTwin)

        // When
        item.isLent = true
        item.lentTo = "John Doe"
        item.lentDate = Date()
        item.expectedReturnDate = Date().addingTimeInterval(7 * 24 * 60 * 60) // 1 week

        // Then
        XCTAssertTrue(item.isLent)
        XCTAssertEqual(item.lentTo, "John Doe")
        XCTAssertNotNil(item.lentDate)
        XCTAssertNotNil(item.expectedReturnDate)
    }

    // MARK: - Condition Tests

    func testItemConditionEnum() {
        // Test all condition values
        XCTAssertEqual(ItemCondition.new.displayName, "New")
        XCTAssertEqual(ItemCondition.excellent.displayName, "Excellent")
        XCTAssertEqual(ItemCondition.good.displayName, "Good")
        XCTAssertEqual(ItemCondition.fair.displayName, "Fair")
        XCTAssertEqual(ItemCondition.poor.displayName, "Poor")
        XCTAssertEqual(ItemCondition.broken.displayName, "Broken")
    }

    // MARK: - Codable Tests

    func testInventoryItemCodable() throws {
        // Given
        let bookTwin = createSampleBookTwin()
        let originalItem = InventoryItem(digitalTwin: bookTwin)

        // When
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()

        let data = try encoder.encode(originalItem)
        let decodedItem = try decoder.decode(InventoryItem.self, from: data)

        // Then
        XCTAssertEqual(originalItem.id, decodedItem.id)
        XCTAssertEqual(originalItem.digitalTwin.displayName, decodedItem.digitalTwin.displayName)
        XCTAssertEqual(originalItem.condition, decodedItem.condition)
    }

    // MARK: - AnyDigitalTwin Tests

    func testAnyDigitalTwinTypeErasure() {
        // Given
        let bookTwin = createSampleBookTwin()
        let item = InventoryItem(digitalTwin: bookTwin)

        // When
        let erasedTwin = item.digitalTwin
        let retrievedBook: BookTwin? = erasedTwin.asTwin()

        // Then
        XCTAssertNotNil(retrievedBook)
        XCTAssertEqual(retrievedBook?.title, "Test Book")
        XCTAssertEqual(retrievedBook?.author, "Test Author")
    }

    func testAnyDigitalTwinProperties() {
        // Given
        let bookTwin = createSampleBookTwin()
        let item = InventoryItem(digitalTwin: bookTwin)

        // Then
        XCTAssertEqual(item.digitalTwin.displayName, "Test Book")
        XCTAssertEqual(item.digitalTwin.objectType, .book)
        XCTAssertEqual(item.digitalTwin.recognitionMethod, .manual)
    }

    // MARK: - Edge Cases

    func testEmptyValues() {
        // Given
        let bookTwin = createSampleBookTwin()
        var item = InventoryItem(digitalTwin: bookTwin)

        // When
        item.notes = ""
        item.tags = []
        item.photosPaths = []

        // Then
        XCTAssertEqual(item.notes, "")
        XCTAssertTrue(item.tags.isEmpty)
        XCTAssertTrue(item.photosPaths.isEmpty)
    }

    func testNilValues() {
        // Given
        let bookTwin = createSampleBookTwin()
        let item = InventoryItem(digitalTwin: bookTwin)

        // Then
        XCTAssertNil(item.purchaseDate)
        XCTAssertNil(item.purchasePrice)
        XCTAssertNil(item.purchaseStore)
        XCTAssertNil(item.currentValue)
        XCTAssertNil(item.locationName)
        XCTAssertNil(item.specificLocation)
        XCTAssertNil(item.conditionNotes)
        XCTAssertNil(item.lentTo)
        XCTAssertNil(item.lentDate)
        XCTAssertNil(item.expectedReturnDate)
        XCTAssertNil(item.notes)
    }
}
