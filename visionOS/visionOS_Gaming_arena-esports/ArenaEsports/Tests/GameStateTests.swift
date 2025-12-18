import XCTest
@testable import ArenaEsports

@MainActor
final class GameStateTests: XCTestCase {
    var gameState: GameState!
    var stateMachine: GameStateMachine!

    override func setUp() {
        super.setUp()
        gameState = GameState()
        stateMachine = GameStateMachine(state: gameState)
    }

    override func tearDown() {
        gameState = nil
        stateMachine = nil
        super.tearDown()
    }

    // MARK: - Game State Tests

    func testInitialState() {
        if case .mainMenu = gameState.currentPhase {
            XCTAssertTrue(true)
        } else {
            XCTFail("Initial state should be mainMenu")
        }
    }

    func testIsInMatch() {
        gameState.currentPhase = .inMatch(matchID: UUID())
        XCTAssertTrue(gameState.isInMatch)

        gameState.currentPhase = .mainMenu
        XCTAssertFalse(gameState.isInMatch)
    }

    func testIsSpectating() {
        gameState.currentPhase = .spectating(matchID: UUID())
        XCTAssertTrue(gameState.isSpectating)

        gameState.currentPhase = .mainMenu
        XCTAssertFalse(gameState.isSpectating)
    }

    func testLocalPlayer() {
        let player = Player(username: "TestPlayer")
        gameState.localPlayer = player

        XCTAssertNotNil(gameState.localPlayer)
        XCTAssertEqual(gameState.localPlayer?.username, "TestPlayer")
    }

    func testCurrentMatch() {
        let arena = Arena(name: "Test Arena")
        let match = Match(teamAPlayers: [], teamBPlayers: [], arena: arena)
        gameState.currentMatch = match

        XCTAssertNotNil(gameState.currentMatch)
        XCTAssertEqual(gameState.currentMatch?.id, match.id)
    }

    // MARK: - State Machine Tests

    func testValidTransitionToTraining() async throws {
        try await stateMachine.transition(to: .training)

        let phase = await stateMachine.currentPhase
        if case .training = phase {
            XCTAssertTrue(true)
        } else {
            XCTFail("Should be in training phase")
        }
    }

    func testValidTransitionToMatchmaking() async throws {
        try await stateMachine.transition(to: .matchmaking)

        let phase = await stateMachine.currentPhase
        if case .matchmaking = phase {
            XCTAssertTrue(true)
        } else {
            XCTFail("Should be in matchmaking phase")
        }
    }

    func testValidTransitionFromMatchmakingToMatch() async throws {
        try await stateMachine.transition(to: .matchmaking)
        let matchID = UUID()
        try await stateMachine.transition(to: .inMatch(matchID: matchID))

        let phase = await stateMachine.currentPhase
        if case .inMatch(let id) = phase {
            XCTAssertEqual(id, matchID)
        } else {
            XCTFail("Should be in match phase")
        }
    }

    func testInvalidTransition() async {
        do {
            // Can't go directly from mainMenu to inMatch
            try await stateMachine.transition(to: .inMatch(matchID: UUID()))
            XCTFail("Should throw error for invalid transition")
        } catch GameStateError.invalidTransition {
            XCTAssertTrue(true)
        } catch {
            XCTFail("Wrong error type thrown")
        }
    }

    func testTransitionFromMatchToPostMatch() async throws {
        try await stateMachine.transition(to: .matchmaking)
        try await stateMachine.transition(to: .inMatch(matchID: UUID()))

        let results = MatchResults(
            matchID: UUID(),
            winner: .teamA,
            playerStats: [:],
            duration: 600
        )
        try await stateMachine.transition(to: .postMatch(results: results))

        let phase = await stateMachine.currentPhase
        if case .postMatch = phase {
            XCTAssertTrue(true)
        } else {
            XCTFail("Should be in postMatch phase")
        }
    }

    func testTransitionBackToMainMenu() async throws {
        try await stateMachine.transition(to: .training)
        try await stateMachine.transition(to: .mainMenu)

        let phase = await stateMachine.currentPhase
        if case .mainMenu = phase {
            XCTAssertTrue(true)
        } else {
            XCTFail("Should be in mainMenu phase")
        }
    }

    // MARK: - Match Results Tests

    func testMatchResults() {
        let matchID = UUID()
        let playerID = UUID()

        var stats = PlayerMatchStats()
        stats.kills = 12
        stats.deaths = 5
        stats.assists = 8

        let results = MatchResults(
            matchID: matchID,
            winner: .teamA,
            playerStats: [playerID: stats],
            duration: 600
        )

        XCTAssertEqual(results.matchID, matchID)
        XCTAssertEqual(results.winner, .teamA)
        XCTAssertEqual(results.duration, 600)
        XCTAssertEqual(results.playerStats[playerID]?.kills, 12)
    }

    func testPlayerMatchStatsKDA() {
        var stats = PlayerMatchStats()
        stats.kills = 10
        stats.deaths = 4
        stats.assists = 6

        let kda = stats.kda
        XCTAssertEqual(kda, 4.0, accuracy: 0.01) // (10 + 6) / 4 = 4.0
    }

    func testPlayerMatchStatsNoDeaths() {
        var stats = PlayerMatchStats()
        stats.kills = 15
        stats.assists = 5
        stats.deaths = 0

        let kda = stats.kda
        XCTAssertEqual(kda, 20.0) // (15 + 5)
    }

    func testMatchResultsCodable() throws {
        let results = MatchResults(
            matchID: UUID(),
            winner: .teamA,
            playerStats: [:],
            duration: 600
        )

        let encoded = try JSONEncoder().encode(results)
        let decoded = try JSONDecoder().decode(MatchResults.self, from: encoded)

        XCTAssertEqual(results.matchID, decoded.matchID)
        XCTAssertEqual(results.winner, decoded.winner)
        XCTAssertEqual(results.duration, decoded.duration)
    }
}
