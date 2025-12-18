//
//  DiagnosticResult.swift
//  FieldServiceAR
//
//  AI diagnostic result model
//

import Foundation
import SwiftData

@Model
final class DiagnosticResult {
    @Attribute(.unique) var id: UUID
    var equipmentId: UUID
    var jobId: UUID?
    var timestamp: Date

    // Input
    var symptoms: [String] = []
    var sensorReadings: [String: Double] = [:]

    // Analysis
    var rootCause: String?
    var confidence: Float = 0.0
    var aiModelVersion: String

    // Recommendations
    var recommendedActions: [String] = []
    var predictedParts: [String] = []
    var estimatedRepairTime: TimeInterval?

    // Similar cases
    var similarCaseIds: [UUID] = []

    init(
        id: UUID = UUID(),
        equipmentId: UUID,
        jobId: UUID? = nil,
        aiModelVersion: String = "1.0"
    ) {
        self.id = id
        self.equipmentId = equipmentId
        self.jobId = jobId
        self.timestamp = Date()
        self.aiModelVersion = aiModelVersion
    }

    var isHighConfidence: Bool {
        confidence >= 0.8
    }

    var confidenceLevel: ConfidenceLevel {
        switch confidence {
        case 0.9...:
            return .veryHigh
        case 0.7..<0.9:
            return .high
        case 0.5..<0.7:
            return .medium
        case 0.3..<0.5:
            return .low
        default:
            return .veryLow
        }
    }
}

// Confidence Level
enum ConfidenceLevel: String {
    case veryHigh = "Very High"
    case high = "High"
    case medium = "Medium"
    case low = "Low"
    case veryLow = "Very Low"

    var color: String {
        switch self {
        case .veryHigh: return "#34C759"
        case .high: return "#34C759"
        case .medium: return "#FFD700"
        case .low: return "#FF9500"
        case .veryLow: return "#FF3B30"
        }
    }
}
