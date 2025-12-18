//
//  DataModels.swift
//  SupplyChainControlTower
//
//  Core data models for the supply chain control tower
//

import Foundation
import SwiftData
import RealityKit

// MARK: - App State

@Observable
class AppState {
    var network: SupplyChainNetwork?
    var selectedNode: Node?
    var selectedFlow: Flow?
    var activeDisruptions: [Disruption] = []
    var filters: FilterState = FilterState()
    var viewMode: ViewMode = .globe
    var collaborators: [User] = []
}

// MARK: - View Mode

enum ViewMode {
    case globe
    case network
    case flows
    case inventory
}

// MARK: - Filter State

struct FilterState {
    var showDelayed: Bool = true
    var showCriticalOnly: Bool = false
    var showInternationalOnly: Bool = false
    var showHighValue: Bool = false
    var timeRange: TimeRange = .now
}

enum TimeRange {
    case now
    case last24Hours
    case last7Days
    case last30Days
    case custom(start: Date, end: Date)
}

// MARK: - Supply Chain Network

struct SupplyChainNetwork: Identifiable, Codable, Sendable {
    let id: UUID
    var nodes: [Node]
    var edges: [Edge]
    var flows: [Flow]
    var disruptions: [Disruption]

    init(id: UUID = UUID(), nodes: [Node] = [], edges: [Edge] = [], flows: [Flow] = [], disruptions: [Disruption] = []) {
        self.id = id
        self.nodes = nodes
        self.edges = edges
        self.flows = flows
        self.disruptions = disruptions
    }
}

// MARK: - Node (Facility)

struct Node: Identifiable, Codable, Sendable, Hashable {
    let id: String
    let type: NodeType
    var location: GeographicCoordinate
    var capacity: Capacity
    var inventory: [InventoryItem]
    var status: NodeStatus
    var metrics: NodeMetrics

    init(id: String, type: NodeType, location: GeographicCoordinate, capacity: Capacity, inventory: [InventoryItem] = [], status: NodeStatus = .healthy, metrics: NodeMetrics = NodeMetrics()) {
        self.id = id
        self.type = type
        self.location = location
        self.capacity = capacity
        self.inventory = inventory
        self.status = status
        self.metrics = metrics
    }
}

enum NodeType: String, Codable, Sendable {
    case facility
    case warehouse
    case port
    case customer
    case factory
    case distributionCenter
}

struct GeographicCoordinate: Codable, Sendable, Hashable {
    var latitude: Double
    var longitude: Double
    var altitude: Double = 0.0
}

struct Capacity: Codable, Sendable, Hashable {
    var total: Double
    var available: Double
    var unit: String

    var utilization: Double {
        guard total > 0 else { return 0 }
        return (total - available) / total
    }
}

struct InventoryItem: Identifiable, Codable, Sendable, Hashable {
    let id: UUID
    var sku: String
    var quantity: Double
    var value: Double
    var turnoverRate: Double
}

enum NodeStatus: String, Codable, Sendable, Hashable {
    case healthy
    case warning
    case critical
    case offline
}

struct NodeMetrics: Codable, Sendable, Hashable {
    var throughput: Double = 0.0
    var accuracy: Double = 1.0
    var onTimeDelivery: Double = 1.0
}

// MARK: - Edge (Route/Connection)

struct Edge: Identifiable, Codable, Sendable, Hashable {
    let id: String
    let source: String // Node ID
    let destination: String // Node ID
    let type: TransportMode
    var routes: [Route]
    var capacity: TransportCapacity
    var cost: Cost
    var duration: Duration

    init(id: String, source: String, destination: String, type: TransportMode, routes: [Route] = [], capacity: TransportCapacity, cost: Cost, duration: Duration) {
        self.id = id
        self.source = source
        self.destination = destination
        self.type = type
        self.routes = routes
        self.capacity = capacity
        self.cost = cost
        self.duration = duration
    }
}

enum TransportMode: String, Codable, Sendable {
    case truck
    case ship
    case plane
    case rail
    case multimodal
}

struct Route: Identifiable, Codable, Sendable, Hashable {
    let id: UUID
    var waypoints: [GeographicCoordinate]
    var distance: Double
    var estimatedTime: TimeInterval
}

struct TransportCapacity: Codable, Sendable, Hashable {
    var volume: Double
    var weight: Double
    var units: Int
}

struct Cost: Codable, Sendable, Hashable {
    var amount: Double
    var currency: String = "USD"
}

struct Duration: Codable, Sendable, Hashable {
    var seconds: TimeInterval

    var hours: Double {
        seconds / 3600
    }

    var days: Double {
        hours / 24
    }
}

// MARK: - Flow (Shipment)

struct Flow: Identifiable, Codable, Sendable, Hashable {
    let id: String
    let shipmentId: String
    var currentNode: String
    var destinationNode: String
    var route: [String] // Node IDs
    var items: [ShipmentItem]
    var status: FlowStatus
    var eta: Date
    var actualProgress: Double // 0.0 to 1.0

    init(id: String, shipmentId: String, currentNode: String, destinationNode: String, route: [String], items: [ShipmentItem], status: FlowStatus, eta: Date, actualProgress: Double = 0.0) {
        self.id = id
        self.shipmentId = shipmentId
        self.currentNode = currentNode
        self.destinationNode = destinationNode
        self.route = route
        self.items = items
        self.status = status
        self.eta = eta
        self.actualProgress = actualProgress
    }
}

struct ShipmentItem: Identifiable, Codable, Sendable, Hashable {
    let id: UUID
    var sku: String
    var quantity: Double
    var value: Double
}

enum FlowStatus: String, Codable, Sendable {
    case pending
    case inTransit
    case delayed
    case delivered
    case cancelled
}

// MARK: - Disruption

struct Disruption: Identifiable, Codable, Sendable, Hashable {
    let id: UUID
    let type: DisruptionType
    var severity: Severity
    var affectedNodes: [String]
    var affectedFlows: [String]
    var predictedImpact: Impact
    var recommendations: [Recommendation]
    var detectedAt: Date

    init(id: UUID = UUID(), type: DisruptionType, severity: Severity, affectedNodes: [String] = [], affectedFlows: [String] = [], predictedImpact: Impact, recommendations: [Recommendation] = [], detectedAt: Date = Date()) {
        self.id = id
        self.type = type
        self.severity = severity
        self.affectedNodes = affectedNodes
        self.affectedFlows = affectedFlows
        self.predictedImpact = predictedImpact
        self.recommendations = recommendations
        self.detectedAt = detectedAt
    }
}

enum DisruptionType: String, Codable, Sendable {
    case weather
    case portCongestion
    case strike
    case geopolitical
    case naturalDisaster
    case systemFailure
    case capacityShortage
}

enum Severity: String, Codable, Sendable {
    case low
    case medium
    case high
    case critical

    var color: String {
        switch self {
        case .low: return "blue"
        case .medium: return "yellow"
        case .high: return "orange"
        case .critical: return "red"
        }
    }
}

struct Impact: Codable, Sendable, Hashable {
    var delayHours: Double
    var affectedShipments: Int
    var costImpact: Double
}

struct Recommendation: Identifiable, Codable, Sendable, Hashable {
    let id: UUID
    var title: String
    var description: String
    var estimatedCost: Double
    var estimatedTimeSavings: Double
    var confidence: Double // 0.0 to 1.0

    init(id: UUID = UUID(), title: String, description: String, estimatedCost: Double, estimatedTimeSavings: Double, confidence: Double) {
        self.id = id
        self.title = title
        self.description = description
        self.estimatedCost = estimatedCost
        self.estimatedTimeSavings = estimatedTimeSavings
        self.confidence = confidence
    }
}

// MARK: - User

struct User: Identifiable, Codable, Sendable {
    let id: UUID
    var name: String
    var role: UserRole
    var avatarColor: String
}

enum UserRole: String, Codable, Sendable {
    case manager
    case planner
    case analyst
    case executive
}

// MARK: - KPI Metrics

struct KPIMetrics: Codable, Sendable {
    var otif: Double // On-Time In-Full
    var activeShipments: Int
    var alerts: Int
    var inventoryTurnover: Double
    var leadTime: Double
    var costPerUnit: Double
}

// MARK: - SwiftData Models (for caching)

@Model
final class CachedNetworkState {
    var timestamp: Date
    var networkData: Data
    var ttl: TimeInterval

    init(timestamp: Date, networkData: Data, ttl: TimeInterval = 3600) {
        self.timestamp = timestamp
        self.networkData = networkData
        self.ttl = ttl
    }

    var isExpired: Bool {
        Date().timeIntervalSince(timestamp) > ttl
    }
}

@Model
final class OfflineOperation {
    var id: UUID
    var type: String
    var payload: Data
    var createdAt: Date
    var syncStatus: String

    init(id: UUID = UUID(), type: String, payload: Data, createdAt: Date = Date(), syncStatus: String = "pending") {
        self.id = id
        self.type = type
        self.payload = payload
        self.createdAt = createdAt
        self.syncStatus = syncStatus
    }
}

// MARK: - Mock Data Generator

extension SupplyChainNetwork {
    static func mockNetwork() -> SupplyChainNetwork {
        let nodes = [
            Node(
                id: "LA-DC-01",
                type: .distributionCenter,
                location: GeographicCoordinate(latitude: 34.0522, longitude: -118.2437),
                capacity: Capacity(total: 10000, available: 1500, unit: "units"),
                inventory: [
                    InventoryItem(id: UUID(), sku: "SKU-001", quantity: 1200, value: 120000, turnoverRate: 0.8)
                ],
                status: .healthy,
                metrics: NodeMetrics(throughput: 850, accuracy: 0.99, onTimeDelivery: 0.94)
            ),
            Node(
                id: "NYC-DC-01",
                type: .distributionCenter,
                location: GeographicCoordinate(latitude: 40.7128, longitude: -74.0060),
                capacity: Capacity(total: 8000, available: 800, unit: "units"),
                status: .warning
            ),
            Node(
                id: "CHI-WH-01",
                type: .warehouse,
                location: GeographicCoordinate(latitude: 41.8781, longitude: -87.6298),
                capacity: Capacity(total: 12000, available: 2400, unit: "units"),
                status: .healthy
            ),
            Node(
                id: "SFO-PORT-01",
                type: .port,
                location: GeographicCoordinate(latitude: 37.7749, longitude: -122.4194),
                capacity: Capacity(total: 5000, available: 1000, unit: "containers"),
                status: .critical
            )
        ]

        let edges = [
            Edge(
                id: "LA-NYC",
                source: "LA-DC-01",
                destination: "NYC-DC-01",
                type: .truck,
                capacity: TransportCapacity(volume: 1000, weight: 20000, units: 50),
                cost: Cost(amount: 5000),
                duration: Duration(seconds: 172800) // 2 days
            ),
            Edge(
                id: "LA-CHI",
                source: "LA-DC-01",
                destination: "CHI-WH-01",
                type: .rail,
                capacity: TransportCapacity(volume: 2000, weight: 40000, units: 100),
                cost: Cost(amount: 3500),
                duration: Duration(seconds: 129600) // 1.5 days
            )
        ]

        let flows = [
            Flow(
                id: "FLOW-001",
                shipmentId: "SHP-7432",
                currentNode: "LA-DC-01",
                destinationNode: "NYC-DC-01",
                route: ["LA-DC-01", "CHI-WH-01", "NYC-DC-01"],
                items: [
                    ShipmentItem(id: UUID(), sku: "SKU-001", quantity: 500, value: 50000)
                ],
                status: .inTransit,
                eta: Date().addingTimeInterval(7200), // 2 hours ahead
                actualProgress: 0.65
            ),
            Flow(
                id: "FLOW-002",
                shipmentId: "SHP-9821",
                currentNode: "CHI-WH-01",
                destinationNode: "NYC-DC-01",
                route: ["CHI-WH-01", "NYC-DC-01"],
                items: [
                    ShipmentItem(id: UUID(), sku: "SKU-002", quantity: 300, value: 30000)
                ],
                status: .delayed,
                eta: Date().addingTimeInterval(5400), // Delayed
                actualProgress: 0.45
            )
        ]

        let disruptions = [
            Disruption(
                type: .portCongestion,
                severity: .critical,
                affectedNodes: ["SFO-PORT-01"],
                affectedFlows: ["FLOW-003", "FLOW-004"],
                predictedImpact: Impact(delayHours: 48, affectedShipments: 23, costImpact: 125000),
                recommendations: [
                    Recommendation(
                        title: "Reroute via Air Freight",
                        description: "Use air freight for critical items to save 36 hours",
                        estimatedCost: 50000,
                        estimatedTimeSavings: 36,
                        confidence: 0.92
                    ),
                    Recommendation(
                        title: "Alternative Port",
                        description: "Redirect shipments to Oakland port",
                        estimatedCost: 15000,
                        estimatedTimeSavings: 24,
                        confidence: 0.85
                    )
                ]
            ),
            Disruption(
                type: .weather,
                severity: .medium,
                affectedNodes: ["CHI-WH-01"],
                affectedFlows: ["FLOW-002"],
                predictedImpact: Impact(delayHours: 4, affectedShipments: 5, costImpact: 5000),
                recommendations: []
            )
        ]

        return SupplyChainNetwork(nodes: nodes, edges: edges, flows: flows, disruptions: disruptions)
    }
}

extension KPIMetrics {
    static func mock() -> KPIMetrics {
        KPIMetrics(
            otif: 0.942,
            activeShipments: 847,
            alerts: 3,
            inventoryTurnover: 8.5,
            leadTime: 5.2,
            costPerUnit: 12.50
        )
    }
}
