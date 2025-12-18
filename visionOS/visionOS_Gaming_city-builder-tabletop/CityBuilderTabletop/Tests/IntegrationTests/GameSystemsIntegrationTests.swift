import Testing
import Foundation
@testable import CityBuilderTabletop

/// Integration tests for complete game systems working together
@Suite("Game Systems Integration Tests")
struct GameSystemsIntegrationTests {

    @Test("Complete city simulation cycle")
    func testCompleteCitySimulation() {
        var city = CityData(name: "Integration Test City")
        let buildingSystem = BuildingPlacementSystem()
        let roadSystem = RoadConstructionSystem()
        let economicSystem = EconomicSimulationSystem()
        let citizenSystem = CitizenAISystem()
        let trafficSystem = TrafficSimulationSystem()

        // Build infrastructure
        // 1. Place residential buildings
        for i in 0..<5 {
            if let building = buildingSystem.createBuilding(
                type: .residential(.apartment),
                at: SIMD3(Float(i) * 0.15, 0, 0),
                cityData: city
            ) {
                var constructedBuilding = building
                constructedBuilding.constructionProgress = 1.0
                constructedBuilding.isConstructed = true
                city.buildings.append(constructedBuilding)
            }
        }

        // 2. Place commercial buildings
        for i in 0..<3 {
            if let building = buildingSystem.createBuilding(
                type: .commercial(.office),
                at: SIMD3(Float(i) * 0.15, 0, 0.2),
                cityData: city
            ) {
                var constructedBuilding = building
                constructedBuilding.constructionProgress = 1.0
                constructedBuilding.isConstructed = true
                city.buildings.append(constructedBuilding)
            }
        }

        // 3. Build connecting roads
        let roadPoints1 = [SIMD3<Float>(0, 0, 0.1), SIMD3<Float>(0.6, 0, 0.1)]
        if let road = roadSystem.createRoad(from: roadPoints1) {
            city.roads.append(road)
        }

        #expect(city.buildings.count > 0)
        #expect(city.roads.count > 0)

        // Spawn citizens
        let citizensSpawned = citizenSystem.spawnCitizens(count: 50, city: &city)
        #expect(citizensSpawned > 0)
        #expect(city.citizens.count == citizensSpawned)

        // Assign jobs
        let jobsAssigned = economicSystem.assignJobs(&city)
        #expect(jobsAssigned > 0)

        // Spawn vehicles
        let vehiclesSpawned = trafficSystem.spawnVehicles(count: 20, city: &city)
        #expect(vehiclesSpawned > 0)

        // Run economic cycle
        economicSystem.processMonthlyEconomy(&city)
        #expect(city.economy.income > 0)

        // Update simulations
        citizenSystem.updateCitizens(&city, deltaTime: 1.0, gameTime: 28800)  // 8 AM
        trafficSystem.updateTraffic(&city, deltaTime: 1.0)

        // Verify city is functioning
        #expect(city.population > 0)
        #expect(city.economy.treasury != 50000)  // Changed from initial
        #expect(city.economy.unemployment < 1.0)  // Some employment
    }

    @Test("Building placement affects economy")
    func testBuildingPlacementAffectsEconomy() {
        var city = CityData()
        let buildingSystem = BuildingPlacementSystem()
        let economicSystem = EconomicSimulationSystem()

        // Initial economy
        let initialIncome = economicSystem.calculateIncome(city)
        let initialExpenses = economicSystem.calculateExpenses(city)

        #expect(initialIncome == 0)
        #expect(initialExpenses == 0)

        // Add residential building with citizens
        if let building = buildingSystem.createBuilding(
            type: .residential(.apartment),
            at: SIMD3(0, 0, 0),
            cityData: city
        ) {
            var constructedBuilding = building
            constructedBuilding.constructionProgress = 1.0
            constructedBuilding.isConstructed = true
            city.buildings.append(constructedBuilding)
        }

        // Add citizens
        for i in 0..<20 {
            city.citizens.append(Citizen(name: "Citizen \(i)", age: 30))
        }

        // Economy should change
        let newIncome = economicSystem.calculateIncome(city)
        let newExpenses = economicSystem.calculateExpenses(city)

        #expect(newIncome > initialIncome)
        #expect(newExpenses > initialExpenses)
    }

    @Test("Roads enable traffic flow")
    func testRoadsEnableTrafficFlow() {
        var city = CityData()
        let roadSystem = RoadConstructionSystem()
        let trafficSystem = TrafficSimulationSystem()

        // No roads = no traffic
        let noRoadVehicles = trafficSystem.spawnVehicles(count: 10, city: &city)
        #expect(noRoadVehicles == 0)

        // Add road
        if let road = roadSystem.createRoad(from: [
            SIMD3(0, 0, 0),
            SIMD3(0.5, 0, 0)
        ]) {
            city.roads.append(road)
        }

        // Now can spawn vehicles
        let withRoadVehicles = trafficSystem.spawnVehicles(count: 10, city: &city)
        #expect(withRoadVehicles > 0)

        // Traffic updates work
        trafficSystem.updateTraffic(&city, deltaTime: 1.0)
        #expect(city.vehicles.allSatisfy { $0.pathProgress >= 0 })
    }

    @Test("Citizens require homes to spawn")
    func testCitizensRequireHomes() {
        var city = CityData()
        let citizenSystem = CitizenAISystem()
        let buildingSystem = BuildingPlacementSystem()

        // No homes = no citizens
        let noHomesCitizens = citizenSystem.spawnCitizens(count: 10, city: &city)
        #expect(noHomesCitizens == 0)

        // Add residential building
        if let building = buildingSystem.createBuilding(
            type: .residential(.apartment),
            at: SIMD3(0, 0, 0),
            cityData: city
        ) {
            var constructedBuilding = building
            constructedBuilding.constructionProgress = 1.0
            constructedBuilding.isConstructed = true
            city.buildings.append(constructedBuilding)
        }

        // Now can spawn citizens
        let withHomesCitizens = citizenSystem.spawnCitizens(count: 10, city: &city)
        #expect(withHomesCitizens > 0)
        #expect(city.citizens.allSatisfy { $0.home != nil })
    }

    @Test("Employment affects citizen happiness")
    func testEmploymentAffectsHappiness() {
        var city = CityData()
        let citizenSystem = CitizenAISystem()
        let economicSystem = EconomicSimulationSystem()

        // Add residential and commercial buildings
        var resBuilding = Building(
            type: .residential(.apartment),
            position: SIMD3(0, 0, 0),
            capacity: 50,
            constructionProgress: 1.0
        )
        resBuilding.isConstructed = true
        city.buildings.append(resBuilding)

        var commBuilding = Building(
            type: .commercial(.office),
            position: SIMD3(0.2, 0, 0),
            capacity: 100,
            constructionProgress: 1.0
        )
        commBuilding.isConstructed = true
        city.buildings.append(commBuilding)

        // Spawn citizens
        citizenSystem.spawnCitizens(count: 10, city: &city)

        // Calculate happiness without jobs
        var unemployedHappiness: Float = 0
        for citizen in city.citizens {
            unemployedHappiness += citizenSystem.calculateHappiness(citizen: citizen, city: city)
        }
        unemployedHappiness /= Float(city.citizens.count)

        // Assign jobs
        economicSystem.assignJobs(&city)

        // Calculate happiness with jobs
        var employedHappiness: Float = 0
        for citizen in city.citizens {
            employedHappiness += citizenSystem.calculateHappiness(citizen: citizen, city: city)
        }
        employedHappiness /= Float(city.citizens.count)

        // Employed should be happier
        #expect(employedHappiness > unemployedHappiness)
    }

    @Test("Traffic congestion affects city statistics")
    func testTrafficCongestionAffectsStatistics() {
        var city = CityData()
        let roadSystem = RoadConstructionSystem()
        let trafficSystem = TrafficSimulationSystem()

        // Add road
        if let road = roadSystem.createRoad(from: [
            SIMD3(0, 0, 0),
            SIMD3(0.5, 0, 0)
        ]) {
            city.roads.append(road)
        }

        // Low traffic
        trafficSystem.spawnVehicles(count: 2, city: &city)
        let lowDensity = trafficSystem.calculateAverageTrafficDensity(city: city)

        // High traffic
        trafficSystem.spawnVehicles(count: 8, city: &city)
        let highDensity = trafficSystem.calculateAverageTrafficDensity(city: city)

        #expect(highDensity > lowDensity)

        // Update city statistics
        city.statistics.trafficDensity = highDensity
        #expect(city.statistics.trafficDensity > 0)
    }

    @Test("Game state persists and restores")
    func testGameStatePersistence() throws {
        var city = CityData(name: "Persistent City")
        let buildingSystem = BuildingPlacementSystem()

        // Build city
        if let building = buildingSystem.createBuilding(
            type: .residential(.apartment),
            at: SIMD3(0, 0, 0),
            cityData: city
        ) {
            city.buildings.append(building)
        }

        city.citizens.append(Citizen(name: "Test Citizen", age: 30))

        // Encode
        let encoder = JSONEncoder()
        let data = try encoder.encode(city)

        // Decode
        let decoder = JSONDecoder()
        let restoredCity = try decoder.decode(CityData.self, from: data)

        // Verify
        #expect(restoredCity.name == city.name)
        #expect(restoredCity.buildings.count == city.buildings.count)
        #expect(restoredCity.citizens.count == city.citizens.count)
    }

    @Test("Road intersections connect properly")
    func testRoadIntersectionsConnect() {
        var city = CityData()
        let roadSystem = RoadConstructionSystem()

        // Create first road (horizontal)
        if let road1 = roadSystem.createRoad(from: [
            SIMD3(-0.2, 0, 0),
            SIMD3(0.2, 0, 0)
        ]) {
            city.roads.append(road1)
        }

        // Create second road (vertical, crossing first)
        if let road2 = roadSystem.createRoad(from: [
            SIMD3(0, 0, -0.2),
            SIMD3(0, 0, 0.2)
        ]) {
            roadSystem.addRoadToCity(road: road2, city: &city)
        }

        // Should have detected intersection and created connections
        #expect(city.roads.count == 2)
        #expect(!city.roads[1].connections.isEmpty)
        #expect(city.roads[1].connections.contains(city.roads[0].id))
    }

    @Test("Full simulation loop integrates all systems")
    func testFullSimulationLoop() {
        var city = CityData()
        let buildingSystem = BuildingPlacementSystem()
        let roadSystem = RoadConstructionSystem()
        let economicSystem = EconomicSimulationSystem()
        let citizenSystem = CitizenAISystem()
        let trafficSystem = TrafficSimulationSystem()
        var gameState = GameState(cityData: city)

        // Setup city
        for i in 0..<3 {
            if let building = buildingSystem.createBuilding(
                type: .residential(.apartment),
                at: SIMD3(Float(i) * 0.2, 0, 0),
                cityData: city
            ) {
                var constructed = building
                constructed.constructionProgress = 1.0
                constructed.isConstructed = true
                gameState.addBuilding(constructed)
            }
        }

        if let road = roadSystem.createRoad(from: [
            SIMD3(0, 0, 0.1),
            SIMD3(0.5, 0, 0.1)
        ]) {
            gameState.addRoad(road)
        }

        // Populate
        citizenSystem.spawnCitizens(count: 30, city: &gameState.cityData)
        trafficSystem.spawnVehicles(count: 10, city: &gameState.cityData)

        // Run simulation for 10 frames
        for frame in 0..<10 {
            let deltaTime: Float = 1.0 / 60.0  // 60 FPS
            let gameTime = Double(frame) * Double(deltaTime)

            gameState.updateTime(deltaTime: deltaTime, speedMultiplier: 1.0)
            economicSystem.updateEconomy(&gameState.cityData, deltaTime: deltaTime)
            citizenSystem.updateCitizens(&gameState.cityData, deltaTime: deltaTime, gameTime: gameTime)
            trafficSystem.updateTraffic(&gameState.cityData, deltaTime: deltaTime)
        }

        // Verify simulation ran
        #expect(gameState.gameTime > 0)
        #expect(gameState.cityData.population > 0)
        #expect(gameState.cityData.economy.income >= 0)
    }
}
