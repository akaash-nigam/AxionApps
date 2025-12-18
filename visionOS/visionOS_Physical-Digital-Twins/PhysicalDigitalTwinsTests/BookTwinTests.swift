//
//  BookTwinTests.swift
//  PhysicalDigitalTwinsTests
//
//  Unit tests for BookTwin model
//

import XCTest
@testable import PhysicalDigitalTwins

final class BookTwinTests: XCTestCase {

    // MARK: - Initialization Tests

    func testBookTwinInitialization() {
        // Given & When
        let book = BookTwin(
            title: "Atomic Habits",
            author: "James Clear",
            isbn: "9780735211292",
            recognitionMethod: .barcode
        )

        // Then
        XCTAssertEqual(book.title, "Atomic Habits")
        XCTAssertEqual(book.author, "James Clear")
        XCTAssertEqual(book.isbn, "9780735211292")
        XCTAssertEqual(book.recognitionMethod, .barcode)
        XCTAssertEqual(book.objectType, .book)
        XCTAssertEqual(book.readingStatus, .unread, "Default reading status should be unread")
    }

    func testBookTwinWithAllFields() {
        // Given & When
        let book = BookTwin(
            title: "Test Book",
            author: "Test Author",
            isbn: "9781234567890",
            recognitionMethod: .manual,
            publisher: "Test Publisher",
            publishDate: "2024",
            pageCount: 300,
            categories: ["Fiction", "Mystery"],
            description: "A test book description",
            thumbnailURL: "https://example.com/image.jpg",
            averageRating: 4.5,
            ratingsCount: 1000,
            readingStatus: .reading
        )

        // Then
        XCTAssertEqual(book.title, "Test Book")
        XCTAssertEqual(book.author, "Test Author")
        XCTAssertEqual(book.publisher, "Test Publisher")
        XCTAssertEqual(book.publishDate, "2024")
        XCTAssertEqual(book.pageCount, 300)
        XCTAssertEqual(book.categories?.count, 2)
        XCTAssertEqual(book.description, "A test book description")
        XCTAssertEqual(book.averageRating, 4.5)
        XCTAssertEqual(book.ratingsCount, 1000)
        XCTAssertEqual(book.readingStatus, .reading)
    }

    // MARK: - Display Name Tests

    func testDisplayName() {
        // Given
        let book = BookTwin(
            title: "Test Book",
            author: "Test Author",
            isbn: nil,
            recognitionMethod: .manual
        )

        // When & Then
        XCTAssertEqual(book.displayName, "Test Book")
    }

    // MARK: - Reading Status Tests

    func testReadingStatusEnum() {
        // Test all reading status values
        XCTAssertEqual(ReadingStatus.unread.displayName, "Unread")
        XCTAssertEqual(ReadingStatus.reading.displayName, "Reading")
        XCTAssertEqual(ReadingStatus.completed.displayName, "Completed")
        XCTAssertEqual(ReadingStatus.dnf.displayName, "Did Not Finish")
    }

    func testReadingStatusUpdate() {
        // Given
        var book = BookTwin(
            title: "Test Book",
            author: "Test Author",
            isbn: nil,
            recognitionMethod: .manual
        )

        // When
        book.readingStatus = .completed

        // Then
        XCTAssertEqual(book.readingStatus, .completed)
    }

    // MARK: - Recognition Method Tests

    func testRecognitionMethodEnum() {
        // Test recognition methods
        XCTAssertEqual(RecognitionMethod.barcode.displayName, "Barcode")
        XCTAssertEqual(RecognitionMethod.manual.displayName, "Manual")
        XCTAssertEqual(RecognitionMethod.photo.displayName, "Photo")
        XCTAssertEqual(RecognitionMethod.ml.displayName, "ML Recognition")
    }

    // MARK: - Object Category Tests

    func testObjectCategory() {
        // Given
        let book = BookTwin(
            title: "Test",
            author: "Author",
            isbn: nil,
            recognitionMethod: .manual
        )

        // Then
        XCTAssertEqual(book.objectType, .book)
        XCTAssertEqual(book.objectType.displayName, "Book")
        XCTAssertEqual(book.objectType.iconName, "book.fill")
    }

    // MARK: - Codable Tests

    func testBookTwinCodable() throws {
        // Given
        let originalBook = BookTwin(
            title: "Codable Test",
            author: "Test Author",
            isbn: "9781234567890",
            recognitionMethod: .barcode,
            publisher: "Test Pub",
            pageCount: 250,
            readingStatus: .reading
        )

        // When
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()

        let data = try encoder.encode(originalBook)
        let decodedBook = try decoder.decode(BookTwin.self, from: data)

        // Then
        XCTAssertEqual(originalBook.title, decodedBook.title)
        XCTAssertEqual(originalBook.author, decodedBook.author)
        XCTAssertEqual(originalBook.isbn, decodedBook.isbn)
        XCTAssertEqual(originalBook.publisher, decodedBook.publisher)
        XCTAssertEqual(originalBook.pageCount, decodedBook.pageCount)
        XCTAssertEqual(originalBook.readingStatus, decodedBook.readingStatus)
    }

    // MARK: - Identifier Tests

    func testUniqueIdentifiers() {
        // Given
        let book1 = BookTwin(
            title: "Book 1",
            author: "Author",
            isbn: nil,
            recognitionMethod: .manual
        )

        let book2 = BookTwin(
            title: "Book 2",
            author: "Author",
            isbn: nil,
            recognitionMethod: .manual
        )

        // Then
        XCTAssertNotEqual(book1.id, book2.id, "Each book should have a unique ID")
    }

    // MARK: - Timestamp Tests

    func testCreatedAtTimestamp() {
        // Given
        let beforeCreation = Date()
        let book = BookTwin(
            title: "Test",
            author: "Author",
            isbn: nil,
            recognitionMethod: .manual
        )
        let afterCreation = Date()

        // Then
        XCTAssertTrue(book.createdAt >= beforeCreation)
        XCTAssertTrue(book.createdAt <= afterCreation)
        XCTAssertEqual(book.createdAt, book.updatedAt, "createdAt and updatedAt should be equal on creation")
    }

    // MARK: - Edge Cases

    func testMinimalBookTwin() {
        // Given & When
        let book = BookTwin(
            title: "T",
            author: "A",
            isbn: nil,
            recognitionMethod: .manual
        )

        // Then
        XCTAssertEqual(book.title, "T")
        XCTAssertEqual(book.author, "A")
        XCTAssertNil(book.isbn)
        XCTAssertNil(book.publisher)
        XCTAssertNil(book.pageCount)
        XCTAssertNil(book.categories)
        XCTAssertNil(book.description)
        XCTAssertNil(book.averageRating)
        XCTAssertNil(book.ratingsCount)
    }

    func testEmptyCategoriesArray() {
        // Given & When
        let book = BookTwin(
            title: "Test",
            author: "Author",
            isbn: nil,
            recognitionMethod: .manual,
            categories: []
        )

        // Then
        XCTAssertNotNil(book.categories)
        XCTAssertTrue(book.categories?.isEmpty == true)
    }

    // MARK: - Rating Tests

    func testValidRatings() {
        // Given & When
        let book = BookTwin(
            title: "Test",
            author: "Author",
            isbn: nil,
            recognitionMethod: .manual,
            averageRating: 3.7,
            ratingsCount: 500
        )

        // Then
        XCTAssertEqual(book.averageRating, 3.7)
        XCTAssertEqual(book.ratingsCount, 500)
    }

    func testNoRatings() {
        // Given & When
        let book = BookTwin(
            title: "Test",
            author: "Author",
            isbn: nil,
            recognitionMethod: .manual
        )

        // Then
        XCTAssertNil(book.averageRating)
        XCTAssertNil(book.ratingsCount)
    }
}
