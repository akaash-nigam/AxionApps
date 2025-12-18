import Foundation
import simd

/// Component for physics simulation
public struct PhysicsComponent: Component {
    public let entityID: UUID
    public var velocity: SIMD3<Float>
    public var acceleration: SIMD3<Float>
    public var mass: Float
    public var friction: Float
    public var hasGravity: Bool

    public init(
        entityID: UUID,
        velocity: SIMD3<Float> = .zero,
        acceleration: SIMD3<Float> = .zero,
        mass: Float = 1.0,
        friction: Float = 0.1,
        hasGravity: Bool = true
    ) {
        self.entityID = entityID
        self.velocity = velocity
        self.acceleration = acceleration
        self.mass = mass
        self.friction = friction
        self.hasGravity = hasGravity
    }
}

/// Component for collision detection
public struct CollisionComponent: Component {
    public let entityID: UUID
    public var radius: Float
    public var collisionLayer: UInt32
    public var collidesWith: UInt32

    public init(
        entityID: UUID,
        radius: Float = 0.5,
        collisionLayer: UInt32 = 1,
        collidesWith: UInt32 = 0xFFFFFFFF
    ) {
        self.entityID = entityID
        self.radius = radius
        self.collisionLayer = collisionLayer
        self.collidesWith = collidesWith
    }
}
