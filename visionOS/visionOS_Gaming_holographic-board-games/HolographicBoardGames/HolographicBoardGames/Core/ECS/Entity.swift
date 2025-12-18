//
//  Entity.swift
//  HolographicBoardGames
//
//  Entity-Component-System: Entity definition
//

import Foundation

/// An Entity is a unique identifier with attached components
final class Entity: Identifiable, Hashable {
    let id: UUID
    private(set) var components: [ObjectIdentifier: Component] = [:]
    weak var manager: EntityManager?

    init(id: UUID = UUID()) {
        self.id = id
    }

    // MARK: - Component Management

    /// Add a component to this entity
    @discardableResult
    func addComponent<T: Component>(_ component: T) -> Entity {
        let key = ObjectIdentifier(T.self)
        component.entity = self
        components[key] = component
        component.onAdded()
        return self
    }

    /// Get a component of the specified type
    func component<T: Component>(ofType type: T.Type) -> T? {
        let key = ObjectIdentifier(type)
        return components[key] as? T
    }

    /// Remove a component of the specified type
    func removeComponent<T: Component>(ofType type: T.Type) {
        let key = ObjectIdentifier(type)
        if let component = components[key] {
            component.onRemoved()
            component.entity = nil
        }
        components.removeValue(forKey: key)
    }

    /// Check if entity has a component of the specified type
    func hasComponent<T: Component>(ofType type: T.Type) -> Bool {
        let key = ObjectIdentifier(type)
        return components[key] != nil
    }

    /// Get all components
    func allComponents() -> [Component] {
        Array(components.values)
    }

    // MARK: - Hashable

    static func == (lhs: Entity, rhs: Entity) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    // MARK: - Lifecycle

    func destroy() {
        manager?.removeEntity(self)
    }
}

// MARK: - Entity Extensions

extension Entity: CustomStringConvertible {
    var description: String {
        "Entity(id: \(id), components: \(components.count))"
    }
}
