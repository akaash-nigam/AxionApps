import Foundation
import Observation

@Observable
final class GoalsViewModel {
    // MARK: - Dependencies

    private let sustainabilityService: SustainabilityService

    // MARK: - State

    var goals: [SustainabilityGoal] = []
    var selectedGoal: SustainabilityGoal?

    var isLoading = false
    var isSaving = false
    var error: Error?

    // MARK: - Computed Properties

    var activeGoals: [SustainabilityGoal] {
        goals.filter { $0.status != .achieved }
    }

    var achievedGoals: [SustainabilityGoal] {
        goals.filter { $0.status == .achieved }
    }

    var onTrackGoals: [SustainabilityGoal] {
        goals.filter { $0.status == .onTrack }
    }

    var atRiskGoals: [SustainabilityGoal] {
        goals.filter { $0.status == .atRisk }
    }

    var behindGoals: [SustainabilityGoal] {
        goals.filter { $0.status == .behind }
    }

    var overallProgress: Double {
        guard !goals.isEmpty else { return 0 }
        return goals.map { $0.progress }.reduce(0, +) / Double(goals.count)
    }

    var goalsByCategory: [GoalCategory: [SustainabilityGoal]] {
        Dictionary(grouping: goals, by: { $0.category })
    }

    // MARK: - Initialization

    init(sustainabilityService: SustainabilityService) {
        self.sustainabilityService = sustainabilityService
    }

    // MARK: - Actions

    @MainActor
    func loadGoals() async {
        isLoading = true
        error = nil

        do {
            goals = try await sustainabilityService.fetchGoals()
        } catch {
            self.error = error
        }

        isLoading = false
    }

    @MainActor
    func createGoal(
        title: String,
        description: String,
        category: GoalCategory,
        baselineValue: Double,
        targetValue: Double,
        targetDate: Date
    ) async throws {
        isSaving = true
        defer { isSaving = false }

        // Validate inputs
        guard !title.isEmpty else {
            throw GoalError.invalidTitle
        }

        guard targetValue != baselineValue else {
            throw GoalError.invalidTargetValue
        }

        guard targetDate > Date() else {
            throw GoalError.invalidTargetDate
        }

        // Create goal model
        let goalModel = SustainabilityGoalModel(
            title: title,
            description: description,
            category: category.rawValue,
            baselineValue: baselineValue,
            currentValue: baselineValue,
            targetValue: targetValue,
            unit: Constants.Units.carbonUnit,
            startDate: Date(),
            targetDate: targetDate
        )

        let goal = SustainabilityGoal(from: goalModel)

        // Save via service
        let createdGoal = try await sustainabilityService.createGoal(goal)

        // Add to local array
        goals.append(createdGoal)
    }

    @MainActor
    func updateGoalProgress(
        goalId: UUID,
        currentValue: Double
    ) async throws {
        guard let index = goals.firstIndex(where: { $0.id == goalId }) else {
            throw GoalError.goalNotFound
        }

        var goal = goals[index]

        // Calculate new progress
        let progress = abs(currentValue - goal.baselineValue) / abs(goal.targetValue - goal.baselineValue)

        // Determine new status
        let status = determineGoalStatus(progress: progress, daysRemaining: goal.daysRemaining)

        // Create updated goal
        let updatedModel = SustainabilityGoalModel(
            id: goal.id,
            title: goal.title,
            description: goal.description,
            category: goal.category.rawValue,
            baselineValue: goal.baselineValue,
            currentValue: currentValue,
            targetValue: goal.targetValue,
            unit: goal.unit,
            startDate: goal.startDate,
            targetDate: goal.targetDate,
            status: status.rawValue
        )

        let updatedGoal = SustainabilityGoal(from: updatedModel)

        // Update via service
        try await sustainabilityService.updateGoal(updatedGoal)

        // Update local array
        goals[index] = updatedGoal

        // Check if goal is achieved
        if status == .achieved {
            NotificationCenter.default.post(
                name: Constants.Notifications.goalAchieved,
                object: updatedGoal
            )
        }
    }

    @MainActor
    func deleteGoal(_ goalId: UUID) async throws {
        try await sustainabilityService.deleteGoal(id: goalId)
        goals.removeAll { $0.id == goalId }
    }

    func selectGoal(_ goal: SustainabilityGoal) {
        selectedGoal = goal
    }

    // MARK: - Helpers

    private func determineGoalStatus(progress: Double, daysRemaining: Int) -> GoalStatus {
        // Goal achieved
        if progress >= 1.0 {
            return .achieved
        }

        // Calculate expected progress based on time
        let totalDays = 365 // Assume 1 year for simplification
        let elapsedDays = totalDays - daysRemaining
        let expectedProgress = Double(elapsedDays) / Double(totalDays)

        // Compare actual vs expected
        if progress >= expectedProgress * Constants.Thresholds.onTrackThreshold {
            return .onTrack
        } else if progress >= expectedProgress * Constants.Thresholds.atRiskThreshold {
            return .atRisk
        } else {
            return .behind
        }
    }

    func timeRemainingText(for goal: SustainabilityGoal) -> String {
        let days = goal.daysRemaining

        if days < 0 {
            return "Overdue by \(abs(days)) days"
        } else if days == 0 {
            return "Due today"
        } else if days == 1 {
            return "1 day remaining"
        } else if days < 30 {
            return "\(days) days remaining"
        } else if days < 365 {
            let months = days / 30
            return "\(months) month\(months == 1 ? "" : "s") remaining"
        } else {
            let years = days / 365
            return "\(years) year\(years == 1 ? "" : "s") remaining"
        }
    }
}

// MARK: - Errors

enum GoalError: LocalizedError {
    case invalidTitle
    case invalidTargetValue
    case invalidTargetDate
    case goalNotFound

    var errorDescription: String? {
        switch self {
        case .invalidTitle:
            return "Goal title cannot be empty"
        case .invalidTargetValue:
            return "Target value must be different from baseline"
        case .invalidTargetDate:
            return "Target date must be in the future"
        case .goalNotFound:
            return "Goal not found"
        }
    }
}
