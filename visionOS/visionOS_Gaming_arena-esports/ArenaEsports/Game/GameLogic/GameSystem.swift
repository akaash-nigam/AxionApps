import Foundation

/// Protocol for all game systems in the ECS architecture
/// Systems contain logic that operates on entities with specific components
public protocol GameSystem: Sendable {
    /// Priority determines system execution order (higher priority runs first)
    var priority: Int { get }

    /// Update system logic for this frame
    /// - Parameters:
    ///   - deltaTime: Time since last update
    ///   - entities: All entities to process
    func update(deltaTime: TimeInterval, entities: [GameEntity]) async
}

/// Base implementation of GameSystem
open class BaseGameSystem: GameSystem, @unchecked Sendable {
    public let priority: Int

    public init(priority: Int) {
        self.priority = priority
    }

    open func update(deltaTime: TimeInterval, entities: [GameEntity]) async {
        // Override in subclasses
    }
}
