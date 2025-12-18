# Build Instructions for Corporate University Platform

## Overview
This document provides instructions for opening, building, and running the Corporate University Platform visionOS application in Xcode.

## Prerequisites

### Hardware Requirements
- Mac with Apple Silicon (M2 or later recommended)
- Minimum 16 GB RAM (32 GB recommended)
- Vision Pro device (for on-device testing) or visionOS Simulator

### Software Requirements
- **macOS**: Sonoma 14.0 or later
- **Xcode**: 16.0 or later
- **visionOS SDK**: 2.0 or later (included with Xcode 16+)
- **Reality Composer Pro**: 2.0 or later (included with Xcode 16+)

### Apple Developer Requirements
- Active Apple Developer account (paid)
- visionOS development entitlements
- Proper provisioning profiles for visionOS

## Project Setup

### Step 1: Create Xcode Project

Since this project was generated programmatically, you need to create the Xcode project file:

1. Open **Xcode 16+**
2. Select **File > New > Project**
3. Choose **visionOS** platform
4. Select **App** template
5. Click **Next**

Configure the project:
- **Product Name**: `CorporateUniversity`
- **Team**: Select your Apple Developer team
- **Organization Identifier**: `com.yourcompany` (or your identifier)
- **Interface**: SwiftUI
- **Language**: Swift
- **Storage**: SwiftData
- Click **Next** and save in: `/path/to/visionOS_corporate-university-platform/`

### Step 2: Replace Generated Files

1. **Delete** the default generated files:
   - `ContentView.swift` (if using the one from `CorporateUniversity/App/`)
   - Any other default generated files

2. **Add** the source files:
   - In Xcode, right-click on the project navigator
   - Select **Add Files to "CorporateUniversity"...**
   - Navigate to the `CorporateUniversity/` folder
   - Select all folders (`App`, `Models`, `Views`, etc.)
   - Ensure **"Create groups"** is selected
   - Click **Add**

### Step 3: Configure Project Settings

#### General Tab
- **Deployment Info**:
  - Minimum Deployments: `visionOS 2.0`
  - Supported Destinations: `Vision Pro`

#### Signing & Capabilities
- **Automatically manage signing**: Enabled
- **Team**: Select your team
- Add capabilities (click **+ Capability**):
  - `Group Activities` (for SharePlay)
  - `iCloud` (for CloudKit sync)
  - `Hand Tracking` (for hand gestures)

#### Build Settings
- Search for "Swift Language Version":
  - Set to **Swift 6**
- Search for "Strict Concurrency Checking":
  - Set to **Complete**

#### Info.plist
Add the following keys (Right-click Info.plist > Open As > Source Code):

```xml
<key>NSHandTrackingUsageDescription</key>
<string>Hand tracking is used for interactive spatial learning experiences.</string>

<key>NSUserTrackingUsageDescription</key>
<string>We use analytics to improve your learning experience.</string>

<key>UIApplicationSupportsIndirectInputEvents</key>
<true/>
```

### Step 4: Add Assets

1. **App Icon**:
   - Open `Assets.xcassets`
   - Add app icon (multiple sizes required)

2. **3D Models** (if available):
   - Drag `.usdz` or `.reality` files into `Resources/3DModels/`

3. **Audio Files** (if available):
   - Add `.mp3` or `.wav` files to `Resources/`

### Step 5: Configure Reality Composer Pro

1. Open Reality Composer Pro
2. Create new project: **File > New**
3. Save as `LearningEnvironments.rkproject` in `Resources/`
4. Design your 3D scenes:
   - Virtual Classroom
   - Manufacturing Floor
   - Boardroom
   - Innovation Lab

5. Export scenes as `.reality` files
6. Add to Xcode project

## Building the Project

### Option 1: Build for Simulator

1. Select **Vision Pro (Designed for visionOS)** from the device menu
2. Press **⌘ + B** (or Product > Build)
3. Wait for build to complete
4. Press **⌘ + R** (or Product > Run)

**Note**: Simulator has limitations:
- No hand tracking
- No eye tracking
- Limited performance compared to device

### Option 2: Build for Device

1. Connect Vision Pro to Mac (USB-C cable or wirelessly)
2. Trust the computer on Vision Pro (if first time)
3. Select **Vision Pro** from the device menu
4. Press **⌘ + R** (or Product > Run)
5. Enter password if prompted
6. App will install and launch on device

## Running Tests

### Unit Tests
```bash
# From command line
xcodebuild test -scheme CorporateUniversity -destination 'platform=visionOS Simulator,name=Apple Vision Pro'

# Or in Xcode
Product > Test (⌘ + U)
```

### UI Tests
```bash
# Run UI tests
xcodebuild test -scheme CorporateUniversity -testPlan UITests
```

## Known Build Issues & Solutions

### Issue 1: SwiftData Model Container Error
**Error**: "Could not create ModelContainer"

**Solution**:
- Ensure all model classes are marked with `@Model`
- Check that model relationships use `@Relationship`
- Verify schema is properly initialized in `AppModel.swift`

### Issue 2: Reality Kit Assets Not Found
**Error**: "Failed to load entity named..."

**Solution**:
- Verify `.reality` files are in Resources
- Check that files are included in target membership
- Ensure file names match exactly (case-sensitive)

### Issue 3: Hand Tracking Not Working
**Error**: "Hand tracking failed to start"

**Solution**:
- Add `NSHandTrackingUsageDescription` to Info.plist
- Enable "Hand Tracking" capability in Signing & Capabilities
- Check device permissions in Settings

### Issue 4: Build Fails with Swift 6 Errors
**Error**: "Concurrency-safety errors"

**Solution**:
- Ensure all shared state is `@Observable` or actor-isolated
- Use `@MainActor` for UI updates
- Check that async/await is used correctly

## Project Structure

```
CorporateUniversity/
├── App/
│   ├── CorporateUniversityApp.swift  # Main app entry point
│   └── AppModel.swift                # Central app state
├── Models/
│   └── DataModels.swift              # SwiftData models
├── Views/
│   ├── Windows/                      # 2D window views
│   ├── Volumes/                      # Volumetric 3D views
│   └── ImmersiveViews/               # Full immersion views
├── ViewModels/
│   └── [View models here]
├── Services/
│   └── [Service layer here]
├── Utilities/
│   └── [Helper functions here]
├── Resources/
│   ├── Assets.xcassets               # Images, icons
│   └── 3DModels/                     # USDZ, Reality files
└── Tests/
    └── [Test files here]
```

## Running Tests

### Unit Tests

The project includes comprehensive unit tests for data models, services, and network layer.

#### Run All Tests

In Xcode:
```
cmd + U
```

Command Line:
```bash
# Navigate to project directory
cd /path/to/visionOS_corporate-university-platform

# Run all tests
swift test

# Run with code coverage
swift test --enable-code-coverage

# Run specific test file
swift test --filter DataModelsTests
swift test --filter LearningServiceTests
swift test --filter NetworkClientTests
```

#### Test Files

1. **DataModelsTests.swift** (25+ tests)
   - Tests all SwiftData models
   - Validates relationships and computed properties
   - Tests all enum cases
   - Location: `CorporateUniversity/Tests/DataModelsTests.swift`

2. **LearningServiceTests.swift** (10+ tests)
   - Tests course fetching and caching
   - Validates enrollment process
   - Tests progress tracking
   - Location: `CorporateUniversity/Tests/LearningServiceTests.swift`

3. **NetworkClientTests.swift** (10+ tests)
   - Tests API endpoint construction
   - Validates authentication handling
   - Tests response parsing and error handling
   - Location: `CorporateUniversity/Tests/NetworkClientTests.swift`

#### Expected Test Results

```
✓ All 35+ tests should pass
✓ 117+ assertions should succeed
✓ No memory leaks detected
✓ All async tests complete successfully
```

### UI Tests

UI tests will validate end-to-end user flows. To create and run UI tests:

1. Add UI Testing target:
   ```
   File > New > Target > visionOS > UI Testing Bundle
   ```

2. Run UI tests:
   ```
   cmd + U (with UI test target selected)
   ```

See `TESTING.md` for comprehensive testing strategy and UI test examples.

### Code Coverage

Generate code coverage report:

```bash
# Run tests with coverage
swift test --enable-code-coverage

# Generate LCOV report
xcrun llvm-cov export \
  .build/debug/PackageTests.xctest/Contents/MacOS/PackageTests \
  -instr-profile .build/debug/codecov/default.profdata \
  -format=lcov > coverage.lcov

# View coverage in Xcode
# Editor > Show Code Coverage (cmd + 9)
```

Target code coverage: **80%+ overall**, **100% for critical paths**

### Performance Testing

Test app performance with Xcode Instruments:

```bash
# Profile CPU usage
instruments -t "Time Profiler" -D /tmp/profile.trace YourApp.app

# Check memory usage
instruments -t "Allocations" -D /tmp/allocations.trace YourApp.app

# Check for memory leaks
leaks --atExit -- YourApp
```

Performance targets:
- **Frame Rate**: 90 FPS (60 FPS minimum)
- **App Launch**: < 2 seconds
- **Memory Usage**: < 500 MB typical
- **Network Response**: < 500ms

### Accessibility Testing

Test VoiceOver and accessibility features:

1. Enable VoiceOver: Settings → Accessibility → VoiceOver
2. Navigate entire app using VoiceOver only
3. Test with all Dynamic Type sizes
4. Verify color contrast ratios (4.5:1 minimum)
5. Run Xcode Accessibility Inspector

See `TESTING.md` for complete accessibility testing checklist.

### Test Documentation

For comprehensive testing information, see:
- **TESTING.md** - Complete testing strategy and guidelines
- **TEST_RESULTS.md** - Latest test execution results
- **Tests/** directory - All unit test implementations

## Next Steps

### Current Implementation Status

✅ **Completed:**
- Core data models (SwiftData)
- App structure (WindowGroups, ImmersiveSpace)
- Main views (Dashboard, Course Browser)
- Service layer architecture
- Network client with authentication
- Comprehensive unit tests (35+ tests)
- Landing page (HTML/CSS/JS)
- Complete documentation

⚠️ **Partially Complete:**
- Some views are placeholders (CourseDetail, Lesson, Analytics, Settings)
- Mock data in services (backend integration pending)
- Basic 3D views (need Reality Composer Pro assets)

📝 **Planned:**
- Advanced hand tracking gestures
- Eye tracking integration
- SharePlay collaboration
- Spatial audio implementation
- AI tutor integration
- Reality Composer Pro environments

### Recommended Next Steps

1. **Build and Test** - Priority: HIGH
   - Build project in Xcode
   - Run all unit tests (should pass)
   - Test on visionOS Simulator
   - Deploy to Vision Pro device

2. **Complete Stub Views** - Priority: HIGH
   - Implement CourseDetailView
   - Implement LessonView with content display
   - Implement AnalyticsView with charts
   - Implement SettingsView with preferences

3. **Add Reality Composer Pro Content** - Priority: MEDIUM
   - Create 3D skill tree models
   - Design immersive learning environments
   - Add interactive 3D objects
   - Implement spatial animations

4. **Backend Integration** - Priority: MEDIUM
   - Replace mock data with real API calls
   - Implement authentication flow
   - Set up data synchronization
   - Add offline support

5. **Advanced Features** - Priority: LOW
   - Hand tracking gestures
   - Eye tracking for focus
   - SharePlay for collaboration
   - Spatial audio positioning
   - AI-powered tutoring

6. **Polish & Release** - Priority: LOW
   - Performance optimization
   - Accessibility audit
   - Localization (i18n)
   - App Store submission

## Additional Resources

- [visionOS Documentation](https://developer.apple.com/visionos/)
- [SwiftUI for visionOS](https://developer.apple.com/documentation/swiftui/bringing-your-app-to-visionos)
- [RealityKit Documentation](https://developer.apple.com/documentation/realitykit/)
- [Reality Composer Pro](https://developer.apple.com/augmented-reality/tools/)

## Support

For issues or questions:
- Review the ARCHITECTURE.md for system design
- Check TECHNICAL_SPEC.md for implementation details
- Refer to DESIGN.md for UI/UX guidelines
- See IMPLEMENTATION_PLAN.md for development roadmap

## Version

- **Project Version**: 1.0.0
- **visionOS Target**: 2.0+
- **Swift Version**: 6.0
- **Last Updated**: 2025-01-20
