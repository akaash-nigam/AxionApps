//
//  PerformanceMetrics.swift
//  MilitaryDefenseTraining
//
//  Created by Claude Code
//

import Foundation

struct PerformanceMetrics: Codable {
    var accuracy: Float // 0-100%
    var decisionSpeed: TimeInterval // avg decision time in seconds
    var tacticalScore: Int // 0-1000
    var objectivesCompleted: Int
    var totalObjectives: Int
    var casualtiesTaken: Int
    var enemiesNeutralized: Int
    var coverUsage: Float // percentage (0-100)
    var communicationEffectiveness: Float // 0-100
    var leadershipRating: Float? // 0-100 (optional, for leaders)
    var stressLevel: Float // 0-100 from biometrics
    var missionDuration: TimeInterval
    var shotsFired: Int
    var shotsHit: Int

    init(
        accuracy: Float = 0,
        decisionSpeed: TimeInterval = 0,
        tacticalScore: Int = 0,
        objectivesCompleted: Int = 0,
        totalObjectives: Int = 0,
        casualtiesTaken: Int = 0,
        enemiesNeutralized: Int = 0,
        coverUsage: Float = 0,
        communicationEffectiveness: Float = 0,
        leadershipRating: Float? = nil,
        stressLevel: Float = 0,
        missionDuration: TimeInterval = 0,
        shotsFired: Int = 0,
        shotsHit: Int = 0
    ) {
        self.accuracy = accuracy
        self.decisionSpeed = decisionSpeed
        self.tacticalScore = tacticalScore
        self.objectivesCompleted = objectivesCompleted
        self.totalObjectives = totalObjectives
        self.casualtiesTaken = casualtiesTaken
        self.enemiesNeutralized = enemiesNeutralized
        self.coverUsage = coverUsage
        self.communicationEffectiveness = communicationEffectiveness
        self.leadershipRating = leadershipRating
        self.stressLevel = stressLevel
        self.missionDuration = missionDuration
        self.shotsFired = shotsFired
        self.shotsHit = shotsHit
    }

    var grade: String {
        let percentage = Float(tacticalScore) / 10.0 // Convert to 0-100
        switch percentage {
        case 90...100: return "A+"
        case 85..<90: return "A"
        case 80..<85: return "A-"
        case 75..<80: return "B+"
        case 70..<75: return "B"
        case 65..<70: return "B-"
        case 60..<65: return "C+"
        case 55..<60: return "C"
        case 50..<55: return "C-"
        default: return "F"
        }
    }

    var hitPercentage: Float {
        guard shotsFired > 0 else { return 0 }
        return Float(shotsHit) / Float(shotsFired) * 100
    }

    var objectiveCompletionRate: Float {
        guard totalObjectives > 0 else { return 0 }
        return Float(objectivesCompleted) / Float(totalObjectives) * 100
    }
}

// MARK: - After Action Report
struct AfterActionReport: Codable {
    var sessionID: UUID
    var timestamp: Date
    var overallScore: Int
    var grade: String
    var strengths: [PerformanceArea]
    var weaknesses: [PerformanceArea]
    var recommendations: [TrainingRecommendation]
    var keyMoments: [KeyMoment]
    var decisionAnalysis: [DecisionPoint]

    init(
        sessionID: UUID,
        timestamp: Date = Date(),
        overallScore: Int,
        grade: String,
        strengths: [PerformanceArea] = [],
        weaknesses: [PerformanceArea] = [],
        recommendations: [TrainingRecommendation] = [],
        keyMoments: [KeyMoment] = [],
        decisionAnalysis: [DecisionPoint] = []
    ) {
        self.sessionID = sessionID
        self.timestamp = timestamp
        self.overallScore = overallScore
        self.grade = grade
        self.strengths = strengths
        self.weaknesses = weaknesses
        self.recommendations = recommendations
        self.keyMoments = keyMoments
        self.decisionAnalysis = decisionAnalysis
    }
}

struct PerformanceArea: Codable, Identifiable {
    var id = UUID()
    var area: String
    var score: Float
    var description: String
}

struct TrainingRecommendation: Codable, Identifiable {
    var id = UUID()
    var title: String
    var description: String
    var priority: Priority

    enum Priority: String, Codable {
        case high = "High"
        case medium = "Medium"
        case low = "Low"
    }
}

struct KeyMoment: Codable, Identifiable {
    var id = UUID()
    var timestamp: TimeInterval
    var type: MomentType
    var description: String
    var tacticalImplication: String
    var alternativeActions: [String]

    enum MomentType: String, Codable {
        case critical = "Critical"
        case success = "Success"
        case failure = "Failure"
        case tactical = "Tactical"
    }
}

struct DecisionPoint: Codable, Identifiable {
    var id = UUID()
    var timestamp: TimeInterval
    var situation: String
    var decision: String
    var outcome: DecisionOutcome
    var optimalDecision: String?
    var tacticalJustification: String

    enum DecisionOutcome: String, Codable {
        case optimal = "Optimal"
        case acceptable = "Acceptable"
        case suboptimal = "Suboptimal"
        case poor = "Poor"
    }
}
