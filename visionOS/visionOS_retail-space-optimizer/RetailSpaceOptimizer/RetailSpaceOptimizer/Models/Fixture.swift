import Foundation
import SwiftData
import Spatial

@Model
final class Fixture {
    @Attribute(.unique) var id: UUID
    var name: String
    var fixtureType: FixtureType
    var category: FixtureCategory
    var position: SIMD3<Float>
    var rotation: Rotation3D
    var dimensions: SIMD3<Float>
    var capacity: Int
    var modelAsset: String
    var materialAssets: [String]

    @Relationship(deleteRule: .cascade)
    var products: [Product]?

    init(
        id: UUID = UUID(),
        name: String,
        fixtureType: FixtureType,
        category: FixtureCategory,
        position: SIMD3<Float>,
        rotation: Rotation3D = .identity,
        dimensions: SIMD3<Float>,
        capacity: Int,
        modelAsset: String,
        materialAssets: [String] = []
    ) {
        self.id = id
        self.name = name
        self.fixtureType = fixtureType
        self.category = category
        self.position = position
        self.rotation = rotation
        self.dimensions = dimensions
        self.capacity = capacity
        self.modelAsset = modelAsset
        self.materialAssets = materialAssets
    }
}

// MARK: - Fixture Types

enum FixtureType: String, Codable, CaseIterable {
    case shelf = "Shelf"
    case rack = "Rack"
    case table = "Table"
    case mannequin = "Mannequin"
    case checkout = "Checkout"
    case entrance = "Entrance"
    case signage = "Signage"
    case display = "Display"
}

enum FixtureCategory: String, Codable, CaseIterable {
    case apparel = "Apparel"
    case footwear = "Footwear"
    case accessories = "Accessories"
    case electronics = "Electronics"
    case home = "Home"
    case grocery = "Grocery"
    case checkout = "Checkout"
    case service = "Service"
}

// MARK: - Rotation 3D

struct Rotation3D: Codable, Hashable {
    var angle: Float // radians
    var axis: SIMD3<Float>

    static let identity = Rotation3D(angle: 0, axis: SIMD3(0, 1, 0))

    init(angle: Float, axis: SIMD3<Float>) {
        self.angle = angle
        self.axis = axis
    }

    // Convenience initializers for common rotations
    static func yaw(_ radians: Float) -> Rotation3D {
        Rotation3D(angle: radians, axis: SIMD3(0, 1, 0))
    }

    static func pitch(_ radians: Float) -> Rotation3D {
        Rotation3D(angle: radians, axis: SIMD3(1, 0, 0))
    }

    static func roll(_ radians: Float) -> Rotation3D {
        Rotation3D(angle: radians, axis: SIMD3(0, 0, 1))
    }
}

// MARK: - Mock Data

extension Fixture {
    static func mock() -> Fixture {
        Fixture(
            name: "Clothing Rack Standard",
            fixtureType: .rack,
            category: .apparel,
            position: SIMD3(5, 0, 10),
            dimensions: SIMD3(2, 1.8, 0.6),
            capacity: 50,
            modelAsset: "ClothingRack_Standard",
            materialAssets: ["Metal_Chrome", "Wood_Oak"]
        )
    }

    static func mockArray(count: Int = 10) -> [Fixture] {
        let types: [FixtureType] = [.shelf, .rack, .table, .mannequin, .display]
        let categories: [FixtureCategory] = [.apparel, .footwear, .accessories, .electronics]

        return (0..<count).map { index in
            let type = types[index % types.count]
            let category = categories[index % categories.count]

            return Fixture(
                name: "\(type.rawValue) \(index + 1)",
                fixtureType: type,
                category: category,
                position: SIMD3(
                    Float(index % 5) * 3.0,
                    0,
                    Float(index / 5) * 3.0
                ),
                dimensions: SIMD3(2, 1.8, 0.6),
                capacity: 20 + index * 5,
                modelAsset: "\(type.rawValue)_Standard"
            )
        }
    }
}
