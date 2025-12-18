# visionOS Environment Setup Guide

**Document**: Complete setup and deployment guide for City Builder Tabletop on visionOS
**Last Updated**: 2025-01-20
**Status**: Production Ready

---

## 📋 Table of Contents

1. [Prerequisites](#prerequisites)
2. [System Requirements](#system-requirements)
3. [Xcode Installation](#xcode-installation)
4. [visionOS SDK Setup](#visionos-sdk-setup)
5. [Project Setup](#project-setup)
6. [Simulator Configuration](#simulator-configuration)
7. [Device Setup](#device-setup)
8. [Building the Project](#building-the-project)
9. [Running Tests](#running-tests)
10. [Debugging](#debugging)
11. [Performance Profiling](#performance-profiling)
12. [Deployment](#deployment)
13. [Troubleshooting](#troubleshooting)

---

## Prerequisites

### Required Knowledge
- [ ] Basic Swift programming
- [ ] Familiarity with Xcode
- [ ] Understanding of iOS/visionOS app development
- [ ] Basic git usage

### Required Accounts
- [ ] Apple ID (free or paid developer account)
- [ ] Apple Developer Program membership ($99/year) - **Required for device testing**
- [ ] GitHub account (for repository access)

### Required Hardware

**For Development (Minimum)**:
- [ ] Mac with Apple Silicon (M1 or later) **OR** Intel Mac with macOS 15.0+
- [ ] 16GB RAM (32GB recommended)
- [ ] 50GB free disk space
- [ ] Stable internet connection

**For Device Testing (Optional but Recommended)**:
- [ ] Apple Vision Pro device
- [ ] USB-C cable (for device connection)
- [ ] Clean, flat surface for testing (table, desk)

---

## System Requirements

### macOS Requirements
```
Minimum: macOS 15.0 (Sequoia) or later
Recommended: Latest macOS version
Processor: Apple Silicon (M1/M2/M3) or Intel
RAM: 16GB minimum, 32GB recommended
Storage: 50GB+ free space
```

### Xcode Requirements
```
Minimum: Xcode 16.0
Recommended: Latest Xcode beta
visionOS SDK: 2.0 or later
Swift: 6.0+
```

### Network Requirements
```
Download Speed: 10 Mbps minimum (for SDK downloads)
Apple Developer Portal: Must be accessible
TestFlight: Must be accessible (for beta testing)
```

---

## Xcode Installation

### Step 1: Install Xcode

#### Option A: Mac App Store (Recommended)
```bash
# Open Mac App Store
open "macappstore://apps.apple.com/app/xcode/id497799835"

# Or search for "Xcode" in App Store
# Click "Get" or "Download"
# Wait for installation (may take 30-60 minutes)
```

#### Option B: Apple Developer Portal
1. Visit https://developer.apple.com/download/
2. Sign in with Apple ID
3. Download Xcode 16.0 or later
4. Install the downloaded .xip file
5. Move Xcode.app to /Applications

### Step 2: Install Command Line Tools
```bash
# Install command line tools
xcode-select --install

# Verify installation
xcode-select -p
# Should output: /Applications/Xcode.app/Contents/Developer

# Accept license
sudo xcodebuild -license accept
```

### Step 3: Verify Xcode Installation
```bash
# Check Xcode version
xcodebuild -version
# Expected output: Xcode 16.0 or later

# Check Swift version
swift --version
# Expected output: Swift 6.0 or later
```

---

## visionOS SDK Setup

### Step 1: Open Xcode
```bash
# Launch Xcode
open -a Xcode
```

### Step 2: Install visionOS Platform
1. Open Xcode
2. Go to **Xcode → Settings** (⌘,)
3. Click **Platforms** tab
4. Click **+** button
5. Select **visionOS** from the list
6. Click **Download & Install**
7. Wait for download (2-5 GB, may take 15-30 minutes)

### Step 3: Install visionOS Simulator
```bash
# List available simulators
xcrun simctl list devices available

# Expected output should include:
# visionOS 2.0
#     Apple Vision Pro (...)
```

### Step 4: Verify visionOS SDK
```bash
# Check installed SDKs
xcodebuild -showsdks

# Look for:
# visionOS 2.0
```

**Verification Checklist**:
- [ ] visionOS platform installed
- [ ] visionOS simulator available
- [ ] visionOS 2.0+ SDK present

---

## Project Setup

### Step 1: Clone Repository
```bash
# Clone from GitHub
cd ~/Developer  # or your preferred directory
git clone https://github.com/akaash-nigam/visionOS_Gaming_city-builder-tabletop.git

# Navigate to project
cd visionOS_Gaming_city-builder-tabletop

# Verify branch
git branch
# Should show: claude/implement-app-with-tests-013QqSMh1YFUUqDqG21X7Pw1
```

### Step 2: Open Project in Xcode
```bash
# Open the project
cd CityBuilderTabletop
open Package.swift

# Or use xed command
xed .
```

### Step 3: Configure Project Settings

#### In Xcode:
1. Select **CityBuilderTabletop** in Project Navigator
2. Select the **CityBuilderTabletop** target
3. Go to **Signing & Capabilities** tab
4. Select your **Team** (Apple ID)
5. Change **Bundle Identifier** if needed (must be unique)

```
Example Bundle ID: com.yourname.citybuilder.tabletop
```

### Step 4: Resolve Dependencies
```bash
# In project directory
swift package resolve

# This should complete quickly (no external dependencies)
```

### Step 5: Build Project
```bash
# Build for visionOS simulator
swift build

# Or build specific target
xcodebuild -scheme CityBuilderTabletop -destination 'platform=visionOS Simulator,name=Apple Vision Pro'
```

**Setup Verification Checklist**:
- [ ] Project opens without errors
- [ ] Signing configured correctly
- [ ] Dependencies resolved
- [ ] Initial build succeeds

---

## Simulator Configuration

### Step 1: Launch visionOS Simulator

#### Via Xcode:
1. Select **Product → Destination**
2. Choose **Apple Vision Pro** (simulator)
3. Click **Run** (⌘R)

#### Via Command Line:
```bash
# List available simulators
xcrun simctl list devices visionOS

# Boot simulator
xcrun simctl boot "Apple Vision Pro"

# Open simulator app
open /Applications/Xcode.app/Contents/Developer/Applications/Simulator.app
```

### Step 2: Configure Simulator Settings

In Simulator menu bar:

**Window Settings**:
- **Window → Stay On Top** (optional, for easy access)
- **Window → Size → 100%** (recommended starting size)

**Device Settings**:
- **Device → Erase All Content and Settings** (for clean slate)
- **Device → Appearance → Light/Dark** (as preferred)

### Step 3: Enable Development Features
```bash
# Enable developer mode on simulator (if needed)
xcrun simctl spawn booted defaults write com.apple.CoreSimulator.SimDevice.AppleInternal DeveloperModeEnabled -bool YES

# Restart simulator for changes to take effect
xcrun simctl shutdown all
xcrun simctl boot "Apple Vision Pro"
```

### Step 4: Test Simulator

**Basic Checks**:
- [ ] Simulator launches successfully
- [ ] Can interact with simulator (click, drag)
- [ ] No error messages in console
- [ ] Simulator responds to input

**Simulator Controls**:
- **Rotate View**: Click and drag with mouse
- **Pan**: Option + click and drag
- **Pinch/Zoom**: Option + Shift + click and drag
- **Reset**: Device → Erase All Content and Settings

---

## Device Setup

### Prerequisites
- [ ] Apple Vision Pro device
- [ ] Apple Developer Program membership ($99/year)
- [ ] USB-C cable
- [ ] Same WiFi network as Mac

### Step 1: Enable Developer Mode on Vision Pro

1. On Vision Pro, open **Settings**
2. Go to **Privacy & Security**
3. Scroll to **Developer Mode**
4. Toggle **Developer Mode** ON
5. Restart Vision Pro when prompted

### Step 2: Trust Computer

1. Connect Vision Pro to Mac via USB-C cable
2. On Vision Pro, tap **Trust** when prompted
3. Enter device passcode if required

### Step 3: Register Device (First Time)

1. Open Xcode
2. Go to **Window → Devices and Simulators** (⇧⌘2)
3. Select **Devices** tab
4. Your Vision Pro should appear in the list
5. Click **Register Device** if prompted
6. Wait for device registration (1-2 minutes)

### Step 4: Verify Device Connection
```bash
# List connected devices
xcrun devicectl list

# Should show your Vision Pro with:
# - Device name
# - Model: Apple Vision Pro
# - OS Version: visionOS 2.0+
# - Connection: USB/WiFi
```

### Step 5: Enable WiFi Debugging (Recommended)

1. In **Devices and Simulators** window
2. Select your Vision Pro
3. Check **Connect via network**
4. Wait for WiFi connection to establish
5. Disconnect USB cable (optional after WiFi is working)

**Device Setup Checklist**:
- [ ] Developer mode enabled
- [ ] Device trusted
- [ ] Device registered in Xcode
- [ ] WiFi debugging enabled (optional)
- [ ] Device appears in Xcode destinations

---

## Building the Project

### Build for Simulator

#### In Xcode:
1. Select **Product → Destination → Apple Vision Pro (simulator)**
2. Press **⌘B** (Build)
3. Wait for build completion (first build may take 2-3 minutes)

#### Via Command Line:
```bash
cd CityBuilderTabletop

# Build for simulator
xcodebuild \
  -scheme CityBuilderTabletop \
  -destination 'platform=visionOS Simulator,name=Apple Vision Pro' \
  build
```

### Build for Device

#### In Xcode:
1. Connect Vision Pro (USB or WiFi)
2. Select **Product → Destination → [Your Vision Pro name]**
3. Press **⌘B** (Build)
4. Enter credentials if prompted

#### Via Command Line:
```bash
# Build for connected device
xcodebuild \
  -scheme CityBuilderTabletop \
  -destination 'platform=visionOS,name=Your Vision Pro' \
  build
```

### Build Configuration

**Debug Build** (Development):
```bash
xcodebuild -configuration Debug
# Includes debug symbols, less optimized
# Larger binary size
# Faster compile time
```

**Release Build** (App Store):
```bash
xcodebuild -configuration Release
# Optimized for performance
# Smaller binary size
# Longer compile time
```

### Verify Build Success
```bash
# Check build logs
# Look for: BUILD SUCCEEDED
# No errors or warnings (ideal)
```

**Build Checklist**:
- [ ] Build completes successfully
- [ ] No compilation errors
- [ ] Minimal or no warnings
- [ ] Build time acceptable (< 5 minutes)

---

## Running Tests

### Run All Tests (Recommended)

#### In Xcode:
1. Press **⌘U** (Test)
2. Or: **Product → Test**
3. Wait for all tests to complete

#### Via Command Line:
```bash
cd CityBuilderTabletop

# Run all tests
swift test

# Expected output:
# Test Suite 'All tests' passed
# Executed 100+ tests
# Coverage: 80%+
```

### Run Specific Test Suite

```bash
# Run unit tests only
swift test --filter CityDataTests

# Run specific test
swift test --filter testInitialization

# Run integration tests
swift test --filter GameSystemsIntegrationTests

# Run performance tests
swift test --filter PerformanceTests
```

### View Test Results

#### In Xcode:
1. Open **Test Navigator** (⌘6)
2. View test results:
   - ✅ Green checkmark = Passed
   - ❌ Red X = Failed
3. Click failed test to see details
4. View test logs in console

#### Command Line Results:
```bash
# Verbose output
swift test --verbose

# Generate test report
swift test --enable-test-discovery 2>&1 | tee test-results.txt
```

### Code Coverage

#### In Xcode:
1. **Product → Test** (⌘U)
2. Open **Report Navigator** (⌘9)
3. Select latest test report
4. Click **Coverage** tab
5. View coverage per file

**Expected Coverage**:
- Overall: >80%
- Critical systems: 100%
- UI code: 60-70% (acceptable)

### Performance Testing

```bash
# Run performance tests with metrics
swift test --filter PerformanceTests

# Expected results:
# ✅ 1000 citizens @ 60 FPS: PASS
# ✅ 500 vehicles @ 60 FPS: PASS
# ✅ Full simulation: PASS
```

**Testing Checklist**:
- [ ] All unit tests pass (70+ tests)
- [ ] All integration tests pass (10+ tests)
- [ ] All performance tests pass (7 tests)
- [ ] Code coverage >80%
- [ ] No flaky tests

---

## Debugging

### Enable Debug Output

#### In Code:
```swift
#if DEBUG
    print("[DEBUG] Detailed log message")
#endif
```

#### In Xcode:
1. **Product → Scheme → Edit Scheme** (⌘<)
2. Select **Run** in left sidebar
3. Go to **Arguments** tab
4. Add environment variables:
   - `DEBUG=1`
   - `VERBOSE_LOGGING=1`

### Debug on Simulator

1. Set breakpoints in code (click line number gutter)
2. Run in debug mode (⌘R)
3. App pauses at breakpoints
4. Use debug controls:
   - **Continue**: F6 or click ▶️
   - **Step Over**: F7
   - **Step Into**: F8
   - **Step Out**: F9

### Debug on Device

**Same as simulator**, but with additional options:

1. **Console Logging**:
```bash
# View device logs
xcrun devicectl device info logs --device [device-id]

# Stream logs in real-time
xcrun devicectl device info logs --device [device-id] --stream
```

2. **Network Debugging**:
   - Enable WiFi debugging
   - Use wireless breakpoints
   - Lower latency than USB

### Memory Debugging

#### In Xcode:
1. Run app with **Debug Navigator** open (⌘7)
2. Click **Memory** graph
3. Monitor memory usage
4. Look for:
   - Memory leaks (unexpected growth)
   - High memory warnings
   - Allocation spikes

#### Instruments:
```bash
# Profile with Instruments
xcodebuild \
  -scheme CityBuilderTabletop \
  -destination 'platform=visionOS Simulator' \
  -enableCodeCoverage YES \
  build test

# Or use Xcode: Product → Profile (⌘I)
```

### Performance Debugging

**Using Instruments**:
1. **Product → Profile** (⌘I)
2. Select **Time Profiler**
3. Click **Record**
4. Interact with app
5. Stop recording
6. Analyze hot spots (slow functions)

**Target Metrics**:
- Frame rate: 60-90 FPS
- Memory: < 2GB
- CPU: < 50% average

### Common Issues

**Issue: Build Fails**
```bash
# Clean build folder
rm -rf .build
swift package clean

# Reset package cache
rm -rf ~/.swiftpm/cache

# Rebuild
swift build
```

**Issue: Tests Fail**
```bash
# Run specific failing test
swift test --filter [TestName]

# Enable verbose output
swift test --verbose

# Check test logs
```

**Issue: App Crashes**
1. Check crash logs in Xcode Organizer
2. Look for stack trace
3. Check console output
4. Enable exception breakpoint

**Debugging Checklist**:
- [ ] Breakpoints work
- [ ] Console shows logs
- [ ] Memory usage normal
- [ ] No crashes during testing
- [ ] Performance metrics met

---

## Performance Profiling

### Using Instruments

#### CPU Profiling:
```bash
# Launch Instruments
open -a Instruments

# Or from Xcode: Product → Profile (⌘I)
```

**Select Template**:
1. **Time Profiler** - CPU usage
2. **Allocations** - Memory allocation
3. **Leaks** - Memory leaks
4. **System Trace** - Overall system performance

#### Profile Steps:
1. Click **Record** (red circle)
2. Interact with app for 30-60 seconds
3. Click **Stop**
4. Analyze results:
   - Find hot spots (heaviest stack trace)
   - Look for memory leaks
   - Check allocation patterns

### Frame Rate Monitoring

#### In Xcode:
1. Run app in debug mode
2. Open **Debug Navigator** (⌘7)
3. Select **FPS** graph
4. Monitor frame rate in real-time

**Target FPS**:
- Ideal: 90 FPS
- Acceptable: 60 FPS
- Warning: < 45 FPS

### Memory Profiling

```bash
# Profile memory usage
instruments -t Allocations -D trace.trace \
  -w [device-id] \
  CityBuilderTabletop
```

**Watch For**:
- Memory leaks (red flags in Instruments)
- Abandoned memory (not freed)
- High-water mark (peak memory)

**Target Memory**:
- Small city: < 500 MB
- Medium city: < 1 GB
- Large city: < 2 GB

### Network Profiling (Multiplayer)

#### Future Phase:
```bash
# Monitor network activity
instruments -t Network -D trace.trace CityBuilderTabletop
```

### Battery Impact

**Check Battery Usage**:
1. Run app for extended period (30 minutes)
2. Monitor battery drain
3. Optimize if drain > 20% per hour

**Optimization Tips**:
- Reduce update frequency when idle
- Use lower LOD when appropriate
- Throttle simulation when backgrounded

---

## Deployment

### TestFlight Beta Testing

#### Step 1: Archive Build
1. In Xcode, select **Any visionOS Device**
2. **Product → Archive**
3. Wait for archive (5-10 minutes)

#### Step 2: Upload to App Store Connect
1. **Window → Organizer**
2. Select your archive
3. Click **Distribute App**
4. Choose **TestFlight & App Store**
5. Follow prompts
6. Upload (10-30 minutes depending on size)

#### Step 3: Configure TestFlight
1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Select your app
3. Go to **TestFlight** tab
4. Add internal testers (up to 100)
5. Add external testers (submit for review)

#### Step 4: Distribute to Testers
1. Testers receive email
2. Install TestFlight on Vision Pro
3. Download and test app
4. Collect feedback

### App Store Submission

#### Prerequisites:
- [ ] App Store Connect account
- [ ] App ID registered
- [ ] Screenshots prepared (required sizes)
- [ ] App icon (1024x1024)
- [ ] Privacy policy URL
- [ ] App description
- [ ] Keywords
- [ ] Age rating
- [ ] Pricing information

#### Step 1: Prepare Metadata
Create screenshots:
- 5-10 screenshots (various features)
- App preview video (optional, recommended)
- Description (up to 4000 characters)

#### Step 2: Submit for Review
1. In App Store Connect
2. Go to **App Store** tab
3. Click **+ Version**
4. Fill in all required fields
5. Select build from TestFlight
6. Submit for Review

#### Step 3: Review Process
- Initial review: 1-3 days
- Typical review: 24-48 hours
- Rejections: Address issues and resubmit

### Ad Hoc Distribution

For device testing without TestFlight:

```bash
# Create ad hoc provisioning profile
# In Apple Developer Portal:
1. Create Ad Hoc profile
2. Add device UDIDs
3. Download profile
4. Install in Xcode

# Export ad hoc build
# In Xcode Organizer:
1. Select archive
2. Distribute → Ad Hoc
3. Export IPA
4. Share IPA file with testers
```

---

## Troubleshooting

### Common Xcode Issues

#### Issue: "visionOS platform not available"
**Solution**:
```bash
# Install visionOS platform
# Xcode → Settings → Platforms → + → visionOS

# Restart Xcode
killall Xcode
open -a Xcode
```

#### Issue: "Unable to boot simulator"
**Solution**:
```bash
# Kill existing simulator processes
killall Simulator

# Delete and recreate simulator
xcrun simctl delete unavailable
xcrun simctl list devices

# Reboot simulator
xcrun simctl boot "Apple Vision Pro"
```

#### Issue: "Code signing error"
**Solution**:
1. Xcode → Settings → Accounts
2. Re-download certificates
3. Clean build folder (⇧⌘K)
4. Rebuild

#### Issue: "Swift compiler error"
**Solution**:
```bash
# Clear derived data
rm -rf ~/Library/Developer/Xcode/DerivedData

# Clear module cache
rm -rf ~/Library/Caches/org.swift.swiftpm

# Clean and rebuild
swift package clean
swift build
```

### Common Build Issues

#### Issue: "Build failed - cannot find module"
**Solution**:
```bash
# Resolve dependencies
swift package resolve
swift package update

# Clean and rebuild
swift package clean
swift build
```

#### Issue: "Linker error"
**Solution**:
- Check target membership of files
- Verify import statements
- Clean build folder
- Rebuild from scratch

#### Issue: "Too many warnings"
**Solution**:
```bash
# Fix warnings incrementally
# Enable "Treat Warnings as Errors" in release builds

# Build settings:
SWIFT_TREAT_WARNINGS_AS_ERRORS = YES
```

### Common Runtime Issues

#### Issue: "App crashes on launch"
**Debug Steps**:
1. Check crash logs (Xcode Organizer)
2. Look for exception type
3. Check stack trace
4. Add breakpoints
5. Run in debug mode

#### Issue: "Poor performance"
**Optimization Steps**:
1. Profile with Instruments
2. Identify bottlenecks
3. Optimize hot spots
4. Reduce draw calls
5. Use LOD system

#### Issue: "Memory warning"
**Solutions**:
- Profile with Instruments
- Check for retain cycles
- Reduce texture sizes
- Implement object pooling
- Clear caches regularly

### Device-Specific Issues

#### Issue: "Cannot connect to device"
**Solutions**:
1. Reconnect USB cable
2. Trust computer on device
3. Restart device
4. Restart Xcode
5. Check developer mode enabled

#### Issue: "App not appearing on device"
**Solutions**:
1. Check bundle ID matches provisioning
2. Verify code signing
3. Check device UDID registered
4. Reinstall provisioning profile

### Getting Help

**Apple Documentation**:
- [visionOS Documentation](https://developer.apple.com/documentation/visionos)
- [RealityKit Documentation](https://developer.apple.com/documentation/realitykit)
- [ARKit Documentation](https://developer.apple.com/documentation/arkit)

**Apple Developer Forums**:
- https://developer.apple.com/forums/

**WWDC Videos**:
- Search "visionOS" on [Apple Developer Videos](https://developer.apple.com/videos/)

**Project Documentation**:
- See [PROJECT_SUMMARY.md](./PROJECT_SUMMARY.md)
- See [ARCHITECTURE.md](./ARCHITECTURE.md)
- See [TECHNICAL_SPEC.md](./TECHNICAL_SPEC.md)

---

## Quick Reference Commands

```bash
# Project Setup
git clone <repo-url>
cd CityBuilderTabletop
swift package resolve

# Build
swift build                                    # Build project
swift build -c release                         # Release build

# Test
swift test                                     # Run all tests
swift test --filter <TestName>                 # Run specific test
swift test --verbose                           # Verbose output

# Clean
swift package clean                            # Clean build
rm -rf .build                                  # Remove build artifacts

# Xcode
xed .                                          # Open in Xcode
xcodebuild -list                              # List schemes
xcodebuild -showsdks                          # Show SDKs

# Simulator
xcrun simctl list devices                      # List simulators
xcrun simctl boot "Apple Vision Pro"           # Boot simulator
xcrun simctl shutdown all                      # Shutdown simulators

# Device
xcrun devicectl list                           # List devices
xcrun devicectl device info logs --device <id> # View logs
```

---

## Checklist: Complete Setup

### Initial Setup
- [ ] macOS 15.0+ installed
- [ ] Xcode 16.0+ installed
- [ ] Command line tools installed
- [ ] Apple Developer account set up
- [ ] visionOS SDK installed
- [ ] visionOS simulator available

### Project Setup
- [ ] Repository cloned
- [ ] Project opens in Xcode
- [ ] Dependencies resolved
- [ ] Code signing configured
- [ ] Initial build successful

### Testing Setup
- [ ] All tests run successfully
- [ ] Code coverage >80%
- [ ] Performance tests pass
- [ ] No test failures

### Development Environment
- [ ] Simulator configured
- [ ] Device connected (if available)
- [ ] Developer mode enabled
- [ ] WiFi debugging works (optional)
- [ ] Breakpoints work
- [ ] Console logging works

### Ready for Development
- [ ] Can build for simulator
- [ ] Can build for device
- [ ] Can run tests
- [ ] Can debug effectively
- [ ] Can profile performance

---

## Success! 🎉

If you've completed all the steps above, your visionOS development environment is fully configured and ready for City Builder Tabletop development!

**Next Steps**:
1. Review [PROJECT_SUMMARY.md](./PROJECT_SUMMARY.md) for project overview
2. Read [ARCHITECTURE.md](./ARCHITECTURE.md) for technical details
3. Check [TECHNICAL_SPEC.md](./TECHNICAL_SPEC.md) for implementation specs
4. Start developing Phase 2 features!

**Need Help?**
- Check [Troubleshooting](#troubleshooting) section
- Review Apple's visionOS documentation
- Ask on Apple Developer Forums

---

*This guide will be updated as new visionOS features and best practices emerge.*
