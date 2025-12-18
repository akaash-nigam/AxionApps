//
//  AlertsViewModel.swift
//  SupplyChainControlTower
//
//  ViewModel for managing alerts and disruptions
//

import Foundation
import Observation

/// ViewModel for the Alerts view
/// Manages disruption alerts, filtering, sorting, and dismissal
@Observable
@MainActor
class AlertsViewModel {

    // MARK: - Published Properties

    /// All disruptions from the network
    var allDisruptions: [Disruption] = []

    /// Filtered and sorted disruptions for display
    var displayedDisruptions: [Disruption] = []

    /// Currently selected disruption for detail view
    var selectedDisruption: Disruption?

    /// Loading state
    var isLoading: Bool = false

    /// Error message if loading fails
    var errorMessage: String?

    /// Filter settings
    var severityFilter: Set<DisruptionSeverity> = [.low, .medium, .high, .critical]
    var typeFilter: Set<DisruptionType> = []
    var showDismissed: Bool = false

    /// Sort option
    var sortOption: SortOption = .severityDescending

    /// Search query
    var searchQuery: String = "" {
        didSet {
            applyFiltersAndSort()
        }
    }

    /// Dismissed disruption IDs
    private var dismissedDisruptionIDs: Set<String> = []

    // MARK: - Dependencies

    private let networkService: NetworkService

    // MARK: - Computed Properties

    /// Count of critical disruptions
    var criticalCount: Int {
        displayedDisruptions.filter { $0.severity == .critical }.count
    }

    /// Count of high severity disruptions
    var highCount: Int {
        displayedDisruptions.filter { $0.severity == .high }.count
    }

    /// Count of medium severity disruptions
    var mediumCount: Int {
        displayedDisruptions.filter { $0.severity == .medium }.count
    }

    /// Count of low severity disruptions
    var lowCount: Int {
        displayedDisruptions.filter { $0.severity == .low }.count
    }

    /// Total active alerts
    var totalActiveAlerts: Int {
        displayedDisruptions.count
    }

    /// Estimated total impact (delay hours)
    var totalEstimatedImpact: Double {
        displayedDisruptions.reduce(0) { $0 + Double($1.predictedImpact.delayHours) }
    }

    /// Total affected shipments
    var totalAffectedShipments: Int {
        displayedDisruptions.reduce(0) { $0 + $1.predictedImpact.affectedShipments }
    }

    /// Total cost impact
    var totalCostImpact: Double {
        displayedDisruptions.reduce(0) { $0 + $1.predictedImpact.costImpact }
    }

    // MARK: - Sort Options

    enum SortOption: String, CaseIterable {
        case severityDescending = "Severity (High to Low)"
        case severityAscending = "Severity (Low to High)"
        case dateDescending = "Date (Newest First)"
        case dateAscending = "Date (Oldest First)"
        case impactDescending = "Impact (Highest First)"
        case impactAscending = "Impact (Lowest First)"
    }

    // MARK: - Initialization

    init(networkService: NetworkService = .shared) {
        self.networkService = networkService
    }

    // MARK: - Public Methods

    /// Load disruptions from the network service
    func loadDisruptions() async {
        isLoading = true
        errorMessage = nil

        do {
            let disruptions = try await networkService.refreshDisruptions()
            allDisruptions = disruptions
            applyFiltersAndSort()
            isLoading = false
        } catch {
            errorMessage = "Failed to load disruptions: \(error.localizedDescription)"
            isLoading = false
        }
    }

    /// Refresh disruptions
    func refresh() async {
        await loadDisruptions()
    }

    /// Select a disruption for detailed view
    func selectDisruption(_ disruption: Disruption) {
        selectedDisruption = disruption
    }

    /// Deselect the current disruption
    func deselectDisruption() {
        selectedDisruption = nil
    }

    /// Dismiss a disruption (hide from view)
    func dismissDisruption(_ disruption: Disruption) {
        dismissedDisruptionIDs.insert(disruption.id)
        applyFiltersAndSort()
    }

    /// Restore a dismissed disruption
    func restoreDisruption(_ disruption: Disruption) {
        dismissedDisruptionIDs.remove(disruption.id)
        applyFiltersAndSort()
    }

    /// Update severity filter
    func updateSeverityFilter(_ severities: Set<DisruptionSeverity>) {
        severityFilter = severities
        applyFiltersAndSort()
    }

    /// Update type filter
    func updateTypeFilter(_ types: Set<DisruptionType>) {
        typeFilter = types
        applyFiltersAndSort()
    }

    /// Toggle show dismissed
    func toggleShowDismissed() {
        showDismissed.toggle()
        applyFiltersAndSort()
    }

    /// Update sort option
    func updateSortOption(_ option: SortOption) {
        sortOption = option
        applyFiltersAndSort()
    }

    /// Clear all filters
    func clearFilters() {
        severityFilter = [.low, .medium, .high, .critical]
        typeFilter = []
        searchQuery = ""
        showDismissed = false
        applyFiltersAndSort()
    }

    /// Get recommendations for a disruption
    func getRecommendations(for disruption: Disruption) -> [Recommendation] {
        disruption.recommendations
    }

    /// Accept a recommendation
    func acceptRecommendation(_ recommendation: Recommendation, for disruption: Disruption) async {
        // In a real app, this would call the backend API
        // For now, we'll just dismiss the disruption
        dismissDisruption(disruption)
    }

    /// Reject a recommendation
    func rejectRecommendation(_ recommendation: Recommendation, for disruption: Disruption) {
        // In a real app, this would log the rejection
        // For now, just a placeholder
    }

    // MARK: - Private Methods

    /// Apply filters and sorting to disruptions
    private func applyFiltersAndSort() {
        var filtered = allDisruptions

        // Filter by dismissed status
        if !showDismissed {
            filtered = filtered.filter { !dismissedDisruptionIDs.contains($0.id) }
        }

        // Filter by severity
        filtered = filtered.filter { severityFilter.contains($0.severity) }

        // Filter by type
        if !typeFilter.isEmpty {
            filtered = filtered.filter { typeFilter.contains($0.type) }
        }

        // Filter by search query
        if !searchQuery.isEmpty {
            filtered = filtered.filter { disruption in
                disruption.type.rawValue.localizedCaseInsensitiveContains(searchQuery) ||
                disruption.severity.rawValue.localizedCaseInsensitiveContains(searchQuery)
            }
        }

        // Sort
        filtered = sortDisruptions(filtered, by: sortOption)

        displayedDisruptions = filtered
    }

    /// Sort disruptions by the given option
    private func sortDisruptions(_ disruptions: [Disruption], by option: SortOption) -> [Disruption] {
        switch option {
        case .severityDescending:
            return disruptions.sorted { $0.severity.priority > $1.severity.priority }
        case .severityAscending:
            return disruptions.sorted { $0.severity.priority < $1.severity.priority }
        case .dateDescending:
            return disruptions.sorted { $0.timestamp > $1.timestamp }
        case .dateAscending:
            return disruptions.sorted { $0.timestamp < $1.timestamp }
        case .impactDescending:
            return disruptions.sorted { $0.predictedImpact.costImpact > $1.predictedImpact.costImpact }
        case .impactAscending:
            return disruptions.sorted { $0.predictedImpact.costImpact < $1.predictedImpact.costImpact }
        }
    }
}

// MARK: - DisruptionSeverity Extension

extension DisruptionSeverity {
    /// Priority value for sorting (higher = more severe)
    var priority: Int {
        switch self {
        case .critical: return 4
        case .high: return 3
        case .medium: return 2
        case .low: return 1
        }
    }
}
