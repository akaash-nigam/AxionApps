//
//  Visualization.swift
//  BusinessOperatingSystem
//
//  Created by BOS Team on 2025-01-20.
//

import Foundation

// MARK: - Visualization

/// Represents a data visualization that can be rendered in 2D or 3D
public struct Visualization: Identifiable, Codable, Sendable {
    public let id: UUID
    var type: VisualizationType
    var title: String
    var dataSource: String
    var configuration: VisualizationConfig

    public enum VisualizationType: String, Codable, Sendable {
        case barChart
        case lineChart
        case pieChart
        case scatterPlot
        case heatMap
        case networkGraph
        case volumetric3D

        var displayName: String {
            switch self {
            case .barChart: return "Bar Chart"
            case .lineChart: return "Line Chart"
            case .pieChart: return "Pie Chart"
            case .scatterPlot: return "Scatter Plot"
            case .heatMap: return "Heat Map"
            case .networkGraph: return "Network Graph"
            case .volumetric3D: return "3D Volumetric"
            }
        }

        var iconName: String {
            switch self {
            case .barChart: return "chart.bar"
            case .lineChart: return "chart.xyaxis.line"
            case .pieChart: return "chart.pie"
            case .scatterPlot: return "circle.grid.2x1"
            case .heatMap: return "square.grid.3x3"
            case .networkGraph: return "point.3.connected.trianglepath.dotted"
            case .volumetric3D: return "cube.transparent"
            }
        }

        var supportsVolumetric: Bool {
            switch self {
            case .barChart, .pieChart, .networkGraph, .volumetric3D:
                return true
            default:
                return false
            }
        }
    }
}

// MARK: - Visualization Configuration

public struct VisualizationConfig: Codable, Hashable, Sendable {
    var dimensions: SIMD3<Float>?  // For 3D visualizations
    var colorScheme: String
    var interactive: Bool
    var animationEnabled: Bool
    var showLabels: Bool
    var showLegend: Bool
    var refreshInterval: TimeInterval?

    init(
        dimensions: SIMD3<Float>? = nil,
        colorScheme: String = "default",
        interactive: Bool = true,
        animationEnabled: Bool = true,
        showLabels: Bool = true,
        showLegend: Bool = true,
        refreshInterval: TimeInterval? = nil
    ) {
        self.dimensions = dimensions
        self.colorScheme = colorScheme
        self.interactive = interactive
        self.animationEnabled = animationEnabled
        self.showLabels = showLabels
        self.showLegend = showLegend
        self.refreshInterval = refreshInterval
    }
}

// MARK: - Business Update

/// Represents a real-time update to business data
public struct BusinessUpdate: Codable, Sendable {
    var id: UUID
    var timestamp: Date
    var entityType: BusinessEntityType
    var entityID: UUID
    var changeType: ChangeType
    var data: Data  // JSON encoded entity

    public enum BusinessEntityType: String, Codable, Sendable {
        case organization
        case department
        case kpi
        case employee
        case report

        var displayName: String {
            switch self {
            case .organization: return "Organization"
            case .department: return "Department"
            case .kpi: return "KPI"
            case .employee: return "Employee"
            case .report: return "Report"
            }
        }
    }

    public enum ChangeType: String, Codable, Sendable {
        case created
        case updated
        case deleted

        var displayName: String {
            switch self {
            case .created: return "Created"
            case .updated: return "Updated"
            case .deleted: return "Deleted"
            }
        }
    }
}

// MARK: - Mock Extension

extension Visualization {
    static func mock(
        type: VisualizationType = .barChart,
        title: String = "Revenue by Quarter"
    ) -> Visualization {
        Visualization(
            id: UUID(),
            type: type,
            title: title,
            dataSource: "revenue_quarterly",
            configuration: VisualizationConfig(
                dimensions: type.supportsVolumetric ? [0.5, 0.5, 0.5] : nil,
                colorScheme: "business",
                interactive: true,
                animationEnabled: true
            )
        )
    }
}
