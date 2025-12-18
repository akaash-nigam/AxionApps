import Foundation

/// Projectile system managing bullet physics and collision
actor ProjectileSystem: GameSystem {
    let priority: Int = 30

    func update(deltaTime: TimeInterval, entities: EntityQuery) async {
        // TODO: Update projectile positions
        // TODO: Apply ballistics physics
        // TODO: Check for collisions
    }
}
