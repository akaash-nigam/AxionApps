import Foundation

/// Manages economic simulation for the city
final class EconomicSimulationSystem {
    // MARK: - Properties

    /// Monthly upkeep cost per building type (multiplier)
    private let buildingUpkeepCost: Float = 10.0

    /// Tax revenue per citizen
    private let citizenTaxRevenue: Float = 50.0

    /// Business tax per commercial building
    private let commercialTaxRevenue: Float = 100.0

    /// Industrial tax per industrial building
    private let industrialTaxRevenue: Float = 200.0

    /// Road maintenance cost per meter
    private let roadMaintenanceCost: Float = 5.0

    // MARK: - Public Methods

    /// Calculate total monthly income for the city
    /// - Parameter city: The current city data
    /// - Returns: Total income
    func calculateIncome(_ city: CityData) -> Float {
        var totalIncome: Float = 0

        // Residential tax (from citizens)
        let residentialTax = Float(city.citizens.count) * citizenTaxRevenue * city.economy.taxRate
        totalIncome += residentialTax

        // Commercial tax
        let commercialBuildings = city.buildings.filter { $0.type.isCommercial }
        let commercialTax = Float(commercialBuildings.count) * commercialTaxRevenue * city.economy.taxRate
        totalIncome += commercialTax

        // Industrial tax
        let industrialBuildings = city.buildings.filter { $0.type.isIndustrial }
        let industrialTax = Float(industrialBuildings.count) * industrialTaxRevenue * city.economy.taxRate
        totalIncome += industrialTax

        return totalIncome
    }

    /// Calculate total monthly expenses for the city
    /// - Parameter city: The current city data
    /// - Returns: Total expenses
    func calculateExpenses(_ city: CityData) -> Float {
        var totalExpenses: Float = 0

        // Building maintenance
        let buildingMaintenance = Float(city.buildings.count) * buildingUpkeepCost
        totalExpenses += buildingMaintenance

        // Road maintenance
        let roadMaintenance = city.roadLength * roadMaintenanceCost
        totalExpenses += roadMaintenance

        // Infrastructure costs
        totalExpenses += city.infrastructure.powerCost
        totalExpenses += city.infrastructure.waterCost

        // Service buildings operational cost
        let serviceBuildings = city.buildings.filter { $0.type.isInfrastructure }
        let serviceCost = Float(serviceBuildings.count) * 50.0
        totalExpenses += serviceCost

        return totalExpenses
    }

    /// Update employment based on available jobs
    /// - Parameter city: The current city data
    /// - Returns: Updated unemployment rate
    func updateEmployment(_ city: CityData) -> Float {
        let availableJobs = countAvailableJobs(city)
        let workingAgeCitizens = city.citizens.filter { $0.age >= 18 && $0.age <= 65 }.count

        guard workingAgeCitizens > 0 else { return 0 }

        if availableJobs >= workingAgeCitizens {
            return 0  // Full employment
        }

        let unemployed = workingAgeCitizens - availableJobs
        return Float(unemployed) / Float(workingAgeCitizens)
    }

    /// Calculate GDP based on economic activity
    /// - Parameter city: The current city data
    /// - Returns: Estimated GDP
    func calculateGDP(_ city: CityData) -> Float {
        var gdp: Float = 0

        // Residential contribution
        let residentialContribution = Float(city.citizens.count) * 1000.0

        // Commercial contribution
        let commercialBuildings = city.buildings.filter { $0.type.isCommercial }
        let commercialContribution = Float(commercialBuildings.count) * 5000.0

        // Industrial contribution
        let industrialBuildings = city.buildings.filter { $0.type.isIndustrial }
        let industrialContribution = Float(industrialBuildings.count) * 10000.0

        gdp = residentialContribution + commercialContribution + industrialContribution

        // Adjust for unemployment
        let employmentFactor = 1.0 - city.economy.unemployment
        gdp *= employmentFactor

        return gdp
    }

    /// Process monthly economic cycle
    /// - Parameter city: The current city data (mutable)
    /// - Returns: Net income for the month
    @discardableResult
    func processMonthlyEconomy(_ city: inout CityData) -> Float {
        // Calculate income and expenses
        let income = calculateIncome(city)
        let expenses = calculateExpenses(city)

        // Update economy state
        city.economy.income = income
        city.economy.expenses = expenses

        // Update treasury
        let netIncome = income - expenses
        city.economy.treasury += netIncome

        // Update unemployment
        city.economy.unemployment = updateEmployment(city)

        // Update GDP
        city.economy.gdp = calculateGDP(city)

        return netIncome
    }

    /// Simulate economic growth for a time period
    /// - Parameters:
    ///   - city: The current city data (mutable)
    ///   - deltaTime: Time elapsed in seconds
    ///   - speedMultiplier: Simulation speed multiplier
    func updateEconomy(_ city: inout CityData, deltaTime: Float, speedMultiplier: Float = 1.0) {
        // For simplicity, process monthly updates at certain intervals
        // In a real implementation, this would be more sophisticated

        // Process economic updates every simulated month (30 in-game days)
        // This is a simplified version for the game
        let monthlyInterval: Float = 30.0  // seconds in-game time
        let adjustedDelta = deltaTime * speedMultiplier

        // For this basic implementation, just update values
        if adjustedDelta > 0 {
            let income = calculateIncome(city)
            let expenses = calculateExpenses(city)

            city.economy.income = income
            city.economy.expenses = expenses

            // Gradual treasury update
            let netIncomePerSecond = (income - expenses) / monthlyInterval
            city.economy.treasury += netIncomePerSecond * adjustedDelta

            // Update unemployment
            city.economy.unemployment = updateEmployment(city)

            // Update GDP
            city.economy.gdp = calculateGDP(city)
        }
    }

    /// Assign jobs to unemployed citizens
    /// - Parameter city: The current city data (mutable)
    /// - Returns: Number of citizens assigned jobs
    @discardableResult
    func assignJobs(_ city: inout CityData) -> Int {
        var jobsAssigned = 0

        // Find unemployed citizens
        let unemployedCitizens = city.citizens.filter { $0.occupation == .unemployed && $0.age >= 18 && $0.age <= 65 }

        // Find buildings with available jobs
        let commercialBuildings = city.buildings.filter { $0.type.isCommercial }
        let industrialBuildings = city.buildings.filter { $0.type.isIndustrial }
        let serviceBuildings = city.buildings.filter { $0.type.isInfrastructure }

        var availableJobs: [(building: Building, occupation: Occupation)] = []

        for building in commercialBuildings {
            availableJobs.append((building, .retail))
        }

        for building in industrialBuildings {
            availableJobs.append((building, .industrial))
        }

        for building in serviceBuildings {
            if case .infrastructure(let type) = building.type {
                switch type {
                case .school:
                    availableJobs.append((building, .education))
                case .hospital:
                    availableJobs.append((building, .healthcare))
                default:
                    availableJobs.append((building, .service))
                }
            }
        }

        // Assign jobs to citizens
        for (index, _) in unemployedCitizens.enumerated() {
            guard index < availableJobs.count else { break }

            if let citizenIndex = city.citizens.firstIndex(where: { $0.id == unemployedCitizens[index].id }) {
                city.citizens[citizenIndex].occupation = availableJobs[index].occupation
                city.citizens[citizenIndex].workplace = availableJobs[index].building.id
                city.citizens[citizenIndex].income = incomeForOccupation(availableJobs[index].occupation)
                jobsAssigned += 1
            }
        }

        return jobsAssigned
    }

    // MARK: - Private Methods

    /// Count available jobs in the city
    private func countAvailableJobs(_ city: CityData) -> Int {
        var jobs = 0

        // Commercial buildings provide jobs
        let commercialBuildings = city.buildings.filter { $0.type.isCommercial }
        for building in commercialBuildings {
            jobs += building.capacity / 4  // Rough estimate: 1 job per 4 capacity
        }

        // Industrial buildings provide jobs
        let industrialBuildings = city.buildings.filter { $0.type.isIndustrial }
        for building in industrialBuildings {
            jobs += building.capacity / 2  // More jobs per building
        }

        // Service buildings provide jobs
        let serviceBuildings = city.buildings.filter { $0.type.isInfrastructure }
        jobs += serviceBuildings.count * 10  // Fixed jobs per service building

        return jobs
    }

    /// Get income for a specific occupation
    private func incomeForOccupation(_ occupation: Occupation) -> Float {
        switch occupation {
        case .unemployed: return 0
        case .retail: return 1500
        case .office: return 2500
        case .industrial: return 2000
        case .service: return 1800
        case .education: return 2200
        case .healthcare: return 3000
        }
    }
}
