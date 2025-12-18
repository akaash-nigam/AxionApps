import XCTest
@testable import TacticalTeamShooters

final class WeaponTests: XCTestCase {

    // MARK: - Weapon Initialization Tests

    func testAK47Initialization() {
        let ak47 = Weapon.ak47

        XCTAssertEqual(ak47.name, "AK-47")
        XCTAssertEqual(ak47.type, .assaultRifle)
        XCTAssertEqual(ak47.stats.damage, 36)
        XCTAssertEqual(ak47.stats.magazineSize, 30)
        XCTAssertEqual(ak47.stats.fireRate, 600)
    }

    func testM4A1Initialization() {
        let m4 = Weapon.m4a1

        XCTAssertEqual(m4.name, "M4A1")
        XCTAssertEqual(m4.type, .assaultRifle)
        XCTAssertEqual(m4.stats.damage, 33)
        XCTAssertEqual(m4.stats.magazineSize, 30)
    }

    func testAWPInitialization() {
        let awp = Weapon.awp

        XCTAssertEqual(awp.name, "AWP")
        XCTAssertEqual(awp.type, .sniper)
        XCTAssertEqual(awp.stats.damage, 115)
        XCTAssertGreaterThan(awp.stats.damage, 100) // One-shot capability
    }

    func testGlockInitialization() {
        let glock = Weapon.glock

        XCTAssertEqual(glock.name, "Glock-18")
        XCTAssertEqual(glock.type, .pistol)
        XCTAssertEqual(glock.stats.magazineSize, 20)
    }

    // MARK: - Weapon Stats Tests

    func testWeaponDamagePerSecond() {
        let ak47 = Weapon.ak47
        let expectedDPS = Double(36) * (600.0 / 60.0)

        XCTAssertEqual(ak47.stats.damagePerSecond, expectedDPS, accuracy: 0.1)
    }

    func testWeaponTimeToKill() {
        let ak47 = Weapon.ak47

        // 100 HP / 36 damage = 2.78 shots = 3 shots needed
        // At 600 RPM: 60/600 = 0.1s between shots
        // TTK = (3-1) * 0.1 = 0.2 seconds

        XCTAssertGreaterThan(ak47.stats.timeToKill, 0.15)
        XCTAssertLessThan(ak47.stats.timeToKill, 0.25)
    }

    func testSniperOneShot() {
        let awp = Weapon.awp

        // AWP should one-shot (damage >= 100)
        XCTAssertGreaterThanOrEqual(awp.stats.damage, 100)

        // TTK should be instant (0 seconds, as only 1 shot needed)
        XCTAssertEqual(awp.stats.timeToKill, 0, accuracy: 0.01)
    }

    // MARK: - Weapon Type Tests

    func testWeaponTypeDisplayNames() {
        XCTAssertEqual(WeaponType.assaultRifle.displayName, "Assault Rifle")
        XCTAssertEqual(WeaponType.smg.displayName, "SMG")
        XCTAssertEqual(WeaponType.sniper.displayName, "Sniper Rifle")
        XCTAssertEqual(WeaponType.shotgun.displayName, "Shotgun")
        XCTAssertEqual(WeaponType.pistol.displayName, "Pistol")
        XCTAssertEqual(WeaponType.lmg.displayName, "LMG")
    }

    func testWeaponCategories() {
        XCTAssertEqual(WeaponType.assaultRifle.category, .automatic)
        XCTAssertEqual(WeaponType.smg.category, .automatic)
        XCTAssertEqual(WeaponType.lmg.category, .automatic)
        XCTAssertEqual(WeaponType.sniper.category, .precision)
        XCTAssertEqual(WeaponType.shotgun.category, .closeRange)
        XCTAssertEqual(WeaponType.pistol.category, .secondary)
    }

    // MARK: - Recoil Pattern Tests

    func testAK47RecoilPattern() {
        let pattern = RecoilPattern.ak47Pattern

        XCTAssertEqual(pattern.verticalKick, 0.15, accuracy: 0.01)
        XCTAssertEqual(pattern.horizontalSpread, 0.08, accuracy: 0.01)
        XCTAssertEqual(pattern.resetTime, 0.4, accuracy: 0.01)
        XCTAssertFalse(pattern.pattern.isEmpty)
        XCTAssertEqual(pattern.pattern.count, 10)
    }

    func testM4RecoilPattern() {
        let pattern = RecoilPattern.m4Pattern

        XCTAssertEqual(pattern.verticalKick, 0.12, accuracy: 0.01)
        XCTAssertEqual(pattern.horizontalSpread, 0.05, accuracy: 0.01)
        XCTAssertLessThan(pattern.verticalKick, RecoilPattern.ak47Pattern.verticalKick)
    }

    // MARK: - Attachment Tests

    func testAttachmentTypes() {
        let optic = Attachment(
            name: "Holographic Sight",
            type: .optic,
            modifiers: WeaponModifiers(accuracyMultiplier: 1.1)
        )

        XCTAssertEqual(optic.type, .optic)
        XCTAssertEqual(optic.type.displayName, "Optic")
        XCTAssertEqual(optic.type.slot, 0)
    }

    func testWeaponModifiers() {
        let modifier = WeaponModifiers(
            damageMultiplier: 1.1,
            recoilMultiplier: 0.9,
            accuracyMultiplier: 1.05,
            magazineSizeBonus: 10
        )

        XCTAssertEqual(modifier.damageMultiplier, 1.1, accuracy: 0.01)
        XCTAssertEqual(modifier.recoilMultiplier, 0.9, accuracy: 0.01)
        XCTAssertEqual(modifier.accuracyMultiplier, 1.05, accuracy: 0.01)
        XCTAssertEqual(modifier.magazineSizeBonus, 10)
    }

    // MARK: - Equipment Tests

    func testEquipmentMaxQuantity() {
        XCTAssertEqual(EquipmentType.flashbang.maxQuantity, 3)
        XCTAssertEqual(EquipmentType.smokeGrenade.maxQuantity, 2)
        XCTAssertEqual(EquipmentType.fragGrenade.maxQuantity, 1)
        XCTAssertEqual(EquipmentType.molotov.maxQuantity, 1)
    }

    func testEquipmentPricing() {
        XCTAssertEqual(EquipmentType.flashbang.price, 200)
        XCTAssertEqual(EquipmentType.smokeGrenade.price, 300)
        XCTAssertEqual(EquipmentType.armor.price, 650)
        XCTAssertEqual(EquipmentType.defuseKit.price, 400)
    }

    // MARK: - Weapon Balance Tests

    func testAssaultRifleBalance() {
        let ak47 = Weapon.ak47
        let m4 = Weapon.m4a1

        // AK should have higher damage
        XCTAssertGreaterThan(ak47.stats.damage, m4.stats.damage)

        // M4 should have higher fire rate
        XCTAssertGreaterThan(m4.stats.fireRate, ak47.stats.fireRate)

        // M4 should have better accuracy
        XCTAssertGreaterThan(m4.stats.accuracy, ak47.stats.accuracy)
    }

    func testWeaponRangeBalancing() {
        let awp = Weapon.awp
        let ak47 = Weapon.ak47

        // Sniper should have longer range
        XCTAssertGreaterThan(awp.stats.range, ak47.stats.range)
    }

    // MARK: - Codable Tests

    func testWeaponCodable() throws {
        let weapon = Weapon.ak47

        let encoder = JSONEncoder()
        let data = try encoder.encode(weapon)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(Weapon.self, from: data)

        XCTAssertEqual(decoded.name, weapon.name)
        XCTAssertEqual(decoded.type, weapon.type)
        XCTAssertEqual(decoded.stats.damage, weapon.stats.damage)
    }

    func testAllWeaponsArray() {
        let allWeapons = Weapon.allWeapons

        XCTAssertFalse(allWeapons.isEmpty)
        XCTAssertGreaterThanOrEqual(allWeapons.count, 4)
        XCTAssertTrue(allWeapons.contains(where: { $0.name == "AK-47" }))
        XCTAssertTrue(allWeapons.contains(where: { $0.name == "M4A1" }))
        XCTAssertTrue(allWeapons.contains(where: { $0.name == "AWP" }))
    }
}
