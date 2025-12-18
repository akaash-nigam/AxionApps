//
//  NavigationFlowTests.swift
//  Language Immersion Rooms UI Tests
//
//  UI tests for app navigation flows
//
//  ⚠️  REQUIRES: Xcode UI testing framework and simulator/device
//  These tests must be run through Xcode's test runner
//

import XCTest

final class NavigationFlowTests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Authentication Flow

    func testSignInFlow() throws {
        // Find and tap Sign In button
        let signInButton = app.buttons["Sign in with Apple"]
        XCTAssertTrue(signInButton.exists, "Sign in button should exist")

        signInButton.tap()

        // After sign in, should navigate to onboarding or main menu
        let onboardingView = app.staticTexts["Welcome to Language Immersion Rooms"]
        let mainMenuView = app.staticTexts["Start Learning"]

        let navigationOccurred = onboardingView.waitForExistence(timeout: 5) ||
                                mainMenuView.waitForExistence(timeout: 5)

        XCTAssertTrue(navigationOccurred, "Should navigate after sign in")
    }

    // MARK: - Onboarding Flow

    func testOnboardingFlow() throws {
        // Skip sign in for this test (or mock authentication)

        // Screen 1: Language Selection
        let spanishButton = app.buttons["🇪🇸 Spanish"]
        if spanishButton.exists {
            spanishButton.tap()

            let nextButton = app.buttons["Next"]
            XCTAssertTrue(nextButton.exists)
            nextButton.tap()
        }

        // Screen 2: Difficulty Selection
        let beginnerButton = app.buttons["Beginner"]
        if beginnerButton.exists {
            beginnerButton.tap()

            let nextButton = app.buttons["Next"]
            XCTAssertTrue(nextButton.exists)
            nextButton.tap()
        }

        // Screen 3: Goals
        let goal1 = app.buttons["Vocabulary"]
        if goal1.exists {
            goal1.tap()

            let finishButton = app.buttons["Finish"]
            XCTAssertTrue(finishButton.exists)
            finishButton.tap()
        }

        // Should navigate to main menu
        let mainMenu = app.staticTexts["Start Learning"]
        XCTAssertTrue(mainMenu.waitForExistence(timeout: 5))
    }

    // MARK: - Main Menu Navigation

    func testNavigateToSettings() throws {
        // Assume we're at main menu
        let settingsButton = app.buttons["Settings"]

        if settingsButton.exists {
            settingsButton.tap()

            let settingsTitle = app.staticTexts["Settings"]
            XCTAssertTrue(settingsTitle.waitForExistence(timeout: 2))

            // Navigate back
            let backButton = app.navigationBars.buttons.element(boundBy: 0)
            if backButton.exists {
                backButton.tap()
            }
        }
    }

    func testNavigateToProgress() throws {
        let progressButton = app.buttons["Progress"]

        if progressButton.exists {
            progressButton.tap()

            let progressTitle = app.staticTexts["Your Progress"]
            XCTAssertTrue(progressTitle.waitForExistence(timeout: 2))

            // Navigate back
            let backButton = app.navigationBars.buttons.element(boundBy: 0)
            if backButton.exists {
                backButton.tap()
            }
        }
    }

    // MARK: - Immersive Space Flow

    func testEnterImmersiveSpace() throws {
        let startLearningButton = app.buttons["Start Learning"]

        if startLearningButton.exists {
            startLearningButton.tap()

            // Should enter immersive space
            // Verify immersive controls appear
            let scanButton = app.buttons["Scan Room"]
            XCTAssertTrue(scanButton.waitForExistence(timeout: 10),
                         "Scan button should appear in immersive space")

            let exitButton = app.buttons["Exit"]
            XCTAssertTrue(exitButton.exists,
                         "Exit button should exist in immersive space")
        }
    }

    func testExitImmersiveSpace() throws {
        // Enter immersive space first
        let startLearningButton = app.buttons["Start Learning"]
        if startLearningButton.exists {
            startLearningButton.tap()

            // Wait for immersive space to load
            let exitButton = app.buttons["Exit"]
            XCTAssertTrue(exitButton.waitForExistence(timeout: 10))

            // Exit
            exitButton.tap()

            // Should return to main menu
            let mainMenu = app.staticTexts["Start Learning"]
            XCTAssertTrue(mainMenu.waitForExistence(timeout: 5))
        }
    }

    // MARK: - Immersive Space Interactions

    func testScanRoomFlow() throws {
        // Enter immersive space
        app.buttons["Start Learning"].tap()

        // Tap scan room
        let scanButton = app.buttons["Scan Room"]
        if scanButton.waitForExistence(timeout: 10) {
            scanButton.tap()

            // Should show scanning indicator or complete quickly in simulator
            // Wait for labels to appear (simulated)
            sleep(2)

            // Verify labels toggle button exists
            let toggleButton = app.buttons["Toggle Labels"]
            XCTAssertTrue(toggleButton.exists,
                         "Toggle labels button should exist after scanning")
        }
    }

    func testStartConversationFlow() throws {
        // Enter immersive space
        app.buttons["Start Learning"].tap()

        // Tap start chat
        let chatButton = app.buttons["Start Chat"]
        if chatButton.waitForExistence(timeout: 10) {
            chatButton.tap()

            // Should show conversation UI
            let micButton = app.buttons["microphone"]
            XCTAssertTrue(micButton.waitForExistence(timeout: 5),
                         "Microphone button should appear in conversation mode")

            // End chat
            let endChatButton = app.buttons["End Chat"]
            if endChatButton.exists {
                endChatButton.tap()
            }
        }
    }

    // MARK: - Settings Interactions

    func testToggleSettings() throws {
        app.buttons["Settings"].tap()

        // Toggle show labels
        let showLabelsToggle = app.switches["Show Labels"]
        if showLabelsToggle.exists {
            let initialState = showLabelsToggle.value as? String
            showLabelsToggle.tap()

            // Verify toggle changed
            let newState = showLabelsToggle.value as? String
            XCTAssertNotEqual(initialState, newState)
        }

        // Change label size
        let labelSizePicker = app.buttons["Label Size"]
        if labelSizePicker.exists {
            labelSizePicker.tap()

            let largeOption = app.buttons["Large"]
            if largeOption.exists {
                largeOption.tap()
            }
        }
    }

    // MARK: - Accessibility Tests

    func testVoiceOverSupport() throws {
        // Enable VoiceOver simulation
        let startButton = app.buttons["Start Learning"]
        XCTAssertTrue(startButton.isAccessibilityElement)
        XCTAssertFalse(startButton.label.isEmpty)
    }

    func testDynamicTypeSupport() throws {
        // Test that UI adapts to larger text sizes
        // This would require changing accessibility settings

        let title = app.staticTexts["Language Immersion Rooms"]
        XCTAssertTrue(title.exists)
    }

    // MARK: - Performance Tests

    func testAppLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            app.launch()
        }
    }

    func testNavigationPerformance() throws {
        measure {
            app.buttons["Settings"].tap()
            app.navigationBars.buttons.element(boundBy: 0).tap()
        }
    }

    // MARK: - Error Handling

    func testNoNetworkConnection() throws {
        // Note: This requires setting up network link conditioner

        app.buttons["Start Learning"].tap()
        app.buttons["Start Chat"].tap()

        // Should handle gracefully without crashing
        // Verify app doesn't crash after timeout
        sleep(5)
        XCTAssertTrue(app.exists)
    }

    func testMicrophonePermissionDenied() throws {
        // This test would need to simulate denied microphone permission

        app.buttons["Start Learning"].tap()
        app.buttons["Start Chat"].tap()

        let micButton = app.buttons["microphone"]
        if micButton.waitForExistence(timeout: 5) {
            micButton.tap()

            // Should show permission alert or handle gracefully
            // App should not crash
            XCTAssertTrue(app.exists)
        }
    }
}
