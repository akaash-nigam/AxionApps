# Build Guide - Supply Chain Control Tower

## Prerequisites

Before building, ensure you have:

- ✅ **macOS 14.0+** (Sonoma or later)
- ✅ **Xcode 16.0+** with visionOS SDK
- ✅ **Apple Vision Pro** (device or simulator)
- ✅ **Apple Developer Account** (for device deployment)

## Quick Start

### Option 1: Create New Xcode Project (Recommended)

1. **Create a new visionOS App in Xcode:**
   ```
   File → New → Project → visionOS → App
   ```

2. **Configure project settings:**
   - Product Name: `SupplyChainControlTower`
   - Interface: SwiftUI
   - Language: Swift
   - Minimum Deployment Target: visionOS 2.0

3. **Copy source files:**
   ```bash
   # From this repository, copy the SupplyChainControlTower folder contents
   # into your new Xcode project, maintaining the folder structure
   ```

4. **Add files to Xcode:**
   - Drag the folders into your project navigator
   - Ensure "Copy items if needed" is checked
   - Ensure "Create groups" is selected
   - Add to target: SupplyChainControlTower

5. **Configure Info.plist:**
   - Copy the contents from `SupplyChainControlTower/Info.plist`
   - Add required privacy descriptions
   - Enable required capabilities

6. **Build and Run:**
   - Select visionOS Simulator or connected Vision Pro
   - Press ⌘R or click the Run button

### Option 2: Validate Before Building

Run the validation script to ensure all files are in place:

```bash
./validate.sh
```

Expected output:
```
✅ Validation PASSED!
Passed: 35
Warnings: 1
```

## Project Structure in Xcode

After adding files, your Xcode project should have this structure:

```
SupplyChainControlTower/
├── App/
│   └── SupplyChainControlTowerApp.swift    ← Main app entry point
├── Models/
│   └── DataModels.swift                     ← Data models
├── Views/
│   ├── Windows/                             ← 2D window views
│   │   ├── DashboardView.swift
│   │   ├── AlertsView.swift
│   │   └── ControlPanelView.swift
│   ├── Volumes/                             ← 3D volume views
│   │   ├── NetworkVolumeView.swift
│   │   ├── InventoryLandscapeView.swift
│   │   └── FlowRiverView.swift
│   └── ImmersiveViews/                      ← Immersive space
│       └── GlobalCommandCenterView.swift
├── ViewModels/                              ← MVVM ViewModels
│   ├── DashboardViewModel.swift
│   └── NetworkVisualizationViewModel.swift
├── Services/
│   └── NetworkService.swift                 ← API and caching
├── Utilities/
│   ├── GeometryExtensions.swift
│   └── PerformanceMonitor.swift
├── Resources/
│   └── Assets.xcassets
├── Tests/
│   ├── DataModelsTests.swift
│   └── NetworkServiceTests.swift
└── Info.plist
```

## Build Configuration

### Signing & Capabilities

1. **Select your team:**
   - Project Navigator → Select target → Signing & Capabilities
   - Team: Select your Apple Developer team

2. **Enable required capabilities:**
   - None required for basic functionality
   - For hand tracking: Enable "Hand Tracking" entitlement
   - For eye tracking: Enable "Eye Tracking" entitlement (requires explicit permission)

### Build Settings

Recommended settings:

- **Swift Language Version:** Swift 6
- **iOS Deployment Target:** visionOS 2.0
- **Swift Compiler - Code Generation:**
  - Optimization Level (Debug): No Optimization [-Onone]
  - Optimization Level (Release): Optimize for Speed [-O]

### Info.plist Required Keys

Ensure these are in your Info.plist:

```xml
<key>NSCameraUsageDescription</key>
<string>Camera access is required for hand tracking and spatial interactions.</string>

<key>NSLocationWhenInUseUsageDescription</key>
<string>Location access is used to provide regional supply chain views.</string>

<key>NSEyeTrackingUsageDescription</key>
<string>Eye tracking enables natural navigation and focus-based interactions.</string>
```

## Running the App

### On visionOS Simulator

1. **Open Simulator:**
   ```
   Xcode → Open Developer Tool → Simulator
   ```

2. **Select Vision Pro:**
   - From device list, select "Apple Vision Pro"

3. **Run from Xcode:**
   - Ensure visionOS Simulator is selected as destination
   - Press ⌘R to build and run

4. **Navigate the app:**
   - Use trackpad/mouse for cursor
   - Click to select/tap
   - Drag to move windows

### On Vision Pro Device

1. **Connect Vision Pro:**
   - Connect via USB-C to your Mac
   - Trust the computer on your Vision Pro

2. **Select device:**
   - In Xcode, select your Vision Pro from destination picker

3. **Build and Run:**
   - Press ⌘R
   - App will install and launch on device

4. **Interact:**
   - Use natural gestures (gaze + pinch)
   - Hand tracking enabled automatically
   - Voice commands (if implemented)

## Testing

### Run Unit Tests

```bash
# From Xcode
⌘U

# Or from command line
xcodebuild test \
  -scheme SupplyChainControlTower \
  -destination 'platform=visionOS Simulator,name=Apple Vision Pro'
```

### Run UI Tests

```bash
# In Xcode: Product → Test (⌘U)
# Tests will run on simulator
```

### Performance Testing

Use Instruments to profile:

1. **Product → Profile (⌘I)**
2. Select instrument:
   - **Time Profiler** for CPU usage
   - **Allocations** for memory
   - **RealityKit Profiler** for 3D rendering

## Troubleshooting

### Common Build Errors

**Error: Cannot find 'Observable' in scope**
- Solution: Ensure deployment target is visionOS 2.0+
- Check: Swift version is 6.0+

**Error: No such module 'RealityKit'**
- Solution: Add RealityKit framework to target
- Target → General → Frameworks, Libraries, and Embedded Content → + → RealityKit

**Error: Cannot find type 'ModelContainer' in scope**
- Solution: Import SwiftData
- Add: `import SwiftData` at top of file

### Runtime Issues

**App crashes on launch**
- Check console for error messages
- Verify SwiftData model container setup
- Ensure Info.plist is properly configured

**3D entities not visible**
- Check RealityView setup
- Verify entity positions (should be in front of camera)
- Check lighting setup

**Poor performance**
- Reduce entity count
- Enable LOD system
- Check memory usage with Instruments

**Gestures not working**
- Ensure InputTargetComponent is added to entities
- Check gesture recognizers are properly set up
- Verify hand tracking permissions

## Performance Optimization

### Before Deployment

1. **Enable Release build:**
   - Product → Scheme → Edit Scheme
   - Run → Build Configuration → Release

2. **Profile the app:**
   - Use Instruments to identify bottlenecks
   - Target: 90 FPS sustained
   - Memory: < 4GB for 3D scenes

3. **Optimize assets:**
   - Compress textures
   - Use appropriate polygon counts
   - Implement LOD system

4. **Test on device:**
   - Simulator performance differs from device
   - Always test on actual Vision Pro before release

## Distribution

### TestFlight

1. **Archive the app:**
   ```
   Product → Archive
   ```

2. **Upload to App Store Connect:**
   - Organizer → Distribute App → App Store Connect
   - Upload

3. **Add to TestFlight:**
   - App Store Connect → TestFlight
   - Add build to testing
   - Invite testers

### Enterprise Distribution

1. **Archive with enterprise profile**
2. **Export IPA:**
   - Organizer → Distribute App → Enterprise
   - Export

3. **Distribute via MDM:**
   - Upload to enterprise app catalog
   - Deploy to devices

## Continuous Integration

### Xcode Cloud

1. **Enable Xcode Cloud:**
   - Project → select target → Integrate → Xcode Cloud

2. **Configure workflow:**
   - Branch: main
   - Actions: Archive, Test
   - Environment: visionOS 2.0+

3. **Set up automatic testing:**
   - Run tests on every PR
   - Build and archive on main branch

### GitHub Actions (Example)

```yaml
name: Build visionOS App

on: [push, pull_request]

jobs:
  build:
    runs-on: macos-14
    steps:
      - uses: actions/checkout@v3
      - name: Build
        run: xcodebuild build -scheme SupplyChainControlTower
```

## Next Steps

After successful build:

1. **Customize data sources:**
   - Update NetworkService.swift with your API endpoint
   - Replace mock data with real data

2. **Add features:**
   - Implement AI prediction models
   - Add collaboration features
   - Customize visualizations

3. **Deploy:**
   - Test with real data
   - Gather user feedback
   - Iterate and improve

## Support

For build issues:
- Check Xcode console for errors
- Review Apple Developer Documentation
- File issues on GitHub repository

For feature requests:
- See IMPLEMENTATION_PLAN.md for roadmap
- Contribute via pull requests

---

**Ready to build?** Run `./validate.sh` first, then open Xcode and start building! 🚀
