# Escape Room Network - Technical Architecture

## Table of Contents
1. [Architecture Overview](#architecture-overview)
2. [Game Architecture](#game-architecture)
3. [visionOS Integration](#visionos-integration)
4. [Data Models & Schemas](#data-models--schemas)
5. [RealityKit Components & Systems](#realitykit-components--systems)
6. [ARKit Integration](#arkit-integration)
7. [Multiplayer Architecture](#multiplayer-architecture)
8. [Physics & Collision Systems](#physics--collision-systems)
9. [Audio Architecture](#audio-architecture)
10. [Performance Optimization](#performance-optimization)
11. [Save/Load System](#saveload-system)

---

## Architecture Overview

### High-Level System Design

```
┌─────────────────────────────────────────────────────────────┐
│                      Application Layer                       │
│  ┌────────────┐  ┌────────────┐  ┌────────────┐            │
│  │ Game Views │  │  UI/Menus  │  │    HUD     │            │
│  └────────────┘  └────────────┘  └────────────┘            │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                      Game Logic Layer                        │
│  ┌────────────┐  ┌────────────┐  ┌────────────┐            │
│  │ Game Loop  │  │   State    │  │   Events   │            │
│  │  Manager   │  │  Machine   │  │   System   │            │
│  └────────────┘  └────────────┘  └────────────┘            │
│  ┌────────────┐  ┌────────────┐  ┌────────────┐            │
│  │   Puzzle   │  │ Progression│  │  Scoring   │            │
│  │   Engine   │  │   System   │  │   System   │            │
│  └────────────┘  └────────────┘  └────────────┘            │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                   Entity-Component-System                    │
│  ┌────────────┐  ┌────────────┐  ┌────────────┐            │
│  │  Entities  │  │ Components │  │  Systems   │            │
│  │  (Puzzles, │  │ (Transform,│  │ (Physics,  │            │
│  │   Items)   │  │ Collision) │  │  Input)    │            │
│  └────────────┘  └────────────┘  └────────────┘            │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                     Platform Layer                           │
│  ┌────────────┐  ┌────────────┐  ┌────────────┐            │
│  │ RealityKit │  │   ARKit    │  │  Network   │            │
│  │  Renderer  │  │  Spatial   │  │ (SharePlay)│            │
│  └────────────┘  └────────────┘  └────────────┘            │
│  ┌────────────┐  ┌────────────┐  ┌────────────┐            │
│  │   Audio    │  │   Input    │  │Persistence │            │
│  │ (Spatial)  │  │  (Gestures)│  │ (CoreData) │            │
│  └────────────┘  └────────────┘  └────────────┘            │
└─────────────────────────────────────────────────────────────┘
```

### Core Design Principles

1. **Separation of Concerns**: Clear boundaries between game logic, rendering, and platform features
2. **Entity-Component-System**: Flexible composition over inheritance for game objects
3. **Event-Driven**: Decoupled communication between systems
4. **Test-Driven**: All components designed for testability
5. **Performance-First**: 60-90 FPS target with efficient memory management

---

## Game Architecture

### Game Loop

```swift
// Core game loop running at 60-90 FPS
class GameLoopManager {
    private var displayLink: CADisplayLink?
    private let targetFrameRate: Double = 90.0
    private var lastUpdateTime: TimeInterval = 0

    func start() {
        displayLink = CADisplayLink(target: self, selector: #selector(update))
        displayLink?.preferredFramesPerSecond = Int(targetFrameRate)
        displayLink?.add(to: .main, forMode: .common)
    }

    @objc private func update(displayLink: CADisplayLink) {
        let currentTime = displayLink.timestamp
        let deltaTime = currentTime - lastUpdateTime
        lastUpdateTime = currentTime

        // Update game systems
        inputSystem.update(deltaTime: deltaTime)
        physicsSystem.update(deltaTime: deltaTime)
        puzzleSystem.update(deltaTime: deltaTime)
        audioSystem.update(deltaTime: deltaTime)
        networkSystem.update(deltaTime: deltaTime)
    }
}
```

### State Management

```swift
// Game state machine
enum GameState {
    case initialization
    case roomScanning
    case roomMapping
    case loadingPuzzle
    case playing
    case paused
    case puzzleCompleted
    case gameOver
    case multiplayerLobby
    case multiplayerSession
}

protocol GameStateProtocol {
    func onEnter()
    func onUpdate(deltaTime: TimeInterval)
    func onExit()
    func canTransition(to newState: GameState) -> Bool
}

class GameStateMachine {
    private(set) var currentState: GameState
    private var states: [GameState: GameStateProtocol]

    func transition(to newState: GameState) {
        guard currentState != newState,
              states[currentState]?.canTransition(to: newState) == true else {
            return
        }

        states[currentState]?.onExit()
        currentState = newState
        states[currentState]?.onEnter()
    }
}
```

### Scene Graph

```swift
// Hierarchical scene organization
class SceneGraph {
    var rootNode: SceneNode
    private var nodeRegistry: [UUID: SceneNode]

    // Scene node types
    // - RoomNode: Represents physical room space
    // - PuzzleNode: Contains puzzle elements
    // - UINode: Spatial UI elements
    // - EffectsNode: Visual/audio effects
}

class SceneNode {
    var id: UUID
    var transform: Transform
    var children: [SceneNode]
    var components: [Component]
    weak var parent: SceneNode?

    func addChild(_ node: SceneNode)
    func removeChild(_ node: SceneNode)
    func findNode(byId id: UUID) -> SceneNode?
}
```

---

## visionOS Integration

### Window Management

```swift
// Multi-window support for menus and settings
@main
struct EscapeRoomNetworkApp: App {
    @State private var gameViewModel = GameViewModel()

    var body: some Scene {
        // Main menu window
        WindowGroup(id: "main-menu") {
            MainMenuView()
                .environment(gameViewModel)
        }
        .windowStyle(.plain)
        .defaultSize(width: 800, height: 600)

        // Settings window
        WindowGroup(id: "settings") {
            SettingsView()
        }
        .windowStyle(.plain)

        // Immersive space for gameplay
        ImmersiveSpace(id: "game-space") {
            GameView()
                .environment(gameViewModel)
        }
        .immersionStyle(selection: .constant(.mixed), in: .mixed, .progressive, .full)
    }
}
```

### Immersive Space Architecture

```swift
// Game space configuration
enum ImmersionLevel {
    case mixed        // Virtual elements blend with real environment
    case progressive  // Adjustable immersion level
    case full        // Complete virtual environment
}

class ImmersiveSpaceManager {
    var currentImmersionLevel: ImmersionLevel = .mixed

    func configureForPuzzle(_ puzzle: Puzzle) {
        // Adjust immersion based on puzzle requirements
        switch puzzle.type {
        case .environmentalExploration:
            currentImmersionLevel = .mixed
        case .focusedPuzzle:
            currentImmersionLevel = .progressive
        case .narrativeCinematic:
            currentImmersionLevel = .full
        }
    }
}
```

### RealityView Integration

```swift
// Main game reality view
struct GameView: View {
    @Environment(GameViewModel.self) private var gameViewModel

    var body: some View {
        RealityView { content in
            // Initialize game scene
            let rootEntity = Entity()
            content.add(rootEntity)

            // Add spatial systems
            await gameViewModel.initializeGameSystems(rootEntity: rootEntity)
        } update: { content in
            // Update loop for RealityKit content
            gameViewModel.updateGameContent(content)
        }
        .gesture(
            SpatialTapGesture()
                .targetedToAnyEntity()
                .onEnded { value in
                    gameViewModel.handleTap(on: value.entity)
                }
        )
    }
}
```

---

## Data Models & Schemas

### Core Data Models

```swift
// Puzzle definition
struct Puzzle: Codable, Identifiable {
    let id: UUID
    let title: String
    let description: String
    let difficulty: Difficulty
    let estimatedTime: TimeInterval
    let requiredRoomSize: RoomSize
    let puzzleElements: [PuzzleElement]
    let objectives: [Objective]
    let hints: [Hint]

    enum Difficulty: String, Codable {
        case beginner, intermediate, advanced, expert
    }
}

// Puzzle element (virtual objects in room)
struct PuzzleElement: Codable, Identifiable {
    let id: UUID
    let type: ElementType
    let position: SIMD3<Float>  // Relative to room anchor
    let rotation: simd_quatf
    let scale: SIMD3<Float>
    let modelName: String
    let interactionType: InteractionType
    let metadata: [String: String]

    enum ElementType: String, Codable {
        case clue, key, lock, mechanism, decoration, hint
    }

    enum InteractionType: String, Codable {
        case tap, grab, rotate, examine, combine
    }
}

// Room mapping data
struct RoomData: Codable {
    let id: UUID
    let scanDate: Date
    let dimensions: SIMD3<Float>
    let floorPlan: FloorPlan
    let furniture: [FurnitureItem]
    let anchorPoints: [AnchorPoint]
    let meshAnchors: [MeshAnchor]

    struct FloorPlan: Codable {
        let vertices: [SIMD3<Float>]
        let polygons: [[Int]]
    }

    struct FurnitureItem: Codable {
        let id: UUID
        let type: FurnitureType
        let boundingBox: BoundingBox
        let surfaceNormals: [SIMD3<Float>]
    }
}

// Player data
struct Player: Codable, Identifiable {
    let id: UUID
    var username: String
    var avatar: AvatarData
    var statistics: PlayerStatistics
    var achievements: [Achievement]
    var roomProfile: RoomData?
}

// Multiplayer session state
struct MultiplayerSession: Codable {
    let id: UUID
    let puzzleId: UUID
    let players: [Player]
    var sharedState: SharedGameState
    var synchronizationData: SyncData
}
```

### Persistence Schema (Core Data)

```swift
// Core Data entities for local persistence
@objc(SavedGame)
class SavedGame: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var puzzleId: UUID
    @NSManaged var saveDate: Date
    @NSManaged var progressData: Data  // Encoded game state
    @NSManaged var roomDataId: UUID
}

@objc(PlayerProgress)
class PlayerProgress: NSManagedObject {
    @NSManaged var playerId: UUID
    @NSManaged var totalPuzzlesSolved: Int32
    @NSManaged var totalPlayTime: TimeInterval
    @NSManaged var currentLevel: Int32
    @NSManaged var unlockedContent: Data
}
```

---

## RealityKit Components & Systems

### Custom Components

```swift
// Puzzle interaction component
struct PuzzleInteractionComponent: Component {
    var isInteractable: Bool = true
    var interactionType: InteractionType
    var onInteract: ((Entity) -> Void)?

    enum InteractionType {
        case tap, grab, rotate, examine
    }
}

// Physics-enabled component
struct PhysicsComponent: Component {
    var mass: Float
    var friction: Float
    var restitution: Float
    var isKinematic: Bool
    var collisionGroup: CollisionGroup
}

// Network sync component
struct NetworkSyncComponent: Component {
    var ownerId: UUID
    var lastSyncTime: TimeInterval
    var syncFrequency: TimeInterval
    var isAuthority: Bool
}

// Spatial anchor component
struct SpatialAnchorComponent: Component {
    var anchorId: UUID
    var anchorType: AnchorType
    var isPersistent: Bool

    enum AnchorType {
        case room, furniture, custom
    }
}

// Audio component
struct SpatialAudioComponent: Component {
    var audioClipName: String
    var volume: Float
    var isLooping: Bool
    var spatialBlend: Float  // 0 = 2D, 1 = 3D
    var maxDistance: Float
}
```

### ECS Systems

```swift
// Interaction system
class InteractionSystem: System {
    static let query = EntityQuery(where: .has(PuzzleInteractionComponent.self))

    func update(context: SceneUpdateContext) {
        // Process all interactable entities
        for entity in context.entities(matching: Self.query, updatingSystemWhen: .rendering) {
            guard var interaction = entity.components[PuzzleInteractionComponent.self] else { continue }

            // Check for user interactions
            if interaction.isInteractable {
                processInteraction(entity: entity, component: interaction)
            }
        }
    }

    private func processInteraction(entity: Entity, component: PuzzleInteractionComponent) {
        // Handle different interaction types
    }
}

// Physics system
class PhysicsSystem: System {
    static let query = EntityQuery(where: .has(PhysicsComponent.self))

    func update(context: SceneUpdateContext) {
        // Update physics for all entities
        for entity in context.entities(matching: Self.query, updatingSystemWhen: .rendering) {
            updatePhysics(entity: entity, deltaTime: context.deltaTime)
        }
    }
}

// Network synchronization system
class NetworkSyncSystem: System {
    static let query = EntityQuery(where: .has(NetworkSyncComponent.self))
    private var networkManager: NetworkManager

    func update(context: SceneUpdateContext) {
        for entity in context.entities(matching: Self.query, updatingSystemWhen: .rendering) {
            guard var syncComponent = entity.components[NetworkSyncComponent.self] else { continue }

            // Sync entity state over network
            if context.currentTime - syncComponent.lastSyncTime >= syncComponent.syncFrequency {
                networkManager.syncEntity(entity)
                syncComponent.lastSyncTime = context.currentTime
            }
        }
    }
}
```

---

## ARKit Integration

### Spatial Mapping & Room Scanning

```swift
// ARKit session management
class SpatialMappingManager {
    private var arSession: ARKitSession
    private var worldTrackingProvider: WorldTrackingProvider
    private var sceneReconstructionProvider: SceneReconstructionProvider
    private var handTrackingProvider: HandTrackingProvider

    func startRoomScanning() async {
        // Request authorization
        await arSession.requestAuthorization(for: [.worldSensing, .handTracking])

        // Start providers
        try? await arSession.run([
            worldTrackingProvider,
            sceneReconstructionProvider,
            handTrackingProvider
        ])
    }

    func processRoomMesh() async {
        for await update in sceneReconstructionProvider.anchorUpdates {
            switch update.event {
            case .added, .updated:
                processMeshAnchor(update.anchor)
            case .removed:
                removeMeshAnchor(update.anchor)
            }
        }
    }

    private func processMeshAnchor(_ anchor: MeshAnchor) {
        // Convert mesh data to game-usable format
        let vertices = anchor.geometry.vertices
        let normals = anchor.geometry.normals
        let faces = anchor.geometry.faces

        // Classify surfaces (floor, wall, ceiling, furniture)
        classifySurface(vertices: vertices, normals: normals)
    }

    func classifySurface(vertices: GeometrySource, normals: GeometrySource) -> SurfaceType {
        // Analyze normals to determine surface type
        // Floor: normal points up
        // Ceiling: normal points down
        // Walls: normal is horizontal
    }
}
```

### Object Recognition & Classification

```swift
// AI-powered object recognition
class ObjectRecognitionManager {
    private var visionModel: VNCoreMLModel

    func classifyFurniture(from meshAnchor: MeshAnchor) async -> FurnitureType? {
        // Use Vision framework for object classification
        let request = VNCoreMLRequest(model: visionModel)

        // Process mesh geometry
        let results = try? await processClassification(request: request, mesh: meshAnchor)

        return results?.topResult
    }

    enum FurnitureType {
        case table, chair, sofa, bed, shelf, desk, cabinet
    }
}
```

### Spatial Anchors

```swift
// Persistent anchor management
class AnchorManager {
    private var worldAnchors: [UUID: WorldAnchor] = [:]

    func createAnchor(at transform: simd_float4x4, persistent: Bool = true) async -> UUID? {
        let anchor = WorldAnchor(originFromAnchorTransform: transform)

        if persistent {
            // Save anchor for persistence across sessions
            try? await anchor.persist()
        }

        let id = UUID()
        worldAnchors[id] = anchor
        return id
    }

    func loadPersistedAnchors() async {
        // Load saved anchors from previous sessions
        let persistedAnchors = try? await WorldAnchor.loadPersisted()

        for anchor in persistedAnchors ?? [] {
            let id = UUID()
            worldAnchors[id] = anchor
        }
    }
}
```

---

## Multiplayer Architecture

### Network Layer

```swift
// SharePlay integration
class MultiplayerManager: NSObject, ObservableObject {
    @Published var currentSession: MultiplayerSession?
    @Published var connectedPlayers: [Player] = []

    private var groupSession: GroupSession<EscapeRoomActivity>?
    private var messenger: GroupSessionMessenger?

    func startMultiplayerSession(puzzleId: UUID) async throws {
        // Create SharePlay activity
        let activity = EscapeRoomActivity(puzzleId: puzzleId)

        // Start group session
        switch await activity.prepareForActivation() {
        case .activationPreferred:
            try await activity.activate()
        case .activationDisabled, .cancelled:
            return
        @unknown default:
            return
        }
    }

    func handleGroupSessionUpdates() {
        Task {
            for await session in EscapeRoomActivity.sessions() {
                configureGroupSession(session)
            }
        }
    }

    private func configureGroupSession(_ session: GroupSession<EscapeRoomActivity>) {
        self.groupSession = session
        self.messenger = GroupSessionMessenger(session: session)

        session.join()

        // Handle participant updates
        Task {
            for await participants in session.$activeParticipants.values {
                updateConnectedPlayers(participants)
            }
        }
    }
}

// SharePlay activity
struct EscapeRoomActivity: GroupActivity {
    let puzzleId: UUID
    var metadata: GroupActivityMetadata {
        var meta = GroupActivityMetadata()
        meta.title = "Escape Room Network"
        meta.type = .generic
        return meta
    }
}
```

### State Synchronization

```swift
// Network message types
enum NetworkMessage: Codable {
    case playerJoined(Player)
    case playerLeft(UUID)
    case entityUpdate(EntityState)
    case puzzleProgress(PuzzleProgress)
    case chatMessage(ChatMessage)
    case voiceChat(VoiceData)
}

struct EntityState: Codable {
    let entityId: UUID
    let position: SIMD3<Float>
    let rotation: simd_quatf
    let timestamp: TimeInterval
}

// Network synchronization
class NetworkSynchronizer {
    private var messenger: GroupSessionMessenger
    private let syncInterval: TimeInterval = 1.0 / 30.0  // 30 updates/sec

    func sendEntityUpdate(_ entity: Entity) {
        let state = EntityState(
            entityId: entity.id,
            position: entity.position,
            rotation: entity.orientation,
            timestamp: Date().timeIntervalSince1970
        )

        let message = NetworkMessage.entityUpdate(state)
        Task {
            try? await messenger.send(message)
        }
    }

    func receiveMessages() {
        Task {
            for await (message, _) in messenger.messages(of: NetworkMessage.self) {
                handleNetworkMessage(message)
            }
        }
    }

    private func handleNetworkMessage(_ message: NetworkMessage) {
        switch message {
        case .entityUpdate(let state):
            updateEntityFromNetwork(state)
        case .puzzleProgress(let progress):
            updatePuzzleProgress(progress)
        // ... handle other message types
        default:
            break
        }
    }
}
```

### Conflict Resolution

```swift
// Authority-based conflict resolution
class ConflictResolver {
    enum Authority {
        case server
        case client
        case hostPlayer
    }

    func resolveEntityConflict(local: EntityState, remote: EntityState) -> EntityState {
        // Use timestamp to determine authoritative state
        if remote.timestamp > local.timestamp {
            return remote
        }
        return local
    }

    func determinePuzzleAuthority(puzzle: Puzzle, players: [Player]) -> UUID {
        // First player to interact becomes authority for that puzzle element
        // or use host player as default authority
        return players.first?.id ?? UUID()
    }
}
```

---

## Physics & Collision Systems

### Physics Engine Integration

```swift
// Physics world configuration
class PhysicsManager {
    private var physicsWorld: PhysicsWorld

    init() {
        physicsWorld = PhysicsWorld()
        physicsWorld.gravity = SIMD3<Float>(0, -9.81, 0)
    }

    func addRigidBody(to entity: Entity, mass: Float, shape: ShapeResource) {
        let physics = PhysicsBodyComponent(
            massProperties: .init(mass: mass),
            material: .init(friction: 0.5, restitution: 0.3),
            mode: .dynamic
        )

        entity.components[PhysicsBodyComponent.self] = physics
        entity.components[CollisionComponent.self] = CollisionComponent(shapes: [shape])
    }
}
```

### Collision Detection

```swift
// Collision handling
class CollisionManager {
    func setupCollisionCallbacks() {
        // Subscribe to collision events
        EventSink.shared.subscribe(
            to: CollisionEvents.Began.self,
            on: nil
        ) { event in
            self.handleCollision(event)
        }
    }

    private func handleCollision(_ event: CollisionEvents.Began) {
        guard let entityA = event.entityA as? Entity,
              let entityB = event.entityB as? Entity else {
            return
        }

        // Process puzzle-related collisions
        if let puzzleComponent = entityA.components[PuzzleInteractionComponent.self] {
            processPuzzleCollision(puzzleEntity: entityA, otherEntity: entityB)
        }
    }
}
```

---

## Audio Architecture

### Spatial Audio System

```swift
// Spatial audio manager
class SpatialAudioManager {
    private var audioEngine: AVAudioEngine
    private var environment: AVAudioEnvironmentNode

    init() {
        audioEngine = AVAudioEngine()
        environment = AVAudioEnvironmentNode()

        // Configure spatial audio
        audioEngine.attach(environment)
        audioEngine.connect(environment, to: audioEngine.mainMixerNode, format: nil)

        // Configure listener properties
        environment.listenerPosition = AVAudio3DPoint(x: 0, y: 0, z: 0)
        environment.listenerVectorOrientation = AVAudio3DVectorOrientation(
            forward: AVAudio3DVector(x: 0, y: 0, z: -1),
            up: AVAudio3DVector(x: 0, y: 1, z: 0)
        )
    }

    func playSound(at position: SIMD3<Float>, audioFile: String, volume: Float = 1.0) {
        let audioPlayer = AVAudioPlayerNode()
        audioEngine.attach(audioPlayer)
        audioEngine.connect(audioPlayer, to: environment, format: nil)

        // Set 3D position
        audioPlayer.position = AVAudio3DPoint(x: position.x, y: position.y, z: position.z)

        // Load and play audio
        if let url = Bundle.main.url(forResource: audioFile, withExtension: "wav"),
           let audioFile = try? AVAudioFile(forReading: url) {
            audioPlayer.scheduleFile(audioFile, at: nil)
            audioPlayer.play()
        }
    }

    func updateListenerPosition(_ position: SIMD3<Float>, orientation: simd_quatf) {
        environment.listenerPosition = AVAudio3DPoint(x: position.x, y: position.y, z: position.z)

        // Update listener orientation based on head tracking
        let forward = orientation.act(SIMD3<Float>(0, 0, -1))
        let up = orientation.act(SIMD3<Float>(0, 1, 0))

        environment.listenerVectorOrientation = AVAudio3DVectorOrientation(
            forward: AVAudio3DVector(x: forward.x, y: forward.y, z: forward.z),
            up: AVAudio3DVector(x: up.x, y: up.y, z: up.z)
        )
    }
}
```

### Audio Categories

```swift
// Audio system categories
enum AudioCategory {
    case music           // Background music
    case sfx            // Sound effects
    case ambience       // Environmental sounds
    case voice          // Voice chat
    case ui             // UI feedback
    case narration      // Story narration
}

class AudioMixer {
    private var categoryVolumes: [AudioCategory: Float] = [:]

    func setVolume(_ volume: Float, for category: AudioCategory) {
        categoryVolumes[category] = volume
    }
}
```

---

## Performance Optimization

### Frame Rate Management

```swift
// Performance monitoring
class PerformanceMonitor {
    private var frameCount: Int = 0
    private var lastFPSUpdate: TimeInterval = 0
    private(set) var currentFPS: Double = 0

    func update(currentTime: TimeInterval) {
        frameCount += 1

        if currentTime - lastFPSUpdate >= 1.0 {
            currentFPS = Double(frameCount)
            frameCount = 0
            lastFPSUpdate = currentTime

            // Log performance warnings
            if currentFPS < 60 {
                logPerformanceWarning()
            }
        }
    }

    private func logPerformanceWarning() {
        print("⚠️ Performance: FPS dropped to \(currentFPS)")
    }
}
```

### Level of Detail (LOD) System

```swift
// LOD management for 3D models
class LODManager {
    enum LODLevel {
        case high, medium, low
    }

    func determineLOD(distance: Float) -> LODLevel {
        switch distance {
        case 0..<2: return .high
        case 2..<5: return .medium
        default: return .low
        }
    }

    func applyLOD(to entity: Entity, level: LODLevel) {
        // Swap model based on LOD level
        let modelName = entity.name + "_\(level)"
        if let model = loadModel(named: modelName) {
            entity.components[ModelComponent.self] = model
        }
    }
}
```

### Object Pooling

```swift
// Pool for frequently spawned objects
class ObjectPool<T: AnyObject> {
    private var availableObjects: [T] = []
    private let createObject: () -> T

    init(createObject: @escaping () -> T, initialCapacity: Int = 10) {
        self.createObject = createObject

        // Pre-populate pool
        for _ in 0..<initialCapacity {
            availableObjects.append(createObject())
        }
    }

    func acquire() -> T {
        if let object = availableObjects.popLast() {
            return object
        }
        return createObject()
    }

    func release(_ object: T) {
        availableObjects.append(object)
    }
}

// Usage for puzzle elements
class PuzzleElementPool {
    private let elementPool = ObjectPool<Entity>(createObject: { Entity() })

    func spawnElement() -> Entity {
        return elementPool.acquire()
    }

    func despawnElement(_ element: Entity) {
        elementPool.release(element)
    }
}
```

### Memory Management

```swift
// Resource management
class ResourceManager {
    private var loadedAssets: [String: Any] = [:]
    private var assetUsageCount: [String: Int] = [:]

    func loadAsset<T>(named name: String, loader: () -> T) -> T {
        if let cached = loadedAssets[name] as? T {
            assetUsageCount[name, default: 0] += 1
            return cached
        }

        let asset = loader()
        loadedAssets[name] = asset
        assetUsageCount[name] = 1
        return asset
    }

    func releaseAsset(named name: String) {
        assetUsageCount[name, default: 1] -= 1

        if assetUsageCount[name] == 0 {
            loadedAssets.removeValue(forKey: name)
            assetUsageCount.removeValue(forKey: name)
        }
    }

    func purgeUnusedAssets() {
        let unused = assetUsageCount.filter { $0.value == 0 }.map { $0.key }
        unused.forEach { loadedAssets.removeValue(forKey: $0) }
    }
}
```

---

## Save/Load System

### Save Data Architecture

```swift
// Save game structure
struct SaveData: Codable {
    let version: String
    let saveDate: Date
    let playerProgress: PlayerProgress
    let currentPuzzleState: PuzzleState?
    let roomConfiguration: RoomData
    let settings: GameSettings
}

struct PuzzleState: Codable {
    let puzzleId: UUID
    let completedObjectives: [UUID]
    let discoveredClues: [UUID]
    let entityStates: [UUID: EntityState]
    let elapsedTime: TimeInterval
}
```

### Persistence Manager

```swift
// Core Data persistence
class PersistenceManager {
    static let shared = PersistenceManager()

    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "EscapeRoomNetwork")
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Unable to load persistent stores: \(error)")
            }
        }
        return container
    }()

    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    func saveGame(_ saveData: SaveData) throws {
        let savedGame = SavedGame(context: context)
        savedGame.id = UUID()
        savedGame.saveDate = saveData.saveDate
        savedGame.progressData = try JSONEncoder().encode(saveData)

        try context.save()
    }

    func loadMostRecentSave() throws -> SaveData? {
        let fetchRequest: NSFetchRequest<SavedGame> = SavedGame.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "saveDate", ascending: false)]
        fetchRequest.fetchLimit = 1

        let results = try context.fetch(fetchRequest)
        guard let savedGame = results.first else { return nil }

        return try JSONDecoder().decode(SaveData.self, from: savedGame.progressData)
    }
}
```

### Cloud Sync

```swift
// iCloud synchronization
class CloudSyncManager {
    private let ubiquityIdentifier = "iCloud.com.escaperoom.network"

    func syncSaveData() async throws {
        guard let ubiquityURL = FileManager.default.url(forUbiquityContainerIdentifier: ubiquityIdentifier) else {
            throw CloudSyncError.notAvailable
        }

        // Sync save files to iCloud
        let documentsURL = ubiquityURL.appendingPathComponent("Documents")
        // ... sync logic
    }
}
```

---

## Testing Architecture

### Unit Testing Strategy

```swift
// Testable game logic
protocol PuzzleEngineProtocol {
    func checkSolution(_ solution: PuzzleSolution) -> Bool
    func providHint(difficulty: Int) -> Hint?
}

class PuzzleEngineTests: XCTestCase {
    var sut: PuzzleEngine!

    override func setUp() {
        super.setUp()
        sut = PuzzleEngine()
    }

    func testPuzzleSolutionValidation() {
        // Given
        let puzzle = MockPuzzle.createTestPuzzle()
        let correctSolution = PuzzleSolution(answer: "correct")

        // When
        let result = sut.checkSolution(correctSolution)

        // Then
        XCTAssertTrue(result, "Correct solution should be validated")
    }
}
```

---

## Summary

This architecture provides:

1. **Scalable Foundation**: Modular design supports future features
2. **Performance**: 60-90 FPS target with efficient rendering and physics
3. **Multiplayer**: Robust SharePlay integration with conflict resolution
4. **Spatial Computing**: Full utilization of visionOS capabilities
5. **Testability**: Clear separation of concerns enables comprehensive testing
6. **Persistence**: Reliable save/load with cloud sync support

The architecture is designed to scale from single-player experiences to complex multiplayer scenarios while maintaining high performance and a smooth user experience.
