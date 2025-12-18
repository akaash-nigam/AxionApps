// TransactionViewModelTests.swift
// Personal Finance Navigator Tests
// Unit tests for TransactionViewModel

import XCTest
@testable import PersonalFinanceNavigator

@MainActor
final class TransactionViewModelTests: XCTestCase {
    var sut: TransactionViewModel!
    var mockTransactionRepo: MockTransactionRepository!
    var mockAccountRepo: MockAccountRepository!
    var mockCategoryRepo: MockCategoryRepository!

    override func setUp() {
        super.setUp()
        mockTransactionRepo = MockTransactionRepository()
        mockAccountRepo = MockAccountRepository()
        mockCategoryRepo = MockCategoryRepository()
        sut = TransactionViewModel(
            transactionRepository: mockTransactionRepo,
            accountRepository: mockAccountRepo,
            categoryRepository: mockCategoryRepo
        )
    }

    override func tearDown() {
        sut = nil
        mockTransactionRepo = nil
        mockAccountRepo = nil
        mockCategoryRepo = nil
        super.tearDown()
    }

    // MARK: - Load Transactions Tests

    func testLoadTransactions_Success() async {
        // Given
        let transactions = [
            Transaction(id: UUID(), accountId: UUID(), amount: -50, date: Date(), name: "Groceries", categoryId: UUID()),
            Transaction(id: UUID(), accountId: UUID(), amount: 1000, date: Date(), name: "Salary", categoryId: UUID())
        ]
        mockTransactionRepo.transactionsToReturn = transactions

        // When
        await sut.loadTransactions()

        // Then
        XCTAssertEqual(sut.transactions.count, 2)
        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(sut.errorMessage)
    }

    func testLoadTransactions_Failure() async {
        // Given
        mockTransactionRepo.shouldFail = true

        // When
        await sut.loadTransactions()

        // Then
        XCTAssertTrue(sut.transactions.isEmpty)
        XCTAssertNotNil(sut.errorMessage)
    }

    // MARK: - Add Transaction Tests

    func testAddTransaction_Success() async {
        // Given
        let accountId = UUID()
        let account = Account(id: accountId, name: "Checking", type: .checking, currentBalance: 1000)
        mockAccountRepo.accountsToReturn = [account]

        let transaction = Transaction(
            id: UUID(),
            accountId: accountId,
            amount: -100,
            date: Date(),
            name: "Coffee",
            categoryId: UUID()
        )

        // When
        let result = await sut.addTransaction(transaction)

        // Then
        XCTAssertTrue(result)
        XCTAssertTrue(mockTransactionRepo.didCallSave)
        XCTAssertTrue(mockAccountRepo.didCallUpdateBalance)
    }

    func testAddTransaction_UpdatesAccountBalance() async {
        // Given
        let accountId = UUID()
        let initialBalance: Decimal = 1000
        let account = Account(id: accountId, name: "Checking", type: .checking, currentBalance: initialBalance)
        mockAccountRepo.accountsToReturn = [account]

        let transaction = Transaction(
            id: UUID(),
            accountId: accountId,
            amount: -50,
            date: Date(),
            name: "Purchase",
            categoryId: UUID()
        )

        // When
        _ = await sut.addTransaction(transaction)

        // Then
        XCTAssertTrue(mockAccountRepo.didCallUpdateBalance)
    }

    // MARK: - Delete Transaction Tests

    func testDeleteTransaction_ReversesBalance() async {
        // Given
        let accountId = UUID()
        let account = Account(id: accountId, name: "Checking", type: .checking, currentBalance: 950)
        mockAccountRepo.accountsToReturn = [account]

        let transaction = Transaction(
            id: UUID(),
            accountId: accountId,
            amount: -50,
            date: Date(),
            name: "Purchase",
            categoryId: UUID()
        )

        // When
        _ = await sut.deleteTransaction(transaction)

        // Then
        XCTAssertTrue(mockTransactionRepo.didCallDelete)
        XCTAssertTrue(mockAccountRepo.didCallUpdateBalance)
    }

    // MARK: - Filter Tests

    func testFilteredTransactions_ByAccount() async {
        // Given
        let accountId1 = UUID()
        let accountId2 = UUID()
        let transactions = [
            Transaction(id: UUID(), accountId: accountId1, amount: -50, date: Date(), name: "Trans 1", categoryId: UUID()),
            Transaction(id: UUID(), accountId: accountId2, amount: -30, date: Date(), name: "Trans 2", categoryId: UUID()),
            Transaction(id: UUID(), accountId: accountId1, amount: -20, date: Date(), name: "Trans 3", categoryId: UUID())
        ]
        mockTransactionRepo.transactionsToReturn = transactions

        // When
        await sut.loadTransactions()
        sut.selectedAccountId = accountId1

        // Then
        XCTAssertEqual(sut.filteredTransactions.count, 2)
        XCTAssertTrue(sut.filteredTransactions.allSatisfy { $0.accountId == accountId1 })
    }

    func testFilteredTransactions_ByCategory() async {
        // Given
        let categoryId1 = UUID()
        let categoryId2 = UUID()
        let transactions = [
            Transaction(id: UUID(), accountId: UUID(), amount: -50, date: Date(), name: "Trans 1", categoryId: categoryId1),
            Transaction(id: UUID(), accountId: UUID(), amount: -30, date: Date(), name: "Trans 2", categoryId: categoryId2),
            Transaction(id: UUID(), accountId: UUID(), amount: -20, date: Date(), name: "Trans 3", categoryId: categoryId1)
        ]
        mockTransactionRepo.transactionsToReturn = transactions

        // When
        await sut.loadTransactions()
        sut.selectedCategoryId = categoryId1

        // Then
        XCTAssertEqual(sut.filteredTransactions.count, 2)
        XCTAssertTrue(sut.filteredTransactions.allSatisfy { $0.categoryId == categoryId1 })
    }

    func testFilteredTransactions_BySearchQuery() async {
        // Given
        let transactions = [
            Transaction(id: UUID(), accountId: UUID(), amount: -50, date: Date(), name: "Starbucks Coffee", merchantName: "Starbucks", categoryId: UUID()),
            Transaction(id: UUID(), accountId: UUID(), amount: -30, date: Date(), name: "Walmart Groceries", merchantName: "Walmart", categoryId: UUID()),
            Transaction(id: UUID(), accountId: UUID(), amount: -20, date: Date(), name: "Dunkin Coffee", merchantName: "Dunkin", categoryId: UUID())
        ]
        mockTransactionRepo.transactionsToReturn = transactions

        // When
        await sut.loadTransactions()
        sut.searchQuery = "coffee"

        // Then
        XCTAssertEqual(sut.filteredTransactions.count, 2)
        XCTAssertTrue(sut.filteredTransactions.allSatisfy {
            $0.name.localizedCaseInsensitiveContains("coffee") ||
            $0.merchantName?.localizedCaseInsensitiveContains("coffee") == true
        })
    }

    func testFilteredTransactions_PendingOnly() async {
        // Given
        let transactions = [
            Transaction(id: UUID(), accountId: UUID(), amount: -50, date: Date(), name: "Pending", categoryId: UUID(), isPending: true),
            Transaction(id: UUID(), accountId: UUID(), amount: -30, date: Date(), name: "Cleared", categoryId: UUID(), isPending: false),
            Transaction(id: UUID(), accountId: UUID(), amount: -20, date: Date(), name: "Also Pending", categoryId: UUID(), isPending: true)
        ]
        mockTransactionRepo.transactionsToReturn = transactions

        // When
        await sut.loadTransactions()
        sut.showPendingOnly = true

        // Then
        XCTAssertEqual(sut.filteredTransactions.count, 2)
        XCTAssertTrue(sut.filteredTransactions.allSatisfy { $0.isPending })
    }

    // MARK: - Total Calculations Tests

    func testTotalIncome_Calculation() async {
        // Given
        let transactions = [
            Transaction(id: UUID(), accountId: UUID(), amount: 1000, date: Date(), name: "Salary", categoryId: UUID()),
            Transaction(id: UUID(), accountId: UUID(), amount: -50, date: Date(), name: "Expense", categoryId: UUID()),
            Transaction(id: UUID(), accountId: UUID(), amount: 200, date: Date(), name: "Bonus", categoryId: UUID())
        ]
        mockTransactionRepo.transactionsToReturn = transactions

        // When
        await sut.loadTransactions()

        // Then
        XCTAssertEqual(sut.totalIncome, 1200)
    }

    func testTotalExpenses_Calculation() async {
        // Given
        let transactions = [
            Transaction(id: UUID(), accountId: UUID(), amount: 1000, date: Date(), name: "Income", categoryId: UUID()),
            Transaction(id: UUID(), accountId: UUID(), amount: -50, date: Date(), name: "Expense 1", categoryId: UUID()),
            Transaction(id: UUID(), accountId: UUID(), amount: -30, date: Date(), name: "Expense 2", categoryId: UUID())
        ]
        mockTransactionRepo.transactionsToReturn = transactions

        // When
        await sut.loadTransactions()

        // Then
        XCTAssertEqual(sut.totalExpenses, 80)
    }

    func testNetAmount_Calculation() async {
        // Given
        let transactions = [
            Transaction(id: UUID(), accountId: UUID(), amount: 1000, date: Date(), name: "Income", categoryId: UUID()),
            Transaction(id: UUID(), accountId: UUID(), amount: -50, date: Date(), name: "Expense 1", categoryId: UUID()),
            Transaction(id: UUID(), accountId: UUID(), amount: -30, date: Date(), name: "Expense 2", categoryId: UUID())
        ]
        mockTransactionRepo.transactionsToReturn = transactions

        // When
        await sut.loadTransactions()

        // Then
        XCTAssertEqual(sut.netAmount, 920) // 1000 - 80
    }

    // MARK: - Date Grouping Tests

    func testTransactionsByDate_GroupsCorrectly() async {
        // Given
        let today = Date()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
        let transactions = [
            Transaction(id: UUID(), accountId: UUID(), amount: -50, date: today, name: "Today 1", categoryId: UUID()),
            Transaction(id: UUID(), accountId: UUID(), amount: -30, date: today, name: "Today 2", categoryId: UUID()),
            Transaction(id: UUID(), accountId: UUID(), amount: -20, date: yesterday, name: "Yesterday", categoryId: UUID())
        ]
        mockTransactionRepo.transactionsToReturn = transactions

        // When
        await sut.loadTransactions()

        // Then
        let grouped = sut.transactionsByDate
        XCTAssertEqual(grouped.count, 2) // Two different dates
        XCTAssertEqual(grouped.first?.1.count, 2) // Today should have 2 transactions
    }

    // MARK: - Date Formatting Tests

    func testFormatDateSection_Today() {
        // Given
        let today = Date()

        // When
        let formatted = sut.formatDateSection(today)

        // Then
        XCTAssertEqual(formatted, "Today")
    }

    func testFormatDateSection_Yesterday() {
        // Given
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!

        // When
        let formatted = sut.formatDateSection(yesterday)

        // Then
        XCTAssertEqual(formatted, "Yesterday")
    }

    // MARK: - Clear Filters Tests

    func testClearFilters_ResetsAllFilters() async {
        // Given
        sut.selectedAccountId = UUID()
        sut.selectedCategoryId = UUID()
        sut.searchQuery = "test"
        sut.showPendingOnly = true

        // When
        sut.clearFilters()

        // Then
        XCTAssertNil(sut.selectedAccountId)
        XCTAssertNil(sut.selectedCategoryId)
        XCTAssertEqual(sut.searchQuery, "")
        XCTAssertFalse(sut.showPendingOnly)
    }
}

// MARK: - Mock Transaction Repository

class MockTransactionRepository: TransactionRepository {
    var transactionsToReturn: [Transaction] = []
    var shouldFail = false
    var didCallSave = false
    var didCallDelete = false

    func fetchAll() async throws -> [Transaction] {
        if shouldFail { throw MockError.genericError }
        return transactionsToReturn
    }

    func fetchById(_ id: UUID) async throws -> Transaction? {
        if shouldFail { throw MockError.genericError }
        return transactionsToReturn.first { $0.id == id }
    }

    func fetchByAccount(_ accountId: UUID) async throws -> [Transaction] {
        if shouldFail { throw MockError.genericError }
        return transactionsToReturn.filter { $0.accountId == accountId }
    }

    func fetchByDateRange(from startDate: Date, to endDate: Date) async throws -> [Transaction] {
        if shouldFail { throw MockError.genericError }
        return transactionsToReturn.filter { $0.date >= startDate && $0.date <= endDate }
    }

    func fetchByCategory(_ categoryId: UUID) async throws -> [Transaction] {
        if shouldFail { throw MockError.genericError }
        return transactionsToReturn.filter { $0.categoryId == categoryId }
    }

    func fetchPending() async throws -> [Transaction] {
        if shouldFail { throw MockError.genericError }
        return transactionsToReturn.filter { $0.isPending }
    }

    func search(query: String) async throws -> [Transaction] {
        if shouldFail { throw MockError.genericError }
        return transactionsToReturn.filter {
            $0.name.localizedCaseInsensitiveContains(query) ||
            $0.merchantName?.localizedCaseInsensitiveContains(query) == true
        }
    }

    func save(_ transaction: Transaction) async throws {
        didCallSave = true
        if shouldFail { throw MockError.genericError }
    }

    func saveAll(_ transactions: [Transaction]) async throws {
        if shouldFail { throw MockError.genericError }
    }

    func delete(_ transaction: Transaction) async throws {
        didCallDelete = true
        if shouldFail { throw MockError.genericError }
    }

    func deleteById(_ id: UUID) async throws {
        if shouldFail { throw MockError.genericError }
    }

    func deleteAll() async throws {
        if shouldFail { throw MockError.genericError }
    }

    func getTotalSpent(from startDate: Date, to endDate: Date) async throws -> Decimal {
        if shouldFail { throw MockError.genericError }
        return 0
    }

    func getTotalIncome(from startDate: Date, to endDate: Date) async throws -> Decimal {
        if shouldFail { throw MockError.genericError }
        return 0
    }

    func getSpendingByCategory(from startDate: Date, to endDate: Date) async throws -> [UUID: Decimal] {
        if shouldFail { throw MockError.genericError }
        return [:]
    }
}

// MARK: - Mock Category Repository

class MockCategoryRepository: CategoryRepository {
    var categoriesToReturn: [Category] = []
    var shouldFail = false

    func fetchAll() async throws -> [Category] {
        if shouldFail { throw MockError.genericError }
        return categoriesToReturn
    }

    func fetchById(_ id: UUID) async throws -> Category? {
        if shouldFail { throw MockError.genericError }
        return categoriesToReturn.first { $0.id == id }
    }

    func fetchByType(_ type: Category.CategoryType) async throws -> [Category] {
        if shouldFail { throw MockError.genericError }
        return categoriesToReturn.filter { $0.type == type }
    }

    func fetchParentCategories() async throws -> [Category] {
        if shouldFail { throw MockError.genericError }
        return categoriesToReturn.filter { $0.parentId == nil }
    }

    func fetchSubcategories(_ parentId: UUID) async throws -> [Category] {
        if shouldFail { throw MockError.genericError }
        return categoriesToReturn.filter { $0.parentId == parentId }
    }

    func fetchActive() async throws -> [Category] {
        if shouldFail { throw MockError.genericError }
        return categoriesToReturn.filter { $0.isActive }
    }

    func save(_ category: Category) async throws {
        if shouldFail { throw MockError.genericError }
    }

    func saveAll(_ categories: [Category]) async throws {
        if shouldFail { throw MockError.genericError }
    }

    func delete(_ category: Category) async throws {
        if shouldFail { throw MockError.genericError }
    }

    func deleteById(_ id: UUID) async throws {
        if shouldFail { throw MockError.genericError }
    }

    func initializeDefaultCategories() async throws {
        if shouldFail { throw MockError.genericError }
    }
}
