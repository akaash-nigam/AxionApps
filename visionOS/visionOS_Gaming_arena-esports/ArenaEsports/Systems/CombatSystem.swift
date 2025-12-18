import Foundation
import QuartzCore
import simd

/// Combat system for weapon handling and damage
public final class CombatSystem: BaseGameSystem {
    public init() {
        super.init(priority: 800)
    }

    public override func update(deltaTime: TimeInterval, entities: [GameEntity]) async {
        // Update combat states
        for entity in entities {
            guard var combat = entity.getComponent(CombatComponent.self) else {
                continue
            }

            // Reset combat state if no recent damage
            if combat.isInCombat {
                combat.isInCombat = false
                entity.removeComponent(CombatComponent.self)
                entity.addComponent(combat)
            }
        }
    }

    /// Apply damage to an entity
    public func applyDamage(
        to targetID: UUID,
        amount: Float,
        from attackerID: UUID?,
        at time: TimeInterval
    ) async -> Bool {
        guard let target = await EntityManager.shared.getEntity(targetID),
              var health = target.getComponent(HealthComponent.self) else {
            return false
        }

        // Get damage multiplier if entity has combat component
        var damageAmount = amount
        if let combat = target.getComponent(CombatComponent.self) {
            damageAmount *= combat.damageMultiplier

            // Update combat state
            var newCombat = combat
            newCombat.isInCombat = true
            newCombat.lastAttacker = attackerID
            target.removeComponent(CombatComponent.self)
            target.addComponent(newCombat)
        }

        // Apply damage
        health.takeDamage(damageAmount, at: time)
        target.removeComponent(HealthComponent.self)
        target.addComponent(health)

        return !health.isAlive
    }

    /// Perform a hitscan attack
    public func performHitscan(
        from origin: SIMD3<Float>,
        direction: SIMD3<Float>,
        maxDistance: Float,
        damage: Float,
        attackerID: UUID,
        entities: [GameEntity]
    ) async -> UUID? {
        var closestHit: (entity: GameEntity, distance: Float)?

        for entity in entities where entity.id != attackerID {
            guard let transform = entity.getComponent(TransformComponent.self),
                  entity.hasComponent(CollisionComponent.self) else {
                continue
            }

            // Simple ray-sphere intersection
            let toEntity = transform.position - origin
            let projection = simd_dot(toEntity, direction)

            guard projection > 0 && projection < maxDistance else {
                continue
            }

            let closestPoint = origin + direction * projection
            let distance = simd_distance(closestPoint, transform.position)

            if let collision = entity.getComponent(CollisionComponent.self) {
                if distance < collision.radius {
                    let hitDistance = projection
                    if closestHit == nil || hitDistance < closestHit!.distance {
                        closestHit = (entity, hitDistance)
                    }
                }
            }
        }

        if let hit = closestHit {
            let killed = await applyDamage(
                to: hit.entity.id,
                amount: damage,
                from: attackerID,
                at: CACurrentMediaTime()
            )
            return killed ? hit.entity.id : nil
        }

        return nil
    }
}
