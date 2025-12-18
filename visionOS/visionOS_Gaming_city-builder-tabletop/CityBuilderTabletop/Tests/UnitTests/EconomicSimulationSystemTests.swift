import Testing
import Foundation
@testable import CityBuilderTabletop

/// Unit tests for EconomicSimulationSystem
@Suite("EconomicSimulationSystem Tests")
struct EconomicSimulationSystemTests {

    @Test("Calculate income with no citizens or buildings")
    func testCalculateIncomeEmpty() {
        let system = EconomicSimulationSystem()
        let city = CityData()

        let income = system.calculateIncome(city)

        #expect(income == 0)
    }

    @Test("Calculate income with citizens")
    func testCalculateIncomeWithCitizens() {
        let system = EconomicSimulationSystem()
        var city = CityData()

        // Add 100 citizens
        for i in 0..<100 {
            city.citizens.append(Citizen(name: "Citizen \(i)", age: 30))
        }

        let income = system.calculateIncome(city)

        #expect(income > 0)
        // Should be: 100 citizens * 50 (tax per citizen) * 0.05 (tax rate) = 250
        #expect(income >= 240)
        #expect(income <= 260)
    }

    @Test("Calculate income with commercial buildings")
    func testCalculateIncomeWithCommercial() {
        let system = EconomicSimulationSystem()
        var city = CityData()

        // Add commercial building
        city.buildings.append(Building(
            type: .commercial(.smallShop),
            position: SIMD3(0, 0, 0)
        ))

        let income = system.calculateIncome(city)

        #expect(income > 0)
    }

    @Test("Calculate expenses with no buildings")
    func testCalculateExpensesEmpty() {
        let system = EconomicSimulationSystem()
        let city = CityData()

        let expenses = system.calculateExpenses(city)

        #expect(expenses == 0)
    }

    @Test("Calculate expenses with buildings")
    func testCalculateExpensesWithBuildings() {
        let system = EconomicSimulationSystem()
        var city = CityData()

        // Add 10 buildings
        for i in 0..<10 {
            city.buildings.append(Building(
                type: .residential(.smallHouse),
                position: SIMD3(Float(i) * 0.1, 0, 0)
            ))
        }

        let expenses = system.calculateExpenses(city)

        #expect(expenses > 0)
        // Should be: 10 buildings * 10 (upkeep) = 100
        #expect(expenses >= 90)
        #expect(expenses <= 110)
    }

    @Test("Calculate expenses with roads")
    func testCalculateExpensesWithRoads() {
        let system = EconomicSimulationSystem()
        var city = CityData()

        // Add road
        let road = Road(path: [
            SIMD3(0, 0, 0),
            SIMD3(1, 0, 0)
        ])
        city.roads.append(road)

        let expenses = system.calculateExpenses(city)

        #expect(expenses > 0)
    }

    @Test("Update employment with no jobs")
    func testUpdateEmploymentNoJobs() {
        let system = EconomicSimulationSystem()
        var city = CityData()

        // Add citizens but no jobs
        for i in 0..<50 {
            city.citizens.append(Citizen(name: "Citizen \(i)", age: 30))
        }

        let unemployment = system.updateEmployment(city)

        #expect(unemployment == 1.0)  // 100% unemployment
    }

    @Test("Update employment with full employment")
    func testUpdateEmploymentFull() {
        let system = EconomicSimulationSystem()
        var city = CityData()

        // Add citizens
        for i in 0..<10 {
            city.citizens.append(Citizen(name: "Citizen \(i)", age: 30))
        }

        // Add enough commercial buildings for jobs
        for i in 0..<20 {
            city.buildings.append(Building(
                type: .commercial(.office),
                position: SIMD3(Float(i) * 0.1, 0, 0),
                capacity: 50
            ))
        }

        let unemployment = system.updateEmployment(city)

        #expect(unemployment == 0.0)  // Full employment
    }

    @Test("Update employment with partial employment")
    func testUpdateEmploymentPartial() {
        let system = EconomicSimulationSystem()
        var city = CityData()

        // Add 100 citizens
        for i in 0..<100 {
            city.citizens.append(Citizen(name: "Citizen \(i)", age: 30))
        }

        // Add few commercial buildings (not enough jobs)
        for i in 0..<5 {
            city.buildings.append(Building(
                type: .commercial(.smallShop),
                position: SIMD3(Float(i) * 0.1, 0, 0),
                capacity: 20
            ))
        }

        let unemployment = system.updateEmployment(city)

        #expect(unemployment > 0.0)
        #expect(unemployment < 1.0)
    }

    @Test("Calculate GDP with no activity")
    func testCalculateGDPEmpty() {
        let system = EconomicSimulationSystem()
        let city = CityData()

        let gdp = system.calculateGDP(city)

        #expect(gdp == 0)
    }

    @Test("Calculate GDP with citizens and buildings")
    func testCalculateGDPWithActivity() {
        let system = EconomicSimulationSystem()
        var city = CityData()

        // Add citizens
        for i in 0..<100 {
            city.citizens.append(Citizen(name: "Citizen \(i)", age: 30))
        }

        // Add buildings
        city.buildings.append(Building(
            type: .commercial(.office),
            position: SIMD3(0, 0, 0)
        ))
        city.buildings.append(Building(
            type: .industrial(.smallFactory),
            position: SIMD3(0.1, 0, 0)
        ))

        let gdp = system.calculateGDP(city)

        #expect(gdp > 0)
    }

    @Test("Process monthly economy updates treasury")
    func testProcessMonthlyEconomy() {
        let system = EconomicSimulationSystem()
        var city = CityData()

        let initialTreasury = city.economy.treasury

        // Add citizens for income
        for i in 0..<50 {
            city.citizens.append(Citizen(name: "Citizen \(i)", age: 30))
        }

        // Add a building for some expenses
        city.buildings.append(Building(
            type: .residential(.apartment),
            position: SIMD3(0, 0, 0)
        ))

        let netIncome = system.processMonthlyEconomy(&city)

        #expect(city.economy.income > 0)
        #expect(city.economy.expenses >= 0)
        #expect(city.economy.treasury != initialTreasury)
        #expect(netIncome == city.economy.income - city.economy.expenses)
    }

    @Test("Update economy over time")
    func testUpdateEconomy() {
        let system = EconomicSimulationSystem()
        var city = CityData()

        // Add citizens for income
        for i in 0..<50 {
            city.citizens.append(Citizen(name: "Citizen \(i)", age: 30))
        }

        let initialTreasury = city.economy.treasury

        // Simulate 1 second at normal speed
        system.updateEconomy(&city, deltaTime: 1.0, speedMultiplier: 1.0)

        #expect(city.economy.income > 0)
        #expect(city.economy.treasury != initialTreasury)
    }

    @Test("Update economy respects speed multiplier")
    func testUpdateEconomySpeedMultiplier() {
        let system = EconomicSimulationSystem()
        var city1 = CityData()
        var city2 = CityData()

        // Add same citizens to both cities
        for i in 0..<50 {
            let citizen = Citizen(name: "Citizen \(i)", age: 30)
            city1.citizens.append(citizen)
            city2.citizens.append(citizen)
        }

        let initialTreasury = city1.economy.treasury

        // Update with different speeds
        system.updateEconomy(&city1, deltaTime: 1.0, speedMultiplier: 1.0)
        system.updateEconomy(&city2, deltaTime: 1.0, speedMultiplier: 2.0)

        // City2 should have changed more due to higher speed
        let change1 = abs(city1.economy.treasury - initialTreasury)
        let change2 = abs(city2.economy.treasury - initialTreasury)

        #expect(change2 > change1)
    }

    @Test("Assign jobs to unemployed citizens")
    func testAssignJobs() {
        let system = EconomicSimulationSystem()
        var city = CityData()

        // Add unemployed citizens
        for i in 0..<10 {
            city.citizens.append(Citizen(name: "Citizen \(i)", age: 30, occupation: .unemployed))
        }

        // Add commercial buildings with jobs
        for i in 0..<5 {
            city.buildings.append(Building(
                type: .commercial(.office),
                position: SIMD3(Float(i) * 0.1, 0, 0),
                capacity: 100
            ))
        }

        let jobsAssigned = system.assignJobs(&city)

        #expect(jobsAssigned > 0)
        #expect(jobsAssigned <= 10)

        // Check that citizens have jobs assigned
        let employedCitizens = city.citizens.filter { $0.occupation != .unemployed }
        #expect(employedCitizens.count == jobsAssigned)
    }

    @Test("Assign jobs sets workplace for citizens")
    func testAssignJobsSetWorkplace() {
        let system = EconomicSimulationSystem()
        var city = CityData()

        // Add citizen
        city.citizens.append(Citizen(name: "Worker", age: 30, occupation: .unemployed))

        // Add commercial building
        let building = Building(
            type: .commercial(.office),
            position: SIMD3(0, 0, 0),
            capacity: 100
        )
        city.buildings.append(building)

        system.assignJobs(&city)

        // Citizen should have workplace assigned
        #expect(city.citizens[0].workplace == building.id)
        #expect(city.citizens[0].income > 0)
    }

    @Test("Economic system handles negative budget")
    func testNegativeBudget() {
        let system = EconomicSimulationSystem()
        var city = CityData()

        // Set low treasury
        city.economy.treasury = 100

        // Add many buildings for high expenses
        for i in 0..<50 {
            city.buildings.append(Building(
                type: .infrastructure(.hospital),
                position: SIMD3(Float(i) * 0.1, 0, 0)
            ))
        }

        system.processMonthlyEconomy(&city)

        // Treasury can go negative
        #expect(city.economy.treasury < 100)
    }

    @Test("GDP decreases with unemployment")
    func testGDPWithUnemployment() {
        let system = EconomicSimulationSystem()
        var city = CityData()

        // Add citizens
        for i in 0..<100 {
            city.citizens.append(Citizen(name: "Citizen \(i)", age: 30))
        }

        // Add buildings
        city.buildings.append(Building(type: .commercial(.office), position: SIMD3(0, 0, 0)))

        // Calculate GDP with low unemployment
        city.economy.unemployment = 0.1
        let gdpLowUnemployment = system.calculateGDP(city)

        // Calculate GDP with high unemployment
        city.economy.unemployment = 0.9
        let gdpHighUnemployment = system.calculateGDP(city)

        #expect(gdpLowUnemployment > gdpHighUnemployment)
    }
}
