# Xcode Setup Guide for Culture Architecture System

This guide walks you through setting up the Culture Architecture System visionOS project in Xcode for building and testing on Apple Vision Pro.

## Prerequisites

### System Requirements
- **macOS**: 14.0 (Sonoma) or later
- **Xcode**: 15.2 or later
- **visionOS SDK**: 2.0 or later (included with Xcode 15.2+)
- **Apple Vision Pro**: Device or Simulator
- **Apple Developer Account**: Required for device testing

### Hardware Requirements
- **Mac**: Apple Silicon (M1/M2/M3) or Intel Mac with macOS 14+
- **RAM**: Minimum 16GB (32GB recommended for simulator)
- **Storage**: At least 50GB free space for Xcode and simulators
- **Apple Vision Pro**: Optional (can use simulator)

## Initial Setup

### 1. Install Xcode

```bash
# Download from Mac App Store or Apple Developer site
# Or use command line:
xcode-select --install
```

After installation:
```bash
# Verify Xcode installation
xcode-select -p
# Should output: /Applications/Xcode.app/Contents/Developer

# Install visionOS simulator
xcodebuild -downloadPlatform visionOS
```

### 2. Clone the Repository

```bash
git clone <repository-url>
cd visionOS_culture-architecture-system
```

### 3. Create Xcode Project

Since the Swift files are already created, you need to create an Xcode project:

#### Option A: Create New Project (Recommended)

1. Open Xcode
2. **File → New → Project**
3. Select **visionOS → App**
4. Configure project:
   - Product Name: `CultureArchitectureSystem`
   - Team: Select your development team
   - Organization Identifier: `com.yourcompany`
   - Interface: **SwiftUI**
   - Language: **Swift**
   - Include Tests: **Yes**

5. Save in the repository root directory

#### Option B: Import Existing Files

1. After creating the project, delete the default ContentView.swift and App file
2. **File → Add Files to "CultureArchitectureSystem"**
3. Select all folders from `CultureArchitectureSystem/`:
   - App/
   - Models/
   - Views/
   - ViewModels/
   - Services/
   - Networking/
   - Utilities/
   - Tests/
4. Ensure "Copy items if needed" is **unchecked**
5. Ensure "Create groups" is selected
6. Add to target: **CultureArchitectureSystem**

### 4. Configure Project Settings

#### General Settings
1. Select project in navigator
2. Select **CultureArchitectureSystem** target
3. **General** tab:
   - **Deployment Target**: visionOS 2.0
   - **Supports Multiple Windows**: Check
   - **Preferred Default Scene Session Role**: Window Group

#### Signing & Capabilities
1. **Signing & Capabilities** tab:
   - **Team**: Select your development team
   - **Bundle Identifier**: `com.yourcompany.CultureArchitectureSystem`

2. **Add Capabilities**:
   - Click **+ Capability**
   - Add the following:
     - **SwiftData** (automatic)
     - **Scene Understanding** (for spatial mapping)
     - **Hand Tracking** (for gesture recognition)
     - **App Groups** (for data sharing)

#### Build Settings
1. **Build Settings** tab:
   - **Swift Language Version**: Swift 6
   - **Minimum Deployment**: visionOS 2.0

#### Info.plist Configuration

Add the following keys to Info.plist:

```xml
<key>NSCameraUsageDescription</key>
<string>Camera access is required for spatial understanding and environment mapping.</string>

<key>NSWorldSensingUsageDescription</key>
<string>World sensing enables immersive culture visualization experiences.</string>

<key>UIApplicationSupportsMultipleScenes</key>
<true/>

<key>UIApplicationSceneManifest</key>
<dict>
    <key>UISceneConfigurations</key>
    <dict>
        <key>CPTemplateApplicationSceneSessionRoleApplication</key>
        <array>
            <dict>
                <key>UISceneClassName</key>
                <string>CPTemplateApplicationScene</string>
                <key>UISceneConfigurationName</key>
                <string>Default Configuration</string>
            </dict>
        </array>
    </dict>
</dict>
```

## Building the Project

### 1. Resolve Build Issues

#### Fix Stub Implementations

Several files contain stub implementations marked with `// TODO: Implement`. Complete these before full functionality:

**Priority Files**:
- `CultureArchitectureSystem/Services/VisualizationService.swift:712` - 3D entity generation
- `CultureArchitectureSystem/Views/Volumes/TeamCultureVolume.swift:718` - 3D culture tree
- `CultureArchitectureSystem/Views/Immersive/CultureCampusView.swift:720` - Immersive environment

#### Add Assets

1. Create **Assets.xcassets** if not exists
2. Add required assets:
   - App Icon (1024x1024)
   - Color sets for themes
   - Any images referenced in code

### 2. Build for Simulator

```bash
# Command line build
xcodebuild -project CultureArchitectureSystem.xcodeproj \
           -scheme CultureArchitectureSystem \
           -destination 'platform=visionOS Simulator,name=Apple Vision Pro' \
           build

# Or in Xcode:
# 1. Select "Apple Vision Pro" simulator from device menu
# 2. Product → Build (⌘B)
```

### 3. Build for Device

```bash
# Ensure device is connected and trusted
xcodebuild -project CultureArchitectureSystem.xcodeproj \
           -scheme CultureArchitectureSystem \
           -destination 'platform=visionOS,name=<Device Name>' \
           build
```

## Running Tests

### Unit Tests

```bash
# Run all tests
xcodebuild test -project CultureArchitectureSystem.xcodeproj \
                -scheme CultureArchitectureSystem \
                -destination 'platform=visionOS Simulator,name=Apple Vision Pro'

# Or in Xcode:
# Product → Test (⌘U)
```

### Individual Test Suites

In Xcode:
1. **Test Navigator** (⌘6)
2. Expand test suites
3. Click play button next to specific test

Test files included:
- `DataAnonymizerTests.swift` - Privacy validation
- `CultureServiceTests.swift` - Service layer tests
- `AnalyticsServiceTests.swift` - Analytics tests
- `VisualizationServiceTests.swift` - 3D rendering tests
- `OrganizationTests.swift` - Model tests
- `EmployeeTests.swift` - Privacy model tests
- `CulturalValueTests.swift` - Values tests
- `BehaviorEventTests.swift` - Event tracking tests
- `RecognitionTests.swift` - Recognition system tests

## Running the App

### On Simulator

1. Select **Apple Vision Pro** simulator
2. **Product → Run** (⌘R)
3. Wait for simulator to launch
4. App will appear in visionOS environment

**Simulator Controls**:
- **Eye Gaze**: Move mouse
- **Pinch Gesture**: Hold Option + click and drag
- **Hand Tracking**: Enable in simulator toolbar

### On Device

1. Connect Apple Vision Pro via cable
2. Trust computer on device
3. Select device from device menu
4. **Product → Run** (⌘R)
5. Approve installation on device
6. App installs and launches

## Debugging

### Common Issues and Solutions

#### Issue: SwiftData Model Schema Errors
**Solution**: Delete app from simulator/device and reinstall
```bash
xcrun simctl uninstall booted com.yourcompany.CultureArchitectureSystem
```

#### Issue: RealityKit Entity Loading Errors
**Solution**: Check that all Reality Composer Pro files are included in target
1. Select file in navigator
2. File Inspector → Target Membership
3. Ensure CultureArchitectureSystem is checked

#### Issue: Build Errors in Stub Files
**Solution**: Implement TODO sections or comment out incomplete code temporarily

#### Issue: Simulator Performance Issues
**Solution**:
- Close other applications
- Reduce window quality in simulator settings
- Use Mac with M-series chip if possible

### Debugging Tools

#### Xcode Debugger
- Set breakpoints in Swift code
- Use `po` to inspect variables
- View call stack and memory

#### Reality Composer Pro
```bash
# Open Reality Composer Pro for 3D debugging
open -a "Reality Composer Pro"
```

#### Instruments
- Profile performance: **Product → Profile** (⌘I)
- Memory leaks detection
- Time profiling for optimization

## Performance Optimization

### Build Configuration

#### Debug Configuration
- Used during development
- Includes debug symbols
- Slower performance

#### Release Configuration
- Used for App Store submission
- Optimized code
- Better performance

Switch to Release:
**Product → Scheme → Edit Scheme → Run → Build Configuration → Release**

### Optimization Tips

1. **Reduce Entity Count**: Limit 3D entities in scene
2. **LOD (Level of Detail)**: Use lower poly models when far away
3. **Occlusion Culling**: Hide entities not in view
4. **Batch Operations**: Group similar rendering operations
5. **Async Operations**: Use async/await for heavy computations

## App Store Submission

### 1. Archive the App

```bash
xcodebuild archive -project CultureArchitectureSystem.xcodeproj \
                   -scheme CultureArchitectureSystem \
                   -destination 'generic/platform=visionOS' \
                   -archivePath './build/CultureArchitectureSystem.xcarchive'
```

Or in Xcode:
1. Select **Any visionOS Device**
2. **Product → Archive**
3. Wait for archive to complete

### 2. Validate Archive

1. **Window → Organizer**
2. Select archive
3. Click **Validate App**
4. Follow prompts to validate

### 3. Upload to App Store Connect

1. In Organizer, click **Distribute App**
2. Select **App Store Connect**
3. Choose distribution options:
   - Upload symbols: **Yes**
   - Bitcode: **No** (not supported for visionOS)
4. Sign and upload

### 4. App Store Connect Configuration

1. Log in to [App Store Connect](https://appstoreconnect.apple.com)
2. Create new app
3. Fill in metadata:
   - Screenshots (required: 6 screenshots at 3840x2160)
   - Description
   - Keywords
   - Support URL
   - Privacy Policy URL
4. Submit for review

## Continuous Integration

### GitHub Actions Example

Create `.github/workflows/build.yml`:

```yaml
name: Build visionOS App

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    runs-on: macos-14
    steps:
    - uses: actions/checkout@v3

    - name: Select Xcode version
      run: sudo xcode-select -s /Applications/Xcode_15.2.app

    - name: Build
      run: |
        xcodebuild build -project CultureArchitectureSystem.xcodeproj \
                        -scheme CultureArchitectureSystem \
                        -destination 'platform=visionOS Simulator,name=Apple Vision Pro'

    - name: Run Tests
      run: |
        xcodebuild test -project CultureArchitectureSystem.xcodeproj \
                       -scheme CultureArchitectureSystem \
                       -destination 'platform=visionOS Simulator,name=Apple Vision Pro'
```

## Troubleshooting

### Get Help

1. **Apple Documentation**: [visionOS Developer](https://developer.apple.com/visionos/)
2. **WWDC Videos**: Search for visionOS sessions
3. **Apple Developer Forums**: [forums.developer.apple.com](https://forums.developer.apple.com)
4. **Stack Overflow**: Tag: `visionos`

### Collect Diagnostics

```bash
# Generate diagnostics report
xcrun simctl diagnose
```

### Reset Development Environment

```bash
# Reset simulators
xcrun simctl shutdown all
xcrun simctl erase all

# Clean build folder
xcodebuild clean -project CultureArchitectureSystem.xcodeproj

# Clear derived data
rm -rf ~/Library/Developer/Xcode/DerivedData/*
```

## Next Steps

1. ✅ Complete TODO implementations in stub files
2. ✅ Add reality files with Reality Composer Pro
3. ✅ Test on physical Apple Vision Pro device
4. ✅ Implement additional 3D visualizations
5. ✅ Add sample data for demo purposes
6. ✅ Record App Store screenshots
7. ✅ Create App Store preview video
8. ✅ Submit to TestFlight for beta testing
9. ✅ Submit to App Store for review

---

**For questions or issues**, please refer to:
- `ARCHITECTURE.md` - Technical architecture details
- `TECHNICAL_SPEC.md` - Implementation specifications
- `NEXT_STEPS.md` - Development roadmap
- `TEST_RESULTS.md` - Testing documentation

**Last Updated**: 2025-01-20
**Version**: 1.0.0
