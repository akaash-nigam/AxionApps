//
//  WeatherImpactService.swift
//  SmartAgriculture
//
//  Created by Claude on 11/17/25.
//

import Foundation

/// Represents weather conditions and their measurements
struct WeatherConditions: Codable, Hashable {
    var temperature: Double          // °F
    var precipitation: Double        // Inches
    var humidity: Double            // Percentage (0-100)
    var windSpeed: Double           // MPH
    var solarRadiation: Double      // W/m²
    var daysSinceRain: Int
    var growingDegreeDays: Double   // GDD accumulation
    var timestamp: Date

    init(
        temperature: Double,
        precipitation: Double,
        humidity: Double,
        windSpeed: Double,
        solarRadiation: Double,
        daysSinceRain: Int,
        growingDegreeDays: Double,
        timestamp: Date = Date()
    ) {
        self.temperature = temperature
        self.precipitation = precipitation
        self.humidity = humidity
        self.windSpeed = windSpeed
        self.solarRadiation = solarRadiation
        self.daysSinceRain = daysSinceRain
        self.growingDegreeDays = growingDegreeDays
        self.timestamp = timestamp
    }
}

/// Weather impact assessment on crop performance
struct WeatherImpact: Codable, Hashable, Identifiable {
    let id: UUID
    var overallImpact: ImpactLevel       // Positive, neutral, or negative
    var yieldImpactPercentage: Double    // -100 to +100
    var stressFactors: [StressFactor]
    var recommendations: [String]
    var confidence: Double               // 0-1
    var assessmentDate: Date

    enum ImpactLevel: String, Codable {
        case veryPositive = "Very Positive"
        case positive = "Positive"
        case neutral = "Neutral"
        case negative = "Negative"
        case veryNegative = "Very Negative"

        var color: String {
            switch self {
            case .veryPositive: return "green"
            case .positive: return "lightGreen"
            case .neutral: return "gray"
            case .negative: return "orange"
            case .veryNegative: return "red"
            }
        }
    }

    struct StressFactor: Codable, Hashable, Identifiable {
        let id: UUID
        var type: StressType
        var severity: Double    // 0-100
        var description: String

        enum StressType: String, Codable {
            case heat, cold, drought, flooding, wind, hail, frost
        }

        init(type: StressType, severity: Double, description: String) {
            self.id = UUID()
            self.type = type
            self.severity = severity
            self.description = description
        }
    }

    init(
        overallImpact: ImpactLevel,
        yieldImpactPercentage: Double,
        stressFactors: [StressFactor],
        recommendations: [String],
        confidence: Double,
        assessmentDate: Date = Date()
    ) {
        self.id = UUID()
        self.overallImpact = overallImpact
        self.yieldImpactPercentage = yieldImpactPercentage
        self.stressFactors = stressFactors
        self.recommendations = recommendations
        self.confidence = confidence
        self.assessmentDate = assessmentDate
    }
}

/// Service for analyzing weather impact on crop performance
actor WeatherImpactService {

    // MARK: - Weather Impact Analysis

    /// Analyzes how current and historical weather affects crop performance
    func analyzeWeatherImpact(
        conditions: WeatherConditions,
        cropType: CropType,
        growthStage: GrowthStage,
        historicalConditions: [WeatherConditions] = []
    ) async throws -> WeatherImpact {

        var stressFactors: [WeatherImpact.StressFactor] = []
        var recommendations: [String] = []
        var totalImpact: Double = 0

        // Analyze temperature stress
        let tempStress = analyzeTemperatureStress(
            conditions.temperature,
            cropType: cropType,
            growthStage: growthStage
        )
        if tempStress.severity > 20 {
            stressFactors.append(tempStress)
            totalImpact += (tempStress.severity / 100.0) * -15  // Up to -15% impact
        }

        // Analyze water stress (drought or flooding)
        let waterStress = analyzeWaterStress(
            conditions: conditions,
            cropType: cropType,
            growthStage: growthStage
        )
        if let stress = waterStress {
            stressFactors.append(stress)
            totalImpact += (stress.severity / 100.0) * -25  // Up to -25% impact

            if stress.type == .drought {
                recommendations.append("Consider emergency irrigation - yield impact projected at \(Int(stress.severity))%")
            } else if stress.type == .flooding {
                recommendations.append("Implement drainage improvements to prevent waterlogging")
            }
        }

        // Analyze growing degree days (positive or negative impact)
        let gddImpact = analyzeGrowingDegreeDays(
            conditions.growingDegreeDays,
            cropType: cropType,
            growthStage: growthStage
        )
        totalImpact += gddImpact

        if gddImpact > 5 {
            recommendations.append("Excellent heat accumulation - expect accelerated growth")
        } else if gddImpact < -5 {
            recommendations.append("Below-average heat units may delay maturity by 5-10 days")
        }

        // Analyze solar radiation
        let solarImpact = analyzeSolarRadiation(
            conditions.solarRadiation,
            cropType: cropType,
            growthStage: growthStage
        )
        totalImpact += solarImpact

        // Analyze wind stress
        if conditions.windSpeed > 25 {
            let windSeverity = min(100, (conditions.windSpeed - 25) * 3)
            stressFactors.append(WeatherImpact.StressFactor(
                type: .wind,
                severity: windSeverity,
                description: "High winds (\(Int(conditions.windSpeed)) MPH) may cause lodging"
            ))
            totalImpact -= windSeverity / 100.0 * 10  // Up to -10% impact
            recommendations.append("Monitor for lodging damage, especially in reproductive stages")
        }

        // Calculate humidity impact
        let humidityImpact = analyzeHumidity(
            conditions.humidity,
            temperature: conditions.temperature,
            cropType: cropType
        )
        totalImpact += humidityImpact

        if conditions.humidity > 85 && conditions.temperature > 70 {
            recommendations.append("High humidity and temperature increase disease risk - scout for fungal infections")
        }

        // Determine overall impact level
        let impactLevel: WeatherImpact.ImpactLevel
        switch totalImpact {
        case 15...:
            impactLevel = .veryPositive
        case 5..<15:
            impactLevel = .positive
        case -5..<5:
            impactLevel = .neutral
        case -15..<(-5):
            impactLevel = .negative
        default:
            impactLevel = .veryNegative
        }

        // Calculate confidence based on data completeness
        let confidence = calculateConfidence(
            hasHistorical: !historicalConditions.isEmpty,
            dataAge: Date().timeIntervalSince(conditions.timestamp)
        )

        return WeatherImpact(
            overallImpact: impactLevel,
            yieldImpactPercentage: totalImpact,
            stressFactors: stressFactors,
            recommendations: recommendations,
            confidence: confidence
        )
    }

    // MARK: - Temperature Analysis

    private func analyzeTemperatureStress(
        _ temperature: Double,
        cropType: CropType,
        growthStage: GrowthStage
    ) -> WeatherImpact.StressFactor {

        let optimalRange = getOptimalTemperatureRange(cropType: cropType, stage: growthStage)

        if temperature < optimalRange.lowerBound {
            let deviation = optimalRange.lowerBound - temperature
            let severity = min(100, deviation * 5)  // 5% per degree below

            if temperature < 32 {
                return WeatherImpact.StressFactor(
                    type: .frost,
                    severity: 100,
                    description: "Frost conditions (\(Int(temperature))°F) - critical crop damage likely"
                )
            }

            return WeatherImpact.StressFactor(
                type: .cold,
                severity: severity,
                description: "Below optimal temperature (\(Int(temperature))°F) - reduced growth rate"
            )
        } else if temperature > optimalRange.upperBound {
            let deviation = temperature - optimalRange.upperBound
            let severity = min(100, deviation * 4)  // 4% per degree above

            return WeatherImpact.StressFactor(
                type: .heat,
                severity: severity,
                description: "Heat stress (\(Int(temperature))°F) - \(getHeatStressDescription(growthStage))"
            )
        }

        // Within optimal range
        return WeatherImpact.StressFactor(
            type: .heat,
            severity: 0,
            description: "Temperature within optimal range"
        )
    }

    private func getOptimalTemperatureRange(cropType: CropType, stage: GrowthStage) -> ClosedRange<Double> {
        // Crop-specific optimal temperature ranges (°F)
        switch cropType {
        case .corn:
            return stage == .reproductive ? 70...85 : 65...85
        case .soybeans:
            return 68...85
        case .wheat:
            return 60...75
        case .cotton:
            return 75...90
        case .rice:
            return 75...95
        default:
            return 65...85
        }
    }

    private func getHeatStressDescription(_ stage: GrowthStage) -> String {
        switch stage {
        case .reproductive:
            return "pollen viability reduced, kernel set affected"
        case .vegetative:
            return "accelerated development, increased water demand"
        case .maturity:
            return "reduced fill period, potential quality issues"
        default:
            return "growth impacted"
        }
    }

    // MARK: - Water Stress Analysis

    private func analyzeWaterStress(
        conditions: WeatherConditions,
        cropType: CropType,
        growthStage: GrowthStage
    ) -> WeatherImpact.StressFactor? {

        // Check for drought conditions
        if conditions.daysSinceRain > 7 && conditions.precipitation < 0.5 {
            let severity = min(100, Double(conditions.daysSinceRain - 7) * 8)

            let criticalStages: Set<GrowthStage> = [.reproductive, .vegetative]
            let multiplier = criticalStages.contains(growthStage) ? 1.5 : 1.0

            return WeatherImpact.StressFactor(
                type: .drought,
                severity: severity * multiplier,
                description: "\(conditions.daysSinceRain) days without significant rain - soil moisture deficit"
            )
        }

        // Check for flooding conditions
        if conditions.precipitation > 3.0 {
            let severity = min(100, (conditions.precipitation - 3.0) * 20)

            return WeatherImpact.StressFactor(
                type: .flooding,
                severity: severity,
                description: "Excessive rainfall (\(String(format: "%.1f", conditions.precipitation)) inches) - waterlogging risk"
            )
        }

        return nil
    }

    // MARK: - Growing Degree Days Analysis

    private func analyzeGrowingDegreeDays(
        _ gdd: Double,
        cropType: CropType,
        growthStage: GrowthStage
    ) -> Double {

        let expectedGDD = getExpectedGDD(cropType: cropType, stage: growthStage)
        let deviation = ((gdd - expectedGDD) / expectedGDD) * 100

        // Positive GDD deviation can be good (faster growth) or bad (too fast)
        if deviation > 20 {
            return 5  // Moderate positive impact
        } else if deviation > 10 {
            return 10  // Good growing conditions
        } else if deviation < -20 {
            return -15  // Significant negative impact
        } else if deviation < -10 {
            return -8  // Moderate negative impact
        }

        return 0  // Neutral
    }

    private func getExpectedGDD(cropType: CropType, stage: GrowthStage) -> Double {
        // Typical GDD requirements by crop and stage
        switch cropType {
        case .corn:
            switch stage {
            case .emergence: return 120
            case .vegetative: return 800
            case .reproductive: return 1400
            case .maturity: return 2700
            default: return 1000
            }
        case .soybeans:
            switch stage {
            case .emergence: return 100
            case .vegetative: return 600
            case .reproductive: return 1200
            case .maturity: return 2200
            default: return 900
            }
        default:
            return 1000
        }
    }

    // MARK: - Solar Radiation Analysis

    private func analyzeSolarRadiation(
        _ radiation: Double,
        cropType: CropType,
        growthStage: GrowthStage
    ) -> Double {

        // Optimal solar radiation: 400-600 W/m²
        if radiation >= 400 && radiation <= 600 {
            return growthStage == .vegetative || growthStage == .reproductive ? 8 : 3
        } else if radiation > 600 {
            return 3  // Slight positive
        } else if radiation < 300 {
            return -5  // Reduced photosynthesis
        }

        return 0
    }

    // MARK: - Humidity Analysis

    private func analyzeHumidity(
        _ humidity: Double,
        temperature: Double,
        cropType: CropType
    ) -> Double {

        // Very high humidity + high temp = disease risk
        if humidity > 85 && temperature > 75 {
            return -8  // Disease pressure
        }

        // Very low humidity = transpiration stress
        if humidity < 30 {
            return -5
        }

        // Optimal humidity range: 40-70%
        if humidity >= 40 && humidity <= 70 {
            return 2
        }

        return 0
    }

    // MARK: - Confidence Calculation

    private func calculateConfidence(hasHistorical: Bool, dataAge: TimeInterval) -> Double {
        var confidence = 0.7

        // Boost confidence if we have historical data
        if hasHistorical {
            confidence += 0.15
        }

        // Reduce confidence for old data
        let hoursOld = dataAge / 3600
        if hoursOld > 24 {
            confidence -= 0.2
        } else if hoursOld > 12 {
            confidence -= 0.1
        }

        return max(0.3, min(1.0, confidence))
    }
}

// MARK: - Mock Data

extension WeatherConditions {
    static var mock: WeatherConditions {
        WeatherConditions(
            temperature: 78.0,
            precipitation: 1.2,
            humidity: 65,
            windSpeed: 8,
            solarRadiation: 520,
            daysSinceRain: 3,
            growingDegreeDays: 1250,
            timestamp: Date()
        )
    }

    static var drought: WeatherConditions {
        WeatherConditions(
            temperature: 92.0,
            precipitation: 0.1,
            humidity: 35,
            windSpeed: 15,
            solarRadiation: 650,
            daysSinceRain: 18,
            growingDegreeDays: 1500,
            timestamp: Date()
        )
    }

    static var ideal: WeatherConditions {
        WeatherConditions(
            temperature: 75.0,
            precipitation: 1.5,
            humidity: 55,
            windSpeed: 5,
            solarRadiation: 480,
            daysSinceRain: 2,
            growingDegreeDays: 1100,
            timestamp: Date()
        )
    }
}
