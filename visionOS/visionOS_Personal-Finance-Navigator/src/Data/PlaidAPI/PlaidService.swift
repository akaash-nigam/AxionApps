// PlaidService.swift
// Personal Finance Navigator
// Service for syncing Plaid data to local storage

import Foundation
import OSLog

private let logger = Logger(subsystem: "com.pfn", category: "plaid-service")

/// Manages syncing data from Plaid to local repositories
@MainActor
class PlaidService {
    // MARK: - Dependencies

    private let apiClient: PlaidAPIClient
    private let accountRepository: AccountRepository
    private let transactionRepository: TransactionRepository
    private let keychainManager: KeychainManager

    // MARK: - State

    private var syncInProgress = false
    private var lastSyncDate: Date?

    // MARK: - Init

    init(
        apiClient: PlaidAPIClient,
        accountRepository: AccountRepository,
        transactionRepository: TransactionRepository,
        keychainManager: KeychainManager
    ) {
        self.apiClient = apiClient
        self.accountRepository = accountRepository
        self.transactionRepository = transactionRepository
        self.keychainManager = keychainManager
    }

    // MARK: - Link Token

    /// Creates a link token for Plaid Link UI
    func createLinkToken(userId: String) async throws -> String {
        logger.info("Creating Plaid link token for user: \(userId)")

        let response = try await apiClient.createLinkToken(userId: userId)
        return response.linkToken
    }

    // MARK: - Connect Account

    /// Exchanges public token and imports accounts
    func connectAccount(publicToken: String) async throws -> [Account] {
        logger.info("Connecting account with public token")

        // Exchange public token for access token
        let exchangeResponse = try await apiClient.exchangePublicToken(publicToken)
        let accessToken = exchangeResponse.accessToken
        let itemId = exchangeResponse.itemId

        // Store access token securely
        try await keychainManager.save(
            accessToken.data(using: .utf8)!,
            for: "plaid_access_token_\(itemId)"
        )

        // Fetch and import accounts
        let accounts = try await fetchAndImportAccounts(accessToken: accessToken, itemId: itemId)

        logger.info("Successfully connected \(accounts.count) accounts")
        return accounts
    }

    // MARK: - Sync

    /// Syncs all data for connected Plaid items
    func syncAll() async throws {
        guard !syncInProgress else {
            logger.warning("Sync already in progress")
            return
        }

        syncInProgress = true
        defer { syncInProgress = false }

        logger.info("Starting full Plaid sync")

        // Get all accounts with Plaid connection
        let allAccounts = try await accountRepository.fetchAll()
        let plaidAccounts = allAccounts.filter { $0.plaidItemId != nil }

        guard !plaidAccounts.isEmpty else {
            logger.info("No Plaid accounts to sync")
            return
        }

        // Group by item ID
        let accountsByItem = Dictionary(grouping: plaidAccounts) { $0.plaidItemId! }

        // Sync each item
        for (itemId, accounts) in accountsByItem {
            do {
                try await syncItem(itemId: itemId, accounts: accounts)
            } catch {
                logger.error("Failed to sync item \(itemId): \(error.localizedDescription)")
                // Continue with other items
            }
        }

        lastSyncDate = Date()
        logger.info("Completed full Plaid sync")
    }

    /// Syncs a specific Plaid item
    private func syncItem(itemId: String, accounts: [Account]) async throws {
        logger.debug("Syncing item: \(itemId)")

        // Get access token from keychain
        guard let tokenData = try await keychainManager.load(for: "plaid_access_token_\(itemId)"),
              let accessToken = String(data: tokenData, encoding: .utf8) else {
            logger.error("Access token not found for item: \(itemId)")
            throw PlaidError.invalidToken
        }

        // Sync balances
        try await syncBalances(accessToken: accessToken, accounts: accounts)

        // Sync transactions
        try await syncTransactions(accessToken: accessToken, itemId: itemId)
    }

    // MARK: - Balance Sync

    private func syncBalances(accessToken: String, accounts: [Account]) async throws {
        logger.debug("Syncing balances")

        let response = try await apiClient.getBalance(accessToken: accessToken)

        for plaidAccount in response.accounts {
            // Find matching local account
            guard let localAccount = accounts.first(where: { $0.plaidAccountId == plaidAccount.accountId }) else {
                continue
            }

            // Update balance
            let newBalance = Decimal(plaidAccount.balances.current)
            if localAccount.currentBalance != newBalance {
                var updatedAccount = localAccount
                updatedAccount.currentBalance = newBalance

                if let available = plaidAccount.balances.available {
                    updatedAccount.availableBalance = Decimal(available)
                }

                try await accountRepository.save(updatedAccount)
                logger.debug("Updated balance for account: \(localAccount.name)")
            }
        }
    }

    // MARK: - Transaction Sync

    private func syncTransactions(accessToken: String, itemId: String) async throws {
        logger.debug("Syncing transactions")

        // Get cursor from UserDefaults (or start fresh)
        let cursorKey = "plaid_sync_cursor_\(itemId)"
        let cursor = UserDefaults.standard.string(forKey: cursorKey)

        var hasMore = true
        var nextCursor = cursor

        while hasMore {
            let response = try await apiClient.syncTransactions(
                accessToken: accessToken,
                cursor: nextCursor
            )

            // Process added transactions
            for plaidTx in response.added {
                try await importTransaction(plaidTx, itemId: itemId)
            }

            // Process modified transactions
            for plaidTx in response.modified {
                try await updateTransaction(plaidTx)
            }

            // Process removed transactions
            for removed in response.removed {
                try await removeTransaction(plaidTransactionId: removed.transactionId)
            }

            // Update cursor
            nextCursor = response.nextCursor
            hasMore = response.hasMore

            logger.debug("Synced: \(response.added.count) added, \(response.modified.count) modified, \(response.removed.count) removed")
        }

        // Save cursor
        UserDefaults.standard.set(nextCursor, forKey: cursorKey)
    }

    // MARK: - Transaction Import

    private func importTransaction(_ plaidTx: PlaidTransaction, itemId: String) async throws {
        // Check if transaction already exists
        let existingTransactions = try await transactionRepository.fetchAll()
        if existingTransactions.contains(where: { $0.plaidTransactionId == plaidTx.transactionId }) {
            return // Skip duplicates
        }

        // Find account
        guard let account = try await findAccount(plaidAccountId: plaidTx.accountId) else {
            logger.warning("Account not found for transaction: \(plaidTx.transactionId)")
            return
        }

        // Parse date
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withFullDate]
        guard let date = dateFormatter.date(from: plaidTx.date) else {
            logger.warning("Invalid date for transaction: \(plaidTx.transactionId)")
            return
        }

        let authorizedDate = plaidTx.authorizedDate.flatMap { dateFormatter.date(from: $0) }

        // Create transaction
        let transaction = Transaction(
            id: UUID(),
            plaidTransactionId: plaidTx.transactionId,
            accountId: account.id,
            amount: -Decimal(plaidTx.amount), // Plaid uses positive for outflows, we use negative
            date: date,
            authorizedDate: authorizedDate,
            merchantName: plaidTx.merchantName,
            name: plaidTx.name,
            pending: plaidTx.pending,
            categoryId: nil, // Will be categorized by user or auto-categorization
            primaryCategory: plaidTx.category?.first ?? "Uncategorized",
            detailedCategory: plaidTx.category?.last,
            isRecurring: false,
            confidence: nil,
            latitude: plaidTx.location?.lat,
            longitude: plaidTx.location?.lon,
            address: plaidTx.location?.address,
            paymentChannel: PaymentChannel(rawValue: plaidTx.paymentChannel) ?? .other,
            paymentMethod: nil,
            isUserModified: false,
            isHidden: false,
            isExcludedFromBudget: false,
            isSplit: false,
            parentTransactionId: nil,
            notes: nil,
            tags: [],
            createdAt: Date(),
            updatedAt: Date()
        )

        try await transactionRepository.save(transaction)
        logger.debug("Imported transaction: \(transaction.name)")
    }

    private func updateTransaction(_ plaidTx: PlaidTransaction) async throws {
        // Find existing transaction
        let transactions = try await transactionRepository.fetchAll()
        guard var existingTransaction = transactions.first(where: { $0.plaidTransactionId == plaidTx.transactionId }) else {
            // Transaction doesn't exist locally, import it
            try await importTransaction(plaidTx, itemId: "")
            return
        }

        // Update fields that may have changed
        existingTransaction.amount = -Decimal(plaidTx.amount)
        existingTransaction.pending = plaidTx.pending
        existingTransaction.name = plaidTx.name
        existingTransaction.merchantName = plaidTx.merchantName
        existingTransaction.updatedAt = Date()

        try await transactionRepository.save(existingTransaction)
        logger.debug("Updated transaction: \(existingTransaction.name)")
    }

    private func removeTransaction(plaidTransactionId: String) async throws {
        let transactions = try await transactionRepository.fetchAll()
        guard let transaction = transactions.first(where: { $0.plaidTransactionId == plaidTransactionId }) else {
            return
        }

        try await transactionRepository.delete(transaction)
        logger.debug("Removed transaction: \(transaction.name)")
    }

    // MARK: - Account Import

    private func fetchAndImportAccounts(accessToken: String, itemId: String) async throws -> [Account] {
        let response = try await apiClient.getAccounts(accessToken: accessToken)

        var importedAccounts: [Account] = []

        for plaidAccount in response.accounts {
            let account = Account(
                id: UUID(),
                plaidItemId: itemId,
                plaidAccountId: plaidAccount.accountId,
                name: plaidAccount.name,
                type: mapAccountType(plaidAccount.type, subtype: plaidAccount.subtype),
                currentBalance: Decimal(plaidAccount.balances.current),
                availableBalance: plaidAccount.balances.available.map { Decimal($0) },
                creditLimit: plaidAccount.balances.limit.map { Decimal($0) },
                currency: plaidAccount.balances.isoCurrencyCode ?? "USD",
                institutionId: response.item.institutionId,
                accountNumber: plaidAccount.mask,
                isActive: true,
                isHidden: false,
                isSynced: true,
                lastSyncedAt: Date(),
                color: generateAccountColor(),
                icon: "creditcard.fill",
                createdAt: Date(),
                updatedAt: Date()
            )

            try await accountRepository.save(account)
            importedAccounts.append(account)

            logger.debug("Imported account: \(account.name)")
        }

        return importedAccounts
    }

    // MARK: - Disconnect

    /// Disconnects a Plaid item and removes access token
    func disconnectItem(itemId: String) async throws {
        logger.info("Disconnecting Plaid item: \(itemId)")

        // Get access token
        guard let tokenData = try await keychainManager.load(for: "plaid_access_token_\(itemId)"),
              let accessToken = String(data: tokenData, encoding: .utf8) else {
            logger.error("Access token not found for item: \(itemId)")
            throw PlaidError.invalidToken
        }

        // Remove from Plaid
        _ = try await apiClient.removeItem(accessToken: accessToken)

        // Delete access token from keychain
        try await keychainManager.delete(for: "plaid_access_token_\(itemId)")

        // Delete sync cursor
        UserDefaults.standard.removeObject(forKey: "plaid_sync_cursor_\(itemId)")

        // Mark accounts as not synced
        let accounts = try await accountRepository.fetchAll()
        let itemAccounts = accounts.filter { $0.plaidItemId == itemId }

        for var account in itemAccounts {
            account.plaidItemId = nil
            account.plaidAccountId = nil
            account.isSynced = false
            try await accountRepository.save(account)
        }

        logger.info("Successfully disconnected item: \(itemId)")
    }

    // MARK: - Helpers

    private func findAccount(plaidAccountId: String) async throws -> Account? {
        let accounts = try await accountRepository.fetchAll()
        return accounts.first { $0.plaidAccountId == plaidAccountId }
    }

    private func mapAccountType(_ type: String, subtype: String?) -> Account.AccountType {
        switch type.lowercased() {
        case "depository":
            if subtype?.lowercased() == "checking" {
                return .checking
            } else if subtype?.lowercased() == "savings" {
                return .savings
            }
            return .checking
        case "credit":
            return .creditCard
        case "loan":
            return .loan
        case "investment":
            return .investment
        default:
            return .other
        }
    }

    private func generateAccountColor() -> String {
        let colors = ["blue", "green", "orange", "purple", "red", "pink", "yellow"]
        return colors.randomElement() ?? "blue"
    }
}
