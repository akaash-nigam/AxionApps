//
//  BiometricReading.swift
//  SpatialWellness
//
//  Created by Claude on 2025-11-17.
//  Copyright © 2025 Spatial Wellness Platform. All rights reserved.
//

import Foundation
import SwiftData

/// Biometric reading model representing health measurements
/// Supports various biometric types from multiple data sources
@Model
final class BiometricReading {

    // MARK: - Properties

    /// Unique identifier
    @Attribute(.unique) var id: UUID

    /// Timestamp when reading was taken
    var timestamp: Date

    /// User ID (foreign key)
    var userId: UUID

    /// Type of biometric reading
    var type: BiometricType

    /// Numeric value of the reading
    var value: Double

    /// Unit of measurement
    var unit: String

    /// Data source (HealthKit, manual entry, device, etc.)
    var source: DataSource

    /// Confidence level (0.0 - 1.0)
    var confidence: Double

    /// Optional notes or context
    var notes: String?

    // MARK: - Initialization

    init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        userId: UUID,
        type: BiometricType,
        value: Double,
        unit: String,
        source: DataSource = .manualEntry,
        confidence: Double = 1.0,
        notes: String? = nil
    ) {
        self.id = id
        self.timestamp = timestamp
        self.userId = userId
        self.type = type
        self.value = value
        self.unit = unit
        self.source = source
        self.confidence = confidence
        self.notes = notes
    }

    // MARK: - Computed Properties

    /// Formatted value with unit
    var formattedValue: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = type.decimalPlaces
        let valueString = formatter.string(from: NSNumber(value: value)) ?? "\(value)"
        return "\(valueString) \(unit)"
    }

    /// Status based on normal ranges
    var status: BiometricStatus {
        type.status(for: value)
    }

    /// Color for visualization
    var statusColor: String {
        switch status {
        case .optimal:
            return "green"
        case .normal:
            return "blue"
        case .caution:
            return "yellow"
        case .warning:
            return "orange"
        case .critical:
            return "red"
        }
    }

    // MARK: - Methods

    /// Check if reading is recent (within last hour)
    func isRecent() -> Bool {
        let hourAgo = Date().addingTimeInterval(-3600)
        return timestamp > hourAgo
    }

    /// Check if reading is from today
    func isToday() -> Bool {
        Calendar.current.isDateInToday(timestamp)
    }

    /// Age of reading in minutes
    func ageInMinutes() -> Int {
        let interval = Date().timeIntervalSince(timestamp)
        return Int(interval / 60)
    }
}

// MARK: - Biometric Type

/// Types of biometric measurements
enum BiometricType: String, Codable, CaseIterable, Identifiable {
    var id: String { rawValue }

    // Cardiovascular
    case heartRate
    case heartRateVariability
    case bloodPressureSystolic
    case bloodPressureDiastolic
    case bloodOxygenSaturation

    // Vital Signs
    case bodyTemperature
    case respiratoryRate

    // Metabolic
    case bloodGlucose
    case weight
    case bodyMassIndex
    case bodyFatPercentage

    // Activity
    case stepCount
    case activeEnergyBurned
    case distanceWalking
    case floorsClimbed

    // Sleep
    case sleepDuration
    case sleepQualityScore
    case remSleep
    case deepSleep

    // Mental Health
    case stressLevel
    case moodScore
    case mindfulMinutes

    /// Display name
    var displayName: String {
        switch self {
        case .heartRate:
            return "Heart Rate"
        case .heartRateVariability:
            return "HRV"
        case .bloodPressureSystolic:
            return "Systolic BP"
        case .bloodPressureDiastolic:
            return "Diastolic BP"
        case .bloodOxygenSaturation:
            return "Blood Oxygen"
        case .bodyTemperature:
            return "Temperature"
        case .respiratoryRate:
            return "Respiratory Rate"
        case .bloodGlucose:
            return "Blood Glucose"
        case .weight:
            return "Weight"
        case .bodyMassIndex:
            return "BMI"
        case .bodyFatPercentage:
            return "Body Fat %"
        case .stepCount:
            return "Steps"
        case .activeEnergyBurned:
            return "Active Calories"
        case .distanceWalking:
            return "Distance"
        case .floorsClimbed:
            return "Floors Climbed"
        case .sleepDuration:
            return "Sleep Duration"
        case .sleepQualityScore:
            return "Sleep Quality"
        case .remSleep:
            return "REM Sleep"
        case .deepSleep:
            return "Deep Sleep"
        case .stressLevel:
            return "Stress Level"
        case .moodScore:
            return "Mood"
        case .mindfulMinutes:
            return "Mindful Minutes"
        }
    }

    /// SF Symbol icon name
    var iconName: String {
        switch self {
        case .heartRate, .heartRateVariability:
            return "heart.fill"
        case .bloodPressureSystolic, .bloodPressureDiastolic:
            return "waveform.path.ecg"
        case .bloodOxygenSaturation:
            return "lungs.fill"
        case .bodyTemperature:
            return "thermometer"
        case .respiratoryRate:
            return "wind"
        case .bloodGlucose:
            return "drop.fill"
        case .weight, .bodyMassIndex, .bodyFatPercentage:
            return "scalemass.fill"
        case .stepCount:
            return "figure.walk"
        case .activeEnergyBurned:
            return "flame.fill"
        case .distanceWalking:
            return "location.fill"
        case .floorsClimbed:
            return "stairs"
        case .sleepDuration, .sleepQualityScore, .remSleep, .deepSleep:
            return "bed.double.fill"
        case .stressLevel:
            return "brain.head.profile"
        case .moodScore:
            return "face.smiling.fill"
        case .mindfulMinutes:
            return "figure.mind.and.body"
        }
    }

    /// Default unit
    var defaultUnit: String {
        switch self {
        case .heartRate:
            return "BPM"
        case .heartRateVariability:
            return "ms"
        case .bloodPressureSystolic, .bloodPressureDiastolic:
            return "mmHg"
        case .bloodOxygenSaturation, .bodyFatPercentage:
            return "%"
        case .bodyTemperature:
            return "°F"
        case .respiratoryRate:
            return "breaths/min"
        case .bloodGlucose:
            return "mg/dL"
        case .weight:
            return "lbs"
        case .bodyMassIndex:
            return "BMI"
        case .stepCount:
            return "steps"
        case .activeEnergyBurned:
            return "cal"
        case .distanceWalking:
            return "mi"
        case .floorsClimbed:
            return "floors"
        case .sleepDuration, .remSleep, .deepSleep:
            return "hours"
        case .sleepQualityScore, .stressLevel, .moodScore:
            return "score"
        case .mindfulMinutes:
            return "min"
        }
    }

    /// Number of decimal places to display
    var decimalPlaces: Int {
        switch self {
        case .stepCount, .floorsClimbed, .mindfulMinutes:
            return 0
        case .heartRate, .bloodPressureSystolic, .bloodPressureDiastolic, .stressLevel, .moodScore, .sleepQualityScore:
            return 0
        case .weight, .distanceWalking:
            return 1
        default:
            return 2
        }
    }

    /// Determine status based on value
    func status(for value: Double) -> BiometricStatus {
        switch self {
        case .heartRate:
            if value < 60 { return .caution }
            if value <= 100 { return .optimal }
            if value <= 120 { return .caution }
            return .warning

        case .bloodPressureSystolic:
            if value < 120 { return .optimal }
            if value < 130 { return .normal }
            if value < 140 { return .caution }
            return .warning

        case .bloodOxygenSaturation:
            if value >= 95 { return .optimal }
            if value >= 90 { return .normal }
            return .warning

        case .stressLevel:
            if value <= 3 { return .optimal }
            if value <= 5 { return .normal }
            if value <= 7 { return .caution }
            return .warning

        case .sleepQualityScore:
            if value >= 85 { return .optimal }
            if value >= 70 { return .normal }
            if value >= 50 { return .caution }
            return .warning

        default:
            return .normal
        }
    }
}

// MARK: - Data Source

/// Source of biometric data
enum DataSource: String, Codable {
    case appleWatch = "apple_watch"
    case healthKit = "health_kit"
    case manualEntry = "manual_entry"
    case fitbit = "fitbit"
    case garmin = "garmin"
    case whoop = "whoop"
    case ouraRing = "oura_ring"
    case telehealth = "telehealth"
    case labResults = "lab_results"

    var displayName: String {
        switch self {
        case .appleWatch:
            return "Apple Watch"
        case .healthKit:
            return "HealthKit"
        case .manualEntry:
            return "Manual Entry"
        case .fitbit:
            return "Fitbit"
        case .garmin:
            return "Garmin"
        case .whoop:
            return "WHOOP"
        case .ouraRing:
            return "Oura Ring"
        case .telehealth:
            return "Telehealth"
        case .labResults:
            return "Lab Results"
        }
    }
}

// MARK: - Biometric Status

/// Health status based on biometric value
enum BiometricStatus: String, Codable {
    case optimal    // Best possible range
    case normal     // Within normal range
    case caution    // Slightly outside normal, watch
    case warning    // Outside normal, take action
    case critical   // Dangerous level, seek help

    var displayName: String {
        rawValue.capitalized
    }

    var emoji: String {
        switch self {
        case .optimal:
            return "✅"
        case .normal:
            return "👍"
        case .caution:
            return "⚠️"
        case .warning:
            return "🔶"
        case .critical:
            return "🚨"
        }
    }
}
