// BudgetViewModelTests.swift
// Personal Finance Navigator Tests
// Unit tests for BudgetViewModel

import XCTest
@testable import PersonalFinanceNavigator

@MainActor
final class BudgetViewModelTests: XCTestCase {
    var sut: BudgetViewModel!
    var mockBudgetRepo: MockBudgetRepository!
    var mockTransactionRepo: MockTransactionRepository!
    var mockCategoryRepo: MockCategoryRepository!

    override func setUp() {
        super.setUp()
        mockBudgetRepo = MockBudgetRepository()
        mockTransactionRepo = MockTransactionRepository()
        mockCategoryRepo = MockCategoryRepository()
        sut = BudgetViewModel(
            budgetRepository: mockBudgetRepo,
            transactionRepository: mockTransactionRepo,
            categoryRepository: mockCategoryRepo
        )
    }

    override func tearDown() {
        sut = nil
        mockBudgetRepo = nil
        mockTransactionRepo = nil
        mockCategoryRepo = nil
        super.tearDown()
    }

    // MARK: - Load Budgets Tests

    func testLoadBudgets_Success() async {
        // Given
        let budgets = [
            createTestBudget(name: "January"),
            createTestBudget(name: "February")
        ]
        mockBudgetRepo.budgetsToReturn = budgets
        mockBudgetRepo.activeBudgetToReturn = budgets.first

        // When
        await sut.loadBudgets()

        // Then
        XCTAssertEqual(sut.budgets.count, 2)
        XCTAssertNotNil(sut.activeBudget)
        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(sut.errorMessage)
    }

    func testLoadBudgets_Failure() async {
        // Given
        mockBudgetRepo.shouldFail = true

        // When
        await sut.loadBudgets()

        // Then
        XCTAssertTrue(sut.budgets.isEmpty)
        XCTAssertNil(sut.activeBudget)
        XCTAssertNotNil(sut.errorMessage)
    }

    func testHasBudgets_ReturnsTrueWhenBudgetsExist() async {
        // Given
        mockBudgetRepo.budgetsToReturn = [createTestBudget(name: "Test")]

        // When
        await sut.loadBudgets()

        // Then
        XCTAssertTrue(sut.hasBudgets)
    }

    func testHasBudgets_ReturnsFalseWhenNoBudgets() async {
        // Given
        mockBudgetRepo.budgetsToReturn = []

        // When
        await sut.loadBudgets()

        // Then
        XCTAssertFalse(sut.hasBudgets)
    }

    // MARK: - Create Budget Tests

    func testCreateBudget_Success() async {
        // Given
        let budget = createTestBudget(name: "New Budget")

        // When
        let result = await sut.createBudget(budget)

        // Then
        XCTAssertTrue(result)
        XCTAssertTrue(mockBudgetRepo.didCallSave)
        XCTAssertNil(sut.errorMessage)
    }

    func testCreateBudget_Failure() async {
        // Given
        mockBudgetRepo.shouldFail = true
        let budget = createTestBudget(name: "New Budget")

        // When
        let result = await sut.createBudget(budget)

        // Then
        XCTAssertFalse(result)
        XCTAssertNotNil(sut.errorMessage)
    }

    // MARK: - Budget Progress Tests

    func testActiveBudgetProgress_CalculatesCorrectly() async {
        // Given
        let categories = [
            BudgetCategory(
                id: UUID(),
                budgetId: UUID(),
                categoryId: UUID(),
                categoryName: "Food",
                allocated: 500,
                spent: 350,
                percentageOfBudget: 70,
                isRollover: false,
                rolledAmount: nil,
                alertAt75: true,
                alertAt90: true,
                alertAt100: true,
                alertOnOverspend: true
            ),
            BudgetCategory(
                id: UUID(),
                budgetId: UUID(),
                categoryId: UUID(),
                categoryName: "Transport",
                allocated: 300,
                spent: 150,
                percentageOfBudget: 50,
                isRollover: false,
                rolledAmount: nil,
                alertAt75: true,
                alertAt90: true,
                alertAt100: true,
                alertOnOverspend: true
            )
        ]

        let budget = Budget(
            id: UUID(),
            name: "Test Budget",
            startDate: Date(),
            endDate: Date(),
            totalAmount: 800,
            strategy: .fiftyThirtyTwenty,
            categories: categories
        )

        mockBudgetRepo.budgetsToReturn = [budget]
        mockBudgetRepo.activeBudgetToReturn = budget

        // When
        await sut.loadBudgets()

        // Then
        let progress = sut.activeBudgetProgress
        XCTAssertNotNil(progress)
        XCTAssertEqual(progress?.spent, 500) // 350 + 150
        XCTAssertEqual(progress?.allocated, 800) // 500 + 300
        XCTAssertEqual(progress?.percentage, 62.5, accuracy: 0.1) // 500/800 * 100
    }

    func testIsOverBudget_ReturnsTrueWhenOverBudget() async {
        // Given
        let categories = [
            BudgetCategory(
                id: UUID(),
                budgetId: UUID(),
                categoryId: UUID(),
                categoryName: "Food",
                allocated: 100,
                spent: 150,
                percentageOfBudget: 150,
                isRollover: false,
                rolledAmount: nil,
                alertAt75: true,
                alertAt90: true,
                alertAt100: true,
                alertOnOverspend: true
            )
        ]

        let budget = Budget(
            id: UUID(),
            name: "Over Budget",
            startDate: Date(),
            endDate: Date(),
            totalAmount: 100,
            strategy: .fiftyThirtyTwenty,
            categories: categories
        )

        mockBudgetRepo.budgetsToReturn = [budget]
        mockBudgetRepo.activeBudgetToReturn = budget

        // When
        await sut.loadBudgets()

        // Then
        XCTAssertTrue(sut.isOverBudget)
    }

    func testIsOverBudget_ReturnsFalseWhenUnderBudget() async {
        // Given
        let categories = [
            BudgetCategory(
                id: UUID(),
                budgetId: UUID(),
                categoryId: UUID(),
                categoryName: "Food",
                allocated: 100,
                spent: 50,
                percentageOfBudget: 50,
                isRollover: false,
                rolledAmount: nil,
                alertAt75: true,
                alertAt90: true,
                alertAt100: true,
                alertOnOverspend: true
            )
        ]

        let budget = Budget(
            id: UUID(),
            name: "Under Budget",
            startDate: Date(),
            endDate: Date(),
            totalAmount: 100,
            strategy: .fiftyThirtyTwenty,
            categories: categories
        )

        mockBudgetRepo.budgetsToReturn = [budget]
        mockBudgetRepo.activeBudgetToReturn = budget

        // When
        await sut.loadBudgets()

        // Then
        XCTAssertFalse(sut.isOverBudget)
    }

    // MARK: - Budget Status Color Tests

    func testBudgetStatusColor_Green_WhenUnder75Percent() async {
        // Given
        let budget = createBudgetWithSpentPercentage(50)
        mockBudgetRepo.budgetsToReturn = [budget]
        mockBudgetRepo.activeBudgetToReturn = budget

        // When
        await sut.loadBudgets()

        // Then
        XCTAssertEqual(sut.budgetStatusColor, .green)
    }

    func testBudgetStatusColor_Yellow_When75To89Percent() async {
        // Given
        let budget = createBudgetWithSpentPercentage(80)
        mockBudgetRepo.budgetsToReturn = [budget]
        mockBudgetRepo.activeBudgetToReturn = budget

        // When
        await sut.loadBudgets()

        // Then
        XCTAssertEqual(sut.budgetStatusColor, .yellow)
    }

    func testBudgetStatusColor_Orange_When90To99Percent() async {
        // Given
        let budget = createBudgetWithSpentPercentage(95)
        mockBudgetRepo.budgetsToReturn = [budget]
        mockBudgetRepo.activeBudgetToReturn = budget

        // When
        await sut.loadBudgets()

        // Then
        XCTAssertEqual(sut.budgetStatusColor, .orange)
    }

    func testBudgetStatusColor_Red_When100PercentOrMore() async {
        // Given
        let budget = createBudgetWithSpentPercentage(105)
        mockBudgetRepo.budgetsToReturn = [budget]
        mockBudgetRepo.activeBudgetToReturn = budget

        // When
        await sut.loadBudgets()

        // Then
        XCTAssertEqual(sut.budgetStatusColor, .red)
    }

    // MARK: - Budget Suggestions Tests

    func testSuggestBudgetAmounts_FiftyThirtyTwenty() {
        // Given
        let income: Decimal = 5000

        // When
        let suggestions = sut.suggestBudgetAmounts(based: income, strategy: .fiftyThirtyTwenty)

        // Then
        XCTAssertEqual(suggestions["Needs"], 2500)
        XCTAssertEqual(suggestions["Wants"], 1500)
        XCTAssertEqual(suggestions["Savings"], 1000)
    }

    func testSuggestBudgetAmounts_PercentageBased() {
        // Given
        let income: Decimal = 6000

        // When
        let suggestions = sut.suggestBudgetAmounts(based: income, strategy: .percentageBased)

        // Then
        XCTAssertEqual(suggestions["Housing"], 1800) // 30%
        XCTAssertEqual(suggestions["Transportation"], 900) // 15%
        XCTAssertEqual(suggestions["Food"], 900) // 15%
        XCTAssertEqual(suggestions["Utilities"], 600) // 10%
        XCTAssertEqual(suggestions["Savings"], 600) // 10%
    }

    // MARK: - Helper Methods Tests

    func testGetRemainingAmount_PositiveWhenUnderBudget() {
        // Given
        let allocated: Decimal = 500
        let spent: Decimal = 300

        // When
        let remaining = sut.getRemainingAmount(allocated: allocated, spent: spent)

        // Then
        XCTAssertEqual(remaining, 200)
    }

    func testGetRemainingAmount_ZeroWhenOverBudget() {
        // Given
        let allocated: Decimal = 500
        let spent: Decimal = 600

        // When
        let remaining = sut.getRemainingAmount(allocated: allocated, spent: spent)

        // Then
        XCTAssertEqual(remaining, 0)
    }

    func testGetOverspendAmount_ZeroWhenUnderBudget() {
        // Given
        let allocated: Decimal = 500
        let spent: Decimal = 300

        // When
        let overspend = sut.getOverspendAmount(allocated: allocated, spent: spent)

        // Then
        XCTAssertEqual(overspend, 0)
    }

    func testGetOverspendAmount_PositiveWhenOverBudget() {
        // Given
        let allocated: Decimal = 500
        let spent: Decimal = 600

        // When
        let overspend = sut.getOverspendAmount(allocated: allocated, spent: spent)

        // Then
        XCTAssertEqual(overspend, 100)
    }

    // MARK: - Format Tests

    func testFormatPercentage() {
        // Given
        let percentage = 75.5

        // When
        let formatted = sut.formatPercentage(percentage)

        // Then
        XCTAssertTrue(formatted.contains("75") || formatted.contains("76"))
        XCTAssertTrue(formatted.contains("%"))
    }

    // MARK: - Helper Methods

    private func createTestBudget(name: String) -> Budget {
        Budget(
            id: UUID(),
            name: name,
            startDate: Date(),
            endDate: Calendar.current.date(byAdding: .month, value: 1, to: Date())!,
            totalAmount: 1000,
            strategy: .fiftyThirtyTwenty,
            categories: []
        )
    }

    private func createBudgetWithSpentPercentage(_ percentage: Double) -> Budget {
        let allocated: Decimal = 1000
        let spent = allocated * Decimal(percentage / 100)

        let category = BudgetCategory(
            id: UUID(),
            budgetId: UUID(),
            categoryId: UUID(),
            categoryName: "Test",
            allocated: allocated,
            spent: spent,
            percentageOfBudget: percentage,
            isRollover: false,
            rolledAmount: nil,
            alertAt75: true,
            alertAt90: true,
            alertAt100: true,
            alertOnOverspend: true
        )

        return Budget(
            id: UUID(),
            name: "Test Budget",
            startDate: Date(),
            endDate: Date(),
            totalAmount: allocated,
            strategy: .fiftyThirtyTwenty,
            categories: [category]
        )
    }
}

// MARK: - Mock Budget Repository

class MockBudgetRepository: BudgetRepository {
    var budgetsToReturn: [Budget] = []
    var activeBudgetToReturn: Budget?
    var shouldFail = false
    var didCallSave = false
    var didCallDelete = false

    func fetchAll() async throws -> [Budget] {
        if shouldFail { throw MockError.genericError }
        return budgetsToReturn
    }

    func fetchById(_ id: UUID) async throws -> Budget? {
        if shouldFail { throw MockError.genericError }
        return budgetsToReturn.first { $0.id == id }
    }

    func fetchActive() async throws -> Budget? {
        if shouldFail { throw MockError.genericError }
        return activeBudgetToReturn
    }

    func fetchByDateRange(from startDate: Date, to endDate: Date) async throws -> [Budget] {
        if shouldFail { throw MockError.genericError }
        return budgetsToReturn
    }

    func save(_ budget: Budget) async throws {
        didCallSave = true
        if shouldFail { throw MockError.genericError }
    }

    func delete(_ budget: Budget) async throws {
        didCallDelete = true
        if shouldFail { throw MockError.genericError }
    }

    func deleteById(_ id: UUID) async throws {
        if shouldFail { throw MockError.genericError }
    }

    func updateCategorySpent(_ budgetId: UUID, categoryId: UUID, spent: Decimal) async throws {
        if shouldFail { throw MockError.genericError }
    }

    func getBudgetProgress(_ budgetId: UUID) async throws -> (spent: Decimal, allocated: Decimal, percentage: Double) {
        if shouldFail { throw MockError.genericError }
        return (0, 0, 0)
    }

    func getCategoryProgress(_ budgetId: UUID, categoryId: UUID) async throws -> (spent: Decimal, allocated: Decimal, percentage: Double) {
        if shouldFail { throw MockError.genericError }
        return (0, 0, 0)
    }
}
