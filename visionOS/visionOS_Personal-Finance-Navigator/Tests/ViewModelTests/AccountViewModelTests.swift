// AccountViewModelTests.swift
// Personal Finance Navigator Tests
// Unit tests for AccountViewModel

import XCTest
@testable import PersonalFinanceNavigator

@MainActor
final class AccountViewModelTests: XCTestCase {
    var sut: AccountViewModel!
    var mockRepository: MockAccountRepository!

    override func setUp() {
        super.setUp()
        mockRepository = MockAccountRepository()
        sut = AccountViewModel(repository: mockRepository)
    }

    override func tearDown() {
        sut = nil
        mockRepository = nil
        super.tearDown()
    }

    // MARK: - Load Accounts Tests

    func testLoadAccounts_Success() async {
        // Given
        let expectedAccounts = [
            Account(name: "Checking", type: .checking, currentBalance: 1000),
            Account(name: "Savings", type: .savings, currentBalance: 5000)
        ]
        mockRepository.accountsToReturn = expectedAccounts

        // When
        await sut.loadAccounts()

        // Then
        XCTAssertEqual(sut.accounts.count, 2)
        XCTAssertEqual(sut.activeAccounts.count, 2)
        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(sut.errorMessage)
    }

    func testLoadAccounts_Failure() async {
        // Given
        mockRepository.shouldFail = true

        // When
        await sut.loadAccounts()

        // Then
        XCTAssertTrue(sut.accounts.isEmpty)
        XCTAssertNotNil(sut.errorMessage)
        XCTAssertFalse(sut.isLoading)
    }

    func testLoadAccounts_FiltersInactiveAccounts() async {
        // Given
        let accounts = [
            Account(name: "Active", type: .checking, currentBalance: 1000, isActive: true),
            Account(name: "Inactive", type: .savings, currentBalance: 5000, isActive: false),
            Account(name: "Hidden", type: .creditCard, currentBalance: 500, isHidden: true)
        ]
        mockRepository.accountsToReturn = accounts

        // When
        await sut.loadAccounts()

        // Then
        XCTAssertEqual(sut.accounts.count, 3)
        XCTAssertEqual(sut.activeAccounts.count, 1) // Only active and not hidden
        XCTAssertEqual(sut.activeAccounts.first?.name, "Active")
    }

    // MARK: - Add Account Tests

    func testAddAccount_Success() async {
        // Given
        let newAccount = Account(name: "New Checking", type: .checking, currentBalance: 2000)

        // When
        let result = await sut.addAccount(newAccount)

        // Then
        XCTAssertTrue(result)
        XCTAssertTrue(mockRepository.didCallSave)
        XCTAssertNil(sut.errorMessage)
    }

    func testAddAccount_Failure() async {
        // Given
        mockRepository.shouldFail = true
        let newAccount = Account(name: "New Checking", type: .checking, currentBalance: 2000)

        // When
        let result = await sut.addAccount(newAccount)

        // Then
        XCTAssertFalse(result)
        XCTAssertNotNil(sut.errorMessage)
    }

    // MARK: - Update Account Tests

    func testUpdateAccount_Success() async {
        // Given
        let account = Account(name: "Updated", type: .checking, currentBalance: 3000)

        // When
        let result = await sut.updateAccount(account)

        // Then
        XCTAssertTrue(result)
        XCTAssertTrue(mockRepository.didCallSave)
    }

    // MARK: - Delete Account Tests

    func testDeleteAccount_Success() async {
        // Given
        let account = Account(name: "To Delete", type: .checking, currentBalance: 1000)

        // When
        let result = await sut.deleteAccount(account)

        // Then
        XCTAssertTrue(result)
        XCTAssertTrue(mockRepository.didCallDelete)
    }

    // MARK: - Net Worth Tests

    func testTotalNetWorth_Calculation() async {
        // Given
        let accounts = [
            Account(name: "Checking", type: .checking, currentBalance: 1000),
            Account(name: "Savings", type: .savings, currentBalance: 5000),
            Account(name: "Credit Card", type: .creditCard, currentBalance: 500), // Debt
            Account(name: "Investment", type: .investment, currentBalance: 10000)
        ]
        mockRepository.accountsToReturn = accounts

        // When
        await sut.loadAccounts()

        // Then
        // 1000 + 5000 - 500 + 10000 = 15500
        XCTAssertEqual(sut.totalNetWorth, 15500)
    }

    func testTotalNetWorth_EmptyAccounts() async {
        // Given
        mockRepository.accountsToReturn = []

        // When
        await sut.loadAccounts()

        // Then
        XCTAssertEqual(sut.totalNetWorth, 0)
    }

    // MARK: - Accounts By Type Tests

    func testAccountsByType_GroupsCorrectly() async {
        // Given
        let accounts = [
            Account(name: "Checking 1", type: .checking, currentBalance: 1000),
            Account(name: "Checking 2", type: .checking, currentBalance: 2000),
            Account(name: "Savings 1", type: .savings, currentBalance: 5000),
            Account(name: "Credit 1", type: .creditCard, currentBalance: 500)
        ]
        mockRepository.accountsToReturn = accounts

        // When
        await sut.loadAccounts()

        // Then
        XCTAssertEqual(sut.accountsByType[.checking]?.count, 2)
        XCTAssertEqual(sut.accountsByType[.savings]?.count, 1)
        XCTAssertEqual(sut.accountsByType[.creditCard]?.count, 1)
        XCTAssertNil(sut.accountsByType[.investment])
    }

    // MARK: - Format Tests

    func testGetFormattedNetWorth_USD() {
        // Given
        let accounts = [Account(name: "Test", type: .checking, currentBalance: 12345.67)]
        mockRepository.accountsToReturn = accounts

        // When
        Task {
            await sut.loadAccounts()
            let formatted = sut.getFormattedNetWorth(currencyCode: "USD")

            // Then
            XCTAssertTrue(formatted.contains("12,345.67") || formatted.contains("12345.67"))
            XCTAssertTrue(formatted.contains("$"))
        }
    }

    func testGetFormattedBalance_USD() {
        // Given
        let amount: Decimal = 9876.54

        // When
        let formatted = sut.getFormattedBalance(amount, currencyCode: "USD")

        // Then
        XCTAssertTrue(formatted.contains("9,876.54") || formatted.contains("9876.54"))
        XCTAssertTrue(formatted.contains("$"))
    }

    // MARK: - Balance Update Tests

    func testUpdateBalance_Success() async {
        // Given
        let accountId = UUID()
        let newBalance: Decimal = 5000
        let availableBalance: Decimal = 4500

        // When
        let result = await sut.updateBalance(for: accountId, current: newBalance, available: availableBalance)

        // Then
        XCTAssertTrue(result)
        XCTAssertTrue(mockRepository.didCallUpdateBalance)
    }
}

// MARK: - Mock Repository

class MockAccountRepository: AccountRepository {
    var accountsToReturn: [Account] = []
    var shouldFail = false
    var didCallSave = false
    var didCallDelete = false
    var didCallUpdateBalance = false

    func fetchAll() async throws -> [Account] {
        if shouldFail {
            throw MockError.genericError
        }
        return accountsToReturn
    }

    func fetchById(_ id: UUID) async throws -> Account? {
        if shouldFail {
            throw MockError.genericError
        }
        return accountsToReturn.first { $0.id == id }
    }

    func fetchActive() async throws -> [Account] {
        if shouldFail {
            throw MockError.genericError
        }
        return accountsToReturn.filter { $0.isActive && !$0.isHidden }
    }

    func fetchByType(_ type: Account.AccountType) async throws -> [Account] {
        if shouldFail {
            throw MockError.genericError
        }
        return accountsToReturn.filter { $0.type == type }
    }

    func fetchNeedingReconnection() async throws -> [Account] {
        if shouldFail {
            throw MockError.genericError
        }
        return accountsToReturn.filter { $0.needsReconnection }
    }

    func save(_ account: Account) async throws {
        didCallSave = true
        if shouldFail {
            throw MockError.genericError
        }
    }

    func saveAll(_ accounts: [Account]) async throws {
        if shouldFail {
            throw MockError.genericError
        }
    }

    func delete(_ account: Account) async throws {
        didCallDelete = true
        if shouldFail {
            throw MockError.genericError
        }
    }

    func deleteById(_ id: UUID) async throws {
        if shouldFail {
            throw MockError.genericError
        }
    }

    func updateBalance(_ accountId: UUID, current: Decimal, available: Decimal?) async throws {
        didCallUpdateBalance = true
        if shouldFail {
            throw MockError.genericError
        }
    }

    func markNeedsReconnection(_ accountId: UUID) async throws {
        if shouldFail {
            throw MockError.genericError
        }
    }

    func updateSyncDate(_ accountId: UUID, date: Date) async throws {
        if shouldFail {
            throw MockError.genericError
        }
    }

    func getTotalNetWorth() async throws -> Decimal {
        if shouldFail {
            throw MockError.genericError
        }
        return accountsToReturn.reduce(Decimal.zero) { total, account in
            if account.type == .creditCard {
                return total - account.currentBalance
            } else {
                return total + account.currentBalance
            }
        }
    }
}

enum MockError: Error {
    case genericError
}
