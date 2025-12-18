//
//  InventoryViewModel.swift
//  SupplyChainControlTower
//
//  ViewModel for managing inventory landscape visualization
//

import Foundation
import Observation

/// ViewModel for the Inventory Landscape view
/// Manages inventory data, stock levels, and alerts
@Observable
@MainActor
class InventoryViewModel {

    // MARK: - Published Properties

    /// All nodes with inventory
    var nodes: [Node] = []

    /// Selected node for detail view
    var selectedNode: Node?

    /// Loading state
    var isLoading: Bool = false

    /// Error message
    var errorMessage: String?

    /// Search query for inventory items
    var searchQuery: String = "" {
        didSet {
            filterInventory()
        }
    }

    /// Filter by stock status
    var stockStatusFilter: Set<StockStatus> = [.optimal, .low, .critical, .excess] {
        didSet {
            filterInventory()
        }
    }

    /// Minimum stock threshold (percentage)
    var lowStockThreshold: Double = 0.2 // 20%

    /// Excess stock threshold (percentage)
    var excessStockThreshold: Double = 0.9 // 90%

    /// Filtered inventory items
    var filteredInventory: [InventoryItemWithNode] = []

    // MARK: - Dependencies

    private let networkService: NetworkService

    // MARK: - Computed Properties

    /// Total inventory value across all nodes
    var totalInventoryValue: Double {
        nodes.reduce(0) { total, node in
            total + node.inventory.reduce(0) { $0 + ($1.value ?? 0) * Double($1.quantity) }
        }
    }

    /// Total inventory items count
    var totalItemsCount: Int {
        nodes.reduce(0) { total, node in
            total + node.inventory.reduce(0) { $0 + $1.quantity }
        }
    }

    /// Number of unique SKUs
    var uniqueSKUs: Int {
        let allSKUs = nodes.flatMap { $0.inventory.map { $0.sku } }
        return Set(allSKUs).count
    }

    /// Low stock items count
    var lowStockItemsCount: Int {
        filteredInventory.filter { $0.stockStatus == .low || $0.stockStatus == .critical }.count
    }

    /// Excess stock items count
    var excessStockItemsCount: Int {
        filteredInventory.filter { $0.stockStatus == .excess }.count
    }

    /// Optimal stock items count
    var optimalStockItemsCount: Int {
        filteredInventory.filter { $0.stockStatus == .optimal }.count
    }

    /// Average turnover rate
    var averageTurnoverRate: Double {
        let rates = nodes.flatMap { $0.inventory.compactMap { $0.turnoverRate } }
        guard !rates.isEmpty else { return 0 }
        return rates.reduce(0, +) / Double(rates.count)
    }

    /// Nodes with critical stock levels
    var criticalStockNodes: [Node] {
        nodes.filter { node in
            node.inventory.contains { item in
                stockStatus(for: item) == .critical
            }
        }
    }

    /// Average capacity utilization
    var averageCapacityUtilization: Double {
        guard !nodes.isEmpty else { return 0 }
        let totalUtilization = nodes.reduce(0) { $0 + $1.capacity.utilization }
        return totalUtilization / Double(nodes.count)
    }

    // MARK: - Stock Status Enum

    enum StockStatus: String, CaseIterable {
        case critical = "Critical"
        case low = "Low"
        case optimal = "Optimal"
        case excess = "Excess"

        var color: String {
            switch self {
            case .critical: return "red"
            case .low: return "orange"
            case .optimal: return "green"
            case .excess: return "yellow"
            }
        }
    }

    // MARK: - Supporting Types

    struct InventoryItemWithNode: Identifiable {
        let id = UUID()
        let item: InventoryItem
        let node: Node
        let stockStatus: StockStatus
    }

    // MARK: - Initialization

    init(networkService: NetworkService = .shared) {
        self.networkService = networkService
    }

    // MARK: - Public Methods

    /// Load inventory data from network service
    func loadInventory() async {
        isLoading = true
        errorMessage = nil

        do {
            let network = try await networkService.fetchNetwork()
            nodes = network.nodes.filter { !$0.inventory.isEmpty }
            filterInventory()
            isLoading = false
        } catch {
            errorMessage = "Failed to load inventory: \(error.localizedDescription)"
            isLoading = false
        }
    }

    /// Refresh inventory data
    func refresh() async {
        await loadInventory()
    }

    /// Select a node for detail view
    func selectNode(_ node: Node) {
        selectedNode = node
    }

    /// Deselect current node
    func deselectNode() {
        selectedNode = nil
    }

    /// Get stock status for an inventory item
    func stockStatus(for item: InventoryItem) -> StockStatus {
        // Calculate stock level percentage
        // This is a simplified calculation - in reality would use reorder points, safety stock, etc.
        guard let turnoverRate = item.turnoverRate else { return .optimal }

        // If turnover is very low, it might be excess
        if turnoverRate < 0.1 && item.quantity > 100 {
            return .excess
        }

        // Simple heuristic: if quantity is low relative to typical demand
        if item.quantity < 10 {
            return .critical
        } else if item.quantity < 50 {
            return .low
        }

        return .optimal
    }

    /// Get inventory for a specific SKU across all nodes
    func inventoryForSKU(_ sku: String) -> [InventoryItemWithNode] {
        var items: [InventoryItemWithNode] = []

        for node in nodes {
            if let item = node.inventory.first(where: { $0.sku == sku }) {
                items.append(InventoryItemWithNode(
                    item: item,
                    node: node,
                    stockStatus: stockStatus(for: item)
                ))
            }
        }

        return items
    }

    /// Get total quantity for a SKU across all nodes
    func totalQuantity(forSKU sku: String) -> Int {
        inventoryForSKU(sku).reduce(0) { $0 + $1.item.quantity }
    }

    /// Get nodes with low stock for a specific SKU
    func lowStockNodes(forSKU sku: String) -> [Node] {
        inventoryForSKU(sku)
            .filter { $0.stockStatus == .low || $0.stockStatus == .critical }
            .map { $0.node }
    }

    /// Calculate reorder recommendation for an item
    func reorderRecommendation(for item: InventoryItem, at node: Node) -> ReorderRecommendation? {
        let status = stockStatus(for: item)

        guard status == .low || status == .critical else {
            return nil
        }

        // Simple reorder calculation
        let optimalQuantity = 200 // This would be calculated based on demand forecast
        let reorderQuantity = max(0, optimalQuantity - item.quantity)

        guard reorderQuantity > 0 else { return nil }

        return ReorderRecommendation(
            sku: item.sku,
            currentQuantity: item.quantity,
            reorderQuantity: reorderQuantity,
            optimalQuantity: optimalQuantity,
            urgency: status == .critical ? .urgent : .normal,
            estimatedCost: (item.value ?? 0) * Double(reorderQuantity)
        )
    }

    struct ReorderRecommendation {
        let sku: String
        let currentQuantity: Int
        let reorderQuantity: Int
        let optimalQuantity: Int
        let urgency: Urgency
        let estimatedCost: Double

        enum Urgency {
            case normal
            case urgent
        }
    }

    /// Get all reorder recommendations
    func getAllReorderRecommendations() -> [ReorderRecommendation] {
        var recommendations: [ReorderRecommendation] = []

        for node in nodes {
            for item in node.inventory {
                if let recommendation = reorderRecommendation(for: item, at: node) {
                    recommendations.append(recommendation)
                }
            }
        }

        return recommendations.sorted { $0.urgency == .urgent && $1.urgency != .urgent }
    }

    /// Calculate ABC classification for inventory
    func abcClassification() -> ABCClassification {
        let allItems = nodes.flatMap { node in
            node.inventory.map { item in
                (item: item, value: (item.value ?? 0) * Double(item.quantity))
            }
        }

        let sortedByValue = allItems.sorted { $0.value > $1.value }
        let totalValue = sortedByValue.reduce(0) { $0 + $1.value }

        var classA: [String] = []
        var classB: [String] = []
        var classC: [String] = []

        var cumulativeValue: Double = 0
        var cumulativePercentage: Double = 0

        for (item, value) in sortedByValue {
            cumulativeValue += value
            cumulativePercentage = (cumulativeValue / totalValue) * 100

            if cumulativePercentage <= 80 {
                classA.append(item.sku)
            } else if cumulativePercentage <= 95 {
                classB.append(item.sku)
            } else {
                classC.append(item.sku)
            }
        }

        return ABCClassification(
            classA: classA,
            classB: classB,
            classC: classC
        )
    }

    struct ABCClassification {
        let classA: [String] // High value (top 80%)
        let classB: [String] // Medium value (80-95%)
        let classC: [String] // Low value (95-100%)
    }

    // MARK: - Private Methods

    /// Filter inventory based on current filters
    private func filterInventory() {
        var items: [InventoryItemWithNode] = []

        for node in nodes {
            for item in node.inventory {
                let status = stockStatus(for: item)

                // Apply status filter
                guard stockStatusFilter.contains(status) else { continue }

                // Apply search filter
                if !searchQuery.isEmpty {
                    let matchesSKU = item.sku.localizedCaseInsensitiveContains(searchQuery)
                    let matchesName = (item.name ?? "").localizedCaseInsensitiveContains(searchQuery)
                    guard matchesSKU || matchesName else { continue }
                }

                items.append(InventoryItemWithNode(
                    item: item,
                    node: node,
                    stockStatus: status
                ))
            }
        }

        filteredInventory = items.sorted { item1, item2 in
            // Sort by status priority (critical first)
            let priority1 = statusPriority(item1.stockStatus)
            let priority2 = statusPriority(item2.stockStatus)

            if priority1 != priority2 {
                return priority1 > priority2
            }

            // Then by SKU
            return item1.item.sku < item2.item.sku
        }
    }

    /// Get priority value for stock status (higher = more urgent)
    private func statusPriority(_ status: StockStatus) -> Int {
        switch status {
        case .critical: return 4
        case .low: return 3
        case .excess: return 2
        case .optimal: return 1
        }
    }
}
