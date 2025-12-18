//
//  SystemManager.swift
//  HolographicBoardGames
//
//  Manages all game systems and their update order
//

import Foundation

final class SystemManager {
    private var systems: [System] = []
    private let entityManager: EntityManager

    init(entityManager: EntityManager) {
        self.entityManager = entityManager
    }

    // MARK: - System Management

    /// Add a system
    func addSystem(_ system: System) {
        systems.append(system)
        systems.sort { $0.priority > $1.priority }
        system.initialize()
    }

    /// Remove a system
    func removeSystem(_ system: System) {
        system.shutdown()
        systems.removeAll { ObjectIdentifier($0) == ObjectIdentifier(system) }
    }

    /// Get a system of the specified type
    func getSystem<T: System>(ofType type: T.Type) -> T? {
        systems.first { $0 is T } as? T
    }

    // MARK: - Update

    /// Update all active systems
    func update(deltaTime: TimeInterval) {
        let entities = entityManager.getAllEntities()

        for system in systems where system.isActive {
            system.update(entities: entities, deltaTime: deltaTime)
        }

        // Process any pending entity changes
        entityManager.processPendingChanges()
    }

    /// Shutdown all systems
    func shutdown() {
        for system in systems {
            system.shutdown()
        }
        systems.removeAll()
    }
}
