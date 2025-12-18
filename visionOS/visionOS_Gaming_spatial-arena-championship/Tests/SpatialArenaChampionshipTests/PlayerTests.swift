//
//  PlayerTests.swift
//  Spatial Arena Championship Tests
//
//  Unit tests for Player model
//

import XCTest
@testable import SpatialArenaChampionship

final class PlayerTests: XCTestCase {

    var player: Player!

    override func setUp() {
        super.setUp()
        player = Player(
            username: "TestPlayer",
            skillRating: 1500,
            team: .blue
        )
    }

    override func tearDown() {
        player = nil
        super.tearDown()
    }

    // MARK: - Initialization Tests

    func testPlayerInitialization() {
        XCTAssertEqual(player.username, "TestPlayer")
        XCTAssertEqual(player.skillRating, 1500)
        XCTAssertEqual(player.team, .blue)
        XCTAssertEqual(player.health, GameConstants.Combat.baseHealth)
        XCTAssertEqual(player.shields, GameConstants.Combat.baseShields)
        XCTAssertEqual(player.energy, GameConstants.Combat.maxEnergy)
    }

    func testPlayerHasUniqueID() {
        let player2 = Player(username: "Player2", skillRating: 1500, team: .red)
        XCTAssertNotEqual(player.id, player2.id)
    }

    // MARK: - Damage Tests

    func testTakeDamage() {
        let initialHealth = player.health
        let damage: Float = 25.0

        player.takeDamage(damage, from: UUID())

        XCTAssertEqual(player.health, initialHealth - damage)
    }

    func testTakeDamageWithShields() {
        let damage: Float = 25.0
        let initialShields = player.shields
        let initialHealth = player.health

        player.takeDamage(damage, from: UUID())

        // Damage should hit shields first
        XCTAssertEqual(player.shields, initialShields - damage)
        XCTAssertEqual(player.health, initialHealth) // Health unchanged
    }

    func testTakeDamageExceedingShields() {
        let damage: Float = 75.0 // More than base shields (50)
        let initialShields = player.shields

        player.takeDamage(damage, from: UUID())

        XCTAssertEqual(player.shields, 0)
        XCTAssertEqual(player.health, GameConstants.Combat.baseHealth - (damage - initialShields))
    }

    func testTakeDamageKillsPlayer() {
        let damage: Float = 200.0

        player.takeDamage(damage, from: UUID())

        XCTAssertEqual(player.health, 0)
        XCTAssertEqual(player.shields, 0)
        XCTAssertTrue(player.isDead)
    }

    func testPlayerDeathIncrementsStat() {
        let initialDeaths = player.stats.deaths

        player.takeDamage(200.0, from: UUID())

        XCTAssertEqual(player.stats.deaths, initialDeaths + 1)
    }

    // MARK: - Healing Tests

    func testHeal() {
        player.takeDamage(50.0, from: UUID())
        let healthAfterDamage = player.health

        player.heal(25.0)

        XCTAssertEqual(player.health, healthAfterDamage + 25.0)
    }

    func testHealCannotExceedMaxHealth() {
        player.heal(1000.0)

        XCTAssertEqual(player.health, GameConstants.Combat.baseHealth)
    }

    // MARK: - Respawn Tests

    func testRespawn() {
        // Kill player
        player.takeDamage(200.0, from: UUID())
        XCTAssertTrue(player.isDead)

        // Respawn
        let spawnPosition = SIMD3<Float>(0, 0, 0)
        player.respawn(at: spawnPosition)

        XCTAssertFalse(player.isDead)
        XCTAssertEqual(player.health, GameConstants.Combat.baseHealth)
        XCTAssertEqual(player.shields, GameConstants.Combat.baseShields)
        XCTAssertEqual(player.position, spawnPosition)
    }

    // MARK: - Energy Tests

    func testConsumeEnergy() {
        let cost: Float = 30.0
        let initialEnergy = player.energy

        let success = player.consumeEnergy(cost)

        XCTAssertTrue(success)
        XCTAssertEqual(player.energy, initialEnergy - cost)
    }

    func testConsumeEnergyInsufficientAmount() {
        player.energy = 20.0

        let success = player.consumeEnergy(30.0)

        XCTAssertFalse(success)
        XCTAssertEqual(player.energy, 20.0) // Unchanged
    }

    func testRegenerateEnergy() {
        player.energy = 50.0

        player.regenerateEnergy(deltaTime: 1.0)

        XCTAssertGreaterThan(player.energy, 50.0)
    }

    func testRegenerateEnergyDoesNotExceedMax() {
        player.energy = GameConstants.Combat.maxEnergy

        player.regenerateEnergy(deltaTime: 1.0)

        XCTAssertEqual(player.energy, GameConstants.Combat.maxEnergy)
    }

    // MARK: - Stats Tests

    func testRecordElimination() {
        let initialElims = player.stats.eliminations

        player.recordElimination()

        XCTAssertEqual(player.stats.eliminations, initialElims + 1)
    }

    func testRecordAssist() {
        let initialAssists = player.stats.assists

        player.recordAssist()

        XCTAssertEqual(player.stats.assists, initialAssists + 1)
    }

    func testKDRatioCalculation() {
        player.stats.eliminations = 10
        player.stats.deaths = 5

        XCTAssertEqual(player.stats.kdRatio, 2.0)
    }

    func testKDRatioWithZeroDeaths() {
        player.stats.eliminations = 10
        player.stats.deaths = 0

        XCTAssertEqual(player.stats.kdRatio, 10.0)
    }

    func testKDRatioWithZeroEliminations() {
        player.stats.eliminations = 0
        player.stats.deaths = 5

        XCTAssertEqual(player.stats.kdRatio, 0.0)
    }

    // MARK: - Codable Tests

    func testPlayerCodable() throws {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()

        let data = try encoder.encode(player)
        let decodedPlayer = try decoder.decode(Player.self, from: data)

        XCTAssertEqual(player.id, decodedPlayer.id)
        XCTAssertEqual(player.username, decodedPlayer.username)
        XCTAssertEqual(player.skillRating, decodedPlayer.skillRating)
        XCTAssertEqual(player.health, decodedPlayer.health)
    }

    // MARK: - Performance Tests

    func testDamageCalculationPerformance() {
        measure {
            for _ in 0..<1000 {
                player.takeDamage(10.0, from: UUID())
                player.respawn(at: .zero)
            }
        }
    }
}
