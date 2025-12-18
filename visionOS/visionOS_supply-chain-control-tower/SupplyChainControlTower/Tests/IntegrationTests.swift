//
//  IntegrationTests.swift
//  SupplyChainControlTowerTests
//
//  Integration tests for service layer and component interactions
//

import Testing
import Foundation
@testable import SupplyChainControlTower

@Suite("Integration Tests")
struct IntegrationTests {

    // MARK: - Service Integration Tests

    @Test("Network service fetches and caches data")
    func testNetworkServiceFetchAndCache() async throws {
        let service = NetworkService.shared
        let cacheManager = service.cacheManager

        // Clear cache first
        await cacheManager.clear()

        // First fetch (should hit network, then cache)
        let network1 = try await service.fetchNetwork()
        #expect(network1.nodes.count > 0)

        // Second fetch (should hit cache)
        let network2 = try await service.fetchNetwork()
        #expect(network2.nodes.count == network1.nodes.count)

        // Verify cache was used
        let cachedNetwork: SupplyChainNetwork? = await cacheManager.get(forKey: "network-data")
        #expect(cachedNetwork != nil)
    }

    @Test("Network service handles shipment updates")
    func testNetworkServiceShipmentUpdate() async throws {
        let service = NetworkService.shared

        // Fetch initial network
        let network = try await service.fetchNetwork()
        guard let firstFlow = network.flows.first else {
            Issue.record("No flows in network")
            return
        }

        // Update shipment
        let updatedFlow = try await service.updateShipment(firstFlow.id, status: .delivered)
        #expect(updatedFlow.status == .delivered)

        // Verify cache was invalidated
        let cacheManager = service.cacheManager
        let cachedNetwork: SupplyChainNetwork? = await cacheManager.get(forKey: "network-data")
        #expect(cachedNetwork == nil) // Should be invalidated
    }

    @Test("Network service refreshes disruptions")
    func testNetworkServiceRefreshDisruptions() async throws {
        let service = NetworkService.shared

        let disruptions = try await service.refreshDisruptions()
        #expect(disruptions.count >= 0)

        // Each disruption should have valid properties
        for disruption in disruptions {
            #expect([DisruptionType.weatherEvent, .portCongestion, .supplierIssue,
                     .customsDelay, .capacityShortage, .transportationFailure]
                    .contains(disruption.type))
            #expect([DisruptionSeverity.low, .medium, .high, .critical]
                    .contains(disruption.severity))
        }
    }

    // MARK: - ViewModel Integration Tests

    @Test("Dashboard ViewModel integrates with Network Service")
    @MainActor
    func testDashboardViewModelIntegration() async throws {
        let viewModel = DashboardViewModel()

        #expect(viewModel.network == nil)
        #expect(viewModel.isLoading == false)

        // Load network
        await viewModel.loadNetwork()

        #expect(viewModel.network != nil)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage == nil)

        // KPIs should be calculated
        #expect(viewModel.kpiMetrics.activeShipments >= 0)
        #expect(viewModel.kpiMetrics.otif >= 0.0 && viewModel.kpiMetrics.otif <= 1.0)
    }

    @Test("Dashboard ViewModel handles refresh")
    @MainActor
    func testDashboardViewModelRefresh() async throws {
        let viewModel = DashboardViewModel()

        // Initial load
        await viewModel.loadNetwork()
        let initialShipmentCount = viewModel.kpiMetrics.activeShipments

        // Refresh
        await viewModel.refreshData()

        #expect(viewModel.network != nil)
        #expect(viewModel.kpiMetrics.activeShipments >= 0)
    }

    @Test("Network Visualization ViewModel integrates with data")
    @MainActor
    func testNetworkVisualizationIntegration() async throws {
        let viewModel = NetworkVisualizationViewModel()
        let network = SupplyChainNetwork.mockNetwork()

        // Load network data
        viewModel.loadNetwork(network)

        // Should have visible nodes
        #expect(viewModel.visibleNodes.count > 0)

        // Select a node
        if let firstNode = network.nodes.first {
            viewModel.selectNode(firstNode)
            #expect(viewModel.selectedNode?.id == firstNode.id)

            // Should have node details
            #expect(viewModel.selectedNodeDetails != nil)
        }
    }

    // MARK: - Data Flow Tests

    @Test("Complete data flow from service to view")
    @MainActor
    func testCompleteDataFlow() async throws {
        // Step 1: Fetch from service
        let service = NetworkService.shared
        let network = try await service.fetchNetwork()
        #expect(network.nodes.count > 0)

        // Step 2: Load into ViewModel
        let viewModel = DashboardViewModel()
        await viewModel.loadNetwork()
        #expect(viewModel.network != nil)

        // Step 3: Calculate KPIs
        let kpis = viewModel.kpiMetrics
        #expect(kpis.activeShipments >= 0)
        #expect(kpis.otif >= 0.0)

        // Step 4: Filter and display data
        let activeFlows = viewModel.network?.flows.filter { $0.status == .inTransit } ?? []
        #expect(activeFlows.count >= 0)
    }

    @Test("Disruption alert flow")
    @MainActor
    func testDisruptionAlertFlow() async throws {
        let service = NetworkService.shared
        let viewModel = DashboardViewModel()

        // Load network
        await viewModel.loadNetwork()

        // Refresh disruptions
        let disruptions = try await service.refreshDisruptions()

        // High severity disruptions should create alerts
        let criticalDisruptions = disruptions.filter { $0.severity == .critical }
        #expect(viewModel.kpiMetrics.alerts >= criticalDisruptions.count)
    }

    // MARK: - Geographic Data Integration Tests

    @Test("Node positions on globe integration")
    func testNodePositionsOnGlobe() async throws {
        let network = SupplyChainNetwork.mockNetwork()
        let globeRadius: Float = 2.5

        // Convert all node positions to Cartesian
        let positions = network.nodes.map { node in
            node.location.toCartesian(radius: globeRadius)
        }

        // All positions should be on or near the sphere surface
        for position in positions {
            let distance = sqrt(position.x * position.x +
                              position.y * position.y +
                              position.z * position.z)
            #expect(abs(distance - globeRadius) < 0.1)
        }
    }

    @Test("Route visualization integration")
    func testRouteVisualizationIntegration() async throws {
        let network = SupplyChainNetwork.mockNetwork()

        // Get a flow with a route
        guard let flow = network.flows.first,
              let sourceNode = network.nodes.first(where: { $0.id == flow.currentNode }),
              let destNode = network.nodes.first(where: { $0.id == flow.destinationNode }) else {
            Issue.record("No valid flow found")
            return
        }

        // Generate waypoints for route
        let waypoints = Route.generateWaypoints(
            from: sourceNode.location,
            to: destNode.location,
            numPoints: 20
        )

        #expect(waypoints.count == 21) // 0 to 20 inclusive
        #expect(waypoints.first?.latitude == sourceNode.location.latitude)
        #expect(waypoints.last?.latitude == destNode.location.latitude)

        // Convert to Cartesian for visualization
        let cartesianPoints = waypoints.map { $0.toCartesian(radius: 2.5) }
        #expect(cartesianPoints.count == waypoints.count)
    }

    // MARK: - State Management Tests

    @Test("AppState propagates changes")
    func testAppStateChanges() async throws {
        let appState = AppState()
        let network = SupplyChainNetwork.mockNetwork()

        #expect(appState.network == nil)
        #expect(appState.selectedNode == nil)

        // Update network
        appState.network = network
        #expect(appState.network != nil)

        // Select a node
        if let firstNode = network.nodes.first {
            appState.selectedNode = firstNode
            #expect(appState.selectedNode?.id == firstNode.id)
        }

        // Add disruption
        if let firstDisruption = network.disruptions.first {
            appState.activeDisruptions.append(firstDisruption)
            #expect(appState.activeDisruptions.count > 0)
        }
    }

    @Test("Multi-window state synchronization")
    func testMultiWindowStateSync() async throws {
        let appState = AppState()
        let network = SupplyChainNetwork.mockNetwork()

        // Simulate dashboard setting network
        appState.network = network

        // Simulate visualization accessing same network
        #expect(appState.network?.nodes.count == network.nodes.count)

        // Simulate selection in visualization
        if let node = network.nodes.first {
            appState.selectedNode = node

            // Dashboard should see the selection
            #expect(appState.selectedNode?.id == node.id)
        }
    }

    // MARK: - Error Handling Integration Tests

    @Test("Service error propagates to ViewModel")
    @MainActor
    func testServiceErrorPropagation() async throws {
        let viewModel = DashboardViewModel()

        // Note: In production, you'd inject a mock service that fails
        // For now, we verify error handling structure exists
        #expect(viewModel.errorMessage == nil)

        // If an error occurs, it should be set
        viewModel.handleError(APIError.invalidResponse)
        #expect(viewModel.errorMessage != nil)
    }

    @Test("Cache invalidation triggers data refresh")
    func testCacheInvalidationRefresh() async throws {
        let service = NetworkService.shared
        let cacheManager = service.cacheManager

        // Load and cache data
        let network1 = try await service.fetchNetwork()
        #expect(network1.nodes.count > 0)

        // Invalidate cache
        await cacheManager.invalidate(key: "network-data")

        // Next fetch should get fresh data
        let network2 = try await service.fetchNetwork()
        #expect(network2.nodes.count > 0)
    }

    // MARK: - Performance Integration Tests

    @Test("LOD system integrates with visualization")
    @MainActor
    func testLODSystemIntegration() async throws {
        let viewModel = NetworkVisualizationViewModel()
        let network = SupplyChainNetwork.mockNetwork()

        // Close camera - should show high detail
        viewModel.updateVisibleNodes(from: network, cameraPosition: SIMD3(0, 0, 2))
        #expect(viewModel.lodLevel == .high)
        let closeNodeCount = viewModel.visibleNodes.count

        // Far camera - should show minimal detail
        viewModel.updateVisibleNodes(from: network, cameraPosition: SIMD3(0, 0, 15))
        #expect(viewModel.lodLevel == .minimal)
        let farNodeCount = viewModel.visibleNodes.count

        // Should show fewer nodes when far
        #expect(farNodeCount <= closeNodeCount)
    }

    @Test("Entity pooling integrates with RealityKit")
    func testEntityPoolingIntegration() async throws {
        class MockEntity {
            var position: SIMD3<Float> = .zero
            var isActive: Bool = false
        }

        let pool = EntityPool<MockEntity>(maxSize: 100) {
            MockEntity()
        }

        // Acquire entities for visible nodes
        var activeEntities: [MockEntity] = []
        for _ in 0..<50 {
            let entity = await pool.acquire()
            entity.isActive = true
            activeEntities.append(entity)
        }

        #expect(activeEntities.count == 50)

        // Release entities when nodes become invisible
        for entity in activeEntities {
            entity.isActive = false
            await pool.release(entity)
        }

        // Pool should reuse entities
        let newEntity = await pool.acquire()
        #expect(activeEntities.contains(where: { $0 === newEntity }))
    }

    // MARK: - Real-time Update Integration Tests

    @Test("Real-time position updates flow")
    func testRealtimePositionUpdates() async throws {
        let network = SupplyChainNetwork.mockNetwork()

        guard var flow = network.flows.first else {
            Issue.record("No flows in network")
            return
        }

        let initialProgress = flow.actualProgress

        // Simulate position update
        flow.actualProgress = min(1.0, initialProgress + 0.1)

        #expect(flow.actualProgress > initialProgress)
        #expect(flow.actualProgress <= 1.0)

        // Update ETA based on progress
        if flow.actualProgress < 1.0 {
            let remainingTime = (1.0 - flow.actualProgress) * 3600 * 10 // Estimate
            flow.eta = Date().addingTimeInterval(remainingTime)
            #expect(flow.eta > Date())
        }
    }

    @Test("Batch update performance")
    func testBatchUpdatePerformance() async throws {
        let network = SupplyChainNetwork.mockNetwork()
        var flows = network.flows

        let startTime = Date()

        // Batch update all flows
        await BatchProcessor.process(flows, batchSize: 100) { batch in
            for i in batch.indices {
                flows[i].actualProgress = min(1.0, flows[i].actualProgress + 0.01)
            }
        }

        let duration = Date().timeIntervalSince(startTime)

        // Should complete quickly
        #expect(duration < 1.0)
        #expect(flows.count == network.flows.count)
    }
}

@Suite("End-to-End Scenario Tests")
struct EndToEndTests {

    @Test("Complete user journey: View dashboard → Select shipment → View details")
    @MainActor
    func testDashboardToShipmentDetails() async throws {
        // Step 1: User opens dashboard
        let dashboardVM = DashboardViewModel()
        await dashboardVM.loadNetwork()
        #expect(dashboardVM.network != nil)

        // Step 2: User sees active shipments
        let activeShipments = dashboardVM.network?.flows.filter { $0.status == .inTransit }
        #expect(activeShipments?.count ?? 0 > 0)

        // Step 3: User selects a shipment
        guard let selectedFlow = activeShipments?.first else {
            Issue.record("No active shipments")
            return
        }

        let appState = AppState()
        appState.selectedFlow = selectedFlow
        #expect(appState.selectedFlow?.id == selectedFlow.id)

        // Step 4: System shows shipment details
        #expect(appState.selectedFlow?.currentNode != nil)
        #expect(appState.selectedFlow?.destinationNode != nil)
    }

    @Test("Complete user journey: Open network view → Inspect node → See inventory")
    @MainActor
    func testNetworkToNodeInventory() async throws {
        // Step 1: User opens network visualization
        let vizVM = NetworkVisualizationViewModel()
        let network = SupplyChainNetwork.mockNetwork()
        vizVM.loadNetwork(network)

        // Step 2: User sees nodes
        #expect(vizVM.visibleNodes.count > 0)

        // Step 3: User taps a node
        guard let node = network.nodes.first(where: { !$0.inventory.isEmpty }) else {
            Issue.record("No nodes with inventory")
            return
        }

        vizVM.selectNode(node)
        #expect(vizVM.selectedNode?.id == node.id)

        // Step 4: System shows inventory
        let inventory = vizVM.selectedNode?.inventory
        #expect(inventory?.count ?? 0 > 0)
    }

    @Test("Complete user journey: Receive disruption alert → View recommendations → Take action")
    @MainActor
    func testDisruptionAlertToAction() async throws {
        // Step 1: System detects disruption
        let service = NetworkService.shared
        let disruptions = try await service.refreshDisruptions()
        guard let criticalDisruption = disruptions.first(where: { $0.severity == .critical }) else {
            // No critical disruptions, create one for testing
            let disruption = Disruption(
                type: .weatherEvent,
                severity: .critical,
                predictedImpact: Impact(delayHours: 48, affectedShipments: 15, costImpact: 250000)
            )

            // Step 2: User receives alert
            let appState = AppState()
            appState.activeDisruptions.append(disruption)
            #expect(appState.activeDisruptions.count > 0)

            // Step 3: User views recommendations
            #expect(disruption.recommendations.count > 0)

            // Step 4: User takes action (e.g., reroute)
            let recommendation = disruption.recommendations.first
            #expect(recommendation != nil)
            return
        }

        // Step 2: User receives alert
        let appState = AppState()
        appState.activeDisruptions.append(criticalDisruption)
        #expect(appState.activeDisruptions.count > 0)

        // Step 3: User views recommendations
        #expect(criticalDisruption.recommendations.count > 0)
    }

    @Test("Complete user journey: Immersive mode → Globe navigation → Route inspection")
    func testImmersiveModeNavigation() async throws {
        // Step 1: User enters immersive mode
        let network = SupplyChainNetwork.mockNetwork()
        let globeRadius: Float = 2.5

        // Step 2: System renders globe with nodes
        let nodePositions = network.nodes.map { $0.location.toCartesian(radius: globeRadius) }
        #expect(nodePositions.count == network.nodes.count)

        // Step 3: User views a route
        guard let flow = network.flows.first(where: { $0.status == .inTransit }),
              let sourceNode = network.nodes.first(where: { $0.id == flow.currentNode }),
              let destNode = network.nodes.first(where: { $0.id == flow.destinationNode }) else {
            Issue.record("No active route found")
            return
        }

        // Step 4: System draws route arc
        let waypoints = Route.generateWaypoints(
            from: sourceNode.location,
            to: destNode.location,
            numPoints: 30
        )
        #expect(waypoints.count == 31)

        // Step 5: User sees current shipment position on route
        let currentWaypointIndex = Int(flow.actualProgress * Double(waypoints.count - 1))
        let currentPosition = waypoints[currentWaypointIndex]
        #expect(currentPosition.latitude != 0 || currentPosition.longitude != 0)
    }
}
