// Budget.swift
// Personal Finance Navigator
// Domain models for budgets

import Foundation

/// Represents a budget plan with category allocations
struct Budget: Identifiable, Codable, Hashable {
    // MARK: - Identity
    let id: UUID

    // MARK: - Details
    var name: String
    let type: BudgetType
    let startDate: Date
    let endDate: Date

    // MARK: - Totals
    var totalIncome: Decimal
    var totalAllocated: Decimal
    var totalSpent: Decimal

    // MARK: - Status
    var isActive: Bool
    var isTemplate: Bool

    // MARK: - Strategy
    let strategy: BudgetStrategy

    // MARK: - Metadata
    let createdAt: Date
    var updatedAt: Date

    // MARK: - Relationships
    var categories: [BudgetCategory]

    // MARK: - Init
    init(
        id: UUID = UUID(),
        name: String,
        type: BudgetType = .monthly,
        startDate: Date,
        endDate: Date,
        totalIncome: Decimal,
        totalAllocated: Decimal = 0,
        totalSpent: Decimal = 0,
        isActive: Bool = true,
        isTemplate: Bool = false,
        strategy: BudgetStrategy = .fiftyThirtyTwenty,
        categories: [BudgetCategory] = [],
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.type = type
        self.startDate = startDate
        self.endDate = endDate
        self.totalIncome = totalIncome
        self.totalAllocated = totalAllocated
        self.totalSpent = totalSpent
        self.isActive = isActive
        self.isTemplate = isTemplate
        self.strategy = strategy
        self.categories = categories
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    // MARK: - Computed Properties
    var totalRemaining: Decimal {
        totalAllocated - totalSpent
    }

    var percentageSpent: Float {
        guard totalAllocated > 0 else { return 0 }
        return Float(truncating: (totalSpent / totalAllocated * 100) as NSDecimalNumber)
    }

    var isOverBudget: Bool {
        totalSpent > totalAllocated
    }

    var categoriesOverBudget: [BudgetCategory] {
        categories.filter { $0.spent > $0.allocated }
    }

    var status: BudgetStatus {
        let percentage = percentageSpent

        if percentage >= 100 {
            return .exceeded
        } else if percentage >= 90 {
            return .danger
        } else if percentage >= 75 {
            return .warning
        } else {
            return .safe
        }
    }
}

// MARK: - Budget Type
enum BudgetType: String, Codable, CaseIterable {
    case monthly
    case weekly
    case annual
    case custom

    var displayName: String {
        rawValue.capitalized
    }
}

// MARK: - Budget Strategy
enum BudgetStrategy: String, Codable, CaseIterable {
    case fiftyThirtyTwenty = "50/30/20"
    case zeroBased = "Zero-Based"
    case envelope = "Envelope"
    case percentageBased = "Percentage-Based"

    var description: String {
        switch self {
        case .fiftyThirtyTwenty:
            return "50% needs, 30% wants, 20% savings"
        case .zeroBased:
            return "Every dollar assigned"
        case .envelope:
            return "Fixed amounts per category"
        case .percentageBased:
            return "Custom % of income"
        }
    }
}

// MARK: - Budget Status
enum BudgetStatus {
    case safe
    case warning
    case danger
    case exceeded

    var color: String {
        switch self {
        case .safe: return "#34C759"
        case .warning: return "#FFC400"
        case .danger: return "#FF9500"
        case .exceeded: return "#FF3B30"
        }
    }
}

// MARK: - Budget Category
struct BudgetCategory: Identifiable, Codable, Hashable {
    // MARK: - Identity
    let id: UUID
    let budgetId: UUID
    let categoryId: UUID

    // MARK: - Allocation
    var allocated: Decimal
    var spent: Decimal
    var percentageOfBudget: Float

    // MARK: - Tracking
    var isRollover: Bool
    var rolledAmount: Decimal?

    // MARK: - Alerts
    var alertAt75: Bool
    var alertAt90: Bool
    var alertAt100: Bool
    var alertOnOverspend: Bool

    // MARK: - Metadata
    let createdAt: Date
    var updatedAt: Date

    // MARK: - Display
    var categoryName: String // Denormalized for performance

    // MARK: - Init
    init(
        id: UUID = UUID(),
        budgetId: UUID,
        categoryId: UUID,
        allocated: Decimal,
        spent: Decimal = 0,
        percentageOfBudget: Float = 0,
        isRollover: Bool = false,
        rolledAmount: Decimal? = nil,
        alertAt75: Bool = true,
        alertAt90: Bool = true,
        alertAt100: Bool = true,
        alertOnOverspend: Bool = true,
        categoryName: String,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.budgetId = budgetId
        self.categoryId = categoryId
        self.allocated = allocated
        self.spent = spent
        self.percentageOfBudget = percentageOfBudget
        self.isRollover = isRollover
        self.rolledAmount = rolledAmount
        self.alertAt75 = alertAt75
        self.alertAt90 = alertAt90
        self.alertAt100 = alertAt100
        self.alertOnOverspend = alertOnOverspend
        self.categoryName = categoryName
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    // MARK: - Computed Properties
    var remaining: Decimal {
        allocated - spent
    }

    var percentageSpent: Float {
        guard allocated > 0 else { return 0 }
        return Float(truncating: (spent / allocated * 100) as NSDecimalNumber)
    }

    var isOverBudget: Bool {
        spent > allocated
    }

    var status: BudgetStatus {
        let percentage = percentageSpent

        if percentage >= 100 {
            return .exceeded
        } else if percentage >= 90 {
            return .danger
        } else if percentage >= 75 {
            return .warning
        } else {
            return .safe
        }
    }
}

// MARK: - Sample Data (for previews)
extension Budget {
    static let sample = Budget(
        name: "December 2024",
        startDate: Date(),
        endDate: Calendar.current.date(byAdding: .month, value: 1, to: Date())!,
        totalIncome: 5000,
        totalAllocated: 5000,
        totalSpent: 3245,
        strategy: .fiftyThirtyTwenty,
        categories: [
            BudgetCategory(
                budgetId: UUID(),
                categoryId: UUID(),
                allocated: 500,
                spent: 425,
                percentageOfBudget: 10,
                categoryName: "Groceries"
            ),
            BudgetCategory(
                budgetId: UUID(),
                categoryId: UUID(),
                allocated: 200,
                spent: 185,
                percentageOfBudget: 4,
                categoryName: "Dining Out"
            ),
            BudgetCategory(
                budgetId: UUID(),
                categoryId: UUID(),
                allocated: 300,
                spent: 320,
                percentageOfBudget: 6,
                categoryName: "Shopping"
            )
        ]
    )
}
