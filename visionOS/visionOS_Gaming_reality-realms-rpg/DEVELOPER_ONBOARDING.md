# Reality Realms RPG - Developer Onboarding Guide

## Table of Contents

- [Welcome](#welcome)
- [Development Environment Setup](#development-environment-setup)
- [Project Structure Walkthrough](#project-structure-walkthrough)
- [Building and Running](#building-and-running)
- [Testing Procedures](#testing-procedures)
- [Common Development Workflows](#common-development-workflows)
- [Architecture Overview](#architecture-overview)
- [Code Conventions](#code-conventions)
- [Troubleshooting](#troubleshooting)
- [Resources and References](#resources-and-references)

---

## Welcome

Welcome to the Reality Realms RPG development team! This guide will help you get started with developing this groundbreaking mixed reality RPG for Apple Vision Pro.

Reality Realms transforms users' actual living spaces into persistent fantasy game worlds using visionOS spatial computing capabilities. As a developer on this project, you'll be working with cutting-edge technologies including:

- **Swift 6.0+** with strict concurrency
- **SwiftUI 5.0+** for UI
- **RealityKit 4.0+** for 3D rendering
- **ARKit 7.0+** for spatial tracking
- **visionOS 2.0+** platform features

### What Makes This Project Unique

- **Spatial Gaming**: Uses ARKit for room mapping and furniture detection
- **90 FPS Target**: Strict performance budgets for smooth VR experience
- **Entity-Component-System**: Modular, scalable game architecture
- **Event-Driven**: Decoupled communication via centralized EventBus
- **Multiplayer**: SharePlay integration for co-op gameplay

---

## Development Environment Setup

### Prerequisites

Before you begin, ensure you have the following:

#### Hardware Requirements

- **Mac**: MacBook Pro (M1/M2/M3) or Mac Studio/Pro (Apple Silicon recommended)
  - Minimum: 16GB RAM
  - Recommended: 32GB+ RAM for smooth development
- **Apple Vision Pro**: For device testing (simulator available for initial development)
- **Storage**: At least 50GB free space for Xcode, tools, and assets

#### Software Requirements

1. **macOS Sonoma (14.0) or later**
   - Latest stable version recommended
   - Check: `sw_vers` in Terminal

2. **Xcode 16.0 or later**
   - Required for visionOS SDK
   - Download from Mac App Store or [Apple Developer](https://developer.apple.com)
   - Verify installation: `xcodebuild -version`

3. **Command Line Tools**
   ```bash
   xcode-select --install
   ```

4. **Apple Developer Account**
   - Required for device testing
   - Free account sufficient for development
   - Paid account ($99/year) required for distribution

### Installing Xcode and visionOS SDK

1. **Install Xcode 16+**
   ```bash
   # From Mac App Store, or download from developer.apple.com
   # After installation, launch Xcode to complete setup
   ```

2. **Install visionOS SDK**
   - Open Xcode
   - Go to **Xcode → Settings → Platforms**
   - Download **visionOS** platform
   - This may take 30-60 minutes depending on connection

3. **Verify Installation**
   ```bash
   xcodebuild -showsdks
   # Should show visionOS 2.0 or later in the list
   ```

### Setting Up Development Tools

#### Reality Composer Pro

Used for 3D asset creation and scene setup:

1. Install from Mac App Store or with Xcode
2. Launch Reality Composer Pro
3. Verify you can create a new project

#### Version Control

1. **Install Git** (if not already installed)
   ```bash
   git --version
   # Should show git version 2.0 or later
   ```

2. **Configure Git**
   ```bash
   git config --global user.name "Your Name"
   git config --global user.email "your.email@example.com"
   ```

3. **Clone the Repository**
   ```bash
   git clone https://github.com/your-org/reality-realms-rpg.git
   cd reality-realms-rpg
   ```

#### Additional Tools (Optional but Recommended)

1. **Instruments** (included with Xcode)
   - Performance profiling
   - Memory analysis
   - Launch: `open -a Instruments`

2. **SF Symbols App**
   - Apple's system icons
   - Download from Apple Developer

3. **Blender** (for 3D modeling)
   - Download from blender.org
   - Used for custom 3D assets

---

## Project Structure Walkthrough

Understanding the project structure is crucial for effective development.

### High-Level Overview

```
visionOS_Gaming_reality-realms-rpg/
├── RealityRealms/                    # Main Xcode project
│   ├── RealityRealms.xcodeproj       # Xcode project file
│   ├── App/                          # Application entry point
│   ├── Game/                         # Core game logic
│   ├── Views/                        # SwiftUI views
│   ├── Models/                       # Data models
│   ├── Spatial/                      # Spatial computing features
│   ├── Audio/                        # Audio systems
│   ├── Persistence/                  # Save/load systems
│   ├── Multiplayer/                  # Multiplayer features
│   ├── Utils/                        # Utilities and helpers
│   ├── Resources/                    # Assets (3D models, textures, audio)
│   └── Tests/                        # Unit and integration tests
├── ARCHITECTURE.md                   # Architecture documentation
├── TECHNICAL_SPEC.md                 # Technical specifications
├── DESIGN.md                         # Design document
├── README.md                         # Project overview
└── ...                              # Other documentation files
```

### Detailed Directory Structure

#### App/

Application initialization and configuration:

```
App/
└── RealityRealmsApp.swift           # Main app entry (@main)
```

**Purpose**: App lifecycle, scene configuration, immersive space setup

**Key Files**:
- `RealityRealmsApp.swift`: Defines WindowGroup and ImmersiveSpace

#### Game/

Core game logic using Entity-Component-System architecture:

```
Game/
├── GameLogic/
│   └── GameLoop.swift               # 90 FPS game loop
├── GameState/
│   └── GameStateManager.swift       # State machine
├── Entities/
│   └── GameEntity.swift             # ECS implementation
├── Components/                      # Game components
│   ├── HealthComponent.swift
│   ├── CombatComponent.swift
│   ├── AIComponent.swift
│   └── ...
└── Systems/                         # Game systems
    ├── CombatSystem.swift
    ├── AISystem.swift
    └── ...
```

**Purpose**: Game mechanics, entities, components, and systems

**Key Concepts**:
- **Entities**: Game objects (players, enemies, NPCs)
- **Components**: Data containers (health, position, AI state)
- **Systems**: Logic processors (combat, movement, AI)

#### Views/

SwiftUI user interface:

```
Views/
├── UI/
│   ├── MainMenuView.swift           # Main menu
│   ├── GameView.swift               # Immersive game view
│   ├── SettingsView.swift           # Settings panel
│   └── InventoryView.swift          # Inventory UI
└── HUD/
    ├── HUDView.swift                # Heads-up display
    ├── HealthOrbView.swift          # Health display
    └── ManaOrbView.swift            # Mana display
```

**Purpose**: All user-facing UI components

**Pattern**: SwiftUI views with MVVM architecture

#### Utils/

Shared utilities and core systems:

```
Utils/
├── EventBus.swift                   # Event system
├── PerformanceMonitor.swift         # Performance tracking
├── Extensions/                      # Swift extensions
└── Helpers/                         # Helper functions
```

**Purpose**: Cross-cutting concerns and reusable utilities

**Key Systems**:
- **EventBus**: Publish-subscribe event system
- **PerformanceMonitor**: FPS tracking and quality scaling

#### Resources/

Game assets and resources:

```
Resources/
├── Assets.xcassets                  # Images and icons
├── Models/                          # 3D models (.usdz, .reality)
├── Textures/                        # Texture files
├── Audio/                           # Sound effects and music
└── Shaders/                         # Metal shaders
```

**Purpose**: All non-code assets

**Asset Guidelines**:
- Use USDZ for 3D models
- Optimize textures (max 2048x2048 for performance)
- Audio: AAC format, 44.1kHz

#### Tests/

Automated tests:

```
Tests/
├── Unit/                            # Unit tests
│   ├── GameStateManagerTests.swift
│   ├── EventBusTests.swift
│   └── EntityComponentTests.swift
├── Integration/                     # Integration tests
│   └── IntegrationTests.swift
├── Performance/                     # Performance tests
│   └── PerformanceTests.swift
└── VisionOSSpecific/               # visionOS-specific tests
    └── SpatialTests.md
```

**Purpose**: Quality assurance and regression prevention

**Test Coverage Target**: 80%+ for core systems

---

## Building and Running

### Opening the Project

1. **Open in Xcode**
   ```bash
   cd visionOS_Gaming_reality-realms-rpg
   open RealityRealms/RealityRealms.xcodeproj
   ```

2. **Wait for Indexing**
   - First open may take 5-10 minutes as Xcode indexes the project
   - Status shown in top center of Xcode window

### Selecting a Target

Xcode toolbar → Select target device:

- **visionOS Simulator (Designed for iPad)**: For development without hardware
- **Apple Vision Pro (Your Device)**: For device testing

### Building the Project

#### Method 1: Xcode GUI

1. Select target device from toolbar
2. Click **Product → Build** (⌘B)
3. Wait for build to complete (check progress in top bar)
4. Fix any build errors (see Troubleshooting section)

#### Method 2: Command Line

```bash
# Build for simulator
xcodebuild -project RealityRealms/RealityRealms.xcodeproj \
           -scheme RealityRealms \
           -destination 'platform=visionOS Simulator,name=Apple Vision Pro'

# Build for device (requires signing)
xcodebuild -project RealityRealms/RealityRealms.xcodeproj \
           -scheme RealityRealms \
           -destination 'platform=visionOS,name=Your Vision Pro'
```

### Running the App

#### On Simulator

1. **Launch Simulator**
   - Xcode → **Product → Run** (⌘R)
   - Or: `open -a Simulator`

2. **First Run Setup**
   - Simulator will boot (may take 1-2 minutes first time)
   - App installs and launches automatically
   - Grant permissions when prompted

3. **Simulating Spatial Features**
   - Note: Some features (hand tracking, room mapping) are limited in simulator
   - Use mock data for testing (see Testing section)

#### On Device

1. **Connect Vision Pro**
   - Connect via USB-C cable
   - Trust computer when prompted on device

2. **Enable Developer Mode**
   - Settings → Privacy & Security → Developer Mode → ON
   - Device will restart

3. **Run from Xcode**
   - Select "Apple Vision Pro" as target
   - Click Run (⌘R)
   - Enter device passcode if prompted

4. **Grant Permissions**
   App requires:
   - Camera access (room mapping)
   - Hand tracking
   - World sensing

### First Launch Experience

When you run the app for the first time:

1. **Main Menu Appears**
   - Welcome screen with game logo
   - Options: New Game, Continue, Settings

2. **New Game Flow**
   - Permission requests
   - Room scanning tutorial
   - Character class selection
   - Tutorial gameplay

3. **Development Testing**
   - Use Settings → Developer Options to:
     - Skip tutorials
     - Enable debug overlay
     - Load test scenarios

---

## Testing Procedures

### Unit Testing

#### Running All Tests

```bash
# Command line
xcodebuild test -project RealityRealms/RealityRealms.xcodeproj \
                -scheme RealityRealms \
                -destination 'platform=visionOS Simulator'

# Or in Xcode: Product → Test (⌘U)
```

#### Running Specific Tests

```bash
# Run specific test class
xcodebuild test -only-testing:RealityRealmsTests/EventBusTests

# Run specific test method
xcodebuild test -only-testing:RealityRealmsTests/EventBusTests/testPublishSubscribe
```

#### Writing Unit Tests

Example test structure:

```swift
import XCTest
@testable import RealityRealms

class MyFeatureTests: XCTestCase {
    var sut: MyFeature!  // System Under Test

    override func setUp() {
        super.setUp()
        sut = MyFeature()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testFeatureBehavior() {
        // Given (Arrange)
        let input = "test input"

        // When (Act)
        let result = sut.process(input)

        // Then (Assert)
        XCTAssertEqual(result, "expected output")
    }
}
```

### Integration Testing

Integration tests verify that multiple systems work together:

```swift
class GameFlowIntegrationTests: XCTestCase {
    func testCombatFlow() async throws {
        // Create player and enemy
        let player = Player(characterClass: .warrior)
        let enemy = Enemy(enemyType: .goblin)

        // Subscribe to events
        var damageReceived = false
        EventBus.shared.subscribe(DamageDealtEvent.self) { event in
            damageReceived = true
        }

        // Perform attack
        let combatSystem = CombatSystem()
        combatSystem.performAttack(attacker: player, target: enemy)

        // Verify
        try await Task.sleep(for: .milliseconds(100))
        XCTAssertTrue(damageReceived)
    }
}
```

### Performance Testing

Measure performance to ensure 90 FPS target:

```swift
class PerformanceTests: XCTestCase {
    func testGameLoopPerformance() {
        measure(metrics: [XCTClockMetric()]) {
            let gameLoop = GameLoop()

            // Simulate 1 second at 90 FPS
            for _ in 0..<90 {
                gameLoop.update(deltaTime: 1.0 / 90.0)
            }
        }
    }

    func testMemoryUsage() {
        measure(metrics: [XCTMemoryMetric()]) {
            let scene = GameScene.createTestScene()
            scene.loadAllAssets()
        }
    }
}
```

### Testing Best Practices

1. **Test Coverage**
   - Aim for 80%+ coverage on core systems
   - View coverage: Editor → Code Coverage (⌘9)

2. **Fast Tests**
   - Unit tests should run in milliseconds
   - Use mocks for slow operations

3. **Isolated Tests**
   - Each test should be independent
   - Clean up in `tearDown()`

4. **Descriptive Names**
   - `testEventBusPublishesEventsToSubscribers()`
   - Not: `testEventBus()`

5. **Test Both Success and Failure**
   - Happy path and error cases
   - Edge cases and boundary conditions

---

## Common Development Workflows

### Adding a New Feature

1. **Create Feature Branch**
   ```bash
   git checkout -b feature/new-spell-system
   ```

2. **Implement Feature**
   - Add components/systems as needed
   - Follow existing patterns

3. **Write Tests**
   - Unit tests for new code
   - Integration tests for interactions

4. **Update Documentation**
   - Add code comments
   - Update relevant .md files

5. **Test Locally**
   ```bash
   xcodebuild test
   ```

6. **Commit and Push**
   ```bash
   git add .
   git commit -m "Add new spell casting system"
   git push origin feature/new-spell-system
   ```

7. **Create Pull Request**
   - Describe changes
   - Link to issue/ticket
   - Request review

### Adding a New Game Entity

Example: Adding a new enemy type

1. **Define Enemy Type**
   ```swift
   // In GameEntity.swift
   enum EnemyType {
       // ... existing types
       case dragon

       var stats: EnemyStats {
           // ... existing cases
           case .dragon:
               return EnemyStats(
                   health: 500,
                   damage: 50,
                   defense: 20,
                   attackSpeed: 0.5,
                   range: 3.0
               )
       }
   }
   ```

2. **Create Enemy Instance**
   ```swift
   let dragon = Enemy(enemyType: .dragon)
   ```

3. **Add Custom Behavior (if needed)**
   ```swift
   class DragonAI: AIComponent {
       func breathFire() {
           // Custom attack logic
       }
   }
   ```

4. **Add 3D Model**
   - Place model in `Resources/Models/dragon.usdz`
   - Update asset catalog

5. **Test**
   ```swift
   func testDragonCreation() {
       let dragon = Enemy(enemyType: .dragon)
       XCTAssertEqual(dragon.enemyType, .dragon)

       let health = dragon.getComponent(HealthComponent.self)
       XCTAssertEqual(health?.maximum, 500)
   }
   ```

### Adding a New Event Type

1. **Define Event**
   ```swift
   // In EventBus.swift
   struct SpellCastEvent: GameEvent {
       let casterID: UUID
       let spellType: SpellType
       let targetPosition: SIMD3<Float>
       let timestamp: Date = Date()
   }
   ```

2. **Publish Event**
   ```swift
   EventBus.shared.publish(SpellCastEvent(
       casterID: player.id,
       spellType: .fireball,
       targetPosition: targetPos
   ))
   ```

3. **Subscribe to Event**
   ```swift
   EventBus.shared.subscribe(SpellCastEvent.self) { event in
       print("Spell cast: \(event.spellType)")
       // Handle spell casting
   }
   ```

### Debugging Tips

#### Using Xcode Debugger

1. **Set Breakpoints**
   - Click on line number in gutter
   - Conditional: Right-click → Edit Breakpoint

2. **LLDB Commands**
   ```
   po variable          # Print object
   p variable           # Print value
   expr variable = 10   # Modify value
   bt                   # Backtrace
   c                    # Continue
   ```

3. **Debug Overlays**
   - Enable debug overlay in Settings
   - Shows FPS, memory, entity count

#### Common Debug Scenarios

**Event not firing:**
```swift
// Verify subscription
EventBus.shared.subscribe(MyEvent.self) { event in
    print("Event received: \(event)")  // Add log
}

// Verify publish
EventBus.shared.publish(MyEvent(...))
print("Event published")  // Add log
```

**State transition not working:**
```swift
// Check transition validity
print("Current state: \(gameStateManager.currentState)")
print("Can transition: \(gameStateManager.canTransition(from: current, to: new))")
```

**Performance issues:**
```swift
// Use PerformanceMonitor
PerformanceMonitor.shared.logPerformanceStats()

// Or Instruments:
// Product → Profile (⌘I) → Time Profiler
```

---

## Architecture Overview

### Entity-Component-System (ECS)

Reality Realms uses ECS for flexibility and performance:

#### Entities

Game objects with unique IDs:

```swift
protocol GameEntity: AnyObject, Identifiable {
    var id: UUID { get }
    var components: [Component.Type: any Component] { get set }
    var transform: Transform { get set }
    var isActive: Bool { get set }
}
```

#### Components

Pure data containers:

```swift
protocol Component: AnyObject {
    var entityID: UUID { get }
}

class HealthComponent: Component {
    let entityID: UUID
    var current: Int
    var maximum: Int
    // ... methods
}
```

#### Systems

Process entities with specific components:

```swift
class CombatSystem {
    func update(entities: [GameEntity], deltaTime: TimeInterval) {
        for entity in entities where entity.hasComponent(CombatComponent.self) {
            // Process combat logic
        }
    }
}
```

### Event-Driven Architecture

Decoupled communication via EventBus:

```swift
// Publisher
EventBus.shared.publish(DamageDealtEvent(
    attackerID: attacker.id,
    targetID: target.id,
    damage: 25,
    damageType: .physical,
    isCritical: false
))

// Subscriber
EventBus.shared.subscribe(DamageDealtEvent.self) { event in
    // Handle damage
    updateHealthBar(for: event.targetID, damage: event.damage)
}
```

### State Management

Hierarchical state machine:

```swift
enum GameState {
    case initialization
    case roomScanning
    case tutorial
    case gameplay(GameplayState)
    case paused
    case loading(String)
    case error(String)
}

GameStateManager.shared.transition(to: .gameplay(.exploration))
```

---

## Code Conventions

### Swift Style Guide

Follow Apple's Swift API Design Guidelines:

1. **Naming**
   - Types: `PascalCase` (e.g., `GameEntity`, `HealthComponent`)
   - Functions/Variables: `camelCase` (e.g., `updateHealth`, `currentFPS`)
   - Constants: `camelCase` (e.g., `targetFPS`, not `TARGET_FPS`)

2. **Type Inference**
   ```swift
   // Good
   let health = 100

   // Avoid unless clarity needed
   let health: Int = 100
   ```

3. **Optionals**
   ```swift
   // Use guard for early exit
   guard let health = entity.getComponent(HealthComponent.self) else {
       return
   }

   // Use if let for scoped unwrapping
   if let damage = calculateDamage() {
       applyDamage(damage)
   }
   ```

4. **Access Control**
   ```swift
   // Prefer private/private(set) for encapsulation
   @Published private(set) var currentFPS: Double
   ```

### Concurrency

Use Swift 6.0 strict concurrency:

```swift
// MainActor for UI
@MainActor
class GameStateManager: ObservableObject {
    @Published var currentState: GameState
}

// Async operations
func loadAssets() async throws {
    let model = try await loadModel("character.usdz")
    await MainActor.run {
        self.applyModel(model)
    }
}
```

### Comments

```swift
// MARK: - Section Headers
// Use MARK for logical sections

/// Documentation comments for public APIs
/// - Parameter entity: The entity to update
/// - Returns: Updated entity state
func updateEntity(_ entity: GameEntity) -> EntityState {
    // Implementation comments for complex logic
    // Explain WHY, not WHAT
}
```

### Error Handling

```swift
// Use typed errors
enum GameError: Error, LocalizedError {
    case roomMappingFailed
    case insufficientSpace

    var errorDescription: String? {
        switch self {
        case .roomMappingFailed:
            return "Failed to map room"
        case .insufficientSpace:
            return "Need at least 2m x 2m space"
        }
    }
}

// Propagate errors
func scanRoom() throws -> RoomLayout {
    guard hasPermission else {
        throw GameError.roomMappingFailed
    }
    // ...
}
```

---

## Troubleshooting

### Build Errors

#### "No such module 'RealityKit'"

**Cause**: visionOS SDK not installed

**Solution**:
```bash
# Verify visionOS SDK
xcodebuild -showsdks | grep visionOS

# If missing, install via Xcode → Settings → Platforms
```

#### Code Signing Errors

**Cause**: Team not configured

**Solution**:
1. Open project settings
2. Select target → Signing & Capabilities
3. Choose your Apple Developer team

#### Build Failed with Concurrency Errors

**Cause**: Swift 6.0 strict concurrency

**Solution**:
```swift
// Add @MainActor to classes that access UI
@MainActor
class MyViewModel: ObservableObject {
    // ...
}

// Or mark functions
@MainActor
func updateUI() {
    // ...
}
```

### Runtime Issues

#### App Crashes on Launch

**Check**:
1. Console logs (⌘Y in Xcode)
2. Crash reports: Window → Devices and Simulators → View Device Logs
3. Enable Exception Breakpoint (⌘8 → + → Exception Breakpoint)

#### Performance Issues (Low FPS)

**Debug Steps**:
1. Enable debug overlay to see FPS
2. Profile with Instruments:
   ```bash
   # Product → Profile (⌘I) → Time Profiler
   ```
3. Check PerformanceMonitor logs:
   ```swift
   PerformanceMonitor.shared.logPerformanceStats()
   ```

#### Spatial Tracking Lost

**Solutions**:
- Ensure adequate lighting
- Look around to re-establish tracking
- Check console for ARKit errors

### Testing Issues

#### Tests Timing Out

**Solution**:
```swift
// Increase timeout for async tests
func testAsyncOperation() async throws {
    let expectation = XCTestExpectation()

    // ... test code

    await fulfillment(of: [expectation], timeout: 10.0)  // Increase timeout
}
```

#### Test Database/State Pollution

**Solution**:
```swift
override func tearDown() {
    // Clean up shared state
    EventBus.shared.clear()
    GameStateManager.shared.reset()
    super.tearDown()
}
```

---

## Resources and References

### Official Documentation

1. **visionOS**
   - [visionOS Developer Portal](https://developer.apple.com/visionos/)
   - [visionOS Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/visionos)

2. **RealityKit**
   - [RealityKit Documentation](https://developer.apple.com/documentation/realitykit)
   - [Reality Composer Pro](https://developer.apple.com/augmented-reality/tools/)

3. **ARKit**
   - [ARKit Documentation](https://developer.apple.com/documentation/arkit)
   - [World Tracking](https://developer.apple.com/documentation/arkit/arworldtrackingconfiguration)

4. **Swift**
   - [Swift Language Guide](https://docs.swift.org/swift-book/)
   - [Swift Concurrency](https://docs.swift.org/swift-book/LanguageGuide/Concurrency.html)
   - [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)

### Project Documentation

1. **ARCHITECTURE.md** - Technical architecture
2. **TECHNICAL_SPEC.md** - Detailed specifications
3. **DESIGN.md** - Game design document
4. **API_DOCUMENTATION.md** - API reference
5. **PERFORMANCE_PROFILING.md** - Performance guide

### WWDC Sessions

Key sessions for visionOS development:

- WWDC 2024: "Meet visionOS"
- WWDC 2024: "Build great games for spatial computing"
- WWDC 2024: "Explore RealityKit 4"
- WWDC 2024: "Optimize for spatial gaming"

### Community Resources

1. **Apple Developer Forums**
   - [visionOS Forum](https://developer.apple.com/forums/tags/visionos)

2. **Sample Code**
   - [Apple Sample Code](https://developer.apple.com/sample-code/)
   - Search for "visionOS" and "RealityKit"

3. **Recommended Books**
   - "Building visionOS Apps" (Apple)
   - "Swift Programming: The Big Nerd Ranch Guide"

### Tools and Utilities

1. **Xcode Instruments**
   - Time Profiler: CPU usage
   - Allocations: Memory tracking
   - Leaks: Memory leak detection

2. **Reality Converter**
   - Convert 3D models to USDZ
   - [Download](https://developer.apple.com/augmented-reality/tools/)

3. **SF Symbols**
   - System icon library
   - [SF Symbols App](https://developer.apple.com/sf-symbols/)

### Getting Help

1. **Internal**
   - Check existing documentation first
   - Ask in team Slack channel
   - Code reviews for architectural questions

2. **External**
   - Apple Developer Forums
   - Stack Overflow (tag: visionos, realitykit)
   - File bug reports: [Feedback Assistant](https://feedbackassistant.apple.com)

### Next Steps

Now that you're set up:

1. **Run the app** and explore the features
2. **Read ARCHITECTURE.md** to understand the system design
3. **Review existing code** in a feature area you'll work on
4. **Write a simple test** to familiarize yourself with the codebase
5. **Pick up your first task** from the issue tracker

Welcome to the team! We're excited to build the future of spatial gaming together.

---

**Last Updated**: 2025-11-19
**Maintained By**: Reality Realms Development Team
