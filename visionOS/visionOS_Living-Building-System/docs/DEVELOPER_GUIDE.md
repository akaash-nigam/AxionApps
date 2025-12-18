# Developer Guide
## Living Building System

Welcome to the Living Building System development team! This guide will help you understand the architecture, set up your development environment, and contribute effectively.

## Table of Contents

1. [Quick Start](#quick-start)
2. [Architecture Overview](#architecture-overview)
3. [Project Structure](#project-structure)
4. [Development Workflow](#development-workflow)
5. [Testing Strategy](#testing-strategy)
6. [Debugging Tips](#debugging-tips)
7. [Common Patterns](#common-patterns)
8. [Performance Considerations](#performance-considerations)
9. [Troubleshooting](#troubleshooting)

---

## Quick Start

### Prerequisites

- **macOS**: 14.0 or later
- **Xcode**: 15.2 or later
- **Swift**: 6.0 or later
- **visionOS SDK**: 2.0 or later
- **Git**: Latest version
- **Homebrew**: For installing dependencies

### Setup (5 minutes)

```bash
# 1. Clone the repository
git clone https://github.com/OWNER/visionOS_Living-Building-System.git
cd visionOS_Living-Building-System

# 2. Install development tools
brew install swiftlint swift-format

# 3. Open the project
cd LivingBuildingSystem
open Package.swift

# 4. Select scheme
# In Xcode: Product > Scheme > LivingBuildingSystem

# 5. Select destination
# In Xcode: Product > Destination > Apple Vision Pro (Simulator)

# 6. Build and run
# Press Cmd+R

# 7. Run tests
# Press Cmd+U
```

### First Contribution

1. **Read**: [CONTRIBUTING.md](../CONTRIBUTING.md)
2. **Find**: Look for `good first issue` label
3. **Branch**: Create feature branch
4. **Code**: Make your changes
5. **Test**: Run `xcodebuild test`
6. **Lint**: Run `swiftlint`
7. **PR**: Submit pull request

---

## Architecture Overview

### Clean Architecture Layers

Living Building System follows Clean Architecture with clear separation of concerns:

```
┌─────────────────────────────────────────┐
│         Presentation Layer              │
│  (SwiftUI Views, ViewModels)            │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│         Application Layer               │
│  (Managers, Use Cases)                  │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│           Domain Layer                  │
│  (Models, Business Logic)               │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│            Data Layer                   │
│  (Services, Persistence)                │
└─────────────────────────────────────────┘
```

### Layer Responsibilities

#### 1. Presentation Layer (`Presentation/`)
- **Purpose**: User interface and user interaction
- **Technologies**: SwiftUI, RealityKit
- **Components**:
  - `WindowViews/`: Traditional 2D windows
  - `ImmersiveViews/`: 3D immersive spaces
  - View modifiers and custom components

**Example**:
```swift
struct DashboardView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        NavigationStack {
            DeviceGridSection()
        }
    }
}
```

#### 2. Application Layer (`Application/`)
- **Purpose**: Orchestrate business logic
- **Pattern**: Manager pattern
- **Components**:
  - `DeviceManager`: Device discovery and control
  - `EnergyManager`: Energy monitoring and analysis
  - `PersistenceManager`: Data persistence
  - `SpatialManager`: ARKit and spatial features

**Example**:
```swift
@MainActor
class DeviceManager {
    private let appState: AppState
    private let homeKitService: HomeKitServiceProtocol

    func discoverDevices() async throws {
        let devices = try await homeKitService.discoverDevices()
        appState.devices = devices.reduce(into: [:]) { $0[$1.id] = $1 }
    }
}
```

#### 3. Domain Layer (`Domain/`)
- **Purpose**: Business entities and rules
- **Technologies**: SwiftData models
- **Components**:
  - `Models/`: Core entities (Home, Room, Device, User, Energy)
  - `State/`: App state with @Observable
  - Business logic methods on models

**Example**:
```swift
@Model
final class EnergyReading {
    var timestamp: Date
    var energyType: EnergyType
    var instantaneousPower: Double?

    func calculateCost(configuration: EnergyConfiguration) -> Double {
        (cumulativeConsumption ?? 0) * configuration.electricityRatePerKWh
    }
}
```

#### 4. Data Layer (`Integrations/`, `Utilities/`)
- **Purpose**: External data sources
- **Pattern**: Protocol-oriented design
- **Components**:
  - `HomeKit/`: HomeKit integration
  - `Energy/`: Energy meter integration
  - `Persistence`: SwiftData persistence
  - `Logger`: Logging utility

**Example**:
```swift
actor EnergyService: EnergyServiceProtocol {
    func getCurrentReading(type: EnergyType) async throws -> EnergyReading {
        // Implementation
    }
}
```

### State Management

We use Swift's native `@Observable` macro for reactive state management:

```swift
@Observable
class AppState {
    var devices: [UUID: SmartDevice] = [:]
    var currentHome: Home?
    var currentUser: User?
    var error: LBSError?

    // Computed properties
    var devicesList: [SmartDevice] {
        Array(devices.values).sorted { $0.name < $1.name }
    }
}
```

**Benefits**:
- No external dependencies (no Combine)
- Automatic view updates
- Thread-safe with `@MainActor`
- Clean and simple

### Concurrency Model

#### Actors for Thread Safety

```swift
actor EnergyService {
    private var isMonitoring = false

    func startMonitoring() async {
        // Safe concurrent access
    }
}
```

#### @MainActor for UI

```swift
@MainActor
class DeviceManager {
    // Guaranteed to run on main thread
    func updateUI() {
        // Safe UI updates
    }
}
```

#### Task Groups for Parallel Work

```swift
await withTaskGroup(of: SmartDevice.self) { group in
    for deviceID in deviceIDs {
        group.addTask {
            try await self.fetchDevice(deviceID)
        }
    }
}
```

---

## Project Structure

```
LivingBuildingSystem/
│
├── Package.swift                          # Swift Package definition
├── Sources/
│   └── LivingBuildingSystem/
│       │
│       ├── App/
│       │   └── LivingBuildingSystemApp.swift  # App entry point
│       │
│       ├── Domain/
│       │   ├── Models/
│       │   │   ├── Home.swift             # Home entity
│       │   │   ├── Room.swift             # Room entity
│       │   │   ├── SmartDevice.swift      # Device entity
│       │   │   ├── User.swift             # User entity
│       │   │   ├── EnergyReading.swift    # Energy data
│       │   │   └── ...
│       │   └── State/
│       │       └── AppState.swift         # Global app state
│       │
│       ├── Application/
│       │   └── Managers/
│       │       ├── DeviceManager.swift    # Device business logic
│       │       ├── EnergyManager.swift    # Energy business logic
│       │       ├── PersistenceManager.swift  # Data persistence
│       │       └── SpatialManager.swift   # Spatial features
│       │
│       ├── Integrations/
│       │   ├── HomeKit/
│       │   │   ├── HomeKitServiceProtocol.swift
│       │   │   └── HomeKitService.swift   # HomeKit integration
│       │   └── Energy/
│       │       ├── EnergyServiceProtocol.swift
│       │       └── EnergyService.swift    # Energy meter integration
│       │
│       ├── Presentation/
│       │   ├── WindowViews/
│       │   │   ├── DashboardView.swift    # Main dashboard
│       │   │   ├── DeviceDetailView.swift  # Device details
│       │   │   ├── EnergyDashboardView.swift  # Energy dashboard
│       │   │   ├── SettingsView.swift     # Settings
│       │   │   └── OnboardingView.swift   # First-launch
│       │   └── ImmersiveViews/
│       │       ├── HomeImmersiveView.swift  # 3D home view
│       │       └── RoomScanView.swift     # Room scanning
│       │
│       └── Utilities/
│           ├── Constants/
│           │   └── LBSError.swift         # Error types
│           └── Helpers/
│               └── Logger.swift           # Logging utility
│
├── Tests/
│   └── LivingBuildingSystemTests/
│       ├── ModelTests/                    # Model unit tests
│       ├── ServiceTests/                  # Service integration tests
│       └── ManagerTests/                  # Manager unit tests
│
├── docs/                                  # Documentation
│   ├── design/                            # Design docs
│   ├── testing/                           # Test documentation
│   └── app-store/                         # App Store materials
│
└── landing-page/                          # Marketing website
```

### File Naming Conventions

- **Models**: `EntityName.swift` (e.g., `Home.swift`)
- **Views**: `PurposeView.swift` (e.g., `DashboardView.swift`)
- **Managers**: `PurposeManager.swift` (e.g., `DeviceManager.swift`)
- **Services**: `PurposeService.swift` (e.g., `EnergyService.swift`)
- **Protocols**: `NameProtocol.swift` (e.g., `EnergyServiceProtocol.swift`)
- **Tests**: `SubjectTests.swift` (e.g., `HomeTests.swift`)

---

## Development Workflow

### 1. Pick an Issue

- Browse [Issues](github-issues-url)
- Look for `good first issue` or `help wanted` labels
- Comment to claim the issue
- Ask questions if unclear

### 2. Create a Branch

```bash
# Feature
git checkout -b feature/add-device-scenes

# Bug fix
git checkout -b fix/device-discovery-crash

# Documentation
git checkout -b docs/update-architecture-guide
```

### 3. Develop

#### Write Code

```swift
// Follow Swift style guide
// Use MARK comments for organization
// Add inline documentation for public APIs

// MARK: - Public Methods

/// Discovers all HomeKit devices on the local network.
///
/// - Returns: Array of discovered smart devices
/// - Throws: `LBSError` if discovery fails
func discoverDevices() async throws -> [SmartDevice] {
    // Implementation
}
```

#### Write Tests

```swift
// Test every public method
// Use Given-When-Then pattern
// Test edge cases

func testDiscoverDevicesWithNoDevices() async throws {
    // Given
    let service = MockHomeKitService()
    let manager = DeviceManager(appState: appState, homeKitService: service)

    // When
    let devices = try await manager.discoverDevices()

    // Then
    XCTAssertTrue(devices.isEmpty)
}
```

#### Run SwiftLint

```bash
swiftlint
# Fix auto-fixable violations
swiftlint --fix
```

### 4. Test Locally

```bash
# Run all tests
xcodebuild test -scheme LivingBuildingSystem

# Run specific test
xcodebuild test -scheme LivingBuildingSystem \
  -only-testing:LivingBuildingSystemTests/HomeTests/testHomeInitialization

# Test on device (if available)
# Select your Vision Pro in Xcode destination
# Press Cmd+R
```

### 5. Commit

```bash
# Stage changes
git add .

# Commit with conventional format
git commit -m "feat(devices): add support for garage door openers

- Implement GarageDoorDevice model
- Add open/close controls
- Update DeviceManager to handle garage doors

Closes #123"
```

### 6. Push and Create PR

```bash
# Push branch
git push origin feature/add-device-scenes

# Create PR on GitHub
# Fill out PR template
# Request review
```

### 7. Address Feedback

```bash
# Make changes based on review
git add .
git commit -m "refactor: simplify garage door logic"
git push origin feature/add-device-scenes

# Re-request review when ready
```

---

## Testing Strategy

### Unit Tests

**Coverage Goal**: 90% for models, 85% for managers

```swift
final class EnergyReadingTests: XCTestCase {
    func testCostCalculation() {
        // Arrange
        let reading = EnergyReading(timestamp: Date(), energyType: .electricity)
        reading.cumulativeConsumption = 100.0
        let config = EnergyConfiguration()

        // Act
        let cost = reading.calculateCost(configuration: config)

        // Assert
        XCTAssertEqual(cost, 15.0, accuracy: 0.01)
    }
}
```

### Integration Tests

**Coverage Goal**: Key workflows

```swift
func testEnergyServiceIntegration() async throws {
    // Connect to service
    let service = EnergyService()
    try await service.connect(apiIdentifier: "test-001")

    // Get reading
    let reading = try await service.getCurrentReading(type: .electricity)

    // Verify
    XCTAssertNotNil(reading.instantaneousPower)
}
```

### UI Tests

**Coverage Goal**: Critical user paths

See [docs/testing/UI-TESTS.md](testing/UI-TESTS.md) for details.

### Manual Testing

Use [docs/testing/MANUAL-TEST-CHECKLIST.md](testing/MANUAL-TEST-CHECKLIST.md).

---

## Debugging Tips

### Logging

```swift
// Use Logger, never print()
Logger.shared.log("Device discovered: \(device.name)", category: "DeviceManager")
Logger.shared.log("Failed to connect", category: "Energy", type: .error, error: error)
```

### Breakpoints

- **Symbolic Breakpoint**: Break on all errors
  - `Swift Error breakpoint`
- **Conditional Breakpoint**: Break only when condition is true
  - Right-click breakpoint > Edit Breakpoint > Condition

### Instruments

- **Time Profiler**: Find performance bottlenecks
- **Leaks**: Detect memory leaks
- **Allocations**: Track memory usage

### Console

```bash
# Filter logs
log stream --predicate 'subsystem == "com.lbs"' --level debug

# View crash logs
log show --predicate 'eventMessage contains "crash"' --last 1h
```

---

## Common Patterns

### Dependency Injection

```swift
// Protocol
protocol EnergyServiceProtocol: Actor {
    func getCurrentReading(type: EnergyType) async throws -> EnergyReading
}

// Manager depends on protocol, not concrete type
class EnergyManager {
    private let energyService: any EnergyServiceProtocol

    init(energyService: any EnergyServiceProtocol) {
        self.energyService = energyService
    }
}

// Easy to mock for testing
class MockEnergyService: EnergyServiceProtocol {
    func getCurrentReading(type: EnergyType) async throws -> EnergyReading {
        return EnergyReading.preview
    }
}
```

### Optimistic UI Updates

```swift
func toggleDevice(_ device: SmartDevice) async {
    // Update UI immediately
    device.currentState?.isOn?.toggle()
    appState.updateDevice(device)

    do {
        // Send command to device
        try await homeKitService.toggleDevice(device)
    } catch {
        // Rollback on error
        device.currentState?.isOn?.toggle()
        appState.updateDevice(device)
        appState.handleError(error)
    }
}
```

### Error Handling

```swift
do {
    try await riskyOperation()
} catch let error as LBSError {
    // Handle known errors
    appState.handleError(error)
} catch {
    // Handle unexpected errors
    appState.handleError(.unknown(message: error.localizedDescription))
}
```

---

## Performance Considerations

### Memory Management

- Avoid retain cycles with `[weak self]`
- Use value types (structs) when appropriate
- Release resources in `deinit`

### UI Performance

- Keep views lightweight (<60 lines)
- Use `LazyVStack` for long lists
- Offload work to background threads
- Cache computed values

### Network Efficiency

- Batch requests when possible
- Use caching (10s TTL for energy readings)
- Handle offline gracefully
- Implement exponential backoff

### Battery Optimization

- Reduce polling frequency
- Use system callbacks instead of timers
- Minimize ARKit usage when not needed

---

## Troubleshooting

### Build Issues

**Problem**: "Cannot find type 'Home'"
**Solution**: Clean build folder (Shift+Cmd+K) and rebuild

**Problem**: SwiftData schema migration error
**Solution**: Delete app from simulator and reinstall

### Runtime Issues

**Problem**: HomeKit authorization not working
**Solution**: Check Info.plist has `NSHomeKitUsageDescription`

**Problem**: Devices not discovered
**Solution**: Ensure HomeKit hub is on same network

### Test Issues

**Problem**: Tests failing only on CI
**Solution**: Check for hardcoded paths or timing issues

**Problem**: Async test hangs
**Solution**: Verify `await fulfill ment(of:timeout:)` has sufficient timeout

---

## Resources

### Apple Documentation
- [visionOS Developer](https://developer.apple.com/visionos/)
- [SwiftUI](https://developer.apple.com/documentation/swiftui)
- [SwiftData](https://developer.apple.com/documentation/swiftdata)
- [HomeKit](https://developer.apple.com/documentation/homekit)
- [RealityKit](https://developer.apple.com/documentation/realitykit)

### Project Documentation
- [Architecture Docs](design/)
- [API Documentation](api/)
- [Testing Guide](testing/)

### Community
- GitHub Discussions
- Issue Tracker
- Pull Requests

---

## Getting Help

### Before Asking

1. Check existing documentation
2. Search closed issues
3. Review pull requests
4. Try debugging yourself

### Where to Ask

- **GitHub Discussions**: General questions
- **GitHub Issues**: Bug reports, feature requests
- **Pull Requests**: Code-specific questions
- **Email**: Private inquiries

### How to Ask

- Be specific
- Provide context
- Include error messages
- Show what you've tried
- Minimal reproducible example

---

**Welcome to the team! Happy coding! 🚀**

Last Updated: 2025-01-24
