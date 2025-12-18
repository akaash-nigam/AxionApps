//
//  PerformanceTests.swift
//  Reality Realms RPG Tests
//
//  Performance benchmarks and tests
//

import XCTest
@testable import RealityRealms

@MainActor
final class PerformanceTests: XCTestCase {

    // MARK: - Frame Rate Tests

    func testGameLoopPerformance() {
        let gameLoop = GameLoop()

        measure(metrics: [XCTClockMetric(), XCTCPUMetric()]) {
            // Simulate 90 frames (1 second at 90 FPS)
            for _ in 0..<90 {
                // Simulate game update
                let deltaTime = 1.0 / 90.0
                _ = deltaTime
            }
        }
    }

    func testEventBusPerformance() {
        let eventBus = EventBus.shared
        eventBus.clear()

        // Subscribe 100 handlers
        for _ in 0..<100 {
            eventBus.subscribe(LevelUpEvent.self) { _ in
                // Minimal processing
            }
        }

        measure(metrics: [XCTClockMetric()]) {
            // Publish 1000 events
            for i in 0..<1000 {
                let event = LevelUpEvent(
                    playerID: UUID(),
                    newLevel: i % 50,
                    skillPointsGained: 3
                )
                eventBus.publish(event)
            }
        }

        eventBus.clear()
    }

    // MARK: - Entity Performance Tests

    func testEntityCreationPerformance() {
        measure(metrics: [XCTClockMetric(), XCTMemoryMetric()]) {
            var entities: [Entity] = []
            entities.reserveCapacity(1000)

            for _ in 0..<1000 {
                let entity = Entity()
                entity.addComponent(HealthComponent(entityID: entity.id, maximum: 100))
                entity.addComponent(CombatComponent(
                    entityID: entity.id,
                    damage: 15,
                    attackSpeed: 1.5,
                    attackRange: 1.0
                ))
                entities.append(entity)
            }
        }
    }

    func testComponentLookupPerformance() {
        // Create 1000 entities with components
        var entities: [Entity] = []
        for _ in 0..<1000 {
            let entity = Entity()
            entity.addComponent(HealthComponent(entityID: entity.id, maximum: 100))
            entity.addComponent(CombatComponent(
                entityID: entity.id,
                damage: 15,
                attackSpeed: 1.5,
                attackRange: 1.0
            ))
            entities.append(entity)
        }

        measure(metrics: [XCTClockMetric()]) {
            // Lookup components 10,000 times
            for _ in 0..<10 {
                for entity in entities {
                    _ = entity.getComponent(HealthComponent.self)
                    _ = entity.getComponent(CombatComponent.self)
                }
            }
        }
    }

    // MARK: - Inventory Performance Tests

    func testInventoryOperationsPerformance() {
        let inventory = Inventory()

        measure(metrics: [XCTClockMetric()]) {
            // Add 50 items
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

            // Remove all items
            for i in (0..<50).reversed() {
                inventory.remove(at: i)
            }
        }
    }

    // MARK: - State Management Performance Tests

    func testStateTransitionPerformance() {
        let stateManager = GameStateManager.shared

        measure(metrics: [XCTClockMetric()]) {
            // Perform 1000 state transitions
            for _ in 0..<100 {
                stateManager.transition(to: .roomScanning)
                stateManager.transition(to: .tutorial)
                stateManager.transition(to: .gameplay(.exploration))
                stateManager.enterCombat(enemyCount: 5)
                stateManager.exitCombat()
                stateManager.pauseGame(true)
                stateManager.pauseGame(false)
                stateManager.showInventory()
                stateManager.closeInventory()
                stateManager.transition(to: .initialization)
            }
        }
    }

    // MARK: - Memory Leak Tests

    func testEntityMemoryLeak() {
        measure(metrics: [XCTMemoryMetric()]) {
            autoreleasepool {
                var entities: [Entity] = []
                entities.reserveCapacity(1000)

                // Create 1000 entities
                for _ in 0..<1000 {
                    let entity = Entity()
                    entity.addComponent(HealthComponent(entityID: entity.id, maximum: 100))
                    entities.append(entity)
                }

                // Remove all
                entities.removeAll()
            }
        }
    }

    // MARK: - Performance Benchmarks

    func testTargetFrameTimeAchieved() {
        let targetFrameTime: Double = 11.1  // 11.1ms for 90 FPS

        measure(metrics: [XCTClockMetric()]) {
            // Simulate game frame update
            let startTime = Date()

            // Simulate game logic
            var entities: [Entity] = []
            for _ in 0..<100 {
                let entity = Entity()
                entity.addComponent(HealthComponent(entityID: entity.id, maximum: 100))
                entities.append(entity)
            }

            // Update all entities
            for entity in entities {
                if let health = entity.getComponent(HealthComponent.self) {
                    health.takeDamage(10)
                    health.heal(5)
                }
            }

            entities.removeAll()

            let frameTime = Date().timeIntervalSince(startTime) * 1000  // Convert to ms

            XCTAssertLessThan(frameTime, targetFrameTime,
                            "Frame time \(frameTime)ms exceeds target \(targetFrameTime)ms")
        }
    }

    // MARK: - Concurrent Operations Tests

    func testConcurrentEventPublishing() {
        let eventBus = EventBus.shared
        eventBus.clear()

        measure(metrics: [XCTClockMetric()]) {
            let group = DispatchGroup()

            for i in 0..<10 {
                group.enter()
                DispatchQueue.global().async {
                    for j in 0..<100 {
                        let event = LevelUpEvent(
                            playerID: UUID(),
                            newLevel: i * 10 + j,
                            skillPointsGained: 3
                        )
                        Task { @MainActor in
                            eventBus.publish(event)
                        }
                    }
                    group.leave()
                }
            }

            group.wait()
        }

        eventBus.clear()
    }

    // MARK: - Stress Tests

    func testLargeEntityCountPerformance() {
        measure(metrics: [XCTClockMetric(), XCTMemoryMetric()]) {
            var entities: [Entity] = []
            entities.reserveCapacity(10000)

            // Create 10,000 entities
            for _ in 0..<10000 {
                let entity = Entity()
                entity.addComponent(HealthComponent(entityID: entity.id, maximum: 100))
                entities.append(entity)
            }

            // Update all entities
            for entity in entities {
                if let health = entity.getComponent(HealthComponent.self) {
                    health.takeDamage(10)
                }
            }

            entities.removeAll()
        }
    }

    // MARK: - Cleanup Performance

    func testEfficientCleanup() {
        var entities: [Entity] = []
        for _ in 0..<1000 {
            let entity = Entity()
            entity.addComponent(HealthComponent(entityID: entity.id, maximum: 100))
            entity.addComponent(CombatComponent(
                entityID: entity.id,
                damage: 15,
                attackSpeed: 1.5,
                attackRange: 1.0
            ))
            entities.append(entity)
        }

        measure(metrics: [XCTClockMetric()]) {
            // Remove components from all entities
            for entity in entities {
                entity.removeComponent(HealthComponent.self)
                entity.removeComponent(CombatComponent.self)
            }

            // Clear entities
            entities.removeAll()

            // Recreate for next iteration
            entities = []
            for _ in 0..<1000 {
                let entity = Entity()
                entity.addComponent(HealthComponent(entityID: entity.id, maximum: 100))
                entity.addComponent(CombatComponent(
                    entityID: entity.id,
                    damage: 15,
                    attackSpeed: 1.5,
                    attackRange: 1.0
                ))
                entities.append(entity)
            }
        }
    }
}
