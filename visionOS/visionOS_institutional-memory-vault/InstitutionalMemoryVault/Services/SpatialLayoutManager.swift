//
//  SpatialLayoutManager.swift
//  Institutional Memory Vault
//
//  Manages spatial positioning and layout algorithms for 3D visualization
//

import Foundation
import simd

@Observable
final class SpatialLayoutManager {

    // MARK: - Layout Algorithms

    /// Calculate spatial layout using force-directed graph algorithm
    /// This creates a natural-looking network where connected nodes attract
    /// and unconnected nodes repel
    func forceDirectedLayout(
        entities: [KnowledgeEntity],
        connections: [KnowledgeConnection],
        iterations: Int = 100,
        bounds: Float = 5.0
    ) -> [UUID: SpatialCoordinate] {
        var positions: [UUID: SIMD3<Float>] = [:]
        var velocities: [UUID: SIMD3<Float>] = [:]

        // Initialize random positions
        for entity in entities {
            positions[entity.id] = SIMD3<Float>(
                Float.random(in: -bounds...bounds),
                Float.random(in: -bounds...bounds),
                Float.random(in: -bounds...bounds)
            )
            velocities[entity.id] = SIMD3<Float>(0, 0, 0)
        }

        // Build adjacency for faster lookups
        var adjacency: [UUID: Set<UUID>] = [:]
        for connection in connections {
            if let sourceId = connection.sourceEntity?.id,
               let targetId = connection.targetEntity?.id {
                adjacency[sourceId, default: []].insert(targetId)
                adjacency[targetId, default: []].insert(sourceId)
            }
        }

        // Simulation parameters
        let repulsionStrength: Float = 0.1
        let attractionStrength: Float = 0.01
        let damping: Float = 0.85
        let minDistance: Float = 0.1

        // Run simulation
        for _ in 0..<iterations {
            var forces: [UUID: SIMD3<Float>] = [:]

            // Calculate repulsion forces (all pairs)
            for i in 0..<entities.count {
                let entity1 = entities[i]
                var totalForce = SIMD3<Float>(0, 0, 0)

                for j in 0..<entities.count where i != j {
                    let entity2 = entities[j]

                    guard let pos1 = positions[entity1.id],
                          let pos2 = positions[entity2.id] else { continue }

                    let delta = pos1 - pos2
                    let distance = max(length(delta), minDistance)
                    let direction = normalize(delta)

                    // Coulomb's law for repulsion
                    let repulsion = direction * (repulsionStrength / (distance * distance))
                    totalForce += repulsion
                }

                forces[entity1.id] = totalForce
            }

            // Calculate attraction forces (connected pairs)
            for connection in connections {
                guard let sourceId = connection.sourceEntity?.id,
                      let targetId = connection.targetEntity?.id,
                      let pos1 = positions[sourceId],
                      let pos2 = positions[targetId] else { continue }

                let delta = pos2 - pos1
                let distance = length(delta)
                let direction = normalize(delta)

                // Hooke's law for attraction
                let strength = attractionStrength * connection.strength
                let attraction = direction * (distance * strength)

                forces[sourceId, default: SIMD3<Float>(0, 0, 0)] += attraction
                forces[targetId, default: SIMD3<Float>(0, 0, 0)] -= attraction
            }

            // Update velocities and positions
            for entity in entities {
                guard let force = forces[entity.id] else { continue }

                var velocity = velocities[entity.id] ?? SIMD3<Float>(0, 0, 0)
                velocity = (velocity + force) * damping

                var position = positions[entity.id]!
                position += velocity

                // Keep within bounds
                position = clamp(position, min: -bounds, max: bounds)

                velocities[entity.id] = velocity
                positions[entity.id] = position
            }
        }

        // Convert to SpatialCoordinate
        return positions.mapValues { pos in
            SpatialCoordinate(x: pos.x, y: pos.y, z: pos.z)
        }
    }

    /// Timeline layout - arrange entities chronologically along a path
    func timelineLayout(
        entities: [KnowledgeEntity],
        spacing: Float = 0.5,
        curvature: Float = 0.0
    ) -> [UUID: SpatialCoordinate] {
        // Sort by date
        let sorted = entities.sorted { $0.createdDate < $1.createdDate }

        var coordinates: [UUID: SpatialCoordinate] = [:]

        for (index, entity) in sorted.enumerated() {
            let progress = Float(index) / Float(max(sorted.count - 1, 1))
            let x = (progress - 0.5) * Float(sorted.count) * spacing

            // Add vertical variation based on department or type for visual interest
            let y = sin(progress * .pi * 2 * curvature) * 0.3

            // Slight depth variation
            let z = cos(progress * .pi * 2 * curvature) * 0.2

            coordinates[entity.id] = SpatialCoordinate(
                x: x,
                y: y,
                z: z,
                temporalPosition: entity.createdDate
            )
        }

        return coordinates
    }

    /// Hierarchical layout - arrange entities in a tree structure
    func hierarchicalLayout(
        entities: [KnowledgeEntity],
        connections: [KnowledgeConnection],
        levelHeight: Float = 1.0,
        nodeSpacing: Float = 0.5
    ) -> [UUID: SpatialCoordinate] {
        // Build parent-child relationships
        var children: [UUID: [UUID]] = [:]
        var parents: [UUID: UUID] = [:]

        for connection in connections where connection.connectionType == .prerequisiteFor {
            if let parentId = connection.sourceEntity?.id,
               let childId = connection.targetEntity?.id {
                children[parentId, default: []].append(childId)
                parents[childId] = parentId
            }
        }

        // Find root nodes (nodes with no parents)
        let roots = entities.filter { parents[$0.id] == nil }

        var coordinates: [UUID: SpatialCoordinate] = [:]
        var level Positions: [Int: Float] = [:]

        func layoutNode(id: UUID, level: Int, parentX: Float) {
            let childCount = children[id]?.count ?? 0
            let width = Float(childCount + 1) * nodeSpacing

            let x = parentX + (levelPositions[level] ?? 0)
            let y = -Float(level) * levelHeight
            let z: Float = 0

            coordinates[id] = SpatialCoordinate(x: x, y: y, z: z)

            levelPositions[level] = (levelPositions[level] ?? 0) + width

            // Layout children
            if let childIds = children[id] {
                for childId in childIds {
                    layoutNode(id: childId, level: level + 1, parentX: x)
                }
            }
        }

        // Layout from each root
        var rootX: Float = 0
        for root in roots {
            layoutNode(id: root.id, level: 0, parentX: rootX)
            rootX += 3.0 // Space between root trees
        }

        return coordinates
    }

    /// Circular layout - arrange entities in a circle or spiral
    func circularLayout(
        entities: [KnowledgeEntity],
        radius: Float = 2.0,
        spiral: Bool = false
    ) -> [UUID: SpatialCoordinate] {
        var coordinates: [UUID: SpatialCoordinate] = [:]

        for (index, entity) in entities.enumerated() {
            let angle = (Float(index) / Float(entities.count)) * 2 * .pi

            var currentRadius = radius
            if spiral {
                currentRadius += Float(index) * 0.1
            }

            let x = cos(angle) * currentRadius
            let z = sin(angle) * currentRadius
            let y = spiral ? Float(index) * 0.05 : 0

            coordinates[entity.id] = SpatialCoordinate(x: x, y: y, z: z)
        }

        return coordinates
    }

    /// Grid layout - arrange entities in a 3D grid
    func gridLayout(
        entities: [KnowledgeEntity],
        spacing: Float = 0.8
    ) -> [UUID: SpatialCoordinate] {
        let gridSize = Int(ceil(pow(Float(entities.count), 1.0/3.0)))
        var coordinates: [UUID: SpatialCoordinate] = [:]

        for (index, entity) in entities.enumerated() {
            let x = Float(index % gridSize) * spacing
            let y = Float((index / gridSize) % gridSize) * spacing
            let z = Float(index / (gridSize * gridSize)) * spacing

            // Center the grid
            let offset = Float(gridSize - 1) * spacing / 2
            coordinates[entity.id] = SpatialCoordinate(
                x: x - offset,
                y: y - offset,
                z: z - offset
            )
        }

        return coordinates
    }

    /// Departmental layout - group by department in distinct clusters
    func departmentalLayout(
        entities: [KnowledgeEntity],
        departments: [Department]
    ) -> [UUID: SpatialCoordinate] {
        var coordinates: [UUID: SpatialCoordinate] = [:]

        // Group entities by department
        var departmentGroups: [UUID: [KnowledgeEntity]] = [:]
        var ungrouped: [KnowledgeEntity] = []

        for entity in entities {
            if let deptId = entity.department?.id {
                departmentGroups[deptId, default: []].append(entity)
            } else {
                ungrouped.append(entity)
            }
        }

        // Position each department cluster
        let deptCount = departments.count
        let clusterRadius: Float = 3.0

        for (index, department) in departments.enumerated() {
            let angle = (Float(index) / Float(deptCount)) * 2 * .pi
            let clusterX = cos(angle) * clusterRadius
            let clusterZ = sin(angle) * clusterRadius

            // Layout entities within this cluster
            if let deptEntities = departmentGroups[department.id] {
                for (entityIndex, entity) in deptEntities.enumerated() {
                    let localAngle = (Float(entityIndex) / Float(deptEntities.count)) * 2 * .pi
                    let localRadius: Float = 0.8

                    let x = clusterX + cos(localAngle) * localRadius
                    let z = clusterZ + sin(localAngle) * localRadius
                    let y = Float.random(in: -0.2...0.2)

                    coordinates[entity.id] = SpatialCoordinate(x: x, y: y, z: z)
                }
            }
        }

        // Handle ungrouped entities
        for (index, entity) in ungrouped.enumerated() {
            let angle = (Float(index) / Float(max(ungrouped.count, 1))) * 2 * .pi
            coordinates[entity.id] = SpatialCoordinate(
                x: cos(angle) * 1.5,
                y: 0.5,
                z: sin(angle) * 1.5
            )
        }

        return coordinates
    }

    // MARK: - Utility Functions

    /// Interpolate between two layouts smoothly
    func interpolateLayouts(
        from: [UUID: SpatialCoordinate],
        to: [UUID: SpatialCoordinate],
        progress: Float
    ) -> [UUID: SpatialCoordinate] {
        var result: [UUID: SpatialCoordinate] = [:]

        for (id, fromCoord) in from {
            if let toCoord = to[id] {
                result[id] = SpatialCoordinate(
                    x: lerp(fromCoord.x, toCoord.x, progress),
                    y: lerp(fromCoord.y, toCoord.y, progress),
                    z: lerp(fromCoord.z, toCoord.z, progress),
                    scale: lerp(fromCoord.scale, toCoord.scale, progress)
                )
            } else {
                result[id] = fromCoord
            }
        }

        return result
    }

    private func lerp(_ a: Float, _ b: Float, _ t: Float) -> Float {
        return a + (b - a) * t
    }

    private func clamp(_ value: SIMD3<Float>, min minValue: Float, max maxValue: Float) -> SIMD3<Float> {
        return SIMD3<Float>(
            simd_clamp(value.x, minValue, maxValue),
            simd_clamp(value.y, minValue, maxValue),
            simd_clamp(value.z, minValue, maxValue)
        )
    }
}

// MARK: - Layout Presets

enum LayoutStyle {
    case forceDirected
    case timeline
    case hierarchical
    case circular
    case circularSpiral
    case grid
    case departmental
}
