# Shadow Boxing Champions - Technical Specifications

## Document Overview

This document provides detailed technical specifications for implementing Shadow Boxing Champions on Apple Vision Pro. It covers the complete technology stack, implementation requirements, performance targets, and testing criteria.

**Version:** 1.0
**Last Updated:** 2025-11-19
**Target Platform:** visionOS 2.0+
**Minimum Requirements:** Apple Vision Pro, visionOS 2.0, 2m x 2m play space

---

## Table of Contents

1. [Technology Stack](#technology-stack)
2. [Development Environment](#development-environment)
3. [Game Mechanics Implementation](#game-mechanics-implementation)
4. [Control Schemes](#control-schemes)
5. [Physics Specifications](#physics-specifications)
6. [Rendering Requirements](#rendering-requirements)
7. [AI and Machine Learning](#ai-and-machine-learning)
8. [Multiplayer and Networking](#multiplayer-and-networking)
9. [Performance Budgets](#performance-budgets)
10. [Audio Specifications](#audio-specifications)
11. [Health and Fitness Integration](#health-and-fitness-integration)
12. [Testing Requirements](#testing-requirements)

---

## 1. Technology Stack

### 1.1 Core Technologies

#### Programming Language
- **Swift 6.0+**
  - Strict concurrency checking enabled
  - Modern async/await patterns
  - Actor-based concurrency for thread safety
  - Value semantics for game data

#### UI Framework
- **SwiftUI**
  - Declarative UI for menus and HUD
  - @Observable macro for state management
  - Custom view modifiers for spatial UI
  - Animations using SwiftUI animation system

#### 3D Rendering
- **RealityKit**
  - Entity-Component-System architecture
  - Custom components and systems
  - PBR (Physically Based Rendering) materials
  - Particle systems for effects
  - Custom shaders where needed

#### Spatial Computing
- **ARKit**
  - Hand tracking (HandTrackingProvider)
  - Body tracking (BodyTrackingProvider) - if available
  - Scene reconstruction (SceneReconstructionProvider)
  - Plane detection (PlaneDetectionProvider)
  - World tracking (WorldTrackingProvider)

#### Game Development
- **GameplayKit**
  - State machines for game flow
  - Pathfinding for AI movement
  - Random number generation
  - Rule systems for AI decisions

### 1.2 Apple Frameworks

```swift
// Core frameworks
import SwiftUI
import RealityKit
import ARKit
import Combine

// Spatial audio
import AVFAudio
import CoreAudio
import SpatialAudio

// AI/ML
import CoreML
import CreateML
import Vision

// Persistence
import SwiftData
import CloudKit

// Health and fitness
import HealthKit
import CoreMotion

// Networking
import MultipeerConnectivity
import Network

// Analytics
import OSLog
import MetricKit
```

### 1.3 Third-Party Dependencies (Optional)

```swift
// Swift Package Manager dependencies
dependencies: [
    // Networking utilities
    .package(url: "https://github.com/apple/swift-nio.git", from: "2.0.0"),

    // Analytics (if needed)
    // .package(url: "analytics-package", from: "1.0.0"),
]
```

### 1.4 Development Tools

- **Xcode 16.0+**: Primary IDE
- **Reality Composer Pro**: 3D asset creation and editing
- **Instruments**: Performance profiling
- **Create ML**: Training AI models
- **Git**: Version control
- **TestFlight**: Beta distribution

---

## 2. Development Environment

### 2.1 Project Configuration

```swift
// Project settings
PRODUCT_NAME = Shadow Boxing Champions
PRODUCT_BUNDLE_IDENTIFIER = com.virtualfitness.shadowboxing
DEVELOPMENT_TEAM = [Team ID]

// Deployment
IPHONEOS_DEPLOYMENT_TARGET = 18.0  // visionOS 2.0
SWIFT_VERSION = 6.0
ENABLE_USER_SCRIPT_SANDBOXING = YES

// Capabilities required
INFOPLIST_KEY_NSCameraUsageDescription = "Camera access required for hand tracking"
INFOPLIST_KEY_NSMotionUsageDescription = "Motion tracking for boxing movements"
```

### 2.2 Info.plist Configuration

```xml
<key>UIRequiredDeviceCapabilities</key>
<array>
    <string>arkit</string>
    <string>hand-tracking</string>
</array>

<key>NSPrivacyAccessedAPICategoryTypes</key>
<array>
    <dict>
        <key>NSPrivacyAccessedAPIType</key>
        <string>NSPrivacyAccessedAPICategoryFileTimestamp</string>
        <key>NSPrivacyAccessedAPITypeReasons</key>
        <array>
            <string>C617.1</string>
        </array>
    </dict>
</array>

<key>UIApplicationSceneManifest</key>
<dict>
    <key>UIApplicationPreferredDefaultSceneSessionRole</key>
    <string>UIWindowSceneSessionRoleImmersiveSpaceApplication</string>
</dict>
```

### 2.3 Build Configurations

```
Debug:
- Optimization level: None (-Onone)
- Debug symbols: Yes
- Assertions: Enabled
- Logging: Verbose

Release:
- Optimization level: Optimize for Speed (-O)
- Debug symbols: Yes (dSYM)
- Assertions: Disabled
- Logging: Errors only
- Bitcode: No (not supported on visionOS)
```

---

## 3. Game Mechanics Implementation

### 3.1 Punch Detection System

#### Detection Algorithm

```swift
struct PunchDetectionSystem {
    // Configuration
    let velocityThreshold: Float = 2.5  // m/s
    let minimumExtension: Float = 0.3   // meters
    let cooldownPeriod: TimeInterval = 0.15  // seconds between punches

    func detectPunch(
        hand: HandAnchor,
        previousPosition: SIMD3<Float>,
        previousTime: TimeInterval,
        currentTime: TimeInterval
    ) -> Punch? {
        let deltaTime = Float(currentTime - previousTime)
        let currentPosition = hand.position

        // Calculate velocity
        let displacement = currentPosition - previousPosition
        let velocity = displacement / deltaTime

        // Check velocity threshold
        guard simd_length(velocity) >= velocityThreshold else {
            return nil
        }

        // Check extension (distance from shoulder)
        let shoulderPosition = estimateShoulderPosition(from: hand)
        let extension = simd_distance(currentPosition, shoulderPosition)

        guard extension >= minimumExtension else {
            return nil
        }

        // Classify punch type
        let punchType = classifyPunch(
            velocity: velocity,
            position: currentPosition,
            hand: hand.chirality
        )

        // Calculate power (0.0 - 1.0)
        let power = calculatePower(
            velocity: simd_length(velocity),
            extension: extension
        )

        // Calculate accuracy based on form
        let accuracy = analyzeForm(hand: hand, punchType: punchType)

        return Punch(
            id: UUID(),
            type: punchType,
            hand: hand.chirality == .left ? .left : .right,
            position: currentPosition,
            velocity: velocity,
            power: power,
            accuracy: accuracy,
            timestamp: currentTime
        )
    }

    private func classifyPunch(
        velocity: SIMD3<Float>,
        position: SIMD3<Float>,
        hand: HandAnchor.Chirality
    ) -> PunchType {
        let direction = simd_normalize(velocity)

        // Forward punches (jab, cross)
        if direction.z < -0.8 {
            // Jab is typically lead hand, cross is rear hand
            return hand == .left ? .jab : .cross
        }

        // Horizontal punches (hook)
        if abs(direction.x) > 0.7 {
            return .hook
        }

        // Upward punches (uppercut)
        if direction.y > 0.6 {
            return .uppercut
        }

        // Default to jab
        return .jab
    }

    private func calculatePower(velocity: Float, extension: Float) -> Float {
        // Power is combination of speed and extension
        let velocityFactor = min(velocity / 5.0, 1.0)  // Normalize to 0-1
        let extensionFactor = min(extension / 0.6, 1.0)

        return (velocityFactor * 0.7 + extensionFactor * 0.3)
    }

    private func analyzeForm(hand: HandAnchor, punchType: PunchType) -> Float {
        // Analyze hand orientation and joint angles
        let orientation = hand.transform.rotation

        // Check if fist is properly aligned
        let alignment = checkFistAlignment(orientation)

        // Check shoulder rotation (estimated)
        let rotation = checkShoulderRotation(hand)

        // Combine factors (0.0 - 1.0)
        return (alignment * 0.6 + rotation * 0.4)
    }
}
```

### 3.2 Defensive Moves Detection

```swift
struct DefensiveMovementDetection {
    func detectDefensiveMove(
        headPosition: SIMD3<Float>,
        previousHeadPosition: SIMD3<Float>,
        handPositions: (left: SIMD3<Float>, right: SIMD3<Float>),
        deltaTime: TimeInterval
    ) -> DefensiveMove? {

        // Detect ducking
        let verticalMovement = headPosition.y - previousHeadPosition.y
        if verticalMovement < -0.15 {  // Moved down 15cm+
            return DefensiveMove(
                type: .duck,
                success: false,  // Will be updated by collision system
                timestamp: CACurrentMediaTime()
            )
        }

        // Detect slipping (lateral head movement)
        let lateralMovement = SIMD2(headPosition.x - previousHeadPosition.x,
                                    headPosition.z - previousHeadPosition.z)
        if simd_length(lateralMovement) > 0.2 {
            return DefensiveMove(
                type: .slip,
                success: false,
                timestamp: CACurrentMediaTime()
            )
        }

        // Detect blocking (hands near face)
        let facePosition = headPosition
        let leftDistance = simd_distance(handPositions.left, facePosition)
        let rightDistance = simd_distance(handPositions.right, facePosition)

        if leftDistance < 0.25 || rightDistance < 0.25 {
            return DefensiveMove(
                type: .block,
                success: false,
                timestamp: CACurrentMediaTime()
            )
        }

        return nil
    }
}
```

### 3.3 Combo System

```swift
struct ComboSystem {
    private var recentPunches: [Punch] = []
    private let comboWindow: TimeInterval = 2.0  // 2 second window

    func recordPunch(_ punch: Punch) {
        recentPunches.append(punch)

        // Remove old punches outside combo window
        let cutoff = punch.timestamp - comboWindow
        recentPunches.removeAll { $0.timestamp < cutoff }
    }

    func detectCombo() -> Combo? {
        guard recentPunches.count >= 2 else { return nil }

        let pattern = recentPunches.map { $0.type }

        // Check against known combos
        for combo in KnownCombos.all {
            if pattern.suffix(combo.pattern.count) == combo.pattern {
                return combo
            }
        }

        return nil
    }
}

struct Combo {
    let name: String
    let pattern: [PunchType]
    let damageMultiplier: Float
    let scoreBonus: Int
}

struct KnownCombos {
    static let all: [Combo] = [
        Combo(name: "One-Two", pattern: [.jab, .cross], damageMultiplier: 1.2, scoreBonus: 10),
        Combo(name: "Hook Combo", pattern: [.jab, .cross, .hook], damageMultiplier: 1.5, scoreBonus: 25),
        Combo(name: "Uppercut Finish", pattern: [.jab, .jab, .uppercut], damageMultiplier: 1.6, scoreBonus: 30),
        Combo(name: "Speed Combo", pattern: [.jab, .jab, .jab, .cross], damageMultiplier: 1.4, scoreBonus: 20),
    ]
}
```

### 3.4 Stamina System

```swift
@Observable
class StaminaSystem {
    var currentStamina: Float = 100.0
    var maxStamina: Float = 100.0

    // Configuration
    let punchCost: Float = 2.0
    let defenseCost: Float = 1.0
    let movementCostPerMeter: Float = 1.5
    let recoveryRate: Float = 8.0  // per second

    func update(deltaTime: TimeInterval) {
        // Regenerate stamina
        currentStamina = min(maxStamina, currentStamina + recoveryRate * Float(deltaTime))
    }

    func consumeForPunch(power: Float) {
        let cost = punchCost * power
        currentStamina = max(0, currentStamina - cost)
    }

    func consumeForDefense() {
        currentStamina = max(0, currentStamina - defenseCost)
    }

    func consumeForMovement(distance: Float) {
        let cost = movementCostPerMeter * distance
        currentStamina = max(0, currentStamina - cost)
    }

    var exhaustionMultiplier: Float {
        // Reduce effectiveness when stamina is low
        if currentStamina < 20 {
            return 0.5
        } else if currentStamina < 50 {
            return 0.75
        }
        return 1.0
    }
}
```

---

## 4. Control Schemes

### 4.1 Primary Input: Hand Tracking

#### Hand Gestures

| Gesture | Description | Detection |
|---------|-------------|-----------|
| **Closed Fist** | Boxing stance | All fingers curled |
| **Punch** | Strike forward | Fist + high velocity + extension |
| **Guard** | Defensive position | Fists near face |
| **Pinch** | Menu interaction | Thumb + index finger touch |

#### Implementation

```swift
struct HandGestureRecognizer {
    func recognizeGesture(_ hand: HandAnchor) -> HandGesture {
        let skeleton = hand.skeleton

        // Check if fist is closed
        if isClosedFist(skeleton) {
            return .fist
        }

        // Check for pinch
        if isPinching(skeleton) {
            return .pinch
        }

        // Check for open palm
        if isOpenPalm(skeleton) {
            return .open
        }

        return .neutral
    }

    private func isClosedFist(_ skeleton: HandSkeleton) -> Bool {
        // Check if fingers are curled
        let joints = skeleton.allJoints

        // Check each finger (index through pinky)
        for finger in [HandSkeleton.JointName.indexFingerTip,
                       HandSkeleton.JointName.middleFingerTip,
                       HandSkeleton.JointName.ringFingerTip,
                       HandSkeleton.JointName.littleFingerTip] {
            guard let tip = joints[finger],
                  let base = joints[finger.base] else {
                continue
            }

            let distance = simd_distance(tip.position, base.position)

            // If any finger is extended, not a fist
            if distance > 0.05 {
                return false
            }
        }

        return true
    }
}

enum HandGesture {
    case fist
    case open
    case pinch
    case neutral
}
```

### 4.2 Secondary Input: Eye Tracking

#### Eye Tracking Features

- **Target Selection**: Look at opponent's body parts to aim punches
- **Menu Navigation**: Gaze at menu items to highlight
- **Attention Tracking**: Monitor where player is looking for safety

```swift
actor EyeTrackingManager {
    private var session: ARKitSession?
    private var eyeTracking: EyeTrackingProvider?

    func start() async throws {
        session = ARKitSession()
        eyeTracking = EyeTrackingProvider()

        try await session?.run([eyeTracking!])
    }

    func getGazeDirection() async -> SIMD3<Float>? {
        guard let eyeTracking = eyeTracking else {
            return nil
        }

        // Get latest eye tracking data
        for await update in eyeTracking.anchorUpdates {
            if case .updated = update.event {
                let anchor = update.anchor
                return anchor.lookAtPoint
            }
        }

        return nil
    }

    func raycastFromGaze(in scene: RealityKit.Scene) async -> Entity? {
        guard let gazeDirection = await getGazeDirection() else {
            return nil
        }

        // Perform raycast from eye position
        let results = scene.raycast(
            origin: gazeDirection,
            direction: SIMD3<Float>(0, 0, -1)
        )

        return results.first?.entity
    }
}
```

### 4.3 Tertiary Input: Voice Commands

#### Supported Commands

```swift
enum VoiceCommand: String, CaseIterable {
    case startTraining = "start training"
    case startSparring = "start sparring"
    case pause = "pause"
    case resume = "resume"
    case restart = "restart"
    case mainMenu = "main menu"
    case nextRound = "next round"
    case settings = "settings"
}

actor VoiceCommandRecognizer {
    private var recognizer: SpeechRecognizer?

    func startListening() async throws {
        recognizer = SpeechRecognizer()
        try await recognizer?.start()
    }

    func processCommand(_ text: String) -> VoiceCommand? {
        let lowercased = text.lowercased().trimmingCharacters(in: .whitespaces)

        for command in VoiceCommand.allCases {
            if lowercased.contains(command.rawValue) {
                return command
            }
        }

        return nil
    }
}
```

### 4.4 Gamepad Support (Optional)

For accessibility and alternative control:

```swift
import GameController

class GameControllerManager {
    private var controller: GCController?

    func setup() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(controllerConnected),
            name: .GCControllerDidConnect,
            object: nil
        )

        // Check for already connected controllers
        if let controller = GCController.controllers().first {
            setupController(controller)
        }
    }

    private func setupController(_ controller: GCController) {
        self.controller = controller

        // Map buttons to game actions
        controller.extendedGamepad?.buttonA.pressedChangedHandler = { _, _, pressed in
            if pressed {
                // Throw jab
                self.throwPunch(.jab)
            }
        }

        controller.extendedGamepad?.buttonB.pressedChangedHandler = { _, _, pressed in
            if pressed {
                // Throw cross
                self.throwPunch(.cross)
            }
        }

        // Add other button mappings...
    }
}
```

---

## 5. Physics Specifications

### 5.1 Physics Engine Configuration

```swift
struct PhysicsConfiguration {
    // Simulation
    static let timeStep: TimeInterval = 1.0 / 90.0  // 90 Hz physics
    static let gravity: SIMD3<Float> = [0, -9.81, 0]
    static let maxSubsteps: Int = 4

    // Collision detection
    static let collisionLayers: [CollisionLayer] = [
        .player,
        .opponent,
        .environment,
        .projectile
    ]

    // Materials
    static let defaultRestitution: Float = 0.3
    static let defaultFriction: Float = 0.6
    static let defaultDensity: Float = 1.0
}

enum CollisionLayer: UInt32 {
    case player = 1
    case opponent = 2
    case environment = 4
    case projectile = 8

    var mask: CollisionGroup {
        CollisionGroup(rawValue: rawValue)
    }
}
```

### 5.2 Punch Impact Physics

```swift
struct PunchImpactPhysics {
    static func calculateImpact(punch: Punch) -> ImpactResult {
        let velocity = simd_length(punch.velocity)
        let mass: Float = 0.5  // kg (hand + glove)

        // Kinetic energy: KE = 0.5 * m * v^2
        let kineticEnergy = 0.5 * mass * velocity * velocity

        // Impact force (simplified)
        let impactDuration: Float = 0.01  // 10ms contact time
        let force = (mass * velocity) / impactDuration

        // Damage based on energy transfer
        let damage = kineticEnergy * 10.0 * punch.accuracy

        return ImpactResult(
            force: force,
            damage: damage,
            impulse: punch.velocity * mass,
            point: punch.position
        )
    }
}

struct ImpactResult {
    let force: Float  // Newtons
    let damage: Float  // Hit points
    let impulse: SIMD3<Float>  // kg⋅m/s
    let point: SIMD3<Float>  // World position
}
```

### 5.3 Collision Response

```swift
struct CollisionResponse {
    static func handlePunchCollision(
        punch: Entity,
        target: Entity,
        contactPoint: SIMD3<Float>
    ) {
        // Apply damage
        if var health = target.components[HealthComponent.self] {
            let punchData = extractPunchData(from: punch)
            let impact = PunchImpactPhysics.calculateImpact(punch: punchData)

            health.current = max(0, health.current - impact.damage)
            target.components[HealthComponent.self] = health
        }

        // Apply physics impulse
        if var physics = target.components[PhysicsBodyComponent.self] {
            let punchData = extractPunchData(from: punch)
            let impact = PunchImpactPhysics.calculateImpact(punch: punchData)

            physics.addImpulse(impact.impulse, at: contactPoint)
        }

        // Visual feedback
        spawnImpactEffect(at: contactPoint)

        // Audio feedback
        playImpactSound(at: contactPoint, intensity: impact.force / 100.0)
    }
}
```

---

## 6. Rendering Requirements

### 6.1 Rendering Pipeline

```swift
struct RenderingConfiguration {
    // Frame rate
    static let targetFrameRate: Int = 90  // FPS
    static let minFrameRate: Int = 60     // Acceptable minimum

    // Resolution
    static let renderScale: Float = 1.0   // Can reduce for performance

    // Quality settings
    enum QualityPreset {
        case low
        case medium
        case high
        case ultra

        var shadowQuality: ShadowQuality {
            switch self {
            case .low: return .off
            case .medium: return .low
            case .high: return .medium
            case .ultra: return .high
            }
        }

        var particleCount: Int {
            switch self {
            case .low: return 100
            case .medium: return 500
            case .high: return 1000
            case .ultra: return 2000
            }
        }

        var antiAliasing: AntiAliasing {
            switch self {
            case .low: return .off
            case .medium: return .fxaa
            case .high: return .msaa2x
            case .ultra: return .msaa4x
            }
        }
    }
}
```

### 6.2 Material System

```swift
struct MaterialLibrary {
    // PBR materials
    static func createGloveMaterial() -> PhysicallyBasedMaterial {
        var material = PhysicallyBasedMaterial()

        // Base color
        material.baseColor = .init(tint: .red)

        // Roughness (0 = smooth, 1 = rough)
        material.roughness = .init(floatLiteral: 0.6)

        // Metallic (0 = non-metal, 1 = metal)
        material.metallic = .init(floatLiteral: 0.1)

        // Normal map for texture
        if let normalTexture = try? TextureResource.load(named: "glove_normal") {
            material.normal = .init(texture: .init(normalTexture))
        }

        return material
    }

    static func createSkinMaterial() -> PhysicallyBasedMaterial {
        var material = PhysicallyBasedMaterial()

        // Subsurface scattering for realistic skin
        material.baseColor = .init(tint: .init(red: 0.9, green: 0.7, blue: 0.6))
        material.roughness = .init(floatLiteral: 0.4)

        // Enable subsurface
        material.subsurface = .init(floatLiteral: 0.3)

        return material
    }
}
```

### 6.3 Lighting Setup

```swift
struct LightingConfiguration {
    static func setupArenaLighting(scene: RealityKit.Scene) {
        // Ambient light (soft overall illumination)
        let ambient = AmbientLightComponent(color: .white, intensity: 200)

        // Directional light (main key light)
        let directional = DirectionalLight()
        directional.light.color = .white
        directional.light.intensity = 1000
        directional.shadow = .init()
        directional.shadow?.maximumDistance = 10.0
        directional.shadow?.depthBias = 0.1

        // Spot lights (accent lights)
        let spotLights = (0..<4).map { index in
            let spot = SpotLight()
            spot.light.color = .white
            spot.light.intensity = 500
            spot.light.attenuationRadius = 5.0
            spot.light.innerAngleInDegrees = 30
            spot.light.outerAngleInDegrees = 45
            return spot
        }

        // Add to scene
        // ... (positioning code)
    }
}
```

### 6.4 Post-Processing Effects

```swift
struct PostProcessing {
    // Bloom for impact effects
    static let bloom = BloomEffect(
        threshold: 0.8,
        intensity: 0.3,
        radius: 2.0
    )

    // Color grading for atmosphere
    static let colorGrading = ColorGradingEffect(
        contrast: 1.1,
        saturation: 1.05,
        brightness: 1.0
    )

    // Motion blur for fast movements
    static let motionBlur = MotionBlurEffect(
        intensity: 0.5,
        sampleCount: 4
    )

    // Depth of field (optional)
    static let depthOfField = DepthOfFieldEffect(
        focusDistance: 2.0,
        focalLength: 50.0,
        aperture: 2.8
    )
}
```

---

## 7. AI and Machine Learning

### 7.1 Opponent AI Model

#### Model Architecture

```swift
// Core ML model inputs
struct OpponentAIInput {
    var playerX: Double
    var playerY: Double
    var playerZ: Double
    var playerVelocityX: Double
    var playerVelocityY: Double
    var playerVelocityZ: Double
    var playerStamina: Double
    var playerHealth: Double
    var opponentHealth: Double
    var opponentStamina: Double
    var recentPunchPattern: [Double]  // One-hot encoded
    var timeSinceLastPunch: Double
    var distanceToPlayer: Double
}

// Core ML model outputs
struct OpponentAIOutput {
    var action: AIAction  // Predicted action
    var confidence: Double  // 0-1
    var targetPosition: SIMD3<Float>  // Where to move
}
```

#### Training Data Collection

```swift
struct TrainingDataCollector {
    func recordGameState(
        playerState: PlayerState,
        opponentState: OpponentState,
        optimalAction: AIAction
    ) async {
        let dataPoint = TrainingDataPoint(
            timestamp: Date(),
            playerState: playerState,
            opponentState: opponentState,
            optimalAction: optimalAction,
            outcome: nil  // Will be filled when match ends
        )

        await saveTrainingData(dataPoint)
    }

    private func saveTrainingData(_ dataPoint: TrainingDataPoint) async {
        // Save to local database for later training
        // Can be uploaded to server for aggregate training
    }
}
```

### 7.2 Technique Analysis ML

```swift
struct TechniqueAnalysisModel {
    private var model: MLModel?

    func analyzePunchTechnique(
        handPositions: [SIMD3<Float>],
        velocities: [SIMD3<Float>],
        timestamps: [TimeInterval]
    ) async -> TechniqueScore {

        // Extract features
        let features = extractFeatures(
            positions: handPositions,
            velocities: velocities,
            timestamps: timestamps
        )

        // Run through ML model
        guard let model = model,
              let prediction = try? model.prediction(from: features) else {
            return TechniqueScore.default
        }

        return parsePrediction(prediction)
    }

    private func extractFeatures(
        positions: [SIMD3<Float>],
        velocities: [SIMD3<Float>],
        timestamps: [TimeInterval]
    ) -> MLFeatureProvider {
        // Feature engineering
        // - Peak velocity
        // - Acceleration profile
        // - Extension distance
        // - Hand rotation
        // - Timing consistency
        // etc.
    }
}

struct TechniqueScore {
    var overall: Float  // 0-1
    var form: Float
    var power: Float
    var speed: Float
    var consistency: Float
    var improvements: [String]

    static let `default` = TechniqueScore(
        overall: 0.5,
        form: 0.5,
        power: 0.5,
        speed: 0.5,
        consistency: 0.5,
        improvements: []
    )
}
```

### 7.3 Personalized Training AI

```swift
actor PersonalTrainerAI {
    private var userProfile: PlayerProfile
    private var llm: LLMService?  // Optional LLM integration

    func generateWorkoutPlan(
        goals: [FitnessGoal],
        availableTime: TimeInterval,
        currentFitness: FitnessLevel
    ) async -> WorkoutPlan {

        // Use AI to create personalized workout
        let exercises = selectExercises(
            for: goals,
            difficulty: currentFitness.difficulty
        )

        let duration = distributeTime(
            total: availableTime,
            across: exercises
        )

        return WorkoutPlan(
            exercises: exercises,
            duration: duration,
            intensity: currentFitness.recommendedIntensity
        )
    }

    func provideRealTimeFeedback(
        technique: TechniqueScore
    ) async -> String {
        // Generate natural language feedback
        if let llm = llm {
            return await llm.generateFeedback(technique: technique)
        }

        // Fallback to rule-based feedback
        return generateRuleBasedFeedback(technique: technique)
    }
}
```

---

## 8. Multiplayer and Networking

### 8.1 Network Architecture

```swift
actor MultiplayerManager {
    private var session: MultipeerSession?
    private var connectionQuality: ConnectionQuality = .unknown

    // Network configuration
    private let tickRate: Int = 30  // Updates per second
    private let maxLatency: TimeInterval = 0.150  // 150ms max acceptable
    private let timeoutDuration: TimeInterval = 10.0

    func createSession(playerName: String) async throws {
        session = MultipeerSession(
            serviceName: "shadowboxing",
            identity: playerName,
            maxPeers: 2  // 1v1 matches
        )

        try await session?.advertise()
    }

    func joinSession(hostID: String) async throws {
        try await session?.browse()
        try await session?.connect(to: hostID)

        // Measure initial latency
        await measureLatency()
    }

    private func measureLatency() async {
        let startTime = CACurrentMediaTime()

        // Send ping
        try? await session?.send(
            data: "PING".data(using: .utf8)!,
            to: .all
        )

        // Wait for pong
        // ... (measurement code)

        let latency = CACurrentMediaTime() - startTime
        updateConnectionQuality(latency: latency)
    }
}

enum ConnectionQuality {
    case unknown
    case excellent  // < 50ms
    case good       // 50-100ms
    case fair       // 100-150ms
    case poor       // > 150ms
}
```

### 8.2 State Synchronization Protocol

```swift
struct GameStateMessage: Codable {
    let sequenceNumber: UInt64
    let timestamp: TimeInterval

    // Player state
    let playerPosition: SIMD3<Float>
    let playerHealth: Float
    let playerStamina: Float
    let playerAction: PlayerAction?

    // Match state
    let currentRound: Int
    let roundTime: TimeInterval
    let score: Score
}

actor StateSynchronizer {
    private var localSequence: UInt64 = 0
    private var remoteSequence: UInt64 = 0
    private var stateBuffer: [GameStateMessage] = []

    func sendState(_ state: GameState) async throws {
        localSequence += 1

        let message = GameStateMessage(
            sequenceNumber: localSequence,
            timestamp: CACurrentMediaTime(),
            playerPosition: state.playerPosition,
            playerHealth: state.playerHealth,
            playerStamina: state.playerStamina,
            playerAction: state.currentAction,
            currentRound: state.currentRound,
            roundTime: state.roundTime,
            score: state.score
        )

        let data = try JSONEncoder().encode(message)
        try await networkManager.send(data)
    }

    func receiveState() async throws -> GameStateMessage? {
        guard let data = try await networkManager.receive() else {
            return nil
        }

        let message = try JSONDecoder().decode(GameStateMessage.self, from: data)

        // Handle out-of-order messages
        if message.sequenceNumber <= remoteSequence {
            // Discard old message
            return nil
        }

        remoteSequence = message.sequenceNumber
        return message
    }
}
```

### 8.3 Lag Compensation Techniques

```swift
struct ClientPrediction {
    // Client predicts own movement immediately
    func predictLocalMovement(
        input: PlayerInput,
        deltaTime: TimeInterval
    ) -> PlayerState {
        // Apply movement immediately on client
        var predicted = currentState
        predicted.position += input.movement * Float(deltaTime)
        predicted.stamina -= input.actionCost

        return predicted
    }
}

struct ServerReconciliation {
    // Server sends authoritative state
    // Client reconciles differences
    func reconcile(
        predicted: PlayerState,
        authoritative: PlayerState
    ) -> PlayerState {
        let positionError = simd_distance(
            predicted.position,
            authoritative.position
        )

        // If error is small, smoothly interpolate
        if positionError < 0.5 {
            return interpolate(
                from: predicted,
                to: authoritative,
                alpha: 0.1
            )
        } else {
            // Large error, snap to authoritative
            return authoritative
        }
    }
}

struct EntityInterpolation {
    // Smooth out opponent movement
    private var positionHistory: [(time: TimeInterval, position: SIMD3<Float>)] = []

    func addSnapshot(time: TimeInterval, position: SIMD3<Float>) {
        positionHistory.append((time, position))

        // Keep last 200ms of history
        let cutoff = time - 0.2
        positionHistory.removeAll { $0.time < cutoff }
    }

    func interpolatePosition(at time: TimeInterval) -> SIMD3<Float>? {
        // Find surrounding snapshots
        guard positionHistory.count >= 2 else {
            return positionHistory.last?.position
        }

        // Interpolate between snapshots
        // ... (interpolation logic)
    }
}
```

---

## 9. Performance Budgets

### 9.1 Frame Time Budget (90 FPS)

Total frame budget: **11.1ms**

| System | Budget | Target |
|--------|--------|--------|
| Input Processing | 1.0ms | 0.8ms |
| Game Logic Update | 2.0ms | 1.5ms |
| AI Processing | 1.5ms | 1.2ms |
| Physics Simulation | 2.0ms | 1.8ms |
| Animation | 1.0ms | 0.8ms |
| Rendering | 3.0ms | 2.5ms |
| Audio | 0.5ms | 0.3ms |
| Misc/Overhead | 0.1ms | 0.2ms |
| **Total** | **11.1ms** | **9.1ms** |

### 9.2 Memory Budget

Total memory budget: **2GB**

| Category | Budget | Notes |
|----------|--------|-------|
| Textures | 500MB | Compressed formats |
| 3D Models | 300MB | LOD system |
| Audio | 100MB | Streaming for music |
| Game State | 50MB | Current match data |
| AI Models | 200MB | Core ML models |
| Code/Framework | 150MB | App binary |
| System Reserved | 500MB | visionOS overhead |
| Buffer | 200MB | Headroom |
| **Total** | **2000MB** | |

### 9.3 Network Budget

| Metric | Target | Maximum |
|--------|--------|---------|
| Tick Rate | 30 Hz | 30 Hz |
| Latency | < 100ms | < 150ms |
| Bandwidth | 50 KB/s | 100 KB/s |
| Packet Loss | < 1% | < 5% |

### 9.4 Thermal Budget

- **Sustained Performance**: 30 minutes minimum
- **CPU Usage**: < 60% average
- **GPU Usage**: < 70% average
- **Neural Engine**: < 50% average

### 9.5 Battery Budget

- **Target Session Length**: 45 minutes
- **Maximum Power Draw**: 8W average
- **Standby Efficiency**: < 50mW

---

## 10. Audio Specifications

### 10.1 Audio Assets

#### File Formats
- **Music**: AAC 256kbps, 48kHz
- **SFX**: WAV 16-bit, 48kHz
- **Spatial**: Supports Dolby Atmos

#### Asset List

```
Audio/
├── Music/
│   ├── menu_theme.m4a (3:00)
│   ├── training_ambient.m4a (5:00, looping)
│   ├── match_intro.m4a (0:30)
│   └── match_intense.m4a (3:00, layered)
│
├── SFX/
│   ├── Punches/
│   │   ├── jab_light.wav
│   │   ├── jab_heavy.wav
│   │   ├── cross_light.wav
│   │   ├── cross_heavy.wav
│   │   ├── hook_light.wav
│   │   ├── hook_heavy.wav
│   │   ├── uppercut_light.wav
│   │   └── uppercut_heavy.wav
│   │
│   ├── Impacts/
│   │   ├── hit_body.wav
│   │   ├── hit_face.wav
│   │   ├── block.wav
│   │   └── miss.wav
│   │
│   ├── Ambience/
│   │   ├── crowd_cheer.wav
│   │   ├── crowd_boo.wav
│   │   ├── crowd_ambient.wav
│   │   └── bell.wav
│   │
│   └── UI/
│       ├── button_press.wav
│       ├── menu_select.wav
│       └── countdown.wav
│
└── Voice/
    ├── coach_encouragement_01.wav
    ├── coach_technique_01.wav
    └── referee_count.wav
```

### 10.2 Spatial Audio Configuration

```swift
struct SpatialAudioConfig {
    // HRTF settings
    static let renderingAlgorithm: AVAudio3DMixingRenderingAlgorithm = .HRTF

    // Distance attenuation
    static let referenceDistance: Float = 1.0  // meters
    static let maximumDistance: Float = 50.0   // meters
    static let rolloffFactor: Float = 1.0

    // Reverb for arena
    static let reverbPreset: AVAudioUnitReverbPreset = .largeHall

    // Occlusion
    static let occlusionEnabled: Bool = true
}
```

---

## 11. Health and Fitness Integration

### 11.1 HealthKit Integration

```swift
actor HealthKitManager {
    private let healthStore = HKHealthStore()

    func requestAuthorization() async throws {
        let typesToWrite: Set<HKSampleType> = [
            HKObjectType.workoutType(),
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKObjectType.quantityType(forIdentifier: .distanceBoxing)!,
        ]

        let typesToRead: Set<HKObjectType> = [
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.quantityType(forIdentifier: .restingHeartRate)!,
        ]

        try await healthStore.requestAuthorization(
            toShare: typesToWrite,
            read: typesToRead
        )
    }

    func startWorkout() async throws {
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = .boxing
        configuration.locationType = .indoor

        // Start workout session
        // ... (implementation)
    }

    func recordCalories(_ calories: Double) async throws {
        let calorieUnit = HKUnit.kilocalorie()
        let calorieQuantity = HKQuantity(unit: calorieUnit, doubleValue: calories)

        let calorieSample = HKQuantityample(
            type: HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
            quantity: calorieQuantity,
            start: Date(),
            end: Date()
        )

        try await healthStore.save(calorieSample)
    }
}
```

### 11.2 Heart Rate Monitoring

```swift
actor HeartRateMonitor {
    private var query: HKAnchoredObjectQuery?

    func startMonitoring(callback: @escaping (Double) -> Void) async throws {
        let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate)!

        query = HKAnchoredObjectQuery(
            type: heartRateType,
            predicate: nil,
            anchor: nil,
            limit: HKObjectQueryNoLimit
        ) { query, samples, deletedObjects, anchor, error in
            guard let samples = samples as? [HKQuantitySample] else {
                return
            }

            for sample in samples {
                let bpm = sample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: .minute()))
                callback(bpm)
            }
        }

        healthStore.execute(query!)
    }

    func stopMonitoring() {
        if let query = query {
            healthStore.stop(query)
        }
    }
}
```

---

## 12. Testing Requirements

### 12.1 Unit Testing

```swift
@Test
class PunchDetectionTests {
    @Test("Detect jab from velocity")
    func testJabDetection() async throws {
        let detector = PunchDetectionSystem()

        let hand = createMockHand(
            position: SIMD3<Float>(0, 1.5, -0.5),
            velocity: SIMD3<Float>(0, 0, -3.0)
        )

        let punch = detector.detectPunch(
            hand: hand,
            previousPosition: SIMD3<Float>(0, 1.5, 0),
            previousTime: 0,
            currentTime: 0.1
        )

        #expect(punch != nil)
        #expect(punch?.type == .jab)
    }
}
```

### 12.2 Performance Testing

```swift
@Test
class PerformanceTests {
    @Test("Frame rate stays above 60 FPS")
    func testFrameRate() async throws {
        let metrics = await runGameSession(duration: 60.0)

        #expect(metrics.averageFrameRate >= 60)
        #expect(metrics.minimumFrameRate >= 45)
        #expect(metrics.frameTimeVariance < 5.0)
    }

    @Test("Memory usage stays under budget")
    func testMemoryUsage() async throws {
        let metrics = await runGameSession(duration: 300.0)

        #expect(metrics.peakMemory < 2_000_000_000)  // 2GB
        #expect(metrics.memoryLeaks == 0)
    }
}
```

### 12.3 Integration Testing

```swift
@Test
class IntegrationTests {
    @Test("Complete match flow")
    func testMatchFlow() async throws {
        let game = GameCoordinator()

        // Start match
        await game.startMatch(opponent: .beginner)

        // Simulate punches
        for _ in 0..<100 {
            await game.throwPunch(.jab)
            try await Task.sleep(nanoseconds: 100_000_000)  // 0.1s
        }

        // Verify match completes
        #expect(game.state == .completed)
    }
}
```

### 12.4 User Acceptance Testing

**Test Scenarios:**

1. **Onboarding Flow**
   - New user completes tutorial
   - Understands controls
   - Completes first training session

2. **Training Session**
   - User performs all punch types
   - Receives accurate technique feedback
   - Completes 15-minute session without discomfort

3. **Sparring Match**
   - AI opponent behaves realistically
   - Damage and scoring work correctly
   - Match concludes properly

4. **Multiplayer**
   - Users can find and connect to matches
   - Synchronization is smooth (< 100ms latency)
   - Disconnection is handled gracefully

**Acceptance Criteria:**
- 95% task completion rate
- < 5% bug report rate
- 4+ star average rating
- < 1% motion sickness reports

---

## Conclusion

This technical specification provides comprehensive implementation details for Shadow Boxing Champions. All systems are designed for optimal performance on Vision Pro while delivering professional-grade boxing training and competitive gameplay.

**Key Technical Achievements:**
- 90 FPS spatial combat
- Sub-20ms input latency
- Professional motion capture accuracy
- AI-driven opponents and coaching
- Seamless multiplayer experience

Refer to ARCHITECTURE.md for system design and DESIGN.md for UI/UX specifications.
