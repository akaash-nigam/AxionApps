# Real Estate Spatial Platform - Technical Specification

## Document Information
- **Version**: 1.0
- **Last Updated**: 2025-11-17
- **Target Platform**: visionOS 2.0+
- **Development Tools**: Xcode 16+, Reality Composer Pro
- **Status**: Design Phase

---

## 1. Technology Stack

### 1.1 Core Technologies

#### Swift and SwiftUI
```yaml
Language: Swift 6.0+
UI Framework: SwiftUI 5.0+
Concurrency: Swift Concurrency (async/await, actors)
Architecture: MVVM with @Observable
Minimum Deployment: visionOS 2.0

Key Swift Features:
  - Strict concurrency checking
  - Typed throws
  - Macro system for data models
  - Result builders for declarative UI
  - Property wrappers for state management
```

#### 3D and Spatial Computing
```yaml
3D Framework: RealityKit 2.0+
AR Framework: ARKit 6.0+
Spatial Audio: AVFoundation Spatial Audio
Hand Tracking: ARKit Hand Tracking API
Eye Tracking: ARKit Gaze API (where available)
Scene Understanding: ARKit Scene Reconstruction

File Formats:
  - USDZ for 3D models
  - Reality files from Reality Composer Pro
  - HDR textures (EXR, HDR)
  - Spatial audio (AAC, ALAC)
```

#### Data Persistence
```yaml
Primary Database: SwiftData
Cloud Sync: CloudKit
User Defaults: For app preferences
Keychain: Secure credential storage
File System: Documents directory for media cache

SwiftData Models:
  - @Model for entities
  - @Relationship for associations
  - @Transient for computed properties
  - @Attribute for constraints
```

#### Networking
```yaml
HTTP Client: URLSession with async/await
WebSocket: URLSessionWebSocketTask
Streaming: HTTP Live Streaming (HLS)
CDN: CloudFront or similar for asset delivery
Real-time: WebRTC for multi-user tours

Protocols:
  - REST API (JSON)
  - WebSocket for real-time updates
  - WebRTC for peer-to-peer
  - HLS for video streaming
```

### 1.2 Third-Party Services

#### AI/ML Services
```yaml
OpenAI GPT-4: Property descriptions, Q&A
OpenAI DALL-E 3: Virtual staging generation
Core ML: On-device inference
Vision Framework: Image analysis
Natural Language: Text processing

Local ML Models:
  - Room classification
  - Furniture detection
  - Price estimation
  - User preference learning
```

#### Real Estate Data
```yaml
MLS API: Property listings sync
Zillow API: Market data and estimates
Google Maps: Geocoding and places
Walk Score API: Neighborhood metrics
Census Data: Demographics

Integration Methods:
  - REST APIs
  - Webhooks for updates
  - Batch sync jobs
  - Real-time feeds (where available)
```

#### Analytics and Monitoring
```yaml
TelemetryDeck: Privacy-first analytics
Sentry: Error tracking and monitoring
os_log: System logging
MetricKit: Performance metrics
Instruments: Profiling and debugging
```

### 1.3 Development Tools

```yaml
IDE: Xcode 16.0+
3D Content: Reality Composer Pro
Version Control: Git
CI/CD: Xcode Cloud
Testing: XCTest, Swift Testing
Documentation: DocC

Additional Tools:
  - SF Symbols for iconography
  - Blender for 3D asset creation
  - Instruments for performance profiling
  - Create ML for model training
```

---

## 2. visionOS Presentation Modes

### 2.1 WindowGroup Implementation

#### Primary Window: Property Browser
```swift
WindowGroup("Properties", id: "browser") {
    PropertyBrowserView()
        .environment(appModel)
        .frame(minWidth: 800, minHeight: 600)
}
.defaultSize(width: 1200, height: 800)
.windowResizability(.contentSize)

// Window Features:
// - Scrollable property grid
// - Filter sidebar
// - Search bar
// - Map view toggle
// - Saved properties section
```

#### Auxiliary Window: Property Details
```swift
WindowGroup(id: "property-detail", for: Property.ID.self) { $propertyID in
    if let propertyID {
        PropertyDetailView(propertyID: propertyID)
            .environment(appModel)
    }
}
.defaultSize(width: 900, height: 1000)

// Window Features:
// - Photo gallery carousel
// - Property specifications
// - Pricing and financial info
// - Neighborhood data
// - Action buttons (save, share, tour)
```

#### Agent Dashboard Window
```swift
WindowGroup("Dashboard", id: "agent-dashboard") {
    AgentDashboardView()
        .environment(appModel)
}
.defaultSize(width: 1400, height: 900)
.windowResizability(.contentSize)

// Dashboard Panels:
// - Active listings
// - Client pipeline
// - Showing schedule
// - Analytics and insights
// - Commission tracker
```

### 2.2 Volumetric Content

#### 3D Floor Plan Volume
```swift
WindowGroup(id: "floor-plan-3d", for: Property.ID.self) { $propertyID in
    FloorPlan3DView(propertyID: propertyID)
        .environment(appModel)
}
.windowStyle(.volumetric)
.defaultSize(width: 1.5, height: 1.2, depth: 1.5, in: .meters)

// Volume Features:
// - Interactive 3D floor plan
// - Room labels floating above
// - Measurement annotations
// - Tap rooms to highlight
// - Rotate and scale gestures
```

#### Property Model Volume
```swift
WindowGroup(id: "property-model", for: Property.ID.self) { $propertyID in
    PropertyModelView(propertyID: propertyID)
        .environment(appModel)
}
.windowStyle(.volumetric)
.defaultSize(width: 2.0, height: 1.5, depth: 2.0, in: .meters)

// Model Features:
// - Exterior architectural model
// - Lot boundaries
// - Landscaping
// - Driveway and garage
// - Pinch to scale, rotate gesture
```

#### Neighborhood Context Volume
```swift
WindowGroup(id: "neighborhood", for: GeographicArea.self) { $area in
    NeighborhoodVolumeView(area: area)
}
.windowStyle(.volumetric)
.defaultSize(width: 2.5, height: 2.0, depth: 2.5, in: .meters)

// Neighborhood Features:
// - 3D map of surrounding area
// - Points of interest (schools, parks)
// - Transit routes
// - Property markers
// - Aerial perspective option
```

### 2.3 Immersive Spaces

#### Property Tour Immersive Space
```swift
ImmersiveSpace(id: "property-tour", for: Property.ID.self) { $propertyID in
    PropertyTourImmersiveView(propertyID: propertyID)
        .environment(appModel)
}
.immersionStyle(selection: $immersionLevel, in: .mixed, .progressive, .full)
.upperLimbVisibility(.hidden) // Hide user's hands for immersion

// Immersion Features:
// - Photorealistic room environments
// - Natural walking navigation
// - Teleport to any room
// - Spatial audio ambience
// - Toggle staging on/off
// - Measurement mode
// - Annotation mode
```

#### Virtual Open House Space
```swift
ImmersiveSpace(id: "open-house", for: OpenHouseSession.ID.self) { $sessionID in
    OpenHouseView(sessionID: sessionID)
        .environment(appModel)
}
.immersionStyle(selection: .constant(.full), in: .full)

// Open House Features:
// - Multi-user presence (SharePlay)
// - Voice chat enabled
// - Agent avatar and controls
// - Participant avatars
// - Shared annotations
// - Q&A panel
// - Live document sharing
```

#### Renovation Preview Space
```swift
ImmersiveSpace(id: "renovation", for: RenovationPlan.ID.self) { $planID in
    RenovationPreviewView(planID: planID)
}
.immersionStyle(selection: .constant(.mixed), in: .mixed)

// Renovation Features:
// - Before/after slider
// - Wall removal visualization
// - New fixture placement
// - Paint color changes
// - Flooring updates
// - Cost estimates overlay
```

---

## 3. Gesture and Interaction Specifications

### 3.1 Standard Interactions

#### Gaze and Pinch (Primary)
```swift
// Property Card Selection
.onTapGesture {
    selectProperty(property)
}
.hoverEffect() // Highlight on gaze

// Specifications:
// - Hover state: 200ms delay
// - Highlight: Subtle scale (1.05x) + glow
// - Tap target: Minimum 60pt
// - Feedback: Haptic on selection
```

#### Direct Touch Gestures
```swift
// Photo Gallery Swipe
.gesture(
    DragGesture()
        .onChanged { value in
            photoOffset = value.translation.width
        }
        .onEnded { value in
            if abs(value.translation.width) > 100 {
                nextPhoto()
            }
        }
)

// Pinch to Zoom on Property Images
.gesture(
    MagnifyGesture()
        .onChanged { value in
            imageScale = value.magnification
        }
        .onEnded { _ in
            withAnimation(.spring()) {
                imageScale = 1.0
            }
        }
)
```

### 3.2 Spatial Interactions

#### Room Navigation in Immersive Space
```swift
// Tap to Teleport
func handleRoomTap(entity: Entity, location: SIMD3<Float>) {
    // Visual feedback at target location
    showTeleportIndicator(at: location)

    // Smooth transition with fade
    withAnimation(.easeInOut(duration: 0.5)) {
        cameraPosition = location
    }

    // Spatial audio transition
    updateAudioEnvironment(for: location)
}

// Specifications:
// - Teleport radius: 0.3m accuracy
// - Transition time: 500ms
// - Fade duration: 200ms in, 200ms out
// - Audio crossfade: 300ms
```

#### Virtual Walking
```swift
// Natural movement using hand gestures
func processWalkingGesture(hand: HandAnchor) {
    let thumbTip = hand.thumbTip
    let indexTip = hand.indexFingerTip

    // Pinch and drag to move
    if isPinching(thumb: thumbTip, index: indexTip) {
        let dragDirection = calculateDirection(from: lastPosition, to: indexTip)
        moveCamera(in: dragDirection, speed: 0.5) // 0.5 m/s
    }
}

// Specifications:
// - Walking speed: 0.5 m/s (configurable)
// - Collision detection: 0.1m from walls
// - Head bobbing: Subtle (disabled for motion sensitivity)
// - Turn speed: 45°/second
```

#### Measurement Tool
```swift
// Two-point measurement
var measurementPoints: [SIMD3<Float>] = []

func handleMeasurementTap(location: SIMD3<Float>) {
    measurementPoints.append(location)

    if measurementPoints.count == 2 {
        let distance = simd_distance(measurementPoints[0], measurementPoints[1])
        displayMeasurement(distance)
    }
}

// Specifications:
// - Accuracy: ±1 inch (2.54cm)
// - Display units: feet/inches or meters (user preference)
// - Visual: Line with dimensions label
// - Max distance: 50 meters
```

### 3.3 Hand Tracking Implementation

#### Hand Pose Detection
```swift
import ARKit

actor HandTrackingManager {
    private var handTracking: HandTrackingProvider?

    func startTracking() async throws {
        handTracking = HandTrackingProvider()
        try await arSession.run([handTracking!])
    }

    func monitorHandPoses() -> AsyncStream<HandTrackingUpdate> {
        AsyncStream { continuation in
            Task {
                guard let tracking = handTracking else { return }

                for await update in tracking.anchorUpdates {
                    continuation.yield(update)
                }
            }
        }
    }
}

// Supported Gestures:
// - Pinch (thumb + index)
// - Point (index extended)
// - Grab (full hand close)
// - Swipe (hand movement)
// - Peace sign (for screenshots)
```

#### Custom Gesture Recognition
```swift
struct PinchGesture {
    static func detect(hand: HandAnchor) -> Bool {
        let thumbTip = hand.thumbTip.position
        let indexTip = hand.indexFingerTip.position

        let distance = simd_distance(thumbTip, indexTip)
        return distance < 0.02 // 2cm threshold
    }

    static func pinchStrength(hand: HandAnchor) -> Float {
        let thumbTip = hand.thumbTip.position
        let indexTip = hand.indexFingerTip.position

        let distance = simd_distance(thumbTip, indexTip)
        return max(0, min(1, 1 - (distance / 0.05))) // 0-5cm range
    }
}
```

### 3.4 Eye Tracking (Optional Enhancement)

```swift
// Eye gaze for UI element focus
actor EyeTrackingManager {
    private var gazeLocation: SIMD3<Float>?

    func currentGaze() async -> SIMD3<Float>? {
        // ARKit provides gaze direction
        // Return 3D point where user is looking
        return gazeLocation
    }

    func highlightGazedElement() async {
        guard let gaze = await currentGaze() else { return }

        // Raycast to find UI element
        if let element = findElement(at: gaze) {
            element.highlight()
        }
    }
}

// Use Cases:
// - Auto-scroll property list
// - Highlight UI on gaze
// - Analytics (what users look at)
// - Accessibility (hands-free navigation)
```

---

## 4. Spatial Audio Specifications

### 4.1 Ambient Audio

```swift
import AVFoundation
import RealityKit

class SpatialAudioManager {
    private var audioResources: [String: AudioFileResource] = [:]
    private var activeAudioEntities: [Entity] = []

    func setupRoomAmbience(for room: Room) async throws {
        // Load appropriate ambient sound
        let ambience = try await loadAmbience(for: room.type)

        // Create audio entity at room center
        let audioEntity = Entity()
        audioEntity.position = room.centerPosition

        // Configure spatial audio
        let audioComponent = AmbientAudioComponent(
            source: .single(ambience),
            volume: 0.3,
            rolloffFactor: 1.0
        )
        audioEntity.components[AmbientAudioComponent.self] = audioComponent

        activeAudioEntities.append(audioEntity)
    }

    private func loadAmbience(for roomType: RoomType) async throws -> AudioFileResource {
        let filename: String
        switch roomType {
        case .kitchen:
            filename = "kitchen_ambience.aac" // Subtle appliance hum
        case .livingRoom:
            filename = "living_room.aac" // Fireplace crackle (if applicable)
        case .bathroom:
            filename = "bathroom.aac" // Water drip
        default:
            filename = "room_tone.aac" // General room tone
        }

        return try await AudioFileResource(named: filename)
    }
}

// Audio Specifications:
// - Format: AAC, 48kHz, stereo
// - Compression: 192kbps
// - Spatial: HRTF processing
// - Falloff: Realistic (inverse square law)
// - Occlusion: Walls reduce volume by 6dB
```

### 4.2 UI Sound Effects

```swift
enum SoundEffect {
    case buttonTap
    case propertySelect
    case teleport
    case measurement
    case notification
    case error

    var audioResource: AudioFileResource? {
        switch self {
        case .buttonTap:
            return try? AudioFileResource.load(named: "tap.aiff")
        case .teleport:
            return try? AudioFileResource.load(named: "whoosh.aiff")
        // ... other sounds
        }
    }
}

func playSound(_ effect: SoundEffect) {
    guard let resource = effect.audioResource else { return }

    // Play non-spatial UI sound
    let audio = try? AudioPlayer(resource: resource)
    audio?.play()
}

// Sound Design:
// - Subtle and professional
// - Spatial for 3D interactions
// - Non-spatial for UI elements
// - Respectful of user's environment
// - User preference for volume/disable
```

### 4.3 Voice Narration

```swift
import AVFoundation

actor NarrationManager {
    private let synthesizer = AVSpeechSynthesizer()

    func narrate(text: String, at position: SIMD3<Float>? = nil) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.5 // Slightly slower for clarity
        utterance.volume = 0.8

        if let position {
            // Spatial narration from specific location
            // (Requires custom spatial audio implementation)
        }

        synthesizer.speak(utterance)
    }

    func narratePropertyFeature(_ feature: PropertyFeature) {
        let text = feature.description
        narrate(text: text, at: feature.location)
    }
}

// Narration Use Cases:
// - Tour guide (AI assistant)
// - Room descriptions
// - Feature highlights
// - Accessibility (screen reader alternative)
```

---

## 5. Accessibility Requirements

### 5.1 VoiceOver Support

```swift
// All interactive elements must have accessibility labels
PropertyCard(property: property)
    .accessibilityLabel("\(property.address.street), \(property.pricing.listPrice) dollars")
    .accessibilityHint("Tap to view property details")
    .accessibilityAddTraits(.isButton)

// Spatial content accessibility
RoomEntity(room: room)
    .accessibilityLabel(room.name)
    .accessibilityValue("\(room.dimensions.squareFeet) square feet")
    .accessibilityHint("Double tap to teleport to this room")

// Custom actions for complex interactions
.accessibilityAction(named: "Measure") {
    startMeasurement()
}
.accessibilityAction(named: "Toggle Staging") {
    toggleStaging()
}
```

### 5.2 Dynamic Type

```swift
// All text must scale with user preferences
Text(property.address.street)
    .font(.title)
    .dynamicTypeSize(...DynamicTypeSize.xxxLarge) // Cap at xxxLarge

// Adjust layouts for larger text
GeometryReader { geometry in
    if geometry.dynamicTypeSize >= .accessibility1 {
        VStack { /* Vertical layout */ }
    } else {
        HStack { /* Horizontal layout */ }
    }
}
```

### 5.3 Reduced Motion

```swift
// Respect reduce motion preference
@Environment(\.accessibilityReduceMotion) var reduceMotion

var animationDuration: Double {
    reduceMotion ? 0.0 : 0.5
}

// Disable parallax and complex animations
if !reduceMotion {
    withAnimation(.spring()) {
        // Smooth transitions
    }
} else {
    // Instant transitions
}
```

### 5.4 Alternative Navigation

```swift
// Voice commands for hands-free operation
struct VoiceCommandHandler {
    func processCommand(_ command: String) {
        switch command.lowercased() {
        case "show me the kitchen":
            navigateToRoom(.kitchen)
        case "measure this wall":
            startMeasurement()
        case "what's the square footage":
            announceSquareFootage()
        case "go back":
            navigateBack()
        default:
            break
        }
    }
}

// Head tracking for navigation (accessibility alternative to hand gestures)
func processHeadPose(transform: simd_float4x4) {
    let forward = SIMD3<Float>(transform.columns.2.x, 0, transform.columns.2.z)
    // Gaze-based navigation for users with limited hand mobility
}
```

### 5.5 Color Contrast

```swift
// Ensure WCAG AA compliance (4.5:1 for normal text)
struct AccessibleColors {
    static let primary = Color(red: 0.0, green: 0.5, blue: 1.0) // Meets contrast
    static let background = Color(white: 0.95)
    static let text = Color.black

    // High contrast mode
    @Environment(\.colorSchemeContrast) var contrast

    var buttonColor: Color {
        contrast == .increased ? .white : .primary
    }
}
```

---

## 6. Privacy and Security Requirements

### 6.1 Privacy Compliance

#### Data Collection Transparency
```swift
// Privacy manifest (PrivacyInfo.xcprivacy)
/*
{
  "NSPrivacyTracking": false,
  "NSPrivacyTrackingDomains": [],
  "NSPrivacyCollectedDataTypes": [
    {
      "NSPrivacyCollectedDataType": "NSPrivacyCollectedDataTypeUserID",
      "NSPrivacyCollectedDataTypeLinked": true,
      "NSPrivacyCollectedDataTypeTracking": false,
      "NSPrivacyCollectedDataTypePurposes": [
        "NSPrivacyCollectedDataTypePurposeAppFunctionality"
      ]
    },
    {
      "NSPrivacyCollectedDataType": "NSPrivacyCollectedDataTypeLocation",
      "NSPrivacyCollectedDataTypeLinked": true,
      "NSPrivacyCollectedDataTypeTracking": false,
      "NSPrivacyCollectedDataTypePurposes": [
        "NSPrivacyCollectedDataTypePurposeAppFunctionality"
      ]
    }
  ]
}
*/
```

#### Permission Requests
```swift
// Location permission
func requestLocationPermission() async -> Bool {
    let manager = CLLocationManager()
    manager.requestWhenInUseAuthorization()
    return manager.authorizationStatus == .authorizedWhenInUse
}

// Camera access (for property capture - future feature)
func requestCameraPermission() async -> Bool {
    await AVCaptureDevice.requestAccess(for: .video)
}

// World sensing (required for immersive spaces)
// Automatically requested by ARKit
```

### 6.2 Data Encryption

```swift
import CryptoKit

struct EncryptionManager {
    // Encrypt sensitive user data
    static func encrypt(_ data: Data, using key: SymmetricKey) throws -> Data {
        let sealedBox = try AES.GCM.seal(data, using: key)
        return sealedBox.combined!
    }

    static func decrypt(_ data: Data, using key: SymmetricKey) throws -> Data {
        let sealedBox = try AES.GCM.SealedBox(combined: data)
        return try AES.GCM.open(sealedBox, using: key)
    }

    // Generate key from user credentials
    static func deriveKey(from password: String, salt: Data) -> SymmetricKey {
        let passwordData = Data(password.utf8)
        let hash = SHA256.hash(data: passwordData + salt)
        return SymmetricKey(data: hash)
    }
}

// Encrypt property data at rest
func saveSecureProperty(_ property: Property) throws {
    let encoder = JSONEncoder()
    let data = try encoder.encode(property)

    let key = loadEncryptionKey() // From keychain
    let encrypted = try EncryptionManager.encrypt(data, using: key)

    try encrypted.write(to: secureStorageURL)
}
```

### 6.3 Network Security

```swift
// TLS/HTTPS enforcement
class SecureNetworkClient {
    private let session: URLSession

    init() {
        let configuration = URLSessionConfiguration.default
        configuration.tlsMinimumSupportedProtocolVersion = .TLSv13

        // Certificate pinning for critical APIs
        configuration.urlSessionDelegate = CertificatePinningDelegate()

        self.session = URLSession(configuration: configuration)
    }

    func request<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T {
        guard endpoint.url.scheme == "https" else {
            throw NetworkError.insecureConnection
        }

        let (data, response) = try await session.data(for: endpoint.urlRequest)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.invalidResponse
        }

        return try JSONDecoder().decode(T.self, from: data)
    }
}
```

### 6.4 Authentication

```swift
// JWT-based authentication
struct AuthToken: Codable {
    let accessToken: String
    let refreshToken: String
    let expiresAt: Date
}

actor AuthManager {
    private var currentToken: AuthToken?

    func signIn(email: String, password: String) async throws -> User {
        // Send credentials over HTTPS
        let response: AuthResponse = try await api.post("/auth/login", body: [
            "email": email,
            "password": password
        ])

        // Store tokens securely in keychain
        currentToken = response.token
        try storeInKeychain(response.token)

        return response.user
    }

    func refreshToken() async throws {
        guard let token = currentToken else {
            throw AuthError.notAuthenticated
        }

        let response: AuthToken = try await api.post("/auth/refresh", body: [
            "refreshToken": token.refreshToken
        ])

        currentToken = response
        try storeInKeychain(response)
    }

    private func storeInKeychain(_ token: AuthToken) throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(token)

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "authToken",
            kSecValueData as String: data
        ]

        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }
}
```

---

## 7. Data Persistence Strategy

### 7.1 SwiftData Configuration

```swift
import SwiftData

// Model container setup
@MainActor
let container: ModelContainer = {
    let schema = Schema([
        Property.self,
        Room.self,
        User.self,
        ViewingSession.self,
        StagingConfiguration.self,
        SearchQuery.self
    ])

    let config = ModelConfiguration(
        schema: schema,
        isStoredInMemoryOnly: false,
        allowsSave: true,
        groupContainer: .identifier("group.com.realestatespatial"),
        cloudKitDatabase: .automatic // iCloud sync
    )

    return try! ModelContainer(for: schema, configurations: [config])
}()

// Access in views
struct PropertyBrowserView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Property.metadata.createdAt, order: .reverse) var properties: [Property]

    var body: some View {
        List(properties) { property in
            PropertyCard(property: property)
        }
    }
}
```

### 7.2 CloudKit Sync

```swift
// Enable CloudKit for multi-device sync
// Automatic with SwiftData + CloudKit configuration

// Handle sync conflicts
extension Property {
    static func resolveConflict(local: Property, remote: Property) -> Property {
        // Use most recent modification
        if local.metadata.modifiedAt > remote.metadata.modifiedAt {
            return local
        } else {
            return remote
        }
    }
}
```

### 7.3 File System Storage

```swift
// Property media cache
actor FileStorageManager {
    private let fileManager = FileManager.default
    private let cacheDirectory: URL

    init() {
        cacheDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("PropertyAssets")

        // Create directory if needed
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }

    func cacheAsset(_ data: Data, for propertyID: UUID, filename: String) async throws {
        let propertyDir = cacheDirectory.appendingPathComponent(propertyID.uuidString)
        try fileManager.createDirectory(at: propertyDir, withIntermediateDirectories: true)

        let fileURL = propertyDir.appendingPathComponent(filename)
        try data.write(to: fileURL)
    }

    func loadAsset(for propertyID: UUID, filename: String) async throws -> Data {
        let fileURL = cacheDirectory
            .appendingPathComponent(propertyID.uuidString)
            .appendingPathComponent(filename)

        return try Data(contentsOf: fileURL)
    }

    func clearCache(for propertyID: UUID) async throws {
        let propertyDir = cacheDirectory.appendingPathComponent(propertyID.uuidString)
        try fileManager.removeItem(at: propertyDir)
    }

    func getCacheSize() async -> Int64 {
        let enumerator = fileManager.enumerator(at: cacheDirectory, includingPropertiesForKeys: [.fileSizeKey])
        var totalSize: Int64 = 0

        while let fileURL = enumerator?.nextObject() as? URL {
            if let size = try? fileURL.resourceValues(forKeys: [.fileSizeKey]).fileSize {
                totalSize += Int64(size)
            }
        }

        return totalSize
    }
}
```

---

## 8. Network Architecture

### 8.1 API Client

```swift
protocol APIEndpoint {
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String] { get }
    var body: Data? { get }
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
}

actor APIClient {
    private let baseURL: URL
    private let session: URLSession
    private var authToken: String?

    init(baseURL: URL) {
        self.baseURL = baseURL

        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 300
        config.waitsForConnectivity = true

        self.session = URLSession(configuration: config)
    }

    func request<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T {
        let url = baseURL.appendingPathComponent(endpoint.path)
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.httpBody = endpoint.body

        // Add headers
        for (key, value) in endpoint.headers {
            request.setValue(value, forHTTPHeaderField: key)
        }

        // Add auth token
        if let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        switch httpResponse.statusCode {
        case 200...299:
            return try JSONDecoder().decode(T.self, from: data)
        case 401:
            throw APIError.unauthorized
        case 404:
            throw APIError.notFound
        case 500...599:
            throw APIError.serverError
        default:
            throw APIError.unknown(httpResponse.statusCode)
        }
    }
}

enum APIError: Error {
    case invalidResponse
    case unauthorized
    case notFound
    case serverError
    case unknown(Int)
}
```

### 8.2 Asset Streaming

```swift
// Progressive loading for large 3D assets
actor AssetStreamingClient {
    func streamMesh(url: URL) -> AsyncThrowingStream<MeshChunk, Error> {
        AsyncThrowingStream { continuation in
            Task {
                do {
                    let (bytes, response) = try await URLSession.shared.bytes(from: url)

                    guard let httpResponse = response as? HTTPURLResponse,
                          httpResponse.statusCode == 200 else {
                        throw StreamError.invalidResponse
                    }

                    var buffer = Data()
                    let chunkSize = 1024 * 1024 // 1MB chunks

                    for try await byte in bytes {
                        buffer.append(byte)

                        if buffer.count >= chunkSize {
                            let chunk = MeshChunk(data: buffer)
                            continuation.yield(chunk)
                            buffer.removeAll(keepingCapacity: true)
                        }
                    }

                    // Send remaining data
                    if !buffer.isEmpty {
                        continuation.yield(MeshChunk(data: buffer))
                    }

                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
}
```

### 8.3 WebSocket for Real-Time Updates

```swift
actor WebSocketManager {
    private var webSocket: URLSessionWebSocketTask?
    private let url: URL

    init(url: URL) {
        self.url = url
    }

    func connect() async throws {
        let session = URLSession(configuration: .default)
        webSocket = session.webSocketTask(with: url)
        webSocket?.resume()

        // Start receiving messages
        Task {
            await receiveMessages()
        }
    }

    func send(_ message: String) async throws {
        guard let webSocket else {
            throw WebSocketError.notConnected
        }

        let message = URLSessionWebSocketTask.Message.string(message)
        try await webSocket.send(message)
    }

    private func receiveMessages() async {
        guard let webSocket else { return }

        do {
            let message = try await webSocket.receive()

            switch message {
            case .string(let text):
                handleMessage(text)
            case .data(let data):
                handleData(data)
            @unknown default:
                break
            }

            // Continue receiving
            await receiveMessages()
        } catch {
            print("WebSocket error: \(error)")
        }
    }

    func disconnect() {
        webSocket?.cancel(with: .goingAway, reason: nil)
        webSocket = nil
    }
}

// Use cases:
// - Property listing updates
// - Multi-user tour synchronization
// - Real-time notifications
// - Live auction updates
```

---

## 9. Testing Requirements

### 9.1 Unit Testing

```swift
import Testing
import SwiftData

@Suite("Property Model Tests")
struct PropertyTests {
    @Test("Property creation with valid data")
    func testPropertyCreation() {
        let address = PropertyAddress(
            street: "123 Main St",
            city: "San Francisco",
            state: "CA",
            zipCode: "94102",
            country: "USA",
            coordinates: GeographicCoordinate(latitude: 37.7749, longitude: -122.4194)
        )

        let property = Property(mlsNumber: "MLS123456", address: address)

        #expect(property.mlsNumber == "MLS123456")
        #expect(property.address.city == "San Francisco")
    }

    @Test("Price per square foot calculation")
    func testPriceCalculation() {
        var property = createTestProperty()
        property.pricing.listPrice = 1000000
        property.specifications.squareFeet = 2000

        #expect(property.pricing.pricePerSqFt == 500)
    }
}

@Suite("Service Tests")
struct ServiceTests {
    @Test("Property service fetches data")
    func testPropertyFetch() async throws {
        let service = PropertyServiceImpl(
            networkClient: MockNetworkClient(),
            cacheManager: MockCacheManager(),
            context: createTestContext()
        )

        let properties = try await service.fetchProperties(query: SearchQuery())
        #expect(properties.count > 0)
    }
}
```

### 9.2 UI Testing

```swift
import XCTest

final class PropertyBrowserUITests: XCTestCase {
    let app = XCUIApplication()

    override func setUp() {
        continueAfterFailure = false
        app.launch()
    }

    func testPropertySelection() {
        // Find first property card
        let propertyCard = app.buttons["property-card"].firstMatch
        XCTAssertTrue(propertyCard.exists)

        // Tap to select
        propertyCard.tap()

        // Verify detail view appears
        let detailView = app.otherElements["property-detail-view"]
        XCTAssertTrue(detailView.waitForExistence(timeout: 2))
    }

    func testImmersiveTourLaunch() {
        // Select property
        app.buttons["property-card"].firstMatch.tap()

        // Tap tour button
        app.buttons["start-tour"].tap()

        // Verify immersive space requested
        // (Note: Can't fully test immersive space in simulator)
        XCTAssertTrue(app.staticTexts["Loading tour..."].exists)
    }
}
```

### 9.3 Performance Testing

```swift
import Testing

@Suite("Performance Tests")
struct PerformanceTests {
    @Test("Property list loading performance")
    func testPropertyListPerformance() async {
        let service = PropertyServiceImpl(
            networkClient: NetworkClient(baseURL: testURL),
            cacheManager: CacheManager(),
            context: testContext
        )

        let startTime = CFAbsoluteTimeGetCurrent()

        let _ = try? await service.fetchProperties(query: SearchQuery())

        let endTime = CFAbsoluteTimeGetCurrent()
        let duration = endTime - startTime

        // Should load within 2 seconds
        #expect(duration < 2.0)
    }

    @Test("3D asset loading performance")
    func testAssetLoadingPerformance() async {
        let manager = AssetStreamingManager()

        let startTime = CFAbsoluteTimeGetCurrent()

        let _ = try? await manager.loadPropertyAssets(
            propertyID: testPropertyID,
            userDistance: 10
        )

        let endTime = CFAbsoluteTimeGetCurrent()
        let duration = endTime - startTime

        // Should stream assets within 5 seconds
        #expect(duration < 5.0)
    }
}
```

### 9.4 Spatial Testing

```swift
// Test spatial interactions (requires Vision Pro hardware)
@Suite("Spatial Interaction Tests", .enabled(if: ProcessInfo.isVisionPro))
struct SpatialTests {
    @Test("Teleportation accuracy")
    func testTeleportation() async {
        let sceneManager = PropertySceneManager()
        try? await sceneManager.loadProperty(testProperty, spatial: testSpatialData)

        let targetPosition = SIMD3<Float>(1.0, 0.0, 1.0)
        await sceneManager.teleport(to: targetPosition)

        let currentPosition = await sceneManager.cameraPosition

        // Should be within 0.3m of target
        let distance = simd_distance(currentPosition, targetPosition)
        #expect(distance < 0.3)
    }

    @Test("Measurement accuracy")
    func testMeasurement() {
        let point1 = SIMD3<Float>(0, 0, 0)
        let point2 = SIMD3<Float>(3, 0, 0) // 3 meters apart

        let measurement = MeasurementTool.measure(from: point1, to: point2)

        // Should be accurate within 1 inch (0.0254m)
        #expect(abs(measurement - 3.0) < 0.0254)
    }
}
```

---

## 10. Build and Deployment

### 10.1 Build Configurations

```swift
// Debug Configuration
#if DEBUG
let apiBaseURL = "https://api-dev.realestatespatial.com"
let enableLogging = true
let enableAnalytics = false
#else
// Release Configuration
let apiBaseURL = "https://api.realestatespatial.com"
let enableLogging = false
let enableAnalytics = true
#endif

// Environment-specific settings
enum Environment {
    case development
    case staging
    case production

    static var current: Environment {
        #if DEBUG
        return .development
        #elseif STAGING
        return .staging
        #else
        return .production
        #endif
    }
}
```

### 10.2 App Store Metadata

```yaml
App Name: Real Estate Spatial
Bundle ID: com.realestatespatial.visionos
Version: 1.0.0
Minimum visionOS: 2.0
Category: Business
Age Rating: 4+

Privacy Policy URL: https://realestatespatial.com/privacy
Terms of Service: https://realestatespatial.com/terms

Required Device Capabilities:
  - arm64
  - metal
  - world-sensing

Capabilities:
  - Network (Client)
  - Personal VPN (for enterprise deployments)
  - CloudKit
  - Push Notifications
  - Background Modes (for asset prefetching)
```

### 10.3 Continuous Integration

```yaml
# Xcode Cloud workflow
name: CI/CD Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  build:
    runs-on: macos-14
    steps:
      - checkout
      - xcode-select: 16.0

      - name: Run tests
        run: xcodebuild test -scheme RealEstateSpatial -destination 'platform=visionOS Simulator,name=Apple Vision Pro'

      - name: Build archive
        run: xcodebuild archive -scheme RealEstateSpatial -archivePath build/RealEstateSpatial.xcarchive

      - name: Export IPA
        run: xcodebuild -exportArchive -archivePath build/RealEstateSpatial.xcarchive -exportPath build/export -exportOptionsPlist ExportOptions.plist

      - name: Upload to TestFlight
        if: github.ref == 'refs/heads/main'
        run: xcrun altool --upload-app --file build/export/RealEstateSpatial.ipa
```

---

## 11. Performance Benchmarks

### 11.1 Target Metrics

```yaml
Frame Rate:
  - Target: 90 FPS sustained
  - Minimum: 60 FPS (never drop below)
  - Measurement: Instruments FPS gauge

Latency:
  - Input to response: < 50ms
  - Teleportation: < 500ms total
  - Asset load: < 5s for full property
  - API response: < 2s

Memory:
  - Base usage: < 500MB
  - Per property: < 100MB
  - Peak usage: < 2GB
  - Cache limit: 1GB

Battery:
  - Active use: < 10% per hour
  - Background: < 1% per hour

Network:
  - Property download: < 50MB
  - Streaming bandwidth: Adaptive (1-10 Mbps)
  - Prefetch: Intelligent based on user behavior
```

### 11.2 Profiling Strategy

```swift
import os.signpost

let performanceLog = OSLog(subsystem: "com.realestatespatial", category: .pointsOfInterest)

func loadProperty(_ id: UUID) async {
    let signpostID = OSSignpostID(log: performanceLog)
    os_signpost(.begin, log: performanceLog, name: "Load Property", signpostID: signpostID)

    // Perform loading
    await performLoad(id)

    os_signpost(.end, log: performanceLog, name: "Load Property", signpostID: signpostID)
}

// View in Instruments:
// - Time Profiler: CPU usage
// - Allocations: Memory usage
// - Network: Data transfer
// - System Trace: Thread activity
// - Energy Log: Battery impact
```

---

## 12. Conclusion

This technical specification provides comprehensive implementation details for building the Real Estate Spatial Platform on visionOS. Key technical highlights:

1. **Modern Swift**: Swift 6.0 with strict concurrency
2. **Spatial Computing**: Full utilization of windows, volumes, and immersive spaces
3. **Performance**: Optimized for 90fps with LOD and streaming
4. **Accessibility**: Full VoiceOver, Dynamic Type, and alternative inputs
5. **Security**: End-to-end encryption, secure authentication
6. **Testing**: Comprehensive unit, UI, and performance tests

The specification ensures a professional, enterprise-grade visionOS application that meets all requirements from the PRD.

---

**Next Document**: DESIGN.md for UI/UX specifications
