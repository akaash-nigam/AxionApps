//
//  WorldData.swift
//  Reality Minecraft
//
//  World data model and persistence
//

import Foundation
import simd

// MARK: - World Data

/// Represents a complete game world
struct WorldData: Codable, Identifiable {
    let id: UUID
    let name: String
    let createdDate: Date
    var lastPlayedDate: Date

    var seed: Int64
    var gameMode: GameMode
    var difficulty: GameMode.Difficulty

    var spawnPosition: SIMD3<Float>
    var currentTime: Int // Game ticks
    var isRaining: Bool

    var worldAnchors: [WorldAnchorData]
    var playerData: PlayerData

    static func createNew(name: String) -> WorldData {
        return WorldData(
            id: UUID(),
            name: name,
            createdDate: Date(),
            lastPlayedDate: Date(),
            seed: Int64.random(in: 0...Int64.max),
            gameMode: .creative,
            difficulty: .normal,
            spawnPosition: SIMD3<Float>(0, 0, 0),
            currentTime: 0,
            isRaining: false,
            worldAnchors: [],
            playerData: PlayerData.default
        )
    }
}

// MARK: - World Anchor Data

/// Serializable world anchor data
struct WorldAnchorData: Codable, Identifiable {
    let id: UUID
    let transform: CodableTransform
    var associatedChunks: [ChunkPosition]
}

// MARK: - Player Data

/// Player-specific data for a world
struct PlayerData: Codable {
    var health: Float
    var hunger: Float
    var experience: Int
    var level: Int
    var position: SIMD3<Float>
    var rotation: CodableQuaternion
    var inventory: Inventory

    static var `default`: PlayerData {
        return PlayerData(
            health: 20.0,
            hunger: 20.0,
            experience: 0,
            level: 0,
            position: SIMD3<Float>(0, 0, 0),
            rotation: CodableQuaternion(simd_quatf(angle: 0, axis: SIMD3<Float>(0, 1, 0))),
            inventory: Inventory(maxSlots: 36)
        )
    }
}

// MARK: - Codable Transform

/// Codable version of Transform
struct CodableTransform: Codable {
    let position: SIMD3<Float>
    let rotation: CodableQuaternion
    let scale: SIMD3<Float>

    var matrix: simd_float4x4 {
        var matrix = simd_float4x4(rotation.quaternion)
        matrix.columns.3 = SIMD4<Float>(position.x, position.y, position.z, 1)

        let scaleMatrix = simd_float4x4(
            SIMD4<Float>(scale.x, 0, 0, 0),
            SIMD4<Float>(0, scale.y, 0, 0),
            SIMD4<Float>(0, 0, scale.z, 0),
            SIMD4<Float>(0, 0, 0, 1)
        )

        return matrix * scaleMatrix
    }
}

// MARK: - Codable Quaternion

/// Codable version of simd_quatf
struct CodableQuaternion: Codable {
    let x: Float
    let y: Float
    let z: Float
    let w: Float

    init(_ quaternion: simd_quatf) {
        self.x = quaternion.vector.x
        self.y = quaternion.vector.y
        self.z = quaternion.vector.z
        self.w = quaternion.vector.w
    }

    var quaternion: simd_quatf {
        return simd_quatf(vector: SIMD4<Float>(x, y, z, w))
    }
}

// MARK: - SIMD3 Codable Extension

extension SIMD3: Codable where Scalar == Float {
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        let x = try container.decode(Float.self)
        let y = try container.decode(Float.self)
        let z = try container.decode(Float.self)
        self.init(x, y, z)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(self.x)
        try container.encode(self.y)
        try container.encode(self.z)
    }
}

// MARK: - World Persistence Manager

/// Manages saving and loading worlds
class WorldPersistenceManager {
    private let fileManager = FileManager.default
    private var worldsDirectory: URL

    init() {
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        worldsDirectory = documentsPath.appendingPathComponent("Worlds")

        try? fileManager.createDirectory(at: worldsDirectory, withIntermediateDirectories: true)
    }

    /// Save a world to disk
    func saveWorld(_ world: WorldData) async throws {
        let worldPath = worldsDirectory.appendingPathComponent("\(world.id.uuidString).world")

        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try encoder.encode(world)

        try data.write(to: worldPath)
        print("✅ World saved: \(world.name)")
    }

    /// Load a world from disk
    func loadWorld(id: UUID) async throws -> WorldData {
        let worldPath = worldsDirectory.appendingPathComponent("\(id.uuidString).world")

        let data = try Data(contentsOf: worldPath)
        let decoder = JSONDecoder()
        let world = try decoder.decode(WorldData.self, from: data)

        print("✅ World loaded: \(world.name)")
        return world
    }

    /// List all saved worlds
    func listWorlds() throws -> [WorldData] {
        let worldFiles = try fileManager.contentsOfDirectory(
            at: worldsDirectory,
            includingPropertiesForKeys: nil
        ).filter { $0.pathExtension == "world" }

        var worlds: [WorldData] = []

        for file in worldFiles {
            if let data = try? Data(contentsOf: file),
               let world = try? JSONDecoder().decode(WorldData.self, from: data) {
                worlds.append(world)
            }
        }

        return worlds.sorted { $0.lastPlayedDate > $1.lastPlayedDate }
    }

    /// Delete a world
    func deleteWorld(id: UUID) throws {
        let worldPath = worldsDirectory.appendingPathComponent("\(id.uuidString).world")
        try fileManager.removeItem(at: worldPath)
        print("🗑 World deleted: \(id)")
    }
}
