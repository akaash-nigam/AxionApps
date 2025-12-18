import Foundation
import Observation

/// Main game state container
/// Manages the current city data and game state
@Observable
final class GameState {
    // MARK: - Properties

    var cityData: CityData
    var lastUpdateTime: Date
    var gameTime: TimeInterval  // In-game time (seconds)

    // MARK: - Initialization

    init() {
        self.cityData = CityData()
        self.lastUpdateTime = Date()
        self.gameTime = 0
    }

    init(cityData: CityData) {
        self.cityData = cityData
        self.lastUpdateTime = Date()
        self.gameTime = 0
    }

    // MARK: - Public Methods

    /// Update game time
    func updateTime(deltaTime: TimeInterval, speedMultiplier: Float) {
        gameTime += deltaTime * TimeInterval(speedMultiplier)
        lastUpdateTime = Date()
    }

    /// Add a building to the city
    func addBuilding(_ building: Building) {
        cityData.buildings.append(building)
        cityData.lastModified = Date()
    }

    /// Remove a building from the city
    func removeBuilding(id: UUID) {
        cityData.buildings.removeAll { $0.id == id }
        cityData.lastModified = Date()
    }

    /// Add a road to the city
    func addRoad(_ road: Road) {
        cityData.roads.append(road)
        cityData.lastModified = Date()
    }

    /// Remove a road from the city
    func removeRoad(id: UUID) {
        cityData.roads.removeAll { $0.id == id }
        cityData.lastModified = Date()
    }

    /// Add a zone to the city
    func addZone(_ zone: Zone) {
        cityData.zones.append(zone)
        cityData.lastModified = Date()
    }

    /// Remove a zone from the city
    func removeZone(id: UUID) {
        cityData.zones.removeAll { $0.id == id }
        cityData.lastModified = Date()
    }

    /// Add a citizen to the city
    func addCitizen(_ citizen: Citizen) {
        cityData.citizens.append(citizen)
        updateStatistics()
    }

    /// Remove a citizen from the city
    func removeCitizen(id: UUID) {
        cityData.citizens.removeAll { $0.id == id }
        updateStatistics()
    }

    /// Add a vehicle to the city
    func addVehicle(_ vehicle: Vehicle) {
        cityData.vehicles.append(vehicle)
    }

    /// Remove a vehicle from the city
    func removeVehicle(id: UUID) {
        cityData.vehicles.removeAll { $0.id == id }
    }

    /// Update city statistics
    func updateStatistics() {
        cityData.statistics.population = cityData.citizens.count

        if !cityData.citizens.isEmpty {
            cityData.statistics.averageHappiness =
                cityData.citizens.reduce(0) { $0 + $1.happiness } / Float(cityData.citizens.count)
        } else {
            cityData.statistics.averageHappiness = 0
        }

        cityData.statistics.powerUsage = cityData.infrastructure.powerUsage
        cityData.statistics.waterUsage = cityData.infrastructure.waterUsage
    }

    /// Update economy
    func updateEconomy(income: Float, expenses: Float) {
        cityData.economy.income = income
        cityData.economy.expenses = expenses
        cityData.economy.treasury += (income - expenses)
    }

    /// Check if can afford cost
    func canAfford(_ cost: Float) -> Bool {
        return cityData.economy.treasury >= cost
    }

    /// Spend money
    func spend(_ amount: Float) -> Bool {
        guard canAfford(amount) else { return false }
        cityData.economy.treasury -= amount
        cityData.lastModified = Date()
        return true
    }

    /// Add money
    func addFunds(_ amount: Float) {
        cityData.economy.treasury += amount
        cityData.lastModified = Date()
    }
}
