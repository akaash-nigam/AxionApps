//
//  FinancialTransaction.swift
//  Financial Operations Platform
//
//  Core financial transaction model
//

import Foundation
import SwiftData

@Model
final class FinancialTransaction: Identifiable {
    // MARK: - Properties

    @Attribute(.unique) var id: UUID
    var transactionDate: Date
    var postingDate: Date
    var accountCode: String
    var amount: Decimal
    var currency: Currency
    var description: String
    var transactionType: TransactionType
    var status: TransactionStatus
    var createdBy: String
    var createdAt: Date
    var approvedBy: String?
    var approvedAt: Date?
    var metadata: [String: String]

    // MARK: - Relationships

    var account: Account?
    var counterpartyAccount: Account?
    var journalEntry: JournalEntry?

    // MARK: - Initialization

    init(
        id: UUID = UUID(),
        transactionDate: Date = Date(),
        postingDate: Date = Date(),
        accountCode: String,
        amount: Decimal,
        currency: Currency,
        description: String,
        transactionType: TransactionType,
        status: TransactionStatus = .draft,
        createdBy: String,
        createdAt: Date = Date(),
        metadata: [String: String] = [:]
    ) {
        self.id = id
        self.transactionDate = transactionDate
        self.postingDate = postingDate
        self.accountCode = accountCode
        self.amount = amount
        self.currency = currency
        self.description = description
        self.transactionType = transactionType
        self.status = status
        self.createdBy = createdBy
        self.createdAt = createdAt
        self.metadata = metadata
    }

    // MARK: - Computed Properties

    var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency.code
        return formatter.string(from: amount as NSDecimalNumber) ?? "\(amount)"
    }

    var isApproved: Bool {
        status == .approved || status == .posted
    }
}

// MARK: - Transaction Type

enum TransactionType: String, Codable, CaseIterable {
    case revenue
    case expense
    case asset
    case liability
    case equity

    var displayName: String {
        rawValue.capitalized
    }
}

// MARK: - Transaction Status

enum TransactionStatus: String, Codable, CaseIterable {
    case draft
    case pending
    case approved
    case posted
    case reconciled
    case rejected

    var displayName: String {
        rawValue.capitalized
    }

    var color: String {
        switch self {
        case .draft: return "gray"
        case .pending: return "yellow"
        case .approved: return "green"
        case .posted: return "blue"
        case .reconciled: return "green"
        case .rejected: return "red"
        }
    }
}

// MARK: - Journal Entry

@Model
final class JournalEntry: Identifiable {
    @Attribute(.unique) var id: UUID
    var entryNumber: String
    var entryDate: Date
    var period: ClosePeriod
    var description: String
    var totalDebit: Decimal
    var totalCredit: Decimal
    var createdBy: String
    var createdAt: Date
    var postedBy: String?
    var postedAt: Date?

    var transactions: [FinancialTransaction]

    init(
        id: UUID = UUID(),
        entryNumber: String,
        entryDate: Date,
        period: ClosePeriod,
        description: String,
        totalDebit: Decimal,
        totalCredit: Decimal,
        createdBy: String,
        createdAt: Date = Date(),
        transactions: [FinancialTransaction] = []
    ) {
        self.id = id
        self.entryNumber = entryNumber
        self.entryDate = entryDate
        self.period = period
        self.description = description
        self.totalDebit = totalDebit
        self.totalCredit = totalCredit
        self.createdBy = createdBy
        self.createdAt = createdAt
        self.transactions = transactions
    }

    var isBalanced: Bool {
        totalDebit == totalCredit
    }
}
