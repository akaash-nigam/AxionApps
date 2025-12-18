# Interactive Theater - Technical Architecture

## Document Overview
This document outlines the comprehensive technical architecture for Interactive Theater, a visionOS application that transforms living spaces into immersive theatrical performances with AI-driven holographic actors.

**Version:** 1.0
**Last Updated:** 2025-01-20
**Target Platform:** Apple Vision Pro (visionOS 2.0+)

---

## Table of Contents
1. [System Overview](#system-overview)
2. [Game Architecture](#game-architecture)
3. [visionOS-Specific Gaming Patterns](#visionos-specific-gaming-patterns)
4. [Game Data Models & Schemas](#game-data-models--schemas)
5. [RealityKit Gaming Components & Systems](#realitykit-gaming-components--systems)
6. [ARKit Integration](#arkit-integration)
7. [AI Architecture](#ai-architecture)
8. [Physics & Collision Systems](#physics--collision-systems)
9. [Audio Architecture](#audio-architecture)
10. [Performance Optimization](#performance-optimization)
11. [Save/Load System Architecture](#saveload-system-architecture)
12. [Network Architecture](#network-architecture)
13. [Security & Privacy](#security--privacy)

---

## System Overview

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        Application Layer                          │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │  SwiftUI     │  │  RealityKit  │  │  ARKit       │          │
│  │  Interface   │  │  Renderer    │  │  Tracking    │          │
│  └──────────────┘  └──────────────┘  └──────────────┘          │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                        Game Core Layer                            │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │  Game Loop   │  │  State Mgmt  │  │  Event Bus   │          │
│  └──────────────┘  └──────────────┘  └──────────────┘          │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                        Systems Layer                              │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐        │
│  │   AI     │  │ Narrative│  │ Spatial  │  │  Audio   │        │
│  │  Engine  │  │  Engine  │  │  Engine  │  │  Engine  │        │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘        │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                        Entity-Component System                    │
│  ┌──────────────────────────────────────────────────┐            │
│  │  Characters │  Props │  Environment │  Effects   │            │
│  └──────────────────────────────────────────────────┘            │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                        Data & Services Layer                      │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐        │
│  │ Content  │  │  Cloud   │  │  Local   │  │Analytics │        │
│  │  Store   │  │ Services │  │ Storage  │  │ Service  │        │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘        │
└─────────────────────────────────────────────────────────────────┘
```

### Core Technology Stack
- **Language:** Swift 6.0+ (strict concurrency, modern patterns)
- **UI Framework:** SwiftUI for 2D interfaces and menus
- **3D Rendering:** RealityKit for spatial content and characters
- **Spatial Tracking:** ARKit for room mapping and user positioning
- **Platform:** visionOS 2.0+ with gaming-optimized APIs
- **AI/ML:** CoreML for on-device character AI, cloud services for complex reasoning
- **Audio:** AVFoundation with Spatial Audio APIs
- **Networking:** MultipeerConnectivity, SharePlay for multiplayer
- **Storage:** SwiftData for structured data, FileManager for assets

---

## Game Architecture

### Game Loop Architecture

The game loop runs at 90 FPS (target) to maintain smooth character animation and responsive interactions.

```swift
// Conceptual Game Loop Structure
class GameLoop {
    // Fixed timestep for physics (60 Hz)
    let fixedDeltaTime: TimeInterval = 1.0 / 60.0

    // Variable timestep for rendering (90 Hz target)
    var lastUpdateTime: TimeInterval = 0
    var accumulator: TimeInterval = 0

    func update(currentTime: TimeInterval) {
        let deltaTime = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        accumulator += deltaTime

        // Fixed timestep physics updates
        while accumulator >= fixedDeltaTime {
            updatePhysics(fixedDeltaTime)
            updateAI(fixedDeltaTime)
            updateNarrative(fixedDeltaTime)
            accumulator -= fixedDeltaTime
        }

        // Variable timestep rendering
        updateAnimation(deltaTime)
        updateAudio(deltaTime)
        updateSpatialInteractions(deltaTime)
        render(accumulator / fixedDeltaTime) // interpolation factor
    }
}
```

### State Management System

Centralized state management using observation and reactive patterns:

```swift
// State Management Architecture
@Observable
class GameStateManager {
    // Performance states
    enum PerformanceState {
        case initialization
        case characterIntroduction
        case activePerformance
        case decisionPoint
        case sceneTransition
        case performanceComplete
        case paused
    }

    var currentState: PerformanceState = .initialization
    var currentScene: TheaterScene?
    var activeCharacters: [CharacterEntity] = []
    var narrativeState: NarrativeState
    var playerChoices: [NarrativeChoice] = []
    var performanceProgress: PerformanceProgress

    // State transition handling
    func transitionTo(_ newState: PerformanceState) {
        // Validate transition
        // Execute exit handlers for current state
        // Execute entry handlers for new state
        // Update UI and notify observers
    }
}
```

### Scene Graph Architecture

Hierarchical scene management for theatrical performances:

```
RootScene
├── EnvironmentScene (set transformation, lighting, atmosphere)
│   ├── SetElements (furniture integration, props, period decorations)
│   ├── Lighting (theatrical lighting, time-of-day, mood)
│   └── Effects (weather, particles, atmospheric)
├── CharacterScene (AI actors and performers)
│   ├── PrimaryCharacters (story protagonists)
│   ├── SupportingCharacters (secondary roles)
│   └── BackgroundCharacters (atmosphere, crowds)
├── InteractionScene (player interaction points)
│   ├── DialogueNodes (conversation opportunities)
│   ├── PropInteractions (handleable objects)
│   └── ChoicePoints (narrative decision moments)
└── UIScene (spatial UI overlay)
    ├── HUD (subtle performance information)
    ├── SubtitleSystem (accessibility, translation)
    └── MenuOverlay (pause, settings, accessibility)
```

### Event System Architecture

Decoupled event-driven architecture for game systems communication:

```swift
// Event Bus Pattern
protocol GameEvent {
    var timestamp: TimeInterval { get }
    var priority: EventPriority { get }
}

enum EventPriority {
    case critical  // Immediate processing (user safety, crashes)
    case high      // Frame-critical (input, AI decisions)
    case normal    // Standard game events
    case low       // Analytics, logging
}

class EventBus {
    private var subscribers: [String: [(GameEvent) -> Void]] = [:]
    private var eventQueue: PriorityQueue<GameEvent> = []

    func subscribe<T: GameEvent>(_ eventType: T.Type, handler: @escaping (T) -> Void)
    func publish<T: GameEvent>(_ event: T)
    func processEvents() // Called each frame
}

// Example Events
struct CharacterSpeechEvent: GameEvent { /* ... */ }
struct PlayerChoiceEvent: GameEvent { /* ... */ }
struct SceneTransitionEvent: GameEvent { /* ... */ }
struct NarrativeBranchEvent: GameEvent { /* ... */ }
```

---

## visionOS-Specific Gaming Patterns

### Spatial Computing Modes

Interactive Theater uses **Full Immersive Space** mode for optimal theatrical experience:

```swift
// App Structure
@main
struct InteractiveTheaterApp: App {
    @State private var immersionStyle: ImmersionStyle = .full

    var body: some Scene {
        WindowGroup {
            MainMenuView()
        }

        ImmersiveSpace(id: "theater") {
            TheaterPerformanceView()
        }
        .immersionStyle(selection: $immersionStyle, in: .full)
    }
}
```

### Window Management
- **Main Menu Window:** 2D SwiftUI window for browsing performances
- **Settings Window:** Separate window for preferences and accessibility
- **Immersive Theater Space:** Full immersion for performances

### Volume Integration
Characters and props use volumetric space with real-world integration:

```swift
// Volumetric Character Representation
struct CharacterVolume {
    let entity: ModelEntity
    let aiController: CharacterAI
    let spatialBounds: BoundingBox

    // Real-world integration
    func integrateWithRoom(_ roomLayout: RoomLayout) {
        // Position character relative to furniture
        // Adjust scale for room size
        // Configure collision boundaries
    }
}
```

### Hand Tracking Integration

Natural hand gestures for character interaction:

```swift
// Hand Tracking for Interactions
class HandInteractionSystem {
    func processHandInput(_ handAnchor: HandAnchor) {
        // Detect gestures: pointing, grasping, waving
        // Character attention based on pointing
        // Object interaction via pinch gestures
        // Emotional gestures (comforting, dismissing)
    }
}
```

### Eye Tracking Integration

Gaze-based character attention and dialogue selection:

```swift
// Eye Tracking System
class EyeTrackingSystem {
    func processGaze(_ gazeDirection: SIMD3<Float>) {
        // Determine character being looked at
        // Trigger character awareness and response
        // Gaze-based dialogue option highlighting
        // Attention metrics for engagement tracking
    }
}
```

---

## Game Data Models & Schemas

### Character Data Model

```swift
struct CharacterModel: Codable, Identifiable {
    let id: UUID
    let name: String
    let role: CharacterRole

    // AI Personality
    let personality: PersonalityTraits
    let emotionalState: EmotionalState
    let relationshipMap: [UUID: Relationship] // Character ID -> Relationship

    // Narrative
    let backstory: String
    let motivations: [String]
    let currentObjectives: [Objective]

    // Appearance
    let visualAssetID: String
    let costumes: [CostumeData]
    let animations: [AnimationData]

    // Performance
    let dialogueTree: DialogueTree
    let voiceProfile: VoiceProfile
    let behaviorPatterns: [BehaviorPattern]
}

struct PersonalityTraits: Codable {
    // Big Five personality model
    let openness: Float       // 0.0 - 1.0
    let conscientiousness: Float
    let extraversion: Float
    let agreeableness: Float
    let neuroticism: Float

    // Custom traits for theatrical characters
    let honor: Float
    let ambition: Float
    let loyalty: Float
    let compassion: Float
}

struct EmotionalState: Codable {
    let primaryEmotion: Emotion
    let emotionIntensity: Float // 0.0 - 1.0
    let emotionTrigger: String?
    let emotionDuration: TimeInterval
}

enum Emotion: String, Codable {
    case joy, sadness, anger, fear, surprise, disgust
    case love, grief, guilt, pride, shame, anxiety
}
```

### Narrative Data Model

```swift
struct PerformanceData: Codable, Identifiable {
    let id: UUID
    let title: String
    let author: String
    let genre: TheaterGenre
    let duration: TimeInterval // Expected duration

    // Content
    let acts: [Act]
    let characters: [CharacterModel]
    let settings: [SettingData]

    // Metadata
    let ageRating: AgeRating
    let culturalContext: CulturalContext
    let educationalObjectives: [LearningObjective]
    let historicalPeriod: HistoricalPeriod?

    // Branching narrative
    let narrativeGraph: NarrativeGraph
    let endings: [EndingData]
}

struct NarrativeGraph: Codable {
    let nodes: [NarrativeNode]
    let edges: [NarrativeEdge]
    let startNodeID: UUID
    let endNodeIDs: [UUID]
}

struct NarrativeNode: Codable, Identifiable {
    let id: UUID
    let type: NodeType
    let sceneData: SceneData
    let requiredChoices: [UUID]? // Previous choice IDs
    let characterStates: [UUID: CharacterState]
}

enum NodeType: String, Codable {
    case scene          // Standard performance scene
    case choicePoint    // Player decision moment
    case branch         // Narrative divergence
    case convergence    // Paths rejoin
    case ending         // Performance conclusion
}

struct NarrativeChoice: Codable, Identifiable {
    let id: UUID
    let promptText: String
    let options: [ChoiceOption]
    let timeLimit: TimeInterval?
    let significance: ChoiceSignificance

    // Impact tracking
    let affectedCharacters: [UUID]
    let narrativeConsequences: [Consequence]
    let moralDimension: MoralDimension?
}

struct ChoiceOption: Codable, Identifiable {
    let id: UUID
    let text: String
    let requiredConditions: [Condition]?
    let nextNodeID: UUID
    let immediateEffects: [Effect]
}

enum ChoiceSignificance: String, Codable {
    case minor       // Affects current scene only
    case moderate    // Affects character relationships
    case major       // Changes story direction
    case critical    // Determines ending
}
```

### Spatial Environment Data Model

```swift
struct SettingData: Codable, Identifiable {
    let id: UUID
    let name: String
    let description: String
    let historicalPeriod: HistoricalPeriod

    // Visual design
    let architecturalStyle: ArchitecturalStyle
    let colorPalette: ColorPalette
    let lightingDesign: LightingDesign
    let weatherConditions: WeatherData?

    // Spatial configuration
    let furnitureRequirements: [FurnitureType]
    let minimumRoomSize: SIMD3<Float> // meters
    let optimalRoomSize: SIMD3<Float>

    // Assets
    let environmentAssets: [AssetReference]
    let propModels: [PropData]
    let soundscapeID: String
}

struct PropData: Codable, Identifiable {
    let id: UUID
    let name: String
    let modelAssetID: String
    let isInteractive: Bool
    let interactionType: InteractionType?
    let narrativeSignificance: String?

    // Physics
    let physicsMaterial: PhysicsMaterial
    let mass: Float
    let canBePickedUp: Bool
}

enum InteractionType: String, Codable {
    case examine        // Look closely at object
    case manipulate     // Move, open, close
    case give           // Give to character
    case use            // Use for specific purpose
}
```

### Save Data Model

```swift
struct SaveData: Codable {
    let id: UUID
    let timestamp: Date
    let performanceID: UUID
    let performanceTitle: String

    // Progress
    let currentNodeID: UUID
    let completedNodes: [UUID]
    let choiceHistory: [PlayerChoice]
    let playthrough: Int // For multiple playthroughs

    // Character states
    let characterStates: [UUID: CharacterSaveState]
    let relationshipStates: [RelationshipKey: RelationshipState]

    // Statistics
    let totalPlayTime: TimeInterval
    let decisionsPoints: Int
    let explorationType: ExplorationType // Determined by choices
}

struct CharacterSaveState: Codable {
    let characterID: UUID
    let emotionalState: EmotionalState
    let currentObjective: Objective?
    let playerRelationship: Relationship
    let conversationHistory: [ConversationRecord]
}

struct PlayerChoice: Codable {
    let choiceID: UUID
    let selectedOptionID: UUID
    let timestamp: Date
    let choiceContext: String
}
```

---

## RealityKit Gaming Components & Systems

### Custom Component Architecture

```swift
// Character Animation Component
struct CharacterAnimationComponent: Component {
    var currentAnimation: AnimationResource
    var emotionalBlends: [Emotion: AnimationResource]
    var idleAnimation: AnimationResource
    var speakingAnimation: AnimationResource
    var transitionSpeed: Float
}

// AI Behavior Component
struct AIBehaviorComponent: Component {
    var personality: PersonalityTraits
    var currentGoal: Goal?
    var perceptionRadius: Float
    var attentionTarget: Entity?
    var conversationState: ConversationState
}

// Narrative Component
struct NarrativeComponent: Component {
    var characterID: UUID
    var availableDialogue: [DialogueNode]
    var currentDialogueNode: DialogueNode?
    var relationshipModifiers: [UUID: Float]
}

// Spatial Interaction Component
struct SpatialInteractionComponent: Component {
    var interactionType: InteractionType
    var interactionRadius: Float
    var requiresGaze: Bool
    var requiresHandGesture: Bool
    var feedbackType: HapticFeedback
}

// Performance Component (for optimization)
struct PerformanceComponent: Component {
    var lodLevel: LODLevel
    var isVisible: Bool
    var distanceFromPlayer: Float
    var updatePriority: UpdatePriority
}
```

### ECS System Architecture

```swift
// Character Animation System
class CharacterAnimationSystem: System {
    static let query = EntityQuery(
        where: .has(CharacterAnimationComponent.self) &&
               .has(AIBehaviorComponent.self)
    )

    func update(context: SceneUpdateContext) {
        for entity in context.entities(matching: Self.query) {
            guard var animation = entity.components[CharacterAnimationComponent.self],
                  let behavior = entity.components[AIBehaviorComponent.self] else { continue }

            // Blend animations based on emotional state
            // Update speaking animations during dialogue
            // Handle transitions smoothly
        }
    }
}

// AI Decision System
class AIDecisionSystem: System {
    static let query = EntityQuery(where: .has(AIBehaviorComponent.self))

    func update(context: SceneUpdateContext) {
        // Process AI decision-making
        // Update character goals and behaviors
        // Respond to player interactions
        // Maintain personality consistency
    }
}

// Spatial Interaction System
class SpatialInteractionSystem: System {
    static let query = EntityQuery(where: .has(SpatialInteractionComponent.self))

    func update(context: SceneUpdateContext) {
        // Process gaze-based interactions
        // Handle hand gesture recognition
        // Trigger character responses
        // Update interaction UI
    }
}

// Narrative Flow System
class NarrativeFlowSystem: System {
    func update(context: SceneUpdateContext) {
        // Manage scene progression
        // Trigger choice points
        // Track player decisions
        // Update narrative state
    }
}
```

### Entity Pooling for Performance

```swift
class EntityPool {
    private var pooledEntities: [String: [Entity]] = [:]

    func acquire(template: String, position: SIMD3<Float>) -> Entity? {
        if var pool = pooledEntities[template], !pool.isEmpty {
            let entity = pool.removeLast()
            entity.position = position
            entity.isEnabled = true
            return entity
        }
        return createNewEntity(template: template, position: position)
    }

    func release(_ entity: Entity, template: String) {
        entity.isEnabled = false
        pooledEntities[template, default: []].append(entity)
    }
}
```

---

## ARKit Integration

### Room Mapping & Understanding

```swift
class SpatialMappingSystem {
    private var roomBounds: BoundingBox?
    private var furnitureAnchors: [AnchorEntity] = []
    private var planeAnchors: [ARPlaneAnchor] = []

    func processRoomData(_ session: ARKitSession) async {
        // Detect room boundaries
        let roomDimensions = await detectRoomDimensions(session)

        // Identify furniture and surfaces
        let furniture = await detectFurniture(session)

        // Create spatial constraints for characters
        configureSafeZones(roomDimensions, furniture)

        // Optimize set design for room size
        adaptSetDesign(to: roomDimensions)
    }

    private func detectFurniture(_ session: ARKitSession) async -> [FurnitureAnchor] {
        // Use ARKit scene understanding
        // Classify objects: chairs, tables, couches
        // Create anchors for set integration
    }

    private func adaptSetDesign(to dimensions: SIMD3<Float>) {
        // Scale virtual set elements
        // Position characters appropriately
        // Adjust lighting for room size
        // Ensure player movement space
    }
}
```

### Player Tracking & Positioning

```swift
class PlayerTrackingSystem {
    private var playerPosition: SIMD3<Float> = .zero
    private var playerHeading: SIMD3<Float> = [0, 0, -1]
    private var gazeDirection: SIMD3<Float>?

    func updateTracking(_ session: ARKitSession) {
        // Track player head position
        // Determine gaze direction for character attention
        // Calculate distance to characters
        // Update spatial audio listener position
    }

    func getPlayerAttentionTarget() -> Entity? {
        guard let gaze = gazeDirection else { return nil }

        // Raycast from player gaze
        // Determine which character is being looked at
        // Calculate attention duration
        // Trigger character awareness
    }
}
```

### Hand Tracking System

```swift
class HandGestureSystem {
    enum TheaterGesture {
        case point(target: SIMD3<Float>)
        case wave
        case reachOut
        case dismiss
        case applause
        case raiseHand
    }

    func recognizeGesture(_ handTracking: HandTrackingProvider) -> TheaterGesture? {
        // Analyze hand skeleton data
        // Recognize theatrical gestures
        // Consider cultural context
        // Return high-confidence gestures only
    }

    func handleGesture(_ gesture: TheaterGesture) {
        switch gesture {
        case .point(let target):
            notifyCharactersOfPoint(target)
        case .wave:
            triggerCharacterGreeting()
        case .reachOut:
            enablePropInteraction()
        case .raiseHand:
            requestCharacterAttention()
        default:
            break
        }
    }
}
```

---

## AI Architecture

### Character AI Engine

```swift
class CharacterAIEngine {
    // Personality-driven decision making
    private let personalityModel: PersonalityModel

    // Dialogue generation
    private let dialogueGenerator: DialogueGenerator

    // Emotional intelligence
    private let emotionRecognizer: EmotionRecognitionSystem
    private let emotionGenerator: EmotionGenerationSystem

    // Memory and context
    private let shortTermMemory: ShortTermMemory
    private let longTermMemory: LongTermMemory

    func processPlayerInteraction(_ interaction: PlayerInteraction) async -> CharacterResponse {
        // Analyze interaction context
        let context = await analyzeContext(interaction)

        // Consider character personality
        let personalityInfluence = personalityModel.evaluate(context)

        // Check emotional state
        let emotionalResponse = emotionGenerator.generate(context, personalityInfluence)

        // Generate dialogue
        let dialogue = await dialogueGenerator.generate(
            context: context,
            personality: personalityInfluence,
            emotion: emotionalResponse
        )

        // Update memory
        shortTermMemory.record(interaction)

        // Return complete response
        return CharacterResponse(
            dialogue: dialogue,
            emotion: emotionalResponse,
            animation: selectAnimation(for: emotionalResponse),
            narrativeEffect: evaluateNarrativeImpact(interaction)
        )
    }
}
```

### Personality Model

```swift
class PersonalityModel {
    private let traits: PersonalityTraits
    private let culturalContext: CulturalContext

    func evaluateChoice(_ choice: PlayerChoice) -> PersonalityResponse {
        // Calculate alignment with character values
        let honorAlignment = calculateAlignment(choice, trait: .honor, weight: traits.honor)
        let loyaltyAlignment = calculateAlignment(choice, trait: .loyalty, weight: traits.loyalty)

        // Determine emotional reaction
        let emotionalReaction = determineReaction(
            alignments: [honorAlignment, loyaltyAlignment],
            basePersonality: traits
        )

        return PersonalityResponse(
            approval: emotionalReaction.approval,
            emotionalShift: emotionalReaction.emotionChange,
            relationshipDelta: emotionalReaction.relationshipChange
        )
    }
}
```

### Dialogue Generation System

```swift
class DialogueGenerator {
    private let languageModel: LanguageModel // CoreML or cloud-based
    private let styleGuide: DialogueStyleGuide

    func generate(
        context: InteractionContext,
        personality: PersonalityInfluence,
        emotion: EmotionalState
    ) async -> GeneratedDialogue {

        // Prepare prompt with context
        let prompt = buildPrompt(
            characterBackground: context.character.backstory,
            currentSituation: context.narrativeContext,
            recentHistory: context.conversationHistory,
            personality: personality,
            emotion: emotion,
            period: context.historicalPeriod
        )

        // Generate response
        let rawDialogue = await languageModel.generate(prompt)

        // Apply style and constraints
        let styledDialogue = styleGuide.apply(
            rawDialogue,
            period: context.historicalPeriod,
            formality: personality.formality
        )

        // Validate appropriateness
        let validatedDialogue = await validateContent(styledDialogue)

        return GeneratedDialogue(
            text: validatedDialogue,
            emotionalTone: emotion,
            deliveryStyle: determineDeliveryStyle(personality, emotion)
        )
    }
}
```

### Emotion Recognition & Response

```swift
class EmotionRecognitionSystem {
    func recognizePlayerEmotion() -> EmotionalState? {
        // Analyze facial expressions (if available)
        // Interpret voice tone
        // Consider gesture patterns
        // Evaluate choice patterns

        // Return recognized emotion with confidence
    }
}

class EmotionGenerationSystem {
    func generate(
        _ context: InteractionContext,
        _ personality: PersonalityInfluence
    ) -> EmotionalState {

        // Consider current emotional state
        // Factor in player interaction
        // Apply personality modifiers
        // Calculate emotional transition

        return EmotionalState(
            primaryEmotion: calculatedEmotion,
            intensity: calculatedIntensity,
            trigger: context.interactionType,
            duration: estimateDuration(calculatedEmotion, personality)
        )
    }
}
```

### Narrative AI Director

```swift
class NarrativeDirector {
    private let narrativeGraph: NarrativeGraph
    private var currentPath: [UUID] = []

    func evaluateStoryProgression(_ playerChoices: [PlayerChoice]) -> DirectorDecision {
        // Analyze pacing
        let currentPacing = analyzePacing()

        // Evaluate dramatic tension
        let tension = calculateDramaticTension()

        // Consider player engagement
        let engagement = estimateEngagement()

        // Make directorial decisions
        if tension < optimalTension && pacing == .slow {
            return .introduceConflict
        } else if engagement < threshold {
            return .offerInteraction
        } else {
            return .continueCurrentPath
        }
    }

    enum DirectorDecision {
        case continueCurrentPath
        case introduceConflict
        case offerInteraction
        case transitionScene
        case presentChoicePoint
    }
}
```

---

## Physics & Collision Systems

### Physics Configuration

```swift
class TheaterPhysicsSystem {
    // Lightweight physics for prop interactions
    private let physicsWorld: PhysicsWorld

    func configurePhysics() {
        // Gravity configuration (may vary for dramatic effect)
        physicsWorld.gravity = [0, -9.81, 0]

        // Collision layers
        // Layer 0: Environment (static)
        // Layer 1: Props (dynamic)
        // Layer 2: Characters (kinematic)
        // Layer 3: Player interaction zone
        // Layer 4: Safety boundaries
    }

    func setupPropPhysics(_ prop: Entity, data: PropData) {
        var physics = PhysicsBodyComponent(
            massProperties: .init(mass: data.mass),
            material: data.physicsMaterial,
            mode: data.canBePickedUp ? .dynamic : .static
        )

        prop.components[PhysicsBodyComponent.self] = physics

        // Collision filtering
        var collision = CollisionComponent(
            shapes: [.generateConvex(from: prop.model!)],
            mode: .trigger,
            filter: .init(group: .layer1, mask: [.layer0, .layer3])
        )

        prop.components[CollisionComponent.self] = collision
    }
}
```

### Collision Detection for Interactions

```swift
class CollisionInteractionSystem {
    func onCollision(_ event: CollisionEvent) {
        switch (event.entityA.collisionLayer, event.entityB.collisionLayer) {
        case (.playerInteraction, .prop):
            handlePropInteraction(event.entityB)

        case (.playerInteraction, .character):
            handleCharacterProximity(event.entityB)

        case (.safety, .player):
            triggerSafetyWarning()

        default:
            break
        }
    }
}
```

---

## Audio Architecture

### Spatial Audio System

```swift
class SpatialAudioSystem {
    private let audioEngine: AVAudioEngine
    private let environment: AVAudioEnvironmentNode

    func setupSpatialAudio() {
        // Configure for room-scale spatial audio
        environment.listenerPosition = AVAudio3DPoint(x: 0, y: 1.6, z: 0) // Player height
        environment.listenerAngularOrientation = AVAudio3DAngularOrientation()
        environment.renderingAlgorithm = .HRTF
    }

    func positionCharacterAudio(_ character: CharacterEntity, position: SIMD3<Float>) {
        guard let audioNode = character.audioNode else { return }

        // Position character voice in 3D space
        audioNode.position = AVAudio3DPoint(
            x: position.x,
            y: position.y,
            z: position.z
        )

        // Distance attenuation for realism
        audioNode.renderingAlgorithm = .HRTF
        audioNode.distanceAttenuationParameters.distanceAttenuationModel = .inverse
        audioNode.distanceAttenuationParameters.referenceDistance = 1.0
        audioNode.distanceAttenuationParameters.maximumDistance = 10.0
    }
}
```

### Audio Categories

```swift
enum AudioCategory {
    case characterDialogue    // Highest priority
    case narratorVoice       // High priority
    case environmentalSound  // Medium priority
    case music              // Low priority (ducks for dialogue)
    case soundEffects       // Medium priority
}

class AudioMixingSystem {
    private var activeSources: [AudioCategory: [AVAudioPlayerNode]] = [:]

    func playDialogue(_ character: CharacterEntity, audio: AVAudioFile) {
        // Duck music and ambient sound
        fadeCategory(.music, to: 0.3, duration: 0.5)
        fadeCategory(.environmentalSound, to: 0.5, duration: 0.5)

        // Play dialogue at full volume
        playPositionalAudio(audio, category: .characterDialogue, position: character.position)
    }

    func onDialogueComplete() {
        // Restore other audio categories
        fadeCategory(.music, to: 1.0, duration: 1.0)
        fadeCategory(.environmentalSound, to: 1.0, duration: 1.0)
    }
}
```

### Atmospheric Audio

```swift
class AtmosphericAudioSystem {
    func setupAtmosphere(for setting: SettingData) {
        // Base ambience
        let baseAmbience = loadAmbience(setting.soundscapeID)

        // Weather sounds
        if let weather = setting.weatherConditions {
            let weatherAudio = generateWeatherAudio(weather)
            mixAudio(baseAmbience, weatherAudio)
        }

        // Period-appropriate music
        if let music = setting.backgroundMusic {
            playBackgroundMusic(music, fadeIn: 3.0)
        }
    }
}
```

---

## Performance Optimization

### Target Metrics
- **Frame Rate:** 90 FPS (target), 60 FPS (minimum)
- **Frame Time:** 11.1ms per frame (90 FPS)
- **Latency:** <20ms for interactions
- **Memory:** <2GB working set
- **Thermal:** Sustained performance without throttling

### LOD (Level of Detail) System

```swift
class LODSystem {
    func updateLOD(for entity: Entity, distanceFromPlayer: Float) {
        var performance = entity.components[PerformanceComponent.self]!

        let newLOD: LODLevel = switch distanceFromPlayer {
        case 0..<2:
            .high      // Full detail
        case 2..<5:
            .medium    // Reduced polygon count
        case 5..<10:
            .low       // Simplified geometry
        default:
            .culled    // Not rendered
        }

        if newLOD != performance.lodLevel {
            performance.lodLevel = newLOD
            applyLOD(entity, level: newLOD)
        }
    }

    private func applyLOD(_ entity: Entity, level: LODLevel) {
        switch level {
        case .high:
            entity.model?.mesh = highDetailMesh
            entity.components[CharacterAnimationComponent.self]?.updateRate = .full

        case .medium:
            entity.model?.mesh = mediumDetailMesh
            entity.components[CharacterAnimationComponent.self]?.updateRate = .half

        case .low:
            entity.model?.mesh = lowDetailMesh
            entity.components[CharacterAnimationComponent.self]?.updateRate = .quarter

        case .culled:
            entity.isEnabled = false
        }
    }
}
```

### Asset Streaming

```swift
class AssetStreamingSystem {
    private var loadedScenes: [UUID: Scene] = [:]
    private var assetCache: NSCache<NSString, Asset> = NSCache()

    func preloadUpcoming(_ narrativeState: NarrativeState) async {
        // Predict next scenes based on narrative graph
        let upcomingScenes = predictNextScenes(narrativeState)

        for sceneID in upcomingScenes {
            // Load in background
            Task.detached(priority: .background) {
                await self.loadScene(sceneID)
            }
        }
    }

    func unloadDistantScenes() {
        // Free memory from scenes unlikely to be revisited
        // Keep critical paths in memory
    }
}
```

### Animation Optimization

```swift
class AnimationOptimizationSystem {
    func optimizeAnimations() {
        // Skeletal animation compression
        // Reduce keyframes for distant characters
        // Use animation LOD
        // Cache repeated animations
    }

    func updateAnimationBudget() {
        // Limit simultaneous animated characters
        // Prioritize characters player is looking at
        // Freeze distant character animations
    }
}
```

### Memory Management

```swift
class MemoryManager {
    func monitorMemory() {
        let usedMemory = getMemoryUsage()

        if usedMemory > memoryWarningThreshold {
            // Trigger garbage collection
            // Reduce asset quality
            // Clear caches
            // Unload distant content
        }
    }

    func optimizeForMemory() {
        // Texture compression
        // Mesh simplification
        // Audio format optimization
        // Shader complexity reduction
    }
}
```

---

## Save/Load System Architecture

### Save System

```swift
class SaveSystem {
    private let saveDirectory: URL

    func createSave(
        performance: PerformanceData,
        state: GameStateManager,
        narrativeState: NarrativeState
    ) async throws {

        let saveData = SaveData(
            id: UUID(),
            timestamp: Date(),
            performanceID: performance.id,
            performanceTitle: performance.title,
            currentNodeID: narrativeState.currentNode.id,
            completedNodes: narrativeState.completedNodes,
            choiceHistory: narrativeState.playerChoices,
            playthrough: narrativeState.playthroughNumber,
            characterStates: captureCharacterStates(state.activeCharacters),
            relationshipStates: captureRelationships(state.activeCharacters),
            totalPlayTime: state.performanceProgress.totalTime,
            decisionsPoints: narrativeState.playerChoices.count,
            explorationType: analyzeExplorationType(narrativeState.playerChoices)
        )

        // Serialize and save
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(saveData)

        let saveURL = saveDirectory.appendingPathComponent("\(saveData.id).save")
        try data.write(to: saveURL)

        // Create cloud backup if enabled
        if UserDefaults.standard.bool(forKey: "cloudSaveEnabled") {
            await uploadToCloud(saveData)
        }
    }

    func loadSave(_ saveID: UUID) async throws -> SaveData {
        let saveURL = saveDirectory.appendingPathComponent("\(saveID).save")
        let data = try Data(contentsOf: saveURL)

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(SaveData.self, from: data)
    }

    func restoreGameState(from save: SaveData) async {
        // Restore narrative position
        // Reload character states
        // Rebuild relationship map
        // Position player at correct scene
        // Resume performance
    }
}
```

### Auto-Save System

```swift
class AutoSaveSystem {
    private let saveInterval: TimeInterval = 120 // 2 minutes
    private var lastSaveTime: Date = Date()

    func update() {
        let now = Date()
        if now.timeIntervalSince(lastSaveTime) >= saveInterval {
            Task {
                await createAutoSave()
                lastSaveTime = now
            }
        }
    }

    private func createAutoSave() async {
        // Create save without interrupting gameplay
        // Use background priority
        // Compress if needed
    }
}
```

---

## Network Architecture

### Multiplayer Support (SharePlay)

```swift
class MultiplayerSession {
    private var groupSession: GroupSession?
    private var syncManager: SynchronizationManager

    func startSharedPerformance() async throws {
        // Initiate SharePlay session
        let session = try await GroupSession<TheaterPerformance>()
        self.groupSession = session

        // Synchronize narrative state
        syncManager.synchronize(with: session.participants)
    }

    func handleRemoteChoice(_ choice: PlayerChoice, from participant: Participant) {
        // Aggregate choices from all participants
        // Apply democratic or leader-based decision making
        // Update narrative state for all
    }
}
```

### Cloud Services Integration

```swift
class CloudServicesManager {
    // Content delivery
    func downloadPerformance(_ performanceID: UUID) async throws -> PerformanceData

    // AI dialogue generation (for complex requests)
    func generateComplexDialogue(_ context: ComplexContext) async throws -> GeneratedDialogue

    // Analytics
    func uploadAnalytics(_ events: [AnalyticsEvent]) async

    // Educational services
    func fetchCurriculumData() async throws -> [CurriculumAlignment]
}
```

---

## Security & Privacy

### Privacy Protection

```swift
class PrivacyManager {
    // Spatial data handling
    func processRoomData(_ roomData: RoomData) -> ProcessedRoomData {
        // Use room dimensions and layout
        // Discard identifiable information
        // Never store or transmit raw spatial data

        return ProcessedRoomData(
            dimensions: roomData.bounds,
            furnitureLayout: anonymizeFurniture(roomData.furniture)
        )
    }

    // User interaction privacy
    func recordInteraction(_ interaction: PlayerInteraction) {
        // Store locally only
        // No cloud synchronization without explicit consent
        // Anonymize if used for analytics
    }
}
```

### Content Safety

```swift
class ContentSafetySystem {
    func validateDialogue(_ dialogue: String) -> ValidationResult {
        // Check for inappropriate content
        // Ensure age-rating compliance
        // Cultural sensitivity verification

        return .approved(dialogue)
    }

    func monitorAIGeneration() {
        // Real-time content monitoring
        // Block inappropriate emergent content
        // Log safety issues for review
    }
}
```

---

## Testing Architecture

### Test Categories

1. **Unit Tests:** Individual components and systems
2. **Integration Tests:** System interactions and data flow
3. **UI Tests:** SwiftUI interfaces and spatial interactions
4. **Performance Tests:** Frame rate, latency, memory
5. **Accessibility Tests:** VoiceOver, alternative controls
6. **End-to-End Tests:** Complete user journeys

### Test Infrastructure

```swift
// Example test structure
class CharacterAITests: XCTestCase {
    func testPersonalityConsistency() async
    func testEmotionalResponseAccuracy() async
    func testDialogueGeneration() async
    func testMemorySystem() async
}

class NarrativeEngineTests: XCTestCase {
    func testBranchingLogic() async
    func testChoiceConsequences() async
    func testStateManagement() async
}

class SpatialInteractionTests: XCTestCase {
    func testGazeDetection() async
    func testHandGestureRecognition() async
    func testCollisionDetection() async
}
```

---

## Conclusion

This architecture provides a robust foundation for Interactive Theater, balancing:
- **Performance:** 90 FPS with complex AI and spatial rendering
- **Immersion:** Seamless integration of virtual and physical space
- **Intelligence:** Sophisticated character AI and narrative systems
- **Scalability:** Support for expanding content library
- **Privacy:** User data protection and spatial privacy
- **Accessibility:** Inclusive design for diverse audiences

The modular design allows for iterative development and testing, with clear separation of concerns and well-defined interfaces between systems.

---

**Version History:**
- v1.0 (2025-01-20): Initial architecture document
