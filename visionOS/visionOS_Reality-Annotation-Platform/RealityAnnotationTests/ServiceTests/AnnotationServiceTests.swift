//
//  AnnotationServiceTests.swift
//  Reality Annotation Platform Tests
//
//  Unit tests for AnnotationService
//

import XCTest
@testable import RealityAnnotation

final class AnnotationServiceTests: XCTestCase {
    var sut: DefaultAnnotationService!
    var mockRepository: MockAnnotationRepository!
    let testUserID = "test-user-123"

    override func setUp() {
        super.setUp()
        mockRepository = MockAnnotationRepository()
        sut = DefaultAnnotationService(
            repository: mockRepository,
            currentUserID: testUserID
        )
    }

    override func tearDown() {
        sut = nil
        mockRepository = nil
        super.tearDown()
    }

    // MARK: - Create Annotation Tests

    func testCreateAnnotation_Success() async throws {
        // Given
        let content = "Test annotation content"
        let title = "Test Title"
        let position = SIMD3<Float>(0, 1, -2)
        let layerID = UUID()

        // When
        let annotation = try await sut.createAnnotation(
            content: content,
            title: title,
            type: .text,
            position: position,
            layerID: layerID
        )

        // Then
        XCTAssertEqual(annotation.contentText, content)
        XCTAssertEqual(annotation.title, title)
        XCTAssertEqual(annotation.position, position)
        XCTAssertEqual(annotation.layerID, layerID)
        XCTAssertEqual(annotation.ownerID, testUserID)
        XCTAssertEqual(mockRepository.annotations.count, 1)
    }

    func testCreateAnnotation_EmptyContent_ThrowsError() async {
        // Given
        let emptyContent = ""

        // When/Then
        do {
            _ = try await sut.createAnnotation(
                content: emptyContent,
                title: nil,
                type: .text,
                position: SIMD3(0, 0, 0),
                layerID: UUID()
            )
            XCTFail("Should have thrown emptyContent error")
        } catch {
            XCTAssertEqual(error as? AnnotationError, AnnotationError.emptyContent)
        }
    }

    // MARK: - Fetch Annotation Tests

    func testFetchAnnotations_ReturnsAllNonDeleted() async throws {
        // Given
        let annotation1 = createTestAnnotation(content: "Test 1")
        let annotation2 = createTestAnnotation(content: "Test 2")
        let deletedAnnotation = createTestAnnotation(content: "Deleted")
        deletedAnnotation.isDeleted = true

        mockRepository.annotations = [annotation1, annotation2, deletedAnnotation]

        // When
        let annotations = try await sut.fetchAnnotations()

        // Then
        XCTAssertEqual(annotations.count, 2)
        XCTAssertTrue(annotations.contains { $0.id == annotation1.id })
        XCTAssertTrue(annotations.contains { $0.id == annotation2.id })
        XCTAssertFalse(annotations.contains { $0.id == deletedAnnotation.id })
    }

    func testFetchAnnotationsByLayer_ReturnsCorrectAnnotations() async throws {
        // Given
        let layerID = UUID()
        let annotation1 = createTestAnnotation(content: "Test 1", layerID: layerID)
        let annotation2 = createTestAnnotation(content: "Test 2", layerID: layerID)
        let otherLayerAnnotation = createTestAnnotation(content: "Other", layerID: UUID())

        mockRepository.annotations = [annotation1, annotation2, otherLayerAnnotation]

        // When
        let annotations = try await sut.fetchAnnotations(in: layerID)

        // Then
        XCTAssertEqual(annotations.count, 2)
        XCTAssertTrue(annotations.allSatisfy { $0.layerID == layerID })
    }

    func testFetchNearbyAnnotations_ReturnsWithinRadius() async throws {
        // Given
        let position = SIMD3<Float>(0, 0, 0)
        let nearAnnotation = createTestAnnotation(content: "Near", position: SIMD3(0.5, 0.5, 0.5))
        let farAnnotation = createTestAnnotation(content: "Far", position: SIMD3(10, 10, 10))

        mockRepository.annotations = [nearAnnotation, farAnnotation]

        // When
        let annotations = try await sut.fetchNearby(position: position, radius: 2.0)

        // Then
        XCTAssertEqual(annotations.count, 1)
        XCTAssertEqual(annotations.first?.id, nearAnnotation.id)
    }

    // MARK: - Update Annotation Tests

    func testUpdateAnnotation_Success() async throws {
        // Given
        let annotation = createTestAnnotation(content: "Original")
        mockRepository.annotations = [annotation]

        // When
        annotation.contentText = "Updated"
        try await sut.updateAnnotation(annotation)

        // Then
        let updated = try await mockRepository.fetch(annotation.id)
        XCTAssertEqual(updated?.contentText, "Updated")
        XCTAssertEqual(updated?.syncStatus, "pending")
    }

    func testUpdateAnnotation_NotOwner_ThrowsError() async {
        // Given
        let annotation = createTestAnnotation(content: "Test")
        annotation.ownerID = "different-user"
        mockRepository.annotations = [annotation]

        // When/Then
        do {
            try await sut.updateAnnotation(annotation)
            XCTFail("Should have thrown notOwner error")
        } catch {
            XCTAssertEqual(error as? AnnotationError, AnnotationError.notOwner)
        }
    }

    // MARK: - Delete Annotation Tests

    func testDeleteAnnotation_Success() async throws {
        // Given
        let annotation = createTestAnnotation(content: "To Delete")
        mockRepository.annotations = [annotation]

        // When
        try await sut.deleteAnnotation(id: annotation.id)

        // Then
        let deleted = try await mockRepository.fetch(annotation.id)
        XCTAssertTrue(deleted?.isDeleted ?? false)
        XCTAssertNotNil(deleted?.deletedAt)
    }

    func testDeleteAnnotation_NotFound_ThrowsError() async {
        // Given
        let nonExistentID = UUID()

        // When/Then
        do {
            try await sut.deleteAnnotation(id: nonExistentID)
            XCTFail("Should have thrown notFound error")
        } catch {
            XCTAssertEqual(error as? AnnotationError, AnnotationError.notFound)
        }
    }

    // MARK: - Helper Methods

    private func createTestAnnotation(
        content: String,
        position: SIMD3<Float> = SIMD3(0, 1, -2),
        layerID: UUID = UUID()
    ) -> Annotation {
        return Annotation(
            type: .text,
            title: nil,
            contentText: content,
            position: position,
            layerID: layerID,
            ownerID: testUserID
        )
    }
}
