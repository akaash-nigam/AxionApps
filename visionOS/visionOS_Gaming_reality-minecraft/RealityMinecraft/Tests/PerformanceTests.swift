//
//  PerformanceTests.swift
//  Reality Minecraft Performance Tests
//
//  Comprehensive performance benchmarks
//  ⚠️ REQUIRES XCODE TO RUN
//

import XCTest
@testable import Reality_Minecraft

final class PerformanceTests: XCTestCase {

    // MARK: - Block System Performance

    func testChunkCreationPerformance() {
        measure {
            let manager = ChunkManager()
            for x in -10...10 {
                for z in -10...10 {
                    _ = manager.getOrCreateChunk(at: ChunkPosition(x: x, y: 0, z: z))
                }
            }
        }
    }

    func testBlockAccessPerformance() {
        let manager = ChunkManager()
        let chunk = manager.getOrCreateChunk(at: ChunkPosition(x: 0, y: 0, z: 0))

        // Fill chunk with blocks
        for x in 0..<Chunk.CHUNK_SIZE {
            for y in 0..<Chunk.CHUNK_SIZE {
                for z in 0..<Chunk.CHUNK_SIZE {
                    let pos = BlockPosition(x: x, y: y, z: z)
                    chunk.setBlock(at: pos, block: Block(position: pos, type: .stone))
                }
            }
        }

        measure {
            for _ in 0..<10000 {
                let x = Int.random(in: 0..<Chunk.CHUNK_SIZE)
                let y = Int.random(in: 0..<Chunk.CHUNK_SIZE)
                let z = Int.random(in: 0..<Chunk.CHUNK_SIZE)
                _ = chunk.getBlock(at: BlockPosition(x: x, y: y, z: z))
            }
        }
    }

    func testChunkFillingPerformance() {
        measure {
            let chunk = Chunk(position: ChunkPosition(x: 0, y: 0, z: 0))
            for x in 0..<Chunk.CHUNK_SIZE {
                for y in 0..<Chunk.CHUNK_SIZE {
                    for z in 0..<Chunk.CHUNK_SIZE {
                        let pos = BlockPosition(x: x, y: y, z: z)
                        chunk.setBlock(at: pos, block: Block(position: pos, type: .dirt))
                    }
                }
            }
        }
    }

    func testMultipleChunkOperations() {
        let manager = ChunkManager()

        measure {
            // Create chunks
            for x in -5...5 {
                for z in -5...5 {
                    let chunk = manager.getOrCreateChunk(at: ChunkPosition(x: x, y: 0, z: z))

                    // Set random blocks
                    for _ in 0..<100 {
                        let localX = Int.random(in: 0..<Chunk.CHUNK_SIZE)
                        let localY = Int.random(in: 0..<Chunk.CHUNK_SIZE)
                        let localZ = Int.random(in: 0..<Chunk.CHUNK_SIZE)
                        let pos = BlockPosition(x: localX, y: localY, z: localZ)
                        chunk.setBlock(at: pos, block: Block(position: pos, type: .grass))
                    }
                }
            }
        }
    }

    // MARK: - Entity System Performance

    func testEntityCreationPerformance() {
        let manager = EntityManager(eventBus: EventBus())

        measure {
            for _ in 0..<1000 {
                let entity = manager.createEntity()
                entity.addComponent(HealthComponent(maxHealth: 20))
                entity.addComponent(VelocityComponent())
                manager.addEntity(entity)
            }
            manager.removeAllEntities()
        }
    }

    func testEntityQueryPerformance() {
        let manager = EntityManager(eventBus: EventBus())

        // Create 1000 entities with various components
        for _ in 0..<1000 {
            let entity = manager.createEntity()
            entity.addComponent(HealthComponent(maxHealth: 20))
            if Bool.random() {
                entity.addComponent(PlayerComponent())
            }
            if Bool.random() {
                entity.addComponent(VelocityComponent())
            }
            manager.addEntity(entity)
        }

        measure {
            _ = manager.getEntitiesWithComponent(HealthComponent.self)
            _ = manager.getEntitiesWithComponent(PlayerComponent.self)
            _ = manager.getEntitiesWithComponent(VelocityComponent.self)
        }
    }

    func testEntityUpdatePerformance() {
        let manager = EntityManager(eventBus: EventBus())

        for _ in 0..<1000 {
            let entity = manager.createEntity()
            entity.addComponent(VelocityComponent())
            manager.addEntity(entity)
        }

        measure {
            manager.update(deltaTime: 0.016) // 60 FPS
        }
    }

    func testComponentAddRemovePerformance() {
        let manager = EntityManager(eventBus: EventBus())
        let entities = (0..<100).map { _ in manager.createEntity() }

        measure {
            for entity in entities {
                entity.addComponent(HealthComponent(maxHealth: 20))
                entity.addComponent(VelocityComponent())
                entity.addComponent(PlayerComponent())
            }

            for entity in entities {
                entity.removeComponent(HealthComponent.self)
                entity.removeComponent(VelocityComponent.self)
                entity.removeComponent(PlayerComponent.self)
            }
        }
    }

    // MARK: - Inventory Performance

    func testInventoryOperationsPerformance() {
        measure {
            let inventory = Inventory(maxSlots: 36)

            // Add items
            for _ in 0..<100 {
                inventory.addItem("dirt", quantity: 64)
                inventory.addItem("stone", quantity: 64)
                inventory.addItem("cobblestone", quantity: 64)
            }

            // Check items
            for _ in 0..<100 {
                _ = inventory.hasItem("dirt", quantity: 10)
                _ = inventory.getItemQuantity("stone")
            }

            // Remove items
            for _ in 0..<100 {
                inventory.removeItem("dirt", quantity: 5)
            }
        }
    }

    func testInventoryStackingPerformance() {
        let inventory = Inventory(maxSlots: 36)

        measure {
            // Test stacking behavior with max stack size
            for _ in 0..<1000 {
                inventory.addItem("dirt", quantity: 1)
            }

            // Clear inventory
            for slot in inventory.slots where !slot.isEmpty {
                inventory.removeItem(slot.itemType!, quantity: slot.quantity)
            }
        }
    }

    // MARK: - Crafting Performance

    func testRecipeMatchingPerformance() {
        let manager = CraftingManager()

        let grids: [[[String?]]] = [
            [["oak_log"]],
            [["oak_planks"], ["oak_planks"]],
            [["oak_planks", "oak_planks", "oak_planks"],
             ["", "stick", ""],
             ["", "stick", ""]],
            [["cobblestone", "cobblestone", "cobblestone"],
             ["", "stick", ""],
             ["", "stick", ""]]
        ]

        measure {
            for _ in 0..<1000 {
                for grid in grids {
                    _ = manager.findMatchingRecipe(grid: grid)
                }
            }
        }
    }

    func testCraftingOperationsPerformance() {
        let manager = CraftingManager()
        let inventory = Inventory(maxSlots: 36)
        inventory.addItem("oak_log", quantity: 64)
        inventory.addItem("oak_planks", quantity: 64)
        inventory.addItem("stick", quantity: 64)
        inventory.addItem("cobblestone", quantity: 64)

        measure {
            // Craft various items
            _ = manager.craft(grid: [["oak_log"]], inventory: inventory)
            _ = manager.craft(grid: [["oak_planks"], ["oak_planks"]], inventory: inventory)
            _ = manager.craft(grid: [["stick"], ["stick"], ["cobblestone"]], inventory: inventory)
        }
    }

    func testAvailableRecipesPerformance() {
        let manager = CraftingManager()
        let inventory = Inventory(maxSlots: 36)

        // Add all material types
        inventory.addItem("oak_log", quantity: 64)
        inventory.addItem("oak_planks", quantity: 64)
        inventory.addItem("stick", quantity: 64)
        inventory.addItem("cobblestone", quantity: 64)
        inventory.addItem("coal", quantity: 64)

        measure {
            for _ in 0..<100 {
                _ = manager.getAvailableRecipes(inventory: inventory)
            }
        }
    }

    // MARK: - Physics Performance

    func testPhysicsUpdatePerformance() {
        let physics = PhysicsSystem()

        // Create 100 rigid bodies
        for _ in 0..<100 {
            let body = RigidBody(
                position: SIMD3<Float>(
                    Float.random(in: -10...10),
                    Float.random(in: 0...20),
                    Float.random(in: -10...10)
                ),
                mass: 1.0
            )
            physics.addRigidBody(body)
        }

        measure {
            for _ in 0..<60 { // Simulate 1 second at 60 FPS
                physics.update(deltaTime: 0.016)
            }
        }
    }

    func testCollisionDetectionPerformance() {
        let physics = PhysicsSystem()

        // Create many AABBs
        let aabbs = (0..<200).map { _ in
            AABB(
                min: SIMD3<Float>(
                    Float.random(in: -20...20),
                    Float.random(in: -20...20),
                    Float.random(in: -20...20)
                ),
                max: SIMD3<Float>(
                    Float.random(in: -20...20),
                    Float.random(in: -20...20),
                    Float.random(in: -20...20)
                )
            )
        }

        measure {
            for i in 0..<aabbs.count {
                for j in (i+1)..<aabbs.count {
                    _ = physics.checkCollision(aabbs[i], aabbs[j])
                }
            }
        }
    }

    // MARK: - Event System Performance

    func testEventPublishPerformance() {
        let eventBus = EventBus()

        // Subscribe multiple handlers
        for _ in 0..<10 {
            eventBus.subscribe(to: BlockPlacementEvent.self) { _ in
                // Handler
            }
        }

        measure {
            for _ in 0..<1000 {
                let event = BlockPlacementEvent(position: BlockPosition(x: 0, y: 0, z: 0))
                eventBus.publish(event)
            }
        }
    }

    func testMultipleEventTypesPerformance() {
        let eventBus = EventBus()

        eventBus.subscribe(to: BlockPlacementEvent.self) { _ in }
        eventBus.subscribe(to: GameStateChangedEvent.self) { _ in }
        eventBus.subscribe(to: PlayerDamagedEvent.self) { _ in }

        measure {
            for _ in 0..<1000 {
                eventBus.publish(BlockPlacementEvent(position: BlockPosition(x: 0, y: 0, z: 0)))
                eventBus.publish(GameStateChangedEvent(oldState: .mainMenu, newState: .playing(mode: .creative)))
                eventBus.publish(PlayerDamagedEvent(damage: 5.0, source: "fall"))
            }
        }
    }

    // MARK: - World Persistence Performance

    func testWorldSavePerformance() async throws {
        let persistence = WorldPersistenceManager()
        var world = WorldData.createNew(name: "Performance Test World")

        // Add some complexity
        for _ in 0..<10 {
            world.worldAnchors.append(WorldAnchorData(
                id: UUID(),
                transform: CodableTransform(
                    position: SIMD3<Float>(0, 0, 0),
                    rotation: CodableQuaternion(simd_quatf(angle: 0, axis: SIMD3<Float>(0, 1, 0))),
                    scale: SIMD3<Float>(1, 1, 1)
                ),
                associatedChunks: []
            ))
        }

        // Add items to inventory
        world.playerData.inventory.addItem("dirt", quantity: 64)
        world.playerData.inventory.addItem("stone", quantity: 64)

        measure {
            Task {
                try? await persistence.saveWorld(world)
            }
        }

        // Cleanup
        try? persistence.deleteWorld(id: world.id)
    }

    func testWorldLoadPerformance() async throws {
        let persistence = WorldPersistenceManager()
        var world = WorldData.createNew(name: "Load Test World")

        // Create complex world
        for _ in 0..<10 {
            world.worldAnchors.append(WorldAnchorData(
                id: UUID(),
                transform: CodableTransform(
                    position: SIMD3<Float>(0, 0, 0),
                    rotation: CodableQuaternion(simd_quatf(angle: 0, axis: SIMD3<Float>(0, 1, 0))),
                    scale: SIMD3<Float>(1, 1, 1)
                ),
                associatedChunks: []
            ))
        }

        try await persistence.saveWorld(world)

        measure {
            Task {
                _ = try? await persistence.loadWorld(id: world.id)
            }
        }

        // Cleanup
        try? persistence.deleteWorld(id: world.id)
    }

    func testWorldListPerformance() throws {
        let persistence = WorldPersistenceManager()

        // Create multiple worlds
        var worldIDs: [UUID] = []
        for i in 0..<20 {
            let world = WorldData.createNew(name: "Test World \(i)")
            try await persistence.saveWorld(world)
            worldIDs.append(world.id)
        }

        measure {
            _ = try? persistence.listWorlds()
        }

        // Cleanup
        for id in worldIDs {
            try? persistence.deleteWorld(id: id)
        }
    }

    // MARK: - Game State Performance

    func testStateTransitionPerformance() {
        let manager = GameStateManager()

        measure {
            for _ in 0..<1000 {
                manager.transitionTo(.mainMenu)
                manager.transitionTo(.loading(progress: 0.5))
                manager.transitionTo(.playing(mode: .creative))
                manager.transitionTo(.paused)
                manager.resume()
            }
        }
    }

    // MARK: - Memory Performance

    func testMemoryUsageChunks() {
        measure(metrics: [XCTMemoryMetric()]) {
            let manager = ChunkManager()

            // Create 100 chunks
            for x in -5...5 {
                for z in -5...5 {
                    let chunk = manager.getOrCreateChunk(at: ChunkPosition(x: x, y: 0, z: z))

                    // Fill each chunk
                    for lx in 0..<Chunk.CHUNK_SIZE {
                        for ly in 0..<Chunk.CHUNK_SIZE {
                            for lz in 0..<Chunk.CHUNK_SIZE {
                                let pos = BlockPosition(x: lx, y: ly, z: lz)
                                chunk.setBlock(at: pos, block: Block(position: pos, type: .stone))
                            }
                        }
                    }
                }
            }
        }
    }

    func testMemoryUsageEntities() {
        measure(metrics: [XCTMemoryMetric()]) {
            let manager = EntityManager(eventBus: EventBus())

            // Create 1000 entities
            for _ in 0..<1000 {
                let entity = manager.createEntity()
                entity.addComponent(PlayerComponent())
                entity.addComponent(HealthComponent(maxHealth: 20))
                entity.addComponent(VelocityComponent())
                manager.addEntity(entity)
            }
        }
    }

    // MARK: - Combined System Performance

    func testFullGameLoopSimulation() {
        let gameState = GameStateManager()
        let entityManager = EntityManager(eventBus: gameState.eventBus)
        let chunkManager = ChunkManager()
        let physics = PhysicsSystem()

        // Setup game world
        gameState.transitionTo(.playing(mode: .creative))

        // Create player
        let player = entityManager.createEntity()
        player.addComponent(PlayerComponent())
        player.addComponent(HealthComponent(maxHealth: 20))
        player.addComponent(VelocityComponent())
        entityManager.addEntity(player)

        // Create some mobs
        for _ in 0..<10 {
            let mob = entityManager.createEntity()
            mob.addComponent(MobComponent(type: .zombie))
            mob.addComponent(HealthComponent(maxHealth: 20))
            mob.addComponent(VelocityComponent())
            entityManager.addEntity(mob)
        }

        // Create chunks
        for x in -2...2 {
            for z in -2...2 {
                _ = chunkManager.getOrCreateChunk(at: ChunkPosition(x: x, y: 0, z: z))
            }
        }

        // Simulate game loop
        measure {
            for _ in 0..<90 { // 1 second at 90 FPS
                entityManager.update(deltaTime: 0.011) // ~90 FPS
                physics.update(deltaTime: 0.011)
            }
        }
    }

    func testHighEntityCountScenario() {
        let manager = EntityManager(eventBus: EventBus())
        let physics = PhysicsSystem()

        // Create 500 entities (high load scenario)
        for _ in 0..<500 {
            let entity = manager.createEntity()
            entity.addComponent(MobComponent(type: .zombie))
            entity.addComponent(HealthComponent(maxHealth: 20))
            entity.addComponent(VelocityComponent())
            manager.addEntity(entity)

            let body = RigidBody(
                position: SIMD3<Float>(
                    Float.random(in: -50...50),
                    Float.random(in: 0...10),
                    Float.random(in: -50...50)
                ),
                mass: 1.0
            )
            physics.addRigidBody(body)
        }

        measure {
            for _ in 0..<60 { // 1 second at 60 FPS
                manager.update(deltaTime: 0.016)
                physics.update(deltaTime: 0.016)
            }
        }
    }

    // MARK: - Frame Time Consistency

    func testFrameTimeConsistency90FPS() {
        let gameLoop = GameLoopController(gameStateManager: GameStateManager())
        let entityManager = EntityManager(eventBus: EventBus())

        // Create moderate load
        for _ in 0..<100 {
            let entity = entityManager.createEntity()
            entity.addComponent(HealthComponent(maxHealth: 20))
            entityManager.addEntity(entity)
        }

        measure {
            // Simulate maintaining 90 FPS
            for _ in 0..<90 {
                let startTime = Date()

                entityManager.update(deltaTime: 0.011)

                let elapsed = Date().timeIntervalSince(startTime)
                // Each frame should complete in < 11ms for 90 FPS
                XCTAssertLessThan(elapsed, 0.011)
            }
        }
    }
}
