// BudgetViewModel.swift
// Personal Finance Navigator
// ViewModel for budget management

import Foundation
import SwiftUI
import OSLog

private let logger = Logger(subsystem: "com.pfn", category: "viewmodel")

/// ViewModel for managing budgets
@MainActor
@Observable
class BudgetViewModel {
    // MARK: - Published State

    private(set) var budgets: [Budget] = []
    private(set) var activeBudget: Budget?
    private(set) var isLoading = false
    private(set) var errorMessage: String?

    // Category progress tracking
    private(set) var categoryProgress: [UUID: (spent: Decimal, allocated: Decimal, percentage: Double)] = [:]

    // Computed properties
    var hasBudgets: Bool {
        !budgets.isEmpty
    }

    var activeBudgetProgress: (spent: Decimal, allocated: Decimal, percentage: Double)? {
        guard let budget = activeBudget else { return nil }

        let spent = budget.categories.reduce(Decimal.zero) { $0 + $1.spent }
        let allocated = budget.categories.reduce(Decimal.zero) { $0 + $1.allocated }
        let percentage = allocated > 0 ? Double(truncating: (spent / allocated) as NSDecimalNumber) * 100 : 0

        return (spent: spent, allocated: allocated, percentage: percentage)
    }

    var isOverBudget: Bool {
        guard let progress = activeBudgetProgress else { return false }
        return progress.percentage > 100
    }

    var budgetStatusColor: Color {
        guard let progress = activeBudgetProgress else { return .gray }

        if progress.percentage >= 100 {
            return .red
        } else if progress.percentage >= 90 {
            return .orange
        } else if progress.percentage >= 75 {
            return .yellow
        } else {
            return .green
        }
    }

    // MARK: - Dependencies

    private let budgetRepository: BudgetRepository
    private let transactionRepository: TransactionRepository
    private let categoryRepository: CategoryRepository

    // MARK: - Init

    init(
        budgetRepository: BudgetRepository,
        transactionRepository: TransactionRepository,
        categoryRepository: CategoryRepository
    ) {
        self.budgetRepository = budgetRepository
        self.transactionRepository = transactionRepository
        self.categoryRepository = categoryRepository
    }

    // MARK: - Fetch Methods

    func loadBudgets() async {
        isLoading = true
        errorMessage = nil

        do {
            budgets = try await budgetRepository.fetchAll()
            activeBudget = try await budgetRepository.fetchActive()

            if let active = activeBudget {
                await updateBudgetProgress(for: active)
            }

            logger.info("Loaded \(self.budgets.count) budgets, active: \(self.activeBudget != nil)")
        } catch {
            errorMessage = "Failed to load budgets: \(error.localizedDescription)"
            logger.error("Failed to load budgets: \(error.localizedDescription)")
        }

        isLoading = false
    }

    func refreshBudgets() async {
        await loadBudgets()
    }

    func loadBudget(id: UUID) async -> Budget? {
        do {
            return try await budgetRepository.fetchById(id)
        } catch {
            logger.error("Failed to load budget \(id): \(error.localizedDescription)")
            return nil
        }
    }

    // MARK: - CRUD Operations

    func createBudget(_ budget: Budget) async -> Bool {
        isLoading = true
        errorMessage = nil

        do {
            try await budgetRepository.save(budget)
            await loadBudgets()
            logger.info("Created budget: \(budget.name)")
            return true
        } catch {
            errorMessage = "Failed to create budget: \(error.localizedDescription)"
            logger.error("Failed to create budget: \(error.localizedDescription)")
            return false
        }
    }

    func updateBudget(_ budget: Budget) async -> Bool {
        isLoading = true
        errorMessage = nil

        do {
            try await budgetRepository.save(budget)
            await loadBudgets()
            logger.info("Updated budget: \(budget.name)")
            return true
        } catch {
            errorMessage = "Failed to update budget: \(error.localizedDescription)"
            logger.error("Failed to update budget: \(error.localizedDescription)")
            return false
        }
    }

    func deleteBudget(_ budget: Budget) async -> Bool {
        isLoading = true
        errorMessage = nil

        do {
            try await budgetRepository.delete(budget)
            await loadBudgets()
            logger.info("Deleted budget: \(budget.name)")
            return true
        } catch {
            errorMessage = "Failed to delete budget: \(error.localizedDescription)"
            logger.error("Failed to delete budget: \(error.localizedDescription)")
            return false
        }
    }

    // MARK: - Budget Progress

    func updateBudgetProgress(for budget: Budget) async {
        // Calculate spent amounts for each category
        for category in budget.categories {
            guard let categoryId = category.categoryId else { continue }

            do {
                // Get transactions for this category in budget period
                let transactions = try await transactionRepository.fetchByDateRange(
                    from: budget.startDate,
                    to: budget.endDate
                )

                // Filter by category and calculate spent
                let categoryTransactions = transactions.filter { $0.categoryId == categoryId && $0.amount < 0 }
                let spent = abs(categoryTransactions.reduce(Decimal.zero) { $0 + $1.amount })

                // Update repository
                try await budgetRepository.updateCategorySpent(budget.id, categoryId: categoryId, spent: spent)

                // Update local cache
                let percentage = category.allocated > 0
                    ? Double(truncating: (spent / category.allocated) as NSDecimalNumber) * 100
                    : 0

                categoryProgress[categoryId] = (spent: spent, allocated: category.allocated, percentage: percentage)
            } catch {
                logger.error("Failed to update category progress: \(error.localizedDescription)")
            }
        }

        // Reload to get updated data
        await loadBudgets()
    }

    func getCategoryProgress(budgetId: UUID, categoryId: UUID) async -> (spent: Decimal, allocated: Decimal, percentage: Double)? {
        do {
            return try await budgetRepository.getCategoryProgress(budgetId, categoryId: categoryId)
        } catch {
            logger.error("Failed to get category progress: \(error.localizedDescription)")
            return nil
        }
    }

    // MARK: - Helper Methods

    func clearError() {
        errorMessage = nil
    }

    func getFormattedAmount(_ amount: Decimal, currencyCode: String = "USD") -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode
        return formatter.string(from: amount as NSDecimalNumber) ?? "$0.00"
    }

    func formatPercentage(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value / 100)) ?? "0%"
    }

    func formatDateRange(from startDate: Date, to endDate: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium

        return "\(formatter.string(from: startDate)) - \(formatter.string(from: endDate))"
    }

    func getRemainingAmount(allocated: Decimal, spent: Decimal) -> Decimal {
        return max(allocated - spent, 0)
    }

    func getOverspendAmount(allocated: Decimal, spent: Decimal) -> Decimal {
        return max(spent - allocated, 0)
    }

    // MARK: - Budget Suggestions

    func suggestBudgetAmounts(based totalIncome: Decimal, strategy: Budget.BudgetStrategy) -> [String: Decimal] {
        switch strategy {
        case .fiftyThirtyTwenty:
            return [
                "Needs": totalIncome * 0.50,
                "Wants": totalIncome * 0.30,
                "Savings": totalIncome * 0.20
            ]

        case .zeroBased:
            return ["Total Budget": totalIncome]

        case .envelope:
            return ["Total Budget": totalIncome]

        case .percentageBased:
            return [
                "Housing": totalIncome * 0.30,
                "Transportation": totalIncome * 0.15,
                "Food": totalIncome * 0.15,
                "Utilities": totalIncome * 0.10,
                "Savings": totalIncome * 0.10,
                "Personal": totalIncome * 0.10,
                "Other": totalIncome * 0.10
            ]
        }
    }
}
