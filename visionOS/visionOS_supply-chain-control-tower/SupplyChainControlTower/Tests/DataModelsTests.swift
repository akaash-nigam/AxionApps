//
//  DataModelsTests.swift
//  SupplyChainControlTowerTests
//
//  Unit tests for data models
//

import Testing
import Foundation
@testable import SupplyChainControlTower

@Suite("Data Model Tests")
struct DataModelsTests {

    // MARK: - Node Tests

    @Test("Node creation and properties")
    func testNodeCreation() async throws {
        let node = Node(
            id: "TEST-01",
            type: .warehouse,
            location: GeographicCoordinate(latitude: 40.7128, longitude: -74.0060),
            capacity: Capacity(total: 1000, available: 200, unit: "units")
        )

        #expect(node.id == "TEST-01")
        #expect(node.type == .warehouse)
        #expect(node.capacity.utilization == 0.8)
    }

    @Test("Node capacity utilization calculation")
    func testCapacityUtilization() async throws {
        let capacity = Capacity(total: 100, available: 25, unit: "units")
        #expect(capacity.utilization == 0.75)

        let emptyCapacity = Capacity(total: 0, available: 0, unit: "units")
        #expect(emptyCapacity.utilization == 0.0)
    }

    // MARK: - Flow Tests

    @Test("Flow creation and status")
    func testFlowCreation() async throws {
        let flow = Flow(
            id: "FLOW-001",
            shipmentId: "SHP-001",
            currentNode: "NODE-A",
            destinationNode: "NODE-B",
            route: ["NODE-A", "NODE-C", "NODE-B"],
            items: [],
            status: .inTransit,
            eta: Date().addingTimeInterval(3600),
            actualProgress: 0.5
        )

        #expect(flow.status == .inTransit)
        #expect(flow.actualProgress == 0.5)
        #expect(flow.route.count == 3)
    }

    // MARK: - Disruption Tests

    @Test("Disruption severity and impact")
    func testDisruptionSeverity() async throws {
        let disruption = Disruption(
            type: .portCongestion,
            severity: .critical,
            predictedImpact: Impact(delayHours: 48, affectedShipments: 20, costImpact: 100000)
        )

        #expect(disruption.severity == .critical)
        #expect(disruption.predictedImpact.delayHours == 48)
        #expect(disruption.type == .portCongestion)
    }

    @Test("Recommendation confidence validation")
    func testRecommendationConfidence() async throws {
        let recommendation = Recommendation(
            title: "Reroute",
            description: "Use alternative route",
            estimatedCost: 5000,
            estimatedTimeSavings: 24,
            confidence: 0.95
        )

        #expect(recommendation.confidence >= 0.0 && recommendation.confidence <= 1.0)
        #expect(recommendation.confidence == 0.95)
    }

    // MARK: - Network Tests

    @Test("Supply chain network creation")
    func testNetworkCreation() async throws {
        let node1 = Node(
            id: "N1",
            type: .warehouse,
            location: GeographicCoordinate(latitude: 0, longitude: 0),
            capacity: Capacity(total: 100, available: 50, unit: "units")
        )

        let node2 = Node(
            id: "N2",
            type: .port,
            location: GeographicCoordinate(latitude: 10, longitude: 10),
            capacity: Capacity(total: 200, available: 100, unit: "units")
        )

        let edge = Edge(
            id: "E1",
            source: "N1",
            destination: "N2",
            type: .truck,
            capacity: TransportCapacity(volume: 1000, weight: 5000, units: 50),
            cost: Cost(amount: 1000),
            duration: Duration(seconds: 3600)
        )

        let network = SupplyChainNetwork(
            nodes: [node1, node2],
            edges: [edge],
            flows: [],
            disruptions: []
        )

        #expect(network.nodes.count == 2)
        #expect(network.edges.count == 1)
        #expect(network.nodes.first?.id == "N1")
    }

    // MARK: - Mock Data Tests

    @Test("Mock network data validation")
    func testMockNetwork() async throws {
        let network = SupplyChainNetwork.mockNetwork()

        #expect(network.nodes.count > 0)
        #expect(network.flows.count > 0)
        #expect(network.disruptions.count > 0)

        // Verify node types are valid
        for node in network.nodes {
            #expect([NodeType.facility, .warehouse, .port, .customer, .factory, .distributionCenter].contains(node.type))
        }

        // Verify flows have valid status
        for flow in network.flows {
            #expect([FlowStatus.pending, .inTransit, .delayed, .delivered, .cancelled].contains(flow.status))
        }
    }

    // MARK: - KPI Tests

    @Test("KPI metrics validation")
    func testKPIMetrics() async throws {
        let kpi = KPIMetrics.mock()

        #expect(kpi.otif >= 0.0 && kpi.otif <= 1.0)
        #expect(kpi.activeShipments >= 0)
        #expect(kpi.alerts >= 0)
    }

    // MARK: - Geographic Coordinate Tests

    @Test("Geographic coordinate distance calculation")
    func testCoordinateDistance() async throws {
        let nyc = GeographicCoordinate(latitude: 40.7128, longitude: -74.0060)
        let la = GeographicCoordinate(latitude: 34.0522, longitude: -118.2437)

        let distance = nyc.distance(to: la)

        // Distance should be approximately 3944 km
        #expect(distance > 3900 && distance < 4000)
    }

    @Test("Geographic coordinate to Cartesian conversion")
    func testCoordinateToCartesian() async throws {
        let coord = GeographicCoordinate(latitude: 0, longitude: 0)
        let cartesian = coord.toCartesian(radius: 1.0)

        // At equator, prime meridian: should be approximately (1, 0, 0)
        #expect(abs(cartesian.x - 1.0) < 0.01)
        #expect(abs(cartesian.y) < 0.01)
        #expect(abs(cartesian.z) < 0.01)
    }

    @Test("Intermediate point calculation")
    func testIntermediatePoint() async throws {
        let start = GeographicCoordinate(latitude: 0, longitude: 0)
        let end = GeographicCoordinate(latitude: 10, longitude: 10)

        let midpoint = start.intermediate(to: end, fraction: 0.5)

        // Midpoint should be approximately (5, 5) for small distances
        #expect(abs(midpoint.latitude - 5.0) < 1.0)
        #expect(abs(midpoint.longitude - 5.0) < 1.0)
    }
}
