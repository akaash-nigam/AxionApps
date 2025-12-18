# Technical Architecture Document
## Home Maintenance Oracle

**Version**: 1.0
**Last Updated**: 2025-11-24
**Status**: Draft

---

## Table of Contents

1. [System Overview](#system-overview)
2. [Architecture Patterns](#architecture-patterns)
3. [Component Architecture](#component-architecture)
4. [Service Layer Design](#service-layer-design)
5. [Networking Layer](#networking-layer)
6. [Data Flow](#data-flow)
7. [Caching Strategy](#caching-strategy)
8. [Error Handling](#error-handling)
9. [Background Processing](#background-processing)
10. [Performance Considerations](#performance-considerations)

---

## System Overview

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     Vision Pro UI Layer                      │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │  SwiftUI     │  │  RealityKit  │  │   ARKit      │      │
│  │  Views       │  │  3D Scenes   │  │  Spatial     │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└─────────────────────────────────────────────────────────────┘
                            │
┌─────────────────────────────────────────────────────────────┐
│                      Application Layer                       │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │  ViewModels  │  │  Use Cases   │  │  Coordinators│      │
│  │  (ObservableObject)│  │(Business Logic)│  │ (Navigation) │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└─────────────────────────────────────────────────────────────┘
                            │
┌─────────────────────────────────────────────────────────────┐
│                       Service Layer                          │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │  Recognition │  │  Manual      │  │  Maintenance │      │
│  │  Service     │  │  Service     │  │  Service     │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │  Parts       │  │  Tutorial    │  │  Inventory   │      │
│  │  Service     │  │  Service     │  │  Service     │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└─────────────────────────────────────────────────────────────┘
                            │
┌─────────────────────────────────────────────────────────────┐
│                    Data & Storage Layer                      │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │  Core Data   │  │  CloudKit    │  │  File System │      │
│  │  (Local DB)  │  │  (Sync)      │  │  (Cache)     │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │  Core ML     │  │  UserDefaults│  │  Keychain    │      │
│  │  (ML Models) │  │  (Prefs)     │  │  (Secrets)   │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└─────────────────────────────────────────────────────────────┘
                            │
┌─────────────────────────────────────────────────────────────┐
│                     External Services                        │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │  Manual API  │  │  Parts APIs  │  │  Video APIs  │      │
│  │  (REST)      │  │  (Amazon,eBay)│  │ (YouTube)    │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└─────────────────────────────────────────────────────────────┘
```

---

## Architecture Patterns

### Primary Pattern: Clean Architecture + MVVM

We use a layered architecture with clear separation of concerns:

1. **Presentation Layer** (SwiftUI + ViewModels)
2. **Domain Layer** (Use Cases + Entities)
3. **Data Layer** (Repositories + Data Sources)

### Key Principles

- **Dependency Inversion**: Inner layers don't depend on outer layers
- **Single Responsibility**: Each component has one clear purpose
- **Testability**: All business logic is unit testable
- **Immutability**: Use value types and Observables where possible

### Folder Structure

```
HomeMaintenanceOracle/
├── App/
│   ├── HomeMaintenanceOracleApp.swift
│   └── AppDependencies.swift
├── Presentation/
│   ├── Scenes/
│   │   ├── Home/
│   │   ├── ApplianceDetail/
│   │   ├── Manual/
│   │   ├── Tutorial/
│   │   ├── Maintenance/
│   │   └── Inventory/
│   ├── Components/
│   │   ├── SpatialViews/
│   │   └── CommonViews/
│   └── ViewModels/
├── Domain/
│   ├── Entities/
│   ├── UseCases/
│   └── Repositories/ (Protocols)
├── Data/
│   ├── Repositories/ (Implementations)
│   ├── DataSources/
│   │   ├── Local/
│   │   └── Remote/
│   ├── Models/ (DTOs)
│   └── CoreData/
├── Services/
│   ├── Recognition/
│   ├── Networking/
│   ├── Storage/
│   └── ML/
├── Infrastructure/
│   ├── Extensions/
│   ├── Utilities/
│   └── Constants/
└── Resources/
    ├── Assets/
    ├── CoreML/
    └── Localization/
```

---

## Component Architecture

### 1. Recognition Service

```swift
protocol RecognitionServiceProtocol {
    func recognizeAppliance(from image: CGImage) async throws -> RecognizedAppliance
    func recognizePart(from image: CGImage) async throws -> RecognizedPart
    func extractModelNumber(from image: CGImage) async throws -> String
}

class RecognitionService: RecognitionServiceProtocol {
    private let applianceClassifier: ApplianceClassifier
    private let brandDetector: BrandDetector
    private let ocrEngine: OCREngine
    private let partRecognizer: PartRecognizer

    // ML Model management
    // Image preprocessing
    // Confidence threshold validation
    // Fallback logic
}
```

**Dependencies**:
- Core ML (on-device inference)
- Vision Framework (OCR, object detection)
- RealityKit (camera feed access)

**Responsibilities**:
- Run ML models for classification
- Extract text from model plates
- Coordinate multi-stage recognition pipeline
- Cache recent recognitions

### 2. Manual Service

```swift
protocol ManualServiceProtocol {
    func fetchManual(for appliance: Appliance) async throws -> Manual
    func downloadManual(_ manual: Manual) async throws -> URL
    func searchManuals(query: String) async throws -> [Manual]
    func bookmarkPage(_ page: Int, in manual: Manual)
}

class ManualService: ManualServiceProtocol {
    private let apiClient: APIClient
    private let cacheManager: CacheManager
    private let pdfRenderer: PDFRenderer

    // API integration
    // Local caching
    // PDF download management
    // Search indexing
}
```

### 3. Maintenance Service

```swift
protocol MaintenanceServiceProtocol {
    func generateSchedule(for appliances: [Appliance]) -> [MaintenanceTask]
    func scheduleReminder(for task: MaintenanceTask) throws
    func markTaskComplete(_ task: MaintenanceTask, with photo: UIImage?) async
    func getUpcomingTasks(within days: Int) -> [MaintenanceTask]
}

class MaintenanceService: MaintenanceServiceProtocol {
    private let notificationManager: NotificationManager
    private let repository: MaintenanceRepository
    private let scheduleEngine: ScheduleEngine

    // Schedule generation logic
    // Notification scheduling
    // Task completion tracking
    // Calendar integration
}
```

### 4. Parts Service

```swift
protocol PartsServiceProtocol {
    func searchParts(for appliance: Appliance, partType: String) async throws -> [Part]
    func comparePrices(for part: Part) async throws -> [PartListing]
    func createAffiliateLink(for listing: PartListing) -> URL
}

class PartsService: PartsServiceProtocol {
    private let amazonAPI: AmazonAPIClient
    private let ebayAPI: EbayAPIClient
    private let priceComparator: PriceComparator

    // Multi-source part search
    // Price comparison
    // Affiliate link generation
    // Availability checking
}
```

### 5. Tutorial Service

```swift
protocol TutorialServiceProtocol {
    func findTutorials(for appliance: Appliance, issue: String) async throws -> [Tutorial]
    func streamVideo(from url: URL) -> AsyncStream<VideoChunk>
    func cacheTutorial(_ tutorial: Tutorial) async throws
}

class TutorialService: TutorialServiceProtocol {
    private let youtubeAPI: YouTubeAPIClient
    private let videoCache: VideoCache
    private let avPlayer: AVPlayerManager

    // Video search
    // Streaming management
    // Offline caching
    // Playback coordination
}
```

### 6. Inventory Service

```swift
protocol InventoryServiceProtocol {
    func scanRoom() async throws -> [Appliance]
    func addAppliance(_ appliance: Appliance) async throws
    func updateAppliance(_ appliance: Appliance) async throws
    func deleteAppliance(_ id: UUID) async throws
    func exportInventory() async throws -> URL
}

class InventoryService: InventoryServiceProtocol {
    private let repository: InventoryRepository
    private let recognitionService: RecognitionService
    private let cloudSync: CloudSyncManager

    // Room scanning
    // CRUD operations
    // CloudKit sync
    // Export functionality
}
```

---

## Service Layer Design

### Dependency Injection

Use a dependency container for service management:

```swift
class AppDependencies {
    // Services
    lazy var recognitionService: RecognitionServiceProtocol = RecognitionService(
        applianceClassifier: applianceClassifier,
        brandDetector: brandDetector,
        ocrEngine: ocrEngine
    )

    lazy var manualService: ManualServiceProtocol = ManualService(
        apiClient: apiClient,
        cacheManager: cacheManager
    )

    lazy var maintenanceService: MaintenanceServiceProtocol = MaintenanceService(
        repository: maintenanceRepository,
        notificationManager: notificationManager
    )

    // Repositories
    lazy var inventoryRepository: InventoryRepository = CoreDataInventoryRepository(
        context: persistenceController.container.viewContext
    )

    // API Clients
    lazy var apiClient: APIClient = URLSessionAPIClient(
        session: .shared,
        baseURL: Configuration.apiBaseURL
    )
}
```

### Service Communication

Services communicate through:
1. **Direct calls** for synchronous operations
2. **Async/await** for asynchronous operations
3. **Combine publishers** for reactive streams
4. **Notification Center** for system-wide events

```swift
// Example: Recognition triggers manual fetch
class ApplianceDetailViewModel: ObservableObject {
    @Published var appliance: Appliance?
    @Published var manual: Manual?

    private let recognitionService: RecognitionServiceProtocol
    private let manualService: ManualServiceProtocol

    func recognizeAndFetchManual(image: CGImage) async {
        do {
            // Step 1: Recognize
            let recognized = try await recognitionService.recognizeAppliance(from: image)
            appliance = recognized.toAppliance()

            // Step 2: Fetch manual
            manual = try await manualService.fetchManual(for: appliance!)
        } catch {
            handleError(error)
        }
    }
}
```

---

## Networking Layer

### API Client Architecture

```swift
protocol APIClient {
    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T
    func download(_ url: URL, to destination: URL) async throws
}

class URLSessionAPIClient: APIClient {
    private let session: URLSession
    private let baseURL: URL
    private let requestBuilder: RequestBuilder
    private let responseHandler: ResponseHandler

    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        let request = try requestBuilder.build(endpoint, baseURL: baseURL)
        let (data, response) = try await session.data(for: request)
        return try responseHandler.handle(data, response: response)
    }
}
```

### Endpoint Definition

```swift
enum Endpoint {
    case manualSearch(query: String)
    case manualDownload(id: String)
    case partsSearch(model: String, part: String)
    case tutorialSearch(appliance: String, issue: String)

    var path: String { ... }
    var method: HTTPMethod { ... }
    var headers: [String: String] { ... }
    var queryParameters: [String: String]? { ... }
}
```

### Request/Response Handling

```swift
struct RequestBuilder {
    func build(_ endpoint: Endpoint, baseURL: URL) throws -> URLRequest {
        var request = URLRequest(url: baseURL.appendingPathComponent(endpoint.path))
        request.httpMethod = endpoint.method.rawValue

        // Add headers
        endpoint.headers.forEach { request.setValue($1, forHTTPHeaderField: $0) }

        // Add query parameters
        if let params = endpoint.queryParameters {
            var components = URLComponents(url: request.url!, resolvingAgainstBaseURL: true)
            components?.queryItems = params.map { URLQueryItem(name: $0, value: $1) }
            request.url = components?.url
        }

        return request
    }
}

struct ResponseHandler {
    func handle<T: Decodable>(_ data: Data, response: URLResponse) throws -> T {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.httpError(statusCode: httpResponse.statusCode)
        }

        return try JSONDecoder().decode(T.self, from: data)
    }
}
```

### Network Error Handling

```swift
enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
    case decodingError(Error)
    case noConnection
    case timeout
    case rateLimitExceeded

    var userMessage: String {
        switch self {
        case .noConnection:
            return "No internet connection. Please check your network."
        case .timeout:
            return "Request timed out. Please try again."
        case .rateLimitExceeded:
            return "Too many requests. Please wait a moment."
        default:
            return "Something went wrong. Please try again."
        }
    }
}
```

### Retry Logic

```swift
extension URLSessionAPIClient {
    func requestWithRetry<T: Decodable>(
        _ endpoint: Endpoint,
        maxRetries: Int = 3,
        retryDelay: TimeInterval = 2.0
    ) async throws -> T {
        var lastError: Error?

        for attempt in 0..<maxRetries {
            do {
                return try await request(endpoint)
            } catch let error as NetworkError where error.isRetryable {
                lastError = error
                if attempt < maxRetries - 1 {
                    try await Task.sleep(nanoseconds: UInt64(retryDelay * 1_000_000_000 * pow(2.0, Double(attempt))))
                }
            } catch {
                throw error // Non-retryable error
            }
        }

        throw lastError ?? NetworkError.unknown
    }
}
```

---

## Data Flow

### Recognition Flow

```
User Points at Appliance
         │
         ▼
Camera Feed → ARKit Scene Understanding
         │
         ▼
Recognition Service
    ├─→ Appliance Classifier (Core ML)
    ├─→ Brand Detector (Core ML)
    └─→ OCR Engine (Vision)
         │
         ▼
Recognized Appliance Entity
         │
         ├─→ Manual Service (Fetch Docs)
         ├─→ Maintenance Service (Generate Schedule)
         └─→ Inventory Service (Save to DB)
         │
         ▼
UI Updates (SwiftUI)
```

### Maintenance Reminder Flow

```
Schedule Generation
         │
         ▼
Maintenance Tasks Created → Core Data
         │
         ▼
Notification Manager
    ├─→ Schedule Local Notifications
    └─→ Calendar API Integration
         │
         ▼
User Receives Notification
         │
         ▼
User Opens App → Task Detail View
         │
         ▼
User Marks Complete
         │
         ├─→ Photo Capture (Optional)
         ├─→ Update Core Data
         └─→ Sync to CloudKit
         │
         ▼
Next Reminder Scheduled
```

### Part Ordering Flow

```
User Points at Broken Part
         │
         ▼
Recognition Service → Part Recognition
         │
         ▼
Parts Service
    ├─→ Amazon API (Search)
    ├─→ eBay API (Search)
    └─→ Manufacturer API (Search)
         │
         ▼
Price Comparison Engine
         │
         ▼
Sorted Listings Display
         │
         ▼
User Selects Listing
         │
         ▼
Affiliate Link Generator
         │
         ▼
Open Safari → External Purchase
         │
         ▼
Track Commission (Analytics)
```

---

## Caching Strategy

### Multi-Level Cache

```
┌─────────────────────────────────────┐
│         Application                  │
└─────────────────────────────────────┘
              │
    ┌─────────┴─────────┐
    ▼                   ▼
┌─────────┐      ┌─────────────┐
│ Memory  │      │  Core Data  │
│ Cache   │◄────►│  (Disk)     │
│ (Fast)  │      │  (Persistent)│
└─────────┘      └─────────────┘
    │                   │
    └─────────┬─────────┘
              ▼
    ┌──────────────────┐
    │   File System    │
    │   (PDF, Images)  │
    └──────────────────┘
              │
              ▼
    ┌──────────────────┐
    │   CloudKit       │
    │   (Sync)         │
    └──────────────────┘
```

### Cache Implementation

```swift
protocol CacheManager {
    func get<T: Codable>(forKey key: String) -> T?
    func set<T: Codable>(_ value: T, forKey key: String, expiration: TimeInterval?)
    func remove(forKey key: String)
    func clear()
}

class TwoLevelCacheManager: CacheManager {
    private let memoryCache = NSCache<NSString, CacheEntry>()
    private let diskCache: DiskCache

    func get<T: Codable>(forKey key: String) -> T? {
        // Try memory first
        if let entry = memoryCache.object(forKey: key as NSString),
           !entry.isExpired {
            return entry.value as? T
        }

        // Fallback to disk
        if let data = diskCache.data(forKey: key),
           let entry = try? JSONDecoder().decode(CacheEntry.self, from: data),
           !entry.isExpired {
            // Promote to memory cache
            memoryCache.setObject(entry, forKey: key as NSString)
            return entry.value as? T
        }

        return nil
    }
}
```

### Cache Policies

**Manuals (PDF)**:
- **Strategy**: Persistent disk cache
- **Expiration**: Never (manual cleanup)
- **Size limit**: 10GB
- **Eviction**: LRU when size exceeded

**API Responses**:
- **Strategy**: Memory + disk cache
- **Expiration**: 1 hour (parts prices), 24 hours (product info)
- **Size limit**: 100MB memory, 500MB disk
- **Eviction**: Time-based + LRU

**Images/Thumbnails**:
- **Strategy**: Memory cache
- **Expiration**: Session-based
- **Size limit**: 50MB
- **Eviction**: LRU

**ML Model Results**:
- **Strategy**: Memory cache
- **Expiration**: 5 minutes
- **Size limit**: 20MB
- **Eviction**: Time-based

**CloudKit Data**:
- **Strategy**: Core Data with CloudKit sync
- **Expiration**: Never (live data)
- **Sync**: Background fetch every 1 hour

---

## Error Handling

### Error Hierarchy

```swift
protocol AppError: Error {
    var title: String { get }
    var message: String { get }
    var recoverySuggestion: String? { get }
    var isRecoverable: Bool { get }
}

enum RecognitionError: AppError {
    case noApplianceDetected
    case lowConfidence(Float)
    case modelLoadFailed
    case imageProcessingFailed

    var title: String {
        switch self {
        case .noApplianceDetected: return "Appliance Not Found"
        case .lowConfidence: return "Uncertain Recognition"
        case .modelLoadFailed: return "Model Error"
        case .imageProcessingFailed: return "Processing Error"
        }
    }

    var message: String { ... }
    var recoverySuggestion: String? { ... }
}

enum ManualError: AppError {
    case notFound
    case downloadFailed
    case corruptedFile
    case insufficientStorage
}

enum MaintenanceError: AppError {
    case scheduleGenerationFailed
    case notificationPermissionDenied
    case calendarAccessDenied
}
```

### Global Error Handler

```swift
class ErrorHandler {
    static let shared = ErrorHandler()

    func handle(_ error: Error, context: String? = nil) {
        // Log error
        logger.error("Error in \(context ?? "unknown"): \(error)")

        // Analytics
        Analytics.trackError(error, context: context)

        // User notification
        if let appError = error as? AppError {
            showUserAlert(appError)
        } else {
            showGenericError()
        }

        // Crash reporting
        if error.isCritical {
            CrashReporter.report(error)
        }
    }

    private func showUserAlert(_ error: AppError) {
        // Present alert through AlertManager
    }
}
```

### ViewModel Error Handling Pattern

```swift
class ApplianceDetailViewModel: ObservableObject {
    @Published var error: AppError?
    @Published var isLoading = false

    func recognizeAppliance() async {
        isLoading = true
        error = nil

        do {
            let result = try await recognitionService.recognize(...)
            // Handle success
        } catch {
            self.error = error as? AppError ?? GenericError(underlying: error)
            ErrorHandler.shared.handle(error, context: "ApplianceRecognition")
        }

        isLoading = false
    }
}
```

---

## Background Processing

### Background Task Types

1. **CloudKit Sync** (hourly)
2. **Manual Downloads** (user-initiated, continue in background)
3. **ML Model Updates** (weekly, during off-peak)
4. **Maintenance Notifications** (scheduled)
5. **Cache Cleanup** (daily)

### Background Task Manager

```swift
class BackgroundTaskManager {
    func scheduleSync() {
        let request = BGAppRefreshTaskRequest(identifier: "com.hmo.sync")
        request.earliestBeginDate = Date(timeIntervalSinceNow: 3600) // 1 hour

        try? BGTaskScheduler.shared.submit(request)
    }

    func handleSyncTask(_ task: BGTask) {
        task.expirationHandler = {
            task.setTaskCompleted(success: false)
        }

        Task {
            do {
                try await cloudSyncManager.sync()
                task.setTaskCompleted(success: true)
            } catch {
                task.setTaskCompleted(success: false)
            }
        }
    }
}
```

### Download Manager

```swift
class DownloadManager {
    private let session: URLSession

    func download(_ url: URL, for manual: Manual) -> AsyncStream<DownloadProgress> {
        AsyncStream { continuation in
            let task = session.downloadTask(with: url)

            // Progress tracking
            let observation = task.progress.observe(\.fractionCompleted) { progress, _ in
                continuation.yield(.progress(progress.fractionCompleted))
            }

            task.resume()

            continuation.onTermination = { _ in
                task.cancel()
                observation.invalidate()
            }
        }
    }
}
```

---

## Performance Considerations

### Memory Management

**Targets**:
- Peak memory: < 2GB
- Average memory: < 1GB
- No memory leaks

**Strategies**:
1. Use weak references in closures
2. Implement proper cache eviction
3. Release large objects promptly
4. Use autoreleasepool for batch operations

```swift
func processLargeDataset(_ items: [Item]) async {
    for item in items {
        autoreleasepool {
            // Process item
            // Auto-released after each iteration
        }
    }
}
```

### Frame Rate Optimization

**Target**: 60fps sustained, 90fps ideal for Vision Pro

**Strategies**:
1. Offload ML inference to background threads
2. Use LOD (Level of Detail) for 3D models
3. Lazy load UI components
4. Virtualize long lists
5. Profile with Instruments regularly

### Battery Impact

**Target**: < 5% battery drain per hour of active use

**Strategies**:
1. Batch network requests
2. Reduce polling frequency
3. Use motion coprocessor data when available
4. Pause non-essential background work
5. Optimize ML model inference

### Startup Time

**Target**: < 2 seconds cold start

**Strategies**:
1. Lazy initialization of services
2. Background loading of non-essential data
3. Precompile ML models
4. Optimize Core Data stack setup

---

## Security Considerations

### API Key Management

```swift
enum Secrets {
    static var amazonAPIKey: String {
        // Loaded from Keychain or secure storage
        KeychainManager.shared.get(key: "amazon_api_key")
    }
}
```

### Data Encryption

- **Keychain**: Sensitive user data (API tokens)
- **Core Data**: Enable NSPersistentStoreFileProtectionCompleteUnlessOpen
- **Files**: Use FileProtectionType.complete for cached manuals
- **Network**: TLS 1.3 only, certificate pinning for critical APIs

---

## Testing Architecture

### Test Pyramid

```
        /\
       /  \      10% - UI Tests (XCUITest)
      /────\
     /      \    30% - Integration Tests
    /────────\
   /          \  60% - Unit Tests (XCTest)
  /────────────\
```

### Mock Services

```swift
class MockRecognitionService: RecognitionServiceProtocol {
    var mockResult: RecognizedAppliance?
    var shouldThrowError = false

    func recognizeAppliance(from image: CGImage) async throws -> RecognizedAppliance {
        if shouldThrowError {
            throw RecognitionError.noApplianceDetected
        }
        return mockResult ?? .default
    }
}
```

---

## Deployment Architecture

### Build Configurations

1. **Debug**: Development, verbose logging
2. **Beta**: TestFlight, analytics enabled
3. **Release**: App Store, optimized, minimal logging

### Feature Flags

```swift
enum FeatureFlags {
    static var enablePredictiveMaintenance: Bool {
        #if DEBUG
        return UserDefaults.standard.bool(forKey: "ff_predictive_maintenance")
        #else
        return RemoteConfig.shared.bool(forKey: "predictive_maintenance")
        #endif
    }
}
```

---

## Monitoring & Analytics

### Key Metrics

1. **Performance**: App launch time, frame rate, memory usage
2. **Engagement**: DAU/MAU, feature usage, session duration
3. **Recognition**: Accuracy rate, confidence scores, fallback rate
4. **Errors**: Crash rate, error frequency by type
5. **Business**: Conversion rate, affiliate clicks, subscription retention

### Analytics Events

```swift
enum AnalyticsEvent {
    case applianceRecognized(type: String, confidence: Float)
    case manualViewed(applianceId: String)
    case tutorialStarted(tutorialId: String)
    case partOrdered(partId: String, source: String)
    case maintenanceCompleted(taskId: String)
}
```

---

## Future Considerations

### Scalability

- Microservices architecture if user base exceeds 1M
- CDN for manual distribution (CloudFront, Akamai)
- Database sharding for large inventory datasets
- Serverless functions for on-demand processing

### Platform Expansion

- iOS companion app (non-spatial version)
- watchOS app for quick maintenance reminders
- macOS app for property managers
- Web dashboard for multi-property management

---

**Document Status**: Ready for Review
**Next Steps**: Review with engineering team, update based on feedback
