# Legal Discovery Universe - Technical Specification

## 1. Technology Stack

### 1.1 Core Technologies

| Component | Technology | Version | Purpose |
|-----------|-----------|---------|---------|
| Language | Swift | 6.0+ | Primary development language with strict concurrency |
| UI Framework | SwiftUI | visionOS 2.0+ | Declarative UI and spatial layouts |
| 3D Engine | RealityKit | 2.0+ | 3D rendering and spatial computing |
| AR Framework | ARKit | 6.0+ | Spatial tracking and hand/eye tracking |
| Data Layer | SwiftData | visionOS 2.0+ | Local data persistence and modeling |
| Async | Swift Concurrency | Native | Async/await, actors, task groups |
| Networking | URLSession | Native | HTTP/HTTPS networking with modern async APIs |
| Security | CryptoKit | Native | Encryption, hashing, secure random |

### 1.2 Development Tools

| Tool | Version | Purpose |
|------|---------|---------|
| Xcode | 16.0+ | Primary IDE |
| Reality Composer Pro | 2.0+ | 3D content authoring |
| Instruments | Latest | Performance profiling |
| visionOS Simulator | 2.0+ | Testing and development |
| Swift Package Manager | Native | Dependency management |

### 1.3 Third-Party Dependencies

```swift
// Package.swift dependencies
dependencies: [
    // AI/ML
    .package(url: "https://github.com/apple/swift-transformers", from: "1.0.0"),

    // Testing
    .package(url: "https://github.com/Quick/Quick", from: "7.0.0"),
    .package(url: "https://github.com/Quick/Nimble", from: "13.0.0"),

    // Utilities
    .package(url: "https://github.com/apple/swift-algorithms", from: "1.0.0"),
    .package(url: "https://github.com/apple/swift-collections", from: "1.0.0")
]
```

## 2. visionOS Presentation Modes

### 2.1 WindowGroup Configuration

#### Main Discovery Workspace
```swift
WindowGroup("Discovery Workspace", id: "main-workspace") {
    ContentView()
        .environment(appState)
}
.defaultSize(width: 1200, height: 900)
.windowResizability(.contentSize)
.windowToolbar {
    ToolbarItemGroup(placement: .bottomOrnament) {
        DiscoveryToolbar()
    }
}
```

**Specifications**:
- Default size: 1200×900 points
- Minimum size: 800×600 points
- Resizable: Content-based
- Glass material background
- Bottom ornament for primary controls

#### Document Detail Window
```swift
WindowGroup("Document Detail", id: "document-detail", for: UUID.self) { $documentId in
    if let documentId {
        DocumentDetailView(documentId: documentId)
    }
}
.defaultSize(width: 900, height: 1200)
.windowResizability(.contentMinSize)
```

**Specifications**:
- Optimized for document reading
- Vertical orientation preferred
- Supports multiple instances
- Quick Look integration

### 2.2 Volumetric Windows

#### Evidence Universe Volume
```swift
WindowGroup("Evidence Universe", id: "evidence-universe") {
    EvidenceUniverseView()
        .environment(visualizationState)
}
.windowStyle(.volumetric)
.defaultSize(width: 1.5, height: 1.5, depth: 1.5, in: .meters)
.defaultWorldAlignment(.gravityAligned)
```

**Specifications**:
- Size: 1.5m × 1.5m × 1.5m
- Gravity-aligned by default
- Supports up to 10,000 visible entities
- LOD system for performance
- Interactive document nodes

#### Timeline Volume
```swift
WindowGroup("Timeline", id: "timeline-volume") {
    TimelineVolumeView()
}
.windowStyle(.volumetric)
.defaultSize(width: 2.0, height: 0.8, depth: 0.5, in: .meters)
```

**Specifications**:
- Horizontal layout: 2m wide
- Chronological flow left to right
- Event markers in 3D space
- Draggable timeline scrubber

#### Network Analysis Volume
```swift
WindowGroup("Network Analysis", id: "network-volume") {
    NetworkAnalysisView()
}
.windowStyle(.volumetric)
.defaultSize(width: 1.2, height: 1.2, depth: 1.2, in: .meters)
```

**Specifications**:
- Entity nodes connected by edges
- Force-directed graph layout
- Interactive node selection
- Dynamic edge highlighting

### 2.3 Immersive Spaces

#### Progressive Immersion
```swift
ImmersiveSpace(id: "case-investigation") {
    CaseInvestigationSpace()
}
.immersionStyle(selection: $immersionLevel, in: .progressive)
.upperLimbVisibility(.visible)
```

**Specifications**:
- Progressive immersion levels:
  - 0.0: Passthrough visible
  - 0.5: Partial immersion
  - 1.0: Full immersion
- User-controlled immersion slider
- Upper limbs always visible for interaction

#### Full Immersion Mode
```swift
ImmersiveSpace(id: "presentation-mode") {
    PresentationModeSpace()
}
.immersionStyle(selection: .constant(.full), in: .full)
.upperLimbVisibility(.hidden)
```

**Specifications**:
- Full immersion for presentations
- Optimized for courtroom/client demos
- Guided navigation mode
- Voice-controlled progression

## 3. Gesture and Interaction Specifications

### 3.1 Standard Gestures

#### Tap Gesture
```swift
.onTapGesture(count: 1) { location in
    // Single tap: Select document
    handleDocumentSelection(at: location)
}
.onTapGesture(count: 2) { location in
    // Double tap: Open document detail
    openDocumentDetail(at: location)
}
```

**Specifications**:
- Single tap: Selection with visual feedback
- Double tap: Open/expand action
- Minimum target size: 60pt (44pt accessible minimum)
- Debounce time: 300ms

#### Drag Gesture
```swift
.gesture(
    DragGesture(minimumDistance: 10)
        .targetedToAnyEntity()
        .onChanged { value in
            // Update entity position
            updateEntityPosition(value.convert(value.location3D, from: .local, to: .scene))
        }
        .onEnded { value in
            // Finalize position with physics
            finalizeEntityPosition(with: value.velocity)
        }
)
```

**Specifications**:
- Minimum distance: 10 points
- Real-time position updates
- Velocity-based momentum on release
- Snap to grid option for organization

#### Magnify Gesture
```swift
.gesture(
    MagnifyGesture()
        .targetedToEntity(documentEntity)
        .onChanged { value in
            scale = baseScale * value.magnification
        }
)
```

**Specifications**:
- Minimum scale: 0.5x
- Maximum scale: 3.0x
- Smooth scaling animation
- Scale persistence per entity

### 3.2 Custom Legal Discovery Gestures

#### Mark as Relevant (Thumbs Up)
```swift
func detectThumbsUpGesture(_ handAnchor: HandAnchor) -> Bool {
    let thumb = handAnchor.handSkeleton?.joint(.thumbTip)
    let index = handAnchor.handSkeleton?.joint(.indexFingerTip)

    // Thumb up, fingers curled
    return thumb?.position.y > index?.position.y &&
           isFingersCurled(handAnchor)
}
```

**Specifications**:
- Recognition confidence: >85%
- Hold time: 500ms
- Visual feedback: Green highlight
- Audio cue: Soft chime

#### Flag as Privileged (Shield Gesture)
```swift
func detectShieldGesture(_ handAnchors: [HandAnchor]) -> Bool {
    guard handAnchors.count == 2 else { return false }

    let leftHand = handAnchors[0]
    let rightHand = handAnchors[1]

    // Hands crossed at wrists, palms forward
    return areHandsCrossed(leftHand, rightHand) &&
           arePalmsForward(leftHand, rightHand)
}
```

**Specifications**:
- Two-handed gesture
- Recognition confidence: >90%
- Hold time: 750ms
- Visual feedback: Red shield overlay
- Confirmation dialog required

#### Connect Documents (Draw Line)
```swift
func detectConnectionGesture() -> (start: Entity?, end: Entity?) {
    // Point at first document, pinch, drag to second document
    if isPinching && isPointingAtEntity(startEntity) {
        if let endEntity = raycastToEntity() {
            return (startEntity, endEntity)
        }
    }
    return (nil, nil)
}
```

**Specifications**:
- Pinch and drag between entities
- Visual line preview during gesture
- Snap to entity center
- Connection type selector

## 4. Hand Tracking Implementation

### 4.1 Hand Tracking Setup

```swift
// Request hand tracking authorization
func setupHandTracking() async {
    let handTrackingProvider = HandTrackingProvider()

    do {
        try await handTrackingProvider.session.run([.handTracking])
    } catch {
        print("Hand tracking failed: \(error)")
    }
}
```

### 4.2 Hand Skeleton Access

```swift
// Access hand joints in real-time
func updateHandJoints(_ handAnchor: HandAnchor) {
    guard let handSkeleton = handAnchor.handSkeleton else { return }

    // Key joints for legal gestures
    let thumbTip = handSkeleton.joint(.thumbTip)
    let indexTip = handSkeleton.joint(.indexFingerTip)
    let wrist = handSkeleton.joint(.wrist)

    // Calculate pinch strength
    let pinchStrength = calculatePinchStrength(thumbTip, indexTip)

    // Update UI based on hand pose
    updateHandCursor(position: indexTip.position, strength: pinchStrength)
}
```

### 4.3 Hand Pose Recognition

```swift
struct HandPoseRecognizer {
    enum LegalGesture {
        case thumbsUp      // Mark relevant
        case shield        // Mark privileged
        case point         // Focus/select
        case pinch         // Grab/drag
        case openPalm      // Release/dismiss
    }

    func recognize(handAnchor: HandAnchor) -> LegalGesture? {
        guard let skeleton = handAnchor.handSkeleton else { return nil }

        if isThumbsUp(skeleton) { return .thumbsUp }
        if isShield(skeleton) { return .shield }
        if isPointing(skeleton) { return .point }
        if isPinching(skeleton) { return .pinch }
        if isOpenPalm(skeleton) { return .openPalm }

        return nil
    }
}
```

**Specifications**:
- Update frequency: 90 Hz
- Gesture confidence threshold: 85%
- Smoothing: 3-frame moving average
- Chirality detection: Automatic
- Occlusion handling: Predictive tracking

## 5. Eye Tracking Implementation

### 5.1 Eye Tracking Setup

```swift
// Request eye tracking permission
func setupEyeTracking() async {
    do {
        let permission = await ARKitSession.queryAuthorization(for: [.eyeTracking])

        if permission == .allowed {
            let eyeTrackingProvider = EyeTrackingProvider()
            try await eyeTrackingProvider.session.run([.eyeTracking])
        }
    } catch {
        print("Eye tracking unavailable: \(error)")
    }
}
```

### 5.2 Gaze-Based Interactions

```swift
// Detect what user is looking at
func handleGazeUpdate(_ gazeAnchor: GazeAnchor) {
    let gazeOrigin = gazeAnchor.originFromAnchorTransform.position
    let gazeDirection = gazeAnchor.direction

    // Raycast to find focused entity
    if let hitEntity = performRaycast(from: gazeOrigin, direction: gazeDirection) {
        // Apply hover state
        applyHoverEffect(to: hitEntity)

        // Track dwell time for auto-select
        updateDwellTime(for: hitEntity)

        // Update reading position for documents
        if let document = documentEntity(hitEntity) {
            updateReadingPosition(document, gazePosition: gazeDirection)
        }
    }
}
```

### 5.3 Attention-Based Features

```swift
struct AttentionTracker {
    // Track reading patterns
    func trackDocumentAttention(_ document: Document, gazeData: [GazePoint]) {
        let heatmap = generateAttentionHeatmap(gazeData)

        // Identify key passages
        let keyPassages = identifyFocusAreas(heatmap)

        // Auto-highlight important sections
        highlightSections(keyPassages, in: document)

        // Log for later review
        saveAttentionData(document.id, heatmap: heatmap)
    }

    // Dwell-time selection
    func dwellTimeSelection(entity: Entity, duration: TimeInterval) {
        if duration > 1.5 {
            // Auto-select after 1.5s of continuous gaze
            selectEntity(entity)
        }
    }
}
```

**Specifications**:
- Update frequency: 120 Hz (if available)
- Dwell time for selection: 1.5 seconds
- Hover activation: 300ms
- Reading comfort zone: 0.5-1.0 meters
- Eye strain prevention: Auto-dim after 45 minutes

## 6. Spatial Audio Specifications

### 6.1 Audio Zones

```swift
// Configure spatial audio for different areas
func setupAudioZones() {
    // Notification sounds
    let notificationAudio = AudioFileResource(
        named: "notification",
        configuration: .init(shouldLoop: false)
    )

    // Position audio at notification source
    let audioEntity = Entity()
    audioEntity.position = notificationPosition
    audioEntity.components[SpatialAudioComponent.self] = SpatialAudioComponent(
        resource: notificationAudio,
        spatialSettings: .init(
            directivity: .beam(focus: 0.7),
            distanceAttenuation: .linear(maximumDistance: 5.0)
        )
    )
}
```

### 6.2 Audio Feedback Types

| Event | Sound | Spatial | Duration |
|-------|-------|---------|----------|
| Document select | Soft click | Entity position | 100ms |
| Relevant tag | Success chime | Entity position | 300ms |
| Privilege flag | Alert tone | Entity position | 500ms |
| Connection created | Link sound | Between entities | 400ms |
| Search complete | Completion tone | User position | 250ms |
| Error | Warning tone | User position | 600ms |

### 6.3 Audio Implementation

```swift
struct AudioFeedbackSystem {
    let audioEngine = AVAudioEngine()
    let spatialEnvironment = AVAudioEnvironmentNode()

    func playSpatialSound(_ sound: AudioResource, at position: SIMD3<Float>) {
        let audioSource = AVAudioPlayerNode()
        audioEngine.attach(audioSource)

        // Configure spatial mixing
        audioEngine.connect(
            audioSource,
            to: spatialEnvironment,
            format: sound.audioFormat
        )

        // Set 3D position
        spatialEnvironment.position = AVAudio3DPoint(
            x: position.x,
            y: position.y,
            z: position.z
        )

        // Play
        audioSource.scheduleBuffer(sound.buffer, at: nil)
        audioSource.play()
    }
}
```

**Specifications**:
- Sample rate: 48kHz
- Bit depth: 24-bit
- Format: AAC or ALAC
- Spatial rendering: HRTF-based
- Maximum simultaneous sources: 32
- Reverb: Room-aware environmental

## 7. Accessibility Requirements

### 7.1 VoiceOver Support

```swift
// Accessible 3D entities
func makeEntityAccessible(_ entity: Entity, label: String, hint: String? = nil) {
    entity.accessibility = AccessibilityComponent(
        label: label,
        value: nil,
        hint: hint,
        traits: [.button]
    )

    entity.components[AccessibilityComponent.self]?.isAccessibilityElement = true
}

// Example usage
makeEntityAccessible(
    documentEntity,
    label: "Email from John Smith to Jane Doe, dated March 15th, 2024",
    hint: "Double tap to open document"
)
```

**VoiceOver Specifications**:
- All interactive elements must have labels
- Spatial position announced: "Document at 10 o'clock, 2 meters"
- State changes announced: "Marked as relevant"
- Custom rotor for document navigation
- Gesture alternatives for all actions

### 7.2 Dynamic Type

```swift
// Support dynamic type in 3D space
@Environment(\.dynamicTypeSize) var dynamicTypeSize

var scaledFontSize: CGFloat {
    switch dynamicTypeSize {
    case .xSmall: return 12
    case .small: return 14
    case .medium: return 16
    case .large: return 18
    case .xLarge: return 20
    case .xxLarge: return 24
    case .xxxLarge: return 28
    default: return 16
    }
}

// Apply to 3D text
Text3D(content: document.title)
    .font(.system(size: scaledFontSize, weight: .semibold))
    .foregroundStyle(.primary)
```

**Dynamic Type Specifications**:
- Support all system text sizes (xSmall to xxxLarge)
- 3D text scales proportionally
- Minimum readable size: 14pt
- Maximum size: No artificial limit
- Layout adjusts for larger text

### 7.3 Reduce Motion

```swift
@Environment(\.accessibilityReduceMotion) var reduceMotion

func animateDocumentEntry(_ entity: Entity) {
    if reduceMotion {
        // Simple fade in
        entity.opacity = 0
        entity.fadeIn(duration: 0.2)
    } else {
        // Full animation with movement
        entity.opacity = 0
        entity.position.y -= 0.5

        entity.animate(duration: 0.6, curve: .easeOut) {
            entity.opacity = 1
            entity.position.y += 0.5
        }
    }
}
```

**Reduce Motion Specifications**:
- Disable non-essential animations
- Replace motion with fades
- Maintain spatial relationships without movement
- User preference respected system-wide

### 7.4 Alternative Interaction Methods

```swift
// Keyboard shortcuts for Vision Pro keyboard
struct KeyboardShortcuts {
    static let selectDocument = KeyEquivalent("s", modifiers: .command)
    static let markRelevant = KeyEquivalent("r", modifiers: .command)
    static let markPrivileged = KeyEquivalent("p", modifiers: .command)
    static let search = KeyEquivalent("f", modifiers: .command)
    static let closeWindow = KeyEquivalent("w", modifiers: .command)
}

// Voice commands
struct VoiceCommands {
    let commands = [
        "Select document",
        "Mark as relevant",
        "Mark as privileged",
        "Show timeline",
        "Search documents",
        "Open next document",
        "Go back"
    ]
}
```

## 8. Privacy and Security Requirements

### 8.1 Data Encryption

```swift
// Document encryption at rest
class DocumentEncryptionManager {
    private let keySize = 256 // AES-256

    func encryptDocument(_ document: Document) throws -> Data {
        // Generate random key for this document
        let key = SymmetricKey(size: .bits256)

        // Encrypt content
        let sealedBox = try AES.GCM.seal(
            document.content.data(using: .utf8)!,
            using: key
        )

        // Store encrypted key in Keychain
        try storeKey(key, forDocument: document.id)

        return sealedBox.combined!
    }

    func decryptDocument(_ encryptedData: Data, documentId: UUID) throws -> String {
        // Retrieve key from Keychain
        let key = try retrieveKey(forDocument: documentId)

        // Decrypt
        let sealedBox = try AES.GCM.SealedBox(combined: encryptedData)
        let decryptedData = try AES.GCM.open(sealedBox, using: key)

        return String(data: decryptedData, encoding: .utf8)!
    }
}
```

### 8.2 Network Security

```swift
// TLS 1.3 configuration
class SecureNetworkManager {
    private let session: URLSession

    init() {
        let configuration = URLSessionConfiguration.default
        configuration.tlsMinimumSupportedProtocolVersion = .TLSv13
        configuration.tlsMaximumSupportedProtocolVersion = .TLSv13

        // Certificate pinning
        configuration.urlCredentialStorage = nil

        self.session = URLSession(
            configuration: configuration,
            delegate: CertificatePinningDelegate(),
            delegateQueue: nil
        )
    }
}

// Certificate pinning
class CertificatePinningDelegate: NSObject, URLSessionDelegate {
    let pinnedCertificates: [SecCertificate] = [] // Load from bundle

    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge
    ) async -> (URLSession.AuthChallengeDisposition, URLCredential?) {
        // Verify certificate against pinned certificates
        // Implementation details...
        return (.useCredential, credential)
    }
}
```

### 8.3 Audit Logging

```swift
// Comprehensive audit trail
struct AuditEvent: Codable {
    let id: UUID
    let timestamp: Date
    let userId: UUID
    let action: AuditAction
    let resourceId: UUID?
    let resourceType: ResourceType?
    let metadata: [String: String]
    let ipAddress: String?
    let deviceId: String
}

enum AuditAction: String, Codable {
    case documentViewed
    case documentMarkedRelevant
    case documentMarkedPrivileged
    case documentExported
    case searchPerformed
    case caseCreated
    case caseAccessed
    case userLogin
    case userLogout
    case settingsChanged
}

class AuditLogger {
    func log(_ action: AuditAction, resource: Resource? = nil) async {
        let event = AuditEvent(
            id: UUID(),
            timestamp: Date(),
            userId: currentUser.id,
            action: action,
            resourceId: resource?.id,
            resourceType: resource?.type,
            metadata: gatherMetadata(),
            ipAddress: getIPAddress(),
            deviceId: getDeviceId()
        )

        // Store encrypted in local DB
        try? await storeAuditEvent(event)

        // Send to secure backend
        try? await sendToAuditServer(event)
    }
}
```

**Security Specifications**:
- Encryption: AES-256-GCM
- Key storage: Secure Enclave
- Network: TLS 1.3 only
- Certificate pinning: Required
- Audit retention: 7 years minimum
- PII redaction: Automatic
- Biometric auth: Required for sensitive actions

## 9. Data Persistence Strategy

### 9.1 SwiftData Schema

```swift
// SwiftData model container
@MainActor
class DataManager {
    static let shared = DataManager()

    let modelContainer: ModelContainer
    let modelContext: ModelContext

    init() {
        let schema = Schema([
            LegalCase.self,
            Document.self,
            Entity.self,
            Timeline.self,
            Tag.self,
            Annotation.self,
            AuditEvent.self
        ])

        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            allowsSave: true,
            cloudKitDatabase: .none // Local only for security
        )

        self.modelContainer = try! ModelContainer(
            for: schema,
            configurations: [configuration]
        )

        self.modelContext = ModelContext(modelContainer)
    }
}
```

### 9.2 Indexing Strategy

```swift
// Optimize queries with indexes
@Model
class Document {
    @Attribute(.unique) var id: UUID

    // Indexed fields for fast search
    @Attribute(.indexed) var fileName: String
    @Attribute(.indexed) var documentDate: Date?
    @Attribute(.indexed) var relevanceScore: Double
    @Attribute(.indexed) var privilegeStatus: PrivilegeStatus

    // Full-text search index
    @Attribute(.fullTextSearch) var extractedText: String

    // Composite index for common queries
    @Attribute(.compositeIndex(["relevanceScore", "documentDate"]))
    var compositeKey: String { "\(relevanceScore)_\(documentDate?.timeIntervalSince1970 ?? 0)" }
}
```

### 9.3 Caching Strategy

```swift
// Multi-tier caching
actor CacheManager {
    // Memory cache (L1)
    private var memoryCache: [UUID: Document] = [:]
    private let maxMemoryCacheSize = 100

    // Disk cache (L2)
    private let diskCache: NSCache<NSUUID, NSData>

    // Database (L3)
    private let database: ModelContext

    func getDocument(id: UUID) async throws -> Document {
        // L1: Check memory
        if let cached = memoryCache[id] {
            return cached
        }

        // L2: Check disk cache
        if let diskData = diskCache.object(forKey: id as NSUUID),
           let document = try? JSONDecoder().decode(Document.self, from: diskData as Data) {
            memoryCache[id] = document
            return document
        }

        // L3: Load from database
        let document = try await loadFromDatabase(id)

        // Populate caches
        memoryCache[id] = document
        if let encoded = try? JSONEncoder().encode(document) {
            diskCache.setObject(encoded as NSData, forKey: id as NSUUID)
        }

        return document
    }
}
```

**Persistence Specifications**:
- Database: SwiftData with SQLite backend
- Encryption: File-level encryption via Data Protection
- Indexes: Strategic indexing for performance
- Cache sizes:
  - L1 (Memory): 100 documents
  - L2 (Disk): 1000 documents
  - L3 (Database): Unlimited
- Backup: Encrypted local backups
- Sync: Manual export/import only (no cloud)

## 10. Network Architecture

### 10.1 API Client

```swift
// RESTful API client
actor APIClient {
    private let session: URLSession
    private let baseURL = URL(string: "https://api.discovery.legal/v1")!

    func request<T: Decodable>(
        _ endpoint: Endpoint,
        method: HTTPMethod = .get,
        body: Encodable? = nil
    ) async throws -> T {
        var request = URLRequest(url: baseURL.appendingPathComponent(endpoint.path))
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Add authentication token
        if let token = await getAuthToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        // Encode body
        if let body {
            request.httpBody = try JSONEncoder().encode(body)
        }

        // Execute request
        let (data, response) = try await session.data(for: request)

        // Validate response
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw APIError.invalidResponse
        }

        // Decode response
        return try JSONDecoder().decode(T.self, from: data)
    }
}
```

### 10.2 Endpoint Definitions

```swift
enum Endpoint {
    case uploadDocuments
    case syncCase(UUID)
    case searchDocuments
    case analyzeDocument(UUID)
    case getPrivilegeReport

    var path: String {
        switch self {
        case .uploadDocuments: return "/documents/upload"
        case .syncCase(let id): return "/cases/\(id)/sync"
        case .searchDocuments: return "/documents/search"
        case .analyzeDocument(let id): return "/documents/\(id)/analyze"
        case .getPrivilegeReport: return "/reports/privilege"
        }
    }
}
```

### 10.3 Offline Support

```swift
// Operation queue for offline actions
actor OfflineOperationQueue {
    private var pendingOperations: [Operation] = []

    func enqueue(_ operation: Operation) {
        pendingOperations.append(operation)
        Task { await syncIfPossible() }
    }

    func syncIfPossible() async {
        guard isNetworkAvailable() else { return }

        for operation in pendingOperations {
            do {
                try await operation.execute()
                operation.status = .completed
            } catch {
                operation.status = .failed(error)
            }
        }

        // Remove completed operations
        pendingOperations.removeAll { $0.status.isCompleted }
    }
}
```

**Network Specifications**:
- Protocol: HTTPS (TLS 1.3)
- Format: JSON
- Authentication: JWT Bearer tokens
- Timeout: 30 seconds
- Retry policy: Exponential backoff (3 retries)
- Offline mode: Full read, queued writes
- Bandwidth: Optimized for limited connections

## 11. Testing Requirements

### 11.1 Unit Testing

```swift
// Example unit tests
@Test("Document relevance scoring")
func testRelevanceScoring() async throws {
    let document = Document(
        fileName: "test.pdf",
        extractedText: "This is a test document about the case"
    )

    let score = await aiService.analyzeRelevance(document)

    #expect(score >= 0.0 && score <= 1.0)
}

@Test("Privilege detection accuracy")
func testPrivilegeDetection() async throws {
    let privilegedDoc = Document(
        extractedText: "Attorney-client privileged communication..."
    )

    let status = await aiService.detectPrivilege(privilegedDoc)

    #expect(status == .attorneyClient)
}
```

**Unit Test Specifications**:
- Framework: Swift Testing (new framework)
- Coverage target: >80%
- Test categories:
  - Data models
  - Business logic
  - Utilities
  - AI services
- Execution: Parallel where possible
- Mocking: Protocol-based dependency injection

### 11.2 UI Testing

```swift
// Spatial UI tests
@MainActor
@Test("Document selection in 3D space")
func testDocumentSelection() async throws {
    let app = XCUIApplication()
    app.launch()

    // Navigate to Evidence Universe
    app.buttons["Evidence Universe"].tap()

    // Wait for 3D content to load
    try await Task.sleep(for: .seconds(2))

    // Simulate tap on document entity
    let documentEntity = app.otherElements["Document_123"]
    #expect(documentEntity.exists)

    documentEntity.tap()

    // Verify selection state
    #expect(documentEntity.value(forKey: "selected") as? Bool == true)
}
```

**UI Test Specifications**:
- Framework: XCUITest
- Coverage target: Critical flows >90%
- Test categories:
  - Navigation
  - Document interaction
  - Spatial gestures
  - Accessibility
- Execution: Sequential (UI tests)
- Simulator: visionOS Simulator

### 11.3 Performance Testing

```swift
// Performance benchmarks
@Test(.performance)
func testDocumentSearchPerformance() async {
    measure {
        await searchService.search(query: "contract")
    }

    // Should complete in <500ms
}

@Test(.performance)
func testRenderingPerformance() async {
    let documents = generateTestDocuments(count: 10000)

    measure {
        await visualizationService.renderDocumentGalaxy(documents)
    }

    // Should maintain >90 FPS
}
```

**Performance Test Specifications**:
- Tool: XCTest Metrics
- Metrics tracked:
  - FPS (target: 90+)
  - Memory usage (target: <2GB)
  - CPU usage (target: <60%)
  - Network latency (target: <500ms)
  - Search speed (target: <500ms)
- Profiling: Instruments for detailed analysis

### 11.4 Integration Testing

```swift
// End-to-end integration tests
@Test("Complete document workflow")
func testDocumentWorkflow() async throws {
    // 1. Import document
    let url = Bundle.module.url(forResource: "test", withExtension: "pdf")!
    let documents = try await documentService.importDocuments(from: [url])

    // 2. Analyze with AI
    let analysis = try await aiService.analyzeDocument(documents[0])
    #expect(analysis.relevanceScore > 0)

    // 3. Store in database
    try await database.save(documents[0])

    // 4. Search and retrieve
    let results = try await searchService.search(query: documents[0].fileName)
    #expect(results.contains(where: { $0.id == documents[0].id }))

    // 5. Export
    let exportURL = try await documentService.exportDocuments([documents[0]], format: .pdf)
    #expect(FileManager.default.fileExists(atPath: exportURL.path))
}
```

**Integration Test Specifications**:
- Framework: XCTest
- Coverage: All major workflows
- Test categories:
  - Document lifecycle
  - AI pipeline
  - Data sync
  - Export/import
- Execution: Sequential
- Test data: Realistic samples

---

**Document Version**: 1.0
**Last Updated**: 2025-11-17
**Status**: Initial Technical Specification
