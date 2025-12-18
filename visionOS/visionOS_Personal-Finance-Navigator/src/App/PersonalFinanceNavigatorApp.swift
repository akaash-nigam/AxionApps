// PersonalFinanceNavigatorApp.swift
// Personal Finance Navigator
// Main app entry point

import SwiftUI

@main
struct PersonalFinanceNavigatorApp: App {
    // MARK: - State
    @Environment(\.scenePhase) private var scenePhase
    @State private var hasCompletedOnboarding = false
    @State private var sessionManager = SessionManager()

    // MARK: - Dependencies
    let persistenceController = PersistenceController.shared
    let dependencyContainer = DependencyContainer.shared

    // MARK: - Body
    var body: some Scene {
        WindowGroup {
            Group {
                if sessionManager.isAuthenticated {
                    if hasCompletedOnboarding {
                        MainContentView()
                            .environment(sessionManager)
                    } else {
                        OnboardingView()
                    }
                } else {
                    AuthenticationView(sessionManager: sessionManager)
                }
            }
            .environment(\.managedObjectContext, persistenceController.container.viewContext)
            .onAppear {
                checkOnboardingStatus()
            }
            .onChange(of: scenePhase) { oldPhase, newPhase in
                handleScenePhaseChange(from: oldPhase, to: newPhase)
            }
        }
    }

    // MARK: - Private Methods
    private func checkOnboardingStatus() {
        // Check if user has completed onboarding
        hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
    }

    private func handleScenePhaseChange(from oldPhase: ScenePhase, to newPhase: ScenePhase) {
        switch newPhase {
        case .background:
            sessionManager.didEnterBackground()

        case .active:
            sessionManager.didBecomeActive()

        case .inactive:
            sessionManager.didBecomeInactive()

        @unknown default:
            break
        }
    }
}

// MARK: - Temporary Placeholder Views
// These will be replaced with actual implementations

struct MainContentView: View {
    var body: some View {
        TabView {
            DashboardPlaceholderView()
                .tabItem {
                    Label("Dashboard", systemImage: "chart.pie.fill")
                }

            AccountListView(
                viewModel: AccountViewModel(
                    repository: DependencyContainer.shared.accountRepository
                )
            )
            .tabItem {
                Label("Accounts", systemImage: "building.columns")
            }

            TransactionListView(
                viewModel: TransactionViewModel(
                    transactionRepository: DependencyContainer.shared.transactionRepository,
                    accountRepository: DependencyContainer.shared.accountRepository,
                    categoryRepository: DependencyContainer.shared.categoryRepository
                )
            )
            .tabItem {
                Label("Transactions", systemImage: "list.bullet")
            }

            BudgetListView(
                viewModel: BudgetViewModel(
                    budgetRepository: DependencyContainer.shared.budgetRepository,
                    transactionRepository: DependencyContainer.shared.transactionRepository,
                    categoryRepository: DependencyContainer.shared.categoryRepository
                )
            )
            .tabItem {
                Label("Budget", systemImage: "dollarsign.circle.fill")
            }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
    }
}

struct DashboardPlaceholderView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "chart.pie.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(.blue)

                Text("Dashboard")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Your financial overview will appear here")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .navigationTitle("Dashboard")
        }
    }
}

// TransactionsPlaceholderView removed - now using TransactionListView

// BudgetPlaceholderView removed - now using BudgetListView

// SettingsPlaceholderView removed - now using SettingsView

struct OnboardingView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "sparkles")
                .font(.system(size: 60))
                .foregroundStyle(.yellow)

            Text("Welcome!")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Onboarding flow will be implemented here")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Button("Skip Onboarding (Dev)") {
                UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}
