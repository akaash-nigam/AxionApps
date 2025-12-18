//
//  AnalyticsViewModel.swift
//  SurgicalTrainingUniverse
//
//  ViewModel for Analytics view - handles performance data and visualizations
//

import Foundation
import SwiftData
import Observation

@Observable
final class AnalyticsViewModel {

    // MARK: - Dependencies

    private let analyticsService: AnalyticsService
    private let procedureService: ProcedureService
    private let modelContext: ModelContext

    // MARK: - Published State

    var currentUser: SurgeonProfile?
    var sessions: [ProcedureSession] = []
    var selectedTimeRange: TimeRange = .last30Days
    var selectedProcedureType: ProcedureType?
    var isLoading = false
    var errorMessage: String?

    // Analytics Data
    var skillProgression: [SkillDataPoint] = []
    var procedureDistribution: [ProcedureDistributionData] = []
    var learningCurve: [LearningCurvePoint] = []
    var performanceReport: PerformanceReport?

    // MARK: - Computed Properties

    var hasData: Bool {
        !sessions.isEmpty
    }

    var totalSessions: Int {
        sessions.count
    }

    var averageAccuracy: Double {
        guard !sessions.isEmpty else { return 0 }
        return sessions.reduce(0.0) { $0 + $1.accuracyScore } / Double(sessions.count)
    }

    var averageEfficiency: Double {
        guard !sessions.isEmpty else { return 0 }
        return sessions.reduce(0.0) { $0 + $1.efficiencyScore } / Double(sessions.count)
    }

    var averageSafety: Double {
        guard !sessions.isEmpty else { return 0 }
        return sessions.reduce(0.0) { $0 + $1.safetyScore } / Double(sessions.count)
    }

    var overallScore: Double {
        (averageAccuracy + averageEfficiency + averageSafety) / 3.0
    }

    var masteryLevel: MasteryLevel {
        analyticsService.determineMasteryLevel(
            averageScore: overallScore,
            sessionCount: totalSessions
        )
    }

    // Formatted Strings
    var formattedAccuracy: String {
        String(format: "%.1f%%", averageAccuracy)
    }

    var formattedEfficiency: String {
        String(format: "%.1f%%", averageEfficiency)
    }

    var formattedSafety: String {
        String(format: "%.1f%%", averageSafety)
    }

    var formattedOverallScore: String {
        String(format: "%.1f%%", overallScore)
    }

    var masteryLevelText: String {
        switch masteryLevel {
        case .novice: return "Novice"
        case .beginner: return "Beginner"
        case .competent: return "Competent"
        case .proficient: return "Proficient"
        case .expert: return "Expert"
        }
    }

    var masteryLevelColor: String {
        switch masteryLevel {
        case .novice: return "gray"
        case .beginner: return "blue"
        case .competent: return "green"
        case .proficient: return "orange"
        case .expert: return "purple"
        }
    }

    // MARK: - Initialization

    init(
        analyticsService: AnalyticsService,
        procedureService: ProcedureService,
        modelContext: ModelContext,
        currentUser: SurgeonProfile? = nil
    ) {
        self.analyticsService = analyticsService
        self.procedureService = procedureService
        self.modelContext = modelContext
        self.currentUser = currentUser
    }

    // MARK: - Public Methods

    /// Load analytics data for the current user
    @MainActor
    func loadAnalytics() async {
        guard let user = currentUser else {
            errorMessage = "No user logged in"
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            // Load sessions based on time range
            sessions = try await loadSessionsForTimeRange(user: user, range: selectedTimeRange)

            // Calculate analytics
            await calculateAnalytics()

        } catch {
            errorMessage = "Failed to load analytics: \(error.localizedDescription)"
        }

        isLoading = false
    }

    /// Change time range and reload data
    @MainActor
    func changeTimeRange(_ range: TimeRange) async {
        selectedTimeRange = range
        await loadAnalytics()
    }

    /// Filter by procedure type
    @MainActor
    func filterByProcedure(_ type: ProcedureType?) async {
        selectedProcedureType = type
        await loadAnalytics()
    }

    /// Refresh analytics data
    @MainActor
    func refresh() async {
        await loadAnalytics()
    }

    /// Generate detailed performance report
    @MainActor
    func generateReport() async {
        guard let user = currentUser else { return }

        isLoading = true

        performanceReport = analyticsService.generatePerformanceReport(for: user)

        isLoading = false
    }

    /// Export analytics data
    func exportData() -> String {
        var csv = "Date,Procedure,Accuracy,Efficiency,Safety,Overall\n"

        for session in sessions {
            let dateString = ISO8601DateFormatter().string(from: session.startTime)
            let line = "\(dateString),\(session.procedureType.rawValue),\(session.accuracyScore),\(session.efficiencyScore),\(session.safetyScore),\(session.overallScore)\n"
            csv += line
        }

        return csv
    }

    // MARK: - Private Methods

    private func loadSessionsForTimeRange(user: SurgeonProfile, range: TimeRange) async throws -> [ProcedureSession] {
        let startDate = range.startDate
        let endDate = Date()

        var allSessions = try await procedureService.getSessions(
            for: user,
            startDate: startDate,
            endDate: endDate
        )

        // Filter by procedure type if selected
        if let procedureType = selectedProcedureType {
            allSessions = allSessions.filter { $0.procedureType == procedureType }
        }

        return allSessions
    }

    private func calculateAnalytics() async {
        // Calculate skill progression
        skillProgression = analyticsService.calculateSkillProgression(sessions: sessions)

        // Calculate procedure distribution
        procedureDistribution = analyticsService.calculateProcedureDistribution(sessions: sessions)

        // Calculate learning curve
        learningCurve = analyticsService.calculateLearningCurve(sessions: sessions)
    }

    /// Format time range for display
    func formatTimeRange() -> String {
        switch selectedTimeRange {
        case .last7Days: return "Last 7 Days"
        case .last30Days: return "Last 30 Days"
        case .last90Days: return "Last 90 Days"
        case .lastYear: return "Last Year"
        case .allTime: return "All Time"
        }
    }

    /// Get trend indicator for a metric
    func getTrend(for metric: MetricType) -> TrendDirection {
        guard sessions.count >= 2 else { return .stable }

        let recentSessions = Array(sessions.suffix(5))
        let olderSessions = Array(sessions.prefix(5))

        let recentAvg: Double
        let olderAvg: Double

        switch metric {
        case .accuracy:
            recentAvg = recentSessions.reduce(0.0) { $0 + $1.accuracyScore } / Double(recentSessions.count)
            olderAvg = olderSessions.reduce(0.0) { $0 + $1.accuracyScore } / Double(olderSessions.count)
        case .efficiency:
            recentAvg = recentSessions.reduce(0.0) { $0 + $1.efficiencyScore } / Double(recentSessions.count)
            olderAvg = olderSessions.reduce(0.0) { $0 + $1.efficiencyScore } / Double(olderSessions.count)
        case .safety:
            recentAvg = recentSessions.reduce(0.0) { $0 + $1.safetyScore } / Double(recentSessions.count)
            olderAvg = olderSessions.reduce(0.0) { $0 + $1.safetyScore } / Double(olderSessions.count)
        }

        let difference = recentAvg - olderAvg

        if difference > 2.0 {
            return .improving
        } else if difference < -2.0 {
            return .declining
        } else {
            return .stable
        }
    }
}

// MARK: - Supporting Types

enum TimeRange {
    case last7Days
    case last30Days
    case last90Days
    case lastYear
    case allTime

    var startDate: Date {
        let calendar = Calendar.current
        let now = Date()

        switch self {
        case .last7Days:
            return calendar.date(byAdding: .day, value: -7, to: now) ?? now
        case .last30Days:
            return calendar.date(byAdding: .day, value: -30, to: now) ?? now
        case .last90Days:
            return calendar.date(byAdding: .day, value: -90, to: now) ?? now
        case .lastYear:
            return calendar.date(byAdding: .year, value: -1, to: now) ?? now
        case .allTime:
            return Date.distantPast
        }
    }
}

struct SkillDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let score: Double
    let procedureType: ProcedureType
}

struct ProcedureDistributionData: Identifiable {
    let id = UUID()
    let procedureType: ProcedureType
    let count: Int
    let percentage: Double
}

struct LearningCurvePoint: Identifiable {
    let id = UUID()
    let sessionNumber: Int
    let averageScore: Double
}

struct PerformanceReport {
    let surgeon: SurgeonProfile
    let timeRange: String
    let totalSessions: Int
    let averageScores: (accuracy: Double, efficiency: Double, safety: Double)
    let masteryLevel: MasteryLevel
    let strengths: [String]
    let areasForImprovement: [String]
    let recommendations: [String]
    let generatedDate: Date
}

enum MetricType {
    case accuracy
    case efficiency
    case safety
}

enum TrendDirection {
    case improving
    case stable
    case declining

    var icon: String {
        switch self {
        case .improving: return "arrow.up.right"
        case .stable: return "arrow.right"
        case .declining: return "arrow.down.right"
        }
    }

    var color: String {
        switch self {
        case .improving: return "green"
        case .stable: return "gray"
        case .declining: return "red"
        }
    }
}
