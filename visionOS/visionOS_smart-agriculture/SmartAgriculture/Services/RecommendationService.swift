//
//  RecommendationService.swift
//  SmartAgriculture
//
//  Created by Claude Code
//  Copyright © 2025 Smart Agriculture. All rights reserved.
//

import Foundation

// MARK: - Recommendation Service

final class RecommendationService {
    // MARK: - Initialization

    init() {}

    // MARK: - Generate Recommendations

    func generateRecommendations(
        for field: Field,
        healthMetrics: HealthMetrics
    ) async throws -> [Recommendation] {
        // Simulate analysis delay
        try await Task.sleep(for: .milliseconds(200))

        var recommendations: [Recommendation] = []

        // Check nutrient levels
        if let nutrientRec = checkNutrientDeficiency(field: field, metrics: healthMetrics) {
            recommendations.append(nutrientRec)
        }

        // Check moisture levels
        if let moistureRec = checkMoistureLevels(field: field, metrics: healthMetrics) {
            recommendations.append(moistureRec)
        }

        // Check disease risk
        if let diseaseRec = checkDiseaseRisk(field: field, metrics: healthMetrics) {
            recommendations.append(diseaseRec)
        }

        // Check pest pressure
        if let pestRec = checkPestPressure(field: field, metrics: healthMetrics) {
            recommendations.append(pestRec)
        }

        // Sort by ROI (highest first)
        return recommendations.sorted { $0.roi > $1.roi }
    }

    // MARK: - Private Recommendation Checks

    private func checkNutrientDeficiency(
        field: Field,
        metrics: HealthMetrics
    ) -> Recommendation? {
        let nutrients = metrics.nutrientLevels

        // Check nitrogen
        if nutrients.nitrogen < 40 {
            let acresAffected = field.acreage * 0.3  // Assume 30% affected
            let lbsPerAcre: Double = 30
            let costPerLb: Double = 1.40
            let estimatedCost = acresAffected * lbsPerAcre * costPerLb

            // Calculate expected yield improvement
            let currentYieldLoss = (40 - nutrients.nitrogen) * 0.5  // % loss
            let yieldIncrease = currentYieldLoss * 0.7  // 70% recovery expected
            let pricePerBushel: Double = 6.50
            let expectedBenefit = acresAffected * (field.cropType.typicalYield * (yieldIncrease / 100)) * pricePerBushel

            return Recommendation(
                type: .fertilizer,
                priority: nutrients.nitrogen < 30 ? .high : .medium,
                description: "Apply \(Int(lbsPerAcre)) lbs/acre nitrogen to address deficiency",
                acresAffected: acresAffected,
                estimatedCost: estimatedCost,
                expectedBenefit: expectedBenefit,
                confidence: 0.94
            )
        }

        return nil
    }

    private func checkMoistureLevels(
        field: Field,
        metrics: HealthMetrics
    ) -> Recommendation? {
        if metrics.moisture < 30 {
            let acresAffected = field.acreage * 0.2  // Assume 20% affected
            let inchesOfWater: Double = 1.0
            let costPerAcreInch: Double = 15.0
            let estimatedCost = acresAffected * inchesOfWater * costPerAcreInch

            // Calculate yield protection
            let yieldLossWithoutWater: Double = 25  // % potential loss
            let pricePerBushel: Double = 6.50
            let expectedBenefit = acresAffected * (field.cropType.typicalYield * (yieldLossWithoutWater / 100)) * pricePerBushel

            return Recommendation(
                type: .irrigation,
                priority: metrics.moisture < 20 ? .high : .medium,
                description: "Schedule irrigation for low moisture areas",
                acresAffected: acresAffected,
                estimatedCost: estimatedCost,
                expectedBenefit: expectedBenefit,
                confidence: 0.89
            )
        }

        return nil
    }

    private func checkDiseaseRisk(
        field: Field,
        metrics: HealthMetrics
    ) -> Recommendation? {
        if metrics.diseaseRisk.level >= .moderate {
            let acresAffected = field.acreage * (metrics.diseaseRisk.level == .severe ? 0.4 : 0.2)
            let costPerAcre: Double = 35.0
            let estimatedCost = acresAffected * costPerAcre

            // Calculate yield protection
            let potentialLoss: Double = metrics.diseaseRisk.level == .severe ? 40 : 20  // %
            let treatmentEffectiveness: Double = 0.75  // 75% effective
            let yieldProtected = potentialLoss * treatmentEffectiveness
            let pricePerBushel: Double = 6.50
            let expectedBenefit = acresAffected * (field.cropType.typicalYield * (yieldProtected / 100)) * pricePerBushel

            let diseases = metrics.diseaseRisk.detectedDiseases.joined(separator: ", ")
            let description = diseases.isEmpty
                ? "Apply preventive fungicide for disease risk"
                : "Treat detected disease: \(diseases)"

            return Recommendation(
                type: .diseaseControl,
                priority: metrics.diseaseRisk.level == .severe ? .critical : .high,
                description: description,
                acresAffected: acresAffected,
                estimatedCost: estimatedCost,
                expectedBenefit: expectedBenefit,
                confidence: metrics.diseaseRisk.confidence
            )
        }

        return nil
    }

    private func checkPestPressure(
        field: Field,
        metrics: HealthMetrics
    ) -> Recommendation? {
        if metrics.pestPressure.level >= .moderate {
            let acresAffected = field.acreage * (metrics.pestPressure.level == .high ? 0.3 : 0.15)
            let costPerAcre: Double = 28.0
            let estimatedCost = acresAffected * costPerAcre

            // Calculate yield protection
            let potentialLoss: Double = metrics.pestPressure.level == .high ? 30 : 15  // %
            let treatmentEffectiveness: Double = 0.80  // 80% effective
            let yieldProtected = potentialLoss * treatmentEffectiveness
            let pricePerBushel: Double = 6.50
            let expectedBenefit = acresAffected * (field.cropType.typicalYield * (yieldProtected / 100)) * pricePerBushel

            let pests = metrics.pestPressure.detectedPests.joined(separator: ", ")
            let description = pests.isEmpty
                ? "Apply insecticide for pest control"
                : "Treat pest infestation: \(pests)"

            return Recommendation(
                type: .pestControl,
                priority: metrics.pestPressure.level == .high ? .high : .medium,
                description: description,
                acresAffected: acresAffected,
                estimatedCost: estimatedCost,
                expectedBenefit: expectedBenefit,
                confidence: metrics.pestPressure.confidence
            )
        }

        return nil
    }
}
