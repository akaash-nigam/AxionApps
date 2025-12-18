//
//  Ability.swift
//  Spatial Arena Championship
//
//  Ability data model
//

import Foundation
import simd

// MARK: - Ability

struct Ability: Codable, Identifiable, Hashable {
    let id: UUID
    var name: String
    var type: AbilityType
    var cooldown: TimeInterval
    var energyCost: Float

    var gesture: GesturePattern
    var effect: AbilityEffect
    var range: Float
    var duration: TimeInterval?

    var projectileConfig: ProjectileConfig?
    var areaEffectConfig: AreaEffectConfig?
    var shieldConfig: ShieldConfig?
    var mobilityConfig: MobilityConfig?

    init(
        id: UUID = UUID(),
        name: String,
        type: AbilityType,
        cooldown: TimeInterval,
        energyCost: Float,
        gesture: GesturePattern,
        effect: AbilityEffect,
        range: Float,
        duration: TimeInterval? = nil
    ) {
        self.id = id
        self.name = name
        self.type = type
        self.cooldown = cooldown
        self.energyCost = energyCost
        self.gesture = gesture
        self.effect = effect
        self.range = range
        self.duration = duration
    }
}

// MARK: - Predefined Abilities

extension Ability {
    static let primaryFire = Ability(
        name: "Energy Bolt",
        type: .projectile,
        cooldown: GameConstants.Abilities.PrimaryFire.cooldown,
        energyCost: GameConstants.Abilities.PrimaryFire.energyCost,
        gesture: .pointing,
        effect: .damage(GameConstants.Abilities.PrimaryFire.damage),
        range: GameConstants.Abilities.PrimaryFire.maxRange,
        projectileConfig: ProjectileConfig(
            speed: GameConstants.Abilities.PrimaryFire.speed,
            radius: GameConstants.Abilities.PrimaryFire.projectileRadius,
            damage: GameConstants.Abilities.PrimaryFire.damage
        )
    )

    static let shieldWall = Ability(
        name: "Shield Wall",
        type: .shield,
        cooldown: GameConstants.Abilities.Shield.cooldown,
        energyCost: GameConstants.Abilities.Shield.energyCost,
        gesture: .palmForward,
        effect: .shield(GameConstants.Abilities.Shield.durability),
        range: 1.0,
        duration: GameConstants.Abilities.Shield.duration,
        shieldConfig: ShieldConfig(
            durability: GameConstants.Abilities.Shield.durability,
            size: GameConstants.Abilities.Shield.size,
            duration: GameConstants.Abilities.Shield.duration
        )
    )

    static let dash = Ability(
        name: "Dash",
        type: .mobility,
        cooldown: GameConstants.Abilities.Dash.cooldown,
        energyCost: GameConstants.Abilities.Dash.energyCost,
        gesture: .swipe,
        effect: .movement,
        range: GameConstants.Abilities.Dash.distance,
        duration: GameConstants.Abilities.Dash.duration,
        mobilityConfig: MobilityConfig(
            distance: GameConstants.Abilities.Dash.distance,
            duration: GameConstants.Abilities.Dash.duration,
            speedMultiplier: 10.0
        )
    )

    static let grenade = Ability(
        name: "Grenade",
        type: .areaEffect,
        cooldown: GameConstants.Abilities.Grenade.cooldown,
        energyCost: GameConstants.Abilities.Grenade.energyCost,
        gesture: .throw,
        effect: .damage(GameConstants.Abilities.Grenade.damage),
        range: 10.0,
        areaEffectConfig: AreaEffectConfig(
            radius: GameConstants.Abilities.Grenade.radius,
            damage: GameConstants.Abilities.Grenade.damage,
            duration: 0.1,
            tickRate: 1
        )
    )

    static let novaBlast = Ability(
        name: "Nova Blast",
        type: .ultimate,
        cooldown: 0,
        energyCost: 0,
        gesture: .twoHandsUp,
        effect: .damage(GameConstants.Abilities.Ultimate.damage),
        range: GameConstants.Abilities.Ultimate.radius,
        duration: GameConstants.Abilities.Ultimate.castTime,
        areaEffectConfig: AreaEffectConfig(
            radius: GameConstants.Abilities.Ultimate.radius,
            damage: GameConstants.Abilities.Ultimate.damage,
            duration: 0.1,
            tickRate: 1
        )
    )

    static let healBeam = Ability(
        name: "Heal Beam",
        type: .heal,
        cooldown: 10.0,
        energyCost: 30.0,
        gesture: .pointAtAlly,
        effect: .heal(30.0),
        range: 10.0,
        duration: 2.0
    )
}

// MARK: - Gesture Pattern

enum GesturePattern: String, Codable {
    case pointing        // Index finger extended, point and pinch
    case palmForward     // Palm facing forward (shield)
    case swipe          // Quick hand swipe
    case `throw`        // Throwing motion
    case twoHandsUp     // Both hands raised (ultimate)
    case pointAtAlly    // Point at teammate
    case punch          // Punching motion

    var description: String {
        switch self {
        case .pointing: return "Point with index finger and pinch to activate"
        case .palmForward: return "Hold palm forward"
        case .swipe: return "Swipe hand in direction"
        case .throw: return "Throwing motion"
        case .twoHandsUp: return "Raise both hands above head"
        case .pointAtAlly: return "Point at teammate"
        case .punch: return "Punching motion"
        }
    }
}

// MARK: - Ability Effect

enum AbilityEffect: Codable, Hashable {
    case damage(Float)
    case heal(Float)
    case shield(Float)
    case movement
    case buff(BuffType)
    case debuff(DebuffType)

    enum BuffType: String, Codable {
        case damageBoost
        case speedBoost
        case shieldBoost
        case invisibility
    }

    enum DebuffType: String, Codable {
        case slow
        case silence
        case blind
        case stun
    }
}

// MARK: - Ability Configurations

struct ProjectileConfig: Codable, Hashable {
    var speed: Float
    var radius: Float
    var damage: Float
    var lifetime: TimeInterval = 5.0
    var gravity: Bool = false
}

struct AreaEffectConfig: Codable, Hashable {
    var radius: Float
    var damage: Float
    var duration: TimeInterval
    var tickRate: Int // Damage ticks per second
}

struct ShieldConfig: Codable, Hashable {
    var durability: Float
    var size: SIMD3<Float>
    var duration: TimeInterval
}

struct MobilityConfig: Codable, Hashable {
    var distance: Float
    var duration: TimeInterval
    var speedMultiplier: Float
}

// MARK: - Ability State (Runtime)

struct AbilityState {
    var ability: Ability
    var cooldownRemaining: TimeInterval = 0
    var isActive: Bool = false
    var activatedAt: TimeInterval?

    var isReady: Bool {
        cooldownRemaining <= 0 && !isActive
    }

    mutating func activate(at time: TimeInterval) {
        isActive = true
        activatedAt = time
        cooldownRemaining = ability.cooldown
    }

    mutating func deactivate() {
        isActive = false
        activatedAt = nil
    }

    mutating func updateCooldown(deltaTime: TimeInterval) {
        if cooldownRemaining > 0 {
            cooldownRemaining = max(0, cooldownRemaining - deltaTime)
        }

        // Check if ability duration expired
        if let activated = activatedAt,
           let duration = ability.duration {
            let elapsed = Date().timeIntervalSince1970 - activated
            if elapsed >= duration {
                deactivate()
            }
        }
    }

    mutating func resetCooldown() {
        cooldownRemaining = 0
    }
}

// MARK: - Ability Slot

enum AbilitySlot: String, Codable, CaseIterable {
    case primary    // No cooldown, no energy
    case secondary  // 8s cooldown
    case tactical   // 12s cooldown
    case ultimate   // Requires charge

    var displayName: String {
        switch self {
        case .primary: return "Primary"
        case .secondary: return "Secondary"
        case .tactical: return "Tactical"
        case .ultimate: return "Ultimate"
        }
    }
}
