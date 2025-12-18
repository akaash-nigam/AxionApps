// TransactionViewModel.swift
// Personal Finance Navigator
// ViewModel for transaction management

import Foundation
import SwiftUI
import OSLog

private let logger = Logger(subsystem: "com.pfn", category: "viewmodel")

/// ViewModel for managing transactions
@MainActor
@Observable
class TransactionViewModel {
    // MARK: - Published State

    private(set) var transactions: [Transaction] = []
    private(set) var isLoading = false
    private(set) var errorMessage: String?

    // Filter state
    var selectedAccountId: UUID?
    var selectedCategoryId: UUID?
    var searchQuery: String = ""
    var showPendingOnly: Bool = false

    // Computed properties
    var filteredTransactions: [Transaction] {
        var filtered = transactions

        // Filter by account
        if let accountId = selectedAccountId {
            filtered = filtered.filter { $0.accountId == accountId }
        }

        // Filter by category
        if let categoryId = selectedCategoryId {
            filtered = filtered.filter { $0.categoryId == categoryId }
        }

        // Filter by search query
        if !searchQuery.isEmpty {
            filtered = filtered.filter { transaction in
                transaction.name.localizedCaseInsensitiveContains(searchQuery) ||
                transaction.merchantName?.localizedCaseInsensitiveContains(searchQuery) == true
            }
        }

        // Filter pending
        if showPendingOnly {
            filtered = filtered.filter { $0.isPending }
        }

        return filtered
    }

    var transactionsByDate: [(Date, [Transaction])] {
        let grouped = Dictionary(grouping: filteredTransactions) { transaction in
            Calendar.current.startOfDay(for: transaction.date)
        }

        return grouped.sorted { $0.key > $1.key }.map { ($0.key, $0.value.sorted { $0.date > $1.date }) }
    }

    var totalIncome: Decimal {
        filteredTransactions.filter { $0.amount > 0 }.reduce(0) { $0 + $1.amount }
    }

    var totalExpenses: Decimal {
        abs(filteredTransactions.filter { $0.amount < 0 }.reduce(0) { $0 + $1.amount })
    }

    var netAmount: Decimal {
        totalIncome - totalExpenses
    }

    // MARK: - Dependencies

    private let transactionRepository: TransactionRepository
    private let accountRepository: AccountRepository
    private let categoryRepository: CategoryRepository

    // MARK: - Init

    init(
        transactionRepository: TransactionRepository,
        accountRepository: AccountRepository,
        categoryRepository: CategoryRepository
    ) {
        self.transactionRepository = transactionRepository
        self.accountRepository = accountRepository
        self.categoryRepository = categoryRepository
    }

    // MARK: - Fetch Methods

    func loadTransactions() async {
        isLoading = true
        errorMessage = nil

        do {
            transactions = try await transactionRepository.fetchAll()
            logger.info("Loaded \(self.transactions.count) transactions")
        } catch {
            errorMessage = "Failed to load transactions: \(error.localizedDescription)"
            logger.error("Failed to load transactions: \(error.localizedDescription)")
        }

        isLoading = false
    }

    func refreshTransactions() async {
        await loadTransactions()
    }

    func loadTransactions(for accountId: UUID) async {
        isLoading = true
        errorMessage = nil

        do {
            transactions = try await transactionRepository.fetchByAccount(accountId)
            selectedAccountId = accountId
            logger.info("Loaded \(self.transactions.count) transactions for account \(accountId)")
        } catch {
            errorMessage = "Failed to load transactions: \(error.localizedDescription)"
            logger.error("Failed to load transactions: \(error.localizedDescription)")
        }

        isLoading = false
    }

    func loadTransactions(from startDate: Date, to endDate: Date) async {
        isLoading = true
        errorMessage = nil

        do {
            transactions = try await transactionRepository.fetchByDateRange(from: startDate, to: endDate)
            logger.info("Loaded \(self.transactions.count) transactions for date range")
        } catch {
            errorMessage = "Failed to load transactions: \(error.localizedDescription)"
            logger.error("Failed to load transactions: \(error.localizedDescription)")
        }

        isLoading = false
    }

    func searchTransactions(_ query: String) async {
        guard !query.isEmpty else {
            await loadTransactions()
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            transactions = try await transactionRepository.search(query: query)
            logger.info("Found \(self.transactions.count) transactions matching '\(query)'")
        } catch {
            errorMessage = "Failed to search transactions: \(error.localizedDescription)"
            logger.error("Failed to search transactions: \(error.localizedDescription)")
        }

        isLoading = false
    }

    // MARK: - CRUD Operations

    func addTransaction(_ transaction: Transaction) async -> Bool {
        isLoading = true
        errorMessage = nil

        do {
            try await transactionRepository.save(transaction)
            await loadTransactions()

            // Update account balance
            await updateAccountBalance(for: transaction.accountId, amount: transaction.amount)

            logger.info("Added transaction: \(transaction.name)")
            return true
        } catch {
            errorMessage = "Failed to add transaction: \(error.localizedDescription)"
            logger.error("Failed to add transaction: \(error.localizedDescription)")
            return false
        }
    }

    func updateTransaction(_ transaction: Transaction) async -> Bool {
        isLoading = true
        errorMessage = nil

        do {
            // Get the old transaction to calculate balance difference
            if let oldTransaction = try await transactionRepository.fetchById(transaction.id) {
                let difference = transaction.amount - oldTransaction.amount

                try await transactionRepository.save(transaction)
                await loadTransactions()

                // Update account balance with difference
                if difference != 0 {
                    await updateAccountBalance(for: transaction.accountId, amount: difference)
                }

                logger.info("Updated transaction: \(transaction.name)")
                return true
            } else {
                // If old transaction not found, treat as new
                return await addTransaction(transaction)
            }
        } catch {
            errorMessage = "Failed to update transaction: \(error.localizedDescription)"
            logger.error("Failed to update transaction: \(error.localizedDescription)")
            return false
        }
    }

    func deleteTransaction(_ transaction: Transaction) async -> Bool {
        isLoading = true
        errorMessage = nil

        do {
            try await transactionRepository.delete(transaction)
            await loadTransactions()

            // Reverse the transaction's effect on account balance
            await updateAccountBalance(for: transaction.accountId, amount: -transaction.amount)

            logger.info("Deleted transaction: \(transaction.name)")
            return true
        } catch {
            errorMessage = "Failed to delete transaction: \(error.localizedDescription)"
            logger.error("Failed to delete transaction: \(error.localizedDescription)")
            return false
        }
    }

    // MARK: - Helper Methods

    private func updateAccountBalance(for accountId: UUID, amount: Decimal) async {
        do {
            if let account = try await accountRepository.fetchById(accountId) {
                let newBalance = account.currentBalance + amount
                try await accountRepository.updateBalance(accountId, current: newBalance, available: nil)
                logger.debug("Updated account balance: \(accountId)")
            }
        } catch {
            logger.error("Failed to update account balance: \(error.localizedDescription)")
        }
    }

    func clearError() {
        errorMessage = nil
    }

    func clearFilters() {
        selectedAccountId = nil
        selectedCategoryId = nil
        searchQuery = ""
        showPendingOnly = false
    }

    func getFormattedAmount(_ amount: Decimal, currencyCode: String = "USD") -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode
        return formatter.string(from: amount as NSDecimalNumber) ?? "$0.00"
    }

    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }

    func formatDateSection(_ date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()

        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else if calendar.isDate(date, equalTo: now, toGranularity: .weekOfYear) {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE"
            return formatter.string(from: date)
        } else if calendar.isDate(date, equalTo: now, toGranularity: .year) {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM d"
            return formatter.string(from: date)
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM d, yyyy"
            return formatter.string(from: date)
        }
    }
}
