//
//  BlockSystem.swift
//  Reality Minecraft
//
//  Block data models and chunk system
//

import Foundation
import simd

// MARK: - Block Type

/// Represents a type of block with all its properties
struct BlockType: Hashable, Codable {
    let id: String
    let displayName: String
    let textureAtlasIndex: Int
    let isTransparent: Bool
    let isSolid: Bool
    let hardness: Float
    let toolRequired: ToolType?
    let lightEmission: Int // 0-15
    let properties: BlockProperties

    // Common block types
    static let air = BlockType(
        id: "air",
        displayName: "Air",
        textureAtlasIndex: 0,
        isTransparent: true,
        isSolid: false,
        hardness: 0,
        toolRequired: nil,
        lightEmission: 0,
        properties: BlockProperties()
    )

    static let dirt = BlockType(
        id: "dirt",
        displayName: "Dirt",
        textureAtlasIndex: 1,
        isTransparent: false,
        isSolid: true,
        hardness: 0.5,
        toolRequired: nil,
        lightEmission: 0,
        properties: BlockProperties()
    )

    static let grass = BlockType(
        id: "grass",
        displayName: "Grass",
        textureAtlasIndex: 2,
        isTransparent: false,
        isSolid: true,
        hardness: 0.6,
        toolRequired: nil,
        lightEmission: 0,
        properties: BlockProperties()
    )

    static let stone = BlockType(
        id: "stone",
        displayName: "Stone",
        textureAtlasIndex: 3,
        isTransparent: false,
        isSolid: true,
        hardness: 1.5,
        toolRequired: .pickaxe(.any),
        lightEmission: 0,
        properties: BlockProperties()
    )

    static let cobblestone = BlockType(
        id: "cobblestone",
        displayName: "Cobblestone",
        textureAtlasIndex: 4,
        isTransparent: false,
        isSolid: true,
        hardness: 2.0,
        toolRequired: .pickaxe(.any),
        lightEmission: 0,
        properties: BlockProperties()
    )

    static let oakLog = BlockType(
        id: "oak_log",
        displayName: "Oak Log",
        textureAtlasIndex: 5,
        isTransparent: false,
        isSolid: true,
        hardness: 2.0,
        toolRequired: nil,
        lightEmission: 0,
        properties: BlockProperties(isFlammable: true)
    )

    static let oakPlanks = BlockType(
        id: "oak_planks",
        displayName: "Oak Planks",
        textureAtlasIndex: 6,
        isTransparent: false,
        isSolid: true,
        hardness: 2.0,
        toolRequired: nil,
        lightEmission: 0,
        properties: BlockProperties(isFlammable: true)
    )

    static let glass = BlockType(
        id: "glass",
        displayName: "Glass",
        textureAtlasIndex: 7,
        isTransparent: true,
        isSolid: true,
        hardness: 0.3,
        toolRequired: nil,
        lightEmission: 0,
        properties: BlockProperties()
    )

    static let torch = BlockType(
        id: "torch",
        displayName: "Torch",
        textureAtlasIndex: 8,
        isTransparent: true,
        isSolid: false,
        hardness: 0.0,
        toolRequired: nil,
        lightEmission: 14,
        properties: BlockProperties()
    )

    static let glowstone = BlockType(
        id: "glowstone",
        displayName: "Glowstone",
        textureAtlasIndex: 9,
        isTransparent: false,
        isSolid: true,
        hardness: 0.3,
        toolRequired: nil,
        lightEmission: 15,
        properties: BlockProperties()
    )

    // Registry of all block types
    static let registry: [String: BlockType] = [
        "air": air,
        "dirt": dirt,
        "grass": grass,
        "stone": stone,
        "cobblestone": cobblestone,
        "oak_log": oakLog,
        "oak_planks": oakPlanks,
        "glass": glass,
        "torch": torch,
        "glowstone": glowstone
    ]
}

/// Block properties
struct BlockProperties: Codable {
    var isGravityAffected: Bool = false
    var isFlammable: Bool = false
    var canBeWaterlogged: Bool = false
    var hasCollision: Bool = true
}

/// Tool types required for mining
enum ToolType: Codable, Equatable {
    case pickaxe(MaterialTier)
    case axe(MaterialTier)
    case shovel(MaterialTier)
    case hoe(MaterialTier)
    case sword(MaterialTier)
    case shears

    enum MaterialTier: String, Codable {
        case any
        case wood
        case stone
        case iron
        case diamond
        case gold
    }
}

// MARK: - Block

/// Represents a single block instance in the world
struct Block: Codable {
    let position: BlockPosition
    var type: BlockType
    var metadata: BlockMetadata?
    var lightLevel: Int // 0-15

    init(position: BlockPosition, type: BlockType, lightLevel: Int = 0) {
        self.position = position
        self.type = type
        self.lightLevel = lightLevel
        self.metadata = nil
    }

    func toWorldPosition(chunkOrigin: SIMD3<Float>, blockSize: Float = 0.1) -> SIMD3<Float> {
        return position.toWorldPosition(chunkOrigin: chunkOrigin, blockSize: blockSize)
    }
}

/// Block metadata for additional data
struct BlockMetadata: Codable {
    var rotation: Int?
    var customData: [String: String]?
}

// MARK: - Block Position

/// 3D position of a block in the world
struct BlockPosition: Hashable, Codable {
    let x: Int
    let y: Int
    let z: Int

    func toWorldPosition(chunkOrigin: SIMD3<Float>, blockSize: Float = 0.1) -> SIMD3<Float> {
        return SIMD3<Float>(
            Float(x) * blockSize + chunkOrigin.x,
            Float(y) * blockSize + chunkOrigin.y,
            Float(z) * blockSize + chunkOrigin.z
        )
    }

    func offset(x: Int = 0, y: Int = 0, z: Int = 0) -> BlockPosition {
        return BlockPosition(x: self.x + x, y: self.y + y, z: self.z + z)
    }
}

// MARK: - Chunk

/// A 16x16x16 section of blocks
class Chunk {
    static let CHUNK_SIZE = 16

    let position: ChunkPosition
    var blocks: [[[Block?]]] // 3D array [x][y][z]
    var entities: [GameEntity] = []
    var isDirty: Bool = true
    var meshNeedsUpdate: Bool = true

    init(position: ChunkPosition) {
        self.position = position

        // Initialize 3D array with nil (air blocks)
        self.blocks = Array(
            repeating: Array(
                repeating: Array(repeating: nil, count: Chunk.CHUNK_SIZE),
                count: Chunk.CHUNK_SIZE
            ),
            count: Chunk.CHUNK_SIZE
        )
    }

    /// Get block at local chunk position
    func getBlock(at localPos: BlockPosition) -> Block? {
        guard isValidPosition(localPos) else { return nil }
        return blocks[localPos.x][localPos.y][localPos.z]
    }

    /// Set block at local chunk position
    func setBlock(at localPos: BlockPosition, block: Block?) {
        guard isValidPosition(localPos) else { return }
        blocks[localPos.x][localPos.y][localPos.z] = block
        isDirty = true
        meshNeedsUpdate = true
    }

    /// Check if position is valid within chunk
    private func isValidPosition(_ pos: BlockPosition) -> Bool {
        return pos.x >= 0 && pos.x < Chunk.CHUNK_SIZE &&
               pos.y >= 0 && pos.y < Chunk.CHUNK_SIZE &&
               pos.z >= 0 && pos.z < Chunk.CHUNK_SIZE
    }

    /// Fill chunk with a pattern (for testing)
    func fillWithPattern() {
        // Fill bottom layer with grass
        for x in 0..<Chunk.CHUNK_SIZE {
            for z in 0..<Chunk.CHUNK_SIZE {
                let pos = BlockPosition(x: x, y: 0, z: z)
                setBlock(at: pos, block: Block(position: pos, type: .grass))
            }
        }

        // Add some stone blocks
        for x in 0..<Chunk.CHUNK_SIZE {
            for z in 0..<Chunk.CHUNK_SIZE {
                for y in 1..<3 {
                    if Bool.random() {
                        let pos = BlockPosition(x: x, y: y, z: z)
                        setBlock(at: pos, block: Block(position: pos, type: .stone))
                    }
                }
            }
        }
    }
}

// MARK: - Chunk Position

/// Position of a chunk in the world
struct ChunkPosition: Hashable, Codable {
    let x: Int
    let y: Int
    let z: Int

    func toWorldPosition(blockSize: Float = 0.1) -> SIMD3<Float> {
        let chunkSize = Float(Chunk.CHUNK_SIZE) * blockSize
        return SIMD3<Float>(
            Float(x) * chunkSize,
            Float(y) * chunkSize,
            Float(z) * chunkSize
        )
    }
}

// MARK: - Chunk Manager

/// Manages loading, unloading, and accessing chunks
@MainActor
class ChunkManager: ObservableObject {
    @Published private(set) var loadedChunks: [ChunkPosition: Chunk] = [:]

    private let maxLoadedChunks = 64
    private var chunkLoadQueue: [ChunkPosition] = []

    /// Get or create a chunk at position
    func getOrCreateChunk(at position: ChunkPosition) -> Chunk {
        if let chunk = loadedChunks[position] {
            return chunk
        }

        let chunk = Chunk(position: position)
        loadedChunks[position] = chunk

        // Unload distant chunks if needed
        if loadedChunks.count > maxLoadedChunks {
            unloadDistantChunks(from: position)
        }

        return chunk
    }

    /// Get chunk at position (returns nil if not loaded)
    func getChunk(at position: ChunkPosition) -> Chunk? {
        return loadedChunks[position]
    }

    /// Unload chunk at position
    func unloadChunk(at position: ChunkPosition) {
        loadedChunks.removeValue(forKey: position)
    }

    /// Unload chunks far from given position
    private func unloadDistantChunks(from centerPosition: ChunkPosition) {
        let maxDistance = 8 // chunks

        let chunksToUnload = loadedChunks.keys.filter { position in
            let distance = abs(position.x - centerPosition.x) +
                          abs(position.y - centerPosition.y) +
                          abs(position.z - centerPosition.z)
            return distance > maxDistance
        }

        for position in chunksToUnload {
            unloadChunk(at: position)
        }
    }

    /// Get block at world block position
    func getBlock(at worldPos: BlockPosition) -> Block? {
        let chunkPos = worldPosToChunkPos(worldPos)
        let localPos = worldPosToLocalPos(worldPos)

        guard let chunk = getChunk(at: chunkPos) else { return nil }
        return chunk.getBlock(at: localPos)
    }

    /// Set block at world block position
    func setBlock(at worldPos: BlockPosition, block: Block?) {
        let chunkPos = worldPosToChunkPos(worldPos)
        let localPos = worldPosToLocalPos(worldPos)

        let chunk = getOrCreateChunk(at: chunkPos)
        chunk.setBlock(at: localPos, block: block)
    }

    /// Convert world block position to chunk position
    private func worldPosToChunkPos(_ worldPos: BlockPosition) -> ChunkPosition {
        return ChunkPosition(
            x: worldPos.x / Chunk.CHUNK_SIZE,
            y: worldPos.y / Chunk.CHUNK_SIZE,
            z: worldPos.z / Chunk.CHUNK_SIZE
        )
    }

    /// Convert world block position to local chunk position
    private func worldPosToLocalPos(_ worldPos: BlockPosition) -> BlockPosition {
        return BlockPosition(
            x: worldPos.x % Chunk.CHUNK_SIZE,
            y: worldPos.y % Chunk.CHUNK_SIZE,
            z: worldPos.z % Chunk.CHUNK_SIZE
        )
    }

    /// Get all loaded chunks
    func getAllChunks() -> [Chunk] {
        return Array(loadedChunks.values)
    }

    /// Clear all chunks
    func clearAllChunks() {
        loadedChunks.removeAll()
    }
}

// MARK: - Block Face

/// Enum representing faces of a block (for rendering)
enum BlockFace {
    case top
    case bottom
    case north
    case south
    case east
    case west

    var normal: SIMD3<Float> {
        switch self {
        case .top: return SIMD3<Float>(0, 1, 0)
        case .bottom: return SIMD3<Float>(0, -1, 0)
        case .north: return SIMD3<Float>(0, 0, 1)
        case .south: return SIMD3<Float>(0, 0, -1)
        case .east: return SIMD3<Float>(1, 0, 0)
        case .west: return SIMD3<Float>(-1, 0, 0)
        }
    }
}
