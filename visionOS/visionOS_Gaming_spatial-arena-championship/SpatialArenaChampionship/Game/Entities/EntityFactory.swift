//
//  EntityFactory.swift
//  Spatial Arena Championship
//
//  Factory for creating game entities
//

import Foundation
import RealityKit
import simd

// MARK: - Entity Factory

class EntityFactory {

    // MARK: - Player Entity

    static func createPlayer(
        id: UUID,
        username: String,
        position: SIMD3<Float>,
        team: TeamColor,
        isLocalPlayer: Bool = false
    ) -> Entity {
        let entity = Entity()
        entity.name = "Player_\(username)"
        entity.position = position

        // Visual representation
        let mesh = MeshResource.generateBox(
            size: [0.5, 1.8, 0.3],
            cornerRadius: 0.05
        )
        let material = SimpleMaterial(
            color: teamColor(team),
            isMetallic: false
        )
        entity.components[ModelComponent.self] = ModelComponent(
            mesh: mesh,
            materials: [material]
        )

        // Physics
        let shape = ShapeResource.generateBox(size: [0.5, 1.8, 0.3])
        entity.components[CollisionComponent.self] = CollisionComponent(
            shapes: [shape],
            mode: .trigger,
            filter: .init(
                group: .init(rawValue: 1 << 0), // Player layer
                mask: .all
            )
        )

        // Custom components
        entity.components[PlayerComponent.self] = PlayerComponent(
            playerID: id,
            username: username,
            team: team,
            isLocalPlayer: isLocalPlayer
        )
        entity.components[HealthComponent.self] = HealthComponent()
        entity.components[EnergyComponent.self] = EnergyComponent()
        entity.components[VelocityComponent.self] = VelocityComponent()

        return entity
    }

    // MARK: - Projectile Entity

    static func createProjectile(
        owner: UUID,
        position: SIMD3<Float>,
        direction: SIMD3<Float>,
        team: TeamColor,
        config: ProjectileConfig
    ) -> Entity {
        let entity = Entity()
        entity.name = "Projectile"
        entity.position = position

        // Visual
        let mesh = MeshResource.generateSphere(radius: config.radius)
        let color = teamColor(team).withAlphaComponent(0.8)
        let material = SimpleMaterial(color: color, isMetallic: true)
        entity.components[ModelComponent.self] = ModelComponent(
            mesh: mesh,
            materials: [material]
        )

        // Particle trail
        var particles = ParticleEmitterComponent()
        particles.emitterShape = .sphere
        particles.birthRate = 100
        particles.lifeSpan = 0.5
        particles.speed = 0.1
        entity.components[ParticleEmitterComponent.self] = particles

        // Physics
        let shape = ShapeResource.generateSphere(radius: config.radius)
        entity.components[CollisionComponent.self] = CollisionComponent(
            shapes: [shape],
            mode: .trigger,
            filter: .init(
                group: .init(rawValue: 1 << 1), // Projectile layer
                mask: .all
            )
        )

        // Custom components
        entity.components[ProjectileComponent.self] = ProjectileComponent(
            damage: config.damage,
            speed: config.speed,
            lifetime: config.lifetime,
            ownerID: owner,
            team: team
        )

        let velocity = normalize(direction) * config.speed
        entity.components[VelocityComponent.self] = VelocityComponent(
            linear: velocity,
            maxSpeed: config.speed
        )

        return entity
    }

    // MARK: - Shield Wall Entity

    static func createShield(
        owner: UUID,
        position: SIMD3<Float>,
        orientation: simd_quatf,
        team: TeamColor,
        config: ShieldConfig
    ) -> Entity {
        let entity = Entity()
        entity.name = "Shield"
        entity.position = position
        entity.orientation = orientation

        // Visual
        let mesh = MeshResource.generateBox(
            size: config.size,
            cornerRadius: 0.05
        )
        let color = teamColor(team).withAlphaComponent(0.6)
        let material = SimpleMaterial(color: color, isMetallic: false)
        entity.components[ModelComponent.self] = ModelComponent(
            mesh: mesh,
            materials: [material]
        )

        // Glowing effect
        var emissiveMaterial = UnlitMaterial()
        emissiveMaterial.color = .init(tint: color)
        entity.components[ModelComponent.self] = ModelComponent(
            mesh: mesh,
            materials: [emissiveMaterial]
        )

        // Physics (blocks projectiles)
        let shape = ShapeResource.generateBox(size: config.size)
        entity.components[CollisionComponent.self] = CollisionComponent(
            shapes: [shape],
            mode: .default,
            filter: .init(
                group: .init(rawValue: 1 << 2), // Shield layer
                mask: .init(rawValue: 1 << 1) // Only blocks projectiles
            )
        )

        // Custom component
        entity.components[ShieldComponent.self] = ShieldComponent(
            durability: config.durability,
            size: config.size,
            duration: config.duration,
            ownerID: owner,
            team: team
        )

        return entity
    }

    // MARK: - Capture Zone Entity

    static func createCaptureZone(
        position: SIMD3<Float>,
        radius: Float = 1.5
    ) -> Entity {
        let entity = Entity()
        entity.name = "CaptureZone"
        entity.position = position

        // Visual indicator (ring on ground)
        let mesh = MeshResource.generateCylinder(
            height: 0.1,
            radius: radius
        )
        let material = SimpleMaterial(
            color: .init(white: 1.0, alpha: 0.3),
            isMetallic: false
        )
        entity.components[ModelComponent.self] = ModelComponent(
            mesh: mesh,
            materials: [material]
        )

        // Trigger volume
        let shape = ShapeResource.generateCylinder(height: 2.0, radius: radius)
        entity.components[CollisionComponent.self] = CollisionComponent(
            shapes: [shape],
            mode: .trigger,
            filter: .init(
                group: .init(rawValue: 1 << 3), // Objective layer
                mask: .init(rawValue: 1 << 0) // Only players
            )
        )

        // Territory component
        entity.components[TerritoryComponent.self] = TerritoryComponent(radius: radius)

        return entity
    }

    // MARK: - Power-Up Entity

    static func createPowerUp(
        type: PowerUpSpawn.PowerUpType,
        position: SIMD3<Float>
    ) -> Entity {
        let entity = Entity()
        entity.name = "PowerUp_\(type.rawValue)"
        entity.position = position

        // Visual
        let mesh = MeshResource.generateBox(size: [0.3, 0.3, 0.3], cornerRadius: 0.05)
        let color = powerUpColor(type)
        let material = SimpleMaterial(color: color, isMetallic: true)
        entity.components[ModelComponent.self] = ModelComponent(
            mesh: mesh,
            materials: [material]
        )

        // Rotation animation
        entity.components[RotationComponent.self] = RotationComponent(
            speed: 1.0,
            axis: [0, 1, 0]
        )

        // Trigger volume
        let shape = ShapeResource.generateSphere(radius: 0.5)
        entity.components[CollisionComponent.self] = CollisionComponent(
            shapes: [shape],
            mode: .trigger,
            filter: .init(
                group: .init(rawValue: 1 << 4), // PowerUp layer
                mask: .init(rawValue: 1 << 0) // Only players
            )
        )

        return entity
    }

    // MARK: - Explosion Effect

    static func createExplosion(
        at position: SIMD3<Float>,
        radius: Float,
        damage: Float,
        team: TeamColor
    ) -> Entity {
        let entity = Entity()
        entity.name = "Explosion"
        entity.position = position

        // Particle explosion
        var particles = ParticleEmitterComponent()
        particles.emitterShape = .sphere
        particles.birthRate = 1000
        particles.lifeSpan = 1.0
        particles.speed = 5.0
        particles.birthLocation = .surface
        entity.components[ParticleEmitterComponent.self] = particles

        // Sphere for visual
        let mesh = MeshResource.generateSphere(radius: radius)
        let color = teamColor(team).withAlphaComponent(0.5)
        var material = UnlitMaterial()
        material.color = .init(tint: color)
        entity.components[ModelComponent.self] = ModelComponent(
            mesh: mesh,
            materials: [material]
        )

        // Auto-destroy after 1 second
        entity.components[LifetimeComponent.self] = LifetimeComponent(lifetime: 1.0)

        return entity
    }

    // MARK: - Arena Boundary

    static func createArenaBoundary(dimensions: SIMD3<Float>) -> Entity {
        let entity = Entity()
        entity.name = "ArenaBoundary"

        // Create walls (invisible collision)
        let thickness: Float = 0.1

        // Floor
        let floorShape = ShapeResource.generateBox(
            size: [dimensions.x, thickness, dimensions.z]
        )
        let floor = Entity()
        floor.position = [0, -thickness / 2, 0]
        floor.components[CollisionComponent.self] = CollisionComponent(
            shapes: [floorShape],
            mode: .default
        )
        entity.addChild(floor)

        // Walls (4 sides)
        createWall(parent: entity, dimensions: dimensions, side: .front)
        createWall(parent: entity, dimensions: dimensions, side: .back)
        createWall(parent: entity, dimensions: dimensions, side: .left)
        createWall(parent: entity, dimensions: dimensions, side: .right)

        return entity
    }

    private static func createWall(
        parent: Entity,
        dimensions: SIMD3<Float>,
        side: WallSide
    ) {
        let thickness: Float = 0.1
        let wall = Entity()

        let shape: ShapeResource
        let position: SIMD3<Float>

        switch side {
        case .front:
            shape = ShapeResource.generateBox(size: [dimensions.x, dimensions.y, thickness])
            position = [0, dimensions.y / 2, dimensions.z / 2]
        case .back:
            shape = ShapeResource.generateBox(size: [dimensions.x, dimensions.y, thickness])
            position = [0, dimensions.y / 2, -dimensions.z / 2]
        case .left:
            shape = ShapeResource.generateBox(size: [thickness, dimensions.y, dimensions.z])
            position = [-dimensions.x / 2, dimensions.y / 2, 0]
        case .right:
            shape = ShapeResource.generateBox(size: [thickness, dimensions.y, dimensions.z])
            position = [dimensions.x / 2, dimensions.y / 2, 0]
        }

        wall.position = position
        wall.components[CollisionComponent.self] = CollisionComponent(
            shapes: [shape],
            mode: .default
        )

        parent.addChild(wall)
    }

    // MARK: - Helper Methods

    private static func teamColor(_ team: TeamColor) -> UIColor {
        switch team {
        case .blue:
            return UIColor(red: 0, green: 0.75, blue: 1.0, alpha: 1.0)
        case .red:
            return UIColor(red: 1.0, green: 0.27, blue: 0.27, alpha: 1.0)
        case .neutral:
            return UIColor(red: 1.0, green: 0.67, blue: 0, alpha: 1.0)
        }
    }

    private static func powerUpColor(_ type: PowerUpSpawn.PowerUpType) -> UIColor {
        switch type {
        case .health:
            return UIColor(red: 0, green: 1.0, blue: 0.53, alpha: 1.0)
        case .shield:
            return UIColor(red: 0, green: 0.75, blue: 1.0, alpha: 1.0)
        case .damage:
            return UIColor(red: 1.0, green: 0.27, blue: 0.27, alpha: 1.0)
        case .speed:
            return UIColor(red: 1.0, green: 0.67, blue: 0, alpha: 1.0)
        case .ultimateCharge:
            return UIColor(red: 0.67, green: 0, blue: 1.0, alpha: 1.0)
        }
    }

    private enum WallSide {
        case front, back, left, right
    }
}

// MARK: - Rotation Component (for animation)

struct RotationComponent: Component, Codable {
    var speed: Float
    var axis: SIMD3<Float>

    init(speed: Float = 1.0, axis: SIMD3<Float> = [0, 1, 0]) {
        self.speed = speed
        self.axis = normalize(axis)
    }
}
