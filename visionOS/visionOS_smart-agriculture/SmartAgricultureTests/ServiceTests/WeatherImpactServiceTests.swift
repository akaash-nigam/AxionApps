//
//  WeatherImpactServiceTests.swift
//  SmartAgricultureTests
//
//  Created by Claude on 11/17/25.
//

import Testing
@testable import SmartAgriculture

@Suite("Weather Impact Service Tests")
struct WeatherImpactServiceTests {

    @Test("Analyze weather impact with ideal conditions")
    func testIdealWeatherConditions() async throws {
        let service = WeatherImpactService()
        let conditions = WeatherConditions.ideal

        let impact = try await service.analyzeWeatherImpact(
            conditions: conditions,
            cropType: .corn,
            growthStage: .vegetative
        )

        #expect(impact.overallImpact == .positive || impact.overallImpact == .veryPositive)
        #expect(impact.yieldImpactPercentage > 0)
        #expect(impact.confidence > 0.5)
    }

    @Test("Analyze weather impact with drought conditions")
    func testDroughtConditions() async throws {
        let service = WeatherImpactService()
        let conditions = WeatherConditions.drought

        let impact = try await service.analyzeWeatherImpact(
            conditions: conditions,
            cropType: .corn,
            growthStage: .reproductive
        )

        #expect(impact.overallImpact == .negative || impact.overallImpact == .veryNegative)
        #expect(impact.yieldImpactPercentage < 0)
        #expect(impact.stressFactors.count > 0)

        // Should have drought stress factor
        let hasDroughtStress = impact.stressFactors.contains { $0.type == .drought }
        #expect(hasDroughtStress)
    }

    @Test("Heat stress detection above optimal temperature")
    func testHeatStress() async throws {
        let service = WeatherImpactService()
        let hotConditions = WeatherConditions(
            temperature: 100,
            precipitation: 0.1,
            humidity: 40,
            windSpeed: 10,
            solarRadiation: 650,
            daysSinceRain: 5,
            growingDegreeDays: 1500
        )

        let impact = try await service.analyzeWeatherImpact(
            conditions: hotConditions,
            cropType: .corn,
            growthStage: .reproductive
        )

        let hasHeatStress = impact.stressFactors.contains { $0.type == .heat }
        #expect(hasHeatStress)

        if let heatStress = impact.stressFactors.first(where: { $0.type == .heat }) {
            #expect(heatStress.severity > 20)
        }
    }

    @Test("Frost conditions detection")
    func testFrostConditions() async throws {
        let service = WeatherImpactService()
        let frostConditions = WeatherConditions(
            temperature: 28,
            precipitation: 0,
            humidity: 80,
            windSpeed: 5,
            solarRadiation: 200,
            daysSinceRain: 2,
            growingDegreeDays: 400
        )

        let impact = try await service.analyzeWeatherImpact(
            conditions: frostConditions,
            cropType: .corn,
            growthStage: .emergence
        )

        let hasFrostStress = impact.stressFactors.contains { $0.type == .frost }
        #expect(hasFrostStress)

        if let frostStress = impact.stressFactors.first(where: { $0.type == .frost }) {
            #expect(frostStress.severity == 100)  // Critical
        }
    }

    @Test("Weather impact recommendations generated")
    func testRecommendationsGenerated() async throws {
        let service = WeatherImpactService()
        let stressfulConditions = WeatherConditions(
            temperature: 95,
            precipitation: 0,
            humidity: 30,
            windSpeed: 20,
            solarRadiation: 700,
            daysSinceRain: 15,
            growingDegreeDays: 1800
        )

        let impact = try await service.analyzeWeatherImpact(
            conditions: stressfulConditions,
            cropType: .corn,
            growthStage: .reproductive
        )

        #expect(impact.recommendations.count > 0)
    }

    @Test("Confidence increases with historical data")
    func testConfidenceWithHistoricalData() async throws {
        let service = WeatherImpactService()
        let conditions = WeatherConditions.mock
        let historical = [WeatherConditions.mock, WeatherConditions.mock]

        let impactWithHistory = try await service.analyzeWeatherImpact(
            conditions: conditions,
            cropType: .corn,
            growthStage: .vegetative,
            historicalConditions: historical
        )

        let impactWithoutHistory = try await service.analyzeWeatherImpact(
            conditions: conditions,
            cropType: .corn,
            growthStage: .vegetative,
            historicalConditions: []
        )

        #expect(impactWithHistory.confidence > impactWithoutHistory.confidence)
    }

    @Test("Wind stress above threshold")
    func testWindStress() async throws {
        let service = WeatherImpactService()
        let windyConditions = WeatherConditions(
            temperature: 75,
            precipitation: 0.2,
            humidity: 50,
            windSpeed: 35,
            solarRadiation: 500,
            daysSinceRain: 3,
            growingDegreeDays: 1200
        )

        let impact = try await service.analyzeWeatherImpact(
            conditions: windyConditions,
            cropType: .corn,
            growthStage: .reproductive
        )

        let hasWindStress = impact.stressFactors.contains { $0.type == .wind }
        #expect(hasWindStress)
    }
}
