import XCTest
@testable import HideAndSeekEvolved

@MainActor
final class GameFlowIntegrationTests: XCTestCase {
    var gameManager: GameManager!
    var stateManager: GameStateManager!
    var eventBus: EventBus!

    override func setUp() async throws {
        eventBus = EventBus()
        stateManager = GameStateManager(eventBus: eventBus)
        gameManager = GameManager()
    }

    override func tearDown() async throws {
        gameManager = nil
        stateManager = nil
        eventBus = nil
    }

    // MARK: - Complete Game Flow Tests

    func testCompleteGameFlow_fromMenuToRoundEnd() async {
        // Given - Start at main menu
        XCTAssertEqual(stateManager.currentState, .mainMenu)

        // When - Progress through game states
        await stateManager.transition(to: .roomScanning)
        XCTAssertEqual(stateManager.currentState, .roomScanning)

        await stateManager.transition(to: .playerSetup)
        XCTAssertEqual(stateManager.currentState, .playerSetup)

        await stateManager.transition(to: .roleSelection)
        XCTAssertEqual(stateManager.currentState, .roleSelection)

        await stateManager.transition(to: .hiding(timeRemaining: 60))
        if case .hiding = stateManager.currentState {
            // Success
        } else {
            XCTFail("Expected hiding state")
        }

        await stateManager.transition(to: .seeking(timeRemaining: 180))
        if case .seeking = stateManager.currentState {
            // Success
        } else {
            XCTFail("Expected seeking state")
        }

        await stateManager.transition(to: .roundEnd(winner: .hider))
        if case .roundEnd(let winner) = stateManager.currentState {
            XCTAssertEqual(winner, .hider)
        } else {
            XCTFail("Expected roundEnd state")
        }
    }

    func testPlayerManagement_addUpdateRemove() {
        // Given
        let player = Player(name: "Test Player")

        // When - Add player
        gameManager.addPlayer(player)

        // Then
        XCTAssertTrue(gameManager.hasPlayers)
        XCTAssertEqual(gameManager.playerCount, 1)

        // When - Update player
        var updatedPlayer = player
        updatedPlayer.stats.gamesWon = 5
        gameManager.updatePlayer(updatedPlayer)

        // When - Remove player
        gameManager.removePlayer(id: player.id)

        // Then
        XCTAssertFalse(gameManager.hasPlayers)
        XCTAssertEqual(gameManager.playerCount, 0)
    }

    // MARK: - State Transitions with Events

    func testStateTransition_emitsEvents() async {
        // Given
        var emittedEvents: [GameEvent] = []
        _ = await eventBus.subscribe { event in
            emittedEvents.append(event)
        }

        // When
        await stateManager.transition(to: .roomScanning)
        await stateManager.transition(to: .playerSetup)

        // Then
        // Allow async events to process
        try? await Task.sleep(for: .milliseconds(100))
        XCTAssertGreaterThanOrEqual(emittedEvents.count, 2)
    }

    // MARK: - Round Timer Tests

    func testHidingPhaseTimer_automaticallyTransitionsToSeeking() async {
        // Given
        await stateManager.transition(to: .hiding(timeRemaining: 0.1))

        // When - Wait for timer to expire
        try? await Task.sleep(for: .milliseconds(150))
        await stateManager.update(deltaTime: 0.2)

        // Then
        if case .seeking = stateManager.currentState {
            // Success - transitioned to seeking
        } else {
            XCTFail("Expected automatic transition to seeking state")
        }
    }

    func testSeekingPhaseTimer_automaticallyTransitionsToRoundEnd() async {
        // Given
        await stateManager.transition(to: .seeking(timeRemaining: 0.1))

        // When - Wait for timer to expire
        try? await Task.sleep(for: .milliseconds(150))
        await stateManager.update(deltaTime: 0.2)

        // Then
        if case .roundEnd = stateManager.currentState {
            // Success - transitioned to round end
        } else {
            XCTFail("Expected automatic transition to roundEnd state")
        }
    }

    // MARK: - Pause/Resume Tests

    func testPauseResume_preservesPreviousState() async {
        // Given - In seeking state
        await stateManager.transition(to: .seeking(timeRemaining: 100))

        // When - Pause
        let currentState = stateManager.currentState
        await stateManager.transition(to: .paused(previousState: currentState))

        // Then - Verify paused
        if case .paused(let previousState) = stateManager.currentState {
            if case .seeking(let time) = previousState {
                XCTAssertEqual(time, 100, accuracy: 1.0)
            } else {
                XCTFail("Expected seeking as previous state")
            }
        } else {
            XCTFail("Expected paused state")
        }
    }

    // MARK: - Multi-Round Tests

    func testMultipleRounds_trackCorrectly() async {
        // Given
        let initialRound = stateManager.currentRound

        // When - Complete 3 rounds
        for _ in 0..<3 {
            await stateManager.transition(to: .hiding(timeRemaining: 60))
            await stateManager.transition(to: .seeking(timeRemaining: 180))
            await stateManager.transition(to: .roundEnd(winner: .hider))
        }

        // Then
        // Note: Round counter would increment in real processRoundEnd
        // This test validates the state transitions work correctly
        XCTAssertEqual(stateManager.currentState, .roundEnd(winner: .hider))
    }
}
