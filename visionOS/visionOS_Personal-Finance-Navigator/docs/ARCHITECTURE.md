# Architecture Guide
# Personal Finance Navigator

**Version**: 1.0
**Last Updated**: 2025-11-24
**Status**: Implementation Complete

## Table of Contents

1. [Overview](#overview)
2. [Architecture Pattern](#architecture-pattern)
3. [Layer Breakdown](#layer-breakdown)
4. [Data Flow](#data-flow)
5. [Dependency Injection](#dependency-injection)
6. [Concurrency Model](#concurrency-model)
7. [State Management](#state-management)
8. [Security Architecture](#security-architecture)
9. [Testing Architecture](#testing-architecture)

## Overview

Personal Finance Navigator follows **Clean Architecture** principles with an **MVVM** (Model-View-ViewModel) pattern for the presentation layer. The architecture is designed to be:

- **Modular**: Clear separation of concerns
- **Testable**: Easy to mock and test components
- **Scalable**: Can grow without becoming unmanageable
- **Maintainable**: Easy to understand and modify

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    Presentation Layer                    │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │   SwiftUI    │  │  ViewModels  │  │ Coordinators │  │
│  │    Views     │◄─┤ (@Observable)│◄─┤   (Flow)     │  │
│  └──────────────┘  └──────────────┘  └──────────────┘  │
└─────────────────────────────────────────────────────────┘
                           ▼
┌─────────────────────────────────────────────────────────┐
│                      Domain Layer                        │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │    Domain    │  │  Use Cases   │  │ Repository   │  │
│  │    Models    │  │ (Business    │  │  Protocols   │  │
│  │              │  │   Logic)     │  │              │  │
│  └──────────────┘  └──────────────┘  └──────────────┘  │
└─────────────────────────────────────────────────────────┘
                           ▼
┌─────────────────────────────────────────────────────────┐
│                       Data Layer                         │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │  Core Data   │  │   Plaid API  │  │   Keychain   │  │
│  │ (Persistence)│  │  (Banking)   │  │  (Secrets)   │  │
│  └──────────────┘  └──────────────┘  └──────────────┘  │
└─────────────────────────────────────────────────────────┘
```

## Architecture Pattern

### MVVM (Model-View-ViewModel)

**Views** (SwiftUI)
- Purely declarative UI
- No business logic
- Observe ViewModels using @Observable
- Handle user interactions

**ViewModels** (@Observable classes)
- Presentation logic
- State management
- Coordinate between domain and views
- Handle UI-specific formatting

**Models** (Domain entities)
- Pure Swift structs
- Business rules
- No dependencies on frameworks
- Immutable where possible

### Repository Pattern

Repositories abstract data access:

```swift
protocol AccountRepository {
    func fetchAll() async throws -> [Account]
    func fetch(by id: UUID) async throws -> Account?
    func save(_ account: Account) async throws
    func delete(_ account: Account) async throws
}
```

Benefits:
- Testable (easy to mock)
- Swappable implementations
- Centralized data access
- Error handling in one place

## Layer Breakdown

### 1. Presentation Layer

**Location**: `src/Presentation/`

#### ViewModels

All ViewModels follow this pattern:

```swift
@MainActor
@Observable
class XyzViewModel {
    // MARK: - Published State
    private(set) var items: [Item] = []
    private(set) var isLoading = false
    private(set) var errorMessage: String?

    // MARK: - Dependencies
    private let repository: ItemRepository

    // MARK: - Init
    init(repository: ItemRepository) {
        self.repository = repository
    }

    // MARK: - Public Methods
    func loadItems() async { /* ... */ }

    // MARK: - Private Methods
    private func handleError(_ error: Error) { /* ... */ }
}
```

Key principles:
- **@MainActor**: All UI updates on main thread
- **@Observable**: Swift's modern observation
- **private(set)**: Immutable state from outside
- **async/await**: Modern concurrency

#### Views

Views are broken into:

**Screens** - Full-screen views
Examples: `DashboardView`, `BudgetListView`

**Components** - Reusable UI pieces
Examples: `TransactionRow`, `BudgetCard`

**Modifiers** - Custom view modifiers
Examples: `LoadingModifier`, `ErrorBannerModifier`

### 2. Domain Layer

**Location**: `src/Domain/`

#### Models

Pure Swift structs representing business concepts:

```swift
struct Account: Identifiable, Codable {
    let id: UUID
    var name: String
    var type: AccountType
    var currentBalance: Decimal
    // ... more properties

    // Business logic
    var isLowBalance: Bool {
        currentBalance < 100
    }
}
```

Characteristics:
- **Identifiable**: For SwiftUI lists
- **Codable**: For serialization
- **Hashable**: For dictionaries
- **Immutable by default**: Use `var` only when needed

#### Repository Protocols

Define contracts for data access:

```swift
protocol TransactionRepository {
    func fetchAll() async throws -> [Transaction]
    func fetchTransactions(
        from startDate: Date,
        to endDate: Date
    ) async throws -> [Transaction]
    func save(_ transaction: Transaction) async throws
    func delete(_ transaction: Transaction) async throws
    func search(query: String) async throws -> [Transaction]
}
```

#### Use Cases

Encapsulate complex business logic:

```swift
struct CalculateBudgetProgressUseCase {
    func execute(budget: Budget, transactions: [Transaction]) -> BudgetProgress {
        // Complex calculation logic
    }
}
```

### 3. Data Layer

**Location**: `src/Data/`

#### Core Data

**Entities** - NSManagedObject subclasses
Map to domain models:

```swift
@objc(TransactionEntity)
public class TransactionEntity: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var amount: NSDecimalNumber
    // ... more properties

    // Convert to domain model
    func toDomain() -> Transaction {
        Transaction(
            id: id,
            amount: amount as Decimal,
            // ... more properties
        )
    }

    // Update from domain model
    func update(from transaction: Transaction) {
        self.amount = NSDecimalNumber(decimal: transaction.amount)
        // ... more updates
    }
}
```

**Repository Implementations**
Concrete Core Data implementations:

```swift
class CoreDataTransactionRepository: TransactionRepository {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func fetchAll() async throws -> [Transaction] {
        try await context.perform {
            let request = TransactionEntity.fetchRequest()
            let entities = try self.context.fetch(request)
            return entities.map { $0.toDomain() }
        }
    }
}
```

## Data Flow

### Read Flow

```
User Action → View → ViewModel → Repository → Core Data
                                      ↓
View ← ViewModel ← Domain Model ← Entity
```

Example: Loading transactions

```swift
// 1. User pulls to refresh
TransactionListView {
    .refreshable {
        await viewModel.loadTransactions()  // 2. View calls ViewModel
    }
}

// 3. ViewModel calls Repository
func loadTransactions() async {
    transactions = try await repository.fetchAll()  // 4. Repository queries Core Data
}

// 5. Repository converts entities to domain models
// 6. ViewModel updates state
// 7. View automatically updates (via @Observable)
```

### Write Flow

```
User Input → View → ViewModel → Repository → Core Data
                                      ↓
             View ← Update State ← Success/Error
```

Example: Adding a transaction

```swift
// 1. User submits form
Button("Save") {
    await viewModel.saveTransaction(transaction)  // 2. View calls ViewModel
}

// 3. ViewModel validates and calls Repository
func saveTransaction(_ transaction: Transaction) async -> Bool {
    guard isValid(transaction) else { return false }
    try await repository.save(transaction)  // 4. Repository saves to Core Data
    await loadTransactions()  // 5. Reload data
    return true
}
```

## Dependency Injection

All dependencies are injected via `DependencyContainer`:

```swift
@MainActor
class DependencyContainer: ObservableObject {
    // MARK: - Core Data

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentCloudKitContainer(name: "PersonalFinanceNavigator")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Core Data load error: \(error)")
            }
        }
        return container
    }()

    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    // MARK: - Repositories

    lazy var accountRepository: AccountRepository = {
        CoreDataAccountRepository(context: context)
    }()

    lazy var transactionRepository: TransactionRepository = {
        CoreDataTransactionRepository(context: context)
    }()

    // MARK: - ViewModels

    func makeAccountViewModel() -> AccountViewModel {
        AccountViewModel(repository: accountRepository)
    }

    func makeTransactionViewModel() -> TransactionViewModel {
        TransactionViewModel(
            transactionRepository: transactionRepository,
            accountRepository: accountRepository,
            categoryRepository: categoryRepository
        )
    }
}
```

Benefits:
- Easy testing (swap real with mocks)
- Single source of truth
- Lazy initialization
- Clear dependency graph

## Concurrency Model

### Swift 6 Concurrency

We use modern Swift concurrency:

**async/await** - No completion handlers

```swift
func loadAccounts() async {
    accounts = try await repository.fetchAll()
}
```

**Actors** - Thread-safe services

```swift
actor EncryptionManager {
    func encrypt(_ data: Data) throws -> Data {
        // Thread-safe encryption
    }
}
```

**@MainActor** - UI updates on main thread

```swift
@MainActor
class ViewModel {
    func updateUI() {
        // Always on main thread
    }
}
```

### Concurrency Patterns

**Parallel Loading**

```swift
async let accounts = loadAccounts()
async let transactions = loadTransactions()
async let budgets = loadBudgets()

await accounts
await transactions
await budgets
```

**Sequential with Dependencies**

```swift
let budget = try await budgetRepository.fetchActive()
let transactions = try await transactionRepository.fetchForBudget(budget.id)
updateProgress(budget: budget, transactions: transactions)
```

## State Management

### @Observable Pattern

Swift's modern observation system:

```swift
@Observable
class ViewModel {
    var items: [Item] = []  // Automatically observed
    var isLoading = false   // View updates when changed
}

struct MyView: View {
    @State private var viewModel = ViewModel()

    var body: some View {
        List(viewModel.items) { item in
            // Automatically updates when items change
        }
    }
}
```

Benefits over @Published:
- No Combine dependency
- Better performance
- Simpler syntax
- More predictable

### State Scope

**Local State** - @State
For view-specific state (animations, selections)

**Shared State** - ViewModels
For shared business state

**Environment** - @Environment
For app-wide configuration

## Security Architecture

### Layered Security

```
┌─────────────────────────────────┐
│   Biometric Authentication      │  Face ID/Optic ID
├─────────────────────────────────┤
│   Session Management            │  Auto-lock, timeout
├─────────────────────────────────┤
│   Data Encryption (AES-256)     │  Sensitive data
├─────────────────────────────────┤
│   Keychain Storage              │  Tokens, keys
├─────────────────────────────────┤
│   Core Data + CloudKit          │  Encrypted at rest
└─────────────────────────────────┘
```

### Security Flow

```swift
// 1. App Launch
@main
struct App: App {
    @State private var sessionManager = SessionManager()

    var body: some Scene {
        WindowGroup {
            if sessionManager.isAuthenticated {
                MainView()  // 3. Show main app
            } else {
                AuthenticationView()  // 2. Require auth
            }
        }
    }
}

// 4. Access sensitive data
let encryptedData = try encryptionManager.encrypt(sensitiveData)
try keychainManager.save(encryptedData, for: key)
```

## Testing Architecture

### Test Pyramid

```
         ┌─────────┐
         │   UI    │  Few (Manual in Xcode)
         ├─────────┤
         │Integration│  Some (Mock network/DB)
         ├─────────┤
         │  Unit   │  Many (ViewModels, Models)
         └─────────┘
```

### Mock Repositories

```swift
class MockAccountRepository: AccountRepository {
    var accountsToReturn: [Account] = []
    var shouldThrowError = false

    func fetchAll() async throws -> [Account] {
        if shouldThrowError {
            throw TestError.mockError
        }
        return accountsToReturn
    }
}
```

### Testing ViewModels

```swift
@MainActor
class ViewModelTests: XCTestCase {
    var sut: AccountViewModel!
    var mockRepo: MockAccountRepository!

    override func setUp() {
        mockRepo = MockAccountRepository()
        sut = AccountViewModel(repository: mockRepo)
    }

    func testLoadAccounts() async {
        // Given
        mockRepo.accountsToReturn = [testAccount]

        // When
        await sut.loadAccounts()

        // Then
        XCTAssertEqual(sut.accounts.count, 1)
    }
}
```

---

## Best Practices

### Do's ✅

- Use protocols for dependencies
- Inject dependencies via init
- Keep ViewModels focused (single responsibility)
- Use async/await for all async operations
- Handle errors gracefully
- Write tests for all business logic
- Document public APIs

### Don'ts ❌

- Don't put business logic in Views
- Don't use singletons (except for truly global services)
- Don't use completion handlers (use async/await)
- Don't access Core Data directly from Views
- Don't use force unwrapping (!)
- Don't ignore errors

---

**For more details, see:**
- [technical-architecture.md](technical-architecture.md) - Full technical spec
- [data-model-schema.md](data-model-schema.md) - Database design
- [state-management.md](state-management.md) - State management patterns
