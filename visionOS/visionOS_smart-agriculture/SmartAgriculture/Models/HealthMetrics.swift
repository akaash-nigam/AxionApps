//
//  HealthMetrics.swift
//  SmartAgriculture
//
//  Created by Claude Code
//  Copyright © 2025 Smart Agriculture. All rights reserved.
//

import Foundation

// MARK: - Health Metrics

struct HealthMetrics: Codable, Hashable, Identifiable {
    let id: UUID
    var ndvi: Double              // Normalized Difference Vegetation Index (0-1)
    var ndre: Double              // Normalized Difference Red Edge (0-1)
    var moisture: Double          // Soil moisture percentage (0-100)
    var temperature: Double       // Canopy temperature (°F)
    var stressIndex: Double       // Combined stress indicator (0-100)
    var diseaseRisk: DiseaseRisk
    var pestPressure: PestPressure
    var nutrientLevels: NutrientProfile
    var overallScore: Double      // 0-100 health score

    var timestamp: Date
    var confidence: Double        // AI prediction confidence (0-1)

    init(
        id: UUID = UUID(),
        ndvi: Double,
        ndre: Double,
        moisture: Double,
        temperature: Double,
        stressIndex: Double,
        diseaseRisk: DiseaseRisk,
        pestPressure: PestPressure,
        nutrientLevels: NutrientProfile,
        overallScore: Double,
        timestamp: Date = Date(),
        confidence: Double = 0.95
    ) {
        self.id = id
        self.ndvi = ndvi
        self.ndre = ndre
        self.moisture = moisture
        self.temperature = temperature
        self.stressIndex = stressIndex
        self.diseaseRisk = diseaseRisk
        self.pestPressure = pestPressure
        self.nutrientLevels = nutrientLevels
        self.overallScore = overallScore
        self.timestamp = timestamp
        self.confidence = confidence
    }

    var healthStatus: HealthStatus {
        switch overallScore {
        case 80...100:
            return .excellent
        case 60..<80:
            return .good
        case 40..<60:
            return .moderate
        case 20..<40:
            return .poor
        default:
            return .critical
        }
    }
}

// MARK: - Health Status

enum HealthStatus: String, Codable {
    case excellent = "Excellent"
    case good = "Good"
    case moderate = "Moderate"
    case poor = "Poor"
    case critical = "Critical"

    var iconName: String {
        switch self {
        case .excellent, .good:
            return "checkmark.circle.fill"
        case .moderate:
            return "exclamationmark.triangle.fill"
        case .poor, .critical:
            return "xmark.octagon.fill"
        }
    }
}

// MARK: - Disease Risk

struct DiseaseRisk: Codable, Hashable {
    var level: RiskLevel
    var detectedDiseases: [String]
    var confidence: Double

    init(level: RiskLevel = .low, detectedDiseases: [String] = [], confidence: Double = 0.9) {
        self.level = level
        self.detectedDiseases = detectedDiseases
        self.confidence = confidence
    }
}

// MARK: - Pest Pressure

struct PestPressure: Codable, Hashable {
    var level: RiskLevel
    var detectedPests: [String]
    var confidence: Double

    init(level: RiskLevel = .low, detectedPests: [String] = [], confidence: Double = 0.9) {
        self.level = level
        self.detectedPests = detectedPests
        self.confidence = confidence
    }
}

// MARK: - Risk Level

enum RiskLevel: String, Codable, Comparable {
    case low = "Low"
    case moderate = "Moderate"
    case high = "High"
    case severe = "Severe"

    static func < (lhs: RiskLevel, rhs: RiskLevel) -> Bool {
        let order: [RiskLevel] = [.low, .moderate, .high, .severe]
        guard let lhsIndex = order.firstIndex(of: lhs),
              let rhsIndex = order.firstIndex(of: rhs) else {
            return false
        }
        return lhsIndex < rhsIndex
    }
}

// MARK: - Nutrient Profile

struct NutrientProfile: Codable, Hashable {
    var nitrogen: Double      // N percentage (0-100)
    var phosphorus: Double    // P percentage (0-100)
    var potassium: Double     // K percentage (0-100)
    var ph: Double            // Soil pH (0-14)

    init(nitrogen: Double = 50.0, phosphorus: Double = 50.0, potassium: Double = 50.0, ph: Double = 6.5) {
        self.nitrogen = nitrogen
        self.phosphorus = phosphorus
        self.potassium = potassium
        self.ph = ph
    }

    var isBalanced: Bool {
        return nitrogen >= 40 && phosphorus >= 40 && potassium >= 40 &&
               ph >= 6.0 && ph <= 7.5
    }

    static let adequate = NutrientProfile(nitrogen: 60, phosphorus: 55, potassium: 58, ph: 6.5)
}

// MARK: - Health Snapshot

struct HealthSnapshot: Codable, Hashable, Identifiable {
    let id: UUID
    let metrics: HealthMetrics
    let timestamp: Date

    init(id: UUID = UUID(), metrics: HealthMetrics, timestamp: Date = Date()) {
        self.id = id
        self.metrics = metrics
        self.timestamp = timestamp
    }
}

// MARK: - Mock Data Extension

extension HealthMetrics {
    static func mock(healthScore: Double = 85.0, confidence: Double = 0.92) -> HealthMetrics {
        return HealthMetrics(
            ndvi: 0.75,
            ndre: 0.70,
            moisture: 45.0,
            temperature: 72.0,
            stressIndex: 15.0,
            diseaseRisk: DiseaseRisk(level: .low),
            pestPressure: PestPressure(level: .low),
            nutrientLevels: .adequate,
            overallScore: healthScore,
            confidence: confidence
        )
    }

    static func mockPoor() -> HealthMetrics {
        return HealthMetrics(
            ndvi: 0.45,
            ndre: 0.40,
            moisture: 25.0,
            temperature: 85.0,
            stressIndex: 65.0,
            diseaseRisk: DiseaseRisk(level: .high, detectedDiseases: ["Leaf Blight"]),
            pestPressure: PestPressure(level: .moderate, detectedPests: ["Aphids"]),
            nutrientLevels: NutrientProfile(nitrogen: 30, phosphorus: 45, potassium: 40, ph: 5.8),
            overallScore: 35.0,
            confidence: 0.88
        )
    }
}
