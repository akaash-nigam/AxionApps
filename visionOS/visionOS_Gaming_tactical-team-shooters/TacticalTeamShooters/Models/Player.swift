import Foundation

struct Player: Codable, Identifiable, Hashable {
    let id: UUID
    var username: String
    var rank: CompetitiveRank
    var stats: PlayerStats
    var loadout: Loadout
    var teamRole: TeamRole

    // Runtime state (not persisted)
    var position: SIMD3<Float> = .zero
    var rotation: simd_quatf = simd_quatf(angle: 0, axis: SIMD3<Float>(0, 1, 0))
    var health: Float = 100.0
    var armor: Float = 0.0
    var currentWeapon: Weapon?
    var isAlive: Bool = true

    init(
        id: UUID = UUID(),
        username: String,
        rank: CompetitiveRank = .recruit,
        teamRole: TeamRole = .support
    ) {
        self.id = id
        self.username = username
        self.rank = rank
        self.stats = PlayerStats()
        self.loadout = Loadout()
        self.teamRole = teamRole
    }
}

// MARK: - Player Stats

struct PlayerStats: Codable, Hashable {
    var kills: Int = 0
    var deaths: Int = 0
    var assists: Int = 0
    var matchesPlayed: Int = 0
    var matchesWon: Int = 0
    var totalDamage: Int = 0
    var headshotKills: Int = 0
    var accuracy: Double = 0.0
    var headshotPercentage: Double = 0.0
    var tacticalScore: Double = 0.0
    var totalPlayTime: TimeInterval = 0.0

    var kdr: Double {
        deaths > 0 ? Double(kills) / Double(deaths) : Double(kills)
    }

    var winRate: Double {
        matchesPlayed > 0 ? Double(matchesWon) / Double(matchesPlayed) : 0.0
    }

    mutating func recordKill(headshot: Bool = false) {
        kills += 1
        if headshot {
            headshotKills += 1
        }
        updatePercentages()
    }

    mutating func recordDeath() {
        deaths += 1
    }

    mutating func recordAssist() {
        assists += 1
    }

    mutating func recordShot(hit: Bool) {
        // Update accuracy calculation
        // This would be more complex in practice
        if hit {
            accuracy = (accuracy * 0.95) + (1.0 * 0.05)
        } else {
            accuracy = (accuracy * 0.95) + (0.0 * 0.05)
        }
    }

    private mutating func updatePercentages() {
        if kills > 0 {
            headshotPercentage = Double(headshotKills) / Double(kills)
        }
    }
}

// MARK: - Competitive Rank

enum CompetitiveRank: String, Codable, CaseIterable {
    case recruit
    case specialist
    case veteran
    case elite
    case master
    case legend

    var displayName: String {
        rawValue.capitalized
    }

    var eloRange: ClosedRange<Int> {
        switch self {
        case .recruit: return 0...999
        case .specialist: return 1000...1499
        case .veteran: return 1500...1999
        case .elite: return 2000...2499
        case .master: return 2500...2999
        case .legend: return 3000...5000
        }
    }

    var emblemAsset: String {
        "Rank_\(rawValue)"
    }

    static func rank(for elo: Int) -> CompetitiveRank {
        for rank in CompetitiveRank.allCases {
            if rank.eloRange.contains(elo) {
                return rank
            }
        }
        return .legend
    }
}

// MARK: - Team Role

enum TeamRole: String, Codable, CaseIterable {
    case entryFragger
    case support
    case sniper
    case igl  // In-game leader
    case lurker

    var displayName: String {
        switch self {
        case .entryFragger: return "Entry Fragger"
        case .support: return "Support"
        case .sniper: return "Sniper"
        case .igl: return "IGL"
        case .lurker: return "Lurker"
        }
    }

    var description: String {
        switch self {
        case .entryFragger:
            return "First to engage enemies, opening up sites for the team"
        case .support:
            return "Uses utility to help teammates and provide cover fire"
        case .sniper:
            return "Long-range specialist, holds angles and picks off enemies"
        case .igl:
            return "Makes tactical decisions and coordinates team strategy"
        case .lurker:
            return "Operates independently to catch enemies off-guard"
        }
    }
}

// MARK: - Loadout

struct Loadout: Codable, Hashable {
    var primaryWeapon: UUID?
    var secondaryWeapon: UUID?
    var equipment: [Equipment] = []
    var tacticalAbility: TacticalAbility?

    init() {
        // Default loadout
        self.equipment = []
    }
}

enum TacticalAbility: String, Codable {
    case smokeGrenade
    case flashbang
    case fragGrenade
    case molotov
    case breachCharge

    var maxCount: Int {
        switch self {
        case .smokeGrenade: return 2
        case .flashbang: return 3
        case .fragGrenade: return 1
        case .molotov: return 1
        case .breachCharge: return 2
        }
    }
}
