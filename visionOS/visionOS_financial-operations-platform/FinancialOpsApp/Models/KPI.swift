//
//  KPI.swift
//  Financial Operations Platform
//
//  Key Performance Indicator models
//

import Foundation
import SwiftData
import simd

@Model
final class KPI: Identifiable {
    // MARK: - Properties

    @Attribute(.unique) var id: UUID
    var name: String
    var category: KPICategory
    var currentValue: Decimal
    var targetValue: Decimal
    var previousValue: Decimal
    var unit: String
    var trend: TrendDirection
    var lastUpdated: Date
    var updateFrequency: UpdateFrequency

    // Spatial Visualization Properties
    var displayPositionX: Float
    var displayPositionY: Float
    var displayPositionZ: Float
    var visualizationType: VisualizationType

    // MARK: - Initialization

    init(
        id: UUID = UUID(),
        name: String,
        category: KPICategory,
        currentValue: Decimal,
        targetValue: Decimal,
        previousValue: Decimal = 0,
        unit: String,
        trend: TrendDirection = .stable,
        lastUpdated: Date = Date(),
        updateFrequency: UpdateFrequency = .daily,
        displayPosition: SIMD3<Float> = SIMD3<Float>(0, 0, 0),
        visualizationType: VisualizationType = .gauge
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.currentValue = currentValue
        self.targetValue = targetValue
        self.previousValue = previousValue
        self.unit = unit
        self.trend = trend
        self.lastUpdated = lastUpdated
        self.updateFrequency = updateFrequency
        self.displayPositionX = displayPosition.x
        self.displayPositionY = displayPosition.y
        self.displayPositionZ = displayPosition.z
        self.visualizationType = visualizationType
    }

    // MARK: - Computed Properties

    var displayPosition: SIMD3<Float> {
        get {
            SIMD3<Float>(displayPositionX, displayPositionY, displayPositionZ)
        }
        set {
            displayPositionX = newValue.x
            displayPositionY = newValue.y
            displayPositionZ = newValue.z
        }
    }

    var variance: Decimal {
        currentValue - targetValue
    }

    var variancePercent: Double {
        guard targetValue != 0 else { return 0 }
        return Double(truncating: ((currentValue - targetValue) / targetValue * 100) as NSDecimalNumber)
    }

    var changeFromPrevious: Decimal {
        currentValue - previousValue
    }

    var changePercent: Double {
        guard previousValue != 0 else { return 0 }
        return Double(truncating: ((currentValue - previousValue) / previousValue * 100) as NSDecimalNumber)
    }

    var isOnTarget: Bool {
        abs(variancePercent) <= 5.0 // Within 5% of target
    }

    var performanceRating: PerformanceRating {
        let absVariance = abs(variancePercent)
        switch absVariance {
        case 0..<5:
            return .excellent
        case 5..<10:
            return .good
        case 10..<20:
            return .fair
        default:
            return .poor
        }
    }

    var formattedCurrentValue: String {
        formatValue(currentValue)
    }

    var formattedTargetValue: String {
        formatValue(targetValue)
    }

    private func formatValue(_ value: Decimal) -> String {
        let formatter = NumberFormatter()

        switch unit {
        case "USD", "EUR", "GBP", "$", "€", "£":
            formatter.numberStyle = .currency
            formatter.currencyCode = unit == "$" ? "USD" : unit
        case "%":
            formatter.numberStyle = .percent
            formatter.minimumFractionDigits = 1
            formatter.maximumFractionDigits = 2
            return formatter.string(from: (value / 100) as NSDecimalNumber) ?? "\(value)%"
        default:
            formatter.numberStyle = .decimal
            formatter.minimumFractionDigits = 0
            formatter.maximumFractionDigits = 2
        }

        return (formatter.string(from: value as NSDecimalNumber) ?? "\(value)") + (unit == "days" ? " days" : "")
    }
}

// MARK: - KPI Category

enum KPICategory: String, Codable, CaseIterable {
    case liquidity
    case profitability
    case efficiency
    case risk
    case growth

    var displayName: String {
        rawValue.capitalized
    }

    var icon: String {
        switch self {
        case .liquidity: return "drop.fill"
        case .profitability: return "chart.line.uptrend.xyaxis"
        case .efficiency: return "gauge.high"
        case .risk: return "exclamationmark.triangle"
        case .growth: return "arrow.up.right"
        }
    }
}

// MARK: - Trend Direction

enum TrendDirection: String, Codable {
    case up
    case down
    case stable

    var icon: String {
        switch self {
        case .up: return "arrow.up"
        case .down: return "arrow.down"
        case .stable: return "arrow.right"
        }
    }

    var color: String {
        switch self {
        case .up: return "green"
        case .down: return "red"
        case .stable: return "blue"
        }
    }
}

// MARK: - Update Frequency

enum UpdateFrequency: String, Codable {
    case realTime = "real-time"
    case hourly
    case daily
    case weekly
    case monthly

    var displayName: String {
        switch self {
        case .realTime: return "Real-time"
        default: return rawValue.capitalized
        }
    }
}

// MARK: - Visualization Type

enum VisualizationType: String, Codable {
    case gauge
    case chart
    case spatial3D

    var displayName: String {
        switch self {
        case .gauge: return "Gauge"
        case .chart: return "Chart"
        case .spatial3D: return "3D Visualization"
        }
    }
}

// MARK: - Performance Rating

enum PerformanceRating: String {
    case excellent
    case good
    case fair
    case poor

    var color: String {
        switch self {
        case .excellent: return "green"
        case .good: return "blue"
        case .fair: return "yellow"
        case .poor: return "red"
        }
    }

    var icon: String {
        switch self {
        case .excellent: return "star.fill"
        case .good: return "checkmark.circle.fill"
        case .fair: return "exclamationmark.circle"
        case .poor: return "xmark.circle.fill"
        }
    }
}

// MARK: - KPI Dashboard

struct KPIDashboard: Codable {
    let kpis: [KPISummary]
    let generatedAt: Date

    struct KPISummary: Codable, Identifiable {
        let id: UUID
        let name: String
        let category: KPICategory
        let currentValue: Decimal
        let targetValue: Decimal
        let trend: TrendDirection
        let variancePercent: Double
    }
}
