import XCTest
@testable import SustainabilityCommand

final class BusinessLogicTests: XCTestCase {

    // MARK: - Carbon Calculation Tests

    func testTotalEmissionsCalculation() {
        let footprint = MockDataGenerator.generateMockFootprint()

        let expectedTotal = footprint.scope1Emissions +
                          footprint.scope2Emissions +
                          footprint.scope3Emissions

        XCTAssertEqual(footprint.totalEmissions, expectedTotal, accuracy: 0.1)
    }

    func testScopeBreakdown() {
        let footprint = MockDataGenerator.generateMockFootprint()
        let breakdown = footprint.scopeBreakdown

        XCTAssertEqual(breakdown.count, 3)
        XCTAssertTrue(breakdown.contains { $0.scope == .scope1 })
        XCTAssertTrue(breakdown.contains { $0.scope == .scope2 })
        XCTAssertTrue(breakdown.contains { $0.scope == .scope3 })

        let totalFromBreakdown = breakdown.map { $0.emissions }.reduce(0, +)
        XCTAssertEqual(totalFromBreakdown, footprint.totalEmissions, accuracy: 0.1)
    }

    func testEmissionSourcePercentages() {
        let sources = MockDataGenerator.generateMockEmissionSources()
        let totalPercentage = sources.map { $0.percentage }.reduce(0, +)

        XCTAssertEqual(totalPercentage, 100.0, accuracy: 0.1)
    }

    // MARK: - Facility Tests

    func testFacilityEfficiencyRating() {
        let lowEmissionFacility = Facility(from: FacilityModel(
            name: "Test Facility",
            facilityType: "office",
            latitude: 0,
            longitude: 0,
            emissions: 300
        ))
        XCTAssertEqual(lowEmissionFacility.efficiencyRating, .excellent)

        let mediumEmissionFacility = Facility(from: FacilityModel(
            name: "Test Facility",
            facilityType: "office",
            latitude: 0,
            longitude: 0,
            emissions: 1500
        ))
        XCTAssertEqual(mediumEmissionFacility.efficiencyRating, .good)

        let highEmissionFacility = Facility(from: FacilityModel(
            name: "Test Facility",
            facilityType: "office",
            latitude: 0,
            longitude: 0,
            emissions: 6000
        ))
        XCTAssertEqual(highEmissionFacility.efficiencyRating, .poor)
    }

    func testEnergyMetricsCalculation() {
        let metrics = EnergyMetrics(
            consumption: 1000, // kWh
            renewablePercentage: 40 // 40%
        )

        XCTAssertEqual(metrics.renewableEnergy, 400, accuracy: 0.1)
        XCTAssertEqual(metrics.fossilFuelEnergy, 600, accuracy: 0.1)
    }

    func testWaterMetricsCalculation() {
        let metrics = WaterMetrics(usage: 1000)
        var metricsWithRecycling = metrics
        metricsWithRecycling.recycledPercentage = 30

        XCTAssertEqual(metricsWithRecycling.recycledWater, 300, accuracy: 0.1)
    }

    // MARK: - Goal Tests

    func testGoalProgressCalculation() {
        let goal = SustainabilityGoal(from: SustainabilityGoalModel(
            title: "Test Goal",
            description: "Test",
            category: "carbonReduction",
            baselineValue: 1000,
            currentValue: 750,
            targetValue: 500,
            unit: "tCO2e",
            startDate: Date().addingMonths(-6),
            targetDate: Date().addingMonths(6)
        ))

        // Progress = (baseline - current) / (baseline - target)
        // Progress = (1000 - 750) / (1000 - 500) = 250 / 500 = 0.5 = 50%
        XCTAssertEqual(goal.progress, 0.5, accuracy: 0.01)
        XCTAssertEqual(goal.progressPercentage, 50)
    }

    func testGoalDaysRemaining() {
        let futureDate = Date().addingDays(30)
        let goal = SustainabilityGoal(from: SustainabilityGoalModel(
            title: "Test Goal",
            description: "Test",
            category: "carbonReduction",
            baselineValue: 1000,
            currentValue: 750,
            targetValue: 500,
            unit: "tCO2e",
            startDate: Date(),
            targetDate: futureDate
        ))

        XCTAssertEqual(goal.daysRemaining, 30, accuracy: 1)
    }

    func testGoalIsOverdue() {
        let pastDate = Date().addingDays(-10)
        let goal = SustainabilityGoal(from: SustainabilityGoalModel(
            title: "Test Goal",
            description: "Test",
            category: "carbonReduction",
            baselineValue: 1000,
            currentValue: 750,
            targetValue: 500,
            unit: "tCO2e",
            startDate: Date().addingMonths(-6),
            targetDate: pastDate
        ))

        XCTAssertTrue(goal.isOverdue)
    }

    // MARK: - Validation Tests

    func testEmissionValueValidation() {
        let minValid = Constants.Validation.minEmissionValue
        let maxValid = Constants.Validation.maxEmissionValue

        XCTAssertGreaterThanOrEqual(minValid, 0)
        XCTAssertLessThanOrEqual(maxValid, 10_000_000)
    }

    func testGoalProgressValidation() {
        let minProgress = Constants.Validation.minGoalProgress
        let maxProgress = Constants.Validation.maxGoalProgress

        XCTAssertEqual(minProgress, 0.0)
        XCTAssertEqual(maxProgress, 1.0)
    }

    // MARK: - Threshold Tests

    func testEmissionThresholds() {
        let low = Constants.Thresholds.lowEmissions
        let medium = Constants.Thresholds.mediumEmissions
        let high = Constants.Thresholds.highEmissions

        XCTAssertLessThan(low, medium)
        XCTAssertLessThan(medium, high)
    }

    func testGoalStatusThresholds() {
        let onTrack = Constants.Thresholds.onTrackThreshold
        let atRisk = Constants.Thresholds.atRiskThreshold

        XCTAssertGreaterThan(onTrack, atRisk)
        XCTAssertGreaterThan(atRisk, 0)
        XCTAssertLessThan(onTrack, 1.0)
    }

    // MARK: - Emission Factor Tests

    func testEnergyEmissionFactors() {
        let grid = Constants.EmissionFactors.gridElectricity
        let solar = Constants.EmissionFactors.solarPower
        let wind = Constants.EmissionFactors.windPower

        // Solar and wind should have lower factors than grid
        XCTAssertLessThan(solar, grid)
        XCTAssertLessThan(wind, grid)
    }

    func testTransportEmissionFactors() {
        let sea = Constants.EmissionFactors.seaFreight
        let air = Constants.EmissionFactors.airFreight
        let rail = Constants.EmissionFactors.rail
        let truck = Constants.EmissionFactors.truck

        // Air should be highest
        XCTAssertGreaterThan(air, sea)
        XCTAssertGreaterThan(air, rail)
        XCTAssertGreaterThan(air, truck)

        // Sea should be lowest
        XCTAssertLessThan(sea, rail)
        XCTAssertLessThan(sea, truck)
    }

    // MARK: - Supply Chain Tests

    func testSupplyChainEmissionsPerKm() {
        let supplyChain = SupplyChain(from: SupplyChainModel(
            productId: "TEST-001",
            productName: "Test Product",
            totalEmissions: 1000,
            totalDistance: 10000
        ))

        XCTAssertEqual(supplyChain.emissionsPerKm, 0.1, accuracy: 0.001)
    }

    func testSupplyChainWithZeroDistance() {
        let supplyChain = SupplyChain(from: SupplyChainModel(
            productId: "TEST-001",
            productName: "Test Product",
            totalEmissions: 1000,
            totalDistance: 0
        ))

        XCTAssertEqual(supplyChain.emissionsPerKm, 0.0)
    }

    // MARK: - Date Calculations Tests

    func testReportingPeriods() {
        let now = Date()
        let quarterStart = now.addingMonths(-3).startOfDay
        let quarterEnd = now.endOfDay

        let period = DateInterval(start: quarterStart, end: quarterEnd)

        XCTAssertTrue(period.duration > 0)
        XCTAssertTrue(period.contains(now))
    }

    // MARK: - Performance Tests

    func testEmissionCalculationPerformance() {
        let facilities = MockDataGenerator.generateMockFacilities()

        measure {
            for _ in 0..<1000 {
                let _ = facilities.reduce(0) { $0 + $1.emissions }
            }
        }
    }

    func testGoalProgressCalculationPerformance() {
        let goals = MockDataGenerator.generateMockGoals()

        measure {
            for _ in 0..<1000 {
                let _ = goals.map { $0.progress }.reduce(0, +) / Double(goals.count)
            }
        }
    }
}
