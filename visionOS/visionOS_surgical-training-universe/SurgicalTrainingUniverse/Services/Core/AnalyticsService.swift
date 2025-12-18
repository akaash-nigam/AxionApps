//
//  AnalyticsService.swift
//  Surgical Training Universe
//
//  Analytics and performance tracking service
//

import Foundation

/// Service for tracking and analyzing performance metrics
@Observable
class AnalyticsService {

    // MARK: - Session Analytics

    /// Calculate average scores for a set of sessions
    func calculateAverageScores(sessions: [ProcedureSession]) -> (accuracy: Double, efficiency: Double, safety: Double) {
        guard !sessions.isEmpty else {
            return (0, 0, 0)
        }

        let accuracy = sessions.map(\.accuracyScore).reduce(0, +) / Double(sessions.count)
        let efficiency = sessions.map(\.efficiencyScore).reduce(0, +) / Double(sessions.count)
        let safety = sessions.map(\.safetyScore).reduce(0, +) / Double(sessions.count)

        return (accuracy, efficiency, safety)
    }

    /// Calculate skill progression over time
    func calculateSkillProgression(sessions: [ProcedureSession]) -> [ProgressionPoint] {
        return sessions.sorted { $0.startTime < $1.startTime }.map { session in
            ProgressionPoint(
                date: session.startTime,
                score: session.overallScore,
                procedureType: session.procedureType
            )
        }
    }

    /// Analyze procedure distribution
    func analyzeProcedureDistribution(sessions: [ProcedureSession]) -> [ProcedureType: Int] {
        return Dictionary(grouping: sessions, by: \.procedureType)
            .mapValues { $0.count }
    }

    /// Calculate learning curve metrics
    func calculateLearningCurve(
        sessions: [ProcedureSession],
        procedureType: ProcedureType
    ) -> LearningCurveMetrics {

        let procedureSessions = sessions
            .filter { $0.procedureType == procedureType }
            .sorted { $0.startTime < $1.startTime }

        guard !procedureSessions.isEmpty else {
            return LearningCurveMetrics.empty
        }

        let firstAttempt = procedureSessions.first!
        let lastAttempt = procedureSessions.last!

        let improvement = lastAttempt.overallScore - firstAttempt.overallScore
        let attemptCount = procedureSessions.count

        let averageImprovement = improvement / Double(attemptCount)

        return LearningCurveMetrics(
            totalAttempts: attemptCount,
            initialScore: firstAttempt.overallScore,
            currentScore: lastAttempt.overallScore,
            totalImprovement: improvement,
            averageImprovement: averageImprovement,
            masteryLevel: calculateMasteryLevel(score: lastAttempt.overallScore)
        )
    }

    /// Calculate mastery level based on score
    private func calculateMasteryLevel(score: Double) -> MasteryLevel {
        switch score {
        case 0..<60: return .beginner
        case 60..<75: return .intermediate
        case 75..<90: return .advanced
        default: return .expert
        }
    }

    /// Get performance trends
    func getPerformanceTrends(sessions: [ProcedureSession], days: Int = 30) -> PerformanceTrends {
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()

        let recentSessions = sessions.filter { $0.startTime >= cutoffDate }

        let (accuracy, efficiency, safety) = calculateAverageScores(sessions: recentSessions)

        // Calculate trends (comparing to previous period)
        let previousPeriodStart = Calendar.current.date(byAdding: .day, value: -days * 2, to: cutoffDate) ?? Date()
        let previousSessions = sessions.filter { $0.startTime >= previousPeriodStart && $0.startTime < cutoffDate }

        let (prevAccuracy, prevEfficiency, prevSafety) = calculateAverageScores(sessions: previousSessions)

        return PerformanceTrends(
            accuracyTrend: accuracy - prevAccuracy,
            efficiencyTrend: efficiency - prevEfficiency,
            safetyTrend: safety - prevSafety,
            sessionCount: recentSessions.count,
            period: days
        )
    }

    /// Generate performance report
    func generatePerformanceReport(for surgeon: SurgeonProfile) -> PerformanceSummary {
        let sessions = surgeon.sessions

        let (accuracy, efficiency, safety) = calculateAverageScores(sessions: sessions)

        let procedureDistribution = analyzeProcedureDistribution(sessions: sessions)

        let totalComplications = sessions.flatMap(\.complications).count

        let averageDuration = sessions.isEmpty ? 0 : sessions.map(\.duration).reduce(0, +) / Double(sessions.count)

        return PerformanceSummary(
            totalSessions: sessions.count,
            averageAccuracy: accuracy,
            averageEfficiency: efficiency,
            averageSafety: safety,
            overallScore: (accuracy + efficiency + safety) / 3.0,
            totalComplications: totalComplications,
            averageDuration: averageDuration,
            procedureDistribution: procedureDistribution,
            certifications: surgeon.certifications.count,
            achievements: surgeon.achievements.count
        )
    }
}

// MARK: - Supporting Types

struct ProgressionPoint: Identifiable {
    let id = UUID()
    let date: Date
    let score: Double
    let procedureType: ProcedureType
}

struct LearningCurveMetrics {
    let totalAttempts: Int
    let initialScore: Double
    let currentScore: Double
    let totalImprovement: Double
    let averageImprovement: Double
    let masteryLevel: MasteryLevel

    static let empty = LearningCurveMetrics(
        totalAttempts: 0,
        initialScore: 0,
        currentScore: 0,
        totalImprovement: 0,
        averageImprovement: 0,
        masteryLevel: .beginner
    )
}

enum MasteryLevel: String {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"
    case expert = "Expert"
}

struct PerformanceTrends {
    let accuracyTrend: Double
    let efficiencyTrend: Double
    let safetyTrend: Double
    let sessionCount: Int
    let period: Int
}

struct PerformanceSummary {
    let totalSessions: Int
    let averageAccuracy: Double
    let averageEfficiency: Double
    let averageSafety: Double
    let overallScore: Double
    let totalComplications: Int
    let averageDuration: TimeInterval
    let procedureDistribution: [ProcedureType: Int]
    let certifications: Int
    let achievements: Int
}
