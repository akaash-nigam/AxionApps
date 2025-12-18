import Testing
import Foundation
@testable import CityBuilderTabletop

/// Unit tests for BuildingPlacementSystem
@Suite("BuildingPlacementSystem Tests")
struct BuildingPlacementSystemTests {

    @Test("Snap to grid works correctly")
    func testSnapToGrid() {
        let system = BuildingPlacementSystem()

        // Test snapping to nearest grid point
        let position1 = SIMD3<Float>(0.02, 0, 0.02)
        let snapped1 = system.snapToGrid(position1)

        #expect(snapped1.x == 0.0)
        #expect(snapped1.z == 0.0)

        // Test snapping with larger offset
        let position2 = SIMD3<Float>(0.08, 0, 0.08)
        let snapped2 = system.snapToGrid(position2)

        #expect(snapped2.x >= 0.09)
        #expect(snapped2.x <= 0.11)
    }

    @Test("Can place building in empty city")
    func testCanPlaceBuildingEmptyCity() {
        let system = BuildingPlacementSystem()
        let city = CityData()

        let canPlace = system.canPlaceBuilding(
            at: SIMD3(0, 0, 0),
            type: .residential(.smallHouse),
            cityData: city
        )

        #expect(canPlace)
    }

    @Test("Cannot place building overlapping existing building")
    func testCannotPlaceOverlappingBuilding() {
        let system = BuildingPlacementSystem()
        var city = CityData()

        // Add existing building
        let existing = Building(
            type: .residential(.smallHouse),
            position: SIMD3(0, 0, 0)
        )
        city.buildings.append(existing)

        // Try to place at same location
        let canPlace = system.canPlaceBuilding(
            at: SIMD3(0, 0, 0),
            type: .residential(.smallHouse),
            cityData: city
        )

        #expect(!canPlace)
    }

    @Test("Cannot place building outside terrain bounds")
    func testCannotPlaceOutsideBounds() {
        let system = BuildingPlacementSystem()
        let city = CityData(surfaceSize: SIMD2(1.0, 1.0))

        // Try to place way outside bounds
        let canPlace = system.canPlaceBuilding(
            at: SIMD3(10, 0, 10),
            type: .residential(.smallHouse),
            cityData: city
        )

        #expect(!canPlace)
    }

    @Test("Cannot place building without road access when roads exist")
    func testCannotPlaceWithoutRoadAccess() {
        let system = BuildingPlacementSystem()
        var city = CityData()

        // Add a road far away
        let road = Road(path: [
            SIMD3(-0.5, 0, -0.5),
            SIMD3(-0.4, 0, -0.5)
        ])
        city.roads.append(road)

        // Try to place building far from road
        let canPlace = system.canPlaceBuilding(
            at: SIMD3(0.5, 0, 0.5),
            type: .residential(.smallHouse),
            cityData: city
        )

        #expect(!canPlace)
    }

    @Test("Can place building with road access")
    func testCanPlaceWithRoadAccess() {
        let system = BuildingPlacementSystem()
        var city = CityData()

        // Add a road nearby
        let road = Road(path: [
            SIMD3(0, 0, 0),
            SIMD3(0.1, 0, 0)
        ])
        city.roads.append(road)

        // Try to place building near road
        let canPlace = system.canPlaceBuilding(
            at: SIMD3(0.05, 0, 0.1),
            type: .residential(.smallHouse),
            cityData: city
        )

        #expect(canPlace)
    }

    @Test("Zone compatibility - residential in residential zone")
    func testZoneCompatibilityResidential() {
        let system = BuildingPlacementSystem()
        var city = CityData()

        // Create residential zone
        let zone = Zone(
            zoneType: .residential,
            area: [
                SIMD2(-0.2, -0.2),
                SIMD2(0.2, -0.2),
                SIMD2(0.2, 0.2),
                SIMD2(-0.2, 0.2)
            ]
        )
        city.zones.append(zone)

        // Should be able to place residential in residential zone
        let canPlace = system.canPlaceBuilding(
            at: SIMD3(0, 0, 0),
            type: .residential(.smallHouse),
            cityData: city
        )

        #expect(canPlace)
    }

    @Test("Zone incompatibility - residential in industrial zone")
    func testZoneIncompatibilityResidential() {
        let system = BuildingPlacementSystem()
        var city = CityData()

        // Create industrial zone
        let zone = Zone(
            zoneType: .industrial,
            area: [
                SIMD2(-0.2, -0.2),
                SIMD2(0.2, -0.2),
                SIMD2(0.2, 0.2),
                SIMD2(-0.2, 0.2)
            ]
        )
        city.zones.append(zone)

        // Should NOT be able to place residential in industrial zone
        let canPlace = system.canPlaceBuilding(
            at: SIMD3(0, 0, 0),
            type: .residential(.smallHouse),
            cityData: city
        )

        #expect(!canPlace)
    }

    @Test("Infrastructure can be placed in any zone")
    func testInfrastructureInAnyZone() {
        let system = BuildingPlacementSystem()
        var city = CityData()

        // Create commercial zone
        let zone = Zone(
            zoneType: .commercial,
            area: [
                SIMD2(-0.2, -0.2),
                SIMD2(0.2, -0.2),
                SIMD2(0.2, 0.2),
                SIMD2(-0.2, 0.2)
            ]
        )
        city.zones.append(zone)

        // Infrastructure should be placeable anywhere
        let canPlace = system.canPlaceBuilding(
            at: SIMD3(0, 0, 0),
            type: .infrastructure(.school),
            cityData: city
        )

        #expect(canPlace)
    }

    @Test("Create building returns valid building when placement is valid")
    func testCreateBuildingValid() {
        let system = BuildingPlacementSystem()
        let city = CityData()

        let building = system.createBuilding(
            type: .residential(.smallHouse),
            at: SIMD3(0, 0, 0),
            cityData: city
        )

        #expect(building != nil)
        #expect(building?.type.isResidential == true)
        #expect(building?.constructionProgress == 0.0)
        #expect(building?.capacity == 4)  // Small house capacity
    }

    @Test("Create building returns nil when placement is invalid")
    func testCreateBuildingInvalid() {
        let system = BuildingPlacementSystem()
        let city = CityData(surfaceSize: SIMD2(1.0, 1.0))

        // Try to create building outside bounds
        let building = system.createBuilding(
            type: .residential(.smallHouse),
            at: SIMD3(10, 0, 10),
            cityData: city
        )

        #expect(building == nil)
    }

    @Test("Created building has correct capacity")
    func testBuildingCapacity() {
        let system = BuildingPlacementSystem()
        let city = CityData()

        let smallHouse = system.createBuilding(
            type: .residential(.smallHouse),
            at: SIMD3(0, 0, 0),
            cityData: city
        )

        let apartment = system.createBuilding(
            type: .residential(.apartment),
            at: SIMD3(0.2, 0, 0),
            cityData: city
        )

        #expect(smallHouse?.capacity == 4)
        #expect(apartment?.capacity == 24)
        #expect((apartment?.capacity ?? 0) > (smallHouse?.capacity ?? 0))
    }

    @Test("Can place buildings next to each other without overlap")
    func testPlaceBuildingsAdjacent() {
        let system = BuildingPlacementSystem()
        var city = CityData()

        // Place first building
        let building1 = system.createBuilding(
            type: .residential(.smallHouse),
            at: SIMD3(0, 0, 0),
            cityData: city
        )
        #expect(building1 != nil)

        if let building1 = building1 {
            city.buildings.append(building1)

            // Place second building at safe distance
            let canPlace = system.canPlaceBuilding(
                at: SIMD3(0.15, 0, 0),
                type: .residential(.smallHouse),
                cityData: city
            )

            #expect(canPlace)
        }
    }

    @Test("Cannot place building too close to existing building")
    func testCannotPlaceBuildingTooClose() {
        let system = BuildingPlacementSystem()
        var city = CityData()

        // Place first building
        let building1 = system.createBuilding(
            type: .residential(.smallHouse),
            at: SIMD3(0, 0, 0),
            cityData: city
        )
        #expect(building1 != nil)

        if let building1 = building1 {
            city.buildings.append(building1)

            // Try to place second building too close
            let canPlace = system.canPlaceBuilding(
                at: SIMD3(0.02, 0, 0),
                type: .residential(.smallHouse),
                cityData: city
            )

            #expect(!canPlace)
        }
    }
}
