# Xcode Project Setup Guide

Complete step-by-step instructions for creating the Xcode project for Reality Annotations and building the app.

---

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Create Xcode Project](#create-xcode-project)
3. [Configure Project Settings](#configure-project-settings)
4. [Add Source Files](#add-source-files)
5. [Add Test Files](#add-test-files)
6. [Configure Frameworks](#configure-frameworks)
7. [Configure Signing & Capabilities](#configure-signing--capabilities)
8. [Build and Run](#build-and-run)
9. [Run Tests](#run-tests)
10. [Troubleshooting](#troubleshooting)

---

## Prerequisites

### Required Software

- **macOS Sonoma 14.0+** (or later)
- **Xcode 15.2+** (or later)
  - Download from Mac App Store or [developer.apple.com](https://developer.apple.com/download/)
- **visionOS SDK** (included with Xcode 15.2+)

### Required Accounts

- **Apple ID** (for development)
- **Apple Developer Account** (for device testing and App Store submission)
  - Individual: $99/year
  - Organization: $99/year
  - Enterprise: $299/year

### Hardware (Optional but Recommended)

- **Apple Vision Pro** (for device testing)
- **Mac with Apple Silicon** (M1/M2/M3) - Recommended for visionOS development
- **16GB+ RAM** - Recommended

### Knowledge Prerequisites

- Basic familiarity with Xcode
- Understanding of iOS/visionOS project structure
- Basic Swift knowledge (helpful for troubleshooting)

---

## Create Xcode Project

### Step 1: Launch Xcode

1. Open **Xcode** from Applications
2. On the welcome screen, select **"Create New Project"**
   - Or: File → New → Project (⇧⌘N)

### Step 2: Choose Template

1. Select **visionOS** tab at the top
2. Choose **App** template
3. Click **Next**

### Step 3: Configure Project

**Project Configuration:**

| Field | Value |
|-------|-------|
| Product Name | `RealityAnnotation` |
| Team | Select your Apple Developer team |
| Organization Identifier | `com.yourcompany` (use your domain) |
| Bundle Identifier | `com.yourcompany.RealityAnnotation` |
| Interface | **SwiftUI** |
| Language | **Swift** |
| Storage | **SwiftData** (check this box) |

**Important:** Check **"SwiftData"** to include SwiftData framework.

### Step 4: Choose Location

1. Select where to save the project
2. **Important:** Save OUTSIDE this git repository initially
3. Click **Create**

### Result

Xcode creates a project with:
- Basic visionOS app structure
- Default ContentView.swift
- App entry point
- SwiftData model container setup

---

## Configure Project Settings

### Step 5: Project Settings

1. Select **RealityAnnotation** project in navigator (top item)
2. Select **RealityAnnotation** target (not the project)
3. Configure the following settings:

#### General Tab

**Identity:**
- **Display Name:** `Reality Annotations` (with space)
- **Bundle Identifier:** `com.yourcompany.RealityAnnotation`
- **Version:** `1.0`
- **Build:** `1`

**Deployment Info:**
- **Minimum Deployments:** visionOS 1.0 or later
- **Supported Destinations:** visionOS
- **Device Families:** Reality Device (Vision Pro)
- **Preferred Window Style:** Automatic

**Frameworks, Libraries, and Embedded Content:**
- (Will add later)

#### Build Settings Tab

1. Search for **"Swift Language Version"**
   - Set to **Swift 5.9** or later

2. Search for **"Enable Strict Concurrency Checking"**
   - Set to **Complete**

3. Search for **"Enable Testing Search Paths"**
   - Set to **Yes**

---

## Add Source Files

### Step 6: Delete Default Files

1. In Project Navigator, delete the following default files:
   - `ContentView.swift` (we have our own)
   - Default model file (if any)
   - Preview content folder (optional to keep)

2. Select **"Move to Trash"** when prompted

### Step 7: Create Group Structure

Create the following group (folder) structure by right-clicking **RealityAnnotation** group:

```
RealityAnnotation/
├── App/
├── Data/
│   ├── Models/
│   ├── Repositories/
│   ├── CloudKit/
├── Domain/
│   ├── Entities/
│   ├── Services/
├── Presentation/
│   ├── Views/
│   └── Components/
└── AR/
```

**How to create groups:**
1. Right-click `RealityAnnotation` folder
2. Select "New Group"
3. Name the group (e.g., "App")
4. Repeat for all groups

### Step 8: Add Source Files

#### Copy Files from Repository

1. Open Finder and navigate to this git repository
2. Locate `RealityAnnotation/` directory
3. Copy all Swift files to corresponding Xcode groups:

**App Files** → `App/` group:
- `RealityAnnotationApp.swift`
- `AppState.swift`
- `ServiceContainer.swift`

**Model Files** → `Data/Models/` group:
- `Annotation.swift`
- `Layer.swift`

**Repository Files** → `Data/Repositories/` group:
- `AnnotationRepository.swift`
- `LayerRepository.swift`

**CloudKit Files** → `Data/CloudKit/` group:
- `Syncable.swift`
- `CloudKitService.swift`
- `SyncCoordinator.swift`
- `Annotation+Syncable.swift`
- `Layer+Syncable.swift`

**Service Files** → `Domain/Services/` group:
- `AnnotationService.swift`
- `LayerService.swift`
- `ServiceProtocols.swift`

**Entity Files** → `Domain/Entities/` group:
- `AnnotationEntity.swift`

**View Files** → `Presentation/Views/` group:
- `ContentView.swift`
- `AnnotationListView.swift`
- `AnnotationDetailView.swift`
- `CreateAnnotationView.swift`
- `SettingsView.swift`
- `OnboardingView.swift`

**Component Files** → `Presentation/Components/` group:
- `ErrorStateView.swift`

**AR Files** → `AR/` group:
- `ARSessionManager.swift`
- `AnchorManager.swift`
- `AnnotationRenderer.swift`

#### Add Files to Xcode

**Method 1: Drag & Drop**
1. Drag Swift files from Finder to corresponding Xcode group
2. In dialog that appears:
   - ✅ Check **"Copy items if needed"**
   - ✅ Check **"Create groups"**
   - ✅ Select **RealityAnnotation** target
3. Click **Finish**

**Method 2: File → Add Files**
1. Right-click group in Xcode
2. Select **"Add Files to RealityAnnotation..."**
3. Navigate to source file
4. Configure options as above
5. Click **Add**

### Step 9: Verify File Addition

1. Select **RealityAnnotation** target
2. Go to **Build Phases** tab
3. Expand **"Compile Sources"**
4. Verify all `.swift` files are listed (should be ~30 files)

**If files are missing:**
1. Find the file in Project Navigator
2. Select it
3. In File Inspector (right sidebar), check **RealityAnnotation** target

---

## Add Test Files

### Step 10: Create Test Targets

The project should have default test targets. If not, create them:

**Unit Test Target:**
1. File → New → Target
2. Choose **Unit Testing Bundle**
3. Name: `RealityAnnotationTests`
4. Click **Finish**

**UI Test Target:**
1. File → New → Target
2. Choose **UI Testing Bundle**
3. Name: `RealityAnnotationUITests`
4. Click **Finish**

### Step 11: Add Test Files

From the repository, copy test files to Xcode:

**Unit Tests** → `RealityAnnotationTests/`:
- All test files from `RealityAnnotationTests/` directory
- Create subdirectories as needed:
  - `ModelTests/`
  - `RepositoryTests/`
  - `ServiceTests/`
  - `IntegrationTests/`
  - `PerformanceTests/`

**UI Tests** → `RealityAnnotationUITests/`:
- `OnboardingUITests.swift`
- `AnnotationCRUDUITests.swift`

**Add to Xcode:**
- Use drag & drop method as before
- Ensure correct test target is selected
- Verify in Build Phases → Compile Sources

---

## Configure Frameworks

### Step 12: Link Frameworks

1. Select **RealityAnnotation** target
2. Go to **General** tab
3. Scroll to **"Frameworks, Libraries, and Embedded Content"**
4. Click **+** button
5. Add the following frameworks:

**Required Frameworks:**
- ✅ **SwiftUI.framework**
- ✅ **SwiftData.framework**
- ✅ **RealityKit.framework**
- ✅ **ARKit.framework**
- ✅ **CloudKit.framework**

**Optional Frameworks (for future features):**
- AVFoundation.framework (for audio annotations)
- SceneKit.framework (for 3D model support)

### Step 13: Configure Framework Search Paths

1. Go to **Build Settings** tab
2. Search for **"Framework Search Paths"**
3. Should be empty or `$(inherited)` - this is correct
4. Xcode automatically finds system frameworks

---

## Configure Signing & Capabilities

### Step 14: Signing

1. Select **RealityAnnotation** target
2. Go to **Signing & Capabilities** tab
3. Configure **Signing:**

   - **Automatically manage signing:** ✅ (recommended for beginners)
   - **Team:** Select your Apple Developer team
   - **Bundle Identifier:** Verify it's correct

**If you see errors:**
- "Failed to register bundle identifier" → Bundle ID may be taken
- Change to unique identifier: `com.yourname.RealityAnnotation`

### Step 15: Add Capabilities

Click **+ Capability** button and add:

**Required Capabilities:**

1. **iCloud**
   - ✅ CloudKit
   - ✅ Use default container
   - Container: `iCloud.com.yourcompany.RealityAnnotation`

2. **Background Modes**
   - ✅ Background fetch
   - ✅ Remote notifications (for CloudKit sync)

**How to add:**
1. Click **+ Capability**
2. Double-click capability name
3. Configure options as listed above

### Step 16: Privacy Permissions

1. Open **Info.plist** (or Info tab in target settings)
2. Add the following privacy keys:

**Required Privacy Keys:**

| Key | Value |
|-----|-------|
| `NSCameraUsageDescription` | `Reality Annotations uses the camera for AR tracking to position your annotations in physical space.` |
| `NSWorldSensingUsageDescription` | `Reality Annotations uses world sensing to anchor annotations to your physical environment.` |

**How to add:**
1. In Info.plist, click **+** to add row
2. Type the key name
3. Enter the value (description shown to user)

---

## Build and Run

### Step 17: Build the Project

1. Select target device:
   - **visionOS Simulator** (for testing without device)
   - **Your Vision Pro** (if connected)

2. Click **Build** button (⌘B) or Product → Build

3. **Fix any build errors:**
   - Missing imports: Check framework linking
   - File not found: Check file target membership
   - Syntax errors: Check Swift version compatibility

### Step 18: Run in Simulator

1. Select **visionOS Simulator** from device dropdown
2. Click **Run** button (⌘R) or Product → Run
3. Simulator will launch (may take 1-2 minutes first time)

**Expected Result:**
- App launches
- Onboarding screen appears (first launch)
- Can navigate through interface

**Limitations in Simulator:**
- AR features won't work (no camera)
- Performance may differ from device
- Some gestures may not work

### Step 19: Run on Device

**Prerequisites:**
- Apple Vision Pro device
- Device connected to Mac (USB-C or wirelessly)
- Device in Developer Mode

**Enable Developer Mode on Vision Pro:**
1. Settings → Privacy & Security → Developer Mode
2. Toggle on
3. Restart device

**Run on Device:**
1. Connect Vision Pro to Mac
2. Trust the device (if prompted)
3. Select **Vision Pro** from device dropdown
4. Click **Run** (⌘R)
5. Xcode installs and launches app

**Expected Result:**
- App installs on Vision Pro
- App launches automatically
- Full AR functionality available
- Can test spatial anchoring

---

## Run Tests

### Step 20: Run Unit Tests

1. Select **Product → Test** (⌘U)
2. Or: Click test diamond next to test class/function
3. Or: Open **Test Navigator** (⌘6) and click play button

**Expected Results:**
- All unit tests should pass
- ~122 unit tests
- Execution time: < 30 seconds

**If tests fail:**
- Check error messages in test report
- Verify all source files are added
- Check target membership
- Review test log for details

### Step 21: Run Integration Tests

1. Open **Test Navigator** (⌘6)
2. Find **IntegrationTests** group
3. Click play button for group
4. Wait for tests to complete (~1 minute)

**Expected Results:**
- 15 integration tests pass
- Tests verify end-to-end flows
- Tests verify persistence

### Step 22: Run UI Tests

**Note:** UI tests require simulator or device

1. Open **Test Navigator**
2. Find **RealityAnnotationUITests**
3. Click play button
4. Watch UI tests execute (2-5 minutes)

**Expected Results:**
- 25 UI tests pass
- Tests automate user interactions
- Screenshots captured on failure

### Step 23: Run Performance Tests

1. Open **Test Navigator**
2. Find **PerformanceTests**
3. Click play button
4. Wait for benchmark tests (~2 minutes)

**Expected Results:**
- Performance baselines established
- Future runs compare against baseline
- Alerts if performance regresses

### Step 24: Code Coverage

**Enable Code Coverage:**
1. Product → Scheme → Edit Scheme (⌘<)
2. Select **Test** action
3. Go to **Options** tab
4. ✅ Check **"Gather coverage for some targets"**
5. Select **RealityAnnotation** target
6. Click **Close**

**Run Tests with Coverage:**
1. Run all tests (⌘U)
2. Open **Report Navigator** (⌘9)
3. Select latest test run
4. Click **Coverage** tab
5. View coverage percentages

**Target Coverage:**
- Overall: 75%+
- Models: 90%+
- Services: 80%+
- Repositories: 80%+
- ViewModels: 70%+

---

## Troubleshooting

### Common Build Errors

#### "Cannot find type/module"

**Problem:** Missing framework or import

**Solution:**
1. Check **Build Phases → Link Binary with Libraries**
2. Add missing framework
3. Verify `import` statements in code

#### "No such module 'SwiftData'"

**Problem:** SwiftData not available

**Solution:**
- Update to Xcode 15.2+
- Check deployment target is visionOS 1.0+
- Clean build folder (⇧⌘K)

#### "Sandbox: rsync deny(1) file-write-create"

**Problem:** Code signing issue

**Solution:**
1. Product → Clean Build Folder (⇧⌘K)
2. Delete derived data: ~/Library/Developer/Xcode/DerivedData
3. Restart Xcode
4. Rebuild

#### "Could not find target 'RealityAnnotation'"

**Problem:** Target not configured correctly

**Solution:**
1. Check file target membership
2. Verify files in **Build Phases → Compile Sources**
3. Re-add files if needed

### Common Runtime Errors

#### App crashes on launch

**Problem:** Missing model container or initialization error

**Solution:**
1. Check `RealityAnnotationApp.swift` has `.modelContainer`
2. Verify models are `@Model` annotated
3. Check console for error messages

#### AR features not working

**Problem:** Missing capabilities or permissions

**Solution:**
1. Verify **Camera** and **World Sensing** privacy keys in Info.plist
2. Check user granted permissions in Settings
3. Restart app after granting permissions

#### iCloud sync not working

**Problem:** CloudKit not configured or account issue

**Solution:**
1. Verify **iCloud** capability enabled
2. Check container identifier is correct
3. Sign in to iCloud on device
4. Check CloudKit Dashboard for container setup

### Common Test Failures

#### "Failed to launch app"

**Problem:** Simulator or device not ready

**Solution:**
1. Wait for simulator to fully boot
2. Reset simulator: Device → Erase All Content and Settings
3. Disconnect and reconnect device
4. Restart Xcode

#### "UI tests time out"

**Problem:** UI elements not found or slow performance

**Solution:**
1. Increase timeout values in test code
2. Add wait conditions: `waitForExistence(timeout:)`
3. Check UI element accessibility identifiers
4. Run on device instead of simulator

#### Tests pass individually but fail together

**Problem:** Test state pollution

**Solution:**
1. Check `setUp()` and `tearDown()` properly reset state
2. Use unique test data for each test
3. Run tests in random order to catch dependencies

### Performance Issues

#### Slow builds

**Problem:** Large project or incremental build issues

**Solution:**
1. Clean build folder (⇧⌘K)
2. Enable **Build System** → New Build System
3. Increase **Build Active Architecture Only** to YES for Debug
4. Consider modularization for very large projects

#### Slow app performance

**Problem:** Debug build or memory issues

**Solution:**
1. Test with **Release** build configuration
2. Profile with **Instruments** (⌘I)
3. Check for memory leaks
4. Optimize query performance

### Getting Help

**Resources:**
- **Apple Documentation:** [developer.apple.com/documentation](https://developer.apple.com/documentation)
- **visionOS Developer:** [developer.apple.com/visionos](https://developer.apple.com/visionos)
- **SwiftUI Tutorials:** [developer.apple.com/tutorials/swiftui](https://developer.apple.com/tutorials/swiftui)
- **Stack Overflow:** Search for error messages
- **Apple Developer Forums:** [developer.apple.com/forums](https://developer.apple.com/forums)

**Contact:**
- **Project Support:** See GitHub Issues
- **Email:** support@realityannotations.com

---

## Next Steps

Once the project is set up and running:

1. ✅ **Verify All Features Work**
   - Create annotations
   - Test layers
   - Test iCloud sync
   - Test AR anchoring

2. ✅ **Run Full Test Suite**
   - All unit tests pass
   - Integration tests pass
   - UI tests pass
   - Performance benchmarks established

3. ✅ **Profile Performance**
   - Use Instruments to profile
   - Check memory usage
   - Verify frame rate (60+ FPS)
   - Optimize bottlenecks

4. ✅ **Test on Device**
   - Install on Vision Pro
   - Test all AR features
   - Test in different environments
   - Verify spatial anchoring accuracy

5. ✅ **Prepare for Beta**
   - See `docs/TestFlight_Guide.md`
   - Archive and upload build
   - Configure TestFlight
   - Invite beta testers

6. ✅ **App Store Submission**
   - Prepare metadata (see `docs/app-store/App_Store_Metadata.md`)
   - Create screenshots
   - Record app preview video
   - Submit for review

---

## Checklist

Use this checklist to track setup progress:

### Project Creation
- [ ] Xcode installed and updated
- [ ] Project created with correct settings
- [ ] Bundle identifier configured
- [ ] SwiftData enabled

### File Organization
- [ ] Group structure created
- [ ] All source files added (30+ files)
- [ ] All test files added
- [ ] Files have correct target membership

### Configuration
- [ ] Frameworks linked (SwiftUI, SwiftData, RealityKit, ARKit, CloudKit)
- [ ] Signing configured
- [ ] Capabilities added (iCloud, Background Modes)
- [ ] Privacy keys added (Camera, World Sensing)

### Building
- [ ] Project builds successfully
- [ ] No compilation errors
- [ ] No warnings (or acceptable warnings)

### Testing
- [ ] Unit tests run and pass (122 tests)
- [ ] Integration tests pass (15 tests)
- [ ] UI tests pass (25 tests)
- [ ] Performance tests run (10+ tests)
- [ ] Code coverage ≥ 75%

### Device Testing
- [ ] App runs in simulator
- [ ] App installs on Vision Pro
- [ ] AR features work on device
- [ ] iCloud sync works
- [ ] Performance is acceptable (60+ FPS)

### Ready for Distribution
- [ ] Archive builds successfully
- [ ] App validated with no errors
- [ ] TestFlight ready
- [ ] App Store metadata prepared

---

**Setup Guide Version:** 1.0
**Last Updated:** 2024-11-24
**Compatible with:** Xcode 15.2+, visionOS 1.0+

Good luck building Reality Annotations! 🚀
