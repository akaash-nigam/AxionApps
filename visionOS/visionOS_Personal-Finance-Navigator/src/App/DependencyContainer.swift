// DependencyContainer.swift
// Personal Finance Navigator
// Dependency Injection Container

import Foundation
import CoreData

/// Central dependency injection container
/// Manages all app dependencies and their lifecycles
@MainActor
class DependencyContainer {
    // MARK: - Singleton
    static let shared = DependencyContainer()

    // MARK: - Core Dependencies
    let persistenceController: PersistenceController
    let keychainManager: KeychainManager
    let encryptionManager: EncryptionManager

    // MARK: - Repositories
    private(set) lazy var transactionRepository: TransactionRepository = {
        CoreDataTransactionRepository(
            context: persistenceController.container.viewContext
        )
    }()

    private(set) lazy var accountRepository: AccountRepository = {
        CoreDataAccountRepository(
            context: persistenceController.container.viewContext
        )
    }()

    private(set) lazy var budgetRepository: BudgetRepository = {
        CoreDataBudgetRepository(
            context: persistenceController.container.viewContext
        )
    }()

    private(set) lazy var categoryRepository: CategoryRepository = {
        CoreDataCategoryRepository(
            context: persistenceController.container.viewContext
        )
    }()

    // MARK: - Services
    private(set) lazy var biometricAuthManager: BiometricAuthManager = {
        BiometricAuthManager()
    }()

    // TODO: Add more services as we implement them
    // private(set) lazy var plaidService: PlaidService = { ... }()
    // private(set) lazy var notificationService: NotificationService = { ... }()

    // MARK: - Use Cases
    // TODO: Add use cases as we implement them
    // func makeSyncTransactionsUseCase() -> SyncTransactionsUseCase { ... }
    // func makeCalculateBudgetStatusUseCase() -> CalculateBudgetStatusUseCase { ... }

    // MARK: - Init
    private init() {
        self.persistenceController = PersistenceController.shared
        self.keychainManager = KeychainManager()
        self.encryptionManager = EncryptionManager()

        // Initialize default categories on first launch
        Task {
            await initializeDefaultCategoriesIfNeeded()
        }
    }

    // MARK: - Initialization Helpers
    private func initializeDefaultCategoriesIfNeeded() async {
        let hasInitialized = UserDefaults.standard.bool(forKey: "hasInitializedCategories")

        guard !hasInitialized else { return }

        // Create default categories
        await createDefaultCategories()

        UserDefaults.standard.set(true, forKey: "hasInitializedCategories")
    }

    private func createDefaultCategories() async {
        do {
            try await categoryRepository.initializeDefaultCategories()
            print("✓ Default categories initialized")
        } catch {
            print("✗ Failed to initialize default categories: \(error.localizedDescription)")
        }
    }

    // MARK: - Factory Methods
    /// Creates a new background context for heavy operations
    func makeBackgroundContext() -> NSManagedObjectContext {
        persistenceController.container.newBackgroundContext()
    }
}

// MARK: - Repository Protocols
// Implemented in src/Data/Repositories/

protocol TransactionRepository {
    func fetchAll() async throws -> [Transaction]
    func fetchById(_ id: UUID) async throws -> Transaction?
    func fetchByAccount(_ accountId: UUID) async throws -> [Transaction]
    func fetchByDateRange(from startDate: Date, to endDate: Date) async throws -> [Transaction]
    func fetchByCategory(_ categoryId: UUID) async throws -> [Transaction]
    func fetchPending() async throws -> [Transaction]
    func search(query: String) async throws -> [Transaction]
    func save(_ transaction: Transaction) async throws
    func saveAll(_ transactions: [Transaction]) async throws
    func delete(_ transaction: Transaction) async throws
    func deleteById(_ id: UUID) async throws
    func deleteAll() async throws
    func getTotalSpent(from startDate: Date, to endDate: Date) async throws -> Decimal
    func getTotalIncome(from startDate: Date, to endDate: Date) async throws -> Decimal
    func getSpendingByCategory(from startDate: Date, to endDate: Date) async throws -> [UUID: Decimal]
}

protocol AccountRepository {
    func fetchAll() async throws -> [Account]
    func fetchById(_ id: UUID) async throws -> Account?
    func fetchActive() async throws -> [Account]
    func fetchByType(_ type: Account.AccountType) async throws -> [Account]
    func fetchNeedingReconnection() async throws -> [Account]
    func save(_ account: Account) async throws
    func saveAll(_ accounts: [Account]) async throws
    func delete(_ account: Account) async throws
    func deleteById(_ id: UUID) async throws
    func updateBalance(_ accountId: UUID, current: Decimal, available: Decimal?) async throws
    func markNeedsReconnection(_ accountId: UUID) async throws
    func updateSyncDate(_ accountId: UUID, date: Date) async throws
    func getTotalNetWorth() async throws -> Decimal
}

protocol BudgetRepository {
    func fetchAll() async throws -> [Budget]
    func fetchById(_ id: UUID) async throws -> Budget?
    func fetchActive() async throws -> Budget?
    func fetchByDateRange(from startDate: Date, to endDate: Date) async throws -> [Budget]
    func save(_ budget: Budget) async throws
    func delete(_ budget: Budget) async throws
    func deleteById(_ id: UUID) async throws
    func updateCategorySpent(_ budgetId: UUID, categoryId: UUID, spent: Decimal) async throws
    func getBudgetProgress(_ budgetId: UUID) async throws -> (spent: Decimal, allocated: Decimal, percentage: Double)
    func getCategoryProgress(_ budgetId: UUID, categoryId: UUID) async throws -> (spent: Decimal, allocated: Decimal, percentage: Double)
}

protocol CategoryRepository {
    func fetchAll() async throws -> [Category]
    func fetchById(_ id: UUID) async throws -> Category?
    func fetchByType(_ type: Category.CategoryType) async throws -> [Category]
    func fetchParentCategories() async throws -> [Category]
    func fetchSubcategories(_ parentId: UUID) async throws -> [Category]
    func fetchActive() async throws -> [Category]
    func save(_ category: Category) async throws
    func saveAll(_ categories: [Category]) async throws
    func delete(_ category: Category) async throws
    func deleteById(_ id: UUID) async throws
    func initializeDefaultCategories() async throws
}
