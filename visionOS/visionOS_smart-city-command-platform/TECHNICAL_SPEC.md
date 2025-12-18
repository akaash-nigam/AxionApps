# Smart City Command Platform - Technical Specifications

## 1. Technology Stack

### 1.1 Core Technologies

#### Platform & Language
- **visionOS**: 2.0+ (minimum deployment target)
- **Swift**: 6.0+ with strict concurrency enabled
- **Xcode**: 16.0+ with visionOS SDK
- **Swift Concurrency**: async/await, actors, TaskGroup

#### UI Framework
- **SwiftUI**: Primary UI framework
- **RealityKit**: 3D rendering and spatial content
- **ARKit**: Spatial tracking and scene understanding
- **RealityKit Audio**: Spatial audio implementation

#### Data & Persistence
- **SwiftData**: Primary data persistence layer
- **CloudKit**: Optional cloud sync for multi-device
- **Core Location**: Geographic coordinate handling
- **Combine**: Reactive data streams (where needed)

#### Networking
- **URLSession**: HTTP/HTTPS communication
- **WebSocket**: Real-time data streaming
- **MQTT**: IoT sensor data ingestion (via third-party)

### 1.2 External Dependencies (Swift Package Manager)

```swift
// Package.swift dependencies
dependencies: [
    // MQTT client for IoT integration
    .package(url: "https://github.com/emqx/CocoaMQTT.git", from: "2.1.0"),

    // GeoJSON parsing
    .package(url: "https://github.com/GEOSwift/GEOSwift.git", from: "10.0.0"),

    // Charting and analytics visualization
    .package(url: "https://github.com/danielgindi/Charts.git", from: "5.0.0"),
]
```

### 1.3 Development Tools

- **Reality Composer Pro**: 3D asset creation and scene composition
- **Instruments**: Performance profiling and optimization
- **visionOS Simulator**: Development and testing
- **XCTest**: Unit and UI testing framework
- **Git**: Version control

## 2. visionOS Presentation Modes

### 2.1 WindowGroup Configurations

#### Primary Operations Center Window
```swift
WindowGroup("City Operations Center", id: "operations-center") {
    OperationsCenterView()
        .frame(minWidth: 1200, idealWidth: 1400, maxWidth: 1800,
               minHeight: 800, idealHeight: 900, maxHeight: 1200)
}
.windowStyle(.plain)
.windowResizability(.contentSize)
.defaultSize(width: 1400, height: 900)
.defaultWorldSizing(.fixed)
```

**Features**:
- Real-time city status dashboard
- Department coordination panels
- Critical alerts and notifications
- Quick action controls
- Communication hub

**Ergonomics**:
- Default distance: 1.5m from user
- Viewing angle: 10° below eye level
- Always accessible, cannot be dismissed

#### Analytics Dashboard Window
```swift
WindowGroup("City Analytics", id: "analytics") {
    AnalyticsDashboardView()
}
.defaultSize(width: 1000, height: 700)
.windowStyle(.automatic)
```

**Features**:
- Performance metrics and KPIs
- Trend analysis and charts
- Predictive analytics visualizations
- Comparative reports

#### Emergency Command Window
```swift
WindowGroup("Emergency Command", id: "emergency-command") {
    EmergencyCommandView()
}
.defaultSize(width: 1200, height: 800)
.windowStyle(.plain)
```

**Features**:
- Active incident tracking
- Multi-agency coordination
- Resource deployment controls
- Real-time communications

### 2.2 Volumetric Windows

#### 3D City Model Volume
```swift
WindowGroup("3D City Model", id: "city-3d") {
    City3DModelView()
}
.windowStyle(.volumetric)
.defaultSize(width: 1000, height: 800, depth: 600)
.defaultWorldSizing(.volumetric(meters: 1.0, 0.8, 0.6))
```

**Content**:
- Interactive 3D city visualization
- Building-level detail
- Infrastructure layer toggles
- Real-time sensor overlays
- Traffic flow visualization

**Interactions**:
- Rotate: Two-handed rotation gesture
- Zoom: Pinch to scale
- Pan: Drag gesture
- Select: Tap on buildings/infrastructure

#### Infrastructure Systems Volume
```swift
WindowGroup("Infrastructure", id: "infrastructure-3d") {
    InfrastructureVolumeView()
}
.windowStyle(.volumetric)
.defaultSize(width: 800, height: 600, depth: 400)
```

**Content**:
- Underground utility networks
- Power grid visualization
- Water/sewage systems
- Telecommunications infrastructure

### 2.3 ImmersiveSpace Experiences

#### Full City Immersion
```swift
ImmersiveSpace(id: "city-immersive") {
    CityImmersiveView()
}
.immersionStyle(selection: $immersionLevel, in: .progressive)
.upperLimbVisibility(.visible)
```

**Immersion Levels**:
- **Progressive (default)**: Blended with passthrough
- **Full**: Complete immersion for crisis scenarios

**Features**:
- Walk/fly through city streets
- First-person infrastructure inspection
- Immersive incident command
- Planning scenario simulations

**Transitions**:
```swift
@Environment(\.openImmersiveSpace) var openImmersive
@Environment(\.dismissImmersiveSpace) var dismissImmersive

// Enter immersive mode
await openImmersive(id: "city-immersive")

// Exit immersive mode
await dismissImmersive()
```

#### Crisis Management Immersive Space
```swift
ImmersiveSpace(id: "crisis-management") {
    CrisisManagementImmersiveView()
}
.immersionStyle(selection: .constant(.full), in: .full)
```

**Usage**: Major incident command and coordination

## 3. Gesture and Interaction Specifications

### 3.1 Standard visionOS Interactions

#### Gaze + Pinch (Primary Interaction)
```swift
// Tap gesture on entity
var tapGesture: some Gesture {
    TapGesture()
        .targetedToAnyEntity()
        .onEnded { event in
            handleEntityTap(event.entity)
        }
}

// Long press for context menu
var longPressGesture: some Gesture {
    LongPressGesture(minimumDuration: 0.5)
        .targetedToAnyEntity()
        .onEnded { event in
            showContextMenu(for: event.entity)
        }
}
```

**Applications**:
- Select buildings/infrastructure
- Activate controls and buttons
- Deploy emergency resources
- Place annotations

#### Drag Gestures
```swift
var dragGesture: some Gesture {
    DragGesture()
        .targetedToAnyEntity()
        .onChanged { event in
            updateEntityPosition(event.entity, by: event.translation3D)
        }
        .onEnded { event in
            finalizeEntityPosition(event.entity)
        }
}
```

**Applications**:
- Move windows and panels
- Reposition 3D elements
- Draw measurement lines
- Define areas of interest

#### Rotate and Scale
```swift
var magnifyGesture: some Gesture {
    MagnifyGesture()
        .targetedToAnyEntity()
        .onChanged { event in
            scaleEntity(event.entity, by: event.magnification)
        }
}

var rotateGesture: some Gesture {
    RotateGesture3D()
        .targetedToAnyEntity()
        .onChanged { event in
            rotateEntity(event.entity, by: event.rotation)
        }
}
```

### 3.2 Custom City Command Gestures

#### Emergency Response Gesture (Double Tap)
```swift
var emergencyGesture: some Gesture {
    TapGesture(count: 2)
        .targetedToAnyEntity()
        .onEnded { event in
            triggerEmergencyResponse(at: event.entity)
        }
}
```

**Behavior**: Immediately activates emergency protocol for tapped location

#### Resource Deployment (Point + Hold + Release)
```swift
// Custom gesture recognizer
class ResourceDeploymentGesture {
    func recognizeGesture(_ handAnchor: HandAnchor) -> Bool {
        // Detect pointing gesture (index finger extended)
        // Hold for 1 second
        // Release to confirm deployment
    }
}
```

#### Measurement Tool (Two-finger Points)
```swift
// Place two points to measure distance
var measurementGesture: some Gesture {
    SimultaneousGesture(
        TapGesture().targetedToAnyEntity(),
        TapGesture().targetedToAnyEntity()
    )
    .onEnded { first, second in
        calculateDistance(from: first.location3D, to: second.location3D)
    }
}
```

### 3.3 Hover Effects

```swift
// Add hover effect to interactive elements
ModelEntity()
    .components.set(HoverEffectComponent())
    .components.set(InputTargetComponent(allowedInputTypes: .indirect))

// Custom hover highlight
struct BuildingView: View {
    @State private var isHovered = false

    var body: some View {
        Model3D(named: "building")
            .hoverEffect()
            .onContinuousHover { phase in
                switch phase {
                case .active:
                    isHovered = true
                    showBuildingPreview()
                case .ended:
                    isHovered = false
                    hidePreview()
                }
            }
    }
}
```

## 4. Hand Tracking Implementation

### 4.1 ARKit Hand Tracking Setup

```swift
import ARKit

final class HandTrackingManager: @unchecked Sendable {
    private let session = ARKitSession()
    private let handTracking = HandTrackingProvider()

    private var handAnchors: [HandAnchor.Chirality: HandAnchor] = [:]

    func startTracking() async throws {
        guard HandTrackingProvider.isSupported else {
            throw HandTrackingError.notSupported
        }

        try await session.run([handTracking])
    }

    func monitorHandUpdates() async {
        for await update in handTracking.anchorUpdates {
            switch update.event {
            case .added, .updated:
                handAnchors[update.anchor.chirality] = update.anchor
                processHandGesture(update.anchor)
            case .removed:
                handAnchors[update.anchor.chirality] = nil
            }
        }
    }

    private func processHandGesture(_ anchor: HandAnchor) {
        // Detect custom gestures
        if let gesture = detectCityGesture(from: anchor) {
            notifyGestureRecognized(gesture)
        }
    }
}

enum HandTrackingError: Error {
    case notSupported
    case authorizationDenied
}
```

### 4.2 Custom Hand Gestures

#### Point and Deploy Gesture
```swift
func detectPointAndDeploy(_ anchor: HandAnchor) -> Bool {
    guard let indexTip = anchor.handSkeleton?.joint(.indexFingerTip),
          let indexKnuckle = anchor.handSkeleton?.joint(.indexFingerKnuckle),
          let middleTip = anchor.handSkeleton?.joint(.middleFingerTip) else {
        return false
    }

    // Index finger extended
    let indexExtended = distance(indexTip.position, indexKnuckle.position) > 0.05

    // Other fingers curled
    let middleCurled = distance(middleTip.position, indexKnuckle.position) < 0.03

    return indexExtended && middleCurled
}
```

#### Palm Scan Gesture (Navigate City)
```swift
func detectPalmScan(_ anchor: HandAnchor) -> SIMD3<Float>? {
    guard let palm = anchor.handSkeleton?.joint(.wrist) else {
        return nil
    }

    // Detect palm orientation and movement
    // Return movement vector for city navigation
    return palm.position
}
```

#### Pinch Measurements
```swift
func detectPinchMeasurement(_ leftHand: HandAnchor, _ rightHand: HandAnchor) -> Float? {
    guard let leftPinch = getPinchPoint(leftHand),
          let rightPinch = getPinchPoint(rightHand) else {
        return nil
    }

    return distance(leftPinch, rightPinch)
}

private func getPinchPoint(_ anchor: HandAnchor) -> SIMD3<Float>? {
    guard let thumbTip = anchor.handSkeleton?.joint(.thumbTip),
          let indexTip = anchor.handSkeleton?.joint(.indexFingerTip) else {
        return nil
    }

    let pinchDistance = distance(thumbTip.position, indexTip.position)
    if pinchDistance < 0.02 { // 2cm threshold
        return (thumbTip.position + indexTip.position) / 2
    }

    return nil
}
```

## 5. Eye Tracking Implementation

### 5.1 ARKit Eye Tracking

```swift
import ARKit

final class EyeTrackingManager {
    private let session = ARKitSession()
    private let worldTracking = WorldTrackingProvider()

    func startEyeTracking() async throws {
        try await session.run([worldTracking])
    }

    func getCurrentGaze() async -> SIMD3<Float>? {
        // Get user's gaze direction
        // Used for:
        // - Focus indicators on UI elements
        // - Attention analytics (which areas are viewed)
        // - Hands-free navigation
        return nil // ARKit provides gaze data
    }
}
```

### 5.2 Eye Tracking Use Cases

**Focus Indicators**:
- Highlight infrastructure under gaze
- Show tooltips for hovered elements
- Enable hands-free inspection

**Privacy Considerations**:
- Eye tracking data never leaves device
- No gaze recording
- Only used for UI interaction

## 6. Spatial Audio Specifications

### 6.1 Audio Architecture

```swift
import RealityKit
import AVFAudio

final class SpatialAudioManager {
    private let audioEngine = AVAudioEngine()
    private var audioSources: [UUID: AudioSource] = [:]

    func setupSpatialAudio() {
        // Configure spatial audio environment
        let environment = AVAudioEnvironmentNode()
        audioEngine.attach(environment)

        // Set listener position (user's head)
        environment.listenerPosition = AVAudio3DPoint(x: 0, y: 0, z: 0)
    }

    func playEmergencyAlert(at location: SIMD3<Float>) {
        let alert = AudioFileResource.loadAsync(named: "emergency_alert")

        // Create spatial audio source
        let audioSource = AudioSource(resource: alert)
        audioSource.position = location
        audioSource.gain = -10 // dB

        // Play with spatial positioning
        playAudio(audioSource)
    }

    func createAmbientCitySound(for district: District) -> AudioSource {
        // Ambient traffic, city sounds based on district type
        let soundFile = ambientSoundForDistrict(district.type)
        let audio = AudioFileResource.loadAsync(named: soundFile)

        let source = AudioSource(resource: audio)
        source.isLooping = true
        source.gain = -20 // Subtle background

        return source
    }
}
```

### 6.2 Audio Event Types

**Critical Alerts**:
- Emergency incidents: High priority, directional
- Infrastructure failures: Medium priority, pulsing
- System notifications: Low priority, ambient

**Ambient Sounds**:
- Traffic flow: Subtle directional audio
- District atmosphere: Environmental soundscape
- Equipment operation: Mechanical ambiance

**Voice Communications**:
- Radio dispatch: Spatial voice positioning
- Department calls: 3D audio placement
- AI assistant: Non-spatial, always clear

## 7. Accessibility Requirements

### 7.1 VoiceOver Support

```swift
// Comprehensive VoiceOver labels
Model3D(named: "building")
    .accessibilityLabel("Office building at 123 Main Street")
    .accessibilityValue("Operational status: Normal, Occupancy: 450 people")
    .accessibilityHint("Double tap to view building details")
    .accessibilityAddTraits(.isButton)

// Custom actions for complex controls
Button("Deploy Emergency Response") {
    deployEmergency()
}
.accessibilityAction(named: "Deploy Fire Unit") {
    deployFireUnit()
}
.accessibilityAction(named: "Deploy Medical Unit") {
    deployMedicalUnit()
}

// Spatial audio cues for VoiceOver
.accessibilitySpatialAudio(enabled: true)
```

### 7.2 Dynamic Type Support

```swift
// Scale text with user preferences
Text("Active Incidents: \(incidents.count)")
    .font(.headline)
    .dynamicTypeSize(...DynamicTypeSize.xxxLarge)

// Minimum tap targets: 60x60 points
Button("Alert") {
    // Action
}
.frame(minWidth: 60, minHeight: 60)
```

### 7.3 Alternative Interaction Methods

**Voice Commands**:
```swift
// Siri integration for hands-free operation
AppIntent protocol for common actions:
- "Show emergency incidents"
- "Deploy resources to downtown"
- "What's the traffic status?"
```

**Hardware Controllers**:
- Support for external game controllers
- Keyboard shortcuts for all actions
- Alternative to hand gestures

### 7.4 Reduce Motion

```swift
@Environment(\.accessibilityReduceMotion) var reduceMotion

var animationDuration: Double {
    reduceMotion ? 0.1 : 0.5
}

// Disable particle effects and animations when enabled
if !reduceMotion {
    ParticleEmitterComponent()
}
```

### 7.5 High Contrast Mode

```swift
@Environment(\.accessibilityContrastLevel) var contrastLevel

var borderWidth: CGFloat {
    contrastLevel == .high ? 3 : 1
}

// Increase visual distinction in high contrast
```

## 8. Privacy and Security Requirements

### 8.1 Data Privacy

#### Citizen Data Anonymization
```swift
struct AnonymizedCitizenData {
    // Never store PII
    let demographicSegment: String // "25-34 age group"
    let approximateLocation: CLLocationCoordinate2D // Rounded to district
    let timestamp: Date // Rounded to hour

    // No names, addresses, identifiable information
}
```

#### Privacy Manifest (PrivacyInfo.xcprivacy)
```xml
<key>NSPrivacyCollectedDataTypes</key>
<array>
    <dict>
        <key>NSPrivacyCollectedDataType</key>
        <string>NSPrivacyCollectedDataTypeLocation</string>
        <key>NSPrivacyCollectedDataTypeLinked</key>
        <false/>
        <key>NSPrivacyCollectedDataTypeTracking</key>
        <false/>
        <key>NSPrivacyCollectedDataTypePurposes</key>
        <array>
            <string>NSPrivacyCollectedDataTypePurposeAnalytics</string>
        </array>
    </dict>
</array>
```

### 8.2 Security Implementation

#### Secure Storage
```swift
import Security

final class SecureStorage {
    func saveToken(_ token: String, for key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: token.data(using: .utf8)!,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlocked
        ]

        SecItemAdd(query as CFDictionary, nil)
    }
}
```

#### Certificate Pinning
```swift
final class PinnedURLSessionDelegate: NSObject, URLSessionDelegate {
    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        // Verify server certificate against pinned certificate
        guard let serverTrust = challenge.protectionSpace.serverTrust else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }

        // Validate certificate
        let isValid = validateCertificate(serverTrust)

        if isValid {
            completionHandler(.useCredential, URLCredential(trust: serverTrust))
        } else {
            completionHandler(.cancelAuthenticationChallenge, nil)
        }
    }
}
```

#### Encryption
```swift
import CryptoKit

func encryptSensitiveData(_ data: Data, key: SymmetricKey) throws -> Data {
    let sealedBox = try AES.GCM.seal(data, using: key)
    return sealedBox.combined!
}

func decryptSensitiveData(_ encrypted: Data, key: SymmetricKey) throws -> Data {
    let sealedBox = try AES.GCM.SealedBox(combined: encrypted)
    return try AES.GCM.open(sealedBox, using: key)
}
```

### 8.3 Role-Based Access Control

```swift
enum PermissionLevel {
    case read, write, admin, emergency
}

struct UserPermissions {
    let role: UserRole
    let departments: [Department]
    let permissions: Set<PermissionLevel>

    func canAccess(_ resource: Resource) -> Bool {
        // Check if user has permission
        return permissions.contains(.admin) ||
               resource.requiredPermission.isSubset(of: permissions)
    }
}
```

## 9. Data Persistence Strategy

### 9.1 SwiftData Configuration

```swift
import SwiftData

@main
struct SmartCityApp: App {
    let modelContainer: ModelContainer

    init() {
        let schema = Schema([
            City.self,
            District.self,
            Building.self,
            Infrastructure.self,
            IoTSensor.self,
            SensorReading.self,
            EmergencyIncident.self,
            TransportationAsset.self,
            CitizenRequest.self
        ])

        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            allowsSave: true
        )

        do {
            modelContainer = try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Failed to create model container: \(error)")
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
actor CacheManager {
    private var cache: [String: CacheEntry] = [:]

    struct CacheEntry {
        let data: Any
        let timestamp: Date
        let ttl: TimeInterval // Time to live
    }

    func get<T>(_ key: String) -> T? {
        guard let entry = cache[key],
              Date().timeIntervalSince(entry.timestamp) < entry.ttl else {
            return nil
        }
        return entry.data as? T
    }

    func set(_ key: String, value: Any, ttl: TimeInterval = 300) {
        cache[key] = CacheEntry(data: value, timestamp: Date(), ttl: ttl)
    }

    func invalidate(_ key: String) {
        cache.removeValue(forKey: key)
    }
}
```

### 9.3 Time-Series Data Handling

```swift
// Efficient sensor reading storage
extension SensorReading {
    // Aggregate historical data
    static func aggregateHourly(readings: [SensorReading]) -> AggregatedReading {
        let values = readings.map { $0.value }
        return AggregatedReading(
            average: values.reduce(0, +) / Double(values.count),
            min: values.min() ?? 0,
            max: values.max() ?? 0,
            count: readings.count
        )
    }
}

// Archive old data to reduce database size
func archiveOldSensorData() async {
    let cutoffDate = Calendar.current.date(byAdding: .day, value: -30, to: Date())!
    // Move data older than 30 days to compressed archive
}
```

## 10. Network Architecture

### 10.1 API Communication

```swift
final class NetworkManager {
    private let session: URLSession
    private let baseURL: URL

    init(baseURL: URL) {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 300
        configuration.waitsForConnectivity = true

        self.session = URLSession(configuration: configuration)
        self.baseURL = baseURL
    }

    func request<T: Decodable>(
        _ endpoint: String,
        method: HTTPMethod = .get,
        body: (any Encodable)? = nil
    ) async throws -> T {
        var request = URLRequest(url: baseURL.appendingPathComponent(endpoint))
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let body {
            request.httpBody = try JSONEncoder().encode(body)
        }

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.invalidResponse
        }

        return try JSONDecoder().decode(T.self, from: data)
    }
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}
```

### 10.2 Real-Time Data Streaming

```swift
// WebSocket for live sensor data
final class WebSocketManager {
    private var webSocket: URLSessionWebSocketTask?

    func connect(to url: URL) {
        webSocket = URLSession.shared.webSocketTask(with: url)
        webSocket?.resume()
        receiveMessage()
    }

    private func receiveMessage() {
        webSocket?.receive { [weak self] result in
            switch result {
            case .success(let message):
                self?.handleMessage(message)
                self?.receiveMessage() // Continue listening
            case .failure(let error):
                print("WebSocket error: \(error)")
            }
        }
    }

    func send<T: Encodable>(_ message: T) async throws {
        let data = try JSONEncoder().encode(message)
        let message = URLSessionWebSocketTask.Message.data(data)
        try await webSocket?.send(message)
    }
}

// MQTT for IoT sensors
import CocoaMQTT

final class MQTTManager {
    private let mqtt: CocoaMQTT

    init(clientID: String, host: String, port: UInt16) {
        mqtt = CocoaMQTT(clientID: clientID, host: host, port: port)
        mqtt.keepAlive = 60
    }

    func subscribe(to topic: String) {
        mqtt.subscribe(topic, qos: .qos1)
    }

    func onMessageReceived(_ handler: @escaping (String, String) -> Void) {
        mqtt.didReceiveMessage = { _, message, _ in
            handler(message.topic, message.string ?? "")
        }
    }
}
```

## 11. Testing Requirements

### 11.1 Unit Testing

```swift
import XCTest
@testable import SmartCityCommandPlatform

final class CityOperationsViewModelTests: XCTestCase {
    var viewModel: CityOperationsViewModel!
    var mockIoTService: MockIoTDataService!
    var mockEmergencyService: MockEmergencyDispatchService!

    override func setUp() async throws {
        mockIoTService = MockIoTDataService()
        mockEmergencyService = MockEmergencyDispatchService()
        viewModel = CityOperationsViewModel(
            iotService: mockIoTService,
            emergencyService: mockEmergencyService,
            analyticsService: MockAnalyticsService()
        )
    }

    func testLoadCityData() async throws {
        // Given
        mockIoTService.mockSensors = [createMockSensor()]

        // When
        try await viewModel.loadCityData()

        // Then
        XCTAssertEqual(viewModel.sensorData.count, 1)
        XCTAssertFalse(viewModel.isLoading)
    }

    func testEmergencyDispatch() async throws {
        // Given
        let incident = createMockIncident()

        // When
        try await viewModel.dispatchEmergencyResponse(to: incident)

        // Then
        XCTAssertTrue(mockEmergencyService.dispatchCalled)
    }
}
```

### 11.2 UI Testing

```swift
import XCTest

final class SmartCityUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUp() {
        app = XCUIApplication()
        app.launch()
    }

    func testOperationsCenterLoad() {
        // Verify operations center window appears
        XCTAssertTrue(app.windows["City Operations Center"].exists)

        // Check for critical UI elements
        XCTAssertTrue(app.staticTexts["Active Incidents"].exists)
        XCTAssertTrue(app.buttons["Emergency Response"].exists)
    }

    func test3DCityModelInteraction() {
        // Open 3D city model
        app.buttons["3D View"].tap()

        // Wait for model to load
        let cityModel = app.otherElements["3D City Model"]
        XCTAssertTrue(cityModel.waitForExistence(timeout: 5))

        // Test interaction
        cityModel.tap()
    }
}
```

### 11.3 Spatial Interaction Testing

```swift
// Test spatial gestures and hand tracking
final class SpatialInteractionTests: XCTestCase {
    func testTapGesture() {
        // Simulate tap on building entity
        let building = createTestBuilding()
        let tapLocation = CGPoint(x: 100, y: 100)

        // Verify tap handler called
    }

    func testHandTrackingGesture() {
        // Mock hand tracking data
        let mockHandAnchor = createMockHandAnchor()

        // Verify gesture recognition
    }
}
```

### 11.4 Performance Testing

```swift
func testRenderingPerformance() {
    measure(metrics: [XCTClockMetric(), XCTMemoryMetric()]) {
        // Render complex city scene
        renderCityScene()
    }
}

func testDataLoadPerformance() {
    measure {
        // Load large dataset
        _ = loadAllSensorData()
    }
}
```

### 11.5 Integration Testing

```swift
final class APIIntegrationTests: XCTestCase {
    func testIoTSensorDataFetch() async throws {
        let service = IoTDataService(
            apiClient: APIClient(baseURL: testServerURL),
            cache: CacheService()
        )

        let sensors = try await service.fetchSensorData()
        XCTAssertFalse(sensors.isEmpty)
    }
}
```

## 12. Build Configuration

### 12.1 Info.plist Configuration

```xml
<key>NSCameraUsageDescription</key>
<string>Camera access is required for spatial tracking and AR features</string>

<key>NSLocationWhenInUseUsageDescription</key>
<string>Location access is required to show your city's infrastructure</string>

<key>UIRequiredDeviceCapabilities</key>
<array>
    <string>arm64</string>
</array>

<key>UIRequiresFullScreen</key>
<true/>
```

### 12.2 Build Settings

```swift
// Deployment target
IPHONEOS_DEPLOYMENT_TARGET = 2.0

// Swift version
SWIFT_VERSION = 6.0

// Concurrency checking
SWIFT_STRICT_CONCURRENCY = complete

// Optimization
SWIFT_OPTIMIZATION_LEVEL = -Onone // Debug
SWIFT_OPTIMIZATION_LEVEL = -O // Release
```

### 12.3 Entitlements

```xml
<key>com.apple.developer.arkit</key>
<true/>

<key>com.apple.developer.hand-tracking</key>
<true/>

<key>com.apple.security.application-groups</key>
<array>
    <string>group.com.smartcity.commandplatform</string>
</array>
```

---

This technical specification provides comprehensive implementation details for building a production-ready Smart City Command Platform on visionOS.
