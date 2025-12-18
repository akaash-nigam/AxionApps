import Foundation
import SwiftData

/// Represents an investment phase with budget and timeline
@Model
final class InvestmentPhase {
    /// Unique identifier
    var id: UUID

    /// Phase name (e.g., "Foundation", "Scaling")
    var name: String

    /// Timeline description (e.g., "Q1-Q2 2025")
    var timeline: String

    /// Budget range
    var budgetMin: Int  // in thousands
    var budgetMax: Int  // in thousands

    /// Checklist items for this phase
    @Relationship(deleteRule: .cascade)
    var checklist: [ChecklistItem]

    /// Phase order
    var order: Int

    /// Phase description
    var descriptionText: String?

    /// Initialize a new investment phase
    /// - Parameters:
    ///   - id: Unique identifier
    ///   - name: Phase name
    ///   - timeline: Timeline description
    ///   - budgetMin: Minimum budget (in thousands)
    ///   - budgetMax: Maximum budget (in thousands)
    ///   - checklist: Checklist items
    ///   - order: Display order
    ///   - descriptionText: Optional description
    init(
        id: UUID = UUID(),
        name: String,
        timeline: String,
        budgetMin: Int,
        budgetMax: Int,
        checklist: [ChecklistItem] = [],
        order: Int = 0,
        descriptionText: String? = nil
    ) {
        self.id = id
        self.name = name
        self.timeline = timeline
        self.budgetMin = budgetMin
        self.budgetMax = budgetMax
        self.checklist = checklist
        self.order = order
        self.descriptionText = descriptionText
    }

    /// Formatted budget range
    var budgetRange: String {
        "$\(budgetMin)K-$\(budgetMax)K"
    }

    /// Budget midpoint for visualization
    var budgetMidpoint: Int {
        (budgetMin + budgetMax) / 2
    }

    /// Completion percentage
    var completionPercentage: Double {
        guard !checklist.isEmpty else { return 0 }
        let completed = checklist.filter { $0.completed }.count
        return Double(completed) / Double(checklist.count) * 100
    }

    /// Is phase complete
    var isComplete: Bool {
        completionPercentage == 100
    }
}

/// A checklist item within an investment phase
@Model
final class ChecklistItem {
    /// Unique identifier
    var id: UUID

    /// Task description
    var task: String

    /// Completion status
    var completed: Bool

    /// Optional assignee
    var assignee: String?

    /// Optional due date
    var dueDate: Date?

    /// Priority level (1 = highest)
    var priority: Int

    /// Initialize a new checklist item
    init(
        id: UUID = UUID(),
        task: String,
        completed: Bool = false,
        assignee: String? = nil,
        dueDate: Date? = nil,
        priority: Int = 5
    ) {
        self.id = id
        self.task = task
        self.completed = completed
        self.assignee = assignee
        self.dueDate = dueDate
        self.priority = priority
    }
}

// MARK: - Hashable & Equatable
extension InvestmentPhase: Hashable {
    static func == (lhs: InvestmentPhase, rhs: InvestmentPhase) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension ChecklistItem: Hashable {
    static func == (lhs: ChecklistItem, rhs: ChecklistItem) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
