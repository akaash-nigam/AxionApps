import XCTest
@testable import EscapeRoomNetwork

/// Integration tests for game systems working together
final class GameSystemIntegrationTests: XCTestCase {

    var gameViewModel: GameViewModel!
    var puzzleEngine: PuzzleEngine!
    var stateMachine: GameStateMachine!

    override func setUp() {
        super.setUp()
        gameViewModel = GameViewModel()
        puzzleEngine = PuzzleEngine()
        stateMachine = GameStateMachine()
    }

    override func tearDown() {
        gameViewModel = nil
        puzzleEngine = nil
        stateMachine = nil
        super.tearDown()
    }

    // MARK: - Complete Game Flow Tests

    func testCompleteGameFlow() async throws {
        // Given - Start from initialization
        XCTAssertEqual(stateMachine.currentState, .initialization)

        // When - Progress through game states
        XCTAssertTrue(stateMachine.transition(to: .roomScanning))

        // Simulate room scanning
        let mappingManager = SpatialMappingManager()
        await mappingManager.startRoomScanning()

        let roomData = mappingManager.getCurrentRoomData()
        XCTAssertNotNil(roomData)

        // Transition to puzzle loading
        XCTAssertTrue(stateMachine.transition(to: .roomMapping))
        XCTAssertTrue(stateMachine.transition(to: .loadingPuzzle))

        // Generate puzzle
        let puzzle = puzzleEngine.generatePuzzle(
            type: .logic,
            difficulty: .beginner,
            roomData: roomData!
        )

        XCTAssertNotNil(puzzle)

        // Start playing
        XCTAssertTrue(stateMachine.transition(to: .playing))

        // Then - Verify state
        XCTAssertEqual(stateMachine.currentState, .playing)
        XCTAssertEqual(puzzle.difficulty, .beginner)
    }

    func testPuzzleCompletionFlow() {
        // Given
        let roomData = RoomData()
        let puzzle = puzzleEngine.generatePuzzle(
            type: .logic,
            difficulty: .beginner,
            roomData: roomData
        )

        stateMachine.transition(to: .roomScanning)
        stateMachine.transition(to: .roomMapping)
        stateMachine.transition(to: .loadingPuzzle)
        stateMachine.transition(to: .playing)

        // When - Complete all objectives
        for objective in puzzle.objectives {
            puzzleEngine.updateProgress(completedObjective: objective.id)
        }

        // Then
        XCTAssertTrue(puzzleEngine.isPuzzleCompleted())

        // Transition to completion
        XCTAssertTrue(stateMachine.transition(to: .puzzleCompleted))
        XCTAssertEqual(stateMachine.currentState, .puzzleCompleted)
    }

    // MARK: - Puzzle Engine + Spatial Mapping Integration

    func testPuzzleGenerationWithRoomData() async {
        // Given
        let mappingManager = SpatialMappingManager()
        await mappingManager.startRoomScanning()

        guard let roomData = mappingManager.getCurrentRoomData() else {
            XCTFail("Room data should be available")
            return
        }

        // When - Generate puzzles for different types
        for puzzleType in PuzzleType.allCases {
            let puzzle = puzzleEngine.generatePuzzle(
                type: puzzleType,
                difficulty: .beginner,
                roomData: roomData
            )

            // Then
            XCTAssertNotNil(puzzle)
            XCTAssertFalse(puzzle.puzzleElements.isEmpty)
        }
    }

    func testPuzzleElementPlacement() async {
        // Given
        let mappingManager = SpatialMappingManager()
        await mappingManager.startRoomScanning()

        guard let roomData = mappingManager.getCurrentRoomData() else {
            XCTFail("Room data should be available")
            return
        }

        // When
        let puzzle = puzzleEngine.generatePuzzle(
            type: .spatial,
            difficulty: .intermediate,
            roomData: roomData
        )

        // Then - Verify elements are within room bounds
        for element in puzzle.puzzleElements {
            XCTAssertTrue(abs(element.position.x) <= roomData.dimensions.x / 2)
            XCTAssertTrue(element.position.y >= 0)
            XCTAssertTrue(abs(element.position.z) <= roomData.dimensions.z / 2)
        }
    }

    // MARK: - Multiplayer + Puzzle Integration

    func testMultiplayerPuzzleSharing() async throws {
        // Given
        let multiplayerManager = MultiplayerManager()
        let roomData = RoomData()
        let puzzle = puzzleEngine.generatePuzzle(
            type: .collaborative,
            difficulty: .intermediate,
            roomData: roomData
        )

        // When - Start multiplayer session with puzzle
        try await multiplayerManager.startMultiplayerSession(puzzleId: puzzle.id)

        // Then
        XCTAssertTrue(multiplayerManager.isSessionActive)
        XCTAssertNotNil(multiplayerManager.currentSession)
        XCTAssertEqual(multiplayerManager.currentSession?.puzzleId, puzzle.id)
    }

    func testMultiplayerProgressSync() async throws {
        // Given
        let multiplayerManager = MultiplayerManager()
        let roomData = RoomData()
        let puzzle = puzzleEngine.generatePuzzle(
            type: .logic,
            difficulty: .beginner,
            roomData: roomData
        )

        try await multiplayerManager.startMultiplayerSession(puzzleId: puzzle.id)

        // When - Update puzzle progress
        let objectiveId = puzzle.objectives.first!.id
        puzzleEngine.updateProgress(completedObjective: objectiveId)

        let progress = puzzleEngine.getCurrentProgress()!

        // Sync progress
        multiplayerManager.syncGameState(SharedGameState(
            completedObjectives: progress.completedObjectives,
            discoveredClues: progress.discoveredClues,
            currentPhase: 1
        ))

        // Then
        XCTAssertTrue(multiplayerManager.isSessionActive)
    }

    // MARK: - State Machine + Game Loop Integration

    func testStateMachineWithGameLoop() {
        // Given
        let gameLoop = GameLoopManager(targetFrameRate: 60)
        let mockSystem = MockGameSystem()

        gameLoop.addSystem(mockSystem)

        // When - Start game loop and transition states
        stateMachine.transition(to: .roomScanning)
        gameLoop.start()

        // Wait for updates
        let expectation = XCTestExpectation(description: "Game loop running")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            gameLoop.stop()
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)

        // Then
        XCTAssertTrue(mockSystem.updateCalled)
        XCTAssertGreaterThan(mockSystem.updateCount, 0)
    }

    // MARK: - Full Integration Test

    func testFullGameplaySession() async throws {
        // Given - Initialize all systems
        let gameLoop = GameLoopManager(targetFrameRate: 60)
        let mappingManager = SpatialMappingManager()

        // When - Complete game flow
        // 1. Scan room
        stateMachine.transition(to: .roomScanning)
        await mappingManager.startRoomScanning()
        let roomData = mappingManager.getCurrentRoomData()!

        // 2. Load puzzle
        stateMachine.transition(to: .roomMapping)
        stateMachine.transition(to: .loadingPuzzle)

        let puzzle = puzzleEngine.generatePuzzle(
            type: .observation,
            difficulty: .beginner,
            roomData: roomData
        )

        // 3. Start playing
        stateMachine.transition(to: .playing)
        gameLoop.start()

        // 4. Discover clues
        for element in puzzle.puzzleElements {
            puzzleEngine.discoverClue(element.id)
        }

        // 5. Complete objectives
        for objective in puzzle.objectives {
            puzzleEngine.updateProgress(completedObjective: objective.id)
        }

        // 6. Complete puzzle
        XCTAssertTrue(puzzleEngine.isPuzzleCompleted())
        stateMachine.transition(to: .puzzleCompleted)

        gameLoop.stop()

        // Then - Verify final state
        XCTAssertEqual(stateMachine.currentState, .puzzleCompleted)
        XCTAssertTrue(puzzleEngine.isPuzzleCompleted())

        let progress = puzzleEngine.getCurrentProgress()!
        XCTAssertEqual(progress.completedObjectives.count, puzzle.objectives.count)
        XCTAssertEqual(progress.discoveredClues.count, puzzle.puzzleElements.count)
    }

    // MARK: - Error Handling Integration

    func testErrorRecovery() {
        // Given - Invalid state transition
        stateMachine.transition(to: .roomScanning)

        // When - Try invalid transition
        let success = stateMachine.transition(to: .puzzleCompleted)

        // Then - Should handle gracefully
        XCTAssertFalse(success)
        XCTAssertEqual(stateMachine.currentState, .roomScanning)
    }

    // MARK: - Performance Integration Tests

    func testIntegratedSystemPerformance() async {
        measure {
            Task {
                let mappingManager = SpatialMappingManager()
                await mappingManager.startRoomScanning()

                if let roomData = mappingManager.getCurrentRoomData() {
                    let puzzle = puzzleEngine.generatePuzzle(
                        type: .logic,
                        difficulty: .intermediate,
                        roomData: roomData
                    )

                    _ = puzzleEngine.validateSolution(
                        puzzle: puzzle,
                        solution: PuzzleSolution(answer: "test")
                    )
                }
            }
        }
    }
}

// MARK: - Mock System for Testing

class MockGameSystem: System {
    var updateCalled = false
    var updateCount = 0

    func update(deltaTime: TimeInterval) {
        updateCalled = true
        updateCount += 1
    }
}
