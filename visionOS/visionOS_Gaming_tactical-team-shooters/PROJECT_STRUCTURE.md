# Project Structure

Detailed overview of the Tactical Team Shooters project structure.

## Directory Layout

```
visionOS_Gaming_tactical-team-shooters/
├── .github/                    # GitHub configuration
│   ├── workflows/             # CI/CD workflows
│   │   └── ci.yml            # Main CI pipeline
│   ├── ISSUE_TEMPLATE/        # Issue templates
│   │   ├── bug_report.md
│   │   └── feature_request.md
│   └── pull_request_template.md
├── TacticalTeamShooters/      # Main application
│   ├── App/                   # Application entry point
│   │   └── TacticalTeamShootersApp.swift
│   ├── Models/                # Data models
│   │   ├── Player.swift
│   │   ├── Weapon.swift
│   │   └── Team.swift
│   ├── Views/                 # UI components
│   │   ├── UI/               # Standard UI views
│   │   │   ├── MainMenuView.swift
│   │   │   ├── SettingsView.swift
│   │   │   └── TeamLobbyView.swift
│   │   └── HUD/              # In-game HUD
│   │       └── GameHUDView.swift
│   ├── Scenes/                # RealityKit scenes
│   │   └── GameScene/
│   │       └── BattlefieldView.swift
│   ├── Systems/               # Game systems (ECS)
│   │   ├── NetworkSystem/
│   │   │   └── NetworkManager.swift
│   │   ├── PhysicsSystem/
│   │   ├── AudioSystem/
│   │   └── InputSystem/
│   ├── Game/                  # Game logic
│   │   ├── GameState/
│   │   │   └── GameStateManager.swift
│   │   ├── Weapons/
│   │   └── Maps/
│   ├── Resources/             # Assets
│   │   ├── Models/           # 3D models
│   │   ├── Textures/         # Textures
│   │   ├── Audio/            # Sound effects
│   │   └── Maps/             # Map data
│   ├── Tests/                 # Test files
│   │   ├── Models/           # Model tests
│   │   │   ├── PlayerTests.swift
│   │   │   ├── WeaponTests.swift
│   │   │   └── TeamTests.swift
│   │   ├── Integration/      # Integration tests
│   │   │   └── NetworkIntegrationTests.swift
│   │   └── README.md
│   └── Info.plist            # App configuration
├── landing-page/              # Marketing website
│   ├── index.html
│   ├── styles.css
│   └── script.js
├── scripts/                   # Development scripts
│   └── pre-commit-hook.sh
├── docs/                      # Documentation
│   ├── ARCHITECTURE.md
│   ├── TECHNICAL_SPEC.md
│   └── DESIGN.md
├── Package.swift              # Swift Package Manager
├── .gitignore
├── .swiftlint.yml            # SwiftLint config
├── README.md
├── CONTRIBUTING.md
├── LICENSE
└── CHANGELOG.md
```

## Key Directories

### `/TacticalTeamShooters/App/`

Application entry point and configuration.

**Files**:
- `TacticalTeamShootersApp.swift` - Main app struct with SwiftUI scene configuration

### `/TacticalTeamShooters/Models/`

Data models representing game entities.

**Purpose**: Define core data structures using Swift structs for value semantics.

**Key Files**:
- `Player.swift` - Player data, stats, loadout
- `Weapon.swift` - Weapon stats, types, attachments
- `Team.swift` - Team data, matches, rounds

**Conventions**:
- Use `struct` for data models
- Conform to `Codable` for serialization
- Conform to `Identifiable` where needed
- Use computed properties for derived data

### `/TacticalTeamShooters/Views/`

SwiftUI views for UI and HUD.

**Subdirectories**:
- `UI/` - Standard menu views
- `HUD/` - In-game heads-up display

**Purpose**: All user interface components.

**Conventions**:
- Use SwiftUI declarative syntax
- Extract reusable components
- Keep views focused and composable

### `/TacticalTeamShooters/Scenes/`

RealityKit 3D scenes for gameplay.

**Purpose**: 3D game environments using RealityKit.

**Key Files**:
- `BattlefieldView.swift` - Main gameplay scene

**Conventions**:
- Use RealityView for 3D content
- Integrate ARKit for spatial features
- Optimize for 120 FPS

### `/TacticalTeamShooters/Systems/`

ECS (Entity-Component-System) game systems.

**Subdirectories**:
- `NetworkSystem/` - Multiplayer networking
- `PhysicsSystem/` - Physics and collisions
- `AudioSystem/` - Spatial audio
- `InputSystem/` - Player input handling

**Purpose**: Separate concerns into independent systems.

**Conventions**:
- Each system operates on specific components
- Systems are updated each frame
- Use actors for thread safety

### `/TacticalTeamShooters/Game/`

Game logic and state management.

**Subdirectories**:
- `GameState/` - Game state machine
- `Weapons/` - Weapon behavior
- `Maps/` - Map definitions

**Purpose**: Core gameplay logic.

### `/TacticalTeamShooters/Resources/`

Game assets (models, textures, audio).

**Subdirectories**:
- `Models/` - 3D models (.usdz, .reality)
- `Textures/` - Texture files
- `Audio/` - Sound effects and music
- `Maps/` - Map data files

**Asset Guidelines**:
- Compress textures (ASTC/BC7)
- Optimize polygon counts
- Use appropriate file formats

### `/TacticalTeamShooters/Tests/`

All test files.

**Structure**:
- `Models/` - Unit tests for models
- `Integration/` - Integration tests
- `UI/` - UI tests

**Naming**: `{Type}Tests.swift`

See [TESTING_STRATEGY.md](TESTING_STRATEGY.md)

### `/scripts/`

Development and build scripts.

**Files**:
- `pre-commit-hook.sh` - Git pre-commit checks
- `build.sh` - Build automation
- `test.sh` - Test running

### `/docs/`

Project documentation.

**Key Files**:
- `ARCHITECTURE.md` - System architecture
- `TECHNICAL_SPEC.md` - Technical specifications
- `DESIGN.md` - Game design document

## File Naming Conventions

### Swift Files

- **Types**: `Player.swift`, `Weapon.swift`
- **Views**: `MainMenuView.swift`, `GameHUDView.swift`
- **Tests**: `PlayerTests.swift`, `WeaponTests.swift`
- **Extensions**: `Player+Extensions.swift`
- **Protocols**: `Damageable.swift`, `Movable.swift`

### Assets

- **Models**: `weapon_ak47.usdz`, `map_warehouse.reality`
- **Textures**: `metal_panel_diffuse.png`, `concrete_normal.png`
- **Audio**: `gunshot_ak47.wav`, `footstep_concrete.wav`

## Code Organization

### Within Files

```swift
// 1. Imports
import SwiftUI
import RealityKit

// 2. Type definition
struct Player {
    // 3. Properties
    let id: UUID
    var username: String

    // 4. Computed properties
    var displayName: String { username }

    // 5. Initializers
    init(username: String) {
        self.id = UUID()
        self.username = username
    }

    // 6. Methods
    func takeDamage(_ amount: Double) {
        // ...
    }
}

// 7. Extensions
extension Player: Codable { }
```

## Dependencies

### External (via SPM)

Currently no external dependencies - using Apple frameworks only:
- SwiftUI
- RealityKit
- ARKit
- MultipeerConnectivity
- AVFoundation

### Internal

- Models are dependency-free
- Views depend on Models
- Systems depend on Models
- Game logic orchestrates Systems

## Build Products

### Debug Build

- Location: `.build/debug/`
- Optimizations: Disabled
- Assertions: Enabled
- Logging: Verbose

### Release Build

- Location: `.build/release/`
- Optimizations: Enabled (-O)
- Assertions: Disabled
- Logging: Minimal

## Adding New Files

### New Model

1. Create in `TacticalTeamShooters/Models/`
2. Conform to `Codable`, `Identifiable`
3. Add corresponding test file
4. Update documentation

### New View

1. Create in `TacticalTeamShooters/Views/UI/` or `/HUD/`
2. Use SwiftUI
3. Extract reusable components
4. Add preview provider for development

### New System

1. Create in `TacticalTeamShooters/Systems/{SystemName}/`
2. Implement system update logic
3. Use actor for thread safety
4. Add integration tests

## Documentation Location

- **API Docs**: `API_DOCUMENTATION.md`
- **Architecture**: `ARCHITECTURE.md`
- **Contributing**: `CONTRIBUTING.md`
- **Deployment**: `DEPLOYMENT.md`
- **Performance**: `PERFORMANCE_OPTIMIZATION.md`
- **Troubleshooting**: `TROUBLESHOOTING.md`

## Questions?

See [CONTRIBUTING.md](CONTRIBUTING.md) or open an issue.
