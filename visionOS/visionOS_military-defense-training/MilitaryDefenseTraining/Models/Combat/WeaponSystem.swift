//
//  WeaponSystem.swift
//  MilitaryDefenseTraining
//
//  Created by Claude Code
//

import Foundation
import simd

struct WeaponSystem: Codable, Identifiable {
    var id: UUID
    var name: String
    var type: WeaponType
    var ammunition: AmmunitionType
    var magazineCapacity: Int
    var currentRounds: Int
    var totalAmmo: Int
    var fireRate: Float // rounds per minute
    var effectiveRange: Float // meters
    var damage: DamageModel
    var recoilPattern: RecoilPattern
    var fireMode: FireMode

    init(
        id: UUID = UUID(),
        name: String,
        type: WeaponType,
        ammunition: AmmunitionType,
        magazineCapacity: Int,
        currentRounds: Int,
        totalAmmo: Int,
        fireRate: Float,
        effectiveRange: Float,
        damage: DamageModel,
        recoilPattern: RecoilPattern = .moderate,
        fireMode: FireMode = .semiAuto
    ) {
        self.id = id
        self.name = name
        self.type = type
        self.ammunition = ammunition
        self.magazineCapacity = magazineCapacity
        self.currentRounds = currentRounds
        self.totalAmmo = totalAmmo
        self.fireRate = fireRate
        self.effectiveRange = effectiveRange
        self.damage = damage
        self.recoilPattern = recoilPattern
        self.fireMode = fireMode
    }

    var needsReload: Bool {
        currentRounds == 0
    }

    var hasAmmo: Bool {
        totalAmmo > 0 || currentRounds > 0
    }

    mutating func fire() -> Bool {
        guard currentRounds > 0 else { return false }
        currentRounds -= 1
        return true
    }

    mutating func reload() {
        let roundsNeeded = magazineCapacity - currentRounds
        let roundsToLoad = min(roundsNeeded, totalAmmo)
        currentRounds += roundsToLoad
        totalAmmo -= roundsToLoad
    }
}

// MARK: - Weapon Type
enum WeaponType: String, Codable, CaseIterable {
    case rifle = "Rifle"
    case pistol = "Pistol"
    case shotgun = "Shotgun"
    case smg = "SMG"
    case lmg = "LMG"
    case sniper = "Sniper"
    case grenade = "Grenade"
    case launcher = "Launcher"

    var iconName: String {
        switch self {
        case .rifle: return "🔫"
        case .pistol: return "🔫"
        case .shotgun: return "🔫"
        case .smg: return "🔫"
        case .lmg: return "🔫"
        case .sniper: return "🎯"
        case .grenade: return "💣"
        case .launcher: return "🚀"
        }
    }
}

// MARK: - Ammunition Type
enum AmmunitionType: String, Codable {
    case nato556 = "5.56mm NATO"
    case nato762 = "7.62mm NATO"
    case mm9 = "9mm"
    case mm45acp = ".45 ACP"
    case gauge12 = "12 Gauge"
    case mm40 = "40mm Grenade"
    case explosive = "Explosive"
}

// MARK: - Fire Mode
enum FireMode: String, Codable {
    case semiAuto = "Semi-Auto"
    case burstFire = "Burst"
    case fullAuto = "Full-Auto"
    case single = "Single"
}

// MARK: - Recoil Pattern
enum RecoilPattern: String, Codable {
    case low = "Low"
    case moderate = "Moderate"
    case high = "High"
    case veryHigh = "Very High"

    var recoilMultiplier: Float {
        switch self {
        case .low: return 0.5
        case .moderate: return 1.0
        case .high: return 1.5
        case .veryHigh: return 2.0
        }
    }
}

// MARK: - Damage Model
struct DamageModel: Codable {
    var baseDamage: Float
    var headMultiplier: Float
    var armorPenetration: Float
    var dropoffStart: Float // distance in meters
    var dropoffEnd: Float

    init(
        baseDamage: Float = 30,
        headMultiplier: Float = 2.0,
        armorPenetration: Float = 0.5,
        dropoffStart: Float = 50,
        dropoffEnd: Float = 300
    ) {
        self.baseDamage = baseDamage
        self.headMultiplier = headMultiplier
        self.armorPenetration = armorPenetration
        self.dropoffStart = dropoffStart
        self.dropoffEnd = dropoffEnd
    }

    func calculateDamage(
        distance: Float,
        isHeadshot: Bool,
        armorValue: Float
    ) -> Float {
        var damage = baseDamage

        // Apply headshot multiplier
        if isHeadshot {
            damage *= headMultiplier
        }

        // Apply distance dropoff
        if distance > dropoffStart {
            let dropoffRange = dropoffEnd - dropoffStart
            let dropoffDistance = min(distance - dropoffStart, dropoffRange)
            let dropoffFactor = 1.0 - (dropoffDistance / dropoffRange * 0.5)
            damage *= dropoffFactor
        }

        // Apply armor
        let effectiveArmor = armorValue * (1.0 - armorPenetration)
        damage *= (1.0 - effectiveArmor)

        return max(damage, 0)
    }
}

// MARK: - Predefined Weapons
extension WeaponSystem {
    static let m4Rifle = WeaponSystem(
        name: "M4A1 Carbine",
        type: .rifle,
        ammunition: .nato556,
        magazineCapacity: 30,
        currentRounds: 30,
        totalAmmo: 210,
        fireRate: 700,
        effectiveRange: 500,
        damage: DamageModel(
            baseDamage: 30,
            headMultiplier: 2.5,
            armorPenetration: 0.6,
            dropoffStart: 100,
            dropoffEnd: 500
        ),
        recoilPattern: .moderate,
        fireMode: .semiAuto
    )

    static let m9Pistol = WeaponSystem(
        name: "M9 Beretta",
        type: .pistol,
        ammunition: .mm9,
        magazineCapacity: 15,
        currentRounds: 15,
        totalAmmo: 60,
        fireRate: 120,
        effectiveRange: 50,
        damage: DamageModel(
            baseDamage: 20,
            headMultiplier: 2.0,
            armorPenetration: 0.3,
            dropoffStart: 25,
            dropoffEnd: 50
        ),
        recoilPattern: .low,
        fireMode: .semiAuto
    )

    static let m249SAW = WeaponSystem(
        name: "M249 SAW",
        type: .lmg,
        ammunition: .nato556,
        magazineCapacity: 200,
        currentRounds: 200,
        totalAmmo: 600,
        fireRate: 800,
        effectiveRange: 800,
        damage: DamageModel(
            baseDamage: 32,
            headMultiplier: 2.3,
            armorPenetration: 0.65,
            dropoffStart: 200,
            dropoffEnd: 800
        ),
        recoilPattern: .high,
        fireMode: .fullAuto
    )
}
