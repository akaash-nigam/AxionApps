import SwiftUI
import Observation

@Observable
final class DashboardViewModel {
    // MARK: - Properties

    var completedToday: Int = 2
    var totalAssigned: Int = 5
    var recentAchievements: [Achievement] = []

    var completionPercentage: Double {
        guard totalAssigned > 0 else { return 0 }
        return Double(completedToday) / Double(totalAssigned) * 100
    }

    // MARK: - Initialization

    init() {
        loadDashboardData()
    }

    // MARK: - Methods

    private func loadDashboardData() {
        // In production, this would fetch from SwiftData
        // For now, using mock data
        recentAchievements = [
            Achievement(
                title: "Perfect Score - Lockout/Tagout",
                icon: "star.fill",
                earnedDate: Date().addingTimeInterval(-2 * 24 * 3600),
                color: "yellow"
            ),
            Achievement(
                title: "Expert Level Unlocked",
                icon: "flame.fill",
                earnedDate: Date().addingTimeInterval(-7 * 24 * 3600),
                color: "orange"
            )
        ]
    }

    func refreshData() {
        loadDashboardData()
    }
}

// MARK: - Achievement

struct Achievement: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
    let earnedDate: Date
    let color: String

    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: earnedDate, relativeTo: Date())
    }
}
