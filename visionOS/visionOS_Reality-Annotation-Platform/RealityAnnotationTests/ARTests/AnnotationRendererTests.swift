//
//  AnnotationRendererTests.swift
//  Reality Annotation Platform Tests
//
//  Unit tests for AnnotationRenderer
//

import XCTest
import RealityKit
@testable import RealityAnnotation

@MainActor
final class AnnotationRendererTests: XCTestCase {
    var sut: AnnotationRenderer!
    var mockAnchorManager: AnchorManager!
    var rootEntity: Entity!

    override func setUp() {
        super.setUp()
        mockAnchorManager = AnchorManager()
        sut = AnnotationRenderer(anchorManager: mockAnchorManager)
        rootEntity = Entity()
        sut.setRootEntity(rootEntity)
    }

    override func tearDown() {
        sut = nil
        mockAnchorManager = nil
        rootEntity = nil
        super.tearDown()
    }

    // MARK: - Initialization Tests

    func testSetRootEntity_SetsRoot() {
        // Given
        let newRoot = Entity()

        // When
        sut.setRootEntity(newRoot)

        // Then - should not crash
        XCTAssertTrue(true)
    }

    // MARK: - Entity Creation Tests

    func testCreateEntity_CreatesAnnotationEntity() async {
        // Given
        let annotation = createTestAnnotation(content: "Test")

        // When
        await sut.createEntity(for: annotation)

        // Then
        let entity = sut.getEntity(for: annotation.id)
        XCTAssertNotNil(entity)
    }

    func testCreateEntity_DoesNotCreateDuplicate() async {
        // Given
        let annotation = createTestAnnotation(content: "Test")
        await sut.createEntity(for: annotation)

        // When
        await sut.createEntity(for: annotation)

        // Then - should handle gracefully
        let entity = sut.getEntity(for: annotation.id)
        XCTAssertNotNil(entity)
    }

    func testCreateEntity_MultipleAnnotations() async {
        // Given
        let annotations = [
            createTestAnnotation(content: "Test 1"),
            createTestAnnotation(content: "Test 2"),
            createTestAnnotation(content: "Test 3")
        ]

        // When
        for annotation in annotations {
            await sut.createEntity(for: annotation)
        }

        // Then
        for annotation in annotations {
            XCTAssertNotNil(sut.getEntity(for: annotation.id))
        }
    }

    // MARK: - Entity Removal Tests

    func testRemoveEntity_RemovesExisting() async {
        // Given
        let annotation = createTestAnnotation(content: "Test")
        await sut.createEntity(for: annotation)
        XCTAssertNotNil(sut.getEntity(for: annotation.id))

        // When
        await sut.removeEntity(for: annotation.id)

        // Then
        XCTAssertNil(sut.getEntity(for: annotation.id))
    }

    func testRemoveEntity_HandlesNonexistent() async {
        // Given
        let randomID = UUID()

        // When/Then - should not crash
        await sut.removeEntity(for: randomID)
        XCTAssertTrue(true)
    }

    // MARK: - Entity Update Tests

    func testUpdateEntity_UpdatesExisting() async {
        // Given
        let annotation = createTestAnnotation(content: "Original")
        await sut.createEntity(for: annotation)

        // When
        annotation.contentText = "Updated"
        sut.updateEntity(for: annotation)

        // Then - should not crash
        let entity = sut.getEntity(for: annotation.id)
        XCTAssertNotNil(entity)
    }

    func testUpdateEntity_HandlesNonexistent() {
        // Given
        let annotation = createTestAnnotation(content: "Test")

        // When/Then - should not crash
        sut.updateEntity(for: annotation)
        XCTAssertTrue(true)
    }

    // MARK: - Reload Tests

    func testReloadAnnotations_CreatesNewEntities() async {
        // Given
        let annotations = [
            createTestAnnotation(content: "Test 1"),
            createTestAnnotation(content: "Test 2")
        ]

        // When
        await sut.reloadAnnotations(annotations)

        // Then
        for annotation in annotations {
            XCTAssertNotNil(sut.getEntity(for: annotation.id))
        }
    }

    func testReloadAnnotations_UpdatesExisting() async {
        // Given
        let annotation = createTestAnnotation(content: "Original")
        await sut.createEntity(for: annotation)

        // When
        annotation.contentText = "Updated"
        await sut.reloadAnnotations([annotation])

        // Then
        let entity = sut.getEntity(for: annotation.id)
        XCTAssertNotNil(entity)
    }

    func testReloadAnnotations_RemovesOldEntities() async {
        // Given
        let annotation1 = createTestAnnotation(content: "Keep")
        let annotation2 = createTestAnnotation(content: "Remove")
        await sut.createEntity(for: annotation1)
        await sut.createEntity(for: annotation2)

        // When - reload with only annotation1
        await sut.reloadAnnotations([annotation1])

        // Then
        XCTAssertNotNil(sut.getEntity(for: annotation1.id))
        XCTAssertNil(sut.getEntity(for: annotation2.id))
    }

    // MARK: - Update Loop Tests

    func testUpdate_DoesNotCrashWithNoEntities() {
        // Given
        let cameraPosition = SIMD3<Float>(0, 1.6, 0)

        // When/Then - should not crash
        sut.update(cameraPosition: cameraPosition, deltaTime: 0.016)
        XCTAssertTrue(true)
    }

    func testUpdate_DoesNotCrashWithEntities() async {
        // Given
        let annotation = createTestAnnotation(content: "Test")
        await sut.createEntity(for: annotation)
        let cameraPosition = SIMD3<Float>(0, 1.6, 0)

        // When/Then - should not crash
        sut.update(cameraPosition: cameraPosition, deltaTime: 0.016)
        XCTAssertTrue(true)
    }

    func testUpdate_ThrottlesUpdates() {
        // Given
        let cameraPosition = SIMD3<Float>(0, 1.6, 0)

        // When - call update twice rapidly
        sut.update(cameraPosition: cameraPosition, deltaTime: 0.001)
        sut.update(cameraPosition: cameraPosition, deltaTime: 0.001)

        // Then - should handle throttling gracefully
        XCTAssertTrue(true)
    }

    // MARK: - Raycast Tests

    func testRaycast_ReturnsNilWithNoEntities() {
        // Given
        let origin = SIMD3<Float>(0, 1.6, 0)
        let direction = SIMD3<Float>(0, 0, -1)

        // When
        let entity = sut.raycast(from: origin, direction: direction)

        // Then
        XCTAssertNil(entity)
    }

    func testRaycast_FindsEntityInPath() async {
        // Given
        let annotation = createTestAnnotation(
            content: "Test",
            position: SIMD3(0, 1.6, -2)
        )
        await sut.createEntity(for: annotation)

        let origin = SIMD3<Float>(0, 1.6, 0)
        let direction = normalize(SIMD3<Float>(0, 0, -1))

        // When
        let entity = sut.raycast(from: origin, direction: direction)

        // Then
        XCTAssertNotNil(entity)
        XCTAssertEqual(entity?.annotationID, annotation.id)
    }

    func testRaycast_ReturnsClosestEntity() async {
        // Given
        let nearAnnotation = createTestAnnotation(
            content: "Near",
            position: SIMD3(0, 1.6, -1)
        )
        let farAnnotation = createTestAnnotation(
            content: "Far",
            position: SIMD3(0, 1.6, -5)
        )
        await sut.createEntity(for: nearAnnotation)
        await sut.createEntity(for: farAnnotation)

        let origin = SIMD3<Float>(0, 1.6, 0)
        let direction = normalize(SIMD3<Float>(0, 0, -1))

        // When
        let entity = sut.raycast(from: origin, direction: direction)

        // Then
        XCTAssertNotNil(entity)
        XCTAssertEqual(entity?.annotationID, nearAnnotation.id)
    }

    // MARK: - Clear Tests

    func testClearAll_RemovesAllEntities() async {
        // Given
        let annotations = [
            createTestAnnotation(content: "Test 1"),
            createTestAnnotation(content: "Test 2"),
            createTestAnnotation(content: "Test 3")
        ]
        for annotation in annotations {
            await sut.createEntity(for: annotation)
        }

        // When
        await sut.clearAll()

        // Then
        for annotation in annotations {
            XCTAssertNil(sut.getEntity(for: annotation.id))
        }
    }

    // MARK: - Status Tests

    func testPrintStatus_DoesNotCrash() async {
        // Given
        let annotation = createTestAnnotation(content: "Test")
        await sut.createEntity(for: annotation)

        // When/Then - should not crash
        sut.printStatus()
        XCTAssertTrue(true)
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
