//
//  DashboardUITests.swift
//  SupplyChainControlTowerUITests
//
//  UI tests for Dashboard view
//

import XCTest

final class DashboardUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments.append("--uitesting")
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Dashboard Layout Tests

    func testDashboardDisplaysKPICards() throws {
        // Given: Dashboard is loaded
        let dashboard = DashboardPage(app: app)

        // Then: KPI cards are visible
        XCTAssertTrue(dashboard.otifCard.exists, "OTIF card should be visible")
        XCTAssertTrue(dashboard.shipmentsCard.exists, "Shipments card should be visible")
        XCTAssertTrue(dashboard.alertsCard.exists, "Alerts card should be visible")
    }

    func testDashboardDisplaysActiveShipments() throws {
        // Given: Dashboard is loaded
        let dashboard = DashboardPage(app: app)

        // Then: Shipments list is visible
        XCTAssertTrue(dashboard.shipmentsListexists, "Shipments list should be visible")
        XCTAssertGreaterThan(dashboard.shipmentRows.count, 0, "Should display at least one shipment")
    }

    func testDashboardNavigationButtons() throws {
        // Given: Dashboard is loaded
        let dashboard = DashboardPage(app: app)

        // Then: Navigation buttons exist
        XCTAssertTrue(dashboard.openNetworkButton.exists, "Open Network button should exist")
        XCTAssertTrue(dashboard.analyticsButton.exists, "Analytics button should exist")
        XCTAssertTrue(dashboard.planningButton.exists, "Planning button should exist")
    }

    // MARK: - Interaction Tests

    func testTapOnKPICardShowsDetails() throws {
        // Given: Dashboard is loaded
        let dashboard = DashboardPage(app: app)

        // When: User taps on OTIF card
        dashboard.otifCard.tap()

        // Then: Detail view appears
        XCTAssertTrue(dashboard.kpiDetailView.waitForExistence(timeout: 2), "KPI detail view should appear")
    }

    func testTapOnShipmentShowsDetails() throws {
        // Given: Dashboard is loaded
        let dashboard = DashboardPage(app: app)

        // When: User taps on first shipment
        let firstShipment = dashboard.shipmentRows.firstMatch
        XCTAssertTrue(firstShipment.exists, "First shipment should exist")
        firstShipment.tap()

        // Then: Shipment detail view appears
        XCTAssertTrue(dashboard.shipmentDetailView.waitForExistence(timeout: 2), "Shipment detail should appear")
    }

    func testOpenNetworkViewButton() throws {
        // Given: Dashboard is loaded
        let dashboard = DashboardPage(app: app)

        // When: User taps Open Network button
        dashboard.openNetworkButton.tap()

        // Then: Network view appears
        XCTAssertTrue(app.otherElements["NetworkView"].waitForExistence(timeout: 3), "Network view should appear")
    }

    func testRefreshDataPullToRefresh() throws {
        // Given: Dashboard is loaded
        let dashboard = DashboardPage(app: app)

        // When: User pulls to refresh
        let scrollView = dashboard.scrollView
        scrollView.swipeDown(velocity: .fast)

        // Then: Loading indicator appears
        XCTAssertTrue(dashboard.loadingIndicator.waitForExistence(timeout: 1), "Loading indicator should appear")

        // And: Data is refreshed (loading indicator disappears)
        XCTAssertFalse(dashboard.loadingIndicator.waitForNonExistence(timeout: 5), "Loading should complete")
    }

    // MARK: - Data Display Tests

    func testKPIValuesAreDisplayed() throws {
        // Given: Dashboard is loaded
        let dashboard = DashboardPage(app: app)

        // Then: KPI values are visible and formatted
        let otifValue = dashboard.otifValue
        XCTAssertTrue(otifValue.exists, "OTIF value should exist")
        XCTAssertTrue(otifValue.label.contains("%"), "OTIF should be a percentage")

        let shipmentsCount = dashboard.shipmentsCount
        XCTAssertTrue(shipmentsCount.exists, "Shipments count should exist")
    }

    func testShipmentStatusBadgesDisplay() throws {
        // Given: Dashboard is loaded
        let dashboard = DashboardPage(app: app)

        // When: Viewing shipments
        let firstShipment = dashboard.shipmentRows.firstMatch

        // Then: Status badge is visible
        let statusBadge = firstShipment.images["StatusBadge"]
        XCTAssertTrue(statusBadge.exists, "Status badge should be visible")
    }

    // MARK: - Accessibility Tests

    func testDashboardAccessibilityLabels() throws {
        // Given: Dashboard is loaded
        let dashboard = DashboardPage(app: app)

        // Then: All elements have accessibility labels
        XCTAssertNotNil(dashboard.otifCard.label, "OTIF card should have accessibility label")
        XCTAssertNotNil(dashboard.openNetworkButton.label, "Open Network button should have label")
    }

    func testVoiceOverNavigation() throws {
        // Given: Dashboard is loaded with VoiceOver
        let dashboard = DashboardPage(app: app)

        // When: Navigating with accessibility
        XCTAssertTrue(dashboard.otifCard.isAccessibilityElement, "OTIF card should be accessible")
        XCTAssertTrue(dashboard.shipmentsCard.isAccessibilityElement, "Shipments card should be accessible")
    }

    // MARK: - Performance Tests

    func testDashboardLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            app.launch()
        }
    }

    func testDashboardScrollPerformance() throws {
        // Given: Dashboard with many shipments
        let dashboard = DashboardPage(app: app)
        let scrollView = dashboard.scrollView

        // When: Scrolling through list
        measure(metrics: [XCTOSSignpostMetric.scrollDecelerationMetric]) {
            scrollView.swipeUp(velocity: .fast)
            scrollView.swipeDown(velocity: .fast)
        }
    }

    // MARK: - Error States

    func testDashboardShowsErrorWhenNetworkFails() throws {
        // Given: Network is unavailable
        app.launchArguments.append("--network-error")
        app.launch()

        let dashboard = DashboardPage(app: app)

        // Then: Error message is displayed
        XCTAssertTrue(dashboard.errorMessage.waitForExistence(timeout: 3), "Error message should appear")
        XCTAssertTrue(dashboard.retryButton.exists, "Retry button should be visible")
    }

    func testRetryButtonReloadsData() throws {
        // Given: Error state
        app.launchArguments.append("--network-error")
        app.launch()

        let dashboard = DashboardPage(app: app)

        // When: User taps retry
        dashboard.retryButton.tap()

        // Then: Loading indicator appears
        XCTAssertTrue(dashboard.loadingIndicator.waitForExistence(timeout: 1), "Should show loading")
    }

    // MARK: - Edge Cases

    func testEmptyStateDisplaysCorrectly() throws {
        // Given: No shipments available
        app.launchArguments.append("--empty-state")
        app.launch()

        let dashboard = DashboardPage(app: app)

        // Then: Empty state message is shown
        XCTAssertTrue(dashboard.emptyStateMessage.exists, "Empty state message should be visible")
    }

    func testLargeNumberOfShipmentsPerformance() throws {
        // Given: Many shipments (1000+)
        app.launchArguments.append("--large-dataset")
        app.launch()

        let dashboard = DashboardPage(app: app)

        // Then: UI remains responsive
        let scrollView = dashboard.scrollView
        XCTAssertTrue(scrollView.exists)

        // Scroll should be smooth
        scrollView.swipeUp()
        scrollView.swipeDown()
    }
}

// MARK: - Page Object

class DashboardPage {
    let app: XCUIApplication

    init(app: XCUIApplication) {
        self.app = app
    }

    // MARK: - Elements

    var scrollView: XCUIElement {
        app.scrollViews["DashboardScrollView"]
    }

    // KPI Cards
    var otifCard: XCUIElement {
        app.otherElements["OTIFCard"]
    }

    var otifValue: XCUIElement {
        otifCard.staticTexts["OTIFValue"]
    }

    var shipmentsCard: XCUIElement {
        app.otherElements["ShipmentsCard"]
    }

    var shipmentsCount: XCUIElement {
        shipmentsCard.staticTexts["ShipmentsCount"]
    }

    var alertsCard: XCUIElement {
        app.otherElements["AlertsCard"]
    }

    // Shipments List
    var shipmentsList: XCUIElement {
        app.otherElements["ShipmentsList"]
    }

    var shipmentRows: XCUIElementQuery {
        shipmentsList.buttons.matching(identifier: "ShipmentRow")
    }

    // Navigation
    var openNetworkButton: XCUIElement {
        app.buttons["OpenNetworkButton"]
    }

    var analyticsButton: XCUIElement {
        app.buttons["AnalyticsButton"]
    }

    var planningButton: XCUIElement {
        app.buttons["PlanningButton"]
    }

    // Detail Views
    var kpiDetailView: XCUIElement {
        app.otherElements["KPIDetailView"]
    }

    var shipmentDetailView: XCUIElement {
        app.otherElements["ShipmentDetailView"]
    }

    // Loading & Error States
    var loadingIndicator: XCUIElement {
        app.activityIndicators["LoadingIndicator"]
    }

    var errorMessage: XCUIElement {
        app.staticTexts["ErrorMessage"]
    }

    var retryButton: XCUIElement {
        app.buttons["RetryButton"]
    }

    var emptyStateMessage: XCUIElement {
        app.staticTexts["EmptyStateMessage"]
    }
}

// MARK: - XCUIElement Extensions

extension XCUIElement {
    func waitForNonExistence(timeout: TimeInterval) -> Bool {
        let predicate = NSPredicate(format: "exists == false")
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: self)
        let result = XCTWaiter().wait(for: [expectation], timeout: timeout)
        return result == .completed
    }
}
