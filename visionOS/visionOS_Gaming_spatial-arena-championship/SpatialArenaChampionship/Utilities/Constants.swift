//
//  Constants.swift
//  Spatial Arena Championship
//
//  Core game constants and configuration values
//

import Foundation
import simd

// MARK: - Game Constants

enum GameConstants {
    // MARK: - Performance Targets
    enum Performance {
        static let targetFPS: Int = 90
        static let targetFrameTime: Double = 1.0 / 90.0 // 11.1ms
        static let maxFrameTime: Double = 1.0 / 60.0 // 16.7ms fallback
    }

    // MARK: - Arena Configuration
    enum Arena {
        static let minPlaySpace = SIMD3<Float>(2.0, 2.5, 2.0) // 2m x 2.5m x 2m
        static let optimalPlaySpace = SIMD3<Float>(3.0, 2.5, 3.0) // 3m x 2.5m x 3m
        static let safetyBoundaryPadding: Float = 0.3 // 30cm padding from walls
        static let maxPlayers: Int = 10
    }

    // MARK: - Movement Configuration
    enum Movement {
        static let walkSpeed: Float = 1.5 // m/s
        static let sprintSpeed: Float = 3.0 // m/s
        static let dodgeSpeed: Float = 4.0 // m/s
        static let dodgeDuration: Float = 0.3 // seconds
        static let acceleration: Float = 8.0 // m/s²
        static let deceleration: Float = 10.0 // m/s²
        static let playerRadius: Float = 0.3 // meters
        static let playerHeight: Float = 1.8 // meters
    }

    // MARK: - Combat Configuration
    enum Combat {
        static let baseHealth: Float = 100.0
        static let baseShields: Float = 50.0
        static let baseEnergy: Float = 100.0
        static let energyRegenRate: Float = 10.0 // per second
        static let healthRegenDelay: Double = 5.0 // seconds
        static let healthRegenRate: Float = 10.0 // per second
        static let shieldRegenDelay: Double = 3.0 // seconds
        static let shieldRegenRate: Float = 20.0 // per second
        static let headshotMultiplier: Float = 2.0
        static let backstabMultiplier: Float = 1.5
    }

    // MARK: - Ability Configuration
    enum Abilities {
        // Primary Fire
        enum PrimaryFire {
            static let damage: Float = 20.0
            static let speed: Float = 10.0 // m/s
            static let cooldown: Double = 0.5
            static let energyCost: Float = 0.0
            static let projectileRadius: Float = 0.05
            static let maxRange: Float = 30.0
        }

        // Shield Wall
        enum Shield {
            static let durability: Float = 100.0
            static let duration: Double = 3.0
            static let cooldown: Double = 8.0
            static let energyCost: Float = 30.0
            static let size = SIMD3<Float>(2.0, 2.0, 0.1)
        }

        // Dash
        enum Dash {
            static let distance: Float = 2.0
            static let duration: Double = 0.2
            static let cooldown: Double = 6.0
            static let energyCost: Float = 20.0
        }

        // Grenade
        enum Grenade {
            static let damage: Float = 50.0
            static let radius: Float = 2.0
            static let cooldown: Double = 10.0
            static let energyCost: Float = 40.0
            static let fuseTime: Double = 2.0
        }

        // Ultimate - Nova Blast
        enum Ultimate {
            static let damage: Float = 50.0
            static let radius: Float = 5.0
            static let chargeRequired: Float = 100.0
            static let castTime: Double = 1.0
        }
    }

    // MARK: - Physics Configuration
    enum Physics {
        static let gravity = SIMD3<Float>(0, -9.81, 0)
        static let fixedTimestep: Double = 1.0 / 90.0
        static let maxSubsteps: Int = 3
        static let collisionMargin: Float = 0.001

        enum Materials {
            static let playerFriction: Float = 0.4
            static let playerRestitution: Float = 0.0
            static let projectileFriction: Float = 0.0
            static let projectileRestitution: Float = 0.8
            static let environmentFriction: Float = 0.6
            static let environmentRestitution: Float = 0.3
        }
    }

    // MARK: - Network Configuration
    enum Network {
        static let serverTickRate: Int = 30 // Hz
        static let clientUpdateRate: Int = 30 // Hz
        static let maxLatency: Double = 0.050 // 50ms
        static let timeoutDuration: Double = 10.0 // seconds
        static let interpolationDelay: Double = 0.1 // 100ms
        static let serviceType = "arena-champ"
    }

    // MARK: - Matchmaking Configuration
    enum Matchmaking {
        static let maxSkillDifference: Int = 500
        static let targetQueueTime: Double = 120.0 // 2 minutes
        static let matchQualityThreshold: Float = 0.75 // 75%
    }

    // MARK: - UI Configuration
    enum UI {
        static let hudUpdateRate: Double = 1.0 / 30.0 // 30 Hz
        static let minimapUpdateRate: Double = 1.0 / 15.0 // 15 Hz
        static let killFeedDuration: Double = 3.0 // seconds
    }

    // MARK: - Audio Configuration
    enum Audio {
        static let footstepRange: Float = 5.0 // meters
        static let weaponFireRange: Float = 15.0 // meters
        static let abilityRange: Float = 20.0 // meters
        static let explosionRange: Float = 25.0 // meters
    }

    // MARK: - Progression Configuration
    enum Progression {
        static let startingRank: Int = 0
        static let rankTiers = [
            "Bronze": 0...999,
            "Silver": 1000...1499,
            "Gold": 1500...1999,
            "Platinum": 2000...2499,
            "Diamond": 2500...2999,
            "Master": 3000...3499,
            "Grand Master": 3500...Int.max
        ]
        static let baseWinSR: Int = 15
        static let baseLossSR: Int = 15
        static let performanceBonusMax: Int = 5
        static let streakBonusThreshold: Int = 3
        static let streakBonus: Int = 5
    }

    // MARK: - Memory Budgets
    enum Memory {
        static let totalBudget: Int = 2_000_000_000 // 2GB
        static let textureBudget: Int = 500_000_000 // 500MB
        static let meshBudget: Int = 300_000_000 // 300MB
        static let audioBudget: Int = 200_000_000 // 200MB
        static let gameStateBudget: Int = 50_000_000 // 50MB
    }
}

// MARK: - Team Colors

enum TeamColor: String, Codable, CaseIterable {
    case blue
    case red
    case neutral

    var displayName: String {
        switch self {
        case .blue: return "Blue Team"
        case .red: return "Red Team"
        case .neutral: return "Neutral"
        }
    }

    var hexColor: UInt32 {
        switch self {
        case .blue: return 0x00BFFF // Cyan
        case .red: return 0xFF4444 // Scarlet
        case .neutral: return 0xFFAA00 // Gold
        }
    }
}

// MARK: - Game Modes

enum GameMode: String, Codable, CaseIterable {
    case elimination
    case domination
    case artifactHunt
    case teamDeathmatch
    case freeForAll
    case kingOfTheHill
    case custom

    var displayName: String {
        switch self {
        case .elimination: return "Elimination"
        case .domination: return "Domination"
        case .artifactHunt: return "Artifact Hunt"
        case .teamDeathmatch: return "Team Deathmatch"
        case .freeForAll: return "Free-For-All"
        case .kingOfTheHill: return "King of the Hill"
        case .custom: return "Custom Game"
        }
    }

    var description: String {
        switch self {
        case .elimination: return "Last player/team standing wins"
        case .domination: return "Control territory zones to earn points"
        case .artifactHunt: return "Collect and bank artifacts to score"
        case .teamDeathmatch: return "First team to elimination limit wins"
        case .freeForAll: return "Every player for themselves"
        case .kingOfTheHill: return "Control the moving capture zone"
        case .custom: return "Custom rules and settings"
        }
    }

    var minPlayers: Int {
        switch self {
        case .elimination: return 2
        case .domination: return 4
        case .artifactHunt: return 4
        case .teamDeathmatch: return 4
        case .freeForAll: return 3
        case .kingOfTheHill: return 4
        case .custom: return 1
        }
    }

    var maxPlayers: Int {
        switch self {
        case .elimination: return 6
        case .domination: return 10
        case .artifactHunt: return 10
        case .teamDeathmatch: return 10
        case .freeForAll: return 10
        case .kingOfTheHill: return 10
        case .custom: return 10
        }
    }
}

// MARK: - Arena Themes

enum ArenaTheme: String, Codable, CaseIterable {
    case cyberArena
    case ancientTemple
    case spaceStation
    case urbanWarfare
    case fantasyRealm

    var displayName: String {
        switch self {
        case .cyberArena: return "Cyber Arena"
        case .ancientTemple: return "Ancient Temple"
        case .spaceStation: return "Space Station"
        case .urbanWarfare: return "Urban Warfare"
        case .fantasyRealm: return "Fantasy Realm"
        }
    }

    var description: String {
        switch self {
        case .cyberArena: return "Futuristic neon arena with holographic elements"
        case .ancientTemple: return "Mystical ruins with stone pillars and ancient magic"
        case .spaceStation: return "Zero-G themed space facility"
        case .urbanWarfare: return "Futuristic city with building facades"
        case .fantasyRealm: return "Magical battlefield with enchanted elements"
        }
    }
}

// MARK: - Match Types

enum MatchType: String, Codable {
    case casual
    case ranked
    case tournament
    case custom
    case training

    var displayName: String {
        switch self {
        case .casual: return "Casual"
        case .ranked: return "Ranked"
        case .tournament: return "Tournament"
        case .custom: return "Custom"
        case .training: return "Training"
        }
    }
}

// MARK: - Ability Types

enum AbilityType: String, Codable {
    case projectile
    case shield
    case areaEffect
    case mobility
    case ultimate
    case heal
    case buff

    var displayName: String {
        switch self {
        case .projectile: return "Projectile"
        case .shield: return "Shield"
        case .areaEffect: return "Area Effect"
        case .mobility: return "Mobility"
        case .ultimate: return "Ultimate"
        case .heal: return "Heal"
        case .buff: return "Buff"
        }
    }
}

// MARK: - Rank Tier

enum RankTier: String, Codable, CaseIterable {
    case bronze
    case silver
    case gold
    case platinum
    case diamond
    case master
    case grandMaster
    case champion

    var displayName: String {
        switch self {
        case .bronze: return "Bronze"
        case .silver: return "Silver"
        case .gold: return "Gold"
        case .platinum: return "Platinum"
        case .diamond: return "Diamond"
        case .master: return "Master"
        case .grandMaster: return "Grand Master"
        case .champion: return "Champion"
        }
    }

    var srRange: ClosedRange<Int> {
        switch self {
        case .bronze: return 0...999
        case .silver: return 1000...1499
        case .gold: return 1500...1999
        case .platinum: return 2000...2499
        case .diamond: return 2500...2999
        case .master: return 3000...3499
        case .grandMaster: return 3500...4999
        case .champion: return 5000...Int.max
        }
    }

    static func tier(for sr: Int) -> RankTier {
        for tier in RankTier.allCases {
            if tier.srRange.contains(sr) {
                return tier
            }
        }
        return .bronze
    }
}

// MARK: - Error Types

enum GameError: Error, LocalizedError {
    case insufficientSpace
    case networkConnectionFailed
    case matchmakingTimeout
    case invalidGameState
    case performanceIssue
    case assetLoadingFailed

    var errorDescription: String? {
        switch self {
        case .insufficientSpace:
            return "Play space is too small. Minimum 2m x 2m required."
        case .networkConnectionFailed:
            return "Failed to connect to game server."
        case .matchmakingTimeout:
            return "Matchmaking timed out. Please try again."
        case .invalidGameState:
            return "Invalid game state encountered."
        case .performanceIssue:
            return "Performance below acceptable threshold."
        case .assetLoadingFailed:
            return "Failed to load game assets."
        }
    }
}
