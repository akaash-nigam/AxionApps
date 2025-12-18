//
//  CombatEntity.swift
//  MilitaryDefenseTraining
//
//  Created by Claude Code
//

import Foundation
import RealityKit
import simd

class CombatEntity: Entity {
    var entityType: EntityType
    var health: Float
    var maxHealth: Float
    var armor: ArmorType
    var weapons: [WeaponSystem]
    var currentWeaponIndex: Int
    var stance: CombatStance
    var movementSpeed: Float
    var detectionRadius: Float
    var isAlive: Bool

    init(
        entityType: EntityType,
        health: Float = 100,
        armor: ArmorType = .none,
        weapons: [WeaponSystem] = [],
        stance: CombatStance = .standing,
        movementSpeed: Float = 1.5,
        detectionRadius: Float = 50
    ) {
        self.entityType = entityType
        self.health = health
        self.maxHealth = health
        self.armor = armor
        self.weapons = weapons
        self.currentWeaponIndex = 0
        self.stance = stance
        self.movementSpeed = movementSpeed
        self.detectionRadius = detectionRadius
        self.isAlive = true

        super.init()
    }

    required init() {
        self.entityType = .friendly
        self.health = 100
        self.maxHealth = 100
        self.armor = .none
        self.weapons = []
        self.currentWeaponIndex = 0
        self.stance = .standing
        self.movementSpeed = 1.5
        self.detectionRadius = 50
        self.isAlive = true

        super.init()
    }

    var currentWeapon: WeaponSystem? {
        get {
            guard !weapons.isEmpty, currentWeaponIndex < weapons.count else {
                return nil
            }
            return weapons[currentWeaponIndex]
        }
        set {
            guard !weapons.isEmpty, currentWeaponIndex < weapons.count, let newValue else {
                return
            }
            weapons[currentWeaponIndex] = newValue
        }
    }

    var healthPercentage: Float {
        guard maxHealth > 0 else { return 0 }
        return health / maxHealth
    }

    func takeDamage(_ amount: Float) {
        let armorReduction = armor.damageReduction
        let actualDamage = amount * (1.0 - armorReduction)
        health = max(0, health - actualDamage)

        if health <= 0 {
            isAlive = false
            onDeath()
        }
    }

    func heal(_ amount: Float) {
        health = min(maxHealth, health + amount)
    }

    func switchWeapon(to index: Int) {
        guard index >= 0, index < weapons.count else { return }
        currentWeaponIndex = index
    }

    func nextWeapon() {
        guard !weapons.isEmpty else { return }
        currentWeaponIndex = (currentWeaponIndex + 1) % weapons.count
    }

    private func onDeath() {
        // Death handling - will be implemented with animations
        // For now, just mark as not alive
    }
}

// MARK: - Entity Type
enum EntityType: String, Codable {
    case friendly = "Friendly"
    case enemy = "Enemy"
    case neutral = "Neutral"
    case objective = "Objective"
    case civilian = "Civilian"
}

// MARK: - Armor Type
enum ArmorType: String, Codable {
    case none = "None"
    case light = "Light"
    case plateCarrier = "Plate Carrier"
    case heavy = "Heavy"

    var damageReduction: Float {
        switch self {
        case .none: return 0.0
        case .light: return 0.15
        case .plateCarrier: return 0.35
        case .heavy: return 0.50
        }
    }

    var speedPenalty: Float {
        switch self {
        case .none: return 0.0
        case .light: return 0.05
        case .plateCarrier: return 0.10
        case .heavy: return 0.20
        }
    }
}

// MARK: - Combat Stance
enum CombatStance: String, Codable {
    case standing = "Standing"
    case crouching = "Crouching"
    case prone = "Prone"

    var heightMultiplier: Float {
        switch self {
        case .standing: return 1.0
        case .crouching: return 0.6
        case .prone: return 0.3
        }
    }

    var speedMultiplier: Float {
        switch self {
        case .standing: return 1.0
        case .crouching: return 0.5
        case .prone: return 0.2
        }
    }

    var accuracyBonus: Float {
        switch self {
        case .standing: return 0.0
        case .crouching: return 0.15
        case .prone: return 0.30
        }
    }

    var detectionMultiplier: Float {
        switch self {
        case .standing: return 1.0
        case .crouching: return 0.7
        case .prone: return 0.4
        }
    }
}

// MARK: - Hit Event
struct HitEvent {
    var attacker: CombatEntity
    var target: CombatEntity
    var weapon: WeaponSystem
    var distance: Float
    var isHeadshot: Bool
    var timestamp: Date

    init(
        attacker: CombatEntity,
        target: CombatEntity,
        weapon: WeaponSystem,
        distance: Float,
        isHeadshot: Bool,
        timestamp: Date = Date()
    ) {
        self.attacker = attacker
        self.target = target
        self.weapon = weapon
        self.distance = distance
        self.isHeadshot = isHeadshot
        self.timestamp = timestamp
    }
}
