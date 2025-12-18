import XCTest
@testable import EscapeRoomNetwork

/// Performance tests for critical game systems
/// ✅ Can run in CLI with `swift test --filter PerformanceTests`
final class PerformanceTests: XCTestCase {

    // MARK: - Game Loop Performance

    func testGameLoopUpdatePerformance() {
        let gameLoop = GameLoopManager(targetFrameRate: 60)
        let mockSystem = MockPerformanceSystem()
        gameLoop.addSystem(mockSystem)

        measure {
            gameLoop.start()
            Thread.sleep(forTimeInterval: 0.1) // 100ms = ~6 frames at 60fps
            gameLoop.stop()
        }
    }

    func testGameLoopWith10Systems() {
        let gameLoop = GameLoopManager(targetFrameRate: 60)

        // Add 10 systems
        for _ in 0..<10 {
            gameLoop.addSystem(MockPerformanceSystem())
        }

        measure {
            gameLoop.start()
            Thread.sleep(forTimeInterval: 0.05)
            gameLoop.stop()
        }
    }

    // MARK: - Puzzle Generation Performance

    func testPuzzleGenerationPerformance() {
        let puzzleEngine = PuzzleEngine()
        let roomData = createMockRoomData()

        measure {
            _ = puzzleEngine.generatePuzzle(
                type: .logic,
                difficulty: .intermediate,
                roomData: roomData
            )
        }
    }

    func testGenerateAllPuzzleTypes() {
        let puzzleEngine = PuzzleEngine()
        let roomData = createMockRoomData()

        measure {
            for type in PuzzleType.allCases {
                _ = puzzleEngine.generatePuzzle(
                    type: type,
                    difficulty: .beginner,
                    roomData: roomData
                )
            }
        }
    }

    func testComplexPuzzleGeneration() {
        let puzzleEngine = PuzzleEngine()
        let roomData = createComplexRoomData()

        measure {
            _ = puzzleEngine.generatePuzzle(
                type: .collaborative,
                difficulty: .expert,
                roomData: roomData
            )
        }
    }

    // MARK: - State Machine Performance

    func testStateMachineTransitionPerformance() {
        let stateMachine = GameStateMachine()

        measure {
            for _ in 0..<1000 {
                stateMachine.transition(to: .roomScanning)
                stateMachine.transition(to: .roomMapping)
                stateMachine.transition(to: .loadingPuzzle)
                stateMachine.transition(to: .playing)
                stateMachine.transition(to: .paused)
                stateMachine.transition(to: .playing)
                stateMachine.transition(to: .puzzleCompleted)
                stateMachine.transition(to: .initialization)
            }
        }
    }

    // MARK: - Data Model Performance

    func testPuzzleEncodingPerformance() throws {
        let puzzle = createLargePuzzle()
        let encoder = JSONEncoder()

        measure {
            _ = try? encoder.encode(puzzle)
        }
    }

    func testPuzzleDecodingPerformance() throws {
        let puzzle = createLargePuzzle()
        let encoder = JSONEncoder()
        let data = try encoder.encode(puzzle)
        let decoder = JSONDecoder()

        measure {
            _ = try? decoder.decode(Puzzle.self, from: data)
        }
    }

    func testRoomDataEncodingPerformance() throws {
        let roomData = createComplexRoomData()
        let encoder = JSONEncoder()

        measure {
            _ = try? encoder.encode(roomData)
        }
    }

    // MARK: - Spatial Mapping Performance

    func testRoomScanningPerformance() {
        let mappingManager = SpatialMappingManager()

        measure {
            Task {
                await mappingManager.startRoomScanning()
            }
        }
    }

    func testFurnitureClassificationPerformance() async {
        let mappingManager = SpatialMappingManager()
        await mappingManager.startRoomScanning()

        measure {
            for _ in 0..<100 {
                _ = mappingManager.classifyFurniture(at: SIMD3<Float>(0, 0.75, 0))
            }
        }
    }

    func testSpatialQueryPerformance() async {
        let mappingManager = SpatialMappingManager()
        await mappingManager.startRoomScanning()

        measure {
            _ = mappingManager.findSuitablePositions(for: .clue, count: 20)
        }
    }

    // MARK: - Multiplayer Performance

    func testSessionCreationPerformance() {
        let multiplayerManager = MultiplayerManager()

        measure {
            Task {
                try? await multiplayerManager.startMultiplayerSession(puzzleId: UUID())
                multiplayerManager.leaveSession()
            }
        }
    }

    func testPlayerManagementPerformance() {
        let multiplayerManager = MultiplayerManager()

        measure {
            for i in 0..<100 {
                let player = Player(username: "Player\(i)")
                multiplayerManager.addPlayer(player)
                multiplayerManager.removePlayer(player.id)
            }
        }
    }

    func testMessageHandlingPerformance() {
        let multiplayerManager = MultiplayerManager()

        measure {
            for _ in 0..<1000 {
                let message = NetworkMessage.chatMessage("Performance test")
                multiplayerManager.handleReceivedMessage(message)
            }
        }
    }

    // MARK: - Collection Performance

    func testPuzzleProgressUpdatePerformance() {
        let puzzleEngine = PuzzleEngine()
        let roomData = createMockRoomData()
        let puzzle = puzzleEngine.generatePuzzle(
            type: .observation,
            difficulty: .expert,
            roomData: roomData
        )

        measure {
            for objective in puzzle.objectives {
                puzzleEngine.updateProgress(completedObjective: objective.id)
            }
        }
    }

    func testLargeObjectiveListPerformance() {
        var progress = PuzzleProgress(puzzleId: UUID())

        measure {
            for _ in 0..<1000 {
                progress.completedObjectives.append(UUID())
            }
        }
    }

    // MARK: - Memory Allocation Performance

    func testEntityCreationPerformance() {
        measure {
            var entities: [PuzzleElement] = []
            for i in 0..<1000 {
                entities.append(PuzzleElement(
                    type: .clue,
                    position: SIMD3<Float>(Float(i), 0, 0),
                    modelName: "entity_\(i)",
                    interactionType: .grab
                ))
            }
        }
    }

    // MARK: - Algorithm Performance

    func testSolutionValidationPerformance() {
        let puzzleEngine = PuzzleEngine()
        let roomData = createMockRoomData()
        let puzzle = puzzleEngine.generatePuzzle(
            type: .logic,
            difficulty: .expert,
            roomData: roomData
        )

        measure {
            for _ in 0..<100 {
                _ = puzzleEngine.validateSolution(
                    puzzle: puzzle,
                    solution: PuzzleSolution(answer: "test")
                )
            }
        }
    }

    func testHintGenerationPerformance() {
        let puzzleEngine = PuzzleEngine()
        let roomData = createMockRoomData()
        let puzzle = puzzleEngine.generatePuzzle(
            type: .logic,
            difficulty: .expert,
            roomData: roomData
        )
        let progress = PuzzleProgress(puzzleId: puzzle.id)

        measure {
            for _ in 0..<100 {
                _ = puzzleEngine.provideHint(puzzle: puzzle, progress: progress)
            }
        }
    }

    // MARK: - Target Benchmarks

    func testTargetFrameTime() {
        // Target: 11ms for 90 FPS, 16ms for 60 FPS
        let gameLoop = GameLoopManager(targetFrameRate: 90)
        let system = MockPerformanceSystem()
        gameLoop.addSystem(system)

        let startTime = Date()
        gameLoop.start()
        Thread.sleep(forTimeInterval: 1.0) // Run for 1 second
        gameLoop.stop()
        let elapsed = Date().timeIntervalSince(startTime)

        // Should complete many frames in 1 second
        XCTAssertLessThan(elapsed, 1.1) // Allow 10% overhead
    }

    func testPuzzleGenerationTarget() {
        // Target: < 100ms for puzzle generation
        let puzzleEngine = PuzzleEngine()
        let roomData = createMockRoomData()

        let startTime = Date()
        _ = puzzleEngine.generatePuzzle(
            type: .logic,
            difficulty: .intermediate,
            roomData: roomData
        )
        let elapsed = Date().timeIntervalSince(startTime)

        XCTAssertLessThan(elapsed, 0.1, "Puzzle generation should take less than 100ms")
    }

    // MARK: - Helper Methods

    private func createMockRoomData() -> RoomData {
        var roomData = RoomData()
        roomData.dimensions = SIMD3<Float>(5, 3, 5)
        return roomData
    }

    private func createComplexRoomData() -> RoomData {
        var roomData = RoomData()
        roomData.dimensions = SIMD3<Float>(10, 4, 10)

        // Add many furniture items
        for i in 0..<20 {
            let furniture = RoomData.FurnitureItem(
                id: UUID(),
                type: .table,
                boundingBox: RoomData.BoundingBox(
                    center: SIMD3<Float>(Float(i % 5), 0.75, Float(i / 5)),
                    extents: SIMD3<Float>(1, 0.75, 1)
                ),
                surfaceNormals: [SIMD3<Float>(0, 1, 0)]
            )
            roomData.furniture.append(furniture)
        }

        return roomData
    }

    private func createLargePuzzle() -> Puzzle {
        var elements: [PuzzleElement] = []
        for i in 0..<50 {
            elements.append(PuzzleElement(
                type: .clue,
                position: SIMD3<Float>(Float(i), 1, 0),
                modelName: "element_\(i)",
                interactionType: .examine
            ))
        }

        var objectives: [Objective] = []
        for i in 0..<20 {
            objectives.append(Objective(
                title: "Objective \(i)",
                description: "Complete task \(i)"
            ))
        }

        var hints: [Hint] = []
        for i in 0..<10 {
            hints.append(Hint(text: "Hint \(i)", difficulty: i % 3 + 1))
        }

        return Puzzle(
            title: "Large Test Puzzle",
            description: "A complex puzzle for performance testing",
            difficulty: .expert,
            estimatedTime: 3600,
            requiredRoomSize: .large,
            puzzleElements: elements,
            objectives: objectives,
            hints: hints
        )
    }
}

// MARK: - Mock System

class MockPerformanceSystem: System {
    func update(deltaTime: TimeInterval) {
        // Simulate some work
        var sum = 0
        for i in 0..<100 {
            sum += i
        }
    }
}
