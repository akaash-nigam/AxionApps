import Foundation
import SwiftData

@Model
final class Room {
    @Attribute(.unique) var id: UUID
    var name: String
    var roomType: RoomType
    var floorLevel: Int

    @Relationship(deleteRule: .nullify, inverse: \Home.rooms)
    var home: Home?

    @Relationship(deleteRule: .cascade, inverse: \SmartDevice.room)
    var devices: [SmartDevice]

    @Relationship(deleteRule: .cascade)
    var anchors: [RoomAnchor]

    var createdAt: Date
    var updatedAt: Date

    init(name: String, roomType: RoomType, floorLevel: Int = 0) {
        self.id = UUID()
        self.name = name
        self.roomType = roomType
        self.floorLevel = floorLevel
        self.createdAt = Date()
        self.updatedAt = Date()
        self.devices = []
        self.anchors = []
    }
}

enum RoomType: String, Codable, CaseIterable {
    case kitchen
    case livingRoom
    case bedroom
    case bathroom
    case office
    case entryway
    case hallway
    case garage
    case basement
    case laundryRoom
    case diningRoom
    case other

    var displayName: String {
        switch self {
        case .kitchen: "Kitchen"
        case .livingRoom: "Living Room"
        case .bedroom: "Bedroom"
        case .bathroom: "Bathroom"
        case .office: "Office"
        case .entryway: "Entryway"
        case .hallway: "Hallway"
        case .garage: "Garage"
        case .basement: "Basement"
        case .laundryRoom: "Laundry Room"
        case .diningRoom: "Dining Room"
        case .other: "Other"
        }
    }

    var icon: String {
        switch self {
        case .kitchen: "fork.knife"
        case .livingRoom: "sofa.fill"
        case .bedroom: "bed.double.fill"
        case .bathroom: "shower.fill"
        case .office: "desktopcomputer"
        case .entryway: "door.left.hand.open"
        case .hallway: "arrow.left.and.right"
        case .garage: "car.fill"
        case .basement: "arrow.down.to.line"
        case .laundryRoom: "washer.fill"
        case .diningRoom: "fork.knife.circle.fill"
        case .other: "square.fill"
        }
    }
}
