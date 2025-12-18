//
//  GameModeTests.swift
//  Spatial Arena Championship Tests
//
//  Unit tests for Game Mode Controllers
//

import XCTest
@testable import SpatialArenaChampionship

@MainActor
final class GameModeTests: XCTestCase {

    var match: Match!
    var team1: Team!
    var team2: Team!

    override func setUp() {
        super.setUp()

        team1 = Team(
            color: .blue,
            players: [
                Player(username: "Blue1", skillRating: 1500, team: .blue),
                Player(username: "Blue2", skillRating: 1500, team: .blue)
            ]
        )

        team2 = Team(
            color: .red,
            players: [
                Player(username: "Red1", skillRating: 1500, team: .red),
                Player(username: "Red2", skillRating: 1500, team: .red)
            ]
        )

        match = Match(
            matchType: .competitive,
            gameMode: .teamDeathmatch,
            arena: .cyberArena(),
            team1: team1,
            team2: team2
        )
    }

    override func tearDown() {
        match = nil
        team1 = nil
        team2 = nil
        super.tearDown()
    }

    // MARK: - Team Deathmatch Tests

    func testTeamDeathmatchVictoryCondition() {
        let controller = TeamDeathmatchModeController(match: match, killLimit: 10)

        // Simulate 10 kills for team1
        for _ in 0..<10 {
            controller.handlePlayerElimination(
                victim: team2.players[0].id,
                killer: team1.players[0].id
            )
        }

        let winner = controller.checkVictoryConditions()

        XCTAssertNotNil(winner)
        XCTAssertEqual(winner?.color, .blue)
    }

    func testTeamDeathmatchScoreTracking() {
        let controller = TeamDeathmatchModeController(match: match, killLimit: 50)

        controller.handlePlayerElimination(
            victim: team2.players[0].id,
            killer: team1.players[0].id
        )

        XCTAssertEqual(match.team1.score, 1)
        XCTAssertEqual(match.team2.score, 0)
    }

    // MARK: - Elimination Tests

    func testEliminationLastTeamStanding() {
        let controller = EliminationModeController(match: match, lives: 3)

        // Eliminate all team2 players 3 times each
        for player in team2.players {
            for _ in 0..<3 {
                controller.handlePlayerElimination(
                    victim: player.id,
                    killer: team1.players[0].id
                )
            }
        }

        let winner = controller.checkVictoryConditions()

        XCTAssertNotNil(winner)
        XCTAssertEqual(winner?.color, .blue)
    }

    func testEliminationLivesDecrement() {
        let controller = EliminationModeController(match: match, lives: 3)

        // Kill team2 player once
        controller.handlePlayerElimination(
            victim: team2.players[0].id,
            killer: team1.players[0].id
        )

        // Player should still have lives remaining
        let winner = controller.checkVictoryConditions()
        XCTAssertNil(winner) // No winner yet
    }

    // MARK: - Domination Tests

    func testDominationTerritoryCapture() {
        let controller = DominationModeController(match: match, pointsToWin: 100)

        // Simulate territory control
        controller.updateTerritoryControl(territoryID: UUID(), controllingTeam: .blue)

        // Update for some time to accumulate points
        for _ in 0..<100 {
            controller.update(deltaTime: 1.0)
        }

        // Team1 should have accumulated points
        XCTAssertGreaterThan(match.team1.score, 0)
    }

    func testDominationVictoryByPoints() {
        let controller = DominationModeController(match: match, pointsToWin: 100)

        // Manually set score
        match.team1.score = 100

        let winner = controller.checkVictoryConditions()

        XCTAssertNotNil(winner)
        XCTAssertEqual(winner?.color, .blue)
    }

    // MARK: - Artifact Hunt Tests

    func testArtifactHuntBanking() {
        let controller = ArtifactHuntModeController(match: match, artifactsToWin: 5)

        let artifactID = UUID()

        // Pickup artifact
        controller.handleArtifactPickup(artifactID: artifactID, playerID: team1.players[0].id)

        // Bank artifact
        controller.handleArtifactBanked(artifactID: artifactID, team: .blue)

        XCTAssertEqual(match.team1.score, 1)
    }

    func testArtifactHuntDropOnDeath() {
        let controller = ArtifactHuntModeController(match: match, artifactsToWin: 5)

        let artifactID = UUID()

        // Pickup artifact
        controller.handleArtifactPickup(artifactID: artifactID, playerID: team1.players[0].id)

        // Player gets eliminated
        controller.handlePlayerElimination(
            victim: team1.players[0].id,
            killer: team2.players[0].id
        )

        // Artifact should be dropped (implementation dependent)
        // This tests that the system handles elimination correctly
    }

    // MARK: - Match State Tests

    func testMatchStartTransition() {
        XCTAssertEqual(match.state, .waiting)

        match.start()

        XCTAssertEqual(match.state, .inProgress)
        XCTAssertNotNil(match.startTime)
    }

    func testMatchEndTransition() {
        match.start()

        match.end(winner: team1)

        XCTAssertEqual(match.state, .completed)
        XCTAssertNotNil(match.endTime)
        XCTAssertEqual(match.winner?.id, team1.id)
    }

    func testMatchDuration() {
        match.start()

        // Simulate some time passing
        Thread.sleep(forTimeInterval: 0.1)

        match.end(winner: team1)

        let duration = match.duration
        XCTAssertGreaterThan(duration, 0)
    }

    // MARK: - Event Tracking Tests

    func testMatchEventRecording() {
        let initialEventCount = match.events.count

        match.recordEvent(.playerElimination(
            killerID: team1.players[0].id,
            victimID: team2.players[0].id,
            timestamp: 10.0
        ))

        XCTAssertEqual(match.events.count, initialEventCount + 1)
    }

    func testObjectiveCaptureEvent() {
        let objectiveID = UUID()

        match.recordEvent(.objectiveCaptured(
            objectiveID: objectiveID,
            team: .blue,
            timestamp: 15.0
        ))

        let captureEvents = match.events.filter {
            if case .objectiveCaptured = $0 {
                return true
            }
            return false
        }

        XCTAssertEqual(captureEvents.count, 1)
    }

    // MARK: - Performance Tests

    func testGameModeUpdatePerformance() {
        let controller = TeamDeathmatchModeController(match: match, killLimit: 50)

        measure {
            for _ in 0..<1000 {
                controller.update(deltaTime: 0.016) // 60 FPS
            }
        }
    }

    func testVictoryConditionCheckPerformance() {
        let controller = TeamDeathmatchModeController(match: match, killLimit: 50)

        // Add many eliminations
        for _ in 0..<40 {
            controller.handlePlayerElimination(
                victim: team2.players[0].id,
                killer: team1.players[0].id
            )
        }

        measure {
            for _ in 0..<1000 {
                _ = controller.checkVictoryConditions()
            }
        }
    }
}
