# Spatial Arena Championship - Technical Architecture

## Document Overview
This document defines the comprehensive technical architecture for Spatial Arena Championship, a competitive multiplayer arena game for Apple Vision Pro featuring room-scale combat, gesture-based abilities, and esports-grade performance.

**Version:** 1.0
**Last Updated:** 2025-11-19
**Target Platform:** visionOS 2.0+

---

## Table of Contents

1. [System Architecture Overview](#system-architecture-overview)
2. [visionOS Gaming Patterns](#visionos-gaming-patterns)
3. [Game Architecture](#game-architecture)
4. [Data Models & Schemas](#data-models--schemas)
5. [RealityKit Gaming Components](#realitykit-gaming-components)
6. [ARKit Integration](#arkit-integration)
7. [Multiplayer Architecture](#multiplayer-architecture)
8. [Physics & Collision Systems](#physics--collision-systems)
9. [Audio Architecture](#audio-architecture)
10. [Performance Optimization](#performance-optimization)
11. [Save/Load System](#saveload-system)
12. [Security & Anti-Cheat](#security--anti-cheat)

---

## System Architecture Overview

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Spatial Arena Championship                │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │   SwiftUI    │  │  RealityKit  │  │    ARKit     │      │
│  │   UI Layer   │  │  3D Render   │  │  Tracking    │      │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘      │
│         │                  │                  │              │
│  ┌──────┴──────────────────┴──────────────────┴───────┐     │
│  │           Game Coordinator & State Manager         │     │
│  └──────┬─────────────────┬─────────────────┬─────────┘     │
│         │                 │                 │                │
│  ┌──────┴──────┐   ┌──────┴──────┐   ┌─────┴──────┐        │
│  │   Game      │   │  Network    │   │   Audio    │        │
│  │   Systems   │   │  Manager    │   │   Engine   │        │
│  └─────────────┘   └─────────────┘   └────────────┘        │
│                                                               │
│  ┌──────────────────────────────────────────────────────┐   │
│  │              Entity Component System (ECS)           │   │
│  └──────────────────────────────────────────────────────┘   │
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

### Core Architectural Principles

1. **Entity-Component-System (ECS)**: RealityKit's native ECS for game objects
2. **Client-Server Model**: Authoritative server for competitive integrity
3. **Event-Driven**: Reactive architecture using Combine framework
4. **Performance-First**: 90 FPS target with <50ms input latency
5. **Spatial-Native**: Room-scale design from ground up

---

## visionOS Gaming Patterns

### Immersive Space Configuration

```swift
// Primary gaming environment
struct ArenaSpace {
    // Full immersive space for competitive gameplay
    var immersionStyle: ImmersionStyle = .full
    var upperLimbVisibility: UpperLimbVisibility = .visible

    // Arena dimensions
    let minPlaySpace: SIMD3<Float> = [2.0, 2.0, 2.5] // 2m x 2m x 2.5m
    let optimalPlaySpace: SIMD3<Float> = [3.0, 3.0, 2.5] // 3m x 3m x 2.5m
}
```

### Space Management Strategy

```
┌──────────────────────────────────────────────────────┐
│  App Launch                                           │
│  ├─> Window: Main Menu, Settings, Matchmaking        │
│  ├─> Volume: Character Selection Preview (optional)  │
│  └─> Immersive Space: Arena Combat                   │
│       ├─> Pre-Match: Tutorial, Warm-up              │
│       ├─> Active Match: Full immersion combat        │
│       └─> Post-Match: Victory/Defeat screens         │
└──────────────────────────────────────────────────────┘
```

### Window ↔ Immersive Space Transitions

- **Menu to Arena**: Smooth fade with spatial audio ramp-up
- **Arena to Menu**: Quick fade with results overlay
- **Emergency Exit**: Instant return to menu with safety pause

---

## Game Architecture

### Game Loop Architecture

```swift
class GameLoop {
    // Target: 90 FPS (11.1ms per frame)
    let targetFrameRate: Int = 90
    let fixedTimestep: Double = 1.0 / 90.0

    enum Phase {
        case input          // 1ms - Process player inputs
        case update         // 4ms - Game logic, physics prep
        case physics        // 3ms - Physics simulation
        case networking     // 1ms - Network sync
        case render         // 2ms - RealityKit rendering
    }

    // RealityKit Update Loop
    func update(deltaTime: TimeInterval) {
        processInput(deltaTime)
        updateGameState(deltaTime)
        updatePhysics(deltaTime)
        synchronizeNetwork(deltaTime)
        // Rendering handled by RealityKit
    }
}
```

### State Management Architecture

```
┌─────────────────────────────────────────────────┐
│              Game State Machine                  │
├─────────────────────────────────────────────────┤
│                                                  │
│  Launching → MainMenu → Matchmaking → InQueue   │
│                  ↑           ↓                   │
│                  │      MatchFound               │
│                  │           ↓                   │
│                  │      LoadingArena             │
│                  │           ↓                   │
│                  │      PreMatch (Countdown)     │
│                  │           ↓                   │
│                  │      ActiveMatch              │
│                  │           ↓                   │
│                  │      PostMatch (Results)      │
│                  └───────────┘                   │
│                                                  │
└─────────────────────────────────────────────────┘
```

### Game Coordinator Pattern

```swift
@Observable
class GameCoordinator {
    // Core managers
    let stateManager: GameStateManager
    let networkManager: NetworkManager
    let arenaManager: ArenaManager
    let inputManager: InputManager
    let audioManager: AudioManager
    let matchmaker: MatchmakingManager

    // Current game state
    var currentState: GameState
    var currentMatch: Match?
    var localPlayer: Player

    // Performance monitoring
    let performanceMonitor: PerformanceMonitor

    func transitionTo(_ newState: GameState) async {
        await stateManager.transition(to: newState)
        await updateSystemsForState(newState)
    }
}
```

### Entity-Component-System Architecture

```
Entities (Game Objects)
├─> Player Entity
│   ├─> TransformComponent (position, rotation)
│   ├─> PlayerComponent (stats, abilities)
│   ├─> HealthComponent (HP, shields)
│   ├─> CollisionComponent (hit detection)
│   ├─> InputComponent (gesture handlers)
│   └─> NetworkComponent (sync state)
│
├─> Projectile Entity
│   ├─> TransformComponent
│   ├─> VelocityComponent
│   ├─> DamageComponent
│   ├─> ParticleComponent (VFX)
│   └─> LifetimeComponent (auto-destroy)
│
├─> Arena Element Entity
│   ├─> TransformComponent
│   ├─> StaticMeshComponent
│   ├─> CollisionComponent
│   └─> TerritoryComponent (capture zones)
│
└─> PowerUp Entity
    ├─> TransformComponent
    ├─> RotationComponent (visual)
    ├─> PowerUpComponent (type, effect)
    └─> SpawnComponent (respawn logic)

Systems (Logic Processing)
├─> MovementSystem (player movement)
├─> AbilitySystem (gesture-based powers)
├─> CombatSystem (damage calculation)
├─> PhysicsSystem (collision, forces)
├─> NetworkSyncSystem (multiplayer)
├─> AudioSystem (spatial sound)
└─> UISystem (HUD updates)
```

---

## Data Models & Schemas

### Player Data Model

```swift
struct Player: Codable, Identifiable {
    let id: UUID
    var username: String
    var skillRating: Int
    var rank: Rank

    // Combat stats
    var health: Float
    var maxHealth: Float
    var shields: Float
    var maxShields: Float
    var energy: Float // For abilities

    // Abilities
    var primaryAbility: Ability
    var secondaryAbility: Ability
    var ultimateAbility: Ability
    var ultimateCharge: Float

    // Stats tracking
    var stats: PlayerStats
    var position: SIMD3<Float>
    var rotation: simd_quatf

    // Network sync
    var networkState: NetworkPlayerState
    var lastUpdateTimestamp: TimeInterval
}

struct PlayerStats: Codable {
    var kills: Int = 0
    var deaths: Int = 0
    var assists: Int = 0
    var damageDealt: Float = 0
    var damageTaken: Float = 0
    var objectivesCaptured: Int = 0
    var accuracy: Float = 0.0
}
```

### Match Data Model

```swift
struct Match: Codable, Identifiable {
    let id: UUID
    var matchType: MatchType
    var gameMode: GameMode
    var arenaTheme: ArenaTheme

    var team1: Team
    var team2: Team

    var state: MatchState
    var startTime: Date?
    var endTime: Date?
    var duration: TimeInterval

    var objectives: [Objective]
    var events: [MatchEvent]

    var winCondition: WinCondition
    var winner: Team?
}

enum MatchType: String, Codable {
    case casual
    case ranked
    case tournament
    case custom
}

enum GameMode: String, Codable {
    case elimination      // Last Warrior Standing
    case domination      // Territory Control
    case artifactHunt    // Capture & Hold Objects
    case teamElimination // Team Deathmatch
}

struct Team: Codable, Identifiable {
    let id: UUID
    var name: String
    var players: [Player]
    var score: Int
    var color: TeamColor
}
```

### Ability Data Model

```swift
struct Ability: Codable, Identifiable {
    let id: UUID
    var name: String
    var type: AbilityType
    var cooldown: TimeInterval
    var energyCost: Float

    var gesture: GesturePattern
    var effect: AbilityEffect
    var range: Float
    var duration: TimeInterval?

    var projectileConfig: ProjectileConfig?
    var areaEffectConfig: AreaEffectConfig?
}

enum AbilityType: String, Codable {
    case projectile      // Energy bolt
    case shield          // Barrier
    case areaEffect      // Zone damage/heal
    case mobility        // Dash, teleport
    case ultimate        // Room-filling power
}

struct GesturePattern: Codable {
    var handedness: Handedness
    var motionType: MotionType
    var recognitionThreshold: Float
}
```

### Arena Data Model

```swift
struct Arena: Codable, Identifiable {
    let id: UUID
    var name: String
    var theme: ArenaTheme

    // Physical space requirements
    var dimensions: SIMD3<Float>
    var safetyBoundary: Float // Padding from walls

    // Game elements
    var spawnPoints: [SpawnPoint]
    var objectiveZones: [ObjectiveZone]
    var powerUpSpawns: [PowerUpSpawn]
    var coverElements: [CoverElement]

    // Environment
    var lighting: LightingConfig
    var ambientAudio: AudioConfig
    var particleEffects: [ParticleEffect]
}

enum ArenaTheme: String, Codable {
    case cyberArena
    case ancientTemple
    case spaceStation
    case urbanWarfare
    case fantasyRealm
}
```

### Network Message Schema

```swift
// Client → Server
enum ClientMessage: Codable {
    case playerInput(PlayerInputData, timestamp: TimeInterval)
    case abilityActivation(abilityID: UUID, targetPosition: SIMD3<Float>)
    case ready
    case chatMessage(String)
}

// Server → Client
enum ServerMessage: Codable {
    case matchStart(Match)
    case worldState(WorldSnapshot)
    case playerUpdate([NetworkPlayerState])
    case matchEvent(MatchEvent)
    case matchEnd(MatchResult)
}

struct WorldSnapshot: Codable {
    var timestamp: TimeInterval
    var serverTick: UInt64
    var players: [NetworkPlayerState]
    var projectiles: [NetworkProjectileState]
    var objectives: [NetworkObjectiveState]
}
```

---

## RealityKit Gaming Components

### Custom Component System

```swift
// Player Component
struct PlayerComponent: Component {
    var playerID: UUID
    var team: TeamColor
    var abilities: [Ability]
    var stats: PlayerStats
}

// Health Component
struct HealthComponent: Component {
    var current: Float
    var maximum: Float
    var isAlive: Bool { current > 0 }
    var lastDamageTime: TimeInterval?
    var lastDamageSource: UUID?
}

// Velocity Component
struct VelocityComponent: Component {
    var linear: SIMD3<Float>
    var angular: SIMD3<Float>
    var maxSpeed: Float
}

// Projectile Component
struct ProjectileComponent: Component {
    var damage: Float
    var speed: Float
    var lifetime: TimeInterval
    var ownerID: UUID
    var team: TeamColor
    var ignoreList: Set<UUID> // Already hit entities
}

// Territory Component
struct TerritoryComponent: Component {
    var captureRadius: Float
    var captureProgress: Float
    var controllingTeam: TeamColor?
    var contestedBy: Set<TeamColor>
}

// Ability State Component
struct AbilityStateComponent: Component {
    var abilities: [AbilitySlot: AbilityState]
    var ultimateCharge: Float
}

struct AbilityState {
    var ability: Ability
    var cooldownRemaining: TimeInterval
    var isReady: Bool { cooldownRemaining <= 0 }
}
```

### System Architecture

```swift
// Movement System
struct MovementSystem: System {
    static let query = EntityQuery(where: .has(PlayerComponent.self) && .has(VelocityComponent.self))

    init(scene: Scene) {}

    func update(context: SceneUpdateContext) {
        for entity in context.entities(matching: Self.query, updatingSystemWhen: .rendering) {
            guard var velocity = entity.components[VelocityComponent.self],
                  var transform = entity.components[Transform.self] else { continue }

            // Apply velocity
            let displacement = velocity.linear * Float(context.deltaTime)
            transform.translation += displacement

            // Update entity
            entity.components[Transform.self] = transform
        }
    }
}

// Combat System
struct CombatSystem: System {
    static let query = EntityQuery(where: .has(ProjectileComponent.self))

    func update(context: SceneUpdateContext) {
        let projectiles = context.entities(matching: Self.query, updatingSystemWhen: .rendering)

        for projectile in projectiles {
            checkCollisions(projectile, context: context)
            updateLifetime(projectile, deltaTime: context.deltaTime)
        }
    }

    func checkCollisions(_ projectile: Entity, context: SceneUpdateContext) {
        // Physics-based collision detection
        // Apply damage on hit
        // Trigger VFX
    }
}

// Network Sync System
struct NetworkSyncSystem: System {
    let networkManager: NetworkManager
    var lastSyncTime: TimeInterval = 0
    let syncRate: TimeInterval = 1.0 / 30.0 // 30 Hz sync

    func update(context: SceneUpdateContext) {
        if context.time - lastSyncTime >= syncRate {
            syncPlayerStates(context: context)
            syncProjectiles(context: context)
            lastSyncTime = context.time
        }
    }
}
```

### Entity Factory Pattern

```swift
class EntityFactory {
    // Create player entity
    static func createPlayer(id: UUID, position: SIMD3<Float>, team: TeamColor) -> Entity {
        let entity = Entity()

        // Transform
        entity.position = position

        // Model (visual representation)
        let mesh = MeshResource.generateBox(size: [0.5, 1.8, 0.3])
        let material = SimpleMaterial(color: team.uiColor, isMetallic: false)
        entity.components[ModelComponent.self] = ModelComponent(mesh: mesh, materials: [material])

        // Physics
        let shape = ShapeResource.generateBox(size: [0.5, 1.8, 0.3])
        entity.components[CollisionComponent.self] = CollisionComponent(shapes: [shape])

        // Custom components
        entity.components[PlayerComponent.self] = PlayerComponent(playerID: id, team: team)
        entity.components[HealthComponent.self] = HealthComponent(current: 100, maximum: 100)
        entity.components[VelocityComponent.self] = VelocityComponent(maxSpeed: 3.0)

        return entity
    }

    // Create projectile entity
    static func createProjectile(owner: UUID, position: SIMD3<Float>, direction: SIMD3<Float>, team: TeamColor) -> Entity {
        let entity = Entity()

        entity.position = position

        // Visual
        let mesh = MeshResource.generateSphere(radius: 0.05)
        let material = SimpleMaterial(color: team.uiColor.withAlphaComponent(0.8), isMetallic: true)
        entity.components[ModelComponent.self] = ModelComponent(mesh: mesh, materials: [material])

        // Particle trail
        var particles = ParticleEmitterComponent()
        particles.emitterShape = .sphere
        particles.birthRate = 100
        particles.lifeSpan = 0.5
        entity.components[ParticleEmitterComponent.self] = particles

        // Physics
        let shape = ShapeResource.generateSphere(radius: 0.05)
        entity.components[CollisionComponent.self] = CollisionComponent(shapes: [shape])

        // Custom components
        entity.components[ProjectileComponent.self] = ProjectileComponent(
            damage: 20.0,
            speed: 10.0,
            lifetime: 5.0,
            ownerID: owner,
            team: team
        )

        let velocity = normalize(direction) * 10.0
        entity.components[VelocityComponent.self] = VelocityComponent(linear: velocity, maxSpeed: 10.0)

        return entity
    }
}
```

---

## ARKit Integration

### Room Scanning & Calibration

```swift
class ArenaCalibration {
    let arkitSession: ARKitSession
    let worldTracking: WorldTrackingProvider
    let sceneReconstruction: SceneReconstructionProvider

    func calibrateArena() async throws {
        // Start AR session
        try await arkitSession.run([worldTracking, sceneReconstruction])

        // Scan room dimensions
        let roomBounds = await scanRoomBounds()

        // Validate play space
        guard roomBounds.volume >= minPlaySpaceVolume else {
            throw ArenaError.insufficientSpace
        }

        // Define arena boundaries
        let arena = createArenaBoundaries(from: roomBounds)

        // Anchor arena to world
        await anchorArenaToWorld(arena)
    }

    func scanRoomBounds() async -> RoomBounds {
        // Use SceneReconstructionProvider to get mesh
        // Calculate playable area avoiding furniture
        // Return safe play space dimensions
    }
}
```

### Hand Tracking for Abilities

```swift
class HandTrackingManager {
    let handTracking: HandTrackingProvider

    func update() async {
        guard let leftHand = handTracking.leftHand,
              let rightHand = handTracking.rightHand else { return }

        // Gesture recognition
        detectPointingGesture(leftHand, rightHand)
        detectShieldGesture(leftHand, rightHand)
        detectUltimateGesture(leftHand, rightHand)
    }

    func detectPointingGesture(_ left: HandAnchor, _ right: HandAnchor) -> Bool {
        // Check if index finger extended, others curled
        // Get pointing direction for aiming
    }

    func detectShieldGesture(_ left: HandAnchor, _ right: HandAnchor) -> Bool {
        // Check for palm-forward pose
        // Both hands creating barrier
    }
}
```

### Eye Tracking for Targeting

```swift
class EyeTrackingManager {
    func getAimTarget() -> SIMD3<Float>? {
        // Get eye gaze direction
        // Raycast to find target point
        // Return hit position in world space
    }

    func getCrosshairPosition() -> CGPoint {
        // Get screen-space position for UI crosshair
    }
}
```

---

## Multiplayer Architecture

### Network Topology

```
         ┌─────────────────┐
         │  Game Server    │
         │  (Authoritative)│
         └────────┬─────────┘
                  │
      ┌───────────┼───────────┐
      │           │           │
┌─────┴─────┐ ┌──┴──────┐ ┌──┴──────┐
│ Client 1  │ │Client 2 │ │Client 3 │
│ (Player)  │ │(Player) │ │(Player) │
└───────────┘ └─────────┘ └─────────┘
```

### Network Manager Architecture

```swift
class NetworkManager: ObservableObject {
    let serverConnection: MCSession
    let serviceType = "arena-champ"

    @Published var connectionState: ConnectionState = .disconnected
    @Published var latency: TimeInterval = 0

    // Client → Server messaging
    func sendPlayerInput(_ input: PlayerInputData) {
        let message = ClientMessage.playerInput(input, timestamp: Date().timeIntervalSince1970)
        sendToServer(message)
    }

    func sendAbilityActivation(_ ability: Ability, target: SIMD3<Float>) {
        let message = ClientMessage.abilityActivation(abilityID: ability.id, targetPosition: target)
        sendToServer(message)
    }

    // Server → Client handling
    func handleServerMessage(_ message: ServerMessage) {
        switch message {
        case .worldState(let snapshot):
            reconcileWorldState(snapshot)
        case .matchEvent(let event):
            processMatchEvent(event)
        case .matchEnd(let result):
            handleMatchEnd(result)
        default:
            break
        }
    }
}
```

### Client-Side Prediction & Reconciliation

```swift
class PredictionSystem {
    var pendingInputs: [PlayerInputData] = []
    var lastProcessedInputSequence: UInt64 = 0

    // Optimistic local update
    func applyLocalInput(_ input: PlayerInputData) {
        pendingInputs.append(input)
        updateLocalPlayerState(with: input)
        sendToServer(input)
    }

    // Server reconciliation
    func reconcileWithServerState(_ serverState: NetworkPlayerState) {
        guard serverState.lastProcessedInput > lastProcessedInputSequence else { return }

        // Remove acknowledged inputs
        pendingInputs.removeAll { $0.sequence <= serverState.lastProcessedInput }

        // Check for prediction error
        if !stateMatches(serverState) {
            // Rewind and replay pending inputs
            rewindToServerState(serverState)
            replayPendingInputs()
        }

        lastProcessedInputSequence = serverState.lastProcessedInput
    }
}
```

### Lag Compensation

```swift
class LagCompensation {
    // Server rewinds game state for hit detection
    func validateHit(shooterID: UUID, targetID: UUID, timestamp: TimeInterval, position: SIMD3<Float>) -> Bool {
        // Rewind to shooter's timestamp (accounting for latency)
        let historicalState = getHistoricalWorldState(at: timestamp)

        // Check if hit was valid at that point in time
        return isHitValid(targetID: targetID, position: position, state: historicalState)
    }

    // Store historical states for rewinding
    var stateHistory: [TimeInterval: WorldSnapshot] = [:]
    let historyDuration: TimeInterval = 1.0 // Keep 1 second of history
}
```

### Matchmaking System

```swift
class MatchmakingManager {
    func findMatch(player: Player) async throws -> Match {
        // Add to matchmaking queue
        let ticket = createMatchmakingTicket(player)

        // AI-based skill matching
        let matchedPlayers = await aiMatchmaking.findPlayers(
            skillRating: player.skillRating,
            maxSkillDifference: 500,
            maxLatency: 50, // ms
            timeout: 60 // seconds
        )

        // Create balanced teams
        let teams = balanceTeams(matchedPlayers)

        // Create match
        return createMatch(teams: teams)
    }
}
```

---

## Physics & Collision Systems

### Physics Configuration

```swift
struct PhysicsConfig {
    static let gravity: SIMD3<Float> = [0, -9.81, 0]
    static let fixedTimestep: TimeInterval = 1.0 / 90.0
    static let maxSubsteps: Int = 3

    // Collision layers
    enum CollisionLayer: UInt32 {
        case player = 0b0001
        case projectile = 0b0010
        case environment = 0b0100
        case trigger = 0b1000
    }
}
```

### Collision Detection

```swift
class CollisionSystem {
    func update(context: SceneUpdateContext) {
        // Broadphase: Spatial hashing for efficient detection
        let potentialCollisions = spatialHash.query()

        // Narrowphase: Precise collision testing
        for (entityA, entityB) in potentialCollisions {
            if let collision = testCollision(entityA, entityB) {
                handleCollision(collision)
            }
        }
    }

    func handleCollision(_ collision: Collision) {
        let entityA = collision.entityA
        let entityB = collision.entityB

        // Projectile hitting player
        if let projectile = entityA.components[ProjectileComponent.self],
           var health = entityB.components[HealthComponent.self] {

            // Apply damage
            health.current -= projectile.damage
            health.lastDamageTime = Date().timeIntervalSince1970
            health.lastDamageSource = projectile.ownerID

            entityB.components[HealthComponent.self] = health

            // Destroy projectile
            entityA.scene?.removeEntity(entityA)

            // Trigger hit VFX
            spawnHitEffect(at: collision.position)
        }
    }
}
```

### Spatial Hashing for Performance

```swift
class SpatialHash {
    let cellSize: Float = 1.0
    var grid: [SIMD3<Int>: Set<Entity>] = [:]

    func insert(_ entity: Entity) {
        let cell = worldToCell(entity.position)
        grid[cell, default: []].insert(entity)
    }

    func query(around position: SIMD3<Float>, radius: Float) -> [Entity] {
        let cells = getCellsInRadius(position, radius)
        return cells.flatMap { grid[$0] ?? [] }
    }
}
```

---

## Audio Architecture

### Spatial Audio System

```swift
class SpatialAudioManager {
    let audioSession: AVAudioSession
    var soundSources: [UUID: AudioSource] = [:]

    func playSound(_ sound: Sound, at position: SIMD3<Float>, volume: Float = 1.0) {
        let source = AudioSource(sound: sound)
        source.position = position
        source.volume = volume
        source.spatialBlend = 1.0 // Full 3D
        source.play()

        soundSources[source.id] = source
    }

    func updateListenerPosition(_ position: SIMD3<Float>, orientation: simd_quatf) {
        // Update spatial audio listener (player's head)
        audioSession.listenerPosition = position
        audioSession.listenerOrientation = orientation
    }
}
```

### Audio Categories

```
Combat Sounds
├─> Weapon Fire (3D positioned)
├─> Explosions (3D + reverb)
├─> Hit Confirmation (localized)
└─> Shield Activation (player-local)

Environmental
├─> Arena Ambience (omnidirectional)
├─> Footsteps (3D positioned)
└─> Territory Capture (zone-based)

UI/Feedback
├─> Menu Navigation (non-spatial)
├─> Ability Ready (player-local)
└─> Countdown Timer (non-spatial)

Voice Chat
├─> Team Comms (spatial from avatar)
└─> Spectator Commentary (optional)

Music
├─> Menu Music (non-spatial)
├─> Combat Music (adaptive intensity)
└─> Victory/Defeat (non-spatial)
```

### Adaptive Audio

```swift
class AdaptiveAudioEngine {
    var combatIntensity: Float = 0.0 // 0.0 to 1.0

    func updateCombatIntensity() {
        // Calculate based on nearby enemies, health, objective state
        combatIntensity = calculateIntensity()

        // Adjust music layers
        musicController.setIntensity(combatIntensity)
    }

    func calculateIntensity() -> Float {
        let enemyProximity = nearbyEnemies.count > 0 ? 0.3 : 0.0
        let healthCritical = player.health < 30 ? 0.3 : 0.0
        let objectiveContested = currentObjective.isContested ? 0.4 : 0.0

        return min(enemyProximity + healthCritical + objectiveContested, 1.0)
    }
}
```

---

## Performance Optimization

### Target Performance Metrics

- **Frame Rate**: 90 FPS locked (no drops)
- **Input Latency**: <50ms from gesture to action
- **Network Latency**: <30ms to server
- **Memory**: <2GB total, <500MB per match
- **Battery**: >90 minutes active gameplay
- **Thermal**: No throttling during 15-minute matches

### Optimization Strategies

#### 1. Rendering Optimization

```swift
class RenderOptimizer {
    // Level of Detail (LOD) system
    func updateLOD(for entity: Entity, distance: Float) {
        if distance < 3.0 {
            entity.model?.mesh = highDetailMesh
        } else if distance < 10.0 {
            entity.model?.mesh = mediumDetailMesh
        } else {
            entity.model?.mesh = lowDetailMesh
        }
    }

    // Frustum culling (handled by RealityKit, but optimize entity count)
    func cullInvisibleEntities() {
        for entity in allEntities where !isInFrustum(entity) {
            entity.isEnabled = false
        }
    }

    // Particle budget management
    var maxParticles: Int = 5000
    var activeParticles: Int = 0
}
```

#### 2. Object Pooling

```swift
class ObjectPool<T> {
    private var available: [T] = []
    private var inUse: Set<ObjectIdentifier> = []
    private let factory: () -> T

    init(size: Int, factory: @escaping () -> T) {
        self.factory = factory
        available = (0..<size).map { _ in factory() }
    }

    func acquire() -> T {
        if available.isEmpty {
            return factory()
        }
        return available.removeFirst()
    }

    func release(_ object: T) {
        available.append(object)
    }
}

// Usage for projectiles
let projectilePool = ObjectPool<Entity>(size: 100) {
    EntityFactory.createProjectile(...)
}
```

#### 3. Network Bandwidth Optimization

```swift
struct NetworkOptimizer {
    // Delta compression
    func compressPlayerState(_ current: NetworkPlayerState, _ previous: NetworkPlayerState) -> Data {
        // Only send changed fields
        var delta = PlayerStateDelta()

        if current.position != previous.position {
            delta.position = current.position
        }

        if current.health != previous.health {
            delta.health = current.health
        }

        return try! JSONEncoder().encode(delta)
    }

    // Update rate scaling
    var updateRate: Int {
        switch connectionQuality {
        case .excellent: return 30 // 30 Hz
        case .good: return 20
        case .poor: return 15
        }
    }
}
```

#### 4. Memory Management

```swift
class MemoryManager {
    func optimizeMemory() {
        // Unload unused assets
        AssetCache.shared.purgeUnused()

        // Clear old match data
        clearMatchHistory(olderThan: 60) // Keep last minute

        // Texture compression
        enableTextureCompression()
    }

    func monitorMemory() {
        let used = memoryUsage()
        if used > memoryBudget * 0.9 {
            triggerMemoryWarning()
        }
    }
}
```

### Performance Monitoring

```swift
class PerformanceMonitor {
    @Published var fps: Double = 90.0
    @Published var frameTime: TimeInterval = 0.011
    @Published var networkLatency: TimeInterval = 0.020

    func update(deltaTime: TimeInterval) {
        fps = 1.0 / deltaTime
        frameTime = deltaTime

        // Alert if performance degrades
        if fps < 80 {
            logger.warning("FPS dropped to \(fps)")
            triggerPerformanceOptimization()
        }
    }
}
```

---

## Save/Load System

### Local Save Data

```swift
struct SaveData: Codable {
    var playerProfile: PlayerProfile
    var settings: GameSettings
    var statistics: CareerStatistics
    var unlocks: UnlockedContent
    var matchHistory: [MatchSummary]
}

struct PlayerProfile: Codable {
    let playerID: UUID
    var username: String
    var skillRating: Int
    var rank: Rank
    var level: Int
    var experience: Int
}

struct GameSettings: Codable {
    var audioSettings: AudioSettings
    var graphicsSettings: GraphicsSettings
    var controlSettings: ControlSettings
    var accessibilitySettings: AccessibilitySettings
}
```

### Save Manager

```swift
class SaveManager {
    private let fileManager = FileManager.default
    private let saveDirectory: URL

    func save(_ data: SaveData) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted

        let jsonData = try encoder.encode(data)
        try jsonData.write(to: saveFileURL())
    }

    func load() throws -> SaveData {
        let data = try Data(contentsOf: saveFileURL())
        let decoder = JSONDecoder()
        return try decoder.decode(SaveData.self, from: data)
    }

    private func saveFileURL() -> URL {
        saveDirectory.appendingPathComponent("save.json")
    }
}
```

### Cloud Sync (iCloud)

```swift
class CloudSyncManager {
    let container = NSUbiquitousKeyValueStore.default

    func syncToCloud(_ data: SaveData) {
        guard let jsonData = try? JSONEncoder().encode(data) else { return }
        container.set(jsonData, forKey: "playerData")
        container.synchronize()
    }

    func syncFromCloud() -> SaveData? {
        guard let jsonData = container.data(forKey: "playerData"),
              let data = try? JSONDecoder().decode(SaveData.self, from: jsonData) else {
            return nil
        }
        return data
    }
}
```

---

## Security & Anti-Cheat

### Client-Side Validation

```swift
class InputValidator {
    func validatePlayerInput(_ input: PlayerInputData) -> Bool {
        // Validate movement speed
        guard input.velocity.length() <= maxAllowedSpeed else {
            return false
        }

        // Validate ability usage (cooldowns, energy cost)
        guard canUseAbility(input.abilityID) else {
            return false
        }

        // Validate position (no teleporting)
        guard isPositionReachable(input.position, from: lastPosition) else {
            return false
        }

        return true
    }
}
```

### Server-Side Anti-Cheat

```swift
class ServerAntiCheat {
    func analyzePlayerBehavior(_ player: Player, _ actions: [PlayerAction]) {
        // Check for impossible reaction times
        if hasImpossibleReactionTime(actions) {
            flagSuspiciousActivity(player, reason: "Superhuman reaction")
        }

        // Check for aimbot patterns
        if hasAimbotPattern(actions) {
            flagSuspiciousActivity(player, reason: "Aim assistance detected")
        }

        // Check for movement hacks
        if hasImpossibleMovement(actions) {
            flagSuspiciousActivity(player, reason: "Speed/teleport hack")
        }
    }

    func hasImpossibleReactionTime(_ actions: [PlayerAction]) -> Bool {
        // Human minimum reaction time: ~100ms
        // Check for consistent <100ms reactions
    }
}
```

### Encryption

```swift
class EncryptionManager {
    func encryptMessage(_ message: Data) throws -> Data {
        // Use CryptoKit for encryption
        let key = SymmetricKey(size: .bits256)
        let sealedBox = try AES.GCM.seal(message, using: key)
        return sealedBox.combined!
    }

    func decryptMessage(_ encrypted: Data) throws -> Data {
        let key = SymmetricKey(size: .bits256)
        let sealedBox = try AES.GCM.SealedBox(combined: encrypted)
        return try AES.GCM.open(sealedBox, using: key)
    }
}
```

---

## Conclusion

This architecture provides a solid foundation for building Spatial Arena Championship as a competitive, performant, and engaging spatial gaming experience on Vision Pro. The modular design allows for iterative development and optimization while maintaining code quality and competitive integrity.

### Key Architectural Decisions

1. **ECS Architecture**: Leverages RealityKit's native system for performance
2. **Authoritative Server**: Ensures fair competitive gameplay
3. **Client Prediction**: Maintains responsive feel despite network latency
4. **Spatial-First Design**: Built for room-scale from the ground up
5. **Performance Budget**: 90 FPS target with strict monitoring
6. **Modular Systems**: Easy to test, iterate, and extend

### Next Steps

1. Review TECHNICAL_SPEC.md for implementation details
2. Review DESIGN.md for gameplay and UX specifications
3. Review IMPLEMENTATION_PLAN.md for development roadmap
4. Begin Phase 2: Project setup and core implementation
