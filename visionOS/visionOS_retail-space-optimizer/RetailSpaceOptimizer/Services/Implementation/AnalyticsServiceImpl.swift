import Foundation

final class AnalyticsServiceImpl: AnalyticsService {
    private let repository: AnalyticsRepository
    private let networkClient: NetworkClient

    init(repository: AnalyticsRepository, networkClient: NetworkClient) {
        self.repository = repository
        self.networkClient = networkClient
    }

    func fetchAnalytics(storeID: UUID, dateRange: DateInterval) async throws -> StoreAnalytics {
        // Check local cache first
        if let cached = try? await repository.fetchAnalytics(storeID: storeID, dateRange: dateRange) {
            return cached
        }

        // Fetch from server
        let analytics: StoreAnalytics = try await networkClient.request(
            .getAnalytics(storeID: storeID, dateRange: dateRange)
        )

        // Cache locally
        try? await repository.saveAnalytics(analytics)

        return analytics
    }

    func generateHeatmap(storeID: UUID, type: HeatmapType) async throws -> Heatmap {
        // Request heatmap generation from server
        let heatmap: Heatmap = try await networkClient.request(
            .generateHeatmap(storeID: storeID, type: type)
        )

        return heatmap
    }

    func analyzeCustomerJourneys(storeID: UUID, limit: Int? = nil) async throws -> [CustomerJourney] {
        let journeys: [CustomerJourney] = try await networkClient.request(
            .getCustomerJourneys(storeID: storeID, limit: limit)
        )

        return journeys
    }

    func calculatePerformanceMetrics(storeID: UUID, dateRange: DateInterval) async throws -> PerformanceMetrics {
        let analytics = try await fetchAnalytics(storeID: storeID, dateRange: dateRange)

        // Calculate comparison to previous period
        let previousRange = DateInterval(
            start: dateRange.start.addingTimeInterval(-dateRange.duration),
            end: dateRange.start
        )

        let previousAnalytics = try? await fetchAnalytics(storeID: storeID, dateRange: previousRange)

        var comparison: MetricsComparison?
        if let previous = previousAnalytics {
            comparison = calculateComparison(current: analytics, previous: previous)
        }

        return PerformanceMetrics(
            salesPerSquareFoot: analytics.salesData.salesPerSquareFoot,
            conversionRate: analytics.trafficData.conversionRate,
            averageBasketSize: analytics.salesData.averageBasketSize,
            trafficCount: analytics.trafficData.totalVisitors,
            dwellTime: analytics.trafficData.averageDwellTime,
            productDiscoveryRate: 0.7,  // Placeholder
            customerSatisfactionScore: nil,
            period: dateRange,
            comparisonToPrevious: comparison
        )
    }

    func getTrafficData(storeID: UUID, dateRange: DateInterval) async throws -> TrafficData {
        let analytics = try await fetchAnalytics(storeID: storeID, dateRange: dateRange)
        return analytics.trafficData
    }

    func getSalesData(storeID: UUID, dateRange: DateInterval) async throws -> SalesData {
        let analytics = try await fetchAnalytics(storeID: storeID, dateRange: dateRange)
        return analytics.salesData
    }

    func exportReport(storeID: UUID, format: ReportFormat) async throws -> Data {
        // Implementation for report export
        return Data()
    }

    // MARK: - Private Methods
    private func calculateComparison(current: StoreAnalytics, previous: StoreAnalytics) -> MetricsComparison {
        func percentageChange(_ current: Decimal, _ previous: Decimal) -> Double {
            guard previous > 0 else { return 0 }
            return Double(truncating: ((current - previous) / previous * 100) as NSNumber)
        }

        return MetricsComparison(
            salesChange: percentageChange(current.salesData.totalRevenue, previous.salesData.totalRevenue),
            conversionChange: current.trafficData.conversionRate - previous.trafficData.conversionRate,
            trafficChange: Double(current.trafficData.totalVisitors - previous.trafficData.totalVisitors) / Double(previous.trafficData.totalVisitors) * 100,
            dwellTimeChange: (current.trafficData.averageDwellTime - previous.trafficData.averageDwellTime) / previous.trafficData.averageDwellTime * 100
        )
    }
}
