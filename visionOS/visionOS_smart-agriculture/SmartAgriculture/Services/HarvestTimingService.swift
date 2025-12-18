//
//  HarvestTimingService.swift
//  SmartAgriculture
//
//  Created by Claude on 11/17/25.
//

import Foundation

/// Harvest timing recommendation
struct HarvestRecommendation: Codable, Hashable, Identifiable {
    let id: UUID
    var cropType: CropType
    var optimalHarvestDate: Date
    var earlyHarvestDate: Date
    var lateHarvestDate: Date
    var currentReadiness: ReadinessLevel
    var maturityLevel: Double           // 0-100%
    var moistureContent: Double         // Percentage
    var qualityScore: Double            // 0-100
    var weatherRisk: WeatherRisk
    var yieldImpact: YieldImpact
    var recommendations: [String]
    var estimatedYield: Double          // Bushels per acre
    var estimatedRevenue: Double        // Per acre
    var urgency: UrgencyLevel
    var confidence: Double              // 0-1

    enum ReadinessLevel: String, Codable {
        case tooEarly = "Too Early"
        case approaching = "Approaching"
        case ready = "Ready"
        case optimal = "Optimal"
        case pastPeak = "Past Peak"
        case urgent = "Urgent"

        var color: String {
            switch self {
            case .tooEarly: return "gray"
            case .approaching: return "yellow"
            case .ready, .optimal: return "green"
            case .pastPeak: return "orange"
            case .urgent: return "red"
            }
        }
    }

    enum UrgencyLevel: String, Codable {
        case none = "No Rush"
        case low = "Low"
        case medium = "Medium"
        case high = "High"
        case critical = "Critical"
    }

    struct WeatherRisk: Codable, Hashable {
        var riskLevel: RiskLevel
        var threats: [String]
        var delayImpact: Double         // Yield loss % per day
        var recommendedWindow: Int      // Days remaining

        enum RiskLevel: String, Codable {
            case low = "Low"
            case moderate = "Moderate"
            case high = "High"
            case severe = "Severe"
        }
    }

    struct YieldImpact: Codable, Hashable {
        var harvestNow: Double          // Current yield if harvested now
        var harvestOptimal: Double      // Maximum potential yield
        var harvestDelayed: Double      // Yield if delayed 7 days
        var qualityPremium: Double      // Price premium/penalty
    }

    init(
        cropType: CropType,
        optimalHarvestDate: Date,
        earlyHarvestDate: Date,
        lateHarvestDate: Date,
        currentReadiness: ReadinessLevel,
        maturityLevel: Double,
        moistureContent: Double,
        qualityScore: Double,
        weatherRisk: WeatherRisk,
        yieldImpact: YieldImpact,
        recommendations: [String],
        estimatedYield: Double,
        estimatedRevenue: Double,
        urgency: UrgencyLevel,
        confidence: Double
    ) {
        self.id = UUID()
        self.cropType = cropType
        self.optimalHarvestDate = optimalHarvestDate
        self.earlyHarvestDate = earlyHarvestDate
        self.lateHarvestDate = lateHarvestDate
        self.currentReadiness = currentReadiness
        self.maturityLevel = maturityLevel
        self.moistureContent = moistureContent
        self.qualityScore = qualityScore
        self.weatherRisk = weatherRisk
        self.yieldImpact = yieldImpact
        self.recommendations = recommendations
        self.estimatedYield = estimatedYield
        self.estimatedRevenue = estimatedRevenue
        self.urgency = urgency
        self.confidence = confidence
    }
}

/// Service for optimizing harvest timing
actor HarvestTimingService {

    // MARK: - Harvest Timing Optimization

    /// Calculates optimal harvest timing based on crop maturity, weather, and market conditions
    func calculateOptimalHarvestTiming(
        field: Field,
        plantingDate: Date,
        currentDate: Date = Date(),
        currentWeather: WeatherConditions,
        weatherForecast: [WeatherConditions] = [],
        marketPrice: Double? = nil
    ) async throws -> HarvestRecommendation {

        // Calculate maturity level
        let maturityLevel = calculateMaturity(
            field: field,
            plantingDate: plantingDate,
            currentDate: currentDate,
            growingDegreeDays: currentWeather.growingDegreeDays
        )

        // Assess moisture content
        let moistureContent = estimateMoistureContent(
            maturityLevel: maturityLevel,
            cropType: field.cropType,
            weather: currentWeather
        )

        // Calculate quality score
        let qualityScore = assessQualityScore(
            maturityLevel: maturityLevel,
            moistureContent: moistureContent,
            cropType: field.cropType,
            healthScore: field.currentHealthScore ?? 70
        )

        // Assess weather risks
        let weatherRisk = assessWeatherRisk(
            currentWeather: currentWeather,
            forecast: weatherForecast,
            maturityLevel: maturityLevel,
            cropType: field.cropType
        )

        // Calculate harvest window
        let harvestWindow = calculateHarvestWindow(
            plantingDate: plantingDate,
            cropType: field.cropType,
            maturityLevel: maturityLevel
        )

        // Determine current readiness
        let readiness = determineReadiness(
            maturityLevel: maturityLevel,
            moistureContent: moistureContent,
            qualityScore: qualityScore,
            weatherRisk: weatherRisk
        )

        // Calculate yield impacts
        let yieldImpact = calculateYieldImpacts(
            field: field,
            maturityLevel: maturityLevel,
            moistureContent: moistureContent,
            qualityScore: qualityScore,
            currentDate: currentDate,
            optimalDate: harvestWindow.optimal
        )

        // Generate recommendations
        let recommendations = generateHarvestRecommendations(
            readiness: readiness,
            maturityLevel: maturityLevel,
            moistureContent: moistureContent,
            weatherRisk: weatherRisk,
            yieldImpact: yieldImpact,
            cropType: field.cropType
        )

        // Calculate revenue
        let basePrice = marketPrice ?? getBasePrice(cropType: field.cropType)
        let qualityAdjustedPrice = basePrice * (1.0 + yieldImpact.qualityPremium)
        let revenue = yieldImpact.harvestOptimal * qualityAdjustedPrice

        // Determine urgency
        let urgency = determineUrgency(
            readiness: readiness,
            weatherRisk: weatherRisk,
            daysToOptimal: Calendar.current.dateComponents([.day], from: currentDate, to: harvestWindow.optimal).day ?? 0
        )

        // Calculate confidence
        let confidence = calculateConfidence(
            hasWeatherForecast: !weatherForecast.isEmpty,
            hasPlantingDate: true,
            dataQuality: field.currentHealthScore != nil ? 1.0 : 0.7
        )

        return HarvestRecommendation(
            cropType: field.cropType,
            optimalHarvestDate: harvestWindow.optimal,
            earlyHarvestDate: harvestWindow.early,
            lateHarvestDate: harvestWindow.late,
            currentReadiness: readiness,
            maturityLevel: maturityLevel,
            moistureContent: moistureContent,
            qualityScore: qualityScore,
            weatherRisk: weatherRisk,
            yieldImpact: yieldImpact,
            recommendations: recommendations,
            estimatedYield: yieldImpact.harvestOptimal,
            estimatedRevenue: revenue,
            urgency: urgency,
            confidence: confidence
        )
    }

    // MARK: - Maturity Calculation

    private func calculateMaturity(
        field: Field,
        plantingDate: Date,
        currentDate: Date,
        growingDegreeDays: Double
    ) -> Double {

        // Calculate days since planting
        let daysSincePlanting = Calendar.current.dateComponents([.day], from: plantingDate, to: currentDate).day ?? 0

        // Get expected days to maturity
        let expectedDays = field.cropType.growingSeasonDays

        // Calculate maturity percentage based on time
        let timeBasedMaturity = min(100, (Double(daysSincePlanting) / Double(expectedDays)) * 100)

        // Calculate maturity based on GDD
        let requiredGDD = getRequiredGDD(cropType: field.cropType)
        let gddBasedMaturity = min(100, (growingDegreeDays / requiredGDD) * 100)

        // Average the two methods
        let maturity = (timeBasedMaturity * 0.4) + (gddBasedMaturity * 0.6)

        return min(100, max(0, maturity))
    }

    private func getRequiredGDD(cropType: CropType) -> Double {
        switch cropType {
        case .corn: return 2700
        case .soybeans: return 2200
        case .wheat: return 2000
        case .cotton: return 2800
        default: return 2400
        }
    }

    // MARK: - Moisture Content

    private func estimateMoistureContent(
        maturityLevel: Double,
        cropType: CropType,
        weather: WeatherConditions
    ) -> Double {

        // Grain moisture decreases as it matures
        let baselineMoisture = getInitialMoisture(cropType: cropType)

        // Moisture decreases with maturity
        let maturityFactor = (100 - maturityLevel) / 100.0
        var moisture = baselineMoisture * (0.4 + maturityFactor * 0.6)

        // Weather impacts
        if weather.humidity > 75 {
            moisture += 2.0  // High humidity slows drying
        } else if weather.humidity < 40 {
            moisture -= 2.0  // Low humidity accelerates drying
        }

        if weather.precipitation > 0.5 {
            moisture += 3.0  // Recent rain increases moisture
        }

        return max(10, min(35, moisture))
    }

    private func getInitialMoisture(cropType: CropType) -> Double {
        switch cropType {
        case .corn: return 30.0
        case .soybeans: return 20.0
        case .wheat: return 18.0
        default: return 25.0
        }
    }

    private func getTargetMoisture(cropType: CropType) -> ClosedRange<Double> {
        switch cropType {
        case .corn: return 15.0...20.0
        case .soybeans: return 13.0...15.0
        case .wheat: return 12.0...14.0
        default: return 14.0...18.0
        }
    }

    // MARK: - Quality Assessment

    private func assessQualityScore(
        maturityLevel: Double,
        moistureContent: Double,
        cropType: CropType,
        healthScore: Double
    ) -> Double {

        var quality: Double = 60  // Base quality

        // Optimal maturity (95-100%) gives best quality
        if maturityLevel >= 95 && maturityLevel <= 100 {
            quality += 20
        } else if maturityLevel >= 90 {
            quality += 15
        } else if maturityLevel < 85 {
            quality -= 10
        } else if maturityLevel > 105 {
            quality -= 15  // Over-mature reduces quality
        }

        // Optimal moisture range
        let targetMoisture = getTargetMoisture(cropType: cropType)
        if targetMoisture.contains(moistureContent) {
            quality += 15
        } else {
            let deviation = min(
                abs(moistureContent - targetMoisture.lowerBound),
                abs(moistureContent - targetMoisture.upperBound)
            )
            quality -= deviation * 2
        }

        // Health impacts quality
        quality += (healthScore - 70) * 0.15

        return max(0, min(100, quality))
    }

    // MARK: - Weather Risk

    private func assessWeatherRisk(
        currentWeather: WeatherConditions,
        forecast: [WeatherConditions],
        maturityLevel: Double,
        cropType: CropType
    ) -> HarvestRecommendation.WeatherRisk {

        var threats: [String] = []
        var riskScore: Double = 0

        // Check current conditions
        if currentWeather.precipitation > 1.0 {
            threats.append("Recent heavy rain - field conditions may be too wet")
            riskScore += 30
        }

        if currentWeather.windSpeed > 30 {
            threats.append("High winds - lodging risk")
            riskScore += 25
        }

        // Check forecast
        let heavyRainDays = forecast.filter { $0.precipitation > 1.5 }.count
        if heavyRainDays > 0 {
            threats.append("\(heavyRainDays) day(s) of heavy rain forecasted")
            riskScore += Double(heavyRainDays) * 15
        }

        let frostDays = forecast.filter { $0.temperature < 32 }.count
        if frostDays > 0 && maturityLevel < 100 {
            threats.append("Frost risk - may damage immature crop")
            riskScore += 40
        }

        // Hail risk (simplified - based on severe weather indicators)
        if forecast.contains(where: { $0.temperature > 80 && $0.humidity > 70 && $0.windSpeed > 20 }) {
            threats.append("Severe weather possible - hail risk")
            riskScore += 35
        }

        // Determine risk level
        let riskLevel: HarvestRecommendation.WeatherRisk.RiskLevel
        switch riskScore {
        case 0..<20:
            riskLevel = .low
        case 20..<50:
            riskLevel = .moderate
        case 50..<80:
            riskLevel = .high
        default:
            riskLevel = .severe
        }

        // Calculate delay impact (yield loss per day of delay)
        var delayImpact: Double = 0.5  // Base 0.5% per day
        if riskLevel == .high || riskLevel == .severe {
            delayImpact = 1.5  // Higher loss with weather threats
        }
        if maturityLevel > 100 {
            delayImpact += 0.5  // Additional loss when over-mature
        }

        // Recommended window
        let recommendedWindow = riskLevel == .severe ? 2 : riskLevel == .high ? 5 : 10

        return HarvestRecommendation.WeatherRisk(
            riskLevel: riskLevel,
            threats: threats,
            delayImpact: delayImpact,
            recommendedWindow: recommendedWindow
        )
    }

    // MARK: - Harvest Window

    private struct HarvestWindow {
        var early: Date
        var optimal: Date
        var late: Date
    }

    private func calculateHarvestWindow(
        plantingDate: Date,
        cropType: CropType,
        maturityLevel: Double
    ) -> HarvestWindow {

        let calendar = Calendar.current
        let daysToMaturity = cropType.growingSeasonDays

        // Base dates
        let optimalDate = calendar.date(byAdding: .day, value: daysToMaturity, to: plantingDate)!
        let earlyDate = calendar.date(byAdding: .day, value: -7, to: optimalDate)!
        let lateDate = calendar.date(byAdding: .day, value: 14, to: optimalDate)!

        return HarvestWindow(early: earlyDate, optimal: optimalDate, late: lateDate)
    }

    // MARK: - Readiness

    private func determineReadiness(
        maturityLevel: Double,
        moistureContent: Double,
        qualityScore: Double,
        weatherRisk: HarvestRecommendation.WeatherRisk
    ) -> HarvestRecommendation.ReadinessLevel {

        // Urgent if weather threatens and crop is harvestable
        if weatherRisk.riskLevel == .severe && maturityLevel >= 90 {
            return .urgent
        }

        // Too early
        if maturityLevel < 85 {
            return .tooEarly
        }

        // Approaching
        if maturityLevel >= 85 && maturityLevel < 92 {
            return .approaching
        }

        // Past peak
        if maturityLevel > 105 || qualityScore < 60 {
            return .pastPeak
        }

        // Optimal
        if maturityLevel >= 95 && maturityLevel <= 100 && qualityScore >= 80 {
            return .optimal
        }

        // Ready
        return .ready
    }

    // MARK: - Yield Impact

    private func calculateYieldImpacts(
        field: Field,
        maturityLevel: Double,
        moistureContent: Double,
        qualityScore: Double,
        currentDate: Date,
        optimalDate: Date
    ) -> HarvestRecommendation.YieldImpact {

        let baseYield = field.predictedYield ?? field.cropType.typicalYield

        // Harvest now
        var harvestNow = baseYield
        if maturityLevel < 95 {
            harvestNow *= (maturityLevel / 95.0 * 0.85 + 0.15)  // Penalty for early harvest
        } else if maturityLevel > 100 {
            harvestNow *= (1.0 - ((maturityLevel - 100) * 0.01))  // Loss from over-maturity
        }

        // Harvest at optimal
        let harvestOptimal = baseYield * 1.0  // Full yield potential

        // Harvest delayed
        let daysDelay = 7
        let delayPenalty = 0.007 * Double(daysDelay)  // 0.7% per day
        var harvestDelayed = baseYield * (1.0 - delayPenalty)

        // Additional penalty if already past optimal
        if maturityLevel > 100 {
            harvestDelayed *= 0.93  // Additional 7% loss
        }

        // Quality premium/penalty
        var premium: Double = 0
        if qualityScore >= 90 {
            premium = 0.05  // 5% price premium for excellent quality
        } else if qualityScore >= 80 {
            premium = 0.02  // 2% premium for good quality
        } else if qualityScore < 60 {
            premium = -0.10  // 10% discount for poor quality
        } else if qualityScore < 70 {
            premium = -0.05  // 5% discount for below-average quality
        }

        // Moisture content discount (if too high, drying costs reduce price)
        let targetMoisture = getTargetMoisture(cropType: field.cropType)
        if moistureContent > targetMoisture.upperBound {
            let excessMoisture = moistureContent - targetMoisture.upperBound
            premium -= excessMoisture * 0.005  // 0.5% per point over
        }

        return HarvestRecommendation.YieldImpact(
            harvestNow: harvestNow,
            harvestOptimal: harvestOptimal,
            harvestDelayed: harvestDelayed,
            qualityPremium: premium
        )
    }

    // MARK: - Recommendations

    private func generateHarvestRecommendations(
        readiness: HarvestRecommendation.ReadinessLevel,
        maturityLevel: Double,
        moistureContent: Double,
        weatherRisk: HarvestRecommendation.WeatherRisk,
        yieldImpact: HarvestRecommendation.YieldImpact,
        cropType: CropType
    ) -> [String] {

        var recommendations: [String] = []

        switch readiness {
        case .tooEarly:
            recommendations.append("Crop maturity at \(Int(maturityLevel))% - wait \(Int((95 - maturityLevel) * 0.7)) more days")
            recommendations.append("Continue monitoring maturity progression daily")

        case .approaching:
            recommendations.append("Maturity at \(Int(maturityLevel))% - harvest window opens in 3-7 days")
            recommendations.append("Begin preparing equipment and checking field access")
            if moistureContent > 20 {
                recommendations.append("Monitor moisture - currently \(String(format: "%.1f", moistureContent))%, target 15-18%")
            }

        case .ready:
            recommendations.append("✓ Crop is ready for harvest - proceed when conditions allow")
            if weatherRisk.riskLevel != .low {
                recommendations.append("Weather risks present: \(weatherRisk.threats.joined(separator: ", "))")
            }
            recommendations.append("Optimal window: next \(weatherRisk.recommendedWindow) days")

        case .optimal:
            recommendations.append("⭐ Peak harvest conditions - harvest immediately for maximum yield and quality")
            recommendations.append("Estimated yield: \(String(format: "%.1f", yieldImpact.harvestOptimal)) bu/acre")
            if weatherRisk.riskLevel != .low {
                recommendations.append("Complete harvest quickly - weather risks approaching")
            }

        case .pastPeak:
            recommendations.append("⚠️ Crop is past optimal maturity - harvest ASAP to minimize losses")
            recommendations.append("Current losses: \(String(format: "%.1f", (1.0 - yieldImpact.harvestNow / yieldImpact.harvestOptimal) * 100))% vs. optimal")
            recommendations.append("Each additional day reduces yield by ~\(String(format: "%.1f", weatherRisk.delayImpact))%")

        case .urgent:
            recommendations.append("🚨 URGENT - Severe weather threatens crop")
            recommendations.append("Weather risks: \(weatherRisk.threats.joined(separator: "; "))")
            recommendations.append("Harvest within \(weatherRisk.recommendedWindow) days to avoid significant losses")
        }

        // Moisture-specific recommendations
        let targetMoisture = getTargetMoisture(cropType: cropType)
        if moistureContent > targetMoisture.upperBound + 5 {
            recommendations.append("High moisture (\(String(format: "%.1f", moistureContent))%) - plan for drying costs")
        } else if moistureContent < targetMoisture.lowerBound {
            recommendations.append("Moisture is optimal for storage (\(String(format: "%.1f", moistureContent))%)")
        }

        return recommendations
    }

    // MARK: - Urgency

    private func determineUrgency(
        readiness: HarvestRecommendation.ReadinessLevel,
        weatherRisk: HarvestRecommendation.WeatherRisk,
        daysToOptimal: Int
    ) -> HarvestRecommendation.UrgencyLevel {

        if readiness == .urgent {
            return .critical
        }

        if readiness == .pastPeak {
            return .high
        }

        if readiness == .optimal && weatherRisk.riskLevel == .high {
            return .high
        }

        if readiness == .optimal || (readiness == .ready && weatherRisk.riskLevel == .moderate) {
            return .medium
        }

        if readiness == .ready {
            return .low
        }

        return .none
    }

    // MARK: - Market Data

    private func getBasePrice(cropType: CropType) -> Double {
        // Default market prices (per bushel)
        switch cropType {
        case .corn: return 6.50
        case .soybeans: return 14.00
        case .wheat: return 7.50
        case .cotton: return 0.85  // Per pound
        default: return 6.00
        }
    }

    // MARK: - Confidence

    private func calculateConfidence(
        hasWeatherForecast: Bool,
        hasPlantingDate: Bool,
        dataQuality: Double
    ) -> Double {
        var confidence = 0.6

        if hasWeatherForecast {
            confidence += 0.15
        }

        if hasPlantingDate {
            confidence += 0.10
        }

        confidence += dataQuality * 0.15

        return min(1.0, confidence)
    }
}
