//
//  SpatialLayoutEngine.swift
//  BusinessOperatingSystem
//
//  Created by BOS Team on 2025-01-20.
//

import Foundation
import simd

// MARK: - Octree Node for Barnes-Hut Algorithm

/// Octree node for spatial partitioning - enables O(n log n) force calculations
final class OctreeNode {
    let center: SIMD3<Float>
    let halfSize: Float

    var totalMass: Float = 0
    var centerOfMass: SIMD3<Float> = .zero
    var entity: UUID?
    var entityPosition: SIMD3<Float>?
    var children: [OctreeNode?] = Array(repeating: nil, count: 8)
    var isLeaf: Bool { entity != nil || children.allSatisfy { $0 == nil } }

    init(center: SIMD3<Float>, halfSize: Float) {
        self.center = center
        self.halfSize = halfSize
    }

    /// Insert an entity into the octree
    func insert(entity: UUID, position: SIMD3<Float>, mass: Float = 1.0) {
        // Update center of mass
        let newTotalMass = totalMass + mass
        centerOfMass = (centerOfMass * totalMass + position * mass) / newTotalMass
        totalMass = newTotalMass

        // If this is an empty leaf, store the entity here
        if self.entity == nil && isLeaf {
            self.entity = entity
            self.entityPosition = position
            return
        }

        // If this leaf already has an entity, we need to subdivide
        if let existingEntity = self.entity, let existingPos = self.entityPosition {
            self.entity = nil
            self.entityPosition = nil
            insertIntoChild(entity: existingEntity, position: existingPos, mass: 1.0)
        }

        // Insert the new entity into the appropriate child
        insertIntoChild(entity: entity, position: position, mass: mass)
    }

    private func insertIntoChild(entity: UUID, position: SIMD3<Float>, mass: Float) {
        let childIndex = octantIndex(for: position)

        if children[childIndex] == nil {
            let childCenter = childCenterPosition(for: childIndex)
            children[childIndex] = OctreeNode(center: childCenter, halfSize: halfSize / 2)
        }

        children[childIndex]?.insert(entity: entity, position: position, mass: mass)
    }

    private func octantIndex(for position: SIMD3<Float>) -> Int {
        var index = 0
        if position.x >= center.x { index |= 1 }
        if position.y >= center.y { index |= 2 }
        if position.z >= center.z { index |= 4 }
        return index
    }

    private func childCenterPosition(for index: Int) -> SIMD3<Float> {
        let offset = halfSize / 2
        return SIMD3<Float>(
            center.x + ((index & 1) != 0 ? offset : -offset),
            center.y + ((index & 2) != 0 ? offset : -offset),
            center.z + ((index & 4) != 0 ? offset : -offset)
        )
    }

    /// Calculate force on a position using Barnes-Hut approximation
    /// theta: accuracy parameter (0.5 is typical, lower = more accurate but slower)
    func calculateForce(
        on position: SIMD3<Float>,
        repulsionStrength: Float,
        theta: Float = 0.5
    ) -> SIMD3<Float> {
        guard totalMass > 0 else { return .zero }

        let delta = centerOfMass - position
        let distance = simd_length(delta)

        // Avoid division by zero
        guard distance > 0.001 else { return .zero }

        // Check if we can use this node as approximation (Barnes-Hut criterion)
        let nodeSize = halfSize * 2
        if nodeSize / distance < theta || isLeaf {
            // Use this node's center of mass as approximation
            let forceMagnitude = repulsionStrength * totalMass / (distance * distance)
            return simd_normalize(delta) * (-forceMagnitude)  // Repulsion (negative)
        }

        // Otherwise, recurse into children
        var totalForce: SIMD3<Float> = .zero
        for child in children {
            if let child = child {
                totalForce += child.calculateForce(on: position, repulsionStrength: repulsionStrength, theta: theta)
            }
        }
        return totalForce
    }
}

// MARK: - Spatial Hash Grid for Collision Detection

/// Spatial hash grid for O(1) average-case neighbor queries
final class SpatialHashGrid {
    private var grid: [Int: [(UUID, SIMD3<Float>)]] = [:]
    private let cellSize: Float

    init(cellSize: Float = 0.5) {
        self.cellSize = cellSize
    }

    func clear() {
        grid.removeAll()
    }

    func insert(entity: UUID, position: SIMD3<Float>) {
        let hash = hashPosition(position)
        if grid[hash] == nil {
            grid[hash] = []
        }
        grid[hash]?.append((entity, position))
    }

    /// Get all entities in the same or neighboring cells
    func getNearbyEntities(position: SIMD3<Float>) -> [(UUID, SIMD3<Float>)] {
        var result: [(UUID, SIMD3<Float>)] = []

        // Check all 27 neighboring cells (3x3x3)
        let baseX = Int(floor(position.x / cellSize))
        let baseY = Int(floor(position.y / cellSize))
        let baseZ = Int(floor(position.z / cellSize))

        for dx in -1...1 {
            for dy in -1...1 {
                for dz in -1...1 {
                    let hash = hashCell(baseX + dx, baseY + dy, baseZ + dz)
                    if let entities = grid[hash] {
                        result.append(contentsOf: entities)
                    }
                }
            }
        }

        return result
    }

    private func hashPosition(_ position: SIMD3<Float>) -> Int {
        let x = Int(floor(position.x / cellSize))
        let y = Int(floor(position.y / cellSize))
        let z = Int(floor(position.z / cellSize))
        return hashCell(x, y, z)
    }

    private func hashCell(_ x: Int, _ y: Int, _ z: Int) -> Int {
        // Simple spatial hash combining coordinates
        var hasher = Hasher()
        hasher.combine(x)
        hasher.combine(y)
        hasher.combine(z)
        return hasher.finalize()
    }
}

// MARK: - Optimized Spatial Layout Engine

/// Engine for calculating spatial positions of business entities
/// Uses Barnes-Hut algorithm for O(n log n) force calculations
final class SpatialLayoutEngine {

    // MARK: - Configuration

    struct ForceDirectedConfig {
        var iterations: Int = 100
        var initialRadius: Float = 2.0
        var repulsionStrength: Float = 0.1
        var attractionStrength: Float = 0.01
        var damping: Float = 0.9
        var minDistance: Float = 0.1
        var theta: Float = 0.5  // Barnes-Hut accuracy (lower = more accurate)
        var useBarnesHut: Bool = true  // Use optimized algorithm for large graphs
        var barnesHutThreshold: Int = 50  // Node count above which to use Barnes-Hut
    }

    // MARK: - Layout Algorithms

    /// Calculate positions using radial layout
    func calculateRadialLayout(
        for entities: [UUID],
        radius: Float = 2.0,
        centerPosition: SIMD3<Float> = [0, 0, -1.5],
        elevationAngle: Float = -0.26  // -15 degrees
    ) -> [UUID: SIMD3<Float>] {
        var positions: [UUID: SIMD3<Float>] = [:]
        let count = entities.count
        guard count > 0 else { return positions }

        let angleStep = (2.0 * Float.pi) / Float(count)

        for (index, entityID) in entities.enumerated() {
            let angle = Float(index) * angleStep
            let x = radius * cos(angle)
            let z = radius * sin(angle) + centerPosition.z
            let y = centerPosition.y + (radius * tan(elevationAngle))

            positions[entityID] = SIMD3<Float>(x, y, z)
        }

        return positions
    }

    /// Calculate positions using grid layout
    func calculateGridLayout(
        for entities: [UUID],
        columns: Int = 5,
        spacing: Float = 0.5,
        startPosition: SIMD3<Float> = [-1.0, 0, -2.0]
    ) -> [UUID: SIMD3<Float>] {
        var positions: [UUID: SIMD3<Float>] = [:]

        for (index, entityID) in entities.enumerated() {
            let row = index / columns
            let col = index % columns

            let x = startPosition.x + (Float(col) * spacing)
            let y = startPosition.y - (Float(row) * spacing)
            let z = startPosition.z

            positions[entityID] = SIMD3<Float>(x, y, z)
        }

        return positions
    }

    /// Calculate positions using hierarchical tree layout
    func calculateHierarchicalLayout(
        for tree: [UUID: [UUID]],  // Parent -> Children mapping
        levelSpacing: Float = 0.8,
        nodeSpacing: Float = 0.4,
        startPosition: SIMD3<Float> = [0, 1.0, -2.0]
    ) -> [UUID: SIMD3<Float>] {
        var positions: [UUID: SIMD3<Float>] = [:]

        // Find root nodes (nodes with no parent)
        let allNodes = Set(tree.keys)
        let allChildren = Set(tree.values.flatMap { $0 })
        let rootNodes = allNodes.subtracting(allChildren)

        // BFS traversal
        var level = 0
        var currentLevel: Set<UUID> = rootNodes

        while !currentLevel.isEmpty {
            let levelNodes = Array(currentLevel)
            let levelWidth = Float(levelNodes.count - 1) * nodeSpacing
            let levelStartX = startPosition.x - (levelWidth / 2)

            for (index, nodeID) in levelNodes.enumerated() {
                let x = levelStartX + (Float(index) * nodeSpacing)
                let y = startPosition.y - (Float(level) * levelSpacing)
                let z = startPosition.z

                positions[nodeID] = SIMD3<Float>(x, y, z)
            }

            // Get next level
            var nextLevel: Set<UUID> = []
            for nodeID in currentLevel {
                if let children = tree[nodeID] {
                    nextLevel.formUnion(children)
                }
            }

            currentLevel = nextLevel
            level += 1
        }

        return positions
    }

    /// Calculate positions using force-directed graph layout
    /// Automatically uses Barnes-Hut O(n log n) algorithm for large graphs
    func calculateForceDirectedLayout(
        for nodes: [UUID],
        edges: [(UUID, UUID)],
        config: ForceDirectedConfig = ForceDirectedConfig()
    ) -> [UUID: SIMD3<Float>] {
        // Use Barnes-Hut for large graphs
        if config.useBarnesHut && nodes.count >= config.barnesHutThreshold {
            return calculateForceDirectedLayoutBarnesHut(for: nodes, edges: edges, config: config)
        } else {
            return calculateForceDirectedLayoutNaive(for: nodes, edges: edges, config: config)
        }
    }

    /// Legacy method signature for backwards compatibility
    func calculateForceDirectedLayout(
        for nodes: [UUID],
        edges: [(UUID, UUID)],
        iterations: Int = 100,
        initialRadius: Float = 2.0
    ) -> [UUID: SIMD3<Float>] {
        var config = ForceDirectedConfig()
        config.iterations = iterations
        config.initialRadius = initialRadius
        return calculateForceDirectedLayout(for: nodes, edges: edges, config: config)
    }

    // MARK: - Barnes-Hut Implementation (O(n log n))

    private func calculateForceDirectedLayoutBarnesHut(
        for nodes: [UUID],
        edges: [(UUID, UUID)],
        config: ForceDirectedConfig
    ) -> [UUID: SIMD3<Float>] {
        guard !nodes.isEmpty else { return [:] }

        // Initialize positions in a circle
        var positions: [UUID: SIMD3<Float>] = [:]
        for (index, nodeID) in nodes.enumerated() {
            let angle = (Float(index) / Float(nodes.count)) * 2 * Float.pi
            let x = config.initialRadius * cos(angle)
            let z = config.initialRadius * sin(angle) - 2.0
            positions[nodeID] = SIMD3<Float>(x, 0, z)
        }

        var velocities: [UUID: SIMD3<Float>] = [:]
        for nodeID in nodes {
            velocities[nodeID] = .zero
        }

        // Pre-compute edge lookup for O(1) access
        var edgeLookup: [UUID: [UUID]] = [:]
        for (source, target) in edges {
            edgeLookup[source, default: []].append(target)
            edgeLookup[target, default: []].append(source)
        }

        // Simulation loop
        for _ in 0..<config.iterations {
            // Build octree for this iteration
            let bounds = calculateBounds(positions: positions)
            let octree = OctreeNode(center: bounds.center, halfSize: bounds.halfSize * 1.5)

            for (nodeID, position) in positions {
                octree.insert(entity: nodeID, position: position)
            }

            // Calculate forces using Barnes-Hut
            var forces: [UUID: SIMD3<Float>] = [:]
            for nodeID in nodes {
                forces[nodeID] = .zero
            }

            // Repulsion forces via Barnes-Hut
            for nodeID in nodes {
                guard let position = positions[nodeID] else { continue }
                let repulsionForce = octree.calculateForce(
                    on: position,
                    repulsionStrength: config.repulsionStrength,
                    theta: config.theta
                )
                forces[nodeID]! += repulsionForce
            }

            // Attraction forces along edges (still O(E))
            for (source, target) in edges {
                guard let pos1 = positions[source],
                      let pos2 = positions[target] else { continue }

                let delta = pos2 - pos1
                let distance = simd_length(delta)
                guard distance > 0.001 else { continue }

                let force = delta * config.attractionStrength * distance
                forces[source]! += force
                forces[target]! -= force
            }

            // Update velocities and positions
            for nodeID in nodes {
                guard let force = forces[nodeID],
                      let velocity = velocities[nodeID],
                      let position = positions[nodeID] else { continue }

                let newVelocity = (velocity + force) * config.damping
                velocities[nodeID] = newVelocity
                positions[nodeID] = position + newVelocity
            }
        }

        return positions
    }

    // MARK: - Naive Implementation (O(n²)) - for small graphs

    private func calculateForceDirectedLayoutNaive(
        for nodes: [UUID],
        edges: [(UUID, UUID)],
        config: ForceDirectedConfig
    ) -> [UUID: SIMD3<Float>] {
        // Initialize positions
        var positions: [UUID: SIMD3<Float>] = [:]
        for (index, nodeID) in nodes.enumerated() {
            let angle = (Float(index) / Float(nodes.count)) * 2 * Float.pi
            let x = config.initialRadius * cos(angle)
            let z = config.initialRadius * sin(angle) - 2.0
            positions[nodeID] = SIMD3<Float>(x, 0, z)
        }

        var velocities: [UUID: SIMD3<Float>] = [:]
        for nodeID in nodes {
            velocities[nodeID] = SIMD3<Float>(0, 0, 0)
        }

        // Simulate forces
        for _ in 0..<config.iterations {
            var forces: [UUID: SIMD3<Float>] = [:]
            for nodeID in nodes {
                forces[nodeID] = SIMD3<Float>(0, 0, 0)
            }

            // Repulsion between all nodes (O(n²))
            for i in 0..<nodes.count {
                for j in (i+1)..<nodes.count {
                    let node1 = nodes[i]
                    let node2 = nodes[j]

                    guard let pos1 = positions[node1],
                          let pos2 = positions[node2] else { continue }

                    let delta = pos1 - pos2
                    let distance = max(simd_length(delta), 0.01)

                    if distance < config.minDistance * 5 {
                        let force = simd_normalize(delta) * config.repulsionStrength / (distance * distance)
                        forces[node1]! += force
                        forces[node2]! -= force
                    }
                }
            }

            // Attraction along edges
            for (source, target) in edges {
                guard let pos1 = positions[source],
                      let pos2 = positions[target] else { continue }

                let delta = pos2 - pos1
                let distance = simd_length(delta)

                let force = delta * config.attractionStrength * distance
                forces[source]! += force
                forces[target]! -= force
            }

            // Update velocities and positions
            for nodeID in nodes {
                if let force = forces[nodeID],
                   let velocity = velocities[nodeID],
                   let position = positions[nodeID] {

                    let newVelocity = (velocity + force) * config.damping
                    velocities[nodeID] = newVelocity
                    positions[nodeID] = position + newVelocity
                }
            }
        }

        return positions
    }

    // MARK: - Helper Methods

    private func calculateBounds(positions: [UUID: SIMD3<Float>]) -> (center: SIMD3<Float>, halfSize: Float) {
        guard !positions.isEmpty else {
            return (center: .zero, halfSize: 5.0)
        }

        var minPos = SIMD3<Float>(repeating: Float.greatestFiniteMagnitude)
        var maxPos = SIMD3<Float>(repeating: -Float.greatestFiniteMagnitude)

        for position in positions.values {
            minPos = simd_min(minPos, position)
            maxPos = simd_max(maxPos, position)
        }

        let center = (minPos + maxPos) / 2
        let size = maxPos - minPos
        let halfSize = max(size.x, max(size.y, size.z)) / 2

        return (center: center, halfSize: max(halfSize, 1.0))
    }

    // MARK: - Collision Detection (Optimized with Spatial Hash)

    /// Check if two spherical entities would overlap
    func checkCollision(
        position1: SIMD3<Float>,
        radius1: Float,
        position2: SIMD3<Float>,
        radius2: Float
    ) -> Bool {
        let distance = simd_distance(position1, position2)
        return distance < (radius1 + radius2)
    }

    /// Resolve overlapping positions using spatial hashing for O(n) average case
    func resolveCollisions(
        positions: inout [UUID: SIMD3<Float>],
        radii: [UUID: Float],
        iterations: Int = 10
    ) {
        let maxRadius = radii.values.max() ?? 0.5
        let grid = SpatialHashGrid(cellSize: maxRadius * 2.5)

        for _ in 0..<iterations {
            // Rebuild grid each iteration
            grid.clear()
            for (entity, position) in positions {
                grid.insert(entity: entity, position: position)
            }

            // Check collisions using spatial hash
            for (entity1, pos1) in positions {
                guard let radius1 = radii[entity1] else { continue }

                let nearby = grid.getNearbyEntities(position: pos1)
                for (entity2, pos2) in nearby {
                    guard entity1 != entity2,
                          let radius2 = radii[entity2] else { continue }

                    if checkCollision(position1: pos1, radius1: radius1,
                                      position2: pos2, radius2: radius2) {
                        let delta = pos1 - pos2
                        let distance = simd_length(delta)
                        guard distance > 0.001 else { continue }

                        let overlap = (radius1 + radius2) - distance
                        let direction = simd_normalize(delta)

                        positions[entity1] = pos1 + direction * (overlap * 0.5)
                        positions[entity2] = pos2 - direction * (overlap * 0.5)
                    }
                }
            }
        }
    }

    /// Legacy resolve collisions (backwards compatibility)
    func resolveCollisionsNaive(
        positions: inout [UUID: SIMD3<Float>],
        radii: [UUID: Float],
        iterations: Int = 10
    ) {
        let entities = Array(positions.keys)

        for _ in 0..<iterations {
            for i in 0..<entities.count {
                for j in (i+1)..<entities.count {
                    let entity1 = entities[i]
                    let entity2 = entities[j]

                    guard let pos1 = positions[entity1],
                          let pos2 = positions[entity2],
                          let radius1 = radii[entity1],
                          let radius2 = radii[entity2] else { continue }

                    if checkCollision(position1: pos1, radius1: radius1,
                                    position2: pos2, radius2: radius2) {
                        let delta = pos1 - pos2
                        let distance = simd_length(delta)
                        let overlap = (radius1 + radius2) - distance
                        let direction = simd_normalize(delta)

                        positions[entity1] = pos1 + direction * (overlap * 0.5)
                        positions[entity2] = pos2 - direction * (overlap * 0.5)
                    }
                }
            }
        }
    }
}

// MARK: - Bezier Curve Utilities

extension SpatialLayoutEngine {
    /// Calculate point on cubic bezier curve
    func bezierPoint(
        t: Float,
        p0: SIMD3<Float>,
        p1: SIMD3<Float>,
        p2: SIMD3<Float>,
        p3: SIMD3<Float>
    ) -> SIMD3<Float> {
        let oneMinusT = 1 - t
        let oneMinusT2 = oneMinusT * oneMinusT
        let oneMinusT3 = oneMinusT2 * oneMinusT
        let t2 = t * t
        let t3 = t2 * t

        return oneMinusT3 * p0 +
               3 * oneMinusT2 * t * p1 +
               3 * oneMinusT * t2 * p2 +
               t3 * p3
    }

    /// Generate smooth path between two points with control points
    func generatePath(
        from start: SIMD3<Float>,
        to end: SIMD3<Float>,
        arcHeight: Float = 0.5,
        steps: Int = 20
    ) -> [SIMD3<Float>] {
        var path: [SIMD3<Float>] = []

        // Calculate control points
        let control1 = SIMD3<Float>(start.x, start.y + arcHeight, start.z)
        let control2 = SIMD3<Float>(end.x, end.y + arcHeight, end.z)

        // Generate path points
        for i in 0...steps {
            let t = Float(i) / Float(steps)
            let point = bezierPoint(t: t, p0: start, p1: control1, p2: control2, p3: end)
            path.append(point)
        }

        return path
    }
}
