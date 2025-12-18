//
//  CourseGeneratorTests.swift
//  Parkour Pathways Tests
//
//  Unit tests for AI course generation
//

import XCTest
@testable import ParkourPathways

final class AICourseGeneratorTests: XCTestCase {
    var generator: AICourseGenerator!
    var mockRoomModel: RoomModel!
    var mockPlayer: PlayerData!

    override func setUp() {
        super.setUp()
        generator = AICourseGenerator(
            difficultyEngine: DifficultyEngine(),
            spatialOptimizer: SpatialOptimizer(),
            safetyValidator: SafetyValidator()
        )
        mockRoomModel = createMockRoom()
        mockPlayer = createMockPlayer()
    }

    override func tearDown() {
        generator = nil
        mockRoomModel = nil
        mockPlayer = nil
        super.tearDown()
    }

    // MARK: - Helper Methods

    private func createMockRoom() -> RoomModel {
        return RoomModel(
            width: 4.0,
            length: 4.0,
            height: 2.5,
            surfaces: [],
            furniture: [],
            safePlayArea: PlayArea(
                bounds: PlayArea.Bounds(
                    min: SIMD3<Float>(-2, 0, -2),
                    max: SIMD3<Float>(2, 2.5, 2)
                ),
                safeZone: PlayArea.Bounds(
                    min: SIMD3<Float>(-1.5, 0, -1.5),
                    max: SIMD3<Float>(1.5, 2.5, 1.5)
                ),
                centerPoint: .zero
            )
        )
    }

    private func createMockPlayer() -> PlayerData {
        return PlayerData(
            username: "TestPlayer",
            skillLevel: .intermediate,
            physicalProfile: PhysicalProfile(
                height: 1.7,
                reach: 0.7,
                jumpHeight: 0.6,
                fitnessLevel: .intermediate
            )
        )
    }

    // MARK: - Course Generation Tests

    func testGenerateCourse_ValidInput_ReturnsValidCourse() async throws {
        let course = try await generator.generateCourse(
            for: mockRoomModel,
            player: mockPlayer,
            difficulty: .medium
        )

        XCTAssertFalse(course.obstacles.isEmpty, "Course should contain obstacles")
        XCTAssertEqual(course.difficulty, .medium, "Course difficulty should match request")
        XCTAssertGreaterThan(course.estimatedDuration, 0, "Course should have estimated duration")
    }

    func testGenerateCourse_BeginnerDifficulty_CreatesEasierCourse() async throws {
        let beginnerCourse = try await generator.generateCourse(
            for: mockRoomModel,
            player: mockPlayer,
            difficulty: .easy
        )

        let hardCourse = try await generator.generateCourse(
            for: mockRoomModel,
            player: mockPlayer,
            difficulty: .hard
        )

        XCTAssertLessThan(
            beginnerCourse.obstacles.count,
            hardCourse.obstacles.count,
            "Easier courses should have fewer obstacles"
        )
    }

    func testGenerateCourse_CheckpointsGenerated() async throws {
        let course = try await generator.generateCourse(
            for: mockRoomModel,
            player: mockPlayer,
            difficulty: .medium
        )

        XCTAssertFalse(course.checkpoints.isEmpty, "Course should have checkpoints")
        XCTAssertTrue(
            course.checkpoints.allSatisfy { !$0.requiredObstacles.isEmpty },
            "Checkpoints should have required obstacles"
        )
    }

    func testGenerateCourse_SpaceRequirementsFitRoom() async throws {
        let course = try await generator.generateCourse(
            for: mockRoomModel,
            player: mockPlayer,
            difficulty: .medium
        )

        XCTAssertTrue(
            course.spaceRequirements.fits(in: mockRoomModel),
            "Generated course should fit in provided room"
        )
    }

    func testGenerateCourse_ObstacleSpacing() async throws {
        let course = try await generator.generateCourse(
            for: mockRoomModel,
            player: mockPlayer,
            difficulty: .medium
        )

        // Check minimum spacing between obstacles
        let minSpacing: Float = 1.0
        for i in 0..<course.obstacles.count {
            for j in (i+1)..<course.obstacles.count {
                let distance = simd_distance(
                    course.obstacles[i].position,
                    course.obstacles[j].position
                )
                XCTAssertGreaterThanOrEqual(
                    distance,
                    minSpacing,
                    "Obstacles should maintain minimum spacing"
                )
            }
        }
    }

    func testGenerateCourse_SafetyValidation() async throws {
        let course = try await generator.generateCourse(
            for: mockRoomModel,
            player: mockPlayer,
            difficulty: .medium
        )

        // All obstacles should be within room bounds
        for obstacle in course.obstacles {
            XCTAssertGreaterThan(obstacle.position.x, -mockRoomModel.width / 2)
            XCTAssertLessThan(obstacle.position.x, mockRoomModel.width / 2)
            XCTAssertGreaterThan(obstacle.position.z, -mockRoomModel.length / 2)
            XCTAssertLessThan(obstacle.position.z, mockRoomModel.length / 2)
        }
    }

    func testGenerateCourse_ObstacleVariety() async throws {
        let course = try await generator.generateCourse(
            for: mockRoomModel,
            player: mockPlayer,
            difficulty: .medium
        )

        // Should have multiple obstacle types
        let uniqueTypes = Set(course.obstacles.map { $0.type })
        XCTAssertGreaterThan(uniqueTypes.count, 1, "Course should have variety of obstacle types")
    }

    func testGenerateCourse_EstimatedDurationReasonable() async throws {
        let course = try await generator.generateCourse(
            for: mockRoomModel,
            player: mockPlayer,
            difficulty: .medium
        )

        // Estimated duration should be reasonable (30 seconds to 10 minutes)
        XCTAssertGreaterThan(course.estimatedDuration, 30)
        XCTAssertLessThan(course.estimatedDuration, 600)
    }
}

// MARK: - Difficulty Engine Tests

final class DifficultyEngineTests: XCTestCase {
    var engine: DifficultyEngine!

    override func setUp() {
        super.setUp()
        engine = DifficultyEngine()
    }

    override func tearDown() {
        engine = nil
        super.tearDown()
    }

    func testCalculateDifficulty_AllFactorsZero_ReturnsZero() {
        let factors = DifficultyFactors(
            obstacleComplexity: 0,
            spacing: 0,
            precisionRequired: 0,
            speedRequirement: 0,
            endurance: 0,
            technicalVariety: 0
        )

        let difficulty = engine.calculateDifficulty(factors)

        XCTAssertEqual(difficulty, 0, accuracy: 0.01)
    }

    func testCalculateDifficulty_AllFactorsMax_ReturnsOne() {
        let factors = DifficultyFactors(
            obstacleComplexity: 1,
            spacing: 1,
            precisionRequired: 1,
            speedRequirement: 1,
            endurance: 1,
            technicalVariety: 1
        )

        let difficulty = engine.calculateDifficulty(factors)

        XCTAssertEqual(difficulty, 1, accuracy: 0.01)
    }

    func testCalculateDifficulty_MixedFactors() {
        let factors = DifficultyFactors(
            obstacleComplexity: 0.5,
            spacing: 0.7,
            precisionRequired: 0.6,
            speedRequirement: 0.4,
            endurance: 0.5,
            technicalVariety: 0.8
        )

        let difficulty = engine.calculateDifficulty(factors)

        XCTAssertGreaterThan(difficulty, 0)
        XCTAssertLessThan(difficulty, 1)
    }
}

// MARK: - Safety Validator Tests

final class SafetyValidatorTests: XCTestCase {
    var validator: SafetyValidator!
    var mockRoom: RoomModel!

    override func setUp() {
        super.setUp()
        validator = SafetyValidator()
        mockRoom = RoomModel(
            width: 3.0,
            length: 3.0,
            height: 2.5,
            surfaces: [],
            furniture: [],
            safePlayArea: nil
        )
    }

    override func tearDown() {
        validator = nil
        mockRoom = nil
        super.tearDown()
    }

    func testValidate_ObstacleWithinBounds_Passes() throws {
        var graph = ObstacleGraph()
        graph.add(Obstacle(
            type: .precisionTarget,
            position: SIMD3<Float>(0, 0.5, 0),
            scale: SIMD3<Float>(0.3, 0.05, 0.3)
        ))

        XCTAssertNoThrow(try validator.validate(course: graph, space: mockRoom))
    }

    func testValidate_ObstacleOutOfBounds_Throws() {
        var graph = ObstacleGraph()
        graph.add(Obstacle(
            type: .precisionTarget,
            position: SIMD3<Float>(10, 0.5, 0),
            scale: SIMD3<Float>(0.3, 0.05, 0.3)
        ))

        XCTAssertThrowsError(try validator.validate(course: graph, space: mockRoom)) { error in
            XCTAssertEqual(error as? CourseGenerationError, .obstacleOutOfBounds)
        }
    }

    func testValidate_MultipleObstacles_AllWithinBounds() throws {
        var graph = ObstacleGraph()

        for i in 0..<5 {
            let x = Float(i) * 0.5 - 1.0
            graph.add(Obstacle(
                type: .vaultBox,
                position: SIMD3<Float>(x, 0.5, 0),
                scale: SIMD3<Float>(0.5, 0.6, 0.6)
            ))
        }

        XCTAssertNoThrow(try validator.validate(course: graph, space: mockRoom))
    }
}

// MARK: - Spatial Optimizer Tests

final class SpatialOptimizerTests: XCTestCase {
    var optimizer: SpatialOptimizer!
    var mockProfile: PhysicalProfile!

    override func setUp() {
        super.setUp()
        optimizer = SpatialOptimizer()
        mockProfile = PhysicalProfile(
            height: 1.7,
            reach: 0.7,
            jumpHeight: 0.6,
            fitnessLevel: .intermediate
        )
    }

    override func tearDown() {
        optimizer = nil
        mockProfile = nil
        super.tearDown()
    }

    func testOptimize_MaintainsObstacleCount() {
        var graph = ObstacleGraph()
        let initialCount = 10

        for i in 0..<initialCount {
            graph.add(Obstacle(
                type: .precisionTarget,
                position: SIMD3<Float>(Float(i) * 0.5, 0.5, 0),
                scale: SIMD3<Float>(0.3, 0.05, 0.3)
            ))
        }

        let optimized = optimizer.optimize(graph: graph, playerProfile: mockProfile)

        XCTAssertEqual(
            optimized.obstacles.count,
            initialCount,
            "Optimizer should not change obstacle count"
        )
    }

    func testOptimize_ReturnsValidGraph() {
        var graph = ObstacleGraph()
        graph.add(Obstacle(
            type: .vaultBox,
            position: SIMD3<Float>(0, 0.5, 0),
            scale: SIMD3<Float>(1, 0.6, 0.6)
        ))

        let optimized = optimizer.optimize(graph: graph, playerProfile: mockProfile)

        XCTAssertFalse(optimized.obstacles.isEmpty, "Optimized graph should have obstacles")
    }
}
