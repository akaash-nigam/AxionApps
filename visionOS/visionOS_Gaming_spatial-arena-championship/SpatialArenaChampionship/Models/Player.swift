//
//  Player.swift
//  Spatial Arena Championship
//
//  Player data model
//

import Foundation
import simd

// MARK: - Player

struct Player: Codable, Identifiable, Hashable {
    let id: UUID
    var username: String
    var skillRating: Int
    var rank: RankTier

    // Combat stats
    var health: Float
    var maxHealth: Float
    var shields: Float
    var maxShields: Float
    var energy: Float
    var maxEnergy: Float

    // Abilities
    var primaryAbility: Ability
    var secondaryAbility: Ability
    var tacticalAbility: Ability
    var ultimateAbility: Ability
    var ultimateCharge: Float

    // Stats tracking
    var stats: PlayerStats

    // Spatial state
    var position: SIMD3<Float>
    var rotation: simd_quatf
    var velocity: SIMD3<Float>

    // Match state
    var team: TeamColor
    var isAlive: Bool
    var isDashing: Bool
    var isUsingAbility: Bool

    // Network sync
    var networkState: NetworkPlayerState
    var lastUpdateTimestamp: TimeInterval

    init(
        id: UUID = UUID(),
        username: String,
        skillRating: Int = 0,
        team: TeamColor = .neutral
    ) {
        self.id = id
        self.username = username
        self.skillRating = skillRating
        self.rank = RankTier.tier(for: skillRating)

        // Initialize combat stats
        self.health = GameConstants.Combat.baseHealth
        self.maxHealth = GameConstants.Combat.baseHealth
        self.shields = GameConstants.Combat.baseShields
        self.maxShields = GameConstants.Combat.baseShields
        self.energy = GameConstants.Combat.baseEnergy
        self.maxEnergy = GameConstants.Combat.baseEnergy

        // Initialize default abilities
        self.primaryAbility = Ability.primaryFire
        self.secondaryAbility = Ability.shieldWall
        self.tacticalAbility = Ability.dash
        self.ultimateAbility = Ability.novaBlast
        self.ultimateCharge = 0.0

        // Initialize stats
        self.stats = PlayerStats()

        // Initialize spatial state
        self.position = SIMD3<Float>(0, 0, 0)
        self.rotation = simd_quatf(angle: 0, axis: [0, 1, 0])
        self.velocity = SIMD3<Float>(0, 0, 0)

        // Initialize match state
        self.team = team
        self.isAlive = true
        self.isDashing = false
        self.isUsingAbility = false

        // Initialize network state
        self.networkState = NetworkPlayerState(playerID: id)
        self.lastUpdateTimestamp = Date().timeIntervalSince1970
    }

    // MARK: - Methods

    mutating func takeDamage(_ amount: Float, from source: UUID? = nil) {
        // Apply to shields first
        if shields > 0 {
            let shieldDamage = min(amount, shields)
            shields -= shieldDamage
            let remainingDamage = amount - shieldDamage
            if remainingDamage > 0 {
                health -= remainingDamage
            }
        } else {
            health -= amount
        }

        // Update stats
        stats.damageTaken += amount

        // Check death
        if health <= 0 {
            health = 0
            isAlive = false
        }
    }

    mutating func heal(_ amount: Float) {
        health = min(health + amount, maxHealth)
    }

    mutating func restoreShields(_ amount: Float) {
        shields = min(shields + amount, maxShields)
    }

    mutating func restoreEnergy(_ amount: Float) {
        energy = min(energy + amount, maxEnergy)
    }

    mutating func useEnergy(_ amount: Float) -> Bool {
        guard energy >= amount else { return false }
        energy -= amount
        return true
    }

    mutating func chargeUltimate(_ amount: Float) {
        ultimateCharge = min(ultimateCharge + amount, 100.0)
    }

    mutating func useUltimate() -> Bool {
        guard ultimateCharge >= GameConstants.Abilities.Ultimate.chargeRequired else {
            return false
        }
        ultimateCharge = 0
        return true
    }

    mutating func respawn(at position: SIMD3<Float>) {
        self.position = position
        self.health = maxHealth
        self.shields = maxShields
        self.energy = maxEnergy
        self.isAlive = true
        self.isDashing = false
        self.isUsingAbility = false
        self.velocity = SIMD3<Float>(0, 0, 0)
    }

    mutating func recordElimination() {
        stats.kills += 1
    }

    mutating func recordDeath() {
        stats.deaths += 1
    }

    mutating func recordAssist() {
        stats.assists += 1
    }
}

// MARK: - Player Stats

struct PlayerStats: Codable, Hashable {
    var kills: Int = 0
    var deaths: Int = 0
    var assists: Int = 0
    var damageDealt: Float = 0
    var damageTaken: Float = 0
    var healingDone: Float = 0
    var objectivesCaptured: Int = 0
    var shotsFired: Int = 0
    var shotsHit: Int = 0

    var kda: Float {
        let d = max(deaths, 1)
        return Float(kills + assists) / Float(d)
    }

    var accuracy: Float {
        guard shotsFired > 0 else { return 0 }
        return Float(shotsHit) / Float(shotsFired)
    }

    mutating func reset() {
        kills = 0
        deaths = 0
        assists = 0
        damageDealt = 0
        damageTaken = 0
        healingDone = 0
        objectivesCaptured = 0
        shotsFired = 0
        shotsHit = 0
    }
}

// MARK: - Network Player State

struct NetworkPlayerState: Codable, Hashable {
    let playerID: UUID
    var position: SIMD3<Float> = .zero
    var rotation: simd_quatf = simd_quatf(angle: 0, axis: [0, 1, 0])
    var velocity: SIMD3<Float> = .zero
    var health: Float = 100
    var shields: Float = 50
    var energy: Float = 100
    var ultimateCharge: Float = 0
    var isAlive: Bool = true
    var lastProcessedInput: UInt64 = 0
    var timestamp: TimeInterval = 0

    init(playerID: UUID) {
        self.playerID = playerID
    }
}

// MARK: - Player Profile (Persistent Data)

struct PlayerProfile: Codable {
    let playerID: UUID
    var username: String
    var skillRating: Int
    var rank: RankTier
    var level: Int
    var experience: Int
    var totalMatches: Int
    var totalWins: Int
    var totalLosses: Int
    var careerStats: PlayerStats
    var createdAt: Date
    var lastPlayed: Date

    init(username: String) {
        self.playerID = UUID()
        self.username = username
        self.skillRating = 0
        self.rank = .bronze
        self.level = 1
        self.experience = 0
        self.totalMatches = 0
        self.totalWins = 0
        self.totalLosses = 0
        self.careerStats = PlayerStats()
        self.createdAt = Date()
        self.lastPlayed = Date()
    }

    var winRate: Float {
        guard totalMatches > 0 else { return 0 }
        return Float(totalWins) / Float(totalMatches)
    }

    mutating func addMatchResult(won: Bool, stats: PlayerStats, srChange: Int) {
        totalMatches += 1
        if won {
            totalWins += 1
        } else {
            totalLosses += 1
        }

        skillRating += srChange
        rank = RankTier.tier(for: skillRating)

        // Merge career stats
        careerStats.kills += stats.kills
        careerStats.deaths += stats.deaths
        careerStats.assists += stats.assists
        careerStats.damageDealt += stats.damageDealt
        careerStats.damageTaken += stats.damageTaken
        careerStats.healingDone += stats.healingDone
        careerStats.objectivesCaptured += stats.objectivesCaptured
        careerStats.shotsFired += stats.shotsFired
        careerStats.shotsHit += stats.shotsHit

        lastPlayed = Date()
    }

    mutating func addExperience(_ xp: Int) {
        experience += xp

        // Level up logic (100 XP per level, scaling)
        let xpForNextLevel = level * 100
        if experience >= xpForNextLevel {
            level += 1
            experience -= xpForNextLevel
        }
    }
}
