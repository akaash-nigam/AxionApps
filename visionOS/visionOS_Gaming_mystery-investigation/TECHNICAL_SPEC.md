# Mystery Investigation - Technical Specification

## Document Information
- **Version**: 1.0
- **Last Updated**: January 2025
- **Platform**: Apple Vision Pro (visionOS 2.0+)
- **Target Audience**: Development Team, QA, Product Management

---

## 1. Technology Stack

### Primary Technologies

#### Language & Frameworks
```yaml
Language:
  Primary: Swift 6.0+
  Concurrency: async/await, actors, structured concurrency

UI Framework:
  SwiftUI: 5.0+
  UIKit: Minimal (legacy compatibility only)

3D & Spatial:
  RealityKit: 2.0+
  Reality Composer Pro: Latest
  ARKit: 6.0+

Audio:
  AVFoundation: Spatial Audio
  AVAudioEngine: 3D Sound processing

Networking:
  GroupActivities: SharePlay multiplayer
  URLSession: Content downloads
  MultipeerConnectivity: Local co-op (future)

Data Persistence:
  SwiftData: Primary (visionOS 2.0+)
  CoreData: Fallback compatibility
  FileManager: Case file storage
  CloudKit: iCloud sync

AI/ML:
  CoreML: On-device NPC behavior
  CreateML: Case generation training
  Natural Language: Dialogue processing
```

### Development Tools
```yaml
Development:
  Xcode: 16.0+
  Reality Composer Pro: Latest
  Swift Package Manager: Dependency management

Performance:
  Instruments: CPU, GPU, Memory profiling
  Metal Debugger: Graphics analysis
  Network Link Conditioner: Multiplayer testing

Testing:
  XCTest: Unit testing
  XCUITest: UI automation
  TestFlight: Beta distribution

Version Control:
  Git: Source control
  GitHub Actions: CI/CD (optional)
```

---

## 2. Game Mechanics Implementation

### Evidence Collection System

#### Proximity Detection
```swift
// Evidence Discovery Range
let proximityRadius: Float = 2.0 // meters
let interactionRadius: Float = 0.5 // meters
let gazeActivationAngle: Float = 10.0 // degrees

// Detection algorithm
func checkEvidenceProximity(player: PlayerPosition, evidence: EvidenceEntity) -> Bool {
    let distance = simd_distance(player.position, evidence.position)
    return distance <= proximityRadius
}
```

#### Gaze-Based Highlighting
```swift
// Eye tracking configuration
struct GazeConfig {
    static let dwellTime: TimeInterval = 0.3 // seconds to activate
    static let highlightColor = Color.yellow.opacity(0.6)
    static let pulseAnimation = Animation.easeInOut(duration: 1.0).repeatForever()
}

// Shader for evidence highlighting
let evidenceHighlightMaterial = ShaderGraphMaterial(
    named: "EvidenceGlow",
    in: realityKitContentBundle
)
```

#### Hand Tracking Gestures
```swift
enum InvestigationGesture: String {
    case pinchToPickup      // Thumb + index pinch
    case spreadToMagnify    // Two-hand spread
    case swipeToRotate      // Single hand swipe
    case airWriting         // Index finger extended
    case doubleTabDismiss   // Quick double pinch
}

struct GestureThresholds {
    static let pinchThreshold: Float = 0.02 // meters between thumb and index
    static let spreadMinDistance: Float = 0.3 // meters between hands
    static let swipeMinVelocity: Float = 0.5 // m/s
}
```

### Forensic Tool Simulation

#### Magnifying Glass
```swift
struct MagnifyingGlassConfig {
    static let magnificationLevels: [Float] = [2.0, 5.0, 10.0]
    static let focusDepth: Float = 0.15 // meters from lens
    static let viewportSize: CGSize = CGSize(width: 0.2, height: 0.2) // meters
}

// Shader for magnification effect
// Uses depth-based rendering with focal blur
```

#### UV Light Tool
```swift
struct UVLightConfig {
    static let wavelength: Float = 365 // nanometers
    static let coneAngle: Float = 45 // degrees
    static let maxRange: Float = 2.0 // meters
    static let revealDuration: TimeInterval = 1.5 // seconds to full reveal
}

// Reveals hidden evidence using emission shader
```

#### Fingerprint Dusting Kit
```swift
struct FingerprintKitConfig {
    static let brushStrokeWidth: Float = 0.01 // meters
    static let dustingProgress: Float = 0.0...1.0
    static let revealThreshold: Float = 0.7 // 70% dusted to reveal
    static let strokeSampleRate: Int = 60 // Hz
}

// Implements particle system for powder application
```

### Interrogation System

#### Dialogue Tree Structure
```swift
struct DialogueNode: Codable, Identifiable {
    let id: UUID
    let speakerID: UUID // Suspect ID
    let text: String
    let emotionalTone: EmotionalTone
    let triggers: [DialogueTrigger]
    let responses: [DialogueChoice]

    enum EmotionalTone: String, Codable {
        case neutral, nervous, defensive, cooperative,
             angry, fearful, deceptive, truthful
    }
}

struct DialogueChoice: Codable, Identifiable {
    let id: UUID
    let promptText: String
    let requiresEvidence: UUID? // Optional evidence to unlock
    let nextNodeID: UUID
    let suspectReaction: SuspectReaction
    let progressValue: Float // 0-1, how much closer to confession
}
```

#### NPC Behavior Simulation
```swift
class NPCBehaviorModel {
    // Stress level increases with evidence pressure
    var stressLevel: Float = 0.0 // 0-1

    // Affects dialogue choices and body language
    var currentEmotion: EmotionalState

    // Memory of previous questions and evidence shown
    var conversationMemory: [DialogueNode]

    // Determines when suspect breaks down or confesses
    let confessionThreshold: Float = 0.85

    func processEvidencePresentation(_ evidence: Evidence) {
        if evidence.relatedSuspects.contains(suspect.id) {
            stressLevel += 0.15
            if stressLevel > confessionThreshold {
                triggerConfession()
            }
        }
    }
}
```

### Crime Scene Reconstruction

#### Timeline Visualization
```swift
struct TimelineEvent: Codable, Identifiable {
    let id: UUID
    let timestamp: Date // Relative to crime time
    let location: SIMD3<Float>
    let eventType: EventType
    let participants: [UUID] // Suspect/victim IDs
    let evidenceCreated: [UUID] // Evidence left behind
    let animationSequence: String // RealityKit animation

    enum EventType: String, Codable {
        case arrival, interaction, crime, departure, cleanup
    }
}

// Timeline playback system
class TimelinePlayback {
    var playbackSpeed: Float = 1.0 // 1x real-time
    var currentTime: TimeInterval = 0

    func playTimeline(_ events: [TimelineEvent]) {
        // Animate holographic recreation of events
        // Show suspect movements through space
        // Highlight evidence creation moments
    }
}
```

---

## 3. Spatial Computing Specifications

### Room Scanning & Mapping

#### ARKit Configuration
```swift
struct RoomScanningConfig {
    // World tracking configuration
    static let worldTracking = WorldTrackingProvider()

    // Scene reconstruction settings
    static let sceneReconstruction = SceneReconstructionProvider(
        modes: [.classification]
    )

    // Plane detection
    static let planeDetection: PlaneDetectionProvider.PlaneDetections = [
        .horizontal, .vertical
    ]

    // Mesh granularity
    static let meshDetail: SceneReconstructionProvider.MeshDetail = .medium
}
```

#### Spatial Anchor Persistence
```swift
class SpatialAnchorManager {
    // Anchor storage
    private var anchors: [UUID: AnchorEntity] = [:]

    // Persistence key format
    func persistenceKey(for evidenceID: UUID, caseID: UUID) -> String {
        return "evidence_\(caseID)_\(evidenceID)"
    }

    // Save anchor to WorldAnchor system
    func saveAnchor(_ anchor: AnchorEntity, for evidence: Evidence) async throws {
        let key = persistenceKey(for: evidence.id, caseID: currentCase.id)
        try await WorldAnchor.save(anchor, identifier: key)
    }

    // Load anchor from previous session
    func loadAnchor(for evidence: Evidence) async throws -> AnchorEntity? {
        let key = persistenceKey(for: evidence.id, caseID: currentCase.id)
        return try await WorldAnchor.load(identifier: key)
    }
}
```

### Space Requirements & Boundaries

#### Play Area Specifications
```swift
struct PlayAreaConfig {
    // Minimum viable play area
    static let minimumWidth: Float = 2.0 // meters
    static let minimumDepth: Float = 2.0 // meters
    static let minimumHeight: Float = 2.0 // meters

    // Recommended play area
    static let recommendedWidth: Float = 3.0
    static let recommendedDepth: Float = 3.0
    static let recommendedHeight: Float = 2.5

    // Maximum supported area
    static let maximumWidth: Float = 5.0
    static let maximumDepth: Float = 5.0

    // Safety buffer from walls
    static let safetyBuffer: Float = 0.3 // meters
}
```

#### Boundary Visualization
```swift
class BoundarySystem {
    // Visual boundary when player approaches edge
    func showBoundaryWarning(distanceToWall: Float) {
        if distanceToWall < PlayAreaConfig.safetyBuffer {
            // Display translucent wall indicator
            // Haptic warning
            // Slow player movement near boundary
        }
    }

    // Adapt evidence placement to room size
    func adaptEvidenceLayout(roomSize: SIMD3<Float>) {
        let scale = min(roomSize.x / PlayAreaConfig.recommendedWidth,
                       roomSize.z / PlayAreaConfig.recommendedDepth)
        // Scale evidence distribution accordingly
    }
}
```

---

## 4. Control Schemes & Input

### Hand Tracking Implementation

#### Gesture Recognition
```swift
class HandGestureRecognizer {
    // Hand tracking provider
    private let handTracking = HandTrackingProvider()

    // Gesture detection thresholds
    struct GestureThresholds {
        static let pinchDistance: Float = 0.02 // m
        static let pinchHoldDuration: TimeInterval = 0.1 // s
        static let swipeMinDistance: Float = 0.15 // m
        static let swipeMaxDuration: TimeInterval = 0.5 // s
    }

    // Main gesture detection
    func detectGesture(from handAnchor: HandAnchor) -> InvestigationGesture? {
        // Check for pinch
        if isPinching(handAnchor) {
            return .pinchToPickup
        }

        // Check for spread (two-hand gesture)
        if let otherHand = otherHandAnchor,
           isSpreadGesture(handAnchor, otherHand) {
            return .spreadToMagnify
        }

        // Check for swipe
        if isSwipeGesture(handAnchor) {
            return .swipeToRotate
        }

        return nil
    }

    // Pinch detection
    func isPinching(_ hand: HandAnchor) -> Bool {
        guard let thumbTip = hand.handSkeleton?.joint(.thumbTip),
              let indexTip = hand.handSkeleton?.joint(.indexFingerTip) else {
            return false
        }

        let distance = simd_distance(
            thumbTip.anchorFromJointTransform.columns.3.xyz,
            indexTip.anchorFromJointTransform.columns.3.xyz
        )

        return distance < GestureThresholds.pinchDistance
    }
}
```

### Eye Tracking Integration

#### Gaze Detection System
```swift
class GazeTrackingSystem {
    private var eyeTracking: EyeTrackingProvider?

    struct GazeConfig {
        static let raycastMaxDistance: Float = 10.0 // meters
        static let dwellTimeForSelection: TimeInterval = 0.5
        static let gazeStabilityThreshold: Float = 0.05 // meters
    }

    // Cast ray from eyes to detect focused entity
    func performGazeRaycast(in scene: RealityKit.Scene) -> Entity? {
        guard let eyeTracking = eyeTracking,
              let gazeAnchor = eyeTracking.latestAnchor else {
            return nil
        }

        // Get gaze direction
        let origin = gazeAnchor.originFromAnchorTransform.columns.3.xyz
        let direction = -gazeAnchor.originFromAnchorTransform.columns.2.xyz

        // Raycast into scene
        let results = scene.raycast(
            origin: origin,
            direction: direction,
            length: GazeConfig.raycastMaxDistance,
            query: .all,
            mask: .default,
            relativeTo: nil
        )

        return results.first?.entity
    }

    // Dwell time tracking for gaze selection
    private var gazedEntity: Entity?
    private var gazeDwellStart: Date?

    func updateGazeDwell(focusedEntity: Entity?) {
        if focusedEntity == gazedEntity {
            // Still gazing at same entity
            if let startTime = gazeDwellStart,
               Date().timeIntervalSince(startTime) > GazeConfig.dwellTimeForSelection {
                // Dwell time exceeded - trigger selection
                selectEntity(focusedEntity)
            }
        } else {
            // Gaze shifted to new entity
            gazedEntity = focusedEntity
            gazeDwellStart = Date()
        }
    }
}
```

### Voice Command System

#### Speech Recognition
```swift
class VoiceCommandSystem {
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))

    enum VoiceCommand: String, CaseIterable {
        // Evidence commands
        case collectEvidence = "collect evidence"
        case examineCloser = "examine closer"
        case takePhoto = "take photo"
        case bagEvidence = "bag evidence"

        // Interrogation commands
        case askAboutAlibi = "ask about alibi"
        case showEvidence = "show evidence"
        case pressHarder = "press harder"
        case endInterview = "end interview"

        // Navigation commands
        case showCaseBoard = "show case board"
        case reviewEvidence = "review evidence"
        case constructTimeline = "construct timeline"

        // Note-taking commands
        case noteColon = "note:"
        case theoryColon = "theory:"
        case reminderColon = "reminder:"
    }

    // Process spoken command
    func processCommand(_ transcription: String) -> VoiceCommand? {
        let normalized = transcription.lowercased().trimmingCharacters(in: .whitespaces)
        return VoiceCommand.allCases.first { normalized.contains($0.rawValue) }
    }

    // Dictation for note-taking
    func startDictation(noteType: NoteType) {
        // Continuous recognition for open-ended note-taking
    }
}
```

### Game Controller Support (Optional)

#### Controller Mapping
```swift
struct ControllerMapping {
    // Left stick: Move player focus
    // Right stick: Rotate examined evidence
    // A button: Select/pickup
    // B button: Cancel/back
    // X button: Use active tool
    // Y button: Open case board
    // Left bumper: Previous evidence
    // Right bumper: Next evidence
    // Left trigger: Zoom in
    // Right trigger: Zoom out
    // Menu button: Pause
}
```

---

## 5. Physics & Collision

### RealityKit Physics Configuration

#### Evidence Physics
```swift
struct EvidencePhysicsConfig {
    // Physics body settings
    static func configureEvidencePhysics(_ entity: Entity, mass: Float) {
        entity.components[PhysicsBodyComponent.self] = PhysicsBodyComponent(
            massProperties: .default,
            material: .generate(
                staticFriction: 0.8,
                dynamicFriction: 0.6,
                restitution: 0.3
            ),
            mode: .dynamic
        )
    }

    // Collision settings
    static func configureCollision(_ entity: Entity) {
        entity.components[CollisionComponent.self] = CollisionComponent(
            shapes: [.generateBox(size: entity.visualBounds(relativeTo: nil).extents)],
            mode: .trigger,
            filter: CollisionFilter(
                group: .evidence,
                mask: [.player, .environment]
            )
        )
    }
}

// Collision groups
extension CollisionGroup {
    static let evidence = CollisionGroup(rawValue: 1 << 0)
    static let player = CollisionGroup(rawValue: 1 << 1)
    static let environment = CollisionGroup(rawValue: 1 << 2)
    static let suspect = CollisionGroup(rawValue: 1 << 3)
}
```

#### Interaction Physics
```swift
class InteractionPhysicsManager {
    // Smooth pickup with spring joint
    func pickupEvidence(_ entity: Entity, to hand: SIMD3<Float>) {
        // Create spring joint between hand and evidence
        let joint = PhysicsJoint.spring(
            from: handEntity,
            to: entity,
            stiffness: 100,
            damping: 10
        )

        // Apply to physics simulation
        entity.components[JointComponent.self] = JointComponent(joint: joint)
    }

    // Release evidence with natural drop
    func releaseEvidence(_ entity: Entity) {
        entity.components.remove(JointComponent.self)
        // Gravity takes over
    }
}
```

---

## 6. Rendering & Graphics

### Performance Targets
```swift
struct RenderingTargets {
    static let targetFrameRate: Int = 90 // Hz
    static let minimumFrameRate: Int = 60 // Hz
    static let maximumLatency: TimeInterval = 0.02 // 20ms

    // Resolution (per eye)
    static let targetResolution = CGSize(width: 1920, height: 1920)

    // Draw call budget
    static let maxDrawCallsPerFrame: Int = 500
    static let maxTrianglesPerFrame: Int = 1_000_000
}
```

### Material System
```swift
class MaterialLibrary {
    // Evidence materials
    static let paperMaterial = SimpleMaterial(
        color: .white,
        roughness: 0.8,
        isMetallic: false
    )

    static let metalEvidenceMaterial = SimpleMaterial(
        color: .init(white: 0.7, alpha: 1.0),
        roughness: 0.3,
        isMetallic: true
    )

    // Highlight materials (shader-based)
    static let gazeHighlight = try! ShaderGraphMaterial(
        named: "GazeHighlight",
        in: realityKitContentBundle
    )

    static let selectedHighlight = try! ShaderGraphMaterial(
        named: "SelectedPulse",
        in: realityKitContentBundle
    )

    // Hologram material for suspects
    static let hologramMaterial = try! ShaderGraphMaterial(
        named: "HologramShader",
        in: realityKitContentBundle
    )
}
```

### Level of Detail (LOD)
```swift
class LODManager {
    struct LODLevels {
        static let highDetail: Float = 1.0 // < 1m distance
        static let mediumDetail: Float = 3.0 // 1-3m distance
        static let lowDetail: Float = Float.infinity // > 3m distance
    }

    func updateLOD(entity: Entity, distanceFromPlayer: Float) {
        var modelComponent = entity.components[ModelComponent.self]

        switch distanceFromPlayer {
        case 0..<LODLevels.highDetail:
            modelComponent?.mesh = highDetailMesh
        case LODLevels.highDetail..<LODLevels.mediumDetail:
            modelComponent?.mesh = mediumDetailMesh
        default:
            modelComponent?.mesh = lowDetailMesh
        }

        entity.components[ModelComponent.self] = modelComponent
    }
}
```

---

## 7. Multiplayer Technical Specification

### SharePlay Architecture
```swift
struct InvestigationActivity: GroupActivity {
    static let activityIdentifier = "com.mysterygame.investigation"

    var metadata: GroupActivityMetadata {
        var metadata = GroupActivityMetadata()
        metadata.title = "Mystery Investigation"
        metadata.type = .generic
        metadata.supportsContinuationOnTV = false
        return metadata
    }
}

class MultiplayerSession: ObservableObject {
    private var groupSession: GroupSession<InvestigationActivity>?
    private var messenger: GroupSessionMessenger?
    private var syncEngine: SyncEngine?

    // Synchronized state
    struct SharedInvestigationState: Codable {
        var discoveredEvidence: Set<UUID>
        var currentCase: UUID
        var investigationProgress: Float
        var sharedNotes: [InvestigationNote]
        var activeInterrogation: UUID?
    }

    // Send evidence discovery to all participants
    func syncEvidenceDiscovery(_ evidenceID: UUID) async throws {
        guard let messenger = messenger else { return }

        let message = EvidenceDiscoveredMessage(evidenceID: evidenceID)
        try await messenger.send(message)
    }
}
```

### Network Synchronization
```swift
struct NetworkConfig {
    // Update rates
    static let evidenceUpdateRate: TimeInterval = 0.1 // 10 Hz
    static let suspectStateUpdateRate: TimeInterval = 0.05 // 20 Hz
    static let positionUpdateRate: TimeInterval = 0.033 // 30 Hz

    // Bandwidth limits
    static let maxBandwidthKBps: Int = 50 // KB/s per player

    // Latency targets
    static let maxAcceptableLatency: TimeInterval = 0.2 // 200ms
}
```

---

## 8. Performance Specifications

### Memory Budget
```swift
struct MemoryBudget {
    // App memory limits
    static let baseAppMemory: Int = 500 * 1024 * 1024 // 500 MB
    static let perCaseMemory: Int = 200 * 1024 * 1024 // 200 MB
    static let audioBufferMemory: Int = 50 * 1024 * 1024 // 50 MB

    // Texture memory
    static let texturePoolSize: Int = 100 * 1024 * 1024 // 100 MB

    // Entity limits
    static let maxSimultaneousEntities: Int = 500
    static let maxPhysicsBodies: Int = 100
}
```

### Battery Optimization
```swift
class PowerManagement {
    // Reduce rendering quality to save battery
    func enablePowerSavingMode() {
        // Reduce shadow quality
        // Lower physics update rate
        // Reduce particle effects
        // Lower audio processing quality
    }

    // Target battery consumption
    struct BatteryTargets {
        static let targetSessionLength: TimeInterval = 60 * 60 // 60 minutes
        static let batteryConsumptionRate: Float = 0.15 // 15% per 60 min
    }
}
```

---

## 9. Data Persistence Specification

### Save File Format
```swift
struct SaveFileFormat: Codable {
    let version: Int = 1
    let timestamp: Date
    let playerID: UUID

    // Player progress
    let completedCases: [UUID]
    let inProgressCases: [UUID: CaseProgress]
    let unlockedTools: Set<String>
    let achievements: [Achievement]

    // Settings
    let gameSettings: GameSettings
    let comfortSettings: ComfortSettings
    let accessibilitySettings: AccessibilitySettings

    // Statistics
    let stats: PlayerStatistics
}

struct CaseProgress: Codable {
    let caseID: UUID
    let discoveredEvidence: Set<UUID>
    let interrogationProgress: [UUID: DialogueProgress]
    let notes: [InvestigationNote]
    let theoryState: TheoryState?
    let timeSpent: TimeInterval
    let lastPlayed: Date
}
```

### Cloud Sync Specification
```swift
class CloudSyncManager {
    // iCloud container
    private let container = CKContainer(identifier: "iCloud.com.mysterygame.investigation")

    // Sync frequency
    struct SyncConfig {
        static let autoSyncInterval: TimeInterval = 300 // 5 minutes
        static let maxSyncRetries: Int = 3
        static let syncTimeout: TimeInterval = 30
    }

    // Conflict resolution
    func resolveConflict(local: SaveFileFormat, remote: SaveFileFormat) -> SaveFileFormat {
        // Use most recent timestamp
        // Merge discovered evidence (union)
        // Preserve highest progress
        return local.timestamp > remote.timestamp ? local : remote
    }
}
```

---

## 10. Testing Requirements

### Unit Test Coverage
```swift
// Minimum test coverage: 70%

@testable import MysteryInvestigation

class EvidenceTests: XCTestCase {
    func testEvidenceDiscovery() { }
    func testForensicAnalysis() { }
    func testEvidenceCollectionPhysics() { }
}

class InterrogationTests: XCTestCase {
    func testDialogueProgression() { }
    func testSuspectBehaviorUnderPressure() { }
    func testEvidencePresentation() { }
}

class SpatialTests: XCTestCase {
    func testAnchorPersistence() { }
    func testRoomAdaptation() { }
    func testBoundaryDetection() { }
}
```

### Performance Testing
```swift
class PerformanceTests: XCTestCase {
    func testFrameRateStability() {
        measure {
            // Run full investigation scene for 60 seconds
            // Assert average FPS > 60
        }
    }

    func testMemoryUsage() {
        // Load complete case
        // Assert memory < MemoryBudget.perCaseMemory
    }

    func testLoadingTimes() {
        measure {
            // Load case
            // Assert load time < 3 seconds
        }
    }
}
```

---

## 11. Accessibility Requirements

### VoiceOver Support
```swift
// All interactive elements must have accessibility labels
extension EvidenceEntity {
    var accessibilityLabel: String {
        return "Evidence: \(evidence.name). \(evidence.description)"
    }

    var accessibilityHint: String {
        return "Double tap to examine. Swipe down to collect."
    }
}
```

### Alternative Controls
```swift
struct AccessibilityControlScheme {
    // One-handed operation
    static let oneHandedMode: Bool

    // Simplified gestures
    static let simpleGesturesOnly: Bool

    // Extended interaction time
    static let extendedGazeDwell: TimeInterval = 1.5 // vs 0.5 default

    // Audio cues
    static let enhancedAudioFeedback: Bool
}
```

---

## 12. Localization & Regional Support

### Supported Languages (Phase 1)
```swift
enum SupportedLanguage: String, CaseIterable {
    case english = "en"
    case spanish = "es"
    case french = "fr"
    case german = "de"
    case japanese = "ja"
    case chineseSimplified = "zh-Hans"
}
```

### Text-to-Speech for Dialogue
```swift
class DialogueSynthesizer {
    private let synthesizer = AVSpeechSynthesizer()

    func speakDialogue(_ text: String, voice: AVSpeechSynthesisVoice, emotion: EmotionalTone) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = voice
        utterance.rate = adjustRate(for: emotion)
        utterance.pitchMultiplier = adjustPitch(for: emotion)

        synthesizer.speak(utterance)
    }
}
```

---

## 13. Analytics & Telemetry

### Events Tracked
```swift
enum AnalyticsEvent: String {
    // Case events
    case caseStarted
    case caseCompleted
    case caseAbandoned

    // Evidence events
    case evidenceDiscovered
    case evidenceExamined
    case forensicToolUsed

    // Interrogation events
    case interrogationStarted
    case questionAsked
    case evidencePresented
    case confessionReceived

    // Performance events
    case frameRateDropped
    case loadTimeExceeded
    case crashOccurred
}

struct AnalyticsConfig {
    static let trackingEnabled: Bool = true
    static let personalDataCollection: Bool = false // Privacy-first
    static let batchUploadInterval: TimeInterval = 3600 // 1 hour
}
```

---

## 14. Security & Privacy

### Data Privacy Policy
```swift
struct PrivacyConfig {
    // Spatial data
    static let spatialDataStaysOnDevice: Bool = true
    static let roomGeometryNotUploaded: Bool = true

    // User data
    static let noPersonalDataCollection: Bool = true
    static let encryptSaveFiles: Bool = true

    // Analytics
    static let anonymizedAnalytics: Bool = true
    static let optOutAvailable: Bool = true
}
```

### Encryption
```swift
class EncryptionManager {
    private let key = SymmetricKey(size: .bits256)

    func encryptSaveFile(_ data: Data) throws -> Data {
        let sealedBox = try AES.GCM.seal(data, using: key)
        return sealedBox.combined ?? Data()
    }

    func decryptSaveFile(_ data: Data) throws -> Data {
        let sealedBox = try AES.GCM.SealedBox(combined: data)
        return try AES.GCM.open(sealedBox, using: key)
    }
}
```

---

## 15. Build & Deployment

### Build Configuration
```swift
// Debug Build
#if DEBUG
let logLevel: LogLevel = .verbose
let showDebugOverlay: Bool = true
let skipIntros: Bool = true
#else
// Release Build
let logLevel: LogLevel = .errors
let showDebugOverlay: Bool = false
let skipIntros: Bool = false
#endif
```

### App Store Requirements
```yaml
App Information:
  Bundle ID: com.mysterygame.investigation
  Version: 1.0.0
  Min visionOS: 2.0
  Category: Games
  Age Rating: 12+ (Mild Violence, Mature Themes)

Privacy:
  Camera: No
  Microphone: Yes (Voice Commands)
  Hand Tracking: Yes
  World Sensing: Yes (Room Mapping)

Capabilities:
  - Immersive Spaces
  - SharePlay
  - iCloud
  - Spatial Audio
```

---

## Conclusion

This technical specification provides comprehensive implementation details for Mystery Investigation on visionOS. All systems are designed for optimal performance, user comfort, and privacy while delivering an immersive detective experience.

**Key Technical Highlights:**
- 90 FPS rendering target with LOD optimization
- On-device spatial data processing for privacy
- Natural hand/eye tracking for intuitive interaction
- SharePlay multiplayer with real-time sync
- Robust save system with iCloud backup
- Comprehensive accessibility support

Development should proceed according to the implementation plan with continuous performance profiling and user testing.
