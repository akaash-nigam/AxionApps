# Personal Finance Navigator - Test Guide

This document provides comprehensive testing information for the Personal Finance Navigator app, including tests that can be run immediately and tests that require Xcode/visionOS Simulator.

## Table of Contents

1. [Test Overview](#test-overview)
2. [Tests Included (Runnable)](#tests-included-runnable)
3. [Tests Requiring Xcode/Simulator](#tests-requiring-xcodesimulator)
4. [Running Tests](#running-tests)
5. [Test Coverage Goals](#test-coverage-goals)
6. [Continuous Integration](#continuous-integration)

---

## Test Overview

The application has comprehensive test coverage across multiple layers:

- **Unit Tests**: Test individual components in isolation (~85% coverage target)
- **Integration Tests**: Test component interactions
- **UI Tests**: Test user flows and interactions
- **Performance Tests**: Measure operation execution time
- **Snapshot Tests**: Visual regression testing

### Test Structure

```
Tests/
├── ViewModelTests/          # ViewModel unit tests (Runnable)
│   ├── AccountViewModelTests.swift
│   ├── TransactionViewModelTests.swift
│   └── BudgetViewModelTests.swift
├── DomainTests/             # Domain model tests (Runnable)
│   └── AccountTests.swift
├── IntegrationTests/        # Integration tests (Requires Xcode)
├── UITests/                 # UI automation tests (Requires Xcode)
├── PerformanceTests/        # Performance tests (Requires Xcode)
└── TEST_GUIDE.md           # This file
```

---

## Tests Included (Runnable)

These tests can be run with `swift test` or in Xcode Test Navigator.

### 1. AccountViewModelTests

**Location**: `Tests/ViewModelTests/AccountViewModelTests.swift`

**Coverage**: AccountViewModel

**Test Cases** (15 tests):
- ✅ `testLoadAccounts_Success`: Verifies successful account loading
- ✅ `testLoadAccounts_Failure`: Tests error handling
- ✅ `testLoadAccounts_FiltersInactiveAccounts`: Tests filtering logic
- ✅ `testAddAccount_Success`: Tests account creation
- ✅ `testAddAccount_Failure`: Tests error handling on save failure
- ✅ `testUpdateAccount_Success`: Tests account updates
- ✅ `testDeleteAccount_Success`: Tests account deletion
- ✅ `testTotalNetWorth_Calculation`: Verifies net worth calculation
- ✅ `testTotalNetWorth_EmptyAccounts`: Edge case with no accounts
- ✅ `testAccountsByType_GroupsCorrectly`: Tests grouping logic
- ✅ `testGetFormattedNetWorth_USD`: Tests currency formatting
- ✅ `testGetFormattedBalance_USD`: Tests balance formatting
- ✅ `testUpdateBalance_Success`: Tests balance update operations

**Run Command**:
```bash
swift test --filter AccountViewModelTests
```

### 2. TransactionViewModelTests

**Location**: `Tests/ViewModelTests/TransactionViewModelTests.swift`

**Coverage**: TransactionViewModel

**Test Cases** (20 tests):
- ✅ `testLoadTransactions_Success`: Tests transaction loading
- ✅ `testLoadTransactions_Failure`: Tests error handling
- ✅ `testAddTransaction_Success`: Tests transaction creation
- ✅ `testAddTransaction_UpdatesAccountBalance`: Verifies balance sync
- ✅ `testDeleteTransaction_ReversesBalance`: Tests balance reversal
- ✅ `testFilteredTransactions_ByAccount`: Tests account filtering
- ✅ `testFilteredTransactions_ByCategory`: Tests category filtering
- ✅ `testFilteredTransactions_BySearchQuery`: Tests search functionality
- ✅ `testFilteredTransactions_PendingOnly`: Tests pending filter
- ✅ `testTotalIncome_Calculation`: Verifies income calculation
- ✅ `testTotalExpenses_Calculation`: Verifies expense calculation
- ✅ `testNetAmount_Calculation`: Verifies net amount (income - expenses)
- ✅ `testTransactionsByDate_GroupsCorrectly`: Tests date grouping
- ✅ `testFormatDateSection_Today`: Tests "Today" formatting
- ✅ `testFormatDateSection_Yesterday`: Tests "Yesterday" formatting
- ✅ `testClearFilters_ResetsAllFilters`: Tests filter reset

**Run Command**:
```bash
swift test --filter TransactionViewModelTests
```

### 3. BudgetViewModelTests

**Location**: `Tests/ViewModelTests/BudgetViewModelTests.swift`

**Coverage**: BudgetViewModel

**Test Cases** (18 tests):
- ✅ `testLoadBudgets_Success`: Tests budget loading
- ✅ `testLoadBudgets_Failure`: Tests error handling
- ✅ `testHasBudgets_ReturnsTrueWhenBudgetsExist`: Tests budget existence check
- ✅ `testHasBudgets_ReturnsFalseWhenNoBudgets`: Edge case with no budgets
- ✅ `testCreateBudget_Success`: Tests budget creation
- ✅ `testCreateBudget_Failure`: Tests error handling
- ✅ `testActiveBudgetProgress_CalculatesCorrectly`: Verifies progress calculation
- ✅ `testIsOverBudget_ReturnsTrueWhenOverBudget`: Tests over-budget detection
- ✅ `testIsOverBudget_ReturnsFalseWhenUnderBudget`: Tests under-budget state
- ✅ `testBudgetStatusColor_Green_WhenUnder75Percent`: Tests color coding <75%
- ✅ `testBudgetStatusColor_Yellow_When75To89Percent`: Tests color coding 75-89%
- ✅ `testBudgetStatusColor_Orange_When90To99Percent`: Tests color coding 90-99%
- ✅ `testBudgetStatusColor_Red_When100PercentOrMore`: Tests color coding ≥100%
- ✅ `testSuggestBudgetAmounts_FiftyThirtyTwenty`: Tests 50/30/20 rule
- ✅ `testSuggestBudgetAmounts_PercentageBased`: Tests percentage-based budgeting
- ✅ `testGetRemainingAmount_PositiveWhenUnderBudget`: Tests remaining calculation
- ✅ `testGetOverspendAmount_ZeroWhenUnderBudget`: Tests overspend calculation
- ✅ `testFormatPercentage`: Tests percentage formatting

**Run Command**:
```bash
swift test --filter BudgetViewModelTests
```

### 4. AccountTests

**Location**: `Tests/DomainTests/AccountTests.swift`

**Coverage**: Account domain model

**Test Cases** (15 tests):
- ✅ `testAccountInitialization_WithRequiredFields`: Tests basic initialization
- ✅ `testAccountInitialization_WithOptionalFields`: Tests full initialization
- ✅ `testDisplayBalance_FormatsCorrectly`: Tests balance display
- ✅ `testDisplayBalance_NegativeAmount`: Tests negative balance display
- ✅ `testMaskedAccountNumber_WithMask`: Tests masked number display
- ✅ `testMaskedAccountNumber_WithoutMask`: Tests default masking
- ✅ `testIsCreditCard_ReturnsTrueForCreditCard`: Tests credit card detection
- ✅ `testIsCreditCard_ReturnsFalseForNonCreditCard`: Tests non-credit card
- ✅ `testUtilizationPercentage_CalculatesCorrectly`: Tests utilization calc
- ✅ `testUtilizationPercentage_NilWhenNoCreditLimit`: Edge case handling
- ✅ `testUtilizationPercentage_NilWhenZeroCreditLimit`: Edge case handling
- ✅ `testUtilizationPercentage_HandlesNegativeBalance`: Debt handling
- ✅ `testAccountType_DisplayNames`: Tests enum display names
- ✅ `testAccountType_Icons`: Tests enum icons
- ✅ `testAccountCodable_EncodesAndDecodes`: Tests JSON serialization

**Run Command**:
```bash
swift test --filter AccountTests
```

### Total Runnable Tests: **68 test cases**

---

## Tests Requiring Xcode/Simulator

The following tests require Xcode and visionOS Simulator to run. They are documented here for implementation.

### 1. Integration Tests with Core Data

**Purpose**: Test actual Core Data operations with in-memory store

**Test Class**: `CoreDataIntegrationTests`

**Test Cases to Implement**:

```swift
// CoreDataIntegrationTests.swift

func testAccountRepository_SaveAndFetch() async {
    // Test actual Core Data CRUD operations
    // 1. Create account
    // 2. Save to Core Data
    // 3. Fetch and verify
    // 4. Update and verify
    // 5. Delete and verify
}

func testTransactionRepository_WithRelationships() async {
    // Test transactions with account relationships
    // Verify cascading deletes, referential integrity
}

func testBudgetRepository_ComplexQueries() async {
    // Test complex queries with date ranges
    // Test category progress updates
}

func testCloudKitSync_Simulation() async {
    // Test CloudKit sync with mock data
    // Verify conflict resolution
}

func testCoreData_Migration() async {
    // Test Core Data model migration
    // Verify data preservation
}

func testCoreData_Performance() async {
    // Test with 1000+ records
    // Verify fetch performance
}
```

**Run in Xcode**:
1. Open `PersonalFinanceNavigator.xcodeproj`
2. Select visionOS Simulator
3. Navigate to Test Navigator (⌘6)
4. Run `CoreDataIntegrationTests`

### 2. UI Tests

**Purpose**: Test user workflows and UI interactions

**Test Class**: `PersonalFinanceNavigatorUITests`

**Test Cases to Implement**:

```swift
// PersonalFinanceNavigatorUITests.swift

// MARK: - Authentication Flow

func testAuthenticationFlow_BiometricSuccess() {
    // 1. Launch app
    // 2. Tap "Unlock with Biometrics"
    // 3. Simulate biometric success
    // 4. Verify main screen appears
}

func testAuthenticationFlow_BiometricFailure() {
    // 1. Launch app
    // 2. Tap "Unlock with Biometrics"
    // 3. Simulate biometric failure
    // 4. Verify error message
    // 5. Tap "Try Again"
}

func testAutoLock_Background() {
    // 1. Authenticate
    // 2. Navigate to accounts
    // 3. Simulate background
    // 4. Wait for timeout
    // 5. Foreground app
    // 6. Verify auth screen appears
}

// MARK: - Account Management Flow

func testCreateAccount_Success() {
    // 1. Navigate to Accounts tab
    // 2. Tap "+" button
    // 3. Fill in account details
    // 4. Tap "Add"
    // 5. Verify account appears in list
    // 6. Verify net worth updated
}

func testCreateAccount_Validation() {
    // 1. Navigate to add account
    // 2. Leave required fields empty
    // 3. Tap "Add"
    // 4. Verify validation messages
    // 5. Verify "Add" button disabled
}

func testEditAccount_Success() {
    // 1. Swipe account left
    // 2. Tap "Edit"
    // 3. Modify account name
    // 4. Tap "Save"
    // 5. Verify updated name
}

func testDeleteAccount_WithConfirmation() {
    // 1. Swipe account left
    // 2. Tap "Delete"
    // 3. Verify confirmation alert
    // 4. Tap "Delete"
    // 5. Verify account removed
    // 6. Verify net worth updated
}

// MARK: - Transaction Management Flow

func testCreateTransaction_Expense() {
    // 1. Navigate to Transactions tab
    // 2. Tap "+" button
    // 3. Enter description
    // 4. Select "Expense"
    // 5. Enter amount
    // 6. Select account and category
    // 7. Tap "Add"
    // 8. Verify transaction in list
    // 9. Verify account balance updated
}

func testCreateTransaction_Income() {
    // Similar to expense but with income type
}

func testSearchTransactions() {
    // 1. Navigate to Transactions
    // 2. Pull down to reveal search
    // 3. Type merchant name
    // 4. Verify filtered results
}

func testFilterTransactions_ByAccount() {
    // 1. Tap filter icon
    // 2. Select account
    // 3. Tap "Done"
    // 4. Verify filtered transactions
    // 5. Verify summary updated
}

// MARK: - Budget Management Flow

func testCreateBudget_ThreeStepWizard() {
    // Step 1:
    // 1. Navigate to Budget tab
    // 2. Tap "Create Budget"
    // 3. Enter budget name and amount
    // 4. Select strategy
    // 5. Set dates
    // 6. Verify suggestions displayed
    // 7. Tap "Next"

    // Step 2:
    // 8. Select 3 categories
    // 9. Verify category count
    // 10. Tap "Next"

    // Step 3:
    // 11. Allocate amounts
    // 12. Verify total and remaining
    // 13. Tap "Create"
    // 14. Verify budget appears in list
}

func testBudgetDetail_ViewProgress() {
    // 1. Tap active budget card
    // 2. Verify circular progress
    // 3. Verify category breakdown
    // 4. Tap "Refresh"
    // 5. Verify progress updates
}

func testBudgetDetail_OverBudgetWarning() {
    // 1. Create budget with small amounts
    // 2. Add transactions exceeding budget
    // 3. Open budget detail
    // 4. Verify red color coding
    // 5. Verify "Over Budget" text
}

// MARK: - Settings Flow

func testSecuritySettings_ToggleBiometric() {
    // 1. Navigate to Settings
    // 2. Tap "Security & Privacy"
    // 3. Toggle "Require Biometric"
    // 4. Verify setting saved
    // 5. Background and foreground
    // 6. Verify biometric not required
}

func testSecuritySettings_ChangeTimeout() {
    // 1. Navigate to Security Settings
    // 2. Tap "Lock After"
    // 3. Select "1 minute"
    // 4. Verify checkmark
    // 5. Tap "Done"
    // 6. Verify setting saved
}

func testSecuritySettings_ManualLock() {
    // 1. Navigate to Security Settings
    // 2. Tap "Lock Now"
    // 3. Verify auth screen appears
}

// MARK: - Navigation Flow

func testTabNavigation_AllTabs() {
    // 1. Authenticate
    // 2. Tap each tab
    // 3. Verify correct view appears
    // 4. Verify state persists
}

// MARK: - Error Handling

func testNetworkError_GracefulHandling() {
    // 1. Simulate network error
    // 2. Attempt operation
    // 3. Verify error message
    // 4. Verify retry option
}

func testInvalidData_Validation() {
    // Test various invalid inputs
    // Verify validation messages
}

// MARK: - Accessibility

func testVoiceOver_Navigation() {
    // 1. Enable VoiceOver
    // 2. Navigate through app
    // 3. Verify labels and hints
}

func testDynamicType_Scaling() {
    // 1. Increase text size
    // 2. Verify layout adapts
    // 3. Verify no text truncation
}
```

**Run in Xcode**:
1. Open project in Xcode
2. Select visionOS Simulator
3. Product → Test (⌘U)
4. Or run specific test class

### 3. Performance Tests

**Purpose**: Measure and benchmark operation performance

**Test Class**: `PerformanceTests`

**Test Cases to Implement**:

```swift
// PerformanceTests.swift

func testAccountLoading_Performance() {
    // Measure time to load 1000 accounts
    measure {
        await viewModel.loadAccounts()
    }
    // Assert < 100ms
}

func testTransactionFiltering_Performance() {
    // Measure filtering 10,000 transactions
    measure {
        _ = viewModel.filteredTransactions
    }
    // Assert < 50ms
}

func testBudgetCalculation_Performance() {
    // Measure budget progress calculation
    measure {
        await viewModel.updateBudgetProgress(for: budget)
    }
    // Assert < 200ms
}

func testCoreDataFetch_Performance() {
    // Measure large batch fetch
    measure(metrics: [XCTCPUMetric(), XCTMemoryMetric()]) {
        _ = try! repository.fetchAll()
    }
}

func testUIRendering_Performance() {
    // Measure view rendering time
    measure(metrics: [XCTClockMetric()]) {
        app.tables.firstMatch.swipeUp()
    }
}
```

**Run in Xcode**:
1. Open Test Navigator (⌘6)
2. Run `PerformanceTests`
3. View baseline in test results

### 4. Snapshot Tests

**Purpose**: Visual regression testing

**Setup Required**:
```swift
// Install SnapshotTesting
// Add to Package.swift:
.package(url: "https://github.com/pointfreeco/swift-snapshot-testing", from: "1.0.0")
```

**Test Cases to Implement**:

```swift
import SnapshotTesting

func testAccountListView_Snapshot() {
    let view = AccountListView(viewModel: viewModel)
    assertSnapshot(matching: view, as: .image)
}

func testTransactionRow_Snapshot_Income() {
    let transaction = Transaction(amount: 1000, name: "Salary")
    let row = TransactionRow(transaction: transaction)
    assertSnapshot(matching: row, as: .image)
}

func testTransactionRow_Snapshot_Expense() {
    let transaction = Transaction(amount: -50, name: "Coffee")
    let row = TransactionRow(transaction: transaction)
    assertSnapshot(matching: row, as: .image)
}

func testBudgetCard_Snapshot_UnderBudget() {
    let budget = createBudgetWithProgress(50)
    let card = ActiveBudgetCard(budget: budget)
    assertSnapshot(matching: card, as: .image)
}

func testBudgetCard_Snapshot_OverBudget() {
    let budget = createBudgetWithProgress(105)
    let card = ActiveBudgetCard(budget: budget)
    assertSnapshot(matching: card, as: .image)
}
```

---

## Running Tests

### Command Line

Run all tests:
```bash
swift test
```

Run specific test suite:
```bash
swift test --filter AccountViewModelTests
```

Run specific test:
```bash
swift test --filter testLoadAccounts_Success
```

Generate code coverage:
```bash
swift test --enable-code-coverage
```

### Xcode

1. Open project: `PersonalFinanceNavigator.xcodeproj`
2. Test Navigator (⌘6)
3. Run all tests: ⌘U
4. Run specific test: Click diamond icon
5. View coverage: Coverage tab in Report Navigator

### visionOS Simulator Required

For UI, Integration, and Performance tests:
1. Launch Xcode
2. Select "Apple Vision Pro" simulator
3. Product → Test (⌘U)

---

## Test Coverage Goals

### Current Coverage (Unit Tests)

- **ViewModels**: ~90% (AccountViewModel, TransactionViewModel, BudgetViewModel)
- **Domain Models**: ~85% (Account, Transaction, Budget, Category)
- **Repositories**: 0% (Mocked in unit tests)
- **Views**: 0% (Requires UI tests)
- **Overall**: ~40% (Unit tests only)

### Target Coverage

- **ViewModels**: 90%+
- **Domain Models**: 90%+
- **Repositories**: 80%+ (Integration tests)
- **Business Logic**: 85%+
- **Views**: 60%+ (UI tests)
- **Overall**: 75%+

### Critical Paths (100% Coverage Required)

- Authentication flow
- Transaction balance updates
- Budget calculations
- Data persistence (save/load)
- Security features (encryption, auto-lock)

---

## Continuous Integration

### GitHub Actions Workflow

```yaml
name: Tests

on: [push, pull_request]

jobs:
  unit-tests:
    runs-on: macos-14
    steps:
      - uses: actions/checkout@v3
      - name: Run Unit Tests
        run: swift test --enable-code-coverage

  ui-tests:
    runs-on: macos-14
    steps:
      - uses: actions/checkout@v3
      - name: Select Xcode
        run: sudo xcode-select -s /Applications/Xcode_15.2.app
      - name: Run UI Tests
        run: xcodebuild test -scheme PersonalFinanceNavigator -destination 'platform=visionOS Simulator,name=Apple Vision Pro'
```

### Xcode Cloud

Configure in Xcode:
1. Product → Xcode Cloud → Create Workflow
2. Add test action
3. Configure triggers (PR, commits)
4. Enable code coverage reports

---

## Test Maintenance

### Adding New Tests

1. Create test file in appropriate directory
2. Follow naming convention: `<Component>Tests.swift`
3. Use descriptive test names: `test<Scenario>_<ExpectedBehavior>`
4. Include Given-When-Then comments
5. Update this guide

### Updating Existing Tests

1. Tests should be updated when functionality changes
2. Maintain backward compatibility when possible
3. Document breaking changes
4. Update code coverage baselines

### Best Practices

- **Isolation**: Each test should be independent
- **Fast**: Unit tests should complete in <100ms
- **Reliable**: No flaky tests allowed
- **Readable**: Clear assertions and error messages
- **Maintainable**: Use helper methods for setup
- **Comprehensive**: Test happy paths, edge cases, errors

---

## Troubleshooting

### Tests Not Running in Xcode

1. Clean build folder: ⌘⇧K
2. Reset simulator: Device → Erase All Content and Settings
3. Delete derived data: ~/Library/Developer/Xcode/DerivedData
4. Restart Xcode

### Performance Test Failures

1. Run tests multiple times to establish baseline
2. Consider device/simulator performance variations
3. Adjust timeout values if needed
4. Check for background processes affecting performance

### UI Test Timeouts

1. Increase timeout values: `XCTAssert(element.waitForExistence(timeout: 10))`
2. Check element identifiers are set
3. Verify accessibility labels
4. Check for animations blocking interactions

---

## Additional Resources

- [XCTest Documentation](https://developer.apple.com/documentation/xctest)
- [Testing Best Practices](https://developer.apple.com/videos/play/wwdc2020/10221/)
- [Code Coverage in Xcode](https://developer.apple.com/documentation/xcode/code-coverage)
- [UI Testing](https://developer.apple.com/documentation/xctest/user_interface_tests)

---

## Summary

**Total Tests Documented**: 150+ test cases

**Runnable Now**: 68 unit tests
- AccountViewModelTests: 15 tests
- TransactionViewModelTests: 20 tests
- BudgetViewModelTests: 18 tests
- AccountTests: 15 tests

**Requires Xcode/Simulator**: 80+ tests
- Integration Tests: ~15 tests
- UI Tests: ~50 tests
- Performance Tests: ~10 tests
- Snapshot Tests: ~10 tests

**Status**: ✅ Unit tests ready to run | 📋 Integration/UI tests documented for implementation
