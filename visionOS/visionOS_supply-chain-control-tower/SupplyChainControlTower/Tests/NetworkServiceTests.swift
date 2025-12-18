//
//  NetworkServiceTests.swift
//  SupplyChainControlTowerTests
//
//  Unit tests for NetworkService
//

import Testing
import Foundation
@testable import SupplyChainControlTower

@Suite("Network Service Tests")
struct NetworkServiceTests {

    // MARK: - Cache Manager Tests

    @Test("Cache manager stores and retrieves data")
    func testCacheManagerStoreRetrieve() async throws {
        let cacheManager = CacheManager()

        let testData = "Test Value"
        await cacheManager.set(testData, forKey: "test-key", ttl: 3600)

        let retrieved: String? = await cacheManager.get(forKey: "test-key")
        #expect(retrieved == testData)
    }

    @Test("Cache manager respects TTL expiration")
    func testCacheManagerTTL() async throws {
        let cacheManager = CacheManager()

        let testData = "Test Value"
        await cacheManager.set(testData, forKey: "test-key", ttl: 0.1) // 100ms TTL

        // Wait for expiration
        try await Task.sleep(for: .milliseconds(150))

        let retrieved: String? = await cacheManager.get(forKey: "test-key")
        #expect(retrieved == nil)
    }

    @Test("Cache manager invalidates keys")
    func testCacheManagerInvalidate() async throws {
        let cacheManager = CacheManager()

        let testData = "Test Value"
        await cacheManager.set(testData, forKey: "test-key", ttl: 3600)

        await cacheManager.invalidate(key: "test-key")

        let retrieved: String? = await cacheManager.get(forKey: "test-key")
        #expect(retrieved == nil)
    }

    @Test("Cache manager handles multiple keys")
    func testCacheManagerMultipleKeys() async throws {
        let cacheManager = CacheManager()

        await cacheManager.set("Value1", forKey: "key1", ttl: 3600)
        await cacheManager.set("Value2", forKey: "key2", ttl: 3600)

        let value1: String? = await cacheManager.get(forKey: "key1")
        let value2: String? = await cacheManager.get(forKey: "key2")

        #expect(value1 == "Value1")
        #expect(value2 == "Value2")
    }

    // MARK: - API Client Tests

    @Test("API endpoint paths are correct")
    func testAPIEndpointPaths() async throws {
        #expect(Endpoint.getNetwork.path == "/api/v1/network")
        #expect(Endpoint.getShipments.path == "/api/v1/shipments")
        #expect(Endpoint.getDisruptions.path == "/api/v1/disruptions")
        #expect(Endpoint.updateShipment("123").path == "/api/v1/shipments/123")
    }

    @Test("API endpoint methods are correct")
    func testAPIEndpointMethods() async throws {
        #expect(Endpoint.getNetwork.method == "GET")
        #expect(Endpoint.getShipments.method == "GET")
        #expect(Endpoint.updateShipment("123").method == "PUT")
    }

    // MARK: - API Error Tests

    @Test("API error descriptions are informative")
    func testAPIErrorDescriptions() async throws {
        let invalidResponseError = APIError.invalidResponse
        #expect(invalidResponseError.errorDescription?.contains("Invalid response") == true)

        let httpError = APIError.httpError(statusCode: 404)
        #expect(httpError.errorDescription?.contains("404") == true)
    }
}

@Suite("Geometry Extension Tests")
struct GeometryExtensionTests {

    @Test("SIMD3 normalization")
    func testSIMD3Normalization() async throws {
        let vector = SIMD3<Float>(3, 4, 0)
        let normalized = vector.normalized

        // Length should be 1.0
        let length = sqrt(normalized.x * normalized.x +
                         normalized.y * normalized.y +
                         normalized.z * normalized.z)

        #expect(abs(length - 1.0) < 0.001)
    }

    @Test("SIMD3 linear interpolation")
    func testSIMD3Lerp() async throws {
        let start = SIMD3<Float>(0, 0, 0)
        let end = SIMD3<Float>(10, 10, 10)

        let mid = start.lerp(to: end, t: 0.5)

        #expect(abs(mid.x - 5.0) < 0.001)
        #expect(abs(mid.y - 5.0) < 0.001)
        #expect(abs(mid.z - 5.0) < 0.001)
    }

    @Test("Math utils clamp function")
    func testClamp() async throws {
        #expect(MathUtils.clamp(5, min: 0, max: 10) == 5)
        #expect(MathUtils.clamp(-5, min: 0, max: 10) == 0)
        #expect(MathUtils.clamp(15, min: 0, max: 10) == 10)
    }

    @Test("Math utils map function")
    func testMap() async throws {
        let result = MathUtils.map(5, fromMin: 0, fromMax: 10, toMin: 0, toMax: 100)
        #expect(abs(result - 50.0) < 0.001)
    }

    @Test("Math utils smooth step")
    func testSmoothStep() async throws {
        #expect(MathUtils.smoothStep(0.0) == 0.0)
        #expect(MathUtils.smoothStep(1.0) == 1.0)

        let mid = MathUtils.smoothStep(0.5)
        #expect(mid >= 0.0 && mid <= 1.0)
    }

    @Test("Route waypoint generation")
    func testRouteWaypoints() async throws {
        let start = GeographicCoordinate(latitude: 0, longitude: 0)
        let end = GeographicCoordinate(latitude: 10, longitude: 10)

        let waypoints = Route.generateWaypoints(from: start, to: end, numPoints: 10)

        #expect(waypoints.count == 11) // 0 to 10 inclusive
        #expect(waypoints.first?.latitude == start.latitude)
        #expect(waypoints.last?.latitude == end.latitude)
    }
}

@Suite("ViewModel Tests")
struct ViewModelTests {

    @Test("Dashboard ViewModel initialization")
    @MainActor
    func testDashboardViewModelInit() async throws {
        let viewModel = DashboardViewModel()

        #expect(viewModel.network == nil)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage == nil)
    }

    @Test("Dashboard ViewModel loads network")
    @MainActor
    func testDashboardViewModelLoadNetwork() async throws {
        let viewModel = DashboardViewModel()

        await viewModel.loadNetwork()

        #expect(viewModel.network != nil)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.kpiMetrics.activeShipments >= 0)
    }

    @Test("Network Visualization ViewModel node selection")
    @MainActor
    func testNetworkVisualizationNodeSelection() async throws {
        let viewModel = NetworkVisualizationViewModel()

        let node = Node(
            id: "TEST",
            type: .warehouse,
            location: GeographicCoordinate(latitude: 0, longitude: 0),
            capacity: Capacity(total: 100, available: 50, unit: "units")
        )

        viewModel.selectNode(node)
        #expect(viewModel.selectedNode?.id == "TEST")

        viewModel.deselectNode()
        #expect(viewModel.selectedNode == nil)
    }

    @Test("Network Visualization ViewModel LOD updates")
    @MainActor
    func testNetworkVisualizationLOD() async throws {
        let viewModel = NetworkVisualizationViewModel()
        let network = SupplyChainNetwork.mockNetwork()

        // Close camera position
        viewModel.updateVisibleNodes(from: network, cameraPosition: SIMD3(0, 0, 1))
        #expect(viewModel.lodLevel == .high)

        // Far camera position
        viewModel.updateVisibleNodes(from: network, cameraPosition: SIMD3(0, 0, 15))
        #expect(viewModel.lodLevel == .minimal)
    }
}
