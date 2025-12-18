//
//  HealthAnalysisService.swift
//  SmartAgriculture
//
//  Created by Claude Code
//  Copyright © 2025 Smart Agriculture. All rights reserved.
//

import Foundation

// MARK: - Health Analysis Service

final class HealthAnalysisService {
    // MARK: - Initialization

    init() {}

    // MARK: - Health Analysis

    func analyzeField(_ field: Field) async throws -> HealthMetrics {
        // Simulate AI analysis delay
        try await Task.sleep(for: .milliseconds(500))

        // Calculate NDVI (simulated - would normally come from satellite imagery)
        let ndvi = calculateNDVI(for: field)

        // Calculate other metrics
        let ndre = ndvi * 0.93  // NDRE is typically slightly lower than NDVI
        let moisture = calculateMoisture(for: field)
        let temperature = calculateTemperature(for: field)
        let stressIndex = calculateStressIndex(ndvi: ndvi, moisture: moisture, temperature: temperature)

        // Assess risks
        let diseaseRisk = assessDiseaseRisk(stressIndex: stressIndex)
        let pestPressure = assessPestPressure(stressIndex: stressIndex)

        // Calculate nutrient levels
        let nutrients = calculateNutrientLevels(for: field)

        // Calculate overall health score
        let overallScore = calculateOverallHealth(
            ndvi: ndvi,
            moisture: moisture,
            stressIndex: stressIndex,
            nutrients: nutrients
        )

        // Create health metrics
        let metrics = HealthMetrics(
            ndvi: ndvi,
            ndre: ndre,
            moisture: moisture,
            temperature: temperature,
            stressIndex: stressIndex,
            diseaseRisk: diseaseRisk,
            pestPressure: pestPressure,
            nutrientLevels: nutrients,
            overallScore: overallScore,
            confidence: 0.92
        )

        return metrics
    }

    // MARK: - Private Calculation Methods

    private func calculateNDVI(for field: Field) -> Double {
        // Simulate NDVI calculation
        // In production, this would analyze actual satellite imagery
        guard let currentHealth = field.currentHealthScore else {
            return 0.5  // Default moderate value
        }

        // Convert health score to NDVI (0-1 range)
        // Healthy fields typically have NDVI > 0.7
        return 0.3 + (currentHealth / 100.0) * 0.6
    }

    private func calculateMoisture(for field: Field) -> Double {
        // Simulate moisture calculation
        // Would normally come from sensors or satellite data
        let baseM moisture: Double

        switch field.cropType {
        case .corn:
            moisture = Double.random(in: 35...55)
        case .soybeans:
            moisture = Double.random(in: 30...50)
        case .wheat:
            moisture = Double.random(in: 25...45)
        default:
            moisture = Double.random(in: 30...50)
        }

        return moisture
    }

    private func calculateTemperature(for field: Field) -> Double {
        // Simulate canopy temperature
        // Would normally come from infrared sensors
        return Double.random(in: 68...82)
    }

    private func calculateStressIndex(ndvi: Double, moisture: Double, temperature: Double) -> Double {
        // Calculate composite stress index (0-100)
        // Higher values indicate more stress

        let ndviStress = max(0, (0.8 - ndvi) / 0.8) * 40  // 0-40 points
        let tempStress = max(0, (temperature - 75) / 15) * 30  // 0-30 points
        let moistureStress = max(0, (40 - moisture) / 40) * 30  // 0-30 points

        return min(100, ndviStress + tempStress + moistureStress)
    }

    private func assessDiseaseRisk(stressIndex: Double) -> DiseaseRisk {
        // Higher stress = higher disease risk
        let level: RiskLevel

        if stressIndex > 60 {
            level = .severe
        } else if stressIndex > 40 {
            level = .high
        } else if stressIndex > 20 {
            level = .moderate
        } else {
            level = .low
        }

        // Simulate disease detection
        var diseases: [String] = []
        if level == .severe || level == .high {
            diseases = ["Leaf Blight", "Root Rot"].filter { _ in Bool.random() }
        }

        return DiseaseRisk(
            level: level,
            detectedDiseases: diseases,
            confidence: 0.88
        )
    }

    private func assessPestPressure(stressIndex: Double) -> PestPressure {
        // Stressed plants attract more pests
        let level: RiskLevel

        if stressIndex > 50 {
            level = .high
        } else if stressIndex > 30 {
            level = .moderate
        } else {
            level = .low
        }

        // Simulate pest detection
        var pests: [String] = []
        if level == .high {
            pests = ["Aphids", "Corn Borer"].filter { _ in Bool.random() }
        } else if level == .moderate {
            pests = ["Aphids"].filter { _ in Bool.random() }
        }

        return PestPressure(
            level: level,
            detectedPests: pests,
            confidence: 0.85
        )
    }

    private func calculateNutrientLevels(for field: Field) -> NutrientProfile {
        // Simulate nutrient analysis
        // Would normally come from soil samples
        return NutrientProfile(
            nitrogen: Double.random(in: 30...70),
            phosphorus: Double.random(in: 35...65),
            potassium: Double.random(in: 40...70),
            ph: Double.random(in: 5.5...7.5)
        )
    }

    private func calculateOverallHealth(
        ndvi: Double,
        moisture: Double,
        stressIndex: Double,
        nutrients: NutrientProfile
    ) -> Double {
        // Weighted average of health factors
        let ndviScore = ndvi * 100 * 0.4          // 40% weight
        let moistureScore = (moisture / 50) * 100 * 0.2  // 20% weight
        let stressScore = (100 - stressIndex) * 0.3      // 30% weight
        let nutrientScore = (nutrients.nitrogen / 100) * 100 * 0.1  // 10% weight

        let totalScore = ndviScore + moistureScore + stressScore + nutrientScore

        return min(100, max(0, totalScore))
    }
}
