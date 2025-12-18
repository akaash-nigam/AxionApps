# Tactical Team Shooters - Source Code

## Overview

This directory contains the complete Swift source code for Tactical Team Shooters, a competitive tactical FPS for Apple Vision Pro.

## Project Structure

```
TacticalTeamShooters/
├── App/                           # Application entry point and coordination
│   ├── TacticalTeamShootersApp.swift    # Main app definition
│   └── GameCoordinator.swift            # Game state management
├── Game/                          # Core game logic
│   ├── GameLogic/
│   │   ├── GameLoop.swift              # Main game loop (90 FPS)
│   │   └── ECSManager.swift            # Entity-Component-System manager
│   ├── GameState/                      # Game state management
│   ├── Entities/                       # Game entities
│   └── Components/
│       └── GameComponents.swift        # Core components (Transform, Combat, etc.)
├── Systems/                       # Game systems
│   ├── CombatSystem.swift              # Combat and damage
│   ├── WeaponSystem.swift              # Weapon mechanics
│   ├── MovementSystem.swift            # Movement and physics
│   ├── AISystem.swift                  # Enemy AI
│   ├── ProjectileSystem.swift          # Bullet physics
│   ├── PhysicsSystem/
│   │   └── SpatialEnvironmentManager.swift  # ARKit integration
│   ├── AudioSystem/
│   │   └── SpatialAudioManager.swift   # 3D audio
│   ├── InputSystem/
│   │   └── SpatialInputManager.swift   # Hand/eye tracking input
│   └── NetworkManager.swift            # Multiplayer networking
├── Scenes/                        # Game scenes
│   ├── MenuScene/                      # Menu scene
│   └── GameScene/                      # Gameplay scene
├── Views/                         # SwiftUI views
│   ├── UI/
│   │   ├── MainMenuView.swift         # Main menu
│   │   ├── SettingsView.swift         # Settings interface
│   │   └── StatisticsView.swift       # Player stats
│   ├── HUD/                            # In-game HUD
│   ├── GameView.swift                  # Main game view
│   └── TrainingView.swift              # Training mode
├── Models/                        # Data models
│   ├── Player.swift                    # Player data and progression
│   ├── GameSettings.swift              # Game settings
│   ├── WeaponData.swift                # Weapon definitions
│   └── MapData.swift                   # Map data
├── Resources/                     # Game assets
│   ├── Assets.xcassets/                # Image assets
│   ├── Audio/                          # Sound effects and music
│   └── Levels/                         # Map data
├── Tests/                         # Unit and integration tests
└── Supporting/
    └── Info.plist                      # App configuration
```

## Architecture

### Entity-Component-System (ECS)

The game uses ECS architecture for optimal performance and flexibility:

- **Entities**: Unique identifiers (UUID) with tags
- **Components**: Data containers (Transform, Combat, Weapon, etc.)
- **Systems**: Logic processors (CombatSystem, MovementSystem, etc.)

### Game Loop

- **Target**: 90 FPS for smooth Vision Pro experience
- **Fixed Timestep**: 60 Hz for physics simulation
- **Frame Budget**: 11.1ms per frame

### Spatial Computing

- **ARKit Integration**: Room mapping and hand tracking
- **RealityKit**: 3D rendering and entity management
- **Spatial Audio**: HRTF-based 3D positional audio

## Key Systems

### Combat System
- Health and damage management
- Armor mechanics
- Body part damage multipliers
- Death and respawn handling

### Weapon System
- Firing mechanics with recoil
- Reload system
- Weapon switching
- Ammo management

### Movement System
- Player locomotion
- Stance changes (standing, crouching, prone)
- Stamina management
- Physics-based movement

### AI System
- Behavior trees for enemy AI
- Tactical decision making
- Squad coordination
- Difficulty levels

### Network System
- Client-server architecture
- Lag compensation
- State synchronization
- Matchmaking

## Building & Running

### Requirements

- Xcode 16.0 or later
- visionOS 2.0 SDK
- Apple Vision Pro device or simulator
- Swift 6.0

### Build Instructions

1. Open in Xcode:
   ```bash
   open TacticalTeamShooters.xcodeproj
   ```

2. Select target device (Vision Pro)

3. Build and run (⌘R)

### Configuration

Edit `GameSettings.swift` to modify:
- Graphics quality
- Audio settings
- Control sensitivity
- Network region

## Performance Targets

| Metric | Target | Critical |
|--------|--------|----------|
| Frame Rate | 90 FPS | 60 FPS |
| Frame Time | 11.1ms | 16.6ms |
| Memory | <1.5GB | <2.5GB |
| Latency | <50ms | <100ms |

## Development Workflow

### Adding New Features

1. **Define Components**: Add to `GameComponents.swift`
2. **Create System**: Implement `GameSystem` protocol
3. **Register System**: Add to `GameCoordinator`
4. **Test**: Write unit tests

### Code Style

- Swift 6.0 with strict concurrency
- Actor-based concurrency for thread safety
- Async/await for asynchronous operations
- Value semantics for data models

## Testing

Run tests:
```bash
xcodebuild test -scheme TacticalTeamShooters
```

## Documentation

- See `ARCHITECTURE.md` for system design
- See `TECHNICAL_SPEC.md` for implementation details
- See `DESIGN.md` for game design
- See `IMPLEMENTATION_PLAN.md` for development roadmap

## Contributing

1. Follow Swift API Design Guidelines
2. Maintain 90 FPS performance target
3. Write unit tests for new systems
4. Document public APIs

## License

Proprietary - All rights reserved

## Contact

For questions or issues, contact the development team.
