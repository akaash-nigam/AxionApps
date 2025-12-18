import Foundation
import simd

/// Physics system for movement and collision
public final class PhysicsSystem: BaseGameSystem {
    private let gravity: SIMD3<Float> = SIMD3(0, -9.81, 0)

    public init() {
        super.init(priority: 900)
    }

    public override func update(deltaTime: TimeInterval, entities: [GameEntity]) async {
        let dt = Float(deltaTime)

        for entity in entities {
            guard var physics = entity.getComponent(PhysicsComponent.self),
                  var transform = entity.getComponent(TransformComponent.self) else {
                continue
            }

            // Apply gravity
            if physics.hasGravity {
                physics.acceleration += gravity
            }

            // Update velocity
            physics.velocity += physics.acceleration * dt

            // Apply friction
            physics.velocity *= (1.0 - physics.friction * dt)

            // Update position
            transform.position += physics.velocity * dt

            // Reset acceleration
            physics.acceleration = .zero

            // Update entity components
            entity.removeComponent(PhysicsComponent.self)
            entity.addComponent(physics)
            entity.removeComponent(TransformComponent.self)
            entity.addComponent(transform)
        }

        // Check collisions
        await detectCollisions(entities: entities)
    }

    private func detectCollisions(entities: [GameEntity]) async {
        let collidableEntities = entities.filter { $0.hasComponent(CollisionComponent.self) }

        for i in 0..<collidableEntities.count {
            for j in (i+1)..<collidableEntities.count {
                let entity1 = collidableEntities[i]
                let entity2 = collidableEntities[j]

                guard let transform1 = entity1.getComponent(TransformComponent.self),
                      let transform2 = entity2.getComponent(TransformComponent.self),
                      let collision1 = entity1.getComponent(CollisionComponent.self),
                      let collision2 = entity2.getComponent(CollisionComponent.self) else {
                    continue
                }

                // Check collision layers
                guard (collision1.collisionLayer & collision2.collidesWith) != 0 else {
                    continue
                }

                // Calculate distance
                let distance = simd_distance(transform1.position, transform2.position)
                let minDistance = collision1.radius + collision2.radius

                // Check if colliding
                if distance < minDistance {
                    // Simple separation response
                    let separation = minDistance - distance
                    let direction = normalize(transform2.position - transform1.position)

                    var newTransform1 = transform1
                    var newTransform2 = transform2

                    newTransform1.position -= direction * (separation / 2)
                    newTransform2.position += direction * (separation / 2)

                    entity1.removeComponent(TransformComponent.self)
                    entity1.addComponent(newTransform1)
                    entity2.removeComponent(TransformComponent.self)
                    entity2.addComponent(newTransform2)
                }
            }
        }
    }
}
