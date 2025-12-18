# Retail Space Optimizer - Technical Architecture

## 1. System Architecture Overview

### 1.1 High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    visionOS Application                     │
├─────────────────────────────────────────────────────────────┤
│  Presentation Layer (SwiftUI + RealityKit)                  │
│  ├── Windows (2D UI Controls & Dashboards)                  │
│  ├── Volumes (3D Store Visualizations)                      │
│  └── Immersive Spaces (Full Store Walkthroughs)             │
├─────────────────────────────────────────────────────────────┤
│  Business Logic Layer                                       │
│  ├── View Models (@Observable)                              │
│  ├── Use Cases / Interactors                                │
│  └── Domain Services                                        │
├─────────────────────────────────────────────────────────────┤
│  Data Layer                                                  │
│  ├── Repositories (Protocol-based)                          │
│  ├── Data Sources (Local + Remote)                          │
│  └── SwiftData Models                                       │
├─────────────────────────────────────────────────────────────┤
│  Infrastructure Layer                                       │
│  ├── Network Client (URLSession + async/await)              │
│  ├── Storage Manager (SwiftData)                            │
│  ├── Analytics Engine                                       │
│  └── AI/ML Services                                         │
└─────────────────────────────────────────────────────────────┘
         │              │              │              │
         ▼              ▼              ▼              ▼
┌────────────┐  ┌────────────┐  ┌────────────┐  ┌────────────┐
│    POS     │  │ Inventory  │  │ Analytics  │  │    AI      │
│  Systems   │  │    APIs    │  │  Platform  │  │  Services  │
└────────────┘  └────────────┘  └────────────┘  └────────────┘
```

### 1.2 Architecture Principles

1. **Clean Architecture**: Separation of concerns with clear boundaries
2. **MVVM Pattern**: View Models mediate between Views and Business Logic
3. **Protocol-Oriented Design**: Abstraction via protocols for testability
4. **Reactive State Management**: @Observable and Observation framework
5. **Async/Await Concurrency**: Swift 6.0 strict concurrency model
6. **Entity Component System**: RealityKit ECS for 3D entities

### 1.3 Core Components

#### Presentation Layer
- **Windows**: Control panels, analytics dashboards, toolbars
- **Volumes**: 3D store models, product visualizations
- **Immersive Spaces**: Full-scale store walkthroughs, customer journey simulations

#### Business Logic Layer
- Store design orchestration
- Customer behavior simulation
- Analytics computation
- Optimization algorithms
- Collaboration management

#### Data Layer
- Local persistence (SwiftData)
- Remote API integration
- Caching strategy
- Data synchronization

#### Infrastructure Layer
- Network communication
- File storage (3D models, textures)
- AI/ML model execution
- External system integration

## 2. visionOS-Specific Architecture

### 2.1 Scene Architecture

```swift
@main
struct RetailSpaceOptimizerApp: App {
    @State private var appModel = AppModel()
    @State private var immersionStyle: ImmersionStyle = .mixed

    var body: some Scene {
        // Primary window for controls and dashboards
        WindowGroup("Retail Optimizer", id: "main") {
            ContentView()
                .environment(appModel)
        }
        .windowStyle(.plain)
        .defaultSize(width: 1200, height: 800)

        // 3D store visualization volume
        WindowGroup("Store View", id: "store-volume", for: Store.ID.self) { $storeID in
            StoreVolumeView(storeID: storeID ?? "")
                .environment(appModel)
        }
        .windowStyle(.volumetric)
        .defaultSize(width: 2, height: 1.5, depth: 2, in: .meters)

        // Immersive store walkthrough
        ImmersiveSpace(id: "store-immersive") {
            StoreImmersiveView()
                .environment(appModel)
        }
        .immersionStyle(selection: $immersionStyle, in: .mixed, .progressive, .full)
    }
}
```

### 2.2 Window Management Strategy

**Primary Window (WindowGroup "main")**
- Purpose: Control center, analytics dashboard, tool palettes
- Size: 1200x800 points (scalable)
- Style: Plain window with glass background
- Persistence: Always visible during session

**Store Volume Windows (WindowGroup "store-volume")**
- Purpose: 3D store model visualization
- Size: 2m x 1.5m x 2m volumetric space
- Multiple instances: One per store being edited
- Interactive: Drag-and-drop fixtures, gestures

**Immersive Space (ImmersiveSpace "store-immersive")**
- Purpose: Full-scale store walkthrough
- Modes: Mixed (with passthrough), Progressive, Full
- Use case: Client presentations, final reviews
- Transition: From volume view on demand

### 2.3 Spatial Zones

```
Detail Zone (0.5m - 1m from user)
├── Fixture detail panels
├── Product specifications
├── Measurement tools
└── Configuration controls

Working Zone (1m - 3m from user)
├── Store volume visualization
├── Department layouts
├── Traffic flow overlays
└── Interactive toolbars

Overview Zone (3m - 10m from user)
├── Full store overview
├── Multi-store comparison
├── Performance dashboards
└── Team collaboration avatars
```

### 2.4 Coordinate System

- **Origin**: Center of store floor plan
- **Y-Axis**: Vertical (height), 0 = floor level
- **X-Axis**: Store width
- **Z-Axis**: Store depth
- **Units**: Meters (1:1 scale for immersive, scaled for volumes)

## 3. Data Models & Schemas

### 3.1 Core Domain Models

```swift
// MARK: - Store Models

@Model
final class Store {
    @Attribute(.unique) var id: UUID
    var name: String
    var location: StoreLocation
    var dimensions: StoreDimensions
    var layout: StoreLayout
    var fixtures: [Fixture]
    var products: [Product]
    var analytics: StoreAnalytics?
    var createdAt: Date
    var updatedAt: Date

    init(name: String, location: StoreLocation, dimensions: StoreDimensions) {
        self.id = UUID()
        self.name = name
        self.location = location
        self.dimensions = dimensions
        self.layout = StoreLayout()
        self.fixtures = []
        self.products = []
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

struct StoreLocation: Codable {
    var address: String
    var city: String
    var state: String
    var country: String
    var coordinates: GeographicCoordinate?
}

struct StoreDimensions: Codable {
    var width: Double      // meters
    var depth: Double      // meters
    var height: Double     // meters
    var floorArea: Double  // square meters
}

struct StoreLayout: Codable {
    var zones: [StoreZone]
    var aisles: [Aisle]
    var entrances: [Entrance]
    var checkouts: [Checkout]
    var walls: [Wall]
}

// MARK: - Fixture Models

@Model
final class Fixture {
    @Attribute(.unique) var id: UUID
    var type: FixtureType
    var name: String
    var dimensions: FixtureDimensions
    var position: SIMD3<Double>
    var rotation: SIMD3<Double>
    var capacity: Int
    var products: [ProductPlacement]
    var modelAsset: String  // Reference to 3D model

    init(type: FixtureType, name: String, dimensions: FixtureDimensions) {
        self.id = UUID()
        self.type = type
        self.name = name
        self.dimensions = dimensions
        self.position = SIMD3(0, 0, 0)
        self.rotation = SIMD3(0, 0, 0)
        self.capacity = 0
        self.products = []
        self.modelAsset = ""
    }
}

enum FixtureType: String, Codable {
    case shelf
    case rack
    case display
    case endcap
    case table
    case mannequin
    case gondola
    case refrigerator
    case custom
}

struct FixtureDimensions: Codable {
    var width: Double
    var height: Double
    var depth: Double
}

// MARK: - Product Models

@Model
final class Product {
    @Attribute(.unique) var id: UUID
    var sku: String
    var name: String
    var category: String
    var price: Decimal
    var dimensions: ProductDimensions
    var modelAsset: String?
    var imageAsset: String?
    var salesVelocity: Double  // units per day
    var margin: Decimal

    init(sku: String, name: String, category: String, price: Decimal) {
        self.id = UUID()
        self.sku = sku
        self.name = name
        self.category = category
        self.price = price
        self.dimensions = ProductDimensions(width: 0.1, height: 0.1, depth: 0.1)
        self.salesVelocity = 0
        self.margin = 0
    }
}

struct ProductPlacement: Codable, Identifiable {
    var id: UUID = UUID()
    var productID: UUID
    var position: SIMD3<Double>
    var facingCount: Int
    var stockDepth: Int
}

// MARK: - Analytics Models

@Model
final class StoreAnalytics {
    @Attribute(.unique) var id: UUID
    var storeID: UUID
    var dateRange: DateInterval
    var trafficData: TrafficData
    var salesData: SalesData
    var heatmaps: [Heatmap]
    var customerJourneys: [CustomerJourney]

    init(storeID: UUID, dateRange: DateInterval) {
        self.id = UUID()
        self.storeID = storeID
        self.dateRange = dateRange
        self.trafficData = TrafficData()
        self.salesData = SalesData()
        self.heatmaps = []
        self.customerJourneys = []
    }
}

struct TrafficData: Codable {
    var totalVisitors: Int
    var averageDwellTime: TimeInterval  // seconds
    var peakHours: [Int]  // hours of day
    var conversionRate: Double  // percentage
    var bounceRate: Double  // percentage
}

struct SalesData: Codable {
    var totalRevenue: Decimal
    var salesPerSquareFoot: Decimal
    var averageBasketSize: Decimal
    var topProducts: [ProductPerformance]
    var categoryPerformance: [CategoryPerformance]
}

struct Heatmap: Codable, Identifiable {
    var id: UUID = UUID()
    var type: HeatmapType
    var gridResolution: Int  // cells per meter
    var data: [[Double]]  // 2D grid of values (0.0 to 1.0)
    var timestamp: Date
}

enum HeatmapType: String, Codable {
    case traffic
    case dwell
    case conversion
    case sales
}

// MARK: - Customer Journey Models

struct CustomerJourney: Codable, Identifiable {
    var id: UUID = UUID()
    var customerID: String
    var timestamp: Date
    var path: [PathPoint]
    var interactions: [Interaction]
    var purchasesMade: [PurchaseEvent]
    var dwellPoints: [DwellPoint]
}

struct PathPoint: Codable {
    var position: SIMD3<Double>
    var timestamp: TimeInterval  // offset from journey start
}

struct Interaction: Codable {
    var type: InteractionType
    var productID: UUID?
    var fixtureID: UUID?
    var position: SIMD3<Double>
    var timestamp: TimeInterval
    var duration: TimeInterval
}

enum InteractionType: String, Codable {
    case browse
    case pickup
    case examine
    case compare
    case putBack
    case addToCart
}

// MARK: - AI/ML Models

@Model
final class OptimizationSuggestion {
    @Attribute(.unique) var id: UUID
    var storeID: UUID
    var type: OptimizationType
    var title: String
    var description: String
    var predictedImpact: ImpactMetrics
    var changes: [LayoutChange]
    var confidence: Double  // 0.0 to 1.0
    var generatedAt: Date
    var status: SuggestionStatus

    init(storeID: UUID, type: OptimizationType, title: String) {
        self.id = UUID()
        self.storeID = storeID
        self.type = type
        self.title = title
        self.description = ""
        self.predictedImpact = ImpactMetrics()
        self.changes = []
        self.confidence = 0
        self.generatedAt = Date()
        self.status = .pending
    }
}

enum OptimizationType: String, Codable {
    case layout
    case merchandising
    case traffic
    case checkout
    case seasonal
}

struct ImpactMetrics: Codable {
    var salesIncrease: Double  // percentage
    var conversionIncrease: Double
    var dwellTimeChange: Double
    var revenueImpact: Decimal
}

struct LayoutChange: Codable, Identifiable {
    var id: UUID = UUID()
    var changeType: ChangeType
    var fixtureID: UUID?
    var fromPosition: SIMD3<Double>?
    var toPosition: SIMD3<Double>?
    var description: String
}

enum ChangeType: String, Codable {
    case move
    case add
    case remove
    case replace
    case rotate
}
```

### 3.2 Database Schema (SwiftData)

```
Store (Primary)
├── id: UUID (PK)
├── name: String
├── location: StoreLocation
├── dimensions: StoreDimensions
├── layout: StoreLayout
├── fixtures: [Fixture] (Relationship)
├── products: [Product] (Relationship)
└── analytics: StoreAnalytics? (Relationship)

Fixture
├── id: UUID (PK)
├── storeID: UUID (FK)
├── type: FixtureType
├── position: SIMD3<Double>
└── products: [ProductPlacement]

Product
├── id: UUID (PK)
├── sku: String (Unique)
├── category: String
├── salesVelocity: Double
└── modelAsset: String?

StoreAnalytics
├── id: UUID (PK)
├── storeID: UUID (FK)
├── trafficData: TrafficData
├── salesData: SalesData
└── heatmaps: [Heatmap]

OptimizationSuggestion
├── id: UUID (PK)
├── storeID: UUID (FK)
├── type: OptimizationType
├── predictedImpact: ImpactMetrics
└── changes: [LayoutChange]
```

## 4. Service Layer Architecture

### 4.1 Service Organization

```swift
// MARK: - Service Protocols

protocol StoreService {
    func fetchStores() async throws -> [Store]
    func createStore(_ store: Store) async throws
    func updateStore(_ store: Store) async throws
    func deleteStore(id: UUID) async throws
    func getStore(id: UUID) async throws -> Store
}

protocol AnalyticsService {
    func fetchAnalytics(storeID: UUID, dateRange: DateInterval) async throws -> StoreAnalytics
    func generateHeatmap(storeID: UUID, type: HeatmapType) async throws -> Heatmap
    func analyzeCustomerJourneys(storeID: UUID) async throws -> [CustomerJourney]
    func calculatePerformanceMetrics(storeID: UUID) async throws -> PerformanceMetrics
}

protocol OptimizationService {
    func generateSuggestions(storeID: UUID) async throws -> [OptimizationSuggestion]
    func applySuggestion(suggestionID: UUID) async throws
    func simulateLayoutChange(_ changes: [LayoutChange]) async throws -> ImpactMetrics
    func predictSalesImpact(storeID: UUID, scenario: LayoutScenario) async throws -> Decimal
}

protocol SimulationService {
    func runCustomerSimulation(storeID: UUID, parameters: SimulationParameters) async throws -> SimulationResult
    func generateTrafficFlow(storeID: UUID) async throws -> TrafficFlowData
    func analyzeDwellPatterns(storeID: UUID) async throws -> [DwellPattern]
}

protocol IntegrationService {
    func syncPOSData() async throws
    func syncInventoryData() async throws
    func exportPlanogram(storeID: UUID) async throws -> PlanogramData
    func importStoreLayout(file: URL) async throws -> Store
}

protocol CollaborationService {
    func createSession(storeID: UUID) async throws -> CollaborationSession
    func joinSession(sessionID: UUID) async throws
    func leaveSession(sessionID: UUID) async throws
    func syncChanges(_ changes: [StoreChange]) async throws
}
```

### 4.2 Service Implementation Pattern

```swift
actor StoreServiceImpl: StoreService {
    private let repository: StoreRepository
    private let networkClient: NetworkClient
    private let cache: CacheManager

    init(repository: StoreRepository, networkClient: NetworkClient, cache: CacheManager) {
        self.repository = repository
        self.networkClient = networkClient
        self.cache = cache
    }

    func fetchStores() async throws -> [Store] {
        // Check cache first
        if let cached = await cache.get(key: "all_stores") as? [Store] {
            return cached
        }

        // Fetch from network
        let stores = try await networkClient.request(.getStores)

        // Cache result
        await cache.set(key: "all_stores", value: stores, ttl: 300)

        // Persist locally
        try await repository.saveAll(stores)

        return stores
    }

    // ... other methods
}
```

## 5. RealityKit & ARKit Integration

### 5.1 RealityKit Entity Component System

```swift
// MARK: - Custom Components

struct FixtureComponent: Component {
    var fixtureID: UUID
    var fixtureType: FixtureType
    var isInteractive: Bool
    var productSlots: [ProductSlot]
}

struct ProductComponent: Component {
    var productID: UUID
    var sku: String
    var price: Decimal
    var salesData: ProductSalesData
}

struct HeatmapComponent: Component {
    var heatmapType: HeatmapType
    var intensity: Float  // 0.0 to 1.0
    var gridPosition: SIMD2<Int>
}

struct InteractionComponent: Component {
    var isHovered: Bool
    var isSelected: Bool
    var isDraggable: Bool
    var gestureHandlers: GestureHandlers
}

// MARK: - Custom Systems

class LayoutUpdateSystem: System {
    static let query = EntityQuery(where: .has(FixtureComponent.self))

    required init(scene: RealityKit.Scene) {}

    func update(context: SceneUpdateContext) {
        context.entities(matching: Self.query, updatingSystemWhen: .rendering).forEach { entity in
            // Update fixture positions based on layout changes
            if let fixture = entity.components[FixtureComponent.self] {
                updateFixturePosition(entity, fixture: fixture)
            }
        }
    }

    private func updateFixturePosition(_ entity: Entity, fixture: FixtureComponent) {
        // Implementation
    }
}

class HeatmapVisualizationSystem: System {
    static let query = EntityQuery(where: .has(HeatmapComponent.self))

    required init(scene: RealityKit.Scene) {}

    func update(context: SceneUpdateContext) {
        context.entities(matching: Self.query, updatingSystemWhen: .rendering).forEach { entity in
            if let heatmap = entity.components[HeatmapComponent.self] {
                updateHeatmapVisualization(entity, heatmap: heatmap)
            }
        }
    }

    private func updateHeatmapVisualization(_ entity: Entity, heatmap: HeatmapComponent) {
        // Update visual representation based on intensity
    }
}
```

### 5.2 3D Content Pipeline

```
3D Asset Pipeline:
─────────────────
Reality Composer Pro → .usdz files → Asset Bundle
         │
         ├── Store Fixtures (shelves, racks, displays)
         ├── Products (3D models with LODs)
         ├── Store Architecture (walls, floors, ceilings)
         ├── UI Elements (spatial buttons, panels)
         └── Effects (particles, shaders)

Optimization Strategy:
├── Level of Detail (LOD): 3 levels per model
├── Texture Compression: ASTC format
├── Polygon Budget: <5K tris per fixture, <1K per product
├── Instancing: Reuse models for identical fixtures
└── Occlusion Culling: Hide non-visible entities
```

### 5.3 ARKit Integration

```swift
// Hand tracking for precise fixture placement
class HandTrackingManager: ObservableObject {
    @Published var handAnchor: HandAnchor?
    @Published var pinchGesture: PinchGestureState = .inactive

    func enableHandTracking() async {
        let session = ARKitSession()
        let handTracking = HandTrackingProvider()

        do {
            try await session.run([handTracking])

            for await update in handTracking.anchorUpdates {
                handleHandUpdate(update)
            }
        } catch {
            // Handle error
        }
    }

    private func handleHandUpdate(_ update: HandAnchorUpdate) {
        switch update.event {
        case .updated:
            handAnchor = update.anchor
            detectPinchGesture(update.anchor)
        default:
            break
        }
    }
}
```

## 6. API Design & External Integrations

### 6.1 REST API Architecture

```
API Base URL: https://api.retailspaceoptimizer.com/v1

Authentication:
├── OAuth 2.0 with JWT tokens
├── API keys for service-to-service
└── Refresh token rotation

Endpoints:
├── /stores
│   ├── GET    /stores                    (List all stores)
│   ├── POST   /stores                    (Create store)
│   ├── GET    /stores/{id}               (Get store)
│   ├── PUT    /stores/{id}               (Update store)
│   └── DELETE /stores/{id}               (Delete store)
│
├── /analytics
│   ├── GET /stores/{id}/analytics        (Get analytics)
│   ├── GET /stores/{id}/heatmap/{type}   (Get heatmap)
│   └── GET /stores/{id}/journeys         (Get customer journeys)
│
├── /optimization
│   ├── POST /stores/{id}/suggestions      (Generate suggestions)
│   ├── POST /stores/{id}/simulate         (Run simulation)
│   └── GET  /stores/{id}/predictions      (Get predictions)
│
├── /integration
│   ├── POST /sync/pos                     (Sync POS data)
│   ├── POST /sync/inventory               (Sync inventory)
│   └── GET  /export/planogram/{id}        (Export planogram)
│
└── /collaboration
    ├── POST /sessions                      (Create session)
    ├── GET  /sessions/{id}                 (Get session)
    ├── POST /sessions/{id}/join            (Join session)
    └── WS   /sessions/{id}/sync            (WebSocket sync)
```

### 6.2 External System Integrations

```swift
// POS Integration
protocol POSIntegration {
    func fetchSalesData(dateRange: DateInterval) async throws -> [SalesTransaction]
    func fetchProductPerformance() async throws -> [ProductPerformance]
    func syncInventoryLevels() async throws -> [InventoryLevel]
}

// Inventory Management Integration
protocol InventoryIntegration {
    func getStockLevels(storeID: UUID) async throws -> [StockLevel]
    func updateProductPlacement(placements: [ProductPlacement]) async throws
    func getReplenishmentSchedule() async throws -> [ReplenishmentEvent]
}

// Analytics Platform Integration
protocol AnalyticsPlatformIntegration {
    func getTrafficData(storeID: UUID, dateRange: DateInterval) async throws -> TrafficData
    func getCustomerBehavior() async throws -> [BehaviorPattern]
    func exportMetrics(metrics: [Metric]) async throws
}

// Planogram Software Integration
protocol PlanogramIntegration {
    func importPlanogram(file: URL) async throws -> Planogram
    func exportPlanogram(layout: StoreLayout) async throws -> PlanogramFile
    func validateCompliance(layout: StoreLayout) async throws -> ComplianceReport
}
```

## 7. State Management Strategy

### 7.1 Observable Architecture

```swift
@Observable
class AppModel {
    // Global app state
    var selectedStore: Store?
    var activeStores: [Store] = []
    var currentUser: User?
    var preferences: UserPreferences

    // Services
    let storeService: StoreService
    let analyticsService: AnalyticsService
    let optimizationService: OptimizationService

    // Collaboration state
    var activeSession: CollaborationSession?
    var connectedUsers: [User] = []

    init(services: ServiceContainer) {
        self.storeService = services.storeService
        self.analyticsService = services.analyticsService
        self.optimizationService = services.optimizationService
        self.preferences = UserPreferences()
    }
}

@Observable
class StoreViewModel {
    // Store-specific state
    var store: Store
    var fixtures: [Fixture] = []
    var selectedFixture: Fixture?
    var isEditMode: Bool = false

    // Analytics state
    var currentHeatmap: Heatmap?
    var trafficData: TrafficData?
    var suggestions: [OptimizationSuggestion] = []

    // View state
    var viewMode: ViewMode = .layout
    var showAnalytics: Bool = false
    var showSuggestions: Bool = false

    // Services
    private let storeService: StoreService
    private let analyticsService: AnalyticsService

    init(store: Store, services: ServiceContainer) {
        self.store = store
        self.storeService = services.storeService
        self.analyticsService = services.analyticsService
    }

    func loadAnalytics() async {
        do {
            let dateRange = DateInterval(start: .now.addingTimeInterval(-30*86400), end: .now)
            trafficData = try await analyticsService.fetchAnalytics(
                storeID: store.id,
                dateRange: dateRange
            ).trafficData
        } catch {
            // Handle error
        }
    }
}
```

### 7.2 State Flow

```
User Action
    ↓
View (SwiftUI)
    ↓
ViewModel Method
    ↓
Service Layer
    ↓
Repository/Network
    ↓
Data Update
    ↓
@Observable triggers view update
    ↓
View Re-renders
```

## 8. Performance Optimization Strategy

### 8.1 Rendering Optimization

```swift
// Level of Detail (LOD) Management
class LODManager {
    func selectLOD(entity: Entity, distance: Float) -> LODLevel {
        switch distance {
        case 0..<2:    return .high      // Full detail
        case 2..<5:    return .medium    // Reduced polygons
        case 5..<10:   return .low       // Simplified
        default:       return .minimal   // Billboard/impostor
        }
    }

    func updateLODs(for entities: [Entity], viewerPosition: SIMD3<Float>) {
        for entity in entities {
            let distance = simd_distance(entity.position, viewerPosition)
            let lod = selectLOD(entity: entity, distance: distance)
            applyLOD(entity, level: lod)
        }
    }
}

// Occlusion Culling
class OcclusionManager {
    func cullNonVisibleEntities(camera: PerspectiveCamera, entities: [Entity]) {
        for entity in entities {
            entity.isEnabled = isVisibleToCamera(entity, camera: camera)
        }
    }
}

// Instancing for Repeated Objects
class InstanceManager {
    private var instancedModels: [String: ModelEntity] = [:]

    func createInstance(modelName: String, at position: SIMD3<Float>) -> Entity {
        if let prototype = instancedModels[modelName] {
            let instance = prototype.clone(recursive: true)
            instance.position = position
            return instance
        } else {
            let model = loadModel(modelName)
            instancedModels[modelName] = model
            return createInstance(modelName: modelName, at: position)
        }
    }
}
```

### 8.2 Memory Management

```swift
class AssetManager {
    private var cache: NSCache<NSString, ModelEntity>
    private let maxCacheSize: Int = 500_000_000  // 500MB

    init() {
        cache = NSCache()
        cache.totalCostLimit = maxCacheSize
    }

    func loadModel(named name: String) async -> ModelEntity? {
        // Check cache
        if let cached = cache.object(forKey: name as NSString) {
            return cached
        }

        // Load from bundle
        guard let model = try? await ModelEntity.load(named: name) else {
            return nil
        }

        // Estimate memory cost
        let cost = estimateMemoryCost(model)
        cache.setObject(model, forKey: name as NSString, cost: cost)

        return model
    }

    func preloadAssets(_ assetNames: [String]) async {
        await withTaskGroup(of: Void.self) { group in
            for name in assetNames {
                group.addTask {
                    _ = await self.loadModel(named: name)
                }
            }
        }
    }
}
```

### 8.3 Network Optimization

```swift
class NetworkOptimizer {
    // Request batching
    func batchRequests<T>(_ requests: [APIRequest]) async throws -> [T] {
        let batchedRequest = APIRequest.batch(requests)
        return try await networkClient.execute(batchedRequest)
    }

    // Response caching
    private var cache = URLCache(
        memoryCapacity: 50_000_000,   // 50MB
        diskCapacity: 500_000_000      // 500MB
    )

    // Compression
    func compressPayload(_ data: Data) -> Data {
        return (data as NSData).compressed(using: .lzma) as Data
    }
}
```

### 8.4 Performance Targets

```
Frame Rate: 90 FPS (11ms per frame)
├── Rendering: <8ms
├── Physics: <1ms
├── Game Logic: <1ms
└── System Overhead: <1ms

Memory Usage:
├── Working Set: <500MB
├── Texture Memory: <300MB
├── Geometry: <100MB
└── Other: <100MB

Network:
├── API Response Time: <200ms (p95)
├── Asset Download: Progressive streaming
└── Sync Latency: <100ms (collaboration)

Battery Impact: Low (< 5% over 8 hours of moderate use)
```

## 9. Security Architecture

### 9.1 Authentication & Authorization

```swift
class SecurityManager {
    // JWT Token Management
    func authenticate(credentials: Credentials) async throws -> AuthToken {
        let response = try await authAPI.login(credentials)
        let token = AuthToken(
            accessToken: response.accessToken,
            refreshToken: response.refreshToken,
            expiresAt: Date().addingTimeInterval(response.expiresIn)
        )
        try await keychain.save(token)
        return token
    }

    // Role-based access control
    func checkPermission(_ permission: Permission, for user: User) -> Bool {
        return user.role.permissions.contains(permission)
    }

    // Secure storage
    private let keychain = KeychainManager()
}

enum Permission {
    case viewStore
    case editStore
    case deleteStore
    case viewAnalytics
    case generateSuggestions
    case manageUsers
    case exportData
}

struct Role {
    let name: String
    let permissions: Set<Permission>

    static let viewer = Role(name: "Viewer", permissions: [.viewStore, .viewAnalytics])
    static let designer = Role(name: "Designer", permissions: [.viewStore, .editStore, .viewAnalytics])
    static let admin = Role(name: "Admin", permissions: Set(Permission.allCases))
}
```

### 9.2 Data Encryption

```swift
class EncryptionManager {
    // Data at rest
    func encryptLocal(data: Data, key: SymmetricKey) throws -> Data {
        let sealedBox = try AES.GCM.seal(data, using: key)
        return sealedBox.combined!
    }

    func decryptLocal(data: Data, key: SymmetricKey) throws -> Data {
        let sealedBox = try AES.GCM.SealedBox(combined: data)
        return try AES.GCM.open(sealedBox, using: key)
    }

    // Data in transit (handled by URLSession with TLS 1.3)
}
```

### 9.3 Privacy Protection

```swift
class PrivacyManager {
    // Anonymize customer journey data
    func anonymizeJourneys(_ journeys: [CustomerJourney]) -> [CustomerJourney] {
        return journeys.map { journey in
            var anonymized = journey
            anonymized.customerID = hashCustomerID(journey.customerID)
            return anonymized
        }
    }

    // Data minimization
    func filterSensitiveData(_ analytics: StoreAnalytics) -> StoreAnalytics {
        var filtered = analytics
        // Remove personally identifiable information
        return filtered
    }
}
```

### 9.4 Security Best Practices

1. **Transport Security**: TLS 1.3 for all network communications
2. **Certificate Pinning**: Prevent MITM attacks
3. **Secure Storage**: Keychain for credentials, encrypted SwiftData
4. **Input Validation**: Sanitize all user inputs
5. **API Rate Limiting**: Prevent abuse
6. **Audit Logging**: Track sensitive operations
7. **Regular Security Audits**: Quarterly penetration testing

## 10. Scalability Considerations

### 10.1 Horizontal Scaling

```
Load Balancer
    │
    ├── API Server Instance 1
    ├── API Server Instance 2
    └── API Server Instance N
         │
         └── Shared Services
              ├── Database Cluster (Read Replicas)
              ├── Cache Cluster (Redis)
              ├── Object Storage (S3-compatible)
              └── Message Queue (for async tasks)
```

### 10.2 Data Partitioning

```
Sharding Strategy:
├── Partition by Store ID (geographic sharding)
├── Separate analytics data (time-series DB)
├── CDN for 3D assets (edge caching)
└── Multi-region deployment for global access
```

### 10.3 Caching Strategy

```
Multi-layer Caching:
├── Client-side: URLCache + in-memory cache (5-15 min TTL)
├── CDN: Static assets, 3D models (24h TTL)
├── Application: Redis cache for hot data (1h TTL)
└── Database: Query result caching
```

---

## Appendix: Technology Stack Summary

### Core Technologies
- **Language**: Swift 6.0+ (strict concurrency)
- **UI Framework**: SwiftUI 5+
- **3D Engine**: RealityKit 2+
- **Spatial Framework**: ARKit 6+
- **Platform**: visionOS 2.0+

### Data & Persistence
- **Local Storage**: SwiftData
- **Network**: URLSession with async/await
- **Serialization**: Codable, JSON

### AI/ML
- **Framework**: Core ML, Create ML
- **Vision**: Vision framework for image analysis
- **Natural Language**: Natural Language framework

### Build Tools
- **IDE**: Xcode 16+
- **3D Authoring**: Reality Composer Pro
- **Dependency Management**: Swift Package Manager

### Testing
- **Unit Tests**: XCTest
- **UI Tests**: XCUITest
- **Performance Tests**: XCTMetrics

### DevOps
- **CI/CD**: Xcode Cloud / GitHub Actions
- **Analytics**: App Store Connect Analytics
- **Crash Reporting**: MetricKit

---

*This architecture document provides the technical foundation for building a scalable, performant, and maintainable Retail Space Optimizer application on visionOS.*
