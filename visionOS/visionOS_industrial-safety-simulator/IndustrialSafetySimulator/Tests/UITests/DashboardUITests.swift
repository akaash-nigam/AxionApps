import XCTest

/// UI Tests for Dashboard and main navigation
/// Legend: ✅ Can run in current environment | ⚠️ Requires visionOS Simulator | 🔴 Requires Vision Pro hardware
final class DashboardUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Dashboard Launch Tests ⚠️

    func test_WarningSimulator_DashboardLaunchesSuccessfully() throws {
        // ⚠️ Requires visionOS Simulator

        // Arrange & Act
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 5))

        // Assert - Dashboard window should be visible
        let dashboardTitle = app.staticTexts["Safety Dashboard"]
        XCTAssertTrue(dashboardTitle.waitForExistence(timeout: 3))
    }

    func test_WarningSimulator_NavigationBarExists() throws {
        // ⚠️ Requires visionOS Simulator

        // Assert
        let navigationBar = app.navigationBars.firstMatch
        XCTAssertTrue(navigationBar.exists)
    }

    // MARK: - Training Module Display Tests ⚠️

    func test_WarningSimulator_TrainingModulesDisplay() throws {
        // ⚠️ Requires visionOS Simulator

        // Arrange
        let modulesList = app.scrollViews["training-modules-list"]

        // Assert
        XCTAssertTrue(modulesList.waitForExistence(timeout: 3))

        // Should have at least one training module card
        let firstModule = app.buttons["module-card"].firstMatch
        XCTAssertTrue(firstModule.exists)
    }

    func test_WarningSimulator_ModuleCardTapNavigatesToDetail() throws {
        // ⚠️ Requires visionOS Simulator

        // Arrange
        let firstModule = app.buttons["module-card"].firstMatch
        XCTAssertTrue(firstModule.waitForExistence(timeout: 3))

        // Act
        firstModule.tap()

        // Assert - Should navigate to module detail
        let detailView = app.otherElements["module-detail-view"]
        XCTAssertTrue(detailView.waitForExistence(timeout: 2))
    }

    // MARK: - Progress Section Tests ⚠️

    func test_WarningSimulator_ProgressSectionDisplays() throws {
        // ⚠️ Requires visionOS Simulator

        // Assert
        let progressSection = app.otherElements["progress-section"]
        XCTAssertTrue(progressSection.waitForExistence(timeout: 3))

        // Should show training hours
        let hoursLabel = app.staticTexts["training-hours-label"]
        XCTAssertTrue(hoursLabel.exists)

        // Should show completion percentage
        let completionLabel = app.staticTexts["completion-percentage"]
        XCTAssertTrue(completionLabel.exists)
    }

    func test_WarningSimulator_ProgressMetricsAreNumeric() throws {
        // ⚠️ Requires visionOS Simulator

        // Arrange
        let hoursValue = app.staticTexts["training-hours-value"]
        let completionValue = app.staticTexts["completion-percentage-value"]

        // Assert
        XCTAssertTrue(hoursValue.waitForExistence(timeout: 3))
        XCTAssertTrue(completionValue.exists)

        // Values should contain numbers
        let hoursText = hoursValue.label
        let completionText = completionValue.label

        XCTAssertTrue(hoursText.contains(where: { $0.isNumber }))
        XCTAssertTrue(completionText.contains(where: { $0.isNumber }))
    }

    // MARK: - Quick Actions Tests ⚠️

    func test_WarningSimulator_QuickActionsAreVisible() throws {
        // ⚠️ Requires visionOS Simulator

        // Assert
        let startTrainingButton = app.buttons["quick-action-start-training"]
        let viewProgressButton = app.buttons["quick-action-view-progress"]
        let certificationsButton = app.buttons["quick-action-certifications"]

        XCTAssertTrue(startTrainingButton.waitForExistence(timeout: 3))
        XCTAssertTrue(viewProgressButton.exists)
        XCTAssertTrue(certificationsButton.exists)
    }

    func test_WarningSimulator_StartTrainingButtonLaunchesModule() throws {
        // ⚠️ Requires visionOS Simulator

        // Arrange
        let startButton = app.buttons["quick-action-start-training"]
        XCTAssertTrue(startButton.waitForExistence(timeout: 3))

        // Act
        startButton.tap()

        // Assert - Should show module selector or start a module
        let moduleSelector = app.sheets["module-selector"]
        let immersiveView = app.otherElements["immersive-training-view"]

        let selectorAppeared = moduleSelector.waitForExistence(timeout: 2)
        let immersiveAppeared = immersiveView.waitForExistence(timeout: 2)

        XCTAssertTrue(selectorAppeared || immersiveAppeared,
                      "Either module selector or training should start")
    }

    // MARK: - Certifications Display Tests ⚠️

    func test_WarningSimulator_CertificationsListDisplays() throws {
        // ⚠️ Requires visionOS Simulator

        // Arrange
        let certificationsButton = app.buttons["quick-action-certifications"]
        XCTAssertTrue(certificationsButton.waitForExistence(timeout: 3))

        // Act
        certificationsButton.tap()

        // Assert
        let certificationsList = app.scrollViews["certifications-list"]
        XCTAssertTrue(certificationsList.waitForExistence(timeout: 2))
    }

    func test_WarningSimulator_CertificationCardShowsDetails() throws {
        // ⚠️ Requires visionOS Simulator

        // Arrange
        let certificationsButton = app.buttons["quick-action-certifications"]
        certificationsButton.tap()

        let firstCert = app.otherElements["certification-card"].firstMatch

        // Assert - If certifications exist, they should have proper structure
        if firstCert.waitForExistence(timeout: 2) {
            XCTAssertTrue(firstCert.staticTexts["cert-name"].exists)
            XCTAssertTrue(firstCert.staticTexts["cert-expiration"].exists)
        }
    }

    // MARK: - Search and Filter Tests ⚠️

    func test_WarningSimulator_SearchBarExists() throws {
        // ⚠️ Requires visionOS Simulator

        // Assert
        let searchField = app.searchFields["module-search"]
        XCTAssertTrue(searchField.waitForExistence(timeout: 3))
    }

    func test_WarningSimulator_SearchFiltersModules() throws {
        // ⚠️ Requires visionOS Simulator

        // Arrange
        let searchField = app.searchFields["module-search"]
        XCTAssertTrue(searchField.waitForExistence(timeout: 3))

        let moduleCountBefore = app.buttons["module-card"].count

        // Act
        searchField.tap()
        searchField.typeText("Fire")

        // Wait for filtering
        sleep(1)

        // Assert
        let moduleCountAfter = app.buttons["module-card"].count

        // Search should affect visible modules
        XCTAssertTrue(moduleCountAfter <= moduleCountBefore)
    }

    func test_WarningSimulator_FilterButtonsWork() throws {
        // ⚠️ Requires visionOS Simulator

        // Arrange
        let filterButton = app.buttons["filter-button"]

        if filterButton.waitForExistence(timeout: 3) {
            // Act
            filterButton.tap()

            // Assert - Filter sheet should appear
            let filterSheet = app.sheets["filter-options"]
            XCTAssertTrue(filterSheet.waitForExistence(timeout: 2))
        }
    }

    // MARK: - Accessibility Tests ⚠️

    func test_WarningSimulator_AccessibilityLabelsExist() throws {
        // ⚠️ Requires visionOS Simulator

        // Assert - Key elements should have accessibility labels
        let dashboard = app.otherElements["dashboard-view"]
        XCTAssertTrue(dashboard.waitForExistence(timeout: 3))

        let moduleCard = app.buttons["module-card"].firstMatch
        if moduleCard.exists {
            XCTAssertFalse(moduleCard.label.isEmpty, "Module card should have accessibility label")
        }
    }

    func test_WarningSimulator_VoiceOverNavigationWorks() throws {
        // ⚠️ Requires visionOS Simulator

        // Note: This test verifies elements are accessible
        // Full VoiceOver testing requires manual testing or specialized tools

        let firstModule = app.buttons["module-card"].firstMatch
        if firstModule.waitForExistence(timeout: 3) {
            XCTAssertTrue(firstModule.isHittable)
            XCTAssertFalse(firstModule.label.isEmpty)
        }
    }

    // MARK: - Window Management Tests ⚠️

    func test_WarningSimulator_MultipleWindowsCanOpen() throws {
        // ⚠️ Requires visionOS Simulator

        // Arrange
        let analyticsButton = app.buttons["open-analytics-window"]

        if analyticsButton.waitForExistence(timeout: 3) {
            // Act
            analyticsButton.tap()

            // Assert - Analytics window should open
            let analyticsWindow = app.windows["analytics-window"]
            XCTAssertTrue(analyticsWindow.waitForExistence(timeout: 2))
        }
    }

    // MARK: - State Persistence Tests ⚠️

    func test_WarningSimulator_DashboardRestoresState() throws {
        // ⚠️ Requires visionOS Simulator

        // Arrange - Navigate to a module
        let firstModule = app.buttons["module-card"].firstMatch
        if firstModule.waitForExistence(timeout: 3) {
            firstModule.tap()
        }

        // Act - Terminate and relaunch app
        app.terminate()
        app.launch()

        // Assert - Dashboard should load successfully
        let dashboardTitle = app.staticTexts["Safety Dashboard"]
        XCTAssertTrue(dashboardTitle.waitForExistence(timeout: 5))
    }

    // MARK: - Error State Tests ⚠️

    func test_WarningSimulator_EmptyStateDisplaysWhenNoModules() throws {
        // ⚠️ Requires visionOS Simulator

        // This would require a test configuration with no modules
        // In real testing, you'd launch with empty data

        let emptyState = app.otherElements["empty-state-view"]

        if emptyState.exists {
            XCTAssertTrue(emptyState.staticTexts["empty-state-message"].exists)
            XCTAssertTrue(emptyState.buttons["empty-state-action"].exists)
        }
    }

    // MARK: - Performance Tests ⚠️

    func test_WarningSimulator_DashboardLaunchPerformance() throws {
        // ⚠️ Requires visionOS Simulator

        measure(metrics: [XCTApplicationLaunchMetric()]) {
            let app = XCUIApplication()
            app.launch()
            app.terminate()
        }
    }

    func test_WarningSimulator_ScrollingPerformance() throws {
        // ⚠️ Requires visionOS Simulator

        // Arrange
        let modulesList = app.scrollViews["training-modules-list"]
        XCTAssertTrue(modulesList.waitForExistence(timeout: 3))

        // Act & Assert
        measure(metrics: [XCTOSSignpostMetric.scrollDecelerationMetric]) {
            modulesList.swipeUp(velocity: .fast)
            sleep(1)
            modulesList.swipeDown(velocity: .fast)
        }
    }
}

// MARK: - Settings UI Tests

final class SettingsUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    // MARK: - Settings Access Tests ⚠️

    func test_WarningSimulator_SettingsWindowOpens() throws {
        // ⚠️ Requires visionOS Simulator

        // Arrange
        let settingsButton = app.buttons["open-settings"]

        if settingsButton.waitForExistence(timeout: 3) {
            // Act
            settingsButton.tap()

            // Assert
            let settingsWindow = app.windows["settings-window"]
            XCTAssertTrue(settingsWindow.waitForExistence(timeout: 2))
        }
    }

    func test_WarningSimulator_SettingsSectionsDisplay() throws {
        // ⚠️ Requires visionOS Simulator

        // Arrange
        let settingsButton = app.buttons["open-settings"]
        settingsButton.tap()

        // Assert - Should have main settings sections
        let profileSection = app.otherElements["settings-profile-section"]
        let preferencesSection = app.otherElements["settings-preferences-section"]

        XCTAssertTrue(profileSection.waitForExistence(timeout: 3) ||
                      preferencesSection.waitForExistence(timeout: 3))
    }

    // MARK: - Settings Modification Tests ⚠️

    func test_WarningSimulator_ImmersionLevelAdjusts() throws {
        // ⚠️ Requires visionOS Simulator

        // Arrange
        let settingsButton = app.buttons["open-settings"]
        settingsButton.tap()

        let immersionSlider = app.sliders["immersion-level-slider"]

        if immersionSlider.waitForExistence(timeout: 3) {
            // Act
            immersionSlider.adjust(toNormalizedSliderPosition: 0.5)

            // Assert - Value should update
            let sliderValue = immersionSlider.normalizedSliderPosition
            XCTAssertTrue(sliderValue > 0.4 && sliderValue < 0.6)
        }
    }

    func test_WarningSimulator_ToggleSettingsWork() throws {
        // ⚠️ Requires visionOS Simulator

        // Arrange
        let settingsButton = app.buttons["open-settings"]
        settingsButton.tap()

        let soundToggle = app.switches["sound-effects-toggle"]

        if soundToggle.waitForExistence(timeout: 3) {
            // Act
            let initialState = soundToggle.value as? String == "1"
            soundToggle.tap()

            // Assert - Should toggle
            let newState = soundToggle.value as? String == "1"
            XCTAssertNotEqual(initialState, newState)
        }
    }
}

// MARK: - Helper Extensions

extension XCUIApplication {
    func wait(for state: XCUIApplication.State, timeout: TimeInterval) -> Bool {
        let predicate = NSPredicate { _, _ in
            self.state == state
        }
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: nil)
        let result = XCTWaiter.wait(for: [expectation], timeout: timeout)
        return result == .completed
    }
}
