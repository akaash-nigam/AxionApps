//
//  EventBus.swift
//  Reality Realms RPG
//
//  Central event system for decoupled communication
//

import Foundation

/// Centralized event bus for game-wide event communication
@MainActor
class EventBus {
    static let shared = EventBus()

    private var subscribers: [String: [(Any) -> Void]] = [:]
    private let queue = DispatchQueue(label: "com.realityrealms.eventbus", qos: .userInteractive)

    private init() {
        print("📡 EventBus initialized")
    }

    /// Subscribe to events of a specific type
    func subscribe<T>(_ eventType: T.Type, handler: @escaping (T) -> Void) {
        let key = String(describing: eventType)

        let wrappedHandler: (Any) -> Void = { event in
            if let typedEvent = event as? T {
                handler(typedEvent)
            }
        }

        queue.async { [weak self] in
            self?.subscribers[key, default: []].append(wrappedHandler)
        }
    }

    /// Publish an event to all subscribers
    func publish<T>(_ event: T) {
        let key = String(describing: T.self)

        queue.async { [weak self] in
            guard let handlers = self?.subscribers[key] else { return }

            Task { @MainActor in
                for handler in handlers {
                    handler(event)
                }
            }
        }
    }

    /// Clear all subscribers (useful for testing)
    func clear() {
        queue.async { [weak self] in
            self?.subscribers.removeAll()
        }
    }
}

// MARK: - Game Events

/// Base protocol for all game events
protocol GameEvent {}

// State Events
struct StateChangeEvent: GameEvent {
    let from: GameState
    let to: GameState
    let timestamp: Date = Date()
}

// Combat Events
struct CombatGestureEvent: GameEvent {
    let gesture: CombatGesture
    let timestamp: Date = Date()
}

struct DamageDealtEvent: GameEvent {
    let attackerID: UUID
    let targetID: UUID
    let damage: Int
    let damageType: DamageType
    let isCritical: Bool
}

struct EntityDefeatedEvent: GameEvent {
    let entityID: UUID
    let killerID: UUID
    let experience: Int
}

// Progression Events
struct LevelUpEvent: GameEvent {
    let playerID: UUID
    let newLevel: Int
    let skillPointsGained: Int
}

struct ExperienceGainedEvent: GameEvent {
    let playerID: UUID
    let amount: Int
    let source: String
}

// Quest Events
struct QuestAcceptedEvent: GameEvent {
    let questID: UUID
    let questName: String
}

struct QuestCompletedEvent: GameEvent {
    let questID: UUID
    let rewards: [Reward]
}

struct QuestProgressEvent: GameEvent {
    let questID: UUID
    let progress: Float  // 0.0 to 1.0
}

// Multiplayer Events
struct MultiplayerSyncEvent: GameEvent {
    let playerID: String
    let action: PlayerAction
    let timestamp: Date = Date()
}

struct PlayerJoinedEvent: GameEvent {
    let playerID: String
    let playerName: String
}

struct PlayerLeftEvent: GameEvent {
    let playerID: String
}

// Spatial Events
struct RoomMappingCompleteEvent: GameEvent {
    let roomLayout: RoomLayout?
}

struct FurnitureDetectedEvent: GameEvent {
    let furnitureID: UUID
    let furnitureType: FurnitureType
}

struct AnchorPlacedEvent: GameEvent {
    let anchorID: UUID
    let position: SIMD3<Float>
}

// UI Events
struct ShowNotificationEvent: GameEvent {
    let title: String
    let message: String
    let duration: TimeInterval = 3.0
}

struct ShowDialogEvent: GameEvent {
    let npcID: UUID
    let dialogueText: String
}

// Supporting Types
enum CombatGesture {
    case swordSlash(direction: SIMD3<Float>)
    case shieldBlock
    case spellCast(type: SpellType)
    case bowDraw
    case dodge(direction: SIMD3<Float>)
}

enum SpellType {
    case fireball
    case iceS hard
    case lightningBolt
    case heal
    case shield
}

enum DamageType {
    case physical
    case fire
    case ice
    case lightning
    case arcane
    case poison
}

struct Reward {
    let type: RewardType
    let amount: Int

    enum RewardType {
        case experience
        case gold
        case item(itemID: UUID)
        case skillPoint
    }
}

enum PlayerAction: Codable {
    case move(position: SIMD3<Float>)
    case attack(targetID: UUID)
    case useAbility(abilityID: String)
    case interact(objectID: UUID)
}

enum FurnitureType {
    case couch
    case table
    case chair
    case bed
    case shelf
    case desk
    case tv
    case other
}
