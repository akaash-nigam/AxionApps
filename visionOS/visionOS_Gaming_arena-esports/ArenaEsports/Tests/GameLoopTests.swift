import XCTest
@testable import ArenaEsports

// Mock system for testing
final class MockSystem: BaseGameSystem {
    var updateCallCount: Int = 0
    var lastDeltaTime: TimeInterval = 0
    var onUpdate: (() -> Void)?

    override func update(deltaTime: TimeInterval, entities: [GameEntity]) async {
        updateCallCount += 1
        lastDeltaTime = deltaTime
        onUpdate?()
    }
}

@MainActor
final class GameLoopTests: XCTestCase {
    var gameLoop: GameLoop!

    override func setUp() {
        super.setUp()
        gameLoop = GameLoop()
    }

    override func tearDown() {
        gameLoop.stop()
        gameLoop = nil
        super.tearDown()
    }

    // MARK: - Initialization Tests

    func testGameLoopInitialization() {
        XCTAssertNotNil(gameLoop)
        XCTAssertFalse(gameLoop.running)
        XCTAssertEqual(gameLoop.registeredSystems.count, 0)
    }

    // MARK: - System Management Tests

    func testAddSystem() {
        let system = MockSystem(priority: 100)
        gameLoop.addSystem(system)

        XCTAssertEqual(gameLoop.registeredSystems.count, 1)
    }

    func testAddMultipleSystems() {
        let system1 = MockSystem(priority: 100)
        let system2 = MockSystem(priority: 200)
        let system3 = MockSystem(priority: 150)

        gameLoop.addSystem(system1)
        gameLoop.addSystem(system2)
        gameLoop.addSystem(system3)

        XCTAssertEqual(gameLoop.registeredSystems.count, 3)
    }

    func testSystemPriorityOrder() {
        let system1 = MockSystem(priority: 100)
        let system2 = MockSystem(priority: 200)
        let system3 = MockSystem(priority: 150)

        gameLoop.addSystem(system1)
        gameLoop.addSystem(system2)
        gameLoop.addSystem(system3)

        // Systems should be sorted by priority (highest first)
        let priorities = gameLoop.registeredSystems.map { $0.priority }
        XCTAssertEqual(priorities, [200, 150, 100])
    }

    func testRemoveSystem() {
        let system = MockSystem(priority: 100)
        gameLoop.addSystem(system)

        XCTAssertEqual(gameLoop.registeredSystems.count, 1)

        gameLoop.removeSystem(system)

        XCTAssertEqual(gameLoop.registeredSystems.count, 0)
    }

    func testClearSystems() {
        gameLoop.addSystem(MockSystem(priority: 100))
        gameLoop.addSystem(MockSystem(priority: 200))
        gameLoop.addSystem(MockSystem(priority: 300))

        gameLoop.clearSystems()

        XCTAssertEqual(gameLoop.registeredSystems.count, 0)
    }

    // MARK: - Loop Control Tests

    func testStartGameLoop() {
        gameLoop.start()

        XCTAssertTrue(gameLoop.running)
    }

    func testStopGameLoop() {
        gameLoop.start()
        XCTAssertTrue(gameLoop.running)

        gameLoop.stop()
        XCTAssertFalse(gameLoop.running)
    }

    func testStartAlreadyRunningLoop() {
        gameLoop.start()
        XCTAssertTrue(gameLoop.running)

        // Starting again should have no effect
        gameLoop.start()
        XCTAssertTrue(gameLoop.running)
    }

    // MARK: - Update Tests

    func testSystemUpdate() async {
        let system = MockSystem(priority: 100)
        gameLoop.addSystem(system)

        await gameLoop.updateOnce(deltaTime: 0.016)

        XCTAssertEqual(system.updateCallCount, 1)
        XCTAssertEqual(system.lastDeltaTime, 0.016, accuracy: 0.001)
    }

    func testMultipleSystemUpdates() async {
        let system1 = MockSystem(priority: 200)
        let system2 = MockSystem(priority: 100)

        gameLoop.addSystem(system1)
        gameLoop.addSystem(system2)

        await gameLoop.updateOnce(deltaTime: 0.016)

        XCTAssertEqual(system1.updateCallCount, 1)
        XCTAssertEqual(system2.updateCallCount, 1)
    }

    func testSystemUpdateOrder() async {
        var updateOrder: [Int] = []

        let system1 = MockSystem(priority: 100)
        system1.onUpdate = { updateOrder.append(100) }

        let system2 = MockSystem(priority: 200)
        system2.onUpdate = { updateOrder.append(200) }

        let system3 = MockSystem(priority: 150)
        system3.onUpdate = { updateOrder.append(150) }

        gameLoop.addSystem(system1)
        gameLoop.addSystem(system2)
        gameLoop.addSystem(system3)

        await gameLoop.updateOnce(deltaTime: 0.016)

        // Higher priority should execute first
        XCTAssertEqual(updateOrder, [200, 150, 100])
    }

    func testMultipleUpdates() async {
        let system = MockSystem(priority: 100)
        gameLoop.addSystem(system)

        await gameLoop.updateOnce(deltaTime: 0.016)
        await gameLoop.updateOnce(deltaTime: 0.016)
        await gameLoop.updateOnce(deltaTime: 0.016)

        XCTAssertEqual(system.updateCallCount, 3)
    }

    // MARK: - FPS Tracking Tests

    func testFPSInitialValue() {
        XCTAssertEqual(gameLoop.currentFPS, 0)
    }

    // Note: Actual FPS calculation tests would require running the loop
    // for a period of time, which is better suited for integration tests
}
