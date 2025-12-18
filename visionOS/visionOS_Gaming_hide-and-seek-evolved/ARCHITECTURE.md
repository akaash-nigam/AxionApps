# Hide and Seek Evolved - Technical Architecture

**Version:** 1.0
**Platform:** Apple Vision Pro (visionOS 2.0+)
**Last Updated:** January 2025

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [Game Architecture](#game-architecture)
3. [visionOS Spatial Patterns](#visionos-spatial-patterns)
4. [Data Models & Schemas](#data-models--schemas)
5. [RealityKit Components & Systems](#realitykit-components--systems)
6. [ARKit Integration](#arkit-integration)
7. [Multiplayer Architecture](#multiplayer-architecture)
8. [Physics & Collision Systems](#physics--collision-systems)
9. [Audio Architecture](#audio-architecture)
10. [Performance Optimization](#performance-optimization)
11. [Save/Load System](#saveload-system)
12. [AI & Game Intelligence](#ai--game-intelligence)

---

## Architecture Overview

### High-Level Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                     Application Layer                        │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │ SwiftUI Views│  │ Game Screens │  │   HUD/UI     │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                    Game Logic Layer                          │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │ Game Loop    │  │ State Manager│  │ Event System │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │ Hide Manager │  │ Seek Manager │  │ AI Balancer  │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                   Systems Layer (ECS)                        │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │ Input System │  │ Physics Sys  │  │ Audio System │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │ Render System│  │ Safety System│  │ Network Sys  │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                    Platform Layer                            │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │  RealityKit  │  │    ARKit     │  │   AVAudio    │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │  SwiftUI     │  │ GroupActivities│ GameController│      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└─────────────────────────────────────────────────────────────┘
```

### Core Architectural Principles

1. **Entity-Component-System (ECS)**: Leverages RealityKit's ECS architecture for game entities
2. **Reactive State Management**: Unidirectional data flow using Combine framework
3. **Spatial-First Design**: All mechanics designed around physical space interaction
4. **Safety-Critical Architecture**: Safety systems have highest priority in execution pipeline
5. **Performance-Optimized**: Target 90 FPS with <20ms motion-to-photon latency
6. **Testable Design**: Clear separation of concerns for comprehensive testing

---

## Game Architecture

### Game Loop

The main game loop runs at 90Hz synchronized with display refresh:

```swift
// GameLoop.swift
actor GameLoop {
    private var displayLink: CADisplayLink?
    private var lastUpdateTime: TimeInterval = 0
    private let targetFPS: Double = 90

    private let stateManager: GameStateManager
    private let physicsSystem: PhysicsSystem
    private let audioSystem: AudioSystem
    private let safetySystem: SafetySystem

    func start() {
        displayLink = CADisplayLink(
            target: self,
            selector: #selector(update)
        )
        displayLink?.add(to: .main, forMode: .common)
        displayLink?.preferredFramesPerSecond = Int(targetFPS)
    }

    @MainActor
    @objc private func update(_ displayLink: CADisplayLink) {
        let deltaTime = displayLink.timestamp - lastUpdateTime
        lastUpdateTime = displayLink.timestamp

        // Fixed update order for deterministic behavior
        Task {
            // Priority 1: Safety checks (must run first)
            await safetySystem.update(deltaTime: deltaTime)

            // Priority 2: Input processing
            await inputSystem.processInput()

            // Priority 3: Game logic
            await stateManager.update(deltaTime: deltaTime)

            // Priority 4: Physics simulation
            await physicsSystem.simulate(deltaTime: deltaTime)

            // Priority 5: Audio updates
            await audioSystem.update(deltaTime: deltaTime)

            // Priority 6: Rendering (handled by RealityKit)
            // RealityKit handles rendering automatically
        }
    }
}
```

### State Management

Game state managed through finite state machine:

```swift
// GameStateManager.swift
enum GameState: Equatable {
    case mainMenu
    case roomScanning
    case playerSetup
    case roleSelection
    case hiding(timeRemaining: TimeInterval)
    case seeking(timeRemaining: TimeInterval)
    case roundEnd(winner: PlayerRole)
    case gameOver(results: GameResults)
    case paused(previousState: GameState)
}

@MainActor
class GameStateManager: ObservableObject {
    @Published private(set) var currentState: GameState = .mainMenu
    @Published private(set) var players: [Player] = []
    @Published private(set) var currentRound: Int = 0

    private let eventBus: EventBus
    private let persistenceManager: PersistenceManager

    func transition(to newState: GameState) async {
        let oldState = currentState
        currentState = newState

        // Emit state change event
        await eventBus.emit(.stateChanged(from: oldState, to: newState))

        // Perform state-specific setup
        await handleStateEntry(newState)
    }

    private func handleStateEntry(_ state: GameState) async {
        switch state {
        case .hiding(let timeRemaining):
            await startHidingPhase(duration: timeRemaining)
        case .seeking(let timeRemaining):
            await startSeekingPhase(duration: timeRemaining)
        case .roundEnd(let winner):
            await processRoundEnd(winner: winner)
        default:
            break
        }
    }
}
```

### Event System

Centralized event bus for decoupled communication:

```swift
// EventBus.swift
enum GameEvent {
    case stateChanged(from: GameState, to: GameState)
    case playerHidden(Player)
    case playerFound(Player, foundBy: Player)
    case abilityActivated(Ability, by: Player)
    case boundaryViolation(Player, location: SIMD3<Float>)
    case achievementUnlocked(Achievement, for: Player)
}

actor EventBus {
    private var subscribers: [UUID: (GameEvent) async -> Void] = [:]

    func subscribe(_ handler: @escaping (GameEvent) async -> Void) -> UUID {
        let id = UUID()
        subscribers[id] = handler
        return id
    }

    func unsubscribe(_ id: UUID) {
        subscribers.removeValue(forKey: id)
    }

    func emit(_ event: GameEvent) async {
        for handler in subscribers.values {
            await handler(event)
        }
    }
}
```

---

## visionOS Spatial Patterns

### Immersive Space Management

The game uses a full immersive space for gameplay:

```swift
// ImmersiveSpaceManager.swift
@MainActor
class ImmersiveSpaceManager: ObservableObject {
    @Published private(set) var isImmersiveSpaceActive = false

    private let immersiveSpaceID = "GameplaySpace"

    func enterImmersiveSpace(
        using openImmersiveSpace: OpenImmersiveSpaceAction
    ) async throws {
        switch await openImmersiveSpace(id: immersiveSpaceID) {
        case .opened:
            isImmersiveSpaceActive = true
        case .error, .userCancelled:
            throw ImmersiveSpaceError.failedToOpen
        @unknown default:
            throw ImmersiveSpaceError.unknown
        }
    }

    func exitImmersiveSpace(
        using dismissImmersiveSpace: DismissImmersiveSpaceAction
    ) async {
        await dismissImmersiveSpace()
        isImmersiveSpaceActive = false
    }
}
```

### RealityView Integration

Main gameplay view using RealityView:

```swift
// GameplayView.swift
struct GameplayView: View {
    @StateObject private var gameManager: GameManager
    @State private var rootEntity = Entity()

    var body: some View {
        RealityView { content in
            // Add root entity to scene
            content.add(rootEntity)

            // Setup scene
            await gameManager.setupScene(rootEntity: rootEntity)
        } update: { content in
            // Update scene based on game state
            await gameManager.updateScene(rootEntity: rootEntity)
        }
        .gesture(
            SpatialTapGesture()
                .targetedToAnyEntity()
                .onEnded { value in
                    gameManager.handleTap(on: value.entity)
                }
        )
        .overlay(alignment: .top) {
            GameHUDView(gameManager: gameManager)
        }
    }
}
```

---

## Data Models & Schemas

### Core Data Models

```swift
// Player.swift
struct Player: Identifiable, Codable {
    let id: UUID
    var name: String
    var role: PlayerRole
    var position: SIMD3<Float>
    var orientation: simd_quatf
    var activeAbilities: [Ability]
    var stats: PlayerStats
    var avatarConfiguration: AvatarConfig
}

enum PlayerRole: String, Codable {
    case hider
    case seeker
}

struct PlayerStats: Codable {
    var totalGamesPlayed: Int = 0
    var gamesWon: Int = 0
    var totalHideTime: TimeInterval = 0
    var totalSeekTime: TimeInterval = 0
    var successfulHides: Int = 0
    var successfulSeeks: Int = 0
}

// Ability.swift
enum Ability: Codable {
    case camouflage(opacity: Float)
    case sizeManipulation(scale: Float)
    case thermalVision(range: Float)
    case clueDetection(sensitivity: Float)
    case soundMasking(effectiveness: Float)

    var cooldownDuration: TimeInterval {
        switch self {
        case .camouflage: return 30
        case .sizeManipulation: return 45
        case .thermalVision: return 20
        case .clueDetection: return 15
        case .soundMasking: return 25
        }
    }
}

// Room.swift
struct RoomLayout: Codable {
    let id: UUID
    var scannedDate: Date
    var bounds: BoundingBox
    var furniture: [FurnitureItem]
    var safetyBoundaries: [SafetyBoundary]
    var hidingSpots: [HidingSpot]
}

struct FurnitureItem: Identifiable, Codable {
    let id: UUID
    var type: FurnitureType
    var position: SIMD3<Float>
    var size: SIMD3<Float>
    var orientation: simd_quatf
    var hidingPotential: Float // 0.0 - 1.0
}

enum FurnitureType: String, Codable {
    case sofa, chair, table, desk
    case cabinet, shelf, bookshelf
    case bed, dresser, wardrobe
    case plant, decoration
}

struct HidingSpot: Identifiable, Codable {
    let id: UUID
    var location: SIMD3<Float>
    var quality: Float // 0.0 - 1.0
    var accessibility: AccessibilityLevel
    var associatedFurniture: UUID?
}

enum AccessibilityLevel: String, Codable {
    case easy      // All ages and abilities
    case moderate  // Requires some mobility
    case difficult // Requires good mobility
}

// Game Session
struct GameSession: Codable {
    let id: UUID
    var startTime: Date
    var endTime: Date?
    var players: [Player]
    var rounds: [Round]
    var roomLayout: RoomLayout
    var settings: GameSettings
}

struct Round: Codable {
    let roundNumber: Int
    var startTime: Date
    var endTime: Date?
    var hiders: [UUID] // Player IDs
    var seekers: [UUID] // Player IDs
    var winner: PlayerRole?
    var events: [RoundEvent]
}

struct RoundEvent: Codable {
    let timestamp: Date
    let type: EventType
    let playerId: UUID?
    let details: String
}

enum EventType: String, Codable {
    case playerHidden
    case playerFound
    case abilityUsed
    case boundaryViolation
    case roundTimeExpired
}
```

---

## RealityKit Components & Systems

### Custom Components

```swift
// PlayerComponent.swift
struct PlayerComponent: Component, Codable {
    var playerId: UUID
    var role: PlayerRole
    var isVisible: Bool = true
    var opacity: Float = 1.0
    var scale: Float = 1.0
}

// HidingSpotComponent.swift
struct HidingSpotComponent: Component, Codable {
    var spotId: UUID
    var quality: Float
    var isOccupied: Bool = false
    var occupantId: UUID?
}

// CamouflageComponent.swift
struct CamouflageComponent: Component, Codable {
    var isActive: Bool = false
    var targetOpacity: Float = 0.1
    var transitionDuration: TimeInterval = 2.0
    var remainingDuration: TimeInterval = 0
}

// SafetyBoundaryComponent.swift
struct SafetyBoundaryComponent: Component, Codable {
    var boundaryPoints: [SIMD3<Float>]
    var warningDistance: Float = 0.5
    var hardBoundaryDistance: Float = 0.1
}
```

### Custom Systems

```swift
// CamouflageSystem.swift
struct CamouflageSystem: System {
    static let query = EntityQuery(
        where: .has(PlayerComponent.self) && .has(CamouflageComponent.self)
    )

    init(scene: Scene) {}

    func update(context: SceneUpdateContext) {
        for entity in context.entities(matching: Self.query, updatingSystemWhen: .rendering) {
            guard var camouflage = entity.components[CamouflageComponent.self],
                  camouflage.isActive else { continue }

            // Update opacity
            if var model = entity.components[ModelComponent.self] {
                let currentOpacity = model.materials.first?.baseColor.tint.alpha ?? 1.0
                let targetOpacity = camouflage.targetOpacity

                // Smooth transition
                let newOpacity = lerp(
                    currentOpacity,
                    targetOpacity,
                    t: Float(context.deltaTime / camouflage.transitionDuration)
                )

                // Update material
                for i in 0..<model.materials.count {
                    var material = model.materials[i]
                    if var physicallyBased = material as? PhysicallyBasedMaterial {
                        physicallyBased.baseColor.tint.alpha = newOpacity
                        model.materials[i] = physicallyBased
                    }
                }

                entity.components[ModelComponent.self] = model
            }

            // Update remaining duration
            camouflage.remainingDuration -= context.deltaTime
            if camouflage.remainingDuration <= 0 {
                camouflage.isActive = false
            }
            entity.components[CamouflageComponent.self] = camouflage
        }
    }
}

// Helper function
private func lerp(_ a: Float, _ b: Float, t: Float) -> Float {
    return a + (b - a) * t
}
```

---

## ARKit Integration

### World Tracking & Scene Understanding

```swift
// SpatialTrackingManager.swift
@MainActor
class SpatialTrackingManager: ObservableObject {
    private var arKitSession: ARKitSession?
    private var worldTrackingProvider: WorldTrackingProvider?
    private var sceneReconstructionProvider: SceneReconstructionProvider?
    private var handTrackingProvider: HandTrackingProvider?

    @Published private(set) var roomLayout: RoomLayout?
    @Published private(set) var trackingState: TrackingState = .notStarted

    func startTracking() async throws {
        let session = ARKitSession()
        let worldTracking = WorldTrackingProvider()
        let sceneReconstruction = SceneReconstructionProvider()
        let handTracking = HandTrackingProvider()

        try await session.run([
            worldTracking,
            sceneReconstruction,
            handTracking
        ])

        self.arKitSession = session
        self.worldTrackingProvider = worldTracking
        self.sceneReconstructionProvider = sceneReconstruction
        self.handTrackingProvider = handTracking

        trackingState = .tracking

        // Start processing scene updates
        await processSceneUpdates()
    }

    private func processSceneUpdates() async {
        guard let provider = sceneReconstructionProvider else { return }

        for await update in provider.anchorUpdates {
            switch update.event {
            case .added, .updated:
                await processAnchor(update.anchor)
            case .removed:
                await removeAnchor(update.anchor)
            }
        }
    }

    private func processAnchor(_ anchor: SceneReconstructionProvider.Anchor) async {
        // Classify furniture and update room layout
        let furnitureType = classifyMesh(anchor.geometry)

        let furnitureItem = FurnitureItem(
            id: UUID(),
            type: furnitureType,
            position: SIMD3(anchor.transform.columns.3.x,
                           anchor.transform.columns.3.y,
                           anchor.transform.columns.3.z),
            size: estimateSize(from: anchor.geometry),
            orientation: extractOrientation(from: anchor.transform),
            hidingPotential: calculateHidingPotential(furnitureType, anchor.geometry)
        )

        // Update room layout
        if roomLayout == nil {
            roomLayout = RoomLayout(
                id: UUID(),
                scannedDate: Date(),
                bounds: BoundingBox(min: .zero, max: .zero),
                furniture: [],
                safetyBoundaries: [],
                hidingSpots: []
            )
        }

        roomLayout?.furniture.append(furnitureItem)

        // Generate hiding spots
        let hidingSpots = generateHidingSpots(for: furnitureItem)
        roomLayout?.hidingSpots.append(contentsOf: hidingSpots)
    }

    private func classifyMesh(_ geometry: MeshAnchor.Geometry) -> FurnitureType {
        // Use heuristics based on size and shape
        let boundingBox = geometry.extent

        // Simple classification logic (would be more sophisticated in production)
        if boundingBox.y < 0.5 && boundingBox.x > 1.0 {
            return .table
        } else if boundingBox.y > 0.8 && boundingBox.y < 1.2 {
            return .chair
        } else if boundingBox.y > 0.4 && boundingBox.x > 1.5 {
            return .sofa
        } else {
            return .decoration
        }
    }

    private func calculateHidingPotential(
        _ type: FurnitureType,
        _ geometry: MeshAnchor.Geometry
    ) -> Float {
        let baseQuality: Float

        switch type {
        case .sofa, .bed, .wardrobe: baseQuality = 0.9
        case .table, .desk, .cabinet: baseQuality = 0.7
        case .chair, .shelf: baseQuality = 0.5
        case .plant, .decoration: baseQuality = 0.3
        default: baseQuality = 0.4
        }

        // Adjust based on size (larger = better hiding)
        let volume = geometry.extent.x * geometry.extent.y * geometry.extent.z
        let sizeBonus = min(volume / 2.0, 0.2) // Cap at +0.2

        return min(baseQuality + sizeBonus, 1.0)
    }
}
```

### Occlusion Detection

```swift
// OcclusionDetector.swift
actor OcclusionDetector {
    private let sceneUnderstanding: SceneUnderstandingProvider

    func isOccluded(
        from viewerPosition: SIMD3<Float>,
        target: SIMD3<Float>,
        in scene: Scene
    ) async -> Bool {
        // Perform raycast from viewer to target
        let direction = normalize(target - viewerPosition)
        let distance = length(target - viewerPosition)

        let origin = viewerPosition
        let raycastResult = scene.raycast(
            origin: origin,
            direction: direction,
            length: distance,
            query: .all
        )

        // Check if any mesh blocks line of sight
        for result in raycastResult {
            if result.distance < distance - 0.1 { // Small tolerance
                return true // Something is blocking the view
            }
        }

        return false
    }

    func calculateVisibilityPercentage(
        from viewerPosition: SIMD3<Float>,
        target playerEntity: Entity,
        samplePoints: Int = 9
    ) async -> Float {
        guard let bounds = playerEntity.visualBounds(relativeTo: nil) else {
            return 0.0
        }

        var visiblePoints = 0
        let samplePositions = generateSamplePoints(in: bounds, count: samplePoints)

        for samplePos in samplePositions {
            let isVisible = await !isOccluded(
                from: viewerPosition,
                target: samplePos,
                in: playerEntity.scene!
            )
            if isVisible {
                visiblePoints += 1
            }
        }

        return Float(visiblePoints) / Float(samplePoints)
    }

    private func generateSamplePoints(
        in bounds: BoundingBox,
        count: Int
    ) -> [SIMD3<Float>] {
        // Generate grid of sample points within bounding box
        var points: [SIMD3<Float>] = []
        let gridSize = Int(ceil(pow(Double(count), 1.0/3.0)))

        for x in 0..<gridSize {
            for y in 0..<gridSize {
                for z in 0..<gridSize {
                    let t = SIMD3<Float>(
                        Float(x) / Float(gridSize - 1),
                        Float(y) / Float(gridSize - 1),
                        Float(z) / Float(gridSize - 1)
                    )
                    let point = bounds.min + (bounds.max - bounds.min) * t
                    points.append(point)
                }
            }
        }

        return Array(points.prefix(count))
    }
}
```

---

## Multiplayer Architecture

### Local Multiplayer using GroupActivities

```swift
// MultiplayerManager.swift
import GroupActivities

struct HideAndSeekActivity: GroupActivity {
    static let activityIdentifier = "com.hideandseek.game"

    var metadata: GroupActivityMetadata {
        var metadata = GroupActivityMetadata()
        metadata.title = "Hide and Seek Evolved"
        metadata.type = .generic
        return metadata
    }
}

@MainActor
class MultiplayerManager: ObservableObject {
    @Published private(set) var groupSession: GroupSession<HideAndSeekActivity>?
    @Published private(set) var messenger: GroupSessionMessenger?
    @Published private(set) var connectedPlayers: [Player] = []

    private var tasks = Set<Task<Void, Never>>()

    func startGroupActivity() async throws {
        let activity = HideAndSeekActivity()

        switch await activity.prepareForActivation() {
        case .activationPreferred:
            _ = try await activity.activate()
        case .activationDisabled:
            throw MultiplayerError.activationDisabled
        case .cancelled:
            throw MultiplayerError.cancelled
        @unknown default:
            break
        }
    }

    func configureGroupSession() async {
        for await session in HideAndSeekActivity.sessions() {
            groupSession = session
            messenger = GroupSessionMessenger(session: session)

            session.join()

            // Handle session events
            await handleSessionEvents(session)
        }
    }

    private func handleSessionEvents(_ session: GroupSession<HideAndSeekActivity>) async {
        // Monitor participants
        for await participants in session.$activeParticipants.values {
            await updateConnectedPlayers(participants)
        }
    }

    func sendGameState(_ state: GameStateUpdate) async throws {
        guard let messenger = messenger else {
            throw MultiplayerError.noMessenger
        }

        try await messenger.send(state)
    }

    func receiveGameStateUpdates() async {
        guard let messenger = messenger else { return }

        for await (message, _) in messenger.messages(of: GameStateUpdate.self) {
            await handleGameStateUpdate(message)
        }
    }
}

// Network Messages
struct GameStateUpdate: Codable {
    let timestamp: Date
    let playerStates: [PlayerState]
    let gamePhase: GameState
}

struct PlayerState: Codable {
    let playerId: UUID
    let position: SIMD3<Float>
    let orientation: simd_quatf
    let activeAbilities: [Ability]
    let isHidden: Bool
}
```

---

## Physics & Collision Systems

### Physics Configuration

```swift
// PhysicsSystem.swift
actor PhysicsSystem {
    private var physicsWorld: PhysicsWorld

    func setup(scene: Scene) {
        // Configure physics world
        physicsWorld = PhysicsWorld()
        physicsWorld.gravity = SIMD3(0, -9.81, 0) // Real gravity for realism
    }

    func addPlayerPhysics(to entity: Entity) {
        // Player collision shape (capsule)
        let shape = ShapeResource.generateCapsule(
            height: 1.7,
            radius: 0.3
        )

        let physicsMaterial = PhysicsMaterialResource.generate(
            staticFriction: 0.3,
            dynamicFriction: 0.2,
            restitution: 0.0
        )

        entity.components[PhysicsBodyComponent.self] = PhysicsBodyComponent(
            shapes: [shape],
            mass: 70.0, // Average person weight
            material: physicsMaterial,
            mode: .kinematic // Player controlled, not physics-driven
        )

        entity.components[CollisionComponent.self] = CollisionComponent(
            shapes: [shape],
            mode: .trigger, // Detect collisions but don't physically collide
            filter: CollisionFilter(
                group: .player,
                mask: [.furniture, .boundary]
            )
        )
    }

    func addFurniturePhysics(to entity: Entity, size: SIMD3<Float>) {
        let shape = ShapeResource.generateBox(size: size)

        entity.components[PhysicsBodyComponent.self] = PhysicsBodyComponent(
            shapes: [shape],
            mass: 0, // Static object
            mode: .static
        )

        entity.components[CollisionComponent.self] = CollisionComponent(
            shapes: [shape],
            mode: .default,
            filter: CollisionFilter(
                group: .furniture,
                mask: [.player]
            )
        )
    }
}

// Collision Groups
extension CollisionFilter.Group {
    static let player = CollisionFilter.Group(rawValue: 1 << 0)
    static let furniture = CollisionFilter.Group(rawValue: 1 << 1)
    static let boundary = CollisionFilter.Group(rawValue: 1 << 2)
    static let hidingSpot = CollisionFilter.Group(rawValue: 1 << 3)
}
```

---

## Audio Architecture

### Spatial Audio System

```swift
// SpatialAudioManager.swift
@MainActor
class SpatialAudioManager: ObservableObject {
    private var audioEngine: AVAudioEngine
    private var environment: AVAudioEnvironmentNode
    private var sources: [UUID: AVAudioPlayerNode] = [:]

    init() {
        audioEngine = AVAudioEngine()
        environment = AVAudioEnvironmentNode()

        audioEngine.attach(environment)
        audioEngine.connect(
            environment,
            to: audioEngine.mainMixerNode,
            format: nil
        )

        // Configure spatial audio
        environment.listenerPosition = AVAudio3DPoint(x: 0, y: 0, z: 0)
        environment.listenerAngularOrientation = AVAudio3DAngularOrientation(
            yaw: 0,
            pitch: 0,
            roll: 0
        )

        do {
            try audioEngine.start()
        } catch {
            print("Failed to start audio engine: \(error)")
        }
    }

    func play3DSound(
        _ soundName: String,
        at position: SIMD3<Float>,
        for playerId: UUID,
        volume: Float = 1.0
    ) {
        guard let url = Bundle.main.url(
            forResource: soundName,
            withExtension: "wav"
        ) else { return }

        do {
            let file = try AVAudioFile(forReading: url)
            let player = AVAudioPlayerNode()

            audioEngine.attach(player)
            audioEngine.connect(player, to: environment, format: file.processingFormat)

            // Set 3D position
            player.position = AVAudio3DPoint(
                x: position.x,
                y: position.y,
                z: position.z
            )

            player.volume = volume
            player.scheduleFile(file, at: nil)
            player.play()

            sources[playerId] = player
        } catch {
            print("Failed to play sound: \(error)")
        }
    }

    func updateListenerPosition(_ position: SIMD3<Float>, orientation: simd_quatf) {
        environment.listenerPosition = AVAudio3DPoint(
            x: position.x,
            y: position.y,
            z: position.z
        )

        // Convert quaternion to Euler angles for listener orientation
        let euler = quaternionToEuler(orientation)
        environment.listenerAngularOrientation = AVAudio3DAngularOrientation(
            yaw: euler.yaw,
            pitch: euler.pitch,
            roll: euler.roll
        )
    }

    private func quaternionToEuler(_ q: simd_quatf) -> (yaw: Float, pitch: Float, roll: Float) {
        // Convert quaternion to Euler angles
        let yaw = atan2(2.0 * (q.vector.y * q.vector.z + q.vector.w * q.vector.x),
                       q.vector.w * q.vector.w - q.vector.x * q.vector.x - q.vector.y * q.vector.y + q.vector.z * q.vector.z)
        let pitch = asin(-2.0 * (q.vector.x * q.vector.z - q.vector.w * q.vector.y))
        let roll = atan2(2.0 * (q.vector.x * q.vector.y + q.vector.w * q.vector.z),
                        q.vector.w * q.vector.w + q.vector.x * q.vector.x - q.vector.y * q.vector.y - q.vector.z * q.vector.z)

        return (yaw, pitch, roll)
    }
}
```

---

## Performance Optimization

### Rendering Optimization

```swift
// PerformanceMonitor.swift
@MainActor
class PerformanceMonitor: ObservableObject {
    @Published private(set) var currentFPS: Double = 90
    @Published private(set) var frameTime: Double = 0
    @Published private(set) var memoryUsage: UInt64 = 0

    private var frameTimestamps: [TimeInterval] = []
    private let maxSamples = 60

    func recordFrame(timestamp: TimeInterval) {
        frameTimestamps.append(timestamp)

        if frameTimestamps.count > maxSamples {
            frameTimestamps.removeFirst()
        }

        if frameTimestamps.count > 1 {
            let totalTime = frameTimestamps.last! - frameTimestamps.first!
            let averageFPS = Double(frameTimestamps.count - 1) / totalTime
            currentFPS = averageFPS
            frameTime = totalTime / Double(frameTimestamps.count - 1) * 1000 // ms
        }
    }

    func checkPerformance() {
        if currentFPS < 72 {
            // Performance degraded, reduce quality
            reduceLOD()
        } else if currentFPS > 85 && frameTime < 10 {
            // Performance headroom, can increase quality
            increaseLOD()
        }
    }

    private func reduceLOD() {
        // Reduce level of detail for distant objects
        // Reduce particle count
        // Simplify materials
    }

    private func increaseLOD() {
        // Increase visual quality
    }
}

// LOD System
struct LODComponent: Component {
    var levels: [ModelComponent] = []
    var currentLevel: Int = 0
    var distances: [Float] = [5, 10, 20] // Distance thresholds
}

struct LODSystem: System {
    static let query = EntityQuery(where: .has(LODComponent.self))

    init(scene: Scene) {}

    func update(context: SceneUpdateContext) {
        guard let cameraPosition = context.scene.camera?.position else { return }

        for entity in context.entities(matching: Self.query, updatingSystemWhen: .rendering) {
            guard var lod = entity.components[LODComponent.self] else { continue }

            let distance = length(entity.position - cameraPosition)
            var newLevel = 0

            for (index, threshold) in lod.distances.enumerated() {
                if distance > threshold {
                    newLevel = min(index + 1, lod.levels.count - 1)
                }
            }

            if newLevel != lod.currentLevel {
                lod.currentLevel = newLevel
                entity.components[ModelComponent.self] = lod.levels[newLevel]
                entity.components[LODComponent.self] = lod
            }
        }
    }
}
```

---

## Save/Load System

### Persistence Manager

```swift
// PersistenceManager.swift
actor PersistenceManager {
    private let fileManager = FileManager.default
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    private var documentsDirectory: URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    // Save game session
    func saveSession(_ session: GameSession) async throws {
        let url = documentsDirectory
            .appendingPathComponent("sessions")
            .appendingPathComponent("\(session.id).json")

        // Create directory if needed
        try fileManager.createDirectory(
            at: url.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )

        let data = try encoder.encode(session)
        try data.write(to: url)
    }

    // Load game session
    func loadSession(id: UUID) async throws -> GameSession {
        let url = documentsDirectory
            .appendingPathComponent("sessions")
            .appendingPathComponent("\(id).json")

        let data = try Data(contentsOf: url)
        return try decoder.decode(GameSession.self, from: data)
    }

    // Save room layout
    func saveRoomLayout(_ layout: RoomLayout) async throws {
        let url = documentsDirectory
            .appendingPathComponent("rooms")
            .appendingPathComponent("\(layout.id).json")

        try fileManager.createDirectory(
            at: url.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )

        let data = try encoder.encode(layout)
        try data.write(to: url)
    }

    // Load most recent room layout
    func loadMostRecentRoomLayout() async throws -> RoomLayout? {
        let roomsDir = documentsDirectory.appendingPathComponent("rooms")

        guard fileManager.fileExists(atPath: roomsDir.path) else {
            return nil
        }

        let files = try fileManager.contentsOfDirectory(at: roomsDir, includingPropertiesForKeys: [.creationDateKey])

        guard let mostRecent = files.max(by: { file1, file2 in
            let date1 = try? file1.resourceValues(forKeys: [.creationDateKey]).creationDate
            let date2 = try? file2.resourceValues(forKeys: [.creationDateKey]).creationDate
            return (date1 ?? .distantPast) < (date2 ?? .distantPast)
        }) else {
            return nil
        }

        let data = try Data(contentsOf: mostRecent)
        return try decoder.decode(RoomLayout.self, from: data)
    }

    // Save player profile
    func savePlayerProfile(_ player: Player) async throws {
        let url = documentsDirectory
            .appendingPathComponent("players")
            .appendingPathComponent("\(player.id).json")

        try fileManager.createDirectory(
            at: url.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )

        let data = try encoder.encode(player)
        try data.write(to: url)
    }
}
```

---

## AI & Game Intelligence

### Fairness Balancing System

```swift
// AIBalancingSystem.swift
actor AIBalancingSystem {
    private let hidingSpotAnalyzer: HidingSpotAnalyzer
    private let playerSkillTracker: PlayerSkillTracker

    func balanceHidingOpportunities(
        for players: [Player],
        in roomLayout: RoomLayout
    ) async -> [UUID: [HidingSpot]] {
        var assignments: [UUID: [HidingSpot]] = [:]

        for player in players where player.role == .hider {
            let skill = await playerSkillTracker.getSkillLevel(for: player.id)
            let accessibility = determineAccessibility(for: player)

            // Find suitable hiding spots
            let suitableSpots = roomLayout.hidingSpots.filter { spot in
                spot.accessibility.isAccessible(for: accessibility) &&
                spot.quality >= (1.0 - skill) * 0.5 // Harder spots for skilled players
            }

            assignments[player.id] = suitableSpots
        }

        return assignments
    }

    func generateHints(
        for seeker: Player,
        targets: [Player],
        elapsed: TimeInterval,
        maxTime: TimeInterval
    ) async -> [Hint] {
        var hints: [Hint] = []

        // More generous hints as time runs out
        let timeRatio = elapsed / maxTime
        let hintLevel = Int(timeRatio * 3) // 0, 1, 2, 3 levels

        let skill = await playerSkillTracker.getSkillLevel(for: seeker.id)

        for target in targets {
            if hintLevel >= 1 || skill < 0.3 {
                // General direction hint
                hints.append(.direction(target.position))
            }

            if hintLevel >= 2 || skill < 0.2 {
                // Distance hint
                let distance = length(target.position - seeker.position)
                hints.append(.distance(distance))
            }

            if hintLevel >= 3 || skill < 0.1 {
                // Very specific hint
                hints.append(.hotCold(target.position))
            }
        }

        return hints
    }

    private func determineAccessibility(for player: Player) -> AccessibilityRequirement {
        // Could integrate with health data, age, preferences
        return .moderate
    }
}

enum Hint {
    case direction(SIMD3<Float>)
    case distance(Float)
    case hotCold(SIMD3<Float>)
    case visual(Entity) // Highlight an area
}

enum AccessibilityRequirement {
    case easy, moderate, difficult
}

extension AccessibilityLevel {
    func isAccessible(for requirement: AccessibilityRequirement) -> Bool {
        switch (self, requirement) {
        case (.easy, _): return true
        case (.moderate, .moderate), (.moderate, .difficult): return true
        case (.difficult, .difficult): return true
        default: return false
        }
    }
}

// Player Skill Tracking
actor PlayerSkillTracker {
    private var skillLevels: [UUID: Float] = [:]

    func getSkillLevel(for playerId: UUID) -> Float {
        return skillLevels[playerId] ?? 0.5 // Default to medium skill
    }

    func updateSkillLevel(
        for playerId: UUID,
        based performance: GamePerformance
    ) {
        let current = skillLevels[playerId] ?? 0.5
        let adjustment = performance.successRate - 0.5 // -0.5 to +0.5
        let newSkill = max(0, min(1, current + adjustment * 0.1))
        skillLevels[playerId] = newSkill
    }
}

struct GamePerformance {
    let successRate: Float
    let averageTime: TimeInterval
    let errorsCount: Int
}
```

---

## Testing Architecture

All systems are designed to be testable:

```swift
// Example Unit Test
@testable import HideAndSeekEvolved
import XCTest

final class GameStateManagerTests: XCTestCase {
    var sut: GameStateManager!
    var mockEventBus: MockEventBus!

    override func setUp() async throws {
        mockEventBus = MockEventBus()
        sut = GameStateManager(eventBus: mockEventBus)
    }

    func testStateTransition_fromMainMenuToRoomScanning() async throws {
        // Given
        XCTAssertEqual(sut.currentState, .mainMenu)

        // When
        await sut.transition(to: .roomScanning)

        // Then
        XCTAssertEqual(sut.currentState, .roomScanning)
        XCTAssertEqual(mockEventBus.emittedEvents.count, 1)
    }
}
```

---

## Conclusion

This architecture provides:

1. **Scalability**: Entity-Component-System allows easy addition of new features
2. **Performance**: Optimized for 90 FPS with LOD and adaptive quality
3. **Testability**: Clean separation of concerns and dependency injection
4. **Safety**: Safety systems have highest priority in execution pipeline
5. **Maintainability**: Clear structure and well-defined responsibilities

The architecture leverages visionOS and RealityKit strengths while maintaining game development best practices.
