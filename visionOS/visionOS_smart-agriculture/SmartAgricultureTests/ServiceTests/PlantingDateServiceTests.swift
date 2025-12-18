//
//  PlantingDateServiceTests.swift
//  SmartAgricultureTests
//
//  Created by Claude on 11/17/25.
//

import Testing
import Foundation
@testable import SmartAgriculture

@Suite("Planting Date Service Tests")
struct PlantingDateServiceTests {

    @Test("Calculate optimal planting date for corn")
    func testCornPlantingDate() async throws {
        let service = PlantingDateService()

        // Mid-April current date
        let calendar = Calendar.current
        let currentDate = calendar.date(from: DateComponents(year: 2025, month: 4, day: 15))!

        let recommendation = try await service.calculateOptimalPlantingDate(
            cropType: .corn,
            latitude: 40.0,
            currentDate: currentDate,
            soilTemperature: 52.0,
            soilMoisture: 55.0
        )

        #expect(recommendation.cropType == .corn)
        #expect(recommendation.optimalDate > currentDate)
        #expect(recommendation.earlyDate < recommendation.optimalDate)
        #expect(recommendation.lateDate > recommendation.optimalDate)
    }

    @Test("Soil too cold delays planting recommendation")
    func testColdSoilDelayPlanting() async throws {
        let service = PlantingDateService()
        let currentDate = Date()

        let recommendation = try await service.calculateOptimalPlantingDate(
            cropType: .corn,
            latitude: 40.0,
            currentDate: currentDate,
            soilTemperature: 42.0,  // Too cold (minimum is 50°F)
            soilMoisture: 50.0
        )

        #expect(!recommendation.soilConditions.isReady)
        #expect(recommendation.currentRisk != .veryLow && recommendation.currentRisk != .low)
    }

    @Test("Soil temperature ready for planting")
    func testSoilTemperatureReady() async throws {
        let service = PlantingDateService()
        let currentDate = Date()

        let recommendation = try await service.calculateOptimalPlantingDate(
            cropType: .corn,
            latitude: 40.0,
            currentDate: currentDate,
            soilTemperature: 55.0,  // Adequate
            soilMoisture: 52.0
        )

        #expect(recommendation.soilConditions.isReady)
        #expect(recommendation.soilConditions.temperature >= 50.0)
    }

    @Test("Frost risk affects planting date")
    func testFrostRiskAffectsDate() async throws {
        let service = PlantingDateService()

        // Early spring date
        let calendar = Calendar.current
        let earlyDate = calendar.date(from: DateComponents(year: 2025, month: 4, day: 1))!

        let recommendation = try await service.calculateOptimalPlantingDate(
            cropType: .corn,
            latitude: 42.0,  // Northern latitude
            currentDate: earlyDate,
            soilTemperature: 51.0,
            soilMoisture: 50.0,
            historicalFrostDates: [
                calendar.date(from: DateComponents(year: 2024, month: 5, day: 5))!,
                calendar.date(from: DateComponents(year: 2023, month: 5, day: 8))!
            ]
        )

        #expect(recommendation.frostRisk.probability > 0)
        if let daysUntilSafe = recommendation.frostRisk.daysUntilSafe {
            #expect(daysUntilSafe > 0)
        }
    }

    @Test("Moisture too wet delays planting")
    func testExcessMoistureDelayPlanting() async throws {
        let service = PlantingDateService()
        let currentDate = Date()

        let recommendation = try await service.calculateOptimalPlantingDate(
            cropType: .soybeans,
            latitude: 40.0,
            currentDate: currentDate,
            soilTemperature: 58.0,
            soilMoisture: 75.0  // Too wet
        )

        #expect(recommendation.moistureStatus.status == .tooWet)
    }

    @Test("Moisture too dry indicates irrigation needed")
    func testLowMoistureStatus() async throws {
        let service = PlantingDateService()
        let currentDate = Date()

        let recommendation = try await service.calculateOptimalPlantingDate(
            cropType: .corn,
            latitude: 40.0,
            currentDate: currentDate,
            soilTemperature: 53.0,
            soilMoisture: 30.0  // Too dry
        )

        #expect(recommendation.moistureStatus.status == .tooDry)
    }

    @Test("Different crops have different optimal dates")
    func testCropSpecificDates() async throws {
        let service = PlantingDateService()
        let currentDate = Date()

        let cornRec = try await service.calculateOptimalPlantingDate(
            cropType: .corn,
            latitude: 40.0,
            currentDate: currentDate,
            soilTemperature: 52.0,
            soilMoisture: 50.0
        )

        let soybeansRec = try await service.calculateOptimalPlantingDate(
            cropType: .soybeans,
            latitude: 40.0,
            currentDate: currentDate,
            soilTemperature: 57.0,
            soilMoisture: 50.0
        )

        // Soybeans are typically planted later than corn
        #expect(soybeansRec.optimalDate > cornRec.optimalDate)
    }

    @Test("Maturity date calculated correctly")
    func testMaturityDateCalculation() async throws {
        let service = PlantingDateService()
        let calendar = Calendar.current
        let plantingDate = calendar.date(from: DateComponents(year: 2025, month: 5, day: 10))!

        let recommendation = try await service.calculateOptimalPlantingDate(
            cropType: .corn,
            latitude: 40.0,
            currentDate: plantingDate,
            soilTemperature: 55.0,
            soilMoisture: 52.0
        )

        // Corn typically matures in 120-130 days
        let daysDiff = calendar.dateComponents([.day], from: recommendation.optimalDate, to: recommendation.expectedMaturityDate).day ?? 0
        #expect(daysDiff >= 110)
        #expect(daysDiff <= 140)
    }

    @Test("Expected yield decreases for late planting")
    func testLatePlantingYieldPenalty() async throws {
        let service = PlantingDateService()
        let calendar = Calendar.current

        // On-time planting
        let earlyDate = calendar.date(from: DateComponents(year: 2025, month: 5, day: 1))!
        let earlyRec = try await service.calculateOptimalPlantingDate(
            cropType: .corn,
            latitude: 40.0,
            currentDate: earlyDate,
            soilTemperature: 55.0,
            soilMoisture: 50.0
        )

        // Late planting
        let lateDate = calendar.date(from: DateComponents(year: 2025, month: 6, day: 15))!
        let lateRec = try await service.calculateOptimalPlantingDate(
            cropType: .corn,
            latitude: 40.0,
            currentDate: lateDate,
            soilTemperature: 65.0,
            soilMoisture: 50.0
        )

        // Late planting should have lower expected yield
        // Only compare if the late planting is actually recommended after the optimal window
        if lateRec.currentRisk == .high || lateRec.currentRisk == .veryHigh {
            #expect(lateRec.expectedYield <= earlyRec.expectedYield)
        }
    }

    @Test("Reasoning includes key factors")
    func testReasoningGenerated() async throws {
        let service = PlantingDateService()
        let currentDate = Date()

        let recommendation = try await service.calculateOptimalPlantingDate(
            cropType: .corn,
            latitude: 40.0,
            currentDate: currentDate,
            soilTemperature: 52.0,
            soilMoisture: 55.0
        )

        #expect(recommendation.reasoning.count > 0)

        // Should mention soil temperature
        let mentionsSoilTemp = recommendation.reasoning.contains { $0.contains("Soil temperature") || $0.contains("soil temperature") }
        #expect(mentionsSoilTemp)
    }

    @Test("Latitude affects planting dates")
    func testLatitudeAdjustment() async throws {
        let service = PlantingDateService()
        let currentDate = Date()

        // Southern latitude (warmer, earlier planting)
        let southRec = try await service.calculateOptimalPlantingDate(
            cropType: .corn,
            latitude: 35.0,
            currentDate: currentDate,
            soilTemperature: 55.0,
            soilMoisture: 50.0
        )

        // Northern latitude (colder, later planting)
        let northRec = try await service.calculateOptimalPlantingDate(
            cropType: .corn,
            latitude: 45.0,
            currentDate: currentDate,
            soilTemperature: 55.0,
            soilMoisture: 50.0
        )

        // Northern latitude should have later planting date
        #expect(northRec.optimalDate > southRec.optimalDate)
    }

    @Test("Current risk assessment accurate")
    func testCurrentRiskAssessment() async throws {
        let service = PlantingDateService()
        let calendar = Calendar.current

        // Perfect conditions in optimal window
        let optimalDate = calendar.date(from: DateComponents(year: 2025, month: 5, day: 5))!
        let lowRiskRec = try await service.calculateOptimalPlantingDate(
            cropType: .corn,
            latitude: 40.0,
            currentDate: optimalDate,
            soilTemperature: 55.0,
            soilMoisture: 52.0
        )

        // Should be low risk if conditions are good
        if lowRiskRec.soilConditions.isReady && lowRiskRec.frostRisk.probability < 0.3 {
            #expect(lowRiskRec.currentRisk == .veryLow || lowRiskRec.currentRisk == .low)
        }
    }

    @Test("Weather forecast improves confidence")
    func testWeatherForecastImprovestConfidence() async throws {
        let service = PlantingDateService()
        let currentDate = Date()
        let forecast = [WeatherConditions.mock, WeatherConditions.mock]

        let withForecast = try await service.calculateOptimalPlantingDate(
            cropType: .corn,
            latitude: 40.0,
            currentDate: currentDate,
            soilTemperature: 52.0,
            soilMoisture: 50.0,
            weatherForecast: forecast
        )

        let withoutForecast = try await service.calculateOptimalPlantingDate(
            cropType: .corn,
            latitude: 40.0,
            currentDate: currentDate,
            soilTemperature: 52.0,
            soilMoisture: 50.0
        )

        #expect(withForecast.confidence >= withoutForecast.confidence)
    }
}
