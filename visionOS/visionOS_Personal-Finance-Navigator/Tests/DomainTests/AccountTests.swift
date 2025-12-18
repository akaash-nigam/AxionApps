// AccountTests.swift
// Personal Finance Navigator Tests
// Unit tests for Account domain model

import XCTest
@testable import PersonalFinanceNavigator

final class AccountTests: XCTestCase {

    // MARK: - Initialization Tests

    func testAccountInitialization_WithRequiredFields() {
        // Given
        let name = "Test Checking"
        let type = Account.AccountType.checking
        let balance: Decimal = 1000.00

        // When
        let account = Account(name: name, type: type, currentBalance: balance)

        // Then
        XCTAssertEqual(account.name, name)
        XCTAssertEqual(account.type, type)
        XCTAssertEqual(account.currentBalance, balance)
        XCTAssertTrue(account.isActive)
        XCTAssertFalse(account.isHidden)
        XCTAssertFalse(account.needsReconnection)
    }

    func testAccountInitialization_WithOptionalFields() {
        // Given
        let institutionName = "Chase"
        let mask = "1234"
        let notes = "Primary checking account"

        // When
        let account = Account(
            name: "Test",
            type: .checking,
            currentBalance: 1000,
            mask: mask,
            institutionName: institutionName,
            notes: notes
        )

        // Then
        XCTAssertEqual(account.institutionName, institutionName)
        XCTAssertEqual(account.mask, mask)
        XCTAssertEqual(account.notes, notes)
    }

    // MARK: - Display Balance Tests

    func testDisplayBalance_FormatsCorrectly() {
        // Given
        let account = Account(name: "Test", type: .checking, currentBalance: 1234.56)

        // When
        let displayBalance = account.displayBalance

        // Then
        XCTAssertTrue(displayBalance.contains("1,234.56") || displayBalance.contains("1234.56"))
        XCTAssertTrue(displayBalance.contains("$"))
    }

    func testDisplayBalance_NegativeAmount() {
        // Given
        let account = Account(name: "Test", type: .checking, currentBalance: -500.00)

        // When
        let displayBalance = account.displayBalance

        // Then
        XCTAssertTrue(displayBalance.contains("-") || displayBalance.contains("("))
        XCTAssertTrue(displayBalance.contains("500"))
    }

    // MARK: - Masked Account Number Tests

    func testMaskedAccountNumber_WithMask() {
        // Given
        let account = Account(name: "Test", type: .checking, currentBalance: 1000, mask: "5678")

        // When
        let masked = account.maskedAccountNumber

        // Then
        XCTAssertEqual(masked, "••••5678")
    }

    func testMaskedAccountNumber_WithoutMask() {
        // Given
        let account = Account(name: "Test", type: .checking, currentBalance: 1000)

        // When
        let masked = account.maskedAccountNumber

        // Then
        XCTAssertEqual(masked, "••••")
    }

    // MARK: - Credit Card Tests

    func testIsCreditCard_ReturnsTrueForCreditCard() {
        // Given
        let account = Account(name: "Test", type: .creditCard, currentBalance: 500)

        // Then
        XCTAssertTrue(account.isCreditCard)
    }

    func testIsCreditCard_ReturnsFalseForNonCreditCard() {
        // Given
        let account = Account(name: "Test", type: .checking, currentBalance: 1000)

        // Then
        XCTAssertFalse(account.isCreditCard)
    }

    // MARK: - Utilization Percentage Tests

    func testUtilizationPercentage_CalculatesCorrectly() {
        // Given
        let account = Account(
            name: "Credit Card",
            type: .creditCard,
            currentBalance: 500,
            creditLimit: 1000
        )

        // When
        let utilization = account.utilizationPercentage

        // Then
        XCTAssertNotNil(utilization)
        XCTAssertEqual(utilization!, 50.0, accuracy: 0.1)
    }

    func testUtilizationPercentage_NilWhenNoCreditLimit() {
        // Given
        let account = Account(name: "Credit Card", type: .creditCard, currentBalance: 500)

        // When
        let utilization = account.utilizationPercentage

        // Then
        XCTAssertNil(utilization)
    }

    func testUtilizationPercentage_NilWhenZeroCreditLimit() {
        // Given
        let account = Account(
            name: "Credit Card",
            type: .creditCard,
            currentBalance: 500,
            creditLimit: 0
        )

        // When
        let utilization = account.utilizationPercentage

        // Then
        XCTAssertNil(utilization)
    }

    func testUtilizationPercentage_HandlesNegativeBalance() {
        // Given (negative balance represents debt)
        let account = Account(
            name: "Credit Card",
            type: .creditCard,
            currentBalance: -750,
            creditLimit: 1000
        )

        // When
        let utilization = account.utilizationPercentage

        // Then
        XCTAssertNotNil(utilization)
        XCTAssertEqual(utilization!, 75.0, accuracy: 0.1)
    }

    // MARK: - Account Type Tests

    func testAccountType_DisplayNames() {
        XCTAssertEqual(Account.AccountType.checking.displayName, "Checking")
        XCTAssertEqual(Account.AccountType.savings.displayName, "Savings")
        XCTAssertEqual(Account.AccountType.creditCard.displayName, "Credit Card")
        XCTAssertEqual(Account.AccountType.investment.displayName, "Investment")
        XCTAssertEqual(Account.AccountType.loan.displayName, "Loan")
    }

    func testAccountType_Icons() {
        XCTAssertEqual(Account.AccountType.checking.icon, "dollarsign.circle.fill")
        XCTAssertEqual(Account.AccountType.savings.icon, "banknote.fill")
        XCTAssertEqual(Account.AccountType.creditCard.icon, "creditcard.fill")
        XCTAssertEqual(Account.AccountType.investment.icon, "chart.line.uptrend.xyaxis")
        XCTAssertEqual(Account.AccountType.loan.icon, "doc.text.fill")
    }

    // MARK: - Codable Tests

    func testAccountCodable_EncodesAndDecodes() throws {
        // Given
        let originalAccount = Account(
            name: "Test Account",
            type: .checking,
            currentBalance: 1234.56,
            availableBalance: 1000.00,
            mask: "1234",
            institutionName: "Test Bank",
            notes: "Test notes"
        )

        // When
        let encoder = JSONEncoder()
        let data = try encoder.encode(originalAccount)
        let decoder = JSONDecoder()
        let decodedAccount = try decoder.decode(Account.self, from: data)

        // Then
        XCTAssertEqual(decodedAccount.id, originalAccount.id)
        XCTAssertEqual(decodedAccount.name, originalAccount.name)
        XCTAssertEqual(decodedAccount.type, originalAccount.type)
        XCTAssertEqual(decodedAccount.currentBalance, originalAccount.currentBalance)
        XCTAssertEqual(decodedAccount.mask, originalAccount.mask)
        XCTAssertEqual(decodedAccount.institutionName, originalAccount.institutionName)
        XCTAssertEqual(decodedAccount.notes, originalAccount.notes)
    }

    // MARK: - Hashable Tests

    func testAccountHashable_SameIDHasSameHash() {
        // Given
        let id = UUID()
        let account1 = Account(id: id, name: "Account 1", type: .checking, currentBalance: 1000)
        let account2 = Account(id: id, name: "Account 2", type: .savings, currentBalance: 2000)

        // Then
        XCTAssertEqual(account1.hashValue, account2.hashValue)
    }

    func testAccountHashable_DifferentIDHasDifferentHash() {
        // Given
        let account1 = Account(name: "Account 1", type: .checking, currentBalance: 1000)
        let account2 = Account(name: "Account 2", type: .checking, currentBalance: 1000)

        // Then
        XCTAssertNotEqual(account1.hashValue, account2.hashValue)
    }

    // MARK: - Equatable Tests

    func testAccountEquatable_SameIDIsEqual() {
        // Given
        let id = UUID()
        let account1 = Account(id: id, name: "Account 1", type: .checking, currentBalance: 1000)
        let account2 = Account(id: id, name: "Account 2", type: .savings, currentBalance: 2000)

        // Then
        XCTAssertEqual(account1, account2)
    }

    func testAccountEquatable_DifferentIDIsNotEqual() {
        // Given
        let account1 = Account(name: "Account 1", type: .checking, currentBalance: 1000)
        let account2 = Account(name: "Account 2", type: .checking, currentBalance: 1000)

        // Then
        XCTAssertNotEqual(account1, account2)
    }
}
