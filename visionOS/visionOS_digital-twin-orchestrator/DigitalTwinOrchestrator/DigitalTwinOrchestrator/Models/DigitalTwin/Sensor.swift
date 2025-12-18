import Foundation
import SwiftData

/// Sensor Model - Represents a sensor attached to a digital twin
@Model
final class Sensor {
    @Attribute(.unique) var id: UUID
    var name: String
    var sensorType: SensorType
    var unit: String

    // Current reading
    var currentValue: Double
    var timestamp: Date
    var quality: DataQuality
    var isActive: Bool

    // Thresholds
    var normalRangeLower: Double
    var normalRangeUpper: Double
    var warningRangeLower: Double
    var warningRangeUpper: Double
    var criticalThreshold: Double

    // Historical data reference
    var timeSeriesDataURL: URL?

    // Visualization
    var visualizationType: VisualizationType
    var displayPositionX: Float
    var displayPositionY: Float
    var displayPositionZ: Float

    // Metadata
    var manufacturer: String?
    var modelNumber: String?
    var calibrationDate: Date?
    var nextCalibrationDate: Date?

    @Relationship(inverse: \DigitalTwin.sensors)
    var digitalTwin: DigitalTwin?

    init(
        id: UUID = UUID(),
        name: String,
        sensorType: SensorType,
        unit: String,
        currentValue: Double = 0.0,
        normalRange: ClosedRange<Double> = 0...100,
        warningRange: ClosedRange<Double> = -10...110,
        criticalThreshold: Double = 120,
        visualizationType: VisualizationType = .gauge
    ) {
        self.id = id
        self.name = name
        self.sensorType = sensorType
        self.unit = unit
        self.currentValue = currentValue
        self.timestamp = Date()
        self.quality = .good
        self.isActive = true

        self.normalRangeLower = normalRange.lowerBound
        self.normalRangeUpper = normalRange.upperBound
        self.warningRangeLower = warningRange.lowerBound
        self.warningRangeUpper = warningRange.upperBound
        self.criticalThreshold = criticalThreshold

        self.visualizationType = visualizationType
        self.displayPositionX = 0
        self.displayPositionY = 0
        self.displayPositionZ = 0
    }

    // MARK: - Computed Properties

    var normalRange: ClosedRange<Double> {
        normalRangeLower...normalRangeUpper
    }

    var warningRange: ClosedRange<Double> {
        warningRangeLower...warningRangeUpper
    }

    var status: SensorStatus {
        guard isActive else { return .offline }

        if currentValue >= criticalThreshold {
            return .critical
        } else if !normalRange.contains(currentValue) {
            return .warning
        } else {
            return .normal
        }
    }

    var statusColor: String {
        switch status {
        case .normal: return "green"
        case .warning: return "yellow"
        case .critical: return "red"
        case .offline: return "gray"
        }
    }

    var formattedValue: String {
        String(format: "%.2f %@", currentValue, unit)
    }

    var displayPosition: SIMD3<Float> {
        SIMD3(displayPositionX, displayPositionY, displayPositionZ)
    }

    // MARK: - Methods

    func updateReading(_ value: Double, quality: DataQuality = .good) {
        currentValue = value
        timestamp = Date()
        self.quality = quality
    }

    func isWithinNormalRange() -> Bool {
        normalRange.contains(currentValue)
    }

    func isCalibrationDue() -> Bool {
        guard let nextCalibration = nextCalibrationDate else {
            return false
        }
        return Date() >= nextCalibration
    }
}

// MARK: - Supporting Types

enum SensorType: String, Codable {
    case temperature
    case pressure
    case vibration
    case flow
    case power
    case speed
    case humidity
    case current
    case voltage
    case frequency
    case level
    case ph
    case conductivity
    case custom

    var displayName: String {
        rawValue.capitalized
    }

    var iconName: String {
        switch self {
        case .temperature: return "thermometer"
        case .pressure: return "gauge"
        case .vibration: return "waveform"
        case .flow: return "drop.fill"
        case .power: return "bolt.fill"
        case .speed: return "speedometer"
        case .humidity: return "humidity.fill"
        case .current: return "bolt.circle.fill"
        case .voltage: return "battery.100"
        case .frequency: return "waveform.path"
        case .level: return "chart.bar.fill"
        case .ph: return "flask.fill"
        case .conductivity: return "antenna.radiowaves.left.and.right"
        case .custom: return "sensor.fill"
        }
    }

    var defaultUnit: String {
        switch self {
        case .temperature: return "°C"
        case .pressure: return "bar"
        case .vibration: return "Hz"
        case .flow: return "L/min"
        case .power: return "kW"
        case .speed: return "RPM"
        case .humidity: return "%"
        case .current: return "A"
        case .voltage: return "V"
        case .frequency: return "Hz"
        case .level: return "m"
        case .ph: return "pH"
        case .conductivity: return "μS/cm"
        case .custom: return "units"
        }
    }
}

enum DataQuality: String, Codable {
    case excellent
    case good
    case fair
    case poor
    case uncertain

    var displayName: String {
        rawValue.capitalized
    }

    var reliability: Double {
        switch self {
        case .excellent: return 1.0
        case .good: return 0.9
        case .fair: return 0.7
        case .poor: return 0.5
        case .uncertain: return 0.3
        }
    }
}

enum VisualizationType: String, Codable {
    case gauge
    case heatmap
    case waveform
    case particle

    var displayName: String {
        rawValue.capitalized
    }
}

enum SensorStatus {
    case normal
    case warning
    case critical
    case offline
}

// MARK: - Extensions

extension Sensor {
    /// Create a sample sensor for testing
    static func sample(name: String, type: SensorType) -> Sensor {
        let sensor = Sensor(
            name: name,
            sensorType: type,
            unit: type.defaultUnit,
            currentValue: Double.random(in: 20...80),
            normalRange: 10...90,
            warningRange: 0...100,
            criticalThreshold: 110,
            visualizationType: type == .temperature ? .heatmap : .gauge
        )

        sensor.manufacturer = "Industrial Sensors Inc."
        sensor.modelNumber = "IS-\(type.rawValue.uppercased())-2000"
        sensor.calibrationDate = Date().addingTimeInterval(-30 * 24 * 3600) // 30 days ago
        sensor.nextCalibrationDate = Date().addingTimeInterval(335 * 24 * 3600) // 335 days from now

        return sensor
    }

    /// Create sample time series data
    func generateSampleTimeSeriesData(count: Int = 100) -> [SensorReading] {
        var readings: [SensorReading] = []
        let now = Date()

        for i in 0..<count {
            let timestamp = now.addingTimeInterval(-Double(count - i) * 60) // Every minute
            let value = currentValue + Double.random(in: -5...5) // Random variation
            readings.append(SensorReading(
                sensorId: id,
                value: value,
                timestamp: timestamp,
                quality: .good
            ))
        }

        return readings
    }
}

// MARK: - Sensor Reading

struct SensorReading: Codable, Identifiable {
    var id: UUID = UUID()
    let sensorId: UUID
    let value: Double
    let timestamp: Date
    let quality: DataQuality
}
