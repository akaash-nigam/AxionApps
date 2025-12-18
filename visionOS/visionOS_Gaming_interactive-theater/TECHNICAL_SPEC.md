# Interactive Theater - Technical Specifications

## Document Overview
Detailed technical specifications for Interactive Theater visionOS gaming application.

**Version:** 1.0
**Last Updated:** 2025-01-20
**Target Platform:** Apple Vision Pro
**Minimum OS:** visionOS 2.0

---

## Table of Contents
1. [Technology Stack](#technology-stack)
2. [Development Environment](#development-environment)
3. [Game Mechanics Implementation](#game-mechanics-implementation)
4. [Control Schemes](#control-schemes)
5. [Physics Specifications](#physics-specifications)
6. [Rendering Requirements](#rendering-requirements)
7. [Multiplayer/Networking Specifications](#multiplayernetworking-specifications)
8. [Performance Budgets](#performance-budgets)
9. [Testing Requirements](#testing-requirements)
10. [API Specifications](#api-specifications)
11. [Data Formats](#data-formats)
12. [Third-Party Dependencies](#third-party-dependencies)

---

## Technology Stack

### Core Technologies

#### Programming Language
- **Swift 6.0+**
  - Strict concurrency checking enabled
  - Modern async/await patterns
  - Actor-based isolation for thread safety
  - Sendable protocol compliance
  - Value semantics for data models

```swift
// Example: Strict concurrency
@MainActor
class GameStateManager: ObservableObject {
    @Published var currentState: PerformanceState = .initialization
}

actor CharacterAIProcessor {
    func processDialogue(_ input: String) async -> CharacterResponse {
        // Thread-safe AI processing
    }
}
```

#### UI Framework
- **SwiftUI**
  - Declarative UI for menus and 2D interfaces
  - Ornament attachments for spatial UI
  - Custom view modifiers for theater aesthetics
  - Accessibility integration

```swift
struct MainMenuView: View {
    var body: some View {
        NavigationStack {
            PerformanceLibraryView()
        }
        .theaterStyle() // Custom modifier
    }
}
```

#### 3D Rendering
- **RealityKit 4.0+**
  - Entity-Component-System architecture
  - Custom components for character AI and narrative
  - Shader graph for visual effects
  - Particle systems for atmosphere
  - Physical-based rendering (PBR)

#### Spatial Computing
- **ARKit**
  - Room mapping and understanding
  - Hand tracking provider
  - Scene reconstruction
  - Plane detection
  - Object classification

- **visionOS 2.0+ Gaming APIs**
  - Immersive space management
  - Spatial input handling
  - Eye tracking integration
  - Spatial audio positioning

#### AI/ML Framework
- **CoreML 7.0+**
  - On-device character personality models
  - Emotion recognition models
  - Natural language understanding
  - Gesture classification

- **Natural Language Framework**
  - Sentiment analysis
  - Named entity recognition
  - Language detection
  - Text tokenization

#### Audio Engine
- **AVFoundation**
  - Spatial audio with HRTF
  - Audio engine for mixing
  - Low-latency playback
  - Voice synthesis (AVSpeechSynthesizer)

- **Audio Toolbox**
  - Custom audio units
  - Real-time audio processing
  - 3D audio positioning

#### Data Persistence
- **SwiftData**
  - Performance save data
  - Character relationship states
  - Player progress tracking
  - Settings and preferences

- **FileManager**
  - Asset management
  - Performance content packages
  - Cached AI model data

#### Networking
- **GroupActivities (SharePlay)**
  - Synchronized multiplayer performances
  - Shared decision-making
  - Participant coordination

- **URLSession**
  - Content downloads
  - Cloud AI services
  - Analytics upload
  - Educational platform API

---

## Development Environment

### Required Tools
- **Xcode 16.0+**
  - visionOS SDK
  - Reality Composer Pro
  - Swift 6.0 compiler
  - Instruments for profiling

- **Reality Composer Pro**
  - Character model preparation
  - Set design and layout
  - Material authoring
  - Animation setup

- **Version Control**
  - Git 2.40+
  - Git LFS for large assets (3D models, audio)

### Build Configuration

```swift
// Build settings
SWIFT_VERSION = 6.0
IPHONEOS_DEPLOYMENT_TARGET = 2.0
ENABLE_STRICT_CONCURRENCY = YES
SWIFT_OPTIMIZATION_LEVEL = -O // Release
SWIFT_COMPILATION_MODE = wholemodule

// Capabilities required
- Immersive Space
- Hand Tracking
- ARKit
- Spatial Audio
- Network (for multiplayer)
```

### Project Structure
```
InteractiveTheater/
├── InteractiveTheater/
│   ├── App/
│   │   ├── InteractiveTheaterApp.swift
│   │   ├── AppCoordinator.swift
│   │   └── Configuration.swift
│   ├── Core/
│   │   ├── GameLoop/
│   │   │   ├── GameLoopSystem.swift
│   │   │   └── UpdateScheduler.swift
│   │   ├── StateManagement/
│   │   │   ├── GameStateManager.swift
│   │   │   ├── NarrativeStateManager.swift
│   │   │   └── PerformanceState.swift
│   │   └── EventSystem/
│   │       ├── EventBus.swift
│   │       ├── GameEvents.swift
│   │       └── EventPriority.swift
│   ├── Systems/
│   │   ├── AISystem/
│   │   │   ├── CharacterAIEngine.swift
│   │   │   ├── PersonalityModel.swift
│   │   │   ├── DialogueGenerator.swift
│   │   │   ├── EmotionRecognition.swift
│   │   │   └── MemorySystem.swift
│   │   ├── NarrativeSystem/
│   │   │   ├── NarrativeEngine.swift
│   │   │   ├── ChoiceProcessor.swift
│   │   │   ├── BranchingLogic.swift
│   │   │   └── NarrativeDirector.swift
│   │   ├── SpatialSystem/
│   │   │   ├── RoomMappingSystem.swift
│   │   │   ├── HandTrackingSystem.swift
│   │   │   ├── EyeTrackingSystem.swift
│   │   │   └── GestureRecognition.swift
│   │   ├── AudioSystem/
│   │   │   ├── SpatialAudioEngine.swift
│   │   │   ├── DialoguePlayer.swift
│   │   │   ├── AtmosphericAudio.swift
│   │   │   └── MusicSystem.swift
│   │   └── PhysicsSystem/
│   │       ├── TheaterPhysicsWorld.swift
│   │       └── CollisionHandlers.swift
│   ├── Entities/
│   │   ├── CharacterEntity.swift
│   │   ├── PropEntity.swift
│   │   ├── EnvironmentEntity.swift
│   │   └── EntityFactory.swift
│   ├── Components/
│   │   ├── CharacterAnimationComponent.swift
│   │   ├── AIBehaviorComponent.swift
│   │   ├── NarrativeComponent.swift
│   │   ├── SpatialInteractionComponent.swift
│   │   └── PerformanceComponent.swift
│   ├── Views/
│   │   ├── MainMenuView.swift
│   │   ├── PerformanceLibraryView.swift
│   │   ├── SettingsView.swift
│   │   ├── TheaterPerformanceView.swift
│   │   ├── HUDView.swift
│   │   └── Components/
│   ├── Models/
│   │   ├── CharacterModel.swift
│   │   ├── PerformanceData.swift
│   │   ├── NarrativeGraph.swift
│   │   ├── SettingData.swift
│   │   └── SaveData.swift
│   ├── Services/
│   │   ├── SaveSystem.swift
│   │   ├── CloudServicesManager.swift
│   │   ├── AnalyticsService.swift
│   │   └── ContentDeliveryService.swift
│   ├── Utilities/
│   │   ├── Extensions/
│   │   ├── Helpers/
│   │   └── Constants.swift
│   └── Resources/
│       ├── Assets.xcassets/
│       ├── Performances/ (content packages)
│       ├── Audio/
│       ├── Models3D/
│       └── AIModels/
├── InteractiveTheaterTests/
│   ├── UnitTests/
│   │   ├── AISystemTests/
│   │   ├── NarrativeEngineTests/
│   │   ├── StateManagementTests/
│   │   └── ModelTests/
│   ├── IntegrationTests/
│   │   ├── SpatialInteractionTests/
│   │   ├── AudioSystemTests/
│   │   └── PerformanceFlowTests/
│   └── PerformanceTests/
│       ├── FrameRateTests.swift
│       ├── MemoryTests.swift
│       └── LatencyTests.swift
└── InteractiveTheaterUITests/
    ├── MenuNavigationTests.swift
    ├── PerformanceJourneyTests.swift
    └── AccessibilityTests.swift
```

---

## Game Mechanics Implementation

### Character Interaction System

#### Conversation Mechanism
```swift
class ConversationSystem {
    // Input: Player speech or selection
    // Processing: AI analysis and response generation
    // Output: Character dialogue with emotional context

    func initiateConversation(with character: CharacterEntity) async {
        // 1. Check character availability
        guard character.isAvailableForConversation else { return }

        // 2. Establish attention (eye tracking + proximity)
        await establishMutualAttention(character)

        // 3. Begin dialogue flow
        let context = buildContext(character, recentHistory)
        let response = await character.aiEngine.generateResponse(context)

        // 4. Play response with animation
        await playCharacterResponse(character, response)

        // 5. Await player input
        awaitPlayerResponse()
    }
}
```

#### Voice Input Processing
- **Speech Recognition:** On-device with privacy protection
- **Intent Classification:** Determine player intention (question, statement, choice)
- **Context Building:** Recent conversation, character relationships, narrative state

#### Dialogue Choice Selection
- **Gaze-based:** Look at option for 1 second to select
- **Voice-based:** Speak option number or content
- **Hand gesture:** Pinch on floating option card

### Narrative Agency Implementation

#### Choice Impact System
```swift
struct ChoiceImpactProcessor {
    func processChoice(_ choice: PlayerChoice, state: NarrativeState) -> ChoiceConsequences {
        var consequences = ChoiceConsequences()

        // 1. Immediate character reactions
        consequences.characterReactions = evaluateCharacterReactions(choice)

        // 2. Relationship modifications
        consequences.relationshipChanges = calculateRelationshipImpact(choice)

        // 3. Narrative path divergence
        consequences.narrativeBranch = determineNextNode(choice, state.currentNode)

        // 4. Long-term story effects
        consequences.futureConsequences = predictFutureImpacts(choice)

        // 5. Achievement/progress tracking
        consequences.achievements = checkAchievements(choice)

        return consequences
    }
}
```

#### Branching Logic
- **Tree-based branching:** Major story divergences
- **State-based gating:** Choices available based on prior decisions
- **Character-based branching:** Different paths per relationship levels
- **Convergent points:** Paths rejoin at key narrative moments

### Environmental Participation

#### Object Interaction
```swift
class PropInteractionSystem {
    func interactWithProp(_ prop: PropEntity, type: InteractionType) async {
        switch type {
        case .examine:
            // Bring prop closer, display details
            await zoomToProp(prop)
            await narrativeEngine.triggerExamineDialogue(prop)

        case .give(let character):
            // Transfer prop to character
            await animateGiveItem(prop, to: character)
            let reaction = await character.receiveItem(prop)
            await playReaction(reaction)

        case .manipulate:
            // Open, close, move, use
            await playManipulationAnimation(prop)
            await checkNarrativeTrigger(prop.manipulationState)

        case .use:
            // Use prop for specific purpose
            await executeUsage(prop)
            await applyNarrativeConsequence(prop.usageEffect)
        }
    }
}
```

#### Spatial Positioning Effects
- Player position affects which dialogue they hear
- Standing near specific characters reveals private conversations
- Room positioning changes camera angles and focus
- Proximity to props enables interactions

---

## Control Schemes

### Primary Input: Gaze + Voice

#### Eye Tracking
- **Attention Detection:** Which character player is looking at (100ms sampling)
- **Choice Selection:** Gaze-dwell selection (1000ms threshold)
- **UI Navigation:** Menu navigation via gaze
- **Engagement Tracking:** Attention analytics for pacing

```swift
class EyeTrackingInput {
    var gazeTarget: Entity?
    var gazeDuration: TimeInterval = 0

    func update(_ deltaTime: TimeInterval) {
        if let newTarget = detectGazeTarget() {
            if newTarget == gazeTarget {
                gazeDuration += deltaTime
                if gazeDuration >= selectionThreshold {
                    triggerSelection(newTarget)
                }
            } else {
                gazeTarget = newTarget
                gazeDuration = 0
            }
        }
    }
}
```

#### Voice Input
- **Continuous Listening:** Active during decision points
- **Wake Phrase:** Optional "Interactive Theater" to speak
- **Natural Language:** Full sentence interpretation
- **Privacy:** On-device processing, no cloud transmission

### Secondary Input: Hand Tracking

#### Supported Gestures
1. **Pinch (Thumb + Index)**
   - Selection confirmation
   - Prop grabbing
   - UI interaction

2. **Point (Index Extended)**
   - Direct object reference in dialogue
   - Character attention direction
   - Spatial navigation

3. **Wave**
   - Greeting characters
   - Getting attention
   - Dismissing UI

4. **Open Palm**
   - Receiving objects
   - Gesture of peace/submission
   - Historical cultural gestures

5. **Applause**
   - Performance appreciation
   - Encouragement
   - Ending acknowledgment

```swift
class HandGestureRecognizer {
    func recognizeGesture(_ handTracking: HandTrackingProvider) -> Gesture? {
        let leftHand = handTracking.leftHand
        let rightHand = handTracking.rightHand

        // Pinch detection
        if isPinching(rightHand) || isPinching(leftHand) {
            return .pinch(location: getPinchLocation())
        }

        // Point detection
        if isPointing(rightHand) {
            return .point(direction: getPointDirection(rightHand))
        }

        // Wave detection
        if isWaving(rightHand) || isWaving(leftHand) {
            return .wave
        }

        // Applause detection
        if isClapping(leftHand, rightHand) {
            return .applause
        }

        return nil
    }

    private func isPinching(_ hand: HandAnchor?) -> Bool {
        guard let hand = hand else { return false }
        let thumbTip = hand.thumbTip
        let indexTip = hand.indexFingerTip
        return distance(thumbTip, indexTip) < pinchThreshold
    }
}
```

### Tertiary Input: Game Controllers

#### Supported Controllers
- Xbox Wireless Controller
- PlayStation DualSense
- Generic MFi controllers

#### Button Mapping
- **A/X Button:** Confirm selection
- **B/Circle Button:** Back/cancel
- **D-Pad:** Navigate choices
- **Left Stick:** Navigate 3D space (seated mode)
- **Right Stick:** Look around (seated mode)
- **Triggers:** Context actions

#### Accessibility Consideration
- Full controller support for limited mobility
- Remappable buttons
- Hold vs. press options
- Reduced gesture requirements option

---

## Physics Specifications

### Physics Engine Configuration

#### Global Settings
```swift
let physicsConfiguration = PhysicsConfiguration(
    gravity: SIMD3<Float>(0, -9.81, 0),
    timeStep: 1.0 / 60.0, // Fixed 60 Hz physics
    solverIterations: 4,
    enableContinuousCollisionDetection: true
)
```

#### Material Properties

| Material | Static Friction | Dynamic Friction | Restitution (Bounce) | Density |
|----------|----------------|------------------|---------------------|---------|
| Wood (props) | 0.5 | 0.3 | 0.2 | 600 kg/m³ |
| Metal (swords, etc.) | 0.4 | 0.3 | 0.5 | 7850 kg/m³ |
| Fabric (costumes) | 0.7 | 0.5 | 0.0 | 200 kg/m³ |
| Paper (documents) | 0.6 | 0.4 | 0.1 | 700 kg/m³ |
| Stone (environment) | 0.9 | 0.7 | 0.1 | 2500 kg/m³ |

#### Collision Layers

```swift
enum CollisionLayer: UInt32 {
    case environment = 0b0001     // Static set pieces
    case props = 0b0010           // Interactive objects
    case characters = 0b0100      // AI actors (kinematic)
    case playerZone = 0b1000      // Player interaction area
    case safety = 0b10000         // Safety boundaries

    static let defaultMask: UInt32 = 0b11111
}
```

### Prop Physics Behavior

#### Graspable Objects
- **Mass Range:** 0.1 kg (letters) to 5 kg (heavy props)
- **Pickup Mechanism:** Snap to hand on pinch gesture
- **Release Behavior:** Inherit hand velocity
- **Drop Detection:** Auto-release if hand opens

#### Environmental Interactions
- **Collision Detection:** Only for player safety, minimal visual feedback
- **Character Avoidance:** Characters navigate around player and furniture
- **Furniture Integration:** Real furniture acts as static obstacles

---

## Rendering Requirements

### Visual Fidelity Targets

#### Character Rendering
- **Polygon Count:**
  - LOD 0 (High): 50,000 triangles
  - LOD 1 (Medium): 20,000 triangles
  - LOD 2 (Low): 5,000 triangles

- **Texture Resolution:**
  - Albedo: 4K (4096x4096)
  - Normal: 4K
  - Roughness/Metallic: 2K
  - AO: 2K

- **Shader Complexity:**
  - PBR materials with subsurface scattering
  - Cloth simulation for costumes
  - Hair rendering with transparency
  - Facial micro-expressions

#### Environmental Rendering
- **Set Pieces:** 10,000-30,000 triangles per major piece
- **Lighting:** Real-time global illumination
- **Shadows:** Soft shadows with PCSS
- **Reflections:** Screen-space reflections + probes

#### Visual Effects
- **Particle Systems:**
  - Atmospheric dust (period authenticity)
  - Candle flames and smoke
  - Weather effects (rain, snow)
  - Maximum 10,000 particles simultaneously

- **Post-Processing:**
  - Bloom for candles and light sources
  - Color grading for period look
  - Vignette (subtle, for dramatic moments)
  - Depth of field (optional, accessibility consideration)

### Rendering Pipeline

```swift
// Simplified rendering pipeline
class TheaterRenderingSystem {
    func render(scene: Scene, deltaTime: TimeInterval) {
        // 1. Culling
        let visibleEntities = frustumCull(scene.entities)

        // 2. LOD Selection
        updateLOD(visibleEntities, playerPosition)

        // 3. Shadow pass
        renderShadowMaps(visibleEntities)

        // 4. Lighting pass
        calculateLighting(visibleEntities, lightSources)

        // 5. Character rendering (highest priority)
        renderCharacters(visibleEntities.characters)

        // 6. Environment rendering
        renderEnvironment(visibleEntities.environment)

        // 7. VFX rendering
        renderParticles(activeParticleSystems)

        // 8. UI overlay
        renderSpatialUI(hudElements)

        // 9. Post-processing
        applyPostEffects(framebuffer)
    }
}
```

---

## Multiplayer/Networking Specifications

### SharePlay Integration

#### Session Management
```swift
class SharePlaySession {
    // Maximum participants: 6 people
    static let maxParticipants = 6

    func startSession() async throws {
        let activity = TheaterPerformanceActivity(performanceID: currentPerformance.id)
        let session = try await activity.prepareForActivation()
        session.activate()

        // Synchronize state
        await synchronizeInitialState()
    }

    func synchronizeInitialState() async {
        // Send current narrative node
        // Sync character states
        // Align playback timing
    }
}
```

#### State Synchronization
- **Frequency:** 30 Hz (every 33ms)
- **Data per update:** <1 KB
- **Latency tolerance:** <100ms
- **Conflict resolution:** Host-authoritative for narrative, voting for choices

#### Synchronized Elements
- Narrative progression
- Character positions and animations
- Dialogue timing
- Decision points (collaborative voting)
- Performance playback position

#### Non-Synchronized Elements
- Player spatial position (local only)
- Camera angle (personal preference)
- UI state (local preferences)
- Subtitles (accessibility settings)

### Network Requirements
- **Bandwidth:** 100 KB/s per participant (upload/download)
- **Latency:** <150ms for acceptable experience
- **Packet Loss:** Graceful degradation up to 5%

---

## Performance Budgets

### Frame Rate Targets
- **Target:** 90 FPS (11.1ms per frame)
- **Minimum:** 60 FPS (16.6ms per frame)
- **Never below:** 45 FPS (emergency thermal throttling)

### Per-Frame Budget Allocation

| System | Time Budget | Percentage |
|--------|-------------|------------|
| Input Processing | 0.5ms | 4.5% |
| AI Update | 2.0ms | 18% |
| Physics Simulation | 1.0ms | 9% |
| Animation Update | 1.5ms | 13.5% |
| Rendering | 5.0ms | 45% |
| Audio Processing | 0.5ms | 4.5% |
| Game Logic | 1.0ms | 9% |
| Reserve | 0.6ms | 5.4% |
| **Total** | **11.1ms** | **100%** |

### Memory Budget
- **Total Budget:** 2 GB working set
- **Breakdown:**
  - Textures: 600 MB
  - 3D Models: 400 MB
  - Audio: 200 MB
  - AI Models: 300 MB
  - Code & Framework: 200 MB
  - System Reserve: 300 MB

### Thermal Management
- **Target:** Sustained performance without throttling for 60+ minutes
- **Monitoring:** Check thermal state every 5 seconds
- **Mitigation Strategies:**
  - Reduce LOD levels
  - Lower texture resolution
  - Decrease particle count
  - Reduce AI update frequency
  - Dim lighting complexity

### Battery Impact
- **Target:** 2+ hours of continuous play
- **Power-Efficient Mode:** 3+ hours with reduced fidelity
- **Optimization:**
  - Efficient rendering pipeline
  - Smart asset streaming
  - Minimize network usage
  - Optimize AI inference

---

## Testing Requirements

### Unit Testing (Target: 80% Code Coverage)

#### Core Systems
```swift
class GameLoopTests: XCTestCase {
    func testFixedTimestepPhysics() async throws
    func testVariableRenderingUpdate() async throws
    func testTimeAccumulatorAccuracy() async throws
}

class StateManagementTests: XCTestCase {
    func testStateTransitions() async throws
    func testInvalidTransitionBlocking() async throws
    func testStateEventNotification() async throws
}

class EventBusTests: XCTestCase {
    func testEventPublishing() async throws
    func testEventSubscription() async throws
    func testEventPriorityOrdering() async throws
    func testAsyncEventProcessing() async throws
}
```

#### AI Systems
```swift
class CharacterAITests: XCTestCase {
    func testPersonalityConsistency() async throws
    func testEmotionalStateTransitions() async throws
    func testDialogueGeneration() async throws
    func testMemoryRetention() async throws
    func testRelationshipTracking() async throws
}

class DialogueGeneratorTests: XCTestCase {
    func testPeriodAppropriateLanguage() async throws
    func testPersonalityInfluence() async throws
    func testEmotionalToneMatching() async throws
    func testContextualCoherence() async throws
}
```

#### Narrative Engine
```swift
class NarrativeEngineTests: XCTestCase {
    func testBranchingLogic() async throws
    func testChoiceConsequences() async throws
    func testNarrativeGraphTraversal() async throws
    func testEndingDetermination() async throws
}
```

### Integration Testing

#### Spatial Interactions
```swift
class SpatialInteractionIntegrationTests: XCTestCase {
    func testGazeToCharacterAttention() async throws
    func testHandGestureToCharacterResponse() async throws
    func testVoiceInputToDialogue() async throws
    func testPropInteractionFlow() async throws
}
```

#### Performance Flow
```swift
class PerformanceFlowTests: XCTestCase {
    func testCompletePerformancePlaythrough() async throws
    func testSceneTransitions() async throws
    func testChoicePointFlow() async throws
    func testMultipleEndingPaths() async throws
}
```

### Performance Testing

#### Frame Rate
```swift
class FrameRateTests: XCTestCase {
    func testSustained90FPS() throws {
        // Run performance for 5 minutes
        // Measure frame times
        // Assert: 95th percentile < 11.1ms
    }

    func testWorstCaseScenario() throws {
        // Maximum characters + effects
        // Measure frame times
        // Assert: Never below 60 FPS
    }
}
```

#### Memory
```swift
class MemoryTests: XCTestCase {
    func testMemoryLeaks() async throws
    func testWorkingSetBudget() async throws
    func testAssetStreamingEfficiency() async throws
}
```

#### Latency
```swift
class LatencyTests: XCTestCase {
    func testInputToResponseLatency() async throws {
        // Measure: Input detected -> Character responds
        // Assert: <200ms for 95th percentile
    }

    func testGestureRecognitionLatency() async throws {
        // Measure: Gesture performed -> System recognition
        // Assert: <100ms for 95th percentile
    }
}
```

### UI Testing

```swift
class MenuNavigationUITests: XCTestCase {
    func testMainMenuNavigation() async throws
    func testPerformanceSelection() async throws
    func testSettingsAdjustment() async throws
    func testAccessibilityControls() async throws
}

class PerformanceJourneyUITests: XCTestCase {
    func testPerformanceStartToEnd() async throws
    func testPauseAndResume() async throws
    func testChoiceInteraction() async throws
    func testSubtitleDisplay() async throws
}
```

### Accessibility Testing

```swift
class AccessibilityTests: XCTestCase {
    func testVoiceOverSupport() async throws
    func testReducedMotionMode() async throws
    func testSubtitleAccuracy() async throws
    func testControllerOnlyNavigation() async throws
    func testColorBlindModes() async throws
}
```

### End-to-End Testing

```swift
class CompleteUserJourneyTests: XCTestCase {
    func testNewUserOnboarding() async throws
    func testFirstPerformanceExperience() async throws
    func testMultiplePlaythroughs() async throws
    func testSaveAndLoadFunctionality() async throws
    func testMultiplayerSession() async throws
}
```

---

## API Specifications

### Content Delivery API

```swift
protocol ContentDeliveryService {
    /// Fetch available performances
    func fetchPerformanceLibrary() async throws -> [PerformanceMetadata]

    /// Download specific performance
    func downloadPerformance(_ id: UUID) async throws -> PerformanceData

    /// Check for updates to owned performances
    func checkForUpdates() async throws -> [PerformanceUpdate]

    /// Download performance assets
    func downloadAssets(_ performanceID: UUID) async throws -> AssetBundle
}
```

### Cloud AI Service API

```swift
protocol CloudAIService {
    /// Generate complex dialogue (when on-device insufficient)
    func generateComplexDialogue(_ request: DialogueRequest) async throws -> GeneratedDialogue

    /// Analyze player interaction patterns
    func analyzePlayerBehavior(_ interactions: [PlayerInteraction]) async throws -> BehaviorAnalysis

    /// Educational content generation
    func generateEducationalContent(_ request: EducationalContentRequest) async throws -> EducationalContent
}
```

### Analytics API

```swift
protocol AnalyticsService {
    /// Track performance events
    func logEvent(_ event: AnalyticsEvent)

    /// Track player choices (anonymized)
    func logChoice(_ choice: PlayerChoice, context: ChoiceContext)

    /// Upload analytics batch
    func uploadBatch() async throws

    /// Educational analytics
    func logLearningOutcome(_ outcome: LearningOutcome)
}
```

---

## Data Formats

### Performance Package Format

```
PerformancePackage.itp (Interactive Theater Performance)
├── manifest.json (metadata, version, requirements)
├── narrative/
│   ├── graph.json (narrative structure)
│   ├── characters.json (character definitions)
│   ├── scenes.json (scene data)
│   └── dialogue/
│       ├── act1_scene1.json
│       └── ...
├── assets/
│   ├── models/
│   │   ├── character_hamlet.usdz
│   │   └── ...
│   ├── textures/
│   ├── animations/
│   └── audio/
│       ├── dialogue/
│       ├── music/
│       └── sfx/
├── ai/
│   ├── personality_models.mlmodel
│   └── dialogue_style.mlmodel
└── educational/
    ├── learning_objectives.json
    ├── curriculum_alignment.json
    └── study_guide.md
```

### Save File Format

```json
{
  "version": "1.0",
  "saveID": "uuid",
  "timestamp": "2025-01-20T10:30:00Z",
  "performanceID": "uuid",
  "currentNodeID": "uuid",
  "completedNodes": ["uuid", "uuid"],
  "choiceHistory": [
    {
      "choiceID": "uuid",
      "selectedOptionID": "uuid",
      "timestamp": "2025-01-20T10:25:00Z"
    }
  ],
  "characterStates": {
    "hamlet_uuid": {
      "emotionalState": "melancholic",
      "relationshipWithPlayer": 0.6,
      "conversationHistory": [...]
    }
  },
  "statistics": {
    "totalPlayTime": 3600,
    "decisionsCount": 12
  }
}
```

---

## Third-Party Dependencies

### Swift Package Manager Dependencies

```swift
// Package.swift
dependencies: [
    // None initially - using Apple frameworks
    // Potential future additions:
    // .package(url: "https://github.com/apple/swift-algorithms", from: "1.0.0"),
]
```

### CoreML Models

1. **Personality Model** (custom trained)
   - Input: Interaction context
   - Output: Personality-based response scores

2. **Emotion Recognition** (custom trained)
   - Input: Player behavior patterns
   - Output: Emotion classification

3. **Dialogue Style Model** (fine-tuned LLM)
   - Input: Context + character profile
   - Output: Period-appropriate dialogue

### Asset Requirements

- **3D Models:** USD/USDZ format
- **Audio:** AAC 256kbps, 48kHz, spatial
- **Textures:** PNG/ASTC compressed
- **Animations:** USD animation tracks

---

## Version Compatibility

### Minimum Requirements
- **Device:** Apple Vision Pro (1st generation)
- **OS:** visionOS 2.0
- **Storage:** 10 GB free (base app + one performance)
- **Network:** Wi-Fi for downloads (cellular for multiplayer)

### Recommended Requirements
- **OS:** visionOS 2.1+
- **Storage:** 50 GB (full performance library)
- **Network:** Wi-Fi 6 for optimal multiplayer

---

## Conclusion

This technical specification provides the foundation for implementing Interactive Theater with:
- Robust technology stack leveraging latest visionOS capabilities
- Detailed game mechanics for immersive theatrical experiences
- Multiple input methods for accessibility and natural interaction
- High-fidelity rendering with strict performance budgets
- Comprehensive testing strategy ensuring quality
- Clear API contracts for extensibility

All implementations must adhere to these specifications while maintaining flexibility for iteration based on testing and user feedback.

---

**Version History:**
- v1.0 (2025-01-20): Initial technical specification
