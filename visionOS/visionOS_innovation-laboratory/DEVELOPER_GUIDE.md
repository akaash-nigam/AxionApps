# Innovation Laboratory - Developer Guide

**Version 1.0.0** | **Last Updated: 2025-11-19**

Complete technical guide for developers working on the Innovation Laboratory visionOS application.

---

## Table of Contents

1. [Development Environment Setup](#development-environment-setup)
2. [Project Structure](#project-structure)
3. [Architecture Overview](#architecture-overview)
4. [Data Models](#data-models)
5. [Services Layer](#services-layer)
6. [Views & UI](#views--ui)
7. [RealityKit Integration](#realitykit-integration)
8. [Collaboration (SharePlay)](#collaboration-shareplay)
9. [Testing](#testing)
10. [Performance Optimization](#performance-optimization)
11. [Debugging](#debugging)
12. [Building & Distribution](#building--distribution)
13. [Contributing](#contributing)
14. [API Documentation](#api-documentation)

---

## Development Environment Setup

### Prerequisites

**Required:**
- macOS 15.0+ (Sequoia or later)
- Xcode 16.0+ (with visionOS 2.0 SDK)
- Apple Developer account
- Git

**Recommended:**
- Apple Vision Pro device (for testing spatial features)
- Minimum 16GB RAM
- 50GB free disk space

### Installation Steps

1. **Clone Repository**
   ```bash
   git clone https://github.com/your-org/visionOS_innovation-laboratory.git
   cd visionOS_innovation-laboratory
   ```

2. **Open Project**
   ```bash
   cd InnovationLaboratory
   open InnovationLaboratory.xcodeproj
   ```

3. **Configure Signing**
   - Select project in Xcode
   - Choose your team in "Signing & Capabilities"
   - Update bundle identifier if needed

4. **Build Project**
   ```bash
   # Command line
   xcodebuild -scheme InnovationLaboratory -destination 'platform=visionOS Simulator,name=Apple Vision Pro'

   # Or in Xcode: ⌘B
   ```

5. **Run on Simulator**
   ```bash
   # Select "Apple Vision Pro" simulator
   # Press ⌘R to run
   ```

### Development Tools

**Code Quality:**
```bash
# Install SwiftLint
brew install swiftlint

# Run linter
swiftlint

# Auto-fix issues
swiftlint --fix
```

**Code Formatting:**
```bash
# Install swift-format
brew install swift-format

# Format code
swift-format -i -r InnovationLaboratory/
```

**Dependency Management:**
- Swift Package Manager (built-in to Xcode)
- No external dependencies (all Apple frameworks)

---

## Project Structure

```
InnovationLaboratory/
├── App/
│   ├── InnovationLaboratoryApp.swift     # Main app entry point
│   ├── AppState.swift                     # Global app state
│   └── Info.plist                         # App configuration
│
├── Models/
│   ├── DataModels.swift                   # SwiftData models
│   ├── Enums.swift                        # Shared enumerations
│   └── Extensions/                        # Model extensions
│
├── Views/
│   ├── Windows/                           # 2D window views
│   │   ├── DashboardView.swift
│   │   ├── IdeaCaptureView.swift
│   │   ├── IdeasListView.swift
│   │   ├── PrototypesListView.swift
│   │   ├── AnalyticsDashboardView.swift
│   │   └── SettingsView.swift
│   │
│   ├── Volumes/                           # 3D volumetric views
│   │   ├── PrototypeStudioView.swift
│   │   ├── MindMapView.swift
│   │   └── AnalyticsVolumeView.swift
│   │
│   ├── ImmersiveViews/                    # Full immersive views
│   │   ├── InnovationUniverseView.swift
│   │   └── ControlPanelView.swift
│   │
│   └── Components/                        # Reusable components
│       ├── IdeaCard.swift
│       ├── PrototypeCard.swift
│       ├── MetricCard.swift
│       └── CustomButtons.swift
│
├── Services/
│   ├── InnovationService.swift            # Business logic for ideas
│   ├── PrototypeService.swift             # Prototype management
│   ├── AnalyticsService.swift             # Analytics & insights
│   └── CollaborationService.swift         # SharePlay integration
│
├── Utilities/
│   ├── Formatters.swift                   # Date, number formatters
│   ├── Constants.swift                    # App constants
│   └── Helpers.swift                      # Helper functions
│
├── Resources/
│   ├── Assets.xcassets/                   # Images, colors
│   ├── Localizable.strings                # Translations
│   └── PrivacyInfo.xcprivacy              # Privacy manifest
│
└── Tests/
    ├── Unit/                              # Unit tests
    ├── UI/                                # UI tests
    ├── Integration/                       # Integration tests
    ├── Performance/                       # Performance tests
    ├── Accessibility/                     # Accessibility tests
    └── Security/                          # Security tests
```

### Key Files

**InnovationLaboratoryApp.swift**
- App entry point
- Scene configuration
- Dependency injection

**DataModels.swift**
- SwiftData models
- Relationships
- Business logic

**AppState.swift**
- Global state management
- Observable object
- Shared across views

---

## Architecture Overview

### Design Pattern: MVVM

```
┌─────────────────────────────────────────────┐
│                    View                      │
│  (SwiftUI - DashboardView, etc.)            │
└────────────────┬────────────────────────────┘
                 │ Observes
                 │
┌────────────────▼────────────────────────────┐
│               ViewModel                      │
│  (@Observable AppState, Services)           │
└────────────────┬────────────────────────────┘
                 │ Uses
                 │
┌────────────────▼────────────────────────────┐
│                Model                         │
│  (SwiftData Models, Business Logic)         │
└──────────────────────────────────────────────┘
```

**View Layer:**
- SwiftUI views
- No business logic
- Observe ViewModels
- Handle user input

**ViewModel Layer:**
- `@Observable` classes
- Coordinate between View and Model
- Services (InnovationService, etc.)
- Expose data to Views

**Model Layer:**
- SwiftData `@Model` classes
- Data persistence
- Business rules
- Relationships

### Dependency Injection

Using SwiftUI's `@Environment`:

```swift
@main
struct InnovationLaboratoryApp: App {
    @State private var appState = AppState()
    let modelContainer: ModelContainer

    var body: some Scene {
        WindowGroup {
            DashboardView()
                .environment(appState)
                .modelContainer(modelContainer)
        }
    }
}
```

Views access dependencies:

```swift
struct DashboardView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        // Use appState and modelContext
    }
}
```

---

## Data Models

### SwiftData Models

All models use `@Model` macro for persistence:

```swift
import SwiftData

@Model
final class InnovationIdea {
    @Attribute(.unique) var id: UUID
    var title: String
    var ideaDescription: String
    var category: IdeaCategory
    var status: IdeaStatus
    var priority: Priority
    var tags: [String]
    var createdDate: Date
    var modifiedDate: Date

    // Relationships
    var creator: User?
    var prototypes: [Prototype]
    var analytics: IdeaAnalytics?
    var comments: [Comment]
    var attachments: [Attachment]

    init(title: String, description: String, category: IdeaCategory) {
        self.id = UUID()
        self.title = title
        self.ideaDescription = description
        self.category = category
        self.status = .concept
        self.priority = .medium
        self.tags = []
        self.createdDate = Date()
        self.modifiedDate = Date()
        self.prototypes = []
        self.comments = []
        self.attachments = []
    }
}
```

### Model Relationships

**One-to-Many:**
```swift
// InnovationIdea has many Prototypes
var prototypes: [Prototype]  // In InnovationIdea

var idea: InnovationIdea?     // In Prototype
```

**One-to-One:**
```swift
// InnovationIdea has one IdeaAnalytics
var analytics: IdeaAnalytics?  // In InnovationIdea

var idea: InnovationIdea?      // In IdeaAnalytics
```

**Many-to-Many:**
```swift
// Team has many Users, User belongs to many Teams
var members: [User]  // In Team

var teams: [Team]    // In User
```

### Querying Data

Using `@Query` macro in SwiftUI:

```swift
struct IdeasListView: View {
    @Query(
        filter: #Predicate<InnovationIdea> { idea in
            idea.status != .archived
        },
        sort: \.createdDate,
        order: .reverse
    )
    private var activeIdeas: [InnovationIdea]

    var body: some View {
        List(activeIdeas) { idea in
            IdeaCard(idea: idea)
        }
    }
}
```

**Complex Filtering:**

```swift
@Query(
    filter: #Predicate<InnovationIdea> { idea in
        idea.category == .technology &&
        idea.priority == .high &&
        idea.status == .development
    },
    sort: [
        SortDescriptor(\.priority, order: .reverse),
        SortDescriptor(\.createdDate, order: .reverse)
    ]
)
private var highPriorityTechIdeas: [InnovationIdea]
```

### Manual Queries

Using `ModelContext` directly:

```swift
func fetchIdeas(filter: IdeaFilter?) async throws -> [InnovationIdea] {
    let context = modelContext
    var descriptor = FetchDescriptor<InnovationIdea>()

    // Apply filters
    if let filter = filter {
        descriptor.predicate = #Predicate<InnovationIdea> { idea in
            (filter.category == nil || idea.category == filter.category) &&
            (filter.status == nil || idea.status == filter.status)
        }
    }

    // Sort
    descriptor.sortBy = [SortDescriptor(\.createdDate, order: .reverse)]

    // Fetch
    return try context.fetch(descriptor)
}
```

---

## Services Layer

### InnovationService

Business logic for managing ideas:

```swift
@Observable
final class InnovationService: InnovationServiceProtocol {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - CRUD Operations

    func createIdea(_ idea: InnovationIdea) async throws -> InnovationIdea {
        modelContext.insert(idea)

        // Create analytics
        let analytics = IdeaAnalytics()
        analytics.idea = idea
        idea.analytics = analytics
        modelContext.insert(analytics)

        try modelContext.save()

        // Track event
        await AnalyticsService.shared.trackEvent(
            .ideaCreated(ideaID: idea.id)
        )

        return idea
    }

    func updateIdea(_ idea: InnovationIdea) async throws {
        idea.modifiedDate = Date()
        try modelContext.save()

        await AnalyticsService.shared.trackEvent(
            .ideaUpdated(ideaID: idea.id)
        )
    }

    func deleteIdea(_ idea: InnovationIdea) async throws {
        let ideaID = idea.id
        modelContext.delete(idea)
        try modelContext.save()

        await AnalyticsService.shared.trackEvent(
            .ideaDeleted(ideaID: ideaID)
        )
    }

    // MARK: - Query Operations

    func fetchIdeas(filter: IdeaFilter?) async throws -> [InnovationIdea] {
        var descriptor = FetchDescriptor<InnovationIdea>()

        if let filter = filter {
            descriptor.predicate = buildPredicate(from: filter)
        }

        descriptor.sortBy = [SortDescriptor(\.createdDate, order: .reverse)]

        return try modelContext.fetch(descriptor)
    }

    private func buildPredicate(from filter: IdeaFilter) -> Predicate<InnovationIdea> {
        return #Predicate<InnovationIdea> { idea in
            (filter.category == nil || idea.category == filter.category) &&
            (filter.status == nil || idea.status == filter.status) &&
            (filter.priority == nil || idea.priority == filter.priority)
        }
    }
}
```

### PrototypeService

Manages prototypes and simulations:

```swift
@Observable
final class PrototypeService {
    private let modelContext: ModelContext

    func createPrototype(
        for idea: InnovationIdea,
        name: String,
        type: PrototypeType
    ) async throws -> Prototype {
        let prototype = Prototype(
            name: name,
            version: "1.0.0",
            type: type
        )

        prototype.idea = idea
        idea.prototypes.append(prototype)

        modelContext.insert(prototype)
        try modelContext.save()

        return prototype
    }

    func runSimulation(
        on prototype: Prototype
    ) async throws -> SimulationResult {
        // Run physics simulation
        let result = await performSimulation(prototype)

        // Store results
        let testResult = TestResult(
            testType: "Simulation",
            status: result.success ? .passed : .failed,
            metrics: result.metrics
        )

        prototype.testResults.append(testResult)
        try modelContext.save()

        return result
    }

    private func performSimulation(_ prototype: Prototype) async -> SimulationResult {
        // Actual simulation logic
        // Returns metrics like stress, durability, cost
    }
}
```

### AnalyticsService

Provides insights and predictions:

```swift
@Observable
final class AnalyticsService {
    static let shared = AnalyticsService()

    func calculateMetrics(for idea: InnovationIdea) async -> IdeaMetrics {
        let analytics = idea.analytics ?? IdeaAnalytics()

        return IdeaMetrics(
            viewCount: analytics.viewCount,
            collaboratorCount: analytics.collaboratorCount,
            successProbability: predictSuccess(for: idea),
            estimatedTimeToLaunch: estimateTimeToLaunch(for: idea)
        )
    }

    private func predictSuccess(for idea: InnovationIdea) -> Double {
        // ML model predictions based on:
        // - Category historical success rates
        // - Team size
        // - Resource allocation
        // - Market trends

        var probability = 0.5

        // Category factor
        let categorySuccess = historicalSuccessRate(for: idea.category)
        probability *= categorySuccess

        // Priority factor
        if idea.priority == .high || idea.priority == .critical {
            probability *= 1.2
        }

        // Collaboration factor
        let collaborators = idea.analytics?.collaboratorCount ?? 0
        if collaborators > 3 {
            probability *= 1.15
        }

        return min(probability, 1.0)
    }
}
```

### CollaborationService

SharePlay integration:

```swift
import GroupActivities

@Observable
final class CollaborationService: ObservableObject {
    static let shared = CollaborationService()

    private var groupSession: GroupSession<IdeaCollaborationActivity>?
    private var messenger: GroupSessionMessenger?

    func startCollaboration(
        for idea: InnovationIdea
    ) async throws {
        let activity = IdeaCollaborationActivity(ideaID: idea.id)

        switch await activity.prepareForActivation() {
        case .activationPreferred:
            try await activity.activate()
        case .activationDisabled:
            throw CollaborationError.activationDisabled
        case .cancelled:
            throw CollaborationError.cancelled
        @unknown default:
            break
        }
    }

    func configureSession(_ session: GroupSession<IdeaCollaborationActivity>) {
        self.groupSession = session
        self.messenger = GroupSessionMessenger(session: session)

        session.join()

        // Handle messages
        Task {
            for await message in messenger!.messages(of: IdeaUpdate.self) {
                await handleUpdate(message)
            }
        }
    }

    func sendUpdate(_ update: IdeaUpdate) async {
        try? await messenger?.send(update)
    }

    private func handleUpdate(_ update: IdeaUpdate) async {
        // Apply updates from other participants
    }
}
```

---

## Views & UI

### Window Views (2D)

Traditional 2D SwiftUI views:

```swift
struct DashboardView: View {
    @Environment(AppState.self) private var appState
    @Query(sort: \.createdDate, order: .reverse)
    private var ideas: [InnovationIdea]

    var body: some View {
        NavigationSplitView {
            sidebar
        } detail: {
            mainContent
        }
        .navigationTitle("Innovation Dashboard")
    }

    private var sidebar: some View {
        List(selection: $appState.selectedTab) {
            Label("Dashboard", systemImage: "chart.bar")
                .tag(Tab.dashboard)
            Label("Ideas", systemImage: "lightbulb")
                .tag(Tab.ideas)
            Label("Prototypes", systemImage: "cube.transparent")
                .tag(Tab.prototypes)
        }
    }

    private var mainContent: some View {
        switch appState.selectedTab {
        case .dashboard:
            DashboardContent(ideas: ideas)
        case .ideas:
            IdeasListView()
        case .prototypes:
            PrototypesListView()
        }
    }
}
```

### Volume Views (3D Bounded)

3D content in bounded space:

```swift
struct PrototypeStudioView: View {
    let prototype: Prototype
    @State private var modelEntity: ModelEntity?

    var body: some View {
        RealityView { content in
            // Load 3D model
            if let entity = try? await loadModel(for: prototype) {
                content.add(entity)
                modelEntity = entity
            }
        }
        .gesture(
            DragGesture()
                .targetedToAnyEntity()
                .onChanged { value in
                    value.entity.position = value.convert(
                        value.location3D,
                        from: .local,
                        to: .scene
                    )
                }
        )
        .gesture(
            RotateGesture3D()
                .targetedToAnyEntity()
                .onChanged { value in
                    value.entity.orientation = value.rotation
                }
        )
        .ornament(attachmentAnchor: .scene(.bottom)) {
            StudioControls(prototype: prototype)
        }
    }

    private func loadModel(for prototype: Prototype) async throws -> ModelEntity {
        guard let modelData = prototype.modelData,
              let url = saveToTemporaryFile(modelData) else {
            throw PrototypeError.noModelData
        }

        return try await ModelEntity(contentsOf: url)
    }
}
```

### Immersive Views (Full Spatial)

Full immersive 3D environment:

```swift
struct InnovationUniverseView: View {
    @Environment(AppState.self) private var appState
    @Query private var ideas: [InnovationIdea]

    var body: some View {
        RealityView { content in
            await setupInnovationUniverse(content: content)
        }
        .gesture(
            SpatialTapGesture()
                .targetedToAnyEntity()
                .onEnded { value in
                    handleEntityTap(value.entity)
                }
        )
        .overlay(alignment: .bottomTrailing) {
            ControlPanelView()
                .glassBackgroundEffect()
        }
    }

    @MainActor
    private func setupInnovationUniverse(content: RealityViewContent) async {
        // Create central origin
        let origin = Entity()
        origin.position = .zero
        content.add(origin)

        // Create idea nodes
        for (index, idea) in ideas.enumerated() {
            let node = await createIdeaNode(for: idea, index: index)
            origin.addChild(node)
        }

        // Add lighting
        let light = DirectionalLight()
        light.light.intensity = 1000
        content.add(light)
    }

    @MainActor
    private func createIdeaNode(
        for idea: InnovationIdea,
        index: Int
    ) async -> Entity {
        // Create sphere for idea
        let radius: Float = Float(idea.priority.rawValue) * 0.05
        let mesh = MeshResource.generateSphere(radius: radius)

        var material = UnlitMaterial()
        material.color = .init(tint: categoryColor(for: idea.category))

        let entity = ModelEntity(mesh: mesh, materials: [material])

        // Position in spiral
        let angle = Float(index) * 0.618 * 2 * .pi
        let distance: Float = 0.5 + Float(index) * 0.05
        entity.position = SIMD3<Float>(
            cos(angle) * distance,
            Float(index) * 0.1 - 1.0,
            sin(angle) * distance
        )

        // Add component for identification
        entity.components[IdeaNodeComponent.self] = IdeaNodeComponent(ideaID: idea.id)

        return entity
    }
}
```

---

## RealityKit Integration

### Entity Component System

**Components** attach data to entities:

```swift
struct IdeaNodeComponent: Component {
    var ideaID: UUID
}

struct HoverComponent: Component {
    var isHovered: Bool
    var originalScale: SIMD3<Float>
}
```

**Systems** process components:

```swift
struct HoverSystem: System {
    static let query = EntityQuery(where: .has(HoverComponent.self))

    init(scene: Scene) {}

    func update(context: SceneUpdateContext) {
        for entity in context.scene.performQuery(Self.query) {
            guard var hover = entity.components[HoverComponent.self] else { continue }

            if hover.isHovered {
                entity.scale = hover.originalScale * 1.2
            } else {
                entity.scale = hover.originalScale
            }
        }
    }
}
```

### Loading 3D Models

```swift
// Load from URL
let entity = try await ModelEntity(contentsOf: modelURL)

// Load from bundle
let entity = try await ModelEntity(named: "PrototypeModel")

// Generate primitive
let sphere = ModelEntity(
    mesh: .generateSphere(radius: 0.1),
    materials: [SimpleMaterial(color: .blue, isMetallic: false)]
)
```

### Gestures in 3D

```swift
RealityView { content in
    // ...
}
.gesture(
    SpatialTapGesture()
        .targetedToAnyEntity()
        .onEnded { value in
            print("Tapped: \(value.entity)")
        }
)
.gesture(
    DragGesture()
        .targetedToEntity(where: .has(IdeaNodeComponent.self))
        .onChanged { value in
            value.entity.position = value.convert(
                value.location3D,
                from: .local,
                to: .scene
            )
        }
)
.gesture(
    MagnifyGesture()
        .targetedToAnyEntity()
        .onChanged { value in
            value.entity.scale *= Float(value.magnification)
        }
)
.gesture(
    RotateGesture3D()
        .targetedToAnyEntity()
        .onChanged { value in
            value.entity.orientation *= value.rotation
        }
)
```

### Animations

```swift
// Simple animation
entity.move(
    to: Transform(translation: SIMD3(0, 1, 0)),
    relativeTo: nil,
    duration: 1.0
)

// With easing
entity.move(
    to: Transform(translation: SIMD3(0, 1, 0)),
    relativeTo: nil,
    duration: 1.0,
    timingFunction: .easeInOut
)

// SwiftUI animation
withAnimation(.spring(duration: 0.5)) {
    entity.scale = SIMD3(repeating: 1.5)
}
```

---

## Collaboration (SharePlay)

### GroupActivity

Define collaborative activity:

```swift
import GroupActivities

struct IdeaCollaborationActivity: GroupActivity {
    var metadata: GroupActivityMetadata {
        var meta = GroupActivityMetadata()
        meta.title = "Collaborate on Idea"
        meta.type = .generic
        return meta
    }

    let ideaID: UUID
}
```

### Session Management

```swift
class CollaborationManager: ObservableObject {
    @Published var groupSession: GroupSession<IdeaCollaborationActivity>?
    @Published var messenger: GroupSessionMessenger?

    func observeSessions() {
        Task {
            for await session in IdeaCollaborationActivity.sessions() {
                configureSession(session)
            }
        }
    }

    func configureSession(_ session: GroupSession<IdeaCollaborationActivity>) {
        self.groupSession = session
        self.messenger = GroupSessionMessenger(session: session)

        session.join()

        // Listen for messages
        Task {
            for await message in messenger!.messages(of: IdeaUpdate.self) {
                await handleUpdate(message)
            }
        }
    }
}
```

### Message Passing

```swift
struct IdeaUpdate: Codable {
    let ideaID: UUID
    let field: String
    let newValue: String
    let timestamp: Date
}

// Send update
try await messenger.send(IdeaUpdate(
    ideaID: idea.id,
    field: "title",
    newValue: "New Title",
    timestamp: Date()
))

// Receive updates
for await message in messenger.messages(of: IdeaUpdate.self) {
    await applyUpdate(message)
}
```

---

## Testing

### Unit Tests

```swift
import XCTest
@testable import InnovationLaboratory

final class InnovationServiceTests: XCTestCase {
    var service: InnovationService!
    var modelContext: ModelContext!

    override func setUp() async throws {
        let schema = Schema([InnovationIdea.self, ...])
        let config = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: true
        )
        let container = try ModelContainer(
            for: schema,
            configurations: config
        )
        modelContext = ModelContext(container)
        service = InnovationService(modelContext: modelContext)
    }

    func testCreateIdea() async throws {
        let idea = InnovationIdea(
            title: "Test",
            description: "Test",
            category: .technology
        )

        let created = try await service.createIdea(idea)

        XCTAssertNotNil(created.analytics)
        XCTAssertEqual(created.status, .concept)
    }
}
```

### UI Tests

```swift
import XCTest

final class InnovationLaboratoryUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUp() {
        app = XCUIApplication()
        app.launch()
    }

    func testDashboardLaunches() {
        XCTAssertTrue(app.windows["Dashboard"].exists)
        XCTAssertTrue(app.buttons["New Idea"].exists)
    }

    func testIdeaCreation() {
        app.buttons["New Idea"].tap()

        let titleField = app.textFields["Title"]
        titleField.tap()
        titleField.typeText("New Innovation")

        app.buttons["Save"].tap()

        XCTAssertTrue(app.staticTexts["New Innovation"].exists)
    }
}
```

### Running Tests

```bash
# All tests
xcodebuild test -scheme InnovationLaboratory

# Specific test
xcodebuild test \
  -scheme InnovationLaboratory \
  -only-testing:InnovationLaboratoryTests/DataModelsTests/testIdeaCreation

# With coverage
xcodebuild test \
  -scheme InnovationLaboratory \
  -enableCodeCoverage YES
```

---

## Performance Optimization

### Frame Rate Optimization

**Target**: 90 FPS in immersive mode

```swift
// Use LOD (Level of Detail)
func createEntityWithLOD() -> Entity {
    let entity = ModelEntity(...)

    // High detail mesh for close viewing
    let highDetail = MeshResource.generateBox(size: 0.1, cornerRadius: 0.01)

    // Low detail mesh for distant viewing
    let lowDetail = MeshResource.generateBox(size: 0.1)

    // Switch based on distance
    entity.components[LODComponent.self] = LODComponent(
        levels: [
            (distance: 2.0, mesh: highDetail),
            (distance: 5.0, mesh: lowDetail)
        ]
    )

    return entity
}
```

### Memory Management

**Target**: <2GB memory usage

```swift
// Lazy loading
@Query private var ideas: [InnovationIdea]

var limitedIdeas: [InnovationIdea] {
    Array(ideas.prefix(100))  // Show only first 100
}

// Release resources
func cleanupUnusedResources() {
    // Remove entities outside view frustum
    for entity in entities where !isVisible(entity) {
        entity.isEnabled = false
    }
}
```

### Caching

```swift
class ModelCache {
    private var cache: [UUID: ModelEntity] = [:]
    private let maxCacheSize = 50

    func getOrLoad(for prototype: Prototype) async throws -> ModelEntity {
        if let cached = cache[prototype.id] {
            return cached
        }

        let entity = try await loadModel(for: prototype)

        if cache.count >= maxCacheSize {
            // Evict oldest
            let oldest = cache.keys.first!
            cache.removeValue(forKey: oldest)
        }

        cache[prototype.id] = entity
        return entity
    }
}
```

### Profiling

```bash
# Profile with Instruments
xcodebuild \
  -scheme InnovationLaboratory \
  -destination 'platform=visionOS,name=My Vision Pro' \
  -enableAddressSanitizer NO \
  -enableThreadSanitizer NO \
  build

# Open in Instruments
instruments -t "Time Profiler" \
  DerivedData/.../InnovationLaboratory.app
```

---

## Debugging

### Print Debugging

```swift
// Use os_log instead of print()
import os

private let logger = Logger(subsystem: "com.innovationlab", category: "Ideas")

logger.debug("Fetching ideas with filter: \(filter)")
logger.info("Created idea: \(idea.id)")
logger.warning("Low memory: \(memoryUsage)MB")
logger.error("Failed to save: \(error.localizedDescription)")

// Private data
logger.debug("User email: \(email, privacy: .private)")
```

### LLDB Commands

```bash
# Pause execution
(lldb) breakpoint set --name viewDidLoad
(lldb) br s -n viewDidLoad  # Short form

# Print variable
(lldb) po idea
(lldb) p idea.title

# Step through
(lldb) step  # Step into
(lldb) next  # Step over
(lldb) continue  # Resume

# View hierarchy
(lldb) expr -l objc -O -- [[UIWindow keyWindow] recursiveDescription]
```

### Reality Composer Pro

- Visual debugging of RealityKit scenes
- Inspector for entities and components
- Timeline for animations
- Material editor

---

## Building & Distribution

### Build Configurations

**Debug**
- Assertions enabled
- Optimizations disabled
- Debug symbols included

**Release**
- Assertions disabled
- Optimizations enabled
- Debug symbols stripped

### Archive for App Store

```bash
# Clean build folder
xcodebuild clean

# Archive
xcodebuild archive \
  -scheme InnovationLaboratory \
  -destination 'generic/platform=visionOS' \
  -archivePath InnovationLaboratory.xcarchive

# Export IPA
xcodebuild -exportArchive \
  -archivePath InnovationLaboratory.xcarchive \
  -exportPath ./Export \
  -exportOptionsPlist ExportOptions.plist
```

### TestFlight

1. Archive app
2. Upload to App Store Connect
3. Submit for review
4. Add internal/external testers
5. Collect feedback

### App Store Submission

- Complete App Store Connect listing
- Provide screenshots (Vision Pro required)
- Write compelling description
- Set pricing
- Choose availability
- Submit for review

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

**Quick Start:**
1. Fork repository
2. Create feature branch
3. Make changes
4. Write tests
5. Submit pull request

---

## API Documentation

### InnovationService

```swift
protocol InnovationServiceProtocol {
    func createIdea(_ idea: InnovationIdea) async throws -> InnovationIdea
    func updateIdea(_ idea: InnovationIdea) async throws
    func deleteIdea(_ idea: InnovationIdea) async throws
    func fetchIdeas(filter: IdeaFilter?) async throws -> [InnovationIdea]
}
```

### PrototypeService

```swift
protocol PrototypeServiceProtocol {
    func createPrototype(for idea: InnovationIdea, name: String, type: PrototypeType) async throws -> Prototype
    func runSimulation(on prototype: Prototype) async throws -> SimulationResult
    func optimizePrototype(_ prototype: Prototype) async throws -> [OptimizationSuggestion]
    func exportForAR(_ prototype: Prototype) async throws -> URL
}
```

### AnalyticsService

```swift
protocol AnalyticsServiceProtocol {
    func calculateMetrics(for idea: InnovationIdea) async -> IdeaMetrics
    func predictSuccess(for idea: InnovationIdea) async -> Double
    func generateInsights(for ideas: [InnovationIdea]) async -> [Insight]
    func trackEvent(_ event: AnalyticsEvent) async
}
```

---

## Resources

**Apple Documentation:**
- [visionOS Developer](https://developer.apple.com/visionos/)
- [RealityKit](https://developer.apple.com/documentation/realitykit)
- [SwiftUI](https://developer.apple.com/documentation/swiftui)
- [SharePlay](https://developer.apple.com/documentation/groupactivities)

**Sample Code:**
- [Apple Vision Pro Samples](https://developer.apple.com/visionos/samples/)

**Community:**
- [Apple Developer Forums](https://developer.apple.com/forums/)
- [Stack Overflow - visionOS](https://stackoverflow.com/questions/tagged/visionos)

---

**Happy Coding! 🚀**

Transform innovation with spatial computing on Apple Vision Pro.
