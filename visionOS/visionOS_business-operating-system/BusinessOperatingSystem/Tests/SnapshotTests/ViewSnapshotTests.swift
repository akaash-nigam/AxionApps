//
//  ViewSnapshotTests.swift
//  BusinessOperatingSystemTests
//
//  Created by BOS Team on 2025-01-20.
//

import XCTest
import SwiftUI
@testable import BusinessOperatingSystem

// MARK: - View Snapshot Tests

/// Snapshot tests for key UI components
final class ViewSnapshotTests: SnapshotTestCase {

    // MARK: - Setup

    override func setUp() {
        super.setUp()
        // Set to true to record new reference snapshots
        recordMode = false
    }

    // MARK: - Dashboard Tests

    func testDashboardToolbarOrnament() {
        let view = DashboardToolbarOrnament(selectedView: .constant(.overview))

        assertSnapshots(matching: view, configurations: [.dark, .light])
    }

    func testQuickActionsOrnament() {
        let view = QuickActionsOrnament()

        assertSnapshots(matching: view, configurations: [.dark, .light])
    }

    func testStatusOrnament() {
        let view = StatusOrnament()
            .environment(AppState())

        assertSnapshot(matching: view)
    }

    // MARK: - Immersion Control Tests

    func testImmersionLevelPicker() {
        let view = ImmersionLevelPicker()

        assertSnapshots(
            matching: view,
            configurations: [.dark, .light],
            as: "immersion_picker"
        )
    }

    func testImmersionLevelControl() {
        let view = ImmersionLevelControl()

        assertSnapshot(matching: view, as: "immersion_control")
    }

    // MARK: - Component Tests

    func testOrnamentButton() {
        let view = OrnamentButton(icon: "gear", label: "Settings")

        assertSnapshot(matching: view)
    }

    func testBreadcrumbOrnament() {
        let view = BreadcrumbOrnament(path: ["Home", "Departments", "Engineering"])

        assertSnapshot(matching: view)
    }

    // MARK: - KPI Views

    func testKPISummaryOrnament_AllHealthy() {
        let kpis = createTestKPIs(healthy: 5, warning: 0, critical: 0)
        let view = KPISummaryOrnament(kpis: kpis)

        assertSnapshot(matching: view, as: "kpi_summary_healthy")
    }

    func testKPISummaryOrnament_Mixed() {
        let kpis = createTestKPIs(healthy: 3, warning: 2, critical: 1)
        let view = KPISummaryOrnament(kpis: kpis)

        assertSnapshot(matching: view, as: "kpi_summary_mixed")
    }

    func testKPISummaryOrnament_Critical() {
        let kpis = createTestKPIs(healthy: 0, warning: 1, critical: 4)
        let view = KPISummaryOrnament(kpis: kpis)

        assertSnapshot(matching: view, as: "kpi_summary_critical")
    }

    // MARK: - Accessibility Tests

    func testDashboardToolbar_LargeText() {
        let view = DashboardToolbarOrnament(selectedView: .constant(.overview))

        assertSnapshot(
            matching: view,
            with: .largeText,
            as: "toolbar_large_text"
        )
    }

    // MARK: - Helpers

    private func createTestKPIs(healthy: Int, warning: Int, critical: Int) -> [KPI] {
        var kpis: [KPI] = []

        for i in 0..<healthy {
            kpis.append(KPI(
                id: UUID(),
                name: "Healthy KPI \(i)",
                description: "Test KPI",
                type: .performance,
                value: 1.2,
                target: 1.0,
                unit: .percentage,
                trend: .increasing,
                comparisonPeriod: .monthOverMonth
            ))
        }

        for i in 0..<warning {
            kpis.append(KPI(
                id: UUID(),
                name: "Warning KPI \(i)",
                description: "Test KPI",
                type: .performance,
                value: 0.7,
                target: 1.0,
                unit: .percentage,
                trend: .stable,
                comparisonPeriod: .monthOverMonth
            ))
        }

        for i in 0..<critical {
            kpis.append(KPI(
                id: UUID(),
                name: "Critical KPI \(i)",
                description: "Test KPI",
                type: .performance,
                value: 0.4,
                target: 1.0,
                unit: .percentage,
                trend: .decreasing,
                comparisonPeriod: .monthOverMonth
            ))
        }

        return kpis
    }
}

// MARK: - Entity Visualization Snapshot Tests

final class EntityVisualizationSnapshotTests: SnapshotTestCase {

    override func setUp() {
        super.setUp()
        recordMode = false
    }

    // Note: 3D entity snapshots require special handling in visionOS
    // These tests serve as documentation for what should be tested manually

    func testDepartmentEntityBuilder_Configuration() {
        // Verify configuration defaults
        let config = DepartmentEntityBuilder.Configuration()

        XCTAssertEqual(config.baseSize, 0.3)
        XCTAssertEqual(config.maxHeight, 0.8)
        XCTAssertTrue(config.showLabels)
        XCTAssertTrue(config.animationEnabled)
        XCTAssertTrue(config.usePooledEntities)
    }

    func testKPIEntityBuilder_Configuration() {
        let config = KPIEntityBuilder.Configuration()

        XCTAssertTrue(config.usePooledEntities)
        XCTAssertEqual(config.gaugeRadius, 0.12)
        XCTAssertEqual(config.segmentCount, 20)
    }

    func testDataFlowVisualizer_Configuration() {
        let config = DataFlowVisualizer.Configuration()

        XCTAssertTrue(config.usePooledEntities)
        XCTAssertEqual(config.arcHeight, 0.3)
        XCTAssertEqual(config.pathSteps, 30)
        XCTAssertEqual(config.particleCount, 10)
    }
}
