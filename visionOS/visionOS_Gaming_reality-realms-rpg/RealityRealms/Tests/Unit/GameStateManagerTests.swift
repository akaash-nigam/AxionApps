//
//  GameStateManagerTests.swift
//  Reality Realms RPG Tests
//
//  Unit tests for GameStateManager
//

import XCTest
@testable import RealityRealms

@MainActor
final class GameStateManagerTests: XCTestCase {

    var sut: GameStateManager!

    override func setUp() async throws {
        try await super.setUp()
        sut = GameStateManager.shared
    }

    override func tearDown() async throws {
        sut = nil
        try await super.tearDown()
    }

    // MARK: - State Transition Tests

    func testInitialState() {
        XCTAssertEqual(sut.currentState, .initialization)
        XCTAssertFalse(sut.isGameActive)
    }

    func testTransitionFromInitializationToRoomScanning() {
        sut.transition(to: .roomScanning)
        XCTAssertEqual(sut.currentState, .roomScanning)
    }

    func testTransitionFromRoomScanningToTutorial() {
        sut.transition(to: .roomScanning)
        sut.transition(to: .tutorial)
        XCTAssertEqual(sut.currentState, .tutorial)
    }

    func testTransitionFromTutorialToGameplay() {
        sut.transition(to: .roomScanning)
        sut.transition(to: .tutorial)
        sut.transition(to: .gameplay(.exploration))

        if case .gameplay(.exploration) = sut.currentState {
            XCTAssertTrue(true)
        } else {
            XCTFail("Expected gameplay state with exploration")
        }
    }

    func testInvalidTransitionPrevented() {
        // Try to go directly from initialization to gameplay (invalid)
        sut.transition(to: .gameplay(.exploration))

        // Should remain in initialization
        XCTAssertEqual(sut.currentState, .initialization)
    }

    func testGameActiveWhenInGameplayState() {
        sut.transition(to: .roomScanning)
        sut.transition(to: .tutorial)
        sut.transition(to: .gameplay(.exploration))

        XCTAssertTrue(sut.isGameActive)
    }

    func testGameInactiveWhenNotInGameplayState() {
        sut.transition(to: .roomScanning)
        XCTAssertFalse(sut.isGameActive)
    }

    // MARK: - Pause/Resume Tests

    func testPauseGame() {
        sut.transition(to: .roomScanning)
        sut.transition(to: .tutorial)
        sut.transition(to: .gameplay(.exploration))

        sut.pauseGame(true)
        XCTAssertEqual(sut.currentState, .paused)
    }

    func testResumeGame() {
        sut.transition(to: .roomScanning)
        sut.transition(to: .tutorial)
        sut.transition(to: .gameplay(.exploration))
        sut.pauseGame(true)
        sut.pauseGame(false)

        if case .gameplay = sut.currentState {
            XCTAssertTrue(true)
        } else {
            XCTFail("Expected gameplay state after resume")
        }
    }

    // MARK: - Combat State Tests

    func testEnterCombat() {
        sut.transition(to: .roomScanning)
        sut.transition(to: .tutorial)
        sut.transition(to: .gameplay(.exploration))

        sut.enterCombat(enemyCount: 3)

        if case .gameplay(.combat(let count)) = sut.currentState {
            XCTAssertEqual(count, 3)
        } else {
            XCTFail("Expected combat state with 3 enemies")
        }
    }

    func testExitCombat() {
        sut.transition(to: .roomScanning)
        sut.transition(to: .tutorial)
        sut.transition(to: .gameplay(.exploration))
        sut.enterCombat(enemyCount: 3)

        sut.exitCombat()

        if case .gameplay(.exploration) = sut.currentState {
            XCTAssertTrue(true)
        } else {
            XCTFail("Expected exploration state after exiting combat")
        }
    }

    // MARK: - Inventory Tests

    func testShowInventory() {
        sut.transition(to: .roomScanning)
        sut.transition(to: .tutorial)
        sut.transition(to: .gameplay(.exploration))

        sut.showInventory()

        if case .gameplay(.inventory) = sut.currentState {
            XCTAssertTrue(true)
        } else {
            XCTFail("Expected inventory state")
        }
    }

    func testCloseInventory() {
        sut.transition(to: .roomScanning)
        sut.transition(to: .tutorial)
        sut.transition(to: .gameplay(.exploration))
        sut.showInventory()

        sut.closeInventory()

        if case .gameplay(.exploration) = sut.currentState {
            XCTAssertTrue(true)
        } else {
            XCTFail("Expected exploration state after closing inventory")
        }
    }

    // MARK: - Error Handling Tests

    func testReportError() {
        sut.reportError(.roomMappingFailed)

        if case .error = sut.currentState {
            XCTAssertTrue(true)
        } else {
            XCTFail("Expected error state")
        }
    }
}
