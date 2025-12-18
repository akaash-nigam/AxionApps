//
//  PhysicsSystem.swift
//  Reality Minecraft
//
//  Physics and collision system
//

import Foundation
import simd

/// Physics system for the game
class PhysicsSystem {
    // Physics constants
    private let gravity: Float = -9.81
    private let terminalVelocity: Float = -78.4

    private var rigidBodies: [UUID: RigidBodyComponent] = [:]

    /// Update physics simulation
    func update(deltaTime: TimeInterval) {
        for (id, var body) in rigidBodies {
            body.integrate(deltaTime: Float(deltaTime), gravity: gravity)
            rigidBodies[id] = body
        }
    }

    /// Add a rigid body to the simulation
    func addRigidBody(id: UUID, component: RigidBodyComponent) {
        rigidBodies[id] = component
    }

    /// Remove a rigid body
    func removeRigidBody(id: UUID) {
        rigidBodies.removeValue(forKey: id)
    }

    /// Check collision between two AABB boxes
    func checkCollision(_ a: AABB, _ b: AABB) -> Bool {
        return a.intersects(b)
    }
}

// MARK: - Rigid Body Component

/// Rigid body physics component
struct RigidBodyComponent {
    var mass: Float
    var velocity: SIMD3<Float> = .zero
    var acceleration: SIMD3<Float> = .zero
    var isKinematic: Bool = false

    mutating func applyForce(_ force: SIMD3<Float>) {
        guard !isKinematic else { return }
        acceleration += force / mass
    }

    mutating func applyImpulse(_ impulse: SIMD3<Float>) {
        guard !isKinematic else { return }
        velocity += impulse / mass
    }

    mutating func integrate(deltaTime: Float, gravity: Float) {
        guard !isKinematic else { return }

        // Apply gravity
        applyForce(SIMD3<Float>(0, gravity * mass, 0))

        // Update velocity
        velocity += acceleration * deltaTime

        // Clamp to terminal velocity
        if velocity.y < -78.4 {
            velocity.y = -78.4
        }

        // Reset acceleration
        acceleration = .zero
    }
}

// MARK: - AABB (Axis-Aligned Bounding Box)

/// Axis-aligned bounding box for collision
struct AABB {
    var min: SIMD3<Float>
    var max: SIMD3<Float>

    var center: SIMD3<Float> {
        return (min + max) / 2
    }

    var extents: SIMD3<Float> {
        return (max - min) / 2
    }

    func intersects(_ other: AABB) -> Bool {
        return min.x <= other.max.x && max.x >= other.min.x &&
               min.y <= other.max.y && max.y >= other.min.y &&
               min.z <= other.max.z && max.z >= other.min.z
    }

    func contains(_ point: SIMD3<Float>) -> Bool {
        return point.x >= min.x && point.x <= max.x &&
               point.y >= min.y && point.y <= max.y &&
               point.z >= min.z && point.z <= max.z
    }
}
