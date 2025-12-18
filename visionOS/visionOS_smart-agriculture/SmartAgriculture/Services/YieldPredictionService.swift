//
//  YieldPredictionService.swift
//  SmartAgriculture
//
//  Created by Claude Code
//  Copyright © 2025 Smart Agriculture. All rights reserved.
//

import Foundation

// MARK: - Yield Prediction Service

final class YieldPredictionService {
    // MARK: - Initialization

    init() {}

    // MARK: - Yield Prediction

    func predictYield(for field: Field, healthMetrics: HealthMetrics) async throws -> YieldPrediction {
        // Simulate AI prediction delay
        try await Task.sleep(for: .milliseconds(300))

        // Get typical yield for crop type
        let typicalYield = field.cropType.typicalYield

        // Calculate yield based on health factors
        let healthFactor = healthMetrics.overallScore / 100.0
        let moistureFactor = min(1.0, healthMetrics.moisture / 50.0)
        let ndviFactor = healthMetrics.ndvi / 0.8  // 0.8 is optimal NDVI
        let stressFactor = 1.0 - (healthMetrics.stressIndex / 100.0)

        // Weighted combination
        let yieldMultiplier = (
            healthFactor * 0.4 +
            moistureFactor * 0.2 +
            ndviFactor * 0.3 +
            stressFactor * 0.1
        )

        let estimatedYield = typicalYield * yieldMultiplier

        // Calculate confidence based on data quality
        let confidence = healthMetrics.confidence * 0.95

        // Calculate range (±10%)
        let range = (estimatedYield * 0.9)...(estimatedYield * 1.1)

        // Identify contributing factors
        let factors = identifyYieldFactors(
            healthMetrics: healthMetrics,
            healthFactor: healthFactor,
            moistureFactor: moistureFactor,
            ndviFactor: ndviFactor
        )

        return YieldPrediction(
            estimatedYield: estimatedYield,
            confidence: confidence,
            range: range,
            contributingFactors: factors
        )
    }

    // MARK: - Private Methods

    private func identifyYieldFactors(
        healthMetrics: HealthMetrics,
        healthFactor: Double,
        moistureFactor: Double,
        ndviFactor: Double
    ) -> [YieldFactor] {
        var factors: [YieldFactor] = []

        // Crop health factor
        let healthImpact = (healthFactor - 0.7) * 2  // Normalize around 0.7
        if abs(healthImpact) > 0.1 {
            factors.append(YieldFactor(
                name: "Crop Health",
                impact: healthImpact,
                description: healthImpact > 0
                    ? "Strong crop health supporting high yield"
                    : "Reduced health limiting yield potential"
            ))
        }

        // Moisture factor
        let moistureImpact = (moistureFactor - 0.8) * 1.5
        if abs(moistureImpact) > 0.1 {
            factors.append(YieldFactor(
                name: "Soil Moisture",
                impact: moistureImpact,
                description: moistureImpact > 0
                    ? "Optimal moisture supporting growth"
                    : "Moisture stress reducing yield"
            ))
        }

        // NDVI factor
        let ndviImpact = (ndviFactor - 0.9) * 1.8
        if abs(ndviImpact) > 0.1 {
            factors.append(YieldFactor(
                name: "Vegetation Index",
                impact: ndviImpact,
                description: ndviImpact > 0
                    ? "Excellent vegetation density"
                    : "Lower than optimal vegetation"
            ))
        }

        // Nutrient levels
        let nutrientImpact = (healthMetrics.nutrientLevels.nitrogen / 100.0 - 0.5) * 0.8
        if abs(nutrientImpact) > 0.1 {
            factors.append(YieldFactor(
                name: "Nutrient Levels",
                impact: nutrientImpact,
                description: nutrientImpact > 0
                    ? "Good nutrient availability"
                    : "Nutrient deficiency detected"
            ))
        }

        // Disease/pest pressure
        if healthMetrics.diseaseRisk.level >= .moderate {
            factors.append(YieldFactor(
                name: "Disease Pressure",
                impact: -0.3 * Double(healthMetrics.diseaseRisk.level == .severe ? 2 : 1),
                description: "Disease affecting crop performance"
            ))
        }

        if healthMetrics.pestPressure.level >= .moderate {
            factors.append(YieldFactor(
                name: "Pest Pressure",
                impact: -0.2 * Double(healthMetrics.pestPressure.level == .high ? 2 : 1),
                description: "Pest damage reducing yield"
            ))
        }

        return factors
    }
}
