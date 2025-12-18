//
//  AnnotationFlowIntegrationTests.swift
//  Reality Annotation Platform Tests
//
//  Integration tests for complete annotation flows
//

import XCTest
@testable import RealityAnnotation

@MainActor
final class AnnotationFlowIntegrationTests: XCTestCase {
    var serviceContainer: ServiceContainer!
    var annotationService: AnnotationService!
    var layerService: LayerService!

    override func setUp() {
        super.setUp()
        // Use in-memory container for testing
        serviceContainer = ServiceContainer(modelContainer: nil)
        annotationService = serviceContainer.annotationService
        layerService = serviceContainer.layerService
    }

    override func tearDown() {
        serviceContainer = nil
        annotationService = nil
        layerService = nil
        super.tearDown()
    }

    // MARK: - Create-Read-Update-Delete Flow

    func testCompleteAnnotationCRUDFlow() async throws {
        // CREATE
        let layer = try await layerService.getOrCreateDefaultLayer()
        let annotation = try await annotationService.createAnnotation(
            content: "Test annotation",
            title: "Test",
            type: .text,
            position: SIMD3(0, 1, -2),
            layerID: layer.id
        )

        XCTAssertNotNil(annotation)
        XCTAssertEqual(annotation.contentText, "Test annotation")
        XCTAssertTrue(annotation.isPendingSync)

        // READ
        let fetchedAnnotations = try await annotationService.fetchAnnotations()
        XCTAssertEqual(fetchedAnnotations.count, 1)
        XCTAssertEqual(fetchedAnnotations.first?.id, annotation.id)

        // UPDATE
        var updatedAnnotation = annotation
        updatedAnnotation.contentText = "Updated content"
        try await annotationService.updateAnnotation(updatedAnnotation)

        let refetchedAnnotations = try await annotationService.fetchAnnotations()
        XCTAssertEqual(refetchedAnnotations.first?.contentText, "Updated content")

        // DELETE
        try await annotationService.deleteAnnotation(id: annotation.id)

        let finalAnnotations = try await annotationService.fetchAnnotations()
        XCTAssertEqual(finalAnnotations.count, 0)
    }

    // MARK: - Multi-Annotation Scenarios

    func testCreateMultipleAnnotationsInSameLayer() async throws {
        let layer = try await layerService.getOrCreateDefaultLayer()

        // Create multiple annotations
        for i in 1...5 {
            _ = try await annotationService.createAnnotation(
                content: "Annotation \(i)",
                title: "Test \(i)",
                type: .text,
                position: SIMD3(Float(i), 1, -2),
                layerID: layer.id
            )
        }

        let annotations = try await annotationService.fetchAnnotations()
        XCTAssertEqual(annotations.count, 5)

        // Verify all are in the same layer
        XCTAssertTrue(annotations.allSatisfy { $0.layerID == layer.id })
    }

    func testAnnotationPersistenceAcrossReads() async throws {
        // Create annotation
        let layer = try await layerService.getOrCreateDefaultLayer()
        let originalAnnotation = try await annotationService.createAnnotation(
            content: "Persistent annotation",
            title: "Persistence Test",
            type: .text,
            position: SIMD3(1, 2, 3),
            layerID: layer.id
        )

        // Read multiple times
        for _ in 1...3 {
            let annotations = try await annotationService.fetchAnnotations()
            XCTAssertEqual(annotations.count, 1)
            XCTAssertEqual(annotations.first?.id, originalAnnotation.id)
            XCTAssertEqual(annotations.first?.contentText, "Persistent annotation")
        }
    }

    // MARK: - Service Integration Tests

    func testServiceLayerValidation() async throws {
        let layer = try await layerService.getOrCreateDefaultLayer()

        // Should fail with empty content
        do {
            _ = try await annotationService.createAnnotation(
                content: "",
                title: "Test",
                type: .text,
                position: SIMD3(0, 0, 0),
                layerID: layer.id
            )
            XCTFail("Should throw error for empty content")
        } catch AnnotationError.emptyContent {
            // Expected
        }
    }

    // MARK: - Layer Integration

    func testAnnotationsFilterByLayer() async throws {
        // Create two layers (would need multi-layer support)
        let layer1 = try await layerService.getOrCreateDefaultLayer()

        // Create annotations in layer1
        let annotation1 = try await annotationService.createAnnotation(
            content: "In layer 1",
            title: nil,
            type: .text,
            position: SIMD3(0, 0, 0),
            layerID: layer1.id
        )

        // Fetch by layer
        let layer1Annotations = try await annotationService.fetchAnnotations(in: layer1.id)
        XCTAssertEqual(layer1Annotations.count, 1)
        XCTAssertEqual(layer1Annotations.first?.id, annotation1.id)
    }

    // MARK: - Nearby Annotations

    func testFetchNearbyAnnotations() async throws {
        let layer = try await layerService.getOrCreateDefaultLayer()

        // Create annotations at different positions
        _ = try await annotationService.createAnnotation(
            content: "Close",
            title: nil,
            type: .text,
            position: SIMD3(0, 0, 0),
            layerID: layer.id
        )

        _ = try await annotationService.createAnnotation(
            content: "Far",
            title: nil,
            type: .text,
            position: SIMD3(100, 0, 0),
            layerID: layer.id
        )

        // Fetch nearby (within 10m of origin)
        let nearby = try await annotationService.fetchNearby(
            position: SIMD3(0, 0, 0),
            radius: 10
        )

        XCTAssertEqual(nearby.count, 1)
        XCTAssertEqual(nearby.first?.contentText, "Close")
    }

    // MARK: - Soft Delete

    func testSoftDeleteExcludesFromQueries() async throws {
        let layer = try await layerService.getOrCreateDefaultLayer()
        let annotation = try await annotationService.createAnnotation(
            content: "To be deleted",
            title: nil,
            type: .text,
            position: SIMD3(0, 0, 0),
            layerID: layer.id
        )

        // Delete (soft delete)
        try await annotationService.deleteAnnotation(id: annotation.id)

        // Should not appear in queries
        let annotations = try await annotationService.fetchAnnotations()
        XCTAssertEqual(annotations.count, 0)
    }
}
