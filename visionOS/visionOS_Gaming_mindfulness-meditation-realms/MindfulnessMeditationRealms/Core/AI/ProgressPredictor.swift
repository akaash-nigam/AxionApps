import Foundation

/// ML-based system that predicts user preferences and recommends optimal sessions
actor ProgressPredictor {

    // MARK: - Types

    struct SessionRecommendation {
        let environment: String
        let technique: MeditationTechnique
        let duration: TimeInterval
        let timeOfDay: RecommendedTime?
        let reasoning: String
        let confidence: Float

        enum RecommendedTime {
            case morning // 6-10am
            case midday // 11am-2pm
            case afternoon // 3-6pm
            case evening // 7-10pm
            case night // After 10pm
        }
    }

    struct ProgressPrediction {
        let predictedLevel: Int
        let daysToNextLevel: Int
        let predictedStreakLength: Int
        let likelyDropoffDate: Date?
        let confidence: Float
    }

    struct PersonalizedInsight {
        let insight: String
        let actionableAdvice: String
        let category: InsightCategory
        let priority: Int

        enum InsightCategory {
            case timing
            case technique
            case environment
            case duration
            case consistency
            case challenge
        }
    }

    // MARK: - Private Properties

    private var userHistory: [MeditationSession] = []
    private var userProgress: UserProgress?
    private var userProfile: UserProfile?

    // Pattern detection
    private var preferredEnvironments: [String: Int] = [:]
    private var preferredTechniques: [MeditationTechnique: Int] = [:]
    private var sessionsByTimeOfDay: [Int: [MeditationSession]] = [:] // Hour -> Sessions
    private var sessionsByDayOfWeek: [Int: [MeditationSession]] = [:] // 1-7 -> Sessions

    // MARK: - Public Methods

    func updateUserData(
        sessions: [MeditationSession],
        progress: UserProgress,
        profile: UserProfile
    ) async {
        self.userHistory = sessions
        self.userProgress = progress
        self.userProfile = profile

        // Analyze patterns
        await analyzePatterns()
    }

    func getNextSessionRecommendation() async -> SessionRecommendation {
        // Recommend optimal session based on:
        // 1. Time of day patterns
        // 2. Success rates by environment/technique
        // 3. Current stress/energy levels (if available)
        // 4. Progress goals

        let currentHour = Calendar.current.component(.hour, from: Date())
        let recommendedTime = timeOfDayForHour(currentHour)

        // Find best performing environment
        let bestEnvironment = preferredEnvironments.max(by: { $0.value < $1.value })?.key ?? "ZenGarden"

        // Find best performing technique
        let bestTechnique = preferredTechniques.max(by: { $0.value < $1.value })?.key ?? .breathAwareness

        // Determine optimal duration
        let optimalDuration = await calculateOptimalDuration()

        // Build reasoning
        var reasoning = ""
        if let sessions = sessionsByTimeOfDay[currentHour], !sessions.isEmpty {
            let avgQuality = sessions.compactMap { $0.qualityScore }.reduce(0, +) / Float(sessions.count)
            reasoning += "You typically meditate well at this time (avg quality: \(Int(avgQuality * 100))%). "
        }

        reasoning += "The \(bestEnvironment) environment has worked well for you. "
        reasoning += "Duration of \(Int(optimalDuration / 60)) minutes matches your successful sessions."

        let confidence = await calculateRecommendationConfidence()

        return SessionRecommendation(
            environment: bestEnvironment,
            technique: bestTechnique,
            duration: optimalDuration,
            timeOfDay: recommendedTime,
            reasoning: reasoning,
            confidence: confidence
        )
    }

    func predictProgress(daysAhead: Int = 30) async -> ProgressPrediction {
        guard let progress = userProgress else {
            return ProgressPrediction(
                predictedLevel: 1,
                daysToNextLevel: 30,
                predictedStreakLength: 1,
                likelyDropoffDate: nil,
                confidence: 0.3
            )
        }

        // Calculate current velocity
        let recentSessions = userHistory.suffix(14) // Last 2 weeks
        let sessionsPerDay = Float(recentSessions.count) / 14.0

        // Predict XP accumulation
        let avgXPPerSession: Float = 50.0 // Simplified
        let predictedDailyXP = sessionsPerDay * avgXPPerSession

        let currentXP = progress.experiencePoints
        let currentLevel = progress.level
        let xpForNextLevel = AppConfiguration.Progress.experienceForLevel(currentLevel + 1)
        let xpNeeded = xpForNextLevel - currentXP

        let daysToNextLevel = predictedDailyXP > 0 ?
            Int(ceil(Float(xpNeeded) / predictedDailyXP)) : 30

        // Predict streak
        let currentStreak = progress.currentStreak
        let predictedStreakLength = currentStreak + Int(sessionsPerDay * Float(daysAhead))

        // Predict dropoff (if consistency is low)
        let likelyDropoffDate = await predictDropoff()

        // Confidence based on history length
        let confidence = min(0.9, Float(userHistory.count) / 50.0)

        return ProgressPrediction(
            predictedLevel: currentLevel + (daysAhead / max(1, daysToNextLevel)),
            daysToNextLevel: daysToNextLevel,
            predictedStreakLength: predictedStreakLength,
            likelyDropoffDate: likelyDropoffDate,
            confidence: confidence
        )
    }

    func getPersonalizedInsights() async -> [PersonalizedInsight] {
        var insights: [PersonalizedInsight] = []

        // Timing insights
        if let bestHour = await findBestPerformanceHour() {
            let timeString = formatHour(bestHour)
            insights.append(PersonalizedInsight(
                insight: "Your best sessions are around \(timeString)",
                actionableAdvice: "Try to meditate at \(timeString) when possible for optimal results",
                category: .timing,
                priority: 8
            ))
        }

        // Consistency insights
        if let progress = userProgress, progress.currentStreak < 3 {
            insights.append(PersonalizedInsight(
                insight: "Building a daily habit is key to progress",
                actionableAdvice: "Set a daily reminder for the same time each day to build consistency",
                category: .consistency,
                priority: 10
            ))
        }

        // Duration insights
        let avgDuration = userHistory.map { $0.duration }.reduce(0, +) / Double(max(1, userHistory.count))
        if avgDuration < 300 { // Less than 5 minutes
            insights.append(PersonalizedInsight(
                insight: "Short sessions are great for starting, but longer sessions deepen the benefits",
                actionableAdvice: "Try gradually extending your sessions to 10-15 minutes",
                category: .duration,
                priority: 6
            ))
        }

        // Technique variety insights
        if preferredTechniques.count == 1 {
            insights.append(PersonalizedInsight(
                insight: "Exploring different techniques can enhance your practice",
                actionableAdvice: "Try a body scan or loving-kindness meditation this week",
                category: .technique,
                priority: 5
            ))
        }

        // Challenge insights
        if let progress = userProgress, progress.level >= 5 {
            insights.append(PersonalizedInsight(
                insight: "You're ready for longer, unguided sessions",
                actionableAdvice: "Challenge yourself with a 20-minute silent meditation",
                category: .challenge,
                priority: 7
            ))
        }

        return insights.sorted { $0.priority > $1.priority }
    }

    func predictOptimalDuration(forTimeOfDay hour: Int) async -> TimeInterval {
        // Predict best duration based on historical success

        let sessionsAtThisTime = sessionsByTimeOfDay[hour] ?? []

        if sessionsAtThisTime.isEmpty {
            return 600 // Default 10 minutes
        }

        // Find durations with highest quality scores
        let sessionsByDuration = Dictionary(grouping: sessionsAtThisTime) { session in
            Int(session.duration / 60) * 60 // Round to nearest minute
        }

        var bestDuration: TimeInterval = 600
        var bestQuality: Float = 0

        for (duration, sessions) in sessionsByDuration {
            let avgQuality = sessions.compactMap { $0.qualityScore }.reduce(0, +) / Float(sessions.count)
            if avgQuality > bestQuality {
                bestQuality = avgQuality
                bestDuration = TimeInterval(duration)
            }
        }

        return bestDuration
    }

    func shouldRecommendRest() async -> Bool {
        // Recommend rest day if user is overtraining or showing burnout signs

        guard userHistory.count > 7 else { return false }

        let last7Days = userHistory.suffix(7)

        // Check for declining quality
        let qualityScores = last7Days.compactMap { $0.qualityScore }
        if qualityScores.count >= 5 {
            let recent3 = Array(qualityScores.suffix(3))
            let earlier3 = Array(qualityScores.prefix(3))

            let recentAvg = recent3.reduce(0, +) / Float(recent3.count)
            let earlierAvg = earlier3.reduce(0, +) / Float(earlier3.count)

            // Quality declining significantly
            if recentAvg < earlierAvg - 0.2 {
                return true
            }
        }

        // Check for excessive frequency
        if last7Days.count > 14 { // More than 2x per day
            return true
        }

        return false
    }

    // MARK: - Private Analysis Methods

    private func analyzePatterns() async {
        preferredEnvironments.removeAll()
        preferredTechniques.removeAll()
        sessionsByTimeOfDay.removeAll()
        sessionsByDayOfWeek.removeAll()

        for session in userHistory {
            // Count environments
            preferredEnvironments[session.environmentID, default: 0] += 1

            // Count techniques
            preferredTechniques[session.technique, default: 0] += 1

            // Group by time of day
            let hour = Calendar.current.component(.hour, from: session.startTime)
            sessionsByTimeOfDay[hour, default: []].append(session)

            // Group by day of week
            let weekday = Calendar.current.component(.weekday, from: session.startTime)
            sessionsByDayOfWeek[weekday, default: []].append(session)
        }
    }

    private func calculateOptimalDuration() async -> TimeInterval {
        guard !userHistory.isEmpty else {
            return 600 // Default 10 minutes
        }

        // Find sessions with high quality scores
        let qualitySessions = userHistory.filter { ($0.qualityScore ?? 0) > 0.7 }

        if qualitySessions.isEmpty {
            // Use average duration
            let avgDuration = userHistory.map { $0.duration }.reduce(0, +) / Double(userHistory.count)
            return avgDuration
        }

        // Average duration of high-quality sessions
        let optimalDuration = qualitySessions.map { $0.duration }.reduce(0, +) / Double(qualitySessions.count)

        // Round to nearest 5 minutes
        return (optimalDuration / 300).rounded() * 300
    }

    private func calculateRecommendationConfidence() async -> Float {
        // Higher confidence with more data and consistent patterns

        let historyConfidence = min(0.9, Float(userHistory.count) / 30.0)

        // Check pattern consistency
        let environmentDistribution = preferredEnvironments.values
        let maxEnvCount = environmentDistribution.max() ?? 1
        let totalSessions = environmentDistribution.reduce(0, +)
        let dominance = Float(maxEnvCount) / Float(max(1, totalSessions))

        // High dominance = clear preference = higher confidence
        let patternConfidence = dominance

        return (historyConfidence + patternConfidence) / 2.0
    }

    private func findBestPerformanceHour() async -> Int? {
        var bestHour: Int?
        var bestAvgQuality: Float = 0

        for (hour, sessions) in sessionsByTimeOfDay {
            let qualityScores = sessions.compactMap { $0.qualityScore }
            guard !qualityScores.isEmpty else { continue }

            let avgQuality = qualityScores.reduce(0, +) / Float(qualityScores.count)

            if avgQuality > bestAvgQuality {
                bestAvgQuality = avgQuality
                bestHour = hour
            }
        }

        return bestHour
    }

    private func predictDropoff() async -> Date? {
        // Predict if user is likely to stop practicing based on patterns

        guard userHistory.count > 14 else { return nil }

        let recent7 = userHistory.suffix(7)
        let previous7 = userHistory.suffix(14).prefix(7)

        // Declining frequency
        if recent7.count < previous7.count * 2 / 3 {
            // Frequency dropped by 33%+, predict dropoff in 14 days
            return Date().addingTimeInterval(14 * 86400)
        }

        // Declining quality
        let recentQuality = recent7.compactMap { $0.qualityScore }.reduce(0, +) / Float(max(1, recent7.count))
        let previousQuality = previous7.compactMap { $0.qualityScore }.reduce(0, +) / Float(max(1, previous7.count))

        if recentQuality < previousQuality - 0.3 {
            // Quality dropped 30%+
            return Date().addingTimeInterval(21 * 86400)
        }

        return nil
    }

    private func timeOfDayForHour(_ hour: Int) -> SessionRecommendation.RecommendedTime? {
        switch hour {
        case 6...10:
            return .morning
        case 11...14:
            return .midday
        case 15...18:
            return .afternoon
        case 19...22:
            return .evening
        default:
            return .night
        }
    }

    private func formatHour(_ hour: Int) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "ha"

        var components = DateComponents()
        components.hour = hour
        components.minute = 0

        let date = Calendar.current.date(from: components) ?? Date()
        return formatter.string(from: date)
    }
}
