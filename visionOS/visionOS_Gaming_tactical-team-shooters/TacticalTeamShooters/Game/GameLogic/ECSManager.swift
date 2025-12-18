import Foundation

/// Entity-Component-System manager
/// Manages all game entities, components, and systems
actor ECSManager {

    // MARK: - Storage

    private var entities: [UUID: Entity] = [:]
    private var components: [String: [UUID: any Component]] = [:]
    private var systems: [any GameSystem] = []
    private var activeEntities: Set<UUID> = []

    // MARK: - Entity Management

    func createEntity(tags: Set<EntityTag> = []) -> Entity {
        let entity = Entity(tags: tags)
        entities[entity.id] = entity
        activeEntities.insert(entity.id)
        return entity
    }

    func destroyEntity(_ entityID: UUID) {
        entities.removeValue(forKey: entityID)
        activeEntities.remove(entityID)

        // Remove all components for this entity
        for componentType in components.keys {
            components[componentType]?[entityID] = nil
        }
    }

    func getEntity(_ id: UUID) -> Entity? {
        return entities[id]
    }

    func clearAllEntities() {
        entities.removeAll()
        components.removeAll()
        activeEntities.removeAll()
    }

    // MARK: - Component Management

    func addComponent<T: Component>(_ component: T, to entityID: UUID) {
        let componentType = String(describing: T.self)

        if components[componentType] == nil {
            components[componentType] = [:]
        }

        components[componentType]?[entityID] = component
    }

    func getComponent<T: Component>(_ type: T.Type, for entityID: UUID) -> T? {
        let componentType = String(describing: type)
        return components[componentType]?[entityID] as? T
    }

    func removeComponent<T: Component>(_ type: T.Type, from entityID: UUID) {
        let componentType = String(describing: type)
        components[componentType]?[entityID] = nil
    }

    func hasComponent<T: Component>(_ type: T.Type, entityID: UUID) -> Bool {
        let componentType = String(describing: type)
        return components[componentType]?[entityID] != nil
    }

    // MARK: - System Management

    func registerSystem<T: GameSystem>(_ system: T) {
        systems.append(system)
        systems.sort { $0.priority < $1.priority }
    }

    func update(deltaTime: TimeInterval) async {
        for system in systems {
            let query = await createQuery(for: system)
            await system.update(deltaTime: deltaTime, entities: query)
        }
    }

    // MARK: - Queries

    private func createQuery(for system: any GameSystem) async -> EntityQuery {
        // This would be implemented with actual query logic
        // For now, return all active entities
        var result: [UUID: [String: any Component]] = [:]

        for entityID in activeEntities {
            var entityComponents: [String: any Component] = [:]

            for (componentType, componentDict) in components {
                if let component = componentDict[entityID] {
                    entityComponents[componentType] = component
                }
            }

            if !entityComponents.isEmpty {
                result[entityID] = entityComponents
            }
        }

        return EntityQuery(entities: result)
    }

    func query(withComponents types: [any Component.Type], tags: Set<EntityTag> = []) async -> EntityQuery {
        var result: [UUID: [String: any Component]] = [:]

        for entityID in activeEntities {
            // Check if entity has all required components
            var hasAllComponents = true
            var entityComponents: [String: any Component] = [:]

            for type in types {
                let componentType = String(describing: type)
                if let component = components[componentType]?[entityID] {
                    entityComponents[componentType] = component
                } else {
                    hasAllComponents = false
                    break
                }
            }

            // Check tags
            if let entity = entities[entityID] {
                if !tags.isEmpty && !tags.isSubset(of: entity.tags) {
                    hasAllComponents = false
                }
            }

            if hasAllComponents {
                result[entityID] = entityComponents
            }
        }

        return EntityQuery(entities: result)
    }

    // MARK: - Statistics

    var entityCount: Int {
        return activeEntities.count
    }

    var componentCount: Int {
        return components.values.reduce(0) { $0 + $1.count }
    }
}

/// Represents a game entity (just an ID with metadata)
struct Entity: Identifiable, Hashable {
    let id: UUID
    var isActive: Bool
    var tags: Set<EntityTag>

    init(id: UUID = UUID(), isActive: Bool = true, tags: Set<EntityTag> = []) {
        self.id = id
        self.isActive = isActive
        self.tags = tags
    }
}

/// Entity tags for categorization
enum EntityTag: String, Hashable {
    case player
    case enemy
    case projectile
    case weapon
    case equipment
    case environment
    case cover
    case spawnPoint
    case objective
}

/// Base protocol for all components
protocol Component: Codable {
    var entityID: UUID { get set }
}

/// Protocol for game systems
protocol GameSystem: Actor {
    var priority: Int { get }
    func update(deltaTime: TimeInterval, entities: EntityQuery) async
}

/// Query result containing entities and their components
struct EntityQuery {
    let entities: [UUID: [String: any Component]]

    var count: Int {
        return entities.count
    }

    func forEach(_ closure: (UUID, [String: any Component]) -> Void) {
        for (id, components) in entities {
            closure(id, components)
        }
    }
}
