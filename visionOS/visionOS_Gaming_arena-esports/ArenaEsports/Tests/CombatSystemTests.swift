import XCTest
import simd
@testable import ArenaEsports

final class CombatSystemTests: XCTestCase {
    var combatSystem: CombatSystem!
    var entityManager: EntityManager!

    override func setUp() async throws {
        try await super.setUp()
        combatSystem = CombatSystem()
        entityManager = EntityManager.shared
        await entityManager.clear()
    }

    override func tearDown() async throws {
        await entityManager.clear()
        try await super.tearDown()
    }

    // MARK: - Weapon Component Tests

    func testWeaponFiring() {
        var weapon = WeaponComponent(entityID: UUID())

        let canFire = weapon.fire(at: 1.0)

        XCTAssertTrue(canFire)
        XCTAssertEqual(weapon.ammo, 29)
        XCTAssertEqual(weapon.lastFireTime, 1.0)
    }

    func testWeaponFireRate() {
        var weapon = WeaponComponent(entityID: UUID(), fireRate: 0.5)

        weapon.fire(at: 1.0)
        let canFireAgain = weapon.fire(at: 1.1) // Too soon

        XCTAssertFalse(canFireAgain)
        XCTAssertEqual(weapon.ammo, 29) // Only fired once
    }

    func testWeaponEmptyAmmo() {
        var weapon = WeaponComponent(entityID: UUID(), ammo: 0)

        let canFire = weapon.fire(at: 1.0)

        XCTAssertFalse(canFire)
        XCTAssertTrue(weapon.needsReload)
    }

    func testWeaponReload() {
        var weapon = WeaponComponent(entityID: UUID(), ammo: 0, maxAmmo: 30)

        weapon.reload()

        XCTAssertEqual(weapon.ammo, 30)
        XCTAssertTrue(weapon.canFire)
        XCTAssertFalse(weapon.needsReload)
    }

    // MARK: - Damage Tests

    func testApplyDamage() async {
        let entity = await entityManager.createEntity()
        entity.addComponent(HealthComponent(entityID: entity.id, current: 100, maximum: 100))

        let killed = await combatSystem.applyDamage(
            to: entity.id,
            amount: 25,
            from: nil,
            at: 1.0
        )

        XCTAssertFalse(killed)

        let health = entity.getComponent(HealthComponent.self)!
        XCTAssertEqual(health.current, 75)
    }

    func testLethalDamage() async {
        let entity = await entityManager.createEntity()
        entity.addComponent(HealthComponent(entityID: entity.id, current: 50, maximum: 100))

        let killed = await combatSystem.applyDamage(
            to: entity.id,
            amount: 60,
            from: nil,
            at: 1.0
        )

        XCTAssertTrue(killed)

        let health = entity.getComponent(HealthComponent.self)!
        XCTAssertFalse(health.isAlive)
    }

    func testDamageMultiplier() async {
        let entity = await entityManager.createEntity()
        entity.addComponent(HealthComponent(entityID: entity.id, current: 100, maximum: 100))
        entity.addComponent(CombatComponent(entityID: entity.id, damageMultiplier: 2.0))

        await combatSystem.applyDamage(
            to: entity.id,
            amount: 25,
            from: nil,
            at: 1.0
        )

        let health = entity.getComponent(HealthComponent.self)!
        XCTAssertEqual(health.current, 50) // 25 * 2.0 = 50 damage
    }

    func testCombatStateUpdate() async {
        let attacker = await entityManager.createEntity()
        let target = await entityManager.createEntity()
        target.addComponent(HealthComponent(entityID: target.id, current: 100, maximum: 100))
        target.addComponent(CombatComponent(entityID: target.id))

        await combatSystem.applyDamage(
            to: target.id,
            amount: 25,
            from: attacker.id,
            at: 1.0
        )

        let combat = target.getComponent(CombatComponent.self)!
        XCTAssertTrue(combat.isInCombat)
        XCTAssertEqual(combat.lastAttacker, attacker.id)
    }

    // MARK: - Hitscan Tests

    func testHitscanHit() async {
        let attacker = await entityManager.createEntity()
        attacker.addComponent(TransformComponent(entityID: attacker.id, position: .zero))

        let target = await entityManager.createEntity()
        target.addComponent(TransformComponent(entityID: target.id, position: SIMD3(0, 0, 10)))
        target.addComponent(CollisionComponent(entityID: target.id, radius: 1.0))
        target.addComponent(HealthComponent(entityID: target.id, current: 100, maximum: 100))

        let hitEntityID = await combatSystem.performHitscan(
            from: .zero,
            direction: SIMD3(0, 0, 1),
            maxDistance: 50,
            damage: 25,
            attackerID: attacker.id,
            entities: [attacker, target]
        )

        XCTAssertNil(hitEntityID) // Not killed, just damaged

        let health = target.getComponent(HealthComponent.self)!
        XCTAssertEqual(health.current, 75)
    }

    func testHitscanMiss() async {
        let attacker = await entityManager.createEntity()
        attacker.addComponent(TransformComponent(entityID: attacker.id, position: .zero))

        let target = await entityManager.createEntity()
        target.addComponent(TransformComponent(entityID: target.id, position: SIMD3(10, 0, 0)))
        target.addComponent(CollisionComponent(entityID: target.id, radius: 1.0))
        target.addComponent(HealthComponent(entityID: target.id, current: 100, maximum: 100))

        let hitEntityID = await combatSystem.performHitscan(
            from: .zero,
            direction: SIMD3(0, 0, 1), // Shooting forward, target is to the side
            maxDistance: 50,
            damage: 25,
            attackerID: attacker.id,
            entities: [attacker, target]
        )

        XCTAssertNil(hitEntityID)

        let health = target.getComponent(HealthComponent.self)!
        XCTAssertEqual(health.current, 100) // No damage
    }

    func testHitscanKill() async {
        let attacker = await entityManager.createEntity()
        attacker.addComponent(TransformComponent(entityID: attacker.id, position: .zero))

        let target = await entityManager.createEntity()
        target.addComponent(TransformComponent(entityID: target.id, position: SIMD3(0, 0, 10)))
        target.addComponent(CollisionComponent(entityID: target.id, radius: 1.0))
        target.addComponent(HealthComponent(entityID: target.id, current: 20, maximum: 100))

        let hitEntityID = await combatSystem.performHitscan(
            from: .zero,
            direction: SIMD3(0, 0, 1),
            maxDistance: 50,
            damage: 25,
            attackerID: attacker.id,
            entities: [attacker, target]
        )

        XCTAssertEqual(hitEntityID, target.id) // Killed

        let health = target.getComponent(HealthComponent.self)!
        XCTAssertFalse(health.isAlive)
    }

    // MARK: - Integration Tests

    func testCombatSystemUpdate() async {
        let entity = await entityManager.createEntity()
        entity.addComponent(CombatComponent(entityID: entity.id, isInCombat: true))

        await combatSystem.update(deltaTime: 0.016, entities: [entity])

        let combat = entity.getComponent(CombatComponent.self)!
        XCTAssertFalse(combat.isInCombat)
    }
}
