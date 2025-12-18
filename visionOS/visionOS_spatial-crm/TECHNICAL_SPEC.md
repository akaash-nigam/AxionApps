# Spatial CRM - Technical Specifications

## 1. Technology Stack

### 1.1 Core Technologies

| Component | Technology | Version | Purpose |
|-----------|-----------|---------|---------|
| Language | Swift | 6.0+ | Primary development language |
| UI Framework | SwiftUI | visionOS 2.0+ | Declarative UI |
| 3D Engine | RealityKit | visionOS 2.0+ | 3D rendering and spatial content |
| Spatial Tracking | ARKit | visionOS 2.0+ | Hand/eye tracking, spatial anchors |
| Data Persistence | SwiftData | visionOS 2.0+ | Local data storage |
| Networking | URLSession | Native | API communication |
| Concurrency | Swift Concurrency | Swift 6.0 | async/await, actors |
| Testing | Swift Testing | Xcode 16+ | Unit and UI testing |

### 1.2 Development Tools

- **Xcode**: 16.0 or later
- **Reality Composer Pro**: 3D asset creation and optimization
- **Instruments**: Performance profiling
- **visionOS Simulator**: Development and testing
- **TestFlight**: Beta distribution
- **Git**: Version control

### 1.3 Third-Party Dependencies (via SPM)

```swift
// Package.swift
dependencies: [
    .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.9.0"),
    .package(url: "https://github.com/onevcat/Kingfisher.git", from: "7.10.0"),
    .package(url: "https://github.com/krzyzanowskim/CryptoSwift.git", from: "1.8.0")
]
```

## 2. visionOS Presentation Modes

### 2.1 WindowGroup Configuration

#### Main Dashboard Window
```swift
WindowGroup("Dashboard", id: "dashboard") {
    DashboardView()
        .environment(appState)
}
.windowStyle(.plain)
.defaultSize(width: 1400, height: 900)
.windowResizability(.contentSize)
```

**Specifications:**
- **Default Size**: 1400x900 points
- **Minimum Size**: 800x600 points
- **Maximum Size**: 2400x1600 points
- **Materials**: Glass with vibrancy
- **Ornaments**: Toolbar, tabs, inspector panels

#### Customer Detail Window
```swift
WindowGroup("Customer", id: "customer-detail", for: UUID.self) { $customerId in
    CustomerDetailView(customerId: customerId)
}
.defaultSize(width: 1000, height: 700)
```

#### Quick Actions Panel
```swift
WindowGroup("Quick Actions", id: "quick-actions") {
    QuickActionsView()
}
.defaultSize(width: 400, height: 600)
.windowStyle(.plain)
.defaultWindowPlacement { content, context in
    return WindowPlacement(.trailing)
}
```

### 2.2 Volumetric Windows

#### Pipeline Volume
```swift
WindowGroup("Pipeline", id: "pipeline-volume") {
    PipelineVolumeView()
}
.windowStyle(.volumetric)
.defaultSize(width: 2.0, height: 1.5, depth: 1.0, in: .meters)
```

**Specifications:**
- **Size**: 2m x 1.5m x 1.0m
- **Content**: 3D pipeline flow visualization
- **Interactions**: Drag deals between stages
- **Visual Style**: Glass container with flowing particles

#### Relationship Network Volume
```swift
WindowGroup("Network", id: "network-volume") {
    RelationshipNetworkView()
}
.windowStyle(.volumetric)
.defaultSize(width: 1.5, height: 1.5, depth: 1.5, in: .meters)
```

**Specifications:**
- **Size**: 1.5m cubic
- **Content**: Force-directed graph of contacts
- **Interactions**: Pinch to select, drag to reposition
- **Physics**: Real-time force simulation

### 2.3 Immersive Spaces

#### Customer Galaxy
```swift
ImmersiveSpace(id: "customer-galaxy") {
    CustomerGalaxyView()
}
.immersionStyle(selection: .constant(.mixed), in: .mixed, .progressive, .full)
```

**Specifications:**
- **Modes**: Mixed, Progressive, Full
- **Default**: Mixed (shows passthrough)
- **Scale**: Infinite (user can walk around)
- **Content**: Solar system visualization
- **Interactions**: Gaze + pinch navigation

#### Territory Explorer
```swift
ImmersiveSpace(id: "territory-explorer") {
    TerritoryExplorerView()
}
.immersionStyle(selection: .constant(.full), in: .full)
```

**Specifications:**
- **Mode**: Full immersion
- **Content**: 360° terrain map
- **Navigation**: Walk-through experience
- **Scale**: Room-scale (3m x 3m recommended)

## 3. Gesture and Interaction Specifications

### 3.1 Standard Gestures

| Gesture | Implementation | Use Case | Code Example |
|---------|---------------|----------|--------------|
| Tap | `.onTapGesture` | Select entity | `entity.onTapGesture { selectCustomer() }` |
| Long Press | `.onLongPressGesture` | Context menu | `entity.onLongPressGesture { showMenu() }` |
| Drag | `.gesture(DragGesture3D())` | Move entity | `entity.gesture(DragGesture3D())` |
| Pinch | `.gesture(MagnifyGesture())` | Scale/zoom | `entity.gesture(MagnifyGesture())` |
| Rotate | `.gesture(RotateGesture3D())` | Rotate view | `entity.gesture(RotateGesture3D())` |

### 3.2 Custom Spatial Gestures

```swift
// Deal Stage Progression Gesture
struct StageProgressGesture: Gesture {
    @State private var isDragging = false
    @State private var dragOffset: SIMD3<Float> = .zero

    var body: some Gesture {
        DragGesture3D()
            .onChanged { value in
                isDragging = true
                dragOffset = value.translation3D
                // Snap to stage boundaries
                updateDealStage(based: dragOffset)
            }
            .onEnded { _ in
                isDragging = false
                commitStageChange()
            }
    }
}

// Relationship Connection Gesture
struct ConnectContactsGesture: Gesture {
    @State private var startContact: Contact?
    @State private var endContact: Contact?

    var body: some Gesture {
        DragGesture3D()
            .onChanged { value in
                if startContact == nil {
                    startContact = hitTest(at: value.startLocation3D)
                }
                endContact = hitTest(at: value.location3D)
                drawConnectionLine(from: startContact, to: endContact)
            }
            .onEnded { _ in
                createRelationship(from: startContact, to: endContact)
            }
    }
}
```

### 3.3 Gaze-Based Interactions

```swift
struct GazeInteraction: View {
    @State private var isGazing = false
    @State private var gazeDuration: TimeInterval = 0

    var body: some View {
        CustomerEntityView()
            .hoverEffect()
            .onContinuousHover { phase in
                switch phase {
                case .active(let location):
                    isGazing = true
                    startGazeTimer()
                case .ended:
                    isGazing = false
                    resetGazeTimer()
                }
            }
    }

    func startGazeTimer() {
        // Show quick preview after 0.5s
        // Show full details after 1.5s
    }
}
```

## 4. Hand Tracking Implementation

### 4.1 Hand Skeleton Tracking

```swift
import ARKit

@Observable
class HandTrackingService {
    private var session: ARKitSession?
    private var handTracking: HandTrackingProvider?

    func startTracking() async {
        let session = ARKitSession()
        let handTracking = HandTrackingProvider()

        do {
            try await session.run([handTracking])
            self.session = session
            self.handTracking = handTracking

            for await update in handTracking.anchorUpdates {
                handleHandUpdate(update)
            }
        } catch {
            print("Hand tracking failed: \(error)")
        }
    }

    func handleHandUpdate(_ update: AnchorUpdate<HandAnchor>) {
        switch update.event {
        case .added, .updated:
            let hand = update.anchor
            // Process hand joints
            processHandGesture(hand)
        case .removed:
            break
        }
    }

    func processHandGesture(_ hand: HandAnchor) {
        // Detect custom gestures
        if isPinchGesture(hand) {
            handlePinch()
        } else if isPointingGesture(hand) {
            handlePointing()
        }
    }
}
```

### 4.2 Custom Hand Gestures

```swift
// Victory Sign = Close Deal
func detectVictorySign(_ hand: HandAnchor) -> Bool {
    let indexExtended = hand.handSkeleton.joint(.indexFingerTip).isTracked
    let middleExtended = hand.handSkeleton.joint(.middleFingerTip).isTracked
    let othersClosed = !hand.handSkeleton.joint(.ringFingerTip).isTracked

    return indexExtended && middleExtended && othersClosed
}

// Fist = Delete/Remove
func detectFist(_ hand: HandAnchor) -> Bool {
    let allFingersClosed = hand.handSkeleton.allJoints
        .filter { $0.name.rawValue.contains("Tip") }
        .allSatisfy { !$0.isTracked }

    return allFingersClosed
}

// Open Palm = Home/Reset
func detectOpenPalm(_ hand: HandAnchor) -> Bool {
    let allFingersExtended = hand.handSkeleton.allJoints
        .filter { $0.name.rawValue.contains("Tip") }
        .allSatisfy { $0.isTracked }

    return allFingersExtended
}
```

## 5. Eye Tracking Implementation

### 5.1 Eye Tracking for Focus

```swift
import ARKit

@Observable
class EyeTrackingService {
    private var session: ARKitSession?
    private var eyeTracking: EyeTrackingProvider?

    func startTracking() async {
        guard EyeTrackingProvider.isSupported else {
            print("Eye tracking not supported")
            return
        }

        let session = ARKitSession()
        let eyeTracking = EyeTrackingProvider()

        do {
            try await session.run([eyeTracking])
            self.session = session
            self.eyeTracking = eyeTracking

            for await update in eyeTracking.anchorUpdates {
                handleEyeUpdate(update)
            }
        } catch {
            print("Eye tracking failed: \(error)")
        }
    }

    func handleEyeUpdate(_ update: AnchorUpdate<EyeAnchor>) {
        switch update.event {
        case .updated:
            let eyeAnchor = update.anchor
            // Get gaze direction
            let gazeDirection = eyeAnchor.lookAtPoint
            highlightEntityUnderGaze(at: gazeDirection)
        default:
            break
        }
    }
}
```

### 5.2 Gaze-Aware UI

```swift
struct GazeAwareButton: View {
    @State private var isGazedAt = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text("Action")
        }
        .buttonStyle(.bordered)
        .scaleEffect(isGazedAt ? 1.1 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isGazedAt)
        .hoverEffect()
    }
}
```

## 6. Spatial Audio Specifications

### 6.1 Audio Feedback System

```swift
import AVFoundation
import RealityKit

@Observable
class SpatialAudioService {
    private var audioController: AudioPlaybackController?

    // Deal closure celebration
    func playDealClosedSound(at position: SIMD3<Float>) async {
        let resource = try? await AudioFileResource(
            named: "deal-closed.wav",
            from: "Sounds.bundle"
        )

        guard let resource else { return }

        let entity = Entity()
        entity.position = position

        let audioController = entity.prepareAudio(resource)
        audioController.play()
        audioController.spatialBlendingMode = .automatic
    }

    // Notification chime
    func playNotificationSound(type: NotificationType) {
        let soundName = switch type {
        case .newLead: "new-lead.wav"
        case .dealAtRisk: "alert.wav"
        case .taskDue: "reminder.wav"
        }

        playSound(named: soundName)
    }

    // Ambient territory sounds
    func playTerritoryAmbience(for territory: Territory) {
        let ambience = switch territory.performance {
        case .excellent: "success-ambience.wav"
        case .good: "neutral-ambience.wav"
        case .poor: "warning-ambience.wav"
        }

        playAmbientSound(named: ambience)
    }
}
```

### 6.2 Voice Feedback

```swift
import AVFoundation

@Observable
class VoiceService {
    private let synthesizer = AVSpeechSynthesizer()

    func announce(_ text: String, priority: Priority = .normal) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.5

        switch priority {
        case .high:
            utterance.volume = 1.0
        case .normal:
            utterance.volume = 0.7
        case .low:
            utterance.volume = 0.4
        }

        synthesizer.speak(utterance)
    }

    // AI insights narration
    func narrateInsight(_ insight: AIInsight) {
        let text = "AI Insight: \(insight.title). \(insight.description)"
        announce(text, priority: .high)
    }
}
```

## 7. Accessibility Requirements

### 7.1 VoiceOver Support

```swift
struct AccessibleCustomerCard: View {
    let customer: Account

    var body: some View {
        CustomerCardView(customer: customer)
            .accessibilityLabel("\(customer.name), \(customer.industry)")
            .accessibilityValue("Revenue: \(customer.revenue.formatted(.currency(code: "USD")))")
            .accessibilityHint("Double tap to view details")
            .accessibilityAddTraits(.isButton)
            .accessibilityAction(.magicTap) {
                openCustomerDetails()
            }
    }
}
```

### 7.2 Dynamic Type Support

```swift
struct ScalableText: View {
    let text: String
    @Environment(\.dynamicTypeSize) var dynamicTypeSize

    var body: some View {
        Text(text)
            .font(.headline)
            .dynamicTypeSize(.large...(.accessibility3))
            .lineLimit(nil)
    }
}
```

### 7.3 Reduce Motion Support

```swift
struct AnimatedView: View {
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        CustomerGalaxyView()
            .animation(
                reduceMotion ? .none : .easeInOut(duration: 0.5),
                value: customers
            )
    }
}
```

### 7.4 High Contrast Mode

```swift
struct ThemedView: View {
    @Environment(\.colorSchemeContrast) var contrast

    var body: some View {
        Text("Customer Name")
            .foregroundStyle(
                contrast == .increased ? .primary : .secondary
            )
    }
}
```

### 7.5 Alternative Interactions

- **Voice Commands**: Full voice control for all actions
- **Controller Support**: Xbox/PlayStation controller navigation
- **Keyboard Shortcuts**: Mac keyboard integration
- **Switch Control**: For users with limited mobility

## 8. Privacy and Security Requirements

### 8.1 Data Protection

```swift
// Encrypted data model
@Model
class SecureAccount {
    @Attribute(.unique) var id: UUID

    @Attribute(.encrypted)
    var revenue: Decimal

    @Attribute(.encrypted)
    var contactEmail: String

    @Attribute(.allowsCloudEncryption)
    var notes: String
}
```

### 8.2 Privacy Permissions

```swift
// Info.plist entries required
<key>NSCameraUsageDescription</key>
<string>Camera access is needed for spatial tracking</string>

<key>NSMicrophoneUsageDescription</key>
<string>Microphone access is needed for voice commands and call recording</string>

<key>NSHandsTrackingUsageDescription</key>
<string>Hand tracking enables natural gesture interactions</string>
```

### 8.3 Biometric Authentication

```swift
import LocalAuthentication

class BiometricAuthService {
    func authenticate() async throws -> Bool {
        let context = LAContext()
        var error: NSError?

        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            throw AuthError.biometricsNotAvailable
        }

        let reason = "Authenticate to access CRM data"
        return try await context.evaluatePolicy(
            .deviceOwnerAuthenticationWithBiometrics,
            localizedReason: reason
        )
    }
}
```

### 8.4 Data Minimization

- Only collect essential customer data
- Anonymize analytics data
- Regular data purging (configurable retention)
- No tracking across apps
- Opt-in for telemetry

## 9. Data Persistence Strategy

### 9.1 SwiftData Configuration

```swift
import SwiftData

@main
struct SpatialCRMApp: App {
    let modelContainer: ModelContainer

    init() {
        let schema = Schema([
            Account.self,
            Contact.self,
            Opportunity.self,
            Activity.self,
            Territory.self,
            SalesRep.self
        ])

        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            allowsSave: true,
            cloudKitDatabase: .private("iCloud.com.company.spatialcrm")
        )

        do {
            modelContainer = try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
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

### 9.2 Caching Strategy

```swift
@Observable
class CacheManager {
    private let memoryCache = NSCache<NSString, AnyObject>()
    private let diskCache: URL

    init() {
        diskCache = FileManager.default
            .urls(for: .cachesDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("SpatialCRM")
    }

    // Three-tier caching
    func fetch<T: Codable>(key: String) async throws -> T? {
        // 1. Check memory cache
        if let cached = memoryCache.object(forKey: key as NSString) as? T {
            return cached
        }

        // 2. Check disk cache
        let fileURL = diskCache.appendingPathComponent(key)
        if let data = try? Data(contentsOf: fileURL),
           let object = try? JSONDecoder().decode(T.self, from: data) {
            memoryCache.setObject(object as AnyObject, forKey: key as NSString)
            return object
        }

        // 3. Fetch from network
        return nil
    }
}
```

### 9.3 CloudKit Sync

```swift
import CloudKit

@Observable
class CloudSyncService {
    private let container = CKContainer(identifier: "iCloud.com.company.spatialcrm")
    private let database: CKDatabase

    init() {
        database = container.privateCloudDatabase
    }

    func syncAccounts() async throws {
        let query = CKQuery(recordType: "Account", predicate: NSPredicate(value: true))
        let results = try await database.records(matching: query)

        for (_, result) in results.matchResults {
            let record = try result.get()
            await processRecord(record)
        }
    }
}
```

## 10. Network Architecture

### 10.1 API Client

```swift
@Observable
class APIClient {
    private let baseURL = URL(string: "https://api.spatialcrm.com/v1")!
    private let session: URLSession

    init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 300
        configuration.httpMaximumConnectionsPerHost = 5
        configuration.requestCachePolicy = .returnCacheDataElseLoad

        session = URLSession(configuration: configuration)
    }

    func request<T: Codable>(
        endpoint: String,
        method: HTTPMethod = .get,
        body: Encodable? = nil
    ) async throws -> T {
        var request = URLRequest(url: baseURL.appendingPathComponent(endpoint))
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")

        if let body {
            request.httpBody = try JSONEncoder().encode(body)
        }

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw APIError.invalidResponse
        }

        return try JSONDecoder().decode(T.self, from: data)
    }
}
```

### 10.2 Request Batching

```swift
@Observable
class BatchRequestService {
    private var pendingRequests: [APIRequest] = []
    private let batchInterval: TimeInterval = 0.5

    func enqueue(_ request: APIRequest) {
        pendingRequests.append(request)

        if pendingRequests.count >= 10 {
            Task { await flushBatch() }
        }
    }

    private func flushBatch() async {
        guard !pendingRequests.isEmpty else { return }

        let batch = pendingRequests
        pendingRequests.removeAll()

        let batchRequest = BatchRequest(requests: batch)
        do {
            let results = try await apiClient.request(
                endpoint: "/batch",
                method: .post,
                body: batchRequest
            )
            processBatchResults(results)
        } catch {
            handleBatchError(error, requests: batch)
        }
    }
}
```

### 10.3 Offline Queue

```swift
@Observable
class OfflineQueueService {
    @AppStorage("offlineQueue") private var queueData: Data = Data()
    private var queue: [QueuedOperation] = []

    func enqueue(_ operation: QueuedOperation) {
        queue.append(operation)
        persistQueue()
    }

    func processQueue() async {
        for operation in queue {
            do {
                try await executeOperation(operation)
                removeFromQueue(operation)
            } catch {
                operation.retryCount += 1
                if operation.retryCount > 3 {
                    operation.failed = true
                }
            }
        }
    }

    private func persistQueue() {
        queueData = (try? JSONEncoder().encode(queue)) ?? Data()
    }
}
```

## 11. Testing Requirements

### 11.1 Unit Test Coverage

```swift
@Test("Account health score calculation")
func testHealthScoreCalculation() async throws {
    let account = Account.sample
    account.activities = [
        Activity(type: .meeting, completedAt: .now),
        Activity(type: .email, completedAt: .now.addingTimeInterval(-86400))
    ]

    let healthScore = await HealthScoreCalculator.calculate(for: account)
    #expect(healthScore >= 0 && healthScore <= 100)
}

@Test("Deal stage progression")
func testDealProgression() {
    let opportunity = Opportunity.sample
    opportunity.stage = .qualification

    opportunity.progress(to: .needsAnalysis)
    #expect(opportunity.stage == .needsAnalysis)
    #expect(opportunity.activities.last?.type == .stageChange)
}
```

### 11.2 UI Testing

```swift
@MainActor
@Test("Pipeline view interaction")
func testPipelineInteraction() throws {
    let app = XCUIApplication()
    app.launch()

    // Navigate to pipeline
    app.buttons["Pipeline"].tap()

    // Verify opportunities are displayed
    let pipelineView = app.windows["Pipeline"]
    #expect(pipelineView.exists)

    // Test drag gesture
    let dealCard = pipelineView.otherElements["Deal Card"].firstMatch
    #expect(dealCard.exists)

    // Drag to next stage
    dealCard.press(forDuration: 0.5, thenDragTo: app.otherElements["Proposal Stage"])

    // Verify stage updated
    #expect(dealCard.label.contains("Proposal"))
}
```

### 11.3 Performance Testing

```swift
@Test("Render 1000 customers in galaxy view")
func testGalaxyPerformance() async throws {
    let customers = (0..<1000).map { _ in Account.sample }

    measure {
        let galaxyView = CustomerGalaxyView(accounts: customers)
        // Measure render time
        _ = galaxyView.body
    }

    // Assert under performance budget
    #expect(averageRenderTime < 0.016) // 60 FPS = 16ms per frame
}
```

### 11.4 Accessibility Testing

```swift
@Test("VoiceOver navigation")
@MainActor
func testVoiceOverSupport() throws {
    let app = XCUIApplication()
    app.launch()

    // Enable VoiceOver
    app.activate()
    XCUIDevice.shared.press(.voiceOver)

    // Navigate through elements
    app.typeKey(.rightArrow, modifierFlags: [.control, .option])

    // Verify element is accessible
    #expect(app.staticTexts.firstMatch.isAccessibilityElement)
}
```

## 12. Development Workflows

### 12.1 Git Branching Strategy

```
main (production)
  ├── develop (integration)
  │   ├── feature/customer-galaxy
  │   ├── feature/pipeline-view
  │   ├── feature/ai-insights
  │   └── bugfix/sync-issue
  └── hotfix/critical-bug
```

### 12.2 Code Review Checklist

- [ ] Follows Swift style guide
- [ ] No force unwraps (!)
- [ ] Proper error handling
- [ ] Unit tests included
- [ ] UI tests for new features
- [ ] Accessibility labels added
- [ ] Performance profiled
- [ ] Documentation updated
- [ ] No memory leaks
- [ ] Concurrency safety verified

### 12.3 CI/CD Pipeline

```yaml
# .github/workflows/ios.yml
name: visionOS Build

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]

jobs:
  build:
    runs-on: macos-14
    steps:
      - uses: actions/checkout@v4
      - name: Setup Xcode
        run: sudo xcode-select -s /Applications/Xcode_16.0.app
      - name: Build
        run: xcodebuild -scheme SpatialCRM -destination 'platform=visionOS Simulator,name=Apple Vision Pro'
      - name: Test
        run: xcodebuild test -scheme SpatialCRM -destination 'platform=visionOS Simulator,name=Apple Vision Pro'
```

## 13. Monitoring and Analytics

### 13.1 Crash Reporting

```swift
import OSLog

class CrashReporter {
    static let shared = CrashReporter()
    private let logger = Logger(subsystem: "com.company.spatialcrm", category: "crashes")

    func reportCrash(_ error: Error, context: [String: Any] = [:]) {
        logger.error("Crash: \(error.localizedDescription)")
        logger.error("Context: \(context)")

        // Send to analytics service
        Task {
            await analyticsService.logError(error, context: context)
        }
    }
}
```

### 13.2 Performance Monitoring

```swift
import os.signpost

class PerformanceMonitor {
    private let log = OSLog(subsystem: "com.company.spatialcrm", category: .pointsOfInterest)

    func measure<T>(_ operation: String, block: () async throws -> T) async rethrows -> T {
        let signpostID = OSSignpostID(log: log)
        os_signpost(.begin, log: log, name: "Performance", signpostID: signpostID, "%{public}s", operation)

        let result = try await block()

        os_signpost(.end, log: log, name: "Performance", signpostID: signpostID)
        return result
    }
}
```

### 13.3 Usage Analytics

```swift
class AnalyticsService {
    func trackEvent(_ event: AnalyticsEvent) {
        let eventData: [String: Any] = [
            "name": event.name,
            "timestamp": Date(),
            "properties": event.properties,
            "user_id": currentUser?.id.uuidString ?? "unknown"
        ]

        // Send to analytics backend
        Task {
            try? await apiClient.request(
                endpoint: "/analytics/events",
                method: .post,
                body: eventData
            )
        }
    }

    func trackScreenView(_ screen: String) {
        trackEvent(AnalyticsEvent(name: "screen_view", properties: ["screen": screen]))
    }

    func trackFeatureUsage(_ feature: String) {
        trackEvent(AnalyticsEvent(name: "feature_used", properties: ["feature": feature]))
    }
}
```

---

## Appendix A: Build Configurations

### Debug Configuration
- Swift optimization: `-Onone`
- Debug symbols: Enabled
- Assertions: Enabled
- Logging: Verbose

### Release Configuration
- Swift optimization: `-O`
- Debug symbols: Stripped
- Assertions: Disabled
- Logging: Errors only
- Bitcode: Enabled

## Appendix B: Performance Benchmarks

| Metric | Target | Acceptable | Critical |
|--------|--------|-----------|----------|
| Frame Rate | 90 FPS | 60 FPS | <30 FPS |
| App Launch | <2s | <3s | >5s |
| Search Response | <100ms | <200ms | >500ms |
| Sync Latency | <500ms | <1s | >2s |
| Memory Usage | <300MB | <500MB | >800MB |
| Battery/Hour | <5% | <8% | >10% |

## Appendix C: Security Compliance

- **GDPR**: Full compliance
- **CCPA**: California privacy compliance
- **SOC 2**: Type II certified
- **HIPAA**: Healthcare data support (optional)
- **ISO 27001**: Information security management

## Appendix D: Required Capabilities

```xml
<!-- SpatialCRM.entitlements -->
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.developer.arkit.hand-tracking</key>
    <true/>
    <key>com.apple.developer.arkit.eye-tracking</key>
    <true/>
    <key>com.apple.security.app-sandbox</key>
    <true/>
    <key>com.apple.security.network.client</key>
    <true/>
    <key>com.apple.developer.icloud-container-identifiers</key>
    <array>
        <string>iCloud.com.company.spatialcrm</string>
    </array>
</dict>
</plist>
```
