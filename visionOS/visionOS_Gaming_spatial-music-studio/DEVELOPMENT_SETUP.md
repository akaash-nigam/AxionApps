# Development Setup Guide

This guide will walk you through setting up your development environment for Spatial Music Studio.

## Table of Contents
- [Prerequisites](#prerequisites)
- [Hardware Requirements](#hardware-requirements)
- [Software Installation](#software-installation)
- [Project Setup](#project-setup)
- [Running the Application](#running-the-application)
- [Running Tests](#running-tests)
- [Troubleshooting](#troubleshooting)
- [Development Tools](#development-tools)
- [Best Practices](#best-practices)

---

## Prerequisites

### Required Knowledge
- Swift programming language (6.0+)
- SwiftUI framework
- Basic understanding of spatial computing
- Familiarity with Xcode
- Git version control

### Recommended Background
- Audio programming concepts
- Music theory basics
- 3D graphics and RealityKit
- iOS/visionOS app development

---

## Hardware Requirements

### Minimum Requirements
- **Mac:** MacBook Pro/Air (M1 or later) or iMac/Mac Studio
- **macOS:** 14.0 (Sonoma) or later
- **RAM:** 16GB minimum, 32GB recommended
- **Storage:** 50GB free space for Xcode and simulators
- **Internet:** Broadband connection for downloading dependencies

### Recommended for Full Development
- **Vision Pro device:** For testing actual spatial audio and performance
- **Audio interface:** For professional audio testing (optional)
- **High-quality headphones:** For spatial audio testing

### What You Can Do Without Vision Pro
- ✅ Write and edit all code
- ✅ Run unit tests (domain models, business logic)
- ✅ Build the project
- ✅ Use visionOS Simulator for basic UI testing
- ❌ Test actual spatial audio performance
- ❌ Test hand/eye tracking
- ❌ Measure real-world performance metrics

---

## Software Installation

### Step 1: Install Xcode

1. **Open App Store** on your Mac
2. **Search for "Xcode"**
3. **Click "Get"** or "Install" (this will take 30-60 minutes)
4. **Wait for download** (~15GB) and installation to complete

**Or via command line:**
```bash
# This requires prior Xcode installation or xcodes tool
# Visit: https://developer.apple.com/xcode/
```

### Step 2: Install Xcode Command Line Tools

```bash
xcode-select --install
```

Click "Install" in the dialog that appears.

**Verify installation:**
```bash
xcode-select -p
# Should output: /Applications/Xcode.app/Contents/Developer
```

### Step 3: Install visionOS SDK

1. **Open Xcode**
2. **Go to:** Xcode → Settings → Platforms
3. **Click the "+" button**
4. **Select "visionOS"**
5. **Click "Download"** (~5GB, takes 15-30 minutes)
6. **Wait for installation** to complete

**Verify visionOS SDK:**
```bash
xcodebuild -showsdks | grep visionOS
# Should show: visionOS 2.0+
```

### Step 4: Install Additional Tools

#### Homebrew (Package Manager)
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

#### Git (Version Control)
```bash
brew install git
git --version
```

#### SwiftLint (Code Quality)
```bash
brew install swiftlint
swiftlint version
```

#### Optional: xcpretty (Better Build Output)
```bash
gem install xcpretty
```

---

## Project Setup

### Step 1: Clone Repository

```bash
# Navigate to your development directory
cd ~/Developer

# Clone the repository
git clone https://github.com/akaash-nigam/visionOS_Gaming_spatial-music-studio.git

# Navigate into project
cd visionOS_Gaming_spatial-music-studio
```

### Step 2: Open Project in Xcode

```bash
# Open the Xcode project
open SpatialMusicStudio/SpatialMusicStudio.xcodeproj
```

**Or:**
1. Launch Xcode
2. File → Open
3. Navigate to `SpatialMusicStudio/SpatialMusicStudio.xcodeproj`
4. Click "Open"

### Step 3: Resolve Swift Package Dependencies

Xcode will automatically start resolving package dependencies when you open the project.

**If dependencies don't resolve automatically:**
1. File → Packages → Resolve Package Versions
2. Wait for all packages to download (may take 5-10 minutes)

**Check Package.swift dependencies:**
- AudioKit 5.6.0+
- MusicTheory 2.1.0+
- AudioKitEX 5.6.0+

**Verify dependencies resolved:**
```bash
cd SpatialMusicStudio
xcodebuild -resolvePackageDependencies -scheme SpatialMusicStudio
```

### Step 4: Configure Signing & Capabilities

1. **Select the project** in Xcode navigator (SpatialMusicStudio at the top)
2. **Select target:** "SpatialMusicStudio"
3. **Go to "Signing & Capabilities" tab**
4. **Team:** Select your Apple Developer team
   - If you don't have one, create a free Apple ID account
5. **Bundle Identifier:** Change to unique identifier (e.g., `com.yourname.spatialmusicstudio`)

**Required Capabilities:**
- ✅ Spatial Audio
- ✅ Group Activities (SharePlay)
- ✅ CloudKit (for cloud sync)
- ✅ iCloud (for data storage)

### Step 5: Configure Scheme

1. **Product → Scheme → Edit Scheme** (or ⌘<)
2. **Run → Options:**
   - ✅ Audio Session - Active
   - ✅ Metal API Validation - Enabled (for debugging)
3. **Test → Options:**
   - ✅ Code Coverage - Enabled
4. **Click "Close"**

---

## Running the Application

### On visionOS Simulator

1. **Select destination:** visionOS Simulator
   - Click device selector in toolbar
   - Choose "Apple Vision Pro"

2. **Build and run:** Press ⌘R or Product → Run

3. **First run will:**
   - Boot the simulator (takes 1-2 minutes)
   - Install the app
   - Launch the app

**Simulator Controls:**
- **Rotate view:** Click and drag
- **Move:** Option + drag
- **Pinch gesture:** Shift + click and drag
- **Tap:** Click

### On Vision Pro Device

1. **Connect Vision Pro:**
   - Use USB-C cable
   - Trust the Mac when prompted on Vision Pro

2. **Select device:**
   - Click device selector
   - Choose "Your Vision Pro"

3. **First time setup:**
   - Enable Developer Mode on Vision Pro
   - Trust development certificate

4. **Build and run:** Press ⌘R

**Note:** First installation takes longer (2-3 minutes)

### Build Configurations

**Debug (Development):**
```bash
# In Xcode: Product → Scheme → Edit Scheme → Run → Build Configuration → Debug
```
- Faster builds
- Debug symbols included
- Optimizations disabled
- More verbose logging

**Release (Production):**
```bash
# In Xcode: Product → Scheme → Edit Scheme → Run → Build Configuration → Release
```
- Slower builds
- Optimized performance
- Smaller binary size
- Production-ready

---

## Running Tests

### Quick Test

Press **⌘U** in Xcode to run all tests.

### Run Specific Test Suite

#### Domain Model Tests (No Hardware Required)
```bash
cd SpatialMusicStudio
xcodebuild test \
  -scheme SpatialMusicStudio \
  -destination 'platform=macOS,arch=arm64' \
  -only-testing:SpatialMusicStudioTests/DomainModelTests
```

#### All Tests (Requires visionOS Simulator)
```bash
xcodebuild test \
  -scheme SpatialMusicStudio \
  -destination 'platform=visionOS Simulator,name=Apple Vision Pro'
```

### View Test Results

1. **Show Test Navigator:** ⌘6
2. **View results:** Click on any test
3. **See logs:** Open Report Navigator (⌘9)

### Generate Code Coverage

1. **Enable coverage:** Scheme → Test → Options → ✅ Code Coverage
2. **Run tests:** ⌘U
3. **View coverage:** Report Navigator → Coverage tab

**Target Coverage:**
- Overall: 75%+
- Core audio engine: 85%+
- Data models: 95%+

---

## Troubleshooting

### Common Issues

#### Issue 1: "visionOS SDK not found"

**Symptoms:** Build fails with error about missing visionOS SDK

**Solution:**
```bash
# Check installed SDKs
xcodebuild -showsdks

# If visionOS not listed:
# 1. Open Xcode → Settings → Platforms
# 2. Download visionOS SDK
# 3. Restart Xcode
```

#### Issue 2: Package Resolution Failed

**Symptoms:** "Package resolution failed" error

**Solution:**
```bash
# Clear package cache
rm -rf ~/Library/Caches/org.swift.swiftpm
rm -rf ~/Library/Developer/Xcode/DerivedData

# Reopen project and resolve packages
```

#### Issue 3: Simulator Won't Boot

**Symptoms:** visionOS Simulator fails to start

**Solution:**
```bash
# Kill existing simulators
killall Simulator

# Reset simulator
xcrun simctl shutdown all
xcrun simctl erase all

# Try again
```

#### Issue 4: Code Signing Error

**Symptoms:** "Failed to register bundle identifier"

**Solution:**
1. Change bundle identifier to unique value
2. Select your development team
3. Clean build folder: Shift + ⌘K
4. Try again

#### Issue 5: Audio Engine Initialization Failed

**Symptoms:** App crashes on launch with audio error

**Solution:**
- Ensure you're running on visionOS Simulator/device
- Check audio capabilities are enabled
- Verify AVFoundation is linked

#### Issue 6: Build Takes Very Long

**Symptoms:** First build takes 10+ minutes

**Solution:**
- Normal for first build with all dependencies
- Subsequent builds will be faster (< 1 minute)
- Use Xcode's new build system
- Close other apps to free up RAM

### Getting Help

If you encounter issues not listed here:

1. **Check logs:**
   ```bash
   # Xcode console (⌘Y)
   # Or system console:
   log show --predicate 'process == "SpatialMusicStudio"' --last 5m
   ```

2. **Clean build:**
   ```bash
   # In Xcode: Product → Clean Build Folder (Shift + ⌘K)
   # Or:
   cd SpatialMusicStudio
   xcodebuild clean
   ```

3. **Search issues:** Check [GitHub Issues](https://github.com/akaash-nigam/visionOS_Gaming_spatial-music-studio/issues)

4. **Ask for help:** Create a new issue with:
   - Xcode version
   - macOS version
   - Full error message
   - Steps to reproduce

---

## Development Tools

### Recommended Xcode Extensions

#### SourceKitten (Code Completion)
Enhances Swift code completion and documentation.

#### SwiftFormat (Code Formatting)
Automatically formats Swift code.

#### Periphery (Dead Code Detection)
Finds unused code in your project.

### Recommended Mac Apps

#### SF Symbols (Apple)
Browse SF Symbols for UI icons.
```bash
# Download from Apple Developer website
```

#### Reality Composer (Apple)
Create and preview 3D content.
```bash
# Download from Apple Developer website
```

#### Proxyman (Network Debugging)
Debug network requests (for SharePlay testing).
```bash
brew install --cask proxyman
```

#### Fork (Git Client)
Visual Git client (alternative to command line).
```bash
brew install --cask fork
```

### Command Line Tools

#### xcodes (Xcode Version Manager)
```bash
brew install xcodesorg/made/xcodes
xcodes install 16.0
```

#### swiftformat (Code Formatter)
```bash
brew install swiftformat
swiftformat SpatialMusicStudio/SpatialMusicStudio
```

#### jazzy (Documentation Generator)
```bash
gem install jazzy
jazzy --min-acl public
```

---

## Best Practices

### Code Organization

```swift
// File structure
SpatialMusicStudio/
├── App/              // App lifecycle
├── Core/             // Core business logic
│   ├── Audio/        // Audio engine
│   ├── Models/       // Data models
│   └── Spatial/      // Spatial systems
├── Views/            // UI components
├── Networking/       // Network & collaboration
└── Data/             // Persistence

// Naming conventions
- Types: PascalCase (e.g., SpatialAudioEngine)
- Functions: camelCase (e.g., addInstrument)
- Constants: camelCase (e.g., maxLatency)
- Enums: PascalCase (e.g., NoteName)
```

### Git Workflow

```bash
# Start new feature
git checkout -b feature/my-feature

# Make changes, commit often
git add .
git commit -m "Add: Implement feature X"

# Keep branch updated
git fetch origin
git rebase origin/main

# Push to remote
git push origin feature/my-feature

# Create pull request on GitHub
```

### Commit Message Format

```
Type: Short description (50 chars max)

Longer explanation if needed (wrap at 72 chars).
Can span multiple paragraphs.

- Bullet points are okay too
- Use imperative mood: "Add" not "Added"

Types: Add, Fix, Update, Remove, Refactor, Test, Doc
```

### Testing Strategy

```swift
// Write tests first (TDD)
func testNoteTransposition() {
    // Arrange
    let note = NoteName.c

    // Act
    let result = note.transpose(by: 7)

    // Assert
    XCTAssertEqual(result, NoteName.g)
}

// Test naming
- testFeatureName_WhenCondition_ExpectedResult
- testEdgeCase_InvalidInput_ThrowsError
```

### Code Review Checklist

Before submitting PR:
- [ ] All tests pass (⌘U)
- [ ] No SwiftLint warnings
- [ ] Code is documented
- [ ] No hardcoded values
- [ ] Performance is acceptable
- [ ] UI is accessible
- [ ] Follows Swift API guidelines

### Performance Considerations

```swift
// ✅ Good: Use @MainActor for UI updates
@MainActor
class AppCoordinator: ObservableObject {
    @Published var currentScene: AppScene
}

// ✅ Good: Use async/await for concurrent work
func loadComposition() async throws -> Composition {
    async let metadata = loadMetadata()
    async let tracks = loadTracks()
    return try await Composition(metadata: metadata, tracks: tracks)
}

// ❌ Bad: Blocking main thread
func expensiveOperation() {
    // Long-running work on main thread
}

// ✅ Good: Background processing
func expensiveOperation() async {
    await Task.detached {
        // Long-running work
    }.value
}
```

### Security Best Practices

```swift
// ✅ Good: Store sensitive data in Keychain
let keychain = KeychainManager.shared
keychain.save("api-key", value: apiKey)

// ❌ Bad: Hardcoded secrets
let apiKey = "sk-1234567890" // Never do this!

// ✅ Good: Use environment variables or secure config
let apiKey = ProcessInfo.processInfo.environment["API_KEY"]
```

### Debugging Tips

```swift
// Use OSLog for production logging
import os.log

let logger = Logger(subsystem: "com.spatialmusicstudio", category: "audio")
logger.debug("Audio engine initialized")
logger.error("Failed to load instrument: \(error)")

// Use breakpoints
// - Conditional breakpoints: Only trigger when condition true
// - Symbolic breakpoints: Break on function name

// Memory debugging
// - Enable Address Sanitizer in scheme
// - Use Instruments for memory profiling
```

---

## Next Steps

Once your environment is set up:

1. **Read the documentation:**
   - [ARCHITECTURE.md](ARCHITECTURE.md) - System design
   - [TECHNICAL_SPEC.md](TECHNICAL_SPEC.md) - Technical details
   - [TEST_DOCUMENTATION.md](TEST_DOCUMENTATION.md) - Testing guide

2. **Explore the code:**
   - Start with `SpatialMusicStudioApp.swift`
   - Review domain models in `Core/Models/`
   - Understand audio engine in `Core/Audio/`

3. **Run the tests:**
   - Run unit tests: ⌘U
   - Review test coverage
   - Add tests for new features

4. **Start contributing:**
   - Pick an issue from GitHub
   - Create a feature branch
   - Make your changes
   - Submit a pull request

---

## Additional Resources

### Apple Documentation
- [visionOS Documentation](https://developer.apple.com/visionos/)
- [RealityKit](https://developer.apple.com/documentation/realitykit)
- [ARKit](https://developer.apple.com/documentation/arkit)
- [AVFoundation](https://developer.apple.com/documentation/avfoundation)
- [SharePlay](https://developer.apple.com/documentation/groupactivities)

### Swift Resources
- [Swift.org](https://swift.org)
- [Swift Forums](https://forums.swift.org)
- [Swift Evolution](https://github.com/apple/swift-evolution)

### Community
- [Vision Pro Developer Forums](https://developer.apple.com/forums/visionos)
- [Swift Forums](https://forums.swift.org)
- [Stack Overflow](https://stackoverflow.com/questions/tagged/visionos)

---

**Happy Coding! 🎵**

*Last Updated: 2025-01-19*
