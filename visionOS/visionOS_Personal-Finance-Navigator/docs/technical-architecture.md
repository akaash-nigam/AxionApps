# Technical Architecture Document
# Personal Finance Navigator

**Version**: 1.0
**Last Updated**: 2025-11-24
**Status**: Draft

## Table of Contents
1. [System Overview](#system-overview)
2. [Architecture Layers](#architecture-layers)
3. [Component Breakdown](#component-breakdown)
4. [Data Flow](#data-flow)
5. [Technology Stack](#technology-stack)
6. [Deployment Architecture](#deployment-architecture)
7. [Design Patterns](#design-patterns)
8. [Error Handling Strategy](#error-handling-strategy)

## System Overview

Personal Finance Navigator is a native visionOS application that provides immersive 3D visualization of personal financial data. The application follows a clean architecture pattern with clear separation of concerns across presentation, business logic, and data layers.

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                      Presentation Layer                      │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │  SwiftUI     │  │  RealityKit  │  │   Voice/     │      │
│  │   Views      │  │   Scenes     │  │   Gesture    │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└─────────────────────────────────────────────────────────────┘
                            ↕
┌─────────────────────────────────────────────────────────────┐
│                      Domain Layer                            │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │  ViewModels  │  │  Use Cases   │  │   Domain     │      │
│  │              │  │              │  │   Models     │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└─────────────────────────────────────────────────────────────┘
                            ↕
┌─────────────────────────────────────────────────────────────┐
│                       Service Layer                          │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │   Banking    │  │    Budget    │  │  Investment  │      │
│  │   Service    │  │   Service    │  │   Service    │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└─────────────────────────────────────────────────────────────┘
                            ↕
┌─────────────────────────────────────────────────────────────┐
│                       Data Layer                             │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │  Core Data   │  │   CloudKit   │  │   Plaid      │      │
│  │  Repository  │  │   Sync       │  │   API        │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└─────────────────────────────────────────────────────────────┘
```

## Architecture Layers

### 1. Presentation Layer

**Responsibilities**:
- Render UI using SwiftUI
- Render 3D visualizations using RealityKit
- Handle user interactions (gestures, voice commands)
- Display state updates
- Navigation management

**Key Components**:
- **Views**: SwiftUI view hierarchy
- **RealityViews**: 3D spatial content
- **Coordinators**: Navigation flow management
- **Input Handlers**: Gesture and voice recognition

**Technology**:
- SwiftUI for 2D UI
- RealityKit for 3D content
- ARKit for spatial tracking
- SpeechRecognition for voice commands

### 2. Domain Layer

**Responsibilities**:
- Business logic encapsulation
- State management
- Data transformation
- Validation rules
- Use case orchestration

**Key Components**:
- **ViewModels**: @Observable classes managing view state
- **Use Cases**: Single-responsibility business operations
- **Domain Models**: Pure Swift entities (Transaction, Account, Budget)
- **Validators**: Business rule enforcement

**Patterns**:
- MVVM (Model-View-ViewModel)
- Use Case pattern for complex operations
- Repository pattern for data access abstraction

### 3. Service Layer

**Responsibilities**:
- External API communication
- Business service orchestration
- Transaction categorization
- Notification management
- Background task coordination

**Key Services**:

#### BankingService
- Plaid integration
- Transaction fetching and sync
- Account balance updates
- Institution connection management

#### BudgetService
- Budget calculations
- Spending analysis
- Alert generation
- Category management

#### InvestmentService
- Portfolio tracking
- Performance calculations
- Asset allocation analysis

#### GoalService
- Goal progress tracking
- Projection calculations
- Achievement notifications

#### DebtService
- Debt payoff calculations
- Amortization schedules
- Strategy comparisons (snowball vs avalanche)

#### NotificationService
- Bill reminders
- Budget alerts
- Goal achievements
- Security notifications

### 4. Data Layer

**Responsibilities**:
- Data persistence
- Cloud synchronization
- API client implementation
- Cache management
- Data encryption

**Key Components**:

#### Core Data Stack
```swift
┌─────────────────────────────────────┐
│      NSPersistentContainer          │
│  ┌─────────────────────────────┐   │
│  │  NSPersistentCloudKitContainer│  │
│  └─────────────────────────────┘   │
│  ┌─────────────────────────────┐   │
│  │  ViewContext (Main Thread)   │   │
│  └─────────────────────────────┘   │
│  ┌─────────────────────────────┐   │
│  │  BackgroundContext (Sync)    │   │
│  └─────────────────────────────┘   │
└─────────────────────────────────────┘
```

#### Repository Pattern
```swift
protocol TransactionRepository {
    func fetchAll() async throws -> [Transaction]
    func fetch(by id: UUID) async throws -> Transaction?
    func save(_ transaction: Transaction) async throws
    func delete(_ transaction: Transaction) async throws
    func fetchRecent(limit: Int) async throws -> [Transaction]
}
```

#### CloudKit Sync Strategy
- NSPersistentCloudKitContainer for automatic sync
- Private database for user data
- Shared database for family plan sharing
- Conflict resolution: Last-Write-Wins with user notification

## Component Breakdown

### Core Modules

```
PersonalFinanceNavigator/
├── App/
│   ├── PersonalFinanceNavigatorApp.swift
│   ├── AppCoordinator.swift
│   └── DependencyContainer.swift
├── Presentation/
│   ├── Views/
│   │   ├── Dashboard/
│   │   │   ├── DashboardView.swift
│   │   │   ├── MoneyFlowView.swift
│   │   │   └── FinancialCommandCenterView.swift
│   │   ├── Budget/
│   │   │   ├── BudgetOverviewView.swift
│   │   │   ├── BudgetWallsView.swift
│   │   │   └── CategoryDetailView.swift
│   │   ├── Investment/
│   │   │   ├── PortfolioView.swift
│   │   │   ├── GrowthStructureView.swift
│   │   │   └── AssetAllocationView.swift
│   │   ├── Bills/
│   │   │   ├── BillCalendarView.swift
│   │   │   ├── BillCardView.swift
│   │   │   └── PaymentScheduleView.swift
│   │   ├── Debt/
│   │   │   ├── DebtOverviewView.swift
│   │   │   ├── DebtVisualizationView.swift
│   │   │   └── PayoffStrategyView.swift
│   │   └── Goals/
│   │       ├── GoalsOverviewView.swift
│   │       ├── GoalProgressView.swift
│   │       └── GoalDetailView.swift
│   ├── RealityViews/
│   │   ├── MoneyFlowRealityView.swift
│   │   ├── BudgetWallsRealityView.swift
│   │   ├── InvestmentGrowthRealityView.swift
│   │   └── DebtMeltingRealityView.swift
│   └── Components/
│       ├── Cards/
│       ├── Charts/
│       └── Controls/
├── Domain/
│   ├── ViewModels/
│   │   ├── DashboardViewModel.swift
│   │   ├── BudgetViewModel.swift
│   │   ├── InvestmentViewModel.swift
│   │   ├── BillViewModel.swift
│   │   ├── DebtViewModel.swift
│   │   └── GoalViewModel.swift
│   ├── UseCases/
│   │   ├── Banking/
│   │   │   ├── SyncTransactionsUseCase.swift
│   │   │   ├── LinkBankAccountUseCase.swift
│   │   │   └── CategorizeTransactionUseCase.swift
│   │   ├── Budget/
│   │   │   ├── CalculateBudgetStatusUseCase.swift
│   │   │   ├── CreateBudgetUseCase.swift
│   │   │   └── CheckBudgetAlertUseCase.swift
│   │   ├── Investment/
│   │   │   ├── CalculatePortfolioPerformanceUseCase.swift
│   │   │   └── ProjectRetirementUseCase.swift
│   │   ├── Debt/
│   │   │   ├── CalculatePayoffStrategyUseCase.swift
│   │   │   └── ProjectDebtFreeDate.swift
│   │   └── Goals/
│   │       ├── CalculateGoalProgressUseCase.swift
│   │       └── ProjectGoalCompletionUseCase.swift
│   └── Models/
│       ├── Transaction.swift
│       ├── Account.swift
│       ├── Budget.swift
│       ├── Category.swift
│       ├── Investment.swift
│       ├── Bill.swift
│       ├── Debt.swift
│       └── Goal.swift
├── Services/
│   ├── Banking/
│   │   ├── BankingService.swift
│   │   ├── PlaidClient.swift
│   │   └── TransactionCategorizer.swift
│   ├── Budget/
│   │   ├── BudgetService.swift
│   │   └── BudgetCalculator.swift
│   ├── Investment/
│   │   ├── InvestmentService.swift
│   │   └── PortfolioAnalyzer.swift
│   ├── Debt/
│   │   ├── DebtService.swift
│   │   └── AmortizationCalculator.swift
│   ├── Goals/
│   │   └── GoalService.swift
│   └── Notifications/
│       └── NotificationService.swift
├── Data/
│   ├── CoreData/
│   │   ├── PersistenceController.swift
│   │   ├── PersonalFinanceNavigator.xcdatamodeld
│   │   └── Entities/
│   │       ├── TransactionEntity+CoreDataClass.swift
│   │       ├── AccountEntity+CoreDataClass.swift
│   │       └── ...
│   ├── Repositories/
│   │   ├── TransactionRepository.swift
│   │   ├── AccountRepository.swift
│   │   ├── BudgetRepository.swift
│   │   └── ...
│   ├── API/
│   │   ├── PlaidAPIClient.swift
│   │   └── NetworkClient.swift
│   └── Cache/
│       └── ImageCache.swift
├── Utilities/
│   ├── Extensions/
│   ├── Helpers/
│   └── Constants/
└── Resources/
    ├── Assets.xcassets
    ├── Localizable.strings
    └── 3DModels/
```

## Data Flow

### Transaction Sync Flow

```
1. Background Fetch Triggered
         ↓
2. BankingService.syncTransactions()
         ↓
3. PlaidClient.fetchTransactions()
         ↓
4. TransactionCategorizer.categorize()
         ↓
5. TransactionRepository.save()
         ↓
6. Core Data persistence
         ↓
7. CloudKit sync (automatic)
         ↓
8. NotificationCenter.post(.transactionsUpdated)
         ↓
9. ViewModels observe and update
         ↓
10. Views refresh automatically (@Observable)
```

### User Action Flow (Add Budget)

```
User taps "Create Budget"
         ↓
View calls ViewModel.createBudget()
         ↓
ViewModel calls CreateBudgetUseCase.execute()
         ↓
Use Case validates input
         ↓
Use Case calls BudgetRepository.save()
         ↓
Repository persists to Core Data
         ↓
Core Data syncs to CloudKit
         ↓
Use Case returns Result<Budget, Error>
         ↓
ViewModel updates @Published state
         ↓
SwiftUI automatically refreshes view
```

## Technology Stack

### Core Frameworks
- **SwiftUI**: UI framework
- **RealityKit**: 3D rendering and spatial computing
- **ARKit**: Spatial tracking
- **Core Data**: Local persistence
- **CloudKit**: Cloud sync
- **Combine**: Reactive programming (legacy support)
- **Swift Concurrency**: async/await

### Third-Party Dependencies

#### Plaid SDK
```swift
// Package.swift
dependencies: [
    .package(url: "https://github.com/plaid/plaid-link-ios", from: "5.0.0")
]
```

#### Security
- **CryptoKit**: Encryption and hashing
- **LocalAuthentication**: Biometric authentication

#### Utilities
- **Swift Algorithms**: Collection algorithms
- **Swift Collections**: Advanced collection types

## Deployment Architecture

### App Structure
```
PersonalFinanceNavigator.app/
├── Info.plist
├── Entitlements
│   ├── PersonalFinanceNavigator.entitlements
│   └── CloudKit containers
├── Main executable
├── Frameworks/
├── PlugIns/ (App Extensions)
│   ├── NotificationService.appex
│   └── WidgetExtension.appex
└── Resources/
```

### CloudKit Configuration

**Container**: iCloud.com.yourcompany.personalfinancenav

**Databases**:
- Private: User's financial data
- Shared: Family plan shared budgets/goals

**Record Types**:
- Transaction
- Account
- Budget
- Category
- Bill
- Debt
- Goal
- UserProfile

### Background Modes

**Enabled Capabilities**:
- Background fetch (transaction sync)
- Remote notifications (real-time updates)
- Background processing (data analysis)

**Background Tasks**:
```swift
// Transaction sync: Every 4 hours
BGAppRefreshTask: "com.yourcompany.pfn.transaction-sync"

// Data analysis: Daily at 2 AM
BGProcessingTask: "com.yourcompany.pfn.analysis"
```

## Design Patterns

### 1. MVVM (Model-View-ViewModel)

```swift
// View
struct DashboardView: View {
    @State private var viewModel = DashboardViewModel()

    var body: some View {
        // UI bound to viewModel state
    }
}

// ViewModel
@Observable
class DashboardViewModel {
    var transactions: [Transaction] = []
    var isLoading = false
    var errorMessage: String?

    private let syncTransactionsUseCase: SyncTransactionsUseCase

    func syncTransactions() async {
        isLoading = true
        defer { isLoading = false }

        do {
            transactions = try await syncTransactionsUseCase.execute()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
```

### 2. Repository Pattern

```swift
protocol TransactionRepository {
    func fetchAll() async throws -> [Transaction]
    func save(_ transaction: Transaction) async throws
}

class CoreDataTransactionRepository: TransactionRepository {
    private let context: NSManagedObjectContext

    func fetchAll() async throws -> [Transaction] {
        // Core Data fetch
    }

    func save(_ transaction: Transaction) async throws {
        // Core Data save
    }
}
```

### 3. Dependency Injection

```swift
class DependencyContainer {
    // Singletons
    let persistenceController: PersistenceController
    let networkClient: NetworkClient

    // Repositories
    lazy var transactionRepository: TransactionRepository = {
        CoreDataTransactionRepository(context: persistenceController.container.viewContext)
    }()

    // Services
    lazy var bankingService: BankingService = {
        BankingService(
            plaidClient: plaidClient,
            transactionRepository: transactionRepository
        )
    }()

    // Use Cases
    func makeSyncTransactionsUseCase() -> SyncTransactionsUseCase {
        SyncTransactionsUseCase(bankingService: bankingService)
    }
}
```

### 4. Coordinator Pattern (Navigation)

```swift
@Observable
class AppCoordinator {
    var path = NavigationPath()

    enum Destination: Hashable {
        case dashboard
        case budgetDetail(Budget)
        case transactionDetail(Transaction)
    }

    func navigate(to destination: Destination) {
        path.append(destination)
    }

    func popToRoot() {
        path.removeLast(path.count)
    }
}
```

## Error Handling Strategy

### Error Types

```swift
enum AppError: LocalizedError {
    case networkError(NetworkError)
    case databaseError(DatabaseError)
    case authenticationError(AuthError)
    case validationError(String)
    case plaidError(PlaidError)

    var errorDescription: String? {
        switch self {
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .databaseError(let error):
            return "Database error: \(error.localizedDescription)"
        case .authenticationError(let error):
            return "Authentication failed: \(error.localizedDescription)"
        case .validationError(let message):
            return message
        case .plaidError(let error):
            return "Banking connection error: \(error.localizedDescription)"
        }
    }
}
```

### Error Handling Flow

```swift
// Use Case
class SyncTransactionsUseCase {
    func execute() async throws -> [Transaction] {
        do {
            let plaidTransactions = try await bankingService.fetchTransactions()
            return try await transactionRepository.saveAll(plaidTransactions)
        } catch let error as PlaidError {
            throw AppError.plaidError(error)
        } catch let error as DatabaseError {
            throw AppError.databaseError(error)
        } catch {
            throw AppError.networkError(.unknown)
        }
    }
}

// ViewModel
@Observable
class DashboardViewModel {
    var errorState: ErrorState?

    enum ErrorState {
        case transient(String) // Show toast
        case blocking(String)  // Show alert
        case recoverable(String, action: () -> Void) // Show alert with retry
    }

    func syncTransactions() async {
        do {
            transactions = try await syncTransactionsUseCase.execute()
        } catch let error as AppError {
            handleError(error)
        }
    }

    private func handleError(_ error: AppError) {
        switch error {
        case .networkError:
            errorState = .recoverable("Network connection failed") { [weak self] in
                Task { await self?.syncTransactions() }
            }
        case .authenticationError:
            errorState = .blocking("Please reconnect your bank account")
        default:
            errorState = .transient(error.localizedDescription)
        }
    }
}
```

### Offline Mode Strategy

```swift
protocol OfflineCapable {
    var requiresNetwork: Bool { get }
    func cacheKey() -> String?
}

class NetworkAwareRepository {
    private let cache: Cache
    private let networkClient: NetworkClient

    func fetch<T: Codable & OfflineCapable>(
        _ endpoint: Endpoint
    ) async throws -> T {
        // Try network first
        if networkClient.isConnected {
            do {
                let data = try await networkClient.fetch(endpoint)
                if let cacheKey = data.cacheKey() {
                    cache.set(data, forKey: cacheKey)
                }
                return data
            } catch {
                // Fall back to cache
                if let cached: T = cache.get(forKey: endpoint.cacheKey) {
                    return cached
                }
                throw error
            }
        } else {
            // Offline mode: Use cache
            if let cached: T = cache.get(forKey: endpoint.cacheKey) {
                return cached
            }
            throw AppError.networkError(.offline)
        }
    }
}
```

## Performance Considerations

### Memory Management
- Use `@MainActor` for UI-bound ViewModels
- Background contexts for heavy operations
- Lazy loading for large data sets
- Image caching with size limits

### Rendering Performance
- 60fps target for all animations
- LOD (Level of Detail) for 3D objects
- Particle pooling for money flow
- Culling for off-screen objects

### Database Performance
- Batch operations for bulk inserts
- Fetch request optimization with predicates
- Indexes on frequently queried fields
- Pagination for large result sets

## Security Architecture

### Data Protection
```swift
// Core Data store encryption
let storeDescription = NSPersistentStoreDescription()
storeDescription.setOption(
    FileProtectionType.complete as NSObject,
    forKey: NSPersistentStoreFileProtectionKey
)
```

### Keychain Storage
```swift
// Sensitive data (Plaid tokens, encryption keys)
class SecureStorage {
    func save(token: String, for key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: token.data(using: .utf8)!,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        SecItemAdd(query as CFDictionary, nil)
    }
}
```

### Biometric Authentication
```swift
class BiometricAuthManager {
    func authenticate() async throws {
        let context = LAContext()
        let reason = "Unlock your financial data"

        try await context.evaluatePolicy(
            .deviceOwnerAuthenticationWithBiometrics,
            localizedReason: reason
        )
    }
}
```

## Monitoring & Logging

### Logging Strategy
```swift
import OSLog

extension Logger {
    static let banking = Logger(subsystem: "com.pfn", category: "banking")
    static let sync = Logger(subsystem: "com.pfn", category: "sync")
    static let ui = Logger(subsystem: "com.pfn", category: "ui")
}

// Usage
Logger.banking.info("Starting transaction sync")
Logger.banking.error("Sync failed: \(error.localizedDescription)")
```

### Crash Reporting
- Use MetricKit for production monitoring
- Custom crash logger for debug builds
- Privacy-preserving error reports (no PII)

---

**Document Status**: Ready for Implementation
**Next Steps**: Begin Data Model & Schema Design
