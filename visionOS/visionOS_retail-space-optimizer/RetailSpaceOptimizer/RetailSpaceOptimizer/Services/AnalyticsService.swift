import Foundation

@Observable
class AnalyticsService {
    private let apiClient: APIClient

    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    func fetchPerformanceMetrics(
        storeId: UUID,
        dateRange: DateInterval
    ) async throws -> [PerformanceMetric] {
        #if DEBUG
        if Configuration.useMockData {
            return PerformanceMetric.mockArray(count: 30)
        }
        #endif

        let metrics: [PerformanceMetric] = try await apiClient.request(
            .analytics(storeId: storeId, dateRange: dateRange)
        )
        return metrics
    }

    func generateHeatMap(
        storeId: UUID,
        metric: HeatMapData.HeatMapMetric,
        dateRange: DateInterval
    ) async throws -> HeatMapData {
        #if DEBUG
        if Configuration.useMockData {
            return mockHeatMapData(metric: metric)
        }
        #endif

        // Call API to generate heat map
        // let data: HeatMapData = try await apiClient.request(...)

        return mockHeatMapData(metric: metric)
    }

    func analyzeCustomerJourneys(
        storeId: UUID,
        dateRange: DateInterval
    ) async throws -> JourneyAnalysis {
        #if DEBUG
        if Configuration.useMockData {
            return mockJourneyAnalysis()
        }
        #endif

        // Call API to analyze journeys
        return mockJourneyAnalysis()
    }

    func compareLayouts(layoutIds: [UUID]) async throws -> ComparisonResult {
        guard layoutIds.count == 2 else {
            throw AnalyticsError.invalidComparison
        }

        #if DEBUG
        if Configuration.useMockData {
            return mockComparisonResult()
        }
        #endif

        // Call API to compare layouts
        return mockComparisonResult()
    }

    // MARK: - Mock Data Generators

    private func mockHeatMapData(metric: HeatMapData.HeatMapMetric) -> HeatMapData {
        let resolution = SIMD2<Int>(20, 30) // 20x30 grid

        var dataPoints: [[Float]] = []
        for _ in 0..<resolution.y {
            var row: [Float] = []
            for _ in 0..<resolution.x {
                row.append(Float.random(in: 0...1))
            }
            dataPoints.append(row)
        }

        return HeatMapData(
            gridResolution: resolution,
            dataPoints: dataPoints,
            metric: metric,
            timeRange: DateInterval(
                start: Date().addingTimeInterval(-30 * 24 * 60 * 60),
                end: Date()
            )
        )
    }

    private func mockJourneyAnalysis() -> JourneyAnalysis {
        JourneyAnalysis(
            totalJourneys: 1245,
            averageTime: 18 * 60, // 18 minutes
            conversionRate: 0.245,
            topPaths: [
                PathSummary(
                    pathDescription: "Entrance → Apparel → Checkout",
                    frequency: 425,
                    averageValue: 87.50
                ),
                PathSummary(
                    pathDescription: "Entrance → Electronics → Apparel → Checkout",
                    frequency: 312,
                    averageValue: 142.30
                )
            ],
            dwellHotspots: [
                DwellHotspot(
                    position: SIMD2(5, 10),
                    averageDwell: 240, // 4 minutes
                    engagement: 0.85
                )
            ]
        )
    }

    private func mockComparisonResult() -> ComparisonResult {
        ComparisonResult(
            layoutAId: UUID(),
            layoutBId: UUID(),
            metrics: ComparisonMetrics(
                salesDifference: 18.5,
                trafficDifference: 12.3,
                conversionDifference: 5.7,
                dwellTimeDifference: 8.2
            ),
            winner: .layoutB,
            confidenceLevel: 0.95
        )
    }
}

// MARK: - Analytics Errors

enum AnalyticsError: LocalizedError {
    case invalidComparison

    var errorDescription: String? {
        switch self {
        case .invalidComparison:
            return "Comparison requires exactly 2 layouts"
        }
    }
}

// MARK: - Journey Analysis

struct JourneyAnalysis: Codable {
    var totalJourneys: Int
    var averageTime: TimeInterval
    var conversionRate: Float
    var topPaths: [PathSummary]
    var dwellHotspots: [DwellHotspot]
}

struct PathSummary: Codable, Identifiable {
    var id: UUID = UUID()
    var pathDescription: String
    var frequency: Int
    var averageValue: Decimal
}

struct DwellHotspot: Codable, Identifiable {
    var id: UUID = UUID()
    var position: SIMD2<Float>
    var averageDwell: TimeInterval
    var engagement: Float
}

// MARK: - Comparison Result

struct ComparisonResult: Codable {
    var layoutAId: UUID
    var layoutBId: UUID
    var metrics: ComparisonMetrics
    var winner: Winner
    var confidenceLevel: Float

    enum Winner: String, Codable {
        case layoutA, layoutB, tie
    }
}

struct ComparisonMetrics: Codable {
    var salesDifference: Float // percentage
    var trafficDifference: Float
    var conversionDifference: Float
    var dwellTimeDifference: Float
}
