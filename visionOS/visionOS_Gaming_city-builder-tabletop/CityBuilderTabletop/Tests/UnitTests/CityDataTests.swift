import Testing
import Foundation
@testable import CityBuilderTabletop

/// Unit tests for CityData model
@Suite("CityData Tests")
struct CityDataTests {

    @Test("CityData initializes with default values")
    func testInitialization() {
        let city = CityData()

        #expect(city.name == "New City")
        #expect(city.buildings.isEmpty)
        #expect(city.roads.isEmpty)
        #expect(city.zones.isEmpty)
        #expect(city.citizens.isEmpty)
        #expect(city.vehicles.isEmpty)
        #expect(city.population == 0)
        #expect(city.buildingCount == 0)
    }

    @Test("CityData initializes with custom name")
    func testCustomNameInitialization() {
        let city = CityData(name: "Test City")

        #expect(city.name == "Test City")
    }

    @Test("CityData computes population correctly")
    func testPopulationComputation() {
        var city = CityData()

        // Add citizens
        city.citizens.append(Citizen(name: "Alice", age: 30))
        city.citizens.append(Citizen(name: "Bob", age: 25))
        city.citizens.append(Citizen(name: "Charlie", age: 40))

        #expect(city.population == 3)
    }

    @Test("CityData computes building count correctly")
    func testBuildingCountComputation() {
        var city = CityData()

        // Add buildings
        city.buildings.append(Building(
            type: .residential(.smallHouse),
            position: SIMD3(0, 0, 0)
        ))
        city.buildings.append(Building(
            type: .commercial(.smallShop),
            position: SIMD3(0.1, 0, 0)
        ))

        #expect(city.buildingCount == 2)
    }

    @Test("CityData computes road length correctly")
    func testRoadLengthComputation() {
        var city = CityData()

        // Add road with 2 points (length = 0.1)
        let road1 = Road(path: [
            SIMD3(0, 0, 0),
            SIMD3(0.1, 0, 0)
        ])
        city.roads.append(road1)

        // Add road with 3 points (total length = 0.2)
        let road2 = Road(path: [
            SIMD3(0, 0, 0),
            SIMD3(0.1, 0, 0),
            SIMD3(0.2, 0, 0)
        ])
        city.roads.append(road2)

        #expect(city.roadLength > 0.29)  // Approximately 0.3
        #expect(city.roadLength < 0.31)
    }

    @Test("CityData is Codable")
    func testCodable() throws {
        let originalCity = CityData(name: "Codable City")

        // Encode
        let encoder = JSONEncoder()
        let data = try encoder.encode(originalCity)

        // Decode
        let decoder = JSONDecoder()
        let decodedCity = try decoder.decode(CityData.self, from: data)

        #expect(decodedCity.id == originalCity.id)
        #expect(decodedCity.name == originalCity.name)
    }
}

/// Unit tests for Building model
@Suite("Building Tests")
struct BuildingTests {

    @Test("Building initializes correctly")
    func testInitialization() {
        let building = Building(
            type: .residential(.smallHouse),
            position: SIMD3(0, 0, 0)
        )

        #expect(building.type.isResidential)
        #expect(building.position == SIMD3(0, 0, 0))
        #expect(building.level == 1)
        #expect(!building.isConstructed)
    }

    @Test("Building computes bounds correctly")
    func testBoundsComputation() {
        let smallHouse = Building(
            type: .residential(.smallHouse),
            position: SIMD3(0, 0, 0)
        )

        #expect(smallHouse.bounds == SIMD2(0.05, 0.05))
    }

    @Test("Building construction state")
    func testConstructionState() {
        var building = Building(
            type: .residential(.smallHouse),
            position: SIMD3(0, 0, 0)
        )

        #expect(!building.isConstructed)
        #expect(building.constructionProgress == 0.0)

        // Complete construction
        building.constructionProgress = 1.0
        building.isConstructed = true

        #expect(building.isConstructed)
    }

    @Test("BuildingType identifies residential correctly")
    func testResidentialType() {
        let type = BuildingType.residential(.smallHouse)

        #expect(type.isResidential)
        #expect(!type.isCommercial)
        #expect(!type.isIndustrial)
        #expect(!type.isInfrastructure)
    }

    @Test("BuildingType provides correct display name")
    func testBuildingTypeDisplayName() {
        let smallHouse = BuildingType.residential(.smallHouse)
        let office = BuildingType.commercial(.office)
        let factory = BuildingType.industrial(.smallFactory)
        let school = BuildingType.infrastructure(.school)

        #expect(smallHouse.displayName == "Small House")
        #expect(office.displayName == "Office Building")
        #expect(factory.displayName == "Small Factory")
        #expect(school.displayName == "School")
    }

    @Test("BuildingType provides correct base cost")
    func testBuildingTypeBaseCost() {
        let smallHouse = BuildingType.residential(.smallHouse)
        let tower = BuildingType.residential(.tower)

        #expect(smallHouse.baseCost == 1000)
        #expect(tower.baseCost == 20000)
        #expect(tower.baseCost > smallHouse.baseCost)
    }
}

/// Unit tests for Road model
@Suite("Road Tests")
struct RoadTests {

    @Test("Road initializes correctly")
    func testInitialization() {
        let road = Road(path: [
            SIMD3(0, 0, 0),
            SIMD3(0.1, 0, 0)
        ])

        #expect(road.path.count == 2)
        #expect(road.lanes == 2)
        #expect(road.connections.isEmpty)
    }

    @Test("Road computes length correctly for straight segment")
    func testStraightRoadLength() {
        let road = Road(path: [
            SIMD3(0, 0, 0),
            SIMD3(0.1, 0, 0)
        ])

        #expect(road.length > 0.09)
        #expect(road.length < 0.11)
    }

    @Test("Road computes length correctly for multi-segment path")
    func testMultiSegmentRoadLength() {
        let road = Road(path: [
            SIMD3(0, 0, 0),
            SIMD3(0.1, 0, 0),
            SIMD3(0.1, 0, 0.1)
        ])

        #expect(road.length > 0.19)
        #expect(road.length < 0.21)
    }

    @Test("RoadType provides correct width")
    func testRoadTypeWidth() {
        let dirt = RoadType.dirt
        let street = RoadType.street
        let highway = RoadType.highway

        #expect(dirt.width == 0.02)
        #expect(street.width == 0.03)
        #expect(highway.width == 0.08)
        #expect(highway.width > street.width)
    }
}

/// Unit tests for Citizen model
@Suite("Citizen Tests")
struct CitizenTests {

    @Test("Citizen initializes with default values")
    func testInitialization() {
        let citizen = Citizen(name: "Test Citizen", age: 30)

        #expect(citizen.name == "Test Citizen")
        #expect(citizen.age == 30)
        #expect(citizen.occupation == .unemployed)
        #expect(citizen.happiness == 0.75)
        #expect(citizen.currentActivity == .sleeping)
        #expect(citizen.home == nil)
        #expect(citizen.workplace == nil)
    }

    @Test("Citizen can be assigned home and workplace")
    func testHomeAndWorkplaceAssignment() {
        var citizen = Citizen(name: "Test Citizen", age: 30)

        let homeID = UUID()
        let workplaceID = UUID()

        citizen.home = homeID
        citizen.workplace = workplaceID

        #expect(citizen.home == homeID)
        #expect(citizen.workplace == workplaceID)
    }
}

/// Unit tests for Vehicle model
@Suite("Vehicle Tests")
struct VehicleTests {

    @Test("Vehicle initializes correctly")
    func testInitialization() {
        let vehicle = Vehicle(vehicleType: .car)

        #expect(vehicle.vehicleType == .car)
        #expect(vehicle.pathProgress == 0)
        #expect(vehicle.road == nil)
    }
}

/// Unit tests for EconomyState
@Suite("EconomyState Tests")
struct EconomyStateTests {

    @Test("EconomyState initializes with default values")
    func testInitialization() {
        let economy = EconomyState()

        #expect(economy.treasury == 50000)
        #expect(economy.taxRate == 0.05)
        #expect(economy.income == 0)
        #expect(economy.expenses == 0)
    }

    @Test("EconomyState computes net income correctly")
    func testNetIncomeComputation() {
        var economy = EconomyState()

        economy.income = 1000
        economy.expenses = 300

        #expect(economy.netIncome == 700)
    }

    @Test("EconomyState computes budget correctly")
    func testBudgetComputation() {
        let economy = EconomyState()

        #expect(economy.budget == economy.treasury)
    }
}

/// Unit tests for Statistics
@Suite("Statistics Tests")
struct StatisticsTests {

    @Test("Statistics initializes with default values")
    func testInitialization() {
        let stats = Statistics()

        #expect(stats.population == 0)
        #expect(stats.averageHappiness == 0.75)
        #expect(stats.pollution == 0)
        #expect(stats.crimeRate == 0)
    }
}

/// Unit tests for Zone
@Suite("Zone Tests")
struct ZoneTests {

    @Test("Zone initializes correctly")
    func testInitialization() {
        let zone = Zone(
            zoneType: .residential,
            area: [
                SIMD2(0, 0),
                SIMD2(0.1, 0),
                SIMD2(0.1, 0.1),
                SIMD2(0, 0.1)
            ]
        )

        #expect(zone.zoneType == .residential)
        #expect(zone.area.count == 4)
        #expect(zone.density == 0.5)
    }

    @Test("ZoneType provides correct display name")
    func testZoneTypeDisplayName() {
        let residential = ZoneType.residential
        let commercial = ZoneType.commercial
        let industrial = ZoneType.industrial

        #expect(residential.displayName == "Residential")
        #expect(commercial.displayName == "Commercial")
        #expect(industrial.displayName == "Industrial")
    }
}

/// Unit tests for Infrastructure
@Suite("Infrastructure Tests")
struct InfrastructureTests {

    @Test("Infrastructure initializes with default values")
    func testInitialization() {
        let infrastructure = Infrastructure()

        #expect(infrastructure.powerCapacity == 0)
        #expect(infrastructure.powerUsage == 0)
        #expect(infrastructure.waterCapacity == 0)
        #expect(infrastructure.waterUsage == 0)
    }

    @Test("Infrastructure correctly determines power availability")
    func testPowerAvailability() {
        var infrastructure = Infrastructure()

        infrastructure.powerCapacity = 100
        infrastructure.powerUsage = 50

        #expect(infrastructure.hasPower)

        infrastructure.powerUsage = 150

        #expect(!infrastructure.hasPower)
    }

    @Test("Infrastructure correctly determines water availability")
    func testWaterAvailability() {
        var infrastructure = Infrastructure()

        infrastructure.waterCapacity = 100
        infrastructure.waterUsage = 50

        #expect(infrastructure.hasWater)

        infrastructure.waterUsage = 150

        #expect(!infrastructure.hasWater)
    }
}
