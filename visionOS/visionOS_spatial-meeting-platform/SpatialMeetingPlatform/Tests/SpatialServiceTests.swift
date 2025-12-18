import XCTest
@testable import SpatialMeetingPlatform
import Foundation
import simd

final class SpatialServiceTests: XCTestCase {
    var sut: SpatialService!

    override func setUp() {
        super.setUp()
        sut = SpatialService()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Tracking Tests

    func testStartTracking() async throws {
        // Given
        XCTAssertFalse(sut.isTracking)

        // When
        try await sut.startTracking()

        // Then
        XCTAssertTrue(sut.isTracking)
    }

    func testStopTracking() async throws {
        // Given
        try await sut.startTracking()
        XCTAssertTrue(sut.isTracking)

        // When
        sut.stopTracking()

        // Then
        XCTAssertFalse(sut.isTracking)
    }

    // MARK: - Anchor Tests

    func testCreateAnchor() async throws {
        // Given
        let position = SpatialPosition(x: 1.0, y: 0.5, z: -2.0)
        let id = UUID()

        // When
        let anchor = try await sut.createAnchor(at: position, id: id)

        // Then
        XCTAssertEqual(anchor.id, id)
        XCTAssertEqual(anchor.position.x, position.x)
        XCTAssertEqual(anchor.position.y, position.y)
        XCTAssertEqual(anchor.position.z, position.z)
    }

    func testGetAnchor() async throws {
        // Given
        let position = SpatialPosition(x: 1.0, y: 0.5, z: -2.0)
        let id = UUID()
        _ = try await sut.createAnchor(at: position, id: id)

        // When
        let retrieved = sut.getAnchor(id)

        // Then
        XCTAssertNotNil(retrieved)
        XCTAssertEqual(retrieved?.id, id)
    }

    func testRemoveAnchor() async throws {
        // Given
        let position = SpatialPosition(x: 1.0, y: 0.5, z: -2.0)
        let id = UUID()
        _ = try await sut.createAnchor(at: position, id: id)

        // When
        sut.removeAnchor(id)

        // Then
        XCTAssertNil(sut.getAnchor(id))
    }

    // MARK: - Position Utility Tests

    func testCalculateDistance() {
        // Given
        let pos1 = SpatialPosition(x: 0, y: 0, z: 0)
        let pos2 = SpatialPosition(x: 3, y: 4, z: 0)

        // When
        let distance = sut.calculateDistance(from: pos1, to: pos2)

        // Then
        XCTAssertEqual(distance, 5.0, accuracy: 0.01) // 3-4-5 triangle
    }

    func testSnapToGrid() {
        // Given
        let position = SIMD3<Float>(1.23, 0.56, -2.78)

        // When
        let snapped = sut.snapToGrid(position, gridSize: 0.1)

        // Then
        XCTAssertEqual(snapped.x, 1.2, accuracy: 0.01)
        XCTAssertEqual(snapped.y, 0.6, accuracy: 0.01)
        XCTAssertEqual(snapped.z, -2.8, accuracy: 0.01)
    }

    func testInterpolatePosition() {
        // Given
        let start = SpatialPosition(x: 0, y: 0, z: 0)
        let end = SpatialPosition(x: 10, y: 5, z: -10)

        // When (halfway)
        let middle = sut.interpolatePosition(from: start, to: end, t: 0.5)

        // Then
        XCTAssertEqual(middle.x, 5.0, accuracy: 0.01)
        XCTAssertEqual(middle.y, 2.5, accuracy: 0.01)
        XCTAssertEqual(middle.z, -5.0, accuracy: 0.01)
    }

    // MARK: - Collision Detection Tests

    func testDetectCollision() async throws {
        // Given
        let anchor1Pos = SpatialPosition(x: 0, y: 0, z: 0)
        let anchor1Id = UUID()
        _ = try await sut.createAnchor(at: anchor1Pos, id: anchor1Id)

        let anchor2Pos = SpatialPosition(x: 5, y: 0, z: 0)
        let anchor2Id = UUID()
        _ = try await sut.createAnchor(at: anchor2Pos, id: anchor2Id)

        // When (check within radius of first anchor)
        let testPos = SpatialPosition(x: 0.5, y: 0, z: 0)
        let collisions = sut.detectCollision(at: testPos, radius: 1.0)

        // Then
        XCTAssertTrue(collisions.contains(anchor1Id))
        XCTAssertFalse(collisions.contains(anchor2Id))
    }

    // MARK: - Participant Positioning Tests

    func testCalculateCircleLayout() {
        // Given
        let count = 8
        let center = SpatialPosition(x: 0, y: 0, z: 0)
        let radius: Float = 2.0

        // When
        let positions = sut.calculateParticipantPositions(
            count: count,
            layout: .circle,
            centerPosition: center,
            radius: radius
        )

        // Then
        XCTAssertEqual(positions.count, count)

        // All positions should be at the specified radius from center
        for position in positions {
            let distance = sqrt(position.x * position.x + position.z * position.z)
            XCTAssertEqual(distance, radius, accuracy: 0.01)
        }
    }

    func testCalculateTheaterLayout() {
        // Given
        let count = 12

        // When
        let positions = sut.calculateParticipantPositions(
            count: count,
            layout: .theater
        )

        // Then
        XCTAssertEqual(positions.count, count)

        // Verify positions are arranged in rows
        XCTAssertTrue(positions.allSatisfy { $0.y <= 0 }) // All at or below center level
    }

    func testCalculateUShapeLayout() {
        // Given
        let count = 10

        // When
        let positions = sut.calculateParticipantPositions(
            count: count,
            layout: .uShape
        )

        // Then
        XCTAssertEqual(positions.count, count)
    }
}
