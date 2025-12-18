//
//  CombatSimulationService.swift
//  MilitaryDefenseTraining
//
//  Created by Claude Code
//

import Foundation
import RealityKit
import simd

actor CombatSimulationService {
    private var activeEntities: [UUID: CombatEntity] = [:]
    private var combatEvents: [CombatEvent] = []

    init() {}

    // MARK: - Entity Management

    func registerEntity(_ entity: CombatEntity) {
        activeEntities[entity.id] = entity
    }

    func unregisterEntity(_ entityID: UUID) {
        activeEntities.removeValue(forKey: entityID)
    }

    func getEntity(_ id: UUID) -> CombatEntity? {
        return activeEntities[id]
    }

    // MARK: - Weapon Fire

    func processWeaponFire(
        from shooter: CombatEntity,
        direction: SIMD3<Float>,
        spread: Float = 0.02
    ) async -> FireResult {
        guard var weapon = shooter.currentWeapon else {
            return .noAmmo
        }

        // Check if can fire
        guard weapon.fire() else {
            return .noAmmo
        }

        // Update shooter's weapon
        shooter.currentWeapon = weapon

        // Apply weapon spread
        let spreadDirection = applySpread(direction, spread: spread * weapon.recoilPattern.recoilMultiplier)

        // Raycast to find hit
        let ray = Ray(origin: shooter.position, direction: spreadDirection)
        let hitResult = await performRaycast(ray: ray, maxDistance: weapon.effectiveRange)

        guard let hit = hitResult else {
            return .miss
        }

        // Check if hit an entity
        if let targetEntity = activeEntities[hit.entityID] {
            let distance = simd_distance(shooter.position, targetEntity.position)
            let isHeadshot = checkHeadshot(hit.hitPoint, targetEntity: targetEntity)

            // Calculate damage
            let damage = weapon.damage.calculateDamage(
                distance: distance,
                isHeadshot: isHeadshot,
                armorValue: targetEntity.armor.damageReduction
            )

            // Apply damage
            targetEntity.takeDamage(damage)

            // Record event
            let event = CombatEvent(
                type: .hit,
                timestamp: Date(),
                attackerID: shooter.id,
                targetID: targetEntity.id,
                damage: damage,
                isHeadshot: isHeadshot
            )
            combatEvents.append(event)

            return .hit(target: targetEntity, damage: damage, isHeadshot: isHeadshot)
        }

        return .environmentHit(position: hit.hitPoint)
    }

    // MARK: - Ballistics

    private func applySpread(_ direction: SIMD3<Float>, spread: Float) -> SIMD3<Float> {
        let randomX = Float.random(in: -spread...spread)
        let randomY = Float.random(in: -spread...spread)

        let spreadVector = SIMD3<Float>(randomX, randomY, 0)
        return simd_normalize(direction + spreadVector)
    }

    private func performRaycast(
        ray: Ray,
        maxDistance: Float
    ) async -> RaycastHit? {
        // In real implementation, this would use RealityKit's raycasting
        // For now, simplified simulation
        for (_, entity) in activeEntities {
            let distance = simd_distance(ray.origin, entity.position)
            if distance <= maxDistance {
                // Simple sphere collision check
                let toEntity = entity.position - ray.origin
                let projection = simd_dot(toEntity, ray.direction)

                if projection > 0 && projection < maxDistance {
                    let closestPoint = ray.origin + ray.direction * projection
                    let distanceToRay = simd_length(entity.position - closestPoint)

                    if distanceToRay < 0.5 { // Hit radius
                        return RaycastHit(
                            entityID: entity.id,
                            hitPoint: closestPoint,
                            distance: projection
                        )
                    }
                }
            }
        }

        return nil
    }

    private func checkHeadshot(_ hitPoint: SIMD3<Float>, targetEntity: CombatEntity) -> Bool {
        // Check if hit point is in head region (top 20% of entity)
        let headHeight = targetEntity.position.y + 1.6 // Approximate head height
        return hitPoint.y >= headHeight
    }

    // MARK: - Damage Calculation

    func calculateDamage(_ hit: HitEvent) async -> Float {
        let weapon = hit.weapon
        let distance = hit.distance
        let target = hit.target

        return weapon.damage.calculateDamage(
            distance: distance,
            isHeadshot: hit.isHeadshot,
            armorValue: target.armor.damageReduction
        )
    }

    // MARK: - Cover System

    func processCover(
        entity: CombatEntity,
        threatDirection: SIMD3<Float>
    ) async -> CoverEffectiveness {
        // Simplified cover calculation
        // In real implementation, would check actual geometry

        let entityForward = SIMD3<Float>(0, 0, -1) // Simplified
        let dot = simd_dot(simd_normalize(threatDirection), entityForward)

        if dot < -0.7 {
            return .full // Behind cover
        } else if dot < -0.3 {
            return .partial // Partial cover
        } else {
            return .none // Exposed
        }
    }

    // MARK: - Combat Events

    func getCombatEvents() async -> [CombatEvent] {
        return combatEvents
    }

    func clearEvents() async {
        combatEvents.removeAll()
    }

    // MARK: - Update

    func updateEntityStates(deltaTime: TimeInterval) async {
        // Update all active entities
        for (_, entity) in activeEntities {
            // Update entity state, animations, etc.
            // This would be called every frame
        }
    }
}

// MARK: - Supporting Types

struct Ray {
    var origin: SIMD3<Float>
    var direction: SIMD3<Float>
}

struct RaycastHit {
    var entityID: UUID
    var hitPoint: SIMD3<Float>
    var distance: Float
}

enum FireResult {
    case hit(target: CombatEntity, damage: Float, isHeadshot: Bool)
    case miss
    case environmentHit(position: SIMD3<Float>)
    case noAmmo
}

enum CoverEffectiveness {
    case none
    case partial
    case full

    var damageMultiplier: Float {
        switch self {
        case .none: return 1.0
        case .partial: return 0.5
        case .full: return 0.1
        }
    }
}

struct CombatEvent {
    var type: EventType
    var timestamp: Date
    var attackerID: UUID
    var targetID: UUID?
    var damage: Float
    var isHeadshot: Bool

    enum EventType {
        case hit
        case kill
        case miss
        case reload
        case weaponSwitch
    }
}
