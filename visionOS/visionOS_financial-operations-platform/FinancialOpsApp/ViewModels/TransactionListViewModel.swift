//
//  TransactionListViewModel.swift
//  Financial Operations Platform
//
//  Transaction list and detail view model
//

import Foundation
import SwiftData

@Observable
final class TransactionListViewModel {
    // MARK: - Published State

    var transactions: [FinancialTransaction] = []
    var filteredTransactions: [FinancialTransaction] = []
    var selectedTransaction: FinancialTransaction?

    var isLoading: Bool = false
    var errorMessage: String?

    // Filters
    var searchText: String = "" {
        didSet { applyFilters() }
    }
    var selectedStatus: TransactionStatus? {
        didSet { applyFilters() }
    }
    var selectedType: TransactionType? {
        didSet { applyFilters() }
    }
    var dateRange: DateInterval = .last30Days {
        didSet { Task { await loadTransactions() } }
    }
    var accountCode: String?

    // Sort
    var sortBy: SortOption = .date {
        didSet { applySort() }
    }

    // MARK: - Dependencies

    private let financialService: FinancialDataService

    // MARK: - Initialization

    init(financialService: FinancialDataService, accountCode: String? = nil) {
        self.financialService = financialService
        self.accountCode = accountCode
    }

    // MARK: - Public Methods

    @MainActor
    func loadTransactions() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let accounts = accountCode.map { [$0] }
            transactions = try await financialService.fetchTransactions(
                dateRange: dateRange,
                accounts: accounts,
                status: selectedStatus
            )

            applyFilters()
        } catch {
            errorMessage = error.localizedDescription
            print("Transaction load error: \(error)")
        }
    }

    @MainActor
    func createTransaction(_ transaction: FinancialTransaction) async throws {
        _ = try await financialService.createTransaction(transaction)
        await loadTransactions()
    }

    @MainActor
    func approveTransaction(_ transaction: FinancialTransaction) async throws {
        try await financialService.approveTransaction(transaction, approvedBy: "currentUser")
        await loadTransactions()
    }

    @MainActor
    func rejectTransaction(_ transaction: FinancialTransaction) async throws {
        try await financialService.rejectTransaction(transaction)
        await loadTransactions()
    }

    @MainActor
    func selectTransaction(_ transaction: FinancialTransaction) {
        selectedTransaction = transaction
    }

    @MainActor
    func clearSelection() {
        selectedTransaction = nil
    }

    @MainActor
    func refresh() async {
        await loadTransactions()
    }

    // MARK: - Filter & Sort

    private func applyFilters() {
        filteredTransactions = transactions

        // Apply search filter
        if !searchText.isEmpty {
            filteredTransactions = filteredTransactions.filter {
                $0.description.localizedCaseInsensitiveContains(searchText) ||
                $0.accountCode.localizedCaseInsensitiveContains(searchText)
            }
        }

        // Apply status filter
        if let status = selectedStatus {
            filteredTransactions = filteredTransactions.filter { $0.status == status }
        }

        // Apply type filter
        if let type = selectedType {
            filteredTransactions = filteredTransactions.filter { $0.transactionType == type }
        }

        applySort()
    }

    private func applySort() {
        switch sortBy {
        case .date:
            filteredTransactions.sort { $0.transactionDate > $1.transactionDate }
        case .amount:
            filteredTransactions.sort { $0.amount > $1.amount }
        case .status:
            filteredTransactions.sort { $0.status.rawValue < $1.status.rawValue }
        case .account:
            filteredTransactions.sort { $0.accountCode < $1.accountCode }
        }
    }

    // MARK: - Summary Statistics

    var totalAmount: Decimal {
        filteredTransactions.reduce(0) { $0 + $1.amount }
    }

    var pendingCount: Int {
        filteredTransactions.filter { $0.status == .pending }.count
    }

    var approvedCount: Int {
        filteredTransactions.filter { $0.status == .approved }.count
    }

    var averageAmount: Decimal {
        guard !filteredTransactions.isEmpty else { return 0 }
        return totalAmount / Decimal(filteredTransactions.count)
    }
}

// MARK: - Sort Option

enum SortOption: String, CaseIterable {
    case date = "Date"
    case amount = "Amount"
    case status = "Status"
    case account = "Account"
}
