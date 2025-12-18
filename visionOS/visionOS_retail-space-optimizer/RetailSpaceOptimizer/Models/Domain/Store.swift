import Foundation
import SwiftData

@Model
final class Store {
    @Attribute(.unique) var id: UUID
    var name: String
    var location: StoreLocation
    var dimensions: StoreDimensions
    var layout: StoreLayout
    var createdAt: Date
    var updatedAt: Date

    // Relationships
    var fixtures: [Fixture]
    var products: [Product]
    var analytics: StoreAnalytics?

    init(name: String, location: StoreLocation, dimensions: StoreDimensions) {
        self.id = UUID()
        self.name = name
        self.location = location
        self.dimensions = dimensions
        self.layout = StoreLayout()
        self.createdAt = Date()
        self.updatedAt = Date()
        self.fixtures = []
        self.products = []
    }

    // MARK: - Computed Properties
    var floorArea: Double {
        dimensions.floorArea
    }

    var fixtureCount: Int {
        fixtures.count
    }

    var productCount: Int {
        products.count
    }
}

// MARK: - Supporting Types

struct StoreLocation: Codable, Hashable {
    var address: String
    var city: String
    var state: String
    var country: String
    var postalCode: String?
    var coordinates: GeographicCoordinate?
}

struct GeographicCoordinate: Codable, Hashable {
    var latitude: Double
    var longitude: Double
}

struct StoreDimensions: Codable, Hashable {
    var width: Double      // meters
    var depth: Double      // meters
    var height: Double     // meters

    var floorArea: Double {
        width * depth
    }

    var volume: Double {
        width * depth * height
    }
}

struct StoreLayout: Codable, Hashable {
    var zones: [StoreZone] = []
    var aisles: [Aisle] = []
    var entrances: [Entrance] = []
    var checkouts: [Checkout] = []
    var walls: [Wall] = []
}

struct StoreZone: Codable, Hashable, Identifiable {
    var id: UUID = UUID()
    var name: String
    var category: ZoneCategory
    var bounds: BoundingBox
    var color: CodableColor?
}

enum ZoneCategory: String, Codable, CaseIterable {
    case entrance
    case checkout
    case retail
    case storage
    case fitting
    case service
    case display
    case promotional
}

struct Aisle: Codable, Hashable, Identifiable {
    var id: UUID = UUID()
    var name: String
    var startPoint: SIMD3<Double>
    var endPoint: SIMD3<Double>
    var width: Double
}

struct Entrance: Codable, Hashable, Identifiable {
    var id: UUID = UUID()
    var name: String
    var position: SIMD3<Double>
    var width: Double
    var isMain: Bool
}

struct Checkout: Codable, Hashable, Identifiable {
    var id: UUID = UUID()
    var name: String
    var position: SIMD3<Double>
    var lanes: Int
}

struct Wall: Codable, Hashable, Identifiable {
    var id: UUID = UUID()
    var startPoint: SIMD3<Double>
    var endPoint: SIMD3<Double>
    var height: Double
    var thickness: Double
    var isExterior: Bool
}

struct BoundingBox: Codable, Hashable {
    var min: SIMD3<Double>
    var max: SIMD3<Double>

    var center: SIMD3<Double> {
        (min + max) / 2
    }

    var size: SIMD3<Double> {
        max - min
    }

    func contains(_ point: SIMD3<Double>) -> Bool {
        return point.x >= min.x && point.x <= max.x &&
               point.y >= min.y && point.y <= max.y &&
               point.z >= min.z && point.z <= max.z
    }

    func intersects(_ other: BoundingBox) -> Bool {
        return !(max.x < other.min.x || min.x > other.max.x ||
                max.y < other.min.y || min.y > other.max.y ||
                max.z < other.min.z || min.z > other.max.z)
    }
}

// Helper to make Color codable
struct CodableColor: Codable, Hashable {
    var red: Double
    var green: Double
    var blue: Double
    var alpha: Double

    init(red: Double, green: Double, blue: Double, alpha: Double = 1.0) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }
}
