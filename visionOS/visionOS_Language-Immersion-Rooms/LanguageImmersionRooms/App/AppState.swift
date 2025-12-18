//
//  AppState.swift
//  Language Immersion Rooms
//
//  Application-level state management
//

import Foundation
import Observation

@Observable
class AppState {
    // MARK: - User Session
    var currentUser: UserProfile?
    var isAuthenticated: Bool = false
    var isOnboarding: Bool = true

    // MARK: - Learning State
    var currentLanguage: Language = .spanish
    var activeSession: LearningSession?
    var sessionStartTime: Date?

    // MARK: - Progress Tracking
    var wordsEncounteredToday: Int = 0
    var conversationTimeToday: TimeInterval = 0
    var currentStreak: Int = 0
    var lastActiveDate: Date = Date()

    // MARK: - UI State
    var showingSettings: Bool = false
    var showingProgress: Bool = false
    var isLearningSpaceActive: Bool = false

    // MARK: - Preferences
    var labelSize: LabelSize = .medium
    var speechSpeed: Double = 1.0
    var showGrammarHelp: Bool = true

    init() {
        loadUserSession()
        loadProgress()
    }

    // MARK: - User Session Management

    func signIn(user: UserProfile) {
        self.currentUser = user
        self.isAuthenticated = true
        saveUserSession()
        print("✅ User signed in: \(user.username)")
    }

    func signOut() {
        self.currentUser = nil
        self.isAuthenticated = false
        clearUserSession()
        print("👋 User signed out")
    }

    private func loadUserSession() {
        if let userData = UserDefaults.standard.data(forKey: "currentUser"),
           let user = try? JSONDecoder().decode(UserProfile.self, from: userData) {
            self.currentUser = user
            self.isAuthenticated = true
            self.isOnboarding = false
            print("📱 User session restored: \(user.username)")
        }
    }

    private func saveUserSession() {
        if let user = currentUser,
           let userData = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(userData, forKey: "currentUser")
        }
    }

    private func clearUserSession() {
        UserDefaults.standard.removeObject(forKey: "currentUser")
    }

    // MARK: - Learning Session

    func startLearningSession() {
        let session = LearningSession(
            id: UUID(),
            language: currentLanguage,
            startTime: Date()
        )
        self.activeSession = session
        self.sessionStartTime = Date()
        self.isLearningSpaceActive = true
        print("🎓 Learning session started")
    }

    func endLearningSession() {
        guard let session = activeSession, let startTime = sessionStartTime else { return }

        let duration = Date().timeIntervalSince(startTime)
        conversationTimeToday += duration

        // Save session
        saveSessionData(session, duration: duration)

        self.activeSession = nil
        self.sessionStartTime = nil
        self.isLearningSpaceActive = false

        print("✅ Learning session ended. Duration: \(Int(duration))s")
    }

    private func saveSessionData(_ session: LearningSession, duration: TimeInterval) {
        // TODO: Save to CoreData
    }

    // MARK: - Progress Tracking

    func incrementWordsEncountered(by count: Int = 1) {
        wordsEncounteredToday += count
        updateStreak()
        saveProgress()
    }

    func addConversationTime(_ duration: TimeInterval) {
        conversationTimeToday += duration
        saveProgress()
    }

    private func updateStreak() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let lastActive = calendar.startOfDay(for: lastActiveDate)

        if today == lastActive {
            // Same day, no change
            return
        } else if calendar.dateComponents([.day], from: lastActive, to: today).day == 1 {
            // Consecutive day
            currentStreak += 1
        } else {
            // Streak broken
            currentStreak = 1
        }

        lastActiveDate = Date()
    }

    private func loadProgress() {
        wordsEncounteredToday = UserDefaults.standard.integer(forKey: "wordsEncounteredToday")
        conversationTimeToday = UserDefaults.standard.double(forKey: "conversationTimeToday")
        currentStreak = UserDefaults.standard.integer(forKey: "currentStreak")

        if let lastActive = UserDefaults.standard.object(forKey: "lastActiveDate") as? Date {
            lastActiveDate = lastActive
        }

        // Reset daily stats if new day
        let calendar = Calendar.current
        if !calendar.isDateInToday(lastActiveDate) {
            resetDailyStats()
        }
    }

    private func saveProgress() {
        UserDefaults.standard.set(wordsEncounteredToday, forKey: "wordsEncounteredToday")
        UserDefaults.standard.set(conversationTimeToday, forKey: "conversationTimeToday")
        UserDefaults.standard.set(currentStreak, forKey: "currentStreak")
        UserDefaults.standard.set(lastActiveDate, forKey: "lastActiveDate")
    }

    private func resetDailyStats() {
        wordsEncounteredToday = 0
        conversationTimeToday = 0
        saveProgress()
    }

    // MARK: - Computed Properties

    var todayProgress: Double {
        // Target: 20 words per day
        return min(Double(wordsEncounteredToday) / 20.0, 1.0)
    }

    var hasCompletedOnboarding: Bool {
        !isOnboarding && isAuthenticated
    }
}

// MARK: - Supporting Types

enum LabelSize: String, Codable {
    case small, medium, large

    var fontSize: Float {
        switch self {
        case .small: return 0.03
        case .medium: return 0.05
        case .large: return 0.07
        }
    }
}
