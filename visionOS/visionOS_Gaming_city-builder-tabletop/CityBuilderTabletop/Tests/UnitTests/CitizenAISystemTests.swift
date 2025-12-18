import Testing
import Foundation
@testable import CityBuilderTabletop

/// Unit tests for CitizenAISystem
@Suite("CitizenAISystem Tests")
struct CitizenAISystemTests {

    @Test("Spawn citizens in residential buildings")
    func testSpawnCitizens() {
        let system = CitizenAISystem()
        var city = CityData()

        // Add residential building
        city.buildings.append(Building(
            type: .residential(.apartment),
            position: SIMD3(0, 0, 0),
            capacity: 24,
            constructionProgress: 1.0
        ))

        let spawned = system.spawnCitizens(count: 10, city: &city)

        #expect(spawned == 10)
        #expect(city.citizens.count == 10)

        // All citizens should have homes
        for citizen in city.citizens {
            #expect(citizen.home != nil)
        }
    }

    @Test("Cannot spawn citizens without residential buildings")
    func testCannotSpawnWithoutHousing() {
        let system = CitizenAISystem()
        var city = CityData()

        let spawned = system.spawnCitizens(count: 10, city: &city)

        #expect(spawned == 0)
        #expect(city.citizens.isEmpty)
    }

    @Test("Respects building capacity when spawning")
    func testRespectsCapacity() {
        let system = CitizenAISystem()
        var city = CityData()

        // Add small building (capacity: 4)
        city.buildings.append(Building(
            type: .residential(.smallHouse),
            position: SIMD3(0, 0, 0),
            capacity: 4,
            constructionProgress: 1.0
        ))

        // Try to spawn more than capacity
        let spawned = system.spawnCitizens(count: 10, city: &city)

        #expect(spawned <= 4)
        #expect(city.citizens.count <= 4)
    }

    @Test("Assign home to citizen")
    func testAssignHome() {
        let system = CitizenAISystem()
        var city = CityData()

        let building = Building(
            type: .residential(.smallHouse),
            position: SIMD3(0, 0, 0),
            constructionProgress: 1.0
        )
        city.buildings.append(building)

        let citizen = Citizen(name: "Test Citizen", age: 30)
        city.citizens.append(citizen)

        system.assignHome(citizenId: citizen.id, buildingId: building.id, city: &city)

        #expect(city.citizens[0].home == building.id)
        #expect(city.citizens[0].currentPosition == building.position)
    }

    @Test("Calculate happiness with home and job")
    func testCalculateHappinessWithHomeAndJob() {
        let system = CitizenAISystem()
        var city = CityData()

        let building = Building(
            type: .residential(.smallHouse),
            position: SIMD3(0, 0, 0)
        )
        city.buildings.append(building)

        var citizen = Citizen(name: "Happy Citizen", age: 30, occupation: .office)
        citizen.home = building.id

        let happiness = system.calculateHappiness(citizen: citizen, city: city)

        #expect(happiness > 0.5)  // Should be above base level
    }

    @Test("Calculate happiness without home or job")
    func testCalculateHappinessWithoutHomeOrJob() {
        let system = CitizenAISystem()
        let city = CityData()

        let citizen = Citizen(name: "Unhappy Citizen", age: 30, occupation: .unemployed)

        let happiness = system.calculateHappiness(citizen: citizen, city: city)

        #expect(happiness < 0.7)  // Lower happiness
    }

    @Test("Update citizens moves them towards targets")
    func testUpdateCitizensMovement() {
        let system = CitizenAISystem()
        var city = CityData()

        var citizen = Citizen(name: "Walker", age: 30)
        citizen.currentPosition = SIMD3(0, 0, 0)
        citizen.targetPosition = SIMD3(0.1, 0, 0)
        city.citizens.append(citizen)

        let initialPosition = city.citizens[0].currentPosition

        // Update for 1 second
        system.updateCitizens(&city, deltaTime: 1.0, gameTime: 0)

        let newPosition = city.citizens[0].currentPosition

        // Should have moved towards target
        let distanceToTarget = simd_distance(newPosition, citizen.targetPosition)
        let initialDistanceToTarget = simd_distance(initialPosition, citizen.targetPosition)

        #expect(distanceToTarget < initialDistanceToTarget)
    }

    @Test("Citizens have names")
    func testCitizensHaveNames() {
        let system = CitizenAISystem()
        var city = CityData()

        city.buildings.append(Building(
            type: .residential(.smallHouse),
            position: SIMD3(0, 0, 0),
            capacity: 10,
            constructionProgress: 1.0
        ))

        system.spawnCitizens(count: 5, city: &city)

        for citizen in city.citizens {
            #expect(!citizen.name.isEmpty)
            #expect(citizen.name.contains(" "))  // Has first and last name
        }
    }

    @Test("Find path returns valid path")
    func testFindPath() {
        let system = CitizenAISystem()
        let city = CityData()

        let start = SIMD3<Float>(0, 0, 0)
        let end = SIMD3<Float>(0.5, 0, 0.5)

        let path = system.findPath(from: start, to: end, city: city)

        #expect(!path.isEmpty)
        #expect(path.first == start)
        #expect(path.last == end)
    }

    @Test("Citizens update happiness over time")
    func testHappinessUpdates() {
        let system = CitizenAISystem()
        var city = CityData()

        let building = Building(
            type: .residential(.smallHouse),
            position: SIMD3(0, 0, 0)
        )
        city.buildings.append(building)

        var citizen = Citizen(name: "Test", age: 30, happiness: 0.5)
        citizen.home = building.id
        citizen.occupation = .office
        city.citizens.append(citizen)

        let initialHappiness = city.citizens[0].happiness

        // Update multiple times
        for _ in 0..<10 {
            system.updateCitizens(&city, deltaTime: 1.0, gameTime: 0)
        }

        // Happiness should have changed (smoothly towards calculated value)
        #expect(city.citizens[0].happiness != initialHappiness)
    }
}
