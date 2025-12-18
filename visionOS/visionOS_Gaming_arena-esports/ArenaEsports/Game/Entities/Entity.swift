import Foundation

/// Base protocol for all entities in the game
/// Entities are unique identifiers with attached components
public protocol Entity: Identifiable, Sendable {
    /// Unique identifier for this entity
    var id: UUID { get }

    /// All components attached to this entity
    var components: [AnyComponent] { get set }

    /// Whether this entity is active in the game world
    var isActive: Bool { get set }
}

/// Default entity implementation
public final class GameEntity: Entity, @unchecked Sendable {
    public let id: UUID
    public var components: [AnyComponent]
    public var isActive: Bool

    public init(id: UUID = UUID(), isActive: Bool = true) {
        self.id = id
        self.components = []
        self.isActive = isActive
    }

    /// Add a component to this entity
    public func addComponent(_ component: any Component) {
        components.append(AnyComponent(component))
    }

    /// Get a component of a specific type
    public func getComponent<T: Component>(_ type: T.Type) -> T? {
        return components.first(where: { $0.as(type) != nil })?.as(type)
    }

    /// Remove a component of a specific type
    public func removeComponent<T: Component>(_ type: T.Type) {
        components.removeAll(where: { $0.as(type) != nil })
    }

    /// Check if entity has a component of a specific type
    public func hasComponent<T: Component>(_ type: T.Type) -> Bool {
        return getComponent(type) != nil
    }
}
