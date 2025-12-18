import Foundation

// MARK: - Analytics State
@Observable
final class AnalyticsState {
    // MARK: - Metrics
    var organizationMetrics: TalentAnalytics?
    var engagementTrends: [EngagementTrend] = []

    // MARK: - Loading State
    var isLoading: Bool = false
    var error: Error?

    // MARK: - Time Range
    var timeRange: AnalyticsTimeRange = .last3Months
    var selectedMetric: MetricType = .engagement

    // MARK: - Methods
    @MainActor
    func loadMetrics(using analyticsService: AnalyticsService) async {
        isLoading = true
        error = nil

        do {
            async let metricsTask = analyticsService.getOrganizationMetrics()
            async let trendsTask = analyticsService.getEngagementTrends()

            (organizationMetrics, engagementTrends) = try await (metricsTask, trendsTask)

            print("✅ Loaded analytics metrics")
        } catch {
            self.error = error
            print("❌ Failed to load analytics: \(error)")
        }

        isLoading = false
    }

    // MARK: - Computed Properties
    var headcount: Int {
        organizationMetrics?.totalHeadcount ?? 0
    }

    var turnoverRate: Double {
        organizationMetrics?.turnoverRate ?? 0.0
    }

    var eNPS: Int {
        organizationMetrics?.eNPS ?? 0
    }

    var avgEngagement: Double {
        organizationMetrics?.avgEngagement ?? 0.0
    }

    var latestEngagementTrend: EngagementTrend? {
        engagementTrends.last
    }

    var engagementTrendDirection: TrendDirection {
        guard engagementTrends.count >= 2 else { return .flat }

        let latest = engagementTrends[engagementTrends.count - 1].score
        let previous = engagementTrends[engagementTrends.count - 2].score

        if latest > previous + 2 {
            return .up
        } else if latest < previous - 2 {
            return .down
        } else {
            return .flat
        }
    }
}

// MARK: - Analytics Time Range
enum AnalyticsTimeRange: String, CaseIterable {
    case lastMonth = "Last Month"
    case last3Months = "Last 3 Months"
    case last6Months = "Last 6 Months"
    case lastYear = "Last Year"
    case allTime = "All Time"
}

// MARK: - Metric Type
enum MetricType: String, CaseIterable {
    case engagement = "Engagement"
    case performance = "Performance"
    case turnover = "Turnover"
    case eNPS = "eNPS"
    case headcount = "Headcount"

    var icon: String {
        switch self {
        case .engagement: return "heart.fill"
        case .performance: return "chart.bar.fill"
        case .turnover: return "arrow.triangle.2.circlepath"
        case .eNPS: return "star.fill"
        case .headcount: return "person.3.fill"
        }
    }

    var color: String {
        switch self {
        case .engagement: return "#30D158"
        case .performance: return "#0A84FF"
        case .turnover: return "#FF3B30"
        case .eNPS: return "#FFD700"
        case .headcount: return "#5E5CE6"
        }
    }
}

// MARK: - Trend Direction
enum TrendDirection {
    case up
    case down
    case flat

    var icon: String {
        switch self {
        case .up: return "arrow.up.right"
        case .down: return "arrow.down.right"
        case .flat: return "arrow.right"
        }
    }

    var color: String {
        switch self {
        case .up: return "#30D158"
        case .down: return "#FF3B30"
        case .flat: return "#8E8E93"
        }
    }
}
