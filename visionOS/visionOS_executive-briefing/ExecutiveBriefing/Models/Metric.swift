import Foundation
import SwiftData

/// Represents a metric or KPI
@Model
final class Metric {
    /// Unique identifier
    var id: UUID

    /// Metric label/name
    var label: String

    /// Metric value (formatted string, e.g., "67%", "$2M")
    var value: String

    /// Optional trend indicator
    var trend: Trend?

    /// Unit of measurement
    var unit: String?

    /// Category for grouping
    var category: String?

    /// Initialize a new metric
    /// - Parameters:
    ///   - id: Unique identifier
    ///   - label: Metric label
    ///   - value: Formatted value
    ///   - trend: Optional trend
    ///   - unit: Optional unit
    ///   - category: Optional category
    init(
        id: UUID = UUID(),
        label: String,
        value: String,
        trend: Trend? = nil,
        unit: String? = nil,
        category: String? = nil
    ) {
        self.id = id
        self.label = label
        self.value = value
        self.trend = trend
        self.unit = unit
        self.category = category
    }

    /// Accessibility description
    var accessibilityDescription: String {
        var description = "\(label): \(value)"
        if let unit = unit {
            description += " \(unit)"
        }
        if let trend = trend {
            description += ", \(trend.description)"
        }
        return description
    }
}

/// Trend direction for metrics
enum Trend: String, Codable {
    case up
    case down
    case stable

    var symbol: String {
        switch self {
        case .up: return "↗"
        case .down: return "↘"
        case .stable: return "→"
        }
    }

    var description: String {
        switch self {
        case .up: return "trending up"
        case .down: return "trending down"
        case .stable: return "stable"
        }
    }

    var sfSymbol: String {
        switch self {
        case .up: return "arrow.up.right"
        case .down: return "arrow.down.right"
        case .stable: return "arrow.right"
        }
    }
}

// MARK: - Hashable & Equatable
extension Metric: Hashable {
    static func == (lhs: Metric, rhs: Metric) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
