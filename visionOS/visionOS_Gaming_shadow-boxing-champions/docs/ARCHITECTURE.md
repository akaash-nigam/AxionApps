# Shadow Boxing Champions - Technical Architecture

## Document Overview

This document describes the comprehensive technical architecture for Shadow Boxing Champions, a professional-grade boxing training and competition game for Apple Vision Pro. The architecture is designed to support high-performance spatial gaming with AI-driven opponents, real-time motion analysis, and immersive training experiences.

**Version:** 1.0
**Last Updated:** 2025-11-19
**Target Platform:** visionOS 2.0+

---

## Table of Contents

1. [System Overview](#system-overview)
2. [Game Architecture](#game-architecture)
3. [visionOS-Specific Gaming Patterns](#visionos-specific-gaming-patterns)
4. [Data Models and Schemas](#data-models-and-schemas)
5. [RealityKit Gaming Components](#realitykit-gaming-components)
6. [ARKit Integration](#arkit-integration)
7. [Physics and Collision Systems](#physics-and-collision-systems)
8. [AI Opponent Architecture](#ai-opponent-architecture)
9. [Audio Architecture](#audio-architecture)
10. [Multiplayer Architecture](#multiplayer-architecture)
11. [Performance Optimization](#performance-optimization)
12. [Save/Load System](#saveload-system)

---

## 1. System Overview

### 1.1 Architecture Principles

- **Entity-Component-System (ECS)**: Leveraging RealityKit's native ECS for game entities
- **Reactive State Management**: SwiftUI + Combine for UI and game state
- **Modular Design**: Clear separation between game logic, rendering, and platform services
- **Performance First**: 90 FPS target with thermal management
- **AI-Driven**: Machine learning for opponent behavior and technique analysis

### 1.2 High-Level System Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                     Application Layer                        │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │  Game Views  │  │  Menu Views  │  │  HUD Views   │      │
│  │   (SwiftUI)  │  │   (SwiftUI)  │  │  (SwiftUI)   │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└─────────────────────────────────────────────────────────────┘
                            │
┌─────────────────────────────────────────────────────────────┐
│                    Game Coordinator Layer                    │
│  ┌────────────────────────────────────────────────────────┐ │
│  │              GameCoordinator (State Machine)            │ │
│  └────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
                            │
┌─────────────────────────────────────────────────────────────┐
│                      Game Systems Layer                      │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐   │
│  │  Combat  │  │ Physics  │  │   AI     │  │  Audio   │   │
│  │  System  │  │  System  │  │  System  │  │  System  │   │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘   │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐   │
│  │  Input   │  │  Score   │  │ Training │  │ Network  │   │
│  │  System  │  │  System  │  │  System  │  │  System  │   │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘   │
└─────────────────────────────────────────────────────────────┘
                            │
┌─────────────────────────────────────────────────────────────┐
│                   RealityKit/ARKit Layer                     │
│  ┌────────────────────────────────────────────────────────┐ │
│  │  RealityKit Scene (Entities, Components, Systems)      │ │
│  ├────────────────────────────────────────────────────────┤ │
│  │  ARKit (Hand Tracking, Body Tracking, Scene Mapping)   │ │
│  └────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
                            │
┌─────────────────────────────────────────────────────────────┐
│                      Platform Services                       │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐   │
│  │HealthKit │  │ CloudKit │  │ GameKit  │  │  iCloud  │   │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘   │
└─────────────────────────────────────────────────────────────┘
```

### 1.3 Technology Stack

- **Language**: Swift 6.0+
- **UI Framework**: SwiftUI
- **3D Rendering**: RealityKit
- **Spatial Tracking**: ARKit
- **Platform**: visionOS 2.0+
- **Concurrency**: Swift Structured Concurrency (async/await, Actor model)
- **AI/ML**: Core ML, Create ML
- **Persistence**: SwiftData
- **Networking**: MultipeerConnectivity, URLSession
- **Audio**: AVFAudioEngine with Spatial Audio
- **Health**: HealthKit integration

---

## 2. Game Architecture

### 2.1 Game Loop

The game follows a standard game loop pattern optimized for visionOS:

```swift
// Conceptual Game Loop
class GameLoop {
    private var updateTask: Task<Void, Never>?
    private var targetFrameTime: TimeInterval = 1.0 / 90.0 // 90 FPS

    func start() {
        updateTask = Task {
            var lastTime = CACurrentMediaTime()

            while !Task.isCancelled {
                let currentTime = CACurrentMediaTime()
                let deltaTime = currentTime - lastTime

                // Process input
                await inputSystem.update(deltaTime: deltaTime)

                // Update game logic
                await gameState.update(deltaTime: deltaTime)

                // Update AI
                await aiSystem.update(deltaTime: deltaTime)

                // Update physics
                await physicsSystem.update(deltaTime: deltaTime)

                // Update combat
                await combatSystem.update(deltaTime: deltaTime)

                // Update audio
                await audioSystem.update(deltaTime: deltaTime)

                // RealityKit handles rendering automatically

                lastTime = currentTime

                // Frame rate limiting
                let elapsed = CACurrentMediaTime() - currentTime
                let sleepTime = max(0, targetFrameTime - elapsed)
                try? await Task.sleep(nanoseconds: UInt64(sleepTime * 1_000_000_000))
            }
        }
    }
}
```

### 2.2 State Management

#### Game State Machine

```swift
enum GameState {
    case mainMenu
    case training(mode: TrainingMode)
    case sparring(opponent: Opponent, round: Int)
    case tournament(bracket: TournamentBracket)
    case paused
    case results(MatchResults)
}

@MainActor
class GameStateManager: ObservableObject {
    @Published var currentState: GameState = .mainMenu
    @Published var playerProfile: PlayerProfile
    @Published var settings: GameSettings

    func transition(to newState: GameState) async {
        await handleStateExit(currentState)
        currentState = newState
        await handleStateEntry(newState)
    }
}
```

#### Observable Game Model

```swift
@Observable
class GameModel {
    var state: GameState
    var currentMatch: Match?
    var player: Player
    var opponent: AIOpponent?

    // Performance metrics
    var frameRate: Double = 0
    var renderTime: TimeInterval = 0

    // Training data
    var trainingSession: TrainingSession?
    var techniqueAnalysis: TechniqueAnalysis?
}
```

### 2.3 Scene Graph Architecture

```
RootEntity (Anchored to World)
│
├── GameEnvironment
│   ├── BoxingRing
│   │   ├── RingFloor
│   │   ├── RingRopes (4x)
│   │   └── RingCorners (4x)
│   │
│   ├── Lighting
│   │   ├── AmbientLight
│   │   ├── DirectionalLight
│   │   └── SpotLights (4x)
│   │
│   └── Crowd (Particles/LOD)
│
├── PlayerSpace
│   ├── VirtualGloves (2x)
│   ├── ShadowPlayer (Visual feedback)
│   └── TrainingTools
│       ├── HeavyBag
│       ├── SpeedBag
│       └── FocusMitts
│
├── OpponentSpace
│   ├── OpponentModel
│   │   ├── BodyMesh
│   │   ├── AnimationController
│   │   └── DamageIndicators
│   │
│   └── OpponentEffects
│       ├── SweatParticles
│       ├── ImpactEffects
│       └── MovementTrails
│
└── UISpace (World-locked)
    ├── HUD
    │   ├── HealthBars
    │   ├── RoundTimer
    │   ├── ScoreDisplay
    │   └── ComboCounter
    │
    └── Feedback
        ├── TechniqueIndicators
        ├── PowerMeter
        └── FormCorrection
```

---

## 3. visionOS-Specific Gaming Patterns

### 3.1 Immersive Space Management

```swift
@main
struct ShadowBoxingApp: App {
    @State private var immersionStyle: ImmersionStyle = .mixed

    var body: some Scene {
        // Main menu in window
        WindowGroup {
            MenuView()
        }

        // Game in immersive space
        ImmersiveSpace(id: "GameSpace") {
            GameView()
        }
        .immersionStyle(selection: $immersionStyle, in: .mixed, .progressive, .full)
    }
}
```

### 3.2 Spatial Anchoring Strategy

```swift
actor SpatialAnchorManager {
    private var ringAnchor: AnchorEntity?
    private var playerAnchor: AnchorEntity?

    func setupGameSpace(in scene: RealityKit.Scene) async throws {
        // Anchor ring to world space
        ringAnchor = AnchorEntity(.plane(.horizontal,
                                         classification: .floor,
                                         minimumBounds: [2.0, 2.0]))

        // Player anchor at head position
        playerAnchor = AnchorEntity(.head)

        scene.addAnchor(ringAnchor!)
        scene.addAnchor(playerAnchor!)
    }
}
```

### 3.3 Hand Tracking Integration

```swift
actor HandTrackingSystem: System {
    func update(context: SceneUpdateContext) async {
        // Access hand tracking data
        guard let leftHand = await ARKitSession.shared.leftHand,
              let rightHand = await ARKitSession.shared.rightHand else {
            return
        }

        // Analyze punch gestures
        let leftPunch = analyzePunchGesture(hand: leftHand)
        let rightPunch = analyzePunchGesture(hand: rightHand)

        // Update virtual gloves
        await updateGlovePositions(left: leftHand, right: rightHand)

        // Detect punch events
        if let punch = leftPunch ?? rightPunch {
            await combatSystem.processPunch(punch)
        }
    }

    private func analyzePunchGesture(hand: HandAnchor) -> Punch? {
        // Analyze hand velocity, position, and orientation
        let velocity = hand.velocity
        let position = hand.transform.translation

        // Detect punch threshold
        if velocity.magnitude > punchVelocityThreshold {
            return classifyPunch(hand: hand)
        }

        return nil
    }
}
```

### 3.4 Room-Scale Adaptation

```swift
actor RoomScaleManager {
    private var availableSpace: SIMD3<Float> = [3.0, 3.0, 2.5]

    func calibrateSpace() async {
        // Scan room dimensions
        let sceneReconstruction = await ARKitSession.shared.sceneReconstruction

        // Calculate safe play area
        let bounds = calculateSafePlayArea(from: sceneReconstruction)
        availableSpace = bounds

        // Scale ring to fit
        await scaleBoxingRing(to: availableSpace)
    }

    func setupSafetyBoundaries() async {
        // Create visual and haptic boundaries
        let boundaryEntity = createBoundaryVisualization()
        // Add to scene
    }
}
```

---

## 4. Data Models and Schemas

### 4.1 Player Data

```swift
@Model
class PlayerProfile {
    var id: UUID
    var name: String
    var avatar: AvatarConfiguration

    // Skills
    var skillLevel: SkillLevel
    var punchPower: Float
    var punchSpeed: Float
    var defense: Float
    var stamina: Float

    // Progress
    var experience: Int
    var level: Int
    var wins: Int
    var losses: Int

    // Statistics
    var totalPunches: Int
    var totalTrainingTime: TimeInterval
    var caloriesBurned: Double

    // Health
    var healthPermission: Bool
    var heartRateData: [HeartRateReading]
}

enum SkillLevel: String, Codable {
    case beginner
    case intermediate
    case advanced
    case professional
}
```

### 4.2 Combat Data

```swift
struct Punch {
    let id: UUID
    let type: PunchType
    let hand: Hand
    let position: SIMD3<Float>
    let velocity: SIMD3<Float>
    let power: Float
    let accuracy: Float
    let timestamp: TimeInterval

    var damage: Float {
        power * accuracy
    }
}

enum PunchType: String, Codable {
    case jab
    case cross
    case hook
    case uppercut
    case bodyShot
}

enum Hand {
    case left
    case right
}

struct DefensiveMove {
    let type: DefenseType
    let success: Bool
    let timestamp: TimeInterval
}

enum DefenseType {
    case block
    case parry
    case slip
    case duck
    case dodge
}
```

### 4.3 Match Data

```swift
@Model
class Match {
    var id: UUID
    var date: Date
    var opponent: OpponentProfile
    var rounds: [Round]
    var result: MatchResult
    var playerStats: MatchStatistics
    var opponentStats: MatchStatistics
}

struct Round {
    var number: Int
    var duration: TimeInterval
    var playerDamageDealt: Float
    var playerDamageTaken: Float
    var punchesThrown: Int
    var punchesLanded: Int
    var defensiveSuccesses: Int
    var events: [RoundEvent]
}

struct MatchStatistics {
    var totalPunches: Int
    var punchesLanded: Int
    var accuracy: Float
    var powerPunches: Int
    var averagePunchPower: Float
    var defensiveRating: Float
    var caloriesBurned: Double
}
```

### 4.4 Training Data

```swift
@Model
class TrainingSession {
    var id: UUID
    var date: Date
    var mode: TrainingMode
    var duration: TimeInterval
    var exercisesCompleted: [Exercise]
    var techniqueAnalysis: TechniqueAnalysis
    var fitnessMetrics: FitnessMetrics
}

enum TrainingMode: String, Codable {
    case techniqueDrills
    case comboChallenges
    case defensiveTraining
    case sparring
    case conditioning
}

struct TechniqueAnalysis {
    var jabForm: Float  // 0.0 - 1.0
    var crossForm: Float
    var hookForm: Float
    var uppercutForm: Float
    var stance: Float
    var footwork: Float
    var guardPosition: Float
    var improvements: [String]
}

struct FitnessMetrics {
    var averageHeartRate: Double
    var maxHeartRate: Double
    var caloriesBurned: Double
    var punchesPerMinute: Int
    var activeTime: TimeInterval
    var restTime: TimeInterval
}
```

### 4.5 AI Opponent Data

```swift
@Model
class OpponentProfile {
    var id: UUID
    var name: String
    var appearance: OpponentAppearance
    var difficulty: Difficulty
    var fightingStyle: FightingStyle
    var personality: AIPersonality
    var stats: OpponentStats
}

enum FightingStyle: String, Codable {
    case boxer       // Traditional boxing, defensive
    case brawler     // Aggressive, power punches
    case counterpuncher  // Defensive, capitalizes on mistakes
    case swarmer     // Close range, high volume
    case outfighter  // Long range, movement
}

struct AIPersonality {
    var aggression: Float      // 0.0 - 1.0
    var adaptability: Float    // How quickly they learn
    var patience: Float        // Willingness to wait for openings
    var riskTaking: Float      // Tendency for risky moves
    var taunting: Bool
}

struct OpponentStats {
    var health: Float
    var punchPower: Float
    var punchSpeed: Float
    var defense: Float
    var stamina: Float
    var reactionTime: TimeInterval
}
```

---

## 5. RealityKit Gaming Components

### 5.1 Custom Components

```swift
// Combat components
struct HealthComponent: Component {
    var current: Float
    var maximum: Float

    var percentage: Float {
        current / maximum
    }
}

struct DamageComponent: Component {
    var baseDamage: Float
    var damageType: DamageType
    var hitboxRadius: Float
}

enum DamageType {
    case light
    case medium
    case heavy
}

// Movement components
struct VelocityComponent: Component {
    var linear: SIMD3<Float>
    var angular: SIMD3<Float>
}

struct StaminaComponent: Component {
    var current: Float
    var maximum: Float
    var recoveryRate: Float
    var depletionRate: Float
}

// AI components
struct AIBehaviorComponent: Component {
    var currentState: AIState
    var target: Entity?
    var decisionCooldown: TimeInterval
}

enum AIState {
    case idle
    case approaching
    case attacking
    case defending
    case retreating
    case stunned
}

// Animation components
struct AnimationStateComponent: Component {
    var currentAnimation: String
    var nextAnimation: String?
    var transitionTime: TimeInterval
}

// Audio components
struct AudioSourceComponent: Component {
    var clips: [AudioClip]
    var spatialSettings: SpatialAudioSettings
}

struct AudioClip {
    var name: String
    var resource: AudioFileResource
    var volume: Float
    var loop: Bool
}
```

### 5.2 Entity Archetypes

```swift
// Player glove entities
extension Entity {
    static func createPlayerGlove(hand: Hand) -> Entity {
        let glove = Entity()

        // Visual model
        let mesh = MeshResource.generateBox(size: 0.15)
        let material = SimpleMaterial(color: .red, isMetallic: false)
        glove.components.set(ModelComponent(mesh: mesh, materials: [material]))

        // Combat properties
        glove.components.set(DamageComponent(
            baseDamage: 10.0,
            damageType: .light,
            hitboxRadius: 0.08
        ))

        // Collision
        glove.components.set(CollisionComponent(
            shapes: [.generateSphere(radius: 0.08)],
            isStatic: false
        ))

        return glove
    }
}

// Opponent entity
extension Entity {
    static func createOpponent(profile: OpponentProfile) async -> Entity {
        let opponent = Entity()

        // Load model
        let model = try? await ModelEntity.load(named: profile.appearance.modelName)
        opponent.addChild(model!)

        // Add components
        opponent.components.set(HealthComponent(
            current: 100.0,
            maximum: 100.0
        ))

        opponent.components.set(AIBehaviorComponent(
            currentState: .idle,
            target: nil,
            decisionCooldown: 0.0
        ))

        opponent.components.set(StaminaComponent(
            current: 100.0,
            maximum: 100.0,
            recoveryRate: 5.0,
            depletionRate: 2.0
        ))

        return opponent
    }
}
```

### 5.3 Systems

```swift
// Combat system
struct CombatSystem: System {
    static let query = EntityQuery(where: .has(HealthComponent.self))

    func update(context: SceneUpdateContext) {
        let entities = context.scene.performQuery(Self.query)

        for entity in entities {
            // Process damage
            if var health = entity.components[HealthComponent.self] {
                // Check for collisions with damage sources
                if let collision = checkCollisions(entity: entity, context: context) {
                    applyDamage(to: &health, from: collision)
                    entity.components[HealthComponent.self] = health
                }

                // Check for knockout
                if health.current <= 0 {
                    handleKnockout(entity: entity)
                }
            }
        }
    }
}

// Stamina system
struct StaminaSystem: System {
    static let query = EntityQuery(where: .has(StaminaComponent.self))

    func update(context: SceneUpdateContext) {
        let entities = context.scene.performQuery(Self.query)
        let deltaTime = Float(context.deltaTime)

        for entity in entities {
            if var stamina = entity.components[StaminaComponent.self] {
                // Regenerate stamina
                stamina.current = min(
                    stamina.maximum,
                    stamina.current + stamina.recoveryRate * deltaTime
                )

                entity.components[StaminaComponent.self] = stamina
            }
        }
    }
}
```

---

## 6. ARKit Integration

### 6.1 Hand Tracking Pipeline

```swift
actor HandTrackingManager {
    private var session: ARKitSession?
    private var handTracking: HandTrackingProvider?

    func start() async throws {
        session = ARKitSession()
        handTracking = HandTrackingProvider()

        try await session?.run([handTracking!])
    }

    func getHandData() async -> (left: HandAnchor?, right: HandAnchor?) {
        guard let handTracking = handTracking else {
            return (nil, nil)
        }

        var leftHand: HandAnchor?
        var rightHand: HandAnchor?

        for await update in handTracking.anchorUpdates {
            switch update.event {
            case .added, .updated:
                let anchor = update.anchor
                if anchor.chirality == .left {
                    leftHand = anchor
                } else {
                    rightHand = anchor
                }
            default:
                break
            }
        }

        return (leftHand, rightHand)
    }
}
```

### 6.2 Body Tracking for Stance Analysis

```swift
actor BodyTrackingManager {
    private var session: ARKitSession?
    private var bodyTracking: BodyTrackingProvider?

    func start() async throws {
        session = ARKitSession()
        bodyTracking = BodyTrackingProvider()

        try await session?.run([bodyTracking!])
    }

    func analyzeStance() async -> StanceAnalysis {
        guard let bodyTracking = bodyTracking else {
            return StanceAnalysis.default
        }

        // Get skeleton data
        for await update in bodyTracking.anchorUpdates {
            if case .updated = update.event {
                let skeleton = update.anchor.skeleton
                return evaluateStance(skeleton: skeleton)
            }
        }

        return StanceAnalysis.default
    }

    private func evaluateStance(skeleton: Skeleton) -> StanceAnalysis {
        // Analyze joint positions
        let hipAlignment = checkHipAlignment(skeleton)
        let shoulderPosition = checkShoulderPosition(skeleton)
        let footPlacement = checkFootPlacement(skeleton)

        return StanceAnalysis(
            score: calculateScore(hip: hipAlignment, shoulder: shoulderPosition, foot: footPlacement),
            feedback: generateFeedback(hip: hipAlignment, shoulder: shoulderPosition, foot: footPlacement)
        )
    }
}

struct StanceAnalysis {
    var score: Float
    var feedback: [String]

    static let `default` = StanceAnalysis(score: 0.5, feedback: [])
}
```

### 6.3 Scene Understanding

```swift
actor SceneUnderstandingManager {
    private var session: ARKitSession?
    private var sceneReconstruction: SceneReconstructionProvider?
    private var planeDetection: PlaneDetectionProvider?

    func start() async throws {
        session = ARKitSession()
        sceneReconstruction = SceneReconstructionProvider()
        planeDetection = PlaneDetectionProvider(alignments: [.horizontal])

        try await session?.run([sceneReconstruction!, planeDetection!])
    }

    func findFloorPlane() async -> PlaneAnchor? {
        guard let planeDetection = planeDetection else {
            return nil
        }

        for await update in planeDetection.anchorUpdates {
            if case .added = update.event {
                let plane = update.anchor
                if plane.classification == .floor {
                    return plane
                }
            }
        }

        return nil
    }

    func getSafePlayArea() async -> SIMD3<Float> {
        // Calculate safe area based on room reconstruction
        return [3.0, 3.0, 2.5] // Default fallback
    }
}
```

---

## 7. Physics and Collision Systems

### 7.1 Physics Architecture

```swift
actor PhysicsManager {
    private var rigidBodies: [UUID: RigidBody] = [:]
    private var colliders: [UUID: Collider] = [:]

    func update(deltaTime: TimeInterval) async {
        // Update rigid body physics
        for (id, var body) in rigidBodies {
            // Apply forces
            body.velocity += body.acceleration * Float(deltaTime)
            body.position += body.velocity * Float(deltaTime)

            // Apply drag
            body.velocity *= 0.98

            rigidBodies[id] = body
        }

        // Detect collisions
        await detectCollisions()
    }

    private func detectCollisions() async {
        // Broad phase: spatial hash grid
        let grid = buildSpatialGrid()

        // Narrow phase: detailed collision detection
        for (id, collider) in colliders {
            let nearbyColliders = grid.query(collider.bounds)

            for other in nearbyColliders where other.id != id {
                if let collision = testCollision(collider, other) {
                    await handleCollision(collision)
                }
            }
        }
    }
}

struct RigidBody {
    var id: UUID
    var position: SIMD3<Float>
    var velocity: SIMD3<Float>
    var acceleration: SIMD3<Float>
    var mass: Float
    var restitution: Float  // Bounciness
}

struct Collider {
    var id: UUID
    var shape: ColliderShape
    var bounds: BoundingBox
    var isTrigger: Bool
}

enum ColliderShape {
    case sphere(radius: Float)
    case box(size: SIMD3<Float>)
    case capsule(radius: Float, height: Float)
}
```

### 7.2 Punch Physics

```swift
struct PunchPhysics {
    static func calculateDamage(punch: Punch, target: Entity) -> Float {
        // Base damage from velocity
        let velocityMagnitude = simd_length(punch.velocity)
        let baseDamage = velocityMagnitude * 5.0

        // Multiplier from punch type
        let typeMultiplier: Float = switch punch.type {
        case .jab: 1.0
        case .cross: 1.5
        case .hook: 1.3
        case .uppercut: 1.6
        case .bodyShot: 1.2
        }

        // Critical hit check (proper form)
        let criticalMultiplier = punch.accuracy > 0.9 ? 1.5 : 1.0

        return baseDamage * typeMultiplier * criticalMultiplier
    }

    static func calculateImpactForce(punch: Punch) -> SIMD3<Float> {
        let direction = simd_normalize(punch.velocity)
        let magnitude = simd_length(punch.velocity)
        return direction * magnitude * 10.0
    }
}
```

### 7.3 Collision Callbacks

```swift
actor CollisionHandler {
    func onPunchCollision(_ collision: Collision) async {
        guard let punchEntity = collision.entityA,
              let targetEntity = collision.entityB else {
            return
        }

        // Calculate damage
        let punch = extractPunchData(from: punchEntity)
        let damage = PunchPhysics.calculateDamage(punch: punch, target: targetEntity)

        // Apply damage
        if var health = targetEntity.components[HealthComponent.self] {
            health.current = max(0, health.current - damage)
            targetEntity.components[HealthComponent.self] = health
        }

        // Visual feedback
        await showImpactEffect(at: collision.contactPoint)

        // Audio feedback
        await playImpactSound(at: collision.contactPoint, intensity: damage / 100.0)

        // Haptic feedback
        await triggerHaptic(intensity: damage / 50.0)
    }
}
```

---

## 8. AI Opponent Architecture

### 8.1 Behavior Tree System

```swift
protocol BehaviorNode {
    func evaluate(context: AIContext) async -> NodeResult
}

enum NodeResult {
    case success
    case failure
    case running
}

struct AIContext {
    var opponent: Entity
    var player: Entity
    var match: Match
    var deltaTime: TimeInterval
}

// Composite nodes
class SequenceNode: BehaviorNode {
    var children: [BehaviorNode]

    func evaluate(context: AIContext) async -> NodeResult {
        for child in children {
            let result = await child.evaluate(context: context)
            if result != .success {
                return result
            }
        }
        return .success
    }
}

class SelectorNode: BehaviorNode {
    var children: [BehaviorNode]

    func evaluate(context: AIContext) async -> NodeResult {
        for child in children {
            let result = await child.evaluate(context: context)
            if result != .failure {
                return result
            }
        }
        return .failure
    }
}

// Action nodes
class AttackNode: BehaviorNode {
    func evaluate(context: AIContext) async -> NodeResult {
        // Check if in range
        let distance = simd_distance(
            context.opponent.position,
            context.player.position
        )

        guard distance < 2.0 else {
            return .failure
        }

        // Execute attack
        await executeAttack(context: context)
        return .success
    }
}

class DefendNode: BehaviorNode {
    func evaluate(context: AIContext) async -> NodeResult {
        // Check if player is attacking
        guard await isPlayerAttacking(context) else {
            return .failure
        }

        // Execute defense
        await executeDefense(context: context)
        return .success
    }
}
```

### 8.2 Machine Learning Integration

```swift
actor AILearningSystem {
    private var model: MLModel?

    func loadModel() async throws {
        let config = MLModelConfiguration()
        model = try await OpponentBehaviorModel.load(configuration: config).model
    }

    func predictNextAction(
        playerPosition: SIMD3<Float>,
        playerVelocity: SIMD3<Float>,
        recentPunches: [PunchType]
    ) async -> AIAction {
        guard let model = model else {
            return .idle
        }

        // Prepare input
        let input = OpponentBehaviorModelInput(
            playerX: Double(playerPosition.x),
            playerY: Double(playerPosition.y),
            playerZ: Double(playerPosition.z),
            velocityX: Double(playerVelocity.x),
            velocityY: Double(playerVelocity.y),
            velocityZ: Double(playerVelocity.z),
            recentPattern: encodePattern(recentPunches)
        )

        // Get prediction
        guard let output = try? model.prediction(from: input) else {
            return .idle
        }

        return decodeAction(output)
    }
}

enum AIAction {
    case idle
    case approach
    case retreat
    case throwJab
    case throwCross
    case throwHook
    case throwUppercut
    case block
    case dodge
}
```

### 8.3 Difficulty Scaling

```swift
struct DifficultyScaler {
    static func adjustOpponentStats(
        base: OpponentStats,
        difficulty: Difficulty,
        playerSkill: Float
    ) -> OpponentStats {
        let multiplier = difficulty.statMultiplier
        let adaptation = playerSkill * 0.5

        return OpponentStats(
            health: base.health * multiplier,
            punchPower: base.punchPower * (multiplier + adaptation),
            punchSpeed: base.punchSpeed * (multiplier + adaptation),
            defense: base.defense * (multiplier + adaptation * 0.7),
            stamina: base.stamina * multiplier,
            reactionTime: base.reactionTime / (multiplier + adaptation)
        )
    }
}

enum Difficulty: Float {
    case beginner = 0.6
    case easy = 0.8
    case medium = 1.0
    case hard = 1.3
    case expert = 1.6
    case master = 2.0

    var statMultiplier: Float {
        rawValue
    }
}
```

---

## 9. Audio Architecture

### 9.1 Spatial Audio System

```swift
actor SpatialAudioManager {
    private var engine: AVAudioEngine
    private var environment: AVAudioEnvironmentNode
    private var sources: [UUID: AVAudioPlayerNode] = [:]

    init() {
        engine = AVAudioEngine()
        environment = engine.environment

        // Configure spatial audio
        environment.renderingAlgorithm = .HRTF
        environment.distanceAttenuationParameters.distanceAttenuationModel = .inverse
        environment.distanceAttenuationParameters.referenceDistance = 1.0
        environment.distanceAttenuationParameters.maximumDistance = 50.0
        environment.distanceAttenuationParameters.rolloffFactor = 1.0
    }

    func start() throws {
        try engine.start()
    }

    func playSound(
        _ resource: AudioFileResource,
        at position: SIMD3<Float>,
        volume: Float = 1.0
    ) async {
        let player = AVAudioPlayerNode()
        engine.attach(player)

        // Connect to environment node
        engine.connect(player, to: environment, format: nil)

        // Set 3D position
        player.position = AVAudio3DPoint(
            x: position.x,
            y: position.y,
            z: position.z
        )

        // Play
        player.scheduleFile(resource.audioFile, at: nil)
        player.volume = volume
        player.play()

        // Store reference
        let id = UUID()
        sources[id] = player

        // Clean up after playback
        Task {
            try? await Task.sleep(nanoseconds: UInt64(resource.duration * 1_000_000_000))
            sources.removeValue(forKey: id)
        }
    }
}
```

### 9.2 Dynamic Music System

```swift
actor MusicManager {
    private var layers: [MusicLayer] = []
    private var currentIntensity: Float = 0.0

    func loadTrack(name: String) async throws {
        // Load layered music
        layers = [
            MusicLayer(file: "\(name)_ambient", baseVolume: 1.0),
            MusicLayer(file: "\(name)_rhythm", baseVolume: 0.0),
            MusicLayer(file: "\(name)_melody", baseVolume: 0.0),
            MusicLayer(file: "\(name)_intensity", baseVolume: 0.0)
        ]

        // Start all layers synchronized
        for layer in layers {
            await layer.play()
        }
    }

    func setIntensity(_ intensity: Float) async {
        currentIntensity = intensity

        // Crossfade layers based on intensity
        await layers[0].setVolume(max(0, 1.0 - intensity))       // Ambient
        await layers[1].setVolume(min(1.0, intensity))            // Rhythm
        await layers[2].setVolume(max(0, intensity - 0.5) * 2.0)  // Melody
        await layers[3].setVolume(max(0, intensity - 0.8) * 5.0)  // Intensity
    }
}

struct MusicLayer {
    let file: String
    let baseVolume: Float
    private let player: AVAudioPlayerNode

    func play() async {
        // Start playback
    }

    func setVolume(_ volume: Float) async {
        // Crossfade to new volume
    }
}
```

### 9.3 Impact Sound System

```swift
struct ImpactSoundSystem {
    static func playImpactSound(
        type: PunchType,
        power: Float,
        position: SIMD3<Float>,
        audioManager: SpatialAudioManager
    ) async {
        let soundName = selectImpactSound(type: type, power: power)
        let volume = calculateVolume(power: power)

        await audioManager.playSound(
            AudioFileResource(name: soundName),
            at: position,
            volume: volume
        )
    }

    private static func selectImpactSound(type: PunchType, power: Float) -> String {
        let intensity = power > 0.7 ? "heavy" : "light"
        return "impact_\(type.rawValue)_\(intensity)"
    }

    private static func calculateVolume(power: Float) -> Float {
        // Map power (0-1) to volume (0.3-1.0)
        return 0.3 + (power * 0.7)
    }
}
```

---

## 10. Multiplayer Architecture

### 10.1 Network Architecture

```swift
actor NetworkManager {
    private var session: MultipeerSession?
    private var messageQueue: [NetworkMessage] = []

    func startHosting() async throws {
        session = MultipeerSession(
            serviceName: "shadowboxing",
            identity: "host",
            maxPeers: 2
        )

        try await session?.start()
    }

    func joinSession(hostID: String) async throws {
        session = MultipeerSession(
            serviceName: "shadowboxing",
            identity: "client",
            maxPeers: 2
        )

        try await session?.connect(to: hostID)
    }

    func sendMessage(_ message: NetworkMessage) async throws {
        guard let data = try? JSONEncoder().encode(message) else {
            throw NetworkError.encodingFailed
        }

        try await session?.send(data: data, to: .all)
    }

    func receive() async throws -> NetworkMessage? {
        guard let data = try await session?.receive() else {
            return nil
        }

        return try JSONDecoder().decode(NetworkMessage.self, from: data)
    }
}

struct NetworkMessage: Codable {
    let type: MessageType
    let timestamp: TimeInterval
    let payload: Data
}

enum MessageType: String, Codable {
    case gameState
    case playerAction
    case matchStart
    case matchEnd
    case sync
}
```

### 10.2 State Synchronization

```swift
actor GameStateSynchronizer {
    private var localState: GameState
    private var remoteState: GameState?
    private var networkManager: NetworkManager

    func synchronize() async throws {
        // Send local state
        let message = NetworkMessage(
            type: .gameState,
            timestamp: CACurrentMediaTime(),
            payload: try JSONEncoder().encode(localState)
        )

        try await networkManager.sendMessage(message)

        // Receive remote state
        if let remoteMessage = try await networkManager.receive() {
            remoteState = try JSONDecoder().decode(
                GameState.self,
                from: remoteMessage.payload
            )
        }

        // Reconcile states
        await reconcileStates()
    }

    private func reconcileStates() async {
        guard let remote = remoteState else { return }

        // Server authoritative for critical state
        if await isServer() {
            // Local state is authoritative
            return
        } else {
            // Apply remote state with interpolation
            await interpolateState(from: localState, to: remote)
        }
    }
}
```

### 10.3 Lag Compensation

```swift
struct LagCompensation {
    static func predictPosition(
        current: SIMD3<Float>,
        velocity: SIMD3<Float>,
        latency: TimeInterval
    ) -> SIMD3<Float> {
        // Linear prediction
        let delta = velocity * Float(latency)
        return current + delta
    }

    static func interpolateState(
        from: GameState,
        to: GameState,
        alpha: Float
    ) -> GameState {
        // Smooth interpolation between states
        var interpolated = from

        // Interpolate positions
        interpolated.playerPosition = simd_mix(
            from.playerPosition,
            to.playerPosition,
            alpha
        )

        interpolated.opponentPosition = simd_mix(
            from.opponentPosition,
            to.opponentPosition,
            alpha
        )

        return interpolated
    }
}
```

---

## 11. Performance Optimization

### 11.1 Target Metrics

- **Frame Rate**: 90 FPS (consistent)
- **Frame Time**: < 11.1ms
- **Input Latency**: < 20ms
- **Memory**: < 2GB active
- **Thermal**: Sustained performance > 30 minutes

### 11.2 Rendering Optimization

```swift
actor RenderingOptimizer {
    private var lodSystem: LODSystem
    private var cullingSystem: CullingSystem

    func optimize(scene: RealityKit.Scene, camera: Entity) async {
        // Level of Detail
        await lodSystem.update(cameraPosition: camera.position)

        // Frustum culling
        await cullingSystem.cullEntities(scene: scene, camera: camera)

        // Occlusion culling
        await performOcclusionCulling(scene: scene)
    }
}

struct LODSystem {
    func update(cameraPosition: SIMD3<Float>) async {
        // Adjust model detail based on distance
        for entity in entities {
            let distance = simd_distance(entity.position, cameraPosition)

            let lod = switch distance {
            case 0..<2: LODLevel.high
            case 2..<5: LODLevel.medium
            case 5..<10: LODLevel.low
            default: LODLevel.none
            }

            await entity.setLOD(lod)
        }
    }
}

enum LODLevel {
    case high
    case medium
    case low
    case none
}
```

### 11.3 Memory Management

```swift
actor MemoryManager {
    private var textureCache: [String: TextureResource] = [:]
    private var modelCache: [String: ModelEntity] = [:]

    func loadTexture(named name: String) async throws -> TextureResource {
        if let cached = textureCache[name] {
            return cached
        }

        let texture = try await TextureResource.load(named: name)
        textureCache[name] = texture
        return texture
    }

    func clearUnusedAssets() async {
        // Remove assets not used in last 60 seconds
        let threshold = CACurrentMediaTime() - 60.0

        textureCache = textureCache.filter { _, texture in
            texture.lastAccessTime > threshold
        }

        modelCache = modelCache.filter { _, model in
            model.lastAccessTime > threshold
        }
    }
}
```

### 11.4 Object Pooling

```swift
actor ObjectPool<T> {
    private var available: [T] = []
    private var inUse: Set<ObjectIdentifier> = []
    private let factory: () -> T

    init(initialSize: Int, factory: @escaping () -> T) {
        self.factory = factory
        available = (0..<initialSize).map { _ in factory() }
    }

    func acquire() -> T {
        if let object = available.popLast() {
            inUse.insert(ObjectIdentifier(object as AnyObject))
            return object
        } else {
            let object = factory()
            inUse.insert(ObjectIdentifier(object as AnyObject))
            return object
        }
    }

    func release(_ object: T) {
        let id = ObjectIdentifier(object as AnyObject)
        if inUse.remove(id) != nil {
            available.append(object)
        }
    }
}

// Usage
let particlePool = ObjectPool<ParticleEntity>(initialSize: 100) {
    ParticleEntity()
}
```

---

## 12. Save/Load System

### 12.1 Persistence Architecture

```swift
@ModelActor
actor PersistenceManager {
    private let modelContext: ModelContext

    func savePlayerProfile(_ profile: PlayerProfile) async throws {
        modelContext.insert(profile)
        try modelContext.save()
    }

    func loadPlayerProfile() async throws -> PlayerProfile? {
        let descriptor = FetchDescriptor<PlayerProfile>()
        let profiles = try modelContext.fetch(descriptor)
        return profiles.first
    }

    func saveMatch(_ match: Match) async throws {
        modelContext.insert(match)
        try modelContext.save()
    }

    func loadMatches(limit: Int = 10) async throws -> [Match] {
        var descriptor = FetchDescriptor<Match>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        descriptor.fetchLimit = limit
        return try modelContext.fetch(descriptor)
    }
}
```

### 12.2 Cloud Sync

```swift
actor CloudSyncManager {
    private let container = CKContainer.default()

    func syncProfile(_ profile: PlayerProfile) async throws {
        let record = CKRecord(recordType: "PlayerProfile")
        record["name"] = profile.name
        record["level"] = profile.level
        record["experience"] = profile.experience
        record["wins"] = profile.wins
        record["losses"] = profile.losses

        let database = container.privateCloudDatabase
        try await database.save(record)
    }

    func fetchProfile() async throws -> PlayerProfile? {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "PlayerProfile", predicate: predicate)

        let database = container.privateCloudDatabase
        let results = try await database.records(matching: query)

        guard let record = results.matchResults.first?.1.get() else {
            return nil
        }

        return parseProfile(from: record)
    }
}
```

### 12.3 Auto-Save System

```swift
actor AutoSaveManager {
    private var isDirty = false
    private var lastSaveTime: TimeInterval = 0
    private let saveInterval: TimeInterval = 60.0 // Save every 60 seconds

    func markDirty() {
        isDirty = true
    }

    func update(currentTime: TimeInterval) async throws {
        guard isDirty else { return }
        guard currentTime - lastSaveTime >= saveInterval else { return }

        // Perform save
        try await saveGameState()

        isDirty = false
        lastSaveTime = currentTime
    }

    private func saveGameState() async throws {
        // Save current game state
        let state = await getCurrentGameState()
        try await PersistenceManager.shared.saveGameState(state)
    }
}
```

---

## Conclusion

This architecture provides a comprehensive foundation for Shadow Boxing Champions, designed specifically for visionOS gaming with:

- **High Performance**: 90 FPS target with thermal management
- **Spatial Computing**: Full integration with ARKit and RealityKit
- **AI-Driven**: Intelligent opponents and technique analysis
- **Scalable**: Modular design supporting future enhancements
- **Professional**: Production-ready patterns and practices

The architecture balances performance, maintainability, and user experience to create a revolutionary boxing training game for Vision Pro.

---

**Next Steps:**
1. Review TECHNICAL_SPEC.md for implementation details
2. Review DESIGN.md for UI/UX specifications
3. Review IMPLEMENTATION_PLAN.md for development roadmap
