//
//  AdvancedPerformanceTests.swift
//  SupplyChainControlTowerTests
//
//  Advanced performance and benchmarking tests
//

import Testing
import Foundation
@testable import SupplyChainControlTower

@Suite("Advanced Performance Tests")
struct AdvancedPerformanceTests {

    // MARK: - Rendering Performance

    @Test("3D Globe rendering performance with 1000 nodes")
    func testGlobeRenderingPerformance() async throws {
        let network = generateLargeNetwork(nodeCount: 1000)
        let globeRadius: Float = 2.5

        let startTime = Date()

        // Convert all nodes to 3D positions
        let positions = network.nodes.map { node in
            node.location.toCartesian(radius: globeRadius)
        }

        let duration = Date().timeIntervalSince(startTime)

        // Should complete in < 50ms for smooth rendering
        #expect(duration < 0.05)
        #expect(positions.count == 1000)
    }

    @Test("Route arc generation performance")
    func testRouteArcGenerationPerformance() async throws {
        let network = SupplyChainNetwork.mockNetwork()
        let globeRadius: Float = 2.5

        let startTime = Date()

        // Generate waypoints for all active flows
        var allWaypoints: [[GeographicCoordinate]] = []
        for flow in network.flows where flow.status == .inTransit {
            guard let sourceNode = network.nodes.first(where: { $0.id == flow.currentNode }),
                  let destNode = network.nodes.first(where: { $0.id == flow.destinationNode }) else {
                continue
            }

            let waypoints = Route.generateWaypoints(
                from: sourceNode.location,
                to: destNode.location,
                numPoints: 20
            )
            allWaypoints.append(waypoints)
        }

        let duration = Date().timeIntervalSince(startTime)

        // Should generate all routes quickly
        #expect(duration < 0.1)
        #expect(allWaypoints.count > 0)
    }

    // MARK: - Memory Performance

    @Test("Memory usage with large dataset")
    func testMemoryUsageWithLargeDataset() async throws {
        let initialMemory = currentMemoryUsage()

        // Create large network
        let network = generateLargeNetwork(nodeCount: 5000, flowCount: 10000)

        let finalMemory = currentMemoryUsage()
        let memoryIncrease = finalMemory - initialMemory

        // Should stay under 500MB for large dataset
        #expect(memoryIncrease < 500_000_000)
        #expect(network.nodes.count == 5000)
        #expect(network.flows.count == 10000)
    }

    @Test("Memory efficiency with entity pooling")
    func testEntityPoolingMemoryEfficiency() async throws {
        class TestEntity {
            var data: [Double] = Array(repeating: 0.0, count: 100)
        }

        let pool = EntityPool<TestEntity>(maxSize: 100) { TestEntity() }

        let initialMemory = currentMemoryUsage()

        // Acquire and release entities many times
        for _ in 0..<1000 {
            let entities = await (0..<50).asyncMap { _ in
                await pool.acquire()
            }

            for entity in entities {
                await pool.release(entity)
            }
        }

        let finalMemory = currentMemoryUsage()
        let memoryIncrease = finalMemory - initialMemory

        // Memory should not significantly increase due to pooling
        #expect(memoryIncrease < 50_000_000) // < 50MB
    }

    // MARK: - Concurrency Performance

    @Test("Concurrent data processing performance")
    func testConcurrentDataProcessing() async throws {
        let network = generateLargeNetwork(nodeCount: 1000)

        let startTime = Date()

        // Process nodes concurrently
        let results = await withTaskGroup(of: (String, Double).self) { group in
            for node in network.nodes {
                group.addTask {
                    // Simulate complex calculation
                    let utilization = node.capacity.utilization
                    return (node.id, utilization)
                }
            }

            var collected: [(String, Double)] = []
            for await result in group {
                collected.append(result)
            }
            return collected
        }

        let duration = Date().timeIntervalSince(startTime)

        // Concurrent processing should be fast
        #expect(duration < 0.5)
        #expect(results.count == 1000)
    }

    @Test("Actor isolation overhead")
    func testActorIsolationOverhead() async throws {
        let cacheManager = CacheManager()

        let startTime = Date()

        // Perform many cache operations
        for i in 0..<1000 {
            await cacheManager.set("value\(i)", forKey: "key\(i)", ttl: 3600)
        }

        for i in 0..<1000 {
            let _: String? = await cacheManager.get(forKey: "key\(i)")
        }

        let duration = Date().timeIntervalSince(startTime)

        // Actor operations should still be fast
        #expect(duration < 1.0)
    }

    // MARK: - LOD System Performance

    @Test("LOD system culling performance")
    func testLODCullingPerformance() async throws {
        let network = generateLargeNetwork(nodeCount: 10000)
        let viewModel = NetworkVisualizationViewModel()

        let startTime = Date()

        // Update visible nodes at minimal LOD
        viewModel.updateVisibleNodes(from: network, cameraPosition: SIMD3(0, 0, 20))

        let duration = Date().timeIntervalSince(startTime)

        // LOD culling should be very fast
        #expect(duration < 0.1)
        #expect(viewModel.lodLevel == .minimal)
        #expect(viewModel.visibleNodes.count <= LODLevel.minimal.maxNodes)
    }

    @Test("LOD transitions are smooth")
    func testLODTransitionPerformance() async throws {
        let network = generateLargeNetwork(nodeCount: 5000)
        let viewModel = NetworkVisualizationViewModel()

        let startTime = Date()

        // Simulate camera moving through LOD levels
        let distances: [Float] = [2.0, 6.0, 12.0, 20.0, 12.0, 6.0, 2.0]
        for distance in distances {
            viewModel.updateVisibleNodes(from: network, cameraPosition: SIMD3(0, 0, distance))
        }

        let duration = Date().timeIntervalSince(startTime)

        // All LOD transitions should complete quickly
        #expect(duration < 0.5)
    }

    // MARK: - Batch Processing Performance

    @Test("Batch update performance")
    func testBatchUpdatePerformance() async throws {
        var flows = Array(repeating: Flow(
            id: "test",
            shipmentId: "ship",
            currentNode: "A",
            destinationNode: "B",
            route: ["A", "B"],
            items: [],
            status: .inTransit,
            eta: Date(),
            actualProgress: 0.5
        ), count: 10000)

        let startTime = Date()

        // Batch update all flows
        await BatchProcessor.process(flows, batchSize: 500) { batch in
            for i in batch.indices {
                flows[i].actualProgress = min(1.0, flows[i].actualProgress + 0.01)
            }
        }

        let duration = Date().timeIntervalSince(startTime)

        // Should process 10k items quickly
        #expect(duration < 2.0)
    }

    // MARK: - Network Performance

    @Test("API response parsing performance")
    func testAPIResponseParsingPerformance() async throws {
        let network = generateLargeNetwork(nodeCount: 1000, flowCount: 2000)

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(network)

        let startTime = Date()

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decoded = try decoder.decode(SupplyChainNetwork.self, from: data)

        let duration = Date().timeIntervalSince(startTime)

        // Should decode large response quickly (< 100ms)
        #expect(duration < 0.1)
        #expect(decoded.nodes.count == 1000)
        #expect(decoded.flows.count == 2000)
    }

    // MARK: - Search & Filter Performance

    @Test("Search performance on large dataset")
    func testSearchPerformance() async throws {
        let network = generateLargeNetwork(nodeCount: 10000)

        let startTime = Date()

        // Search for nodes
        let results = network.nodes.filter { node in
            node.id.contains("1000") ||
            node.type == .warehouse ||
            node.status == .healthy
        }

        let duration = Date().timeIntervalSince(startTime)

        // Search should be fast even on large dataset
        #expect(duration < 0.05)
        #expect(results.count > 0)
    }

    @Test("Multi-filter performance")
    func testMultiFilterPerformance() async throws {
        let viewModel = ControlPanelViewModel()
        let network = generateLargeNetwork(nodeCount: 5000, flowCount: 10000)

        let startTime = Date()

        // Apply multiple filters
        let filteredNodes = network.nodes.filter { node in
            viewModel.shouldDisplayNode(node)
        }

        let filteredFlows = network.flows.filter { flow in
            viewModel.shouldDisplayFlow(flow)
        }

        let duration = Date().timeIntervalSince(startTime)

        // Filtering should be fast
        #expect(duration < 0.2)
    }

    // MARK: - Calculation Performance

    @Test("Distance matrix calculation performance")
    func testDistanceMatrixPerformance() async throws {
        let nodeCount = 100
        let nodes = (0..<nodeCount).map { i in
            GeographicCoordinate(
                latitude: Double.random(in: -90...90),
                longitude: Double.random(in: -180...180)
            )
        }

        let startTime = Date()

        // Calculate distance matrix
        var matrix: [[Double]] = []
        for i in 0..<nodeCount {
            var row: [Double] = []
            for j in 0..<nodeCount {
                let distance = nodes[i].distance(to: nodes[j])
                row.append(distance)
            }
            matrix.append(row)
        }

        let duration = Date().timeIntervalSince(startTime)

        // 100x100 matrix should calculate quickly
        #expect(duration < 1.0)
        #expect(matrix.count == 100)
        #expect(matrix[0].count == 100)
    }

    // MARK: - Helpers

    private func generateLargeNetwork(nodeCount: Int, flowCount: Int = 0) -> SupplyChainNetwork {
        let nodes = (0..<nodeCount).map { i in
            Node(
                id: "NODE-\(i)",
                type: NodeType.allCases.randomElement()!,
                location: GeographicCoordinate(
                    latitude: Double.random(in: -90...90),
                    longitude: Double.random(in: -180...180)
                ),
                capacity: Capacity(
                    total: Int.random(in: 100...10000),
                    available: Int.random(in: 0...5000),
                    unit: "units"
                )
            )
        }

        let flows = (0..<flowCount).map { i in
            Flow(
                id: "FLOW-\(i)",
                shipmentId: "SHP-\(i)",
                currentNode: nodes.randomElement()!.id,
                destinationNode: nodes.randomElement()!.id,
                route: [nodes.randomElement()!.id, nodes.randomElement()!.id],
                items: [],
                status: FlowStatus.allCases.randomElement()!,
                eta: Date().addingTimeInterval(Double.random(in: 3600...86400)),
                actualProgress: Double.random(in: 0...1)
            )
        }

        return SupplyChainNetwork(
            nodes: nodes,
            edges: [],
            flows: flows,
            disruptions: []
        )
    }

    private func currentMemoryUsage() -> UInt64 {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4

        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_,
                         task_flavor_t(MACH_TASK_BASIC_INFO),
                         $0,
                         &count)
            }
        }

        if kerr == KERN_SUCCESS {
            return info.resident_size
        }
        return 0
    }
}

// MARK: - Benchmark Utilities

struct Benchmark {
    let name: String
    var measurements: [TimeInterval] = []

    mutating func measure(_ operation: () -> Void) {
        let start = Date()
        operation()
        let duration = Date().timeIntervalSince(start)
        measurements.append(duration)
    }

    mutating func measureAsync(_ operation: () async -> Void) async {
        let start = Date()
        await operation()
        let duration = Date().timeIntervalSince(start)
        measurements.append(duration)
    }

    var average: TimeInterval {
        guard !measurements.isEmpty else { return 0 }
        return measurements.reduce(0, +) / Double(measurements.count)
    }

    var min: TimeInterval {
        measurements.min() ?? 0
    }

    var max: TimeInterval {
        measurements.max() ?? 0
    }

    var standardDeviation: TimeInterval {
        guard measurements.count > 1 else { return 0 }

        let avg = average
        let variance = measurements.reduce(0) { $0 + pow($1 - avg, 2) } / Double(measurements.count - 1)
        return sqrt(variance)
    }

    func report() {
        print("""
        Benchmark: \(name)
        Average: \(String(format: "%.4f", average * 1000))ms
        Min: \(String(format: "%.4f", min * 1000))ms
        Max: \(String(format: "%.4f", max * 1000))ms
        StdDev: \(String(format: "%.4f", standardDeviation * 1000))ms
        Iterations: \(measurements.count)
        """)
    }
}

// MARK: - Sequence Extension

extension Sequence {
    func asyncMap<T>(_ transform: @escaping (Element) async -> T) async -> [T] {
        var results: [T] = []
        for element in self {
            let result = await transform(element)
            results.append(result)
        }
        return results
    }
}
