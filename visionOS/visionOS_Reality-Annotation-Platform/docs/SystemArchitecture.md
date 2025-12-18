# System Architecture Document
## Reality Annotation Platform

**Version**: 1.0
**Date**: November 2024
**Status**: Draft

---

## 1. Executive Summary

This document defines the system architecture for the Reality Annotation Platform, a visionOS application that enables users to create, manage, and share persistent spatial annotations in physical spaces.

### Key Architectural Decisions
- **Native visionOS app** using SwiftUI and RealityKit
- **CloudKit** for backend storage and synchronization
- **MVVM + Repository pattern** for clean separation of concerns
- **Structured Concurrency** (async/await) throughout
- **Protocol-oriented design** for testability and flexibility

---

## 2. High-Level Architecture

### 2.1 System Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    visionOS Application                      │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌────────────────────────────────────────────────────┐    │
│  │              Presentation Layer                     │    │
│  │  (SwiftUI Views + ViewModels)                      │    │
│  └────────────────────────────────────────────────────┘    │
│                          │                                   │
│  ┌────────────────────────────────────────────────────┐    │
│  │              Business Logic Layer                   │    │
│  │  (Services + Use Cases)                            │    │
│  └────────────────────────────────────────────────────┘    │
│                          │                                   │
│  ┌────────────────────────────────────────────────────┐    │
│  │              Data Layer                             │    │
│  │  (Repositories + Data Sources)                     │    │
│  └────────────────────────────────────────────────────┘    │
│                          │                                   │
│  ┌──────────────┬─────────────┬────────────────────┐      │
│  │   AR Layer   │  Storage    │   Network          │      │
│  │   (ARKit +   │  (SwiftData)│   (CloudKit)       │      │
│  │  RealityKit) │             │                    │      │
│  └──────────────┴─────────────┴────────────────────┘      │
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

### 2.2 Layer Responsibilities

#### **Presentation Layer**
- SwiftUI views and view modifiers
- ViewModels (ObservableObject)
- User interaction handling
- State management
- Navigation coordination

#### **Business Logic Layer**
- Domain logic and business rules
- Service protocols and implementations
- Permission evaluation
- Validation logic
- Event handling

#### **Data Layer**
- Repository pattern implementations
- Local and remote data source abstractions
- Data transformation (DTO ↔ Domain models)
- Caching strategies

#### **Infrastructure Layer**
- ARKit integration (world tracking, anchors)
- RealityKit rendering
- CloudKit operations
- SwiftData persistence
- System frameworks

---

## 3. Module Architecture

### 3.1 Core Modules

```
RealityAnnotationPlatform/
├── App/
│   ├── RealityAnnotationApp.swift
│   └── AppConfiguration.swift
│
├── Presentation/
│   ├── Views/
│   │   ├── ImmersiveView.swift
│   │   ├── AnnotationCreation/
│   │   ├── AnnotationList/
│   │   ├── LayerManagement/
│   │   └── Settings/
│   ├── ViewModels/
│   │   ├── ImmersiveViewModel.swift
│   │   ├── AnnotationViewModel.swift
│   │   └── LayerViewModel.swift
│   └── Components/
│       └── Reusable UI components
│
├── Domain/
│   ├── Models/
│   │   ├── Annotation.swift
│   │   ├── Layer.swift
│   │   ├── User.swift
│   │   ├── Permission.swift
│   │   └── Comment.swift
│   ├── Services/
│   │   ├── AnnotationService.swift
│   │   ├── LayerService.swift
│   │   ├── PermissionService.swift
│   │   ├── SearchService.swift
│   │   └── CollaborationService.swift
│   └── UseCases/
│       ├── CreateAnnotationUseCase.swift
│       ├── DeleteAnnotationUseCase.swift
│       └── ShareAnnotationUseCase.swift
│
├── Data/
│   ├── Repositories/
│   │   ├── AnnotationRepository.swift
│   │   ├── LayerRepository.swift
│   │   └── UserRepository.swift
│   ├── DataSources/
│   │   ├── Local/
│   │   │   └── SwiftDataSource.swift
│   │   └── Remote/
│   │       └── CloudKitDataSource.swift
│   └── DTOs/
│       └── CloudKit record mappings
│
├── AR/
│   ├── ARSessionManager.swift
│   ├── AnchorManager.swift
│   ├── WorldMapManager.swift
│   ├── SpatialTrackingService.swift
│   └── AnnotationRenderer.swift
│
├── Sync/
│   ├── SyncCoordinator.swift
│   ├── ConflictResolver.swift
│   └── OfflineQueueManager.swift
│
└── Utilities/
    ├── Extensions/
    ├── Helpers/
    └── Constants.swift
```

### 3.2 Module Dependencies

```
Presentation → Domain → Data
     ↓           ↓        ↓
    AR ←────────┴────────┴→ Sync
```

**Dependency Rules:**
- Presentation depends on Domain (ViewModels use Services)
- Domain is independent (no framework dependencies)
- Data implements Domain protocols
- AR and Sync are infrastructure modules used by Domain services
- No circular dependencies

---

## 4. Architectural Patterns

### 4.1 MVVM (Model-View-ViewModel)

```swift
// View
struct AnnotationListView: View {
    @StateObject private var viewModel = AnnotationListViewModel()

    var body: some View {
        List(viewModel.annotations) { annotation in
            AnnotationRow(annotation: annotation)
        }
        .task { await viewModel.loadAnnotations() }
    }
}

// ViewModel
@MainActor
class AnnotationListViewModel: ObservableObject {
    @Published var annotations: [Annotation] = []

    private let annotationService: AnnotationService

    init(annotationService: AnnotationService = DefaultAnnotationService()) {
        self.annotationService = annotationService
    }

    func loadAnnotations() async {
        annotations = await annotationService.fetchAnnotations()
    }
}

// Service (Business Logic)
protocol AnnotationService {
    func fetchAnnotations() async -> [Annotation]
}

class DefaultAnnotationService: AnnotationService {
    private let repository: AnnotationRepository

    func fetchAnnotations() async -> [Annotation] {
        return await repository.fetchAll()
    }
}
```

### 4.2 Repository Pattern

```swift
protocol AnnotationRepository {
    func fetchAll() async -> [Annotation]
    func save(_ annotation: Annotation) async throws
    func delete(_ id: UUID) async throws
}

class DefaultAnnotationRepository: AnnotationRepository {
    private let localDataSource: LocalDataSource
    private let remoteDataSource: RemoteDataSource
    private let syncCoordinator: SyncCoordinator

    func fetchAll() async -> [Annotation] {
        // Try local first (fast)
        let local = await localDataSource.fetchAnnotations()

        // Sync in background
        Task {
            await syncCoordinator.sync()
        }

        return local
    }

    func save(_ annotation: Annotation) async throws {
        // Save locally immediately
        try await localDataSource.save(annotation)

        // Queue for remote sync
        await syncCoordinator.queueForSync(annotation)
    }
}
```

### 4.3 Protocol-Oriented Design

All major components defined by protocols for:
- **Testability**: Easy mocking
- **Flexibility**: Swap implementations
- **Dependency Injection**: Loose coupling

```swift
protocol ARSessionManager {
    var worldTrackingState: ARTrackingState { get }
    func startSession() async
    func stopSession()
    func addAnchor(at position: SIMD3<Float>) async throws -> ARAnchor
}

protocol SyncCoordinator {
    func sync() async
    func queueForSync<T: Syncable>(_ item: T) async
}
```

---

## 5. Data Flow

### 5.1 Annotation Creation Flow

```
User Interaction
    ↓
[ImmersiveView] ──tap gesture──→ [ImmersiveViewModel]
    ↓
[ViewModel.createAnnotation()] ──→ [AnnotationService]
    ↓
[Service validates & processes] ──→ [AnnotationRepository]
    ↓
[Repository.save()]
    ├──→ [LocalDataSource.save()] ── SwiftData → Local DB
    └──→ [SyncCoordinator.queue()] ── Background → CloudKit
    ↓
[AnnotationRenderer] ← notified via Combine/AsyncStream
    ↓
RealityKit Entity created at ARanchor position
```

### 5.2 Sync Flow (Background)

```
[SyncCoordinator] ← timer/network change
    ↓
Check network availability
    ↓
[CloudKitDataSource.fetchChanges()]
    ↓
Fetch CKRecords with change token
    ↓
[ConflictResolver.resolve()] if conflicts
    ↓
[LocalDataSource.update()] ← save to local DB
    ↓
Notify ViewModels via Combine publishers
    ↓
UI updates automatically (@Published)
```

---

## 6. Technology Stack

### 6.1 Core Technologies

| Layer | Technology | Purpose |
|-------|-----------|---------|
| UI Framework | SwiftUI | Declarative UI, visionOS optimized |
| 3D Rendering | RealityKit | Spatial rendering of annotations |
| AR Foundation | ARKit | World tracking, spatial anchors |
| Backend | CloudKit | Cloud storage, sync, authentication |
| Local Storage | SwiftData | On-device persistence |
| Concurrency | Swift Concurrency | async/await, actors, tasks |
| Networking | CloudKit API | Push notifications, subscriptions |

### 6.2 Apple Frameworks

```swift
import SwiftUI           // UI layer
import RealityKit        // 3D rendering
import ARKit             // Spatial tracking
import CloudKit          // Backend
import SwiftData         // Local persistence
import Combine           // Reactive streams
import Observation       // Observable macro (iOS 17+)
```

### 6.3 visionOS-Specific APIs

```swift
import RealityKitContent // Reality Composer Pro content
import CompositorServices // Custom rendering if needed
```

---

## 7. State Management

### 7.1 App-Level State

```swift
@MainActor
class AppState: ObservableObject {
    @Published var currentUser: User?
    @Published var isAuthenticated = false
    @Published var activeLayers: Set<UUID> = []
    @Published var arSessionState: ARSessionState = .notStarted

    // Shared across app
    static let shared = AppState()
}
```

### 7.2 View-Level State

- Use `@State` for local, transient state
- Use `@StateObject` for view-owned ViewModels
- Use `@ObservedObject` for injected ViewModels
- Use `@EnvironmentObject` for app-wide state

### 7.3 Persistence State

- SwiftData `ModelContext` injected via environment
- CloudKit subscriptions for real-time updates
- Combine publishers for reactive updates

---

## 8. Navigation Architecture

### 8.1 visionOS Window Scenes

```swift
@main
struct RealityAnnotationApp: App {
    @StateObject private var appState = AppState.shared

    var body: some Scene {
        // Main window for 2D UI
        WindowGroup {
            ContentView()
                .environmentObject(appState)
        }

        // Immersive space for AR
        ImmersiveSpace(id: "ImmersiveSpace") {
            ImmersiveView()
                .environmentObject(appState)
        }
        .immersionStyle(selection: .constant(.mixed), in: .mixed)
    }
}
```

### 8.2 Navigation Pattern

```
ContentView (WindowGroup)
    ├── NavigationStack for list views
    ├── Sheet modals for creation/editing
    └── Toggle to ImmersiveSpace

ImmersiveView (ImmersiveSpace)
    ├── RealityView for spatial content
    └── Attachments for 3D UI elements
```

---

## 9. Dependency Injection

### 9.1 Service Container

```swift
class ServiceContainer {
    static let shared = ServiceContainer()

    // Singletons
    lazy var annotationService: AnnotationService = {
        DefaultAnnotationService(repository: annotationRepository)
    }()

    lazy var annotationRepository: AnnotationRepository = {
        DefaultAnnotationRepository(
            localDataSource: localDataSource,
            remoteDataSource: cloudKitDataSource,
            syncCoordinator: syncCoordinator
        )
    }()

    lazy var arSessionManager: ARSessionManager = {
        DefaultARSessionManager()
    }()

    // ... other services
}
```

### 9.2 ViewModel Injection

```swift
// Production
let viewModel = AnnotationListViewModel(
    annotationService: ServiceContainer.shared.annotationService
)

// Testing
let viewModel = AnnotationListViewModel(
    annotationService: MockAnnotationService()
)
```

---

## 10. Error Handling

### 10.1 Error Types

```swift
enum AnnotationError: LocalizedError {
    case notFound(UUID)
    case permissionDenied
    case invalidContent
    case syncFailed(underlying: Error)
    case arSessionFailed

    var errorDescription: String? {
        switch self {
        case .notFound(let id):
            return "Annotation \(id) not found"
        case .permissionDenied:
            return "You don't have permission to perform this action"
        case .invalidContent:
            return "Invalid annotation content"
        case .syncFailed(let error):
            return "Sync failed: \(error.localizedDescription)"
        case .arSessionFailed:
            return "AR session failed to start"
        }
    }
}
```

### 10.2 Error Propagation

```swift
// Services throw errors
func createAnnotation(_ content: String) async throws -> Annotation {
    guard !content.isEmpty else {
        throw AnnotationError.invalidContent
    }
    // ... create annotation
}

// ViewModels catch and present
func createAnnotation(content: String) async {
    do {
        let annotation = try await annotationService.createAnnotation(content)
        // Success
    } catch {
        errorMessage = error.localizedDescription
        showError = true
    }
}
```

---

## 11. Performance Considerations

### 11.1 Rendering Optimization

- **LOD (Level of Detail)**: Show simplified annotations when far away
- **Culling**: Don't render annotations outside view frustum
- **Batching**: Batch similar annotations into single RealityKit entity
- **Lazy Loading**: Load annotation content on-demand

### 11.2 Memory Management

- **Weak references** in closures to prevent retain cycles
- **Unload distant annotations** from memory (keep metadata only)
- **Image downsampling** for photo annotations
- **Cancel tasks** when views disappear

### 11.3 Network Optimization

- **Batch CloudKit operations** (fetch/save multiple records)
- **Use CKQueryOperation** for large queries
- **Implement pagination** for search results
- **Cache aggressively** with TTL

---

## 12. Security Architecture

### 12.1 Authentication

- **Sign in with Apple** (CloudKit user identity)
- **CKContainer.default().accountStatus** check
- User record created on first launch

### 12.2 Authorization

- CloudKit permissions (private/shared/public databases)
- Custom permission evaluation in `PermissionService`
- ACL checks before operations

### 12.3 Data Protection

- CloudKit encryption at rest and in transit
- Sensitive data in Keychain (if needed)
- Privacy-preserving location storage (no GPS coordinates in cloud)

---

## 13. Testing Strategy

### 13.1 Unit Tests

- Test ViewModels with mock services
- Test Services with mock repositories
- Test business logic in isolation
- **Target**: 80% code coverage

### 13.2 Integration Tests

- Test Repository + DataSource integration
- Test CloudKit operations (using test container)
- Test AR session management

### 13.3 UI Tests

- Critical user flows (create annotation, share, search)
- visionOS simulator support

---

## 14. Scalability

### 14.1 Current Limits

- Max 100 annotations rendered simultaneously
- Max 1000 annotations per space (local DB)
- No hard limit on cloud storage

### 14.2 Future Scaling

- **Spatial partitioning**: Divide space into chunks, load on-demand
- **Server-side processing**: Offload complex operations
- **CDN**: Cache public annotation media
- **Database sharding**: Separate hot/cold data

---

## 15. Deployment

### 15.1 Build Configurations

- **Debug**: Local CloudKit development container
- **TestFlight**: CloudKit development environment
- **Release**: CloudKit production environment

### 15.2 Continuous Integration

- GitHub Actions for automated builds
- Unit test execution on every PR
- TestFlight distribution for beta testers

---

## 16. Monitoring & Analytics

### 16.1 Logging

```swift
import OSLog

let logger = Logger(subsystem: "com.example.RealityAnnotation", category: "AR")

logger.info("AR session started")
logger.error("Failed to create anchor: \(error)")
```

### 16.2 Crash Reporting

- Use CloudKit Telemetry (built-in)
- Consider third-party: Sentry, Crashlytics

### 16.3 Analytics

- Track key events (annotation created, shared, etc.)
- Privacy-first: No PII, aggregate data only
- Use CloudKit telemetry or TelemetryDeck

---

## 17. Documentation Standards

### 17.1 Code Documentation

```swift
/// Creates a new spatial annotation at the specified position.
///
/// - Parameters:
///   - content: The text content of the annotation
///   - position: The 3D position in world coordinates
///   - layer: The layer to which this annotation belongs
/// - Returns: The created annotation
/// - Throws: `AnnotationError.invalidContent` if content is empty
func createAnnotation(
    content: String,
    position: SIMD3<Float>,
    layer: Layer
) async throws -> Annotation
```

### 17.2 Architecture Decision Records (ADRs)

- Document major decisions in `docs/adr/` folder
- Use numbered format: `001-use-cloudkit.md`

---

## 18. Future Considerations

### 18.1 Planned Enhancements

- **Multi-platform**: iOS companion app (view/create from phone)
- **SharePlay**: Real-time collaboration in shared space
- **ML Features**: Object recognition for smart anchoring
- **API**: Public API for third-party integrations

### 18.2 Technical Debt Tracking

- Use `// TODO:` comments with ticket numbers
- Track in GitHub Issues with `tech-debt` label
- Address during dedicated refactoring sprints

---

## 19. Appendix

### 19.1 Key Design Principles

1. **Separation of Concerns**: Clear layer boundaries
2. **Dependency Inversion**: Depend on abstractions, not concretions
3. **Single Responsibility**: Each class has one reason to change
4. **Open/Closed**: Open for extension, closed for modification
5. **Protocol-Oriented**: Prefer protocols over concrete classes

### 19.2 Code Style

- Follow Swift API Design Guidelines
- Use SwiftLint for consistency
- SwiftFormat for automatic formatting

### 19.3 References

- [Apple visionOS Documentation](https://developer.apple.com/visionos/)
- [RealityKit Documentation](https://developer.apple.com/documentation/realitykit)
- [CloudKit Best Practices](https://developer.apple.com/documentation/cloudkit)
- [Swift Concurrency](https://docs.swift.org/swift-book/LanguageGuide/Concurrency.html)

---

**Document Status**: ✅ Ready for Implementation
**Next Steps**: Create Data Model & Schema Design document
