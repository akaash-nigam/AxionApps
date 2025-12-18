import Foundation

/// Manages all entities in the game world
/// Singleton actor for thread-safe entity management
public actor EntityManager {
    public static let shared = EntityManager()

    private var entities: [UUID: GameEntity] = [:]
    private var componentIndex: [ObjectIdentifier: Set<UUID>] = [:]

    private init() {}

    // MARK: - Entity Management

    /// Create a new entity
    public func createEntity(isActive: Bool = true) -> GameEntity {
        let entity = GameEntity(isActive: isActive)
        entities[entity.id] = entity
        return entity
    }

    /// Add an existing entity to the manager
    public func addEntity(_ entity: GameEntity) {
        entities[entity.id] = entity

        // Update component index
        for component in entity.components {
            let typeID = ObjectIdentifier(type(of: component))
            componentIndex[typeID, default: []].insert(entity.id)
        }
    }

    /// Remove an entity
    public func removeEntity(_ entityID: UUID) {
        guard let entity = entities[entityID] else { return }

        // Remove from component index
        for component in entity.components {
            let typeID = ObjectIdentifier(type(of: component))
            componentIndex[typeID]?.remove(entityID)
        }

        entities.removeValue(forKey: entityID)
    }

    /// Get an entity by ID
    public func getEntity(_ entityID: UUID) -> GameEntity? {
        return entities[entityID]
    }

    /// Get all active entities
    public var activeEntities: [GameEntity] {
        return entities.values.filter { $0.isActive }
    }

    /// Get all entities (active and inactive)
    public var allEntities: [GameEntity] {
        return Array(entities.values)
    }

    /// Clear all entities
    public func clear() {
        entities.removeAll()
        componentIndex.removeAll()
    }

    // MARK: - Component Queries

    /// Query entities that have a specific component type
    public func entitiesWithComponent<T: Component>(_ type: T.Type) -> [GameEntity] {
        return activeEntities.filter { $0.hasComponent(type) }
    }

    /// Query entities that have multiple component types
    public func entitiesWithComponents(_ types: [any Component.Type]) -> [GameEntity] {
        return activeEntities.filter { entity in
            types.allSatisfy { componentType in
                entity.components.contains { component in
                    type(of: component) == componentType
                }
            }
        }
    }

    // MARK: - Statistics

    /// Get the total number of entities
    public var entityCount: Int {
        return entities.count
    }

    /// Get the number of active entities
    public var activeEntityCount: Int {
        return activeEntities.count
    }
}
