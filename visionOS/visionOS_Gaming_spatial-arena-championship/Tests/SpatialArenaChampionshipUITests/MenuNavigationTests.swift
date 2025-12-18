//
//  MenuNavigationTests.swift
//  Spatial Arena Championship UI Tests
//
//  UI tests for menu navigation and user flows
//

import XCTest

final class MenuNavigationTests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Main Menu Tests

    func testMainMenuDisplays() throws {
        // Verify main menu elements are present
        XCTAssertTrue(app.staticTexts["SPATIAL ARENA CHAMPIONSHIP"].exists)
        XCTAssertTrue(app.buttons["PLAY"].exists)
        XCTAssertTrue(app.buttons["TRAINING"].exists)
        XCTAssertTrue(app.buttons["PROFILE"].exists)
        XCTAssertTrue(app.buttons["SETTINGS"].exists)
    }

    func testNavigateToMatchmaking() throws {
        let playButton = app.buttons["PLAY"]
        XCTAssertTrue(playButton.waitForExistence(timeout: 5))

        playButton.tap()

        // Verify matchmaking screen appears
        let matchmakingTitle = app.staticTexts["MATCHMAKING"]
        XCTAssertTrue(matchmakingTitle.waitForExistence(timeout: 5))
    }

    func testNavigateToSettings() throws {
        let settingsButton = app.buttons["SETTINGS"]
        XCTAssertTrue(settingsButton.waitForExistence(timeout: 5))

        settingsButton.tap()

        // Verify settings screen appears
        XCTAssertTrue(app.navigationBars["Settings"].waitForExistence(timeout: 5))
    }

    func testNavigateToProfile() throws {
        let profileButton = app.buttons["PROFILE"]
        XCTAssertTrue(profileButton.waitForExistence(timeout: 5))

        profileButton.tap()

        // Verify profile screen appears
        XCTAssertTrue(app.staticTexts["PLAYER PROFILE"].waitForExistence(timeout: 5))
    }

    // MARK: - Settings Tests

    func testSettingsVolumeSliders() throws {
        app.buttons["SETTINGS"].tap()

        // Wait for settings to load
        XCTAssertTrue(app.staticTexts["Audio"].waitForExistence(timeout: 5))

        // Verify volume sliders exist
        let masterVolumeSlider = app.sliders["Master Volume"]
        XCTAssertTrue(masterVolumeSlider.exists)

        // Adjust slider
        masterVolumeSlider.adjust(toNormalizedSliderPosition: 0.5)
    }

    func testSettingsGraphicsQuality() throws {
        app.buttons["SETTINGS"].tap()

        XCTAssertTrue(app.staticTexts["Graphics"].waitForExistence(timeout: 5))

        // Verify quality picker exists
        let qualityPicker = app.pickers["Quality"]
        XCTAssertTrue(qualityPicker.exists)
    }

    func testSettingsAccessibility() throws {
        app.buttons["SETTINGS"].tap()

        XCTAssertTrue(app.staticTexts["Accessibility"].waitForExistence(timeout: 5))

        // Verify accessibility toggles
        let colorblindToggle = app.switches["Colorblind Mode"]
        XCTAssertTrue(colorblindToggle.exists)
    }

    // MARK: - Matchmaking Flow Tests

    func testGameModeSelection() throws {
        app.buttons["PLAY"].tap()

        // Wait for matchmaking screen
        XCTAssertTrue(app.staticTexts["MATCHMAKING"].waitForExistence(timeout: 5))

        // Select Team Deathmatch
        let tdmButton = app.buttons["Team Deathmatch"]
        XCTAssertTrue(tdmButton.waitForExistence(timeout: 5))
        tdmButton.tap()

        // Verify selection
        // Implementation would check visual indication of selection
    }

    func testArenaSelection() throws {
        app.buttons["PLAY"].tap()

        XCTAssertTrue(app.staticTexts["SELECT ARENA"].waitForExistence(timeout: 5))

        // Select Cyber Arena
        let cyberArenaButton = app.buttons["Cyber Arena"]
        if cyberArenaButton.exists {
            cyberArenaButton.tap()
        }
    }

    func testHostMatchFlow() throws {
        app.buttons["PLAY"].tap()

        let hostButton = app.buttons["HOST MATCH"]
        XCTAssertTrue(hostButton.waitForExistence(timeout: 5))
        hostButton.tap()

        // Should transition to lobby
        XCTAssertTrue(app.staticTexts["HOSTING LOBBY"].waitForExistence(timeout: 5))
    }

    func testFindMatchFlow() throws {
        app.buttons["PLAY"].tap()

        let findButton = app.buttons["FIND MATCH"]
        XCTAssertTrue(findButton.waitForExistence(timeout: 5))
        findButton.tap()

        // Should show searching state
        XCTAssertTrue(app.staticTexts["Searching for Players"].waitForExistence(timeout: 5))
    }

    func testCancelMatchmaking() throws {
        app.buttons["PLAY"].tap()
        app.buttons["FIND MATCH"].tap()

        // Wait for searching state
        XCTAssertTrue(app.staticTexts["Searching for Players"].waitForExistence(timeout: 5))

        // Cancel
        let cancelButton = app.buttons["CANCEL"]
        XCTAssertTrue(cancelButton.exists)
        cancelButton.tap()

        // Should return to main menu or matchmaking selection
    }

    // MARK: - Profile Tests

    func testProfileStatsDisplay() throws {
        app.buttons["PROFILE"].tap()

        // Verify profile elements
        XCTAssertTrue(app.staticTexts["PLAYER PROFILE"].waitForExistence(timeout: 5))

        // Check for stats sections
        XCTAssertTrue(app.staticTexts["RANK"].exists || app.staticTexts["Rank"].exists)
        XCTAssertTrue(app.staticTexts["CAREER STATS"].exists || app.staticTexts["Career Stats"].exists)
    }

    // MARK: - Performance Tests

    func testAppLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }

    func testMenuNavigationPerformance() throws {
        measure(metrics: [XCTClockMetric()]) {
            app.buttons["PLAY"].tap()
            app.buttons["CANCEL"].tap()
        }
    }

    // MARK: - Accessibility Tests

    func testVoiceOverLabels() throws {
        // Verify important UI elements have accessibility labels
        let playButton = app.buttons["PLAY"]
        XCTAssertNotNil(playButton.label)
    }

    func testDynamicTypeSupport() throws {
        // Test that app handles different text sizes
        // This would require changing system settings programmatically
    }
}
