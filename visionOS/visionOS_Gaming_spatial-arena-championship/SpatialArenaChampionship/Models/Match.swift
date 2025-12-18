//
//  Match.swift
//  Spatial Arena Championship
//
//  Match data model
//

import Foundation
import simd

// MARK: - Match

struct Match: Codable, Identifiable {
    let id: UUID
    var matchType: MatchType
    var gameMode: GameMode
    var arenaTheme: ArenaTheme

    var team1: Team
    var team2: Team

    var state: MatchState
    var startTime: Date?
    var endTime: Date?
    var matchSettings: MatchSettings

    var objectives: [Objective]
    var events: [MatchEvent]

    var winCondition: WinCondition
    var winner: Team?

    init(
        id: UUID = UUID(),
        matchType: MatchType,
        gameMode: GameMode,
        arenaTheme: ArenaTheme,
        team1: Team,
        team2: Team,
        matchSettings: MatchSettings = MatchSettings()
    ) {
        self.id = id
        self.matchType = matchType
        self.gameMode = gameMode
        self.arenaTheme = arenaTheme
        self.team1 = team1
        self.team2 = team2
        self.state = .pending
        self.matchSettings = matchSettings
        self.objectives = []
        self.events = []
        self.winCondition = gameMode.defaultWinCondition
    }

    var duration: TimeInterval {
        guard let start = startTime else { return 0 }
        let end = endTime ?? Date()
        return end.timeIntervalSince(start)
    }

    mutating func start() {
        state = .active
        startTime = Date()
        addEvent(.matchStart)
    }

    mutating func end(winner: Team) {
        state = .completed
        endTime = Date()
        self.winner = winner
        addEvent(.matchEnd(winnerTeam: winner.color))
    }

    mutating func addEvent(_ event: MatchEvent) {
        events.append(event)
    }

    mutating func updateScore(team: TeamColor, points: Int) {
        if team == team1.color {
            team1.score += points
        } else if team == team2.color {
            team2.score += points
        }

        checkWinCondition()
    }

    mutating func checkWinCondition() {
        switch winCondition {
        case .scoreLimit(let limit):
            if team1.score >= limit {
                end(winner: team1)
            } else if team2.score >= limit {
                end(winner: team2)
            }
        case .elimination:
            let team1Alive = team1.players.filter { $0.isAlive }.count
            let team2Alive = team2.players.filter { $0.isAlive }.count

            if team1Alive == 0 {
                end(winner: team2)
            } else if team2Alive == 0 {
                end(winner: team1)
            }
        case .timeLimit:
            // Check if time expired
            guard let start = startTime else { return }
            if Date().timeIntervalSince(start) >= matchSettings.timeLimit {
                // Team with higher score wins
                if team1.score > team2.score {
                    end(winner: team1)
                } else if team2.score > team1.score {
                    end(winner: team2)
                }
            }
        case .custom:
            // Custom win conditions handled separately
            break
        }
    }
}

// MARK: - Team

struct Team: Codable, Identifiable {
    let id: UUID
    var name: String
    var color: TeamColor
    var players: [Player]
    var score: Int

    init(
        id: UUID = UUID(),
        name: String,
        color: TeamColor,
        players: [Player] = []
    ) {
        self.id = id
        self.name = name
        self.color = color
        self.players = players
        self.score = 0
    }

    var isAlive: Bool {
        players.contains { $0.isAlive }
    }

    var aliveCount: Int {
        players.filter { $0.isAlive }.count
    }

    mutating func addPlayer(_ player: Player) {
        var playerWithTeam = player
        playerWithTeam.team = color
        players.append(playerWithTeam)
    }

    mutating func removePlayer(_ playerID: UUID) {
        players.removeAll { $0.id == playerID }
    }
}

// MARK: - Match State

enum MatchState: String, Codable {
    case pending        // Waiting to start
    case loading        // Loading assets
    case countdown      // Pre-match countdown
    case active         // Match in progress
    case paused         // Match paused
    case overtime       // Overtime period
    case completed      // Match ended
    case cancelled      // Match cancelled
}

// MARK: - Win Condition

enum WinCondition: Codable, Hashable {
    case scoreLimit(Int)
    case elimination
    case timeLimit
    case custom

    var description: String {
        switch self {
        case .scoreLimit(let limit):
            return "First to \(limit) points"
        case .elimination:
            return "Last team standing"
        case .timeLimit:
            return "Highest score when time expires"
        case .custom:
            return "Custom win condition"
        }
    }
}

// MARK: - Match Settings

struct MatchSettings: Codable {
    var timeLimit: TimeInterval = 900 // 15 minutes
    var scoreLimit: Int = 300
    var respawnEnabled: Bool = true
    var respawnDelay: TimeInterval = 5.0
    var friendlyFire: Bool = false
    var abilityCooldownMultiplier: Float = 1.0
    var damageMultiplier: Float = 1.0
    var movementSpeedMultiplier: Float = 1.0
}

// MARK: - Objective

struct Objective: Codable, Identifiable {
    let id: UUID
    var type: ObjectiveType
    var position: SIMD3<Float>
    var radius: Float
    var state: ObjectiveState
    var controllingTeam: TeamColor?
    var captureProgress: Float = 0.0
    var contestedBy: Set<TeamColor> = []

    enum ObjectiveType: String, Codable {
        case captureZone
        case artifact
        case powerUp
        case controlPoint
    }

    enum ObjectiveState: String, Codable {
        case neutral
        case capturing
        case captured
        case contested
    }

    mutating func startCapture(by team: TeamColor) {
        state = .capturing
        contestedBy = [team]
    }

    mutating func complete(by team: TeamColor) {
        state = .captured
        controllingTeam = team
        captureProgress = 1.0
        contestedBy = []
    }

    mutating func contest(by teams: Set<TeamColor>) {
        state = .contested
        contestedBy = teams
    }

    mutating func reset() {
        state = .neutral
        controllingTeam = nil
        captureProgress = 0.0
        contestedBy = []
    }
}

// MARK: - Match Event

enum MatchEvent: Codable {
    case matchStart
    case matchEnd(winnerTeam: TeamColor)
    case playerElimination(killerID: UUID, victimID: UUID, timestamp: TimeInterval)
    case objectiveCaptured(objectiveID: UUID, team: TeamColor, timestamp: TimeInterval)
    case abilityUsed(playerID: UUID, ability: String, timestamp: TimeInterval)
    case teamWipe(team: TeamColor, timestamp: TimeInterval)
    case firstBlood(killerID: UUID, victimID: UUID, timestamp: TimeInterval)
    case doubleKill(killerID: UUID, timestamp: TimeInterval)
    case tripleKill(killerID: UUID, timestamp: TimeInterval)
    case killingSpree(killerID: UUID, killCount: Int, timestamp: TimeInterval)

    var timestamp: TimeInterval {
        switch self {
        case .matchStart, .matchEnd:
            return Date().timeIntervalSince1970
        case .playerElimination(_, _, let time),
             .objectiveCaptured(_, _, let time),
             .abilityUsed(_, _, let time),
             .teamWipe(_, let time),
             .firstBlood(_, _, let time),
             .doubleKill(_, let time),
             .tripleKill(_, let time),
             .killingSpree(_, _, let time):
            return time
        }
    }

    var description: String {
        switch self {
        case .matchStart:
            return "Match Started"
        case .matchEnd(let winner):
            return "\(winner.displayName) wins!"
        case .playerElimination(let killer, let victim, _):
            return "Player \(killer) eliminated \(victim)"
        case .objectiveCaptured(_, let team, _):
            return "\(team.displayName) captured objective"
        case .abilityUsed(_, let ability, _):
            return "Used \(ability)"
        case .teamWipe(let team, _):
            return "\(team.displayName) wiped out!"
        case .firstBlood:
            return "First Blood!"
        case .doubleKill:
            return "Double Kill!"
        case .tripleKill:
            return "Triple Kill!"
        case .killingSpree(_, let count, _):
            return "Killing Spree! (\(count) kills)"
        }
    }
}

// MARK: - Match Result

struct MatchResult: Codable {
    let matchID: UUID
    let winningTeam: TeamColor
    let losingTeam: TeamColor
    let duration: TimeInterval
    let finalScore: (team1: Int, team2: Int)
    let playerStats: [UUID: PlayerStats]
    let mvpPlayerID: UUID?

    init(from match: Match) {
        self.matchID = match.id
        self.winningTeam = match.winner?.color ?? .neutral
        self.losingTeam = winningTeam == match.team1.color ? match.team2.color : match.team1.color
        self.duration = match.duration
        self.finalScore = (match.team1.score, match.team2.score)

        // Collect player stats
        var stats: [UUID: PlayerStats] = [:]
        for player in match.team1.players + match.team2.players {
            stats[player.id] = player.stats
        }
        self.playerStats = stats

        // Determine MVP (highest KDA)
        let mvp = (match.team1.players + match.team2.players)
            .max { $0.stats.kda < $1.stats.kda }
        self.mvpPlayerID = mvp?.id
    }
}

// MARK: - Game Mode Extensions

extension GameMode {
    var defaultWinCondition: WinCondition {
        switch self {
        case .elimination:
            return .elimination
        case .domination:
            return .scoreLimit(300)
        case .artifactHunt:
            return .scoreLimit(10)
        case .teamDeathmatch:
            return .scoreLimit(50)
        case .freeForAll:
            return .scoreLimit(20)
        case .kingOfTheHill:
            return .scoreLimit(200)
        case .custom:
            return .custom
        }
    }

    var defaultTimeLimit: TimeInterval {
        switch self {
        case .elimination:
            return 600 // 10 minutes
        case .domination:
            return 900 // 15 minutes
        case .artifactHunt:
            return 720 // 12 minutes
        case .teamDeathmatch:
            return 600 // 10 minutes
        case .freeForAll:
            return 600 // 10 minutes
        case .kingOfTheHill:
            return 480 // 8 minutes
        case .custom:
            return 900 // 15 minutes
        }
    }
}
