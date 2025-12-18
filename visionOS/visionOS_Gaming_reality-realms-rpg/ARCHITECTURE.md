# Reality Realms RPG - Technical Architecture

## Table of Contents
- [Architecture Overview](#architecture-overview)
- [Game Architecture](#game-architecture)
- [visionOS-Specific Gaming Patterns](#visionos-specific-gaming-patterns)
- [Data Models and Schemas](#data-models-and-schemas)
- [RealityKit Gaming Components](#realitykit-gaming-components)
- [ARKit Integration](#arkit-integration)
- [Multiplayer Architecture](#multiplayer-architecture)
- [Physics and Collision Systems](#physics-and-collision-systems)
- [Audio Architecture](#audio-architecture)
- [Performance Optimization](#performance-optimization)
- [Save/Load System](#saveload-system)

---

## Architecture Overview

Reality Realms follows a modular, event-driven Entity-Component-System (ECS) architecture optimized for visionOS spatial gaming. The application is structured in layers:

```
┌─────────────────────────────────────────────────────────────┐
│                    Presentation Layer                        │
│  SwiftUI Views • RealityKit Rendering • Spatial UI          │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│                     Game Logic Layer                         │
│  Game Loop • State Machine • ECS Systems • Event Bus        │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│                     Spatial Layer                            │
│  Room Mapping • Anchor Management • Furniture Detection     │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│                       Data Layer                             │
│  CloudKit Sync • Local Persistence • Asset Streaming        │
└─────────────────────────────────────────────────────────────┘
```

### Core Architectural Principles

1. **Entity-Component-System (ECS)**: All game objects are entities with composable components
2. **Event-Driven Communication**: Loose coupling via centralized event bus
3. **Spatial-First Design**: Room mapping and spatial anchors as foundation
4. **Performance Budgets**: Strict 90 FPS target with dynamic quality scaling
5. **Persistent World State**: All spatial data survives app restarts

---

## Game Architecture

### Game Loop

The main game loop runs at 90 Hz synchronized with Vision Pro's display:

```swift
class GameLoop {
    private var displayLink: CADisplayLink?
    private let targetFPS: Double = 90.0
    private var deltaTime: TimeInterval = 0

    func start() {
        displayLink = CADisplayLink(target: self, selector: #selector(update))
        displayLink?.preferredFramesPerSecond = Int(targetFPS)
        displayLink?.add(to: .main, forMode: .common)
    }

    @objc private func update(_ displayLink: CADisplayLink) {
        deltaTime = displayLink.targetTimestamp - displayLink.timestamp

        // Fixed update phases
        processInput(deltaTime)
        updatePhysics(deltaTime)
        updateGameLogic(deltaTime)
        updateAI(deltaTime)
        updateAnimations(deltaTime)
        updateAudio(deltaTime)
        render()
    }
}
```

### State Management

Game state follows a hierarchical finite state machine:

```swift
enum GameState {
    case initialization
    case roomScanning
    case tutorial
    case gameplay(GameplayState)
    case paused
    case loading(LoadingContext)
    case error(GameError)
}

enum GameplayState {
    case exploration
    case combat(CombatContext)
    case dialogue(NPCInteraction)
    case inventory
    case multiplayer(MultiplayerSession)
}

class GameStateManager: ObservableObject {
    @Published private(set) var currentState: GameState
    private var stateHistory: [GameState] = []
    private let eventBus: EventBus

    func transition(to newState: GameState) {
        let oldState = currentState
        stateHistory.append(oldState)
        currentState = newState

        // Trigger state change events
        eventBus.publish(StateChangeEvent(from: oldState, to: newState))
    }
}
```

### Scene Graph

Scenes are organized hierarchically with RealityKit:

```swift
protocol GameScene {
    var rootEntity: Entity { get }
    var sceneID: UUID { get }
    var isActive: Bool { get set }

    func setup()
    func teardown()
    func update(deltaTime: TimeInterval)
}

class SceneManager {
    private var activeScenes: [UUID: GameScene] = [:]
    private let realityKitView: RealityView

    func loadScene(_ scene: GameScene) async {
        await scene.setup()
        activeScenes[scene.sceneID] = scene
        realityKitView.scene.addChild(scene.rootEntity)
    }

    func unloadScene(_ sceneID: UUID) async {
        guard let scene = activeScenes[sceneID] else { return }
        await scene.teardown()
        realityKitView.scene.removeChild(scene.rootEntity)
        activeScenes.removeValue(forKey: sceneID)
    }
}
```

---

## visionOS-Specific Gaming Patterns

### Immersive Space Management

Reality Realms uses Full Immersive Space for core gameplay:

```swift
@main
struct RealityRealmsApp: App {
    @State private var immersionStyle: ImmersionStyle = .full

    var body: some Scene {
        WindowGroup {
            MainMenuView()
        }

        ImmersiveSpace(id: "GameSpace") {
            GameView()
        }
        .immersionStyle(selection: $immersionStyle, in: .full)
    }
}
```

### Spatial Anchors for Persistence

All game objects use WorldAnchor for persistence:

```swift
struct SpatialAnchorManager {
    func createPersistentAnchor(
        at transform: simd_float4x4,
        for entity: Entity
    ) async throws -> AnchorEntity {
        let anchor = AnchorEntity(.world(transform: transform))
        anchor.addChild(entity)

        // Persist anchor to CloudKit
        let anchorData = try await WorldAnchorSerializer.serialize(anchor)
        await CloudKitManager.shared.save(anchorData)

        return anchor
    }

    func restorePersistedAnchors() async throws -> [AnchorEntity] {
        let anchorData = try await CloudKitManager.shared.fetchAnchors()
        return try await WorldAnchorSerializer.deserialize(anchorData)
    }
}
```

### Room Mapping Integration

```swift
class RoomMapper {
    private let arSession: ARKitSession
    private let worldTracking: WorldTrackingProvider
    private let sceneReconstruction: SceneReconstructionProvider

    func scanRoom() async throws -> RoomLayout {
        // Start AR session
        try await arSession.run([worldTracking, sceneReconstruction])

        var meshAnchors: [MeshAnchor] = []

        // Collect mesh data
        for await update in sceneReconstruction.anchorUpdates {
            switch update.event {
            case .added, .updated:
                meshAnchors.append(update.anchor)
            case .removed:
                meshAnchors.removeAll { $0.id == update.anchor.id }
            }
        }

        // Analyze room geometry
        return RoomAnalyzer.analyze(meshAnchors: meshAnchors)
    }
}

struct RoomLayout {
    let bounds: AxisAlignedBoundingBox
    let floor: PlaneAnchor
    let walls: [PlaneAnchor]
    let ceiling: PlaneAnchor?
    let furniture: [FurnitureObject]
    let safePlayArea: AxisAlignedBoundingBox
}
```

---

## Data Models and Schemas

### Core Entity Schema

```swift
protocol GameEntity: Identifiable {
    var id: UUID { get }
    var components: [Component] { get set }
    var transform: Transform { get set }
    var isActive: Bool { get set }
}

struct Player: GameEntity {
    let id: UUID
    var components: [Component]
    var transform: Transform
    var isActive: Bool

    // Player-specific properties
    var characterClass: CharacterClass
    var level: Int
    var experience: Int
    var health: Int
    var maxHealth: Int
    var mana: Int
    var maxMana: Int
    var inventory: Inventory
    var equipment: Equipment
}

struct NPC: GameEntity {
    let id: UUID
    var components: [Component]
    var transform: Transform
    var isActive: Bool

    // NPC-specific properties
    var npcType: NPCType
    var aiState: AIState
    var dialogue: DialogueTree
    var questProvider: QuestProvider?
    var merchantInventory: [Item]?
}

struct Enemy: GameEntity {
    let id: UUID
    var components: [Component]
    var transform: Transform
    var isActive: Bool

    // Enemy-specific properties
    var enemyType: EnemyType
    var combatAI: CombatAI
    var health: Int
    var maxHealth: Int
    var damage: Int
    var lootTable: LootTable
}
```

### Component System

```swift
protocol Component {
    var entityID: UUID { get }
}

// Transform Component
struct TransformComponent: Component {
    let entityID: UUID
    var position: SIMD3<Float>
    var rotation: simd_quatf
    var scale: SIMD3<Float>
}

// Render Component
struct RenderComponent: Component {
    let entityID: UUID
    var modelEntity: ModelEntity
    var materials: [Material]
    var lodLevel: Int
}

// Physics Component
struct PhysicsComponent: Component {
    let entityID: UUID
    var physicsBody: PhysicsBodyComponent
    var collisionShape: ShapeResource
    var mass: Float
    var friction: Float
}

// Health Component
struct HealthComponent: Component {
    let entityID: UUID
    var current: Int
    var maximum: Int
    var regenerationRate: Float
    var isDead: Bool
}

// AI Component
struct AIComponent: Component {
    let entityID: UUID
    var behaviorTree: BehaviorTree
    var perceptionRadius: Float
    var targetEntity: UUID?
    var currentAction: AIAction?
}
```

### Spatial Data Schema

```swift
struct RealmData: Codable {
    let realmID: UUID
    let ownerID: String
    var rooms: [RoomID: RoomRealmData]
    var createdAt: Date
    var lastUpdated: Date
}

struct RoomRealmData: Codable {
    let roomID: UUID
    let roomType: RoomType
    var spatialAnchors: [SpatialAnchorData]
    var entities: [EntitySnapshot]
    var furnitureGameplayData: [FurnitureGameplayData]
    var discoveredSecrets: [SecretID]
}

struct SpatialAnchorData: Codable {
    let anchorID: UUID
    let worldTransform: simd_float4x4
    let entityID: UUID
    let anchorType: AnchorType
}

enum RoomType: String, Codable {
    case livingRoom = "throne_room"
    case kitchen = "alchemy_lab"
    case bedroom = "restoration_chamber"
    case bathroom = "mystical_springs"
    case basement = "dungeon"
    case garage = "armory"
}
```

---

## RealityKit Gaming Components

### Custom RealityKit Components

```swift
// Combat Component
struct CombatComponent: Component {
    var damage: Int
    var attackSpeed: Float
    var attackRange: Float
    var combatStyle: CombatStyle
    var activeWeapon: WeaponEntity?
}

// Interactable Component
struct InteractableComponent: Component {
    var interactionType: InteractionType
    var interactionRadius: Float
    var requiresGaze: Bool
    var onInteract: () -> Void
}

// Persistent Component - marks entities for save/load
struct PersistentComponent: Component {
    var anchorID: UUID
    var shouldSaveState: Bool
}

// Pet Companion Component
struct CompanionComponent: Component {
    var petType: PetType
    var loyalty: Int
    var homeLocation: SIMD3<Float>
    var schedule: DailySchedule
    var currentActivity: CompanionActivity
}
```

### RealityKit Systems

```swift
// Combat System
class CombatSystem: System {
    static let query = EntityQuery(where: .has(CombatComponent.self))

    required init(scene: Scene) {}

    func update(context: SceneUpdateContext) {
        for entity in context.entities(matching: Self.query, updatingSystemWhen: .rendering) {
            guard let combat = entity.components[CombatComponent.self] else { continue }

            // Process combat logic
            if let target = findNearestTarget(for: entity, within: combat.attackRange) {
                performAttack(attacker: entity, target: target, combat: combat)
            }
        }
    }
}

// Furniture Interaction System
class FurnitureInteractionSystem: System {
    static let query = EntityQuery(where: .has(InteractableComponent.self))

    required init(scene: Scene) {}

    func update(context: SceneUpdateContext) {
        for entity in context.entities(matching: Self.query, updatingSystemWhen: .rendering) {
            guard let interactable = entity.components[InteractableComponent.self] else { continue }

            if isPlayerNearby(entity, radius: interactable.interactionRadius) {
                showInteractionPrompt(for: entity)
            }
        }
    }
}
```

---

## ARKit Integration

### Hand Tracking for Combat

```swift
class HandTrackingManager {
    private let handTracking: HandTrackingProvider
    private let arSession: ARKitSession

    func startTracking() async throws {
        try await arSession.run([handTracking])
    }

    func processHandGestures() async {
        for await update in handTracking.anchorUpdates {
            let handAnchor = update.anchor

            // Detect combat gestures
            if let gesture = detectCombatGesture(handAnchor) {
                EventBus.shared.publish(CombatGestureEvent(gesture: gesture))
            }
        }
    }

    private func detectCombatGesture(_ handAnchor: HandAnchor) -> CombatGesture? {
        let skeleton = handAnchor.handSkeleton

        // Sword slash detection
        if isSwordSlashGesture(skeleton) {
            return .swordSlash(direction: calculateSlashDirection(skeleton))
        }

        // Shield block detection
        if isShieldBlockGesture(skeleton) {
            return .shieldBlock
        }

        // Spell casting detection
        if isSpellCastGesture(skeleton) {
            return .spellCast(type: detectSpellType(skeleton))
        }

        return nil
    }
}

enum CombatGesture {
    case swordSlash(direction: SIMD3<Float>)
    case shieldBlock
    case spellCast(type: SpellType)
    case bow Draw
    case dodge(direction: SIMD3<Float>)
}
```

### Eye Tracking for Targeting

```swift
class EyeTrackingManager {
    private let eyeTracking: EyeTrackingProvider

    func getCurrentGazeTarget() -> Entity? {
        guard let gazeDirection = eyeTracking.gazeDirection else { return nil }

        // Raycast from eyes
        let rayOrigin = ARKitSession.shared.headTransform.position
        let rayDirection = gazeDirection

        // Find entity hit by gaze
        return performRaycast(origin: rayOrigin, direction: rayDirection)
    }

    func enableGazeTargeting(for player: Player) {
        Task {
            for await update in eyeTracking.anchorUpdates {
                if let target = getCurrentGazeTarget(),
                   target.components[CombatComponent.self] != nil {
                    // Lock onto gazed enemy
                    EventBus.shared.publish(TargetLockedEvent(target: target))
                }
            }
        }
    }
}
```

---

## Multiplayer Architecture

### Network Layer

```swift
class MultiplayerManager {
    private let cloudKit = CKContainer.default()
    private let groupSession: GroupSession<GameActivity>?

    // SharePlay integration
    func startMultiplayerSession() async throws {
        let activity = GameActivity()

        switch await activity.prepareForActivation() {
        case .activationPreferred:
            try await activity.activate()
        case .activationDisabled:
            // Fallback to direct connection
            try await startDirectConnection()
        default:
            break
        }
    }

    // Synchronization
    func syncGameState(_ state: GameState) async {
        let stateData = try? JSONEncoder().encode(state)

        // Send to all participants
        for participant in groupSession?.activeParticipants ?? [] {
            sendData(stateData, to: participant)
        }
    }
}

// Shared Realm Synchronization
struct SharedRealmSync {
    func mapVisitorSpace(
        hostRealm: RealmData,
        visitorRoom: RoomLayout
    ) -> MappedSpace {
        // Scale and adapt host's realm to visitor's space
        let scaleFactor = calculateScaleFactor(
            hostBounds: hostRealm.rooms.first?.value.roomBounds,
            visitorBounds: visitorRoom.bounds
        )

        return MappedSpace(
            hostRealm: hostRealm,
            visitorRoom: visitorRoom,
            scaleFactor: scaleFactor,
            anchorOffsets: calculateAnchorOffsets()
        )
    }
}
```

---

## Physics and Collision Systems

### Physics Configuration

```swift
class PhysicsManager {
    private var physicsWorld: PhysicsWorld

    func setupPhysics() {
        // Configure physics world
        physicsWorld.gravity = SIMD3<Float>(0, -9.81, 0)
        physicsWorld.timeStep = 1.0 / 90.0  // Match game loop

        // Collision layers
        setupCollisionLayers()
    }

    private func setupCollisionLayers() {
        // Define collision groups
        CollisionGroup.player.canCollideWith([.enemy, .environment, .furniture])
        CollisionGroup.enemy.canCollideWith([.player, .playerProjectile, .environment])
        CollisionGroup.furniture.canCollideWith([.player, .enemy, .projectiles])
    }

    func addPhysicsBody(to entity: Entity, type: PhysicsBodyType) {
        let physicsBody: PhysicsBodyComponent

        switch type {
        case .dynamic(let mass):
            physicsBody = PhysicsBodyComponent(
                massProperties: .init(mass: mass),
                mode: .dynamic
            )
        case .kinematic:
            physicsBody = PhysicsBodyComponent(mode: .kinematic)
        case .static:
            physicsBody = PhysicsBodyComponent(mode: .static)
        }

        entity.components[PhysicsBodyComponent.self] = physicsBody
    }
}
```

### Furniture Collision Detection

```swift
class FurniturePhysicsManager {
    func setupFurnitureCollision(_ furniture: FurnitureObject) -> Entity {
        let entity = Entity()

        // Generate collision mesh from detected furniture
        let collisionShape = generateCollisionShape(from: furniture.mesh)

        entity.components[PhysicsBodyComponent.self] = PhysicsBodyComponent(
            shapes: [collisionShape],
            mode: .static
        )

        entity.components[CollisionComponent.self] = CollisionComponent(
            shapes: [collisionShape],
            filter: CollisionFilter(group: .furniture, mask: .all)
        )

        return entity
    }
}
```

---

## Audio Architecture

### Spatial Audio System

```swift
class SpatialAudioManager {
    private let audioEngine = AVAudioEngine()
    private let environment = AVAudioEnvironmentNode()

    func setup() {
        audioEngine.attach(environment)
        audioEngine.connect(environment, to: audioEngine.mainMixerNode, format: nil)

        // Configure spatial audio
        environment.renderingAlgorithm = .HRTF
        environment.distanceAttenuationParameters.maximumDistance = 50
        environment.distanceAttenuationParameters.referenceDistance = 1
    }

    func play3DSound(_ sound: AudioResource, at position: SIMD3<Float>) {
        let audioEntity = Entity()
        audioEntity.position = position

        let audioController = audioEntity.prepareAudio(sound)
        audioController.play()
    }
}

// Dynamic Music System
class MusicManager {
    private var currentState: MusicState = .exploration
    private let musicLayers: [MusicState: [AVAudioPlayerNode]] = [:]

    func transitionTo(_ state: MusicState) {
        // Crossfade between music states
        fadeOut(musicLayers[currentState] ?? [])
        fadeIn(musicLayers[state] ?? [])
        currentState = state
    }
}

enum MusicState {
    case exploration
    case combat
    case bossBattle
    case victory
    case menu
}
```

---

## Performance Optimization

### Level of Detail (LOD) System

```swift
class LODManager {
    func applyLOD(to entity: Entity, distance: Float) {
        guard var render = entity.components[RenderComponent.self] else { return }

        let lodLevel: Int
        switch distance {
        case 0..<2:
            lodLevel = 0  // Ultra quality
        case 2..<5:
            lodLevel = 1  // High quality
        case 5..<10:
            lodLevel = 2  // Medium quality
        case 10..<20:
            lodLevel = 3  // Low quality
        default:
            lodLevel = 4  // Minimum quality
        }

        if render.lodLevel != lodLevel {
            render.lodLevel = lodLevel
            swapModel(for: entity, lodLevel: lodLevel)
        }
    }
}
```

### Object Pooling

```swift
class ObjectPool<T: GameEntity> {
    private var pool: [T] = []
    private let factory: () -> T

    init(size: Int, factory: @escaping () -> T) {
        self.factory = factory
        pool = (0..<size).map { _ in factory() }
    }

    func acquire() -> T? {
        if let object = pool.popLast() {
            object.isActive = true
            return object
        }
        return nil
    }

    func release(_ object: T) {
        object.isActive = false
        pool.append(object)
    }
}

// Usage
let projectilePool = ObjectPool<Projectile>(size: 100) {
    Projectile()
}
```

### Dynamic Resolution Scaling

```swift
class PerformanceManager {
    private let targetFPS: Double = 90.0
    private var currentResolutionScale: Float = 1.0

    func adjustQuality(currentFPS: Double) {
        if currentFPS < targetFPS - 5 {
            // Reduce quality
            currentResolutionScale = max(0.7, currentResolutionScale - 0.05)
        } else if currentFPS > targetFPS && currentResolutionScale < 1.0 {
            // Increase quality
            currentResolutionScale = min(1.0, currentResolutionScale + 0.05)
        }

        applyResolutionScale(currentResolutionScale)
    }
}
```

---

## Save/Load System

### Persistence Architecture

```swift
class PersistenceManager {
    private let cloudKit = CKContainer.default()
    private let localCache = URL.documentsDirectory.appending(path: "realm_data")

    // Save entire realm state
    func saveRealm(_ realm: RealmData) async throws {
        // Save locally
        try await saveLocal(realm)

        // Sync to CloudKit
        try await syncToCloud(realm)
    }

    private func saveLocal(_ realm: RealmData) async throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(realm)
        try data.write(to: localCache)
    }

    private func syncToCloud(_ realm: RealmData) async throws {
        let record = CKRecord(recordType: "RealmData")
        record["realmID"] = realm.realmID.uuidString
        record["ownerID"] = realm.ownerID
        record["data"] = try JSONEncoder().encode(realm)

        let database = cloudKit.privateCloudDatabase
        try await database.save(record)
    }

    // Load realm state
    func loadRealm(realmID: UUID) async throws -> RealmData {
        // Try local cache first
        if let cached = try? await loadLocal(realmID) {
            return cached
        }

        // Fallback to cloud
        return try await loadFromCloud(realmID)
    }
}

// Spatial Anchor Persistence
class AnchorPersistence {
    func saveAnchors(_ anchors: [AnchorEntity]) async throws {
        for anchor in anchors {
            let anchorData = SpatialAnchorData(
                anchorID: anchor.id,
                worldTransform: anchor.transform.matrix,
                entityID: anchor.children.first?.id ?? UUID(),
                anchorType: .world
            )

            try await PersistenceManager.shared.saveAnchor(anchorData)
        }
    }

    func restoreAnchors() async throws -> [AnchorEntity] {
        let anchorData = try await PersistenceManager.shared.loadAnchors()

        return anchorData.map { data in
            let anchor = AnchorEntity(.world(transform: data.worldTransform))
            anchor.id = data.anchorID
            return anchor
        }
    }
}
```

---

## System Integration

### Event Bus

```swift
class EventBus {
    static let shared = EventBus()

    private var subscribers: [String: [(Any) -> Void]] = [:]

    func subscribe<T>(_ eventType: T.Type, handler: @escaping (T) -> Void) {
        let key = String(describing: eventType)
        let wrappedHandler: (Any) -> Void = { event in
            if let typedEvent = event as? T {
                handler(typedEvent)
            }
        }
        subscribers[key, default: []].append(wrappedHandler)
    }

    func publish<T>(_ event: T) {
        let key = String(describing: T.self)
        subscribers[key]?.forEach { handler in
            handler(event)
        }
    }
}

// Event Types
struct CombatGestureEvent {
    let gesture: CombatGesture
    let timestamp: Date
}

struct StateChangeEvent {
    let from: GameState
    let to: GameState
}

struct MultiplayerSyncEvent {
    let playerID: String
    let action: PlayerAction
}
```

---

## Conclusion

This architecture provides a scalable, performant foundation for Reality Realms RPG. The modular design allows for:

- **Extensibility**: New features can be added via components and systems
- **Performance**: Optimized for 90 FPS with dynamic quality scaling
- **Persistence**: Robust save/load with cloud synchronization
- **Multiplayer**: Built-in SharePlay and spatial synchronization
- **Spatial Gaming**: Full integration with visionOS spatial computing features

The architecture is designed to evolve with the game while maintaining strict performance budgets and providing an exceptional spatial gaming experience.
