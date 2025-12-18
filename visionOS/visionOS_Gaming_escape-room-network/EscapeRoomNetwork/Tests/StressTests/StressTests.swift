import XCTest
@testable import EscapeRoomNetwork

/// Stress tests for system limits and robustness
/// ✅ Can run in CLI with `swift test --filter StressTests`
final class StressTests: XCTestCase {

    // MARK: - Entity Stress Tests

    func testMaximumPuzzleElements() {
        // Test with maximum number of puzzle elements
        let puzzleEngine = PuzzleEngine()
        var roomData = RoomData()
        roomData.dimensions = SIMD3<Float>(20, 4, 20) // Large room

        // Generate puzzle with many elements
        let puzzle = puzzleEngine.generatePuzzle(
            type: .observation,
            difficulty: .expert,
            roomData: roomData
        )

        // Should handle large numbers gracefully
        XCTAssertLessThanOrEqual(puzzle.puzzleElements.count, 100)
    }

    func testThousandEntityCreation() {
        // Test creating 1000 entities
        measure {
            var entities: [PuzzleElement] = []
            for i in 0..<1000 {
                let element = PuzzleElement(
                    type: .clue,
                    position: SIMD3<Float>(
                        Float(i % 10),
                        Float((i / 10) % 10),
                        Float(i / 100)
                    ),
                    modelName: "entity_\(i)",
                    interactionType: .grab
                )
                entities.append(element)
            }

            XCTAssertEqual(entities.count, 1000)
        }
    }

    // MARK: - State Machine Stress Tests

    func testRapidStateTransitions() {
        let stateMachine = GameStateMachine()

        // Perform 10,000 rapid transitions
        measure {
            for _ in 0..<10000 {
                _ = stateMachine.transition(to: .roomScanning)
                _ = stateMachine.transition(to: .roomMapping)
                _ = stateMachine.transition(to: .loadingPuzzle)
                _ = stateMachine.transition(to: .playing)
                _ = stateMachine.transition(to: .paused)
                _ = stateMachine.transition(to: .playing)
                _ = stateMachine.transition(to: .puzzleCompleted)
                _ = stateMachine.transition(to: .initialization)
            }
        }
    }

    func testConcurrentStateAccessAttempts() {
        let stateMachine = GameStateMachine()
        let expectation = XCTestExpectation(description: "Concurrent access")
        expectation.expectedFulfillmentCount = 100

        // Attempt 100 concurrent state reads/writes
        for _ in 0..<100 {
            DispatchQueue.global().async {
                _ = stateMachine.currentState
                _ = stateMachine.transition(to: .playing)
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 5.0)
    }

    // MARK: - Game Loop Stress Tests

    func testGameLoopWith100Systems() {
        let gameLoop = GameLoopManager(targetFrameRate: 60)

        // Add 100 systems
        for _ in 0..<100 {
            gameLoop.addSystem(StressMockSystem())
        }

        // Run for 1 second
        gameLoop.start()
        Thread.sleep(forTimeInterval: 1.0)
        gameLoop.stop()

        // Should complete without crashing
    }

    func testExtendedGameLoopSession() {
        let gameLoop = GameLoopManager(targetFrameRate: 60)
        gameLoop.addSystem(StressMockSystem())

        // Run for 10 seconds (600 frames at 60 FPS)
        measure {
            gameLoop.start()
            Thread.sleep(forTimeInterval: 10.0)
            gameLoop.stop()
        }
    }

    // MARK: - Puzzle Engine Stress Tests

    func testGenerating1000Puzzles() {
        let puzzleEngine = PuzzleEngine()
        let roomData = createStressTestRoomData()

        measure {
            for _ in 0..<1000 {
                _ = puzzleEngine.generatePuzzle(
                    type: .logic,
                    difficulty: .beginner,
                    roomData: roomData
                )
            }
        }
    }

    func testPuzzleWithMaximumObjectives() {
        var objectives: [Objective] = []
        for i in 0..<100 {
            objectives.append(Objective(
                title: "Objective \(i)",
                description: "Complete task \(i)"
            ))
        }

        XCTAssertEqual(objectives.count, 100)
    }

    func testPuzzleProgressWith1000Updates() {
        let puzzleEngine = PuzzleEngine()
        let roomData = createStressTestRoomData()
        _ = puzzleEngine.generatePuzzle(
            type: .logic,
            difficulty: .beginner,
            roomData: roomData
        )

        measure {
            for _ in 0..<1000 {
                puzzleEngine.updateProgress(completedObjective: UUID())
                puzzleEngine.discoverClue(UUID())
                puzzleEngine.revealHint(UUID())
            }
        }
    }

    // MARK: - Multiplayer Stress Tests

    func testMaximumPlayerCount() async throws {
        let multiplayerManager = MultiplayerManager()
        try await multiplayerManager.startMultiplayerSession(puzzleId: UUID())

        // Add 100 players
        for i in 0..<100 {
            let player = Player(username: "Player\(i)")
            multiplayerManager.addPlayer(player)
        }

        XCTAssertGreaterThanOrEqual(multiplayerManager.connectedPlayers.count, 100)
    }

    func testRapidPlayerJoinLeave() async throws {
        let multiplayerManager = MultiplayerManager()
        try await multiplayerManager.startMultiplayerSession(puzzleId: UUID())

        measure {
            for i in 0..<500 {
                let player = Player(username: "Player\(i)")
                multiplayerManager.addPlayer(player)
                multiplayerManager.removePlayer(player.id)
            }
        }
    }

    func testHighMessageThroughput() {
        let multiplayerManager = MultiplayerManager()

        // Send 10,000 messages
        measure {
            for i in 0..<10000 {
                let message = NetworkMessage.chatMessage("Message \(i)")
                multiplayerManager.handleReceivedMessage(message)
            }
        }
    }

    // MARK: - Spatial Mapping Stress Tests

    func testLargeRoomMapping() async {
        let mappingManager = SpatialMappingManager()

        // Simulate very large room
        await mappingManager.startRoomScanning()

        let roomData = mappingManager.getCurrentRoomData()
        XCTAssertNotNil(roomData)
    }

    func testManyFurnitureItems() {
        var roomData = RoomData()

        // Add 500 furniture items
        for i in 0..<500 {
            let furniture = RoomData.FurnitureItem(
                id: UUID(),
                type: .table,
                boundingBox: RoomData.BoundingBox(
                    center: SIMD3<Float>(Float(i % 20), 0.75, Float(i / 20)),
                    extents: SIMD3<Float>(1, 0.75, 1)
                ),
                surfaceNormals: [SIMD3<Float>(0, 1, 0)]
            )
            roomData.furniture.append(furniture)
        }

        XCTAssertEqual(roomData.furniture.count, 500)
    }

    func testRapidSpatialQueries() async {
        let mappingManager = SpatialMappingManager()
        await mappingManager.startRoomScanning()

        measure {
            for _ in 0..<1000 {
                _ = mappingManager.findSuitablePositions(for: .clue, count: 10)
            }
        }
    }

    // MARK: - Memory Stress Tests

    func testLargeDataSerialization() throws {
        // Create large puzzle with many elements
        var elements: [PuzzleElement] = []
        for i in 0..<1000 {
            elements.append(PuzzleElement(
                type: .clue,
                position: SIMD3<Float>(Float(i), 0, 0),
                modelName: "element_\(i)",
                interactionType: .grab,
                metadata: [
                    "key1": "value1",
                    "key2": "value2",
                    "key3": "value3"
                ]
            ))
        }

        let puzzle = Puzzle(
            title: "Stress Test Puzzle",
            description: "A puzzle with many elements",
            difficulty: .expert,
            estimatedTime: 3600,
            requiredRoomSize: .large,
            puzzleElements: elements,
            objectives: [],
            hints: []
        )

        // Test serialization
        measure {
            let encoder = JSONEncoder()
            _ = try? encoder.encode(puzzle)
        }
    }

    func testRepeatedAllocationDeallocation() {
        measure {
            for _ in 0..<1000 {
                var array: [Puzzle] = []
                for _ in 0..<100 {
                    array.append(Puzzle(
                        title: "Test",
                        description: "Test",
                        difficulty: .beginner,
                        estimatedTime: 600,
                        requiredRoomSize: .small,
                        puzzleElements: [],
                        objectives: [],
                        hints: []
                    ))
                }
                // Array goes out of scope and is deallocated
            }
        }
    }

    // MARK: - Concurrent Operation Stress Tests

    func testConcurrentPuzzleGeneration() {
        let puzzleEngine = PuzzleEngine()
        let roomData = createStressTestRoomData()

        let expectation = XCTestExpectation(description: "Concurrent puzzle generation")
        expectation.expectedFulfillmentCount = 50

        // Generate 50 puzzles concurrently
        for _ in 0..<50 {
            DispatchQueue.global().async {
                _ = puzzleEngine.generatePuzzle(
                    type: .logic,
                    difficulty: .beginner,
                    roomData: roomData
                )
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 10.0)
    }

    func testConcurrentRoomScanning() {
        let expectation = XCTestExpectation(description: "Concurrent scanning")
        expectation.expectedFulfillmentCount = 10

        // Attempt 10 concurrent scans
        for _ in 0..<10 {
            Task {
                let manager = SpatialMappingManager()
                await manager.startRoomScanning()
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 15.0)
    }

    // MARK: - Edge Case Stress Tests

    func testEmptyPuzzleHandling() {
        let puzzle = Puzzle(
            title: "Empty Puzzle",
            description: "No elements",
            difficulty: .beginner,
            estimatedTime: 0,
            requiredRoomSize: .small,
            puzzleElements: [],
            objectives: [],
            hints: []
        )

        XCTAssertTrue(puzzle.puzzleElements.isEmpty)
        XCTAssertTrue(puzzle.objectives.isEmpty)
    }

    func testExtremelyLongStrings() {
        let longString = String(repeating: "A", count: 10000)

        let puzzle = Puzzle(
            title: longString,
            description: longString,
            difficulty: .beginner,
            estimatedTime: 600,
            requiredRoomSize: .small,
            puzzleElements: [],
            objectives: [],
            hints: []
        )

        XCTAssertEqual(puzzle.title.count, 10000)
    }

    // MARK: - Helper Methods

    private func createStressTestRoomData() -> RoomData {
        var roomData = RoomData()
        roomData.dimensions = SIMD3<Float>(10, 4, 10)

        // Add some furniture
        for i in 0..<10 {
            let furniture = RoomData.FurnitureItem(
                id: UUID(),
                type: .table,
                boundingBox: RoomData.BoundingBox(
                    center: SIMD3<Float>(Float(i), 0.75, 0),
                    extents: SIMD3<Float>(1, 0.75, 1)
                ),
                surfaceNormals: [SIMD3<Float>(0, 1, 0)]
            )
            roomData.furniture.append(furniture)
        }

        return roomData
    }
}

// MARK: - Mock System for Stress Testing

class StressMockSystem: System {
    func update(deltaTime: TimeInterval) {
        // Simulate some computational work
        var sum = 0.0
        for i in 0..<1000 {
            sum += Double(i) * deltaTime
        }
    }
}
