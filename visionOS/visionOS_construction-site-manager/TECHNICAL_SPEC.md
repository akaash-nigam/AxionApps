# Construction Site Manager - Technical Specifications

## Document Overview
**Version:** 1.0
**Last Updated:** 2025-01-20
**Status:** Design Phase

This document provides detailed technical specifications for implementing the Construction Site Manager visionOS application.

---

## 1. Technology Stack

### 1.1 Core Technologies

| Component | Technology | Version | Justification |
|-----------|------------|---------|---------------|
| **Platform** | visionOS | 2.0+ | Latest spatial computing capabilities |
| **Language** | Swift | 6.0+ | Modern concurrency, type safety, performance |
| **UI Framework** | SwiftUI | Latest | Declarative UI, visionOS optimized |
| **3D Rendering** | RealityKit | 2.0+ | Native spatial rendering, ECS architecture |
| **AR Foundation** | ARKit | 6.0+ | World tracking, scene understanding |
| **Persistence** | SwiftData | 2.0+ | Modern data persistence, observation |
| **Networking** | URLSession | - | Native HTTP/REST client |
| **Real-time Sync** | WebSockets | - | Live collaboration features |
| **Concurrency** | Swift Concurrency | - | async/await, actors, structured concurrency |

### 1.2 Development Tools

| Tool | Purpose | Version |
|------|---------|---------|
| **Xcode** | IDE | 16.0+ |
| **Reality Composer Pro** | 3D asset creation | 2.0+ |
| **Instruments** | Performance profiling | Latest |
| **visionOS Simulator** | Testing without hardware | Latest |
| **TestFlight** | Beta distribution | Latest |

### 1.3 Third-Party Dependencies

```swift
// Package.swift dependencies
dependencies: [
    // IFC file parsing
    .package(url: "https://github.com/example/IFCSwift", from: "1.0.0"),

    // Efficient serialization
    .package(url: "https://github.com/apple/swift-protobuf", from: "1.25.0"),

    // MQTT for IoT sensors
    .package(url: "https://github.com/swift-server-community/mqtt-nio", from: "2.9.0"),

    // Spatial math utilities
    .package(url: "https://github.com/apple/swift-numerics", from: "1.0.0"),
]
```

---

## 2. visionOS Presentation Modes

### 2.1 WindowGroup (2D Interface)

**Purpose**: Main control panel, lists, forms, settings

**Specifications:**
```swift
WindowGroup("Site Control", id: "main-control") {
    SiteControlView()
}
.windowStyle(.plain)
.defaultSize(width: 800, height: 600)
.windowResizability(.contentSize)
```

**Features:**
- Dashboard with key metrics
- Site and project selection
- Issue list and management
- Schedule view
- Settings and preferences
- Team directory
- Document browser

**Constraints:**
- Minimum size: 600×400 points
- Maximum size: 1200×900 points
- Supports multiple windows simultaneously
- Draggable, resizable within bounds

### 2.2 Volumetric Windows (3D Bounded Content)

**Purpose**: 3D site preview, model inspection, coordination

**Specifications:**
```swift
WindowGroup("Site Overview", id: "site-volume") {
    SiteOverviewVolumeView()
}
.windowStyle(.volumetric)
.defaultSize(width: 2, height: 1.5, depth: 2, in: .meters)
```

**Features:**
- Interactive 3D BIM model
- Rotate, zoom, pan navigation
- Element selection and inspection
- Layer filtering
- Clash detection visualization
- Schedule animation (4D)
- Multi-user collaboration

**Constraints:**
- Volume size: 1-3 meters per dimension
- Bounded space with glass container
- Z-depth ordering important
- Performance: maintain 90 FPS with complex models

### 2.3 Mixed Reality (Immersive Space)

**Purpose**: On-site AR overlay, primary field use mode

**Specifications:**
```swift
ImmersiveSpace(id: "ar-overlay") {
    ARSiteOverlayView()
}
.immersionStyle(selection: $immersionStyle, in: .mixed)
.upperLimbVisibility(.visible)  // Show hands
```

**Features:**
- Real-world passthrough
- BIM overlay on physical site
- Real-time progress tracking
- Safety zone visualization
- Worker tracking
- Spatial annotations
- Gesture interactions
- Voice commands

**Constraints:**
- Full spatial awareness required
- GPS + visual SLAM for positioning
- ±5mm alignment accuracy
- Outdoor and indoor operation
- 8-hour battery target
- Brightness: readable in sunlight

### 2.4 Full Immersive Space

**Purpose**: Training, client presentations, design reviews

**Specifications:**
```swift
ImmersiveSpace(id: "full-immersive") {
    ImmersiveTrainingView()
}
.immersionStyle(selection: $immersionStyle, in: .full)
```

**Features:**
- Complete environment replacement
- Virtual site walkthroughs
- Time-lapse construction simulation
- Training scenarios
- Safety simulations
- Client presentations

**Constraints:**
- Limited to shorter sessions (15-30 min)
- Comfort-optimized navigation
- Clear exit mechanism
- Audio spatial cues

---

## 3. Gesture and Interaction Specifications

### 3.1 Standard visionOS Gestures

| Gesture | Interaction | Response | Use Case |
|---------|-------------|----------|----------|
| **Gaze + Tap** | Look at element, pinch fingers | Element selection | Select BIM element, open menu |
| **Gaze + Double Tap** | Look at element, double pinch | Quick action | Toggle element visibility |
| **Drag** | Pinch and move hand | Move object | Reposition annotation |
| **Pinch & Spread** | Two-hand gesture | Scale | Zoom in/out on model |
| **Rotate** | Two-hand twist | Rotation | Rotate 3D model |
| **Long Press** | Sustained pinch | Context menu | Show element properties |

### 3.2 Custom Construction Gestures

```swift
enum ConstructionGesture: String {
    case measure        // Two-finger extend
    case annotate       // Point and hold
    case approve        // Thumbs up
    case reject         // Thumbs down
    case flagIssue      // X gesture with hand
    case capture        // Frame gesture (rectangle)
    case levelCheck     // Two hands flat horizontal
    case heightMeasure  // Two hands vertical
}

class CustomGestureRecognizer {
    func recognizeGesture(_ handPose: HandPose) -> ConstructionGesture? {
        // Custom gesture recognition logic
    }
}
```

**Gesture Specifications:**

**Measure Gesture:**
- **Input**: Extend thumb and index finger on both hands
- **Action**: Create measurement between two points
- **Feedback**: Visual line with dimension, haptic click on point set
- **Accuracy**: ±5mm

**Annotate Gesture:**
- **Input**: Point with index finger, hold for 1 second
- **Action**: Create annotation at pointed location
- **Feedback**: Annotation marker appears, voice input activates

**Approve/Reject:**
- **Input**: Thumbs up/down gesture
- **Action**: Approve or reject current inspection item
- **Feedback**: Visual confirmation, item status updated

**Flag Issue:**
- **Input**: Draw X in air with index finger
- **Action**: Create issue marker at gaze point
- **Feedback**: Red issue marker, issue form appears

**Capture Photo:**
- **Input**: Frame gesture (rectangle with fingers)
- **Action**: Capture photo of framed area
- **Feedback**: Camera shutter sound, photo preview

### 3.3 Interaction Feedback

```swift
struct InteractionFeedback {
    // Visual feedback
    static func highlight(entity: Entity) {
        entity.components[HighlightComponent.self] = HighlightComponent(
            color: .systemBlue,
            intensity: 0.3,
            animation: .pulse(duration: 0.5)
        )
    }

    // Spatial audio feedback
    static func playSound(_ sound: SoundEffect, at position: SIMD3<Float>) {
        let audioResource = try! AudioFileResource.load(named: sound.filename)
        let audioEntity = Entity()
        audioEntity.position = position
        audioEntity.playAudio(audioResource)
    }

    // Haptic feedback
    static func haptic(_ type: HapticType) {
        // Trigger appropriate haptic response
    }
}

enum HapticType {
    case selectionChanged
    case actionCompleted
    case warningAlert
    case errorOccurred
}
```

### 3.4 Accessibility Alternatives

For users unable to perform gestures:

| Alternative | Method | Use Case |
|-------------|--------|----------|
| **Voice Control** | "Select wall", "Measure this" | Full voice navigation |
| **Button UI** | On-screen buttons | Traditional input method |
| **Dwell Selection** | Gaze for 2 seconds | Selection without hands |
| **External Controller** | Bluetooth game controller | Precise input |

---

## 4. Hand Tracking Implementation

### 4.1 Hand Tracking Provider Configuration

```swift
class HandTrackingManager {
    private let handTracking = HandTrackingProvider()

    func startTracking() async throws {
        let configuration = HandTrackingProvider.Configuration()
        try await handTracking.run(configuration)

        // Process hand updates
        Task {
            for await update in handTracking.anchorUpdates {
                await processHandUpdate(update)
            }
        }
    }

    private func processHandUpdate(_ update: HandAnchor.Update) async {
        switch update.event {
        case .added(let anchor):
            handleHandAppeared(anchor)
        case .updated(let anchor):
            handleHandMoved(anchor)
        case .removed(let anchor):
            handleHandDisappeared(anchor)
        }
    }
}
```

### 4.2 Hand Skeleton Tracking

```swift
struct HandPose {
    var wrist: SIMD3<Float>
    var thumb: [SIMD3<Float>]  // 4 joints
    var index: [SIMD3<Float>]  // 4 joints
    var middle: [SIMD3<Float>]
    var ring: [SIMD3<Float>]
    var little: [SIMD3<Float>]

    var chirality: HandChirality  // .left or .right
    var confidence: Float
}

class HandSkeletonTracker {
    func extractPose(from anchor: HandAnchor) -> HandPose {
        // Extract joint positions
        // Calculate hand pose
        // Determine confidence
    }

    func recognizeGesture(from pose: HandPose) -> ConstructionGesture? {
        // Gesture recognition from skeleton
        // Pattern matching against known gestures
    }
}
```

### 4.3 Precision Requirements

| Operation | Precision | Latency | Confidence |
|-----------|-----------|---------|------------|
| **Element Selection** | ±10mm | <50ms | >0.8 |
| **Measurement** | ±5mm | <100ms | >0.9 |
| **Gesture Recognition** | N/A | <150ms | >0.85 |
| **Manipulation** | ±10mm | <50ms | >0.8 |

### 4.4 Hand Occlusion Handling

```swift
class HandOcclusionManager {
    func handleOcclusion(hand: HandPose, entities: [Entity]) {
        // Render hands in front of virtual content
        // Apply proper depth sorting
        // Maintain realistic occlusion with real world
    }

    func estimatePoseWhenOccluded(lastKnownPose: HandPose) -> HandPose? {
        // Predictive tracking when hand temporarily occluded
        // Use motion model to estimate position
        // Degrade confidence appropriately
    }
}
```

---

## 5. Eye Tracking Implementation

### 5.1 Eye Tracking Provider

```swift
class EyeTrackingManager {
    private let eyeTracking = EyeTrackingProvider()

    func startTracking() async throws {
        guard eyeTracking.isSupported else {
            throw EyeTrackingError.notSupported
        }

        let configuration = EyeTrackingProvider.Configuration()
        try await eyeTracking.run(configuration)

        Task {
            for await update in eyeTracking.anchorUpdates {
                await processEyeUpdate(update)
            }
        }
    }

    private func processEyeUpdate(_ update: EyeAnchor.Update) async {
        guard let anchor = update.anchor else { return }

        let gazeDirection = anchor.lookAtPoint
        let focusedEntity = rayCast(from: gazeDirection)

        await handleFocusChange(focusedEntity)
    }
}
```

### 5.2 Gaze-Based Interactions

```swift
enum GazeInteraction {
    case selection      // Gaze + gesture
    case scrolling      // Gaze + dwell
    case navigation     // Gaze direction
    case contextLoading // Predictive content loading
}

class GazeInteractionHandler {
    private var gazeDuration: TimeInterval = 0
    private var currentFocus: Entity?

    func updateGaze(focusedEntity: Entity?, deltaTime: TimeInterval) {
        if focusedEntity == currentFocus {
            gazeDuration += deltaTime

            // Dwell selection after 2 seconds
            if gazeDuration >= 2.0 {
                handleDwellSelection(focusedEntity)
            }
        } else {
            // Focus changed
            if let previous = currentFocus {
                handleFocusExit(previous)
            }

            currentFocus = focusedEntity
            gazeDuration = 0

            if let current = currentFocus {
                handleFocusEnter(current)
            }
        }
    }

    func handleFocusEnter(_ entity: Entity) {
        // Subtle highlight
        // Pre-load relevant data
        // Show tooltip after delay
    }

    func handleFocusExit(_ entity: Entity) {
        // Remove highlight
        // Cancel pending actions
    }
}
```

### 5.3 Predictive Content Loading

```swift
class PredictiveLoader {
    func analyzeFocusPattern(_ history: [FocusEvent]) async -> UserIntention {
        // Machine learning model to predict user intention
        // Based on gaze patterns and dwell times
    }

    func preloadContent(for intention: UserIntention) async {
        switch intention {
        case .inspectingElement(let elementId):
            await preloadElementProperties(elementId)
            await preloadRelatedDocuments(elementId)

        case .navigatingToArea(let area):
            await preloadModelsInArea(area)
            await preloadIssuesInArea(area)

        case .measuringDistance:
            await prepareToolsUI()
        }
    }
}
```

### 5.4 Privacy and Consent

```swift
class EyeTrackingPrivacy {
    static var isAuthorized: Bool {
        // Check authorization status
        // visionOS handles this automatically
    }

    static func requestAuthorization() async -> Bool {
        // Request permission (if needed)
        // Explain use case to user
    }

    static func handleEyeDataPrivacy(gazeData: GazeData) -> GazeData {
        // Never store raw gaze data
        // Process in real-time only
        // Aggregate for analytics (no PII)
    }
}
```

**Privacy Guarantees:**
- No storage of raw eye tracking data
- Real-time processing only
- No transmission of gaze data off-device
- Aggregated analytics only (anonymous)
- User can disable eye tracking features

---

## 6. Spatial Audio Specifications

### 6.1 Audio Architecture

```swift
class SpatialAudioManager {
    private var audioEngine: AudioEngine
    private var environmentalAudio: EnvironmentalAudioContext

    func setupAudio() {
        // Configure spatial audio
        environmentalAudio = EnvironmentalAudioContext(
            reverbPreset: .outdoorOpen  // Construction site ambiance
        )
    }

    func playSpatialSound(_ sound: AudioResource,
                          at position: SIMD3<Float>,
                          configuration: AudioConfiguration) {
        let audioEntity = Entity()
        audioEntity.position = position
        audioEntity.spatialAudio = SpatialAudioComponent(
            directivity: configuration.directivity,
            intensity: configuration.intensity,
            distanceAttenuation: configuration.attenuation
        )
        audioEntity.playAudio(sound)
    }
}
```

### 6.2 Audio Use Cases

| Use Case | Audio Type | Spatialization | Priority |
|----------|------------|----------------|----------|
| **Safety Alerts** | Warning tone | High precision | Critical |
| **Worker Communication** | Voice | Directional | High |
| **Issue Notifications** | Notification sound | General direction | Medium |
| **Measurement Feedback** | Click/beep | Non-spatial | Low |
| **Ambient Site Sounds** | Construction noise | Environmental | Low |

### 6.3 Safety Alert Audio

```swift
struct SafetyAlertAudio {
    static func playAlert(_ severity: SafetySeverity,
                          at position: SIMD3<Float>) {
        let sound: AudioResource
        let volume: Float

        switch severity {
        case .critical:
            sound = .criticalAlert
            volume = 1.0
            // Also trigger haptic

        case .high:
            sound = .warningAlert
            volume = 0.8

        case .medium:
            sound = .cautionAlert
            volume = 0.6

        case .low:
            sound = .noticeAlert
            volume = 0.4
        }

        SpatialAudioManager.shared.playSpatialSound(
            sound,
            at: position,
            configuration: .alert(volume: volume)
        )
    }
}
```

### 6.4 Voice Communication

```swift
class VoiceCommuncationSystem {
    func enableSpatialVoice() async {
        // Enable voice chat between team members
        // Spatialized based on worker location
        // Noise cancellation for construction site
    }

    func broadcastMessage(_ message: String, to zone: Zone) async {
        // Text-to-speech for announcements
        // Spatialized to specific zone
        // "All workers in Zone A, crane operation starting"
    }

    func configureNoiseProfile(_ profile: NoiseProfile) {
        // Adapt to construction site noise
        // Enhance voice clarity
        // Reduce ambient construction sounds
    }
}
```

---

## 7. Accessibility Requirements

### 7.1 VoiceOver Support

```swift
// Accessibility labels for spatial elements
extension ModelEntity {
    func configureAccessibility(bimElement: BIMElement) {
        accessibilityLabel = bimElement.name
        accessibilityHint = "Double tap to inspect \(bimElement.ifcType)"
        accessibilityTraits = .button

        // Custom actions
        accessibilityCustomActions = [
            UIAccessibilityCustomAction(
                name: "Show Properties",
                target: self,
                selector: #selector(showProperties)
            ),
            UIAccessibilityCustomAction(
                name: "Toggle Visibility",
                target: self,
                selector: #selector(toggleVisibility)
            )
        ]
    }
}
```

**VoiceOver Implementation:**
- All interactive elements labeled
- Meaningful descriptions for 3D objects
- Custom actions for common operations
- Spatial audio cues for element location
- Gesture alternatives for all interactions

### 7.2 Dynamic Type

```swift
// Support Dynamic Type for text scaling
struct SiteInfoView: View {
    @Environment(\.dynamicTypeSize) var dynamicTypeSize

    var body: some View {
        VStack(alignment: .leading, spacing: spacing) {
            Text(site.name)
                .font(.title)  // Automatically scales

            Text(site.address)
                .font(.body)
        }
    }

    private var spacing: CGFloat {
        // Adjust spacing based on text size
        switch dynamicTypeSize {
        case .xSmall...regular: return 8
        case .large...xLarge: return 12
        case .xxLarge...xxxLarge: return 16
        default: return 20
        }
    }
}
```

**Dynamic Type Support:**
- All text respects user's text size preference
- Layout adapts to larger text
- Minimum size: accessibility size 1
- Maximum size: accessibility size 5

### 7.3 Reduce Motion

```swift
class MotionManager {
    @AppStorage("prefersReducedMotion") var prefersReducedMotion = false

    func animate(_ entity: Entity, to position: SIMD3<Float>) {
        if prefersReducedMotion {
            // Instant transition
            entity.position = position
        } else {
            // Smooth animation
            entity.move(to: Transform(translation: position),
                       relativeTo: nil,
                       duration: 0.3,
                       timingFunction: .easeInOut)
        }
    }
}
```

**Reduce Motion Features:**
- Disable animations when preferred
- Crossfade instead of movement
- Instant transitions option
- Respect system setting

### 7.4 Color and Contrast

```swift
enum AccessibleColor {
    static func statusColor(for status: ElementStatus,
                           in colorScheme: ColorScheme) -> Color {
        switch (status, colorScheme) {
        case (.completed, .light):
            return .green
        case (.completed, .dark):
            return Color(red: 0.2, green: 0.8, blue: 0.2)  // Brighter green

        case (.inProgress, .light):
            return .orange
        case (.inProgress, .dark):
            return Color(red: 1.0, green: 0.7, blue: 0.2)  // Brighter orange

        // Additional cases...
        }
    }
}
```

**Accessibility Color Requirements:**
- WCAG AA contrast ratio (4.5:1)
- Color blind friendly palette
- High contrast mode support
- Patterns in addition to colors

### 7.5 Alternative Input Methods

| Method | Support | Use Case |
|--------|---------|----------|
| **Voice Commands** | Full | Hands-free operation |
| **Switch Control** | Full | Single-switch navigation |
| **Dwell Control** | Full | Gaze-based selection |
| **Bluetooth Keyboard** | Full | Keyboard navigation |
| **Game Controller** | Partial | Navigation and selection |

---

## 8. Privacy and Security Requirements

### 8.1 Data Privacy

```swift
class PrivacyManager {
    // Worker location privacy
    func anonymizeWorkerLocation(_ location: WorkerTracking) -> AnonymousTracking {
        return AnonymousTracking(
            workerId: hashWorkerID(location.workerId),  // One-way hash
            trade: location.trade,
            zone: location.currentZone,  // Zone only, not precise location
            timestamp: location.lastUpdate.rounded(toNearest: .minutes(5))
        )
    }

    // Photo privacy
    func processSitePhoto(_ photo: PhotoReference) async -> ProcessedPhoto {
        // Blur faces automatically
        // Remove metadata with PII
        // Retain construction-relevant data only
    }

    // Data retention
    func enforceRetentionPolicy() async {
        // Delete location data older than 30 days
        // Archive progress photos after project completion
        // Maintain safety incident records per regulations
    }
}
```

**Privacy Principles:**
1. **Data Minimization**: Collect only necessary data
2. **Purpose Limitation**: Use data only for stated purposes
3. **Storage Limitation**: Delete data when no longer needed
4. **Transparency**: Clear privacy policy and notices
5. **User Control**: Users can access and delete their data

### 8.2 Security Implementation

```swift
// Authentication
class AuthenticationService {
    func authenticate(credentials: Credentials) async throws -> AuthToken {
        // OAuth 2.0 / OpenID Connect
        // Support enterprise SSO (SAML, Azure AD)
        // Multi-factor authentication
        // Biometric authentication (Face ID)
    }

    func refreshToken(_ token: AuthToken) async throws -> AuthToken {
        // Automatic token refresh
        // Secure token storage in Keychain
    }
}

// Encryption
class EncryptionService {
    func encryptSensitiveData(_ data: Data) throws -> Data {
        // AES-256-GCM encryption
        // Unique keys per site/project
        // Key derivation from user credentials
    }

    func encryptFileForStorage(_ fileURL: URL) throws {
        // File-level encryption for BIM models
        // Encrypted Core Data/SwiftData
    }
}

// Authorization
class AuthorizationService {
    func checkAccess(user: User, resource: Resource, action: Action) -> Bool {
        // Role-based access control (RBAC)
        // Site-specific permissions
        // Feature-level authorization
        // Time-based access (working hours only)
    }
}
```

**Security Layers:**

1. **Transport Security**
   - TLS 1.3 for all network communication
   - Certificate pinning for API calls
   - VPN support for enterprise deployments

2. **Data At Rest**
   - AES-256 encryption
   - Encrypted backups
   - Secure deletion

3. **Authentication**
   - OAuth 2.0 / OpenID Connect
   - Enterprise SSO integration
   - MFA support
   - Biometric authentication

4. **Authorization**
   - Role-based access control
   - Resource-level permissions
   - Audit logging

5. **Device Security**
   - Geofencing (data access only on-site)
   - Remote wipe capability
   - Device attestation

### 8.3 Compliance

| Regulation | Requirement | Implementation |
|------------|-------------|----------------|
| **GDPR** | Data privacy, right to erasure | Privacy manager, data export |
| **CCPA** | California privacy rights | Privacy policy, opt-out |
| **OSHA** | Safety data retention | 5-year incident record storage |
| **ISO 27001** | Information security | Security controls, audit trails |
| **SOC 2** | Trust service criteria | Security, availability, confidentiality |

---

## 9. Data Persistence Strategy

### 9.1 SwiftData Models

```swift
@Model
class PersistedSite {
    @Attribute(.unique) var id: UUID
    var name: String
    var lastAccessedDate: Date

    @Relationship(deleteRule: .cascade)
    var cachedModels: [CachedBIMModel]

    @Relationship(deleteRule: .cascade)
    var offlineProgress: [ProgressSnapshot]

    @Relationship(deleteRule: .cascade)
    var pendingIssues: [PendingIssue]
}

@Model
class CachedBIMModel {
    @Attribute(.unique) var id: UUID
    var modelData: Data  // Compressed BIM data
    var cacheDate: Date
    var sizeInBytes: Int64

    @Relationship(inverse: \PersistedSite.cachedModels)
    var site: PersistedSite
}
```

### 9.2 Storage Strategy

```swift
class StorageManager {
    private let modelContext: ModelContext
    private let maxCacheSize: Int64 = 10_000_000_000  // 10 GB

    // Three-tier storage
    func saveToCache(model: BIMModel) async throws {
        // Tier 1: Memory (active session)
        InMemoryCache.shared.store(model)

        // Tier 2: Device storage (7 days)
        let cachedModel = CachedBIMModel(from: model)
        modelContext.insert(cachedModel)
        try modelContext.save()

        // Tier 3: Cloud (permanent)
        try await CloudSync.shared.upload(model)
    }

    func enforceStorageLimits() async throws {
        let currentSize = try await calculateCacheSize()

        if currentSize > maxCacheSize {
            // Delete least recently used
            let modelsToDelete = try await findLRUModels(
                toFree: currentSize - maxCacheSize
            )

            for model in modelsToDelete {
                modelContext.delete(model)
            }

            try modelContext.save()
        }
    }
}
```

### 9.3 Sync Strategy

```swift
actor SyncEngine {
    private var isSyncing = false
    private var pendingChanges: [Change] = []

    func sync() async throws {
        guard !isSyncing else { return }
        isSyncing = true
        defer { isSyncing = false }

        // 1. Pull changes from cloud
        let remoteChanges = try await fetchRemoteChanges()

        // 2. Detect conflicts
        let conflicts = detectConflicts(
            local: pendingChanges,
            remote: remoteChanges
        )

        // 3. Resolve conflicts
        let resolved = try await resolveConflicts(conflicts)

        // 4. Apply remote changes
        try await applyChanges(resolved.remoteChanges)

        // 5. Push local changes
        try await pushChanges(resolved.localChanges)

        // 6. Clear pending
        pendingChanges.removeAll()
    }

    func resolveConflicts(_ conflicts: [Conflict]) async throws -> Resolution {
        // Conflict resolution strategies:
        // - Last-write-wins for most data
        // - Merge for compatible changes
        // - Manual resolution for critical conflicts
    }
}
```

---

## 10. Network Architecture

### 10.1 Network Layers

```
┌─────────────────────────────────────────┐
│         Application Layer               │
│  (Business logic makes requests)        │
└─────────────────────────────────────────┘
                  ↓
┌─────────────────────────────────────────┐
│         Service Layer                   │
│  (API clients, integration services)    │
└─────────────────────────────────────────┘
                  ↓
┌─────────────────────────────────────────┐
│         Network Layer                   │
│  (URLSession, WebSocket, caching)       │
└─────────────────────────────────────────┘
                  ↓
┌─────────────────────────────────────────┐
│         Transport Layer                 │
│  (TLS 1.3, HTTP/2, TCP/IP)             │
└─────────────────────────────────────────┘
```

### 10.2 API Communication

```swift
class NetworkClient {
    private let session: URLSession
    private let baseURL: URL

    init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 300
        configuration.waitsForConnectivity = true
        configuration.allowsCellularAccess = true
        configuration.httpMaximumConnectionsPerHost = 6

        // Request caching
        configuration.urlCache = URLCache(
            memoryCapacity: 50_000_000,    // 50 MB
            diskCapacity: 500_000_000       // 500 MB
        )
        configuration.requestCachePolicy = .returnCacheDataElseLoad

        self.session = URLSession(configuration: configuration)
    }

    func request<T: Decodable>(
        _ endpoint: Endpoint
    ) async throws -> T {
        var request = URLRequest(url: endpoint.url)
        request.httpMethod = endpoint.method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("gzip, deflate", forHTTPHeaderField: "Accept-Encoding")

        // Retry logic
        var lastError: Error?
        for attempt in 1...3 {
            do {
                let (data, response) = try await session.data(for: request)
                return try decode(data, response)
            } catch {
                lastError = error
                if attempt < 3 {
                    try await Task.sleep(nanoseconds: UInt64(pow(2.0, Double(attempt))) * 1_000_000_000)
                }
            }
        }

        throw lastError!
    }
}
```

### 10.3 Offline Support

```swift
class OfflineManager {
    @Published var isOnline = true
    private let reachability = NetworkReachability()

    func startMonitoring() {
        reachability.startMonitoring { [weak self] status in
            self?.isOnline = (status == .connected)

            if status == .connected {
                // Resume sync when back online
                Task {
                    try await SyncEngine.shared.sync()
                }
            }
        }
    }

    func queueOfflineAction(_ action: OfflineAction) {
        // Queue actions for later sync
        OfflineQueue.shared.enqueue(action)
    }
}

enum OfflineAction: Codable {
    case updateProgress(elementId: String, status: ElementStatus)
    case createIssue(issue: Issue)
    case addAnnotation(annotation: Annotation)
    case uploadPhoto(photo: PhotoReference)
}
```

### 10.4 Real-Time Communication

```swift
class WebSocketManager {
    private var webSocket: URLSessionWebSocketTask?

    func connect(to url: URL) async throws {
        let session = URLSession(configuration: .default)
        webSocket = session.webSocketTask(with: url)
        webSocket?.resume()

        // Listen for messages
        Task {
            while let webSocket = webSocket {
                let message = try await webSocket.receive()
                await handleMessage(message)
            }
        }
    }

    func send<T: Encodable>(_ message: T) async throws {
        let data = try JSONEncoder().encode(message)
        let message = URLSessionWebSocketTask.Message.data(data)
        try await webSocket?.send(message)
    }

    private func handleMessage(_ message: URLSessionWebSocketTask.Message) async {
        switch message {
        case .data(let data):
            // Handle binary message
            break
        case .string(let text):
            // Handle text message (JSON)
            if let update = try? JSONDecoder().decode(RealtimeUpdate.self, from: Data(text.utf8)) {
                await processUpdate(update)
            }
        @unknown default:
            break
        }
    }
}
```

---

## 11. Testing Requirements

### 11.1 Testing Strategy

```
Testing Pyramid:
       /\
      /UI\       10% - UI/Spatial Tests
     /────\
    /Integ.\     20% - Integration Tests
   /────────\
  /   Unit   \   70% - Unit Tests
 /────────────\
```

### 11.2 Unit Testing

```swift
@Test
class BIMImportTests {
    @Test("IFC file parsing")
    func testIFCParsing() async throws {
        let service = BIMImportService()
        let testFileURL = Bundle.module.url(forResource: "test", withExtension: "ifc")!

        let model = try await service.importIFC(from: testFileURL)

        #expect(model.elements.count == 150)
        #expect(model.format == .ifc)
        #expect(model.disciplines.contains(.structural))
    }

    @Test("Element property extraction")
    func testPropertyExtraction() async throws {
        let service = BIMImportService()
        let element = createTestElement()

        let properties = try await service.extractProperties(element)

        #expect(properties["Name"] != nil)
        #expect(properties["Material"] != nil)
    }
}

@Test
class SafetyMonitoringTests {
    @Test("Danger zone violation detection")
    func testDangerZoneViolation() async throws {
        let service = SafetyMonitoringService()
        let dangerZone = createTestDangerZone()
        let workerPosition = SIMD3<Float>(x: 0, y: 0, z: 0)  // Inside zone

        let violation = try await service.checkViolation(
            position: workerPosition,
            zone: dangerZone
        )

        #expect(violation != nil)
        #expect(violation?.severity == .high)
    }
}
```

### 11.3 Integration Testing

```swift
@Test
class SyncIntegrationTests {
    @Test("Offline to online sync")
    func testOfflineSync() async throws {
        // 1. Go offline
        NetworkSimulator.setOffline()

        // 2. Make changes
        let issue = createTestIssue()
        try await IssueStore.shared.createIssue(issue)

        #expect(OfflineQueue.shared.pendingCount == 1)

        // 3. Go online
        NetworkSimulator.setOnline()

        // 4. Wait for sync
        try await Task.sleep(nanoseconds: 2_000_000_000)

        // 5. Verify synced
        #expect(OfflineQueue.shared.pendingCount == 0)

        let synced = try await APIClient.shared.getIssue(issue.id)
        #expect(synced.title == issue.title)
    }
}
```

### 11.4 UI/Spatial Testing

```swift
@MainActor
class SpatialUITests: XCTestCase {
    func testAROverlayRendering() async throws {
        let scene = RealityViewContent()
        let bimModel = createTestBIMModel()

        // Add model to scene
        let entity = try await BIMRenderingService.shared.generateEntity(from: bimModel)
        scene.add(entity)

        // Verify entity rendered
        XCTAssertNotNil(scene.entities.first)
        XCTAssertEqual(scene.entities.count, 1)

        // Verify LOD component
        XCTAssertNotNil(entity.components[LODComponent.self])
    }

    func testHandGestureRecognition() async throws {
        let recognizer = CustomGestureRecognizer()
        let handPose = createMeasureGesturePose()

        let gesture = recognizer.recognizeGesture(handPose)

        XCTAssertEqual(gesture, .measure)
    }
}
```

### 11.5 Performance Testing

```swift
@Test
class PerformanceTests {
    @Test("BIM model rendering performance")
    func testRenderingPerformance() async throws {
        let model = createLargeBIMModel()  // 100,000 elements
        let renderer = BIMRenderingService.shared

        let metrics = try await measure {
            let entity = try await renderer.generateEntity(from: model)
            return entity
        }

        // Target: <30 seconds for 500MB model
        #expect(metrics.duration < 30.0)

        // Target: <11ms frame time (90 FPS)
        #expect(metrics.frameTime < 0.011)

        // Target: <6GB memory
        #expect(metrics.memoryUsage < 6_000_000_000)
    }
}
```

### 11.6 Test Coverage Requirements

| Component | Coverage Target | Priority |
|-----------|----------------|----------|
| **Data Models** | 90% | Critical |
| **Services** | 85% | Critical |
| **ViewModels** | 80% | High |
| **Views** | 60% | Medium |
| **Utilities** | 95% | High |

---

## 12. Performance Requirements

### 12.1 Performance Targets

| Metric | Target | Measurement | Critical Path |
|--------|--------|-------------|---------------|
| **Frame Rate** | 90 FPS sustained | Instruments | RealityKit rendering |
| **Frame Time** | <11ms | Instruments | Frame profiler |
| **BIM Load Time** | <30s for 500MB | Stopwatch | IFC parsing |
| **Memory Usage** | <6 GB active | Instruments | Asset management |
| **App Launch** | <3 seconds | Stopwatch | Cold start |
| **AR Tracking** | <20ms latency | ARKit metrics | World tracking |
| **Network Request** | <2s response | Network profiler | API calls |
| **Sync Time** | <10s for changes | Stopwatch | Differential sync |
| **Battery Life** | 8 hours continuous | Battery monitor | Active AR use |

### 12.2 Optimization Techniques

```swift
class PerformanceOptimizer {
    // Geometry optimization
    func optimizeGeometry(model: BIMModel) async -> OptimizedModel {
        // Merge similar geometries
        // Reduce polygon count
        // Generate LOD levels
        // Compress textures
    }

    // Memory optimization
    func manageMemoryPressure() {
        NotificationCenter.default.addObserver(
            forName: UIApplication.didReceiveMemoryWarningNotification,
            object: nil,
            queue: .main
        ) { _ in
            // Clear caches
            // Reduce LOD quality
            // Unload distant assets
        }
    }

    // Rendering optimization
    func optimizeRendering(scene: Scene) {
        // Frustum culling
        // Occlusion culling
        // Draw call batching
        // Texture atlas usage
    }
}
```

---

## 13. Development Configuration

### 13.1 Build Configurations

```swift
// Debug.xcconfig
SWIFT_OPTIMIZATION_LEVEL = -Onone
SWIFT_COMPILATION_MODE = singlefile
DEBUG_INFORMATION_FORMAT = dwarf-with-dsym
ENABLE_TESTABILITY = YES

// Release.xcconfig
SWIFT_OPTIMIZATION_LEVEL = -O
SWIFT_COMPILATION_MODE = wholemodule
DEBUG_INFORMATION_FORMAT = dwarf-with-dsym
ENABLE_TESTABILITY = NO
DEAD_CODE_STRIPPING = YES
```

### 13.2 Feature Flags

```swift
enum FeatureFlag: String {
    case aiProgressTracking
    case droneIntegration
    case voiceCommands
    case multiUserCollaboration
    case advancedSafety

    var isEnabled: Bool {
        #if DEBUG
        return true  // All features in debug
        #else
        return UserDefaults.standard.bool(forKey: "feature_\(rawValue)")
        #endif
    }
}
```

### 13.3 Logging Configuration

```swift
class Logger {
    static let shared = Logger()

    enum Level: String {
        case debug, info, warning, error, critical
    }

    func log(_ message: String,
             level: Level,
             category: String,
             file: String = #file,
             function: String = #function,
             line: Int = #line) {
        #if DEBUG
        print("[\(level.rawValue.uppercased())] [\(category)] \(message)")
        #else
        if level == .error || level == .critical {
            // Send to analytics/crash reporting
            AnalyticsService.shared.logError(message, level: level)
        }
        #endif
    }
}
```

---

## Appendices

### A. API Endpoints

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/api/v1/sites` | GET | List sites |
| `/api/v1/sites/{id}` | GET | Get site details |
| `/api/v1/sites/{id}/models` | GET | List BIM models |
| `/api/v1/models/{id}/download` | GET | Download BIM model |
| `/api/v1/sites/{id}/progress` | POST | Upload progress |
| `/api/v1/sites/{id}/issues` | GET/POST | Manage issues |
| `/api/v1/sites/{id}/safety/alerts` | GET | Get safety alerts |
| `/api/v1/sync` | POST | Sync all changes |

### B. File Formats

| Format | Extension | Use Case | Import/Export |
|--------|-----------|----------|---------------|
| **IFC** | .ifc | BIM models | Both |
| **RVT** | .rvt | Revit models | Import only |
| **DWG** | .dwg | CAD drawings | Import only |
| **USDZ** | .usdz | 3D visualization | Both |
| **JSON** | .json | Data exchange | Both |
| **PDF** | .pdf | Documentation | Import only |

### C. Error Codes

| Code | Category | Description |
|------|----------|-------------|
| 1000-1099 | Network | Connection, timeout, etc. |
| 2000-2099 | Authentication | Auth failures |
| 3000-3099 | Data | Parsing, validation errors |
| 4000-4099 | Spatial | AR tracking issues |
| 5000-5099 | System | Memory, storage issues |

---

## Document Version History

| Version | Date | Changes | Author |
|---------|------|---------|--------|
| 1.0 | 2025-01-20 | Initial technical specifications | Claude |

---

**End of Technical Specifications**
