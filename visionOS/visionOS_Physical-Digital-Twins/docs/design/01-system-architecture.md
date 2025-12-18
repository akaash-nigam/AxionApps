# System Architecture Document

## Overview

Physical-Digital Twins is a visionOS spatial computing application that creates digital enhancement layers for physical objects. This document outlines the system architecture, component design, and technical approach.

## Architecture Principles

1. **Modular Design**: Feature-based modules with clear boundaries
2. **Testability**: Dependency injection and protocol-oriented design
3. **Scalability**: Support for unlimited items with efficient data management
4. **Offline-First**: Core features work without internet connectivity
5. **Performance**: Maintain 90fps for AR, <2s object recognition
6. **Privacy**: Local-first with optional cloud sync

## High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     Presentation Layer                       │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │   SwiftUI    │  │  RealityKit  │  │  ARKit       │     │
│  │   Views      │  │  AR Overlays │  │  Spatial UI  │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
└─────────────────────────────────────────────────────────────┘
                            │
┌─────────────────────────────────────────────────────────────┐
│                    Application Layer                         │
│  ┌──────────────────────────────────────────────────────┐  │
│  │              Feature Modules (ViewModels)             │  │
│  │                                                        │  │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐           │  │
│  │  │ Object   │  │ Digital  │  │ Inventory│           │  │
│  │  │Recognition│  │ Twin Mgr │  │ Manager  │           │  │
│  │  └──────────┘  └──────────┘  └──────────┘           │  │
│  │                                                        │  │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐           │  │
│  │  │Expiration│  │ Assembly │  │Sustainabi│           │  │
│  │  │ Tracker  │  │Instructions│  │lity Mgr │           │  │
│  │  └──────────┘  └──────────┘  └──────────┘           │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                            │
┌─────────────────────────────────────────────────────────────┐
│                     Service Layer                            │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │   Vision     │  │   Product    │  │ Notification │     │
│  │   Service    │  │API Aggregator│  │   Service    │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
│                                                              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │   Storage    │  │   Sync       │  │   Analytics  │     │
│  │   Service    │  │   Service    │  │   Service    │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
└─────────────────────────────────────────────────────────────┘
                            │
┌─────────────────────────────────────────────────────────────┐
│                    Data/Infrastructure Layer                 │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │  Core Data   │  │   CloudKit   │  │  UserDefaults│     │
│  │   Stack      │  │   Sync       │  │  Settings    │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
│                                                              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │  Core ML     │  │   Keychain   │  │  FileManager │     │
│  │   Models     │  │   Secure     │  │  Image Cache │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
└─────────────────────────────────────────────────────────────┘
```

## Core Components

### 1. Presentation Layer

#### SwiftUI Views
- **ImmersiveSpaceView**: Main AR scanning environment
- **WindowView**: 2D inventory management interface
- **DigitalTwinCard**: Floating information cards in AR space
- **InventoryDashboard**: Comprehensive inventory management
- **SettingsView**: App configuration

#### RealityKit Components
- **TwinAnchorComponent**: Anchors digital twins to physical objects
- **InteractionComponent**: Handles user interactions (gaze, pinch)
- **AnimationComponent**: Smooth transitions and highlights

### 2. Application Layer (Feature Modules)

#### ObjectRecognitionModule
**Responsibility**: Identify physical objects from camera feed

**Components**:
- `ObjectRecognitionViewModel`: Orchestrates recognition flow
- `ObjectClassifier`: Core ML model wrapper
- `BarcodeScanner`: Vision framework barcode detection
- `ImageMatcher`: Visual similarity search

**Dependencies**:
- VisionService
- DigitalTwinManager
- StorageService

#### DigitalTwinManager
**Responsibility**: Create, retrieve, update digital twins

**Components**:
- `DigitalTwinViewModel`: Twin lifecycle management
- `TwinFactory`: Creates twins for different object categories
- `TwinRegistry`: Maps physical objects to twins

**Data Models**:
```swift
protocol DigitalTwin: Identifiable, Codable {
    var id: UUID { get }
    var objectType: ObjectCategory { get }
    var createdAt: Date { get }
    var lastUpdated: Date { get }
    var metadata: [String: Any] { get }
}

struct BookTwin: DigitalTwin {
    let id: UUID
    let objectType: ObjectCategory = .book
    var title: String
    var author: String
    var isbn: String?
    var rating: Double?
    var readingStatus: ReadingStatus
    var notes: String?
}

struct FoodTwin: DigitalTwin {
    let id: UUID
    let objectType: ObjectCategory = .food
    var productName: String
    var barcode: String?
    var expirationDate: Date?
    var opened: Date?
    var nutritionInfo: NutritionInfo?
}
```

#### InventoryManager
**Responsibility**: Manage personal inventory catalog

**Components**:
- `InventoryViewModel`: Overall inventory state
- `RoomScanner`: Batch object detection via ARKit
- `LocationManager`: Track item locations in home
- `ValueCalculator`: Compute total inventory value

#### ExpirationTracker
**Responsibility**: Monitor food freshness and expiration

**Components**:
- `ExpirationViewModel`: Expiration state management
- `DateExtractor`: OCR for expiration dates
- `FreshnessCalculator`: Estimate remaining shelf life
- `RecipeRecommender`: Suggest recipes for expiring items

#### AssemblyInstructionModule
**Responsibility**: Display AR assembly instructions

**Components**:
- `AssemblyViewModel`: Instruction flow state
- `ManualFetcher`: Retrieve assembly guides
- `ARInstructionRenderer`: Overlay instructions in AR
- `StepTracker`: Progress through assembly steps

#### SustainabilityManager
**Responsibility**: Track environmental impact and product lifecycle

**Components**:
- `SustainabilityViewModel`: Environmental metrics
- `CarbonCalculator`: Estimate carbon footprint
- `ResaleValueEstimator`: Current market value
- `RecyclingLocator`: Find local recycling facilities

### 3. Service Layer

#### VisionService
**Responsibility**: Computer vision operations

```swift
protocol VisionService {
    func recognizeObject(from image: CIImage) async throws -> RecognizedObject
    func scanBarcode(from image: CIImage) async throws -> BarcodeResult?
    func extractText(from image: CIImage) async throws -> [String]
    func findSimilarImages(query: CIImage) async throws -> [ImageMatch]
}

class VisionServiceImpl: VisionService {
    private let modelManager: MLModelManager
    private let visionQueue: DispatchQueue

    // Implementation using Vision framework + Core ML
}
```

#### ProductAPIAggregator
**Responsibility**: Aggregate data from multiple product APIs

```swift
protocol ProductAPIService {
    func fetchProductInfo(barcode: String) async throws -> ProductInfo
    func searchProduct(query: String) async throws -> [ProductInfo]
}

class ProductAPIAggregator: ProductAPIService {
    private let amazonAPI: AmazonProductAPI
    private let googleShoppingAPI: GoogleShoppingAPI
    private let openFoodFacts: OpenFoodFactsAPI
    private let upcDatabase: UPCDatabaseAPI

    // Aggregate results from multiple sources
    // Implement fallback chain and rate limiting
}
```

#### StorageService
**Responsibility**: Data persistence and retrieval

```swift
protocol StorageService {
    func saveTwin(_ twin: any DigitalTwin) async throws
    func fetchTwin(id: UUID) async throws -> (any DigitalTwin)?
    func fetchAllTwins() async throws -> [any DigitalTwin]
    func deleteTwin(id: UUID) async throws
    func searchTwins(query: String) async throws -> [any DigitalTwin]
}

class StorageServiceImpl: StorageService {
    private let coreDataStack: CoreDataStack
    private let imageCache: ImageCacheService

    // Implementation using Core Data
}
```

#### SyncService
**Responsibility**: CloudKit synchronization

```swift
protocol SyncService {
    func syncToCloud() async throws
    func syncFromCloud() async throws
    func resolveConflicts(_ conflicts: [SyncConflict]) async throws
    var syncStatus: AsyncStream<SyncStatus> { get }
}
```

#### NotificationService
**Responsibility**: Schedule and manage notifications

```swift
protocol NotificationService {
    func scheduleExpirationAlert(for twin: FoodTwin) async throws
    func scheduleWarrantyReminder(for twin: any DigitalTwin) async throws
    func cancelNotifications(for twinId: UUID) async throws
}
```

### 4. Data Layer

#### Core Data Stack
**Entities**:
- `DigitalTwinEntity`: Base entity for all twins
- `InventoryItemEntity`: Items in personal inventory
- `LocationEntity`: Physical locations in home
- `RecognitionHistoryEntity`: History of recognized objects

#### CloudKit Schema
**Record Types**:
- `DigitalTwin`: Synced twin data
- `InventoryItem`: Personal inventory items
- `UserSettings`: App preferences

#### Image Cache
- Local file storage for object photos
- Optimized compression (WebP format)
- LRU cache eviction policy
- Maximum 500MB cache size

## State Management

### SwiftUI @Observable Pattern

```swift
@Observable
class AppState {
    var currentSession: ScanningSession?
    var inventory: InventoryState
    var userSettings: UserSettings
    var syncStatus: SyncStatus

    private let dependencies: AppDependencies

    func startScanning() { ... }
    func stopScanning() { ... }
    func refreshInventory() async { ... }
}

@Observable
class InventoryState {
    var items: [InventoryItem] = []
    var totalValue: Decimal = 0
    var categoryBreakdown: [ObjectCategory: Int] = [:]

    func addItem(_ item: InventoryItem) { ... }
    func removeItem(id: UUID) { ... }
}
```

## Dependency Injection

### Container Pattern

```swift
protocol DependencyContainer {
    var visionService: VisionService { get }
    var storageService: StorageService { get }
    var syncService: SyncService { get }
    var productAPIService: ProductAPIService { get }
    var notificationService: NotificationService { get }
}

class AppDependencies: DependencyContainer {
    // Lazy initialization of services
    lazy var visionService: VisionService = VisionServiceImpl(...)
    lazy var storageService: StorageService = StorageServiceImpl(...)
    // etc.
}

// Pass to root view
@main
struct PhysicalDigitalTwinsApp: App {
    @State private var appState: AppState

    init() {
        let dependencies = AppDependencies()
        self.appState = AppState(dependencies: dependencies)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appState)
        }
    }
}
```

## Plugin Architecture for Object Types

### Extensibility for New Object Categories

```swift
protocol ObjectTypePlugin {
    var category: ObjectCategory { get }
    func createTwin(from recognition: RecognizedObject) async throws -> any DigitalTwin
    func enrichTwin(_ twin: any DigitalTwin) async throws -> any DigitalTwin
    func viewForTwin(_ twin: any DigitalTwin) -> any View
}

class BookPlugin: ObjectTypePlugin {
    let category: ObjectCategory = .book

    func createTwin(from recognition: RecognizedObject) async throws -> any DigitalTwin {
        let bookInfo = try await bookAPI.fetch(isbn: recognition.isbn)
        return BookTwin(from: bookInfo)
    }

    func enrichTwin(_ twin: any DigitalTwin) async throws -> any DigitalTwin {
        guard var bookTwin = twin as? BookTwin else { return twin }
        bookTwin.rating = try await goodreadsAPI.getRating(isbn: bookTwin.isbn)
        return bookTwin
    }

    func viewForTwin(_ twin: any DigitalTwin) -> any View {
        BookTwinView(book: twin as! BookTwin)
    }
}

class ObjectTypeRegistry {
    private var plugins: [ObjectCategory: ObjectTypePlugin] = [:]

    func register(_ plugin: ObjectTypePlugin) {
        plugins[plugin.category] = plugin
    }

    func plugin(for category: ObjectCategory) -> ObjectTypePlugin? {
        plugins[category]
    }
}
```

## Concurrency & Threading

### Structured Concurrency with Swift Async/Await

- **Main Actor**: All UI updates and SwiftUI state changes
- **Background Tasks**: Vision processing, ML inference, API calls
- **Actor Isolation**: Core Data operations isolated to `@ModelActor`

```swift
@MainActor
class ObjectRecognitionViewModel: ObservableObject {
    @Published var recognizedObject: RecognizedObject?
    @Published var isProcessing = false

    private let visionService: VisionService

    func processFrame(_ image: CIImage) async {
        isProcessing = true
        defer { isProcessing = false }

        do {
            // Runs on background queue
            let result = try await visionService.recognizeObject(from: image)
            // Updates published property on main actor
            recognizedObject = result
        } catch {
            // Handle error
        }
    }
}
```

## Performance Considerations

### Memory Management
- Use `@MainActor` for UI state to prevent data races
- Lazy loading of digital twin details
- Image downsampling for thumbnails
- Unload inactive twins from memory

### Caching Strategy
- 3-tier cache: Memory → Disk → Network
- Pre-fetch likely-needed twin data
- Cache API responses (24-hour TTL)

### AR Performance
- Target 90fps for immersive experience
- Limit simultaneous AR entities (max 20)
- Use level-of-detail (LOD) for 3D models
- Occlusion for realistic AR blending

## Error Handling Architecture

### Layered Error Handling

```swift
enum AppError: LocalizedError {
    case vision(VisionError)
    case storage(StorageError)
    case network(NetworkError)
    case sync(SyncError)

    var errorDescription: String? { ... }
    var recoverySuggestion: String? { ... }
}

enum VisionError: Error {
    case modelLoadFailed
    case recognitionFailed
    case unsupportedImageFormat
}

// Service layer throws specific errors
// ViewModel layer catches and converts to user-facing messages
// UI layer displays alerts/banners
```

## Testing Architecture

### Testability through Protocols

```swift
// Production
class ProductionVisionService: VisionService { ... }

// Testing
class MockVisionService: VisionService {
    var mockResult: RecognizedObject?

    func recognizeObject(from image: CIImage) async throws -> RecognizedObject {
        guard let result = mockResult else {
            throw VisionError.recognitionFailed
        }
        return result
    }
}

// In tests
func testObjectRecognition() async throws {
    let mockVision = MockVisionService()
    mockVision.mockResult = RecognizedObject(type: .book, confidence: 0.95)

    let viewModel = ObjectRecognitionViewModel(visionService: mockVision)
    await viewModel.processFrame(testImage)

    XCTAssertEqual(viewModel.recognizedObject?.type, .book)
}
```

## Security Architecture

### Data Protection
- Keychain: API keys, authentication tokens
- FileProtection: `.complete` for sensitive data
- CloudKit: Encrypted private database
- No sensitive data in UserDefaults

### Authentication
- Sign in with Apple (optional for cloud sync)
- Anonymous local-only mode supported
- Biometric authentication for app access (optional)

## Scalability Considerations

### Handling Large Inventories
- Pagination for inventory lists (50 items per page)
- Indexed Core Data queries
- Background queue for sync operations
- Incremental CloudKit sync

### API Rate Limiting
- Token bucket algorithm for API calls
- Exponential backoff for failed requests
- Queue non-urgent API calls for batch processing
- Cache API responses aggressively

## Future Architecture Considerations

### Extensibility Points
1. **Custom Object Types**: Plugin system allows third-party categories
2. **Additional APIs**: Easy to add new product data sources
3. **Multi-Platform**: Architecture supports iOS companion app
4. **Shared Inventory**: Family sharing through CloudKit zones
5. **ML Model Updates**: Over-the-air Core ML model updates

### Migration Strategy
- Core Data lightweight migrations for schema changes
- Versioned CloudKit records
- Backward compatibility for 2 major versions

## Technology Stack Summary

| Layer | Technologies |
|-------|-------------|
| UI | SwiftUI, RealityKit, ARKit |
| Application | Swift 6.0, Async/Await, Actors |
| Services | Vision Framework, Core ML, URLSession |
| Data | Core Data, CloudKit, Keychain, FileManager |
| Testing | XCTest, XCTVapor (mocking) |
| CI/CD | Xcode Cloud, TestFlight |

## Conclusion

This architecture provides:
- **Modularity**: Clear separation of concerns
- **Testability**: Protocol-based design with dependency injection
- **Performance**: Optimized for real-time AR and ML
- **Scalability**: Handles unlimited items efficiently
- **Maintainability**: Clean architecture with well-defined boundaries
- **Extensibility**: Plugin system for new object types

Next steps: Implement core services layer and data models, then build feature modules on top.
