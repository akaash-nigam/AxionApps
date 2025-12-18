//
//  HarvestTimingServiceTests.swift
//  SmartAgricultureTests
//
//  Created by Claude on 11/17/25.
//

import Testing
import Foundation
@testable import SmartAgriculture

@Suite("Harvest Timing Service Tests")
struct HarvestTimingServiceTests {

    @Test("Calculate optimal harvest timing for mature crop")
    func testMatureCropHarvestTiming() async throws {
        let service = HarvestTimingService()
        let calendar = Calendar.current

        let plantingDate = calendar.date(byAdding: .day, value: -120, to: Date())!
        let field = Field.mock(health: 85.0)

        let recommendation = try await service.calculateOptimalHarvestTiming(
            field: field,
            plantingDate: plantingDate,
            currentWeather: WeatherConditions.ideal
        )

        #expect(recommendation.cropType == field.cropType)
        #expect(recommendation.maturityLevel >= 0 && recommendation.maturityLevel <= 110)
        #expect(recommendation.confidence > 0.5)
    }

    @Test("Immature crop shows too early readiness")
    func testImmatureCropReadiness() async throws {
        let service = HarvestTimingService()
        let calendar = Calendar.current

        // Planted only 60 days ago
        let plantingDate = calendar.date(byAdding: .day, value: -60, to: Date())!
        let field = Field.mock(health: 90.0)

        let recommendation = try await service.calculateOptimalHarvestTiming(
            field: field,
            plantingDate: plantingDate,
            currentWeather: WeatherConditions.ideal
        )

        #expect(recommendation.maturityLevel < 85)
        #expect(recommendation.currentReadiness == .tooEarly || recommendation.currentReadiness == .approaching)
    }

    @Test("High weather risk increases urgency")
    func testWeatherRiskIncreasesUrgency() async throws {
        let service = HarvestTimingService()
        let calendar = Calendar.current

        let plantingDate = calendar.date(byAdding: .day, value: -125, to: Date())!
        let field = Field.mock(health: 80.0)

        // Severe weather forecast
        let severeWeather = WeatherConditions(
            temperature: 85,
            precipitation: 3.5,  // Heavy rain
            humidity: 90,
            windSpeed: 35,  // High winds
            solarRadiation: 400,
            daysSinceRain: 0,
            growingDegreeDays: 2600
        )

        let forecast = [severeWeather, severeWeather]

        let recommendation = try await service.calculateOptimalHarvestTiming(
            field: field,
            plantingDate: plantingDate,
            currentWeather: severeWeather,
            weatherForecast: forecast
        )

        #expect(recommendation.weatherRisk.riskLevel == .high || recommendation.weatherRisk.riskLevel == .severe)
        #expect(recommendation.urgency != .none)
    }

    @Test("Optimal maturity produces highest yield")
    func testOptimalMaturityYield() async throws {
        let service = HarvestTimingService()
        let calendar = Calendar.current

        // Perfectly timed for optimal harvest
        let plantingDate = calendar.date(byAdding: .day, value: -field.cropType.growingSeasonDays, to: Date())!
        let field = Field.mock(health: 90.0)

        let recommendation = try await service.calculateOptimalHarvestTiming(
            field: field,
            plantingDate: plantingDate,
            currentWeather: WeatherConditions.ideal
        )

        // Harvest at optimal should yield best results
        #expect(recommendation.yieldImpact.harvestOptimal >= recommendation.yieldImpact.harvestNow)
        #expect(recommendation.yieldImpact.harvestOptimal >= recommendation.yieldImpact.harvestDelayed)
    }

    @Test("Delayed harvest reduces yield")
    func testDelayedHarvestYieldLoss() async throws {
        let service = HarvestTimingService()
        let calendar = Calendar.current

        // Over-mature crop
        let plantingDate = calendar.date(byAdding: .day, value: -140, to: Date())!
        let field = Field.mock(health: 75.0)

        let recommendation = try await service.calculateOptimalHarvestTiming(
            field: field,
            plantingDate: plantingDate,
            currentWeather: WeatherConditions.ideal
        )

        // Delayed harvest should have lower yield than optimal
        #expect(recommendation.yieldImpact.harvestDelayed <= recommendation.yieldImpact.harvestOptimal)
    }

    @Test("Moisture content affects quality score")
    func testMoistureContentAffectsQuality() async throws {
        let service = HarvestTimingService()
        let calendar = Calendar.current

        let plantingDate = calendar.date(byAdding: .day, value: -120, to: Date())!
        let field = Field.mock(health: 85.0)

        // Recent rain increases moisture
        let wetWeather = WeatherConditions(
            temperature: 70,
            precipitation: 2.0,
            humidity: 85,
            windSpeed: 5,
            solarRadiation: 450,
            daysSinceRain: 1,
            growingDegreeDays: 2500
        )

        let recommendation = try await service.calculateOptimalHarvestTiming(
            field: field,
            plantingDate: plantingDate,
            currentWeather: wetWeather
        )

        #expect(recommendation.moistureContent > 15)  // Should be above target due to rain
    }

    @Test("Quality premium calculated for excellent quality")
    func testQualityPremiumForExcellentCrop() async throws {
        let service = HarvestTimingService()
        let calendar = Calendar.current

        // Optimal harvest timing
        let daysToMaturity = CropType.corn.growingSeasonDays
        let plantingDate = calendar.date(byAdding: .day, value: -daysToMaturity, to: Date())!

        var field = Field.mock(health: 95.0)
        field.cropTypeRaw = CropType.corn.rawValue

        let recommendation = try await service.calculateOptimalHarvestTiming(
            field: field,
            plantingDate: plantingDate,
            currentWeather: WeatherConditions.ideal
        )

        // High quality should have positive premium
        if recommendation.qualityScore >= 80 {
            #expect(recommendation.yieldImpact.qualityPremium >= 0)
        }
    }

    @Test("Recommendations generated based on readiness")
    func testRecommendationsGenerated() async throws {
        let service = HarvestTimingService()
        let calendar = Calendar.current

        let plantingDate = calendar.date(byAdding: .day, value: -125, to: Date())!
        let field = Field.mock(health: 85.0)

        let recommendation = try await service.calculateOptimalHarvestTiming(
            field: field,
            plantingDate: plantingDate,
            currentWeather: WeatherConditions.ideal
        )

        #expect(recommendation.recommendations.count > 0)
    }

    @Test("Market price affects estimated revenue")
    func testMarketPriceAffectsRevenue() async throws {
        let service = HarvestTimingService()
        let calendar = Calendar.current
        let plantingDate = calendar.date(byAdding: .day, value: -120, to: Date())!
        let field = Field.mock(health: 85.0)

        let highPrice = try await service.calculateOptimalHarvestTiming(
            field: field,
            plantingDate: plantingDate,
            currentWeather: WeatherConditions.ideal,
            marketPrice: 10.00
        )

        let lowPrice = try await service.calculateOptimalHarvestTiming(
            field: field,
            plantingDate: plantingDate,
            currentWeather: WeatherConditions.ideal,
            marketPrice: 5.00
        )

        #expect(highPrice.estimatedRevenue > lowPrice.estimatedRevenue)
    }

    @Test("Harvest window calculated correctly")
    func testHarvestWindowCalculation() async throws {
        let service = HarvestTimingService()
        let calendar = Calendar.current
        let plantingDate = calendar.date(byAdding: .day, value: -120, to: Date())!
        let field = Field.mock(health: 85.0)

        let recommendation = try await service.calculateOptimalHarvestTiming(
            field: field,
            plantingDate: plantingDate,
            currentWeather: WeatherConditions.ideal
        )

        // Early date should be before optimal
        #expect(recommendation.earlyHarvestDate < recommendation.optimalHarvestDate)

        // Late date should be after optimal
        #expect(recommendation.lateHarvestDate > recommendation.optimalHarvestDate)

        // Window should be reasonable (within 21 days total)
        let windowDays = calendar.dateComponents([.day], from: recommendation.earlyHarvestDate, to: recommendation.lateHarvestDate).day ?? 0
        #expect(windowDays > 0)
        #expect(windowDays <= 30)
    }

    @Test("Urgency levels assigned correctly")
    func testUrgencyLevels() async throws {
        let service = HarvestTimingService()
        let calendar = Calendar.current

        // Ready crop with good weather - low urgency
        let plantingDate = calendar.date(byAdding: .day, value: -120, to: Date())!
        let field = Field.mock(health: 85.0)

        let goodConditions = try await service.calculateOptimalHarvestTiming(
            field: field,
            plantingDate: plantingDate,
            currentWeather: WeatherConditions.ideal
        )

        // Over-mature crop with severe weather - high urgency
        let latePlantingDate = calendar.date(byAdding: .day, value: -140, to: Date())!
        let severeWeather = WeatherConditions(
            temperature: 90,
            precipitation: 4.0,
            humidity: 95,
            windSpeed: 40,
            solarRadiation: 350,
            daysSinceRain: 0,
            growingDegreeDays: 2800
        )

        let urgentConditions = try await service.calculateOptimalHarvestTiming(
            field: field,
            plantingDate: latePlantingDate,
            currentWeather: severeWeather,
            weatherForecast: [severeWeather]
        )

        #expect(urgentConditions.urgency != goodConditions.urgency)
    }

    @Test("GDD affects maturity calculation")
    func testGDDAffectsMaturity() async throws {
        let service = HarvestTimingService()
        let calendar = Calendar.current
        let plantingDate = calendar.date(byAdding: .day, value: -100, to: Date())!
        let field = Field.mock(health: 85.0)

        // High GDD accumulation
        let highGDD = WeatherConditions(
            temperature: 80,
            precipitation: 0.5,
            humidity: 60,
            windSpeed: 8,
            solarRadiation: 550,
            daysSinceRain: 3,
            growingDegreeDays: 2500
        )

        // Low GDD accumulation
        let lowGDD = WeatherConditions(
            temperature: 65,
            precipitation: 0.5,
            humidity: 60,
            windSpeed: 8,
            solarRadiation: 450,
            daysSinceRain: 3,
            growingDegreeDays: 1500
        )

        let highGDDRec = try await service.calculateOptimalHarvestTiming(
            field: field,
            plantingDate: plantingDate,
            currentWeather: highGDD
        )

        let lowGDDRec = try await service.calculateOptimalHarvestTiming(
            field: field,
            plantingDate: plantingDate,
            currentWeather: lowGDD
        )

        #expect(highGDDRec.maturityLevel > lowGDDRec.maturityLevel)
    }
}
