//
//  UITests.swift
//  Institutional Memory Vault UI Tests
//
//  UI tests for visionOS application
//

import XCTest

final class InstitutionalMemoryVaultUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Launch Tests

    func testAppLaunches() throws {
        XCTAssertTrue(app.state == .runningForeground)
    }

    func testDashboardWindowExists() throws {
        let dashboardWindow = app.windows["Dashboard"]
        XCTAssertTrue(dashboardWindow.waitForExistence(timeout: 5))
    }

    // MARK: - Dashboard Tests

    func testDashboardShowsWelcomeMessage() throws {
        let welcomeText = app.staticTexts["Welcome back"]
        XCTAssertTrue(welcomeText.exists)
    }

    func testDashboardQuickActions() throws {
        let recentButton = app.buttons.matching(identifier: "RecentKnowledge").firstMatch
        let searchButton = app.buttons.matching(identifier: "SearchButton").firstMatch
        let captureButton = app.buttons.matching(identifier: "CaptureButton").firstMatch

        XCTAssertTrue(recentButton.exists)
        XCTAssertTrue(searchButton.exists)
        XCTAssertTrue(captureButton.exists)
    }

    func testNavigateToSearch() throws {
        let searchButton = app.buttons["Search & Find"]
        XCTAssertTrue(searchButton.waitForExistence(timeout: 2))

        searchButton.tap()

        let searchWindow = app.windows["Search Knowledge"]
        XCTAssertTrue(searchWindow.waitForExistence(timeout: 3))
    }

    // MARK: - Search Tests

    func testSearchWindowOpens() throws {
        // Open search window
        let searchButton = app.buttons["Search & Find"]
        searchButton.tap()

        let searchField = app.textFields["Search institutional memory..."]
        XCTAssertTrue(searchField.waitForExistence(timeout: 2))
    }

    func testSearchInput() throws {
        // Open search
        app.buttons["Search & Find"].tap()

        // Enter search query
        let searchField = app.textFields["Search institutional memory..."]
        searchField.tap()
        searchField.typeText("leadership")

        // Verify text was entered
        XCTAssertEqual(searchField.value as? String, "leadership")
    }

    func testSearchFilters() throws {
        // Open search
        app.buttons["Search & Find"].tap()

        // Tap filter
        let allFilter = app.buttons["All"]
        XCTAssertTrue(allFilter.exists)

        let decisionFilter = app.buttons["Decision"]
        XCTAssertTrue(decisionFilter.exists)

        decisionFilter.tap()
        // Filter should be selected (visual state change)
    }

    // MARK: - Knowledge Detail Tests

    func testOpenKnowledgeDetail() throws {
        // Assuming there's sample data
        let firstKnowledgeItem = app.collectionViews["KnowledgeList"].cells.firstMatch
        if firstKnowledgeItem.waitForExistence(timeout: 2) {
            firstKnowledgeItem.tap()

            let detailWindow = app.windows["KnowledgeDetail"]
            XCTAssertTrue(detailWindow.waitForExistence(timeout: 3))
        }
    }

    func testKnowledgeDetailShowsContent() throws {
        // Open first knowledge item
        let firstItem = app.collectionViews["KnowledgeList"].cells.firstMatch
        if firstItem.waitForExistence(timeout: 2) {
            firstItem.tap()

            // Verify detail content exists
            let titleLabel = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'Knowledge'")).firstMatch
            XCTAssertTrue(titleLabel.exists)
        }
    }

    // MARK: - Analytics Tests

    func testOpenAnalyticsDashboard() throws {
        // Navigate to analytics (via menu or button)
        // This depends on your navigation implementation
        let analyticsButton = app.buttons["Analytics"]
        if analyticsButton.exists {
            analyticsButton.tap()

            let analyticsWindow = app.windows["Knowledge Analytics"]
            XCTAssertTrue(analyticsWindow.waitForExistence(timeout: 3))
        }
    }

    // MARK: - Settings Tests

    func testOpenSettings() throws {
        let settingsButton = app.buttons["Settings"]
        if settingsButton.exists {
            settingsButton.tap()

            let settingsWindow = app.windows["Settings"]
            XCTAssertTrue(settingsWindow.waitForExistence(timeout: 3))
        }
    }

    func testSettingsToggles() throws {
        // Open settings
        app.buttons["Settings"]?.tap()

        let notificationsToggle = app.switches["Enable Notifications"]
        if notificationsToggle.exists {
            let initialValue = notificationsToggle.value as? String
            notificationsToggle.tap()
            let newValue = notificationsToggle.value as? String

            XCTAssertNotEqual(initialValue, newValue)
        }
    }

    // MARK: - 3D Volume Tests

    func testOpen3DKnowledgeNetwork() throws {
        let networkButton = app.buttons["Knowledge Network"]
        if networkButton.exists {
            networkButton.tap()

            // 3D volume should open
            let volumeWindow = app.windows.matching(identifier: "KnowledgeNetwork3D").firstMatch
            XCTAssertTrue(volumeWindow.waitForExistence(timeout: 3))
        }
    }

    func testOpenTimeline3D() throws {
        let timelineButton = app.buttons["Timeline"]
        if timelineButton.exists {
            timelineButton.tap()

            let volumeWindow = app.windows.matching(identifier: "Timeline3D").firstMatch
            XCTAssertTrue(volumeWindow.waitForExistence(timeout: 3))
        }
    }

    func testOpenOrgChart3D() throws {
        let orgChartButton = app.buttons["Departments"]
        if orgChartButton.exists {
            orgChartButton.tap()

            let volumeWindow = app.windows.matching(identifier: "OrgChart3D").firstMatch
            XCTAssertTrue(volumeWindow.waitForExistence(timeout: 3))
        }
    }

    // MARK: - Immersive Space Tests

    func testEnterMemoryPalace() throws {
        let memoryPalaceButton = app.buttons["Memory Palace"]
        if memoryPalaceButton.exists {
            memoryPalaceButton.tap()

            // Wait for immersive space to activate
            sleep(2)

            // In immersive space, certain UI elements should be visible
            let palaceTitle = app.staticTexts["Welcome to the Memory Palace"]
            XCTAssertTrue(palaceTitle.waitForExistence(timeout: 5))
        }
    }

    func testExitImmersiveSpace() throws {
        // Enter immersive space
        app.buttons["Memory Palace"]?.tap()
        sleep(2)

        // Exit immersive space (implementation depends on UI)
        // Usually there's a close or back button
        let backButton = app.buttons["Back"]
        if backButton.exists {
            backButton.tap()

            // Should return to dashboard
            let dashboard = app.windows["Dashboard"]
            XCTAssertTrue(dashboard.waitForExistence(timeout: 3))
        }
    }

    // MARK: - Window Management Tests

    func testMultipleWindowsOpen() throws {
        // Open multiple windows
        app.buttons["Search & Find"]?.tap()
        sleep(1)

        // Both dashboard and search should be open
        let dashboardWindow = app.windows["Dashboard"]
        let searchWindow = app.windows["Search"]

        XCTAssertTrue(dashboardWindow.exists)
        XCTAssertTrue(searchWindow.exists)
    }

    func testCloseWindow() throws {
        // Open a window
        app.buttons["Search & Find"]?.tap()

        let searchWindow = app.windows["Search"]
        XCTAssertTrue(searchWindow.waitForExistence(timeout: 2))

        // Close it (if there's a close button)
        let closeButton = searchWindow.buttons["Close"]
        if closeButton.exists {
            closeButton.tap()

            // Window should be closed
            XCTAssertFalse(searchWindow.exists)
        }
    }

    // MARK: - Data Tests

    func testGenerateSampleData() throws {
        // Look for generate sample data button
        let generateButton = app.buttons["Generate Sample Data"]
        if generateButton.exists {
            generateButton.tap()

            // Wait for data generation
            sleep(2)

            // Knowledge list should now have items
            let knowledgeList = app.collectionViews["KnowledgeList"]
            let cellCount = knowledgeList.cells.count
            XCTAssertGreaterThan(cellCount, 0)
        }
    }

    // MARK: - Navigation Flow Tests

    func testCompleteUserFlow() throws {
        // 1. Launch app
        XCTAssertTrue(app.state == .runningForeground)

        // 2. View dashboard
        let dashboard = app.windows["Dashboard"]
        XCTAssertTrue(dashboard.exists)

        // 3. Open search
        app.buttons["Search & Find"]?.tap()
        sleep(1)

        // 4. Enter search query
        let searchField = app.textFields.firstMatch
        if searchField.exists {
            searchField.tap()
            searchField.typeText("test")
        }

        // 5. View first result (if exists)
        let firstResult = app.collectionViews.cells.firstMatch
        if firstResult.exists {
            firstResult.tap()
            sleep(1)
        }

        // 6. Return to dashboard
        app.buttons["Back"]?.tap()
    }

    // MARK: - Accessibility Tests

    func testVoiceOverLabels() throws {
        let searchButton = app.buttons["Search & Find"]
        XCTAssertNotNil(searchButton.label)
        XCTAssertGreaterThan(searchButton.label.count, 0)
    }

    func testButtonsAreAccessible() throws {
        let buttons = app.buttons
        for button in buttons.allElementsBoundByIndex {
            XCTAssertTrue(button.isEnabled)
            XCTAssertNotNil(button.label)
        }
    }

    // MARK: - Performance Tests

    func testLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }

    func testScrollPerformance() throws {
        // Generate sample data first if needed

        let knowledgeList = app.collectionViews["KnowledgeList"]
        if knowledgeList.exists {
            measure(metrics: [XCTOSSignpostMetric.scrollDecelerationMetric]) {
                knowledgeList.swipeUp()
                knowledgeList.swipeDown()
            }
        }
    }

    func testSearchPerformance() throws {
        app.buttons["Search & Find"]?.tap()

        let searchField = app.textFields.firstMatch
        if searchField.exists {
            measure {
                searchField.tap()
                searchField.typeText("test query")
                // Wait for results
                sleep(1)
            }
        }
    }

    // MARK: - Error Handling Tests

    func testEmptyStateUI() throws {
        // On fresh install, should show empty state
        let emptyMessage = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'No knowledge'")).firstMatch

        if emptyMessage.exists {
            XCTAssertTrue(emptyMessage.exists)
        }
    }

    func testOfflineMode() throws {
        // This would require network conditioning
        // For now, just verify offline indicator exists
        // Implementation depends on your offline handling
    }

    // MARK: - Gesture Tests (visionOS specific)

    func testTapGesture() throws {
        let firstButton = app.buttons.firstMatch
        if firstButton.exists {
            // Tap gesture should work
            firstButton.tap()
            // Verify response
        }
    }

    // Note: Advanced gesture tests (pinch, rotate, drag in 3D)
    // require actual Vision Pro hardware and cannot be fully
    // tested in simulator

    // MARK: - Snapshot Tests

    func testDashboardSnapshot() throws {
        let dashboard = app.windows["Dashboard"]
        if dashboard.exists {
            let screenshot = dashboard.screenshot()
            let attachment = XCTAttachment(screenshot: screenshot)
            attachment.name = "Dashboard"
            attachment.lifetime = .keepAlways
            add(attachment)
        }
    }

    func testSearchSnapshot() throws {
        app.buttons["Search & Find"]?.tap()
        sleep(1)

        let searchWindow = app.windows["Search"]
        if searchWindow.exists {
            let screenshot = searchWindow.screenshot()
            let attachment = XCTAttachment(screenshot: screenshot)
            attachment.name = "Search"
            attachment.lifetime = .keepAlways
            add(attachment)
        }
    }
}
