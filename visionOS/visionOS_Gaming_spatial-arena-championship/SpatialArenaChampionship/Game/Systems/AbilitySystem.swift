//
//  AbilitySystem.swift
//  Spatial Arena Championship
//
//  Complete ability management system
//

import Foundation
import RealityKit
import simd

// MARK: - Ability System

@MainActor
class AbilitySystem {
    private weak var scene: Scene?
    private var combatSystem: CombatSystem?
    private var movementSystem: MovementSystem?

    // Ability states per player
    private var abilityStates: [UUID: PlayerAbilityStates] = [:]

    init(scene: Scene?, combatSystem: CombatSystem?, movementSystem: MovementSystem?) {
        self.scene = scene
        self.combatSystem = combatSystem
        self.movementSystem = movementSystem
    }

    // MARK: - Update

    func update(deltaTime: TimeInterval) {
        let currentTime = Date().timeIntervalSince1970

        // Update all ability cooldowns
        for (playerID, var states) in abilityStates {
            states.update(deltaTime: deltaTime)
            abilityStates[playerID] = states
        }

        // Update active ability durations
        updateActiveAbilities(currentTime: currentTime)
    }

    // MARK: - Ability Activation

    func activatePrimary(for entity: Entity, direction: SIMD3<Float>) -> Bool {
        guard let player = entity.components[PlayerComponent.self],
              var energy = entity.components[EnergyComponent.self] else {
            return false
        }

        let ability = Ability.primaryFire

        // Check energy
        guard energy.use(ability.energyCost) else { return false }
        entity.components[EnergyComponent.self] = energy

        // Fire projectile
        combatSystem?.fireProjectile(from: entity, direction: direction, ability: ability)

        return true
    }

    func activateSecondary(for entity: Entity, direction: SIMD3<Float>) -> Bool {
        guard let player = entity.components[PlayerComponent.self],
              var energy = entity.components[EnergyComponent.self],
              var states = abilityStates[player.playerID] else {
            return false
        }

        let ability = Ability.shieldWall

        // Check if ready
        guard states.secondary.isReady else { return false }

        // Check energy
        guard energy.use(ability.energyCost) else { return false }
        entity.components[EnergyComponent.self] = energy

        // Activate ability
        states.secondary.activate(at: Date().timeIntervalSince1970)
        abilityStates[player.playerID] = states

        // Deploy shield
        combatSystem?.deployShield(from: entity, forward: direction, ability: ability)

        return true
    }

    func activateTactical(for entity: Entity, direction: SIMD3<Float>) -> Bool {
        guard let player = entity.components[PlayerComponent.self],
              var energy = entity.components[EnergyComponent.self],
              var states = abilityStates[player.playerID] else {
            return false
        }

        let ability = Ability.dash

        // Check if ready
        guard states.tactical.isReady else { return false }

        // Check energy
        guard energy.use(ability.energyCost) else { return false }
        entity.components[EnergyComponent.self] = energy

        // Activate ability
        states.tactical.activate(at: Date().timeIntervalSince1970)
        abilityStates[player.playerID] = states

        // Execute dash
        movementSystem?.dash(entity, direction: direction)

        return true
    }

    func activateUltimate(for entity: Entity) -> Bool {
        guard let player = entity.components[PlayerComponent.self],
              var states = abilityStates[player.playerID] else {
            return false
        }

        // Check ultimate charge
        guard player.ultimateCharge >= GameConstants.Abilities.Ultimate.chargeRequired else {
            return false
        }

        // Consume charge
        var mutablePlayer = player
        mutablePlayer.ultimateCharge = 0
        entity.components[PlayerComponent.self] = mutablePlayer

        // Activate ability
        states.ultimate.activate(at: Date().timeIntervalSince1970)
        abilityStates[player.playerID] = states

        // Execute ultimate (Nova Blast)
        executeNovaBlast(from: entity)

        return true
    }

    // MARK: - Special Ability Implementations

    private func executeNovaBlast(from entity: Entity) {
        guard let player = entity.components[PlayerComponent.self],
              let scene = scene else {
            return
        }

        let blastPosition = entity.position
        let blastRadius = GameConstants.Abilities.Ultimate.radius
        let damage = GameConstants.Abilities.Ultimate.damage

        // Create visual effect
        let explosion = EntityFactory.createExplosion(
            at: blastPosition,
            radius: blastRadius,
            damage: damage,
            team: player.team
        )
        scene.anchors.first?.addChild(explosion)

        // Damage all enemies in radius
        damageInRadius(
            center: blastPosition,
            radius: blastRadius,
            damage: damage,
            team: player.team,
            source: player.playerID
        )
    }

    private func executeGrenade(from entity: Entity, direction: SIMD3<Float>) {
        guard let player = entity.components[PlayerComponent.self],
              let scene = scene else {
            return
        }

        // Create grenade projectile
        let grenadeConfig = ProjectileConfig(
            speed: 8.0,
            radius: 0.1,
            damage: 0, // Explosion does the damage
            lifetime: GameConstants.Abilities.Grenade.fuseTime,
            gravity: true
        )

        let grenade = EntityFactory.createProjectile(
            owner: player.playerID,
            position: entity.position + SIMD3(0, 1.5, 0),
            direction: direction,
            team: player.team,
            config: grenadeConfig
        )

        scene.anchors.first?.addChild(grenade)

        // Schedule explosion
        Task {
            try await Task.sleep(for: .seconds(GameConstants.Abilities.Grenade.fuseTime))

            let explosionPosition = grenade.position
            grenade.removeFromParent()

            executeExplosion(
                at: explosionPosition,
                radius: GameConstants.Abilities.Grenade.radius,
                damage: GameConstants.Abilities.Grenade.damage,
                team: player.team,
                source: player.playerID
            )
        }
    }

    private func executeExplosion(
        at position: SIMD3<Float>,
        radius: Float,
        damage: Float,
        team: TeamColor,
        source: UUID
    ) {
        guard let scene = scene else { return }

        // Visual effect
        let explosion = EntityFactory.createExplosion(
            at: position,
            radius: radius,
            damage: damage,
            team: team
        )
        scene.anchors.first?.addChild(explosion)

        // Damage in radius
        damageInRadius(
            center: position,
            radius: radius,
            damage: damage,
            team: team,
            source: source
        )
    }

    private func damageInRadius(
        center: SIMD3<Float>,
        radius: Float,
        damage: Float,
        team: TeamColor,
        source: UUID
    ) {
        guard let scene = scene else { return }

        for entity in scene.entities {
            damageEntityInRadius(
                entity,
                center: center,
                radius: radius,
                damage: damage,
                team: team,
                source: source
            )
        }
    }

    private func damageEntityInRadius(
        _ entity: Entity,
        center: SIMD3<Float>,
        radius: Float,
        damage: Float,
        team: TeamColor,
        source: UUID
    ) {
        if let player = entity.components[PlayerComponent.self],
           player.team != team {
            let distance = simd_distance(entity.position, center)
            if distance <= radius {
                // Damage falloff based on distance
                let falloff = 1.0 - (distance / radius)
                let finalDamage = damage * falloff

                combatSystem?.applyDamage(
                    to: entity,
                    amount: finalDamage,
                    from: source,
                    at: entity.position
                )
            }
        }

        // Check children
        for child in entity.children {
            damageEntityInRadius(
                child,
                center: center,
                radius: radius,
                damage: damage,
                team: team,
                source: source
            )
        }
    }

    // MARK: - Ultimate Charge

    func addUltimateCharge(to entity: Entity, amount: Float) {
        guard var player = entity.components[PlayerComponent.self] else { return }

        player.ultimateCharge = min(
            player.ultimateCharge + amount,
            GameConstants.Abilities.Ultimate.chargeRequired
        )

        entity.components[PlayerComponent.self] = player
    }

    func chargeUltimateOnDamage(attacker: Entity, damage: Float) {
        // Charge ultimate based on damage dealt
        let chargeAmount = damage * 0.5 // 50 damage = 25 charge
        addUltimateCharge(to: attacker, amount: chargeAmount)
    }

    // MARK: - Ability State Management

    func initializePlayer(_ playerID: UUID) {
        abilityStates[playerID] = PlayerAbilityStates()
    }

    func removePlayer(_ playerID: UUID) {
        abilityStates.removeValue(forKey: playerID)
    }

    func getAbilityState(for playerID: UUID, slot: AbilitySlot) -> AbilityState? {
        guard let states = abilityStates[playerID] else { return nil }

        switch slot {
        case .primary: return states.primary
        case .secondary: return states.secondary
        case .tactical: return states.tactical
        case .ultimate: return states.ultimate
        }
    }

    private func updateActiveAbilities(currentTime: TimeInterval) {
        // Update any abilities with active durations
        // For now, this is handled by component lifetimes
    }

    // MARK: - Utility

    func resetAllCooldowns(for playerID: UUID) {
        guard var states = abilityStates[playerID] else { return }

        states.primary.resetCooldown()
        states.secondary.resetCooldown()
        states.tactical.resetCooldown()
        states.ultimate.resetCooldown()

        abilityStates[playerID] = states
    }
}

// MARK: - Player Ability States

struct PlayerAbilityStates {
    var primary: AbilityState
    var secondary: AbilityState
    var tactical: AbilityState
    var ultimate: AbilityState

    init() {
        self.primary = AbilityState(ability: .primaryFire)
        self.secondary = AbilityState(ability: .shieldWall)
        self.tactical = AbilityState(ability: .dash)
        self.ultimate = AbilityState(ability: .novaBlast)
    }

    mutating func update(deltaTime: TimeInterval) {
        primary.updateCooldown(deltaTime: deltaTime)
        secondary.updateCooldown(deltaTime: deltaTime)
        tactical.updateCooldown(deltaTime: deltaTime)
        ultimate.updateCooldown(deltaTime: deltaTime)
    }
}
