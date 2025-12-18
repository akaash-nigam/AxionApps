//
//  LayerServiceTests.swift
//  Reality Annotation Platform Tests
//
//  Unit tests for LayerService
//

import XCTest
@testable import RealityAnnotation

final class LayerServiceTests: XCTestCase {
    var sut: DefaultLayerService!
    var mockLayerRepository: MockLayerRepository!
    var mockAnnotationRepository: MockAnnotationRepository!
    let testUserID = "test-user-123"

    override func setUp() {
        super.setUp()
        mockLayerRepository = MockLayerRepository()
        mockAnnotationRepository = MockAnnotationRepository()
        sut = DefaultLayerService(
            repository: mockLayerRepository,
            annotationRepository: mockAnnotationRepository,
            currentUserID: testUserID
        )
    }

    override func tearDown() {
        sut = nil
        mockLayerRepository = nil
        mockAnnotationRepository = nil
        super.tearDown()
    }

    // MARK: - Create Layer Tests

    func testCreateLayer_Success() async throws {
        // Given
        let name = "Test Layer"
        let icon = "tag.fill"
        let color = LayerColor.blue

        // When
        let layer = try await sut.createLayer(name: name, icon: icon, color: color)

        // Then
        XCTAssertEqual(layer.name, name)
        XCTAssertEqual(layer.icon, icon)
        XCTAssertEqual(layer.color, color)
        XCTAssertEqual(layer.ownerID, testUserID)
        XCTAssertEqual(mockLayerRepository.layers.count, 1)
    }

    func testCreateLayer_EmptyName_ThrowsError() async {
        // When/Then
        do {
            _ = try await sut.createLayer(name: "", icon: "tag", color: .blue)
            XCTFail("Should have thrown emptyName error")
        } catch {
            XCTAssertEqual(error as? LayerError, LayerError.emptyName)
        }
    }

    func testCreateLayer_NameTooLong_ThrowsError() async {
        // Given
        let longName = String(repeating: "a", count: 51)

        // When/Then
        do {
            _ = try await sut.createLayer(name: longName, icon: "tag", color: .blue)
            XCTFail("Should have thrown nameTooLong error")
        } catch {
            XCTAssertEqual(error as? LayerError, LayerError.nameTooLong)
        }
    }

    func testCreateLayer_LimitExceeded_ThrowsError() async {
        // Given - User already has one layer (MVP limit)
        let existingLayer = Layer(name: "Existing", ownerID: testUserID)
        mockLayerRepository.layers = [existingLayer]

        // When/Then
        do {
            _ = try await sut.createLayer(name: "New Layer", icon: "tag", color: .blue)
            XCTFail("Should have thrown limitExceeded error")
        } catch {
            if case LayerError.limitExceeded(let limit) = error {
                XCTAssertEqual(limit, 1)
            } else {
                XCTFail("Wrong error type")
            }
        }
    }

    // MARK: - Fetch Layer Tests

    func testFetchLayers_ReturnsUserLayers() async throws {
        // Given
        let userLayer1 = Layer(name: "Layer 1", ownerID: testUserID)
        let userLayer2 = Layer(name: "Layer 2", ownerID: testUserID)
        let otherUserLayer = Layer(name: "Other", ownerID: "other-user")

        mockLayerRepository.layers = [userLayer1, userLayer2, otherUserLayer]

        // When
        let layers = try await sut.fetchLayers()

        // Then
        XCTAssertEqual(layers.count, 2)
        XCTAssertTrue(layers.allSatisfy { $0.ownerID == testUserID })
    }

    func testGetDefaultLayer_CreatesIfNotExists() async throws {
        // When
        let layer = try await sut.getDefaultLayer()

        // Then
        XCTAssertEqual(layer.name, "My Notes")
        XCTAssertEqual(layer.ownerID, testUserID)
        XCTAssertEqual(mockLayerRepository.layers.count, 1)
    }

    func testGetDefaultLayer_ReturnsExistingIfExists() async throws {
        // Given
        let existingLayer = Layer(name: "Existing", ownerID: testUserID)
        mockLayerRepository.layers = [existingLayer]

        // When
        let layer = try await sut.getDefaultLayer()

        // Then
        XCTAssertEqual(layer.id, existingLayer.id)
        XCTAssertEqual(mockLayerRepository.layers.count, 1) // No new layer created
    }

    // MARK: - Update Layer Tests

    func testUpdateLayer_Success() async throws {
        // Given
        let layer = Layer(name: "Original", ownerID: testUserID)
        mockLayerRepository.layers = [layer]

        // When
        layer.name = "Updated"
        try await sut.updateLayer(layer)

        // Then
        let updated = try await mockLayerRepository.fetch(layer.id)
        XCTAssertEqual(updated?.name, "Updated")
    }

    func testUpdateLayer_NotOwner_ThrowsError() async {
        // Given
        let layer = Layer(name: "Test", ownerID: "other-user")
        mockLayerRepository.layers = [layer]

        // When/Then
        do {
            try await sut.updateLayer(layer)
            XCTFail("Should have thrown notOwner error")
        } catch {
            XCTAssertEqual(error as? LayerError, LayerError.notOwner)
        }
    }

    func testSetLayerVisible_Success() async throws {
        // Given
        let layer = Layer(name: "Test", ownerID: testUserID)
        layer.isVisible = true
        mockLayerRepository.layers = [layer]

        // When
        try await sut.setLayerVisible(layer.id, visible: false)

        // Then
        let updated = try await mockLayerRepository.fetch(layer.id)
        XCTAssertFalse(updated?.isVisible ?? true)
    }

    // MARK: - Delete Layer Tests

    func testDeleteLayer_ThrowsCannotDeleteError() async {
        // Given - MVP: Cannot delete the only layer
        let layer = Layer(name: "Only Layer", ownerID: testUserID)
        mockLayerRepository.layers = [layer]

        // When/Then
        do {
            try await sut.deleteLayer(id: layer.id)
            XCTFail("Should have thrown cannotDeleteDefaultLayer error")
        } catch {
            XCTAssertEqual(error as? LayerError, LayerError.cannotDeleteDefaultLayer)
        }
    }
}
