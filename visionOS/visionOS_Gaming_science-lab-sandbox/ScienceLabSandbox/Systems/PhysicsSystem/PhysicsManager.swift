//
//  PhysicsManager.swift
//  Science Lab Sandbox
//
//  Manages physics simulation and calculations
//

import Foundation
import RealityKit

@MainActor
class PhysicsManager: ObservableObject {

    // MARK: - Constants

    static let gravity = SIMD3<Float>(0, -9.81, 0)  // m/s²
    static let airDensity: Float = 1.225  // kg/m³
    static let timeStep: TimeInterval = 1.0 / 90.0  // 90 Hz

    // MARK: - Private Properties

    private var physicsObjects: [UUID: PhysicsObject] = [:]

    // MARK: - Physics Simulation

    func update(deltaTime: TimeInterval) {
        // Update all physics objects
        for (id, var object) in physicsObjects {
            updatePhysicsObject(&object, deltaTime: deltaTime)
            physicsObjects[id] = object
        }
    }

    private func updatePhysicsObject(_ object: inout PhysicsObject, deltaTime: TimeInterval) {
        // Apply gravity
        var acceleration = Self.gravity

        // Apply drag force
        let speed = simd_length(object.velocity)
        if speed > 0 {
            let dragMagnitude = 0.5 * Self.airDensity * speed * speed * object.dragCoefficient * object.crossSectionalArea
            let dragDirection = -simd_normalize(object.velocity)
            let dragForce = dragDirection * dragMagnitude
            acceleration += dragForce / object.mass
        }

        // Update velocity and position
        object.velocity += acceleration * Float(deltaTime)
        object.position += object.velocity * Float(deltaTime)
    }

    // MARK: - Trajectory Calculation

    func calculateTrajectory(
        initialPosition: SIMD3<Float>,
        initialVelocity: SIMD3<Float>,
        mass: Float,
        dragCoefficient: Float,
        crossSectionalArea: Float,
        duration: TimeInterval
    ) -> [TrajectoryPoint] {
        var points: [TrajectoryPoint] = []
        var position = initialPosition
        var velocity = initialVelocity
        var time: TimeInterval = 0

        while time < duration {
            // Calculate drag force
            let speed = simd_length(velocity)
            let dragMagnitude = 0.5 * Self.airDensity * speed * speed * dragCoefficient * crossSectionalArea
            let dragDirection = speed > 0 ? -simd_normalize(velocity) : SIMD3<Float>.zero
            let dragForce = dragDirection * dragMagnitude

            // Calculate acceleration
            let acceleration = (dragForce / mass) + Self.gravity

            // Update velocity and position
            velocity += acceleration * Float(Self.timeStep)
            position += velocity * Float(Self.timeStep)

            points.append(TrajectoryPoint(
                position: position,
                velocity: velocity,
                time: time
            ))

            time += Self.timeStep

            // Stop if object hits ground
            if position.y <= 0 { break }
        }

        return points
    }

    // MARK: - Collision Detection

    func detectCollision(entityA: Entity, entityB: Entity) -> CollisionInfo? {
        // Simplified collision detection
        // In real implementation, use RealityKit's collision system

        let posA = entityA.position(relativeTo: nil)
        let posB = entityB.position(relativeTo: nil)

        let distance = simd_distance(posA, posB)
        let minDistance: Float = 0.1  // Minimum collision distance

        if distance < minDistance {
            let contactPoint = (posA + posB) / 2
            let contactNormal = simd_normalize(posA - posB)

            return CollisionInfo(
                entityA: entityA,
                entityB: entityB,
                contactPoint: contactPoint,
                contactNormal: contactNormal,
                penetrationDepth: minDistance - distance
            )
        }

        return nil
    }

    // MARK: - Force Application

    func applyForce(_ force: SIMD3<Float>, to objectID: UUID) {
        guard var object = physicsObjects[objectID] else { return }

        let acceleration = force / object.mass
        object.velocity += acceleration * Float(Self.timeStep)

        physicsObjects[objectID] = object
    }

    func applyImpulse(_ impulse: SIMD3<Float>, to objectID: UUID) {
        guard var object = physicsObjects[objectID] else { return }

        object.velocity += impulse / object.mass

        physicsObjects[objectID] = object
    }

    // MARK: - Object Management

    func registerPhysicsObject(_ object: PhysicsObject) {
        physicsObjects[object.id] = object
    }

    func unregisterPhysicsObject(_ id: UUID) {
        physicsObjects.removeValue(forKey: id)
    }

    func getPhysicsObject(_ id: UUID) -> PhysicsObject? {
        return physicsObjects[id]
    }
}

// MARK: - Physics Object

struct PhysicsObject: Identifiable {
    let id: UUID
    var mass: Float  // kg
    var velocity: SIMD3<Float>  // m/s
    var position: SIMD3<Float>  // m
    var restitution: Float  // 0-1 (bounciness)
    var friction: Float  // 0-1
    var dragCoefficient: Float
    var crossSectionalArea: Float  // m²

    init(
        id: UUID = UUID(),
        mass: Float,
        velocity: SIMD3<Float> = .zero,
        position: SIMD3<Float> = .zero,
        restitution: Float = 0.5,
        friction: Float = 0.5,
        dragCoefficient: Float = 0.47,
        crossSectionalArea: Float = 0.01
    ) {
        self.id = id
        self.mass = mass
        self.velocity = velocity
        self.position = position
        self.restitution = restitution
        self.friction = friction
        self.dragCoefficient = dragCoefficient
        self.crossSectionalArea = crossSectionalArea
    }
}

// MARK: - Trajectory Point

struct TrajectoryPoint {
    let position: SIMD3<Float>
    let velocity: SIMD3<Float>
    let time: TimeInterval
}

// MARK: - Collision Info

struct CollisionInfo {
    let entityA: Entity
    let entityB: Entity
    let contactPoint: SIMD3<Float>
    let contactNormal: SIMD3<Float>
    let penetrationDepth: Float
}
