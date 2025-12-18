//
//  FormatUtilities.swift
//  BusinessOperatingSystem
//
//  Created by BOS Team on 2025-01-20.
//

import Foundation

/// Utilities for formatting business data
enum FormatUtilities {
    // MARK: - Currency Formatting

    static func formatCurrency(_ value: Decimal, currencyCode: String = "USD") -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode
        formatter.maximumFractionDigits = 0

        return formatter.string(from: value as NSDecimalNumber) ?? "$0"
    }

    static func formatCurrencyCompact(_ value: Decimal) -> String {
        let doubleValue = Double(truncating: value as NSDecimalNumber)

        switch abs(doubleValue) {
        case 1_000_000_000...:
            return String(format: "$%.1fB", doubleValue / 1_000_000_000)
        case 1_000_000...:
            return String(format: "$%.1fM", doubleValue / 1_000_000)
        case 1_000...:
            return String(format: "$%.1fK", doubleValue / 1_000)
        default:
            return formatCurrency(value)
        }
    }

    // MARK: - Number Formatting

    static func formatNumber(_ value: Decimal, decimals: Int = 2) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = decimals

        return formatter.string(from: value as NSDecimalNumber) ?? "0"
    }

    static func formatPercentage(_ value: Double, decimals: Int = 1) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = decimals
        formatter.multiplier = 1  // Value already in percentage

        return formatter.string(from: NSNumber(value: value / 100)) ?? "0%"
    }

    // MARK: - Date Formatting

    static func formatDate(_ date: Date, style: DateFormatter.Style = .medium) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = style
        formatter.timeStyle = .none

        return formatter.string(from: date)
    }

    static func formatDateTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short

        return formatter.string(from: date)
    }

    static func formatRelativeTime(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated

        return formatter.localizedString(for: date, relativeTo: Date())
    }

    // MARK: - Duration Formatting

    static func formatDuration(_ seconds: TimeInterval) -> String {
        let hours = Int(seconds) / 3600
        let minutes = (Int(seconds) % 3600) / 60

        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }

    // MARK: - Trend Formatting

    static func formatTrendChange(_ change: Double) -> String {
        let sign = change >= 0 ? "+" : ""
        return "\(sign)\(String(format: "%.1f", change))%"
    }

    static func trendIcon(for direction: TrendData.TrendDirection) -> String {
        switch direction {
        case .up: return "↑"
        case .down: return "↓"
        case .flat: return "→"
        }
    }
}

// MARK: - KPI Formatting Extensions

extension KPI {
    var formattedValue: String {
        switch displayFormat.formatStyle {
        case .currency:
            return FormatUtilities.formatCurrencyCompact(value)
        case .number:
            return FormatUtilities.formatNumber(value, decimals: displayFormat.decimalPlaces)
        case .percentage:
            return FormatUtilities.formatPercentage(Double(truncating: value as NSDecimalNumber),
                                                   decimals: displayFormat.decimalPlaces)
        case .duration:
            return FormatUtilities.formatDuration(TimeInterval(truncating: value as NSDecimalNumber))
        case .custom:
            return "\(value) \(unit)"
        }
    }

    var formattedTarget: String {
        switch displayFormat.formatStyle {
        case .currency:
            return FormatUtilities.formatCurrencyCompact(target)
        case .number:
            return FormatUtilities.formatNumber(target, decimals: displayFormat.decimalPlaces)
        case .percentage:
            return FormatUtilities.formatPercentage(Double(truncating: target as NSDecimalNumber),
                                                   decimals: displayFormat.decimalPlaces)
        case .duration:
            return FormatUtilities.formatDuration(TimeInterval(truncating: target as NSDecimalNumber))
        case .custom:
            return "\(target) \(unit)"
        }
    }

    var formattedTrend: String {
        FormatUtilities.formatTrendChange(trend.change)
    }
}

// MARK: - Department Formatting Extensions

extension Department {
    var formattedBudget: String {
        FormatUtilities.formatCurrencyCompact(budget.allocated)
    }

    var formattedBudgetUtilization: String {
        FormatUtilities.formatPercentage(budget.utilizationPercent, decimals: 0)
    }
}
