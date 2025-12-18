import Foundation
import simd

/// Component representing position, rotation, and scale in 3D space
public struct TransformComponent: Component {
    public let entityID: UUID
    public var position: SIMD3<Float>
    public var rotation: simd_quatf
    public var scale: SIMD3<Float>

    public init(
        entityID: UUID,
        position: SIMD3<Float> = .zero,
        rotation: simd_quatf = simd_quatf(angle: 0, axis: SIMD3(0, 1, 0)),
        scale: SIMD3<Float> = SIMD3(repeating: 1)
    ) {
        self.entityID = entityID
        self.position = position
        self.rotation = rotation
        self.scale = scale
    }

    /// Get the forward direction vector
    public var forward: SIMD3<Float> {
        return rotation.act(SIMD3(0, 0, -1))
    }

    /// Get the right direction vector
    public var right: SIMD3<Float> {
        return rotation.act(SIMD3(1, 0, 0))
    }

    /// Get the up direction vector
    public var up: SIMD3<Float> {
        return rotation.act(SIMD3(0, 1, 0))
    }
}
