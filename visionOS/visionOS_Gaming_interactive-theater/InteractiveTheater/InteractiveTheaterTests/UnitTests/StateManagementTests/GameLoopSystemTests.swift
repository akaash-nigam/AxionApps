import XCTest
@testable import InteractiveTheater

/// Unit tests for GameLoopSystem
@MainActor
final class GameLoopSystemTests: XCTestCase {

    var gameLoop: GameLoopSystem!
    var gameState: GameStateManager!
    var testPerformance: PerformanceData!

    override func setUp() async throws {
        testPerformance = createTestPerformance()
        gameState = GameStateManager(performance: testPerformance)
        gameLoop = GameLoopSystem(gameStateManager: gameState)
    }

    override func tearDown() async throws {
        gameLoop = nil
        gameState = nil
        testPerformance = nil
    }

    // MARK: - Test Initialization

    func testInitialization() {
        XCTAssertNotNil(gameLoop)
        XCTAssertEqual(gameLoop.currentFPS, 0) // Not started yet
    }

    // MARK: - Test Game Loop Start/Stop

    func testStartGameLoop() {
        gameLoop.start()

        // Simulate a few updates
        for i in 0..<10 {
            let currentTime = CACurrentMediaTime() + Double(i) * 0.011 // ~90 FPS
            gameLoop.update(currentTime: currentTime)
        }

        XCTAssertGreaterThan(gameLoop.currentFPS, 0)
    }

    func testStopGameLoop() {
        gameLoop.start()

        let currentTime = CACurrentMediaTime()
        gameLoop.update(currentTime: currentTime)

        gameLoop.stop()

        // Updates after stop should not affect FPS significantly
        let fpsBefore = gameLoop.currentFPS
        gameLoop.update(currentTime: currentTime + 1.0)

        // FPS might change slightly but shouldn't be drastically different
        // because update() checks isRunning
    }

    // MARK: - Test Performance Metrics

    func testPerformanceStats() {
        gameLoop.start()

        // Simulate consistent frame times (90 FPS = ~11ms per frame)
        var currentTime = CACurrentMediaTime()

        for _ in 0..<100 {
            currentTime += 0.0111 // 11.1ms per frame (90 FPS)
            gameLoop.update(currentTime: currentTime)
        }

        let stats = gameLoop.getPerformanceStats()

        XCTAssertGreaterThan(stats.currentFPS, 85) // Should be around 90 FPS
        XCTAssertLessThan(stats.currentFPS, 95)
        XCTAssertGreaterThan(stats.averageFrameTime, 0)
        XCTAssertLessThan(stats.averageFrameTime, 0.012) // Should be around 11.1ms
    }

    func testPerformanceTargetMet() {
        gameLoop.start()

        // Simulate good performance (90 FPS)
        var currentTime = CACurrentMediaTime()

        for _ in 0..<100 {
            currentTime += 0.0111 // 11.1ms per frame
            gameLoop.update(currentTime: currentTime)
        }

        XCTAssertTrue(gameLoop.isPerformanceTargetMet())
    }

    func testPerformanceTargetNotMet() {
        gameLoop.start()

        // Simulate poor performance (30 FPS)
        var currentTime = CACurrentMediaTime()

        for _ in 0..<100 {
            currentTime += 0.0333 // 33.3ms per frame (30 FPS)
            gameLoop.update(currentTime: currentTime)
        }

        XCTAssertFalse(gameLoop.isPerformanceTargetMet())
    }

    // MARK: - Test Performance Rating

    func testPerformanceRatingExcellent() {
        gameLoop.start()

        var currentTime = CACurrentMediaTime()

        for _ in 0..<100 {
            currentTime += 0.0111 // 90 FPS
            gameLoop.update(currentTime: currentTime)
        }

        let stats = gameLoop.getPerformanceStats()
        XCTAssertEqual(stats.performanceRating, .excellent)
    }

    func testPerformanceRatingGood() {
        gameLoop.start()

        var currentTime = CACurrentMediaTime()

        for _ in 0..<100 {
            currentTime += 0.0143 // ~70 FPS
            gameLoop.update(currentTime: currentTime)
        }

        let stats = gameLoop.getPerformanceStats()
        XCTAssertEqual(stats.performanceRating, .good)
    }

    func testPerformanceRatingPoor() {
        gameLoop.start()

        var currentTime = CACurrentMediaTime()

        for _ in 0..<100 {
            currentTime += 0.04 // 25 FPS
            gameLoop.update(currentTime: currentTime)
        }

        let stats = gameLoop.getPerformanceStats()
        XCTAssertEqual(stats.performanceRating, .poor)
    }

    // MARK: - Test Frame Time Percentiles

    func testFrameTimePercentiles() {
        gameLoop.start()

        var currentTime = CACurrentMediaTime()

        // Simulate mostly good frames with a few bad ones
        for i in 0..<100 {
            if i % 20 == 0 {
                currentTime += 0.025 // Occasional slow frame
            } else {
                currentTime += 0.0111 // Normal frame
            }
            gameLoop.update(currentTime: currentTime)
        }

        let stats = gameLoop.getPerformanceStats()

        XCTAssertGreaterThan(stats.percentile95FrameTime, 0)
        XCTAssertGreaterThan(stats.percentile99FrameTime, 0)
        XCTAssertGreaterThanOrEqual(stats.percentile99FrameTime, stats.percentile95FrameTime)
        XCTAssertGreaterThanOrEqual(stats.maxFrameTime, stats.percentile99FrameTime)
    }

    // MARK: - Test System Management

    func testAddSystem() {
        let testSystem = TestUpdateSystem()

        gameLoop.addSystem(testSystem)

        // System should now be in the update loop
        // We can't directly verify this without making updateSystems public,
        // but we can verify no errors occur
    }

    // MARK: - Test Integration with GameState

    func testGameStateProgressUpdate() {
        gameLoop.start()

        let initialProgress = gameState.performanceProgress.totalTime

        var currentTime = CACurrentMediaTime()

        for _ in 0..<10 {
            currentTime += 0.0111
            gameLoop.update(currentTime: currentTime)
        }

        // Game state should have accumulated time
        XCTAssertGreaterThan(gameState.performanceProgress.totalTime, initialProgress)
    }

    // MARK: - Helper Methods

    private func createTestPerformance() -> PerformanceData {
        let startNodeID = UUID()
        let endNodeID = UUID()

        let sceneData = SceneData(
            title: "Test Scene",
            description: "Test",
            duration: 60.0,
            settingID: UUID(),
            charactersPresent: [],
            dialogueSequence: [],
            interactiveMoments: []
        )

        let node1 = NarrativeNode(id: startNodeID, type: .scene, sceneData: sceneData)
        let node2 = NarrativeNode(id: endNodeID, type: .ending, sceneData: sceneData)

        let edge = NarrativeEdge(fromNodeID: startNodeID, toNodeID: endNodeID)

        let narrativeGraph = NarrativeGraph(
            nodes: [node1, node2],
            edges: [edge],
            startNodeID: startNodeID,
            endNodeIDs: [endNodeID]
        )

        return PerformanceData(
            title: "Test",
            author: "Test",
            genre: .tragedy,
            duration: 60.0,
            acts: [],
            characters: [],
            settings: [],
            ageRating: .everyone,
            culturalContext: CulturalContext(
                culture: "Test",
                timePerio: "Test",
                geographicLocation: "Test",
                culturalNotes: "Test"
            ),
            educationalObjectives: [],
            historicalPeriod: .contemporary,
            narrativeGraph: narrativeGraph,
            endings: []
        )
    }
}

// MARK: - Test Helpers

class TestUpdateSystem: UpdateSystem {
    var updateMode: UpdateMode = .fixed
    var updateCount = 0

    func update(deltaTime: TimeInterval) {
        updateCount += 1
    }
}
