# Parkour Pathways - Technical Architecture
*visionOS Spatial Gaming Application*

## Document Overview

This document defines the technical architecture for Parkour Pathways, a visionOS spatial gaming application that transforms indoor spaces into dynamic parkour training environments. The architecture emphasizes performance (90 FPS target), safety, and seamless integration with the user's physical environment.

---

## 1. System Architecture Overview

### 1.1 High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     Application Layer                       │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │ SwiftUI Views│  │ Game Scenes  │  │ Menu System  │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                    Game Logic Layer                         │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │  Game State  │  │ ECS Systems  │  │ AI Director  │     │
│  │  Management  │  │   Manager    │  │              │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                  Core Systems Layer                         │
│  ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐          │
│  │ Physics │ │ Input   │ │ Audio   │ │ Spatial │          │
│  │ System  │ │ System  │ │ System  │ │ Mapping │          │
│  └─────────┘ └─────────┘ └─────────┘ └─────────┘          │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│               visionOS Framework Layer                      │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │  RealityKit  │  │    ARKit     │  │   SwiftUI    │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
└─────────────────────────────────────────────────────────────┘
```

### 1.2 Core Architectural Principles

1. **Entity-Component-System (ECS)**: Leveraging RealityKit's ECS architecture for game objects
2. **Reactive State Management**: Using Combine framework for state propagation
3. **Async/Await Patterns**: Swift concurrency for asynchronous operations
4. **Spatial-First Design**: All systems optimized for 3D spatial interaction
5. **Safety-Critical Architecture**: Multiple layers of safety validation and boundary enforcement

---

## 2. Game Architecture

### 2.1 Game Loop Architecture

```swift
// Main Game Loop Structure
class GameLoop {
    // Target: 90 FPS (11.1ms per frame)
    private var displayLink: CADisplayLink?
    private let targetFrameTime: TimeInterval = 1.0/90.0

    func update(deltaTime: TimeInterval) {
        // Phase 1: Input Processing (< 1ms)
        inputSystem.processInput()

        // Phase 2: Game Logic Update (< 3ms)
        aiDirector.update(deltaTime)
        gameState.update(deltaTime)

        // Phase 3: Physics Simulation (< 2ms)
        physicsWorld.step(deltaTime)

        // Phase 4: ECS System Updates (< 2ms)
        ecsManager.update(deltaTime)

        // Phase 5: Spatial Updates (< 1ms)
        spatialMappingSystem.update()

        // Phase 6: Audio Processing (< 1ms)
        audioSystem.update(deltaTime)

        // Phase 7: Rendering Preparation (< 1ms)
        prepareRenderingData()

        // RealityKit handles actual rendering
    }
}
```

### 2.2 State Management System

```swift
// Game State Machine
enum GameState {
    case initializing
    case roomScanning
    case calibrating
    case mainMenu
    case courseSetup
    case courseActive
    case coursePaused
    case courseCompleted
    case trainingMode
    case competitionMode
    case multiplayerSync
}

class GameStateManager: ObservableObject {
    @Published var currentState: GameState = .initializing
    @Published var playerData: PlayerData
    @Published var courseData: CourseData
    @Published var sessionMetrics: SessionMetrics

    private var stateHistory: [GameState] = []
    private var stateMachine: StateMachine<GameState>

    func transition(to newState: GameState) async throws {
        // Validate state transition
        guard isValidTransition(from: currentState, to: newState) else {
            throw GameStateError.invalidTransition
        }

        // Execute exit actions for current state
        await executeStateExit(currentState)

        // Update state
        let previousState = currentState
        currentState = newState
        stateHistory.append(previousState)

        // Execute entry actions for new state
        await executeStateEntry(newState)

        // Notify observers
        NotificationCenter.default.post(
            name: .gameStateChanged,
            object: GameStateTransition(from: previousState, to: newState)
        )
    }
}
```

### 2.3 Scene Graph Architecture

```
RootEntity (ImmersiveSpace)
├── EnvironmentEntity
│   ├── RoomMeshEntity (ARKit scanned geometry)
│   ├── SafetyBoundaryEntity
│   └── LightingEntity (Spatial lighting)
│
├── CourseEntity
│   ├── ObstacleGroupEntity
│   │   ├── VirtualWallEntity[]
│   │   ├── VaultBoxEntity[]
│   │   ├── BalanceBeamEntity[]
│   │   └── PrecisionTargetEntity[]
│   │
│   ├── PathVisualizationEntity
│   └── CheckpointEntity[]
│
├── PlayerEntity
│   ├── HandTrackingEntities
│   ├── BodyTrackingEntity
│   └── GazeIndicatorEntity
│
├── UIEntity
│   ├── HUDEntity (Always visible)
│   ├── MenuEntity (Context-sensitive)
│   └── FeedbackEntity (Form analysis)
│
└── AudioEntity
    ├── SpatialAudioSources[]
    └── MusicController
```

---

## 3. visionOS-Specific Architecture

### 3.1 Spatial Presentation Modes

```swift
// Window Mode - Initial setup and menus
struct WindowModeView: View {
    var body: some View {
        NavigationSplitView {
            // Course selection, settings, profile
        }
        .frame(width: 800, height: 600)
    }
}

// Volume Mode - 3D course preview
struct VolumeModeView: View {
    var body: some View {
        RealityView { content in
            // Miniature 3D course preview
        }
        .frame(depth: 400)
    }
}

// Immersive Space - Active gameplay
struct ImmersiveGameView: View {
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace

    var body: some View {
        RealityView { content in
            // Full immersive parkour experience
            let rootEntity = await setupGameWorld()
            content.add(rootEntity)
        } update: { content in
            // Update game world each frame
        }
        .upperLimbVisibility(.hidden) // Hide hands during active play
    }
}
```

### 3.2 Spatial Anchoring System

```swift
class SpatialAnchorManager {
    private var worldTracking: ARWorldTrackingConfiguration
    private var anchors: [UUID: ARAnchor] = [:]

    // Persistent course anchors
    func createPersistentAnchor(for obstacle: Obstacle) async throws -> UUID {
        let anchor = ARAnchor(
            name: "obstacle_\(obstacle.id)",
            transform: obstacle.worldTransform
        )

        // Save to CloudKit for multi-session persistence
        try await saveToCloudKit(anchor)

        return anchor.identifier
    }

    // Room-relative positioning
    func anchorToSurface(_ entity: Entity, surface: PlaneAnchor) {
        entity.position = surface.transform.translation
        entity.orientation = surface.transform.rotation

        // Add component for automatic updates
        entity.components[AnchorComponent.self] = AnchorComponent(
            planeAnchor: surface
        )
    }
}
```

### 3.3 Hand Tracking Integration

```swift
class HandTrackingSystem {
    private var leftHandEntity: HandEntity?
    private var rightHandEntity: HandEntity?

    func update() async {
        guard let provider = handTrackingProvider else { return }

        // Get latest hand anchors
        let anchors = await provider.queryLatestAnchors()

        for anchor in anchors {
            switch anchor.chirality {
            case .left:
                updateHandEntity(leftHandEntity, with: anchor)
            case .right:
                updateHandEntity(rightHandEntity, with: anchor)
            }

            // Detect parkour-relevant gestures
            analyzeGesture(anchor)
        }
    }

    func analyzeGesture(_ anchor: HandAnchor) {
        // Detect vault hand placement
        if isVaultGesture(anchor) {
            triggerVaultAction(handPosition: anchor.originFromAnchorTransform.translation)
        }

        // Detect grab gesture for climbing
        if isGrabGesture(anchor) {
            triggerGrabAction(handPosition: anchor.originFromAnchorTransform.translation)
        }
    }
}
```

### 3.4 Eye Tracking Integration

```swift
class EyeTrackingSystem {
    private var gazeEntity: Entity?
    private var focusedEntity: Entity?

    func update() async {
        guard let deviceAnchor = await worldTracking.queryDeviceAnchor() else { return }

        // Get eye tracking data
        let eyeDirection = deviceAnchor.originFromAnchorTransform.rotation * SIMD3<Float>(0, 0, -1)

        // Raycast to find focused object
        let results = scene.raycast(
            origin: deviceAnchor.originFromAnchorTransform.translation,
            direction: eyeDirection
        )

        if let hitEntity = results.first?.entity {
            updateFocus(to: hitEntity)

            // Use for UI navigation
            if hitEntity.components[InteractableComponent.self] != nil {
                highlightForInteraction(hitEntity)
            }

            // Use for gameplay (target acquisition)
            if hitEntity.components[TargetComponent.self] != nil {
                notifyTargetFocused(hitEntity)
            }
        }
    }
}
```

---

## 4. Data Architecture

### 4.1 Core Data Models

```swift
// Player Profile
struct PlayerData: Codable {
    let id: UUID
    var username: String
    var skillLevel: SkillLevel
    var physicalProfile: PhysicalProfile
    var achievements: [Achievement]
    var statistics: PlayerStatistics
    var preferences: PlayerPreferences
}

struct PhysicalProfile: Codable {
    var height: Measurement<UnitLength>
    var reach: Measurement<UnitLength>
    var jumpHeight: Measurement<UnitLength>
    var fitnessLevel: FitnessLevel
    var injuries: [InjuryHistory]
}

// Course Definition
struct CourseData: Codable {
    let id: UUID
    var name: String
    var difficulty: DifficultyLevel
    var obstacles: [Obstacle]
    var checkpoints: [Checkpoint]
    var spaceRequirements: SpaceRequirements
    var estimatedDuration: TimeInterval
    var tags: [CourseTag]
}

struct Obstacle: Codable {
    let id: UUID
    var type: ObstacleType
    var position: SIMD3<Float>
    var rotation: simd_quatf
    var scale: SIMD3<Float>
    var difficulty: Float
    var safetyParameters: SafetyParameters
}

enum ObstacleType: String, Codable {
    case virtualWall
    case vaultBox
    case balanceBeam
    case precisionTarget
    case wallRun
    case gap
    case climbingSurface
}

// Session Tracking
struct SessionMetrics: Codable {
    var startTime: Date
    var endTime: Date?
    var courseId: UUID
    var completionTime: TimeInterval?
    var movementData: [MovementSample]
    var score: Float
    var caloriesBurned: Float
    var techniqueScores: [String: Float]
}

struct MovementSample: Codable {
    var timestamp: TimeInterval
    var bodyPosition: SIMD3<Float>
    var velocity: SIMD3<Float>
    var acceleration: SIMD3<Float>
    var handPositions: (left: SIMD3<Float>, right: SIMD3<Float>)
    var headOrientation: simd_quatf
    var jointAngles: [String: Float]
}
```

### 4.2 Persistence Layer

```swift
class PersistenceManager {
    private let modelContainer: ModelContainer
    private let cloudKitContainer: CKContainer

    // Local persistence with SwiftData
    @MainActor
    func savePlayerProgress(_ player: PlayerData) async throws {
        let context = modelContainer.mainContext
        context.insert(player)
        try context.save()
    }

    // Cloud sync for cross-device experience
    func syncToCloud(_ data: SyncableData) async throws {
        let record = CKRecord(recordType: data.recordType)
        record.encodeSystemFields(with: NSKeyedArchiver(requiringSecureCoding: true))

        try await cloudKitContainer.publicCloudDatabase.save(record)
    }

    // Leaderboard data
    func submitScore(_ score: ScoreSubmission) async throws {
        // Store in CloudKit for global leaderboards
        let record = CKRecord(recordType: "CourseScore")
        record["playerID"] = score.playerID.uuidString
        record["courseID"] = score.courseID.uuidString
        record["score"] = score.score
        record["completionTime"] = score.completionTime
        record["timestamp"] = Date()

        try await cloudKitContainer.publicCloudDatabase.save(record)
    }
}
```

---

## 5. RealityKit Gaming Components

### 5.1 Custom ECS Components

```swift
// Obstacle Component
struct ObstacleComponent: Component {
    var type: ObstacleType
    var difficulty: Float
    var isActive: Bool = true
    var interactionState: InteractionState = .idle
    var safetyZone: Float = 0.5 // meters
}

// Movement Tracking Component
struct MovementTrackingComponent: Component {
    var trackedJoints: Set<TrackedJoint>
    var movementHistory: CircularBuffer<MovementSample>
    var currentVelocity: SIMD3<Float> = .zero
    var currentAcceleration: SIMD3<Float> = .zero
}

// Safety Component
struct SafetyComponent: Component {
    var boundaryDistance: Float
    var collisionRisk: Float = 0.0
    var isInSafeZone: Bool = true
    var warningLevel: WarningLevel = .none
}

// Score Component
struct ScoreComponent: Component {
    var basePoints: Float
    var techniqueMultiplier: Float = 1.0
    var speedBonus: Float = 0.0
    var totalScore: Float {
        basePoints * techniqueMultiplier + speedBonus
    }
}

// Target Component
struct TargetComponent: Component {
    var targetPosition: SIMD3<Float>
    var requiredAccuracy: Float // meters
    var isAchieved: Bool = false
    var achievementTime: Date?
}
```

### 5.2 Custom ECS Systems

```swift
// Obstacle Interaction System
class ObstacleInteractionSystem: System {
    static let query = EntityQuery(where: .has(ObstacleComponent.self))

    func update(context: SceneUpdateContext) {
        let playerPosition = getPlayerPosition()

        for entity in context.entities(matching: Self.query) {
            guard var obstacle = entity.components[ObstacleComponent.self] else { continue }

            let distance = simd_distance(playerPosition, entity.position)

            // Update interaction state
            if distance < obstacle.safetyZone {
                obstacle.interactionState = .engaged
                handleObstacleInteraction(entity, obstacle)
            } else if distance < obstacle.safetyZone * 2 {
                obstacle.interactionState = .nearby
                prepareForInteraction(entity)
            } else {
                obstacle.interactionState = .idle
            }

            entity.components[ObstacleComponent.self] = obstacle
        }
    }

    private func handleObstacleInteraction(_ entity: Entity, _ obstacle: ObstacleComponent) {
        // Trigger haptic feedback
        triggerHaptics(for: obstacle.type)

        // Play interaction sound
        playInteractionSound(entity, obstacle.type)

        // Update visual feedback
        updateVisualFeedback(entity, .interacting)

        // Score the movement
        scoreInteraction(entity, obstacle)
    }
}

// Movement Analysis System
class MovementAnalysisSystem: System {
    static let query = EntityQuery(where: .has(MovementTrackingComponent.self))

    private let aiAnalyzer: MovementAIAnalyzer

    func update(context: SceneUpdateContext) {
        for entity in context.entities(matching: Self.query) {
            guard var tracking = entity.components[MovementTrackingComponent.self] else { continue }

            // Capture current movement sample
            let sample = captureMovementSample(entity)
            tracking.movementHistory.append(sample)

            // Calculate velocity and acceleration
            tracking.currentVelocity = calculateVelocity(tracking.movementHistory)
            tracking.currentAcceleration = calculateAcceleration(tracking.movementHistory)

            // AI analysis for technique
            let analysis = aiAnalyzer.analyzeTechnique(tracking.movementHistory)
            provideFeedback(analysis)

            entity.components[MovementTrackingComponent.self] = tracking
        }
    }
}

// Safety Monitoring System (High Priority)
class SafetyMonitoringSystem: System {
    static let query = EntityQuery(where: .has(SafetyComponent.self))

    private let updatePriority: SystemPriority = .high

    func update(context: SceneUpdateContext) {
        let playerPosition = getPlayerPosition()
        let playerVelocity = getPlayerVelocity()

        for entity in context.entities(matching: Self.query) {
            guard var safety = entity.components[SafetyComponent.self] else { continue }

            // Check boundary proximity
            safety.boundaryDistance = calculateBoundaryDistance(playerPosition)

            // Predict collision risk
            safety.collisionRisk = predictCollisionRisk(
                position: playerPosition,
                velocity: playerVelocity,
                obstacles: getNearbyObstacles(playerPosition)
            )

            // Update warning level
            safety.warningLevel = determineWarningLevel(
                boundary: safety.boundaryDistance,
                collision: safety.collisionRisk
            )

            // Take safety actions if needed
            if safety.warningLevel == .critical {
                triggerEmergencyStop()
                displayWarning()
            } else if safety.warningLevel == .warning {
                displayBoundaryWarning()
                provideGuidance()
            }

            entity.components[SafetyComponent.self] = safety
        }
    }
}
```

---

## 6. ARKit Integration

### 6.1 Spatial Mapping Architecture

```swift
class SpatialMappingSystem {
    private var arkitSession: ARKitSession
    private var worldTracking: WorldTrackingProvider
    private var sceneReconstruction: SceneReconstructionProvider
    private var planeDetection: PlaneDetectionProvider

    private var roomMesh: MeshResource?
    private var detectedPlanes: [UUID: PlaneAnchor] = [:]
    private var spaceClassification: SpaceClassification?

    func initialize() async throws {
        // Request required authorizations
        let authorizationResult = await arkitSession.requestAuthorization(for: [
            .worldSensing,
            .handTracking
        ])

        guard authorizationResult[.worldSensing] == .allowed else {
            throw ARKitError.authorizationDenied
        }

        // Start tracking providers
        try await arkitSession.run([
            worldTracking,
            sceneReconstruction,
            planeDetection
        ])
    }

    func scanRoom() async throws -> RoomScanResult {
        var scanProgress: Float = 0.0
        var detectedSurfaces: [Surface] = []

        // Monitor scene reconstruction
        for await update in sceneReconstruction.anchorUpdates {
            switch update.event {
            case .added, .updated:
                let meshAnchor = update.anchor

                // Process mesh geometry
                let surface = processMeshAnchor(meshAnchor)
                detectedSurfaces.append(surface)

                // Update scan progress
                scanProgress = calculateScanProgress(detectedSurfaces)

                // Notify UI
                NotificationCenter.default.post(
                    name: .roomScanProgress,
                    object: scanProgress
                )

                if scanProgress >= 0.95 {
                    break
                }
            case .removed:
                break
            }
        }

        // Classify the space
        let classification = classifySpace(detectedSurfaces)

        // Generate room model
        let roomModel = generateRoomModel(
            surfaces: detectedSurfaces,
            classification: classification
        )

        return RoomScanResult(
            roomModel: roomModel,
            surfaces: detectedSurfaces,
            classification: classification
        )
    }

    func detectPlayArea() -> PlayArea {
        // Analyze floor planes
        let floorPlanes = detectedPlanes.values.filter { $0.classification == .floor }

        // Find largest contiguous floor space
        let playArea = findLargestPlayArea(floorPlanes)

        // Calculate safe boundaries
        let safeZone = calculateSafeZone(playArea)

        return PlayArea(
            bounds: playArea,
            safeZone: safeZone,
            centerPoint: playArea.center
        )
    }
}
```

### 6.2 Surface Classification

```swift
struct SurfaceClassifier {
    func classifySurface(_ meshAnchor: MeshAnchor) -> SurfaceType {
        let normal = calculateAverageNormal(meshAnchor.geometry)
        let angle = angleBetween(normal, worldUp)

        // Classify based on orientation
        if angle < 15° {
            return .floor
        } else if angle > 165° {
            return .ceiling
        } else if angle > 75° && angle < 105° {
            return .wall
        } else {
            return .sloped
        }
    }

    func identifyFurniture(_ objects: [AnchoredObject]) -> [FurnitureItem] {
        var furniture: [FurnitureItem] = []

        for object in objects {
            let dimensions = object.boundingBox
            let height = dimensions.y
            let surfaceArea = dimensions.x * dimensions.z

            // Heuristic classification
            if height < 0.6 && surfaceArea > 0.3 {
                furniture.append(FurnitureItem(type: .table, anchor: object))
            } else if height > 0.4 && height < 0.6 && dimensions.z > 0.4 {
                furniture.append(FurnitureItem(type: .chair, anchor: object))
            } else if height > 0.8 && surfaceArea < 0.5 {
                furniture.append(FurnitureItem(type: .shelf, anchor: object))
            }
        }

        return furniture
    }
}
```

---

## 7. AI Course Generation Architecture

### 7.1 Course Generation System

```swift
class AICourseGenerator {
    private let difficultyEngine: DifficultyEngine
    private let spatialOptimizer: SpatialOptimizer
    private let safetyValidator: SafetyValidator

    func generateCourse(
        for space: RoomModel,
        player: PlayerData,
        difficulty: DifficultyLevel
    ) async throws -> CourseData {

        // Phase 1: Analyze space capabilities
        let spaceAnalysis = analyzeSpace(space)

        // Phase 2: Generate obstacle graph
        let obstacleGraph = generateObstacleGraph(
            space: spaceAnalysis,
            skillLevel: player.skillLevel,
            difficulty: difficulty
        )

        // Phase 3: Optimize for flow
        let optimizedCourse = spatialOptimizer.optimize(
            graph: obstacleGraph,
            playerProfile: player.physicalProfile
        )

        // Phase 4: Validate safety
        let validatedCourse = try safetyValidator.validate(
            course: optimizedCourse,
            space: space
        )

        // Phase 5: Add checkpoints and scoring
        let finalCourse = addGameplayElements(validatedCourse)

        return finalCourse
    }

    private func generateObstacleGraph(
        space: SpaceAnalysis,
        skillLevel: SkillLevel,
        difficulty: DifficultyLevel
    ) -> ObstacleGraph {

        var graph = ObstacleGraph()

        // Determine obstacle density
        let obstacleCount = calculateObstacleCount(
            spaceArea: space.floorArea,
            difficulty: difficulty
        )

        // Select obstacle types based on skill level
        let availableTypes = getAvailableObstacles(for: skillLevel)

        // Place obstacles with spatial optimization
        for _ in 0..<obstacleCount {
            let type = selectObstacleType(
                available: availableTypes,
                difficulty: difficulty
            )

            let position = findOptimalPosition(
                type: type,
                existing: graph.obstacles,
                space: space
            )

            let obstacle = Obstacle(
                type: type,
                position: position,
                rotation: calculateOptimalRotation(type, space),
                difficulty: difficulty.rawValue
            )

            graph.add(obstacle)
        }

        return graph
    }
}
```

### 7.2 Movement AI Analyzer

```swift
class MovementAIAnalyzer {
    private let mlModel: MovementAnalysisModel
    private let techniqueDatabase: TechniqueDatabase

    func analyzeTechnique(_ samples: [MovementSample]) -> TechniqueAnalysis {
        // Extract features from movement samples
        let features = extractFeatures(samples)

        // Run ML model for classification
        let prediction = try? mlModel.prediction(input: features)

        // Compare with ideal technique
        let idealTechnique = techniqueDatabase.getIdealTechnique(
            for: detectMovementType(samples)
        )

        // Calculate deviations
        let deviations = calculateDeviations(
            actual: samples,
            ideal: idealTechnique
        )

        // Generate feedback
        let feedback = generateFeedback(
            deviations: deviations,
            prediction: prediction
        )

        return TechniqueAnalysis(
            movementType: detectMovementType(samples),
            score: calculateTechniqueScore(deviations),
            feedback: feedback,
            improvementAreas: identifyImprovementAreas(deviations)
        )
    }

    private func extractFeatures(_ samples: [MovementSample]) -> MLMultiArray {
        // Feature extraction for ML model
        var features: [Float] = []

        // Velocity profile
        features.append(contentsOf: calculateVelocityProfile(samples))

        // Joint angles over time
        features.append(contentsOf: extractJointAngleSequence(samples))

        // Body positioning
        features.append(contentsOf: extractBodyPositioning(samples))

        // Momentum and force
        features.append(contentsOf: calculateMomentumProfile(samples))

        return convertToMLArray(features)
    }
}
```

---

## 8. Physics Architecture

### 8.1 Physics World Configuration

```swift
class PhysicsWorldManager {
    private var physicsWorld: PhysicsWorld

    func configure() {
        // Configure physics simulation
        physicsWorld.gravity = SIMD3<Float>(0, -9.81, 0)
        physicsWorld.simulationSpeed = 1.0
        physicsWorld.iterationCount = 8 // Higher for accuracy

        // Collision layers
        configureCollisionLayers()

        // Contact delegates
        physicsWorld.contactDelegate = self
    }

    private func configureCollisionLayers() {
        // Define collision groups
        let playerGroup: CollisionGroup = .init(rawValue: 1 << 0)
        let obstacleGroup: CollisionGroup = .init(rawValue: 1 << 1)
        let boundaryGroup: CollisionGroup = .init(rawValue: 1 << 2)
        let targetGroup: CollisionGroup = .init(rawValue: 1 << 3)

        // Player collides with obstacles and boundaries
        // Targets only trigger events, no physical collision
    }
}

extension PhysicsWorldManager: PhysicsContactDelegate {
    func physicsWorld(_ world: PhysicsWorld, didBegin contact: PhysicsContact) {
        handleCollision(contact)
    }

    func physicsWorld(_ world: PhysicsWorld, didUpdate contact: PhysicsContact) {
        updateCollision(contact)
    }

    func physicsWorld(_ world: PhysicsWorld, didEnd contact: PhysicsContact) {
        endCollision(contact)
    }

    private func handleCollision(_ contact: PhysicsContact) {
        // Determine collision type
        if isObstacleCollision(contact) {
            handleObstacleContact(contact)
        } else if isBoundaryCollision(contact) {
            handleBoundaryContact(contact)
        } else if isTargetTrigger(contact) {
            handleTargetAchievement(contact)
        }
    }
}
```

### 8.2 Custom Physics Shapes

```swift
class ObstaclePhysicsShapeFactory {
    func createShape(for obstacle: Obstacle) -> ShapeResource {
        switch obstacle.type {
        case .virtualWall:
            return .generateBox(
                width: obstacle.scale.x,
                height: obstacle.scale.y,
                depth: 0.1
            )

        case .vaultBox:
            return .generateBox(size: obstacle.scale)

        case .balanceBeam:
            return .generateCapsule(
                height: obstacle.scale.y,
                radius: 0.1
            )

        case .precisionTarget:
            // Trigger volume, no physical collision
            return .generateSphere(radius: obstacle.scale.x)

        case .wallRun:
            // Angled surface
            return .generateConvex(from: generateWallRunMesh())

        default:
            return .generateBox(size: obstacle.scale)
        }
    }
}
```

---

## 9. Audio Architecture

### 9.1 Spatial Audio System

```swift
class SpatialAudioSystem {
    private var audioEngine: AVAudioEngine
    private var environment: AVAudioEnvironmentNode
    private var mixer: AVAudioMixerNode

    // Audio categories
    private var musicPlayer: AVAudioPlayerNode
    private var sfxPlayers: [SFXType: AVAudioPlayerNode] = [:]
    private var spatialSources: [UUID: AudioSource] = [:]

    func initialize() {
        // Configure audio engine
        audioEngine = AVAudioEngine()
        environment = AVAudioEnvironmentNode()
        mixer = audioEngine.mainMixerNode

        // Attach environment node
        audioEngine.attach(environment)
        audioEngine.connect(environment, to: mixer, format: nil)

        // Configure spatial audio
        environment.listenerPosition = AVAudio3DPoint(x: 0, y: 1.7, z: 0) // Ear height
        environment.renderingAlgorithm = .HRTFHQ // High-quality spatial audio

        // Start engine
        try? audioEngine.start()
    }

    func createSpatialSource(
        at position: SIMD3<Float>,
        sound: SoundEffect
    ) -> UUID {
        let sourceID = UUID()
        let player = AVAudioPlayerNode()

        // Attach player
        audioEngine.attach(player)
        audioEngine.connect(player, to: environment, format: sound.format)

        // Set 3D position
        player.position = AVAudio3DPoint(
            x: position.x,
            y: position.y,
            z: position.z
        )

        // Configure attenuation
        player.obstruction = 0.0
        player.occlusion = 0.0

        // Store and play
        spatialSources[sourceID] = AudioSource(player: player, sound: sound)
        player.scheduleBuffer(sound.buffer, at: nil, options: [])
        player.play()

        return sourceID
    }

    func updateListenerPosition(_ position: SIMD3<Float>, orientation: simd_quatf) {
        environment.listenerPosition = AVAudio3DPoint(
            x: position.x,
            y: position.y,
            z: position.z
        )

        // Convert quaternion to Euler for listener orientation
        let euler = orientation.eulerAngles
        environment.listenerAngularOrientation = AVAudio3DAngularOrientation(
            yaw: euler.y,
            pitch: euler.x,
            roll: euler.z
        )
    }
}
```

### 9.2 Adaptive Music System

```swift
class AdaptiveMusicSystem {
    private var musicLayers: [MusicLayer] = []
    private var currentIntensity: Float = 0.0

    struct MusicLayer {
        let player: AVAudioPlayerNode
        let intensity: Float
        var volume: Float
    }

    func updateIntensity(based on gameState: GameState) {
        let targetIntensity = calculateIntensity(gameState)

        // Smooth transition
        let delta = targetIntensity - currentIntensity
        currentIntensity += delta * 0.1 // Smooth interpolation

        // Adjust layer volumes
        for var layer in musicLayers {
            let distance = abs(layer.intensity - currentIntensity)
            layer.volume = max(0, 1.0 - distance)
            layer.player.volume = layer.volume
        }
    }

    private func calculateIntensity(_ state: GameState) -> Float {
        switch state {
        case .mainMenu:
            return 0.2
        case .courseActive:
            return 0.7
        case .competitionMode:
            return 1.0
        default:
            return 0.5
        }
    }
}
```

---

## 10. Multiplayer Architecture

### 10.1 Network Architecture

```swift
class MultiplayerManager {
    private var groupSession: GroupSession?
    private var messenger: GroupSessionMessenger?
    private var syncManager: SynchronizationManager

    // SharePlay integration
    func startGroupActivity() async throws {
        let activity = ParkourPathwaysActivity()

        // Prepare for SharePlay
        switch await activity.prepareForActivation() {
        case .activationPreferred:
            // Start group session
            let session = try await ParkourPathwaysActivity.Session()
            self.groupSession = session

            // Set up messenger
            self.messenger = GroupSessionMessenger(session: session)

            // Join session
            session.join()

            // Start sync
            await syncManager.startSync(session: session)

        case .activationDisabled, .cancelled:
            throw MultiplayerError.sessionCancelled
        @unknown default:
            break
        }
    }

    func syncGameState(_ state: GameState) async throws {
        guard let messenger = messenger else { return }

        let message = GameStateMessage(state: state)
        try await messenger.send(message)
    }
}
```

### 10.2 Ghost Recording System

```swift
class GhostRecordingSystem {
    private var recording: GhostRecording?
    private var playback: GhostPlayback?

    struct GhostRecording {
        var startTime: Date
        var samples: [GhostSample] = []
        var courseID: UUID
        var playerID: UUID
    }

    struct GhostSample: Codable {
        var timestamp: TimeInterval
        var position: SIMD3<Float>
        var rotation: simd_quatf
        var currentObstacle: UUID?
    }

    func startRecording(courseID: UUID) {
        recording = GhostRecording(
            startTime: Date(),
            courseID: courseID,
            playerID: getCurrentPlayerID()
        )
    }

    func recordFrame(position: SIMD3<Float>, rotation: simd_quatf) {
        guard var recording = recording else { return }

        let timestamp = Date().timeIntervalSince(recording.startTime)
        let sample = GhostSample(
            timestamp: timestamp,
            position: position,
            rotation: rotation,
            currentObstacle: getCurrentObstacleID()
        )

        recording.samples.append(sample)
        self.recording = recording
    }

    func playGhost(_ ghostData: GhostRecording) {
        playback = GhostPlayback(recording: ghostData)

        // Create ghost entity
        let ghostEntity = createGhostEntity()

        // Animate along recorded path
        animateGhost(ghostEntity, recording: ghostData)
    }
}
```

---

## 11. Performance Optimization

### 11.1 Frame Budget Management

```
Target: 90 FPS (11.1ms per frame)

Frame Budget Allocation:
├── Input Processing:        1.0ms
├── Game Logic:              3.0ms
├── Physics Simulation:      2.0ms
├── ECS Systems:             2.0ms
├── Spatial Updates:         1.0ms
├── Audio Processing:        1.0ms
├── Render Preparation:      1.1ms
└── Reserve:                 0ms (buffer)
```

### 11.2 Optimization Strategies

```swift
class PerformanceOptimizer {
    // Object pooling for frequently spawned objects
    class ObjectPool<T> {
        private var available: [T] = []
        private let factory: () -> T

        func acquire() -> T {
            if available.isEmpty {
                return factory()
            }
            return available.removeLast()
        }

        func release(_ object: T) {
            available.append(object)
        }
    }

    // LOD system for distant obstacles
    func updateLOD(for entity: Entity, distance: Float) {
        if distance < 2.0 {
            entity.components[ModelComponent.self]?.mesh = highDetailMesh
        } else if distance < 5.0 {
            entity.components[ModelComponent.self]?.mesh = mediumDetailMesh
        } else {
            entity.components[ModelComponent.self]?.mesh = lowDetailMesh
        }
    }

    // Frustum culling
    func cullOutOfView(_ entities: [Entity], camera: PerspectiveCamera) {
        for entity in entities {
            let inView = camera.frustum.contains(entity.position)
            entity.isEnabled = inView
        }
    }

    // Async loading of course data
    func loadCourseAsync(_ courseID: UUID) async -> CourseData {
        return await withTaskGroup(of: CourseElement.self) { group in
            // Load different course elements in parallel
            group.addTask { await self.loadObstacles(courseID) }
            group.addTask { await self.loadCheckpoints(courseID) }
            group.addTask { await self.loadAudioData(courseID) }

            var elements: [CourseElement] = []
            for await element in group {
                elements.append(element)
            }
            return assembleCourse(from: elements)
        }
    }
}
```

### 11.3 Memory Management

```swift
class MemoryManager {
    private let maxMemoryBudget: UInt64 = 2_000_000_000 // 2GB

    func monitorMemory() {
        let used = getMemoryUsage()

        if used > maxMemoryBudget * 0.9 {
            // Aggressive cleanup
            performEmergencyCleanup()
        } else if used > maxMemoryBudget * 0.7 {
            // Standard cleanup
            performStandardCleanup()
        }
    }

    private func performStandardCleanup() {
        // Release cached assets
        assetCache.releaseUnused()

        // Reduce movement history buffer size
        movementBuffer.trimOldest(keepRecent: 100)

        // Unload distant course elements
        unloadDistantElements()
    }
}
```

---

## 12. Safety Architecture

### 12.1 Multi-Layer Safety System

```swift
class SafetySystem {
    // Layer 1: Boundary Detection
    private let boundaryMonitor = BoundaryMonitor()

    // Layer 2: Collision Prediction
    private let collisionPredictor = CollisionPredictor()

    // Layer 3: Movement Analysis
    private let movementSafetyAnalyzer = MovementSafetyAnalyzer()

    // Layer 4: Emergency Stop
    private let emergencyController = EmergencyController()

    func evaluate() -> SafetyStatus {
        // Check all safety layers
        let boundaryStatus = boundaryMonitor.check()
        let collisionRisk = collisionPredictor.predict()
        let movementRisk = movementSafetyAnalyzer.analyze()

        // Determine overall safety
        if boundaryStatus == .critical || collisionRisk > 0.8 {
            emergencyController.stop()
            return .emergency
        } else if boundaryStatus == .warning || collisionRisk > 0.5 {
            return .warning
        }

        return .safe
    }
}

class CollisionPredictor {
    func predict(
        position: SIMD3<Float>,
        velocity: SIMD3<Float>,
        obstacles: [Entity]
    ) -> Float {
        // Predict position in next 0.5 seconds
        let futurePosition = position + velocity * 0.5

        // Check for potential collisions
        var maxRisk: Float = 0.0

        for obstacle in obstacles {
            let distance = simd_distance(futurePosition, obstacle.position)
            let obstacleRadius = obstacle.visualBounds(relativeTo: nil).extents.max() / 2

            if distance < obstacleRadius + 0.3 { // Safety margin
                let risk = 1.0 - (distance / (obstacleRadius + 0.3))
                maxRisk = max(maxRisk, risk)
            }
        }

        return maxRisk
    }
}
```

---

## 13. Development Architecture

### 13.1 Project Structure

```
ParkourPathways/
├── App/
│   ├── ParkourPathwaysApp.swift
│   ├── AppCoordinator.swift
│   └── AppState.swift
│
├── Core/
│   ├── Game/
│   │   ├── GameLoop.swift
│   │   ├── GameStateManager.swift
│   │   └── GameCoordinator.swift
│   │
│   ├── Systems/
│   │   ├── PhysicsSystem.swift
│   │   ├── InputSystem.swift
│   │   ├── AudioSystem.swift
│   │   ├── SafetySystem.swift
│   │   └── MovementAnalysisSystem.swift
│   │
│   └── ECS/
│       ├── Components/
│       ├── Systems/
│       └── Entities/
│
├── Features/
│   ├── Spatial/
│   │   ├── SpatialMappingSystem.swift
│   │   ├── ARKitIntegration.swift
│   │   └── AnchorManagement.swift
│   │
│   ├── CourseGeneration/
│   │   ├── AIGenerator.swift
│   │   ├── DifficultyEngine.swift
│   │   └── SafetyValidator.swift
│   │
│   ├── Multiplayer/
│   │   ├── SharePlayIntegration.swift
│   │   ├── GhostSystem.swift
│   │   └── Leaderboards.swift
│   │
│   └── UI/
│       ├── MenuViews/
│       ├── HUD/
│       └── FeedbackViews/
│
├── Data/
│   ├── Models/
│   ├── Persistence/
│   └── Network/
│
├── Resources/
│   ├── Assets.xcassets
│   ├── RealityKitContent/
│   ├── Audio/
│   └── Courses/
│
└── Tests/
    ├── UnitTests/
    ├── IntegrationTests/
    └── PerformanceTests/
```

### 13.2 Dependency Management

```swift
// Dependency container using Swift DI
class DependencyContainer {
    // Singletons
    lazy var gameStateManager = GameStateManager()
    lazy var spatialMappingSystem = SpatialMappingSystem()
    lazy var audioSystem = SpatialAudioSystem()

    // Factories
    func makeCourseGenerator() -> AICourseGenerator {
        AICourseGenerator(
            difficultyEngine: DifficultyEngine(),
            spatialOptimizer: SpatialOptimizer(),
            safetyValidator: SafetyValidator()
        )
    }

    func makeMultiplayerManager() -> MultiplayerManager {
        MultiplayerManager(
            syncManager: SynchronizationManager(),
            messenger: nil  // Created on demand
        )
    }
}
```

---

## 14. Testing Architecture

### 14.1 Unit Testing Strategy

```swift
@testable import ParkourPathways
import XCTest

class CourseGeneratorTests: XCTestCase {
    var generator: AIGenerator!
    var mockRoomModel: RoomModel!

    override func setUp() {
        generator = AIGenerator()
        mockRoomModel = createMockRoom()
    }

    func testCourseGeneration_ValidSpace_GeneratesObstacles() async throws {
        let course = try await generator.generateCourse(
            for: mockRoomModel,
            player: mockPlayer,
            difficulty: .medium
        )

        XCTAssertGreaterThan(course.obstacles.count, 0)
        XCTAssertTrue(course.spaceRequirements.fits(in: mockRoomModel))
    }

    func testSafetyValidation_ObstaclesTooClose_ThrowsError() async {
        let invalidCourse = createUnsafeCourse()

        await XCTAssertThrowsError(
            try await safetyValidator.validate(course: invalidCourse)
        )
    }
}
```

### 14.2 Performance Testing

```swift
class PerformanceTests: XCTestCase {
    func testGameLoop_90FPS_MaintainsTargetFramerate() {
        measure(metrics: [XCTClockMetric()]) {
            let gameLoop = GameLoop()

            // Simulate 100 frames
            for _ in 0..<100 {
                gameLoop.update(deltaTime: 1.0/90.0)
            }
        }

        // Assert frame time < 11.1ms
    }

    func testMemoryUsage_ExtendedPlay_StaysWithinBudget() {
        let memoryMetric = XCTMemoryMetric()

        measure(metrics: [memoryMetric]) {
            // Simulate 10-minute play session
            simulateGameplay(duration: 600)
        }
    }
}
```

---

## 15. Deployment Architecture

### 15.1 Build Configurations

```swift
// Development
#if DEBUG
let apiEndpoint = "https://dev-api.parkourpathways.com"
let enableDebugUI = true
let logLevel = .verbose
#endif

// Production
#if RELEASE
let apiEndpoint = "https://api.parkourpathways.com"
let enableDebugUI = false
let logLevel = .error
#endif
```

### 15.2 App Distribution

```yaml
# Xcode Cloud Configuration
app_distribution:
  development:
    build_number_increment: true
    archive: true
    distribute_to_testflight: true

  production:
    build_number_increment: true
    archive: true
    app_store_connect: true
    submit_for_review: false
```

---

## Conclusion

This architecture provides a robust, scalable, and performant foundation for Parkour Pathways. Key architectural decisions prioritize:

1. **Performance**: 90 FPS target with careful frame budget management
2. **Safety**: Multi-layer safety system preventing injuries
3. **Spatial Computing**: Full utilization of visionOS capabilities
4. **Modularity**: Clean separation of concerns for maintainability
5. **Scalability**: Ready for multiplayer and future features

The architecture leverages modern Swift features (async/await, Combine, SwiftData) and visionOS-specific frameworks (RealityKit, ARKit, SharePlay) to deliver a revolutionary spatial gaming experience.
