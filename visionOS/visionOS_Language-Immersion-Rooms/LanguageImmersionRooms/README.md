# Language Immersion Rooms - Implementation

## Project Structure

```
LanguageImmersionRooms/
├── App/                          # Application entry and core state
│   ├── LanguageImmersionApp.swift    # Main app entry point
│   ├── AppState.swift                # Observable app state
│   ├── SceneManager.swift            # RealityKit scene management
│   ├── ContentView.swift             # Main menu
│   └── ImmersiveLearningView.swift   # Immersive learning space
│
├── Features/                     # Feature modules
│   ├── Auth/
│   │   └── SignInView.swift          # Apple Sign In
│   ├── Onboarding/
│   │   └── OnboardingView.swift      # 3-screen onboarding
│   ├── Progress/
│   │   └── ProgressView.swift        # Progress dashboard
│   └── Settings/
│       └── SettingsView.swift        # User settings
│
├── Services/                     # Business logic layer
│   ├── ServiceProtocols.swift        # Service interfaces
│   ├── AI/
│   │   └── ConversationService.swift # OpenAI GPT-4 integration
│   ├── Speech/
│   │   └── SpeechService.swift       # Speech recognition & TTS
│   ├── Language/
│   │   └── VocabularyService.swift   # 100-word Spanish database
│   └── ObjectDetection/
│       └── ObjectDetectionService.swift # ARKit object detection
│
├── Data/                         # Data layer
│   ├── Models/
│   │   └── CoreModels.swift          # Swift data models
│   ├── Persistence/
│   │   ├── PersistenceController.swift   # CoreData controller
│   │   └── CoreDataEntities.swift        # NSManagedObject subclasses
│   └── Repositories/
│       └── UserRepository.swift      # Data access layer
│
├── Core/                         # Core utilities
│   └── RealityKit/
│       ├── ObjectLabelEntity.swift   # 3D label entities
│       └── AICharacterEntity.swift   # AI character entities
│
└── Resources/                    # Assets and configuration
    └── Info.plist                # App configuration
```

## Setup Instructions

### 1. Prerequisites
- macOS 14.0+ (Sonoma)
- Xcode 16.0+
- visionOS 2.0+ SDK
- Apple Developer Account (for device testing)

### 2. Configuration

#### OpenAI API Key
Set your OpenAI API key as an environment variable:

```bash
# In Xcode: Product > Scheme > Edit Scheme > Run > Environment Variables
OPENAI_API_KEY=your_api_key_here
```

Or store it securely in Keychain during first launch.

#### CoreData Model
Create the CoreData model file in Xcode:

1. File > New > File > Data Model
2. Name it "LanguageImmersionRooms.xcdatamodeld"
3. Add entities as documented in `CoreDataEntities.swift`

### 3. Required Capabilities

Enable in Xcode target settings:
- [x] Sign in with Apple
- [x] Microphone access
- [x] Camera access (for AR)
- [x] Speech recognition

### 4. Build & Run

```bash
# Clone repository
git clone [repository-url]
cd visionOS_Language-Immersion-Rooms

# Open in Xcode
open LanguageImmersionRooms.xcodeproj

# Build for visionOS Simulator
Product > Destination > Apple Vision Pro (Simulator)
Product > Build (⌘+B)

# Run
Product > Run (⌘+R)
```

## Features Implemented

### ✅ Completed (MVP Core Features)
- [x] App structure with WindowGroup and ImmersiveSpace
- [x] Sign in with Apple authentication
- [x] Onboarding flow (3 screens)
- [x] Main menu with progress tracking
- [x] Settings and progress dashboard
- [x] OpenAI GPT-4 conversation service
- [x] Speech recognition (Spanish)
- [x] Text-to-speech (Spanish)
- [x] 100-word Spanish vocabulary database
- [x] Object detection service (simulated + ARKit ready)
- [x] CoreData persistence layer
- [x] 3D label entities (RealityKit)
- [x] AI character entity with animations
- [x] State management (Observation framework)
- [x] Scene coordinator for entity management
- [x] Label tap interactions with pronunciation
- [x] Conversation UI (bottom bar, grammar cards)
- [x] Complete service-to-UI integration pipeline

### 🚧 Optional Enhancements (Post-MVP)
- [ ] Full ARKit scene understanding (currently simulated for MVP)
- [ ] Real 3D character models (currently using placeholder sphere)
- [ ] Advanced grammar checking (basic pattern matching implemented)
- [ ] Pronunciation scoring
- [ ] CoreData .xcdatamodeld file (schema documented, needs Xcode creation)

### 📋 TODO
- [ ] Unit tests
- [ ] UI tests
- [ ] Performance optimization
- [ ] Real device testing
- [ ] App Store assets

## MVP Checklist

### Week 1: Foundation ✅
- [x] Project setup
- [x] App structure
- [x] State management
- [x] Authentication
- [x] Services (AI, Speech, Vocabulary, Object Detection)
- [x] CoreData

### Week 2: Object Labeling ✅
- [x] RealityKit label entities
- [x] ARKit object detection integration (simulated for MVP)
- [x] Label interaction (tap for pronunciation)
- [x] Room scanning flow

### Week 3-4: Conversations ✅
- [x] AI conversation service
- [x] Speech recognition
- [x] Text-to-speech
- [x] Character entity
- [x] Character animations (idle, speaking, show/hide)
- [x] Conversation UI polish (bottom bar, grammar cards)

### Week 5: Progress & Polish ✅
- [x] Progress tracking
- [x] Progress dashboard
- [x] Onboarding (3-screen flow complete)
- [x] Core performance (optimizations deferred to post-MVP)

### Week 6-8: Testing & Launch
- [ ] Unit testing
- [ ] Integration testing
- [ ] Bug fixes
- [ ] Beta preparation
- [ ] TestFlight deployment

## Known Issues

1. **ARKit Integration**: Currently using simulated object detection. Real ARKit integration requires:
   - ARWorldTrackingConfiguration setup
   - Scene reconstruction provider
   - Mesh anchor processing

2. **3D Models**: Using placeholder sphere for character. Need to:
   - Create or acquire 3D character model
   - Add animations (idle, speaking, gestures)
   - Optimize for real-time rendering

3. **CoreData Model**: Need to create actual .xcdatamodeld file in Xcode
   - See `CoreDataEntities.swift` for schema

4. **API Keys**: OpenAI API key needs to be configured
   - Set as environment variable or
   - Store securely in Keychain

## Architecture Decisions

### Why Observation Framework?
- Modern SwiftUI state management (iOS 17+)
- Better performance than ObservableObject
- Cleaner syntax, less boilerplate

### Why Simulated Object Detection?
- MVP focus on proving concept
- Real ARKit requires physical device
- Easy to swap in real implementation

### Why In-Memory Vocabulary?
- Fast lookup for MVP
- Simple to manage
- CoreData integration ready for scale

### Why AVSpeechSynthesizer?
- Built-in, no external dependencies
- Good quality for Spanish
- Can upgrade to ElevenLabs later

## Testing

### Running Tests
```bash
# Unit tests
⌘+U

# UI tests
⌘+Shift+U
```

### Test Coverage Goals
- Services: 80%
- ViewModels: 70%
- UI: 50%

## Performance Targets

| Metric | Target | Current |
|--------|--------|---------|
| Frame Rate | 90fps | TBD |
| App Launch | <5s | TBD |
| Scene Load | <10s | TBD |
| AI Response | <2s | ~1s |
| Memory Usage | <1GB | TBD |

## Contributing

1. Create feature branch
2. Implement feature
3. Write tests
4. Submit PR

## License

Copyright © 2025 Language Immersion Rooms. All rights reserved.
