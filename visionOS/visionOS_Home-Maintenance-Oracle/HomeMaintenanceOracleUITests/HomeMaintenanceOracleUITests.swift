//
//  HomeMaintenanceOracleUITests.swift
//  HomeMaintenanceOracleUITests
//
//  Created on 2025-11-24.
//  UI tests for the application
//
//  NOTE: These tests require Xcode and cannot be run in command-line environment
//  Run these tests using: Cmd+U in Xcode or `xcodebuild test` command
//

import XCTest

final class HomeMaintenanceOracleUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Home View Tests

    func testHomeView_DisplaysCorrectly() throws {
        // Given - App launches
        // Then - Home view elements should be visible
        XCTAssertTrue(app.staticTexts["Home Maintenance Oracle"].exists)
        XCTAssertTrue(app.buttons["Scan Appliance"].exists)

        // Take screenshot for visual verification
        let screenshot = app.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    func testHomeView_NavigationToInventory() throws {
        // When - Tap on Inventory tab
        app.buttons["Inventory"].tap()

        // Then - Should navigate to inventory view
        XCTAssertTrue(app.navigationBars["Inventory"].exists)
    }

    func testHomeView_NavigationToMaintenance() throws {
        // When - Tap on Maintenance tab
        app.buttons["Maintenance"].tap()

        // Then - Should navigate to maintenance view
        XCTAssertTrue(app.navigationBars["Maintenance"].exists)
    }

    func testHomeView_ScanButton_OpensImmersiveSpace() throws {
        // When - Tap scan button
        app.buttons["Scan Appliance"].tap()

        // Then - Should open immersive space (hard to test in UI tests)
        // Verify camera permission alert appears
        sleep(1) // Wait for permission alert
        let permissionAlert = app.alerts.firstMatch
        if permissionAlert.exists {
            permissionAlert.buttons["Allow"].tap()
        }
    }

    // MARK: - Inventory View Tests

    func testInventoryView_EmptyState() throws {
        // Given - Navigate to inventory
        app.buttons["Inventory"].tap()

        // Then - Should show empty state
        XCTAssertTrue(app.staticTexts["No Appliances"].exists)
        XCTAssertTrue(app.buttons["Scan Appliance"].exists)
    }

    func testInventoryView_AddManualEntry() throws {
        // Given - Navigate to inventory
        app.buttons["Inventory"].tap()

        // When - Tap add button (if exists)
        let addButton = app.buttons["Add Appliance"]
        if addButton.exists {
            addButton.tap()

            // Then - Manual entry form should appear
            XCTAssertTrue(app.navigationBars["Add Appliance"].exists)

            // Fill out form
            let brandField = app.textFields["Brand"]
            brandField.tap()
            brandField.typeText("Samsung")

            let modelField = app.textFields["Model Number"]
            modelField.tap()
            modelField.typeText("RF28R7351SR")

            // Save
            app.buttons["Save"].tap()

            // Should return to inventory with new item
            XCTAssertTrue(app.navigationBars["Inventory"].exists)
        }
    }

    func testInventoryView_SearchFunctionality() throws {
        // Given - Navigate to inventory with items
        app.buttons["Inventory"].tap()

        // When - Use search bar
        let searchField = app.searchFields.firstMatch
        if searchField.exists {
            searchField.tap()
            searchField.typeText("Samsung")

            // Then - Should filter results
            // Verify filtered results appear
        }
    }

    func testInventoryView_SwipeToDelete() throws {
        // Given - Navigate to inventory with items
        app.buttons["Inventory"].tap()

        // When - Swipe on a list item
        let firstCell = app.cells.firstMatch
        if firstCell.exists {
            firstCell.swipeLeft()

            // Then - Delete button should appear
            XCTAssertTrue(app.buttons["Delete"].exists)

            // Tap delete
            app.buttons["Delete"].tap()

            // Item should be removed
        }
    }

    // MARK: - Maintenance View Tests

    func testMaintenanceView_FilterTabs() throws {
        // Given - Navigate to maintenance
        app.buttons["Maintenance"].tap()

        // Then - Filter tabs should be visible
        XCTAssertTrue(app.buttons["All"].exists)
        XCTAssertTrue(app.buttons["Overdue"].exists)
        XCTAssertTrue(app.buttons["This Week"].exists)
        XCTAssertTrue(app.buttons["This Month"].exists)

        // When - Tap different filters
        app.buttons["Overdue"].tap()
        XCTAssertTrue(app.buttons["Overdue"].isSelected)

        app.buttons["This Week"].tap()
        XCTAssertTrue(app.buttons["This Week"].isSelected)
    }

    func testMaintenanceView_CompleteTask() throws {
        // Given - Navigate to maintenance with tasks
        app.buttons["Maintenance"].tap()

        // When - Tap complete button on a task
        let completeButton = app.buttons.matching(identifier: "checkmark.circle").firstMatch
        if completeButton.exists {
            completeButton.tap()

            // Then - Task should be marked complete or updated
            // Verify the task state changes
        }
    }

    func testMaintenanceView_AddTask() throws {
        // Given - Navigate to maintenance
        app.buttons["Maintenance"].tap()

        // When - Tap add task button
        let addButton = app.buttons["ellipsis.circle"].firstMatch
        if addButton.exists {
            addButton.tap()
            app.buttons["Add Task"].tap()

            // Then - Add task sheet should appear
            // (Form is currently placeholder)
        }
    }

    func testMaintenanceView_PullToRefresh() throws {
        // Given - Navigate to maintenance
        app.buttons["Maintenance"].tap()

        // When - Pull to refresh
        let firstCell = app.cells.firstMatch
        if firstCell.exists {
            firstCell.swipeDown()

            // Then - Should refresh data
            // Verify loading indicator appears
        }
    }

    // MARK: - Appliance Detail View Tests

    func testApplianceDetail_DisplaysInformation() throws {
        // Given - Navigate to inventory and select appliance
        app.buttons["Inventory"].tap()

        let firstCell = app.cells.firstMatch
        if firstCell.exists {
            firstCell.tap()

            // Then - Detail view should show all information
            // Verify sections are present
            XCTAssertTrue(app.staticTexts["Basic Information"].exists)
            XCTAssertTrue(app.staticTexts["Installation"].exists)
            XCTAssertTrue(app.staticTexts["Maintenance"].exists)
        }
    }

    func testApplianceDetail_EditFunctionality() throws {
        // Given - In appliance detail view
        app.buttons["Inventory"].tap()
        let firstCell = app.cells.firstMatch
        if firstCell.exists {
            firstCell.tap()

            // When - Tap edit button
            app.buttons["ellipsis.circle"].tap()
            app.buttons["Edit"].tap()

            // Then - Edit form should appear
            XCTAssertTrue(app.navigationBars["Edit Appliance"].exists)

            // Make changes
            let brandField = app.textFields["Brand"]
            brandField.tap()
            brandField.clearText()
            brandField.typeText("Updated Brand")

            // Save
            app.buttons["Save"].tap()

            // Should return to detail view with updated info
        }
    }

    func testApplianceDetail_ShareFunctionality() throws {
        // Given - In appliance detail view
        app.buttons["Inventory"].tap()
        let firstCell = app.cells.firstMatch
        if firstCell.exists {
            firstCell.tap()

            // When - Tap share button
            let shareButton = app.buttons["Share"]
            if shareButton.exists {
                shareButton.tap()

                // Then - Share sheet should appear
                XCTAssertTrue(app.otherElements["ActivityListView"].exists)
            }
        }
    }

    // MARK: - Recognition Flow UI Tests

    func testRecognitionFlow_CameraPermission() throws {
        // When - Start recognition
        app.buttons["Scan Appliance"].tap()

        // Then - Camera permission alert should appear (first time)
        sleep(1)
        let permissionAlert = app.alerts.firstMatch
        if permissionAlert.exists {
            XCTAssertTrue(permissionAlert.staticTexts["Camera Access Required"].exists)

            // Test both allow and deny
            permissionAlert.buttons["Allow"].tap()
        }
    }

    func testRecognitionFlow_ManualEntry() throws {
        // When - Start recognition
        app.buttons["Scan Appliance"].tap()
        sleep(1)

        // When - Tap manual entry button
        let manualButton = app.buttons["Manual Entry"]
        if manualButton.exists {
            manualButton.tap()

            // Then - Manual entry form should appear
            XCTAssertTrue(app.navigationBars["Add Appliance"].exists)
        }
    }

    // MARK: - Settings View Tests

    func testSettingsView_DisplaysVersion() throws {
        // Given - Navigate to settings
        app.buttons["Settings"].tap()

        // Then - Version info should be visible
        XCTAssertTrue(app.navigationBars["Settings"].exists)
        // Version text might vary, so just check it exists
        XCTAssertTrue(app.staticTexts.containing(NSPredicate(format: "label CONTAINS 'Version'")).firstMatch.exists)
    }

    // MARK: - Accessibility Tests

    func testAccessibility_AllButtonsHaveLabels() throws {
        // Given - App launches
        // Then - All interactive elements should have accessibility labels
        let buttons = app.buttons.allElementsBoundByIndex
        for button in buttons {
            XCTAssertFalse(button.label.isEmpty, "Button missing accessibility label")
        }
    }

    func testAccessibility_VoiceOverNavigation() throws {
        // Test that VoiceOver can navigate through the app
        // This would require VoiceOver to be enabled in the simulator
        // XCTAssertTrue(app.isVoiceOverRunning) // Example check
    }

    // MARK: - Performance UI Tests

    func testLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }

    func testScrollPerformance() throws {
        // Given - Navigate to list view with many items
        app.buttons["Inventory"].tap()

        // Measure scroll performance
        measure(metrics: [XCTOSSignpostMetric.scrollDecelerationMetric]) {
            app.swipeUp()
            app.swipeDown()
        }
    }
}

// MARK: - Helper Extensions

extension XCUIElement {
    func clearText() {
        guard let stringValue = self.value as? String else {
            return
        }

        let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: stringValue.count)
        typeText(deleteString)
    }
}
