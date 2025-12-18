import XCTest
@testable import TacticalTeamShooters

final class PlayerTests: XCTestCase {

    // MARK: - Initialization Tests

    func testPlayerInitialization() {
        let player = Player(username: "TestPlayer")

        XCTAssertEqual(player.username, "TestPlayer")
        XCTAssertEqual(player.rank, .recruit)
        XCTAssertEqual(player.health, 100.0)
        XCTAssertEqual(player.armor, 0.0)
        XCTAssertEqual(player.stats.kills, 0)
        XCTAssertEqual(player.stats.deaths, 0)
        XCTAssertTrue(player.isAlive)
    }

    func testPlayerInitializationWithCustomRank() {
        let player = Player(
            username: "VeteranPlayer",
            rank: .veteran,
            teamRole: .sniper
        )

        XCTAssertEqual(player.username, "VeteranPlayer")
        XCTAssertEqual(player.rank, .veteran)
        XCTAssertEqual(player.teamRole, .sniper)
    }

    // MARK: - Stats Tests

    func testPlayerStatsKDRWithDeaths() {
        var player = Player(username: "TestPlayer")
        player.stats.kills = 10
        player.stats.deaths = 5

        XCTAssertEqual(player.stats.kdr, 2.0, accuracy: 0.01)
    }

    func testPlayerStatsKDRWithNoDeaths() {
        var player = Player(username: "TestPlayer")
        player.stats.kills = 10
        player.stats.deaths = 0

        XCTAssertEqual(player.stats.kdr, 10.0, accuracy: 0.01)
    }

    func testPlayerStatsKDRWithNoKills() {
        var player = Player(username: "TestPlayer")
        player.stats.kills = 0
        player.stats.deaths = 5

        XCTAssertEqual(player.stats.kdr, 0.0, accuracy: 0.01)
    }

    func testWinRate() {
        var player = Player(username: "TestPlayer")
        player.stats.matchesPlayed = 10
        player.stats.matchesWon = 7

        XCTAssertEqual(player.stats.winRate, 0.7, accuracy: 0.01)
    }

    func testWinRateWithNoMatches() {
        let player = Player(username: "TestPlayer")

        XCTAssertEqual(player.stats.winRate, 0.0)
    }

    // MARK: - Record Events Tests

    func testRecordKill() {
        var player = Player(username: "TestPlayer")

        player.stats.recordKill(headshot: false)

        XCTAssertEqual(player.stats.kills, 1)
        XCTAssertEqual(player.stats.headshotKills, 0)
        XCTAssertEqual(player.stats.headshotPercentage, 0.0)
    }

    func testRecordHeadshotKill() {
        var player = Player(username: "TestPlayer")

        player.stats.recordKill(headshot: true)

        XCTAssertEqual(player.stats.kills, 1)
        XCTAssertEqual(player.stats.headshotKills, 1)
        XCTAssertEqual(player.stats.headshotPercentage, 1.0, accuracy: 0.01)
    }

    func testRecordMultipleKills() {
        var player = Player(username: "TestPlayer")

        player.stats.recordKill(headshot: true)
        player.stats.recordKill(headshot: false)
        player.stats.recordKill(headshot: true)
        player.stats.recordKill(headshot: false)

        XCTAssertEqual(player.stats.kills, 4)
        XCTAssertEqual(player.stats.headshotKills, 2)
        XCTAssertEqual(player.stats.headshotPercentage, 0.5, accuracy: 0.01)
    }

    func testRecordDeath() {
        var player = Player(username: "TestPlayer")

        player.stats.recordDeath()

        XCTAssertEqual(player.stats.deaths, 1)
    }

    func testRecordAssist() {
        var player = Player(username: "TestPlayer")

        player.stats.recordAssist()

        XCTAssertEqual(player.stats.assists, 1)
    }

    func testRecordShot() {
        var player = Player(username: "TestPlayer")
        let initialAccuracy = player.stats.accuracy

        player.stats.recordShot(hit: true)

        XCTAssertGreaterThan(player.stats.accuracy, initialAccuracy)
    }

    // MARK: - Competitive Rank Tests

    func testCompetitiveRankDisplayName() {
        XCTAssertEqual(CompetitiveRank.recruit.displayName, "Recruit")
        XCTAssertEqual(CompetitiveRank.specialist.displayName, "Specialist")
        XCTAssertEqual(CompetitiveRank.veteran.displayName, "Veteran")
        XCTAssertEqual(CompetitiveRank.elite.displayName, "Elite")
        XCTAssertEqual(CompetitiveRank.master.displayName, "Master")
        XCTAssertEqual(CompetitiveRank.legend.displayName, "Legend")
    }

    func testCompetitiveRankFromELO() {
        XCTAssertEqual(CompetitiveRank.rank(for: 500), .recruit)
        XCTAssertEqual(CompetitiveRank.rank(for: 1250), .specialist)
        XCTAssertEqual(CompetitiveRank.rank(for: 1750), .veteran)
        XCTAssertEqual(CompetitiveRank.rank(for: 2250), .elite)
        XCTAssertEqual(CompetitiveRank.rank(for: 2750), .master)
        XCTAssertEqual(CompetitiveRank.rank(for: 3500), .legend)
    }

    // MARK: - Team Role Tests

    func testTeamRoleDisplayNames() {
        XCTAssertEqual(TeamRole.entryFragger.displayName, "Entry Fragger")
        XCTAssertEqual(TeamRole.support.displayName, "Support")
        XCTAssertEqual(TeamRole.sniper.displayName, "Sniper")
        XCTAssertEqual(TeamRole.igl.displayName, "IGL")
        XCTAssertEqual(TeamRole.lurker.displayName, "Lurker")
    }

    func testTeamRoleDescriptions() {
        XCTAssertFalse(TeamRole.entryFragger.description.isEmpty)
        XCTAssertFalse(TeamRole.support.description.isEmpty)
        XCTAssertFalse(TeamRole.sniper.description.isEmpty)
        XCTAssertFalse(TeamRole.igl.description.isEmpty)
        XCTAssertFalse(TeamRole.lurker.description.isEmpty)
    }

    // MARK: - Codable Tests

    func testPlayerCodable() throws {
        let player = Player(username: "TestPlayer", rank: .veteran)

        let encoder = JSONEncoder()
        let data = try encoder.encode(player)

        let decoder = JSONDecoder()
        let decodedPlayer = try decoder.decode(Player.self, from: data)

        XCTAssertEqual(decodedPlayer.username, player.username)
        XCTAssertEqual(decodedPlayer.rank, player.rank)
    }
}
