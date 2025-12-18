# Time Machine Adventures - Technical Architecture

## Game Architecture Overview

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────┐
│                     App Layer                            │
│  (GameApp.swift, GameCoordinator.swift)                 │
└────────────────┬────────────────────────────────────────┘
                 │
┌────────────────┴────────────────────────────────────────┐
│              Game Core Systems                           │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐ │
│  │ Game Loop    │  │ State Mgmt   │  │ Event Bus    │ │
│  │ (60-90 FPS)  │  │ (GameState)  │  │ (Publisher)  │ │
│  └──────────────┘  └──────────────┘  └──────────────┘ │
└─────────────────────────────────────────────────────────┘
                 │
┌────────────────┴────────────────────────────────────────┐
│         Entity-Component-System (ECS)                    │
│  ┌──────────────────────────────────────────────────┐  │
│  │ RealityKit Entities + Custom Components          │  │
│  │ - Artifacts, Characters, Environment Elements    │  │
│  └──────────────────────────────────────────────────┘  │
└────────────────┬────────────────────────────────────────┘
                 │
┌────────────────┴────────────────────────────────────────┐
│                  Game Systems                            │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐  │
│  │ Physics  │ │  Input   │ │  Audio   │ │   AI     │  │
│  │ System   │ │ System   │ │ System   │ │ System   │  │
│  └──────────┘ └──────────┘ └──────────┘ └──────────┘  │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐  │
│  │ Learning │ │ Progress │ │ Mystery  │ │ Environ  │  │
│  │ System   │ │ Tracking │ │ System   │ │ System   │  │
│  └──────────┘ └──────────┘ └──────────┘ └──────────┘  │
└─────────────────────────────────────────────────────────┘
                 │
┌────────────────┴────────────────────────────────────────┐
│              visionOS Integration                        │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐  │
│  │RealityKit│ │  ARKit   │ │SwiftUI   │ │Spatial   │  │
│  │          │ │          │ │          │ │ Audio    │  │
│  └──────────┘ └──────────┘ └──────────┘ └──────────┘  │
└─────────────────────────────────────────────────────────┘
```

### Game Loop Architecture

```swift
class GameLoop {
    private var lastUpdateTime: TimeInterval = 0
    private let targetFPS: Double = 90.0
    private let fixedDeltaTime: TimeInterval = 1.0 / 60.0

    func update(currentTime: TimeInterval) {
        let deltaTime = currentTime - lastUpdateTime

        // Fixed timestep for physics
        physicsSystem.update(fixedDeltaTime)

        // Variable timestep for rendering
        inputSystem.update(deltaTime)
        aiSystem.update(deltaTime)
        audioSystem.update(deltaTime)
        learningSystem.update(deltaTime)

        // Render
        renderSystem.render(deltaTime)

        lastUpdateTime = currentTime
    }
}
```

### State Management Architecture

```swift
enum GameState {
    case loading
    case mainMenu
    case roomCalibration
    case tutorial
    case exploring(era: HistoricalEra)
    case examiningArtifact(artifact: Artifact)
    case conversing(character: HistoricalCharacter)
    case solvingMystery(mystery: Mystery)
    case assessment
    case paused
}

class GameStateManager: ObservableObject {
    @Published var currentState: GameState = .loading
    @Published var previousState: GameState?

    private var stateHistory: [GameState] = []
    private let eventBus: EventBus

    func transition(to newState: GameState) {
        previousState = currentState
        stateHistory.append(currentState)
        currentState = newState
        eventBus.publish(.stateChanged(from: previousState, to: newState))
    }
}
```

## visionOS-Specific Gaming Patterns

### Window, Volume, and Immersive Space Strategy

#### Window Mode (Tutorial & Setup)
- **Purpose**: Gentle introduction, settings, teacher dashboard
- **Implementation**: SwiftUI windows for 2D content
- **Size**: Standard window sizes (800x600)
- **Use Cases**: Main menu, settings, progress review

#### Volume Mode (Artifact Examination)
- **Purpose**: Detailed artifact study in bounded space
- **Implementation**: 3D bounded volume (1m³)
- **Content**: Rotating artifacts, detailed information overlays
- **Interaction**: Pinch-to-rotate, zoom gestures

#### Immersive Space (Historical Environments)
- **Purpose**: Full room transformation into historical periods
- **Implementation**: Mixed reality with environmental overlays
- **Modes**:
  - **Mixed**: Room visible with historical overlays
  - **Progressive**: Gradual environment transformation
  - **Full**: Complete historical immersion (limited duration)

```swift
enum SpatialMode {
    case window
    case volume(size: SIMD3<Float>)
    case immersiveSpace(level: ImmersionLevel)
}

enum ImmersionLevel {
    case mixed        // Room visible + historical elements
    case progressive  // 50% room / 50% historical
    case full         // Complete immersion (20min max)
}
```

### Room Mapping and Spatial Anchors

```swift
class RoomMappingSystem {
    private let arSession: ARKitSession
    private var roomAnchors: [UUID: AnchorEntity] = [:]
    private var persistentAnchors: [String: WorldAnchor] = [:]

    // Scan room and identify surfaces
    func calibrateRoom() async throws {
        let authorization = await arSession.requestAuthorization(for: [.worldSensing])

        // Detect planes for artifact placement
        let planeAnchors = await detectPlanes()

        // Identify walls for timeline display
        let wallSurfaces = await identifyWalls()

        // Create safe play boundaries
        let playBoundary = await defineSafeArea()

        // Store persistent anchors for artifact locations
        await createPersistentAnchors()
    }

    // Place artifacts on detected surfaces
    func placeArtifact(_ artifact: Artifact, on surface: PlaneAnchor) {
        let anchorEntity = AnchorEntity(anchor: surface)
        let artifactEntity = createArtifactEntity(artifact)
        anchorEntity.addChild(artifactEntity)

        // Store for persistence
        roomAnchors[surface.id] = anchorEntity
    }
}
```

## Game Data Models and Schemas

### Core Data Models

```swift
// Historical Era
struct HistoricalEra: Codable, Identifiable {
    let id: UUID
    let name: String
    let period: DateInterval
    let civilization: String
    let difficulty: DifficultyLevel
    let artifacts: [Artifact]
    let characters: [HistoricalCharacter]
    let mysteries: [Mystery]
    let environmentAssets: EnvironmentAssets
    let educationalStandards: [CurriculumStandard]
}

// Artifact
struct Artifact: Codable, Identifiable {
    let id: UUID
    let name: String
    let era: HistoricalEra
    let modelResource: String
    let description: String
    let historicalContext: String
    let educationalValue: [LearningObjective]
    let interactionPoints: [InteractionPoint]
    let rarity: Rarity
    let unlockConditions: [Condition]
}

// Historical Character
struct HistoricalCharacter: Codable, Identifiable {
    let id: UUID
    let name: String
    let era: HistoricalEra
    let role: String
    let knowledgeDomains: [String]
    let personalityTraits: [PersonalityTrait]
    let dialogueDatabase: String
    let teachingStyle: TeachingStyle
    let aiModelConfig: AIConfig
}

// Mystery
struct Mystery: Codable, Identifiable {
    let id: UUID
    let title: String
    let era: HistoricalEra
    let difficulty: DifficultyLevel
    let objectives: [MysteryObjective]
    let clues: [Clue]
    let artifacts: [Artifact]
    let historicalAccuracy: Double
    let educationalStandards: [CurriculumStandard]
    let estimatedDuration: TimeInterval
}

// Player Progress
struct PlayerProgress: Codable {
    var id: UUID
    var age: Int
    var gradeLevel: Int
    var exploredEras: Set<UUID>
    var discoveredArtifacts: Set<UUID>
    var completedMysteries: Set<UUID>
    var metCharacters: Set<UUID>
    var learningProfile: LearningProfile
    var assessmentResults: [AssessmentResult]
    var playTime: TimeInterval
    var lastPlayed: Date
}
```

### Data Persistence

```swift
class DataManager {
    private let cloudKitManager: CloudKitManager
    private let localStorageManager: LocalStorageManager

    // Save player progress
    func saveProgress(_ progress: PlayerProgress) async throws {
        // Save locally first for offline support
        try await localStorageManager.save(progress)

        // Sync to iCloud if available
        try await cloudKitManager.syncProgress(progress)
    }

    // Load historical content
    func loadEra(_ eraId: UUID) async throws -> HistoricalEra {
        // Check local cache
        if let cachedEra = localStorageManager.loadEra(eraId) {
            return cachedEra
        }

        // Download from CDN
        let era = try await downloadEra(eraId)

        // Cache locally
        try await localStorageManager.cache(era)

        return era
    }
}
```

## RealityKit Gaming Components and Systems

### Custom Components

```swift
// Artifact Component
struct ArtifactComponent: Component {
    var artifactData: Artifact
    var isDiscovered: Bool = false
    var examinationProgress: Double = 0.0
    var interactionState: InteractionState = .idle
}

// Historical Character Component
struct CharacterComponent: Component {
    var characterData: HistoricalCharacter
    var conversationState: ConversationState
    var knowledgeBase: KnowledgeBase
    var emotionalState: EmotionalState
}

// Interactive Component
struct InteractiveComponent: Component {
    var interactionType: InteractionType
    var isInteractable: Bool = true
    var hoverState: HoverState = .none
    var selectionState: SelectionState = .none
}

// Educational Component
struct EducationalComponent: Component {
    var learningObjectives: [LearningObjective]
    var difficultyLevel: DifficultyLevel
    var completionStatus: CompletionStatus
    var assessmentData: AssessmentData?
}
```

### Custom Systems

```swift
// Artifact Interaction System
class ArtifactInteractionSystem: System {
    static let query = EntityQuery(where: .has(ArtifactComponent.self))

    func update(context: SceneUpdateContext) {
        for entity in context.entities(matching: Self.query, updatingSystemWhen: .rendering) {
            guard var artifact = entity.components[ArtifactComponent.self] else { continue }

            // Check for gaze interaction
            if inputSystem.isGazingAt(entity) {
                artifact.interactionState = .highlighted
                displayArtifactInfo(artifact)
            }

            // Check for pinch gesture
            if inputSystem.isPinching(at: entity.position) {
                openDetailedExamination(artifact)
            }

            entity.components[ArtifactComponent.self] = artifact
        }
    }
}

// Character AI System
class CharacterAISystem: System {
    static let query = EntityQuery(where: .has(CharacterComponent.self))
    private let llmService: LLMService

    func update(context: SceneUpdateContext) {
        for entity in context.entities(matching: Self.query, updatingSystemWhen: .rendering) {
            guard var character = entity.components[CharacterComponent.self] else { continue }

            // Update character behaviors
            updateConversationState(&character)
            updateEmotionalResponse(&character)
            updateTeachingAdaptation(&character)

            entity.components[CharacterComponent.self] = character
        }
    }

    private func updateConversationState(_ character: inout CharacterComponent) {
        // AI-driven dialogue management
        if character.conversationState == .responding {
            Task {
                let response = await llmService.generateResponse(
                    character: character.characterData,
                    context: conversationContext
                )
                character.conversationState = .listening
            }
        }
    }
}
```

## ARKit Integration for Gameplay

### Spatial Tracking

```swift
class SpatialTrackingSystem {
    private let arSession: ARKitSession
    private let worldTracking: WorldTrackingProvider
    private let handTracking: HandTrackingProvider

    func startTracking() async {
        // Configure tracking
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        configuration.environmentTexturing = .automatic

        // Run session
        try await arSession.run([worldTracking, handTracking])

        // Monitor tracking quality
        monitorTrackingQuality()
    }

    func getPlayerHeadPose() -> simd_float4x4? {
        return worldTracking.queryDeviceAnchor(atTimestamp: CACurrentMediaTime())?.originFromAnchorTransform
    }
}
```

### Hand Tracking for Artifact Manipulation

```swift
class HandInteractionSystem {
    private let handTracking: HandTrackingProvider

    func detectArtifactGrab() -> GrabGesture? {
        guard let leftHand = handTracking.leftHand,
              let rightHand = handTracking.rightHand else {
            return nil
        }

        // Detect pinch gesture
        let leftPinch = detectPinch(hand: leftHand)
        let rightPinch = detectPinch(hand: rightHand)

        if leftPinch || rightPinch {
            return GrabGesture(
                hand: leftPinch ? .left : .right,
                position: leftPinch ? leftHand.thumbTip.position : rightHand.thumbTip.position
            )
        }

        return nil
    }

    private func detectPinch(hand: HandAnchor) -> Bool {
        let thumbTip = hand.thumbTip.position
        let indexTip = hand.indexFingerTip.position
        let distance = simd_distance(thumbTip, indexTip)

        return distance < 0.02 // 2cm threshold
    }
}
```

### Eye Tracking for Educational Analytics

```swift
class EyeTrackingSystem {
    private var gazeHistory: [GazeEvent] = []
    private let analyticsService: AnalyticsService

    func trackArtifactAttention(artifact: Entity) {
        guard let gazeDirection = getCurrentGazeDirection() else { return }

        // Check if gazing at artifact
        if isGazingAt(entity: artifact, gazeDirection: gazeDirection) {
            recordGazeEvent(GazeEvent(
                target: artifact.id,
                timestamp: Date(),
                duration: calculateGazeDuration(artifact)
            ))

            // Trigger educational overlay after sustained gaze
            if calculateGazeDuration(artifact) > 2.0 {
                displayEducationalInfo(artifact)
            }
        }
    }

    func getEngagementMetrics() -> EngagementMetrics {
        // Analyze gaze patterns for learning analytics
        return EngagementMetrics(
            focusedArtifacts: gazeHistory.filter { $0.duration > 3.0 },
            attentionSpan: calculateAverageAttentionSpan(),
            explorationPattern: analyzeExplorationPattern()
        )
    }
}
```

## Physics and Collision Systems

### Physics Configuration

```swift
class PhysicsSystem {
    private var physicsWorld: PhysicsSimulation

    init() {
        physicsWorld = PhysicsSimulation()
        physicsWorld.gravity = [0, -9.81, 0] // Standard gravity
    }

    func configureArtifact(_ entity: Entity, artifact: Artifact) {
        // Add physics body with realistic properties
        let physicsBody = PhysicsBodyComponent(
            massProperties: .init(mass: artifact.mass),
            material: .init(
                staticFriction: 0.6,
                dynamicFriction: 0.4,
                restitution: 0.3
            ),
            mode: .dynamic
        )

        entity.components[PhysicsBodyComponent.self] = physicsBody

        // Add collision shape
        let collisionShape = ShapeResource.generateConvex(from: artifact.mesh)
        entity.components[CollisionComponent.self] = CollisionComponent(shapes: [collisionShape])
    }
}
```

### Collision Detection for Artifacts

```swift
class CollisionSystem: System {
    func handleCollision(_ event: CollisionEvents.Began) {
        let entityA = event.entityA
        let entityB = event.entityB

        // Check if artifact touched surface
        if entityA.components.has(ArtifactComponent.self),
           entityB.components.has(SurfaceComponent.self) {

            // Play appropriate sound
            audioSystem.playCollisionSound(
                material: entityA.components[ArtifactComponent.self]?.artifactData.material,
                velocity: event.collisionImpulse
            )

            // Haptic feedback
            hapticsSystem.playCollisionHaptic(intensity: event.collisionImpulse.magnitude)
        }
    }
}
```

## Audio Architecture

### Spatial Audio System

```swift
class SpatialAudioSystem {
    private var audioEngine: AVAudioEngine
    private var environmentNode: AVAudioEnvironmentNode
    private var audioSources: [UUID: AVAudioPlayerNode] = [:]

    init() {
        audioEngine = AVAudioEngine()
        environmentNode = AVAudioEnvironmentNode()

        // Configure spatial audio
        environmentNode.listenerPosition = AVAudio3DPoint(x: 0, y: 0, z: 0)
        environmentNode.renderingAlgorithm = .HRTF

        audioEngine.attach(environmentNode)
        audioEngine.connect(environmentNode, to: audioEngine.mainMixerNode, format: nil)
    }

    func playHistoricalAmbiance(era: HistoricalEra, at position: SIMD3<Float>) {
        let audioFile = loadAudioFile(era.ambianceFile)
        let playerNode = AVAudioPlayerNode()

        audioEngine.attach(playerNode)
        audioEngine.connect(playerNode, to: environmentNode, format: audioFile.processingFormat)

        // Position in 3D space
        playerNode.position = AVAudio3DPoint(
            x: position.x,
            y: position.y,
            z: position.z
        )

        playerNode.scheduleFile(audioFile, at: nil, completionHandler: nil)
        playerNode.play()

        audioSources[era.id] = playerNode
    }
}
```

### Period-Accurate Sound Design

```swift
struct HistoricalSoundscape {
    let era: HistoricalEra
    let ambientLoops: [AudioFile]
    let characterVoices: [String: AudioFile]
    let sfxLibrary: [SoundEffect: AudioFile]

    func getAmbianceForEnvironment() -> [PositionedAudio] {
        switch era.name {
        case "Ancient Egypt":
            return [
                PositionedAudio(file: "nile_water.wav", position: [10, 0, 0]),
                PositionedAudio(file: "market_chatter.wav", position: [-5, 0, 5]),
                PositionedAudio(file: "construction.wav", position: [0, 0, -10])
            ]
        case "Medieval Castle":
            return [
                PositionedAudio(file: "torch_crackle.wav", position: [0, 2, -2]),
                PositionedAudio(file: "distant_bells.wav", position: [20, 0, 0]),
                PositionedAudio(file: "armor_clanking.wav", position: [5, 0, 3])
            ]
        default:
            return []
        }
    }
}
```

## Performance Optimization

### Level of Detail (LOD) System

```swift
class LODSystem: System {
    private let lodDistances: [Float] = [1.0, 3.0, 5.0, 10.0]

    func update(context: SceneUpdateContext) {
        guard let cameraPosition = getCameraPosition() else { return }

        for entity in context.scene.performQuery(EntityQuery(where: .has(ModelComponent.self))) {
            let distance = simd_distance(entity.position, cameraPosition)
            let lodLevel = determineLODLevel(distance: distance)

            applyLOD(entity: entity, level: lodLevel)
        }
    }

    private func determineLODLevel(distance: Float) -> Int {
        for (index, threshold) in lodDistances.enumerated() {
            if distance < threshold {
                return index
            }
        }
        return lodDistances.count
    }

    private func applyLOD(entity: Entity, level: Int) {
        guard var modelComponent = entity.components[ModelComponent.self] else { return }

        // Switch to appropriate LOD mesh
        let lodMesh = loadLODMesh(entity: entity, level: level)
        modelComponent.mesh = lodMesh

        entity.components[ModelComponent.self] = modelComponent
    }
}
```

### Memory Management

```swift
class AssetManager {
    private var loadedAssets: [UUID: Any] = [:]
    private var assetAccessTimes: [UUID: Date] = [:]
    private let maxMemoryMB: Int = 2048

    func loadEra(_ era: HistoricalEra) async throws {
        // Unload least recently used assets if needed
        if getCurrentMemoryUsage() > maxMemoryMB * 0.8 {
            unloadLRUAssets()
        }

        // Load era assets progressively
        await loadCriticalAssets(era) // Characters, key artifacts
        await loadEnvironmentAssets(era) // Background, ambiance
        await loadOptionalAssets(era) // Additional details
    }

    private func unloadLRUAssets() {
        let sortedAssets = assetAccessTimes.sorted { $0.value < $1.value }

        for (assetId, _) in sortedAssets.prefix(10) {
            loadedAssets.removeValue(forKey: assetId)
            assetAccessTimes.removeValue(forKey: assetId)
        }
    }
}
```

### Frame Rate Optimization

```swift
class PerformanceMonitor {
    private var frameTimings: [TimeInterval] = []
    private let targetFPS: Double = 90.0

    func monitorFrame(deltaTime: TimeInterval) {
        frameTimings.append(deltaTime)

        if frameTimings.count > 60 {
            frameTimings.removeFirst()
        }

        let averageFPS = 1.0 / (frameTimings.reduce(0, +) / Double(frameTimings.count))

        // Adjust quality if below target
        if averageFPS < targetFPS * 0.9 {
            adjustQualitySettings()
        }
    }

    private func adjustQualitySettings() {
        // Reduce shadow quality
        // Lower texture resolution
        // Reduce particle effects
        // Simplify physics calculations
    }
}
```

## Save/Load System Architecture

```swift
class SaveSystem {
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    func saveGame() async throws {
        let saveData = GameSaveData(
            progress: playerProgress,
            discoveredArtifacts: artifactManager.discovered,
            conversationHistory: aiSystem.conversationHistory,
            mysteryProgress: mysteryManager.progress,
            timestamp: Date()
        )

        // Save locally
        let localURL = getLocalSaveURL()
        let data = try encoder.encode(saveData)
        try data.write(to: localURL)

        // Backup to iCloud
        try await cloudKitManager.saveToCl oud(saveData)
    }

    func loadGame() async throws -> GameSaveData {
        // Try iCloud first
        if let cloudData = try? await cloudKitManager.loadFromCloud() {
            return cloudData
        }

        // Fallback to local
        let localURL = getLocalSaveURL()
        let data = try Data(contentsOf: localURL)
        return try decoder.decode(GameSaveData.self, from: data)
    }
}
```

## Multiplayer Architecture (SharePlay)

```swift
class MultiplayerManager {
    private var groupSession: GroupSession<TimeMachineActivity>?
    private var messenger: GroupSessionMessenger?

    func startSharePlay() async throws {
        let activity = TimeMachineActivity()

        switch await activity.prepareForActivation() {
        case .activationPreferred:
            let session = try GroupSession(activity)
            configureGroupSession(session)
        case .activationDisabled:
            // Fall back to single player
            break
        default:
            break
        }
    }

    private func configureGroupSession(_ session: GroupSession<TimeMachineActivity>) {
        groupSession = session
        messenger = GroupSessionMessenger(session: session)

        session.$activeParticipants
            .sink { participants in
                self.syncGameState(with: participants)
            }
            .store(in: &cancellables)

        session.join()
    }

    func syncArtifactDiscovery(_ artifact: Artifact) {
        Task {
            try? await messenger?.send(
                DiscoveryEvent(artifactId: artifact.id),
                to: .all
            )
        }
    }
}
```

## System Integration

### Main Game Coordinator

```swift
@MainActor
class GameCoordinator: ObservableObject {
    // Core systems
    let stateManager: GameStateManager
    let inputSystem: InputSystem
    let physicsSystem: PhysicsSystem
    let audioSystem: SpatialAudioSystem
    let aiSystem: CharacterAISystem
    let learningSystem: AdaptiveLearningSystem

    // Managers
    let dataManager: DataManager
    let assetManager: AssetManager
    let roomManager: RoomMappingSystem
    let multiplayerManager: MultiplayerManager

    // RealityKit
    var immersiveSpace: ImmersiveSpace?
    var rootEntity: Entity?

    init() {
        // Initialize all systems
        self.stateManager = GameStateManager()
        self.inputSystem = InputSystem()
        self.physicsSystem = PhysicsSystem()
        self.audioSystem = SpatialAudioSystem()
        self.aiSystem = CharacterAISystem()
        self.learningSystem = AdaptiveLearningSystem()

        self.dataManager = DataManager()
        self.assetManager = AssetManager()
        self.roomManager = RoomMappingSystem()
        self.multiplayerManager = MultiplayerManager()

        setupSystems()
    }

    private func setupSystems() {
        // Register system dependencies
        inputSystem.delegate = self
        stateManager.eventBus.subscribe(self)
    }

    func startGame() async {
        // Load player progress
        let progress = try? await dataManager.loadProgress()

        // Calibrate room
        try? await roomManager.calibrateRoom()

        // Enter main menu
        stateManager.transition(to: .mainMenu)
    }
}
```

This architecture provides a solid foundation for building Time Machine Adventures with:
- **Scalable ECS design** for game entities
- **visionOS-specific patterns** for spatial computing
- **Performance optimization** targeting 90 FPS
- **Educational systems** integrated throughout
- **Multiplayer support** via SharePlay
- **Robust save/load** with cloud backup
- **AI-driven characters** for adaptive learning

The architecture is designed to be maintainable, performant, and aligned with Apple's visionOS best practices for gaming applications.
