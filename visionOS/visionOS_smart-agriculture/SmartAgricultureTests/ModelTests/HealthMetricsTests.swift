//
//  HealthMetricsTests.swift
//  SmartAgricultureTests
//
//  Created by Claude Code
//  Copyright © 2025 Smart Agriculture. All rights reserved.
//

import Testing
@testable import SmartAgriculture

@Suite("Health Metrics Tests")
struct HealthMetricsTests {

    @Test("Health metrics creation with default values")
    func testHealthMetricsCreation() {
        let metrics = HealthMetrics(
            ndvi: 0.8,
            ndre: 0.75,
            moisture: 45.0,
            temperature: 72.0,
            stressIndex: 15.0,
            diseaseRisk: DiseaseRisk(),
            pestPressure: PestPressure(),
            nutrientLevels: .adequate,
            overallScore: 85.0
        )

        #expect(metrics.ndvi == 0.8)
        #expect(metrics.overallScore == 85.0)
        #expect(metrics.confidence == 0.95)  // Default value
    }

    @Test("Health status calculation for excellent health")
    func testExcellentHealthStatus() {
        let metrics = HealthMetrics.mock(healthScore: 92.0)

        #expect(metrics.healthStatus == .excellent)
    }

    @Test("Health status calculation for poor health")
    func testPoorHealthStatus() {
        let metrics = HealthMetrics.mockPoor()

        #expect(metrics.overallScore == 35.0)
        #expect(metrics.healthStatus == .poor)
    }

    @Test("Disease risk levels")
    func testDiseaseRiskLevels() {
        let lowRisk = DiseaseRisk(level: .low)
        let highRisk = DiseaseRisk(level: .high, detectedDiseases: ["Leaf Blight"])

        #expect(lowRisk.level == .low)
        #expect(lowRisk.detectedDiseases.isEmpty)

        #expect(highRisk.level == .high)
        #expect(highRisk.detectedDiseases.count == 1)
        #expect(highRisk.detectedDiseases[0] == "Leaf Blight")
    }

    @Test("Nutrient profile balance check")
    func testNutrientBalance() {
        let balanced = NutrientProfile.adequate
        #expect(balanced.isBalanced == true)

        let unbalanced = NutrientProfile(nitrogen: 20, phosphorus: 50, potassium: 50, ph: 6.5)
        #expect(unbalanced.isBalanced == false)
    }

    @Test("Risk level comparison")
    func testRiskLevelComparison() {
        #expect(RiskLevel.low < RiskLevel.moderate)
        #expect(RiskLevel.moderate < RiskLevel.high)
        #expect(RiskLevel.high < RiskLevel.severe)
    }
}
