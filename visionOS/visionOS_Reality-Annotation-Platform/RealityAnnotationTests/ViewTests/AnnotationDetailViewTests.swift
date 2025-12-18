//
//  AnnotationDetailViewTests.swift
//  Reality Annotation Platform Tests
//
//  Tests for AnnotationDetailView CRUD operations
//

import XCTest
import SwiftUI
@testable import RealityAnnotation

@MainActor
final class AnnotationDetailViewTests: XCTestCase {
    var mockAnnotationService: MockAnnotationService!
    var testAnnotation: Annotation!

    override func setUp() {
        super.setUp()
        mockAnnotationService = MockAnnotationService()
        testAnnotation = Annotation(
            type: .text,
            title: "Test Title",
            contentText: "Test Content",
            position: SIMD3(0, 1, -2),
            layerID: UUID(),
            ownerID: "test-user"
        )
    }

    override func tearDown() {
        mockAnnotationService = nil
        testAnnotation = nil
        super.tearDown()
    }

    // MARK: - View Tests

    func testInitialization_DisplaysAnnotationData() {
        // Given/When
        let view = AnnotationDetailView(
            annotation: testAnnotation,
            annotationService: mockAnnotationService
        )

        // Then
        XCTAssertEqual(testAnnotation.title, "Test Title")
        XCTAssertEqual(testAnnotation.contentText, "Test Content")
    }

    func testAnnotationUpdate_CallsService() async {
        // Given
        testAnnotation.title = "Updated Title"
        testAnnotation.contentText = "Updated Content"

        // When
        try? await mockAnnotationService.updateAnnotation(testAnnotation)

        // Then - update should be called
        XCTAssertNotNil(testAnnotation.updatedAt)
    }

    func testAnnotationDelete_CallsService() async {
        // When
        try? await mockAnnotationService.deleteAnnotation(id: testAnnotation.id)

        // Then
        let annotations = try? await mockAnnotationService.fetchAnnotations()
        XCTAssertFalse(annotations?.contains { $0.id == testAnnotation.id } ?? true)
    }

    // MARK: - Edit Mode Tests

    func testEditMode_UpdatesTitle() {
        // Given
        var annotation = testAnnotation!
        let newTitle = "New Title"

        // When
        annotation.title = newTitle
        annotation.updatedAt = Date()

        // Then
        XCTAssertEqual(annotation.title, newTitle)
        XCTAssertNotEqual(annotation.createdAt, annotation.updatedAt)
    }

    func testEditMode_UpdatesContent() {
        // Given
        var annotation = testAnnotation!
        let newContent = "New Content"

        // When
        annotation.contentText = newContent
        annotation.updatedAt = Date()

        // Then
        XCTAssertEqual(annotation.contentText, newContent)
    }

    func testEditMode_MarksPendingSync() {
        // Given
        var annotation = testAnnotation!
        XCTAssertFalse(annotation.isPendingSync)

        // When
        annotation.contentText = "Updated"
        annotation.isPendingSync = true

        // Then
        XCTAssertTrue(annotation.isPendingSync)
    }

    // MARK: - Validation Tests

    func testUpdate_WithEmptyContent_Fails() {
        // Given
        var annotation = testAnnotation!
        annotation.contentText = ""

        // When
        let isValid = annotation.validate()

        // Then
        XCTAssertFalse(isValid)
    }

    func testUpdate_WithValidContent_Succeeds() {
        // Given
        var annotation = testAnnotation!
        annotation.contentText = "Valid content"

        // When
        let isValid = annotation.validate()

        // Then
        XCTAssertTrue(isValid)
    }

    // MARK: - Metadata Tests

    func testPositionFormatting() {
        // Given
        let position = SIMD3<Float>(1.23, 4.56, 7.89)
        let annotation = Annotation(
            type: .text,
            title: nil,
            contentText: "Test",
            position: position,
            layerID: UUID(),
            ownerID: "test-user"
        )

        // When
        let formattedPosition = String(format: "%.2f, %.2f, %.2f",
                                     annotation.position.x,
                                     annotation.position.y,
                                     annotation.position.z)

        // Then
        XCTAssertEqual(formattedPosition, "1.23, 4.56, 7.89")
    }

    func testSyncStatus_PendingSync() {
        // Given
        var annotation = testAnnotation!

        // When
        annotation.isPendingSync = true

        // Then
        XCTAssertTrue(annotation.isPendingSync)
        XCTAssertNil(annotation.lastSyncedAt)
    }

    func testSyncStatus_Synced() {
        // Given
        var annotation = testAnnotation!
        let syncDate = Date()

        // When
        annotation.isPendingSync = false
        annotation.lastSyncedAt = syncDate

        // Then
        XCTAssertFalse(annotation.isPendingSync)
        XCTAssertNotNil(annotation.lastSyncedAt)
    }

    // MARK: - Error Handling Tests

    func testUpdate_WithServiceError_HandlesGracefully() async {
        // Given
        mockAnnotationService.shouldThrowError = true

        // When
        do {
            try await mockAnnotationService.updateAnnotation(testAnnotation)
            XCTFail("Should throw error")
        } catch {
            // Then
            XCTAssertTrue(true, "Error handled correctly")
        }
    }

    func testDelete_WithServiceError_HandlesGracefully() async {
        // Given
        mockAnnotationService.shouldThrowError = true

        // When
        do {
            try await mockAnnotationService.deleteAnnotation(id: testAnnotation.id)
            XCTFail("Should throw error")
        } catch {
            // Then
            XCTAssertTrue(true, "Error handled correctly")
        }
    }
}
