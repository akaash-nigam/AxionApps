import Foundation

/// Movement system handling player and entity movement
actor MovementSystem: GameSystem {
    let priority: Int = 15

    func update(deltaTime: TimeInterval, entities: EntityQuery) async {
        // TODO: Update entity positions based on velocity
        // TODO: Apply gravity
        // TODO: Handle stamina depletion
    }
}
