//
//  PathfindingService.swift
//  MilitaryDefenseTraining
//
//  Created by Claude Code
//

import Foundation
import simd

actor PathfindingService {
    private var navMesh: NavigationMesh?
    private var obstacleMap: ObstacleMap?

    // MARK: - Navigation Mesh Setup

    func loadNavigationMesh(_ mesh: NavigationMesh) {
        self.navMesh = mesh
        self.obstacleMap = ObstacleMap(from: mesh)
    }

    // MARK: - A* Pathfinding

    func findPath(
        from start: SIMD3<Float>,
        to goal: SIMD3<Float>,
        avoidDanger: Bool = true
    ) async -> [SIMD3<Float>]? {
        guard let navMesh = navMesh else {
            // Fallback to direct path if no navmesh
            return [start, goal]
        }

        // Convert world positions to grid coordinates
        let startNode = worldToGrid(start)
        let goalNode = worldToGrid(goal)

        // Run A* algorithm
        guard let path = await aStarSearch(start: startNode, goal: goalNode, avoidDanger: avoidDanger) else {
            return nil
        }

        // Convert grid path back to world coordinates
        return path.map { gridToWorld($0) }
    }

    private func aStarSearch(
        start: GridNode,
        goal: GridNode,
        avoidDanger: Bool
    ) async -> [GridNode]? {
        var openSet: [GridNode] = [start]
        var closedSet: Set<GridNode> = []

        var gScore: [GridNode: Float] = [start: 0]
        var fScore: [GridNode: Float] = [start: heuristic(start, goal)]
        var cameFrom: [GridNode: GridNode] = [:]

        while !openSet.isEmpty {
            // Get node with lowest fScore
            guard let current = openSet.min(by: { fScore[$0] ?? Float.infinity < fScore[$1] ?? Float.infinity }) else {
                break
            }

            // Check if we reached goal
            if current == goal {
                return reconstructPath(cameFrom: cameFrom, current: current)
            }

            openSet.removeAll { $0 == current }
            closedSet.insert(current)

            // Check neighbors
            for neighbor in getNeighbors(current) {
                if closedSet.contains(neighbor) {
                    continue
                }

                // Skip if blocked
                if isBlocked(neighbor) {
                    continue
                }

                // Calculate tentative gScore
                let moveCost = calculateMoveCost(from: current, to: neighbor, avoidDanger: avoidDanger)
                let tentativeGScore = (gScore[current] ?? Float.infinity) + moveCost

                if tentativeGScore < (gScore[neighbor] ?? Float.infinity) {
                    cameFrom[neighbor] = current
                    gScore[neighbor] = tentativeGScore
                    fScore[neighbor] = tentativeGScore + heuristic(neighbor, goal)

                    if !openSet.contains(neighbor) {
                        openSet.append(neighbor)
                    }
                }
            }
        }

        return nil // No path found
    }

    private func heuristic(_ a: GridNode, _ b: GridNode) -> Float {
        // Manhattan distance heuristic
        let dx = abs(Float(a.x - b.x))
        let dy = abs(Float(a.y - b.y))
        let dz = abs(Float(a.z - b.z))
        return dx + dy + dz
    }

    private func getNeighbors(_ node: GridNode) -> [GridNode] {
        var neighbors: [GridNode] = []

        // 8 directions (+ diagonal) on XZ plane
        let directions: [(Int, Int, Int)] = [
            (1, 0, 0), (-1, 0, 0),   // East, West
            (0, 0, 1), (0, 0, -1),   // North, South
            (1, 0, 1), (-1, 0, 1),   // NE, NW
            (1, 0, -1), (-1, 0, -1), // SE, SW
            (0, 1, 0), (0, -1, 0)    // Up, Down
        ]

        for (dx, dy, dz) in directions {
            let neighbor = GridNode(
                x: node.x + dx,
                y: node.y + dy,
                z: node.z + dz
            )
            neighbors.append(neighbor)
        }

        return neighbors
    }

    private func calculateMoveCost(
        from: GridNode,
        to: GridNode,
        avoidDanger: Bool
    ) -> Float {
        var cost: Float = 1.0

        // Diagonal movement costs more
        let dx = abs(to.x - from.x)
        let dz = abs(to.z - from.z)
        if dx > 0 && dz > 0 {
            cost = 1.414 // sqrt(2)
        }

        // Vertical movement costs more
        if to.y != from.y {
            cost += 0.5
        }

        // Add danger penalty if avoiding danger zones
        if avoidDanger {
            cost += getDangerLevel(at: to) * 5.0
        }

        // Add cover bonus (negative cost for positions with cover)
        let coverBonus = getCoverValue(at: to)
        cost -= coverBonus * 0.3

        return max(cost, 0.1) // Minimum cost
    }

    private func reconstructPath(
        cameFrom: [GridNode: GridNode],
        current: GridNode
    ) -> [GridNode] {
        var path: [GridNode] = [current]
        var currentNode = current

        while let previous = cameFrom[currentNode] {
            path.insert(previous, at: 0)
            currentNode = previous
        }

        return smoothPath(path)
    }

    private func smoothPath(_ path: [GridNode]) -> [GridNode] {
        guard path.count > 2 else { return path }

        var smoothedPath: [GridNode] = [path[0]]
        var currentIndex = 0

        while currentIndex < path.count - 1 {
            var furthestVisible = currentIndex + 1

            // Find furthest node we can see from current
            for i in (currentIndex + 2)..<path.count {
                if hasLineOfSight(from: path[currentIndex], to: path[i]) {
                    furthestVisible = i
                } else {
                    break
                }
            }

            smoothedPath.append(path[furthestVisible])
            currentIndex = furthestVisible
        }

        return smoothedPath
    }

    private func hasLineOfSight(from: GridNode, to: GridNode) -> Bool {
        // Bresenham-like line check
        let steps = max(
            abs(to.x - from.x),
            abs(to.y - from.y),
            abs(to.z - from.z)
        )

        for step in 0...steps {
            let t = Float(step) / Float(steps)
            let x = Int(Float(from.x) + Float(to.x - from.x) * t)
            let y = Int(Float(from.y) + Float(to.y - from.y) * t)
            let z = Int(Float(from.z) + Float(to.z - from.z) * t)

            if isBlocked(GridNode(x: x, y: y, z: z)) {
                return false
            }
        }

        return true
    }

    // MARK: - Grid Utilities

    private func worldToGrid(_ position: SIMD3<Float>) -> GridNode {
        let gridSize: Float = 1.0 // 1 meter per grid cell

        return GridNode(
            x: Int(position.x / gridSize),
            y: Int(position.y / gridSize),
            z: Int(position.z / gridSize)
        )
    }

    private func gridToWorld(_ node: GridNode) -> SIMD3<Float> {
        let gridSize: Float = 1.0

        return SIMD3<Float>(
            Float(node.x) * gridSize,
            Float(node.y) * gridSize,
            Float(node.z) * gridSize
        )
    }

    private func isBlocked(_ node: GridNode) -> Bool {
        guard let obstacleMap = obstacleMap else { return false }
        return obstacleMap.isObstacle(at: node)
    }

    private func getDangerLevel(at node: GridNode) -> Float {
        // Check for danger zones (sniper lines, IEDs, etc.)
        // For now, return 0
        return 0.0
    }

    private func getCoverValue(at node: GridNode) -> Float {
        // Check if position has cover nearby
        // Higher value = better cover
        // For now, return 0
        return 0.0
    }

    // MARK: - Tactical Pathfinding

    func findCoverPath(
        from start: SIMD3<Float>,
        to goal: SIMD3<Float>,
        enemyPositions: [SIMD3<Float>]
    ) async -> [SIMD3<Float>]? {
        // Find path that maximizes cover from enemy positions
        // This uses modified A* with danger zones around enemies

        let startNode = worldToGrid(start)
        let goalNode = worldToGrid(goal)

        // Mark danger zones around enemies
        for enemyPos in enemyPositions {
            let enemyNode = worldToGrid(enemyPos)
            markDangerZone(around: enemyNode, radius: 30)
        }

        let path = await aStarSearch(start: startNode, goal: goalNode, avoidDanger: true)

        // Clear danger zones
        clearDangerZones()

        return path?.map { gridToWorld($0) }
    }

    func findFlankingPath(
        from start: SIMD3<Float>,
        targetEnemy: SIMD3<Float>,
        flankDirection: FlankDirection
    ) async -> [SIMD3<Float>]? {
        // Find path that approaches enemy from the side

        let enemyNode = worldToGrid(targetEnemy)
        let offset: Int = 10 // 10 meters to the side

        let goalNode: GridNode
        switch flankDirection {
        case .left:
            goalNode = GridNode(x: enemyNode.x - offset, y: enemyNode.y, z: enemyNode.z)
        case .right:
            goalNode = GridNode(x: enemyNode.x + offset, y: enemyNode.y, z: enemyNode.z)
        }

        return await findPath(from: start, to: gridToWorld(goalNode))
    }

    private func markDangerZone(around center: GridNode, radius: Int) {
        // Mark grid cells in radius as dangerous
        // In real implementation, would update obstacleMap
    }

    private func clearDangerZones() {
        // Clear all danger zone markings
    }

    // MARK: - Cover Points

    func findNearestCover(from position: SIMD3<Float>, maxDistance: Float = 20.0) async -> SIMD3<Float>? {
        let startNode = worldToGrid(position)
        let searchRadius = Int(maxDistance)

        var bestCover: GridNode?
        var bestCoverValue: Float = 0

        // Search in radius for best cover
        for x in (startNode.x - searchRadius)...(startNode.x + searchRadius) {
            for z in (startNode.z - searchRadius)...(startNode.z + searchRadius) {
                let node = GridNode(x: x, y: startNode.y, z: z)
                let coverValue = getCoverValue(at: node)

                if coverValue > bestCoverValue && !isBlocked(node) {
                    bestCoverValue = coverValue
                    bestCover = node
                }
            }
        }

        return bestCover.map { gridToWorld($0) }
    }
}

// MARK: - Supporting Types

struct GridNode: Hashable, Equatable {
    var x: Int
    var y: Int
    var z: Int

    static func == (lhs: GridNode, rhs: GridNode) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y && lhs.z == rhs.z
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(x)
        hasher.combine(y)
        hasher.combine(z)
    }
}

struct NavigationMesh {
    var bounds: Bounds
    var obstacles: [Obstacle]
    var coverPoints: [CoverPoint]

    struct Bounds {
        var min: SIMD3<Float>
        var max: SIMD3<Float>
        var gridSize: Float = 1.0
    }

    struct Obstacle {
        var position: SIMD3<Float>
        var size: SIMD3<Float>
        var type: ObstacleType

        enum ObstacleType {
            case wall
            case building
            case vehicle
            case debris
        }
    }

    struct CoverPoint {
        var position: SIMD3<Float>
        var coverDirection: SIMD3<Float> // Direction cover faces
        var coverQuality: CoverQuality

        enum CoverQuality {
            case full
            case partial
            case concealment
        }
    }
}

class ObstacleMap {
    private var blockedCells: Set<GridNode> = []

    init(from navMesh: NavigationMesh) {
        // Convert obstacles to blocked grid cells
        for obstacle in navMesh.obstacles {
            let center = GridNode(
                x: Int(obstacle.position.x),
                y: Int(obstacle.position.y),
                z: Int(obstacle.position.z)
            )

            let halfSize = obstacle.size / 2.0
            let minNode = GridNode(
                x: Int(obstacle.position.x - halfSize.x),
                y: Int(obstacle.position.y - halfSize.y),
                z: Int(obstacle.position.z - halfSize.z)
            )
            let maxNode = GridNode(
                x: Int(obstacle.position.x + halfSize.x),
                y: Int(obstacle.position.y + halfSize.y),
                z: Int(obstacle.position.z + halfSize.z)
            )

            for x in minNode.x...maxNode.x {
                for y in minNode.y...maxNode.y {
                    for z in minNode.z...maxNode.z {
                        blockedCells.insert(GridNode(x: x, y: y, z: z))
                    }
                }
            }
        }
    }

    func isObstacle(at node: GridNode) -> Bool {
        return blockedCells.contains(node)
    }

    func markBlocked(_ node: GridNode) {
        blockedCells.insert(node)
    }

    func clearBlocked(_ node: GridNode) {
        blockedCells.remove(node)
    }
}

enum FlankDirection {
    case left
    case right
}
