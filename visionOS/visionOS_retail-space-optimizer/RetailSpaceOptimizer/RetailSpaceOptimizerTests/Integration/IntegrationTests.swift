import XCTest
@testable import RetailSpaceOptimizer

/// Integration tests for data flow and system integration
final class IntegrationTests: XCTestCase {

    // MARK: - Store to Layout Integration

    func testStoreLayoutRelationship() async throws {
        // Given
        let store = Store.mock()
        let layout = StoreLayout.mock()

        // When
        store.layouts = [layout]

        // Then
        XCTAssertNotNil(store.layouts)
        XCTAssertEqual(store.layouts?.count, 1)
        XCTAssertEqual(store.layouts?.first?.id, layout.id)
    }

    func testLayoutFixtureRelationship() async throws {
        // Given
        let layout = StoreLayout.mock()
        let fixtures = Fixture.mockArray(count: 5)

        // When
        layout.fixtures = fixtures

        // Then
        XCTAssertNotNil(layout.fixtures)
        XCTAssertEqual(layout.fixtures?.count, 5)
    }

    // MARK: - Full Store Setup Integration

    func testCompleteStoreSetup() async throws {
        // Given - Create store
        let store = Store(
            name: "Integration Test Store",
            location: StoreLocation(
                address: "123 Integration St",
                city: "Test City",
                state: "TC",
                country: "USA",
                postalCode: "12345"
            ),
            dimensions: StoreDimensions(width: 20, length: 30, height: 4)
        )

        // When - Add layout
        let layout = StoreLayout(
            name: "Test Layout",
            layoutType: .grid
        )
        store.layouts = [layout]

        // Add fixtures to layout
        let fixtures = Fixture.mockArray(count: 10)
        layout.fixtures = fixtures

        // Add zones
        let zones = StoreZone.mockArray(count: 5)
        store.zones = zones

        // Then - Verify complete setup
        XCTAssertNotNil(store.layouts)
        XCTAssertEqual(store.layouts?.count, 1)
        XCTAssertEqual(store.layouts?.first?.fixtures?.count, 10)
        XCTAssertEqual(store.zones?.count, 5)
    }

    // MARK: - Analytics Integration

    func testStorePerformanceMetricsIntegration() async throws {
        // Given
        let store = Store.mock()
        let metrics = PerformanceMetric.mockArray(count: 30)

        // When
        store.performanceMetrics = metrics

        // Then
        XCTAssertEqual(store.performanceMetrics?.count, 30)

        // Verify metrics data
        if let firstMetric = store.performanceMetrics?.first {
            XCTAssertGreaterThan(firstMetric.salesPerSquareFoot, 0)
            XCTAssertGreaterThan(firstMetric.trafficCount, 0)
        }
    }

    func testCustomerJourneyIntegration() async throws {
        // Given
        let store = Store.mock()
        let journeys = CustomerJourney.mockArray(count: 100)

        // When
        store.customerJourneys = journeys

        // Then
        XCTAssertEqual(store.customerJourneys?.count, 100)

        // Verify journey data
        if let firstJourney = store.customerJourneys?.first {
            XCTAssertGreaterThan(firstJourney.totalTime, 0)
        }
    }

    // MARK: - Zone Performance Integration

    func testZonePerformanceTracking() async throws {
        // Given
        let zone = StoreZone.mock()
        let metric = PerformanceMetric.mock()

        // When
        zone.performanceMetric = metric

        // Then
        XCTAssertNotNil(zone.performanceMetric)
        XCTAssertEqual(zone.performanceMetric?.salesPerSquareFoot, metric.salesPerSquareFoot)
    }

    // MARK: - A/B Testing Integration

    func testABTestWithLayouts() async throws {
        // Given
        let layoutA = StoreLayout.mock()
        let layoutB = StoreLayout(
            name: "Optimized Layout",
            layoutType: .freeform
        )

        let abTest = ABTest(
            name: "Layout Comparison Test",
            testDescription: "Testing new layout configuration",
            layoutAId: layoutA.id,
            layoutBId: layoutB.id
        )

        // Add metrics
        let metricsA = PerformanceMetric.mock()
        let metricsB = PerformanceMetric(
            salesPerSquareFoot: 2520.0,
            trafficCount: 1350,
            dwellTime: 19 * 60,
            conversionRate: 0.265,
            averageBasketSize: 92.50,
            customerSatisfaction: 4.4
        )

        abTest.metricsA = metricsA
        abTest.metricsB = metricsB
        abTest.status = .completed

        // When
        abTest.analyzeResults()

        // Then
        XCTAssertNotNil(abTest.winningLayoutId)
        XCTAssertNotNil(abTest.improvementPercentage)
        XCTAssertGreaterThan(abTest.improvementPercentage ?? 0, 0)
    }

    // MARK: - Service Integration Tests

    func testEndToEndStoreCreationFlow() async throws {
        // Given
        let apiClient = APIClient(baseURL: URL(string: "https://test-api.example.com")!)
        let dataStore = DataStore()
        let cache = CacheService()
        let storeService = StoreService(apiClient: apiClient, dataStore: dataStore, cache: cache)

        let newStore = Store(
            name: "E2E Test Store",
            location: StoreLocation(
                address: "456 E2E Ave",
                city: "Integration City",
                state: "IC",
                country: "USA",
                postalCode: "54321"
            ),
            dimensions: StoreDimensions(width: 18, length: 28, height: 3.8)
        )

        // When
        let createdStore = try await storeService.createStore(newStore)
        let fetchedStore = try await storeService.fetchStore(id: createdStore.id)

        // Then
        XCTAssertEqual(createdStore.id, fetchedStore.id)
        XCTAssertEqual(createdStore.name, fetchedStore.name)
    }

    func testLayoutOptimizationFlow() async throws {
        // Given
        let apiClient = APIClient(baseURL: URL(string: "https://test-api.example.com")!)
        let layoutService = LayoutService(apiClient: apiClient)

        let layout = StoreLayout.mock()
        layout.fixtures = Fixture.mockArray(count: 15)

        // When
        let validationResult = try await layoutService.validateLayout(layout)
        let optimizedLayout = try await layoutService.optimizeLayout(layout, constraints: [])

        // Then
        XCTAssertNotNil(validationResult)
        XCTAssertNotNil(optimizedLayout)
    }

    // MARK: - Data Consistency Tests

    func testDataConsistencyAcrossModels() async throws {
        // Given
        let store = Store.mock()
        let layout = StoreLayout.mock()
        let fixtures = Fixture.mockArray(count: 20)

        // When
        store.layouts = [layout]
        layout.fixtures = fixtures

        // Then - Verify data consistency
        XCTAssertEqual(store.layouts?.first?.fixtures?.count, 20)

        // Verify all fixtures have valid positions within store dimensions
        for fixture in fixtures {
            XCTAssertGreaterThanOrEqual(fixture.position.x, 0)
            XCTAssertLessThanOrEqual(fixture.position.x, store.dimensions.width)
            XCTAssertGreaterThanOrEqual(fixture.position.z, 0)
            XCTAssertLessThanOrEqual(fixture.position.z, store.dimensions.length)
        }
    }

    // MARK: - Cache Integration Tests

    func testCacheServiceIntegration() async throws {
        // Given
        let cache = CacheService()
        let testStore = Store.mock()

        // When
        cache.cache(testStore, forKey: "test_store")
        let retrieved: Store? = cache.retrieve(forKey: "test_store")

        // Then
        XCTAssertNotNil(retrieved)
        XCTAssertEqual(retrieved?.id, testStore.id)
        XCTAssertEqual(retrieved?.name, testStore.name)
    }

    // MARK: - Performance Integration Tests

    func testLargeDataSetPerformance() async throws {
        measure {
            // Create a store with large dataset
            let store = Store.mock()
            let layouts = (0..<10).map { _ in StoreLayout.mock() }
            let fixtures = Fixture.mockArray(count: 100)
            let metrics = PerformanceMetric.mockArray(count: 365)
            let journeys = CustomerJourney.mockArray(count: 10000)

            store.layouts = layouts
            layouts.first?.fixtures = fixtures
            store.performanceMetrics = metrics
            store.customerJourneys = journeys

            // Verify performance is acceptable
            XCTAssertEqual(store.layouts?.count, 10)
            XCTAssertEqual(store.performanceMetrics?.count, 365)
            XCTAssertEqual(store.customerJourneys?.count, 10000)
        }
    }
}
