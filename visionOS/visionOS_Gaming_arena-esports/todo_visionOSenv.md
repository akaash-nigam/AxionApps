# visionOS Environment Setup - Complete Guide

**Arena Esports Development Environment Configuration**

This document provides step-by-step instructions for setting up your development environment to build, test, and deploy Arena Esports on Apple Vision Pro.

---

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Hardware Requirements](#hardware-requirements)
3. [Software Requirements](#software-requirements)
4. [Initial Setup](#initial-setup)
5. [Project Configuration](#project-configuration)
6. [Building the Project](#building-the-project)
7. [Running on Simulator](#running-on-simulator)
8. [Running Tests](#running-tests)
9. [Deploying to Physical Device](#deploying-to-physical-device)
10. [Performance Profiling](#performance-profiling)
11. [Troubleshooting](#troubleshooting)
12. [Best Practices](#best-practices)

---

## 1. Prerequisites

### Required Knowledge
- Swift programming language (Swift 6.0)
- SwiftUI fundamentals
- Basic understanding of 3D graphics
- Familiarity with RealityKit and ARKit (helpful)
- Experience with Xcode and iOS/visionOS development

### Apple Developer Account
- **Required**: Apple Developer Program membership ($99/year)
- **Purpose**:
  - Access to visionOS SDK
  - TestFlight deployment
  - App Store distribution
  - Device provisioning for physical Vision Pro

**Sign up**: https://developer.apple.com/programs/

---

## 2. Hardware Requirements

### Development Mac

**Minimum Requirements:**
- **Mac Model**: Mac with Apple Silicon (M1 or later) OR Intel Mac with dedicated GPU
- **macOS**: macOS 14.0 (Sonoma) or later
- **RAM**: 16 GB minimum, 32 GB recommended
- **Storage**: 50 GB free space minimum
- **Display**: Retina display recommended for design work

**Recommended Configuration:**
- **Mac Model**: MacBook Pro 14" or 16" with M2 Pro/Max or Mac Studio with M2 Max/Ultra
- **macOS**: Latest stable version (macOS 14.5+)
- **RAM**: 32 GB or more
- **Storage**: 500 GB+ SSD with at least 100 GB free
- **Display**: External 4K/5K display for spatial UI design

### Apple Vision Pro (Optional but Recommended)

**For Physical Testing:**
- Apple Vision Pro device
- USB-C cable for device connection
- Adequate physical space (minimum 2m x 2m for Arena Esports)
- Good lighting conditions

**Note**: Simulator is sufficient for most development, but physical device testing is essential before release.

---

## 3. Software Requirements

### Step 1: Install Xcode 16+

**Version Required**: Xcode 16.0 or later (includes visionOS 2.0 SDK)

**Installation Steps:**

1. **Download Xcode**
   ```bash
   # Option 1: From Mac App Store
   # Search for "Xcode" and install

   # Option 2: From Apple Developer Downloads
   # Visit: https://developer.apple.com/download/
   # Download: Xcode 16.x (latest stable)
   ```

2. **Install Xcode**
   - Open the downloaded `.xip` file
   - Drag Xcode to `/Applications` folder
   - Wait for extraction (may take 15-30 minutes)

3. **Accept License Agreement**
   ```bash
   sudo xcodebuild -license accept
   ```

4. **Install Command Line Tools**
   ```bash
   xcode-select --install
   ```

5. **Verify Installation**
   ```bash
   xcodebuild -version
   # Expected output: Xcode 16.0 or later

   xcrun --show-sdk-path --sdk xros
   # Expected: Path to visionOS SDK
   ```

### Step 2: Install visionOS Simulator

**Automatic Installation:**

1. Open Xcode
2. Go to `Xcode > Settings > Platforms`
3. Click the `+` button
4. Select `visionOS` from the list
5. Click `Download` (approximately 8-10 GB)
6. Wait for installation to complete

**Verify Simulator:**
```bash
xcrun simctl list devices | grep "Apple Vision Pro"
# Expected: List of Vision Pro simulators
```

### Step 3: Install Additional Tools

**Swift Package Manager** (Included with Xcode)
```bash
swift --version
# Expected: Swift version 6.0 or later
```

**Git** (Version Control)
```bash
git --version
# If not installed, install via Xcode Command Line Tools
```

**Homebrew** (Optional but recommended for tools)
```bash
# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install useful tools
brew install swiftlint      # Code linting
brew install swiftformat    # Code formatting
```

---

## 4. Initial Setup

### Step 1: Clone the Repository

```bash
# Navigate to your projects folder
cd ~/Developer

# Clone the repository
git clone https://github.com/akaash-nigam/visionOS_Gaming_arena-esports.git

# Navigate to project directory
cd visionOS_Gaming_arena-esports

# Verify branch
git branch -a
# Switch to development branch if needed
git checkout claude/implement-app-with-tests-019izibbmWyV1xtdoUAiHttJ
```

### Step 2: Project Structure Review

```bash
# View project structure
ls -la

# Expected structure:
# ├── ARCHITECTURE.md
# ├── DESIGN.md
# ├── IMPLEMENTATION_PLAN.md
# ├── PROJECT_SUMMARY.md
# ├── TECHNICAL_SPEC.md
# └── ArenaEsports/
#     ├── Package.swift
#     ├── Game/
#     ├── Models/
#     ├── Systems/
#     └── Tests/
```

### Step 3: Verify Swift Package

```bash
cd ArenaEsports

# Validate Package.swift
swift package dump-package

# Resolve dependencies
swift package resolve

# Build to verify
swift build
```

---

## 5. Project Configuration

### Step 1: Create Xcode Project

Since we have a Swift Package, we need to create a visionOS app project:

**Using Xcode:**

1. **Open Xcode**
2. **Create New Project**
   - File → New → Project
   - Select `visionOS` tab
   - Choose `App` template
   - Click `Next`

3. **Configure Project**
   - **Product Name**: `Arena Esports`
   - **Team**: Select your Apple Developer Team
   - **Organization Identifier**: `com.yourcompany.arenaesports`
   - **Interface**: SwiftUI
   - **Language**: Swift
   - **Include Tests**: ✅ Checked
   - Click `Next`

4. **Save Location**
   - Navigate to `visionOS_Gaming_arena-esports/ArenaEsports/`
   - Save as `ArenaEsports.xcodeproj`

### Step 2: Configure Build Settings

**In Xcode Project Settings:**

1. **General Tab**
   - **Deployment Info**
     - Minimum Deployment: `visionOS 2.0`
     - Supported Destinations: `Apple Vision Pro`

   - **App Category**: Games

   - **Preferred Default Scene Session Role**: `Immersive Space`

2. **Signing & Capabilities**
   - **Automatically manage signing**: ✅ Checked
   - **Team**: Select your team
   - **Bundle Identifier**: `com.yourcompany.arenaesports`

   - **Add Capabilities** (click `+`):
     - ☑️ App Groups (for data sharing)
     - ☑️ Game Center
     - ☑️ In-App Purchase (for monetization)

3. **Build Settings**
   - Search for "Swift Language Version"
   - Set to `Swift 6`

   - Search for "Strict Concurrency Checking"
   - Set to `Complete`

### Step 3: Configure Info.plist

Add required visionOS permissions and settings:

**Privacy Permissions:**
```xml
<key>NSCameraUsageDescription</key>
<string>Arena Esports uses the camera for hand tracking and spatial awareness in competitive gameplay.</string>

<key>NSLocalNetworkUsageDescription</key>
<string>Arena Esports needs local network access for multiplayer matches and tournament play.</string>

<key>NSBonjourServices</key>
<array>
    <string>_arenaesports._tcp</string>
</array>
```

**visionOS Specific Settings:**
```xml
<key>UIApplicationPreferredDefaultSceneSessionRole</key>
<string>UIWindowSceneSessionRoleImmersiveSpaceApplication</string>

<key>UIRequiresFullScreen</key>
<true/>

<key>UIApplicationSupportsMultipleScenes</key>
<true/>
```

**Game Center:**
```xml
<key>GKGameCenterEnabled</key>
<true/>
```

### Step 4: Import Swift Package Code

**Option 1: Add Local Package**

1. In Xcode, File → Add Package Dependencies
2. Click `Add Local...`
3. Navigate to `ArenaEsports/` folder
4. Select the folder containing `Package.swift`
5. Click `Add Package`

**Option 2: Copy Source Files**

```bash
# From ArenaEsports/ directory
# Copy source files to Xcode project
cp -r Game/ ../ArenaEsportsApp/ArenaEsports/
cp -r Models/ ../ArenaEsportsApp/ArenaEsports/
cp -r Systems/ ../ArenaEsportsApp/ArenaEsports/
cp -r Tests/ ../ArenaEsportsApp/ArenaEsportsTests/
```

### Step 5: Create App Entry Point

**ArenaEsportsApp.swift:**

```swift
import SwiftUI

@main
struct ArenaEsportsApp: App {
    @State private var gameState = GameState()
    @State private var gameLoop = GameLoop()

    var body: some Scene {
        WindowGroup {
            MainMenuView()
                .environment(gameState)
        }

        ImmersiveSpace(id: "GameArena") {
            GameArenaView()
                .environment(gameState)
        }
        .immersionStyle(selection: .constant(.progressive), in: .progressive)
    }
}
```

**MainMenuView.swift (Placeholder):**

```swift
import SwiftUI

struct MainMenuView: View {
    @Environment(GameState.self) private var gameState

    var body: some View {
        VStack(spacing: 30) {
            Text("ARENA ESPORTS")
                .font(.system(size: 60, weight: .bold))

            Text("Professional Competitive Gaming in Spatial Reality")
                .font(.title3)

            VStack(spacing: 20) {
                Button("Play Competitive") {
                    // Start matchmaking
                }
                .buttonStyle(.borderedProminent)

                Button("Training") {
                    // Enter training mode
                }
                .buttonStyle(.bordered)

                Button("Settings") {
                    // Open settings
                }
                .buttonStyle(.bordered)
            }
            .font(.title2)
        }
        .padding(50)
    }
}
```

---

## 6. Building the Project

### Step 1: Select Build Destination

**In Xcode:**
1. Click on the scheme selector (top left, next to play/stop buttons)
2. Select `Apple Vision Pro (Simulator)`
   - If not visible, select `Any visionOS Device (arm64)`

### Step 2: Build the Project

**Via Xcode:**
- Press `⌘ + B` (Command + B)
- Or: Product → Build

**Via Command Line:**
```bash
# Navigate to Xcode project directory
cd /path/to/ArenaEsports.xcodeproj/..

# Build for simulator
xcodebuild build \
  -scheme ArenaEsports \
  -destination 'platform=visionOS Simulator,name=Apple Vision Pro' \
  -configuration Debug

# Build for device
xcodebuild build \
  -scheme ArenaEsports \
  -destination 'generic/platform=visionOS' \
  -configuration Release
```

**Expected Output:**
```
** BUILD SUCCEEDED **
```

### Step 3: Resolve Build Errors

**Common Issues:**

1. **Swift Version Mismatch**
   ```
   Error: Module compiled with Swift X.X cannot be imported by Swift Y.Y
   ```
   **Fix**: Ensure all targets use Swift 6.0
   - Build Settings → Swift Language Version → Swift 6

2. **Missing visionOS SDK**
   ```
   Error: Could not find visionOS SDK
   ```
   **Fix**: Install visionOS platform in Xcode Settings

3. **Code Signing Error**
   ```
   Error: Signing for "ArenaEsports" requires a development team
   ```
   **Fix**: Select team in Signing & Capabilities

---

## 7. Running on Simulator

### Step 1: Launch Simulator

**Via Xcode:**
1. Select `Apple Vision Pro (Simulator)` as destination
2. Press `⌘ + R` (Command + R) to run
3. Or: Product → Run

**Via Command Line:**
```bash
# Open simulator
open -a Simulator

# Or use xcrun
xcrun simctl boot "Apple Vision Pro"

# Run app
xcodebuild run \
  -scheme ArenaEsports \
  -destination 'platform=visionOS Simulator,name=Apple Vision Pro'
```

### Step 2: Simulator Controls

**Mouse/Trackpad Controls:**
- **Look Around**: Click and drag
- **Move**: WASD keys
- **Pinch Gesture**: Click with cursor on UI element
- **Hand Tracking**: Enable in Simulator → I/O → Input

**Keyboard Shortcuts:**
- `⌘ + →/←`: Rotate view
- `⌘ + ↑/↓`: Tilt view
- `⌘ + Shift + H`: Home button
- `⌘ + K`: Toggle keyboard

**Performance Mode:**
- Window → Show Performance HUD
- Monitor FPS (target: 90-120 FPS)
- Monitor memory usage

### Step 3: Debugging in Simulator

**Set Breakpoints:**
1. Click line number in Xcode to set breakpoint
2. Run app in debug mode
3. Use debug console: `View → Debug Area → Show Debug Area`

**Common Debug Commands:**
```lldb
# Print variable
po variableName

# Print object description
p objectName

# Continue execution
continue

# Step over
next

# Step into
step
```

**Performance Monitoring:**
```bash
# In Terminal, while simulator is running
xcrun simctl io booted recordVideo --codec=h264 recording.mp4

# Monitor performance
instruments -t "Time Profiler" -D trace.trace \
  -w "Apple Vision Pro (Simulator)"
```

---

## 8. Running Tests

### Step 1: Run Unit Tests

**Via Xcode:**
1. Press `⌘ + U` (Command + U)
2. Or: Product → Test
3. View results in Test Navigator (`⌘ + 6`)

**Via Command Line:**
```bash
# Run all tests
xcodebuild test \
  -scheme ArenaEsports \
  -destination 'platform=visionOS Simulator,name=Apple Vision Pro'

# Run specific test suite
xcodebuild test \
  -scheme ArenaEsports \
  -destination 'platform=visionOS Simulator,name=Apple Vision Pro' \
  -only-testing:ArenaEsportsTests/EntityTests

# Run with code coverage
xcodebuild test \
  -scheme ArenaEsports \
  -destination 'platform=visionOS Simulator,name=Apple Vision Pro' \
  -enableCodeCoverage YES
```

### Step 2: View Test Results

**In Xcode:**
1. Open Test Navigator (`⌘ + 6`)
2. See pass/fail status for each test
3. Click on failed test to see details
4. View test logs in Report Navigator (`⌘ + 9`)

**Code Coverage:**
1. Product → Show Build Folder in Finder
2. Navigate to `Logs/Test/*.xcresult`
3. Right-click → Show Package Contents
4. Open `Coverage.json`

**Command Line Coverage:**
```bash
# Generate coverage report
xcrun xccov view --report --json \
  path/to/TestResults.xcresult > coverage.json

# View coverage percentage
xcrun xccov view --report path/to/TestResults.xcresult
```

### Step 3: Performance Testing

**XCTest Performance Metrics:**

```swift
func testPhysicsPerformance() {
    measure(metrics: [XCTClockMetric(), XCTMemoryMetric()]) {
        // Code to benchmark
        physicsSystem.update(deltaTime: 0.016, entities: entities)
    }
}
```

**Run Performance Tests:**
```bash
xcodebuild test \
  -scheme ArenaEsports \
  -destination 'platform=visionOS Simulator,name=Apple Vision Pro' \
  -only-testing:ArenaEsportsTests/PerformanceTests
```

---

## 9. Deploying to Physical Device

### Step 1: Connect Vision Pro

**Prerequisites:**
- Apple Vision Pro powered on
- Connected to same Wi-Fi network as Mac
- Developer Mode enabled on Vision Pro

**Enable Developer Mode on Vision Pro:**
1. Open Settings app on Vision Pro
2. Navigate to: Privacy & Security → Developer Mode
3. Toggle Developer Mode ON
4. Restart Vision Pro when prompted

**Pair Device:**
1. In Xcode: Window → Devices and Simulators
2. Click `+` button
3. Select your Vision Pro from the list
4. Click `Connect`
5. Trust the computer on Vision Pro when prompted

### Step 2: Configure Code Signing

**In Xcode:**
1. Select project in Navigator
2. Select target `ArenaEsports`
3. Go to Signing & Capabilities
4. **Team**: Select your Apple Developer Team
5. **Bundle Identifier**: Ensure it's unique (e.g., `com.yourname.arenaesports`)
6. **Automatically manage signing**: ✅ Checked

**Verify Provisioning Profile:**
```bash
# List provisioning profiles
security find-identity -v -p codesigning

# Verify profile
codesign -dv --verbose=4 /path/to/ArenaEsports.app
```

### Step 3: Deploy to Device

**Via Xcode:**
1. Select your Vision Pro from device list
2. Press `⌘ + R` to build and run
3. Wait for installation (first time may take 5-10 minutes)
4. App launches automatically

**Via Command Line:**
```bash
# Build for device
xcodebuild build \
  -scheme ArenaEsports \
  -destination 'platform=visionOS,name=Your Vision Pro' \
  -configuration Release

# Install using ios-deploy (if installed)
ios-deploy --bundle path/to/ArenaEsports.app
```

### Step 4: Test on Physical Device

**Physical Space Requirements:**
- Minimum: 2m x 2m clear area
- Recommended: 3m x 3m for optimal gameplay
- Good lighting
- Non-reflective surfaces

**Performance Validation:**
- Monitor FPS (should maintain 90+ FPS)
- Test hand tracking accuracy
- Verify spatial audio
- Check thermal performance (device should not overheat)

**Capture Logs:**
```bash
# Capture device logs
idevicesyslog > device_logs.txt

# Or via Xcode
# Window → Devices and Simulators → Select device → View Device Logs
```

---

## 10. Performance Profiling

### Step 1: Use Instruments

**Launch Instruments:**

**Via Xcode:**
1. Product → Profile (`⌘ + I`)
2. Select profiling template:
   - **Time Profiler**: CPU usage, hot spots
   - **Allocations**: Memory usage, leaks
   - **Leaks**: Memory leak detection
   - **Metal System Trace**: GPU performance

**Via Command Line:**
```bash
# Launch Time Profiler
instruments -t "Time Profiler" \
  -D time_profile.trace \
  -w "Apple Vision Pro (Simulator)"
```

### Step 2: Analyze Performance

**Time Profiler:**
1. Run app in Instruments
2. Perform actions (gameplay, navigation)
3. Stop recording
4. View Call Tree
5. Identify hot spots (functions taking most time)
6. Target: No single function > 5% CPU

**Memory Profiler:**
1. Use Allocations template
2. Monitor memory growth
3. Take snapshots at different states
4. Look for memory leaks
5. Target: Memory usage < 3.5 GB

**GPU Profiler (Metal):**
1. Use Metal System Trace
2. Monitor frame rate
3. Check GPU utilization
4. Identify rendering bottlenecks
5. Target: 90-120 FPS sustained

### Step 3: Optimize Based on Results

**Common Optimizations:**

**CPU Optimization:**
```swift
// Before: O(n²) collision check
for entity1 in entities {
    for entity2 in entities {
        checkCollision(entity1, entity2)
    }
}

// After: Spatial partitioning
let nearbyEntities = spatialGrid.query(near: entity.position)
for nearby in nearbyEntities {
    checkCollision(entity, nearby)
}
```

**Memory Optimization:**
```swift
// Use object pooling for frequently created objects
class EntityPool {
    private var pool: [GameEntity] = []

    func acquire() -> GameEntity {
        return pool.popLast() ?? GameEntity()
    }

    func release(_ entity: GameEntity) {
        entity.reset()
        pool.append(entity)
    }
}
```

**Rendering Optimization:**
```swift
// Level of Detail (LOD)
func selectLOD(distance: Float) -> ModelAsset {
    if distance < 5 { return .highDetail }
    else if distance < 20 { return .mediumDetail }
    else { return .lowDetail }
}
```

---

## 11. Troubleshooting

### Common Issues and Solutions

#### Issue 1: Simulator Won't Launch

**Symptoms:**
- Simulator crashes on launch
- "Unable to boot device" error

**Solutions:**
```bash
# Reset simulator
xcrun simctl shutdown all
xcrun simctl erase all

# Reinstall simulator
# Xcode → Settings → Platforms → Remove visionOS → Reinstall
```

#### Issue 2: Build Fails with Swift Errors

**Symptoms:**
- "Module X compiled with Swift Y cannot be imported"
- Concurrency errors

**Solutions:**
1. Clean build folder: `⌘ + Shift + K`
2. Delete derived data:
   ```bash
   rm -rf ~/Library/Developer/Xcode/DerivedData
   ```
3. Verify Swift version in all targets
4. Enable strict concurrency checking

#### Issue 3: Tests Failing

**Symptoms:**
- Tests pass locally but fail in CI
- Race conditions in actor tests

**Solutions:**
```swift
// Ensure async tests use await
func testAsync() async {
    await entityManager.createEntity()
    // Not: entityManager.createEntity() without await
}

// Use proper MainActor annotation
@MainActor
func testUI() {
    // UI test code
}
```

#### Issue 4: Performance Issues

**Symptoms:**
- FPS drops below 60
- Stuttering or lag

**Solutions:**
1. Profile with Instruments
2. Reduce draw calls
3. Implement LOD system
4. Use object pooling
5. Optimize physics calculations

#### Issue 5: Code Signing Issues

**Symptoms:**
- "Failed to create provisioning profile"
- "Signing requires a development team"

**Solutions:**
1. Verify Apple Developer account is active
2. Select correct team in Xcode
3. Create unique bundle identifier
4. Regenerate provisioning profile:
   ```bash
   # Via developer portal
   # https://developer.apple.com/account/resources/profiles/
   ```

#### Issue 6: Hand Tracking Not Working

**Symptoms:**
- Hand gestures not detected
- Tracking is inaccurate

**Solutions (Simulator):**
1. Simulator → I/O → Input → Enable Hand Tracking
2. Use mouse to simulate hand positions

**Solutions (Device):**
1. Ensure good lighting
2. Keep hands in visible range
3. Check privacy permissions
4. Calibrate hand tracking in Settings

---

## 12. Best Practices

### Development Workflow

**1. Use Git Branching Strategy**
```bash
# Feature development
git checkout -b feature/new-weapon-system
# Make changes, commit frequently
git commit -m "Add pulse blaster weapon"
# Push to remote
git push origin feature/new-weapon-system
```

**2. Run Tests Before Committing**
```bash
# Pre-commit hook
#!/bin/sh
swift test
if [ $? -ne 0 ]; then
    echo "Tests failed. Commit aborted."
    exit 1
fi
```

**3. Use Continuous Integration**
```yaml
# .github/workflows/test.yml
name: Run Tests
on: [push, pull_request]
jobs:
  test:
    runs-on: macos-14
    steps:
      - uses: actions/checkout@v3
      - name: Run Tests
        run: xcodebuild test -scheme ArenaEsports
```

### Code Quality

**1. Use SwiftLint**
```bash
# Install
brew install swiftlint

# Create .swiftlint.yml
cat > .swiftlint.yml << EOF
disabled_rules:
  - trailing_whitespace
opt_in_rules:
  - empty_count
  - explicit_init
line_length: 120
EOF

# Run linter
swiftlint
```

**2. Enable All Warnings**
- Build Settings → Other Swift Flags → Add `-warnings-as-errors`
- Treat all warnings as errors in CI

**3. Document Public APIs**
```swift
/// Performs a hitscan attack from the specified origin
/// - Parameters:
///   - origin: Starting position of the raycast
///   - direction: Direction to shoot (should be normalized)
///   - maxDistance: Maximum range of the attack
///   - damage: Amount of damage to apply
/// - Returns: UUID of killed entity, or nil if no kill
public func performHitscan(
    from origin: SIMD3<Float>,
    direction: SIMD3<Float>,
    maxDistance: Float,
    damage: Float
) async -> UUID?
```

### Performance

**1. Profile Regularly**
- Profile every major feature addition
- Set performance budgets (8ms per frame max)
- Monitor memory usage continuously

**2. Use Async/Await Properly**
```swift
// Good: Parallel execution
async let physics = physicsSystem.update()
async let combat = combatSystem.update()
await physics
await combat

// Bad: Sequential when unnecessary
await physicsSystem.update()
await combatSystem.update()
```

**3. Optimize Asset Loading**
```swift
// Preload frequently used assets
Task {
    await AssetCache.shared.preload([
        "arena_sphere",
        "player_model",
        "weapon_rifle"
    ])
}
```

### Testing

**1. Maintain Test Coverage**
- Target: 80% minimum
- Run coverage reports weekly
- Add tests for all bug fixes

**2. Use Test Doubles**
```swift
// Mock for testing
class MockNetworkManager: NetworkManager {
    var shouldSucceed = true

    override func send(_ message: NetworkMessage) async throws {
        if !shouldSucceed {
            throw NetworkError.connectionLost
        }
    }
}
```

**3. Test on Physical Device**
- Test every sprint on real hardware
- Validate performance metrics
- Check thermal behavior

---

## Quick Reference

### Essential Commands

```bash
# Build
xcodebuild build -scheme ArenaEsports

# Test
xcodebuild test -scheme ArenaEsports

# Clean
xcodebuild clean -scheme ArenaEsports

# Reset simulator
xcrun simctl erase all

# View device logs
log stream --predicate 'process == "ArenaEsports"'

# Code coverage
xcrun xccov view --report path/to/results.xcresult
```

### Keyboard Shortcuts

| Action | Shortcut |
|--------|----------|
| Build | `⌘ + B` |
| Run | `⌘ + R` |
| Test | `⌘ + U` |
| Profile | `⌘ + I` |
| Clean | `⌘ + Shift + K` |
| Stop | `⌘ + .` |
| Show Navigator | `⌘ + 0-9` |
| Show/Hide Debug Area | `⌘ + Shift + Y` |

---

## Support and Resources

### Official Documentation
- [visionOS Developer Documentation](https://developer.apple.com/documentation/visionos)
- [RealityKit Documentation](https://developer.apple.com/documentation/realitykit/)
- [ARKit Documentation](https://developer.apple.com/documentation/arkit/)
- [Swift Concurrency Guide](https://docs.swift.org/swift-book/LanguageGuide/Concurrency.html)

### Community
- [Apple Developer Forums - visionOS](https://developer.apple.com/forums/tags/visionos)
- [Swift Forums](https://forums.swift.org/)
- [Stack Overflow - visionOS tag](https://stackoverflow.com/questions/tagged/visionos)

### Project-Specific
- **ARCHITECTURE.md**: Technical architecture details
- **TECHNICAL_SPEC.md**: Implementation specifications
- **DESIGN.md**: Game design and UX guidelines
- **PROJECT_SUMMARY.md**: Implementation overview

---

## Checklist: Environment Setup

Use this checklist to verify your setup:

- [ ] macOS 14.0+ installed
- [ ] Xcode 16.0+ installed and configured
- [ ] visionOS SDK downloaded
- [ ] Apple Developer account active
- [ ] Git repository cloned
- [ ] Xcode project created and configured
- [ ] Code signing configured with team
- [ ] Simulator launches successfully
- [ ] Project builds without errors
- [ ] All tests pass (115+ tests)
- [ ] App runs in simulator
- [ ] Physical device paired (if available)
- [ ] Performance profiling tools tested
- [ ] SwiftLint installed and configured

---

**Last Updated**: 2025-11-19
**Version**: 1.0
**Project**: Arena Esports visionOS

For issues or questions, refer to PROJECT_SUMMARY.md or open an issue in the repository.
