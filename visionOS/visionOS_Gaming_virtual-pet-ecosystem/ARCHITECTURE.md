# Virtual Pet Ecosystem - Technical Architecture

## Document Overview
This document defines the technical architecture for the Virtual Pet Ecosystem visionOS application, a spatial gaming experience where persistent AI companions live in users' physical spaces.

---

## 1. Game Architecture Overview

### 1.1 Core Architecture Principles
```
┌─────────────────────────────────────────────────────────┐
│                    Application Layer                     │
│  ┌─────────────┐  ┌──────────────┐  ┌───────────────┐  │
│  │   GameApp   │  │ Coordinator  │  │  App State    │  │
│  └─────────────┘  └──────────────┘  └───────────────┘  │
└─────────────────────────────────────────────────────────┘
                          │
┌─────────────────────────────────────────────────────────┐
│                  Game Systems Layer                      │
│  ┌──────────┐  ┌──────────┐  ┌────────┐  ┌──────────┐ │
│  │ Pet AI   │  │ Physics  │  │ Audio  │  │  Input   │ │
│  └──────────┘  └──────────┘  └────────┘  └──────────┘ │
└─────────────────────────────────────────────────────────┘
                          │
┌─────────────────────────────────────────────────────────┐
│              Entity-Component-System Layer               │
│  ┌──────────┐  ┌───────────┐  ┌──────────────────────┐ │
│  │ Entities │  │Components │  │  System Processors   │ │
│  └──────────┘  └───────────┘  └──────────────────────┘ │
└─────────────────────────────────────────────────────────┘
                          │
┌─────────────────────────────────────────────────────────┐
│              RealityKit Rendering Layer                  │
│  ┌──────────┐  ┌───────────┐  ┌──────────────────────┐ │
│  │  Scene   │  │ Materials │  │  Spatial Anchors     │ │
│  └──────────┘  └───────────┘  └──────────────────────┘ │
└─────────────────────────────────────────────────────────┘
```

### 1.2 Game Loop Architecture
```swift
// Main game loop running at 60 FPS
class GameLoop {
    private var displayLink: CADisplayLink?
    private var lastUpdateTime: TimeInterval = 0

    func start() {
        displayLink = CADisplayLink(target: self, selector: #selector(update))
        displayLink?.add(to: .current, forMode: .common)
    }

    @objc private func update() {
        let currentTime = CACurrentMediaTime()
        let deltaTime = currentTime - lastUpdateTime
        lastUpdateTime = currentTime

        // Update all game systems
        inputSystem.update(deltaTime: deltaTime)
        aiSystem.update(deltaTime: deltaTime)
        physicsSystem.update(deltaTime: deltaTime)
        animationSystem.update(deltaTime: deltaTime)
        audioSystem.update(deltaTime: deltaTime)
        spatialPersistenceSystem.update(deltaTime: deltaTime)

        // Render
        renderSystem.render()
    }
}
```

### 1.3 State Management
The application uses a hierarchical state machine with the following states:
- **InitializationState**: App startup and spatial mapping
- **PetSelectionState**: First-time user pet adoption
- **ActiveGameplayState**: Normal pet interaction and care
- **BreedingState**: Pet breeding UI and genetic combination
- **SocialState**: Pet visits and SharePlay sessions
- **SettingsState**: Configuration and preferences
- **BackgroundState**: App inactive but pets continue simulating

---

## 2. VisionOS-Specific Gaming Patterns

### 2.1 Spatial Modes

#### Window Mode (Initial Experience)
```swift
WindowGroup(id: "pet-selection") {
    PetSelectionView()
        .frame(width: 800, height: 600)
        .glassBackgroundEffect()
}
```

#### Volume Mode (Primary Gameplay)
```swift
WindowGroup(id: "pet-ecosystem") {
    PetEcosystemView()
        .volumeBasePlatform(.flat, size: CGSize(width: 2, height: 2))
}
.defaultWorldScaling(.dynamic)
.windowResizability(.contentSize)
```

#### Immersive Space Mode (Full Ecosystem)
```swift
ImmersiveSpace(id: "home-ecosystem") {
    RealityView { content in
        // Load pet entities and anchor to real-world locations
        let petScene = await PetSceneBuilder.buildHomeEcosystem()
        content.add(petScene)
    }
}
.immersionStyle(selection: .constant(.mixed), in: .mixed)
```

### 2.2 Spatial Interaction Zones
```
┌────────────────────────────────────────────┐
│  Far Field (3m+)                           │
│  - Pet territory awareness                 │
│  - Environmental observation               │
│                                            │
│  ┌──────────────────────────────────────┐ │
│  │ Mid Field (1m - 3m)                  │ │
│  │ - Pet play area                      │ │
│  │ - Status indicators                  │ │
│  │                                      │ │
│  │  ┌────────────────────────────────┐ │ │
│  │  │ Near Field (0.3m - 1m)         │ │ │
│  │  │ - Direct pet interaction       │ │ │
│  │  │ - Care tools                   │ │ │
│  │  │ - Petting and feeding          │ │ │
│  │  └────────────────────────────────┘ │ │
│  └──────────────────────────────────────┘ │
└────────────────────────────────────────────┘
```

---

## 3. Game Data Models and Schemas

### 3.1 Core Pet Model
```swift
/// Represents a persistent virtual pet with spatial awareness
struct Pet: Codable, Identifiable {
    let id: UUID
    var name: String
    var species: PetSpecies
    var birthDate: Date
    var lifeStage: LifeStage

    // Personality and AI
    var personality: PetPersonality
    var emotionalState: EmotionalState
    var memory: PetMemory

    // Physical attributes
    var health: Float // 0.0 - 1.0
    var happiness: Float // 0.0 - 1.0
    var energy: Float // 0.0 - 1.0
    var hunger: Float // 0.0 - 1.0

    // Spatial data
    var currentLocation: SpatialLocation
    var favoriteSpots: [SpatialAnchor]
    var territoryBounds: BoundingBox

    // Genetics
    var genetics: GeneticData
    var traits: [PetTrait]

    // Social
    var relationships: [UUID: RelationshipStrength]
    var familyTree: FamilyTree
}

enum PetSpecies: String, Codable {
    case luminos     // Light creatures
    case fluffkins   // Furry companions
    case crystalites // Geometric beings
    case aquarians   // Float like swimming
    case shadowlings // Shy creatures
}

enum LifeStage: String, Codable {
    case baby    // 0-30 days
    case youth   // 31-90 days
    case adult   // 91-365 days
    case elder   // 365+ days
}
```

### 3.2 Spatial Memory System
```swift
/// Pet's spatial memory and environmental learning
struct PetMemory: Codable {
    // Location preferences
    var favoriteSpots: [SpatialAnchor: Float] // Anchor -> Preference score
    var routinePatterns: [TimeOfDay: SpatialLocation]
    var exploredAreas: Set<RoomIdentifier>

    // Social connections
    var socialConnections: [UUID: RelationshipStrength]
    var interactionHistory: [InteractionEvent]

    // Learned behaviors
    var learnedBehaviors: [Behavior]
    var commandRecognition: [String: CommandResponse]

    // Environmental memory
    var furnitureMap: [ObjectAnchor: FurnitureType]
    var safeZones: [BoundingBox]
    var dangerZones: [BoundingBox]

    // Emotional timeline
    var emotionalHistory: CircularBuffer<EmotionalSnapshot>
}

struct SpatialLocation: Codable {
    var worldTransform: simd_float4x4
    var roomID: RoomIdentifier
    var surfaceType: SurfaceType
    var anchorID: UUID?
}
```

### 3.3 Personality System
```swift
/// AI-driven personality traits that evolve over time
struct PetPersonality: Codable {
    // Big Five personality traits (0.0 - 1.0)
    var openness: Float      // Curiosity and exploration
    var conscientiousness: Float // Routine adherence
    var extraversion: Float   // Social engagement
    var agreeableness: Float  // Friendliness
    var neuroticism: Float    // Emotional stability

    // Pet-specific traits
    var playfulness: Float
    var independence: Float
    var loyalty: Float
    var intelligence: Float
    var affectionNeed: Float

    // Dynamic modifiers
    var moodModifier: Float
    var environmentalInfluence: Float
    var socialInfluence: Float

    mutating func evolve(based on interaction: Interaction) {
        // AI-driven personality evolution
    }
}
```

### 3.4 Genetic System
```swift
/// Genetics for breeding and trait inheritance
struct GeneticData: Codable {
    var chromosomes: [Chromosome]
    var dominantTraits: [GeneticTrait]
    var recessiveTraits: [GeneticTrait]
    var mutations: [Mutation]

    static func combine(_ parent1: GeneticData, _ parent2: GeneticData) -> GeneticData {
        // Mendelian genetics with mutations
        var offspring = GeneticData()

        for i in 0..<parent1.chromosomes.count {
            let gene1 = parent1.chromosomes[i].randomGene()
            let gene2 = parent2.chromosomes[i].randomGene()
            offspring.chromosomes.append(Chromosome.combine(gene1, gene2))
        }

        // Random mutations (5% chance)
        if Float.random(in: 0...1) < 0.05 {
            offspring.mutations.append(Mutation.random())
        }

        return offspring
    }
}
```

---

## 4. RealityKit Gaming Components

### 4.1 Entity-Component Architecture
```swift
// Custom RealityKit components for pet behavior
struct PetBehaviorComponent: Component {
    var currentBehavior: BehaviorState
    var behaviorQueue: [BehaviorState]
    var targetLocation: SIMD3<Float>?
}

struct PetAnimationComponent: Component {
    var currentAnimation: AnimationResource?
    var animationController: AnimationPlaybackController?
    var blendTime: TimeInterval
}

struct PetPhysicsComponent: Component {
    var velocity: SIMD3<Float>
    var acceleration: SIMD3<Float>
    var mass: Float
    var friction: Float
}

struct PetAIComponent: Component {
    var decisionTree: BehaviorTree
    var perceptionRadius: Float
    var updateInterval: TimeInterval
    var lastUpdateTime: TimeInterval
}

struct SpatialAnchorComponent: Component {
    var anchorID: UUID
    var anchorType: AnchorType
    var persistenceEnabled: Bool
}
```

### 4.2 Pet Entity Builder
```swift
class PetEntityBuilder {
    static func build(pet: Pet) async throws -> Entity {
        let petEntity = Entity()

        // Load 3D model
        let model = try await ModelEntity.loadModel(named: pet.species.modelName)
        petEntity.addChild(model)

        // Add components
        petEntity.components[PetBehaviorComponent.self] = PetBehaviorComponent()
        petEntity.components[PetAnimationComponent.self] = PetAnimationComponent()
        petEntity.components[PetPhysicsComponent.self] = PetPhysicsComponent(
            mass: pet.species.baseMass
        )
        petEntity.components[PetAIComponent.self] = PetAIComponent(
            decisionTree: BehaviorTreeFactory.create(for: pet.personality)
        )

        // Add collision detection
        let collisionShape = ShapeResource.generateSphere(radius: 0.1)
        petEntity.components[CollisionComponent.self] = CollisionComponent(
            shapes: [collisionShape],
            mode: .trigger
        )

        // Add spatial anchor
        if let anchor = pet.currentLocation.anchorID {
            petEntity.components[SpatialAnchorComponent.self] = SpatialAnchorComponent(
                anchorID: anchor,
                anchorType: .world,
                persistenceEnabled: true
            )
        }

        return petEntity
    }
}
```

---

## 5. ARKit Integration for Gameplay

### 5.1 Spatial Mapping and Persistence
```swift
class SpatialPersistenceManager {
    private let arkitSession: ARKitSession
    private let worldTrackingProvider: WorldTrackingProvider
    private var persistentAnchors: [UUID: WorldAnchor] = [:]

    func initialize() async {
        let configuration = ARKitSession.Configuration([worldTrackingProvider])
        await arkitSession.run(configuration)

        // Load persistent anchors
        await loadSavedAnchors()
    }

    func createPetAnchor(at location: SIMD3<Float>) async -> UUID? {
        let anchor = WorldAnchor(originFromAnchorTransform: simd_float4x4(
            translation: location
        ))

        guard let tracked = try? await worldTrackingProvider.addAnchor(anchor) else {
            return nil
        }

        persistentAnchors[tracked.id] = tracked
        await savePersistentAnchor(tracked)

        return tracked.id
    }

    private func savePersistentAnchor(_ anchor: WorldAnchor) async {
        // Persist to disk for 24/7 pet locations
        let data = try? JSONEncoder().encode(anchor)
        UserDefaults.standard.set(data, forKey: "anchor_\(anchor.id)")
    }
}
```

### 5.2 Room Understanding
```swift
class RoomMappingSystem {
    private let sceneReconstructionProvider: SceneReconstructionProvider
    private var rooms: [RoomIdentifier: RoomData] = [:]

    func mapEnvironment() async {
        for await update in sceneReconstructionProvider.anchorUpdates {
            switch update.event {
            case .added:
                processNewAnchor(update.anchor)
            case .updated:
                updateAnchor(update.anchor)
            case .removed:
                removeAnchor(update.anchor)
            }
        }
    }

    func findSuitableSpots(for pet: Pet) -> [SpatialLocation] {
        var spots: [SpatialLocation] = []

        for (_, room) in rooms {
            // Find sunny spots for Luminos
            if pet.species == .luminos {
                spots.append(contentsOf: room.windowSills)
            }

            // Find soft surfaces for Fluffkins
            if pet.species == .fluffkins {
                spots.append(contentsOf: room.softSurfaces)
            }
        }

        return spots
    }
}
```

### 5.3 Hand Tracking for Interactions
```swift
class HandTrackingSystem {
    private let handTracking: HandTrackingProvider
    private var activeGestures: [GestureType: HandGesture] = [:]

    func detectPettingGesture() async -> Bool {
        guard let leftHand = await handTracking.leftHand,
              let rightHand = await handTracking.rightHand else {
            return false
        }

        // Detect stroking motion
        let velocity = leftHand.wrist.velocity
        let isStroking = velocity.magnitude > 0.1 && velocity.magnitude < 0.5

        return isStroking
    }

    func detectFeedingGesture() async -> (detected: Bool, foodItem: FoodType?) {
        guard let hand = await handTracking.dominantHand else {
            return (false, nil)
        }

        // Detect cupped hand posture
        let isCupped = checkCuppedHandPosture(hand)

        if isCupped {
            return (true, .treat)
        }

        return (false, nil)
    }
}
```

---

## 6. Multiplayer Architecture

### 6.1 SharePlay Integration
```swift
class SharePlayManager: ObservableObject {
    private var groupSession: GroupSession<PetVisitActivity>?
    private var messenger: GroupSessionMessenger?

    func startPetVisit(pet: Pet) async {
        let activity = PetVisitActivity(petID: pet.id)

        switch await activity.prepareForActivation() {
        case .activationPreferred:
            guard let session = try? await activity.activate() else { return }
            configureSession(session)
        case .activationDisabled, .cancelled:
            break
        @unknown default:
            break
        }
    }

    private func configureSession(_ session: GroupSession<PetVisitActivity>) {
        groupSession = session
        messenger = GroupSessionMessenger(session: session)

        session.join()

        // Sync pet state
        Task {
            for await message in messenger!.messages(of: PetStateUpdate.self) {
                await handlePetUpdate(message)
            }
        }
    }
}
```

### 6.2 Network Synchronization
```swift
protocol NetworkSyncable: Codable {
    var syncID: UUID { get }
    var lastSyncTime: Date { get set }
}

class NetworkSyncManager {
    func sync<T: NetworkSyncable>(_ object: T) async throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(object)

        // Send via messenger
        try await messenger?.send(data)
    }

    func receive<T: NetworkSyncable>() async throws -> T {
        guard let data = try await messenger?.receive() else {
            throw SyncError.noData
        }

        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    }
}
```

---

## 7. Physics and Collision Systems

### 7.1 Pet Physics
```swift
class PetPhysicsSystem {
    func update(deltaTime: TimeInterval) {
        for pet in activePets {
            // Apply gravity
            pet.physics.acceleration.y -= 9.8

            // Update velocity
            pet.physics.velocity += pet.physics.acceleration * Float(deltaTime)

            // Apply friction
            pet.physics.velocity *= (1.0 - pet.physics.friction)

            // Update position
            pet.position += pet.physics.velocity * Float(deltaTime)

            // Ground collision
            if pet.position.y <= 0 {
                pet.position.y = 0
                pet.physics.velocity.y = 0
                pet.physics.acceleration = .zero
            }
        }
    }
}
```

### 7.2 Collision Detection
```swift
class CollisionSystem {
    func detectCollisions() {
        for (petA, petB) in petPairs {
            if checkCollision(petA, petB) {
                handlePetCollision(petA, petB)
            }
        }

        for pet in pets {
            if let furniture = checkFurnitureCollision(pet) {
                handleFurnitureCollision(pet, furniture)
            }
        }
    }

    private func handlePetCollision(_ petA: Pet, _ petB: Pet) {
        // Social interaction based on relationship
        if petA.relationships[petB.id] ?? 0 > 0.7 {
            // Friendly interaction
            triggerPlayBehavior(petA, petB)
        } else {
            // Avoid or investigate
            triggerAvoidanceBehavior(petA, petB)
        }
    }
}
```

---

## 8. Audio Architecture

### 8.1 Spatial Audio System
```swift
class SpatialAudioManager {
    private var audioEngine: AVAudioEngine
    private var environment: AVAudioEnvironmentNode

    func playPetSound(_ sound: PetSound, at location: SIMD3<Float>) {
        let player = AVAudioPlayerNode()
        audioEngine.attach(player)

        // Position in 3D space
        player.position = AVAudio3DPoint(
            x: location.x,
            y: location.y,
            z: location.z
        )

        // Load audio file
        guard let file = try? AVAudioFile(forReading: sound.url) else { return }

        // Connect and play
        audioEngine.connect(player, to: environment, format: file.processingFormat)
        player.scheduleFile(file, at: nil)
        player.play()
    }

    func updateListenerPosition(_ position: SIMD3<Float>, orientation: simd_quatf) {
        environment.listenerPosition = AVAudio3DPoint(
            x: position.x,
            y: position.y,
            z: position.z
        )

        // Convert quaternion to forward/up vectors
        environment.listenerAngularOrientation = AVAudio3DAngularOrientation(
            from: orientation
        )
    }
}
```

### 8.2 Audio Categories
```
Pet Vocalizations:
├── Happy sounds (purrs, chirps)
├── Hungry sounds (whines, calls)
├── Playful sounds (barks, excited noises)
├── Sleepy sounds (yawns, settling)
└── Social sounds (greetings, responses)

Environmental Audio:
├── Footsteps (surface-dependent)
├── Eating sounds
├── Toy interaction sounds
└── Movement rustles

UI Audio:
├── Menu interactions
├── Care actions
├── Breeding sounds
└── Achievement unlocks
```

---

## 9. Performance Optimization

### 9.1 Frame Rate Target: 60 FPS
```swift
class PerformanceMonitor {
    private var frameCount: Int = 0
    private var lastFrameTime: CFTimeInterval = 0
    private var fps: Double = 0

    func update() {
        let currentTime = CACurrentMediaTime()
        frameCount += 1

        if currentTime - lastFrameTime >= 1.0 {
            fps = Double(frameCount) / (currentTime - lastFrameTime)

            if fps < 55 {
                // Performance degradation, reduce quality
                applyPerformanceOptimizations()
            }

            frameCount = 0
            lastFrameTime = currentTime
        }
    }

    private func applyPerformanceOptimizations() {
        // Reduce pet animation detail
        // Decrease particle effects
        // Simplify AI update frequency
    }
}
```

### 9.2 LOD System
```swift
class LODManager {
    enum DetailLevel {
        case high    // Within 2m
        case medium  // 2m - 5m
        case low     // 5m+
    }

    func updatePetLOD(_ pet: Pet, distance: Float) {
        let detailLevel: DetailLevel

        switch distance {
        case 0..<2:
            detailLevel = .high
        case 2..<5:
            detailLevel = .medium
        default:
            detailLevel = .low
        }

        applyLOD(pet, level: detailLevel)
    }

    private func applyLOD(_ pet: Pet, level: DetailLevel) {
        switch level {
        case .high:
            pet.animation.frameRate = 60
            pet.ai.updateFrequency = 0.016 // Every frame
            pet.particles.enabled = true
        case .medium:
            pet.animation.frameRate = 30
            pet.ai.updateFrequency = 0.1 // 10 Hz
            pet.particles.enabled = false
        case .low:
            pet.animation.frameRate = 15
            pet.ai.updateFrequency = 1.0 // 1 Hz
            pet.particles.enabled = false
        }
    }
}
```

### 9.3 Object Pooling
```swift
class ObjectPool<T> {
    private var availableObjects: [T] = []
    private var inUseObjects: Set<ObjectIdentifier> = []
    private let factory: () -> T

    init(factory: @escaping () -> T, initialCapacity: Int = 10) {
        self.factory = factory

        for _ in 0..<initialCapacity {
            availableObjects.append(factory())
        }
    }

    func acquire() -> T {
        if availableObjects.isEmpty {
            return factory()
        }

        let object = availableObjects.removeLast()
        inUseObjects.insert(ObjectIdentifier(object as AnyObject))
        return object
    }

    func release(_ object: T) {
        inUseObjects.remove(ObjectIdentifier(object as AnyObject))
        availableObjects.append(object)
    }
}

// Usage for particle effects
let particlePool = ObjectPool<ParticleEmitter> {
    ParticleEmitter()
}
```

---

## 10. Save/Load System Architecture

### 10.1 Persistence Layer
```swift
class PersistenceManager {
    private let fileManager = FileManager.default
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    private var saveDirectory: URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("PetEcosystem")
    }

    // Save pet data
    func save(_ pet: Pet) throws {
        try fileManager.createDirectory(at: saveDirectory, withIntermediateDirectories: true)

        let fileURL = saveDirectory.appendingPathComponent("\(pet.id).json")
        let data = try encoder.encode(pet)
        try data.write(to: fileURL, options: .atomic)

        // Also save to iCloud
        try saveToiCloud(pet)
    }

    // Load all pets
    func loadAllPets() throws -> [Pet] {
        let files = try fileManager.contentsOfDirectory(
            at: saveDirectory,
            includingPropertiesForKeys: nil
        )

        return try files.compactMap { url -> Pet? in
            guard url.pathExtension == "json" else { return nil }
            let data = try Data(contentsOf: url)
            return try decoder.decode(Pet.self, from: data)
        }
    }

    // Background simulation save
    func saveBackgroundState(_ state: BackgroundSimulationState) throws {
        let fileURL = saveDirectory.appendingPathComponent("background.json")
        let data = try encoder.encode(state)
        try data.write(to: fileURL, options: .atomic)
    }
}
```

### 10.2 Background Simulation
```swift
/// Simulates pet life when app is closed
class BackgroundSimulator {
    func simulate(pets: [Pet], timeElapsed: TimeInterval) -> [Pet] {
        var updatedPets = pets

        for i in 0..<updatedPets.count {
            // Calculate needs decay
            let hoursPassed = timeElapsed / 3600.0

            updatedPets[i].hunger = max(0, updatedPets[i].hunger - Float(hoursPassed) * 0.1)
            updatedPets[i].happiness -= Float(hoursPassed) * 0.05
            updatedPets[i].energy += Float(hoursPassed) * 0.15 // Resting recovers energy

            // Age the pet
            let ageDelta = TimeInterval(hoursPassed * 3600)
            updatedPets[i] = agePet(updatedPets[i], by: ageDelta)

            // Simulate basic behaviors
            updatedPets[i] = simulateBehaviors(updatedPets[i], duration: timeElapsed)
        }

        return updatedPets
    }

    private func simulateBehaviors(_ pet: Pet, duration: TimeInterval) -> Pet {
        var updated = pet

        // Pets might move to favorite spots
        if let favoriteSpot = pet.memory.favoriteSpots.max(by: { $0.value < $1.value }) {
            updated.currentLocation = SpatialLocation(
                worldTransform: favoriteSpot.key.transform,
                roomID: pet.currentLocation.roomID,
                surfaceType: .horizontal,
                anchorID: favoriteSpot.key.id
            )
        }

        return updated
    }
}
```

---

## 11. Testing Architecture

### 11.1 Unit Testing Framework
```swift
// Test data models
class PetModelTests: XCTestCase {
    func testPetCreation() {
        let pet = Pet(species: .luminos, name: "Spark")
        XCTAssertEqual(pet.species, .luminos)
        XCTAssertEqual(pet.name, "Spark")
        XCTAssertEqual(pet.lifeStage, .baby)
    }

    func testPersonalityEvolution() {
        var pet = Pet(species: .fluffkins, name: "Fluffy")
        let initialPlayfulness = pet.personality.playfulness

        // Simulate play interactions
        for _ in 0..<100 {
            pet.personality.evolve(based: Interaction.play)
        }

        XCTAssertGreaterThan(pet.personality.playfulness, initialPlayfulness)
    }
}
```

### 11.2 Integration Testing
```swift
class SpatialPersistenceTests: XCTestCase {
    var persistenceManager: SpatialPersistenceManager!

    override func setUp() async throws {
        persistenceManager = SpatialPersistenceManager()
        await persistenceManager.initialize()
    }

    func testAnchorCreation() async throws {
        let location = SIMD3<Float>(1, 0, -2)
        let anchorID = await persistenceManager.createPetAnchor(at: location)

        XCTAssertNotNil(anchorID)

        // Verify anchor persists
        let loaded = await persistenceManager.loadAnchor(anchorID!)
        XCTAssertNotNil(loaded)
    }
}
```

### 11.3 Performance Testing
```swift
class PerformanceTests: XCTestCase {
    func testAISystemPerformance() {
        let aiSystem = PetAISystem()
        let pets = (0..<10).map { _ in Pet.createRandom() }

        measure {
            aiSystem.update(pets: pets, deltaTime: 0.016)
        }
    }

    func testRenderingPerformance() {
        measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: false) {
            let scene = RealityKitScene()

            // Add 50 pets
            for _ in 0..<50 {
                scene.addPet(Pet.createRandom())
            }

            startMeasuring()

            // Simulate 60 frames
            for _ in 0..<60 {
                scene.update(deltaTime: 1.0/60.0)
            }

            stopMeasuring()
        }
    }
}
```

---

## 12. Deployment Architecture

### 12.1 App Bundle Structure
```
VirtualPetEcosystem.app/
├── Info.plist
├── Entitlements.plist
├── VirtualPetEcosystem (binary)
├── Resources/
│   ├── Assets.xcassets/
│   │   ├── AppIcon/
│   │   ├── PetIcons/
│   │   └── UIAssets/
│   ├── Models/
│   │   ├── Luminos.usdz
│   │   ├── Fluffkins.usdz
│   │   ├── Crystalites.usdz
│   │   ├── Aquarians.usdz
│   │   └── Shadowlings.usdz
│   ├── Audio/
│   │   ├── Vocalizations/
│   │   ├── Ambient/
│   │   └── UI/
│   └── Particles/
├── Frameworks/
│   ├── RealityKit.framework
│   ├── ARKit.framework
│   └── AVFoundation.framework
└── PlugIns/
    └── VirtualPetEcosystemTests.xctest/
```

### 12.2 Required Capabilities
```xml
<key>NSCameraUsageDescription</key>
<string>Camera access is required to map your home environment for pet exploration.</string>

<key>NSWorldSensingUsageDescription</key>
<string>World sensing enables pets to navigate and interact with your furniture.</string>

<key>NSHandsTrackingUsageDescription</key>
<string>Hand tracking allows natural petting and feeding gestures.</string>

<key>UIRequiredDeviceCapabilities</key>
<array>
    <string>arkit</string>
    <string>world-tracking</string>
    <string>hand-tracking</string>
</array>
```

---

## 13. Security & Privacy Architecture

### 13.1 Data Protection
```swift
class PrivacyManager {
    // All spatial data stays on-device
    private var spatialDataPolicy: DataPolicy = .localOnly

    // Only personality data syncs to iCloud (encrypted)
    func syncToCloud(_ pet: Pet) async throws {
        // Remove spatial data before upload
        var cloudPet = pet
        cloudPet.currentLocation = SpatialLocation.null
        cloudPet.favoriteSpots = []
        cloudPet.territoryBounds = .zero

        // Encrypt personality and genetics
        let encrypted = try encrypt(cloudPet)

        // Upload to iCloud
        try await CloudKitManager.shared.save(encrypted)
    }

    private func encrypt(_ pet: Pet) throws -> Data {
        let encoder = JSONEncoder()
        let data = try encoder.encode(pet)

        // Use on-device encryption
        return try CryptoKit.seal(data)
    }
}
```

---

## Summary

This architecture provides:
- **Persistent spatial pets** using ARKit anchors and RealityKit
- **AI-driven personalities** with environmental learning
- **60 FPS performance** through LOD and object pooling
- **Comprehensive testing** at unit, integration, and performance levels
- **Secure privacy** with local spatial data and encrypted cloud sync
- **Multiplayer support** via SharePlay
- **Background simulation** for true 24/7 pet life

The modular design allows for incremental implementation and testing while maintaining high performance for visionOS gaming.
