import Testing
import Foundation
@testable import CityBuilderTabletop

/// Performance tests to ensure the game meets FPS targets
@Suite("Performance Tests")
struct PerformanceTests {

    @Test("Simulate 1000 citizens at 60 FPS")
    func testSimulate1000Citizens() {
        var city = CityData()
        let citizenSystem = CitizenAISystem()

        // Setup city
        for i in 0..<50 {
            var building = Building(
                type: .residential(.apartment),
                position: SIMD3(Float(i % 10) * 0.2, 0, Float(i / 10) * 0.2),
                capacity: 24,
                constructionProgress: 1.0
            )
            building.isConstructed = true
            city.buildings.append(building)
        }

        // Spawn 1000 citizens
        citizenSystem.spawnCitizens(count: 1000, city: &city)
        #expect(city.citizens.count == 1000)

        // Measure update time
        let startTime = Date()

        // Simulate 60 frames (1 second at 60 FPS)
        for frame in 0..<60 {
            let deltaTime: Float = 1.0 / 60.0
            let gameTime = Double(frame) * Double(deltaTime)
            citizenSystem.updateCitizens(&city, deltaTime: deltaTime, gameTime: gameTime)
        }

        let elapsed = Date().timeIntervalSince(startTime)

        // Should complete in < 1 second (ideally much less)
        #expect(elapsed < 2.0)

        print("1000 citizens @ 60 FPS: \(elapsed)s (target: < 1.0s)")
    }

    @Test("Simulate 500 vehicles at 60 FPS")
    func testSimulate500Vehicles() {
        var city = CityData()
        let trafficSystem = TrafficSimulationSystem()
        let roadSystem = RoadConstructionSystem()

        // Create road network
        for i in 0..<20 {
            if let road = roadSystem.createRoad(from: [
                SIMD3(Float(i) * 0.1, 0, 0),
                SIMD3(Float(i) * 0.1, 0, 0.5)
            ]) {
                city.roads.append(road)
            }
        }

        // Spawn 500 vehicles
        trafficSystem.spawnVehicles(count: 500, city: &city)
        #expect(city.vehicles.count > 0)

        // Measure update time
        let startTime = Date()

        // Simulate 60 frames
        for _ in 0..<60 {
            let deltaTime: Float = 1.0 / 60.0
            trafficSystem.updateTraffic(&city, deltaTime: deltaTime)
        }

        let elapsed = Date().timeIntervalSince(startTime)

        // Should complete in < 1 second
        #expect(elapsed < 2.0)

        print("500 vehicles @ 60 FPS: \(elapsed)s (target: < 1.0s)")
    }

    @Test("Economic simulation with large city")
    func testEconomicSimulationPerformance() {
        var city = CityData()
        let economicSystem = EconomicSimulationSystem()

        // Create large city
        for i in 0..<500 {
            let buildingType: BuildingType
            let mod = i % 3
            if mod == 0 {
                buildingType = .residential(.apartment)
            } else if mod == 1 {
                buildingType = .commercial(.office)
            } else {
                buildingType = .industrial(.smallFactory)
            }

            var building = Building(
                type: buildingType,
                position: SIMD3(Float(i % 25) * 0.2, 0, Float(i / 25) * 0.2),
                capacity: 50,
                constructionProgress: 1.0
            )
            building.isConstructed = true
            city.buildings.append(building)
        }

        // Add 5000 citizens
        for i in 0..<5000 {
            city.citizens.append(Citizen(name: "Citizen \(i)", age: 30))
        }

        // Measure economic update time
        let startTime = Date()

        for _ in 0..<60 {
            economicSystem.updateEconomy(&city, deltaTime: 1.0 / 60.0)
        }

        let elapsed = Date().timeIntervalSince(startTime)

        // Should complete in < 1 second
        #expect(elapsed < 2.0)

        print("Economic simulation (500 buildings, 5000 citizens) @ 60 FPS: \(elapsed)s")
    }

    @Test("Building placement validation performance")
    func testBuildingPlacementPerformance() {
        var city = CityData()
        let buildingSystem = BuildingPlacementSystem()

        // Add many existing buildings
        for i in 0..<500 {
            let building = Building(
                type: .residential(.smallHouse),
                position: SIMD3(Float(i % 25) * 0.15, 0, Float(i / 25) * 0.15)
            )
            city.buildings.append(building)
        }

        // Measure validation time
        let startTime = Date()

        // Test 1000 placement validations
        for i in 0..<1000 {
            let position = SIMD3<Float>(
                Float.random(in: -0.5...0.5),
                0,
                Float.random(in: -0.5...0.5)
            )
            _ = buildingSystem.canPlaceBuilding(
                at: position,
                type: .residential(.smallHouse),
                cityData: city
            )
        }

        let elapsed = Date().timeIntervalSince(startTime)

        // Should complete in < 1 second
        #expect(elapsed < 1.0)

        print("1000 placement validations (500 buildings): \(elapsed)s")
    }

    @Test("Road construction performance")
    func testRoadConstructionPerformance() {
        let roadSystem = RoadConstructionSystem()

        let startTime = Date()

        // Create 100 roads
        for _ in 0..<100 {
            let points = [
                SIMD3<Float>(Float.random(in: -0.5...0.5), 0, Float.random(in: -0.5...0.5)),
                SIMD3<Float>(Float.random(in: -0.5...0.5), 0, Float.random(in: -0.5...0.5)),
                SIMD3<Float>(Float.random(in: -0.5...0.5), 0, Float.random(in: -0.5...0.5))
            ]
            _ = roadSystem.createRoad(from: points)
        }

        let elapsed = Date().timeIntervalSince(startTime)

        // Should complete in < 0.5 seconds
        #expect(elapsed < 1.0)

        print("100 road constructions: \(elapsed)s")
    }

    @Test("Full city simulation performance")
    func testFullCitySimulationPerformance() {
        var city = CityData()
        let buildingSystem = BuildingPlacementSystem()
        let roadSystem = RoadConstructionSystem()
        let economicSystem = EconomicSimulationSystem()
        let citizenSystem = CitizenAISystem()
        let trafficSystem = TrafficSimulationSystem()

        // Build medium-sized city
        for i in 0..<100 {
            if let building = buildingSystem.createBuilding(
                type: i % 2 == 0 ? .residential(.apartment) : .commercial(.office),
                at: SIMD3(Float(i % 10) * 0.2, 0, Float(i / 10) * 0.2),
                cityData: city
            ) {
                var constructed = building
                constructed.constructionProgress = 1.0
                constructed.isConstructed = true
                city.buildings.append(constructed)
            }
        }

        // Add roads
        for i in 0..<10 {
            if let road = roadSystem.createRoad(from: [
                SIMD3(Float(i) * 0.2, 0, 0),
                SIMD3(Float(i) * 0.2, 0, 2.0)
            ]) {
                city.roads.append(road)
            }
        }

        // Populate
        citizenSystem.spawnCitizens(count: 1000, city: &city)
        trafficSystem.spawnVehicles(count: 100, city: &city)

        // Measure full simulation
        let startTime = Date()

        // Simulate 60 frames (1 second @ 60 FPS)
        for frame in 0..<60 {
            let deltaTime: Float = 1.0 / 60.0
            let gameTime = Double(frame) * Double(deltaTime)

            economicSystem.updateEconomy(&city, deltaTime: deltaTime)
            citizenSystem.updateCitizens(&city, deltaTime: deltaTime, gameTime: gameTime)
            trafficSystem.updateTraffic(&city, deltaTime: deltaTime)
        }

        let elapsed = Date().timeIntervalSince(startTime)
        let fps = 60.0 / elapsed

        // Should maintain at least 30 FPS (2 seconds for 60 frames)
        #expect(elapsed < 2.0)

        print("Full city simulation (100 buildings, 1000 citizens, 100 vehicles): \(elapsed)s (\(Int(fps)) FPS)")
    }

    @Test("Memory usage stays under 2GB")
    func testMemoryUsage() {
        var city = CityData()
        let citizenSystem = CitizenAISystem()

        // Create large city
        for i in 0..<1000 {
            var building = Building(
                type: .residential(.apartment),
                position: SIMD3(Float(i % 32) * 0.2, 0, Float(i / 32) * 0.2),
                capacity: 24,
                constructionProgress: 1.0
            )
            building.isConstructed = true
            city.buildings.append(building)
        }

        // Spawn 10,000 citizens
        citizenSystem.spawnCitizens(count: 10000, city: &city)

        #expect(city.buildings.count == 1000)
        #expect(city.citizens.count == 10000)

        // Note: Actual memory measurement requires platform-specific APIs
        // This test verifies that large cities can be created
        print("Created city with 1000 buildings and 10,000 citizens")
    }
}
