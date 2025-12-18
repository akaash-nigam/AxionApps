# Spatial Arena Championship - Technical Specification

## Document Overview
This document provides detailed technical specifications for implementing Spatial Arena Championship, covering all technology stack decisions, implementation patterns, performance requirements, and testing strategies.

**Version:** 1.0
**Last Updated:** 2025-11-19
**Target Platform:** visionOS 2.0+

---

## Table of Contents

1. [Technology Stack](#technology-stack)
2. [Development Environment](#development-environment)
3. [Game Mechanics Implementation](#game-mechanics-implementation)
4. [Control Schemes](#control-schemes)
5. [Physics Specifications](#physics-specifications)
6. [Rendering Requirements](#rendering-requirements)
7. [Networking Specifications](#networking-specifications)
8. [Performance Budgets](#performance-budgets)
9. [Testing Requirements](#testing-requirements)
10. [Deployment & Distribution](#deployment--distribution)

---

## Technology Stack

### Core Technologies

#### Primary Framework Stack
```yaml
Swift: 6.0+
  - Concurrency: async/await, actors
  - Strict concurrency checking
  - Modern Swift features (macros, property wrappers)

SwiftUI: visionOS 2.0+
  - UI and menu systems
  - @Observable macro for state management
  - Custom ornaments for HUD
  - Window Groups for menus

RealityKit: 2.0+
  - 3D rendering engine
  - Entity-Component-System (ECS)
  - Custom components and systems
  - Material and shader system
  - Particle effects

ARKit: visionOS 2.0+
  - WorldTrackingProvider
  - HandTrackingProvider
  - SceneReconstructionProvider
  - PlaneDetectionProvider

visionOS SDK: 2.0+
  - ImmersiveSpace API
  - Spatial audio framework
  - Room scanning APIs
```

#### Supporting Frameworks
```swift
// Networking
import MultipeerConnectivity   // Local multiplayer
import Network                  // Low-level networking
import Combine                  // Reactive streams

// Audio
import AVFoundation            // Spatial audio
import CoreAudio               // Low-latency audio

// Performance
import Metal                   // GPU programming
import MetalKit                // Metal utilities
import Accelerate              // Vector math

// AI/ML (Future)
import CoreML                  // On-device ML
import CreateML                // Model training

// Data
import SwiftData               // Persistent storage
import CloudKit                // Cloud sync

// Analytics
import OSLog                   // Structured logging
```

### Project Structure

```
SpatialArenaChampionship/
├── SpatialArenaChampionship.xcodeproj
├── SpatialArenaChampionship/
│   ├── App/
│   │   ├── SpatialArenaApp.swift
│   │   ├── AppCoordinator.swift
│   │   └── AppState.swift
│   │
│   ├── Game/
│   │   ├── Core/
│   │   │   ├── GameLoop.swift
│   │   │   ├── GameState.swift
│   │   │   └── GameCoordinator.swift
│   │   ├── Entities/
│   │   │   ├── Player.swift
│   │   │   ├── Projectile.swift
│   │   │   └── PowerUp.swift
│   │   ├── Components/
│   │   │   ├── PlayerComponent.swift
│   │   │   ├── HealthComponent.swift
│   │   │   ├── VelocityComponent.swift
│   │   │   └── AbilityComponent.swift
│   │   └── Systems/
│   │       ├── MovementSystem.swift
│   │       ├── CombatSystem.swift
│   │       ├── NetworkSyncSystem.swift
│   │       └── AudioSystem.swift
│   │
│   ├── Arena/
│   │   ├── ArenaManager.swift
│   │   ├── ArenaCalibration.swift
│   │   ├── ArenaThemes/
│   │   └── EnvironmentalEffects/
│   │
│   ├── Input/
│   │   ├── InputManager.swift
│   │   ├── HandTrackingManager.swift
│   │   ├── EyeTrackingManager.swift
│   │   └── GestureRecognizers/
│   │
│   ├── Network/
│   │   ├── NetworkManager.swift
│   │   ├── MatchmakingManager.swift
│   │   ├── ServerConnection.swift
│   │   └── Protocols/
│   │
│   ├── Physics/
│   │   ├── PhysicsManager.swift
│   │   ├── CollisionSystem.swift
│   │   └── SpatialHash.swift
│   │
│   ├── Audio/
│   │   ├── AudioManager.swift
│   │   ├── SpatialAudioEngine.swift
│   │   └── SoundLibrary/
│   │
│   ├── UI/
│   │   ├── Views/
│   │   │   ├── MainMenuView.swift
│   │   │   ├── MatchmakingView.swift
│   │   │   ├── HUDView.swift
│   │   │   └── SettingsView.swift
│   │   ├── Components/
│   │   └── ViewModels/
│   │
│   ├── Models/
│   │   ├── Player.swift
│   │   ├── Match.swift
│   │   ├── Ability.swift
│   │   └── Arena.swift
│   │
│   ├── Resources/
│   │   ├── Assets.xcassets
│   │   ├── RealityKitContent/
│   │   │   ├── Arenas/
│   │   │   ├── Characters/
│   │   │   ├── Effects/
│   │   │   └── Materials/
│   │   ├── Audio/
│   │   │   ├── Music/
│   │   │   ├── SFX/
│   │   │   └── Voice/
│   │   └── Shaders/
│   │
│   └── Utilities/
│       ├── Extensions/
│       ├── Helpers/
│       └── Constants.swift
│
├── SpatialArenaChampionshipTests/
│   ├── GameLogicTests/
│   ├── NetworkTests/
│   ├── PhysicsTests/
│   └── PerformanceTests/
│
└── SpatialArenaChampionshipUITests/
    ├── MenuFlowTests/
    └── GameplayTests/
```

---

## Development Environment

### Requirements

```yaml
Hardware:
  - Mac: Apple Silicon (M1/M2/M3+)
  - RAM: 16GB minimum, 32GB recommended
  - Storage: 50GB free space
  - Vision Pro: Development device

Software:
  - macOS: Sonoma 14.0+
  - Xcode: 16.0+
  - visionOS SDK: 2.0+
  - Git: 2.0+
```

### Xcode Configuration

```swift
// Build Settings
SWIFT_VERSION = 6.0
IPHONEOS_DEPLOYMENT_TARGET = 2.0
TARGETED_DEVICE_FAMILY = 7 // Vision

// Optimization
SWIFT_OPTIMIZATION_LEVEL = -O // Release
SWIFT_OPTIMIZATION_LEVEL = -Onone // Debug
ENABLE_TESTABILITY = YES // Debug

// Concurrency
SWIFT_STRICT_CONCURRENCY = complete
ENABLE_STRICT_CONCURRENCY_CHECKING = YES

// Other
ENABLE_PREVIEWS = YES
ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon
```

### Package Dependencies

```swift
// Package.swift
dependencies: [
    // Networking utilities
    .package(url: "https://github.com/apple/swift-nio.git", from: "2.0.0"),

    // JSON handling
    .package(url: "https://github.com/Flight-School/AnyCodable", from: "0.6.0"),

    // Logging
    .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0"),
]
```

---

## Game Mechanics Implementation

### Core Movement System

```swift
// Movement specifications
struct MovementConfig {
    // Speed in meters per second
    static let walkSpeed: Float = 1.5       // Normal movement
    static let sprintSpeed: Float = 3.0     // Sprint modifier
    static let dodgeSpeed: Float = 4.0      // Quick dodge
    static let dodgeDuration: Float = 0.3   // Seconds

    // Acceleration
    static let acceleration: Float = 8.0     // m/s²
    static let deceleration: Float = 10.0    // m/s²

    // Physics
    static let playerRadius: Float = 0.3     // Collision radius
    static let playerHeight: Float = 1.8     // Standing height
}

class MovementController {
    func processMovementInput(
        _ input: MovementInput,
        current: Transform,
        deltaTime: Float
    ) -> Transform {
        var newTransform = current

        // Calculate desired velocity
        let desiredVelocity = input.direction * MovementConfig.walkSpeed * input.speedMultiplier

        // Apply acceleration
        let acceleration = input.isSprinting ? MovementConfig.acceleration * 1.5 : MovementConfig.acceleration
        let velocityDelta = desiredVelocity * acceleration * deltaTime

        // Update velocity (with smoothing)
        let currentVelocity = (newTransform.translation - lastPosition) / deltaTime
        let newVelocity = lerp(currentVelocity, desiredVelocity, t: deltaTime * 10)

        // Apply velocity to position
        newTransform.translation += newVelocity * deltaTime

        // Clamp to arena bounds
        newTransform.translation = clampToArena(newTransform.translation)

        return newTransform
    }
}
```

### Ability System Implementation

```swift
struct AbilityConfig {
    // Primary Fire (Projectile)
    struct PrimaryFire {
        static let damage: Float = 20.0
        static let speed: Float = 10.0
        static let cooldown: TimeInterval = 0.5
        static let energyCost: Float = 0.0
        static let projectileSize: Float = 0.05
        static let maxRange: Float = 30.0
    }

    // Shield Wall
    struct Shield {
        static let durability: Float = 100.0
        static let duration: TimeInterval = 3.0
        static let cooldown: TimeInterval = 8.0
        static let energyCost: Float = 30.0
        static let size: SIMD3<Float> = [2.0, 2.0, 0.1]
    }

    // Ultimate Ability (Room-filling blast)
    struct Ultimate {
        static let damage: Float = 50.0
        static let radius: Float = 5.0
        static let chargeRequired: Float = 100.0
        static let castTime: TimeInterval = 1.0
    }
}

class AbilitySystem {
    func activatePrimaryFire(
        player: Entity,
        direction: SIMD3<Float>
    ) -> Entity? {
        // Check if ability is ready
        guard canUseAbility(.primaryFire, for: player) else { return nil }

        // Create projectile
        let projectile = EntityFactory.createProjectile(
            owner: player.id,
            position: player.position + SIMD3(0, 1.5, 0),
            direction: direction,
            team: player.components[PlayerComponent.self]!.team
        )

        // Apply cooldown
        applyAbilityCooldown(.primaryFire, to: player)

        return projectile
    }

    func activateShield(
        player: Entity,
        forward: SIMD3<Float>
    ) -> Entity? {
        guard canUseAbility(.shield, for: player) else { return nil }

        // Deduct energy
        var playerComp = player.components[PlayerComponent.self]!
        playerComp.energy -= AbilityConfig.Shield.energyCost
        player.components[PlayerComponent.self] = playerComp

        // Create shield entity
        let shield = EntityFactory.createShield(
            owner: player.id,
            position: player.position + forward * 1.0,
            orientation: simd_quatf(forward: forward, up: [0, 1, 0])
        )

        // Auto-destroy after duration
        Task {
            try await Task.sleep(for: .seconds(AbilityConfig.Shield.duration))
            shield.scene?.removeEntity(shield)
        }

        applyAbilityCooldown(.shield, to: player)

        return shield
    }
}
```

### Combat System Implementation

```swift
struct CombatConfig {
    // Damage values
    static let headshotMultiplier: Float = 2.0
    static let backstabMultiplier: Float = 1.5

    // Health regeneration
    static let healthRegenDelay: TimeInterval = 5.0
    static let healthRegenRate: Float = 10.0 // HP per second

    // Shield mechanics
    static let shieldRegenDelay: TimeInterval = 3.0
    static let shieldRegenRate: Float = 20.0
}

class CombatSystem {
    func applyDamage(
        to target: Entity,
        amount: Float,
        from attacker: Entity,
        hitPosition: SIMD3<Float>
    ) {
        guard var health = target.components[HealthComponent.self] else { return }

        // Calculate damage multipliers
        var finalDamage = amount

        // Headshot detection
        let headPosition = target.position + SIMD3(0, 1.7, 0)
        if distance(hitPosition, headPosition) < 0.15 {
            finalDamage *= CombatConfig.headshotMultiplier
            showHeadshotIndicator(at: hitPosition)
        }

        // Apply to shields first, then health
        if health.shields > 0 {
            let shieldDamage = min(finalDamage, health.shields)
            health.shields -= shieldDamage
            finalDamage -= shieldDamage
        }

        if finalDamage > 0 {
            health.current -= finalDamage
        }

        // Track damage source
        health.lastDamageTime = Date().timeIntervalSince1970
        health.lastDamageSource = attacker.id

        // Check for death
        if health.current <= 0 {
            handlePlayerDeath(target, killedBy: attacker)
        }

        target.components[HealthComponent.self] = health

        // Trigger hit feedback
        triggerHitFeedback(target: target, damage: finalDamage)
    }

    func handlePlayerDeath(_ player: Entity, killedBy killer: Entity) {
        // Update stats
        updateKillStats(killer: killer, victim: player)

        // Trigger death animation/effects
        playDeathEffects(at: player.position)

        // Respawn after delay
        Task {
            try await Task.sleep(for: .seconds(3))
            respawnPlayer(player)
        }
    }
}
```

### Objective System (Territory Control)

```swift
class ObjectiveSystem {
    func updateTerritoryControl(deltaTime: Float) {
        for objective in activeObjectives {
            guard var territory = objective.components[TerritoryComponent.self] else { continue }

            // Find players in capture radius
            let nearbyPlayers = getPlayersInRadius(objective.position, territory.captureRadius)

            // Determine controlling teams
            let teamPresence = nearbyPlayers.reduce(into: [TeamColor: Int]()) { counts, player in
                let team = player.components[PlayerComponent.self]!.team
                counts[team, default: 0] += 1
            }

            // Update capture progress
            if teamPresence.count == 1, let (team, count) = teamPresence.first {
                // Single team capturing
                territory.contestedBy = []
                let captureRate: Float = 0.1 * Float(count) // Faster with more players

                if territory.controllingTeam == team {
                    // Already controlled, maintain
                    territory.captureProgress = 1.0
                } else {
                    // Capturing from neutral or enemy
                    territory.captureProgress += captureRate * deltaTime

                    if territory.captureProgress >= 1.0 {
                        territory.controllingTeam = team
                        territory.captureProgress = 1.0
                        triggerTerritoryCapture(objective, by: team)
                    }
                }
            } else if teamPresence.count > 1 {
                // Contested
                territory.contestedBy = Set(teamPresence.keys)
                territory.captureProgress = max(0, territory.captureProgress - 0.05 * deltaTime)
            } else {
                // No players, decay progress if not fully captured
                if territory.controllingTeam == nil {
                    territory.captureProgress = max(0, territory.captureProgress - 0.03 * deltaTime)
                }
            }

            objective.components[TerritoryComponent.self] = territory
        }
    }
}
```

---

## Control Schemes

### Input System Architecture

```swift
enum InputMethod {
    case handTracking
    case eyeTracking
    case gameController
    case combined // Eye + Hand
}

struct InputConfig {
    var primaryMethod: InputMethod = .combined
    var aimAssist: Bool = false
    var sensitivity: Float = 1.0
    var deadzone: Float = 0.1
}

class InputManager: @unchecked Sendable {
    let handTracking: HandTrackingManager
    let eyeTracking: EyeTrackingManager
    let gameControllerManager: GameControllerManager

    @Published var currentInput: CombinedInput = .zero

    func update() async {
        // Gather input from all sources
        let handInput = await handTracking.getCurrentInput()
        let eyeInput = await eyeTracking.getCurrentInput()
        let controllerInput = gameControllerManager.getCurrentInput()

        // Merge based on configuration
        currentInput = mergeInputs(
            hand: handInput,
            eye: eyeInput,
            controller: controllerInput
        )
    }
}
```

### Hand Tracking Implementation

```swift
class HandTrackingManager {
    let provider: HandTrackingProvider

    func getCurrentInput() async -> HandInput {
        guard let leftHand = provider.leftHand,
              let rightHand = provider.rightHand else {
            return .zero
        }

        var input = HandInput()

        // Pointing gesture for aiming
        if isPointing(rightHand) {
            input.aimDirection = getPointingDirection(rightHand)
            input.firePressed = isPinching(rightHand)
        }

        // Shield gesture detection
        if isPalmForward(leftHand) && isPalmForward(rightHand) {
            input.shieldActive = true
        }

        // Ultimate gesture (two hands together)
        if areHandsTogether(leftHand, rightHand) {
            input.ultimatePressed = true
        }

        return input
    }

    func isPointing(_ hand: HandAnchor) -> Bool {
        let indexTip = hand.handSkeleton!.joint(.indexFingerTip)
        let indexBase = hand.handSkeleton!.joint(.indexFingerMetacarpal)
        let middleTip = hand.handSkeleton!.joint(.middleFingerTip)

        // Index extended, middle curled
        let indexExtended = distance(indexTip.position, indexBase.position) > 0.08
        let middleCurled = distance(middleTip.position, indexBase.position) < 0.06

        return indexExtended && middleCurled
    }

    func getPointingDirection(_ hand: HandAnchor) -> SIMD3<Float> {
        let indexTip = hand.handSkeleton!.joint(.indexFingerTip)
        let wrist = hand.handSkeleton!.joint(.wrist)

        return normalize(indexTip.position - wrist.position)
    }

    func isPinching(_ hand: HandAnchor) -> Bool {
        let thumbTip = hand.handSkeleton!.joint(.thumbTip)
        let indexTip = hand.handSkeleton!.joint(.indexFingerTip)

        return distance(thumbTip.position, indexTip.position) < 0.02
    }
}
```

### Eye Tracking Implementation

```swift
class EyeTrackingManager {
    func getCurrentInput() async -> EyeInput {
        // Get device anchor (head position/orientation)
        guard let deviceAnchor = await getDeviceAnchor() else {
            return .zero
        }

        // Raycast from eye gaze
        let origin = deviceAnchor.originFromAnchorTransform.translation
        let direction = deviceAnchor.originFromAnchorTransform.forwardVector

        var input = EyeInput()
        input.gazeOrigin = origin
        input.gazeDirection = direction

        // Raycast to find target
        if let hit = rayCast(origin: origin, direction: direction, maxDistance: 50.0) {
            input.gazeTarget = hit.position
            input.gazeTargetEntity = hit.entity
        }

        return input
    }
}
```

### Game Controller Support

```swift
import GameController

class GameControllerManager {
    var controller: GCController?

    func setupController() {
        NotificationCenter.default.addObserver(
            forName: .GCControllerDidConnect,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            self?.controller = notification.object as? GCController
            self?.configureController()
        }
    }

    func configureController() {
        guard let gamepad = controller?.extendedGamepad else { return }

        // Movement
        gamepad.leftThumbstick.valueChangedHandler = { [weak self] _, x, y in
            self?.currentInput.movement = SIMD2(x, y)
        }

        // Aiming
        gamepad.rightThumbstick.valueChangedHandler = { [weak self] _, x, y in
            self?.currentInput.aim = SIMD2(x, y)
        }

        // Abilities
        gamepad.buttonA.pressedChangedHandler = { [weak self] _, _, pressed in
            self?.currentInput.primaryFire = pressed
        }

        gamepad.buttonB.pressedChangedHandler = { [weak self] _, _, pressed in
            self?.currentInput.secondaryAbility = pressed
        }

        gamepad.rightTrigger.pressedChangedHandler = { [weak self] _, _, pressed in
            self?.currentInput.primaryFire = pressed
        }

        gamepad.leftTrigger.pressedChangedHandler = { [weak self] _, _, pressed in
            self?.currentInput.shield = pressed
        }
    }
}
```

---

## Physics Specifications

### Physics Engine Configuration

```swift
struct PhysicsConfiguration {
    // Simulation
    static let gravity: SIMD3<Float> = [0, -9.81, 0]
    static let fixedTimestep: Double = 1.0 / 90.0
    static let maxSubsteps: Int = 3
    static let solverIterations: Int = 8

    // Collision detection
    static let collisionMargin: Float = 0.001
    static let continuousCollisionDetection: Bool = true

    // Material properties
    struct Materials {
        static let playerFriction: Float = 0.4
        static let playerRestitution: Float = 0.0

        static let projectileFriction: Float = 0.0
        static let projectileRestitution: Float = 0.8

        static let environmentFriction: Float = 0.6
        static let environmentRestitution: Float = 0.3
    }
}
```

### Collision Layers & Masks

```swift
struct CollisionCategory: OptionSet {
    let rawValue: UInt32

    static let player      = CollisionCategory(rawValue: 1 << 0) // 0b00001
    static let projectile  = CollisionCategory(rawValue: 1 << 1) // 0b00010
    static let environment = CollisionCategory(rawValue: 1 << 2) // 0b00100
    static let trigger     = CollisionCategory(rawValue: 1 << 3) // 0b01000
    static let powerUp     = CollisionCategory(rawValue: 1 << 4) // 0b10000

    // What each category collides with
    static func maskFor(_ category: CollisionCategory) -> CollisionCategory {
        switch category {
        case .player:
            return [.player, .environment, .trigger, .powerUp]
        case .projectile:
            return [.player, .environment]
        case .environment:
            return [.player, .projectile]
        case .trigger:
            return [.player]
        case .powerUp:
            return [.player]
        default:
            return []
        }
    }
}
```

### Physics Bodies Configuration

```swift
extension EntityFactory {
    static func addPhysics(to entity: Entity, type: PhysicsBodyType) {
        switch type {
        case .player:
            let shape = ShapeResource.generateCapsule(height: 1.8, radius: 0.3)
            let physics = PhysicsBodyComponent(
                shapes: [shape],
                mass: 70.0,
                material: .init(
                    friction: PhysicsConfiguration.Materials.playerFriction,
                    restitution: PhysicsConfiguration.Materials.playerRestitution
                ),
                mode: .dynamic
            )
            entity.components[PhysicsBodyComponent.self] = physics

            let collision = CollisionComponent(
                shapes: [shape],
                mode: .trigger,
                filter: .init(
                    group: .player,
                    mask: CollisionCategory.maskFor(.player)
                )
            )
            entity.components[CollisionComponent.self] = collision

        case .projectile:
            let shape = ShapeResource.generateSphere(radius: 0.05)
            let physics = PhysicsBodyComponent(
                shapes: [shape],
                mass: 0.1,
                material: .init(
                    friction: PhysicsConfiguration.Materials.projectileFriction,
                    restitution: PhysicsConfiguration.Materials.projectileRestitution
                ),
                mode: .dynamic
            )
            physics.isAffectedByGravity = false
            entity.components[PhysicsBodyComponent.self] = physics

            let collision = CollisionComponent(
                shapes: [shape],
                mode: .trigger,
                filter: .init(
                    group: .projectile,
                    mask: CollisionCategory.maskFor(.projectile)
                )
            )
            entity.components[CollisionComponent.self] = collision

        case .environment:
            // Static collision mesh
            let collision = CollisionComponent(
                shapes: entity.model?.mesh?.shapeResource ?? [],
                mode: .default,
                filter: .init(
                    group: .environment,
                    mask: CollisionCategory.maskFor(.environment)
                )
            )
            entity.components[CollisionComponent.self] = collision
        }
    }
}
```

---

## Rendering Requirements

### Graphics Quality Settings

```swift
enum GraphicsQuality: String, CaseIterable {
    case low
    case medium
    case high
    case ultra

    var targetFrameRate: Int {
        switch self {
        case .low: return 90
        case .medium: return 90
        case .high: return 90
        case .ultra: return 90 // Always 90 for competitive integrity
        }
    }

    var maxParticles: Int {
        switch self {
        case .low: return 1000
        case .medium: return 3000
        case .high: return 5000
        case .ultra: return 10000
        }
    }

    var shadowQuality: ShadowQuality {
        switch self {
        case .low: return .off
        case .medium: return .low
        case .high: return .medium
        case .ultra: return .high
        }
    }

    var textureResolution: Float {
        switch self {
        case .low: return 0.5
        case .medium: return 0.75
        case .high: return 1.0
        case .ultra: return 1.0
        }
    }
}

struct RenderingConfig {
    var quality: GraphicsQuality = .high
    var antialiasing: Bool = true
    var dynamicResolution: Bool = true
    var bloomEnabled: Bool = true
    var ambientOcclusion: Bool = true
}
```

### Material System

```swift
// Custom shader for team-colored materials
struct TeamColorMaterial {
    var baseColor: UIColor
    var emissiveColor: UIColor
    var metallic: Float
    var roughness: Float

    func createMaterial() -> Material {
        var material = SimpleMaterial()
        material.color = .init(tint: baseColor)
        material.metallic = .init(floatLiteral: metallic)
        material.roughness = .init(floatLiteral: roughness)

        if emissiveColor != .clear {
            material.emissiveColor = .init(color: emissiveColor)
            material.emissiveIntensity = 2.0
        }

        return material
    }
}

// Particle effects configuration
struct ParticleEffectConfig {
    var birthRate: Float = 100
    var lifetime: Float = 1.0
    var speed: Float = 1.0
    var size: Float = 0.01
    var color: UIColor = .white
    var emitterShape: ParticleEmitterComponent.EmitterShape = .sphere

    func createEmitter() -> ParticleEmitterComponent {
        var emitter = ParticleEmitterComponent()
        emitter.birthRate = birthRate
        emitter.lifeSpan = TimeInterval(lifetime)
        emitter.speed = speed
        emitter.emitterShape = emitterShape
        return emitter
    }
}
```

### LOD (Level of Detail) System

```swift
class LODManager {
    enum LODLevel {
        case high    // < 3m
        case medium  // 3-10m
        case low     // > 10m
    }

    func updateLOD(for entity: Entity, viewerDistance: Float) {
        let level = getLODLevel(distance: viewerDistance)

        switch level {
        case .high:
            entity.model?.mesh = entity.highDetailMesh
            entity.isEnabled = true
        case .medium:
            entity.model?.mesh = entity.mediumDetailMesh
            entity.isEnabled = true
        case .low:
            entity.model?.mesh = entity.lowDetailMesh
            entity.isEnabled = viewerDistance < 15.0 // Cull beyond 15m
        }
    }

    func getLODLevel(distance: Float) -> LODLevel {
        if distance < 3.0 {
            return .high
        } else if distance < 10.0 {
            return .medium
        } else {
            return .low
        }
    }
}
```

---

## Networking Specifications

### Network Protocol

```swift
enum NetworkProtocol {
    case multipeerConnectivity  // Local matches
    case udp                    // Internet matches (low latency)
    case tcp                    // Reliable messages (matchmaking, chat)
}

struct NetworkConfig {
    static let serverTickRate: Int = 30 // Hz
    static let clientUpdateRate: Int = 30 // Hz
    static let maxPlayers: Int = 10
    static let maxLatency: TimeInterval = 0.050 // 50ms
    static let timeoutDuration: TimeInterval = 10.0
}
```

### Message Format

```swift
// Binary protocol for performance
struct NetworkMessage {
    var header: MessageHeader
    var payload: Data

    struct MessageHeader {
        var messageType: MessageType
        var timestamp: UInt64
        var sequenceNumber: UInt32
        var payloadSize: UInt16
    }

    enum MessageType: UInt8 {
        case playerInput = 0x01
        case worldState = 0x02
        case abilityActivation = 0x03
        case damageEvent = 0x04
        case matchEvent = 0x05
        case chat = 0x06
    }
}

// Serialization
extension NetworkMessage {
    func serialize() -> Data {
        var data = Data()
        data.append(header.messageType.rawValue)
        // ... serialize rest of header
        data.append(payload)
        return data
    }

    static func deserialize(_ data: Data) throws -> NetworkMessage {
        // Parse header and payload
    }
}
```

### Bandwidth Optimization

```swift
struct BandwidthOptimizer {
    // Delta compression for position updates
    func compressPosition(_ current: SIMD3<Float>, _ previous: SIMD3<Float>) -> Data {
        let delta = current - previous

        // Quantize to 16-bit integers (millimeter precision)
        let quantized = SIMD3<Int16>(
            Int16(delta.x * 1000),
            Int16(delta.y * 1000),
            Int16(delta.z * 1000)
        )

        var data = Data()
        data.append(contentsOf: withUnsafeBytes(of: quantized) { Array($0) })
        return data // 6 bytes vs 12 bytes for full float
    }

    // Rotation compression (quaternion to smallest-three)
    func compressRotation(_ quat: simd_quatf) -> Data {
        // Find largest component, omit it
        // Compress remaining 3 components to 10 bits each
        // Total: 32 bits (4 bytes) vs 16 bytes for full quaternion
    }

    // Adaptive update rate
    func getUpdateRateFor(entity: Entity, importance: Float) -> Int {
        if importance > 0.8 {
            return 30 // High priority: 30 Hz
        } else if importance > 0.4 {
            return 15 // Medium: 15 Hz
        } else {
            return 5  // Low: 5 Hz
        }
    }
}
```

### Interpolation & Extrapolation

```swift
class NetworkInterpolation {
    var stateBuffer: [TimeInterval: NetworkPlayerState] = [:]
    let interpolationDelay: TimeInterval = 0.1 // 100ms buffer

    func getInterpolatedState(at time: TimeInterval) -> NetworkPlayerState {
        // Find two states to interpolate between
        let sortedStates = stateBuffer.sorted { $0.key < $1.key }

        guard let (time0, state0) = sortedStates.last(where: { $0.key <= time }),
              let (time1, state1) = sortedStates.first(where: { $0.key > time }) else {
            // No interpolation possible, use latest
            return sortedStates.last!.value
        }

        let t = Float((time - time0) / (time1 - time0))

        var interpolated = state0
        interpolated.position = mix(state0.position, state1.position, t: t)
        interpolated.rotation = simd_slerp(state0.rotation, state1.rotation, t)
        interpolated.velocity = mix(state0.velocity, state1.velocity, t: t)

        return interpolated
    }

    func extrapolateState(from state: NetworkPlayerState, duration: TimeInterval) -> NetworkPlayerState {
        var extrapolated = state
        extrapolated.position += state.velocity * Float(duration)
        // Don't extrapolate rotation (too unpredictable)
        return extrapolated
    }
}
```

---

## Performance Budgets

### Frame Budget (11.1ms @ 90 FPS)

```swift
struct FrameBudget {
    static let total: TimeInterval = 0.0111 // 11.1ms

    // Per-system budgets
    static let input: TimeInterval = 0.001      // 1ms
    static let gameLogic: TimeInterval = 0.004  // 4ms
    static let physics: TimeInterval = 0.003    // 3ms
    static let networking: TimeInterval = 0.001 // 1ms
    static let rendering: TimeInterval = 0.002  // 2ms (RealityKit)
}
```

### Memory Budget

```swift
struct MemoryBudget {
    static let total: Int = 2_000_000_000 // 2GB total

    // Per-system budgets
    static let textures: Int = 500_000_000       // 500MB
    static let meshes: Int = 300_000_000         // 300MB
    static let audio: Int = 200_000_000          // 200MB
    static let code: Int = 100_000_000           // 100MB
    static let gameState: Int = 50_000_000       // 50MB
    static let networking: Int = 50_000_000      // 50MB
    static let other: Int = 800_000_000          // 800MB buffer
}

class MemoryMonitor {
    func checkMemoryUsage() {
        let used = getMemoryUsage()

        if used > MemoryBudget.total * 0.9 {
            logger.warning("Memory usage critical: \(used / 1_000_000)MB")
            triggerMemoryCleanup()
        }
    }

    func getMemoryUsage() -> Int {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4

        let result = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }

        return result == KERN_SUCCESS ? Int(info.resident_size) : 0
    }
}
```

### Battery Budget

```swift
struct BatteryBudget {
    // Target: 90+ minutes of active gameplay
    static let targetGameplayDuration: TimeInterval = 5400 // 90 minutes

    // Power-intensive systems
    static let displayPower: Float = 40.0 // % of battery
    static let gpuPower: Float = 30.0
    static let cpuPower: Float = 15.0
    static let networkingPower: Float = 10.0
    static let other: Float = 5.0
}

class BatteryMonitor {
    func optimizeForBattery() {
        // Reduce non-essential graphics
        GraphicsSettings.shared.bloomEnabled = false
        GraphicsSettings.shared.ambientOcclusion = false

        // Reduce network update rate
        NetworkConfig.clientUpdateRate = 20 // Down from 30 Hz

        // Reduce particle effects
        ParticleManager.shared.maxParticles = 2000 // Down from 5000
    }
}
```

---

## Testing Requirements

### Unit Testing

```swift
// Game Logic Tests
final class GameLogicTests: XCTestCase {
    func testMovementPhysics() {
        let controller = MovementController()
        let input = MovementInput(direction: [1, 0, 0], speed: 1.0)
        let initialTransform = Transform()

        let newTransform = controller.processMovementInput(
            input,
            current: initialTransform,
            deltaTime: 1.0
        )

        XCTAssertGreaterThan(newTransform.translation.x, 0)
        XCTAssertLessThanOrEqual(newTransform.translation.x, MovementConfig.walkSpeed)
    }

    func testDamageCalculation() {
        let combatSystem = CombatSystem()
        let player = createTestPlayer()

        combatSystem.applyDamage(to: player, amount: 50, from: player, hitPosition: [0, 0, 0])

        let health = player.components[HealthComponent.self]!
        XCTAssertEqual(health.current, 50.0)
    }

    func testAbilityCooldown() {
        let abilitySystem = AbilitySystem()
        let player = createTestPlayer()

        // Use ability
        _ = abilitySystem.activatePrimaryFire(player: player, direction: [0, 0, 1])

        // Try immediately again (should fail)
        let result = abilitySystem.activatePrimaryFire(player: player, direction: [0, 0, 1])

        XCTAssertNil(result, "Ability should be on cooldown")
    }
}

// Physics Tests
final class PhysicsTests: XCTestCase {
    func testProjectileCollision() {
        let collisionSystem = CollisionSystem()
        let projectile = createTestProjectile()
        let player = createTestPlayer()

        // Move projectile to player position
        projectile.position = player.position

        let collision = collisionSystem.testCollision(projectile, player)

        XCTAssertNotNil(collision)
    }

    func testSpatialHashing() {
        let spatialHash = SpatialHash()
        let entity = createTestEntity()
        entity.position = [1.5, 0, 1.5]

        spatialHash.insert(entity)

        let results = spatialHash.query(around: [1.0, 0, 1.0], radius: 1.0)

        XCTAssertTrue(results.contains(entity))
    }
}
```

### Performance Testing

```swift
final class PerformanceTests: XCTestCase {
    func testFrameRate() {
        measure {
            let gameLoop = GameLoop()
            for _ in 0..<90 { // Simulate 1 second
                gameLoop.update(deltaTime: 1.0 / 90.0)
            }
        }

        // Assert average frame time < 11.1ms
    }

    func testMemoryUsage() {
        let arena = ArenaManager()
        let initialMemory = getMemoryUsage()

        arena.loadArena(.cyberArena)

        let finalMemory = getMemoryUsage()
        let delta = finalMemory - initialMemory

        XCTAssertLessThan(delta, 200_000_000, "Arena should use < 200MB")
    }

    func testNetworkLatency() async {
        let network = NetworkManager()
        let start = Date()

        await network.sendPlayerInput(testInput)

        let latency = Date().timeIntervalSince(start)

        XCTAssertLessThan(latency, 0.050, "Network latency should be < 50ms")
    }
}
```

### Integration Testing

```swift
final class IntegrationTests: XCTestCase {
    func testFullMatchFlow() async throws {
        // Initialize game
        let coordinator = GameCoordinator()

        // Create match
        let match = try await coordinator.matchmaker.findMatch(player: testPlayer)

        // Start match
        await coordinator.transitionTo(.activeMatch)

        // Simulate gameplay for 10 seconds
        for _ in 0..<900 {
            coordinator.update(deltaTime: 1.0 / 90.0)
        }

        // End match
        await coordinator.endMatch(winner: match.team1)

        XCTAssertEqual(coordinator.currentState, .postMatch)
    }

    func testMultiplayerSync() async {
        let host = NetworkManager()
        let client = NetworkManager()

        // Connect
        try await host.hostMatch()
        try await client.joinMatch(host: host.localPeer)

        // Send player position from client
        let testPosition = SIMD3<Float>(1, 2, 3)
        await client.sendPlayerInput(PlayerInputData(position: testPosition))

        // Wait for sync
        try await Task.sleep(for: .milliseconds(100))

        // Verify host received update
        let receivedPosition = host.getPlayerPosition(client.localPlayerID)
        XCTAssertEqual(receivedPosition, testPosition, accuracy: 0.01)
    }
}
```

### Playtest Metrics

```swift
struct PlaytestMetrics {
    // Combat feel
    var weaponFeel: Rating // 1-5
    var abilityResponsiveness: Rating
    var hitFeedbackClarity: Rating

    // Balance
    var matchBalance: Rating
    var abilityBalance: Rating
    var mapBalance: Rating

    // Comfort
    var motionSickness: Rating // 1=none, 5=severe
    var fatigueLevel: Rating
    var sessionDuration: TimeInterval

    // Engagement
    var funRating: Rating
    var wouldPlayAgain: Bool
    var recommendToFriend: Bool

    enum Rating: Int {
        case veryPoor = 1
        case poor = 2
        case average = 3
        case good = 4
        case excellent = 5
    }
}
```

---

## Deployment & Distribution

### App Store Configuration

```yaml
Bundle ID: com.championshipsystems.spatialarena
Version: 1.0.0
Build: 1
Minimum OS: visionOS 2.0

Capabilities:
  - Immersive Space
  - Hand Tracking
  - ARKit
  - Networking (Multiplayer)
  - iCloud (Save sync)

Entitlements:
  - com.apple.developer.arkit
  - com.apple.developer.networking.multipath
  - com.apple.developer.icloud-container-identifiers

Privacy Permissions:
  - Camera Usage (ARKit) - "Required for spatial gameplay"
  - Local Network - "Required for multiplayer matches"
```

### Build Configurations

```swift
// Debug
SWIFT_OPTIMIZATION_LEVEL = -Onone
DEBUG_INFORMATION_FORMAT = dwarf-with-dsym
ENABLE_TESTABILITY = YES
ENABLE_PREVIEWS = YES

// Release
SWIFT_OPTIMIZATION_LEVEL = -O
SWIFT_COMPILATION_MODE = wholemodule
DEBUG_INFORMATION_FORMAT = dwarf-with-dsym
ENABLE_TESTABILITY = NO
ENABLE_PREVIEWS = NO
STRIP_SWIFT_SYMBOLS = YES

// Production
(Same as Release, plus:)
VALIDATE_PRODUCT = YES
CODE_SIGN_STYLE = Manual
```

### Continuous Integration

```yaml
# .github/workflows/build.yml
name: Build and Test

on: [push, pull_request]

jobs:
  build:
    runs-on: macos-14
    steps:
      - uses: actions/checkout@v3

      - name: Select Xcode
        run: sudo xcode-select -s /Applications/Xcode_16.0.app

      - name: Build
        run: xcodebuild -scheme SpatialArenaChampionship -sdk xros

      - name: Run Tests
        run: xcodebuild test -scheme SpatialArenaChampionship -sdk xros

      - name: Archive
        run: xcodebuild archive -scheme SpatialArenaChampionship -archivePath ./build/app.xcarchive
```

---

## Conclusion

This technical specification provides comprehensive implementation details for building Spatial Arena Championship. All systems are designed for:

- **Performance**: 90 FPS with <50ms latency
- **Scalability**: Support for 10+ players
- **Maintainability**: Modular architecture
- **Competitive Integrity**: Server authority and anti-cheat
- **Platform Optimization**: visionOS-native patterns

### Next Steps

1. Review ARCHITECTURE.md for system design
2. Review DESIGN.md for gameplay and UX details
3. Review IMPLEMENTATION_PLAN.md for development roadmap
4. Begin Phase 2: Project setup and implementation
