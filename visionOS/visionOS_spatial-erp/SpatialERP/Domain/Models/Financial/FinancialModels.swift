import Foundation
import SwiftData

// MARK: - General Ledger Entry
@Model
final class GeneralLedgerEntry {
    @Attribute(.unique) var id: UUID
    var accountNumber: String
    var accountDescription: String
    var debitAmount: Decimal
    var creditAmount: Decimal
    var postingDate: Date
    var fiscalPeriod: String
    var documentNumber: String
    var referenceNumber: String?
    var notes: String?

    @Relationship(deleteRule: .nullify) var costCenter: CostCenter?
    @Relationship(deleteRule: .cascade) var lineItems: [JournalLineItem]

    // Computed properties
    var netAmount: Decimal {
        debitAmount - creditAmount
    }

    init(
        id: UUID = UUID(),
        accountNumber: String,
        accountDescription: String,
        debitAmount: Decimal,
        creditAmount: Decimal,
        postingDate: Date,
        fiscalPeriod: String,
        documentNumber: String,
        referenceNumber: String? = nil,
        notes: String? = nil
    ) {
        self.id = id
        self.accountNumber = accountNumber
        self.accountDescription = accountDescription
        self.debitAmount = debitAmount
        self.creditAmount = creditAmount
        self.postingDate = postingDate
        self.fiscalPeriod = fiscalPeriod
        self.documentNumber = documentNumber
        self.referenceNumber = referenceNumber
        self.notes = notes
        self.lineItems = []
    }

    // Mock data generator
    static func mock() -> GeneralLedgerEntry {
        GeneralLedgerEntry(
            accountNumber: "1000-100",
            accountDescription: "Revenue - Product Sales",
            debitAmount: 0,
            creditAmount: Decimal(45000),
            postingDate: Date(),
            fiscalPeriod: "Q4 2024",
            documentNumber: "INV-2024-1234"
        )
    }
}

// MARK: - Journal Line Item
@Model
final class JournalLineItem {
    @Attribute(.unique) var id: UUID
    var lineNumber: Int
    var accountNumber: String
    var amount: Decimal
    var description: String

    init(
        id: UUID = UUID(),
        lineNumber: Int,
        accountNumber: String,
        amount: Decimal,
        description: String
    ) {
        self.id = id
        self.lineNumber = lineNumber
        self.accountNumber = accountNumber
        self.amount = amount
        self.description = description
    }
}

// MARK: - Cost Center
@Model
final class CostCenter {
    @Attribute(.unique) var id: UUID
    var code: String
    var name: String
    var budget: Decimal
    var actualSpend: Decimal
    var manager: String
    var department: String

    @Relationship(inverse: \GeneralLedgerEntry.costCenter) var entries: [GeneralLedgerEntry]

    // Spatial properties for 3D visualization
    var spatialPositionX: Float?
    var spatialPositionY: Float?
    var spatialPositionZ: Float?
    var spatialScale: Float = 1.0

    // Computed properties
    var variance: Decimal {
        actualSpend - budget
    }

    var variancePercentage: Double {
        guard budget > 0 else { return 0 }
        return Double(truncating: ((actualSpend - budget) / budget * 100) as NSNumber)
    }

    var isOverBudget: Bool {
        actualSpend > budget
    }

    init(
        id: UUID = UUID(),
        code: String,
        name: String,
        budget: Decimal,
        actualSpend: Decimal = 0,
        manager: String,
        department: String
    ) {
        self.id = id
        self.code = code
        self.name = name
        self.budget = budget
        self.actualSpend = actualSpend
        self.manager = manager
        self.department = department
        self.entries = []
    }

    static func mock() -> CostCenter {
        CostCenter(
            code: "CC-1001",
            name: "Manufacturing Operations",
            budget: Decimal(500000),
            actualSpend: Decimal(485000),
            manager: "John Smith",
            department: "Operations"
        )
    }
}

// MARK: - Budget
@Model
final class Budget {
    @Attribute(.unique) var id: UUID
    var fiscalYear: String
    var fiscalPeriod: String
    var category: String
    var plannedAmount: Decimal
    var revisedAmount: Decimal?
    var approvalStatus: String
    var approvedBy: String?
    var approvalDate: Date?
    var notes: String?

    var currentAmount: Decimal {
        revisedAmount ?? plannedAmount
    }

    init(
        id: UUID = UUID(),
        fiscalYear: String,
        fiscalPeriod: String,
        category: String,
        plannedAmount: Decimal,
        revisedAmount: Decimal? = nil,
        approvalStatus: String = "Draft",
        approvedBy: String? = nil,
        approvalDate: Date? = nil,
        notes: String? = nil
    ) {
        self.id = id
        self.fiscalYear = fiscalYear
        self.fiscalPeriod = fiscalPeriod
        self.category = category
        self.plannedAmount = plannedAmount
        self.revisedAmount = revisedAmount
        self.approvalStatus = approvalStatus
        self.approvedBy = approvedBy
        self.approvalDate = approvalDate
        self.notes = notes
    }

    static func mock() -> Budget {
        Budget(
            fiscalYear: "FY 2024",
            fiscalPeriod: "Q4 2024",
            category: "Operations",
            plannedAmount: Decimal(2000000),
            approvalStatus: "Approved",
            approvedBy: "CFO",
            approvalDate: Date()
        )
    }
}

// MARK: - Supporting Types
struct BudgetAnalysis: Codable {
    let period: String
    let totalBudget: Decimal
    let totalSpend: Decimal
    let variance: Decimal
    let variancePercentage: Double
    let topOverBudget: [CostCenterVariance]
    let topUnderBudget: [CostCenterVariance]

    struct CostCenterVariance: Codable {
        let code: String
        let name: String
        let variance: Decimal
        let variancePercentage: Double
    }
}

struct FinancialKPIs: Codable {
    let revenue: Decimal
    let revenueChange: Double
    let profit: Decimal
    let profitMargin: Double
    let cashPosition: Decimal
    let daysPayableOutstanding: Int
    let daysReceivableOutstanding: Int
}

struct ProfitAndLoss: Codable {
    let period: String
    let revenue: Decimal
    let costOfSales: Decimal
    let grossProfit: Decimal
    let operatingExpenses: Decimal
    let ebitda: Decimal
    let interestExpense: Decimal
    let taxExpense: Decimal
    let netIncome: Decimal

    var grossMargin: Double {
        guard revenue > 0 else { return 0 }
        return Double(truncating: (grossProfit / revenue * 100) as NSNumber)
    }

    var operatingMargin: Double {
        guard revenue > 0 else { return 0 }
        return Double(truncating: (ebitda / revenue * 100) as NSNumber)
    }

    var netMargin: Double {
        guard revenue > 0 else { return 0 }
        return Double(truncating: (netIncome / revenue * 100) as NSNumber)
    }
}
