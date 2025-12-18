//
//  PlantingDateService.swift
//  SmartAgriculture
//
//  Created by Claude on 11/17/25.
//

import Foundation

/// Optimal planting date recommendation
struct PlantingDateRecommendation: Codable, Hashable, Identifiable {
    let id: UUID
    var cropType: CropType
    var optimalDate: Date
    var earlyDate: Date              // Earliest safe planting
    var lateDate: Date               // Latest recommended planting
    var currentRisk: PlantingRisk    // Risk if planting today
    var soilConditions: SoilReadiness
    var frostRisk: FrostRisk
    var moistureStatus: MoistureStatus
    var reasoning: [String]
    var expectedMaturityDate: Date
    var expectedYield: Double        // Bushels per acre
    var confidence: Double           // 0-1

    enum PlantingRisk: String, Codable {
        case veryLow = "Very Low"
        case low = "Low"
        case moderate = "Moderate"
        case high = "High"
        case veryHigh = "Very High"

        var color: String {
            switch self {
            case .veryLow, .low: return "green"
            case .moderate: return "yellow"
            case .high: return "orange"
            case .veryHigh: return "red"
            }
        }
    }

    struct SoilReadiness: Codable, Hashable {
        var temperature: Double      // °F at planting depth
        var moisture: Double        // Percentage
        var isReady: Bool
        var daysUntilReady: Int?
    }

    struct FrostRisk: Codable, Hashable {
        var lastFrostDate: Date?
        var daysUntilSafe: Int?
        var probability: Double     // 0-1
    }

    struct MoistureStatus: Codable, Hashable {
        var current: Double
        var optimal: ClosedRange<Double>
        var status: Status

        enum Status: String, Codable {
            case tooWet = "Too Wet"
            case optimal = "Optimal"
            case tooDry = "Too Dry"
        }
    }

    init(
        cropType: CropType,
        optimalDate: Date,
        earlyDate: Date,
        lateDate: Date,
        currentRisk: PlantingRisk,
        soilConditions: SoilReadiness,
        frostRisk: FrostRisk,
        moistureStatus: MoistureStatus,
        reasoning: [String],
        expectedMaturityDate: Date,
        expectedYield: Double,
        confidence: Double
    ) {
        self.id = UUID()
        self.cropType = cropType
        self.optimalDate = optimalDate
        self.earlyDate = earlyDate
        self.lateDate = lateDate
        self.currentRisk = currentRisk
        self.soilConditions = soilConditions
        self.frostRisk = frostRisk
        self.moistureStatus = moistureStatus
        self.reasoning = reasoning
        self.expectedMaturityDate = expectedMaturityDate
        self.expectedYield = expectedYield
        self.confidence = confidence
    }
}

/// Service for calculating optimal planting dates
actor PlantingDateService {

    // MARK: - Planting Date Calculation

    /// Calculates optimal planting date for a crop based on multiple factors
    func calculateOptimalPlantingDate(
        cropType: CropType,
        latitude: Double,
        currentDate: Date = Date(),
        soilTemperature: Double,
        soilMoisture: Double,
        weatherForecast: [WeatherConditions] = [],
        historicalFrostDates: [Date] = []
    ) async throws -> PlantingDateRecommendation {

        // Get planting window for this crop and location
        let plantingWindow = getPlantingWindow(
            cropType: cropType,
            latitude: latitude,
            currentDate: currentDate
        )

        // Assess frost risk
        let frostRisk = assessFrostRisk(
            latitude: latitude,
            currentDate: currentDate,
            historicalDates: historicalFrostDates,
            forecast: weatherForecast
        )

        // Check soil readiness
        let soilReadiness = assessSoilReadiness(
            temperature: soilTemperature,
            moisture: soilMoisture,
            cropType: cropType,
            forecast: weatherForecast
        )

        // Assess soil moisture status
        let optimalMoisture = getOptimalPlantingMoisture(cropType: cropType)
        let moistureStatus = PlantingDateRecommendation.MoistureStatus(
            current: soilMoisture,
            optimal: optimalMoisture,
            status: getMoistureStatus(soilMoisture, optimal: optimalMoisture)
        )

        // Calculate optimal date within window
        let optimalDate = calculateOptimalDate(
            window: plantingWindow,
            soilReadiness: soilReadiness,
            frostRisk: frostRisk,
            moistureStatus: moistureStatus,
            currentDate: currentDate
        )

        // Calculate current planting risk
        let currentRisk = assessCurrentPlantingRisk(
            currentDate: currentDate,
            optimalDate: optimalDate,
            window: plantingWindow,
            soilReadiness: soilReadiness,
            frostRisk: frostRisk,
            moistureStatus: moistureStatus
        )

        // Generate reasoning
        let reasoning = generateReasoning(
            cropType: cropType,
            optimalDate: optimalDate,
            currentDate: currentDate,
            soilReadiness: soilReadiness,
            frostRisk: frostRisk,
            moistureStatus: moistureStatus,
            currentRisk: currentRisk
        )

        // Calculate expected maturity date
        let maturityDate = calculateMaturityDate(
            plantingDate: optimalDate,
            cropType: cropType,
            latitude: latitude
        )

        // Estimate yield based on planting date
        let expectedYield = estimateYieldByPlantingDate(
            plantingDate: optimalDate,
            optimalDate: optimalDate,
            cropType: cropType
        )

        // Calculate confidence
        let confidence = calculateConfidence(
            hasWeatherForecast: !weatherForecast.isEmpty,
            hasHistoricalData: !historicalFrostDates.isEmpty,
            soilDataQuality: soilTemperature > 0 ? 1.0 : 0.5
        )

        return PlantingDateRecommendation(
            cropType: cropType,
            optimalDate: optimalDate,
            earlyDate: plantingWindow.early,
            lateDate: plantingWindow.late,
            currentRisk: currentRisk,
            soilConditions: soilReadiness,
            frostRisk: frostRisk,
            moistureStatus: moistureStatus,
            reasoning: reasoning,
            expectedMaturityDate: maturityDate,
            expectedYield: expectedYield,
            confidence: confidence
        )
    }

    // MARK: - Planting Window

    private struct PlantingWindow {
        var early: Date
        var optimal: Date
        var late: Date
    }

    private func getPlantingWindow(
        cropType: CropType,
        latitude: Double,
        currentDate: Date
    ) -> PlantingWindow {

        let calendar = Calendar.current
        let year = calendar.component(.year, from: currentDate)

        // Adjust base dates by latitude (later planting in northern regions)
        let latitudeAdjustment = Int((latitude - 40) * -2)  // 2 days per degree

        // Base planting windows (for 40°N latitude)
        let (earlyDay, optimalDay, lateDay): (Int, Int, Int)

        switch cropType {
        case .corn:
            earlyDay = 105 + latitudeAdjustment  // Mid-April
            optimalDay = 120 + latitudeAdjustment  // Early May
            lateDay = 150 + latitudeAdjustment  // Late May

        case .soybeans:
            earlyDay = 120 + latitudeAdjustment  // Early May
            optimalDay = 135 + latitudeAdjustment  // Mid-May
            lateDay = 165 + latitudeAdjustment  // Mid-June

        case .wheat:
            // Winter wheat planted in fall
            earlyDay = 260 + latitudeAdjustment  // Mid-September
            optimalDay = 280 + latitudeAdjustment  // Early October
            lateDay = 305 + latitudeAdjustment  // Early November

        case .cotton:
            earlyDay = 110 + latitudeAdjustment  // Late April
            optimalDay = 125 + latitudeAdjustment  // Early May
            lateDay = 145 + latitudeAdjustment  // Late May

        default:
            earlyDay = 110 + latitudeAdjustment
            optimalDay = 125 + latitudeAdjustment
            lateDay = 150 + latitudeAdjustment
        }

        let earlyDate = calendar.date(from: DateComponents(year: year, day: earlyDay))!
        let optimalDate = calendar.date(from: DateComponents(year: year, day: optimalDay))!
        let lateDate = calendar.date(from: DateComponents(year: year, day: lateDay))!

        return PlantingWindow(early: earlyDate, optimal: optimalDate, late: lateDate)
    }

    // MARK: - Frost Risk

    private func assessFrostRisk(
        latitude: Double,
        currentDate: Date,
        historicalDates: [Date],
        forecast: [WeatherConditions]
    ) -> PlantingDateRecommendation.FrostRisk {

        // Calculate average last frost date from historical data
        let lastFrostDate: Date?
        if !historicalDates.isEmpty {
            let calendar = Calendar.current
            let averageDay = historicalDates.reduce(0) { sum, date in
                sum + calendar.ordinality(of: .day, in: .year, for: date)!
            } / historicalDates.count

            let year = calendar.component(.year, from: currentDate)
            lastFrostDate = calendar.date(from: DateComponents(year: year, day: averageDay))
        } else {
            // Estimate based on latitude
            let baseDay = 120 - Int((latitude - 40) * 3)  // Roughly early May at 40°N
            let year = Calendar.current.component(.year, from: currentDate)
            lastFrostDate = Calendar.current.date(from: DateComponents(year: year, day: baseDay))
        }

        // Calculate days until safe
        let daysUntilSafe: Int?
        if let frostDate = lastFrostDate {
            let days = Calendar.current.dateComponents([.day], from: currentDate, to: frostDate).day
            daysUntilSafe = days ?? 0
        } else {
            daysUntilSafe = nil
        }

        // Check forecast for frost
        let hasFrostInForecast = forecast.contains { $0.temperature < 32 }

        // Calculate probability (decreases as we move past average last frost)
        var probability: Double = 0.5
        if let days = daysUntilSafe {
            if days > 7 {
                probability = 0.8
            } else if days > 0 {
                probability = 0.5
            } else if days > -7 {
                probability = 0.2
            } else {
                probability = 0.05
            }
        }

        if hasFrostInForecast {
            probability = max(probability, 0.9)
        }

        return PlantingDateRecommendation.FrostRisk(
            lastFrostDate: lastFrostDate,
            daysUntilSafe: daysUntilSafe,
            probability: probability
        )
    }

    // MARK: - Soil Readiness

    private func assessSoilReadiness(
        temperature: Double,
        moisture: Double,
        cropType: CropType,
        forecast: [WeatherConditions]
    ) -> PlantingDateRecommendation.SoilReadiness {

        let minTemp = getMinimumSoilTemperature(cropType: cropType)
        let optimalTemp = minTemp + 10

        let tempReady = temperature >= minTemp
        let moistureRange = getOptimalPlantingMoisture(cropType: cropType)
        let moistureReady = moistureRange.contains(moisture)

        let isReady = tempReady && moistureReady

        // Estimate days until ready if not ready now
        var daysUntilReady: Int? = nil
        if !isReady && !forecast.isEmpty {
            var projectedTemp = temperature
            var projectedMoisture = moisture

            for (index, day) in forecast.enumerated() {
                // Temperature warms gradually
                if projectedTemp < minTemp {
                    projectedTemp += (day.temperature - projectedTemp) * 0.3
                }

                // Moisture changes with precipitation
                if day.precipitation > 0.1 {
                    projectedMoisture = min(100, projectedMoisture + day.precipitation * 8)
                } else {
                    projectedMoisture = max(0, projectedMoisture - 2)
                }

                let tempOk = projectedTemp >= minTemp
                let moistureOk = moistureRange.contains(projectedMoisture)

                if tempOk && moistureOk {
                    daysUntilReady = index + 1
                    break
                }
            }

            if daysUntilReady == nil && !tempReady {
                // Estimate based on temperature alone
                let tempDeficit = minTemp - temperature
                daysUntilReady = Int(tempDeficit * 3)  // Rough estimate
            }
        }

        return PlantingDateRecommendation.SoilReadiness(
            temperature: temperature,
            moisture: moisture,
            isReady: isReady,
            daysUntilReady: isReady ? nil : daysUntilReady
        )
    }

    private func getMinimumSoilTemperature(cropType: CropType) -> Double {
        switch cropType {
        case .corn: return 50.0
        case .soybeans: return 55.0
        case .wheat: return 40.0
        case .cotton: return 60.0
        default: return 50.0
        }
    }

    private func getOptimalPlantingMoisture(cropType: CropType) -> ClosedRange<Double> {
        // Soil should be moist but not saturated
        return 40.0...65.0
    }

    private func getMoistureStatus(
        _ moisture: Double,
        optimal: ClosedRange<Double>
    ) -> PlantingDateRecommendation.MoistureStatus.Status {
        if moisture < optimal.lowerBound {
            return .tooDry
        } else if moisture > optimal.upperBound {
            return .tooWet
        } else {
            return .optimal
        }
    }

    // MARK: - Optimal Date Calculation

    private func calculateOptimalDate(
        window: PlantingWindow,
        soilReadiness: PlantingDateRecommendation.SoilReadiness,
        frostRisk: PlantingDateRecommendation.FrostRisk,
        moistureStatus: PlantingDateRecommendation.MoistureStatus,
        currentDate: Date
    ) -> Date {

        var targetDate = window.optimal

        // Delay if frost risk is high
        if frostRisk.probability > 0.3, let lastFrost = frostRisk.lastFrostDate {
            let safeDate = Calendar.current.date(byAdding: .day, value: 3, to: lastFrost)!
            if safeDate > targetDate {
                targetDate = min(safeDate, window.late)
            }
        }

        // Delay if soil not ready
        if !soilReadiness.isReady, let daysUntilReady = soilReadiness.daysUntilReady {
            let readyDate = Calendar.current.date(byAdding: .day, value: daysUntilReady, to: currentDate)!
            if readyDate > targetDate && readyDate <= window.late {
                targetDate = readyDate
            }
        }

        // Ensure within planting window
        if targetDate < window.early {
            targetDate = window.early
        } else if targetDate > window.late {
            targetDate = window.late
        }

        return targetDate
    }

    // MARK: - Risk Assessment

    private func assessCurrentPlantingRisk(
        currentDate: Date,
        optimalDate: Date,
        window: PlantingWindow,
        soilReadiness: PlantingDateRecommendation.SoilReadiness,
        frostRisk: PlantingDateRecommendation.FrostRisk,
        moistureStatus: PlantingDateRecommendation.MoistureStatus
    ) -> PlantingDateRecommendation.PlantingRisk {

        var riskScore: Double = 0

        // Days from optimal
        let daysFromOptimal = Calendar.current.dateComponents([.day], from: optimalDate, to: currentDate).day ?? 0

        if abs(daysFromOptimal) > 20 {
            riskScore += 40
        } else if abs(daysFromOptimal) > 10 {
            riskScore += 20
        }

        // Frost risk
        if frostRisk.probability > 0.5 {
            riskScore += 30
        } else if frostRisk.probability > 0.3 {
            riskScore += 15
        }

        // Soil readiness
        if !soilReadiness.isReady {
            riskScore += 25
        }

        // Moisture status
        if moistureStatus.status != .optimal {
            riskScore += 15
        }

        // Convert to risk level
        switch riskScore {
        case 0..<10:
            return .veryLow
        case 10..<30:
            return .low
        case 30..<50:
            return .moderate
        case 50..<70:
            return .high
        default:
            return .veryHigh
        }
    }

    // MARK: - Reasoning

    private func generateReasoning(
        cropType: CropType,
        optimalDate: Date,
        currentDate: Date,
        soilReadiness: PlantingDateRecommendation.SoilReadiness,
        frostRisk: PlantingDateRecommendation.FrostRisk,
        moistureStatus: PlantingDateRecommendation.MoistureStatus,
        currentRisk: PlantingDateRecommendation.PlantingRisk
    ) -> [String] {

        var reasons: [String] = []

        let formatter = DateFormatter()
        formatter.dateStyle = .medium

        // Optimal date reasoning
        reasons.append("Optimal planting date for \(cropType.displayName): \(formatter.string(from: optimalDate))")

        // Soil temperature
        if soilReadiness.isReady {
            reasons.append("Soil temperature (\(Int(soilReadiness.temperature))°F) is adequate for germination")
        } else {
            let minTemp = getMinimumSoilTemperature(cropType: cropType)
            reasons.append("Soil temperature (\(Int(soilReadiness.temperature))°F) below minimum (\(Int(minTemp))°F)")

            if let days = soilReadiness.daysUntilReady {
                reasons.append("Soil expected to warm sufficiently in \(days) days")
            }
        }

        // Frost risk
        if frostRisk.probability > 0.3 {
            if let lastFrost = frostRisk.lastFrostDate {
                reasons.append("Frost risk \(Int(frostRisk.probability * 100))% - average last frost: \(formatter.string(from: lastFrost))")
            } else {
                reasons.append("Frost risk \(Int(frostRisk.probability * 100))% based on forecast")
            }
        } else {
            reasons.append("Frost risk is minimal (\(Int(frostRisk.probability * 100))%)")
        }

        // Moisture
        switch moistureStatus.status {
        case .optimal:
            reasons.append("Soil moisture (\(Int(moistureStatus.current))%) is ideal for planting")
        case .tooDry:
            reasons.append("Soil moisture (\(Int(moistureStatus.current))%) below optimal - irrigation recommended")
        case .tooWet:
            reasons.append("Soil moisture (\(Int(moistureStatus.current))%) too high - allow time to dry")
        }

        // Current risk
        if currentRisk == .veryHigh || currentRisk == .high {
            reasons.append("⚠️ Planting now carries \(currentRisk.rawValue.lowercased()) risk - consider waiting")
        }

        return reasons
    }

    // MARK: - Maturity & Yield

    private func calculateMaturityDate(
        plantingDate: Date,
        cropType: CropType,
        latitude: Double
    ) -> Date {

        let daysToMaturity = cropType.growingSeasonDays

        // Adjust for latitude (longer days in north extend growing season slightly)
        let latitudeAdjustment = Int((latitude - 40) * 0.5)

        let totalDays = daysToMaturity + latitudeAdjustment

        return Calendar.current.date(byAdding: .day, value: totalDays, to: plantingDate)!
    }

    private func estimateYieldByPlantingDate(
        plantingDate: Date,
        optimalDate: Date,
        cropType: CropType
    ) -> Double {

        let typicalYield = cropType.typicalYield

        // Calculate yield penalty for non-optimal planting
        let daysFromOptimal = abs(Calendar.current.dateComponents([.day], from: optimalDate, to: plantingDate).day ?? 0)

        var yieldMultiplier: Double = 1.0

        if daysFromOptimal <= 7 {
            yieldMultiplier = 1.0  // No penalty
        } else if daysFromOptimal <= 14 {
            yieldMultiplier = 0.98  // 2% penalty
        } else if daysFromOptimal <= 21 {
            yieldMultiplier = 0.95  // 5% penalty
        } else if daysFromOptimal <= 30 {
            yieldMultiplier = 0.90  // 10% penalty
        } else {
            yieldMultiplier = 0.80  // 20% penalty
        }

        return typicalYield * yieldMultiplier
    }

    // MARK: - Confidence

    private func calculateConfidence(
        hasWeatherForecast: Bool,
        hasHistoricalData: Bool,
        soilDataQuality: Double
    ) -> Double {
        var confidence = 0.6

        if hasWeatherForecast {
            confidence += 0.15
        }

        if hasHistoricalData {
            confidence += 0.15
        }

        confidence += soilDataQuality * 0.1

        return min(1.0, confidence)
    }
}
