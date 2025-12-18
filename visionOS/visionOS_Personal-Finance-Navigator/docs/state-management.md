# State Management Design
# Personal Finance Navigator

**Version**: 1.0
**Last Updated**: 2025-11-24
**Status**: Draft

## Table of Contents
1. [Overview](#overview)
2. [Observation Framework](#observation-framework)
3. [ViewModel Architecture](#viewmodel-architecture)
4. [State Persistence](#state-persistence)
5. [State Synchronization](#state-synchronization)
6. [Navigation State](#navigation-state)

## Overview

Personal Finance Navigator uses Swift's native `@Observable` macro (iOS 17+) for reactive state management, following the MVVM pattern.

### State Management Principles
- **Single Source of Truth**: ViewModels own state
- **Unidirectional Data Flow**: State flows down, events flow up
- **Immutability**: Prefer immutable state updates
- **Testability**: ViewModels testable without UI

## Observation Framework

### Observable ViewModels

```swift
// DashboardViewModel.swift
import Observation

@Observable
@MainActor
class DashboardViewModel {
    // MARK: - State
    var transactions: [Transaction] = []
    var accounts: [Account] = []
    var totalBalance: Decimal = 0
    var isLoading = false
    var errorMessage: String?

    // MARK: - Dependencies
    private let syncTransactionsUseCase: SyncTransactionsUseCase
    private let accountRepository: AccountRepository

    // MARK: - Init
    init(
        syncTransactionsUseCase: SyncTransactionsUseCase,
        accountRepository: AccountRepository
    ) {
        self.syncTransactionsUseCase = syncTransactionsUseCase
        self.accountRepository = accountRepository
    }

    // MARK: - Actions
    func loadData() async {
        isLoading = true
        errorMessage = nil

        do {
            async let transactionsResult = syncTransactionsUseCase.execute()
            async let accountsResult = accountRepository.fetchAll()

            transactions = try await transactionsResult
            accounts = try await accountsResult

            calculateTotalBalance()
        } catch {
            errorMessage = "Failed to load data: \(error.localizedDescription)"
            Logger.ui.error("Dashboard load failed: \(error)")
        }

        isLoading = false
    }

    func refreshTransactions() async {
        do {
            transactions = try await syncTransactionsUseCase.execute()
            calculateTotalBalance()
        } catch {
            errorMessage = "Refresh failed: \(error.localizedDescription)"
        }
    }

    // MARK: - Private
    private func calculateTotalBalance() {
        totalBalance = accounts.reduce(0) { $0 + $1.currentBalance }
    }
}
```

### View Binding

```swift
// DashboardView.swift
struct DashboardView: View {
    @State private var viewModel: DashboardViewModel

    var body: some View {
        ScrollView {
            if viewModel.isLoading {
                ProgressView("Loading...")
            } else if let error = viewModel.errorMessage {
                ErrorView(message: error) {
                    Task { await viewModel.loadData() }
                }
            } else {
                contentView
            }
        }
        .task {
            await viewModel.loadData()
        }
        .refreshable {
            await viewModel.refreshTransactions()
        }
    }

    @ViewBuilder
    private var contentView: some View {
        VStack(spacing: 20) {
            // Balance card
            BalanceCard(balance: viewModel.totalBalance)

            // Accounts list
            ForEach(viewModel.accounts) { account in
                AccountRow(account: account)
            }

            // Recent transactions
            TransactionsList(transactions: viewModel.recentTransactions)
        }
    }
}
```

## ViewModel Architecture

### Base ViewModel Protocol

```swift
// BaseViewModel.swift
protocol BaseViewModel: AnyObject, Observable {
    var isLoading: Bool { get set }
    var errorMessage: String? { get set }

    func handleError(_ error: Error)
}

extension BaseViewModel {
    func handleError(_ error: Error) {
        errorMessage = error.localizedDescription
        Logger.ui.error("ViewModel error: \(error)")
    }
}
```

### Budget ViewModel

```swift
// BudgetViewModel.swift
@Observable
@MainActor
class BudgetViewModel: BaseViewModel {
    // MARK: - State
    var budget: Budget?
    var categories: [BudgetCategory] = []
    var spendingPercentage: Float = 0
    var isLoading = false
    var errorMessage: String?

    // MARK: - Computed Properties
    var totalSpent: Decimal {
        categories.reduce(0) { $0 + $1.spent }
    }

    var totalAllocated: Decimal {
        categories.reduce(0) { $0 + $1.allocated }
    }

    var remainingBudget: Decimal {
        totalAllocated - totalSpent
    }

    var isOverBudget: Bool {
        totalSpent > totalAllocated
    }

    var categoriesOverBudget: [BudgetCategory] {
        categories.filter { $0.spent > $0.allocated }
    }

    // MARK: - Dependencies
    private let budgetRepository: BudgetRepository
    private let createBudgetUseCase: CreateBudgetUseCase
    private let calculateBudgetStatusUseCase: CalculateBudgetStatusUseCase

    // MARK: - Actions
    func loadCurrentBudget() async {
        isLoading = true
        defer { isLoading = false }

        do {
            budget = try await budgetRepository.fetchCurrent()
            if let budget {
                categories = budget.categories
                calculateSpendingPercentage()
            }
        } catch {
            handleError(error)
        }
    }

    func createBudget(
        totalIncome: Decimal,
        strategy: BudgetStrategy
    ) async {
        isLoading = true
        defer { isLoading = false }

        do {
            budget = try await createBudgetUseCase.execute(
                totalIncome: totalIncome,
                strategy: strategy
            )
            categories = budget?.categories ?? []
        } catch {
            handleError(error)
        }
    }

    func updateCategory(
        _ category: BudgetCategory,
        newAllocated: Decimal
    ) async {
        do {
            var updated = category
            updated.allocated = newAllocated
            try await budgetRepository.updateCategory(updated)

            // Refresh budget
            await loadCurrentBudget()
        } catch {
            handleError(error)
        }
    }

    // MARK: - Private
    private func calculateSpendingPercentage() {
        guard totalAllocated > 0 else {
            spendingPercentage = 0
            return
        }

        spendingPercentage = Float(totalSpent / totalAllocated * 100)
    }
}
```

### Investment ViewModel

```swift
// InvestmentViewModel.swift
@Observable
@MainActor
class InvestmentViewModel: BaseViewModel {
    // MARK: - State
    var investmentAccounts: [InvestmentAccount] = []
    var selectedAccount: InvestmentAccount?
    var holdings: [Holding] = []
    var totalValue: Decimal = 0
    var totalGain: Decimal = 0
    var totalGainPercent: Float = 0
    var isLoading = false
    var errorMessage: String?

    // MARK: - Chart Data
    var assetAllocation: [AssetAllocationData] = []
    var performanceHistory: [PerformanceDataPoint] = []

    // MARK: - Dependencies
    private let investmentRepository: InvestmentRepository
    private let investmentSyncService: InvestmentSyncService

    // MARK: - Actions
    func loadInvestments() async {
        isLoading = true
        defer { isLoading = false }

        do {
            investmentAccounts = try await investmentRepository.fetchAll()
            calculateTotals()
            calculateAssetAllocation()
        } catch {
            handleError(error)
        }
    }

    func selectAccount(_ account: InvestmentAccount) async {
        selectedAccount = account

        do {
            holdings = try await investmentRepository.fetchHoldings(
                for: account.id
            )
        } catch {
            handleError(error)
        }
    }

    func syncInvestments() async {
        isLoading = true
        defer { isLoading = false }

        do {
            for account in investmentAccounts {
                _ = try await investmentSyncService.syncInvestments(
                    for: account.accountId.uuidString
                )
            }

            await loadInvestments()
        } catch {
            handleError(error)
        }
    }

    // MARK: - Private
    private func calculateTotals() {
        totalValue = investmentAccounts.reduce(0) { $0 + $1.totalValue }
        totalGain = investmentAccounts.reduce(0) { $0 + $1.totalGain }

        let totalCost = investmentAccounts.reduce(0) { $0 + $1.totalCost }
        if totalCost > 0 {
            totalGainPercent = Float(totalGain / totalCost * 100)
        }
    }

    private func calculateAssetAllocation() {
        var allocationMap: [SecurityType: Decimal] = [:]

        for account in investmentAccounts {
            for holding in account.holdings {
                allocationMap[holding.type, default: 0] += holding.currentValue
            }
        }

        assetAllocation = allocationMap.map { type, value in
            AssetAllocationData(
                type: type,
                value: value,
                percentage: Float(value / totalValue * 100)
            )
        }
    }
}

struct AssetAllocationData: Identifiable {
    let id = UUID()
    let type: SecurityType
    let value: Decimal
    let percentage: Float
}
```

## State Persistence

### User Preferences

```swift
// UserPreferencesStore.swift
@Observable
class UserPreferencesStore {
    // MARK: - Preferences
    var currency: String {
        didSet { save() }
    }

    var enableBiometric: Bool {
        didSet { save() }
    }

    var autoLockMinutes: Int {
        didSet { save() }
    }

    var enableNotifications: Bool {
        didSet { save() }
    }

    var privacyModeEnabled: Bool {
        didSet { save() }
    }

    // MARK: - Storage
    private let userDefaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults

        // Load preferences
        self.currency = userDefaults.string(forKey: "currency") ?? "USD"
        self.enableBiometric = userDefaults.bool(forKey: "enableBiometric")
        self.autoLockMinutes = userDefaults.integer(forKey: "autoLockMinutes")
        self.enableNotifications = userDefaults.bool(forKey: "enableNotifications")
        self.privacyModeEnabled = userDefaults.bool(forKey: "privacyModeEnabled")
    }

    private func save() {
        userDefaults.set(currency, forKey: "currency")
        userDefaults.set(enableBiometric, forKey: "enableBiometric")
        userDefaults.set(autoLockMinutes, forKey: "autoLockMinutes")
        userDefaults.set(enableNotifications, forKey: "enableNotifications")
        userDefaults.set(privacyModeEnabled, forKey: "privacyModeEnabled")
    }

    func reset() {
        currency = "USD"
        enableBiometric = false
        autoLockMinutes = 5
        enableNotifications = true
        privacyModeEnabled = false
    }
}
```

### App State

```swift
// AppState.swift
@Observable
@MainActor
class AppState {
    // MARK: - Authentication
    var isAuthenticated = false
    var currentUser: UserProfile?

    // MARK: - Onboarding
    var hasCompletedOnboarding = false

    // MARK: - Connectivity
    var isOnline = true
    var lastSyncDate: Date?

    // MARK: - Notifications
    var unreadNotificationsCount = 0

    // MARK: - Preferences
    var preferences = UserPreferencesStore()

    // MARK: - Init
    init() {
        loadState()
    }

    // MARK: - Actions
    func login(user: UserProfile) {
        currentUser = user
        isAuthenticated = true
        saveState()
    }

    func logout() {
        currentUser = nil
        isAuthenticated = false
        saveState()
    }

    func completeOnboarding() {
        hasCompletedOnboarding = true
        saveState()
    }

    func updateLastSync() {
        lastSyncDate = Date()
        saveState()
    }

    // MARK: - Persistence
    private func saveState() {
        let state = PersistedAppState(
            hasCompletedOnboarding: hasCompletedOnboarding,
            userId: currentUser?.id.uuidString,
            lastSyncDate: lastSyncDate
        )

        if let encoded = try? JSONEncoder().encode(state) {
            UserDefaults.standard.set(encoded, forKey: "app_state")
        }
    }

    private func loadState() {
        guard let data = UserDefaults.standard.data(forKey: "app_state"),
              let state = try? JSONDecoder().decode(PersistedAppState.self, from: data) else {
            return
        }

        hasCompletedOnboarding = state.hasCompletedOnboarding
        lastSyncDate = state.lastSyncDate
    }
}

struct PersistedAppState: Codable {
    let hasCompletedOnboarding: Bool
    let userId: String?
    let lastSyncDate: Date?
}
```

## State Synchronization

### Core Data Observation

```swift
// CoreDataObserver.swift
@Observable
@MainActor
class CoreDataObserver {
    var hasChanges = false

    init(context: NSManagedObjectContext) {
        NotificationCenter.default.addObserver(
            forName: .NSManagedObjectContextObjectsDidChange,
            object: context,
            queue: .main
        ) { [weak self] notification in
            self?.handleContextChange(notification)
        }
    }

    private func handleContextChange(_ notification: Notification) {
        guard let userInfo = notification.userInfo else { return }

        let inserted = userInfo[NSInsertedObjectsKey] as? Set<NSManagedObject> ?? []
        let updated = userInfo[NSUpdatedObjectsKey] as? Set<NSManagedObject> ?? []
        let deleted = userInfo[NSDeletedObjectsKey] as? Set<NSManagedObject> ?? []

        if !inserted.isEmpty || !updated.isEmpty || !deleted.isEmpty {
            hasChanges = true
            Logger.data.info("Core Data changes detected")

            // Notify ViewModels
            NotificationCenter.default.post(name: .dataDidChange, object: nil)
        }
    }
}

extension Notification.Name {
    static let dataDidChange = Notification.Name("dataDidChange")
}
```

### Real-time Updates

```swift
// View that auto-refreshes on data changes
struct TransactionsListView: View {
    @State private var viewModel: TransactionsViewModel

    var body: some View {
        List(viewModel.transactions) { transaction in
            TransactionRow(transaction: transaction)
        }
        .onReceive(NotificationCenter.default.publisher(for: .transactionsUpdated)) { _ in
            Task {
                await viewModel.refresh()
            }
        }
    }
}

extension Notification.Name {
    static let transactionsUpdated = Notification.Name("transactionsUpdated")
    static let accountsUpdated = Notification.Name("accountsUpdated")
    static let budgetUpdated = Notification.Name("budgetUpdated")
}
```

## Navigation State

### App Coordinator

```swift
// AppCoordinator.swift
@Observable
@MainActor
class AppCoordinator {
    var path = NavigationPath()
    var presentedSheet: Sheet?
    var presentedFullScreen: FullScreenCover?

    enum Destination: Hashable {
        case dashboard
        case budget
        case budgetDetail(Budget)
        case transactions
        case transactionDetail(Transaction)
        case accounts
        case accountDetail(Account)
        case investments
        case investmentDetail(InvestmentAccount)
        case goals
        case goalDetail(Goal)
        case debts
        case debtDetail(Debt)
        case settings
    }

    enum Sheet: Identifiable {
        case addTransaction
        case addAccount
        case createBudget
        case addGoal
        case addDebt

        var id: String {
            switch self {
            case .addTransaction: return "addTransaction"
            case .addAccount: return "addAccount"
            case .createBudget: return "createBudget"
            case .addGoal: return "addGoal"
            case .addDebt: return "addDebt"
            }
        }
    }

    enum FullScreenCover: Identifiable {
        case onboarding
        case plaidLink(linkToken: String)

        var id: String {
            switch self {
            case .onboarding: return "onboarding"
            case .plaidLink: return "plaidLink"
            }
        }
    }

    // MARK: - Navigation
    func navigate(to destination: Destination) {
        path.append(destination)
    }

    func popToRoot() {
        path.removeLast(path.count)
    }

    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    // MARK: - Sheets
    func presentSheet(_ sheet: Sheet) {
        presentedSheet = sheet
    }

    func dismissSheet() {
        presentedSheet = nil
    }

    // MARK: - Full Screen
    func presentFullScreen(_ cover: FullScreenCover) {
        presentedFullScreen = cover
    }

    func dismissFullScreen() {
        presentedFullScreen = nil
    }
}
```

### Navigation Implementation

```swift
// RootView.swift
struct RootView: View {
    @State private var coordinator = AppCoordinator()

    var body: some View {
        NavigationStack(path: $coordinator.path) {
            DashboardView()
                .navigationDestination(for: AppCoordinator.Destination.self) { destination in
                    destinationView(for: destination)
                }
        }
        .sheet(item: $coordinator.presentedSheet) { sheet in
            sheetView(for: sheet)
        }
        .fullScreenCover(item: $coordinator.presentedFullScreen) { cover in
            fullScreenView(for: cover)
        }
        .environment(coordinator)
    }

    @ViewBuilder
    private func destinationView(for destination: AppCoordinator.Destination) -> some View {
        switch destination {
        case .dashboard:
            DashboardView()
        case .budget:
            BudgetView()
        case .budgetDetail(let budget):
            BudgetDetailView(budget: budget)
        case .transactions:
            TransactionsView()
        case .transactionDetail(let transaction):
            TransactionDetailView(transaction: transaction)
        case .accounts:
            AccountsView()
        case .accountDetail(let account):
            AccountDetailView(account: account)
        case .investments:
            InvestmentsView()
        case .investmentDetail(let investmentAccount):
            InvestmentDetailView(investmentAccount: investmentAccount)
        case .goals:
            GoalsView()
        case .goalDetail(let goal):
            GoalDetailView(goal: goal)
        case .debts:
            DebtsView()
        case .debtDetail(let debt):
            DebtDetailView(debt: debt)
        case .settings:
            SettingsView()
        }
    }

    @ViewBuilder
    private func sheetView(for sheet: AppCoordinator.Sheet) -> some View {
        switch sheet {
        case .addTransaction:
            AddTransactionView()
        case .addAccount:
            AddAccountView()
        case .createBudget:
            CreateBudgetView()
        case .addGoal:
            AddGoalView()
        case .addDebt:
            AddDebtView()
        }
    }

    @ViewBuilder
    private func fullScreenView(for cover: AppCoordinator.FullScreenCover) -> some View {
        switch cover {
        case .onboarding:
            OnboardingView()
        case .plaidLink(let linkToken):
            PlaidLinkView(linkToken: linkToken)
        }
    }
}
```

---

**Document Status**: Ready for Implementation
**Next Steps**: UI/UX Design System & Spatial Layouts
