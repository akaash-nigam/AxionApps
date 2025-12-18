//
//  PerformanceTests.swift
//  SupplyChainControlTowerTests
//
//  Performance and optimization tests
//

import Testing
import Foundation
@testable import SupplyChainControlTower

@Suite("Performance Tests")
struct PerformanceTests {

    // MARK: - Performance Monitor Tests

    @Test("Performance monitor tracks FPS")
    func testPerformanceMonitorFPS() async throws {
        let monitor = PerformanceMonitor()

        // Simulate multiple frames
        for _ in 0..<90 {
            monitor.recordFrame()
            try await Task.sleep(for: .milliseconds(11)) // ~90 FPS
        }

        #expect(monitor.currentFPS > 0)
        #expect(monitor.currentFPS <= 90)
    }

    @Test("Performance monitor detects low FPS")
    func testPerformanceMonitorLowFPS() async throws {
        let monitor = PerformanceMonitor()

        // Simulate low FPS
        for _ in 0..<30 {
            monitor.recordFrame()
            try await Task.sleep(for: .milliseconds(50)) // ~20 FPS
        }

        let status = monitor.checkPerformanceTargets()
        #expect(status == .degraded || status == .critical)
    }

    @Test("Performance monitor tracks memory usage")
    func testPerformanceMonitorMemory() async throws {
        let monitor = PerformanceMonitor()

        // Memory usage should be trackable
        #expect(monitor.memoryUsage >= 0)
    }

    // MARK: - Entity Pool Tests

    @Test("Entity pool creates and reuses entities")
    func testEntityPool() async throws {
        class TestEntity {
            var isActive: Bool = false
        }

        let pool = EntityPool<TestEntity>(maxSize: 10, factory: { TestEntity() })

        let entity1 = await pool.acquire()
        #expect(entity1 !== nil)

        await pool.release(entity1)

        let entity2 = await pool.acquire()
        #expect(entity2 !== nil)

        // Pool should reuse entities
        #expect(entity1 === entity2)
    }

    @Test("Entity pool respects max size")
    func testEntityPoolMaxSize() async throws {
        class TestEntity {
            var isActive: Bool = false
        }

        let pool = EntityPool<TestEntity>(maxSize: 3, factory: { TestEntity() })

        let entity1 = await pool.acquire()
        let entity2 = await pool.acquire()
        let entity3 = await pool.acquire()

        #expect(entity1 !== nil)
        #expect(entity2 !== nil)
        #expect(entity3 !== nil)

        // All different entities
        #expect(entity1 !== entity2)
        #expect(entity2 !== entity3)
    }

    // MARK: - Throttle Tests

    @Test("Throttle limits execution frequency")
    func testThrottle() async throws {
        let throttle = Throttle(interval: 0.1) // 100ms throttle
        var executionCount = 0

        // Try to execute 10 times rapidly
        for _ in 0..<10 {
            await throttle.execute {
                executionCount += 1
            }
        }

        // Should only execute once due to throttling
        #expect(executionCount == 1)

        // Wait for throttle interval
        try await Task.sleep(for: .milliseconds(150))

        // Now it should execute again
        await throttle.execute {
            executionCount += 1
        }

        #expect(executionCount == 2)
    }

    @Test("Debounce delays execution")
    func testDebounce() async throws {
        let debounce = Debounce(delay: 0.1) // 100ms debounce
        var executionCount = 0

        // Schedule multiple times rapidly
        for _ in 0..<10 {
            await debounce.schedule {
                executionCount += 1
            }
            try await Task.sleep(for: .milliseconds(10))
        }

        // Should not execute yet
        #expect(executionCount == 0)

        // Wait for debounce delay
        try await Task.sleep(for: .milliseconds(150))

        // Should execute only once
        #expect(executionCount == 1)
    }

    // MARK: - LOD System Tests

    @Test("LOD system calculates correct level from distance")
    func testLODSystemDistance() async throws {
        #expect(LODLevel.fromDistance(2.0) == .high)
        #expect(LODLevel.fromDistance(6.0) == .medium)
        #expect(LODLevel.fromDistance(12.0) == .low)
        #expect(LODLevel.fromDistance(20.0) == .minimal)
    }

    @Test("LOD level provides correct detail counts")
    func testLODDetailCounts() async throws {
        #expect(LODLevel.high.maxNodes == 1000)
        #expect(LODLevel.medium.maxNodes == 500)
        #expect(LODLevel.low.maxNodes == 200)
        #expect(LODLevel.minimal.maxNodes == 50)

        #expect(LODLevel.high.maxLabels == 500)
        #expect(LODLevel.minimal.maxLabels == 20)
    }

    // MARK: - Batch Processing Tests

    @Test("Batch processor handles large datasets")
    func testBatchProcessor() async throws {
        let items = Array(0..<1000)
        var processedCount = 0

        await BatchProcessor.process(items, batchSize: 100) { batch in
            processedCount += batch.count
        }

        #expect(processedCount == 1000)
    }

    @Test("Batch processor respects batch size")
    func testBatchProcessorBatchSize() async throws {
        let items = Array(0..<250)
        var batchCounts: [Int] = []

        await BatchProcessor.process(items, batchSize: 100) { batch in
            batchCounts.append(batch.count)
        }

        // Should have 3 batches: 100, 100, 50
        #expect(batchCounts.count == 3)
        #expect(batchCounts[0] == 100)
        #expect(batchCounts[1] == 100)
        #expect(batchCounts[2] == 50)
    }

    // MARK: - Memory Management Tests

    @Test("Large network mock generation performance")
    func testLargeNetworkGeneration() async throws {
        let startTime = Date()

        let network = SupplyChainNetwork.mockNetwork()

        let duration = Date().timeIntervalSince(startTime)

        // Should generate quickly (< 1 second)
        #expect(duration < 1.0)
        #expect(network.nodes.count > 0)
        #expect(network.flows.count > 0)
    }

    @Test("Entity creation performance")
    func testEntityCreationPerformance() async throws {
        let startTime = Date()

        // Create 1000 nodes
        var nodes: [Node] = []
        for i in 0..<1000 {
            let node = Node(
                id: "NODE-\(i)",
                type: .warehouse,
                location: GeographicCoordinate(
                    latitude: Double.random(in: -90...90),
                    longitude: Double.random(in: -180...180)
                ),
                capacity: Capacity(total: 100, available: 50, unit: "units")
            )
            nodes.append(node)
        }

        let duration = Date().timeIntervalSince(startTime)

        // Should create quickly (< 0.5 seconds)
        #expect(duration < 0.5)
        #expect(nodes.count == 1000)
    }

    // MARK: - Cartesian Conversion Performance Tests

    @Test("Cartesian conversion performance for large datasets")
    func testCartesianConversionPerformance() async throws {
        let coordinates = (0..<1000).map { i in
            GeographicCoordinate(
                latitude: Double.random(in: -90...90),
                longitude: Double.random(in: -180...180)
            )
        }

        let startTime = Date()

        let cartesianPoints = coordinates.map { $0.toCartesian(radius: 2.5) }

        let duration = Date().timeIntervalSince(startTime)

        // Should convert quickly (< 0.1 seconds)
        #expect(duration < 0.1)
        #expect(cartesianPoints.count == 1000)
    }

    @Test("Distance calculation performance")
    func testDistanceCalculationPerformance() async throws {
        let coord1 = GeographicCoordinate(latitude: 40.7128, longitude: -74.0060)
        let coord2 = GeographicCoordinate(latitude: 34.0522, longitude: -118.2437)

        let startTime = Date()

        // Calculate 1000 distances
        for _ in 0..<1000 {
            _ = coord1.distance(to: coord2)
        }

        let duration = Date().timeIntervalSince(startTime)

        // Should calculate quickly (< 0.1 seconds)
        #expect(duration < 0.1)
    }
}

@Suite("Stress Tests")
struct StressTests {

    @Test("Handle maximum node count")
    func testMaximumNodeCount() async throws {
        var nodes: [Node] = []

        // Create 5000 nodes (stress test)
        for i in 0..<5000 {
            let node = Node(
                id: "NODE-\(i)",
                type: .warehouse,
                location: GeographicCoordinate(
                    latitude: Double.random(in: -90...90),
                    longitude: Double.random(in: -180...180)
                ),
                capacity: Capacity(total: 100, available: 50, unit: "units")
            )
            nodes.append(node)
        }

        #expect(nodes.count == 5000)

        // Create network with all nodes
        let network = SupplyChainNetwork(
            nodes: nodes,
            edges: [],
            flows: [],
            disruptions: []
        )

        #expect(network.nodes.count == 5000)
    }

    @Test("Handle maximum flow count")
    func testMaximumFlowCount() async throws {
        var flows: [Flow] = []

        // Create 10000 flows (stress test)
        for i in 0..<10000 {
            let flow = Flow(
                id: "FLOW-\(i)",
                shipmentId: "SHP-\(i)",
                currentNode: "NODE-A",
                destinationNode: "NODE-B",
                route: ["NODE-A", "NODE-B"],
                items: [],
                status: .inTransit,
                eta: Date().addingTimeInterval(3600),
                actualProgress: Double.random(in: 0...1)
            )
            flows.append(flow)
        }

        #expect(flows.count == 10000)
    }

    @Test("Concurrent data access stress test")
    func testConcurrentAccess() async throws {
        let network = SupplyChainNetwork.mockNetwork()

        // Simulate concurrent access from multiple tasks
        await withTaskGroup(of: Void.self) { group in
            for _ in 0..<100 {
                group.addTask {
                    // Read operations
                    _ = network.nodes.count
                    _ = network.flows.count
                    _ = network.edges.count
                }
            }
        }

        // Should complete without crashes
        #expect(network.nodes.count > 0)
    }
}
