//
//  AnchorManagerTests.swift
//  Reality Annotation Platform Tests
//
//  Unit tests for AnchorManager
//

import XCTest
import RealityKit
@testable import RealityAnnotation

@MainActor
final class AnchorManagerTests: XCTestCase {
    var sut: AnchorManager!

    override func setUp() {
        super.setUp()
        sut = AnchorManager()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Anchor Creation Tests

    func testAnchorFor_CreatesNewAnchor() async throws {
        // Given
        let position = SIMD3<Float>(0, 0, -2)

        // When
        let anchorID = try await sut.anchorFor(position: position)

        // Then
        XCTAssertNotNil(anchorID)
        XCTAssertNotNil(sut.getAnchor(anchorID))
    }

    func testAnchorFor_ReturnsUniqueID() async throws {
        // Given
        let position1 = SIMD3<Float>(0, 0, -2)
        let position2 = SIMD3<Float>(5, 0, -2) // Far enough to create new anchor

        // When
        let anchorID1 = try await sut.anchorFor(position: position1)
        let anchorID2 = try await sut.anchorFor(position: position2)

        // Then
        XCTAssertNotEqual(anchorID1, anchorID2)
    }

    // MARK: - Anchor Reuse Tests

    func testAnchorFor_ReusesNearbyAnchor() async throws {
        // Given
        let position1 = SIMD3<Float>(0, 0, -2)
        let position2 = SIMD3<Float>(0.5, 0, -2) // Within 2m radius

        // When
        let anchorID1 = try await sut.anchorFor(position: position1)
        let anchorID2 = try await sut.anchorFor(position: position2)

        // Then
        XCTAssertEqual(anchorID1, anchorID2, "Should reuse anchor within 2m radius")
    }

    func testAnchorFor_CreatesNewAnchorWhenFar() async throws {
        // Given
        let position1 = SIMD3<Float>(0, 0, -2)
        let position2 = SIMD3<Float>(5, 0, -2) // Beyond 2m radius

        // When
        let anchorID1 = try await sut.anchorFor(position: position1)
        let anchorID2 = try await sut.anchorFor(position: position2)

        // Then
        XCTAssertNotEqual(anchorID1, anchorID2, "Should create new anchor beyond 2m")
    }

    func testAnchorFor_RespectsTwoMeterThreshold() async throws {
        // Given
        let position1 = SIMD3<Float>(0, 0, -2)
        let position2 = SIMD3<Float>(1.9, 0, -2) // Just under 2m
        let position3 = SIMD3<Float>(2.1, 0, -2) // Just over 2m

        // When
        let anchorID1 = try await sut.anchorFor(position: position1)
        let anchorID2 = try await sut.anchorFor(position: position2)
        let anchorID3 = try await sut.anchorFor(position: position3)

        // Then
        XCTAssertEqual(anchorID1, anchorID2, "Should reuse at 1.9m")
        XCTAssertNotEqual(anchorID1, anchorID3, "Should create new at 2.1m")
    }

    // MARK: - Anchor Retrieval Tests

    func testGetAnchor_ReturnsExistingAnchor() async throws {
        // Given
        let position = SIMD3<Float>(0, 0, -2)
        let anchorID = try await sut.anchorFor(position: position)

        // When
        let anchor = sut.getAnchor(anchorID)

        // Then
        XCTAssertNotNil(anchor)
    }

    func testGetAnchor_ReturnsNilForNonexistent() {
        // Given
        let randomID = UUID()

        // When
        let anchor = sut.getAnchor(randomID)

        // Then
        XCTAssertNil(anchor)
    }

    func testGetAllAnchors_ReturnsAllCreated() async throws {
        // Given
        let positions: [SIMD3<Float>] = [
            SIMD3(0, 0, -2),
            SIMD3(5, 0, -2),
            SIMD3(10, 0, -2)
        ]

        // When
        for position in positions {
            _ = try await sut.anchorFor(position: position)
        }

        let allAnchors = sut.getAllAnchors()

        // Then
        XCTAssertEqual(allAnchors.count, 3)
    }

    // MARK: - Anchor Removal Tests

    func testRemoveAnchor_RemovesExisting() async throws {
        // Given
        let position = SIMD3<Float>(0, 0, -2)
        let anchorID = try await sut.anchorFor(position: position)
        XCTAssertNotNil(sut.getAnchor(anchorID))

        // When
        sut.removeAnchor(anchorID)

        // Then
        XCTAssertNil(sut.getAnchor(anchorID))
    }

    func testRemoveAnchor_HandlesNonexistent() {
        // Given
        let randomID = UUID()

        // When/Then - should not crash
        sut.removeAnchor(randomID)
        XCTAssertTrue(true)
    }

    func testClearAllAnchors_RemovesAll() async throws {
        // Given
        _ = try await sut.anchorFor(position: SIMD3(0, 0, -2))
        _ = try await sut.anchorFor(position: SIMD3(5, 0, -2))
        XCTAssertEqual(sut.getAllAnchors().count, 2)

        // When
        sut.clearAllAnchors()

        // Then
        XCTAssertEqual(sut.getAllAnchors().count, 0)
    }

    // MARK: - Persistence Tests

    func testGetAnchorData_ReturnsValidData() async throws {
        // Given
        let position1 = SIMD3<Float>(0, 0, -2)
        let position2 = SIMD3<Float>(5, 0, -2)
        _ = try await sut.anchorFor(position: position1)
        _ = try await sut.anchorFor(position: position2)

        // When
        let anchorData = sut.getAnchorData()

        // Then
        XCTAssertEqual(anchorData.count, 2)
        XCTAssertTrue(anchorData.allSatisfy { !$0.id.uuidString.isEmpty })
    }

    func testRestoreFromAnchorData_RestoresAnchors() async throws {
        // Given
        let data = [
            AnchorData(
                id: UUID(),
                position: SIMD3(0, 0, -2),
                timestamp: Date()
            ),
            AnchorData(
                id: UUID(),
                position: SIMD3(5, 0, -2),
                timestamp: Date()
            )
        ]

        // When
        try await sut.restoreFromAnchorData(data)

        // Then
        XCTAssertEqual(sut.getAllAnchors().count, 2)
    }

    // MARK: - Status Tests

    func testPrintStatus_DoesNotCrash() async throws {
        // Given
        _ = try await sut.anchorFor(position: SIMD3(0, 0, -2))

        // When/Then - should not crash
        sut.printStatus()
        XCTAssertTrue(true)
    }

    // MARK: - Performance Tests

    func testAnchorFor_HandlesMultipleAnchors() async throws {
        // Given - create many anchors (but not too many to slow test)
        let positions = (0..<10).map { i in
            SIMD3<Float>(Float(i * 3), 0, -2) // 3m apart
        }

        // When
        for position in positions {
            _ = try await sut.anchorFor(position: position)
        }

        // Then
        let anchors = sut.getAllAnchors()
        XCTAssertEqual(anchors.count, 10)
    }

    func testAnchorFor_ReuseReducesAnchorCount() async throws {
        // Given - positions that cluster together
        let positions: [SIMD3<Float>] = [
            SIMD3(0, 0, -2),
            SIMD3(0.5, 0, -2),
            SIMD3(1.0, 0, -2),
            SIMD3(1.5, 0, -2)
        ]

        // When
        for position in positions {
            _ = try await sut.anchorFor(position: position)
        }

        // Then - should reuse, so fewer anchors than positions
        let anchors = sut.getAllAnchors()
        XCTAssertLessThan(anchors.count, positions.count)
    }
}
