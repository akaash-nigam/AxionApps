import Foundation
import Combine

/// Tracks user progress, maintains statistics, and manages achievements
@MainActor
class ProgressTracker: ObservableObject {

    // MARK: - Published Properties

    @Published private(set) var userProgress: UserProgress
    @Published private(set) var statistics: ProgressStatistics
    @Published private(set) var recentAchievements: [Achievement] = []

    // MARK: - Types

    struct ProgressStatistics {
        var totalSessions: Int
        var totalDuration: TimeInterval
        var currentStreak: Int
        var longestStreak: Int
        var averageSessionDuration: TimeInterval
        var averageQualityScore: Float
        var totalHours: Double
        var sessionsThisWeek: Int
        var sessionsThisMonth: Int
        var favoriteEnvironment: String?
        var favoriteTechnique: MeditationTechnique?
        var mostProductiveHour: Int?

        var formattedTotalHours: String {
            String(format: "%.1f", totalHours)
        }

        var formattedAverageDuration: String {
            let minutes = Int(averageSessionDuration / 60)
            return "\(minutes) min"
        }
    }

    // MARK: - Private Properties

    private var sessionHistory: [MeditationSession] = []
    private let persistenceManager: PersistenceManager?

    // MARK: - Initialization

    init(userID: UUID, persistenceManager: PersistenceManager? = nil) {
        self.persistenceManager = persistenceManager
        self.userProgress = UserProgress.initial(userID: userID)
        self.statistics = ProgressStatistics(
            totalSessions: 0,
            totalDuration: 0,
            currentStreak: 0,
            longestStreak: 0,
            averageSessionDuration: 0,
            averageQualityScore: 0,
            totalHours: 0,
            sessionsThisWeek: 0,
            sessionsThisMonth: 0
        )
    }

    // MARK: - Session Recording

    func recordSession(_ session: MeditationSession) async {
        // Add to history
        sessionHistory.append(session)

        // Update progress
        userProgress.recordSession(session)

        // Check for achievements
        await checkAndUnlockAchievements(for: session)

        // Recalculate statistics
        await updateStatistics()

        // Persist changes
        await persistProgress()
    }

    func getSessionHistory(limit: Int? = nil) -> [MeditationSession] {
        if let limit = limit {
            return Array(sessionHistory.suffix(limit))
        }
        return sessionHistory
    }

    func getSession(id: UUID) -> MeditationSession? {
        return sessionHistory.first { $0.id == id }
    }

    // MARK: - Statistics

    private func updateStatistics() async {
        let totalSessions = userProgress.totalSessions
        let totalDuration = userProgress.totalDuration

        // Basic stats
        statistics.totalSessions = totalSessions
        statistics.totalDuration = totalDuration
        statistics.currentStreak = userProgress.currentStreak
        statistics.longestStreak = userProgress.longestStreak
        statistics.totalHours = totalDuration / 3600.0

        // Average duration
        statistics.averageSessionDuration = totalSessions > 0 ?
            totalDuration / Double(totalSessions) : 0

        // Average quality
        let qualitySessions = sessionHistory.compactMap { $0.qualityScore }
        statistics.averageQualityScore = qualitySessions.isEmpty ? 0 :
            qualitySessions.reduce(0, +) / Float(qualitySessions.count)

        // Time-based stats
        let now = Date()
        let calendar = Calendar.current

        // This week
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: now)!
        statistics.sessionsThisWeek = sessionHistory.filter {
            $0.startTime >= weekAgo
        }.count

        // This month
        let monthAgo = calendar.date(byAdding: .month, value: -1, to: now)!
        statistics.sessionsThisMonth = sessionHistory.filter {
            $0.startTime >= monthAgo
        }.count

        // Favorite environment
        let environmentCounts = Dictionary(grouping: sessionHistory) { $0.environmentID }
            .mapValues { $0.count }
        statistics.favoriteEnvironment = environmentCounts.max { $0.value < $1.value }?.key

        // Favorite technique
        let techniqueCounts = Dictionary(grouping: sessionHistory) { $0.technique }
            .mapValues { $0.count }
        statistics.favoriteTechnique = techniqueCounts.max { $0.value < $1.value }?.key

        // Most productive hour
        let hourCounts = Dictionary(grouping: sessionHistory) {
            calendar.component(.hour, from: $0.startTime)
        }.mapValues { sessions -> Float in
            let qualityScores = sessions.compactMap { $0.qualityScore }
            return qualityScores.isEmpty ? 0 :
                qualityScores.reduce(0, +) / Float(qualityScores.count)
        }
        statistics.mostProductiveHour = hourCounts.max { $0.value < $1.value }?.key
    }

    func getDetailedStatistics(for period: StatisticsPeriod) -> DetailedStatistics {
        let filteredSessions = sessionHistory.filter { session in
            switch period {
            case .allTime:
                return true
            case .thisWeek:
                let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
                return session.startTime >= weekAgo
            case .thisMonth:
                let monthAgo = Calendar.current.date(byAdding: .month, value: -1, to: Date())!
                return session.startTime >= monthAgo
            case .last30Days:
                let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date())!
                return session.startTime >= thirtyDaysAgo
            }
        }

        return DetailedStatistics(sessions: filteredSessions, userProgress: userProgress)
    }

    enum StatisticsPeriod {
        case allTime
        case thisWeek
        case thisMonth
        case last30Days
    }

    struct DetailedStatistics {
        let sessionCount: Int
        let totalDuration: TimeInterval
        let averageDuration: TimeInterval
        let averageQualityScore: Float
        let bestSession: MeditationSession?
        let stressReductionAverage: Double
        let meditationDepthBreakdown: [MeditationDepth: Int]

        init(sessions: [MeditationSession], userProgress: UserProgress) {
            self.sessionCount = sessions.count

            self.totalDuration = sessions.reduce(0) { $0 + $1.duration }

            self.averageDuration = sessionCount > 0 ?
                totalDuration / Double(sessionCount) : 0

            let qualityScores = sessions.compactMap { $0.qualityScore }
            self.averageQualityScore = qualityScores.isEmpty ? 0 :
                qualityScores.reduce(0, +) / Float(qualityScores.count)

            self.bestSession = sessions.max { ($0.qualityScore ?? 0) < ($1.qualityScore ?? 0) }

            let stressReductions = sessions.compactMap { $0.stressReduction }
            self.stressReductionAverage = stressReductions.isEmpty ? 0 :
                stressReductions.reduce(0, +) / Double(stressReductions.count)

            self.meditationDepthBreakdown = Dictionary(grouping: sessions) {
                $0.finalBiometrics?.meditationDepth ?? .settling
            }.mapValues { $0.count }
        }
    }

    // MARK: - Achievements

    private func checkAndUnlockAchievements(for session: MeditationSession) async {
        var newAchievements: [Achievement] = []

        // First session
        if userProgress.totalSessions == 1 {
            if unlockIfNew(Achievement.firstSession) {
                newAchievements.append(Achievement.firstSession)
            }
        }

        // 10 sessions
        if userProgress.totalSessions == 10 {
            if unlockIfNew(Achievement.tenSessions) {
                newAchievements.append(Achievement.tenSessions)
            }
        }

        // 100 sessions (Centurion)
        if userProgress.totalSessions == 100 {
            if unlockIfNew(Achievement.centurion) {
                newAchievements.append(Achievement.centurion)
            }
        }

        // Week streak
        if userProgress.currentStreak == 7 {
            if unlockIfNew(Achievement.weekStreak) {
                newAchievements.append(Achievement.weekStreak)
            }
        }

        // Month streak
        if userProgress.currentStreak == 30 {
            if unlockIfNew(Achievement.monthStreak) {
                newAchievements.append(Achievement.monthStreak)
            }
        }

        // Deep meditation
        if session.finalBiometrics?.meditationDepth == .deep {
            if unlockIfNew(Achievement.deepMeditation) {
                newAchievements.append(Achievement.deepMeditation)
            }
        }

        // Marathon (60 min session)
        if session.duration >= 3600 {
            if unlockIfNew(Achievement.marathon) {
                newAchievements.append(Achievement.marathon)
            }
        }

        // Early bird (before 7am)
        let hour = Calendar.current.component(.hour, from: session.startTime)
        if hour < 7 {
            if unlockIfNew(Achievement.earlyBird) {
                newAchievements.append(Achievement.earlyBird)
            }
        }

        // Night owl (after 10pm)
        if hour >= 22 {
            if unlockIfNew(Achievement.nightOwl) {
                newAchievements.append(Achievement.nightOwl)
            }
        }

        // Stress relief (reduced stress by 50%+)
        if let stressReduction = session.stressReduction, stressReduction >= 0.5 {
            if unlockIfNew(Achievement.stressRelief) {
                newAchievements.append(Achievement.stressRelief)
            }
        }

        // Level milestones
        if userProgress.level == 10 {
            if unlockIfNew(Achievement.level10) {
                newAchievements.append(Achievement.level10)
            }
        }

        if !newAchievements.isEmpty {
            recentAchievements = newAchievements
        }
    }

    private func unlockIfNew(_ achievement: Achievement) -> Bool {
        if !userProgress.achievements.contains(where: { $0.id == achievement.id }) {
            userProgress.unlockAchievement(achievement)
            return true
        }
        return false
    }

    func clearRecentAchievements() {
        recentAchievements.removeAll()
    }

    // MARK: - Insights

    func generateInsights() -> [ProgressInsight] {
        var insights: [ProgressInsight] = []

        // Streak insights
        if userProgress.currentStreak > 0 {
            insights.append(ProgressInsight(
                title: "Current Streak",
                description: "\(userProgress.currentStreak) days in a row! Keep it going.",
                type: .positive,
                actionable: userProgress.currentStreak >= 3 ? nil : "Meditate again tomorrow to build your streak"
            ))
        }

        // Consistency insights
        if statistics.sessionsThisWeek < 3 {
            insights.append(ProgressInsight(
                title: "Build Consistency",
                description: "You've meditated \(statistics.sessionsThisWeek) times this week.",
                type: .suggestion,
                actionable: "Aim for 5 sessions this week to establish a strong habit"
            ))
        }

        // Quality insights
        if statistics.averageQualityScore > 0.7 {
            insights.append(ProgressInsight(
                title: "High Quality Practice",
                description: "Your average session quality is \(Int(statistics.averageQualityScore * 100))%",
                type: .positive,
                actionable: nil
            ))
        }

        // Progress insights
        let nextLevelXP = AppConfiguration.Progress.experienceForLevel(userProgress.level + 1)
        let xpProgress = Float(userProgress.experiencePoints) / Float(nextLevelXP)

        if xpProgress > 0.8 {
            insights.append(ProgressInsight(
                title: "Almost There!",
                description: "You're \(Int((1.0 - xpProgress) * 100))% away from level \(userProgress.level + 1)",
                type: .positive,
                actionable: "One more good session should level you up"
            ))
        }

        // Milestone insights
        if userProgress.totalSessions == 9 {
            insights.append(ProgressInsight(
                title: "Milestone Ahead",
                description: "Your next session will be your 10th!",
                type: .milestone,
                actionable: "Complete one more session to unlock an achievement"
            ))
        }

        return insights
    }

    struct ProgressInsight {
        let title: String
        let description: String
        let type: InsightType
        let actionable: String?

        enum InsightType {
            case positive
            case suggestion
            case milestone
            case warning
        }
    }

    // MARK: - Calendar/History

    func getCalendarData(for month: Date) -> [Date: SessionDayData] {
        let calendar = Calendar.current
        let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: month))!
        let monthEnd = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: monthStart)!

        let monthSessions = sessionHistory.filter { session in
            session.startTime >= monthStart && session.startTime <= monthEnd
        }

        // Group by day
        var dayData: [Date: SessionDayData] = [:]

        for session in monthSessions {
            let dayStart = calendar.startOfDay(for: session.startTime)

            if dayData[dayStart] == nil {
                dayData[dayStart] = SessionDayData(date: dayStart, sessions: [])
            }

            dayData[dayStart]?.sessions.append(session)
        }

        return dayData
    }

    struct SessionDayData {
        let date: Date
        var sessions: [MeditationSession]

        var totalDuration: TimeInterval {
            sessions.reduce(0) { $0 + $1.duration }
        }

        var averageQuality: Float? {
            let qualityScores = sessions.compactMap { $0.qualityScore }
            guard !qualityScores.isEmpty else { return nil }
            return qualityScores.reduce(0, +) / Float(qualityScores.count)
        }
    }

    // MARK: - Persistence

    private func persistProgress() async {
        await persistenceManager?.saveProgress(userProgress)
    }

    func loadProgress(for userID: UUID) async {
        if let loaded = await persistenceManager?.loadProgress(for: userID) {
            self.userProgress = loaded
            await updateStatistics()
        }
    }

    func loadSessionHistory(for userID: UUID) async {
        if let sessions = await persistenceManager?.loadSessions(for: userID) {
            self.sessionHistory = sessions
            await updateStatistics()
        }
    }
}

// MARK: - Achievement Extensions

extension Achievement {
    static let firstSession = Achievement(
        id: "first_session",
        name: "First Steps",
        description: "Complete your first meditation session",
        iconName: "leaf.circle.fill",
        experienceReward: 100
    )

    static let tenSessions = Achievement(
        id: "ten_sessions",
        name: "Committed",
        description: "Complete 10 meditation sessions",
        iconName: "star.circle.fill",
        experienceReward: 200
    )

    static let centurion = Achievement(
        id: "centurion",
        name: "Centurion",
        description: "Complete 100 meditation sessions",
        iconName: "crown.fill",
        experienceReward: 1000
    )

    static let weekStreak = Achievement(
        id: "week_streak",
        name: "Seven Days",
        description: "Meditate for 7 days in a row",
        iconName: "flame.fill",
        experienceReward: 300
    )

    static let monthStreak = Achievement(
        id: "month_streak",
        name: "Dedicated",
        description: "Meditate for 30 days in a row",
        iconName: "bolt.fill",
        experienceReward: 1500
    )

    static let deepMeditation = Achievement(
        id: "deep_meditation",
        name: "Going Deep",
        description: "Achieve deep meditation state",
        iconName: "moon.stars.fill",
        experienceReward: 250
    )

    static let marathon = Achievement(
        id: "marathon",
        name: "Marathon",
        description: "Complete a 60-minute session",
        iconName: "timer",
        experienceReward: 500
    )

    static let earlyBird = Achievement(
        id: "early_bird",
        name: "Early Bird",
        description: "Meditate before 7am",
        iconName: "sunrise.fill",
        experienceReward: 150
    )

    static let nightOwl = Achievement(
        id: "night_owl",
        name: "Night Owl",
        description: "Meditate after 10pm",
        iconName: "moon.fill",
        experienceReward: 150
    )

    static let stressRelief = Achievement(
        id: "stress_relief",
        name: "Stress Relief",
        description: "Reduce stress by 50% in a session",
        iconName: "heart.fill",
        experienceReward: 200
    )

    static let level10 = Achievement(
        id: "level_10",
        name: "Expert Meditator",
        description: "Reach level 10",
        iconName: "star.circle.fill",
        experienceReward: 500
    )
}
