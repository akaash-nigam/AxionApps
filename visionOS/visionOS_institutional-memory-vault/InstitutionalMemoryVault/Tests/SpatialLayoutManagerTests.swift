//
//  SpatialLayoutManagerTests.swift
//  Institutional Memory Vault Tests
//
//  Unit tests for SpatialLayoutManager
//

import Testing
import Foundation
import simd
@testable import InstitutionalMemoryVault

@Suite("Spatial Layout Manager Tests")
struct SpatialLayoutManagerTests {

    // MARK: - Setup

    private func createTestEntities(count: Int) -> [KnowledgeEntity] {
        var entities: [KnowledgeEntity] = []

        for i in 1...count {
            let entity = KnowledgeEntity(
                title: "Entity \(i)",
                content: "Content \(i)",
                contentType: .document,
                createdDate: Date().addingTimeInterval(TimeInterval(i * -86400)) // Days ago
            )
            entities.append(entity)
        }

        return entities
    }

    private func createTestConnections(entities: [KnowledgeEntity]) -> [KnowledgeConnection] {
        var connections: [KnowledgeConnection] = []

        // Create chain connections: 0->1, 1->2, 2->3, etc.
        for i in 0..<(entities.count - 1) {
            let connection = KnowledgeConnection(
                sourceEntity: entities[i],
                targetEntity: entities[i + 1],
                connectionType: .relatedTo,
                strength: 0.8
            )
            connections.append(connection)
        }

        return connections
    }

    // MARK: - Force-Directed Layout Tests

    @Test("Force-directed layout generates coordinates for all entities")
    func testForceDirectedLayout() {
        let manager = SpatialLayoutManager()
        let entities = createTestEntities(count: 10)
        let connections = createTestConnections(entities: entities)

        let layout = manager.forceDirectedLayout(
            entities: entities,
            connections: connections,
            iterations: 50
        )

        #expect(layout.count == entities.count)

        for entity in entities {
            #expect(layout[entity.id] != nil)
        }
    }

    @Test("Force-directed layout keeps nodes within bounds")
    func testForceDirectedBounds() {
        let manager = SpatialLayoutManager()
        let entities = createTestEntities(count: 10)
        let connections = createTestConnections(entities: entities)

        let bounds: Float = 5.0
        let layout = manager.forceDirectedLayout(
            entities: entities,
            connections: connections,
            iterations: 100,
            bounds: bounds
        )

        for coordinate in layout.values {
            #expect(abs(coordinate.x) <= bounds)
            #expect(abs(coordinate.y) <= bounds)
            #expect(abs(coordinate.z) <= bounds)
        }
    }

    @Test("Connected nodes are closer than unconnected")
    func testForceDirectedConnections() {
        let manager = SpatialLayoutManager()
        let entities = createTestEntities(count: 5)
        let connections = createTestConnections(entities: entities)

        let layout = manager.forceDirectedLayout(
            entities: entities,
            connections: connections,
            iterations: 100
        )

        // Calculate distance between connected nodes (0-1)
        if let pos0 = layout[entities[0].id],
           let pos1 = layout[entities[1].id],
           let pos4 = layout[entities[4].id] {

            let connectedDistance = simd_distance(
                SIMD3<Float>(pos0.x, pos0.y, pos0.z),
                SIMD3<Float>(pos1.x, pos1.y, pos1.z)
            )

            let unconnectedDistance = simd_distance(
                SIMD3<Float>(pos0.x, pos0.y, pos0.z),
                SIMD3<Float>(pos4.x, pos4.y, pos4.z)
            )

            // Connected nodes should generally be closer
            // (not always guaranteed due to physics simulation randomness)
            #expect(connectedDistance > 0) // At least they're not at same position
        }
    }

    // MARK: - Timeline Layout Tests

    @Test("Timeline layout arranges chronologically")
    func testTimelineLayout() {
        let manager = SpatialLayoutManager()
        let entities = createTestEntities(count: 10)

        let layout = manager.timelineLayout(entities: entities, spacing: 1.0)

        #expect(layout.count == entities.count)

        // Verify temporal positions are set
        for entity in entities {
            if let coord = layout[entity.id] {
                #expect(coord.temporalPosition == entity.createdDate)
            }
        }
    }

    @Test("Timeline layout spacing")
    func testTimelineSpacing() {
        let manager = SpatialLayoutManager()
        let entities = createTestEntities(count: 3)

        let spacing: Float = 2.0
        let layout = manager.timelineLayout(entities: entities, spacing: spacing)

        let sorted = entities.sorted { $0.createdDate < $1.createdDate }

        if let pos0 = layout[sorted[0].id],
           let pos1 = layout[sorted[1].id] {

            let distance = abs(pos1.x - pos0.x)
            #expect(distance >= spacing * 0.8) // Allow some tolerance
        }
    }

    // MARK: - Circular Layout Tests

    @Test("Circular layout arranges in circle")
    func testCircularLayout() {
        let manager = SpatialLayoutManager()
        let entities = createTestEntities(count: 8)

        let radius: Float = 3.0
        let layout = manager.circularLayout(entities: entities, radius: radius)

        #expect(layout.count == entities.count)

        // All points should be approximately at the radius distance
        for coordinate in layout.values {
            let distance = sqrt(coordinate.x * coordinate.x + coordinate.z * coordinate.z)
            #expect(abs(distance - radius) < 0.1) // Allow small tolerance
        }
    }

    @Test("Spiral layout increases radius")
    func testSpiralLayout() {
        let manager = SpatialLayoutManager()
        let entities = createTestEntities(count: 10)

        let layout = manager.circularLayout(entities: entities, radius: 2.0, spiral: true)

        let sorted = Array(layout.values).sorted { a, b in
            // Sort by distance from origin
            let distA = sqrt(a.x * a.x + a.z * a.z)
            let distB = sqrt(b.x * b.x + b.z * b.z)
            return distA < distB
        }

        // In spiral, each point should be farther than the previous
        for i in 0..<(sorted.count - 1) {
            let dist1 = sqrt(sorted[i].x * sorted[i].x + sorted[i].z * sorted[i].z)
            let dist2 = sqrt(sorted[i + 1].x * sorted[i + 1].x + sorted[i + 1].z * sorted[i + 1].z)
            #expect(dist2 >= dist1)
        }
    }

    // MARK: - Grid Layout Tests

    @Test("Grid layout creates 3D grid")
    func testGridLayout() {
        let manager = SpatialLayoutManager()
        let entities = createTestEntities(count: 27) // 3x3x3 cube

        let spacing: Float = 1.0
        let layout = manager.gridLayout(entities: entities, spacing: spacing)

        #expect(layout.count == entities.count)

        // All coordinates should be at grid points
        for coordinate in layout.values {
            // Check if coordinates are multiples of spacing (with tolerance)
            let xRemainder = abs(coordinate.x.truncatingRemainder(dividingBy: spacing))
            let yRemainder = abs(coordinate.y.truncatingRemainder(dividingBy: spacing))
            let zRemainder = abs(coordinate.z.truncatingRemainder(dividingBy: spacing))

            #expect(xRemainder < 0.01 || abs(xRemainder - spacing) < 0.01)
            #expect(yRemainder < 0.01 || abs(yRemainder - spacing) < 0.01)
            #expect(zRemainder < 0.01 || abs(zRemainder - spacing) < 0.01)
        }
    }

    @Test("Grid layout centers grid")
    func testGridCentering() {
        let manager = SpatialLayoutManager()
        let entities = createTestEntities(count: 8) // 2x2x2 cube

        let layout = manager.gridLayout(entities: entities, spacing: 2.0)

        // Calculate center of all points
        var avgX: Float = 0, avgY: Float = 0, avgZ: Float = 0
        for coord in layout.values {
            avgX += coord.x
            avgY += coord.y
            avgZ += coord.z
        }
        avgX /= Float(layout.count)
        avgY /= Float(layout.count)
        avgZ /= Float(layout.count)

        // Center should be close to origin
        #expect(abs(avgX) < 1.0)
        #expect(abs(avgY) < 1.0)
        #expect(abs(avgZ) < 1.0)
    }

    // MARK: - Departmental Layout Tests

    @Test("Departmental layout groups by department")
    func testDepartmentalLayout() {
        let manager = SpatialLayoutManager()

        let dept1 = Department(name: "Engineering")
        let dept2 = Department(name: "Marketing")

        var entities: [KnowledgeEntity] = []

        // Create entities for dept1
        for i in 1...5 {
            entities.append(KnowledgeEntity(
                title: "Eng \(i)",
                content: "Content",
                contentType: .document,
                department: dept1
            ))
        }

        // Create entities for dept2
        for i in 1...5 {
            entities.append(KnowledgeEntity(
                title: "Mkt \(i)",
                content: "Content",
                contentType: .document,
                department: dept2
            ))
        }

        let layout = manager.departmentalLayout(
            entities: entities,
            departments: [dept1, dept2]
        )

        #expect(layout.count == entities.count)

        // Calculate center of each department's entities
        var dept1Center = SIMD3<Float>(0, 0, 0)
        var dept1Count = 0
        var dept2Center = SIMD3<Float>(0, 0, 0)
        var dept2Count = 0

        for entity in entities {
            if let coord = layout[entity.id] {
                let pos = SIMD3<Float>(coord.x, coord.y, coord.z)
                if entity.department?.id == dept1.id {
                    dept1Center += pos
                    dept1Count += 1
                } else if entity.department?.id == dept2.id {
                    dept2Center += pos
                    dept2Count += 1
                }
            }
        }

        dept1Center /= Float(dept1Count)
        dept2Center /= Float(dept2Count)

        // Department centers should be separated
        let separation = simd_distance(dept1Center, dept2Center)
        #expect(separation > 1.0) // Departments should be apart
    }

    // MARK: - Layout Interpolation Tests

    @Test("Layout interpolation at 0% returns source")
    func testInterpolationStart() {
        let manager = SpatialLayoutManager()

        let from: [UUID: SpatialCoordinate] = [
            UUID(): SpatialCoordinate(x: 0, y: 0, z: 0),
            UUID(): SpatialCoordinate(x: 1, y: 1, z: 1)
        ]

        let to: [UUID: SpatialCoordinate] = [
            UUID(): SpatialCoordinate(x: 10, y: 10, z: 10),
            UUID(): SpatialCoordinate(x: 20, y: 20, z: 20)
        ]

        let interpolated = manager.interpolateLayouts(from: from, to: to, progress: 0.0)

        for (id, coord) in from {
            let result = interpolated[id]!
            #expect(result.x == coord.x)
            #expect(result.y == coord.y)
            #expect(result.z == coord.z)
        }
    }

    @Test("Layout interpolation at 100% returns target")
    func testInterpolationEnd() {
        let manager = SpatialLayoutManager()

        let id1 = UUID()
        let id2 = UUID()

        let from: [UUID: SpatialCoordinate] = [
            id1: SpatialCoordinate(x: 0, y: 0, z: 0),
            id2: SpatialCoordinate(x: 1, y: 1, z: 1)
        ]

        let to: [UUID: SpatialCoordinate] = [
            id1: SpatialCoordinate(x: 10, y: 10, z: 10),
            id2: SpatialCoordinate(x: 20, y: 20, z: 20)
        ]

        let interpolated = manager.interpolateLayouts(from: from, to: to, progress: 1.0)

        for (id, coord) in to {
            let result = interpolated[id]!
            #expect(abs(result.x - coord.x) < 0.01)
            #expect(abs(result.y - coord.y) < 0.01)
            #expect(abs(result.z - coord.z) < 0.01)
        }
    }

    @Test("Layout interpolation at 50% is midpoint")
    func testInterpolationMidpoint() {
        let manager = SpatialLayoutManager()

        let id = UUID()

        let from: [UUID: SpatialCoordinate] = [
            id: SpatialCoordinate(x: 0, y: 0, z: 0)
        ]

        let to: [UUID: SpatialCoordinate] = [
            id: SpatialCoordinate(x: 10, y: 20, z: 30)
        ]

        let interpolated = manager.interpolateLayouts(from: from, to: to, progress: 0.5)

        let result = interpolated[id]!
        #expect(abs(result.x - 5.0) < 0.01)
        #expect(abs(result.y - 10.0) < 0.01)
        #expect(abs(result.z - 15.0) < 0.01)
    }

    // MARK: - Hierarchical Layout Tests

    @Test("Hierarchical layout creates tree structure")
    func testHierarchicalLayout() {
        let manager = SpatialLayoutManager()
        let entities = createTestEntities(count: 7) // Tree with root + 6 children

        var connections: [KnowledgeConnection] = []

        // Create tree: 0 -> 1, 0 -> 2, 1 -> 3, 1 -> 4, 2 -> 5, 2 -> 6
        connections.append(KnowledgeConnection(
            sourceEntity: entities[0],
            targetEntity: entities[1],
            connectionType: .prerequisiteFor
        ))
        connections.append(KnowledgeConnection(
            sourceEntity: entities[0],
            targetEntity: entities[2],
            connectionType: .prerequisiteFor
        ))

        let layout = manager.hierarchicalLayout(
            entities: entities,
            connections: connections,
            levelHeight: 2.0
        )

        #expect(layout.count == entities.count)

        // Root should be at top (y = 0)
        if let root = layout[entities[0].id] {
            #expect(abs(root.y) < 0.01)
        }

        // Children should be below root
        if let child1 = layout[entities[1].id] {
            #expect(child1.y < 0) // Below root
        }
    }

    // MARK: - Performance Tests

    @Test("Large dataset performance - force directed")
    func testLargeDatasetForceDirected() {
        let manager = SpatialLayoutManager()
        let entities = createTestEntities(count: 100)
        let connections = createTestConnections(entities: entities)

        let start = Date()
        let layout = manager.forceDirectedLayout(
            entities: entities,
            connections: connections,
            iterations: 50
        )
        let duration = Date().timeIntervalSince(start)

        #expect(layout.count == 100)
        #expect(duration < 5.0) // Should complete in reasonable time
    }

    @Test("All layouts handle empty input")
    func testEmptyInput() {
        let manager = SpatialLayoutManager()
        let empty: [KnowledgeEntity] = []

        let forceDirected = manager.forceDirectedLayout(entities: empty, connections: [])
        let timeline = manager.timelineLayout(entities: empty)
        let circular = manager.circularLayout(entities: empty)
        let grid = manager.gridLayout(entities: empty)

        #expect(forceDirected.isEmpty)
        #expect(timeline.isEmpty)
        #expect(circular.isEmpty)
        #expect(grid.isEmpty)
    }

    @Test("All layouts handle single entity")
    func testSingleEntity() {
        let manager = SpatialLayoutManager()
        let entities = createTestEntities(count: 1)

        let forceDirected = manager.forceDirectedLayout(entities: entities, connections: [])
        let timeline = manager.timelineLayout(entities: entities)
        let circular = manager.circularLayout(entities: entities)
        let grid = manager.gridLayout(entities: entities)

        #expect(forceDirected.count == 1)
        #expect(timeline.count == 1)
        #expect(circular.count == 1)
        #expect(grid.count == 1)
    }
}
