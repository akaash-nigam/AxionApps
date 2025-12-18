//
//  FinancialDataService.swift
//  Financial Operations Platform
//
//  Core financial data operations service
//

import Foundation
import SwiftData

@Observable
final class FinancialDataService {
    // MARK: - Properties

    private let modelContext: ModelContext
    private let apiClient: APIClient

    // Published state
    var isLoading: Bool = false
    var errorMessage: String?
    var lastSyncTime: Date?

    // MARK: - Initialization

    init(modelContext: ModelContext, apiClient: APIClient = APIClient.shared) {
        self.modelContext = modelContext
        self.apiClient = apiClient
    }

    // MARK: - Transaction Operations

    func fetchTransactions(
        dateRange: DateInterval,
        accounts: [String]? = nil,
        status: TransactionStatus? = nil
    ) async throws -> [FinancialTransaction] {
        isLoading = true
        defer { isLoading = false }

        do {
            // Build fetch descriptor
            var predicate: Predicate<FinancialTransaction>?

            if let accounts = accounts, !accounts.isEmpty {
                predicate = #Predicate<FinancialTransaction> { transaction in
                    accounts.contains(transaction.accountCode) &&
                    transaction.transactionDate >= dateRange.start &&
                    transaction.transactionDate <= dateRange.end
                }
            } else if let status = status {
                predicate = #Predicate<FinancialTransaction> { transaction in
                    transaction.status == status &&
                    transaction.transactionDate >= dateRange.start &&
                    transaction.transactionDate <= dateRange.end
                }
            } else {
                predicate = #Predicate<FinancialTransaction> { transaction in
                    transaction.transactionDate >= dateRange.start &&
                    transaction.transactionDate <= dateRange.end
                }
            }

            let descriptor = FetchDescriptor<FinancialTransaction>(
                predicate: predicate,
                sortBy: [SortDescriptor(\.transactionDate, order: .reverse)]
            )

            let transactions = try modelContext.fetch(descriptor)

            // If no local data, fetch from API
            if transactions.isEmpty {
                return try await fetchTransactionsFromAPI(dateRange: dateRange, accounts: accounts)
            }

            return transactions
        } catch {
            errorMessage = "Failed to fetch transactions: \(error.localizedDescription)"
            throw FinancialError.fetchFailed(error)
        }
    }

    func createTransaction(_ transaction: FinancialTransaction) async throws -> FinancialTransaction {
        isLoading = true
        defer { isLoading = false }

        do {
            // Validate transaction
            try validateTransaction(transaction)

            // Insert into local database
            modelContext.insert(transaction)
            try modelContext.save()

            // Sync to remote
            try await syncTransactionToAPI(transaction)

            return transaction
        } catch {
            errorMessage = "Failed to create transaction: \(error.localizedDescription)"
            throw FinancialError.createFailed(error)
        }
    }

    func updateTransaction(_ transaction: FinancialTransaction) async throws {
        isLoading = true
        defer { isLoading = false }

        do {
            // Update local
            transaction.updatedAt = Date()
            try modelContext.save()

            // Sync to remote
            try await syncTransactionToAPI(transaction)
        } catch {
            errorMessage = "Failed to update transaction: \(error.localizedDescription)"
            throw FinancialError.updateFailed(error)
        }
    }

    func approveTransaction(_ transaction: FinancialTransaction, approvedBy: String) async throws {
        transaction.status = .approved
        transaction.approvedBy = approvedBy
        transaction.approvedAt = Date()

        try await updateTransaction(transaction)
    }

    func rejectTransaction(_ transaction: FinancialTransaction) async throws {
        transaction.status = .rejected
        try await updateTransaction(transaction)
    }

    // MARK: - Account Operations

    func fetchAccounts(includeInactive: Bool = false) async throws -> [Account] {
        var predicate: Predicate<Account>?

        if !includeInactive {
            predicate = #Predicate<Account> { account in
                account.isActive
            }
        }

        let descriptor = FetchDescriptor<Account>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.accountCode)]
        )

        return try modelContext.fetch(descriptor)
    }

    func fetchAccount(code: String) async throws -> Account? {
        let predicate = #Predicate<Account> { account in
            account.accountCode == code
        }

        let descriptor = FetchDescriptor<Account>(predicate: predicate)
        return try modelContext.fetch(descriptor).first
    }

    func calculateAccountBalance(_ account: Account, asOf date: Date) async throws -> Decimal {
        let predicate = #Predicate<FinancialTransaction> { transaction in
            transaction.accountCode == account.accountCode &&
            transaction.postingDate <= date &&
            transaction.status == .posted
        }

        let descriptor = FetchDescriptor<FinancialTransaction>(predicate: predicate)
        let transactions = try modelContext.fetch(descriptor)

        return transactions.reduce(0) { total, transaction in
            switch transaction.transactionType {
            case .asset, .expense:
                return total + transaction.amount
            case .liability, .equity, .revenue:
                return total - transaction.amount
            }
        }
    }

    // MARK: - KPI Operations

    func fetchKPIs(category: KPICategory? = nil) async throws -> [KPI] {
        var predicate: Predicate<KPI>?

        if let category = category {
            predicate = #Predicate<KPI> { kpi in
                kpi.category == category
            }
        }

        let descriptor = FetchDescriptor<KPI>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.category), SortDescriptor(\.name)]
        )

        let kpis = try modelContext.fetch(descriptor)

        // If no local data, generate sample KPIs for demo
        if kpis.isEmpty {
            return generateSampleKPIs()
        }

        return kpis
    }

    func updateKPI(_ kpi: KPI, newValue: Decimal) async throws {
        kpi.previousValue = kpi.currentValue
        kpi.currentValue = newValue
        kpi.lastUpdated = Date()

        // Update trend
        if newValue > kpi.previousValue {
            kpi.trend = .up
        } else if newValue < kpi.previousValue {
            kpi.trend = .down
        } else {
            kpi.trend = .stable
        }

        try modelContext.save()
    }

    // MARK: - Data Sync

    func syncAllData() async throws {
        isLoading = true
        defer {
            isLoading = false
            lastSyncTime = Date()
        }

        async let transactionsSync = syncTransactionsFromAPI()
        async let accountsSync = syncAccountsFromAPI()
        async let kpisSync = syncKPIsFromAPI()

        _ = try await (transactionsSync, accountsSync, kpisSync)
    }

    // MARK: - Private Methods

    private func validateTransaction(_ transaction: FinancialTransaction) throws {
        guard !transaction.accountCode.isEmpty else {
            throw FinancialError.validationFailed("Account code is required")
        }

        guard transaction.amount != 0 else {
            throw FinancialError.validationFailed("Amount must be non-zero")
        }

        guard !transaction.description.isEmpty else {
            throw FinancialError.validationFailed("Description is required")
        }
    }

    private func fetchTransactionsFromAPI(
        dateRange: DateInterval,
        accounts: [String]?
    ) async throws -> [FinancialTransaction] {
        let endpoint = APIEndpoint.transactions(dateRange: dateRange, accounts: accounts)
        let response: TransactionsResponse = try await apiClient.request(endpoint)

        // Save to local database
        for transaction in response.transactions {
            modelContext.insert(transaction)
        }
        try modelContext.save()

        return response.transactions
    }

    private func syncTransactionToAPI(_ transaction: FinancialTransaction) async throws {
        let endpoint = APIEndpoint.postTransaction(transaction)
        let _: TransactionResponse = try await apiClient.request(endpoint, method: .post)
    }

    private func syncTransactionsFromAPI() async throws {
        let dateRange = DateInterval.last30Days
        _ = try await fetchTransactionsFromAPI(dateRange: dateRange, accounts: nil)
    }

    private func syncAccountsFromAPI() async throws {
        // Stub - would fetch from API
    }

    private func syncKPIsFromAPI() async throws {
        // Stub - would fetch from API
    }

    private func generateSampleKPIs() -> [KPI] {
        [
            KPI(
                name: "Cash Position",
                category: .liquidity,
                currentValue: 847_000_000,
                targetValue: 800_000_000,
                previousValue: 805_000_000,
                unit: "USD",
                trend: .up,
                displayPosition: SIMD3<Float>(-1, 0, 0)
            ),
            KPI(
                name: "Working Capital",
                category: .liquidity,
                currentValue: 432_000_000,
                targetValue: 450_000_000,
                previousValue: 441_000_000,
                unit: "USD",
                trend: .down,
                displayPosition: SIMD3<Float>(0, 0, 0)
            ),
            KPI(
                name: "Forecast Accuracy",
                category: .efficiency,
                currentValue: 92,
                targetValue: 90,
                previousValue: 89,
                unit: "%",
                trend: .up,
                displayPosition: SIMD3<Float>(1, 0, 0)
            )
        ]
    }
}

// MARK: - API Response Models

struct TransactionsResponse: Codable {
    let transactions: [FinancialTransaction]
    let total: Int
    let page: Int
}

struct TransactionResponse: Codable {
    let transaction: FinancialTransaction
    let message: String
}

// MARK: - Financial Error

enum FinancialError: LocalizedError {
    case fetchFailed(Error)
    case createFailed(Error)
    case updateFailed(Error)
    case deleteFailed(Error)
    case validationFailed(String)
    case networkError(Error)
    case authenticationRequired

    var errorDescription: String? {
        switch self {
        case .fetchFailed(let error):
            return "Failed to fetch data: \(error.localizedDescription)"
        case .createFailed(let error):
            return "Failed to create: \(error.localizedDescription)"
        case .updateFailed(let error):
            return "Failed to update: \(error.localizedDescription)"
        case .deleteFailed(let error):
            return "Failed to delete: \(error.localizedDescription)"
        case .validationFailed(let message):
            return "Validation error: \(message)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .authenticationRequired:
            return "Authentication required"
        }
    }
}
