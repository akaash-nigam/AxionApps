import Foundation

// MARK: - Analytics Service Protocol
protocol AnalyticsServiceProtocol {
    func getOrganizationMetrics() async throws -> TalentAnalytics
    func getDepartmentMetrics(departmentId: UUID) async throws -> DepartmentMetrics
    func getEngagementTrends() async throws -> [EngagementTrend]
    func getTurnoverRate() async throws -> Double
}

// MARK: - Analytics Service
@Observable
final class AnalyticsService: AnalyticsServiceProtocol {
    // MARK: - Properties
    private let apiClient: APIClient

    // MARK: - State
    var organizationMetrics: TalentAnalytics?
    var isLoading: Bool = false
    var error: Error?

    // MARK: - Initialization
    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    // MARK: - Organization Metrics
    func getOrganizationMetrics() async throws -> TalentAnalytics {
        isLoading = true
        defer { isLoading = false }

        // For development, return mock data
        let analytics = TalentAnalytics(
            timestamp: Date(),
            organizationId: "org-001",
            totalHeadcount: 247,
            departmentBreakdown: [
                "Engineering": 85,
                "Product": 32,
                "Design": 18,
                "Sales": 42,
                "Marketing": 28,
                "HR": 12,
                "Finance": 15,
                "Operations": 15
            ],
            avgTenure: 2.5 * 365 * 24 * 60 * 60, // 2.5 years in seconds
            turnoverRate: 8.2,
            eNPS: 42,
            avgEngagement: 76.5,
            avgPerformance: 82.3
        )

        self.organizationMetrics = analytics
        return analytics
    }

    // MARK: - Department Metrics
    func getDepartmentMetrics(departmentId: UUID) async throws -> DepartmentMetrics {
        DepartmentMetrics(
            departmentId: departmentId,
            headcount: Int.random(in: 15...85),
            avgEngagement: Double.random(in: 65...85),
            avgPerformance: Double.random(in: 70...90),
            turnoverRate: Double.random(in: 5...15),
            topSkills: ["Swift", "Leadership", "Communication"]
        )
    }

    // MARK: - Engagement Trends
    func getEngagementTrends() async throws -> [EngagementTrend] {
        // Generate mock trend data for last 6 months
        var trends: [EngagementTrend] = []
        let calendar = Calendar.current

        for i in 0..<6 {
            let date = calendar.date(byAdding: .month, value: -i, to: Date())!
            let score = Double.random(in: 70...85)

            trends.append(EngagementTrend(
                date: date,
                score: score,
                participationRate: Double.random(in: 75...95)
            ))
        }

        return trends.reversed()
    }

    // MARK: - Turnover Rate
    func getTurnoverRate() async throws -> Double {
        // Mock calculation
        8.2
    }
}

// MARK: - Talent Analytics
struct TalentAnalytics: Codable {
    let timestamp: Date
    let organizationId: String
    let totalHeadcount: Int
    let departmentBreakdown: [String: Int]
    let avgTenure: TimeInterval
    let turnoverRate: Double
    let eNPS: Int
    let avgEngagement: Double
    let avgPerformance: Double

    var diversityMetrics: DiversityMetrics {
        DiversityMetrics(
            genderBalance: 0.48, // % women
            ethnicDiversity: 0.62,
            ageDistribution: [
                "18-25": 0.12,
                "26-35": 0.45,
                "36-45": 0.28,
                "46-55": 0.12,
                "56+": 0.03
            ]
        )
    }
}

// MARK: - Department Metrics
struct DepartmentMetrics: Codable {
    let departmentId: UUID
    let headcount: Int
    let avgEngagement: Double
    let avgPerformance: Double
    let turnoverRate: Double
    let topSkills: [String]
}

// MARK: - Engagement Trend
struct EngagementTrend: Codable, Identifiable {
    let id = UUID()
    let date: Date
    let score: Double
    let participationRate: Double
}

// MARK: - Diversity Metrics
struct DiversityMetrics: Codable {
    let genderBalance: Double // 0-1 (0.5 is perfect balance)
    let ethnicDiversity: Double // 0-1 (diversity index)
    let ageDistribution: [String: Double]
}
