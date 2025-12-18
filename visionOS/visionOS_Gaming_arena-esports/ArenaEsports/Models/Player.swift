import Foundation

/// Player model representing a competitive player
public struct Player: Identifiable, Codable, Sendable {
    public let id: UUID
    public var username: String
    public var skillRating: Int
    public var statistics: PlayerStatistics
    public var team: UUID?

    public init(
        id: UUID = UUID(),
        username: String,
        skillRating: Int = 1500,
        statistics: PlayerStatistics = PlayerStatistics(),
        team: UUID? = nil
    ) {
        self.id = id
        self.username = username
        self.skillRating = skillRating
        self.statistics = statistics
        self.team = team
    }
}

/// Player statistics
public struct PlayerStatistics: Codable, Sendable {
    public var matchesPlayed: Int
    public var wins: Int
    public var losses: Int
    public var kills: Int
    public var deaths: Int
    public var assists: Int

    public init(
        matchesPlayed: Int = 0,
        wins: Int = 0,
        losses: Int = 0,
        kills: Int = 0,
        deaths: Int = 0,
        assists: Int = 0
    ) {
        self.matchesPlayed = matchesPlayed
        self.wins = wins
        self.losses = losses
        self.kills = kills
        self.deaths = deaths
        self.assists = assists
    }

    public var winRate: Double {
        guard matchesPlayed > 0 else { return 0 }
        return Double(wins) / Double(matchesPlayed)
    }

    public var kda: Double {
        guard deaths > 0 else { return Double(kills + assists) }
        return Double(kills + assists) / Double(deaths)
    }
}
