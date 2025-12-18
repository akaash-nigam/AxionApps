# Narrative Story Worlds - Technical Architecture

## Table of Contents

1. [System Overview](#system-overview)
2. [Game Architecture](#game-architecture)
3. [visionOS Spatial Architecture](#visionos-spatial-architecture)
4. [AI Systems Architecture](#ai-systems-architecture)
5. [Data Models & Schemas](#data-models--schemas)
6. [RealityKit Components & Systems](#realitykit-components--systems)
7. [State Management](#state-management)
8. [Persistence & Save System](#persistence--save-system)
9. [Audio Architecture](#audio-architecture)
10. [Performance Architecture](#performance-architecture)

---

## 1. System Overview

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        Player Space                          │
│  ┌──────────────────────────────────────────────────────┐   │
│  │              SwiftUI Application Layer                │   │
│  │  ├── App Coordinator                                  │   │
│  │  ├── Scene Management                                 │   │
│  │  └── UI/Menu Systems                                  │   │
│  └──────────────────────────────────────────────────────┘   │
│                           ▼                                  │
│  ┌──────────────────────────────────────────────────────┐   │
│  │            Game Logic & State Layer                   │   │
│  │  ├── Story Director (AI-driven)                       │   │
│  │  ├── Game State Machine                               │   │
│  │  ├── Choice System                                    │   │
│  │  └── Event Bus                                        │   │
│  └──────────────────────────────────────────────────────┘   │
│                           ▼                                  │
│  ┌──────────────────────────────────────────────────────┐   │
│  │           AI Systems Layer                            │   │
│  │  ├── Character AI Engine                              │   │
│  │  ├── Dialogue Generator                               │   │
│  │  ├── Emotion Recognition                              │   │
│  │  └── Environmental Storytelling AI                    │   │
│  └──────────────────────────────────────────────────────┘   │
│                           ▼                                  │
│  ┌──────────────────────────────────────────────────────┐   │
│  │         Spatial Computing Layer                       │   │
│  │  ├── Room Analysis & Mapping (ARKit)                  │   │
│  │  ├── Spatial Anchors & Persistence                    │   │
│  │  ├── Character Navigation                             │   │
│  │  └── Environmental Transformation                     │   │
│  └──────────────────────────────────────────────────────┘   │
│                           ▼                                  │
│  ┌──────────────────────────────────────────────────────┐   │
│  │          RealityKit Rendering Layer                   │   │
│  │  ├── Character Entities (ECS)                         │   │
│  │  ├── Story Object Entities                            │   │
│  │  ├── Environmental Effects                            │   │
│  │  └── Animation System                                 │   │
│  └──────────────────────────────────────────────────────┘   │
│                           ▼                                  │
│  ┌──────────────────────────────────────────────────────┐   │
│  │         Audio & Haptics Layer                         │   │
│  │  ├── Spatial Audio Engine (AVFoundation)              │   │
│  │  ├── Dialogue Audio System                            │   │
│  │  ├── Ambient Sound                                    │   │
│  │  └── Haptic Feedback                                  │   │
│  └──────────────────────────────────────────────────────┘   │
│                           ▼                                  │
│  ┌──────────────────────────────────────────────────────┐   │
│  │         Data Persistence Layer                        │   │
│  │  ├── Local Story State (CoreData)                     │   │
│  │  ├── Character Memory                                 │   │
│  │  ├── Spatial Anchors Database                         │   │
│  │  └── iCloud Sync (CloudKit)                           │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

### Technology Stack

- **Language**: Swift 6.0+ with concurrency features
- **UI Framework**: SwiftUI for menus and HUD
- **3D Rendering**: RealityKit 4.0 for character and environment rendering
- **Spatial Computing**: ARKit 6.0 for room mapping and tracking
- **Platform**: visionOS 2.0+
- **AI/ML**: Core ML for on-device AI processing
- **Audio**: AVFoundation with Spatial Audio
- **Persistence**: CoreData + CloudKit
- **Networking**: Swift Concurrency for async operations

---

## 2. Game Architecture

### Game Loop

```swift
class GameLoop {
    // Target: 90 FPS for smooth experience
    private let targetFrameRate: TimeInterval = 1.0 / 90.0

    func update(deltaTime: TimeInterval) {
        // 1. Input Processing (1ms budget)
        inputSystem.process()

        // 2. AI Update (5ms budget)
        storyDirector.update(deltaTime)
        characterAI.update(deltaTime)

        // 3. Game State Update (2ms budget)
        stateManager.update(deltaTime)

        // 4. Physics & Collision (2ms budget)
        physicsSystem.update(deltaTime)

        // 5. Animation Update (1ms budget)
        animationSystem.update(deltaTime)

        // 6. Audio Update (1ms budget)
        audioSystem.update(deltaTime)

        // Total: ~12ms = comfortable 90 FPS margin
    }
}
```

### Entity-Component-System (ECS)

```
Entities:
├── CharacterEntity
│   ├── Transform Component
│   ├── Animation Component
│   ├── AI Brain Component
│   ├── Dialogue Component
│   ├── Emotion State Component
│   └── Spatial Navigation Component
│
├── StoryObjectEntity
│   ├── Transform Component
│   ├── Interaction Component
│   ├── Story Data Component
│   └── Visual State Component
│
└── EnvironmentalEntity
    ├── Transform Component
    ├── Room Anchor Component
    ├── Lighting Component
    └── Ambient Audio Component

Systems:
├── CharacterAISystem (updates character behavior)
├── DialogueSystem (manages conversations)
├── NavigationSystem (character pathfinding)
├── InteractionSystem (player-object interactions)
├── EmotionSystem (character emotional states)
└── PersistenceSystem (save/load entity states)
```

### Scene Graph

```
StoryWorld (Root)
├── RoomSpace
│   ├── FloorPlane (detected surface)
│   ├── Furniture Anchors (detected objects)
│   └── Wall Surfaces (detected boundaries)
│
├── CharacterLayer
│   ├── Primary Character (main NPC)
│   ├── Secondary Characters (supporting NPCs)
│   └── Background Characters
│
├── StoryElementLayer
│   ├── Interactive Objects (clues, items)
│   ├── Environmental Props (set dressing)
│   └── Effect Emitters (particles, lighting)
│
└── UILayer
    ├── Choice Interface (floating options)
    ├── HUD Elements (minimal)
    └── Contextual Prompts
```

---

## 3. visionOS Spatial Architecture

### Spatial Modes

```swift
enum SpatialMode {
    case window          // Menu navigation, settings
    case volume         // Character close-ups, object examination
    case immersiveSpace // Full story experience
}

// Mode transitions
MenuScene → Window Mode
StoryStart → Immersive Space (Bounded)
FullImmersion → Immersive Space (Unbounded)
```

### Room Mapping & Analysis

```swift
class RoomAnalyzer {
    // ARKit WorldTrackingProvider
    var worldTracking: WorldTrackingProvider

    // Detected room features
    struct RoomFeatures {
        var floorPlane: Plane
        var walls: [Plane]
        var furniture: [DetectedObject]
        var safeZones: [BoundingBox]
        var lightingSources: [LightAnchor]
    }

    func analyzeRoom() async -> RoomFeatures {
        // 1. Scan physical environment
        // 2. Identify surfaces (floor, walls, furniture)
        // 3. Create navigation mesh for characters
        // 4. Identify story anchor points
        // 5. Calculate safe zones for player movement
    }
}
```

### Spatial Persistence

```swift
// Story elements persist across sessions
class SpatialPersistenceManager {
    // WorldAnchor for each story element
    struct StoryAnchor {
        let id: UUID
        let worldAnchor: WorldAnchor
        let storyElementID: String
        let narrativeState: NarrativeState
    }

    // Save anchor positions
    func saveAnchors(_ anchors: [StoryAnchor]) async throws {
        // Use WorldAnchors for persistence
        // Characters remember where they stood
        // Objects stay where placed
        // Room transformations persist
    }

    // Restore on app launch
    func restoreAnchors() async throws -> [StoryAnchor] {
        // Reload previous session state
        // Characters reappear in saved positions
        // Story continues from last point
    }
}
```

### Character Spatial Behavior

```swift
class CharacterSpatialManager {
    // Character positioning rules
    enum PositioningRule {
        case intimate(distance: 0.8...1.2)     // Deep conversations
        case social(distance: 1.5...3.0)       // Normal interactions
        case dramatic(distance: 3.0...5.0)     // Revelations, conflicts
    }

    // Natural furniture usage
    func findSeatingPosition(character: Character,
                           furniture: [DetectedObject]) -> Transform {
        // Characters naturally sit on couches, lean on walls
        // Use room context for believable behavior
    }

    // Navigation mesh for character movement
    func generateNavigationMesh(room: RoomFeatures) -> NavigationMesh {
        // Characters walk around obstacles
        // Use doorways naturally
        // Respect physical boundaries
    }
}
```

---

## 4. AI Systems Architecture

### Story Director AI

```swift
class StoryDirectorAI {
    // Manages overall narrative flow
    struct StoryState {
        var currentChapter: Chapter
        var activeBranches: [StoryBranch]
        var playerRelationships: [Character: RelationshipLevel]
        var storyFlags: Set<StoryFlag>
        var emotionalTension: Float // 0.0 to 1.0
    }

    // Pacing engine
    func adjustPacing(playerEngagement: Float) -> PacingDecision {
        // Speed up if player disengaged
        // Slow down for important moments
        // Insert breaks for comfort
    }

    // Branch selection
    func selectNextBranch(playerHistory: [Choice]) -> StoryBranch {
        // AI analyzes player preferences
        // Themes that resonated
        // Character relationships
        // Emotional responses
    }

    // Climax orchestration
    func buildTension(currentTension: Float,
                     target: Float,
                     deltaTime: TimeInterval) -> [NarrativeEvent] {
        // Gradually increase stakes
        // Layer complications
        // Time dramatic peaks
    }
}
```

### Character AI Engine

```swift
class CharacterAI {
    // Personality model (Big Five + story traits)
    struct Personality {
        var openness: Float
        var conscientiousness: Float
        var extraversion: Float
        var agreeableness: Float
        var neuroticism: Float

        // Story-specific traits
        var loyalty: Float
        var deception: Float
        var vulnerability: Float
    }

    // Emotional state tracking
    struct EmotionalState {
        var trustInPlayer: Float
        var currentEmotion: Emotion
        var emotionalHistory: [EmotionalEvent]
        var stress: Float
        var attraction: Float
        var fear: Float
    }

    // Memory system
    struct CharacterMemory {
        var conversationHistory: [DialogueLine]
        var playerChoices: [Choice]
        var sharedExperiences: [StoryEvent]
        var emotionalMoments: [EmotionalPeak]
    }

    // Behavior generation
    func generateBehavior(context: StoryContext) -> CharacterAction {
        // Combine personality + emotional state + memory
        // Generate contextual reactions
        // Maintain character consistency
    }
}
```

### Dialogue Generation System

```swift
class DialogueGenerator {
    // Uses Core ML for on-device generation
    private let languageModel: MLModel

    struct DialogueContext {
        var characterState: EmotionalState
        var relationshipLevel: Float
        var recentEvents: [StoryEvent]
        var conversationTone: Tone
        var narrativePhase: StoryPhase
    }

    func generateDialogue(context: DialogueContext,
                         prompt: String) async -> DialogueLine {
        // Context-aware generation
        // Maintain character voice
        // Emotional tone matching
        // Subtext layering
    }

    // Dialogue variation
    func generateVariations(baseLine: DialogueLine,
                          count: Int) -> [DialogueLine] {
        // Multiple takes for replayability
        // Slight wording differences
        // Same emotional beat, different delivery
    }
}
```

### Emotion Recognition System

```swift
class EmotionRecognitionAI {
    // Face tracking from ARKit
    private var faceTrackingProvider: FaceTrackingProvider

    struct EmotionalSignals {
        var facialExpression: FacialExpression
        var eyeGaze: GazePattern
        var bodyLanguage: PostureState
        var responseTime: TimeInterval
    }

    func analyzePlayerEmotion() async -> Emotion {
        // Read facial expressions
        // Track eye movements (interest, avoidance)
        // Measure response times
        // Infer emotional state
    }

    func adaptStoryToEmotion(detectedEmotion: Emotion) {
        // If player uncomfortable → ease tension
        // If player engaged → maintain intensity
        // If player bored → introduce surprise
    }
}
```

---

## 5. Data Models & Schemas

### Story Data Model

```swift
// Core story structure
struct Story {
    let id: UUID
    let title: String
    let genre: Genre
    let estimatedDuration: TimeInterval

    var chapters: [Chapter]
    var characters: [Character]
    var branches: [StoryBranch]
    var achievements: [Achievement]
}

struct Chapter {
    let id: UUID
    let title: String
    let scenes: [Scene]
    var completionState: CompletionState
}

struct Scene {
    let id: UUID
    let location: SceneLocation
    let characters: [CharacterID]
    let storyBeats: [StoryBeat]
    let requiredFlags: Set<StoryFlag>
    var spatialConfiguration: SpatialSetup
}

struct StoryBeat {
    let id: UUID
    let type: BeatType // dialogue, choice, event, revelation
    let content: BeatContent
    let emotionalWeight: Float
    let pacing: PacingHint
}
```

### Character Data Model

```swift
struct Character {
    let id: UUID
    let name: String
    let bio: String

    // Visual representation
    var appearance: CharacterAppearance
    var animationSet: AnimationSetID

    // AI personality
    var personality: Personality
    var emotionalState: EmotionalState
    var memory: CharacterMemory

    // Story role
    var narrativeRole: NarrativeRole
    var relationshipWithPlayer: Relationship
    var storyFlags: Set<CharacterFlag>
}

struct CharacterAppearance {
    var model3D: ModelEntity
    var textures: [String: TextureResource]
    var facialRig: FacialRig
    var clothingLayers: [ClothingLayer]
}
```

### Player Choice Model

```swift
struct Choice {
    let id: UUID
    let prompt: String
    let options: [ChoiceOption]
    var timeLimit: TimeInterval?
    let emotionalContext: EmotionalContext
}

struct ChoiceOption {
    let id: UUID
    let text: String
    let icon: String?

    // Consequences
    let storyBranchID: BranchID
    let relationshipImpacts: [CharacterID: Float]
    let flagsSet: Set<StoryFlag>
    let emotionalTone: Tone

    // UI presentation
    let spatialPosition: ChoicePosition
    let visualStyle: ChoiceStyle
}

// Choice history for AI adaptation
struct ChoiceHistory {
    var choices: [Choice]
    var patterns: ChoicePatterns
    var playerArchetype: PlayerArchetype
}
```

### Spatial Data Model

```swift
struct SpatialConfiguration {
    // Room analysis
    var roomLayout: RoomLayout
    var furnitureAnchors: [FurnitureAnchor]
    var navigationMesh: NavigationMesh

    // Story anchors
    var characterPositions: [CharacterID: WorldAnchor]
    var objectPlacements: [ObjectID: WorldAnchor]
    var effectLocations: [EffectID: WorldAnchor]

    // Transformations
    var lightingState: LightingConfiguration
    var environmentalEffects: [EnvironmentalEffect]
}

struct FurnitureAnchor {
    let id: UUID
    let type: FurnitureType // couch, chair, table, bed
    let worldAnchor: WorldAnchor
    let usablePositions: [UsagePoint] // where characters can sit/stand
    var storySignificance: StoryRelevance?
}
```

---

## 6. RealityKit Components & Systems

### Custom Components

```swift
// Character brain component
struct CharacterBrainComponent: Component {
    var personality: Personality
    var emotionalState: EmotionalState
    var currentGoal: CharacterGoal
    var dialogueState: DialogueState
}

// Story object component
struct StoryObjectComponent: Component {
    let storyID: String
    var narrativeSignificance: Float
    var interactionType: InteractionType
    var discoveryState: DiscoveryState
}

// Spatial navigation component
struct SpatialNavigationComponent: Component {
    var targetPosition: SIMD3<Float>?
    var navigationPath: [SIMD3<Float>]
    var movementSpeed: Float
    var avoidanceRadius: Float
}

// Emotion display component
struct EmotionDisplayComponent: Component {
    var currentEmotion: Emotion
    var facialExpression: FacialExpression
    var bodyLanguage: BodyLanguage
    var transitionDuration: TimeInterval
}
```

### Custom Systems

```swift
// Character AI system
class CharacterAISystem: System {
    static let query = EntityQuery(
        where: .has(CharacterBrainComponent.self)
    )

    func update(context: SceneUpdateContext) {
        for entity in context.entities(matching: Self.query) {
            guard var brain = entity.components[CharacterBrainComponent.self] else { continue }

            // Update AI state
            updateEmotionalState(&brain, deltaTime: context.deltaTime)
            updateGoals(&brain)
            generateBehavior(entity, brain: brain)

            entity.components[CharacterBrainComponent.self] = brain
        }
    }
}

// Spatial navigation system
class SpatialNavigationSystem: System {
    static let query = EntityQuery(
        where: .has(SpatialNavigationComponent.self)
    )

    func update(context: SceneUpdateContext) {
        for entity in context.entities(matching: Self.query) {
            guard var nav = entity.components[SpatialNavigationComponent.self] else { continue }

            // Navigate character through space
            if let path = nav.navigationPath, !path.isEmpty {
                moveAlongPath(entity, nav: &nav, deltaTime: context.deltaTime)
                avoidObstacles(entity, nav: &nav)
            }

            entity.components[SpatialNavigationComponent.self] = nav
        }
    }
}
```

---

## 7. State Management

### Game State Machine

```swift
enum GameState {
    case initializing
    case menuNavigation
    case roomCalibration
    case storyPlaying(chapter: Chapter, scene: Scene)
    case choicePresentation(choice: Choice)
    case characterInteraction(character: Character)
    case paused
    case loading(progress: Float)
}

class GameStateManager: ObservableObject {
    @Published var currentState: GameState = .initializing
    @Published var storyState: StoryState

    private var stateHistory: [GameState] = []

    func transition(to newState: GameState) {
        // Validate transition
        guard isValidTransition(from: currentState, to: newState) else {
            return
        }

        // Execute exit actions
        exitState(currentState)

        // Update state
        stateHistory.append(currentState)
        currentState = newState

        // Execute entry actions
        enterState(newState)
    }

    func isValidTransition(from: GameState, to: GameState) -> Bool {
        // Define valid state transitions
        // Prevent invalid state changes
    }
}
```

### Story State Tracking

```swift
struct StoryState: Codable {
    // Current position
    var currentStoryID: UUID
    var currentChapterID: UUID
    var currentSceneID: UUID

    // Progress tracking
    var completedScenes: Set<UUID>
    var activeFlags: Set<StoryFlag>
    var choiceHistory: [Choice]

    // Character relationships
    var characterRelationships: [UUID: Relationship]
    var characterMemories: [UUID: CharacterMemory]

    // Spatial state
    var spatialAnchors: [UUID: AnchorData]
    var roomConfiguration: RoomLayout

    // Metadata
    var playTime: TimeInterval
    var lastSaveDate: Date
    var version: String
}
```

---

## 8. Persistence & Save System

### Save System Architecture

```swift
class SaveSystem {
    private let persistenceController: PersistenceController
    private let cloudSync: CloudSyncManager

    // Auto-save at story beats
    func autoSave(state: StoryState) async throws {
        // 1. Serialize current state
        let data = try JSONEncoder().encode(state)

        // 2. Save to local CoreData
        try await persistenceController.saveLocal(data)

        // 3. Sync to iCloud if enabled
        if UserDefaults.standard.bool(forKey: "iCloudSyncEnabled") {
            try await cloudSync.upload(data)
        }
    }

    // Manual save slots
    func saveToSlot(_ slot: Int, state: StoryState) async throws {
        // Multiple save slots for experimentation
    }

    // Load saved state
    func loadState(from slot: Int) async throws -> StoryState {
        // 1. Load from local
        var state = try await persistenceController.loadLocal(slot: slot)

        // 2. Merge with cloud if newer
        if let cloudState = try await cloudSync.downloadLatest() {
            state = merge(local: state, cloud: cloudState)
        }

        return state
    }
}
```

### Spatial Anchor Persistence

```swift
class SpatialAnchorManager {
    // Persist character positions across sessions
    func saveCharacterPosition(characterID: UUID,
                              anchor: WorldAnchor) async throws {
        // Save anchor to WorldAnchorStorage
        // Characters reappear exactly where they were
    }

    // Restore spatial layout
    func restoreScene(sceneID: UUID) async throws -> SpatialConfiguration {
        // Reload all anchors for a scene
        // Characters, objects, effects in correct positions
    }
}
```

---

## 9. Audio Architecture

### Spatial Audio System

```swift
class SpatialAudioEngine {
    private let audioEngine: AVAudioEngine
    private let environment: AVAudioEnvironmentNode

    // Character voice positioning
    func playCharacterDialogue(character: Character,
                              audioClip: AVAudioFile,
                              position: SIMD3<Float>) {
        // 3D positioned dialogue
        // Sounds like character is really there
        // Adjusts with character movement
    }

    // Environmental ambience
    func setAmbientSound(scene: Scene) {
        // Subtle room tone
        // Atmospheric music
        // Environmental sounds (rain, wind, etc.)
    }

    // Emotional audio cues
    func playEmotionalCue(emotion: Emotion, intensity: Float) {
        // Heartbeat for tension
        // Musical swells for drama
        // Subtle cues for mood
    }
}
```

### Haptic Feedback System

```swift
class HapticFeedbackManager {
    // Emotional haptics
    func playEmotionalHaptic(emotion: Emotion, intensity: Float) {
        // Rapid pulse for anxiety
        // Steady beat for calm
        // Sharp tap for surprise
    }

    // Interaction feedback
    func playInteractionHaptic(type: InteractionType) {
        // Touch confirmation
        // Object weight simulation
        // Choice selection feedback
    }
}
```

---

## 10. Performance Architecture

### Performance Budgets

```
Frame Budget (90 FPS = 11ms per frame):
├── Input Processing: 1ms
├── AI Update: 5ms
│   ├── Story Director: 2ms
│   ├── Character AI: 2ms
│   └── Emotion Recognition: 1ms
├── Game Logic: 2ms
├── Physics: 1ms
├── Animation: 1ms
└── Audio: 1ms
Total: ~11ms (comfortable margin)

Memory Budget:
├── 3D Character Models: 500MB
├── Textures (foveated): 300MB
├── Audio Assets: 200MB
├── AI Models (Core ML): 150MB
├── Story Data: 100MB
└── Runtime: 250MB
Total: ~1.5GB
```

### Optimization Strategies

```swift
class PerformanceOptimizer {
    // Level of Detail for characters
    func adjustLOD(character: Entity, distanceFromPlayer: Float) {
        if distanceFromPlayer > 3.0 {
            character.useLowPolyModel()
        } else {
            character.useHighPolyModel()
        }
    }

    // Foveated rendering for textures
    func applyFoveatedRendering() {
        // High-res where player is looking
        // Lower-res in periphery
    }

    // Predictive loading
    func preloadUpcomingScene(nextScene: Scene) async {
        // Load assets before scene transition
        // Seamless transitions
    }

    // Asset streaming
    func streamLargeAssets(asset: AssetID) async {
        // Load in background
        // Progressive quality increase
    }
}
```

### Thermal Management

```swift
class ThermalManager {
    func adjustQualityForThermalState(_ state: ProcessInfo.ThermalState) {
        switch state {
        case .nominal:
            setQualityLevel(.high)
        case .fair:
            setQualityLevel(.medium)
        case .serious:
            setQualityLevel(.low)
            reduceAIUpdates()
        case .critical:
            setQualityLevel(.minimal)
            pauseNonEssentialSystems()
        @unknown default:
            break
        }
    }
}
```

---

## Architectural Principles

### 1. Spatial-First Design
- Everything designed for 3D space
- Characters exist as spatial entities
- UI integrated into story world
- Room layout drives narrative

### 2. AI-Driven Experience
- Story adapts to player in real-time
- Characters have genuine personalities
- Dialogue feels natural and contextual
- Emotional intelligence throughout

### 3. Performance-Conscious
- 90 FPS minimum maintained
- Thermal management proactive
- Asset streaming intelligent
- Memory usage optimized

### 4. Persistence-Aware
- World state preserved across sessions
- Characters remember everything
- Spatial anchors maintain positions
- Cloud sync for continuity

### 5. Comfort-Focused
- No motion sickness triggers
- Seated play fully supported
- Pacing respects player comfort
- Intensity adjustable

---

## Technology Decision Rationale

### Why RealityKit over Unity/Unreal?
- Native visionOS integration
- Optimal performance on Apple Silicon
- Seamless ARKit integration
- SwiftUI compatibility
- First-class spatial persistence

### Why On-Device AI?
- Privacy preservation (no dialogue uploaded)
- Zero latency for real-time responses
- Works offline
- No server costs
- Apple Neural Engine optimization

### Why CoreData + CloudKit?
- Native iCloud integration
- Conflict resolution built-in
- Offline-first architecture
- Privacy-focused
- Free tier for users

---

**This architecture enables a groundbreaking narrative experience that feels like living inside a story, with AI characters that remember and react naturally, all running smoothly on Vision Pro hardware.**
