import Foundation

/// Match status
public enum MatchStatus: String, Codable, Sendable {
    case waiting
    case inProgress
    case paused
    case completed
    case cancelled
}

/// Game mode
public enum GameMode: String, Codable, Sendable {
    case elimination
    case domination
    case kingOfSphere
}

/// Match model
public struct Match: Identifiable, Codable, Sendable {
    public let id: UUID
    public var teamAPlayers: [UUID]
    public var teamBPlayers: [UUID]
    public var arena: Arena
    public var mode: GameMode
    public var status: MatchStatus
    public var score: MatchScore
    public var startTime: Date?
    public var endTime: Date?
    public var currentRound: Int

    public init(
        id: UUID = UUID(),
        teamAPlayers: [UUID],
        teamBPlayers: [UUID],
        arena: Arena,
        mode: GameMode = .elimination,
        status: MatchStatus = .waiting,
        score: MatchScore = MatchScore(),
        startTime: Date? = nil,
        endTime: Date? = nil,
        currentRound: Int = 0
    ) {
        self.id = id
        self.teamAPlayers = teamAPlayers
        self.teamBPlayers = teamBPlayers
        self.arena = arena
        self.mode = mode
        self.status = status
        self.score = score
        self.startTime = startTime
        self.endTime = endTime
        self.currentRound = currentRound
    }

    public var duration: TimeInterval? {
        guard let start = startTime, let end = endTime else { return nil }
        return end.timeIntervalSince(start)
    }

    public var winner: Winner? {
        guard status == .completed else { return nil }

        if score.teamA > score.teamB {
            return .teamA
        } else if score.teamB > score.teamA {
            return .teamB
        } else {
            return .draw
        }
    }

    public enum Winner: String, Codable, Sendable {
        case teamA
        case teamB
        case draw
    }
}

/// Match score
public struct MatchScore: Codable, Sendable {
    public var teamA: Int
    public var teamB: Int

    public init(teamA: Int = 0, teamB: Int = 0) {
        self.teamA = teamA
        self.teamB = teamB
    }
}
