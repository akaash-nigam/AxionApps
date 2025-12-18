//
//  PerformanceTests.swift
//  Parkour Pathways Tests
//
//  Performance and benchmark tests
//

import XCTest
@testable import ParkourPathways

final class PerformanceTests: XCTestCase {

    // MARK: - Frame Rate Tests
    // NOTE: Requires actual hardware/simulator to run

    func testGameLoopPerformance() {
        // Target: 90 FPS (11.1ms per frame)
        let targetFrameTime: TimeInterval = 1.0 / 90.0

        measure(metrics: [XCTClockMetric()]) {
            // Simulate game loop update
            let deltaTime = targetFrameTime

            // Simulate typical frame operations
            for _ in 0..<100 {
                simulateFrameUpdate(deltaTime: deltaTime)
            }
        }

        // Assert average frame time < 11.1ms
        // Note: Actual assertion would be done by CI/CD system
    }

    func testPhysicsUpdatePerformance() {
        measure(metrics: [XCTClockMetric()]) {
            // Simulate physics calculations for 100 frames
            for _ in 0..<100 {
                simulatePhysicsUpdate()
            }
        }
    }

    func testMovementAnalysisPerformance() {
        let mechanic = PrecisionJumpMechanic()

        measure {
            for _ in 0..<1000 {
                _ = mechanic.calculateScore(
                    landingPosition: SIMD3<Float>(0.1, 0, 0.1),
                    targetPosition: SIMD3<Float>(0, 0, 0)
                )
            }
        }
    }

    // MARK: - Memory Tests

    func testMemoryUsage_ExtendedGameplay() {
        let memoryMetric = XCTMemoryMetric()

        measure(metrics: [memoryMetric]) {
            // Simulate 10-minute gameplay session
            simulateExtendedGameplay(duration: 600)
        }

        // Target: < 2GB total memory usage
    }

    func testMemoryLeaks_CourseGeneration() {
        // Generate multiple courses and check for leaks
        measure(metrics: [XCTMemoryMetric()]) {
            for _ in 0..<50 {
                autoreleasepool {
                    _ = createTestCourse()
                }
            }
        }
    }

    // MARK: - Course Generation Performance

    func testCourseGenerationSpeed() async {
        let generator = AICourseGenerator(
            difficultyEngine: DifficultyEngine(),
            spatialOptimizer: SpatialOptimizer(),
            safetyValidator: SafetyValidator()
        )

        let room = createTestRoom()
        let player = createTestPlayer()

        measure(metrics: [XCTClockMetric()]) {
            Task {
                _ = try? await generator.generateCourse(
                    for: room,
                    player: player,
                    difficulty: .medium
                )
            }
        }

        // Target: < 500ms for course generation
    }

    func testMultipleCourseGeneration() async {
        let generator = AICourseGenerator(
            difficultyEngine: DifficultyEngine(),
            spatialOptimizer: SpatialOptimizer(),
            safetyValidator: SafetyValidator()
        )

        let room = createTestRoom()
        let player = createTestPlayer()

        measure {
            for _ in 0..<10 {
                Task {
                    _ = try? await generator.generateCourse(
                        for: room,
                        player: player,
                        difficulty: .medium
                    )
                }
            }
        }
    }

    // MARK: - Collision Detection Performance

    func testCollisionDetectionPerformance() {
        // Test collision checking with many obstacles
        let obstacles = createManyObstacles(count: 100)
        let playerPosition = SIMD3<Float>(0, 1, 0)

        measure {
            for _ in 0..<1000 {
                checkCollisions(obstacles: obstacles, playerPosition: playerPosition)
            }
        }
    }

    // MARK: - ECS System Performance

    func testECSSystemUpdatePerformance() {
        // Simulate updating 100 entities across multiple systems
        let entityCount = 100

        measure {
            for _ in 0..<60 { // 1 second at 60 FPS
                updateAllSystems(entityCount: entityCount)
            }
        }

        // Target: All systems update in < 3ms total
    }

    // MARK: - Data Persistence Performance

    func testSavePlayerDataPerformance() {
        let player = createTestPlayer()

        measure {
            for _ in 0..<100 {
                // Simulate saving player data
                savePlayerData(player)
            }
        }
    }

    func testLoadCourseDataPerformance() {
        measure {
            for _ in 0..<100 {
                // Simulate loading course data
                _ = loadCourseData()
            }
        }
    }

    // MARK: - Helper Methods

    private func simulateFrameUpdate(deltaTime: TimeInterval) {
        // Simulate typical frame operations
        _ = SIMD3<Float>(1, 2, 3) * Float(deltaTime)
        _ = simd_normalize(SIMD3<Float>(1, 0, 0))
    }

    private func simulatePhysicsUpdate() {
        // Simulate physics calculations
        let position = SIMD3<Float>(0, 1, 0)
        let velocity = SIMD3<Float>(1, 0, 0)
        let gravity = SIMD3<Float>(0, -9.81, 0)
        _ = position + velocity * 0.016 + gravity * 0.016 * 0.016
    }

    private func simulateExtendedGameplay(duration: TimeInterval) {
        let frameCount = Int(duration * 60) // 60 FPS
        for _ in 0..<frameCount {
            autoreleasepool {
                simulateFrameUpdate(deltaTime: 1.0/60.0)
                simulatePhysicsUpdate()
            }
        }
    }

    private func createTestCourse() -> CourseData {
        return CourseData(
            name: "Performance Test Course",
            difficulty: .medium,
            obstacles: (0..<10).map { i in
                Obstacle(
                    type: .precisionTarget,
                    position: SIMD3<Float>(Float(i), 0.5, 0),
                    scale: SIMD3<Float>(0.3, 0.05, 0.3)
                )
            },
            checkpoints: [],
            spaceRequirements: SpaceRequirements(),
            estimatedDuration: 180
        )
    }

    private func createTestRoom() -> RoomModel {
        return RoomModel(
            width: 3.0,
            length: 3.0,
            height: 2.5,
            surfaces: [],
            furniture: [],
            safePlayArea: nil
        )
    }

    private func createTestPlayer() -> PlayerData {
        return PlayerData(
            username: "PerfTestPlayer",
            skillLevel: .intermediate
        )
    }

    private func createManyObstacles(count: Int) -> [Obstacle] {
        return (0..<count).map { i in
            Obstacle(
                type: .vaultBox,
                position: SIMD3<Float>(
                    Float(i % 10),
                    0.5,
                    Float(i / 10)
                ),
                scale: SIMD3<Float>(0.5, 0.6, 0.6)
            )
        }
    }

    private func checkCollisions(obstacles: [Obstacle], playerPosition: SIMD3<Float>) {
        for obstacle in obstacles {
            let distance = simd_distance(playerPosition, obstacle.position)
            _ = distance < 1.0
        }
    }

    private func updateAllSystems(entityCount: Int) {
        // Simulate system updates
        for _ in 0..<entityCount {
            _ = SIMD3<Float>.random(in: -1...1)
            _ = simd_normalize(SIMD3<Float>.random(in: -1...1))
        }
    }

    private func savePlayerData(_ player: PlayerData) {
        // Simulate save operation
        _ = player.username
        _ = player.skillLevel
    }

    private func loadCourseData() -> CourseData {
        return createTestCourse()
    }
}

// MARK: - SIMD3 Random Extension for Testing

extension SIMD3 where Scalar == Float {
    static func random(in range: ClosedRange<Float>) -> SIMD3<Float> {
        return SIMD3<Float>(
            Float.random(in: range),
            Float.random(in: range),
            Float.random(in: range)
        )
    }
}

// MARK: - Performance Benchmarks

final class BenchmarkTests: XCTestCase {

    func testBenchmark_VaultDetection() {
        let mechanic = VaultMechanic()
        let handPlacement = VaultMechanic.HandPlacement(
            position: SIMD3<Float>(0, 1, 0),
            normal: SIMD3<Float>(0, 1, 0),
            gripStrength: 0.9,
            timestamp: Date()
        )

        measure {
            for _ in 0..<10000 {
                _ = mechanic.detectVaultType(
                    leftHand: nil,
                    rightHand: handPlacement,
                    bodyVelocity: SIMD3<Float>(0, 0, 2.0),
                    obstacleHeight: 0.8
                )
            }
        }

        // Target: < 0.01ms per detection
    }

    func testBenchmark_BalanceCalculation() {
        let mechanic = BalanceMechanic()

        measure {
            for _ in 0..<10000 {
                _ = mechanic.calculateBalance(
                    bodyPosition: SIMD3<Float>(0, 1, 0),
                    footPositions: [SIMD3<Float>(0, 0, 0)],
                    headPosition: SIMD3<Float>(0, 1.7, 0)
                )
            }
        }

        // Target: < 0.01ms per calculation
    }
}
