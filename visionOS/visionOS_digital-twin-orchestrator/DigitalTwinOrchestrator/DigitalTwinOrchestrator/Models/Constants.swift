import SwiftUI

// MARK: - Health Thresholds

/// Centralized health score thresholds used throughout the application
enum HealthThresholds {
    /// Score at or above which health is considered excellent
    static let excellent: Double = 90.0

    /// Score at or above which health is considered good (warning below)
    static let good: Double = 70.0

    /// Score at or above which health is considered fair (critical below)
    static let fair: Double = 50.0

    /// Score below which health is considered critical
    static let critical: Double = 50.0

    /// Get the health category for a given score
    static func category(for score: Double) -> HealthCategory {
        switch score {
        case excellent...100: return .excellent
        case good..<excellent: return .good
        case fair..<good: return .fair
        case 0..<fair: return .critical
        default: return .unknown
        }
    }

    /// Get the appropriate color for a health score
    static func color(for score: Double) -> Color {
        switch score {
        case excellent...100: return .green
        case good..<excellent: return .yellow
        case fair..<good: return .orange
        case 0..<fair: return .red
        default: return .gray
        }
    }

    /// Get the appropriate system color name (for models that store as String)
    static func colorName(for score: Double) -> String {
        switch score {
        case excellent...100: return "green"
        case good..<excellent: return "yellow"
        case fair..<good: return "orange"
        case 0..<fair: return "red"
        default: return "gray"
        }
    }
}

enum HealthCategory: String, CaseIterable {
    case excellent = "Excellent"
    case good = "Good"
    case fair = "Fair"
    case critical = "Critical"
    case unknown = "Unknown"

    var color: Color {
        switch self {
        case .excellent: return .green
        case .good: return .yellow
        case .fair: return .orange
        case .critical: return .red
        case .unknown: return .gray
        }
    }

    var iconName: String {
        switch self {
        case .excellent: return "checkmark.circle.fill"
        case .good: return "checkmark.circle"
        case .fair: return "exclamationmark.circle"
        case .critical: return "xmark.circle.fill"
        case .unknown: return "questionmark.circle"
        }
    }
}

// MARK: - Sensor Thresholds

/// Thresholds for sensor data quality
enum SensorQualityThresholds {
    static let excellent: Double = 0.95
    static let good: Double = 0.85
    static let fair: Double = 0.70
    static let poor: Double = 0.50
}

// MARK: - Prediction Confidence Thresholds

/// Thresholds for prediction confidence levels
enum PredictionConfidenceThresholds {
    static let high: Double = 0.85
    static let medium: Double = 0.70
    static let low: Double = 0.50
}

// MARK: - Performance Thresholds

/// Thresholds for performance monitoring
enum PerformanceThresholds {
    /// Maximum acceptable latency for real-time updates (ms)
    static let maxLatencyMs: Double = 100.0

    /// Warning threshold for latency (ms)
    static let warningLatencyMs: Double = 50.0

    /// Maximum sensor messages per second before throttling
    static let maxMessagesPerSecond: Int = 1000

    /// Cache hit ratio below which a warning is logged
    static let minCacheHitRatio: Double = 0.70
}

// MARK: - UI Constants

/// UI-related constants
enum UIConstants {
    /// Standard animation duration
    static let animationDuration: Double = 0.3

    /// Long press duration for context menus
    static let longPressDuration: Double = 0.5

    /// Debounce interval for search
    static let searchDebounceMs: Int = 300

    /// Maximum items to show in lists before pagination
    static let maxListItems: Int = 50

    /// Refresh interval for real-time data (seconds)
    static let refreshInterval: TimeInterval = 5.0
}

// MARK: - Spatial Constants

/// Constants for visionOS spatial UI
enum SpatialConstants {
    /// Default volume size in meters
    static let defaultVolumeSize: Float = 1.5

    /// Minimum comfortable viewing distance in meters
    static let minViewingDistance: Float = 0.5

    /// Maximum comfortable viewing distance in meters
    static let maxViewingDistance: Float = 3.0

    /// Default ornament offset from content
    static let ornamentOffset: Float = 0.1

    /// Hover highlight scale factor
    static let hoverScale: Float = 1.05
}
