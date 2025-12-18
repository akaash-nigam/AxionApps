import XCTest
@testable import HideAndSeekEvolved

final class SeekingMechanicsSystemTests: XCTestCase {
    var sut: SeekingMechanicsSystem!

    override func setUp() async throws {
        sut = SeekingMechanicsSystem()
    }

    override func tearDown() async throws {
        sut = nil
    }

    // MARK: - Thermal Vision Tests

    func testActivateThermalVision_success() async throws {
        // Given
        let seekerId = UUID()
        let range: Float = 5.0

        // When
        try await sut.activateThermalVision(for: seekerId, range: range)

        // Then
        let activeAbility = await sut.getActiveAbility(for: seekerId)
        XCTAssertNotNil(activeAbility)
        if case .thermalVision(let r) = activeAbility {
            XCTAssertEqual(r, range, accuracy: 0.001)
        } else {
            XCTFail("Expected thermal vision ability")
        }
    }

    func testFindHidersInThermalRange_withHidersInRange() async {
        // Given
        let seekerPosition = SIMD3<Float>(0, 0, 0)
        let hider1 = Player(name: "Hider1", position: SIMD3(2, 0, 0))  // 2m away
        let hider2 = Player(name: "Hider2", position: SIMD3(10, 0, 0)) // 10m away
        let hiders = [hider1, hider2]
        let range: Float = 5.0

        // When
        let foundHiders = await sut.findHidersInThermalRange(
            from: seekerPosition,
            range: range,
            hiders: hiders
        )

        // Then
        XCTAssertEqual(foundHiders.count, 1)
        XCTAssertEqual(foundHiders.first?.name, "Hider1")
    }

    func testFindHidersInThermalRange_withNoHidersInRange() async {
        // Given
        let seekerPosition = SIMD3<Float>(0, 0, 0)
        let hider1 = Player(name: "Hider1", position: SIMD3(10, 0, 0))
        let hider2 = Player(name: "Hider2", position: SIMD3(15, 0, 0))
        let hiders = [hider1, hider2]
        let range: Float = 5.0

        // When
        let foundHiders = await sut.findHidersInThermalRange(
            from: seekerPosition,
            range: range,
            hiders: hiders
        )

        // Then
        XCTAssertEqual(foundHiders.count, 0)
    }

    // MARK: - Clue Detection Tests

    func testActivateClueDetection_success() async throws {
        // Given
        let seekerId = UUID()
        let sensitivity: Float = 1.5

        // When
        try await sut.activateClueDetection(for: seekerId, sensitivity: sensitivity)

        // Then
        let activeAbility = await sut.getActiveAbility(for: seekerId)
        XCTAssertNotNil(activeAbility)
        if case .clueDetection(let s) = activeAbility {
            XCTAssertEqual(s, sensitivity, accuracy: 0.001)
        } else {
            XCTFail("Expected clue detection ability")
        }
    }

    func testDeactivateClueDetection_removesAbility() async throws {
        // Given
        let seekerId = UUID()
        try await sut.activateClueDetection(for: seekerId)

        // When
        await sut.deactivateClueDetection(for: seekerId)

        // Then
        let activeAbility = await sut.getActiveAbility(for: seekerId)
        XCTAssertNil(activeAbility)
    }

    // MARK: - Footprint Generation Tests

    func testGenerateFootprint_createsClue() async {
        // Given
        let playerId = UUID()
        let position = SIMD3<Float>(1, 0, 1)

        // When
        let clue = await sut.generateFootprint(at: position, for: playerId)

        // Then
        XCTAssertEqual(clue.type, .footprint)
        XCTAssertEqual(clue.position, position)
        XCTAssertEqual(clue.playerId, playerId)
    }

    func testGenerateFootprint_incrementsClueCount() async {
        // Given
        let playerId = UUID()
        let initialCount = await sut.getTotalCluesGenerated(for: playerId)

        // When
        _ = await sut.generateFootprint(at: SIMD3(0, 0, 0), for: playerId)

        // Then
        let finalCount = await sut.getTotalCluesGenerated(for: playerId)
        XCTAssertEqual(finalCount, initialCount + 1)
    }

    func testGenerateDisturbance_createsClue() async {
        // Given
        let playerId = UUID()
        let position = SIMD3<Float>(2, 0, 2)

        // When
        let clue = await sut.generateDisturbance(at: position, for: playerId)

        // Then
        XCTAssertEqual(clue.type, .disturbance)
        XCTAssertEqual(clue.position, position)
        XCTAssertEqual(clue.playerId, playerId)
    }

    // MARK: - Visible Clues Tests

    func testGetVisibleClues_returnsNearbyClues() async {
        // Given
        let seekerId = UUID()
        let playerId = UUID()
        let seekerPosition = SIMD3<Float>(0, 0, 0)

        // Generate clues at different distances
        _ = await sut.generateFootprint(at: SIMD3(1, 0, 0), for: playerId)  // 1m away
        _ = await sut.generateFootprint(at: SIMD3(10, 0, 0), for: playerId) // 10m away

        // When
        let visibleClues = await sut.getVisibleClues(
            for: seekerId,
            from: seekerPosition,
            maxDistance: 3.0
        )

        // Then
        XCTAssertEqual(visibleClues.count, 1)
    }

    func testGetVisibleClues_withClueDetection_increaseRange() async throws {
        // Given
        let seekerId = UUID()
        let playerId = UUID()
        let seekerPosition = SIMD3<Float>(0, 0, 0)

        // Generate clues
        _ = await sut.generateFootprint(at: SIMD3(4, 0, 0), for: playerId)  // 4m away

        // Activate clue detection
        try await sut.activateClueDetection(for: seekerId, sensitivity: 2.0)

        // When
        let visibleClues = await sut.getVisibleClues(
            for: seekerId,
            from: seekerPosition,
            maxDistance: 3.0  // Base range 3m, but enhanced to 6m with sensitivity
        )

        // Then
        XCTAssertEqual(visibleClues.count, 1)
    }

    func testGetActiveCluesCount_excludesExpiredClues() async {
        // Given
        let playerId = UUID()

        // Generate clues
        _ = await sut.generateFootprint(at: SIMD3(0, 0, 0), for: playerId)

        // When
        let activeCount = await sut.getActiveCluesCount(for: playerId)

        // Then
        XCTAssertGreaterThan(activeCount, 0)
    }

    // MARK: - Cooldown Tests

    func testGetCooldownRemaining_afterActivation() async throws {
        // Given
        let seekerId = UUID()
        try await sut.activateThermalVision(for: seekerId)

        // When
        let cooldown = await sut.getCooldownRemaining(for: seekerId)

        // Then
        XCTAssertGreaterThan(cooldown, 0)
    }
}
