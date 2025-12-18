import Foundation

actor AIBalancingSystem {
    private var playerSkillLevels: [UUID: Float] = [:]  // 0.0 (novice) - 1.0 (expert)

    // MARK: - Skill Tracking

    func updateSkillLevel(
        for playerId: UUID,
        performance: GamePerformance
    ) {
        let currentSkill = playerSkillLevels[playerId] ?? 0.5

        // Calculate skill adjustment based on performance
        let adjustment = (performance.successRate - 0.5) * 0.1  // -0.05 to +0.05
        let newSkill = max(0, min(1, currentSkill + adjustment))

        playerSkillLevels[playerId] = newSkill
    }

    func getSkillLevel(for playerId: UUID) -> Float {
        return playerSkillLevels[playerId] ?? 0.5
    }

    // MARK: - Hiding Spot Assignment

    func balanceHidingOpportunities(
        for players: [Player],
        in roomLayout: RoomLayout
    ) async -> [UUID: [HidingSpot]] {
        var assignments: [UUID: [HidingSpot]] = [:]

        for player in players where player.role == .hider {
            let skill = getSkillLevel(for: player.id)

            // Find suitable hiding spots based on skill
            let suitableSpots = roomLayout.hidingSpots.filter { spot in
                // Beginners get better spots
                let targetQuality = 1.0 - (skill * 0.3)  // 0.7-1.0 for beginners, 0.7-0.4 for experts
                return spot.quality >= targetQuality - 0.2 && spot.quality <= targetQuality + 0.2
            }

            assignments[player.id] = suitableSpots
        }

        return assignments
    }

    // MARK: - Hint Generation

    func generateHints(
        for seeker: Player,
        targets: [Player],
        elapsed: TimeInterval,
        maxTime: TimeInterval
    ) async -> [Hint] {
        var hints: [Hint] = []

        let timeRatio = elapsed / maxTime
        let hintLevel = Int(timeRatio * 3)  // 0, 1, 2, 3 levels

        let skill = getSkillLevel(for: seeker.id)

        for target in targets {
            // Beginners get more hints
            if hintLevel >= 1 || skill < 0.3 {
                hints.append(.direction(target.position))
            }

            if hintLevel >= 2 || skill < 0.2 {
                let distance = length(target.position - seeker.position)
                hints.append(.distance(distance))
            }

            if hintLevel >= 3 || skill < 0.1 {
                hints.append(.hotCold(target.position))
            }
        }

        return hints
    }

    // MARK: - Difficulty Adjustment

    func calculateOptimalRoundDuration(
        for players: [Player]
    ) async -> TimeInterval {
        let averageSkill = players.map { getSkillLevel(for: $0.id) }.reduce(0, +) / Float(players.count)

        // Beginners get more time
        let baseDuration: TimeInterval = 180  // 3 minutes
        let adjustment = TimeInterval((0.5 - averageSkill) * 60)  // ±30 seconds

        return max(120, min(240, baseDuration + adjustment))
    }

    func shouldProvideAssistance(
        for playerId: UUID,
        timeElapsed: TimeInterval,
        totalTime: TimeInterval
    ) async -> Bool {
        let skill = getSkillLevel(for: playerId)
        let timeRatio = timeElapsed / totalTime

        // Lower skilled players get assistance earlier
        let assistanceThreshold = 0.5 + (skill * 0.3)  // 0.5-0.8

        return timeRatio > assistanceThreshold
    }

    // MARK: - Fairness Metrics

    func calculateFairnessScore(
        results: [UUID: Int]  // Player ID -> Wins
    ) -> Float {
        guard !results.isEmpty else { return 1.0 }

        let values = Array(results.values)
        let average = Float(values.reduce(0, +)) / Float(values.count)

        // Calculate standard deviation
        let variance = values.map { pow(Float($0) - average, 2) }.reduce(0, +) / Float(values.count)
        let standardDeviation = sqrt(variance)

        // Lower standard deviation = more fair
        // Normalize to 0-1 scale where 1 is perfectly fair
        let fairness = 1.0 / (1.0 + standardDeviation)

        return fairness
    }
}

// MARK: - Supporting Types

struct GamePerformance {
    let successRate: Float  // 0.0 - 1.0
    let averageTime: TimeInterval
    let errorsCount: Int
}

enum Hint {
    case direction(SIMD3<Float>)
    case distance(Float)
    case hotCold(SIMD3<Float>)
    case visual  // Highlight an area
}
