//
//  GameModeController.swift
//  Spatial Arena Championship
//
//  Game mode logic controllers
//

import Foundation
import RealityKit

// MARK: - Game Mode Controller Protocol

@MainActor
protocol GameModeController {
    var match: Match { get set }
    var isMatchComplete: Bool { get }

    func start()
    func update(deltaTime: TimeInterval)
    func handlePlayerElimination(victim: UUID, killer: UUID)
    func handleObjectiveCaptured(objectiveID: UUID, team: TeamColor)
    func checkVictoryConditions() -> Team?
}

// MARK: - Elimination Mode

@MainActor
class EliminationModeController: GameModeController {
    var match: Match
    var isMatchComplete: Bool {
        match.state == .completed
    }

    private let livesPerPlayer: Int

    init(match: Match, livesPerPlayer: Int = 1) {
        self.match = match
        self.livesPerPlayer = livesPerPlayer
    }

    func start() {
        match.state = .active
        match.startTime = Date()
    }

    func update(deltaTime: TimeInterval) {
        // Check time limit if applicable
        if let startTime = match.startTime,
           Date().timeIntervalSince(startTime) >= match.matchSettings.timeLimit {
            // Time expired - team with most players alive wins
            if let winner = checkVictoryConditions() {
                endMatch(winner: winner)
            }
        }
    }

    func handlePlayerElimination(victim: UUID, killer: UUID) {
        // Find victim player
        if let victimIndex = match.team1.players.firstIndex(where: { $0.id == victim }) {
            match.team1.players[victimIndex].recordDeath()
            match.team1.players[victimIndex].isAlive = false
        } else if let victimIndex = match.team2.players.firstIndex(where: { $0.id == victim }) {
            match.team2.players[victimIndex].recordDeath()
            match.team2.players[victimIndex].isAlive = false
        }

        // Find killer player
        if let killerIndex = match.team1.players.firstIndex(where: { $0.id == killer }) {
            match.team1.players[killerIndex].recordElimination()
        } else if let killerIndex = match.team2.players.firstIndex(where: { $0.id == killer }) {
            match.team2.players[killerIndex].recordElimination()
        }

        // Record event
        let event = MatchEvent.playerElimination(
            killerID: killer,
            victimID: victim,
            timestamp: Date().timeIntervalSince1970
        )
        match.addEvent(event)

        // Check victory
        if let winner = checkVictoryConditions() {
            endMatch(winner: winner)
        }
    }

    func handleObjectiveCaptured(objectiveID: UUID, team: TeamColor) {
        // Not used in Elimination mode
    }

    func checkVictoryConditions() -> Team? {
        let team1Alive = match.team1.players.filter { $0.isAlive }.count
        let team2Alive = match.team2.players.filter { $0.isAlive }.count

        if team1Alive == 0 && team2Alive > 0 {
            return match.team2
        } else if team2Alive == 0 && team1Alive > 0 {
            return match.team1
        }

        return nil
    }

    private func endMatch(winner: Team) {
        match.end(winner: winner)
    }
}

// MARK: - Domination Mode

@MainActor
class DominationModeController: GameModeController {
    var match: Match
    var isMatchComplete: Bool {
        match.state == .completed
    }

    private var pointsPerSecond: Int = 1

    init(match: Match) {
        self.match = match
    }

    func start() {
        match.state = .active
        match.startTime = Date()
    }

    func update(deltaTime: TimeInterval) {
        // Award points based on controlled zones
        let team1Zones = match.objectives.filter { $0.controllingTeam == .blue }.count
        let team2Zones = match.objectives.filter { $0.controllingTeam == .red }.count

        match.team1.score += team1Zones * pointsPerSecond * Int(deltaTime)
        match.team2.score += team2Zones * pointsPerSecond * Int(deltaTime)

        // Check victory conditions
        if let winner = checkVictoryConditions() {
            endMatch(winner: winner)
        }

        // Check time limit
        if let startTime = match.startTime,
           Date().timeIntervalSince(startTime) >= match.matchSettings.timeLimit {
            // Time expired - team with higher score wins
            if let winner = checkVictoryConditions() {
                endMatch(winner: winner)
            } else if match.team1.score > match.team2.score {
                endMatch(winner: match.team1)
            } else if match.team2.score > match.team1.score {
                endMatch(winner: match.team2)
            }
        }
    }

    func handlePlayerElimination(victim: UUID, killer: UUID) {
        // Find and update player stats
        if let victimIndex = match.team1.players.firstIndex(where: { $0.id == victim }) {
            match.team1.players[victimIndex].recordDeath()
        } else if let victimIndex = match.team2.players.firstIndex(where: { $0.id == victim }) {
            match.team2.players[victimIndex].recordDeath()
        }

        if let killerIndex = match.team1.players.firstIndex(where: { $0.id == killer }) {
            match.team1.players[killerIndex].recordElimination()
        } else if let killerIndex = match.team2.players.firstIndex(where: { $0.id == killer }) {
            match.team2.players[killerIndex].recordElimination()
        }

        // Record event
        let event = MatchEvent.playerElimination(
            killerID: killer,
            victimID: victim,
            timestamp: Date().timeIntervalSince1970
        )
        match.addEvent(event)
    }

    func handleObjectiveCaptured(objectiveID: UUID, team: TeamColor) {
        // Find objective and update
        if let index = match.objectives.firstIndex(where: { $0.id == objectiveID }) {
            match.objectives[index].complete(by: team)
        }

        // Record event
        let event = MatchEvent.objectiveCaptured(
            objectiveID: objectiveID,
            team: team,
            timestamp: Date().timeIntervalSince1970
        )
        match.addEvent(event)
    }

    func checkVictoryConditions() -> Team? {
        // Check score limit
        if match.team1.score >= match.matchSettings.scoreLimit {
            return match.team1
        } else if match.team2.score >= match.matchSettings.scoreLimit {
            return match.team2
        }

        return nil
    }

    private func endMatch(winner: Team) {
        match.end(winner: winner)
    }
}

// MARK: - Artifact Hunt Mode

@MainActor
class ArtifactHuntModeController: GameModeController {
    var match: Match
    var isMatchComplete: Bool {
        match.state == .completed
    }

    private let artifactsToWin: Int = 10
    private var activeArtifacts: Set<UUID> = []

    init(match: Match) {
        self.match = match
    }

    func start() {
        match.state = .active
        match.startTime = Date()

        // Spawn initial artifacts
        spawnArtifacts(count: 3)
    }

    func update(deltaTime: TimeInterval) {
        // Ensure minimum artifacts are spawned
        if activeArtifacts.count < 3 {
            spawnArtifacts(count: 3 - activeArtifacts.count)
        }

        // Check victory conditions
        if let winner = checkVictoryConditions() {
            endMatch(winner: winner)
        }

        // Check time limit
        if let startTime = match.startTime,
           Date().timeIntervalSince(startTime) >= match.matchSettings.timeLimit {
            // Time expired - team with most artifacts wins
            if match.team1.score > match.team2.score {
                endMatch(winner: match.team1)
            } else if match.team2.score > match.team1.score {
                endMatch(winner: match.team2)
            }
        }
    }

    func handlePlayerElimination(victim: UUID, killer: UUID) {
        // When carrying artifact, drop it
        // TODO: Implement artifact drop on death

        // Update stats
        if let victimIndex = match.team1.players.firstIndex(where: { $0.id == victim }) {
            match.team1.players[victimIndex].recordDeath()
        } else if let victimIndex = match.team2.players.firstIndex(where: { $0.id == victim }) {
            match.team2.players[victimIndex].recordDeath()
        }

        if let killerIndex = match.team1.players.firstIndex(where: { $0.id == killer }) {
            match.team1.players[killerIndex].recordElimination()
        } else if let killerIndex = match.team2.players.firstIndex(where: { $0.id == killer }) {
            match.team2.players[killerIndex].recordElimination()
        }

        // Record event
        let event = MatchEvent.playerElimination(
            killerID: killer,
            victimID: victim,
            timestamp: Date().timeIntervalSince1970
        )
        match.addEvent(event)
    }

    func handleObjectiveCaptured(objectiveID: UUID, team: TeamColor) {
        // Not used in this mode
    }

    func handleArtifactBanked(artifactID: UUID, team: TeamColor) {
        // Award point
        if team == match.team1.color {
            match.team1.score += 1
        } else if team == match.team2.color {
            match.team2.score += 1
        }

        // Remove artifact from active set
        activeArtifacts.remove(artifactID)

        // Spawn new artifact
        spawnArtifacts(count: 1)
    }

    func checkVictoryConditions() -> Team? {
        if match.team1.score >= artifactsToWin {
            return match.team1
        } else if match.team2.score >= artifactsToWin {
            return match.team2
        }

        return nil
    }

    private func spawnArtifacts(count: Int) {
        // TODO: Spawn artifacts at random spawn points
        // For now, just track that they should be spawned
        for _ in 0..<count {
            let artifactID = UUID()
            activeArtifacts.insert(artifactID)
        }
    }

    private func endMatch(winner: Team) {
        match.end(winner: winner)
    }
}

// MARK: - Team Deathmatch Mode

@MainActor
class TeamDeathmatchModeController: GameModeController {
    var match: Match
    var isMatchComplete: Bool {
        match.state == .completed
    }

    private let eliminationsToWin: Int = 50

    init(match: Match, eliminationsToWin: Int = 50) {
        self.match = match
        self.eliminationsToWin = eliminationsToWin
    }

    func start() {
        match.state = .active
        match.startTime = Date()
    }

    func update(deltaTime: TimeInterval) {
        // Check victory conditions
        if let winner = checkVictoryConditions() {
            endMatch(winner: winner)
        }

        // Check time limit
        if let startTime = match.startTime,
           Date().timeIntervalSince(startTime) >= match.matchSettings.timeLimit {
            // Time expired - team with higher score wins
            if match.team1.score > match.team2.score {
                endMatch(winner: match.team1)
            } else if match.team2.score > match.team1.score {
                endMatch(winner: match.team2)
            }
        }
    }

    func handlePlayerElimination(victim: UUID, killer: UUID) {
        // Award point to killer's team
        if match.team1.players.contains(where: { $0.id == killer }) {
            match.team1.score += 1
        } else if match.team2.players.contains(where: { $0.id == killer }) {
            match.team2.score += 1
        }

        // Update stats
        if let victimIndex = match.team1.players.firstIndex(where: { $0.id == victim }) {
            match.team1.players[victimIndex].recordDeath()
        } else if let victimIndex = match.team2.players.firstIndex(where: { $0.id == victim }) {
            match.team2.players[victimIndex].recordDeath()
        }

        if let killerIndex = match.team1.players.firstIndex(where: { $0.id == killer }) {
            match.team1.players[killerIndex].recordElimination()
        } else if let killerIndex = match.team2.players.firstIndex(where: { $0.id == killer }) {
            match.team2.players[killerIndex].recordElimination()
        }

        // Record event
        let event = MatchEvent.playerElimination(
            killerID: killer,
            victimID: victim,
            timestamp: Date().timeIntervalSince1970
        )
        match.addEvent(event)

        // Respawn player
        // TODO: Schedule respawn after delay
    }

    func handleObjectiveCaptured(objectiveID: UUID, team: TeamColor) {
        // Not used in Team Deathmatch
    }

    func checkVictoryConditions() -> Team? {
        if match.team1.score >= eliminationsToWin {
            return match.team1
        } else if match.team2.score >= eliminationsToWin {
            return match.team2
        }

        return nil
    }

    private func endMatch(winner: Team) {
        match.end(winner: winner)
    }
}

// MARK: - Game Mode Factory

@MainActor
class GameModeFactory {
    static func createController(for match: Match) -> GameModeController {
        switch match.gameMode {
        case .elimination:
            return EliminationModeController(match: match)
        case .domination:
            return DominationModeController(match: match)
        case .artifactHunt:
            return ArtifactHuntModeController(match: match)
        case .teamDeathmatch:
            return TeamDeathmatchModeController(match: match)
        case .freeForAll:
            // Similar to elimination but FFA
            return EliminationModeController(match: match)
        case .kingOfTheHill:
            // Similar to domination but single moving zone
            return DominationModeController(match: match)
        case .custom:
            // Default to elimination
            return EliminationModeController(match: match)
        }
    }
}
