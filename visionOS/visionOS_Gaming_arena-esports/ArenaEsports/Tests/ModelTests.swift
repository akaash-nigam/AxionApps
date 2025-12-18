import XCTest
@testable import ArenaEsports

final class ModelTests: XCTestCase {

    // MARK: - Player Tests

    func testPlayerInitialization() {
        let player = Player(username: "TestPlayer")

        XCTAssertNotNil(player.id)
        XCTAssertEqual(player.username, "TestPlayer")
        XCTAssertEqual(player.skillRating, 1500)
        XCTAssertNil(player.team)
    }

    func testPlayerStatistics() {
        var stats = PlayerStatistics()
        stats.matchesPlayed = 10
        stats.wins = 6
        stats.losses = 4

        XCTAssertEqual(stats.winRate, 0.6, accuracy: 0.01)
    }

    func testPlayerKDA() {
        var stats = PlayerStatistics()
        stats.kills = 12
        stats.deaths = 5
        stats.assists = 8

        let kda = stats.kda
        XCTAssertEqual(kda, 4.0, accuracy: 0.01) // (12 + 8) / 5 = 4.0
    }

    func testPlayerKDANoDeaths() {
        var stats = PlayerStatistics()
        stats.kills = 10
        stats.assists = 5
        stats.deaths = 0

        let kda = stats.kda
        XCTAssertEqual(kda, 15.0) // (10 + 5) / 1 = 15.0 when deaths = 0
    }

    func testPlayerCodable() throws {
        let player = Player(username: "TestPlayer", skillRating: 2000)

        let encoded = try JSONEncoder().encode(player)
        let decoded = try JSONDecoder().decode(Player.self, from: encoded)

        XCTAssertEqual(player.id, decoded.id)
        XCTAssertEqual(player.username, decoded.username)
        XCTAssertEqual(player.skillRating, decoded.skillRating)
    }

    // MARK: - Match Tests

    func testMatchInitialization() {
        let arena = Arena(name: "Test Arena")
        let match = Match(
            teamAPlayers: [UUID(), UUID()],
            teamBPlayers: [UUID(), UUID()],
            arena: arena
        )

        XCTAssertNotNil(match.id)
        XCTAssertEqual(match.teamAPlayers.count, 2)
        XCTAssertEqual(match.teamBPlayers.count, 2)
        XCTAssertEqual(match.status, .waiting)
        XCTAssertEqual(match.currentRound, 0)
    }

    func testMatchDuration() {
        let arena = Arena(name: "Test Arena")
        var match = Match(
            teamAPlayers: [],
            teamBPlayers: [],
            arena: arena
        )

        match.startTime = Date()
        match.endTime = Date().addingTimeInterval(600) // 10 minutes

        let duration = match.duration
        XCTAssertEqual(duration, 600, accuracy: 1.0)
    }

    func testMatchWinner() {
        let arena = Arena(name: "Test Arena")
        var match = Match(
            teamAPlayers: [],
            teamBPlayers: [],
            arena: arena,
            status: .completed
        )

        match.score.teamA = 4
        match.score.teamB = 2

        XCTAssertEqual(match.winner, .teamA)
    }

    func testMatchDraw() {
        let arena = Arena(name: "Test Arena")
        var match = Match(
            teamAPlayers: [],
            teamBPlayers: [],
            arena: arena,
            status: .completed
        )

        match.score.teamA = 3
        match.score.teamB = 3

        XCTAssertEqual(match.winner, .draw)
    }

    func testMatchNoWinnerWhenInProgress() {
        let arena = Arena(name: "Test Arena")
        var match = Match(
            teamAPlayers: [],
            teamBPlayers: [],
            arena: arena,
            status: .inProgress
        )

        match.score.teamA = 2
        match.score.teamB = 1

        XCTAssertNil(match.winner)
    }

    func testMatchCodable() throws {
        let arena = Arena(name: "Test Arena")
        let match = Match(
            teamAPlayers: [UUID()],
            teamBPlayers: [UUID()],
            arena: arena
        )

        let encoded = try JSONEncoder().encode(match)
        let decoded = try JSONDecoder().decode(Match.self, from: encoded)

        XCTAssertEqual(match.id, decoded.id)
        XCTAssertEqual(match.mode, decoded.mode)
        XCTAssertEqual(match.status, decoded.status)
    }

    // MARK: - Arena Tests

    func testArenaInitialization() {
        let arena = Arena(name: "Nexus", type: .spherical360)

        XCTAssertNotNil(arena.id)
        XCTAssertEqual(arena.name, "Nexus")
        XCTAssertEqual(arena.type, .spherical360)
        XCTAssertEqual(arena.radius, 15.0)
    }

    func testArenaVolume() {
        let arena = Arena(name: "Test", radius: 10.0)

        let volume = arena.volume
        let expectedVolume = (4.0 / 3.0) * Float.pi * pow(10.0, 3)

        XCTAssertEqual(volume, expectedVolume, accuracy: 0.1)
    }

    func testArenaPlayAreaRequirements() {
        let arena = Arena(
            name: "Competitive",
            minPlayArea: SIMD2(2.0, 2.0),
            recommendedPlayArea: SIMD2(3.0, 3.0)
        )

        XCTAssertEqual(arena.minPlayArea.x, 2.0)
        XCTAssertEqual(arena.recommendedPlayArea.x, 3.0)
    }

    func testArenaCodable() throws {
        let arena = Arena(name: "Test Arena", type: .verticalDominance)

        let encoded = try JSONEncoder().encode(arena)
        let decoded = try JSONDecoder().decode(Arena.self, from: encoded)

        XCTAssertEqual(arena.id, decoded.id)
        XCTAssertEqual(arena.name, decoded.name)
        XCTAssertEqual(arena.type, decoded.type)
    }
}
