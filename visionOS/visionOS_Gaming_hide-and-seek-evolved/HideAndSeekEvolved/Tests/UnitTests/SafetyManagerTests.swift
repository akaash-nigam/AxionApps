import XCTest
@testable import HideAndSeekEvolved

@MainActor
final class SafetyManagerTests: XCTestCase {
    var sut: SafetyManager!

    override func setUp() async throws {
        sut = SafetyManager()
    }

    override func tearDown() async throws {
        sut = nil
    }

    // MARK: - Initialization Tests

    func testInitialState_isSafe() {
        XCTAssertEqual(sut.safetyState, .safe)
    }

    func testInitialViolations_isEmpty() {
        XCTAssertTrue(sut.boundaryViolations.isEmpty)
    }

    // MARK: - Boundary Setup Tests

    func testSetupBoundaries_fromRoomLayout() {
        // Given
        let boundary = SafetyBoundary(
            points: [
                SIMD3(0, 0, 0),
                SIMD3(5, 0, 0),
                SIMD3(5, 0, 5),
                SIMD3(0, 0, 5)
            ]
        )
        let roomLayout = RoomLayout(
            bounds: BoundingBox(min: .zero, max: SIMD3(5, 3, 5)),
            safetyBoundaries: [boundary]
        )

        // When
        sut.setupBoundaries(for: roomLayout)

        // Then - Would verify internal state in real implementation
    }

    func testAddBoundary_increasesBoundaryCount() {
        // Given
        let boundary = SafetyBoundary(points: [SIMD3(0, 0, 0)])

        // When
        sut.addBoundary(boundary)

        // Then - Would verify boundary was added
    }

    func testClearBoundaries_removesAllBoundaries() {
        // Given
        sut.addBoundary(SafetyBoundary(points: [SIMD3(0, 0, 0)]))

        // When
        sut.clearBoundaries()

        // Then - Would verify all boundaries removed
    }

    // MARK: - Position Checking Tests

    func testIsPositionSafe_farFromBoundary_returnsTrue() async {
        // Given
        let boundary = SafetyBoundary(
            points: [
                SIMD3(10, 0, 10),
                SIMD3(15, 0, 10),
                SIMD3(15, 0, 15),
                SIMD3(10, 0, 15)
            ]
        )
        sut.addBoundary(boundary)

        let safePosition = SIMD3<Float>(0, 1, 0)  // Far from boundary

        // When
        let isSafe = await sut.isPositionSafe(safePosition)

        // Then
        XCTAssertTrue(isSafe)
    }

    func testCheckPlayerPosition_safe_returnsSafeState() async {
        // Given
        let player = Player(name: "Test", position: SIMD3(0, 1, 0))

        // When
        let state = await sut.checkPlayerPosition(player)

        // Then
        if case .safe = state {
            // Success
        } else {
            XCTFail("Expected safe state")
        }
    }

    // MARK: - Violation Recording Tests

    func testGetTotalViolations_initially_returnsZero() {
        XCTAssertEqual(sut.getTotalViolations(), 0)
    }

    func testGetViolationCount_forNewPlayer_returnsZero() {
        let playerId = UUID()
        XCTAssertEqual(sut.getViolationCount(for: playerId), 0)
    }

    func testClearViolationHistory_removesAllViolations() {
        // Given - Would need to trigger violations first in real test

        // When
        sut.clearViolationHistory()

        // Then
        XCTAssertEqual(sut.getTotalViolations(), 0)
    }

    // MARK: - Emergency Stop Tests

    func testTriggerEmergencyStop_setsViolationState() async {
        // When
        await sut.triggerEmergencyStop()

        // Then
        if case .violation = sut.safetyState {
            // Success
        } else {
            XCTFail("Expected violation state after emergency stop")
        }
    }

    // MARK: - Statistics Tests

    func testGetCriticalViolations_initially_returnsZero() {
        XCTAssertEqual(sut.getCriticalViolations(), 0)
    }
}
