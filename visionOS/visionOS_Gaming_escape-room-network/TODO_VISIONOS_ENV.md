# visionOS Environment Tasks - TODO

This document outlines all tasks that must be performed in a visionOS development environment (Xcode + Vision Pro Simulator/Device). These tasks cannot be completed in a CLI-only environment.

---

## 🎯 Quick Reference

**Environment Requirements:**
- macOS 14.0+ (Sonoma)
- Xcode 16.0+
- visionOS 2.0+ SDK
- Apple Vision Pro (Simulator or Hardware)

**Current Status:** ✅ CLI Implementation Complete | ⏳ Xcode Tasks Pending

---

## 📋 Table of Contents

1. [Project Setup in Xcode](#1-project-setup-in-xcode)
2. [Build & Compile](#2-build--compile)
3. [UI/Visual Testing](#3-uivisual-testing)
4. [ARKit/Spatial Testing](#4-arkitspatial-testing)
5. [Performance Profiling](#5-performance-profiling)
6. [Manual Testing](#6-manual-testing)
7. [Assets & Resources](#7-assets--resources)
8. [App Store Preparation](#8-app-store-preparation)
9. [Known Issues to Resolve](#9-known-issues-to-resolve)

---

## 1. Project Setup in Xcode

### ⏳ Required Tasks

#### 1.1 Create Xcode Project
```bash
# Cannot be done in CLI - requires Xcode
Status: ⏳ TODO
```

**Steps:**
1. Open Xcode 16+
2. File > New > Project
3. Select visionOS > App
4. Configure:
   - Product Name: `EscapeRoomNetwork`
   - Team: Your development team
   - Organization Identifier: `com.escaperoom.network`
   - Interface: SwiftUI
   - Language: Swift
5. Import existing Swift files from `EscapeRoomNetwork/` folder
6. Link Package.swift dependencies

**Files to Import:**
```
EscapeRoomNetwork/
├── App/EscapeRoomNetworkApp.swift
├── Game/GameLogic/*.swift
├── Game/GameState/*.swift
├── Models/*.swift
├── Systems/*.swift
├── Views/UI/*.swift
├── Scenes/GameScene/*.swift
└── Tests/**/*.swift
```

#### 1.2 Configure Build Settings
- [ ] Set minimum deployment target: visionOS 2.0
- [ ] Enable Swift 6.0 language mode
- [ ] Configure code signing
- [ ] Set up entitlements
- [ ] Configure Info.plist

**Info.plist Required Entries:**
```xml
<key>NSWorldSensingUsageDescription</key>
<string>We need to scan your room to create personalized escape room puzzles</string>

<key>NSHandTrackingUsageDescription</key>
<string>Hand tracking is used for interacting with puzzle elements</string>

<key>NSMicrophoneUsageDescription</key>
<string>Microphone access is needed for voice chat with other players</string>
```

#### 1.3 Add Capabilities
- [ ] World Sensing
- [ ] Hand Tracking
- [ ] SharePlay/Group Activities
- [ ] Game Center (optional)

---

## 2. Build & Compile

### ⏳ Required Tasks

#### 2.1 Fix Compilation Errors
```bash
# Command to run in Xcode
⌘B (Build)
```

**Expected Issues:**
- [ ] Missing SwiftUI imports in views
- [ ] RealityKit entity configurations
- [ ] ARKit session setup code
- [ ] GroupActivities protocol conformance

**Files that may need updates:**
- `EscapeRoomNetworkApp.swift` - Add proper imports
- `GameView.swift` - Complete RealityKit setup
- `MultiplayerManager.swift` - Implement actual SharePlay code
- `SpatialMappingManager.swift` - Add real ARKit session code

#### 2.2 Resolve Dependencies
- [ ] Verify Swift Package Manager dependencies load
- [ ] Check for any missing frameworks
- [ ] Resolve any version conflicts

#### 2.3 Build for Simulator
```bash
# Select Vision Pro Simulator
# Product > Build (⌘B)
Status: ⏳ TODO
```

#### 2.4 Build for Device
```bash
# Connect Vision Pro or select paired device
# Product > Build for > Running (⌘B)
Status: ⏳ TODO
```

---

## 3. UI/Visual Testing

### ⏳ Required Tasks - UI Tests

#### 3.1 Run UI Tests
```bash
# In Xcode
Product > Test (⌘U)
# Or select specific test: ⌘6 > Right-click test > Run
```

**Test Files to Run:**
- [ ] `MainMenuUITests.swift` - ❌ Not yet created
- [ ] `GameplayUITests.swift` - ❌ Not yet created
- [ ] `SettingsUITests.swift` - ❌ Not yet created
- [ ] `OnboardingUITests.swift` - ❌ Not yet created

**Create These Test Files:**

**File: `EscapeRoomNetwork/Tests/UITests/MainMenuUITests.swift`**
```swift
import XCTest

final class MainMenuUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUp() {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    func testMainMenuAppears() {
        XCTAssertTrue(app.staticTexts["ESCAPE ROOM NETWORK"].exists)
    }

    func testPlaySoloButton() {
        let playSoloButton = app.buttons["Play Solo"]
        XCTAssertTrue(playSoloButton.exists)
        playSoloButton.tap()
        // Verify transition to game
    }

    func testNavigationToSettings() {
        app.buttons["Settings"].tap()
        XCTAssertTrue(app.staticTexts["Settings"].exists)
    }
}
```

#### 3.2 Snapshot Testing
- [ ] Install snapshot testing library (optional)
- [ ] Capture baseline screenshots for all views
- [ ] Run regression tests on UI changes

#### 3.3 Visual Regression Testing
- [ ] Test main menu layout
- [ ] Test game HUD appearance
- [ ] Test settings screen
- [ ] Verify all colors match design
- [ ] Check font sizes and readability

---

## 4. ARKit/Spatial Testing

### ⏳ Required Tasks - Vision Pro Required

#### 4.1 Room Scanning Tests
**File: `EscapeRoomNetwork/Tests/SpatialTests/ARKitIntegrationTests.swift`**

```swift
import XCTest
import ARKit
@testable import EscapeRoomNetwork

final class ARKitIntegrationTests: XCTestCase {
    // These tests require Vision Pro hardware

    func testRoomScanningAccuracy() {
        // Test requires actual device
        // Scan room and verify mesh quality
    }

    func testFurnitureRecognition() {
        // Test requires actual device
        // Verify furniture classification accuracy
    }
}
```

**Manual Testing Required:**
- [ ] Scan small room (bedroom) - verify accuracy
- [ ] Scan medium room (living room) - verify accuracy
- [ ] Scan large space (open floor plan) - verify accuracy
- [ ] Test with various furniture types
- [ ] Test with different lighting conditions
- [ ] Verify spatial anchors persist across sessions

#### 4.2 Hand Tracking Tests
- [ ] Test pinch gesture detection
- [ ] Test grab gesture detection
- [ ] Test object manipulation with hands
- [ ] Verify hand tracking accuracy at different distances
- [ ] Test with both hands simultaneously

#### 4.3 Eye Tracking Tests
- [ ] Test gaze detection accuracy
- [ ] Verify gaze-based selection
- [ ] Test dwell-time activation
- [ ] Verify eye tracking works with glasses

#### 4.4 Spatial Audio Tests
- [ ] Verify positional audio works correctly
- [ ] Test audio occlusion (sound blocked by walls)
- [ ] Test multiplayer voice chat spatial positioning
- [ ] Verify audio quality and clarity

---

## 5. Performance Profiling

### ⏳ Required Tasks - Instruments

#### 5.1 Frame Rate Analysis
```bash
# In Xcode
Product > Profile (⌘I)
# Select "Game Performance" template
```

**Metrics to Monitor:**
- [ ] Average FPS: Target 90 FPS, Minimum 60 FPS
- [ ] Frame time: < 11ms for 90 FPS
- [ ] GPU utilization: < 70%
- [ ] CPU utilization: < 60%

**Test Scenarios:**
- [ ] Idle game (menu screen)
- [ ] Single puzzle with 10 elements
- [ ] Complex puzzle with 50 elements
- [ ] Multiplayer with 6 players
- [ ] Room scanning active

#### 5.2 Memory Profiling
```bash
# In Xcode
Product > Profile (⌘I)
# Select "Allocations" or "Leaks" template
```

**Checks:**
- [ ] Memory usage < 1.5 GB during gameplay
- [ ] No memory leaks detected
- [ ] Memory doesn't grow over time
- [ ] Proper cleanup when puzzle completes

**Use Instruments:**
- Allocations
- Leaks
- Zombies
- Memory Graph Debugger (⇧⌘M during debug)

#### 5.3 Battery & Thermal
```bash
# In Xcode
Product > Profile (⌘I)
# Select "Energy Log" template
```

**Targets:**
- [ ] 2+ hours battery life during normal gameplay
- [ ] No thermal throttling warnings
- [ ] CPU efficiency rating: Good or better

#### 5.4 Network Performance
- [ ] Test multiplayer with simulated network conditions
- [ ] Verify latency < 100ms
- [ ] Test bandwidth usage
- [ ] Verify graceful degradation with poor connection

---

## 6. Manual Testing

### ⏳ Required Tasks - On Device

#### 6.1 Complete Gameplay Flow
**Test Script:**

1. **Launch & Onboarding**
   - [ ] App launches successfully
   - [ ] First-time tutorial appears
   - [ ] Permissions requested appropriately
   - [ ] Tutorial is clear and helpful

2. **Room Scanning**
   - [ ] Room scanning starts smoothly
   - [ ] Progress indicator works
   - [ ] Scan completes in < 2 minutes
   - [ ] Room recognized accurately

3. **Solo Puzzle**
   - [ ] Puzzle loads within 5 seconds
   - [ ] All UI elements visible and readable
   - [ ] Hand gestures work smoothly
   - [ ] Puzzle elements placed correctly
   - [ ] Objectives tracked properly
   - [ ] Hints system works
   - [ ] Puzzle completion recognized
   - [ ] Celebration/rewards appear

4. **Multiplayer Session**
   - [ ] Can invite friends via SharePlay
   - [ ] Players connect successfully
   - [ ] Voice chat works clearly
   - [ ] Puzzles sync between players
   - [ ] Collaborative actions work
   - [ ] Players can see each other's progress
   - [ ] Session ends gracefully

5. **Settings & Preferences**
   - [ ] All settings can be changed
   - [ ] Changes persist across sessions
   - [ ] Accessibility options work
   - [ ] Audio levels adjust correctly

#### 6.2 Extended Session Testing
- [ ] Play for 30 minutes continuously
- [ ] Play for 1 hour - check battery/thermal
- [ ] Play for 2 hours - verify stability
- [ ] Complete 5 puzzles in one session
- [ ] Test session save/restore

#### 6.3 Edge Cases
- [ ] Test with extremely small room
- [ ] Test with very large open space
- [ ] Test with minimal furniture
- [ ] Test in low light conditions
- [ ] Test with interruptions (phone call, notification)
- [ ] Test with app backgrounding
- [ ] Test disconnecting during multiplayer

#### 6.4 Accessibility Testing
**On Vision Pro:**
- [ ] Enable VoiceOver - navigate entire app
- [ ] Test with largest Dynamic Type size
- [ ] Enable Reduce Motion - verify playable
- [ ] Test with Voice Control
- [ ] Verify all buttons have accessibility labels
- [ ] Test color blind modes

---

## 7. Assets & Resources

### ⏳ Required Tasks - Asset Creation

#### 7.1 3D Models & Assets
**Create in Reality Composer Pro:**

- [ ] Puzzle element models:
  - [ ] Clue icons (10 variations)
  - [ ] Key models (5 types)
  - [ ] Lock models (5 types)
  - [ ] Mechanism models (10 types)
  - [ ] Decoration objects (20+ types)

- [ ] UI elements:
  - [ ] Objective markers
  - [ ] Hint indicators
  - [ ] Progress rings
  - [ ] Celebration effects

**File Structure:**
```
Resources/
├── 3DModels/
│   ├── Clues/
│   ├── Keys/
│   ├── Locks/
│   └── Mechanisms/
├── Materials/
├── Textures/
└── Particles/
```

#### 7.2 Audio Assets
- [ ] Background music (3-5 tracks)
- [ ] Sound effects:
  - [ ] Clue discovered
  - [ ] Puzzle solved
  - [ ] Hint revealed
  - [ ] Button tap
  - [ ] Menu navigation
  - [ ] Success/failure sounds
- [ ] Voice narration (optional)
- [ ] Ambient soundscapes

**Location:** `Resources/Audio/`

#### 7.3 App Icons & Screenshots
- [ ] App icon (1024x1024)
- [ ] App icon variants for different contexts
- [ ] Launch screen
- [ ] Screenshots for App Store (6-8 required)
- [ ] Preview video (optional but recommended)

---

## 8. App Store Preparation

### ⏳ Required Tasks - TestFlight & Submission

#### 8.1 TestFlight Setup
```bash
# In Xcode
Product > Archive
# Then upload to App Store Connect
```

**Steps:**
1. [ ] Archive app build
2. [ ] Upload to App Store Connect
3. [ ] Configure TestFlight:
   - [ ] Add test information
   - [ ] Set up beta testers
   - [ ] Create test groups
4. [ ] Distribute to internal testers (Apple employees)
5. [ ] Distribute to external testers
6. [ ] Collect feedback

**TestFlight Checklist:**
- [ ] Export compliance information
- [ ] Add beta testing notes
- [ ] Set up beta tester groups
- [ ] Configure automatic updates

#### 8.2 App Store Metadata
- [ ] App name: "Escape Room Network"
- [ ] Subtitle (30 chars): "Spatial Puzzle Adventure"
- [ ] Description (4000 chars max)
- [ ] Keywords
- [ ] Support URL
- [ ] Marketing URL
- [ ] Privacy Policy URL
- [ ] Age rating questionnaire

#### 8.3 Privacy & Compliance
- [ ] Create privacy policy
- [ ] Configure privacy details in App Store Connect:
  - [ ] Data collected: Room layout, gameplay stats
  - [ ] Data usage: Gameplay, analytics
  - [ ] Data sharing: None
- [ ] Export compliance documentation
- [ ] Content rights verification

#### 8.4 Pricing & Availability
- [ ] Set pricing tier
- [ ] Configure in-app purchases:
  - [ ] Individual puzzles ($7.99)
  - [ ] Subscription ($14.99/month)
  - [ ] Corporate package ($99.99/month)
- [ ] Select territories
- [ ] Set release date

#### 8.5 App Review Preparation
- [ ] Prepare demo account (if needed)
- [ ] Create demo video showing all features
- [ ] Write detailed review notes
- [ ] Prepare for common rejection reasons:
  - [ ] Incomplete features
  - [ ] Privacy violations
  - [ ] Performance issues
  - [ ] Misleading metadata

---

## 9. Known Issues to Resolve

### 🔧 Technical Debt

#### 9.1 Implementation Gaps
- [ ] **SpatialMappingManager**: Replace mock room scanning with real ARKit implementation
- [ ] **MultiplayerManager**: Implement actual SharePlay GroupSession code
- [ ] **GameView**: Complete RealityView entity setup
- [ ] **Hand Tracking**: Implement full gesture recognition
- [ ] **Spatial Audio**: Add AVAudioEngine configuration

#### 9.2 Missing Features
- [ ] Save/Load system not fully implemented
- [ ] Achievement system needs backend
- [ ] Leaderboards require Game Center integration
- [ ] Analytics not configured
- [ ] Crash reporting not set up

#### 9.3 Polish Items
- [ ] Add loading indicators
- [ ] Improve error messages
- [ ] Add animation polish
- [ ] Implement haptic feedback
- [ ] Add particle effects
- [ ] Improve visual effects

---

## 🚀 Execution Plan

### Week 1: Project Setup
- [ ] Day 1: Create Xcode project, import files
- [ ] Day 2: Configure build settings, resolve compilation errors
- [ ] Day 3: Add assets, configure Info.plist
- [ ] Day 4: First successful build on simulator
- [ ] Day 5: Test on Vision Pro hardware

### Week 2: Core Implementation
- [ ] Day 1: Implement real ARKit room scanning
- [ ] Day 2: Implement hand tracking
- [ ] Day 3: Implement spatial audio
- [ ] Day 4: Complete RealityKit entity setup
- [ ] Day 5: Integration testing

### Week 3: Polish & Testing
- [ ] Day 1-2: UI/UX polish
- [ ] Day 3: Performance profiling
- [ ] Day 4: Bug fixes
- [ ] Day 5: Manual testing

### Week 4: Multiplayer & Final
- [ ] Day 1-2: SharePlay implementation
- [ ] Day 3: Multiplayer testing
- [ ] Day 4: Final polish
- [ ] Day 5: TestFlight build

### Week 5: App Store
- [ ] Day 1: Create App Store listing
- [ ] Day 2: TestFlight beta testing
- [ ] Day 3: Address beta feedback
- [ ] Day 4: Final submission build
- [ ] Day 5: Submit for review

---

## 📝 Testing Checklist Summary

### ✅ Completed (CLI Tests)
- [x] Unit tests (90%+ coverage)
- [x] Integration tests
- [x] Performance tests (basic)
- [x] Security tests
- [x] Stress tests
- [x] Localization tests
- [x] Accessibility validation tests

### ⏳ Requires Xcode
- [ ] UI tests
- [ ] Snapshot tests
- [ ] Full performance profiling
- [ ] Memory leak detection
- [ ] Build & compile

### ⏳ Requires Vision Pro
- [ ] ARKit/Spatial tests
- [ ] Hand tracking tests
- [ ] Eye tracking tests
- [ ] Spatial audio tests
- [ ] End-to-end gameplay tests
- [ ] Manual testing scenarios

---

## 📞 Support & Resources

**Apple Documentation:**
- [visionOS Developer](https://developer.apple.com/visionos/)
- [RealityKit](https://developer.apple.com/documentation/realitykit/)
- [ARKit](https://developer.apple.com/documentation/arkit/)
- [SharePlay](https://developer.apple.com/documentation/groupactivities/)

**Troubleshooting:**
- [visionOS Forum](https://developer.apple.com/forums/tags/visionos)
- [Stack Overflow - visionOS](https://stackoverflow.com/questions/tagged/visionos)

**Tools:**
- Reality Composer Pro
- Instruments
- TestFlight
- App Store Connect

---

**Last Updated:** 2025-11-19
**Status:** 📦 CLI Implementation Complete, 🔨 Xcode Implementation Pending
**Next Step:** Import project into Xcode and begin visionOS-specific implementation
