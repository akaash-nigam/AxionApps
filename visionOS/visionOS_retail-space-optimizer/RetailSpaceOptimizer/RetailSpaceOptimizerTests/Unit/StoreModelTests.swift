import XCTest
@testable import RetailSpaceOptimizer

/// Unit tests for Store data model
final class StoreModelTests: XCTestCase {

    // MARK: - Initialization Tests

    func testStoreInitialization() {
        // Given
        let location = StoreLocation(
            address: "123 Main St",
            city: "San Francisco",
            state: "CA",
            country: "USA",
            postalCode: "94102"
        )
        let dimensions = StoreDimensions(width: 20, length: 30, height: 4)

        // When
        let store = Store(
            name: "Test Store",
            location: location,
            dimensions: dimensions
        )

        // Then
        XCTAssertNotNil(store.id)
        XCTAssertEqual(store.name, "Test Store")
        XCTAssertEqual(store.location.city, "San Francisco")
        XCTAssertEqual(store.dimensions.width, 20)
        XCTAssertEqual(store.version, 1)
    }

    func testStoreLocationInitialization() {
        // Given & When
        let location = StoreLocation(
            address: "456 Oak Ave",
            city: "Los Angeles",
            state: "CA",
            country: "USA",
            postalCode: "90001",
            latitude: 34.0522,
            longitude: -118.2437
        )

        // Then
        XCTAssertEqual(location.city, "Los Angeles")
        XCTAssertEqual(location.latitude, 34.0522)
        XCTAssertEqual(location.longitude, -118.2437)
    }

    // MARK: - Dimensions Tests

    func testStoreDimensionsCalculations() {
        // Given
        let dimensions = StoreDimensions(width: 20, length: 30, height: 4)

        // When
        let area = dimensions.area
        let usableArea = dimensions.usableArea

        // Then
        XCTAssertEqual(area, 600.0) // 20 * 30
        XCTAssertEqual(usableArea, 510.0) // 600 * 0.85
    }

    func testStoreDimensionsAreaCalculation() {
        // Given
        let dimensions = StoreDimensions(width: 15, length: 25, height: 3.5)

        // Then
        XCTAssertEqual(dimensions.area, 375.0)
    }

    // MARK: - Mock Data Tests

    func testMockStoreCreation() {
        // When
        let mockStore = Store.mock()

        // Then
        XCTAssertNotNil(mockStore.id)
        XCTAssertEqual(mockStore.name, "Downtown Flagship")
        XCTAssertEqual(mockStore.location.city, "San Francisco")
        XCTAssertEqual(mockStore.dimensions.width, 20.0)
    }

    func testMockStoreArrayCreation() {
        // When
        let stores = Store.mockArray(count: 5)

        // Then
        XCTAssertEqual(stores.count, 5)
        XCTAssertEqual(stores[0].name, "Downtown Flagship")
        XCTAssertEqual(stores[1].name, "Suburban Mall")

        // Verify all stores have unique IDs
        let uniqueIds = Set(stores.map { $0.id })
        XCTAssertEqual(uniqueIds.count, 5)
    }

    // MARK: - Relationships Tests

    func testStoreLayoutsRelationship() {
        // Given
        let store = Store.mock()
        let layout = StoreLayout.mock()

        // When
        store.layouts = [layout]

        // Then
        XCTAssertEqual(store.layouts?.count, 1)
        XCTAssertEqual(store.layouts?.first?.name, "Standard Layout")
    }

    // MARK: - Codable Tests

    func testStoreLocationCodable() throws {
        // Given
        let location = StoreLocation(
            address: "789 Pine St",
            city: "Seattle",
            state: "WA",
            country: "USA",
            postalCode: "98101"
        )

        // When
        let encoder = JSONEncoder()
        let data = try encoder.encode(location)
        let decoder = JSONDecoder()
        let decodedLocation = try decoder.decode(StoreLocation.self, from: data)

        // Then
        XCTAssertEqual(decodedLocation.address, location.address)
        XCTAssertEqual(decodedLocation.city, location.city)
    }

    func testStoreDimensionsCodable() throws {
        // Given
        let dimensions = StoreDimensions(width: 25, length: 35, height: 5)

        // When
        let encoder = JSONEncoder()
        let data = try encoder.encode(dimensions)
        let decoder = JSONDecoder()
        let decodedDimensions = try decoder.decode(StoreDimensions.self, from: data)

        // Then
        XCTAssertEqual(decodedDimensions.width, dimensions.width)
        XCTAssertEqual(decodedDimensions.length, dimensions.length)
        XCTAssertEqual(decodedDimensions.height, dimensions.height)
    }

    // MARK: - Validation Tests

    func testValidStoreDimensions() {
        // Given
        let validDimensions = StoreDimensions(width: 10, length: 15, height: 3)

        // Then
        XCTAssertGreaterThan(validDimensions.width, 0)
        XCTAssertGreaterThan(validDimensions.length, 0)
        XCTAssertGreaterThan(validDimensions.height, 0)
        XCTAssertGreaterThan(validDimensions.area, 0)
    }

    // MARK: - Performance Tests

    func testMockStoreArrayPerformance() {
        measure {
            let _ = Store.mockArray(count: 100)
        }
    }
}
