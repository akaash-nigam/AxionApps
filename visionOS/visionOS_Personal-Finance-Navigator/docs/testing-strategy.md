# Testing Strategy Document
# Personal Finance Navigator

**Version**: 1.0
**Last Updated**: 2025-11-24
**Status**: Draft

## Table of Contents
1. [Testing Overview](#testing-overview)
2. [Unit Testing](#unit-testing)
3. [Integration Testing](#integration-testing)
4. [UI Testing](#ui-testing)
5. [Performance Testing](#performance-testing)
6. [Security Testing](#security-testing)
7. [Test Data](#test-data)

## Testing Overview

### Testing Pyramid

```
          ┌────────────┐
          │  Manual    │ 5%
          │  Testing   │
        ┌─┴────────────┴─┐
        │   UI Tests     │ 15%
       ┌┴────────────────┴┐
       │ Integration Tests│ 30%
     ┌─┴──────────────────┴─┐
     │    Unit Tests         │ 50%
     └───────────────────────┘
```

### Testing Goals
- **Coverage Target**: 80% code coverage
- **Critical Paths**: 100% coverage for financial calculations
- **Automated**: 95% of tests automated
- **CI/CD**: All tests run on every commit

### Testing Tools
- **XCTest**: Unit and UI testing
- **XCUITest**: UI automation
- **Quick/Nimble**: BDD-style testing (optional)
- **Instruments**: Performance profiling
- **TestFlight**: Beta testing

## Unit Testing

### ViewModel Testing

```swift
// DashboardViewModelTests.swift
import XCTest
@testable import PersonalFinanceNavigator

final class DashboardViewModelTests: XCTestCase {
    var viewModel: DashboardViewModel!
    var mockTransactionRepository: MockTransactionRepository!
    var mockAccountRepository: MockAccountRepository!

    override func setUp() {
        super.setUp()
        mockTransactionRepository = MockTransactionRepository()
        mockAccountRepository = MockAccountRepository()

        viewModel = DashboardViewModel(
            syncTransactionsUseCase: SyncTransactionsUseCase(
                transactionRepository: mockTransactionRepository
            ),
            accountRepository: mockAccountRepository
        )
    }

    override func tearDown() {
        viewModel = nil
        mockTransactionRepository = nil
        mockAccountRepository = nil
        super.tearDown()
    }

    func testLoadData_Success() async throws {
        // Given
        let expectedTransactions = MockData.transactions
        let expectedAccounts = MockData.accounts
        mockTransactionRepository.mockTransactions = expectedTransactions
        mockAccountRepository.mockAccounts = expectedAccounts

        // When
        await viewModel.loadData()

        // Then
        XCTAssertEqual(viewModel.transactions.count, expectedTransactions.count)
        XCTAssertEqual(viewModel.accounts.count, expectedAccounts.count)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.isLoading)
    }

    func testLoadData_Failure() async throws {
        // Given
        mockTransactionRepository.shouldFail = true

        // When
        await viewModel.loadData()

        // Then
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.isLoading)
    }

    func testCalculateTotalBalance() async throws {
        // Given
        mockAccountRepository.mockAccounts = [
            Account(id: UUID(), currentBalance: 1000, ...),
            Account(id: UUID(), currentBalance: 2500, ...),
            Account(id: UUID(), currentBalance: -500, ...)
        ]

        // When
        await viewModel.loadData()

        // Then
        XCTAssertEqual(viewModel.totalBalance, 3000)
    }
}
```

### Use Case Testing

```swift
// CalculateBudgetStatusUseCaseTests.swift
final class CalculateBudgetStatusUseCaseTests: XCTestCase {
    var useCase: CalculateBudgetStatusUseCase!
    var mockBudgetRepository: MockBudgetRepository!

    override func setUp() {
        super.setUp()
        mockBudgetRepository = MockBudgetRepository()
        useCase = CalculateBudgetStatusUseCase(
            budgetRepository: mockBudgetRepository
        )
    }

    func testCalculateStatus_UnderBudget() async throws {
        // Given
        let budget = Budget(
            id: UUID(),
            totalAllocated: 3000,
            categories: [
                BudgetCategory(allocated: 1000, spent: 500, ...),
                BudgetCategory(allocated: 500, spent: 200, ...)
            ]
        )

        // When
        let status = try await useCase.execute(for: budget)

        // Then
        XCTAssertEqual(status.totalSpent, 700)
        XCTAssertEqual(status.remaining, 2300)
        XCTAssertFalse(status.isOverBudget)
    }

    func testCalculateStatus_OverBudget() async throws {
        // Given
        let budget = Budget(
            id: UUID(),
            totalAllocated: 1000,
            categories: [
                BudgetCategory(allocated: 500, spent: 700, ...)
            ]
        )

        // When
        let status = try await useCase.execute(for: budget)

        // Then
        XCTAssertTrue(status.isOverBudget)
        XCTAssertEqual(status.categoriesOverBudget.count, 1)
    }
}
```

### Repository Testing

```swift
// TransactionRepositoryTests.swift
final class TransactionRepositoryTests: XCTestCase {
    var repository: CoreDataTransactionRepository!
    var persistenceController: PersistenceController!

    override func setUp() {
        super.setUp()
        // Use in-memory store for testing
        persistenceController = PersistenceController(inMemory: true)
        repository = CoreDataTransactionRepository(
            context: persistenceController.container.viewContext
        )
    }

    func testSaveTransaction() async throws {
        // Given
        let transaction = Transaction(
            id: UUID(),
            amount: -50.00,
            date: Date(),
            name: "Test Transaction",
            ...
        )

        // When
        try await repository.save(transaction)

        // Then
        let fetched = try await repository.fetch(by: transaction.id)
        XCTAssertNotNil(fetched)
        XCTAssertEqual(fetched?.amount, transaction.amount)
    }

    func testFetchRecent() async throws {
        // Given
        let transactions = MockData.transactions
        for transaction in transactions {
            try await repository.save(transaction)
        }

        // When
        let recent = try await repository.fetchRecent(limit: 10)

        // Then
        XCTAssertEqual(recent.count, min(10, transactions.count))
        // Verify sorted by date descending
        XCTAssertTrue(recent[0].date >= recent[1].date)
    }

    func testDelete() async throws {
        // Given
        let transaction = Transaction(id: UUID(), ...)
        try await repository.save(transaction)

        // When
        try await repository.delete(transaction)

        // Then
        let fetched = try await repository.fetch(by: transaction.id)
        XCTAssertNil(fetched)
    }
}
```

### Financial Calculation Testing

```swift
// AmortizationCalculatorTests.swift
final class AmortizationCalculatorTests: XCTestCase {
    var calculator: AmortizationCalculator!

    override func setUp() {
        super.setUp()
        calculator = AmortizationCalculator()
    }

    func testCalculateMonthlyPayment() {
        // Given: $10,000 loan at 5% APR for 12 months
        let principal: Decimal = 10_000
        let annualRate: Decimal = 0.05
        let months = 12

        // When
        let payment = calculator.calculateMonthlyPayment(
            principal: principal,
            annualRate: annualRate,
            months: months
        )

        // Then
        // Expected: ~$856.07
        XCTAssertEqual(payment, 856.07, accuracy: 0.01)
    }

    func testGenerateAmortizationSchedule() {
        // Given
        let principal: Decimal = 10_000
        let annualRate: Decimal = 0.05
        let months = 12

        // When
        let schedule = calculator.generateSchedule(
            principal: principal,
            annualRate: annualRate,
            months: months
        )

        // Then
        XCTAssertEqual(schedule.count, 12)

        // First payment
        XCTAssertEqual(schedule[0].principalAmount, 814.41, accuracy: 0.01)
        XCTAssertEqual(schedule[0].interestAmount, 41.67, accuracy: 0.01)

        // Last payment
        XCTAssertEqual(schedule[11].balance, 0, accuracy: 0.01)

        // Total interest paid
        let totalInterest = schedule.reduce(0) { $0 + $1.interestAmount }
        XCTAssertEqual(totalInterest, 272.90, accuracy: 0.01)
    }
}
```

## Integration Testing

### API Integration Tests

```swift
// PlaidIntegrationTests.swift
final class PlaidIntegrationTests: XCTestCase {
    var plaidService: PlaidService!
    var mockAPIClient: MockPlaidAPIClient!

    override func setUp() {
        super.setUp()
        mockAPIClient = MockPlaidAPIClient()
        plaidService = PlaidService(apiClient: mockAPIClient)
    }

    func testSyncTransactions_Success() async throws {
        // Given
        mockAPIClient.mockTransactions = MockData.plaidTransactions

        // When
        let transactions = try await plaidService.syncTransactions(
            for: "test_item_id"
        )

        // Then
        XCTAssertEqual(transactions.count, MockData.plaidTransactions.count)
        XCTAssertTrue(mockAPIClient.syncWasCalled)
    }

    func testSyncTransactions_NetworkError() async throws {
        // Given
        mockAPIClient.shouldFail = true

        // When/Then
        await XCTAssertThrowsError(
            try await plaidService.syncTransactions(for: "test_item_id")
        ) { error in
            XCTAssertTrue(error is NetworkError)
        }
    }
}
```

### Core Data Integration Tests

```swift
// CoreDataIntegrationTests.swift
final class CoreDataIntegrationTests: XCTestCase {
    var persistenceController: PersistenceController!

    override func setUp() {
        super.setUp()
        persistenceController = PersistenceController(inMemory: true)
    }

    func testCoreDataStack() {
        XCTAssertNotNil(persistenceController.container)
        XCTAssertNotNil(persistenceController.container.viewContext)
    }

    func testTransactionWithRelationships() async throws {
        let context = persistenceController.container.viewContext

        // Create account
        let account = AccountEntity(context: context)
        account.id = UUID()
        account.name = "Test Account"

        // Create category
        let category = CategoryEntity(context: context)
        category.id = UUID()
        category.name = "Food"

        // Create transaction
        let transaction = TransactionEntity(context: context)
        transaction.id = UUID()
        transaction.amount = -50.00
        transaction.account = account
        transaction.category = category

        // Save
        try context.save()

        // Fetch and verify relationships
        let fetchRequest: NSFetchRequest<TransactionEntity> = TransactionEntity.fetchRequest()
        let results = try context.fetch(fetchRequest)

        XCTAssertEqual(results.count, 1)
        XCTAssertNotNil(results[0].account)
        XCTAssertNotNil(results[0].category)
        XCTAssertEqual(results[0].account?.name, "Test Account")
    }
}
```

## UI Testing

### Navigation Tests

```swift
// NavigationUITests.swift
final class NavigationUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["--uitesting"]
        app.launch()
    }

    func testNavigateToBudget() {
        // Given
        let budgetButton = app.buttons["Budget"]

        // When
        budgetButton.tap()

        // Then
        XCTAssertTrue(app.navigationBars["Budget"].exists)
    }

    func testNavigateToTransactionDetail() {
        // Given
        let transactionsList = app.scrollViews["TransactionsList"]
        let firstTransaction = transactionsList.buttons.firstMatch

        // When
        firstTransaction.tap()

        // Then
        XCTAssertTrue(app.navigationBars["Transaction Detail"].exists)
    }
}
```

### User Flow Tests

```swift
// BudgetCreationFlowTests.swift
final class BudgetCreationFlowTests: XCTestCase {
    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        app = XCUIApplication()
        app.launchArguments = ["--uitesting", "--reset-data"]
        app.launch()
    }

    func testCreateBudgetFlow() {
        // Navigate to budget screen
        app.buttons["Budget"].tap()

        // Tap create budget
        app.buttons["Create Budget"].tap()

        // Enter income
        let incomeField = app.textFields["Monthly Income"]
        incomeField.tap()
        incomeField.typeText("5000")

        // Select strategy
        app.buttons["50/30/20 Rule"].tap()

        // Save
        app.buttons["Create"].tap()

        // Verify budget was created
        XCTAssertTrue(app.staticTexts["$5,000.00"].exists)
    }
}
```

## Performance Testing

### Performance Metrics

```swift
// PerformanceTests.swift
final class PerformanceTests: XCTestCase {
    func testTransactionLoadPerformance() {
        let repository = CoreDataTransactionRepository(...)

        measure {
            // Load 1000 transactions
            _ = try? await repository.fetchAll()
        }

        // Expected: < 0.5 seconds
    }

    func testBudgetCalculationPerformance() {
        let useCase = CalculateBudgetStatusUseCase(...)
        let budget = Budget(with: 20 categories)

        measure {
            _ = try? await useCase.execute(for: budget)
        }

        // Expected: < 0.1 seconds
    }

    func testRealityKitRenderPerformance() {
        let scene = MoneyFlowScene()

        measure {
            // Render frame with 1000 particles
            scene.update(deltaTime: 1.0/60.0)
        }

        // Expected: < 16ms (60fps)
    }
}
```

### Memory Leak Detection

```swift
func testViewModelDoesNotLeak() {
    weak var weakViewModel: DashboardViewModel?

    autoreleasepool {
        let viewModel = DashboardViewModel(...)
        weakViewModel = viewModel

        // Use viewModel
        Task {
            await viewModel.loadData()
        }
    }

    // ViewModel should be deallocated
    XCTAssertNil(weakViewModel)
}
```

## Security Testing

### Encryption Tests

```swift
// EncryptionTests.swift
final class EncryptionTests: XCTestCase {
    var encryptionManager: EncryptionManager!

    override func setUp() async {
        super.setUp()
        encryptionManager = EncryptionManager()
    }

    func testEncryptDecrypt() async throws {
        // Given
        let plaintext = "Sensitive financial data"

        // When
        let encrypted = try await encryptionManager.encrypt(plaintext)
        let decrypted = try await encryptionManager.decrypt(encrypted)

        // Then
        XCTAssertNotEqual(String(data: encrypted, encoding: .utf8), plaintext)
        XCTAssertEqual(decrypted, plaintext)
    }

    func testEncryptedDataIsDifferent() async throws {
        // Same plaintext should produce different ciphertext (due to IV)
        let plaintext = "Test data"

        let encrypted1 = try await encryptionManager.encrypt(plaintext)
        let encrypted2 = try await encryptionManager.encrypt(plaintext)

        XCTAssertNotEqual(encrypted1, encrypted2)
    }
}
```

### Authentication Tests

```swift
// AuthenticationTests.swift
final class AuthenticationTests: XCTestCase {
    func testBiometricAuthenticationRequired() {
        let authManager = BiometricAuthManager()

        XCTAssertTrue(authManager.requiresAuthentication)
    }

    func testAutoLock() async {
        let lockManager = AutoLockManager(lockTimeout: 1.0)

        // Wait for auto-lock
        try? await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 seconds

        // Should be locked
        // Verify through notification or state
    }
}
```

## Test Data

### Mock Data Factory

```swift
// MockDataFactory.swift
struct MockDataFactory {
    static func createAccount(
        balance: Decimal = 1000,
        type: AccountType = .checking
    ) -> Account {
        Account(
            id: UUID(),
            plaidAccountId: "mock_\(UUID().uuidString)",
            name: "Test \(type.rawValue.capitalized)",
            type: type,
            currentBalance: balance,
            isActive: true,
            createdAt: Date()
        )
    }

    static func createTransaction(
        amount: Decimal = -50,
        date: Date = Date(),
        category: String = "Food & Drink"
    ) -> Transaction {
        Transaction(
            id: UUID(),
            accountId: UUID(),
            amount: amount,
            date: date,
            name: "Test Transaction",
            primaryCategory: category,
            createdAt: Date()
        )
    }

    static func createBudget(
        income: Decimal = 5000,
        strategy: BudgetStrategy = .fiftyThirtyTwenty
    ) -> Budget {
        let categories = createBudgetCategories(for: income, strategy: strategy)

        return Budget(
            id: UUID(),
            name: "Test Budget",
            type: .monthly,
            startDate: Date(),
            endDate: Date().addingTimeInterval(2592000), // 30 days
            totalIncome: income,
            totalAllocated: income,
            totalSpent: 0,
            isActive: true,
            strategy: strategy,
            categories: categories,
            createdAt: Date()
        )
    }

    private static func createBudgetCategories(
        for income: Decimal,
        strategy: BudgetStrategy
    ) -> [BudgetCategory] {
        // Implement based on strategy
        []
    }
}
```

### Test Fixtures

```swift
// TestFixtures.swift
enum TestFixtures {
    static let sampleTransactions: [Transaction] = [
        MockDataFactory.createTransaction(amount: -45.67, category: "Groceries"),
        MockDataFactory.createTransaction(amount: -120.00, category: "Gas"),
        MockDataFactory.createTransaction(amount: 3000.00, category: "Salary"),
        MockDataFactory.createTransaction(amount: -15.99, category: "Streaming")
    ]

    static let sampleAccounts: [Account] = [
        MockDataFactory.createAccount(balance: 5432.10, type: .checking),
        MockDataFactory.createAccount(balance: 15000.00, type: .savings),
        MockDataFactory.createAccount(balance: -2150.50, type: .creditCard)
    ]
}
```

---

**Document Status**: Ready for Implementation
**Next Steps**: Performance & Optimization Plan
