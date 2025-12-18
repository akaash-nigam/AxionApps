//
//  Arena.swift
//  Spatial Arena Championship
//
//  Arena data model
//

import Foundation
import simd

// MARK: - Arena

struct Arena: Codable, Identifiable {
    let id: UUID
    var name: String
    var theme: ArenaTheme

    // Physical space requirements
    var dimensions: SIMD3<Float>
    var safetyBoundary: Float

    // Game elements
    var spawnPoints: [SpawnPoint]
    var objectiveZones: [ObjectiveZone]
    var powerUpSpawns: [PowerUpSpawn]
    var coverElements: [CoverElement]

    // Environment settings
    var lighting: LightingConfig
    var ambientAudio: String
    var hasEnvironmentalHazards: Bool

    init(
        id: UUID = UUID(),
        name: String,
        theme: ArenaTheme,
        dimensions: SIMD3<Float> = GameConstants.Arena.optimalPlaySpace
    ) {
        self.id = id
        self.name = name
        self.theme = theme
        self.dimensions = dimensions
        self.safetyBoundary = GameConstants.Arena.safetyBoundaryPadding

        // Initialize with default spawns
        self.spawnPoints = []
        self.objectiveZones = []
        self.powerUpSpawns = []
        self.coverElements = []

        self.lighting = LightingConfig.default
        self.ambientAudio = "ambient_\(theme.rawValue)"
        self.hasEnvironmentalHazards = false
    }

    var volume: Float {
        dimensions.x * dimensions.y * dimensions.z
    }

    var meetsMinimumSize: Bool {
        dimensions.x >= GameConstants.Arena.minPlaySpace.x &&
        dimensions.y >= GameConstants.Arena.minPlaySpace.y &&
        dimensions.z >= GameConstants.Arena.minPlaySpace.z
    }
}

// MARK: - Spawn Point

struct SpawnPoint: Codable, Identifiable {
    let id: UUID
    var position: SIMD3<Float>
    var rotation: Float // Y-axis rotation in radians
    var team: TeamColor

    init(
        id: UUID = UUID(),
        position: SIMD3<Float>,
        rotation: Float = 0,
        team: TeamColor = .neutral
    ) {
        self.id = id
        self.position = position
        self.rotation = rotation
        self.team = team
    }
}

// MARK: - Objective Zone

struct ObjectiveZone: Codable, Identifiable {
    let id: UUID
    var position: SIMD3<Float>
    var radius: Float
    var captureTime: TimeInterval
    var pointsPerSecond: Int

    init(
        id: UUID = UUID(),
        position: SIMD3<Float>,
        radius: Float = 1.5,
        captureTime: TimeInterval = 15.0,
        pointsPerSecond: Int = 1
    ) {
        self.id = id
        self.position = position
        self.radius = radius
        self.captureTime = captureTime
        self.pointsPerSecond = pointsPerSecond
    }
}

// MARK: - Power-Up Spawn

struct PowerUpSpawn: Codable, Identifiable {
    let id: UUID
    var position: SIMD3<Float>
    var powerUpType: PowerUpType
    var respawnTime: TimeInterval
    var lastSpawnTime: TimeInterval?

    enum PowerUpType: String, Codable {
        case health
        case shield
        case damage
        case speed
        case ultimateCharge

        var displayName: String {
            switch self {
            case .health: return "Health Boost"
            case .shield: return "Shield Boost"
            case .damage: return "Damage Boost"
            case .speed: return "Speed Boost"
            case .ultimateCharge: return "Ultimate Charge"
            }
        }

        var value: Float {
            switch self {
            case .health: return 50.0
            case .shield: return 50.0
            case .damage: return 1.5 // 50% increase
            case .speed: return 1.5 // 50% increase
            case .ultimateCharge: return 50.0
            }
        }

        var duration: TimeInterval {
            switch self {
            case .health, .shield, .ultimateCharge: return 0 // Instant
            case .damage, .speed: return 10.0 // 10 seconds
            }
        }
    }

    init(
        id: UUID = UUID(),
        position: SIMD3<Float>,
        powerUpType: PowerUpType,
        respawnTime: TimeInterval = 30.0
    ) {
        self.id = id
        self.position = position
        self.powerUpType = powerUpType
        self.respawnTime = respawnTime
    }

    func isAvailable(at time: TimeInterval) -> Bool {
        guard let lastSpawn = lastSpawnTime else { return true }
        return time - lastSpawn >= respawnTime
    }
}

// MARK: - Cover Element

struct CoverElement: Codable, Identifiable {
    let id: UUID
    var position: SIMD3<Float>
    var size: SIMD3<Float>
    var isDestructible: Bool
    var health: Float?

    init(
        id: UUID = UUID(),
        position: SIMD3<Float>,
        size: SIMD3<Float> = SIMD3(1.0, 2.0, 0.3),
        isDestructible: Bool = false,
        health: Float? = nil
    ) {
        self.id = id
        self.position = position
        self.size = size
        self.isDestructible = isDestructible
        self.health = health
    }
}

// MARK: - Lighting Config

struct LightingConfig: Codable {
    var ambientIntensity: Float
    var directionalIntensity: Float
    var shadowQuality: ShadowQuality

    enum ShadowQuality: String, Codable {
        case off
        case low
        case medium
        case high
    }

    static let `default` = LightingConfig(
        ambientIntensity: 0.5,
        directionalIntensity: 1.0,
        shadowQuality: .medium
    )
}

// MARK: - Predefined Arenas

extension Arena {
    static func cyberArena() -> Arena {
        var arena = Arena(
            name: "Cyber Arena",
            theme: .cyberArena,
            dimensions: SIMD3(3.0, 2.5, 3.0)
        )

        // Spawn points (symmetrical)
        arena.spawnPoints = [
            SpawnPoint(position: SIMD3(-1.0, 0, -1.0), rotation: .pi / 4, team: .blue),
            SpawnPoint(position: SIMD3(1.0, 0, 1.0), rotation: -.pi * 3 / 4, team: .red)
        ]

        // Objective zones (3 zones)
        arena.objectiveZones = [
            ObjectiveZone(position: SIMD3(-1.0, 0, 0)),
            ObjectiveZone(position: SIMD3(0, 0, 0)),
            ObjectiveZone(position: SIMD3(1.0, 0, 0))
        ]

        // Power-up spawns
        arena.powerUpSpawns = [
            PowerUpSpawn(position: SIMD3(0, 0.5, 1.0), powerUpType: .health),
            PowerUpSpawn(position: SIMD3(0, 0.5, -1.0), powerUpType: .damage, respawnTime: 60.0)
        ]

        // Cover elements
        arena.coverElements = [
            CoverElement(position: SIMD3(-0.5, 0, 0.5)),
            CoverElement(position: SIMD3(0.5, 0, -0.5))
        ]

        arena.lighting = LightingConfig(
            ambientIntensity: 0.4,
            directionalIntensity: 0.8,
            shadowQuality: .medium
        )

        return arena
    }

    static func ancientTemple() -> Arena {
        var arena = Arena(
            name: "Ancient Temple",
            theme: .ancientTemple,
            dimensions: SIMD3(3.0, 2.5, 3.0)
        )

        // More spawn points for larger space
        arena.spawnPoints = [
            SpawnPoint(position: SIMD3(-1.2, 0, -1.2), rotation: .pi / 4, team: .blue),
            SpawnPoint(position: SIMD3(-1.0, 0, -1.0), rotation: .pi / 4, team: .blue),
            SpawnPoint(position: SIMD3(1.2, 0, 1.2), rotation: -.pi * 3 / 4, team: .red),
            SpawnPoint(position: SIMD3(1.0, 0, 1.0), rotation: -.pi * 3 / 4, team: .red)
        ]

        // Multiple objective zones
        arena.objectiveZones = [
            ObjectiveZone(position: SIMD3(-1.0, 0, 0)),
            ObjectiveZone(position: SIMD3(0, 0, 0)),
            ObjectiveZone(position: SIMD3(1.0, 0, 0)),
            ObjectiveZone(position: SIMD3(0, 0, -1.0)),
            ObjectiveZone(position: SIMD3(0, 0, 1.0))
        ]

        // Strategic power-up placement
        arena.powerUpSpawns = [
            PowerUpSpawn(position: SIMD3(0, 0.5, 0), powerUpType: .ultimateCharge, respawnTime: 90.0),
            PowerUpSpawn(position: SIMD3(-1.0, 0.5, 1.0), powerUpType: .shield),
            PowerUpSpawn(position: SIMD3(1.0, 0.5, -1.0), powerUpType: .shield)
        ]

        // More cover with pillars
        arena.coverElements = [
            CoverElement(position: SIMD3(-0.8, 0, -0.8), size: SIMD3(0.4, 2.5, 0.4)),
            CoverElement(position: SIMD3(0.8, 0, -0.8), size: SIMD3(0.4, 2.5, 0.4)),
            CoverElement(position: SIMD3(-0.8, 0, 0.8), size: SIMD3(0.4, 2.5, 0.4)),
            CoverElement(position: SIMD3(0.8, 0, 0.8), size: SIMD3(0.4, 2.5, 0.4))
        ]

        arena.lighting = LightingConfig(
            ambientIntensity: 0.3,
            directionalIntensity: 1.2,
            shadowQuality: .high
        )

        return arena
    }

    static func spaceStation() -> Arena {
        var arena = Arena(
            name: "Space Station",
            theme: .spaceStation,
            dimensions: SIMD3(3.0, 2.5, 3.0)
        )

        // Space station spawns
        arena.spawnPoints = [
            SpawnPoint(position: SIMD3(-1.0, 0, 0), rotation: 0, team: .blue),
            SpawnPoint(position: SIMD3(1.0, 0, 0), rotation: .pi, team: .red)
        ]

        // Open space objectives
        arena.objectiveZones = [
            ObjectiveZone(position: SIMD3(0, 0, 0), radius: 2.0)
        ]

        // Strategic power-ups
        arena.powerUpSpawns = [
            PowerUpSpawn(position: SIMD3(0, 0.5, 1.2), powerUpType: .speed, respawnTime: 45.0),
            PowerUpSpawn(position: SIMD3(0, 0.5, -1.2), powerUpType: .speed, respawnTime: 45.0)
        ]

        // Minimal cover (open space combat)
        arena.coverElements = [
            CoverElement(position: SIMD3(0, 0, 0.7), size: SIMD3(2.0, 1.5, 0.2)),
            CoverElement(position: SIMD3(0, 0, -0.7), size: SIMD3(2.0, 1.5, 0.2))
        ]

        arena.lighting = LightingConfig(
            ambientIntensity: 0.6,
            directionalIntensity: 0.5,
            shadowQuality: .low
        )

        return arena
    }

    static let allPredefined: [Arena] = [
        .cyberArena(),
        .ancientTemple(),
        .spaceStation()
    ]
}
