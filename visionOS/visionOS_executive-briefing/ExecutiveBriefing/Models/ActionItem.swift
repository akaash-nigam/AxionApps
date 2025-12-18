import Foundation
import SwiftData

/// Represents an action item for a specific executive role
@Model
final class ActionItem {
    /// Unique identifier
    var id: UUID

    /// Executive role this action is for
    var role: ExecutiveRole

    /// Action item title
    var title: String

    /// Detailed description
    var descriptionText: String

    /// Priority level (1 = highest)
    var priority: Int

    /// Completion status
    var completed: Bool

    /// Date completed
    var completedDate: Date?

    /// Optional due date
    var dueDate: Date?

    /// Optional notes
    var notes: String?

    /// Order within role's action list
    var order: Int

    /// Initialize a new action item
    /// - Parameters:
    ///   - id: Unique identifier
    ///   - role: Executive role
    ///   - title: Action title
    ///   - descriptionText: Detailed description
    ///   - priority: Priority level (1 = highest)
    ///   - completed: Completion status
    ///   - dueDate: Optional due date
    ///   - order: Display order
    init(
        id: UUID = UUID(),
        role: ExecutiveRole,
        title: String,
        descriptionText: String,
        priority: Int = 5,
        completed: Bool = false,
        dueDate: Date? = nil,
        order: Int = 0
    ) {
        self.id = id
        self.role = role
        self.title = title
        self.descriptionText = descriptionText
        self.priority = priority
        self.completed = completed
        self.completedDate = nil
        self.dueDate = dueDate
        self.notes = nil
        self.order = order
    }

    /// Mark as complete
    func markComplete() {
        completed = true
        completedDate = Date()
    }

    /// Mark as incomplete
    func markIncomplete() {
        completed = false
        completedDate = nil
    }

    /// Priority label
    var priorityLabel: String {
        switch priority {
        case 1: return "Critical"
        case 2: return "High"
        case 3: return "Medium"
        case 4...5: return "Normal"
        default: return "Low"
        }
    }

    /// Accessibility description
    var accessibilityDescription: String {
        var desc = "\(title), for \(role.displayName), \(priorityLabel) priority"
        desc += completed ? ", completed" : ", not completed"
        return desc
    }
}

/// Executive roles
enum ExecutiveRole: String, Codable, CaseIterable {
    case ceo
    case cfo
    case cto
    case cio
    case chro
    case cmo
    case legal

    var displayName: String {
        switch self {
        case .ceo: return "CEO"
        case .cfo: return "CFO"
        case .cto: return "CTO"
        case .cio: return "CIO"
        case .chro: return "CHRO"
        case .cmo: return "CMO"
        case .legal: return "Legal/Risk"
        }
    }

    var icon: String {
        switch self {
        case .ceo: return "star.fill"
        case .cfo: return "dollarsign.circle.fill"
        case .cto, .cio: return "cpu.fill"
        case .chro: return "person.2.fill"
        case .cmo: return "megaphone.fill"
        case .legal: return "scale.3d"
        }
    }

    var description: String {
        switch self {
        case .ceo: return "Chief Executive Officer"
        case .cfo: return "Chief Financial Officer"
        case .cto: return "Chief Technology Officer"
        case .cio: return "Chief Information Officer"
        case .chro: return "Chief Human Resources Officer"
        case .cmo: return "Chief Marketing Officer"
        case .legal: return "Legal and Risk Management"
        }
    }
}

// MARK: - Hashable & Equatable
extension ActionItem: Hashable {
    static func == (lhs: ActionItem, rhs: ActionItem) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
