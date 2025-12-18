import Foundation

/// Service for analytics operations
protocol AnalyticsService {
    /// Fetch analytics for a store within a date range
    func fetchAnalytics(storeID: UUID, dateRange: DateInterval) async throws -> StoreAnalytics

    /// Generate a heatmap for a specific type
    func generateHeatmap(storeID: UUID, type: HeatmapType) async throws -> Heatmap

    /// Analyze customer journeys for a store
    func analyzeCustomerJourneys(storeID: UUID, limit: Int?) async throws -> [CustomerJourney]

    /// Calculate performance metrics for a store
    func calculatePerformanceMetrics(storeID: UUID, dateRange: DateInterval) async throws -> PerformanceMetrics

    /// Get traffic data for specific time periods
    func getTrafficData(storeID: UUID, dateRange: DateInterval) async throws -> TrafficData

    /// Get sales data for analysis
    func getSalesData(storeID: UUID, dateRange: DateInterval) async throws -> SalesData

    /// Export analytics report
    func exportReport(storeID: UUID, format: ReportFormat) async throws -> Data
}

enum ReportFormat: String {
    case pdf
    case csv
    case json
    case excel
}
