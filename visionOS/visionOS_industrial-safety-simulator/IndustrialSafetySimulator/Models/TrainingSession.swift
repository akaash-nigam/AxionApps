import Foundation
import SwiftData

@Model
final class TrainingSession {
    var id: UUID
    var startTime: Date
    var endTime: Date?
    var status: SessionStatus

    @Relationship
    var user: SafetyUser

    @Relationship
    var module: TrainingModule

    @Relationship(deleteRule: .cascade)
    var scenarioResults: [ScenarioResult] = []

    var overallScore: Double?
    var aiCoachingNotes: [String] = []
    var duration: TimeInterval {
        guard let endTime = endTime else {
            return Date().timeIntervalSince(startTime)
        }
        return endTime.timeIntervalSince(startTime)
    }

    init(user: SafetyUser, module: TrainingModule, startTime: Date) {
        self.id = UUID()
        self.user = user
        self.module = module
        self.startTime = startTime
        self.status = .inProgress
    }

    func complete(withScore score: Double) {
        self.endTime = Date()
        self.overallScore = score
        self.status = score >= 70.0 ? .completed : .failed
    }

    func abandon() {
        self.endTime = Date()
        self.status = .abandoned
    }
}

// MARK: - Session Status

enum SessionStatus: String, Codable {
    case scheduled = "Scheduled"
    case inProgress = "In Progress"
    case paused = "Paused"
    case completed = "Completed"
    case failed = "Failed"
    case abandoned = "Abandoned"

    var color: String {
        switch self {
        case .scheduled: return "blue"
        case .inProgress: return "orange"
        case .paused: return "yellow"
        case .completed: return "green"
        case .failed: return "red"
        case .abandoned: return "gray"
        }
    }
}

// MARK: - Scenario Result

@Model
final class ScenarioResult {
    var id: UUID
    var timestamp: Date

    @Relationship
    var scenario: SafetyScenario

    var score: Double
    var timeCompleted: TimeInterval
    var isPassed: Bool

    @Relationship(deleteRule: .cascade)
    var detectedHazards: [Hazard] = []

    @Relationship(deleteRule: .cascade)
    var missedHazards: [Hazard] = []

    var proceduresFollowed: [String] = []
    var proceduresViolated: [String] = []
    var decisionPath: [String] = []
    var aiRecommendations: [String] = []

    // Performance metrics
    var hazardDetectionAccuracy: Double {
        let total = detectedHazards.count + missedHazards.count
        guard total > 0 else { return 0 }
        return Double(detectedHazards.count) / Double(total) * 100
    }

    var procedureComplianceRate: Double {
        let total = proceduresFollowed.count + proceduresViolated.count
        guard total > 0 else { return 0 }
        return Double(proceduresFollowed.count) / Double(total) * 100
    }

    init(scenario: SafetyScenario, timeCompleted: TimeInterval, score: Double) {
        self.id = UUID()
        self.scenario = scenario
        self.timeCompleted = timeCompleted
        self.score = score
        self.isPassed = score >= scenario.passingScore
        self.timestamp = Date()
    }
}

// MARK: - User Decision

struct UserDecision: Codable {
    var timestamp: TimeInterval
    var decision: String
    var wasCorrect: Bool
    var feedback: String?
}
