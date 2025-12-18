# TODO: visionOS Environment Setup & Deployment Guide

A comprehensive checklist for setting up, developing, testing, and deploying the Executive Briefing visionOS app on Apple Vision Pro.

**Last Updated**: November 19, 2025
**Project**: Executive Briefing: AR/VR in 2025
**Platform**: visionOS 2.0+ for Apple Vision Pro

---

## 📋 Table of Contents

1. [Prerequisites Setup](#1-prerequisites-setup)
2. [Development Environment](#2-development-environment)
3. [Xcode Project Configuration](#3-xcode-project-configuration)
4. [visionOS Simulator Setup](#4-visionos-simulator-setup)
5. [Build and Run](#5-build-and-run)
6. [Testing on Simulator](#6-testing-on-simulator)
7. [Testing on Device](#7-testing-on-device-apple-vision-pro)
8. [Debugging and Profiling](#8-debugging-and-profiling)
9. [TestFlight Distribution](#9-testflight-distribution)
10. [App Store Submission](#10-app-store-submission)
11. [Troubleshooting](#11-troubleshooting)

---

## 1. Prerequisites Setup

### 1.1 Hardware Requirements

- [ ] Mac with Apple Silicon (M1/M2/M3/M4) **OR** Intel Mac with macOS 14.0+
- [ ] Minimum 16GB RAM (32GB recommended for smooth development)
- [ ] At least 50GB free disk space
- [ ] Apple Vision Pro device (optional, for device testing)

### 1.2 Software Requirements

- [ ] **macOS 14.0 (Sonoma)** or later
  - Check: `sw_vers` in Terminal
  - Update: System Settings → General → Software Update

- [ ] **Xcode 16.0 or later** with visionOS SDK
  - Download from: Mac App Store or [developer.apple.com](https://developer.apple.com/download/)
  - Check version: `xcodebuild -version`
  - Expected output: `Xcode 16.0` or higher

- [ ] **Command Line Tools** installed
  - Check: `xcode-select -p`
  - Install if needed: `xcode-select --install`

### 1.3 Apple Developer Account

- [ ] Active Apple Developer Account (required for device testing)
  - Sign up at: [developer.apple.com](https://developer.apple.com/programs/)
  - Cost: $99/year for individual or organization

- [ ] Sign in to Xcode with Apple ID
  - Xcode → Settings → Accounts → Add (+) → Apple ID

- [ ] Download provisioning profiles
  - Automatic in Xcode or manually at [developer.apple.com/account](https://developer.apple.com/account/)

### 1.4 Git Setup

- [ ] Clone the repository
  ```bash
  git clone https://github.com/akaash-nigam/visionOS_executive-briefing.git
  cd visionOS_executive-briefing
  ```

- [ ] Checkout the development branch
  ```bash
  git checkout claude/implement-app-with-tests-01X11Ye4mFWK6usJA7t4iEK1
  ```

- [ ] Verify all files are present
  ```bash
  ls -la
  # Should see: ExecutiveBriefing/, ExecutiveBriefingTests/, *.md files
  ```

---

## 2. Development Environment

### 2.1 Install visionOS Support

- [ ] Open **Xcode 16+**
- [ ] Go to **Xcode → Settings** (⌘,)
- [ ] Click **Platforms** tab
- [ ] Find **visionOS** in the list
- [ ] Click **GET** to download visionOS SDK and Simulator (~8GB)
- [ ] Wait for download and installation to complete
- [ ] Verify installation: Should see "visionOS" in platform dropdown

### 2.2 Install visionOS Simulator

The simulator is included with the visionOS platform installation above.

- [ ] Verify simulator is available
  - Xcode → Window → Devices and Simulators (⇧⌘2)
  - Click **Simulators** tab
  - Look for **Apple Vision Pro** in the list

- [ ] If not present, add simulator:
  - Click **+** (bottom left)
  - Select **Device Type**: Apple Vision Pro
  - Select **OS Version**: visionOS 2.0 or later
  - Click **Create**

### 2.3 Configure Xcode Preferences

- [ ] **Editor Settings**
  - Xcode → Settings → Text Editing
  - ✅ Enable: Line numbers
  - ✅ Enable: Code folding ribbon
  - ✅ Enable: Page guide at column: 100

- [ ] **Source Control**
  - Xcode → Settings → Source Control
  - ✅ Enable: Show source control changes
  - ✅ Enable: Include upstream changes

- [ ] **Behaviors** (Optional)
  - Xcode → Settings → Behaviors
  - Configure build success/failure actions

---

## 3. Xcode Project Configuration

### 3.1 Create Xcode Project

**Option A: Follow XCODE_SETUP.md (Recommended)**
- [ ] Open `XCODE_SETUP.md` in the repository
- [ ] Follow the detailed step-by-step guide
- [ ] Complete all 12 steps

**Option B: Quick Setup**

- [ ] **Step 1**: Create new visionOS project
  - Xcode → File → New → Project (⌘⇧N)
  - Choose: visionOS → App
  - Product Name: `ExecutiveBriefing`
  - Interface: SwiftUI
  - Language: Swift
  - ✅ Include Tests
  - Save in repository root directory

- [ ] **Step 2**: Remove default files
  - Delete: `ContentView.swift` (Xcode's default)
  - Delete: `ExecutiveBriefingApp.swift` (Xcode's default)
  - Delete: `ImmersiveView.swift` (if present)

- [ ] **Step 3**: Add source files
  ```
  Add folders to project (ensure "Copy items if needed" is UNCHECKED):
  - ExecutiveBriefing/App/
  - ExecutiveBriefing/Models/
  - ExecutiveBriefing/Services/
  - ExecutiveBriefing/Views/
  - ExecutiveBriefing/Utilities/
  - ExecutiveBriefing/Resources/
  ```

- [ ] **Step 4**: Add test files
  ```
  - ExecutiveBriefingTests/ModelTests/
  - ExecutiveBriefingTests/ServiceTests/
  - ExecutiveBriefingTests/UtilityTests/
  ```

- [ ] **Step 5**: Add content file (CRITICAL!)
  - Add `Executive-Briefing-AR-VR-2025.md` to project
  - Ensure it's in **Copy Bundle Resources** build phase
  - This file is required for auto-seeding the database

### 3.2 Configure Build Settings

- [ ] Select **ExecutiveBriefing** target
- [ ] Go to **Build Settings** tab
- [ ] Set the following:

  ```
  Swift Language Version: Swift 6
  Swift Strict Concurrency Checking: Complete
  iOS Deployment Target: (leave empty for visionOS)
  ```

- [ ] Search for "Info.plist" and set:
  ```
  INFOPLIST_FILE = ExecutiveBriefing/Resources/Info.plist
  ```

- [ ] Search for "Code Signing Entitlements" and set:
  ```
  CODE_SIGN_ENTITLEMENTS = ExecutiveBriefing/Resources/ExecutiveBriefing.entitlements
  ```

### 3.3 Configure Signing & Capabilities

- [ ] Select **ExecutiveBriefing** target
- [ ] Go to **Signing & Capabilities** tab
- [ ] **Team**: Select your development team
- [ ] **Bundle Identifier**: Use default or customize (e.g., `com.yourcompany.ExecutiveBriefing`)
- [ ] Verify capabilities are present:
  - ✅ Spatial Tracking
  - ✅ Hand Tracking (optional)
  - ✅ Data Protection

### 3.4 Verify File Targets

- [ ] Select `Executive-Briefing-AR-VR-2025.md` in Project Navigator
- [ ] Check **File Inspector** (right panel)
- [ ] Ensure **Target Membership**: ✅ ExecutiveBriefing
- [ ] Verify it appears in **Build Phases → Copy Bundle Resources**

---

## 4. visionOS Simulator Setup

### 4.1 Launch Simulator

- [ ] Xcode → Window → Devices and Simulators (⇧⌘2)
- [ ] Click **Simulators** tab
- [ ] Select **Apple Vision Pro** simulator
- [ ] Click **▶** (Run) or right-click → **Boot**
- [ ] Wait for simulator to fully boot (~30 seconds)

### 4.2 Configure Simulator Settings

- [ ] Once simulator is running, go to Simulator menu bar
- [ ] **Simulator → Settings** (⌘,)
  - Set display quality (affects performance)
  - Configure keyboard shortcuts
  - Enable/disable pointer capture

- [ ] **Optional**: Configure simulated environment
  - Simulator → Environment
  - Choose: Living Room, Office, etc.

### 4.3 Simulator Controls

Learn the basic controls:

- [ ] **Look Around**: Move mouse (hold Option for faster)
- [ ] **Tap/Select**: Click mouse
- [ ] **Pinch**: Option + Click + Drag
- [ ] **Two-Hand Gestures**: Option + Shift + Click
- [ ] **Home Button**: Simulator → I/O → Home (⇧⌘H)
- [ ] **Reset Content**: Simulator → Device → Erase All Content and Settings

### 4.4 Simulator Tips

- [ ] **Performance**: Close other apps for better simulator performance
- [ ] **Screenshots**: Simulator → File → Save Screen (⌘S)
- [ ] **Video Recording**: Simulator → File → Record Screen
- [ ] **Accessibility**: Simulator → Settings → Accessibility
  - Test VoiceOver
  - Test Dynamic Type
  - Test Reduced Motion

---

## 5. Build and Run

### 5.1 First Build

- [ ] Open `ExecutiveBriefing.xcodeproj` in Xcode
- [ ] Select scheme: **ExecutiveBriefing**
- [ ] Select destination: **Apple Vision Pro** (Simulator)
- [ ] Press **⌘R** or click **▶** (Run) button
- [ ] Wait for build to complete

### 5.2 Build Success Checklist

- [ ] Build completes without errors
- [ ] No compiler warnings (target: 0 warnings)
- [ ] Simulator launches
- [ ] App icon appears in simulator
- [ ] App launches and shows Welcome screen
- [ ] Sidebar shows 8+ sections
- [ ] Can navigate to a section
- [ ] Content displays correctly

### 5.3 Common Build Errors

If build fails, check:

- [ ] All source files are added to target
- [ ] `Executive-Briefing-AR-VR-2025.md` is in Copy Bundle Resources
- [ ] Info.plist path is correct
- [ ] Entitlements file path is correct
- [ ] Swift version is set to 6.0
- [ ] All import statements are correct

### 5.4 Build Clean (If Needed)

- [ ] Product → Clean Build Folder (⇧⌘K)
- [ ] Delete derived data:
  ```bash
  rm -rf ~/Library/Developer/Xcode/DerivedData/ExecutiveBriefing-*
  ```
- [ ] Quit and restart Xcode
- [ ] Build again (⌘R)

---

## 6. Testing on Simulator

### 6.1 Run Unit Tests

- [ ] Press **⌘U** to run all tests
- [ ] Or: Product → Test (⌘U)
- [ ] Wait for tests to complete
- [ ] **Expected Result**: ✅ All 50+ tests pass in < 5 seconds
- [ ] Check test results: View → Navigators → Test (⌘6)

### 6.2 Test Individual Components

- [ ] **Model Tests**: Click test diamond next to test class/method
- [ ] **Service Tests**: Run BriefingContentServiceTests
- [ ] **Utility Tests**: Run MarkdownParserTests
- [ ] Verify 100% pass rate

### 6.3 UI Testing (Manual)

Test all main features:

- [ ] **App Launch**
  - App opens without crash
  - Welcome screen appears
  - Database auto-seeds on first launch

- [ ] **Navigation**
  - Click sections in sidebar
  - Content displays correctly
  - Can navigate between sections
  - Back/forward navigation works

- [ ] **Content Rendering**
  - Headings display correctly
  - Paragraphs render properly
  - Metrics show in styled boxes
  - Lists display with bullets/numbers
  - Callouts show with info icon

- [ ] **3D Visualizations**
  - Click "View in 3D" button
  - New volume window opens
  - 3D chart displays
  - Can rotate/interact with chart

- [ ] **Search** (if implemented)
  - Enter search query
  - Results appear
  - Can navigate to results

- [ ] **Progress Tracking**
  - Visit multiple sections
  - Check progress updates
  - Time tracking works

### 6.4 Accessibility Testing

- [ ] Enable VoiceOver: Simulator → Accessibility Inspector
- [ ] Test navigation with VoiceOver
- [ ] Verify all elements have labels
- [ ] Test Dynamic Type:
  - Settings → Accessibility → Display & Text Size
  - Increase text size
  - Verify content adapts

- [ ] Test Reduced Motion:
  - Settings → Accessibility → Motion
  - Enable Reduce Motion
  - Verify animations are simplified

### 6.5 Performance Testing

- [ ] Run app in Instruments
  - Xcode → Product → Profile (⌘I)
  - Choose **Time Profiler** template
  - Record while using app
  - Check for CPU spikes
  - Verify smooth 90 FPS

- [ ] Check memory usage
  - Debug → Memory Report
  - Verify < 500 MB usage
  - Check for memory leaks

---

## 7. Testing on Device (Apple Vision Pro)

### 7.1 Prerequisites

- [ ] Apple Vision Pro device
- [ ] USB-C cable (for initial pairing)
- [ ] Device updated to visionOS 2.0+
- [ ] Development certificate installed

### 7.2 Pair Device

- [ ] Connect Vision Pro to Mac via USB-C
- [ ] Put on Vision Pro
- [ ] Navigate to Settings → Privacy & Security → Developer Mode
- [ ] Enable **Developer Mode**
- [ ] Restart Vision Pro when prompted

- [ ] In Xcode: Window → Devices and Simulators (⇧⌘2)
- [ ] Click **Devices** tab
- [ ] Vision Pro should appear in list
- [ ] Click **Trust** on both Mac and Vision Pro
- [ ] Enter passcode on Vision Pro if prompted

### 7.3 Configure for Device

- [ ] Select **ExecutiveBriefing** scheme
- [ ] Change destination to **[Your Name]'s Apple Vision Pro**
- [ ] Verify signing is configured:
  - Target → Signing & Capabilities
  - Team should be selected
  - Provisioning profile should be automatic

### 7.4 Deploy to Device

- [ ] Press **⌘R** to build and run on device
- [ ] Wait for build and deployment
- [ ] **First time**: May ask for permission on Vision Pro
- [ ] App installs and launches on Vision Pro

### 7.5 Device Testing Checklist

- [ ] App launches successfully
- [ ] Performance is smooth (90 FPS target)
- [ ] Hand tracking works (if implemented)
- [ ] Eye tracking works for UI hover
- [ ] Spatial audio works correctly
- [ ] All gestures work (tap, pinch, rotate)
- [ ] 3D visualizations render correctly
- [ ] No overheating or thermal issues
- [ ] Battery drain is acceptable

### 7.6 Wireless Debugging (Optional)

- [ ] Ensure Mac and Vision Pro on same Wi-Fi
- [ ] Xcode → Window → Devices and Simulators
- [ ] Select Vision Pro
- [ ] ✅ Enable: "Connect via network"
- [ ] Disconnect USB-C cable
- [ ] Device should show network icon
- [ ] Can now deploy wirelessly

---

## 8. Debugging and Profiling

### 8.1 Console Logging

- [ ] View console output: View → Debug Area → Activate Console (⇧⌘C)
- [ ] Or use Console.app (macOS) for detailed logs
- [ ] Filter logs by subsystem: `ExecutiveBriefing`

### 8.2 Breakpoint Debugging

- [ ] Set breakpoints: Click line number gutter
- [ ] Run app in debug mode (⌘R)
- [ ] When breakpoint hits:
  - Inspect variables in Debug Area
  - Use LLDB console: `po variableName`
  - Step over: F6
  - Step into: F7
  - Continue: Control + ⌘Y

### 8.3 View Hierarchy Debugging

- [ ] While app is running, click **Debug View Hierarchy** button
- [ ] Or: Debug → View Debugging → Capture View Hierarchy
- [ ] Inspect 3D view hierarchy
- [ ] Check for overlapping views
- [ ] Verify spatial positioning

### 8.4 Memory Graph Debugging

- [ ] While app is running, click **Debug Memory Graph** button
- [ ] Or: Debug → Memory Graph
- [ ] Look for memory leaks (purple icons)
- [ ] Inspect retain cycles

### 8.5 Instruments Profiling

Profile app performance:

- [ ] **Time Profiler**
  - Product → Profile (⌘I)
  - Choose Time Profiler
  - Record while using app
  - Find CPU hotspots

- [ ] **Allocations**
  - Check memory allocations
  - Find memory leaks
  - Track object lifetimes

- [ ] **Metal System Trace**
  - Profile GPU performance
  - Verify 90 FPS
  - Check rendering pipeline

- [ ] **Energy Log**
  - Check battery impact
  - Target: "Low" rating
  - Optimize high-energy operations

---

## 9. TestFlight Distribution

### 9.1 Archive Build

- [ ] Select **Any visionOS Device (arm64)** as destination
- [ ] Product → Archive (⌘⇧B with scheme set to Release)
- [ ] Wait for archive to complete
- [ ] Organizer window opens automatically

### 9.2 Configure Archive

- [ ] In Organizer, select the archive
- [ ] Click **Distribute App**
- [ ] Choose **TestFlight & App Store**
- [ ] Click **Next**

### 9.3 App Store Connect Setup

- [ ] Go to [appstoreconnect.apple.com](https://appstoreconnect.apple.com)
- [ ] Click **My Apps** → **+** → **New App**
- [ ] Fill in app information:
  - Platform: visionOS
  - Name: Executive Briefing AR/VR
  - Language: English
  - Bundle ID: (select your bundle ID)
  - SKU: ExecutiveBriefing001
- [ ] Click **Create**

### 9.4 Upload to TestFlight

- [ ] Back in Xcode Organizer
- [ ] Continue through distribution wizard
- [ ] Upload symbols: ✅ Yes
- [ ] Manage version automatically: ✅ Yes
- [ ] Click **Upload**
- [ ] Wait for upload to complete (may take 5-15 minutes)

### 9.5 Configure TestFlight

- [ ] Go to App Store Connect → TestFlight tab
- [ ] Wait for "Processing" to complete (30 minutes - 2 hours)
- [ ] Once ready, click on build
- [ ] Add test information:
  - What to Test: "First beta release..."
  - Test Details: "Test navigation, content, 3D viz..."

### 9.6 Add Testers

- [ ] Click **App Store Connect Users** or **External Testers**
- [ ] Add testers by email
- [ ] Select groups if needed
- [ ] Click **Add**
- [ ] Testers receive email with TestFlight link

### 9.7 Monitor TestFlight

- [ ] Check crash reports
- [ ] Review feedback
- [ ] Monitor adoption metrics
- [ ] Iterate and upload new builds

---

## 10. App Store Submission

### 10.1 Prepare App Metadata

- [ ] **App Information**
  - Name: Executive Briefing: AR/VR in 2025
  - Subtitle: Strategic Decisions for C-Suite Leaders
  - Category: Business / Productivity

- [ ] **Description**
  - Write compelling app description
  - Highlight key features
  - Mention C-suite focus

- [ ] **Keywords**
  - AR, VR, Executive, Briefing, ROI, Strategy, visionOS

- [ ] **Support URL**
  - Create support website or GitHub pages

- [ ] **Privacy Policy URL**
  - Create privacy policy page

### 10.2 Screenshots and Previews

- [ ] **Required Screenshots** (Apple Vision Pro)
  - Take screenshots in simulator or device
  - Minimum: 3 screenshots
  - Recommended: 6-8 screenshots showing key features

- [ ] **App Preview Video** (Optional)
  - Record 15-30 second demo
  - Show navigation and 3D visualizations

- [ ] **Upload Assets**
  - App Store Connect → App Store tab → Screenshots
  - Drag and drop images
  - Arrange in preferred order

### 10.3 App Review Information

- [ ] **Contact Information**
  - First/Last Name
  - Phone Number
  - Email Address

- [ ] **Demo Account** (if needed)
  - Username: (provide if needed)
  - Password: (provide if needed)

- [ ] **Notes**
  - Add any special instructions for reviewers
  - Mention any complex features

### 10.4 Submit for Review

- [ ] Go to App Store Connect → App Store tab
- [ ] Click **+ Version or Platform**
- [ ] Select visionOS version
- [ ] Fill in "What's New in This Version"
- [ ] Select build from TestFlight
- [ ] Set pricing (Free or Paid)
- [ ] Set availability (regions/countries)
- [ ] Click **Add for Review**
- [ ] Click **Submit to App Review**

### 10.5 Review Process

- [ ] **Waiting for Review**: Usually 24-48 hours
- [ ] **In Review**: Usually 24-48 hours
- [ ] **Approved**: App goes live (or scheduled release)
- [ ] **Rejected**: Address issues and resubmit

---

## 11. Troubleshooting

### 11.1 Build Issues

**Error**: "Cannot find type 'BriefingSection'"
- [ ] Solution: Ensure all Model files are added to target
- [ ] Check: Target Membership in File Inspector

**Error**: "File not found: Executive-Briefing-AR-VR-2025.md"
- [ ] Solution: Add markdown file to Copy Bundle Resources
- [ ] Verify: Build Phases → Copy Bundle Resources

**Error**: "Swift Compiler Error"
- [ ] Clean build folder (⇧⌘K)
- [ ] Delete derived data
- [ ] Restart Xcode
- [ ] Build again

### 11.2 Runtime Issues

**Issue**: App crashes on launch
- [ ] Check Console for error messages
- [ ] Verify database seeding works
- [ ] Check markdown file is in bundle

**Issue**: Database is empty
- [ ] Delete app from simulator
- [ ] Clean build
- [ ] Run again (forces re-seed)

**Issue**: 3D visualizations don't appear
- [ ] Check RealityKit is imported
- [ ] Verify entities are added to scene
- [ ] Check console for errors

### 11.3 Simulator Issues

**Issue**: Simulator is slow
- [ ] Quit other applications
- [ ] Reduce graphics quality in Simulator settings
- [ ] Restart simulator
- [ ] Restart Mac if needed

**Issue**: Can't interact with UI
- [ ] Ensure simulator window has focus
- [ ] Check keyboard shortcuts aren't conflicting
- [ ] Try keyboard navigation

**Issue**: Simulator won't boot
- [ ] Simulator → Device → Erase All Content and Settings
- [ ] Delete simulator and recreate
- [ ] Check macOS/Xcode updates

### 11.4 Device Issues

**Issue**: Device not appearing in Xcode
- [ ] Enable Developer Mode on Vision Pro
- [ ] Reconnect USB-C cable
- [ ] Restart both devices
- [ ] Trust device when prompted

**Issue**: App won't install on device
- [ ] Check signing configuration
- [ ] Verify provisioning profile
- [ ] Try manual code signing
- [ ] Check device storage

**Issue**: Performance issues on device
- [ ] Profile with Instruments
- [ ] Optimize 3D content
- [ ] Reduce polygon counts
- [ ] Check for memory leaks

### 11.5 Test Failures

**Issue**: SwiftData tests fail
- [ ] Ensure in-memory configuration
- [ ] Check model relationships
- [ ] Verify test data is valid

**Issue**: UI tests timeout
- [ ] Increase timeout values
- [ ] Check element accessibility IDs
- [ ] Ensure UI is fully loaded before assertions

### 11.6 Getting Help

- [ ] Check Apple Developer Forums
- [ ] Search Stack Overflow
- [ ] Review Apple Documentation
- [ ] Check project issues on GitHub
- [ ] Contact Apple Developer Support

---

## ✅ Completion Checklist

Use this final checklist to ensure everything is ready:

### Development Complete
- [ ] All source files implemented
- [ ] All tests passing (50+ tests)
- [ ] No compiler warnings
- [ ] Documentation complete
- [ ] README updated

### Testing Complete
- [ ] Unit tests: 100% pass
- [ ] UI tests: All critical flows work
- [ ] Accessibility tests: VoiceOver works
- [ ] Performance tests: 90 FPS on device
- [ ] Memory tests: No leaks detected

### Deployment Ready
- [ ] App builds for release
- [ ] Archive created successfully
- [ ] TestFlight build uploaded
- [ ] Beta testers added
- [ ] Feedback collected

### App Store Ready
- [ ] Metadata complete
- [ ] Screenshots uploaded
- [ ] Privacy policy created
- [ ] Support URL active
- [ ] Submitted for review

---

## 📚 Additional Resources

### Apple Documentation
- [visionOS Developer](https://developer.apple.com/visionos/)
- [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/visionos)
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)
- [RealityKit Documentation](https://developer.apple.com/documentation/realitykit/)
- [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)

### Project Documentation
- `README.md` - Project overview
- `XCODE_SETUP.md` - Detailed setup guide
- `ARCHITECTURE.md` - System architecture
- `TECHNICAL_SPEC.md` - Technical details
- `PROJECT_COMPLETE.md` - Completion summary

### Tools
- [Xcode](https://developer.apple.com/xcode/)
- [TestFlight](https://developer.apple.com/testflight/)
- [App Store Connect](https://appstoreconnect.apple.com/)
- [Transporter](https://apps.apple.com/us/app/transporter/id1450874784) - Upload builds

---

## 🎯 Quick Reference Commands

```bash
# Check Xcode version
xcodebuild -version

# Check available simulators
xcrun simctl list devices

# Build from command line
xcodebuild -scheme ExecutiveBriefing -destination 'platform=visionOS Simulator,name=Apple Vision Pro' build

# Run tests from command line
xcodebuild test -scheme ExecutiveBriefing -destination 'platform=visionOS Simulator,name=Apple Vision Pro'

# Clean build
rm -rf ~/Library/Developer/Xcode/DerivedData/ExecutiveBriefing-*

# Archive for distribution
xcodebuild archive -scheme ExecutiveBriefing -archivePath ./build/ExecutiveBriefing.xcarchive
```

---

**Last Updated**: November 19, 2025
**Status**: ✅ Complete and Ready for Use
**Platform**: visionOS 2.0+ for Apple Vision Pro

---

Built with ❤️ for Apple Vision Pro
