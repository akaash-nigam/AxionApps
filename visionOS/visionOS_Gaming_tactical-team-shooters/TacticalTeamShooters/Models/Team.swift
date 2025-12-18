import Foundation

struct Team: Codable, Identifiable, Hashable {
    let id: UUID
    var name: String
    var players: [Player]
    var score: Int = 0
    var side: TeamSide

    init(
        id: UUID = UUID(),
        name: String,
        players: [Player] = [],
        side: TeamSide
    ) {
        self.id = id
        self.name = name
        self.players = players
        self.side = side
    }

    mutating func addPlayer(_ player: Player) {
        guard players.count < 5 else { return }
        players.append(player)
    }

    mutating func removePlayer(_ playerId: UUID) {
        players.removeAll { $0.id == playerId }
    }

    var isFullTeam: Bool {
        players.count == 5
    }

    var averageRank: CompetitiveRank {
        guard !players.isEmpty else { return .recruit }
        let totalElo = players.reduce(0) { sum, player in
            sum + player.rank.eloRange.lowerBound
        }
        let averageElo = totalElo / players.count
        return CompetitiveRank.rank(for: averageElo)
    }
}

// MARK: - Team Side

enum TeamSide: String, Codable {
    case attackers
    case defenders

    var displayName: String {
        rawValue.capitalized
    }

    var color: String {
        switch self {
        case .attackers: return "orange"
        case .defenders: return "blue"
        }
    }

    var opposite: TeamSide {
        switch self {
        case .attackers: return .defenders
        case .defenders: return .attackers
        }
    }
}

// MARK: - Match

struct Match: Codable, Identifiable {
    let id: UUID
    let matchType: MatchType
    let map: GameMap
    var teams: [Team]
    var rounds: [Round] = []
    var startTime: Date
    var endTime: Date?
    var winner: Team?

    init(
        id: UUID = UUID(),
        matchType: MatchType,
        map: GameMap,
        teams: [Team]
    ) {
        self.id = id
        self.matchType = matchType
        self.map = map
        self.teams = teams
        self.startTime = Date()
    }

    var duration: TimeInterval {
        let end = endTime ?? Date()
        return end.timeIntervalSince(startTime)
    }

    var currentRound: Round? {
        rounds.last
    }

    var isComplete: Bool {
        winner != nil
    }
}

// MARK: - Match Type

enum MatchType: String, Codable {
    case casual
    case ranked
    case competitive
    case training
    case custom

    var displayName: String {
        rawValue.capitalized
    }

    var roundsToWin: Int {
        switch self {
        case .casual: return 8
        case .ranked: return 13
        case .competitive: return 13
        case .training: return 1
        case .custom: return 13
        }
    }

    var roundTime: TimeInterval {
        switch self {
        case .casual: return 90
        case .ranked: return 115
        case .competitive: return 115
        case .training: return 300
        case .custom: return 115
        }
    }
}

// MARK: - Game Map

struct GameMap: Codable, Identifiable, Hashable {
    let id: UUID
    let name: String
    let displayName: String
    let description: String
    let imageAsset: String

    init(
        id: UUID = UUID(),
        name: String,
        displayName: String,
        description: String,
        imageAsset: String
    ) {
        self.id = id
        self.name = name
        self.displayName = displayName
        self.description = description
        self.imageAsset = imageAsset
    }

    static let warehouse = GameMap(
        name: "warehouse",
        displayName: "Warehouse",
        description: "Industrial complex with multi-level layouts and long sightlines",
        imageAsset: "Map_Warehouse"
    )

    static let urbanEnvironment = GameMap(
        name: "urban",
        displayName: "Urban Assault",
        description: "City streets with close-quarters combat and vertical gameplay",
        imageAsset: "Map_Urban"
    )

    static let militaryBase = GameMap(
        name: "military_base",
        displayName: "Military Base",
        description: "Tactical facility with balanced attack and defense positions",
        imageAsset: "Map_MilitaryBase"
    )

    static var allMaps: [GameMap] {
        [.warehouse, .urbanEnvironment, .militaryBase]
    }
}

// MARK: - Round

struct Round: Codable, Identifiable {
    let id: UUID
    let number: Int
    var winner: Team?
    var startTime: Date
    var endTime: Date?
    var kills: [KillEvent] = []
    var objectiveCompleted: Bool = false
    var winCondition: WinCondition?

    init(
        id: UUID = UUID(),
        number: Int
    ) {
        self.id = id
        self.number = number
        self.startTime = Date()
    }

    var duration: TimeInterval {
        let end = endTime ?? Date()
        return end.timeIntervalSince(startTime)
    }

    mutating func recordKill(_ kill: KillEvent) {
        kills.append(kill)
    }
}

// MARK: - Win Condition

enum WinCondition: String, Codable {
    case elimination  // All enemies eliminated
    case objectiveComplete  // Bomb planted/defused, hostage rescued, etc.
    case timeExpired  // Time ran out
    case surrender  // Team surrendered

    var displayName: String {
        switch self {
        case .elimination: return "Elimination"
        case .objectiveComplete: return "Objective Complete"
        case .timeExpired: return "Time Expired"
        case .surrender: return "Surrender"
        }
    }
}

// MARK: - Kill Event

struct KillEvent: Codable, Identifiable {
    let id: UUID
    let killer: UUID  // Player ID
    let victim: UUID  // Player ID
    let weapon: UUID  // Weapon ID
    let isHeadshot: Bool
    let distance: Float
    let timestamp: Date

    init(
        id: UUID = UUID(),
        killer: UUID,
        victim: UUID,
        weapon: UUID,
        isHeadshot: Bool,
        distance: Float
    ) {
        self.id = id
        self.killer = killer
        self.victim = victim
        self.weapon = weapon
        self.isHeadshot = isHeadshot
        self.distance = distance
        self.timestamp = Date()
    }
}
