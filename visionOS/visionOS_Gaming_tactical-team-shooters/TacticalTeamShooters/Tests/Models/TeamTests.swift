import XCTest
@testable import TacticalTeamShooters

final class TeamTests: XCTestCase {

    // MARK: - Team Initialization Tests

    func testTeamInitialization() {
        let team = Team(name: "Alpha Squad", side: .attackers)

        XCTAssertEqual(team.name, "Alpha Squad")
        XCTAssertEqual(team.side, .attackers)
        XCTAssertEqual(team.score, 0)
        XCTAssertTrue(team.players.isEmpty)
        XCTAssertFalse(team.isFullTeam)
    }

    // MARK: - Player Management Tests

    func testAddPlayer() {
        var team = Team(name: "Alpha Squad", side: .attackers)
        let player = Player(username: "TestPlayer")

        team.addPlayer(player)

        XCTAssertEqual(team.players.count, 1)
        XCTAssertEqual(team.players[0].username, "TestPlayer")
    }

    func testAddMultiplePlayers() {
        var team = Team(name: "Alpha Squad", side: .attackers)

        for i in 1...3 {
            team.addPlayer(Player(username: "Player\(i)"))
        }

        XCTAssertEqual(team.players.count, 3)
        XCTAssertFalse(team.isFullTeam)
    }

    func testTeamFullAt5Players() {
        var team = Team(name: "Alpha Squad", side: .attackers)

        for i in 1...5 {
            team.addPlayer(Player(username: "Player\(i)"))
        }

        XCTAssertTrue(team.isFullTeam)
        XCTAssertEqual(team.players.count, 5)
    }

    func testCannotAddSixthPlayer() {
        var team = Team(name: "Alpha Squad", side: .attackers)

        for i in 1...5 {
            team.addPlayer(Player(username: "Player\(i)"))
        }

        // Try to add 6th player
        team.addPlayer(Player(username: "Player6"))

        XCTAssertEqual(team.players.count, 5)
    }

    func testRemovePlayer() {
        var team = Team(name: "Alpha Squad", side: .attackers)
        let player = Player(username: "TestPlayer")

        team.addPlayer(player)
        XCTAssertEqual(team.players.count, 1)

        team.removePlayer(player.id)
        XCTAssertTrue(team.players.isEmpty)
    }

    func testRemoveNonExistentPlayer() {
        var team = Team(name: "Alpha Squad", side: .attackers)
        team.addPlayer(Player(username: "Player1"))

        let randomUUID = UUID()
        team.removePlayer(randomUUID)

        XCTAssertEqual(team.players.count, 1)
    }

    // MARK: - Team Side Tests

    func testTeamSideDisplayNames() {
        XCTAssertEqual(TeamSide.attackers.displayName, "Attackers")
        XCTAssertEqual(TeamSide.defenders.displayName, "Defenders")
    }

    func testTeamSideColors() {
        XCTAssertEqual(TeamSide.attackers.color, "orange")
        XCTAssertEqual(TeamSide.defenders.color, "blue")
    }

    func testTeamSideOpposite() {
        XCTAssertEqual(TeamSide.attackers.opposite, .defenders)
        XCTAssertEqual(TeamSide.defenders.opposite, .attackers)
    }

    // MARK: - Average Rank Tests

    func testAverageRankWithNoPlayers() {
        let team = Team(name: "Alpha Squad", side: .attackers)

        XCTAssertEqual(team.averageRank, .recruit)
    }

    func testAverageRankWithOnlyRecruits() {
        var team = Team(name: "Alpha Squad", side: .attackers)

        for i in 1...5 {
            var player = Player(username: "Player\(i)")
            player.rank = .recruit
            team.addPlayer(player)
        }

        XCTAssertEqual(team.averageRank, .recruit)
    }

    // MARK: - Match Tests

    func testMatchInitialization() {
        let team1 = Team(name: "Alpha", side: .attackers)
        let team2 = Team(name: "Bravo", side: .defenders)

        let match = Match(
            matchType: .competitive,
            map: .warehouse,
            teams: [team1, team2]
        )

        XCTAssertEqual(match.matchType, .competitive)
        XCTAssertEqual(match.map.name, "warehouse")
        XCTAssertEqual(match.teams.count, 2)
        XCTAssertNil(match.winner)
        XCTAssertFalse(match.isComplete)
    }

    func testMatchDuration() {
        let team1 = Team(name: "Alpha", side: .attackers)
        let team2 = Team(name: "Bravo", side: .defenders)

        let match = Match(
            matchType: .competitive,
            map: .warehouse,
            teams: [team1, team2]
        )

        // Duration should be >= 0
        XCTAssertGreaterThanOrEqual(match.duration, 0)
    }

    // MARK: - Match Type Tests

    func testMatchTypeDisplayNames() {
        XCTAssertEqual(MatchType.casual.displayName, "Casual")
        XCTAssertEqual(MatchType.ranked.displayName, "Ranked")
        XCTAssertEqual(MatchType.competitive.displayName, "Competitive")
        XCTAssertEqual(MatchType.training.displayName, "Training")
    }

    func testMatchTypeRoundsToWin() {
        XCTAssertEqual(MatchType.casual.roundsToWin, 8)
        XCTAssertEqual(MatchType.ranked.roundsToWin, 13)
        XCTAssertEqual(MatchType.competitive.roundsToWin, 13)
        XCTAssertEqual(MatchType.training.roundsToWin, 1)
    }

    func testMatchTypeRoundTime() {
        XCTAssertEqual(MatchType.casual.roundTime, 90)
        XCTAssertEqual(MatchType.ranked.roundTime, 115)
        XCTAssertEqual(MatchType.competitive.roundTime, 115)
        XCTAssertEqual(MatchType.training.roundTime, 300)
    }

    // MARK: - Game Map Tests

    func testMapInitialization() {
        let map = GameMap.warehouse

        XCTAssertEqual(map.name, "warehouse")
        XCTAssertEqual(map.displayName, "Warehouse")
        XCTAssertFalse(map.description.isEmpty)
        XCTAssertEqual(map.imageAsset, "Map_Warehouse")
    }

    func testAllMapsAvailable() {
        let allMaps = GameMap.allMaps

        XCTAssertGreaterThanOrEqual(allMaps.count, 3)
        XCTAssertTrue(allMaps.contains(where: { $0.name == "warehouse" }))
        XCTAssertTrue(allMaps.contains(where: { $0.name == "urban" }))
        XCTAssertTrue(allMaps.contains(where: { $0.name == "military_base" }))
    }

    // MARK: - Round Tests

    func testRoundInitialization() {
        let round = Round(number: 1)

        XCTAssertEqual(round.number, 1)
        XCTAssertNil(round.winner)
        XCTAssertNil(round.endTime)
        XCTAssertTrue(round.kills.isEmpty)
        XCTAssertFalse(round.objectiveCompleted)
    }

    func testRoundRecordKill() {
        var round = Round(number: 1)

        let killEvent = KillEvent(
            killer: UUID(),
            victim: UUID(),
            weapon: UUID(),
            isHeadshot: true,
            distance: 25.0
        )

        round.recordKill(killEvent)

        XCTAssertEqual(round.kills.count, 1)
        XCTAssertTrue(round.kills[0].isHeadshot)
    }

    // MARK: - Win Condition Tests

    func testWinConditionDisplayNames() {
        XCTAssertEqual(WinCondition.elimination.displayName, "Elimination")
        XCTAssertEqual(WinCondition.objectiveComplete.displayName, "Objective Complete")
        XCTAssertEqual(WinCondition.timeExpired.displayName, "Time Expired")
        XCTAssertEqual(WinCondition.surrender.displayName, "Surrender")
    }

    // MARK: - Kill Event Tests

    func testKillEventInitialization() {
        let killerID = UUID()
        let victimID = UUID()
        let weaponID = UUID()

        let killEvent = KillEvent(
            killer: killerID,
            victim: victimID,
            weapon: weaponID,
            isHeadshot: true,
            distance: 50.0
        )

        XCTAssertEqual(killEvent.killer, killerID)
        XCTAssertEqual(killEvent.victim, victimID)
        XCTAssertEqual(killEvent.weapon, weaponID)
        XCTAssertTrue(killEvent.isHeadshot)
        XCTAssertEqual(killEvent.distance, 50.0, accuracy: 0.1)
    }

    // MARK: - Codable Tests

    func testTeamCodable() throws {
        let team = Team(name: "Alpha Squad", side: .attackers)

        let encoder = JSONEncoder()
        let data = try encoder.encode(team)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(Team.self, from: data)

        XCTAssertEqual(decoded.name, team.name)
        XCTAssertEqual(decoded.side, team.side)
    }
}
