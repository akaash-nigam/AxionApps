# Spatial Wellness Platform - Technical Specifications

## 1. Technology Stack

### 1.1 Core Technologies

| Component | Technology | Version | Purpose |
|-----------|------------|---------|---------|
| **Language** | Swift | 6.0+ | Primary development language |
| **UI Framework** | SwiftUI | visionOS 2.0+ | User interface |
| **3D Rendering** | RealityKit | 4.0+ | Spatial content |
| **AR Framework** | ARKit | 6.0+ | Spatial tracking |
| **Platform** | visionOS | 2.0+ | Operating system |
| **Concurrency** | Swift Concurrency | Native | async/await, actors |
| **Data Persistence** | SwiftData | Latest | Local database |
| **Health Integration** | HealthKit | Latest | Apple health data |
| **Networking** | URLSession | Native | HTTP client |
| **Security** | CryptoKit | Native | Encryption |
| **Audio** | AVAudioEngine | Latest | Spatial audio |
| **ML** | CoreML | Latest | On-device AI |
| **NLP** | Natural Language | Latest | Text processing |

### 1.2 Development Tools

```yaml
Development Environment:
  IDE: Xcode 16.0+
  Simulator: visionOS Simulator
  Reality Composer: Reality Composer Pro
  3D Modeling: Blender, Reality Composer Pro
  Version Control: Git
  CI/CD: Xcode Cloud / GitHub Actions

Testing Tools:
  Unit Testing: XCTest
  UI Testing: XCUITest
  Performance: Instruments
  Code Quality: SwiftLint
  Coverage: Xcode Code Coverage

Debugging Tools:
  - RealityKit Debugger
  - Memory Graph Debugger
  - Network Link Conditioner
  - Accessibility Inspector
  - Console.app for logging
```

### 1.3 Third-Party Dependencies

```swift
// Package.swift dependencies
dependencies: [
    // Networking
    .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.9.0"),

    // Async utilities
    .package(url: "https://github.com/apple/swift-async-algorithms", from: "1.0.0"),

    // Keychain wrapper
    .package(url: "https://github.com/kishikawakatsumi/KeychainAccess", from: "4.2.0"),

    // Image caching (for avatars, thumbnails)
    .package(url: "https://github.com/onevcat/Kingfisher.git", from: "7.10.0"),

    // Analytics
    .package(url: "https://github.com/mixpanel/mixpanel-swift", from: "4.0.0"),

    // Error tracking
    .package(url: "https://github.com/getsentry/sentry-cocoa", from: "8.0.0"),
]
```

---

## 2. visionOS Presentation Modes

### 2.1 WindowGroup Configuration

Windows are the primary interface for health data, settings, and standard UI interactions.

```swift
// Dashboard Window - Primary interface
WindowGroup(id: "dashboard") {
    DashboardView()
        .environment(\.appState, appState)
}
.windowStyle(.automatic)
.defaultSize(width: 800, height: 600)
.windowResizability(.contentSize)

// Biometric Detail Window
WindowGroup(id: "biometrics") {
    BiometricDetailView()
}
.defaultSize(width: 600, height: 800)
.windowResizability(.contentMinSize)

// Community/Social Window
WindowGroup(id: "community") {
    CommunityView()
}
.defaultSize(width: 900, height: 700)

// Settings Window
WindowGroup(id: "settings") {
    SettingsView()
}
.defaultSize(width: 700, height: 500)
.windowResizability(.contentSize)

// Analytics Window
WindowGroup(id: "analytics") {
    AnalyticsView()
}
.defaultSize(width: 1000, height: 800)
```

**Window Best Practices**:
- Default size: 600-1000pt width, optimized for viewing distance
- Glass background with appropriate blur
- Minimize window chrome, maximize content
- Support Dynamic Type for all text
- Ornaments for contextual actions

### 2.2 Volumetric Windows (3D Bounded Content)

Volumes display 3D health visualizations within bounded spaces.

```swift
// Health Landscape Volume - Main 3D visualization
WindowGroup(id: "healthLandscape") {
    HealthLandscapeVolume()
}
.windowStyle(.volumetric)
.defaultSize(width: 1.0, height: 1.0, depth: 1.0, in: .meters)

// Heart Rate Visualization Volume
WindowGroup(id: "heartRateViz") {
    HeartRateVisualizationVolume()
}
.windowStyle(.volumetric)
.defaultSize(width: 0.8, height: 0.8, depth: 0.8, in: .meters)

// Activity Timeline Volume
WindowGroup(id: "activityTimeline") {
    ActivityTimelineVolume()
}
.windowStyle(.volumetric)
.defaultSize(width: 1.2, height: 0.6, depth: 0.6, in: .meters)
```

**Volume Specifications**:
- Size: 0.5m - 2.0m per dimension
- Placement: 10-15° below eye level
- Distance: 0.5m - 3m from user
- Interactive elements: 60pt minimum hit target
- Performance: Optimize polygon count (<100k per volume)

### 2.3 Immersive Spaces (Full Immersion)

Immersive spaces for meditation, workouts, and therapeutic environments.

```swift
// Meditation Space - Progressive immersion
ImmersiveSpace(id: "meditation") {
    MeditationEnvironmentView()
}
.immersionStyle(selection: $immersionStyle, in: .progressive)
.upperLimbVisibility(.visible) // Show hands for gestures

// Virtual Gym - Full immersion
ImmersiveSpace(id: "virtualGym") {
    VirtualGymView()
}
.immersionStyle(selection: $immersionStyle, in: .full)
.upperLimbVisibility(.visible)

// Relaxation Beach - Progressive immersion
ImmersiveSpace(id: "relaxationBeach") {
    RelaxationBeachView()
}
.immersionStyle(selection: $immersionStyle, in: .progressive)
.upperLimbVisibility(.hidden)

// Guided Workout - Mixed immersion
ImmersiveSpace(id: "guidedWorkout") {
    GuidedWorkoutView()
}
.immersionStyle(selection: $immersionStyle, in: .mixed)
.upperLimbVisibility(.visible)
```

**Immersion Levels**:
- **Progressive**: Blend environment with passthrough (adjustable)
- **Full**: Complete immersion, no passthrough
- **Mixed**: Digital content overlays real world

**Immersive Space Guidelines**:
- Minimum 90 FPS for comfort
- Smooth transitions (0.5-1.0s fade)
- Exit affordance always visible
- Comfort mode for motion sensitivity
- Spatial audio for environmental sound

### 2.4 Scene Transition Management

```swift
@Observable
class SceneNavigationManager {
    enum Scene {
        case dashboard
        case volume(VolumeType)
        case immersive(ImmersiveType)
    }

    var currentScene: Scene = .dashboard
    var immersionLevel: ImmersionStyle = .progressive

    func navigate(to scene: Scene) async {
        // Fade out current scene
        await fadeOut(duration: 0.3)

        // Transition
        currentScene = scene

        // Fade in new scene
        await fadeIn(duration: 0.3)
    }

    func enterImmersiveSpace(_ type: ImmersiveType) async throws {
        guard let window = await openWindow(id: type.rawValue) else {
            throw NavigationError.cannotOpenWindow
        }

        currentScene = .immersive(type)
    }

    func exitImmersiveSpace() async {
        await dismissWindow()
        currentScene = .dashboard
    }
}
```

---

## 3. Gesture and Interaction Specifications

### 3.1 Standard visionOS Gestures

```swift
// Tap gesture - Primary selection
.onTapGesture {
    selectHealthMetric()
}

// Long press - Contextual menu
.onLongPressGesture(minimumDuration: 0.5) {
    showContextMenu()
}

// Drag gesture - Reposition elements
.gesture(
    DragGesture()
        .onChanged { value in
            updatePosition(value.translation)
        }
        .onEnded { value in
            finalizePosition(value.translation)
        }
)

// Magnification - Scale 3D objects
.gesture(
    MagnifyGesture()
        .onChanged { value in
            scale = value.magnification
        }
)

// Rotation - Rotate volumes
.gesture(
    RotateGesture3D()
        .onChanged { value in
            rotation = value.rotation
        }
)
```

### 3.2 Custom Health Gestures

```swift
enum HealthGesture {
    case checkVitals          // Palm scan gesture
    case startActivity        // Ready position (hands at sides)
    case joinChallenge        // Step forward gesture
    case celebrate            // Victory pose (arms up)
    case requestHelp          // Hand raise
    case meditate             // Calm hands (palms up, relaxed)
    case breathe              // Chest expansion tracking
}

struct GestureRecognizer {
    func recognize(from handAnchors: [HandAnchor]) -> HealthGesture? {
        // Analyze hand positions
        guard let leftHand = handAnchors.first(where: { $0.chirality == .left }),
              let rightHand = handAnchors.first(where: { $0.chirality == .right }) else {
            return nil
        }

        // Check for palm scan
        if isPalmScanGesture(leftHand, rightHand) {
            return .checkVitals
        }

        // Check for meditation pose
        if isMeditationPose(leftHand, rightHand) {
            return .meditate
        }

        // More gesture recognition...
        return nil
    }

    private func isPalmScanGesture(_ left: HandAnchor, _ right: HandAnchor) -> Bool {
        // Hand palm facing towards user
        // Fingers extended
        // Held steady for 1 second
        return false // Implementation
    }
}
```

### 3.3 Gaze Interaction

```swift
struct BiometricCard: View {
    @State private var isHovered = false

    var body: some View {
        VStack {
            // Card content
        }
        .hoverEffect(.highlight) // Built-in hover effect
        .onContinuousHover { phase in
            switch phase {
            case .active(_):
                isHovered = true
                highlightCard()
            case .ended:
                isHovered = false
                unhighlightCard()
            }
        }
    }
}
```

### 3.4 Interaction Specifications

| Interaction | Method | Feedback | Use Case |
|-------------|--------|----------|----------|
| **Select Item** | Gaze + Pinch | Visual highlight + haptic | Navigate, choose options |
| **Drag Object** | Pinch + Move | Visual follow + haptic | Reposition windows/volumes |
| **Scale Volume** | Two-hand pinch | Scale preview | Resize visualizations |
| **Rotate Volume** | Two-hand twist | Rotation preview | View from different angles |
| **Scroll Content** | Vertical pinch-drag | Momentum scroll | Browse lists |
| **Pull to Refresh** | Downward drag | Progress indicator | Update data |
| **Dismiss** | Swipe away | Fade animation | Close notifications |
| **Long Press** | Gaze + Hold pinch | Context menu | Additional options |

**Interaction Guidelines**:
- Minimum hit target: 60pt × 60pt
- Hover effect radius: 80pt
- Feedback latency: <50ms
- Gesture recognition: <100ms
- Animation duration: 0.3-0.5s

---

## 4. Hand Tracking Implementation

### 4.1 Hand Tracking Setup

```swift
import ARKit

class HandTrackingManager: ObservableObject {
    private let session = ARKitSession()
    private let handTracking = HandTrackingProvider()

    @Published var leftHandAnchor: HandAnchor?
    @Published var rightHandAnchor: HandAnchor?

    func start() async throws {
        // Check support
        guard HandTrackingProvider.isSupported else {
            throw TrackingError.handTrackingNotSupported
        }

        // Run session
        try await session.run([handTracking])

        // Monitor updates
        Task {
            for await update in handTracking.anchorUpdates {
                handleHandUpdate(update)
            }
        }
    }

    private func handleHandUpdate(_ update: AnchorUpdate<HandAnchor>) {
        switch update.event {
        case .added, .updated:
            if update.anchor.chirality == .left {
                leftHandAnchor = update.anchor
            } else {
                rightHandAnchor = update.anchor
            }
        case .removed:
            if update.anchor.chirality == .left {
                leftHandAnchor = nil
            } else {
                rightHandAnchor = nil
            }
        }
    }

    func stop() {
        session.stop()
    }
}
```

### 4.2 Exercise Form Tracking

```swift
class ExerciseFormTracker {
    private let handTracking: HandTrackingManager

    func trackPushUpForm() async -> FormFeedback {
        guard let leftHand = handTracking.leftHandAnchor,
              let rightHand = handTracking.rightHandAnchor else {
            return .noHandsDetected
        }

        // Extract joint positions
        let leftWrist = leftHand.handSkeleton?.joint(.wrist)
        let rightWrist = rightHand.handSkeleton?.joint(.wrist)
        let leftShoulder = estimateShoulderPosition(from: leftWrist)
        let rightShoulder = estimateShoulderPosition(from: rightWrist)

        // Analyze form
        let alignment = checkBodyAlignment(leftWrist, rightWrist, leftShoulder, rightShoulder)
        let handPlacement = checkHandPlacement(leftHand, rightHand)
        let depth = checkPushUpDepth(leftWrist, rightWrist)

        return FormFeedback(
            alignment: alignment,
            handPlacement: handPlacement,
            depth: depth,
            score: calculateFormScore(alignment, handPlacement, depth)
        )
    }

    func trackYogaPose(_ pose: YogaPose) async -> PoseAccuracy {
        // Compare hand positions to ideal pose
        // Calculate accuracy percentage
        // Provide corrective feedback
        return PoseAccuracy(accuracy: 0.85, feedback: "Extend left arm higher")
    }
}

struct FormFeedback {
    var alignment: AlignmentQuality
    var handPlacement: PlacementQuality
    var depth: DepthQuality
    var score: Double // 0.0 - 1.0
}

enum AlignmentQuality {
    case excellent, good, needsImprovement, poor
}
```

### 4.3 Hand Skeleton Joints

```swift
enum HandJoint {
    // Wrist
    case wrist

    // Thumb
    case thumbTip, thumbDistal, thumbProximal, thumbMetacarpal

    // Index finger
    case indexFingerTip, indexFingerDistal, indexFingerIntermediate,
         indexFingerProximal, indexFingerMetacarpal

    // Middle finger
    case middleFingerTip, middleFingerDistal, middleFingerIntermediate,
         middleFingerProximal, middleFingerMetacarpal

    // Ring finger
    case ringFingerTip, ringFingerDistal, ringFingerIntermediate,
         ringFingerProximal, ringFingerMetacarpal

    // Little finger
    case littleFingerTip, littleFingerDistal, littleFingerIntermediate,
         littleFingerProximal, littleFingerMetacarpal
}

extension HandAnchor {
    func position(of joint: HandJoint) -> SIMD3<Float>? {
        return handSkeleton?.joint(joint.skeletonJoint)?.anchorFromJointTransform.columns.3.xyz
    }

    func rotation(of joint: HandJoint) -> simd_quatf? {
        guard let transform = handSkeleton?.joint(joint.skeletonJoint)?.anchorFromJointTransform else {
            return nil
        }
        return simd_quatf(transform)
    }
}
```

---

## 5. Eye Tracking Implementation

### 5.1 Eye Tracking (Privacy-Considerate)

**Note**: visionOS eye tracking is privacy-focused. Apps don't get raw eye gaze data. Instead, the system handles gaze input for selection.

```swift
// Eye tracking is implicit in hover effects
struct HealthCard: View {
    @State private var isLookedAt = false

    var body: some View {
        VStack {
            // Content
        }
        .hoverEffect(.highlight)
        .onContinuousHover { phase in
            switch phase {
            case .active(_):
                // User is looking at this card
                isLookedAt = true
                provideSubtleFeedback()
            case .ended:
                isLookedAt = false
            }
        }
    }
}

// For accessibility: Dwell control
struct DwellControlButton: View {
    @State private var dwellProgress: Double = 0.0
    @State private var dwellTimer: Timer?

    var body: some View {
        Button("Start Activity") {
            startActivity()
        }
        .onContinuousHover { phase in
            switch phase {
            case .active(_):
                startDwellTimer()
            case .ended:
                cancelDwellTimer()
            }
        }
        .overlay(
            Circle()
                .trim(from: 0, to: dwellProgress)
                .stroke(Color.blue, lineWidth: 3)
        )
    }

    private func startDwellTimer() {
        dwellTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            dwellProgress += 0.05 / 2.0 // 2 second dwell
            if dwellProgress >= 1.0 {
                startActivity()
                cancelDwellTimer()
            }
        }
    }
}
```

### 5.2 Attention-Based Features

```swift
class AttentionManager: ObservableObject {
    @Published var isUserAttentive = true

    // Monitor user attention for safety during exercise
    func startMonitoring() {
        // System provides attention state
        // Use for:
        // - Pausing video if user looks away
        // - Showing hints when user focuses on element
        // - Safety checks during exercise
    }

    func pauseWorkoutIfNotAttentive() {
        if !isUserAttentive {
            // User looked away during workout
            // Pause for safety
        }
    }
}
```

---

## 6. Spatial Audio Specifications

### 6.1 Spatial Audio Setup

```swift
import AVFAudio
import CoreAudio

class SpatialAudioManager {
    private let audioEngine = AVAudioEngine()
    private let environment = AVAudioEnvironmentNode()

    func setupSpatialAudio() {
        audioEngine.attach(environment)

        // Configure environmental audio
        environment.listenerPosition = AVAudio3DPoint(x: 0, y: 0, z: 0)
        environment.listenerAngularOrientation = AVAudio3DAngularOrientation(
            yaw: 0, pitch: 0, roll: 0
        )

        // Reverb for immersive spaces
        environment.reverbParameters.enable = true
        environment.reverbParameters.level = 0.3

        audioEngine.connect(environment, to: audioEngine.mainMixerNode, format: nil)

        do {
            try audioEngine.start()
        } catch {
            print("Audio engine failed to start: \(error)")
        }
    }

    func play3DAudio(
        _ audioFile: AVAudioFile,
        at position: SIMD3<Float>,
        volume: Float = 1.0
    ) {
        let playerNode = AVAudioPlayerNode()
        audioEngine.attach(playerNode)

        // 3D positioning
        playerNode.position = AVAudio3DPoint(
            x: position.x,
            y: position.y,
            z: position.z
        )

        playerNode.volume = volume

        audioEngine.connect(playerNode, to: environment, format: audioFile.processingFormat)
        playerNode.scheduleFile(audioFile, at: nil)
        playerNode.play()
    }
}
```

### 6.2 Audio Environments

```swift
enum AudioEnvironment {
    case meditationTemple    // Calm, reverberant
    case virtualGym          // Energetic, motivational
    case nature              // Outdoor ambience
    case underwater          // Muffled, serene
    case space               // Vast, ethereal

    var reverbPreset: AVAudioUnitReverbPreset {
        switch self {
        case .meditationTemple:
            return .cathedral
        case .virtualGym:
            return .mediumRoom
        case .nature:
            return .largeHall
        case .underwater:
            return .smallRoom
        case .space:
            return .largeChamber
        }
    }

    var ambientSoundTrack: String {
        switch self {
        case .meditationTemple:
            return "temple_ambience.m4a"
        case .virtualGym:
            return "gym_energy.m4a"
        case .nature:
            return "forest_sounds.m4a"
        case .underwater:
            return "ocean_depths.m4a"
        case .space:
            return "cosmic_hum.m4a"
        }
    }
}
```

### 6.3 Voice Guidance

```swift
import AVFoundation

class VoiceGuidanceManager {
    private let synthesizer = AVSpeechSynthesizer()

    func provideGuidance(_ text: String, at position: SIMD3<Float>? = nil) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.5 // Slower for comprehension
        utterance.volume = 0.8

        if let position = position {
            // Spatial voice guidance (if supported in future)
            // utterance.spatialPosition = position
        }

        synthesizer.speak(utterance)
    }

    func provideWorkoutCue(_ cue: WorkoutCue) {
        let text = cue.instruction
        provideGuidance(text)

        // Haptic feedback
        if cue.requiresHaptic {
            playHaptic()
        }
    }
}

struct WorkoutCue {
    var instruction: String
    var timing: TimeInterval
    var requiresHaptic: Bool
}
```

---

## 7. Accessibility Requirements

### 7.1 VoiceOver Support

```swift
// All interactive elements must have accessibility labels
Button("Start Meditation") {
    startMeditation()
}
.accessibilityLabel("Start meditation session")
.accessibilityHint("Begins a 10-minute guided meditation")

// Custom accessibility for 3D visualizations
RealityView { content in
    let healthLandscape = createHealthLandscape()
    content.add(healthLandscape)
}
.accessibilityLabel("Your health landscape")
.accessibilityValue("Overall health score: 85 out of 100")
.accessibilityHint("Tap to explore detailed metrics")
.accessibilityActions {
    Button("View heart health") {
        focusOnHeartHealth()
    }
    Button("View activity levels") {
        focusOnActivity()
    }
}

// Dynamic descriptions for data
Text("Heart Rate: \(heartRate) BPM")
    .accessibilityLabel("Heart rate")
    .accessibilityValue("\(heartRate) beats per minute")
    .accessibilityAddTraits(.updatesFrequently)
```

### 7.2 Dynamic Type

```swift
// Support all text sizes
Text("Daily Step Goal")
    .font(.headline)
    .dynamicTypeSize(.xSmall ... .xxxLarge)

// Layout adapts to text size
VStack(spacing: 8) {
    Text("10,000 steps")
        .font(.title)
    Text("Target")
        .font(.caption)
}
.dynamicTypeSize(.xSmall ... .xxxLarge)

// Custom scaling for fixed-size elements
.scaleEffect(sizeCategory.scaleFactor)

extension DynamicTypeSize {
    var scaleFactor: CGFloat {
        switch self {
        case .xSmall: return 0.8
        case .small: return 0.9
        case .medium: return 1.0
        case .large: return 1.1
        case .xLarge: return 1.2
        case .xxLarge: return 1.3
        case .xxxLarge: return 1.4
        @unknown default: return 1.0
        }
    }
}
```

### 7.3 Alternative Interaction Methods

```swift
// Dwell control for those who can't pinch
struct DwellControl: View {
    let action: () -> Void
    @State private var progress: Double = 0

    var body: some View {
        Button("Action") {
            action()
        }
        .onContinuousHover { phase in
            switch phase {
            case .active(_):
                startDwell()
            case .ended:
                cancelDwell()
            }
        }
    }
}

// Voice control support
.accessibilityInputLabels(["start workout", "begin exercise", "go"])

// Switch control support
.accessibilityAddTraits(.isButton)
.accessibilityAction(.default) {
    performAction()
}
```

### 7.4 Reduce Motion

```swift
@Environment(\.accessibilityReduceMotion) var reduceMotion

var body: some View {
    HealthCard()
        .animation(reduceMotion ? .none : .spring, value: isExpanded)

    // Alternative to animated transitions
    if reduceMotion {
        ImmediateTransition()
    } else {
        AnimatedTransition()
    }
}

// Disable auto-rotating 3D content
func updateRotation() {
    if !reduceMotion {
        rotationAngle += 0.01
    }
}
```

### 7.5 High Contrast

```swift
@Environment(\.colorSchemeContrast) var contrast

var cardBackground: Color {
    switch contrast {
    case .standard:
        return Color(.systemBackground).opacity(0.8)
    case .increased:
        return Color(.systemBackground)
    @unknown default:
        return Color(.systemBackground).opacity(0.8)
    }
}

var textColor: Color {
    contrast == .increased ? .primary : .secondary
}
```

### 7.6 Accessibility Checklist

- [ ] All interactive elements have labels
- [ ] All images have descriptions
- [ ] Sufficient color contrast (4.5:1 minimum)
- [ ] No information conveyed by color alone
- [ ] Support Dynamic Type
- [ ] Provide alternatives to time-based interactions
- [ ] Support VoiceOver gestures
- [ ] Test with VoiceOver enabled
- [ ] Support dwell control
- [ ] Support switch control
- [ ] Respect reduce motion preference
- [ ] Respect reduce transparency
- [ ] Support high contrast mode
- [ ] Keyboard navigation (if applicable)
- [ ] Screen curtain compatible

---

## 8. Privacy and Security Requirements

### 8.1 Data Privacy

```swift
// Privacy-first data handling
class PrivacyManager {
    // User consent management
    func requestConsent(for dataType: HealthDataType) async -> Bool {
        // Present clear explanation
        // Get explicit consent
        // Store consent record
        return await presentConsentDialog(for: dataType)
    }

    // Data minimization
    func collectMinimalData() {
        // Only collect necessary data
        // Avoid collecting identifiable information when possible
    }

    // Anonymization for analytics
    func anonymize(_ data: BiometricReading) -> AnonymizedData {
        return AnonymizedData(
            type: data.type,
            value: data.value,
            timestamp: roundToHour(data.timestamp),
            userId: hashUserId(data.userId) // One-way hash
        )
    }

    // Right to deletion
    func deleteAllUserData(for userId: UUID) async throws {
        // Delete from local database
        // Request deletion from backend
        // Clear caches
        // Notify user of completion
    }

    // Data export (GDPR)
    func exportUserData(for userId: UUID) async throws -> URL {
        // Compile all user data
        // Format as JSON
        // Return downloadable file
        return URL(fileURLWithPath: "")
    }
}
```

### 8.2 Encryption

```swift
import CryptoKit

class EncryptionService {
    // Symmetric encryption for data at rest
    func encrypt(_ data: Data, with key: SymmetricKey) throws -> Data {
        let sealedBox = try AES.GCM.seal(data, using: key)
        return sealedBox.combined!
    }

    func decrypt(_ encryptedData: Data, with key: SymmetricKey) throws -> Data {
        let sealedBox = try AES.GCM.SealedBox(combined: encryptedData)
        return try AES.GCM.open(sealedBox, using: key)
    }

    // Generate secure key
    func generateKey() -> SymmetricKey {
        return SymmetricKey(size: .bits256)
    }

    // Key derivation from password
    func deriveKey(from password: String, salt: Data) throws -> SymmetricKey {
        let passwordData = Data(password.utf8)
        let hash = SHA256.hash(data: passwordData + salt)
        return SymmetricKey(data: hash)
    }
}

// Secure key storage
class KeychainManager {
    func storeKey(_ key: SymmetricKey, for identifier: String) throws {
        let keyData = key.withUnsafeBytes { Data($0) }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: identifier,
            kSecValueData as String: keyData,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]

        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeychainError.unableToStore
        }
    }

    func retrieveKey(for identifier: String) throws -> SymmetricKey {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: identifier,
            kSecReturnData as String: true
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess,
              let keyData = result as? Data else {
            throw KeychainError.keyNotFound
        }

        return SymmetricKey(data: keyData)
    }
}
```

### 8.3 Network Security

```swift
class SecureNetworkClient {
    private let session: URLSession

    init() {
        let configuration = URLSessionConfiguration.default

        // Certificate pinning
        configuration.urlCache = nil
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData

        // TLS 1.3 minimum
        configuration.tlsMinimumSupportedProtocolVersion = .TLSv13

        self.session = URLSession(
            configuration: configuration,
            delegate: SecurityDelegate(),
            delegateQueue: nil
        )
    }

    func secureRequest(to url: URL) async throws -> Data {
        var request = URLRequest(url: url)

        // Add security headers
        request.setValue("Bearer \(try await getToken())", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Request integrity
        let timestamp = ISO8601DateFormatter().string(from: Date())
        request.setValue(timestamp, forHTTPHeaderField: "X-Request-Timestamp")

        let (data, response) = try await session.data(for: request)

        // Validate response
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.invalidResponse
        }

        return data
    }
}

class SecurityDelegate: NSObject, URLSessionDelegate {
    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        // Certificate pinning validation
        guard let serverTrust = challenge.protectionSpace.serverTrust else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }

        // Validate certificate
        let credential = URLCredential(trust: serverTrust)
        completionHandler(.useCredential, credential)
    }
}
```

### 8.4 HIPAA Compliance

```yaml
HIPAA Requirements:
  Encryption:
    - At rest: AES-256
    - In transit: TLS 1.3
    - Key management: Secure enclave / Keychain

  Access Control:
    - Authentication: Multi-factor
    - Authorization: Role-based
    - Audit logs: All data access logged

  Data Integrity:
    - Checksums: SHA-256
    - Version control: All modifications tracked
    - Backup: Encrypted backups

  Privacy:
    - Minimum necessary: Only required data
    - De-identification: When possible
    - User rights: Access, amendment, accounting

  Breach Notification:
    - Detection: Real-time monitoring
    - Response: Incident response plan
    - Notification: Within 60 days

  Business Associate Agreements:
    - All third-party integrations
    - Cloud service providers
    - Analytics vendors
```

---

## 9. Data Persistence Strategy

### 9.1 SwiftData Schema

```swift
import SwiftData

@Model
final class UserProfile {
    @Attribute(.unique) var id: UUID
    var firstName: String
    var lastName: String
    var email: String
    var dateOfBirth: Date

    @Relationship(deleteRule: .cascade)
    var biometrics: [BiometricReading]?

    @Relationship(deleteRule: .cascade)
    var activities: [Activity]?

    @Relationship(deleteRule: .cascade)
    var goals: [HealthGoal]?

    init(id: UUID, firstName: String, lastName: String) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        // ...
    }
}

// SwiftData configuration
let container = try ModelContainer(
    for: UserProfile.self, BiometricReading.self, Activity.self,
    configurations: ModelConfiguration(
        url: URL.documentsDirectory.appending(path: "wellness.db"),
        allowsSave: true,
        cloudKitDatabase: .none // Privacy: no cloud sync by default
    )
)
```

### 9.2 Caching Strategy

```swift
actor CacheManager {
    private var cache: [String: (data: Any, expiry: Date)] = [:]

    func get<T>(_ key: String) -> T? {
        guard let entry = cache[key],
              entry.expiry > Date() else {
            return nil
        }
        return entry.data as? T
    }

    func set<T>(_ key: String, value: T, duration: TimeInterval = 300) {
        let expiry = Date().addingTimeInterval(duration)
        cache[key] = (value, expiry)
    }

    func clear() {
        cache.removeAll()
    }

    func removeExpired() {
        let now = Date()
        cache = cache.filter { $0.value.expiry > now }
    }
}
```

### 9.3 Offline Support

```swift
class OfflineManager {
    private let syncQueue = DispatchQueue(label: "com.wellness.sync")
    private var pendingOperations: [SyncOperation] = []

    func queueOperation(_ operation: SyncOperation) {
        syncQueue.async {
            self.pendingOperations.append(operation)
            self.savePendingOperations()
        }
    }

    func syncWhenOnline() async {
        guard await NetworkMonitor.shared.isConnected else {
            return
        }

        for operation in pendingOperations {
            do {
                try await execute(operation)
                remove(operation)
            } catch {
                // Retry later
            }
        }
    }

    private func execute(_ operation: SyncOperation) async throws {
        switch operation.type {
        case .createActivity:
            try await apiClient.post("/activities", body: operation.data)
        case .updateBiometric:
            try await apiClient.put("/biometrics/\(operation.id)", body: operation.data)
        // ...
        }
    }
}

struct SyncOperation: Codable {
    var id: UUID
    var type: OperationType
    var data: Data
    var timestamp: Date
}
```

---

## 10. Testing Requirements

### 10.1 Unit Testing

```swift
import XCTest
@testable import SpatialWellness

final class HealthServiceTests: XCTestCase {
    var sut: HealthService!
    var mockDataController: MockDataController!

    override func setUp() async throws {
        mockDataController = MockDataController()
        sut = HealthService(dataController: mockDataController)
    }

    func testFetchBiometricsReturnsCorrectData() async throws {
        // Given
        let userId = UUID()
        let expectedReadings = [
            BiometricReading(type: .heartRate, value: 72, unit: "bpm")
        ]
        mockDataController.biometrics = expectedReadings

        // When
        let result = try await sut.fetchBiometrics(for: userId, dateRange: DateInterval())

        // Then
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.type, .heartRate)
        XCTAssertEqual(result.first?.value, 72)
    }

    func testHealthKitSyncHandlesPermissionDenial() async throws {
        // Given
        mockDataController.shouldDenyPermission = true

        // When/Then
        await XCTAssertThrowsError(try await sut.syncWithHealthKit()) { error in
            XCTAssertEqual(error as? HealthError, .permissionDenied)
        }
    }
}
```

### 10.2 UI Testing

```swift
import XCTest

final class DashboardUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUp() {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["testing"]
        app.launch()
    }

    func testDashboardDisplaysHealthMetrics() {
        // Given
        let dashboard = app.windows["dashboard"]

        // Then
        XCTAssertTrue(dashboard.staticTexts["Heart Rate"].exists)
        XCTAssertTrue(dashboard.staticTexts["Steps Today"].exists)
        XCTAssertTrue(dashboard.staticTexts["Sleep Quality"].exists)
    }

    func testStartMeditationOpensImmersiveSpace() {
        // When
        app.buttons["Start Meditation"].tap()

        // Then
        let meditationSpace = app.windows["meditation"]
        XCTAssertTrue(meditationSpace.waitForExistence(timeout: 5))
    }
}
```

### 10.3 Performance Testing

```swift
func testHealthLandscapeRenderingPerformance() {
    measure(metrics: [XCTClockMetric(), XCTMemoryMetric()]) {
        let landscape = HealthLandscapeGenerator.generate(dataPoints: 10000)
        // Render landscape
    }
}

func testBiometricQueryPerformance() {
    let context = DataController.shared.context

    measure {
        let _ = try? context.fetch(FetchDescriptor<BiometricReading>())
    }

    // Assert: Query completes in < 100ms
}
```

### 10.4 Accessibility Testing

```swift
func testVoiceOverLabelsAreDescriptive() {
    app.buttons["Start Workout"].tap()

    let workoutCard = app.otherElements["workout-card"]
    XCTAssertTrue(workoutCard.exists)

    let label = workoutCard.label
    XCTAssertFalse(label.isEmpty)
    XCTAssertNotEqual(label, "Button") // Avoid generic labels
}
```

### 10.5 Integration Testing

```swift
final class APIIntegrationTests: XCTestCase {
    func testBiometricSyncE2E() async throws {
        // 1. Create local biometric
        let reading = BiometricReading(type: .heartRate, value: 75, unit: "bpm")
        try await DataController.shared.context.insert(reading)

        // 2. Sync to backend
        try await HealthService.shared.syncWithBackend()

        // 3. Verify on backend
        let synced: [BiometricReading] = try await APIClient.shared.get("/biometrics")
        XCTAssertTrue(synced.contains(where: { $0.id == reading.id }))
    }
}
```

### 10.6 Test Coverage Goals

- **Unit Test Coverage**: 80% minimum
- **UI Test Coverage**: Critical user flows
- **Performance Tests**: All render-intensive operations
- **Accessibility Tests**: All interactive elements
- **Integration Tests**: All external API calls

---

## 11. Performance Benchmarks

```yaml
Performance Targets:
  Frame Rate:
    Target: 90 FPS
    Minimum: 60 FPS
    Measurement: Instruments (Time Profiler)

  Render Time:
    Target: < 11ms per frame
    Measurement: RealityKit Debugger

  Memory:
    Typical Session: < 500 MB
    Peak: < 1 GB
    Measurement: Instruments (Allocations)

  CPU:
    Average: < 40%
    Peak: < 70%
    Measurement: Instruments (CPU Profiler)

  GPU:
    Average: < 60%
    Peak: < 85%
    Measurement: Instruments (GPU Profiler)

  Battery:
    Drain Rate: < 15% per hour
    Measurement: Xcode Energy Log

  Network:
    API Response: < 200ms (p95)
    Asset Download: < 5s for 3D scenes
    Measurement: Network Link Conditioner

  App Launch:
    Cold Start: < 2s
    Warm Start: < 1s
    Measurement: Xcode Organizer
```

---

## 12. Development Workflow

### 12.1 Git Workflow

```bash
# Feature branch workflow
git checkout -b feature/meditation-space
git commit -m "feat: add meditation environment"
git push origin feature/meditation-space

# Commit message convention
# feat: New feature
# fix: Bug fix
# docs: Documentation
# style: Formatting
# refactor: Code restructuring
# test: Testing
# chore: Maintenance
```

### 12.2 Code Review Checklist

- [ ] Code follows Swift style guidelines
- [ ] All new code has unit tests
- [ ] Performance tested (90 FPS maintained)
- [ ] Accessibility labels added
- [ ] Privacy considerations addressed
- [ ] Security review completed
- [ ] Documentation updated
- [ ] No compiler warnings
- [ ] Builds successfully on simulator and device
- [ ] Tested with VoiceOver enabled

### 12.3 CI/CD Pipeline

```yaml
# GitHub Actions / Xcode Cloud
name: CI

on: [push, pull_request]

jobs:
  test:
    runs-on: macos-14
    steps:
      - uses: actions/checkout@v3
      - name: Run Tests
        run: xcodebuild test -scheme SpatialWellness -destination 'platform=visionOS Simulator,name=Apple Vision Pro'

  lint:
    runs-on: macos-14
    steps:
      - uses: actions/checkout@v3
      - name: SwiftLint
        run: swiftlint lint --strict

  build:
    runs-on: macos-14
    steps:
      - uses: actions/checkout@v3
      - name: Build
        run: xcodebuild build -scheme SpatialWellness -destination 'platform=visionOS Simulator,name=Apple Vision Pro'
```

---

## Summary

This technical specification provides:

1. **Complete Technology Stack**: Swift 6.0, SwiftUI, RealityKit, ARKit, visionOS 2.0+
2. **Presentation Modes**: Windows, volumes, immersive spaces
3. **Interaction Methods**: Gestures, hand tracking, gaze input
4. **Accessibility**: VoiceOver, Dynamic Type, alternative controls
5. **Security**: Encryption, HIPAA compliance, privacy-first
6. **Performance**: 90 FPS targets, optimization strategies
7. **Testing**: Unit, UI, performance, accessibility
8. **Development Workflow**: Git, CI/CD, code review

This spec ensures a robust, accessible, performant, and secure visionOS wellness application.
