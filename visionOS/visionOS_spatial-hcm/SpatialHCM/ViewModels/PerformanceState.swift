import Foundation

// MARK: - Performance State
@Observable
final class PerformanceState {
    // MARK: - Data
    var performanceData: [UUID: PerformanceData] = [:]
    var goals: [Goal] = []

    // MARK: - Loading State
    var isLoading: Bool = false
    var error: Error?

    // MARK: - Selection
    var selectedGoal: Goal?

    // MARK: - Computed Properties
    var activeGoals: [Goal] {
        goals.filter { $0.status == .inProgress }
    }

    var completedGoals: [Goal] {
        goals.filter { $0.status == .completed }
    }

    var overdueGoals: [Goal] {
        goals.filter { $0.isOverdue }
    }

    var goalsOnTrack: [Goal] {
        goals.filter { $0.isOnTrack && !$0.isOverdue }
    }

    var completionRate: Double {
        guard !goals.isEmpty else { return 0.0 }
        return Double(completedGoals.count) / Double(goals.count) * 100.0
    }

    // MARK: - Methods
    func loadPerformanceData(for employee: Employee) {
        // In a real app, fetch from service
        print("Loading performance data for \(employee.fullName)")
    }

    func createGoal(_ goal: Goal) {
        goals.append(goal)
    }

    func updateGoal(_ goal: Goal) {
        if let index = goals.firstIndex(where: { $0.id == goal.id }) {
            goals[index] = goal
        }
    }

    func deleteGoal(_ goal: Goal) {
        goals.removeAll { $0.id == goal.id }
    }

    func completeGoal(_ goal: Goal) {
        if let index = goals.firstIndex(where: { $0.id == goal.id }) {
            goals[index].status = .completed
            goals[index].completedDate = Date()
            goals[index].progressPercentage = 100.0
        }
    }
}
