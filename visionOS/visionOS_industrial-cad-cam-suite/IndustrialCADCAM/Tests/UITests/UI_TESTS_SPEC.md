# UI Tests Specification - visionOS Required

This document specifies UI tests that MUST be run on visionOS Simulator or Apple Vision Pro hardware.

## Prerequisites

- Xcode 16+ with visionOS SDK
- visionOS Simulator or Apple Vision Pro device
- XCUITest framework

## Test Suite Structure

```swift
import XCTest

class IndustrialCADCAMUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
}
```

---

## 1. Window Management Tests

### Test: Launch App and Display Control Panel
```swift
func testLaunchAppShowsControlPanel() throws {
    // Given: App is launched

    // When: App appears
    let controlPanel = app.windows["control-panel"]

    // Then: Control panel window exists
    XCTAssert(controlPanel.exists)
    XCTAssert(controlPanel.staticTexts["Industrial CAD/CAM"].exists)
}
```

### Test: Create New Project Flow
```swift
func testCreateNewProject() throws {
    // Given: Control panel is visible
    let newProjectButton = app.buttons["New Project"]

    // When: User taps new project button
    newProjectButton.tap()

    // Then: New project sheet appears
    let sheet = app.sheets.firstMatch
    XCTAssert(sheet.exists)

    // When: User enters project details
    let nameField = sheet.textFields["Project Name"]
    nameField.tap()
    nameField.typeText("Test CAD Project")

    // And: User confirms creation
    sheet.buttons["Create"].tap()

    // Then: Project appears in list
    XCTAssert(app.staticTexts["Test CAD Project"].exists)
}
```

### Test: Open Multiple Windows
```swift
func testOpenMultipleWindows() throws {
    // Given: Control panel is visible

    // When: User opens inspector window
    app.buttons["Open Inspector"].tap()

    // Then: Inspector window exists
    let inspector = app.windows["inspector"]
    XCTAssert(inspector.exists)

    // When: User opens library window
    app.buttons["Open Library"].tap()

    // Then: Library window exists
    let library = app.windows["library"]
    XCTAssert(library.exists)

    // And: All windows coexist
    XCTAssert(inspector.exists && library.exists)
}
```

---

## 2. Volumetric Window Tests

### Test: Open Part Viewer Volume
```swift
func testOpenPartViewerVolume() throws {
    // Given: A project with a part exists
    createTestProject()
    selectPart("Test Part")

    // When: User opens part viewer
    app.buttons["Part Viewer"].tap()

    // Then: Volumetric window appears
    let partViewer = app.windows["part-viewer"]
    XCTAssert(partViewer.exists)

    // And: 3D content is visible
    // Note: Entity detection requires specialized visionOS APIs
}
```

### Test: Interact with Part in Volume
```swift
func testRotatePartInVolume() throws {
    // Given: Part viewer is open
    openPartViewer()

    // When: User performs rotation gesture
    let partEntity = app.entities["test-part"]
    partEntity.tap()

    // Perform drag gesture to rotate
    let start = partEntity.coordinate(withNormalizedOffset: CGVector(dx: 0.3, dy: 0.3))
    let end = partEntity.coordinate(withNormalizedOffset: CGVector(dx: 0.7, dy: 0.7))
    start.press(forDuration: 0.1, thenDragTo: end)

    // Then: Part rotates (verify through entity state)
    // Note: Requires custom entity accessibility labels
}
```

---

## 3. Immersive Space Tests

### Test: Enter Design Studio
```swift
func testEnterDesignStudio() throws {
    // Given: Project is open
    openTestProject()

    // When: User enters immersive space
    app.buttons["Design Studio"].tap()

    // Then: Immersive space loads
    let immersiveSpace = app.immersiveSpaces["design-studio"]
    XCTAssert(immersiveSpace.isActive)

    // And: Environment is visible
    XCTAssert(app.entities["grid-floor"].exists)
    XCTAssert(app.entities["tool-palette"].exists)
}
```

### Test: Tool Palette Interaction
```swift
func testToolPaletteInImmersiveSpace() throws {
    // Given: Design studio is active
    enterDesignStudio()

    // When: User taps tool from palette
    let selectTool = app.buttons["Select Tool"]
    selectTool.tap()

    // Then: Tool is activated
    XCTAssert(selectTool.isSelected)

    // When: User taps different tool
    let moveTool = app.buttons["Move Tool"]
    moveTool.tap()

    // Then: Active tool changes
    XCTAssert(moveTool.isSelected)
    XCTAssertFalse(selectTool.isSelected)
}
```

### Test: Exit Immersive Space
```swift
func testExitDesignStudio() throws {
    // Given: Design studio is active
    enterDesignStudio()

    // When: User exits immersive space
    // Note: Uses Digital Crown or system gesture
    app.digitalCrown.rotate(by: -1.0)

    // Then: Returns to window mode
    let immersiveSpace = app.immersiveSpaces["design-studio"]
    XCTAssertFalse(immersiveSpace.isActive)

    // And: Control panel is visible again
    XCTAssert(app.windows["control-panel"].exists)
}
```

---

## 4. Gesture Recognition Tests

### Test: Tap Gesture on Entity
```swift
func testTapGestureSelects Entity() throws {
    // Given: Part viewer is open with parts
    openPartViewerWithParts()

    // When: User taps on a part entity
    let partEntity = app.entities["bracket-42"]
    partEntity.tap()

    // Then: Part is selected
    XCTAssert(partEntity.isSelected)

    // And: Properties inspector updates
    let inspector = app.windows["inspector"]
    XCTAssert(inspector.staticTexts["Bracket_42"].exists)
}
```

### Test: Drag Gesture Moves Part
```swift
func testDragGestureMovesPartInSpace() throws {
    // Given: Design studio with movable part
    enterDesignStudio()
    let part = app.entities["movable-part"]
    let initialPosition = part.frame.origin

    // When: User drags part to new location
    let newPosition = CGPoint(x: initialPosition.x + 100, y: initialPosition.y)
    part.press(forDuration: 0.1, thenDragTo: app.coordinate(withNormalizedOffset: CGVector(dx: 0.6, dy: 0.5)))

    // Then: Part moves to new position
    let finalPosition = part.frame.origin
    XCTAssertNotEqual(initialPosition, finalPosition)
}
```

### Test: Pinch Gesture Scales Part
```swift
func testPinchGestureScalesPart() throws {
    // Given: Part viewer with scalable part
    openPartViewer()
    let part = app.entities["scalable-part"]
    let initialSize = part.frame.size

    // When: User performs pinch gesture
    part.pinch(withScale: 2.0, velocity: 1.0)

    // Then: Part scales up
    let finalSize = part.frame.size
    XCTAssertGreaterThan(finalSize.width, initialSize.width)
}
```

---

## 5. Hand Tracking Tests

### Test: Hand Tracking Permission
```swift
func testHandTrackingPermissionRequest() throws {
    // Given: App launches for first time

    // When: App requests hand tracking permission
    let permissionAlert = app.alerts["Hand Tracking Permission"]

    // Then: Alert appears
    XCTAssert(permissionAlert.exists)

    // When: User allows hand tracking
    permissionAlert.buttons["Allow"].tap()

    // Then: Permission granted
    // Verify through app state
}
```

### Test: Pinch Gesture Detection
```swift
func testPinchGestureDetection() throws {
    // Given: Design studio is active with hand tracking
    enterDesignStudio()

    // When: User performs pinch gesture
    // Note: This requires actual hand tracking hardware
    // Simulator: Use simulated hand gestures
    performPinchGesture()

    // Then: Part is selected
    let selectedPart = app.entities.matching(NSPredicate(format: "isSelected == true"))
    XCTAssertGreaterThan(selectedPart.count, 0)
}
```

---

## 6. Navigation Tests

### Test: Navigate Between Windows
```swift
func testNavigateBetweenWindows() throws {
    // Given: Multiple windows are open
    openMultipleWindows()

    // When: User focuses on different windows
    let controlPanel = app.windows["control-panel"]
    let inspector = app.windows["inspector"]

    inspector.tap()
    XCTAssert(inspector.isFocused)

    controlPanel.tap()
    XCTAssert(controlPanel.isFocused)
}
```

### Test: Window Positioning
```swift
func testWindowPositioning() throws {
    // Given: Window is open
    let window = app.windows["control-panel"]
    let initialPosition = window.frame.origin

    // When: User repositions window
    // Note: visionOS specific window movement gesture
    window.press(forDuration: 1.0, thenDragTo: app.coordinate(withNormalizedOffset: CGVector(dx: 0.3, dy: 0.3)))

    // Then: Window moves
    let finalPosition = window.frame.origin
    XCTAssertNotEqual(initialPosition, finalPosition)
}
```

---

## 7. Accessibility Tests

### Test: VoiceOver Navigation
```swift
func testVoiceOverNavigation() throws {
    // Given: VoiceOver is enabled
    XCUIDevice.shared.enableVoiceOver()

    // When: User navigates with VoiceOver
    app.swipeRight() // Next element

    // Then: Focus moves to next element
    let focusedElement = app.firstMatch.staticTexts.element(matching: .any, identifier: "voiceover-focused")
    XCTAssert(focusedElement.exists)

    XCUIDevice.shared.disableVoiceOver()
}
```

### Test: Spatial Audio Accessibility
```swift
func testSpatialAudioLabels() throws {
    // Given: Immersive space with entities
    enterDesignStudio()

    // When: VoiceOver is enabled
    XCUIDevice.shared.enableVoiceOver()

    // Then: All entities have spatial audio labels
    let entities = app.entities.allElementsBoundByAccessibilityElement
    XCTAssert(entities.allSatisfy { $0.accessibilityLabel != nil })

    XCUIDevice.shared.disableVoiceOver()
}
```

---

## 8. Performance Tests in UI Context

### Test: Frame Rate During Interaction
```swift
func testFrameRateDuringRotation() throws {
    // Given: Part viewer with complex part
    openPartViewerWithComplexPart()

    // When: User continuously rotates part
    let part = app.entities["complex-part"]

    measure(metrics: [XCTOSSignpostMetric.applicationLaunch]) {
        // Perform rotation
        for _ in 0..<10 {
            part.rotate(by: 0.1)
        }
    }

    // Then: Frame rate stays above 60 FPS
    // Verify through performance metrics
}
```

### Test: Window Launch Performance
```swift
func testWindowLaunchPerformance() throws {
    // Measure time to launch windows
    measure {
        app.buttons["Part Viewer"].tap()

        let partViewer = app.windows["part-viewer"]
        _ = partViewer.waitForExistence(timeout: 5)
    }

    // Assert launch time < 1 second
}
```

---

## 9. Collaboration Tests (Multi-Device)

### Test: Start Collaboration Session
```swift
func testStartCollaborationSession() throws {
    // Given: Project is open
    openTestProject()

    // When: User starts collaboration
    app.buttons["Start Collaboration"].tap()

    // Then: Session creation dialog appears
    let dialog = app.sheets["New Session"]
    XCTAssert(dialog.exists)

    // When: User confirms
    dialog.buttons["Start"].tap()

    // Then: Session is active
    XCTAssert(app.staticTexts["Session Active"].exists)
}
```

### Test: SharePlay Integration
```swift
func testSharePlayConnection() throws {
    // Given: SharePlay is available

    // When: User starts SharePlay session
    app.buttons["Share with SharePlay"].tap()

    // Then: SharePlay picker appears
    let picker = app.otherElements["SharePlay Picker"]
    XCTAssert(picker.exists)

    // Note: Actual connection requires multiple devices
}
```

---

## 10. Error Handling Tests

### Test: Network Disconnection
```swift
func testNetworkDisconnectionHandling() throws {
    // Given: Collaboration session is active
    startCollaborationSession()

    // When: Network disconnects
    // Simulate using Network Link Conditioner
    simulateNetworkDisconnection()

    // Then: Offline mode indicator appears
    let offlineIndicator = app.staticTexts["Working Offline"]
    XCTAssert(offlineIndicator.waitForExistence(timeout: 5))

    // And: User can continue working
    XCTAssert(app.buttons["New Part"].isEnabled)
}
```

### Test: Low Memory Warning
```swift
func testLowMemoryWarningHandling() throws {
    // Given: Large assembly is loaded
    loadLargeAssembly(partCount: 10000)

    // When: System triggers low memory warning
    // Note: Requires manual testing or custom memory pressure simulation

    // Then: App frees memory gracefully
    // Verify app doesn't crash and maintains core functionality
}
```

---

## Test Execution Instructions

### Running All UI Tests
```bash
# In Terminal:
cd /path/to/IndustrialCADCAM
xcodebuild test -scheme IndustrialCADCAM -destination 'platform=visionOS Simulator,name=Apple Vision Pro'

# Or in Xcode:
# 1. Select IndustrialCADCAMUITests target
# 2. Press Cmd+U
# 3. Or click Product → Test
```

### Running Specific Test
```bash
xcodebuild test -scheme IndustrialCADCAM \
  -destination 'platform=visionOS Simulator,name=Apple Vision Pro' \
  -only-testing:IndustrialCADCAMUITests/IndustrialCADCAMUITests/testCreateNewProject
```

### Running on Device
```bash
xcodebuild test -scheme IndustrialCADCAM \
  -destination 'platform=visionOS,name=Your Vision Pro'
```

---

## Test Coverage Goals

- [ ] All window interactions: 100%
- [ ] Critical user flows: 100%
- [ ] Gesture recognition: 80%
- [ ] Volumetric interactions: 80%
- [ ] Immersive space: 80%
- [ ] Accessibility: 100%
- [ ] Error scenarios: 90%

---

## Notes for Test Implementation

1. **Entity Testing**: Requires custom accessibility labels on RealityKit entities
2. **Gesture Testing**: May require simulated gestures in simulator
3. **Hand Tracking**: Best tested on actual hardware
4. **Performance**: Use XCTMetric for accurate measurements
5. **Multi-Device**: Requires multiple Vision Pro devices
6. **Network**: Use Network Link Conditioner for simulation

---

**Status**: Specification complete, ready for implementation on visionOS
**Estimated Test Count**: 50+ UI tests
**Estimated Execution Time**: 20-30 minutes (full suite)
