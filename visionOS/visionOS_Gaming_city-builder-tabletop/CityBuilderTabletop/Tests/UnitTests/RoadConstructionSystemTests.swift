import Testing
import Foundation
@testable import CityBuilderTabletop

/// Unit tests for RoadConstructionSystem
@Suite("RoadConstructionSystem Tests")
struct RoadConstructionSystemTests {

    @Test("Create road from two points")
    func testCreateRoadTwoPoints() {
        let system = RoadConstructionSystem()

        let points = [
            SIMD3<Float>(0, 0, 0),
            SIMD3<Float>(0.1, 0, 0)
        ]

        let road = system.createRoad(from: points)

        #expect(road != nil)
        #expect(road!.path.count >= 2)
        #expect(road!.lanes == 2)  // Default street has 2 lanes
    }

    @Test("Create road from multiple points")
    func testCreateRoadMultiplePoints() {
        let system = RoadConstructionSystem()

        let points = [
            SIMD3<Float>(0, 0, 0),
            SIMD3<Float>(0.1, 0, 0),
            SIMD3<Float>(0.2, 0, 0.1),
            SIMD3<Float>(0.3, 0, 0.1)
        ]

        let road = system.createRoad(from: points)

        #expect(road != nil)
        #expect(road!.path.count > points.count)  // Smoothing adds points
    }

    @Test("Cannot create road from single point")
    func testCannotCreateRoadSinglePoint() {
        let system = RoadConstructionSystem()

        let points = [SIMD3<Float>(0, 0, 0)]

        let road = system.createRoad(from: points)

        #expect(road == nil)
    }

    @Test("Road type affects lane count")
    func testRoadTypeLanes() {
        let system = RoadConstructionSystem()

        let points = [
            SIMD3<Float>(0, 0, 0),
            SIMD3<Float>(0.1, 0, 0)
        ]

        let dirt = system.createRoad(from: points, type: .dirt)
        let street = system.createRoad(from: points, type: .street)
        let avenue = system.createRoad(from: points, type: .avenue)
        let highway = system.createRoad(from: points, type: .highway)

        #expect(dirt?.lanes == 1)
        #expect(street?.lanes == 2)
        #expect(avenue?.lanes == 4)
        #expect(highway?.lanes == 6)
    }

    @Test("Road has traffic capacity")
    func testRoadTrafficCapacity() {
        let system = RoadConstructionSystem()

        let points = [
            SIMD3<Float>(0, 0, 0),
            SIMD3<Float>(1, 0, 0)  // 1 meter long
        ]

        let road = system.createRoad(from: points)

        #expect(road != nil)
        #expect(road!.trafficCapacity > 0)
    }

    @Test("Detect intersection between crossing roads")
    func testDetectIntersection() {
        let system = RoadConstructionSystem()

        // Create horizontal road
        let road1 = Road(path: [
            SIMD3<Float>(-0.1, 0, 0),
            SIMD3<Float>(0.1, 0, 0)
        ])

        // Create vertical road that crosses it
        let road2 = Road(path: [
            SIMD3<Float>(0, 0, -0.1),
            SIMD3<Float>(0, 0, 0.1)
        ])

        let intersections = system.detectIntersections(newRoad: road2, existingRoads: [road1])

        #expect(intersections.count > 0)

        if let intersection = intersections.first {
            #expect(abs(intersection.point.x) < 0.01)
            #expect(abs(intersection.point.z) < 0.01)
        }
    }

    @Test("No intersection for parallel roads")
    func testNoIntersectionParallel() {
        let system = RoadConstructionSystem()

        let road1 = Road(path: [
            SIMD3<Float>(0, 0, 0),
            SIMD3<Float>(0.1, 0, 0)
        ])

        let road2 = Road(path: [
            SIMD3<Float>(0, 0, 0.05),
            SIMD3<Float>(0.1, 0, 0.05)
        ])

        let intersections = system.detectIntersections(newRoad: road2, existingRoads: [road1])

        #expect(intersections.isEmpty)
    }

    @Test("Add road to city creates connections")
    func testAddRoadToCity() {
        let system = RoadConstructionSystem()
        var city = CityData()

        // Add first road
        let road1 = Road(path: [
            SIMD3<Float>(-0.1, 0, 0),
            SIMD3<Float>(0.1, 0, 0)
        ])
        city.roads.append(road1)

        // Add intersecting road
        let road2 = Road(path: [
            SIMD3<Float>(0, 0, -0.1),
            SIMD3<Float>(0, 0, 0.1)
        ])

        let addedRoad = system.addRoadToCity(road: road2, city: &city)

        #expect(city.roads.count == 2)
        #expect(!addedRoad.connections.isEmpty)
        #expect(addedRoad.connections.contains(road1.id))
        #expect(city.roads[0].connections.contains(addedRoad.id))
    }

    @Test("Can build road within bounds")
    func testCanBuildRoadWithinBounds() {
        let system = RoadConstructionSystem()
        let city = CityData(surfaceSize: SIMD2(1.0, 1.0))

        let points = [
            SIMD3<Float>(0, 0, 0),
            SIMD3<Float>(0.2, 0, 0.2)
        ]

        let canBuild = system.canBuildRoad(points: points, city: city)

        #expect(canBuild)
    }

    @Test("Cannot build road outside bounds")
    func testCannotBuildRoadOutsideBounds() {
        let system = RoadConstructionSystem()
        let city = CityData(surfaceSize: SIMD2(1.0, 1.0))

        let points = [
            SIMD3<Float>(0, 0, 0),
            SIMD3<Float>(10, 0, 10)  // Way outside
        ]

        let canBuild = system.canBuildRoad(points: points, city: city)

        #expect(!canBuild)
    }

    @Test("Road graph finds shortest path")
    func testRoadGraphShortestPath() {
        let road1 = Road(id: UUID(), path: [SIMD3(0, 0, 0), SIMD3(0.1, 0, 0)])
        let road2 = Road(id: UUID(), path: [SIMD3(0.1, 0, 0), SIMD3(0.2, 0, 0)])
        let road3 = Road(id: UUID(), path: [SIMD3(0.2, 0, 0), SIMD3(0.3, 0, 0)])

        var roads = [road1, road2, road3]
        roads[0].connections = [road2.id]
        roads[1].connections = [road1.id, road3.id]
        roads[2].connections = [road2.id]

        let system = RoadConstructionSystem()
        let graph = system.buildRoadGraph(roads: roads)

        let path = graph.shortestPath(from: road1.id, to: road3.id)

        #expect(path != nil)
        #expect(path!.count == 3)
        #expect(path!.first == road1.id)
        #expect(path!.last == road3.id)
    }

    @Test("Smoothed road has more points than input")
    func testRoadSmoothing() {
        let system = RoadConstructionSystem()

        let points = [
            SIMD3<Float>(0, 0, 0),
            SIMD3<Float>(0.1, 0, 0),
            SIMD3<Float>(0.2, 0, 0.1)
        ]

        let road = system.createRoad(from: points)

        #expect(road != nil)
        #expect(road!.path.count > points.count)
    }

    @Test("Filters out points that are too close")
    func testFilterClosePoints() {
        let system = RoadConstructionSystem()

        // Points very close together
        let points = [
            SIMD3<Float>(0, 0, 0),
            SIMD3<Float>(0.001, 0, 0),  // Too close
            SIMD3<Float>(0.002, 0, 0),  // Too close
            SIMD3<Float>(0.1, 0, 0)     // Far enough
        ]

        let road = system.createRoad(from: points)

        #expect(road != nil)
        // Should filter out the very close points
        #expect(road!.path.count < points.count * 5)  // Accounting for smoothing
    }
}
