//
//  CombatSystem.swift
//  Spatial Arena Championship
//
//  Combat, damage, and projectile system
//

import Foundation
import RealityKit
import simd

// MARK: - Combat System

@MainActor
class CombatSystem {
    private weak var scene: Scene?
    private var hitEvents: [(attacker: UUID, victim: UUID, damage: Float)] = []

    init(scene: Scene?) {
        self.scene = scene
    }

    // MARK: - Update

    func update(deltaTime: TimeInterval) {
        guard let scene = scene else { return }

        let currentTime = Date().timeIntervalSince1970

        // Update projectiles
        updateProjectiles(scene: scene, currentTime: currentTime, deltaTime: deltaTime)

        // Update shields
        updateShields(scene: scene, currentTime: currentTime)

        // Regenerate health and shields
        regeneratePlayers(scene: scene, deltaTime: deltaTime)

        // Process hit events
        processHitEvents()
    }

    // MARK: - Projectile Management

    private func updateProjectiles(scene: Scene, currentTime: TimeInterval, deltaTime: TimeInterval) {
        for entity in scene.entities {
            updateProjectileEntity(entity, currentTime: currentTime, deltaTime: deltaTime)
        }
    }

    private func updateProjectileEntity(_ entity: Entity, currentTime: TimeInterval, deltaTime: TimeInterval) {
        guard let projectile = entity.components[ProjectileComponent.self] else {
            // Recursively check children
            for child in entity.children {
                updateProjectileEntity(child, currentTime: currentTime, deltaTime: deltaTime)
            }
            return
        }

        // Check expiration
        if projectile.isExpired(at: currentTime) {
            entity.removeFromParent()
            return
        }

        // Check collisions with players
        checkProjectileCollisions(entity, projectile: projectile)

        // Continue with children
        for child in entity.children {
            updateProjectileEntity(child, currentTime: currentTime, deltaTime: deltaTime)
        }
    }

    private func checkProjectileCollisions(_ projectileEntity: Entity, projectile: ProjectileComponent) {
        guard let scene = scene else { return }

        let projectilePos = projectileEntity.position

        // Check against all players
        for entity in scene.entities {
            checkPlayerCollision(entity, projectileEntity: projectileEntity, projectile: projectile, projectilePos: projectilePos)
        }
    }

    private func checkPlayerCollision(
        _ entity: Entity,
        projectileEntity: Entity,
        projectile: ProjectileComponent,
        projectilePos: SIMD3<Float>
    ) {
        guard let player = entity.components[PlayerComponent.self],
              !projectile.hasHit(player.playerID),
              player.team != projectile.team else {
            // Check children
            for child in entity.children {
                checkPlayerCollision(child, projectileEntity: projectileEntity, projectile: projectile, projectilePos: projectilePos)
            }
            return
        }

        let playerPos = entity.position
        let distance = simd_distance(projectilePos, playerPos)

        // Simple sphere collision (radius = 0.5 for player)
        if distance < (0.5 + GameConstants.Abilities.PrimaryFire.projectileRadius) {
            // Hit!
            applyDamage(
                to: entity,
                amount: projectile.damage,
                from: projectile.ownerID,
                at: projectilePos
            )

            // Mark hit
            var mutableProjectile = projectile
            mutableProjectile.markHit(player.playerID)
            projectileEntity.components[ProjectileComponent.self] = mutableProjectile

            // Remove projectile
            projectileEntity.removeFromParent()
        }

        // Check children
        for child in entity.children {
            checkPlayerCollision(child, projectileEntity: projectileEntity, projectile: projectile, projectilePos: projectilePos)
        }
    }

    // MARK: - Damage Application

    func applyDamage(
        to entity: Entity,
        amount: Float,
        from source: UUID,
        at position: SIMD3<Float>
    ) {
        guard var health = entity.components[HealthComponent.self] else { return }

        let currentTime = Date().timeIntervalSince1970

        // Check for headshot (position near top of player)
        var finalDamage = amount
        let playerTop = entity.position + SIMD3<Float>(0, 1.7, 0)
        if simd_distance(position, playerTop) < 0.15 {
            finalDamage *= GameConstants.Combat.headshotMultiplier
            // TODO: Trigger headshot event
        }

        // Apply damage
        health.takeDamage(finalDamage, from: source, at: currentTime)
        entity.components[HealthComponent.self] = health

        // Check for death
        if !health.isAlive {
            handlePlayerDeath(entity, killedBy: source)
        }

        // Record hit event
        if let player = entity.components[PlayerComponent.self] {
            hitEvents.append((attacker: source, victim: player.playerID, damage: finalDamage))
        }
    }

    private func handlePlayerDeath(_ entity: Entity, killedBy killer: UUID) {
        guard var player = entity.components[PlayerComponent.self] else { return }

        // Update stats
        player.deaths += 1
        entity.components[PlayerComponent.self] = player

        // Update killer stats
        if let killerEntity = findPlayerEntity(killer) {
            var killerPlayer = killerEntity.components[PlayerComponent.self]!
            killerPlayer.kills += 1
            killerEntity.components[PlayerComponent.self] = killerPlayer
        }

        // TODO: Trigger death event
        // TODO: Schedule respawn
    }

    // MARK: - Shield Management

    private func updateShields(scene: Scene, currentTime: TimeInterval) {
        for entity in scene.entities {
            updateShieldEntity(entity, currentTime: currentTime)
        }
    }

    private func updateShieldEntity(_ entity: Entity, currentTime: TimeInterval) {
        guard let shield = entity.components[ShieldComponent.self] else {
            for child in entity.children {
                updateShieldEntity(child, currentTime: currentTime)
            }
            return
        }

        // Check expiration
        if shield.isExpired(at: currentTime) {
            entity.removeFromParent()
            return
        }

        for child in entity.children {
            updateShieldEntity(child, currentTime: currentTime)
        }
    }

    // MARK: - Regeneration

    private func regeneratePlayers(scene: Scene, deltaTime: TimeInterval) {
        for entity in scene.entities {
            regeneratePlayerEntity(entity, deltaTime: deltaTime)
        }
    }

    private func regeneratePlayerEntity(_ entity: Entity, deltaTime: TimeInterval) {
        guard entity.components[PlayerComponent.self] != nil,
              var health = entity.components[HealthComponent.self] else {
            for child in entity.children {
                regeneratePlayerEntity(child, deltaTime: deltaTime)
            }
            return
        }

        // Regenerate shields
        health.regenerateShields(deltaTime: deltaTime)

        // Regenerate health
        health.regenerateHealth(deltaTime: deltaTime)

        entity.components[HealthComponent.self] = health

        for child in entity.children {
            regeneratePlayerEntity(child, deltaTime: deltaTime)
        }
    }

    // MARK: - Ability Activation

    func fireProjectile(
        from entity: Entity,
        direction: SIMD3<Float>,
        ability: Ability
    ) -> Entity? {
        guard let player = entity.components[PlayerComponent.self],
              let config = ability.projectileConfig,
              var energy = entity.components[EnergyComponent.self],
              energy.use(ability.energyCost) else {
            return nil
        }

        // Update energy
        entity.components[EnergyComponent.self] = energy

        // Create projectile
        let spawnOffset = direction * 0.6 // Spawn in front of player
        let spawnPosition = entity.position + SIMD3<Float>(0, 1.5, 0) + spawnOffset

        let projectile = EntityFactory.createProjectile(
            owner: player.playerID,
            position: spawnPosition,
            direction: direction,
            team: player.team,
            config: config
        )

        // Add to scene
        scene?.addAnchor(AnchorEntity(world: .zero))
        scene?.anchors.first?.addChild(projectile)

        // Update stats
        var mutablePlayer = player
        mutablePlayer.damageDealt += 0 // Will be updated on hit
        entity.components[PlayerComponent.self] = mutablePlayer

        return projectile
    }

    func deployShield(
        from entity: Entity,
        forward: SIMD3<Float>,
        ability: Ability
    ) -> Entity? {
        guard let player = entity.components[PlayerComponent.self],
              let config = ability.shieldConfig,
              var energy = entity.components[EnergyComponent.self],
              energy.use(ability.energyCost) else {
            return nil
        }

        // Update energy
        entity.components[EnergyComponent.self] = energy

        // Create shield
        let spawnPosition = entity.position + forward * 1.0
        let orientation = simd_quatf(from: [0, 0, 1], to: forward)

        let shield = EntityFactory.createShield(
            owner: player.playerID,
            position: spawnPosition,
            orientation: orientation,
            team: player.team,
            config: config
        )

        // Add to scene
        scene?.anchors.first?.addChild(shield)

        return shield
    }

    // MARK: - Utilities

    private func findPlayerEntity(_ playerID: UUID) -> Entity? {
        guard let scene = scene else { return nil }
        return findPlayerInEntities(playerID, entities: scene.entities)
    }

    private func findPlayerInEntities(_ playerID: UUID, entities: [Entity]) -> Entity? {
        for entity in entities {
            if let player = entity.components[PlayerComponent.self],
               player.playerID == playerID {
                return entity
            }

            if let found = findPlayerInEntities(playerID, entities: entity.children) {
                return found
            }
        }
        return nil
    }

    private func processHitEvents() {
        // Process accumulated hit events
        // TODO: Send to network, update UI, trigger audio/visual effects
        hitEvents.removeAll()
    }
}
