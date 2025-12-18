import Foundation
import simd

/// Manages road construction, path smoothing, and intersection handling
final class RoadConstructionSystem {
    // MARK: - Properties

    /// Minimum distance between road points for smoothing
    let minPointDistance: Float = 0.02  // 2cm

    /// Intersection detection threshold
    let intersectionThreshold: Float = 0.03  // 3cm

    /// Maximum curve segments for Bezier smoothing
    let maxCurveSegments: Int = 20

    // MARK: - Public Methods

    /// Create a road from a series of points
    /// - Parameters:
    ///   - points: Raw points from user input
    ///   - type: Type of road to create
    /// - Returns: A new road with smoothed path
    func createRoad(from points: [SIMD3<Float>], type: RoadType = .street) -> Road? {
        guard points.count >= 2 else { return nil }

        // Filter out points that are too close together
        let filteredPoints = filterClosePoints(points)

        guard filteredPoints.count >= 2 else { return nil }

        // Smooth the path using Catmull-Rom spline
        let smoothedPath = smoothPath(filteredPoints)

        // Determine number of lanes based on road type
        let lanes = lanesForRoadType(type)

        // Calculate traffic capacity
        let capacity = calculateTrafficCapacity(length: pathLength(smoothedPath), lanes: lanes)

        return Road(
            type: type,
            path: smoothedPath,
            lanes: lanes,
            trafficCapacity: capacity
        )
    }

    /// Detect intersections between a new road and existing roads
    /// - Parameters:
    ///   - newRoad: The road being placed
    ///   - existingRoads: Array of existing roads
    /// - Returns: Array of intersection points and road IDs
    func detectIntersections(
        newRoad: Road,
        existingRoads: [Road]
    ) -> [(point: SIMD3<Float>, roadId: UUID)] {
        var intersections: [(point: SIMD3<Float>, roadId: UUID)] = []

        for existingRoad in existingRoads {
            // Check each segment of new road against each segment of existing road
            for i in 0..<(newRoad.path.count - 1) {
                let newStart = newRoad.path[i]
                let newEnd = newRoad.path[i + 1]

                for j in 0..<(existingRoad.path.count - 1) {
                    let existingStart = existingRoad.path[j]
                    let existingEnd = existingRoad.path[j + 1]

                    if let intersection = lineSegmentIntersection(
                        p1: newStart, p2: newEnd,
                        p3: existingStart, p4: existingEnd
                    ) {
                        intersections.append((intersection, existingRoad.id))
                    }
                }
            }
        }

        return intersections
    }

    /// Add a road to the city and create intersections
    /// - Parameters:
    ///   - road: The road to add
    ///   - city: The current city data (mutable)
    /// - Returns: The added road with updated connections
    @discardableResult
    func addRoadToCity(road: Road, city: inout CityData) -> Road {
        var updatedRoad = road

        // Detect intersections with existing roads
        let intersections = detectIntersections(newRoad: road, existingRoads: city.roads)

        // Update connections
        for (_, roadId) in intersections {
            updatedRoad.connections.append(roadId)

            // Update the existing road's connections
            if let index = city.roads.firstIndex(where: { $0.id == roadId }) {
                city.roads[index].connections.append(updatedRoad.id)
            }
        }

        city.roads.append(updatedRoad)
        return updatedRoad
    }

    /// Validate if a road can be built
    /// - Parameters:
    ///   - points: Road path points
    ///   - city: Current city data
    /// - Returns: True if road is valid
    func canBuildRoad(points: [SIMD3<Float>], city: CityData) -> Bool {
        guard points.count >= 2 else { return false }

        // Check all points are within terrain bounds
        let halfSize = city.surfaceSize / 2
        for point in points {
            if point.x < -halfSize.x || point.x > halfSize.x ||
               point.z < -halfSize.y || point.z > halfSize.y {
                return false
            }
        }

        return true
    }

    // MARK: - Private Methods

    /// Filter out points that are too close together
    private func filterClosePoints(_ points: [SIMD3<Float>]) -> [SIMD3<Float>] {
        guard points.count > 1 else { return points }

        var filtered: [SIMD3<Float>] = [points[0]]

        for i in 1..<points.count {
            let distance = simd_distance(filtered.last!, points[i])
            if distance >= minPointDistance {
                filtered.append(points[i])
            }
        }

        return filtered
    }

    /// Smooth path using Catmull-Rom spline
    private func smoothPath(_ points: [SIMD3<Float>]) -> [SIMD3<Float>] {
        guard points.count >= 2 else { return points }

        // For very short paths, return as-is
        if points.count == 2 {
            return points
        }

        var smoothed: [SIMD3<Float>] = []

        // Add first point
        smoothed.append(points[0])

        // Generate smooth curve between each pair of points
        for i in 0..<(points.count - 1) {
            let p0 = i > 0 ? points[i - 1] : points[i]
            let p1 = points[i]
            let p2 = points[i + 1]
            let p3 = i < points.count - 2 ? points[i + 2] : points[i + 1]

            // Generate curve segments
            let segments = 5
            for t in 1...segments {
                let u = Float(t) / Float(segments)
                let point = catmullRomSpline(p0: p0, p1: p1, p2: p2, p3: p3, t: u)
                smoothed.append(point)
            }
        }

        return smoothed
    }

    /// Catmull-Rom spline interpolation
    private func catmullRomSpline(
        p0: SIMD3<Float>,
        p1: SIMD3<Float>,
        p2: SIMD3<Float>,
        p3: SIMD3<Float>,
        t: Float
    ) -> SIMD3<Float> {
        let t2 = t * t
        let t3 = t2 * t

        let v0 = (p2 - p0) * 0.5
        let v1 = (p3 - p1) * 0.5

        // Break up complex expression to help compiler
        let a = (2 * p1 - 2 * p2 + v0 + v1) * t3
        let b = (-3 * p1 + 3 * p2 - 2 * v0 - v1) * t2
        let c = v0 * t
        return a + b + c + p1
    }

    /// Calculate path length
    private func pathLength(_ path: [SIMD3<Float>]) -> Float {
        guard path.count > 1 else { return 0 }

        var length: Float = 0
        for i in 0..<(path.count - 1) {
            length += simd_distance(path[i], path[i + 1])
        }
        return length
    }

    /// Get number of lanes for road type
    private func lanesForRoadType(_ type: RoadType) -> Int {
        switch type {
        case .dirt: return 1
        case .street: return 2
        case .avenue: return 4
        case .highway: return 6
        }
    }

    /// Calculate traffic capacity based on road parameters
    private func calculateTrafficCapacity(length: Float, lanes: Int) -> Int {
        // Capacity = lanes * 50 vehicles per lane per 100m
        let capacityPerMeter = Float(lanes) * 0.5
        return Int(length * capacityPerMeter)
    }

    /// Find intersection point of two line segments (2D in XZ plane)
    private func lineSegmentIntersection(
        p1: SIMD3<Float>, p2: SIMD3<Float>,
        p3: SIMD3<Float>, p4: SIMD3<Float>
    ) -> SIMD3<Float>? {
        // Convert to 2D (XZ plane)
        let x1 = p1.x, z1 = p1.z
        let x2 = p2.x, z2 = p2.z
        let x3 = p3.x, z3 = p3.z
        let x4 = p4.x, z4 = p4.z

        let denom = (x1 - x2) * (z3 - z4) - (z1 - z2) * (x3 - x4)

        // Parallel or coincident
        if abs(denom) < 0.0001 {
            return nil
        }

        let t = ((x1 - x3) * (z3 - z4) - (z1 - z3) * (x3 - x4)) / denom
        let u = -((x1 - x2) * (z1 - z3) - (z1 - z2) * (x1 - x3)) / denom

        // Check if intersection is within both segments
        if t >= 0 && t <= 1 && u >= 0 && u <= 1 {
            let x = x1 + t * (x2 - x1)
            let z = z1 + t * (z2 - z1)
            let y = (p1.y + p2.y) / 2  // Average Y

            return SIMD3(x, y, z)
        }

        return nil
    }

    /// Build a road graph for pathfinding
    func buildRoadGraph(roads: [Road]) -> RoadGraph {
        return RoadGraph(roads: roads)
    }
}

// MARK: - Road Graph

/// Graph structure for road network pathfinding
struct RoadGraph {
    let roads: [Road]
    private var adjacency: [UUID: [UUID]] = [:]

    init(roads: [Road]) {
        self.roads = roads
        buildAdjacencyList()
    }

    private mutating func buildAdjacencyList() {
        for road in roads {
            adjacency[road.id] = road.connections
        }
    }

    /// Find shortest path between two roads using Dijkstra's algorithm
    func shortestPath(from startId: UUID, to endId: UUID) -> [UUID]? {
        guard roads.contains(where: { $0.id == startId }),
              roads.contains(where: { $0.id == endId }) else {
            return nil
        }

        var distances: [UUID: Float] = [:]
        var previous: [UUID: UUID] = [:]
        var unvisited: Set<UUID> = Set(roads.map { $0.id })

        // Initialize distances
        for road in roads {
            distances[road.id] = road.id == startId ? 0 : .infinity
        }

        while !unvisited.isEmpty {
            // Find unvisited node with minimum distance
            guard let current = unvisited.min(by: { distances[$0]! < distances[$1]! }) else {
                break
            }

            if current == endId {
                break
            }

            unvisited.remove(current)

            // Update neighbors
            if let neighbors = adjacency[current] {
                for neighbor in neighbors {
                    if unvisited.contains(neighbor) {
                        let road = roads.first { $0.id == current }
                        let alt = distances[current]! + (road?.length ?? 0)

                        if alt < distances[neighbor]! {
                            distances[neighbor] = alt
                            previous[neighbor] = current
                        }
                    }
                }
            }
        }

        // Reconstruct path
        var path: [UUID] = []
        var current: UUID? = endId

        while let curr = current {
            path.insert(curr, at: 0)
            current = previous[curr]
        }

        return path.first == startId ? path : nil
    }
}
