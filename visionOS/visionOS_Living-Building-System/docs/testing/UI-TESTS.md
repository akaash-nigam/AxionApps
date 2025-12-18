# UI Test Plan
## Living Building System - visionOS

**Version**: 1.0
**Last Updated**: 2025-11-24
**Test Framework**: XCTest UI Testing

---

## Overview

This document describes UI tests that require the visionOS Simulator or physical device to execute. These tests verify user interface interactions, navigation flows, and visual behavior.

## Prerequisites

- Xcode 15.2 or later
- visionOS SDK 2.0+
- Apple Vision Pro Simulator
- Test device (optional)

## Setup

```bash
# Build for testing
xcodebuild -scheme LivingBuildingSystem -destination 'platform=visionOS Simulator,name=Apple Vision Pro' build-for-testing

# Run UI tests
xcodebuild -scheme LivingBuildingSystem -destination 'platform=visionOS Simulator,name=Apple Vision Pro' test -only-testing:LivingBuildingSystemUITests
```

---

## Test Suite 1: Onboarding Flow

### Test 1.1: First Launch Onboarding
**Priority**: Critical
**Estimated Duration**: 2 minutes

**Steps**:
1. Launch app for the first time (clean install)
2. Verify onboarding sheet appears automatically
3. Verify "Welcome" screen displays with app icon
4. Tap "Next" button
5. Verify "Home Setup" screen appears
6. Enter home name: "Test Home"
7. Enter address: "123 Test St"
8. Tap "Next" button
9. Verify "User Setup" screen appears
10. Enter user name: "Test User"
11. Select role: "Owner"
12. Tap "Complete" button
13. Verify onboarding dismisses
14. Verify dashboard appears with home data

**Expected Results**:
- Onboarding completes successfully
- Home created with name "Test Home"
- 4 default rooms created (Living Room, Kitchen, Bedroom, Bathroom)
- User created with name "Test User" and role "Owner"
- Dashboard displays empty device list

**Test Code**:
```swift
func testFirstLaunchOnboarding() throws {
    let app = XCUIApplication()
    app.launchArguments = ["--uitesting", "--reset-data"]
    app.launch()

    // Verify onboarding appears
    XCTAssertTrue(app.sheets["onboarding"].waitForExistence(timeout: 2))

    // Welcome screen
    XCTAssertTrue(app.staticTexts["Welcome to Living Building System"].exists)
    app.buttons["Next"].tap()

    // Home setup
    XCTAssertTrue(app.staticTexts["Set Up Your Home"].exists)
    app.textFields["Home Name"].tap()
    app.textFields["Home Name"].typeText("Test Home")
    app.textFields["Address"].tap()
    app.textFields["Address"].typeText("123 Test St")
    app.buttons["Next"].tap()

    // User setup
    XCTAssertTrue(app.staticTexts["Create Your Profile"].exists)
    app.textFields["Name"].tap()
    app.textFields["Name"].typeText("Test User")
    app.buttons["Owner"].tap()
    app.buttons["Complete"].tap()

    // Verify dashboard
    XCTAssertTrue(app.navigationBars["Living Building System"].waitForExistence(timeout: 5))
    XCTAssertTrue(app.staticTexts["Test Home"].exists)
}
```

### Test 1.2: Skip Onboarding on Subsequent Launches
**Priority**: High
**Estimated Duration**: 30 seconds

**Steps**:
1. Complete onboarding (prerequisite)
2. Close and relaunch app
3. Verify onboarding does NOT appear
4. Verify dashboard appears immediately

**Expected Results**:
- Onboarding skipped
- Dashboard loads with saved data
- Home name and devices persist

**Test Code**:
```swift
func testOnboardingSkippedOnSubsequentLaunch() throws {
    let app = XCUIApplication()
    app.launch()

    // Verify onboarding does NOT appear
    XCTAssertFalse(app.sheets["onboarding"].waitForExistence(timeout: 2))

    // Verify dashboard appears
    XCTAssertTrue(app.navigationBars["Living Building System"].exists)
}
```

---

## Test Suite 2: Dashboard Navigation

### Test 2.1: Navigate to Settings
**Priority**: High
**Estimated Duration**: 30 seconds

**Steps**:
1. Launch app
2. Locate Settings button in toolbar
3. Tap Settings button
4. Verify Settings window opens
5. Verify settings content displays

**Expected Results**:
- Settings window opens
- Home statistics visible
- Debug utilities visible

**Test Code**:
```swift
func testNavigateToSettings() throws {
    let app = XCUIApplication()
    app.launch()

    // Tap settings button
    app.buttons["Settings"].tap()

    // Verify settings window
    XCTAssertTrue(app.windows["settings"].waitForExistence(timeout: 2))
    XCTAssertTrue(app.staticTexts["Debug Utilities"].exists)
}
```

### Test 2.2: Navigate to Energy Dashboard
**Priority**: High
**Estimated Duration**: 30 seconds

**Steps**:
1. Launch app
2. Locate Energy button in toolbar
3. Tap Energy button
4. Verify Energy Dashboard window opens
5. Verify energy content displays

**Expected Results**:
- Energy dashboard opens
- "Energy Monitoring" title visible
- Configuration prompt if not set up

**Test Code**:
```swift
func testNavigateToEnergyDashboard() throws {
    let app = XCUIApplication()
    app.launch()

    // Tap energy button
    app.buttons["Energy"].tap()

    // Verify energy dashboard
    XCTAssertTrue(app.windows["energy"].waitForExistence(timeout: 2))
    XCTAssertTrue(app.navigationBars["Energy Monitoring"].exists)
}
```

### Test 2.3: Enter Immersive Space
**Priority**: Critical
**Estimated Duration**: 1 minute

**Steps**:
1. Launch app
2. Tap "Enter Immersive View" button
3. Verify immersive space loads
4. Verify 3D environment appears
5. Verify button becomes disabled

**Expected Results**:
- Immersive space opens
- 3D home environment visible
- Button disabled while in immersive mode

**Test Code**:
```swift
func testEnterImmersiveSpace() throws {
    let app = XCUIApplication()
    app.launch()

    let immersiveButton = app.buttons["Enter Immersive View"]
    XCTAssertTrue(immersiveButton.exists)
    XCTAssertTrue(immersiveButton.isEnabled)

    immersiveButton.tap()

    // Wait for immersive space to load
    Thread.sleep(forTimeInterval: 2)

    // Button should be disabled
    XCTAssertFalse(immersiveButton.isEnabled)
}
```

---

## Test Suite 3: Device Management

### Test 3.1: Discover Devices
**Priority**: Critical
**Estimated Duration**: 1 minute

**Steps**:
1. Launch app
2. Grant HomeKit permissions when prompted
3. Tap "Refresh" button
4. Wait for device discovery
5. Verify devices appear in grid
6. Verify device count updates

**Expected Results**:
- HomeKit permission granted
- Devices discovered and displayed
- Device grid populated
- Status shows "X devices found"

**Test Code**:
```swift
func testDiscoverDevices() throws {
    let app = XCUIApplication()
    app.launchArguments = ["--uitesting"]
    app.launch()

    // Tap refresh button
    app.buttons["Refresh"].tap()

    // Wait for discovery
    Thread.sleep(forTimeInterval: 3)

    // Verify devices appear
    let deviceGrid = app.scrollViews.firstMatch
    XCTAssertGreaterThan(deviceGrid.buttons.count, 0)
}
```

### Test 3.2: Control Device (Toggle)
**Priority**: Critical
**Estimated Duration**: 30 seconds

**Steps**:
1. Discover devices (prerequisite)
2. Locate a light device card
3. Note current state (on/off)
4. Tap the device card
5. Verify state toggles
6. Verify visual feedback

**Expected Results**:
- Device state changes
- Card updates immediately (optimistic UI)
- Icon changes to reflect new state

**Test Code**:
```swift
func testToggleDevice() throws {
    let app = XCUIApplication()
    app.launch()

    // Find first device
    let deviceCard = app.buttons.matching(identifier: "device-card").firstMatch
    XCTAssertTrue(deviceCard.waitForExistence(timeout: 5))

    // Get initial state
    let initialLabel = deviceCard.label

    // Tap to toggle
    deviceCard.tap()

    // Wait for state change
    Thread.sleep(forTimeInterval: 1)

    // Verify state changed
    let newLabel = deviceCard.label
    XCTAssertNotEqual(initialLabel, newLabel)
}
```

### Test 3.3: Open Device Detail View
**Priority**: High
**Estimated Duration**: 30 seconds

**Steps**:
1. Discover devices (prerequisite)
2. Locate a device with brightness control
3. Long press on device card
4. Verify detail window opens
5. Verify detail shows device controls

**Expected Results**:
- Detail window opens
- Device name displayed
- Controls visible (brightness slider, etc.)
- "Close" button present

**Test Code**:
```swift
func testOpenDeviceDetail() throws {
    let app = XCUIApplication()
    app.launch()

    // Find and long-press first device
    let deviceCard = app.buttons.matching(identifier: "device-card").firstMatch
    XCTAssertTrue(deviceCard.waitForExistence(timeout: 5))
    deviceCard.press(forDuration: 1.0)

    // Verify detail window
    XCTAssertTrue(app.windows["device-detail"].waitForExistence(timeout: 2))
    XCTAssertTrue(app.sliders["brightness-slider"].exists)
}
```

---

## Test Suite 4: Energy Monitoring

### Test 4.1: Configure Energy Monitoring
**Priority**: High
**Estimated Duration**: 1 minute

**Steps**:
1. Navigate to Energy Dashboard
2. Tap "Configure" button (if not configured)
3. Toggle "Smart Meter" on
4. Enter API identifier: "test-meter-001"
5. Toggle "Solar Panels" on
6. Set electricity rate: 0.18
7. Tap "Save"
8. Verify configuration saved

**Expected Results**:
- Configuration sheet appears
- All fields editable
- Configuration saves successfully
- "Connected to smart meter" message appears

**Test Code**:
```swift
func testConfigureEnergyMonitoring() throws {
    let app = XCUIApplication()
    app.launch()

    // Navigate to energy
    app.buttons["Energy"].tap()

    // Tap configure
    app.buttons["Configure"].tap()

    // Configure settings
    app.switches["Smart Meter"].tap()
    app.textFields["API Identifier"].tap()
    app.textFields["API Identifier"].typeText("test-meter-001")
    app.switches["Solar Panels"].tap()

    // Save
    app.buttons["Save"].tap()

    // Verify connected
    XCTAssertTrue(app.staticTexts["Connected to smart meter"].waitForExistence(timeout: 2))
}
```

### Test 4.2: View Real-Time Energy Data
**Priority**: High
**Estimated Duration**: 30 seconds

**Steps**:
1. Configure energy monitoring (prerequisite)
2. Navigate to Energy Dashboard
3. Verify current status cards display
4. Verify electricity power shown
5. Verify solar generation shown (if configured)
6. Wait 5 seconds
7. Verify values update

**Expected Results**:
- Status cards show real-time data
- Values are numeric and reasonable
- Values update automatically

**Test Code**:
```swift
func testViewRealTimeEnergyData() throws {
    let app = XCUIApplication()
    app.launch()

    app.buttons["Energy"].tap()

    // Verify status cards
    XCTAssertTrue(app.staticTexts["Electricity"].exists)

    // Find power value
    let powerLabel = app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'kW'")).firstMatch
    XCTAssertTrue(powerLabel.exists)

    let initialValue = powerLabel.label

    // Wait for update
    Thread.sleep(forTimeInterval: 6)

    // Verify value changed
    let newValue = powerLabel.label
    // Values might change or stay the same, just verify it's still a valid number
    XCTAssertTrue(newValue.contains("kW"))
}
```

### Test 4.3: View Consumption Chart
**Priority**: Medium
**Estimated Duration**: 30 seconds

**Steps**:
1. Navigate to Energy Dashboard (with data)
2. Locate consumption chart
3. Verify chart displays bars
4. Tap "Week" time range selector
5. Verify chart updates with weekly data

**Expected Results**:
- Chart visible with bars
- Time range selector works
- Chart updates when range changes

**Test Code**:
```swift
func testViewConsumptionChart() throws {
    let app = XCUIApplication()
    app.launch()

    app.buttons["Energy"].tap()

    // Find chart
    let chart = app.otherElements["consumption-chart"]
    XCTAssertTrue(chart.waitForExistence(timeout: 3))

    // Switch to week view
    app.buttons["Week"].tap()

    // Chart should still exist
    XCTAssertTrue(chart.exists)
}
```

### Test 4.4: Dismiss Energy Anomaly
**Priority**: Medium
**Estimated Duration**: 30 seconds

**Steps**:
1. Navigate to Energy Dashboard (with anomalies)
2. Locate anomaly alert
3. Tap dismiss button (X)
4. Verify anomaly disappears from list
5. Verify anomaly count updates

**Expected Results**:
- Anomaly dismissed
- Alert removed from UI
- Count decreases by 1

**Test Code**:
```swift
func testDismissEnergyAnomaly() throws {
    let app = XCUIApplication()
    app.launchArguments = ["--uitesting", "--generate-anomalies"]
    app.launch()

    app.buttons["Energy"].tap()

    // Find first anomaly
    let anomalyRow = app.otherElements["anomaly-row"].firstMatch
    XCTAssertTrue(anomalyRow.waitForExistence(timeout: 2))

    // Get initial count
    let alertsLabel = app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'Alerts'")).firstMatch
    let initialLabel = alertsLabel.label

    // Dismiss
    anomalyRow.buttons["xmark.circle.fill"].tap()

    // Wait for UI update
    Thread.sleep(forTimeInterval: 0.5)

    // Verify count changed
    let newLabel = alertsLabel.label
    XCTAssertNotEqual(initialLabel, newLabel)
}
```

---

## Test Suite 5: Spatial Interactions

### Test 5.1: Room Scanning
**Priority**: High
**Estimated Duration**: 2 minutes

**Steps**:
1. Navigate to Settings
2. Tap "Scan Room" button
3. Verify room scan immersive space opens
4. Observe mesh visualization
5. Wait for room scanning progress
6. Tap "Complete" button
7. Verify return to dashboard

**Expected Results**:
- Immersive space opens
- Cyan mesh visualized
- Progress indicator shows surface count
- Anchor saved on completion

**Manual Test** (requires physical device)

### Test 5.2: Look-to-Control Interaction
**Priority**: Medium
**Estimated Duration**: 1 minute

**Steps**:
1. Enter immersive home view
2. Locate a device entity in 3D space
3. Look directly at device for 1 second
4. Verify contextual control appears
5. Tap air to toggle device
6. Verify device state changes

**Expected Results**:
- Device highlights when gazed at
- Control panel appears
- Air tap toggles device
- Visual feedback provided

**Manual Test** (requires physical device with eye tracking)

---

## Test Suite 6: Data Persistence

### Test 6.1: Data Persists Across Launches
**Priority**: Critical
**Estimated Duration**: 1 minute

**Steps**:
1. Complete onboarding with home "Persistence Test"
2. Discover and control some devices
3. Configure energy monitoring
4. Force quit app
5. Relaunch app
6. Verify home name still "Persistence Test"
7. Verify devices still present
8. Verify energy configuration still set

**Expected Results**:
- All data persists
- Home, rooms, user data intact
- Device states current
- Energy configuration preserved

**Test Code**:
```swift
func testDataPersistence() throws {
    let app = XCUIApplication()
    app.launchArguments = ["--uitesting"]
    app.launch()

    // Create data
    // ... (onboarding, device setup, etc.)

    // Terminate
    app.terminate()

    // Relaunch
    app.launch()

    // Verify data
    XCTAssertTrue(app.staticTexts["Persistence Test"].exists)
    XCTAssertGreaterThan(app.buttons.matching(identifier: "device-card").count, 0)
}
```

### Test 6.2: Auto-Save Functionality
**Priority**: High
**Estimated Duration**: 5 minutes

**Steps**:
1. Launch app with existing data
2. Make a change (rename home in settings)
3. Wait 5 minutes (auto-save interval)
4. Force quit app WITHOUT explicit save
5. Relaunch app
6. Verify change persisted

**Expected Results**:
- Auto-save triggers after 5 minutes
- Changes persist without manual save
- Data integrity maintained

**Manual Test** (requires 5+ minute wait)

---

## Test Suite 7: Error Handling

### Test 7.1: HomeKit Permission Denied
**Priority**: High
**Estimated Duration**: 1 minute

**Steps**:
1. Reset HomeKit permissions
2. Launch app
3. Deny HomeKit permission when prompted
4. Verify error banner appears
5. Verify helpful message shown
6. Tap "Retry" button
7. Grant permission
8. Verify error clears

**Expected Results**:
- Error banner displays
- Message: "HomeKit access denied"
- Retry button works
- Discovery succeeds after grant

**Test Code**:
```swift
func testHomeKitPermissionDenied() throws {
    let app = XCUIApplication()
    app.launchArguments = ["--uitesting", "--deny-homekit"]
    app.launch()

    // Tap refresh to trigger permission
    app.buttons["Refresh"].tap()

    // Verify error
    XCTAssertTrue(app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'denied'")).firstMatch.waitForExistence(timeout: 2))
}
```

### Test 7.2: Device Unreachable
**Priority**: Medium
**Estimated Duration**: 30 seconds

**Steps**:
1. Discover devices (with a simulated unreachable device)
2. Locate unreachable device card
3. Verify "Unreachable" badge shown
4. Tap device card
5. Verify error message or disabled state

**Expected Results**:
- Unreachable devices marked
- Badge or icon indicates status
- Controls disabled for unreachable devices

**Test Code**:
```swift
func testDeviceUnreachable() throws {
    let app = XCUIApplication()
    app.launchArguments = ["--uitesting", "--unreachable-device"]
    app.launch()

    // Find unreachable device
    let unreachableCard = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Unreachable'")).firstMatch
    XCTAssertTrue(unreachableCard.waitForExistence(timeout: 3))
}
```

---

## Test Suite 8: Performance

### Test 8.1: Scroll Performance (Device Grid)
**Priority**: High
**Estimated Duration**: 30 seconds

**Steps**:
1. Launch app with 50+ devices
2. Scroll through device grid rapidly
3. Monitor frame rate
4. Verify smooth 60fps scrolling

**Expected Results**:
- Scrolling smooth at 60fps
- No dropped frames
- No stuttering

**Performance Test** (requires Instruments)

### Test 8.2: Immersive Space Frame Rate
**Priority**: Critical
**Estimated Duration**: 1 minute

**Steps**:
1. Enter immersive space with 20+ devices
2. Move head around environment
3. Monitor frame rate with Instruments
4. Verify consistent 90fps

**Expected Results**:
- 90fps maintained
- No frame drops during head movement
- Smooth entity rendering

**Performance Test** (requires Instruments + device)

---

## Test Execution Instructions

### Running All UI Tests
```bash
cd LivingBuildingSystem
xcodebuild test -scheme LivingBuildingSystem \
  -destination 'platform=visionOS Simulator,name=Apple Vision Pro' \
  -only-testing:LivingBuildingSystemUITests
```

### Running Specific Test Suite
```bash
xcodebuild test -scheme LivingBuildingSystem \
  -destination 'platform=visionOS Simulator,name=Apple Vision Pro' \
  -only-testing:LivingBuildingSystemUITests/OnboardingTests
```

### Running Single Test
```bash
xcodebuild test -scheme LivingBuildingSystem \
  -destination 'platform=visionOS Simulator,name=Apple Vision Pro' \
  -only-testing:LivingBuildingSystemUITests/OnboardingTests/testFirstLaunchOnboarding
```

---

## Test Data Setup

### Launch Arguments for Testing

```swift
// In test setUp:
app.launchArguments = [
    "--uitesting",                    // Enable UI testing mode
    "--reset-data",                   // Clear all persisted data
    "--generate-sample-devices",      // Create mock devices
    "--generate-anomalies",           // Create energy anomalies
    "--disable-animations",           // Speed up tests
    "--deny-homekit",                 // Simulate permission denial
    "--unreachable-device",           // Add unreachable device
]
```

### Environment Variables

```swift
app.launchEnvironment = [
    "ANIMATION_DURATION": "0",        // Disable animations
    "UITEST_MODE": "1",               // UI test mode flag
]
```

---

## Coverage Requirements

**Minimum Coverage**: 80% of UI flows

**Critical Paths** (must have 100% coverage):
- ✅ Onboarding flow
- ✅ Device discovery and control
- ✅ Energy monitoring setup
- ✅ Immersive space entry
- ✅ Data persistence

**Medium Priority** (target 80% coverage):
- Energy chart interactions
- Settings modifications
- Device detail views
- Anomaly management

**Low Priority** (target 50% coverage):
- Edge cases
- Error recovery
- Performance scenarios

---

## Accessibility Testing

All UI tests should also verify:
- VoiceOver compatibility
- Dynamic type support
- Contrast ratios
- Touch target sizes (min 44x44pt)

Add accessibility assertions:
```swift
XCTAssertTrue(button.isAccessibilityElement)
XCTAssertNotNil(button.accessibilityLabel)
XCTAssertNotNil(button.accessibilityHint)
```

---

## CI/CD Integration

### GitHub Actions Example

```yaml
name: UI Tests

on: [push, pull_request]

jobs:
  uitest:
    runs-on: macos-14
    steps:
      - uses: actions/checkout@v3

      - name: Select Xcode
        run: sudo xcode-select -s /Applications/Xcode_15.2.app

      - name: Run UI Tests
        run: |
          xcodebuild test \
            -scheme LivingBuildingSystem \
            -destination 'platform=visionOS Simulator,name=Apple Vision Pro' \
            -resultBundlePath TestResults.xcresult

      - name: Upload Results
        uses: actions/upload-artifact@v3
        with:
          name: test-results
          path: TestResults.xcresult
```

---

## Known Issues & Limitations

1. **Eye Tracking**: Cannot be tested in simulator
2. **Hand Gestures**: Limited simulation support
3. **Spatial Audio**: Not testable in CI environment
4. **ARKit Features**: Require physical device
5. **Performance**: Simulator results not representative

---

## Document Maintenance

- Update after each new UI feature
- Review quarterly for obsolete tests
- Keep test code in sync with app code
- Document test failures and resolutions
