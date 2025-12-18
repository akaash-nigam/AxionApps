import Foundation
import simd

/// Combat system handling damage, health, and combat state
actor CombatSystem: GameSystem {

    let priority: Int = 10

    // Configuration
    private let healthRegenRate: Float = 5.0  // HP per second
    private let armorDamageReduction: Float = 0.5  // 50% reduction
    private let invulnerabilityDuration: TimeInterval = 0.5

    func update(deltaTime: TimeInterval, entities: EntityQuery) async {
        for (entityID, components) in entities.entities {
            guard var combat = components[String(describing: CombatComponent.self)] as? CombatComponent else {
                continue
            }

            // Health regeneration (if enabled)
            if combat.health < combat.maxHealth && combat.health > 0 {
                // Only regen if not recently damaged
                let timeSinceDamage = CACurrentMediaTime() - combat.lastDamageTime
                if timeSinceDamage > 5.0 {  // 5 second delay
                    combat.health = min(
                        combat.maxHealth,
                        combat.health + healthRegenRate * Float(deltaTime)
                    )
                }
            }

            // Update vulnerability state
            combat.isVulnerable = (CACurrentMediaTime() - combat.lastDamageTime) > invulnerabilityDuration

            // Update combat state based on health
            if combat.health <= 0 {
                combat.combatState = .dead
            } else if combat.healthPercentage < 0.25 {
                combat.combatState = .critical
            } else if combat.healthPercentage < 0.5 {
                combat.combatState = .injured
            } else {
                combat.combatState = .alive
            }

            // TODO: Update component in ECS manager
            // await ecsManager.updateComponent(combat, for: entityID)
        }
    }

    // MARK: - Damage Application

    func applyDamage(
        to entityID: UUID,
        amount: Float,
        type: DamageType,
        bodyPart: BodyPart,
        source: UUID,
        ecsManager: ECSManager
    ) async -> DamageResult {
        guard var combat = await ecsManager.getComponent(CombatComponent.self, for: entityID) else {
            return .noDamage
        }

        guard combat.isVulnerable else {
            return .invulnerable
        }

        // Calculate actual damage
        var actualDamage = amount

        // Apply body part multipliers
        actualDamage *= bodyPartMultiplier(for: bodyPart)

        // Apply armor reduction
        if combat.armor > 0 {
            let armorAbsorbed = min(actualDamage * armorDamageReduction, combat.armor)
            combat.armor -= armorAbsorbed
            actualDamage -= armorAbsorbed
        }

        // Apply damage to health
        combat.health -= actualDamage
        combat.lastDamageTime = CACurrentMediaTime()
        combat.lastDamageDealer = source

        // Update component
        await ecsManager.addComponent(combat, to: entityID)

        // Check for death
        if combat.health <= 0 {
            await handleDeath(entityID: entityID, killedBy: source, ecsManager: ecsManager)
            return .killed
        }

        return .damaged(amount: actualDamage)
    }

    private func bodyPartMultiplier(for bodyPart: BodyPart) -> Float {
        switch bodyPart {
        case .head:
            return 4.0  // 4x damage for headshot
        case .chest:
            return 1.0
        case .stomach:
            return 1.0
        case .arm:
            return 0.75
        case .leg:
            return 0.75
        }
    }

    private func handleDeath(entityID: UUID, killedBy: UUID, ecsManager: ECSManager) async {
        // TODO: Trigger death effects, ragdoll, etc.
        // TODO: Award kill to killer
        // TODO: Handle respawn logic
    }
}

enum DamageType: String, Codable {
    case bullet
    case explosion
    case melee
    case fall
    case environmental
}

enum BodyPart: String, Codable {
    case head
    case chest
    case stomach
    case arm
    case leg
}

enum DamageResult {
    case noDamage
    case invulnerable
    case damaged(amount: Float)
    case killed
}
