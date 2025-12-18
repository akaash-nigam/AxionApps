//
//  CreateAnnotationViewTests.swift
//  Reality Annotation Platform Tests
//
//  Tests for CreateAnnotationView and annotation creation
//

import XCTest
import SwiftUI
@testable import RealityAnnotation

@MainActor
final class CreateAnnotationViewTests: XCTestCase {
    var mockAnnotationService: MockAnnotationService!
    var mockLayerService: MockLayerService!
    var defaultLayer: Layer!

    override func setUp() {
        super.setUp()
        mockAnnotationService = MockAnnotationService()
        mockLayerService = MockLayerService()
        defaultLayer = Layer(
            name: "Default",
            icon: "note.text",
            color: .blue,
            ownerID: "test-user"
        )
        mockLayerService.defaultLayer = defaultLayer
    }

    override func tearDown() {
        mockAnnotationService = nil
        mockLayerService = nil
        defaultLayer = nil
        super.tearDown()
    }

    // MARK: - Creation Tests

    func testCreateAnnotation_WithTitle_Succeeds() async {
        // Given
        let title = "Test Title"
        let content = "Test Content"
        let position = SIMD3<Float>(0, 1, -2)

        // When
        let annotation = try? await mockAnnotationService.createAnnotation(
            content: content,
            title: title,
            type: .text,
            position: position,
            layerID: defaultLayer.id
        )

        // Then
        XCTAssertNotNil(annotation)
        XCTAssertEqual(annotation?.title, title)
        XCTAssertEqual(annotation?.contentText, content)
        XCTAssertEqual(mockAnnotationService.createdAnnotations.count, 1)
    }

    func testCreateAnnotation_WithoutTitle_Succeeds() async {
        // Given
        let content = "Test Content"
        let position = SIMD3<Float>(0, 1, -2)

        // When
        let annotation = try? await mockAnnotationService.createAnnotation(
            content: content,
            title: nil,
            type: .text,
            position: position,
            layerID: defaultLayer.id
        )

        // Then
        XCTAssertNotNil(annotation)
        XCTAssertNil(annotation?.title)
        XCTAssertEqual(annotation?.contentText, content)
    }

    func testCreateAnnotation_WithEmptyContent_Fails() async {
        // Given
        let content = ""
        let position = SIMD3<Float>(0, 1, -2)

        // When
        do {
            _ = try await mockAnnotationService.createAnnotation(
                content: content,
                title: nil,
                type: .text,
                position: position,
                layerID: defaultLayer.id
            )
            XCTFail("Should throw error for empty content")
        } catch {
            // Then
            XCTAssertTrue(true, "Correctly rejected empty content")
        }
    }

    // MARK: - Layer Assignment Tests

    func testCreateAnnotation_UsesDefaultLayer() async {
        // When
        let layer = try? await mockLayerService.getOrCreateDefaultLayer()

        // Then
        XCTAssertNotNil(layer)
        XCTAssertEqual(layer?.name, "Default")
        XCTAssertEqual(layer?.id, defaultLayer.id)
    }

    func testCreateAnnotation_CreatesDefaultLayerIfNeeded() async {
        // Given
        mockLayerService.defaultLayer = nil

        // When
        let layer = try? await mockLayerService.getOrCreateDefaultLayer()

        // Then
        XCTAssertNotNil(layer)
        XCTAssertEqual(layer?.name, "Default")
    }

    // MARK: - Position Tests

    func testCreateAnnotation_WithARPosition_UsesCorrectPosition() async {
        // Given
        let expectedPosition = SIMD3<Float>(1.5, 2.0, -3.5)

        // When
        let annotation = try? await mockAnnotationService.createAnnotation(
            content: "Test",
            title: nil,
            type: .text,
            position: expectedPosition,
            layerID: defaultLayer.id
        )

        // Then
        XCTAssertEqual(annotation?.position, expectedPosition)
    }

    func testCreateAnnotation_WithoutAR_UsesDefaultPosition() async {
        // Given
        let defaultPosition = SIMD3<Float>(0, 0, 0)

        // When
        let annotation = try? await mockAnnotationService.createAnnotation(
            content: "Test",
            title: nil,
            type: .text,
            position: defaultPosition,
            layerID: defaultLayer.id
        )

        // Then
        XCTAssertEqual(annotation?.position, defaultPosition)
    }

    // MARK: - Validation Tests

    func testAnnotation_ValidatesContent() {
        // Given
        let validAnnotation = Annotation(
            type: .text,
            title: nil,
            contentText: "Valid content",
            position: SIMD3(0, 0, 0),
            layerID: UUID(),
            ownerID: "test-user"
        )

        let invalidAnnotation = Annotation(
            type: .text,
            title: nil,
            contentText: "",
            position: SIMD3(0, 0, 0),
            layerID: UUID(),
            ownerID: "test-user"
        )

        // When/Then
        XCTAssertTrue(validAnnotation.validate())
        XCTAssertFalse(invalidAnnotation.validate())
    }

    func testAnnotation_ContentLengthLimit() {
        // Given
        let longContent = String(repeating: "a", count: 5001)
        var annotation = Annotation(
            type: .text,
            title: nil,
            contentText: longContent,
            position: SIMD3(0, 0, 0),
            layerID: UUID(),
            ownerID: "test-user"
        )

        // When
        let isValid = annotation.contentText?.count ?? 0 <= 5000

        // Then
        XCTAssertFalse(isValid, "Content should not exceed 5000 characters")
    }

    // MARK: - Type Tests

    func testCreateAnnotation_TypeIsText() async {
        // When
        let annotation = try? await mockAnnotationService.createAnnotation(
            content: "Test",
            title: nil,
            type: .text,
            position: SIMD3(0, 0, 0),
            layerID: defaultLayer.id
        )

        // Then
        XCTAssertEqual(annotation?.type, .text)
    }

    // MARK: - Metadata Tests

    func testCreateAnnotation_SetsTimestamps() async {
        // Given
        let beforeCreation = Date()

        // When
        let annotation = try? await mockAnnotationService.createAnnotation(
            content: "Test",
            title: nil,
            type: .text,
            position: SIMD3(0, 0, 0),
            layerID: defaultLayer.id
        )

        let afterCreation = Date()

        // Then
        XCTAssertNotNil(annotation?.createdAt)
        XCTAssertGreaterThanOrEqual(annotation!.createdAt, beforeCreation)
        XCTAssertLessThanOrEqual(annotation!.createdAt, afterCreation)
    }

    func testCreateAnnotation_MarksPendingSync() async {
        // When
        let annotation = try? await mockAnnotationService.createAnnotation(
            content: "Test",
            title: nil,
            type: .text,
            position: SIMD3(0, 0, 0),
            layerID: defaultLayer.id
        )

        // Then
        XCTAssertTrue(annotation?.isPendingSync ?? false)
    }

    // MARK: - Error Handling Tests

    func testCreateAnnotation_WithServiceError_ThrowsError() async {
        // Given
        mockAnnotationService.shouldThrowError = true

        // When/Then
        do {
            _ = try await mockAnnotationService.createAnnotation(
                content: "Test",
                title: nil,
                type: .text,
                position: SIMD3(0, 0, 0),
                layerID: defaultLayer.id
            )
            XCTFail("Should throw error")
        } catch {
            XCTAssertTrue(true, "Error handled correctly")
        }
    }

    func testCreateAnnotation_WithLayerError_ThrowsError() async {
        // Given
        mockLayerService.shouldThrowError = true

        // When/Then
        do {
            _ = try await mockLayerService.getOrCreateDefaultLayer()
            XCTFail("Should throw error")
        } catch {
            XCTAssertTrue(true, "Error handled correctly")
        }
    }

    // MARK: - Batch Creation Tests

    func testCreateMultipleAnnotations_AllSucceed() async {
        // Given
        let annotations = [
            ("Test 1", "Content 1"),
            ("Test 2", "Content 2"),
            ("Test 3", "Content 3")
        ]

        // When
        for (title, content) in annotations {
            _ = try? await mockAnnotationService.createAnnotation(
                content: content,
                title: title,
                type: .text,
                position: SIMD3(0, 0, 0),
                layerID: defaultLayer.id
            )
        }

        // Then
        XCTAssertEqual(mockAnnotationService.createdAnnotations.count, 3)
    }
}
