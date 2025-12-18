//
//  WeaponLibrary.swift
//  MilitaryDefenseTraining
//
//  Created by Claude Code
//

import Foundation

extension WeaponSystem {
    // MARK: - Assault Rifles

    static let m16A4 = WeaponSystem(
        name: "M16A4",
        type: .rifle,
        ammunition: .nato556,
        magazineCapacity: 30,
        currentRounds: 30,
        totalAmmo: 210,
        fireRate: 700,
        effectiveRange: 550,
        damage: DamageModel(baseDamage: 32, armorPenetration: 0.65),
        fireMode: .burstFire
    )

    static let ak47 = WeaponSystem(
        name: "AK-47",
        type: .rifle,
        ammunition: .nato762,
        magazineCapacity: 30,
        currentRounds: 30,
        totalAmmo: 180,
        fireRate: 600,
        effectiveRange: 350,
        damage: DamageModel(baseDamage: 40, armorPenetration: 0.7),
        recoilPattern: .high,
        fireMode: .fullAuto
    )

    static let scar17 = WeaponSystem(
        name: "SCAR-17",
        type: .rifle,
        ammunition: .nato762,
        magazineCapacity: 20,
        currentRounds: 20,
        totalAmmo: 140,
        fireRate: 625,
        effectiveRange: 600,
        damage: DamageModel(baseDamage: 45, armorPenetration: 0.75),
        recoilPattern: .moderate
    )

    // MARK: - Sniper Rifles

    static let m24 = WeaponSystem(
        name: "M24 SWS",
        type: .sniper,
        ammunition: .nato762,
        magazineCapacity: 5,
        currentRounds: 5,
        totalAmmo: 40,
        fireRate: 20,
        effectiveRange: 800,
        damage: DamageModel(
            baseDamage: 100,
            headMultiplier: 3.0,
            armorPenetration: 0.9,
            dropoffStart: 400,
            dropoffEnd: 800
        ),
        recoilPattern: .high,
        fireMode: .single
    )

    static let m107 = WeaponSystem(
        name: "M107 Barrett",
        type: .sniper,
        ammunition: .nato762,
        magazineCapacity: 10,
        currentRounds: 10,
        totalAmmo: 30,
        fireRate: 60,
        effectiveRange: 1800,
        damage: DamageModel(
            baseDamage: 150,
            headMultiplier: 3.5,
            armorPenetration: 0.95,
            dropoffStart: 800,
            dropoffEnd: 1800
        ),
        recoilPattern: .veryHigh,
        fireMode: .semiAuto
    )

    // MARK: - Shotguns

    static let m500 = WeaponSystem(
        name: "Mossberg 500",
        type: .shotgun,
        ammunition: .gauge12,
        magazineCapacity: 8,
        currentRounds: 8,
        totalAmmo: 40,
        fireRate: 60,
        effectiveRange: 40,
        damage: DamageModel(
            baseDamage: 80,
            headMultiplier: 1.5,
            armorPenetration: 0.4,
            dropoffStart: 10,
            dropoffEnd: 40
        ),
        recoilPattern: .veryHigh,
        fireMode: .single
    )

    static let aa12 = WeaponSystem(
        name: "AA-12",
        type: .shotgun,
        ammunition: .gauge12,
        magazineCapacity: 20,
        currentRounds: 20,
        totalAmmo: 60,
        fireRate: 300,
        effectiveRange: 50,
        damage: DamageModel(baseDamage: 70, armorPenetration: 0.45),
        recoilPattern: .moderate,
        fireMode: .fullAuto
    )

    // MARK: - SMGs

    static let mp5 = WeaponSystem(
        name: "MP5",
        type: .smg,
        ammunition: .mm9,
        magazineCapacity: 30,
        currentRounds: 30,
        totalAmmo: 180,
        fireRate: 800,
        effectiveRange: 200,
        damage: DamageModel(baseDamage: 22, armorPenetration: 0.3),
        recoilPattern: .low,
        fireMode: .fullAuto
    )

    static let p90 = WeaponSystem(
        name: "FN P90",
        type: .smg,
        ammunition: .mm9,
        magazineCapacity: 50,
        currentRounds: 50,
        totalAmmo: 200,
        fireRate: 900,
        effectiveRange: 150,
        damage: DamageModel(baseDamage: 20, armorPenetration: 0.6),
        recoilPattern: .low,
        fireMode: .fullAuto
    )

    // MARK: - Pistols

    static let glock17 = WeaponSystem(
        name: "Glock 17",
        type: .pistol,
        ammunition: .mm9,
        magazineCapacity: 17,
        currentRounds: 17,
        totalAmmo: 68,
        fireRate: 120,
        effectiveRange: 50,
        damage: DamageModel(baseDamage: 22, armorPenetration: 0.3),
        recoilPattern: .low,
        fireMode: .semiAuto
    )

    static let desert eagle = WeaponSystem(
        name: "Desert Eagle",
        type: .pistol,
        ammunition: .mm45acp,
        magazineCapacity: 7,
        currentRounds: 7,
        totalAmmo: 35,
        fireRate: 100,
        effectiveRange: 60,
        damage: DamageModel(baseDamage: 45, armorPenetration: 0.5),
        recoilPattern: .high,
        fireMode: .semiAuto
    )

    // MARK: - Light Machine Guns

    static let m240 = WeaponSystem(
        name: "M240",
        type: .lmg,
        ammunition: .nato762,
        magazineCapacity: 200,
        currentRounds: 200,
        totalAmmo: 600,
        fireRate: 750,
        effectiveRange: 1100,
        damage: DamageModel(baseDamage: 42, armorPenetration: 0.75),
        recoilPattern: .high,
        fireMode: .fullAuto
    )

    static let pkm = WeaponSystem(
        name: "PKM",
        type: .lmg,
        ammunition: .nato762,
        magazineCapacity: 250,
        currentRounds: 250,
        totalAmmo: 750,
        fireRate: 650,
        effectiveRange: 1000,
        damage: DamageModel(baseDamage: 40, armorPenetration: 0.7),
        recoilPattern: .moderate,
        fireMode: .fullAuto
    )

    // MARK: - Grenades

    static let fragGrenade = WeaponSystem(
        name: "M67 Frag Grenade",
        type: .grenade,
        ammunition: .explosive,
        magazineCapacity: 1,
        currentRounds: 1,
        totalAmmo: 2,
        fireRate: 1,
        effectiveRange: 40,
        damage: DamageModel(
            baseDamage: 200,
            headMultiplier: 1.0,
            armorPenetration: 0.8,
            dropoffStart: 5,
            dropoffEnd: 15
        ),
        fireMode: .single
    )

    static let flashbang = WeaponSystem(
        name: "Flashbang",
        type: .grenade,
        ammunition: .explosive,
        magazineCapacity: 1,
        currentRounds: 1,
        totalAmmo: 2,
        fireRate: 1,
        effectiveRange: 25,
        damage: DamageModel(baseDamage: 0), // No damage, stun only
        fireMode: .single
    )

    static let smokeGrenade = WeaponSystem(
        name: "Smoke Grenade",
        type: .grenade,
        ammunition: .explosive,
        magazineCapacity: 1,
        currentRounds: 1,
        totalAmmo: 2,
        fireRate: 1,
        effectiveRange: 20,
        damage: DamageModel(baseDamage: 0), // Concealment only
        fireMode: .single
    )

    // MARK: - Weapon Collections

    static let allRifles: [WeaponSystem] = [
        m4Rifle, m16A4, ak47, scar17
    ]

    static let allSnipers: [WeaponSystem] = [
        m24, m107
    ]

    static let allShotguns: [WeaponSystem] = [
        m500, aa12
    ]

    static let allSMGs: [WeaponSystem] = [
        mp5, p90
    ]

    static let allPistols: [WeaponSystem] = [
        m9Pistol, glock17, desertEagle
    ]

    static let allLMGs: [WeaponSystem] = [
        m249SAW, m240, pkm
    ]

    static let allGrenades: [WeaponSystem] = [
        fragGrenade, flashbang, smokeGrenade
    ]

    static let allWeapons: [WeaponSystem] = [
        allRifles,
        allSnipers,
        allShotguns,
        allSMGs,
        allPistols,
        allLMGs,
        allGrenades
    ].flatMap { $0 }
}
