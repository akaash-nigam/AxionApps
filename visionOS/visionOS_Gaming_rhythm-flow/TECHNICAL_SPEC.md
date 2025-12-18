# Rhythm Flow - Technical Specifications

## Document Overview

This document provides detailed technical specifications for implementing Rhythm Flow, including technology stack, system requirements, API specifications, performance requirements, and testing criteria.

**Version:** 1.0
**Last Updated:** 2025-01-20
**Target Platform:** visionOS 2.0+ (Apple Vision Pro)

---

## Table of Contents

1. [Technology Stack](#technology-stack)
2. [System Requirements](#system-requirements)
3. [Game Mechanics Implementation](#game-mechanics-implementation)
4. [Control Schemes](#control-schemes)
5. [Physics Specifications](#physics-specifications)
6. [Rendering Requirements](#rendering-requirements)
7. [Audio Specifications](#audio-specifications)
8. [Networking & Multiplayer](#networking--multiplayer)
9. [Performance Requirements](#performance-requirements)
10. [Testing Requirements](#testing-requirements)
11. [API Specifications](#api-specifications)
12. [File Formats & Data Structures](#file-formats--data-structures)

---

## Technology Stack

### Core Technologies

#### Swift & SwiftUI
```yaml
Language: Swift 6.0+
UI Framework: SwiftUI 6.0+
Concurrency: Swift Concurrency (async/await)
Features Used:
  - Structured concurrency
  - Actors for thread-safe state
  - AsyncSequence for event streams
  - Observation framework
```

#### RealityKit
```yaml
Version: RealityKit 4.0+ (visionOS 2.0)
Features:
  - Entity-Component-System (ECS)
  - Custom components and systems
  - Particle effects
  - Spatial audio integration
  - Physics simulation
  - Custom materials and shaders
  - Anchor-based positioning
```

#### ARKit
```yaml
Version: ARKit 6.0+ (visionOS)
Features:
  - Hand tracking
  - World tracking
  - Scene reconstruction
  - Room mesh detection
  - Plane detection
  - Spatial anchors
```

#### Audio Technologies
```yaml
Spatial Audio: AVAudioEngine with AVAudioEnvironmentNode
Music Playback: AVAudioPlayerNode
File Formats: AAC, ALAC, MP3, FLAC
Streaming: AVAssetResourceLoader
Analysis: Accelerate framework, CoreML
```

#### Machine Learning
```yaml
Framework: CoreML 8.0+
Models:
  - Audio analysis (beat detection)
  - Difficulty adjustment (regression)
  - Movement quality (classification)
  - Music recommendation (ranking)
Training: CreateML, PyTorch → CoreML conversion
On-device: All inference runs locally
```

#### Networking
```yaml
Framework: Network.framework
Protocols: TCP, UDP (for real-time multiplayer)
SharePlay: GroupActivities framework
Cloud: CloudKit (CKDatabase, CKRecord)
```

#### Data Persistence
```yaml
Local: FileManager + JSON/PropertyList
Cache: NSCache for in-memory objects
Cloud: CloudKit private database
HealthKit: HKHealthStore for fitness data
GameCenter: GKLeaderboard, GKAchievement
```

### Development Tools

```yaml
IDE: Xcode 16.0+
Reality Composer Pro: 2.0+
Simulator: visionOS Simulator
Profiling: Instruments
  - Time Profiler
  - Allocations
  - Metal System Trace
  - Energy Log
Version Control: Git
CI/CD: GitHub Actions / Xcode Cloud
```

### Third-Party Dependencies

```yaml
# Minimal external dependencies - prefer Apple frameworks

Recommended SPM Packages:
  - Swift Algorithms (Apple)
  - Swift Collections (Apple)
  - Swift Numerics (Apple)

Music Services (Optional):
  - MusicKit (Apple Music integration)
  - Spotify SDK (if partnership secured)
```

---

## System Requirements

### Hardware Requirements

```yaml
Minimum:
  Device: Apple Vision Pro (1st generation)
  Storage: 2 GB free space (base game)
  Memory: Runs within visionOS memory limits

Recommended:
  Storage: 10 GB (base game + song packs)
  Play Space: 2.5m x 2.5m clear area
  Internet: For multiplayer and song downloads
```

### Software Requirements

```yaml
Operating System: visionOS 2.0 or later
Apple Services:
  - Apple ID (required)
  - iCloud account (for save sync)
  - Game Center (for leaderboards)
  - HealthKit authorization (optional)
  - Music streaming service (optional)
```

### Runtime Permissions

```yaml
Required:
  - Hand tracking
  - World sensing
  - Local network (for SharePlay)

Optional:
  - HealthKit (fitness tracking)
  - Music library access
  - Camera access (for AR features)
  - Notifications (reminders)
```

---

## Game Mechanics Implementation

### Note Spawning System

```swift
// Note Spawn Specification
struct NoteSpawnSpec {
    // Timing
    let spawnLeadTime: TimeInterval = 2.0      // Spawn 2s before hit time
    let approachDuration: TimeInterval = 1.5   // Time to reach player

    // Positioning
    let spawnDistance: Float = 3.0              // Meters from player
    let hitDistance: Float = 0.8                // Optimal hit zone distance

    // Difficulty-based adjustments
    var speedMultiplier: Float {
        switch difficulty {
        case .easy: return 0.7
        case .normal: return 1.0
        case .hard: return 1.3
        case .expert: return 1.6
        case .expertPlus: return 2.0
        }
    }

    // Spawn patterns
    enum SpawnPattern {
        case straightLine       // Traditional highway
        case circular          // 360° ring
        case spiral            // Rotating approach
        case cascade           // Rain from above
        case scatter           // Random positions
        case wave              // Synchronized groups
    }
}

// Note Spawn Algorithm
class NoteSpawner {
    func spawnNote(_ event: NoteEvent, pattern: SpawnPattern) -> NoteEntity {
        // 1. Calculate spawn position
        let spawnPos = calculateSpawnPosition(event, pattern)

        // 2. Calculate approach path
        let path = calculateApproachPath(from: spawnPos, to: event.position)

        // 3. Create note entity
        let note = NoteEntity(event: event)
        note.position = spawnPos
        note.approachPath = path

        // 4. Configure movement
        let duration = spec.approachDuration / Double(spec.speedMultiplier)
        note.animateAlongPath(path, duration: duration)

        // 5. Add to scene
        gameScene.addChild(note)

        return note
    }

    func calculateSpawnPosition(_ event: NoteEvent, _ pattern: SpawnPattern) -> SIMD3<Float> {
        switch pattern {
        case .straightLine:
            return event.position + SIMD3<Float>(0, 0, -spec.spawnDistance)

        case .circular:
            let angle = event.timestamp.truncatingRemainder(dividingBy: .pi * 2)
            let radius = spec.spawnDistance
            return SIMD3<Float>(
                cos(Float(angle)) * radius,
                event.position.y,
                sin(Float(angle)) * radius
            )

        case .cascade:
            return SIMD3<Float>(
                event.position.x,
                event.position.y + spec.spawnDistance,
                event.position.z
            )

        // ... other patterns
        }
    }
}
```

### Hit Detection System

```swift
// Hit Detection Specification
struct HitDetectionSpec {
    // Timing windows (seconds)
    let perfectWindow: TimeInterval = 0.050    // ±50ms
    let greatWindow: TimeInterval = 0.100      // ±100ms
    let goodWindow: TimeInterval = 0.150       // ±150ms
    let okayWindow: TimeInterval = 0.200       // ±200ms

    // Spatial windows (meters)
    let perfectRadius: Float = 0.05            // 5cm
    let greatRadius: Float = 0.10              // 10cm
    let goodRadius: Float = 0.15               // 15cm
    let okayRadius: Float = 0.20               // 20cm

    // Score values
    let perfectScore: Int = 115
    let greatScore: Int = 100
    let goodScore: Int = 75
    let okayScore: Int = 50
    let missScore: Int = 0

    // Multipliers
    let comboMultiplier: [Int: Float] = [
        10: 1.1,
        25: 1.25,
        50: 1.5,
        100: 2.0
    ]
}

// Hit Detection Algorithm
class HitDetector {
    func checkHit(note: NoteEntity, hand: HandEntity) -> HitResult? {
        // 1. Check timing
        let currentTime = musicSync.currentMusicTime
        let targetTime = note.targetTime
        let timingError = abs(currentTime - targetTime)

        guard timingError <= spec.okayWindow else {
            return nil  // Outside timing window
        }

        // 2. Check spatial distance
        let distance = simd_distance(note.position, hand.position)

        guard distance <= spec.okayRadius else {
            return nil  // Too far away
        }

        // 3. Verify gesture
        let gestureMatches = verifyGesture(
            required: note.requiredGesture,
            detected: hand.currentGesture
        )

        guard gestureMatches else {
            return HitResult(quality: .miss, reason: .wrongGesture)
        }

        // 4. Verify hand
        let handMatches = note.requiredHand == .both ||
                         note.requiredHand == hand.chirality

        guard handMatches else {
            return HitResult(quality: .miss, reason: .wrongHand)
        }

        // 5. Calculate hit quality
        let quality = calculateHitQuality(timingError, distance)

        // 6. Return result
        return HitResult(
            quality: quality,
            timingError: timingError,
            spatialError: distance,
            timestamp: currentTime
        )
    }

    func calculateHitQuality(_ timing: TimeInterval, _ distance: Float) -> HitQuality {
        // Both timing and distance must meet threshold
        if timing <= spec.perfectWindow && distance <= spec.perfectRadius {
            return .perfect
        } else if timing <= spec.greatWindow && distance <= spec.greatRadius {
            return .great
        } else if timing <= spec.goodWindow && distance <= spec.goodRadius {
            return .good
        } else {
            return .okay
        }
    }
}
```

### Scoring System

```swift
// Scoring Specification
class ScoreManager {
    private(set) var currentScore: Int = 0
    private(set) var currentCombo: Int = 0
    private(set) var maxCombo: Int = 0
    private(set) var multiplier: Float = 1.0

    // Statistics
    private(set) var perfectHits: Int = 0
    private(set) var greatHits: Int = 0
    private(set) var goodHits: Int = 0
    private(set) var okayHits: Int = 0
    private(set) var missedNotes: Int = 0

    func registerHit(_ result: HitResult, noteValue: Int) {
        switch result.quality {
        case .perfect:
            perfectHits += 1
            currentCombo += 1
            addScore(spec.perfectScore + noteValue, multiplier: calculateMultiplier())

        case .great:
            greatHits += 1
            currentCombo += 1
            addScore(spec.greatScore + noteValue, multiplier: calculateMultiplier())

        case .good:
            goodHits += 1
            currentCombo += 1
            addScore(spec.goodScore + noteValue, multiplier: calculateMultiplier())

        case .okay:
            okayHits += 1
            currentCombo += 1
            addScore(spec.okayScore + noteValue, multiplier: calculateMultiplier())

        case .miss:
            missedNotes += 1
            currentCombo = 0
            multiplier = 1.0
        }

        maxCombo = max(maxCombo, currentCombo)
    }

    func calculateMultiplier() -> Float {
        // Find highest applicable combo multiplier
        let applicableMultipliers = spec.comboMultiplier.filter { currentCombo >= $0.key }
        return applicableMultipliers.values.max() ?? 1.0
    }

    func addScore(_ points: Int, multiplier: Float) {
        let finalScore = Int(Float(points) * multiplier)
        currentScore += finalScore

        // Trigger score popup
        notifyScoreGained(finalScore, at: currentHitPosition)
    }

    // Calculate final grade
    func calculateGrade() -> Grade {
        let accuracy = calculateAccuracy()

        switch accuracy {
        case 0.95...1.0: return .sPlus
        case 0.90..<0.95: return .s
        case 0.85..<0.90: return .aPlus
        case 0.80..<0.85: return .a
        case 0.75..<0.80: return .b
        case 0.70..<0.75: return .c
        default: return .d
        }
    }

    func calculateAccuracy() -> Double {
        let totalNotes = perfectHits + greatHits + goodHits + okayHits + missedNotes
        guard totalNotes > 0 else { return 0 }

        let weightedScore = Double(
            perfectHits * 100 +
            greatHits * 85 +
            goodHits * 70 +
            okayHits * 50
        )

        return weightedScore / (Double(totalNotes) * 100.0)
    }
}
```

---

## Control Schemes

### Hand Tracking Controls

```swift
// Hand Gesture Specification
enum HandGesture: String, CaseIterable {
    case punch          // Closed fist, rapid forward motion
    case swipeUp        // Open hand, upward motion
    case swipeDown      // Open hand, downward motion
    case swipeLeft      // Open hand, left motion
    case swipeRight     // Open hand, right motion
    case hold           // Sustained position
    case clap           // Two hands together
    case grab           // Pinch gesture
    case spread         // Open palm
}

// Gesture Recognition Parameters
struct GestureRecognitionSpec {
    // Punch detection
    let punchMinVelocity: Float = 2.0          // m/s
    let punchMaxFingerExtension: Float = 0.3   // Fist threshold
    let punchDuration: TimeInterval = 0.1      // Max duration

    // Swipe detection
    let swipeMinVelocity: Float = 1.5          // m/s
    let swipeMinDistance: Float = 0.2          // meters
    let swipeMaxDuration: TimeInterval = 0.3
    let swipeDirectionTolerance: Float = 30.0  // degrees

    // Hold detection
    let holdMinDuration: TimeInterval = 0.5
    let holdMaxMovement: Float = 0.05          // meters
    let holdPositionTolerance: Float = 0.02

    // Confidence threshold
    let minimumConfidence: Float = 0.85
}

// Gesture Detector
class HandGestureDetector {
    private var handHistory: [HandSnapshot] = []
    private let historyDuration: TimeInterval = 0.5

    func detectGesture(from handAnchor: HandAnchor) -> DetectedGesture? {
        // 1. Record hand state
        let snapshot = HandSnapshot(
            timestamp: CACurrentMediaTime(),
            position: handAnchor.originFromAnchorTransform.translation,
            joints: extractJointPositions(handAnchor),
            velocity: calculateVelocity(handAnchor)
        )
        handHistory.append(snapshot)

        // 2. Maintain history window
        let cutoffTime = snapshot.timestamp - historyDuration
        handHistory.removeAll { $0.timestamp < cutoffTime }

        // 3. Detect gestures
        if let punch = detectPunch(handHistory) {
            return punch
        }
        if let swipe = detectSwipe(handHistory) {
            return swipe
        }
        if let hold = detectHold(handHistory) {
            return hold
        }

        return nil
    }

    private func detectPunch(_ history: [HandSnapshot]) -> DetectedGesture? {
        guard history.count >= 3 else { return nil }

        let recent = history.suffix(3)

        // Check velocity spike
        let maxVelocity = recent.map(\.velocity.z).max() ?? 0
        guard maxVelocity >= spec.punchMinVelocity else { return nil }

        // Check fist formation
        let fingersClosed = recent.last?.joints.areFingersClosed ?? false
        guard fingersClosed else { return nil }

        return DetectedGesture(
            type: .punch,
            confidence: calculateConfidence(.punch, history),
            direction: recent.last?.velocity.normalized ?? .zero
        )
    }

    private func detectSwipe(_ history: [HandSnapshot]) -> DetectedGesture? {
        guard history.count >= 5 else { return nil }

        let recent = history.suffix(5)

        // Calculate displacement
        let startPos = recent.first!.position
        let endPos = recent.last!.position
        let displacement = endPos - startPos
        let distance = simd_length(displacement)

        guard distance >= spec.swipeMinDistance else { return nil }

        // Check velocity
        let avgVelocity = recent.map(\.velocity).reduce(.zero, +) / Float(recent.count)
        guard simd_length(avgVelocity) >= spec.swipeMinVelocity else { return nil }

        // Determine direction
        let direction = determineSwipeDirection(displacement)

        return DetectedGesture(
            type: .swipe(direction),
            confidence: calculateConfidence(.swipe, history),
            direction: displacement.normalized
        )
    }
}
```

### Game Controller Support

```swift
// Game Controller Mapping
import GameController

class GameControllerManager {
    func setupControllerSupport() {
        NotificationCenter.default.addObserver(
            forName: .GCControllerDidConnect,
            object: nil,
            queue: .main
        ) { notification in
            self.handleControllerConnected(notification.object as? GCController)
        }
    }

    func handleControllerConnected(_ controller: GCController?) {
        guard let gamepad = controller?.extendedGamepad else { return }

        // Map buttons to game actions
        gamepad.buttonA.pressedChangedHandler = { button, value, pressed in
            if pressed {
                self.handleNoteHit(.punch, hand: .right)
            }
        }

        gamepad.buttonB.pressedChangedHandler = { button, value, pressed in
            if pressed {
                self.handleNoteHit(.punch, hand: .left)
            }
        }

        // D-pad for swipes
        gamepad.dpad.up.pressedChangedHandler = { button, value, pressed in
            if pressed {
                self.handleNoteHit(.swipeUp, hand: .right)
            }
        }

        // Triggers for special moves
        gamepad.rightTrigger.valueChangedHandler = { button, value, pressed in
            if value > 0.5 {
                self.handleSpecialMove()
            }
        }
    }
}
```

### Accessibility Controls

```swift
// Alternative control schemes for accessibility
enum AccessibilityControlMode {
    case eyeGaze              // Look to select, dwell to activate
    case voiceCommands        // Speech recognition
    case reducedMotion        // Minimal movement required
    case oneHanded            // Single hand gameplay
    case seated               // No standing required
    case assistMode           // Auto-hit assistance
}

class AccessibilityController {
    var currentMode: AccessibilityControlMode = .standard

    func enableEyeGazeControl() {
        // Use eye tracking for note selection
        // Dwell timer for activation
    }

    func enableVoiceCommands() {
        let recognizer = SFSpeechRecognizer()
        // Recognize: "hit", "swipe", "hold"
    }

    func enableAssistMode(level: AssistLevel) {
        switch level {
        case .minimal:
            // Slightly larger hit windows
            hitDetectionSpec.perfectWindow *= 1.2

        case .moderate:
            // Auto-hit notes within range
            autoHitThreshold = 0.25

        case .full:
            // Play automatically, just enjoy visuals
            fullyAutomated = true
        }
    }
}
```

---

## Physics Specifications

### Physics Engine Configuration

```swift
// Physics World Settings
struct PhysicsWorldSpec {
    let gravity: SIMD3<Float> = [0, -9.81, 0]
    let timeStep: TimeInterval = 1.0 / 90.0     // 90Hz physics
    let substeps: Int = 2                        // 2 substeps per frame

    // Collision detection
    let collisionMode: CollisionMode = .continuous
    let spatialPartitioning: SpatialPartitioningMethod = .octree

    // Performance
    let maxCollisionPairs: Int = 1000
    let sleepThreshold: Float = 0.01
}

// Physics Materials
enum PhysicsMaterial {
    case note
    case hand
    case obstacle
    case boundary

    var properties: PhysicsMaterialProperties {
        switch self {
        case .note:
            return PhysicsMaterialProperties(
                friction: 0.0,
                restitution: 0.8,
                density: 0.5
            )
        case .hand:
            return PhysicsMaterialProperties(
                friction: 0.5,
                restitution: 0.3,
                density: 1.0
            )
        case .obstacle:
            return PhysicsMaterialProperties(
                friction: 0.3,
                restitution: 0.5,
                density: 2.0
            )
        case .boundary:
            return PhysicsMaterialProperties(
                friction: 0.0,
                restitution: 1.0,
                density: Float.infinity
            )
        }
    }
}
```

### Collision Groups & Filters

```swift
// Collision Matrix
struct CollisionMatrix {
    /*
     Note   Hand   Obstacle   Boundary   Floor
    Note    No     Yes     No         Yes       No
    Hand    Yes    No      Yes        Yes       Yes
    Obstacle No    Yes     No         No        No
    Boundary Yes   Yes     No         No        No
    Floor   No     Yes     No         No        No
    */

    static let note: CollisionFilter = .init(
        group: .note,
        mask: [.hand, .boundary]
    )

    static let hand: CollisionFilter = .init(
        group: .hand,
        mask: [.note, .obstacle, .boundary, .floor]
    )

    static let obstacle: CollisionFilter = .init(
        group: .obstacle,
        mask: [.hand]
    )
}
```

---

## Rendering Requirements

### Visual Quality Targets

```yaml
Frame Rate: 90 FPS (locked)
Resolution: Native Vision Pro resolution per eye
Anti-aliasing: 4x MSAA
Texture Quality: High (2048x2048 for key assets)
Particle Count: Up to 5000 simultaneous particles
Poly Budget: 100K triangles per frame
Draw Calls: < 100 per frame
```

### Material System

```swift
// Custom Shader Materials
struct NoteShaderMaterial {
    // Base properties
    var baseColor: SIMD3<Float>
    var metallic: Float = 0.8
    var roughness: Float = 0.2
    var emissive: SIMD3<Float>
    var emissiveIntensity: Float = 2.0

    // Animation properties
    var pulseFrequency: Float = 2.0
    var glowIntensity: Float = 1.0
    var dissolveAmount: Float = 0.0

    // Create RealityKit material
    func createMaterial() -> CustomMaterial {
        var material = CustomMaterial()

        material.custom.value = .init(
            baseColor: baseColor,
            metallic: metallic,
            roughness: roughness,
            emissive: emissive * emissiveIntensity
        )

        // Add custom shader for animations
        material.vertexShader = """
        vertex float4 customVertex(VertexIn in) {
            float pulse = sin(time * \(pulseFrequency)) * 0.1;
            in.position.xyz += in.normal * pulse;
            return in.position;
        }
        """

        material.fragmentShader = """
        fragment float4 customFragment(FragmentIn in) {
            float glow = \(glowIntensity);
            float3 color = baseColor * glow;
            return float4(color, 1.0 - \(dissolveAmount));
        }
        """

        return material
    }
}
```

### Particle Effects

```swift
// Particle System Specifications
struct ParticleEffectSpec {
    // Hit effect
    static let hitEffect = ParticleEmitterComponent(
        birthRate: 100,
        lifeSpan: 0.5,
        speed: 2.0,
        spreadingAngle: .pi / 4,
        color: .dynamic,
        size: 0.02,
        gravity: [0, -1, 0]
    )

    // Combo flames
    static let comboFlames = ParticleEmitterComponent(
        birthRate: 50,
        lifeSpan: 1.0,
        speed: 1.0,
        spreadingAngle: .pi / 8,
        color: .gradient([.orange, .red, .yellow]),
        size: 0.05,
        gravity: [0, 1, 0]  // Rise upward
    )

    // Perfect streak trail
    static let perfectStreak = ParticleEmitterComponent(
        birthRate: 200,
        lifeSpan: 0.8,
        speed: 0.5,
        spreadingAngle: .pi / 2,
        color: .rainbow,
        size: 0.01,
        gravity: .zero
    )
}
```

### Level of Detail (LOD)

```swift
// LOD System
class LODManager {
    func selectLOD(for entity: Entity, distanceFromCamera: Float) -> LODLevel {
        switch distanceFromCamera {
        case 0..<1.5:
            return .high
        case 1.5..<3.0:
            return .medium
        case 3.0..<5.0:
            return .low
        default:
            return .culled
        }
    }

    enum LODLevel {
        case high       // Full quality: 1000 polygons, full textures
        case medium     // Reduced: 500 polygons, 50% textures
        case low        // Minimal: 200 polygons, 25% textures
        case culled     // Not rendered
    }
}
```

---

## Audio Specifications

### Spatial Audio Configuration

```yaml
Audio Engine: AVAudioEngine
Spatialization: HRTF (Head-Related Transfer Function)
Sample Rate: 48 kHz
Bit Depth: 24-bit
Channels: Stereo source, spatialized to 3D
Reverb: Room-aware environmental audio
Occlusion: Enabled for obstacles
```

### Audio Files

```yaml
Music Tracks:
  Format: AAC 256 kbps or ALAC
  Sample Rate: 48 kHz
  Length: 1-6 minutes
  Stems: Optional (drums, bass, melody, vocals)

Sound Effects:
  Format: WAV 48kHz 24-bit
  Types:
    - Note hit sounds (perfect/great/good/miss)
    - Combo milestone sounds
    - UI interaction sounds
    - Ambient environment sounds
    - Voice feedback (optional)
```

### Audio Latency Budget

```swift
// Audio Timing Specifications
struct AudioLatencySpec {
    let targetLatency: TimeInterval = 0.020      // 20ms total
    let breakdown: [String: TimeInterval] = [
        "Input detection": 0.005,                 // 5ms
        "Processing": 0.005,                      // 5ms
        "Audio rendering": 0.010                  // 10ms
    ]

    // Calibration
    let allowUserCalibration: Bool = true
    let calibrationRange: ClosedRange<TimeInterval> = -0.100...0.100  // ±100ms
}
```

---

## Networking & Multiplayer

### Network Architecture

```swift
// Multiplayer Network Specification
struct MultiplayerNetworkSpec {
    // Connection
    let maxPlayers: Int = 4
    let serverType: ServerType = .peerToPeer  // SharePlay uses P2P
    let protocol: NetworkProtocol = .tcp      // Reliable for game state
    let udpForAudio: Bool = true              // Voice chat uses UDP

    // Synchronization
    let tickRate: Int = 30                     // 30 updates/second
    let interpolation: Bool = true             // Smooth remote players
    let predictionEnabled: Bool = true         // Client-side prediction

    // Bandwidth
    let maxBandwidth: Int = 1_000_000          // 1 Mbps per player
    let compressionEnabled: Bool = true

    // Latency compensation
    let maxAcceptableLatency: TimeInterval = 0.150     // 150ms
    let lagCompensation: Bool = true
}

// Network Messages
enum NetworkMessage: Codable {
    case playerJoined(PlayerInfo)
    case playerLeft(UUID)
    case gameStateSync(GameStateSyncData)
    case noteHit(NoteHitData)
    case scoreUpdate(ScoreData)
    case chatMessage(String)
    case readyStatus(Bool)
}

// Game State Synchronization
struct GameStateSyncData: Codable {
    let timestamp: TimeInterval
    let musicTime: TimeInterval
    let playerScores: [UUID: Int]
    let playerCombos: [UUID: Int]
    let noteStates: [UUID: NoteState]  // Only active notes
}
```

### SharePlay Implementation

```swift
// SharePlay Activity Definition
struct RhythmFlowActivity: GroupActivity {
    static let activityIdentifier = "com.beatspace.rhythmflow.gameplay"

    let songID: UUID
    let difficulty: Difficulty
    let mode: MultiplayerMode

    var metadata: GroupActivityMetadata {
        var meta = GroupActivityMetadata()
        meta.type = .generic
        meta.title = "Rhythm Flow - \(songTitle)"
        meta.subtitle = "Difficulty: \(difficulty.rawValue)"
        meta.previewImage = songArtwork
        meta.supportsContinuationOnTV = false
        return meta
    }
}

// Coordinated Playback
class CoordinatedPlaybackManager {
    func synchronizeStart(with participants: [Participant]) async {
        // 1. All participants report ready
        await broadcastReady()

        // 2. Wait for all ready signals
        let allReady = await waitForAllReady()

        // 3. Leader determines start time
        let startTime = Date().addingTimeInterval(3.0)
        if isLeader {
            await broadcast(StartCommand(time: startTime))
        }

        // 4. All participants start at exact time
        let receivedStartTime = await waitForStartCommand()
        await sleepUntil(receivedStartTime)

        // 5. Begin synchronized playback
        musicPlayer.play(at: receivedStartTime)
    }
}
```

---

## Performance Requirements

### Frame Rate Targets

```yaml
Target: 90 FPS (consistent)
Minimum: 60 FPS (never drop below)
Frame Time Budget: 11.1ms per frame

Breakdown:
  - Input: 1ms
  - Game Logic: 3ms
  - Physics: 2ms
  - Rendering: 4ms
  - System: 1.1ms
```

### Memory Budget

```yaml
Total Memory: < 2 GB
Breakdown:
  - Textures: 500 MB
  - Audio: 300 MB
  - Geometry: 200 MB
  - Code: 100 MB
  - Runtime: 400 MB
  - System Reserve: 500 MB
```

### Battery & Thermal

```yaml
Battery Life Target: 2 hours continuous play
Thermal Management:
  - Monitor temperature every second
  - Reduce quality if overheating
  - Disable effects at critical temp
  - Show warning to user
```

### Performance Monitoring

```swift
// Performance Monitor
class PerformanceMonitor {
    private var frameTimings: [TimeInterval] = []
    private let windowSize = 120  // 120 frames (~1.3s at 90fps)

    func recordFrame(_ duration: TimeInterval) {
        frameTimings.append(duration)
        if frameTimings.count > windowSize {
            frameTimings.removeFirst()
        }

        // Check for issues
        if duration > 0.0167 {  // > 16.7ms (< 60fps)
            handlePerformanceIssue()
        }
    }

    func getCurrentFPS() -> Double {
        let avgFrameTime = frameTimings.reduce(0, +) / Double(frameTimings.count)
        return 1.0 / avgFrameTime
    }

    func handlePerformanceIssue() {
        // Reduce quality dynamically
        qualityManager.reduceQuality()
    }
}
```

---

## Testing Requirements

### Unit Testing

```swift
// Test Coverage Requirements
/*
Minimum Coverage: 80%
Critical Paths: 100% coverage

Test Categories:
  - Game logic (scoring, combo, difficulty)
  - Data models (serialization, validation)
  - Utilities (math, extensions)
  - AI systems (beat generation, difficulty adjustment)
*/

// Example Unit Tests
class ScoreManagerTests: XCTestCase {
    func testPerfectHitScoring() {
        let scoreManager = ScoreManager()
        let result = HitResult(quality: .perfect, timingError: 0.01, spatialError: 0.02)

        scoreManager.registerHit(result, noteValue: 100)

        XCTAssertEqual(scoreManager.perfectHits, 1)
        XCTAssertEqual(scoreManager.currentCombo, 1)
        XCTAssertEqual(scoreManager.currentScore, 215)  // 115 + 100
    }

    func testComboMultiplier() {
        let scoreManager = ScoreManager()

        // Build combo to 50
        for _ in 0..<50 {
            let result = HitResult(quality: .perfect, timingError: 0.01, spatialError: 0.02)
            scoreManager.registerHit(result, noteValue: 100)
        }

        // Multiplier should be 1.5x at 50 combo
        XCTAssertEqual(scoreManager.multiplier, 1.5)
    }
}
```

### Integration Testing

```yaml
Integration Test Scenarios:
  - Full song playthrough (all difficulties)
  - Multiplayer session (2-4 players)
  - Room scanning and boundary detection
  - Hand tracking calibration
  - Audio synchronization
  - Save/load game state
  - CloudKit synchronization
  - Beat map generation
```

### Performance Testing

```yaml
Performance Test Suite:
  - Sustained 90 FPS for 10 minutes
  - Memory stability (no leaks)
  - Battery drain measurement
  - Thermal management validation
  - Network latency simulation
  - Large particle count stress test
  - 1000+ notes simultaneously
```

### Accessibility Testing

```yaml
Accessibility Test Checklist:
  - VoiceOver navigation
  - Reduced motion mode
  - Color blind modes
  - One-handed mode
  - Seated mode
  - Controller support
  - Difficulty assist features
```

### User Acceptance Testing

```yaml
UAT Scenarios:
  - First-time user onboarding
  - Casual 30-minute session
  - Extended 2-hour session
  - Multiplayer with friends
  - Song library browsing
  - Beat map creation
  - Fitness tracking accuracy
  - Cross-device sync (iPhone, Mac)
```

---

## API Specifications

### Music Analysis API

```swift
protocol MusicAnalyzer {
    func analyze(_ audioURL: URL) async throws -> AudioFeatures
}

struct AudioFeatures {
    let bpm: Double
    let key: MusicalKey
    let timeSignature: TimeSignature
    let beats: [BeatMarker]
    let downbeats: [BeatMarker]
    let melody: MelodicContour
    let energy: EnergyCurve
    let segments: [SongSegment]
}

struct BeatMarker {
    let timestamp: TimeInterval
    let confidence: Float
}
```

### Difficulty Scaling API

```swift
protocol DifficultyScaler {
    func adjustDifficulty(current: Difficulty, performance: PerformanceMetrics) -> Difficulty
    func getDifficultyMultipliers(_ difficulty: Difficulty) -> DifficultyMultipliers
}

struct DifficultyMultipliers {
    var noteSpeed: Float
    var noteDensity: Float
    var complexity: Float
    var restPeriods: Float
}
```

### Leaderboard API

```swift
protocol LeaderboardService {
    func submitScore(_ entry: LeaderboardEntry) async throws
    func fetchLeaderboard(songID: UUID, difficulty: Difficulty, scope: LeaderboardScope) async throws -> [LeaderboardEntry]
    func fetchPlayerRank(playerID: UUID, songID: UUID) async throws -> Int
}

enum LeaderboardScope {
    case global
    case friends
    case regional(String)
}
```

---

## File Formats & Data Structures

### Beat Map File Format

```json
{
  "version": "1.0",
  "songID": "uuid-here",
  "difficulty": "expert",
  "metadata": {
    "creator": "AI Generator v2.0",
    "created": "2025-01-20T10:00:00Z",
    "bpm": 128.0,
    "duration": 180.5
  },
  "noteEvents": [
    {
      "timestamp": 2.5,
      "type": "punch",
      "position": [0.5, 1.2, 0.8],
      "hand": "right",
      "points": 100,
      "color": "blue"
    }
  ],
  "obstacles": [],
  "events": []
}
```

### Player Profile Format

```json
{
  "id": "player-uuid",
  "username": "RhythmMaster",
  "level": 42,
  "experience": 125000,
  "statistics": {
    "totalSongsPlayed": 350,
    "totalScore": 5000000,
    "perfectHits": 25000,
    "averageAccuracy": 0.87
  },
  "preferences": {
    "difficulty": "hard",
    "visualTheme": "neon",
    "haptics": true
  }
}
```

---

## Conclusion

This technical specification provides detailed implementation requirements for Rhythm Flow. All systems should be built to these specifications to ensure consistent performance, quality, and user experience across the platform.

**Key Performance Targets:**
- 90 FPS sustained gameplay
- < 20ms audio latency
- < 2 GB memory usage
- 2+ hours battery life

**Next Steps:** Refer to IMPLEMENTATION_PLAN.md for development phases and milestones.
