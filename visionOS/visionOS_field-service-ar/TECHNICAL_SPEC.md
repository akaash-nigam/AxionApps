# Field Service AR Assistant - Technical Specifications

## 1. Technology Stack

### 1.1 Core Technologies

| Component | Technology | Version | Purpose |
|-----------|-----------|---------|---------|
| Programming Language | Swift | 6.0+ | Primary development language with strict concurrency |
| UI Framework | SwiftUI | visionOS 2.0+ | Declarative UI for windows and spatial interfaces |
| 3D Rendering | RealityKit 4 | visionOS 2.0+ | 3D content, entities, and spatial computing |
| AR Framework | ARKit 6 | visionOS 2.0+ | Spatial tracking, hand/eye tracking, image recognition |
| Data Persistence | SwiftData | Latest | Modern data persistence with @Model |
| Networking | URLSession + Async/Await | iOS 16+ | HTTP API communication |
| Real-Time Comm | WebRTC | Latest | Peer-to-peer video/audio/data channels |
| AI/ML | Core ML 7 | visionOS 2.0+ | On-device machine learning |
| Vision | Vision Framework | visionOS 2.0+ | Image analysis and recognition |
| Speech | Speech Framework | visionOS 2.0+ | Voice commands and dictation |
| Audio | AVFoundation + Spatial Audio | visionOS 2.0+ | 3D audio rendering |

### 1.2 Development Environment

- **IDE**: Xcode 16.0 or later
- **Simulator**: visionOS Simulator (for basic testing)
- **Device**: Apple Vision Pro (required for full testing)
- **macOS**: Sequoia 15.0 or later
- **Reality Composer Pro**: For 3D asset creation
- **Instruments**: For performance profiling
- **TestFlight**: For beta distribution

### 1.3 Third-Party Dependencies

```swift
// Package.swift
dependencies: [
    // WebRTC for real-time collaboration
    .package(url: "https://github.com/webrtc-sdk/Specs", from: "1.1.0"),

    // MQTT for IoT sensor integration
    .package(url: "https://github.com/emqx/CocoaMQTT", from: "2.1.0"),

    // Image processing utilities
    .package(url: "https://github.com/onevcat/Kingfisher", from: "7.10.0"),
]
```

### 1.4 Minimum Requirements

- **Device**: Apple Vision Pro
- **OS**: visionOS 2.0 or later
- **Storage**: 500 MB installation + 10 GB for offline data
- **Memory**: 4 GB recommended
- **Network**: Optional (offline mode supported)
- **Permissions**:
  - Camera access (for AR)
  - Hand tracking
  - World sensing
  - Network access
  - Local network (for IoT)

## 2. visionOS Presentation Modes

### 2.1 WindowGroup (2D Floating Windows)

#### Dashboard Window
```swift
WindowGroup(id: "dashboard") {
    DashboardView()
        .environment(\.appState, appState)
}
.windowStyle(.plain)
.defaultSize(width: 800, height: 600)
.windowResizability(.contentSize)
```

**Specifications:**
- Default size: 800×600 points
- Minimum size: 600×400 points
- Maximum size: 1200×900 points
- Resizable: Yes
- Multiple instances: No
- Background: Glass material with vibrancy
- Position: User-adjustable
- Depth: Floating 10-15° below eye level

**Use Cases:**
- Job list and scheduling
- Equipment library browser
- Performance analytics dashboard
- Settings and preferences
- Documentation viewer

#### Job Details Window
```swift
WindowGroup(id: "job-details", for: UUID.self) { $jobId in
    JobDetailsView(jobId: jobId)
}
.defaultSize(width: 1000, height: 700)
```

**Specifications:**
- Default size: 1000×700 points
- Supports deep linking by job ID
- Multiple instances: Yes (one per job)
- Contains:
  - Job metadata
  - Equipment information
  - Procedure checklist
  - Required parts list
  - Start AR button

### 2.2 Volumetric Windows (3D Bounded Content)

#### Equipment Preview Volume
```swift
WindowGroup(id: "equipment-3d", for: UUID.self) { $equipmentId in
    Equipment3DView(equipmentId: equipmentId)
}
.windowStyle(.volumetric)
.defaultSize(width: 0.6, height: 0.6, depth: 0.6, in: .meters)
```

**Specifications:**
- Physical dimensions: 60cm × 60cm × 60cm
- Content: RealityKit scene with 3D equipment model
- Interaction: Rotation, scaling, component selection
- Lighting: Environment-aware
- Shadows: Real-time shadow casting
- LOD: 3 levels based on viewing distance

**Features:**
- 360° equipment inspection
- Component highlighting
- Exploded view mode
- Part identification
- Measurement tools

### 2.3 ImmersiveSpace (Full Space AR/VR)

#### AR Repair Guidance
```swift
ImmersiveSpace(id: "ar-repair") {
    ARRepairView()
        .environment(\.repairViewModel, repairViewModel)
}
.immersionStyle(selection: .constant(.mixed), in: .mixed)
```

**Specifications:**
- Immersion style: Mixed (AR passthrough)
- Hand tracking: Enabled
- Eye tracking: Enabled for targeting
- Plane detection: Horizontal and vertical
- Image tracking: Equipment recognition
- Spatial anchors: Persistent per equipment
- Occlusion: ARKit scene understanding

**AR Overlay Specifications:**
- Registration accuracy: ±2mm at 1m distance
- Tracking update rate: 60 Hz minimum
- Annotation latency: <50ms
- Spatial audio: 3D positional
- Text legibility: Minimum 18pt at 0.5m

## 3. Gesture & Interaction Specifications

### 3.1 Standard visionOS Gestures

#### Look & Tap (Primary Interaction)
```swift
Button("Complete Step") {
    viewModel.completeStep()
}
.buttonStyle(.bordered)
.hoverEffect() // Adds visual feedback on gaze
```

**Behavior:**
- Gaze at interactive element
- Visual highlight appears
- Tap gesture (thumb + index finger)
- Haptic feedback on activation
- Minimum target size: 60pt × 60pt

#### Scroll & Pan
```swift
ScrollView {
    ForEach(steps) { step in
        StepCard(step: step)
    }
}
```

**Behavior:**
- Look at scrollable area
- Pinch and drag to scroll
- Momentum scrolling enabled
- Scroll indicators appear on gaze

### 3.2 Custom Spatial Gestures

#### Point & Identify
```swift
struct PointGestureView: View {
    @State private var handAnchor: HandAnchor?

    var body: some View {
        RealityView { content in
            // Setup reality content
        }
        .gesture(
            SpatialTapGesture(coordinateSpace: .immersiveSpace)
                .targetedToAnyEntity()
                .onEnded { value in
                    handlePointGesture(at: value.location3D)
                }
        )
    }

    func handlePointGesture(at location: SIMD3<Float>) {
        // Raycast to identify equipment component
        let results = arSession.raycast(from: location)
        if let hit = results.first {
            identifyComponent(at: hit.position)
        }
    }
}
```

**Specifications:**
- Detection range: 0.3m - 2.0m
- Accuracy: ±5mm
- Response time: <100ms
- Visual feedback: Highlight + label
- Audio feedback: Confirmation tone

#### Measure Gesture (Two-Hand)
```swift
func processMeasurementGesture(
    leftHand: HandAnchor,
    rightHand: HandAnchor
) {
    let leftIndex = leftHand.handSkeleton?.joint(.indexFingerTip)
    let rightIndex = rightHand.handSkeleton?.joint(.indexFingerTip)

    guard let leftPos = leftIndex?.anchorFromJointTransform.position,
          let rightPos = rightIndex?.anchorFromJointTransform.position else {
        return
    }

    let distance = simd_distance(leftPos, rightPos)
    displayMeasurement(distance)
}
```

**Specifications:**
- Minimum distance: 2cm
- Maximum distance: 2m
- Accuracy: ±2mm
- Display: Real-time measurement line
- Units: Metric and imperial toggle

#### Rotate Equipment (Circular Motion)
```swift
.gesture(
    RotateGesture3D()
        .onChanged { value in
            equipmentEntity.orientation = value.rotation
        }
)
```

**Specifications:**
- Rotation axes: X, Y, Z
- Sensitivity: Adjustable
- Constraints: Optional axis locking
- Snap angles: 15° increments (optional)

### 3.3 Voice Commands

```swift
class VoiceCommandProcessor {
    let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))

    func processCommand(_ command: String) {
        switch command.lowercased() {
        case "next step":
            viewModel.advanceToNextStep()
        case "call expert":
            viewModel.initiateExpertCall()
        case "take photo":
            viewModel.captureEvidence()
        case "mark as complete":
            viewModel.completeCurrentStep()
        case "show measurements":
            viewModel.showMeasurementMode()
        default:
            handleNaturalLanguageCommand(command)
        }
    }
}
```

**Supported Commands:**
- "Next step" / "Previous step"
- "Call expert" / "End call"
- "Take photo" / "Record video"
- "Show [component name]"
- "Mark as complete"
- "What's next?"
- "Show measurements"
- "Zoom in" / "Zoom out"

**Specifications:**
- Recognition language: 25+ languages
- Accuracy: >95% for commands
- Wake phrase: Optional "Hey Assistant"
- Continuous listening: During AR mode
- Privacy: On-device processing (when possible)

## 4. Hand Tracking Implementation

### 4.1 Hand Tracking Configuration

```swift
class HandTrackingManager {
    private let handTracking = HandTrackingProvider()

    func startTracking() async throws {
        let config = HandTrackingProvider.Configuration()
        try await handTracking.run(config)

        for await update in handTracking.anchorUpdates {
            processHandUpdate(update)
        }
    }

    func processHandUpdate(_ update: AnchorUpdate<HandAnchor>) {
        guard let handAnchor = update.anchor,
              let skeleton = handAnchor.handSkeleton else {
            return
        }

        // Process hand poses
        detectGestures(from: skeleton)

        // Track finger positions
        updateFingerTracking(skeleton)
    }
}
```

### 4.2 Hand Gesture Recognition

#### Pinch Detection
```swift
func detectPinch(from skeleton: HandSkeleton) -> Bool {
    let thumbTip = skeleton.joint(.thumbTip)
    let indexTip = skeleton.joint(.indexFingerTip)

    guard let thumbPos = thumbTip.anchorFromJointTransform.position,
          let indexPos = indexTip.anchorFromJointTransform.position else {
        return false
    }

    let distance = simd_distance(thumbPos, indexPos)
    return distance < 0.02 // 2cm threshold
}
```

#### Custom Gestures
```swift
enum CustomHandGesture {
    case point      // Index extended, others closed
    case grab       // All fingers closed
    case openPalm   // All fingers extended
    case thumbsUp   // Thumb up, others closed
    case measure    // Index and thumb extended (L-shape)
}

func recognizeGesture(from skeleton: HandSkeleton) -> CustomHandGesture? {
    let joints = skeleton.allJoints

    // Analyze finger positions and angles
    let fingerStates = analyzeFingerStates(joints)

    switch fingerStates {
    case .indexExtended where othersClosed:
        return .point
    case .allClosed:
        return .grab
    case .allExtended:
        return .openPalm
    // ... other patterns
    default:
        return nil
    }
}
```

### 4.3 Hand Tracking Specifications

- **Update Rate**: 90 Hz
- **Latency**: <11ms
- **Tracking Volume**: 40cm radius from head
- **Joints Tracked**: 27 per hand
- **Accuracy**: ±5mm positional
- **Occlusion Handling**: Predictive tracking
- **Handedness**: Both hands simultaneously

## 5. Eye Tracking Implementation

### 5.1 Eye Tracking Configuration

```swift
// Note: Eye tracking is implicit in visionOS for UI targeting
// Direct access to gaze direction requires special entitlement

struct GazeTargetView: View {
    @State private var isGazed = false

    var body: some View {
        Text("Target Component")
            .padding()
            .background(isGazed ? Color.blue.opacity(0.3) : Color.clear)
            .hoverEffect(.highlight)
            .onContinuousHover { phase in
                switch phase {
                case .active:
                    isGazed = true
                case .ended:
                    isGazed = false
                }
            }
    }
}
```

### 5.2 Gaze-Based UI Enhancements

```swift
class GazeAttentionManager {
    func trackComponentAttention(componentId: UUID, duration: TimeInterval) {
        // Track which components user looks at
        // Useful for:
        // - Highlighting relevant info
        // - Predictive UI loading
        // - Usage analytics
        // - Training insights
    }

    func predictNextAction(gazeHistory: [GazeEvent]) -> PredictedAction? {
        // Use gaze patterns to predict next interaction
        // Pre-load relevant data
        // Prepare UI transitions
    }
}
```

### 5.3 Eye Tracking Specifications

- **Sampling Rate**: 90 Hz (synchronized with display)
- **Accuracy**: ±0.5° visual angle
- **Latency**: <11ms
- **Calibration**: Automatic per user
- **Privacy**: No raw gaze data export
- **Use Cases**:
  - Hover effects
  - Attention tracking
  - Foveated rendering
  - UI prediction

## 6. Spatial Audio Specifications

### 6.1 Audio Architecture

```swift
class SpatialAudioManager {
    private let audioEngine = AVAudioEngine()
    private let environment = AVAudioEnvironmentNode()
    private let mixer = AVAudioMixerNode()

    init() {
        setupAudioEngine()
    }

    func setupAudioEngine() {
        // Attach nodes
        audioEngine.attach(environment)
        audioEngine.attach(mixer)

        // Configure spatial environment
        environment.renderingAlgorithm = .auto // visionOS optimized
        environment.distanceAttenuationParameters.distanceAttenuationModel = .inverse
        environment.distanceAttenuationParameters.maximumDistance = 10.0
        environment.distanceAttenuationParameters.referenceDistance = 1.0

        // Connect audio graph
        audioEngine.connect(mixer, to: environment, format: nil)
        audioEngine.connect(environment, to: audioEngine.mainMixerNode, format: nil)

        // Start engine
        try? audioEngine.start()
    }
}
```

### 6.2 Instruction Audio Positioning

```swift
func playStepInstruction(step: ProcedureStep, at position: SIMD3<Float>) async {
    // Generate speech from text
    let synthesizer = AVSpeechSynthesizer()
    let utterance = AVSpeechUtterance(string: step.instruction)
    utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
    utterance.rate = 0.5 // Slower for clarity

    // Create audio player
    let player = AVAudioPlayerNode()
    audioEngine.attach(player)

    // Position in 3D space
    player.position = AVAudio3DPoint(x: position.x, y: position.y, z: position.z)
    player.renderingAlgorithm = .HRTF // Head-related transfer function

    // Connect and play
    audioEngine.connect(player, to: environment, format: nil)
    player.scheduleBuffer(audioBuffer)
    player.play()
}
```

### 6.3 Collaboration Audio

```swift
func setupRemoteExpertAudio(expertPosition: SIMD3<Float>) {
    // WebRTC audio stream from remote expert
    let remoteAudioTrack = rtcPeerConnection.remoteAudioTracks.first

    // Convert to spatial audio
    let spatialPlayer = AVAudioPlayerNode()
    audioEngine.attach(spatialPlayer)

    // Position expert "in space"
    spatialPlayer.position = AVAudio3DPoint(
        x: expertPosition.x,
        y: expertPosition.y + 0.3, // Slightly elevated (head height)
        z: expertPosition.z
    )

    audioEngine.connect(spatialPlayer, to: environment, format: nil)
}
```

### 6.4 Audio Specifications

- **Codec**: AAC-LC, Opus for WebRTC
- **Sample Rate**: 48 kHz
- **Bit Depth**: 16-bit
- **Spatialization**: HRTF-based
- **Reverb**: Environment-aware
- **Max Distance**: 10 meters
- **Attenuation**: Inverse distance law
- **Voice Clarity**: Speech enhancement enabled
- **Background Noise**: Active noise cancellation

## 7. Accessibility Requirements

### 7.1 VoiceOver Support

```swift
struct AccessibleStepCard: View {
    let step: ProcedureStep

    var body: some View {
        VStack(alignment: .leading) {
            Text("Step \(step.sequenceNumber)")
                .font(.headline)
                .accessibilityAddTraits(.isHeader)

            Text(step.instruction)
                .font(.body)

            HStack {
                ForEach(step.requiredTools) { tool in
                    ToolIcon(tool: tool)
                        .accessibilityLabel(tool.name)
                }
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Required tools: \(step.requiredTools.map(\.name).joined(separator: ", "))")
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Step \(step.sequenceNumber): \(step.instruction)")
        .accessibilityAction(named: "Complete Step") {
            completeStep()
        }
    }
}
```

### 7.2 Dynamic Type Support

```swift
struct ScalableUI: View {
    @Environment(\.dynamicTypeSize) var dynamicTypeSize

    var body: some View {
        Text("Equipment: \(equipment.name)")
            .font(.title)
            .dynamicTypeSize(...DynamicTypeSize.xxxLarge) // Cap maximum size

        Text(step.instruction)
            .font(.body)
            // No cap - let it scale fully
    }
}
```

### 7.3 Alternative Interaction Methods

```swift
// Dwell-based activation (for users with limited hand mobility)
struct DwellButton: View {
    let action: () -> Void
    @State private var dwellProgress: Double = 0

    var body: some View {
        Button("Complete") { }
            .onContinuousHover { phase in
                switch phase {
                case .active:
                    startDwellTimer()
                case .ended:
                    cancelDwellTimer()
                }
            }
    }

    func startDwellTimer() {
        // Activate after 2 seconds of continuous gaze
        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { _ in
            action()
        }
    }
}
```

### 7.4 Accessibility Specifications

| Feature | Requirement | Implementation |
|---------|-------------|----------------|
| VoiceOver | Full support | All UI elements labeled |
| Dynamic Type | Up to XXXL | Text scaling supported |
| Contrast | WCAG AAA | 7:1 minimum ratio |
| Motion | Reduce motion | Respect system setting |
| Color Blind | All modes | Color + shape/icon indicators |
| Voice Control | Full navigation | Voice command system |
| Closed Captions | Collaboration audio | Real-time transcription |
| Haptic Feedback | Alternative to audio | Taptic cues available |

## 8. Privacy & Security Requirements

### 8.1 Privacy Manifest

```xml
<!-- NSPrivacyAccessedAPITypes.plist -->
<dict>
    <key>NSPrivacyAccessedAPITypes</key>
    <array>
        <dict>
            <key>NSPrivacyAccessedAPIType</key>
            <string>NSPrivacyAccessedAPICategoryWorldSensing</string>
            <key>NSPrivacyAccessedAPITypeReasons</key>
            <array>
                <string>Equipment recognition for repair guidance</string>
            </array>
        </dict>
        <dict>
            <key>NSPrivacyAccessedAPIType</key>
            <string>NSPrivacyAccessedAPICategoryHandTracking</string>
            <key>NSPrivacyAccessedAPITypeReasons</key>
            <array>
                <string>Hands-free gesture control during repairs</string>
            </array>
        </dict>
    </array>
</dict>
```

### 8.2 Data Privacy

```swift
class PrivacyManager {
    // Local processing first
    func processImageLocally(_ image: CIImage) async -> Equipment? {
        // Use Core ML for on-device recognition
        let model = try? EquipmentRecognitionModel(configuration: .init())
        let prediction = try? await model?.prediction(from: image)
        return prediction?.equipment
    }

    // Only send to server if necessary and with consent
    func processImageRemotely(_ image: CIImage) async throws -> Equipment? {
        guard await requestUserConsent() else {
            throw PrivacyError.consentDenied
        }

        // Strip EXIF data
        let cleanedImage = stripMetadata(from: image)

        // Encrypt before transmission
        let encrypted = try encrypt(cleanedImage)

        return try await apiClient.recognizeEquipment(encrypted)
    }
}
```

### 8.3 Security Specifications

| Aspect | Specification |
|--------|---------------|
| Data at Rest | AES-256 encryption |
| Data in Transit | TLS 1.3 minimum |
| Authentication | OAuth 2.0 + OIDC |
| Authorization | Role-based access control (RBAC) |
| API Security | Certificate pinning, JWT tokens |
| Local Storage | iOS Keychain for secrets |
| Biometric Auth | Face ID / Optic ID support |
| Session Timeout | 15 minutes idle |
| Audit Logging | All data access logged |
| PII Handling | Minimal collection, encrypted storage |

## 9. Data Persistence Strategy

### 9.1 SwiftData Schema

```swift
@Model
final class OfflineJob {
    @Attribute(.unique) var id: UUID
    var workOrderNumber: String
    var customerName: String
    var equipmentId: UUID
    var status: JobStatus
    var lastSyncDate: Date?
    var needsUpload: Bool

    @Relationship(deleteRule: .cascade)
    var capturedEvidence: [MediaEvidence] = []

    @Relationship(deleteRule: .cascade)
    var completedSteps: [CompletedStep] = []
}

@Model
final class CachedEquipment {
    @Attribute(.unique) var id: UUID
    var modelNumber: String
    var manufacturer: String

    @Attribute(.externalStorage)
    var modelData: Data? // 3D model

    var cachedDate: Date
    var lastAccessDate: Date
}
```

### 9.2 Sync Strategy

```swift
actor DataSyncManager {
    private let apiClient: FieldServiceAPIClient
    private let modelContext: ModelContext

    func syncAll() async throws {
        // Download new jobs
        let remoteJobs = try await apiClient.fetchJobs()
        try await mergeJobs(remoteJobs)

        // Upload completed work
        let localCompletions = try await fetchPendingUploads()
        for completion in localCompletions {
            try await apiClient.uploadJobCompletion(completion)
            completion.needsUpload = false
        }

        // Sync equipment library
        try await syncEquipmentLibrary()
    }

    func enableOfflineMode() async {
        // Pre-download required data
        let upcomingJobs = try? await fetchUpcomingJobs()
        for job in upcomingJobs ?? [] {
            // Cache equipment models
            try? await downloadEquipmentData(job.equipment)

            // Cache procedures
            try? await downloadProcedures(for: job.equipment)

            // Cache required documentation
            try? await downloadDocumentation(for: job)
        }
    }
}
```

### 9.3 Storage Specifications

| Data Type | Storage | Size Limit | Retention |
|-----------|---------|------------|-----------|
| User Profile | Keychain | 10 KB | Permanent |
| Job Data | SwiftData | 100 MB | 30 days after completion |
| Equipment Models | File System | 5 GB | LRU cache |
| Procedures | SwiftData | 500 MB | 90 days |
| Photos/Videos | File System | 10 GB | Until uploaded |
| Logs | File System | 100 MB | 7 days |
| Cached API Responses | SwiftData | 200 MB | 24 hours |

## 10. Network Architecture

### 10.1 API Communication

```swift
protocol NetworkLayer {
    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T
}

actor HTTPClient: NetworkLayer {
    private let session: URLSession
    private let baseURL: URL
    private let authProvider: AuthenticationProvider

    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        var request = URLRequest(url: baseURL.appendingPathComponent(endpoint.path))
        request.httpMethod = endpoint.method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Add auth token
        let token = try await authProvider.getToken()
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        // Add request body if needed
        if let body = endpoint.body {
            request.httpBody = try JSONEncoder().encode(body)
        }

        // Execute with retry logic
        let (data, response) = try await executeWithRetry(request)

        // Validate response
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.invalidResponse
        }

        // Decode and return
        return try JSONDecoder().decode(T.self, from: data)
    }

    private func executeWithRetry(_ request: URLRequest, attempts: Int = 3) async throws -> (Data, URLResponse) {
        for attempt in 1...attempts {
            do {
                return try await session.data(for: request)
            } catch {
                if attempt == attempts {
                    throw error
                }
                // Exponential backoff
                try await Task.sleep(nanoseconds: UInt64(pow(2.0, Double(attempt)) * 1_000_000_000))
            }
        }
        fatalError("Unreachable")
    }
}
```

### 10.2 WebRTC Architecture

```swift
class WebRTCManager: NSObject {
    private var peerConnection: RTCPeerConnection?
    private var localVideoTrack: RTCVideoTrack?
    private var localAudioTrack: RTCAudioTrack?
    private var dataChannel: RTCDataChannel?

    func setupPeerConnection() {
        let config = RTCConfiguration()
        config.iceServers = [
            RTCIceServer(urlStrings: ["stun:stun.l.google.com:19302"]),
            RTCIceServer(urlStrings: ["turn:turn.example.com:3478"],
                        username: "user",
                        credential: "pass")
        ]
        config.sdpSemantics = .unifiedPlan
        config.continualGatheringPolicy = .gatherContinually

        let constraints = RTCMediaConstraints(
            mandatoryConstraints: nil,
            optionalConstraints: ["DtlsSrtpKeyAgreement": kRTCMediaConstraintsValueTrue]
        )

        peerConnection = RTCPeerConnectionFactory.shared().peerConnection(
            with: config,
            constraints: constraints,
            delegate: self
        )
    }

    func createDataChannel(label: String) -> RTCDataChannel? {
        let config = RTCDataChannelConfiguration()
        config.isOrdered = true
        config.maxRetransmits = 3

        return peerConnection?.dataChannel(forLabel: label, configuration: config)
    }
}
```

### 10.3 Network Specifications

| Aspect | Specification |
|--------|---------------|
| Protocol | HTTPS REST + WebRTC |
| API Version | v1 (versioned in path) |
| Request Timeout | 30 seconds |
| Retry Policy | Exponential backoff, max 3 attempts |
| Rate Limiting | 100 requests/minute per user |
| Max Payload | 50 MB (for media uploads) |
| Compression | gzip for responses |
| WebRTC | STUN/TURN support |
| Video Codec | H.264, VP8 fallback |
| Audio Codec | Opus |
| Max Bitrate | 2 Mbps video, 64 kbps audio |

## 11. Testing Requirements

### 11.1 Unit Testing

```swift
import XCTest
@testable import FieldServiceAR

final class EquipmentRecognitionTests: XCTestCase {
    var recognitionService: EquipmentRecognitionService!
    var mockRepository: MockEquipmentRepository!

    override func setUp() async throws {
        mockRepository = MockEquipmentRepository()
        recognitionService = EquipmentRecognitionServiceImpl(
            repository: mockRepository
        )
    }

    func testRecognizeEquipment_ValidImage_ReturnsEquipment() async throws {
        // Given
        let testImage = ImageAnchor.mock()
        let expectedEquipment = Equipment.fixture()
        mockRepository.stubbedMatches = [
            (equipment: expectedEquipment, confidence: 0.98)
        ]

        // When
        let result = try await recognitionService.recognizeEquipment(from: testImage)

        // Then
        XCTAssertEqual(result.id, expectedEquipment.id)
        XCTAssertEqual(result.modelNumber, expectedEquipment.modelNumber)
    }

    func testRecognizeEquipment_LowConfidence_ThrowsError() async {
        // Given
        let testImage = ImageAnchor.mock()
        mockRepository.stubbedMatches = [
            (equipment: Equipment.fixture(), confidence: 0.5)
        ]

        // When/Then
        await XCTAssertThrowsError(
            try await recognitionService.recognizeEquipment(from: testImage)
        ) { error in
            XCTAssertTrue(error is RecognitionError)
        }
    }
}
```

### 11.2 UI Testing

```swift
import XCTest

final class ARRepairUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUp() {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    func testCompleteRepairWorkflow() {
        // Navigate to job details
        app.buttons["Start Job"].tap()

        // Enter AR mode
        app.buttons["Start AR Guidance"].tap()

        // Wait for equipment recognition
        let recognizedLabel = app.staticTexts["Equipment Recognized"]
        XCTAssertTrue(recognizedLabel.waitForExistence(timeout: 5))

        // Complete first step
        app.buttons["Complete Step"].tap()

        // Verify progress
        XCTAssertTrue(app.staticTexts["Step 2 of 5"].exists)

        // Complete remaining steps
        for _ in 2...5 {
            app.buttons["Complete Step"].tap()
        }

        // Verify job completion
        XCTAssertTrue(app.staticTexts["Job Complete"].exists)
    }
}
```

### 11.3 Performance Testing

```swift
import XCTest

final class PerformanceTests: XCTestCase {
    func testEquipmentRecognitionPerformance() {
        let recognitionService = EquipmentRecognitionServiceImpl()
        let testImage = ImageAnchor.mock()

        measure {
            let _ = try? await recognitionService.recognizeEquipment(from: testImage)
        }

        // Target: <2 seconds for recognition
    }

    func testRenderingPerformance() {
        let sceneManager = RepairSceneManager()

        measureMetrics([.wallClockTime], automaticallyStartMeasuring: false) {
            startMeasuring()

            // Render complex scene
            Task {
                await sceneManager.setupScene(for: Equipment.complex())
                for step in RepairProcedure.complex().steps {
                    await sceneManager.overlayStep(step)
                }
            }

            stopMeasuring()
        }

        // Target: 60 FPS (16ms frame time)
    }
}
```

### 11.4 Testing Specifications

| Test Type | Coverage Target | Tools | Frequency |
|-----------|----------------|-------|-----------|
| Unit Tests | 80% code coverage | XCTest | Every commit |
| Integration Tests | Critical paths | XCTest | Daily |
| UI Tests | Main workflows | XCUITest | Before release |
| Performance Tests | Key operations | Instruments | Weekly |
| AR Testing | On-device only | Vision Pro | Before release |
| Accessibility | VoiceOver navigation | Accessibility Inspector | Before release |
| Network Tests | API integration | URLSession mocks | Daily |
| Load Tests | Multi-user collaboration | Custom harness | Monthly |

---

## Summary

These technical specifications provide:

1. **Modern Swift Stack**: Swift 6.0, SwiftUI, async/await concurrency
2. **visionOS Native**: Windows, volumes, and immersive spaces
3. **Advanced Interactions**: Hand tracking, eye tracking, spatial gestures
4. **Enterprise Security**: End-to-end encryption, RBAC, certificate pinning
5. **Offline Capability**: SwiftData persistence, intelligent caching
6. **Real-Time Collaboration**: WebRTC with spatial audio
7. **Accessibility**: Full VoiceOver, Dynamic Type, alternative inputs
8. **Performance**: 90 FPS target, <100ms latency, efficient rendering
9. **Comprehensive Testing**: Unit, UI, performance, and on-device testing

All specifications align with Apple's visionOS Human Interface Guidelines and enterprise field service requirements from the PRD.
