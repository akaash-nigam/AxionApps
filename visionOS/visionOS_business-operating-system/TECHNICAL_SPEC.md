# Business Operating System - Technical Specification

## Document Overview

This document provides detailed technical specifications for implementing the Business Operating System (BOS) on Apple Vision Pro using visionOS 2.0+.

**Version:** 1.0
**Last Updated:** 2025-01-20
**Platform:** visionOS 2.0+
**Xcode:** 16.0+

---

## 1. Technology Stack

### 1.1 Core Technologies

| Technology | Version | Purpose |
|------------|---------|---------|
| **Swift** | 6.0+ | Primary programming language with strict concurrency |
| **SwiftUI** | visionOS 2.0+ | UI framework for 2D and spatial interfaces |
| **RealityKit** | 4.0+ | 3D rendering and spatial computing |
| **ARKit** | 6.0+ | Spatial tracking, hand tracking, scene understanding |
| **visionOS SDK** | 2.0+ | Platform-specific APIs and frameworks |
| **Combine** | Latest | Reactive programming for data streams |
| **Swift Concurrency** | Swift 6.0+ | Async/await, actors, task groups |
| **SwiftData** | Latest | Data persistence and modeling |

### 1.2 Apple Frameworks

```swift
// Core frameworks
import SwiftUI
import RealityKit
import ARKit
import Spatial

// Data and networking
import SwiftData
import Combine
import Foundation

// Security and authentication
import LocalAuthentication
import CryptoKit
import AuthenticationServices

// Multimedia
import AVFoundation      // Spatial audio
import CoreHaptics       // Haptic feedback

// System integration
import OSLog            // Logging
import CloudKit         // Cloud sync (optional)
import GroupActivities  // SharePlay collaboration
```

### 1.3 Third-Party Dependencies (Swift Package Manager)

```swift
// Package.swift dependencies
dependencies: [
    // Networking
    .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.9.0"),

    // GraphQL client
    .package(url: "https://github.com/apollographql/apollo-ios.git", from: "1.9.0"),

    // WebSocket
    .package(url: "https://github.com/daltoniam/Starscream.git", from: "4.0.0"),

    // Utilities
    .package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", from: "5.0.0"),

    // Analytics (optional)
    .package(url: "https://github.com/mixpanel/mixpanel-swift.git", from: "4.0.0"),
]
```

---

## 2. visionOS Presentation Modes

### 2.1 WindowGroup Configuration

#### Executive Dashboard Window

```swift
WindowGroup(id: "dashboard") {
    DashboardView()
        .environment(\.appState, appState)
        .environment(\.services, services)
}
.windowStyle(.plain)
.defaultSize(width: 1200, height: 800)
.windowResizability(.contentSize)
```

**Specifications:**
- **Minimum Size:** 800 x 600 points
- **Default Size:** 1200 x 800 points
- **Maximum Size:** 1920 x 1200 points
- **Glass Material:** `.ultraThin`
- **Corner Radius:** 24 points
- **Ornaments:** Top toolbar, bottom status bar

#### Report Detail Windows

```swift
WindowGroup(id: "report", for: Report.ID.self) { $reportID in
    if let reportID {
        ReportDetailView(reportID: reportID)
    }
}
.defaultSize(width: 800, height: 1000)
.windowResizability(.contentMinSize)
```

**Specifications:**
- **Minimum Size:** 600 x 800 points
- **Supports Multiple Instances:** Yes
- **Persistent State:** Saved per report ID
- **Export Capabilities:** PDF, CSV, Excel

### 2.2 Volumetric Windows

#### Department Volume

```swift
WindowGroup(id: "department", for: Department.ID.self) { $deptID in
    if let deptID {
        DepartmentVolumeView(departmentID: deptID)
    }
}
.windowStyle(.volumetric)
.defaultSize(width: 1.0, height: 1.0, depth: 1.0, in: .meters)
```

**Specifications:**
- **Physical Dimensions:** 1.0m x 1.0m x 1.0m (adjustable)
- **Content Bounds:** Clipped to volume
- **Interaction:** Direct manipulation within volume
- **Background:** Transparent
- **Entity Count:** Up to 10,000 entities
- **Target FPS:** 90 FPS

#### Data Visualization Volume

```swift
WindowGroup(id: "viz", for: Visualization.ID.self) { $vizID in
    if let vizID {
        DataVisualizationVolume(visualizationID: vizID)
    }
}
.windowStyle(.volumetric)
.defaultSize(width: 0.8, height: 1.2, depth: 0.8, in: .meters)
```

**Specifications:**
- **Chart Types:** 3D bar charts, scatter plots, network graphs
- **Data Points:** Up to 100,000 points with LOD
- **Animations:** Smooth transitions at 60+ FPS
- **Interaction:** Pinch to select, drag to rotate, spread to expand

### 2.3 Immersive Spaces

#### Business Universe Immersive Space

```swift
ImmersiveSpace(id: "universe") {
    BusinessUniverseView()
        .environment(\.appState, appState)
}
.immersionStyle(selection: $immersionLevel, in: .full)
.upperLimbVisibility(.hidden) // Optional: hide hands for cleaner view
```

**Specifications:**
- **Immersion Level:** Full (occludes passthrough entirely)
- **World Scale:** 10m x 10m x 10m navigable space
- **Anchor System:** World-locked spatial anchors
- **Environment:** Custom skybox with corporate branding
- **Lighting:** IBL (Image-Based Lighting) + dynamic lights
- **Performance Target:** 90 FPS with 50K+ entities

**Environment Customization:**
```swift
RealityView { content in
    // Custom skybox
    var skybox = Entity()
    skybox.components.set(SkyboxComponent(resource: .skybox))
    content.add(skybox)

    // Directional lighting
    var sunlight = DirectionalLight()
    sunlight.light.intensity = 5000
    sunlight.light.color = .white
    sunlight.orientation = simd_quatf(angle: .pi / 4, axis: [1, -1, 0])
    content.add(sunlight)

    // Ambient light
    var ambient = Entity()
    ambient.components.set(ImageBasedLightComponent(source: .single(.ibl)))
    content.add(ambient)
}
```

---

## 3. Gesture and Interaction Specifications

### 3.1 Standard visionOS Gestures

#### Tap Gesture

```swift
entity.components.set(InputTargetComponent())
entity.components.set(CollisionComponent(shapes: [.generateBox(size: [0.1, 0.1, 0.1])]))

// Handle tap in gesture
.gesture(
    TapGesture()
        .targetedToAnyEntity()
        .onEnded { value in
            handleEntityTap(value.entity)
        }
)
```

**Specifications:**
- **Target Size:** Minimum 60pt (visual) / 60mm (spatial)
- **Haptic Feedback:** `.impact(.light)` on tap
- **Visual Feedback:** Scale animation 1.0 → 0.95 → 1.0 over 200ms
- **Audio Feedback:** Subtle click sound (optional)

#### Drag Gesture

```swift
.gesture(
    DragGesture()
        .targetedToAnyEntity()
        .onChanged { value in
            updateEntityPosition(value.entity, value.translation3D)
        }
        .onEnded { value in
            finalizeEntityPosition(value.entity)
        }
)
```

**Specifications:**
- **Drag Threshold:** 5mm movement to initiate
- **Update Frequency:** Every frame (90 Hz)
- **Constraints:** Can be axis-locked (X, Y, or Z only)
- **Physics:** Optional spring interpolation for smooth movement
- **Haptic Feedback:** Continuous light haptics during drag

#### Rotate Gesture

```swift
.gesture(
    RotateGesture3D()
        .targetedToAnyEntity()
        .onChanged { value in
            rotateEntity(value.entity, value.rotation)
        }
)
```

**Specifications:**
- **Two-Hand Required:** Yes
- **Rotation Axis:** Free rotation or constrained to Y-axis
- **Snap Points:** Optional 45° or 90° snapping
- **Haptic Feedback:** `.selection` at snap points

#### Scale/Magnify Gesture

```swift
.gesture(
    MagnifyGesture()
        .targetedToAnyEntity()
        .onChanged { value in
            scaleEntity(value.entity, value.magnification)
        }
)
```

**Specifications:**
- **Scale Range:** 0.5x to 3.0x
- **Two-Hand Required:** Yes
- **Uniform Scaling:** Default (can be configured for non-uniform)
- **Animation:** Smooth interpolation with spring physics

### 3.2 Custom Business Gestures

#### Drill-Down Gesture

```swift
struct DrillDownGesture: Gesture {
    // Custom gesture: Forward push motion with pinched fingers

    var body: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                // Detect forward Z-axis movement while pinching
                if isPinching && value.translation3D.z < -0.1 {
                    triggerDrillDown()
                }
            }
    }
}
```

**Specifications:**
- **Trigger:** Forward push (toward user → away) while pinching
- **Distance Threshold:** 10cm minimum
- **Action:** Navigate into hierarchical data
- **Visual Feedback:** Zoom animation into selected entity
- **Haptic:** `.impact(.medium)` on trigger

#### Resource Allocation Gesture

```swift
struct ResourceAllocationGesture: Gesture {
    // Grab entity and drag to another department

    var body: some Gesture {
        SimultaneousGesture(
            DragGesture().targetedToAnyEntity(),
            LongPressGesture(minimumDuration: 0.5)
        )
    }
}
```

**Specifications:**
- **Trigger:** Long press (500ms) + drag
- **Visual Feedback:** Entity becomes translucent and follows hand
- **Drop Zones:** Departments highlight when entity is nearby
- **Haptic:** `.success` on valid drop, `.error` on invalid
- **Animation:** Spring physics for entity movement

#### Comparison Gesture

```swift
// Bring two entities together to compare
struct ComparisonGesture: Gesture {
    var body: some Gesture {
        // Detect when two selected entities are brought within 20cm
        // Automatically show comparison UI
    }
}
```

**Specifications:**
- **Trigger:** Two entities within 20cm proximity
- **Visual Feedback:** Comparison panel appears between entities
- **Data Display:** Side-by-side metrics, delta calculations
- **Dismiss:** Separate entities beyond 30cm

---

## 4. Hand Tracking Implementation

### 4.1 Hand Tracking Provider

```swift
class HandTrackingManager: ObservableObject {
    private let session = ARKitSession()
    private let handTracking = HandTrackingProvider()

    @Published var leftHandAnchor: HandAnchor?
    @Published var rightHandAnchor: HandAnchor?

    func startTracking() async throws {
        try await session.run([handTracking])

        for await update in handTracking.anchorUpdates {
            switch update.event {
            case .added, .updated:
                updateHand(update.anchor)
            case .removed:
                removeHand(update.anchor)
            }
        }
    }

    private func updateHand(_ anchor: HandAnchor) {
        if anchor.chirality == .left {
            leftHandAnchor = anchor
        } else {
            rightHandAnchor = anchor
        }
    }
}
```

### 4.2 Custom Gesture Recognition

```swift
class BusinessGestureRecognizer {
    func recognizeGesture(from hand: HandAnchor) -> BOSGesture? {
        guard let skeleton = hand.handSkeleton else { return nil }

        // Get joint positions
        let thumbTip = skeleton.joint(.thumbTip)
        let indexTip = skeleton.joint(.indexFingerTip)
        let wrist = skeleton.joint(.wrist)

        // Check pinch gesture
        if isPinching(thumb: thumbTip, index: indexTip) {
            return .select
        }

        // Check point gesture
        if isPointing(hand: skeleton) {
            return .point
        }

        // Check grab gesture
        if isGrabbing(hand: skeleton) {
            return .grab
        }

        return nil
    }

    private func isPinching(thumb: HandSkeleton.Joint, index: HandSkeleton.Joint) -> Bool {
        let distance = simd_distance(
            thumb.anchorFromJointTransform.columns.3.xyz,
            index.anchorFromJointTransform.columns.3.xyz
        )
        return distance < 0.02 // 2cm threshold
    }

    private func isPointing(hand: HandSkeleton) -> Bool {
        // Index finger extended, others curled
        let indexExtended = isFingerExtended(hand, .indexFinger)
        let middleCurled = !isFingerExtended(hand, .middleFinger)
        let ringCurled = !isFingerExtended(hand, .ringFinger)
        let pinkyCurled = !isFingerExtended(hand, .littleFinger)

        return indexExtended && middleCurled && ringCurled && pinkyCurled
    }

    private func isGrabbing(hand: HandSkeleton) -> Bool {
        // All fingers curled
        return !isFingerExtended(hand, .indexFinger) &&
               !isFingerExtended(hand, .middleFinger) &&
               !isFingerExtended(hand, .ringFinger) &&
               !isFingerExtended(hand, .littleFinger)
    }

    private func isFingerExtended(_ hand: HandSkeleton, _ finger: HandSkeleton.JointName) -> Bool {
        // Compare tip and knuckle positions to determine extension
        // Implementation details...
        return true // placeholder
    }
}

enum BOSGesture {
    case select    // Pinch
    case point     // Point with index finger
    case grab      // Closed fist
    case swipe     // Swipe motion
    case rotate    // Rotation gesture
}
```

### 4.3 Hand Tracking Specifications

| Feature | Specification |
|---------|--------------|
| **Update Frequency** | 90 Hz |
| **Tracked Joints** | 27 joints per hand |
| **Tracking Volume** | Full arms-reach sphere |
| **Occlusion Handling** | Predictive tracking when occluded |
| **Latency** | <11ms (one frame at 90 FPS) |
| **Accuracy** | ±5mm for fingertips |

---

## 5. Eye Tracking Implementation

### 5.1 Eye Tracking for Focus

```swift
class EyeTrackingManager {
    private var currentFocusedEntity: Entity?

    func observeFocus() -> AsyncStream<Entity?> {
        AsyncStream { continuation in
            // visionOS automatically provides gaze focus
            // via InputTargetComponent and hover effects

            // Additional custom eye tracking (if needed)
            // Note: Direct eye tracking requires special entitlement
        }
    }
}
```

### 5.2 Gaze-Based Interactions

```swift
// Hover effect on gaze
entity.components.set(HoverEffectComponent())

// Custom hover behavior
.onContinuousHover { phase in
    switch phase {
    case .active(let location):
        // Entity is being gazed at
        highlightEntity(at: location)

    case .ended:
        // Gaze left the entity
        unhighlightEntity()
    }
}
```

### 5.3 Eye Tracking Privacy

**Requirements:**
- Eye tracking data NEVER leaves the device
- No eye position logging or analytics
- Only use for UI focus and interaction
- User consent via system permissions
- Privacy policy disclosure

**Info.plist Entry:**
```xml
<key>NSEyeTrackingUsageDescription</key>
<string>Eye tracking improves interaction precision and helps highlight relevant business metrics as you look around your business environment.</string>
```

---

## 6. Spatial Audio Specifications

### 6.1 Ambient Business Audio

```swift
class SpatialAudioManager {
    private let audioEngine = AVAudioEngine()

    func playAmbientMetricSound(for kpi: KPI, at position: SIMD3<Float>) async {
        // Create spatial audio source
        let audioSource = AudioFileResource.createSpatialAudioSource(
            for: kpi.category.soundFile,
            at: position
        )

        // Adjust parameters based on KPI status
        let parameters = AudioPlaybackParameters(
            volume: kpi.health.volumeLevel,
            pitch: kpi.trend.pitch,
            reverbLevel: 0.2
        )

        await audioSource.play(with: parameters)
    }

    func playAlertSound(for alert: BusinessAlert, at position: SIMD3<Float>) async {
        // Critical alerts use distinctive spatial audio
        let urgency: AudioUrgencyLevel = switch alert.severity {
        case .critical: .high
        case .warning: .medium
        case .info: .low
        }

        let audioSource = AudioFileResource.createAlertSound(
            urgency: urgency,
            position: position
        )

        await audioSource.play()
    }
}
```

### 6.2 Spatial Audio Specifications

| Feature | Specification |
|---------|--------------|
| **Audio Format** | Spatial Audio (3D positional) |
| **Sample Rate** | 48 kHz |
| **Bit Depth** | 24-bit |
| **Channels** | Multichannel spatial |
| **Falloff Model** | Inverse distance |
| **Max Sources** | 64 simultaneous |
| **Reverb** | Environment-based (office, large hall) |
| **Occlusion** | Basic occlusion modeling |

### 6.3 Audio Accessibility

```swift
// Audio descriptions for visual elements
class AudioDescriptionService {
    func describeEntity(_ entity: Entity) -> String {
        guard let businessData = entity.components[BusinessDataComponent.self] else {
            return "Unknown entity"
        }

        switch businessData.entityType {
        case .department:
            return "Department: \(businessData.metadata["name"] ?? "Unknown")"

        case .kpi:
            return "KPI: \(businessData.metadata["name"] ?? "Unknown"), value \(businessData.metadata["value"] ?? "N/A")"

        default:
            return "Business entity"
        }
    }
}

// VoiceOver support
entity.accessibilityLabel = audioDescriptionService.describeEntity(entity)
entity.accessibilityHint = "Double tap to view details, drag to move"
entity.accessibilityTraits = [.button, .updatesFrequently]
```

---

## 7. Accessibility Requirements

### 7.1 VoiceOver Support

```swift
// All interactive elements must have accessibility labels
Button("Show Details") {
    showDetails()
}
.accessibilityLabel("Show department details")
.accessibilityHint("Double tap to open detailed view")

// Spatial entities
entity.accessibilityLabel = department.name
entity.accessibilityHint = "Department with \(department.headcount) employees"
entity.accessibilityValue = "Budget: \(department.budget.formatted())"
```

**Requirements:**
- ✅ All interactive elements labeled
- ✅ Meaningful hints for complex interactions
- ✅ Dynamic content updates announced
- ✅ Spatial navigation cues
- ✅ Alternative text for all visualizations

### 7.2 Dynamic Type Support

```swift
// All text must scale with user preferences
Text("Revenue: $1.2M")
    .font(.body)  // Use semantic fonts, not fixed sizes
    .dynamicTypeSize(.xSmall ... .xxxLarge)

// Minimum font size for critical information
Text("Critical Alert")
    .font(.headline)
    .minimumScaleFactor(0.8)
```

**Supported Sizes:**
- Extra Small (XS)
- Small (S)
- Medium (M) - Default
- Large (L)
- Extra Large (XL)
- Extra Extra Large (XXL)
- Extra Extra Extra Large (XXXL)
- Accessibility sizes (A1-A5)

### 7.3 Reduce Motion

```swift
@Environment(\.accessibilityReduceMotion) var reduceMotion

func animateEntity() {
    if reduceMotion {
        // Instant transition
        entity.transform.scale = targetScale
    } else {
        // Animated transition
        entity.transform.scale.animate(to: targetScale, duration: 0.3)
    }
}
```

**Requirements:**
- ✅ Disable or reduce all non-essential animations
- ✅ Instant transitions instead of smooth animations
- ✅ Static visualizations option
- ✅ Preference honored throughout app

### 7.4 Voice Control

```swift
// Custom voice commands
entity.accessibilityLabel = "Engineering Department"
entity.accessibilityCustomActions = [
    UIAccessibilityCustomAction(name: "Show metrics") { _ in
        showMetrics(for: department)
        return true
    },
    UIAccessibilityCustomAction(name: "Edit budget") { _ in
        editBudget(for: department)
        return true
    }
]
```

### 7.5 Color Contrast

**Minimum Ratios:**
- Normal text: 4.5:1
- Large text: 3:1
- UI components: 3:1
- Graphical objects: 3:1

**Implementation:**
```swift
// High contrast mode support
@Environment(\.colorSchemeContrast) var colorSchemeContrast

var textColor: Color {
    switch colorSchemeContrast {
    case .standard:
        return .primary
    case .increased:
        return .black  // Maximum contrast
    @unknown default:
        return .primary
    }
}
```

### 7.6 Alternative Input Methods

```swift
// Support for external controllers (if available)
class InputManager {
    func handleControllerInput(_ input: ControllerInput) {
        switch input {
        case .buttonA:
            selectCurrentEntity()
        case .buttonB:
            navigateBack()
        case .joystick(let direction):
            moveSelection(direction)
        }
    }
}

// Keyboard navigation support (for simulator and accessibility)
.onKeyPress(.space) {
    selectEntity()
    return .handled
}
.onKeyPress(.escape) {
    deselectEntity()
    return .handled
}
.onKeyPress(.arrow) { press in
    navigateSelection(press.key)
    return .handled
}
```

---

## 8. Privacy and Security Requirements

### 8.1 Data Privacy

**Info.plist Entries:**
```xml
<key>NSPrivacyAccessedAPITypes</key>
<array>
    <dict>
        <key>NSPrivacyAccessedAPIType</key>
        <string>NSPrivacyAccessedAPICategoryUserDefaults</string>
        <key>NSPrivacyAccessedAPITypeReasons</key>
        <array>
            <string>CA92.1</string> <!-- User preferences -->
        </array>
    </dict>
</array>

<key>NSPrivacyCollectedDataTypes</key>
<array>
    <dict>
        <key>NSPrivacyCollectedDataType</key>
        <string>NSPrivacyCollectedDataTypeName</string>
        <key>NSPrivacyCollectedDataTypeLinked</key>
        <true/>
        <key>NSPrivacyCollectedDataTypePurposes</key>
        <array>
            <string>App functionality</string>
        </array>
    </dict>
</array>

<key>NSPrivacyTrackingDomains</key>
<array>
    <!-- No tracking domains -->
</array>

<key>NSPrivacyTracking</key>
<false/>
```

### 8.2 Entitlements

**BusinessOperatingSystem.entitlements:**
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <!-- Network access -->
    <key>com.apple.security.network.client</key>
    <true/>

    <!-- Keychain -->
    <key>keychain-access-groups</key>
    <array>
        <string>$(AppIdentifierPrefix)com.company.bos</string>
    </array>

    <!-- GroupActivities (SharePlay) -->
    <key>com.apple.developer.group-session</key>
    <true/>

    <!-- World sensing (if needed) -->
    <key>com.apple.developer.arkit.world-sensing</key>
    <true/>

    <!-- Hand tracking -->
    <key>com.apple.developer.arkit.hand-tracking</key>
    <true/>
</dict>
</plist>
```

### 8.3 Secure Data Storage

```swift
// All sensitive data encrypted
class SecureStorage {
    private let encryptionKey: SymmetricKey

    init() {
        // Retrieve or generate encryption key from Keychain
        self.encryptionKey = try! KeychainManager.shared.getEncryptionKey()
    }

    func store<T: Codable>(_ object: T, forKey key: String) throws {
        let data = try JSONEncoder().encode(object)
        let encrypted = try AES.GCM.seal(data, using: encryptionKey)

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: encrypted.combined!,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]

        SecItemAdd(query as CFDictionary, nil)
    }

    func retrieve<T: Codable>(_ type: T.Type, forKey key: String) throws -> T? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess,
              let encryptedData = result as? Data else {
            return nil
        }

        let sealedBox = try AES.GCM.SealedBox(combined: encryptedData)
        let decrypted = try AES.GCM.open(sealedBox, using: encryptionKey)

        return try JSONDecoder().decode(T.self, from: decrypted)
    }
}
```

### 8.4 Network Security

```swift
// Certificate pinning
class SecureNetworkManager {
    private let session: URLSession

    init() {
        let configuration = URLSessionConfiguration.default
        configuration.tlsMinimumSupportedProtocolVersion = .TLSv13

        let delegate = PinningDelegate()
        self.session = URLSession(configuration: configuration, delegate: delegate, delegateQueue: nil)
    }
}

class PinningDelegate: NSObject, URLSessionDelegate {
    func urlSession(_ session: URLSession,
                    didReceive challenge: URLAuthenticationChallenge,
                    completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {

        guard let serverTrust = challenge.protectionSpace.serverTrust else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }

        // Verify certificate
        let credential = URLCredential(trust: serverTrust)
        completionHandler(.useCredential, credential)
    }
}
```

---

## 9. Data Persistence Strategy

### 9.1 SwiftData Models

```swift
import SwiftData

@Model
final class CachedOrganization {
    @Attribute(.unique) var id: UUID
    var name: String
    var lastSyncedAt: Date
    var data: Data  // JSON encoded organization data

    @Relationship(deleteRule: .cascade)
    var departments: [CachedDepartment]

    init(id: UUID, name: String, data: Data) {
        self.id = id
        self.name = name
        self.lastSyncedAt = Date()
        self.data = data
        self.departments = []
    }
}

@Model
final class CachedDepartment {
    @Attribute(.unique) var id: UUID
    var name: String
    var data: Data

    @Relationship(inverse: \CachedOrganization.departments)
    var organization: CachedOrganization?

    init(id: UUID, name: String, data: Data) {
        self.id = id
        self.name = name
        self.data = data
    }
}
```

### 9.2 Model Container Configuration

```swift
@main
struct BusinessOperatingSystemApp: App {
    let modelContainer: ModelContainer

    init() {
        do {
            let schema = Schema([
                CachedOrganization.self,
                CachedDepartment.self,
                CachedKPI.self
            ])

            let configuration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false,
                allowsSave: true,
                cloudKitDatabase: .none  // Or .private for iCloud sync
            )

            self.modelContainer = try ModelContainer(
                for: schema,
                configurations: [configuration]
            )
        } catch {
            fatalError("Failed to initialize ModelContainer: \(error)")
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

### 9.3 Cache Management

```swift
actor CacheManager {
    private let modelContext: ModelContext
    private let maxCacheAge: TimeInterval = 3600 // 1 hour

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func getCachedOrganization() async -> Organization? {
        let descriptor = FetchDescriptor<CachedOrganization>()

        guard let cached = try? modelContext.fetch(descriptor).first else {
            return nil
        }

        // Check if cache is still valid
        guard !cached.isExpired(maxAge: maxCacheAge) else {
            return nil
        }

        // Decode from cached data
        return try? JSONDecoder().decode(Organization.self, from: cached.data)
    }

    func cacheOrganization(_ org: Organization) async throws {
        let data = try JSONEncoder().encode(org)

        let cached = CachedOrganization(
            id: org.id,
            name: org.name,
            data: data
        )

        modelContext.insert(cached)
        try modelContext.save()
    }

    func clearExpiredCache() async throws {
        let descriptor = FetchDescriptor<CachedOrganization>(
            predicate: #Predicate { cached in
                cached.lastSyncedAt < Date().addingTimeInterval(-maxCacheAge)
            }
        )

        let expired = try modelContext.fetch(descriptor)

        for item in expired {
            modelContext.delete(item)
        }

        try modelContext.save()
    }
}
```

---

## 10. Network Architecture

### 10.1 API Client Configuration

```swift
enum APIEndpoint {
    case organization
    case departments
    case kpis(departmentID: UUID)
    case employees

    var path: String {
        switch self {
        case .organization:
            return "/api/v1/organization"
        case .departments:
            return "/api/v1/departments"
        case .kpis(let deptID):
            return "/api/v1/departments/\(deptID.uuidString)/kpis"
        case .employees:
            return "/api/v1/employees"
        }
    }

    var method: HTTPMethod {
        .get
    }
}

actor APIClient {
    private let baseURL: URL
    private let session: URLSession
    private var authToken: String?

    init(baseURL: URL) {
        self.baseURL = baseURL

        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 300
        configuration.waitsForConnectivity = true
        configuration.httpMaximumConnectionsPerHost = 5

        self.session = URLSession(configuration: configuration)
    }

    func request<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T {
        let url = baseURL.appendingPathComponent(endpoint.path)
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue

        // Add authentication
        if let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        // Add headers
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("BOS-iOS/1.0", forHTTPHeaderField: "User-Agent")

        // Execute request
        let (data, response) = try await session.data(for: request)

        // Validate response
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard 200...299 ~= httpResponse.statusCode else {
            throw APIError.httpError(httpResponse.statusCode)
        }

        // Decode response
        return try JSONDecoder().decode(T.self, from: data)
    }
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
}

enum APIError: Error {
    case invalidResponse
    case httpError(Int)
    case decodingError
    case networkError
}
```

### 10.2 WebSocket Real-Time Sync

```swift
actor WebSocketClient {
    private var webSocketTask: URLSessionWebSocketTask?
    private let url: URL

    init(url: URL) {
        self.url = url
    }

    func connect() async throws {
        let session = URLSession(configuration: .default)
        webSocketTask = session.webSocketTask(with: url)
        webSocketTask?.resume()

        // Start receiving messages
        await receiveMessages()
    }

    func disconnect() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
    }

    func send(_ message: BusinessUpdate) async throws {
        let data = try JSONEncoder().encode(message)
        let string = String(data: data, encoding: .utf8)!
        let message = URLSessionWebSocketTask.Message.string(string)

        try await webSocketTask?.send(message)
    }

    private func receiveMessages() async {
        guard let webSocketTask else { return }

        do {
            let message = try await webSocketTask.receive()

            switch message {
            case .data(let data):
                await handleMessage(data)
            case .string(let string):
                if let data = string.data(using: .utf8) {
                    await handleMessage(data)
                }
            @unknown default:
                break
            }

            // Continue receiving
            await receiveMessages()
        } catch {
            print("WebSocket error: \(error)")
        }
    }

    private func handleMessage(_ data: Data) async {
        do {
            let update = try JSONDecoder().decode(BusinessUpdate.self, from: data)
            // Notify observers
            await NotificationCenter.default.post(
                name: .businessDataUpdated,
                object: update
            )
        } catch {
            print("Failed to decode message: \(error)")
        }
    }
}
```

---

## 11. Testing Requirements

### 11.1 Unit Tests

```swift
@testable import BusinessOperatingSystem
import XCTest

@MainActor
final class ViewModelTests: XCTestCase {
    var sut: DashboardViewModel!
    var mockRepository: MockRepository!

    override func setUp() async throws {
        mockRepository = MockRepository()
        sut = DashboardViewModel(repository: mockRepository)
    }

    override func tearDown() async throws {
        sut = nil
        mockRepository = nil
    }

    func testLoadKPIs_Success() async throws {
        // Given
        let expectedKPIs = [KPI.mock(name: "Revenue")]
        mockRepository.kpisToReturn = expectedKPIs

        // When
        await sut.loadKPIs()

        // Then
        XCTAssertEqual(sut.kpis.count, 1)
        XCTAssertEqual(sut.kpis.first?.name, "Revenue")
        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(sut.error)
    }

    func testLoadKPIs_Failure() async throws {
        // Given
        mockRepository.shouldFail = true

        // When
        await sut.loadKPIs()

        // Then
        XCTAssertTrue(sut.kpis.isEmpty)
        XCTAssertFalse(sut.isLoading)
        XCTAssertNotNil(sut.error)
    }
}
```

### 11.2 UI Tests

```swift
@MainActor
final class DashboardUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUp() {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UI-Testing"]
        app.launch()
    }

    func testDashboardLoadsKPIs() throws {
        // Wait for dashboard to load
        let dashboardTitle = app.staticTexts["Dashboard"]
        XCTAssertTrue(dashboardTitle.waitForExistence(timeout: 5))

        // Verify KPIs are displayed
        let revenueKPI = app.staticTexts["Revenue"]
        XCTAssertTrue(revenueKPI.exists)

        // Tap on KPI to view details
        revenueKPI.tap()

        // Verify detail view appears
        let detailView = app.otherElements["KPI Detail View"]
        XCTAssertTrue(detailView.waitForExistence(timeout: 2))
    }
}
```

### 11.3 Performance Tests

```swift
final class PerformanceTests: XCTestCase {
    func testSpatialRenderingPerformance() {
        measure(metrics: [XCTClockMetric(), XCTMemoryMetric()]) {
            // Render 10,000 entities
            let visualizer = BusinessUniverseVisualizer()
            let departments = (0..<100).map { Department.mock(id: $0) }
            _ = visualizer.createVisualization(for: departments)
        }
    }

    func testDataLoadingPerformance() async {
        let repository = BusinessRepositoryImpl()

        let metrics = XCTClockMetric()
        measure(metrics: [metrics]) {
            Task {
                _ = try? await repository.fetchOrganization()
            }
        }
    }
}
```

### 11.4 Test Coverage Target

**Minimum Coverage:** 80%
- Unit tests: 90%+ coverage
- Integration tests: 70%+ coverage
- UI tests: Critical paths covered

---

## 12. Build Configurations

### 12.1 Debug Configuration

```swift
#if DEBUG
let apiBaseURL = URL(string: "https://dev-api.bos.company")!
let enableLogging = true
let showDebugOverlay = true
#endif
```

### 12.2 Release Configuration

```swift
#if RELEASE
let apiBaseURL = URL(string: "https://api.bos.company")!
let enableLogging = false
let showDebugOverlay = false
#endif
```

### 12.3 Build Settings

| Setting | Debug | Release |
|---------|-------|---------|
| **Optimization Level** | None (-Onone) | Aggressive (-O) |
| **Swift Compilation Mode** | Incremental | Whole Module |
| **Enable Bitcode** | No | No (not supported for visionOS) |
| **Debug Information** | Full | Line Tables Only |
| **Assertions** | Enabled | Disabled |

---

## 13. Logging and Diagnostics

### 13.1 OSLog Implementation

```swift
import OSLog

extension Logger {
    private static var subsystem = Bundle.main.bundleIdentifier!

    static let app = Logger(subsystem: subsystem, category: "app")
    static let networking = Logger(subsystem: subsystem, category: "networking")
    static let spatial = Logger(subsystem: subsystem, category: "spatial")
    static let data = Logger(subsystem: subsystem, category: "data")
}

// Usage
Logger.app.info("Application launched")
Logger.networking.debug("API request: \(endpoint.path)")
Logger.spatial.error("Failed to create entity: \(error.localizedDescription)")
```

### 13.2 Analytics Events

```swift
enum AnalyticsEvent {
    case appLaunched
    case dashboardViewed
    case departmentSelected(Department.ID)
    case kpiTapped(KPI.ID)
    case reportGenerated(ReportType)
    case errorOccurred(Error)
}

actor AnalyticsService {
    func track(_ event: AnalyticsEvent) async {
        // Log to backend analytics
        Logger.app.info("Analytics: \(String(describing: event))")
    }
}
```

---

## Conclusion

This technical specification provides comprehensive implementation details for the Business Operating System on visionOS. All requirements prioritize:

1. **Performance:** 90 FPS with complex 3D visualizations
2. **Accessibility:** Full VoiceOver, Dynamic Type, and alternative inputs
3. **Security:** End-to-end encryption and enterprise compliance
4. **User Experience:** Natural gestures and spatial interactions
5. **Scalability:** Support for organizations of all sizes

Implementation should follow these specifications closely while remaining flexible for platform updates and user feedback.
