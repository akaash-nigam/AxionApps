//
//  FlowViewModel.swift
//  SupplyChainControlTower
//
//  ViewModel for managing flow/shipment tracking and visualization
//

import Foundation
import Observation

/// ViewModel for the Flow River view
/// Manages shipment flows, tracking, and real-time updates
@Observable
@MainActor
class FlowViewModel {

    // MARK: - Published Properties

    /// All active flows
    var allFlows: [Flow] = []

    /// Filtered and sorted flows for display
    var displayedFlows: [Flow] = []

    /// Selected flow for detail view
    var selectedFlow: Flow?

    /// Loading state
    var isLoading: Bool = false

    /// Error message
    var errorMessage: String?

    /// Filter by status
    var statusFilter: Set<FlowStatus> = [.pending, .inTransit, .delayed] {
        didSet {
            applyFiltersAndSort()
        }
    }

    /// Search query (shipment ID, destination, etc.)
    var searchQuery: String = "" {
        didSet {
            applyFiltersAndSort()
        }
    }

    /// Sort option
    var sortOption: SortOption = .etaAscending

    /// Animation speed for flow visualization
    var animationSpeed: Double = 1.0

    /// Show only delayed shipments
    var showOnlyDelayed: Bool = false {
        didSet {
            applyFiltersAndSort()
        }
    }

    /// Minimum priority filter (0-10)
    var minimumPriority: Int = 0 {
        didSet {
            applyFiltersAndSort()
        }
    }

    // MARK: - Dependencies

    private let networkService: NetworkService

    // MARK: - Computed Properties

    /// Total active shipments
    var totalActiveShipments: Int {
        allFlows.filter { $0.status == .inTransit || $0.status == .pending }.count
    }

    /// Delayed shipments count
    var delayedShipmentsCount: Int {
        allFlows.filter { $0.status == .delayed }.count
    }

    /// On-time shipments count
    var onTimeShipmentsCount: Int {
        displayedFlows.filter { isOnTime($0) }.count
    }

    /// Average progress across all flows
    var averageProgress: Double {
        guard !displayedFlows.isEmpty else { return 0 }
        let totalProgress = displayedFlows.reduce(0.0) { $0 + $1.actualProgress }
        return totalProgress / Double(displayedFlows.count)
    }

    /// Estimated total value in transit
    var totalValueInTransit: Double {
        displayedFlows
            .filter { $0.status == .inTransit }
            .reduce(0) { total, flow in
                total + flow.items.reduce(0) { $0 + ($1.value ?? 0) * Double($1.quantity) }
            }
    }

    /// Critical shipments (high priority or delayed)
    var criticalShipments: [Flow] {
        displayedFlows.filter { flow in
            (flow.priority ?? 0) >= 8 || flow.status == .delayed
        }
    }

    /// Average delay hours for delayed shipments
    var averageDelayHours: Double {
        let delayedFlows = displayedFlows.filter { $0.status == .delayed }
        guard !delayedFlows.isEmpty else { return 0 }

        let totalDelay = delayedFlows.reduce(0.0) { total, flow in
            guard let originalETA = flow.originalETA else { return total }
            return total + flow.eta.timeIntervalSince(originalETA) / 3600
        }

        return totalDelay / Double(delayedFlows.count)
    }

    // MARK: - Sort Options

    enum SortOption: String, CaseIterable {
        case etaAscending = "ETA (Soonest First)"
        case etaDescending = "ETA (Latest First)"
        case progressAscending = "Progress (Lowest First)"
        case progressDescending = "Progress (Highest First)"
        case priorityDescending = "Priority (Highest First)"
        case valueDescending = "Value (Highest First)"
        case statusCritical = "Status (Critical First)"
    }

    // MARK: - Initialization

    init(networkService: NetworkService = .shared) {
        self.networkService = networkService
    }

    // MARK: - Public Methods

    /// Load flows from network service
    func loadFlows() async {
        isLoading = true
        errorMessage = nil

        do {
            let network = try await networkService.fetchNetwork()
            allFlows = network.flows
            applyFiltersAndSort()
            isLoading = false
        } catch {
            errorMessage = "Failed to load flows: \(error.localizedDescription)"
            isLoading = false
        }
    }

    /// Refresh flows
    func refresh() async {
        await loadFlows()
    }

    /// Select a flow for detail view
    func selectFlow(_ flow: Flow) {
        selectedFlow = flow
    }

    /// Deselect current flow
    func deselectFlow() {
        selectedFlow = nil
    }

    /// Update sort option
    func updateSortOption(_ option: SortOption) {
        sortOption = option
        applyFiltersAndSort()
    }

    /// Clear all filters
    func clearFilters() {
        statusFilter = [.pending, .inTransit, .delayed]
        searchQuery = ""
        showOnlyDelayed = false
        minimumPriority = 0
        applyFiltersAndSort()
    }

    /// Check if a flow is on time
    func isOnTime(_ flow: Flow) -> Bool {
        guard flow.status == .inTransit else { return true }

        // If original ETA exists, compare with current ETA
        if let originalETA = flow.originalETA {
            return flow.eta <= originalETA
        }

        // If no original ETA, assume on time
        return true
    }

    /// Calculate estimated time remaining for a flow
    func estimatedTimeRemaining(_ flow: Flow) -> TimeInterval {
        return max(0, flow.eta.timeIntervalSinceNow)
    }

    /// Calculate delay hours for a flow
    func delayHours(_ flow: Flow) -> Double {
        guard let originalETA = flow.originalETA else { return 0 }
        let delay = flow.eta.timeIntervalSince(originalETA)
        return max(0, delay / 3600)
    }

    /// Get route progress percentage
    func routeProgress(_ flow: Flow) -> Double {
        return flow.actualProgress * 100
    }

    /// Get current route segment
    func currentRouteSegment(_ flow: Flow) -> RouteSegment? {
        guard flow.route.count >= 2 else { return nil }

        let progress = flow.actualProgress
        let segmentCount = flow.route.count - 1
        let currentSegmentIndex = min(Int(progress * Double(segmentCount)), segmentCount - 1)

        return RouteSegment(
            from: flow.route[currentSegmentIndex],
            to: flow.route[currentSegmentIndex + 1],
            progress: (progress * Double(segmentCount)) - Double(currentSegmentIndex)
        )
    }

    struct RouteSegment {
        let from: String
        let to: String
        let progress: Double // 0-1 within this segment
    }

    /// Calculate ETA accuracy (percentage of shipments arriving within window)
    func etaAccuracy(withinMinutes minutes: Int = 30) -> Double {
        let delivered = allFlows.filter { $0.status == .delivered }
        guard !delivered.isEmpty else { return 100 }

        let onTime = delivered.filter { flow in
            guard let actualDeliveryTime = flow.actualDeliveryTime,
                  let originalETA = flow.originalETA else {
                return false
            }

            let difference = abs(actualDeliveryTime.timeIntervalSince(originalETA))
            return difference <= Double(minutes * 60)
        }

        return (Double(onTime.count) / Double(delivered.count)) * 100
    }

    /// Get flows by destination
    func flowsToDestination(_ destination: String) -> [Flow] {
        allFlows.filter { $0.destinationNode == destination }
    }

    /// Get flows from origin
    func flowsFromOrigin(_ origin: String) -> [Flow] {
        allFlows.filter { $0.currentNode == origin }
    }

    /// Calculate throughput (shipments per hour)
    func throughput(overLast hours: Int = 24) -> Double {
        let cutoffDate = Date().addingTimeInterval(-Double(hours * 3600))
        let recentFlows = allFlows.filter { flow in
            flow.timestamp >= cutoffDate
        }

        return Double(recentFlows.count) / Double(hours)
    }

    /// Get performance summary
    func performanceSummary() -> PerformanceSummary {
        let total = allFlows.count
        let inTransit = allFlows.filter { $0.status == .inTransit }.count
        let delayed = allFlows.filter { $0.status == .delayed }.count
        let delivered = allFlows.filter { $0.status == .delivered }.count
        let cancelled = allFlows.filter { $0.status == .cancelled }.count

        let onTimeDeliveries = allFlows.filter { flow in
            flow.status == .delivered && isOnTime(flow)
        }.count

        let otifPercentage = delivered > 0 ? (Double(onTimeDeliveries) / Double(delivered)) * 100 : 100

        return PerformanceSummary(
            totalShipments: total,
            inTransit: inTransit,
            delayed: delayed,
            delivered: delivered,
            cancelled: cancelled,
            otifPercentage: otifPercentage,
            averageProgress: averageProgress,
            totalValue: totalValueInTransit
        )
    }

    struct PerformanceSummary {
        let totalShipments: Int
        let inTransit: Int
        let delayed: Int
        let delivered: Int
        let cancelled: Int
        let otifPercentage: Double
        let averageProgress: Double
        let totalValue: Double
    }

    /// Expedite a shipment (mark as high priority)
    func expediteShipment(_ flow: Flow) async {
        // In a real app, this would call the backend API
        // For now, we'll update locally
        if let index = allFlows.firstIndex(where: { $0.id == flow.id }) {
            var updatedFlow = allFlows[index]
            updatedFlow.priority = 10
            allFlows[index] = updatedFlow
            applyFiltersAndSort()
        }
    }

    /// Reroute a shipment
    func rerouteShipment(_ flow: Flow, newRoute: [String]) async {
        // In a real app, this would call the backend API
        // For now, we'll update locally
        if let index = allFlows.firstIndex(where: { $0.id == flow.id }) {
            var updatedFlow = allFlows[index]
            updatedFlow.route = newRoute
            allFlows[index] = updatedFlow
            applyFiltersAndSort()
        }
    }

    // MARK: - Private Methods

    /// Apply filters and sorting to flows
    private func applyFiltersAndSort() {
        var filtered = allFlows

        // Filter by status
        filtered = filtered.filter { statusFilter.contains($0.status) }

        // Filter by delayed only
        if showOnlyDelayed {
            filtered = filtered.filter { $0.status == .delayed }
        }

        // Filter by minimum priority
        if minimumPriority > 0 {
            filtered = filtered.filter { ($0.priority ?? 0) >= minimumPriority }
        }

        // Filter by search query
        if !searchQuery.isEmpty {
            filtered = filtered.filter { flow in
                flow.id.localizedCaseInsensitiveContains(searchQuery) ||
                flow.shipmentId.localizedCaseInsensitiveContains(searchQuery) ||
                flow.destinationNode.localizedCaseInsensitiveContains(searchQuery) ||
                flow.currentNode.localizedCaseInsensitiveContains(searchQuery)
            }
        }

        // Sort
        filtered = sortFlows(filtered, by: sortOption)

        displayedFlows = filtered
    }

    /// Sort flows by the given option
    private func sortFlows(_ flows: [Flow], by option: SortOption) -> [Flow] {
        switch option {
        case .etaAscending:
            return flows.sorted { $0.eta < $1.eta }
        case .etaDescending:
            return flows.sorted { $0.eta > $1.eta }
        case .progressAscending:
            return flows.sorted { $0.actualProgress < $1.actualProgress }
        case .progressDescending:
            return flows.sorted { $0.actualProgress > $1.actualProgress }
        case .priorityDescending:
            return flows.sorted { ($0.priority ?? 0) > ($1.priority ?? 0) }
        case .valueDescending:
            return flows.sorted { flowValue($0) > flowValue($1) }
        case .statusCritical:
            return flows.sorted { statusPriority($0.status) > statusPriority($1.status) }
        }
    }

    /// Calculate total value of a flow
    private func flowValue(_ flow: Flow) -> Double {
        flow.items.reduce(0) { $0 + ($1.value ?? 0) * Double($1.quantity) }
    }

    /// Get priority value for status (higher = more critical)
    private func statusPriority(_ status: FlowStatus) -> Int {
        switch status {
        case .delayed: return 5
        case .pending: return 4
        case .inTransit: return 3
        case .delivered: return 2
        case .cancelled: return 1
        }
    }
}
