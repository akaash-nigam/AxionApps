# visionOS-Specific Tests Documentation

This document outlines tests that require Apple Vision Pro hardware or visionOS Simulator to run.

## ⚠️ Prerequisites

- **Xcode 16.0+** with visionOS SDK 2.0+
- **Apple Vision Pro** (device) OR **visionOS Simulator**
- **macOS Sonoma 14.5+** with Apple Silicon

## UI Tests (Requires visionOS Environment)

### MainControlViewUITests.swift

**Purpose**: Test main control window functionality

```swift
import XCTest

final class MainControlViewUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUp() {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    func testStoreListDisplays() {
        // Verify store list appears
        XCTAssertTrue(app.navigationBars["Retail Space Optimizer"].exists)

        // Check if stores are visible
        let storeList = app.scrollViews.firstMatch
        XCTAssertTrue(storeList.exists)
    }

    func testCreateStoreFlow() {
        // Tap create button
        app.buttons["New Store"].tap()

        // Fill in store details
        let nameField = app.textFields["Store Name"]
        XCTAssertTrue(nameField.exists)
        nameField.tap()
        nameField.typeText("Test Store")

        // Submit
        app.buttons["Create"].tap()

        // Verify store appears
        XCTAssertTrue(app.staticTexts["Test Store"].waitForExistence(timeout: 5))
    }

    func testOpenStoreEditor() {
        // Select first store
        let firstStore = app.buttons.matching(identifier: "StoreCard").firstMatch
        XCTAssertTrue(firstStore.exists)
        firstStore.tap()

        // Tap edit button
        app.buttons["Edit Layout"].tap()

        // Verify editor opens (new window)
        // Note: Window detection in visionOS requires specific APIs
    }

    func testNavigationToAnalytics() {
        // Select store
        app.buttons.matching(identifier: "StoreCard").firstMatch.tap()

        // Open analytics
        app.buttons["Analytics"].tap()

        // Verify analytics dashboard
        // Window should contain analytics content
    }
}
```

**Run Command**:
```bash
xcodebuild test \
  -scheme RetailSpaceOptimizer \
  -destination 'platform=visionOS Simulator,name=Apple Vision Pro' \
  -only-testing:RetailSpaceOptimizerUITests/MainControlViewUITests
```

---

### StoreEditorUITests.swift

**Purpose**: Test 2D layout editor interactions

```swift
final class StoreEditorUITests: XCTestCase {
    var app: XCUIApplication!

    func testFixturePlacement() {
        // Open store editor
        openStoreEditor()

        // Select fixture from library
        let fixtureLibrary = app.scrollViews["FixtureLibrary"]
        let shelfButton = fixtureLibrary.buttons["Shelf 1"]
        shelfButton.tap()

        // Drag to canvas
        let canvas = app.otherElements["StoreCanvas"]
        let start = shelfButton.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        let end = canvas.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        start.press(forDuration: 0.5, thenDragTo: end)

        // Verify fixture appears on canvas
        XCTAssertTrue(canvas.otherElements.containing(.any, identifier: "Shelf").exists)
    }

    func testZoomControls() {
        openStoreEditor()

        let zoomSlider = app.sliders["Zoom"]
        XCTAssertTrue(zoomSlider.exists)

        // Adjust zoom
        zoomSlider.adjust(toNormalizedSliderPosition: 0.8)

        // Verify zoom level updates
        let zoomLabel = app.staticTexts.containing(NSPredicate(format: "label CONTAINS '80%'"))
        XCTAssertTrue(zoomLabel.firstMatch.exists)
    }

    func testUndoRedo() {
        openStoreEditor()

        // Perform an action (add fixture)
        // ... fixture placement code ...

        // Undo
        app.buttons["Undo"].tap()

        // Verify fixture removed
        // ...

        // Redo
        app.buttons["Redo"].tap()

        // Verify fixture restored
        // ...
    }
}
```

**Run Command**:
```bash
xcodebuild test \
  -scheme RetailSpaceOptimizer \
  -destination 'platform=visionOS Simulator,name=Apple Vision Pro' \
  -only-testing:RetailSpaceOptimizerUITests/StoreEditorUITests
```

---

### VolumetricWindowTests.swift

**Purpose**: Test 3D volumetric window interactions

```swift
final class VolumetricWindowTests: XCTestCase {
    func testVolumeOpens() {
        app.launch()

        // Open store
        app.buttons.matching(identifier: "StoreCard").firstMatch.tap()

        // Open 3D preview
        app.buttons["3D Preview"].tap()

        // Verify volumetric window appears
        // Note: Volumetric window detection requires visionOS-specific APIs
        XCTAssertTrue(app.windows.count > 1)
    }

    func testVolumeGestureInteractions() {
        // Test requires actual Vision Pro hardware or simulator
        // Gesture simulation: rotate, scale, drag in 3D space
    }

    func testVolumeControls() {
        openVolumetricPreview()

        // Toggle walls
        let wallsToggle = app.toggles["Walls"]
        XCTAssertTrue(wallsToggle.exists)
        wallsToggle.tap()

        // Toggle grid
        let gridToggle = app.toggles["Grid"]
        XCTAssertTrue(gridToggle.exists)
        gridToggle.tap()
    }
}
```

**⚠️ Note**: Volumetric window testing requires actual visionOS environment. Simulator may have limited support.

---

### ImmersiveSpaceTests.swift

**Purpose**: Test immersive space experience

```swift
final class ImmersiveSpaceTests: XCTestCase {
    func testEnterImmersiveMode() {
        app.launch()

        // Navigate to immersive walkthrough
        // ... navigation code ...

        // Enter immersive space
        app.buttons["Walkthrough"].tap()

        // Wait for immersive space to load
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 5))

        // Verify immersive UI elements
        let immersiveControls = app.otherElements["ImmersiveControls"]
        XCTAssertTrue(immersiveControls.exists)
    }

    func testExitImmersiveMode() {
        enterImmersiveMode()

        // Exit immersive space
        app.buttons["Exit Immersive Mode"].tap()

        // Verify returned to window mode
        XCTAssertTrue(app.windows.count >= 1)
    }

    func testImmersiveAnalyticsOverlay() {
        enterImmersiveMode()

        // Toggle analytics
        let analyticsToggle = app.toggles["Show Analytics"]
        analyticsToggle.tap()

        // Verify analytics appear in 3D space
        // Note: Requires spatial UI testing capabilities
    }
}
```

**⚠️ Critical**: Immersive space tests **MUST** run on actual Vision Pro hardware. Simulator support is limited.

---

## Performance Tests (Requires visionOS)

### RenderingPerformanceTests.swift

**Purpose**: Test 3D rendering performance

```swift
final class RenderingPerformanceTests: XCTestCase {
    func testVolumeRenderingPerformance() {
        measure(metrics: [XCTClockMetric(), XCTMemoryMetric()]) {
            // Open volumetric window
            openVolumetricPreview()

            // Load complex store model
            loadStoreWithManyFixtures(count: 100)

            // Measure frame rate
            // Target: 60 FPS minimum
        }
    }

    func testImmersiveSpacePerformance() {
        measure(metrics: [XCTClockMetric(), XCTCPUMetric(), XCTMemoryMetric()]) {
            // Enter immersive space
            enterImmersiveMode()

            // Load full-scale store
            loadFullScaleStore()

            // Target: 90 FPS for comfort
        }
    }

    func testLargeScenePerformance() {
        // Test with maximum fixture count
        let maxFixtures = 1000

        measure {
            loadStoreWithManyFixtures(count: maxFixtures)
        }

        // Should complete in < 5 seconds
        // Memory should stay < 2GB
    }
}
```

**Run Command**:
```bash
xcodebuild test \
  -scheme RetailSpaceOptimizer \
  -destination 'platform=visionOS,name=<Device Name>' \
  -only-testing:RetailSpaceOptimizerPerformanceTests
```

**Targets**:
- **Frame Rate**: 90 FPS (immersive), 60 FPS (windows)
- **Memory**: < 2GB typical, < 3GB peak
- **Load Time**: < 5 seconds for complex stores

---

## Accessibility Tests (Requires visionOS)

### AccessibilityTests.swift

**Purpose**: Test VoiceOver and accessibility features

```swift
final class AccessibilityTests: XCTestCase {
    func testVoiceOverNavigation() {
        // Enable VoiceOver
        app.launch(with: .voiceOver)

        // Navigate with VoiceOver
        // Verify all elements have labels
        let firstElement = app.buttons.firstMatch
        XCTAssertNotNil(firstElement.label)
        XCTAssertFalse(firstElement.label.isEmpty)
    }

    func testAccessibilityLabels() {
        app.launch()

        // Check all interactive elements have accessibility
        let buttons = app.buttons.allElementsBoundByIndex
        for button in buttons {
            XCTAssertNotNil(button.label)
            XCTAssertFalse(button.label.isEmpty)
        }
    }

    func testDynamicType() {
        // Test with large text sizes
        app.launch(with: .accessibilityLargeText)

        // Verify UI adapts
        // Text should be readable
        // Layout should not break
    }

    func testSpatialAccessibility() {
        // Test 3D entity accessibility
        enterImmersiveMode()

        // Verify 3D objects have accessibility
        // VoiceOver should describe spatial position
    }
}
```

**Run Command**:
```bash
xcodebuild test \
  -scheme RetailSpaceOptimizer \
  -destination 'platform=visionOS Simulator,name=Apple Vision Pro' \
  -only-testing:RetailSpaceOptimizerAccessibilityTests
```

---

## Hand Tracking Tests (Requires Vision Pro Hardware)

### HandTrackingTests.swift

**Purpose**: Test hand gesture interactions

```swift
final class HandTrackingTests: XCTestCase {
    // ⚠️ REQUIRES ACTUAL VISION PRO HARDWARE

    func testPinchGesture() {
        // Test pinch to select
        // Requires hand tracking provider
    }

    func testDragGesture() {
        // Test grab and drag fixtures
        // Requires hand tracking in 3D space
    }

    func testRotationGesture() {
        // Test two-hand rotation
        // Requires hand tracking
    }
}
```

**⚠️ Cannot be automated**: Manual testing required with physical device.

---

## Eye Tracking Tests (Requires Vision Pro Hardware)

### EyeTrackingTests.swift

**Purpose**: Test gaze-based interactions

```swift
final class EyeTrackingTests: XCTestCase {
    // ⚠️ REQUIRES ACTUAL VISION PRO HARDWARE

    func testGazeFocus() {
        // Verify elements highlight on gaze
        // Requires eye tracking
    }

    func testDwellActivation() {
        // Test dwell-based activation
        // Requires eye tracking
    }
}
```

**⚠️ Cannot be automated**: Manual testing required with physical device.

---

## Running Tests

### All Unit Tests (Can run without visionOS)
```bash
xcodebuild test \
  -scheme RetailSpaceOptimizer \
  -only-testing:RetailSpaceOptimizerTests
```

### UI Tests (Requires Simulator/Device)
```bash
# On Simulator
xcodebuild test \
  -scheme RetailSpaceOptimizer \
  -destination 'platform=visionOS Simulator,name=Apple Vision Pro' \
  -only-testing:RetailSpaceOptimizerUITests

# On Device
xcodebuild test \
  -scheme RetailSpaceOptimizer \
  -destination 'platform=visionOS,name=My Vision Pro' \
  -only-testing:RetailSpaceOptimizerUITests
```

### Performance Tests (Requires Device)
```bash
xcodebuild test \
  -scheme RetailSpaceOptimizer \
  -destination 'platform=visionOS,name=My Vision Pro' \
  -only-testing:RetailSpaceOptimizerPerformanceTests
```

---

## Test Coverage Goals

| Test Type | Target Coverage | Environment Required |
|-----------|----------------|---------------------|
| Unit Tests | > 80% | ✅ Any Mac |
| Integration Tests | > 70% | ✅ Any Mac |
| UI Tests | > 60% | ⚠️ visionOS Simulator |
| Performance Tests | Critical paths | ⚠️ Vision Pro Device |
| Accessibility Tests | All interactive elements | ⚠️ visionOS Simulator |
| Gesture Tests | Manual verification | ⚠️ Vision Pro Device |

---

## Manual Testing Checklist

### On Vision Pro Device

- [ ] Immersive space enters smoothly (< 2s)
- [ ] Frame rate stays at 90 FPS in immersive mode
- [ ] Hand gestures work accurately
- [ ] Eye tracking focuses correctly
- [ ] Spatial audio positioned accurately
- [ ] No simulator artifacts
- [ ] Comfortable viewing distances
- [ ] No motion sickness triggers
- [ ] Battery usage is reasonable (> 2 hours)
- [ ] Thermal performance is acceptable

### On Simulator

- [ ] All windows open correctly
- [ ] 2D UI works as expected
- [ ] Navigation flows smoothly
- [ ] Data persists correctly
- [ ] Settings save properly
- [ ] Mock data displays
- [ ] Analytics charts render
- [ ] Export functions work

---

## Continuous Integration

### GitHub Actions (Example)

```yaml
name: Tests

on: [push, pull_request]

jobs:
  unit-tests:
    runs-on: macos-14
    steps:
      - uses: actions/checkout@v3
      - name: Run Unit Tests
        run: |
          xcodebuild test \
            -scheme RetailSpaceOptimizer \
            -destination 'platform=macOS' \
            -only-testing:RetailSpaceOptimizerTests

  ui-tests:
    runs-on: macos-14
    steps:
      - uses: actions/checkout@v3
      - name: Run UI Tests on Simulator
        run: |
          xcodebuild test \
            -scheme RetailSpaceOptimizer \
            -destination 'platform=visionOS Simulator,name=Apple Vision Pro' \
            -only-testing:RetailSpaceOptimizerUITests
```

---

## Troubleshooting

### Simulator Issues

**Problem**: Volumetric windows don't appear
- **Solution**: Restart simulator, ensure visionOS 2.0+ is installed

**Problem**: Immersive space crashes
- **Solution**: Immersive spaces have limited simulator support. Test on device.

### Performance Issues

**Problem**: Tests timeout
- **Solution**: Increase timeout values, check for memory leaks

**Problem**: Frame rate drops
- **Solution**: Reduce polygon count, implement LOD system

### Device Issues

**Problem**: Hand tracking not detected
- **Solution**: Ensure good lighting, recalibrate device

**Problem**: Eye tracking inaccurate
- **Solution**: Recalibrate eye tracking in device settings

---

## Additional Resources

- [visionOS Testing Guide](https://developer.apple.com/documentation/visionos/testing-your-app)
- [XCTest Framework](https://developer.apple.com/documentation/xctest)
- [Performance Testing](https://developer.apple.com/documentation/xcode/improving-performance)
- [Accessibility Testing](https://developer.apple.com/documentation/accessibility)
