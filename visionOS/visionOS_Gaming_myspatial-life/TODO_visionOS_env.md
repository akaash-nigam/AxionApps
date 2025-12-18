# MySpatial Life - visionOS Environment Setup Guide

This document provides step-by-step instructions for setting up your development environment and running MySpatial Life on Apple Vision Pro (simulator or device).

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Development Environment Setup](#development-environment-setup)
3. [Project Setup](#project-setup)
4. [Running on Vision Pro Simulator](#running-on-vision-pro-simulator)
5. [Running on Physical Vision Pro Device](#running-on-physical-vision-pro-device)
6. [Testing & Debugging](#testing--debugging)
7. [Troubleshooting](#troubleshooting)
8. [visionOS-Specific Configurations](#visionos-specific-configurations)

---

## Prerequisites

### Hardware Requirements

**For Development:**
- Mac with Apple Silicon (M1, M2, M3, or later) **REQUIRED**
- macOS Sonoma 14.0 or later
- Minimum 16GB RAM (32GB recommended)
- 50GB+ free disk space

**For Device Testing:**
- Apple Vision Pro device
- USB-C cable for device connection
- Same Wi-Fi network for wireless debugging

### Software Requirements

**Essential:**
- Xcode 16.0 or later
- visionOS 2.0 SDK (included with Xcode 16+)
- Command Line Tools for Xcode

**Optional but Recommended:**
- Reality Composer Pro (included with Xcode)
- Instruments (included with Xcode)
- SF Symbols app (for UI design)

---

## Development Environment Setup

### Step 1: Install Xcode 16+

1. **Download Xcode:**
   ```bash
   # Option 1: From Mac App Store (recommended)
   # Open App Store and search for "Xcode"

   # Option 2: From Apple Developer
   # Visit: https://developer.apple.com/download/
   ```

2. **Verify Installation:**
   ```bash
   xcode-select --version
   # Should show: xcode-select version 2403 or later

   xcodebuild -version
   # Should show: Xcode 16.0 or later
   ```

3. **Install Command Line Tools:**
   ```bash
   xcode-select --install
   ```

4. **Accept Xcode License:**
   ```bash
   sudo xcodebuild -license accept
   ```

### Step 2: Install visionOS SDK

The visionOS SDK comes bundled with Xcode 16+, but you need to verify it's available:

1. Open Xcode
2. Go to **Xcode → Settings → Platforms**
3. Verify **visionOS** is listed
4. If not installed, click the **+** button and download visionOS SDK

**Verify SDK Installation:**
```bash
xcodebuild -showsdks | grep visionOS
# Should show: visionOS 2.0 or later
```

### Step 3: Install Additional Components

1. **Reality Composer Pro** (for 3D assets):
   - Already included with Xcode 16
   - Access via: Xcode → Open Developer Tool → Reality Composer Pro

2. **iOS/visionOS Simulators:**
   ```bash
   # List available simulators
   xcrun simctl list devices

   # Install Vision Pro simulator if not present
   # Go to: Xcode → Settings → Platforms → visionOS → Get
   ```

---

## Project Setup

### Step 1: Clone the Repository

```bash
# Navigate to your projects directory
cd ~/Projects

# Clone the repository
git clone https://github.com/akaash-nigam/visionOS_Gaming_myspatial-life.git

# Navigate into project
cd visionOS_Gaming_myspatial-life

# Checkout the development branch
git checkout claude/implement-app-with-tests-01G1iuZbgp3P8gsWx91H5D9p
```

### Step 2: Open Project in Xcode

```bash
# Open the Xcode project
open MySpatialLife/MySpatialLife.xcodeproj

# Or open the entire folder
open MySpatialLife/
```

### Step 3: Configure Swift Package Dependencies

The project uses Swift Package Manager. Dependencies should resolve automatically.

**Manual Resolution (if needed):**
1. In Xcode, go to **File → Packages → Resolve Package Versions**
2. Wait for dependencies to download:
   - swift-algorithms
   - swift-collections
   - swift-numerics

**Verify Dependencies:**
```bash
cd MySpatialLife
swift package resolve
swift package show-dependencies
```

### Step 4: Configure Signing & Capabilities

1. Select the **MySpatialLife** target
2. Go to **Signing & Capabilities** tab
3. **Team:** Select your Apple Developer account
4. **Bundle Identifier:** Use your own (e.g., `com.yourname.myspatiallife`)
5. Enable required capabilities (pre-configured):
   - ✅ ARKit
   - ✅ World Sensing
   - ✅ Hand Tracking

**Note:** You need an Apple Developer account ($99/year) for device testing.

---

## Running on Vision Pro Simulator

### Step 1: Select Simulator

1. In Xcode toolbar, click the device selector (next to Run button)
2. Select **Apple Vision Pro**
3. If not visible, go to **Window → Devices and Simulators → Simulators**
4. Click **+** → Select **visionOS → Apple Vision Pro**

### Step 2: Build and Run

```bash
# Option 1: Via Xcode GUI
# Press Cmd+R or click the Run button (▶️)

# Option 2: Via Command Line
cd MySpatialLife
xcodebuild -scheme MySpatialLife \
  -destination 'platform=visionOS Simulator,name=Apple Vision Pro' \
  build
```

### Step 3: Simulator Controls

**Keyboard Shortcuts:**
- **⌘ + 1, 2, 3** - Switch between windows
- **⌘ + Shift + H** - Go to home
- **⌘ + Shift + 4** - Take screenshot
- **⌘ + K** - Toggle software keyboard

**Hand Tracking Simulation:**
- **Option + Drag** - Simulate hand movement
- **Shift + Option + Drag** - Simulate pinch gesture
- **Control + Option + Drag** - Simulate gaze

**Tips:**
- Simulator performance is slower than device
- Some features (room scanning) limited in simulator
- Use for UI/logic testing, not performance testing

---

## Running on Physical Vision Pro Device

### Step 1: Enable Developer Mode on Vision Pro

1. **On Vision Pro:**
   - Go to **Settings → Privacy & Security**
   - Scroll down to **Developer Mode**
   - Toggle **ON**
   - Restart Vision Pro

2. **Verify Developer Mode:**
   - Look for Developer menu in Settings
   - Should see options for wireless debugging

### Step 2: Connect Vision Pro to Mac

**Via USB-C Cable:**
1. Connect Vision Pro to Mac with USB-C cable
2. On Vision Pro, tap **Trust This Computer**
3. Enter Vision Pro passcode

**Via Wi-Fi (Wireless Debugging):**
1. Ensure both devices on same Wi-Fi network
2. In Xcode: **Window → Devices and Simulators**
3. Select your Vision Pro device
4. Check **Connect via network**
5. Disconnect cable (device should remain connected)

### Step 3: Build and Run on Device

1. **Select Device:**
   - In Xcode device selector
   - Choose your Vision Pro (name you gave it)

2. **Build Configuration:**
   - Ensure **Debug** configuration selected
   - Check **Signing & Capabilities** configured correctly

3. **Run:**
   ```bash
   # Press Cmd+R in Xcode

   # Or via command line:
   xcodebuild -scheme MySpatialLife \
     -destination 'platform=visionOS,name=Your Vision Pro' \
     build
   ```

4. **First Launch:**
   - On Vision Pro, approve app installation
   - App will install and launch automatically

### Step 4: Wireless Debugging Setup

For best development experience, enable wireless debugging:

1. **In Xcode → Devices and Simulators:**
   - Select Vision Pro device
   - Enable **Connect via network**
   - Note IP address

2. **Verify Connection:**
   ```bash
   # Check connected devices
   xcrun devicectl list devices

   # Should show Vision Pro with IP address
   ```

---

## Testing & Debugging

### Running Unit Tests

**Via Xcode:**
1. Press **Cmd+U** to run all tests
2. Or click test diamond in gutter of test files
3. View results in **Test Navigator** (Cmd+6)

**Via Command Line:**
```bash
cd MySpatialLife

# Run all tests
xcodebuild test \
  -scheme MySpatialLife \
  -destination 'platform=visionOS Simulator,name=Apple Vision Pro'

# Run specific test
xcodebuild test \
  -scheme MySpatialLife \
  -destination 'platform=visionOS Simulator,name=Apple Vision Pro' \
  -only-testing:MySpatialLifeTests/PersonalityTests
```

### Debugging on Device

**Enable Console Logging:**
```bash
# On Mac, open Console app
# Select Vision Pro device from sidebar
# Filter for "MySpatialLife"
```

**Xcode Debugging:**
1. Set breakpoints in code
2. Run app with debugger (Cmd+R)
3. Use Debug Navigator (Cmd+7) for:
   - Memory usage
   - CPU usage
   - Thread inspection

**Performance Profiling:**
```bash
# Launch Instruments
# Cmd+I in Xcode or:
open -a Instruments

# Select Vision Pro device
# Choose template:
# - Time Profiler (CPU usage)
# - Allocations (memory usage)
# - System Trace (overall performance)
```

### Testing Spatial Features

**Room Scanning (Device Only):**
1. Enable World Sensing in capabilities
2. Run app on device (not simulator)
3. Walk around room for scanning
4. Check ARKit session status in debugger

**Hand Tracking:**
1. Simulator: Use Option+Drag
2. Device: Use natural hand gestures
3. Debug with: **Settings → Developer → Hand Tracking Visualization**

---

## Troubleshooting

### Common Issues and Solutions

#### 1. "Failed to prepare device for development"

**Problem:** Vision Pro not ready for development

**Solution:**
```bash
# Reset device preparation
xcrun devicectl device info prepare --device <device-id>

# Or in Xcode: Window → Devices → Right-click device → Prepare for Development
```

#### 2. "No signing certificate found"

**Problem:** Missing developer certificate

**Solution:**
1. Go to Xcode → Settings → Accounts
2. Click your Apple ID
3. Click **Manage Certificates**
4. Click **+** → **Apple Development**
5. Restart Xcode

#### 3. "Swift package resolution failed"

**Problem:** Dependencies not downloading

**Solution:**
```bash
# Clear package cache
rm -rf ~/Library/Caches/org.swift.swiftpm/
rm -rf ~/Library/Developer/Xcode/DerivedData/

# Re-resolve packages
cd MySpatialLife
swift package reset
swift package resolve
```

#### 4. "Simulator not showing up"

**Problem:** Vision Pro simulator not available

**Solution:**
```bash
# Check installed simulators
xcrun simctl list devices

# Install if missing
# Xcode → Settings → Platforms → visionOS → Download

# Create new simulator
xcrun simctl create "Vision Pro Test" "Apple Vision Pro" "visionOS2.0"
```

#### 5. Build fails with "Module not found"

**Problem:** Swift package dependencies not linked

**Solution:**
1. Clean build folder: **Product → Clean Build Folder** (Cmd+Shift+K)
2. Delete DerivedData:
   ```bash
   rm -rf ~/Library/Developer/Xcode/DerivedData/MySpatialLife-*
   ```
3. Rebuild: Cmd+B

#### 6. App crashes on launch

**Problem:** Runtime error or missing resources

**Solution:**
1. Check Console app for crash logs
2. Look for:
   ```bash
   # View crash logs
   ls ~/Library/Logs/DiagnosticReports/ | grep MySpatialLife

   # Open recent crash log
   open ~/Library/Logs/DiagnosticReports/MySpatialLife*.crash
   ```
3. Run with debugger to catch exception

#### 7. "Untrusted Developer" on device

**Problem:** App not verified

**Solution:**
1. On Vision Pro: **Settings → General → VPN & Device Management**
2. Select your developer profile
3. Tap **Trust**

---

## visionOS-Specific Configurations

### Required Info.plist Keys

Ensure these are in your `Info.plist`:

```xml
<!-- Required for World Sensing -->
<key>NSWorldSensingUsageDescription</key>
<string>MySpatial Life needs to understand your room layout to place family members naturally in your space.</string>

<!-- Required for Hand Tracking -->
<key>NSHandTrackingUsageDescription</key>
<string>MySpatial Life uses hand tracking for natural interactions with your virtual family.</string>

<!-- Required for Camera (Photo Mode) -->
<key>NSCameraUsageDescription</key>
<string>MySpatial Life uses the camera for photo mode to capture special family moments.</string>

<!-- Optional: Microphone for Voice Commands -->
<key>NSMicrophoneUsageDescription</key>
<string>MySpatial Life uses the microphone for voice commands to interact with family members.</string>
```

### Required Capabilities

Enable in **Signing & Capabilities** tab:

1. **ARKit** - For spatial tracking
2. **World Sensing** - For room scanning
3. **Hand Tracking** - For hand gestures

### Recommended Settings

**Build Settings:**
```
Swift Language Version: Swift 6.0
Minimum visionOS Version: visionOS 2.0
Optimization Level (Debug): -Onone
Optimization Level (Release): -O -whole-module-optimization
```

**Scheme Settings:**
1. Edit Scheme (Cmd+<)
2. Run → Options:
   - ✅ GPU Frame Capture: Automatically Enabled
   - ✅ GPU Validation: Enabled (Debug only)
   - ✅ Main Thread Checker: Enabled

---

## Performance Optimization on visionOS

### Frame Rate Monitoring

```swift
// Add to your app for monitoring
import MetricKit

class PerformanceMonitor: NSObject, MXMetricManagerSubscriber {
    func didReceive(_ payloads: [MXMetricPayload]) {
        for payload in payloads {
            print("FPS: \(payload.timelineData?.averageFPS ?? 0)")
            print("Memory: \(payload.memoryMetrics?.peakMemoryUsage ?? 0)")
        }
    }
}
```

### Memory Management

Monitor memory with Instruments:
```bash
# Launch Memory Graph Debugger
# Debug → View Memory Graph (Cmd+Shift+M)

# Check for:
# - Retain cycles
# - Memory leaks
# - Large allocations
```

### Battery Optimization

Enable Energy Impact in Xcode:
1. Run app with debugger
2. Debug Navigator → Energy
3. Monitor for high energy usage
4. Optimize rendering, physics, AI update rates

---

## Next Steps

Once your environment is set up:

1. ✅ Read the [README.md](README.md) for project overview
2. ✅ Review [ARCHITECTURE.md](ARCHITECTURE.md) for technical details
3. ✅ Check [IMPLEMENTATION_PLAN.md](IMPLEMENTATION_PLAN.md) for roadmap
4. ✅ Run tests to verify setup: `Cmd+U`
5. ✅ Start implementing missing features (Needs System, AI, etc.)

---

## Resources

**Apple Documentation:**
- [visionOS Developer](https://developer.apple.com/visionos/)
- [RealityKit Documentation](https://developer.apple.com/documentation/realitykit/)
- [ARKit Documentation](https://developer.apple.com/documentation/arkit/)
- [SwiftUI for visionOS](https://developer.apple.com/documentation/swiftui/bringing-your-app-to-visionos)

**Sample Code:**
- [Apple Sample Code](https://developer.apple.com/sample-code/visionos/)
- [Hello World visionOS](https://developer.apple.com/documentation/visionos/world)

**Community:**
- [Apple Developer Forums - visionOS](https://developer.apple.com/forums/tags/visionos)
- [Swift Forums](https://forums.swift.org/)

**Tools:**
- [Reality Composer Pro](https://developer.apple.com/augmented-reality/tools/)
- [SF Symbols](https://developer.apple.com/sf-symbols/)
- [Instruments Help](https://help.apple.com/instruments/)

---

## Support

If you encounter issues:

1. Check [Troubleshooting](#troubleshooting) section above
2. Search [Apple Developer Forums](https://developer.apple.com/forums/)
3. Review [Known Issues](https://developer.apple.com/documentation/visionos-release-notes)
4. Open an issue in this repository

---

**Ready to build MySpatial Life!** 🚀

*Last Updated: 2025-01-20*
