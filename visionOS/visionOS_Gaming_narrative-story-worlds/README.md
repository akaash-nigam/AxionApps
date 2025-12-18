# Narrative Story Worlds - visionOS

> Transform your living space into immersive, emotionally-driven story experiences where AI-driven characters remember and react to your choices in real-time.

## Project Overview

**Narrative Story Worlds** is a groundbreaking visionOS gaming application for Apple Vision Pro that leverages spatial computing to deliver cinematic narrative adventures. Players become protagonists in branching stories where photorealistic characters appear in their actual living spaces, remember past decisions, and adapt to player emotions through AI-driven storytelling.

### Core Features

- 🎭 **Spatial Storytelling**: Your room becomes the stage - characters appear naturally in your environment
- 🤖 **AI-Driven Adaptation**: Stories adapt to your choices, emotions, and play style in real-time
- 💬 **Dynamic Dialogue**: Context-aware conversations with character memory and personality
- 🎮 **Gesture-Based Interaction**: Natural hand gestures and gaze for choice selection
- 💾 **Persistent World**: Characters and objects remember positions across sessions
- 🎵 **Spatial Audio**: 3D positioned dialogue and adaptive music
- 📱 **iCloud Sync**: Continue your story across devices

## Documentation

### Design & Planning Documents

- **[ARCHITECTURE.md](ARCHITECTURE.md)** - Technical architecture and system design
- **[TECHNICAL_SPEC.md](TECHNICAL_SPEC.md)** - Detailed technical specifications
- **[DESIGN.md](DESIGN.md)** - Game design document, UI/UX, and visual style
- **[IMPLEMENTATION_PLAN.md](IMPLEMENTATION_PLAN.md)** - Development roadmap and milestones
- **[INSTRUCTIONS.md](INSTRUCTIONS.md)** - Original implementation instructions
- **[Narrative-Story-Worlds-PRD.md](Narrative-Story-Worlds-PRD.md)** - Product requirements document
- **[Narrative-Story-Worlds-PRFAQ.md](Narrative-Story-Worlds-PRFAQ.md)** - PR/FAQ document

## Project Structure

```
NarrativeStoryWorlds/
├── App/
│   ├── NarrativeStoryWorldsApp.swift    # Main app entry point
│   ├── AppModel.swift                    # Global app state
│   ├── ContentView.swift                 # Main menu UI
│   └── StoryExperienceView.swift         # Immersive story view
│
├── Core/
│   └── GameStateManager.swift            # Game state machine
│
├── Game/
│   ├── Dialogue/
│   │   └── DialogueSystem.swift          # Dialogue presentation
│   ├── Choice/
│   │   └── ChoiceSystem.swift            # Choice presentation & selection
│   └── State/
│       └── StoryManager.swift            # Story progression & branching
│
├── Spatial/
│   ├── SpatialManager.swift              # Room scanning & tracking
│   └── CharacterManager.swift            # Character entities & positioning
│
├── Models/
│   └── StoryModels.swift                 # Core data models
│
├── Persistence/
│   └── SaveSystem.swift                  # Save/load functionality
│
├── Views/
│   ├── Dialogue/                         # Dialogue UI components
│   ├── Choice/                           # Choice UI components
│   └── UI/                               # General UI components
│
├── AI/                                   # AI systems (to be implemented)
│   ├── StoryDirector/                    # Pacing & branch selection
│   ├── Character/                        # Character AI & personality
│   ├── EmotionRecognition/               # Player emotion detection
│   └── Dialogue/                         # Dialogue generation
│
├── Audio/                                # Audio systems (to be implemented)
├── Input/                                # Gesture recognition (to be implemented)
└── Resources/                            # Assets and resources
```

## Requirements

### Development Environment

- **macOS**: Sonoma or later
- **Xcode**: 16.0 or later
- **Reality Composer Pro**: Latest version
- **Apple Silicon**: M1 or later recommended

### Target Platform

- **visionOS**: 2.0 or later
- **Device**: Apple Vision Pro

### Capabilities Required

- ARKit World Tracking
- ARKit Face Tracking
- ARKit Hand Tracking
- Spatial Persistence
- Spatial Audio
- iCloud (CloudKit)

## Getting Started

### 1. Clone the Repository

```bash
git clone https://github.com/your-username/visionOS_Gaming_narrative-story-worlds.git
cd visionOS_Gaming_narrative-story-worlds
```

### 2. Open in Xcode

Since this is a Swift package structure, you'll need to create an Xcode project:

1. Open Xcode 16+
2. Create new visionOS App project
3. Copy the `NarrativeStoryWorlds/` folder contents into your project
4. Add `Info.plist` and `NarrativeStoryWorlds.entitlements` to your project
5. Configure bundle identifier: `com.storystudios.narrativeworldsvision`

### 3. Configure Entitlements

Ensure the following entitlements are enabled in your project:

- ✅ ARKit World Tracking
- ✅ ARKit Face Tracking
- ✅ ARKit Hand Tracking
- ✅ Spatial Persistence
- ✅ Spatial Audio
- ✅ iCloud
- ✅ App Groups

### 4. Build and Run

1. Select Vision Pro simulator or physical device
2. Build the project (⌘B)
3. Run (⌘R)

## Implementation Status

### ✅ Completed

- [x] Project structure and architecture
- [x] Core game state management
- [x] Story manager with branching support
- [x] Dialogue system foundation
- [x] Choice system with spatial presentation
- [x] Save/load system with JSON persistence
- [x] Spatial room scanning framework
- [x] Character manager and positioning
- [x] Main menu UI
- [x] Immersive story view
- [x] Comprehensive documentation

### 🚧 In Progress

- [ ] AI systems (Story Director, Character AI, Emotion Recognition)
- [ ] Audio systems (Spatial audio, haptics)
- [ ] Sample story content

### 📋 To Do

- [ ] Advanced facial animations
- [ ] Voice acting integration
- [ ] SharePlay multiplayer
- [ ] Creator tools
- [ ] Performance optimization
- [ ] Full playtesting
- [ ] App Store submission

## Key Features Implementation

### Spatial Storytelling

The app uses ARKit's WorldTrackingProvider to:
- Detect floor planes and walls
- Identify furniture for character interactions
- Create persistent anchors for story elements
- Adapt story presentation to room size

See: `NarrativeStoryWorlds/Spatial/SpatialManager.swift:26-39`

### AI-Driven Narrative

Character AI combines:
- Personality models (Big Five traits)
- Emotional state tracking
- Player relationship management
- Memory of past interactions

See: `NarrativeStoryWorlds/Models/StoryModels.swift:147-170`

### Save System

Automatic and manual saves using:
- JSON encoding/decoding
- Local file storage
- iCloud sync support (future)
- Multiple save slots

See: `NarrativeStoryWorlds/Persistence/SaveSystem.swift:12-36`

## Performance Targets

- **Frame Rate**: 90 FPS minimum (11.1ms per frame)
- **Memory**: < 2GB maximum
- **Battery Life**: 2.5+ hours per charge
- **Load Time**: < 5 seconds

## Architecture Highlights

### Game Loop

```swift
// 90 FPS update cycle
let targetFrameTime = 1.0 / 90.0

while appModel.currentState == .playingStory {
    let deltaTime = CACurrentMediaTime() - lastTime

    gameStateManager.update(deltaTime: deltaTime)
    characterManager.update(deltaTime: deltaTime)
    storyManager.update(deltaTime: deltaTime)

    // Sleep to maintain frame rate
}
```

See: `NarrativeStoryWorlds/App/StoryExperienceView.swift:44-60`

### State Machine

```
initializing → menuNavigation → roomCalibration → storyPlaying
                                                       ↓
                                  paused ←→ choicePresentation
```

See: `NarrativeStoryWorlds/Core/GameStateManager.swift:47-62`

## Development Workflow

### Phase 1: Foundation (Current)
- ✅ Project setup
- ✅ Core architecture
- ✅ Basic systems

### Phase 2: Core Features
- 🚧 AI integration
- 🚧 Audio systems
- ⏳ Story content

### Phase 3: Polish & Testing
- ⏳ Performance optimization
- ⏳ Playtesting
- ⏳ Bug fixes

### Phase 4: Release
- ⏳ App Store submission
- ⏳ Launch preparation

## Contributing

This is currently a solo project, but contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Follow the existing code style
4. Write comprehensive comments
5. Submit a pull request

## Testing

We maintain a comprehensive test suite to ensure production readiness. See **[NarrativeStoryWorlds/Tests/README.md](NarrativeStoryWorlds/Tests/README.md)** for complete testing documentation.

### Test Coverage

- **Unit Tests**: 60+ tests for AI systems, models, and core logic
- **Integration Tests**: 25+ tests for system interactions
- **Performance Tests**: 25+ benchmarks for speed and memory
- **Hardware Tests**: 50+ visionOS-specific tests (requires Vision Pro)

**Coverage Goals**: 70%+ overall, 80%+ for critical AI systems

### Running Tests

#### Unit & Integration Tests (Xcode)

```bash
# Run all tests
xcodebuild test \
  -scheme NarrativeStoryWorlds \
  -destination 'platform=visionOS Simulator,name=Apple Vision Pro'

# Run with coverage
xcodebuild test \
  -scheme NarrativeStoryWorlds \
  -enableCodeCoverage YES \
  -resultBundlePath ./TestResults.xcresult

# Generate coverage report
xcrun xccov view --report ./TestResults.xcresult
```

#### Or in Xcode

1. Open `NarrativeStoryWorlds.xcodeproj`
2. Press `⌘U` to run all tests
3. View results in Test Navigator (⌘6)

### Test Documentation

- **[TEST_STRATEGY.md](NarrativeStoryWorlds/Tests/TEST_STRATEGY.md)** - Comprehensive test strategy
- **[VISIONOS_HARDWARE_TESTS.md](NarrativeStoryWorlds/Tests/VISIONOS_HARDWARE_TESTS.md)** - Hardware test procedures
- **[TEST_EXECUTION_REPORT.md](NarrativeStoryWorlds/Tests/TEST_EXECUTION_REPORT.md)** - Test execution status

### Performance Testing

```bash
# Profile with Instruments
⌘I
```

**Performance Targets**:
- AI Response: <100ms
- Emotion Recognition: <20ms
- Frame Rate: 90 FPS minimum
- Memory: <1.5 GB peak

## Privacy & Security

- All spatial data processed on-device
- No data uploaded to servers
- Optional iCloud sync (encrypted)
- Face tracking data never leaves device
- User can delete all data anytime

See: `TECHNICAL_SPEC.md` Section 11: Security & Privacy

## License

Copyright © 2024 StorySpace Studios. All rights reserved.

This is a proprietary project developed for Apple Vision Pro.

## Credits

### Development
- Architecture & Implementation: Based on PRD specifications
- Game Design: Narrative Story Worlds PRD
- Technical Specifications: TECHNICAL_SPEC.md

### Technologies
- **visionOS 2.0+**: Apple's spatial computing platform
- **RealityKit 4.0**: 3D rendering and spatial interactions
- **ARKit 6.0**: Spatial tracking and room mapping
- **SwiftUI 5.0+**: User interface
- **Core ML**: On-device AI processing
- **AVFoundation**: Spatial audio

## Support

For issues, questions, or feedback:

- Create an issue on GitHub
- Email: support@storystudios.example.com
- Documentation: See the `docs/` directory

## Acknowledgments

- Apple for visionOS and the Vision Pro platform
- The narrative gaming community for inspiration
- Beta testers and early supporters

---

**Built with ❤️ for Apple Vision Pro**

*"Your home becomes the story"*
