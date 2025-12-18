//
//  CropRotationService.swift
//  SmartAgriculture
//
//  Created by Claude on 11/17/25.
//

import Foundation

/// Crop rotation plan for multiple years
struct CropRotationPlan: Codable, Hashable, Identifiable {
    let id: UUID
    var fieldId: UUID
    var years: [YearPlan]
    var totalYears: Int
    var estimatedAverageYield: Double    // Average across all years
    var estimatedAverageRevenue: Double  // Per acre per year
    var soilHealthImpact: SoilHealthImpact
    var environmentalBenefits: EnvironmentalBenefits
    var riskDiversification: Double      // 0-100 score
    var recommendations: [String]
    var confidence: Double               // 0-1

    struct YearPlan: Codable, Hashable, Identifiable {
        let id: UUID
        var year: Int
        var cropType: CropType
        var estimatedYield: Double
        var estimatedRevenue: Double
        var nitrogenBalance: Double      // Lbs/acre added or depleted
        var reasoning: String

        init(year: Int, cropType: CropType, estimatedYield: Double, estimatedRevenue: Double, nitrogenBalance: Double, reasoning: String) {
            self.id = UUID()
            self.year = year
            self.cropType = cropType
            self.estimatedYield = estimatedYield
            self.estimatedRevenue = estimatedRevenue
            self.nitrogenBalance = nitrogenBalance
            self.reasoning = reasoning
        }
    }

    struct SoilHealthImpact: Codable, Hashable {
        var organicMatterChange: Double  // Percentage points
        var erosionReduction: Double     // Percentage
        var soilStructureImprovement: Double  // 0-100 score
        var overallHealthChange: Double  // -100 to +100
    }

    struct EnvironmentalBenefits: Codable, Hashable {
        var carbonSequestration: Double  // Tons CO2e per acre per year
        var nitrogenUseEfficiency: Double  // Percentage
        var pestReduction: Double        // Percentage
        var biodiversityScore: Double    // 0-100
    }

    init(
        fieldId: UUID,
        years: [YearPlan],
        totalYears: Int,
        estimatedAverageYield: Double,
        estimatedAverageRevenue: Double,
        soilHealthImpact: SoilHealthImpact,
        environmentalBenefits: EnvironmentalBenefits,
        riskDiversification: Double,
        recommendations: [String],
        confidence: Double
    ) {
        self.id = UUID()
        self.fieldId = fieldId
        self.years = years
        self.totalYears = totalYears
        self.estimatedAverageYield = estimatedAverageYield
        self.estimatedAverageRevenue = estimatedAverageRevenue
        self.soilHealthImpact = soilHealthImpact
        self.environmentalBenefits = environmentalBenefits
        self.riskDiversification = riskDiversification
        self.recommendations = recommendations
        self.confidence = confidence
    }
}

/// Crop compatibility and rotation rules
struct CropCompatibility: Codable, Hashable {
    var cropType: CropType
    var benefitsAfter: [CropType]        // Crops that benefit from following this one
    var avoidsAfter: [CropType]          // Crops to avoid following this one
    var nitrogenContribution: Double     // Lbs/acre (can be negative for consumers)
    var pestPressureReduction: [CropType]  // Reduces pests for these crops
    var diseaseBreak: [CropType]         // Breaks disease cycles for these crops
}

/// Service for planning multi-year crop rotations
actor CropRotationService {

    // MARK: - Rotation Planning

    /// Generates an optimized multi-year crop rotation plan
    func generateRotationPlan(
        field: Field,
        currentCrop: CropType,
        yearsToProject: Int = 5,
        availableCrops: [CropType] = [.corn, .soybeans, .wheat, .alfalfa],
        marketPrices: [CropType: Double] = [:],
        prioritizeSoilHealth: Bool = false,
        prioritizeProfit: Bool = true
    ) async throws -> CropRotationPlan {

        var yearPlans: [CropRotationPlan.YearPlan] = []
        var previousCrop = currentCrop
        var cumulativeNitrogen: Double = 0

        // Generate year-by-year plan
        for year in 1...yearsToProject {
            let nextCrop = selectNextCrop(
                previousCrop: previousCrop,
                availableCrops: availableCrops,
                year: year,
                cumulativeNitrogen: cumulativeNitrogen,
                prioritizeSoilHealth: prioritizeSoilHealth,
                prioritizeProfit: prioritizeProfit
            )

            let compatibility = getCropCompatibility(cropType: nextCrop)

            // Calculate yield (adjusted for rotation benefits)
            let rotationBonus = calculateRotationBonus(
                currentCrop: nextCrop,
                previousCrop: previousCrop
            )
            let baseYield = nextCrop.typicalYield
            let estimatedYield = baseYield * (1.0 + rotationBonus)

            // Calculate revenue
            let price = marketPrices[nextCrop] ?? getDefaultPrice(cropType: nextCrop)
            let revenue = estimatedYield * price

            // Nitrogen balance
            let nitrogenBalance = compatibility.nitrogenContribution
            cumulativeNitrogen += nitrogenBalance

            // Generate reasoning
            let reasoning = generateYearReasoning(
                crop: nextCrop,
                previousCrop: previousCrop,
                rotationBonus: rotationBonus,
                nitrogenBalance: nitrogenBalance
            )

            yearPlans.append(CropRotationPlan.YearPlan(
                year: year,
                cropType: nextCrop,
                estimatedYield: estimatedYield,
                estimatedRevenue: revenue,
                nitrogenBalance: nitrogenBalance,
                reasoning: reasoning
            ))

            previousCrop = nextCrop
        }

        // Calculate aggregate metrics
        let averageYield = yearPlans.reduce(0.0) { $0 + $1.estimatedYield } / Double(yearsToProject)
        let averageRevenue = yearPlans.reduce(0.0) { $0 + $1.estimatedRevenue } / Double(yearsToProject)

        // Assess soil health impact
        let soilHealthImpact = assessSoilHealthImpact(yearPlans: yearPlans)

        // Calculate environmental benefits
        let environmentalBenefits = calculateEnvironmentalBenefits(yearPlans: yearPlans)

        // Calculate risk diversification
        let riskDiversification = calculateRiskDiversification(yearPlans: yearPlans)

        // Generate overall recommendations
        let recommendations = generateRotationRecommendations(
            yearPlans: yearPlans,
            soilHealthImpact: soilHealthImpact,
            riskDiversification: riskDiversification
        )

        let confidence = 0.75  // Base confidence for rotation planning

        return CropRotationPlan(
            fieldId: field.id,
            years: yearPlans,
            totalYears: yearsToProject,
            estimatedAverageYield: averageYield,
            estimatedAverageRevenue: averageRevenue,
            soilHealthImpact: soilHealthImpact,
            environmentalBenefits: environmentalBenefits,
            riskDiversification: riskDiversification,
            recommendations: recommendations,
            confidence: confidence
        )
    }

    // MARK: - Crop Selection

    private func selectNextCrop(
        previousCrop: CropType,
        availableCrops: [CropType],
        year: Int,
        cumulativeNitrogen: Double,
        prioritizeSoilHealth: Bool,
        prioritizeProfit: Bool
    ) -> CropType {

        let previousCompatibility = getCropCompatibility(cropType: previousCrop)

        var cropScores: [(CropType, Double)] = []

        for crop in availableCrops {
            var score: Double = 50  // Base score

            // Benefit from rotation
            if previousCompatibility.benefitsAfter.contains(crop) {
                score += 25
            }

            // Avoid if incompatible
            if previousCompatibility.avoidsAfter.contains(crop) {
                score -= 30
            }

            // Nitrogen management
            let cropCompatibility = getCropCompatibility(cropType: crop)
            if cumulativeNitrogen < -100 {
                // Soil is nitrogen depleted, favor nitrogen fixers
                if cropCompatibility.nitrogenContribution > 0 {
                    score += 20
                }
            } else if cumulativeNitrogen > 100 {
                // Soil has excess nitrogen, favor heavy consumers
                if cropCompatibility.nitrogenContribution < -50 {
                    score += 15
                }
            }

            // Profitability
            if prioritizeProfit {
                let profitFactor = getDefaultPrice(cropType: crop) * crop.typicalYield / 1000.0
                score += profitFactor * 5
            }

            // Soil health
            if prioritizeSoilHealth {
                if crop == .alfalfa || crop == .soybeans {
                    score += 15  // Legumes improve soil
                }
                if crop == .wheat || crop == .oats || crop == .barley {
                    score += 8  // Cover crops improve soil
                }
            }

            // Diversity bonus (avoid continuous same crop)
            if crop != previousCrop {
                score += 10
            }

            cropScores.append((crop, score))
        }

        // Select highest scoring crop
        let selected = cropScores.max(by: { $0.1 < $1.1 })?.0 ?? .corn

        return selected
    }

    // MARK: - Crop Compatibility

    private func getCropCompatibility(cropType: CropType) -> CropCompatibility {
        switch cropType {
        case .corn:
            return CropCompatibility(
                cropType: .corn,
                benefitsAfter: [.soybeans, .alfalfa],  // Benefits from N fixers
                avoidsAfter: [.corn],  // Avoid continuous corn
                nitrogenContribution: -150,  // Heavy N consumer
                pestPressureReduction: [],
                diseaseBreak: [.soybeans, .wheat]
            )

        case .soybeans:
            return CropCompatibility(
                cropType: .soybeans,
                benefitsAfter: [.corn, .wheat],  // Good for most crops
                avoidsAfter: [.soybeans],  // Avoid continuous soybeans
                nitrogenContribution: 40,  // N fixer
                pestPressureReduction: [.corn],
                diseaseBreak: [.corn, .wheat]
            )

        case .wheat:
            return CropCompatibility(
                cropType: .wheat,
                benefitsAfter: [.corn, .soybeans],
                avoidsAfter: [.wheat, .barley, .oats],  // Avoid continuous small grains
                nitrogenContribution: -80,  // Moderate N consumer
                pestPressureReduction: [.corn, .soybeans],
                diseaseBreak: [.corn, .soybeans]
            )

        case .alfalfa:
            return CropCompatibility(
                cropType: .alfalfa,
                benefitsAfter: [.corn, .wheat],  // Excellent for following crops
                avoidsAfter: [],
                nitrogenContribution: 100,  // Excellent N fixer
                pestPressureReduction: [.corn, .soybeans],
                diseaseBreak: [.corn, .soybeans, .wheat]
            )

        case .cotton:
            return CropCompatibility(
                cropType: .cotton,
                benefitsAfter: [.corn, .soybeans],
                avoidsAfter: [.cotton],
                nitrogenContribution: -120,
                pestPressureReduction: [],
                diseaseBreak: [.soybeans]
            )

        default:
            return CropCompatibility(
                cropType: cropType,
                benefitsAfter: [],
                avoidsAfter: [cropType],
                nitrogenContribution: -60,
                pestPressureReduction: [],
                diseaseBreak: []
            )
        }
    }

    // MARK: - Rotation Benefits

    private func calculateRotationBonus(
        currentCrop: CropType,
        previousCrop: CropType
    ) -> Double {

        let previousCompatibility = getCropCompatibility(cropType: previousCrop)

        var bonus: Double = 0

        // Direct rotation benefit
        if previousCompatibility.benefitsAfter.contains(currentCrop) {
            bonus += 0.12  // 12% yield increase
        }

        // Nitrogen benefit
        if previousCompatibility.nitrogenContribution > 0 {
            let currentCompatibility = getCropCompatibility(cropType: currentCrop)
            if currentCompatibility.nitrogenContribution < 0 {
                // N-consuming crop after N-fixing crop
                bonus += 0.08  // 8% yield increase
            }
        }

        // Disease break benefit
        if previousCompatibility.diseaseBreak.contains(currentCrop) {
            bonus += 0.05  // 5% yield increase from disease reduction
        }

        // Penalty for continuous cropping
        if currentCrop == previousCrop {
            bonus -= 0.15  // 15% yield penalty
        }

        return max(-0.20, min(0.25, bonus))  // Cap between -20% and +25%
    }

    // MARK: - Soil Health

    private func assessSoilHealthImpact(
        yearPlans: [CropRotationPlan.YearPlan]
    ) -> CropRotationPlan.SoilHealthImpact {

        var organicMatterChange: Double = 0
        var erosionReduction: Double = 0
        var structureImprovement: Double = 50  // Base score

        for plan in yearPlans {
            let compatibility = getCropCompatibility(cropType: plan.cropType)

            // Legumes and perennials add organic matter
            if plan.cropType == .alfalfa {
                organicMatterChange += 0.15  // 0.15% per year
                erosionReduction += 8
                structureImprovement += 5
            } else if plan.cropType == .soybeans {
                organicMatterChange += 0.05  // 0.05% per year
                erosionReduction += 3
                structureImprovement += 2
            } else if plan.cropType == .corn {
                organicMatterChange += 0.02  // Small increase from residue
                erosionReduction += 1
            }

            // Diverse rotations improve structure
            structureImprovement += 2
        }

        // Average across years
        organicMatterChange /= Double(yearPlans.count)
        erosionReduction /= Double(yearPlans.count)

        // Overall health change
        let overallHealthChange = (organicMatterChange * 20) + (erosionReduction * 0.5) + (structureImprovement - 50) * 0.8

        return CropRotationPlan.SoilHealthImpact(
            organicMatterChange: organicMatterChange,
            erosionReduction: erosionReduction,
            soilStructureImprovement: min(100, structureImprovement),
            overallHealthChange: max(-50, min(50, overallHealthChange))
        )
    }

    // MARK: - Environmental Benefits

    private func calculateEnvironmentalBenefits(
        yearPlans: [CropRotationPlan.YearPlan]
    ) -> CropRotationPlan.EnvironmentalBenefits {

        var carbonSequestration: Double = 0
        var totalNitrogenBalance: Double = 0
        var pestReduction: Double = 0
        var biodiversityScore: Double = 20  // Base score

        for plan in yearPlans {
            // Carbon sequestration (tons CO2e per acre per year)
            if plan.cropType == .alfalfa {
                carbonSequestration += 0.8
            } else if plan.cropType == .soybeans {
                carbonSequestration += 0.3
            } else {
                carbonSequestration += 0.1
            }

            // Nitrogen balance
            totalNitrogenBalance += plan.nitrogenBalance

            // Diversity increases biodiversity
            biodiversityScore += 8
        }

        // Average carbon sequestration
        carbonSequestration /= Double(yearPlans.count)

        // Nitrogen use efficiency (positive balance = less fertilizer needed)
        let nitrogenUseEfficiency = totalNitrogenBalance > 0 ? 85.0 : 70.0

        // Pest reduction from crop diversity
        let uniqueCrops = Set(yearPlans.map { $0.cropType }).count
        pestReduction = Double(uniqueCrops) * 8  // 8% per unique crop

        biodiversityScore = min(100, biodiversityScore)

        return CropRotationPlan.EnvironmentalBenefits(
            carbonSequestration: carbonSequestration,
            nitrogenUseEfficiency: nitrogenUseEfficiency,
            pestReduction: min(50, pestReduction),
            biodiversityScore: biodiversityScore
        )
    }

    // MARK: - Risk Diversification

    private func calculateRiskDiversification(
        yearPlans: [CropRotationPlan.YearPlan]
    ) -> Double {

        // Count unique crops
        let uniqueCrops = Set(yearPlans.map { $0.cropType }).count

        // Calculate revenue variance
        let revenues = yearPlans.map { $0.estimatedRevenue }
        let meanRevenue = revenues.reduce(0, +) / Double(revenues.count)
        let variance = revenues.reduce(0.0) { $0 + pow($1 - meanRevenue, 2) } / Double(revenues.count)
        let coefficientOfVariation = variance > 0 ? sqrt(variance) / meanRevenue : 0

        // More unique crops = better diversification
        var score: Double = Double(uniqueCrops) * 15  // 15 points per unique crop

        // Lower revenue variation = better stability
        score += max(0, 40 - (coefficientOfVariation * 100))

        return min(100, score)
    }

    // MARK: - Recommendations

    private func generateYearReasoning(
        crop: CropType,
        previousCrop: CropType,
        rotationBonus: Double,
        nitrogenBalance: Double
    ) -> String {

        var parts: [String] = []

        if rotationBonus > 0.10 {
            parts.append("excellent rotation from \(previousCrop.displayName)")
        } else if rotationBonus > 0.05 {
            parts.append("good rotation from \(previousCrop.displayName)")
        } else if rotationBonus < -0.10 {
            parts.append("continuous cropping penalty")
        }

        if nitrogenBalance > 50 {
            parts.append("adds nitrogen to soil")
        } else if nitrogenBalance < -100 {
            parts.append("high N requirement")
        }

        if parts.isEmpty {
            return "Maintains soil balance and diversifies rotation"
        }

        return parts.joined(separator: ", ").capitalized
    }

    private func generateRotationRecommendations(
        yearPlans: [CropRotationPlan.YearPlan],
        soilHealthImpact: CropRotationPlan.SoilHealthImpact,
        riskDiversification: Double
    ) -> [String] {

        var recommendations: [String] = []

        // Diversity recommendation
        let uniqueCrops = Set(yearPlans.map { $0.cropType }).count
        if uniqueCrops < 3 {
            recommendations.append("Consider adding more crop diversity to improve soil health and reduce risk")
        } else if uniqueCrops >= 4 {
            recommendations.append("✓ Excellent crop diversity reduces pest pressure and improves resilience")
        }

        // Nitrogen management
        let totalNitrogen = yearPlans.reduce(0.0) { $0 + $1.nitrogenBalance }
        if totalNitrogen < -200 {
            recommendations.append("Add nitrogen-fixing crop (soybeans, alfalfa) to reduce fertilizer costs")
        } else if totalNitrogen > 100 {
            recommendations.append("✓ Good nitrogen balance reduces synthetic fertilizer needs")
        }

        // Soil health
        if soilHealthImpact.organicMatterChange > 0.10 {
            recommendations.append("✓ Rotation improves organic matter by \(String(format: "%.2f", soilHealthImpact.organicMatterChange))% per year")
        } else if soilHealthImpact.organicMatterChange < 0 {
            recommendations.append("Consider adding cover crops or perennials to build organic matter")
        }

        // Risk diversification
        if riskDiversification > 75 {
            recommendations.append("✓ Well-diversified rotation reduces market and weather risks")
        } else if riskDiversification < 50 {
            recommendations.append("Increase crop diversity to reduce revenue volatility")
        }

        // Profitability
        let avgRevenue = yearPlans.reduce(0.0) { $0 + $1.estimatedRevenue } / Double(yearPlans.count)
        recommendations.append("Projected average revenue: $\(Int(avgRevenue))/acre/year")

        return recommendations
    }

    // MARK: - Market Prices

    private func getDefaultPrice(cropType: CropType) -> Double {
        // Default prices per bushel (or pound for cotton)
        switch cropType {
        case .corn: return 6.50
        case .soybeans: return 14.00
        case .wheat: return 7.50
        case .cotton: return 0.85
        case .rice: return 16.00
        case .barley: return 6.00
        case .oats: return 4.50
        case .alfalfa: return 250.00  // Per ton
        default: return 6.00
        }
    }
}

// MARK: - Mock Data

extension CropRotationPlan {
    static var mock: CropRotationPlan {
        let yearPlans = [
            YearPlan(year: 1, cropType: .corn, estimatedYield: 185, estimatedRevenue: 1202.50, nitrogenBalance: -150, reasoning: "Good rotation from soybeans, adds nitrogen to soil"),
            YearPlan(year: 2, cropType: .soybeans, estimatedYield: 58, estimatedRevenue: 812.00, nitrogenBalance: 40, reasoning: "Excellent rotation from corn, adds nitrogen to soil"),
            YearPlan(year: 3, cropType: .corn, estimatedYield: 192, estimatedRevenue: 1248.00, nitrogenBalance: -150, reasoning: "Excellent rotation from soybeans, adds nitrogen to soil"),
            YearPlan(year: 4, cropType: .wheat, estimatedYield: 68, estimatedRevenue: 510.00, nitrogenBalance: -80, reasoning: "Good rotation from corn, maintains soil balance"),
            YearPlan(year: 5, cropType: .soybeans, estimatedYield: 56, estimatedRevenue: 784.00, nitrogenBalance: 40, reasoning: "Good rotation from wheat, adds nitrogen to soil")
        ]

        return CropRotationPlan(
            fieldId: UUID(),
            years: yearPlans,
            totalYears: 5,
            estimatedAverageYield: 111.8,
            estimatedAverageRevenue: 911.30,
            soilHealthImpact: SoilHealthImpact(
                organicMatterChange: 0.08,
                erosionReduction: 4.2,
                soilStructureImprovement: 68,
                overallHealthChange: 12.5
            ),
            environmentalBenefits: EnvironmentalBenefits(
                carbonSequestration: 0.32,
                nitrogenUseEfficiency: 78,
                pestReduction: 24,
                biodiversityScore: 68
            ),
            riskDiversification: 72,
            recommendations: [
                "✓ Excellent crop diversity reduces pest pressure and improves resilience",
                "✓ Rotation improves organic matter by 0.08% per year",
                "✓ Well-diversified rotation reduces market and weather risks",
                "Projected average revenue: $911/acre/year"
            ],
            confidence: 0.75
        )
    }
}
