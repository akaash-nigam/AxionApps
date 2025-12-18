//
//  DashboardViewModel.swift
//  SupplyChainControlTower
//
//  ViewModel for Dashboard view
//

import Foundation
import Observation

@Observable
@MainActor
class DashboardViewModel {

    // MARK: - Published State

    var network: SupplyChainNetwork?
    var kpiMetrics: KPIMetrics = KPIMetrics.mock()
    var isLoading: Bool = false
    var errorMessage: String?
    var lastUpdated: Date?

    // MARK: - Dependencies

    private let networkService: NetworkService

    // MARK: - Initialization

    init(networkService: NetworkService = NetworkService()) {
        self.networkService = networkService
    }

    // MARK: - Actions

    /// Load network data
    func loadNetwork() async {
        isLoading = true
        errorMessage = nil

        do {
            // In production, fetch from API
            // For now, use mock data
            network = SupplyChainNetwork.mockNetwork()

            // Simulate network delay
            try await Task.sleep(for: .milliseconds(500))

            // Update metrics based on network
            updateMetrics()

            lastUpdated = Date()
            isLoading = false
        } catch {
            errorMessage = "Failed to load network: \(error.localizedDescription)"
            isLoading = false
        }
    }

    /// Refresh data
    func refresh() async {
        await loadNetwork()
    }

    /// Update KPI metrics from network data
    private func updateMetrics() {
        guard let network = network else { return }

        let activeShipments = network.flows.filter { $0.status == .inTransit }.count
        let totalFlows = network.flows.count
        let onTimeFlows = network.flows.filter {
            $0.status == .delivered || ($0.status == .inTransit && $0.eta > Date())
        }.count

        kpiMetrics = KPIMetrics(
            otif: totalFlows > 0 ? Double(onTimeFlows) / Double(totalFlows) : 0.0,
            activeShipments: activeShipments,
            alerts: network.disruptions.count,
            inventoryTurnover: 8.5,
            leadTime: 5.2,
            costPerUnit: 12.50
        )
    }

    /// Get filtered flows based on current filters
    func filteredFlows() -> [Flow] {
        guard let network = network else { return [] }

        // Apply filters here
        return network.flows.filter { flow in
            // Example: filter by status
            flow.status == .inTransit || flow.status == .delayed
        }
    }

    /// Select a flow
    func selectFlow(_ flow: Flow) {
        // Update app state or navigate to detail view
        print("Selected flow: \(flow.id)")
    }
}
