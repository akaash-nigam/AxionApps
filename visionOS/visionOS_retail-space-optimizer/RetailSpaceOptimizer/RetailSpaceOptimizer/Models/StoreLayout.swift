import Foundation
import SwiftData

@Model
final class StoreLayout {
    @Attribute(.unique) var id: UUID
    var name: String
    var layoutDescription: String
    var layoutType: LayoutType
    var gridSize: Float
    var isActive: Bool
    var createdDate: Date
    var modifiedDate: Date

    @Relationship(deleteRule: .cascade)
    var fixtures: [Fixture]?

    var entrances: [Entrance]
    var exits: [Exit]
    var walls: [Wall]
    var columns: [Column]

    init(
        id: UUID = UUID(),
        name: String,
        layoutDescription: String = "",
        layoutType: LayoutType = .grid,
        gridSize: Float = 0.5,
        isActive: Bool = true,
        createdDate: Date = Date(),
        modifiedDate: Date = Date(),
        entrances: [Entrance] = [],
        exits: [Exit] = [],
        walls: [Wall] = [],
        columns: [Column] = []
    ) {
        self.id = id
        self.name = name
        self.layoutDescription = layoutDescription
        self.layoutType = layoutType
        self.gridSize = gridSize
        self.isActive = isActive
        self.createdDate = createdDate
        self.modifiedDate = modifiedDate
        self.entrances = entrances
        self.exits = exits
        self.walls = walls
        self.columns = columns
    }
}

// MARK: - Layout Type

enum LayoutType: String, Codable, CaseIterable {
    case grid = "Grid"
    case freeform = "Freeform"
    case racetrack = "Racetrack"
    case boutique = "Boutique"
    case marketplace = "Marketplace"
}

// MARK: - Structural Elements

struct Entrance: Codable, Hashable, Identifiable {
    var id: UUID = UUID()
    var position: SIMD2<Float>
    var width: Float
    var direction: Direction

    enum Direction: String, Codable {
        case north, south, east, west
    }
}

struct Exit: Codable, Hashable, Identifiable {
    var id: UUID = UUID()
    var position: SIMD2<Float>
    var width: Float
    var direction: Entrance.Direction
    var isEmergency: Bool = false
}

struct Wall: Codable, Hashable, Identifiable {
    var id: UUID = UUID()
    var startPoint: SIMD2<Float>
    var endPoint: SIMD2<Float>
    var height: Float
    var thickness: Float = 0.2
}

struct Column: Codable, Hashable, Identifiable {
    var id: UUID = UUID()
    var position: SIMD2<Float>
    var width: Float
    var depth: Float
    var height: Float
}

// MARK: - Mock Data

extension StoreLayout {
    static func mock() -> StoreLayout {
        StoreLayout(
            name: "Standard Layout",
            layoutDescription: "Basic grid layout with central aisle",
            layoutType: .grid,
            entrances: [
                Entrance(position: SIMD2(10, 0), width: 2.0, direction: .south)
            ],
            exits: [
                Exit(position: SIMD2(10, 30), width: 2.0, direction: .north)
            ],
            walls: [
                Wall(startPoint: SIMD2(0, 0), endPoint: SIMD2(20, 0), height: 4.0),
                Wall(startPoint: SIMD2(20, 0), endPoint: SIMD2(20, 30), height: 4.0),
                Wall(startPoint: SIMD2(20, 30), endPoint: SIMD2(0, 30), height: 4.0),
                Wall(startPoint: SIMD2(0, 30), endPoint: SIMD2(0, 0), height: 4.0)
            ]
        )
    }
}
