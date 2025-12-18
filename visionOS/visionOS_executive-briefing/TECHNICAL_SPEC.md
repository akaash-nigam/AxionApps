# Technical Specification
## visionOS Executive Briefing App

### Document Version
- **Version**: 1.0
- **Date**: 2025-11-19
- **Status**: Initial Specification

---

## 1. Technology Stack

### 1.1 Core Technologies

| Component | Technology | Version | Purpose |
|-----------|-----------|---------|---------|
| Platform | visionOS | 2.0+ | Target operating system |
| Language | Swift | 6.0+ | Primary development language |
| Concurrency | Swift Concurrency | 6.0+ | async/await, actors |
| UI Framework | SwiftUI | Latest | Declarative UI |
| 3D Engine | RealityKit | 2.0+ | 3D rendering and spatial content |
| AR Framework | ARKit | 5.0+ | Spatial tracking and anchors |
| Persistence | SwiftData | 1.0+ | Data storage and management |
| Testing | XCTest | Latest | Unit and integration tests |
| UI Testing | XCUITest | Latest | Automated UI tests |
| Build Tool | Xcode | 16.0+ | IDE and build system |

### 1.2 Swift Package Dependencies

```swift
// Package.swift dependencies (if needed)
dependencies: [
    // None required for MVP - using system frameworks only
    // Future: Charts library for advanced visualizations
]
```

### 1.3 System Frameworks

```swift
import SwiftUI          // UI components
import RealityKit       // 3D content
import ARKit            // Spatial tracking
import SwiftData        // Persistence
import Observation      // @Observable macro
import OSLog            // Logging
import Spatial          // Spatial math utilities
```

---

## 2. visionOS Presentation Modes

### 2.1 WindowGroup Configuration

#### Main Window
```swift
@main
struct ExecutiveBriefingApp: App {
    @State private var appState = AppState()

    var body: some Scene {
        // Main navigation window
        WindowGroup(id: "main") {
            BriefingNavigationView()
                .environment(appState)
        }
        .windowStyle(.plain)
        .defaultSize(width: 1000, height: 800)
        .windowResizability(.contentSize)

        // Data visualization volumes
        WindowGroup(id: "roi-visualization", for: VisualizationType.self) { $vizType in
            if let type = vizType {
                DataVisualizationVolume(type: type)
                    .environment(appState)
            }
        }
        .windowStyle(.volumetric)
        .defaultSize(width: 600, height: 600, depth: 600, in: .points)

        // Immersive environment (optional)
        ImmersiveSpace(id: "immersive-briefing") {
            ImmersiveBriefingView()
                .environment(appState)
        }
        .immersionStyle(selection: .constant(.mixed), in: .mixed)
    }
}
```

### 2.2 Window Management

```swift
@Environment(\.openWindow) private var openWindow
@Environment(\.dismissWindow) private var dismissWindow
@Environment(\.openImmersiveSpace) private var openImmersiveSpace
@Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace

// Opening windows programmatically
func openROIVisualization() {
    openWindow(id: "roi-visualization", value: VisualizationType.roiComparison)
}

func openImmersive() async {
    await openImmersiveSpace(id: "immersive-briefing")
}
```

### 2.3 Scene Phases

```swift
@Environment(\.scenePhase) private var scenePhase

// React to scene phase changes
.onChange(of: scenePhase) { oldPhase, newPhase in
    switch newPhase {
    case .active:
        // Resume animations, refresh data
        viewModel.resume()
    case .inactive:
        // Pause animations
        viewModel.pause()
    case .background:
        // Save state, cleanup resources
        viewModel.saveState()
    @unknown default:
        break
    }
}
```

---

## 3. Gesture and Interaction Specifications

### 3.1 Standard Gestures

#### Tap Gesture
```swift
// Single tap to select
.onTapGesture {
    selectItem(item)
}

// Double tap for alternate action
.onTapGesture(count: 2) {
    expandItem(item)
}
```

#### Drag Gesture
```swift
// 3D drag for repositioning volumes
.gesture(
    DragGesture()
        .targetedToAnyEntity()
        .onChanged { value in
            entity.position = value.convert(value.location3D, from: .local, to: .scene)
        }
)
```

#### Rotation and Scale
```swift
// Rotate 3D objects
.gesture(
    RotateGesture3D()
        .targetedToEntity(entity)
        .onChanged { value in
            entity.orientation = value.rotation
        }
)

// Scale volumes
.gesture(
    MagnifyGesture()
        .targetedToEntity(entity)
        .onChanged { value in
            entity.scale = SIMD3<Float>(repeating: Float(value.magnification))
        }
)
```

### 3.2 Custom Spatial Gestures

```swift
// Hand tracking for pinch-to-select
class HandGestureManager {
    func setupHandTracking() {
        let handTracking = HandTrackingProvider()
        // Configure hand tracking
    }

    func detectPinchGesture(hand: HandAnchor) -> Bool {
        // Detect thumb and index finger pinch
        let thumbTip = hand.thumbTip
        let indexTip = hand.indexTip
        let distance = simd_distance(thumbTip.position, indexTip.position)
        return distance < 0.02 // 2cm threshold
    }
}
```

### 3.3 Hover Effects

```swift
// Hover highlighting
struct InteractiveCard: View {
    @State private var isHovered = false

    var body: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(.ultraThinMaterial)
            .hoverEffect(.highlight)
            .onHover { hovering in
                isHovered = hovering
            }
            .scaleEffect(isHovered ? 1.05 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: isHovered)
    }
}
```

---

## 4. Hand Tracking Implementation

### 4.1 Hand Tracking Setup

```swift
import ARKit

class HandTrackingService {
    private var handTracking = HandTrackingProvider()
    private var latestHandAnchor: HandAnchor?

    func startTracking() async {
        do {
            try await handTracking.start()
        } catch {
            print("Failed to start hand tracking: \(error)")
        }
    }

    func updateHandAnchors() async {
        for await update in handTracking.anchorUpdates {
            switch update.event {
            case .added, .updated:
                latestHandAnchor = update.anchor
                processHandGesture(update.anchor)
            case .removed:
                latestHandAnchor = nil
            }
        }
    }

    private func processHandGesture(_ anchor: HandAnchor) {
        // Detect custom gestures
        if detectPointingGesture(anchor) {
            // Handle pointing
        }
    }

    private func detectPointingGesture(_ hand: HandAnchor) -> Bool {
        // Index finger extended, others curled
        // Implementation details...
        return false
    }
}
```

### 4.2 Gesture Detection

```swift
enum CustomGesture {
    case pinch
    case point
    case swipe(direction: SwipeDirection)
    case grab
}

enum SwipeDirection {
    case left, right, up, down
}

class GestureDetector {
    func detectGesture(from hand: HandAnchor) -> CustomGesture? {
        // Analyze hand joint positions
        // Return detected gesture
        return nil
    }
}
```

---

## 5. Eye Tracking Implementation

### 5.1 Eye Tracking (Optional - Privacy Sensitive)

```swift
// Eye tracking for UI optimization (not storing data)
class EyeTrackingService {
    func setupEyeTracking() {
        // Request permission
        // Note: Eye tracking data never leaves device
    }

    func getGazeDirection() -> SIMD3<Float>? {
        // Get current gaze direction for hover effects
        // Used only for immediate UI feedback
        return nil
    }
}
```

**Privacy Note**:
- Eye tracking used ONLY for hover effects
- No data stored or transmitted
- User consent required
- Can be completely disabled

---

## 6. Spatial Audio Specifications

### 6.1 Audio Configuration

```swift
import AVFoundation

class SpatialAudioManager {
    private var audioEngine = AVAudioEngine()
    private var audioEnvironment = AVAudioEnvironmentNode()

    func setupSpatialAudio() {
        audioEngine.attach(audioEnvironment)

        // Configure environmental reverb
        audioEnvironment.listenerPosition = AVAudio3DPoint(x: 0, y: 0, z: 0)
        audioEnvironment.renderingAlgorithm = .HRTF

        audioEngine.prepare()
        try? audioEngine.start()
    }

    func playSound(at position: SIMD3<Float>, resource: String) {
        let player = AVAudioPlayerNode()
        audioEngine.attach(player)

        // Load audio file
        guard let audioFile = try? AVAudioFile(forReading: URL(fileURLWithPath: resource)) else {
            return
        }

        // Position in 3D space
        player.position = AVAudio3DPoint(
            x: position.x,
            y: position.y,
            z: position.z
        )

        audioEngine.connect(player, to: audioEnvironment, format: audioFile.processingFormat)
        player.scheduleFile(audioFile, at: nil)
        player.play()
    }
}
```

### 6.2 Audio Events

```swift
enum AudioEvent {
    case sectionTransition
    case useCaseHighlight
    case actionItemChecked
    case volumeOpened
    case error

    var soundFile: String {
        switch self {
        case .sectionTransition: return "transition.wav"
        case .useCaseHighlight: return "highlight.wav"
        case .actionItemChecked: return "check.wav"
        case .volumeOpened: return "volume_open.wav"
        case .error: return "error.wav"
        }
    }
}
```

---

## 7. Accessibility Requirements

### 7.1 VoiceOver Support

```swift
// All interactive elements must have labels
Button("Open ROI Visualization") {
    openROIChart()
}
.accessibilityLabel("Open Return on Investment Visualization")
.accessibilityHint("Opens a 3D chart showing ROI comparison for different use cases")

// Images need descriptions
Image("use-case-icon")
    .accessibilityLabel("Remote Expert Assistance icon")
    .accessibilityHidden(false)

// Complex custom views
var body: some View {
    CustomChart()
        .accessibilityElement(children: .combine)
        .accessibilityLabel("ROI Comparison Chart")
        .accessibilityValue("Remote Expert Assistance: 400%, Training: 350%, Surgical Planning: 250%")
}
```

### 7.2 Dynamic Type Support

```swift
// Use dynamic type for all text
Text("Executive Summary")
    .font(.title)  // Automatically scales
    .dynamicTypeSize(...DynamicTypeSize.xxxLarge)  // Limit max size if needed

// Custom fonts with dynamic type
Text("ROI: 400%")
    .font(.custom("CustomFont", size: 24, relativeTo: .headline))
```

### 7.3 Reduced Motion

```swift
@Environment(\.accessibilityReduceMotion) var reduceMotion

// Conditional animations
.animation(reduceMotion ? .none : .spring(response: 0.5), value: isExpanded)

// Alternative for complex animations
if reduceMotion {
    StaticView()
} else {
    AnimatedView()
}
```

### 7.4 Color Contrast

```swift
// Use system colors that adapt to contrast settings
.foreground Color.primary)
.background(Color(uiColor: .systemBackground))

// Ensure 4.5:1 contrast ratio for text
// Use .accessibilityBackground() for custom colors
```

### 7.5 Alternative Interaction Methods

```swift
// Support for alternative inputs
.onTapGesture {
    performAction()
}
.keyboardShortcut("r", modifiers: .command)  // Also support keyboard
.accessibilityAction(.magicTap) {
    performAction()  // Support Magic Tap gesture
}
```

---

## 8. Privacy and Security Requirements

### 8.1 Data Collection Policy

**Collected Data** (all local only):
- Reading progress
- Completed action items
- Preferred visualization modes
- App usage time

**NOT Collected**:
- Eye tracking data (if enabled, used only for real-time hover)
- Hand gestures (processed locally, not stored)
- Personal information
- Location data

### 8.2 Privacy Manifest

```xml
<!-- NSPrivacyAccessedAPICategoryUserDefaults -->
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
```

### 8.3 Data Encryption

```swift
// SwiftData automatic encryption
@Model
class UserProgress {
    var userId: UUID
    var sectionsRead: [UUID]
    var actionItemsCompleted: [UUID]
    var lastAccessed: Date

    // Stored encrypted on device
}

// Keychain for sensitive data
class SecureStorage {
    func save(key: String, data: Data) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        SecItemAdd(query as CFDictionary, nil)
    }
}
```

### 8.4 Permissions

**Required Permissions**:
- None for basic functionality

**Optional Permissions** (with clear opt-in):
- Hand tracking (for advanced gestures)
- Eye tracking (for UI hover effects)

---

## 9. Data Persistence Strategy

### 9.1 SwiftData Models

```swift
import SwiftData

// Main data container
@main
struct ExecutiveBriefingApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            BriefingSection.self,
            UseCase.self,
            DecisionPoint.self,
            InvestmentPhase.self,
            ActionItem.self,
            UserProgress.self
        ])
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            allowsSave: true
        )

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            BriefingNavigationView()
        }
        .modelContainer(sharedModelContainer)
    }
}
```

### 9.2 Data Access Patterns

```swift
// Accessing SwiftData from views
struct SectionDetailView: View {
    @Query(sort: \BriefingSection.order) var sections: [BriefingSection]
    @Environment(\.modelContext) private var modelContext

    func markAsRead(section: BriefingSection) {
        // Create or update progress
        let progress = UserProgress(sectionId: section.id, readAt: Date())
        modelContext.insert(progress)
        try? modelContext.save()
    }
}

// Filtered queries
@Query(
    filter: #Predicate<UseCase> { useCase in
        useCase.roi >= 300
    },
    sort: \.roi,
    order: .reverse
) var highROIUseCases: [UseCase]
```

### 9.3 Data Seeding

```swift
class DataSeeder {
    static func seedInitialData(modelContext: ModelContext) async throws {
        // Check if already seeded
        let descriptor = FetchDescriptor<BriefingSection>()
        let existingSections = try modelContext.fetch(descriptor)

        guard existingSections.isEmpty else { return }

        // Parse markdown content
        let briefingContent = try loadMarkdownContent()

        // Create models
        let sections = parseBriefingSections(from: briefingContent)

        for section in sections {
            modelContext.insert(section)
        }

        try modelContext.save()
    }

    private static func loadMarkdownContent() throws -> String {
        guard let url = Bundle.main.url(forResource: "Executive-Briefing-AR-VR-2025", withExtension: "md") else {
            throw BriefingError.dataLoadingFailed
        }
        return try String(contentsOf: url)
    }
}
```

---

## 10. Network Architecture (Future)

### 10.1 API Client (Not in MVP)

```swift
// Future: API client for content updates
actor APIClient {
    private let baseURL = URL(string: "https://api.example.com/v1")!
    private let session: URLSession

    init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.waitsForConnectivity = true
        self.session = URLSession(configuration: config)
    }

    func fetchLatestBriefing() async throws -> BriefingData {
        let url = baseURL.appendingPathComponent("briefing/latest")
        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw APIError.invalidResponse
        }

        return try JSONDecoder().decode(BriefingData.self, from: data)
    }
}

enum APIError: Error {
    case invalidResponse
    case networkError(Error)
    case decodingError(Error)
}
```

### 10.2 Caching Strategy (Future)

```swift
actor CacheManager {
    private var memoryCache: [String: CachedItem] = [:]
    private let maxCacheAge: TimeInterval = 3600 // 1 hour

    struct CachedItem {
        let data: Data
        let timestamp: Date
    }

    func cache(key: String, data: Data) {
        memoryCache[key] = CachedItem(data: data, timestamp: Date())
    }

    func retrieve(key: String) -> Data? {
        guard let item = memoryCache[key] else { return nil }

        // Check if expired
        if Date().timeIntervalSince(item.timestamp) > maxCacheAge {
            memoryCache.removeValue(forKey: key)
            return nil
        }

        return item.data
    }
}
```

---

## 11. Testing Requirements

### 11.1 Unit Testing

```swift
import XCTest
@testable import ExecutiveBriefing

final class BriefingContentServiceTests: XCTestCase {
    var service: BriefingContentService!
    var mockContext: ModelContext!

    override func setUp() async throws {
        // Create in-memory container for testing
        let container = try ModelContainer(
            for: BriefingSection.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        mockContext = ModelContext(container)
        service = BriefingContentService(modelContext: mockContext)
    }

    func testLoadBriefing() async throws {
        // Arrange
        let testSection = BriefingSection(
            title: "Test Section",
            order: 1,
            icon: "star",
            content: []
        )
        mockContext.insert(testSection)

        // Act
        let sections = try await service.loadBriefing()

        // Assert
        XCTAssertEqual(sections.count, 1)
        XCTAssertEqual(sections.first?.title, "Test Section")
    }

    func testSearchContent() async throws {
        // Test search functionality
        let results = await service.searchContent(query: "ROI")
        XCTAssertFalse(results.isEmpty)
    }
}
```

### 11.2 UI Testing

```swift
import XCTest

final class BriefingUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUp() {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["--uitesting"]
        app.launch()
    }

    func testNavigationFlow() {
        // Test navigating through sections
        let tableOfContents = app.buttons["Table of Contents"]
        XCTAssertTrue(tableOfContents.exists)

        tableOfContents.tap()

        let executiveSummary = app.buttons["Executive Summary"]
        XCTAssertTrue(executiveSummary.waitForExistence(timeout: 2))

        executiveSummary.tap()

        // Verify content loaded
        let summaryText = app.staticTexts.containing(NSPredicate(format: "label CONTAINS 'Spatial computing'"))
        XCTAssertTrue(summaryText.firstMatch.waitForExistence(timeout: 2))
    }

    func testROIVisualization() {
        // Test opening 3D visualization
        let roiButton = app.buttons["View ROI Chart"]
        roiButton.tap()

        // Verify volume opened (check for specific UI elements)
        let chartTitle = app.staticTexts["ROI Comparison"]
        XCTAssertTrue(chartTitle.waitForExistence(timeout: 3))
    }

    func testAccessibility() {
        // Test VoiceOver support
        XCTAssertTrue(app.isAccessibilityElement || app.accessibilityElementCount() > 0)

        // Test all buttons have labels
        let buttons = app.buttons.allElementsBoundByIndex
        for button in buttons {
            XCTAssertFalse(button.label.isEmpty, "Button missing accessibility label")
        }
    }
}
```

### 11.3 Performance Testing

```swift
final class PerformanceTests: XCTestCase {
    func testBriefingLoadPerformance() {
        measure(metrics: [XCTClockMetric(), XCTMemoryMetric()]) {
            let service = BriefingContentService()
            let expectation = XCTestExpectation(description: "Load briefing")

            Task {
                _ = try await service.loadBriefing()
                expectation.fulfill()
            }

            wait(for: [expectation], timeout: 2.0)
        }
    }

    func testVisualizationRenderPerformance() {
        measure(metrics: [XCTClockMetric(), XCTCPUMetric()]) {
            let vizService = VisualizationService()
            let useCases = TestData.sampleUseCases

            Task {
                _ = await vizService.generateROIChart(useCases: useCases)
            }
        }
    }

    func testFrameRate() {
        // Target: 90 FPS sustained
        let app = XCUIApplication()
        app.launch()

        measure(metrics: [XCTOSSignpostMetric.renderingMetric]) {
            // Interact with 3D content
            app.swipeLeft()
            app.swipeRight()
            app.buttons["Rotate Chart"].tap()
        }
    }
}
```

### 11.4 Integration Testing

```swift
final class IntegrationTests: XCTestCase {
    func testDataFlowEndToEnd() async throws {
        // Test: User action → ViewModel → Service → Data → UI update
        let container = try ModelContainer(
            for: BriefingSection.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let context = ModelContext(container)
        let service = BriefingContentService(modelContext: context)
        let viewModel = SectionViewModel(section: TestData.sampleSection, service: service)

        // Seed data
        try await DataSeeder.seedInitialData(modelContext: context)

        // Load content
        await viewModel.loadContent()

        // Verify
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertNotNil(viewModel.section)
    }
}
```

---

## 12. Build and Deployment Configuration

### 12.1 Xcode Build Settings

```swift
// Build Settings
SWIFT_VERSION = 6.0
IPHONEOS_DEPLOYMENT_TARGET = 2.0  // visionOS 2.0
ENABLE_STRICT_CONCURRENCY = YES
SWIFT_UPCOMING_FEATURE_FLAGS = -enable-bare-slash-regex
DEAD_CODE_STRIPPING = YES  // Reduce app size
STRIP_SWIFT_SYMBOLS = YES  // Release only
```

### 12.2 Info.plist Configuration

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDisplayName</key>
    <string>Executive Briefing AR/VR</string>

    <key>CFBundleIdentifier</key>
    <string>com.company.executive-briefing</string>

    <key>UIApplicationSceneManifest</key>
    <dict>
        <key>UIApplicationPreferredDefaultSceneSessionRole</key>
        <string>UIWindowSceneSessionRoleApplication</string>
    </dict>

    <key>UIRequiredDeviceCapabilities</key>
    <array>
        <string>spatial-tracking</string>
    </array>

    <!-- Optional permissions -->
    <key>NSHandTrackingUsageDescription</key>
    <string>Hand tracking enables natural gesture controls for navigating the briefing content.</string>

    <key>UISupportsDocumentBrowser</key>
    <false/>

    <key>LSSupportsOpeningDocumentsInPlace</key>
    <false/>
</dict>
</plist>
```

### 12.3 Entitlements

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.developer.spatial-tracking</key>
    <true/>

    <!-- Optional: Hand tracking -->
    <key>com.apple.developer.hand-tracking</key>
    <true/>

    <!-- Data protection -->
    <key>com.apple.developer.default-data-protection</key>
    <string>NSFileProtectionComplete</string>
</dict>
</plist>
```

---

## 13. Logging and Debugging

### 13.1 OSLog Configuration

```swift
import OSLog

extension Logger {
    private static var subsystem = Bundle.main.bundleIdentifier!

    static let app = Logger(subsystem: subsystem, category: "app")
    static let data = Logger(subsystem: subsystem, category: "data")
    static let ui = Logger(subsystem: subsystem, category: "ui")
    static let visualization = Logger(subsystem: subsystem, category: "visualization")
    static let performance = Logger(subsystem: subsystem, category: "performance")
}

// Usage
Logger.app.info("App launched successfully")
Logger.data.error("Failed to load briefing: \(error.localizedDescription)")
Logger.performance.debug("Visualization rendered in \(duration)ms")
```

### 13.2 Debug Flags

```swift
struct DebugConfig {
    #if DEBUG
    static let showFPSCounter = true
    static let enableVerboseLogging = true
    static let skipAnimations = false
    static let useTestData = true
    #else
    static let showFPSCounter = false
    static let enableVerboseLogging = false
    static let skipAnimations = false
    static let useTestData = false
    #endif
}
```

---

## 14. Performance Profiling Targets

### 14.1 Key Metrics

| Metric | Target | Critical Threshold |
|--------|--------|-------------------|
| Launch Time | < 2s | < 3s |
| Content Load | < 500ms | < 1s |
| Frame Rate | 90 FPS | > 60 FPS |
| Memory Usage | < 500 MB | < 750 MB |
| CPU Usage (idle) | < 5% | < 10% |
| Battery Impact | Low | Medium |
| Network (future) | < 100ms latency | < 500ms |

### 14.2 Instruments Templates

```
Templates to use:
1. Time Profiler - CPU performance
2. Allocations - Memory leaks and usage
3. Leaks - Memory leak detection
4. Metal - GPU performance
5. SceneKit/RealityKit - 3D rendering performance
6. Energy Log - Battery impact
```

---

## 15. Continuous Integration (Future)

### 15.1 CI Pipeline

```yaml
# .github/workflows/ci.yml (future)
name: CI

on: [push, pull_request]

jobs:
  test:
    runs-on: macos-14  # With visionOS support
    steps:
      - uses: actions/checkout@v3
      - name: Build
        run: xcodebuild build -scheme ExecutiveBriefing -destination 'platform=visionOS Simulator,name=Apple Vision Pro'
      - name: Test
        run: xcodebuild test -scheme ExecutiveBriefing -destination 'platform=visionOS Simulator,name=Apple Vision Pro'
```

---

## 16. Localization (Future)

### 16.1 Internationalization Support

```swift
// Localizable strings
"nav.table_of_contents" = "Table of Contents";
"section.executive_summary" = "Executive Summary";
"action.open_visualization" = "Open Visualization";

// Usage
Text("nav.table_of_contents")  // Automatic localization

// Pluralization
let message = String.localizedStringWithFormat(
    NSLocalizedString("use_cases_count", comment: ""),
    useCaseCount
)
```

---

## Appendix A: File Structure

```
ExecutiveBriefing/
├── ExecutiveBriefing.xcodeproj
├── ExecutiveBriefing/
│   ├── App/
│   │   ├── ExecutiveBriefingApp.swift
│   │   └── AppState.swift
│   ├── Models/
│   │   ├── BriefingSection.swift
│   │   ├── UseCase.swift
│   │   ├── DecisionPoint.swift
│   │   ├── InvestmentPhase.swift
│   │   ├── ActionItem.swift
│   │   └── UserProgress.swift
│   ├── ViewModels/
│   │   ├── SectionViewModel.swift
│   │   ├── VisualizationViewModel.swift
│   │   └── ProgressViewModel.swift
│   ├── Views/
│   │   ├── Windows/
│   │   │   ├── BriefingNavigationView.swift
│   │   │   ├── TableOfContentsView.swift
│   │   │   ├── SectionDetailView.swift
│   │   │   └── ActionItemsView.swift
│   │   ├── Volumes/
│   │   │   ├── DataVisualizationVolume.swift
│   │   │   ├── ROIChartView.swift
│   │   │   ├── DecisionMatrixView.swift
│   │   │   └── TimelineView.swift
│   │   ├── ImmersiveViews/
│   │   │   └── ImmersiveBriefingView.swift
│   │   └── Components/
│   │       ├── ContentBlockView.swift
│   │       ├── MetricCard.swift
│   │       ├── UseCaseCard.swift
│   │       └── ChecklistItemView.swift
│   ├── Services/
│   │   ├── BriefingContentService.swift
│   │   ├── VisualizationService.swift
│   │   ├── SpatialLayoutService.swift
│   │   ├── ProgressService.swift
│   │   └── AnalyticsService.swift
│   ├── Utilities/
│   │   ├── MarkdownParser.swift
│   │   ├── DataSeeder.swift
│   │   ├── Extensions/
│   │   └── Logger+Extensions.swift
│   ├── Resources/
│   │   ├── Assets.xcassets
│   │   ├── Executive-Briefing-AR-VR-2025.md
│   │   ├── Sounds/
│   │   └── 3DModels/
│   └── Info.plist
├── ExecutiveBriefingTests/
│   ├── ModelTests/
│   ├── ServiceTests/
│   ├── ViewModelTests/
│   └── UtilityTests/
├── ExecutiveBriefingUITests/
│   ├── NavigationTests.swift
│   ├── VisualizationTests.swift
│   ├── AccessibilityTests.swift
│   └── PerformanceTests.swift
└── ExecutiveBriefing.xcworkspace
```

---

**Document Status**: Ready for implementation
**Next Steps**: Create DESIGN.md and IMPLEMENTATION_PLAN.md
