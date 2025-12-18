import Foundation

/// AI system that manages overall narrative flow, pacing, and branch selection
@MainActor
class StoryDirectorAI {

    // MARK: - Properties
    private var currentTensionLevel: Float = 0.5
    private var playerEngagementScore: Float = 0.7
    private var sessionStartTime: Date?

    // MARK: - Pacing Control

    /// Adjust story pacing based on player engagement and emotional state
    func adjustPacing(
        playerEngagement: Float,
        sessionDuration: TimeInterval,
        emotionalIntensity: Float
    ) -> PacingAdjustment {
        var adjustment = PacingAdjustment()

        // Update tracking
        self.playerEngagementScore = playerEngagement

        // Too much tension for too long → ease up
        if emotionalIntensity > 0.7 && sessionDuration > 30 * 60 {
            adjustment.tensionDelta = -0.1
            adjustment.insertBreatherMoment = true
            adjustment.suggestBreak = true
        }

        // Player disengaged → introduce surprise
        if playerEngagement < 0.4 {
            adjustment.triggerSurpriseEvent = true
            adjustment.tensionDelta = 0.15
        }

        // Player overwhelmed → slow down
        if emotionalIntensity > 0.8 {
            adjustment.slowDialogue = true
            adjustment.extendChoiceTime = 1.5
        }

        // Approaching natural climax point
        if emotionalIntensity > 0.6 && emotionalIntensity < 0.75 {
            adjustment.acceleratePlot = true
            adjustment.tensionDelta = 0.1
        }

        // Session comfort check
        if sessionDuration > 60 * 60 {
            adjustment.insertBreatherMoment = true
            adjustment.suggestBreak = true
        }

        return adjustment
    }

    /// Build tension towards climactic moments
    func buildTension(
        currentTension: Float,
        target: Float,
        deltaTime: TimeInterval
    ) -> [NarrativeEvent] {
        var events: [NarrativeEvent] = []

        let tensionGap = target - currentTension
        if tensionGap > 0 {
            // Gradually increase stakes
            let tensionRate: Float = 0.05 // Per event
            let eventsNeeded = Int(tensionGap / tensionRate)

            for i in 0..<min(eventsNeeded, 3) {
                events.append(NarrativeEvent(
                    type: .complication,
                    intensity: currentTension + Float(i) * tensionRate,
                    timing: deltaTime * Double(i)
                ))
            }
        }

        return events
    }

    // MARK: - Branch Selection

    /// Select next story branch based on player patterns and preferences
    func selectBranch(
        availableBranches: [StoryBranch],
        playerHistory: [ChoiceRecord]
    ) -> StoryBranch? {
        guard !availableBranches.isEmpty else { return nil }

        // Analyze player's choice patterns
        let archetype = analyzePlayerArchetype(playerHistory)

        // Score each branch based on fit
        let scoredBranches = availableBranches.map { branch in
            (branch, calculateFitScore(branch, archetype: archetype))
        }

        // Select highest scoring branch with some randomness
        return weightedRandom(scoredBranches)
    }

    /// Analyze player's decision patterns to determine their play style
    private func analyzePlayerArchetype(_ history: [ChoiceRecord]) -> PlayerArchetype {
        var emotionalChoices = 0
        var rationalChoices = 0
        var selfishChoices = 0
        var altruisticChoices = 0

        for record in history {
            switch record.choiceType {
            case .emotional:
                emotionalChoices += 1
            case .rational:
                rationalChoices += 1
            case .selfish:
                selfishChoices += 1
            case .altruistic:
                altruisticChoices += 1
            }
        }

        let total = max(history.count, 1)

        return PlayerArchetype(
            emotionalityScore: Float(emotionalChoices) / Float(total),
            rationalityScore: Float(rationalChoices) / Float(total),
            selfishnessScore: Float(selfishChoices) / Float(total),
            altruismScore: Float(altruisticChoices) / Float(total)
        )
    }

    /// Calculate how well a branch fits a player archetype
    private func calculateFitScore(_ branch: StoryBranch, archetype: PlayerArchetype) -> Float {
        // Simplified scoring - in production this would be more sophisticated
        var score: Float = 0.5 // Base score

        // Match branch themes to player preferences
        // This is a placeholder - actual implementation would analyze branch content
        score += Float.random(in: 0...0.5)

        return score
    }

    /// Select branch using weighted random selection
    private func weightedRandom(_ scoredBranches: [(StoryBranch, Float)]) -> StoryBranch? {
        let totalScore = scoredBranches.reduce(0) { $0 + $1.1 }
        var random = Float.random(in: 0...totalScore)

        for (branch, score) in scoredBranches {
            random -= score
            if random <= 0 {
                return branch
            }
        }

        return scoredBranches.first?.0
    }

    /// Check if we're approaching a climactic moment
    private func isNearClimax() -> Bool {
        return currentTensionLevel > 0.7
    }
}

// MARK: - Supporting Types

struct PacingAdjustment {
    var tensionDelta: Float = 0
    var insertBreatherMoment: Bool = false
    var triggerSurpriseEvent: Bool = false
    var acceleratePlot: Bool = false
    var slowDialogue: Bool = false
    var extendChoiceTime: Float = 1.0
    var suggestBreak: Bool = false
}

struct NarrativeEvent {
    let type: EventType
    let intensity: Float
    let timing: TimeInterval

    enum EventType {
        case complication
        case revelation
        case breather
        case surprise
    }
}

struct PlayerArchetype {
    let emotionalityScore: Float
    let rationalityScore: Float
    let selfishnessScore: Float
    let altruismScore: Float
}

struct ChoiceRecord: Codable {
    let choiceID: UUID
    let optionSelected: UUID
    let timestamp: Date
    let choiceType: ChoiceType

    enum ChoiceType: String, Codable {
        case emotional
        case rational
        case selfish
        case altruistic
    }
}
