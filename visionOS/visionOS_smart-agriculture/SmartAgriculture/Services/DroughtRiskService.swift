//
//  DroughtRiskService.swift
//  SmartAgriculture
//
//  Created by Claude on 11/17/25.
//

import Foundation

/// Drought risk assessment levels
enum DroughtRiskLevel: String, Codable, CaseIterable {
    case none = "No Risk"
    case minimal = "Minimal"
    case moderate = "Moderate"
    case high = "High"
    case severe = "Severe"
    case extreme = "Extreme"

    var color: String {
        switch self {
        case .none: return "green"
        case .minimal: return "lightGreen"
        case .moderate: return "yellow"
        case .high: return "orange"
        case .severe: return "red"
        case .extreme: return "darkRed"
        }
    }

    var numericValue: Double {
        switch self {
        case .none: return 0
        case .minimal: return 20
        case .moderate: return 40
        case .high: return 60
        case .severe: return 80
        case .extreme: return 100
        }
    }
}

/// Comprehensive drought risk assessment
struct DroughtRiskAssessment: Codable, Hashable, Identifiable {
    let id: UUID
    var riskLevel: DroughtRiskLevel
    var riskScore: Double              // 0-100
    var daysUntilCritical: Int?        // Days before crop damage
    var soilMoistureDeficit: Double    // Percentage below optimal
    var evapotranspirationRate: Double // Inches per day
    var precipitationDeficit: Double   // Inches below normal
    var projectedYieldLoss: Double     // Percentage
    var mitigationActions: [MitigationAction]
    var forecastPeriodDays: Int
    var confidence: Double             // 0-1
    var assessmentDate: Date

    struct MitigationAction: Codable, Hashable, Identifiable {
        let id: UUID
        var action: String
        var priority: Priority
        var estimatedCost: Double
        var potentialYieldSavings: Double
        var timeframeDays: Int

        enum Priority: String, Codable {
            case immediate = "Immediate"
            case urgent = "Urgent"
            case soon = "Soon"
            case monitor = "Monitor"
        }

        init(
            action: String,
            priority: Priority,
            estimatedCost: Double,
            potentialYieldSavings: Double,
            timeframeDays: Int
        ) {
            self.id = UUID()
            self.action = action
            self.priority = priority
            self.estimatedCost = estimatedCost
            self.potentialYieldSavings = potentialYieldSavings
            self.timeframeDays = timeframeDays
        }
    }

    init(
        riskLevel: DroughtRiskLevel,
        riskScore: Double,
        daysUntilCritical: Int?,
        soilMoistureDeficit: Double,
        evapotranspirationRate: Double,
        precipitationDeficit: Double,
        projectedYieldLoss: Double,
        mitigationActions: [MitigationAction],
        forecastPeriodDays: Int,
        confidence: Double,
        assessmentDate: Date = Date()
    ) {
        self.id = UUID()
        self.riskLevel = riskLevel
        self.riskScore = riskScore
        self.daysUntilCritical = daysUntilCritical
        self.soilMoistureDeficit = soilMoistureDeficit
        self.evapotranspirationRate = evapotranspirationRate
        self.precipitationDeficit = precipitationDeficit
        self.projectedYieldLoss = projectedYieldLoss
        self.mitigationActions = mitigationActions
        self.forecastPeriodDays = forecastPeriodDays
        self.confidence = confidence
        self.assessmentDate = assessmentDate
    }
}

/// Historical precipitation data
struct PrecipitationRecord: Codable, Hashable {
    var date: Date
    var amount: Double  // Inches
    var daysInPeriod: Int

    var dailyAverage: Double {
        amount / Double(daysInPeriod)
    }
}

/// Service for predicting and assessing drought risk
actor DroughtRiskService {

    // MARK: - Drought Risk Assessment

    /// Assesses current and forecasted drought risk for a field
    func assessDroughtRisk(
        field: Field,
        currentWeather: WeatherConditions,
        soilMoisture: Double,
        historicalPrecipitation: [PrecipitationRecord],
        forecastedPrecipitation: [PrecipitationRecord] = []
    ) async throws -> DroughtRiskAssessment {

        // Calculate precipitation deficit
        let normalPrecip = calculateNormalPrecipitation(
            historical: historicalPrecipitation,
            daysBack: 30
        )
        let recentPrecip = historicalPrecipitation
            .filter { Calendar.current.dateComponents([.day], from: $0.date, to: Date()).day ?? 0 <= 30 }
            .reduce(0.0) { $0 + $1.amount }

        let precipDeficit = normalPrecip - recentPrecip

        // Calculate evapotranspiration rate
        let etRate = calculateEvapotranspiration(
            temperature: currentWeather.temperature,
            humidity: currentWeather.humidity,
            windSpeed: currentWeather.windSpeed,
            solarRadiation: currentWeather.solarRadiation,
            cropType: field.cropType,
            growthStage: field.growthStage
        )

        // Calculate soil moisture deficit
        let optimalMoisture = getOptimalSoilMoisture(
            cropType: field.cropType,
            growthStage: field.growthStage
        )
        let moistureDeficit = max(0, optimalMoisture - soilMoisture)

        // Calculate overall drought risk score
        var riskScore: Double = 0

        // Factor 1: Days since rain (0-30 points)
        riskScore += min(30, Double(currentWeather.daysSinceRain) * 2)

        // Factor 2: Soil moisture deficit (0-30 points)
        riskScore += (moistureDeficit / optimalMoisture) * 30

        // Factor 3: Precipitation deficit (0-25 points)
        if normalPrecip > 0 {
            riskScore += min(25, (precipDeficit / normalPrecip) * 25)
        }

        // Factor 4: High evapotranspiration (0-15 points)
        if etRate > 0.25 {
            riskScore += min(15, (etRate - 0.25) * 60)
        }

        riskScore = min(100, riskScore)

        // Determine risk level
        let riskLevel = getRiskLevel(from: riskScore)

        // Calculate days until critical
        let daysUntilCritical = calculateDaysUntilCritical(
            soilMoisture: soilMoisture,
            etRate: etRate,
            forecastedPrecipitation: forecastedPrecipitation,
            cropType: field.cropType
        )

        // Project yield loss
        let yieldLoss = projectYieldLoss(
            riskScore: riskScore,
            moistureDeficit: moistureDeficit,
            growthStage: field.growthStage,
            daysInDrought: currentWeather.daysSinceRain
        )

        // Generate mitigation actions
        let actions = generateMitigationActions(
            field: field,
            riskLevel: riskLevel,
            daysUntilCritical: daysUntilCritical,
            yieldLoss: yieldLoss,
            soilMoistureDeficit: moistureDeficit
        )

        // Calculate confidence
        let confidence = calculateConfidence(
            hasHistorical: !historicalPrecipitation.isEmpty,
            hasForecast: !forecastedPrecipitation.isEmpty,
            dataQuality: soilMoisture > 0 ? 1.0 : 0.5
        )

        return DroughtRiskAssessment(
            riskLevel: riskLevel,
            riskScore: riskScore,
            daysUntilCritical: daysUntilCritical,
            soilMoistureDeficit: moistureDeficit,
            evapotranspirationRate: etRate,
            precipitationDeficit: max(0, precipDeficit),
            projectedYieldLoss: yieldLoss,
            mitigationActions: actions,
            forecastPeriodDays: forecastedPrecipitation.isEmpty ? 7 : 14,
            confidence: confidence
        )
    }

    // MARK: - Precipitation Analysis

    private func calculateNormalPrecipitation(
        historical: [PrecipitationRecord],
        daysBack: Int
    ) -> Double {
        // Calculate average for same period in previous years
        let calendar = Calendar.current
        let now = Date()

        let relevantRecords = historical.filter { record in
            let components = calendar.dateComponents([.month, .day], from: record.date)
            let currentComponents = calendar.dateComponents([.month, .day], from: now)

            // Same month (+/- 15 days) from previous years
            return abs((components.month ?? 0) - (currentComponents.month ?? 0)) <= 1
        }

        if relevantRecords.isEmpty {
            return 3.0  // Default fallback
        }

        let totalAmount = relevantRecords.reduce(0.0) { $0 + $1.amount }
        return totalAmount / Double(relevantRecords.count)
    }

    // MARK: - Evapotranspiration

    private func calculateEvapotranspiration(
        temperature: Double,
        humidity: Double,
        windSpeed: Double,
        solarRadiation: Double,
        cropType: CropType,
        growthStage: GrowthStage
    ) -> Double {
        // Simplified Penman-Monteith equation approximation
        // Base ET (reference crop)

        // Temperature factor
        let tempFactor = (temperature - 32) / 180.0  // Normalize to 0-1

        // Humidity factor (lower humidity = higher ET)
        let humidityFactor = (100 - humidity) / 100.0

        // Wind factor
        let windFactor = min(1.5, 1.0 + (windSpeed / 50.0))

        // Solar radiation factor
        let solarFactor = solarRadiation / 600.0

        // Base ET
        var et = 0.15 * tempFactor * humidityFactor * windFactor * solarFactor

        // Crop coefficient
        let cropCoefficient = getCropCoefficient(cropType: cropType, stage: growthStage)
        et *= cropCoefficient

        return max(0, min(0.5, et))  // Cap at 0.5 inches/day
    }

    private func getCropCoefficient(cropType: CropType, stage: GrowthStage) -> Double {
        switch (cropType, stage) {
        case (_, .preseason), (_, .planted):
            return 0.3
        case (.corn, .emergence):
            return 0.5
        case (.corn, .vegetative):
            return 0.8
        case (.corn, .reproductive):
            return 1.2
        case (.corn, .maturity):
            return 0.7
        case (.soybeans, .vegetative):
            return 0.7
        case (.soybeans, .reproductive):
            return 1.1
        case (.wheat, .vegetative):
            return 0.6
        case (.wheat, .reproductive):
            return 1.0
        default:
            return 0.8
        }
    }

    // MARK: - Soil Moisture

    private func getOptimalSoilMoisture(cropType: CropType, growthStage: GrowthStage) -> Double {
        // Optimal soil moisture percentage by crop
        switch growthStage {
        case .reproductive:
            return 65.0  // Higher needs during reproduction
        case .vegetative:
            return 55.0
        default:
            return 50.0
        }
    }

    // MARK: - Risk Calculation

    private func getRiskLevel(from score: Double) -> DroughtRiskLevel {
        switch score {
        case 0..<10:
            return .none
        case 10..<30:
            return .minimal
        case 30..<50:
            return .moderate
        case 50..<70:
            return .high
        case 70..<85:
            return .severe
        default:
            return .extreme
        }
    }

    private func calculateDaysUntilCritical(
        soilMoisture: Double,
        etRate: Double,
        forecastedPrecipitation: [PrecipitationRecord],
        cropType: CropType
    ) -> Int? {

        let criticalMoisture = 25.0  // Below this, severe crop damage
        var currentMoisture = soilMoisture

        guard currentMoisture > criticalMoisture else {
            return 0  // Already critical
        }

        var days = 0
        let maxDays = 30

        while currentMoisture > criticalMoisture && days < maxDays {
            days += 1

            // Subtract ET loss
            currentMoisture -= etRate * 100 / 7  // Convert to percentage points

            // Add forecasted rain if available
            if let forecast = forecastedPrecipitation.first(where: { record in
                Calendar.current.dateComponents([.day], from: Date(), to: record.date).day == days
            }) {
                // Rainfall increases soil moisture
                let moistureGain = forecast.amount * 10  // Rough conversion
                currentMoisture += moistureGain
            }

            currentMoisture = max(0, min(100, currentMoisture))
        }

        return days < maxDays ? days : nil
    }

    private func projectYieldLoss(
        riskScore: Double,
        moistureDeficit: Double,
        growthStage: GrowthStage,
        daysInDrought: Int
    ) -> Double {

        var yieldLoss: Double = 0

        // Base loss from risk score
        yieldLoss = (riskScore / 100.0) * 40  // Up to 40% base loss

        // Critical stage multipliers
        if growthStage == .reproductive {
            yieldLoss *= 1.8  // Reproductive stage is most critical
        } else if growthStage == .vegetative {
            yieldLoss *= 1.3
        }

        // Duration factor
        if daysInDrought > 21 {
            yieldLoss += 15
        } else if daysInDrought > 14 {
            yieldLoss += 10
        } else if daysInDrought > 10 {
            yieldLoss += 5
        }

        return min(100, yieldLoss)
    }

    // MARK: - Mitigation Actions

    private func generateMitigationActions(
        field: Field,
        riskLevel: DroughtRiskLevel,
        daysUntilCritical: Int?,
        yieldLoss: Double,
        soilMoistureDeficit: Double
    ) -> [DroughtRiskAssessment.MitigationAction] {

        var actions: [DroughtRiskAssessment.MitigationAction] = []

        // Emergency irrigation
        if riskLevel == .extreme || riskLevel == .severe {
            let inchesNeeded = soilMoistureDeficit / 10.0
            let costPerAcreInch: Double = 15.0
            let cost = field.acreage * inchesNeeded * costPerAcreInch

            let yieldSavings = field.acreage * field.cropType.typicalYield * (yieldLoss / 100.0) * 6.50  // Price per bushel

            actions.append(DroughtRiskAssessment.MitigationAction(
                action: "Emergency irrigation - apply \(String(format: "%.1f", inchesNeeded)) inches",
                priority: .immediate,
                estimatedCost: cost,
                potentialYieldSavings: yieldSavings,
                timeframeDays: daysUntilCritical ?? 7
            ))
        }

        // Reduce evapotranspiration
        if riskLevel == .high || riskLevel == .severe {
            actions.append(DroughtRiskAssessment.MitigationAction(
                action: "Apply anti-transpirant foliar spray to reduce water loss",
                priority: .urgent,
                estimatedCost: field.acreage * 12.0,
                potentialYieldSavings: field.acreage * field.cropType.typicalYield * 0.05 * 6.50,
                timeframeDays: 5
            ))
        }

        // Soil moisture conservation
        if riskLevel == .moderate || riskLevel == .high {
            actions.append(DroughtRiskAssessment.MitigationAction(
                action: "Apply mulch or crop residue to reduce soil evaporation",
                priority: .soon,
                estimatedCost: field.acreage * 25.0,
                potentialYieldSavings: field.acreage * field.cropType.typicalYield * 0.08 * 6.50,
                timeframeDays: 10
            ))
        }

        // Monitoring
        if riskLevel == .minimal || riskLevel == .moderate {
            actions.append(DroughtRiskAssessment.MitigationAction(
                action: "Increase soil moisture monitoring frequency to daily",
                priority: .monitor,
                estimatedCost: 0,
                potentialYieldSavings: 0,
                timeframeDays: 30
            ))
        }

        return actions.sorted { $0.priority.rawValue < $1.priority.rawValue }
    }

    // MARK: - Confidence

    private func calculateConfidence(
        hasHistorical: Bool,
        hasForecast: Bool,
        dataQuality: Double
    ) -> Double {
        var confidence = 0.5

        if hasHistorical {
            confidence += 0.2
        }

        if hasForecast {
            confidence += 0.15
        }

        confidence += dataQuality * 0.15

        return min(1.0, confidence)
    }
}

// MARK: - Mock Data

extension PrecipitationRecord {
    static var mockHistorical: [PrecipitationRecord] {
        let calendar = Calendar.current
        var records: [PrecipitationRecord] = []

        for i in 0..<90 {
            let date = calendar.date(byAdding: .day, value: -i, to: Date())!
            let amount = Double.random(in: 0...2.5)

            records.append(PrecipitationRecord(
                date: date,
                amount: amount,
                daysInPeriod: 1
            ))
        }

        return records
    }

    static var mockForecast: [PrecipitationRecord] {
        let calendar = Calendar.current
        var records: [PrecipitationRecord] = []

        for i in 1...14 {
            let date = calendar.date(byAdding: .day, value: i, to: Date())!
            let amount = Double.random(in: 0...1.5)

            records.append(PrecipitationRecord(
                date: date,
                amount: amount,
                daysInPeriod: 1
            ))
        }

        return records
    }
}
