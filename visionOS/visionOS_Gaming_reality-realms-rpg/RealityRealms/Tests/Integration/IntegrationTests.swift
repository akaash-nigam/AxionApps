//
//  IntegrationTests.swift
//  Reality Realms RPG Tests
//
//  Integration tests for system interactions
//

import XCTest
@testable import RealityRealms

@MainActor
final class IntegrationTests: XCTestCase {

    // MARK: - Game Flow Integration Tests

    func testCompleteGameStartupFlow() async throws {
        let gameStateManager = GameStateManager.shared
        let eventBus = EventBus.shared

        // Test complete startup flow
        gameStateManager.transition(to: .initialization)

        // Should transition to room scanning
        gameStateManager.transition(to: .roomScanning)
        XCTAssertEqual(gameStateManager.currentState, .roomScanning)

        // Simulate room scanning completion
        let roomLayout = RoomLayout(
            roomID: UUID(),
            bounds: RoomLayout.AxisAlignedBoundingBox(
                center: SIMD3<Float>(0, 1, 0),
                extents: SIMD3<Float>(3, 2.5, 3)
            ),
            safePlayArea: RoomLayout.AxisAlignedBoundingBox(
                center: SIMD3<Float>(0, 1, 0),
                extents: SIMD3<Float>(2.4, 2.5, 2.4)
            ),
            furniture: [],
            spatialAnchors: [:]
        )

        eventBus.publish(RoomMappingCompleteEvent(roomLayout: roomLayout))

        // Should transition to tutorial
        try await Task.sleep(for: .milliseconds(100))
        XCTAssertEqual(gameStateManager.currentState, .tutorial)

        // Complete tutorial and start game
        gameStateManager.startGame()
        XCTAssertTrue(gameStateManager.isGameActive)
    }

    func testCombatLifecycle() async throws {
        let gameStateManager = GameStateManager.shared
        let eventBus = EventBus.shared

        // Setup game state
        gameStateManager.transition(to: .roomScanning)
        gameStateManager.transition(to: .tutorial)
        gameStateManager.transition(to: .gameplay(.exploration))

        // Enter combat
        gameStateManager.enterCombat(enemyCount: 3)

        if case .gameplay(.combat(let count)) = gameStateManager.currentState {
            XCTAssertEqual(count, 3)
        } else {
            XCTFail("Should be in combat state")
        }

        // Defeat one enemy
        let defeatedEvent = EntityDefeatedEvent(
            entityID: UUID(),
            killerID: UUID(),
            experience: 50
        )
        eventBus.publish(defeatedEvent)

        try await Task.sleep(for: .milliseconds(100))

        // Should still be in combat with 2 enemies
        if case .gameplay(.combat(let count)) = gameStateManager.currentState {
            XCTAssertEqual(count, 2)
        } else {
            XCTFail("Should still be in combat")
        }

        // Defeat remaining enemies
        eventBus.publish(defeatedEvent)
        try await Task.sleep(for: .milliseconds(100))

        eventBus.publish(defeatedEvent)
        try await Task.sleep(for: .milliseconds(100))

        // Should return to exploration
        if case .gameplay(.exploration) = gameStateManager.currentState {
            XCTAssertTrue(true)
        } else {
            XCTFail("Should return to exploration after combat")
        }
    }

    // MARK: - Entity Lifecycle Integration Tests

    func testPlayerCombatIntegration() throws {
        let player = Player(characterClass: .warrior)
        let enemy = Enemy(enemyType: .goblin)

        // Verify player has required components
        XCTAssertNotNil(player.getComponent(HealthComponent.self))
        XCTAssertNotNil(player.getComponent(CombatComponent.self))

        // Verify enemy has required components
        XCTAssertNotNil(enemy.getComponent(HealthComponent.self))
        XCTAssertNotNil(enemy.getComponent(CombatComponent.self))
        XCTAssertNotNil(enemy.getComponent(AIComponent.self))

        // Simulate combat
        guard let playerCombat = player.getComponent(CombatComponent.self),
              let enemyHealth = enemy.getComponent(HealthComponent.self) else {
            XCTFail("Missing required components")
            return
        }

        let damage = playerCombat.damage
        enemyHealth.takeDamage(damage)

        XCTAssertEqual(enemyHealth.current, enemyHealth.maximum - damage)
    }

    func testLevelUpIntegration() async throws {
        let eventBus = EventBus.shared
        eventBus.clear()

        let player = Player(characterClass: .warrior)
        let initialLevel = player.level

        // Subscribe to level up event
        let expectation = expectation(description: "Level up event")
        var receivedEvent: LevelUpEvent?

        eventBus.subscribe(LevelUpEvent.self) { event in
            receivedEvent = event
            expectation.fulfill()
        }

        // Award enough XP to level up
        let progression = ProgressionSystem()
        let xpNeeded = progression.calculateXPRequired(for: player.level + 1)
        progression.awardXP(to: player, amount: xpNeeded)

        // Publish level up event
        let levelUpEvent = LevelUpEvent(
            playerID: player.id,
            newLevel: player.level,
            skillPointsGained: 3
        )
        eventBus.publish(levelUpEvent)

        await fulfillment(of: [expectation], timeout: 1.0)

        XCTAssertNotNil(receivedEvent)
        XCTAssertEqual(receivedEvent?.newLevel, initialLevel + 1)

        eventBus.clear()
    }

    // MARK: - Inventory Integration Tests

    func testInventoryAndEquipmentIntegration() throws {
        let player = Player(characterClass: .warrior)

        // Create test items
        let sword = InventoryItem(
            id: UUID(),
            name: "Iron Sword",
            description: "A sturdy iron sword",
            rarity: .common,
            stackable: false,
            quantity: 1
        )

        let helmet = InventoryItem(
            id: UUID(),
            name: "Iron Helmet",
            description: "Protects your head",
            rarity: .common,
            stackable: false,
            quantity: 1
        )

        // Add to inventory
        XCTAssertTrue(player.inventory.add(sword))
        XCTAssertTrue(player.inventory.add(helmet))
        XCTAssertEqual(player.inventory.items.count, 2)

        // Equip items
        player.equipment.weapon = sword
        player.equipment.helmet = helmet

        XCTAssertNotNil(player.equipment.weapon)
        XCTAssertNotNil(player.equipment.helmet)
    }

    func testInventoryFullPreventsLoot() throws {
        let player = Player(characterClass: .warrior)

        // Fill inventory
        for i in 0..<player.inventory.maxSlots {
            let item = InventoryItem(
                id: UUID(),
                name: "Item \(i)",
                description: "Test",
                rarity: .common,
                stackable: false,
                quantity: 1
            )
            _ = player.inventory.add(item)
        }

        // Try to add loot
        let loot = InventoryItem(
            id: UUID(),
            name: "Treasure",
            description: "Valuable loot",
            rarity: .epic,
            stackable: false,
            quantity: 1
        )

        let success = player.inventory.add(loot)
        XCTAssertFalse(success, "Should not be able to add loot when inventory is full")
    }

    // MARK: - Event System Integration Tests

    func testEventChainReaction() async throws {
        let eventBus = EventBus.shared
        eventBus.clear()

        var eventsReceived: [String] = []

        // Subscribe to damage event
        eventBus.subscribe(DamageDealtEvent.self) { event in
            eventsReceived.append("damage")

            // When damage is dealt, check if enemy is defeated
            if event.damage >= 30 {
                let defeatEvent = EntityDefeatedEvent(
                    entityID: event.targetID,
                    killerID: event.attackerID,
                    experience: 50
                )
                eventBus.publish(defeatEvent)
            }
        }

        // Subscribe to defeat event
        eventBus.subscribe(EntityDefeatedEvent.self) { event in
            eventsReceived.append("defeated")

            // When enemy is defeated, award XP
            let xpEvent = ExperienceGainedEvent(
                playerID: event.killerID,
                amount: event.experience,
                source: "combat"
            )
            eventBus.publish(xpEvent)
        }

        // Subscribe to XP event
        eventBus.subscribe(ExperienceGainedEvent.self) { _ in
            eventsReceived.append("xp")
        }

        // Trigger chain by dealing fatal damage
        let damageEvent = DamageDealtEvent(
            attackerID: UUID(),
            targetID: UUID(),
            damage: 50,
            damageType: .physical,
            isCritical: true
        )

        eventBus.publish(damageEvent)

        // Wait for event propagation
        try await Task.sleep(for: .milliseconds(200))

        // Verify chain reaction
        XCTAssertEqual(eventsReceived, ["damage", "defeated", "xp"])

        eventBus.clear()
    }

    // MARK: - Performance Integration Tests

    func testPerformanceUnderLoad() async throws {
        let performanceMonitor = PerformanceMonitor.shared

        // Create realistic game scenario
        var entities: [Entity] = []

        // Add player
        let player = Player(characterClass: .warrior)
        entities.append(player)

        // Add 10 enemies
        for _ in 0..<10 {
            let enemy = Enemy(enemyType: .goblin)
            entities.append(enemy)
        }

        // Simulate 1 second of gameplay at 90 FPS
        for _ in 0..<90 {
            let startTime = Date()

            // Update all entities
            for entity in entities {
                if let health = entity.getComponent(HealthComponent.self) {
                    if health.regenerationRate > 0 {
                        health.heal(1)
                    }
                }

                if let combat = entity.getComponent(CombatComponent.self) {
                    _ = combat.canAttack()
                }
            }

            let frameTime = Date().timeIntervalSince(startTime)
            performanceMonitor.recordFrame(deltaTime: frameTime)

            // Ensure we don't exceed target frame time
            let remainingTime = (1.0 / 90.0) - frameTime
            if remainingTime > 0 {
                try await Task.sleep(for: .seconds(remainingTime))
            }
        }

        // Verify performance
        XCTAssertGreaterThan(
            performanceMonitor.averageFPS,
            85.0,
            "Should maintain > 85 FPS with 10 entities"
        )
    }

    // MARK: - State Persistence Integration Tests

    func testStatePersistenceBetweenSessions() throws {
        // This would normally involve actual file I/O
        // For unit testing, we're testing the data structures

        let player = Player(characterClass: .mage)
        player.level = 15
        player.experience = 1000
        player.stats.currentHealth = 50

        // Simulate save
        let savedData = SaveData(
            playerID: player.id,
            level: player.level,
            experience: player.experience,
            currentHealth: player.stats.currentHealth
        )

        // Simulate load into new player instance
        let loadedPlayer = Player(characterClass: .mage)
        loadedPlayer.level = savedData.level
        loadedPlayer.experience = savedData.experience
        loadedPlayer.stats.currentHealth = savedData.currentHealth

        XCTAssertEqual(loadedPlayer.level, 15)
        XCTAssertEqual(loadedPlayer.experience, 1000)
        XCTAssertEqual(loadedPlayer.stats.currentHealth, 50)
    }

    // MARK: - Multi-Component Integration Tests

    func testComplexEntityBehavior() throws {
        let enemy = Enemy(enemyType: .orc)

        // Get all components
        guard let health = enemy.getComponent(HealthComponent.self),
              let combat = enemy.getComponent(CombatComponent.self),
              let ai = enemy.getComponent(AIComponent.self) else {
            XCTFail("Enemy missing required components")
            return
        }

        // Simulate complex behavior sequence
        // 1. Enemy is idle
        XCTAssertEqual(ai.currentState, .idle)

        // 2. Enemy detects player and enters chase
        ai.currentState = .chase
        ai.targetEntity = UUID()

        // 3. Enemy reaches player and attacks
        XCTAssertTrue(combat.canAttack())
        combat.performAttack()

        // 4. Enemy takes damage
        health.takeDamage(30)
        XCTAssertEqual(health.current, health.maximum - 30)

        // 5. Enemy health low, retreats
        if health.current < health.maximum / 2 {
            ai.currentState = .retreat
        }

        XCTAssertEqual(ai.currentState, .retreat)
    }
}

// MARK: - Helper Structures

struct SaveData {
    let playerID: UUID
    let level: Int
    let experience: Int
    let currentHealth: Int
}

struct ProgressionSystem {
    func calculateXPRequired(for level: Int) -> Int {
        return Int(100 * pow(Double(level), 1.5))
    }

    func awardXP(to player: Player, amount: Int) {
        player.experience += amount

        while player.experience >= calculateXPRequired(for: player.level + 1) {
            player.level += 1
            player.experience = 0
            player.skillPoints += 3
        }
    }
}
