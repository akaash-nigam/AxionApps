//
//  ObjectiveSystem.swift
//  Spatial Arena Championship
//
//  Objective management for capture zones, artifacts, power-ups
//

import Foundation
import RealityKit
import simd

// MARK: - Objective System

@MainActor
class ObjectiveSystem {
    private weak var scene: Scene?
    private var onObjectiveCaptured: ((UUID, TeamColor) -> Void)?
    private var onPowerUpCollected: ((UUID, PowerUpSpawn.PowerUpType) -> Void)?

    // Active objectives
    private var captureZones: [UUID: CaptureZoneState] = [:]
    private var artifacts: [UUID: ArtifactState] = [:]
    private var powerUps: [UUID: PowerUpState] = [:]

    init(scene: Scene?) {
        self.scene = scene
    }

    // MARK: - Update

    func update(deltaTime: TimeInterval) {
        updateCaptureZones(deltaTime: Float(deltaTime))
        updateArtifacts()
        updatePowerUps(deltaTime: deltaTime)
    }

    // MARK: - Capture Zones

    private func updateCaptureZones(deltaTime: Float) {
        guard let scene = scene else { return }

        for entity in scene.entities {
            updateCaptureZoneEntity(entity, deltaTime: deltaTime)
        }
    }

    private func updateCaptureZoneEntity(_ entity: Entity, deltaTime: Float) {
        guard var territory = entity.components[TerritoryComponent.self] else {
            // Check children
            for child in entity.children {
                updateCaptureZoneEntity(child, deltaTime: deltaTime)
            }
            return
        }

        // Find players in radius
        let playersInZone = findPlayersInRadius(
            center: entity.position,
            radius: territory.captureRadius
        )

        // Group by team
        var teamCounts: [TeamColor: Int] = [:]
        for player in playersInZone {
            if let playerComp = player.components[PlayerComponent.self],
               let health = player.components[HealthComponent.self],
               health.isAlive {
                teamCounts[playerComp.team, default: 0] += 1
            }
        }

        // Update capture progress
        let previousTeam = territory.controllingTeam
        territory.updateCapture(teams: teamCounts, deltaTime: deltaTime)

        // Check if capture completed
        if territory.controllingTeam != previousTeam,
           let newTeam = territory.controllingTeam {
            onObjectiveCaptured?(entity.id, newTeam)
        }

        entity.components[TerritoryComponent.self] = territory

        // Update visual (change color based on controlling team)
        updateCaptureZoneVisual(entity, territory: territory)

        // Check children
        for child in entity.children {
            updateCaptureZoneEntity(child, deltaTime: deltaTime)
        }
    }

    private func updateCaptureZoneVisual(_ entity: Entity, territory: TerritoryComponent) {
        guard var model = entity.components[ModelComponent.self] else { return }

        let color: UIColor
        if let team = territory.controllingTeam {
            color = teamColor(team).withAlphaComponent(0.5)
        } else if territory.isContested {
            color = UIColor.yellow.withAlphaComponent(0.5)
        } else {
            color = UIColor.white.withAlphaComponent(0.3)
        }

        var material = SimpleMaterial()
        material.color = .init(tint: color)
        model.materials = [material]

        entity.components[ModelComponent.self] = model
    }

    func resetCaptureZone(_ zoneID: UUID) {
        if let zoneEntity = findEntityByID(zoneID),
           var territory = zoneEntity.components[TerritoryComponent.self] {
            territory.reset()
            zoneEntity.components[TerritoryComponent.self] = territory
        }
    }

    // MARK: - Artifacts

    func spawnArtifact(at position: SIMD3<Float>) -> Entity {
        guard let scene = scene else {
            fatalError("Scene not available")
        }

        let artifact = Entity()
        artifact.name = "Artifact"
        artifact.position = position

        // Visual
        let mesh = MeshResource.generateSphere(radius: 0.2)
        let material = SimpleMaterial(color: .systemYellow, isMetallic: true)
        artifact.components[ModelComponent.self] = ModelComponent(
            mesh: mesh,
            materials: [material]
        )

        // Rotation animation
        artifact.components[RotationComponent.self] = RotationComponent(
            speed: 2.0,
            axis: [0, 1, 0]
        )

        // Collision
        let shape = ShapeResource.generateSphere(radius: 0.3)
        artifact.components[CollisionComponent.self] = CollisionComponent(
            shapes: [shape],
            mode: .trigger
        )

        scene.anchors.first?.addChild(artifact)

        // Track artifact
        artifacts[artifact.id] = ArtifactState(
            id: artifact.id,
            position: position,
            carrier: nil
        )

        return artifact
    }

    func pickupArtifact(artifact: Entity, by player: Entity) -> Bool {
        guard var state = artifacts[artifact.id],
              state.carrier == nil,
              let playerComp = player.components[PlayerComponent.self] else {
            return false
        }

        // Attach artifact to player
        artifact.removeFromParent()
        player.addChild(artifact)
        artifact.position = [0, 0.5, 0] // Above player

        state.carrier = playerComp.playerID
        artifacts[artifact.id] = state

        return true
    }

    func dropArtifact(artifact: Entity, at position: SIMD3<Float>) {
        guard var state = artifacts[artifact.id] else { return }

        // Detach from player
        artifact.removeFromParent()
        artifact.position = position
        scene?.anchors.first?.addChild(artifact)

        state.carrier = nil
        artifacts[artifact.id] = state
    }

    func bankArtifact(_ artifactID: UUID, team: TeamColor) -> Bool {
        guard let state = artifacts[artifactID],
              state.carrier != nil else {
            return false
        }

        // Remove artifact
        if let artifactEntity = findEntityByID(artifactID) {
            artifactEntity.removeFromParent()
        }

        artifacts.removeValue(forKey: artifactID)

        // Award points
        return true
    }

    private func updateArtifacts() {
        // Check for dropped artifacts
        for (id, var state) in artifacts {
            if state.carrier == nil {
                // Check if any player is close enough to pick up
                if let artifact = findEntityByID(id) {
                    let nearbyPlayers = findPlayersInRadius(
                        center: artifact.position,
                        radius: 0.5
                    )

                    if let player = nearbyPlayers.first {
                        pickupArtifact(artifact: artifact, by: player)
                    }
                }
            }
        }
    }

    // MARK: - Power-Ups

    func spawnPowerUp(type: PowerUpSpawn.PowerUpType, at position: SIMD3<Float>) -> Entity {
        let powerUp = EntityFactory.createPowerUp(type: type, position: position)

        powerUps[powerUp.id] = PowerUpState(
            id: powerUp.id,
            type: type,
            spawnTime: Date().timeIntervalSince1970,
            respawnDelay: 30.0
        )

        scene?.anchors.first?.addChild(powerUp)

        return powerUp
    }

    func collectPowerUp(_ powerUpID: UUID, by player: Entity) -> Bool {
        guard var state = powerUps[powerUpID],
              let powerUpEntity = findEntityByID(powerUpID),
              var health = player.components[HealthComponent.self],
              var energy = player.components[EnergyComponent.self],
              var playerComp = player.components[PlayerComponent.self] else {
            return false
        }

        // Apply power-up effect
        switch state.type {
        case .health:
            health.heal(state.type.value)
        case .shield:
            health.restoreShields(state.type.value)
        case .damage:
            // TODO: Apply damage buff with duration
            break
        case .speed:
            // TODO: Apply speed buff with duration
            break
        case .ultimateCharge:
            playerComp.ultimateCharge += state.type.value
        }

        player.components[HealthComponent.self] = health
        player.components[EnergyComponent.self] = energy
        player.components[PlayerComponent.self] = playerComp

        // Remove visual
        powerUpEntity.removeFromParent()

        // Schedule respawn
        state.lastCollectedTime = Date().timeIntervalSince1970
        powerUps[powerUpID] = state

        onPowerUpCollected?(powerUpID, state.type)

        return true
    }

    private func updatePowerUps(deltaTime: TimeInterval) {
        let currentTime = Date().timeIntervalSince1970

        for (id, var state) in powerUps {
            // Check if should respawn
            if let lastCollected = state.lastCollectedTime,
               currentTime - lastCollected >= state.respawnDelay {
                // Respawn power-up
                if let originalPosition = state.originalPosition {
                    let powerUp = spawnPowerUp(type: state.type, at: originalPosition)
                    state.lastCollectedTime = nil
                    powerUps[id] = state
                }
            }

            // Check for nearby players to collect
            if let powerUpEntity = findEntityByID(id),
               state.lastCollectedTime == nil {
                let nearbyPlayers = findPlayersInRadius(
                    center: powerUpEntity.position,
                    radius: 0.5
                )

                if let player = nearbyPlayers.first {
                    collectPowerUp(id, by: player)
                }
            }
        }
    }

    // MARK: - Utilities

    private func findPlayersInRadius(center: SIMD3<Float>, radius: Float) -> [Entity] {
        guard let scene = scene else { return [] }

        var players: [Entity] = []

        for entity in scene.entities {
            findPlayersInEntity(entity, center: center, radius: radius, results: &players)
        }

        return players
    }

    private func findPlayersInEntity(
        _ entity: Entity,
        center: SIMD3<Float>,
        radius: Float,
        results: inout [Entity]
    ) {
        if entity.components[PlayerComponent.self] != nil {
            let distance = simd_distance(entity.position, center)
            if distance <= radius {
                results.append(entity)
            }
        }

        for child in entity.children {
            findPlayersInEntity(child, center: center, radius: radius, results: &results)
        }
    }

    private func findEntityByID(_ id: UUID) -> Entity? {
        guard let scene = scene else { return nil }

        for entity in scene.entities {
            if let found = searchForEntityByID(entity, id: id) {
                return found
            }
        }

        return nil
    }

    private func searchForEntityByID(_ entity: Entity, id: UUID) -> Entity? {
        if entity.id == id {
            return entity
        }

        for child in entity.children {
            if let found = searchForEntityByID(child, id: id) {
                return found
            }
        }

        return nil
    }

    private func teamColor(_ team: TeamColor) -> UIColor {
        switch team {
        case .blue: return UIColor(red: 0, green: 0.75, blue: 1.0, alpha: 1.0)
        case .red: return UIColor(red: 1.0, green: 0.27, blue: 0.27, alpha: 1.0)
        case .neutral: return UIColor(red: 1.0, green: 0.67, blue: 0, alpha: 1.0)
        }
    }

    // MARK: - Callbacks

    func setObjectiveCapturedCallback(_ callback: @escaping (UUID, TeamColor) -> Void) {
        self.onObjectiveCaptured = callback
    }

    func setPowerUpCollectedCallback(_ callback: @escaping (UUID, PowerUpSpawn.PowerUpType) -> Void) {
        self.onPowerUpCollected = callback
    }
}

// MARK: - State Structs

struct CaptureZoneState {
    let id: UUID
    var controllingTeam: TeamColor?
    var captureProgress: Float = 0.0
}

struct ArtifactState {
    let id: UUID
    var position: SIMD3<Float>
    var carrier: UUID?
}

struct PowerUpState {
    let id: UUID
    let type: PowerUpSpawn.PowerUpType
    var spawnTime: TimeInterval
    var lastCollectedTime: TimeInterval?
    var respawnDelay: TimeInterval
    var originalPosition: SIMD3<Float>?
}
