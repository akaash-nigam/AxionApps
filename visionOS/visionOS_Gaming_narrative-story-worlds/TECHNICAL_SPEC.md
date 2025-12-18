# Narrative Story Worlds - Technical Specification

## Table of Contents

1. [Technology Stack](#technology-stack)
2. [Development Environment](#development-environment)
3. [Game Mechanics Implementation](#game-mechanics-implementation)
4. [Control Schemes](#control-schemes)
5. [Physics Specifications](#physics-specifications)
6. [Rendering Requirements](#rendering-requirements)
7. [AI System Specifications](#ai-system-specifications)
8. [Networking & Multiplayer](#networking--multiplayer)
9. [Performance Requirements](#performance-requirements)
10. [Testing Requirements](#testing-requirements)
11. [Security & Privacy](#security--privacy)

---

## 1. Technology Stack

### Core Technologies

```yaml
Platform:
  OS: visionOS 2.0+
  Device: Apple Vision Pro
  Minimum: visionOS 2.0
  Recommended: visionOS 2.1+

Programming Language:
  Primary: Swift 6.0+
  Features Used:
    - Strict concurrency checking
    - Sendable protocol
    - async/await patterns
    - Actors for thread safety
    - Macros for boilerplate reduction

Frameworks:
  UI: SwiftUI 5.0+
  3D Rendering: RealityKit 4.0
  Spatial Tracking: ARKit 6.0
  Audio: AVFoundation with Spatial Audio
  Machine Learning: Core ML 7.0+
  Persistence: CoreData + CloudKit
  Networking: URLSession with async/await

Game Frameworks:
  GameplayKit: For game logic patterns
  RealityKit Animation: For character animations
  ARKit Face Tracking: For emotion recognition
  Spatial Audio: For immersive sound
```

### Third-Party Dependencies

```swift
// Package.swift
dependencies: [
    // None required - using only Apple frameworks
    // All features implemented with native APIs
]

// Rationale: Minimize dependencies for App Store approval
// and maximum performance on visionOS
```

---

## 2. Development Environment

### Required Tools

```yaml
Hardware Requirements:
  Development Mac:
    - Apple Silicon (M1 or later) required
    - 16GB RAM minimum, 32GB recommended
    - 100GB free storage
  Testing Device:
    - Apple Vision Pro with visionOS 2.0+
    - Developer mode enabled

Software Requirements:
  Xcode: 16.0 or later
  Xcode Command Line Tools: Latest
  Reality Composer Pro: Latest
  SF Symbols: 6.0+
  iOS Simulator: visionOS 2.0+

Additional Tools:
  - Instruments for performance profiling
  - Console.app for debugging
  - Create ML for AI model training
  - Audacity/Logic Pro for audio editing
  - Blender for 3D model prep
```

### Project Configuration

```swift
// Project.pbxproj settings
PRODUCT_NAME = "Narrative Story Worlds"
PRODUCT_BUNDLE_IDENTIFIER = "com.storystudios.narrativeworldsvision"
MARKETING_VERSION = "1.0.0"
CURRENT_PROJECT_VERSION = "1"

SDKROOT = "xros"
SUPPORTED_PLATFORMS = "xros xrsimulator"
TARGETED_DEVICE_FAMILY = "7" // Vision

IPHONEOS_DEPLOYMENT_TARGET = "2.0"
SWIFT_VERSION = "6.0"
ENABLE_PREVIEWS = "YES"

// Capabilities
ENABLE_HARDENED_RUNTIME = "YES"
CODE_SIGN_ENTITLEMENTS = "NarrativeStoryWorlds.entitlements"

// Optimization
SWIFT_OPTIMIZATION_LEVEL = "-O" // Release
GCC_OPTIMIZATION_LEVEL = "s" // Size optimization for assets
SWIFT_COMPILATION_MODE = "wholemodule"
```

### Entitlements

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN">
<plist version="1.0">
<dict>
    <!-- Spatial Computing -->
    <key>com.apple.developer.arkit.world-tracking</key>
    <true/>
    <key>com.apple.developer.arkit.face-tracking</key>
    <true/>
    <key>com.apple.developer.arkit.hand-tracking</key>
    <true/>
    <key>com.apple.developer.spatial-persistence</key>
    <true/>

    <!-- Audio -->
    <key>com.apple.developer.spatial-audio</key>
    <true/>

    <!-- Cloud -->
    <key>com.apple.developer.icloud-container-identifiers</key>
    <array>
        <string>iCloud.com.storystudios.narrativeworldsvision</string>
    </array>
    <key>com.apple.developer.ubiquity-kvstore-identifier</key>
    <string>$(TeamIdentifierPrefix)com.storystudios.narrativeworldsvision</string>

    <!-- App Groups -->
    <key>com.apple.security.application-groups</key>
    <array>
        <string>group.com.storystudios.narrativeworldsvision</string>
    </array>
</dict>
</plist>
```

---

## 3. Game Mechanics Implementation

### Dialogue System

```swift
// Dialogue tree implementation
class DialogueSystem {
    struct DialogueNode {
        let id: UUID
        let speaker: CharacterID
        let text: String
        let audioClip: AudioResource?

        // Branching
        let responses: [DialogueResponse]
        let conditions: [StoryCondition]

        // Timing
        let displayDuration: TimeInterval
        let autoAdvance: Bool

        // Emotion
        let emotionalTone: Emotion
        let facialAnimation: AnimationResource
    }

    struct DialogueResponse {
        let id: UUID
        let text: String
        let nextNodeID: UUID

        // Consequences
        let relationshipChange: [CharacterID: Float]
        let flagsToSet: Set<StoryFlag>
        let emotionalImpact: EmotionalImpact
    }

    // Real-time dialogue
    func presentDialogue(node: DialogueNode,
                        character: Entity) async {
        // 1. Position dialogue UI near character
        let dialogueUI = createDialogueUI(for: node)
        dialogueUI.position = character.position + SIMD3(0, 0.3, 0)

        // 2. Animate character speaking
        character.playAnimation(node.facialAnimation)

        // 3. Play spatial audio
        if let audio = node.audioClip {
            playCharacterVoice(audio, at: character.position)
        }

        // 4. Display text with typewriter effect
        await animateText(node.text, in: dialogueUI)

        // 5. Present response options
        if !node.autoAdvance {
            await presentResponses(node.responses)
        }
    }
}
```

### Choice System

```swift
class ChoiceSystem {
    struct ChoicePresentation {
        let choice: Choice
        let spatialLayout: SpatialLayout
        let timeLimit: TimeInterval?

        enum SpatialLayout {
            case radial(radius: Float, arc: Float)
            case linear(spacing: Float)
            case contextual(anchorTo: Entity)
        }
    }

    // Spatial choice presentation
    func presentChoice(_ choice: Choice,
                      near character: Entity) async -> ChoiceOption {
        // 1. Create choice entities in 3D space
        let choiceEntities = createChoiceEntities(choice)

        // 2. Position in space (fan out from character)
        layoutChoices(choiceEntities,
                     layout: .radial(radius: 0.5, arc: .pi / 2))

        // 3. Add glow/highlighting
        highlightChoices(choiceEntities)

        // 4. Wait for player selection
        let selected = await waitForSelection(choiceEntities,
                                              timeout: choice.timeLimit)

        // 5. Animate selection
        await animateChoice(selected)

        // 6. Remove unselected options
        removeChoices(choiceEntities.filter { $0 != selected })

        return selected.choiceOption
    }

    // Gesture-based selection
    func detectChoiceSelection(choices: [Entity]) async -> Entity? {
        // Use ARKit hand tracking
        // Player points at choice
        // Pinch to select
    }
}
```

### Object Interaction

```swift
class InteractionSystem {
    enum InteractionType {
        case examine          // Pick up and rotate
        case use             // Trigger action
        case combine(with: Entity)  // Combine items
        case talk            // Initiate dialogue
    }

    struct InteractableObject {
        let entity: Entity
        let type: InteractionType
        let storyRelevance: StoryRelevance
        var state: ObjectState
    }

    // Interaction detection
    func detectInteraction() async -> InteractableObject? {
        // 1. Raycast from hand position
        let handPosition = await getHandPosition()
        let raycastResult = raycast(from: handPosition)

        // 2. Check if interactable
        guard let entity = raycastResult.entity,
              let interactable = interactables[entity.id] else {
            return nil
        }

        // 3. Check distance (must be within reach)
        let distance = simd_distance(handPosition, entity.position)
        guard distance < 0.6 else { return nil } // 60cm reach

        return interactable
    }

    // Examine object
    func examineObject(_ object: InteractableObject) async {
        // 1. Detach from anchor
        object.entity.removeFromParent()

        // 2. Bring closer to player
        let examinePosition = playerPosition + SIMD3(0, 0, -0.5)
        await animateMove(object.entity, to: examinePosition)

        // 3. Enable rotation with hand gestures
        enableRotation(object.entity)

        // 4. Show information overlay
        showObjectInfo(object.storyRelevance)

        // 5. Update story state
        markAsExamined(object)
    }
}
```

### Character Presence

```swift
class CharacterPresenceSystem {
    // Natural character positioning
    func positionCharacter(_ character: Entity,
                          for scene: Scene,
                          in room: RoomFeatures) async {
        // 1. Determine optimal position
        let position = calculateOptimalPosition(
            character: character,
            scene: scene,
            room: room
        )

        // 2. Find furniture to use
        if let furniture = findNearestFurniture(to: position, room: room) {
            // Sit or lean naturally
            await animateCharacterToFurniture(character, furniture)
        } else {
            // Stand naturally
            await animateCharacterTo(character, position)
        }

        // 3. Orient toward player
        let lookDirection = normalize(playerPosition - character.position)
        character.orientation = simd_quatf(from: SIMD3(0,0,-1),
                                           to: lookDirection)

        // 4. Maintain eye contact
        enableEyeTracking(character)
    }

    // Eye contact system
    func enableEyeTracking(_ character: Entity) {
        // Character's eyes follow player
        // Looks away during emotional moments
        // Glances at relevant objects
    }
}
```

---

## 4. Control Schemes

### Primary Input: Gaze + Gesture

```swift
class InputSystem {
    // ARKit providers
    private var handTrackingProvider: HandTrackingProvider
    private var eyeTrackingProvider: EyeTrackingProvider

    struct GestureInput {
        var leftHand: HandSkeleton?
        var rightHand: HandSkeleton?
        var gazeDirection: SIMD3<Float>
        var gazeTarget: Entity?
    }

    // Detect pinch gesture
    func detectPinch(hand: HandSkeleton) -> Bool {
        let thumbTip = hand.joint(.thumbTip).position
        let indexTip = hand.joint(.indexFingerTip).position
        let distance = simd_distance(thumbTip, indexTip)
        return distance < 0.02 // 2cm threshold
    }

    // Point and select
    func detectPointAndSelect() async -> Entity? {
        // 1. Get gaze target
        let gazeTarget = await getGazeTarget()

        // 2. Check for pinch gesture
        guard let rightHand = await getHandSkeleton(.right),
              detectPinch(hand: rightHand) else {
            return nil
        }

        // 3. Provide haptic feedback
        playHaptic(.selection)

        return gazeTarget
    }

    // Grab and move
    func detectGrabGesture() async -> GrabIntent? {
        guard let rightHand = await getHandSkeleton(.right) else {
            return nil
        }

        // Closed fist = grab
        if isHandClosed(rightHand) {
            let grabPosition = rightHand.joint(.wrist).position
            let grabTarget = await getEntityAt(grabPosition)
            return GrabIntent(hand: rightHand,
                            target: grabTarget,
                            position: grabPosition)
        }

        return nil
    }
}
```

### Gesture Library

```swift
enum NarrativeGesture: String, CaseIterable {
    // Selection
    case point              // Point at choice
    case pinch              // Select option

    // Interaction
    case grab               // Pick up object
    case push               // Push away
    case pull               // Pull closer

    // Emotional
    case wave               // Greet character
    case handToHeart        // Show emotion
    case defensivePosture   // Show fear
    case openPalm           // Show trust

    // Control
    case timeout            // Pause story
    case rewind             // Review dialogue

    var recognitionCriteria: GestureCriteria {
        switch self {
        case .point:
            return .indexExtended(threshold: 0.9)
        case .pinch:
            return .thumbIndexProximity(maxDistance: 0.02)
        case .grab:
            return .allFingersClosed(threshold: 0.7)
        case .wave:
            return .handMovement(speed: 0.3, pattern: .lateral)
        case .handToHeart:
            return .handPosition(near: .chest, duration: 1.0)
        // ... etc
        }
    }
}
```

### Game Controller Support

```swift
import GameController

class GameControllerSupport {
    // Optional controller support for accessibility
    func setupControllerInput() {
        GCController.startWirelessControllerDiscovery()

        NotificationCenter.default.addObserver(
            forName: .GCControllerDidConnect,
            object: nil,
            queue: .main
        ) { notification in
            guard let controller = notification.object as? GCController else { return }
            self.configureController(controller)
        }
    }

    func configureController(_ controller: GCController) {
        guard let gamepad = controller.extendedGamepad else { return }

        // A button = Select choice
        gamepad.buttonA.pressedChangedHandler = { button, value, pressed in
            if pressed {
                self.selectCurrentChoice()
            }
        }

        // Left stick = Navigate choices
        gamepad.leftThumbstick.valueChangedHandler = { stick, x, y in
            self.navigateChoices(direction: SIMD2(x, y))
        }

        // Menu button = Pause
        gamepad.buttonMenu.pressedChangedHandler = { button, value, pressed in
            if pressed {
                self.pauseStory()
            }
        }
    }
}
```

---

## 5. Physics Specifications

### Physics Configuration

```swift
class PhysicsConfiguration {
    static let shared = PhysicsConfiguration()

    // Physics settings
    let gravity = SIMD3<Float>(0, -9.81, 0)
    let timeStep: TimeInterval = 1.0 / 90.0  // 90 Hz

    // Collision layers
    enum CollisionLayer: UInt32 {
        case character = 0b0001
        case storyObject = 0b0010
        case environment = 0b0100
        case player = 0b1000

        case all = 0b1111
    }

    // Character physics
    func setupCharacterPhysics(_ entity: Entity) {
        let shape = ShapeResource.generateCapsule(
            height: 1.7,  // Average human height
            radius: 0.25
        )

        let physics = PhysicsBodyComponent(
            mode: .kinematic,  // AI-controlled, not physics
            shape: shape
        )

        entity.components[PhysicsBodyComponent.self] = physics

        // Collision detection only
        let collision = CollisionComponent(
            shapes: [shape],
            filter: CollisionFilter(
                group: .character,
                mask: [.environment, .player]
            )
        )

        entity.components[CollisionComponent.self] = collision
    }

    // Object physics
    func setupObjectPhysics(_ entity: Entity,
                           mass: Float = 1.0) {
        let shape = ShapeResource.generateBox(
            size: entity.visualBounds(relativeTo: nil).extents
        )

        let physics = PhysicsBodyComponent(
            mode: .dynamic,
            mass: mass,
            material: .generate(
                staticFriction: 0.6,
                dynamicFriction: 0.5,
                restitution: 0.3  // Slight bounce
            ),
            shape: shape
        )

        entity.components[PhysicsBodyComponent.self] = physics
    }
}
```

### Collision Handling

```swift
class CollisionHandler {
    func handleCollision(_ event: CollisionEvents.Began) {
        let entityA = event.entityA
        let entityB = event.entityB

        // Character collision with environment
        if isCharacter(entityA) && isEnvironment(entityB) {
            // Stop character movement
            // Find alternative path
            rerouteCharacter(entityA)
        }

        // Player interaction with object
        if isPlayer(entityA) && isStoryObject(entityB) {
            // Highlight object
            // Enable interaction prompt
            highlightInteractable(entityB)
        }
    }
}
```

---

## 6. Rendering Requirements

### Visual Quality Targets

```yaml
Character Rendering:
  Polygon Count:
    - High LOD (< 2m): 50,000 triangles
    - Medium LOD (2-4m): 20,000 triangles
    - Low LOD (> 4m): 8,000 triangles

  Textures:
    - Base Color: 4K (4096x4096)
    - Normal Map: 4K
    - Roughness/Metallic: 2K
    - Subsurface Scattering: 2K for skin

  Shading:
    - PBR materials
    - Subsurface scattering for skin
    - Real-time shadows
    - IBL (Image-Based Lighting)

  Animation:
    - 60 FPS skeletal animation
    - Blend shapes for facial (52 ARKit blend shapes)
    - Cloth simulation for clothing

Environment Rendering:
  Lighting:
    - Real-time environmental probe
    - Shadow mapping (2048x2048)
    - Ambient occlusion
    - Color grading for mood

  Effects:
    - Particle systems (dust, atmosphere)
    - Volumetric lighting
    - Screen-space reflections
    - Bloom for dramatic moments

Performance Targets:
  Frame Rate: 90 FPS minimum, never below 60 FPS
  Latency: < 20ms motion-to-photon
  Resolution: Native per-eye resolution
  Foveated Rendering: Enabled for optimization
```

### Foveated Rendering Implementation

```swift
class FoveatedRenderingManager {
    func configureFoveatedRendering() {
        // RealityKit automatically handles foveated rendering
        // on visionOS, but we can optimize content placement

        // High-detail content in center of view
        // Lower detail in periphery
    }

    func optimizeForGaze(gazePosition: SIMD2<Float>) {
        // Increase LOD for entities near gaze
        // Decrease LOD for entities in periphery

        for entity in visibleEntities {
            let angleToGaze = angleBetween(entity.position, gazePosition)

            if angleToGaze < 10.degrees {
                entity.setLOD(.high)
            } else if angleToGaze < 30.degrees {
                entity.setLOD(.medium)
            } else {
                entity.setLOD(.low)
            }
        }
    }
}
```

### Animation System

```swift
class CharacterAnimationSystem {
    // Blend facial animations
    func updateFacialAnimation(character: Entity,
                              emotion: Emotion,
                              speaking: Bool) {
        var blendShapes: [ARFaceAnchor.BlendShapeLocation: Float] = [:]

        // Base emotional expression
        switch emotion {
        case .happy:
            blendShapes[.mouthSmileLeft] = 0.7
            blendShapes[.mouthSmileRight] = 0.7
            blendShapes[.eyeSquintLeft] = 0.3
            blendShapes[.eyeSquintRight] = 0.3

        case .sad:
            blendShapes[.browDownLeft] = 0.6
            blendShapes[.browDownRight] = 0.6
            blendShapes[.mouthFrownLeft] = 0.5
            blendShapes[.mouthFrownRight] = 0.5

        case .angry:
            blendShapes[.browDownLeft] = 0.8
            blendShapes[.browDownRight] = 0.8
            blendShapes[.jawForward] = 0.4

        // ... more emotions
        }

        // Layer speaking animation
        if speaking {
            let lipSync = generateLipSync(audioWaveform: currentAudio)
            blendShapes.merge(lipSync) { $1 } // Speech overrides
        }

        // Apply to character
        character.applyBlendShapes(blendShapes)
    }

    // Procedural idle animations
    func generateIdleAnimation(character: Entity) -> AnimationResource {
        // Subtle breathing
        // Occasional blinks
        // Weight shifts
        // Eye movements
    }
}
```

---

## 7. AI System Specifications

### Character AI Implementation

```swift
import CoreML

class CharacterAIEngine {
    // Core ML model for dialogue generation
    private var dialogueModel: MLModel

    // Personality parameters (Big Five)
    struct Personality: Codable {
        var openness: Float        // 0-1
        var conscientiousness: Float
        var extraversion: Float
        var agreeableness: Float
        var neuroticism: Float

        // Story traits
        var loyalty: Float
        var deception: Float
        var vulnerability: Float
    }

    // Emotional state (dynamic)
    struct EmotionalState: Codable {
        var currentEmotion: Emotion
        var intensity: Float
        var trust: Float           // Trust in player
        var stress: Float
        var attraction: Float
        var fear: Float

        var history: [EmotionalEvent]
    }

    // Generate contextual dialogue
    func generateDialogue(
        context: StoryContext,
        personality: Personality,
        emotion: EmotionalState
    ) async throws -> String {
        // 1. Prepare input features
        let input = DialogueInput(
            recentEvents: context.recentEvents,
            relationship: context.relationshipLevel,
            personality: personality,
            emotion: emotion,
            narrativePhase: context.phase
        )

        // 2. Run Core ML inference
        let output = try await dialogueModel.prediction(from: input)

        // 3. Post-process for character voice
        let dialogue = applyCharacterVoice(
            output.generatedText,
            personality: personality
        )

        return dialogue
    }

    // Update emotional state based on events
    func updateEmotionalState(
        current: EmotionalState,
        event: StoryEvent
    ) -> EmotionalState {
        var new = current

        // Event impacts
        switch event {
        case .playerChoice(let choice):
            if choice.isPositive {
                new.trust += 0.1
                new.stress -= 0.05
            } else {
                new.trust -= 0.15
                new.stress += 0.1
            }

        case .revelation(let secret):
            new.stress += 0.2
            new.fear += 0.15

        // ... more event types
        }

        // Clamp values
        new.trust = max(0, min(1, new.trust))
        new.stress = max(0, min(1, new.stress))

        // Record event
        new.history.append(EmotionalEvent(
            timestamp: Date(),
            trigger: event,
            emotionalChange: new - current
        ))

        return new
    }
}
```

### Story Director AI

```swift
class StoryDirectorAI {
    // Pacing controller
    func adjustPacing(
        currentTension: Float,
        playerEngagement: Float,
        sessionDuration: TimeInterval
    ) -> PacingAdjustment {
        var adjustment = PacingAdjustment()

        // Too much tension for too long → ease up
        if currentTension > 0.7 && sessionDuration > 30.minutes {
            adjustment.tensionDelta = -0.1
            adjustment.insertBreatherMoment = true
        }

        // Player disengaged → introduce surprise
        if playerEngagement < 0.4 {
            adjustment.triggerSurpriseEvent = true
            adjustment.tensionDelta = 0.15
        }

        // Approaching climax
        if isNearClimax() {
            adjustment.acceleratePlot = true
            adjustment.tensionDelta = 0.2
        }

        return adjustment
    }

    // Branch selection based on player patterns
    func selectBranch(
        availableBranches: [StoryBranch],
        playerHistory: [Choice]
    ) -> StoryBranch {
        // Analyze player's choice patterns
        let archetype = analyzePlayerArchetype(playerHistory)

        // Find best matching branch
        let scored = availableBranches.map { branch in
            (branch, calculateFitScore(branch, archetype))
        }

        // Weight towards highest fit with some randomness
        return weightedRandom(scored)
    }
}
```

### Emotion Recognition

```swift
import ARKit

class EmotionRecognitionSystem {
    private var faceTracker: ARFaceTracker

    // Detect player emotion from facial expressions
    func detectEmotion(
        faceAnchor: ARFaceAnchor
    ) async -> Emotion {
        let blendShapes = faceAnchor.blendShapes

        // Analyze blend shapes
        let smileAmount =
            (blendShapes[.mouthSmileLeft] ?? 0) +
            (blendShapes[.mouthSmileRight] ?? 0)

        let frownAmount =
            (blendShapes[.mouthFrownLeft] ?? 0) +
            (blendShapes[.mouthFrownRight] ?? 0)

        let eyebrowRaise =
            (blendShapes[.browInnerUp] ?? 0) +
            (blendShapes[.browOuterUpLeft] ?? 0) +
            (blendShapes[.browOuterUpRight] ?? 0)

        let eyebrowFurrow =
            (blendShapes[.browDownLeft] ?? 0) +
            (blendShapes[.browDownRight] ?? 0)

        // Determine dominant emotion
        if smileAmount > 0.5 {
            return .happy
        } else if frownAmount > 0.4 {
            return .sad
        } else if eyebrowFurrow > 0.6 {
            return .angry
        } else if eyebrowRaise > 0.7 {
            return .surprised
        } else {
            return .neutral
        }
    }

    // Track engagement through gaze
    func measureEngagement(
        gazeHistory: [GazePoint]
    ) -> Float {
        // Looking at characters/story → high engagement
        // Looking away → low engagement
        // Rapid eye movements → confusion or overwhelm
    }
}
```

---

## 8. Networking & Multiplayer

### SharePlay Integration

```swift
import GroupActivities

struct StoryWatchingActivity: GroupActivity {
    let storyID: UUID
    let metadata: GroupActivityMetadata

    init(story: Story) {
        self.storyID = story.id

        var metadata = GroupActivityMetadata()
        metadata.title = story.title
        metadata.type = .watchTogether
        metadata.fallbackURL = story.fallbackURL

        self.metadata = metadata
    }
}

class SharePlayManager {
    private var groupSession: GroupSession<StoryWatchingActivity>?
    private var messenger: GroupSessionMessenger?

    // Start shared story session
    func startSharedSession(story: Story) async throws {
        let activity = StoryWatchingActivity(story: story)

        switch await activity.prepareForActivation() {
        case .activationPreferred:
            _ = try await activity.activate()
        case .cancelled:
            return
        @unknown default:
            return
        }
    }

    // Sync story state
    func syncChoice(_ choice: Choice) async throws {
        guard let messenger = messenger else { return }

        try await messenger.send(
            ChoiceSyncMessage(
                playerID: localPlayerID,
                choice: choice,
                timestamp: Date()
            )
        )
    }

    // Receive synced choices
    func observeSharedChoices() {
        guard let messenger = messenger else { return }

        Task {
            for await (message, _) in messenger.messages(
                of: ChoiceSyncMessage.self
            ) {
                await handleRemoteChoice(message.choice)
            }
        }
    }
}
```

---

## 9. Performance Requirements

### Frame Rate Requirements

```yaml
Target Frame Rates:
  Minimum: 90 FPS (11.1ms per frame)
  Target: 90 FPS sustained
  Never Below: 60 FPS (16.7ms per frame)

Frame Budget:
  CPU: 8ms
  GPU: 8ms
  Total: 11ms (comfortable margin)

Per-Frame Budget:
  Input: 1ms
  AI Update: 5ms
  Game Logic: 2ms
  Physics: 1ms
  Animation: 1ms
  Audio: 1ms
  Reserve: 1ms
```

### Memory Budget

```yaml
Total Budget: 2GB maximum

Breakdown:
  Character Models: 500MB
    - 3 characters loaded: ~150MB each
    - LOD variants included

  Textures: 400MB
    - 4K for close characters
    - 2K for distant
    - Foveated optimization

  Audio: 200MB
    - Streaming from disk
    - 3 simultaneous voices
    - Ambient loops

  AI Models: 150MB
    - Dialogue model: 100MB
    - Emotion recognition: 50MB

  Story Data: 100MB
    - Current chapter
    - Nearby branches

  Runtime: 250MB
    - Game state
    - ECS entities
    - Render targets

  Reserve: 400MB
    - Safety margin
    - Temporary allocations
```

### Battery Life Target

```yaml
Target: 2.5 hours minimum per charge
Strategy:
  - Thermal management
  - Dynamic quality adjustment
  - Efficient asset streaming
  - Background task minimization
```

### Optimization Techniques

```swift
class PerformanceManager {
    // Dynamic quality adjustment
    func adjustQuality() {
        let fps = getCurrentFPS()

        if fps < 85 {
            // Reduce quality
            characterLODSystem.decreaseLOD()
            particleSystem.reduceParticles()
            shadowQuality.decrease()
        } else if fps > 95 && thermalState == .nominal {
            // Can increase quality
            characterLODSystem.increaseLOD()
        }
    }

    // Predictive loading
    func preloadUpcoming() async {
        let nextScenes = storyDirector.getPossibleNextScenes()

        for scene in nextScenes {
            // Load in background
            await assetLoader.preload(scene, priority: .low)
        }
    }

    // Asset streaming
    func streamAssets() {
        // Load high-res as needed
        // Unload distant content
        // Progressive quality increase
    }
}
```

---

## 10. Testing Requirements

### Unit Tests

```swift
import XCTest

class DialogueSystemTests: XCTestCase {
    func testChoiceBranching() {
        let dialogue = DialogueSystem()
        let node = createTestNode()

        XCTAssertEqual(node.responses.count, 3)
        XCTAssertEqual(node.responses[0].nextNodeID, expectedNextID)
    }

    func testEmotionalImpact() {
        // Test that choices affect relationship
    }
}

class CharacterAITests: XCTestCase {
    func testPersonalityConsistency() {
        // Character acts according to personality
    }

    func testEmotionalProgression() {
        // Emotions evolve realistically
    }
}

class SpatialSystemTests: XCTestCase {
    func testCharacterNavigation() {
        // Characters navigate around obstacles
    }

    func testAnchorPersistence() {
        // Anchors save and restore correctly
    }
}
```

### Performance Tests

```swift
class PerformanceTests: XCTestCase {
    func testFrameRate() {
        measure {
            gameLoop.update(deltaTime: 1.0/90.0)
        }
        // Must complete in < 11ms
    }

    func testMemoryUsage() {
        let initialMemory = getCurrentMemoryUsage()

        // Load full scene
        sceneManager.loadScene(testScene)

        let peakMemory = getCurrentMemoryUsage()
        let usage = peakMemory - initialMemory

        XCTAssertLessThan(usage, 2_000_000_000) // 2GB
    }
}
```

### Spatial Tests

```swift
class SpatialTestCase: XCTestCase {
    func testRoomAnalysis() async {
        let analyzer = RoomAnalyzer()
        let features = await analyzer.analyzeRoom()

        XCTAssertNotNil(features.floorPlane)
        XCTAssertGreaterThan(features.walls.count, 0)
    }

    func testCharacterPlacement() {
        // Character appears in expected position
        // Within room boundaries
        // Natural furniture usage
    }
}
```

---

## 11. Security & Privacy

### Privacy Protections

```swift
class PrivacyManager {
    // All spatial data stays local
    func processRoomData(_ data: RoomData) {
        // Process on-device only
        // Never upload to servers
        // Delete when app closes (optional)
    }

    // Dialogue generation on-device
    func generateDialogue() async -> String {
        // Core ML runs locally
        // No data leaves device
        // Private by default
    }

    // Optional iCloud sync (encrypted)
    func syncToCloud(_ storyState: StoryState) async {
        // End-to-end encrypted
        // User can disable
        // Can delete all cloud data
    }
}
```

### Data Collection

```yaml
Data Collected:
  Required (on-device only):
    - Room layout (for character placement)
    - Choice history (for story branching)
    - Save game state

  Optional (cloud sync):
    - Encrypted story progress
    - Achievement status

  Never Collected:
    - Identifiable spatial data
    - Room photos/videos
    - Personal conversations
    - Biometric data (face tracking local only)

User Controls:
  - Delete all data
  - Disable cloud sync
  - Local-only mode
  - Export save data
```

---

## Implementation Priority

### Phase 1: Core (P0)
- Basic dialogue system
- Choice presentation
- Character rendering
- Room detection
- Save/load

### Phase 2: Enhanced (P1)
- AI dialogue generation
- Emotion recognition
- Advanced animations
- Spatial audio
- Multi-branch stories

### Phase 3: Polish (P2)
- SharePlay multiplayer
- Advanced facial animations
- Dynamic music
- Creator tools
- Cloud features

---

**This technical specification provides the foundation for implementing a groundbreaking narrative experience that leverages visionOS's unique capabilities while maintaining exceptional performance and user privacy.**
