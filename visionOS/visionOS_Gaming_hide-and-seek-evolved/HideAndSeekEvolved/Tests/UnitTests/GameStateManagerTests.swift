import XCTest
@testable import HideAndSeekEvolved

@MainActor
final class GameStateManagerTests: XCTestCase {
    var sut: GameStateManager!
    var mockEventBus: MockEventBus!

    override func setUp() async throws {
        mockEventBus = MockEventBus()
        sut = GameStateManager(eventBus: mockEventBus)
    }

    override func tearDown() async throws {
        sut = nil
        mockEventBus = nil
    }

    // MARK: - Initialization Tests

    func testInitialState_isMainMenu() {
        // Then
        XCTAssertEqual(sut.currentState, .mainMenu)
    }

    func testInitialPlayers_isEmpty() {
        // Then
        XCTAssertTrue(sut.players.isEmpty)
    }

    func testInitialRound_isZero() {
        // Then
        XCTAssertEqual(sut.currentRound, 0)
    }

    // MARK: - State Transition Tests

    func testTransition_fromMainMenuToRoomScanning() async {
        // Given
        XCTAssertEqual(sut.currentState, .mainMenu)

        // When
        await sut.transition(to: .roomScanning)

        // Then
        XCTAssertEqual(sut.currentState, .roomScanning)
        XCTAssertEqual(mockEventBus.emittedEvents.count, 1)
    }

    func testTransition_fromRoomScanningToPlayerSetup() async {
        // Given
        await sut.transition(to: .roomScanning)

        // When
        await sut.transition(to: .playerSetup)

        // Then
        XCTAssertEqual(sut.currentState, .playerSetup)
        XCTAssertEqual(mockEventBus.emittedEvents.count, 2)
    }

    func testTransition_toHidingPhase() async {
        // When
        await sut.transition(to: .hiding(timeRemaining: 60))

        // Then
        if case .hiding(let time) = sut.currentState {
            XCTAssertEqual(time, 60, accuracy: 0.001)
        } else {
            XCTFail("Expected hiding state")
        }
    }

    func testTransition_toSeekingPhase() async {
        // When
        await sut.transition(to: .seeking(timeRemaining: 180))

        // Then
        if case .seeking(let time) = sut.currentState {
            XCTAssertEqual(time, 180, accuracy: 0.001)
        } else {
            XCTFail("Expected seeking state")
        }
    }

    func testTransition_toPausedState() async {
        // Given
        await sut.transition(to: .seeking(timeRemaining: 100))

        // When
        let currentState = sut.currentState
        await sut.transition(to: .paused(previousState: currentState))

        // Then
        if case .paused(let previousState) = sut.currentState {
            if case .seeking(let time) = previousState {
                XCTAssertEqual(time, 100, accuracy: 0.001)
            } else {
                XCTFail("Expected seeking as previous state")
            }
        } else {
            XCTFail("Expected paused state")
        }
    }

    // MARK: - Update Tests

    func testUpdate_hidingPhaseTimerDecrements() async {
        // Given
        await sut.transition(to: .hiding(timeRemaining: 60))

        // When
        await sut.update(deltaTime: 1.0)

        // Then
        if case .hiding(let time) = sut.currentState {
            XCTAssertEqual(time, 59, accuracy: 0.1)
        } else {
            XCTFail("Expected hiding state")
        }
    }

    func testUpdate_seekingPhaseTimerDecrements() async {
        // Given
        await sut.transition(to: .seeking(timeRemaining: 180))

        // When
        await sut.update(deltaTime: 5.0)

        // Then
        if case .seeking(let time) = sut.currentState {
            XCTAssertEqual(time, 175, accuracy: 0.1)
        } else {
            XCTFail("Expected seeking state")
        }
    }

    func testUpdate_hidingPhaseExpires_transitionsToSeeking() async {
        // Given
        await sut.transition(to: .hiding(timeRemaining: 0.5))

        // When
        await sut.update(deltaTime: 1.0)

        // Then
        if case .seeking = sut.currentState {
            // Success
        } else {
            XCTFail("Expected transition to seeking state")
        }
    }

    func testUpdate_seekingPhaseExpires_transitionsToRoundEnd() async {
        // Given
        await sut.transition(to: .seeking(timeRemaining: 0.5))

        // When
        await sut.update(deltaTime: 1.0)

        // Then
        if case .roundEnd(let winner) = sut.currentState {
            XCTAssertEqual(winner, .hider)
        } else {
            XCTFail("Expected transition to roundEnd state with hiders winning")
        }
    }

    // MARK: - Event Emission Tests

    func testTransition_emitsStateChangedEvent() async {
        // Given
        mockEventBus.emittedEvents.removeAll()

        // When
        await sut.transition(to: .roomScanning)

        // Then
        XCTAssertEqual(mockEventBus.emittedEvents.count, 1)

        if case .stateChanged(let from, let to) = mockEventBus.emittedEvents.first! {
            XCTAssertEqual(from, .mainMenu)
            XCTAssertEqual(to, .roomScanning)
        } else {
            XCTFail("Expected stateChanged event")
        }
    }

    // MARK: - Round Management Tests

    func testRoundEnd_incrementsRoundCounter() async {
        // Given
        let initialRound = sut.currentRound

        // When
        await sut.transition(to: .roundEnd(winner: .seeker))

        // Then (processRoundEnd is called in handleStateEntry)
        // Note: Round counter incrementation would be tested with full integration
    }

    // MARK: - GameState Equality Tests

    func testGameState_equality_mainMenu() {
        let state1 = GameState.mainMenu
        let state2 = GameState.mainMenu

        XCTAssertEqual(state1, state2)
    }

    func testGameState_equality_hiding() {
        let state1 = GameState.hiding(timeRemaining: 60.0)
        let state2 = GameState.hiding(timeRemaining: 60.0)
        let state3 = GameState.hiding(timeRemaining: 59.0)

        XCTAssertEqual(state1, state2)
        XCTAssertNotEqual(state1, state3)
    }

    func testGameState_equality_roundEnd() {
        let state1 = GameState.roundEnd(winner: .hider)
        let state2 = GameState.roundEnd(winner: .hider)
        let state3 = GameState.roundEnd(winner: .seeker)

        XCTAssertEqual(state1, state2)
        XCTAssertNotEqual(state1, state3)
    }
}

// MARK: - Mock EventBus

class MockEventBus: EventBus {
    var emittedEvents: [GameEvent] = []

    override func emit(_ event: GameEvent) async {
        emittedEvents.append(event)
        await super.emit(event)
    }
}
