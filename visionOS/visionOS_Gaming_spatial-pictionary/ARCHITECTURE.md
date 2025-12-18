# Spatial Pictionary - Technical Architecture

## Document Version
- **Version**: 1.0
- **Last Updated**: 2025-11-19
- **Platform**: visionOS 2.0+
- **Target Device**: Apple Vision Pro

---

## Table of Contents
1. [Game Architecture Overview](#game-architecture-overview)
2. [visionOS Gaming Patterns](#visionos-gaming-patterns)
3. [Data Models & Schemas](#data-models--schemas)
4. [RealityKit Gaming Components](#realitykit-gaming-components)
5. [ARKit Integration](#arkit-integration)
6. [Multiplayer Architecture](#multiplayer-architecture)
7. [Physics & Collision Systems](#physics--collision-systems)
8. [Audio Architecture](#audio-architecture)
9. [Performance Optimization](#performance-optimization)
10. [Save/Load System](#saveload-system)

---

## 1. Game Architecture Overview

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     Application Layer                        │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │   SwiftUI    │  │  Game Views  │  │  HUD/Menus   │      │
│  │  Interface   │  │  & Controls  │  │   System     │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└─────────────────────────────────────────────────────────────┘
                            │
┌─────────────────────────────────────────────────────────────┐
│                   Game Logic Layer                          │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │ Game State   │  │   Turn-Based │  │   Scoring    │      │
│  │  Manager     │  │   Controller │  │   System     │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │   Drawing    │  │   Guessing   │  │   Timer      │      │
│  │   Manager    │  │   System     │  │   Manager    │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└─────────────────────────────────────────────────────────────┘
                            │
┌─────────────────────────────────────────────────────────────┐
│                  3D Rendering Layer                         │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │ RealityKit   │  │   Drawing    │  │  Particle    │      │
│  │   Renderer   │  │   Engine     │  │   System     │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
│  ┌──────────────┐  ┌──────────────┐                        │
│  │  Material    │  │   Lighting   │                        │
│  │   System     │  │   System     │                        │
│  └──────────────┘  └──────────────┘                        │
└─────────────────────────────────────────────────────────────┘
                            │
┌─────────────────────────────────────────────────────────────┐
│                   Input/Output Layer                        │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │ Hand Tracking│  │    Voice     │  │   Spatial    │      │
│  │   System     │  │ Recognition  │  │    Audio     │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└─────────────────────────────────────────────────────────────┘
                            │
┌─────────────────────────────────────────────────────────────┐
│                  Multiplayer Layer                          │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │  SharePlay   │  │    Local     │  │    State     │      │
│  │  Integration │  │   Network    │  │    Sync      │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└─────────────────────────────────────────────────────────────┘
```

### Game Loop Architecture

```swift
// Primary Game Loop (90 FPS Target)
class GameLoop {
    private var lastUpdateTime: TimeInterval = 0
    private let targetFPS: Double = 90.0

    func update(currentTime: TimeInterval) {
        let deltaTime = currentTime - lastUpdateTime

        // 1. Input Phase (~2ms budget)
        processHandInput(deltaTime)
        processVoiceInput()

        // 2. Update Phase (~5ms budget)
        updateGameState(deltaTime)
        updatePhysics(deltaTime)
        updateTimers(deltaTime)

        // 3. Render Phase (~4ms budget)
        updateDrawingMeshes()
        updateParticles(deltaTime)

        // 4. Network Phase (~1ms budget)
        synchronizeMultiplayer(deltaTime)

        lastUpdateTime = currentTime
    }
}
```

### State Management Architecture

```swift
// Centralized State Management using Observation Framework
@Observable
class GameState {
    // Game Phase
    enum Phase {
        case lobby
        case tutorial
        case wordSelection
        case drawing
        case guessing
        case reveal
        case scoring
        case gameOver
    }

    var currentPhase: Phase = .lobby
    var players: [Player] = []
    var currentArtist: Player?
    var currentWord: Word?
    var drawings: [Drawing3D] = []
    var scores: [PlayerID: Int] = [:]
    var roundNumber: Int = 0
    var timeRemaining: TimeInterval = 0

    // Centralized state transitions
    func transitionTo(_ newPhase: Phase) {
        // Handle cleanup of current phase
        exitCurrentPhase()

        // Transition to new phase
        currentPhase = newPhase

        // Initialize new phase
        enterNewPhase(newPhase)
    }
}
```

---

## 2. visionOS Gaming Patterns

### Spatial Gaming Modes

```swift
// Progressive Immersion System
enum SpatialMode {
    case windowed           // 2D-style interface (comfortable start)
    case volume             // Bounded 3D space (primary mode)
    case mixedReality       // Room-scale with passthrough
    case fullImmersion      // Complete virtual environment
}

class SpatialModeManager {
    @Published var currentMode: SpatialMode = .volume

    // Adaptive mode switching based on comfort
    func recommendMode(for players: [Player]) -> SpatialMode {
        let avgExperience = players.map(\.spatialExperience).reduce(0, +) / players.count

        switch avgExperience {
        case 0..<20: return .windowed
        case 20..<50: return .volume
        case 50..<80: return .mixedReality
        default: return .fullImmersion
        }
    }
}
```

### Volume-Based Gaming (Primary Mode)

```swift
// Main game happens in a 1.5m x 1.5m x 1.5m volume
struct DrawingVolume {
    let size: SIMD3<Float> = [1.5, 1.5, 1.5] // meters
    let position: SIMD3<Float> = [0, 1.2, -2.0] // eye level, 2m away

    // Volume subdivisions for organization
    enum Zone {
        case drawingCanvas      // Central 1m³ cube
        case toolPalette        // Left side panel
        case playerDisplay      // Top strip
        case timerZone          // Upper right
        case guessInput         // Lower panel
    }

    func worldPosition(for zone: Zone) -> SIMD3<Float> {
        switch zone {
        case .drawingCanvas: return position
        case .toolPalette: return position + [-0.8, 0, 0]
        case .playerDisplay: return position + [0, 0.8, 0]
        case .timerZone: return position + [0.7, 0.7, 0]
        case .guessInput: return position + [0, -0.7, 0]
        }
    }
}
```

### Comfort-First Design Pattern

```swift
class ComfortManager {
    // Ergonomic positioning
    func adjustCanvasHeight(for headPosition: SIMD3<Float>) -> Float {
        // Canvas at comfortable arm's reach
        let optimalHeight = headPosition.y - 0.2 // Slightly below eye level
        return optimalHeight
    }

    // Fatigue prevention
    func checkFatigue(armPosition: SIMD3<Float>, duration: TimeInterval) -> Bool {
        // Detect extended reach or uncomfortable positions
        let reachDistance = length(armPosition)
        let isOverextended = reachDistance > 0.6 // 60cm max comfortable reach
        let tooLong = duration > 120.0 // 2 minutes in same position

        return isOverextended || tooLong
    }

    // Break recommendations
    func suggestBreak(playTime: TimeInterval) -> Bool {
        return playTime.truncatingRemainder(dividingBy: 1200) < 1.0 // Every 20 minutes
    }
}
```

---

## 3. Data Models & Schemas

### Core Game Models

```swift
// Player Model
struct Player: Identifiable, Codable {
    let id: UUID
    var name: String
    var avatar: AvatarConfiguration
    var score: Int = 0
    var isLocal: Bool
    var deviceID: String
    var spatialExperience: Int = 0 // 0-100 comfort level

    // Statistics
    var gamesPlayed: Int = 0
    var correctGuesses: Int = 0
    var drawingsCompleted: Int = 0
    var averageGuessTime: TimeInterval = 0
}

// Word/Prompt Model
struct Word: Identifiable, Codable {
    let id: UUID
    var text: String
    var category: Category
    var difficulty: Difficulty
    var language: String = "en"
    var metadata: [String: String] = [:]

    enum Difficulty: String, Codable {
        case easy = "Easy"       // 1 point
        case medium = "Medium"   // 2 points
        case hard = "Hard"       // 3 points
    }

    enum Category: String, Codable, CaseIterable {
        case animals, objects, actions, places, food
        case vehicles, nature, sports, occupations, abstract
        case educational, holiday, movie, custom
    }
}

// Drawing Data Model
struct Drawing3D: Identifiable, Codable {
    let id: UUID
    var strokes: [Stroke3D]
    var createdBy: UUID // Player ID
    var word: Word
    var timestamp: Date
    var meshData: Data? // Compressed mesh for saving

    // Metadata
    var viewCount: Int = 0
    var likeCount: Int = 0
    var timeToComplete: TimeInterval = 0
}

// 3D Stroke Model
struct Stroke3D: Identifiable, Codable {
    let id: UUID
    var points: [SIMD3<Float>]
    var color: CodableColor
    var thickness: Float
    var material: MaterialType
    var timestamps: [TimeInterval] // For replay

    enum MaterialType: String, Codable {
        case solid, glow, sketch, neon, particle
    }
}

// Game Session Model
struct GameSession: Identifiable, Codable {
    let id: UUID
    var players: [Player]
    var rounds: [Round]
    var settings: GameSettings
    var startTime: Date
    var endTime: Date?

    struct Round: Codable {
        var roundNumber: Int
        var artist: UUID
        var word: Word
        var drawing: Drawing3D?
        var guesses: [Guess]
        var scores: [UUID: Int]
    }

    struct Guess: Codable {
        var playerID: UUID
        var text: String
        var timestamp: TimeInterval
        var isCorrect: Bool
    }
}

// Game Settings Model
struct GameSettings: Codable {
    var roundDuration: TimeInterval = 90 // seconds
    var numberOfRounds: Int = 8
    var difficulty: Word.Difficulty = .medium
    var categories: Set<Word.Category>
    var maxPlayers: Int = 8
    var allowHints: Bool = true
    var customWordList: [Word] = []

    // Spatial settings
    var spatialMode: String = "volume"
    var canvasSize: Float = 1.0 // meters
    var enableParticles: Bool = true
}

// Color that can be encoded
struct CodableColor: Codable {
    var red: Float
    var green: Float
    var blue: Float
    var alpha: Float

    var color: Color {
        Color(.sRGB, red: Double(red), green: Double(green), blue: Double(blue), opacity: Double(alpha))
    }
}
```

### Multiplayer Synchronization Models

```swift
// Network message protocol
enum NetworkMessage: Codable {
    case playerJoined(Player)
    case playerLeft(UUID)
    case gameStateUpdate(GameStateSnapshot)
    case strokeAdded(Stroke3D, UUID) // stroke, playerID
    case guessSubmitted(String, UUID) // guess, playerID
    case roundStart(Round)
    case roundEnd(RoundResults)
    case timerUpdate(TimeInterval)
}

// Efficient state snapshot for sync
struct GameStateSnapshot: Codable {
    var phase: String
    var currentArtistID: UUID?
    var timeRemaining: TimeInterval
    var scores: [UUID: Int]
    var roundNumber: Int
    var timestamp: Date
}
```

---

## 4. RealityKit Gaming Components

### Entity Component System (ECS) Architecture

```swift
// Custom Components for Spatial Pictionary

// Drawing Stroke Component
struct DrawingStrokeComponent: Component {
    var strokeID: UUID
    var points: [SIMD3<Float>]
    var color: SIMD4<Float>
    var thickness: Float
    var isComplete: Bool
}

// Interactive Tool Component
struct InteractiveToolComponent: Component {
    var toolType: ToolType
    var isActive: Bool
    var lastInteractionTime: TimeInterval

    enum ToolType {
        case brush, eraser, colorPicker, shapeTool, sculptTool
    }
}

// Animation Component
struct DrawingAnimationComponent: Component {
    var animationType: AnimationType
    var duration: TimeInterval
    var startTime: TimeInterval

    enum AnimationType {
        case drawReveal      // Progressive stroke appearance
        case pulseGlow       // Highlight effect
        case fadeIn, fadeOut
        case celebration     // Success animation
    }
}

// Multiplayer Sync Component
struct NetworkSyncComponent: Component {
    var ownerID: UUID
    var lastSyncTime: Date
    var priority: SyncPriority

    enum SyncPriority {
        case critical    // Player strokes - immediate sync
        case high        // Tool selections
        case medium      // UI updates
        case low         // Ambient effects
    }
}
```

### RealityKit Systems

```swift
// Drawing System - Manages 3D stroke creation
class DrawingSystem: System {
    static let query = EntityQuery(where: .has(DrawingStrokeComponent.self))

    func update(context: SceneUpdateContext) {
        context.scene.performQuery(Self.query).forEach { entity in
            guard var stroke = entity.components[DrawingStrokeComponent.self] else { return }

            // Update mesh geometry from points
            updateStrokeMesh(entity: entity, stroke: stroke)

            // Apply material and shading
            applyStrokeMaterial(entity: entity, stroke: stroke)
        }
    }

    private func updateStrokeMesh(entity: Entity, stroke: DrawingStrokeComponent) {
        // Convert points to mesh using tube geometry
        let mesh = generateTubeMesh(points: stroke.points, radius: stroke.thickness)
        entity.components[ModelComponent.self] = ModelComponent(mesh: mesh)
    }
}

// Interaction System - Handles hand tracking input
class InteractionSystem: System {
    func update(context: SceneUpdateContext) {
        // Process hand tracking data
        if let handTracking = context.scene.handTracking {
            processHandInput(handTracking)
        }
    }

    private func processHandInput(_ tracking: HandTrackingData) {
        // Detect drawing gestures
        if tracking.isIndexExtended && tracking.isPinching {
            addDrawingPoint(at: tracking.indexTipPosition)
        }
    }
}

// Particle System - Visual effects
class ParticleEffectSystem: System {
    func update(context: SceneUpdateContext) {
        // Emit particles at drawing points
        // Success celebrations
        // Ambient atmospheric effects
    }
}
```

### Scene Graph Organization

```
RootEntity (WorldAnchor)
├── GameVolumeEntity
│   ├── DrawingCanvasEntity
│   │   ├── StrokesContainerEntity
│   │   │   ├── Stroke_001_Entity (DrawingStrokeComponent)
│   │   │   ├── Stroke_002_Entity (DrawingStrokeComponent)
│   │   │   └── ...
│   │   └── CanvasBoundsEntity (Visual guide)
│   ├── ToolPaletteEntity
│   │   ├── BrushTool (InteractiveToolComponent)
│   │   ├── ColorPalette (InteractiveToolComponent)
│   │   └── ShapeTool (InteractiveToolComponent)
│   ├── UIElementsEntity
│   │   ├── TimerDisplay
│   │   ├── PlayerList
│   │   └── ScoreBoard
│   └── ParticleEffectsEntity
│       ├── AmbientParticles
│       └── CelebrationEffects
└── PlayerAvatarsEntity
    ├── LocalPlayer
    └── RemotePlayers
        ├── Player_001 (NetworkSyncComponent)
        └── Player_002 (NetworkSyncComponent)
```

---

## 5. ARKit Integration

### Spatial Tracking

```swift
class SpatialTrackingManager {
    // World tracking for canvas anchoring
    func setupWorldTracking() {
        let worldTracking = WorldTrackingProvider()
        worldTracking.start()
    }

    // Hand tracking for drawing
    func setupHandTracking() {
        let handTracking = HandTrackingProvider()
        handTracking.start()

        // High precision mode for accurate drawing
        handTracking.setTargetLatency(.minimal) // <16ms
    }

    // Anchor drawing canvas to stable world position
    func anchorCanvas(at position: SIMD3<Float>) -> AnchorEntity {
        let anchor = AnchorEntity(.world(transform: Transform(translation: position)))
        return anchor
    }
}
```

### Hand Gesture Recognition

```swift
class HandGestureRecognizer {
    enum DrawingGesture {
        case indexExtended      // Line drawing
        case pinchAndDrag       // Shape creation
        case twoFingerPinch     // Precision work
        case fistClosure        // Brush size
        case palmPush           // Object movement
        case waveLeft           // Undo
    }

    func recognizeGesture(from chirality: HandAnchor.Chirality,
                         skeleton: HandSkeleton) -> DrawingGesture? {
        // Finger state analysis
        let indexExtended = isFingerExtended(.indexFinger, skeleton)
        let middleExtended = isFingerExtended(.middleFinger, skeleton)
        let isPinching = checkPinchState(skeleton)

        // Gesture classification
        if indexExtended && !middleExtended && !isPinching {
            return .indexExtended
        } else if isPinching {
            return .pinchAndDrag
        }

        return nil
    }

    // Sub-millimeter precision tracking
    func getDrawingPosition(from hand: HandAnchor) -> SIMD3<Float>? {
        guard let indexTip = hand.handSkeleton?.joint(.indexFingerTip) else {
            return nil
        }
        return indexTip.anchorFromJointTransform.columns.3.xyz
    }
}
```

---

## 6. Multiplayer Architecture

### Network Topology

```
Local Multiplayer (Mesh Network)
┌─────────┐     ┌─────────┐     ┌─────────┐
│ Player 1│────│ Player 2│────│ Player 3│
│  (Host) │     │         │     │         │
└────┬────┘     └─────────┘     └─────────┘
     │
     │
┌────┴────┐     ┌─────────┐
│ Player 4│────│ Player 5│
│         │     │         │
└─────────┘     └─────────┘

Remote Multiplayer (Star Topology via SharePlay)
                ┌──────────┐
                │ SharePlay│
                │  Server  │
                └────┬─────┘
        ┌────────────┼────────────┐
   ┌────┴───┐   ┌────┴───┐   ┌────┴───┐
   │Local   │   │Remote  │   │Remote  │
   │Group A │   │Group B │   │Group C │
   │(3 ppl) │   │(2 ppl) │   │(1 ppl) │
   └────────┘   └────────┘   └────────┘
```

### State Synchronization Architecture

```swift
class MultiplayerSyncManager {
    // Differential sync for efficiency
    func syncDrawingStroke(_ stroke: Stroke3D) {
        // Delta compression: only send new points
        let lastSyncedIndex = getLastSyncedIndex(for: stroke.id)
        let newPoints = Array(stroke.points[lastSyncedIndex...])

        if newPoints.count > 0 {
            let deltaMessage = StrokeDelta(
                strokeID: stroke.id,
                newPoints: newPoints,
                startIndex: lastSyncedIndex
            )

            broadcast(deltaMessage, priority: .critical)
        }
    }

    // Predictive interpolation for smooth remote visualization
    func interpolateRemoteStroke(_ stroke: Stroke3D, deltaTime: TimeInterval) -> [SIMD3<Float>] {
        // Predict next point based on velocity
        guard stroke.points.count >= 2 else { return stroke.points }

        let lastPoint = stroke.points.last!
        let prevPoint = stroke.points[stroke.points.count - 2]
        let velocity = (lastPoint - prevPoint) / Float(deltaTime)
        let predictedPoint = lastPoint + velocity * Float(deltaTime)

        return stroke.points + [predictedPoint]
    }

    // Conflict resolution for simultaneous edits
    func resolveConflict(local: GameState, remote: GameState) -> GameState {
        // Artist's device is authoritative for drawing
        // Host is authoritative for game state
        var resolved = local

        if remote.currentArtist?.isLocal == true {
            resolved.drawings = remote.drawings // Trust artist's drawing
        }

        if !local.isHost {
            resolved.currentPhase = remote.currentPhase // Trust host's state
            resolved.timeRemaining = remote.timeRemaining
        }

        return resolved
    }
}
```

### SharePlay Integration

```swift
class SharePlayManager: ObservableObject {
    private var groupSession: GroupSession<GameActivity>?
    private var messenger: GroupSessionMessenger?

    // Start SharePlay session
    func startSession() async throws {
        let activity = GameActivity()

        switch await activity.prepareForActivation() {
        case .activationPreferred:
            do {
                self.groupSession = try await activity.activate()
                await configureSession()
            } catch {
                throw MultiplayerError.sessionActivationFailed
            }
        case .activationDisabled, .cancelled:
            throw MultiplayerError.sessionCancelled
        default:
            break
        }
    }

    // Configure group session
    private func configureSession() async {
        guard let session = groupSession else { return }

        messenger = GroupSessionMessenger(session: session)

        // Handle new participants
        for await newParticipants in session.$activeParticipants.values {
            handleNewParticipants(newParticipants)
        }

        // Handle messages
        for await (message, sender) in messenger!.messages(of: NetworkMessage.self) {
            handleNetworkMessage(message, from: sender)
        }
    }

    // Send message to all participants
    func broadcast(_ message: NetworkMessage) async throws {
        try await messenger?.send(message)
    }
}
```

---

## 7. Physics & Collision Systems

### Physics Architecture (Minimal)

```swift
// Spatial Pictionary has minimal physics needs
// Main use: Prevent drawing outside canvas bounds

class PhysicsManager {
    // Canvas boundary collision
    func checkCanvasBounds(point: SIMD3<Float>, canvasSize: Float) -> SIMD3<Float> {
        let halfSize = canvasSize / 2.0

        return SIMD3<Float>(
            x: max(-halfSize, min(halfSize, point.x)),
            y: max(-halfSize, min(halfSize, point.y)),
            z: max(-halfSize, min(halfSize, point.z))
        )
    }

    // Smooth drawing with velocity damping
    func smoothPoint(current: SIMD3<Float>,
                    previous: SIMD3<Float>,
                    maxVelocity: Float) -> SIMD3<Float> {
        let delta = current - previous
        let distance = length(delta)

        if distance > maxVelocity {
            let direction = normalize(delta)
            return previous + direction * maxVelocity
        }

        return current
    }
}
```

---

## 8. Audio Architecture

### Spatial Audio System

```swift
class SpatialAudioManager {
    private var audioEngine: AVAudioEngine
    private var environmentNode: AVAudioEnvironmentNode

    // 3D positioned audio for drawing
    func playDrawingSound(at position: SIMD3<Float>, material: MaterialType) {
        let sound = loadSound(for: material)
        let audioNode = AVAudioPlayerNode()

        // Position in 3D space
        audioNode.position = AVAudio3DPoint(
            x: position.x,
            y: position.y,
            z: position.z
        )

        audioEngine.attach(audioNode)
        audioEngine.connect(audioNode, to: environmentNode, format: sound.format)
        audioNode.scheduleBuffer(sound, completionHandler: nil)
        audioNode.play()
    }

    // Ambient room audio
    func setupAmbientAudio() {
        environmentNode.reverbBlend = 0.3
        environmentNode.renderingAlgorithm = .HRTF
    }

    // Celebration sounds
    func playCelebration(for event: CelebrationEvent) {
        let sound = getCelebrationSound(event)
        playSound(sound, at: centralPosition, volume: 1.0)
    }
}
```

---

## 9. Performance Optimization

### Frame Rate Optimization (90 FPS Target)

```swift
class PerformanceManager {
    private let targetFrameTime: TimeInterval = 1.0 / 90.0 // ~11.1ms

    // Level of Detail for drawing strokes
    func optimizeStrokeLOD(strokes: [Entity], cameraPosition: SIMD3<Float>) {
        for stroke in strokes {
            let distance = length(stroke.position - cameraPosition)

            if distance > 3.0 {
                // Far: Low poly mesh
                stroke.components[LODComponent.self]?.level = .low
            } else if distance > 1.5 {
                // Medium: Medium poly mesh
                stroke.components[LODComponent.self]?.level = .medium
            } else {
                // Close: Full quality
                stroke.components[LODComponent.self]?.level = .high
            }
        }
    }

    // Mesh pooling for strokes
    private var strokePool: [MeshResource] = []

    func getPooledStrokeMesh() -> MeshResource {
        return strokePool.popLast() ?? createNewStrokeMesh()
    }

    func returnToPool(_ mesh: MeshResource) {
        if strokePool.count < 100 {
            strokePool.append(mesh)
        }
    }

    // Frame budget monitoring
    func monitorFrameBudget() {
        let frameTime = getCurrentFrameTime()

        if frameTime > targetFrameTime * 1.2 {
            // Exceeding budget by 20%
            reduceQuality()
        }
    }
}
```

### Memory Management

```swift
class MemoryManager {
    // Efficient stroke storage
    func compressStroke(_ stroke: Stroke3D) -> Data {
        // Use simplified point representation
        let compressed = stroke.points.map { point in
            // Convert Float to Int16 for 75% size reduction
            return SIMD3<Int16>(
                Int16(point.x * 1000),
                Int16(point.y * 1000),
                Int16(point.z * 1000)
            )
        }

        return try! JSONEncoder().encode(compressed)
    }

    // Cleanup old drawings
    func cleanupOldDrawings(keep mostRecent: Int) {
        // Keep only the most recent N drawings in full quality
        // Older drawings stored in compressed format
    }
}
```

---

## 10. Save/Load System

### Persistent Storage Architecture

```swift
class SaveManager {
    private let fileManager = FileManager.default
    private var saveURL: URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("SpatialPictionary")
    }

    // Save game session
    func saveSession(_ session: GameSession) async throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted

        let data = try encoder.encode(session)
        try data.write(to: saveURL.appendingPathComponent("\(session.id.uuidString).json"))
    }

    // Load game session
    func loadSession(id: UUID) async throws -> GameSession {
        let url = saveURL.appendingPathComponent("\(id.uuidString).json")
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        return try decoder.decode(GameSession.self, from: data)
    }

    // Save 3D drawing mesh
    func saveDrawingMesh(_ drawing: Drawing3D) async throws {
        // Convert strokes to efficient mesh format
        let meshData = try MeshExporter.exportToUSD(drawing)
        let url = saveURL.appendingPathComponent("drawings/\(drawing.id.uuidString).usdz")
        try meshData.write(to: url)
    }

    // iCloud sync
    func enableCloudSync() {
        // Use NSUbiquitousKeyValueStore for settings
        // Use CloudKit for drawing gallery
    }
}
```

---

## Architecture Decision Records (ADRs)

### ADR-001: Why RealityKit over SceneKit?
- **Decision**: Use RealityKit as primary 3D engine
- **Rationale**: Better visionOS integration, hand tracking support, modern API
- **Tradeoffs**: Less mature than SceneKit, smaller community

### ADR-002: Why Volume mode as default?
- **Decision**: Use Volume spatial mode as primary experience
- **Rationale**: Balance between immersion and comfort, social visibility
- **Tradeoffs**: Less immersive than full space, more than windowed

### ADR-003: Why SharePlay for remote multiplayer?
- **Decision**: Use SharePlay instead of custom networking
- **Rationale**: Built-in participant management, seamless integration, low latency
- **Tradeoffs**: Limited to Apple ecosystem, less control over networking

### ADR-004: Why local mesh generation over procedural?
- **Decision**: Generate stroke meshes locally instead of using procedural geometry
- **Rationale**: Better performance, more control over appearance
- **Tradeoffs**: More memory usage, complex mesh generation code

---

## Performance Targets Summary

| Metric | Target | Critical Threshold |
|--------|--------|-------------------|
| Frame Rate | 90 FPS | Never below 72 FPS |
| Hand Tracking Latency | <16ms | <20ms |
| Drawing Point Precision | ±2mm | ±5mm |
| Network Sync Latency | <50ms | <100ms |
| Memory Usage | <500MB | <750MB |
| Session Load Time | <2s | <5s |

---

## Conclusion

This architecture provides a robust foundation for Spatial Pictionary, balancing performance, user comfort, and engaging gameplay. The modular design allows for iterative development while maintaining code quality and system performance.

**Next Steps:**
1. Review and validate architecture with team
2. Create detailed technical specifications
3. Begin prototype development of core systems
4. Performance testing and optimization

*Document Version: 1.0 | Last Updated: 2025-11-19*
