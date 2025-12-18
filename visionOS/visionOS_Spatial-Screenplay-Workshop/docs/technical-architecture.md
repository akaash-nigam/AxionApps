# Technical Architecture Document

## Overview

This document defines the technical architecture for Spatial Screenplay Workshop, a visionOS application that provides an immersive screenwriting experience using spatial computing.

## System Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        Presentation Layer                    │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │   SwiftUI    │  │  RealityKit  │  │    ARKit     │     │
│  │   Views      │  │   Scenes     │  │  Tracking    │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
└─────────────────────────────────────────────────────────────┘
                              │
┌─────────────────────────────────────────────────────────────┐
│                      Application Layer                       │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │   View       │  │  Spatial     │  │  Gesture     │     │
│  │   Models     │  │  Manager     │  │  Handler     │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
└─────────────────────────────────────────────────────────────┘
                              │
┌─────────────────────────────────────────────────────────────┐
│                        Business Layer                        │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │  Script      │  │  Character   │  │  Location    │     │
│  │  Engine      │  │  Manager     │  │  Manager     │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │  Storyboard  │  │Collaboration │  │   Export     │     │
│  │  Manager     │  │  Engine      │  │  Manager     │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
└─────────────────────────────────────────────────────────────┘
                              │
┌─────────────────────────────────────────────────────────────┐
│                       Data Layer                             │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │  SwiftData   │  │  CloudKit    │  │  File        │     │
│  │  Store       │  │  Sync        │  │  Manager     │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
└─────────────────────────────────────────────────────────────┘
                              │
┌─────────────────────────────────────────────────────────────┐
│                     External Services                        │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │     TTS      │  │  AI Image    │  │  3D Asset    │     │
│  │   Service    │  │  Generation  │  │  Library     │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
└─────────────────────────────────────────────────────────────┘
```

## Layer Details

### 1. Presentation Layer

#### SwiftUI Views

**Purpose**: User interface and interaction components

**Key Components**:
- `ProjectHomeView`: Main project dashboard
- `TimelineView`: 3D scene card timeline
- `ScriptEditorView`: Text-based script editing
- `CharacterPerformanceView`: Life-sized character dialogue
- `LocationScoutView`: Virtual location exploration
- `StoryboardEditorView`: Storyboard creation and animation
- `CollaborationView`: Multi-user session UI

**Patterns**:
- MVVM (Model-View-ViewModel)
- Unidirectional data flow
- Observable objects for state management
- Environment objects for shared state

#### RealityKit Scenes

**Purpose**: 3D spatial content rendering

**Key Systems**:
- Scene card rendering system
- Character avatar rendering
- Environment rendering
- Spatial audio positioning
- Animation system

**Structure**:
```swift
RealityViewContent
├── TimelineEntity (root)
│   ├── ActIContainer
│   │   ├── SceneCard1
│   │   ├── SceneCard2
│   │   └── ...
│   ├── ActIIContainer
│   └── ActIIIContainer
├── CharacterPerformanceEntity
│   ├── Character1Avatar
│   └── Character2Avatar
└── EnvironmentEntity
    ├── LocationModel
    ├── Lighting
    └── Effects
```

#### ARKit Integration

**Purpose**: Spatial tracking and scene understanding

**Features**:
- World tracking
- Plane detection (horizontal/vertical)
- Scene reconstruction
- Hand tracking for gestures
- Eye tracking for gaze-based selection

### 2. Application Layer

#### View Models

**Purpose**: Bridge between views and business logic

**Key View Models**:

```swift
@Observable
class ProjectViewModel {
    var project: Project
    var scriptEngine: ScriptEngine
    var undoManager: UndoManager

    func addScene()
    func deleteScene(id: UUID)
    func moveScene(from: Int, to: Int)
    func updateScene(id: UUID, content: SceneContent)
}

@Observable
class TimelineViewModel {
    var scenes: [Scene]
    var spatialLayout: SpatialLayout
    var colorCoding: ColorCodingMode

    func layoutScenes() -> [SceneCardPosition]
    func updateScenePosition(id: UUID, position: SpatialCoordinates)
    func filterScenes(by: FilterCriteria)
}

@Observable
class CharacterViewModel {
    var characters: [Character]
    var currentPerformance: Performance?
    var voiceService: VoiceService

    func playDialogue(for scene: Scene)
    func pausePerformance()
    func adjustVoice(characterId: UUID, settings: VoiceSettings)
}

@Observable
class CollaborationViewModel {
    var collaborators: [Collaborator]
    var presenceInfo: [UUID: PresenceInfo]
    var comments: [Comment]

    func inviteCollaborator(email: String)
    func updatePresence()
    func addComment(sceneId: UUID, text: String)
}
```

#### Spatial Manager

**Purpose**: Coordinate spatial layout and positioning

**Responsibilities**:
- Calculate scene card positions in 3D space
- Handle spatial collision detection
- Manage view transitions (timeline ↔ editor ↔ performance)
- Optimize card visibility based on user position
- Handle spatial persistence (remember card positions)

**Algorithm**:
```swift
class SpatialLayoutEngine {
    func calculateTimelineLayout(scenes: [Scene]) -> [SceneCardLayout] {
        // Arrange scenes in acts with spacing
        // Act I: Left side (-2m to -0.5m from user)
        // Act II: Center (0.5m to 2m from user)
        // Act III: Right side (2.5m to 4m from user)
        // Vertical: 1.5m height (comfortable viewing)
        // Depth: 2-4m from user
    }

    func adaptToRoomSize(availableSpace: SIMD3<Float>)
    func avoidObstacles(obstacles: [PlaneAnchor])
}
```

#### Gesture Handler

**Purpose**: Process user input and gestures

**Supported Gestures**:
- Tap: Select scene card
- Long press: Show context menu
- Drag: Move scene card
- Pinch: Zoom timeline
- Two-finger rotate: Rotate view
- Double tap: Enter immersive mode
- Gaze + pinch: Distant selection

### 3. Business Layer

#### Script Engine

**Purpose**: Core screenplay logic and formatting

**Responsibilities**:
- Parse screenplay text into structured elements
- Apply industry-standard formatting rules
- Calculate page counts
- Validate screenplay structure
- Generate formatted output

```swift
class ScriptEngine {
    func parse(text: String) -> [ScriptElement]
    func format(elements: [ScriptElement]) -> String
    func calculatePageCount(scenes: [Scene]) -> Double
    func validateStructure(project: Project) -> [ValidationIssue]
    func autoComplete(partial: String, type: ElementType) -> [String]
}
```

**Formatting Rules**:
- Slugline: All caps, 1.5" from left
- Action: 1.5" from left, 1" from right
- Character: 3.7" from left
- Parenthetical: 3.1" from left
- Dialogue: 2.5" from left, 2" from right
- Transition: 6" from left

#### Character Manager

**Purpose**: Manage character data and voice synthesis

```swift
class CharacterManager {
    var voiceService: VoiceService
    var avatarService: AvatarService

    func createCharacter(name: String, settings: CharacterSettings) -> Character
    func synthesizeDialogue(character: Character, text: String) async -> AudioBuffer
    func loadAvatar(characterId: UUID) async -> ModelEntity
    func updateVoiceSettings(characterId: UUID, settings: VoiceSettings)
}
```

#### Location Manager

**Purpose**: Manage virtual locations and environments

```swift
class LocationManager {
    var assetLibrary: AssetLibrary
    var customizationEngine: CustomizationEngine

    func loadLocation(locationId: String) async -> Entity
    func customizeLocation(location: Location, changes: LocationCustomization)
    func blendWithRealWorld(location: Location, mode: BlendMode)
    func saveCustomLocation(location: Location) async
}
```

#### Storyboard Manager

**Purpose**: Handle storyboard creation and animation

```swift
class StoryboardManager {
    var imageService: ImageGenerationService?
    var animationEngine: AnimationEngine

    func createStoryboard(sceneId: UUID) -> Storyboard
    func addFrame(storyboardId: UUID, frame: StoryboardFrame)
    func generateFrameImage(prompt: String) async -> Image?
    func playAnimatic(storyboard: Storyboard) async
    func exportVideo(storyboard: Storyboard) async -> URL
}
```

#### Collaboration Engine

**Purpose**: Real-time collaboration and sync

```swift
class CollaborationEngine {
    var syncService: SyncService
    var conflictResolver: ConflictResolver
    var voiceChatService: VoiceChatService

    func startSession(projectId: UUID)
    func inviteCollaborator(userId: String, role: CollaboratorRole)
    func syncChanges(changes: [Change]) async
    func resolveConflict(conflict: SyncConflict) -> Resolution
    func broadcastPresence(info: PresenceInfo)
}
```

#### Export Manager

**Purpose**: Export to various formats

```swift
class ExportManager {
    func exportPDF(project: Project) async -> URL
    func exportFinalDraft(project: Project) async -> URL
    func exportFountain(project: Project) async -> URL
    func exportStoryboard(storyboard: Storyboard, format: ExportFormat) async -> URL
    func exportShotList(scenes: [Scene]) async -> URL
}
```

### 4. Data Layer

#### SwiftData Store

**Purpose**: Local persistence and queries

```swift
@ModelActor
actor ProjectStore {
    func save(project: Project) async throws
    func fetch(id: UUID) async throws -> Project
    func fetchAll() async throws -> [Project]
    func delete(id: UUID) async throws
    func query(predicate: Predicate<Project>) async throws -> [Project]
}
```

**Configuration**:
```swift
let container = ModelContainer(
    for: Project.self,
    Scene.self,
    Character.self,
    Location.self,
    Storyboard.self
)
```

#### CloudKit Sync

**Purpose**: Cloud backup and collaboration sync

**Architecture**:
```swift
class CloudKitSyncService {
    var privateDatabase: CKDatabase
    var sharedDatabase: CKDatabase
    var publicDatabase: CKDatabase

    func syncProject(project: Project) async throws
    func fetchChanges() async throws -> [Change]
    func uploadAsset(data: Data, type: AssetType) async throws -> CKAsset
    func shareProject(projectId: UUID, with: [String]) async throws
}
```

**Sync Strategy**:
- Local-first: Always work with local data
- Background sync: Sync every 30 seconds when changes detected
- Delta sync: Only upload/download changes
- Conflict resolution: Last-write-wins with timestamp
- Retry logic: Exponential backoff (2s, 4s, 8s, 16s)

#### File Manager

**Purpose**: Asset and file management

```swift
class ProjectFileManager {
    var baseURL: URL

    func createProjectDirectory(projectId: UUID) throws -> URL
    func saveAsset(data: Data, projectId: UUID, type: AssetType) throws -> URL
    func loadAsset(url: URL) throws -> Data
    func deleteProject(projectId: UUID) throws
    func exportProject(projectId: UUID) throws -> URL
}
```

### 5. External Services

#### Voice Service

**Provider Options**:

**Option A: Apple Neural Voices** (Primary)
```swift
class AppleVoiceService: VoiceService {
    func synthesize(text: String, settings: VoiceSettings) async -> AVAudioBuffer {
        let synthesizer = AVSpeechSynthesizer()
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(identifier: settings.voiceId)
        utterance.rate = settings.rate
        utterance.pitchMultiplier = settings.pitch
        // Record output to buffer
    }
}
```

**Option B: ElevenLabs API** (Premium)
```swift
class ElevenLabsService: VoiceService {
    func synthesize(text: String, settings: VoiceSettings) async throws -> AVAudioBuffer {
        let request = ElevenLabsRequest(
            text: text,
            voiceId: settings.voiceId,
            modelId: "eleven_monolingual_v1"
        )
        let audioData = try await apiClient.generateSpeech(request)
        return try AVAudioBuffer(from: audioData)
    }
}
```

#### AI Image Generation (Optional)

```swift
protocol ImageGenerationService {
    func generateImage(prompt: String, style: ImageStyle) async throws -> UIImage
}

class DALLEService: ImageGenerationService {
    // OpenAI DALL-E integration
}

class MidjourneyService: ImageGenerationService {
    // Midjourney API integration (when available)
}
```

#### 3D Asset Library

```swift
class AssetLibrary {
    var localCache: AssetCache
    var remoteRepository: AssetRepository

    func loadAsset(id: String) async throws -> Entity
    func downloadAsset(id: String) async throws
    func getCachedAsset(id: String) -> Entity?
    func searchAssets(query: String, category: AssetCategory) -> [AssetMetadata]
}
```

## State Management

### App-Level State

```swift
@Observable
class AppState {
    var currentProject: Project?
    var currentScene: Scene?
    var currentView: AppView
    var isImmersive: Bool
    var collaborationSession: CollaborationSession?
}

enum AppView {
    case projectList
    case timeline
    case scriptEditor
    case characterPerformance
    case locationScout
    case storyboardEditor
}
```

### Scene State

```swift
@Observable
class SceneState {
    var selectedSceneCards: Set<UUID>
    var timelineZoomLevel: Float
    var spatialAnchors: [UUID: AnchorEntity]
    var visibleScenes: [Scene]
}
```

### Performance State

```swift
@Observable
class PerformanceState {
    var isPlaying: Bool
    var currentLineIndex: Int
    var characterPositions: [UUID: SpatialCoordinates]
    var audioPlayers: [UUID: AVAudioPlayer]
}
```

## Memory Management

### Memory Budget

**Target**: 4GB total app memory

**Allocation**:
- App framework: ~500 MB
- RealityKit scenes: ~1.5 GB
  - Scene cards: ~500 MB (100 cards × 5 MB each)
  - Characters: ~500 MB (2-3 characters visible)
  - Environment: ~500 MB
- SwiftData: ~500 MB
- Audio buffers: ~300 MB
- Image cache: ~500 MB
- Overhead: ~700 MB

### Optimization Strategies

#### Lazy Loading
```swift
class SceneCardRenderer {
    func renderVisibleCards(scenes: [Scene], userPosition: SIMD3<Float>) {
        let visibleScenes = scenes.filter { scene in
            distance(scene.position, userPosition) < visibilityRadius
        }
        // Only render visible cards
    }
}
```

#### LOD (Level of Detail)
```swift
enum DetailLevel {
    case full      // Within 2m
    case medium    // 2-4m
    case minimal   // 4-6m
    case hidden    // > 6m
}

func selectLOD(distance: Float) -> DetailLevel {
    switch distance {
    case 0..<2: return .full
    case 2..<4: return .medium
    case 4..<6: return .minimal
    default: return .hidden
    }
}
```

#### Asset Streaming
- Load high-res textures only when close
- Stream audio as needed
- Unload off-screen assets

#### Pooling
```swift
class EntityPool {
    private var pool: [String: [Entity]] = [:]

    func dequeue(type: String) -> Entity? {
        return pool[type]?.popLast()
    }

    func enqueue(entity: Entity, type: String) {
        pool[type, default: []].append(entity)
    }
}
```

## Performance Optimization

### Target Metrics

- **Frame Rate**: 60 FPS (90 FPS ideal for visionOS)
- **Scene Load Time**: < 1 second
- **Card Render Time**: < 16ms per card
- **Voice Synthesis**: < 500ms per line
- **Sync Latency**: < 2 seconds

### Optimization Techniques

#### Main Thread Protection
```swift
@MainActor
class ProjectViewModel {
    // UI updates on main thread
}

actor DataService {
    // Heavy operations off main thread
}
```

#### Async/Await
```swift
func loadProject(id: UUID) async throws -> Project {
    async let project = dataStore.fetch(id: id)
    async let scenes = dataStore.fetchScenes(projectId: id)
    async let characters = dataStore.fetchCharacters(projectId: id)

    return try await Project(
        data: project,
        scenes: scenes,
        characters: characters
    )
}
```

#### Task Groups
```swift
func loadMultipleScenes(ids: [UUID]) async throws -> [Scene] {
    try await withThrowingTaskGroup(of: Scene.self) { group in
        for id in ids {
            group.addTask {
                try await self.loadScene(id: id)
            }
        }

        var scenes: [Scene] = []
        for try await scene in group {
            scenes.append(scene)
        }
        return scenes
    }
}
```

#### Caching
```swift
actor CacheService {
    private var cache: [String: CacheEntry] = [:]

    func get<T>(key: String) -> T? where T: Codable
    func set<T>(key: String, value: T, ttl: TimeInterval) where T: Codable
    func invalidate(key: String)
}
```

## Error Handling

### Error Types

```swift
enum AppError: LocalizedError {
    case projectNotFound(UUID)
    case sceneParseFailed(String)
    case voiceSynthesisFailed(Error)
    case syncFailed(Error)
    case exportFailed(Error)
    case assetLoadFailed(String)

    var errorDescription: String? {
        switch self {
        case .projectNotFound(let id):
            return "Project \(id) not found"
        case .sceneParseFailed(let reason):
            return "Failed to parse scene: \(reason)"
        // ... etc
        }
    }
}
```

### Error Recovery

```swift
class ErrorHandler {
    func handle(_ error: Error, context: ErrorContext) {
        log(error, context)
        showUserAlert(error)
        attemptRecovery(error)
    }

    private func attemptRecovery(_ error: Error) {
        switch error {
        case AppError.syncFailed:
            scheduleRetry()
        case AppError.assetLoadFailed:
            loadFallbackAsset()
        default:
            break
        }
    }
}
```

## Testing Strategy

### Unit Tests
- Business logic (ScriptEngine, formatters, parsers)
- View models (state changes, data transformations)
- Data models (validation, serialization)

### Integration Tests
- Data layer (SwiftData ↔ CloudKit sync)
- External services (voice synthesis, asset loading)
- Export pipeline

### UI Tests
- Core workflows (create scene, edit dialogue, export)
- Gesture recognition
- Accessibility

### Performance Tests
- Frame rate monitoring
- Memory profiling
- Network latency

## Security Considerations

### Data Protection
- Keychain for API keys and tokens
- Data Protection API for local files
- CloudKit encryption (automatic)

### Authentication
- Sign in with Apple (required)
- CloudKit user identity
- Collaboration permission checks

### Validation
- Input sanitization (script content)
- API rate limiting
- File size limits

## Monitoring & Analytics

### Metrics to Track
- App launch time
- Feature usage (which views, how often)
- Performance metrics (FPS, memory, network)
- Error rates
- Crash reports

### Tools
- OSLog for structured logging
- MetricKit for performance metrics
- Xcode Instruments for profiling
- Firebase Analytics (optional)

## Deployment Architecture

### Build Configuration

```swift
#if DEBUG
    let apiBaseURL = "https://dev.api.example.com"
    let enableDebugLogging = true
#else
    let apiBaseURL = "https://api.example.com"
    let enableDebugLogging = false
#endif
```

### Release Process
1. Unit tests pass
2. Integration tests pass
3. Performance benchmarks met
4. Beta testing (TestFlight)
5. App Store submission

## Dependencies

### First-Party
- SwiftUI
- RealityKit
- ARKit
- AVFoundation
- SwiftData
- CloudKit
- PencilKit (for storyboards)

### Third-Party (Potential)
- None required (prefer system frameworks)

### Package Structure

```
SpatialScreenplayWorkshop/
├── App/
│   ├── SpatialScreenplayWorkshopApp.swift
│   └── AppState.swift
├── Views/
│   ├── Timeline/
│   ├── ScriptEditor/
│   ├── CharacterPerformance/
│   ├── LocationScout/
│   └── Storyboard/
├── ViewModels/
├── Models/
│   └── (See data-model-schema.md)
├── Business/
│   ├── ScriptEngine/
│   ├── CharacterManager/
│   ├── LocationManager/
│   ├── StoryboardManager/
│   └── CollaborationEngine/
├── Data/
│   ├── SwiftDataStore/
│   ├── CloudKitService/
│   └── FileManager/
├── Services/
│   ├── VoiceService/
│   ├── AssetLibrary/
│   └── ExportService/
├── Utilities/
│   ├── Extensions/
│   ├── Formatters/
│   └── Validators/
└── Resources/
    ├── Assets.xcassets
    └── Localizable.strings
```

---

**Document Version**: 1.0
**Last Updated**: 2025-11-24
**Author**: Technical Architecture Team
