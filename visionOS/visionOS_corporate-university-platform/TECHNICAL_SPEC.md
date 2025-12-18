# Corporate University Platform - Technical Specifications

## Document Overview
**Version**: 1.0
**Last Updated**: 2025-01-20
**Status**: Draft
**Target Platform**: visionOS 2.0+

## Table of Contents
1. [Technology Stack](#technology-stack)
2. [visionOS Presentation Modes](#visionos-presentation-modes)
3. [Gesture and Interaction Specifications](#gesture-and-interaction-specifications)
4. [Hand Tracking Implementation](#hand-tracking-implementation)
5. [Eye Tracking Implementation](#eye-tracking-implementation)
6. [Spatial Audio Specifications](#spatial-audio-specifications)
7. [Accessibility Requirements](#accessibility-requirements)
8. [Privacy and Security Requirements](#privacy-and-security-requirements)
9. [Data Persistence Strategy](#data-persistence-strategy)
10. [Network Architecture](#network-architecture)
11. [Testing Requirements](#testing-requirements)

---

## 1. Technology Stack

### Core Technologies

#### Swift Language
- **Version**: Swift 6.0+
- **Concurrency**: Strict concurrency checking enabled
- **Features Used**:
  - `async`/`await` for asynchronous operations
  - `@Observable` macro for state management
  - Actors for thread-safe data access
  - Structured concurrency with task groups
  - `sendable` protocol conformance

```swift
// Example: Strict concurrency
actor LearningDataStore {
    private var courses: [UUID: Course] = [:]

    func getCourse(id: UUID) -> Course? {
        courses[id]
    }

    func storeCourse(_ course: Course) {
        courses[course.id] = course
    }
}
```

#### SwiftUI Framework
- **Version**: SwiftUI 5.0+ (iOS 18 / visionOS 2.0)
- **Key Components**:
  - `@Observable` for reactive state
  - `RealityView` for 3D content integration
  - Custom view modifiers for spatial layouts
  - Ornaments and toolbars for spatial UI
  - SwiftData integration

```swift
// Example: Observable pattern
@Observable
class LearningViewModel {
    var courses: [Course] = []
    var isLoading: Bool = false

    @MainActor
    func loadCourses() async {
        isLoading = true
        // Load courses
        isLoading = false
    }
}
```

#### RealityKit
- **Version**: RealityKit 4.0+
- **Features**:
  - Entity Component System (ECS)
  - PBR (Physically Based Rendering)
  - Spatial audio integration
  - Physics simulation
  - Animation system
  - Particle effects

**Key Components**:
```swift
// Custom components
struct LearningInteractionComponent: Component {
    var interactionType: InteractionType
    var isEnabled: Bool
    var feedbackType: FeedbackType
}

// Custom systems
class InteractionSystem: System {
    func update(context: SceneUpdateContext) {
        // Update logic
    }
}
```

#### ARKit
- **Version**: ARKit 6.0+
- **Capabilities Used**:
  - Hand tracking
  - Eye tracking (with privacy controls)
  - Plane detection
  - Scene understanding
  - World tracking

#### visionOS SDK
- **Minimum Version**: visionOS 2.0
- **Target Version**: visionOS 2.1+
- **Key APIs**:
  - `GroupActivities` for SharePlay
  - `RoomPlan` for spatial mapping
  - `VisionKit` for image analysis
  - `Spatial` framework for 3D geometry

### Development Tools

#### Xcode
- **Version**: Xcode 16.0+
- **Configuration**:
  - Swift 6 language mode
  - Strict concurrency checking
  - Build configuration for Debug/Release

```swift
// Build Settings
SWIFT_VERSION = 6.0
SWIFT_STRICT_CONCURRENCY = complete
IPHONEOS_DEPLOYMENT_TARGET = 2.0
ENABLE_PREVIEWS = YES
ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS = YES
```

#### Reality Composer Pro
- **Version**: 2.0+
- **Usage**:
  - Create 3D learning environments
  - Design interactive objects
  - Configure spatial audio
  - Build materials and shaders
  - Export USDZ assets

#### Swift Package Manager
**Dependencies**:
```swift
// Package.swift
dependencies: [
    .package(url: "https://github.com/apple/swift-collections", from: "1.0.0"),
    .package(url: "https://github.com/apple/swift-algorithms", from: "1.2.0"),
]
```

### Third-Party Libraries

```swift
// Key dependencies
// - None required for MVP
// - Consider adding:
//   - Networking: Native URLSession is sufficient
//   - Image loading: Native AsyncImage is sufficient
//   - Analytics: Custom implementation
```

---

## 2. visionOS Presentation Modes

### WindowGroup (2D Floating Windows)

**Purpose**: Dashboard, course browsers, settings, 2D content

**Implementation**:
```swift
WindowGroup(id: "dashboard") {
    DashboardView()
        .environment(appModel)
}
.windowStyle(.plain)
.defaultSize(width: 1200, height: 800)
.windowResizability(.contentSize)
```

**Specifications**:
- **Default Size**: 1200x800 points
- **Minimum Size**: 800x600 points
- **Maximum Size**: 2000x1400 points
- **Resizability**: Content-driven or fixed
- **Background**: Glass material with blur
- **Ornaments**: Top toolbar, side panels optional

**Window Types**:
1. **Main Dashboard**
   - ID: `dashboard`
   - Size: 1200x800
   - Resizable: Yes
   - Always available

2. **Course Browser**
   - ID: `courseBrowser`
   - Size: 1000x700
   - Resizable: Yes
   - Can have multiple instances

3. **Learning Path Explorer**
   - ID: `learningPath`
   - Size: 1200x900
   - Resizable: Yes
   - Single instance

4. **Analytics Dashboard**
   - ID: `analytics`
   - Size: 1400x900
   - Resizable: Yes
   - Single instance

5. **Settings**
   - ID: `settings`
   - Size: 800x600
   - Resizable: No
   - Single instance

### Volumetric Windows (3D Bounded Content)

**Purpose**: 3D visualizations, skill trees, data exploration

**Implementation**:
```swift
WindowGroup(id: "skillTree") {
    SkillTreeVolumeView()
        .environment(appModel)
}
.windowStyle(.volumetric)
.defaultSize(width: 1.0, height: 1.0, depth: 1.0, in: .meters)
```

**Specifications**:
- **Maximum Volume**: 2m x 2m x 2m
- **Default Volume**: 1m x 1m x 1m
- **Resizability**: User can scale
- **Orientation**: Fixed to user
- **Interaction**: Direct hand interaction

**Volume Types**:
1. **Skill Tree Visualization**
   - Size: 1.2m x 1.2m x 1.0m
   - Interactive nodes
   - Animated connections

2. **Knowledge Map**
   - Size: 1.5m x 1.0m x 1.0m
   - 3D concept network
   - Zoomable

3. **Progress Globe**
   - Size: 0.8m x 0.8m x 0.8m
   - Rotating visualization
   - Real-time updates

4. **Assessment Arena**
   - Size: 1.0m x 0.8m x 1.0m
   - Interactive quiz objects
   - Spatial feedback

### ImmersiveSpace (Full Immersion)

**Purpose**: Complete learning environments, simulations, practice spaces

**Implementation**:
```swift
ImmersiveSpace(id: "learningEnvironment") {
    LearningEnvironmentView()
        .environment(appModel)
}
.immersionStyle(selection: $immersionLevel, in: .mixed, .progressive, .full)
```

**Specifications**:

#### Mixed Immersion
- **Use Case**: Blend virtual content with real environment
- **Passthrough**: 100% visible
- **Virtual Content**: Anchored to real world
- **Examples**: Equipment overlays, AR annotations

#### Progressive Immersion
- **Use Case**: Adjustable immersion level
- **Passthrough**: 0-100% via Digital Crown
- **Virtual Content**: Can fill entire view
- **Examples**: Training simulations with real-world context

#### Full Immersion
- **Use Case**: Complete virtual environment
- **Passthrough**: 0% (fully immersive)
- **Virtual Content**: 360° environment
- **Examples**: Virtual factories, immersive classrooms

**Environment Types**:
1. **Virtual Classroom**
   - Immersion: Progressive
   - Size: 10m x 4m x 8m
   - Capacity: 30 participants
   - Features: Whiteboard, desks, presentation area

2. **Manufacturing Floor**
   - Immersion: Full
   - Size: 20m x 5m x 15m
   - Features: Equipment, workstations, safety zones
   - Interactions: Equipment operation, process simulation

3. **Executive Boardroom**
   - Immersion: Mixed
   - Size: 8m x 3m x 6m
   - Features: Conference table, presentation screens
   - Interactions: Presentations, discussions

4. **Innovation Lab**
   - Immersion: Progressive
   - Size: 12m x 4m x 10m
   - Features: Workbenches, prototyping tools
   - Interactions: Creative exercises, prototyping

5. **Outdoor Training Area**
   - Immersion: Full
   - Size: 50m x 5m x 50m
   - Features: Natural environment, obstacles
   - Interactions: Team building, physical challenges

### Space Transition Specifications

**Transition Types**:
```swift
// Window to Volume
await openWindow(id: "skillTree")
// Duration: 0.3s fade + scale

// Window to Immersive
await openImmersiveSpace(id: "learningEnvironment")
// Duration: 0.5s fade + expand

// Volume to Immersive
await dismissWindow(id: "skillTree")
await openImmersiveSpace(id: "learningEnvironment")
// Duration: 0.4s crossfade
```

**Animation Specifications**:
- **Fade Duration**: 0.3-0.5 seconds
- **Easing**: Ease-in-out
- **Scale Factor**: 0.95 to 1.0
- **Position**: Center of user's view

---

## 3. Gesture and Interaction Specifications

### Primary Interaction Methods

#### 3.1 Gaze + Pinch (Default)

**Gaze Targeting**:
- **Activation Time**: 300ms dwell
- **Visual Feedback**: Subtle highlight
- **Accuracy**: ±2° tolerance
- **Range**: 0.5m - 10m

**Pinch Gesture**:
- **Recognition**: Thumb-index contact
- **Activation Force**: Light touch
- **Duration**: Minimum 100ms
- **Feedback**: Haptic click

```swift
// Implementation
.onTapGesture {
    performAction()
}
.hoverEffect(.highlight)
```

#### 3.2 Direct Touch

**Touch Specifications**:
- **Min Target Size**: 60pt (44mm)
- **Touch Accuracy**: ±5mm
- **Activation**: On touch-up
- **Visual Feedback**: Scale + glow

```swift
// Implementation
struct InteractiveButton: View {
    var body: some View {
        Button("Tap Me") {
            action()
        }
        .buttonStyle(.bordered)
        .hoverEffect(.lift)
    }
}
```

#### 3.3 Hand Gestures

**Supported Gestures**:

1. **Grab Gesture**
   - **Recognition**: Fist formation
   - **Use**: Pick up objects
   - **Feedback**: Object follows hand
   - **Release**: Open hand

2. **Two-Hand Scale**
   - **Recognition**: Two pinches
   - **Use**: Scale objects
   - **Range**: 0.1x - 5.0x
   - **Feedback**: Visual scale indicator

3. **Rotate Gesture**
   - **Recognition**: Circular hand motion
   - **Use**: Rotate objects
   - **Range**: 360° continuous
   - **Feedback**: Rotation trail

4. **Push Gesture**
   - **Recognition**: Forward palm motion
   - **Use**: Dismiss, move objects away
   - **Distance**: 0.2m - 0.5m
   - **Feedback**: Object movement

5. **Pull Gesture**
   - **Recognition**: Toward palm motion
   - **Use**: Bring objects closer
   - **Distance**: 0.2m - 0.5m
   - **Feedback**: Object movement

**Custom Learning Gestures**:

1. **Raise Hand** (Ask Question)
   - **Recognition**: Hand above head
   - **Duration**: 1 second
   - **Action**: Notify instructor/AI tutor
   - **Visual**: Hand icon appears

2. **Thumbs Up** (Understand)
   - **Recognition**: Thumb extended upward
   - **Duration**: 0.5 second
   - **Action**: Confirm understanding
   - **Visual**: Checkmark

3. **Wave** (Get Help)
   - **Recognition**: Side-to-side hand motion
   - **Count**: 2-3 waves
   - **Action**: Request assistance
   - **Visual**: Help icon

### Spatial Manipulation

**Drag and Drop**:
```swift
.draggable(item) {
    ItemPreview(item)
}
.dropDestination(for: Item.self) { items, location in
    handleDrop(items, at: location)
}
```

**3D Manipulation**:
```swift
entity.components[InputTargetComponent.self] = InputTargetComponent()

entity.generateCollisionShapes(recursive: true)

// Add gestures
entity.components[GestureComponent.self] = GestureComponent([
    .translation,
    .rotation,
    .scale
])
```

**Specifications**:
- **Translation**: All 3 axes (X, Y, Z)
- **Rotation**: All 3 axes with gimbal lock prevention
- **Scale**: Uniform and non-uniform
- **Constraints**: Definable bounds and snap points

### Interaction Feedback

**Visual Feedback**:
- **Hover**: Subtle scale (1.05x) + glow
- **Active**: Brighter glow + scale (0.95x)
- **Success**: Green pulse + scale bounce
- **Error**: Red shake + scale bounce
- **Disabled**: 50% opacity + desaturate

**Audio Feedback**:
- **Tap**: Soft click (100ms)
- **Success**: Pleasant chime (200ms)
- **Error**: Gentle buzz (150ms)
- **Drag Start**: Subtle whoosh (50ms)
- **Drop**: Soft thud (100ms)

**Haptic Feedback**:
- **Tap**: Light impact
- **Success**: Success pattern
- **Error**: Warning pattern
- **Long Press**: Continuous feedback

---

## 4. Hand Tracking Implementation

### Hand Tracking Configuration

**ARKit Setup**:
```swift
class HandTrackingManager {
    private var session: ARKitSession?
    private var handTracking: HandTrackingProvider?

    func startHandTracking() async throws {
        session = ARKitSession()
        handTracking = HandTrackingProvider()

        try await session?.run([handTracking!])
    }

    func monitorHandUpdates() async {
        guard let handTracking = handTracking else { return }

        for await update in handTracking.anchorUpdates {
            handleHandUpdate(update)
        }
    }
}
```

### Hand Skeleton Tracking

**Tracked Joints** (21 per hand):
```
Wrist
├── Thumb
│   ├── ThumbMetacarpal
│   ├── ThumbProximal
│   ├── ThumbDistal
│   └── ThumbTip
├── Index Finger
│   ├── IndexMetacarpal
│   ├── IndexProximal
│   ├── IndexIntermediate
│   ├── IndexDistal
│   └── IndexTip
├── Middle Finger (same structure)
├── Ring Finger (same structure)
└── Little Finger (same structure)
```

**Joint Data**:
- **Position**: 3D coordinates (X, Y, Z)
- **Orientation**: Quaternion rotation
- **Velocity**: 3D vector (m/s)
- **Confidence**: 0.0 - 1.0

### Gesture Recognition

**Pinch Detection**:
```swift
func detectPinch(hand: HandAnchor) -> Bool {
    let thumbTip = hand.skeleton.joint(.thumbTip)
    let indexTip = hand.skeleton.joint(.indexFingerTip)

    guard let thumbPos = thumbTip.position,
          let indexPos = indexTip.position else {
        return false
    }

    let distance = distance(thumbPos, indexPos)
    return distance < pinchThreshold // 20mm
}
```

**Grab Detection**:
```swift
func detectGrab(hand: HandAnchor) -> Bool {
    let fingerTips: [HandSkeleton.JointName] = [
        .indexFingerTip,
        .middleFingerTip,
        .ringFingerTip,
        .littleFingerTip
    ]

    let palmCenter = hand.skeleton.joint(.wrist).position

    var closedFingers = 0
    for finger in fingerTips {
        if let tipPos = hand.skeleton.joint(finger).position,
           distance(tipPos, palmCenter) < grabThreshold {
            closedFingers += 1
        }
    }

    return closedFingers >= 3 // At least 3 fingers closed
}
```

**Custom Gesture Recognition**:
```swift
class GestureRecognizer {
    private var gestureBuffer: [HandPose] = []
    private let bufferSize = 30 // 1 second at 30fps

    func recognizeGesture(hand: HandAnchor) -> CustomGesture? {
        let pose = extractHandPose(hand)
        gestureBuffer.append(pose)

        if gestureBuffer.count > bufferSize {
            gestureBuffer.removeFirst()
        }

        // Pattern matching
        if let gesture = matchGesturePattern(gestureBuffer) {
            return gesture
        }

        return nil
    }

    private func matchGesturePattern(_ buffer: [HandPose]) -> CustomGesture? {
        // Wave detection
        if detectWavePattern(buffer) {
            return .wave
        }

        // Raise hand detection
        if detectRaisedHand(buffer.last) {
            return .raiseHand
        }

        // Thumbs up detection
        if detectThumbsUp(buffer.last) {
            return .thumbsUp
        }

        return nil
    }
}
```

### Hand Physics

**Hand Collision**:
```swift
// Add collision to hand entities
func setupHandCollision(handEntity: Entity) {
    let collisionShape = ShapeResource.generateSphere(radius: 0.02) // 2cm

    handEntity.components[CollisionComponent.self] = CollisionComponent(
        shapes: [collisionShape],
        mode: .trigger,
        filter: CollisionFilter(
            group: .hand,
            mask: .interactiveObject
        )
    )
}
```

**Object Interaction**:
```swift
// Grab object with hand
func grabObject(hand: Entity, object: Entity) {
    // Attach object to hand
    object.parent = hand

    // Maintain relative position
    let relativePosition = object.position(relativeTo: hand)
    object.position = relativePosition

    // Disable physics temporarily
    object.components[PhysicsBodyComponent.self]?.mode = .kinematic
}
```

### Performance Optimization

**Hand Tracking Specifications**:
- **Update Rate**: 30 Hz (ARKit provides 60 Hz, downsample if needed)
- **Latency**: < 50ms
- **CPU Usage**: < 5%
- **Power Impact**: Low

**Optimization Techniques**:
```swift
// Throttle hand updates
private var lastHandUpdate: Date = .distantPast
private let updateInterval: TimeInterval = 1/30 // 30 Hz

func throttledHandUpdate(hand: HandAnchor) {
    let now = Date()
    guard now.timeIntervalSince(lastHandUpdate) >= updateInterval else {
        return
    }

    lastHandUpdate = now
    processHandUpdate(hand)
}
```

---

## 5. Eye Tracking Implementation

### Privacy-First Eye Tracking

**User Consent**:
```swift
class EyeTrackingManager {
    func requestEyeTrackingAuthorization() async -> Bool {
        // Request permission
        let status = await ARKitSession.requestAuthorization(for: [.eyeTracking])

        return status[.eyeTracking] == .allowed
    }
}
```

**Privacy Requirements**:
- ✅ Explicit user consent required
- ✅ Clear explanation of use case
- ✅ Data never leaves device (except anonymized analytics)
- ✅ User can revoke permission anytime
- ✅ No recording or storage of raw eye data

### Eye Tracking Data

**Available Information**:
```swift
struct EyeTrackingData {
    let gazeDirection: SIMD3<Float> // Direction vector
    let gazeOrigin: SIMD3<Float> // Origin point
    let isTracking: Bool // Tracking confidence
    let timestamp: TimeInterval
}
```

**Note**: visionOS provides gaze direction only, NOT exact eye position or pupil data (for privacy)

### Attention Detection

**Focus Tracking**:
```swift
class AttentionTracker {
    private var focusedEntity: Entity?
    private var focusStartTime: Date?

    func updateAttention(gazeDirection: SIMD3<Float>, entities: [Entity]) {
        let hitEntity = rayCast(origin: gazeOrigin, direction: gazeDirection, entities: entities)

        if hitEntity != focusedEntity {
            // Focus changed
            if let previous = focusedEntity {
                handleFocusLost(previous, duration: focusDuration)
            }

            focusedEntity = hitEntity
            focusStartTime = Date()

            if let current = hitEntity {
                handleFocusGained(current)
            }
        }
    }

    private var focusDuration: TimeInterval {
        guard let startTime = focusStartTime else { return 0 }
        return Date().timeIntervalSince(startTime)
    }
}
```

### Learning Applications

**1. Reading Comprehension Tracking**:
```swift
// Track reading patterns
func trackReadingProgress(gazeData: EyeTrackingData, textBlocks: [TextBlock]) {
    guard let currentBlock = findGazedBlock(gazeData, in: textBlocks) else {
        return
    }

    // Record reading metrics
    let metrics = ReadingMetrics(
        blockId: currentBlock.id,
        dwellTime: focusDuration,
        timestamp: Date()
    )

    // Detect struggles (long dwell time)
    if metrics.dwellTime > 5.0 {
        // Offer help
        offerContextualHelp(for: currentBlock)
    }
}
```

**2. Attention Analytics**:
```swift
struct AttentionAnalytics {
    let totalFocusTime: TimeInterval
    let distractedTime: TimeInterval
    let focusedElements: [UUID: TimeInterval]
    let engagementScore: Double // 0.0 - 1.0

    var isEngaged: Bool {
        engagementScore > 0.7
    }
}
```

**3. Adaptive Content Pacing**:
```swift
class AdaptivePacingEngine {
    func adjustContentSpeed(attention: AttentionAnalytics) -> PlaybackSpeed {
        if attention.engagementScore < 0.5 {
            return .slow // Learner struggling
        } else if attention.engagementScore > 0.9 {
            return .fast // Learner mastering quickly
        } else {
            return .normal
        }
    }
}
```

### Eye Tracking Specifications

**Technical Specifications**:
- **Update Rate**: 30-60 Hz
- **Accuracy**: ±2-3° (system-dependent)
- **Latency**: < 50ms
- **Range**: Effective within 5m
- **Power Impact**: Low

**Limitations**:
- Works best in well-lit environments
- May be less accurate with certain eye conditions
- Requires calibration (automatic)
- Not available for all users (accessibility)

---

## 6. Spatial Audio Specifications

### Spatial Audio Architecture

**Audio Engine**:
```swift
class SpatialAudioManager {
    private let audioEngine = AVAudioEngine()
    private let environmentNode = AVAudioEnvironmentNode()

    func setupSpatialAudio() {
        // Configure environment
        environmentNode.listenerPosition = AVAudio3DPoint(x: 0, y: 0, z: 0)
        environmentNode.renderingAlgorithm = .HRTF // Head-Related Transfer Function

        // Attach nodes
        audioEngine.attach(environmentNode)
        audioEngine.connect(environmentNode, to: audioEngine.mainMixerNode, format: nil)

        // Start engine
        try? audioEngine.start()
    }
}
```

### RealityKit Spatial Audio

**3D Audio Sources**:
```swift
// Add spatial audio to entity
func addSpatialAudio(to entity: Entity, audioFile: String) async throws {
    let audioResource = try await AudioFileResource(named: audioFile)

    let audioComponent = SpatialAudioComponent(
        resource: audioResource,
        distanceAttenuation: .rolloff(
            distance: 1.0,
            rolloffFactor: 1.0
        ),
        directivity: .cone(
            angle: Angle2D(degrees: 45),
            blend: 0.5
        )
    )

    entity.components[SpatialAudioComponent.self] = audioComponent
}
```

### Audio Zones

**Environment Audio Zones**:

1. **Learning Space**
   - **Ambient Audio**: Subtle background music
   - **Volume**: 20-30%
   - **3D**: False (ambient)
   - **Files**: `ambient_learning.mp3`

2. **Practice Area**
   - **Instructional Audio**: Guided voiceover
   - **Volume**: 60-80%
   - **3D**: True (directional)
   - **Position**: Follow instructor avatar

3. **Collaborative Space**
   - **Voice Chat**: Spatial voice positioning
   - **Volume**: 70-100%
   - **3D**: True (per participant)
   - **Attenuation**: Distance-based

4. **Assessment Area**
   - **UI Sounds**: Feedback audio
   - **Volume**: 40-60%
   - **3D**: False (UI layer)
   - **Files**: `success.wav`, `error.wav`

### Audio Specifications

**Audio Formats**:
- **Compressed**: AAC, MP3 (for music/ambient)
- **Uncompressed**: WAV, AIFF (for UI sounds)
- **Spatial**: Dolby Atmos (for immersive content)
- **Sample Rate**: 48 kHz
- **Bit Depth**: 16-bit (UI), 24-bit (music)

**File Size Targets**:
- **UI Sounds**: < 50 KB each
- **Short Audio**: < 500 KB (< 30 seconds)
- **Ambient Audio**: < 5 MB (looping)
- **Instructional**: < 20 MB per lesson

**Performance**:
- **Max Concurrent Sources**: 32
- **Latency**: < 50ms
- **CPU Usage**: < 3%

### Audio Distance Attenuation

**Rolloff Models**:
```swift
// Linear Rolloff
.rolloff(distance: 2.0, rolloffFactor: 1.0)
// Volume decreases linearly with distance

// Inverse Rolloff (realistic)
.rolloff(distance: 1.0, rolloffFactor: 2.0)
// Volume decreases proportional to 1/distance

// Exponential Rolloff
.rolloff(distance: 1.0, rolloffFactor: 3.0)
// Rapid decrease, simulates sound absorption
```

**Distance Ranges**:
- **Near Field**: 0-2m (100% volume)
- **Mid Field**: 2-10m (rolloff applied)
- **Far Field**: 10m+ (minimum 10% volume)

### Directivity

**Audio Directivity Patterns**:
```swift
// Omnidirectional (ambient)
.directivity(.omnidirectional)

// Cone (focused)
.directivity(.cone(
    angle: Angle2D(degrees: 60), // Cone width
    blend: 0.3 // Transition smoothness
))

// Beam (narrow)
.directivity(.cone(
    angle: Angle2D(degrees: 30),
    blend: 0.1
))
```

### Voice Chat Specifications

**Spatial Voice**:
```swift
// Configure spatial voice for collaboration
func setupSpatialVoice(for participant: Participant, at position: SIMD3<Float>) {
    let audioEntity = Entity()
    audioEntity.position = position

    // Add participant voice stream
    let voiceComponent = SpatialVoiceComponent(
        participantId: participant.id,
        position: position,
        distanceAttenuation: .rolloff(distance: 2.0, rolloffFactor: 1.5)
    )

    audioEntity.components[SpatialVoiceComponent.self] = voiceComponent
}
```

**Voice Specifications**:
- **Codec**: Opus (low latency)
- **Bitrate**: 32-64 kbps
- **Sample Rate**: 48 kHz
- **Latency**: < 100ms
- **Echo Cancellation**: Enabled
- **Noise Suppression**: Enabled

---

## 7. Accessibility Requirements

### Vision Accessibility

#### VoiceOver Support

**Implementation Requirements**:
```swift
// All interactive elements must have accessibility labels
Button("Enroll") {
    enrollInCourse()
}
.accessibilityLabel("Enroll in course")
.accessibilityHint("Double tap to enroll in this course")

// Custom 3D entities
entity.accessibilityLabel = "Interactive equipment model"
entity.accessibilityHint = "Use pinch gesture to interact"
entity.accessibilityValue = "Not yet operated"
```

**VoiceOver Features**:
- ✅ All UI elements have descriptive labels
- ✅ Navigation hints provided
- ✅ State changes announced
- ✅ Spatial audio cues for 3D objects
- ✅ Custom rotor for quick navigation

**3D Content Accessibility**:
```swift
// Provide audio descriptions of 3D scenes
func provideSceneDescription() -> String {
    """
    You are in a virtual manufacturing floor.
    Equipment station is 2 meters ahead.
    Control panel is to your right.
    Exit is behind you.
    """
}
```

#### Dynamic Type

**Text Scaling**:
```swift
Text("Course Title")
    .font(.title)
    .dynamicTypeSize(...DynamicTypeSize.accessibility5)

// Support range: .xSmall to .accessibility5 (11 sizes)
```

**Minimum Font Sizes**:
- **Body Text**: 14pt (scales to 62pt)
- **Headers**: 20pt (scales to 88pt)
- **Captions**: 12pt (scales to 53pt)
- **Buttons**: 16pt (scales to 70pt)

**Layout Adaptation**:
```swift
@Environment(\.dynamicTypeSize) var dynamicTypeSize

var body: some View {
    if dynamicTypeSize >= .accessibility1 {
        VStack {
            // Vertical layout for large text
        }
    } else {
        HStack {
            // Horizontal layout for normal text
        }
    }
}
```

#### Color and Contrast

**Contrast Ratios**:
- **Normal Text**: 4.5:1 minimum
- **Large Text**: 3:1 minimum
- **UI Components**: 3:1 minimum
- **Focus Indicators**: 3:1 minimum

**Color Blindness Support**:
```swift
// Use SF Symbols with color-independent meaning
Image(systemName: "checkmark.circle.fill")
    .foregroundStyle(.green)
    .accessibilityLabel("Completed")

// Avoid relying solely on color
// ❌ Red = Error, Green = Success
// ✅ X icon + Red = Error, Checkmark + Green = Success
```

**High Contrast Mode**:
```swift
@Environment(\.colorSchemeContrast) var contrast

var borderWidth: CGFloat {
    contrast == .increased ? 3 : 1
}
```

#### Reduced Motion

**Animation Alternatives**:
```swift
@Environment(\.accessibilityReduceMotion) var reduceMotion

var animation: Animation? {
    reduceMotion ? nil : .spring(duration: 0.3)
}

// Use opacity fades instead of complex animations
withAnimation(animation) {
    isVisible.toggle()
}
```

**Immersive Experience Alternatives**:
- Offer 2D window alternative to full immersion
- Provide static scenes for motion-sensitive users
- Allow teleportation instead of smooth movement

### Hearing Accessibility

#### Captions and Subtitles

**Video Content**:
```swift
VideoPlayer(player: videoPlayer)
    .captionDisplayMode(.always)

// Provide captions for all video content
// Support multiple languages
```

**Caption Specifications**:
- **Format**: WebVTT or SRT
- **Text Size**: Adjustable
- **Position**: Customizable
- **Background**: Semi-transparent black
- **Font**: Sans-serif, high contrast

#### Visual Indicators

**Audio Alternatives**:
- Replace audio cues with visual indicators
- Provide visual feedback for voice commands
- Show transcript for AI tutor responses

```swift
// Visual feedback for audio event
if audioPlaying {
    Image(systemName: "speaker.wave.3.fill")
        .symbolEffect(.variableColor.iterative)
}
```

### Motor Accessibility

#### Alternative Input Methods

**Dwell Control**:
```swift
// Activate buttons by looking at them
Button("Activate") {
    action()
}
.dwellActivation(duration: 2.0)
```

**Voice Control**:
```swift
// Support voice commands
.accessibilityInputLabels(["Enroll", "Sign up", "Join"])
```

**Switch Control**:
- Support sequential navigation
- Large hit targets (minimum 60pt)
- Clear focus indicators

#### Interaction Accommodations

**Gesture Alternatives**:
- Provide button alternatives to gestures
- Support pointer devices
- Allow keyboard navigation

**Specifications**:
- **Minimum Target Size**: 60pt × 60pt (44mm × 44mm)
- **Target Spacing**: 8pt minimum
- **Touch Duration**: Accept slow touches (up to 2 seconds)

### Cognitive Accessibility

#### Simplified Modes

**Reduced Complexity**:
```swift
@AppStorage("simplifiedMode") var simplifiedMode = false

var body: some View {
    if simplifiedMode {
        SimplifiedInterfaceView()
    } else {
        FullInterfaceView()
    }
}
```

**Features**:
- Reduce visual clutter
- Simplified navigation
- Clearer instructions
- Longer timeouts
- Remove time pressure

#### Content Organization

**Clear Structure**:
- Consistent navigation
- Logical information hierarchy
- Clear headings
- Progress indicators
- Breadcrumbs

**Language**:
- Simple, clear language
- Avoid jargon
- Provide glossary
- Visual aids

### Accessibility Testing Requirements

**Testing Checklist**:
- ✅ VoiceOver navigation works completely
- ✅ All interactive elements have labels
- ✅ Keyboard navigation is functional
- ✅ Color contrast meets WCAG 2.1 AA
- ✅ Dynamic Type support verified
- ✅ Reduced Motion tested
- ✅ Captions available for all media
- ✅ Alternative input methods work
- ✅ Focus indicators are visible
- ✅ Error messages are clear

---

## 8. Privacy and Security Requirements

### Data Privacy

#### User Data Collection

**Collected Data**:
1. **Profile Data**
   - Name, email, employee ID
   - Department, role, learning preferences
   - **Storage**: Encrypted locally + encrypted cloud backup
   - **Retention**: Duration of employment + 30 days

2. **Learning Progress**
   - Course enrollments, completion status
   - Assessment scores, time spent
   - **Storage**: Encrypted cloud database
   - **Retention**: 7 years (compliance requirement)

3. **Analytics Data**
   - Interaction events (anonymized)
   - Performance metrics (aggregated)
   - **Storage**: Analytics service (anonymized)
   - **Retention**: 2 years

**NOT Collected**:
- ❌ Raw eye tracking data
- ❌ Raw hand pose data
- ❌ Spatial map of user's environment
- ❌ Recordings of user's appearance
- ❌ Personal conversations (unless explicitly recorded for training)

#### Privacy Controls

**User Rights**:
```swift
class PrivacyManager {
    // GDPR Article 15: Right to access
    func exportUserData(userId: UUID) async throws -> DataExport

    // GDPR Article 17: Right to be forgotten
    func deleteAllUserData(userId: UUID) async throws

    // GDPR Article 20: Right to data portability
    func exportInStandardFormat(userId: UUID) async throws -> JSON

    // User consent management
    func updateConsent(userId: UUID, consent: ConsentPreferences) async throws
}
```

**Consent Management**:
```swift
struct ConsentPreferences: Codable {
    var allowAnalytics: Bool
    var allowPersonalization: Bool
    var allowThirdPartyIntegrations: Bool
    var allowAITutor: Bool

    // Granular eye tracking consent
    var allowEyeTrackingForAttention: Bool
    var allowEyeTrackingForAnalytics: Bool
}
```

#### Data Minimization

**Principles**:
- Only collect data necessary for functionality
- Anonymize data when possible
- Aggregate data before transmission
- Delete data when no longer needed

**Example - Anonymized Analytics**:
```swift
struct AnonymizedEvent {
    let eventType: String
    let timestamp: Date
    let sessionId: UUID // Not tied to user
    let cohortId: UUID // Group identifier
    let metadata: [String: String] // No PII

    // No userId, email, name, or identifying information
}
```

### Data Security

#### Encryption

**At Rest**:
```swift
// SwiftData with encryption
@Model
class SensitiveData {
    @Attribute(.encrypted) var personalInfo: String
    @Attribute(.encrypted) var assessmentData: Data
}
```

**In Transit**:
- **TLS 1.3** for all network communication
- **Certificate Pinning** for critical APIs
- **End-to-End Encryption** for peer communication

**Encryption Specifications**:
- **Algorithm**: AES-256-GCM
- **Key Storage**: Keychain (Secure Enclave when available)
- **Key Rotation**: Every 90 days
- **Forward Secrecy**: Enabled

#### Authentication & Authorization

**Authentication Methods**:
1. **SSO Integration**
   - SAML 2.0
   - OAuth 2.0 / OpenID Connect
   - Enterprise identity providers

2. **Multi-Factor Authentication**
   - TOTP (Time-based One-Time Password)
   - Push notifications
   - Biometric (Face ID - if Vision Pro supports)

3. **Session Management**
   - Session timeout: 4 hours of inactivity
   - Secure token storage (Keychain)
   - Automatic re-authentication

**Authorization**:
```swift
enum UserRole {
    case learner
    case instructor
    case contentCreator
    case manager
    case admin
}

enum Permission {
    case viewCourse
    case enrollInCourse
    case createContent
    case manageLearners
    case viewAnalytics
    case adminAccess
}

func hasPermission(_ permission: Permission, role: UserRole) -> Bool {
    // Role-based access control (RBAC)
}
```

#### Secure Communication

**API Security**:
```swift
struct APIRequest {
    var url: URL
    var method: HTTPMethod
    var headers: [String: String] = [
        "Authorization": "Bearer \(token)",
        "X-API-Version": "1.0",
        "X-Request-ID": UUID().uuidString,
        "Content-Type": "application/json"
    ]

    // Request signing for critical operations
    var signature: String {
        HMAC<SHA256>.authenticationCode(
            for: requestBody.data(using: .utf8)!,
            using: SymmetricKey(data: apiSecret.data(using: .utf8)!)
        ).hexString
    }
}
```

**Rate Limiting**:
- **Authentication**: 5 attempts per 15 minutes
- **API Calls**: 100 requests per minute per user
- **Content Download**: 10 GB per day per user

### Compliance

#### GDPR Compliance

**Requirements**:
- ✅ Data minimization
- ✅ Purpose limitation
- ✅ Storage limitation
- ✅ Integrity and confidentiality
- ✅ Accountability

**Data Processing Agreement**:
- Legal basis for processing
- Data retention policies
- Subprocessor management
- Data breach notification (< 72 hours)

#### Industry-Specific Compliance

**FERPA** (Educational Records):
- Student data protection
- Parental consent (if applicable)
- Access controls

**HIPAA** (Healthcare Training):
- Protected Health Information (PHI) safeguards
- Business Associate Agreement (BAA)
- Audit logging

**SOC 2 Type II**:
- Security controls
- Availability guarantees
- Processing integrity
- Confidentiality
- Privacy

### Security Testing

**Security Testing Requirements**:
- [ ] Penetration testing (annually)
- [ ] Vulnerability scanning (monthly)
- [ ] Security code review
- [ ] Dependency vulnerability scanning
- [ ] SSL/TLS configuration testing
- [ ] Authentication bypass testing
- [ ] Authorization testing
- [ ] Input validation testing
- [ ] Encryption verification

---

## 9. Data Persistence Strategy

### Local Storage (On-Device)

#### SwiftData

**Primary Local Store**:
```swift
@main
struct CorporateUniversityApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [
            Learner.self,
            Course.self,
            CourseEnrollment.self,
            LearningModule.self,
            Assessment.self
            // ... other models
        ])
    }
}
```

**Schema**:
```swift
@Model
class Learner {
    @Attribute(.unique) var id: UUID
    var employeeId: String
    var firstName: String
    var lastName: String
    var email: String

    @Relationship(deleteRule: .cascade) var enrollments: [CourseEnrollment]

    var createdAt: Date
    var updatedAt: Date
}
```

**Query Examples**:
```swift
// Query enrolled courses
@Query(filter: #Predicate<CourseEnrollment> { enrollment in
    enrollment.status == .active
}, sort: \CourseEnrollment.enrolledAt, order: .reverse)
var activeEnrollments: [CourseEnrollment]

// Query completed courses
@Query(filter: #Predicate<CourseEnrollment> { enrollment in
    enrollment.status == .completed
})
var completedCourses: [CourseEnrollment]
```

#### File Storage

**Asset Storage**:
```swift
class FileStorageManager {
    private let fileManager = FileManager.default

    // Storage locations
    var documentsDirectory: URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    var cacheDirectory: URL {
        fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
    }

    // Store downloaded course content
    func storeCourseAssets(courseId: UUID, assets: [Asset]) async throws {
        let courseDirectory = documentsDirectory
            .appendingPathComponent("Courses")
            .appendingPathComponent(courseId.uuidString)

        try fileManager.createDirectory(at: courseDirectory, withIntermediateDirectories: true)

        for asset in assets {
            let assetPath = courseDirectory.appendingPathComponent(asset.filename)
            try asset.data.write(to: assetPath)
        }
    }

    // Get storage size
    func getStorageSize() -> Int64 {
        // Calculate total size of stored files
    }
}
```

**Storage Quotas**:
- **Documents**: Unlimited (backed up to iCloud)
- **Cache**: 10 GB maximum (automatically purged)
- **Temp**: 1 GB maximum (purged on app exit)

#### UserDefaults

**Simple Preferences**:
```swift
@AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding = false
@AppStorage("preferredImmersionLevel") var preferredImmersionLevel = "mixed"
@AppStorage("enableHapticFeedback") var enableHapticFeedback = true
```

### Cloud Storage

#### CloudKit

**Public Database** (Course catalog, shared content):
```swift
class CloudKitManager {
    private let container = CKContainer(identifier: "iCloud.com.company.corporateuniversity")
    private let publicDatabase: CKDatabase

    init() {
        publicDatabase = container.publicCloudDatabase
    }

    // Fetch course catalog
    func fetchCourses() async throws -> [Course] {
        let query = CKQuery(recordType: "Course", predicate: NSPredicate(value: true))
        let results = try await publicDatabase.records(matching: query)

        return results.matchResults.compactMap { try? $0.1.get() }.map { record in
            Course(from: record)
        }
    }
}
```

**Private Database** (User progress, personal data):
```swift
// Save user progress
func saveProgress(_ enrollment: CourseEnrollment) async throws {
    let record = CKRecord(recordType: "Enrollment")
    record["userId"] = enrollment.learner.id.uuidString
    record["courseId"] = enrollment.course.id.uuidString
    record["progress"] = enrollment.progressPercentage

    try await container.privateCloudDatabase.save(record)
}
```

**Shared Database** (Collaborative learning):
```swift
// Share learning space with team
func shareLearninga Space(_ space: LearningSpace, with participants: [Participant]) async throws {
    let share = CKShare(rootRecord: space.record)
    share[CKShare.SystemFieldKey.title] = space.name

    for participant in participants {
        let shareParticipant = CKShare.Participant()
        shareParticipant.permission = .readWrite
        shareParticipant.userIdentity = try await lookupUserIdentity(email: participant.email)
        share.addParticipant(shareParticipant)
    }

    try await container.sharedCloudDatabase.save(share)
}
```

#### Custom Backend API

**REST API Storage**:
```swift
class BackendStorageService {
    private let baseURL = URL(string: "https://api.corporateuniversity.com/v1")!

    // Sync progress to backend
    func syncProgress(_ enrollment: CourseEnrollment) async throws {
        let endpoint = baseURL.appendingPathComponent("/progress/sync")

        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONEncoder().encode(enrollment)

        let (_, response) = try await URLSession.shared.data(for: request)

        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw StorageError.syncFailed
        }
    }

    // Fetch from backend
    func fetchEnrollments(userId: UUID) async throws -> [CourseEnrollment] {
        let endpoint = baseURL.appendingPathComponent("/users/\(userId.uuidString)/enrollments")

        let (data, _) = try await URLSession.shared.data(from: endpoint)
        return try JSONDecoder().decode([CourseEnrollment].self, from: data)
    }
}
```

### Synchronization Strategy

#### Online/Offline Sync

**Sync Manager**:
```swift
@Observable
class SyncManager {
    var isSyncing: Bool = false
    var lastSyncDate: Date?
    var hasPendingChanges: Bool = false

    // Bidirectional sync
    func synchronize() async throws {
        isSyncing = true
        defer { isSyncing = false }

        // 1. Push local changes to cloud
        let localChanges = try await fetchLocalChanges(since: lastSyncDate)
        try await pushChanges(localChanges)

        // 2. Fetch remote changes
        let remoteChanges = try await fetchRemoteChanges(since: lastSyncDate)
        try await applyChanges(remoteChanges)

        // 3. Resolve conflicts
        try await resolveConflicts()

        lastSyncDate = Date()
        hasPendingChanges = false
    }

    // Conflict resolution
    private func resolveConflicts() async throws {
        // Strategy: Server wins for progress, local wins for preferences
    }
}
```

**Sync Triggers**:
- App launch
- App enters foreground
- After completing lesson
- Every 5 minutes (if active)
- Manual sync button

#### Offline Mode

**Offline Capabilities**:
```swift
class OfflineManager {
    // Check if content is available offline
    func isAvailableOffline(courseId: UUID) -> Bool {
        return downloadedCourses.contains(courseId)
    }

    // Download for offline use
    func downloadCourse(_ course: Course) async throws {
        let assets = try await fetchCourseAssets(course.id)

        for asset in assets {
            try await downloadAsset(asset)
        }

        markAsDownloaded(course.id)
    }

    // Queue operations for when online
    func queueOperation(_ operation: OfflineOperation) {
        pendingOperations.append(operation)
    }

    // Execute pending operations when online
    func executePendingOperations() async {
        for operation in pendingOperations {
            try? await execute(operation)
        }
        pendingOperations.removeAll()
    }
}
```

### Data Retention

**Retention Policies**:
- **Active Enrollments**: Retained indefinitely
- **Completed Courses**: 7 years
- **Assessment Results**: 7 years (compliance)
- **Analytics Events**: 2 years
- **Cache**: 30 days
- **Logs**: 90 days

**Automatic Cleanup**:
```swift
class DataCleanupManager {
    func performCleanup() async {
        // Delete old cache
        await deleteCacheOlderThan(days: 30)

        // Delete temporary files
        await deleteTemporaryFiles()

        // Archive old enrollments
        await archiveCompletedCourses(olderThan: .years(7))

        // Prune logs
        await deleteLogsOlderThan(days: 90)
    }
}
```

---

## 10. Network Architecture

### Network Layers

#### HTTP Client

```swift
class NetworkClient {
    private let session: URLSession
    private let baseURL: URL
    private var authToken: String?

    init(baseURL: URL) {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 300
        configuration.waitsForConnectivity = true
        configuration.allowsCellularAccess = true

        self.session = URLSession(configuration: configuration)
        self.baseURL = baseURL
    }

    func request<T: Decodable>(
        _ endpoint: Endpoint,
        method: HTTPMethod = .get,
        body: Encodable? = nil
    ) async throws -> T {
        let request = try buildRequest(endpoint, method: method, body: body)

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.httpError(statusCode: httpResponse.statusCode)
        }

        return try JSONDecoder().decode(T.self, from: data)
    }

    private func buildRequest(
        _ endpoint: Endpoint,
        method: HTTPMethod,
        body: Encodable?
    ) throws -> URLRequest {
        let url = baseURL.appendingPathComponent(endpoint.path)

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        if let body = body {
            request.httpBody = try JSONEncoder().encode(body)
        }

        return request
    }
}
```

#### Retry Logic

```swift
class RetryPolicy {
    let maxRetries: Int = 3
    let baseDelay: TimeInterval = 1.0

    func shouldRetry(error: Error, attempt: Int) -> Bool {
        guard attempt < maxRetries else { return false }

        // Retry on network errors
        if (error as NSError).domain == NSURLErrorDomain {
            return true
        }

        // Retry on 5xx server errors
        if let networkError = error as? NetworkError,
           case .httpError(let statusCode) = networkError,
           (500...599).contains(statusCode) {
            return true
        }

        return false
    }

    func delayForRetry(attempt: Int) -> TimeInterval {
        // Exponential backoff: 1s, 2s, 4s
        return baseDelay * pow(2, Double(attempt))
    }
}
```

### Caching Strategy

#### HTTP Caching

```swift
class CacheManager {
    private let cache = URLCache(
        memoryCapacity: 50_000_000, // 50 MB
        diskCapacity: 200_000_000, // 200 MB
        directory: nil
    )

    func configureCache() {
        URLCache.shared = cache
    }

    // Cache policy per endpoint
    func cachePolicy(for endpoint: Endpoint) -> URLRequest.CachePolicy {
        switch endpoint {
        case .courses:
            return .returnCacheDataElseLoad // Cache course catalog
        case .userProgress:
            return .reloadIgnoringLocalCacheData // Always fresh progress
        case .courseContent:
            return .returnCacheDataElseLoad // Cache content
        default:
            return .useProtocolCachePolicy
        }
    }
}
```

#### Custom Caching

```swift
actor DataCache {
    private var cache: [String: CacheEntry] = [:]
    private let maxAge: TimeInterval = 3600 // 1 hour

    struct CacheEntry {
        let data: Any
        let timestamp: Date

        var isExpired: Bool {
            Date().timeIntervalSince(timestamp) > maxAge
        }
    }

    func get<T>(key: String) -> T? {
        guard let entry = cache[key], !entry.isExpired else {
            return nil
        }
        return entry.data as? T
    }

    func set<T>(key: String, value: T) {
        cache[key] = CacheEntry(data: value, timestamp: Date())
    }

    func clear() {
        cache.removeAll()
    }
}
```

### API Endpoints

**Base URL**: `https://api.corporateuniversity.com/v1`

**Endpoints**:
```swift
enum Endpoint {
    case login
    case courses(filter: CourseFilter?)
    case courseDetail(id: UUID)
    case enroll(courseId: UUID)
    case userProgress(userId: UUID)
    case updateProgress(enrollmentId: UUID)
    case assessments(courseId: UUID)
    case submitAssessment(assessmentId: UUID)
    case aiTutor(sessionId: UUID)
    case analytics(userId: UUID)

    var path: String {
        switch self {
        case .login:
            return "/auth/login"
        case .courses:
            return "/courses"
        case .courseDetail(let id):
            return "/courses/\(id.uuidString)"
        // ... other cases
        }
    }

    var method: HTTPMethod {
        switch self {
        case .login, .enroll, .submitAssessment:
            return .post
        default:
            return .get
        }
    }
}
```

### WebSocket (Real-Time)

**Collaborative Sessions**:
```swift
class WebSocketManager {
    private var webSocket: URLSessionWebSocketTask?
    private let url = URL(string: "wss://realtime.corporateuniversity.com")!

    func connect() {
        let session = URLSession(configuration: .default)
        webSocket = session.webSocketTask(with: url)
        webSocket?.resume()

        receiveMessages()
    }

    func send(_ message: CollaborationMessage) {
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(message),
              let string = String(data: data, encoding: .utf8) else {
            return
        }

        webSocket?.send(.string(string)) { error in
            if let error = error {
                print("WebSocket send error: \(error)")
            }
        }
    }

    private func receiveMessages() {
        webSocket?.receive { [weak self] result in
            switch result {
            case .success(let message):
                self?.handleMessage(message)
                self?.receiveMessages() // Continue receiving
            case .failure(let error):
                print("WebSocket receive error: \(error)")
            }
        }
    }
}
```

### Network Monitoring

```swift
import Network

class NetworkMonitor {
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")

    @Published var isConnected: Bool = true
    @Published var connectionType: ConnectionType = .unknown

    enum ConnectionType {
        case wifi, cellular, ethernet, unknown
    }

    func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            self?.isConnected = path.status == .satisfied

            if path.usesInterfaceType(.wifi) {
                self?.connectionType = .wifi
            } else if path.usesInterfaceType(.cellular) {
                self?.connectionType = .cellular
            } else {
                self?.connectionType = .unknown
            }
        }

        monitor.start(queue: queue)
    }
}
```

---

## 11. Testing Requirements

### Unit Testing

**XCTest Framework**:
```swift
import XCTest
@testable import CorporateUniversity

class LearningServiceTests: XCTestCase {
    var learningService: LearningService!
    var mockNetworkClient: MockNetworkClient!

    override func setUp() {
        super.setUp()
        mockNetworkClient = MockNetworkClient()
        learningService = LearningService(networkClient: mockNetworkClient)
    }

    func testFetchCourses() async throws {
        // Given
        let expectedCourses = [
            Course(id: UUID(), title: "Test Course")
        ]
        mockNetworkClient.coursesResult = .success(expectedCourses)

        // When
        let courses = try await learningService.fetchCourses(filter: .all)

        // Then
        XCTAssertEqual(courses.count, 1)
        XCTAssertEqual(courses.first?.title, "Test Course")
    }

    func testEnrollInCourse() async throws {
        // Test enrollment logic
    }
}
```

**Testing Requirements**:
- ✅ All service methods have unit tests
- ✅ All ViewModels have unit tests
- ✅ Business logic has > 80% code coverage
- ✅ Edge cases covered
- ✅ Error handling tested

### UI Testing

**XCUITest Framework**:
```swift
class LearningFlowUITests: XCTestCase {
    let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }

    func testEnrollmentFlow() throws {
        // Given: User is on dashboard
        XCTAssertTrue(app.staticTexts["Dashboard"].exists)

        // When: User taps on a course
        app.buttons["Browse Courses"].tap()
        app.cells.firstMatch.tap()

        // And: User enrolls in the course
        app.buttons["Enroll"].tap()

        // Then: Success message is shown
        XCTAssertTrue(app.alerts["Enrollment Successful"].exists)
    }

    func testImmersiveEnvironment() throws {
        // Test opening immersive space
        app.buttons["Start Learning"].tap()

        // Wait for environment to load
        let environment = app.otherElements["LearningEnvironment"]
        XCTAssertTrue(environment.waitForExistence(timeout: 5))
    }
}
```

**UI Testing Requirements**:
- ✅ Critical user flows tested
- ✅ Window/space transitions tested
- ✅ Gesture interactions tested
- ✅ Accessibility tested

### Spatial Testing

**RealityKit Testing**:
```swift
class SpatialInteractionTests: XCTestCase {
    var scene: RealityKit.Scene!

    func testEntityInteraction() async throws {
        // Given: A learning object in the scene
        let entity = ModelEntity()
        entity.components[LearningObjectComponent.self] = LearningObjectComponent(
            objectId: UUID(),
            interactionType: .tap,
            isLocked: false
        )
        scene.addAnchor(entity)

        // When: User taps the entity
        let tapLocation = entity.position
        simulateTap(at: tapLocation)

        // Then: Interaction is triggered
        XCTAssertTrue(entity.components[LearningObjectComponent.self]?.wasInteracted == true)
    }

    func testHandGesture() async throws {
        // Test hand tracking gestures
    }
}
```

### Performance Testing

**XCTest Metrics**:
```swift
class PerformanceTests: XCTestCase {
    func testEnvironmentLoadingPerformance() throws {
        measure(metrics: [XCTClockMetric()]) {
            // Load immersive environment
            let environment = loadEnvironment()
            XCTAssertNotNil(environment)
        }

        // Target: < 2 seconds
    }

    func testMemoryUsage() throws {
        measure(metrics: [XCTMemoryMetric()]) {
            // Load multiple courses
            loadMultipleCourses(count: 10)
        }

        // Target: < 500 MB
    }

    func testRenderingPerformance() throws {
        measure(metrics: [XCTCPUMetric(), XCTStorageMetric()]) {
            // Render complex 3D scene
            renderComplexScene()
        }

        // Target: 90 FPS sustained
    }
}
```

**Performance Targets**:
- **Frame Rate**: 90 FPS minimum (98% of the time)
- **Environment Load**: < 5 seconds
- **Memory Usage**: < 3 GB
- **CPU Usage**: < 70% average
- **Battery**: > 3 hours continuous use

### Integration Testing

**API Integration**:
```swift
class IntegrationTests: XCTestCase {
    func testEndToEndEnrollment() async throws {
        // Test complete flow from course selection to completion
        let userId = UUID()
        let courseId = UUID()

        // 1. Fetch courses
        let courses = try await learningService.fetchCourses(filter: .all)
        XCTAssertFalse(courses.isEmpty)

        // 2. Enroll
        let enrollment = try await learningService.enrollInCourse(
            learnerId: userId,
            courseId: courseId
        )
        XCTAssertNotNil(enrollment)

        // 3. Complete lessons
        for lesson in enrollment.course.modules.flatMap(\.lessons) {
            try await learningService.completeLesson(
                enrollmentId: enrollment.id,
                lessonId: lesson.id
            )
        }

        // 4. Verify completion
        let updatedEnrollment = try await learningService.getEnrollment(
            enrollmentId: enrollment.id
        )
        XCTAssertEqual(updatedEnrollment.status, .completed)
    }
}
```

### Accessibility Testing

**Automated Accessibility Testing**:
```swift
class AccessibilityTests: XCTestCase {
    func testVoiceOverSupport() throws {
        let app = XCUIApplication()
        app.launch()

        // Enable VoiceOver simulation
        XCUIElement.perform(NSSelectorFromString("setAccessibilityTraits:"), with: UIAccessibilityTraits.button)

        // Test that all buttons have labels
        for button in app.buttons.allElementsBoundByIndex {
            XCTAssertNotNil(button.label)
            XCTAssertFalse(button.label.isEmpty)
        }
    }

    func testDynamicTypeSupport() throws {
        // Test different text sizes
        let app = XCUIApplication()

        for contentSize in ["XS", "M", "XXXL", "AX5"] {
            app.launchArguments = ["-UIPreferredContentSizeCategoryName", contentSize]
            app.launch()

            // Verify layout adapts
            XCTAssertTrue(app.staticTexts["Welcome"].exists)
        }
    }
}
```

### Testing Coverage Goals

**Code Coverage Targets**:
- **Overall**: 80%+
- **Business Logic**: 90%+
- **ViewModels**: 85%+
- **Services**: 90%+
- **UI Components**: 60%+

**Testing Strategy**:
1. **Unit Tests**: Fast, isolated, run on every build
2. **UI Tests**: Critical paths, run before merge
3. **Integration Tests**: Full flows, nightly builds
4. **Performance Tests**: Weekly regression testing
5. **Accessibility Tests**: Before each release

---

## Summary

This technical specification provides detailed implementation guidance for the Corporate University Platform on visionOS. It covers:

- **Modern Swift 6.0** with strict concurrency
- **Complete visionOS integration** (windows, volumes, immersive spaces)
- **Advanced spatial interactions** (hand tracking, eye tracking, gestures)
- **Spatial audio** for immersive learning
- **Comprehensive accessibility** (VoiceOver, Dynamic Type, alternative inputs)
- **Enterprise-grade security** (encryption, authentication, compliance)
- **Robust data persistence** (SwiftData, CloudKit, offline support)
- **Scalable network architecture** (REST API, WebSocket, caching)
- **Thorough testing requirements** (unit, UI, performance, accessibility)

All specifications align with Apple's Human Interface Guidelines and visionOS best practices, ensuring a world-class spatial learning experience.
