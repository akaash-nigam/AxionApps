//
//  MovementSystem.swift
//  Spatial Arena Championship
//
//  System for handling player and entity movement
//

import Foundation
import RealityKit
import simd

// MARK: - Movement System

@MainActor
class MovementSystem {
    private weak var scene: Scene?
    private var arenaBounds: SIMD3<Float>

    init(scene: Scene?, arenaBounds: SIMD3<Float>) {
        self.scene = scene
        self.arenaBounds = arenaBounds
    }

    // MARK: - Update

    func update(deltaTime: TimeInterval) {
        guard let scene = scene else { return }

        // Update all entities with velocity
        for entity in scene.entities {
            updateEntity(entity, deltaTime: deltaTime)
        }
    }

    private func updateEntity(_ entity: Entity, deltaTime: TimeInterval) {
        guard var velocity = entity.components[VelocityComponent.self],
              var transform = entity.components[Transform.self] else {
            return
        }

        // Apply velocity to position
        let displacement = velocity.linear * Float(deltaTime)
        transform.translation += displacement

        // Clamp to arena bounds
        transform.translation = clampToArena(transform.translation)

        // Apply friction if on ground
        if transform.translation.y <= 0.1 {
            velocity.applyFriction(deltaTime: Float(deltaTime))
        }

        // Apply angular velocity (rotation)
        if simd_length(velocity.angular) > 0.001 {
            let angle = simd_length(velocity.angular) * Float(deltaTime)
            let axis = normalize(velocity.angular)
            let rotation = simd_quatf(angle: angle, axis: axis)
            transform.rotation = transform.rotation * rotation
        }

        // Update entity
        entity.components[Transform.self] = transform
        entity.components[VelocityComponent.self] = velocity

        // Recursively update children
        for child in entity.children {
            updateEntity(child, deltaTime: deltaTime)
        }
    }

    // MARK: - Movement Control

    func movePlayer(
        _ entity: Entity,
        direction: SIMD3<Float>,
        isSprinting: Bool = false,
        deltaTime: TimeInterval
    ) {
        guard var velocity = entity.components[VelocityComponent.self] else { return }

        let targetSpeed = isSprinting ?
            GameConstants.Movement.sprintSpeed :
            GameConstants.Movement.walkSpeed

        let targetVelocity = normalize(direction) * targetSpeed

        // Smooth acceleration
        let acceleration = GameConstants.Movement.acceleration
        let velocityChange = targetVelocity - velocity.linear
        let accelerationAmount = min(
            simd_length(velocityChange),
            acceleration * Float(deltaTime)
        )

        if simd_length(velocityChange) > 0.001 {
            velocity.linear += normalize(velocityChange) * accelerationAmount
        } else {
            velocity.linear = targetVelocity
        }

        velocity.maxSpeed = targetSpeed
        velocity.clampSpeed()

        entity.components[VelocityComponent.self] = velocity
    }

    func stopPlayer(_ entity: Entity, deltaTime: TimeInterval) {
        guard var velocity = entity.components[VelocityComponent.self] else { return }

        // Apply deceleration
        let deceleration = GameConstants.Movement.deceleration
        let currentSpeed = velocity.speed

        if currentSpeed > 0.001 {
            let decelerationAmount = min(currentSpeed, deceleration * Float(deltaTime))
            velocity.linear -= normalize(velocity.linear) * decelerationAmount
        } else {
            velocity.linear = .zero
        }

        entity.components[VelocityComponent.self] = velocity
    }

    func dash(
        _ entity: Entity,
        direction: SIMD3<Float>
    ) {
        guard var velocity = entity.components[VelocityComponent.self],
              let energyComponent = entity.components[EnergyComponent.self],
              energyComponent.current >= GameConstants.Abilities.Dash.energyCost else {
            return
        }

        // Apply dash velocity
        let dashVelocity = normalize(direction) * GameConstants.Movement.dodgeSpeed
        velocity.linear = dashVelocity
        velocity.maxSpeed = GameConstants.Movement.dodgeSpeed

        entity.components[VelocityComponent.self] = velocity

        // Deduct energy
        var energy = energyComponent
        _ = energy.use(GameConstants.Abilities.Dash.energyCost)
        entity.components[EnergyComponent.self] = energy
    }

    // MARK: - Utility

    private func clampToArena(_ position: SIMD3<Float>) -> SIMD3<Float> {
        var clamped = position

        // Clamp X
        let halfWidth = arenaBounds.x / 2 - GameConstants.Arena.safetyBoundaryPadding
        clamped.x = max(-halfWidth, min(halfWidth, position.x))

        // Clamp Y (keep above ground)
        clamped.y = max(0, min(arenaBounds.y - 0.5, position.y))

        // Clamp Z
        let halfDepth = arenaBounds.z / 2 - GameConstants.Arena.safetyBoundaryPadding
        clamped.z = max(-halfDepth, min(halfDepth, position.z))

        return clamped
    }

    func isWithinBounds(_ position: SIMD3<Float>) -> Bool {
        let halfWidth = arenaBounds.x / 2 - GameConstants.Arena.safetyBoundaryPadding
        let halfDepth = arenaBounds.z / 2 - GameConstants.Arena.safetyBoundaryPadding

        return abs(position.x) <= halfWidth &&
               position.y >= 0 &&
               position.y <= arenaBounds.y &&
               abs(position.z) <= halfDepth
    }

    // MARK: - Rotation

    func rotateTowards(
        _ entity: Entity,
        target: SIMD3<Float>,
        deltaTime: TimeInterval,
        speed: Float = 5.0
    ) {
        guard var transform = entity.components[Transform.self] else { return }

        let direction = normalize(target - transform.translation)
        let targetRotation = simd_quatf(from: [0, 0, 1], to: direction)

        // Slerp for smooth rotation
        let t = min(1.0, Float(deltaTime) * speed)
        transform.rotation = simd_slerp(transform.rotation, targetRotation, t)

        entity.components[Transform.self] = transform
    }
}
