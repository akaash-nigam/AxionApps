//
//  WorldAnchorManager.swift
//  Reality Minecraft
//
//  Manages persistent world anchors for visionOS
//

import Foundation
import ARKit
import RealityKit
import simd

/// Manages world anchors for persistent block placement
@MainActor
class WorldAnchorManager: ObservableObject {
    @Published private(set) var worldAnchors: [UUID: WorldAnchor] = [:]
    @Published private(set) var anchorEntities: [UUID: AnchorEntity] = [:]

    private var arkitSession: ARKitSession?

    init() {
        setupARKitSession()
    }

    // MARK: - Setup

    private func setupARKitSession() {
        arkitSession = ARKitSession()
    }

    // MARK: - Anchor Creation

    /// Create a persistent world anchor at a specific transform
    func createPersistentAnchor(at transform: simd_float4x4) async throws -> UUID {
        let worldAnchor = WorldAnchor(originFromAnchorTransform: transform)

        // Persist the anchor for cross-session continuity
        do {
            try await worldAnchor.persist()
            print("✅ World anchor persisted successfully")
        } catch {
            print("❌ Failed to persist world anchor: \(error)")
            throw AnchorError.persistenceFailed
        }

        // Create RealityKit anchor entity
        let anchorEntity = AnchorEntity(world: transform)

        let id = UUID()
        worldAnchors[id] = worldAnchor
        anchorEntities[id] = anchorEntity

        print("🔗 Created world anchor: \(id)")
        return id
    }

    /// Create anchor at player's current position
    func createAnchorAtPlayer(playerPosition: SIMD3<Float>) async throws -> UUID {
        var transform = simd_float4x4(1.0)
        transform.columns.3 = SIMD4<Float>(playerPosition.x, playerPosition.y, playerPosition.z, 1.0)

        return try await createPersistentAnchor(at: transform)
    }

    // MARK: - Anchor Loading

    /// Load all persisted anchors from previous sessions
    func loadPersistedAnchors() async throws {
        print("🔄 Loading persisted anchors...")

        do {
            let persistedAnchors = try await WorldAnchor.loadPersisted()

            for anchor in persistedAnchors {
                let anchorEntity = AnchorEntity(world: anchor.originFromAnchorTransform)
                let id = UUID()

                worldAnchors[id] = anchor
                anchorEntities[id] = anchorEntity

                print("✅ Loaded persisted anchor: \(id)")
            }

            print("✅ Loaded \(persistedAnchors.count) anchors")
        } catch {
            print("❌ Failed to load persisted anchors: \(error)")
            throw AnchorError.loadFailed
        }
    }

    // MARK: - Anchor Access

    /// Get anchor entity for a given ID
    func getAnchorEntity(for id: UUID) -> AnchorEntity? {
        return anchorEntities[id]
    }

    /// Get world anchor for a given ID
    func getWorldAnchor(for id: UUID) -> WorldAnchor? {
        return worldAnchors[id]
    }

    /// Get all anchor IDs
    func getAllAnchorIDs() -> [UUID] {
        return Array(worldAnchors.keys)
    }

    // MARK: - Anchor Removal

    /// Remove a specific anchor
    func removeAnchor(_ id: UUID) {
        anchorEntities[id]?.removeFromParent()
        anchorEntities.removeValue(forKey: id)
        worldAnchors.removeValue(forKey: id)

        print("🗑 Removed anchor: \(id)")
    }

    /// Remove all anchors
    func removeAllAnchors() {
        for id in worldAnchors.keys {
            removeAnchor(id)
        }
    }

    // MARK: - Anchor Updates

    /// Update anchor transform
    func updateAnchor(_ id: UUID, transform: simd_float4x4) {
        guard let anchorEntity = anchorEntities[id] else { return }

        anchorEntity.transform.matrix = transform
    }
}

// MARK: - Anchor Errors

enum AnchorError: Error {
    case persistenceFailed
    case loadFailed
    case notFound
}
