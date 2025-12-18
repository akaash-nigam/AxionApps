import XCTest
@testable import HideAndSeekEvolved

final class RoomLayoutTests: XCTestCase {

    // MARK: - BoundingBox Tests

    func testBoundingBox_center() {
        // Given
        let bounds = BoundingBox(
            min: SIMD3<Float>(0, 0, 0),
            max: SIMD3<Float>(10, 5, 8)
        )

        // When
        let center = bounds.center

        // Then
        XCTAssertEqual(center.x, 5.0, accuracy: 0.001)
        XCTAssertEqual(center.y, 2.5, accuracy: 0.001)
        XCTAssertEqual(center.z, 4.0, accuracy: 0.001)
    }

    func testBoundingBox_size() {
        // Given
        let bounds = BoundingBox(
            min: SIMD3<Float>(-5, -3, -2),
            max: SIMD3<Float>(5, 3, 2)
        )

        // When
        let size = bounds.size

        // Then
        XCTAssertEqual(size.x, 10.0, accuracy: 0.001)
        XCTAssertEqual(size.y, 6.0, accuracy: 0.001)
        XCTAssertEqual(size.z, 4.0, accuracy: 0.001)
    }

    // MARK: - FurnitureItem Tests

    func testFurnitureItem_hidingPotentialClamping_tooHigh() {
        // When
        let furniture = FurnitureItem(
            type: .sofa,
            position: .zero,
            size: SIMD3(2, 1, 1),
            orientation: simd_quatf(angle: 0, axis: SIMD3(0, 1, 0)),
            hidingPotential: 1.5  // Too high
        )

        // Then
        XCTAssertEqual(furniture.hidingPotential, 1.0, accuracy: 0.001)
    }

    func testFurnitureItem_hidingPotentialClamping_tooLow() {
        // When
        let furniture = FurnitureItem(
            type: .chair,
            position: .zero,
            size: SIMD3(0.5, 1, 0.5),
            orientation: simd_quatf(angle: 0, axis: SIMD3(0, 1, 0)),
            hidingPotential: -0.5  // Too low
        )

        // Then
        XCTAssertEqual(furniture.hidingPotential, 0.0, accuracy: 0.001)
    }

    func testFurnitureType_defaultHidingPotential() {
        // Test various furniture types
        XCTAssertEqual(FurnitureType.sofa.defaultHidingPotential, 0.9, accuracy: 0.001)
        XCTAssertEqual(FurnitureType.table.defaultHidingPotential, 0.7, accuracy: 0.001)
        XCTAssertEqual(FurnitureType.chair.defaultHidingPotential, 0.5, accuracy: 0.001)
        XCTAssertEqual(FurnitureType.plant.defaultHidingPotential, 0.3, accuracy: 0.001)
    }

    // MARK: - HidingSpot Tests

    func testHidingSpot_qualityClamping() {
        // When
        let spot1 = HidingSpot(
            location: SIMD3(1, 0, 1),
            quality: 1.5,  // Too high
            accessibility: .easy
        )
        let spot2 = HidingSpot(
            location: SIMD3(2, 0, 2),
            quality: -0.2, // Too low
            accessibility: .moderate
        )

        // Then
        XCTAssertEqual(spot1.quality, 1.0, accuracy: 0.001)
        XCTAssertEqual(spot2.quality, 0.0, accuracy: 0.001)
    }

    func testHidingSpot_withAssociatedFurniture() {
        // Given
        let furnitureId = UUID()

        // When
        let spot = HidingSpot(
            location: SIMD3(3, 0, 3),
            quality: 0.8,
            accessibility: .easy,
            associatedFurniture: furnitureId
        )

        // Then
        XCTAssertEqual(spot.associatedFurniture, furnitureId)
        XCTAssertEqual(spot.quality, 0.8, accuracy: 0.001)
    }

    // MARK: - Accessibility Tests

    func testAccessibilityLevel_isAccessible_easy() {
        // Given
        let level = AccessibilityLevel.easy

        // Then
        XCTAssertTrue(level.isAccessible(for: .easy))
        XCTAssertTrue(level.isAccessible(for: .moderate))
        XCTAssertTrue(level.isAccessible(for: .difficult))
    }

    func testAccessibilityLevel_isAccessible_moderate() {
        // Given
        let level = AccessibilityLevel.moderate

        // Then
        XCTAssertFalse(level.isAccessible(for: .easy))
        XCTAssertTrue(level.isAccessible(for: .moderate))
        XCTAssertTrue(level.isAccessible(for: .difficult))
    }

    func testAccessibilityLevel_isAccessible_difficult() {
        // Given
        let level = AccessibilityLevel.difficult

        // Then
        XCTAssertFalse(level.isAccessible(for: .easy))
        XCTAssertFalse(level.isAccessible(for: .moderate))
        XCTAssertTrue(level.isAccessible(for: .difficult))
    }

    // MARK: - RoomLayout Tests

    func testRoomLayout_initialization() {
        // Given & When
        let bounds = BoundingBox(
            min: SIMD3(0, 0, 0),
            max: SIMD3(5, 3, 5)
        )
        let room = RoomLayout(bounds: bounds)

        // Then
        XCTAssertNotNil(room.id)
        XCTAssertEqual(room.bounds.min, SIMD3(0, 0, 0))
        XCTAssertEqual(room.bounds.max, SIMD3(5, 3, 5))
        XCTAssertTrue(room.furniture.isEmpty)
        XCTAssertTrue(room.hidingSpots.isEmpty)
    }

    func testRoomLayout_withFurniture() {
        // Given
        let bounds = BoundingBox(min: .zero, max: SIMD3(10, 3, 10))
        let furniture = FurnitureItem(
            type: .sofa,
            position: SIMD3(5, 0, 5),
            size: SIMD3(2, 0.8, 1),
            orientation: simd_quatf(angle: 0, axis: SIMD3(0, 1, 0)),
            hidingPotential: 0.9
        )

        // When
        var room = RoomLayout(bounds: bounds)
        room.furniture.append(furniture)

        // Then
        XCTAssertEqual(room.furniture.count, 1)
        XCTAssertEqual(room.furniture[0].type, .sofa)
    }

    // MARK: - SafetyBoundary Tests

    func testSafetyBoundary_initialization() {
        // Given
        let points = [
            SIMD3<Float>(0, 0, 0),
            SIMD3<Float>(5, 0, 0),
            SIMD3<Float>(5, 0, 5),
            SIMD3<Float>(0, 0, 5)
        ]

        // When
        let boundary = SafetyBoundary(points: points)

        // Then
        XCTAssertEqual(boundary.points.count, 4)
        XCTAssertEqual(boundary.warningDistance, 0.5, accuracy: 0.001)
        XCTAssertEqual(boundary.hardBoundaryDistance, 0.1, accuracy: 0.001)
    }

    func testSafetyBoundary_customDistances() {
        // Given
        let points = [SIMD3<Float>(0, 0, 0)]

        // When
        let boundary = SafetyBoundary(
            points: points,
            warningDistance: 1.0,
            hardBoundaryDistance: 0.2
        )

        // Then
        XCTAssertEqual(boundary.warningDistance, 1.0, accuracy: 0.001)
        XCTAssertEqual(boundary.hardBoundaryDistance, 0.2, accuracy: 0.001)
    }

    // MARK: - Codable Tests

    func testRoomLayout_encodingAndDecoding() throws {
        // Given
        let bounds = BoundingBox(min: .zero, max: SIMD3(10, 3, 10))
        let furniture = FurnitureItem(
            type: .table,
            position: SIMD3(2, 0, 2),
            size: SIMD3(1.5, 0.7, 1),
            orientation: simd_quatf(angle: 0, axis: SIMD3(0, 1, 0)),
            hidingPotential: 0.7
        )
        var originalRoom = RoomLayout(bounds: bounds)
        originalRoom.furniture.append(furniture)

        // When
        let encoder = JSONEncoder()
        let data = try encoder.encode(originalRoom)

        let decoder = JSONDecoder()
        let decodedRoom = try decoder.decode(RoomLayout.self, from: data)

        // Then
        XCTAssertEqual(originalRoom.id, decodedRoom.id)
        XCTAssertEqual(originalRoom.furniture.count, decodedRoom.furniture.count)
        XCTAssertEqual(originalRoom.furniture[0].type, decodedRoom.furniture[0].type)
        XCTAssertEqual(originalRoom.bounds.min, decodedRoom.bounds.min)
    }
}
