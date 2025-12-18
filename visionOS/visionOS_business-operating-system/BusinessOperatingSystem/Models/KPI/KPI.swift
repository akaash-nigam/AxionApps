//
//  KPI.swift
//  BusinessOperatingSystem
//
//  Created by BOS Team on 2025-01-20.
//

import Foundation

// MARK: - KPI

/// Key Performance Indicator with tracking and visualization properties
public struct KPI: Identifiable, Codable, Hashable, Sendable {
    public let id: UUID
    var name: String
    var value: Decimal
    var target: Decimal
    var unit: String
    var category: KPICategory
    var trend: TrendData
    var updatedAt: Date
    var displayFormat: DisplayFormat
    var alertThresholds: AlertThresholds

    // MARK: - Computed Properties

    var performance: Double {
        guard target > 0 else { return 0 }
        return Double(truncating: (value / target) as NSDecimalNumber)
    }

    var performanceStatus: PerformanceStatus {
        let perf = performance
        switch perf {
        case 1.1...:
            return .exceeding
        case 0.9..<1.1:
            return .onTrack
        case 0.7..<0.9:
            return .belowTarget
        default:
            return .critical
        }
    }

    // formattedValue is provided by FormatUtilities.swift extension

    var needsAttention: Bool {
        if let critical = alertThresholds.critical, value <= critical {
            return true
        }
        if let warning = alertThresholds.warning, value <= warning {
            return true
        }
        return false
    }
}

// MARK: - KPI Category

extension KPI {
    public enum KPICategory: String, Codable, Sendable {
        case financial
        case operational
        case customer
        case employee
        case strategic

        var displayName: String {
            switch self {
            case .financial: return "Financial"
            case .operational: return "Operational"
            case .customer: return "Customer"
            case .employee: return "Employee"
            case .strategic: return "Strategic"
            }
        }

        var iconName: String {
            switch self {
            case .financial: return "dollarsign.circle"
            case .operational: return "gear"
            case .customer: return "person.2"
            case .employee: return "person.badge.clock"
            case .strategic: return "target"
            }
        }
    }

    public enum PerformanceStatus: String, Codable, Sendable {
        case exceeding
        case onTrack
        case belowTarget
        case critical

        var displayName: String {
            switch self {
            case .exceeding: return "Exceeding"
            case .onTrack: return "On Track"
            case .belowTarget: return "Below Target"
            case .critical: return "Critical"
            }
        }

        var color: String {
            switch self {
            case .exceeding: return "#34C759"
            case .onTrack: return "#007AFF"
            case .belowTarget: return "#FF9500"
            case .critical: return "#FF3B30"
            }
        }

        var iconName: String {
            switch self {
            case .exceeding: return "arrow.up.circle.fill"
            case .onTrack: return "checkmark.circle.fill"
            case .belowTarget: return "exclamationmark.circle.fill"
            case .critical: return "xmark.circle.fill"
            }
        }
    }
}

// MARK: - Trend Data

public struct TrendData: Codable, Hashable, Sendable {
    var direction: TrendDirection
    var change: Double  // Percentage change
    var period: String  // e.g., "vs last month"

    var formattedChange: String {
        let sign = change >= 0 ? "+" : ""
        return "\(sign)\(String(format: "%.1f", change))%"
    }

    public enum TrendDirection: String, Codable, Sendable {
        case up
        case down
        case flat

        var iconName: String {
            switch self {
            case .up: return "arrow.up.right"
            case .down: return "arrow.down.right"
            case .flat: return "arrow.right"
            }
        }
    }
}

// MARK: - Display Format

public struct DisplayFormat: Codable, Hashable, Sendable {
    var formatStyle: FormatStyle
    var decimalPlaces: Int
    var showPercentage: Bool

    public enum FormatStyle: String, Codable, Sendable {
        case currency
        case number
        case percentage
        case duration
        case custom
    }
}

// MARK: - Alert Thresholds

public struct AlertThresholds: Codable, Hashable, Sendable {
    var critical: Decimal?
    var warning: Decimal?
    var target: Decimal
}

// MARK: - Mock Extension

extension KPI {
    static func mock(
        name: String = "Revenue",
        value: Decimal = 1_250_000,
        target: Decimal = 1_500_000,
        category: KPICategory = .financial
    ) -> KPI {
        KPI(
            id: UUID(),
            name: name,
            value: value,
            target: target,
            unit: "USD",
            category: category,
            trend: TrendData(direction: .up, change: 12.5, period: "vs last month"),
            updatedAt: Date(),
            displayFormat: DisplayFormat(formatStyle: .currency, decimalPlaces: 0, showPercentage: false),
            alertThresholds: AlertThresholds(critical: 1_000_000, warning: 1_200_000, target: target)
        )
    }
}
