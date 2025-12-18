# Mindfulness Meditation Realms - Technical Architecture

## Document Overview

**Version:** 1.0
**Last Updated:** 2025-01-20
**Target Platform:** visionOS 2.0+
**Minimum Device:** Apple Vision Pro

---

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [System Architecture](#system-architecture)
3. [Game Architecture](#game-architecture)
4. [visionOS-Specific Gaming Patterns](#visionos-specific-gaming-patterns)
5. [Data Models & Schemas](#data-models--schemas)
6. [RealityKit Components & Systems](#realitykit-components--systems)
7. [ARKit Integration](#arkit-integration)
8. [AI & Biometric Systems](#ai--biometric-systems)
9. [Multiplayer Architecture](#multiplayer-architecture)
10. [Audio Architecture](#audio-architecture)
11. [Performance & Optimization](#performance--optimization)
12. [Save/Load System](#saveload-system)
13. [Security & Privacy](#security--privacy)

---

## Architecture Overview

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        Application Layer                         │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │  SwiftUI     │  │  Game        │  │  Settings    │          │
│  │  Views       │  │  Coordinator │  │  Manager     │          │
│  └──────────────┘  └──────────────┘  └──────────────┘          │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                       Presentation Layer                         │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │  Session     │  │  UI          │  │  Navigation  │          │
│  │  Views       │  │  Components  │  │  Controller  │          │
│  └──────────────┘  └──────────────┘  └──────────────┘          │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                        Business Logic Layer                      │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │  Meditation  │  │  Biometric   │  │  Environment │          │
│  │  Engine      │  │  Processor   │  │  Manager     │          │
│  └──────────────┘  └──────────────┘  └──────────────┘          │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │  AI Coach    │  │  Progress    │  │  Social      │          │
│  │  System      │  │  Tracker     │  │  Manager     │          │
│  └──────────────┘  └──────────────┘  └──────────────┘          │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                      Spatial Computing Layer                     │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │  RealityKit  │  │  ARKit       │  │  Spatial     │          │
│  │  Renderer    │  │  Tracking    │  │  Audio       │          │
│  └──────────────┘  └──────────────┘  └──────────────┘          │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │  Entity      │  │  Gesture     │  │  Room        │          │
│  │  Component   │  │  Recognition │  │  Mapping     │          │
│  └──────────────┘  └──────────────┘  └──────────────┘          │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                         Data Layer                               │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │  Local       │  │  CloudKit    │  │  Asset       │          │
│  │  Storage     │  │  Sync        │  │  Manager     │          │
│  └──────────────┘  └──────────────┘  └──────────────┘          │
└─────────────────────────────────────────────────────────────────┘
```

### Design Principles

1. **Wellness-First Architecture**: Every system prioritizes user comfort and mental state
2. **Privacy by Design**: All biometric data processed locally, never transmitted
3. **Spatial Native**: Leverages spatial computing at every layer
4. **Performance Critical**: Maintain 90fps for smooth, comfortable experience
5. **Adaptive Intelligence**: AI systems respond to real-time user state
6. **Graceful Degradation**: Works beautifully even without biometric features

---

## System Architecture

### Core Systems Overview

```swift
// Main Application Architecture
MindfulnessMeditationRealms/
├── App/
│   ├── MeditationApp.swift              // App entry point
│   ├── AppCoordinator.swift             // Main coordinator
│   └── AppConfiguration.swift           // App-wide config
│
├── Core/
│   ├── MeditationEngine/
│   │   ├── SessionManager.swift         // Session lifecycle
│   │   ├── StateManager.swift           // Meditation state machine
│   │   └── TimingController.swift       // Session timing
│   │
│   ├── BiometricSystem/
│   │   ├── BiometricMonitor.swift       // Heart rate, breathing
│   │   ├── StressAnalyzer.swift         // HRV analysis
│   │   └── StateDetector.swift          // Mental state detection
│   │
│   └── AISystem/
│       ├── AdaptationEngine.swift       // Environment adaptation
│       ├── GuidanceGenerator.swift      // Personalized guidance
│       └── ProgressPredictor.swift      // ML-based predictions
│
├── Spatial/
│   ├── EnvironmentManager/
│   │   ├── RealmCoordinator.swift       // Environment switching
│   │   ├── EnvironmentRenderer.swift    // RealityKit rendering
│   │   └── TransitionController.swift   // Smooth transitions
│   │
│   ├── RoomMapping/
│   │   ├── SpaceAnalyzer.swift          // Room understanding
│   │   ├── BoundaryManager.swift        // Safe space boundaries
│   │   └── AnchorPlacement.swift        // Meditation spot anchoring
│   │
│   └── InteractionSystem/
│       ├── GestureRecognizer.swift      // Meditation gestures
│       ├── EyeTracker.swift             // Gaze-based interaction
│       └── HandTracker.swift            // Hand pose tracking
│
├── Audio/
│   ├── SpatialAudioEngine.swift         // 3D audio rendering
│   ├── SoundscapeManager.swift          // Ambient sound mixing
│   ├── MusicController.swift            // Background music
│   └── VoiceGuidance.swift              // Guided meditation voice
│
├── UI/
│   ├── Views/                           // SwiftUI views
│   ├── Components/                      // Reusable UI components
│   └── Themes/                          // Visual styling
│
├── Data/
│   ├── Models/                          // Data models
│   ├── Persistence/                     // Local storage
│   └── Sync/                            // CloudKit sync
│
├── Multiplayer/
│   ├── GroupSessionManager.swift        // SharePlay integration
│   ├── SyncEngine.swift                 // State synchronization
│   └── PresenceSystem.swift             // Participant visualization
│
└── Resources/
    ├── Environments/                    // RealityKit scenes
    ├── Audio/                           // Sound files
    └── Assets.xcassets/                 // Visual assets
```

---

## Game Architecture

### Game Loop & Update Cycle

```swift
// Meditation Session Game Loop
class MeditationSessionLoop {

    // 90 FPS target for comfort
    private let targetFrameRate: Double = 90.0
    private let deltaTime: TimeInterval = 1.0 / 90.0

    // Core update cycle
    func update(currentTime: TimeInterval) {
        // 1. Input Processing
        processInput()

        // 2. Biometric Update
        updateBiometrics()

        // 3. AI Systems
        updateAISystems()

        // 4. Environment Response
        updateEnvironment()

        // 5. Audio Update
        updateAudio()

        // 6. UI Update
        updateUI()

        // 7. Render
        render()
    }

    private func processInput() {
        // Gesture recognition
        // Eye tracking
        // Hand poses
    }

    private func updateBiometrics() {
        // Heart rate monitoring
        // Breathing pattern analysis
        // Stress level calculation
    }

    private func updateAISystems() {
        // Environment adaptation
        // Guidance generation
        // Progress tracking
    }

    private func updateEnvironment() {
        // Particle systems
        // Lighting changes
        // Weather effects
        // Breathing synchronization
    }

    private func updateAudio() {
        // Spatial audio positioning
        // Music mixing
        // Ambient sound generation
    }

    private func updateUI() {
        // Minimal HUD updates
        // Progress indicators
    }

    private func render() {
        // RealityKit rendering
        // Post-processing
    }
}
```

### State Management System

```swift
// Meditation State Machine
enum MeditationState {
    case idle
    case onboarding
    case calibration
    case sessionSetup
    case meditating
    case paused
    case completing
    case reflection
    case ended
}

class MeditationStateManager: ObservableObject {
    @Published var currentState: MeditationState = .idle
    @Published var sessionData: SessionData?

    private var stateHistory: [StateTransition] = []

    func transition(to newState: MeditationState) {
        let transition = StateTransition(
            from: currentState,
            to: newState,
            timestamp: Date(),
            reason: determineReason()
        )

        stateHistory.append(transition)
        performStateExit(currentState)
        currentState = newState
        performStateEntry(newState)
    }

    private func performStateExit(_ state: MeditationState) {
        // Cleanup for exiting state
    }

    private func performStateEntry(_ state: MeditationState) {
        // Setup for entering state
    }
}
```

### Entity-Component-System (ECS) Architecture

```swift
// ECS for meditation environment elements
protocol MeditationComponent {
    var entityID: UUID { get }
}

// Components
struct BreathingComponent: MeditationComponent {
    let entityID: UUID
    var breathingRate: Double
    var amplitude: Float
    var phase: Float
}

struct BiometricResponseComponent: MeditationComponent {
    let entityID: UUID
    var stressLevel: Float
    var calmLevel: Float
    var adaptationSpeed: Float
}

struct ParticleEffectComponent: MeditationComponent {
    let entityID: UUID
    var particleType: ParticleType
    var emissionRate: Float
    var color: SIMD3<Float>
}

// System
class BreathingSystem {
    func update(entities: [Entity], deltaTime: TimeInterval) {
        for entity in entities {
            if let breathingComp = entity.components[BreathingComponent.self] {
                // Synchronize entity movement with breathing
                updateBreathingAnimation(entity, breathingComp, deltaTime)
            }
        }
    }
}

class BiometricResponseSystem {
    func update(entities: [Entity], biometricData: BiometricData) {
        for entity in entities {
            if let responseComp = entity.components[BiometricResponseComponent.self] {
                // Adapt entity behavior based on biometrics
                adaptEntityToBiometrics(entity, responseComp, biometricData)
            }
        }
    }
}
```

---

## visionOS-Specific Gaming Patterns

### Immersive Space Management

```swift
// Full immersive space for meditation
@main
struct MeditationRealmApp: App {
    @State private var immersionStyle: ImmersionStyle = .full

    var body: some Scene {
        // Main window for menus
        WindowGroup {
            MainMenuView()
        }

        // Immersive meditation space
        ImmersiveSpace(id: "MeditationRealm") {
            MeditationEnvironmentView()
        }
        .immersionStyle(selection: $immersionStyle, in: .full)
    }
}
```

### Spatial Anchoring

```swift
// Anchor meditation position in room
class MeditationAnchorManager {
    private var anchorEntity: AnchorEntity?

    func createMeditationAnchor(at position: SIMD3<Float>) async {
        // Create world anchor at user's chosen meditation spot
        let anchor = AnchorEntity(.world(transform: Transform(
            scale: SIMD3(repeating: 1.0),
            rotation: simd_quatf(),
            translation: position
        )))

        anchorEntity = anchor

        // Persist anchor for future sessions
        await persistAnchor(anchor)
    }

    func loadSavedAnchor() async -> AnchorEntity? {
        // Retrieve saved meditation spot
        return await retrievePersistedAnchor()
    }
}
```

### Hand Tracking Integration

```swift
// Meditation gesture recognition
class MeditationGestureRecognizer {

    enum MeditationGesture {
        case palmsTogether      // Begin session
        case palmsUp           // Receive energy
        case palmsDown         // Ground
        case heartTouch        // Self-compassion
        case timeout           // Pause
    }

    func recognizeGesture(handTracking: HandTrackingProvider) -> MeditationGesture? {
        guard let leftHand = handTracking.leftHand,
              let rightHand = handTracking.rightHand else {
            return nil
        }

        // Check for palms together (prayer position)
        if arePalmsTogether(leftHand, rightHand) {
            return .palmsTogether
        }

        // Check for palms up (receiving position)
        if arePalmsUp(leftHand, rightHand) {
            return .palmsUp
        }

        // Additional gesture recognition...

        return nil
    }
}
```

---

## Data Models & Schemas

### Core Data Models

```swift
// User Profile
struct UserProfile: Codable, Identifiable {
    let id: UUID
    var name: String
    var experienceLevel: ExperienceLevel
    var preferences: MeditationPreferences
    var goals: [WellnessGoal]
    var createdAt: Date
    var lastSessionDate: Date?

    enum ExperienceLevel: String, Codable {
        case beginner
        case intermediate
        case advanced
        case expert
    }
}

// Meditation Session
struct MeditationSession: Codable, Identifiable {
    let id: UUID
    let userID: UUID
    let environmentID: String
    let startTime: Date
    var endTime: Date?
    var duration: TimeInterval
    var completionPercentage: Double

    // Biometric data
    var biometricSnapshots: [BiometricSnapshot]
    var averageHeartRate: Double?
    var hrvImprovement: Double?
    var stressReduction: Double?

    // Session quality
    var focusScore: Double?
    var calmScore: Double?
    var overallRating: Int?
    var notes: String?
}

// Biometric Data
struct BiometricSnapshot: Codable {
    let timestamp: Date
    let heartRate: Double?
    let hrv: Double?
    let breathingRate: Double?
    let estimatedStressLevel: Float
    let estimatedCalmLevel: Float
}

// Environment/Realm
struct MeditationEnvironment: Codable, Identifiable {
    let id: String
    let name: String
    let category: EnvironmentCategory
    let description: String
    let assetPath: String
    let isPremium: Bool
    let unlockCondition: UnlockCondition?

    // Environment properties
    var defaultDuration: TimeInterval
    var ambientSoundscape: String
    var visualTheme: VisualTheme
    var difficulty: DifficultyLevel

    enum EnvironmentCategory: String, Codable {
        case nature
        case cosmic
        case abstract
        case sacred
        case underwater
    }
}

// Progress & Achievements
struct UserProgress: Codable {
    let userID: UUID
    var totalSessions: Int
    var totalDuration: TimeInterval
    var currentStreak: Int
    var longestStreak: Int
    var achievements: [Achievement]
    var unlockedEnvironments: Set<String>
    var experiencePoints: Int
    var level: Int
}

struct Achievement: Codable, Identifiable {
    let id: String
    let name: String
    let description: String
    let iconName: String
    let unlockedAt: Date
    let experienceReward: Int
}
```

### CloudKit Schema

```swift
// CloudKit Record Types
extension CKRecord.RecordType {
    static let userProfile = "UserProfile"
    static let session = "MeditationSession"
    static let progress = "UserProgress"
    static let preferences = "Preferences"
}

// Sync Manager
class CloudKitSyncManager {
    private let container = CKContainer(identifier: "iCloud.com.mindfulness.realms")
    private let privateDatabase: CKDatabase

    init() {
        privateDatabase = container.privateCloudDatabase
    }

    func syncSession(_ session: MeditationSession) async throws {
        let record = CKRecord(recordType: .session)
        record["sessionID"] = session.id.uuidString
        record["duration"] = session.duration
        record["stressReduction"] = session.stressReduction
        // ... additional fields

        try await privateDatabase.save(record)
    }
}
```

---

## RealityKit Components & Systems

### Custom Components

```swift
// Breathing synchronization component
struct BreathingSyncComponent: Component {
    var breathingRate: Float = 0.25 // Hz (15 breaths/min)
    var expansionAmplitude: Float = 0.1
    var currentPhase: Float = 0.0
}

// Biometric response component
struct BiometricResponseComponent: Component {
    var baseColor: SIMD3<Float>
    var stressColor: SIMD3<Float>
    var calmColor: SIMD3<Float>
    var currentBlend: Float = 0.5
    var adaptationSpeed: Float = 0.5
}

// Particle emission component
struct MeditationParticleComponent: Component {
    var emitterType: ParticleEmitterType
    var emissionRate: Float
    var birthRate: Float
    var lifetime: Float
    var colorOverLife: ColorCurve
}

// Audio zone component
struct SpatialAudioZoneComponent: Component {
    var soundType: SoundType
    var volumeRadius: Float
    var falloffCurve: AudioFalloffCurve
    var is3DPositional: Bool
}
```

### RealityKit Systems

```swift
// Breathing synchronization system
class BreathingSyncSystem: System {

    static let query = EntityQuery(where: .has(BreathingSyncComponent.self))

    init(scene: Scene) {}

    func update(context: SceneUpdateContext) {
        for entity in context.entities(matching: Self.query, updatingSystemWhen: .rendering) {
            guard var breathingComp = entity.components[BreathingSyncComponent.self] else { continue }

            // Update breathing phase
            let deltaTime = Float(context.deltaTime)
            breathingComp.currentPhase += breathingComp.breathingRate * deltaTime
            breathingComp.currentPhase = breathingComp.currentPhase.truncatingRemainder(dividingBy: 1.0)

            // Calculate breathing scale
            let breathingCycle = sin(breathingComp.currentPhase * 2 * .pi)
            let scale = 1.0 + (breathingCycle * breathingComp.expansionAmplitude)

            // Apply to entity
            entity.scale = SIMD3(repeating: scale)
            entity.components[BreathingSyncComponent.self] = breathingComp
        }
    }
}

// Biometric response system
class BiometricResponseSystem: System {

    static let query = EntityQuery(where: .has(BiometricResponseComponent.self))
    private var biometricMonitor: BiometricMonitor

    init(scene: Scene, biometricMonitor: BiometricMonitor) {
        self.biometricMonitor = biometricMonitor
    }

    func update(context: SceneUpdateContext) {
        let currentBiometrics = biometricMonitor.currentSnapshot

        for entity in context.entities(matching: Self.query, updatingSystemWhen: .rendering) {
            guard var responseComp = entity.components[BiometricResponseComponent.self] else { continue }

            // Blend color based on stress/calm levels
            let targetBlend = currentBiometrics.estimatedCalmLevel
            responseComp.currentBlend = lerp(
                responseComp.currentBlend,
                targetBlend,
                responseComp.adaptationSpeed * Float(context.deltaTime)
            )

            let finalColor = mix(
                responseComp.stressColor,
                responseComp.calmColor,
                t: responseComp.currentBlend
            )

            // Apply color to entity material
            if var material = entity.components[ModelComponent.self]?.materials.first as? UnlitMaterial {
                material.color = .init(tint: .init(finalColor))
                entity.components[ModelComponent.self]?.materials = [material]
            }

            entity.components[BiometricResponseComponent.self] = responseComp
        }
    }
}
```

### Environment Rendering

```swift
// Environment renderer
class EnvironmentRenderer {
    private var scene: RealityKit.Scene
    private var rootEntity: Entity

    func loadEnvironment(_ environment: MeditationEnvironment) async throws {
        // Load environment from Reality Composer Pro
        let environmentEntity = try await Entity(named: environment.assetPath)

        // Setup breathing components
        addBreathingComponents(to: environmentEntity)

        // Setup biometric response
        addBiometricComponents(to: environmentEntity)

        // Setup particle systems
        addParticleSystems(to: environmentEntity)

        // Add to scene
        rootEntity.addChild(environmentEntity)
    }

    private func addBreathingComponents(to entity: Entity) {
        entity.enumerateHierarchy { child, _ in
            if child.name.contains("breathing") {
                child.components[BreathingSyncComponent.self] = BreathingSyncComponent()
            }
        }
    }
}
```

---

## ARKit Integration

### Room Mapping & Spatial Understanding

```swift
// Room analysis for meditation space
class RoomAnalyzer {
    private let arSession: ARKitSession
    private let worldTracking: WorldTrackingProvider
    private let sceneReconstruction: SceneReconstructionProvider

    func analyzeMeditationSpace() async throws -> MeditationSpace {
        // Start AR session
        try await arSession.run([worldTracking, sceneReconstruction])

        // Analyze room geometry
        let meshAnchors = sceneReconstruction.meshAnchors
        var floorArea: Float = 0
        var obstacleLocations: [SIMD3<Float>] = []

        for await meshAnchor in meshAnchors {
            if isFlorSurface(meshAnchor) {
                floorArea += calculateArea(meshAnchor)
            } else {
                obstacleLocations.append(meshAnchor.transform.translation)
            }
        }

        // Find optimal meditation spot
        let meditationSpot = findOptimalSpot(
            floorArea: floorArea,
            obstacles: obstacleLocations
        )

        return MeditationSpace(
            floorArea: floorArea,
            recommendedSpot: meditationSpot,
            boundaries: calculateSafeBoundaries(obstacles: obstacleLocations)
        )
    }

    private func findOptimalSpot(
        floorArea: Float,
        obstacles: [SIMD3<Float>]
    ) -> SIMD3<Float> {
        // Find location with:
        // - 1.5m radius clear space
        // - Centered in room if possible
        // - Away from windows/distractions

        // Simplified: center of available space
        return SIMD3<Float>(0, 0, -2) // 2m in front of user
    }
}
```

### Hand & Eye Tracking

```swift
// Hand tracking for meditation gestures
class HandTrackingManager {
    private let handTracking: HandTrackingProvider
    private var latestGesture: MeditationGesture?

    func startTracking() async {
        let handTrackingSession = ARKitSession()

        do {
            try await handTrackingSession.run([handTracking])

            // Monitor hand updates
            for await update in handTracking.anchorUpdates {
                processHandUpdate(update)
            }
        } catch {
            print("Hand tracking failed: \(error)")
        }
    }

    private func processHandUpdate(_ update: AnchorUpdate<HandAnchor>) {
        switch update.event {
        case .added, .updated:
            let gesture = recognizeGesture(from: update.anchor)
            if gesture != latestGesture {
                handleGestureChange(from: latestGesture, to: gesture)
                latestGesture = gesture
            }
        default:
            break
        }
    }
}

// Eye tracking for focus detection
class EyeTrackingManager {
    private var focusPoint: SIMD3<Float>?
    private var blinkRate: Double = 0

    func monitorFocus() async {
        // Track where user is looking
        // Detect meditation focus vs. wandering attention
        // Measure blink rate as stress indicator
    }
}
```

---

## AI & Biometric Systems

### Biometric Monitoring

```swift
// Heart rate and HRV monitoring
class BiometricMonitor: ObservableObject {
    @Published var currentSnapshot: BiometricSnapshot

    private var heartRateProvider: HeartRateProvider?
    private var breathingAnalyzer: BreathingAnalyzer

    func startMonitoring() async {
        // Note: Vision Pro doesn't have direct HR sensor
        // Use proxy indicators:
        // - Head movement patterns
        // - Micro-expressions
        // - Breathing estimation from body tracking

        await monitorProxyBiometrics()
    }

    private func monitorProxyBiometrics() async {
        // Estimate breathing from body micro-movements
        let breathingRate = await breathingAnalyzer.estimateBreathingRate()

        // Estimate stress from:
        // - Fidgeting (movement variance)
        // - Eye movement patterns
        // - Gesture frequency
        let stressLevel = await estimateStressLevel()

        let snapshot = BiometricSnapshot(
            timestamp: Date(),
            heartRate: nil, // Not available on VP
            hrv: nil,       // Not available on VP
            breathingRate: breathingRate,
            estimatedStressLevel: stressLevel,
            estimatedCalmLevel: 1.0 - stressLevel
        )

        await MainActor.run {
            self.currentSnapshot = snapshot
        }
    }

    private func estimateStressLevel() async -> Float {
        // Composite stress estimation from available signals
        var stressIndicators: [Float] = []

        // 1. Movement variance (fidgeting)
        let movementVariance = await measureMovementVariance()
        stressIndicators.append(movementVariance)

        // 2. Eye movement patterns (rapid scanning = stress)
        let eyeMovementRate = await measureEyeMovementRate()
        stressIndicators.append(eyeMovementRate)

        // 3. Breathing irregularity
        let breathingIrregularity = await breathingAnalyzer.measureIrregularity()
        stressIndicators.append(breathingIrregularity)

        // Weighted average
        return stressIndicators.reduce(0, +) / Float(stressIndicators.count)
    }
}
```

### AI Adaptation Engine

```swift
// Environment adaptation based on biometric feedback
class AdaptationEngine {
    private let biometricMonitor: BiometricMonitor
    private let environmentManager: EnvironmentManager

    func adaptEnvironment(to biometrics: BiometricSnapshot) {
        // Detect stress state
        if biometrics.estimatedStressLevel > 0.7 {
            // High stress - soothing interventions
            environmentManager.applyAdaptation(.soothing)
        } else if biometrics.estimatedCalmLevel > 0.8 {
            // Deep calm - maintain and deepen
            environmentManager.applyAdaptation(.deepening)
        } else {
            // Normal - gentle guidance
            environmentManager.applyAdaptation(.guiding)
        }
    }
}

// AI-generated guidance
class GuidanceGenerator {
    private let model: LanguageModel // Local on-device model

    func generateGuidance(
        userState: BiometricSnapshot,
        sessionPhase: SessionPhase,
        preferences: MeditationPreferences
    ) async -> String {
        let prompt = """
        Generate a brief, calming meditation guidance for:
        - Stress level: \(userState.estimatedStressLevel)
        - Session phase: \(sessionPhase)
        - User preference: \(preferences.guidanceStyle)

        Keep it under 20 words, soothing and present-focused.
        """

        let guidance = await model.generate(prompt: prompt)
        return guidance
    }
}
```

---

## Multiplayer Architecture

### SharePlay Integration

```swift
// Group meditation sessions via SharePlay
class GroupSessionManager: ObservableObject {
    @Published var isSessionActive = false
    @Published var participants: [Participant] = []

    private var groupSession: GroupSession<MeditationActivity>?
    private var messenger: GroupSessionMessenger?

    func startGroupSession() async throws {
        let activity = MeditationActivity()

        // Prepare for SharePlay
        switch await activity.prepareForActivation() {
        case .activationPreferred:
            groupSession = try await activity.activate()
            setupGroupSession()
        case .cancelled:
            return
        default:
            return
        }
    }

    private func setupGroupSession() {
        guard let session = groupSession else { return }

        messenger = GroupSessionMessenger(session: session)

        // Monitor participants
        Task {
            for await participant in session.$activeParticipants.values {
                updateParticipants(Array(participant))
            }
        }

        // Sync meditation state
        Task {
            guard let messenger = messenger else { return }
            for await (message, _) in messenger.messages(of: MeditationState.self) {
                handleStateSync(message)
            }
        }
    }

    func syncBreathing(_ breathingData: BreathingData) async {
        guard let messenger = messenger else { return }
        try? await messenger.send(breathingData)
    }
}

// Meditation activity for SharePlay
struct MeditationActivity: GroupActivity {
    static let activityIdentifier = "com.mindfulness.realms.group-meditation"

    var metadata: GroupActivityMetadata {
        var meta = GroupActivityMetadata()
        meta.title = "Group Meditation"
        meta.type = .generic
        meta.supportsContinuationOnTV = false
        return meta
    }
}
```

### Presence Visualization

```swift
// Show other meditators as subtle light presences
class PresenceRenderer {

    func renderParticipant(_ participant: Participant, at index: Int) -> Entity {
        // Create subtle light sphere for each participant
        let presenceEntity = Entity()

        // Position in circle around center
        let angle = (Float(index) / Float(totalParticipants)) * 2 * .pi
        let radius: Float = 2.0
        let position = SIMD3<Float>(
            x: cos(angle) * radius,
            y: 1.5, // Eye level
            z: sin(angle) * radius
        )

        presenceEntity.position = position

        // Gentle pulsing light
        let light = PointLight()
        light.light.color = .init(participant.color)
        light.light.intensity = 500
        presenceEntity.components[PointLightComponent.self] = light

        // Breathing synchronization
        presenceEntity.components[BreathingSyncComponent.self] = BreathingSyncComponent()

        return presenceEntity
    }
}
```

---

## Audio Architecture

### Spatial Audio System

```swift
// Spatial audio engine for immersive soundscapes
class SpatialAudioEngine {
    private var audioEngine: AVAudioEngine
    private var environmentNode: AVAudioEnvironmentNode

    // Audio sources
    private var ambientSource: AVAudioPlayerNode
    private var musicSource: AVAudioPlayerNode
    private var guidanceSource: AVAudioPlayerNode
    private var effectSources: [String: AVAudioPlayerNode] = [:]

    init() {
        audioEngine = AVAudioEngine()
        environmentNode = audioEngine.environmentNode

        // Configure spatial audio
        environmentNode.listenerPosition = AVAudio3DPoint(x: 0, y: 0, z: 0)
        environmentNode.listenerAngularOrientation = AVAudio3DAngularOrientation(
            yaw: 0, pitch: 0, roll: 0
        )

        setupAudioSources()
    }

    func playAmbience(_ soundscape: Soundscape, at position: SIMD3<Float>) {
        let playerNode = AVAudioPlayerNode()
        audioEngine.attach(playerNode)

        // Position in 3D space
        playerNode.position = AVAudio3DPoint(
            x: position.x,
            y: position.y,
            z: position.z
        )

        // Connect to environment
        audioEngine.connect(playerNode, to: environmentNode, format: nil)

        // Load and play audio file
        if let audioFile = loadAudioFile(soundscape.filename) {
            playerNode.scheduleFile(audioFile, at: nil, completionHandler: nil)
            playerNode.play()
        }
    }

    func updateListenerPosition(_ position: SIMD3<Float>, orientation: simd_quatf) {
        environmentNode.listenerPosition = AVAudio3DPoint(
            x: position.x,
            y: position.y,
            z: position.z
        )

        // Update orientation from quaternion
        let euler = quaternionToEuler(orientation)
        environmentNode.listenerAngularOrientation = AVAudio3DAngularOrientation(
            yaw: euler.yaw,
            pitch: euler.pitch,
            roll: euler.roll
        )
    }
}
```

### Adaptive Soundscape Mixing

```swift
// Dynamic audio mixing based on meditation state
class SoundscapeMixer {
    private var layers: [AudioLayer] = []

    struct AudioLayer {
        let type: LayerType
        var volume: Float
        var spatialPosition: SIMD3<Float>?
        let playerNode: AVAudioPlayerNode

        enum LayerType {
            case ambient       // Base environment sound
            case water         // Water sounds
            case wind          // Wind through trees
            case birds         // Bird songs
            case chimes        // Wind chimes
            case bowls         // Singing bowls
            case music         // Background music
        }
    }

    func adaptMix(to biometrics: BiometricSnapshot) {
        // High stress - increase calming water sounds
        if biometrics.estimatedStressLevel > 0.7 {
            adjustLayer(.water, targetVolume: 0.8)
            adjustLayer(.bowls, targetVolume: 0.3)
            adjustLayer(.music, targetVolume: 0.2)
        }
        // Deep calm - minimal, spacious
        else if biometrics.estimatedCalmLevel > 0.8 {
            adjustLayer(.ambient, targetVolume: 0.3)
            adjustLayer(.wind, targetVolume: 0.2)
            adjustLayer(.bowls, targetVolume: 0.1)
        }
        // Normal - balanced mix
        else {
            resetToDefaultMix()
        }
    }

    private func adjustLayer(_ type: AudioLayer.LayerType, targetVolume: Float) {
        // Smooth volume transition
        guard let index = layers.firstIndex(where: { $0.type == type }) else { return }

        let currentVolume = layers[index].volume
        let delta = targetVolume - currentVolume

        // Animate over 3 seconds
        animateVolume(layer: &layers[index], delta: delta, duration: 3.0)
    }
}
```

---

## Performance & Optimization

### Performance Budgets

```yaml
Performance_Targets:
  frame_rate: 90 fps (minimum)
  frame_time: 11.1ms (maximum)
  memory_budget: 2GB (comfortable)
  battery_drain: <20% per hour

Frame_Budget_Breakdown:
  update_logic: 2ms
  biometric_processing: 1ms
  ai_systems: 1ms
  physics: 0.5ms
  rendering: 5ms
  audio: 0.5ms
  overhead: 1ms
```

### Optimization Strategies

```swift
// LOD system for distant environment elements
class LODManager {
    func updateLODs(cameraPosition: SIMD3<Float>, entities: [Entity]) {
        for entity in entities {
            let distance = distance(entity.position, cameraPosition)

            let lodLevel: LODLevel
            if distance < 5.0 {
                lodLevel = .high
            } else if distance < 15.0 {
                lodLevel = .medium
            } else {
                lodLevel = .low
            }

            applyLOD(lodLevel, to: entity)
        }
    }

    private func applyLOD(_ level: LODLevel, to entity: Entity) {
        // Swap mesh detail
        // Adjust particle count
        // Modify texture resolution
    }
}

// Object pooling for particle effects
class ParticlePool {
    private var pool: [ParticleType: [Entity]] = [:]

    func getParticle(_ type: ParticleType) -> Entity {
        if let particle = pool[type]?.popLast() {
            particle.isEnabled = true
            return particle
        } else {
            return createParticle(type)
        }
    }

    func returnParticle(_ particle: Entity, type: ParticleType) {
        particle.isEnabled = false
        pool[type, default: []].append(particle)
    }
}
```

### Memory Management

```swift
// Efficient asset loading and unloading
class AssetManager {
    private var loadedEnvironments: [String: Entity] = [:]
    private let maxCachedEnvironments = 3

    func loadEnvironment(_ id: String) async throws -> Entity {
        // Check cache
        if let cached = loadedEnvironments[id] {
            return cached.clone(recursive: true)
        }

        // Load from disk
        let entity = try await Entity(named: "Environments/\(id)")

        // Cache management
        if loadedEnvironments.count >= maxCachedEnvironments {
            // Evict least recently used
            let lru = findLRU()
            loadedEnvironments.removeValue(forKey: lru)
        }

        loadedEnvironments[id] = entity
        return entity.clone(recursive: true)
    }
}
```

---

## Save/Load System

### Progress Persistence

```swift
// Local persistence with CloudKit sync
class PersistenceManager {
    private let userDefaults = UserDefaults.standard
    private let fileManager = FileManager.default
    private let cloudSync: CloudKitSyncManager

    // Save session
    func saveSession(_ session: MeditationSession) async throws {
        // 1. Save locally
        let encoder = JSONEncoder()
        let data = try encoder.encode(session)

        let fileURL = getSessionFileURL(session.id)
        try data.write(to: fileURL)

        // 2. Update user progress
        var progress = try await loadProgress()
        progress.totalSessions += 1
        progress.totalDuration += session.duration
        progress.updateStreak(sessionDate: session.startTime)
        try await saveProgress(progress)

        // 3. Sync to cloud
        try await cloudSync.syncSession(session)
    }

    // Load progress
    func loadProgress() async throws -> UserProgress {
        // Try local first
        if let localProgress = try? loadLocalProgress() {
            return localProgress
        }

        // Fallback to cloud
        if let cloudProgress = try? await cloudSync.fetchProgress() {
            // Cache locally
            try? saveLocalProgress(cloudProgress)
            return cloudProgress
        }

        // New user
        return UserProgress.initial
    }

    private func getSessionFileURL(_ id: UUID) -> URL {
        let directory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return directory
            .appendingPathComponent("sessions")
            .appendingPathComponent("\(id.uuidString).json")
    }
}
```

---

## Security & Privacy

### Privacy Architecture

```swift
// Privacy-first biometric processing
class PrivacyManager {

    // All biometric processing on-device only
    func processBiometrics(_ data: BiometricData) -> BiometricSnapshot {
        // Process locally - NEVER send to server
        let processed = analyzeBiometrics(data)

        // Only aggregated, anonymized stats saved
        return BiometricSnapshot(
            timestamp: Date(),
            heartRate: nil,  // Raw data not persisted
            hrv: nil,        // Raw data not persisted
            breathingRate: nil,  // Raw data not persisted
            estimatedStressLevel: processed.stressLevel,  // Aggregated only
            estimatedCalmLevel: processed.calmLevel       // Aggregated only
        )
    }

    // User data export
    func exportUserData() async throws -> UserDataExport {
        // GDPR compliance - export all user data
        let sessions = try await loadAllSessions()
        let progress = try await loadProgress()
        let preferences = try await loadPreferences()

        return UserDataExport(
            sessions: sessions,
            progress: progress,
            preferences: preferences,
            exportDate: Date()
        )
    }

    // User data deletion
    func deleteAllUserData() async throws {
        // GDPR compliance - complete data removal
        try await deleteLocalData()
        try await deleteCloudData()
        try await deleteAnalytics()
    }
}
```

---

## Conclusion

This architecture provides a robust, scalable, and privacy-focused foundation for Mindfulness Meditation Realms. The design prioritizes user comfort, leverages spatial computing capabilities, and maintains strict privacy standards while delivering an adaptive, AI-enhanced meditation experience.

### Key Architectural Principles

1. **Wellness-First**: Every system optimized for user comfort and mental health
2. **Privacy by Design**: All sensitive data processed locally
3. **Spatial Native**: Fully leverages Vision Pro's unique capabilities
4. **Performance Critical**: 90fps maintained for comfort
5. **Adaptive Intelligence**: Real-time biometric response
6. **Scalable**: Cloud sync and multiplayer ready

### Next Steps

- Review TECHNICAL_SPEC.md for implementation details
- Review DESIGN.md for UX/UI specifications
- Review IMPLEMENTATION_PLAN.md for development roadmap
