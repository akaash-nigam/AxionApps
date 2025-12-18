# Spatial HCM - Technical Specifications

## Table of Contents
1. [Technology Stack](#technology-stack)
2. [visionOS Presentation Modes](#visionos-presentation-modes)
3. [Gesture & Interaction Specifications](#gesture--interaction-specifications)
4. [Hand Tracking Implementation](#hand-tracking-implementation)
5. [Eye Tracking Implementation](#eye-tracking-implementation)
6. [Spatial Audio Specifications](#spatial-audio-specifications)
7. [Accessibility Requirements](#accessibility-requirements)
8. [Privacy & Security Requirements](#privacy--security-requirements)
9. [Data Persistence Strategy](#data-persistence-strategy)
10. [Network Architecture](#network-architecture)
11. [Testing Requirements](#testing-requirements)
12. [Performance Specifications](#performance-specifications)

---

## Technology Stack

### Core Technologies

#### Swift & SwiftUI
- **Swift Version**: 6.0+
- **Language Features**:
  - Strict concurrency (`@Sendable`, `actor`, `async/await`)
  - Observation framework (`@Observable`)
  - Macros for code generation
  - Result builders for DSLs
  - Property wrappers

- **SwiftUI Version**: Latest (visionOS 2.0+)
- **Key Patterns**:
  - MVVM architecture
  - Unidirectional data flow
  - Compositional view hierarchy
  - Environment-based dependency injection

```swift
// Modern Swift Concurrency Example
@Observable
final class EmployeeViewModel {
    private let service: HRDataService
    var employees: [Employee] = []
    var isLoading = false

    init(service: HRDataService) {
        self.service = service
    }

    @MainActor
    func loadEmployees() async {
        isLoading = true
        defer { isLoading = false }

        do {
            employees = try await service.fetchEmployees()
        } catch {
            // Handle error
        }
    }
}
```

#### RealityKit 4.0
- **Features Used**:
  - Entity Component System (ECS)
  - Custom components and systems
  - Physics simulation
  - Particle effects
  - Material shaders
  - Anchoring and world tracking

- **3D Asset Pipeline**:
  - Reality Composer Pro for scene authoring
  - USD/USDZ format for models
  - PBR materials with metallic-roughness workflow
  - Texture atlasing for performance

```swift
// RealityKit Component Example
struct EmployeeNodeComponent: Component {
    var employeeId: UUID
    var performance: Float // 0-1
    var engagement: Float // 0-1
    var isHighlighted: Bool = false
}

// System Example
class EmployeeVisualizationSystem: System {
    static let query = EntityQuery(where: .has(EmployeeNodeComponent.self))

    func update(context: SceneUpdateContext) {
        context.scene.performQuery(Self.query).forEach { entity in
            guard var component = entity.components[EmployeeNodeComponent.self] else { return }

            // Update visual representation based on data
            updateMaterialForPerformance(entity, performance: component.performance)
        }
    }
}
```

#### ARKit
- **Capabilities**:
  - World tracking
  - Plane detection (for anchoring UI)
  - Hand tracking (skeleton detection)
  - Eye tracking
  - Scene reconstruction

#### visionOS 2.0+ APIs
- **Window Management**: WindowGroup, Window
- **Volumetric Content**: volumetric window style
- **Immersive Spaces**: ImmersiveSpace, immersionStyle
- **Spatial Input**: SpatialEventGesture, SpatialTapGesture
- **SharePlay**: GroupActivities framework

### Supporting Technologies

#### Networking
- **HTTP Client**: URLSession with async/await
- **WebSocket**: URLSessionWebSocketTask for real-time updates
- **GraphQL Client**: Apollo iOS (optional)
- **Network Monitoring**: NWPathMonitor for connectivity

```swift
actor NetworkClient {
    private let session: URLSession

    func fetch<T: Decodable>(
        _ endpoint: Endpoint,
        as type: T.Type
    ) async throws -> T {
        let request = try endpoint.asURLRequest()
        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.invalidResponse
        }

        return try JSONDecoder().decode(T.self, from: data)
    }
}
```

#### Data Persistence
- **SwiftData**: Primary persistence framework
- **CloudKit**: Optional cloud sync
- **FileManager**: Asset and media storage
- **UserDefaults**: User preferences
- **Keychain**: Secure credential storage

#### AI/ML
- **Core ML**: On-device ML model inference
- **Create ML**: Model training and optimization
- **Natural Language**: Text analysis and NLP
- **Vision Framework**: Image analysis (for employee photos)

```swift
class AttritionPredictionModel {
    private let model: MLModel

    init() throws {
        let config = MLModelConfiguration()
        config.computeUnits = .all
        self.model = try AttritionPredictor(configuration: config).model
    }

    func predict(features: EmployeeFeatures) async throws -> Double {
        let input = try MLDictionaryFeatureProvider(dictionary: features.asDictionary())
        let prediction = try await model.prediction(from: input)
        return prediction.featureValue(for: "flightRisk")?.doubleValue ?? 0
    }
}
```

#### Authentication
- **Authentication Services**: ASAuthorizationController
- **Local Authentication**: LAContext for biometrics
- **SSO Integration**: SAML 2.0, OAuth 2.0

#### Monitoring & Analytics
- **Logging**: OSLog with structured logging
- **Performance**: MetricKit for performance metrics
- **Crash Reporting**: Integration with third-party (Sentry, Crashlytics)
- **Analytics**: Custom telemetry service

---

## visionOS Presentation Modes

### 1. WindowGroup (2D Floating Windows)

#### Use Cases
- Employee profile details
- Performance review forms
- Settings and configuration
- Data entry forms
- Reports and exports

#### Configuration
```swift
WindowGroup(id: "employee-profile") {
    EmployeeProfileView()
        .environment(\.appState, appState)
}
.defaultSize(width: 600, height: 800)
.windowResizability(.contentSize)
```

#### Specifications
- **Default Size**: 600x800 points
- **Minimum Size**: 400x500 points
- **Maximum Size**: 1200x1600 points
- **Positioning**: System-managed, user-adjustable
- **Materials**: Glass background with vibrancy
- **Depth**: Shallow (< 0.1m)

### 2. Volumetric Windows (3D Bounded Spaces)

#### Use Cases
- Organizational chart sphere
- Team cluster visualization
- Individual career path 3D model
- Skill competency radar
- Performance holograph

#### Configuration
```swift
WindowGroup(id: "org-chart-volume") {
    OrganizationalChartVolumeView()
}
.windowStyle(.volumetric)
.defaultSize(width: 1.0, height: 1.0, depth: 1.0, in: .meters)
```

#### Specifications
- **Default Volume**: 1m³ (1x1x1 meters)
- **Minimum Volume**: 0.5m³
- **Maximum Volume**: 2m³
- **Content**: RealityKit scenes
- **Interaction**: Direct manipulation, gestures
- **Multiple Instances**: Up to 5 concurrent volumes

#### 3D Content Organization
```
Volume Layout (1m³)
├── Center (0,0,0): Focal point (CEO/Department Head)
├── Inner Ring (0.3m radius): Leadership team
├── Middle Ring (0.5m radius): Managers
└── Outer Ring (0.7m radius): Team members
```

### 3. ImmersiveSpace (Full Immersion)

#### Use Cases
- Organizational galaxy exploration
- Talent landscape navigation
- Culture climate visualization
- Strategic workforce planning
- Career pathway network

#### Configuration
```swift
ImmersiveSpace(id: "talent-galaxy") {
    TalentGalaxyView()
}
.immersionStyle(selection: $immersionLevel, in: .mixed, .progressive, .full)
.upperLimbVisibility(.hidden) // Optional: hide user's hands in full immersion
```

#### Immersion Levels

**Mixed** (Default)
- Spatial content blended with passthrough
- Best for: Quick exploration, maintaining awareness
- Use: Initial entry, collaborative sessions

**Progressive**
- Gradually reduces passthrough based on engagement
- Best for: Deep exploration, focused analysis
- Use: Data exploration, pattern finding

**Full**
- Complete immersion, no passthrough
- Best for: Strategic planning, complex visualization
- Use: Long-term planning sessions, executive reviews

#### Specifications
- **Space Dimensions**: Unbounded (user's physical space)
- **Content Range**: 0.5m to 10m from user
- **Optimal Zone**: 1.5m - 3m
- **Performance Target**: 90 FPS minimum
- **Transition**: 1-second fade animation

---

## Gesture & Interaction Specifications

### Primary Interaction Methods

#### 1. Gaze + Tap (Indirect Pinch)
**Most Common Interaction**

```swift
// Implementation
Text("Employee Name")
    .onTapGesture {
        selectEmployee()
    }
    .hoverEffect() // Subtle highlight on gaze
```

**Specifications**:
- **Target Size**: Minimum 60x60 points (44x44 for text)
- **Hover Feedback**: 100ms delay, subtle scale/glow
- **Tap Recognition**: 200ms duration max
- **Double Tap**: 300ms between taps
- **Visual Feedback**: Immediate (< 16ms)

#### 2. Direct Touch (Hand Tracking)
**For 3D Objects in Space**

```swift
// RealityKit Entity with collision
entity.components.set(CollisionComponent(
    shapes: [.generateSphere(radius: 0.05)],
    mode: .trigger
))

entity.components.set(InputTargetComponent())

// Handle gesture
let subscription = content.subscribe(to: CollisionEvents.Began.self) { event in
    handleEmployeeNodeTap(event.entityA)
}
```

**Specifications**:
- **Minimum Entity Size**: 4cm diameter
- **Touch Detection Range**: 0.3m - 2m from user
- **Hover Distance**: 2cm from surface
- **Haptic Feedback**: Light tap on contact (via spatial audio)

#### 3. Drag Gestures

```swift
// 2D Drag (Window)
.gesture(
    DragGesture()
        .onChanged { value in
            updatePosition(value.translation)
        }
        .onEnded { value in
            finalizePosition(value.translation)
        }
)

// 3D Drag (Spatial)
.gesture(
    DragGesture()
        .targetedToAnyEntity()
        .onChanged { value in
            let entity = value.entity
            entity.position = convertToWorldSpace(value.location3D)
        }
)
```

**Specifications**:
- **Activation Distance**: 10 points (2D), 2cm (3D)
- **Update Frequency**: 60 Hz minimum
- **Momentum**: Enabled for natural feel
- **Constraints**: Optional axis locking, boundaries

#### 4. Pinch & Zoom

```swift
.gesture(
    MagnificationGesture()
        .onChanged { value in
            scale = value.magnitude
        }
)
```

**Specifications**:
- **Minimum Scale**: 0.5x
- **Maximum Scale**: 3.0x
- **Gesture Recognition**: Simultaneous two-hand pinch
- **Smooth Scaling**: Exponential easing

#### 5. Rotation Gestures

```swift
.gesture(
    RotateGesture3D()
        .onChanged { value in
            entity.orientation = value.rotation
        }
)
```

**Specifications**:
- **Axes**: Full 3-axis rotation
- **Sensitivity**: 1:1 hand rotation to object rotation
- **Constraints**: Optional axis locking
- **Damping**: 0.1 for smooth rotation

### Custom Spatial Gestures

#### Organizational Chart Navigation
```swift
// "Zoom In" gesture: Two hands moving apart
struct OrgChartZoomGesture: UIGestureRecognizer {
    var onZoomIn: (() -> Void)?
    var onZoomOut: (() -> Void)?
}

// "Fly Through" navigation: Hand pointing direction
struct FlyThroughGesture: UIGestureRecognizer {
    var onNavigate: ((SIMD3<Float>) -> Void)?
}
```

#### Employee Selection
- **Single Tap**: Select employee, show details
- **Double Tap**: Open full profile window
- **Long Press**: Show context menu
- **Swipe Left**: View previous employee
- **Swipe Right**: View next employee

#### Team Manipulation
- **Pinch Multiple Nodes**: Group selection
- **Drag Group**: Move entire team
- **Spread Hands**: Expand team view
- **Bring Hands Together**: Collapse team view

---

## Hand Tracking Implementation

### ARKit Hand Tracking

```swift
import ARKit

class HandTrackingProvider: ObservableObject {
    private let session = ARKitSession()
    private let handTracking = HandTrackingProvider()

    @Published var leftHand: HandAnchor?
    @Published var rightHand: HandAnchor?

    func startTracking() async {
        do {
            try await session.run([handTracking])

            for await update in handTracking.anchorUpdates {
                switch update.anchor.chirality {
                case .left:
                    leftHand = update.anchor
                case .right:
                    rightHand = update.anchor
                }
            }
        } catch {
            print("Hand tracking failed: \(error)")
        }
    }
}
```

### Hand Skeleton Analysis

```swift
extension HandAnchor {
    /// Get position of specific joint
    func jointPosition(_ joint: HandSkeleton.JointName) -> SIMD3<Float>? {
        guard let skeleton = handSkeleton else { return nil }
        return skeleton.joint(joint).anchorFromJointTransform.columns.3.xyz
    }

    /// Detect pinch gesture
    var isPinching: Bool {
        guard let thumbTip = jointPosition(.thumbTip),
              let indexTip = jointPosition(.indexFingerTip) else {
            return false
        }

        let distance = simd_distance(thumbTip, indexTip)
        return distance < 0.02 // 2cm threshold
    }

    /// Calculate hand center
    var palmCenter: SIMD3<Float>? {
        guard let skeleton = handSkeleton else { return nil }

        let wrist = skeleton.joint(.wrist).anchorFromJointTransform.columns.3.xyz
        let middleKnuckle = skeleton.joint(.middleFingerKnuckle).anchorFromJointTransform.columns.3.xyz

        return (wrist + middleKnuckle) / 2
    }
}
```

### Custom Gestures with Hand Tracking

#### "Push" Gesture (Navigate Forward)
```swift
class PushGestureRecognizer {
    private var initialHandPosition: SIMD3<Float>?

    func detectPush(hand: HandAnchor) -> Bool {
        guard let palmCenter = hand.palmCenter else { return false }

        if initialHandPosition == nil {
            initialHandPosition = palmCenter
            return false
        }

        let movement = palmCenter - initialHandPosition!
        let forwardMovement = movement.z // Z-axis is forward/backward

        if forwardMovement > 0.15 { // 15cm push threshold
            initialHandPosition = nil
            return true
        }

        return false
    }
}
```

#### "Grab & Pull" (Select Multiple Employees)
```swift
func detectGrabGesture(hand: HandAnchor) -> Bool {
    // Check if all fingers are curled (fist)
    guard let skeleton = hand.handSkeleton else { return false }

    let fingersCurled = [
        HandSkeleton.JointName.indexFingerTip,
        .middleFingerTip,
        .ringFingerTip,
        .littleFingerTip
    ].allSatisfy { finger in
        guard let tip = skeleton.joint(finger).anchorFromJointTransform.columns.3.xyz,
              let knuckle = skeleton.joint(finger).parent?.anchorFromJointTransform.columns.3.xyz else {
            return false
        }
        return simd_distance(tip, knuckle) < 0.03
    }

    return fingersCurled
}
```

### Accessibility: Hand Tracking Alternatives
- Gaze + pinch as fallback
- Voice commands for all hand gestures
- External controller support (future)

---

## Eye Tracking Implementation

### ARKit Eye Tracking

```swift
import ARKit

class EyeTrackingProvider: ObservableObject {
    @Published var gazeDirection: SIMD3<Float>?
    @Published var gazeOrigin: SIMD3<Float>?
    @Published var focusedEntity: Entity?

    func startTracking() async {
        // Request authorization
        guard await ARKitSession.queryAuthorization(for: [.handTracking]).values.first == .allowed else {
            return
        }

        // Start session
        let session = ARKitSession()
        let worldTracking = WorldTrackingProvider()

        try? await session.run([worldTracking])

        // Update loop
        for await update in worldTracking.anchorUpdates {
            processGaze(update)
        }
    }

    private func processGaze(_ update: AnchorUpdate<WorldAnchor>) {
        // Get device pose (approximates eye position)
        gazeOrigin = update.anchor.originFromAnchorTransform.columns.3.xyz
        gazeDirection = -update.anchor.originFromAnchorTransform.columns.2.xyz // -Z is forward

        // Raycast to find focused entity
        performRaycast()
    }

    private func performRaycast() {
        guard let origin = gazeOrigin,
              let direction = gazeDirection else { return }

        // Perform raycast in RealityKit scene
        let raycastResult = scene.raycast(
            origin: origin,
            direction: direction
        )

        focusedEntity = raycastResult.first?.entity
    }
}
```

### Gaze-Based UI Highlighting

```swift
struct EmployeeNodeView: View {
    @ObservedObject var eyeTracker: EyeTrackingProvider
    let employee: Employee

    var isGazedAt: Bool {
        eyeTracker.focusedEntity?.id == employee.id
    }

    var body: some View {
        RealityView { content in
            let entity = createEmployeeNode(employee)
            content.add(entity)
        }
        .onChange(of: isGazedAt) { _, gazed in
            if gazed {
                highlightNode()
            } else {
                unhighlightNode()
            }
        }
    }
}
```

### Privacy Considerations
- Eye tracking data never leaves device
- No recording or storage of gaze data
- Opt-in required with clear explanation
- Disable option always available
- No gaze data in analytics

---

## Spatial Audio Specifications

### Audio Architecture

```swift
import AVFoundation
import RealityKit

class SpatialAudioManager {
    private var audioResources: [String: AudioResource] = [:]

    func setupSpatialAudio() {
        // Configure audio session for spatial audio
        let audioSession = AVAudioSession.sharedInstance()
        try? audioSession.setCategory(.playback, mode: .spatialAudio)
        try? audioSession.setActive(true)
    }

    func playSound(
        _ soundName: String,
        at position: SIMD3<Float>,
        volume: Float = 1.0
    ) async {
        // Load audio resource
        guard let audioResource = try? await AudioFileResource(named: soundName) else {
            return
        }

        // Create audio playback controller
        let audioController = entity.prepareAudio(audioResource)

        // Configure spatial audio
        audioController.gain = volume
        audioController.mode = .spatial

        // Play
        audioController.play()
    }
}
```

### Audio Feedback Map

| Interaction | Sound | Position | Volume |
|-------------|-------|----------|--------|
| Select Employee | Soft tap | Entity position | 0.5 |
| Hover over Employee | Subtle ping | Entity position | 0.3 |
| Open Profile | Whoosh | Window center | 0.6 |
| Data Refresh | Chime | User position | 0.4 |
| Error | Alert tone | User position | 0.7 |
| Success | Success chime | User position | 0.6 |
| Navigation | Spatial swoosh | Direction of movement | 0.5 |

### Ambient Audio

**Organizational Galaxy**
- Subtle cosmic ambient (low volume)
- Distance-based attenuation
- Increases with immersion level

**Team Visualization**
- Gentle collaboration sounds
- Higher activity = more audio activity
- Spatial positioning based on team location

### Accessibility: Audio Descriptions
- Voice-over descriptions for all visual elements
- Spatial audio cues for navigation
- Audio-only mode for key functionality

---

## Accessibility Requirements

### VoiceOver Support

```swift
// Employee node accessibility
entity.accessibilityLabel = "\(employee.name), \(employee.title)"
entity.accessibilityHint = "Double tap to view profile"
entity.accessibilityTraits = [.button]

// Custom accessibility actions
entity.accessibilityCustomActions = [
    UIAccessibilityCustomAction(name: "View Performance") {
        showPerformance()
        return true
    },
    UIAccessibilityCustomAction(name: "View Team") {
        showTeam()
        return true
    }
]

// Accessibility value for dynamic content
entity.accessibilityValue = "Performance: \(employee.performanceRating), Engagement: \(employee.engagementScore)"
```

### Dynamic Type

```swift
// Support Dynamic Type scaling
Text(employee.name)
    .font(.title)
    .dynamicTypeSize(.xSmall ... .xxxLarge)

// Scale spatial UI elements
let scaleFactor = DynamicTypeSize.current.scaleFactor
entity.scale = [scaleFactor, scaleFactor, scaleFactor]
```

### Alternative Interaction Methods

**For Users Unable to Use Hand Tracking**:
1. **Voice Commands**: All actions available via Siri
2. **Gaze + Dwell**: Select by looking at object for 1.5 seconds
3. **External Controllers**: Support for accessibility controllers
4. **Keyboard Navigation**: Full keyboard support in 2D windows

### Reduce Motion

```swift
@Environment(\.accessibilityReduceMotion) var reduceMotion

// Conditional animations
if reduceMotion {
    // Instant transitions
    entity.position = newPosition
} else {
    // Animated transitions
    entity.move(to: newPosition, relativeTo: nil, duration: 0.3)
}
```

### Color & Contrast

```swift
@Environment(\.accessibilityDifferentiateWithoutColor) var differentiateWithoutColor
@Environment(\.colorSchemeContrast) var contrast

// High contrast mode
let strokeWidth: Float = contrast == .increased ? 2.0 : 1.0

// Don't rely on color alone
if differentiateWithoutColor {
    // Add patterns, labels, or icons in addition to color
    addIconToIndicateStatus(entity)
}
```

### Assistive Technologies

- **Switch Control**: Full support for switch-based navigation
- **Voice Control**: Custom voice commands for all actions
- **AssistiveTouch**: Floating controls for complex gestures
- **Closed Captions**: For any audio content

---

## Privacy & Security Requirements

### Data Protection Levels

```swift
enum DataClassification {
    case public          // Company name, department names
    case internal        // Employee names, titles
    case confidential    // Performance data, compensation
    case restricted      // SSN, health data, personal identifiers
}

// Data handling based on classification
func handleData(_ data: Any, classification: DataClassification) {
    switch classification {
    case .public:
        // No special handling
        break
    case .internal:
        // Encrypt in transit
        encrypt(data)
    case .confidential:
        // Encrypt in transit and at rest, audit access
        encrypt(data)
        auditAccess(data)
    case .restricted:
        // Encrypt, audit, require MFA, limit access
        encrypt(data)
        auditAccess(data)
        requireMFA()
        limitAccess(data)
    }
}
```

### Encryption Requirements

**Data at Rest**:
- FileVault encryption (device level)
- SwiftData encryption for sensitive fields
- Keychain for credentials and tokens

```swift
// Encrypted SwiftData field
@Model
class Employee {
    @Encrypted var socialSecurityNumber: String
    @Encrypted var salary: Decimal
    @Encrypted var healthData: HealthInformation?
}
```

**Data in Transit**:
- TLS 1.3 minimum
- Certificate pinning for API calls
- End-to-end encryption for sensitive operations

```swift
// Certificate pinning
class SecureNetworkClient {
    private let pinnedCertificates: Set<SecCertificate>

    func validateCertificate(_ trust: SecTrust) -> Bool {
        guard let serverCertificate = SecTrustCopyCertificateChain(trust) as? [SecCertificate],
              let cert = serverCertificate.first else {
            return false
        }

        return pinnedCertificates.contains(cert)
    }
}
```

### Authentication & Authorization

**Multi-Factor Authentication**:
```swift
class MFAService {
    func requireMFA() async throws -> Bool {
        // Biometric (primary)
        if try await authenticateWithBiometrics() {
            return true
        }

        // TOTP (fallback)
        return try await authenticateWithTOTP()
    }

    private func authenticateWithBiometrics() async throws -> Bool {
        let context = LAContext()
        context.localizedReason = "Authenticate to access sensitive data"

        return try await context.evaluatePolicy(
            .deviceOwnerAuthenticationWithBiometrics,
            localizedReason: context.localizedReason
        )
    }
}
```

**Session Management**:
- Session timeout: 30 minutes idle, 8 hours absolute
- Re-authentication required for sensitive operations
- Secure session token storage in Keychain

### Audit Logging

```swift
struct AuditLog: Codable {
    let userId: UUID
    let action: AuditAction
    let resourceType: ResourceType
    let resourceId: String
    let timestamp: Date
    let ipAddress: String?
    let deviceId: String
}

enum AuditAction: String, Codable {
    case view
    case create
    case update
    case delete
    case export
    case print
}

actor AuditLogger {
    func log(_ event: AuditLog) async {
        // Send to secure audit log service
        // Immutable, encrypted storage
        // Retained for 7 years (compliance requirement)
    }
}
```

### GDPR Compliance

```swift
protocol GDPRCompliant {
    func exportPersonalData(userId: UUID) async throws -> Data
    func deletePersonalData(userId: UUID) async throws
    func anonymizeData(userId: UUID) async throws
}

class PrivacyService: GDPRCompliant {
    func exportPersonalData(userId: UUID) async throws -> Data {
        let employee = try await hrService.getEmployee(id: userId)

        // Compile all personal data
        let personalData = PersonalDataExport(
            profile: employee.personalInfo,
            employmentHistory: employee.jobInfo,
            performance: employee.performance,
            // ... all personal data
        )

        return try JSONEncoder().encode(personalData)
    }

    func deletePersonalData(userId: UUID) async throws {
        // GDPR "Right to be Forgotten"
        // Note: May need to retain some data for legal compliance
        try await hrService.anonymizeEmployee(id: userId)
    }
}
```

---

## Data Persistence Strategy

### SwiftData Schema

```swift
import SwiftData

@Model
final class Employee {
    @Attribute(.unique) var id: UUID
    var employeeNumber: String
    var firstName: String
    var lastName: String

    // Relationships
    @Relationship(deleteRule: .nullify, inverse: \Employee.directReports)
    var manager: Employee?

    @Relationship(deleteRule: .nullify)
    var directReports: [Employee] = []

    @Relationship(deleteRule: .cascade)
    var performance: PerformanceData?

    @Relationship(deleteRule: .cascade)
    var skills: [Skill] = []

    // Timestamps
    var createdAt: Date
    var updatedAt: Date

    init(id: UUID = UUID(), employeeNumber: String, firstName: String, lastName: String) {
        self.id = id
        self.employeeNumber = employeeNumber
        self.firstName = firstName
        self.lastName = lastName
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

// Model Container Configuration
@main
struct SpatialHCMApp: App {
    let modelContainer: ModelContainer

    init() {
        do {
            let schema = Schema([
                Employee.self,
                Department.self,
                Team.self,
                PerformanceData.self,
                Skill.self
            ])

            let config = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false,
                allowsSave: true
            )

            modelContainer = try ModelContainer(
                for: schema,
                configurations: config
            )
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(modelContainer)
    }
}
```

### Caching Strategy

```swift
class CacheManager {
    private var memoryCache = NSCache<NSString, CacheEntry>()
    private let diskCache: URL

    init() {
        // Configure memory cache
        memoryCache.totalCostLimit = 100 * 1024 * 1024 // 100 MB
        memoryCache.countLimit = 1000

        // Configure disk cache
        let cacheDir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        diskCache = cacheDir.appendingPathComponent("SpatialHCMCache")
        try? FileManager.default.createDirectory(at: diskCache, withIntermediateDirectories: true)
    }

    // Three-tier caching
    func get<T: Codable>(_ key: String, type: T.Type) -> T? {
        // L1: Memory cache
        if let entry = memoryCache.object(forKey: key as NSString) {
            if !entry.isExpired {
                return entry.value as? T
            }
        }

        // L2: SwiftData cache
        // (Query from SwiftData)

        // L3: Network (not part of cache retrieval)
        return nil
    }

    func set<T: Codable>(_ value: T, forKey key: String, ttl: TimeInterval = 300) {
        let entry = CacheEntry(value: value, expiresAt: Date().addingTimeInterval(ttl))
        memoryCache.setObject(entry, forKey: key as NSString)
    }
}
```

### Offline Support

```swift
class OfflineManager {
    private let syncQueue = DispatchQueue(label: "com.spatialhcm.sync")
    private var pendingOperations: [SyncOperation] = []

    func queueOperation(_ operation: SyncOperation) {
        pendingOperations.append(operation)
        persistPendingOperations()
    }

    func syncWhenOnline() async {
        guard NetworkMonitor.shared.isConnected else { return }

        for operation in pendingOperations {
            do {
                try await executeOperation(operation)
                pendingOperations.removeAll { $0.id == operation.id }
            } catch {
                // Retry logic
            }
        }

        persistPendingOperations()
    }
}
```

---

## Network Architecture

### API Client

```swift
actor APIClient {
    private let session: URLSession
    private let baseURL: URL
    private var authToken: String?

    init(baseURL: URL) {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 300
        config.waitsForConnectivity = true

        self.session = URLSession(configuration: config)
        self.baseURL = baseURL
    }

    func request<T: Decodable>(
        _ endpoint: Endpoint,
        method: HTTPMethod = .get,
        body: Data? = nil
    ) async throws -> T {
        var request = URLRequest(url: baseURL.appendingPathComponent(endpoint.path))
        request.httpMethod = method.rawValue
        request.httpBody = body

        // Add headers
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.httpError(statusCode: httpResponse.statusCode)
        }

        return try JSONDecoder().decode(T.self, from: data)
    }
}
```

### WebSocket for Real-Time Updates

```swift
actor WebSocketManager {
    private var webSocket: URLSessionWebSocketTask?
    private let url: URL
    var onMessage: ((WebSocketMessage) -> Void)?

    init(url: URL) {
        self.url = url
    }

    func connect() async throws {
        let session = URLSession(configuration: .default)
        webSocket = session.webSocketTask(with: url)
        webSocket?.resume()

        await listenForMessages()
    }

    private func listenForMessages() async {
        do {
            let message = try await webSocket?.receive()

            switch message {
            case .string(let text):
                handleMessage(text)
            case .data(let data):
                handleMessage(data)
            default:
                break
            }

            // Continue listening
            await listenForMessages()
        } catch {
            // Handle disconnection
            try? await Task.sleep(for: .seconds(5))
            try? await connect()
        }
    }

    func send(_ message: WebSocketMessage) async throws {
        let data = try JSONEncoder().encode(message)
        try await webSocket?.send(.data(data))
    }
}
```

### Network Monitoring

```swift
import Network

@Observable
class NetworkMonitor {
    static let shared = NetworkMonitor()

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")

    var isConnected = false
    var connectionType: NWInterface.InterfaceType?

    private init() {
        monitor.pathUpdateHandler = { [weak self] path in
            self?.isConnected = path.status == .satisfied
            self?.connectionType = path.availableInterfaces.first?.type
        }
        monitor.start(queue: queue)
    }
}
```

---

## Testing Requirements

### Unit Testing

```swift
import Testing
import SwiftData

@Test("Employee data model creation")
func testEmployeeCreation() async throws {
    let employee = Employee(
        employeeNumber: "EMP001",
        firstName: "John",
        lastName: "Doe"
    )

    #expect(employee.id != UUID())
    #expect(employee.employeeNumber == "EMP001")
    #expect(employee.firstName == "John")
}

@Test("HR data service fetches employees")
func testFetchEmployees() async throws {
    let mockAPI = MockAPIClient()
    let service = HRDataService(apiClient: mockAPI)

    let employees = try await service.fetchEmployees()

    #expect(employees.count > 0)
}
```

### UI Testing

```swift
import XCTest

final class SpatialHCMUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUp() {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    func testEmployeeProfileNavigation() {
        // Find employee in list
        let employeeCell = app.buttons["Employee_John_Doe"]
        XCTAssertTrue(employeeCell.waitForExistence(timeout: 5))

        // Tap to open profile
        employeeCell.tap()

        // Verify profile window opened
        let profileWindow = app.windows["EmployeeProfile"]
        XCTAssertTrue(profileWindow.waitForExistence(timeout: 2))
    }

    func testAccessibility() {
        // Enable VoiceOver simulation
        app.activate()

        // Verify accessibility labels
        let employeeButton = app.buttons["Employee_John_Doe"]
        XCTAssertEqual(
            employeeButton.label,
            "John Doe, Senior Software Engineer"
        )
    }
}
```

### Spatial Interaction Testing

```swift
// Test RealityKit entity interactions
@Test("Employee node selection in 3D space")
func testEmployeeNodeSelection() async throws {
    let scene = Scene()
    let factory = EmployeeEntityFactory()

    let employee = Employee(employeeNumber: "EMP001", firstName: "John", lastName: "Doe")
    let entity = factory.createEmployeeNode(for: employee)

    scene.addAnchor(entity)

    // Simulate tap
    let tapLocation = entity.position
    let tappedEntity = scene.raycast(origin: tapLocation, direction: [0, 0, -1]).first

    #expect(tappedEntity?.entity == entity)
}
```

### Performance Testing

```swift
import XCTest

final class PerformanceTests: XCTestCase {
    func testEmployeeRenderingPerformance() {
        measure(metrics: [XCTClockMetric(), XCTMemoryMetric()]) {
            // Render 10,000 employee nodes
            let employees = (0..<10000).map { i in
                Employee(employeeNumber: "EMP\(i)", firstName: "Employee", lastName: "\(i)")
            }

            let factory = EmployeeEntityFactory()
            employees.forEach { employee in
                _ = factory.createEmployeeNode(for: employee)
            }
        }
    }
}
```

### Integration Testing

```swift
@Test("End-to-end employee creation flow")
func testEmployeeCreationFlow() async throws {
    // 1. Create employee via API
    let newEmployee = Employee(
        employeeNumber: "EMP999",
        firstName: "Test",
        lastName: "User"
    )

    let created = try await hrService.createEmployee(newEmployee)

    // 2. Verify in database
    let fetched = try await hrService.getEmployee(id: created.id)
    #expect(fetched.employeeNumber == "EMP999")

    // 3. Verify in 3D visualization
    let entity = factory.createEmployeeNode(for: fetched)
    #expect(entity.components[EmployeeNodeComponent.self]?.employeeId == created.id)

    // 4. Cleanup
    try await hrService.deleteEmployee(id: created.id)
}
```

---

## Performance Specifications

### Frame Rate Targets

- **Minimum**: 90 FPS (11.1ms frame time)
- **Target**: 96 FPS (10.4ms frame time)
- **Unacceptable**: < 60 FPS

### Rendering Budget

| Phase | Budget | Notes |
|-------|--------|-------|
| Update | 3ms | State updates, physics |
| Culling | 1ms | Frustum culling, occlusion |
| Rendering | 6ms | Draw calls, shaders |
| Post-processing | 1ms | Effects, bloom, etc. |
| **Total** | **11ms** | 90 FPS target |

### Memory Limits

- **Active Memory**: < 2GB
- **Peak Memory**: < 4GB
- **Texture Memory**: < 500MB
- **Model Cache**: < 200MB

### Asset Optimization

**3D Models**:
- Triangle count: < 10K per employee node
- Texture size: 512x512 max
- Material complexity: 2 textures per material
- LOD levels: 3 (high, medium, low)

**Textures**:
- Format: ASTC compressed
- Mipmaps: Enabled
- Atlasing: 4K atlas for common textures

### Network Performance

- **API Response**: < 200ms
- **GraphQL Query**: < 500ms
- **WebSocket Latency**: < 100ms
- **Image Load**: < 1s

### Optimization Techniques

```swift
// Entity pooling
class EntityPool {
    private var pool: [Entity] = []

    func acquire() -> Entity {
        return pool.popLast() ?? createEntity()
    }

    func release(_ entity: Entity) {
        entity.isEnabled = false
        pool.append(entity)
    }
}

// Lazy loading
class LazyLoadingSystem: System {
    func update(context: SceneUpdateContext) {
        let camera = context.scene.activeCamera
        let visibleEntities = getVisibleEntities(camera: camera)

        // Load high-detail only for visible entities
        for entity in visibleEntities {
            loadHighDetailModel(entity)
        }
    }
}
```

---

## Conclusion

This technical specification provides the detailed requirements for implementing Spatial HCM on visionOS. Key technical decisions:

1. **Modern Swift**: Leverage Swift 6.0 concurrency and observation
2. **Spatial-First**: Built for visionOS from the ground up
3. **Performance**: Optimized for 90 FPS with 100K+ employees
4. **Accessibility**: Full VoiceOver, Dynamic Type, and alternative inputs
5. **Privacy**: GDPR-compliant with comprehensive security
6. **Testing**: Comprehensive unit, UI, and performance testing

All specifications are designed to deliver a production-ready, enterprise-grade spatial computing application that transforms how organizations manage and visualize their human capital.
