# Technical Specifications: Military Defense Training for visionOS

## 1. Technology Stack

### 1.1 Core Technologies

#### Platform & SDK
```yaml
Platform: visionOS 2.0+
Development:
  IDE: Xcode 16.0+
  Language: Swift 6.0+
  Concurrency: Swift Structured Concurrency (async/await, actors)
  UI Framework: SwiftUI 6.0
  3D Engine: RealityKit 4.0
  AR Framework: ARKit 6.0
  Persistence: SwiftData
  Audio: AVFAudio + RealityKit Spatial Audio

Minimum Requirements:
  Device: Apple Vision Pro (1st gen+)
  OS: visionOS 2.0
  RAM: 16GB
  Storage: 10GB minimum, 50GB recommended
```

#### Swift 6.0 Features
- **Strict Concurrency Checking**: Full data race safety
- **Typed Throws**: Enhanced error handling
- **Noncopyable Types**: Performance optimization for large data structures
- **Parameter Packs**: Variadic generics for flexible APIs
- **Ownership**: Explicit memory management where needed

### 1.2 Apple Frameworks

```swift
import SwiftUI
import RealityKit
import RealityKitContent
import ARKit
import AVFoundation
import SwiftData
import Observation
import Spatial
import CompositorServices // For advanced rendering
import Metal
import MetalKit
import Combine // For legacy integrations
import CoreMotion
import CoreHaptics
import GameController
```

### 1.3 Third-Party Dependencies

```swift
// Package.swift
dependencies: [
    // Swift Collections for optimized data structures
    .package(
        url: "https://github.com/apple/swift-collections",
        from: "1.0.0"
    ),
    // Swift Algorithms for performance
    .package(
        url: "https://github.com/apple/swift-algorithms",
        from: "1.0.0"
    ),
    // Numerics for ballistics calculations
    .package(
        url: "https://github.com/apple/swift-numerics",
        from: "1.0.0"
    )
]
```

## 2. visionOS Presentation Modes

### 2.1 WindowGroup Configuration

```swift
@main
struct MilitaryDefenseTrainingApp: App {
    @State private var appState = AppState()

    var body: some Scene {
        // MARK: - Main Window (Mission Control)
        WindowGroup(id: "mission-control") {
            MissionControlView()
                .environment(appState)
                .frame(minWidth: 800, minHeight: 600)
        }
        .windowStyle(.plain)
        .defaultSize(width: 1000, height: 700)

        // MARK: - Briefing Window
        WindowGroup(id: "briefing") {
            MissionBriefingView()
                .environment(appState)
        }
        .windowStyle(.plain)
        .defaultSize(width: 900, height: 650)

        // MARK: - After Action Review Window
        WindowGroup(id: "after-action") {
            AfterActionReviewView()
                .environment(appState)
        }
        .windowStyle(.plain)
        .defaultSize(width: 1200, height: 800)

        // MARK: - Volume (Tactical Planning)
        WindowGroup(id: "tactical-planning", for: Scenario.ID.self) { $scenarioID in
            TacticalPlanningVolume(scenarioID: scenarioID)
                .environment(appState)
        }
        .windowStyle(.volumetric)
        .defaultSize(width: 1.5, height: 1.0, depth: 1.5, in: .meters)

        // MARK: - Immersive Space (Combat Training)
        ImmersiveSpace(id: "combat-zone") {
            CombatEnvironmentView()
                .environment(appState)
        }
        .immersionStyle(selection: .constant(.progressive), in: .progressive)

        // MARK: - Settings Window
        WindowGroup(id: "settings") {
            SettingsView()
                .environment(appState)
        }
        .windowStyle(.plain)
        .defaultSize(width: 700, height: 500)
    }
}
```

### 2.2 Space Transition Management

```swift
@Observable
class SpaceManager {
    var openWindows: Set<String> = []
    var activeImmersiveSpace: String?

    @MainActor
    func transitionToPlanning(scenario: Scenario, openWindow: OpenWindowAction) async {
        await openWindow(id: "tactical-planning", value: scenario.id)
        openWindows.insert("tactical-planning")
    }

    @MainActor
    func startCombatTraining(openImmersiveSpace: OpenImmersiveSpaceAction) async {
        // Close other spaces first
        openWindows.removeAll()

        // Open immersive space
        switch await openImmersiveSpace(id: "combat-zone") {
        case .opened:
            activeImmersiveSpace = "combat-zone"
        case .error, .userCancelled:
            print("Failed to open combat zone")
        @unknown default:
            break
        }
    }

    @MainActor
    func exitCombat(
        dismissImmersiveSpace: DismissImmersiveSpaceAction,
        openWindow: OpenWindowAction
    ) async {
        await dismissImmersiveSpace()
        activeImmersiveSpace = nil
        await openWindow(id: "after-action")
        openWindows.insert("after-action")
    }
}
```

### 2.3 Presentation Mode Specifications

#### Window Mode Details
```yaml
Windows:
  Purpose: 2D UI for planning, briefing, analytics
  Resolution: Adaptive (scales with user preference)
  Materials: .ultraThinMaterial with military color scheme
  Ornaments: Toolbars for quick actions
  Hover Effects: Standard visionOS hover
  Interaction: Gaze + pinch, or hand poke
```

#### Volume Mode Details
```yaml
Volumes:
  Purpose: 3D terrain visualization, tactical planning
  Default Size: 1.5m x 1.0m x 1.5m
  Resizable: Yes (0.5m to 2.0m per dimension)
  Content Type: RealityKit entities
  Interaction:
    - 3D rotation via two-hand gesture
    - Zoom via pinch-spread
    - Object selection via tap
  Lighting: Custom directional light + ambient
  Background: Transparent (see-through)
```

#### Immersive Space Details
```yaml
Immersive_Space:
  Purpose: Full combat simulation
  Immersion Style: Progressive (blends real/virtual)
  Environment: Completely virtual battlefield
  Passthrough: Optional (for safety/instructor mode)
  Interaction:
    - Full hand tracking
    - Weapon gestures
    - Voice commands
    - Eye tracking for targeting
  Audio: Full spatial audio 360°
  Performance Target: 120fps locked
```

## 3. Gesture and Interaction Specifications

### 3.1 Standard visionOS Gestures

```swift
// MARK: - Basic Interactions
struct InteractionModifiers {
    // Tap/Select
    static func onTapGesture(_ action: @escaping () -> Void) -> some Gesture {
        SpatialTapGesture()
            .onEnded { _ in action() }
    }

    // Drag for movement
    static func onDragGesture(_ action: @escaping (DragGesture.Value) -> Void) -> some Gesture {
        DragGesture()
            .onChanged(action)
    }

    // Magnify for zoom
    static func onMagnifyGesture(_ action: @escaping (MagnifyGesture.Value) -> Void) -> some Gesture {
        MagnifyGesture()
            .onChanged(action)
    }

    // Rotate for orientation
    static func onRotateGesture(_ action: @escaping (RotateGesture3D.Value) -> Void) -> some Gesture {
        RotateGesture3D()
            .onChanged(action)
    }
}
```

### 3.2 Combat-Specific Gestures

```swift
enum CombatGesture {
    case weaponReady        // Raise hands to firing position
    case trigger            // Index finger pinch
    case reload             // Two-hand gesture
    case takecover          // Duck/lower gesture
    case throwGrenade       // Overhand throwing motion
    case meleeAttack        // Forward punch
    case aimDownSights      // Bring weapon to eye level
}

class CombatGestureRecognizer: ObservableObject {
    @Published var currentGesture: CombatGesture?
    @Published var gestureConfidence: Float = 0.0

    func processHandPoses(
        left: HandAnchor?,
        right: HandAnchor?
    ) -> CombatGesture? {
        guard let left, let right else { return nil }

        // Weapon ready detection
        if isWeaponReadyPose(left: left, right: right) {
            return .weaponReady
        }

        // Trigger pull detection
        if isTriggerPinch(right: right) {
            return .trigger
        }

        // Reload detection
        if isReloadGesture(left: left, right: right) {
            return .reload
        }

        return nil
    }

    private func isWeaponReadyPose(left: HandAnchor, right: HandAnchor) -> Bool {
        // Check if hands are in rifle-holding position
        let distance = simd_distance(
            left.originFromAnchorTransform.columns.3,
            right.originFromAnchorTransform.columns.3
        )

        // Hands should be 20-40cm apart
        let isCorrectDistance = distance > 0.2 && distance < 0.4

        // Both hands elevated to chest/shoulder level
        let leftHeight = left.originFromAnchorTransform.columns.3.y
        let rightHeight = right.originFromAnchorTransform.columns.3.y
        let isElevated = leftHeight > 1.0 && rightHeight > 1.0

        return isCorrectDistance && isElevated
    }

    private func isTriggerPinch(right: HandAnchor) -> Bool {
        // Detect index finger pinch on right hand
        let thumbTip = right.handSkeleton?.joint(.thumbTip)
        let indexTip = right.handSkeleton?.joint(.indexFingerTip)

        guard let thumb = thumbTip, let index = indexTip else {
            return false
        }

        let distance = simd_distance(
            thumb.anchorFromJointTransform.columns.3,
            index.anchorFromJointTransform.columns.3
        )

        // Pinch threshold: less than 2cm
        return distance < 0.02
    }

    private func isReloadGesture(left: HandAnchor, right: HandAnchor) -> Bool {
        // Detect magazine change motion
        // Left hand should move toward right hand (bringing new mag)
        // Then separate quickly
        // Implementation would track hand velocities and positions
        return false // Simplified for spec
    }
}
```

### 3.3 Hand Tracking Implementation

```swift
// MARK: - Hand Tracking Session
actor HandTrackingSession {
    private var session: ARKitSession?
    private var handTracking: HandTrackingProvider?

    func start() async throws {
        let session = ARKitSession()
        let handTracking = HandTrackingProvider()

        try await session.run([handTracking])

        self.session = session
        self.handTracking = handTracking
    }

    func getHandAnchors() async -> (left: HandAnchor?, right: HandAnchor?) {
        guard let handTracking else {
            return (nil, nil)
        }

        var leftHand: HandAnchor?
        var rightHand: HandAnchor?

        for await update in handTracking.anchorUpdates {
            switch update.event {
            case .updated:
                let anchor = update.anchor
                if anchor.chirality == .left {
                    leftHand = anchor
                } else if anchor.chirality == .right {
                    rightHand = anchor
                }
            default:
                break
            }
        }

        return (leftHand, rightHand)
    }

    func stop() {
        session?.stop()
    }
}
```

### 3.4 Eye Tracking Implementation

```swift
// MARK: - Eye Tracking for Targeting
actor EyeTrackingSession {
    private var session: ARKitSession?
    private var eyeTracking: EyeTrackingProvider?

    func start() async throws {
        let session = ARKitSession()
        let eyeTracking = EyeTrackingProvider()

        try await session.run([eyeTracking])

        self.session = session
        self.eyeTracking = eyeTracking
    }

    func getGazeDirection() async -> SIMD3<Float>? {
        guard let eyeTracking else { return nil }

        // Get the latest eye tracking data
        for await update in eyeTracking.anchorUpdates {
            if case .updated = update.event {
                let anchor = update.anchor
                // Convert eye gaze to world direction
                let transform = anchor.originFromAnchorTransform
                let forward = SIMD3<Float>(transform.columns.2.x,
                                          transform.columns.2.y,
                                          transform.columns.2.z)
                return -forward // Negative Z is forward
            }
        }

        return nil
    }
}

// MARK: - Targeting System
class TargetingSystem: ObservableObject {
    @Published var currentTarget: Entity?
    @Published var targetingReticle: SIMD3<Float>?

    private let eyeTracking = EyeTrackingSession()

    func startTracking() async throws {
        try await eyeTracking.start()
    }

    func updateTargeting(in scene: Entity) async {
        guard let gazeDirection = await eyeTracking.getGazeDirection() else {
            return
        }

        // Raycast from user's position in gaze direction
        let origin = SIMD3<Float>(0, 1.7, 0) // Approximate eye height
        let ray = Ray(origin: origin, direction: gazeDirection)

        // Find intersections
        if let hit = scene.raycast(from: ray.origin, to: ray.origin + ray.direction * 100.0).first {
            targetingReticle = hit.position
            currentTarget = hit.entity
        }
    }
}
```

### 3.5 Voice Commands

```swift
import Speech

// MARK: - Voice Command System
actor VoiceCommandSystem {
    private var speechRecognizer: SFSpeechRecognizer?
    private var recognitionTask: SFSpeechRecognitionTask?

    enum VoiceCommand: String, CaseIterable {
        case fireMission = "fire mission"
        case ceasefire = "cease fire"
        case regroup = "regroup"
        case coveringFire = "covering fire"
        case medic = "medic"
        case status = "status report"
        case retreat = "fall back"
        case advance = "move out"
    }

    func startListening() async throws {
        speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))

        // Request authorization
        let authStatus = await SFSpeechRecognizer.requestAuthorization()
        guard authStatus == .authorized else {
            throw VoiceCommandError.notAuthorized
        }
    }

    func recognizeCommand(_ audioBuffer: AVAudioPCMBuffer) async -> VoiceCommand? {
        // Process audio and match to commands
        // Simplified for spec
        return nil
    }

    enum VoiceCommandError: Error {
        case notAuthorized
        case recognitionFailed
    }
}
```

## 4. Spatial Audio Specifications

### 4.1 Audio Architecture

```swift
// MARK: - Spatial Audio Manager
@Observable
class SpatialAudioManager {
    private var audioEngine = AVAudioEngine()
    private var environmentNode = AVAudioEnvironmentNode()

    // Audio categories
    enum AudioCategory {
        case weaponFire
        case explosion
        case footsteps
        case voice
        case ambient
        case radio
    }

    struct AudioConfiguration {
        let maxDistance: Float = 500.0 // meters
        let referenceDistance: Float = 1.0
        let rolloffFactor: Float = 1.0
        let soundSpeed: Float = 343.0 // m/s
    }

    func setup() {
        // Configure audio engine
        audioEngine.attach(environmentNode)
        audioEngine.connect(
            environmentNode,
            to: audioEngine.mainMixerNode,
            format: nil
        )

        // Set environment properties
        environmentNode.listenerPosition = AVAudio3DPoint(x: 0, y: 0, z: 0)
        environmentNode.distanceAttenuationParameters.referenceDistance = 1.0
        environmentNode.distanceAttenuationParameters.maximumDistance = 500.0
        environmentNode.distanceAttenuationParameters.rolloffFactor = 1.0

        try? audioEngine.start()
    }

    func play3DSound(
        _ soundFile: String,
        at position: SIMD3<Float>,
        category: AudioCategory,
        volume: Float = 1.0
    ) {
        guard let url = Bundle.main.url(forResource: soundFile, withExtension: "wav") else {
            return
        }

        let audioFile = try? AVAudioFile(forReading: url)
        let playerNode = AVAudioPlayerNode()

        audioEngine.attach(playerNode)
        audioEngine.connect(playerNode, to: environmentNode, format: audioFile?.processingFormat)

        // Set 3D position
        playerNode.position = AVAudio3DPoint(x: position.x, y: position.y, z: position.z)

        // Play
        if let audioFile {
            playerNode.scheduleFile(audioFile, at: nil)
            playerNode.volume = volume * getCategoryVolume(category)
            playerNode.play()
        }
    }

    private func getCategoryVolume(_ category: AudioCategory) -> Float {
        switch category {
        case .weaponFire: return 1.0
        case .explosion: return 1.0
        case .footsteps: return 0.5
        case .voice: return 0.8
        case .ambient: return 0.3
        case .radio: return 0.7
        }
    }

    func updateListenerPosition(_ position: SIMD3<Float>, orientation: simd_quatf) {
        environmentNode.listenerPosition = AVAudio3DPoint(
            x: position.x,
            y: position.y,
            z: position.z
        )

        // Convert quaternion to forward/up vectors
        let forward = orientation.act(SIMD3<Float>(0, 0, -1))
        let up = orientation.act(SIMD3<Float>(0, 1, 0))

        environmentNode.listenerVectorOrientation = AVAudio3DVectorOrientation(
            forward: AVAudio3DVector(x: forward.x, y: forward.y, z: forward.z),
            up: AVAudio3DVector(x: up.x, y: up.y, z: up.z)
        )
    }
}
```

### 4.2 RealityKit Audio Components

```swift
// MARK: - Spatial Audio Component
struct SpatialAudioComponent: Component {
    var audioResource: AudioFileResource
    var looping: Bool = false
    var volume: Float = 1.0
    var category: SpatialAudioManager.AudioCategory
}

// Usage in entity
extension Entity {
    func addSpatialAudio(
        resource: AudioFileResource,
        category: SpatialAudioManager.AudioCategory
    ) {
        let audioComponent = SpatialAudioComponent(
            audioResource: resource,
            category: category
        )
        components.set(audioComponent)

        // Add audio playback controller
        let audioController = AudioPlaybackController()
        audioController.speed = 1.0
        audioController.gain = audioComponent.volume
        components.set(audioController)
    }
}
```

## 5. Accessibility Requirements

### 5.1 VoiceOver Support

```swift
// MARK: - Accessibility Labels
extension View {
    func combatAccessibility(
        label: String,
        hint: String,
        traits: AccessibilityTraits = []
    ) -> some View {
        self
            .accessibilityLabel(label)
            .accessibilityHint(hint)
            .accessibilityAddTraits(traits)
    }
}

// Example usage
Button("Start Mission") {
    startMission()
}
.combatAccessibility(
    label: "Start Mission Button",
    hint: "Double-tap to begin combat training scenario",
    traits: .isButton
)
```

### 5.2 Dynamic Type Support

```swift
// MARK: - Adaptive Typography
struct MilitaryTypography {
    static let title: Font = .system(size: 34, weight: .bold, design: .default)
        .leading(.tight)

    static let headline: Font = .system(size: 24, weight: .semibold, design: .default)

    static let body: Font = .system(size: 17, weight: .regular, design: .default)

    static let caption: Font = .system(size: 12, weight: .regular, design: .default)

    // All fonts automatically scale with Dynamic Type
}

// Usage
Text("Mission Briefing")
    .font(MilitaryTypography.title)
    .dynamicTypeSize(...DynamicTypeSize.xxxLarge) // Cap maximum size
```

### 5.3 Alternative Interaction Methods

```yaml
Accessibility_Options:
  Voice_Control:
    - Full voice navigation
    - Combat commands via speech
    - Status queries

  Assistive_Touch:
    - Reduced precision targeting
    - Auto-aim assistance
    - Simplified gestures

  Visual_Accommodations:
    - High contrast mode
    - Color blind filters (Protanopia, Deuteranopia, Tritanopia)
    - Enhanced UI visibility
    - Larger hit targets

  Auditory_Accommodations:
    - Visual indicators for audio cues
    - Haptic feedback for sounds
    - Closed captions for voice

  Motion_Accommodations:
    - Reduce motion effects
    - Disable parallax
    - Stationary combat mode
    - Reduced camera shake
```

### 5.4 Implementation

```swift
@Observable
class AccessibilityManager {
    var voiceOverEnabled: Bool = false
    var reducedMotion: Bool = false
    var highContrastEnabled: Bool = false
    var colorBlindMode: ColorBlindMode = .none

    enum ColorBlindMode {
        case none
        case protanopia
        case deuteranopia
        case tritanopia
    }

    func applyColorFilter(_ color: Color) -> Color {
        switch colorBlindMode {
        case .none:
            return color
        case .protanopia:
            return adjustForProtanopia(color)
        case .deuteranopia:
            return adjustForDeuteranopia(color)
        case .tritanopia:
            return adjustForTritanopia(color)
        }
    }

    private func adjustForProtanopia(_ color: Color) -> Color {
        // Simulate red-blind vision
        // Implementation would use color transformation matrices
        return color
    }

    private func adjustForDeuteranopia(_ color: Color) -> Color {
        // Simulate green-blind vision
        return color
    }

    private func adjustForTritanopia(_ color: Color) -> Color {
        // Simulate blue-blind vision
        return color
    }
}
```

## 6. Privacy and Security Requirements

### 6.1 Privacy Manifest

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN">
<plist version="1.0">
<dict>
    <key>NSPrivacyTracking</key>
    <false/>
    <key>NSPrivacyTrackingDomains</key>
    <array/>
    <key>NSPrivacyCollectedDataTypes</key>
    <array>
        <dict>
            <key>NSPrivacyCollectedDataType</key>
            <string>NSPrivacyCollectedDataTypePerformance</string>
            <key>NSPrivacyCollectedDataTypeLinked</key>
            <true/>
            <key>NSPrivacyCollectedDataTypeTracking</key>
            <false/>
            <key>NSPrivacyCollectedDataTypePurposes</key>
            <array>
                <string>NSPrivacyCollectedDataTypePurposeAnalytics</string>
            </array>
        </dict>
    </array>
    <key>NSPrivacyAccessedAPITypes</key>
    <array>
        <dict>
            <key>NSPrivacyAccessedAPIType</key>
            <string>NSPrivacyAccessedAPICategoryUserDefaults</string>
            <key>NSPrivacyAccessedAPITypeReasons</key>
            <array>
                <string>CA92.1</string>
            </array>
        </dict>
    </array>
</dict>
</plist>
```

### 6.2 Data Encryption

```swift
// MARK: - Encryption Service
actor EncryptionService {
    private let keychain = KeychainManager()

    func encryptData(_ data: Data) async throws -> Data {
        let key = try await keychain.getEncryptionKey()
        let encrypted = try ChaChaPoly.seal(data, using: key)
        return encrypted.combined
    }

    func decryptData(_ encryptedData: Data) async throws -> Data {
        let key = try await keychain.getEncryptionKey()
        let sealedBox = try ChaChaPoly.SealedBox(combined: encryptedData)
        return try ChaChaPoly.open(sealedBox, using: key)
    }
}

// MARK: - Keychain Manager
actor KeychainManager {
    func getEncryptionKey() async throws -> SymmetricKey {
        // Retrieve from Secure Enclave
        // If not exists, generate and store
        let query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: "com.military.training.encryption",
            kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
            kSecReturnData as String: true
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        if status == errSecSuccess,
           let keyData = item as? Data {
            return SymmetricKey(data: keyData)
        } else {
            // Generate new key
            let newKey = SymmetricKey(size: .bits256)
            try await storeKey(newKey)
            return newKey
        }
    }

    private func storeKey(_ key: SymmetricKey) async throws {
        let keyData = key.withUnsafeBytes { Data($0) }

        let query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: "com.military.training.encryption",
            kSecValueData as String: keyData,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]

        let status = SecItemAdd(query as CFDictionary, nil)

        guard status == errSecSuccess else {
            throw KeychainError.storeFailed
        }
    }

    enum KeychainError: Error {
        case storeFailed
        case retrievalFailed
    }
}
```

### 6.3 Network Security

```swift
// MARK: - Secure Network Configuration
class SecureNetworkService {
    private let session: URLSession

    init() {
        let configuration = URLSessionConfiguration.default
        configuration.tlsMinimumSupportedProtocolVersion = .TLSv13
        configuration.waitsForConnectivity = true
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 300

        self.session = URLSession(
            configuration: configuration,
            delegate: CertificatePinningDelegate(),
            delegateQueue: nil
        )
    }

    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        var request = URLRequest(url: endpoint.url)
        request.httpMethod = endpoint.method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Add classification header
        request.setValue(
            endpoint.classification.rawValue,
            forHTTPHeaderField: "X-Classification"
        )

        // Add authentication token
        if let token = await getAuthToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.invalidResponse
        }

        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    }

    private func getAuthToken() async -> String? {
        // Retrieve CAC/PKI token
        return nil
    }

    enum NetworkError: Error {
        case invalidResponse
        case unauthorized
        case forbidden
    }
}

// MARK: - Certificate Pinning
class CertificatePinningDelegate: NSObject, URLSessionDelegate {
    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge
    ) async -> (URLSession.AuthChallengeDisposition, URLCredential?) {
        guard challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
              let serverTrust = challenge.protectionSpace.serverTrust else {
            return (.cancelAuthenticationChallenge, nil)
        }

        // Validate certificate
        let isValid = await validateCertificate(serverTrust)

        if isValid {
            return (.useCredential, URLCredential(trust: serverTrust))
        } else {
            return (.cancelAuthenticationChallenge, nil)
        }
    }

    private func validateCertificate(_ trust: SecTrust) async -> Bool {
        // Implement certificate pinning logic
        // Compare against known good certificates
        return true
    }
}
```

## 7. Data Persistence Strategy

### 7.1 SwiftData Models

```swift
import SwiftData

// MARK: - Model Configuration
@main
struct MilitaryDefenseTrainingApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            TrainingSession.self,
            Warrior.self,
            Scenario.self,
            PerformanceMetrics.self,
            AfterActionReport.self
        ])

        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            allowsSave: true,
            groupContainer: .identifier("group.com.military.training")
        )

        do {
            return try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
```

### 7.2 File Storage for Assets

```swift
// MARK: - Asset Manager
actor AssetManager {
    private let fileManager = FileManager.default
    private var cacheDirectory: URL {
        fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("TrainingAssets")
    }

    func downloadScenarioAssets(_ scenario: Scenario) async throws {
        let scenarioPath = cacheDirectory.appendingPathComponent(scenario.id.uuidString)

        // Create directory
        try fileManager.createDirectory(
            at: scenarioPath,
            withIntermediateDirectories: true
        )

        // Download terrain
        try await downloadFile(
            from: scenario.terrain.heightmap,
            to: scenarioPath.appendingPathComponent("terrain.heightmap")
        )

        // Download 3D models
        for building in scenario.terrain.buildings {
            try await downloadFile(
                from: building.modelURL,
                to: scenarioPath.appendingPathComponent("models/\(building.id).usdz")
            )
        }
    }

    private func downloadFile(from url: URL, to destination: URL) async throws {
        let (tempURL, _) = try await URLSession.shared.download(from: url)
        try fileManager.moveItem(at: tempURL, to: destination)
    }

    func clearCache() throws {
        try fileManager.removeItem(at: cacheDirectory)
    }
}
```

## 8. Network Architecture

### 8.1 API Layer

```swift
// MARK: - API Endpoints
enum APIEndpoint {
    case getScenarios(filter: ScenarioFilter)
    case downloadScenario(id: UUID)
    case uploadSession(TrainingSession)
    case getAnalytics(warriorID: UUID)
    case downloadAIModel
    case submitScore(CompetitionScore)

    var url: URL {
        let baseURL = "https://api.militarytraining.mil"
        switch self {
        case .getScenarios:
            return URL(string: "\(baseURL)/v1/scenarios")!
        case .downloadScenario(let id):
            return URL(string: "\(baseURL)/v1/scenarios/\(id)/download")!
        case .uploadSession:
            return URL(string: "\(baseURL)/v1/sessions")!
        case .getAnalytics(let id):
            return URL(string: "\(baseURL)/v1/analytics/warrior/\(id)")!
        case .downloadAIModel:
            return URL(string: "\(baseURL)/v1/ai/opfor/latest")!
        case .submitScore:
            return URL(string: "\(baseURL)/v1/leaderboard/submit")!
        }
    }

    var method: String {
        switch self {
        case .getScenarios, .getAnalytics, .downloadScenario, .downloadAIModel:
            return "GET"
        case .uploadSession, .submitScore:
            return "POST"
        }
    }

    var classification: ClassificationLevel {
        switch self {
        case .getScenarios, .downloadScenario:
            return .secret
        case .uploadSession, .getAnalytics:
            return .confidential
        case .downloadAIModel:
            return .secret
        case .submitScore:
            return .unclassified
        }
    }
}
```

### 8.2 Offline Support

```swift
// MARK: - Offline Manager
@Observable
class OfflineManager {
    var isOnline: Bool = false
    var pendingOperations: [PendingOperation] = []

    struct PendingOperation: Codable {
        var id: UUID
        var type: OperationType
        var data: Data
        var timestamp: Date
    }

    enum OperationType: String, Codable {
        case sessionUpload
        case analyticsSync
        case scoreSubmission
    }

    func queueOperation(_ operation: PendingOperation) async {
        pendingOperations.append(operation)
        await savePendingOperations()

        if isOnline {
            await processPendingOperations()
        }
    }

    func processPendingOperations() async {
        for operation in pendingOperations {
            do {
                try await processOperation(operation)
                pendingOperations.removeAll { $0.id == operation.id }
            } catch {
                print("Failed to process operation: \(error)")
            }
        }

        await savePendingOperations()
    }

    private func processOperation(_ operation: PendingOperation) async throws {
        // Process based on type
        switch operation.type {
        case .sessionUpload:
            // Upload training session
            break
        case .analyticsSync:
            // Sync analytics
            break
        case .scoreSubmission:
            // Submit score
            break
        }
    }

    private func savePendingOperations() async {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(pendingOperations) {
            UserDefaults.standard.set(data, forKey: "pendingOperations")
        }
    }
}
```

## 9. Testing Requirements

### 9.1 Unit Testing

```swift
import XCTest
@testable import MilitaryDefenseTraining

final class CombatSystemTests: XCTestCase {
    var combatService: CombatSimulationService!

    override func setUp() async throws {
        combatService = CombatSimulationService()
    }

    func testWeaponDamageCalculation() async throws {
        let weapon = WeaponSystem.m4Rifle
        let hit = HitEvent(
            weapon: weapon,
            distance: 100.0,
            bodyPart: .torso,
            armorType: .plateCarrier
        )

        let result = await combatService.calculateDamage(hit)

        XCTAssertGreaterThan(result.damage, 0)
        XCTAssertLessThan(result.damage, weapon.damage.maximum)
    }

    func testCoverEffectiveness() async throws {
        let entity = CombatEntity()
        entity.position = SIMD3<Float>(0, 0, 0)

        let threatDirection = SIMD3<Float>(1, 0, 0)
        let coverPosition = SIMD3<Float>(-1, 0, 0) // Behind entity

        let effectiveness = await combatService.processCover(
            entity: entity,
            threat: threatDirection
        )

        XCTAssertEqual(effectiveness, .full)
    }
}
```

### 9.2 UI Testing

```swift
import XCTest

final class MissionFlowUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUp() {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    func testMissionSelectionFlow() throws {
        // Tap mission select button
        app.buttons["Mission Select"].tap()

        // Wait for scenario list
        let scenarioList = app.scrollViews["Scenario List"]
        XCTAssertTrue(scenarioList.waitForExistence(timeout: 5))

        // Select first scenario
        scenarioList.buttons.firstMatch.tap()

        // Verify briefing appears
        XCTAssertTrue(app.staticTexts["Mission Briefing"].exists)
    }

    func testCombatInitiation() throws {
        // Navigate to combat
        app.buttons["Start Training"].tap()

        // Wait for immersive space
        let combatView = app.otherElements["Combat View"]
        XCTAssertTrue(combatView.waitForExistence(timeout: 10))

        // Verify HUD elements
        XCTAssertTrue(app.staticTexts["Health"].exists)
        XCTAssertTrue(app.staticTexts["Ammo"].exists)
    }
}
```

### 9.3 Performance Testing

```swift
import XCTest

final class PerformanceTests: XCTestCase {
    func testRenderingPerformance() throws {
        measure(metrics: [XCTClockMetric()]) {
            // Measure frame rendering time
            let scene = CombatScene()
            scene.update(deltaTime: 0.016) // 60fps target
        }
    }

    func testAIProcessingPerformance() throws {
        let metrics: [XCTMetric] = [
            XCTCPUMetric(),
            XCTMemoryMetric(),
            XCTClockMetric()
        ]

        measure(metrics: metrics) {
            let ai = AIDirectorService()
            Task {
                await ai.updateOpForBehaviors()
            }
        }
    }
}
```

## 10. Build Configuration

### 10.1 Xcode Project Settings

```yaml
Project_Settings:
  Deployment_Target: visionOS 2.0
  Swift_Version: 6.0
  Build_Configuration:
    Debug:
      - Optimization: -Onone
      - Debug_Info: Yes
      - Testability: Enabled
    Release:
      - Optimization: -O (Optimize for Speed)
      - Debug_Info: No
      - Testability: Disabled
      - Whole_Module_Optimization: Yes

Capabilities:
  - Spatial Computing
  - Hand Tracking
  - ARKit
  - Network (Client + Server)
  - Background Modes (Audio)
  - App Groups
  - Keychain Sharing

Info_plist:
  NSCameraUsageDescription: "Required for AR tracking"
  NSHandsTrackingUsageDescription: "Required for weapon manipulation"
  NSMicrophoneUsageDescription: "Required for voice commands"
  NSLocalNetworkUsageDescription: "Required for multi-user training"
```

### 10.2 Build Phases

```bash
# Pre-compile script: Code generation
#!/bin/bash
echo "Generating scenario manifests..."
swift Scripts/GenerateScenarios.swift

# Post-compile script: Asset validation
#!/bin/bash
echo "Validating 3D assets..."
swift Scripts/ValidateAssets.swift
```

---

## Summary

This technical specification provides:

1. **Complete Technology Stack**: Swift 6, SwiftUI, RealityKit, ARKit
2. **visionOS Integration**: Windows, Volumes, Immersive Spaces
3. **Interaction Systems**: Hand tracking, eye tracking, voice commands
4. **Audio System**: Full spatial audio with realistic battlefield sounds
5. **Accessibility**: VoiceOver, Dynamic Type, alternative interactions
6. **Security**: Encryption, secure networking, classification handling
7. **Data Persistence**: SwiftData + file-based asset management
8. **Network Architecture**: RESTful API with offline support
9. **Testing Strategy**: Unit, UI, and performance testing
10. **Build Configuration**: Complete Xcode setup

All specifications are designed to meet military-grade requirements while providing an exceptional spatial computing training experience on Apple Vision Pro.
