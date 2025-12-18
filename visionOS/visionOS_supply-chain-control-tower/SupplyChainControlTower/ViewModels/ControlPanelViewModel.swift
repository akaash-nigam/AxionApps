//
//  ControlPanelViewModel.swift
//  SupplyChainControlTower
//
//  ViewModel for managing control panel settings and filters
//

import Foundation
import Observation

/// ViewModel for the Control Panel view
/// Manages display settings, filters, and user preferences
@Observable
@MainActor
class ControlPanelViewModel {

    // MARK: - Display Settings

    /// Current view mode
    var viewMode: ViewMode = .network {
        didSet {
            savePreferences()
        }
    }

    /// Time range for data display
    var timeRange: TimeRange = .last24Hours {
        didSet {
            savePreferences()
        }
    }

    /// Detail level (LOD)
    var detailLevel: DetailLevel = .high {
        didSet {
            savePreferences()
        }
    }

    /// Show labels on nodes
    var showLabels: Bool = true {
        didSet {
            savePreferences()
        }
    }

    /// Show routes/edges
    var showRoutes: Bool = true {
        didSet {
            savePreferences()
        }
    }

    /// Show flows/shipments
    var showFlows: Bool = true {
        didSet {
            savePreferences()
        }
    }

    /// Show disruptions
    var showDisruptions: Bool = true {
        didSet {
            savePreferences()
        }
    }

    /// Animation speed multiplier (0.5 = half speed, 2.0 = double speed)
    var animationSpeed: Double = 1.0 {
        didSet {
            savePreferences()
        }
    }

    // MARK: - Filters

    /// Node type filter
    var nodeTypeFilter: Set<NodeType> = [.facility, .warehouse, .port, .customer, .factory, .distributionCenter] {
        didSet {
            notifyFiltersChanged()
        }
    }

    /// Flow status filter
    var flowStatusFilter: Set<FlowStatus> = [.pending, .inTransit, .delayed, .delivered, .cancelled] {
        didSet {
            notifyFiltersChanged()
        }
    }

    /// Region filter
    var regionFilter: Set<String> = [] {
        didSet {
            notifyFiltersChanged()
        }
    }

    /// Carrier filter
    var carrierFilter: Set<String> = [] {
        didSet {
            notifyFiltersChanged()
        }
    }

    /// Minimum shipment value filter (in dollars)
    var minimumShipmentValue: Double = 0 {
        didSet {
            notifyFiltersChanged()
        }
    }

    /// Maximum shipment value filter (in dollars, 0 = no limit)
    var maximumShipmentValue: Double = 0 {
        didSet {
            notifyFiltersChanged()
        }
    }

    // MARK: - Display Options

    /// Color scheme
    var colorScheme: ColorScheme = .status {
        didSet {
            savePreferences()
        }
    }

    /// Node size mode
    var nodeSizeMode: NodeSizeMode = .capacity {
        didSet {
            savePreferences()
        }
    }

    /// Route width mode
    var routeWidthMode: RouteWidthMode = .volume {
        didSet {
            savePreferences()
        }
    }

    // MARK: - Preferences

    /// Enable sound effects
    var soundEnabled: Bool = true {
        didSet {
            savePreferences()
        }
    }

    /// Enable haptic feedback
    var hapticsEnabled: Bool = true {
        didSet {
            savePreferences()
        }
    }

    /// Enable notifications
    var notificationsEnabled: Bool = true {
        didSet {
            savePreferences()
        }
    }

    /// Reduce motion (for accessibility)
    var reduceMotion: Bool = false {
        didSet {
            savePreferences()
        }
    }

    // MARK: - State

    /// Filters have changed (notify observers)
    var filtersDidChange: Bool = false

    // MARK: - Enums

    enum ViewMode: String, CaseIterable {
        case network = "Network View"
        case inventory = "Inventory View"
        case flow = "Flow View"
        case globe = "Globe View"
    }

    enum TimeRange: String, CaseIterable {
        case last1Hour = "Last Hour"
        case last6Hours = "Last 6 Hours"
        case last24Hours = "Last 24 Hours"
        case last7Days = "Last 7 Days"
        case last30Days = "Last 30 Days"
        case custom = "Custom Range"

        var seconds: TimeInterval {
            switch self {
            case .last1Hour: return 3600
            case .last6Hours: return 21600
            case .last24Hours: return 86400
            case .last7Days: return 604800
            case .last30Days: return 2592000
            case .custom: return 0
            }
        }
    }

    enum DetailLevel: String, CaseIterable {
        case minimal = "Minimal"
        case low = "Low"
        case medium = "Medium"
        case high = "High"

        var lodLevel: LODLevel {
            switch self {
            case .minimal: return .minimal
            case .low: return .low
            case .medium: return .medium
            case .high: return .high
            }
        }
    }

    enum ColorScheme: String, CaseIterable {
        case status = "By Status"
        case region = "By Region"
        case carrier = "By Carrier"
        case priority = "By Priority"
        case temperature = "Heat Map"
    }

    enum NodeSizeMode: String, CaseIterable {
        case uniform = "Uniform"
        case capacity = "By Capacity"
        case throughput = "By Throughput"
        case value = "By Value"
    }

    enum RouteWidthMode: String, CaseIterable {
        case uniform = "Uniform"
        case volume = "By Volume"
        case value = "By Value"
        case frequency = "By Frequency"
    }

    // MARK: - Initialization

    init() {
        loadPreferences()
    }

    // MARK: - Public Methods

    /// Reset all filters to default
    func resetFilters() {
        nodeTypeFilter = [.facility, .warehouse, .port, .customer, .factory, .distributionCenter]
        flowStatusFilter = [.pending, .inTransit, .delayed, .delivered, .cancelled]
        regionFilter = []
        carrierFilter = []
        minimumShipmentValue = 0
        maximumShipmentValue = 0
        notifyFiltersChanged()
    }

    /// Reset all settings to default
    func resetSettings() {
        viewMode = .network
        timeRange = .last24Hours
        detailLevel = .high
        showLabels = true
        showRoutes = true
        showFlows = true
        showDisruptions = true
        animationSpeed = 1.0
        colorScheme = .status
        nodeSizeMode = .capacity
        routeWidthMode = .volume
        soundEnabled = true
        hapticsEnabled = true
        notificationsEnabled = true
        reduceMotion = false
        savePreferences()
    }

    /// Apply a preset configuration
    func applyPreset(_ preset: Preset) {
        switch preset {
        case .performance:
            detailLevel = .low
            showLabels = false
            animationSpeed = 1.0
            reduceMotion = true
        case .quality:
            detailLevel = .high
            showLabels = true
            animationSpeed = 1.0
            reduceMotion = false
        case .accessibility:
            detailLevel = .medium
            showLabels = true
            animationSpeed = 0.5
            reduceMotion = true
            soundEnabled = true
            hapticsEnabled = true
        case .presentation:
            detailLevel = .high
            showLabels = true
            showRoutes = true
            showFlows = true
            showDisruptions = true
            animationSpeed = 0.75
        }
        savePreferences()
    }

    enum Preset: String, CaseIterable {
        case performance = "Performance"
        case quality = "Quality"
        case accessibility = "Accessibility"
        case presentation = "Presentation"
    }

    /// Toggle a specific filter
    func toggleNodeType(_ type: NodeType) {
        if nodeTypeFilter.contains(type) {
            nodeTypeFilter.remove(type)
        } else {
            nodeTypeFilter.insert(type)
        }
    }

    func toggleFlowStatus(_ status: FlowStatus) {
        if flowStatusFilter.contains(status) {
            flowStatusFilter.remove(status)
        } else {
            flowStatusFilter.insert(status)
        }
    }

    /// Check if a node should be displayed based on filters
    func shouldDisplayNode(_ node: Node) -> Bool {
        return nodeTypeFilter.contains(node.type)
    }

    /// Check if a flow should be displayed based on filters
    func shouldDisplayFlow(_ flow: Flow) -> Bool {
        guard flowStatusFilter.contains(flow.status) else { return false }

        // Apply value filters if set
        if minimumShipmentValue > 0 {
            let totalValue = flow.items.reduce(0) { $0 + ($1.value ?? 0) }
            if totalValue < minimumShipmentValue {
                return false
            }
        }

        if maximumShipmentValue > 0 {
            let totalValue = flow.items.reduce(0) { $0 + ($1.value ?? 0) }
            if totalValue > maximumShipmentValue {
                return false
            }
        }

        return true
    }

    // MARK: - Private Methods

    /// Notify that filters have changed
    private func notifyFiltersChanged() {
        filtersDidChange = true
    }

    /// Save preferences to UserDefaults
    private func savePreferences() {
        // In a real app, this would save to UserDefaults or SwiftData
        // For now, it's a placeholder
    }

    /// Load preferences from UserDefaults
    private func loadPreferences() {
        // In a real app, this would load from UserDefaults or SwiftData
        // For now, it's a placeholder
    }

    /// Export current settings as JSON
    func exportSettings() -> String {
        // In a real app, this would serialize settings to JSON
        // For now, return a placeholder
        return "{}"
    }

    /// Import settings from JSON
    func importSettings(_ json: String) {
        // In a real app, this would deserialize JSON and apply settings
        // For now, it's a placeholder
    }
}
