import Foundation
import SwiftData

/// Tracks user's reading progress through the briefing
@Model
final class UserProgress {
    /// Unique identifier
    var id: UUID

    /// User identifier (for future multi-user support)
    var userId: String

    /// Sections that have been visited
    var visitedSectionIds: [UUID]

    /// Action items that have been completed
    var completedActionItemIds: [UUID]

    /// Total time spent in app (seconds)
    var totalTimeSpent: TimeInterval

    /// Last session date
    var lastSessionDate: Date

    /// First session date
    var firstSessionDate: Date

    /// Favorite sections
    var favoriteSectionIds: [UUID]

    /// Preferred visualization mode
    var preferredVisualizationMode: String?

    /// Initialize new user progress
    /// - Parameters:
    ///   - id: Unique identifier
    ///   - userId: User identifier
    init(
        id: UUID = UUID(),
        userId: String = "default"
    ) {
        self.id = id
        self.userId = userId
        self.visitedSectionIds = []
        self.completedActionItemIds = []
        self.totalTimeSpent = 0
        self.lastSessionDate = Date()
        self.firstSessionDate = Date()
        self.favoriteSectionIds = []
        self.preferredVisualizationMode = nil
    }

    /// Record section visit
    func visitSection(_ sectionId: UUID) {
        if !visitedSectionIds.contains(sectionId) {
            visitedSectionIds.append(sectionId)
        }
        lastSessionDate = Date()
    }

    /// Record action item completion
    func completeActionItem(_ actionItemId: UUID) {
        if !completedActionItemIds.contains(actionItemId) {
            completedActionItemIds.append(actionItemId)
        }
    }

    /// Record action item incompletion
    func uncompleteActionItem(_ actionItemId: UUID) {
        completedActionItemIds.removeAll { $0 == actionItemId }
    }

    /// Add time spent
    func addTimeSpent(_ duration: TimeInterval) {
        totalTimeSpent += duration
        lastSessionDate = Date()
    }

    /// Toggle favorite section
    func toggleFavorite(_ sectionId: UUID) {
        if let index = favoriteSectionIds.firstIndex(of: sectionId) {
            favoriteSectionIds.remove(at: index)
        } else {
            favoriteSectionIds.append(sectionId)
        }
    }

    /// Check if section is favorite
    func isFavorite(_ sectionId: UUID) -> Bool {
        favoriteSectionIds.contains(sectionId)
    }

    /// Check if section has been visited
    func hasVisited(_ sectionId: UUID) -> Bool {
        visitedSectionIds.contains(sectionId)
    }

    /// Check if action item is completed
    func isActionItemCompleted(_ actionItemId: UUID) -> Bool {
        completedActionItemIds.contains(actionItemId)
    }

    /// Formatted total time spent
    var formattedTimeSpent: String {
        let hours = Int(totalTimeSpent) / 3600
        let minutes = Int(totalTimeSpent) / 60 % 60

        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }

    /// Reading progress percentage (0-100)
    func readingProgress(totalSections: Int) -> Double {
        guard totalSections > 0 else { return 0 }
        return Double(visitedSectionIds.count) / Double(totalSections) * 100
    }
}

// MARK: - Hashable & Equatable
extension UserProgress: Hashable {
    static func == (lhs: UserProgress, rhs: UserProgress) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
