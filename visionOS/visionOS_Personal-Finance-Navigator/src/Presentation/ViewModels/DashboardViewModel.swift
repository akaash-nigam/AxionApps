// DashboardViewModel.swift
// Personal Finance Navigator
// ViewModel for dashboard overview

import Foundation
import SwiftUI
import OSLog

private let logger = Logger(subsystem: "com.pfn", category: "dashboard")

/// ViewModel for the main dashboard screen
@MainActor
@Observable
class DashboardViewModel {
    // MARK: - Published State

    private(set) var isLoading = false
    private(set) var errorMessage: String?
    private(set) var lastRefreshDate: Date?

    // Account data
    private(set) var totalNetWorth: Decimal = 0
    private(set) var totalAssets: Decimal = 0
    private(set) var totalLiabilities: Decimal = 0
    private(set) var accountCount: Int = 0

    // Budget data
    private(set) var activeBudget: Budget?
    private(set) var budgetProgress: BudgetProgress?
    private(set) var monthlyBudgetAmount: Decimal = 0
    private(set) var monthlySpent: Decimal = 0

    // Transaction data
    private(set) var recentTransactions: [Transaction] = []
    private(set) var thisMonthSpending: Decimal = 0
    private(set) var thisMonthIncome: Decimal = 0
    private(set) var transactionCount: Int = 0

    // Quick stats
    var budgetPercentage: Double {
        guard monthlyBudgetAmount > 0 else { return 0 }
        let spent = NSDecimalNumber(decimal: monthlySpent).doubleValue
        let budget = NSDecimalNumber(decimal: monthlyBudgetAmount).doubleValue
        return (spent / budget) * 100
    }

    var budgetStatusColor: Color {
        if budgetPercentage >= 100 { return .red }
        else if budgetPercentage >= 90 { return .orange }
        else if budgetPercentage >= 75 { return .yellow }
        else { return .green }
    }

    var netWorthTrend: TrendDirection {
        // TODO: Calculate based on historical data
        return .neutral
    }

    // MARK: - Dependencies

    private let accountRepository: AccountRepository
    private let transactionRepository: TransactionRepository
    private let budgetRepository: BudgetRepository

    // MARK: - Init

    init(
        accountRepository: AccountRepository,
        transactionRepository: TransactionRepository,
        budgetRepository: BudgetRepository
    ) {
        self.accountRepository = accountRepository
        self.transactionRepository = transactionRepository
        self.budgetRepository = budgetRepository
    }

    // MARK: - Load Methods

    /// Loads all dashboard data
    func loadDashboard() async {
        isLoading = true
        errorMessage = nil

        do {
            // Load data in parallel for better performance
            async let accountsTask = loadAccountData()
            async let budgetTask = loadBudgetData()
            async let transactionsTask = loadTransactionData()

            await accountsTask
            await budgetTask
            await transactionsTask

            lastRefreshDate = Date()
            logger.info("Dashboard loaded successfully")
        } catch {
            errorMessage = "Failed to load dashboard: \(error.localizedDescription)"
            logger.error("Dashboard load error: \(error.localizedDescription)")
        }

        isLoading = false
    }

    /// Refresh dashboard data
    func refresh() async {
        await loadDashboard()
    }

    // MARK: - Private Load Methods

    private func loadAccountData() async {
        do {
            let accounts = try await accountRepository.fetchAll()
            let activeAccounts = accounts.filter { $0.isActive && !$0.isHidden }

            accountCount = activeAccounts.count

            // Calculate net worth
            totalAssets = 0
            totalLiabilities = 0

            for account in activeAccounts {
                if account.type == .creditCard {
                    totalLiabilities += account.currentBalance
                } else {
                    totalAssets += account.currentBalance
                }
            }

            totalNetWorth = totalAssets - totalLiabilities

            logger.debug("Loaded account data: \(activeAccounts.count) accounts, net worth: \(self.totalNetWorth)")
        } catch {
            logger.error("Failed to load account data: \(error.localizedDescription)")
            throw error
        }
    }

    private func loadBudgetData() async {
        do {
            // Get active budget for current period
            let budgets = try await budgetRepository.fetchAll()
            activeBudget = budgets.first { $0.isActive }

            guard let budget = activeBudget else {
                logger.debug("No active budget found")
                return
            }

            monthlyBudgetAmount = budget.totalAllocated
            monthlySpent = budget.totalSpent

            // Calculate progress
            budgetProgress = calculateBudgetProgress(for: budget)

            logger.debug("Loaded budget data: \(budget.name), spent: \(self.monthlySpent)")
        } catch {
            logger.error("Failed to load budget data: \(error.localizedDescription)")
            throw error
        }
    }

    private func loadTransactionData() async {
        do {
            // Get transactions for current month
            let calendar = Calendar.current
            let now = Date()
            let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
            let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth)!

            let allTransactions = try await transactionRepository.fetchTransactions(
                from: startOfMonth,
                to: endOfMonth
            )

            transactionCount = allTransactions.count

            // Calculate spending and income
            thisMonthSpending = 0
            thisMonthIncome = 0

            for transaction in allTransactions where !transaction.isExcludedFromBudget {
                if transaction.amount < 0 {
                    thisMonthSpending += abs(transaction.amount)
                } else {
                    thisMonthIncome += transaction.amount
                }
            }

            // Get recent transactions (last 5)
            let sortedTransactions = allTransactions.sorted { $0.date > $1.date }
            recentTransactions = Array(sortedTransactions.prefix(5))

            logger.debug("Loaded transaction data: \(allTransactions.count) transactions this month")
        } catch {
            logger.error("Failed to load transaction data: \(error.localizedDescription)")
            throw error
        }
    }

    // MARK: - Helper Methods

    private func calculateBudgetProgress(for budget: Budget) -> BudgetProgress {
        let percentage = budget.totalAllocated > 0
            ? (NSDecimalNumber(decimal: budget.totalSpent).doubleValue /
               NSDecimalNumber(decimal: budget.totalAllocated).doubleValue) * 100
            : 0

        let remaining = budget.totalAllocated - budget.totalSpent

        let daysInPeriod = Calendar.current.dateComponents(
            [.day],
            from: budget.startDate,
            to: budget.endDate
        ).day ?? 30

        let daysElapsed = Calendar.current.dateComponents(
            [.day],
            from: budget.startDate,
            to: Date()
        ).day ?? 0

        let daysRemaining = max(0, daysInPeriod - daysElapsed)

        let expectedSpending = budget.totalAllocated * Decimal(daysElapsed) / Decimal(daysInPeriod)
        let isOnTrack = budget.totalSpent <= expectedSpending

        return BudgetProgress(
            budgetId: budget.id,
            spent: budget.totalSpent,
            allocated: budget.totalAllocated,
            remaining: remaining,
            percentage: percentage,
            daysRemaining: daysRemaining,
            isOnTrack: isOnTrack,
            categoryProgress: []
        )
    }

    // MARK: - Formatting

    func formatCurrency(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSDecimalNumber(decimal: amount)) ?? "$0.00"
    }

    func formatPercentage(_ value: Double) -> String {
        String(format: "%.0f%%", value)
    }

    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    func getStatusMessage() -> String {
        guard let budget = activeBudget else {
            return "No active budget"
        }

        let percentage = budgetPercentage

        if percentage >= 100 {
            return "Budget exceeded"
        } else if percentage >= 90 {
            return "Approaching budget limit"
        } else if percentage >= 75 {
            return "Budget alert: 75% spent"
        } else {
            return "On track"
        }
    }
}

// MARK: - Supporting Types

enum TrendDirection {
    case up
    case down
    case neutral

    var systemImage: String {
        switch self {
        case .up: return "arrow.up.right"
        case .down: return "arrow.down.right"
        case .neutral: return "arrow.right"
        }
    }

    var color: Color {
        switch self {
        case .up: return .green
        case .down: return .red
        case .neutral: return .gray
        }
    }
}

struct BudgetProgress {
    let budgetId: UUID
    let spent: Decimal
    let allocated: Decimal
    let remaining: Decimal
    let percentage: Double
    let daysRemaining: Int
    let isOnTrack: Bool
    let categoryProgress: [CategoryProgress]
}

struct CategoryProgress {
    let categoryId: UUID
    let categoryName: String
    let spent: Decimal
    let allocated: Decimal
    let percentage: Double
}
