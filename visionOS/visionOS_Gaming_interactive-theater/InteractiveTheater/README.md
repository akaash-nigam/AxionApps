# Interactive Theater

**Transform your living space into immersive theatrical performances where your choices shape the story.**

A visionOS gaming application for Apple Vision Pro that brings professional-quality theatrical performances into your home with AI-driven holographic actors, branching narratives, and meaningful player agency.

---

## Overview

Interactive Theater is a revolutionary spatial computing experience that combines:
- **Professional Theater**: High-quality dramatic performances with period-authentic presentation
- **AI Characters**: Sophisticated character personalities that remember interactions and respond naturally
- **Branching Narratives**: Your choices have meaningful consequences that affect relationships and story outcomes
- **Spatial Immersion**: Your room becomes the theater stage with seamless reality integration
- **Educational Value**: Curriculum-aligned content with measurable learning outcomes

---

## Features

### Core Gameplay
- ✅ **Character Interaction**: Natural conversation with AI-driven characters using voice, gaze, and hand gestures
- ✅ **Narrative Agency**: Branching storylines with multiple endings based on your choices
- ✅ **Spatial Performance**: Characters navigate and acknowledge your real environment
- ✅ **Emotional Depth**: Characters respond to your emotions and develop relationships
- ⏳ **Live Events**: Scheduled performances with real actors (planned)
- ⏳ **Multiplayer**: SharePlay integration for shared experiences (planned)

### Technical Highlights
- **90 FPS Target**: Smooth character animation and responsive interactions
- **<20ms Latency**: Natural feeling interactions
- **Spatial Audio**: HRTF-based 3D audio with character positioning
- **Room Mapping**: ARKit-powered environment understanding
- **Eye Tracking**: Gaze-based character attention and UI navigation
- **Hand Tracking**: Natural gesture recognition for interaction

### Accessibility
- Subtitles with speaker identification
- VoiceOver support for navigation
- Multiple control schemes (gaze, voice, hands, controller)
- Adjustable pacing and complexity
- Content warnings and skip options

---

## Project Structure

```
InteractiveTheater/
├── Package.swift                    # Swift Package Manager configuration
├── InteractiveTheater/              # Main application code
│   ├── App/                         # App entry point and coordinators
│   │   ├── InteractiveTheaterApp.swift
│   │   └── AppCoordinator.swift
│   ├── Core/                        # Core game systems
│   │   ├── GameLoop/                # Main game loop (90 FPS target)
│   │   ├── StateManagement/         # Game state management
│   │   └── EventSystem/             # Event bus for system communication
│   ├── Systems/                     # Game systems
│   │   ├── AISystem/                # Character AI and dialogue
│   │   ├── NarrativeSystem/         # Branching narrative engine
│   │   ├── SpatialSystem/           # Room mapping and spatial interactions
│   │   ├── AudioSystem/             # Spatial audio management
│   │   └── PhysicsSystem/           # Physics for prop interactions
│   ├── Entities/                    # Game entities (characters, props)
│   ├── Components/                  # ECS components
│   ├── Views/                       # SwiftUI views and RealityKit scenes
│   ├── Models/                      # Data models and schemas
│   ├── Services/                    # External services (save, cloud, analytics)
│   ├── Utilities/                   # Helper functions and extensions
│   └── Resources/                   # Assets, 3D models, audio
├── InteractiveTheaterTests/         # Test suite
│   ├── UnitTests/                   # Unit tests (80% coverage target)
│   ├── IntegrationTests/            # Integration tests
│   └── PerformanceTests/            # Performance and optimization tests
└── InteractiveTheaterUITests/       # UI and end-to-end tests
```

---

## Technology Stack

- **Language**: Swift 6.0+ (strict concurrency)
- **Platform**: visionOS 2.0+
- **UI Framework**: SwiftUI
- **3D Rendering**: RealityKit
- **Spatial Tracking**: ARKit
- **Audio**: AVFoundation with Spatial Audio
- **AI/ML**: CoreML for on-device processing
- **Data**: SwiftData for persistence
- **Networking**: GroupActivities (SharePlay)

---

## Getting Started

### Prerequisites

- macOS 14.0+ with Xcode 16.0+
- Apple Vision Pro (for testing on device)
- visionOS 2.0+ SDK

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/your-org/interactive-theater.git
   cd interactive-theater
   ```

2. **Open in Xcode**
   ```bash
   cd InteractiveTheater
   open Package.swift
   ```

3. **Build and Run**
   - Select your target device (Vision Pro or simulator)
   - Press Cmd+R to build and run

### Running Tests

```bash
# Run all tests
swift test

# Run specific test suite
swift test --filter CharacterModelTests

# Run with coverage
swift test --enable-code-coverage
```

---

## Architecture

See detailed documentation in:
- [ARCHITECTURE.md](../ARCHITECTURE.md) - Technical architecture and system design
- [TECHNICAL_SPEC.md](../TECHNICAL_SPEC.md) - Technical specifications and requirements
- [DESIGN.md](../DESIGN.md) - Game design and UI/UX specifications
- [IMPLEMENTATION_PLAN.md](../IMPLEMENTATION_PLAN.md) - Development roadmap and milestones

### Core Systems

#### Game Loop System
- Fixed 60 Hz physics timestep
- Variable 90 Hz rendering
- Performance monitoring and metrics
- Adaptive quality based on thermal state

#### State Management
- Centralized game state with @Observable
- State transition validation
- Save/load system integration
- Progress tracking

#### Narrative Engine
- Graph-based branching narratives
- Choice consequence processing
- Relationship tracking
- Multiple ending support

#### AI Character System
- Personality-driven behavior (Big Five model)
- Emotional state modeling
- Memory and context retention
- Natural dialogue generation

---

## Development Workflow

### Branching Strategy
- `main` - Production-ready code
- `develop` - Integration branch
- `feature/*` - Feature branches
- `claude/*` - AI-assisted development branches

### Code Standards
- Swift 6.0 strict concurrency
- 80% test coverage requirement
- Documentation for public APIs
- Performance budget compliance

### Performance Targets
- **Frame Rate**: 90 FPS target, 60 FPS minimum
- **Latency**: <20ms input to response
- **Memory**: <2GB working set
- **Battery**: 2+ hours continuous play

---

## Testing Strategy

### Unit Tests (80% Coverage Target)
- Data models and business logic
- AI systems (personality, dialogue, emotion)
- Narrative engine (branching, consequences)
- State management

### Integration Tests
- System interactions (AI ↔ Narrative)
- Spatial interactions (input → character response)
- Audio positioning
- Scene transitions

### Performance Tests
- Frame rate consistency
- Memory usage
- Input latency
- Thermal performance

### UI Tests
- Menu navigation
- Performance playthrough
- Choice interaction
- Accessibility features

---

## Current Status

### ✅ Completed (Phase 1: Foundation)
- [x] Complete architecture documentation
- [x] Technical specifications
- [x] Game design document
- [x] Implementation roadmap
- [x] Project structure setup
- [x] Core data models
- [x] Game state management system
- [x] Game loop with performance tracking
- [x] Comprehensive unit tests (Models, State, GameLoop)
- [x] Basic UI views (MainMenu, TheaterPerformance)

### 🚧 In Progress
- AI character system
- Narrative engine implementation
- Spatial interaction systems
- Audio systems

### ⏳ Planned
- RealityKit scene management
- Complete UI/UX implementation
- Sample performance content (Hamlet scene)
- Educational features
- Multiplayer (SharePlay)
- Live events

---

## Contributing

### Development Setup
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Write tests for your changes
4. Ensure tests pass and coverage maintained
5. Commit your changes
6. Push to your branch
7. Open a Pull Request

### Testing Guidelines
- All new features require unit tests
- Maintain 80%+ code coverage
- Performance tests for performance-critical code
- Integration tests for system interactions

---

## Performance Monitoring

The game loop includes built-in performance monitoring:

```swift
let stats = gameLoop.getPerformanceStats()
print("FPS: \(stats.currentFPS)")
print("95th percentile frame time: \(stats.percentile95FrameTime * 1000)ms")
print("Rating: \(stats.performanceRating)")
```

Performance ratings:
- **Excellent**: 85+ FPS
- **Good**: 60-85 FPS
- **Fair**: 45-60 FPS
- **Poor**: <45 FPS

---

## License

Copyright © 2025 Interactive Theater Team. All rights reserved.

---

## Contact & Support

- **Documentation**: See `/docs` folder for detailed guides
- **Issues**: https://github.com/your-org/interactive-theater/issues
- **Discussions**: https://github.com/your-org/interactive-theater/discussions

---

## Acknowledgments

- Apple Vision Pro platform and development tools
- Shakespeare and classical theater for inspiration
- Educational partners for curriculum integration
- Early beta testers and feedback providers

---

**Built with ❤️ for Apple Vision Pro**
