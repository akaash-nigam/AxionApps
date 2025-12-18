import Foundation

/// Base protocol for all game events
protocol GameEvent {
    var timestamp: Date { get }
    var eventID: UUID { get }
    var eventType: EventType { get }
}

/// Types of events that can occur in the game
enum EventType: Equatable {
    case characterAction(UUID, Action)
    case relationshipChange(UUID, UUID, RelationshipDelta)
    case needsCritical(UUID, NeedType)
    case lifeStage(UUID, LifeStage)
    case career(UUID, CareerEvent)
    case spatial(SpatialEvent)

    static func == (lhs: EventType, rhs: EventType) -> Bool {
        switch (lhs, rhs) {
        case (.characterAction(let id1, _), .characterAction(let id2, _)):
            return id1 == id2
        case (.relationshipChange(let a1, let b1, _), .relationshipChange(let a2, let b2, _)):
            return a1 == a2 && b1 == b2
        case (.needsCritical(let id1, let need1), .needsCritical(let id2, let need2)):
            return id1 == id2 && need1 == need2
        case (.lifeStage(let id1, let stage1), .lifeStage(let id2, let stage2)):
            return id1 == id2 && stage1 == stage2
        case (.career(let id1, _), .career(let id2, _)):
            return id1 == id2
        case (.spatial, .spatial):
            return true
        default:
            return false
        }
    }
}

/// Concrete game event implementation
struct ConcreteGameEvent: GameEvent {
    let timestamp: Date
    let eventID: UUID
    let eventType: EventType

    init(timestamp: Date, eventID: UUID, eventType: EventType) {
        self.timestamp = timestamp
        self.eventID = eventID
        self.eventType = eventType
    }
}

// MARK: - Event Payloads

enum Action: Equatable {
    case eat
    case sleep
    case socialize
    case work
    case exercise
    case relax
    case custom(String)
}

struct RelationshipDelta: Equatable {
    let scoreDelta: Float
    let interactionType: InteractionType

    enum InteractionType: Equatable {
        case positive
        case negative
        case neutral
        case romantic
    }
}

enum NeedType: String, Codable, Equatable, CaseIterable {
    case hunger
    case energy
    case social
    case fun
    case hygiene
    case bladder
}

enum LifeStage: String, Codable, Equatable, CaseIterable {
    case baby       // 0-2
    case toddler    // 3-5
    case child      // 6-12
    case teen       // 13-19
    case youngAdult // 20-30
    case adult      // 31-50
    case elder      // 51+
}

enum CareerEvent: Equatable {
    case hired(jobTitle: String)
    case promoted(newLevel: Int)
    case fired
    case retired
    case performance(score: Float)
}

enum SpatialEvent: Equatable {
    case enteredRoom(roomID: UUID)
    case exitedRoom(roomID: UUID)
    case usedFurniture(furnitureID: UUID)
    case claimedTerritory(locationID: UUID)
}
