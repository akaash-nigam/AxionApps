// SampleData.swift
// Personal Finance Navigator
// Sample data generation for previews and testing

import Foundation
import CoreData

/// Provides sample data for SwiftUI previews and testing
struct SampleData {
    // MARK: - Preview Container

    /// Creates an in-memory Core Data container with sample data
    static var previewContainer: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        let context = controller.container.viewContext

        // Generate sample data
        let categories = createSampleCategories(in: context)
        let accounts = createSampleAccounts(in: context)
        let transactions = createSampleTransactions(in: context, accounts: accounts, categories: categories)
        let budget = createSampleBudget(in: context, categories: categories)

        do {
            try context.save()
        } catch {
            print("Failed to save sample data: \(error.localizedDescription)")
        }

        return controller
    }()

    // MARK: - Sample Categories

    static func createSampleCategories(in context: NSManagedObjectContext) -> [CategoryEntity] {
        let categories: [(String, String, String, Category.CategoryType)] = [
            ("Food & Dining", "fork.knife", "FF6B6B", .expense),
            ("Groceries", "cart", "FF6B6B", .expense),
            ("Restaurants", "fork.knife.circle", "FF6B6B", .expense),
            ("Transportation", "car", "4ECDC4", .expense),
            ("Gas", "fuelpump", "4ECDC4", .expense),
            ("Public Transit", "tram", "4ECDC4", .expense),
            ("Housing", "house", "95E1D3", .expense),
            ("Rent/Mortgage", "house.fill", "95E1D3", .expense),
            ("Utilities", "bolt", "95E1D3", .expense),
            ("Salary", "dollarsign.circle", "A8E6CF", .income),
            ("Freelance", "briefcase", "A8E6CF", .income),
            ("Investments", "chart.line.uptrend.xyaxis", "FFD93D", .income)
        ]

        var entities: [CategoryEntity] = []
        var parentMap: [String: CategoryEntity] = [:]

        for (index, (name, icon, color, type)) in categories.enumerated() {
            let entity = CategoryEntity(context: context)
            entity.id = UUID()
            entity.name = name
            entity.icon = icon
            entity.color = color
            entity.type = type.rawValue
            entity.isActive = true
            entity.displayOrder = Int32(index)
            entity.createdAt = Date()
            entity.updatedAt = Date()

            // Set parent relationships
            if name == "Groceries" || name == "Restaurants" {
                entity.parentId = parentMap["Food & Dining"]?.id
            } else if name == "Gas" || name == "Public Transit" {
                entity.parentId = parentMap["Transportation"]?.id
            } else if name == "Rent/Mortgage" || name == "Utilities" {
                entity.parentId = parentMap["Housing"]?.id
            }

            entities.append(entity)
            parentMap[name] = entity
        }

        return entities
    }

    // MARK: - Sample Accounts

    static func createSampleAccounts(in context: NSManagedObjectContext) -> [AccountEntity] {
        let accounts: [(String, String, Account.AccountType, Decimal, String)] = [
            ("Chase Checking", "1234", .checking, 5432.10, "Chase"),
            ("Ally Savings", "5678", .savings, 15000.00, "Ally Bank"),
            ("Chase Freedom Credit Card", "9012", .creditCard, 1250.00, "Chase"),
            ("Vanguard 401k", "3456", .investment, 85000.00, "Vanguard")
        ]

        return accounts.map { (name, mask, type, balance, institution) in
            let entity = AccountEntity(context: context)
            entity.id = UUID()
            entity.name = name
            entity.officialName = name
            entity.type = type.rawValue
            entity.subtype = type.rawValue
            entity.mask = mask
            entity.currentBalance = NSDecimalNumber(decimal: balance)
            entity.availableBalance = type == .checking ? NSDecimalNumber(decimal: balance * 0.9) : nil
            entity.creditLimit = type == .creditCard ? NSDecimalNumber(decimal: 5000) : nil
            entity.isActive = true
            entity.isHidden = false
            entity.needsReconnection = false
            entity.institutionName = institution
            entity.lastSyncedAt = Date()
            entity.createdAt = Date()
            entity.updatedAt = Date()
            return entity
        }
    }

    // MARK: - Sample Transactions

    static func createSampleTransactions(
        in context: NSManagedObjectContext,
        accounts: [AccountEntity],
        categories: [CategoryEntity]
    ) -> [TransactionEntity] {
        guard let checkingAccount = accounts.first(where: { $0.type == Account.AccountType.checking.rawValue }),
              let creditCard = accounts.first(where: { $0.type == Account.AccountType.creditCard.rawValue }),
              let groceryCategory = categories.first(where: { $0.name == "Groceries" }),
              let restaurantCategory = categories.first(where: { $0.name == "Restaurants" }),
              let gasCategory = categories.first(where: { $0.name == "Gas" }),
              let salaryCategory = categories.first(where: { $0.name == "Salary" })
        else { return [] }

        let calendar = Calendar.current
        let today = Date()

        let transactions: [(String, String, Decimal, AccountEntity, CategoryEntity, Int)] = [
            // Recent transactions
            ("Whole Foods", "Whole Foods Market", -89.32, checkingAccount, groceryCategory, 0),
            ("Shell Gas Station", "Shell", -45.00, creditCard, gasCategory, 1),
            ("Chipotle", "Chipotle Mexican Grill", -12.50, creditCard, restaurantCategory, 2),
            ("Trader Joe's", "Trader Joe's", -67.89, checkingAccount, groceryCategory, 3),
            ("Starbucks", "Starbucks", -5.75, creditCard, restaurantCategory, 5),
            ("Safeway", "Safeway", -102.45, checkingAccount, groceryCategory, 7),

            // Paycheck
            ("Paycheck", "Direct Deposit", 3500.00, checkingAccount, salaryCategory, 15),

            // Older transactions
            ("Target", "Target", -78.20, creditCard, groceryCategory, 18),
            ("Shell Gas Station", "Shell", -42.00, creditCard, gasCategory, 20),
            ("Panera Bread", "Panera", -15.30, creditCard, restaurantCategory, 22),
        ]

        return transactions.map { (name, merchant, amount, account, category, daysAgo) in
            let entity = TransactionEntity(context: context)
            entity.id = UUID()
            entity.accountId = account.id
            entity.categoryId = category.id
            entity.plaidTransactionId = "plaid_\(UUID().uuidString.prefix(8))"
            entity.name = name
            entity.merchantName = merchant
            entity.amount = NSDecimalNumber(decimal: amount)
            entity.date = calendar.date(byAdding: .day, value: -daysAgo, to: today) ?? today
            entity.authorizedDate = entity.date
            entity.isPending = false
            entity.isRecurring = false
            entity.accountOwner = "User"
            entity.createdAt = Date()
            entity.updatedAt = Date()
            return entity
        }
    }

    // MARK: - Sample Budget

    static func createSampleBudget(
        in context: NSManagedObjectContext,
        categories: [CategoryEntity]
    ) -> BudgetEntity {
        let calendar = Calendar.current
        let today = Date()
        let startDate = calendar.date(from: calendar.dateComponents([.year, .month], from: today))!
        let endDate = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startDate)!

        let entity = BudgetEntity(context: context)
        entity.id = UUID()
        entity.name = "Monthly Budget"
        entity.startDate = startDate
        entity.endDate = endDate
        entity.totalAmount = NSDecimalNumber(decimal: 3000)
        entity.strategy = Budget.BudgetStrategy.fiftyThirtyTwenty.rawValue
        entity.createdAt = Date()
        entity.updatedAt = Date()

        // Create budget categories
        let allocations: [(String, Decimal, Decimal)] = [
            ("Food & Dining", 400, 245),
            ("Transportation", 300, 87),
            ("Housing", 1200, 1200),
            ("Utilities", 150, 0)
        ]

        for (categoryName, allocated, spent) in allocations {
            guard let category = categories.first(where: { $0.name == categoryName }) else { continue }

            let budgetCategory = BudgetCategoryEntity(context: context)
            budgetCategory.id = UUID()
            budgetCategory.budgetId = entity.id
            budgetCategory.categoryId = category.id
            budgetCategory.categoryName = categoryName
            budgetCategory.allocated = NSDecimalNumber(decimal: allocated)
            budgetCategory.spent = NSDecimalNumber(decimal: spent)
            budgetCategory.percentageOfBudget = Double(truncating: (spent / allocated * 100) as NSDecimalNumber)
            budgetCategory.isRollover = false
            budgetCategory.alertAt75 = true
            budgetCategory.alertAt90 = true
            budgetCategory.alertAt100 = true
            budgetCategory.alertOnOverspend = true
            budgetCategory.createdAt = Date()
            budgetCategory.updatedAt = Date()
        }

        return entity
    }

    // MARK: - Sample User Profile

    static func createSampleUserProfile(in context: NSManagedObjectContext) -> UserProfileEntity {
        let entity = UserProfileEntity(context: context)
        entity.id = UUID()
        entity.email = "user@example.com"
        entity.displayName = "John Doe"
        entity.preferredCurrency = "USD"
        entity.fiscalYearStart = 1
        entity.weekStartDay = 1
        entity.enableNotifications = true
        entity.enableBudgetAlerts = true
        entity.enableBillReminders = true
        entity.requireBiometric = true
        entity.autoLockTimeout = 300
        entity.enableCloudSync = true
        entity.theme = "system"
        entity.createdAt = Date()
        entity.updatedAt = Date()
        return entity
    }

    // MARK: - Domain Model Samples

    /// Sample transactions for SwiftUI previews (domain models)
    static let sampleTransactions: [Transaction] = [
        Transaction(
            id: UUID(),
            accountId: UUID(),
            amount: -89.32,
            date: Date(),
            name: "Whole Foods",
            merchantName: "Whole Foods Market",
            categoryId: UUID(),
            isPending: false
        ),
        Transaction(
            id: UUID(),
            accountId: UUID(),
            amount: -45.00,
            date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!,
            name: "Shell Gas Station",
            merchantName: "Shell",
            categoryId: UUID(),
            isPending: false
        ),
        Transaction(
            id: UUID(),
            accountId: UUID(),
            amount: 3500.00,
            date: Calendar.current.date(byAdding: .day, value: -15, to: Date())!,
            name: "Paycheck",
            merchantName: "Direct Deposit",
            categoryId: UUID(),
            isPending: false
        )
    ]

    /// Sample accounts for SwiftUI previews (domain models)
    static let sampleAccounts: [Account] = [
        Account(
            id: UUID(),
            name: "Chase Checking",
            type: .checking,
            currentBalance: 5432.10,
            mask: "1234",
            institutionName: "Chase"
        ),
        Account(
            id: UUID(),
            name: "Ally Savings",
            type: .savings,
            currentBalance: 15000.00,
            mask: "5678",
            institutionName: "Ally Bank"
        ),
        Account(
            id: UUID(),
            name: "Chase Freedom",
            type: .creditCard,
            currentBalance: 1250.00,
            availableBalance: 3750.00,
            creditLimit: 5000.00,
            mask: "9012",
            institutionName: "Chase"
        )
    ]
}
