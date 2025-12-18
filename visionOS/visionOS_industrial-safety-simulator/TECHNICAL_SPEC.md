# Industrial Safety Simulator - Technical Specifications

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

## Technology Stack

### Core Frameworks and Languages

#### Primary Language
- **Swift 6.0+**
  - Strict concurrency enabled
  - Modern async/await patterns
  - Sendable protocol adoption
  - Actor-based concurrency for thread safety

#### UI Framework
- **SwiftUI 5.0+**
  - Declarative UI composition
  - @Observable macro for state management
  - Custom view modifiers for spatial UI
  - Ornaments and toolbars
  - Glass background materials

#### 3D and Spatial Computing
- **RealityKit 4.0+**
  - Entity Component System (ECS)
  - Custom components for safety scenarios
  - Physics simulation
  - Particle systems for hazards (fire, smoke, chemicals)
  - Advanced materials and lighting
  - Spatial audio integration

- **ARKit 6.0+**
  - Hand tracking
  - World tracking
  - Plane detection (for AR modes)
  - Scene reconstruction

- **Reality Composer Pro**
  - 3D scene authoring
  - USDZ asset creation
  - Material design
  - Animation authoring

#### Data and Persistence
- **SwiftData**
  - @Model macro for data models
  - Relationship management
  - Query API
  - Schema migration

- **CloudKit**
  - Private database for user data
  - Cross-device synchronization
  - Shared database for collaborative sessions
  - Push notifications

#### Networking
- **URLSession**
  - Modern async/await API
  - TLS 1.3 security
  - Certificate pinning
  - Response caching

- **Network Framework**
  - Low-latency real-time communication
  - Peer-to-peer connectivity
  - Network path monitoring

#### Machine Learning
- **Core ML**
  - On-device inference
  - Custom models for:
    - Hazard prediction
    - Behavior analysis
    - Risk scoring
    - Performance prediction

- **Create ML**
  - Model training and fine-tuning
  - Transfer learning for safety scenarios

#### Collaboration
- **Group Activities (SharePlay)**
  - Multi-user training sessions
  - Spatial audio for team communication
  - Synchronized state management
  - Real-time activity coordination

#### Additional Frameworks
- **SpriteKit**: 2D UI elements and particle effects
- **AVFoundation**: Video recording and playback
- **Speech**: Voice commands and recognition
- **Vision**: Image analysis for PPE detection
- **Charts**: Data visualization in SwiftUI
- **CryptoKit**: Data encryption and security

### Development Tools

#### Required
- **Xcode 16.0+**
- **visionOS SDK 2.0+**
- **Reality Composer Pro**
- **Instruments**: Performance profiling
- **SF Symbols 6**: Icon library

#### Recommended
- **Blender**: 3D model creation and optimization
- **Adobe Substance**: Material creation
- **Git**: Version control
- **Postman**: API testing

### Third-Party Dependencies (Minimal)

```swift
// Package.swift
dependencies: [
    // Optional: Enhanced charting
    .package(url: "https://github.com/danielgindi/Charts", from: "5.0.0"),

    // Optional: Advanced networking
    .package(url: "https://github.com/Alamofire/Alamofire", from: "5.8.0"),

    // Optional: Analytics (if not using built-in)
    // Prefer first-party solutions when possible
]
```

### Minimum System Requirements

#### Hardware
- **Device**: Apple Vision Pro
- **Storage**: 10GB free space (for app + scenarios)
- **Memory**: 16GB RAM (system provided)

#### Software
- **Operating System**: visionOS 2.0 or later
- **iCloud Account**: Required for cloud sync
- **Network**: Wi-Fi or 5G for full features (offline mode available)

---

## visionOS Presentation Modes

### 1. WindowGroup - Primary Interface

#### Main Dashboard Window

```swift
WindowGroup(id: "main-dashboard") {
    DashboardView()
        .environment(appState)
}
.defaultSize(width: 1200, height: 800)
.windowResizability(.contentSize)
```

**Specifications:**
- **Default Size**: 1200x800 points
- **Resizable**: Yes (minimum: 800x600, maximum: 1600x1000)
- **Glass Material**: Standard visionOS glass with vibrancy
- **Positioning**: Centered in user's field of view at launch
- **Persistence**: Remains open until explicitly closed

**Content:**
- Training progress overview
- Quick access to scenarios
- Recent activity feed
- Upcoming training schedule
- Performance summary cards
- Notification center

#### Analytics Dashboard Window

```swift
WindowGroup(id: "analytics-dashboard") {
    AnalyticsDashboardView()
        .environment(appState)
}
.defaultSize(width: 1400, height: 900)
```

**Specifications:**
- **Default Size**: 1400x900 points
- **Charts**: Using Swift Charts for data visualization
- **Real-time Updates**: WebSocket connection for live metrics
- **Export Options**: PDF and CSV export capabilities

**Content:**
- Performance trend charts
- Incident heat maps
- Compliance status indicators
- Team performance comparisons
- Training effectiveness metrics
- Risk score visualizations

#### Settings and Administration Window

```swift
WindowGroup(id: "settings") {
    SettingsView()
        .environment(appState)
}
.defaultSize(width: 1000, height: 700)
```

**Content:**
- User preferences
- Notification settings
- Integration configuration
- Privacy controls
- Scenario management (admin)
- Organization settings (admin)

### 2. Volumetric Windows - 3D Content

#### Equipment Training Volume

```swift
WindowGroup(id: "equipment-training") {
    EquipmentTrainingVolumeView()
        .environment(appState)
}
.windowStyle(.volumetric)
.defaultSize(width: 2.0, height: 2.0, depth: 2.0, in: .meters)
```

**Specifications:**
- **Default Size**: 2m x 2m x 2m cubic volume
- **Content Scale**: 1:1 real-world scale for equipment
- **Interaction**: Direct manipulation with hands
- **Rotation**: User can walk around volume to view all angles
- **Lighting**: Simulated industrial lighting

**Use Cases:**
- Machinery inspection training
- PPE donning and doffing practice
- Tool operation training
- Equipment maintenance procedures
- Lockout/tagout device interaction

#### Hazard Identification Volume

```swift
WindowGroup(id: "hazard-identification") {
    HazardIdentificationVolumeView()
        .environment(appState)
}
.windowStyle(.volumetric)
.defaultSize(width: 3.0, height: 2.5, depth: 3.0, in: .meters)
```

**Specifications:**
- **Content**: 3D industrial environment section
- **Interactions**: Tap hazards to identify
- **Visual Feedback**: Hazards pulse with subtle glow
- **Progressive Disclosure**: Hazards revealed based on difficulty

### 3. ImmersiveSpace - Full Training Environments

#### Safety Simulation Space

```swift
ImmersiveSpace(id: "safety-simulation") {
    SafetySimulationView()
        .environment(appState)
}
.immersionStyle(selection: $immersionLevel, in: .progressive)
```

**Specifications:**
- **Immersion Style**: Progressive (allows user control)
- **Immersion Levels**:
  - `.mixed`: Pass-through visible, virtual content overlaid
  - `.progressive`: Adjustable blend of real and virtual
  - `.full`: Complete virtual environment
- **Default**: Start in `.progressive` at 50%

**Environment Types:**

##### Factory Floor Simulation
- **Scene Size**: 20m x 15m floor area
- **Ceiling Height**: 8m
- **Equipment**: Industrial machinery, conveyor systems, robotic arms
- **Hazards**: Moving machinery, pinch points, slip hazards
- **Lighting**: Realistic factory lighting with shadows
- **Audio**: Ambient machinery sounds, alarm systems

##### Construction Site Simulation
- **Scene Size**: 25m x 25m outdoor area
- **Vertical Range**: Ground to 12m (scaffolding)
- **Equipment**: Heavy machinery, scaffolding, tools
- **Hazards**: Fall hazards, struck-by hazards, electrical
- **Weather**: Configurable (clear, rain, wind)
- **Audio**: Construction sounds, traffic, wind

##### Chemical Plant Simulation
- **Scene Size**: 15m x 15m process area
- **Equipment**: Tanks, pipes, valves, control panels
- **Hazards**: Chemical spills, pressure releases, toxic gases
- **Visual Effects**: Gas clouds, liquid spills, steam
- **Audio**: Process sounds, leak alarms, ventilation

##### Emergency Evacuation Simulation
- **Scene**: Multi-level building interior
- **Scenario**: Fire with smoke and heat
- **Visual Effects**: Volumetric smoke, fire, emergency lighting
- **Audio**: Fire alarms, fire sounds, emergency announcements
- **Navigation**: Emergency exit signs, evacuation routes

### Presentation Mode Transitions

```swift
class PresentationManager {
    func transitionToImmersive(scenario: SafetyScenario) async throws {
        // 1. Dismiss unnecessary windows
        await dismissWindow(id: "analytics-dashboard")

        // 2. Show preparation UI
        await openWindow(id: "training-prep")

        // 3. Wait for user readiness
        await waitForUserReady()

        // 4. Open immersive space
        await openImmersiveSpace(id: "safety-simulation")

        // 5. Load scenario
        await loadScenario(scenario)
    }

    func returnToDashboard() async {
        // 1. Save session data
        await saveSession()

        // 2. Close immersive space
        await dismissImmersiveSpace()

        // 3. Show results window
        await openWindow(id: "session-results")

        // 4. Return to dashboard
        await openWindow(id: "main-dashboard")
    }
}
```

---

## Gesture and Interaction Specifications

### Primary Interaction Methods

#### 1. Gaze + Tap (Primary)

**Gaze Targeting:**
- **Target Size**: Minimum 60pt (approximately 44mm at 1m distance)
- **Hover State**: 100ms delay before showing hover feedback
- **Hover Feedback**: Subtle scale increase (1.05x) and glow
- **Focus Indicator**: System-provided focus ring

**Tap Gesture:**
- **Detection**: Pinch fingers together
- **Feedback**: Haptic pulse (if supported)
- **Visual Confirmation**: Brief highlight animation
- **Debounce**: 200ms to prevent double-taps

```swift
.onTapGesture {
    Task {
        await handleHazardIdentification(hazard)
    }
}
.hoverEffect(.highlight)
```

#### 2. Direct Touch (3D Objects)

**For Volumetric Content:**
- **Grab**: Pinch near object, then move hand
- **Rotate**: Two-handed pinch and rotate
- **Scale**: Two-handed pinch and spread (if enabled)
- **Release**: Release pinch

```swift
.gesture(
    DragGesture()
        .targetedToEntity(equipmentEntity)
        .onChanged { value in
            equipmentEntity.position = value.convert(value.location3D, from: .local, to: scene)
        }
)
```

#### 3. Spatial Gestures (Custom)

**Safety-Specific Gestures:**

**Emergency Stop:**
- **Gesture**: Both hands raised, palms forward
- **Recognition Distance**: Up to 2m
- **Action**: Immediately pause simulation, show safety UI
- **Feedback**: Audible tone + visual confirmation

```swift
func detectEmergencyStopGesture(handAnchors: [HandAnchor]) -> Bool {
    guard handAnchors.count == 2 else { return false }

    let bothRaised = handAnchors.allSatisfy { $0.originFromAnchorTransform.columns.3.y > eyeLevel - 0.2 }
    let palmsForward = handAnchors.allSatisfy { anchor in
        let palmNormal = anchor.handSkeleton?.joint(.forearmArm)?.anchorFromJointTransform.columns.2
        return palmNormal?.z ?? 0 < -0.8 // Facing away from user
    }

    return bothRaised && palmsForward
}
```

**PPE Inspection Gesture:**
- **Gesture**: Tap helmet area (head), chest (vest), hands (gloves)
- **Recognition**: Hand proximity to body parts
- **Action**: Trigger PPE check interface
- **Validation**: Verify correct inspection sequence

**Tool Grip Assessment:**
- **Gesture**: Grasp virtual tool
- **Recognition**: Hand shape and finger positions
- **Action**: Evaluate proper grip technique
- **Feedback**: Real-time correctness indicator

### Interaction Zones

```
Personal Space
├── Near Field (0.3m - 0.6m)
│   ├── Purpose: Detailed inspection, fine controls
│   └── Interactions: Precision gestures, reading detail
│
├── Comfortable Reach (0.6m - 1.0m)
│   ├── Purpose: Primary interaction zone
│   └── Interactions: Most UI elements, equipment operation
│
└── Extended Reach (1.0m - 2.0m)
    ├── Purpose: Environmental interaction
    └── Interactions: Large objects, spatial navigation
```

### Accessibility Alternative Inputs

- **Voice Commands**: Complete alternative input method
- **Dwell Selection**: Gaze-based selection with time delay (1.5s default)
- **Switch Control**: External switch device support
- **Pointer Control**: Head-based pointer (for mobility limitations)

---

## Hand Tracking Implementation

### Hand Tracking Configuration

```swift
import ARKit

class HandTrackingManager: @unchecked Sendable {
    private let arkitSession = ARKitSession()
    private let handTracking = HandTrackingProvider()

    func startTracking() async throws {
        guard HandTrackingProvider.isSupported else {
            throw TrackingError.handTrackingNotSupported
        }

        try await arkitSession.run([handTracking])
    }

    func trackHands() -> AsyncStream<(left: HandAnchor?, right: HandAnchor?)> {
        AsyncStream { continuation in
            Task {
                for await update in handTracking.anchorUpdates {
                    guard let anchor = update.anchor as? HandAnchor else { continue }

                    // Process hand anchor
                    continuation.yield((
                        left: anchor.chirality == .left ? anchor : nil,
                        right: anchor.chirality == .right ? anchor : nil
                    ))
                }
            }
        }
    }
}
```

### Tracked Joints

All 27 joints per hand tracked in real-time:

```
Hand Skeleton Joints:
├── Wrist
├── Thumb (4 joints): thumbTip, thumbDistal, thumbProximal, thumbKnuckle
├── Index (4 joints): indexFingerTip, indexFingerDistal, indexFingerIntermediate, indexFingerKnuckle
├── Middle (4 joints): middleFingerTip, middleFingerDistal, middleFingerIntermediate, middleFingerKnuckle
├── Ring (4 joints): ringFingerTip, ringFingerDistal, ringFingerIntermediate, ringFingerKnuckle
└── Little (4 joints): littleFingerTip, littleFingerDistal, littleFingerIntermediate, littleFingerKnuckle
```

### Hand Tracking Use Cases

#### 1. PPE Compliance Detection

```swift
func detectPPECompliance(handAnchor: HandAnchor) -> PPEComplianceStatus {
    guard let skeleton = handAnchor.handSkeleton else { return .unknown }

    // Check for glove detection (visual analysis)
    // Verify proper hand position for PPE inspection
    // Track donning sequence

    return .compliant // or .nonCompliant with details
}
```

#### 2. Tool Grip Analysis

```swift
func analyzeToolGrip(handAnchor: HandAnchor, tool: ToolEntity) -> GripAnalysis {
    guard let skeleton = handAnchor.handSkeleton else { return .invalid }

    let thumbPosition = skeleton.joint(.thumbTip)?.anchorFromJointTransform.columns.3
    let indexPosition = skeleton.joint(.indexFingerTip)?.anchorFromJointTransform.columns.3
    let middlePosition = skeleton.joint(.middleFingerTip)?.anchorFromJointTransform.columns.3

    // Analyze grip pattern
    let gripType = classifyGripType(thumb: thumbPosition, index: indexPosition, middle: middlePosition)
    let gripStrength = estimateGripStrength(skeleton)
    let gripSafety = evaluateGripSafety(gripType, for: tool)

    return GripAnalysis(type: gripType, strength: gripStrength, safety: gripSafety)
}
```

#### 3. Safety Gesture Recognition

```swift
class SafetyGestureRecognizer {
    func recognizeGesture(leftHand: HandAnchor?, rightHand: HandAnchor?) -> SafetyGesture? {
        // Emergency stop: Both hands raised, palms forward
        if isEmergencyStop(left: leftHand, right: rightHand) {
            return .emergencyStop
        }

        // Stop signal: Single hand raised, palm forward
        if isStopSignal(hand: leftHand) || isStopSignal(hand: rightHand) {
            return .stopSignal
        }

        // Pointing: Index extended, other fingers curled
        if let pointing = detectPointing(hand: rightHand ?? leftHand) {
            return .pointing(direction: pointing)
        }

        return nil
    }

    private func isEmergencyStop(left: HandAnchor?, right: HandAnchor?) -> Bool {
        guard let left = left, let right = right else { return false }
        // Implementation details...
        return false
    }
}
```

#### 4. Procedural Step Verification

```swift
func verifyLockoutProcedure(handTracking: HandAnchor, step: ProcedureStep) -> Bool {
    switch step {
    case .insertLockoutDevice:
        return verifyInsertionMotion(handTracking)
    case .turnKeyClockwise:
        return verifyRotationMotion(handTracking, direction: .clockwise)
    case .pullToVerify:
        return verifyPullMotion(handTracking)
    default:
        return false
    }
}
```

### Hand Tracking Performance

- **Update Frequency**: 90Hz (synchronized with display)
- **Latency**: <16ms (end-to-end)
- **Accuracy**: Sub-millimeter joint positions
- **Occlusion Handling**: Prediction during temporary occlusion
- **Range**: Effective up to 1.5m from device

---

## Eye Tracking Implementation

### Eye Tracking Configuration

```swift
class EyeTrackingManager {
    private let arkitSession = ARKitSession()

    func requestAuthorization() async throws -> Bool {
        // Request user permission for eye tracking
        // Required for privacy compliance
        let authorization = await arkitSession.requestAuthorization(for: [.worldSensing])
        return authorization == .allowed
    }

    func trackGaze() -> AsyncStream<GazeInfo> {
        AsyncStream { continuation in
            // Gaze tracking implementation
            // Provides direction and focus point
        }
    }
}
```

### Eye Tracking Use Cases

#### 1. Attention Monitoring

```swift
struct AttentionMonitor {
    func trackUserAttention(in scenario: SafetyScenario) async {
        // Monitor where user looks during training
        // Identify if critical hazards were observed
        // Measure attention duration on safety elements
        // Detect distraction or loss of focus
    }

    func generateAttentionHeatmap() -> AttentionHeatmap {
        // Create 3D heatmap of where user looked
        // Highlight areas that received insufficient attention
        // Compare to expected attention patterns
    }
}
```

#### 2. Hazard Recognition Assessment

```swift
func evaluateHazardRecognition(gazeData: [GazePoint], hazards: [Hazard]) -> RecognitionScore {
    var score: Double = 0
    var recognizedHazards: [Hazard] = []

    for hazard in hazards {
        let gazeDuration = calculateGazeDuration(on: hazard, from: gazeData)

        if gazeDuration > 0.5 { // 500ms threshold
            recognizedHazards.append(hazard)
            score += hazard.severityWeight
        }
    }

    return RecognitionScore(
        totalScore: score,
        recognizedCount: recognizedHazards.count,
        totalHazards: hazards.count,
        recognizedHazards: recognizedHazards
    )
}
```

#### 3. Adaptive UI Positioning

```swift
func positionUIAdaptively(based on gaze: GazeInfo) {
    // Position warning overlays in peripheral vision
    // Move critical alerts to center of gaze
    // Adjust UI to avoid blocking important content
}
```

### Privacy Considerations

- **Opt-in Required**: Explicit user permission
- **No Raw Data Storage**: Only aggregate attention metrics stored
- **On-Device Processing**: Gaze data never leaves device
- **User Control**: Can disable at any time
- **Transparency**: Clear indication when eye tracking is active

---

## Spatial Audio Specifications

### Audio Architecture

```swift
import AVFoundation
import Spatial

class SpatialAudioManager {
    private let audioEngine = AVAudioEngine()
    private let environment = AVAudioEnvironmentNode()

    func setupSpatialAudio() {
        // Configure audio engine
        audioEngine.attach(environment)
        audioEngine.connect(environment, to: audioEngine.outputNode, format: nil)

        // Configure environmental reverb
        environment.reverbParameters.enable = true
        environment.reverbParameters.level = 0
        environment.reverbParameters.loadFactoryReverbPreset(.largeRoom) // Adjust per scenario
    }
}
```

### Audio Elements

#### 1. Ambient Environmental Sounds

**Factory Floor:**
```swift
struct FactoryAmbience {
    let machinerHum: AudioFile          // Continuous, 3D positioned
    let conveyorMovement: AudioFile     // Directional, moving source
    let ventilationSystem: AudioFile    // Diffuse, background
    let randomClanks: [AudioFile]       // Occasional, spatial

    func playAmbience(in environment: AVAudioEnvironmentNode) {
        // Position each sound source in 3D space
        // Apply appropriate reverb and occlusion
    }
}
```

**Construction Site:**
- Heavy equipment operation (3D positioned)
- Distant traffic noise (environmental)
- Wind sounds (ambient)
- Worker voices (spatial, distant)

**Chemical Plant:**
- Process equipment sounds (hums, flows)
- Ventilation systems (continuous background)
- Occasional valve releases (positional)

#### 2. Hazard Audio Cues

```swift
struct HazardAudioCues {
    // Fire hazard
    let fireCrackling: AudioFile        // 3D positioned, intensity based on proximity
    let fireAlarm: AudioFile            // Loud, penetrating, spatial

    // Chemical spill
    let liquidPouring: AudioFile        // Directional
    let hissingGas: AudioFile          // Expanding sound field
    let chemicalAlarm: AudioFile        // Distinct tone

    // Equipment failure
    let grindingMetal: AudioFile        // Harsh, attention-grabbing
    let emergencyShutdown: AudioFile    // Sequential sounds

    func playHazardCue(_ hazard: HazardType, at position: SIMD3<Float>) {
        // Position audio source at hazard location
        // Adjust volume based on severity and distance
        // Apply environmental effects (reverb, occlusion)
    }
}
```

#### 3. Voice Instructions and Coaching

```swift
struct VoiceCoaching {
    func provideInstruction(_ instruction: String, priority: Priority) async {
        let utterance = AVSpeechUtterance(string: instruction)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.5 // Slightly slower for clarity

        // Position voice based on priority
        if priority == .critical {
            // Center, close, clear (no environmental effects)
        } else {
            // Slight spatial offset, with reverb
        }

        await speak(utterance)
    }
}
```

#### 4. Team Communication Audio (Collaborative Sessions)

```swift
class TeamAudioManager {
    func enableSpatialTeamAudio(participants: [Participant]) {
        for participant in participants {
            // Position each participant's audio source at their avatar location
            let audioSource = AVAudioPlayerNode()
            audioSource.position = participant.avatarPosition

            // Apply spatial rendering
            // Enable real-time voice streaming
        }
    }

    func updateParticipantPosition(_ participant: Participant, newPosition: SIMD3<Float>) {
        // Update audio source position as participant moves
        // Maintain realistic spatial audio experience
    }
}
```

### Audio Specifications

- **Sample Rate**: 48kHz
- **Bit Depth**: 24-bit
- **Format**: AAC or Apple Lossless for storage, PCM for processing
- **Spatial Rendering**: HRTF-based binaural rendering
- **Channels**: Stereo output, spatial positioning via HRTF
- **Latency**: <20ms for voice communication
- **Max Simultaneous Sources**: 32 spatial audio sources

### Accessibility Audio Features

- **Audio Descriptions**: Detailed verbal descriptions of visual elements
- **Enhanced Audio Cues**: Increased volume and clarity for important sounds
- **Mono Audio Option**: For users with single-ear hearing
- **Visual Audio Indicators**: Visual representation of audio events

---

## Accessibility Requirements

### VoiceOver Support

#### Implementation Requirements

```swift
// Every interactive element must have accessibility label
Button("Start Training") {
    startTraining()
}
.accessibilityLabel("Start Safety Training Session")
.accessibilityHint("Begins the selected safety scenario training")
.accessibilityAction(.magicTap) {
    quickStartLastScenario()
}

// Custom 3D content accessibility
RealityView { content in
    let hazardEntity = createHazardEntity()
    content.add(hazardEntity)
}
.accessibilityLabel("Chemical spill hazard")
.accessibilityValue("High severity, located 3 meters ahead")
.accessibilityHint("Tap to identify hazard and receive safety guidance")
```

#### Spatial Content Descriptions

```swift
struct SpatialAccessibilityHelper {
    func describeEnvironment(_ environment: SafetyEnvironment) -> String {
        // Provide detailed audio description of 3D environment
        // "You are in a factory floor. Ahead at 12 o'clock, 5 meters away, there is a conveyor belt moving left to right..."
        // "To your left at 9 o'clock, 2 meters, there is a fire extinguisher..."
        // "Warning: Rotating machinery hazard at 2 o'clock, 3 meters..."

        var description = "Environment: \(environment.name). "

        for object in environment.objects {
            let distance = calculateDistance(to: object)
            let direction = calculateClockDirection(to: object)
            description += "\(object.type) at \(direction), \(distance) meters. "
        }

        return description
    }
}
```

### Dynamic Type Support

```swift
// All text must scale with user preference
Text("Identify the hazards in this environment")
    .font(.body) // Automatically scales with Dynamic Type
    .dynamicTypeSize(...DynamicTypeSize.xxxLarge) // Support up to xxxLarge

// Custom 3D text entities
func createScalableTextEntity(_ text: String) -> ModelEntity {
    let entity = ModelEntity(mesh: .generateText(
        text,
        font: .systemFont(ofSize: UIFontMetrics.default.scaledValue(for: 24))
    ))
    return entity
}
```

### Reduce Motion Support

```swift
@Environment(\.accessibilityReduceMotion) var reduceMotion

var body: some View {
    HazardIndicator()
        .animation(
            reduceMotion ? .none : .easeInOut(duration: 0.3),
            value: isHighlighted
        )
}

// In RealityKit scenarios
func applyMotionSettings() {
    if reduceMotion {
        // Disable non-essential animations
        // Reduce particle effects
        // Simplify transitions
        // Maintain critical hazard indicators with static visuals
    }
}
```

### Color and Contrast

```swift
// Use semantic colors that adapt to accessibility settings
Color.primary       // Black or white based on color scheme
Color.secondary     // Adapts for contrast

// Hazard color coding with patterns (not color-only)
struct HazardIndicator: View {
    let hazard: Hazard

    var body: some View {
        ZStack {
            // Color
            Circle()
                .fill(hazard.color)

            // Pattern for color-blind users
            Image(systemName: hazard.patternIcon)
                .symbolRenderingMode(.hierarchical)

            // Text label
            Text(hazard.severity)
                .font(.caption.bold())
                .accessibilityHidden(true) // Already in VoiceOver label
        }
    }
}
```

### Alternative Input Methods

#### Voice Control

```swift
class VoiceControlManager {
    func enableVoiceControl() {
        // Register voice commands
        registerCommand("Start training", action: startTraining)
        registerCommand("Identify hazard", action: enterIdentificationMode)
        registerCommand("Emergency stop", action: emergencyPause)
        registerCommand("Show menu", action: showMenu)
        registerCommand("Next step", action: advanceStep)
    }
}
```

#### Switch Control Support

```swift
// Ensure focus order is logical
TabView {
    DashboardView()
        .accessibilityAction(.escape) { returnToHome() }

    TrainingView()
        .accessibilityAction(.escape) { pauseTraining() }
}
.accessibilitySortPriority(1) // Control focus order
```

### Closed Captions for Audio

```swift
struct CaptionedAudioPlayer {
    func playInstructionWithCaption(_ instruction: Instruction) {
        // Play audio
        playAudio(instruction.audioFile)

        // Show synchronized caption
        showCaption(instruction.text, duration: instruction.duration)
    }
}

// Caption overlay
struct CaptionOverlay: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.title3)
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(12)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            .padding(.bottom, 50)
    }
}
```

---

## Privacy and Security Requirements

### Data Privacy

#### Personal Identifiable Information (PII) Handling

```swift
struct PrivacyManager {
    // Minimize PII collection
    func createUser(email: String, name: String) -> SafetyUser {
        let user = SafetyUser(
            id: UUID(), // Never use external IDs
            email: hash(email), // Hash email for matching only
            name: name, // Only what's necessary
            // NO: Social security numbers, birthdates, addresses, phone numbers
        )
        return user
    }

    // Encrypt PII at rest
    func storeSensitiveData(_ data: Data) throws {
        let encrypted = try CryptoKit.AES.GCM.seal(data, using: getEncryptionKey())
        try saveToKeychain(encrypted.combined)
    }

    // Anonymize analytics data
    func recordAnalyticsEvent(_ event: TrainingEvent) {
        let anonymized = AnonymousEvent(
            userId: hash(event.userId), // One-way hash
            scenarioType: event.scenarioType, // No scenario-specific IDs
            performanceMetrics: event.metrics, // Aggregated only
            timestamp: event.timestamp.rounded(to: .hour) // Reduce precision
        )
        analyticsService.record(anonymized)
    }
}
```

#### Biometric Data Protection

```swift
class BiometricDataHandler {
    // Never store raw biometric data
    func processGazeData(_ gazeData: GazeInfo) {
        // Extract insights immediately
        let attentionMetrics = calculateAttentionMetrics(gazeData)

        // Store only aggregated metrics
        store(attentionMetrics)

        // Discard raw data
        // DO NOT: save(gazeData)
    }

    // Separate biometric data from identity
    func recordHandTrackingPerformance(_ handData: HandAnchor) {
        let performanceMetrics = extractPerformanceMetrics(handData)

        // Store with anonymous session ID only
        store(performanceMetrics, sessionID: anonymousSessionID)

        // Never link to user identity
    }
}
```

#### Data Retention

```swift
struct DataRetentionPolicy {
    // Training session data: 2 years
    static let trainingDataRetention: TimeInterval = 2 * 365 * 24 * 60 * 60

    // Analytics data: 1 year
    static let analyticsRetention: TimeInterval = 1 * 365 * 24 * 60 * 60

    // Biometric insights: 90 days
    static let biometricRetention: TimeInterval = 90 * 24 * 60 * 60

    func enforceRetention() async {
        // Automatically delete data past retention period
        await deleteExpiredData()

        // User right to erasure (GDPR)
        await processErasureRequests()
    }
}
```

### Authentication & Authorization

#### Multi-Factor Authentication

```swift
class AuthenticationService {
    func login(email: String, password: String) async throws -> AuthToken {
        // 1. Verify credentials
        let credentials = try await verifyCredentials(email, password)

        // 2. Require MFA
        try await requestMFACode(email)

        // 3. Verify MFA
        let mfaCode = try await waitForMFACode()
        try await verifyMFACode(mfaCode, for: email)

        // 4. Issue token
        let token = try await issueAuthToken(for: credentials.userID)

        return token
    }

    // Support multiple MFA methods
    enum MFAMethod {
        case sms
        case email
        case authenticatorApp
        case biometric // Face ID
    }
}
```

#### Role-Based Access Control (RBAC)

```swift
enum Permission {
    case viewOwnData
    case viewTeamData
    case viewOrganizationData
    case createScenario
    case modifyScenario
    case deleteScenario
    case manageUsers
    case viewAnalytics
    case exportData
    case configureIntegrations
}

enum Role {
    case worker
    case supervisor
    case safetyManager
    case instructor
    case administrator

    var permissions: Set<Permission> {
        switch self {
        case .worker:
            return [.viewOwnData]
        case .supervisor:
            return [.viewOwnData, .viewTeamData, .viewAnalytics]
        case .safetyManager:
            return [.viewOwnData, .viewTeamData, .viewOrganizationData, .viewAnalytics, .exportData]
        case .instructor:
            return [.viewOwnData, .viewTeamData, .createScenario, .modifyScenario, .viewAnalytics]
        case .administrator:
            return Set(Permission.allCases)
        }
    }
}

func checkPermission(user: SafetyUser, permission: Permission) -> Bool {
    return user.role.permissions.contains(permission)
}
```

### Network Security

#### TLS Configuration

```swift
class SecureNetworkService {
    func createSecureSession() -> URLSession {
        let configuration = URLSessionConfiguration.default

        // TLS 1.3 minimum
        configuration.tlsMinimumSupportedProtocolVersion = .TLSv13

        // Certificate pinning
        let delegate = CertificatePinningDelegate()

        return URLSession(configuration: configuration, delegate: delegate, delegateQueue: nil)
    }
}

class CertificatePinningDelegate: NSObject, URLSessionDelegate {
    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        // Verify certificate matches pinned certificate
        guard let serverTrust = challenge.protectionSpace.serverTrust else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }

        // Compare to pinned certificate
        if verifyCertificate(serverTrust) {
            completionHandler(.useCredential, URLCredential(trust: serverTrust))
        } else {
            completionHandler(.cancelAuthenticationChallenge, nil)
        }
    }
}
```

#### API Key Management

```swift
struct SecureConfiguration {
    // NEVER hardcode API keys
    // Use Xcode configuration + environment variables

    static var apiKey: String {
        guard let key = ProcessInfo.processInfo.environment["API_KEY"] else {
            fatalError("API_KEY not configured")
        }
        return key
    }

    // Store sensitive tokens in Keychain
    static func storeAuthToken(_ token: String) throws {
        let data = token.data(using: .utf8)!

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "authToken",
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]

        SecItemAdd(query as CFDictionary, nil)
    }
}
```

---

## Data Persistence Strategy

### SwiftData Implementation

#### Model Configuration

```swift
import SwiftData

@main
struct IndustrialSafetyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [
            SafetyUser.self,
            Organization.self,
            SafetyScenario.self,
            TrainingSession.self,
            AIAnalysis.self,
            CollaborativeSession.self
        ])
    }
}
```

#### Data Queries

```swift
@Query(
    filter: #Predicate<TrainingSession> { session in
        session.userID == currentUserID &&
        session.startTime > Date().addingTimeInterval(-30 * 24 * 60 * 60) // Last 30 days
    },
    sort: \TrainingSession.startTime,
    order: .reverse
)
var recentSessions: [TrainingSession]

// Complex queries
@Query(
    filter: #Predicate<TrainingSession> { session in
        session.status == .completed &&
        session.score ?? 0 < 70 // Failed sessions
    }
)
var failedSessions: [TrainingSession]
```

#### Relationships

```swift
@Model
class SafetyUser {
    @Relationship(deleteRule: .cascade, inverse: \TrainingSession.user)
    var trainingSessions: [TrainingSession] = []

    @Relationship(inverse: \Organization.users)
    var organization: Organization?
}

@Model
class Organization {
    @Relationship(deleteRule: .cascade)
    var users: [SafetyUser] = []

    @Relationship(deleteRule: .cascade)
    var customScenarios: [SafetyScenario] = []
}
```

### CloudKit Synchronization

```swift
class CloudKitSyncService {
    private let container = CKContainer(identifier: "iCloud.com.company.IndustrialSafety")

    func enableSync() async throws {
        // Enable automatic sync
        // SwiftData handles CloudKit sync automatically when configured
    }

    func syncNow() async throws {
        // Manual sync trigger
        let database = container.privateCloudDatabase

        // Fetch changes
        let zone = CKRecordZone(zoneName: "SafetyTraining")
        let changes = try await database.recordZoneChanges(inZoneWith: zone.zoneID)

        // Process changes
        for change in changes {
            await processChange(change)
        }
    }

    func handleSyncConflict(_ conflict: SyncConflict) async -> Resolution {
        // Conflict resolution strategy
        switch conflict.type {
        case .trainingRecord:
            return .serverWins // Training records: server is source of truth
        case .userPreference:
            return .clientWins // User preferences: client is source of truth
        case .scenarioProgress:
            return .merge // Progress: merge both sides
        }
    }
}
```

### Local Caching Strategy

```swift
class CacheManager {
    // Asset caching
    private let assetCache = NSCache<NSString, Entity>()

    func cacheAsset(_ asset: Entity, forKey key: String) {
        assetCache.setObject(asset, forKey: key as NSString)
    }

    func retrieveAsset(forKey key: String) -> Entity? {
        return assetCache.object(forKey: key as NSString)
    }

    // Response caching
    private var responseCache: [String: CachedResponse] = [:]

    struct CachedResponse {
        let data: Data
        let expiry: Date

        var isExpired: Bool {
            return Date() > expiry
        }
    }

    func cacheResponse(_ data: Data, forURL url: URL, duration: TimeInterval = 300) {
        let expiry = Date().addingTimeInterval(duration)
        responseCache[url.absoluteString] = CachedResponse(data: data, expiry: expiry)
    }

    // Scenario pre-caching
    func precacheScenarios(_ scenarios: [SafetyScenario]) async throws {
        for scenario in scenarios {
            try await precacheScenario(scenario)
        }
    }

    private func precacheScenario(_ scenario: SafetyScenario) async throws {
        // Download all assets
        let assets = try await downloadAssets(for: scenario)

        // Cache in memory and on disk
        for asset in assets {
            cacheAsset(asset, forKey: asset.id)
            try await saveAssetToDisk(asset)
        }
    }
}
```

### Offline Mode Support

```swift
class OfflineModeManager {
    func enableOfflineMode() async throws {
        // 1. Download essential scenarios
        let essentialScenarios = try await fetchEssentialScenarios()
        try await downloadScenarios(essentialScenarios)

        // 2. Cache user data
        try await cacheUserData()

        // 3. Queue analytics events
        enableOfflineAnalytics()

        // 4. Update UI for offline mode
        await setOfflineMode(true)
    }

    func syncWhenOnline() async throws {
        guard isOnline else { return }

        // 1. Upload queued analytics
        try await uploadQueuedEvents()

        // 2. Sync training records
        try await syncTrainingRecords()

        // 3. Download scenario updates
        try await checkForScenarioUpdates()

        // 4. Update cached data
        try await refreshCache()
    }

    private var eventQueue: [AnalyticsEvent] = []

    func queueAnalyticsEvent(_ event: AnalyticsEvent) {
        eventQueue.append(event)

        // Persist queue to disk
        saveEventQueue()
    }

    private func uploadQueuedEvents() async throws {
        for event in eventQueue {
            try await analyticsService.uploadEvent(event)
        }
        eventQueue.removeAll()
        saveEventQueue()
    }
}
```

---

## Network Architecture

### API Endpoints

```
Base URL: https://api.industrialsafety.com/v1

Authentication:
POST   /auth/login
POST   /auth/logout
POST   /auth/refresh
POST   /auth/mfa/request
POST   /auth/mfa/verify

Users:
GET    /users/:userId
PUT    /users/:userId
GET    /users/:userId/sessions
GET    /users/:userId/performance
GET    /users/:userId/certifications

Scenarios:
GET    /scenarios
GET    /scenarios/:scenarioId
POST   /scenarios (admin)
PUT    /scenarios/:scenarioId (admin)
DELETE /scenarios/:scenarioId (admin)
GET    /scenarios/:scenarioId/assets

Training:
POST   /training/sessions/start
PUT    /training/sessions/:sessionId/complete
POST   /training/sessions/:sessionId/events
GET    /training/sessions/:sessionId

Analytics:
GET    /analytics/users/:userId
GET    /analytics/organizations/:orgId
GET    /analytics/compliance
POST   /analytics/reports/generate

AI:
POST   /ai/predict-hazards
POST   /ai/recommend-training
GET    /ai/insights/:userId
```

### Request/Response Format

```swift
// Request
struct APIRequest<Parameters: Encodable> {
    let endpoint: String
    let method: HTTPMethod
    let parameters: Parameters?
    let headers: [String: String]

    enum HTTPMethod: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case delete = "DELETE"
    }
}

// Response
struct APIResponse<T: Decodable>: Decodable {
    let success: Bool
    let data: T?
    let error: APIError?
    let meta: ResponseMeta?
}

struct APIError: Decodable {
    let code: String
    let message: String
    let details: [String: String]?
}

struct ResponseMeta: Decodable {
    let timestamp: Date
    let requestId: String
    let version: String
}
```

### Network Service Implementation

```swift
actor NetworkService {
    private let session: URLSession
    private let baseURL = URL(string: "https://api.industrialsafety.com/v1")!

    init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 300
        configuration.waitsForConnectivity = true

        self.session = URLSession(configuration: configuration)
    }

    func request<T: Decodable>(
        _ endpoint: String,
        method: HTTPMethod = .get,
        body: (some Encodable)? = nil
    ) async throws -> T {
        // Build request
        var request = URLRequest(url: baseURL.appendingPathComponent(endpoint))
        request.httpMethod = method.rawValue
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        // Add auth token
        if let token = try? await getAuthToken() {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        // Add body if present
        if let body = body {
            request.httpBody = try JSONEncoder().encode(body)
        }

        // Execute request
        let (data, response) = try await session.data(for: request)

        // Validate response
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.httpError(statusCode: httpResponse.statusCode)
        }

        // Decode response
        let apiResponse = try JSONDecoder().decode(APIResponse<T>.self, from: data)

        guard let responseData = apiResponse.data else {
            throw NetworkError.noData
        }

        return responseData
    }
}
```

### WebSocket for Real-Time Updates

```swift
class RealTimeService {
    private var webSocket: URLSessionWebSocketTask?

    func connect() async throws {
        let url = URL(string: "wss://api.industrialsafety.com/v1/realtime")!
        webSocket = URLSession.shared.webSocketTask(with: url)
        webSocket?.resume()

        // Start receiving messages
        await receiveMessages()
    }

    private func receiveMessages() async {
        do {
            while let message = try await webSocket?.receive() {
                switch message {
                case .string(let text):
                    await handleMessage(text)
                case .data(let data):
                    await handleData(data)
                @unknown default:
                    break
                }
            }
        } catch {
            print("WebSocket error: \(error)")
        }
    }

    func sendEvent(_ event: RealtimeEvent) async throws {
        let data = try JSONEncoder().encode(event)
        let message = URLSessionWebSocketTask.Message.data(data)
        try await webSocket?.send(message)
    }
}
```

---

## Testing Requirements

### Unit Testing

```swift
import XCTest
@testable import IndustrialSafety

final class TrainingEngineTests: XCTestCase {
    var trainingEngine: TrainingEngineService!
    var mockScenario: SafetyScenario!

    override func setUp() async throws {
        trainingEngine = TrainingEngineService()
        mockScenario = createMockScenario()
    }

    func testStartTrainingSession() async throws {
        // Given
        let user = createMockUser()

        // When
        let session = try await trainingEngine.startTrainingSession(
            scenario: mockScenario,
            user: user
        )

        // Then
        XCTAssertNotNil(session)
        XCTAssertEqual(session.status, .inProgress)
        XCTAssertEqual(session.userID, user.id)
    }

    func testHazardIdentificationScoring() async throws {
        // Given
        let session = createMockSession()
        let hazard = HazardIdentification(
            hazardID: UUID(),
            identifiedAt: Date(),
            timeTakenSeconds: 2.5,
            accuracy: true,
            severity: .high
        )

        // When
        await trainingEngine.recordHazardIdentification(hazard, session: session)
        let score = await trainingEngine.calculateScore(for: session)

        // Then
        XCTAssertGreaterThan(score, 0)
    }
}
```

### UI Testing

```swift
final class SafetySimulatorUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUp() {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    func testNavigateToScenarioLibrary() throws {
        // Navigate to scenario library
        app.buttons["Scenario Library"].tap()

        // Verify library is displayed
        XCTAssertTrue(app.staticTexts["Available Scenarios"].exists)
    }

    func testStartTrainingSession() throws {
        // Select a scenario
        app.buttons["Scenario Library"].tap()
        app.buttons["Fire Evacuation"].tap()

        // Start session
        app.buttons["Start Training"].tap()

        // Verify immersive space opens
        // Note: Testing immersive spaces requires special setup
        XCTAssertTrue(app.staticTexts["Training in Progress"].waitForExistence(timeout: 5))
    }
}
```

### Performance Testing

```swift
final class PerformanceTests: XCTestCase {
    func testScenarioLoadTime() throws {
        measure(metrics: [XCTClockMetric(), XCTMemoryMetric()]) {
            // Load heavy scenario
            let scenario = loadLargeScenario()
            XCTAssertNotNil(scenario)
        }
    }

    func testRenderingPerformance() throws {
        measure(metrics: [XCTClockMetric(), XCTCPUMetric()]) {
            // Render complex 3D scene
            renderComplexScene()
        }

        // Assert frame rate >= 90 FPS
        XCTAssertLessThanOrEqual(averageFrameTime, 11.1) // 11.1ms = 90 FPS
    }
}
```

### Integration Testing

```swift
final class IntegrationTests: XCTestCase {
    func testEndToEndTrainingFlow() async throws {
        // 1. Login
        let token = try await authService.login(email: "test@example.com", password: "password")
        XCTAssertNotNil(token)

        // 2. Fetch scenarios
        let scenarios = try await scenarioService.fetchAvailableScenarios(for: .manufacturing)
        XCTAssertFalse(scenarios.isEmpty)

        // 3. Start session
        let session = try await trainingEngine.startTrainingSession(
            scenario: scenarios[0],
            user: currentUser
        )
        XCTAssertEqual(session.status, .inProgress)

        // 4. Complete session
        try await trainingEngine.completeSession(session.id, results: mockResults)

        // 5. Verify analytics updated
        let performance = try await analyticsService.getUserPerformance(currentUser.id, dateRange: todayRange)
        XCTAssertGreaterThan(performance.sessionsCompleted, 0)
    }
}
```

### Accessibility Testing

```swift
final class AccessibilityTests: XCTestCase {
    func testVoiceOverLabels() throws {
        let app = XCUIApplication()
        app.launch()

        // All interactive elements should have labels
        let buttons = app.buttons.allElementsBoundByIndex
        for button in buttons {
            XCTAssertFalse(button.label.isEmpty, "Button missing accessibility label")
        }
    }

    func testDynamicTypeSupport() throws {
        // Test with largest Dynamic Type size
        let app = XCUIApplication()
        app.launchArguments += ["-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityXXXL"]
        app.launch()

        // Verify text is readable and UI is not broken
        XCTAssertTrue(app.staticTexts["Dashboard"].exists)
    }
}
```

### Test Coverage Requirements

- **Minimum Coverage**: 80% code coverage
- **Critical Paths**: 100% coverage for:
  - Authentication
  - Training session management
  - Hazard identification logic
  - Score calculation
  - Data persistence
  - Security features

---

## Performance Benchmarks

| Metric | Target | Maximum Acceptable |
|--------|--------|-------------------|
| Frame Rate | 90 FPS | 60 FPS minimum |
| Scenario Load Time | <8 seconds | 10 seconds |
| Input Latency | <20ms | 30ms |
| Memory Usage | <1.5GB | 2GB |
| App Launch Time | <3 seconds | 5 seconds |
| Network Request Time | <500ms | 1 second |
| Database Query Time | <100ms | 200ms |

---

This technical specification provides the detailed requirements for implementing the Industrial Safety Simulator on visionOS, ensuring a high-quality, accessible, secure, and performant spatial computing experience.
