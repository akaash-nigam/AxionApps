import Testing
import Foundation
@testable import CityBuilderTabletop

/// Unit tests for TrafficSimulationSystem
@Suite("TrafficSimulationSystem Tests")
struct TrafficSimulationSystemTests {

    @Test("Spawn vehicles on roads")
    func testSpawnVehicles() {
        let system = TrafficSimulationSystem()
        var city = CityData()

        // Add road
        city.roads.append(Road(path: [
            SIMD3(0, 0, 0),
            SIMD3(0.1, 0, 0)
        ], trafficCapacity: 100))

        let spawned = system.spawnVehicles(count: 10, city: &city)

        #expect(spawned == 10)
        #expect(city.vehicles.count == 10)

        // All vehicles should be on roads
        for vehicle in city.vehicles {
            #expect(vehicle.road != nil)
        }
    }

    @Test("Cannot spawn vehicles without roads")
    func testCannotSpawnWithoutRoads() {
        let system = TrafficSimulationSystem()
        var city = CityData()

        let spawned = system.spawnVehicles(count: 10, city: &city)

        #expect(spawned == 0)
        #expect(city.vehicles.isEmpty)
    }

    @Test("Respects road capacity when spawning")
    func testRespectsRoadCapacity() {
        let system = TrafficSimulationSystem()
        var city = CityData()

        // Add road with limited capacity
        city.roads.append(Road(path: [
            SIMD3(0, 0, 0),
            SIMD3(0.1, 0, 0)
        ], trafficCapacity: 5))

        // Try to spawn many vehicles
        system.spawnVehicles(count: 20, city: &city)

        // Should not exceed max vehicles per segment
        #expect(city.vehicles.count <= system.maxVehiclesPerSegment)
    }

    @Test("Calculate traffic density")
    func testCalculateTrafficDensity() {
        let system = TrafficSimulationSystem()
        var city = CityData()

        let road = Road(path: [
            SIMD3(0, 0, 0),
            SIMD3(0.1, 0, 0)
        ], trafficCapacity: 10)
        city.roads.append(road)

        // Add 5 vehicles (50% capacity)
        for _ in 0..<5 {
            var vehicle = Vehicle(vehicleType: .car)
            vehicle.road = road.id
            city.vehicles.append(vehicle)
        }

        let density = system.calculateTrafficDensity(roadId: road.id, city: city)

        #expect(density > 0.4)
        #expect(density < 0.6)
    }

    @Test("Calculate average traffic density")
    func testCalculateAverageTrafficDensity() {
        let system = TrafficSimulationSystem()
        var city = CityData()

        // Add two roads
        let road1 = Road(path: [SIMD3(0, 0, 0), SIMD3(0.1, 0, 0)], trafficCapacity: 10)
        let road2 = Road(path: [SIMD3(0, 0, 0), SIMD3(0, 0, 0.1)], trafficCapacity: 10)
        city.roads.append(road1)
        city.roads.append(road2)

        // Add vehicles to first road only
        for _ in 0..<5 {
            var vehicle = Vehicle(vehicleType: .car)
            vehicle.road = road1.id
            city.vehicles.append(vehicle)
        }

        let avgDensity = system.calculateAverageTrafficDensity(city: city)

        #expect(avgDensity > 0.2)  // Half of 50%
        #expect(avgDensity < 0.3)
    }

    @Test("Detect road congestion")
    func testDetectCongestion() {
        let system = TrafficSimulationSystem()
        var city = CityData()

        let road = Road(path: [SIMD3(0, 0, 0), SIMD3(0.1, 0, 0)], trafficCapacity: 10)
        city.roads.append(road)

        // Add many vehicles (90% capacity)
        for _ in 0..<9 {
            var vehicle = Vehicle(vehicleType: .car)
            vehicle.road = road.id
            city.vehicles.append(vehicle)
        }

        let isCongested = system.isRoadCongested(roadId: road.id, city: city)

        #expect(isCongested)
    }

    @Test("Get congested roads")
    func testGetCongestedRoads() {
        let system = TrafficSimulationSystem()
        var city = CityData()

        let road1 = Road(path: [SIMD3(0, 0, 0), SIMD3(0.1, 0, 0)], trafficCapacity: 10)
        let road2 = Road(path: [SIMD3(0, 0, 0), SIMD3(0, 0, 0.1)], trafficCapacity: 10)
        city.roads.append(road1)
        city.roads.append(road2)

        // Congest first road
        for _ in 0..<9 {
            var vehicle = Vehicle(vehicleType: .car)
            vehicle.road = road1.id
            city.vehicles.append(vehicle)
        }

        let congestedRoads = system.getCongestedRoads(city: city)

        #expect(congestedRoads.count == 1)
        #expect(congestedRoads.contains(road1.id))
    }

    @Test("Update traffic moves vehicles")
    func testUpdateTrafficMovement() {
        let system = TrafficSimulationSystem()
        var city = CityData()

        let road = Road(path: [
            SIMD3(0, 0, 0),
            SIMD3(0.1, 0, 0),
            SIMD3(0.2, 0, 0)
        ])
        city.roads.append(road)

        var vehicle = Vehicle(vehicleType: .car)
        vehicle.road = road.id
        vehicle.pathProgress = 0.0
        city.vehicles.append(vehicle)

        let initialProgress = city.vehicles[0].pathProgress

        // Update for 1 second
        system.updateTraffic(&city, deltaTime: 1.0)

        // Progress should have increased
        #expect(city.vehicles[0].pathProgress > initialProgress)
    }

    @Test("Despawn vehicles")
    func testDespawnVehicles() {
        let system = TrafficSimulationSystem()
        var city = CityData()

        // Add road and vehicles
        city.roads.append(Road(path: [SIMD3(0, 0, 0), SIMD3(0.1, 0, 0)]))
        system.spawnVehicles(count: 10, city: &city)

        #expect(city.vehicles.count == 10)

        let despawned = system.despawnVehicles(count: 5, city: &city)

        #expect(despawned == 5)
        #expect(city.vehicles.count == 5)
    }

    @Test("Route vehicle to different road")
    func testRouteVehicle() {
        let system = TrafficSimulationSystem()
        var city = CityData()

        let road1 = Road(path: [SIMD3(0, 0, 0), SIMD3(0.1, 0, 0)])
        let road2 = Road(path: [SIMD3(0.1, 0, 0), SIMD3(0.2, 0, 0)])
        city.roads.append(road1)
        city.roads.append(road2)

        var vehicle = Vehicle(vehicleType: .car)
        vehicle.road = road1.id
        city.vehicles.append(vehicle)

        system.routeVehicle(vehicleIndex: 0, targetRoadId: road2.id, city: &city)

        #expect(city.vehicles[0].road == road2.id)
        #expect(city.vehicles[0].pathProgress == 0.0)
    }

    @Test("Traffic slows down in congestion")
    func testTrafficSlowsInCongestion() {
        let system = TrafficSimulationSystem()
        var city = CityData()

        let road = Road(path: [
            SIMD3(0, 0, 0),
            SIMD3(1, 0, 0)  // Long road
        ], trafficCapacity: 10)
        city.roads.append(road)

        // Test with low traffic
        var vehicle1 = Vehicle(vehicleType: .car)
        vehicle1.road = road.id
        vehicle1.pathProgress = 0.0
        city.vehicles.append(vehicle1)

        let initialProgress1 = city.vehicles[0].pathProgress
        system.updateTraffic(&city, deltaTime: 1.0)
        let progressLowTraffic = city.vehicles[0].pathProgress - initialProgress1

        // Test with high traffic
        for _ in 0..<8 {
            var vehicle = Vehicle(vehicleType: .car)
            vehicle.road = road.id
            city.vehicles.append(vehicle)
        }

        city.vehicles[0].pathProgress = 0.0
        let initialProgress2 = city.vehicles[0].pathProgress
        system.updateTraffic(&city, deltaTime: 1.0)
        let progressHighTraffic = city.vehicles[0].pathProgress - initialProgress2

        // Should move slower with more traffic
        #expect(progressHighTraffic < progressLowTraffic)
    }
}
