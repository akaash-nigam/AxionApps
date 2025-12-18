// Transaction.swift
// Personal Finance Navigator
// Domain model for financial transactions

import Foundation

/// Represents a financial transaction
struct Transaction: Identifiable, Codable, Hashable {
    // MARK: - Identity
    let id: UUID
    let plaidTransactionId: String?

    // MARK: - Details
    let accountId: UUID
    var amount: Decimal
    let date: Date
    let authorizedDate: Date?
    let merchantName: String?
    var name: String
    var pending: Bool

    // MARK: - Categorization
    var categoryId: UUID?
    var primaryCategory: String
    var detailedCategory: String?
    var isRecurring: Bool
    var confidence: Float?

    // MARK: - Location
    var latitude: Double?
    var longitude: Double?
    var address: String?

    // MARK: - Payment
    let paymentChannel: PaymentChannel
    let paymentMethod: String?

    // MARK: - Flags
    var isUserModified: Bool
    var isHidden: Bool
    var isExcludedFromBudget: Bool
    var isSplit: Bool
    var parentTransactionId: UUID?

    // MARK: - Notes
    var notes: String?
    var tags: [String]

    // MARK: - Metadata
    let createdAt: Date
    var updatedAt: Date

    // MARK: - Init
    init(
        id: UUID = UUID(),
        plaidTransactionId: String? = nil,
        accountId: UUID,
        amount: Decimal,
        date: Date,
        authorizedDate: Date? = nil,
        merchantName: String? = nil,
        name: String,
        pending: Bool = false,
        categoryId: UUID? = nil,
        primaryCategory: String = "Uncategorized",
        detailedCategory: String? = nil,
        isRecurring: Bool = false,
        confidence: Float? = nil,
        latitude: Double? = nil,
        longitude: Double? = nil,
        address: String? = nil,
        paymentChannel: PaymentChannel = .other,
        paymentMethod: String? = nil,
        isUserModified: Bool = false,
        isHidden: Bool = false,
        isExcludedFromBudget: Bool = false,
        isSplit: Bool = false,
        parentTransactionId: UUID? = nil,
        notes: String? = nil,
        tags: [String] = [],
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.plaidTransactionId = plaidTransactionId
        self.accountId = accountId
        self.amount = amount
        self.date = date
        self.authorizedDate = authorizedDate
        self.merchantName = merchantName
        self.name = name
        self.pending = pending
        self.categoryId = categoryId
        self.primaryCategory = primaryCategory
        self.detailedCategory = detailedCategory
        self.isRecurring = isRecurring
        self.confidence = confidence
        self.latitude = latitude
        self.longitude = longitude
        self.address = address
        self.paymentChannel = paymentChannel
        self.paymentMethod = paymentMethod
        self.isUserModified = isUserModified
        self.isHidden = isHidden
        self.isExcludedFromBudget = isExcludedFromBudget
        self.isSplit = isSplit
        self.parentTransactionId = parentTransactionId
        self.notes = notes
        self.tags = tags
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    // MARK: - Computed Properties
    var isExpense: Bool {
        amount < 0
    }

    var isIncome: Bool {
        amount > 0
    }

    var absoluteAmount: Decimal {
        abs(amount)
    }

    var displayAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: amount as NSDecimalNumber) ?? "$0.00"
    }

    var shortDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Payment Channel
enum PaymentChannel: String, Codable {
    case online
    case inStore = "in_store"
    case other
}

// MARK: - Sample Data (for previews)
extension Transaction {
    static let sampleExpense = Transaction(
        accountId: UUID(),
        amount: -45.67,
        date: Date(),
        merchantName: "Whole Foods",
        name: "WHOLE FOODS MARKET #123",
        primaryCategory: "Food & Drink",
        detailedCategory: "Groceries",
        paymentChannel: .inStore
    )

    static let sampleIncome = Transaction(
        accountId: UUID(),
        amount: 3000.00,
        date: Date().addingTimeInterval(-86400 * 5),
        name: "Direct Deposit - Paycheck",
        primaryCategory: "Income",
        detailedCategory: "Salary",
        paymentChannel: .online
    )

    static let samplePending = Transaction(
        accountId: UUID(),
        amount: -15.99,
        date: Date(),
        merchantName: "Netflix",
        name: "NETFLIX.COM",
        pending: true,
        primaryCategory: "Entertainment",
        detailedCategory: "Streaming",
        paymentChannel: .online
    )

    static let samples: [Transaction] = [
        sampleExpense,
        sampleIncome,
        samplePending,
        Transaction(
            accountId: UUID(),
            amount: -120.00,
            date: Date().addingTimeInterval(-86400),
            merchantName: "Shell",
            name: "SHELL GAS STATION",
            primaryCategory: "Transportation",
            detailedCategory: "Gas",
            paymentChannel: .inStore
        ),
        Transaction(
            accountId: UUID(),
            amount: -85.50,
            date: Date().addingTimeInterval(-86400 * 2),
            merchantName: "Target",
            name: "TARGET STORE #1234",
            primaryCategory: "Shopping",
            detailedCategory: "General",
            paymentChannel: .inStore
        )
    ]
}
