import Foundation
import SwiftData

@Model
final class PerformanceMetrics {
    var id: UUID
    var userId: UUID
    var lastUpdated: Date

    // Training Statistics
    var totalTrainingHours: TimeInterval = 0
    var scenariosCompleted: Int = 0
    var scenariosPassed: Int = 0
    var scenariosFailed: Int = 0

    // Performance Scores
    var averageScore: Double = 0
    var bestScore: Double = 0
    var latestScore: Double = 0

    // Safety Metrics
    var hazardRecognitionAccuracy: Double = 0
    var emergencyResponseTime: TimeInterval = 0
    var safetyComplianceRate: Double = 0
    var procedureAdherenceRate: Double = 0

    // Skill Levels by Category
    var hazardRecognitionLevel: SkillLevel = .beginner
    var emergencyResponseLevel: SkillLevel = .beginner
    var equipmentSafetyLevel: SkillLevel = .beginner
    var chemicalHandlingLevel: SkillLevel = .beginner

    // Trend Data
    var improvementTrend: Double = 0 // Positive = improving, Negative = declining
    var consistencyScore: Double = 0 // 0-100, higher = more consistent

    // Risk Assessment
    var riskScore: Double = 0 // 0-100, lower = safer
    var incidentPrediction: Double = 0 // 0-100, lower = less likely

    // Achievements
    var achievementsUnlocked: [String] = []
    var certificationsEarned: [String] = []

    init(userId: UUID) {
        self.id = UUID()
        self.userId = userId
        self.lastUpdated = Date()
    }

    // MARK: - Computed Properties

    var passRate: Double {
        guard scenariosCompleted > 0 else { return 0 }
        return Double(scenariosPassed) / Double(scenariosCompleted) * 100
    }

    var overallSkillLevel: SkillLevel {
        let levels = [
            hazardRecognitionLevel,
            emergencyResponseLevel,
            equipmentSafetyLevel,
            chemicalHandlingLevel
        ]

        let sum = levels.reduce(0) { $0 + $1.rawValue }
        let average = Double(sum) / Double(levels.count)

        if average < 1.5 { return .beginner }
        if average < 2.5 { return .intermediate }
        if average < 3.5 { return .advanced }
        return .expert
    }

    // MARK: - Update Methods

    func updateAfterSession(_ result: ScenarioResult) {
        scenariosCompleted += 1

        if result.isPassed {
            scenariosPassed += 1
        } else {
            scenariosFailed += 1
        }

        // Update averageScore
        let total = averageScore * Double(scenariosCompleted - 1) + result.score
        averageScore = total / Double(scenariosCompleted)

        // Update best score
        if result.score > bestScore {
            bestScore = result.score
        }

        latestScore = result.score

        // Update hazard recognition accuracy
        hazardRecognitionAccuracy = (hazardRecognitionAccuracy + result.hazardDetectionAccuracy) / 2

        lastUpdated = Date()
    }

    func calculateRiskScore(based on recentResults: [ScenarioResult]) -> Double {
        guard !recentResults.isEmpty else { return 50.0 }

        var riskFactors: [Double] = []

        // Factor 1: Recent failure rate
        let failures = recentResults.filter { !$0.isPassed }.count
        let failureRate = Double(failures) / Double(recentResults.count) * 100
        riskFactors.append(failureRate)

        // Factor 2: Hazard detection accuracy (inverse)
        let avgHazardAccuracy = recentResults.reduce(0.0) { $0 + $1.hazardDetectionAccuracy } / Double(recentResults.count)
        riskFactors.append(100 - avgHazardAccuracy)

        // Factor 3: Procedure violations
        let avgViolations = recentResults.reduce(0.0) { $0 + Double($1.proceduresViolated.count) } / Double(recentResults.count)
        riskFactors.append(min(avgViolations * 10, 100))

        // Calculate weighted average
        return riskFactors.reduce(0, +) / Double(riskFactors.count)
    }
}

// MARK: - Skill Level

enum SkillLevel: Int, Codable, Comparable {
    case beginner = 1
    case intermediate = 2
    case advanced = 3
    case expert = 4

    static func < (lhs: SkillLevel, rhs: SkillLevel) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    var displayName: String {
        switch self {
        case .beginner: return "Beginner"
        case .intermediate: return "Intermediate"
        case .advanced: return "Advanced"
        case .expert: return "Expert"
        }
    }

    var color: String {
        switch self {
        case .beginner: return "gray"
        case .intermediate: return "blue"
        case .advanced: return "purple"
        case .expert: return "gold"
        }
    }
}

// MARK: - Trend Data

struct TrendData: Codable {
    var weeklyScores: [Double]
    var monthlyScores: [Double]
    var direction: TrendDirection

    enum TrendDirection: String, Codable {
        case improving = "Improving"
        case stable = "Stable"
        case declining = "Declining"
    }
}

// MARK: - Certification Status

struct CertificationStatus: Codable {
    var name: String
    var isValid: Bool
    var expirationDate: Date?
    var renewalRequired: Bool
}
