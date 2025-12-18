//
//  BlockSystemTests.swift
//  Reality Minecraft Tests
//
//  Unit tests for block system and chunk management
//

import XCTest
@testable import Reality_Minecraft

final class BlockSystemTests: XCTestCase {

    var chunkManager: ChunkManager!

    override func setUp() {
        super.setUp()
        chunkManager = ChunkManager()
    }

    override func tearDown() {
        chunkManager = nil
        super.tearDown()
    }

    // MARK: - Block Type Tests

    func testBlockTypeRegistry() {
        // Test that all basic block types are registered
        XCTAssertNotNil(BlockType.registry["dirt"])
        XCTAssertNotNil(BlockType.registry["stone"])
        XCTAssertNotNil(BlockType.registry["grass"])
        XCTAssertNotNil(BlockType.registry["glass"])

        XCTAssertEqual(BlockType.registry.count, 10, "Should have 10 registered block types")
    }

    func testBlockProperties() {
        let stone = BlockType.stone
        XCTAssertEqual(stone.id, "stone")
        XCTAssertEqual(stone.hardness, 1.5)
        XCTAssertFalse(stone.isTransparent)
        XCTAssertTrue(stone.isSolid)
        XCTAssertEqual(stone.toolRequired, .pickaxe(.any))
    }

    func testTransparentBlocks() {
        XCTAssertTrue(BlockType.glass.isTransparent)
        XCTAssertTrue(BlockType.torch.isTransparent)
        XCTAssertFalse(BlockType.stone.isTransparent)
    }

    func testLightEmission() {
        XCTAssertEqual(BlockType.torch.lightEmission, 14)
        XCTAssertEqual(BlockType.glowstone.lightEmission, 15)
        XCTAssertEqual(BlockType.dirt.lightEmission, 0)
    }

    // MARK: - Block Position Tests

    func testBlockPositionOffset() {
        let pos = BlockPosition(x: 5, y: 10, z: 15)
        let offsetPos = pos.offset(x: 1, y: -2, z: 3)

        XCTAssertEqual(offsetPos.x, 6)
        XCTAssertEqual(offsetPos.y, 8)
        XCTAssertEqual(offsetPos.z, 18)
    }

    func testBlockPositionToWorldPosition() {
        let blockPos = BlockPosition(x: 10, y: 5, z: 20)
        let chunkOrigin = SIMD3<Float>(0, 0, 0)
        let worldPos = blockPos.toWorldPosition(chunkOrigin: chunkOrigin, blockSize: 0.1)

        XCTAssertEqual(worldPos.x, 1.0, accuracy: 0.001)
        XCTAssertEqual(worldPos.y, 0.5, accuracy: 0.001)
        XCTAssertEqual(worldPos.z, 2.0, accuracy: 0.001)
    }

    // MARK: - Chunk Tests

    func testChunkCreation() {
        let chunkPos = ChunkPosition(x: 0, y: 0, z: 0)
        let chunk = Chunk(position: chunkPos)

        XCTAssertEqual(chunk.position.x, 0)
        XCTAssertEqual(chunk.position.y, 0)
        XCTAssertEqual(chunk.position.z, 0)
        XCTAssertTrue(chunk.isDirty)
        XCTAssertTrue(chunk.meshNeedsUpdate)
    }

    func testChunkBlockStorage() {
        let chunk = Chunk(position: ChunkPosition(x: 0, y: 0, z: 0))
        let blockPos = BlockPosition(x: 5, y: 10, z: 15)
        let block = Block(position: blockPos, type: .stone)

        chunk.setBlock(at: blockPos, block: block)

        let retrievedBlock = chunk.getBlock(at: blockPos)
        XCTAssertNotNil(retrievedBlock)
        XCTAssertEqual(retrievedBlock?.type.id, "stone")
    }

    func testChunkInvalidPositions() {
        let chunk = Chunk(position: ChunkPosition(x: 0, y: 0, z: 0))

        // Test position outside chunk bounds
        let invalidPos = BlockPosition(x: 20, y: 5, z: 10)
        chunk.setBlock(at: invalidPos, block: Block(position: invalidPos, type: .dirt))

        // Should not crash, block should not be set
        let retrieved = chunk.getBlock(at: invalidPos)
        XCTAssertNil(retrieved)
    }

    func testChunkSize() {
        XCTAssertEqual(Chunk.CHUNK_SIZE, 16, "Chunk size should be 16x16x16")
    }

    // MARK: - Chunk Manager Tests

    func testChunkManagerCreation() {
        let chunkPos = ChunkPosition(x: 0, y: 0, z: 0)
        let chunk = chunkManager.getOrCreateChunk(at: chunkPos)

        XCTAssertEqual(chunk.position.x, 0)
        XCTAssertEqual(chunk.position.y, 0)
        XCTAssertEqual(chunk.position.z, 0)
    }

    func testChunkManagerReusesChunks() {
        let chunkPos = ChunkPosition(x: 1, y: 0, z: 1)

        let chunk1 = chunkManager.getOrCreateChunk(at: chunkPos)
        let chunk2 = chunkManager.getOrCreateChunk(at: chunkPos)

        // Should return the same chunk instance
        XCTAssertTrue(chunk1 === chunk2)
    }

    func testChunkManagerWorldBlockAccess() {
        let worldPos = BlockPosition(x: 20, y: 5, z: 30)
        let block = Block(position: worldPos, type: .grass)

        chunkManager.setBlock(at: worldPos, block: block)

        let retrieved = chunkManager.getBlock(at: worldPos)
        XCTAssertNotNil(retrieved)
        XCTAssertEqual(retrieved?.type.id, "grass")
    }

    func testChunkManagerClearsAllChunks() {
        // Create several chunks
        for x in 0..<5 {
            for z in 0..<5 {
                let pos = ChunkPosition(x: x, y: 0, z: z)
                _ = chunkManager.getOrCreateChunk(at: pos)
            }
        }

        let chunksBeforeClear = chunkManager.getAllChunks().count
        XCTAssertGreaterThan(chunksBeforeClear, 0)

        chunkManager.clearAllChunks()

        let chunksAfterClear = chunkManager.getAllChunks().count
        XCTAssertEqual(chunksAfterClear, 0)
    }

    // MARK: - Block Face Tests

    func testBlockFaceNormals() {
        XCTAssertEqual(BlockFace.top.normal, SIMD3<Float>(0, 1, 0))
        XCTAssertEqual(BlockFace.bottom.normal, SIMD3<Float>(0, -1, 0))
        XCTAssertEqual(BlockFace.north.normal, SIMD3<Float>(0, 0, 1))
        XCTAssertEqual(BlockFace.south.normal, SIMD3<Float>(0, 0, -1))
        XCTAssertEqual(BlockFace.east.normal, SIMD3<Float>(1, 0, 0))
        XCTAssertEqual(BlockFace.west.normal, SIMD3<Float>(-1, 0, 0))
    }

    // MARK: - Performance Tests

    func testChunkFillPerformance() {
        let chunk = Chunk(position: ChunkPosition(x: 0, y: 0, z: 0))

        measure {
            chunk.fillWithPattern()
        }
    }

    func testChunkBlockAccessPerformance() {
        let chunk = Chunk(position: ChunkPosition(x: 0, y: 0, z: 0))
        chunk.fillWithPattern()

        measure {
            for x in 0..<16 {
                for y in 0..<16 {
                    for z in 0..<16 {
                        let pos = BlockPosition(x: x, y: y, z: z)
                        _ = chunk.getBlock(at: pos)
                    }
                }
            }
        }
    }
}
