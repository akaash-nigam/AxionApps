import Foundation

/// Generates actionable insights from user meditation data
actor InsightsGenerator {

    // MARK: - Types

    struct Insight {
        let title: String
        let summary: String
        let detail: String
        let category: Category
        let priority: Priority
        let actionItems: [ActionItem]
        let visualData: VisualData?

        enum Category {
            case progress
            case patterns
            case quality
            case technique
            case timing
            case wellness
            case streaks
            case recommendations
        }

        enum Priority {
            case high
            case medium
            case low
        }
    }

    struct ActionItem {
        let description: String
        let type: ActionType

        enum ActionType {
            case practice // Try a specific practice
            case timing // Adjust timing
            case technique // Try different technique
            case duration // Adjust duration
            case consistency // Improve consistency
            case challenge // Take on a challenge
        }
    }

    struct VisualData {
        let chartType: ChartType
        let dataPoints: [DataPoint]

        enum ChartType {
            case line
            case bar
            case pie
            case timeline
        }

        struct DataPoint {
            let label: String
            let value: Double
            let date: Date?
        }
    }

    // MARK: - Private Properties

    private var sessions: [MeditationSession] = []
    private var progress: UserProgress?
    private var profile: UserProfile?

    // MARK: - Public Methods

    func updateData(
        sessions: [MeditationSession],
        progress: UserProgress,
        profile: UserProfile
    ) {
        self.sessions = sessions
        self.progress = progress
        self.profile = profile
    }

    func generateAllInsights() async -> [Insight] {
        var insights: [Insight] = []

        insights.append(contentsOf: await generateProgressInsights())
        insights.append(contentsOf: await generatePatternInsights())
        insights.append(contentsOf: await generateQualityInsights())
        insights.append(contentsOf: await generateTimingInsights())
        insights.append(contentsOf: await generateWellnessInsights())
        insights.append(contentsOf: await generateRecommendations())

        // Sort by priority
        return insights.sorted { insight1, insight2 in
            let priority1 = priorityValue(insight1.priority)
            let priority2 = priorityValue(insight2.priority)
            return priority1 > priority2
        }
    }

    // MARK: - Progress Insights

    private func generateProgressInsights() async -> [Insight] {
        guard let progress = progress else { return [] }

        var insights: [Insight] = []

        // Level progress
        let currentLevel = progress.level
        let currentXP = progress.experiencePoints
        let nextLevelXP = AppConfiguration.Progress.experienceForLevel(currentLevel + 1)
        let progressPercent = Double(currentXP) / Double(nextLevelXP) * 100

        if progressPercent > 75 {
            insights.append(Insight(
                title: "Level Up Soon!",
                summary: "You're \(Int(100 - progressPercent))% away from level \(currentLevel + 1)",
                detail: "You've earned \(currentXP) XP and need \(nextLevelXP - currentXP) more to reach the next level. At your current pace, you'll level up in approximately \(estimateDaysToNextLevel()) days.",
                category: .progress,
                priority: .high,
                actionItems: [
                    ActionItem(description: "Complete 2-3 quality sessions this week", type: .practice)
                ],
                visualData: VisualData(
                    chartType: .bar,
                    dataPoints: [
                        VisualData.DataPoint(label: "Current XP", value: Double(currentXP), date: nil),
                        VisualData.DataPoint(label: "To Next Level", value: Double(nextLevelXP - currentXP), date: nil)
                    ]
                )
            ))
        }

        // Session milestones
        let totalSessions = progress.totalSessions
        if totalSessions == 9 || totalSessions == 24 || totalSessions == 49 || totalSessions == 99 {
            insights.append(Insight(
                title: "Milestone Ahead",
                summary: "Your next session will be number \(totalSessions + 1)!",
                detail: "You're one session away from a significant milestone. This is a great achievement that shows your dedication to the practice.",
                category: .progress,
                priority: .high,
                actionItems: [
                    ActionItem(description: "Complete your milestone session today", type: .practice)
                ],
                visualData: nil
            ))
        }

        // Hours practiced
        let totalHours = Int(progress.totalDuration / 3600)
        if totalHours >= 10 && totalHours % 10 == 0 {
            insights.append(Insight(
                title: "\(totalHours) Hours Practiced",
                summary: "You've spent \(totalHours) hours in meditation",
                detail: "That's the equivalent of \(totalHours * 60 / 30) average meditation sessions. Your commitment to practice is building real neural pathways for mindfulness.",
                category: .progress,
                priority: .medium,
                actionItems: [],
                visualData: nil
            ))
        }

        return insights
    }

    // MARK: - Pattern Insights

    private func generatePatternInsights() async -> [Insight] {
        guard !sessions.isEmpty else { return [] }

        var insights: [Insight] = []

        // Time of day patterns
        let hourDistribution = Dictionary(grouping: sessions) {
            Calendar.current.component(.hour, from: $0.startTime)
        }

        if let bestHour = findBestPerformanceHour(hourDistribution) {
            let timeString = formatHour(bestHour)
            insights.append(Insight(
                title: "Your Best Time",
                summary: "You meditate most effectively around \(timeString)",
                detail: "Analysis of your sessions shows higher quality scores and better stress reduction during this time. Your mind and body may be naturally more receptive to meditation at this hour.",
                category: .patterns,
                priority: .medium,
                actionItems: [
                    ActionItem(description: "Schedule sessions around \(timeString) when possible", type: .timing)
                ],
                visualData: createHourlyQualityChart(hourDistribution)
            ))
        }

        // Day of week patterns
        let weekdayDistribution = Dictionary(grouping: sessions) {
            Calendar.current.component(.weekday, from: $0.startTime)
        }

        if let data = analyzWeekdayPattern(weekdayDistribution) {
            insights.append(data)
        }

        // Environment preferences
        let envDistribution = Dictionary(grouping: sessions) { $0.environmentID }
        if let favEnvironment = envDistribution.max(by: { $0.value.count < $1.value.count }) {
            let count = favEnvironment.value.count
            let percent = Double(count) / Double(sessions.count) * 100

            insights.append(Insight(
                title: "Favorite Environment",
                summary: "\(favEnvironment.key) is your go-to space",
                detail: "You've chosen this environment for \(Int(percent))% of your sessions. This consistency suggests it resonates with your practice style.",
                category: .patterns,
                priority: .low,
                actionItems: [
                    ActionItem(description: "Try exploring new environments to add variety", type: .practice)
                ],
                visualData: createEnvironmentDistributionChart(envDistribution)
            ))
        }

        return insights
    }

    // MARK: - Quality Insights

    private func generateQualityInsights() async -> [Insight] {
        let qualitySessions = sessions.compactMap { session -> (MeditationSession, Float)? in
            guard let quality = session.qualityScore else { return nil }
            return (session, quality)
        }

        guard !qualitySessions.isEmpty else { return [] }

        var insights: [Insight] = []

        let avgQuality = qualitySessions.map { $0.1 }.reduce(0, +) / Float(qualitySessions.count)

        // Overall quality trend
        if avgQuality > 0.7 {
            insights.append(Insight(
                title: "High Quality Practice",
                summary: "Your average session quality is \(Int(avgQuality * 100))%",
                detail: "You're consistently achieving high-quality meditation states. This indicates strong focus, relaxation, and depth in your practice.",
                category: .quality,
                priority: .high,
                actionItems: [
                    ActionItem(description: "Try longer sessions to explore deeper states", type: .duration)
                ],
                visualData: nil
            ))
        } else if avgQuality < 0.5 {
            insights.append(Insight(
                title: "Room for Growth",
                summary: "Your practice is building, with an average quality of \(Int(avgQuality * 100))%",
                detail: "It's normal for quality to vary as you develop your practice. Consider trying shorter sessions, different techniques, or quieter times of day.",
                category: .quality,
                priority: .high,
                actionItems: [
                    ActionItem(description: "Try 5-minute sessions to build consistency", type: .duration),
                    ActionItem(description: "Experiment with guided breath awareness", type: .technique)
                ],
                visualData: nil
            ))
        }

        // Quality trend over time
        if sessions.count >= 10 {
            let recent5 = Array(qualitySessions.suffix(5)).map { $0.1 }
            let previous5 = Array(qualitySessions.dropLast(5).suffix(5)).map { $0.1 }

            if !previous5.isEmpty {
                let recentAvg = recent5.reduce(0, +) / Float(recent5.count)
                let previousAvg = previous5.reduce(0, +) / Float(previous5.count)

                if recentAvg > previousAvg + 0.1 {
                    insights.append(Insight(
                        title: "Improving Quality",
                        summary: "Your recent sessions show \(Int((recentAvg - previousAvg) * 100))% improvement",
                        detail: "Your practice is deepening. The improvements suggest your meditation skills are developing and your mind is becoming more adept at settling.",
                        category: .quality,
                        priority: .high,
                        actionItems: [],
                        visualData: createQualityTrendChart()
                    ))
                } else if recentAvg < previousAvg - 0.1 {
                    insights.append(Insight(
                        title: "Quality Dip",
                        summary: "Recent sessions show lower quality than before",
                        detail: "This is normal and temporary. Consider if you're stressed, tired, or distracted. Sometimes the best thing is to be gentle with yourself and maintain consistency.",
                        category: .quality,
                        priority: .medium,
                        actionItems: [
                            ActionItem(description: "Return to basics with breath awareness", type: .technique),
                            ActionItem(description: "Ensure you're meditating at your best time", type: .timing)
                        ],
                        visualData: nil
                    ))
                }
            }
        }

        return insights
    }

    // MARK: - Timing Insights

    private func generateTimingInsights() async -> [Insight] {
        guard sessions.count >= 5 else { return [] }

        var insights: [Insight] = []

        // Consistency analysis
        let dates = sessions.map {
            Calendar.current.startOfDay(for: $0.startTime)
        }
        let uniqueDays = Set(dates).count

        if uniqueDays < sessions.count {
            insights.append(Insight(
                title: "Multiple Sessions Per Day",
                summary: "You sometimes practice more than once daily",
                detail: "While enthusiasm is great, ensure you're not overdoing it. Quality and consistency are more important than quantity for building a sustainable practice.",
                category: .timing,
                priority: .low,
                actionItems: [
                    ActionItem(description: "Focus on one quality session per day", type: .consistency)
                ],
                visualData: nil
            ))
        }

        // Session duration analysis
        let avgDuration = sessions.map { $0.duration }.reduce(0, +) / Double(sessions.count)

        if avgDuration < 300 { // Less than 5 minutes
            insights.append(Insight(
                title: "Short Sessions",
                summary: "Your average session is \(Int(avgDuration / 60)) minutes",
                detail: "Short sessions are great for building the habit. As your practice stabilizes, consider gradually extending to 10-15 minutes for deeper benefits.",
                category: .timing,
                priority: .medium,
                actionItems: [
                    ActionItem(description: "Try adding 2 minutes to your next few sessions", type: .duration)
                ],
                visualData: nil
            ))
        } else if avgDuration > 1800 { // More than 30 minutes
            insights.append(Insight(
                title: "Deep Practitioner",
                summary: "You average \(Int(avgDuration / 60)) minutes per session",
                detail: "Your long sessions indicate strong commitment and concentration. This depth of practice can lead to profound insights and benefits.",
                category: .timing,
                priority: .low,
                actionItems: [],
                visualData: nil
            ))
        }

        return insights
    }

    // MARK: - Wellness Insights

    private func generateWellnessInsights() async -> [Insight] {
        let sessionsWithBiometrics = sessions.filter {
            $0.initialBiometrics != nil && $0.finalBiometrics != nil
        }

        guard !sessionsWithBiometrics.isEmpty else { return [] }

        var insights: [Insight] = []

        // Stress reduction analysis
        let stressReductions = sessionsWithBiometrics.compactMap { $0.stressReduction }
        if !stressReductions.isEmpty {
            let avgReduction = stressReductions.reduce(0, +) / Double(stressReductions.count)

            if avgReduction > 0.3 {
                insights.append(Insight(
                    title: "Effective Stress Relief",
                    summary: "You reduce stress by \(Int(avgReduction * 100))% on average",
                    detail: "Your meditation practice is having a measurable positive impact on your stress levels. This physiological change supports better health, sleep, and emotional regulation.",
                    category: .wellness,
                    priority: .high,
                    actionItems: [],
                    visualData: createStressReductionChart()
                ))
            }
        }

        // Meditation depth analysis
        let deepSessions = sessionsWithBiometrics.filter {
            $0.finalBiometrics?.meditationDepth == .deep
        }

        if deepSessions.count >= 3 {
            let deepPercent = Double(deepSessions.count) / Double(sessionsWithBiometrics.count) * 100

            insights.append(Insight(
                title: "Achieving Deep States",
                summary: "\(Int(deepPercent))% of your sessions reach deep meditation",
                detail: "Deep meditation states are associated with increased alpha and theta brain waves, reduced cortisol, and enhanced neuroplasticity. You're developing real mastery.",
                category: .wellness,
                priority: .high,
                actionItems: [
                    ActionItem(description: "Explore unguided sessions in deep states", type: .practice)
                ],
                visualData: nil
            ))
        }

        return insights
    }

    // MARK: - Recommendations

    private func generateRecommendations() async -> [Insight] {
        guard let progress = progress, let profile = profile else { return [] }

        var insights: [Insight] = []

        // Streak recommendations
        if progress.currentStreak == 0 {
            insights.append(Insight(
                title: "Start a Streak",
                summary: "Build momentum with daily practice",
                detail: "Research shows that daily practice, even just 5 minutes, creates lasting changes in the brain. Starting a streak can help cement meditation as a habit.",
                category: .recommendations,
                priority: .high,
                actionItems: [
                    ActionItem(description: "Commit to 7 days in a row", type: .consistency),
                    ActionItem(description: "Set a daily reminder for your best time", type: .timing)
                ],
                visualData: nil
            ))
        } else if progress.currentStreak >= 7 && progress.currentStreak < 30 {
            insights.append(Insight(
                title: "Streak Going Strong",
                summary: "\(progress.currentStreak) days and counting!",
                detail: "You're building a powerful habit. Keep going to reach 30 days - that's when practice truly becomes automatic.",
                category: .recommendations,
                priority: .medium,
                actionItems: [
                    ActionItem(description: "Aim for 30-day milestone", type: .consistency)
                ],
                visualData: nil
            ))
        }

        // Technique variety
        let techniquesUsed = Set(sessions.map { $0.technique }).count
        if techniquesUsed == 1 && sessions.count > 10 {
            insights.append(Insight(
                title: "Explore New Techniques",
                summary: "Variety can deepen your practice",
                detail: "While consistency with one technique is valuable, exploring others can provide new insights and prevent stagnation. Consider trying body scan or loving-kindness meditation.",
                category: .recommendations,
                priority: .medium,
                actionItems: [
                    ActionItem(description: "Try body scan meditation this week", type: .technique),
                    ActionItem(description: "Explore loving-kindness practice", type: .technique)
                ],
                visualData: nil
            ))
        }

        // Level-based recommendations
        if progress.level >= 10 {
            insights.append(Insight(
                title: "Advanced Practitioner",
                summary: "You're ready for deeper challenges",
                detail: "At level \(progress.level), you have the foundation for advanced practices like silent retreats, longer sits, or teaching others.",
                category: .recommendations,
                priority: .low,
                actionItems: [
                    ActionItem(description: "Try a 30-minute unguided session", type: .duration),
                    ActionItem(description: "Consider a virtual meditation retreat", type: .challenge)
                ],
                visualData: nil
            ))
        }

        return insights
    }

    // MARK: - Helper Methods

    private func findBestPerformanceHour(_ distribution: [Int: [MeditationSession]]) -> Int? {
        var bestHour: Int?
        var bestQuality: Float = 0

        for (hour, sessions) in distribution {
            let qualityScores = sessions.compactMap { $0.qualityScore }
            guard !qualityScores.isEmpty else { continue }

            let avgQuality = qualityScores.reduce(0, +) / Float(qualityScores.count)
            if avgQuality > bestQuality {
                bestQuality = avgQuality
                bestHour = hour
            }
        }

        return bestHour
    }

    private func analyzeWeekdayPattern(_ distribution: [Int: [MeditationSession]]) -> Insight? {
        let weekdayNames = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]

        if let leastActiveDay = distribution.min(by: { $0.value.count < $1.value.count }) {
            let dayName = weekdayNames[leastActiveDay.key - 1]

            return Insight(
                title: "Weekly Pattern",
                summary: "\(dayName)s are your least active meditation day",
                detail: "You've only meditated \(leastActiveDay.value.count) times on \(dayName)s. Consider what makes this day different and whether you could add a session.",
                category: .patterns,
                priority: .low,
                actionItems: [
                    ActionItem(description: "Schedule a session for \(dayName)", type: .timing)
                ],
                visualData: nil
            )
        }

        return nil
    }

    private func createQualityTrendChart() -> VisualData {
        let recent20 = sessions.suffix(20)
        let dataPoints = recent20.enumerated().compactMap { index, session -> VisualData.DataPoint? in
            guard let quality = session.qualityScore else { return nil }
            return VisualData.DataPoint(
                label: "Session \(index + 1)",
                value: Double(quality),
                date: session.startTime
            )
        }

        return VisualData(chartType: .line, dataPoints: dataPoints)
    }

    private func createStressReductionChart() -> VisualData {
        let dataPoints = sessions.compactMap { session -> VisualData.DataPoint? in
            guard let reduction = session.stressReduction else { return nil }
            return VisualData.DataPoint(
                label: "",
                value: reduction,
                date: session.startTime
            )
        }

        return VisualData(chartType: .line, dataPoints: dataPoints.suffix(20))
    }

    private func createEnvironmentDistributionChart(_ distribution: [String: [MeditationSession]]) -> VisualData {
        let dataPoints = distribution.map { key, value in
            VisualData.DataPoint(
                label: key,
                value: Double(value.count),
                date: nil
            )
        }

        return VisualData(chartType: .pie, dataPoints: dataPoints)
    }

    private func createHourlyQualityChart(_ distribution: [Int: [MeditationSession]]) -> VisualData {
        let dataPoints = distribution.compactMap { hour, sessions -> VisualData.DataPoint? in
            let qualityScores = sessions.compactMap { $0.qualityScore }
            guard !qualityScores.isEmpty else { return nil }

            let avgQuality = qualityScores.reduce(0, +) / Float(qualityScores.count)
            return VisualData.DataPoint(
                label: formatHour(hour),
                value: Double(avgQuality),
                date: nil
            )
        }.sorted { $0.label < $1.label }

        return VisualData(chartType: .bar, dataPoints: dataPoints)
    }

    private func estimateDaysToNextLevel() -> Int {
        guard let progress = progress, !sessions.isEmpty else { return 7 }

        let recentSessions = sessions.suffix(7)
        let avgXPPerSession: Float = 50.0
        let sessionsPerWeek = Float(recentSessions.count)
        let xpPerWeek = sessionsPerWeek * avgXPPerSession

        let nextLevelXP = AppConfiguration.Progress.experienceForLevel(progress.level + 1)
        let xpNeeded = nextLevelXP - progress.experiencePoints

        let weeksNeeded = Float(xpNeeded) / xpPerWeek
        return max(1, Int(ceil(weeksNeeded * 7)))
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

    private func priorityValue(_ priority: Insight.Priority) -> Int {
        switch priority {
        case .high: return 3
        case .medium: return 2
        case .low: return 1
        }
    }
}
