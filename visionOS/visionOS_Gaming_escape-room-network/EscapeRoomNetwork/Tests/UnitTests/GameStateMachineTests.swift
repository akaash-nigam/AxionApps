import XCTest
@testable import EscapeRoomNetwork

/// Unit tests for game state machine
final class GameStateMachineTests: XCTestCase {

    var sut: GameStateMachine!

    override func setUp() {
        super.setUp()
        sut = GameStateMachine()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Initialization Tests

    func testInitialState() {
        // Then
        XCTAssertEqual(sut.currentState, .initialization)
    }

    func testCustomInitialState() {
        // Given
        let stateMachine = GameStateMachine(initialState: .playing)

        // Then
        XCTAssertEqual(stateMachine.currentState, .playing)
    }

    // MARK: - State Transition Tests

    func testValidTransitionFromInitialization() {
        // When
        let success = sut.transition(to: .roomScanning)

        // Then
        XCTAssertTrue(success)
        XCTAssertEqual(sut.currentState, .roomScanning)
    }

    func testInvalidTransitionFromInitialization() {
        // When
        let success = sut.transition(to: .playing)

        // Then
        XCTAssertFalse(success)
        XCTAssertEqual(sut.currentState, .initialization)
    }

    func testTransitionToSameState() {
        // When
        let success = sut.transition(to: .initialization)

        // Then
        XCTAssertFalse(success)
        XCTAssertEqual(sut.currentState, .initialization)
    }

    func testCompleteGameFlow() {
        // Given - Start from initialization
        XCTAssertEqual(sut.currentState, .initialization)

        // When - Go through typical game flow
        XCTAssertTrue(sut.transition(to: .roomScanning))
        XCTAssertEqual(sut.currentState, .roomScanning)

        XCTAssertTrue(sut.transition(to: .roomMapping))
        XCTAssertEqual(sut.currentState, .roomMapping)

        XCTAssertTrue(sut.transition(to: .loadingPuzzle))
        XCTAssertEqual(sut.currentState, .loadingPuzzle)

        XCTAssertTrue(sut.transition(to: .playing))
        XCTAssertEqual(sut.currentState, .playing)

        XCTAssertTrue(sut.transition(to: .puzzleCompleted))
        XCTAssertEqual(sut.currentState, .puzzleCompleted)
    }

    func testPauseAndResume() {
        // Given - Get to playing state
        sut.transition(to: .roomScanning)
        sut.transition(to: .roomMapping)
        sut.transition(to: .loadingPuzzle)
        sut.transition(to: .playing)

        // When - Pause game
        XCTAssertTrue(sut.transition(to: .paused))
        XCTAssertEqual(sut.currentState, .paused)

        // When - Resume game
        XCTAssertTrue(sut.transition(to: .playing))
        XCTAssertEqual(sut.currentState, .playing)
    }

    func testMultiplayerFlow() {
        // Given
        XCTAssertEqual(sut.currentState, .initialization)

        // When - Enter multiplayer
        XCTAssertTrue(sut.transition(to: .multiplayerLobby))
        XCTAssertEqual(sut.currentState, .multiplayerLobby)

        XCTAssertTrue(sut.transition(to: .multiplayerSession))
        XCTAssertEqual(sut.currentState, .multiplayerSession)

        XCTAssertTrue(sut.transition(to: .roomScanning))
        XCTAssertEqual(sut.currentState, .roomScanning)
    }

    // MARK: - State Change Listener Tests

    func testStateChangeListener() {
        // Given
        var stateChanges: [(from: GameState, to: GameState)] = []

        sut.addStateChangeListener { from, to in
            stateChanges.append((from: from, to: to))
        }

        // When
        sut.transition(to: .roomScanning)
        sut.transition(to: .roomMapping)

        // Then
        XCTAssertEqual(stateChanges.count, 2)
        XCTAssertEqual(stateChanges[0].from, .initialization)
        XCTAssertEqual(stateChanges[0].to, .roomScanning)
        XCTAssertEqual(stateChanges[1].from, .roomScanning)
        XCTAssertEqual(stateChanges[1].to, .roomMapping)
    }

    func testMultipleListeners() {
        // Given
        var listener1Called = false
        var listener2Called = false

        sut.addStateChangeListener { _, _ in
            listener1Called = true
        }

        sut.addStateChangeListener { _, _ in
            listener2Called = true
        }

        // When
        sut.transition(to: .roomScanning)

        // Then
        XCTAssertTrue(listener1Called)
        XCTAssertTrue(listener2Called)
    }

    // MARK: - Update Tests

    func testUpdate() {
        // Given
        let deltaTime: TimeInterval = 0.016

        // When - Should not crash
        sut.update(deltaTime: deltaTime)

        // Then - No assertion needed, just checking it doesn't crash
    }

    // MARK: - Edge Case Tests

    func testGameOverTransition() {
        // Given - Get to playing state
        sut.transition(to: .roomScanning)
        sut.transition(to: .roomMapping)
        sut.transition(to: .loadingPuzzle)
        sut.transition(to: .playing)

        // When - Go to game over
        XCTAssertTrue(sut.transition(to: .gameOver))
        XCTAssertEqual(sut.currentState, .gameOver)

        // Then - Can only go back to initialization
        XCTAssertTrue(sut.transition(to: .initialization))
        XCTAssertEqual(sut.currentState, .initialization)
    }

    func testPuzzleCompletionFlow() {
        // Given - Complete a puzzle
        sut.transition(to: .roomScanning)
        sut.transition(to: .roomMapping)
        sut.transition(to: .loadingPuzzle)
        sut.transition(to: .playing)
        sut.transition(to: .puzzleCompleted)

        // When - Load next puzzle
        XCTAssertTrue(sut.transition(to: .loadingPuzzle))
        XCTAssertEqual(sut.currentState, .loadingPuzzle)

        // Then - Can play again
        XCTAssertTrue(sut.transition(to: .playing))
        XCTAssertEqual(sut.currentState, .playing)
    }

    func testBackToRoomScanningFromMultiplayer() {
        // Given
        sut.transition(to: .multiplayerLobby)
        sut.transition(to: .multiplayerSession)

        // When
        XCTAssertTrue(sut.transition(to: .roomScanning))

        // Then
        XCTAssertEqual(sut.currentState, .roomScanning)
    }

    // MARK: - Performance Tests

    func testStateTransitionPerformance() {
        measure {
            // Perform rapid state transitions
            for _ in 0..<1000 {
                sut.transition(to: .roomScanning)
                sut.transition(to: .roomMapping)
                sut.transition(to: .loadingPuzzle)
                sut.transition(to: .playing)
                sut.transition(to: .paused)
                sut.transition(to: .playing)
                sut.transition(to: .puzzleCompleted)
                sut.transition(to: .initialization)
            }
        }
    }
}
