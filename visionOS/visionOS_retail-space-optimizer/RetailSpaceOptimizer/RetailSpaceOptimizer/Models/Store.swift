import Foundation
import SwiftData

@Model
final class Store {
    @Attribute(.unique) var id: UUID
    var name: String
    var location: StoreLocation
    var dimensions: StoreDimensions
    var createdDate: Date
    var modifiedDate: Date
    var version: Int

    @Relationship(deleteRule: .cascade)
    var layouts: [StoreLayout]?

    @Relationship(deleteRule: .cascade)
    var zones: [StoreZone]?

    @Relationship(deleteRule: .cascade)
    var performanceMetrics: [PerformanceMetric]?

    @Relationship(deleteRule: .cascade)
    var customerJourneys: [CustomerJourney]?

    init(
        id: UUID = UUID(),
        name: String,
        location: StoreLocation,
        dimensions: StoreDimensions,
        createdDate: Date = Date(),
        modifiedDate: Date = Date(),
        version: Int = 1
    ) {
        self.id = id
        self.name = name
        self.location = location
        self.dimensions = dimensions
        self.createdDate = createdDate
        self.modifiedDate = modifiedDate
        self.version = version
    }
}

// MARK: - Store Location

struct StoreLocation: Codable, Hashable {
    var address: String
    var city: String
    var state: String
    var country: String
    var postalCode: String
    var latitude: Double?
    var longitude: Double?
}

// MARK: - Store Dimensions

struct StoreDimensions: Codable, Hashable {
    var width: Float  // meters
    var length: Float // meters
    var height: Float // meters

    var area: Float {
        width * length
    }

    var usableArea: Float {
        area * 0.85 // 85% of total area is typically usable
    }
}

// MARK: - Mock Data

extension Store {
    static func mock() -> Store {
        Store(
            name: "Downtown Flagship",
            location: StoreLocation(
                address: "123 Main St",
                city: "San Francisco",
                state: "CA",
                country: "USA",
                postalCode: "94102",
                latitude: 37.7749,
                longitude: -122.4194
            ),
            dimensions: StoreDimensions(
                width: 20.0,
                length: 30.0,
                height: 4.0
            )
        )
    }

    static func mockArray(count: Int = 5) -> [Store] {
        let names = ["Downtown Flagship", "Suburban Mall", "Airport Terminal", "Shopping District", "Outlet Center"]
        let cities = ["San Francisco", "Los Angeles", "Seattle", "Portland", "Austin"]

        return (0..<min(count, names.count)).map { index in
            Store(
                name: names[index],
                location: StoreLocation(
                    address: "\(index + 100) Main St",
                    city: cities[index],
                    state: "CA",
                    country: "USA",
                    postalCode: "9410\(index)",
                    latitude: 37.7749 + Double(index) * 0.1,
                    longitude: -122.4194 + Double(index) * 0.1
                ),
                dimensions: StoreDimensions(
                    width: Float(15 + index * 5),
                    length: Float(20 + index * 10),
                    height: 4.0
                )
            )
        }
    }
}
