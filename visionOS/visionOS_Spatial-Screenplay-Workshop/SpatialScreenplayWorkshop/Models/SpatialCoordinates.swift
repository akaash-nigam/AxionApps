//
//  SpatialCoordinates.swift
//  SpatialScreenplayWorkshop
//
//  Created on 2025-11-24
//

import Foundation
import simd

/// 3D position and rotation in space
struct SpatialCoordinates: Codable, Hashable {
    var x: Float
    var y: Float
    var z: Float
    var rotation: Float  // Rotation around Y axis in radians

    init(x: Float = 0, y: Float = 0, z: Float = 0, rotation: Float = 0) {
        self.x = x
        self.y = y
        self.z = z
        self.rotation = rotation
    }

    /// Create from SIMD3 position
    init(position: SIMD3<Float>, rotation: Float = 0) {
        self.x = position.x
        self.y = position.y
        self.z = position.z
        self.rotation = rotation
    }

    /// Convert to SIMD3 for RealityKit
    var simd: SIMD3<Float> {
        SIMD3(x: x, y: y, z: z)
    }

    /// Distance from origin
    var magnitude: Float {
        sqrt(x * x + y * y + z * z)
    }

    /// Distance to another coordinate
    func distance(to other: SpatialCoordinates) -> Float {
        let dx = x - other.x
        let dy = y - other.y
        let dz = z - other.z
        return sqrt(dx * dx + dy * dy + dz * dz)
    }

    /// Default positions for common scenarios
    static let origin = SpatialCoordinates(x: 0, y: 0, z: 0)
    static let defaultCardPosition = SpatialCoordinates(x: 0, y: 1.4, z: -2.0)
    static let defaultCharacterPosition = SpatialCoordinates(x: 0, y: 0, z: -1.5)
}

/// Scene position in timeline
struct ScenePosition: Codable, Hashable {
    var act: Int
    var sequence: Int?
    var spatialPosition: SpatialCoordinates?

    init(act: Int, sequence: Int? = nil, spatialPosition: SpatialCoordinates? = nil) {
        self.act = act
        self.sequence = sequence
        self.spatialPosition = spatialPosition
    }

    /// Act display name
    var actName: String {
        switch act {
        case 1: return "Act I"
        case 2: return "Act II"
        case 3: return "Act III"
        default: return "Act \(act)"
        }
    }
}
