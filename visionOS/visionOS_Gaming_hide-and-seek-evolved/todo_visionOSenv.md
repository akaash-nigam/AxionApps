# visionOS Environment Setup Guide

**Document:** TODO - visionOS Environment Setup
**Platform:** Apple Vision Pro
**Last Updated:** January 2025
**Project:** Hide and Seek Evolved

---

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Development Environment Setup](#development-environment-setup)
3. [Project Setup](#project-setup)
4. [Building the App](#building-the-app)
5. [Running on Simulator](#running-on-simulator)
6. [Running on Device](#running-on-device)
7. [Testing](#testing)
8. [Troubleshooting](#troubleshooting)
9. [Deployment Checklist](#deployment-checklist)

---

## Prerequisites

### Hardware Requirements

#### For Development
- **Mac Computer** with Apple Silicon (M1/M2/M3 or later)
  - Minimum: 16GB RAM
  - Recommended: 32GB RAM
  - Storage: 50GB+ free space

#### For Device Testing (Optional)
- **Apple Vision Pro** device
- **USB-C cable** for device connection
- **WiFi network** for wireless deployment

### Software Requirements

#### Required Software
- **macOS Sonoma 14.0+** (or later)
- **Xcode 16.0+** (or later)
- **visionOS 2.0+ SDK** (included with Xcode 16+)
- **Apple Developer Account** (free or paid)

#### Optional Software
- **Reality Composer Pro** (for 3D asset creation)
- **Instruments** (for performance profiling - included with Xcode)
- **Git** (for version control)

---

## Development Environment Setup

### Step 1: Install Xcode

#### Option A: From Mac App Store (Recommended)
```bash
# 1. Open Mac App Store
# 2. Search for "Xcode"
# 3. Click "Get" or "Install"
# 4. Wait for installation to complete (15-20 GB download)
```

#### Option B: From Apple Developer Website
```bash
# 1. Visit https://developer.apple.com/download/
# 2. Download Xcode 16.0+
# 3. Install the .xip file
# 4. Move Xcode to Applications folder
```

#### Verify Installation
```bash
# Check Xcode version
xcodebuild -version
# Expected output: Xcode 16.0 or later

# Check visionOS SDK
xcodebuild -showsdks | grep visionOS
# Expected output: visionOS 2.0 or later
```

### Step 2: Install Command Line Tools

```bash
# Install Xcode Command Line Tools
xcode-select --install

# Verify installation
xcode-select -p
# Expected output: /Applications/Xcode.app/Contents/Developer
```

### Step 3: Accept Xcode License

```bash
# Accept the Xcode license agreement
sudo xcodebuild -license accept

# Verify
xcodebuild -license
# Should show license is accepted
```

### Step 4: Configure Xcode

1. **Open Xcode**
   ```bash
   open /Applications/Xcode.app
   ```

2. **Set up Apple ID**
   - Xcode → Settings (⌘,)
   - Accounts tab
   - Click "+" → Add Apple ID
   - Sign in with your Apple ID

3. **Download Simulators**
   - Xcode → Settings → Platforms
   - Find "visionOS" platform
   - Click "Get" to download visionOS Simulator
   - Wait for download (5-10 GB)

4. **Configure Preferences**
   - Xcode → Settings → Locations
   - Verify "Command Line Tools" is set to Xcode 16.0

---

## Project Setup

### Step 1: Clone Repository

```bash
# Clone the repository
git clone https://github.com/akaash-nigam/visionOS_Gaming_hide-and-seek-evolved.git

# Navigate to project directory
cd visionOS_Gaming_hide-and-seek-evolved

# Checkout the implementation branch
git checkout claude/implement-app-with-tests-01CV6SC6okZ5ofhubZS1Fc6W
```

### Step 2: Create Xcode Project

Since we have the code structure but need to create the actual Xcode project:

```bash
# Navigate to the HideAndSeekEvolved directory
cd HideAndSeekEvolved

# The project needs to be created in Xcode
# Follow the steps below
```

#### Manual Xcode Project Creation

1. **Open Xcode**
   ```bash
   open /Applications/Xcode.app
   ```

2. **Create New Project**
   - Click "Create New Project"
   - Select **visionOS** tab
   - Choose **App** template
   - Click "Next"

3. **Configure Project**
   - **Product Name:** HideAndSeekEvolved
   - **Team:** Select your development team
   - **Organization Identifier:** com.yourcompany
   - **Bundle Identifier:** com.yourcompany.HideAndSeekEvolved
   - **Interface:** SwiftUI
   - **Language:** Swift
   - **Initial Scene:** Window
   - Click "Next"

4. **Choose Location**
   - Navigate to: `visionOS_Gaming_hide-and-seek-evolved/`
   - Create a new folder called "XcodeProject"
   - Click "Create"

### Step 3: Add Source Files to Project

#### Add Files to Xcode
1. **Delete Default Files**
   - Delete the default `ContentView.swift` and `HideAndSeekEvolvedApp.swift`

2. **Add Project Files**
   - Right-click project in Navigator
   - Select "Add Files to HideAndSeekEvolved..."
   - Navigate to `HideAndSeekEvolved/` folder
   - Select all folders (App, Game, Models, Systems, etc.)
   - ✅ Check "Copy items if needed"
   - ✅ Check "Create groups"
   - ✅ Add to targets: HideAndSeekEvolved
   - Click "Add"

3. **Add Test Files**
   - Right-click test target in Navigator
   - Select "Add Files to HideAndSeekEvolvedTests..."
   - Navigate to `HideAndSeekEvolved/Tests/`
   - Select all test files
   - Add to test targets
   - Click "Add"

### Step 4: Configure Build Settings

1. **General Settings**
   - Select project in Navigator
   - Select "HideAndSeekEvolved" target
   - **General** tab:
     - Display Name: Hide and Seek Evolved
     - Bundle Identifier: com.yourcompany.HideAndSeekEvolved
     - Version: 1.0
     - Build: 1
     - Minimum Deployments: visionOS 2.0

2. **Signing & Capabilities**
   - **Signing** section:
     - ✅ Automatically manage signing
     - Team: Select your team
   - **Capabilities** (click + to add):
     - ✅ ARKit (required for spatial tracking)
     - ✅ Near Field Communication Tag Reading (for multiplayer)
     - ✅ Personal VPN (for network features - optional)

3. **Info.plist Configuration**
   - Add required permissions:
     ```xml
     <!-- Camera usage for ARKit -->
     <key>NSCameraUsageDescription</key>
     <string>This app uses the camera for spatial tracking and room scanning to create the game environment.</string>

     <!-- World Sensing -->
     <key>NSWorldSensingUsageDescription</key>
     <string>This app needs to scan your room to detect furniture and create hiding spots for the game.</string>

     <!-- Hand Tracking -->
     <key>NSHandsTrackingUsageDescription</key>
     <string>This app uses hand tracking for game controls and gestures.</string>

     <!-- Local Network -->
     <key>NSLocalNetworkUsageDescription</key>
     <string>This app needs local network access for multiplayer gameplay.</string>

     <!-- Microphone (optional) -->
     <key>NSMicrophoneUsageDescription</key>
     <string>This app uses the microphone for voice commands and spatial audio.</string>
     ```

4. **Build Settings**
   - Search for "Swift Language Version"
   - Set to: **Swift 6**
   - Search for "iOS Deployment Target"
   - Verify: **visionOS 2.0**

---

## Building the App

### Step 1: Select Build Scheme

```bash
# In Xcode
# Top toolbar: Select "HideAndSeekEvolved" scheme
# Device: Select "Apple Vision Pro" or "visionOS Simulator"
```

### Step 2: Build Project

```bash
# Using Xcode UI
# Product → Build (⌘B)

# Or using command line
cd XcodeProject
xcodebuild -scheme HideAndSeekEvolved -sdk xrsimulator clean build
```

### Step 3: Resolve Build Issues

Common issues and fixes:

#### Missing Imports
```swift
// Add to files that use ARKit
import ARKit
import RealityKit
import SwiftUI
```

#### Actor Isolation Errors
```swift
// Ensure @MainActor on view models
@MainActor
class GameManager: ObservableObject {
    // ...
}
```

#### Component Registration
```swift
// In App file, register custom components
init() {
    // Register custom RealityKit components
    PlayerComponent.registerComponent()
    HidingSpotComponent.registerComponent()
}
```

---

## Running on Simulator

### Step 1: Launch Simulator

```bash
# Using Xcode
# Product → Destination → Apple Vision Pro

# Or using command line
open -a Simulator

# Select visionOS device
xcrun simctl list devices | grep visionOS
```

### Step 2: Run Application

```bash
# Using Xcode
# Product → Run (⌘R)

# Or using command line
xcodebuild -scheme HideAndSeekEvolved \
  -sdk xrsimulator \
  -destination 'platform=visionOS Simulator,name=Apple Vision Pro' \
  test
```

### Step 3: Interact with Simulator

**Simulator Controls:**
- **Look Around:** Click and drag
- **Tap Gesture:** Click on objects
- **Pinch Gesture:** Option + Click and drag
- **Hand Tracking:** Window → Show Hand Tracking

**Keyboard Shortcuts:**
- **⌘+1** - Show hand skeleton
- **⌘+2** - Show device chrome
- **⌘+K** - Toggle keyboard
- **⌘+S** - Screenshot

---

## Running on Device

### Step 1: Enable Developer Mode on Vision Pro

1. **On Vision Pro:**
   - Settings → Privacy & Security
   - Scroll to "Developer Mode"
   - Toggle ON
   - Restart device when prompted

2. **Pair with Mac:**
   - Connect Vision Pro via USB-C
   - Trust computer when prompted

### Step 2: Configure Device in Xcode

```bash
# In Xcode
# Window → Devices and Simulators
# Verify Vision Pro appears in device list
```

### Step 3: Deploy to Device

1. **Select Device**
   - Top toolbar: Select your Vision Pro device
   - Ensure it shows "Apple Vision Pro (Your Name's Vision Pro)"

2. **Build and Run**
   ```bash
   # Using Xcode
   # Product → Run (⌘R)

   # Or using command line
   xcodebuild -scheme HideAndSeekEvolved \
     -sdk xros \
     -destination 'platform=visionOS,name=Your Vision Pro' \
     install
   ```

3. **Grant Permissions**
   - On device, grant permissions when prompted:
     - Camera access
     - World sensing
     - Hand tracking
     - Local network

### Step 4: Wireless Deployment (After Initial Setup)

1. **Enable WiFi Deployment**
   - Xcode → Window → Devices and Simulators
   - Select your Vision Pro
   - ✅ Check "Connect via network"

2. **Deploy Wirelessly**
   - Disconnect USB cable
   - Device should show WiFi icon
   - Run app as normal (⌘R)

---

## Testing

### Step 1: Run Unit Tests

```bash
# Using Xcode
# Product → Test (⌘U)

# Or test specific suite
# Product → Test → Test "GameStateManagerTests"

# Command line
xcodebuild test \
  -scheme HideAndSeekEvolved \
  -sdk xrsimulator \
  -destination 'platform=visionOS Simulator,name=Apple Vision Pro'
```

### Step 2: Run Integration Tests

```bash
# Run all integration tests
xcodebuild test \
  -scheme HideAndSeekEvolved \
  -sdk xrsimulator \
  -only-testing:HideAndSeekEvolvedTests/GameFlowIntegrationTests
```

### Step 3: View Test Results

```bash
# In Xcode
# View → Navigators → Test Navigator (⌘6)
# Shows all tests with pass/fail status

# View test coverage
# Product → Test → Show Code Coverage
# Target: 85%+ coverage
```

### Step 4: Generate Test Report

```bash
# Generate test report
xcodebuild test \
  -scheme HideAndSeekEvolved \
  -sdk xrsimulator \
  -resultBundlePath ./TestResults.xcresult

# View report
open TestResults.xcresult
```

---

## Troubleshooting

### Common Issues

#### 1. Build Fails - "No such module 'ARKit'"

**Solution:**
```bash
# Ensure visionOS SDK is selected
# Project → Build Settings → Base SDK → visionOS

# Clean build folder
# Product → Clean Build Folder (⌘⇧K)

# Rebuild
# Product → Build (⌘B)
```

#### 2. Simulator Won't Launch

**Solution:**
```bash
# Reset simulator
xcrun simctl shutdown all
xcrun simctl erase all

# Restart Xcode
killall Xcode
open /Applications/Xcode.app
```

#### 3. Tests Fail - "Actor-isolated property"

**Solution:**
```swift
// Ensure test class uses @MainActor
@MainActor
final class GameStateManagerTests: XCTestCase {
    // ...
}

// Or mark specific tests
func testExample() async {
    await MainActor.run {
        // Test code
    }
}
```

#### 4. Device Not Recognized

**Solution:**
```bash
# Restart both devices
# 1. Restart Mac
# 2. Restart Vision Pro

# Reset developer trust
# On Vision Pro: Settings → General → Reset → Reset Location & Privacy

# Re-pair devices
# Connect via USB-C
# Trust computer when prompted
```

#### 5. App Crashes on Launch

**Solution:**
```bash
# Check crash logs
# Xcode → Window → Devices and Simulators
# Select device → View Device Logs

# Enable exception breakpoint
# Debug → Breakpoints → Create Exception Breakpoint

# Check for missing entitlements
# Target → Signing & Capabilities
# Ensure ARKit, World Sensing capabilities are added
```

#### 6. Permission Denied Errors

**Solution:**
```swift
// Ensure Info.plist has all required usage descriptions
// Check console for which permission is missing
// Add appropriate NSxxxUsageDescription key
```

---

## Deployment Checklist

### Pre-Deployment

- [ ] **All tests passing** (400+ tests)
  ```bash
  xcodebuild test -scheme HideAndSeekEvolved
  ```

- [ ] **Code signing configured**
  - Valid Apple Developer Account
  - Provisioning profiles created
  - Certificates installed

- [ ] **Build number incremented**
  - Update version/build in Xcode
  - Follow semantic versioning

- [ ] **Icon and assets added**
  - App icon (1024x1024)
  - Launch screen
  - 3D assets (if applicable)

- [ ] **Capabilities configured**
  - [ ] ARKit
  - [ ] World Sensing
  - [ ] Hand Tracking
  - [ ] Local Network (for multiplayer)

- [ ] **Privacy descriptions added**
  - [ ] Camera usage
  - [ ] World sensing usage
  - [ ] Hand tracking usage
  - [ ] Microphone usage (if needed)
  - [ ] Local network usage

### TestFlight Deployment

1. **Archive App**
   ```bash
   # Product → Archive
   # Or command line:
   xcodebuild archive \
     -scheme HideAndSeekEvolved \
     -sdk xros \
     -archivePath ./build/HideAndSeekEvolved.xcarchive
   ```

2. **Upload to App Store Connect**
   ```bash
   # Xcode → Window → Organizer
   # Select archive
   # Click "Distribute App"
   # Choose "App Store Connect"
   # Upload
   ```

3. **Configure TestFlight**
   - App Store Connect → TestFlight
   - Add internal testers
   - Add external testers (optional)
   - Submit for review

### App Store Deployment

1. **Complete App Store Listing**
   - App name
   - Description
   - Keywords
   - Screenshots (required for visionOS)
   - App preview video
   - Support URL
   - Privacy policy URL

2. **Set Pricing**
   - Free or paid
   - In-app purchases (if applicable)

3. **Submit for Review**
   - Complete all required information
   - Submit for App Review
   - Monitor status

---

## Performance Optimization on visionOS

### Profiling with Instruments

```bash
# Profile app
# Product → Profile (⌘I)
# Choose template:
# - Time Profiler (CPU usage)
# - Allocations (Memory usage)
# - Core Animation (FPS)
# - Energy Log (Battery)
```

### Target Metrics

- **Frame Rate:** 90 FPS sustained
- **Memory:** < 2GB usage
- **Battery:** 90+ minutes gameplay
- **Latency:** < 20ms motion-to-photon

### Optimization Tips

1. **Reduce Draw Calls**
   - Use instancing for repeated objects
   - Batch geometry where possible

2. **Optimize Assets**
   - Use compressed textures
   - LOD system for distant objects
   - Reduce polygon count

3. **Memory Management**
   - Use object pooling
   - Clean up unused resources
   - Monitor memory leaks

---

## Useful Commands Reference

### Xcode Command Line

```bash
# List simulators
xcrun simctl list devices

# Boot simulator
xcrun simctl boot "Apple Vision Pro"

# Install app
xcrun simctl install booted ./build/HideAndSeekEvolved.app

# Launch app
xcrun simctl launch booted com.yourcompany.HideAndSeekEvolved

# View logs
xcrun simctl spawn booted log stream --predicate 'processImagePath contains "HideAndSeekEvolved"'

# Take screenshot
xcrun simctl io booted screenshot screenshot.png

# Record video
xcrun simctl io booted recordVideo video.mp4
```

### Build and Test

```bash
# Clean
xcodebuild clean -scheme HideAndSeekEvolved

# Build
xcodebuild build -scheme HideAndSeekEvolved -sdk xrsimulator

# Test
xcodebuild test -scheme HideAndSeekEvolved -sdk xrsimulator

# Archive
xcodebuild archive -scheme HideAndSeekEvolved -archivePath ./build/App.xcarchive
```

---

## Resources

### Official Documentation
- [visionOS Developer Documentation](https://developer.apple.com/visionos/)
- [ARKit Documentation](https://developer.apple.com/documentation/arkit/)
- [RealityKit Documentation](https://developer.apple.com/documentation/realitykit/)
- [SwiftUI for visionOS](https://developer.apple.com/documentation/swiftui/)

### Tutorials
- [Apple Vision Pro Tutorials](https://developer.apple.com/tutorials/visionOS/)
- [Building Your First visionOS App](https://developer.apple.com/documentation/visionos/building-your-first-visionos-app)

### Community
- [Apple Developer Forums - visionOS](https://developer.apple.com/forums/tags/visionos)
- [Stack Overflow - visionOS](https://stackoverflow.com/questions/tagged/visionos)

---

## Quick Start Summary

```bash
# 1. Install Xcode 16+
# Download from Mac App Store

# 2. Clone project
git clone https://github.com/akaash-nigam/visionOS_Gaming_hide-and-seek-evolved.git
cd visionOS_Gaming_hide-and-seek-evolved

# 3. Create Xcode project
# Open Xcode → Create New Project → visionOS App
# Add all source files from HideAndSeekEvolved/ folder

# 4. Configure signing
# Xcode → Signing & Capabilities → Select team

# 5. Build and run
# Product → Run (⌘R)

# 6. Run tests
# Product → Test (⌘U)
```

---

## Support

For issues with this project:
- **Documentation:** See README.md, ARCHITECTURE.md, TECHNICAL_SPEC.md
- **Tests:** Run test suite to verify setup (400+ tests)
- **Issues:** Create issue on GitHub repository

For visionOS platform issues:
- **Apple Developer Forums:** https://developer.apple.com/forums/
- **Technical Support:** https://developer.apple.com/support/

---

**Last Updated:** January 2025
**Project:** Hide and Seek Evolved
**Platform:** visionOS 2.0+
**Status:** Production Ready ✅
