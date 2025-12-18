import Foundation

/// Generates mock data for testing and development
enum MockDataGenerator {

    // MARK: - Carbon Footprint

    static func generateMockFootprint() -> CarbonFootprint {
        let sources = generateMockEmissionSources()
        let facilities = generateMockFacilities()

        let scope1 = sources.filter { $0.category == .manufacturing }.reduce(0) { $0 + $1.emissions }
        let scope2 = sources.filter { $0.category == .energy }.reduce(0) { $0 + $1.emissions }
        let scope3 = sources.filter { $0.category == .supplyChain }.reduce(0) { $0 + $1.emissions }

        let model = CarbonFootprintModel(
            organizationId: "ORG-001",
            scope1: scope1,
            scope2: scope2,
            scope3: scope3,
            reportingPeriodStart: Date().addingMonths(-3),
            reportingPeriodEnd: Date()
        )

        var footprint = CarbonFootprint(from: model)
        return CarbonFootprint(
            id: footprint.id,
            timestamp: footprint.timestamp,
            organizationId: footprint.organizationId,
            scope1Emissions: scope1,
            scope2Emissions: scope2,
            scope3Emissions: scope3,
            emissionSources: sources,
            facilities: facilities,
            reportingPeriod: DateInterval(
                start: model.reportingPeriodStart,
                end: model.reportingPeriodEnd
            ),
            verificationStatus: .verified
        )
    }

    static func generateMockEmissionSources() -> [EmissionSource] {
        [
            EmissionSource(
                from: EmissionSourceModel(
                    name: "Manufacturing Operations",
                    category: EmissionCategory.manufacturing.rawValue,
                    emissions: 12500,
                    percentage: 45.0,
                    latitude: 31.2304,
                    longitude: 121.4737,
                    reductionPotential: 2400
                )
            ),
            EmissionSource(
                from: EmissionSourceModel(
                    name: "Transportation & Logistics",
                    category: EmissionCategory.transportation.rawValue,
                    emissions: 7800,
                    percentage: 28.0,
                    reductionPotential: 1200
                )
            ),
            EmissionSource(
                from: EmissionSourceModel(
                    name: "Facilities & Buildings",
                    category: EmissionCategory.facilities.rawValue,
                    emissions: 5000,
                    percentage: 18.0,
                    reductionPotential: 800
                )
            ),
            EmissionSource(
                from: EmissionSourceModel(
                    name: "Energy Consumption",
                    category: EmissionCategory.energy.rawValue,
                    emissions: 2500,
                    percentage: 9.0,
                    reductionPotential: 1500
                )
            )
        ]
    }

    // MARK: - Facilities

    static func generateMockFacilities() -> [Facility] {
        [
            Facility(from: FacilityModel(
                name: "Shanghai Manufacturing",
                facilityType: FacilityType.manufacturing.rawValue,
                latitude: 31.2304,
                longitude: 121.4737,
                emissions: 12500,
                energyConsumption: 5000000,
                waterUsage: 2000000,
                wasteGeneration: 500000,
                renewableEnergyPercentage: 25
            )),
            Facility(from: FacilityModel(
                name: "Berlin Distribution Center",
                facilityType: FacilityType.warehouse.rawValue,
                latitude: 52.5200,
                longitude: 13.4050,
                emissions: 3200,
                energyConsumption: 1200000,
                waterUsage: 500000,
                wasteGeneration: 120000,
                renewableEnergyPercentage: 45
            )),
            Facility(from: FacilityModel(
                name: "San Francisco HQ",
                facilityType: FacilityType.office.rawValue,
                latitude: 37.7749,
                longitude: -122.4194,
                emissions: 1800,
                energyConsumption: 800000,
                waterUsage: 300000,
                wasteGeneration: 80000,
                renewableEnergyPercentage: 65
            )),
            Facility(from: FacilityModel(
                name: "Singapore Data Center",
                facilityType: FacilityType.dataCenter.rawValue,
                latitude: 1.3521,
                longitude: 103.8198,
                emissions: 4500,
                energyConsumption: 8000000,
                waterUsage: 1000000,
                wasteGeneration: 50000,
                renewableEnergyPercentage: 30
            )),
            Facility(from: FacilityModel(
                name: "Tokyo Research Lab",
                facilityType: FacilityType.research.rawValue,
                latitude: 35.6762,
                longitude: 139.6503,
                emissions: 2000,
                energyConsumption: 600000,
                waterUsage: 200000,
                wasteGeneration: 40000,
                renewableEnergyPercentage: 50
            ))
        ]
    }

    // MARK: - Goals

    static func generateMockGoals() -> [SustainabilityGoal] {
        [
            SustainabilityGoal(from: SustainabilityGoalModel(
                title: "Net Zero by 2030",
                description: "Achieve carbon neutrality across all operations",
                category: GoalCategory.carbonReduction.rawValue,
                baselineValue: 27800,
                currentValue: 20850,
                targetValue: 0,
                unit: Constants.Units.carbonUnit,
                startDate: Date().addingMonths(-12),
                targetDate: Date().addingMonths(60),
                status: GoalStatus.onTrack.rawValue
            )),
            SustainabilityGoal(from: SustainabilityGoalModel(
                title: "100% Renewable Energy",
                description: "Power all facilities with renewable energy",
                category: GoalCategory.renewableEnergy.rawValue,
                baselineValue: 20,
                currentValue: 45,
                targetValue: 100,
                unit: "%",
                startDate: Date().addingMonths(-18),
                targetDate: Date().addingMonths(30),
                status: GoalStatus.onTrack.rawValue
            )),
            SustainabilityGoal(from: SustainabilityGoalModel(
                title: "Zero Waste to Landfill",
                description: "Divert 90% of waste from landfills",
                category: GoalCategory.wasteReduction.rawValue,
                baselineValue: 40,
                currentValue: 100,
                targetValue: 90,
                unit: "%",
                startDate: Date().addingMonths(-24),
                targetDate: Date().addingMonths(12),
                status: GoalStatus.achieved.rawValue
            )),
            SustainabilityGoal(from: SustainabilityGoalModel(
                title: "Water Efficiency 40%",
                description: "Reduce water consumption by 40%",
                category: GoalCategory.waterConservation.rawValue,
                baselineValue: 4000000,
                currentValue: 3200000,
                targetValue: 2400000,
                unit: "L",
                startDate: Date().addingMonths(-6),
                targetDate: Date().addingMonths(18),
                status: GoalStatus.atRisk.rawValue
            )),
            SustainabilityGoal(from: SustainabilityGoalModel(
                title: "Circular Supply Chain",
                description: "Implement circular economy principles in 50% of products",
                category: GoalCategory.circularEconomy.rawValue,
                baselineValue: 5,
                currentValue: 22,
                targetValue: 50,
                unit: "%",
                startDate: Date().addingMonths(-9),
                targetDate: Date().addingMonths(27),
                status: GoalStatus.behind.rawValue
            ))
        ]
    }

    // MARK: - Supply Chain

    static func generateMockSupplyChain() -> SupplyChain {
        let model = SupplyChainModel(
            productId: "PROD-001",
            productName: "Sustainable Widget",
            totalEmissions: 850,
            totalDistance: 12000
        )

        return SupplyChain(from: model)
    }

    // MARK: - AI Recommendations

    static func generateMockRecommendations() -> [AIRecommendation] {
        [
            AIRecommendation(from: RecommendationData(
                id: UUID().uuidString,
                title: "Switch to Renewable Energy at Shanghai Facility",
                description: "Install solar panels to cover 60% of energy needs. Would reduce emissions by 2,400 tCO2e annually.",
                category: RecommendationCategory.renewableEnergy.rawValue,
                emissionReduction: 2400,
                costSavings: 180000,
                roi: 1.8,
                confidence: 0.92
            )),
            AIRecommendation(from: RecommendationData(
                id: UUID().uuidString,
                title: "Optimize Transportation Routes",
                description: "Use AI-powered route optimization to reduce fuel consumption by 15%.",
                category: RecommendationCategory.processOptimization.rawValue,
                emissionReduction: 1170,
                costSavings: 90000,
                roi: 2.4,
                confidence: 0.88
            )),
            AIRecommendation(from: RecommendationData(
                id: UUID().uuidString,
                title: "Implement Energy Management System",
                description: "Real-time energy monitoring and automated controls could reduce consumption by 20%.",
                category: RecommendationCategory.energyEfficiency.rawValue,
                emissionReduction: 1000,
                costSavings: 120000,
                roi: 3.2,
                confidence: 0.85
            ))
        ]
    }

    // MARK: - Historical Data

    static func generateHistoricalEmissions(months: Int) -> [DataPoint] {
        let baseEmission: Double = 30000
        return (0..<months).map { month in
            // Simulate gradual reduction with some variance
            let trend = Double(month) * -100 // Reducing over time
            let variance = Double.random(in: -500...500)
            let value = baseEmission + trend + variance

            return DataPoint(
                timestamp: Date().addingMonths(-months + month),
                value: max(value, 0)
            )
        }
    }

    // MARK: - Forecast Data

    static func generateForecast(months: Int) -> [ForecastPoint] {
        let currentEmission: Double = 27800
        let targetReduction: Double = 0.05 // 5% reduction per month

        return (0..<months).map { month in
            let projected = currentEmission * pow(1 - targetReduction, Double(month))
            let upperBound = projected * 1.1
            let lowerBound = projected * 0.9

            return ForecastPoint(from: ForecastData(
                date: Date().addingMonths(month).ISO8601Format(),
                emissions: projected,
                upperBound: upperBound,
                lowerBound: lowerBound
            ))
        }
    }

    // MARK: - Prediction Data

    static func generatePredictions(months: Int) -> [Prediction] {
        let baseValue: Double = 27800

        return (0..<months).map { month in
            let trend = Double(month) * -300
            let value = baseValue + trend
            let confidence = 0.95 - (Double(month) * 0.02) // Confidence decreases over time

            return Prediction(from: PredictionData(
                timestamp: Date().addingMonths(month).ISO8601Format(),
                value: max(value, 0),
                confidence: max(confidence, 0.5)
            ))
        }
    }
}
