import XCTest
@testable import EscapeRoomNetwork

/// Unit tests for game loop manager
final class GameLoopManagerTests: XCTestCase {

    var sut: GameLoopManager!

    override func setUp() {
        super.setUp()
        sut = GameLoopManager(targetFrameRate: 60)
    }

    override func tearDown() {
        sut?.stop()
        sut = nil
        super.tearDown()
    }

    // MARK: - Initialization Tests

    func testInitialization() {
        // Then
        XCTAssertNotNil(sut)
        XCTAssertEqual(sut.currentFPS, 0)
    }

    func testCustomTargetFrameRate() {
        // Given
        let customSut = GameLoopManager(targetFrameRate: 120)

        // Then
        XCTAssertNotNil(customSut)
    }

    // MARK: - Start/Stop Tests

    func testStartGameLoop() {
        // When
        sut.start()

        // Then - Give it a moment to start
        let expectation = XCTestExpectation(description: "Game loop started")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
        sut.stop()
    }

    func testStopGameLoop() {
        // Given
        sut.start()

        // When
        sut.stop()

        // Then - Should not crash
    }

    func testStartAlreadyRunningLoop() {
        // Given
        sut.start()

        // When - Try to start again
        sut.start()

        // Then - Should handle gracefully
        sut.stop()
    }

    func testStopNotRunningLoop() {
        // When
        sut.stop()

        // Then - Should handle gracefully without crashing
    }

    // MARK: - System Management Tests

    func testAddSystem() {
        // Given
        let mockSystem = MockSystem()

        // When
        sut.addSystem(mockSystem)

        // Then - Should not crash, system should be added
    }

    func testRemoveSystem() {
        // Given
        let mockSystem = MockSystem()
        sut.addSystem(mockSystem)

        // When
        sut.removeSystem(mockSystem)

        // Then - Should not crash
    }

    func testRemoveAllSystems() {
        // Given
        sut.addSystem(MockSystem())
        sut.addSystem(MockSystem())
        sut.addSystem(MockSystem())

        // When
        sut.removeAllSystems()

        // Then - Should not crash
    }

    func testMultipleSystemsUpdate() {
        // Given
        let system1 = MockSystem()
        let system2 = MockSystem()
        let system3 = MockSystem()

        sut.addSystem(system1)
        sut.addSystem(system2)
        sut.addSystem(system3)

        // When
        sut.start()

        // Then - Wait for at least one update
        let expectation = XCTestExpectation(description: "Systems updated")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertTrue(system1.updateCalled)
            XCTAssertTrue(system2.updateCalled)
            XCTAssertTrue(system3.updateCalled)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
        sut.stop()
    }

    // MARK: - FPS Tracking Tests

    func testFPSTracking() {
        // Given
        sut.start()

        // When - Wait for FPS to be calculated
        let expectation = XCTestExpectation(description: "FPS calculated")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            // Then
            XCTAssertGreaterThan(self.sut.currentFPS, 0)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2.0)
        sut.stop()
    }

    // MARK: - Integration Tests

    func testStartStopMultipleTimes() {
        // When/Then - Should handle multiple start/stop cycles
        for _ in 0..<5 {
            sut.start()
            Thread.sleep(forTimeInterval: 0.05)
            sut.stop()
        }
    }

    // MARK: - Performance Tests

    func testGameLoopPerformance() {
        // Given
        let system = MockSystem()
        sut.addSystem(system)

        measure {
            sut.start()
            Thread.sleep(forTimeInterval: 0.1)
            sut.stop()
        }
    }
}

// MARK: - Mock System

class MockSystem: System {
    var updateCalled = false
    var updateCount = 0

    func update(deltaTime: TimeInterval) {
        updateCalled = true
        updateCount += 1
    }
}
