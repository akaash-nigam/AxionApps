# Science Lab Sandbox - Technical Architecture

## Document Overview
This document defines the technical architecture for Science Lab Sandbox, a visionOS educational gaming application that transforms any space into a fully-equipped scientific laboratory.

**Version:** 1.0
**Last Updated:** 2025-01-20
**Target Platform:** visionOS 2.0+

---

## 1. High-Level Architecture

### 1.1 System Overview

```
┌─────────────────────────────────────────────────────────────┐
│                     Science Lab Sandbox                      │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │   SwiftUI    │  │  RealityKit  │  │    ARKit     │     │
│  │  Interface   │  │   3D Engine  │  │   Spatial    │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
│         │                 │                  │              │
│  ┌──────┴─────────────────┴──────────────────┴──────┐     │
│  │           Application Layer (Swift)              │     │
│  │  - Game Coordinator                              │     │
│  │  - Scene Management                              │     │
│  │  - State Management                              │     │
│  └──────────────────────────────────────────────────┘     │
│         │                                                   │
│  ┌──────┴───────────────────────────────────────────┐     │
│  │         Game Systems Layer                        │     │
│  │  - Physics System    - Input System              │     │
│  │  - Audio System      - Scientific Simulation     │     │
│  │  - AI Tutor System   - Save/Load System          │     │
│  └──────────────────────────────────────────────────┘     │
│         │                                                   │
│  ┌──────┴───────────────────────────────────────────┐     │
│  │      Entity-Component-System (ECS) Layer          │     │
│  │  - Laboratory Entities                            │     │
│  │  - Scientific Equipment Components                │     │
│  │  - Experiment Components                          │     │
│  └──────────────────────────────────────────────────┘     │
│         │                                                   │
│  ┌──────┴───────────────────────────────────────────┐     │
│  │           Data & Resources Layer                  │     │
│  │  - Experiment Definitions                         │     │
│  │  - 3D Models & Assets                             │     │
│  │  - Audio Resources                                │     │
│  │  - Scientific Data Tables                         │     │
│  └──────────────────────────────────────────────────┘     │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

### 1.2 Core Architectural Principles

1. **Entity-Component-System (ECS)**: Leverage RealityKit's native ECS for scientific equipment and experiments
2. **Spatial-First Design**: All interactions designed for 3D space manipulation
3. **Scientific Accuracy**: Realistic physics and chemical simulations
4. **Performance-Critical**: Target 90 FPS for smooth spatial experience
5. **Educational Focus**: Clear feedback, safety protocols, and learning support
6. **Modular Design**: Easy addition of new experiments and scientific disciplines

---

## 2. Game Architecture

### 2.1 Game Loop

```swift
// Main Game Loop (90 FPS target)
func update(deltaTime: TimeInterval) {
    // 1. Process Input (hand tracking, eye tracking, voice)
    inputSystem.processInput()

    // 2. Update Scientific Simulations
    scientificSimulationSystem.update(deltaTime)

    // 3. Update Physics
    physicsSystem.update(deltaTime)

    // 4. Update Game Logic
    experimentManager.update(deltaTime)

    // 5. Update AI Systems
    aiTutorSystem.update(deltaTime)

    // 6. Update Audio
    audioSystem.update(deltaTime)

    // 7. Update UI/HUD
    hudManager.update()

    // 8. Render Frame
    renderSystem.render()
}
```

### 2.2 State Management

```swift
enum GameState {
    case initializing
    case mainMenu
    case laboratorySelection
    case experimentSetup
    case activeExperiment
    case experimentAnalysis
    case paused
    case settings
}

class GameStateManager: ObservableObject {
    @Published var currentState: GameState = .initializing
    @Published var previousState: GameState?

    private var stateStack: [GameState] = []

    func transition(to newState: GameState) {
        previousState = currentState
        stateStack.append(currentState)
        currentState = newState
        handleStateEnter(newState)
    }

    func popState() {
        guard let state = stateStack.popLast() else { return }
        transition(to: state)
    }
}
```

### 2.3 Scene Graph

```
Root Scene
├── Laboratory Environment
│   ├── Chemistry Station
│   │   ├── Lab Bench (anchored to real table)
│   │   ├── Equipment Rack
│   │   └── Safety Zone
│   ├── Physics Playground
│   │   ├── Force Apparatus
│   │   └── Measurement Tools
│   ├── Biology Station
│   │   ├── Microscope
│   │   └── Specimen Display
│   └── Astronomy Observatory
│       ├── Celestial Display
│       └── Control Panel
├── UI Layer
│   ├── HUD Elements
│   ├── Menus
│   └── Data Displays
└── Audio Sources
    ├── Ambient Lab Sounds
    ├── Equipment Sounds
    └── Safety Alerts
```

---

## 3. VisionOS-Specific Gaming Patterns

### 3.1 Window System
```swift
// Main menu and 2D interfaces
struct MainMenuWindow: Scene {
    var body: some Scene {
        WindowGroup {
            MainMenuView()
        }
        .windowStyle(.plain)
        .defaultSize(width: 800, height: 600)
    }
}
```

### 3.2 Volume System
```swift
// Contained 3D experiments (beginner mode)
struct ChemistryVolumeScene: Scene {
    var body: some Scene {
        WindowGroup {
            RealityView { content in
                let chemistry = ChemistryLabEntity()
                content.add(chemistry)
            }
        }
        .windowStyle(.volumetric)
        .defaultSize(width: 1.0, height: 0.8, depth: 1.0, in: .meters)
    }
}
```

### 3.3 Immersive Space System
```swift
// Full laboratory experience
struct LaboratoryImmersiveSpace: Scene {
    @State private var immersionStyle: ImmersionStyle = .mixed

    var body: some Scene {
        ImmersiveSpace(id: "laboratory") {
            RealityView { content in
                let lab = await LaboratoryEnvironment.load()
                content.add(lab)
            }
        }
        .immersionStyle(selection: $immersionStyle, in: .mixed, .progressive, .full)
    }
}
```

### 3.4 Spatial Anchoring
```swift
class SpatialAnchorManager {
    private var anchors: [UUID: AnchorEntity] = [:]

    // Anchor lab equipment to real surfaces
    func anchorEquipment(_ entity: Entity, to surface: ARPlaneAnchor) {
        let anchor = AnchorEntity(plane: .horizontal)
        anchor.position = surface.transform.translation
        anchor.addChild(entity)
        anchors[entity.id] = anchor
    }

    // Persist anchors between sessions
    func saveAnchors() async throws {
        let data = try JSONEncoder().encode(anchors.mapValues { $0.transform })
        try data.write(to: anchorsURL)
    }
}
```

---

## 4. Game Data Models

### 4.1 Core Data Models

```swift
// Experiment Definition
struct Experiment: Codable, Identifiable {
    let id: UUID
    let name: String
    let discipline: ScientificDiscipline
    let difficulty: DifficultyLevel
    let description: String
    let learningObjectives: [String]
    let requiredEquipment: [EquipmentType]
    let safetyLevel: SafetyLevel
    let estimatedDuration: TimeInterval
    let prerequisites: [UUID]

    // Scientific parameters
    let variables: [ExperimentVariable]
    let expectedOutcomes: [OutcomeRange]
    let assessmentCriteria: [AssessmentCriterion]
}

// Scientific Equipment
struct ScientificEquipment: Codable, Identifiable {
    let id: UUID
    let type: EquipmentType
    let name: String
    let modelAsset: String
    let capabilities: [EquipmentCapability]
    let precision: Measurement<Unit>
    let operatingRange: ClosedRange<Double>
}

// Experiment Session
struct ExperimentSession: Codable {
    let id: UUID
    let experimentID: UUID
    let startTime: Date
    var endTime: Date?
    var observations: [Observation]
    var measurements: [Measurement]
    var hypothesis: String?
    var conclusion: String?
    var dataPoints: [DataPoint]
}

// Player Progress
struct PlayerProgress: Codable {
    var completedExperiments: Set<UUID>
    var masteredConcepts: Set<ScientificConcept>
    var skillLevels: [ScientificDiscipline: SkillLevel]
    var achievements: [Achievement]
    var totalLabTime: TimeInterval
    var safetyRecord: SafetyRecord
}
```

### 4.2 Scientific Enumerations

```swift
enum ScientificDiscipline: String, Codable {
    case chemistry
    case physics
    case biology
    case astronomy
    case earthScience
}

enum SafetyLevel: Int, Codable {
    case safe = 0
    case caution = 1
    case dangerous = 2
    case extreme = 3
}

enum EquipmentType: String, Codable {
    // Chemistry
    case beaker, flask, burner, testTube, pipette

    // Physics
    case forceSensor, motionTracker, voltmeter, oscilloscope

    // Biology
    case microscope, dissectionKit, petriDish, centrifuge

    // Astronomy
    case telescope, planetarium, spectrometer
}
```

---

## 5. RealityKit Gaming Components

### 5.1 Custom Components

```swift
// Scientific Equipment Component
struct EquipmentComponent: Component {
    var equipmentType: EquipmentType
    var isActive: Bool = false
    var currentReading: Double?
    var precision: Double
    var calibrationDate: Date
}

// Chemical Substance Component
struct ChemicalComponent: Component {
    var chemicalFormula: String
    var molarity: Double
    var volume: Measurement<UnitVolume>
    var temperature: Measurement<UnitTemperature>
    var pH: Double?
    var hazardLevel: SafetyLevel
}

// Physics Object Component
struct PhysicsObjectComponent: Component {
    var mass: Double
    var velocity: SIMD3<Float>
    var acceleration: SIMD3<Float>
    var appliedForces: [Force]
    var materialProperties: MaterialProperties
}

// Interactable Component
struct InteractableComponent: Component {
    var canGrab: Bool = true
    var canPour: Bool = false
    var canMeasure: Bool = false
    var requiredGesture: GestureType
    var hapticFeedback: HapticPattern
}

// Data Display Component
struct DataDisplayComponent: Component {
    var displayedValue: Double
    var unit: Unit
    var updateFrequency: TimeInterval
    var visualizationType: DataVisualizationType
}
```

### 5.2 Systems

```swift
// Scientific Simulation System
class ScientificSimulationSystem: System {
    static let query = EntityQuery(where: .has(ChemicalComponent.self))

    func update(context: SceneUpdateContext) {
        for entity in context.entities(matching: Self.query) {
            guard var chemical = entity.components[ChemicalComponent.self] else { continue }

            // Update chemical reactions
            updateChemicalReactions(&chemical, deltaTime: context.deltaTime)

            // Update physical properties
            updatePhysicalProperties(&chemical, deltaTime: context.deltaTime)

            entity.components[ChemicalComponent.self] = chemical
        }
    }

    private func updateChemicalReactions(_ chemical: inout ChemicalComponent, deltaTime: TimeInterval) {
        // Implement realistic chemical kinetics
        // Calculate reaction rates, equilibrium, etc.
    }
}

// Physics Simulation System
class PhysicsSimulationSystem: System {
    static let query = EntityQuery(where: .has(PhysicsObjectComponent.self))

    func update(context: SceneUpdateContext) {
        for entity in context.entities(matching: Self.query) {
            guard var physics = entity.components[PhysicsObjectComponent.self] else { continue }

            // Apply forces and calculate motion
            applyForces(&physics, deltaTime: context.deltaTime)
            updatePosition(entity, physics: physics, deltaTime: context.deltaTime)

            entity.components[PhysicsObjectComponent.self] = physics
        }
    }
}

// Interaction System
class InteractionSystem: System {
    func processHandTracking(_ handAnchor: HandAnchor, entities: [Entity]) {
        let pinchGesture = detectPinchGesture(handAnchor)

        if pinchGesture.isActive {
            if let target = findNearestInteractable(to: pinchGesture.location, in: entities) {
                handleInteraction(target, gesture: pinchGesture)
            }
        }
    }
}
```

---

## 6. ARKit Integration for Gameplay

### 6.1 Hand Tracking

```swift
class HandTrackingManager {
    private var handTracking: HandTrackingProvider?

    func startHandTracking() async {
        handTracking = HandTrackingProvider()
        try? await handTracking?.start()
    }

    func processHandGestures() -> [HandGesture] {
        guard let handTracking = handTracking else { return [] }

        var gestures: [HandGesture] = []

        // Detect pinch for grabbing
        if let pinch = detectPinch(handTracking.leftHand) {
            gestures.append(.pinch(hand: .left, strength: pinch.strength))
        }

        // Detect pour gesture
        if let pour = detectPourGesture(handTracking.rightHand) {
            gestures.append(.pour(hand: .right, angle: pour.angle))
        }

        return gestures
    }
}
```

### 6.2 Eye Tracking

```swift
class EyeTrackingManager {
    func getGazeTarget(in entities: [Entity]) -> Entity? {
        guard let gazeRay = currentGazeRay() else { return nil }

        // Find entity user is looking at
        let results = entities.compactMap { entity -> (Entity, Float)? in
            guard let collision = entity.collision else { return nil }
            guard let distance = gazeRay.intersects(collision) else { return nil }
            return (entity, distance)
        }

        return results.min(by: { $0.1 < $1.1 })?.0
    }
}
```

### 6.3 Spatial Mapping

```swift
class SpatialMappingManager {
    private var sceneReconstruction: SceneReconstructionProvider?

    func startSpatialMapping() async {
        sceneReconstruction = SceneReconstructionProvider()
        try? await sceneReconstruction?.start()
    }

    func findSuitableSurface(for equipment: EquipmentType) -> ARPlaneAnchor? {
        // Find horizontal surface for lab bench
        let planes = sceneReconstruction?.planes ?? []

        return planes.first { plane in
            plane.alignment == .horizontal &&
            plane.extent.x >= equipment.minimumSurfaceSize.x &&
            plane.extent.z >= equipment.minimumSurfaceSize.z
        }
    }
}
```

---

## 7. Multiplayer Architecture

### 7.1 Network Architecture

```swift
class MultiplayerManager: ObservableObject {
    @Published var connectedPeers: [Peer] = []
    @Published var isHost: Bool = false

    private var groupSession: GroupSession<LaboratoryActivity>?
    private var messenger: GroupSessionMessenger?

    // SharePlay Integration
    func startCollaborativeSession() async throws {
        let activity = LaboratoryActivity()

        switch await activity.prepareForActivation() {
        case .activationPreferred:
            _ = try await activity.activate()
        case .activationDisabled, .cancelled:
            return
        @unknown default:
            return
        }
    }

    // Sync experiment state
    func syncExperimentState(_ state: ExperimentState) async {
        guard let messenger = messenger else { return }

        let message = ExperimentSyncMessage(state: state, timestamp: Date())
        try? await messenger.send(message)
    }
}

// SharePlay Activity
struct LaboratoryActivity: GroupActivity {
    static let activityIdentifier = "com.eduspaces.sciencelab.collaborate"

    var metadata: GroupActivityMetadata {
        var metadata = GroupActivityMetadata()
        metadata.title = "Science Lab Collaboration"
        metadata.type = .generic
        return metadata
    }
}
```

### 7.2 State Synchronization

```swift
struct ExperimentSyncMessage: Codable {
    let experimentID: UUID
    let state: ExperimentState
    let timestamp: Date
    let authorID: String
}

class StateSync {
    private var pendingUpdates: [UUID: ExperimentSyncMessage] = [:]

    func reconcileState(local: ExperimentState, remote: ExperimentSyncMessage) -> ExperimentState {
        // Last-write-wins with timestamp
        if remote.timestamp > local.lastModified {
            return remote.state
        }
        return local
    }
}
```

---

## 8. Physics and Collision Systems

### 8.1 Physics Configuration

```swift
class PhysicsConfiguration {
    // Scientific accuracy settings
    static let gravity: SIMD3<Float> = [0, -9.81, 0]  // m/s²
    static let airDensity: Float = 1.225  // kg/m³
    static let timeStep: TimeInterval = 1.0 / 90.0  // 90 FPS

    // Collision layers
    enum CollisionLayer: UInt32 {
        case equipment = 0b0001
        case chemicals = 0b0010
        case specimens = 0b0100
        case environment = 0b1000
    }
}

class PhysicsManager {
    func configurePhysics(for entity: Entity) {
        // Add physics body
        let shape = ShapeResource.generateConvex(from: entity.model!.mesh)
        let physics = PhysicsBodyComponent(
            massProperties: .default,
            material: .generate(staticFriction: 0.6, dynamicFriction: 0.4, restitution: 0.3),
            mode: .dynamic
        )
        entity.components[PhysicsBodyComponent.self] = physics

        // Add collision
        entity.components[CollisionComponent.self] = CollisionComponent(shapes: [shape])
    }
}
```

### 8.2 Scientific Simulations

```swift
class ChemicalReactionEngine {
    // Simulate chemical reactions with real kinetics
    func calculateReactionRate(
        reactants: [Chemical],
        temperature: Double,
        catalyst: Chemical?
    ) -> Double {
        // Arrhenius equation: k = A * exp(-Ea / RT)
        let A = reactionFrequencyFactor
        let Ea = activationEnergy
        let R = 8.314  // J/(mol·K)
        let T = temperature + 273.15  // Convert to Kelvin

        var k = A * exp(-Ea / (R * T))

        if let catalyst = catalyst {
            k *= catalyst.catalyticFactor
        }

        return k
    }
}

class PhysicsSimulationEngine {
    // Simulate realistic physics with scientific accuracy
    func calculateTrajectory(
        initialVelocity: SIMD3<Float>,
        mass: Float,
        dragCoefficient: Float
    ) -> [SIMD3<Float>] {
        var positions: [SIMD3<Float>] = []
        var velocity = initialVelocity
        var position: SIMD3<Float> = .zero

        let deltaTime: Float = 1.0 / 90.0

        for _ in 0..<1000 {
            // Calculate drag force
            let speed = length(velocity)
            let dragForce = -0.5 * dragCoefficient * PhysicsConfiguration.airDensity * speed * speed * normalize(velocity)

            // Calculate acceleration
            let acceleration = PhysicsConfiguration.gravity + (dragForce / mass)

            // Update velocity and position
            velocity += acceleration * deltaTime
            position += velocity * deltaTime

            positions.append(position)

            if position.y < 0 { break }
        }

        return positions
    }
}
```

---

## 9. Audio Architecture

### 9.1 Spatial Audio System

```swift
class SpatialAudioManager {
    private var audioEngine = AVAudioEngine()
    private var environment = AVAudioEnvironmentNode()

    func setup() {
        audioEngine.attach(environment)
        audioEngine.connect(environment, to: audioEngine.mainMixerNode, format: nil)

        // Configure spatial audio
        environment.listenerPosition = AVAudio3DPoint(x: 0, y: 0, z: 0)
        environment.listenerAngularOrientation = AVAudio3DAngularOrientation(yaw: 0, pitch: 0, roll: 0)
    }

    func playSound(
        _ resource: AudioFileResource,
        at position: SIMD3<Float>,
        volume: Float = 1.0
    ) {
        let player = AVAudioPlayerNode()
        audioEngine.attach(player)
        audioEngine.connect(player, to: environment, format: nil)

        player.position = AVAudio3DPoint(x: position.x, y: position.y, z: position.z)
        player.volume = volume

        if let audioFile = try? AVAudioFile(forReading: resource.url) {
            player.scheduleFile(audioFile, at: nil)
            player.play()
        }
    }
}
```

### 9.2 Audio Categories

```swift
enum AudioCategory {
    case ambience        // Background lab sounds
    case equipment       // Equipment operation sounds
    case reaction        // Chemical reactions, explosions
    case measurement     // Beeps, clicks for measurements
    case safety          // Alerts and warnings
    case ui              // Menu sounds
    case voiceover       // AI tutor
}

class AudioResourceManager {
    private var audioCache: [String: AudioFileResource] = [:]

    func loadAudio(for category: AudioCategory) async {
        let resources = getAudioResources(for: category)

        for resource in resources {
            if let audio = try? await AudioFileResource(named: resource.name) {
                audioCache[resource.name] = audio
            }
        }
    }
}
```

---

## 10. Performance Optimization

### 10.1 Rendering Optimization

```swift
class RenderingOptimizer {
    // Level of Detail (LOD) system
    func applyLOD(for entity: Entity, distanceFromCamera: Float) {
        let lodLevel: Int

        switch distanceFromCamera {
        case 0..<1.0:
            lodLevel = 0  // High detail
        case 1.0..<3.0:
            lodLevel = 1  // Medium detail
        default:
            lodLevel = 2  // Low detail
        }

        if let model = entity.model {
            // Swap model mesh based on LOD
            entity.model?.mesh = getLODMesh(original: model.mesh, level: lodLevel)
        }
    }

    // Occlusion culling
    func cullOccludedEntities(_ entities: [Entity], camera: Camera) -> [Entity] {
        return entities.filter { entity in
            isVisible(entity, from: camera)
        }
    }
}
```

### 10.2 Memory Management

```swift
class ResourceManager {
    private var modelCache: [String: ModelEntity] = [:]
    private var textureCache: [String: TextureResource] = [:]
    private let maxCacheSize = 500 * 1024 * 1024  // 500 MB

    func loadModel(_ name: String) async -> ModelEntity? {
        if let cached = modelCache[name] {
            return cached.clone(recursive: true)
        }

        guard let model = try? await ModelEntity(named: name) else { return nil }

        // Add to cache if under size limit
        if currentCacheSize < maxCacheSize {
            modelCache[name] = model
        }

        return model
    }

    func clearUnusedResources() {
        // Remove least recently used resources
        let sortedModels = modelCache.sorted { $0.value.lastAccessTime < $1.value.lastAccessTime }

        for (key, _) in sortedModels.prefix(modelCache.count / 2) {
            modelCache.removeValue(forKey: key)
        }
    }
}
```

### 10.3 Frame Rate Targeting

```swift
class PerformanceMonitor {
    private var frameTimeHistory: [TimeInterval] = []
    private let targetFrameTime: TimeInterval = 1.0 / 90.0  // 90 FPS

    func update(deltaTime: TimeInterval) {
        frameTimeHistory.append(deltaTime)

        if frameTimeHistory.count > 100 {
            frameTimeHistory.removeFirst()
        }

        let averageFrameTime = frameTimeHistory.reduce(0, +) / Double(frameTimeHistory.count)

        if averageFrameTime > targetFrameTime * 1.1 {
            // Reduce quality settings
            applyPerformanceOptimizations()
        }
    }

    private func applyPerformanceOptimizations() {
        // Reduce particle effects
        // Lower LOD levels
        // Reduce shadow quality
        // Disable non-essential visual effects
    }
}
```

---

## 11. Save/Load System Architecture

### 11.1 Save System

```swift
class SaveManager {
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    func saveProgress(_ progress: PlayerProgress) async throws {
        let data = try encoder.encode(progress)
        try data.write(to: progressURL)
    }

    func saveExperiment(_ session: ExperimentSession) async throws {
        let data = try encoder.encode(session)
        let filename = "experiment_\(session.id.uuidString).json"
        try data.write(to: experimentsDirectory.appendingPathComponent(filename))
    }

    func loadProgress() async throws -> PlayerProgress {
        let data = try Data(contentsOf: progressURL)
        return try decoder.decode(PlayerProgress.self, from: data)
    }
}
```

### 11.2 Cloud Sync (Optional)

```swift
class CloudSyncManager {
    func syncToCloud(_ progress: PlayerProgress) async throws {
        // CloudKit integration for cross-device sync
        let record = CKRecord(recordType: "PlayerProgress")
        record["data"] = try JSONEncoder().encode(progress)

        try await CKContainer.default().publicCloudDatabase.save(record)
    }
}
```

---

## 12. AI Tutor Architecture

### 12.1 AI System

```swift
class AITutorSystem {
    private var llmInterface: LLMInterface
    private var knowledgeBase: ScientificKnowledgeBase

    func provideGuidance(
        for experiment: Experiment,
        currentState: ExperimentState,
        studentLevel: SkillLevel
    ) async -> TutorGuidance {
        let context = buildContext(experiment: experiment, state: currentState)

        let prompt = """
        You are a science tutor helping a \(studentLevel) student with \(experiment.name).
        Current state: \(context)
        Provide helpful guidance without giving away the answer.
        """

        let response = await llmInterface.query(prompt)

        return TutorGuidance(
            text: response,
            visualCues: generateVisualCues(for: currentState),
            suggestedActions: suggestNextSteps(currentState)
        )
    }

    func analyzeExperiment(_ session: ExperimentSession) -> ExperimentAnalysis {
        // Analyze student's experimental methodology
        let methodology = assessMethodology(session)
        let dataQuality = assessDataQuality(session)
        let conclusions = assessConclusions(session)

        return ExperimentAnalysis(
            methodologyScore: methodology,
            dataQualityScore: dataQuality,
            conclusionsScore: conclusions,
            feedback: generateFeedback(methodology, dataQuality, conclusions)
        )
    }
}
```

---

## 13. Directory Structure

```
ScienceLabSandbox/
├── App/
│   ├── ScienceLabSandboxApp.swift          # Main app entry
│   ├── GameCoordinator.swift                # Central coordinator
│   └── AppState.swift                       # App-wide state
├── Game/
│   ├── GameLogic/
│   │   ├── GameStateManager.swift
│   │   ├── ExperimentManager.swift
│   │   └── ProgressionManager.swift
│   ├── GameState/
│   │   ├── ExperimentState.swift
│   │   └── LaboratoryState.swift
│   ├── Entities/
│   │   ├── LaboratoryEntity.swift
│   │   ├── EquipmentEntity.swift
│   │   └── ChemicalEntity.swift
│   └── Components/
│       ├── EquipmentComponent.swift
│       ├── ChemicalComponent.swift
│       ├── PhysicsObjectComponent.swift
│       └── InteractableComponent.swift
├── Systems/
│   ├── PhysicsSystem/
│   │   ├── PhysicsSimulationSystem.swift
│   │   └── ChemicalReactionEngine.swift
│   ├── InputSystem/
│   │   ├── HandTrackingManager.swift
│   │   ├── EyeTrackingManager.swift
│   │   └── GestureRecognizer.swift
│   ├── AudioSystem/
│   │   ├── SpatialAudioManager.swift
│   │   └── AudioResourceManager.swift
│   └── AISystem/
│       ├── AITutorSystem.swift
│       └── ScientificKnowledgeBase.swift
├── Scenes/
│   ├── MenuScene/
│   │   └── MainMenuView.swift
│   ├── LaboratoryScene/
│   │   ├── LaboratoryEnvironment.swift
│   │   ├── ChemistryStation.swift
│   │   ├── PhysicsPlayground.swift
│   │   └── BiologyStation.swift
│   └── ImmersiveViews/
│       └── LaboratoryImmersiveView.swift
├── Views/
│   ├── UI/
│   │   ├── MainMenu/
│   │   ├── Settings/
│   │   └── ExperimentSelection/
│   └── HUD/
│       ├── DataDisplayView.swift
│       ├── SafetyIndicatorView.swift
│       └── MeasurementView.swift
├── Models/
│   ├── Experiment.swift
│   ├── ScientificEquipment.swift
│   ├── PlayerProgress.swift
│   └── ExperimentSession.swift
├── Resources/
│   ├── Assets.xcassets/
│   ├── 3DModels/
│   │   ├── Chemistry/
│   │   ├── Physics/
│   │   └── Biology/
│   ├── Audio/
│   │   ├── Ambience/
│   │   ├── Equipment/
│   │   └── Safety/
│   ├── Experiments/
│   │   └── ExperimentDefinitions.json
│   └── Data/
│       └── ScientificConstants.json
├── Utilities/
│   ├── Extensions/
│   ├── Helpers/
│   └── Constants.swift
└── Tests/
    ├── UnitTests/
    ├── IntegrationTests/
    └── PerformanceTests/
```

---

## 14. Technology Stack Summary

### Core Technologies
- **Language**: Swift 6.0+
- **UI Framework**: SwiftUI
- **3D Engine**: RealityKit
- **Spatial Tracking**: ARKit
- **Platform**: visionOS 2.0+
- **Physics**: RealityKit Physics + Custom Scientific Simulation
- **Audio**: AVFoundation Spatial Audio
- **Persistence**: SwiftData / Core Data
- **Networking**: GroupActivities (SharePlay)

### Key Frameworks
```swift
import SwiftUI
import RealityKit
import ARKit
import AVFoundation
import GameplayKit  // For AI behaviors
import Combine      // For reactive programming
import SwiftData    // For data persistence
import GroupActivities  // For multiplayer
```

---

## 15. Performance Targets

| Metric | Target | Critical |
|--------|--------|----------|
| Frame Rate | 90 FPS | 60 FPS minimum |
| Frame Time | 11.1 ms | 16.6 ms maximum |
| Memory Usage | < 2 GB | < 3 GB |
| Battery Life | 2.5 hours | 2 hours minimum |
| Network Latency | < 50 ms | < 100 ms |
| Asset Load Time | < 2 seconds | < 5 seconds |
| App Launch Time | < 3 seconds | < 5 seconds |

---

## 16. Security & Privacy

### Data Privacy
- All experiment data processed locally on device
- Optional cloud sync requires explicit consent
- No collection of spatial mapping data
- Student data encrypted at rest and in transit
- FERPA compliance for educational use

### Safety Protocols
- Virtual safety equipment and warnings
- Emergency stop functionality
- Clear distinction between virtual and real
- Age-appropriate content filtering
- Parental controls for younger users

---

## Conclusion

This architecture provides a solid foundation for building Science Lab Sandbox as a high-performance, educationally rigorous, and spatially immersive scientific laboratory experience on visionOS. The modular design allows for easy expansion of scientific disciplines and experiments while maintaining performance and educational quality.
