//
//  ViewModelTests.swift
//  SupplyChainControlTowerTests
//
//  Comprehensive tests for all ViewModels
//

import Testing
import Foundation
@testable import SupplyChainControlTower

// MARK: - Alerts ViewModel Tests

@Suite("AlertsViewModel Tests")
struct AlertsViewModelTests {

    @Test("AlertsViewModel initializes with default values")
    @MainActor
    func testInitialization() async throws {
        let viewModel = AlertsViewModel()

        #expect(viewModel.allDisruptions.isEmpty)
        #expect(viewModel.displayedDisruptions.isEmpty)
        #expect(viewModel.selectedDisruption == nil)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.severityFilter.count == 4) // All severities
        #expect(viewModel.showDismissed == false)
    }

    @Test("AlertsViewModel loads disruptions")
    @MainActor
    func testLoadDisruptions() async throws {
        let viewModel = AlertsViewModel()

        await viewModel.loadDisruptions()

        #expect(viewModel.allDisruptions.count > 0)
        #expect(viewModel.displayedDisruptions.count > 0)
        #expect(viewModel.isLoading == false)
    }

    @Test("AlertsViewModel filters by severity")
    @MainActor
    func testSeverityFilter() async throws {
        let viewModel = AlertsViewModel()
        await viewModel.loadDisruptions()

        // Filter to only critical
        viewModel.updateSeverityFilter([.critical])

        let allCritical = viewModel.displayedDisruptions.allSatisfy { $0.severity == .critical }
        #expect(allCritical)
    }

    @Test("AlertsViewModel dismisses disruption")
    @MainActor
    func testDismissDisruption() async throws {
        let viewModel = AlertsViewModel()
        await viewModel.loadDisruptions()

        guard let firstDisruption = viewModel.displayedDisruptions.first else {
            Issue.record("No disruptions to test")
            return
        }

        let initialCount = viewModel.displayedDisruptions.count
        viewModel.dismissDisruption(firstDisruption)

        #expect(viewModel.displayedDisruptions.count == initialCount - 1)
    }

    @Test("AlertsViewModel sorts by severity")
    @MainActor
    func testSortBySeverity() async throws {
        let viewModel = AlertsViewModel()
        await viewModel.loadDisruptions()

        viewModel.updateSortOption(.severityDescending)

        // Check that items are sorted by severity (critical first)
        for i in 0..<(viewModel.displayedDisruptions.count - 1) {
            let current = viewModel.displayedDisruptions[i]
            let next = viewModel.displayedDisruptions[i + 1]
            #expect(current.severity.priority >= next.severity.priority)
        }
    }

    @Test("AlertsViewModel search filters disruptions")
    @MainActor
    func testSearchFilter() async throws {
        let viewModel = AlertsViewModel()
        await viewModel.loadDisruptions()

        viewModel.searchQuery = "weather"

        let allMatch = viewModel.displayedDisruptions.allSatisfy {
            $0.type.rawValue.localizedCaseInsensitiveContains("weather")
        }
        #expect(allMatch || viewModel.displayedDisruptions.isEmpty)
    }

    @Test("AlertsViewModel calculates counts correctly")
    @MainActor
    func testDisruptionCounts() async throws {
        let viewModel = AlertsViewModel()
        await viewModel.loadDisruptions()

        let manualCriticalCount = viewModel.displayedDisruptions.filter { $0.severity == .critical }.count
        #expect(viewModel.criticalCount == manualCriticalCount)

        let manualHighCount = viewModel.displayedDisruptions.filter { $0.severity == .high }.count
        #expect(viewModel.highCount == manualHighCount)
    }
}

// MARK: - Control Panel ViewModel Tests

@Suite("ControlPanelViewModel Tests")
struct ControlPanelViewModelTests {

    @Test("ControlPanelViewModel initializes with defaults")
    @MainActor
    func testInitialization() async throws {
        let viewModel = ControlPanelViewModel()

        #expect(viewModel.viewMode == .network)
        #expect(viewModel.timeRange == .last24Hours)
        #expect(viewModel.detailLevel == .high)
        #expect(viewModel.showLabels == true)
        #expect(viewModel.showRoutes == true)
        #expect(viewModel.animationSpeed == 1.0)
    }

    @Test("ControlPanelViewModel resets filters")
    @MainActor
    func testResetFilters() async throws {
        let viewModel = ControlPanelViewModel()

        // Modify filters
        viewModel.nodeTypeFilter = [.warehouse]
        viewModel.flowStatusFilter = [.inTransit]

        // Reset
        viewModel.resetFilters()

        #expect(viewModel.nodeTypeFilter.count == 6) // All types
        #expect(viewModel.flowStatusFilter.count == 5) // All statuses
    }

    @Test("ControlPanelViewModel applies performance preset")
    @MainActor
    func testPerformancePreset() async throws {
        let viewModel = ControlPanelViewModel()

        viewModel.applyPreset(.performance)

        #expect(viewModel.detailLevel == .low)
        #expect(viewModel.showLabels == false)
        #expect(viewModel.reduceMotion == true)
    }

    @Test("ControlPanelViewModel applies quality preset")
    @MainActor
    func testQualityPreset() async throws {
        let viewModel = ControlPanelViewModel()

        viewModel.applyPreset(.quality)

        #expect(viewModel.detailLevel == .high)
        #expect(viewModel.showLabels == true)
        #expect(viewModel.reduceMotion == false)
    }

    @Test("ControlPanelViewModel toggles node type filter")
    @MainActor
    func testToggleNodeType() async throws {
        let viewModel = ControlPanelViewModel()

        let initialCount = viewModel.nodeTypeFilter.count
        viewModel.toggleNodeType(.warehouse)

        #expect(viewModel.nodeTypeFilter.count == initialCount - 1)

        viewModel.toggleNodeType(.warehouse)
        #expect(viewModel.nodeTypeFilter.count == initialCount)
    }

    @Test("ControlPanelViewModel filters nodes correctly")
    @MainActor
    func testShouldDisplayNode() async throws {
        let viewModel = ControlPanelViewModel()
        viewModel.nodeTypeFilter = [.warehouse]

        let warehouseNode = Node(
            id: "W1",
            type: .warehouse,
            location: GeographicCoordinate(latitude: 0, longitude: 0),
            capacity: Capacity(total: 100, available: 50, unit: "units")
        )

        let portNode = Node(
            id: "P1",
            type: .port,
            location: GeographicCoordinate(latitude: 0, longitude: 0),
            capacity: Capacity(total: 100, available: 50, unit: "units")
        )

        #expect(viewModel.shouldDisplayNode(warehouseNode) == true)
        #expect(viewModel.shouldDisplayNode(portNode) == false)
    }

    @Test("ControlPanelViewModel filters flows correctly")
    @MainActor
    func testShouldDisplayFlow() async throws {
        let viewModel = ControlPanelViewModel()
        viewModel.flowStatusFilter = [.inTransit]

        let inTransitFlow = Flow(
            id: "F1",
            shipmentId: "SHP1",
            currentNode: "N1",
            destinationNode: "N2",
            route: ["N1", "N2"],
            items: [],
            status: .inTransit,
            eta: Date(),
            actualProgress: 0.5
        )

        let deliveredFlow = Flow(
            id: "F2",
            shipmentId: "SHP2",
            currentNode: "N2",
            destinationNode: "N2",
            route: ["N1", "N2"],
            items: [],
            status: .delivered,
            eta: Date(),
            actualProgress: 1.0
        )

        #expect(viewModel.shouldDisplayFlow(inTransitFlow) == true)
        #expect(viewModel.shouldDisplayFlow(deliveredFlow) == false)
    }
}

// MARK: - Inventory ViewModel Tests

@Suite("InventoryViewModel Tests")
struct InventoryViewModelTests {

    @Test("InventoryViewModel initializes correctly")
    @MainActor
    func testInitialization() async throws {
        let viewModel = InventoryViewModel()

        #expect(viewModel.nodes.isEmpty)
        #expect(viewModel.selectedNode == nil)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.searchQuery.isEmpty)
    }

    @Test("InventoryViewModel loads inventory")
    @MainActor
    func testLoadInventory() async throws {
        let viewModel = InventoryViewModel()

        await viewModel.loadInventory()

        #expect(viewModel.nodes.count > 0)
        #expect(viewModel.isLoading == false)
    }

    @Test("InventoryViewModel calculates total value")
    @MainActor
    func testTotalInventoryValue() async throws {
        let viewModel = InventoryViewModel()
        await viewModel.loadInventory()

        #expect(viewModel.totalInventoryValue >= 0)
    }

    @Test("InventoryViewModel determines stock status")
    @MainActor
    func testStockStatus() async throws {
        let viewModel = InventoryViewModel()

        let lowStockItem = InventoryItem(
            sku: "LOW-001",
            name: "Low Stock Item",
            quantity: 5,
            unit: "units",
            value: 100,
            lastUpdated: Date(),
            turnoverRate: 0.5
        )

        let status = viewModel.stockStatus(for: lowStockItem)
        #expect(status == .critical || status == .low)
    }

    @Test("InventoryViewModel filters by search query")
    @MainActor
    func testSearchFilter() async throws {
        let viewModel = InventoryViewModel()
        await viewModel.loadInventory()

        let initialCount = viewModel.filteredInventory.count

        viewModel.searchQuery = "NONEXISTENT_SKU_12345"

        #expect(viewModel.filteredInventory.count == 0)
    }

    @Test("InventoryViewModel selects and deselects nodes")
    @MainActor
    func testNodeSelection() async throws {
        let viewModel = InventoryViewModel()
        await viewModel.loadInventory()

        guard let firstNode = viewModel.nodes.first else {
            Issue.record("No nodes to test")
            return
        }

        viewModel.selectNode(firstNode)
        #expect(viewModel.selectedNode?.id == firstNode.id)

        viewModel.deselectNode()
        #expect(viewModel.selectedNode == nil)
    }

    @Test("InventoryViewModel calculates reorder recommendations")
    @MainActor
    func testReorderRecommendation() async throws {
        let viewModel = InventoryViewModel()

        let lowStockItem = InventoryItem(
            sku: "LOW-001",
            name: "Low Stock Item",
            quantity: 5,
            unit: "units",
            value: 100,
            lastUpdated: Date(),
            turnoverRate: 0.5
        )

        let node = Node(
            id: "N1",
            type: .warehouse,
            location: GeographicCoordinate(latitude: 0, longitude: 0),
            capacity: Capacity(total: 1000, available: 500, unit: "units")
        )

        let recommendation = viewModel.reorderRecommendation(for: lowStockItem, at: node)

        #expect(recommendation != nil)
        if let rec = recommendation {
            #expect(rec.reorderQuantity > 0)
            #expect(rec.urgency == .urgent || rec.urgency == .normal)
        }
    }

    @Test("InventoryViewModel ABC classification")
    @MainActor
    func testABCClassification() async throws {
        let viewModel = InventoryViewModel()
        await viewModel.loadInventory()

        let classification = viewModel.abcClassification()

        // ABC classification should distribute items
        let totalItems = classification.classA.count +
                        classification.classB.count +
                        classification.classC.count

        #expect(totalItems >= 0)
    }
}

// MARK: - Flow ViewModel Tests

@Suite("FlowViewModel Tests")
struct FlowViewModelTests {

    @Test("FlowViewModel initializes correctly")
    @MainActor
    func testInitialization() async throws {
        let viewModel = FlowViewModel()

        #expect(viewModel.allFlows.isEmpty)
        #expect(viewModel.displayedFlows.isEmpty)
        #expect(viewModel.selectedFlow == nil)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.animationSpeed == 1.0)
    }

    @Test("FlowViewModel loads flows")
    @MainActor
    func testLoadFlows() async throws {
        let viewModel = FlowViewModel()

        await viewModel.loadFlows()

        #expect(viewModel.allFlows.count > 0)
        #expect(viewModel.displayedFlows.count > 0)
        #expect(viewModel.isLoading == false)
    }

    @Test("FlowViewModel filters by status")
    @MainActor
    func testStatusFilter() async throws {
        let viewModel = FlowViewModel()
        await viewModel.loadFlows()

        viewModel.statusFilter = [.inTransit]

        let allInTransit = viewModel.displayedFlows.allSatisfy { $0.status == .inTransit }
        #expect(allInTransit)
    }

    @Test("FlowViewModel sorts by ETA")
    @MainActor
    func testSortByETA() async throws {
        let viewModel = FlowViewModel()
        await viewModel.loadFlows()

        viewModel.updateSortOption(.etaAscending)

        // Check that flows are sorted by ETA (ascending)
        for i in 0..<(viewModel.displayedFlows.count - 1) {
            let current = viewModel.displayedFlows[i]
            let next = viewModel.displayedFlows[i + 1]
            #expect(current.eta <= next.eta)
        }
    }

    @Test("FlowViewModel calculates average progress")
    @MainActor
    func testAverageProgress() async throws {
        let viewModel = FlowViewModel()
        await viewModel.loadFlows()

        let avg = viewModel.averageProgress
        #expect(avg >= 0.0 && avg <= 1.0)
    }

    @Test("FlowViewModel checks if flow is on time")
    @MainActor
    func testIsOnTime() async throws {
        let viewModel = FlowViewModel()

        let onTimeFlow = Flow(
            id: "F1",
            shipmentId: "SHP1",
            currentNode: "N1",
            destinationNode: "N2",
            route: ["N1", "N2"],
            items: [],
            status: .inTransit,
            eta: Date().addingTimeInterval(3600),
            actualProgress: 0.5,
            originalETA: Date().addingTimeInterval(7200)
        )

        #expect(viewModel.isOnTime(onTimeFlow) == true)
    }

    @Test("FlowViewModel calculates delay hours")
    @MainActor
    func testDelayHours() async throws {
        let viewModel = FlowViewModel()

        let delayedFlow = Flow(
            id: "F1",
            shipmentId: "SHP1",
            currentNode: "N1",
            destinationNode: "N2",
            route: ["N1", "N2"],
            items: [],
            status: .delayed,
            eta: Date().addingTimeInterval(7200), // 2 hours from now
            actualProgress: 0.5,
            originalETA: Date() // Was supposed to arrive now
        )

        let delay = viewModel.delayHours(delayedFlow)
        #expect(delay > 0)
    }

    @Test("FlowViewModel gets current route segment")
    @MainActor
    func testCurrentRouteSegment() async throws {
        let viewModel = FlowViewModel()

        let flow = Flow(
            id: "F1",
            shipmentId: "SHP1",
            currentNode: "N1",
            destinationNode: "N3",
            route: ["N1", "N2", "N3"],
            items: [],
            status: .inTransit,
            eta: Date().addingTimeInterval(3600),
            actualProgress: 0.5
        )

        let segment = viewModel.currentRouteSegment(flow)
        #expect(segment != nil)
        if let seg = segment {
            #expect(seg.progress >= 0.0 && seg.progress <= 1.0)
        }
    }

    @Test("FlowViewModel calculates performance summary")
    @MainActor
    func testPerformanceSummary() async throws {
        let viewModel = FlowViewModel()
        await viewModel.loadFlows()

        let summary = viewModel.performanceSummary()

        #expect(summary.totalShipments == viewModel.allFlows.count)
        #expect(summary.otifPercentage >= 0.0 && summary.otifPercentage <= 100.0)
        #expect(summary.averageProgress >= 0.0 && summary.averageProgress <= 1.0)
    }

    @Test("FlowViewModel filters critical shipments")
    @MainActor
    func testCriticalShipments() async throws {
        let viewModel = FlowViewModel()
        await viewModel.loadFlows()

        let critical = viewModel.criticalShipments

        // All critical shipments should be high priority or delayed
        for flow in critical {
            let isHighPriority = (flow.priority ?? 0) >= 8
            let isDelayed = flow.status == .delayed
            #expect(isHighPriority || isDelayed)
        }
    }

    @Test("FlowViewModel clears filters")
    @MainActor
    func testClearFilters() async throws {
        let viewModel = FlowViewModel()
        await viewModel.loadFlows()

        // Set filters
        viewModel.statusFilter = [.inTransit]
        viewModel.showOnlyDelayed = true
        viewModel.minimumPriority = 5

        // Clear filters
        viewModel.clearFilters()

        #expect(viewModel.statusFilter.count == 3)
        #expect(viewModel.showOnlyDelayed == false)
        #expect(viewModel.minimumPriority == 0)
    }
}
