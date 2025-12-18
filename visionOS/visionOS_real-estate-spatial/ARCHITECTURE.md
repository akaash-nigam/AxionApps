# Real Estate Spatial Platform - Technical Architecture

## Document Version
- **Version**: 1.0
- **Last Updated**: 2025-11-17
- **Platform**: visionOS 2.0+
- **Status**: Design Phase

## 1. System Architecture Overview

### 1.1 High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    visionOS Application Layer                    │
├──────────────┬──────────────┬──────────────┬────────────────────┤
│   Windows    │   Volumes    │ Immersive    │   Ornaments       │
│   (2D UI)    │ (3D Bounded) │   Spaces     │   (Controls)      │
└──────────────┴──────────────┴──────────────┴────────────────────┘
                              ▲
                              │
┌─────────────────────────────┼─────────────────────────────────────┐
│                    Presentation Layer                             │
│  ┌──────────────┐  ┌──────────────┐  ┌────────────────────────┐ │
│  │   SwiftUI    │  │  RealityKit  │  │   ARKit Tracking      │ │
│  │   Views      │  │   Entities   │  │   (Spatial Anchors)   │ │
│  └──────────────┘  └──────────────┘  └────────────────────────┘ │
└───────────────────────────────────────────────────────────────────┘
                              ▲
                              │
┌─────────────────────────────┼─────────────────────────────────────┐
│                    Business Logic Layer                           │
│  ┌──────────────┐  ┌──────────────┐  ┌────────────────────────┐ │
│  │  ViewModels  │  │   Services   │  │   AI/ML Services      │ │
│  │  (@Observable)│  │  (Business)  │  │   (Staging, Match)    │ │
│  └──────────────┘  └──────────────┘  └────────────────────────┘ │
└───────────────────────────────────────────────────────────────────┘
                              ▲
                              │
┌─────────────────────────────┼─────────────────────────────────────┐
│                       Data Layer                                  │
│  ┌──────────────┐  ┌──────────────┐  ┌────────────────────────┐ │
│  │  SwiftData   │  │   Network    │  │   Cache Manager       │ │
│  │  (Local DB)  │  │   Client     │  │   (Property Data)     │ │
│  └──────────────┘  └──────────────┘  └────────────────────────┘ │
└───────────────────────────────────────────────────────────────────┘
                              ▲
                              │
┌─────────────────────────────┼─────────────────────────────────────┐
│                    External Services                              │
│  ┌──────────────┐  ┌──────────────┐  ┌────────────────────────┐ │
│  │   MLS API    │  │  AI Services │  │   CDN (Properties)    │ │
│  │   (Listings) │  │  (OpenAI)    │  │   (3D Assets)         │ │
│  └──────────────┘  └──────────────┘  └────────────────────────┘ │
└───────────────────────────────────────────────────────────────────┘
```

### 1.2 Core Architectural Principles

1. **Spatial-First Design**: All features leverage visionOS spatial capabilities
2. **Progressive Enhancement**: Start with windows, expand to volumes/immersive
3. **Offline-First**: Critical property data cached locally
4. **Performance-Optimized**: Maintain 90fps for smooth spatial experience
5. **Security-By-Design**: End-to-end encryption for transactions
6. **Modular Architecture**: Clean separation of concerns (MVVM)

## 2. visionOS-Specific Architecture

### 2.1 Presentation Modes Strategy

#### Window Group (Primary Interface)
```swift
// Main browsing and management interface
WindowGroup("Property Browser") {
    PropertyBrowserView()
}
.defaultSize(width: 1200, height: 800)

WindowGroup("Agent Dashboard") {
    AgentDashboardView()
}
```

**Use Cases**:
- Property search and filtering
- Agent dashboard and analytics
- Property details and information
- Mortgage calculators
- Neighborhood data

#### Volumes (3D Bounded Content)
```swift
// 3D property models and floor plans
WindowGroup(id: "property-model-3d") {
    PropertyModel3DView()
}
.windowStyle(.volumetric)
.defaultSize(width: 1.0, height: 1.0, depth: 1.0, in: .meters)
```

**Use Cases**:
- 3D floor plan visualization
- Architectural models
- Neighborhood context (buildings, amenities)
- Virtual staging previews

#### Immersive Spaces (Full Immersion)
```swift
// Photorealistic property walkthrough
ImmersiveSpace(id: "property-tour") {
    PropertyTourImmersiveView()
}
.immersionStyle(selection: $immersionLevel, in: .mixed, .progressive, .full)
```

**Use Cases**:
- Full property walkthroughs
- Virtual open houses (multi-user)
- Renovation visualization
- Immersive staging

### 2.2 Spatial Hierarchy

```
Application Spatial Organization
├── Home Space (Passthrough)
│   ├── Property Browser Window (Floating)
│   ├── Search Filters Window (Side)
│   └── Favorites Volume (3D Gallery)
│
├── Property Detail Space (Mixed)
│   ├── Detail Window (Info Panel)
│   ├── 3D Model Volume (Rotatable)
│   └── Measurement Tools (Spatial)
│
└── Property Tour Space (Full Immersive)
    ├── Photorealistic Environment
    ├── Spatial Audio Narration
    ├── Interactive Hotspots
    └── Measurement Overlays
```

### 2.3 Scene Architecture

```swift
// App-level scene configuration
@main
struct RealEstateSpatialApp: App {
    @State private var appModel = AppModel()
    @State private var immersionLevel: ImmersionStyle = .mixed

    var body: some Scene {
        // Main browsing interface
        WindowGroup("Browse", id: "main") {
            ContentView()
                .environment(appModel)
        }

        // Property detail view
        WindowGroup(id: "property-detail", for: Property.ID.self) { $propertyID in
            PropertyDetailView(propertyID: propertyID)
                .environment(appModel)
        }

        // 3D property model
        WindowGroup(id: "property-3d", for: Property.ID.self) { $propertyID in
            Property3DModelView(propertyID: propertyID)
        }
        .windowStyle(.volumetric)
        .defaultSize(width: 1.5, height: 1.5, depth: 1.5, in: .meters)

        // Immersive tour experience
        ImmersiveSpace(id: "tour", for: Property.ID.self) { $propertyID in
            PropertyTourView(propertyID: propertyID)
                .environment(appModel)
        }
        .immersionStyle(selection: $immersionLevel, in: .mixed, .progressive, .full)
    }
}
```

## 3. Data Models and Schemas

### 3.1 Core Data Models

```swift
// Property Entity (SwiftData)
@Model
final class Property {
    @Attribute(.unique) var id: UUID
    var mlsNumber: String
    var address: PropertyAddress
    var pricing: PricingInfo
    var specifications: PropertySpecs
    var media: PropertyMedia
    var spatial: SpatialData
    var metadata: PropertyMetadata
    var analytics: PropertyAnalytics?

    // Relationships
    @Relationship(deleteRule: .cascade) var rooms: [Room]
    @Relationship(deleteRule: .nullify) var viewingHistory: [ViewingSession]
    @Relationship(deleteRule: .nullify) var savedBy: [User]

    init(id: UUID = UUID(), mlsNumber: String, address: PropertyAddress) {
        self.id = id
        self.mlsNumber = mlsNumber
        self.address = address
        // ... initialize other properties
    }
}

struct PropertyAddress: Codable {
    var street: String
    var city: String
    var state: String
    var zipCode: String
    var country: String
    var coordinates: GeographicCoordinate
}

struct PricingInfo: Codable {
    var listPrice: Decimal
    var priceHistory: [PriceChange]
    var estimatedValue: Decimal?
    var pricePerSqFt: Decimal
    var taxAssessment: Decimal
    var monthlyHOA: Decimal?
}

struct PropertySpecs: Codable {
    var bedrooms: Int
    var bathrooms: Double
    var squareFeet: Int
    var lotSize: Int?
    var yearBuilt: Int
    var propertyType: PropertyType
    var features: [String]
    var appliances: [String]
}

struct PropertyMedia: Codable {
    var photos: [MediaAsset]
    var virtualTour: VirtualTourAsset?
    var floorPlans: [MediaAsset]
    var videos: [MediaAsset]
    var documents: [DocumentAsset]
}

struct SpatialData: Codable {
    var spatialCaptureID: String
    var captureDate: Date
    var captureQuality: CaptureQuality
    var roomMeshes: [String] // References to 3D mesh files
    var spatialAnchors: [SpatialAnchor]
    var pointCloudURL: URL?
    var textureAtlasURLs: [URL]
}

// Room Entity
@Model
final class Room {
    @Attribute(.unique) var id: UUID
    var name: String
    var type: RoomType
    var dimensions: RoomDimensions
    var features: [String]
    var meshAssetURL: URL?
    var textureURL: URL?

    @Relationship(inverse: \Property.rooms) var property: Property?
}

struct RoomDimensions: Codable {
    var length: Double // meters
    var width: Double
    var height: Double
    var squareFeet: Double
}

// User Entity
@Model
final class User {
    @Attribute(.unique) var id: UUID
    var email: String
    var profile: UserProfile
    var preferences: UserPreferences
    var role: UserRole

    @Relationship(deleteRule: .cascade) var savedProperties: [Property]
    @Relationship(deleteRule: .cascade) var viewingHistory: [ViewingSession]
    @Relationship(deleteRule: .cascade) var searchHistory: [SearchQuery]
}

struct UserProfile: Codable {
    var firstName: String
    var lastName: String
    var phone: String?
    var agentLicense: String?
    var brokerage: String?
}

struct UserPreferences: Codable {
    var searchCriteria: SearchCriteria
    var notificationSettings: NotificationSettings
    var measurementSystem: MeasurementSystem
    var preferredCurrency: String
}

// Viewing Session (Analytics)
@Model
final class ViewingSession {
    @Attribute(.unique) var id: UUID
    var propertyID: UUID
    var userID: UUID
    var startTime: Date
    var duration: TimeInterval
    var interactions: [InteractionEvent]
    var roomsVisited: [String]
    var engagementScore: Double
    var completionPercentage: Double

    @Relationship(inverse: \Property.viewingHistory) var property: Property?
    @Relationship(inverse: \User.viewingHistory) var user: User?
}

struct InteractionEvent: Codable {
    var timestamp: Date
    var type: InteractionType
    var target: String
    var duration: TimeInterval?
    var metadata: [String: String]?
}

// Virtual Staging
@Model
final class StagingConfiguration {
    @Attribute(.unique) var id: UUID
    var propertyID: UUID
    var style: StagingStyle
    var rooms: [RoomStaging]
    var aiGenerated: Bool
    var createdDate: Date
    var thumbnailURL: URL?
}

struct RoomStaging: Codable {
    var roomID: UUID
    var furnitureItems: [FurnitureItem]
    var colorScheme: ColorScheme
    var lightingPreset: String
}

struct FurnitureItem: Codable, Identifiable {
    var id: UUID
    var modelURL: URL
    var position: SIMD3<Float>
    var rotation: simd_quatf
    var scale: SIMD3<Float>
    var category: FurnitureCategory
}

// Enums
enum PropertyType: String, Codable {
    case singleFamily
    case condo
    case townhouse
    case multiFamily
    case land
    case commercial
}

enum RoomType: String, Codable {
    case livingRoom
    case bedroom
    case kitchen
    case bathroom
    case diningRoom
    case office
    case garage
    case basement
    case other
}

enum UserRole: String, Codable {
    case buyer
    case seller
    case agent
    case propertyManager
    case developer
}

enum InteractionType: String, Codable {
    case roomEnter
    case roomExit
    case measurement
    case stagingToggle
    case photoView
    case shareAction
    case favoriteAction
}

enum StagingStyle: String, Codable {
    case modern
    case traditional
    case minimalist
    case rustic
    case industrial
    case scandinavian
}

enum CaptureQuality: String, Codable {
    case standard
    case high
    case ultra
}
```

### 3.2 Database Schema (SwiftData)

```swift
// Model Container Configuration
@MainActor
class DataController {
    static let shared = DataController()

    let container: ModelContainer

    init() {
        let schema = Schema([
            Property.self,
            Room.self,
            User.self,
            ViewingSession.self,
            StagingConfiguration.self
        ])

        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            allowsSave: true,
            cloudKitDatabase: .automatic
        )

        do {
            container = try ModelContainer(
                for: schema,
                configurations: [configuration]
            )
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }
}
```

## 4. Service Layer Architecture

### 4.1 Service Hierarchy

```swift
// Protocol-based service architecture
protocol PropertyService {
    func fetchProperties(query: SearchQuery) async throws -> [Property]
    func fetchProperty(id: UUID) async throws -> Property
    func saveProperty(_ property: Property) async throws
    func updateProperty(_ property: Property) async throws
}

protocol SpatialCaptureService {
    func loadSpatialAssets(for property: Property) async throws -> SpatialAssets
    func streamRoomMesh(roomID: UUID) async throws -> AsyncStream<MeshChunk>
    func cacheProperty(_ property: Property, priority: CachePriority) async
}

protocol AIService {
    func generatePropertyDescription(_ property: Property) async throws -> String
    func suggestStaging(for room: Room, style: StagingStyle) async throws -> RoomStaging
    func matchProperties(preferences: UserPreferences) async throws -> [PropertyMatch]
    func estimatePrice(property: Property) async throws -> PriceEstimate
}

protocol MLSService {
    func syncListings(lastSync: Date?) async throws -> [Property]
    func fetchMarketData(area: GeographicArea) async throws -> MarketData
    func updatePropertyStatus(mlsNumber: String, status: PropertyStatus) async throws
}

protocol AnalyticsService {
    func trackPropertyView(_ session: ViewingSession) async
    func trackInteraction(_ event: InteractionEvent) async
    func generateEngagementReport(propertyID: UUID) async throws -> EngagementReport
    func getUserInsights(userID: UUID) async throws -> UserInsights
}
```

### 4.2 Service Implementations

```swift
// Property Service Implementation
@Observable
final class PropertyServiceImpl: PropertyService {
    private let networkClient: NetworkClient
    private let cacheManager: CacheManager
    private let context: ModelContext

    init(networkClient: NetworkClient,
         cacheManager: CacheManager,
         context: ModelContext) {
        self.networkClient = networkClient
        self.cacheManager = cacheManager
        self.context = context
    }

    func fetchProperties(query: SearchQuery) async throws -> [Property] {
        // Check cache first
        if let cached = await cacheManager.getCachedProperties(for: query) {
            return cached
        }

        // Fetch from network
        let endpoint = PropertyEndpoint.search(query)
        let properties: [Property] = try await networkClient.request(endpoint)

        // Cache results
        await cacheManager.cacheProperties(properties, for: query)

        // Persist to SwiftData
        for property in properties {
            context.insert(property)
        }
        try context.save()

        return properties
    }

    func fetchProperty(id: UUID) async throws -> Property {
        // Try local database first
        let descriptor = FetchDescriptor<Property>(
            predicate: #Predicate { $0.id == id }
        )

        if let local = try context.fetch(descriptor).first {
            return local
        }

        // Fetch from network
        let endpoint = PropertyEndpoint.detail(id)
        let property: Property = try await networkClient.request(endpoint)

        context.insert(property)
        try context.save()

        return property
    }
}

// Spatial Capture Service
actor SpatialCaptureServiceImpl: SpatialCaptureService {
    private let assetLoader: AssetLoader
    private let cdnClient: CDNClient
    private var loadedAssets: [UUID: SpatialAssets] = [:]

    func loadSpatialAssets(for property: Property) async throws -> SpatialAssets {
        // Return cached if available
        if let cached = loadedAssets[property.id] {
            return cached
        }

        // Load from CDN
        let assets = try await cdnClient.fetchSpatialAssets(
            captureID: property.spatial.spatialCaptureID
        )

        // Cache in memory
        loadedAssets[property.id] = assets

        return assets
    }

    func streamRoomMesh(roomID: UUID) async throws -> AsyncStream<MeshChunk> {
        return AsyncStream { continuation in
            Task {
                do {
                    let chunks = try await cdnClient.streamMesh(roomID: roomID)
                    for await chunk in chunks {
                        continuation.yield(chunk)
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

## 5. RealityKit and ARKit Integration

### 5.1 RealityKit Entity Component System

```swift
// Custom Components for Property Visualization
struct PropertyRoomComponent: Component {
    var roomID: UUID
    var roomType: RoomType
    var dimensions: RoomDimensions
    var isInteractive: Bool
}

struct MeasurementComponent: Component {
    var measurementPoints: [SIMD3<Float>]
    var unit: MeasurementUnit
}

struct StagingComponent: Component {
    var furnitureItems: [Entity]
    var style: StagingStyle
    var isVisible: Bool
}

struct HotspotComponent: Component {
    var infoText: String
    var icon: String
    var action: HotspotAction
}

// Room Entity Factory
@MainActor
class RoomEntityBuilder {
    static func createRoom(from room: Room, spatial: SpatialData) async throws -> Entity {
        let roomEntity = Entity()

        // Add room component
        roomEntity.components[PropertyRoomComponent.self] = PropertyRoomComponent(
            roomID: room.id,
            roomType: room.type,
            dimensions: room.dimensions,
            isInteractive: true
        )

        // Load mesh
        if let meshURL = room.meshAssetURL {
            let mesh = try await loadMesh(from: meshURL)
            let modelEntity = ModelEntity(mesh: mesh)

            // Apply texture
            if let textureURL = room.textureURL {
                let texture = try await TextureResource(contentsOf: textureURL)
                var material = PhysicallyBasedMaterial()
                material.baseColor = .init(texture: .init(texture))
                modelEntity.model?.materials = [material]
            }

            roomEntity.addChild(modelEntity)
        }

        // Add collision for interactions
        let collisionShape = ShapeResource.generateBox(
            width: Float(room.dimensions.length),
            height: Float(room.dimensions.height),
            depth: Float(room.dimensions.width)
        )
        roomEntity.components[CollisionComponent.self] = CollisionComponent(shapes: [collisionShape])

        // Enable input for interactions
        roomEntity.components[InputTargetComponent.self] = InputTargetComponent()

        return roomEntity
    }

    private static func loadMesh(from url: URL) async throws -> MeshResource {
        // Load USDZ or other 3D format
        return try await MeshResource(contentsOf: url)
    }
}

// Property Scene Manager
@MainActor
@Observable
final class PropertySceneManager {
    var rootEntity: Entity
    var currentProperty: Property?
    var stagingEnabled: Bool = false

    private var roomEntities: [UUID: Entity] = [:]
    private var furnitureEntities: [UUID: Entity] = [:]

    init() {
        self.rootEntity = Entity()
        setupLighting()
    }

    func loadProperty(_ property: Property, spatial: SpatialData) async throws {
        // Clear existing scene
        clearScene()

        currentProperty = property

        // Load each room
        for room in property.rooms {
            let roomEntity = try await RoomEntityBuilder.createRoom(
                from: room,
                spatial: spatial
            )
            roomEntities[room.id] = roomEntity
            rootEntity.addChild(roomEntity)
        }

        // Add spatial anchors
        for anchor in spatial.spatialAnchors {
            try await addSpatialAnchor(anchor)
        }
    }

    func toggleStaging(_ configuration: StagingConfiguration) async throws {
        stagingEnabled.toggle()

        if stagingEnabled {
            try await applyStaging(configuration)
        } else {
            removeStaging()
        }
    }

    private func applyStaging(_ configuration: StagingConfiguration) async throws {
        for roomStaging in configuration.rooms {
            guard let roomEntity = roomEntities[roomStaging.roomID] else { continue }

            for furniture in roomStaging.furnitureItems {
                let furnitureEntity = try await loadFurniture(furniture)
                furnitureEntity.position = furniture.position
                furnitureEntity.orientation = furniture.rotation
                furnitureEntity.scale = furniture.scale

                roomEntity.addChild(furnitureEntity)
                furnitureEntities[furniture.id] = furnitureEntity
            }
        }
    }

    private func loadFurniture(_ item: FurnitureItem) async throws -> ModelEntity {
        let model = try await ModelEntity(contentsOf: item.modelURL)
        model.components[StagingComponent.self] = StagingComponent(
            furnitureItems: [],
            style: .modern,
            isVisible: true
        )
        return model
    }

    private func setupLighting() {
        // Add ambient and directional lighting
        let ambientLight = PointLight()
        ambientLight.light.intensity = 500
        ambientLight.position = [0, 2, 0]
        rootEntity.addChild(ambientLight)
    }

    private func clearScene() {
        roomEntities.values.forEach { $0.removeFromParent() }
        roomEntities.removeAll()
        furnitureEntities.removeAll()
    }

    private func removeStaging() {
        furnitureEntities.values.forEach { $0.removeFromParent() }
        furnitureEntities.removeAll()
    }
}
```

### 5.2 ARKit Spatial Tracking

```swift
// ARKit Session Manager for Spatial Anchors
@MainActor
@Observable
final class SpatialTrackingManager {
    private var arKitSession: ARKitSession
    private var worldTracking: WorldTrackingProvider
    private var planeDetection: PlaneDetectionProvider

    var spatialAnchors: [UUID: AnchorEntity] = [:]

    init() {
        arKitSession = ARKitSession()
        worldTracking = WorldTrackingProvider()
        planeDetection = PlaneDetectionProvider()
    }

    func startTracking() async throws {
        try await arKitSession.run([worldTracking, planeDetection])
    }

    func addAnchor(at position: SIMD3<Float>, name: String) -> UUID {
        let anchor = AnchorEntity(world: position)
        let anchorID = UUID()
        spatialAnchors[anchorID] = anchor
        return anchorID
    }

    func trackHandPoses() -> AsyncStream<HandAnchor> {
        AsyncStream { continuation in
            Task {
                for await update in worldTracking.anchorUpdates {
                    if let handAnchor = update.anchor as? HandAnchor {
                        continuation.yield(handAnchor)
                    }
                }
            }
        }
    }
}
```

## 6. API Design and External Integrations

### 6.1 REST API Architecture

```swift
// API Endpoints
enum PropertyEndpoint: APIEndpoint {
    case search(SearchQuery)
    case detail(UUID)
    case nearby(GeographicCoordinate, radius: Double)
    case trending(MarketArea)
    case create(Property)
    case update(UUID, PropertyUpdate)
    case delete(UUID)

    var path: String {
        switch self {
        case .search: return "/properties/search"
        case .detail(let id): return "/properties/\(id)"
        case .nearby: return "/properties/nearby"
        case .trending: return "/properties/trending"
        case .create: return "/properties"
        case .update(let id, _): return "/properties/\(id)"
        case .delete(let id): return "/properties/\(id)"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .search, .detail, .nearby, .trending: return .get
        case .create: return .post
        case .update: return .put
        case .delete: return .delete
        }
    }
}

// Network Client
actor NetworkClient {
    private let baseURL: URL
    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    init(baseURL: URL) {
        self.baseURL = baseURL
        self.session = URLSession.shared
        self.decoder = JSONDecoder()
        self.encoder = JSONEncoder()
    }

    func request<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T {
        let url = baseURL.appendingPathComponent(endpoint.path)
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.invalidResponse
        }

        return try decoder.decode(T.self, from: data)
    }
}
```

### 6.2 MLS Integration

```swift
// MLS Data Sync Service
actor MLSIntegrationService {
    private let mlsClient: MLSAPIClient
    private let propertyService: PropertyService

    func syncListings(since date: Date?) async throws {
        let updates = try await mlsClient.fetchUpdates(since: date)

        for mlsListing in updates {
            let property = try convertMLSToProperty(mlsListing)
            try await propertyService.saveProperty(property)
        }
    }

    private func convertMLSToProperty(_ listing: MLSListing) throws -> Property {
        // Convert MLS data format to internal Property model
        // Map fields, normalize data, etc.
        fatalError("Implementation required")
    }
}
```

### 6.3 AI Services Integration

```swift
// OpenAI Integration for Descriptions and Staging
actor AIServiceClient {
    private let apiKey: String
    private let baseURL = URL(string: "https://api.openai.com/v1")!

    func generatePropertyDescription(_ property: Property) async throws -> String {
        let prompt = buildDescriptionPrompt(property)
        let response = try await completions(prompt: prompt)
        return response.choices.first?.text ?? ""
    }

    func suggestStaging(room: Room, style: StagingStyle) async throws -> [FurnitureItem] {
        let prompt = buildStagingPrompt(room: room, style: style)
        // Use DALL-E or GPT-4 Vision for staging suggestions
        // Return furniture placement recommendations
        fatalError("Implementation required")
    }

    private func completions(prompt: String) async throws -> OpenAIResponse {
        // API call implementation
        fatalError("Implementation required")
    }
}
```

## 7. State Management Strategy

### 7.1 App-Level State

```swift
// Main App Model
@Observable
@MainActor
final class AppModel {
    // User state
    var currentUser: User?
    var isAuthenticated: Bool = false

    // Navigation state
    var selectedProperty: Property?
    var selectedPropertyID: UUID?
    var showingImmersiveSpace: Bool = false

    // UI state
    var searchQuery: SearchQuery = SearchQuery()
    var searchResults: [Property] = []
    var isLoading: Bool = false
    var error: Error?

    // Services
    let propertyService: PropertyService
    let spatialService: SpatialCaptureService
    let aiService: AIService
    let analyticsService: AnalyticsService

    // Scene management
    let sceneManager: PropertySceneManager

    init() {
        // Initialize services
        let networkClient = NetworkClient(baseURL: Configuration.apiBaseURL)
        let cacheManager = CacheManager()
        let context = DataController.shared.container.mainContext

        self.propertyService = PropertyServiceImpl(
            networkClient: networkClient,
            cacheManager: cacheManager,
            context: context
        )
        self.spatialService = SpatialCaptureServiceImpl()
        self.aiService = AIServiceClient(apiKey: Configuration.openAIKey)
        self.analyticsService = AnalyticsServiceImpl()
        self.sceneManager = PropertySceneManager()
    }

    // Actions
    func searchProperties() async {
        isLoading = true
        defer { isLoading = false }

        do {
            searchResults = try await propertyService.fetchProperties(query: searchQuery)
        } catch {
            self.error = error
        }
    }

    func selectProperty(_ property: Property) async {
        selectedProperty = property
        selectedPropertyID = property.id

        // Preload spatial assets
        Task {
            _ = try? await spatialService.loadSpatialAssets(for: property)
        }

        // Track view
        await analyticsService.trackPropertyView(
            ViewingSession(
                id: UUID(),
                propertyID: property.id,
                userID: currentUser?.id ?? UUID(),
                startTime: Date(),
                duration: 0,
                interactions: [],
                roomsVisited: [],
                engagementScore: 0,
                completionPercentage: 0
            )
        )
    }
}
```

## 8. Performance Optimization Strategy

### 8.1 Asset Streaming and LOD

```swift
// Level of Detail Management
enum LODLevel: Int {
    case low = 0
    case medium = 1
    case high = 2
    case ultra = 3
}

actor AssetStreamingManager {
    private var loadedAssets: [UUID: LODLevel] = [:]

    func loadPropertyAssets(
        propertyID: UUID,
        userDistance: Float
    ) async throws -> SpatialAssets {
        let lodLevel = determineLOD(distance: userDistance)

        // Stream appropriate quality assets
        switch lodLevel {
        case .low:
            return try await loadLowPolyAssets(propertyID)
        case .medium:
            return try await loadMediumQualityAssets(propertyID)
        case .high, .ultra:
            return try await loadHighQualityAssets(propertyID)
        }
    }

    private func determineLOD(distance: Float) -> LODLevel {
        switch distance {
        case 0..<5: return .ultra
        case 5..<15: return .high
        case 15..<30: return .medium
        default: return .low
        }
    }
}
```

### 8.2 Caching Strategy

```swift
// Multi-tier caching
actor CacheManager {
    private let memoryCache = NSCache<NSString, CachedProperty>()
    private let diskCache: DiskCache

    init() {
        diskCache = DiskCache(directory: .cachesDirectory)
        memoryCache.countLimit = 50 // 50 properties in memory
        memoryCache.totalCostLimit = 500 * 1024 * 1024 // 500MB
    }

    func getCachedProperties(for query: SearchQuery) async -> [Property]? {
        let key = query.cacheKey

        // Try memory first
        if let cached = memoryCache.object(forKey: key as NSString) {
            if !cached.isExpired {
                return cached.properties
            }
        }

        // Try disk
        if let diskCached = await diskCache.load(key: key) {
            memoryCache.setObject(diskCached, forKey: key as NSString)
            return diskCached.properties
        }

        return nil
    }
}
```

### 8.3 Concurrent Processing

```swift
// Use Swift Concurrency for parallel operations
func loadPropertyWithAssets(_ propertyID: UUID) async throws -> (Property, SpatialAssets) {
    async let property = propertyService.fetchProperty(id: propertyID)
    async let assets = spatialService.loadSpatialAssets(for: try await property)

    return try await (property, assets)
}
```

## 9. Security Architecture

### 9.1 Authentication and Authorization

```swift
// Auth Service
actor AuthService {
    private let keychain: KeychainManager
    private var currentToken: AuthToken?

    func authenticate(email: String, password: String) async throws -> User {
        let credentials = Credentials(email: email, password: password)
        let response = try await authAPI.login(credentials)

        // Store token securely in keychain
        try keychain.save(response.token, for: .authToken)
        currentToken = response.token

        return response.user
    }

    func validateToken() async throws -> Bool {
        guard let token = currentToken else { return false }
        return try await authAPI.validateToken(token)
    }
}
```

### 9.2 Data Encryption

```swift
// Encrypt sensitive property data
struct SecurePropertyData {
    static func encrypt(_ property: Property) throws -> Data {
        let encoder = JSONEncoder()
        let data = try encoder.encode(property)

        // Use CryptoKit for encryption
        let key = SymmetricKey(size: .bits256)
        let sealedBox = try AES.GCM.seal(data, using: key)

        return sealedBox.combined ?? Data()
    }

    static func decrypt(_ data: Data) throws -> Property {
        let key = SymmetricKey(size: .bits256)
        let sealedBox = try AES.GCM.SealedBox(combined: data)
        let decrypted = try AES.GCM.open(sealedBox, using: key)

        let decoder = JSONDecoder()
        return try decoder.decode(Property.self, from: decrypted)
    }
}
```

### 9.3 Privacy Compliance

```swift
// GDPR/CCPA Compliance Manager
actor PrivacyManager {
    func requestDataDeletion(userID: UUID) async throws {
        // Delete user data from all systems
        try await deleteUserProperties(userID)
        try await deleteUserAnalytics(userID)
        try await deleteUserAccount(userID)
    }

    func exportUserData(userID: UUID) async throws -> Data {
        // Export all user data in portable format
        let userData = try await gatherUserData(userID)
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        return try encoder.encode(userData)
    }
}
```

## 10. Testing Strategy

### 10.1 Unit Testing

```swift
@Test("Property model creation")
func testPropertyCreation() {
    let address = PropertyAddress(
        street: "123 Main St",
        city: "San Francisco",
        state: "CA",
        zipCode: "94102",
        country: "USA",
        coordinates: GeographicCoordinate(latitude: 37.7749, longitude: -122.4194)
    )

    let property = Property(
        mlsNumber: "MLS123456",
        address: address
    )

    #expect(property.mlsNumber == "MLS123456")
    #expect(property.address.city == "San Francisco")
}

@Test("Property service fetching")
func testPropertyFetch() async throws {
    let mockClient = MockNetworkClient()
    let service = PropertyServiceImpl(
        networkClient: mockClient,
        cacheManager: MockCacheManager(),
        context: mockContext
    )

    let properties = try await service.fetchProperties(query: SearchQuery())
    #expect(properties.count > 0)
}
```

### 10.2 Integration Testing

```swift
@Test("End-to-end property tour flow")
@MainActor
func testPropertyTourFlow() async throws {
    let app = AppModel()

    // Search for properties
    await app.searchProperties()
    #expect(app.searchResults.count > 0)

    // Select a property
    let property = app.searchResults.first!
    await app.selectProperty(property)
    #expect(app.selectedProperty?.id == property.id)

    // Load spatial assets
    let assets = try await app.spatialService.loadSpatialAssets(for: property)
    #expect(assets.roomMeshes.count > 0)
}
```

## 11. Deployment Architecture

### 11.1 Build Configuration

```swift
// Configuration Management
enum Configuration {
    static var apiBaseURL: URL {
        #if DEBUG
        return URL(string: "https://api-dev.realestatespatial.com")!
        #else
        return URL(string: "https://api.realestatespatial.com")!
        #endif
    }

    static var openAIKey: String {
        // Load from secure storage or environment
        return ProcessInfo.processInfo.environment["OPENAI_API_KEY"] ?? ""
    }

    static var enableAnalytics: Bool {
        #if DEBUG
        return false
        #else
        return true
        #endif
    }
}
```

### 11.2 App Store Distribution

```
Distribution Strategy:
- Enterprise: Internal distribution for real estate agencies
- TestFlight: Beta testing with selected agents
- App Store: Consumer release (post-MVP)
- MDM: Corporate device management for large brokerages
```

## 12. Monitoring and Observability

```swift
// Logging and Telemetry
import OSLog

extension Logger {
    static let property = Logger(subsystem: "com.realestatespatial", category: "property")
    static let spatial = Logger(subsystem: "com.realestatespatial", category: "spatial")
    static let network = Logger(subsystem: "com.realestatespatial", category: "network")
    static let analytics = Logger(subsystem: "com.realestatespatial", category: "analytics")
}

// Usage
Logger.property.info("Loading property: \(propertyID)")
Logger.spatial.error("Failed to load mesh: \(error)")
```

## 13. Conclusion

This architecture provides a robust, scalable foundation for the Real Estate Spatial Platform on visionOS. Key design decisions:

1. **Spatial-First**: Leveraging visionOS presentation modes appropriately
2. **Performance**: LOD, streaming, and caching for smooth 90fps experience
3. **Scalability**: Service-oriented architecture with clear boundaries
4. **Security**: End-to-end encryption and privacy compliance
5. **Maintainability**: MVVM pattern with SwiftUI and SwiftData

The architecture supports all PRD requirements while maintaining flexibility for future enhancements and platform evolution.

---

**Next Steps**: Proceed to TECHNICAL_SPEC.md for detailed implementation specifications.
