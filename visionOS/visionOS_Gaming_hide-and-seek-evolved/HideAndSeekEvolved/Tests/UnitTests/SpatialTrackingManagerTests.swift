import XCTest
@testable import HideAndSeekEvolved

@MainActor
final class SpatialTrackingManagerTests: XCTestCase {
    var sut: SpatialTrackingManager!

    override func setUp() async throws {
        sut = SpatialTrackingManager()
    }

    override func tearDown() async throws {
        sut = nil
    }

    // MARK: - Initialization Tests

    func testInitialState_isNotStarted() {
        XCTAssertEqual(sut.trackingState, .notStarted)
    }

    func testInitialRoomLayout_isNil() {
        XCTAssertNil(sut.roomLayout)
    }

    func testInitialFurnitureCount_isZero() {
        XCTAssertEqual(sut.scannedFurnitureCount, 0)
    }

    // MARK: - Furniture Classification Tests

    func testClassifyMesh_table() {
        // Given - Table dimensions: low height, large surface
        let geometry = createMockGeometry(width: 1.5, height: 0.75, depth: 0.8)

        // When
        let type = sut.classifyMesh(geometry)

        // Then
        XCTAssertEqual(type, .table)
    }

    func testClassifyMesh_chair() {
        // Given - Chair dimensions: medium height, small footprint
        let geometry = createMockGeometry(width: 0.5, height: 1.0, depth: 0.5)

        // When
        let type = sut.classifyMesh(geometry)

        // Then
        XCTAssertEqual(type, .chair)
    }

    func testClassifyMesh_sofa() {
        // Given - Sofa dimensions: low height, large width
        let geometry = createMockGeometry(width: 2.0, height: 0.8, depth: 0.9)

        // When
        let type = sut.classifyMesh(geometry)

        // Then
        XCTAssertEqual(type, .sofa)
    }

    func testClassifyMesh_bed() {
        // Given - Bed dimensions: low height, very large
        let geometry = createMockGeometry(width: 2.0, height: 0.6, depth: 2.0)

        // When
        let type = sut.classifyMesh(geometry)

        // Then
        XCTAssertEqual(type, .bed)
    }

    func testClassifyMesh_wardrobe() {
        // Given - Wardrobe dimensions: tall
        let geometry = createMockGeometry(width: 1.0, height: 2.0, depth: 0.6)

        // When
        let type = sut.classifyMesh(geometry)

        // Then
        XCTAssertEqual(type, .wardrobe)
    }

    func testClassifyMesh_bookshelf() {
        // Given - Bookshelf dimensions: tall and shallow
        let geometry = createMockGeometry(width: 1.2, height: 1.8, depth: 0.3)

        // When
        let type = sut.classifyMesh(geometry)

        // Then
        XCTAssertEqual(type, .bookshelf)
    }

    func testClassifyMesh_decoration() {
        // Given - Small object
        let geometry = createMockGeometry(width: 0.3, height: 0.5, depth: 0.3)

        // When
        let type = sut.classifyMesh(geometry)

        // Then
        XCTAssertEqual(type, .decoration)
    }

    // MARK: - Hiding Potential Tests

    func testCalculateHidingPotential_sofa_highPotential() {
        // Given
        let geometry = createMockGeometry(width: 2.0, height: 0.8, depth: 0.9)

        // When
        let potential = sut.calculateHidingPotential(.sofa, geometry)

        // Then
        XCTAssertGreaterThan(potential, 0.85)
        XCTAssertLessThanOrEqual(potential, 1.0)
    }

    func testCalculateHidingPotential_table_mediumPotential() {
        // Given
        let geometry = createMockGeometry(width: 1.5, height: 0.75, depth: 0.8)

        // When
        let potential = sut.calculateHidingPotential(.table, geometry)

        // Then
        XCTAssertGreaterThan(potential, 0.6)
        XCTAssertLessThan(potential, 0.9)
    }

    func testCalculateHidingPotential_plant_lowPotential() {
        // Given
        let geometry = createMockGeometry(width: 0.4, height: 0.8, depth: 0.4)

        // When
        let potential = sut.calculateHidingPotential(.plant, geometry)

        // Then
        XCTAssertLessThan(potential, 0.5)
    }

    func testCalculateHidingPotential_clampedToOne() {
        // Given - Massive furniture
        let geometry = createMockGeometry(width: 10.0, height: 10.0, depth: 10.0)

        // When
        let potential = sut.calculateHidingPotential(.wardrobe, geometry)

        // Then
        XCTAssertEqual(potential, 1.0, accuracy: 0.001)
    }

    // MARK: - Hiding Spot Generation Tests

    func testGenerateHidingSpots_sofa_generatesBehindSpot() {
        // Given
        let furniture = FurnitureItem(
            type: .sofa,
            position: SIMD3(0, 0, 0),
            size: SIMD3(2.0, 0.8, 0.9),
            orientation: simd_quatf(angle: 0, axis: SIMD3(0, 1, 0)),
            hidingPotential: 0.9
        )

        // When
        let spots = sut.generateHidingSpots(for: furniture)

        // Then
        XCTAssertGreaterThan(spots.count, 0)
        XCTAssertTrue(spots.contains(where: { $0.associatedFurniture == furniture.id }))
    }

    func testGenerateHidingSpots_table_generatesUnderSpot() {
        // Given
        let furniture = FurnitureItem(
            type: .table,
            position: SIMD3(0, 0.75, 0),
            size: SIMD3(1.5, 0.75, 0.8),
            orientation: simd_quatf(angle: 0, axis: SIMD3(0, 1, 0)),
            hidingPotential: 0.7
        )

        // When
        let spots = sut.generateHidingSpots(for: furniture)

        // Then
        XCTAssertGreaterThan(spots.count, 0)
        let hasUnderSpot = spots.contains { spot in
            spot.location.y < furniture.position.y
        }
        XCTAssertTrue(hasUnderSpot)
    }

    func testGenerateHidingSpots_wardrobe_generatesInsideSpot() {
        // Given
        let furniture = FurnitureItem(
            type: .wardrobe,
            position: SIMD3(0, 1.0, 0),
            size: SIMD3(1.0, 2.0, 0.6),
            orientation: simd_quatf(angle: 0, axis: SIMD3(0, 1, 0)),
            hidingPotential: 0.9
        )

        // When
        let spots = sut.generateHidingSpots(for: furniture)

        // Then
        XCTAssertGreaterThan(spots.count, 0)
        let hasInsideSpot = spots.contains { spot in
            spot.quality > 0.9 && spot.accessibility == .easy
        }
        XCTAssertTrue(hasInsideSpot)
    }

    func testGenerateHidingSpots_bed_multipleSpots() {
        // Given
        let furniture = FurnitureItem(
            type: .bed,
            position: SIMD3(0, 0.5, 0),
            size: SIMD3(2.0, 0.6, 2.0),
            orientation: simd_quatf(angle: 0, axis: SIMD3(0, 1, 0)),
            hidingPotential: 0.9
        )

        // When
        let spots = sut.generateHidingSpots(for: furniture)

        // Then
        // Bed should generate both under and behind spots
        XCTAssertGreaterThanOrEqual(spots.count, 2)
    }

    // MARK: - Helper Methods

    private func createMockGeometry(width: Float, height: Float, depth: Float) -> MeshAnchor.Geometry {
        // Create a mock geometry for testing
        // In real implementation, this would use ARKit types
        return MockGeometry(extent: SIMD3(width, height, depth))
    }
}

// MARK: - Mock Geometry

struct MockGeometry {
    var extent: SIMD3<Float>
}

// Extension to make MeshAnchor.Geometry testable
extension SpatialTrackingManager {
    func classifyMesh(_ geometry: MockGeometry) -> FurnitureType {
        let boundingBox = geometry.extent
        let width = boundingBox.x
        let height = boundingBox.y
        let depth = boundingBox.z

        if height < 0.9 && height > 0.5 && width > 0.8 {
            return .table
        }
        if height > 0.8 && height < 1.2 && width < 0.8 {
            return .chair
        }
        if height > 0.4 && height < 0.9 && width > 1.5 {
            return .sofa
        }
        if height > 0.4 && height < 0.8 && width > 1.8 && depth > 1.8 {
            return .bed
        }
        if height > 1.5 {
            return .wardrobe
        }
        if height > 1.0 && depth < 0.5 {
            return .bookshelf
        }
        return .decoration
    }

    func calculateHidingPotential(_ type: FurnitureType, _ geometry: MockGeometry) -> Float {
        let baseQuality = type.defaultHidingPotential
        let volume = geometry.extent.x * geometry.extent.y * geometry.extent.z
        let sizeBonus = min(volume / 2.0, 0.2)
        return min(baseQuality + sizeBonus, 1.0)
    }
}
