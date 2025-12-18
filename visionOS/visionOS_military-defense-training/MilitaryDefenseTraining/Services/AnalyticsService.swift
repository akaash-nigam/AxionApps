//
//  AnalyticsService.swift
//  MilitaryDefenseTraining
//
//  Created by Claude Code
//

import Foundation
import Observation

actor AnalyticsService {
    private var eventLog: [TrainingEvent] = []
    private var performanceHistory: [UUID: [PerformanceMetrics]] = [:]

    // MARK: - Event Recording

    func recordEvent(_ event: TrainingEvent) {
        eventLog.append(event)
    }

    func recordEvents(_ events: [TrainingEvent]) {
        eventLog.append(contentsOf: events)
    }

    // MARK: - After Action Report Generation

    func generateAfterActionReport(
        session: TrainingSession,
        events: [TrainingEvent],
        finalMetrics: PerformanceMetrics
    ) async -> AfterActionReport {
        // Store metrics history
        if performanceHistory[session.warriorID] == nil {
            performanceHistory[session.warriorID] = []
        }
        performanceHistory[session.warriorID]?.append(finalMetrics)

        // Analyze strengths
        let strengths = analyzeStrengths(metrics: finalMetrics)

        // Analyze weaknesses
        let weaknesses = analyzeWeaknesses(metrics: finalMetrics)

        // Generate AI recommendations
        let recommendations = await generateRecommendations(
            metrics: finalMetrics,
            weaknesses: weaknesses,
            history: performanceHistory[session.warriorID] ?? []
        )

        // Extract key moments
        let keyMoments = extractKeyMoments(from: events)

        // Analyze decisions
        let decisions = analyzeDecisions(from: events, metrics: finalMetrics)

        return AfterActionReport(
            sessionID: session.id,
            timestamp: Date(),
            overallScore: finalMetrics.tacticalScore,
            grade: finalMetrics.grade,
            strengths: strengths,
            weaknesses: weaknesses,
            recommendations: recommendations,
            keyMoments: keyMoments,
            decisionAnalysis: decisions
        )
    }

    // MARK: - Performance Analysis

    private func analyzeStrengths(metrics: PerformanceMetrics) -> [PerformanceArea] {
        var strengths: [PerformanceArea] = []

        if metrics.accuracy > 75 {
            strengths.append(PerformanceArea(
                area: "Marksmanship",
                score: metrics.accuracy,
                description: "Excellent weapon accuracy under combat conditions"
            ))
        }

        if metrics.coverUsage > 70 {
            strengths.append(PerformanceArea(
                area: "Tactical Movement",
                score: metrics.coverUsage,
                description: "Effective use of cover and concealment"
            ))
        }

        if metrics.objectiveCompletionRate >= 100 {
            strengths.append(PerformanceArea(
                area: "Mission Focus",
                score: 100,
                description: "All objectives completed successfully"
            ))
        }

        if metrics.casualtiesTaken == 0 {
            strengths.append(PerformanceArea(
                area: "Survivability",
                score: 100,
                description: "Zero casualties - excellent force protection"
            ))
        }

        if metrics.decisionSpeed < 3.0 {
            strengths.append(PerformanceArea(
                area: "Decision Making",
                score: 100 - Float(metrics.decisionSpeed * 10),
                description: "Quick and decisive tactical decisions"
            ))
        }

        return strengths
    }

    private func analyzeWeaknesses(metrics: PerformanceMetrics) -> [PerformanceArea] {
        var weaknesses: [PerformanceArea] = []

        if metrics.accuracy < 50 {
            weaknesses.append(PerformanceArea(
                area: "Marksmanship",
                score: metrics.accuracy,
                description: "Low accuracy - recommend weapon familiarization training"
            ))
        }

        if metrics.coverUsage < 40 {
            weaknesses.append(PerformanceArea(
                area: "Tactical Movement",
                score: metrics.coverUsage,
                description: "Insufficient use of cover - high exposure to enemy fire"
            ))
        }

        if metrics.casualtiesTaken > 0 {
            weaknesses.append(PerformanceArea(
                area: "Force Protection",
                score: Float(max(0, 100 - metrics.casualtiesTaken * 20)),
                description: "Casualties taken - review tactical approach"
            ))
        }

        if metrics.decisionSpeed > 5.0 {
            weaknesses.append(PerformanceArea(
                area: "Decision Speed",
                score: Float(max(0, 100 - metrics.decisionSpeed * 5)),
                description: "Slow decision making under pressure"
            ))
        }

        let ammoEfficiency = Float(metrics.shotsHit) / max(Float(metrics.shotsFired), 1.0)
        if ammoEfficiency < 0.3 {
            weaknesses.append(PerformanceArea(
                area: "Ammunition Management",
                score: ammoEfficiency * 100,
                description: "Poor ammo efficiency - focus on aimed fire"
            ))
        }

        return weaknesses
    }

    // MARK: - AI Recommendations

    private func generateRecommendations(
        metrics: PerformanceMetrics,
        weaknesses: [PerformanceArea],
        history: [PerformanceMetrics]
    ) async -> [TrainingRecommendation] {
        var recommendations: [TrainingRecommendation] = []

        // Accuracy recommendations
        if metrics.accuracy < 60 {
            recommendations.append(TrainingRecommendation(
                title: "Weapons Qualification Course",
                description: "Complete marksmanship training to improve accuracy. Focus on breathing control, trigger squeeze, and follow-through.",
                priority: .high
            ))
        }

        // Cover usage recommendations
        if metrics.coverUsage < 50 {
            recommendations.append(TrainingRecommendation(
                title: "Tactical Movement Drills",
                description: "Practice bounding overwatch and proper use of terrain. Always move from cover to cover.",
                priority: .high
            ))
        }

        // Decision speed recommendations
        if metrics.decisionSpeed > 4.0 {
            recommendations.append(TrainingRecommendation(
                title: "Decision Making Under Stress",
                description: "Rehearse common scenarios to improve reaction time. Use the OODA loop: Observe, Orient, Decide, Act.",
                priority: .medium
            ))
        }

        // Progressive difficulty recommendations
        if metrics.tacticalScore > 800 && history.count >= 3 {
            let recentAverage = history.suffix(3).reduce(0) { $0 + $1.tacticalScore } / 3
            if recentAverage > 750 {
                recommendations.append(TrainingRecommendation(
                    title: "Increase Difficulty Level",
                    description: "You're consistently performing well. Consider moving to a higher difficulty level for greater challenge.",
                    priority: .medium
                ))
            }
        }

        // Objective focus recommendations
        if metrics.objectiveCompletionRate < 100 {
            recommendations.append(TrainingRecommendation(
                title: "Mission Planning and Focus",
                description: "Review mission objectives before engagement. Prioritize primary objectives and avoid distractions.",
                priority: .high
            ))
        }

        // Ammo management recommendations
        if metrics.shotsFired > 0 {
            let efficiency = Float(metrics.shotsHit) / Float(metrics.shotsFired)
            if efficiency < 0.4 {
                recommendations.append(TrainingRecommendation(
                    title: "Fire Discipline Training",
                    description: "Improve shot placement. Aim before firing, use controlled pairs, and verify hits.",
                    priority: .medium
                ))
            }
        }

        return recommendations
    }

    // MARK: - Key Moments Extraction

    private func extractKeyMoments(from events: [TrainingEvent]) -> [KeyMoment] {
        var moments: [KeyMoment] = []

        for event in events {
            switch event.type {
            case .nearDeath(let health):
                if health < 20 {
                    moments.append(KeyMoment(
                        timestamp: event.timestamp,
                        type: .critical,
                        description: "Near-death experience at \(Int(health))% health",
                        tacticalImplication: "Exposed to enemy fire - should have used cover",
                        alternativeActions: [
                            "Take cover immediately when under fire",
                            "Use smoke grenade for concealment",
                            "Reposition to better defensive position"
                        ]
                    ))
                }

            case .objectiveComplete(let objective):
                moments.append(KeyMoment(
                    timestamp: event.timestamp,
                    type: .success,
                    description: "Objective completed: \(objective)",
                    tacticalImplication: "Mission progress maintained",
                    alternativeActions: []
                ))

            case .multiKill(let count):
                if count >= 3 {
                    moments.append(KeyMoment(
                        timestamp: event.timestamp,
                        type: .success,
                        description: "Eliminated \(count) enemies in quick succession",
                        tacticalImplication: "Excellent target engagement and fire control",
                        alternativeActions: []
                    ))
                }

            case .friendlyFire:
                moments.append(KeyMoment(
                    timestamp: event.timestamp,
                    type: .failure,
                    description: "Friendly fire incident",
                    tacticalImplication: "Target identification failure - critical safety violation",
                    alternativeActions: [
                        "Verify target before engaging",
                        "Maintain awareness of friendly positions",
                        "Use IFF (Identify Friend or Foe) procedures"
                    ]
                ))

            case .outOfAmmo:
                moments.append(KeyMoment(
                    timestamp: event.timestamp,
                    type: .tactical,
                    description: "Ran out of ammunition during engagement",
                    tacticalImplication: "Poor ammo management",
                    alternativeActions: [
                        "Reload during lull in combat",
                        "Conserve ammunition with aimed fire",
                        "Carry more magazines in loadout"
                    ]
                ))
            }
        }

        return moments
    }

    // MARK: - Decision Analysis

    private func analyzeDecisions(
        from events: [TrainingEvent],
        metrics: PerformanceMetrics
    ) -> [DecisionPoint] {
        var decisions: [DecisionPoint] = []

        // Analyze major decision events
        for event in events {
            if case .tacticalDecision(let situation, let choice, let outcome) = event.type {
                let decisionQuality = evaluateDecision(choice: choice, outcome: outcome)

                decisions.append(DecisionPoint(
                    timestamp: event.timestamp,
                    situation: situation,
                    decision: choice,
                    outcome: decisionQuality,
                    optimalDecision: getOptimalDecision(situation: situation),
                    tacticalJustification: getJustification(choice: choice, outcome: outcome)
                ))
            }
        }

        return decisions
    }

    private func evaluateDecision(choice: String, outcome: String) -> DecisionPoint.DecisionOutcome {
        // Simplified evaluation - in real system would use ML
        if outcome.contains("success") {
            return .optimal
        } else if outcome.contains("acceptable") {
            return .acceptable
        } else if outcome.contains("suboptimal") {
            return .suboptimal
        } else {
            return .poor
        }
    }

    private func getOptimalDecision(situation: String) -> String? {
        // Return tactical doctrine for common situations
        // In real system, this would be ML-based
        if situation.contains("ambush") {
            return "Immediate action drill: return fire and move to cover"
        } else if situation.contains("contact") {
            return "Establish fire superiority and maneuver"
        }
        return nil
    }

    private func getJustification(choice: String, outcome: String) -> String {
        return "Decision resulted in \(outcome). Review tactical doctrine for this scenario."
    }

    // MARK: - Skill Progression

    func calculateSkillProgression(warriorID: UUID) async -> SkillProgression {
        guard let history = performanceHistory[warriorID], !history.isEmpty else {
            return SkillProgression(
                currentLevel: 1,
                experiencePoints: 0,
                nextLevelXP: 1000,
                skillRatings: [:]
            )
        }

        let latestMetrics = history.last!
        let totalXP = calculateTotalXP(from: history)
        let level = calculateLevel(xp: totalXP)

        let skillRatings: [String: Float] = [
            "Marksmanship": latestMetrics.accuracy,
            "Tactical Movement": latestMetrics.coverUsage,
            "Decision Making": min(100, 100 - Float(latestMetrics.decisionSpeed * 10)),
            "Mission Focus": latestMetrics.objectiveCompletionRate,
            "Combat Effectiveness": Float(latestMetrics.tacticalScore) / 10.0
        ]

        return SkillProgression(
            currentLevel: level,
            experiencePoints: totalXP,
            nextLevelXP: calculateNextLevelXP(level: level),
            skillRatings: skillRatings
        )
    }

    private func calculateTotalXP(from history: [PerformanceMetrics]) -> Int {
        return history.reduce(0) { $0 + $1.tacticalScore }
    }

    private func calculateLevel(xp: Int) -> Int {
        // XP curve: 1000 XP per level, increasing by 10% each level
        var level = 1
        var requiredXP = 1000
        var totalXP = 0

        while totalXP + requiredXP <= xp {
            totalXP += requiredXP
            level += 1
            requiredXP = Int(Double(requiredXP) * 1.1)
        }

        return level
    }

    private func calculateNextLevelXP(level: Int) -> Int {
        return Int(1000.0 * pow(1.1, Double(level - 1)))
    }

    // MARK: - Predictive Analytics

    func predictReadiness(warriorID: UUID) async -> ReadinessScore {
        guard let history = performanceHistory[warriorID], history.count >= 3 else {
            return ReadinessScore(
                overallReadiness: 50,
                combatReadiness: 50,
                tacticalReadiness: 50,
                confidence: 0.3,
                recommendation: "Insufficient training data. Complete at least 3 training sessions."
            )
        }

        let recentSessions = history.suffix(5)
        let avgScore = recentSessions.reduce(0.0) { $0 + Float($1.tacticalScore) } / Float(recentSessions.count)
        let avgAccuracy = recentSessions.reduce(0.0) { $0 + $1.accuracy } / Float(recentSessions.count)

        let combatReadiness = Int(avgAccuracy)
        let tacticalReadiness = Int(avgScore / 10.0)
        let overallReadiness = (combatReadiness + tacticalReadiness) / 2

        let confidence = min(1.0, Float(history.count) / 10.0)

        var recommendation = ""
        if overallReadiness >= 85 {
            recommendation = "Combat ready. Maintain proficiency through regular training."
        } else if overallReadiness >= 70 {
            recommendation = "Mostly ready. Focus on identified weaknesses."
        } else if overallReadiness >= 50 {
            recommendation = "Not combat ready. Intensive training required."
        } else {
            recommendation = "Not ready for deployment. Complete foundational training."
        }

        return ReadinessScore(
            overallReadiness: overallReadiness,
            combatReadiness: combatReadiness,
            tacticalReadiness: tacticalReadiness,
            confidence: confidence,
            recommendation: recommendation
        )
    }

    // MARK: - Clear Data

    func clearEventLog() {
        eventLog.removeAll()
    }

    func getEventLog() -> [TrainingEvent] {
        return eventLog
    }
}

// MARK: - Supporting Types

struct SkillProgression {
    var currentLevel: Int
    var experiencePoints: Int
    var nextLevelXP: Int
    var skillRatings: [String: Float]

    var progressToNextLevel: Float {
        let currentLevelXP = experiencePoints - getPreviousLevelXP()
        let xpNeeded = nextLevelXP
        return Float(currentLevelXP) / Float(xpNeeded)
    }

    private func getPreviousLevelXP() -> Int {
        var totalXP = 0
        var xpPerLevel = 1000

        for _ in 1..<currentLevel {
            totalXP += xpPerLevel
            xpPerLevel = Int(Double(xpPerLevel) * 1.1)
        }

        return totalXP
    }
}

struct ReadinessScore {
    var overallReadiness: Int // 0-100
    var combatReadiness: Int // 0-100
    var tacticalReadiness: Int // 0-100
    var confidence: Float // 0-1
    var recommendation: String
}

enum TrainingEvent {
    case nearDeath(health: Float)
    case objectiveComplete(objective: String)
    case multiKill(count: Int)
    case friendlyFire
    case outOfAmmo
    case tacticalDecision(situation: String, choice: String, outcome: String)

    var timestamp: TimeInterval {
        return Date().timeIntervalSince1970
    }

    var type: TrainingEvent {
        return self
    }
}
