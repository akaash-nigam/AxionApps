# Retail Space Optimizer - Technical Specifications

## 1. Technology Stack

### 1.1 Core Technologies

#### Programming Language
- **Swift 6.0+**
  - Strict concurrency checking enabled
  - Modern async/await patterns
  - Structured concurrency with Task groups
  - Actor isolation for thread-safe state management
  - Result builders for declarative APIs

#### UI Framework
- **SwiftUI 5+**
  - Declarative UI construction
  - @Observable macro for state management
  - Environment for dependency injection
  - Animations and transitions
  - Custom view modifiers and components

#### 3D Graphics
- **RealityKit 2+**
  - Entity Component System (ECS) architecture
  - Material-based rendering
  - Physical-based rendering (PBR)
  - Custom shaders with Metal
  - Particle systems and effects
  - Spatial audio integration

#### Spatial Computing
- **ARKit 6+**
  - World tracking
  - Hand tracking
  - Plane detection
  - Image tracking (if needed for anchors)
  - Scene reconstruction
  - Spatial mapping

#### Platform
- **visionOS 2.0+**
  - WindowGroup for 2D interfaces
  - Volumetric windows for 3D content
  - ImmersiveSpace for full experiences
  - Spatial audio
  - Eye tracking (for UI focus)
  - Hand gesture recognition

### 1.2 Data & Persistence

#### Local Storage
```swift
// SwiftData Configuration
import SwiftData

@main
struct RetailSpaceOptimizerApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Store.self,
            Fixture.self,
            Product.self,
            StoreAnalytics.self,
            OptimizationSuggestion.self
        ])

        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            allowsSave: true,
            cloudKitDatabase: .automatic  // Optional iCloud sync
        )

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
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

#### Network Layer
```swift
// Modern async/await networking
actor NetworkClient {
    private let session: URLSession
    private let baseURL: URL
    private var authToken: String?

    init(baseURL: URL) {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 300
        config.waitsForConnectivity = true
        config.requestCachePolicy = .returnCacheDataElseLoad

        self.session = URLSession(configuration: config)
        self.baseURL = baseURL
    }

    func request<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T {
        let request = try buildRequest(endpoint)
        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.httpError(httpResponse.statusCode)
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601

        return try decoder.decode(T.self, from: data)
    }
}
```

#### Caching Strategy
```swift
class CacheManager {
    private let memoryCache = NSCache<NSString, CacheEntry>()
    private let fileManager = FileManager.default
    private let cacheDirectory: URL

    init() {
        cacheDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("RetailOptimizer")

        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)

        // Configure memory cache
        memoryCache.countLimit = 100
        memoryCache.totalCostLimit = 50 * 1024 * 1024  // 50MB
    }

    func get<T: Codable>(key: String) async -> T? {
        // Check memory cache first
        if let entry = memoryCache.object(forKey: key as NSString) as? TypedCacheEntry<T> {
            if entry.expiresAt > Date() {
                return entry.value
            }
        }

        // Check disk cache
        let fileURL = cacheDirectory.appendingPathComponent(key.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? key)
        guard let data = try? Data(contentsOf: fileURL) else { return nil }

        let decoder = JSONDecoder()
        guard let entry = try? decoder.decode(TypedCacheEntry<T>.self, from: data) else { return nil }

        if entry.expiresAt > Date() {
            // Promote to memory cache
            memoryCache.setObject(entry as AnyObject, forKey: key as NSString)
            return entry.value
        }

        return nil
    }

    func set<T: Codable>(key: String, value: T, ttl: TimeInterval) async {
        let entry = TypedCacheEntry(value: value, expiresAt: Date().addingTimeInterval(ttl))

        // Save to memory
        memoryCache.setObject(entry as AnyObject, forKey: key as NSString)

        // Save to disk
        let fileURL = cacheDirectory.appendingPathComponent(key.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? key)
        if let data = try? JSONEncoder().encode(entry) {
            try? data.write(to: fileURL)
        }
    }
}
```

### 1.3 AI/ML Integration

#### Core ML Models
```swift
class AIOptimizationEngine {
    private var layoutOptimizer: LayoutOptimizerModel?
    private var salesPredictor: SalesPredictionModel?
    private var customerSimulator: CustomerBehaviorModel?

    init() {
        loadModels()
    }

    private func loadModels() {
        Task {
            do {
                let config = MLModelConfiguration()
                config.computeUnits = .cpuAndNeuralEngine

                layoutOptimizer = try await LayoutOptimizerModel.load(configuration: config)
                salesPredictor = try await SalesPredictionModel.load(configuration: config)
                customerSimulator = try await CustomerBehaviorModel.load(configuration: config)
            } catch {
                print("Error loading ML models: \(error)")
            }
        }
    }

    func optimizeLayout(store: Store, constraints: LayoutConstraints) async throws -> [OptimizationSuggestion] {
        guard let model = layoutOptimizer else {
            throw AIError.modelNotLoaded
        }

        let input = prepareLayoutInput(store: store, constraints: constraints)
        let prediction = try await model.prediction(from: input)
        return parseSuggestions(from: prediction)
    }

    func predictSalesImpact(layout: StoreLayout, historicalData: [SalesData]) async throws -> SalesPrediction {
        guard let model = salesPredictor else {
            throw AIError.modelNotLoaded
        }

        let input = prepareSalesInput(layout: layout, data: historicalData)
        let prediction = try await model.prediction(from: input)
        return SalesPrediction(from: prediction)
    }
}
```

## 2. visionOS Presentation Modes

### 2.1 WindowGroup (2D Windows)

#### Main Control Window
```swift
WindowGroup("Retail Optimizer", id: "main") {
    MainDashboardView()
        .environment(appModel)
        .frame(minWidth: 1000, minHeight: 700)
}
.windowStyle(.plain)
.defaultSize(width: 1200, height: 800)
.windowResizability(.contentSize)
```

**Purpose**: Primary control panel and analytics dashboard
**Size**: 1200x800 points (resizable)
**Features**:
- Store selection and management
- Analytics charts and metrics
- Tool palette and settings
- Navigation controls

#### Analytics Detail Window
```swift
WindowGroup("Analytics", id: "analytics", for: Store.ID.self) { $storeID in
    AnalyticsDetailView(storeID: storeID)
        .environment(appModel)
}
.windowStyle(.plain)
.defaultSize(width: 900, height: 700)
```

**Purpose**: Detailed analytics and reporting
**Size**: 900x700 points
**Features**:
- Deep-dive metrics
- Custom reports
- Export capabilities
- Filtering and comparison

### 2.2 Volumetric Windows (3D Bounded Content)

#### Store Volume View
```swift
WindowGroup("Store 3D", id: "store-volume", for: Store.ID.self) { $storeID in
    StoreVolumeView(storeID: storeID ?? UUID().uuidString)
        .environment(appModel)
}
.windowStyle(.volumetric)
.defaultSize(width: 2.0, height: 1.5, depth: 2.0, in: .meters)
.volumeBaseplateVisibility(.hidden)
```

**Purpose**: 3D store model visualization and editing
**Size**: 2m x 1.5m x 2m
**Features**:
- Interactive 3D store model
- Fixture placement and manipulation
- Real-time layout changes
- Heatmap overlays
- Multiple instances for comparison

**Interaction Patterns**:
- **Gaze + Pinch**: Select fixtures
- **Drag**: Move fixtures in 3D space
- **Two-hand pinch**: Scale fixtures
- **Rotate gesture**: Rotate fixtures
- **Tap**: Show fixture details

### 2.3 Immersive Spaces (Full Experiences)

#### Store Walkthrough Space
```swift
ImmersiveSpace(id: "store-immersive") {
    StoreImmersiveView()
        .environment(appModel)
        .upperLimbVisibility(.hidden)  // Hide hands for cleaner presentation
}
.immersionStyle(selection: $immersionStyle, in: .mixed, .progressive, .full)
```

**Modes**:
- **Mixed**: Store with passthrough visible (default for editing)
- **Progressive**: Dimmed passthrough for focused work
- **Full**: Complete immersion for presentations

**Purpose**: Full-scale store exploration
**Features**:
- 1:1 scale store walkthrough
- Customer journey playback
- Presentation mode for stakeholders
- Spatial audio for ambiance

**Navigation**:
- **Walk**: Physical movement in safe area
- **Teleport**: Gaze + pinch to jump to location
- **Guided tour**: Automated camera path

## 3. Gesture and Interaction Specifications

### 3.1 Standard visionOS Gestures

#### Primary Interactions
```swift
// Tap Gesture
.onTapGesture {
    selectFixture(fixture)
}

// Long Press
.onLongPressGesture(minimumDuration: 0.5) {
    showContextMenu(for: fixture)
}

// Drag Gesture (2D in windows)
.gesture(
    DragGesture()
        .onChanged { value in
            updatePosition(value.translation)
        }
        .onEnded { value in
            finalizePosition()
        }
)

// Magnification (Pinch to zoom)
.gesture(
    MagnifyGesture()
        .onChanged { value in
            updateScale(value.magnification)
        }
)

// Rotation
.gesture(
    RotateGesture3D()
        .onChanged { value in
            updateRotation(value.rotation)
        }
)
```

#### Spatial Gestures (3D Volumes)
```swift
struct FixtureEntity: View {
    @State private var position: SIMD3<Float> = [0, 0, 0]
    @State private var isDragging = false

    var body: some View {
        Model3D(named: fixture.modelAsset)
            .gesture(
                DragGesture()
                    .targetedToAnyEntity()
                    .onChanged { value in
                        isDragging = true
                        // Convert 2D drag to 3D position
                        let translation = value.convert(value.translation3D, from: .local, to: .scene)
                        position = SIMD3<Float>(translation)
                    }
                    .onEnded { _ in
                        isDragging = false
                        saveFixturePosition()
                    }
            )
            .scaleEffect(isDragging ? 1.1 : 1.0)
            .animation(.spring(), value: isDragging)
    }
}
```

### 3.2 Custom Gestures

#### Fixture Placement Gesture
```swift
struct FixturePlacementGesture: Gesture {
    @Binding var fixture: Fixture
    @Binding var isPlaced: Bool

    var body: some Gesture {
        DragGesture(minimumDistance: 0)
            .simultaneously(with: MagnifyGesture())
            .onChanged { value in
                if let drag = value.first {
                    updateFixturePosition(drag.translation)
                }
                if let magnify = value.second {
                    updateFixtureScale(magnify.magnification)
                }
            }
            .onEnded { _ in
                isPlaced = true
                validatePlacement()
            }
    }
}
```

#### Multi-Selection Gesture
```swift
class MultiSelectGestureRecognizer {
    private var selectedFixtures: Set<UUID> = []

    func handleSelection(fixture: Fixture, modifierKeys: EventModifiers) {
        if modifierKeys.contains(.command) {
            // Add to selection
            selectedFixtures.insert(fixture.id)
        } else if modifierKeys.contains(.shift) {
            // Range selection
            selectRange(to: fixture)
        } else {
            // Single selection
            selectedFixtures = [fixture.id]
        }
    }
}
```

### 3.3 Accessibility Interactions

#### Voice Commands (Siri Integration)
```swift
struct VoiceCommands {
    static let commands = [
        "Show traffic heatmap",
        "Hide analytics overlay",
        "Select all fixtures",
        "Reset view",
        "Save changes",
        "Generate suggestions"
    ]
}

// Intent handling
class VoiceCommandHandler: NSObject, INUIAddVoiceShortcutViewControllerDelegate {
    func handleCommand(_ command: String) {
        switch command {
        case "Show traffic heatmap":
            showHeatmap(type: .traffic)
        case "Generate suggestions":
            generateOptimizationSuggestions()
        // ... other commands
        default:
            break
        }
    }
}
```

#### Alternative Input Methods
```swift
// Switch Control support
.accessibilityAddTraits(.isButton)
.accessibilityAction(named: "Place Fixture") {
    placeFixtureAtDefaultPosition()
}
.accessibilityAction(named: "Delete Fixture") {
    deleteSelectedFixture()
}

// Keyboard shortcuts
.keyboardShortcut("s", modifiers: .command)  // Save
.keyboardShortcut("z", modifiers: .command)  // Undo
.keyboardShortcut("a", modifiers: .command)  // Select All
```

## 4. Hand Tracking Implementation

### 4.1 Hand Tracking Setup

```swift
import ARKit

class HandTrackingManager: ObservableObject {
    private var arKitSession = ARKitSession()
    private var handTracking = HandTrackingProvider()

    @Published var leftHandAnchor: HandAnchor?
    @Published var rightHandAnchor: HandAnchor?
    @Published var gesture: HandGesture = .none

    func startTracking() async {
        do {
            if HandTrackingProvider.isSupported {
                try await arKitSession.run([handTracking])

                for await update in handTracking.anchorUpdates {
                    handleHandUpdate(update)
                }
            }
        } catch {
            print("Failed to start hand tracking: \(error)")
        }
    }

    private func handleHandUpdate(_ update: HandAnchorUpdate) {
        let anchor = update.anchor

        if anchor.chirality == .left {
            leftHandAnchor = anchor
        } else {
            rightHandAnchor = anchor
        }

        detectGesture(anchor)
    }

    private func detectGesture(_ anchor: HandAnchor) {
        // Detect pinch
        if let thumbTip = anchor.handSkeleton?.joint(.thumbTip),
           let indexTip = anchor.handSkeleton?.joint(.indexFingerTip) {

            let distance = simd_distance(
                thumbTip.anchorFromJointTransform.columns.3.xyz,
                indexTip.anchorFromJointTransform.columns.3.xyz
            )

            if distance < 0.02 {  // 2cm threshold
                gesture = .pinch
            } else {
                gesture = .none
            }
        }
    }
}

enum HandGesture {
    case none
    case pinch
    case grab
    case point
    case openPalm
}
```

### 4.2 Custom Hand Gestures

```swift
class GestureRecognizer {
    func recognizeGesture(hand: HandAnchor) -> CustomGesture? {
        guard let skeleton = hand.handSkeleton else { return nil }

        // Palm-up gesture for menu
        if isPalmUp(skeleton) {
            return .palmUpMenu
        }

        // Fist for grab
        if isFist(skeleton) {
            return .fistGrab
        }

        // Two-finger pinch for precision
        if isTwoFingerPinch(skeleton) {
            return .precisionPinch
        }

        return nil
    }

    private func isPalmUp(_ skeleton: HandSkeleton) -> Bool {
        guard let wrist = skeleton.joint(.wrist),
              let middleFingerMCP = skeleton.joint(.middleFingerMetacarpal) else {
            return false
        }

        let palmNormal = normalize(cross(
            middleFingerMCP.anchorFromJointTransform.columns.3.xyz - wrist.anchorFromJointTransform.columns.3.xyz,
            SIMD3<Float>(1, 0, 0)
        ))

        return palmNormal.y > 0.8  // Facing upward
    }

    private func isFist(_ skeleton: HandSkeleton) -> Bool {
        let fingerTips: [HandSkeleton.JointName] = [
            .thumbTip, .indexFingerTip, .middleFingerTip,
            .ringFingerTip, .littleFingerTip
        ]

        guard let wrist = skeleton.joint(.wrist) else { return false }

        var closedCount = 0
        for tipName in fingerTips {
            if let tip = skeleton.joint(tipName) {
                let distance = simd_distance(
                    tip.anchorFromJointTransform.columns.3,
                    wrist.anchorFromJointTransform.columns.3
                )
                if distance < 0.10 {  // Within 10cm of wrist
                    closedCount += 1
                }
            }
        }

        return closedCount >= 4
    }
}

enum CustomGesture {
    case palmUpMenu
    case fistGrab
    case precisionPinch
    case twoHandScale
}
```

## 5. Eye Tracking Implementation

### 5.1 Eye Tracking for UI Focus

```swift
// Note: Eye tracking in visionOS is primarily used by the system for UI focus
// Direct eye gaze data is not available to apps for privacy reasons

// Use system-provided focus tracking
struct FocusableFixture: View {
    let fixture: Fixture
    @State private var isFocused = false

    var body: some View {
        Model3D(named: fixture.modelAsset)
            .hoverEffect(.highlight)
            .onHover { hovering in
                isFocused = hovering
            }
            .opacity(isFocused ? 1.0 : 0.8)
            .scaleEffect(isFocused ? 1.05 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: isFocused)
    }
}
```

### 5.2 Focus-Based Interactions

```swift
struct SmartToolbar: View {
    @State private var hoveredTool: Tool?

    var body: some View {
        HStack(spacing: 20) {
            ForEach(tools) { tool in
                ToolButton(tool: tool)
                    .onHover { hovering in
                        if hovering {
                            hoveredTool = tool
                            // Show tooltip after brief hover
                            Task {
                                try? await Task.sleep(for: .milliseconds(500))
                                if hoveredTool == tool {
                                    showTooltip(for: tool)
                                }
                            }
                        } else {
                            if hoveredTool == tool {
                                hoveredTool = nil
                                hideTooltip()
                            }
                        }
                    }
            }
        }
    }
}
```

## 6. Spatial Audio Specifications

### 6.1 Audio Setup

```swift
import AVFoundation
import RealityKit

class SpatialAudioManager {
    private var audioEngine = AVAudioEngine()
    private var environmentNode = AVAudioEnvironmentNode()

    init() {
        setupAudioEngine()
    }

    private func setupAudioEngine() {
        audioEngine.attach(environmentNode)
        audioEngine.connect(environmentNode, to: audioEngine.mainMixerNode, format: nil)

        // Configure spatial rendering
        environmentNode.listenerPosition = AVAudio3DPoint(x: 0, y: 0, z: 0)
        environmentNode.renderingAlgorithm = .HRTF

        do {
            try audioEngine.start()
        } catch {
            print("Failed to start audio engine: \(error)")
        }
    }

    func playSound(at position: SIMD3<Float>, sound: String) {
        guard let url = Bundle.main.url(forResource: sound, withExtension: "wav") else {
            return
        }

        let audioFile = try? AVAudioFile(forReading: url)
        let player = AVAudioPlayerNode()

        audioEngine.attach(player)
        audioEngine.connect(player, to: environmentNode, format: audioFile?.processingFormat)

        environmentNode.position = AVAudio3DPoint(
            x: position.x,
            y: position.y,
            z: position.z
        )

        if let buffer = try? AVAudioPCMBuffer(url: url) {
            player.scheduleBuffer(buffer)
            player.play()
        }
    }
}
```

### 6.2 Audio Feedback

```swift
enum SoundEffect: String {
    case fixturePlace = "fixture_place"
    case fixtureDelete = "fixture_delete"
    case notification = "notification"
    case success = "success"
    case error = "error"
    case hover = "hover_subtle"
}

class AudioFeedbackController {
    private let audioManager = SpatialAudioManager()

    func playFeedback(_ effect: SoundEffect, at position: SIMD3<Float>? = nil) {
        let soundPosition = position ?? SIMD3<Float>(0, 0, -0.5)  // Default in front of user
        audioManager.playSound(at: soundPosition, sound: effect.rawValue)
    }

    func playAmbientStoreAudio(volume: Float = 0.3) {
        // Subtle background audio for immersive mode
        // Customer murmurs, ambient music, etc.
    }
}
```

## 7. Accessibility Requirements

### 7.1 VoiceOver Support

```swift
// Descriptive labels for 3D content
extension FixtureEntity {
    var accessibilityLabel: String {
        "\(fixture.type.rawValue) fixture named \(fixture.name) at position \(fixture.position.description)"
    }

    var accessibilityHint: String {
        "Double-tap to select, then drag to move, or pinch to scale"
    }

    var accessibilityValue: String {
        if let products = fixture.products, !products.isEmpty {
            return "Contains \(products.count) products"
        }
        return "Empty"
    }
}

// Complex view accessibility
struct StoreVolumeView: View {
    var body: some View {
        RealityView { content in
            // ... setup 3D content
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("3D Store Layout")
        .accessibilityHint("Contains \(fixtures.count) fixtures. Use explore gestures to navigate.")
    }
}
```

### 7.2 Dynamic Type Support

```swift
// Scale text appropriately
Text("Store Analytics")
    .font(.title)
    .dynamicTypeSize(.large...(.accessibility5))

// Scale UI elements
Button("Add Fixture") {
    addFixture()
}
.padding()
.background(Color.accentColor)
.dynamicTypeSize(.medium...(.accessibility3))
```

### 7.3 Reduce Motion Support

```swift
@Environment(\.accessibilityReduceMotion) var reduceMotion

var animation: Animation {
    reduceMotion ? .none : .spring(response: 0.3, dampingFraction: 0.7)
}

// Apply conditionally
.animation(animation, value: isSelected)
```

### 7.4 High Contrast Mode

```swift
@Environment(\.colorSchemeContrast) var contrast

var borderColor: Color {
    contrast == .increased ? .primary : .secondary
}

var borderWidth: CGFloat {
    contrast == .increased ? 3 : 1
}
```

## 8. Privacy and Security Requirements

### 8.1 Privacy Manifest

```xml
<!-- NSPrivacyAccessedAPICategoryFileTimestamp -->
<key>NSPrivacyAccessedAPITypes</key>
<array>
    <dict>
        <key>NSPrivacyAccessedAPIType</key>
        <string>NSPrivacyAccessedAPICategoryFileTimestamp</string>
        <key>NSPrivacyAccessedAPITypeReasons</key>
        <array>
            <string>C617.1</string>  <!-- Access for cache management -->
        </array>
    </dict>
</array>

<!-- Privacy Nutrition Labels -->
<key>NSPrivacyCollectedDataTypes</key>
<array>
    <dict>
        <key>NSPrivacyCollectedDataType</key>
        <string>NSPrivacyCollectedDataTypeProductInteraction</string>
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

### 8.2 Data Protection

```swift
// Keychain for sensitive data
class SecureStorage {
    func save(token: String, for key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: token.data(using: .utf8)!,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]

        SecItemDelete(query as CFDictionary)  // Delete existing
        let status = SecItemAdd(query as CFDictionary, nil)

        guard status == errSecSuccess else {
            throw KeychainError.saveFailed(status)
        }
    }

    func retrieve(key: String) throws -> String {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess,
              let data = result as? Data,
              let token = String(data: data, encoding: .utf8) else {
            throw KeychainError.retrieveFailed(status)
        }

        return token
    }
}
```

### 8.3 Network Security

```swift
// Certificate pinning
class NetworkSecurityManager {
    private let pinnedCertificates: [Data]

    init() {
        // Load pinned certificates from bundle
        pinnedCertificates = Self.loadCertificates()
    }

    func validateServerTrust(_ serverTrust: SecTrust, for host: String) -> Bool {
        // Validate certificate chain
        guard let serverCertificate = SecTrustGetCertificateAtIndex(serverTrust, 0) else {
            return false
        }

        let serverCertificateData = SecCertificateCopyData(serverCertificate) as Data

        return pinnedCertificates.contains(serverCertificateData)
    }

    private static func loadCertificates() -> [Data] {
        // Load from bundle
        guard let certPath = Bundle.main.path(forResource: "api-cert", ofType: "cer"),
              let certData = try? Data(contentsOf: URL(fileURLWithPath: certPath)) else {
            return []
        }
        return [certData]
    }
}
```

## 9. Data Persistence Strategy

### 9.1 SwiftData Configuration

```swift
// Model container with cloud sync
let container = try ModelContainer(
    for: Store.self, Fixture.self, Product.self,
    configurations: ModelConfiguration(
        cloudKitDatabase: .automatic
    )
)

// Background context for async operations
extension ModelContext {
    static func background(from container: ModelContainer) -> ModelContext {
        let context = ModelContext(container)
        context.autosaveEnabled = true
        return context
    }
}
```

### 9.2 Data Synchronization

```swift
actor DataSyncManager {
    private let container: ModelContainer
    private var lastSyncDate: Date?

    func syncWithServer() async throws {
        let context = ModelContext.background(from: container)

        // Fetch changes since last sync
        let changes = try await fetchServerChanges(since: lastSyncDate)

        // Apply changes
        try await context.transaction {
            for change in changes {
                try applyChange(change, in: context)
            }
        }

        // Upload local changes
        let localChanges = try fetchLocalChanges(in: context)
        try await uploadChanges(localChanges)

        lastSyncDate = Date()
    }

    private func applyChange(_ change: ServerChange, in context: ModelContext) throws {
        switch change.type {
        case .insert:
            let object = try change.createObject()
            context.insert(object)
        case .update:
            let object = try context.fetch(change.fetchDescriptor).first
            try object?.apply(change)
        case .delete:
            let object = try context.fetch(change.fetchDescriptor).first
            context.delete(object)
        }
    }
}
```

## 10. Network Architecture

### 10.1 API Client Implementation

```swift
enum APIEndpoint {
    case getStores
    case getStore(id: UUID)
    case createStore(Store)
    case updateStore(Store)
    case deleteStore(id: UUID)
    case getAnalytics(storeID: UUID, dateRange: DateInterval)
    case generateSuggestions(storeID: UUID)

    var path: String {
        switch self {
        case .getStores:
            return "/stores"
        case .getStore(let id):
            return "/stores/\(id)"
        case .createStore:
            return "/stores"
        // ... other cases
        }
    }

    var method: String {
        switch self {
        case .getStores, .getStore, .getAnalytics:
            return "GET"
        case .createStore, .generateSuggestions:
            return "POST"
        case .updateStore:
            return "PUT"
        case .deleteStore:
            return "DELETE"
        }
    }
}
```

### 10.2 WebSocket for Real-time Collaboration

```swift
actor CollaborationWebSocket: NSObject, URLSessionWebSocketDelegate {
    private var webSocket: URLSessionWebSocketTask?
    private var sessionID: UUID?

    func connect(to sessionID: UUID) async throws {
        let url = URL(string: "wss://api.retailoptimizer.com/v1/sessions/\(sessionID)/sync")!
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)

        webSocket = session.webSocketTask(with: url)
        webSocket?.resume()

        await receiveMessages()
    }

    func send(change: StoreChange) async throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(change)
        let message = URLSessionWebSocketTask.Message.data(data)

        try await webSocket?.send(message)
    }

    private func receiveMessages() async {
        guard let webSocket = webSocket else { return }

        do {
            let message = try await webSocket.receive()

            switch message {
            case .data(let data):
                handleChange(data)
            case .string(let string):
                handleMessage(string)
            @unknown default:
                break
            }

            // Continue receiving
            await receiveMessages()
        } catch {
            print("WebSocket error: \(error)")
        }
    }

    nonisolated func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        print("WebSocket connected")
    }

    nonisolated func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        print("WebSocket disconnected")
    }
}
```

## 11. Testing Requirements

### 11.1 Unit Testing

```swift
@testable import RetailSpaceOptimizer
import XCTest
import SwiftData

final class StoreServiceTests: XCTestCase {
    var container: ModelContainer!
    var storeService: StoreServiceImpl!

    @MainActor
    override func setUp() async throws {
        // In-memory container for testing
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try ModelContainer(
            for: Store.self, Fixture.self,
            configurations: config
        )

        let context = ModelContext(container)
        storeService = StoreServiceImpl(context: context)
    }

    @MainActor
    func testCreateStore() async throws {
        let store = Store(
            name: "Test Store",
            location: StoreLocation(address: "123 Main St", city: "TestCity", state: "TS", country: "US"),
            dimensions: StoreDimensions(width: 20, depth: 30, height: 4, floorArea: 600)
        )

        try await storeService.createStore(store)

        let fetchedStores = try await storeService.fetchStores()
        XCTAssertEqual(fetchedStores.count, 1)
        XCTAssertEqual(fetchedStores.first?.name, "Test Store")
    }

    @MainActor
    func testOptimizationSuggestions() async throws {
        let store = createTestStore()
        let suggestions = try await optimizationService.generateSuggestions(storeID: store.id)

        XCTAssertFalse(suggestions.isEmpty)
        XCTAssertGreaterThan(suggestions.first?.confidence ?? 0, 0.7)
    }
}
```

### 11.2 UI Testing

```swift
final class StoreVolumeUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUp() {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UI-Testing"]
        app.launch()
    }

    func testFixturePlacement() throws {
        // Open store volume
        app.buttons["Open 3D View"].tap()

        // Wait for volume to load
        let volume = app.windows["Store 3D"]
        XCTAssertTrue(volume.waitForExistence(timeout: 5))

        // Select fixture from palette
        app.buttons["Shelf Fixture"].tap()

        // Place in scene
        let scene = volume.otherElements["Store Scene"]
        scene.tap()

        // Verify fixture was placed
        XCTAssertTrue(app.staticTexts["Fixture placed"].waitForExistence(timeout: 2))
    }

    func testCollaboration() throws {
        // Start collaboration session
        app.buttons["Start Session"].tap()

        // Verify session started
        XCTAssertTrue(app.staticTexts["Session Active"].exists)

        // Make a change
        app.buttons["Move Fixture"].tap()

        // Verify change synced
        XCTAssertTrue(app.staticTexts["Synced"].waitForExistence(timeout: 3))
    }
}
```

### 11.3 Performance Testing

```swift
final class PerformanceTests: XCTestCase {
    func testStoreLoadingPerformance() throws {
        measure(metrics: [XCTClockMetric(), XCTMemoryMetric()]) {
            let store = loadComplexStore(fixtureCount: 500)
            XCTAssertNotNil(store)
        }
    }

    func testHeatmapGenerationPerformance() throws {
        let store = createTestStore()

        measure {
            let heatmap = generateTrafficHeatmap(for: store, resolution: 100)
            XCTAssertNotNil(heatmap)
        }
    }

    func testRenderingFrameRate() throws {
        let metrics = [XCTOSSignpostMetric.renderTime]
        let options = XCTMeasureOptions()
        options.iterationCount = 10

        measure(metrics: metrics, options: options) {
            renderStoreScene()
        }
    }
}
```

## 12. Build Configuration

### 12.1 Info.plist Configuration

```xml
<key>UIRequiredDeviceCapabilities</key>
<array>
    <string>arm64</string>
</array>

<key>NSCameraUsageDescription</key>
<string>Camera access is needed for spatial mapping and AR features</string>

<key>NSWorldSensingUsageDescription</key>
<string>World sensing enables accurate store visualization in your physical space</string>

<key>NSHandsTrackingUsageDescription</key>
<string>Hand tracking provides intuitive fixture placement and manipulation</string>

<!-- Supported scene types -->
<key>UIApplicationSceneManifest</key>
<dict>
    <key>UIApplicationSupportsMultipleScenes</key>
    <true/>
</dict>
```

### 12.2 Compiler Flags

```swift
// Build settings
SWIFT_STRICT_CONCURRENCY = complete
SWIFT_UPCOMING_FEATURE_FLAGS = ExistentialAny ConciseMagicFile
ENABLE_TESTABILITY = YES (Debug only)
SWIFT_OPTIMIZATION_LEVEL = -O (Release)
SWIFT_OPTIMIZATION_LEVEL = -Onone (Debug)
```

---

## Performance Benchmarks

### Target Metrics
- **Frame Rate**: Consistent 90 FPS
- **App Launch**: < 2 seconds
- **Store Load**: < 3 seconds (500 fixtures)
- **Heatmap Generation**: < 1 second (100x100 grid)
- **Network Response**: < 200ms (p95)
- **Memory Footprint**: < 500MB typical usage
- **Battery Drain**: < 5% per hour (mixed use)

---

*This technical specification provides the detailed implementation requirements for building the Retail Space Optimizer on visionOS.*
