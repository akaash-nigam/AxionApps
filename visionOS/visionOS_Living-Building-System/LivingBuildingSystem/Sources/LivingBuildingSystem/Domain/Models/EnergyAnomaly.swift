import Foundation
import SwiftData

@Model
final class EnergyAnomaly {
    @Attribute(.unique) var id: UUID
    var detectedAt: Date
    var anomalyType: AnomalyType
    var severity: AnomalySeverity

    var energyType: EnergyType
    var affectedDeviceID: UUID?
    var expectedValue: Double
    var actualValue: Double
    var description: String

    var isDismissed: Bool
    var resolvedAt: Date?

    init(
        detectedAt: Date = Date(),
        anomalyType: AnomalyType,
        severity: AnomalySeverity,
        energyType: EnergyType,
        expectedValue: Double,
        actualValue: Double,
        description: String
    ) {
        self.id = UUID()
        self.detectedAt = detectedAt
        self.anomalyType = anomalyType
        self.severity = severity
        self.energyType = energyType
        self.expectedValue = expectedValue
        self.actualValue = actualValue
        self.description = description
        self.isDismissed = false
    }

    // Calculate deviation percentage
    var deviationPercentage: Double {
        guard expectedValue > 0 else { return 0 }
        return abs(actualValue - expectedValue) / expectedValue * 100
    }

    // Cost impact based on deviation
    func costImpact(configuration: EnergyConfiguration) -> Double {
        let deviation = actualValue - expectedValue
        guard deviation > 0 else { return 0 }

        switch energyType {
        case .electricity:
            return deviation * configuration.electricityRatePerKWh
        case .gas:
            return deviation * (configuration.gasRatePerTherm ?? 0)
        case .water:
            return deviation * configuration.waterRatePerGallon
        case .solar:
            return 0
        }
    }

    // Dismiss anomaly
    func dismiss() {
        isDismissed = true
    }

    // Mark as resolved
    func resolve() {
        resolvedAt = Date()
        isDismissed = true
    }
}

enum AnomalyType: String, Codable {
    case suspectedLeak
    case unusuallyHigh
    case unusuallyLow
    case continuousUsage
    case spikage
}

enum AnomalySeverity: String, Codable {
    case low
    case medium
    case high
    case critical

    var color: String {
        switch self {
        case .low: return "blue"
        case .medium: return "yellow"
        case .high: return "orange"
        case .critical: return "red"
        }
    }

    var icon: String {
        switch self {
        case .low: return "info.circle"
        case .medium: return "exclamationmark.triangle"
        case .high: return "exclamationmark.triangle.fill"
        case .critical: return "exclamationmark.octagon.fill"
        }
    }
}

// MARK: - Preview Data
extension EnergyAnomaly {
    static var preview: EnergyAnomaly {
        EnergyAnomaly(
            anomalyType: .unusuallyHigh,
            severity: .medium,
            energyType: .electricity,
            expectedValue: 2.5,
            actualValue: 5.8,
            description: "Electricity usage 132% higher than normal for this time of day"
        )
    }

    static var previewLeak: EnergyAnomaly {
        EnergyAnomaly(
            anomalyType: .suspectedLeak,
            severity: .critical,
            energyType: .water,
            expectedValue: 0.5,
            actualValue: 3.2,
            description: "Suspected water leak - continuous usage detected for 6+ hours"
        )
    }

    static var previewMultiple: [EnergyAnomaly] {
        [
            EnergyAnomaly(
                anomalyType: .unusuallyHigh,
                severity: .medium,
                energyType: .electricity,
                expectedValue: 2.5,
                actualValue: 5.8,
                description: "Electricity usage 132% higher than normal"
            ),
            EnergyAnomaly(
                anomalyType: .continuousUsage,
                severity: .low,
                energyType: .electricity,
                expectedValue: 0.5,
                actualValue: 1.2,
                description: "Kitchen outlet running continuously for 8 hours"
            ),
            EnergyAnomaly(
                detectedAt: Calendar.current.date(byAdding: .day, value: -1, to: Date())!,
                anomalyType: .spikage,
                severity: .high,
                energyType: .electricity,
                expectedValue: 3.0,
                actualValue: 12.5,
                description: "Sudden power spike detected - HVAC system"
            )
        ]
    }
}
