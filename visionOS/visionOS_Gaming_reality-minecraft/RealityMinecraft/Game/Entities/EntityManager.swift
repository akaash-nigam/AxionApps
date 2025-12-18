//
//  EntityManager.swift
//  Reality Minecraft
//
//  Entity-Component-System (ECS) implementation
//

import Foundation
import RealityKit
import simd

// MARK: - Entity Base

/// Base game entity class
class GameEntity: Identifiable {
    let id: UUID
    var components: [String: Component] = [:]
    var transform: Transform
    var realityKitEntity: Entity?

    init(id: UUID = UUID()) {
        self.id = id
        self.transform = Transform()
    }

    /// Add a component to this entity
    func addComponent<T: Component>(_ component: T) {
        let key = String(describing: T.self)
        components[key] = component
        component.entity = self
    }

    /// Get a component from this entity
    func getComponent<T: Component>() -> T? {
        let key = String(describing: T.self)
        return components[key] as? T
    }

    /// Remove a component from this entity
    func removeComponent<T: Component>(_: T.Type) {
        let key = String(describing: T.self)
        components.removeValue(forKey: key)
    }

    /// Check if entity has a component
    func hasComponent<T: Component>(_: T.Type) -> Bool {
        let key = String(describing: T.self)
        return components[key] != nil
    }
}

// MARK: - Component Protocol

/// Base protocol for all components
protocol Component: AnyObject {
    var isActive: Bool { get set }
    weak var entity: GameEntity? { get set }

    func update(deltaTime: TimeInterval)
}

// Extension providing default implementation
extension Component {
    func update(deltaTime: TimeInterval) {
        // Default: no update needed
    }
}

// MARK: - Entity Manager

/// Manages all entities in the game
@MainActor
class EntityManager: ObservableObject {
    @Published private(set) var entities: [UUID: GameEntity] = [:]

    // Specialized entity collections for fast lookup
    private var playerEntities: [UUID] = []
    private var mobEntities: [UUID] = []
    private var itemEntities: [UUID] = []

    // Event bus for entity events
    private let eventBus: EventBus

    init(eventBus: EventBus) {
        self.eventBus = eventBus
    }

    // MARK: - Entity Management

    /// Create a new entity
    func createEntity() -> GameEntity {
        let entity = GameEntity()
        entities[entity.id] = entity
        return entity
    }

    /// Add an existing entity
    func addEntity(_ entity: GameEntity) {
        entities[entity.id] = entity

        // Categorize entity
        if entity.hasComponent(PlayerComponent.self) {
            playerEntities.append(entity.id)
        } else if entity.hasComponent(MobComponent.self) {
            mobEntities.append(entity.id)
        } else if entity.hasComponent(ItemDropComponent.self) {
            itemEntities.append(entity.id)
        }

        eventBus.publish(EntityCreatedEvent(entityId: entity.id))
    }

    /// Remove an entity
    func removeEntity(_ id: UUID) {
        guard let entity = entities[id] else { return }

        // Remove from specialized collections
        playerEntities.removeAll { $0 == id }
        mobEntities.removeAll { $0 == id }
        itemEntities.removeAll { $0 == id }

        // Remove RealityKit entity
        entity.realityKitEntity?.removeFromParent()

        entities.removeValue(forKey: id)
        eventBus.publish(EntityDestroyedEvent(entityId: id))
    }

    /// Get entity by ID
    func getEntity(_ id: UUID) -> GameEntity? {
        return entities[id]
    }

    /// Get all entities with a specific component type
    func getEntitiesWithComponent<T: Component>(_: T.Type) -> [GameEntity] {
        return entities.values.filter { $0.hasComponent(T.self) }
    }

    // MARK: - Update

    /// Update all entities
    func update(deltaTime: TimeInterval) {
        for entity in entities.values {
            updateEntity(entity, deltaTime: deltaTime)
        }
    }

    /// Update AI for entities
    func updateAI(deltaTime: TimeInterval) {
        for id in mobEntities {
            guard let entity = entities[id] else { continue }
            if let aiComponent = entity.getComponent(MobAIComponent.self)() {
                aiComponent.update(deltaTime: deltaTime)
            }
        }
    }

    private func updateEntity(_ entity: GameEntity, deltaTime: TimeInterval) {
        for (_, component) in entity.components {
            if component.isActive {
                component.update(deltaTime: deltaTime)
            }
        }
    }

    // MARK: - Queries

    /// Get the player entity
    func getPlayer() -> GameEntity? {
        guard let playerId = playerEntities.first else { return nil }
        return entities[playerId]
    }

    /// Get all mob entities
    func getMobs() -> [GameEntity] {
        return mobEntities.compactMap { entities[$0] }
    }

    /// Get all item entities
    func getItems() -> [GameEntity] {
        return itemEntities.compactMap { entities[$0] }
    }

    /// Find entities within radius of position
    func findEntitiesNear(position: SIMD3<Float>, radius: Float) -> [GameEntity] {
        return entities.values.filter { entity in
            let distance = simd_distance(entity.transform.translation, position)
            return distance <= radius
        }
    }

    // MARK: - Cleanup

    /// Remove all entities
    func removeAllEntities() {
        for id in Array(entities.keys) {
            removeEntity(id)
        }
    }
}

// MARK: - Entity Events

struct EntityCreatedEvent: GameEvent {
    let timestamp: Date = Date()
    let eventType: String = "EntityCreated"
    let entityId: UUID
}

struct EntityDestroyedEvent: GameEvent {
    let timestamp: Date = Date()
    let eventType: String = "EntityDestroyed"
    let entityId: UUID
}

// MARK: - Transform

/// Transform component for position, rotation, and scale
struct Transform {
    var translation: SIMD3<Float> = .zero
    var rotation: simd_quatf = simd_quatf(angle: 0, axis: SIMD3<Float>(0, 1, 0))
    var scale: SIMD3<Float> = SIMD3<Float>(1, 1, 1)

    var matrix: simd_float4x4 {
        var matrix = simd_float4x4(rotation)
        matrix.columns.3 = SIMD4<Float>(translation.x, translation.y, translation.z, 1)

        let scaleMatrix = simd_float4x4(
            SIMD4<Float>(scale.x, 0, 0, 0),
            SIMD4<Float>(0, scale.y, 0, 0),
            SIMD4<Float>(0, 0, scale.z, 0),
            SIMD4<Float>(0, 0, 0, 1)
        )

        return matrix * scaleMatrix
    }

    var forward: SIMD3<Float> {
        return rotation.act(SIMD3<Float>(0, 0, -1))
    }

    var up: SIMD3<Float> {
        return rotation.act(SIMD3<Float>(0, 1, 0))
    }

    var right: SIMD3<Float> {
        return rotation.act(SIMD3<Float>(1, 0, 0))
    }
}
