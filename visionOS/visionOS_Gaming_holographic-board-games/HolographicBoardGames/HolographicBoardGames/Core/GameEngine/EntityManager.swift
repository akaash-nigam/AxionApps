//
//  EntityManager.swift
//  HolographicBoardGames
//
//  Manages all entities in the game
//

import Foundation

final class EntityManager {
    private(set) var entities: Set<Entity> = []
    private var entitiesToAdd: Set<Entity> = []
    private var entitiesToRemove: Set<Entity> = []

    // MARK: - Entity Management

    /// Create a new entity
    @discardableResult
    func createEntity() -> Entity {
        let entity = Entity()
        entity.manager = self
        entitiesToAdd.insert(entity)
        return entity
    }

    /// Add an existing entity
    func addEntity(_ entity: Entity) {
        entity.manager = self
        entitiesToAdd.insert(entity)
    }

    /// Remove an entity
    func removeEntity(_ entity: Entity) {
        entitiesToRemove.insert(entity)
    }

    /// Get all entities
    func getAllEntities() -> [Entity] {
        Array(entities)
    }

    /// Get entities with a specific component
    func getEntities<T: Component>(with componentType: T.Type) -> [Entity] {
        entities.filter { $0.hasComponent(ofType: componentType) }
    }

    /// Get entities with multiple components
    func getEntities<T1: Component, T2: Component>(
        with type1: T1.Type,
        and type2: T2.Type
    ) -> [Entity] {
        entities.filter {
            $0.hasComponent(ofType: type1) && $0.hasComponent(ofType: type2)
        }
    }

    /// Find entity by ID
    func findEntity(by id: UUID) -> Entity? {
        entities.first { $0.id == id }
    }

    /// Remove all entities
    func removeAllEntities() {
        entitiesToRemove = entities
    }

    // MARK: - Update

    /// Process pending additions and removals
    func processPendingChanges() {
        // Remove entities
        for entity in entitiesToRemove {
            entities.remove(entity)
            entity.manager = nil
        }
        entitiesToRemove.removeAll()

        // Add entities
        for entity in entitiesToAdd {
            entities.insert(entity)
        }
        entitiesToAdd.removeAll()
    }
}
