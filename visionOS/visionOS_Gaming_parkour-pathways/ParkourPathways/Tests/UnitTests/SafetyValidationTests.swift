//
//  SafetyValidationTests.swift
//  Parkour Pathways Tests
//
//  Safety system validation tests
//

import XCTest
@testable import ParkourPathways

final class SafetyValidationTests: XCTestCase {

    // MARK: - Boundary Validation Tests

    func testSafetyBoundary_ValidObstacles() {
        let validator = SafetyValidator()
        let room = createTestRoom()

        let obstacles = [
            Obstacle(
                type: .precisionTarget,
                position: SIMD3<Float>(0.5, 0.5, 0.5), // Well within bounds
                scale: SIMD3<Float>(0.3, 0.05, 0.3)
            )
        ]

        XCTAssertNoThrow(try validator.validateBoundaries(obstacles, room: room))
    }

    func testSafetyBoundary_ObstacleOutOfBounds() {
        let validator = SafetyValidator()
        let room = createTestRoom()

        let obstacles = [
            Obstacle(
                type: .vaultBox,
                position: SIMD3<Float>(5.0, 0.5, 0), // Beyond room width
                scale: SIMD3<Float>(0.5, 0.6, 0.6)
            )
        ]

        XCTAssertThrowsError(try validator.validateBoundaries(obstacles, room: room)) { error in
            XCTAssertTrue(error is SafetyError)
        }
    }

    func testSafetyBoundary_ObstacleTooCloseToWall() {
        let validator = SafetyValidator()
        let room = createTestRoom(width: 3.0)

        let obstacles = [
            Obstacle(
                type: .vaultBox,
                position: SIMD3<Float>(1.4, 0.5, 0), // Only 0.1m from edge (needs 0.5m margin)
                scale: SIMD3<Float>(0.5, 0.6, 0.6)
            )
        ]

        XCTAssertThrowsError(try validator.validateBoundaries(obstacles, room: room))
    }

    func testSafetyBoundary_ObstacleTooHigh() {
        let validator = SafetyValidator()
        let room = createTestRoom(height: 2.5)

        let obstacles = [
            Obstacle(
                type: .wallTarget,
                position: SIMD3<Float>(0, 2.4, 0), // Too close to ceiling
                scale: SIMD3<Float>(0.2, 0.2, 0.1)
            )
        ]

        XCTAssertThrowsError(try validator.validateBoundaries(obstacles, room: room))
    }

    // MARK: - Obstacle Spacing Tests

    func testObstacleSpacing_AdequateDistance() {
        let validator = SafetyValidator()

        let obstacles = [
            Obstacle(
                type: .precisionTarget,
                position: SIMD3<Float>(0, 0.5, 0),
                scale: SIMD3<Float>(0.3, 0.05, 0.3)
            ),
            Obstacle(
                type: .precisionTarget,
                position: SIMD3<Float>(1.5, 0.5, 0), // 1.5m apart
                scale: SIMD3<Float>(0.3, 0.05, 0.3)
            )
        ]

        XCTAssertNoThrow(try validator.validateSpacing(obstacles))
    }

    func testObstacleSpacing_TooClose() {
        let validator = SafetyValidator()

        let obstacles = [
            Obstacle(
                type: .vaultBox,
                position: SIMD3<Float>(0, 0.5, 0),
                scale: SIMD3<Float>(0.5, 0.6, 0.6)
            ),
            Obstacle(
                type: .vaultBox,
                position: SIMD3<Float>(0.4, 0.5, 0), // Only 0.4m apart (too close)
                scale: SIMD3<Float>(0.5, 0.6, 0.6)
            )
        ]

        XCTAssertThrowsError(try validator.validateSpacing(obstacles)) { error in
            XCTAssertTrue(error is SafetyError)
        }
    }

    func testObstacleSpacing_VerticalClearance() {
        let validator = SafetyValidator()

        let obstacles = [
            Obstacle(
                type: .precisionTarget,
                position: SIMD3<Float>(0, 0.5, 0),
                scale: SIMD3<Float>(0.3, 0.05, 0.3)
            ),
            Obstacle(
                type: .wallTarget,
                position: SIMD3<Float>(0, 1.2, 0), // 0.7m vertical separation
                scale: SIMD3<Float>(0.2, 0.2, 0.1)
            )
        ]

        XCTAssertNoThrow(try validator.validateSpacing(obstacles))
    }

    // MARK: - Collision Detection Tests

    func testCollisionDetection_NoOverlap() {
        let validator = SafetyValidator()

        let obstacle1 = Obstacle(
            type: .vaultBox,
            position: SIMD3<Float>(0, 0.5, 0),
            scale: SIMD3<Float>(0.5, 0.6, 0.6)
        )

        let obstacle2 = Obstacle(
            type: .vaultBox,
            position: SIMD3<Float>(2.0, 0.5, 0),
            scale: SIMD3<Float>(0.5, 0.6, 0.6)
        )

        XCTAssertFalse(validator.checkCollision(obstacle1, obstacle2))
    }

    func testCollisionDetection_Overlapping() {
        let validator = SafetyValidator()

        let obstacle1 = Obstacle(
            type: .vaultBox,
            position: SIMD3<Float>(0, 0.5, 0),
            scale: SIMD3<Float>(0.5, 0.6, 0.6)
        )

        let obstacle2 = Obstacle(
            type: .vaultBox,
            position: SIMD3<Float>(0.3, 0.5, 0), // Overlapping
            scale: SIMD3<Float>(0.5, 0.6, 0.6)
        )

        XCTAssertTrue(validator.checkCollision(obstacle1, obstacle2))
    }

    // MARK: - Furniture Clearance Tests

    func testFurnitureClearance_SafeDistance() {
        let validator = SafetyValidator()
        let room = createRoomWithFurniture()

        let obstacles = [
            Obstacle(
                type: .precisionTarget,
                position: SIMD3<Float>(0, 0.5, 0), // Far from furniture
                scale: SIMD3<Float>(0.3, 0.05, 0.3)
            )
        ]

        XCTAssertNoThrow(try validator.validateFurnitureClearance(obstacles, room: room))
    }

    func testFurnitureClearance_TooCloseToFurniture() {
        let validator = SafetyValidator()
        let room = createRoomWithFurniture()

        // Room has furniture at (1.5, 0.5, 1.5)
        let obstacles = [
            Obstacle(
                type: .vaultBox,
                position: SIMD3<Float>(1.6, 0.5, 1.5), // Too close to furniture
                scale: SIMD3<Float>(0.5, 0.6, 0.6)
            )
        ]

        XCTAssertThrowsError(try validator.validateFurnitureClearance(obstacles, room: room))
    }

    // MARK: - Player Safety Zone Tests

    func testPlayerSafetyZone_AdequateClearance() {
        let validator = SafetyValidator()

        let playerPosition = SIMD3<Float>(0, 0, 0)
        let obstacles = [
            Obstacle(
                type: .precisionTarget,
                position: SIMD3<Float>(1.5, 0.5, 0), // 1.5m away
                scale: SIMD3<Float>(0.3, 0.05, 0.3)
            )
        ]

        XCTAssertTrue(validator.isPlayerSafe(at: playerPosition, obstacles: obstacles))
    }

    func testPlayerSafetyZone_InDangerZone() {
        let validator = SafetyValidator()

        let playerPosition = SIMD3<Float>(0, 0, 0)
        let obstacles = [
            Obstacle(
                type: .vaultBox,
                position: SIMD3<Float>(0.3, 0.5, 0), // Too close to player
                scale: SIMD3<Float>(0.5, 0.6, 0.6)
            )
        ]

        XCTAssertFalse(validator.isPlayerSafe(at: playerPosition, obstacles: obstacles))
    }

    // MARK: - Movement Path Validation Tests

    func testMovementPath_SafeTrajectory() {
        let validator = SafetyValidator()

        let path = MovementPath(
            points: [
                SIMD3<Float>(0, 0, 0),
                SIMD3<Float>(0.5, 0.5, 0),
                SIMD3<Float>(1.0, 0.5, 0)
            ]
        )

        let obstacles = [
            Obstacle(
                type: .precisionTarget,
                position: SIMD3<Float>(2.0, 0.5, 0), // Out of path
                scale: SIMD3<Float>(0.3, 0.05, 0.3)
            )
        ]

        XCTAssertTrue(validator.isPathSafe(path, obstacles: obstacles))
    }

    func testMovementPath_IntersectsObstacle() {
        let validator = SafetyValidator()

        let path = MovementPath(
            points: [
                SIMD3<Float>(0, 0, 0),
                SIMD3<Float>(1.0, 0.5, 0),
                SIMD3<Float>(2.0, 0.5, 0)
            ]
        )

        let obstacles = [
            Obstacle(
                type: .vaultBox,
                position: SIMD3<Float>(1.0, 0.5, 0), // On path
                scale: SIMD3<Float>(0.5, 0.6, 0.6)
            )
        ]

        XCTAssertFalse(validator.isPathSafe(path, obstacles: obstacles))
    }

    // MARK: - Dynamic Hazard Detection Tests

    func testDynamicHazard_SlipRisk() {
        let validator = SafetyValidator()

        let surface = Surface(
            type: .wood,
            friction: 0.3, // Low friction
            position: SIMD3<Float>(0, 0, 0),
            bounds: SIMD2<Float>(2.0, 2.0)
        )

        XCTAssertTrue(validator.hasSlipRisk(surface))
    }

    func testDynamicHazard_NoSlipRisk() {
        let validator = SafetyValidator()

        let surface = Surface(
            type: .carpet,
            friction: 0.8, // High friction
            position: SIMD3<Float>(0, 0, 0),
            bounds: SIMD2<Float>(2.0, 2.0)
        )

        XCTAssertFalse(validator.hasSlipRisk(surface))
    }

    func testDynamicHazard_HeightRisk() {
        let validator = SafetyValidator()

        let obstacle = Obstacle(
            type: .precisionTarget,
            position: SIMD3<Float>(0, 1.8, 0), // Very high
            scale: SIMD3<Float>(0.3, 0.05, 0.3)
        )

        let playerProfile = PhysicalProfile(
            height: 1.7,
            armReach: 0.7,
            jumpHeight: 0.5,
            skillLevel: .beginner
        )

        XCTAssertTrue(validator.hasHeightRisk(obstacle, for: playerProfile))
    }

    // MARK: - Emergency Stop Tests

    func testEmergencyStop_BoundaryViolation() {
        let validator = SafetyValidator()
        let room = createTestRoom(width: 3.0, length: 3.0)

        let playerPosition = SIMD3<Float>(1.45, 1.0, 0) // Close to boundary
        let playerVelocity = SIMD3<Float>(2.0, 0, 0) // Moving toward wall

        let shouldStop = validator.shouldTriggerEmergencyStop(
            playerPosition: playerPosition,
            playerVelocity: playerVelocity,
            room: room
        )

        XCTAssertTrue(shouldStop)
    }

    func testEmergencyStop_SafeMovement() {
        let validator = SafetyValidator()
        let room = createTestRoom(width: 3.0, length: 3.0)

        let playerPosition = SIMD3<Float>(0, 1.0, 0) // Center of room
        let playerVelocity = SIMD3<Float>(0.5, 0, 0) // Slow movement

        let shouldStop = validator.shouldTriggerEmergencyStop(
            playerPosition: playerPosition,
            playerVelocity: playerVelocity,
            room: room
        )

        XCTAssertFalse(shouldStop)
    }

    // MARK: - Safety Margin Tests

    func testSafetyMargin_Calculation() {
        let validator = SafetyValidator()

        let beginnerMargin = validator.calculateSafetyMargin(skillLevel: .beginner)
        let intermediateMargin = validator.calculateSafetyMargin(skillLevel: .intermediate)
        let advancedMargin = validator.calculateSafetyMargin(skillLevel: .advanced)

        XCTAssertGreaterThan(beginnerMargin, intermediateMargin)
        XCTAssertGreaterThan(intermediateMargin, advancedMargin)
        XCTAssertGreaterThanOrEqual(advancedMargin, 0.3) // Minimum margin
    }

    // MARK: - Helper Methods

    private func createTestRoom(
        width: Float = 3.0,
        length: Float = 3.0,
        height: Float = 2.5
    ) -> RoomModel {
        return RoomModel(
            width: width,
            length: length,
            height: height,
            surfaces: [],
            furniture: [],
            safePlayArea: nil
        )
    }

    private func createRoomWithFurniture() -> RoomModel {
        let furniture = Furniture(
            type: .table,
            position: SIMD3<Float>(1.5, 0.5, 1.5),
            bounds: SIMD3<Float>(1.0, 0.8, 0.6)
        )

        return RoomModel(
            width: 3.0,
            length: 3.0,
            height: 2.5,
            surfaces: [],
            furniture: [furniture],
            safePlayArea: nil
        )
    }
}

// MARK: - Supporting Types for Tests

struct MovementPath {
    let points: [SIMD3<Float>]
}

struct Surface {
    enum SurfaceType {
        case wood, carpet, tile, concrete
    }

    let type: SurfaceType
    let friction: Float
    let position: SIMD3<Float>
    let bounds: SIMD2<Float>
}

struct Furniture {
    enum FurnitureType {
        case table, chair, sofa, shelf
    }

    let type: FurnitureType
    let position: SIMD3<Float>
    let bounds: SIMD3<Float>
}

enum SafetyError: Error {
    case boundaryViolation
    case insufficientSpacing
    case collision
    case furnitureTooClose
}
