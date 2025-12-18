//
//  DroughtRiskServiceTests.swift
//  SmartAgricultureTests
//
//  Created by Claude on 11/17/25.
//

import Testing
@testable import SmartAgriculture

@Suite("Drought Risk Service Tests")
struct DroughtRiskServiceTests {

    @Test("Assess drought risk with low soil moisture")
    func testLowSoilMoistureDroughtRisk() async throws {
        let service = DroughtRiskService()
        let field = Field.mock(health: 85.0)
        let weather = WeatherConditions.drought
        let historical = PrecipitationRecord.mockHistorical

        let assessment = try await service.assessDroughtRisk(
            field: field,
            currentWeather: weather,
            soilMoisture: 20.0,  // Very low
            historicalPrecipitation: historical
        )

        #expect(assessment.riskLevel == .severe || assessment.riskLevel == .extreme)
        #expect(assessment.riskScore > 60)
        #expect(assessment.soilMoistureDeficit > 0)
    }

    @Test("Assess drought risk with adequate moisture")
    func testAdequateMoistureNoRisk() async throws {
        let service = DroughtRiskService()
        let field = Field.mock(health: 85.0)
        let weather = WeatherConditions.ideal
        let historical = PrecipitationRecord.mockHistorical

        let assessment = try await service.assessDroughtRisk(
            field: field,
            currentWeather: weather,
            soilMoisture: 55.0,  // Adequate
            historicalPrecipitation: historical
        )

        #expect(assessment.riskLevel == .none || assessment.riskLevel == .minimal)
        #expect(assessment.riskScore < 30)
    }

    @Test("Mitigation actions generated for high risk")
    func testMitigationActionsForHighRisk() async throws {
        let service = DroughtRiskService()
        let field = Field.mock(health: 50.0)
        let weather = WeatherConditions.drought
        let historical = PrecipitationRecord.mockHistorical

        let assessment = try await service.assessDroughtRisk(
            field: field,
            currentWeather: weather,
            soilMoisture: 25.0,
            historicalPrecipitation: historical
        )

        #expect(assessment.mitigationActions.count > 0)

        // Should have immediate priority actions
        let hasImmediateAction = assessment.mitigationActions.contains { $0.priority == .immediate }
        #expect(hasImmediateAction)
    }

    @Test("Days until critical calculated correctly")
    func testDaysUntilCriticalCalculation() async throws {
        let service = DroughtRiskService()
        let field = Field.mock(health: 70.0)
        let weather = WeatherConditions.drought
        let historical = PrecipitationRecord.mockHistorical
        let forecast = PrecipitationRecord.mockForecast

        let assessment = try await service.assessDroughtRisk(
            field: field,
            currentWeather: weather,
            soilMoisture: 35.0,  // Above critical but declining
            historicalPrecipitation: historical,
            forecastedPrecipitation: forecast
        )

        #expect(assessment.daysUntilCritical != nil)
        if let days = assessment.daysUntilCritical {
            #expect(days > 0)
            #expect(days < 60)
        }
    }

    @Test("Yield loss projection increases with risk")
    func testYieldLossProjection() async throws {
        let service = DroughtRiskService()
        let field = Field.mock(health: 60.0)
        let weather = WeatherConditions.drought
        let historical = PrecipitationRecord.mockHistorical

        let assessment = try await service.assessDroughtRisk(
            field: field,
            currentWeather: weather,
            soilMoisture: 20.0,
            historicalPrecipitation: historical
        )

        #expect(assessment.projectedYieldLoss > 0)

        // High risk should have significant yield loss
        if assessment.riskLevel == .extreme || assessment.riskLevel == .severe {
            #expect(assessment.projectedYieldLoss > 20)
        }
    }

    @Test("Evapotranspiration rate calculated")
    func testEvapotranspirationRate() async throws {
        let service = DroughtRiskService()
        let field = Field.mock(health: 75.0)
        let weather = WeatherConditions.drought  // Hot and dry
        let historical = PrecipitationRecord.mockHistorical

        let assessment = try await service.assessDroughtRisk(
            field: field,
            currentWeather: weather,
            soilMoisture: 35.0,
            historicalPrecipitation: historical
        )

        #expect(assessment.evapotranspirationRate > 0)
        #expect(assessment.evapotranspirationRate <= 0.5)  // Capped at 0.5 inches/day
    }

    @Test("Precipitation deficit calculated from historical data")
    func testPrecipitationDeficit() async throws {
        let service = DroughtRiskService()
        let field = Field.mock(health: 70.0)

        // Drought conditions with long dry period
        let weather = WeatherConditions(
            temperature: 90,
            precipitation: 0.05,
            humidity: 35,
            windSpeed: 12,
            solarRadiation: 600,
            daysSinceRain: 21,
            growingDegreeDays: 1600
        )

        let historical = PrecipitationRecord.mockHistorical

        let assessment = try await service.assessDroughtRisk(
            field: field,
            currentWeather: weather,
            soilMoisture: 30.0,
            historicalPrecipitation: historical
        )

        #expect(assessment.precipitationDeficit >= 0)
    }

    @Test("Confidence improves with complete data")
    func testConfidenceWithCompleteData() async throws {
        let service = DroughtRiskService()
        let field = Field.mock(health: 80.0)
        let weather = WeatherConditions.mock
        let historical = PrecipitationRecord.mockHistorical
        let forecast = PrecipitationRecord.mockForecast

        let completeData = try await service.assessDroughtRisk(
            field: field,
            currentWeather: weather,
            soilMoisture: 45.0,
            historicalPrecipitation: historical,
            forecastedPrecipitation: forecast
        )

        let limitedData = try await service.assessDroughtRisk(
            field: field,
            currentWeather: weather,
            soilMoisture: 45.0,
            historicalPrecipitation: [],
            forecastedPrecipitation: []
        )

        #expect(completeData.confidence > limitedData.confidence)
    }

    @Test("Risk level categories assigned correctly")
    func testRiskLevelCategories() async throws {
        let service = DroughtRiskService()
        let field = Field.mock(health: 75.0)
        let historical = PrecipitationRecord.mockHistorical

        // Test extreme risk
        let extremeWeather = WeatherConditions.drought
        let extremeRisk = try await service.assessDroughtRisk(
            field: field,
            currentWeather: extremeWeather,
            soilMoisture: 15.0,
            historicalPrecipitation: historical
        )
        #expect(extremeRisk.riskLevel == .severe || extremeRisk.riskLevel == .extreme)

        // Test low risk
        let idealWeather = WeatherConditions.ideal
        let lowRisk = try await service.assessDroughtRisk(
            field: field,
            currentWeather: idealWeather,
            soilMoisture: 60.0,
            historicalPrecipitation: historical
        )
        #expect(lowRisk.riskLevel == .none || lowRisk.riskLevel == .minimal || lowRisk.riskLevel == .moderate)
    }
}
