# visionOS-Specific Tests

## Overview

This document details all tests that require either the visionOS Simulator or a physical Apple Vision Pro device. These tests cannot be run in the current development environment but are critical for production readiness.

---

## 🔶 Simulator-Required Tests

These tests can be run in Xcode's visionOS Simulator once available.

### 1. UI Component Tests

**File**: `Tests/UITests/ComponentTests.swift`

```swift
import XCTest
import SwiftUI
@testable import MysteryInvestigation

final class ComponentTests: XCTestCase {

    func testMainMenuRendering() throws {
        // Launch app
        let app = XCUIApplication()
        app.launch()

        // Verify main menu elements
        XCTAssertTrue(app.staticTexts["MYSTERY"].exists)
        XCTAssertTrue(app.staticTexts["INVESTIGATION"].exists)
        XCTAssertTrue(app.buttons["Start New Case"].exists)
        XCTAssertTrue(app.buttons["Settings"].exists)
    }

    func testCaseSelectionRendering() throws {
        let app = XCUIApplication()
        app.launch()

        // Navigate to case selection
        app.buttons["Start New Case"].tap()

        // Verify case cards render
        XCTAssertTrue(app.staticTexts["Select a Case"].exists)
        XCTAssertTrue(app.buttons.containing(NSPredicate(format: "label CONTAINS 'Case'")).count > 0)
    }

    func testInvestigationHUDElements() throws {
        let app = XCUIApplication()
        app.launch()

        // Start a case
        app.buttons["Start New Case"].tap()
        app.buttons.matching(identifier: "CaseCard").element(boundBy: 0).tap()

        // Verify HUD elements
        XCTAssertTrue(app.staticTexts.matching(identifier: "EvidenceCount").count > 0)
        XCTAssertTrue(app.staticTexts.matching(identifier: "Objective").count > 0)
    }
}
```

### 2. Navigation Flow Tests

**File**: `Tests/UITests/NavigationFlowTests.swift`

```swift
final class NavigationFlowTests: XCTestCase {

    func testCompleteNavigationFlow() throws {
        let app = XCUIApplication()
        app.launch()

        // Main Menu → Case Selection
        app.buttons["Start New Case"].tap()
        XCTAssertTrue(app.staticTexts["Select a Case"].exists)

        // Case Selection → Investigation
        app.buttons.matching(identifier: "CaseCard").element(boundBy: 0).tap()
        // Should transition to immersive space

        // Investigation → Pause Menu
        app.buttons["Pause"].tap()
        XCTAssertTrue(app.staticTexts["PAUSED"].exists)

        // Pause Menu → Resume
        app.buttons["Resume Investigation"].tap()

        // Investigation → Main Menu
        app.buttons["Pause"].tap()
        app.buttons["Return to Main Menu"].tap()
        XCTAssertTrue(app.staticTexts["MYSTERY"].exists)
    }

    func testBackNavigation() throws {
        let app = XCUIApplication()
        app.launch()

        app.buttons["Start New Case"].tap()
        app.buttons["Back"].tap()

        XCTAssertTrue(app.staticTexts["MYSTERY"].exists)
    }
}
```

### 3. Settings Persistence Tests

**File**: `Tests/IntegrationTests/SettingsPersistenceTests.swift`

```swift
final class SettingsPersistenceTests: XCTestCase {

    func testSettingsSaveAndLoad() throws {
        let app = XCUIApplication()
        app.launch()

        // Open settings
        app.buttons["Settings"].tap()

        // Change settings
        app.sliders["Master Volume"].adjust(toNormalizedSliderPosition: 0.5)
        app.switches["Hand Tracking"].tap() // Toggle off

        // Close and relaunch
        app.terminate()
        app.launch()

        // Verify settings persisted
        app.buttons["Settings"].tap()
        let volumeSlider = app.sliders["Master Volume"]
        XCTAssertEqual(volumeSlider.value as? String, "50%", accuracy: 5)

        let handTracking = app.switches["Hand Tracking"]
        XCTAssertEqual(handTracking.value as? String, "0") // Off
    }
}
```

### 4. SwiftUI View Tests

**File**: `Tests/ViewTests/SwiftUIViewTests.swift`

```swift
import ViewInspector
@testable import MysteryInvestigation

final class SwiftUIViewTests: XCTestCase {

    func testMainMenuViewStructure() throws {
        let coordinator = GameCoordinator()
        let view = MainMenuView()
            .environment(coordinator)

        // Inspect view hierarchy
        let vStack = try view.inspect().vStack()
        XCTAssertNoThrow(try vStack.find(text: "MYSTERY"))
        XCTAssertNoThrow(try vStack.find(text: "INVESTIGATION"))
        XCTAssertNoThrow(try vStack.find(button: "Start New Case"))
    }

    func testCaseSelectionViewRendersCards() throws {
        let coordinator = GameCoordinator()
        let view = CaseSelectionView()
            .environment(coordinator)

        // Should render case cards
        let grid = try view.inspect().find(ViewType.LazyVGrid.self)
        XCTAssertNotNil(grid)
    }
}
```

---

## 🔴 Physical Device Required Tests

These tests MUST be run on actual Apple Vision Pro hardware.

### 1. ARKit Integration Tests

**File**: `Tests/SpatialTests/ARKitIntegrationTests.swift`

```swift
import XCTest
import ARKit
@testable import MysteryInvestigation

@available(visionOS 1.0, *)
final class ARKitIntegrationTests: XCTestCase {

    var spatialManager: SpatialMappingManager!

    override func setUp() async throws {
        spatialManager = SpatialMappingManager()
    }

    func testRoomScanningInitialization() async throws {
        // Start room scanning
        await spatialManager.startRoomScanning()

        // Verify scanning started
        XCTAssertTrue(spatialManager.isScanning)

        // Wait for plane detection
        try await Task.sleep(nanoseconds: 3_000_000_000) // 3 seconds

        // Stop scanning
        spatialManager.stopRoomScanning()
        XCTAssertFalse(spatialManager.isScanning)
    }

    func testPlaneDetection() async throws {
        await spatialManager.startRoomScanning()

        // Wait for planes to be detected
        try await Task.sleep(nanoseconds: 5_000_000_000) // 5 seconds

        // Verify planes detected
        XCTAssertFalse(spatialManager.detectedPlanes.isEmpty,
                      "Should detect at least one plane in 5 seconds")

        spatialManager.stopRoomScanning()
    }

    func testRoomSizeCalculation() async throws {
        await spatialManager.startRoomScanning()

        // Wait for sufficient data
        try await Task.sleep(nanoseconds: 5_000_000_000)

        // Check room size was calculated
        let roomSize = spatialManager.roomSize
        XCTAssertGreaterThan(roomSize.x, 0)
        XCTAssertGreaterThan(roomSize.y, 0)
        XCTAssertGreaterThan(roomSize.z, 0)

        spatialManager.stopRoomScanning()
    }
}
```

### 2. Evidence Placement Accuracy Tests

**File**: `Tests/SpatialTests/EvidencePlacementTests.swift`

```swift
final class EvidencePlacementTests: XCTestCase {

    func testEvidencePlacementOnFloor() async throws {
        // Setup
        let manager = SpatialMappingManager()
        await manager.startRoomScanning()
        try await Task.sleep(nanoseconds: 5_000_000_000)

        // Create test evidence
        let evidence = createFloorEvidence()

        // Place evidence
        let scene = RealityKit.Scene()
        let entity = manager.placeEvidence(evidence, in: scene)

        // Verify placement
        XCTAssertNotNil(entity)
        XCTAssertLessThan(abs(entity!.position.y), 0.1,
                         "Floor evidence should be near y=0")
    }

    func testEvidencePlacementAccuracy() async throws {
        // Test multiple evidence placements
        let manager = SpatialMappingManager()
        await manager.startRoomScanning()
        try await Task.sleep(nanoseconds: 5_000_000_000)

        let evidenceList = createTestEvidenceList(count: 10)
        let scene = RealityKit.Scene()

        var placementErrors: [Float] = []

        for evidence in evidenceList {
            if let entity = manager.placeEvidence(evidence, in: scene) {
                let expectedY = evidence.spatialAnchor.relativePosition.y
                let actualY = entity.position.y
                let error = abs(expectedY - actualY)
                placementErrors.append(error)
            }
        }

        // Average error should be < 5mm
        let avgError = placementErrors.reduce(0, +) / Float(placementErrors.count)
        XCTAssertLessThan(avgError, 0.005, "Average placement error should be < 5mm")
    }

    func testEvidencePersistence() async throws {
        // Place evidence, restart app, verify it's still there
        // This tests WorldAnchor persistence
    }
}
```

### 3. Hand Tracking Tests

**File**: `Tests/SpatialTests/HandTrackingTests.swift`

```swift
final class HandTrackingTests: XCTestCase {

    func testPinchGestureRecognition() async throws {
        let manager = HandTrackingManager()

        // Note: This requires physical hand tracking
        // Tester would perform pinch gesture

        // Monitor for gesture detection
        var pinchDetected = false
        let expectation = XCTestExpectation(description: "Pinch detected")

        // Start monitoring (implementation would use ARKit HandTrackingProvider)
        // ...

        // Give tester time to perform gesture
        let result = await fulfillment(of: [expectation], timeout: 10.0)
        XCTAssertTrue(pinchDetected, "Pinch gesture should be detected")
    }

    func testGestureLatency() async throws {
        // Measure time from gesture start to recognition
        // Should be < 50ms for good UX
    }

    func testGestureAccuracy() async throws {
        // Perform 100 gestures, measure recognition rate
        // Should be > 90% for production
    }
}
```

### 4. Eye Tracking Tests

**File**: `Tests/SpatialTests/EyeTrackingTests.swift`

```swift
final class EyeTrackingTests: XCTestCase {

    func testGazeRaycastAccuracy() async throws {
        let manager = GazeTrackingSystem()

        // Place target evidence at known location
        let targetPosition = SIMD3<Float>(0, 1.5, -2.0)

        // User looks at target
        // Measure gaze raycast hit

        // Verify accuracy within 5 degrees
    }

    func testDwellTimeDetection() async throws {
        // Test that dwell time (0.5s) correctly triggers selection
    }

    func testEvidenceHighlighting() async throws {
        // Verify evidence highlights when gazed at
    }
}
```

### 5. Performance Tests

**File**: `Tests/PerformanceTests/FrameRateTests.swift`

```swift
final class FrameRateTests: XCTestCase {

    func testMinimumFrameRate() throws {
        // Measure frame rate during active gameplay
        let fpsMonitor = FPSMonitor()

        // Play for 5 minutes
        let duration: TimeInterval = 300
        fpsMonitor.startMonitoring()

        // Simulate full investigation (evidence discovery, interrogation, etc.)
        sleep(UInt32(duration))

        let stats = fpsMonitor.stopMonitoring()

        // Assert performance targets
        XCTAssertGreaterThanOrEqual(stats.averageFPS, 90, "Average FPS should be ≥ 90")
        XCTAssertGreaterThanOrEqual(stats.minimumFPS, 60, "Minimum FPS should never drop below 60")
        XCTAssertLessThan(stats.frameTimeVariance, 10, "Frame time variance should be < 10ms")
    }

    func testPerformanceWithMaximumEvidence() throws {
        // Test with worst-case scenario: all evidence visible
    }

    func testPerformanceDuringInterrogation() throws {
        // Test FPS while hologram is active
    }
}
```

### 6. Memory Tests

**File**: `Tests/PerformanceTests/MemoryTests.swift`

```swift
final class MemoryTests: XCTestCase {

    func testMemoryUsageUnderLoad() throws {
        let memoryMonitor = MemoryMonitor()

        memoryMonitor.startMonitoring()

        // Load case
        let coordinator = GameCoordinator()
        let testCase = coordinator.caseManager.availableCases.first!
        coordinator.startNewCase(testCase)

        // Discover all evidence
        for evidence in testCase.evidence {
            coordinator.discoverEvidence(evidence)
        }

        let memoryStats = memoryMonitor.currentUsage()

        // Verify memory constraints
        XCTAssertLessThan(memoryStats.totalMB, 700, "Total memory should be < 700MB")
    }

    func testMemoryLeaks() throws {
        // Run game session, check for leaks
        measureMemory {
            let coordinator = GameCoordinator()

            // Play through case
            for _ in 0..<10 {
                let testCase = coordinator.caseManager.availableCases.first!
                coordinator.startNewCase(testCase)
                // ... complete case ...
                coordinator.returnToMainMenu()
            }
        }

        // Memory should not continuously grow
    }
}
```

### 7. Comfort Tests

**File**: `Tests/UXTests/ComfortTests.swift`

```swift
final class ComfortTests: XCTestCase {

    func testExtendedPlaySessionComfort() async throws {
        // This requires human testers
        // Test protocol:

        // 1. Tester plays for 60 minutes continuously
        // 2. Survey questions every 15 minutes:
        //    - Motion sickness level (0-10)
        //    - Eye strain (0-10)
        //    - Neck discomfort (0-10)
        //    - Overall comfort (0-10)

        // Success criteria:
        // - Motion sickness: < 2/10 average
        // - Eye strain: < 3/10 average
        // - Neck discomfort: < 3/10 average
        // - Overall comfort: > 7/10 average

        // Document any comfort issues for iteration
    }

    func testTextLegibilityAtDistance() throws {
        // Verify all text is readable at 1.5m distance
        // Test different UI elements
    }
}
```

### 8. Multiplayer Tests

**File**: `Tests/MultiplayerTests/SharePlayTests.swift`

```swift
final class SharePlayTests: XCTestCase {

    func testSessionCreation() async throws {
        let manager = MultiplayerManager()

        // Create session
        try await manager.createSession()

        XCTAssertNotNil(manager.activeSession)
    }

    func testEvidenceSynchronization() async throws {
        // Requires two devices
        // Device 1 discovers evidence
        // Verify Device 2 receives update within 200ms
    }

    func testDisconnectionHandling() async throws {
        // Simulate network disconnection
        // Verify graceful degradation
        // Verify reconnection works
    }
}
```

---

## Test Execution Checklist

### Pre-Device Testing (Simulator)
- [ ] All UI component tests pass
- [ ] Navigation flows work correctly
- [ ] Settings persistence works
- [ ] SwiftUI views render properly
- [ ] Accessibility features function

### Device Testing - Phase 1 (Basic Functionality)
- [ ] ARKit session initializes
- [ ] Room scanning works
- [ ] Plane detection functions
- [ ] Evidence placement works
- [ ] Hand gestures recognized
- [ ] Eye tracking functions

### Device Testing - Phase 2 (Performance)
- [ ] Frame rate meets targets (90 FPS avg, 60 FPS min)
- [ ] Memory usage within limits (< 700MB)
- [ ] Load times acceptable (< 3s)
- [ ] No memory leaks detected
- [ ] Battery usage acceptable (60+ min)

### Device Testing - Phase 3 (User Experience)
- [ ] Comfortable for 60 minutes
- [ ] All text legible
- [ ] Gestures intuitive
- [ ] No motion sickness
- [ ] Tutorial completion rate > 90%

### Device Testing - Phase 4 (Multiplayer)
- [ ] SharePlay session creation works
- [ ] Evidence synchronization < 200ms
- [ ] Disconnection handled gracefully
- [ ] Reconnection works

### Device Testing - Phase 5 (Polish)
- [ ] All edge cases handled
- [ ] Accessibility features work
- [ ] Localization correct
- [ ] Final regression tests pass

---

## Test Environment Requirements

### Hardware
- **Minimum**: 3 Vision Pro devices (testing + multiplayer)
- **Recommended**: 5 Vision Pro devices (parallel testing)

### Test Rooms
- Small room (2m × 2m) - minimum space testing
- Medium room (3m × 3m) - optimal space testing
- Large room (5m × 5m) - maximum space testing
- Varied lighting conditions

### Test Participants
- Internal QA team (10 people)
- Beta testers (50-100 people)
- Accessibility testers (10 people with various needs)
- Different age groups (16-65)

---

## Automated Testing on Device

### Continuous Testing Setup

```bash
# Run tests on connected Vision Pro device
xcodebuild test \
  -scheme MysteryInvestigation \
  -destination 'platform=visionOS,name=Apple Vision Pro' \
  -resultBundlePath TestResults.xcresult

# Extract results
xcrun xcresulttool get --format json \
  --path TestResults.xcresult > results.json
```

### Performance Monitoring

```swift
// Integrate into app for continuous monitoring
class PerformanceMonitor {
    func logMetrics() {
        // FPS
        // Memory
        // Network latency (multiplayer)
        // Gesture recognition rate
    }
}
```

---

## Test Reporting Template

### Test Session Report

```markdown
# Test Session Report

**Date**: [Date]
**Tester**: [Name]
**Device**: Apple Vision Pro
**Build**: [Version]
**Test Duration**: [Duration]

## Test Results

### ARKit Tests
- [ ] Room scanning: PASS/FAIL
- [ ] Plane detection: PASS/FAIL
- [ ] Evidence placement: PASS/FAIL
- Notes: [Any issues]

### Performance Tests
- Average FPS: [Number]
- Minimum FPS: [Number]
- Memory usage: [MB]
- Load time: [Seconds]
- Notes: [Any issues]

### UX Tests
- Comfort rating: [0-10]
- Motion sickness: [0-10]
- Eye strain: [0-10]
- Overall experience: [0-10]
- Notes: [Feedback]

## Issues Found
1. [Issue description]
2. [Issue description]

## Recommendations
1. [Recommendation]
2. [Recommendation]
```

---

## Next Steps

1. **Immediate** (can start now):
   - Write all test cases
   - Set up test infrastructure
   - Prepare test data

2. **When simulator available**:
   - Run UI tests
   - Run navigation tests
   - Verify SwiftUI views

3. **When device available**:
   - Run ARKit tests
   - Run performance tests
   - Conduct user testing
   - Launch beta program

---

**These visionOS-specific tests are critical for ensuring Mystery Investigation meets the highest quality standards on Apple Vision Pro.**
