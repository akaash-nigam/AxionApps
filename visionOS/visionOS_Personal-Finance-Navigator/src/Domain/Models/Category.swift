// Category.swift
// Personal Finance Navigator
// Domain model for transaction categories

import Foundation

/// Represents a transaction category (hierarchical)
struct Category: Identifiable, Codable, Hashable {
    // MARK: - Identity
    let id: UUID
    let plaidCategoryId: String?

    // MARK: - Hierarchy
    var name: String
    let parentId: UUID?
    let level: Int16
    let path: String

    // MARK: - Display
    var icon: String
    var color: String
    var sortOrder: Int16

    // MARK: - Classification
    let isIncome: Bool
    let isExpense: Bool
    let isTransfer: Bool
    let isEssential: Bool
    let isDiscretionary: Bool

    // MARK: - Budget
    let isDefaultBudgeted: Bool
    let suggestedPercentage: Float?

    // MARK: - Metadata
    let createdAt: Date
    var updatedAt: Date

    // MARK: - Init
    init(
        id: UUID = UUID(),
        plaidCategoryId: String? = nil,
        name: String,
        parentId: UUID? = nil,
        level: Int16 = 0,
        path: String? = nil,
        icon: String = "folder.fill",
        color: String = "#808080",
        sortOrder: Int16 = 0,
        isIncome: Bool = false,
        isExpense: Bool = true,
        isTransfer: Bool = false,
        isEssential: Bool = false,
        isDiscretionary: Bool = false,
        isDefaultBudgeted: Bool = true,
        suggestedPercentage: Float? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.plaidCategoryId = plaidCategoryId
        self.name = name
        self.parentId = parentId
        self.level = level
        self.path = path ?? name
        self.icon = icon
        self.color = color
        self.sortOrder = sortOrder
        self.isIncome = isIncome
        self.isExpense = isExpense
        self.isTransfer = isTransfer
        self.isEssential = isEssential
        self.isDiscretionary = isDiscretionary
        self.isDefaultBudgeted = isDefaultBudgeted
        self.suggestedPercentage = suggestedPercentage
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    // MARK: - Computed Properties
    var isRootCategory: Bool {
        parentId == nil
    }
}

// MARK: - Default Categories
extension Category {
    /// Creates the default category hierarchy
    static func createDefaultCategories() -> [Category] {
        var categories: [Category] = []

        // Income
        let income = Category(
            name: "Income",
            icon: "dollarsign.circle.fill",
            color: "#34C759",
            isIncome: true,
            isExpense: false,
            isDefaultBudgeted: false
        )
        categories.append(income)

        // Housing
        let housing = Category(
            name: "Housing",
            icon: "house.fill",
            color: "#FF9500",
            isEssential: true,
            suggestedPercentage: 30
        )
        categories.append(housing)

        // Transportation
        let transportation = Category(
            name: "Transportation",
            icon: "car.fill",
            color: "#007AFF",
            isEssential: true,
            suggestedPercentage: 15
        )
        categories.append(transportation)

        // Food & Drink
        let food = Category(
            name: "Food & Drink",
            icon: "fork.knife",
            color: "#34C759",
            isEssential: true,
            suggestedPercentage: 12
        )
        categories.append(food)

        // Shopping
        let shopping = Category(
            name: "Shopping",
            icon: "cart.fill",
            color: "#FF2D55",
            isDiscretionary: true,
            suggestedPercentage: 8
        )
        categories.append(shopping)

        // Entertainment
        let entertainment = Category(
            name: "Entertainment",
            icon: "film.fill",
            color: "#AF52DE",
            isDiscretionary: true,
            suggestedPercentage: 5
        )
        categories.append(entertainment)

        // Healthcare
        let healthcare = Category(
            name: "Healthcare",
            icon: "cross.case.fill",
            color: "#FF3B30",
            isEssential: true,
            suggestedPercentage: 8
        )
        categories.append(healthcare)

        // Utilities
        let utilities = Category(
            name: "Utilities",
            icon: "bolt.fill",
            color: "#FFC400",
            isEssential: true,
            suggestedPercentage: 6
        )
        categories.append(utilities)

        // Subscriptions
        let subscriptions = Category(
            name: "Subscriptions",
            icon: "repeat.circle.fill",
            color: "#5856D6",
            suggestedPercentage: 3
        )
        categories.append(subscriptions)

        // Savings & Investments
        let savings = Category(
            name: "Savings & Investments",
            icon: "banknote.fill",
            color: "#FFD700",
            isExpense: false,
            isDefaultBudgeted: false
        )
        categories.append(savings)

        // Debt Payments
        let debt = Category(
            name: "Debt Payments",
            icon: "creditcard.fill",
            color: "#8B0000",
            isEssential: true
        )
        categories.append(debt)

        // Uncategorized
        let uncategorized = Category(
            name: "Uncategorized",
            icon: "questionmark.circle.fill",
            color: "#808080",
            isDefaultBudgeted: false
        )
        categories.append(uncategorized)

        return categories
    }

    /// Sample categories for previews
    static let samples = createDefaultCategories()

    static let sampleHousing = Category(
        name: "Housing",
        icon: "house.fill",
        color: "#FF9500",
        isEssential: true,
        suggestedPercentage: 30
    )

    static let sampleFood = Category(
        name: "Food & Drink",
        icon: "fork.knife",
        color: "#34C759",
        isEssential: true,
        suggestedPercentage: 12
    )

    static let sampleShopping = Category(
        name: "Shopping",
        icon: "cart.fill",
        color: "#FF2D55",
        isDiscretionary: true,
        suggestedPercentage: 8
    )
}

// MARK: - Category Mapping
/// Helper for mapping Plaid categories to app categories
struct CategoryMapper {
    /// Maps a Plaid category to app category
    static func mapPlaidCategory(_ plaidCategories: [String]) -> String {
        guard let primary = plaidCategories.first else {
            return "Uncategorized"
        }

        // Map Plaid's category hierarchy to our simplified categories
        switch primary.lowercased() {
        case "income": return "Income"
        case "transfer": return "Transfer"
        case "food and drink": return "Food & Drink"
        case "shops": return "Shopping"
        case "recreation": return "Entertainment"
        case "transportation": return "Transportation"
        case "healthcare": return "Healthcare"
        case "service": return "Utilities"
        case "rent and utilities": return "Housing"
        case "payment": return "Debt Payments"
        default: return "Uncategorized"
        }
    }
}
