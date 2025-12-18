//
//  Room.swift
//  RealEstateSpatial
//
//  Room entity for property spatial data
//

import Foundation
import SwiftData

// MARK: - Room Entity

@Model
final class Room {
    @Attribute(.unique) var id: UUID
    var name: String
    var type: RoomType
    var dimensions: RoomDimensions
    var features: [String]
    var meshAssetURL: URL?
    var textureURL: URL?
    var floorLevel: Int

    @Relationship(inverse: \Property.rooms) var property: Property?

    init(
        id: UUID = UUID(),
        name: String,
        type: RoomType,
        dimensions: RoomDimensions,
        features: [String] = [],
        meshAssetURL: URL? = nil,
        textureURL: URL? = nil,
        floorLevel: Int = 1
    ) {
        self.id = id
        self.name = name
        self.type = type
        self.dimensions = dimensions
        self.features = features
        self.meshAssetURL = meshAssetURL
        self.textureURL = textureURL
        self.floorLevel = floorLevel
    }

    // Computed Properties
    var squareFeet: Double {
        dimensions.squareFeet
    }

    var volume: Double {
        dimensions.length * dimensions.width * dimensions.height
    }

    var displayName: String {
        name.isEmpty ? type.rawValue : name
    }
}

// MARK: - Supporting Structures

struct RoomDimensions: Codable, Hashable {
    var length: Double  // meters
    var width: Double   // meters
    var height: Double  // meters

    init(length: Double, width: Double, height: Double) {
        self.length = length
        self.width = width
        self.height = height
    }

    // Convert to square feet
    var squareFeet: Double {
        let squareMeters = length * width
        return squareMeters * 10.764 // 1 m² = 10.764 ft²
    }

    // Get dimensions in feet
    var lengthInFeet: Double {
        length * 3.28084
    }

    var widthInFeet: Double {
        width * 3.28084
    }

    var heightInFeet: Double {
        height * 3.28084
    }
}

// MARK: - Enumerations

enum RoomType: String, Codable, CaseIterable {
    case livingRoom = "Living Room"
    case bedroom = "Bedroom"
    case masterBedroom = "Master Bedroom"
    case kitchen = "Kitchen"
    case bathroom = "Bathroom"
    case diningRoom = "Dining Room"
    case office = "Office"
    case garage = "Garage"
    case basement = "Basement"
    case attic = "Attic"
    case laundry = "Laundry Room"
    case hallway = "Hallway"
    case closet = "Closet"
    case patio = "Patio"
    case deck = "Deck"
    case yard = "Yard"
    case other = "Other"

    var icon: String {
        switch self {
        case .livingRoom: return "sofa.fill"
        case .bedroom, .masterBedroom: return "bed.double.fill"
        case .kitchen: return "fork.knife"
        case .bathroom: return "shower.fill"
        case .diningRoom: return "fork.knife.circle.fill"
        case .office: return "desktopcomputer"
        case .garage: return "car.fill"
        case .basement: return "arrow.down.to.line"
        case .attic: return "arrow.up.to.line"
        case .laundry: return "washer.fill"
        case .hallway: return "arrow.left.arrow.right"
        case .closet: return "cabinet.fill"
        case .patio, .deck: return "rectangle.on.rectangle.angled"
        case .yard: return "leaf.fill"
        case .other: return "square.dashed"
        }
    }

    var color: String {
        switch self {
        case .livingRoom: return "#4A90E2"
        case .bedroom, .masterBedroom: return "#9B59B6"
        case .kitchen: return "#F39C12"
        case .bathroom: return "#1ABC9C"
        case .diningRoom: return "#E67E22"
        case .office: return "#27AE60"
        case .garage: return "#95A5A6"
        case .basement: return "#34495E"
        case .attic: return "#7F8C8D"
        case .laundry: return "#3498DB"
        case .hallway: return "#BDC3C7"
        case .closet: return "#ECF0F1"
        case .patio, .deck: return "#16A085"
        case .yard: return "#2ECC71"
        case .other: return "#95A5A6"
        }
    }
}

// MARK: - Extensions

extension Room {
    static var preview: Room {
        Room(
            name: "Master Bedroom",
            type: .masterBedroom,
            dimensions: RoomDimensions(length: 4.5, width: 3.6, height: 2.7),
            features: ["Carpet flooring", "Walk-in closet", "Ensuite bathroom"],
            floorLevel: 2
        )
    }

    static func createSampleRooms() -> [Room] {
        [
            Room(
                name: "Living Room",
                type: .livingRoom,
                dimensions: RoomDimensions(length: 7.5, width: 5.5, height: 2.7),
                features: ["Hardwood floors", "Fireplace", "Bay windows"],
                floorLevel: 1
            ),
            Room(
                name: "Kitchen",
                type: .kitchen,
                dimensions: RoomDimensions(length: 4.0, width: 3.5, height: 2.7),
                features: ["Granite countertops", "Stainless appliances", "Island"],
                floorLevel: 1
            ),
            Room(
                name: "Master Bedroom",
                type: .masterBedroom,
                dimensions: RoomDimensions(length: 4.5, width: 3.6, height: 2.7),
                features: ["Carpet flooring", "Walk-in closet", "Ensuite bathroom"],
                floorLevel: 2
            ),
            Room(
                name: "Bedroom 2",
                type: .bedroom,
                dimensions: RoomDimensions(length: 3.5, width: 3.0, height: 2.7),
                features: ["Hardwood floors", "Built-in closet"],
                floorLevel: 2
            ),
            Room(
                name: "Bedroom 3",
                type: .bedroom,
                dimensions: RoomDimensions(length: 3.5, width: 3.0, height: 2.7),
                features: ["Carpet flooring", "Large window"],
                floorLevel: 2
            )
        ]
    }
}
