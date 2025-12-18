// AccountViewModel.swift
// Personal Finance Navigator
// ViewModel for account management

import Foundation
import SwiftUI
import OSLog

private let logger = Logger(subsystem: "com.pfn", category: "viewmodel")

/// ViewModel for managing accounts
@MainActor
@Observable
class AccountViewModel {
    // MARK: - Published State

    private(set) var accounts: [Account] = []
    private(set) var activeAccounts: [Account] = []
    private(set) var isLoading = false
    private(set) var errorMessage: String?

    // Computed properties
    var totalNetWorth: Decimal {
        accounts.reduce(Decimal.zero) { total, account in
            if account.type == .creditCard {
                return total - account.currentBalance
            } else {
                return total + account.currentBalance
            }
        }
    }

    var accountsByType: [Account.AccountType: [Account]] {
        Dictionary(grouping: activeAccounts) { $0.type }
    }

    // MARK: - Dependencies

    private let repository: AccountRepository

    // MARK: - Init

    init(repository: AccountRepository) {
        self.repository = repository
    }

    // MARK: - Fetch Methods

    func loadAccounts() async {
        isLoading = true
        errorMessage = nil

        do {
            accounts = try await repository.fetchAll()
            activeAccounts = accounts.filter { $0.isActive && !$0.isHidden }
            logger.info("Loaded \(self.accounts.count) accounts")
        } catch {
            errorMessage = "Failed to load accounts: \(error.localizedDescription)"
            logger.error("Failed to load accounts: \(error.localizedDescription)")
        }

        isLoading = false
    }

    func refreshAccounts() async {
        await loadAccounts()
    }

    func getAccount(by id: UUID) async -> Account? {
        do {
            return try await repository.fetchById(id)
        } catch {
            logger.error("Failed to fetch account \(id): \(error.localizedDescription)")
            return nil
        }
    }

    // MARK: - CRUD Operations

    func addAccount(_ account: Account) async -> Bool {
        isLoading = true
        errorMessage = nil

        do {
            try await repository.save(account)
            await loadAccounts()
            logger.info("Added account: \(account.name)")
            return true
        } catch {
            errorMessage = "Failed to add account: \(error.localizedDescription)"
            logger.error("Failed to add account: \(error.localizedDescription)")
            return false
        }
    }

    func updateAccount(_ account: Account) async -> Bool {
        isLoading = true
        errorMessage = nil

        do {
            try await repository.save(account)
            await loadAccounts()
            logger.info("Updated account: \(account.name)")
            return true
        } catch {
            errorMessage = "Failed to update account: \(error.localizedDescription)"
            logger.error("Failed to update account: \(error.localizedDescription)")
            return false
        }
    }

    func deleteAccount(_ account: Account) async -> Bool {
        isLoading = true
        errorMessage = nil

        do {
            try await repository.delete(account)
            await loadAccounts()
            logger.info("Deleted account: \(account.name)")
            return true
        } catch {
            errorMessage = "Failed to delete account: \(error.localizedDescription)"
            logger.error("Failed to delete account: \(error.localizedDescription)")
            return false
        }
    }

    // MARK: - Balance Updates

    func updateBalance(for accountId: UUID, current: Decimal, available: Decimal?) async -> Bool {
        do {
            try await repository.updateBalance(accountId, current: current, available: available)
            await loadAccounts()
            logger.info("Updated balance for account: \(accountId)")
            return true
        } catch {
            errorMessage = "Failed to update balance: \(error.localizedDescription)"
            logger.error("Failed to update balance: \(error.localizedDescription)")
            return false
        }
    }

    // MARK: - Helper Methods

    func clearError() {
        errorMessage = nil
    }

    func getFormattedNetWorth(currencyCode: String = "USD") -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode
        return formatter.string(from: totalNetWorth as NSDecimalNumber) ?? "$0.00"
    }

    func getFormattedBalance(_ amount: Decimal, currencyCode: String = "USD") -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode
        return formatter.string(from: amount as NSDecimalNumber) ?? "$0.00"
    }
}
