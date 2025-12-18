//
//  OnboardingUITests.swift
//  Reality Annotation Platform UI Tests
//
//  UI tests for onboarding flow
//  REQUIRES: Xcode UI Testing on visionOS Simulator/Device
//

import XCTest

final class OnboardingUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()

        // Reset onboarding state
        app.launchArguments = ["--reset-onboarding"]
        app.launch()
    }

    // MARK: - Onboarding Flow Tests

    func testOnboardingAppearsOnFirstLaunch() throws {
        // Verify onboarding sheet appears
        let onboardingTitle = app.staticTexts["Welcome to\nReality Annotations"]
        XCTAssertTrue(onboardingTitle.waitForExistence(timeout: 5))
    }

    func testOnboardingPageNavigation() throws {
        // Wait for onboarding
        XCTAssertTrue(app.staticTexts["Welcome to\nReality Annotations"].waitForExistence(timeout: 5))

        // Tap Next button 4 times
        for _ in 1...4 {
            app.buttons["Next"].tap()
            sleep(1) // Wait for animation
        }

        // Verify we're on the last page
        XCTAssertTrue(app.buttons["Get Started"].exists)
    }

    func testOnboardingSkipButton() throws {
        // Wait for onboarding
        XCTAssertTrue(app.staticTexts["Welcome to\nReality Annotations"].waitForExistence(timeout: 5))

        // Tap Skip
        app.buttons["Skip"].tap()

        // Verify we're on the main app
        XCTAssertTrue(app.tabBars.buttons["Home"].exists)
    }

    func testOnboardingGetStarted() throws {
        // Navigate to last page
        XCTAssertTrue(app.staticTexts["Welcome to\nReality Annotations"].waitForExistence(timeout: 5))

        for _ in 1...4 {
            app.buttons["Next"].tap()
            sleep(1)
        }

        // Tap Get Started
        app.buttons["Get Started"].tap()

        // Verify we're on the main app
        XCTAssertTrue(app.tabBars.buttons["Home"].exists)
    }

    func testOnboardingDoesNotAppearOnSecondLaunch() throws {
        // Complete onboarding first
        XCTAssertTrue(app.staticTexts["Welcome to\nReality Annotations"].waitForExistence(timeout: 5))
        app.buttons["Skip"].tap()

        // Terminate and relaunch
        app.terminate()
        app.launch()

        // Onboarding should not appear
        let onboardingTitle = app.staticTexts["Welcome to\nReality Annotations"]
        XCTAssertFalse(onboardingTitle.waitForExistence(timeout: 2))

        // Should go straight to main app
        XCTAssertTrue(app.tabBars.buttons["Home"].exists)
    }
}
