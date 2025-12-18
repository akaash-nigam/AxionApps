import Foundation
import simd

/// Manages vehicle traffic simulation and routing
final class TrafficSimulationSystem {
    // MARK: - Properties

    /// Base vehicle speed (meters per second)
    let baseVehicleSpeed: Float = 0.03

    /// Minimum distance between vehicles
    let minVehicleDistance: Float = 0.02

    /// Maximum vehicles per road segment
    let maxVehiclesPerSegment: Int = 10

    // MARK: - Public Methods

    /// Update all vehicles in the simulation
    /// - Parameters:
    ///   - city: Current city data (mutable)
    ///   - deltaTime: Time elapsed since last update
    func updateTraffic(_ city: inout CityData, deltaTime: Float) {
        for i in 0..<city.vehicles.count {
            moveVehicle(index: i, city: &city, deltaTime: deltaTime)
        }

        // Clean up vehicles that have completed their routes
        city.vehicles.removeAll { $0.road == nil && $0.pathProgress >= 1.0 }
    }

    /// Spawn vehicles on roads
    /// - Parameters:
    ///   - count: Number of vehicles to spawn
    ///   - city: Current city data (mutable)
    /// - Returns: Number of vehicles actually spawned
    @discardableResult
    func spawnVehicles(count: Int, city: inout CityData) -> Int {
        guard !city.roads.isEmpty else { return 0 }

        var spawned = 0

        for _ in 0..<count {
            // Pick a random road
            guard let road = city.roads.randomElement() else { break }

            // Check if road has capacity
            let vehiclesOnRoad = city.vehicles.filter { $0.road == road.id }.count
            if vehiclesOnRoad >= maxVehiclesPerSegment {
                continue
            }

            // Create vehicle
            let vehicleType: VehicleType = Bool.random() ? .car : (Bool.random() ? .truck : .bus)
            var vehicle = Vehicle(vehicleType: vehicleType, speed: baseVehicleSpeed)

            vehicle.road = road.id
            vehicle.pathProgress = 0.0
            vehicle.currentPosition = road.path.first ?? SIMD3(0, 0, 0)

            city.vehicles.append(vehicle)
            spawned += 1
        }

        return spawned
    }

    /// Calculate traffic density on a road
    /// - Parameters:
    ///   - roadId: The road ID
    ///   - city: Current city data
    /// - Returns: Traffic density (0.0 to 1.0)
    func calculateTrafficDensity(roadId: UUID, city: CityData) -> Float {
        guard let road = city.roads.first(where: { $0.id == roadId }) else {
            return 0.0
        }

        let vehiclesOnRoad = city.vehicles.filter { $0.road == roadId }.count
        return Float(vehiclesOnRoad) / Float(road.trafficCapacity.clamped(to: 1...Int.max))
    }

    /// Calculate average traffic density for entire city
    /// - Parameter city: Current city data
    /// - Returns: Average density (0.0 to 1.0)
    func calculateAverageTrafficDensity(city: CityData) -> Float {
        guard !city.roads.isEmpty else { return 0.0 }

        var totalDensity: Float = 0.0

        for road in city.roads {
            totalDensity += calculateTrafficDensity(roadId: road.id, city: city)
        }

        return totalDensity / Float(city.roads.count)
    }

    /// Route a vehicle from one road to another
    /// - Parameters:
    ///   - vehicleIndex: Index of the vehicle
    ///   - targetRoadId: Destination road ID
    ///   - city: Current city data (mutable)
    func routeVehicle(vehicleIndex: Int, targetRoadId: UUID, city: inout CityData) {
        guard vehicleIndex < city.vehicles.count else { return }

        // Simple routing: just set the target road
        // In full implementation, this would use road graph pathfinding
        city.vehicles[vehicleIndex].road = targetRoadId
        city.vehicles[vehicleIndex].pathProgress = 0.0
    }

    /// Check if road has traffic congestion
    /// - Parameters:
    ///   - roadId: The road ID
    ///   - city: Current city data
    /// - Returns: True if congested (density > 0.8)
    func isRoadCongested(roadId: UUID, city: CityData) -> Bool {
        let density = calculateTrafficDensity(roadId: roadId, city: city)
        return density > 0.8
    }

    /// Get congested roads in the city
    /// - Parameter city: Current city data
    /// - Returns: Array of congested road IDs
    func getCongestedRoads(city: CityData) -> [UUID] {
        return city.roads.filter { isRoadCongested(roadId: $0.id, city: city) }.map { $0.id }
    }

    /// Despawn vehicles to reduce traffic
    /// - Parameters:
    ///   - count: Number of vehicles to despawn
    ///   - city: Current city data (mutable)
    /// - Returns: Number of vehicles despawned
    @discardableResult
    func despawnVehicles(count: Int, city: inout CityData) -> Int {
        let toRemove = min(count, city.vehicles.count)
        city.vehicles.removeLast(toRemove)
        return toRemove
    }

    // MARK: - Private Methods

    /// Move a vehicle along its road
    private func moveVehicle(index: Int, city: inout CityData, deltaTime: Float) {
        guard let roadId = city.vehicles[index].road,
              let road = city.roads.first(where: { $0.id == roadId }) else {
            return
        }

        let vehicle = city.vehicles[index]

        // Calculate speed (adjusted for traffic density)
        let density = calculateTrafficDensity(roadId: roadId, city: city)
        let speedMultiplier = 1.0 - (density * 0.5)  // Slow down in traffic
        let speed = vehicle.speed * speedMultiplier

        // Update progress along road
        let roadLength = road.length
        guard roadLength > 0 else { return }

        let progressDelta = (speed * deltaTime) / roadLength
        var newProgress = vehicle.pathProgress + progressDelta

        // Check if reached end of road
        if newProgress >= 1.0 {
            // Try to move to connected road
            if !road.connections.isEmpty, let nextRoad = road.connections.randomElement() {
                city.vehicles[index].road = nextRoad
                city.vehicles[index].pathProgress = 0.0
            } else {
                // No connections, remove vehicle
                city.vehicles[index].road = nil
                city.vehicles[index].pathProgress = 1.0
                return
            }
        } else {
            city.vehicles[index].pathProgress = newProgress
        }

        // Update position based on progress along road path
        updateVehiclePosition(index: index, road: road, city: &city)
    }

    /// Update vehicle's 3D position based on road progress
    private func updateVehiclePosition(index: Int, road: Road, city: inout CityData) {
        let progress = city.vehicles[index].pathProgress
        let pathIndex = Int(Float(road.path.count - 1) * progress)
        let nextIndex = min(pathIndex + 1, road.path.count - 1)

        let segment = progress * Float(road.path.count - 1) - Float(pathIndex)

        let currentPoint = road.path[pathIndex]
        let nextPoint = road.path[nextIndex]

        // Interpolate position
        let position = currentPoint + (nextPoint - currentPoint) * segment

        city.vehicles[index].currentPosition = position
    }
}

// MARK: - Extensions

extension Int {
    func clamped(to range: ClosedRange<Int>) -> Int {
        return Swift.min(Swift.max(self, range.lowerBound), range.upperBound)
    }
}
