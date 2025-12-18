// Account.swift
// Personal Finance Navigator
// Domain model for financial accounts

import Foundation

/// Represents a financial account (checking, savings, credit card, etc.)
struct Account: Identifiable, Codable, Hashable {
    // MARK: - Identity
    let id: UUID
    let plaidAccountId: String?
    let plaidItemId: String?

    // MARK: - Details
    var name: String
    var officialName: String?
    let type: AccountType
    let subtype: String?
    let mask: String?

    // MARK: - Balance
    var currentBalance: Decimal
    var availableBalance: Decimal?
    var creditLimit: Decimal?

    // MARK: - Status
    var isActive: Bool
    var isHidden: Bool
    var needsReconnection: Bool
    var isSynced: Bool

    // MARK: - Metadata
    var currency: String
    var institutionId: String?
    var institutionName: String?
    var institutionLogo: Data?
    var primaryColor: String?
    var accountNumber: String?
    var routingNumber: String?
    var notes: String?
    var lastSyncedAt: Date?
    var color: String
    var icon: String
    let createdAt: Date
    var updatedAt: Date

    // MARK: - Init
    init(
        id: UUID = UUID(),
        plaidAccountId: String? = nil,
        plaidItemId: String? = nil,
        name: String,
        officialName: String? = nil,
        type: AccountType = .checking,
        subtype: String? = nil,
        mask: String? = nil,
        currentBalance: Decimal = 0,
        availableBalance: Decimal? = nil,
        creditLimit: Decimal? = nil,
        isActive: Bool = true,
        isHidden: Bool = false,
        needsReconnection: Bool = false,
        isSynced: Bool = false,
        currency: String = "USD",
        institutionId: String? = nil,
        institutionName: String? = nil,
        institutionLogo: Data? = nil,
        primaryColor: String? = nil,
        accountNumber: String? = nil,
        routingNumber: String? = nil,
        notes: String? = nil,
        lastSyncedAt: Date? = nil,
        color: String = "blue",
        icon: String = "creditcard.fill",
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.plaidAccountId = plaidAccountId
        self.plaidItemId = plaidItemId
        self.name = name
        self.officialName = officialName
        self.type = type
        self.subtype = subtype
        self.mask = mask
        self.currentBalance = currentBalance
        self.availableBalance = availableBalance
        self.creditLimit = creditLimit
        self.isActive = isActive
        self.isHidden = isHidden
        self.needsReconnection = needsReconnection
        self.isSynced = isSynced
        self.currency = currency
        self.institutionId = institutionId
        self.institutionName = institutionName
        self.institutionLogo = institutionLogo
        self.primaryColor = primaryColor
        self.accountNumber = accountNumber
        self.routingNumber = routingNumber
        self.notes = notes
        self.lastSyncedAt = lastSyncedAt
        self.color = color
        self.icon = icon
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    // MARK: - Computed Properties
    var displayBalance: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: currentBalance as NSDecimalNumber) ?? "$0.00"
    }

    var maskedAccountNumber: String {
        guard let mask = mask else { return "••••" }
        return "••••\(mask)"
    }

    var isCreditCard: Bool {
        type == .creditCard
    }

    var utilizationPercentage: Float? {
        guard let limit = creditLimit, limit > 0 else { return nil }
        return Float(truncating: abs(currentBalance) / limit as NSDecimalNumber) * 100
    }
}

// MARK: - Account Type
enum AccountType: String, Codable, CaseIterable {
    case checking
    case savings
    case creditCard
    case investment
    case loan
    case other

    var displayName: String {
        switch self {
        case .checking: return "Checking"
        case .savings: return "Savings"
        case .creditCard: return "Credit Card"
        case .investment: return "Investment"
        case .loan: return "Loan"
        }
    }

    var icon: String {
        switch self {
        case .checking: return "dollarsign.circle.fill"
        case .savings: return "banknote.fill"
        case .creditCard: return "creditcard.fill"
        case .investment: return "chart.line.uptrend.xyaxis"
        case .loan: return "doc.text.fill"
        }
    }
}

// MARK: - Sample Data (for previews)
extension Account {
    static let sampleChecking = Account(
        name: "Chase Checking",
        officialName: "Chase Total Checking",
        type: .checking,
        subtype: "checking",
        mask: "1234",
        currentBalance: 5432.10,
        availableBalance: 5432.10,
        institutionName: "Chase",
        primaryColor: "#0066CC",
        lastSyncedAt: Date()
    )

    static let sampleSavings = Account(
        name: "Ally Savings",
        officialName: "Ally Online Savings Account",
        type: .savings,
        subtype: "savings",
        mask: "5678",
        currentBalance: 15000.00,
        availableBalance: 15000.00,
        institutionName: "Ally Bank",
        primaryColor: "#7C3BAC",
        lastSyncedAt: Date()
    )

    static let sampleCreditCard = Account(
        name: "Amex Blue Cash",
        officialName: "American Express Blue Cash Preferred",
        type: .creditCard,
        subtype: "credit card",
        mask: "9012",
        currentBalance: -2150.50,
        availableBalance: 2849.50,
        creditLimit: 5000,
        institutionName: "American Express",
        primaryColor: "#006FCF",
        lastSyncedAt: Date()
    )

    static let samples: [Account] = [
        sampleChecking,
        sampleSavings,
        sampleCreditCard
    ]
}
