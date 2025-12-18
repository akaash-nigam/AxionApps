import XCTest
@testable import TimeMachineAdventures

/// Unit tests for GameStateManager
final class GameStateManagerTests: XCTestCase {
    var sut: GameStateManager!

    override func setUp() {
        super.setUp()
        sut = GameStateManager()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Initialization Tests

    func testInitialState() {
        // Given/When - initialized in setUp()

        // Then
        XCTAssertEqual(sut.currentState, .initializing, "Should start in initializing state")
        XCTAssertNil(sut.previousState, "Should have no previous state initially")
        XCTAssertFalse(sut.canPopState, "Should not be able to pop state initially")
    }

    func testCustomInitialState() {
        // Given
        let customState = GameState.mainMenu

        // When
        sut = GameStateManager(initialState: customState)

        // Then
        XCTAssertEqual(sut.currentState, customState, "Should initialize with custom state")
    }

    // MARK: - State Transition Tests

    func testTransitionToNewState() {
        // Given
        let newState = GameState.mainMenu

        // When
        sut.transition(to: newState)

        // Then
        XCTAssertEqual(sut.currentState, newState, "Should transition to new state")
        XCTAssertEqual(sut.previousState, .initializing, "Should track previous state")
    }

    func testTransitionToSameStateIsIgnored() {
        // Given
        sut.transition(to: .mainMenu)
        let stateBefore = sut.currentState

        // When
        sut.transition(to: .mainMenu)

        // Then
        XCTAssertEqual(sut.currentState, stateBefore, "Should remain in same state")
    }

    func testMultipleTransitions() {
        // When
        sut.transition(to: .mainMenu)
        sut.transition(to: .selectingEra)
        sut.transition(to: .loadingEra(.ancientEgypt))

        // Then
        XCTAssertEqual(sut.currentState, .loadingEra(.ancientEgypt))
        XCTAssertEqual(sut.previousState, .selectingEra)
    }

    // MARK: - State Stack Tests

    func testPushState() {
        // Given
        sut.transition(to: .exploring(.ancientEgypt))

        // When
        sut.pushState(.pause)

        // Then
        XCTAssertEqual(sut.currentState, .pause, "Should be in pushed state")
        XCTAssertTrue(sut.canPopState, "Should be able to pop state")
    }

    func testPopState() {
        // Given
        sut.transition(to: .exploring(.ancientEgypt))
        sut.pushState(.pause)

        // When
        let didPop = sut.popState()

        // Then
        XCTAssertTrue(didPop, "Should successfully pop state")
        XCTAssertEqual(sut.currentState, .exploring(.ancientEgypt), "Should return to previous state")
        XCTAssertFalse(sut.canPopState, "Should not be able to pop again")
    }

    func testPopEmptyStack() {
        // When
        let didPop = sut.popState()

        // Then
        XCTAssertFalse(didPop, "Should not pop empty stack")
        XCTAssertEqual(sut.currentState, .initializing, "Should remain in current state")
    }

    func testMultiplePushAndPop() {
        // Given
        sut.transition(to: .exploring(.ancientEgypt))
        sut.pushState(.examiningArtifact("artifact1"))
        sut.pushState(.pause)

        // When/Then - First pop
        XCTAssertTrue(sut.popState())
        XCTAssertEqual(sut.currentState, .examiningArtifact("artifact1"))

        // When/Then - Second pop
        XCTAssertTrue(sut.popState())
        XCTAssertEqual(sut.currentState, .exploring(.ancientEgypt))

        // When/Then - Third pop fails
        XCTAssertFalse(sut.popState())
    }

    func testClearStateStack() {
        // Given
        sut.transition(to: .exploring(.ancientEgypt))
        sut.pushState(.pause)
        sut.pushState(.settings)

        // When
        sut.clearStateStack()

        // Then
        XCTAssertFalse(sut.canPopState, "Stack should be empty")
        XCTAssertEqual(sut.currentState, .settings, "Should remain in current state")
    }

    // MARK: - State Observer Tests

    func testOnEnterCallback() {
        // Given
        var enteredState: GameState?
        sut.onEnter { state in
            enteredState = state
        }

        // When
        sut.transition(to: .mainMenu)

        // Then
        XCTAssertEqual(enteredState, .mainMenu, "Enter callback should be called with new state")
    }

    func testOnExitCallback() {
        // Given
        var exitedState: GameState?
        sut.onExit { state in
            exitedState = state
        }

        // When
        sut.transition(to: .mainMenu)

        // Then
        XCTAssertEqual(exitedState, .initializing, "Exit callback should be called with old state")
    }

    func testMultipleCallbacks() {
        // Given
        var enterCount = 0
        var exitCount = 0

        sut.onEnter { _ in enterCount += 1 }
        sut.onEnter { _ in enterCount += 1 }
        sut.onExit { _ in exitCount += 1 }

        // When
        sut.transition(to: .mainMenu)

        // Then
        XCTAssertEqual(enterCount, 2, "Both enter callbacks should be called")
        XCTAssertEqual(exitCount, 1, "Exit callback should be called")
    }

    // MARK: - State Query Tests

    func testIsInActiveGameplay() {
        // When/Then - Not in gameplay
        sut.transition(to: .mainMenu)
        XCTAssertFalse(sut.isInActiveGameplay)

        // When/Then - In gameplay
        sut.transition(to: .exploring(.ancientEgypt))
        XCTAssertTrue(sut.isInActiveGameplay)

        sut.transition(to: .examiningArtifact("artifact1"))
        XCTAssertTrue(sut.isInActiveGameplay)

        sut.transition(to: .conversing("caesar"))
        XCTAssertTrue(sut.isInActiveGameplay)
    }

    func testCurrentEra() {
        // When/Then - No era
        XCTAssertNil(sut.currentEra)

        // When/Then - Loading era
        sut.transition(to: .loadingEra(.ancientEgypt))
        XCTAssertEqual(sut.currentEra, .ancientEgypt)

        // When/Then - Exploring era
        sut.transition(to: .exploring(.medievalEurope))
        XCTAssertEqual(sut.currentEra, .medievalEurope)

        // When/Then - Left era
        sut.transition(to: .mainMenu)
        XCTAssertNil(sut.currentEra)
    }

    func testShouldPlayBackgroundAudio() {
        // When/Then - Menu (no audio)
        sut.transition(to: .mainMenu)
        XCTAssertFalse(sut.shouldPlayBackgroundAudio)

        // When/Then - Exploring (audio)
        sut.transition(to: .exploring(.ancientEgypt))
        XCTAssertTrue(sut.shouldPlayBackgroundAudio)

        // When/Then - Examining artifact (audio)
        sut.transition(to: .examiningArtifact("artifact1"))
        XCTAssertTrue(sut.shouldPlayBackgroundAudio)
    }

    // MARK: - State Validation Tests

    func testIsValidTransition() {
        // Then - Invalid transitions
        XCTAssertFalse(
            sut.isValidTransition(from: .initializing, to: .exploring(.ancientEgypt)),
            "Should not go directly from initializing to exploring"
        )

        XCTAssertFalse(
            sut.isValidTransition(from: .calibrating, to: .exploring(.ancientEgypt)),
            "Should not go directly from calibrating to exploring"
        )

        // Then - Valid transitions
        XCTAssertTrue(
            sut.isValidTransition(from: .initializing, to: .mainMenu),
            "Should be able to go from initializing to mainMenu"
        )

        XCTAssertTrue(
            sut.isValidTransition(from: .selectingEra, to: .loadingEra(.ancientEgypt)),
            "Should be able to load era after selecting"
        )
    }

    func testValidNextStates() {
        // When - Initializing
        sut.transition(to: .initializing)
        XCTAssertTrue(sut.validNextStates.contains(.calibrating))
        XCTAssertTrue(sut.validNextStates.contains(.mainMenu))

        // When - Main menu
        sut.transition(to: .mainMenu)
        XCTAssertTrue(sut.validNextStates.contains(.selectingEra))
        XCTAssertTrue(sut.validNextStates.contains(.settings))
        XCTAssertTrue(sut.validNextStates.contains(.viewingTimeline))
    }

    // MARK: - Integration Tests

    func testCompleteGameFlowTransitions() {
        // Simulate a complete game flow
        sut.transition(to: .calibrating)
        XCTAssertEqual(sut.currentState, .calibrating)

        sut.transition(to: .mainMenu)
        XCTAssertEqual(sut.currentState, .mainMenu)

        sut.transition(to: .selectingEra)
        XCTAssertEqual(sut.currentState, .selectingEra)

        sut.transition(to: .loadingEra(.ancientEgypt))
        XCTAssertEqual(sut.currentState, .loadingEra(.ancientEgypt))

        sut.transition(to: .exploring(.ancientEgypt))
        XCTAssertEqual(sut.currentState, .exploring(.ancientEgypt))
        XCTAssertTrue(sut.isInActiveGameplay)

        sut.pushState(.examiningArtifact("pottery1"))
        XCTAssertEqual(sut.currentState, .examiningArtifact("pottery1"))

        sut.popState()
        XCTAssertEqual(sut.currentState, .exploring(.ancientEgypt))
    }

    // MARK: - Performance Tests

    func testTransitionPerformance() {
        measure {
            for _ in 0..<1000 {
                sut.transition(to: .mainMenu)
                sut.transition(to: .exploring(.ancientEgypt))
            }
        }
    }
}

// MARK: - Test Helpers

extension GameStateManagerTests {
    /// Create a test historical era
    private var testEra: HistoricalEra {
        .ancientEgypt
    }
}
