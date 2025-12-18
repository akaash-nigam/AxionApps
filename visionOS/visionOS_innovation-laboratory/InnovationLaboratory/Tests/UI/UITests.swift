import XCTest

// MARK: - UI Tests for visionOS
// NOTE: These tests require Apple Vision Pro hardware or visionOS Simulator

final class InnovationLaboratoryUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    // MARK: - Dashboard Tests

    func testDashboardLaunches() throws {
        // Verify dashboard window appears
        let dashboard = app.windows["Dashboard"]
        XCTAssertTrue(dashboard.waitForExistence(timeout: 5))

        // Verify key elements exist
        XCTAssertTrue(app.staticTexts["Innovation Dashboard"].exists)
        XCTAssertTrue(app.buttons["New Idea"].exists)
    }

    func testNavigationBetweenTabs() throws {
        // Given - Dashboard is shown
        XCTAssertTrue(app.windows["Dashboard"].exists)

        // When - Tap Ideas tab
        app.buttons["Ideas"].tap()

        // Then - Ideas list should be visible
        XCTAssertTrue(app.staticTexts["All Ideas"].exists)

        // When - Tap Prototypes tab
        app.buttons["Prototypes"].tap()

        // Then - Prototypes view should be visible
        XCTAssertTrue(app.staticTexts["Prototypes"].exists)
    }

    // MARK: - Idea Creation Tests

    func testCreateNewIdea() throws {
        // Given - Dashboard is shown
        XCTAssertTrue(app.windows["Dashboard"].exists)

        // When - Tap New Idea button
        app.buttons["New Idea"].tap()

        // Then - Idea capture window should appear
        let captureWindow = app.windows["IdeaCapture"]
        XCTAssertTrue(captureWindow.waitForExistence(timeout: 2))

        // When - Fill in idea details
        let titleField = app.textFields["Idea Title"]
        titleField.tap()
        titleField.typeText("Test Idea from UI Test")

        let descriptionField = app.textViews["Description"]
        descriptionField.tap()
        descriptionField.typeText("This is a test idea created from UI tests")

        // Select category
        app.buttons["Category: Product"].tap()

        // Set priority
        app.buttons["Priority: 4 stars"].tap()

        // When - Submit
        app.buttons["Submit"].tap()

        // Then - Should return to dashboard
        XCTAssertTrue(app.windows["Dashboard"].waitForExistence(timeout: 2))

        // And - Idea should appear in list
        XCTAssertTrue(app.staticTexts["Test Idea from UI Test"].exists)
    }

    func testIdeaCaptureValidation() throws {
        // Given - Open idea capture
        app.buttons["New Idea"].tap()

        // When - Try to submit without filling required fields
        let submitButton = app.buttons["Submit"]

        // Then - Submit should be disabled
        XCTAssertFalse(submitButton.isEnabled)

        // When - Fill in title only
        app.textFields["Idea Title"].tap()
        app.textFields["Idea Title"].typeText("Test")

        // Then - Submit still disabled (need description)
        XCTAssertFalse(submitButton.isEnabled)

        // When - Fill in description
        app.textViews["Description"].tap()
        app.textViews["Description"].typeText("Test description")

        // Then - Submit should be enabled
        XCTAssertTrue(submitButton.isEnabled)
    }

    func testIdeaTagManagement() throws {
        // Given - Idea capture is open
        app.buttons["New Idea"].tap()

        // When - Add tags
        let tagField = app.textFields["Add tag"]
        tagField.tap()
        tagField.typeText("innovation")
        app.keyboards.buttons["return"].tap()

        // Then - Tag should appear
        XCTAssertTrue(app.staticTexts["#innovation"].exists)

        // When - Add another tag
        tagField.tap()
        tagField.typeText("AI")
        app.keyboards.buttons["return"].tap()

        // Then - Both tags visible
        XCTAssertTrue(app.staticTexts["#innovation"].exists)
        XCTAssertTrue(app.staticTexts["#AI"].exists)

        // When - Remove first tag
        app.buttons.matching(identifier: "Remove tag: innovation").element.tap()

        // Then - Only second tag remains
        XCTAssertFalse(app.staticTexts["#innovation"].exists)
        XCTAssertTrue(app.staticTexts["#AI"].exists)
    }

    // MARK: - Search and Filter Tests

    func testSearchIdeas() throws {
        // Given - Ideas view is shown
        app.buttons["Ideas"].tap()

        // When - Type in search field
        let searchField = app.searchFields["Search ideas"]
        searchField.tap()
        searchField.typeText("AI")

        // Then - Only matching ideas should be visible
        // (Assuming "AI" ideas exist)
        let ideaCards = app.otherElements.matching(identifier: "IdeaCard").count
        XCTAssertGreaterThan(ideaCards, 0)
    }

    func testFilterByCategory() throws {
        // Given - Ideas view
        app.buttons["Ideas"].tap()

        // When - Open filter menu
        app.buttons["Filter"].tap()

        // And - Select product category
        app.menuItems["Product"].tap()

        // Then - Only product ideas visible
        // Verify filter is applied
        XCTAssertTrue(app.staticTexts["Category: Product"].exists)
    }

    // MARK: - Prototype Studio Tests (3D Volume)

    func testOpenPrototypeStudio() throws {
        // Given - Dashboard is shown
        XCTAssertTrue(app.windows["Dashboard"].exists)

        // When - Open prototype studio
        app.buttons["Prototype Studio"].tap()

        // Then - Volume should open
        let studioVolume = app.otherElements["PrototypeStudio"]
        XCTAssertTrue(studioVolume.waitForExistence(timeout: 3))

        // And - Controls should be visible
        XCTAssertTrue(app.buttons["Add Model"].exists)
        XCTAssertTrue(app.buttons["Run Simulation"].exists)
    }

    func testPrototypeManipulation() throws {
        // NOTE: Requires Vision Pro hardware for gesture testing
        // Given - Prototype studio is open
        app.buttons["Prototype Studio"].tap()
        XCTAssertTrue(app.otherElements["PrototypeStudio"].waitForExistence(timeout: 3))

        // When - Add a model
        app.buttons["Add Model"].tap()

        // Then - Model should be visible in 3D space
        let prototype = app.otherElements.matching(identifier: "Prototype3DModel").element
        XCTAssertTrue(prototype.waitForExistence(timeout: 2))

        // Spatial manipulation would require hand tracking
        // which can only be tested on device
    }

    // MARK: - Immersive Space Tests

    func testEnterInnovationUniverse() throws {
        // Given - Dashboard is shown
        XCTAssertTrue(app.windows["Dashboard"].exists)

        // When - Enter immersive space
        app.buttons["Enter Universe"].tap()

        // Then - Immersive space should open
        let universeSpace = app.otherElements["InnovationUniverse"]
        XCTAssertTrue(universeSpace.waitForExistence(timeout: 5))

        // And - Zone selector should be visible
        XCTAssertTrue(app.staticTexts["Innovation Universe"].exists)
    }

    func testNavigateBetweenZones() throws {
        // Given - Immersive space is open
        app.buttons["Enter Universe"].tap()
        XCTAssertTrue(app.otherElements["InnovationUniverse"].waitForExistence(timeout: 5))

        // When - Select different zones
        let zonePicker = app.segmentedControls["Zone"]
        zonePicker.buttons["Idea Galaxy"].tap()

        // Then - Zone should change
        // (Visual verification would require device testing)
        XCTAssertTrue(zonePicker.buttons["Idea Galaxy"].isSelected)

        // When - Switch to prototype workshop
        zonePicker.buttons["Prototype Workshop"].tap()

        // Then
        XCTAssertTrue(zonePicker.buttons["Prototype Workshop"].isSelected)
    }

    func testIdeaNodeInteraction() throws {
        // NOTE: Requires Vision Pro for spatial tap gestures
        // Given - Innovation universe is open and showing idea galaxy
        app.buttons["Enter Universe"].tap()
        XCTAssertTrue(app.otherElements["InnovationUniverse"].waitForExistence(timeout: 5))

        // Idea nodes would be 3D entities
        // Interaction testing requires device with hand/eye tracking
    }

    // MARK: - Accessibility Tests

    func testVoiceOverSupport() throws {
        // Enable VoiceOver
        // Note: This would need to be configured in test environment

        // Verify all interactive elements have labels
        let newIdeaButton = app.buttons["New Idea"]
        XCTAssertNotNil(newIdeaButton.label)
        XCTAssertFalse(newIdeaButton.label.isEmpty)

        // Verify hint text exists
        XCTAssertNotNil(newIdeaButton.value)
    }

    func testDynamicTypeSupport() throws {
        // Test various dynamic type sizes
        // Would need to change system settings programmatically
        // or test in different configurations

        XCTAssertTrue(app.staticTexts["Innovation Dashboard"].exists)
    }

    func testKeyboardNavigation() throws {
        // Verify tab navigation works
        // Press tab to move between elements
        app.typeKey(.tab, modifierFlags: [])

        // Verify focus moves
        // (Specific implementation depends on focus system)
    }

    // MARK: - Collaboration Tests

    func testStartCollaboration() throws {
        // Given - Dashboard is shown
        XCTAssertTrue(app.windows["Dashboard"].exists)

        // When - Start collaboration
        app.buttons["Start Collaboration"].tap()

        // Then - Collaboration session should start
        // (Would require SharePlay to be testable)
    }

    // MARK: - Analytics Dashboard Tests

    func testViewAnalytics() throws {
        // Given - Dashboard is shown
        app.buttons["Analytics"].tap()

        // Then - Analytics view should show metrics
        XCTAssertTrue(app.staticTexts["Innovation Analytics"].exists)
        XCTAssertTrue(app.staticTexts["Total Ideas"].exists)
        XCTAssertTrue(app.staticTexts["Prototypes"].exists)
    }

    // MARK: - Settings Tests

    func testOpenSettings() throws {
        // Given - Dashboard is shown
        XCTAssertTrue(app.windows["Dashboard"].exists)

        // When - Open settings
        // (Depends on navigation implementation)
        app.buttons.matching(identifier: "Settings").element.tap()

        // Then - Settings window should open
        let settingsWindow = app.windows["ControlPanel"]
        XCTAssertTrue(settingsWindow.waitForExistence(timeout: 2))
    }

    // MARK: - Window Management Tests

    func testMultipleWindows() throws {
        // Given - Dashboard is open
        XCTAssertTrue(app.windows["Dashboard"].exists)

        // When - Open idea capture
        app.buttons["New Idea"].tap()

        // Then - Both windows should exist
        XCTAssertTrue(app.windows["Dashboard"].exists)
        XCTAssertTrue(app.windows["IdeaCapture"].exists)

        // When - Close idea capture
        app.windows["IdeaCapture"].buttons["Cancel"].tap()

        // Then - Only dashboard remains
        XCTAssertTrue(app.windows["Dashboard"].exists)
        XCTAssertFalse(app.windows["IdeaCapture"].exists)
    }

    // MARK: - Performance Tests

    func testAppLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            app.launch()
        }
    }

    func testScrollPerformance() throws {
        // Given - Ideas list with many items
        app.buttons["Ideas"].tap()

        // Measure scrolling performance
        measure(metrics: [XCTOSSignpostMetric.scrollingMetric]) {
            let ideasList = app.collectionViews["IdeasList"]
            ideasList.swipeUp()
            ideasList.swipeDown()
        }
    }
}

// MARK: - Test Helpers
extension InnovationLaboratoryUITests {

    func createTestIdea(title: String, description: String) {
        app.buttons["New Idea"].tap()
        app.textFields["Idea Title"].tap()
        app.textFields["Idea Title"].typeText(title)
        app.textViews["Description"].tap()
        app.textViews["Description"].typeText(description)
        app.buttons["Submit"].tap()
    }

    func waitForWindowToAppear(_ identifier: String, timeout: TimeInterval = 5) -> Bool {
        let window = app.windows[identifier]
        return window.waitForExistence(timeout: timeout)
    }

    func dismissKeyboard() {
        app.keyboards.buttons["Done"].tap()
    }
}
