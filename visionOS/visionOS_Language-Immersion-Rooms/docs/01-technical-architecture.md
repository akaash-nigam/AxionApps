# Technical Architecture Document

## System Overview

Language Immersion Rooms is built as a native visionOS application using Apple's spatial computing framework. The architecture follows a modular, layered approach optimized for real-time 3D rendering, AI-powered conversations, and persistent spatial anchors.

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                        Presentation Layer                        │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │   SwiftUI    │  │ RealityView  │  │  Immersive   │          │
│  │   Windows    │  │   Volumes    │  │    Space     │          │
│  └──────────────┘  └──────────────┘  └──────────────┘          │
└─────────────────────────────────────────────────────────────────┘
                              │
┌─────────────────────────────────────────────────────────────────┐
│                      Application Layer                           │
│  ┌──────────────────┐  ┌──────────────────┐  ┌────────────┐    │
│  │  Scene Manager   │  │ Conversation     │  │  Learning  │    │
│  │  - Object Labels │  │ Controller       │  │  Progress  │    │
│  │  - Environments  │  │ - AI Chat        │  │  Tracker   │    │
│  │  - Spatial State │  │ - Speech I/O     │  │            │    │
│  └──────────────────┘  └──────────────────┘  └────────────┘    │
└─────────────────────────────────────────────────────────────────┘
                              │
┌─────────────────────────────────────────────────────────────────┐
│                       Service Layer                              │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐        │
│  │ Language │  │   AI     │  │  Speech  │  │  Asset   │        │
│  │ Service  │  │ Service  │  │ Service  │  │ Manager  │        │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘        │
└─────────────────────────────────────────────────────────────────┘
                              │
┌─────────────────────────────────────────────────────────────────┐
│                      Framework Layer                             │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐        │
│  │  ARKit   │  │ Reality  │  │ Core ML  │  │  Speech  │        │
│  │  Scene   │  │   Kit    │  │  Models  │  │Framework │        │
│  │Detection │  │          │  │          │  │          │        │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘        │
└─────────────────────────────────────────────────────────────────┘
                              │
┌─────────────────────────────────────────────────────────────────┐
│                        Data Layer                                │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐        │
│  │ CoreData │  │ CloudKit │  │  UserDef │  │ File     │        │
│  │  Local   │  │   Sync   │  │  aults   │  │ Storage  │        │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘        │
└─────────────────────────────────────────────────────────────────┘
                              │
┌─────────────────────────────────────────────────────────────────┐
│                      External Services                           │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐        │
│  │  OpenAI  │  │ElevenLabs│  │  Azure   │  │ Analytics│        │
│  │  API     │  │   TTS    │  │   STT    │  │ Service  │        │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘        │
└─────────────────────────────────────────────────────────────────┘
```

## Core Modules

### 1. Scene Manager Module
**Responsibility**: Manages spatial scene state, object detection, and label placement

**Components**:
- `SpatialSceneController`: Main coordinator for scene operations
- `ObjectDetectionEngine`: Integrates ARKit scene understanding with Core ML
- `LabelPlacementSystem`: Positions and manages 3D labels attached to objects
- `AnchorPersistenceManager`: Saves/loads spatial anchors between sessions
- `EnvironmentRenderer`: Renders themed environments (café, restaurant, etc.)

**Dependencies**: ARKit, RealityKit, Core ML

### 2. Conversation Module
**Responsibility**: Handles AI-powered conversations with native speakers

**Components**:
- `ConversationOrchestrator`: Manages conversation flow and state
- `AICharacterController`: Controls holographic character appearance and behavior
- `DialogueManager`: Maintains conversation context and history
- `SpeechInputProcessor`: Captures and processes user speech
- `SpeechOutputController`: Generates and plays AI character speech
- `GrammarAnalyzer`: Real-time grammar checking and correction

**Dependencies**: Speech Framework, Natural Language, LLM API

### 3. Learning Progress Module
**Responsibility**: Tracks user progress, achievements, and learning data

**Components**:
- `ProgressTracker`: Records learning metrics and milestones
- `SpacedRepetitionEngine`: Implements SRS algorithm for vocabulary
- `PronunciationScorer`: Evaluates pronunciation accuracy
- `AchievementSystem`: Manages badges and rewards
- `AnalyticsCollector`: Gathers usage and learning data

**Dependencies**: CoreData, CloudKit

### 4. Language Service Module
**Responsibility**: Provides translation, definitions, and language resources

**Components**:
- `TranslationEngine`: Multi-language translation
- `VocabularyDatabase`: 100K+ word dictionary with examples
- `GrammarRuleRepository`: Language-specific grammar rules
- `PhraseLibrary`: Idiomatic expressions and collocations
- `LanguagePackManager`: Downloads and manages language resources

**Dependencies**: Local databases, optional API fallbacks

### 5. Asset Management Module
**Responsibility**: Loads, caches, and manages 3D assets, audio, and textures

**Components**:
- `AssetBundleLoader`: Loads 3D models and environments
- `AudioCacheManager`: Manages pronunciation audio files
- `TextureStreamingController`: Streams high-res textures on demand
- `DownloadManager`: Handles language pack downloads
- `StorageOptimizer`: Manages storage budget and cleanup

**Dependencies**: File system, URLSession

## Data Flow

### Object Labeling Flow
```
User enters space
    ↓
ARKit scans environment
    ↓
Scene understanding detects objects
    ↓
Core ML classifies objects
    ↓
Translation engine provides target language text
    ↓
RealityKit creates 3D label entities
    ↓
Labels anchored to world coordinates
    ↓
Spatial persistence saves anchors
```

### Conversation Flow
```
User triggers conversation
    ↓
AI character appears (RealityKit entity)
    ↓
Character speaks prompt (TTS)
    ↓
User responds (Speech Recognition)
    ↓
Speech → Text transcription
    ↓
Grammar analysis (parallel)
    ↓
LLM generates contextual response
    ↓
Response → TTS → Audio playback
    ↓
Grammar cards appear if errors detected
    ↓
Conversation history saved
```

### Pronunciation Analysis Flow
```
User speaks word/phrase
    ↓
Audio captured (AVAudioEngine)
    ↓
Speech recognition with phoneme timing
    ↓
Waveform analysis (FFT)
    ↓
Compare to reference pronunciation
    ↓
Generate pronunciation score
    ↓
Visual feedback rendered (waveform, mouth shape)
    ↓
Targeted practice suggestions
```

## Concurrency Model

### Main Actor (@MainActor)
- All SwiftUI views
- RealityKit scene updates
- UI-triggered actions

### Background Actors
- `@GlobalActor` for AI service (async LLM calls)
- `@GlobalActor` for asset loading (file I/O)
- Dedicated actor for speech processing (audio streams)

### Task Groups
- Parallel loading of environment assets
- Simultaneous label creation for multiple objects
- Concurrent API calls for translations

### Example Pattern:
```swift
@MainActor
class SceneManager: ObservableObject {
    @Published var labels: [ObjectLabel] = []
    private let aiService: AIService

    func processScene(_ objects: [DetectedObject]) async {
        await withTaskGroup(of: ObjectLabel.self) { group in
            for object in objects {
                group.addTask {
                    await self.createLabel(for: object)
                }
            }

            for await label in group {
                labels.append(label)
            }
        }
    }
}
```

## Memory Architecture

### Memory Budget (per feature)
- **Object Labels**: 50MB (500 labels × 100KB each)
- **AI Character Models**: 200MB (high-quality 3D models with animations)
- **Environment Assets**: 300MB (active environment)
- **Language Pack (in memory)**: 100MB (vocabulary, grammar rules)
- **Audio Buffers**: 50MB (TTS output, pronunciation references)
- **ML Models**: 150MB (object detection, speech recognition)
- **Total Budget**: ~1GB active memory usage

### Memory Management Strategies
- Lazy loading of language packs
- Asset streaming for large environments
- Label culling (hide labels outside frustum)
- Audio cache with LRU eviction
- Aggressive unloading of unused environments

## Threading Model

```
┌──────────────────────────────────────────────┐
│           Main Thread (60fps)                │
│  - UI rendering                              │
│  - RealityKit updates                        │
│  - Touch/gesture handling                    │
└──────────────────────────────────────────────┘

┌──────────────────────────────────────────────┐
│       Audio Thread (Real-time priority)      │
│  - Speech capture                            │
│  - TTS playback                              │
│  - Audio processing                          │
└──────────────────────────────────────────────┘

┌──────────────────────────────────────────────┐
│          Background Threads                  │
│  - API calls (LLM, translation)              │
│  - File I/O (loading assets)                 │
│  - ML inference (object detection)           │
│  - Database operations                       │
└──────────────────────────────────────────────┘

┌──────────────────────────────────────────────┐
│           GPU Thread                         │
│  - 3D rendering                              │
│  - Shader execution                          │
│  - Texture processing                        │
└──────────────────────────────────────────────┘
```

## Communication Patterns

### Observer Pattern (Combine)
```swift
class ConversationController: ObservableObject {
    @Published var currentMessage: String = ""
    @Published var grammarCorrections: [GrammarCard] = []

    private var cancellables = Set<AnyCancellable>()

    func observeSpeech() {
        speechService.transcriptionPublisher
            .debounce(for: .seconds(0.3), scheduler: DispatchQueue.main)
            .sink { [weak self] text in
                self?.processUserInput(text)
            }
            .store(in: &cancellables)
    }
}
```

### Delegate Pattern
- ARKit session delegates for tracking state
- Speech recognition delegates for real-time results
- Download delegates for progress updates

### Async/Await for Services
```swift
protocol AIServiceProtocol {
    func generateResponse(prompt: String, context: [Message]) async throws -> String
}

protocol LanguageServiceProtocol {
    func translate(_ text: String, to language: Language) async throws -> String
}
```

## Dependency Injection

```swift
// Protocol-based architecture for testability
class AppDependencyContainer {
    let aiService: AIServiceProtocol
    let languageService: LanguageServiceProtocol
    let speechService: SpeechServiceProtocol
    let storageService: StorageServiceProtocol

    init(
        aiService: AIServiceProtocol = OpenAIService(),
        languageService: LanguageServiceProtocol = TranslationService(),
        speechService: SpeechServiceProtocol = AppleSpeechService(),
        storageService: StorageServiceProtocol = CoreDataService()
    ) {
        self.aiService = aiService
        self.languageService = languageService
        self.speechService = speechService
        self.storageService = storageService
    }
}

// Inject at app level
@main
struct LanguageImmersionApp: App {
    let dependencies = AppDependencyContainer()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(dependencies.aiService)
                .environmentObject(dependencies.languageService)
        }
    }
}
```

## Package Structure

```
LanguageImmersionRooms/
├── App/
│   ├── LanguageImmersionApp.swift
│   ├── AppDelegate.swift
│   └── DependencyContainer.swift
├── Features/
│   ├── ObjectLabeling/
│   │   ├── Views/
│   │   ├── ViewModels/
│   │   └── Models/
│   ├── Conversations/
│   │   ├── Views/
│   │   ├── ViewModels/
│   │   └── Models/
│   ├── Environments/
│   └── Pronunciation/
├── Services/
│   ├── AIService/
│   ├── LanguageService/
│   ├── SpeechService/
│   └── StorageService/
├── Core/
│   ├── Extensions/
│   ├── Utilities/
│   └── Constants/
├── Data/
│   ├── Models/
│   ├── Repositories/
│   └── Persistence/
├── Resources/
│   ├── Assets.xcassets
│   ├── LanguagePacks/
│   └── 3DModels/
└── Tests/
    ├── UnitTests/
    └── UITests/
```

## Build Configuration

### Debug
- Local API mocking
- Verbose logging
- Memory debugging enabled
- Simulator support (where possible)

### Release
- Production API endpoints
- Minimal logging
- Optimization flags enabled
- Code signing and notarization

### Beta
- Staging APIs
- Analytics enabled
- Crash reporting
- TestFlight provisioning

## Platform Requirements

- **Minimum**: visionOS 2.0
- **Target**: visionOS 2.1
- **Swift**: 6.0+
- **Xcode**: 16.0+

## Performance Targets

| Metric | Target | Critical Threshold |
|--------|--------|-------------------|
| Frame Rate | 90fps | 60fps minimum |
| Scene Load Time | 3s | 10s maximum |
| Label Creation | 0.1s per object | 2s full room |
| Speech Recognition Latency | 200ms | 500ms |
| LLM Response Time | 800ms | 2s |
| Memory Usage | 850MB | 1.2GB max |
| App Launch | 2s | 5s |
| Language Pack Download | 1MB/s | Background only |

## Scalability Considerations

### Horizontal Scaling
- CDN for asset delivery
- Multiple LLM API endpoints with load balancing
- Regional TTS servers for lower latency

### Vertical Scaling
- Efficient asset compression
- Model quantization for Core ML
- Texture atlasing for environments

### Future Architecture Evolution
- On-device LLM for offline conversations (future hardware)
- Federated learning for pronunciation models
- Peer-to-peer language exchange (multiplayer)
