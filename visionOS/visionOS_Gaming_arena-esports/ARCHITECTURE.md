# Arena Esports - Technical Architecture Document
*visionOS Professional Competitive Gaming Platform*

---

## Document Overview

**Version:** 1.0
**Last Updated:** 2025-11-19
**Status:** Design Phase
**Target Platform:** visionOS 2.0+ on Apple Vision Pro

---

## Table of Contents

1. [System Overview](#system-overview)
2. [Game Architecture](#game-architecture)
3. [visionOS-Specific Gaming Patterns](#visionos-specific-gaming-patterns)
4. [Data Models & Schemas](#data-models--schemas)
5. [RealityKit Gaming Components](#realitykit-gaming-components)
6. [ARKit Integration](#arkit-integration)
7. [Multiplayer Architecture](#multiplayer-architecture)
8. [Physics & Collision Systems](#physics--collision-systems)
9. [Audio Architecture](#audio-architecture)
10. [Performance Optimization](#performance-optimization)
11. [Save/Load System](#saveload-system)
12. [Testing Architecture](#testing-architecture)

---

## 1. System Overview

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        Arena Esports App                         │
├─────────────────────────────────────────────────────────────────┤
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │   SwiftUI    │  │  RealityKit  │  │    ARKit     │          │
│  │  UI Layer    │  │  3D Render   │  │   Tracking   │          │
│  └──────────────┘  └──────────────┘  └──────────────┘          │
├─────────────────────────────────────────────────────────────────┤
│                      Game Engine Core                            │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │  ECS System  │  │  Game Loop   │  │ State Manager│          │
│  └──────────────┘  └──────────────┘  └──────────────┘          │
├─────────────────────────────────────────────────────────────────┤
│                       Game Systems                               │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │   Physics    │  │   Input      │  │    Audio     │          │
│  │   System     │  │   System     │  │    System    │          │
│  └──────────────┘  └──────────────┘  └──────────────┘          │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │  Networking  │  │  Analytics   │  │  Anti-Cheat  │          │
│  │   System     │  │   System     │  │    System    │          │
│  └──────────────┘  └──────────────┘  └──────────────┘          │
├─────────────────────────────────────────────────────────────────┤
│                      Data & Services                             │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │  Tournament  │  │   Player     │  │   Spectator  │          │
│  │   Service    │  │   Profile    │  │   Service    │          │
│  └──────────────┘  └──────────────┘  └──────────────┘          │
└─────────────────────────────────────────────────────────────────┘
```

### Technology Stack

- **Language:** Swift 6.0+ with strict concurrency
- **UI Framework:** SwiftUI with visionOS spatial components
- **3D Rendering:** RealityKit with Metal acceleration
- **Spatial Tracking:** ARKit with ultra-low latency mode
- **Networking:** Swift Concurrency + WebRTC for real-time multiplayer
- **Audio:** AVFoundation Spatial Audio + RealityKit audio
- **Storage:** SwiftData for local persistence + CloudKit for sync
- **Analytics:** TelemetryDeck + custom performance metrics
- **Testing:** XCTest + XCUITest + Swift Testing framework

---

## 2. Game Architecture

### Entity-Component-System (ECS) Pattern

Arena Esports uses a modified ECS architecture optimized for competitive spatial gaming:

```swift
// Core ECS Interfaces

protocol Entity: Identifiable, Sendable {
    var id: UUID { get }
    var components: [any Component] { get set }
    var isActive: Bool { get set }
}

protocol Component: Sendable {
    var entityID: UUID { get }
}

protocol GameSystem: Sendable {
    func update(deltaTime: TimeInterval, entities: [any Entity]) async
    var priority: Int { get } // Higher priority systems run first
}
```

### Game Loop Architecture

```swift
@MainActor
final class GameLoop {
    private var displayLink: CADisplayLink?
    private var lastUpdateTime: TimeInterval = 0
    private let targetFPS: Double = 120.0 // Professional mode

    // System execution order
    private let systems: [any GameSystem] = [
        InputSystem(priority: 1000),
        PhysicsSystem(priority: 900),
        CombatSystem(priority: 800),
        NetworkSyncSystem(priority: 700),
        AudioSystem(priority: 600),
        RenderSystem(priority: 500)
    ]

    func start() {
        displayLink = CADisplayLink(target: self, selector: #selector(update))
        displayLink?.preferredFrameRateRange = CAFrameRateRange(
            minimum: 90,
            maximum: 120,
            preferred: 120
        )
        displayLink?.add(to: .main, forMode: .default)
    }

    @objc private func update() {
        let currentTime = CACurrentMediaTime()
        let deltaTime = currentTime - lastUpdateTime
        lastUpdateTime = currentTime

        Task {
            await updateSystems(deltaTime: deltaTime)
        }
    }

    private func updateSystems(deltaTime: TimeInterval) async {
        let entities = EntityManager.shared.activeEntities

        // Run systems in priority order
        for system in systems.sorted(by: { $0.priority > $1.priority }) {
            await system.update(deltaTime: deltaTime, entities: entities)
        }
    }
}
```

### State Management

```swift
@Observable
final class GameState {
    enum Phase: Sendable {
        case mainMenu
        case training
        case matchmaking
        case inMatch(matchID: UUID)
        case spectating(matchID: UUID)
        case tournament(tournamentID: UUID)
        case postMatch(results: MatchResults)
    }

    var currentPhase: Phase = .mainMenu
    var localPlayer: Player?
    var currentMatch: Match?
    var tournament: Tournament?

    // Performance metrics
    var currentFPS: Double = 0
    var latency: TimeInterval = 0
    var frameTime: TimeInterval = 0
}

// State machine for game flow
actor GameStateMachine {
    private(set) var state: GameState

    func transition(to newPhase: GameState.Phase) async throws {
        // Validate state transition
        guard canTransition(from: state.currentPhase, to: newPhase) else {
            throw GameError.invalidStateTransition
        }

        // Cleanup old state
        await cleanup(phase: state.currentPhase)

        // Setup new state
        state.currentPhase = newPhase
        await setup(phase: newPhase)
    }

    private func canTransition(from: GameState.Phase, to: GameState.Phase) -> Bool {
        // Implement state transition rules
        switch (from, to) {
        case (.mainMenu, .training): return true
        case (.mainMenu, .matchmaking): return true
        case (.matchmaking, .inMatch): return true
        case (.inMatch, .postMatch): return true
        default: return false
        }
    }
}
```

---

## 3. visionOS-Specific Gaming Patterns

### Immersive Space Management

```swift
@MainActor
final class ArenaSpaceManager {
    private var immersiveSpace: ImmersiveSpace?

    enum SpaceConfiguration {
        case training       // Controlled environment
        case competitive    // Full immersion
        case spectator      // Observer mode
    }

    func loadArenaSpace(config: SpaceConfiguration) async throws {
        switch config {
        case .training:
            immersiveSpace = await ImmersiveSpace(id: "TrainingArena") {
                TrainingArenaContent()
            }
        case .competitive:
            immersiveSpace = await ImmersiveSpace(id: "CompetitiveArena") {
                CompetitiveArenaContent()
                    .preferredDisplayMode(.progressive)
                    .upperLimbVisibility(.hidden) // Maximize immersion
            }
        case .spectator:
            immersiveSpace = await ImmersiveSpace(id: "SpectatorView") {
                SpectatorArenaContent()
            }
        }

        try await openImmersiveSpace(value: immersiveSpace)
    }
}
```

### Spatial Interaction Model

```swift
// Hand tracking for competitive precision
actor HandTrackingSystem: GameSystem {
    let priority = 1000

    private let handTracking = ARKitSession()
    private let handTrackingProvider = HandTrackingProvider()

    func update(deltaTime: TimeInterval, entities: [any Entity]) async {
        guard let anchors = handTrackingProvider.anchorUpdates else { return }

        for anchor in anchors {
            // Process hand joints for weapon aiming
            if let indexTip = anchor.handSkeleton?.joint(.indexFingerTip) {
                let aimDirection = indexTip.transform.forward
                await updateAiming(direction: aimDirection)
            }

            // Gesture recognition for tactical commands
            if let gesture = recognizeGesture(from: anchor) {
                await handleGesture(gesture)
            }
        }
    }

    private func recognizeGesture(from anchor: HandAnchor) -> TacticalGesture? {
        // Implement competitive gesture recognition
        // - Precision aim (point)
        // - Formation signal (open palm)
        // - Reload (specific motion)
        return nil // Placeholder
    }
}

// Eye tracking for target acquisition
actor EyeTrackingSystem: GameSystem {
    let priority = 999

    func update(deltaTime: TimeInterval, entities: [any Entity]) async {
        // Use eye tracking for rapid target acquisition
        // Supports competitive advantage while maintaining privacy
    }
}
```

---

## 4. Data Models & Schemas

### Core Game Models

```swift
// Player Model
struct Player: Identifiable, Codable, Sendable {
    let id: UUID
    var username: String
    var skillRating: Int // ELO-based ranking
    var statistics: PlayerStatistics
    var achievements: [Achievement]
    var team: Team?

    // Competitive settings
    var preferredRole: PlayerRole
    var sensitivitySettings: SensitivityProfile
}

struct PlayerStatistics: Codable, Sendable {
    var matchesPlayed: Int
    var wins: Int
    var losses: Int
    var averageAccuracy: Double
    var averageSpatialAwareness: Double
    var averageReactionTime: TimeInterval
    var totalKills: Int
    var totalDeaths: Int
}

// Team Model
struct Team: Identifiable, Codable, Sendable {
    let id: UUID
    var name: String
    var members: [Player.ID]
    var captain: Player.ID
    var rating: Int
    var logo: URL?
    var sponsors: [Sponsor]
}

// Match Model
struct Match: Identifiable, Codable, Sendable {
    let id: UUID
    var teams: [Team.ID]
    var arena: Arena
    var mode: GameMode
    var startTime: Date
    var duration: TimeInterval
    var status: MatchStatus
    var score: MatchScore
    var spectators: [Player.ID]

    enum MatchStatus: Codable, Sendable {
        case waiting
        case inProgress
        case paused
        case completed
        case cancelled
    }
}

struct Arena: Identifiable, Codable, Sendable {
    let id: UUID
    var name: String
    var type: ArenaType
    var dimensions: ArenaDimensions
    var obstacles: [Obstacle]
    var spawnPoints: [SpawnPoint]

    enum ArenaType: Codable, Sendable {
        case spherical360
        case verticalDominance
        case closeQuarters
        case longRange
    }
}

struct ArenaDimensions: Codable, Sendable {
    var radius: Float // For spherical arenas
    var height: Float
    var minPlayArea: SIMD2<Float> // Minimum physical space required
    var recommendedPlayArea: SIMD2<Float>
}

// Tournament Model
struct Tournament: Identifiable, Codable, Sendable {
    let id: UUID
    var name: String
    var type: TournamentType
    var prizePool: Decimal
    var teams: [Team.ID]
    var bracket: TournamentBracket
    var schedule: [Match]
    var status: TournamentStatus

    enum TournamentType: Codable, Sendable {
        case singleElimination
        case doubleElimination
        case roundRobin
        case swiss
    }
}
```

### Component Models

```swift
// Transform Component (position in 3D space)
struct TransformComponent: Component {
    let entityID: UUID
    var position: SIMD3<Float>
    var rotation: simd_quatf
    var scale: SIMD3<Float> = SIMD3(1, 1, 1)

    var transform: Transform {
        Transform(
            translation: position,
            rotation: rotation,
            scale: scale
        )
    }
}

// Health Component
struct HealthComponent: Component {
    let entityID: UUID
    var current: Float
    var maximum: Float
    var regenerationRate: Float
    var lastDamageTime: TimeInterval

    var isAlive: Bool { current > 0 }
    var healthPercentage: Float { current / maximum }
}

// Weapon Component
struct WeaponComponent: Component {
    let entityID: UUID
    var weaponType: WeaponType
    var damage: Float
    var accuracy: Float
    var fireRate: TimeInterval
    var ammo: Int
    var maxAmmo: Int
    var lastFireTime: TimeInterval

    enum WeaponType: Codable, Sendable {
        case spatialRifle
        case pulseBlaster
        case gravityLauncher
        case energySword
    }
}

// Combat Component
struct CombatComponent: Component {
    let entityID: UUID
    var team: Int
    var isInCombat: Bool
    var lastAttacker: UUID?
    var damageMultiplier: Float = 1.0
}

// Physics Component
struct PhysicsComponent: Component {
    let entityID: UUID
    var velocity: SIMD3<Float>
    var acceleration: SIMD3<Float>
    var mass: Float
    var friction: Float
    var hasGravity: Bool
}
```

---

## 5. RealityKit Gaming Components

### Custom RealityKit Components

```swift
// Player Entity
final class PlayerEntity: Entity {
    required init() {
        super.init()
        setupComponents()
    }

    private func setupComponents() {
        // Visual representation
        components.set(ModelComponent(
            mesh: .generateBox(size: [0.5, 1.8, 0.5]),
            materials: [SimpleMaterial(color: .blue, isMetallic: true)]
        ))

        // Physics for collision
        components.set(PhysicsBodyComponent(
            massProperties: .default,
            mode: .dynamic
        ))

        components.set(CollisionComponent(
            shapes: [.generateCapsule(height: 1.8, radius: 0.25)]
        ))

        // Spatial audio
        components.set(SpatialAudioComponent())

        // Custom game components
        components.set(HealthComponent(
            entityID: id,
            current: 100,
            maximum: 100,
            regenerationRate: 5.0,
            lastDamageTime: 0
        ))

        components.set(WeaponComponent(
            entityID: id,
            weaponType: .spatialRifle,
            damage: 25,
            accuracy: 0.95,
            fireRate: 0.1,
            ammo: 30,
            maxAmmo: 30,
            lastFireTime: 0
        ))
    }
}

// Arena Entity
final class ArenaEntity: Entity {
    func generateSphericalArena(radius: Float) {
        // Create 360-degree spherical battlefield
        let arenaShell = ModelComponent(
            mesh: .generateSphere(radius: radius),
            materials: [createArenaMaterial()]
        )
        components.set(arenaShell)

        // Add collision boundaries
        components.set(CollisionComponent(
            shapes: [.generateSphere(radius: radius)],
            mode: .trigger
        ))

        // Environmental effects
        addEnvironmentalLighting()
        addSpatialAudio()
        addSpawnPoints()
    }

    private func createArenaMaterial() -> PhysicallyBasedMaterial {
        var material = PhysicallyBasedMaterial()
        material.baseColor = .init(tint: .cyan.withAlphaComponent(0.3))
        material.emissiveColor = .init(color: .cyan)
        material.emissiveIntensity = 0.5
        material.roughness = 0.2
        material.metallic = 0.8
        return material
    }
}
```

### RealityKit Systems

```swift
// Render System
final class RenderSystem: RealityKit.System {
    static let query = EntityQuery(where: .has(ModelComponent.self))

    init(scene: Scene) {}

    func update(context: SceneUpdateContext) {
        // Optimize rendering for 90-120 FPS
        context.entities(matching: Self.query).forEach { entity in
            // Level of Detail (LOD) based on distance
            adjustLOD(for: entity, context: context)

            // Frustum culling
            if !isInFrustum(entity, context: context) {
                entity.isEnabled = false
            } else {
                entity.isEnabled = true
            }
        }
    }

    private func adjustLOD(for entity: Entity, context: SceneUpdateContext) {
        guard var model = entity.components[ModelComponent.self] else { return }

        let distance = simd_distance(entity.position, context.cameraPosition)

        // Adjust mesh quality based on distance
        if distance > 10 {
            model.mesh = model.mesh.simplified(factor: 0.5)
        } else if distance > 5 {
            model.mesh = model.mesh.simplified(factor: 0.75)
        }

        entity.components[ModelComponent.self] = model
    }
}
```

---

## 6. ARKit Integration

### Spatial Tracking Configuration

```swift
final class SpatialTrackingManager {
    private let session = ARKitSession()
    private var worldTracking: WorldTrackingProvider?
    private var handTracking: HandTrackingProvider?
    private var planeDetection: PlaneDetectionProvider?

    func startCompetitiveTracking() async throws {
        // Ultra-low latency configuration for competitive play
        let config = WorldTrackingProvider.Configuration(
            preferredLatency: .minimal,
            worldAlignment: .gravityAndHeading,
            sceneReconstruction: .disabled // Disable for performance
        )

        worldTracking = WorldTrackingProvider(configuration: config)
        handTracking = HandTrackingProvider()

        // Start tracking
        try await session.run([
            worldTracking!,
            handTracking!
        ])
    }

    func calibratePlaySpace() async throws -> PlaySpaceCalibration {
        planeDetection = PlaneDetectionProvider()
        try await session.run([planeDetection!])

        // Wait for floor plane detection
        var floorPlane: PlaneAnchor?
        for await anchor in planeDetection!.anchorUpdates {
            if anchor.classification == .floor {
                floorPlane = anchor
                break
            }
        }

        guard let floor = floorPlane else {
            throw CalibrationError.noFloorDetected
        }

        return PlaySpaceCalibration(
            floorHeight: floor.transform.columns.3.y,
            dimensions: floor.geometry.extent
        )
    }
}

struct PlaySpaceCalibration {
    let floorHeight: Float
    let dimensions: SIMD3<Float>

    var meetsCompetitiveStandards: Bool {
        dimensions.x >= 2.0 && dimensions.z >= 2.0
    }
}
```

---

## 7. Multiplayer Architecture

### Network Layer

```swift
// Network protocol
enum NetworkMessage: Codable {
    case playerJoined(playerID: UUID, username: String)
    case playerLeft(playerID: UUID)
    case stateSync(gameState: NetworkGameState)
    case playerAction(action: PlayerAction)
    case combatEvent(event: CombatEvent)
    case matchStart
    case matchEnd(results: MatchResults)
}

struct NetworkGameState: Codable {
    var timestamp: TimeInterval
    var entities: [NetworkEntity]
    var serverTick: UInt64
}

// Ultra-low latency networking
actor NetworkManager {
    private var webRTCConnection: RTCPeerConnection?
    private var dataChannel: RTCDataChannel?

    private let targetLatency: TimeInterval = 0.010 // 10ms target

    func connect(to server: URL) async throws {
        // Establish WebRTC connection for minimal latency
        let config = RTCConfiguration()
        config.iceServers = [
            RTCIceServer(urlStrings: ["stun:stun.l.google.com:19302"])
        ]

        webRTCConnection = RTCPeerConnection(configuration: config)

        // Create unreliable data channel for low-latency state sync
        let dataChannelConfig = RTCDataChannelConfiguration()
        dataChannelConfig.isOrdered = false // Allow out-of-order for speed
        dataChannelConfig.maxRetransmits = 0 // No retransmits

        dataChannel = webRTCConnection?.dataChannel(
            forLabel: "game_state",
            configuration: dataChannelConfig
        )
    }

    func sendAction(_ action: PlayerAction) async throws {
        let message = NetworkMessage.playerAction(action: action)
        let data = try JSONEncoder().encode(message)

        // Send with highest priority
        dataChannel?.sendData(RTCDataBuffer(
            data: data,
            isBinary: true
        ))
    }

    func receiveUpdates() async throws -> AsyncStream<NetworkMessage> {
        AsyncStream { continuation in
            dataChannel?.delegate = NetworkDataChannelDelegate(
                onMessage: { data in
                    if let message = try? JSONDecoder().decode(NetworkMessage.self, from: data) {
                        continuation.yield(message)
                    }
                }
            )
        }
    }
}

// Client-side prediction for responsive gameplay
actor PredictionSystem {
    private var pendingActions: [PlayerAction] = []
    private var lastServerState: NetworkGameState?

    func predictLocalAction(_ action: PlayerAction) {
        // Apply action immediately on client
        applyAction(action)
        pendingActions.append(action)
    }

    func reconcileWithServer(state: NetworkGameState) {
        // Server reconciliation
        lastServerState = state

        // Rewind to server state
        applyServerState(state)

        // Replay pending actions
        for action in pendingActions {
            applyAction(action)
        }

        // Remove confirmed actions
        pendingActions.removeAll { $0.timestamp <= state.timestamp }
    }
}
```

### Lag Compensation

```swift
// Server-side lag compensation
actor LagCompensationSystem {
    private var stateHistory: [TimeInterval: NetworkGameState] = [:]
    private let historyDuration: TimeInterval = 1.0

    func validateHit(
        shooterID: UUID,
        targetID: UUID,
        timestamp: TimeInterval,
        shooterLatency: TimeInterval
    ) -> Bool {
        // Rewind game state to shooter's perceived time
        let compensatedTime = timestamp - shooterLatency

        guard let historicalState = getState(at: compensatedTime) else {
            return false
        }

        // Check if hit was valid at that point in time
        return isHitValid(
            shooterID: shooterID,
            targetID: targetID,
            state: historicalState
        )
    }

    private func getState(at time: TimeInterval) -> NetworkGameState? {
        // Find closest historical state
        stateHistory
            .sorted { abs($0.key - time) < abs($1.key - time) }
            .first?
            .value
    }
}
```

---

## 8. Physics & Collision Systems

### Physics Engine

```swift
final class PhysicsSystem: GameSystem {
    let priority = 900

    private let gravity: SIMD3<Float> = [0, -9.81, 0]

    func update(deltaTime: TimeInterval, entities: [any Entity]) async {
        let physicsEntities = entities.filter {
            $0.components[PhysicsComponent.self] != nil
        }

        for entity in physicsEntities {
            await updatePhysics(entity: entity, deltaTime: deltaTime)
            await detectCollisions(entity: entity, others: physicsEntities)
        }
    }

    private func updatePhysics(entity: any Entity, deltaTime: TimeInterval) async {
        guard var physics = entity.components[PhysicsComponent.self],
              var transform = entity.components[TransformComponent.self] else {
            return
        }

        // Apply gravity
        if physics.hasGravity {
            physics.acceleration += gravity
        }

        // Update velocity
        physics.velocity += physics.acceleration * Float(deltaTime)

        // Apply friction
        physics.velocity *= (1.0 - physics.friction * Float(deltaTime))

        // Update position
        transform.position += physics.velocity * Float(deltaTime)

        // Reset acceleration
        physics.acceleration = .zero

        // Update components
        entity.components[PhysicsComponent.self] = physics
        entity.components[TransformComponent.self] = transform
    }
}

// Spatial partitioning for efficient collision detection
final class SpatialGrid {
    private let cellSize: Float
    private var cells: [SIMD3<Int>: [UUID]] = [:]

    init(cellSize: Float = 2.0) {
        self.cellSize = cellSize
    }

    func insert(entity: UUID, at position: SIMD3<Float>) {
        let cell = worldToCell(position)
        cells[cell, default: []].append(entity)
    }

    func query(near position: SIMD3<Float>, radius: Float) -> [UUID] {
        let cell = worldToCell(position)
        let cellRadius = Int(ceil(radius / cellSize))

        var results: [UUID] = []
        for x in -cellRadius...cellRadius {
            for y in -cellRadius...cellRadius {
                for z in -cellRadius...cellRadius {
                    let queryCell = SIMD3(cell.x + x, cell.y + y, cell.z + z)
                    results.append(contentsOf: cells[queryCell] ?? [])
                }
            }
        }
        return results
    }

    private func worldToCell(_ position: SIMD3<Float>) -> SIMD3<Int> {
        SIMD3(
            Int(floor(position.x / cellSize)),
            Int(floor(position.y / cellSize)),
            Int(floor(position.z / cellSize))
        )
    }
}
```

---

## 9. Audio Architecture

### Spatial Audio System

```swift
final class AudioSystem: GameSystem {
    let priority = 600

    private var audioEngine: AVAudioEngine
    private var environmentNode: AVAudioEnvironmentNode
    private var sources: [UUID: AVAudioPlayerNode] = [:]

    init() {
        audioEngine = AVAudioEngine()
        environmentNode = audioEngine.environmentNode

        // Configure for spatial gaming
        environmentNode.reverbParameters.enable = true
        environmentNode.reverbParameters.level = 10
        environmentNode.distanceAttenuationParameters.distanceAttenuationModel = .inverse

        audioEngine.prepare()
        try? audioEngine.start()
    }

    func update(deltaTime: TimeInterval, entities: [any Entity]) async {
        // Update listener position (player)
        if let player = entities.first(where: { $0 is PlayerEntity }),
           let transform = player.components[TransformComponent.self] {
            audioEngine.listenerPosition = AVAudio3DPoint(
                x: transform.position.x,
                y: transform.position.y,
                z: transform.position.z
            )
        }

        // Update all audio sources
        for entity in entities {
            guard let transform = entity.components[TransformComponent.self] else {
                continue
            }

            if let source = sources[entity.id] {
                source.position = AVAudio3DPoint(
                    x: transform.position.x,
                    y: transform.position.y,
                    z: transform.position.z
                )
            }
        }
    }

    func playSound(_ sound: GameSound, at position: SIMD3<Float>, volume: Float = 1.0) {
        let player = AVAudioPlayerNode()
        audioEngine.attach(player)
        audioEngine.connect(player, to: environmentNode, format: sound.format)

        player.position = AVAudio3DPoint(x: position.x, y: position.y, z: position.z)
        player.volume = volume

        player.scheduleBuffer(sound.buffer, completionHandler: {
            player.stop()
            self.audioEngine.detach(player)
        })

        player.play()
    }
}

enum GameSound {
    case weaponFire
    case weaponHit
    case footstep
    case jump
    case death
    case victory
    case teamComm

    var buffer: AVAudioPCMBuffer {
        // Load from assets
        fatalError("Load audio buffer")
    }

    var format: AVAudioFormat {
        buffer.format
    }
}
```

---

## 10. Performance Optimization

### Frame Rate Management

```swift
final class PerformanceMonitor {
    private var frameTimes: [TimeInterval] = []
    private let maxSamples = 120

    var currentFPS: Double {
        guard !frameTimes.isEmpty else { return 0 }
        let averageFrameTime = frameTimes.reduce(0, +) / Double(frameTimes.count)
        return 1.0 / averageFrameTime
    }

    func recordFrame(deltaTime: TimeInterval) {
        frameTimes.append(deltaTime)
        if frameTimes.count > maxSamples {
            frameTimes.removeFirst()
        }

        // Alert if performance drops
        if currentFPS < 90 {
            notifyPerformanceIssue()
        }
    }

    private func notifyPerformanceIssue() {
        // Trigger performance optimization
        PerformanceOptimizer.shared.reduceLOD()
    }
}

actor PerformanceOptimizer {
    static let shared = PerformanceOptimizer()

    private var currentQualityLevel: QualityLevel = .professional

    enum QualityLevel {
        case professional  // 120 FPS, highest quality
        case competitive   // 90 FPS, balanced
        case practice      // 60 FPS, reduced quality
    }

    func reduceLOD() {
        // Dynamically adjust quality to maintain frame rate
        switch currentQualityLevel {
        case .professional:
            currentQualityLevel = .competitive
        case .competitive:
            currentQualityLevel = .practice
        case .practice:
            break // Already at minimum
        }
    }
}
```

### Memory Management

```swift
final class AssetCache {
    static let shared = AssetCache()

    private var cache: NSCache<NSString, AnyObject>

    init() {
        cache = NSCache()
        cache.totalCostLimit = 500 * 1024 * 1024 // 500 MB
    }

    func load<T: AnyObject>(key: String, loader: () -> T) -> T {
        if let cached = cache.object(forKey: key as NSString) as? T {
            return cached
        }

        let object = loader()
        cache.setObject(object, forKey: key as NSString)
        return object
    }
}
```

---

## 11. Save/Load System

### Data Persistence

```swift
import SwiftData

@Model
final class PlayerProgress {
    @Attribute(.unique) var playerID: UUID
    var level: Int
    var experience: Int
    var statistics: Data // Encoded PlayerStatistics
    var unlocks: [String]
    var lastPlayed: Date

    init(playerID: UUID) {
        self.playerID = playerID
        self.level = 1
        self.experience = 0
        self.statistics = Data()
        self.unlocks = []
        self.lastPlayed = Date()
    }
}

actor SaveSystem {
    private let modelContext: ModelContext

    func saveProgress(_ player: Player) async throws {
        let progress = PlayerProgress(playerID: player.id)
        progress.level = calculateLevel(from: player.statistics)
        progress.experience = calculateExperience(from: player.statistics)
        progress.statistics = try JSONEncoder().encode(player.statistics)
        progress.lastPlayed = Date()

        modelContext.insert(progress)
        try modelContext.save()
    }

    func loadProgress(playerID: UUID) async throws -> Player? {
        let descriptor = FetchDescriptor<PlayerProgress>(
            predicate: #Predicate { $0.playerID == playerID }
        )

        guard let progress = try modelContext.fetch(descriptor).first else {
            return nil
        }

        var player = Player(id: playerID, username: "")
        player.statistics = try JSONDecoder().decode(
            PlayerStatistics.self,
            from: progress.statistics
        )

        return player
    }
}
```

---

## 12. Testing Architecture

### Testing Strategy

```swift
// Unit Testing
@testable import ArenaEsports
import XCTest

final class GameSystemTests: XCTestCase {
    func testPhysicsSystem() async {
        let system = PhysicsSystem()
        let entity = TestEntity()

        entity.components.append(PhysicsComponent(
            entityID: entity.id,
            velocity: .zero,
            acceleration: [0, -9.81, 0],
            mass: 1.0,
            friction: 0.1,
            hasGravity: true
        ))

        await system.update(deltaTime: 1.0, entities: [entity])

        let physics = entity.components[PhysicsComponent.self]
        XCTAssertEqual(physics?.velocity.y, -9.81, accuracy: 0.01)
    }
}

// Performance Testing
final class PerformanceTests: XCTestCase {
    func testRenderPerformance() {
        measure(metrics: [XCTClockMetric(), XCTMemoryMetric()]) {
            // Test rendering 1000 entities
            let entities = (0..<1000).map { _ in PlayerEntity() }
            // Render frame
        }
    }

    func testNetworkLatency() async {
        let manager = NetworkManager()

        let start = CACurrentMediaTime()
        try? await manager.sendAction(.move(direction: .zero))
        let latency = CACurrentMediaTime() - start

        XCTAssertLessThan(latency, 0.010) // Less than 10ms
    }
}

// Integration Testing
final class MultiplayerTests: XCTestCase {
    func testMatchFlow() async throws {
        let match = Match(/* ... */)
        let players = [Player(), Player()]

        // Test complete match flow
        await match.start()
        XCTAssertEqual(match.status, .inProgress)

        // Simulate gameplay
        for _ in 0..<100 {
            await match.update(deltaTime: 0.016) // 60 FPS
        }

        await match.end()
        XCTAssertEqual(match.status, .completed)
    }
}
```

---

## Conclusion

This architecture provides a solid foundation for Arena Esports:

- **Scalable ECS architecture** for complex gameplay systems
- **Ultra-low latency networking** for competitive integrity
- **visionOS-optimized rendering** for 90-120 FPS performance
- **Spatial computing integration** for immersive 360-degree combat
- **Comprehensive testing** for reliability and quality

Next steps:
1. Review and validate architecture
2. Create detailed technical specifications
3. Begin implementation with core systems
4. Iterate based on performance testing

---

**Document Status:** Draft - Ready for Review
**Next Document:** TECHNICAL_SPEC.md
