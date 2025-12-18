//
//  ImmersiveGameView.swift
//  Parkour Pathways
//
//  Main immersive gameplay view
//

import SwiftUI
import RealityKit
import ARKit

struct ImmersiveGameView: View {
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var gameStateManager: GameStateManager

    @State private var rootEntity: Entity?
    @State private var gameLoop: GameLoop?

    var body: some View {
        RealityView { content in
            // Setup game world
            let root = await setupGameWorld()
            content.add(root)
            rootEntity = root

            // Initialize game loop
            let loop = GameLoop(rootEntity: root, gameState: gameStateManager)
            gameLoop = loop
            loop.start()

        } update: { content in
            // Update game world each frame
            gameLoop?.update()
        }
        .upperLimbVisibility(.hidden)
        .onDisappear {
            gameLoop?.stop()
            cleanup()
        }
    }

    // MARK: - Setup

    @MainActor
    private func setupGameWorld() async -> Entity {
        let root = Entity()
        root.name = "GameRoot"

        // Add environment
        let environment = await createEnvironment()
        root.addChild(environment)

        // Add course if selected
        if let course = appCoordinator.selectedCourse {
            let courseEntity = await createCourse(course)
            root.addChild(courseEntity)
        }

        // Add player entity
        let player = createPlayerEntity()
        root.addChild(player)

        // Add UI entities
        let uiRoot = createUIEntities()
        root.addChild(uiRoot)

        // Add audio controller
        let audio = createAudioController()
        root.addChild(audio)

        return root
    }

    @MainActor
    private func createEnvironment() async -> Entity {
        let env = Entity()
        env.name = "Environment"

        // Add room mesh (from ARKit scanning)
        if let roomMesh = await appCoordinator.spatialMappingSystem.getRoomMesh() {
            env.addChild(roomMesh)
        }

        // Add safety boundaries
        let boundaries = createSafetyBoundaries()
        env.addChild(boundaries)

        // Add lighting
        let lighting = createLighting()
        env.addChild(lighting)

        return env
    }

    @MainActor
    private func createCourse(_ course: CourseData) async -> Entity {
        let courseEntity = Entity()
        courseEntity.name = "Course"

        // Create obstacles
        for obstacle in course.obstacles {
            let obstacleEntity = createObstacleEntity(obstacle)
            courseEntity.addChild(obstacleEntity)
        }

        // Create checkpoints
        for checkpoint in course.checkpoints {
            let checkpointEntity = createCheckpointEntity(checkpoint)
            courseEntity.addChild(checkpointEntity)
        }

        // Add path visualization
        let pathViz = createPathVisualization(course)
        courseEntity.addChild(pathViz)

        return courseEntity
    }

    private func createObstacleEntity(_ obstacle: Obstacle) -> Entity {
        let entity = Entity()
        entity.name = "Obstacle_\(obstacle.type.rawValue)"
        entity.position = obstacle.position
        entity.orientation = obstacle.rotation

        // Add visual model
        let model = createObstacleModel(obstacle.type, scale: obstacle.scale)
        entity.components.set(model)

        // Add components
        entity.components.set(ObstacleComponent(
            type: obstacle.type,
            difficulty: obstacle.difficulty,
            isActive: true
        ))

        entity.components.set(CollisionComponent(
            collisionGroup: .obstacle,
            collidesWith: [.player]
        ))

        entity.components.set(HighlightComponent())

        // Add physics
        let shape = createObstaclePhysicsShape(obstacle.type, scale: obstacle.scale)
        entity.components.set(PhysicsBodyComponent(
            shapes: [shape],
            mass: 0, // Static
            mode: .static
        ))

        return entity
    }

    private func createObstacleModel(_ type: ObstacleType, scale: SIMD3<Float>) -> ModelComponent {
        // Create appropriate 3D model for obstacle type
        var mesh: MeshResource

        switch type {
        case .precisionTarget:
            mesh = .generateSphere(radius: scale.x / 2)
        case .vaultBox, .stepVault, .speedVault, .kongVault:
            mesh = .generateBox(size: scale)
        case .balanceBeam:
            mesh = .generateCylinder(height: scale.y, radius: 0.1)
        case .virtualWall, .wallRun:
            mesh = .generateBox(width: scale.x, height: scale.y, depth: 0.1)
        default:
            mesh = .generateBox(size: scale)
        }

        // Create material
        var material = UnlitMaterial()
        material.color = .init(tint: .cyan, texture: nil)

        return ModelComponent(mesh: mesh, materials: [material])
    }

    private func createObstaclePhysicsShape(_ type: ObstacleType, scale: SIMD3<Float>) -> ShapeResource {
        switch type {
        case .precisionTarget:
            return .generateSphere(radius: scale.x / 2)
        case .balanceBeam:
            return .generateCapsule(height: scale.y, radius: 0.1)
        default:
            return .generateBox(size: scale)
        }
    }

    private func createCheckpointEntity(_ checkpoint: Checkpoint) -> Entity {
        let entity = Entity()
        entity.name = "Checkpoint_\(checkpoint.order)"
        entity.position = checkpoint.position

        // Visual model
        let mesh = MeshResource.generateCylinder(height: 2.0, radius: 0.3)
        var material = UnlitMaterial()
        material.color = .init(tint: .green.withAlphaComponent(0.3), texture: nil)

        entity.components.set(ModelComponent(mesh: mesh, materials: [material]))

        // Checkpoint component
        entity.components.set(CheckpointComponent(
            order: checkpoint.order,
            requiredObstacles: checkpoint.requiredObstacles
        ))

        // Particle effect
        entity.components.set(ParticleEffectComponent(
            effectType: .checkpoint,
            isActive: true
        ))

        return entity
    }

    private func createPathVisualization(_ course: CourseData) -> Entity {
        let entity = Entity()
        entity.name = "PathVisualization"

        // Create line renderer showing path between obstacles
        // This would use custom geometry or multiple small entities

        return entity
    }

    private func createPlayerEntity() -> Entity {
        let player = Entity()
        player.name = "Player"

        // Add tracking components
        player.components.set(MovementTrackingComponent(
            trackedJoints: [.head, .leftHand, .rightHand, .torso],
            movementHistory: []
        ))

        player.components.set(SafetyComponent())
        player.components.set(ScoreComponent())
        player.components.set(TechniqueFeedbackComponent())

        return player
    }

    private func createUIEntities() -> Entity {
        let uiRoot = Entity()
        uiRoot.name = "UI"

        // HUD elements would be added here
        // Timer, score, feedback, etc.

        return uiRoot
    }

    private func createAudioController() -> Entity {
        let audio = Entity()
        audio.name = "AudioController"

        // Audio sources would be set up here

        return audio
    }

    private func createSafetyBoundaries() -> Entity {
        let boundaries = Entity()
        boundaries.name = "SafetyBoundaries"

        // Create visual boundary indicators
        // This would show the safe play area

        return boundaries
    }

    private func createLighting() -> Entity {
        let lighting = Entity()
        lighting.name = "Lighting"

        // Add point lights for scene illumination
        let light = PointLight()
        light.light.intensity = 1000
        light.light.color = .white

        lighting.components.set(light)
        lighting.position = [0, 2, 0]

        return lighting
    }

    // MARK: - Cleanup

    private func cleanup() {
        gameLoop?.stop()
        gameLoop = nil
        rootEntity = nil
    }
}

// MARK: - Game Loop

@MainActor
class GameLoop {
    private let rootEntity: Entity
    private let gameState: GameStateManager
    private var displayLink: CADisplayLink?
    private let targetFrameTime: TimeInterval = 1.0 / 90.0

    // Systems
    private var systems: [any System] = []

    init(rootEntity: Entity, gameState: GameStateManager) {
        self.rootEntity = rootEntity
        self.gameState = gameState

        setupSystems()
    }

    private func setupSystems() {
        // Register game systems
        // These would be instantiated with the scene
    }

    func start() {
        // Start game loop
    }

    func stop() {
        displayLink?.invalidate()
        displayLink = nil
    }

    func update() {
        let deltaTime = targetFrameTime

        // Update all systems
        for system in systems {
            // system.update would be called here
        }
    }
}
