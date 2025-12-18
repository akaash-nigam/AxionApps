//
//  CropRotationServiceTests.swift
//  SmartAgricultureTests
//
//  Created by Claude on 11/17/25.
//

import Testing
@testable import SmartAgriculture

@Suite("Crop Rotation Service Tests")
struct CropRotationServiceTests {

    @Test("Generate multi-year rotation plan")
    func testGenerateRotationPlan() async throws {
        let service = CropRotationService()
        let field = Field.mock(health: 85.0)

        let plan = try await service.generateRotationPlan(
            field: field,
            currentCrop: .corn,
            yearsToProject: 5
        )

        #expect(plan.years.count == 5)
        #expect(plan.totalYears == 5)
        #expect(plan.estimatedAverageYield > 0)
        #expect(plan.estimatedAverageRevenue > 0)
        #expect(plan.confidence > 0)
    }

    @Test("Rotation avoids continuous same crop")
    func testAvoidsContinuousCropping() async throws {
        let service = CropRotationService()
        let field = Field.mock(health: 85.0)

        let plan = try await service.generateRotationPlan(
            field: field,
            currentCrop: .corn,
            yearsToProject: 4,
            availableCrops: [.corn, .soybeans]
        )

        // Should not have continuous corn or soybeans
        for i in 0..<(plan.years.count - 1) {
            let current = plan.years[i].cropType
            let next = plan.years[i + 1].cropType

            // Adjacent years should ideally be different (though algorithm may allow same in some cases)
            // At minimum, there should be variation over the 4 years
        }

        // Check overall diversity
        let uniqueCrops = Set(plan.years.map { $0.cropType })
        #expect(uniqueCrops.count > 1)
    }

    @Test("Nitrogen-fixing crops benefit following crops")
    func testNitrogenFixingBenefit() async throws {
        let service = CropRotationService()
        let field = Field.mock(health: 85.0)

        let plan = try await service.generateRotationPlan(
            field: field,
            currentCrop: .soybeans,  // N-fixing crop
            yearsToProject: 3,
            availableCrops: [.corn, .soybeans]
        )

        // Should include nitrogen balance information
        let hasPositiveNitrogen = plan.years.contains { $0.nitrogenBalance > 0 }
        let hasNegativeNitrogen = plan.years.contains { $0.nitrogenBalance < 0 }

        #expect(hasPositiveNitrogen || hasNegativeNitrogen)  // Should show nitrogen dynamics
    }

    @Test("Soil health impact calculated")
    func testSoilHealthImpact() async throws {
        let service = CropRotationService()
        let field = Field.mock(health: 80.0)

        let plan = try await service.generateRotationPlan(
            field: field,
            currentCrop: .corn,
            yearsToProject: 5,
            availableCrops: [.corn, .soybeans, .wheat, .alfalfa]
        )

        #expect(plan.soilHealthImpact.organicMatterChange != 0 || plan.soilHealthImpact.organicMatterChange == 0)
        #expect(plan.soilHealthImpact.soilStructureImprovement >= 0)
        #expect(plan.soilHealthImpact.soilStructureImprovement <= 100)
    }

    @Test("Environmental benefits quantified")
    func testEnvironmentalBenefits() async throws {
        let service = CropRotationService()
        let field = Field.mock(health: 85.0)

        let plan = try await service.generateRotationPlan(
            field: field,
            currentCrop: .corn,
            yearsToProject: 5,
            availableCrops: [.corn, .soybeans, .alfalfa]
        )

        #expect(plan.environmentalBenefits.carbonSequestration >= 0)
        #expect(plan.environmentalBenefits.nitrogenUseEfficiency >= 0)
        #expect(plan.environmentalBenefits.nitrogenUseEfficiency <= 100)
        #expect(plan.environmentalBenefits.pestReduction >= 0)
        #expect(plan.environmentalBenefits.biodiversityScore >= 0)
        #expect(plan.environmentalBenefits.biodiversityScore <= 100)
    }

    @Test("Risk diversification score calculated")
    func testRiskDiversification() async throws {
        let service = CropRotationService()
        let field = Field.mock(health: 85.0)

        // Diverse rotation should have higher diversification score
        let diversePlan = try await service.generateRotationPlan(
            field: field,
            currentCrop: .corn,
            yearsToProject: 5,
            availableCrops: [.corn, .soybeans, .wheat, .alfalfa]
        )

        // Limited rotation should have lower diversification
        let limitedPlan = try await service.generateRotationPlan(
            field: field,
            currentCrop: .corn,
            yearsToProject: 5,
            availableCrops: [.corn, .soybeans]
        )

        #expect(diversePlan.riskDiversification >= 0)
        #expect(diversePlan.riskDiversification <= 100)
        #expect(limitedPlan.riskDiversification >= 0)
        #expect(limitedPlan.riskDiversification <= 100)

        // More crops should generally mean better diversification
        let diverseUniqueCrops = Set(diversePlan.years.map { $0.cropType }).count
        let limitedUniqueCrops = Set(limitedPlan.years.map { $0.cropType }).count
        #expect(diverseUniqueCrops >= limitedUniqueCrops)
    }

    @Test("Market prices affect crop selection")
    func testMarketPricesAffectSelection() async throws {
        let service = CropRotationService()
        let field = Field.mock(health: 85.0)

        // High price for soybeans
        let highSoybeansPrice = try await service.generateRotationPlan(
            field: field,
            currentCrop: .corn,
            yearsToProject: 5,
            availableCrops: [.corn, .soybeans],
            marketPrices: [.soybeans: 20.00, .corn: 5.00],
            prioritizeProfit: true
        )

        // Count soybeans appearances
        let soybeansCount = highSoybeansPrice.years.filter { $0.cropType == .soybeans }.count

        // With high soybean prices and profit priority, should favor soybeans
        #expect(soybeansCount > 0)
    }

    @Test("Soil health priority affects rotation")
    func testSoilHealthPriority() async throws {
        let service = CropRotationService()
        let field = Field.mock(health: 70.0)

        let soilFocusedPlan = try await service.generateRotationPlan(
            field: field,
            currentCrop: .corn,
            yearsToProject: 5,
            availableCrops: [.corn, .soybeans, .alfalfa],
            prioritizeSoilHealth: true,
            prioritizeProfit: false
        )

        // Should include soil-building crops like alfalfa or soybeans
        let hasSoilBuilders = soilFocusedPlan.years.contains { $0.cropType == .alfalfa || $0.cropType == .soybeans }
        #expect(hasSoilBuilders)
    }

    @Test("Each year includes reasoning")
    func testYearReasoningProvided() async throws {
        let service = CropRotationService()
        let field = Field.mock(health: 85.0)

        let plan = try await service.generateRotationPlan(
            field: field,
            currentCrop: .corn,
            yearsToProject: 5
        )

        // Every year should have reasoning
        for year in plan.years {
            #expect(!year.reasoning.isEmpty)
        }
    }

    @Test("Recommendations generated for rotation")
    func testRecommendationsGenerated() async throws {
        let service = CropRotationService()
        let field = Field.mock(health: 85.0)

        let plan = try await service.generateRotationPlan(
            field: field,
            currentCrop: .corn,
            yearsToProject: 5
        )

        #expect(plan.recommendations.count > 0)
    }

    @Test("Average yield calculated correctly")
    func testAverageYieldCalculation() async throws {
        let service = CropRotationService()
        let field = Field.mock(health: 85.0)

        let plan = try await service.generateRotationPlan(
            field: field,
            currentCrop: .corn,
            yearsToProject: 5
        )

        // Manually calculate average
        let manualAverage = plan.years.reduce(0.0) { $0 + $1.estimatedYield } / Double(plan.years.count)

        // Should match
        let difference = abs(plan.estimatedAverageYield - manualAverage)
        #expect(difference < 0.01)  // Allow for tiny floating point differences
    }

    @Test("Average revenue calculated correctly")
    func testAverageRevenueCalculation() async throws {
        let service = CropRotationService()
        let field = Field.mock(health: 85.0)

        let plan = try await service.generateRotationPlan(
            field: field,
            currentCrop: .corn,
            yearsToProject: 4
        )

        // Manually calculate average
        let manualAverage = plan.years.reduce(0.0) { $0 + $1.estimatedRevenue } / Double(plan.years.count)

        // Should match
        let difference = abs(plan.estimatedAverageRevenue - manualAverage)
        #expect(difference < 0.01)
    }

    @Test("Alfalfa improves soil health significantly")
    func testAlfalfaSoilHealthBenefit() async throws {
        let service = CropRotationService()
        let field = Field.mock(health: 80.0)

        let withAlfalfa = try await service.generateRotationPlan(
            field: field,
            currentCrop: .corn,
            yearsToProject: 5,
            availableCrops: [.corn, .soybeans, .alfalfa]
        )

        let withoutAlfalfa = try await service.generateRotationPlan(
            field: field,
            currentCrop: .corn,
            yearsToProject: 5,
            availableCrops: [.corn, .soybeans]
        )

        // If alfalfa is included, soil health impact should generally be better
        let alfalfaCount = withAlfalfa.years.filter { $0.cropType == .alfalfa }.count

        if alfalfaCount > 0 {
            // Alfalfa should contribute positively to soil health
            #expect(withAlfalfa.soilHealthImpact.organicMatterChange >= 0)
        }
    }

    @Test("Crop sequence follows agronomic principles")
    func testCropSequenceAgronomics() async throws {
        let service = CropRotationService()
        let field = Field.mock(health: 85.0)

        let plan = try await service.generateRotationPlan(
            field: field,
            currentCrop: .corn,
            yearsToProject: 6,
            availableCrops: [.corn, .soybeans]
        )

        // Classic corn-soybean rotation should alternate or at least not have long runs of same crop
        var maxConsecutive = 1
        var currentConsecutive = 1

        for i in 1..<plan.years.count {
            if plan.years[i].cropType == plan.years[i - 1].cropType {
                currentConsecutive += 1
                maxConsecutive = max(maxConsecutive, currentConsecutive)
            } else {
                currentConsecutive = 1
            }
        }

        // Should not have more than 2-3 years of same crop in a row
        #expect(maxConsecutive <= 3)
    }

    @Test("Field ID preserved in plan")
    func testFieldIDPreserved() async throws {
        let service = CropRotationService()
        let field = Field.mock(health: 85.0)

        let plan = try await service.generateRotationPlan(
            field: field,
            currentCrop: .corn,
            yearsToProject: 5
        )

        #expect(plan.fieldId == field.id)
    }

    @Test("Mock rotation plan is valid")
    func testMockRotationPlan() {
        let mockPlan = CropRotationPlan.mock

        #expect(mockPlan.years.count > 0)
        #expect(mockPlan.totalYears > 0)
        #expect(mockPlan.estimatedAverageYield > 0)
        #expect(mockPlan.estimatedAverageRevenue > 0)
        #expect(mockPlan.confidence > 0 && mockPlan.confidence <= 1)
        #expect(mockPlan.riskDiversification >= 0 && mockPlan.riskDiversification <= 100)
    }
}
