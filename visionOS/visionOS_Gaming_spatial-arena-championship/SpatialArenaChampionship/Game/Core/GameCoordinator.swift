//
//  GameCoordinator.swift
//  Spatial Arena Championship
//
//  Main game coordinator managing all game systems
//

import Foundation
import RealityKit
import Observation

// MARK: - Game Coordinator

@Observable
@MainActor
class GameCoordinator {
    // MARK: - Managers & Systems
    private var movementSystem: MovementSystem?
    private var combatSystem: CombatSystem?
    var handTrackingManager: HandTrackingManager
    private var scene: Scene?

    // MARK: - Game State
    var currentMatch: Match?
    var localPlayer: Player?
    var gameState: GameState = .idle

    // MARK: - Performance
    private var lastUpdateTime: TimeInterval = 0
    private var accumulatedTime: TimeInterval = 0
    private let fixedTimestep: TimeInterval = GameConstants.Performance.targetFrameTime

    init() {
        self.handTrackingManager = HandTrackingManager()
    }

    // MARK: - Lifecycle

    func start(scene: Scene, arena: Arena) async throws {
        self.scene = scene

        // Initialize systems
        movementSystem = MovementSystem(scene: scene, arenaBounds: arena.dimensions)
        combatSystem = CombatSystem(scene: scene)

        // Start hand tracking
        try await handTrackingManager.start()

        // Create arena
        setupArena(arena)

        // Create local player
        if let localPlayerData = createLocalPlayer(in: arena) {
            self.localPlayer = localPlayerData.player
            scene.addAnchor(AnchorEntity(world: .zero))
            scene.anchors.first?.addChild(localPlayerData.entity)
        }

        gameState = .playing
        lastUpdateTime = Date().timeIntervalSince1970

        // Start update loop
        startUpdateLoop()
    }

    func stop() async {
        gameState = .idle
        await handTrackingManager.stop()
        scene = nil
    }

    // MARK: - Game Loop

    private func startUpdateLoop() {
        Task {
            while gameState == .playing {
                await update()
                try? await Task.sleep(for: .milliseconds(11)) // ~90 FPS
            }
        }
    }

    private func update() async {
        let currentTime = Date().timeIntervalSince1970
        let deltaTime = currentTime - lastUpdateTime
        lastUpdateTime = currentTime

        // Fixed timestep accumulator
        accumulatedTime += deltaTime

        while accumulatedTime >= fixedTimestep {
            fixedUpdate(fixedTimestep)
            accumulatedTime -= fixedTimestep
        }

        // Variable update for input and rendering
        variableUpdate(deltaTime)
    }

    private func fixedUpdate(_ deltaTime: TimeInterval) {
        // Physics and game logic
        movementSystem?.update(deltaTime: deltaTime)
        combatSystem?.update(deltaTime: deltaTime)
        updateEnergy(deltaTime: deltaTime)
    }

    private func variableUpdate(_ deltaTime: TimeInterval) {
        // Input processing
        processInput()

        // Update hand tracking
        Task {
            await handTrackingManager.update()
        }
    }

    // MARK: - Input Processing

    private func processInput() {
        guard let playerEntity = findLocalPlayerEntity(),
              let player = playerEntity.components[PlayerComponent.self] else {
            return
        }

        let input = handTrackingManager.currentInput

        // Movement (TODO: Get actual movement input from player position)
        // For now, we'll handle this when we integrate ARKit world tracking

        // Fire projectile
        if input.firePressed {
            combatSystem?.fireProjectile(
                from: playerEntity,
                direction: input.aimDirection,
                ability: Ability.primaryFire
            )
        }

        // Shield
        if input.shieldActive {
            combatSystem?.deployShield(
                from: playerEntity,
                forward: input.aimDirection,
                ability: Ability.shieldWall
            )
        }

        // Dash
        if input.dashPressed && simd_length(input.dashDirection) > 0.1 {
            movementSystem?.dash(playerEntity, direction: input.dashDirection)
        }

        // Ultimate
        if input.ultimatePressed {
            activateUltimate(playerEntity, player: player)
        }
    }

    // MARK: - Game Actions

    private func activateUltimate(_ entity: Entity, player: PlayerComponent) {
        guard var localPlayerData = self.localPlayer,
              localPlayerData.useUltimate() else {
            return
        }

        // TODO: Create nova blast effect
        // For now, just consume the charge
        self.localPlayer = localPlayerData
    }

    private func updateEnergy(deltaTime: TimeInterval) {
        guard let scene = scene else { return }

        for entity in scene.entities {
            updateEnergyForEntity(entity, deltaTime: deltaTime)
        }
    }

    private func updateEnergyForEntity(_ entity: Entity, deltaTime: TimeInterval) {
        guard var energy = entity.components[EnergyComponent.self] else {
            for child in entity.children {
                updateEnergyForEntity(child, deltaTime: deltaTime)
            }
            return
        }

        energy.regenerate(deltaTime: deltaTime)
        entity.components[EnergyComponent.self] = energy

        for child in entity.children {
            updateEnergyForEntity(child, deltaTime: deltaTime)
        }
    }

    // MARK: - Setup

    private func setupArena(_ arena: Arena) {
        guard let scene = scene else { return }

        // Create arena boundary
        let boundary = EntityFactory.createArenaBoundary(dimensions: arena.dimensions)
        scene.anchors.first?.addChild(boundary)

        // Create capture zones
        for zone in arena.objectiveZones {
            let captureZone = EntityFactory.createCaptureZone(
                position: zone.position,
                radius: zone.radius
            )
            scene.anchors.first?.addChild(captureZone)
        }

        // Create power-ups
        for powerUpSpawn in arena.powerUpSpawns {
            let powerUp = EntityFactory.createPowerUp(
                type: powerUpSpawn.powerUpType,
                position: powerUpSpawn.position
            )
            scene.anchors.first?.addChild(powerUp)
        }

        // Add lighting
        let light = DirectionalLight()
        light.light.intensity = 1000 * arena.lighting.directionalIntensity
        light.look(at: [0, 0, 0], from: [2, 3, 2], relativeTo: nil)
        scene.anchors.first?.addChild(light)
    }

    private func createLocalPlayer(in arena: Arena) -> (player: Player, entity: Entity)? {
        // Find blue team spawn
        guard let spawn = arena.spawnPoints.first(where: { $0.team == .blue }) else {
            return nil
        }

        let player = Player(
            username: "LocalPlayer",
            skillRating: 1500,
            team: .blue
        )

        let entity = EntityFactory.createPlayer(
            id: player.id,
            username: player.username,
            position: spawn.position,
            team: .blue,
            isLocalPlayer: true
        )

        return (player, entity)
    }

    // MARK: - Utilities

    private func findLocalPlayerEntity() -> Entity? {
        guard let scene = scene,
              let localPlayer = localPlayer else {
            return nil
        }

        return findEntityWithID(localPlayer.id, in: scene.entities)
    }

    private func findEntityWithID(_ id: UUID, in entities: [Entity]) -> Entity? {
        for entity in entities {
            if let player = entity.components[PlayerComponent.self],
               player.playerID == id {
                return entity
            }

            if let found = findEntityWithID(id, in: entity.children) {
                return found
            }
        }
        return nil
    }
}

// MARK: - Game State

enum GameState {
    case idle
    case loading
    case playing
    case paused
    case ended
}
