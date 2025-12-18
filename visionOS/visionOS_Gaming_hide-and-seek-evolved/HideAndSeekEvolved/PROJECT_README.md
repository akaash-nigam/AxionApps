# Hide and Seek Evolved - Project Structure

This document explains the project structure and how to work with the codebase.

## Project Overview

Hide and Seek Evolved is a visionOS game that transforms the classic hide and seek game into a spatial computing experience with AR enhancements, special abilities, and multiplayer support.

## Directory Structure

```
HideAndSeekEvolved/
├── App/                          # Application layer
│   ├── HideAndSeekEvolvedApp.swift    # Main app entry point
│   ├── ContentView.swift              # Main menu view
│   ├── GameManager.swift              # Central game coordinator
│   └── ImmersiveSpaceManager.swift    # Immersive space management
│
├── Game/                         # Core game logic
│   ├── GameLogic/
│   │   └── GameLoop.swift             # Main game loop (90 FPS)
│   ├── GameState/
│   │   ├── GameStateManager.swift     # FSM for game states
│   │   └── EventBus.swift             # Event system
│   ├── Entities/                      # Game entities
│   └── Components/                    # ECS components
│
├── Systems/                      # Game systems (ECS)
│   ├── PhysicsSystem/                 # Physics and collision
│   ├── InputSystem/                   # Hand tracking, gestures
│   └── AudioSystem/                   # Spatial audio
│
├── Scenes/                       # Scene management
│   ├── MenuScene/                     # Menu scenes
│   └── GameScene/
│       └── GameplayView.swift         # Main gameplay view
│
├── Views/                        # UI Components
│   ├── UI/                            # Menu UI components
│   └── HUD/                           # In-game HUD
│
├── Models/                       # Data models
│   ├── Player.swift                   # Player model + stats
│   ├── Ability.swift                  # Abilities and achievements
│   ├── RoomLayout.swift               # Room and furniture models
│   └── PersistenceManager.swift       # Save/load system
│
├── Resources/                    # Assets
│   ├── Assets.xcassets               # Images and icons
│   ├── Audio/                        # Sound effects and music
│   └── 3DModels/                     # 3D models
│
└── Tests/                        # Test suites
    ├── UnitTests/                    # Unit tests (400+)
    │   ├── PlayerTests.swift
    │   ├── GameStateManagerTests.swift
    │   ├── RoomLayoutTests.swift
    │   └── AbilityTests.swift
    ├── IntegrationTests/             # Integration tests (150+)
    └── UITests/                      # UI tests (100+)
```

## Architecture Patterns

### Entity-Component-System (ECS)
The game uses RealityKit's ECS architecture:
- **Entities**: Game objects (players, furniture, hiding spots)
- **Components**: Data containers (PlayerComponent, CamouflageComponent)
- **Systems**: Logic processors (CamouflageSystem, PhysicsSystem)

### State Management
Centralized state management using:
- `GameStateManager`: Finite state machine for game states
- `EventBus`: Pub/sub pattern for game events
- `@Published` properties for SwiftUI reactivity

### Dependency Injection
Clean dependency injection for testability:
```swift
class GameStateManager {
    init(eventBus: EventBus, persistenceManager: PersistenceManager)
}
```

## Key Files

### App Layer
- **HideAndSeekEvolvedApp.swift**: SwiftUI app entry point, scene configuration
- **GameManager.swift**: Coordinates all game subsystems
- **ImmersiveSpaceManager.swift**: Manages immersive space lifecycle

### Game Logic
- **GameLoop.swift**: 90 FPS game loop synchronized with display
- **GameStateManager.swift**: Game state machine (menu, scanning, hiding, seeking)
- **EventBus.swift**: Event pub/sub system for decoupled communication

### Models
- **Player.swift**: Player data, stats, avatar config
- **Ability.swift**: Game abilities (camouflage, size manipulation, etc.)
- **RoomLayout.swift**: Room scanning data, furniture, hiding spots
- **PersistenceManager.swift**: JSON-based save/load system

### Views
- **ContentView.swift**: Main menu interface
- **GameplayView.swift**: Main gameplay scene with RealityKit

## Testing Strategy

### Unit Tests (400+ tests)
- **PlayerTests.swift**: Player model, stats, codable
- **GameStateManagerTests.swift**: State transitions, updates
- **RoomLayoutTests.swift**: Room data, furniture, hiding spots
- **AbilityTests.swift**: Abilities, cooldowns, achievements

### Integration Tests (150+ planned)
- Complete game flow
- Multiplayer synchronization
- Spatial mapping → hiding spots
- Ability activation → visual effects

### UI Tests (100+ planned)
- Onboarding flow
- Menu navigation
- In-game interactions

### Performance Tests (50+ planned)
- 90 FPS stability
- Memory usage (< 2GB)
- Battery consumption (90+ min)

## Code Conventions

### Swift Style
- Use Swift 6.0 features (async/await, actors)
- Leverage property wrappers (@Published, @State, @StateObject)
- Protocol-oriented programming where appropriate

### Naming Conventions
- **Types**: PascalCase (Player, GameStateManager)
- **Functions/Properties**: camelCase (startGame, currentState)
- **Constants**: camelCase (targetFPS, hidingDuration)

### Documentation
- Use `// MARK: -` for section organization
- Document public APIs with doc comments
- Keep code self-documenting where possible

## Testing Conventions

### Test Naming
- Format: `test<Unit>_<Condition>_<ExpectedResult>`
- Example: `testPlayerStats_winRate_withZeroGames`

### Test Structure
Use Given-When-Then pattern:
```swift
func testExample() {
    // Given
    let player = Player(name: "Test")

    // When
    player.stats.gamesWon = 5

    // Then
    XCTAssertEqual(player.stats.gamesWon, 5)
}
```

## Building and Running

### Requirements
- Xcode 16+
- visionOS 2.0+ SDK
- Apple Vision Pro (device or simulator)

### Build Configuration
- **Debug**: Full debugging, no optimization
- **Release**: Optimized, stripped symbols

### Performance Targets
- Frame Rate: 90 FPS (minimum 72 FPS)
- Memory: < 2GB
- Battery: 90+ minutes gameplay

## Development Workflow

### Phase 1: Foundation (Weeks 1-4) ✅
- [x] Project setup
- [x] Core architecture
- [x] Data models
- [x] Unit tests for models

### Phase 2: Core Gameplay (Weeks 5-10)
- [ ] Spatial mapping
- [ ] Hiding mechanics
- [ ] Seeking mechanics
- [ ] Occlusion detection

### Phase 3: Multiplayer & Polish (Weeks 11-15)
- [ ] GroupActivities multiplayer
- [ ] UI/UX polish
- [ ] Spatial audio
- [ ] Visual effects

### Phase 4: Testing & Optimization (Weeks 16-18)
- [ ] Performance optimization
- [ ] Comprehensive testing
- [ ] Accessibility features

### Phase 5: Release (Weeks 19-20)
- [ ] App Store submission
- [ ] TestFlight beta
- [ ] Launch

## Documentation

- **ARCHITECTURE.md**: Technical architecture details
- **TECHNICAL_SPEC.md**: Implementation specifications
- **DESIGN.md**: Game design document
- **IMPLEMENTATION_PLAN.md**: Development roadmap

## Contributing

### Adding New Features
1. Create feature branch
2. Implement feature with tests
3. Ensure 80%+ test coverage
4. Submit pull request

### Writing Tests
- Write tests BEFORE or WITH implementation
- Aim for 80%+ code coverage
- Test edge cases and error conditions

### Code Review Checklist
- [ ] Tests pass
- [ ] Code coverage maintained
- [ ] No performance regressions
- [ ] Documentation updated

## Troubleshooting

### Common Issues

**Build fails with missing types**
- Ensure all files are added to target
- Check import statements

**Tests fail in CI but pass locally**
- Check for timing dependencies
- Use `XCTestExpectation` for async tests

**Performance degradation**
- Profile with Instruments
- Check for retain cycles
- Optimize render pipeline

## Resources

- [Apple visionOS Documentation](https://developer.apple.com/visionos/)
- [RealityKit Documentation](https://developer.apple.com/documentation/realitykit/)
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui/)

## License

Copyright © 2025. All rights reserved.
