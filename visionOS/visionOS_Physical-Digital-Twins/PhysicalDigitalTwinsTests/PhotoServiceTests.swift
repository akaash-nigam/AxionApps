//
//  PhotoServiceTests.swift
//  PhysicalDigitalTwinsTests
//
//  Unit tests for PhotoService
//

import XCTest
import UIKit
@testable import PhysicalDigitalTwins

final class PhotoServiceTests: XCTestCase {

    var photoService: FileSystemPhotoService!
    var testItemID: UUID!

    override func setUpWithError() throws {
        try super.setUpWithError()
        photoService = FileSystemPhotoService()
        testItemID = UUID()
    }

    override func tearDownWithError() throws {
        // Clean up any test photos
        try? await cleanupTestPhotos()
        photoService = nil
        testItemID = nil
        try super.tearDownWithError()
    }

    // MARK: - Helper Methods

    func createTestImage(color: UIColor = .red, size: CGSize = CGSize(width: 100, height: 100)) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            color.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }
    }

    func cleanupTestPhotos() async throws {
        // This would need to access the photos directory and clean up
        // In a real test environment with proper setup
    }

    // MARK: - Save Photo Tests

    func testSavePhoto() async throws {
        // Given
        let testImage = createTestImage()

        // When
        let savedPath = try await photoService.savePhoto(testImage, itemId: testItemID)

        // Then
        XCTAssertFalse(savedPath.isEmpty, "Saved path should not be empty")
        XCTAssertTrue(savedPath.contains(testItemID.uuidString), "Path should contain item ID")
        XCTAssertTrue(savedPath.hasSuffix(".jpg"), "Path should be a JPEG file")
    }

    func testSavePhotoGeneratesUniquePaths() async throws {
        // Given
        let testImage = createTestImage()

        // When
        let path1 = try await photoService.savePhoto(testImage, itemId: testItemID)
        // Small delay to ensure different timestamp
        try await Task.sleep(nanoseconds: 10_000_000) // 10ms
        let path2 = try await photoService.savePhoto(testImage, itemId: testItemID)

        // Then
        XCTAssertNotEqual(path1, path2, "Each save should generate a unique path")
    }

    func testSavePhotoForDifferentItems() async throws {
        // Given
        let testImage = createTestImage()
        let itemID1 = UUID()
        let itemID2 = UUID()

        // When
        let path1 = try await photoService.savePhoto(testImage, itemId: itemID1)
        let path2 = try await photoService.savePhoto(testImage, itemId: itemID2)

        // Then
        XCTAssertTrue(path1.contains(itemID1.uuidString))
        XCTAssertTrue(path2.contains(itemID2.uuidString))
    }

    // MARK: - Load Photo Tests

    func testLoadPhotoAfterSave() async throws {
        // Given
        let originalImage = createTestImage(color: .blue)
        let savedPath = try await photoService.savePhoto(originalImage, itemId: testItemID)

        // When
        let loadedImage = try await photoService.loadPhoto(path: savedPath)

        // Then
        XCTAssertNotNil(loadedImage)
        XCTAssertEqual(loadedImage.size, originalImage.size)
    }

    func testLoadPhotoThrowsForInvalidPath() async {
        // Given
        let invalidPath = "nonexistent_file.jpg"

        // When & Then
        do {
            _ = try await photoService.loadPhoto(path: invalidPath)
            XCTFail("Should throw PhotoError.fileNotFound")
        } catch let error as PhotoError {
            XCTAssertEqual(error, PhotoError.fileNotFound)
        } catch {
            XCTFail("Should throw PhotoError, got \(error)")
        }
    }

    // MARK: - Delete Photo Tests

    func testDeletePhoto() async throws {
        // Given
        let testImage = createTestImage()
        let savedPath = try await photoService.savePhoto(testImage, itemId: testItemID)

        // When
        try await photoService.deletePhoto(path: savedPath)

        // Then - should throw when trying to load deleted photo
        do {
            _ = try await photoService.loadPhoto(path: savedPath)
            XCTFail("Loading deleted photo should throw")
        } catch {
            // Expected
        }
    }

    func testDeleteNonexistentPhotoDoesNotThrow() async {
        // Given
        let nonexistentPath = "nonexistent_photo.jpg"

        // When & Then - should not throw
        do {
            try await photoService.deletePhoto(path: nonexistentPath)
        } catch {
            XCTFail("Deleting nonexistent photo should not throw")
        }
    }

    // MARK: - Delete All Photos Tests

    func testDeleteAllPhotos() async throws {
        // Given
        let testImage = createTestImage()
        let path1 = try await photoService.savePhoto(testImage, itemId: testItemID)
        let path2 = try await photoService.savePhoto(testImage, itemId: testItemID)
        let path3 = try await photoService.savePhoto(testImage, itemId: testItemID)

        let paths = [path1, path2, path3]

        // When
        try await photoService.deleteAllPhotos(paths: paths)

        // Then - all photos should be deleted
        for path in paths {
            do {
                _ = try await photoService.loadPhoto(path: path)
                XCTFail("Loading deleted photo should throw")
            } catch {
                // Expected
            }
        }
    }

    func testDeleteAllPhotosWithEmptyArray() async {
        // Given
        let emptyPaths: [String] = []

        // When & Then - should not throw
        do {
            try await photoService.deleteAllPhotos(paths: emptyPaths)
        } catch {
            XCTFail("Deleting empty array should not throw")
        }
    }

    // MARK: - Photo Error Tests

    func testPhotoErrorDescriptions() {
        XCTAssertNotNil(PhotoError.compressionFailed.errorDescription)
        XCTAssertNotNil(PhotoError.fileNotFound.errorDescription)
        XCTAssertNotNil(PhotoError.invalidImageData.errorDescription)
        XCTAssertNotNil(PhotoError.saveFailed.errorDescription)
        XCTAssertNotNil(PhotoError.deleteFailed.errorDescription)
    }

    // MARK: - Image Quality Tests

    func testPhotoCompressionQuality() async throws {
        // Given
        let largeImage = createTestImage(size: CGSize(width: 1000, height: 1000))

        // When
        let savedPath = try await photoService.savePhoto(largeImage, itemId: testItemID)
        let loadedImage = try await photoService.loadPhoto(path: savedPath)

        // Then
        XCTAssertNotNil(loadedImage)
        // Image should be loaded successfully even after JPEG compression
        XCTAssertEqual(loadedImage.size.width, 1000, accuracy: 1.0)
        XCTAssertEqual(loadedImage.size.height, 1000, accuracy: 1.0)
    }

    // MARK: - Concurrency Tests

    func testConcurrentSaves() async throws {
        // Given
        let testImage = createTestImage()

        // When - save multiple photos concurrently
        async let path1 = photoService.savePhoto(testImage, itemId: testItemID)
        async let path2 = photoService.savePhoto(testImage, itemId: testItemID)
        async let path3 = photoService.savePhoto(testImage, itemId: testItemID)

        let paths = try await [path1, path2, path3]

        // Then - all paths should be unique
        let uniquePaths = Set(paths)
        XCTAssertEqual(uniquePaths.count, 3, "All concurrent saves should produce unique paths")
    }

    // MARK: - Performance Tests

    func testSavePhotoPerformance() throws {
        let testImage = createTestImage()

        measure {
            Task {
                _ = try? await photoService.savePhoto(testImage, itemId: testItemID)
            }
        }
    }
}
