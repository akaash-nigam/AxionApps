# Getting Started with Parkour Pathways Development

This guide will help you set up your development environment and start contributing to Parkour Pathways.

## 📋 Prerequisites

### Required

- **macOS 14.0+** (Sonoma or later)
- **Xcode 16.0+** with visionOS SDK
- **Apple Developer Account** (for device testing)
- **Git** 2.30+

### Optional

- **Apple Vision Pro** (for hardware testing)
- **SwiftLint** (code quality)
- **SF Symbols** app (design assets)

## 🚀 Installation

### 1. Install Xcode

Download from the Mac App Store or Apple Developer:

```bash
# Via Mac App Store
open https://apps.apple.com/app/xcode/id497799835

# Or download from developer.apple.com
```

After installation, install command line tools:

```bash
xcode-select --install
```

### 2. Install visionOS SDK

1. Open Xcode
2. Go to **Settings** (⌘ + ,)
3. Select **Platforms** tab
4. Click **+** and download **visionOS**

### 3. Install SwiftLint (Recommended)

```bash
# Using Homebrew
brew install swiftlint

# Or using Mint
mint install realm/SwiftLint
```

### 4. Clone the Repository

```bash
# Clone the repo
git clone https://github.com/your-org/visionOS_Gaming_parkour-pathways.git
cd visionOS_Gaming_parkour-pathways

# Or using SSH
git clone git@github.com:your-org/visionOS_Gaming_parkour-pathways.git
```

## 🔧 Project Setup

### Open in Xcode

```bash
# Open the Swift Package
open ParkourPathways/Package.swift

# Or open entire directory
open -a Xcode .
```

### Configure Signing

1. Select **ParkourPathways** target
2. Go to **Signing & Capabilities**
3. Select your **Team**
4. Enable **Automatically manage signing**

### Select Build Destination

Choose a build destination:
- **visionOS Simulator** (for basic testing)
- **Your Vision Pro** (for full testing)

## ▶️ Running the App

### In Simulator

```bash
# Select visionOS Simulator
# Press ⌘ + R to build and run
```

**Note**: Some features require actual hardware:
- ARKit spatial mapping
- Hand tracking
- True performance metrics

### On Device

1. Connect your Vision Pro via cable or Wi-Fi
2. Trust the device on Mac
3. Select device in Xcode
4. Press ⌘ + R

**First Run:**
- Xcode will install necessary components
- App will launch automatically
- Grant camera/spatial permissions

## 🧪 Running Tests

### All Tests

```bash
# In Xcode
⌘ + U

# Command line
swift test
```

### Specific Test Suite

```bash
swift test --filter MovementMechanicsTests
```

### With Coverage

```bash
swift test --enable-code-coverage

# View coverage report in Xcode:
# ⌘ + 9 → Coverage tab
```

### Hardware-Specific Tests

Tests in `HardwareTests/` require Vision Pro:

```bash
# Only run on actual device
swift test --filter SpatialMappingTests
```

## 📂 Project Structure

```
ParkourPathways/
├── App/                    # App entry point
│   ├── ParkourPathwaysApp.swift
│   └── AppCoordinator.swift
├── Core/                   # Core systems
│   ├── Audio/             # Audio & haptics
│   ├── Analytics/         # Analytics & monitoring
│   ├── Accessibility/     # Accessibility
│   ├── ECS/               # Entity-Component-System
│   └── Utilities/         # Tools & helpers
├── Features/              # Feature modules
│   ├── Spatial/          # ARKit integration
│   ├── CourseGeneration/ # AI course gen
│   ├── Movement/         # Parkour mechanics
│   └── Multiplayer/      # Networking
├── Data/                  # Data layer
├── Views/                 # SwiftUI views
└── Tests/                 # Test suites
```

## 🛠️ Development Workflow

### 1. Create a Feature Branch

```bash
git checkout -b feature/my-new-feature
```

### 2. Make Changes

Follow the [Style Guide](CONTRIBUTING.md#style-guides)

### 3. Write Tests

Every feature needs tests:

```swift
func testMyFeature_WhenCondition_ExpectedBehavior() {
    // Arrange, Act, Assert
}
```

### 4. Run Quality Checks

```bash
# SwiftLint
swiftlint

# Tests
swift test

# Build
⌘ + B
```

### 5. Commit Changes

```bash
git add .
git commit -m "feat(module): add feature description"
```

See [Commit Guidelines](CONTRIBUTING.md#commit-messages)

### 6. Push and Create PR

```bash
git push origin feature/my-new-feature
```

Then create a Pull Request on GitHub.

## 🐛 Debugging

### Xcode Debugger

- **Breakpoints**: Click line number
- **LLDB**: Use console for debugging
- **View hierarchy**: ⌘ + Click on UI element

### Instruments

Profile your changes:

```bash
# In Xcode: Product → Profile (⌘ + I)
# Choose template: Time Profiler, Allocations, etc.
```

### Common Issues

**"No such module 'RealityKit'"**
- Ensure visionOS SDK is installed
- Clean build folder (⌘ + Shift + K)

**"Code signing failed"**
- Check developer account
- Verify team selection
- Trust certificate in Keychain

**"Simulator not available"**
- Download visionOS Simulator
- Restart Xcode

## 📚 Learning Resources

### visionOS Development
- [Apple visionOS Documentation](https://developer.apple.com/visionos/)
- [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/visionos)
- [WWDC Videos](https://developer.apple.com/videos/)

### Swift & SwiftUI
- [Swift Documentation](https://swift.org/documentation/)
- [SwiftUI Tutorials](https://developer.apple.com/tutorials/swiftui)
- [100 Days of SwiftUI](https://www.hackingwithswift.com/100/swiftui)

### RealityKit
- [RealityKit Documentation](https://developer.apple.com/documentation/realitykit)
- [Creating 3D Content](https://developer.apple.com/documentation/realitykit/creating-3d-content)

### ARKit
- [ARKit Documentation](https://developer.apple.com/documentation/arkit)
- [Room Scanning](https://developer.apple.com/documentation/arkit/arkit_in_visionos)

## 🔑 API Keys & Secrets

**Never commit secrets!**

Create `.env` file (gitignored):

```bash
# .env (local only)
ANALYTICS_KEY=your_key_here
CLOUDKIT_CONTAINER=your_container
```

Load in code:

```swift
let key = ProcessInfo.processInfo.environment["ANALYTICS_KEY"]
```

## 🎯 Next Steps

Now that you're set up:

1. **Read the documentation** in `/Documentation`
2. **Browse existing code** to understand patterns
3. **Look for "good first issue"** labels
4. **Join our community** on Discord
5. **Make your first contribution**!

## 💬 Getting Help

- **Documentation**: Check `/Documentation` folder
- **Issues**: Search existing GitHub issues
- **Discussions**: Ask questions on GitHub Discussions
- **Discord**: Join for real-time help

## 📄 Additional Guides

- [Contributing Guide](CONTRIBUTING.md)
- [Architecture Documentation](ARCHITECTURE.md)
- [Deployment Guide](DEPLOYMENT.md)
- [Test Execution Guide](TEST_EXECUTION_GUIDE.md)

---

**Welcome to the team! Happy coding! 🎮**
