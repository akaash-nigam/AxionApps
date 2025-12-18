//
//  ImmersiveViewModelTests.swift
//  Reality Annotation Platform Tests
//
//  Integration tests for ImmersiveViewModel
//

import XCTest
import RealityKit
@testable import RealityAnnotation

@MainActor
final class ImmersiveViewModelTests: XCTestCase {
    var sut: ImmersiveViewModel!
    var mockAnnotationService: MockAnnotationService!
    var mockLayerService: MockLayerService!

    override func setUp() {
        super.setUp()
        mockAnnotationService = MockAnnotationService()
        mockLayerService = MockLayerService()
        sut = ImmersiveViewModel(
            annotationService: mockAnnotationService,
            layerService: mockLayerService
        )
    }

    override func tearDown() {
        sut = nil
        mockAnnotationService = nil
        mockLayerService = nil
        super.tearDown()
    }

    // MARK: - Initialization Tests

    func testInitialization_DefaultState() {
        // Then
        XCTAssertFalse(sut.isShowingCreatePanel)
        XCTAssertEqual(sut.annotations.count, 0)
        XCTAssertEqual(sut.arSessionState, .stopped)
    }

    // MARK: - AR Session Tests

    func testStartARSession_UpdatesState() async {
        // When
        await sut.startARSession()

        // Then
        XCTAssertEqual(sut.arSessionState, .running)
    }

    func testStopARSession_UpdatesState() async {
        // Given
        await sut.startARSession()

        // When
        sut.stopARSession()

        // Then
        XCTAssertEqual(sut.arSessionState, .stopped)
    }

    // MARK: - Annotation Loading Tests

    func testLoadAnnotations_FetchesFromService() async {
        // Given
        let testAnnotations = [
            createTestAnnotation(content: "Test 1"),
            createTestAnnotation(content: "Test 2")
        ]
        mockAnnotationService.annotations = testAnnotations

        // When
        await sut.loadAnnotations()

        // Then
        XCTAssertEqual(sut.annotations.count, 2)
        XCTAssertTrue(sut.annotations.contains { $0.contentText == "Test 1" })
        XCTAssertTrue(sut.annotations.contains { $0.contentText == "Test 2" })
    }

    func testLoadAnnotations_HandlesError() async {
        // Given
        mockAnnotationService.shouldThrowError = true

        // When
        await sut.loadAnnotations()

        // Then - should handle gracefully
        XCTAssertEqual(sut.annotations.count, 0)
    }

    func testReloadAnnotations_UpdatesAnnotations() async {
        // Given
        let initialAnnotations = [createTestAnnotation(content: "Initial")]
        mockAnnotationService.annotations = initialAnnotations
        await sut.loadAnnotations()
        XCTAssertEqual(sut.annotations.count, 1)

        // When - change annotations and reload
        let newAnnotations = [
            createTestAnnotation(content: "New 1"),
            createTestAnnotation(content: "New 2")
        ]
        mockAnnotationService.annotations = newAnnotations
        await sut.reloadAnnotations()

        // Then
        XCTAssertEqual(sut.annotations.count, 2)
    }

    // MARK: - Annotation Creation Tests

    func testCreateAnnotation_CreatesWithService() async {
        // Given
        let defaultLayer = Layer(
            name: "Default",
            icon: "note.text",
            color: .blue,
            ownerID: "test-user"
        )
        mockLayerService.defaultLayer = defaultLayer

        let position = SIMD3<Float>(0, 1, -2)

        // When
        await sut.handleTap(at: position)
        XCTAssertTrue(sut.isShowingCreatePanel)

        await sut.createAnnotation(title: "Test Title", content: "Test Content")

        // Then
        XCTAssertEqual(mockAnnotationService.createdAnnotations.count, 1)
        let created = mockAnnotationService.createdAnnotations.first!
        XCTAssertEqual(created.title, "Test Title")
        XCTAssertEqual(created.contentText, "Test Content")
        XCTAssertEqual(created.position, position)
        XCTAssertFalse(sut.isShowingCreatePanel)
    }

    func testCreateAnnotation_AddsToLocalList() async {
        // Given
        let defaultLayer = Layer(
            name: "Default",
            icon: "note.text",
            color: .blue,
            ownerID: "test-user"
        )
        mockLayerService.defaultLayer = defaultLayer

        await sut.handleTap(at: SIMD3(0, 1, -2))

        // When
        await sut.createAnnotation(title: nil, content: "Test")

        // Then
        XCTAssertEqual(sut.annotations.count, 1)
    }

    func testCreateAnnotation_WithoutPosition_DoesNotCreate() async {
        // When - try to create without tapping first
        await sut.createAnnotation(title: nil, content: "Test")

        // Then
        XCTAssertEqual(mockAnnotationService.createdAnnotations.count, 0)
    }

    func testCreateAnnotation_HandlesError() async {
        // Given
        mockLayerService.shouldThrowError = true
        await sut.handleTap(at: SIMD3(0, 1, -2))

        // When
        await sut.createAnnotation(title: nil, content: "Test")

        // Then - should handle gracefully
        XCTAssertEqual(sut.annotations.count, 0)
        XCTAssertFalse(sut.isShowingCreatePanel)
    }

    // MARK: - Interaction Tests

    func testHandleTap_ShowsCreatePanel() {
        // Given
        let position = SIMD3<Float>(0, 1, -2)

        // When
        sut.handleTap(at: position)

        // Then
        XCTAssertTrue(sut.isShowingCreatePanel)
    }

    func testShowCreatePanel_UpdatesState() {
        // When
        sut.showCreatePanel()

        // Then
        XCTAssertTrue(sut.isShowingCreatePanel)
    }

    func testDismissCreatePanel_UpdatesState() {
        // Given
        sut.handleTap(at: SIMD3(0, 1, -2))
        XCTAssertTrue(sut.isShowingCreatePanel)

        // When
        sut.dismissCreatePanel()

        // Then
        XCTAssertFalse(sut.isShowingCreatePanel)
    }

    func testDismissCreatePanel_ClearsPendingPosition() async {
        // Given
        await sut.handleTap(at: SIMD3(0, 1, -2))
        sut.dismissCreatePanel()

        // When - try to create without position
        await sut.createAnnotation(title: nil, content: "Test")

        // Then
        XCTAssertEqual(mockAnnotationService.createdAnnotations.count, 0)
    }

    // MARK: - Helper Methods

    private func createTestAnnotation(
        content: String,
        position: SIMD3<Float> = SIMD3(0, 1, -2)
    ) -> Annotation {
        return Annotation(
            type: .text,
            title: nil,
            contentText: content,
            position: position,
            layerID: UUID(),
            ownerID: "test-user"
        )
    }
}

// MARK: - Mock Services

class MockAnnotationService: AnnotationService {
    var annotations: [Annotation] = []
    var createdAnnotations: [Annotation] = []
    var shouldThrowError = false

    func createAnnotation(
        content: String,
        title: String?,
        type: AnnotationType,
        position: SIMD3<Float>,
        layerID: UUID
    ) async throws -> Annotation {
        if shouldThrowError {
            throw AnnotationError.emptyContent
        }

        let annotation = Annotation(
            type: type,
            title: title,
            contentText: content,
            position: position,
            layerID: layerID,
            ownerID: "test-user"
        )
        createdAnnotations.append(annotation)
        annotations.append(annotation)
        return annotation
    }

    func fetchAnnotations() async throws -> [Annotation] {
        if shouldThrowError {
            throw RepositoryError.notFound
        }
        return annotations
    }

    func fetchAnnotations(in layerID: UUID) async throws -> [Annotation] {
        return annotations.filter { $0.layerID == layerID }
    }

    func fetchNearby(position: SIMD3<Float>, radius: Float) async throws -> [Annotation] {
        return annotations.filter { annotation in
            simd_distance(annotation.position, position) <= radius
        }
    }

    func updateAnnotation(_ annotation: Annotation) async throws {
        if shouldThrowError {
            throw AnnotationError.notFound
        }
    }

    func deleteAnnotation(id: UUID) async throws {
        if shouldThrowError {
            throw AnnotationError.notFound
        }
        annotations.removeAll { $0.id == id }
    }
}

class MockLayerService: LayerService {
    var defaultLayer: Layer?
    var shouldThrowError = false

    func createLayer(name: String, icon: String, color: LayerColor) async throws -> Layer {
        throw LayerError.notFound
    }

    func fetchLayers() async throws -> [Layer] {
        return []
    }

    func updateLayer(_ layer: Layer) async throws {
    }

    func deleteLayer(id: UUID) async throws {
    }

    func getOrCreateDefaultLayer() async throws -> Layer {
        if shouldThrowError {
            throw LayerError.notFound
        }
        if let layer = defaultLayer {
            return layer
        }
        let layer = Layer(
            name: "Default",
            icon: "note.text",
            color: .blue,
            ownerID: "test-user"
        )
        defaultLayer = layer
        return layer
    }

    func reorderLayers(_ layers: [Layer]) async throws {
    }
}
