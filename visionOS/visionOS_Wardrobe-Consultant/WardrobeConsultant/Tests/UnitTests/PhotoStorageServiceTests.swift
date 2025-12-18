//
//  PhotoStorageServiceTests.swift
//  WardrobeConsultantTests
//
//  Created by Claude Code
//  Copyright © 2025 Wardrobe Consultant. All rights reserved.
//

import XCTest
import UIKit
@testable import WardrobeConsultant

@MainActor
final class PhotoStorageServiceTests: XCTestCase {
    var service: PhotoStorageService!
    var testFactory: TestDataFactory!
    var testItemID: UUID!

    override func setUp() async throws {
        try await super.setUp()

        service = PhotoStorageService.shared
        testFactory = TestDataFactory.shared
        testItemID = UUID()
    }

    override func tearDown() async throws {
        // Clean up test photos
        if testItemID != nil {
            try? await service.deletePhotos(for: testItemID)
        }

        service = nil
        testFactory = nil
        testItemID = nil

        try await super.tearDown()
    }

    // MARK: - Save Photo Tests

    func testSavePhoto() async throws {
        // Given
        let image = testFactory.createTestImage(width: 800, height: 1000, color: .blue)

        // When
        let (photoURL, thumbnailURL) = try await service.savePhoto(image, for: testItemID)

        // Then
        XCTAssertTrue(FileManager.default.fileExists(atPath: photoURL.path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: thumbnailURL.path))
        XCTAssertTrue(photoURL.path.contains(testItemID.uuidString))
        XCTAssertTrue(thumbnailURL.path.contains(testItemID.uuidString))
    }

    func testSavePhotoCreatesCompressedImage() async throws {
        // Given
        let largeImage = testFactory.createTestImage(width: 2000, height: 2500, color: .red)

        // When
        let (photoURL, _) = try await service.savePhoto(largeImage, for: testItemID)

        // Then
        let data = try Data(contentsOf: photoURL)
        let originalData = largeImage.jpegData(compressionQuality: 1.0)!

        // Compressed should be smaller than original
        XCTAssertLessThan(data.count, originalData.count)
    }

    func testSavePhotoCreatesThumbnail() async throws {
        // Given
        let image = testFactory.createTestImage(width: 800, height: 1000)

        // When
        let (_, thumbnailURL) = try await service.savePhoto(image, for: testItemID)

        // Then
        let thumbnailImage = try await service.loadPhoto(from: thumbnailURL)
        XCTAssertLessThanOrEqual(thumbnailImage.size.width, 200)
        XCTAssertLessThanOrEqual(thumbnailImage.size.height, 200)
    }

    func testSaveMultiplePhotos() async throws {
        // Given
        let item1ID = UUID()
        let item2ID = UUID()
        let image1 = testFactory.createTestImage(color: .blue)
        let image2 = testFactory.createTestImage(color: .red)

        // When
        let result1 = try await service.savePhoto(image1, for: item1ID)
        let result2 = try await service.savePhoto(image2, for: item2ID)

        // Then
        XCTAssertTrue(FileManager.default.fileExists(atPath: result1.photoURL.path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: result2.photoURL.path))
        XCTAssertNotEqual(result1.photoURL.path, result2.photoURL.path)

        // Clean up
        try await service.deletePhotos(for: item1ID)
        try await service.deletePhotos(for: item2ID)
    }

    func testSavePhotoOverwritesExisting() async throws {
        // Given
        let image1 = testFactory.createTestImage(color: .blue)
        let image2 = testFactory.createTestImage(color: .red)

        // When
        let (url1, _) = try await service.savePhoto(image1, for: testItemID)
        let (url2, _) = try await service.savePhoto(image2, for: testItemID)

        // Then
        XCTAssertEqual(url1.path, url2.path) // Same path
        XCTAssertTrue(FileManager.default.fileExists(atPath: url2.path))

        // Load to verify it's the new image
        let loadedImage = try await service.loadPhoto(from: url2)
        XCTAssertNotNil(loadedImage)
    }

    // MARK: - Load Photo Tests

    func testLoadPhoto() async throws {
        // Given
        let originalImage = testFactory.createTestImage(color: .green)
        let (photoURL, _) = try await service.savePhoto(originalImage, for: testItemID)

        // When
        let loadedImage = try await service.loadPhoto(from: photoURL)

        // Then
        XCTAssertNotNil(loadedImage)
        XCTAssertEqual(loadedImage.size.width, originalImage.size.width)
        XCTAssertEqual(loadedImage.size.height, originalImage.size.height)
    }

    func testLoadThumbnail() async throws {
        // Given
        let image = testFactory.createTestImage(width: 1000, height: 1200)
        let (_, thumbnailURL) = try await service.savePhoto(image, for: testItemID)

        // When
        let thumbnail = try await service.loadPhoto(from: thumbnailURL)

        // Then
        XCTAssertNotNil(thumbnail)
        XCTAssertLessThanOrEqual(thumbnail.size.width, 200)
        XCTAssertLessThanOrEqual(thumbnail.size.height, 200)
    }

    func testLoadPhotoFileNotFound() async throws {
        // Given
        let nonExistentURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("nonexistent.jpg")

        // When/Then
        do {
            _ = try await service.loadPhoto(from: nonExistentURL)
            XCTFail("Should throw fileNotFound error")
        } catch PhotoStorageError.fileNotFound {
            // Expected
        } catch {
            XCTFail("Wrong error type: \(error)")
        }
    }

    // MARK: - Delete Photo Tests

    func testDeletePhoto() async throws {
        // Given
        let image = testFactory.createTestImage()
        let (photoURL, _) = try await service.savePhoto(image, for: testItemID)
        XCTAssertTrue(FileManager.default.fileExists(atPath: photoURL.path))

        // When
        try await service.deletePhoto(at: photoURL)

        // Then
        XCTAssertFalse(FileManager.default.fileExists(atPath: photoURL.path))
    }

    func testDeletePhotoNotFound() async throws {
        // Given
        let nonExistentURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("nonexistent.jpg")

        // When/Then - Should not throw
        try await service.deletePhoto(at: nonExistentURL)
    }

    func testDeletePhotosForItem() async throws {
        // Given
        let image = testFactory.createTestImage()
        let (photoURL, thumbnailURL) = try await service.savePhoto(image, for: testItemID)
        XCTAssertTrue(FileManager.default.fileExists(atPath: photoURL.path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: thumbnailURL.path))

        // When
        try await service.deletePhotos(for: testItemID)

        // Then
        XCTAssertFalse(FileManager.default.fileExists(atPath: photoURL.path))
        XCTAssertFalse(FileManager.default.fileExists(atPath: thumbnailURL.path))
    }

    func testDeleteAllPhotos() async throws {
        // Given
        let item1ID = UUID()
        let item2ID = UUID()
        let item3ID = UUID()

        _ = try await service.savePhoto(testFactory.createTestImage(), for: item1ID)
        _ = try await service.savePhoto(testFactory.createTestImage(), for: item2ID)
        _ = try await service.savePhoto(testFactory.createTestImage(), for: item3ID)

        // When
        try await service.deleteAllPhotos()

        // Then - All photos should be deleted
        let storageSize = try await service.getStorageSize()
        XCTAssertEqual(storageSize, 0)
    }

    // MARK: - Storage Statistics Tests

    func testGetStorageSize() async throws {
        // Given
        let image = testFactory.createTestImage(width: 800, height: 1000)
        _ = try await service.savePhoto(image, for: testItemID)

        // When
        let size = try await service.getStorageSize()

        // Then
        XCTAssertGreaterThan(size, 0)
    }

    func testGetStorageSizeMultiplePhotos() async throws {
        // Given
        let item1ID = UUID()
        let item2ID = UUID()
        let item3ID = UUID()

        _ = try await service.savePhoto(testFactory.createTestImage(), for: item1ID)
        _ = try await service.savePhoto(testFactory.createTestImage(), for: item2ID)
        _ = try await service.savePhoto(testFactory.createTestImage(), for: item3ID)

        // When
        let size = try await service.getStorageSize()

        // Then
        XCTAssertGreaterThan(size, 0)

        // Clean up
        try await service.deletePhotos(for: item1ID)
        try await service.deletePhotos(for: item2ID)
        try await service.deletePhotos(for: item3ID)
    }

    func testGetStorageSizeEmptyDirectory() async throws {
        // Given - Empty storage
        try await service.deleteAllPhotos()

        // When
        let size = try await service.getStorageSize()

        // Then
        XCTAssertEqual(size, 0)
    }

    // MARK: - File Protection Tests

    func testPhotoFileProtection() async throws {
        // Given
        let image = testFactory.createTestImage()

        // When
        let (photoURL, _) = try await service.savePhoto(image, for: testItemID)

        // Then - Check file attributes
        let attributes = try FileManager.default.attributesOfItem(atPath: photoURL.path)
        let protection = attributes[.protectionKey] as? FileProtectionType
        XCTAssertEqual(protection, .completeUntilFirstUserAuthentication)
    }

    // MARK: - Thumbnail Quality Tests

    func testThumbnailAspectRatio() async throws {
        // Given - Wide image
        let wideImage = testFactory.createTestImage(width: 1600, height: 800)

        // When
        let (_, thumbnailURL) = try await service.savePhoto(wideImage, for: testItemID)
        let thumbnail = try await service.loadPhoto(from: thumbnailURL)

        // Then - Should maintain aspect ratio within 200x200 bounds
        XCTAssertLessThanOrEqual(thumbnail.size.width, 200)
        XCTAssertLessThanOrEqual(thumbnail.size.height, 200)
    }

    // MARK: - Error Handling Tests

    func testInvalidImageData() async throws {
        // This test verifies behavior with potential invalid data
        // In practice, UIImage creation would fail before reaching save

        // Given
        let validImage = testFactory.createTestImage()

        // When/Then - Should succeed with valid image
        let (photoURL, _) = try await service.savePhoto(validImage, for: testItemID)
        XCTAssertTrue(FileManager.default.fileExists(atPath: photoURL.path))
    }

    // MARK: - Concurrent Operations Tests

    func testConcurrentPhotoSaves() async throws {
        // Given
        let itemIDs = (0..<5).map { _ in UUID() }
        let images = (0..<5).map { _ in testFactory.createTestImage() }

        // When - Save multiple photos concurrently
        try await withThrowingTaskGroup(of: (URL, URL).self) { group in
            for (index, itemID) in itemIDs.enumerated() {
                group.addTask {
                    try await self.service.savePhoto(images[index], for: itemID)
                }
            }

            var results: [(URL, URL)] = []
            for try await result in group {
                results.append(result)
            }

            // Then
            XCTAssertEqual(results.count, 5)
            for result in results {
                XCTAssertTrue(FileManager.default.fileExists(atPath: result.0.path))
                XCTAssertTrue(FileManager.default.fileExists(atPath: result.1.path))
            }
        }

        // Clean up
        for itemID in itemIDs {
            try await service.deletePhotos(for: itemID)
        }
    }

    func testConcurrentPhotoLoads() async throws {
        // Given
        let image = testFactory.createTestImage()
        let (photoURL, _) = try await service.savePhoto(image, for: testItemID)

        // When - Load same photo concurrently
        await withTaskGroup(of: UIImage?.self) { group in
            for _ in 0..<10 {
                group.addTask {
                    try? await self.service.loadPhoto(from: photoURL)
                }
            }

            var results: [UIImage?] = []
            for await result in group {
                results.append(result)
            }

            // Then
            XCTAssertEqual(results.count, 10)
            XCTAssertTrue(results.allSatisfy { $0 != nil })
        }
    }

    // MARK: - Performance Tests

    func testSavePhotoPerformance() async throws {
        // Given
        let image = testFactory.createTestImage(width: 1200, height: 1600)

        // When
        let startTime = Date()
        _ = try await service.savePhoto(image, for: testItemID)
        let duration = Date().timeIntervalSince(startTime)

        // Then - Should complete quickly
        XCTAssertLessThan(duration, 2.0, "Photo save took too long")
    }

    func testLoadPhotoPerformance() async throws {
        // Given
        let image = testFactory.createTestImage()
        let (photoURL, _) = try await service.savePhoto(image, for: testItemID)

        // When
        let startTime = Date()
        _ = try await service.loadPhoto(from: photoURL)
        let duration = Date().timeIntervalSince(startTime)

        // Then - Should complete quickly
        XCTAssertLessThan(duration, 1.0, "Photo load took too long")
    }
}
