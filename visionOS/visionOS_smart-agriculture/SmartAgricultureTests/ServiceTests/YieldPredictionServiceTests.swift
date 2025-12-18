//
//  YieldPredictionServiceTests.swift
//  SmartAgricultureTests
//
//  Created by Claude Code
//  Copyright © 2025 Smart Agriculture. All rights reserved.
//

import Testing
@testable import SmartAgriculture

@Suite("Yield Prediction Service Tests")
struct YieldPredictionServiceTests {

    @Test("Predict yield returns valid prediction")
    func testPredictYieldReturnsValid() async throws {
        let service = YieldPredictionService()
        let field = Field.mock(cropType: .corn, health: 85.0)
        let metrics = HealthMetrics.mock(healthScore: 85.0)

        let prediction = try await service.predictYield(for: field, healthMetrics: metrics)

        // Verify prediction is valid
        #expect(prediction.estimatedYield > 0)
        #expect(prediction.confidence > 0 && prediction.confidence <= 1.0)
        #expect(prediction.minYield <= prediction.estimatedYield)
        #expect(prediction.maxYield >= prediction.estimatedYield)
    }

    @Test("High health produces higher yield")
    func testHighHealthHigherYield() async throws {
        let service = YieldPredictionService()

        let healthyField = Field.mock(cropType: .corn, health: 95.0)
        let healthyMetrics = HealthMetrics.mock(healthScore: 95.0)
        let healthyPrediction = try await service.predictYield(for: healthyField, healthMetrics: healthyMetrics)

        let poorField = Field.mock(cropType: .corn, health: 40.0)
        let poorMetrics = HealthMetrics.mockPoor()
        let poorPrediction = try await service.predictYield(for: poorField, healthMetrics: poorMetrics)

        // Healthy field should predict higher yield
        #expect(healthyPrediction.estimatedYield > poorPrediction.estimatedYield)
    }

    @Test("Yield prediction range is reasonable")
    func testYieldPredictionRange() async throws {
        let service = YieldPredictionService()
        let field = Field.mock(cropType: .corn)
        let metrics = HealthMetrics.mock()

        let prediction = try await service.predictYield(for: field, healthMetrics: metrics)

        let rangeSize = prediction.uncertaintyRange
        let estimatedYield = prediction.estimatedYield

        // Range should be approximately ±10% of estimated yield
        let expectedRange = estimatedYield * 0.2  // ±10% = 20% total range
        let tolerance = estimatedYield * 0.05  // Allow 5% tolerance

        #expect(abs(rangeSize - expectedRange) < tolerance)
    }

    @Test("Yield factors are generated")
    func testYieldFactorsGenerated() async throws {
        let service = YieldPredictionService()
        let field = Field.mock()
        let metrics = HealthMetrics.mock()

        let prediction = try await service.predictYield(for: field, healthMetrics: metrics)

        // Should have some contributing factors
        #expect(prediction.contributingFactors.count > 0)

        // Factors should have valid impact values
        for factor in prediction.contributingFactors {
            #expect(factor.impact >= -1.0 && factor.impact <= 1.0)
        }
    }
}
