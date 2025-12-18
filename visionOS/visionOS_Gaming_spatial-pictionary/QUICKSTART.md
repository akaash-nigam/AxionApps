# Quick Start Guide

Get Spatial Pictionary up and running in minutes! This guide will help you set up your development environment and build the project.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Building the Project](#building-the-project)
- [Running Tests](#running-tests)
- [Project Structure](#project-structure)
- [Development Tips](#development-tips)
- [Common Issues](#common-issues)
- [Next Steps](#next-steps)

---

## Prerequisites

### Required

- **macOS** 14.0 (Sonoma) or later
- **Xcode** 16.0 or later
- **Apple Developer Account** (free tier works for simulator)

### Optional but Recommended

- **Apple Vision Pro** device for device testing
- **Git** for version control
- **macOS** 15.0 (Sequoia) for latest features

### System Check

Verify your system meets the requirements:

```bash
# Check macOS version
sw_vers

# Check Xcode version
xcodebuild -version

# Check Swift version
swift --version
```

Expected output:
```
xcodebuild -version
Xcode 16.0
Build version 16A242

swift --version
swift-driver version: 1.115
Apple Swift version 6.0
```

---

## Installation

### Step 1: Clone the Repository

```bash
# Clone via HTTPS
git clone https://github.com/akaash-nigam/visionOS_Gaming_spatial-pictionary.git

# Or clone via SSH (if configured)
git clone git@github.com:akaash-nigam/visionOS_Gaming_spatial-pictionary.git

# Navigate into the directory
cd visionOS_Gaming_spatial-pictionary
```

### Step 2: Open the Project

**Option A: Using Terminal**
```bash
# Open the Xcode project
open SpatialPictionary.xcodeproj
```

**Option B: Using Finder**
1. Navigate to the project folder
2. Double-click `SpatialPictionary.xcodeproj`

> **Note**: If you see `SpatialPictionary.xcworkspace` in the future (after adding dependencies), open that instead of `.xcodeproj`.

### Step 3: Configure Code Signing

1. In Xcode, select the project in the navigator (top-left)
2. Select the "SpatialPictionary" target
3. Go to "Signing & Capabilities" tab
4. Select your team from the "Team" dropdown
   - If you don't have a team, click "Add Account" to sign in with your Apple ID
5. Xcode will automatically handle provisioning

**Bundle Identifier:**
- Default: `com.yourcompany.SpatialPictionary`
- Change this to your own identifier if needed

### Step 4: Select a Destination

Choose where to run the app:

**Vision Pro Simulator (Recommended for development):**
1. Click the destination selector in Xcode toolbar
2. Select "Vision Pro"
3. Choose a specific simulator if multiple are available

**Physical Vision Pro Device:**
1. Connect your Vision Pro to your Mac
2. Trust the computer on your Vision Pro
3. Select your device from the destination selector

---

## Building the Project

### Quick Build

```bash
# Build the project
Cmd+B

# Or via command line
xcodebuild -scheme SpatialPictionary -destination 'platform=visionOS Simulator,name=Apple Vision Pro' build
```

### Build and Run

```bash
# Run on simulator
Cmd+R

# Or via command line
xcodebuild -scheme SpatialPictionary -destination 'platform=visionOS Simulator,name=Apple Vision Pro' run
```

### Build Configurations

- **Debug** (default): For development, includes debugging symbols
- **Release**: For production, optimized performance

To select configuration:
1. Product → Scheme → Edit Scheme
2. Select "Run" in the sidebar
3. Change "Build Configuration" dropdown

---

## Running Tests

### Run All Tests

**In Xcode:**
```bash
Cmd+U
```

**Via Command Line:**
```bash
xcodebuild test -scheme SpatialPictionary -destination 'platform=visionOS Simulator,name=Apple Vision Pro'
```

### Run Specific Tests

**In Xcode:**
1. Open Test Navigator (Cmd+6)
2. Click the diamond icon next to the test you want to run

**Via Command Line:**
```bash
# Run specific test class
xcodebuild test -scheme SpatialPictionary -destination 'platform=visionOS Simulator,name=Apple Vision Pro' -only-testing:SpatialPictionaryTests/GameStateTests

# Run specific test method
xcodebuild test -scheme SpatialPictionary -destination 'platform=visionOS Simulator,name=Apple Vision Pro' -only-testing:SpatialPictionaryTests/GameStateTests/testInitialPhaseIsLobby
```

### View Test Coverage

1. Run tests with coverage enabled:
   - Product → Scheme → Edit Scheme
   - Select "Test" in sidebar
   - Check "Code Coverage" under Options
2. After running tests: View → Navigators → Report Navigator (Cmd+9)
3. Select the latest test run
4. Click "Coverage" tab

**Target: >80% code coverage**

---

## Project Structure

```
SpatialPictionary/
│
├── App/                          # Application entry point
│   └── SpatialPictionaryApp.swift  # Main app definition
│
├── Models/                       # Data models
│   ├── Player.swift              # Player representation
│   ├── Word.swift                # Word/prompt model
│   └── Drawing.swift             # 3D drawing model
│
├── Game/                         # Game logic
│   ├── GameState/
│   │   └── GameState.swift       # Observable game state
│   ├── Logic/                    # Game rules (future)
│   └── Networking/               # Multiplayer (future)
│
├── Views/                        # SwiftUI views (future)
│   ├── Lobby/                    # Pre-game setup
│   ├── Drawing/                  # 3D drawing interface
│   └── Guessing/                 # Guessing interface
│
├── Systems/                      # Core systems (future)
│   ├── Drawing/                  # Drawing engine
│   ├── Recognition/              # Gesture recognition
│   └── AI/                       # AI difficulty
│
├── Resources/                    # Assets (future)
│   ├── Assets.xcassets           # Images, colors
│   ├── Sounds/                   # Audio files
│   └── Words/                    # Word databases
│
└── Info.plist                    # App configuration

Tests/
├── UnitTests/                    # Unit tests
│   ├── GameStateTests.swift
│   └── ScoringTests.swift
├── IntegrationTests/             # Integration tests (future)
└── UITests/                      # UI tests (future)
```

See [SOURCE_CODE_README.md](SOURCE_CODE_README.md) for detailed architecture.

---

## Development Tips

### Xcode Shortcuts

| Action | Shortcut |
|--------|----------|
| Build | Cmd+B |
| Run | Cmd+R |
| Test | Cmd+U |
| Clean Build Folder | Cmd+Shift+K |
| Open Quickly | Cmd+Shift+O |
| Find in Project | Cmd+Shift+F |
| Jump to Definition | Cmd+Click |
| Show Documentation | Option+Click |

### Swift Development

**Enable Strict Concurrency Checking:**
This project uses Swift 6 strict concurrency. Ensure it's enabled:
1. Project Settings → Build Settings
2. Search for "concurrency"
3. Set "Strict Concurrency Checking" to "Complete"

**SwiftUI Previews:**
Use SwiftUI previews for rapid iteration:

```swift
#Preview {
    ContentView()
        .environment(GameState())
}
```

**Debugging:**
- Set breakpoints by clicking line numbers
- Use `print()` for simple debugging
- Use `po` (print object) in debugger console
- Enable "Debug View Hierarchy" for UI issues

### Vision Pro Simulator Tips

**Simulator Controls:**
- **Hands**: Use trackpad or mouse to simulate hand gestures
- **Reset**: Device → Erase All Content and Settings
- **Screenshots**: Cmd+S
- **Record**: Cmd+R (in simulator menu)

**Performance:**
- Simulator is slower than device
- Performance tests should run on physical device
- Simulator doesn't support all ARKit features

---

## Common Issues

### Issue: "No such module 'RealityKit'"

**Solution:**
Ensure you're building for visionOS target, not iOS.

### Issue: Code Signing Errors

**Solution:**
1. Xcode → Preferences → Accounts
2. Add your Apple ID
3. Download manual profiles if needed
4. Try "Automatically manage signing"

### Issue: Simulator Won't Launch

**Solution:**
```bash
# Kill simulator processes
killall Simulator

# Reset Xcode derived data
rm -rf ~/Library/Developer/Xcode/DerivedData

# Restart Xcode
```

### Issue: Build Fails with Swift Errors

**Solution:**
1. Clean build folder: Cmd+Shift+K
2. Close and reopen Xcode
3. Update to latest Xcode version
4. Check Swift version compatibility

### Issue: Tests Won't Run

**Solution:**
1. Ensure test target is selected
2. Check test host application is set correctly
3. Clean and rebuild test target
4. Verify test bundle identifier matches

### Issue: Vision Pro Simulator Not Available

**Solution:**
1. Xcode → Settings → Platforms
2. Download visionOS platform
3. Restart Xcode
4. Window → Devices and Simulators → Add Vision Pro simulator

---

## Next Steps

### Learn the Codebase

1. **Read Documentation**
   - [ARCHITECTURE.md](ARCHITECTURE.md) - System architecture
   - [TECHNICAL_SPEC.md](TECHNICAL_SPEC.md) - Technical details
   - [DESIGN.md](DESIGN.md) - Design specifications

2. **Explore Code**
   - Start with `SpatialPictionaryApp.swift`
   - Review data models in `Models/`
   - Study `GameState.swift` for state management

3. **Run Tests**
   - Review existing tests to understand expected behavior
   - See [TESTING_GUIDE.md](TESTING_GUIDE.md) for testing strategies

### Start Contributing

1. **Find an Issue**
   - Look for "good first issue" labels
   - Check the [project board](https://github.com/akaash-nigam/visionOS_Gaming_spatial-pictionary/projects)

2. **Read Guidelines**
   - [CONTRIBUTING.md](CONTRIBUTING.md) - Contribution guidelines
   - [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) - Community standards

3. **Create a Branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

4. **Make Changes**
   - Follow Swift style guidelines
   - Add tests for new features
   - Update documentation

5. **Submit Pull Request**
   - Push your branch
   - Open PR on GitHub
   - Respond to review feedback

### Join the Community

- **GitHub Discussions**: Ask questions, share ideas
- **Issues**: Report bugs, request features
- **Pull Requests**: Review others' contributions

---

## Additional Resources

### Apple Documentation

- [visionOS Developer](https://developer.apple.com/visionos/)
- [SwiftUI Tutorials](https://developer.apple.com/tutorials/swiftui)
- [RealityKit Documentation](https://developer.apple.com/documentation/realitykit)
- [ARKit Documentation](https://developer.apple.com/documentation/arkit)

### Swift Resources

- [Swift.org](https://swift.org)
- [Swift Book](https://docs.swift.org/swift-book/)
- [Swift Evolution](https://github.com/apple/swift-evolution)

### Project Resources

- [Implementation Plan](IMPLEMENTATION_PLAN.md) - 24-month roadmap
- [Testing Guide](TESTING_GUIDE.md) - Testing strategies
- [Deployment Guide](DEPLOYMENT.md) - Release process

---

## Getting Help

If you're stuck:

1. **Check Documentation**: Most answers are in our docs
2. **Search Issues**: Someone may have had the same problem
3. **Ask in Discussions**: Our community is here to help
4. **File an Issue**: If you've found a bug

---

## Summary

You should now have:
- ✅ Xcode and project set up
- ✅ Project building successfully
- ✅ Tests running
- ✅ Understanding of project structure
- ✅ Knowledge of development workflow

**Happy coding! 🎨✨**

For more detailed information, see the [full documentation](README.md#documentation).
