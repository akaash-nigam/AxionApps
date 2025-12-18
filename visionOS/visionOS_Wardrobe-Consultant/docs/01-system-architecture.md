# System Architecture & Technical Design

## Document Overview

**Version**: 1.0
**Last Updated**: 2025-11-24
**Status**: Draft

## 1. Executive Summary

This document defines the technical architecture for Wardrobe Consultant, a visionOS application that provides AI-powered styling recommendations with virtual try-on capabilities. The architecture prioritizes performance (60fps AR rendering), user privacy (on-device processing), and scalability.

## 2. High-Level Architecture

### 2.1 Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                        visionOS Application                      │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │                    Presentation Layer                       │ │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐    │ │
│  │  │   SwiftUI    │  │  RealityKit  │  │  ARKit Views │    │ │
│  │  │    Views     │  │    Scenes    │  │              │    │ │
│  │  └──────────────┘  └──────────────┘  └──────────────┘    │ │
│  └────────────────────────────────────────────────────────────┘ │
│                              │                                   │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │                   Application Layer                         │ │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐    │ │
│  │  │  View Models │  │  Coordinators│  │  Use Cases   │    │ │
│  │  │   (MVVM)     │  │              │  │              │    │ │
│  │  └──────────────┘  └──────────────┘  └──────────────┘    │ │
│  └────────────────────────────────────────────────────────────┘ │
│                              │                                   │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │                    Domain Layer                             │ │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐    │ │
│  │  │   Entities   │  │  Repositories│  │   Services   │    │ │
│  │  │              │  │  (Protocol)  │  │  (Protocol)  │    │ │
│  │  └──────────────┘  └──────────────┘  └──────────────┘    │ │
│  └────────────────────────────────────────────────────────────┘ │
│                              │                                   │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │                Infrastructure Layer                         │ │
│  │  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐     │ │
│  │  │Core Data │ │ARKit Mgr │ │ML Engine │ │3D Render │     │ │
│  │  └──────────┘ └──────────┘ └──────────┘ └──────────┘     │ │
│  └────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
                              │
          ┌───────────────────┼───────────────────┐
          │                   │                   │
┌─────────▼────────┐ ┌────────▼────────┐ ┌───────▼────────┐
│   CloudKit       │ │  External APIs  │ │  Device APIs   │
│  - Wardrobe Sync │ │  - WeatherKit   │ │  - Camera      │
│  - User Profile  │ │  - EventKit     │ │  - Location    │
│  - Outfit History│ │  - Retailers    │ │  - Photos      │
└──────────────────┘ └─────────────────┘ └────────────────┘
```

### 2.2 Architectural Style

**Clean Architecture with MVVM Pattern**

- **Presentation Layer**: SwiftUI Views + ViewModels
- **Application Layer**: Use Cases, Coordinators, Business Logic
- **Domain Layer**: Core business entities and protocols
- **Infrastructure Layer**: Framework-specific implementations

**Benefits**:
- Testability: Business logic isolated from UI and frameworks
- Maintainability: Clear separation of concerns
- Flexibility: Easy to swap implementations (e.g., Core Data → Realm)
- Scalability: Modular structure supports feature growth

## 3. Component Breakdown

### 3.1 Presentation Layer Components

#### SwiftUI Views
- **MainView**: Root container, manages navigation state
- **OutfitSuggestionView**: Spatial grid of outfit recommendations
- **VirtualTryOnView**: AR preview of clothing on user's body
- **WardrobeView**: Digital closet interface
- **ShoppingView**: Virtual try-on for online products
- **SettingsView**: App configuration and preferences

#### RealityKit Scenes
- **VirtualMirrorScene**: Central AR scene with body tracking
- **ClothingEntityFactory**: Creates 3D clothing entities
- **OutfitSpatialLayout**: Arranges outfit cards in 3D space

### 3.2 Application Layer Components

#### ViewModels
- **OutfitSuggestionViewModel**: Manages outfit recommendations
- **VirtualTryOnViewModel**: Handles try-on state and interactions
- **WardrobeViewModel**: Wardrobe management and filtering
- **ShoppingViewModel**: Shopping assistant features

#### Coordinators
- **AppCoordinator**: Root navigation coordinator
- **OnboardingCoordinator**: First-run experience flow
- **ShoppingCoordinator**: Shopping feature navigation

#### Use Cases
- **GenerateOutfitSuggestionsUseCase**: AI-powered outfit generation
- **VirtualTryOnUseCase**: Apply clothing to body tracking
- **AddWardrobeItemUseCase**: Catalog new clothing
- **CheckDressCodeUseCase**: Analyze calendar events

### 3.3 Domain Layer Components

#### Entities
- **WardrobeItem**: Clothing piece with metadata
- **Outfit**: Combination of wardrobe items
- **UserProfile**: User preferences and measurements
- **StyleRecommendation**: AI-generated suggestion
- **Event**: Calendar event with dress code

#### Repository Protocols
- **WardrobeRepository**: CRUD operations for wardrobe
- **OutfitRepository**: Outfit storage and retrieval
- **UserProfileRepository**: User data management

#### Service Protocols
- **StyleRecommendationService**: AI styling engine
- **WeatherService**: Weather data retrieval
- **CalendarService**: Event access
- **BodyTrackingService**: AR body tracking
- **ClothingRenderingService**: 3D visualization

### 3.4 Infrastructure Layer Components

#### Core Data Stack
- **PersistenceController**: Core Data setup and configuration
- **CoreDataWardrobeRepository**: Concrete repository implementation
- **CoreDataMigrationManager**: Schema version management

#### ARKit Manager
- **ARBodyTrackingManager**: Manages ARSession and body anchors
- **PersonSegmentationManager**: Body masking for clothing overlay
- **BodyMeasurementEstimator**: Extracts body dimensions

#### ML Engine
- **StyleRecommendationModel**: Core ML model for outfit suggestions
- **ClothingClassificationModel**: Image → clothing attributes
- **ColorHarmonyEngine**: Rule-based color matching
- **SizeRecommendationModel**: Fit prediction

#### 3D Rendering Engine
- **ClothingModelLoader**: Loads 3D models (USDZ/GLB)
- **FabricShaderLibrary**: Metal shaders for materials
- **ClothSimulationEngine**: Physics-based draping
- **LightingManager**: Realistic lighting setup

## 4. Data Flow Diagrams

### 4.1 Outfit Suggestion Flow

```
User opens app
      │
      ▼
┌─────────────────┐
│  MainView       │
│  - Check time   │
│  - Fetch weather│
│  - Get calendar │
└─────────────────┘
      │
      ▼
┌──────────────────────────────┐
│ OutfitSuggestionViewModel    │
│ - Calls UseCase              │
└──────────────────────────────┘
      │
      ▼
┌──────────────────────────────┐
│ GenerateOutfitSuggestionsUC  │
│ 1. Get wardrobe items        │
│ 2. Get weather context       │
│ 3. Get calendar events       │
│ 4. Get user style profile    │
└──────────────────────────────┘
      │
      ├─────────┬────────────┬────────────┐
      ▼         ▼            ▼            ▼
┌──────────┐ ┌────────┐ ┌─────────┐ ┌──────────┐
│Wardrobe  │ │Weather │ │Calendar │ │User      │
│Repository│ │Service │ │Service  │ │Profile   │
└──────────┘ └────────┘ └─────────┘ └──────────┘
      │         │            │            │
      └─────────┴────────────┴────────────┘
                     │
                     ▼
        ┌─────────────────────────┐
        │ StyleRecommendationSvc  │
        │ - ML model inference    │
        │ - Color harmony rules   │
        │ - Occasion matching     │
        └─────────────────────────┘
                     │
                     ▼
        ┌─────────────────────────┐
        │ Outfit Suggestions      │
        │ [Outfit1, Outfit2, ...] │
        └─────────────────────────┘
                     │
                     ▼
        ┌─────────────────────────┐
        │ OutfitSuggestionView    │
        │ Display in spatial grid │
        └─────────────────────────┘
```

### 4.2 Virtual Try-On Flow

```
User selects outfit
      │
      ▼
┌─────────────────────────┐
│ VirtualTryOnViewModel   │
│ - Start AR session      │
│ - Load clothing 3D data │
└─────────────────────────┘
      │
      ├────────────┬───────────────┐
      ▼            ▼               ▼
┌──────────┐ ┌─────────────┐ ┌────────────┐
│ARBody    │ │Clothing     │ │3D Render   │
│Tracking  │ │Model Loader │ │Engine      │
└──────────┘ └─────────────┘ └────────────┘
      │            │               │
      └────────────┴───────────────┘
                   │
                   ▼
      ┌────────────────────────┐
      │ ClothingEntity         │
      │ - Position on body     │
      │ - Apply physics        │
      │ - Apply fabric shader  │
      └────────────────────────┘
                   │
                   ▼
      ┌────────────────────────┐
      │ RealityKit Render Loop │
      │ - Update at 60fps      │
      │ - Track body movement  │
      └────────────────────────┘
                   │
                   ▼
      ┌────────────────────────┐
      │ VirtualTryOnView       │
      │ Display AR scene       │
      └────────────────────────┘
```

### 4.3 Wardrobe Item Addition Flow

```
User captures photo
      │
      ▼
┌─────────────────────────┐
│ Camera / Photo Picker   │
│ - Capture clothing photo│
└─────────────────────────┘
      │
      ▼
┌─────────────────────────┐
│ AddWardrobeItemUseCase  │
│ 1. Process image        │
│ 2. Classify clothing    │
│ 3. Extract attributes   │
│ 4. Save to repository   │
└─────────────────────────┘
      │
      ├─────────────┬─────────────┐
      ▼             ▼             ▼
┌──────────────┐ ┌─────────┐ ┌──────────┐
│ML Engine     │ │Vision   │ │Image     │
│- Clothing    │ │Framework│ │Processing│
│  Classifier  │ │- OCR    │ │- Crop    │
└──────────────┘ └─────────┘ └──────────┘
      │             │             │
      └─────────────┴─────────────┘
                    │
                    ▼
      ┌─────────────────────────┐
      │ WardrobeItem Entity     │
      │ - Category: "Shirt"     │
      │ - Color: "Blue"         │
      │ - Brand: "J.Crew"       │
      │ - Photo: compressed     │
      └─────────────────────────┘
                    │
                    ▼
      ┌─────────────────────────┐
      │ WardrobeRepository      │
      │ - Save to Core Data     │
      │ - Sync to CloudKit      │
      └─────────────────────────┘
```

## 5. Concurrency & Threading Model

### 5.1 Thread Strategy

**Main Thread (MainActor)**:
- All SwiftUI view updates
- RealityKit scene updates
- ARSession delegate callbacks
- User interaction handling

**Background Threads**:
- Core Data operations (private context)
- ML model inference
- Image processing
- Network requests
- CloudKit sync

**Metal Render Thread**:
- Fabric shader execution
- 3D model rendering
- Physics simulation

### 5.2 Concurrency Patterns

```swift
// Modern Swift Concurrency (async/await)

@MainActor
class OutfitSuggestionViewModel: ObservableObject {
    @Published var outfits: [Outfit] = []
    @Published var isLoading = false

    private let useCase: GenerateOutfitSuggestionsUseCase

    func loadSuggestions() async {
        isLoading = true
        defer { isLoading = false }

        do {
            // Background work happens in UseCase
            let suggestions = try await useCase.execute()
            // Update UI on main thread (MainActor ensures this)
            self.outfits = suggestions
        } catch {
            // Handle error
        }
    }
}

// UseCase runs heavy work off main thread
class GenerateOutfitSuggestionsUseCase {
    func execute() async throws -> [Outfit] {
        // Parallel fetch of context data
        async let wardrobeItems = wardrobeRepository.fetchAll()
        async let weather = weatherService.getCurrentWeather()
        async let events = calendarService.getTodayEvents()
        async let profile = profileRepository.fetch()

        let (items, weatherData, calendarEvents, userProfile) =
            try await (wardrobeItems, weather, events, profile)

        // ML inference (CPU-intensive, runs on background)
        return try await styleRecommendationService.generateOutfits(
            wardrobe: items,
            weather: weatherData,
            events: calendarEvents,
            profile: userProfile
        )
    }
}
```

### 5.3 Critical Performance Paths

**AR Rendering (60fps requirement)**:
- Body tracking updates: ARSession delegate → immediate processing
- Clothing entity updates: RealityKit update loop → 16ms budget
- Physics simulation: Metal compute shader → async
- Avoid main thread blocking: No heavy computation in render loop

**App Launch**:
- Load Core Data stack: < 500ms
- Initialize AR session: < 1s
- First outfit suggestion: < 3s

## 6. Error Handling & Recovery

### 6.1 Error Categories

```swift
enum WardrobeConsultantError: Error {
    // Domain Errors
    case emptyWardrobe
    case invalidBodyMeasurements
    case noOutfitSuggestionsAvailable

    // Infrastructure Errors
    case arSessionUnavailable
    case cameraPermissionDenied
    case coreDataFailed(underlying: Error)
    case cloudKitSyncFailed(underlying: Error)
    case networkRequestFailed(underlying: Error)

    // ML Errors
    case modelLoadingFailed
    case inferenceFailed(underlying: Error)

    // 3D Rendering Errors
    case modelLoadingFailed(url: URL)
    case shaderCompilationFailed
    case insufficientGPUResources
}
```

### 6.2 Recovery Strategies

| Error | User Impact | Recovery Strategy |
|-------|-------------|-------------------|
| Empty wardrobe | High | Show onboarding, prompt to add items |
| AR unavailable | High | Fallback to 2D photo mode, check device support |
| Network failure | Medium | Show cached data, retry with exponential backoff |
| CloudKit sync fail | Low | Queue for later sync, notify user |
| ML model failure | Medium | Use rule-based fallback algorithm |
| 3D model loading fail | Low | Show placeholder, retry once |

### 6.3 Graceful Degradation

**No Internet**:
- Outfit suggestions: Use cached weather, skip event integration
- Shopping: Disable feature, show saved wishlist
- Wardrobe: Full functionality (local Core Data)

**Low Battery**:
- Reduce AR frame rate: 60fps → 30fps
- Disable cloth physics: Static overlay
- Simplify shaders: Basic materials

**Low Storage**:
- Compress wardrobe photos more aggressively
- Purge old 3D model cache
- Warn user before adding new items

## 7. Caching Strategy

### 7.1 Cache Layers

**L1 Cache: In-Memory**
- Currently displayed outfit suggestions (10-20 objects)
- Active 3D clothing models (2-3 models)
- User profile (single object)
- Lifetime: App session

**L2 Cache: Core Data**
- All wardrobe items (persistent)
- Outfit history (30 days)
- Weather data (24 hours)
- Calendar events (7 days)
- Lifetime: Variable TTL

**L3 Cache: File System**
- 3D clothing models (USDZ files)
- Compressed wardrobe photos
- ML model files
- Lifetime: 30 days (LRU eviction)

### 7.2 Cache Invalidation

**Time-based**:
- Weather: 1 hour
- Calendar events: 15 minutes
- 3D models: 30 days

**Event-based**:
- Wardrobe item changed → invalidate outfit suggestions
- User profile updated → invalidate ML cache
- Outfit worn → update wear history

**Size-based**:
- 3D model cache: Max 500MB
- Photo cache: Max 2GB
- Eviction: LRU (Least Recently Used)

## 8. Offline Capabilities & Sync

### 8.1 Offline-First Features

**Fully Functional Offline**:
- View wardrobe
- Browse saved outfit suggestions
- Virtual try-on (existing wardrobe)
- Add new wardrobe items
- Outfit history

**Limited Offline**:
- Outfit suggestions (no weather/calendar context)
- Shopping (saved wishlist only, no new items)

**Requires Internet**:
- Weather integration
- Calendar sync
- Shopping assistant
- CloudKit sync

### 8.2 Sync Mechanism

**CloudKit Private Database**:
- Sync wardrobe items (CKRecord per item)
- Sync outfit history
- Sync user profile

**Sync Triggers**:
- App launch (if online)
- Every 15 minutes (background)
- After user action (wardrobe change)

**Conflict Resolution**:
- Last-write-wins for user profile
- Merge outfit history (union)
- Keep both for wardrobe (user resolves)

**Sync State**:
```swift
enum SyncState {
    case synced
    case syncing
    case pendingChanges(count: Int)
    case error(WardrobeConsultantError)
}
```

## 9. Security Architecture

### 9.1 Data Security

**On-Device Encryption**:
- Core Data: NSFileProtectionComplete
- Photos: Encrypted file system
- Body measurements: Keychain storage
- User preferences: UserDefaults (not sensitive)

**Network Security**:
- TLS 1.3 for all API calls
- Certificate pinning for critical APIs
- Token-based authentication (JWT)

**CloudKit Security**:
- Private database (user-scoped)
- Encrypted at rest (Apple managed)
- Encrypted in transit

### 9.2 Privacy-First Design

**On-Device Processing**:
- Body measurements: Never leave device
- AR body tracking: Local processing only
- ML inference: On-device Core ML
- Photo analysis: Local Vision framework

**Minimal Data Collection**:
- No analytics without consent
- No third-party tracking
- No personally identifiable info in logs

**User Control**:
- Export all data (GDPR compliance)
- Delete account and all data
- Opt-out of CloudKit sync

## 10. Scalability Considerations

### 10.1 Data Growth

**Wardrobe Items**:
- Expected: 100-500 items per user
- Max supported: 2,000 items
- Strategy: Pagination, lazy loading, indexing

**3D Models**:
- Cache limit: 500MB
- LRU eviction
- Compressed USDZ format

**Photos**:
- HEIC compression (50-70% size reduction)
- Progressive JPEG for thumbnails
- Max 2GB per user

### 10.2 Performance at Scale

**Core Data Optimization**:
- Batch fetching (50 items at a time)
- Faulting for relationships
- Indexing on: category, color, lastWornDate
- Background context for writes

**ML Model Optimization**:
- Model quantization (Float16)
- Batch inference when possible
- Caching of feature vectors

## 11. Monitoring & Observability

### 11.1 Logging Strategy

**Log Levels**:
- Error: Critical failures (AR session lost, Core Data corruption)
- Warning: Recoverable issues (network timeout, cache miss)
- Info: Key user actions (outfit selected, item added)
- Debug: Detailed flow (disabled in production)

**Log Categories**:
```swift
extension Logger {
    static let arTracking = Logger(subsystem: "com.wardrobeconsultant", category: "ARTracking")
    static let mlInference = Logger(subsystem: "com.wardrobeconsultant", category: "MLInference")
    static let persistence = Logger(subsystem: "com.wardrobeconsultant", category: "Persistence")
    static let networking = Logger(subsystem: "com.wardrobeconsultant", category: "Networking")
}
```

### 11.2 Performance Metrics

**Tracked Metrics**:
- App launch time
- AR session initialization time
- Outfit suggestion generation time
- Virtual try-on load time
- Frame rate (AR rendering)
- Memory usage
- Battery impact
- Network request latency

**Tools**:
- MetricKit for system metrics
- Custom timing instrumentation
- Xcode Instruments profiles

## 12. Deployment Architecture

### 12.1 Build Configurations

**Debug**:
- Verbose logging enabled
- No optimization
- Debug symbols included
- Test data seeded

**Release**:
- Minimal logging (errors only)
- Full optimization (-O)
- Symbols stripped
- App Store submission

**TestFlight**:
- Release build + crash reporting
- Analytics enabled
- Feature flags for beta features

### 12.2 Feature Flags

```swift
enum FeatureFlag: String {
    case advancedClothPhysics
    case retailerIntegrations
    case socialSharing
    case voiceCommands

    var isEnabled: Bool {
        // Remote config or local override
        RemoteConfig.shared.isEnabled(self) ?? defaultValue
    }
}
```

**Benefits**:
- Gradual rollout of features
- A/B testing
- Kill switch for problematic features
- Beta features for TestFlight

## 13. Dependency Management

### 13.1 External Dependencies

**Apple Frameworks** (Native):
- SwiftUI, RealityKit, ARKit
- Core Data, CloudKit
- Core ML, Vision
- WeatherKit, EventKit
- PhotosUI, AVFoundation

**Third-Party (Minimal)**:
- None for MVP (keep dependencies low)

**Potential Future**:
- Firebase (analytics, remote config)
- Alamofire (networking, if needed)
- Kingfisher (async image loading)

### 13.2 Version Control

- Semantic versioning: MAJOR.MINOR.PATCH
- Git branching: main, develop, feature/*
- Pull request reviews required
- CI/CD: GitHub Actions for testing

## 14. Technology Stack Summary

| Layer | Technology | Purpose |
|-------|-----------|---------|
| UI | SwiftUI | Declarative UI |
| 3D/AR | RealityKit, ARKit | Body tracking, 3D rendering |
| ML | Core ML | On-device inference |
| Data | Core Data | Local persistence |
| Sync | CloudKit | Cloud storage |
| Weather | WeatherKit | Weather data |
| Calendar | EventKit | Calendar access |
| Image | Vision, CoreImage | Image analysis |
| Networking | URLSession | API calls |
| Concurrency | Swift Concurrency | async/await |
| Testing | XCTest, ViewInspector | Unit/UI tests |

## 15. Next Steps

Before implementation:
1. ✅ Review this architecture with team
2. ⬜ Create data model schemas (next doc)
3. ⬜ Define API contracts
4. ⬜ Design UI wireframes
5. ⬜ Prototype AR body tracking
6. ⬜ Validate ML model approach

---

**Document Status**: Draft - Ready for Review
**Next Document**: Data Models & Database Schema Design
