import Foundation
import SwiftData

// MARK: - Performance Data Model
@Model
final class PerformanceData {
    // MARK: - Identity
    @Attribute(.unique) var id: UUID

    // MARK: - Employee Reference
    @Relationship(deleteRule: .nullify, inverse: \Employee.performance)
    var employee: Employee?

    // MARK: - Current Performance
    var currentRating: Double = 0.0 // 0-100
    var currentReviewCycle: String = ""
    var lastReviewDate: Date?

    // MARK: - Historical Ratings
    var historicalRatings: [PerformanceRating] = []

    // MARK: - Goals & Development
    @Relationship(deleteRule: .cascade)
    var goals: [Goal] = []

    @Relationship(deleteRule: .cascade)
    var achievements: [Achievement] = []

    @Relationship(deleteRule: .cascade)
    var feedback: [Feedback] = []

    @Relationship(deleteRule: .nullify)
    var developmentPlan: DevelopmentPlan?

    // MARK: - Predictions & Insights
    var potentialScore: Double = 0.0 // 0-100 (High potential indicator)
    var flightRiskScore: Double = 0.0 // 0-100 (Attrition risk)
    var growthTrajectory: GrowthTrajectory = .steady

    // MARK: - 360 Feedback Scores
    var managerRating: Double?
    var peerRating: Double?
    var directReportRating: Double?
    var selfRating: Double?

    // MARK: - Competencies
    var technicalCompetency: Double = 0.0
    var leadershipCompetency: Double = 0.0
    var communicationCompetency: Double = 0.0
    var innovationCompetency: Double = 0.0
    var collaborationCompetency: Double = 0.0

    // MARK: - Timestamps
    var createdAt: Date
    var updatedAt: Date

    // MARK: - Initialization
    init(
        id: UUID = UUID(),
        employee: Employee? = nil
    ) {
        self.id = id
        self.employee = employee
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    // MARK: - Computed Properties
    var overallRating: Double {
        currentRating
    }

    var is360Complete: Bool {
        managerRating != nil &&
        peerRating != nil &&
        selfRating != nil
    }

    var avg360Rating: Double? {
        var ratings: [Double] = []

        if let manager = managerRating { ratings.append(manager) }
        if let peer = peerRating { ratings.append(peer) }
        if let direct = directReportRating { ratings.append(direct) }
        if let selfR = selfRating { ratings.append(selfR) }

        guard !ratings.isEmpty else { return nil }
        return ratings.reduce(0, +) / Double(ratings.count)
    }

    var completedGoalsCount: Int {
        goals.filter { $0.status == .completed }.count
    }

    var activeGoalsCount: Int {
        goals.filter { $0.status == .inProgress || $0.status == .notStarted }.count
    }

    var goalsCompletionRate: Double {
        guard !goals.isEmpty else { return 0.0 }
        return Double(completedGoalsCount) / Double(goals.count) * 100.0
    }
}

// MARK: - Performance Rating (Historical)
struct PerformanceRating: Codable {
    let reviewCycle: String // e.g., "2024-Q2"
    let rating: Double // 0-100
    let reviewDate: Date
    let comments: String?
}

// MARK: - Growth Trajectory
enum GrowthTrajectory: String, Codable {
    case rapid = "Rapid Growth"
    case steady = "Steady Progress"
    case plateau = "Plateau"
    case declining = "Needs Improvement"
}
