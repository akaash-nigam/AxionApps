//
//  GameplayIntegrationTests.swift
//  Parkour Pathways Tests
//
//  Integration tests for complete gameplay flows
//

import XCTest
@testable import ParkourPathways

final class GameplayIntegrationTests: XCTestCase {
    var gameStateManager: GameStateManager!
    var courseGenerator: AICourseGenerator!
    var spatialMappingSystem: SpatialMappingSystem!

    override func setUp() async throws {
        try await super.setUp()
        gameStateManager = GameStateManager()
        courseGenerator = AICourseGenerator(
            difficultyEngine: DifficultyEngine(),
            spatialOptimizer: SpatialOptimizer(),
            safetyValidator: SafetyValidator()
        )
        spatialMappingSystem = SpatialMappingSystem()
    }

    override func tearDown() {
        gameStateManager = nil
        courseGenerator = nil
        spatialMappingSystem = nil
        super.tearDown()
    }

    // MARK: - Complete Gameplay Flow Tests

    func testCompleteGameplayFlow() async throws {
        // 1. Initialize game
        XCTAssertEqual(gameStateManager.currentState, .initializing)

        // 2. Transition to room scanning
        try await gameStateManager.transition(to: .roomScanning)
        XCTAssertEqual(gameStateManager.currentState, .roomScanning)

        // 3. Simulate room scan completion
        // Note: Actual scanning requires ARKit hardware
        let mockRoom = createMockRoom()

        // 4. Transition to main menu
        try await gameStateManager.transition(to: .mainMenu)
        XCTAssertEqual(gameStateManager.currentState, .mainMenu)

        // 5. Generate course
        let mockPlayer = createMockPlayer()
        let course = try await courseGenerator.generateCourse(
            for: mockRoom,
            player: mockPlayer,
            difficulty: .medium
        )

        gameStateManager.courseData = course
        XCTAssertNotNil(gameStateManager.courseData)

        // 6. Start course
        try await gameStateManager.transition(to: .courseSetup)
        XCTAssertEqual(gameStateManager.currentState, .courseSetup)

        try await gameStateManager.transition(to: .courseActive)
        XCTAssertEqual(gameStateManager.currentState, .courseActive)
        XCTAssertNotNil(gameStateManager.sessionMetrics)

        // 7. Pause course
        try await gameStateManager.transition(to: .coursePaused)
        XCTAssertEqual(gameStateManager.currentState, .coursePaused)

        // 8. Resume course
        try await gameStateManager.transition(to: .courseActive)
        XCTAssertEqual(gameStateManager.currentState, .courseActive)

        // 9. Complete course
        try await gameStateManager.transition(to: .courseCompleted)
        XCTAssertEqual(gameStateManager.currentState, .courseCompleted)

        // 10. Check session metrics
        XCTAssertNotNil(gameStateManager.sessionMetrics)
        XCTAssertNotNil(gameStateManager.sessionMetrics?.completionTime)
    }

    func testRoomScanToCourseGeneration() async throws {
        // Scan room (simulated)
        let mockRoom = createMockRoom()

        // Verify room is valid
        XCTAssertGreaterThan(mockRoom.width, 0)
        XCTAssertGreaterThan(mockRoom.height, 0)

        // Generate course for scanned room
        let mockPlayer = createMockPlayer()
        let course = try await courseGenerator.generateCourse(
            for: mockRoom,
            player: mockPlayer,
            difficulty: .medium
        )

        // Verify course fits room
        XCTAssertTrue(course.spaceRequirements.fits(in: mockRoom))
        XCTAssertFalse(course.obstacles.isEmpty)
    }

    func testCourseCompletionWithScoring() async throws {
        // Setup
        let course = createMockCourse()
        gameStateManager.courseData = course
        gameStateManager.playerData = createMockPlayer()

        // Start course
        try await gameStateManager.transition(to: .courseActive)

        // Simulate obstacle completion with scores
        let mockMetrics = SessionMetrics(
            startTime: Date(),
            courseId: course.id,
            techniqueScores: [
                "obstacle_1": 0.9,
                "obstacle_2": 0.85,
                "obstacle_3": 0.95
            ]
        )
        gameStateManager.sessionMetrics = mockMetrics

        // Complete course
        try await gameStateManager.transition(to: .courseCompleted)

        // Verify final score calculated
        XCTAssertGreaterThan(gameStateManager.sessionMetrics?.score ?? 0, 0)
    }

    // MARK: - State Transition Tests

    func testInvalidStateTransition() async {
        // Try invalid transition
        do {
            try await gameStateManager.transition(to: .courseCompleted)
            XCTFail("Should throw error for invalid transition")
        } catch {
            XCTAssertTrue(error is GameStateError)
        }
    }

    func testStateHistoryTracking() async throws {
        try await gameStateManager.transition(to: .roomScanning)
        try await gameStateManager.transition(to: .mainMenu)
        try await gameStateManager.transition(to: .courseSetup)

        // State history should be tracked
        // (Implementation dependent on GameStateManager internals)
        XCTAssertEqual(gameStateManager.currentState, .courseSetup)
    }

    // MARK: - Helper Methods

    private func createMockRoom() -> RoomModel {
        return RoomModel(
            width: 3.5,
            length: 3.5,
            height: 2.5,
            surfaces: [
                RoomModel.Surface(
                    id: UUID(),
                    type: .floor,
                    vertices: [
                        SIMD3<Float>(-1.75, 0, -1.75),
                        SIMD3<Float>(1.75, 0, -1.75),
                        SIMD3<Float>(1.75, 0, 1.75),
                        SIMD3<Float>(-1.75, 0, 1.75)
                    ],
                    normal: SIMD3<Float>(0, 1, 0)
                )
            ],
            furniture: [],
            safePlayArea: PlayArea(
                bounds: PlayArea.Bounds(
                    min: SIMD3<Float>(-1.5, 0, -1.5),
                    max: SIMD3<Float>(1.5, 2.5, 1.5)
                ),
                safeZone: PlayArea.Bounds(
                    min: SIMD3<Float>(-1.2, 0, -1.2),
                    max: SIMD3<Float>(1.2, 2.5, 1.2)
                ),
                centerPoint: .zero
            )
        )
    }

    private func createMockPlayer() -> PlayerData {
        return PlayerData(
            username: "IntegrationTestPlayer",
            skillLevel: .intermediate,
            physicalProfile: PhysicalProfile(
                height: 1.7,
                reach: 0.7,
                jumpHeight: 0.6,
                fitnessLevel: .intermediate
            )
        )
    }

    private func createMockCourse() -> CourseData {
        return CourseData(
            name: "Test Course",
            difficulty: .medium,
            obstacles: [
                Obstacle(
                    type: .precisionTarget,
                    position: SIMD3<Float>(0, 0.5, 0),
                    scale: SIMD3<Float>(0.3, 0.05, 0.3)
                ),
                Obstacle(
                    type: .vaultBox,
                    position: SIMD3<Float>(0.5, 0.6, 0.5),
                    scale: SIMD3<Float>(1, 0.6, 0.6)
                )
            ],
            checkpoints: [
                Checkpoint(
                    position: SIMD3<Float>(0, 0, 0),
                    order: 1
                )
            ],
            spaceRequirements: SpaceRequirements(
                minWidth: 2.0,
                minLength: 2.0,
                minHeight: 2.5
            ),
            estimatedDuration: 180
        )
    }
}
