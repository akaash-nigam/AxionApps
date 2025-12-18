# Data Model & Schema Design
# Personal Finance Navigator

**Version**: 1.0
**Last Updated**: 2025-11-24
**Status**: Draft

## Table of Contents
1. [Overview](#overview)
2. [Core Data Model](#core-data-model)
3. [Entity Definitions](#entity-definitions)
4. [Relationships](#relationships)
5. [Category Taxonomy](#category-taxonomy)
6. [Domain Models](#domain-models)
7. [Migration Strategy](#migration-strategy)
8. [Indexes & Performance](#indexes--performance)

## Overview

The data model is designed with Core Data as the persistence layer, with domain models as the business logic layer. All entities are designed for CloudKit synchronization.

### Design Principles
- **Normalized**: Minimal data redundancy
- **Scalable**: Support for millions of transactions
- **Sync-friendly**: CloudKit-compatible relationships
- **Privacy-first**: Encrypted sensitive fields
- **Auditable**: Track creation and modification dates

## Core Data Model

### Entity Relationship Diagram

```
┌─────────────┐         ┌──────────────┐
│   Account   │1──────n │ Transaction  │
└─────────────┘         └──────────────┘
      │                        │
      │                        │n
      │                        │
      │                  ┌──────────┐
      │n                 │ Category │
      │                  └──────────┘
      │                        │
┌─────────────┐                │1
│    Bill     │                │
└─────────────┘          ┌──────────┐
      │n                 │  Budget  │
      │                  └──────────┘
      │1                       │n
┌─────────────┐                │
│  BillPlan   │          ┌──────────────┐
└─────────────┘          │BudgetCategory│
                         └──────────────┘

┌─────────────┐         ┌──────────────┐
│    Debt     │1──────n │ DebtPayment  │
└─────────────┘         └──────────────┘

┌─────────────┐         ┌──────────────┐
│    Goal     │1──────n │ Contribution │
└─────────────┘         └──────────────┘

┌─────────────┐         ┌──────────────┐
│ Investment  │1──────n │   Holding    │
│  Account    │         └──────────────┘
└─────────────┘
```

## Entity Definitions

### 1. Account

**Description**: Represents a financial account (checking, savings, credit card, investment)

**Attributes**:
```swift
entity Account {
    // Identity
    id: UUID
    plaidAccountId: String?
    plaidItemId: String?

    // Details
    name: String                    // "Chase Checking", "Amex Blue"
    officialName: String?           // Bank's official name
    type: AccountType               // checking, savings, credit, investment
    subtype: String?                // "401k", "roth", etc.
    mask: String?                   // Last 4 digits

    // Balance
    currentBalance: Decimal
    availableBalance: Decimal?
    creditLimit: Decimal?           // For credit cards

    // Status
    isActive: Bool
    isHidden: Bool
    needsReconnection: Bool

    // Metadata
    institutionName: String?
    institutionLogo: Data?
    primaryColor: String?           // Hex color for UI
    lastSyncedAt: Date?
    createdAt: Date
    updatedAt: Date

    // Relationships
    transactions: [Transaction]
    bills: [Bill]
    investmentHoldings: [Holding]?
}

enum AccountType: String {
    case checking
    case savings
    case creditCard
    case investment
    case loan
}
```

**Core Data Configuration**:
```xml
<entity name="Account" representedClassName="AccountEntity" syncable="YES">
    <attribute name="id" attributeType="UUID" usesScalarValueType="NO"/>
    <attribute name="plaidAccountId" optional="YES" attributeType="String"/>
    <attribute name="name" attributeType="String"/>
    <attribute name="type" attributeType="String"/>
    <attribute name="currentBalance" attributeType="Decimal" defaultValue="0"/>
    <attribute name="isActive" attributeType="Boolean" defaultValue="YES"/>
    <attribute name="createdAt" attributeType="Date"/>
    <attribute name="updatedAt" attributeType="Date"/>
    <relationship name="transactions" toMany="YES" deletionRule="Cascade" destinationEntity="Transaction" inverseName="account"/>
</entity>
```

### 2. Transaction

**Description**: Individual financial transaction (purchase, payment, transfer)

**Attributes**:
```swift
entity Transaction {
    // Identity
    id: UUID
    plaidTransactionId: String?

    // Details
    accountId: UUID
    amount: Decimal                 // Negative for expenses, positive for income
    date: Date
    authorizedDate: Date?
    merchantName: String?
    name: String                    // Transaction description
    pending: Bool

    // Categorization
    categoryId: UUID?
    primaryCategory: String         // "Food & Drink"
    detailedCategory: String?       // "Restaurants"
    isRecurring: Bool
    confidence: Float?              // AI categorization confidence 0-1

    // Location
    latitude: Double?
    longitude: Double?
    address: String?

    // Payment
    paymentChannel: PaymentChannel  // online, in-store, etc.
    paymentMethod: String?          // "Visa 1234"

    // Flags
    isUserModified: Bool            // User changed category
    isHidden: Bool
    isExcludedFromBudget: Bool
    isSplit: Bool                   // Split transaction
    parentTransactionId: UUID?      // If part of split

    // Notes
    notes: String?
    tags: [String]?

    // Metadata
    createdAt: Date
    updatedAt: Date

    // Relationships
    account: Account
    category: Category?
    budgetCategory: BudgetCategory?
}

enum PaymentChannel: String {
    case online
    case inStore
    case other
}
```

**Sample Data**:
```json
{
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "plaidTransactionId": "plaid_abc123",
    "accountId": "123e4567-e89b-12d3-a456-426614174000",
    "amount": -45.67,
    "date": "2024-01-15T12:30:00Z",
    "merchantName": "Whole Foods",
    "name": "WHOLE FOODS MARKET #123",
    "pending": false,
    "primaryCategory": "Food & Drink",
    "detailedCategory": "Groceries",
    "isRecurring": false,
    "paymentChannel": "in_store",
    "isUserModified": false,
    "createdAt": "2024-01-15T12:35:00Z"
}
```

### 3. Category

**Description**: Hierarchical category system for transaction organization

**Attributes**:
```swift
entity Category {
    // Identity
    id: UUID
    plaidCategoryId: String?

    // Hierarchy
    name: String                    // "Food & Drink"
    parentId: UUID?                 // Null for root categories
    level: Int16                    // 0 = root, 1 = subcategory, etc.
    path: String                    // "Food & Drink > Restaurants"

    // Display
    icon: String                    // SF Symbol name
    color: String                   // Hex color
    sortOrder: Int16

    // Classification
    isIncome: Bool
    isExpense: Bool
    isTransfer: Bool
    isEssential: Bool               // Need vs want
    isDiscretionary: Bool

    // Budget
    isDefaultBudgeted: Bool
    suggestedPercentage: Float?     // 0-100

    // Metadata
    createdAt: Date
    updatedAt: Date

    // Relationships
    subcategories: [Category]?
    transactions: [Transaction]
    budgetCategories: [BudgetCategory]
}
```

**Core Categories**:
```swift
let defaultCategories = [
    // Income (Green)
    Category(name: "Income", icon: "dollarsign.circle.fill", color: "#34C759", isIncome: true),
    Category(name: "Salary", parent: "Income", icon: "briefcase.fill"),
    Category(name: "Freelance", parent: "Income", icon: "laptop"),
    Category(name: "Investment Income", parent: "Income", icon: "chart.line.uptrend.xyaxis"),

    // Housing (Orange)
    Category(name: "Housing", icon: "house.fill", color: "#FF9500", isEssential: true),
    Category(name: "Rent", parent: "Housing", suggestedPercentage: 30),
    Category(name: "Mortgage", parent: "Housing"),
    Category(name: "Property Tax", parent: "Housing"),
    Category(name: "Home Insurance", parent: "Housing"),

    // Transportation (Blue)
    Category(name: "Transportation", icon: "car.fill", color: "#007AFF"),
    Category(name: "Gas", parent: "Transportation", isEssential: true),
    Category(name: "Public Transit", parent: "Transportation"),
    Category(name: "Parking", parent: "Transportation"),
    Category(name: "Car Payment", parent: "Transportation"),
    Category(name: "Auto Insurance", parent: "Transportation", isEssential: true),

    // Food (Green)
    Category(name: "Food & Drink", icon: "fork.knife", color: "#34C759"),
    Category(name: "Groceries", parent: "Food & Drink", isEssential: true),
    Category(name: "Restaurants", parent: "Food & Drink", isDiscretionary: true),
    Category(name: "Coffee Shops", parent: "Food & Drink", isDiscretionary: true),

    // Shopping (Pink)
    Category(name: "Shopping", icon: "cart.fill", color: "#FF2D55"),
    Category(name: "Clothing", parent: "Shopping", isDiscretionary: true),
    Category(name: "Electronics", parent: "Shopping", isDiscretionary: true),
    Category(name: "General", parent: "Shopping"),

    // Entertainment (Purple)
    Category(name: "Entertainment", icon: "film.fill", color: "#AF52DE", isDiscretionary: true),
    Category(name: "Movies", parent: "Entertainment"),
    Category(name: "Concerts", parent: "Entertainment"),
    Category(name: "Hobbies", parent: "Entertainment"),

    // Subscriptions (Indigo)
    Category(name: "Subscriptions", icon: "repeat.circle.fill", color: "#5856D6"),
    Category(name: "Streaming", parent: "Subscriptions"),
    Category(name: "Software", parent: "Subscriptions"),
    Category(name: "Memberships", parent: "Subscriptions"),

    // Healthcare (Red)
    Category(name: "Healthcare", icon: "cross.case.fill", color: "#FF3B30", isEssential: true),
    Category(name: "Doctor", parent: "Healthcare"),
    Category(name: "Pharmacy", parent: "Healthcare"),
    Category(name: "Health Insurance", parent: "Healthcare"),

    // Utilities (Yellow)
    Category(name: "Utilities", icon: "bolt.fill", color: "#FFC400", isEssential: true),
    Category(name: "Electric", parent: "Utilities"),
    Category(name: "Water", parent: "Utilities"),
    Category(name: "Internet", parent: "Utilities"),
    Category(name: "Phone", parent: "Utilities"),

    // Savings (Gold)
    Category(name: "Savings & Investments", icon: "banknote.fill", color: "#FFD700"),
    Category(name: "Emergency Fund", parent: "Savings & Investments"),
    Category(name: "Retirement", parent: "Savings & Investments"),
    Category(name: "Investments", parent: "Savings & Investments"),

    // Debt (Dark Red)
    Category(name: "Debt Payments", icon: "creditcard.fill", color: "#8B0000"),
    Category(name: "Credit Card Payment", parent: "Debt Payments"),
    Category(name: "Student Loan", parent: "Debt Payments"),
    Category(name: "Personal Loan", parent: "Debt Payments"),
]
```

### 4. Budget

**Description**: Budget plan with category allocations

**Attributes**:
```swift
entity Budget {
    // Identity
    id: UUID

    // Details
    name: String                    // "January 2024", "Q1 Budget"
    type: BudgetType
    startDate: Date
    endDate: Date

    // Totals
    totalIncome: Decimal
    totalAllocated: Decimal
    totalSpent: Decimal
    totalRemaining: Decimal         // Computed property

    // Status
    isActive: Bool
    isTemplate: Bool                // Reusable template

    // Strategy
    strategy: BudgetStrategy        // 50/30/20, zero-based, envelope

    // Metadata
    createdAt: Date
    updatedAt: Date

    // Relationships
    categories: [BudgetCategory]
}

enum BudgetType: String {
    case monthly
    case weekly
    case annual
    case custom
}

enum BudgetStrategy: String {
    case fiftyThirtyTwenty         // 50% needs, 30% wants, 20% savings
    case zeroBased                  // Every dollar assigned
    case envelope                   // Fixed amounts per category
    case percentageBased            // % of income
}
```

### 5. BudgetCategory

**Description**: Budget allocation for a specific category

**Attributes**:
```swift
entity BudgetCategory {
    // Identity
    id: UUID
    budgetId: UUID
    categoryId: UUID

    // Allocation
    allocated: Decimal              // Budget amount
    spent: Decimal                  // Current spending
    remaining: Decimal              // allocated - spent
    percentageOfBudget: Float       // % of total budget

    // Tracking
    isRollover: Bool                // Unused amount carries to next month
    rolledAmount: Decimal?          // Amount from previous period

    // Alerts
    alertAt75: Bool                 // Alert at 75% spent
    alertAt90: Bool
    alertAt100: Bool
    alertOnOverspend: Bool

    // Metadata
    createdAt: Date
    updatedAt: Date

    // Relationships
    budget: Budget
    category: Category
}
```

### 6. Bill

**Description**: Recurring or one-time bill

**Attributes**:
```swift
entity Bill {
    // Identity
    id: UUID
    accountId: UUID?

    // Details
    name: String                    // "Rent", "Electric Bill"
    amount: Decimal
    categoryId: UUID?

    // Schedule
    dueDate: Date
    isRecurring: Bool
    frequency: BillFrequency?       // monthly, biweekly, etc.
    nextDueDate: Date?

    // Payment
    isAutoPay: Bool
    isPaid: Bool
    paidDate: Date?
    paidAmount: Decimal?
    linkedTransactionId: UUID?

    // Status
    isActive: Bool

    // Reminders
    reminderDays: Int16             // Days before due date

    // Metadata
    notes: String?
    createdAt: Date
    updatedAt: Date

    // Relationships
    account: Account?
    category: Category?
}

enum BillFrequency: String {
    case weekly
    case biweekly
    case monthly
    case quarterly
    case semiannual
    case annual
}
```

### 7. Debt

**Description**: Debt account (credit card, loan, mortgage)

**Attributes**:
```swift
entity Debt {
    // Identity
    id: UUID
    accountId: UUID?

    // Details
    name: String                    // "Chase Credit Card", "Student Loan"
    type: DebtType
    originalAmount: Decimal
    currentBalance: Decimal
    interestRate: Decimal           // APR as decimal (0.18 = 18%)

    // Terms
    minimumPayment: Decimal?
    paymentDueDay: Int16?           // Day of month
    termMonths: Int16?              // Loan term

    // Strategy
    payoffStrategy: PayoffStrategy
    targetPayoffDate: Date?
    extraPayment: Decimal?          // Additional payment per period

    // Status
    isActive: Bool

    // Metadata
    createdAt: Date
    updatedAt: Date

    // Relationships
    account: Account?
    payments: [DebtPayment]
}

enum DebtType: String {
    case creditCard
    case studentLoan
    case autoLoan
    case personalLoan
    case mortgage
    case other
}

enum PayoffStrategy: String {
    case snowball               // Smallest balance first
    case avalanche              // Highest interest first
    case custom                 // User-defined
}
```

### 8. DebtPayment

**Description**: Payment made towards debt

**Attributes**:
```swift
entity DebtPayment {
    // Identity
    id: UUID
    debtId: UUID

    // Details
    amount: Decimal
    principalAmount: Decimal        // Amount to principal
    interestAmount: Decimal         // Amount to interest
    date: Date

    // Source
    linkedTransactionId: UUID?

    // Metadata
    createdAt: Date

    // Relationships
    debt: Debt
}
```

### 9. Goal

**Description**: Savings goal

**Attributes**:
```swift
entity Goal {
    // Identity
    id: UUID
    linkedAccountId: UUID?

    // Details
    name: String                    // "Hawaii Vacation", "Emergency Fund"
    description: String?
    targetAmount: Decimal
    currentAmount: Decimal
    type: GoalType

    // Timeline
    targetDate: Date?
    startDate: Date
    projectedCompletionDate: Date?  // Based on current rate

    // Contribution
    recurringAmount: Decimal?
    frequency: ContributionFrequency?
    isAutoContribute: Bool

    // Display
    icon: String                    // SF Symbol
    color: String                   // Hex
    visualizationType: GoalVisualizationType

    // Status
    isActive: Bool
    isCompleted: Bool
    completedDate: Date?

    // Metadata
    createdAt: Date
    updatedAt: Date

    // Relationships
    contributions: [Contribution]
    linkedAccount: Account?
}

enum GoalType: String {
    case emergency
    case vacation
    case house
    case car
    case education
    case retirement
    case custom
}

enum GoalVisualizationType: String {
    case jar                        // Glass jar filling
    case suitcase                   // Travel items appearing
    case piggyBank                  // Growing pig
    case progressBar                // Simple bar
}
```

### 10. Contribution

**Description**: Contribution to a savings goal

**Attributes**:
```swift
entity Contribution {
    // Identity
    id: UUID
    goalId: UUID

    // Details
    amount: Decimal
    date: Date
    source: ContributionSource

    // Source
    linkedTransactionId: UUID?

    // Metadata
    notes: String?
    createdAt: Date

    // Relationships
    goal: Goal
}

enum ContributionSource: String {
    case manual                     // User manually added
    case recurring                  // Auto-transfer
    case roundup                    // Spare change
    case windfall                   // Bonus, tax refund
}
```

### 11. InvestmentAccount

**Description**: Investment/brokerage account

**Attributes**:
```swift
entity InvestmentAccount {
    // Identity
    id: UUID
    accountId: UUID

    // Details
    type: InvestmentAccountType
    totalValue: Decimal
    totalCost: Decimal              // Cost basis
    totalGain: Decimal              // totalValue - totalCost
    totalGainPercent: Float

    // Metadata
    lastSyncedAt: Date?
    createdAt: Date
    updatedAt: Date

    // Relationships
    account: Account
    holdings: [Holding]
}

enum InvestmentAccountType: String {
    case brokerage
    case ira
    case rothIra
    case k401
    case k403b
    case hsa
}
```

### 12. Holding

**Description**: Individual investment holding (stock, bond, fund)

**Attributes**:
```swift
entity Holding {
    // Identity
    id: UUID
    investmentAccountId: UUID

    // Security
    ticker: String                  // "AAPL", "VTSAX"
    name: String                    // "Apple Inc."
    type: SecurityType
    cusip: String?

    // Position
    quantity: Decimal
    costBasis: Decimal              // Price paid per share
    currentPrice: Decimal
    currentValue: Decimal           // quantity * currentPrice

    // Performance
    totalGain: Decimal
    totalGainPercent: Float
    dayChange: Decimal?
    dayChangePercent: Float?

    // Metadata
    lastUpdated: Date
    createdAt: Date

    // Relationships
    investmentAccount: InvestmentAccount
}

enum SecurityType: String {
    case stock
    case etf
    case mutualFund
    case bond
    case crypto
    case other
}
```

### 13. UserProfile

**Description**: User preferences and settings

**Attributes**:
```swift
entity UserProfile {
    // Identity
    id: UUID
    userId: String                  // iCloud user identifier

    // Personal
    displayName: String?
    email: String?

    // Preferences
    currency: String                // "USD", "EUR"
    firstDayOfWeek: Int16           // 0 = Sunday
    fiscalYearStart: Date?

    // Budget
    defaultBudgetStrategy: BudgetStrategy
    monthlyIncome: Decimal?

    // Notifications
    enableBillReminders: Bool
    enableBudgetAlerts: Bool
    enableGoalAchievements: Bool
    reminderTime: Date?             // Time of day for reminders

    // Security
    requireBiometric: Bool
    autoLockMinutes: Int16

    // Display
    preferredTheme: String          // "light", "dark", "auto"
    showNetWorth: Bool
    hideAccountBalances: Bool       // Privacy mode

    // Onboarding
    hasCompletedOnboarding: Bool
    onboardingVersion: String?

    // Metadata
    createdAt: Date
    updatedAt: Date
}
```

## Category Taxonomy

### Hierarchical Structure

```
Income
├── Salary
├── Freelance / Side Hustle
├── Investment Income
│   ├── Dividends
│   ├── Interest
│   └── Capital Gains
├── Gifts
└── Other Income

Housing
├── Rent
├── Mortgage
├── Property Tax
├── Home Insurance
├── HOA Fees
├── Maintenance / Repairs
└── Utilities (if grouped)

Transportation
├── Gas / Fuel
├── Public Transit
├── Parking
├── Tolls
├── Car Payment
├── Auto Insurance
├── Vehicle Maintenance
└── Ride Share

Food & Drink
├── Groceries
├── Restaurants
├── Coffee Shops
├── Bars / Nightlife
└── Food Delivery

Shopping
├── Clothing
├── Electronics
├── Home & Garden
├── Sports & Outdoors
├── Books
└── General Merchandise

Entertainment
├── Movies & Shows
├── Concerts / Events
├── Hobbies
├── Sports & Recreation
├── Travel & Vacation
└── Streaming Services (or Subscriptions)

Subscriptions & Memberships
├── Streaming Services
├── Software / Apps
├── Gym / Fitness
├── Professional Memberships
└── Other Subscriptions

Healthcare
├── Doctor Visits
├── Dentist
├── Pharmacy / Medications
├── Health Insurance
├── Vision Care
└── Medical Devices

Personal Care
├── Haircuts / Salon
├── Spa / Massage
├── Cosmetics
└── Gym (or Entertainment)

Utilities
├── Electric
├── Gas
├── Water / Sewer
├── Internet
├── Phone
└── Trash / Recycling

Education
├── Tuition
├── Books & Supplies
├── Student Loan Interest
└── Courses / Training

Savings & Investments
├── Emergency Fund
├── Retirement Contribution
├── Investment Contribution
└── Savings Transfer

Debt Payments
├── Credit Card Payment
├── Student Loan Payment
├── Personal Loan Payment
├── Auto Loan Payment
└── Mortgage Principal

Fees & Charges
├── Bank Fees
├── ATM Fees
├── Late Fees
├── Overdraft Fees
└── Service Charges

Transfers
├── Internal Transfer
├── External Transfer
└── Venmo / PayPal

Taxes
├── Federal Tax
├── State Tax
├── Property Tax
└── Other Taxes

Gifts & Donations
├── Charity
├── Gifts Given
└── Tithing

Pet Care
├── Veterinarian
├── Pet Food
├── Pet Supplies
└── Pet Insurance

Childcare & Family
├── Daycare
├── Babysitting
├── Child Support
└── School Expenses

Insurance
├── Health Insurance
├── Auto Insurance
├── Home / Renters Insurance
├── Life Insurance
└── Disability Insurance

Business Expenses (if applicable)
├── Office Supplies
├── Business Travel
├── Professional Services
└── Business Insurance

Miscellaneous
├── Uncategorized
└── Other
```

## Domain Models

### Swift Domain Model Example

```swift
// Transaction.swift
struct Transaction: Identifiable, Codable {
    let id: UUID
    let accountId: UUID
    let amount: Decimal
    let date: Date
    let merchantName: String?
    let name: String
    let category: Category?
    let pending: Bool
    let isUserModified: Bool

    var isExpense: Bool {
        amount < 0
    }

    var isIncome: Bool {
        amount > 0
    }

    var absoluteAmount: Decimal {
        abs(amount)
    }
}

// Budget.swift
struct Budget: Identifiable, Codable {
    let id: UUID
    let name: String
    let type: BudgetType
    let startDate: Date
    let endDate: Date
    let totalIncome: Decimal
    var categories: [BudgetCategory]

    var totalAllocated: Decimal {
        categories.reduce(0) { $0 + $1.allocated }
    }

    var totalSpent: Decimal {
        categories.reduce(0) { $0 + $1.spent }
    }

    var totalRemaining: Decimal {
        totalAllocated - totalSpent
    }

    var percentageSpent: Float {
        guard totalAllocated > 0 else { return 0 }
        return Float(totalSpent / totalAllocated * 100)
    }
}
```

## Migration Strategy

### Version Control

```swift
// PersonalFinanceNavigator.xcdatamodeld
// Version 1: Initial release
// Version 2: Add investment tracking
// Version 3: Add recurring transaction detection
```

### Lightweight Migration

For simple changes (add attribute, add entity):
```swift
let container = NSPersistentContainer(name: "PersonalFinanceNavigator")
let description = container.persistentStoreDescriptions.first
description?.shouldMigrateStoreAutomatically = true
description?.shouldInferMappingModelAutomatically = true
```

### Custom Migration

For complex changes (data transformation):
```swift
// Migration from v1 to v2
class MigrationV1toV2: NSEntityMigrationPolicy {
    override func createDestinationInstances(
        forSource sInstance: NSManagedObject,
        in mapping: NSEntityMapping,
        manager: NSMigrationManager
    ) throws {
        // Custom migration logic
    }
}
```

### Migration Checklist

**Version 2 (Investment Tracking)**:
- [ ] Add InvestmentAccount entity
- [ ] Add Holding entity
- [ ] Add relationship: Account -> InvestmentAccount
- [ ] Migrate existing investment accounts
- [ ] Update Category with investment income types

**Version 3 (Recurring Detection)**:
- [ ] Add isRecurring to Transaction
- [ ] Add RecurringTransaction entity
- [ ] Run ML model to detect patterns in existing transactions
- [ ] Link transactions to recurring patterns

## Indexes & Performance

### Core Data Indexes

```swift
// Transaction entity
fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
// Index on: date, accountId, categoryId

// Budget entity
// Index on: startDate, endDate, isActive

// Bill entity
// Index on: dueDate, isPaid, isActive

// Compound index on Transaction
// (accountId, date) for account transaction history
// (categoryId, date) for category spending over time
```

### Fetch Request Optimization

```swift
// Efficient transaction fetch
let request: NSFetchRequest<TransactionEntity> = TransactionEntity.fetchRequest()
request.predicate = NSPredicate(
    format: "date >= %@ AND date <= %@ AND accountId == %@",
    startDate as NSDate,
    endDate as NSDate,
    accountId as CVarArg
)
request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
request.fetchBatchSize = 20 // Pagination
request.propertiesToFetch = ["id", "amount", "date", "name"] // Only needed properties
```

### Pagination Strategy

```swift
class TransactionRepository {
    func fetchTransactions(
        for accountId: UUID,
        limit: Int = 50,
        offset: Int = 0
    ) async throws -> [Transaction] {
        let request: NSFetchRequest<TransactionEntity> = TransactionEntity.fetchRequest()
        request.predicate = NSPredicate(format: "accountId == %@", accountId as CVarArg)
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        request.fetchLimit = limit
        request.fetchOffset = offset

        let entities = try context.fetch(request)
        return entities.map { $0.toDomain() }
    }
}
```

### Cache Strategy

```swift
// In-memory cache for frequently accessed data
actor DataCache {
    private var accounts: [UUID: Account] = [:]
    private var categories: [UUID: Category] = [:]

    func getAccount(id: UUID) -> Account? {
        accounts[id]
    }

    func setAccount(_ account: Account) {
        accounts[account.id] = account
    }

    func invalidate() {
        accounts.removeAll()
        categories.removeAll()
    }
}
```

## CloudKit Schema

### Record Types

```swift
// CKRecord for Transaction
CKRecord(recordType: "Transaction")
- id: String (UUID)
- accountReference: CKRecord.Reference
- amount: Double
- date: Date
- merchantName: String?
- name: String
- categoryReference: CKRecord.Reference?
- pending: Bool

// Shared Database (Family Plan)
CKRecord(recordType: "SharedBudget")
- ownerReference: CKRecord.Reference
- sharedWithUsers: [String] // CloudKit user IDs
```

### Sync Conflict Resolution

```swift
// CloudKit merge policy
let container = NSPersistentCloudKitContainer(name: "PersonalFinanceNavigator")
container.persistentStoreDescriptions.first?.cloudKitContainerOptions?.databaseScope = .private

// Conflict resolution: Last-Write-Wins
let description = container.persistentStoreDescriptions.first
description?.setOption(
    NSMergeByPropertyObjectTrumpMergePolicy,
    forKey: NSMergePolicyOptionKey
)
```

---

**Document Status**: Ready for Implementation
**Next Steps**: API Integration Design
