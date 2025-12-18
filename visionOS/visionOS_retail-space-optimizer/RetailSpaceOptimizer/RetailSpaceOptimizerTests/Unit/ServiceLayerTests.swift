import XCTest
@testable import RetailSpaceOptimizer

/// Unit tests for service layer
final class ServiceLayerTests: XCTestCase {

    var storeService: StoreService!
    var layoutService: LayoutService!
    var analyticsService: AnalyticsService!
    var simulationService: SimulationService!

    override func setUp() {
        super.setUp()

        let apiClient = APIClient(baseURL: URL(string: "https://test-api.example.com")!)
        let dataStore = DataStore()
        let cache = CacheService()

        storeService = StoreService(apiClient: apiClient, dataStore: dataStore, cache: cache)
        layoutService = LayoutService(apiClient: apiClient)
        analyticsService = AnalyticsService(apiClient: apiClient)
        simulationService = SimulationService()
    }

    override func tearDown() {
        storeService = nil
        layoutService = nil
        analyticsService = nil
        simulationService = nil

        super.tearDown()
    }

    // MARK: - StoreService Tests

    func testFetchStoresInMockMode() async throws {
        // When (using mock data in DEBUG mode)
        let stores = try await storeService.fetchStores()

        // Then
        XCTAssertEqual(stores.count, 5)
        XCTAssertEqual(stores[0].name, "Downtown Flagship")
    }

    func testFetchSingleStore() async throws {
        // Given
        let testId = UUID()

        // When
        let store = try await storeService.fetchStore(id: testId)

        // Then
        XCTAssertNotNil(store)
        XCTAssertEqual(store.name, "Downtown Flagship")
    }

    func testCreateStore() async throws {
        // Given
        let newStore = Store(
            name: "New Test Store",
            location: StoreLocation(
                address: "789 Test St",
                city: "Test City",
                state: "TC",
                country: "USA",
                postalCode: "12345"
            ),
            dimensions: StoreDimensions(width: 15, length: 25, height: 3.5)
        )

        // When
        let createdStore = try await storeService.createStore(newStore)

        // Then
        XCTAssertNotNil(createdStore.id)
        XCTAssertEqual(createdStore.name, "New Test Store")
    }

    // MARK: - LayoutService Tests

    func testFetchLayouts() async throws {
        // Given
        let storeId = UUID()

        // When
        let layouts = try await layoutService.fetchLayouts(storeId: storeId)

        // Then
        XCTAssertGreaterThan(layouts.count, 0)
        XCTAssertEqual(layouts.first?.name, "Standard Layout")
    }

    func testLayoutValidation() async throws {
        // Given
        let layout = StoreLayout.mock()

        // When
        let result = try await layoutService.validateLayout(layout)

        // Then
        XCTAssertNotNil(result)
        // In a clean layout, should have no errors
        let errors = result.issues.filter { $0.severity == .error }
        XCTAssertEqual(errors.count, 0)
    }

    func testLayoutOptimization() async throws {
        // Given
        let layout = StoreLayout.mock()
        let constraints: [LayoutConstraint] = []

        // When
        let optimizedLayout = try await layoutService.optimizeLayout(layout, constraints: constraints)

        // Then
        XCTAssertNotNil(optimizedLayout)
        XCTAssertEqual(optimizedLayout.id, layout.id)
    }

    // MARK: - AnalyticsService Tests

    func testFetchPerformanceMetrics() async throws {
        // Given
        let storeId = UUID()
        let dateRange = DateInterval(
            start: Date().addingTimeInterval(-30 * 24 * 60 * 60),
            end: Date()
        )

        // When
        let metrics = try await analyticsService.fetchPerformanceMetrics(
            storeId: storeId,
            dateRange: dateRange
        )

        // Then
        XCTAssertGreaterThan(metrics.count, 0)
        XCTAssertNotNil(metrics.first?.salesPerSquareFoot)
    }

    func testGenerateHeatMap() async throws {
        // Given
        let storeId = UUID()
        let dateRange = DateInterval(start: Date().addingTimeInterval(-7 * 24 * 60 * 60), end: Date())

        // When
        let heatMap = try await analyticsService.generateHeatMap(
            storeId: storeId,
            metric: .traffic,
            dateRange: dateRange
        )

        // Then
        XCTAssertNotNil(heatMap)
        XCTAssertGreaterThan(heatMap.gridResolution.x, 0)
        XCTAssertGreaterThan(heatMap.gridResolution.y, 0)
        XCTAssertGreaterThan(heatMap.dataPoints.count, 0)
    }

    func testAnalyzeCustomerJourneys() async throws {
        // Given
        let storeId = UUID()
        let dateRange = DateInterval(start: Date().addingTimeInterval(-30 * 24 * 60 * 60), end: Date())

        // When
        let analysis = try await analyticsService.analyzeCustomerJourneys(
            storeId: storeId,
            dateRange: dateRange
        )

        // Then
        XCTAssertGreaterThan(analysis.totalJourneys, 0)
        XCTAssertGreaterThan(analysis.topPaths.count, 0)
    }

    func testCompareLayouts() async throws {
        // Given
        let layoutIds = [UUID(), UUID()]

        // When
        let comparison = try await analyticsService.compareLayouts(layoutIds: layoutIds)

        // Then
        XCTAssertNotNil(comparison)
        XCTAssertEqual(comparison.layoutAId, layoutIds[0])
        XCTAssertEqual(comparison.layoutBId, layoutIds[1])
    }

    func testCompareLayoutsWithInvalidCount() async {
        // Given
        let invalidLayoutIds = [UUID()] // Only one ID

        // Then
        do {
            _ = try await analyticsService.compareLayouts(layoutIds: invalidLayoutIds)
            XCTFail("Should throw error with invalid layout count")
        } catch {
            XCTAssertTrue(error is AnalyticsError)
        }
    }

    // MARK: - SimulationService Tests

    func testCustomerFlowSimulation() async throws {
        // Given
        let layout = StoreLayout.mock()
        let personas = [CustomerPersona.mock(), CustomerPersona.mock()]
        let duration: TimeInterval = 3600 // 1 hour

        // When
        let result = try await simulationService.simulateCustomerFlow(
            layout: layout,
            personas: personas,
            duration: duration
        )

        // Then
        XCTAssertNotNil(result)
        XCTAssertEqual(result.journeys.count, personas.count)
        XCTAssertNotNil(result.aggregateMetrics)
        XCTAssertGreaterThan(result.heatMap.count, 0)
    }

    func testPredictPerformance() async throws {
        // Given
        let layout = StoreLayout.mock()

        // When
        let projection = try await simulationService.predictPerformance(layout: layout)

        // Then
        XCTAssertNotNil(projection)
        XCTAssertGreaterThan(projection.expectedSalesPerSqFt, 0)
        XCTAssertGreaterThan(projection.expectedConversionRate, 0)
        XCTAssertLessThan(projection.expectedConversionRate, 1)
    }

    // MARK: - Performance Tests

    func testFetchStoresPerformance() {
        measure {
            Task {
                _ = try? await storeService.fetchStores()
            }
        }
    }

    func testSimulationPerformance() {
        measure {
            Task {
                let layout = StoreLayout.mock()
                let personas = [CustomerPersona.mock()]
                _ = try? await simulationService.simulateCustomerFlow(
                    layout: layout,
                    personas: personas,
                    duration: 1800
                )
            }
        }
    }
}

// MARK: - Mock Extensions

extension CustomerPersona {
    static func mock() -> CustomerPersona {
        CustomerPersona(
            demographicProfile: "Adult 25-35",
            shoppingMission: .planned,
            timeConstraint: .moderate,
            priceSensitivity: 0.5,
            brandPreferences: ["TestBrand"]
        )
    }
}
