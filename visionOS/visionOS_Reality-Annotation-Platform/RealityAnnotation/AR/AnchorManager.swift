//
//  AnchorManager.swift
//  Reality Annotation Platform
//
//  Manages spatial anchors for annotations
//

import Foundation
import RealityKit

@MainActor
class AnchorManager {
    // Anchor storage
    private var anchors: [UUID: AnchorEntity] = [:]

    // Configuration
    private let maxAnchorDistance: Float = 2.0 // Reuse anchors within 2 meters

    // MARK: - Anchor Operations

    /// Get or create an anchor for the given position
    func anchorFor(position: SIMD3<Float>) async throws -> UUID {
        // Try to find existing anchor nearby
        if let existingID = nearestAnchor(to: position, maxDistance: maxAnchorDistance) {
            print("♻️ Reusing existing anchor: \(existingID)")
            return existingID
        }

        // Create new anchor
        print("✨ Creating new anchor at \(position)")
        return try await createAnchor(at: position)
    }

    /// Create a new anchor at the specified position
    func createAnchor(at position: SIMD3<Float>) async throws -> UUID {
        let id = UUID()

        // Create anchor entity
        let anchor = AnchorEntity()
        anchor.name = "annotation-anchor-\(id.uuidString)"

        // Set position
        anchor.position = position

        // Store anchor
        anchors[id] = anchor

        print("✅ Created anchor: \(id) at \(position)")
        return id
    }

    /// Get anchor entity by ID
    func getAnchor(_ id: UUID) -> AnchorEntity? {
        return anchors[id]
    }

    /// Remove anchor by ID
    func removeAnchor(_ id: UUID) {
        if let anchor = anchors[id] {
            anchor.removeFromParent()
            anchors.removeValue(forKey: id)
            print("🗑️ Removed anchor: \(id)")
        }
    }

    /// Find nearest anchor to position within max distance
    func nearestAnchor(to position: SIMD3<Float>, maxDistance: Float) -> UUID? {
        var nearest: (id: UUID, distance: Float)?

        for (id, anchor) in anchors {
            let anchorPos = anchor.position
            let distance = simd_distance(position, anchorPos)

            if distance <= maxDistance {
                if nearest == nil || distance < nearest!.distance {
                    nearest = (id, distance)
                }
            }
        }

        return nearest?.id
    }

    /// Get all anchor IDs
    func getAllAnchorIDs() -> [UUID] {
        return Array(anchors.keys)
    }

    /// Get anchor count
    func anchorCount() -> Int {
        return anchors.count
    }

    /// Clear all anchors
    func clearAllAnchors() {
        for (_, anchor) in anchors {
            anchor.removeFromParent()
        }
        anchors.removeAll()
        print("🧹 Cleared all anchors")
    }

    // MARK: - Anchor Persistence

    /// Save anchor data for persistence
    func saveAnchorData() -> [AnchorData] {
        return anchors.map { id, anchor in
            AnchorData(
                id: id,
                position: anchor.position,
                orientation: anchor.orientation
            )
        }
    }

    /// Load anchor data from persistence
    func loadAnchorData(_ data: [AnchorData]) async {
        clearAllAnchors()

        for anchorData in data {
            let anchor = AnchorEntity()
            anchor.name = "annotation-anchor-\(anchorData.id.uuidString)"
            anchor.position = anchorData.position
            anchor.orientation = anchorData.orientation

            anchors[anchorData.id] = anchor
        }

        print("✅ Loaded \(data.count) anchors from persistence")
    }

    // MARK: - Debug

    func printAnchorInfo() {
        print("📍 Anchor Manager Status:")
        print("  Total anchors: \(anchors.count)")
        print("  Max reuse distance: \(maxAnchorDistance)m")

        for (id, anchor) in anchors {
            print("  - \(id): position=\(anchor.position)")
        }
    }
}

// MARK: - Anchor Data

struct AnchorData: Codable {
    let id: UUID
    let position: SIMD3<Float>
    let orientation: simd_quatf

    enum CodingKeys: String, CodingKey {
        case id
        case positionX, positionY, positionZ
        case orientationW, orientationX, orientationY, orientationZ
    }

    init(id: UUID, position: SIMD3<Float>, orientation: simd_quatf) {
        self.id = id
        self.position = position
        self.orientation = orientation
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)

        let x = try container.decode(Float.self, forKey: .positionX)
        let y = try container.decode(Float.self, forKey: .positionY)
        let z = try container.decode(Float.self, forKey: .positionZ)
        position = SIMD3(x, y, z)

        let w = try container.decode(Float.self, forKey: .orientationW)
        let qx = try container.decode(Float.self, forKey: .orientationX)
        let qy = try container.decode(Float.self, forKey: .orientationY)
        let qz = try container.decode(Float.self, forKey: .orientationZ)
        orientation = simd_quatf(ix: qx, iy: qy, iz: qz, r: w)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(position.x, forKey: .positionX)
        try container.encode(position.y, forKey: .positionY)
        try container.encode(position.z, forKey: .positionZ)
        try container.encode(orientation.vector.w, forKey: .orientationW)
        try container.encode(orientation.vector.x, forKey: .orientationX)
        try container.encode(orientation.vector.y, forKey: .orientationY)
        try container.encode(orientation.vector.z, forKey: .orientationZ)
    }
}
