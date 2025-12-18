//
//  HealthAnalysisServiceTests.swift
//  SmartAgricultureTests
//
//  Created by Claude Code
//  Copyright © 2025 Smart Agriculture. All rights reserved.
//

import Testing
@testable import SmartAgriculture

@Suite("Health Analysis Service Tests")
struct HealthAnalysisServiceTests {

    @Test("Analyze field returns valid health metrics")
    func testAnalyzeFieldReturnsMetrics() async throws {
        let service = HealthAnalysisService()
        let field = Field.mock(health: 85.0)

        let metrics = try await service.analyzeField(field)

        // Verify basic properties
        #expect(metrics.ndvi >= 0 && metrics.ndvi <= 1)
        #expect(metrics.overallScore >= 0 && metrics.overallScore <= 100)
        #expect(metrics.moisture >= 0 && metrics.moisture <= 100)
        #expect(metrics.confidence > 0)
    }

    @Test("Health analysis produces consistent results")
    func testAnalysisConsistency() async throws {
        let service = HealthAnalysisService()
        let field = Field.mock(health: 90.0)

        let metrics1 = try await service.analyzeField(field)
        let metrics2 = try await service.analyzeField(field)

        // Results should be in similar range for same field
        let scoreDifference = abs(metrics1.overallScore - metrics2.overallScore)
        #expect(scoreDifference < 30)  // Allow some randomness but not drastic differences
    }

    @Test("High health field produces good NDVI")
    func testHighHealthFieldNDVI() async throws {
        let service = HealthAnalysisService()
        let healthyField = Field.mock(health: 95.0)

        let metrics = try await service.analyzeField(healthyField)

        // Healthy fields should have higher NDVI
        #expect(metrics.ndvi >= 0.6)
    }

    @Test("Low health field produces lower overall score")
    func testLowHealthFieldScore() async throws {
        let service = HealthAnalysisService()
        let problemField = Field.mock(health: 40.0)

        let metrics = try await service.analyzeField(problemField)

        // Overall score should reflect the poor field health
        #expect(metrics.overallScore < 70.0)
    }

    @Test("Disease risk assessment")
    func testDiseaseRiskAssessment() async throws {
        let service = HealthAnalysisService()
        let field = Field.mock()

        let metrics = try await service.analyzeField(field)

        // Disease risk should be valid
        #expect(metrics.diseaseRisk.confidence > 0)
        #expect(metrics.diseaseRisk.confidence <= 1.0)
    }
}
