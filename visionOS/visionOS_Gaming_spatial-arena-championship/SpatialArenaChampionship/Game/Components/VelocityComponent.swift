//
//  VelocityComponent.swift
//  Spatial Arena Championship
//
//  Velocity and movement component
//

import Foundation
import RealityKit
import simd

// MARK: - Velocity Component

struct VelocityComponent: Component, Codable {
    var linear: SIMD3<Float>
    var angular: SIMD3<Float>
    var maxSpeed: Float

    init(
        linear: SIMD3<Float> = .zero,
        angular: SIMD3<Float> = .zero,
        maxSpeed: Float = GameConstants.Movement.walkSpeed
    ) {
        self.linear = linear
        self.angular = angular
        self.maxSpeed = maxSpeed
    }

    var speed: Float {
        simd_length(linear)
    }

    mutating func clampSpeed() {
        let currentSpeed = speed
        if currentSpeed > maxSpeed {
            linear = normalize(linear) * maxSpeed
        }
    }

    mutating func applyFriction(deltaTime: Float, friction: Float = 0.9) {
        linear *= friction
    }
}

// MARK: - Energy Component

struct EnergyComponent: Component, Codable {
    var current: Float
    var maximum: Float
    var regenRate: Float

    init(
        energy: Float = GameConstants.Combat.baseEnergy,
        regenRate: Float = GameConstants.Combat.energyRegenRate
    ) {
        self.current = energy
        self.maximum = energy
        self.regenRate = regenRate
    }

    var energyPercentage: Float {
        guard maximum > 0 else { return 0 }
        return current / maximum
    }

    mutating func use(_ amount: Float) -> Bool {
        guard current >= amount else { return false }
        current -= amount
        return true
    }

    mutating func restore(_ amount: Float) {
        current = min(current + amount, maximum)
    }

    mutating func regenerate(deltaTime: TimeInterval) {
        current = min(current + regenRate * Float(deltaTime), maximum)
    }
}

// MARK: - Projectile Component

struct ProjectileComponent: Component, Codable {
    var damage: Float
    var speed: Float
    var lifetime: TimeInterval
    var spawnTime: TimeInterval
    var ownerID: UUID
    var team: TeamColor
    var ignoreList: Set<UUID> // Entities already hit

    init(
        damage: Float,
        speed: Float,
        lifetime: TimeInterval = 5.0,
        ownerID: UUID,
        team: TeamColor
    ) {
        self.damage = damage
        self.speed = speed
        self.lifetime = lifetime
        self.spawnTime = Date().timeIntervalSince1970
        self.ownerID = ownerID
        self.team = team
        self.ignoreList = [ownerID] // Don't hit self
    }

    func isExpired(at time: TimeInterval) -> Bool {
        return time - spawnTime >= lifetime
    }

    mutating func markHit(_ entityID: UUID) {
        ignoreList.insert(entityID)
    }

    func hasHit(_ entityID: UUID) -> Bool {
        ignoreList.contains(entityID)
    }
}

// MARK: - Shield Component

struct ShieldComponent: Component, Codable {
    var durability: Float
    var maxDurability: Float
    var size: SIMD3<Float>
    var spawnTime: TimeInterval
    var duration: TimeInterval
    var ownerID: UUID
    var team: TeamColor

    init(
        durability: Float,
        size: SIMD3<Float>,
        duration: TimeInterval,
        ownerID: UUID,
        team: TeamColor
    ) {
        self.durability = durability
        self.maxDurability = durability
        self.size = size
        self.spawnTime = Date().timeIntervalSince1970
        self.duration = duration
        self.ownerID = ownerID
        self.team = team
    }

    func isExpired(at time: TimeInterval) -> Bool {
        return time - spawnTime >= duration || durability <= 0
    }

    mutating func takeDamage(_ amount: Float) {
        durability = max(0, durability - amount)
    }
}

// MARK: - Territory Component

struct TerritoryComponent: Component, Codable {
    var captureRadius: Float
    var captureProgress: Float
    var controllingTeam: TeamColor?
    var contestedBy: Set<TeamColor>
    var captureRate: Float = 0.1 // Progress per second per player

    init(radius: Float = 1.5) {
        self.captureRadius = radius
        self.captureProgress = 0.0
        self.contestedBy = []
    }

    var isNeutral: Bool {
        controllingTeam == nil
    }

    var isContested: Bool {
        contestedBy.count > 1
    }

    mutating func startCapture(by team: TeamColor) {
        if !contestedBy.contains(team) {
            contestedBy.insert(team)
        }
    }

    mutating func updateCapture(teams: [TeamColor: Int], deltaTime: Float) {
        if teams.count == 1, let (team, playerCount) = teams.first {
            // Single team capturing
            contestedBy = [team]
            let rate = captureRate * Float(playerCount) * deltaTime

            if controllingTeam == team {
                // Already owned, maintain
                captureProgress = 1.0
            } else {
                // Capturing
                captureProgress += rate
                if captureProgress >= 1.0 {
                    controllingTeam = team
                    captureProgress = 1.0
                }
            }
        } else if teams.count > 1 {
            // Contested
            contestedBy = Set(teams.keys)
            captureProgress = max(0, captureProgress - 0.05 * deltaTime)
        } else {
            // No one on point
            contestedBy = []
            if controllingTeam == nil {
                captureProgress = max(0, captureProgress - 0.03 * deltaTime)
            }
        }
    }

    mutating func reset() {
        captureProgress = 0.0
        controllingTeam = nil
        contestedBy = []
    }
}

// MARK: - Lifetime Component

struct LifetimeComponent: Component, Codable {
    var spawnTime: TimeInterval
    var lifetime: TimeInterval

    init(lifetime: TimeInterval) {
        self.spawnTime = Date().timeIntervalSince1970
        self.lifetime = lifetime
    }

    func isExpired(at time: TimeInterval) -> Bool {
        return time - spawnTime >= lifetime
    }
}
