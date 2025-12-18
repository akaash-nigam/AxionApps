# Parkour Pathways - Code Implementation

## Project Structure

This visionOS application follows a clean architecture pattern with clear separation of concerns.

```
ParkourPathways/
├── App/                              # Application entry point and coordination
│   ├── ParkourPathwaysApp.swift      # Main app entry (@main)
│   └── AppCoordinator.swift          # App-level state and navigation
│
├── Core/                             # Core game systems
│   ├── Game/
│   │   └── GameStateManager.swift    # Game state machine
│   │
│   ├── Systems/                      # Core game systems
│   │   └── (Physics, Input, Audio - To be implemented)
│   │
│   └── ECS/                          # Entity-Component-System
│       ├── Components/
│       │   └── GameComponents.swift  # RealityKit custom components
│       └── Systems/
│           └── GameSystems.swift     # ECS game logic systems
│
├── Features/                         # Feature modules
│   ├── Spatial/
│   │   └── SpatialMappingSystem.swift # ARKit spatial mapping
│   │
│   ├── CourseGeneration/
│   │   └── AICourseGenerator.swift   # AI course generation
│   │
│   ├── Multiplayer/                  # SharePlay & multiplayer (TBI)
│   │
│   └── UI/                           # User interface
│       ├── ImmersiveGameView.swift   # Main immersive gameplay
│       ├── MenuViews/
│       │   └── MainMenuView.swift    # Main menu system
│       ├── HUD/                      # In-game HUD (TBI)
│       └── FeedbackViews/            # Feedback UI (TBI)
│
├── Data/                             # Data layer
│   ├── Models/
│   │   └── DataModels.swift          # Core data models
│   ├── Persistence/                  # SwiftData persistence (TBI)
│   └── Network/                      # Networking (TBI)
│
├── Resources/                        # Asset resources
│   ├── Assets.xcassets               # Image assets
│   ├── RealityKitContent/            # 3D models and scenes
│   ├── Audio/                        # Audio files
│   └── Courses/                      # Pre-made courses
│
└── Tests/                            # Test suites
    ├── UnitTests/
    ├── IntegrationTests/
    └── PerformanceTests/
```

## Key Components

### 1. App Architecture

**ParkourPathwaysApp.swift**
- Main entry point using SwiftUI `@main`
- Sets up SwiftData model container
- Defines WindowGroup and ImmersiveSpace scenes
- Injects environment objects

**AppCoordinator.swift**
- Manages app-level state and navigation
- Coordinates between window and immersive spaces
- Provides dependency injection container
- Handles space transitions

**GameStateManager.swift**
- Implements game state machine
- Manages state transitions with validation
- Tracks player data, course data, and session metrics
- Publishes state changes via Combine

### 2. Entity-Component-System

**GameComponents.swift**
- Defines custom RealityKit components:
  - `ObstacleComponent`: Obstacle state and interaction
  - `MovementTrackingComponent`: Player movement history
  - `SafetyComponent`: Safety monitoring
  - `ScoreComponent`: Score calculation
  - `TargetComponent`: Precision targets
  - And 15+ more specialized components

**GameSystems.swift**
- Implements ECS systems that process components:
  - `ObstacleInteractionSystem`: Handles player-obstacle interactions
  - `MovementAnalysisSystem`: Analyzes technique
  - `SafetyMonitoringSystem`: Monitors safety (high priority)
  - `ScoreCalculationSystem`: Updates scores
  - And more specialized systems

### 3. Spatial Features

**SpatialMappingSystem.swift**
- ARKit integration for room scanning
- Scene reconstruction and plane detection
- Room model generation
- Play area detection with safety margins
- Surface classification (floor, wall, ceiling, sloped)
- Furniture identification

### 4. AI Course Generation

**AICourseGenerator.swift**
- AI-powered course generation
- Space analysis and optimization
- Difficulty scaling based on player skill
- Obstacle placement algorithms
- Safety validation
- Checkpoint generation
- Flow optimization

### 5. Data Models

**DataModels.swift**
- SwiftData models:
  - `PlayerData`: Player profile and progression
  - `CourseData`: Course definitions
  - `SessionMetrics`: Gameplay session tracking
- Supporting structs:
  - `Obstacle`, `Checkpoint`, `RoomModel`, `PlayArea`
  - Various enums for types and states
- SIMD3 and simd_quatf Codable conformance

### 6. User Interface

**ImmersiveGameView.swift**
- Main immersive gameplay experience
- RealityView setup with game world
- Entity hierarchy management
- GameLoop implementation
- Course rendering from CourseData

**MainMenuView.swift**
- Comprehensive menu system
- Play, Training, Leaderboards, Profile, Settings tabs
- Course selector interface
- Player status display
- SwiftUI-based responsive design

## Implementation Status

### ✅ Completed
- [x] Project structure and configuration
- [x] Core app architecture
- [x] Game state management
- [x] ECS components (20+ components)
- [x] ECS systems (8 systems)
- [x] Data models (complete)
- [x] Spatial mapping system
- [x] AI course generator
- [x] Main menu UI
- [x] Immersive game view structure

### 🚧 To Be Implemented
- [ ] Physics system implementation
- [ ] Input controllers (hand, eye, voice, gamepad)
- [ ] Audio system (spatial audio, music, SFX)
- [ ] Movement mechanics (jumping, vaulting, wall-running)
- [ ] Movement analysis AI (technique scoring)
- [ ] HUD and feedback UI
- [ ] Results screen
- [ ] Multiplayer and SharePlay
- [ ] Safety monitoring (complete implementation)
- [ ] Persistence layer
- [ ] Network layer
- [ ] Sample course content
- [ ] 3D models and assets
- [ ] Audio assets
- [ ] Testing suite

## Technical Details

### Requirements
- **Platform**: visionOS 2.0+
- **Swift**: 6.0+ with strict concurrency
- **Xcode**: 16.0+
- **Device**: Apple Vision Pro

### Key Technologies
- **SwiftUI**: UI framework
- **RealityKit**: 3D rendering and ECS
- **ARKit**: Spatial tracking and scene understanding
- **SwiftData**: Local persistence
- **Combine**: Reactive programming
- **Swift Concurrency**: async/await throughout

### Architecture Patterns
- **Entity-Component-System (ECS)**: Game logic via RealityKit
- **MVVM**: UI layer with SwiftUI
- **Coordinator Pattern**: Navigation management
- **Dependency Injection**: Via DependencyContainer
- **State Machine**: Game state transitions
- **Observer Pattern**: Combine publishers

### Performance Targets
- **Frame Rate**: 90 FPS target, 60 FPS minimum
- **Memory**: < 2GB total usage
- **Latency**: < 50ms for interactions
- **Battery**: 2.5+ hours gameplay

## Building and Running

### Prerequisites
```bash
# Requires macOS with Xcode 16+
xcode-select --install
```

### Build Steps
```bash
# Clone the repository
git clone <repository-url>
cd visionOS_Gaming_parkour-pathways

# Open in Xcode
open ParkourPathways.xcodeproj

# Or build from command line
xcodebuild -scheme ParkourPathways -destination 'platform=visionOS Simulator'
```

### Running on Device
1. Connect Apple Vision Pro
2. Select device as run destination
3. Ensure developer mode is enabled
4. Build and run (⌘R)

## Testing

### Unit Tests
```bash
xcodebuild test -scheme ParkourPathways -destination 'platform=visionOS Simulator'
```

### Test Coverage
- Target: 80% code coverage
- Critical paths: 100% (safety, physics, course generation)

## Code Style

### Swift Guidelines
- Follow [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)
- Use Swift 6.0 features (strict concurrency)
- Prefer `async/await` over completion handlers
- Use `@MainActor` for UI-related code
- Document public APIs with Swift DocC

### Naming Conventions
- Types: PascalCase
- Properties/Methods: camelCase
- Constants: camelCase or UPPER_CASE for app-level
- Enums: PascalCase for type, camelCase for cases

### File Organization
- One type per file
- Group related functionality in folders
- Keep files under 500 lines when possible
- Use `// MARK:` for section organization

## Contributing

### Adding New Features
1. Create feature branch: `feature/feature-name`
2. Implement with tests
3. Ensure all tests pass
4. Update documentation
5. Submit pull request

### Code Review Checklist
- [ ] Builds without warnings
- [ ] Tests pass
- [ ] No force unwrapping (`!`) in production code
- [ ] Async code properly uses `await`
- [ ] Memory safety verified
- [ ] Performance acceptable (90 FPS)
- [ ] Documentation updated

## Known Issues

### Current Limitations
1. **Placeholder Implementations**: Some systems have placeholder methods marked with `// TODO`
2. **Asset Dependencies**: 3D models and audio need to be added
3. **Testing**: Comprehensive test suite not yet implemented
4. **Localization**: Only English supported currently

### Planned Improvements
- Complete physics integration
- Implement all movement mechanics
- Add comprehensive audio system
- Build complete multiplayer support
- Create tutorial system
- Add achievement tracking

## Resources

### Documentation
- [Architecture](./ARCHITECTURE.md)
- [Technical Specifications](./TECHNICAL_SPEC.md)
- [Design Document](./DESIGN.md)
- [Implementation Plan](./IMPLEMENTATION_PLAN.md)

### Apple Documentation
- [visionOS Developer](https://developer.apple.com/visionos/)
- [RealityKit](https://developer.apple.com/documentation/realitykit/)
- [ARKit](https://developer.apple.com/documentation/arkit/)
- [SwiftUI](https://developer.apple.com/documentation/swiftui/)

## License

Copyright © 2025 Parkour Pathways. All rights reserved.

---

**Version**: 1.0.0 (Phase 2 - Initial Implementation)
**Last Updated**: 2025-01-19
