import XCTest
@testable import RetailSpaceOptimizer

/// Unit tests for Fixture data model
final class FixtureModelTests: XCTestCase {

    // MARK: - Initialization Tests

    func testFixtureInitialization() {
        // Given & When
        let fixture = Fixture(
            name: "Test Shelf",
            fixtureType: .shelf,
            category: .apparel,
            position: SIMD3(5, 0, 10),
            dimensions: SIMD3(2, 1.8, 0.6),
            capacity: 50,
            modelAsset: "Shelf_Standard"
        )

        // Then
        XCTAssertNotNil(fixture.id)
        XCTAssertEqual(fixture.name, "Test Shelf")
        XCTAssertEqual(fixture.fixtureType, .shelf)
        XCTAssertEqual(fixture.category, .apparel)
        XCTAssertEqual(fixture.capacity, 50)
    }

    func testFixtureRotation() {
        // Given
        let rotation = Rotation3D.yaw(.pi / 2) // 90 degrees

        let fixture = Fixture(
            name: "Rotated Rack",
            fixtureType: .rack,
            category: .footwear,
            position: SIMD3(0, 0, 0),
            rotation: rotation,
            dimensions: SIMD3(1, 2, 0.5),
            capacity: 30,
            modelAsset: "Rack_Standard"
        )

        // Then
        XCTAssertEqual(fixture.rotation.angle, .pi / 2, accuracy: 0.001)
        XCTAssertEqual(fixture.rotation.axis.y, 1.0)
    }

    // MARK: - Rotation3D Tests

    func testRotation3DIdentity() {
        // When
        let identity = Rotation3D.identity

        // Then
        XCTAssertEqual(identity.angle, 0)
        XCTAssertEqual(identity.axis.y, 1.0)
    }

    func testRotation3DYaw() {
        // When
        let yaw = Rotation3D.yaw(.pi)

        // Then
        XCTAssertEqual(yaw.angle, .pi)
        XCTAssertEqual(yaw.axis, SIMD3(0, 1, 0))
    }

    func testRotation3DPitch() {
        // When
        let pitch = Rotation3D.pitch(.pi / 4)

        // Then
        XCTAssertEqual(pitch.angle, .pi / 4)
        XCTAssertEqual(pitch.axis, SIMD3(1, 0, 0))
    }

    func testRotation3DRoll() {
        // When
        let roll = Rotation3D.roll(.pi / 6)

        // Then
        XCTAssertEqual(roll.angle, .pi / 6)
        XCTAssertEqual(roll.axis, SIMD3(0, 0, 1))
    }

    // MARK: - Fixture Type Tests

    func testAllFixtureTypes() {
        // Given
        let types: [FixtureType] = [.shelf, .rack, .table, .mannequin, .checkout, .entrance, .signage, .display]

        // Then
        XCTAssertEqual(types.count, 8)
        XCTAssertTrue(types.contains(.shelf))
        XCTAssertTrue(types.contains(.checkout))
    }

    func testFixtureTypeRawValues() {
        // Then
        XCTAssertEqual(FixtureType.shelf.rawValue, "Shelf")
        XCTAssertEqual(FixtureType.rack.rawValue, "Rack")
        XCTAssertEqual(FixtureType.mannequin.rawValue, "Mannequin")
    }

    // MARK: - Fixture Category Tests

    func testAllFixtureCategories() {
        // Given
        let categories = FixtureCategory.allCases

        // Then
        XCTAssertGreaterThanOrEqual(categories.count, 8)
        XCTAssertTrue(categories.contains(.apparel))
        XCTAssertTrue(categories.contains(.electronics))
    }

    // MARK: - Mock Data Tests

    func testMockFixtureCreation() {
        // When
        let fixture = Fixture.mock()

        // Then
        XCTAssertNotNil(fixture.id)
        XCTAssertEqual(fixture.name, "Clothing Rack Standard")
        XCTAssertEqual(fixture.fixtureType, .rack)
        XCTAssertEqual(fixture.category, .apparel)
    }

    func testMockFixtureArrayCreation() {
        // When
        let fixtures = Fixture.mockArray(count: 10)

        // Then
        XCTAssertEqual(fixtures.count, 10)

        // Verify unique IDs
        let uniqueIds = Set(fixtures.map { $0.id })
        XCTAssertEqual(uniqueIds.count, 10)

        // Verify different types
        let types = Set(fixtures.map { $0.fixtureType })
        XCTAssertGreaterThan(types.count, 1)
    }

    // MARK: - Position Tests

    func testFixturePositioning() {
        // Given
        let position = SIMD3<Float>(10, 0, 15)
        let fixture = Fixture(
            name: "Positioned Fixture",
            fixtureType: .table,
            category: .accessories,
            position: position,
            dimensions: SIMD3(1, 1, 1),
            capacity: 20,
            modelAsset: "Table_Model"
        )

        // Then
        XCTAssertEqual(fixture.position.x, 10)
        XCTAssertEqual(fixture.position.y, 0)
        XCTAssertEqual(fixture.position.z, 15)
    }

    // MARK: - Dimensions Tests

    func testFixtureDimensions() {
        // Given
        let dimensions = SIMD3<Float>(2.5, 1.8, 0.8)
        let fixture = Fixture(
            name: "Sized Fixture",
            fixtureType: .display,
            category: .electronics,
            position: SIMD3(0, 0, 0),
            dimensions: dimensions,
            capacity: 15,
            modelAsset: "Display_Model"
        )

        // Then
        XCTAssertEqual(fixture.dimensions.x, 2.5) // width
        XCTAssertEqual(fixture.dimensions.y, 1.8) // height
        XCTAssertEqual(fixture.dimensions.z, 0.8) // depth
    }

    // MARK: - Codable Tests

    func testRotation3DCodable() throws {
        // Given
        let rotation = Rotation3D(angle: .pi / 3, axis: SIMD3(0, 1, 0))

        // When
        let encoder = JSONEncoder()
        let data = try encoder.encode(rotation)
        let decoder = JSONDecoder()
        let decodedRotation = try decoder.decode(Rotation3D.self, from: data)

        // Then
        XCTAssertEqual(decodedRotation.angle, rotation.angle, accuracy: 0.001)
        XCTAssertEqual(decodedRotation.axis, rotation.axis)
    }

    // MARK: - Performance Tests

    func testFixtureArrayCreationPerformance() {
        measure {
            let _ = Fixture.mockArray(count: 100)
        }
    }
}
