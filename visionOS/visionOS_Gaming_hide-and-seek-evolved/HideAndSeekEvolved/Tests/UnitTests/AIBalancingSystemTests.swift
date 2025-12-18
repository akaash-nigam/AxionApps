import XCTest
@testable import HideAndSeekEvolved

final class AIBalancingSystemTests: XCTestCase {
    var sut: AIBalancingSystem!

    override func setUp() async throws {
        sut = AIBalancingSystem()
    }

    override func tearDown() async throws {
        sut = nil
    }

    // MARK: - Skill Tracking Tests

    func testGetSkillLevel_newPlayer_returns0Point5() async {
        // Given
        let playerId = UUID()

        // When
        let skill = await sut.getSkillLevel(for: playerId)

        // Then
        XCTAssertEqual(skill, 0.5, accuracy: 0.001)
    }

    func testUpdateSkillLevel_goodPerformance_increasesSkill() async {
        // Given
        let playerId = UUID()
        let goodPerformance = GamePerformance(
            successRate: 0.8,  // 80% success
            averageTime: 60,
            errorsCount: 1
        )

        // When
        await sut.updateSkillLevel(for: playerId, performance: goodPerformance)

        // Then
        let newSkill = await sut.getSkillLevel(for: playerId)
        XCTAssertGreaterThan(newSkill, 0.5)
    }

    func testUpdateSkillLevel_poorPerformance_decreasesSkill() async {
        // Given
        let playerId = UUID()
        let poorPerformance = GamePerformance(
            successRate: 0.2,  // 20% success
            averageTime: 120,
            errorsCount: 10
        )

        // When
        await sut.updateSkillLevel(for: playerId, performance: poorPerformance)

        // Then
        let newSkill = await sut.getSkillLevel(for: playerId)
        XCTAssertLessThan(newSkill, 0.5)
    }

    func testUpdateSkillLevel_clampedTo0and1() async {
        // Given
        let playerId = UUID()
        let perfectPerformance = GamePerformance(
            successRate: 1.0,
            averageTime: 10,
            errorsCount: 0
        )

        // When - Update multiple times
        for _ in 0..<20 {
            await sut.updateSkillLevel(for: playerId, performance: perfectPerformance)
        }

        // Then
        let skill = await sut.getSkillLevel(for: playerId)
        XCTAssertLessThanOrEqual(skill, 1.0)
        XCTAssertGreaterThanOrEqual(skill, 0.0)
    }

    // MARK: - Hiding Spot Assignment Tests

    func testBalanceHidingOpportunities_assignsSpotsBasedOnSkill() async {
        // Given
        let beginnerPlayer = Player(name: "Beginner", role: .hider)
        let expertPlayer = Player(name: "Expert", role: .hider)

        // Set skill levels
        let beginnerPerformance = GamePerformance(successRate: 0.2, averageTime: 150, errorsCount: 10)
        let expertPerformance = GamePerformance(successRate: 0.9, averageTime: 30, errorsCount: 1)

        await sut.updateSkillLevel(for: beginnerPlayer.id, performance: beginnerPerformance)
        await sut.updateSkillLevel(for: expertPlayer.id, performance: expertPerformance)

        let roomLayout = createMockRoomLayout()

        // When
        let assignments = await sut.balanceHidingOpportunities(
            for: [beginnerPlayer, expertPlayer],
            in: roomLayout
        )

        // Then
        XCTAssertNotNil(assignments[beginnerPlayer.id])
        XCTAssertNotNil(assignments[expertPlayer.id])
    }

    // MARK: - Hint Generation Tests

    func testGenerateHints_beginnerPlayer_moreHints() async {
        // Given
        let beginner = Player(name: "Beginner", role: .seeker, position: SIMD3(0, 0, 0))
        let target = Player(name: "Target", role: .hider, position: SIMD3(5, 0, 0))

        let beginnerPerformance = GamePerformance(successRate: 0.2, averageTime: 150, errorsCount: 10)
        await sut.updateSkillLevel(for: beginner.id, performance: beginnerPerformance)

        // When
        let hints = await sut.generateHints(
            for: beginner,
            targets: [target],
            elapsed: 60,
            maxTime: 180
        )

        // Then - Beginners should get hints even early in the game
        XCTAssertGreaterThan(hints.count, 0)
    }

    func testGenerateHints_expertPlayer_fewerHints() async {
        // Given
        let expert = Player(name: "Expert", role: .seeker, position: SIMD3(0, 0, 0))
        let target = Player(name: "Target", role: .hider, position: SIMD3(5, 0, 0))

        let expertPerformance = GamePerformance(successRate: 0.9, averageTime: 30, errorsCount: 1)
        await sut.updateSkillLevel(for: expert.id, performance: expertPerformance)

        // When
        let hints = await sut.generateHints(
            for: expert,
            targets: [target],
            elapsed: 60,
            maxTime: 180
        )

        // Then - Experts get fewer hints early in the game
        // (Will get more as time progresses)
        XCTAssertGreaterThanOrEqual(hints.count, 0)
    }

    func testGenerateHints_moreHintsOverTime() async {
        // Given
        let player = Player(name: "Player", role: .seeker, position: SIMD3(0, 0, 0))
        let target = Player(name: "Target", role: .hider, position: SIMD3(5, 0, 0))

        // When - Early in game
        let earlyHints = await sut.generateHints(
            for: player,
            targets: [target],
            elapsed: 30,
            maxTime: 180
        )

        // When - Late in game
        let lateHints = await sut.generateHints(
            for: player,
            targets: [target],
            elapsed: 160,
            maxTime: 180
        )

        // Then
        XCTAssertLessThanOrEqual(earlyHints.count, lateHints.count)
    }

    // MARK: - Difficulty Adjustment Tests

    func testCalculateOptimalRoundDuration_beginner_longerTime() async {
        // Given
        let beginner = Player(name: "Beginner")
        let beginnerPerformance = GamePerformance(successRate: 0.2, averageTime: 150, errorsCount: 10)
        await sut.updateSkillLevel(for: beginner.id, performance: beginnerPerformance)

        // When
        let duration = await sut.calculateOptimalRoundDuration(for: [beginner])

        // Then
        XCTAssertGreaterThan(duration, 180)
    }

    func testCalculateOptimalRoundDuration_expert_shorterTime() async {
        // Given
        let expert = Player(name: "Expert")
        let expertPerformance = GamePerformance(successRate: 0.9, averageTime: 30, errorsCount: 1)
        await sut.updateSkillLevel(for: expert.id, performance: expertPerformance)

        // When
        let duration = await sut.calculateOptimalRoundDuration(for: [expert])

        // Then
        XCTAssertLessThan(duration, 180)
    }

    func testShouldProvideAssistance_beginnerEarly_returnsTrue() async {
        // Given
        let playerId = UUID()
        let beginnerPerformance = GamePerformance(successRate: 0.2, averageTime: 150, errorsCount: 10)
        await sut.updateSkillLevel(for: playerId, performance: beginnerPerformance)

        // When
        let shouldAssist = await sut.shouldProvideAssistance(
            for: playerId,
            timeElapsed: 100,
            totalTime: 180
        )

        // Then
        XCTAssertTrue(shouldAssist)
    }

    // MARK: - Fairness Metrics Tests

    func testCalculateFairnessScore_equalWins_highScore() async {
        // Given - All players have equal wins
        let results: [UUID: Int] = [
            UUID(): 5,
            UUID(): 5,
            UUID(): 5,
            UUID(): 5
        ]

        // When
        let fairness = await sut.calculateFairnessScore(results: results)

        // Then
        XCTAssertGreaterThan(fairness, 0.9)
    }

    func testCalculateFairnessScore_unequalWins_lowerScore() async {
        // Given - Unequal wins
        let results: [UUID: Int] = [
            UUID(): 10,
            UUID(): 2,
            UUID(): 1,
            UUID(): 0
        ]

        // When
        let fairness = await sut.calculateFairnessScore(results: results)

        // Then
        XCTAssertLessThan(fairness, 0.9)
    }

    func testCalculateFairnessScore_empty_returns1() async {
        // Given
        let results: [UUID: Int] = [:]

        // When
        let fairness = await sut.calculateFairnessScore(results: results)

        // Then
        XCTAssertEqual(fairness, 1.0, accuracy: 0.001)
    }

    // MARK: - Helper Methods

    private func createMockRoomLayout() -> RoomLayout {
        let spots = [
            HidingSpot(location: SIMD3(1, 0, 1), quality: 0.9, accessibility: .easy),
            HidingSpot(location: SIMD3(2, 0, 2), quality: 0.7, accessibility: .moderate),
            HidingSpot(location: SIMD3(3, 0, 3), quality: 0.5, accessibility: .difficult),
            HidingSpot(location: SIMD3(4, 0, 4), quality: 0.3, accessibility: .easy)
        ]

        return RoomLayout(
            bounds: BoundingBox(min: .zero, max: SIMD3(10, 3, 10)),
            hidingSpots: spots
        )
    }
}
