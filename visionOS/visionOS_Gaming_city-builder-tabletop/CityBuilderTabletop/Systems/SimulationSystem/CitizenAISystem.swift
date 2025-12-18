import Foundation
import simd

/// Manages citizen AI behavior, pathfinding, and daily routines
final class CitizenAISystem {
    // MARK: - Properties

    /// Citizen movement speed (meters per second in-game)
    let movementSpeed: Float = 0.02

    /// Time of day for activity transitions (0-24 hours)
    private let activitySchedule: [Activity: (start: Float, end: Float)] = [
        .sleeping: (20.5, 7.0),
        .commuting: (7.0, 8.0),
        .working: (8.0, 17.0),
        .leisure: (17.0, 20.0),
        .returning: (20.0, 20.5)
    ]

    // MARK: - Public Methods

    /// Update all citizens' AI and positions
    /// - Parameters:
    ///   - city: Current city data (mutable)
    ///   - deltaTime: Time elapsed since last update
    ///   - gameTime: Current in-game time (seconds)
    func updateCitizens(_ city: inout CityData, deltaTime: Float, gameTime: TimeInterval) {
        let hourOfDay = Float((gameTime.truncatingRemainder(dividingBy: 86400)) / 3600)

        for i in 0..<city.citizens.count {
            // Determine current activity based on time of day
            let newActivity = determineActivity(for: hourOfDay)

            if city.citizens[i].currentActivity != newActivity {
                city.citizens[i].currentActivity = newActivity
                updateTargetPosition(for: i, city: &city, activity: newActivity)
            }

            // Move citizen towards target
            moveCitizen(index: i, city: &city, deltaTime: deltaTime)

            // Update happiness based on city conditions
            updateHappiness(for: i, city: &city)
        }
    }

    /// Assign a home to a citizen
    /// - Parameters:
    ///   - citizenId: The citizen's ID
    ///   - buildingId: The home building's ID
    ///   - city: Current city data (mutable)
    func assignHome(citizenId: UUID, buildingId: UUID, city: inout CityData) {
        guard let citizenIndex = city.citizens.firstIndex(where: { $0.id == citizenId }),
              let building = city.buildings.first(where: { $0.id == buildingId }),
              building.type.isResidential else {
            return
        }

        city.citizens[citizenIndex].home = buildingId
        city.citizens[citizenIndex].currentPosition = building.position
        city.citizens[citizenIndex].targetPosition = building.position
    }

    /// Spawn citizens in residential buildings
    /// - Parameters:
    ///   - count: Number of citizens to spawn
    ///   - city: Current city data (mutable)
    /// - Returns: Number of citizens actually spawned
    @discardableResult
    func spawnCitizens(count: Int, city: inout CityData) -> Int {
        let residentialBuildings = city.buildings.filter { $0.type.isResidential && $0.isConstructed }

        guard !residentialBuildings.isEmpty else { return 0 }

        var spawned = 0

        for _ in 0..<count {
            // Find a residential building with available capacity
            guard let building = residentialBuildings.first(where: { $0.occupancy < $0.capacity }) else {
                break
            }

            // Create new citizen
            let citizen = Citizen(
                name: generateCitizenName(),
                age: Int.random(in: 18...65),
                occupation: .unemployed,
                happiness: 0.75,
                currentPosition: building.position
            )

            var newCitizen = citizen
            newCitizen.home = building.id
            newCitizen.targetPosition = building.position

            city.citizens.append(newCitizen)

            // Update building occupancy
            if let buildingIndex = city.buildings.firstIndex(where: { $0.id == building.id }) {
                city.buildings[buildingIndex].occupancy += 1
            }

            spawned += 1
        }

        return spawned
    }

    /// Calculate happiness for a citizen based on city conditions
    /// - Parameters:
    ///   - citizen: The citizen
    ///   - city: Current city data
    /// - Returns: Happiness value (0.0 to 1.0)
    func calculateHappiness(citizen: Citizen, city: CityData) -> Float {
        var happiness: Float = 0.5  // Base happiness

        // Has home: +0.2
        if citizen.home != nil {
            happiness += 0.2
        }

        // Has job: +0.2
        if citizen.occupation != .unemployed {
            happiness += 0.2
        }

        // City-wide factors
        let avgHappiness = city.statistics.averageHappiness
        happiness += avgHappiness * 0.1

        // Low unemployment bonus
        if city.economy.unemployment < 0.1 {
            happiness += 0.1
        }

        // Low pollution bonus
        if city.statistics.pollution < 0.2 {
            happiness += 0.1
        }

        // Low crime bonus
        if city.statistics.crimeRate < 0.1 {
            happiness += 0.1
        }

        return min(max(happiness, 0.0), 1.0)
    }

    // MARK: - Private Methods

    /// Determine activity based on time of day
    private func determineActivity(for hour: Float) -> Activity {
        // Normalize hour (handle wrap-around)
        let normalizedHour = hour < 0 ? hour + 24 : (hour >= 24 ? hour - 24 : hour)

        if normalizedHour >= 7.0 && normalizedHour < 8.0 {
            return .commuting
        } else if normalizedHour >= 8.0 && normalizedHour < 17.0 {
            return .working
        } else if normalizedHour >= 17.0 && normalizedHour < 20.0 {
            return .leisure
        } else if normalizedHour >= 20.0 && normalizedHour < 20.5 {
            return .returning
        } else {
            return .sleeping
        }
    }

    /// Update citizen's target position based on activity
    private func updateTargetPosition(for index: Int, city: inout CityData, activity: Activity) {
        let citizen = city.citizens[index]

        switch activity {
        case .sleeping, .returning:
            // Go home
            if let homeId = citizen.home,
               let home = city.buildings.first(where: { $0.id == homeId }) {
                city.citizens[index].targetPosition = home.position
            }

        case .working:
            // Go to workplace
            if let workplaceId = citizen.workplace,
               let workplace = city.buildings.first(where: { $0.id == workplaceId }) {
                city.citizens[index].targetPosition = workplace.position
            } else if let homeId = citizen.home,
                      let home = city.buildings.first(where: { $0.id == homeId }) {
                // Stay home if no workplace
                city.citizens[index].targetPosition = home.position
            }

        case .shopping, .leisure:
            // Go to a random commercial building
            let commercialBuildings = city.buildings.filter { $0.type.isCommercial }
            if let destination = commercialBuildings.randomElement() {
                city.citizens[index].targetPosition = destination.position
            }

        case .commuting:
            // Handled by transition to working/returning
            break
        }
    }

    /// Move citizen towards target position
    private func moveCitizen(index: Int, city: inout CityData, deltaTime: Float) {
        let current = city.citizens[index].currentPosition
        let target = city.citizens[index].targetPosition

        let distance = simd_distance(current, target)

        // Already at target
        if distance < 0.001 {
            return
        }

        // Calculate movement
        let maxMove = movementSpeed * deltaTime
        let direction = simd_normalize(target - current)
        let moveDistance = min(maxMove, distance)

        city.citizens[index].currentPosition = current + direction * moveDistance
    }

    /// Update citizen happiness
    private func updateHappiness(for index: Int, city: inout CityData) {
        let citizen = city.citizens[index]
        let newHappiness = calculateHappiness(citizen: citizen, city: city)

        // Smooth happiness changes
        let currentHappiness = city.citizens[index].happiness
        city.citizens[index].happiness = currentHappiness * 0.95 + newHappiness * 0.05
    }

    /// Generate a random citizen name
    private func generateCitizenName() -> String {
        let firstNames = ["Alex", "Sam", "Jordan", "Taylor", "Morgan", "Casey", "Riley", "Avery"]
        let lastNames = ["Smith", "Johnson", "Williams", "Brown", "Jones", "Garcia", "Miller", "Davis"]

        let firstName = firstNames.randomElement() ?? "Citizen"
        let lastName = lastNames.randomElement() ?? "Unknown"

        return "\(firstName) \(lastName)"
    }

    /// Simple A* pathfinding (simplified version)
    func findPath(from start: SIMD3<Float>, to end: SIMD3<Float>, city: CityData) -> [SIMD3<Float>] {
        // For MVP, use simple direct path
        // In full implementation, this would use A* with road network

        // If there are roads, try to follow them (simplified)
        if city.roads.isEmpty {
            return [start, end]
        }

        // Find closest road points
        var path = [start]

        // Add some intermediate points for natural movement
        let segments = 5
        for i in 1...segments {
            let t = Float(i) / Float(segments)
            let point = start + (end - start) * t
            path.append(point)
        }

        return path
    }
}
