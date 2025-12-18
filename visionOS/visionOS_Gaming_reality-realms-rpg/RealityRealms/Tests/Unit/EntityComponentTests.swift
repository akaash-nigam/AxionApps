//
//  EntityComponentTests.swift
//  Reality Realms RPG Tests
//
//  Unit tests for Entity-Component System
//

import XCTest
@testable import RealityRealms

final class EntityComponentTests: XCTestCase {

    // MARK: - Entity Tests

    func testEntityCreation() {
        let entity = Entity()

        XCTAssertNotNil(entity.id)
        XCTAssertTrue(entity.isActive)
        XCTAssertEqual(entity.components.count, 0)
    }

    func testAddComponent() {
        let entity = Entity()
        let healthComponent = HealthComponent(entityID: entity.id, maximum: 100)

        entity.addComponent(healthComponent)

        XCTAssertTrue(entity.hasComponent(HealthComponent.self))
        XCTAssertEqual(entity.components.count, 1)
    }

    func testGetComponent() {
        let entity = Entity()
        let healthComponent = HealthComponent(entityID: entity.id, maximum: 100)
        entity.addComponent(healthComponent)

        let retrieved = entity.getComponent(HealthComponent.self)

        XCTAssertNotNil(retrieved)
        XCTAssertEqual(retrieved?.maximum, 100)
    }

    func testRemoveComponent() {
        let entity = Entity()
        let healthComponent = HealthComponent(entityID: entity.id, maximum: 100)
        entity.addComponent(healthComponent)

        entity.removeComponent(HealthComponent.self)

        XCTAssertFalse(entity.hasComponent(HealthComponent.self))
        XCTAssertEqual(entity.components.count, 0)
    }

    // MARK: - Health Component Tests

    func testHealthComponentCreation() {
        let entityID = UUID()
        let health = HealthComponent(entityID: entityID, maximum: 100)

        XCTAssertEqual(health.entityID, entityID)
        XCTAssertEqual(health.current, 100)
        XCTAssertEqual(health.maximum, 100)
        XCTAssertFalse(health.isDead)
    }

    func testTakeDamage() {
        let health = HealthComponent(entityID: UUID(), maximum: 100)

        health.takeDamage(30)

        XCTAssertEqual(health.current, 70)
        XCTAssertFalse(health.isDead)
    }

    func testTakeFatalDamage() {
        let health = HealthComponent(entityID: UUID(), maximum: 100)

        health.takeDamage(150)

        XCTAssertEqual(health.current, 0)
        XCTAssertTrue(health.isDead)
    }

    func testHeal() {
        let health = HealthComponent(entityID: UUID(), maximum: 100)
        health.takeDamage(50)

        health.heal(30)

        XCTAssertEqual(health.current, 80)
    }

    func testHealCannotExceedMaximum() {
        let health = HealthComponent(entityID: UUID(), maximum: 100)
        health.takeDamage(20)

        health.heal(50)

        XCTAssertEqual(health.current, 100)
    }

    func testHealRevivesEntity() {
        let health = HealthComponent(entityID: UUID(), maximum: 100)
        health.takeDamage(150)
        XCTAssertTrue(health.isDead)

        health.heal(50)

        XCTAssertEqual(health.current, 50)
        XCTAssertFalse(health.isDead)
    }

    // MARK: - Combat Component Tests

    func testCombatComponentCreation() {
        let entityID = UUID()
        let combat = CombatComponent(
            entityID: entityID,
            damage: 15,
            attackSpeed: 1.5,
            attackRange: 1.0
        )

        XCTAssertEqual(combat.entityID, entityID)
        XCTAssertEqual(combat.damage, 15)
        XCTAssertEqual(combat.attackSpeed, 1.5)
        XCTAssertEqual(combat.attackRange, 1.0)
        XCTAssertNil(combat.lastAttackTime)
    }

    func testCanAttackInitially() {
        let combat = CombatComponent(
            entityID: UUID(),
            damage: 15,
            attackSpeed: 1.5,
            attackRange: 1.0
        )

        XCTAssertTrue(combat.canAttack())
    }

    func testCannotAttackDuringCooldown() {
        let combat = CombatComponent(
            entityID: UUID(),
            damage: 15,
            attackSpeed: 2.0,  // 0.5 second cooldown
            attackRange: 1.0
        )

        combat.performAttack()
        XCTAssertFalse(combat.canAttack())
    }

    // MARK: - Player Entity Tests

    func testPlayerCreation() {
        let player = Player(characterClass: .warrior)

        XCTAssertEqual(player.characterClass, .warrior)
        XCTAssertEqual(player.level, 1)
        XCTAssertEqual(player.experience, 0)
        XCTAssertEqual(player.skillPoints, 0)
        XCTAssertTrue(player.hasComponent(HealthComponent.self))
        XCTAssertTrue(player.hasComponent(CombatComponent.self))
    }

    func testWarriorStats() {
        let warrior = Player(characterClass: .warrior)

        XCTAssertEqual(warrior.stats.maxHealth, 120)
        XCTAssertEqual(warrior.stats.maxMana, 50)
        XCTAssertEqual(warrior.stats.strength, 15)
        XCTAssertEqual(warrior.stats.intelligence, 5)
    }

    func testMageStats() {
        let mage = Player(characterClass: .mage)

        XCTAssertEqual(mage.stats.maxHealth, 80)
        XCTAssertEqual(mage.stats.maxMana, 150)
        XCTAssertEqual(mage.stats.strength, 5)
        XCTAssertEqual(mage.stats.intelligence, 18)
    }

    func testRogueStats() {
        let rogue = Player(characterClass: .rogue)

        XCTAssertEqual(rogue.stats.maxHealth, 90)
        XCTAssertEqual(rogue.stats.maxMana, 80)
        XCTAssertEqual(rogue.stats.dexterity, 16)
    }

    func testRangerStats() {
        let ranger = Player(characterClass: .ranger)

        XCTAssertEqual(ranger.stats.maxHealth, 100)
        XCTAssertEqual(ranger.stats.maxMana, 100)
        XCTAssertEqual(ranger.stats.strength, 10)
        XCTAssertEqual(ranger.stats.dexterity, 14)
    }

    // MARK: - Enemy Entity Tests

    func testEnemyCreation() {
        let enemy = Enemy(enemyType: .goblin)

        XCTAssertEqual(enemy.enemyType, .goblin)
        XCTAssertTrue(enemy.hasComponent(HealthComponent.self))
        XCTAssertTrue(enemy.hasComponent(CombatComponent.self))
        XCTAssertTrue(enemy.hasComponent(AIComponent.self))
    }

    func testGoblinStats() {
        let goblin = Enemy(enemyType: .goblin)
        let health = goblin.getComponent(HealthComponent.self)

        XCTAssertEqual(health?.maximum, 30)
    }

    func testOrcStats() {
        let orc = Enemy(enemyType: .orc)
        let health = orc.getComponent(HealthComponent.self)

        XCTAssertEqual(health?.maximum, 60)
    }

    // MARK: - Inventory Tests

    func testInventoryCreation() {
        let inventory = Inventory()

        XCTAssertEqual(inventory.items.count, 0)
        XCTAssertEqual(inventory.maxSlots, 50)
    }

    func testAddItemToInventory() {
        let inventory = Inventory()
        let item = InventoryItem(
            id: UUID(),
            name: "Health Potion",
            description: "Restores 50 HP",
            rarity: .common,
            stackable: true,
            quantity: 1
        )

        let success = inventory.add(item)

        XCTAssertTrue(success)
        XCTAssertEqual(inventory.items.count, 1)
    }

    func testInventoryFullPreventsAdd() {
        let inventory = Inventory()

        // Fill inventory
        for i in 0..<50 {
            let item = InventoryItem(
                id: UUID(),
                name: "Item \(i)",
                description: "Test item",
                rarity: .common,
                stackable: false,
                quantity: 1
            )
            _ = inventory.add(item)
        }

        // Try to add one more
        let extraItem = InventoryItem(
            id: UUID(),
            name: "Extra",
            description: "Should fail",
            rarity: .common,
            stackable: false,
            quantity: 1
        )

        let success = inventory.add(extraItem)

        XCTAssertFalse(success)
        XCTAssertEqual(inventory.items.count, 50)
    }

    func testRemoveItemFromInventory() {
        let inventory = Inventory()
        let item = InventoryItem(
            id: UUID(),
            name: "Test Item",
            description: "Test",
            rarity: .common,
            stackable: false,
            quantity: 1
        )
        _ = inventory.add(item)

        inventory.remove(at: 0)

        XCTAssertEqual(inventory.items.count, 0)
    }
}
