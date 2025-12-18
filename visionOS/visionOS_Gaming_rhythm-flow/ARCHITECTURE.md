# Rhythm Flow - Technical Architecture

## Document Overview

This document defines the comprehensive technical architecture for Rhythm Flow, a visionOS spatial rhythm game. It covers system design, data flows, component architecture, and technical patterns optimized for Vision Pro gaming.

**Version:** 1.0
**Last Updated:** 2025-01-20
**Target Platform:** visionOS 2.0+ (Apple Vision Pro)

---

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [Game Architecture](#game-architecture)
3. [visionOS Spatial Computing Integration](#visionos-spatial-computing-integration)
4. [Data Models & Schemas](#data-models--schemas)
5. [RealityKit Gaming Components](#realitykit-gaming-components)
6. [ARKit Integration](#arkit-integration)
7. [AI & Machine Learning Architecture](#ai--machine-learning-architecture)
8. [Audio Architecture](#audio-architecture)
9. [Multiplayer Architecture](#multiplayer-architecture)
10. [Physics & Collision Systems](#physics--collision-systems)
11. [Save/Load System](#saveload-system)
12. [Performance Optimization](#performance-optimization)
13. [Security & Privacy](#security--privacy)

---

## Architecture Overview

### High-Level System Design

```
┌─────────────────────────────────────────────────────────────────┐
│                        Rhythm Flow App                          │
├─────────────────────────────────────────────────────────────────┤
│  Presentation Layer (SwiftUI)                                   │
│  ├── Menu System          ├── HUD System        ├── Settings    │
│  └── Results/Statistics   └── Tutorial UI       └── Social UI   │
├─────────────────────────────────────────────────────────────────┤
│  Game Logic Layer                                               │
│  ├── Game State Manager   ├── Score System      ├── Progression │
│  ├── Input Handler        ├── Combo System      └── AI Coach    │
│  └── Level Manager        └── Difficulty Scaler                 │
├─────────────────────────────────────────────────────────────────┤
│  Spatial Computing Layer (RealityKit)                           │
│  ├── Note Entity System   ├── Visual Effects    ├── Scene Mgmt  │
│  ├── Spatial Audio        ├── Hand Tracking     └── Room Scan   │
│  └── Particle Systems     └── Gesture Recognition               │
├─────────────────────────────────────────────────────────────────┤
│  AI/ML Layer                                                    │
│  ├── Beat Map Generator   ├── Difficulty AI     ├── Music Rec.  │
│  ├── Movement Analyzer    ├── Fitness Tracker   └── NLP Engine  │
│  └── Performance Predictor                                      │
├─────────────────────────────────────────────────────────────────┤
│  Data Layer                                                     │
│  ├── Song Library         ├── User Profiles     ├── Analytics   │
│  ├── Beat Maps            ├── Leaderboards      └── CloudKit    │
│  └── Local Cache          └── Asset Streaming                   │
├─────────────────────────────────────────────────────────────────┤
│  Platform Services                                              │
│  ├── ARKit (Room Scan)    ├── HealthKit         ├── GameCenter  │
│  ├── SharePlay            ├── Music Streaming   └── Haptics     │
│  └── CoreML               └── Network.framework                 │
└─────────────────────────────────────────────────────────────────┘
```

### Architecture Principles

1. **Entity-Component-System (ECS)** - RealityKit's native pattern for game objects
2. **Reactive State Management** - Combine framework for state flow
3. **Protocol-Oriented Design** - Swift protocols for flexibility
4. **Performance-First** - 90 FPS target with thermal management
5. **Privacy by Design** - Local processing, minimal data collection
6. **Offline-First** - Core gameplay works without network

---

## Game Architecture

### Game Loop Structure

```swift
class GameLoop {
    // Target: 90 FPS (11.1ms per frame)
    // Budget:
    //   - Input Processing: 1ms
    //   - Game Logic: 3ms
    //   - Physics: 2ms
    //   - Rendering: 4ms
    //   - Buffer: 1.1ms

    func update(deltaTime: TimeInterval) {
        // Frame timing
        let frameStart = CACurrentMediaTime()

        // 1. Input Phase (1ms budget)
        inputSystem.processInput()
        handTracker.updatePoses()
        gestureRecognizer.detectGestures()

        // 2. AI Phase (integrated, non-blocking)
        difficultyAI.adjust(performance: currentPerformance)

        // 3. Game Logic Phase (3ms budget)
        gameStateManager.update(deltaTime)
        noteSpawner.spawnNotes(currentTime: musicTime)
        collisionDetector.checkNoteHits()
        scoreSystem.updateScore()
        comboSystem.updateCombo()

        // 4. Physics Phase (2ms budget)
        physicsWorld.simulate(deltaTime)

        // 5. Audio Phase (async)
        audioEngine.update(listenerPosition: headPosition)

        // 6. Rendering Phase (handled by RealityKit)
        // RealityKit automatically renders at 90 FPS

        // Performance monitoring
        let frameDuration = CACurrentMediaTime() - frameStart
        performanceMonitor.recordFrame(frameDuration)
    }
}
```

### State Management Architecture

```swift
// Game State Machine
enum GameState {
    case initialization
    case mainMenu
    case songSelection
    case calibration
    case countdown
    case playing
    case paused
    case results
    case multiplayer(MultiplayerState)

    enum MultiplayerState {
        case lobby
        case syncing
        case competing
        case finished
    }
}

// State Manager using Combine
class GameStateManager: ObservableObject {
    @Published var currentState: GameState = .initialization
    @Published var gameSession: GameSession?

    private var stateMachine: StateMachine<GameState>
    private var cancellables = Set<AnyCancellable>()

    func transition(to newState: GameState) {
        // Validate transition
        guard stateMachine.canTransition(to: newState) else { return }

        // Exit current state
        exitState(currentState)

        // Transition
        currentState = newState

        // Enter new state
        enterState(newState)
    }
}
```

### Scene Graph Architecture

```
RootEntity (ImmersiveSpace)
├── EnvironmentEntity
│   ├── SkyboxEntity
│   ├── GroundPlaneEntity
│   └── ThemeVisuals
│
├── GameplayEntity
│   ├── NoteSpawnerEntity
│   │   ├── ForwardNoteHighway
│   │   ├── LeftCircularRing
│   │   ├── RightCircularRing
│   │   └── VerticalCascade
│   │
│   ├── ActiveNotesEntity (dynamic pool)
│   │   ├── Note1Entity
│   │   ├── Note2Entity
│   │   └── ... (pooled instances)
│   │
│   └── EffectsEntity
│       ├── HitEffectsPool
│       ├── ComboFlamesEntity
│       └── PerfectStreakEntity
│
├── UIEntity (spatial HUD)
│   ├── ScoreDisplay
│   ├── ComboMeter
│   ├── EnergyBar
│   └── MultiplierDisplay
│
├── PlayerEntity
│   ├── LeftHandTracking
│   ├── RightHandTracking
│   ├── HeadTracking
│   └── BodyTracking (ARKit skeleton)
│
└── RoomEntity
    ├── BoundaryVisualization
    ├── FurnitureColliders
    └── SafeZoneMarkers
```

---

## visionOS Spatial Computing Integration

### Window, Volume, and Immersive Space Strategy

```swift
@main
struct RhythmFlowApp: App {
    @State private var immersionStyle: ImmersionStyle = .progressive

    var body: some Scene {
        // 1. Window Scene - Menu & Settings (2D)
        WindowGroup(id: "main-menu") {
            MainMenuView()
        }
        .windowStyle(.plain)
        .defaultSize(width: 800, height: 600)

        // 2. Volume Scene - Song Preview (3D Bounded)
        WindowGroup(id: "song-preview") {
            SongPreviewVolume()
        }
        .windowStyle(.volumetric)
        .defaultSize(width: 600, height: 400, depth: 300, in: .points)

        // 3. Immersive Space - Gameplay (Full Immersion)
        ImmersiveSpace(id: "gameplay") {
            GameplaySpace()
                .onAppear {
                    setupGameplay()
                }
        }
        .immersionStyle(selection: $immersionStyle, in: .progressive, .full)
    }
}
```

### Progressive Immersion Levels

```swift
class ImmersionManager: ObservableObject {
    @Published var currentLevel: ImmersionLevel = .windowed

    enum ImmersionLevel {
        case windowed           // Menu navigation
        case partial           // Song selection with 3D preview
        case progressive       // Gameplay with passthrough
        case full             // Maximum immersion
    }

    func transitionToGameplay() {
        // Smooth transition: Window -> Partial -> Progressive -> Full
        Task {
            await setImmersion(.partial)
            try? await Task.sleep(for: .milliseconds(500))

            await setImmersion(.progressive)
            try? await Task.sleep(for: .milliseconds(500))

            if userPreference.fullImmersion {
                await setImmersion(.full)
            }
        }
    }
}
```

### Hand Tracking Integration

```swift
class HandTrackingSystem {
    private var leftHandAnchor: AnchorEntity?
    private var rightHandAnchor: AnchorEntity?

    func update() async {
        // ARKit hand tracking
        let handTrackingProvider = HandTrackingProvider()

        for await update in handTrackingProvider.anchorUpdates {
            switch update.anchor.chirality {
            case .left:
                updateLeftHand(update.anchor)
            case .right:
                updateRightHand(update.anchor)
            }
        }
    }

    func updateLeftHand(_ anchor: HandAnchor) {
        // Get joint positions
        let indexTip = anchor.handSkeleton?.joint(.indexFingerTip)
        let wrist = anchor.handSkeleton?.joint(.wrist)

        // Update collision zones for note detection
        leftHandCollider.position = indexTip?.anchorFromJointTransform.translation ?? .zero

        // Gesture recognition
        gestureRecognizer.processHandPose(anchor, hand: .left)
    }
}
```

### Room Scanning & Spatial Mapping

```swift
class RoomScanManager {
    private var worldTracking: WorldTrackingProvider?
    private var sceneReconstruction: SceneReconstructionProvider?

    func scanPlaySpace() async -> PlaySpace {
        // 1. Request room scan authorization
        await ARKitSession.requestAuthorization(for: [.worldSensing])

        // 2. Start room scanning
        let session = ARKitSession()
        sceneReconstruction = SceneReconstructionProvider()

        try? await session.run([sceneReconstruction!])

        // 3. Detect room boundaries
        var roomBounds: [SIMD3<Float>] = []
        for await update in sceneReconstruction!.anchorUpdates {
            if let meshAnchor = update.anchor as? MeshAnchor {
                // Extract floor plane
                if meshAnchor.classification == .floor {
                    roomBounds.append(contentsOf: extractBoundary(meshAnchor))
                }
            }
        }

        // 4. Calculate play area
        return PlaySpace(
            bounds: roomBounds,
            center: calculateCenter(roomBounds),
            recommendedRadius: calculateSafeRadius(roomBounds)
        )
    }

    func detectFurniture() -> [FurnitureObject] {
        // Detect obstacles: tables, chairs, couches
        // Create collision avoidance zones
    }
}
```

---

## Data Models & Schemas

### Core Data Models

```swift
// Song Data Model
struct Song: Codable, Identifiable {
    let id: UUID
    let title: String
    let artist: String
    let album: String?
    let duration: TimeInterval
    let bpm: Double
    let key: MusicalKey
    let genre: Genre

    // Audio
    let audioFileURL: URL
    let previewURL: URL?
    let stems: AudioStems?

    // Beat Maps
    let beatMaps: [Difficulty: BeatMap]

    // Metadata
    let releaseDate: Date
    let artworkURL: URL
    let explicit: Bool
    let license: MusicLicense

    // Stats
    var playCount: Int
    var averageScore: Double
    var completionRate: Double
}

// Beat Map Structure
struct BeatMap: Codable {
    let difficulty: Difficulty
    let noteCount: Int
    let maxScore: Int
    let creator: String
    let createdDate: Date

    // Note sequences
    let noteEvents: [NoteEvent]
    let obstacleEvents: [ObstacleEvent]
    let environmentEvents: [EnvironmentEvent]

    // AI generation metadata
    let generatedByAI: Bool
    let aiVersion: String?
    let humanAdjusted: Bool
}

// Note Event
struct NoteEvent: Codable {
    let timestamp: TimeInterval    // Seconds from song start
    let type: NoteType
    let position: SIMD3<Float>     // 3D spawn position
    let direction: SIMD3<Float>    // Movement direction
    let speed: Float
    let hand: Hand                 // .left, .right, .both
    let gesture: GestureType       // .punch, .swipe, .hold, etc.
    let duration: TimeInterval?    // For hold notes
    let color: NoteColor
    let points: Int                // Base points for perfect hit
}

// Game Session
struct GameSession: Codable {
    let id: UUID
    let songID: UUID
    let difficulty: Difficulty
    let startTime: Date
    var endTime: Date?

    // Performance
    var score: Int
    var accuracy: Double           // Percentage
    var maxCombo: Int
    var currentCombo: Int

    // Hit statistics
    var perfectHits: Int
    var greatHits: Int
    var goodHits: Int
    var missedHits: Int

    // Fitness
    var caloriesBurned: Double
    var averageHeartRate: Double?
    var peakHeartRate: Double?
    var movementQuality: Double    // AI-scored

    // Gameplay events
    var hitEvents: [HitEvent]
    var performanceGraph: [PerformancePoint]
}

// Player Profile
struct PlayerProfile: Codable {
    let id: UUID
    let username: String
    var displayName: String
    var avatar: AvatarConfig

    // Progression
    var level: Int
    var experience: Int
    var totalScore: Int
    var totalSongsPlayed: Int

    // Statistics
    var statistics: PlayerStatistics
    var achievements: [Achievement]
    var badges: [Badge]

    // Preferences
    var preferences: GamePreferences
    var aiProfile: AIPlayerProfile

    // Social
    var friends: [UUID]
    var followedCreators: [UUID]

    // Fitness
    var fitnessGoals: FitnessGoals?
    var workoutHistory: [WorkoutSession]
}

// AI Player Profile (ML-learned preferences)
struct AIPlayerProfile: Codable {
    var skillLevel: Double              // 0.0 - 1.0
    var preferredDifficulty: Difficulty
    var movementEfficiency: Double      // Quality of form
    var reactionSpeed: TimeInterval     // Average response time

    // Music preferences (learned)
    var genrePreferences: [Genre: Double]
    var bpmPreference: ClosedRange<Double>
    var energyPreference: Double        // Calm to intense

    // Play style
    var aggressiveness: Double          // Punchy vs smooth
    var spatialComfort: Double          // 360° tolerance
    var sessionLength: TimeInterval     // Preferred duration

    // Learning metadata
    var dataPoints: Int
    var lastUpdated: Date
    var confidenceScore: Double
}
```

### CloudKit Schema

```swift
// CloudKit Record Types
enum RecordType: String {
    case player = "Player"
    case gameSession = "GameSession"
    case beatMap = "BeatMap"
    case leaderboardEntry = "LeaderboardEntry"
    case achievement = "Achievement"
    case customSong = "CustomSong"
}

// Leaderboard Entry
struct LeaderboardEntry {
    let playerID: CKRecord.Reference
    let songID: String
    let difficulty: String
    let score: Int
    let accuracy: Double
    let combo: Int
    let timestamp: Date
    let replayData: Data?              // Compressed replay
    let verified: Bool                 // Anti-cheat flag
}
```

---

## RealityKit Gaming Components

### Entity Component System (ECS)

```swift
// Note Entity Component
struct NoteComponent: Component {
    var noteType: NoteType
    var targetTime: TimeInterval
    var spawnTime: TimeInterval
    var scoreValue: Int
    var requiredGesture: GestureType
    var requiredHand: Hand
    var isHit: Bool = false
    var hitQuality: HitQuality?
}

// Movement Component (for note animation)
struct MovementComponent: Component {
    var velocity: SIMD3<Float>
    var acceleration: SIMD3<Float>
    var targetPosition: SIMD3<Float>
    var curve: AnimationCurve
}

// Hit Detection Component
struct HitZoneComponent: Component {
    var radius: Float
    var perfectRadius: Float
    var goodRadius: Float
    var enabled: Bool
    var detectHands: Set<Hand>
}

// Visual Feedback Component
struct FeedbackComponent: Component {
    var particleEmitter: Entity?
    var glowIntensity: Float
    var scaleMultiplier: Float
    var colorShift: SIMD3<Float>
}

// Audio Component (spatial)
struct SpatialAudioComponent: Component {
    var audioResource: AudioFileResource
    var volume: Float
    var pitch: Float
    var spatialBlend: Float           // 0 = 2D, 1 = 3D
    var occlusionEnabled: Bool
}
```

### Note Entity Architecture

```swift
class NoteEntity: Entity {
    // Components
    required init(noteEvent: NoteEvent) {
        super.init()

        // Add visual model
        let mesh = MeshResource.generateSphere(radius: 0.1)
        let material = SimpleMaterial(color: noteEvent.color.uiColor, isMetallic: true)
        self.components.set(ModelComponent(mesh: mesh, materials: [material]))

        // Add note logic
        self.components.set(NoteComponent(
            noteType: noteEvent.type,
            targetTime: noteEvent.timestamp,
            spawnTime: CACurrentMediaTime(),
            scoreValue: noteEvent.points,
            requiredGesture: noteEvent.gesture,
            requiredHand: noteEvent.hand
        ))

        // Add movement
        self.components.set(MovementComponent(
            velocity: noteEvent.direction * noteEvent.speed,
            acceleration: .zero,
            targetPosition: noteEvent.position,
            curve: .easeInOut
        ))

        // Add hit detection
        self.components.set(HitZoneComponent(
            radius: 0.15,
            perfectRadius: 0.05,
            goodRadius: 0.10,
            enabled: true,
            detectHands: [noteEvent.hand]
        ))

        // Add collision shape
        self.components.set(CollisionComponent(
            shapes: [.generateSphere(radius: 0.1)],
            mode: .trigger,
            filter: .init(group: .note, mask: .hand)
        ))
    }
}
```

### Systems Architecture

```swift
// Note Movement System
class NoteMovementSystem: System {
    static let query = EntityQuery(where: .has(MovementComponent.self))

    init(scene: RealityKit.Scene) {
        // Register system
    }

    func update(context: SceneUpdateContext) {
        let deltaTime = Float(context.deltaTime)

        for entity in context.entities(matching: Self.query, updatingSystemWhen: .rendering) {
            guard var movement = entity.components[MovementComponent.self] else { continue }

            // Update position based on velocity
            var transform = entity.transform
            transform.translation += movement.velocity * deltaTime

            // Apply acceleration
            movement.velocity += movement.acceleration * deltaTime

            // Update entity
            entity.transform = transform
            entity.components[MovementComponent.self] = movement
        }
    }
}

// Collision Detection System
class NoteCollisionSystem: System {
    func update(context: SceneUpdateContext) {
        // Check hand-note collisions
        for collision in context.collisionEvents {
            if let noteEntity = collision.entityA as? NoteEntity,
               let handEntity = collision.entityB as? HandEntity {
                handleNoteHit(noteEntity, by: handEntity)
            }
        }
    }

    func handleNoteHit(_ note: NoteEntity, by hand: HandEntity) {
        guard var noteComponent = note.components[NoteComponent.self],
              !noteComponent.isHit else { return }

        // Calculate hit quality based on timing
        let timingDelta = abs(noteComponent.targetTime - CACurrentMediaTime())
        let hitQuality = calculateHitQuality(timingDelta)

        // Verify gesture
        let gestureMatches = verifyGesture(note, hand)

        if gestureMatches {
            // Register hit
            noteComponent.isHit = true
            noteComponent.hitQuality = hitQuality
            note.components[NoteComponent.self] = noteComponent

            // Trigger effects
            triggerHitEffects(note, quality: hitQuality)

            // Update score
            GameStateManager.shared.registerHit(quality: hitQuality, points: noteComponent.scoreValue)
        }
    }
}
```

---

## ARKit Integration

### Spatial Tracking Architecture

```swift
class ARKitManager {
    private var session: ARKitSession?
    private var worldTracking: WorldTrackingProvider?
    private var handTracking: HandTrackingProvider?
    private var sceneReconstruction: SceneReconstructionProvider?

    func initialize() async throws {
        // Request authorizations
        let authResults = await ARKitSession.requestAuthorization(for: [
            .worldSensing,
            .handTracking
        ])

        guard authResults[.worldSensing] == .allowed,
              authResults[.handTracking] == .allowed else {
            throw ARError.notAuthorized
        }

        // Set up providers
        session = ARKitSession()
        worldTracking = WorldTrackingProvider()
        handTracking = HandTrackingProvider()
        sceneReconstruction = SceneReconstructionProvider()

        // Start session
        try await session?.run([
            worldTracking!,
            handTracking!,
            sceneReconstruction!
        ])
    }

    func setupGameplayTracking() {
        Task {
            // Track hand positions
            for await update in handTracking!.anchorUpdates {
                processHandUpdate(update)
            }
        }

        Task {
            // Track world changes
            for await update in worldTracking!.anchorUpdates {
                processWorldUpdate(update)
            }
        }

        Task {
            // Track room mesh
            for await update in sceneReconstruction!.anchorUpdates {
                processSceneUpdate(update)
            }
        }
    }
}
```

### Hand Gesture Recognition

```swift
class GestureRecognizer {
    private let minimumConfidence: Float = 0.85

    func recognizeGesture(from handAnchor: HandAnchor) -> RecognizedGesture? {
        guard let skeleton = handAnchor.handSkeleton else { return nil }

        // Get key joints
        let wrist = skeleton.joint(.wrist)
        let indexTip = skeleton.joint(.indexFingerTip)
        let thumbTip = skeleton.joint(.thumbTip)
        let middleTip = skeleton.joint(.middleFingerTip)

        // Detect common gestures
        if isPunchingGesture(skeleton) {
            return RecognizedGesture(type: .punch, confidence: calculateConfidence(.punch, skeleton))
        }

        if isSwipingGesture(skeleton) {
            let direction = calculateSwipeDirection(skeleton)
            return RecognizedGesture(type: .swipe(direction), confidence: calculateConfidence(.swipe, skeleton))
        }

        if isHoldingGesture(skeleton) {
            return RecognizedGesture(type: .hold, confidence: calculateConfidence(.hold, skeleton))
        }

        return nil
    }

    private func isPunchingGesture(_ skeleton: HandSkeleton) -> Bool {
        // Detect rapid forward hand movement with closed fist
        let wristVelocity = skeleton.joint(.wrist).anchorFromJointTransform.velocity
        let fingersClosed = areFingersClosed(skeleton)

        return wristVelocity.z > 2.0 && fingersClosed
    }
}
```

---

## AI & Machine Learning Architecture

### AI System Overview

```
┌─────────────────────────────────────────────────────────────┐
│                      AI/ML Pipeline                         │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Input Layer                                                │
│  ├── Audio Analysis (CoreML)                                │
│  ├── Player Performance (Real-time)                         │
│  ├── Movement Data (ARKit)                                  │
│  └── Preference History                                     │
│                                                             │
│  Processing Layer                                           │
│  ├── Beat Detection Model                                   │
│  ├── Difficulty Adjustment Model                            │
│  ├── Movement Quality Model                                 │
│  └── Music Recommendation Model                             │
│                                                             │
│  Output Layer                                               │
│  ├── Generated Beat Maps                                    │
│  ├── Difficulty Parameters                                  │
│  ├── Song Recommendations                                   │
│  └── Coaching Feedback                                      │
└─────────────────────────────────────────────────────────────┘
```

### Beat Map Generation AI

```swift
class BeatMapGenerator {
    private let audioAnalyzer: AudioAnalysisModel
    private let patternGenerator: PatternGenerationModel

    func generateBeatMap(for song: Song, difficulty: Difficulty) async throws -> BeatMap {
        // 1. Analyze audio
        let audioFeatures = try await analyzeAudio(song.audioFileURL)

        // 2. Extract musical elements
        let beats = audioFeatures.beats              // BPM-aligned beats
        let downbeats = audioFeatures.downbeats      // Measure markers
        let melody = audioFeatures.melody            // Melodic contour
        let energy = audioFeatures.energy            // Intensity curve

        // 3. Generate note patterns
        var noteEvents: [NoteEvent] = []

        for (index, beat) in beats.enumerated() {
            // Determine if note should spawn
            let shouldSpawn = decideNoteSpawn(
                beat: beat,
                difficulty: difficulty,
                energy: energy.value(at: beat.timestamp),
                melodicImportance: melody.importance(at: beat.timestamp)
            )

            if shouldSpawn {
                let note = generateNote(
                    timestamp: beat.timestamp,
                    difficulty: difficulty,
                    context: NoteContext(
                        previousNotes: noteEvents.suffix(4),
                        energy: energy.value(at: beat.timestamp),
                        melodicDirection: melody.direction(at: beat.timestamp)
                    )
                )
                noteEvents.append(note)
            }
        }

        // 4. Add variety and flow
        noteEvents = enhanceWithVariety(noteEvents, difficulty: difficulty)
        noteEvents = ensurePlayability(noteEvents, difficulty: difficulty)

        return BeatMap(
            difficulty: difficulty,
            noteCount: noteEvents.count,
            maxScore: calculateMaxScore(noteEvents),
            creator: "AI Generator v2.0",
            createdDate: Date(),
            noteEvents: noteEvents,
            obstacleEvents: [],
            environmentEvents: [],
            generatedByAI: true,
            aiVersion: "2.0",
            humanAdjusted: false
        )
    }
}

// Audio Analysis using CoreML
class AudioAnalysisModel {
    private let model: MLModel

    func analyze(_ audioURL: URL) async throws -> AudioFeatures {
        // Load audio
        let audioFile = try AVAudioFile(forReading: audioURL)
        let buffer = AVAudioPCMBuffer(pcmFormat: audioFile.processingFormat, frameCapacity: UInt32(audioFile.length))!
        try audioFile.read(into: buffer)

        // Extract features using CoreML
        let input = try MLMultiArray(shape: [1, NSNumber(value: buffer.frameLength)], dataType: .float32)

        // Run inference
        let output = try await model.prediction(from: AudioAnalysisInput(audio: input))

        // Parse results
        return AudioFeatures(
            bpm: output.bpm,
            beats: output.beatTimestamps,
            downbeats: output.downbeatTimestamps,
            melody: output.melodicContour,
            energy: output.energyCurve,
            key: output.musicalKey,
            timbre: output.timbreProfile
        )
    }
}
```

### Dynamic Difficulty Adjustment

```swift
class DifficultyAdjustmentAI {
    private var performanceWindow: [PerformanceFrame] = []
    private let windowSize = 100  // Last 100 notes

    func adjustDifficulty(currentPerformance: PerformanceMetrics) -> DifficultyAdjustment {
        // Track performance
        performanceWindow.append(PerformanceFrame(
            timestamp: CACurrentMediaTime(),
            accuracy: currentPerformance.accuracy,
            combo: currentPerformance.combo,
            missRate: currentPerformance.missRate
        ))

        // Keep window size
        if performanceWindow.count > windowSize {
            performanceWindow.removeFirst()
        }

        // Calculate flow state score (0-1)
        let flowScore = calculateFlowScore(performanceWindow)

        // Adjust difficulty to maintain flow
        let adjustment: DifficultyAdjustment

        if flowScore < 0.3 {
            // Too hard - reduce difficulty
            adjustment = DifficultyAdjustment(
                noteSpeedMultiplier: 0.95,
                noteDensityMultiplier: 0.90,
                complexityReduction: 0.15,
                restPeriodsIncrease: 1.2
            )
        } else if flowScore > 0.8 {
            // Too easy - increase challenge
            adjustment = DifficultyAdjustment(
                noteSpeedMultiplier: 1.05,
                noteDensityMultiplier: 1.10,
                complexityIncrease: 0.10,
                restPeriodsDecrease: 0.9
            )
        } else {
            // Perfect flow state - maintain
            adjustment = DifficultyAdjustment.neutral
        }

        return adjustment
    }

    private func calculateFlowScore(_ performance: [PerformanceFrame]) -> Double {
        // Flow state indicators:
        // - High accuracy (80-95%)
        // - Consistent performance (low variance)
        // - Moderate combo maintenance
        // - Low frustration signals (miss spikes)

        let avgAccuracy = performance.map(\.accuracy).reduce(0, +) / Double(performance.count)
        let variance = calculateVariance(performance.map(\.accuracy))
        let missSpikes = detectMissSpikes(performance)

        // Optimal flow: 85% accuracy, low variance, no spikes
        let accuracyScore = 1.0 - abs(avgAccuracy - 0.85) / 0.85
        let consistencyScore = max(0, 1.0 - variance * 5.0)
        let frustrationScore = max(0, 1.0 - Double(missSpikes) * 0.2)

        return (accuracyScore + consistencyScore + frustrationScore) / 3.0
    }
}
```

### Movement Quality Analysis

```swift
class MovementAnalyzer {
    private let coreMLModel: MLModel

    func analyzeMovementQuality(handTrajectory: [HandPosition]) -> MovementQuality {
        // Analyze:
        // - Efficiency (shortest path vs actual path)
        // - Smoothness (velocity consistency)
        // - Rhythm (tempo adherence)
        // - Form (biomechanically sound)

        let efficiency = calculateEfficiency(handTrajectory)
        let smoothness = calculateSmoothness(handTrajectory)
        let rhythm = calculateRhythmAdherence(handTrajectory)
        let form = assessForm(handTrajectory)

        return MovementQuality(
            overallScore: (efficiency + smoothness + rhythm + form) / 4.0,
            efficiency: efficiency,
            smoothness: smoothness,
            rhythm: rhythm,
            form: form,
            recommendations: generateRecommendations(efficiency, smoothness, rhythm, form)
        )
    }

    func generateCoachingFeedback(_ quality: MovementQuality) -> String {
        if quality.efficiency < 0.7 {
            return "Try shorter, more direct movements to hit notes"
        } else if quality.smoothness < 0.7 {
            return "Focus on smooth, controlled motions"
        } else if quality.rhythm < 0.7 {
            return "Stay with the beat - feel the rhythm"
        } else if quality.form < 0.7 {
            return "Keep your wrists straight and use your whole arm"
        } else {
            return "Excellent form! You're a natural!"
        }
    }
}
```

---

## Audio Architecture

### Spatial Audio System

```swift
class SpatialAudioEngine {
    private let audioEngine = AVAudioEngine()
    private let environment = AVAudioEnvironmentNode()
    private let musicPlayer = AVAudioPlayerNode()

    // Spatial audio sources
    private var noteSounds: [UUID: AVAudioPlayerNode] = [:]
    private var ambientPlayers: [AVAudioPlayerNode] = []

    func initialize() {
        // Set up audio engine
        audioEngine.attach(environment)
        audioEngine.attach(musicPlayer)

        // Configure environment for spatial audio
        environment.listenerPosition = AVAudio3DPoint(x: 0, y: 0, z: 0)
        environment.listenerAngularOrientation = AVAudio3DAngularOrientation(yaw: 0, pitch: 0, roll: 0)
        environment.renderingAlgorithm = .HRTF
        environment.distanceAttenuationParameters.maximumDistance = 10.0

        // Connect nodes
        audioEngine.connect(musicPlayer, to: audioEngine.mainMixerNode, format: nil)
        audioEngine.connect(environment, to: audioEngine.mainMixerNode, format: nil)

        // Start engine
        audioEngine.prepare()
        try? audioEngine.start()
    }

    func playNote(at position: SIMD3<Float>, type: NoteType) {
        let player = AVAudioPlayerNode()
        audioEngine.attach(player)
        audioEngine.connect(player, to: environment, format: nil)

        // Set 3D position
        player.position = AVAudio3DPoint(
            x: position.x,
            y: position.y,
            z: position.z
        )

        // Play sound
        let sound = getNoteSound(type)
        player.scheduleBuffer(sound, completionHandler: {
            self.audioEngine.detach(player)
        })
        player.play()
    }

    func updateListenerPosition(head: Transform) {
        // Update listener (player's head) position and orientation
        let position = head.translation
        let rotation = head.rotation

        environment.listenerPosition = AVAudio3DPoint(
            x: position.x,
            y: position.y,
            z: position.z
        )

        let euler = rotation.eulerAngles
        environment.listenerAngularOrientation = AVAudio3DAngularOrientation(
            yaw: euler.y,
            pitch: euler.x,
            roll: euler.z
        )
    }
}
```

### Music Synchronization

```swift
class MusicSyncEngine {
    private var audioPlayer: AVAudioPlayerNode?
    private var startTime: TimeInterval?
    private var currentBPM: Double

    var currentMusicTime: TimeInterval {
        guard let startTime = startTime else { return 0 }
        return CACurrentMediaTime() - startTime
    }

    func startSong(_ song: Song) {
        // Load audio file
        let audioFile = try! AVAudioFile(forReading: song.audioFileURL)

        // Schedule playback
        audioPlayer?.scheduleFile(audioFile, at: nil) {
            // Song completed
            self.handleSongComplete()
        }

        // Start with countdown
        let countdownDuration: TimeInterval = 3.0

        DispatchQueue.main.asyncAfter(deadline: .now() + countdownDuration) {
            self.startTime = CACurrentMediaTime()
            self.audioPlayer?.play()
        }
    }

    func getCurrentBeat() -> Double {
        let secondsPerBeat = 60.0 / currentBPM
        return currentMusicTime / secondsPerBeat
    }

    func getTimeUntilBeat(_ beat: Double) -> TimeInterval {
        let secondsPerBeat = 60.0 / currentBPM
        let beatTime = beat * secondsPerBeat
        return beatTime - currentMusicTime
    }
}
```

---

## Multiplayer Architecture

### SharePlay Integration

```swift
class MultiplayerManager: ObservableObject {
    @Published var groupSession: GroupSession<RhythmFlowActivity>?
    @Published var messenger: GroupSessionMessenger?
    @Published var participants: [Participant] = []

    func startSharePlaySession(song: Song, difficulty: Difficulty) async {
        // Create activity
        let activity = RhythmFlowActivity(
            songID: song.id,
            difficulty: difficulty
        )

        // Start group session
        switch await activity.prepareForActivation() {
        case .activationPreferred:
            do {
                _ = try await activity.activate()
            } catch {
                print("Failed to activate: \(error)")
            }
        case .activationDisabled:
            // Start local game
            startLocalGame(song: song, difficulty: difficulty)
        default:
            break
        }
    }

    func configureGroupSession(_ session: GroupSession<RhythmFlowActivity>) {
        groupSession = session
        messenger = GroupSessionMessenger(session: session)

        // Join session
        session.join()

        // Handle participant changes
        Task {
            for await participants in session.$activeParticipants.values {
                self.participants = participants.map { Participant(id: $0.id) }
            }
        }

        // Handle messages
        Task {
            for await (message, sender) in messenger!.messages(of: GameStateMessage.self) {
                handleGameStateMessage(message, from: sender)
            }
        }
    }

    func broadcastScore(_ score: Int, combo: Int) {
        Task {
            let message = GameStateMessage(
                type: .scoreUpdate,
                score: score,
                combo: combo,
                timestamp: CACurrentMediaTime()
            )
            try? await messenger?.send(message)
        }
    }
}

// SharePlay Activity
struct RhythmFlowActivity: GroupActivity {
    let songID: UUID
    let difficulty: Difficulty

    var metadata: GroupActivityMetadata {
        var meta = GroupActivityMetadata()
        meta.type = .generic
        meta.title = "Rhythm Flow Battle"
        meta.previewImage = getSongArtwork(songID)
        return meta
    }
}
```

### Network Synchronization

```swift
class NetworkSyncManager {
    private var syncClock: GroupSessionClock?

    func synchronizeGameStart(with participants: [Participant]) async {
        // 1. All participants send ready signal
        await sendReadySignal()

        // 2. Wait for all ready signals
        let allReady = await waitForAllReady(participants)

        guard allReady else { return }

        // 3. Host determines start time
        if isHost {
            let startTime = Date().addingTimeInterval(3.0)
            await broadcastStartTime(startTime)
        }

        // 4. All clients synchronize to start time
        let syncedStartTime = await receiveStartTime()

        // 5. Start game at exact synchronized time
        let delay = syncedStartTime.timeIntervalSinceNow
        try? await Task.sleep(for: .seconds(delay))

        startGame()
    }

    func synchronizeMusicPlayback() {
        // Use GroupSession clock for perfect sync
        if let clock = syncClock {
            let syncedTime = clock.time
            // Adjust audio playback to match
        }
    }
}
```

---

## Physics & Collision Systems

### Physics World Configuration

```swift
class PhysicsManager {
    private var physicsWorld: PhysicsWorld

    func initialize(scene: RealityKit.Scene) {
        physicsWorld = PhysicsWorld()

        // Configure physics simulation
        physicsWorld.gravity = [0, -9.81, 0]  // Standard gravity
        physicsWorld.timeScale = 1.0

        // Set up collision groups
        setupCollisionFilters()
    }

    func setupCollisionFilters() {
        // Collision groups
        enum CollisionGroup: UInt32 {
            case note = 1
            case hand = 2
            case obstacle = 4
            case boundary = 8
            case floor = 16
        }

        // Notes only collide with hands
        let noteFilter = CollisionFilter(
            group: CollisionGroup.note,
            mask: CollisionGroup.hand
        )

        // Hands collide with notes and obstacles
        let handFilter = CollisionFilter(
            group: CollisionGroup.hand,
            mask: CollisionGroup.note.rawValue | CollisionGroup.obstacle.rawValue
        )
    }
}
```

### Collision Detection

```swift
class CollisionDetector {
    func checkNoteHits(notes: [NoteEntity], hands: [HandEntity]) -> [NoteHit] {
        var hits: [NoteHit] = []

        for note in notes {
            guard !note.isHit else { continue }

            for hand in hands {
                // Check distance
                let distance = simd_distance(note.position, hand.position)

                if distance < note.hitRadius {
                    // Verify timing
                    let timingError = abs(note.targetTime - currentMusicTime)

                    if timingError < maxTimingWindow {
                        // Valid hit!
                        let quality = calculateHitQuality(timingError, distance)
                        hits.append(NoteHit(
                            note: note,
                            hand: hand,
                            quality: quality,
                            timestamp: CACurrentMediaTime()
                        ))
                    }
                }
            }
        }

        return hits
    }

    func calculateHitQuality(_ timingError: TimeInterval, _ distance: Float) -> HitQuality {
        // Perfect: < 50ms timing, < 0.05m distance
        if timingError < 0.05 && distance < 0.05 {
            return .perfect
        }
        // Great: < 100ms timing, < 0.10m distance
        else if timingError < 0.10 && distance < 0.10 {
            return .great
        }
        // Good: < 150ms timing, < 0.15m distance
        else if timingError < 0.15 && distance < 0.15 {
            return .good
        }
        else {
            return .okay
        }
    }
}
```

---

## Save/Load System

### Persistence Architecture

```swift
class PersistenceManager {
    private let fileManager = FileManager.default
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    // Local storage
    var documentsDirectory: URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    // Save player profile
    func saveProfile(_ profile: PlayerProfile) throws {
        let data = try encoder.encode(profile)
        let url = documentsDirectory.appendingPathComponent("profile.json")
        try data.write(to: url)

        // Also sync to CloudKit
        Task {
            await cloudSyncManager.syncProfile(profile)
        }
    }

    // Save game session
    func saveGameSession(_ session: GameSession) throws {
        let data = try encoder.encode(session)
        let filename = "session_\(session.id.uuidString).json"
        let url = documentsDirectory.appendingPathComponent("sessions/\(filename)")
        try data.write(to: url)
    }

    // Load player profile
    func loadProfile() throws -> PlayerProfile {
        let url = documentsDirectory.appendingPathComponent("profile.json")
        let data = try Data(contentsOf: url)
        return try decoder.decode(PlayerProfile.self, from: data)
    }
}
```

### CloudKit Synchronization

```swift
class CloudSyncManager {
    private let container = CKContainer(identifier: "iCloud.com.beatspace.rhythmflow")
    private let database: CKDatabase

    init() {
        database = container.privateCloudDatabase
    }

    func syncProfile(_ profile: PlayerProfile) async {
        let record = CKRecord(recordType: "PlayerProfile")
        record["username"] = profile.username
        record["level"] = profile.level
        record["totalScore"] = profile.totalScore
        record["statistics"] = try? JSONEncoder().encode(profile.statistics)

        do {
            try await database.save(record)
        } catch {
            print("CloudKit sync failed: \(error)")
        }
    }

    func syncLeaderboard(_ entry: LeaderboardEntry) async {
        let record = CKRecord(recordType: "LeaderboardEntry")
        record["playerID"] = CKRecord.Reference(recordID: entry.playerID.recordID, action: .none)
        record["songID"] = entry.songID
        record["score"] = entry.score
        record["accuracy"] = entry.accuracy
        record["timestamp"] = entry.timestamp

        try? await database.save(record)
    }
}
```

---

## Performance Optimization

### Frame Rate Optimization

```swift
class PerformanceOptimizer {
    private var targetFrameRate: Int = 90
    private var currentFrameRate: Int = 90

    func optimizeForPerformance() {
        // Dynamic quality adjustment
        if currentFrameRate < targetFrameRate - 5 {
            // Reduce quality
            reduceParticleCount()
            simplifyMaterials()
            decreaseShadowQuality()
            enableDynamicLOD()
        } else if currentFrameRate > targetFrameRate + 5 {
            // Can afford to increase quality
            increaseParticleCount()
            enhanceMaterials()
            increaseShadowQuality()
        }
    }

    func reduceParticleCount() {
        particleEmitter.birthRate *= 0.8
        particleEmitter.maximumParticles = Int(Float(particleEmitter.maximumParticles) * 0.8)
    }

    func enableDynamicLOD() {
        // Reduce note model complexity based on distance
        for note in activeNotes {
            let distance = simd_distance(note.position, cameraPosition)
            if distance > 3.0 {
                note.levelOfDetail = .low
            } else if distance > 1.5 {
                note.levelOfDetail = .medium
            } else {
                note.levelOfDetail = .high
            }
        }
    }
}
```

### Object Pooling

```swift
class NoteEntityPool {
    private var pool: [NoteType: [NoteEntity]] = [:]
    private let maxPoolSize = 100

    func acquire(type: NoteType) -> NoteEntity {
        // Try to reuse existing entity
        if var typePool = pool[type], !typePool.isEmpty {
            return typePool.removeLast()
        }

        // Create new if pool empty
        return NoteEntity(type: type)
    }

    func release(_ entity: NoteEntity) {
        // Reset entity state
        entity.isHit = false
        entity.isEnabled = false
        entity.position = .zero

        // Return to pool
        var typePool = pool[entity.type] ?? []
        if typePool.count < maxPoolSize {
            typePool.append(entity)
            pool[entity.type] = typePool
        }
    }
}
```

### Memory Management

```swift
class MemoryManager {
    func monitorMemoryUsage() {
        let memoryUsage = getMemoryUsage()

        if memoryUsage > 0.8 {  // 80% of available memory
            // Aggressive cleanup
            clearUnusedAssets()
            reduceParticleLifetime()
            compactGameHistory()
        } else if memoryUsage > 0.6 {
            // Preventive cleanup
            clearOldSessions()
            unloadUnusedSongs()
        }
    }

    private func getMemoryUsage() -> Double {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4

        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }

        guard kerr == KERN_SUCCESS else { return 0 }

        let usedMemory = Double(info.resident_size)
        let totalMemory = Double(ProcessInfo.processInfo.physicalMemory)
        return usedMemory / totalMemory
    }
}
```

---

## Security & Privacy

### Data Privacy

```swift
class PrivacyManager {
    // All movement data processed locally
    func processMovementData(_ handTrajectory: [HandPosition]) -> MovementQuality {
        // Analysis happens on-device
        // No raw hand tracking data leaves device
        return movementAnalyzer.analyze(handTrajectory)
    }

    // Anonymous analytics
    func trackEvent(_ event: AnalyticsEvent) {
        // Strip personally identifiable information
        let anonymousEvent = event.anonymized()

        // Only send if user opted in
        if userPreferences.analyticsEnabled {
            analyticsService.send(anonymousEvent)
        }
    }

    // Secure cloud sync
    func syncToCloud(_ data: Codable) async {
        // Encrypt before upload
        let encrypted = try? encryption.encrypt(data)
        await cloudKit.save(encrypted)
    }
}
```

### Anti-Cheat Measures

```swift
class AntiCheatSystem {
    func validateScore(_ session: GameSession) -> Bool {
        // 1. Check for impossible scores
        let maxPossibleScore = session.beatMap.maxScore
        if session.score > maxPossibleScore {
            return false
        }

        // 2. Verify hit timing consistency
        let timingAnomalies = detectTimingAnomalies(session.hitEvents)
        if timingAnomalies > 5 {
            return false
        }

        // 3. Check for perfect score patterns (too consistent)
        let suspiciouslyPerfect = session.perfectHits == session.totalHits && session.totalHits > 100
        if suspiciouslyPerfect {
            return false
        }

        // 4. Validate movement physics
        let physicsViolations = validateMovementPhysics(session.hitEvents)
        if physicsViolations {
            return false
        }

        return true
    }
}
```

---

## Conclusion

This architecture provides a solid foundation for building Rhythm Flow as a high-performance, engaging spatial rhythm game on visionOS. The design emphasizes:

- **Performance**: 90 FPS target with dynamic quality scaling
- **Modularity**: Clear separation of concerns with ECS architecture
- **Scalability**: Object pooling and efficient resource management
- **AI Integration**: Dynamic difficulty and beat generation
- **Privacy**: Local processing with minimal data collection
- **Multiplayer**: SharePlay integration for social experiences

The architecture is designed to be extended and refined during implementation.
