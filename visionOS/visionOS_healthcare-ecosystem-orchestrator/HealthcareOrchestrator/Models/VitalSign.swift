import Foundation
import SwiftData

@Model
final class VitalSign {
    // MARK: - Identifiers
    @Attribute(.unique) var id: UUID
    var recordedAt: Date

    // MARK: - Vital Sign Values
    var heartRate: Int?                 // BPM
    var bloodPressureSystolic: Int?     // mmHg
    var bloodPressureDiastolic: Int?    // mmHg
    var respiratoryRate: Int?           // breaths per minute
    var temperature: Double?            // Celsius
    var oxygenSaturation: Int?          // SpO2 percentage
    var painScore: Int?                 // 0-10 scale

    // MARK: - Clinical Assessment
    var isAbnormal: Bool
    var alertLevel: AlertLevel
    var notes: String?

    // MARK: - Relationships
    @Relationship(inverse: \Patient.vitalSigns) var patient: Patient?

    // MARK: - Metadata
    var recordedBy: String?
    var deviceId: String?

    // MARK: - Computed Properties
    var bloodPressureString: String? {
        guard let systolic = bloodPressureSystolic,
              let diastolic = bloodPressureDiastolic else {
            return nil
        }
        return "\(systolic)/\(diastolic)"
    }

    var criticalValues: [String] {
        var critical: [String] = []

        if let hr = heartRate {
            if hr < 40 || hr > 120 {
                critical.append("Heart Rate: \(hr) BPM")
            }
        }

        if let systolic = bloodPressureSystolic {
            if systolic < 90 || systolic > 180 {
                critical.append("BP Systolic: \(systolic) mmHg")
            }
        }

        if let rr = respiratoryRate {
            if rr < 10 || rr > 30 {
                critical.append("Respiratory Rate: \(rr)")
            }
        }

        if let spo2 = oxygenSaturation {
            if spo2 < 90 {
                critical.append("SpO2: \(spo2)%")
            }
        }

        if let temp = temperature {
            if temp < 35.0 || temp > 39.0 {
                critical.append("Temperature: \(String(format: "%.1f", temp))°C")
            }
        }

        return critical
    }

    // MARK: - Initialization
    init(
        recordedAt: Date = Date(),
        heartRate: Int? = nil,
        bloodPressureSystolic: Int? = nil,
        bloodPressureDiastolic: Int? = nil,
        respiratoryRate: Int? = nil,
        temperature: Double? = nil,
        oxygenSaturation: Int? = nil,
        painScore: Int? = nil
    ) {
        self.id = UUID()
        self.recordedAt = recordedAt
        self.heartRate = heartRate
        self.bloodPressureSystolic = bloodPressureSystolic
        self.bloodPressureDiastolic = bloodPressureDiastolic
        self.respiratoryRate = respiratoryRate
        self.temperature = temperature
        self.oxygenSaturation = oxygenSaturation
        self.painScore = painScore

        // Calculate alert level
        self.alertLevel = Self.calculateAlertLevel(
            hr: heartRate,
            systolic: bloodPressureSystolic,
            rr: respiratoryRate,
            spo2: oxygenSaturation,
            temp: temperature
        )

        self.isAbnormal = self.alertLevel != .normal
    }

    // MARK: - Alert Level Calculation
    private static func calculateAlertLevel(
        hr: Int?,
        systolic: Int?,
        rr: Int?,
        spo2: Int?,
        temp: Double?
    ) -> AlertLevel {
        var criticalCount = 0

        if let hr = hr, hr < 40 || hr > 120 { criticalCount += 1 }
        if let systolic = systolic, systolic < 90 || systolic > 180 { criticalCount += 1 }
        if let rr = rr, rr < 10 || rr > 30 { criticalCount += 1 }
        if let spo2 = spo2, spo2 < 90 { criticalCount += 1 }
        if let temp = temp, temp < 35.0 || temp > 39.0 { criticalCount += 1 }

        if criticalCount >= 2 {
            return .emergency
        } else if criticalCount == 1 {
            return .critical
        } else if hr != nil || systolic != nil {
            // Check for warning levels
            if let hr = hr, (hr < 50 || hr > 100) { return .warning }
            if let systolic = systolic, (systolic < 100 || systolic > 140) { return .warning }
        }

        return .normal
    }
}

// MARK: - Alert Level
enum AlertLevel: String, Codable, Comparable {
    case normal = "Normal"
    case warning = "Warning"
    case critical = "Critical"
    case emergency = "Emergency"

    var sortOrder: Int {
        switch self {
        case .emergency: return 0
        case .critical: return 1
        case .warning: return 2
        case .normal: return 3
        }
    }

    static func < (lhs: AlertLevel, rhs: AlertLevel) -> Bool {
        lhs.sortOrder < rhs.sortOrder
    }

    var color: String {
        switch self {
        case .normal: return "blue"
        case .warning: return "yellow"
        case .critical: return "orange"
        case .emergency: return "red"
        }
    }
}

// MARK: - Preview Helpers
#if DEBUG
extension VitalSign {
    static var previewNormal: VitalSign {
        VitalSign(
            heartRate: 72,
            bloodPressureSystolic: 120,
            bloodPressureDiastolic: 80,
            respiratoryRate: 16,
            temperature: 37.0,
            oxygenSaturation: 98,
            painScore: 2
        )
    }

    static var previewCritical: VitalSign {
        VitalSign(
            heartRate: 112,
            bloodPressureSystolic: 90,
            bloodPressureDiastolic: 60,
            respiratoryRate: 24,
            temperature: 38.5,
            oxygenSaturation: 94,
            painScore: 7
        )
    }
}
#endif
