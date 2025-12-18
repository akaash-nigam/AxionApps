//
//  IntegrationTests.swift
//  Reality Minecraft Tests
//
//  Integration tests for system interactions
//  ⚠️ REQUIRES XCODE TO RUN
//

import XCTest
@testable import Reality_Minecraft

final class IntegrationTests: XCTestCase {

    var gameStateManager: GameStateManager!
    var entityManager: EntityManager!
    var chunkManager: ChunkManager!
    var eventBus: EventBus!

    override func setUp() async throws {
        try await super.setUp()

        eventBus = EventBus()
        gameStateManager = GameStateManager()
        entityManager = EntityManager(eventBus: eventBus)
        chunkManager = ChunkManager()
    }

    override func tearDown() async throws {
        gameStateManager = nil
        entityManager = nil
        chunkManager = nil
        eventBus = nil

        try await super.tearDown()
    }

    // MARK: - Game State Integration Tests

    func testGameStateTransitions() async {
        gameStateManager.transitionTo(.mainMenu)
        XCTAssertEqual(gameStateManager.currentState, .mainMenu)

        gameStateManager.transitionTo(.loading(progress: 0.5))
        if case .loading(let progress) = gameStateManager.currentState {
            XCTAssertEqual(progress, 0.5, accuracy: 0.01)
        } else {
            XCTFail("Should be in loading state")
        }

        gameStateManager.transitionTo(.playing(mode: .creative))
        if case .playing = gameStateManager.currentState {
            // Success
        } else {
            XCTFail("Should be in playing state")
        }
    }

    func testGameStatePauseResume() async {
        gameStateManager.transitionTo(.playing(mode: .creative))

        gameStateManager.pause()
        XCTAssertTrue(gameStateManager.isPaused)
        XCTAssertEqual(gameStateManager.currentState, .paused)

        gameStateManager.resume()
        XCTAssertFalse(gameStateManager.isPaused)
        if case .playing = gameStateManager.currentState {
            // Success
        } else {
            XCTFail("Should return to playing state")
        }
    }

    // MARK: - Entity System Integration Tests

    func testEntityCreationAndComponents() async {
        let entity = entityManager.createEntity()

        // Add components
        let playerComponent = PlayerComponent()
        let healthComponent = HealthComponent(maxHealth: 20)

        entity.addComponent(playerComponent)
        entity.addComponent(healthComponent)

        // Verify components
        XCTAssertTrue(entity.hasComponent(PlayerComponent.self))
        XCTAssertTrue(entity.hasComponent(HealthComponent.self))

        let retrievedPlayer: PlayerComponent? = entity.getComponent()
        XCTAssertNotNil(retrievedPlayer)
        XCTAssertEqual(retrievedPlayer?.health, 20.0)
    }

    func testEntityManagerQueries() async {
        // Create multiple entities with different components
        for _ in 0..<5 {
            let entity = entityManager.createEntity()
            entity.addComponent(PlayerComponent())
            entityManager.addEntity(entity)
        }

        for _ in 0..<10 {
            let entity = entityManager.createEntity()
            entity.addComponent(MobComponent(type: .zombie))
            entityManager.addEntity(entity)
        }

        let players = entityManager.getEntitiesWithComponent(PlayerComponent.self)
        let mobs = entityManager.getMobs()

        XCTAssertEqual(players.count, 5)
        XCTAssertEqual(mobs.count, 10)
    }

    // MARK: - Event System Integration Tests

    func testEventPublishSubscribe() async {
        let expectation = XCTestExpectation(description: "Event received")

        eventBus.subscribe(to: BlockPlacementEvent.self) { event in
            XCTAssertEqual(event.position.x, 5)
            XCTAssertEqual(event.position.y, 10)
            XCTAssertEqual(event.position.z, 15)
            expectation.fulfill()
        }

        let event = BlockPlacementEvent(position: BlockPosition(x: 5, y: 10, z: 15))
        eventBus.publish(event)

        await fulfillment(of: [expectation], timeout: 1.0)
    }

    func testMultipleEventHandlers() async {
        var handler1Called = false
        var handler2Called = false

        eventBus.subscribe(to: GameStateChangedEvent.self) { _ in
            handler1Called = true
        }

        eventBus.subscribe(to: GameStateChangedEvent.self) { _ in
            handler2Called = true
        }

        let event = GameStateChangedEvent(oldState: .mainMenu, newState: .loading(progress: 0))
        eventBus.publish(event)

        // Give time for async handlers
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 second

        XCTAssertTrue(handler1Called)
        XCTAssertTrue(handler2Called)
    }

    // MARK: - Chunk and Block Integration Tests

    func testChunkAndBlockIntegration() async {
        // Place blocks across chunk boundaries
        for x in -5...5 {
            for z in -5...5 {
                let pos = BlockPosition(x: x * 16, y: 0, z: z * 16)
                let block = Block(position: pos, type: .grass)
                chunkManager.setBlock(at: pos, block: block)
            }
        }

        // Verify blocks were placed
        let block = chunkManager.getBlock(at: BlockPosition(x: 32, y: 0, z: 48))
        XCTAssertNotNil(block)
        XCTAssertEqual(block?.type.id, "grass")
    }

    func testEntityAndChunkInteraction() async {
        // Create entity at specific position
        let entity = entityManager.createEntity()
        entity.transform.translation = SIMD3<Float>(1.5, 0.5, 2.0)
        entityManager.addEntity(entity)

        // Find chunk at entity position
        let blockPos = BlockPosition(x: 15, y: 5, z: 20)
        chunkManager.setBlock(at: blockPos, block: Block(position: blockPos, type: .stone))

        // Verify chunk exists
        let chunk = chunkManager.getChunk(at: ChunkPosition(x: 0, y: 0, z: 1))
        XCTAssertNotNil(chunk)
    }

    // MARK: - Game Loop Integration Tests

    func testGameLoopSystemsIntegration() async {
        let gameLoop = GameLoopController(gameStateManager: gameStateManager)
        let inputSystem = InputSystem(eventBus: eventBus)
        let physicsSystem = PhysicsSystem()
        let audioSystem = AudioSystem()

        gameLoop.registerSystems(
            entityManager: entityManager,
            physicsSystem: physicsSystem,
            inputSystem: inputSystem,
            audioSystem: audioSystem
        )

        gameLoop.start()

        // Let it run for a bit
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 second

        XCTAssertTrue(gameLoop.isRunning)
        XCTAssertGreaterThan(gameLoop.currentFPS, 0)

        gameLoop.stop()
        XCTAssertFalse(gameLoop.isRunning)
    }

    // MARK: - Player and Inventory Integration Tests

    func testPlayerInventoryIntegration() async {
        let entity = entityManager.createEntity()
        let playerComponent = PlayerComponent()
        entity.addComponent(playerComponent)
        entityManager.addEntity(entity)

        // Add items to player inventory
        playerComponent.inventory.addItem("dirt", quantity: 64)
        playerComponent.inventory.addItem("stone", quantity: 32)

        XCTAssertEqual(playerComponent.inventory.getItemQuantity("dirt"), 64)
        XCTAssertEqual(playerComponent.inventory.getItemQuantity("stone"), 32)

        // Damage player
        playerComponent.takeDamage(5.0)
        XCTAssertEqual(playerComponent.health, 15.0)
    }

    // MARK: - World Persistence Integration Tests

    func testWorldDataIntegration() async throws {
        let world = WorldData.createNew(name: "Test World")

        // Modify world
        var modifiedWorld = world
        modifiedWorld.currentTime = 1000
        modifiedWorld.spawnPosition = SIMD3<Float>(10, 5, 10)

        // Save world
        let persistenceManager = WorldPersistenceManager()
        try await persistenceManager.saveWorld(modifiedWorld)

        // Load world
        let loadedWorld = try await persistenceManager.loadWorld(id: modifiedWorld.id)

        XCTAssertEqual(loadedWorld.name, "Test World")
        XCTAssertEqual(loadedWorld.currentTime, 1000)
        XCTAssertEqual(loadedWorld.spawnPosition.x, 10)

        // Cleanup
        try persistenceManager.deleteWorld(id: loadedWorld.id)
    }

    // MARK: - Crafting and Inventory Integration Tests

    func testCraftingInventoryIntegration() async {
        let craftingManager = CraftingManager()
        let inventory = Inventory(maxSlots: 36)

        // Simulate full crafting workflow
        inventory.addItem("oak_log", quantity: 1)

        // Craft planks
        let planksGrid: [[String?]] = [["oak_log"]]
        let planksResult = craftingManager.craft(grid: planksGrid, inventory: inventory)

        if case .success = planksResult {
            XCTAssertEqual(inventory.getItemQuantity("oak_planks"), 4)

            // Craft sticks
            let sticksGrid: [[String?]] = [["oak_planks"], ["oak_planks"]]
            let sticksResult = craftingManager.craft(grid: sticksGrid, inventory: inventory)

            if case .success = sticksResult {
                XCTAssertEqual(inventory.getItemQuantity("stick"), 4)
                XCTAssertEqual(inventory.getItemQuantity("oak_planks"), 2)
            } else {
                XCTFail("Sticks crafting should succeed")
            }
        } else {
            XCTFail("Planks crafting should succeed")
        }
    }

    // MARK: - Performance Integration Tests

    func testEntitySystemPerformance() async {
        measure {
            // Create many entities
            for _ in 0..<1000 {
                let entity = entityManager.createEntity()
                entity.addComponent(HealthComponent(maxHealth: 20))
                entityManager.addEntity(entity)
            }

            // Update all entities
            entityManager.update(deltaTime: 0.016)

            // Clean up
            entityManager.removeAllEntities()
        }
    }

    func testChunkLoadingPerformance() async {
        measure {
            // Load 25 chunks (5x5 grid)
            for x in -2...2 {
                for z in -2...2 {
                    let pos = ChunkPosition(x: x, y: 0, z: z)
                    let chunk = chunkManager.getOrCreateChunk(at: pos)
                    chunk.fillWithPattern()
                }
            }

            chunkManager.clearAllChunks()
        }
    }
}
