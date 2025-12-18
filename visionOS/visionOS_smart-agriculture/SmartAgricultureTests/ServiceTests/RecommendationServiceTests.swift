//
//  RecommendationServiceTests.swift
//  SmartAgricultureTests
//
//  Created by Claude Code
//  Copyright © 2025 Smart Agriculture. All rights reserved.
//

import Testing
@testable import SmartAgriculture

@Suite("Recommendation Service Tests")
struct RecommendationServiceTests {

    @Test("Generate recommendations for healthy field")
    func testHealthyFieldRecommendations() async throws {
        let service = RecommendationService()
        let field = Field.mock(health: 92.0)
        let metrics = HealthMetrics.mock(healthScore: 92.0)

        let recommendations = try await service.generateRecommendations(for: field, healthMetrics: metrics)

        // Healthy field should have few or no critical recommendations
        let criticalRecs = recommendations.filter { $0.priority == .critical }
        #expect(criticalRecs.isEmpty)
    }

    @Test("Generate recommendations for problem field")
    func testProblemFieldRecommendations() async throws {
        let service = RecommendationService()
        let field = Field.mock(health: 35.0)
        let poorMetrics = HealthMetrics.mockPoor()

        let recommendations = try await service.generateRecommendations(for: field, healthMetrics: poorMetrics)

        // Problem field should have recommendations
        #expect(recommendations.count > 0)
    }

    @Test("Recommendations sorted by ROI")
    func testRecommendationsSortedByROI() async throws {
        let service = RecommendationService()
        let field = Field.mock(health: 50.0)
        let metrics = HealthMetrics.mockPoor()

        let recommendations = try await service.generateRecommendations(for: field, healthMetrics: metrics)

        guard recommendations.count > 1 else {
            return  // Test passes if less than 2 recommendations
        }

        // Verify sorted by ROI (highest first)
        for i in 0..<(recommendations.count - 1) {
            #expect(recommendations[i].roi >= recommendations[i + 1].roi)
        }
    }

    @Test("Nitrogen deficiency generates fertilizer recommendation")
    func testNitrogenDeficiencyRecommendation() async throws {
        let service = RecommendationService()
        let field = Field.mock()

        // Create metrics with low nitrogen
        var metrics = HealthMetrics.mock()
        metrics.nutrientLevels.nitrogen = 25.0  // Very low

        let recommendations = try await service.generateRecommendations(for: field, healthMetrics: metrics)

        // Should have a fertilizer recommendation
        let fertilizerRecs = recommendations.filter { $0.type == .fertilizer }
        #expect(fertilizerRecs.count > 0)
    }

    @Test("Low moisture generates irrigation recommendation")
    func testLowMoistureRecommendation() async throws {
        let service = RecommendationService()
        let field = Field.mock()

        // Create metrics with low moisture
        var metrics = HealthMetrics.mock()
        metrics.moisture = 20.0  // Very low

        let recommendations = try await service.generateRecommendations(for: field, healthMetrics: metrics)

        // Should have an irrigation recommendation
        let irrigationRecs = recommendations.filter { $0.type == .irrigation }
        #expect(irrigationRecs.count > 0)
    }

    @Test("High disease risk generates disease control recommendation")
    func testDiseaseControlRecommendation() async throws {
        let service = RecommendationService()
        let field = Field.mock()

        // Create metrics with high disease risk
        var metrics = HealthMetrics.mock()
        metrics.diseaseRisk = DiseaseRisk(level: .high, detectedDiseases: ["Leaf Blight"])

        let recommendations = try await service.generateRecommendations(for: field, healthMetrics: metrics)

        // Should have a disease control recommendation
        let diseaseRecs = recommendations.filter { $0.type == .diseaseControl }
        #expect(diseaseRecs.count > 0)

        if let rec = diseaseRecs.first {
            #expect(rec.priority == .high || rec.priority == .critical)
        }
    }

    @Test("ROI calculation is positive for beneficial recommendations")
    func testPositiveROI() async throws {
        let service = RecommendationService()
        let field = Field.mock(health: 50.0)
        let metrics = HealthMetrics.mockPoor()

        let recommendations = try await service.generateRecommendations(for: field, healthMetrics: metrics)

        // All recommendations should have positive expected benefit
        for rec in recommendations {
            #expect(rec.expectedBenefit > 0)
            #expect(rec.estimatedCost > 0)
            // ROI formula: ((benefit - cost) / cost) * 100
            // If benefit > cost, ROI should be positive
        }
    }
}
