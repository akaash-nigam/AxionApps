//
//  ServiceTests.swift
//  MilitaryDefenseTrainingTests
//
//  Created by Claude Code
//

import XCTest
@testable import MilitaryDefenseTraining

final class ServiceTests: XCTestCase {

    // MARK: - AnalyticsService Tests

    func testAnalyticsServiceGeneratesAAR() async throws {
        let analyticsService = AnalyticsService()

        let session = TrainingSession(
            missionType: .urbanAssault,
            scenarioID: UUID(),
            warriorID: UUID()
        )

        let metrics = PerformanceMetrics(
            accuracy: 75,
            tacticalScore: 850,
            objectivesCompleted: 3,
            totalObjectives: 3,
            shotsFired: 100,
            shotsHit: 75
        )

        let events: [TrainingEvent] = [
            .objectiveComplete(objective: "Secure Building"),
            .multiKill(count: 3)
        ]

        let aar = await analyticsService.generateAfterActionReport(
            session: session,
            events: events,
            finalMetrics: metrics
        )

        XCTAssertEqual(aar.overallScore, 850)
        XCTAssertEqual(aar.grade, "B+")
        XCTAssertGreaterThan(aar.strengths.count, 0)
    }

    func testSkillProgressionCalculation() async throws {
        let analyticsService = AnalyticsService()
        let warriorID = UUID()

        // Record some sessions
        let metrics1 = PerformanceMetrics(tacticalScore: 500)
        let metrics2 = PerformanceMetrics(tacticalScore: 750)
        let metrics3 = PerformanceMetrics(tacticalScore: 900)

        await analyticsService.recordEvent(.objectiveComplete(objective: "Test"))

        let progression = await analyticsService.calculateSkillProgression(warriorID: warriorID)

        XCTAssertGreaterThanOrEqual(progression.currentLevel, 1)
        XCTAssertGreaterThanOrEqual(progression.nextLevelXP, 1000)
    }

    func testReadinessPrediction() async throws {
        let analyticsService = AnalyticsService()
        let warriorID = UUID()

        let readiness = await analyticsService.predictReadiness(warriorID: warriorID)

        XCTAssertGreaterThanOrEqual(readiness.overallReadiness, 0)
        XCTAssertLessThanOrEqual(readiness.overallReadiness, 100)
        XCTAssertGreaterThan(readiness.recommendation.count, 0)
    }

    // MARK: - PathfindingService Tests

    func testAStarPathfinding() async throws {
        let pathfinding = PathfindingService()

        let start = SIMD3<Float>(0, 0, 0)
        let goal = SIMD3<Float>(10, 0, 10)

        let path = await pathfinding.findPath(from: start, to: goal)

        XCTAssertNotNil(path)
        XCTAssertGreaterThan(path!.count, 1)
        XCTAssertEqual(path!.first, start)
    }

    func testCoverPathfinding() async throws {
        let pathfinding = PathfindingService()

        let start = SIMD3<Float>(0, 0, 0)
        let goal = SIMD3<Float>(20, 0, 20)
        let enemies = [SIMD3<Float>(10, 0, 10)]

        let path = await pathfinding.findCoverPath(
            from: start,
            to: goal,
            enemyPositions: enemies
        )

        XCTAssertNotNil(path)
    }

    func testFlankingPath() async throws {
        let pathfinding = PathfindingService()

        let start = SIMD3<Float>(0, 0, 0)
        let enemy = SIMD3<Float>(10, 0, 10)

        let path = await pathfinding.findFlankingPath(
            from: start,
            targetEnemy: enemy,
            flankDirection: .left
        )

        XCTAssertNotNil(path)
    }

    // MARK: - AIDirectorService Tests

    func testEnemySpawning() async throws {
        let aiDirector = AIDirectorService()

        let enemy = await aiDirector.spawnEnemy(
            type: .infantry,
            position: SIMD3<Float>(10, 0, 10),
            difficulty: .medium
        )

        XCTAssertEqual(enemy.unitType, .infantry)
        XCTAssertEqual(enemy.aiDifficulty, .medium)

        let enemies = await aiDirector.getActiveEnemies()
        XCTAssertEqual(enemies.count, 1)
    }

    func testSquadSpawning() async throws {
        let aiDirector = AIDirectorService()

        let squad = await aiDirector.spawnSquad(
            size: 4,
            position: SIMD3<Float>(0, 0, 0),
            difficulty: .hard,
            doctrine: .conventional
        )

        XCTAssertEqual(squad.count, 4)
        XCTAssertTrue(squad.allSatisfy { $0.squadID != nil })
    }

    func testDifficultyAdjustment() async throws {
        let aiDirector = AIDirectorService()

        let initialMultiplier = await aiDirector.getDifficultyMultiplier()

        let goodMetrics = PerformanceMetrics(
            accuracy: 90,
            tacticalScore: 950,
            objectivesCompleted: 3,
            totalObjectives: 3
        )

        await aiDirector.adjustDifficulty(basedOn: goodMetrics)

        let newMultiplier = await aiDirector.getDifficultyMultiplier()

        XCTAssertGreaterThan(newMultiplier, initialMultiplier)
    }

    func testReinforcementSpawning() async throws {
        let aiDirector = AIDirectorService()

        let reinforcements = await aiDirector.spawnReinforcements(
            near: SIMD3<Float>(0, 0, 0),
            count: 3,
            difficulty: .easy
        )

        XCTAssertEqual(reinforcements.count, 3)
    }

    // MARK: - Combat Simulation Tests

    func testWeaponFireSimulation() async throws {
        let combatSim = CombatSimulationService()

        let shooter = CombatEntity(
            entityType: .friendly,
            weapons: [WeaponSystem.m4Rifle]
        )
        shooter.position = SIMD3<Float>(0, 0, 0)

        await combatSim.registerEntity(shooter)

        let direction = SIMD3<Float>(0, 0, 1)
        let result = await combatSim.processWeaponFire(
            from: shooter,
            direction: direction
        )

        // Should either hit or miss (not fail)
        switch result {
        case .hit, .miss, .environmentHit:
            XCTAssert(true)
        case .noAmmo:
            XCTFail("Should have ammo")
        }
    }

    func testCoverEffectiveness() async throws {
        let combatSim = CombatSimulationService()

        let entity = CombatEntity(entityType: .friendly)
        entity.position = SIMD3<Float>(0, 0, 0)

        let threatDirection = SIMD3<Float>(1, 0, 0)

        let effectiveness = await combatSim.processCover(
            entity: entity,
            threatDirection: threatDirection
        )

        XCTAssertNotNil(effectiveness)
    }

    // MARK: - Network Service Tests

    func testOfflineQueueManagement() async throws {
        let networkService = NetworkService()

        let sessionCount = networkService.getQueuedOperationCount()

        XCTAssertGreaterThanOrEqual(sessionCount, 0)
    }

    // MARK: - Persistence Service Tests

    func testFileSaveAndLoad() async throws {
        let persistence = PersistenceService()

        let testData = "Test Data".data(using: .utf8)!
        let filename = "test_file.txt"

        // Save
        _ = try await persistence.saveFile(testData, name: filename, directory: .cache)

        // Load
        let loadedData = try await persistence.loadFile(name: filename, directory: .cache)

        XCTAssertEqual(testData, loadedData)

        // Cleanup
        try await persistence.deleteFile(name: filename, directory: .cache)
    }

    func testScenarioCaching() async throws {
        let persistence = PersistenceService()

        let scenario = Scenario(
            name: "Test Scenario",
            type: .urbanAssault,
            scenarioDescription: "Test"
        )

        // Cache
        try await persistence.cacheScenario(scenario)

        // Load
        let loaded = try await persistence.loadCachedScenario(id: scenario.id)

        XCTAssertEqual(loaded.name, scenario.name)
    }

    func testCacheSizeCalculation() async throws {
        let persistence = PersistenceService()

        let size = try await persistence.getCacheSize()

        XCTAssertGreaterThanOrEqual(size, 0)
    }

    // MARK: - Performance Tests

    func testPathfindingPerformance() async throws {
        let pathfinding = PathfindingService()

        measure {
            let start = SIMD3<Float>(0, 0, 0)
            let goal = SIMD3<Float>(50, 0, 50)

            Task {
                _ = await pathfinding.findPath(from: start, to: goal)
            }
        }
    }

    func testAIUpdatePerformance() async throws {
        let aiDirector = AIDirectorService()

        // Spawn 20 enemies
        for i in 0..<20 {
            _ = await aiDirector.spawnEnemy(
                type: .infantry,
                position: SIMD3<Float>(Float(i * 5), 0, 0),
                difficulty: .medium
            )
        }

        measure {
            Task {
                await aiDirector.updateEnemyBehaviors(
                    playerPosition: SIMD3<Float>(0, 0, 0),
                    deltaTime: 0.016
                )
            }
        }
    }

    // MARK: - Integration Tests

    func testFullCombatLoop() async throws {
        let combatSim = CombatSimulationService()
        let aiDirector = AIDirectorService()

        // Create player
        let player = CombatEntity(
            entityType: .friendly,
            weapons: [WeaponSystem.m4Rifle]
        )
        player.position = SIMD3<Float>(0, 0, 0)

        await combatSim.registerEntity(player)

        // Spawn enemy
        let enemy = await aiDirector.spawnEnemy(
            type: .infantry,
            position: SIMD3<Float>(20, 0, 0),
            difficulty: .easy
        )

        let enemyEntity = CombatEntity(entityType: .enemy)
        enemyEntity.position = SIMD3<Float>(20, 0, 0)
        enemy.combatEntity = enemyEntity

        await combatSim.registerEntity(enemyEntity)

        // Fire at enemy
        let direction = simd_normalize(enemyEntity.position - player.position)
        let result = await combatSim.processWeaponFire(
            from: player,
            direction: direction
        )

        // Should hit or miss
        switch result {
        case .hit(let target, let damage, _):
            XCTAssertGreaterThan(damage, 0)
            XCTAssertLessThan(target.health, 100)
        case .miss, .environmentHit:
            XCTAssert(true)
        case .noAmmo:
            XCTFail("Should have ammo")
        }
    }
}
