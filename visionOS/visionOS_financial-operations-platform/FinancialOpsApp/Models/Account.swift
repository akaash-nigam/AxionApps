//
//  Account.swift
//  Financial Operations Platform
//
//  Financial account model
//

import Foundation
import SwiftData

@Model
final class Account: Identifiable {
    // MARK: - Properties

    @Attribute(.unique) var id: UUID
    var accountCode: String
    var accountName: String
    var accountType: AccountType
    var currency: Currency
    var balance: Decimal
    var isActive: Bool
    var costCenter: String?
    var department: String?
    var region: String?
    var createdAt: Date
    var updatedAt: Date

    // MARK: - Relationships

    var transactions: [FinancialTransaction]
    var budgets: [Budget]

    // MARK: - Initialization

    init(
        id: UUID = UUID(),
        accountCode: String,
        accountName: String,
        accountType: AccountType,
        currency: Currency,
        balance: Decimal = 0,
        isActive: Bool = true,
        costCenter: String? = nil,
        department: String? = nil,
        region: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        transactions: [FinancialTransaction] = [],
        budgets: [Budget] = []
    ) {
        self.id = id
        self.accountCode = accountCode
        self.accountName = accountName
        self.accountType = accountType
        self.currency = currency
        self.balance = balance
        self.isActive = isActive
        self.costCenter = costCenter
        self.department = department
        self.region = region
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.transactions = transactions
        self.budgets = budgets
    }

    // MARK: - Computed Properties

    var formattedBalance: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency.code
        return formatter.string(from: balance as NSDecimalNumber) ?? "\(balance)"
    }

    var displayName: String {
        "\(accountCode) - \(accountName)"
    }
}

// MARK: - Account Type

enum AccountType: String, Codable, CaseIterable {
    case asset
    case liability
    case equity
    case revenue
    case expense

    var displayName: String {
        rawValue.capitalized
    }

    var normalBalance: BalanceType {
        switch self {
        case .asset, .expense:
            return .debit
        case .liability, .equity, .revenue:
            return .credit
        }
    }
}

enum BalanceType {
    case debit
    case credit
}

// MARK: - Budget

@Model
final class Budget: Identifiable {
    @Attribute(.unique) var id: UUID
    var account: Account?
    var period: ClosePeriod
    var budgetAmount: Decimal
    var actualAmount: Decimal
    var variance: Decimal
    var variancePercent: Double
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        account: Account? = nil,
        period: ClosePeriod,
        budgetAmount: Decimal,
        actualAmount: Decimal = 0,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.account = account
        self.period = period
        self.budgetAmount = budgetAmount
        self.actualAmount = actualAmount
        self.variance = actualAmount - budgetAmount
        self.variancePercent = budgetAmount != 0 ?
            Double(truncating: ((actualAmount - budgetAmount) / budgetAmount * 100) as NSDecimalNumber) : 0
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    var isOverBudget: Bool {
        actualAmount > budgetAmount
    }

    var formattedVariance: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.minimumFractionDigits = 1
        formatter.maximumFractionDigits = 1
        return formatter.string(from: NSNumber(value: variancePercent / 100)) ?? "\(variancePercent)%"
    }
}
