// DashboardView.swift
// Personal Finance Navigator
// Main dashboard overview screen

import SwiftUI

/// Main dashboard view showing financial overview
struct DashboardView: View {
    @State private var viewModel: DashboardViewModel

    init(viewModel: DashboardViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.isLoading && viewModel.lastRefreshDate == nil {
                    // Initial loading state
                    ProgressView("Loading dashboard...")
                        .font(.title3)
                } else {
                    ScrollView {
                        VStack(spacing: 24) {
                            // Header with greeting
                            DashboardHeader(
                                lastRefreshDate: viewModel.lastRefreshDate
                            )

                            // Net Worth Card
                            NetWorthCard(
                                netWorth: viewModel.totalNetWorth,
                                assets: viewModel.totalAssets,
                                liabilities: viewModel.totalLiabilities,
                                trend: viewModel.netWorthTrend,
                                accountCount: viewModel.accountCount,
                                formatCurrency: viewModel.formatCurrency
                            )

                            // Budget Status Card
                            if viewModel.activeBudget != nil {
                                BudgetStatusCard(
                                    spent: viewModel.monthlySpent,
                                    budget: viewModel.monthlyBudgetAmount,
                                    percentage: viewModel.budgetPercentage,
                                    statusColor: viewModel.budgetStatusColor,
                                    daysRemaining: viewModel.budgetProgress?.daysRemaining ?? 0,
                                    statusMessage: viewModel.getStatusMessage(),
                                    formatCurrency: viewModel.formatCurrency,
                                    formatPercentage: viewModel.formatPercentage
                                )
                            }

                            // This Month Summary
                            MonthSummaryCard(
                                spending: viewModel.thisMonthSpending,
                                income: viewModel.thisMonthIncome,
                                transactionCount: viewModel.transactionCount,
                                formatCurrency: viewModel.formatCurrency
                            )

                            // Recent Transactions
                            RecentTransactionsCard(
                                transactions: viewModel.recentTransactions,
                                formatCurrency: viewModel.formatCurrency
                            )

                            // Quick Actions
                            QuickActionsSection()
                        }
                        .padding()
                    }
                    .refreshable {
                        await viewModel.refresh()
                    }
                }

                // Error overlay
                if let errorMessage = viewModel.errorMessage {
                    ErrorBanner(message: errorMessage)
                }
            }
            .navigationTitle("Dashboard")
            .task {
                if viewModel.lastRefreshDate == nil {
                    await viewModel.loadDashboard()
                }
            }
        }
    }
}

// MARK: - Dashboard Header

struct DashboardHeader: View {
    let lastRefreshDate: Date?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(greeting)
                .font(.largeTitle)
                .fontWeight(.bold)

            if let date = lastRefreshDate {
                HStack {
                    Image(systemName: "clock")
                        .foregroundStyle(.secondary)
                    Text("Updated \(timeAgo(date))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12: return "Good Morning"
        case 12..<17: return "Good Afternoon"
        default: return "Good Evening"
        }
    }

    private func timeAgo(_ date: Date) -> String {
        let seconds = Date().timeIntervalSince(date)
        if seconds < 60 {
            return "just now"
        } else if seconds < 3600 {
            return "\(Int(seconds / 60))m ago"
        } else if seconds < 86400 {
            return "\(Int(seconds / 3600))h ago"
        } else {
            return "\(Int(seconds / 86400))d ago"
        }
    }
}

// MARK: - Net Worth Card

struct NetWorthCard: View {
    let netWorth: Decimal
    let assets: Decimal
    let liabilities: Decimal
    let trend: TrendDirection
    let accountCount: Int
    let formatCurrency: (Decimal) -> String

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Net Worth")
                        .font(.headline)
                        .foregroundStyle(.secondary)

                    Text(formatCurrency(netWorth))
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .minimumScaleFactor(0.7)
                }

                Spacer()

                // Trend indicator
                HStack(spacing: 4) {
                    Image(systemName: trend.systemImage)
                    Text("0%")
                }
                .font(.callout)
                .fontWeight(.semibold)
                .foregroundColor(trend.color)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(trend.color.opacity(0.1))
                .clipShape(Capsule())
            }

            Divider()

            // Breakdown
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Assets")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(formatCurrency(assets))
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("Liabilities")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(formatCurrency(liabilities))
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.red)
                }
            }

            // Account count
            Label("\(accountCount) Active Accounts", systemImage: "creditcard.fill")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

// MARK: - Budget Status Card

struct BudgetStatusCard: View {
    let spent: Decimal
    let budget: Decimal
    let percentage: Double
    let statusColor: Color
    let daysRemaining: Int
    let statusMessage: String
    let formatCurrency: (Decimal) -> String
    let formatPercentage: (Double) -> String

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Budget Status")
                    .font(.headline)
                    .foregroundStyle(.secondary)

                Spacer()

                Text(statusMessage)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(statusColor)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(statusColor.opacity(0.15))
                    .clipShape(Capsule())
            }

            // Progress Circle
            HStack(spacing: 20) {
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 12)
                        .frame(width: 100, height: 100)

                    Circle()
                        .trim(from: 0, to: min(percentage / 100, 1.0))
                        .stroke(statusColor, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                        .frame(width: 100, height: 100)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut, value: percentage)

                    VStack {
                        Text(formatPercentage(percentage))
                            .font(.title2)
                            .fontWeight(.bold)
                        Text("spent")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    VStack(alignment: .leading) {
                        Text("Spent")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(formatCurrency(spent))
                            .font(.title3)
                            .fontWeight(.semibold)
                    }

                    VStack(alignment: .leading) {
                        Text("Budget")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(formatCurrency(budget))
                            .font(.title3)
                            .fontWeight(.semibold)
                    }
                }
            }

            Divider()

            HStack {
                Label("\(daysRemaining) days left", systemImage: "calendar")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer()

                let remaining = budget - spent
                Text("\(formatCurrency(remaining)) remaining")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

// MARK: - Month Summary Card

struct MonthSummaryCard: View {
    let spending: Decimal
    let income: Decimal
    let transactionCount: Int
    let formatCurrency: (Decimal) -> String

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("This Month")
                .font(.headline)
                .foregroundStyle(.secondary)

            HStack(spacing: 20) {
                // Spending
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.up.circle.fill")
                            .foregroundColor(.red)
                        Text("Spending")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    Text(formatCurrency(spending))
                        .font(.title2)
                        .fontWeight(.bold)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Divider()
                    .frame(height: 50)

                // Income
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.down.circle.fill")
                            .foregroundColor(.green)
                        Text("Income")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    Text(formatCurrency(income))
                        .font(.title2)
                        .fontWeight(.bold)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            Divider()

            Label("\(transactionCount) transactions", systemImage: "arrow.left.arrow.right")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

// MARK: - Recent Transactions Card

struct RecentTransactionsCard: View {
    let transactions: [Transaction]
    let formatCurrency: (Decimal) -> String

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Recent Transactions")
                    .font(.headline)
                    .foregroundStyle(.secondary)

                Spacer()

                NavigationLink {
                    // Navigate to full transaction list
                    Text("All Transactions")
                } label: {
                    Text("See All")
                        .font(.caption)
                        .fontWeight(.semibold)
                }
            }

            if transactions.isEmpty {
                EmptyTransactionsView()
            } else {
                VStack(spacing: 12) {
                    ForEach(transactions) { transaction in
                        TransactionRowCompact(
                            transaction: transaction,
                            formatCurrency: formatCurrency
                        )
                    }
                }
            }
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

struct EmptyTransactionsView: View {
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.largeTitle)
                .foregroundStyle(.secondary)

            Text("No recent transactions")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
    }
}

struct TransactionRowCompact: View {
    let transaction: Transaction
    let formatCurrency: (Decimal) -> String

    var body: some View {
        HStack(spacing: 12) {
            // Category icon
            Circle()
                .fill(categoryColor.opacity(0.2))
                .frame(width: 40, height: 40)
                .overlay {
                    Image(systemName: categoryIcon)
                        .foregroundColor(categoryColor)
                }

            // Details
            VStack(alignment: .leading, spacing: 2) {
                Text(transaction.merchantName ?? transaction.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)

                Text(transaction.primaryCategory)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // Amount
            Text(formatCurrency(transaction.amount))
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(transaction.amount < 0 ? .red : .green)
        }
        .padding(.vertical, 4)
    }

    private var categoryColor: Color {
        // Map categories to colors
        switch transaction.primaryCategory.lowercased() {
        case let cat where cat.contains("food"): return .orange
        case let cat where cat.contains("transport"): return .blue
        case let cat where cat.contains("shopping"): return .purple
        case let cat where cat.contains("entertainment"): return .pink
        case let cat where cat.contains("utilities"): return .cyan
        default: return .gray
        }
    }

    private var categoryIcon: String {
        switch transaction.primaryCategory.lowercased() {
        case let cat where cat.contains("food"): return "fork.knife"
        case let cat where cat.contains("transport"): return "car.fill"
        case let cat where cat.contains("shopping"): return "bag.fill"
        case let cat where cat.contains("entertainment"): return "tv.fill"
        case let cat where cat.contains("utilities"): return "bolt.fill"
        default: return "dollarsign.circle.fill"
        }
    }
}

// MARK: - Quick Actions Section

struct QuickActionsSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Actions")
                .font(.headline)
                .foregroundStyle(.secondary)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                QuickActionButton(
                    icon: "plus.circle.fill",
                    title: "Add Transaction",
                    color: .blue
                ) {
                    // Action
                }

                QuickActionButton(
                    icon: "chart.bar.fill",
                    title: "View Budget",
                    color: .purple
                ) {
                    // Action
                }

                QuickActionButton(
                    icon: "building.columns.fill",
                    title: "Add Account",
                    color: .green
                ) {
                    // Action
                }

                QuickActionButton(
                    icon: "arrow.triangle.2.circlepath",
                    title: "Sync Data",
                    color: .orange
                ) {
                    // Action
                }
            }
        }
    }
}

struct QuickActionButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)

                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
}

// MARK: - Error Banner

struct ErrorBanner: View {
    let message: String

    var body: some View {
        VStack {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.red)

                Text(message)
                    .font(.caption)
                    .foregroundColor(.white)

                Spacer()
            }
            .padding()
            .background(Color.red.opacity(0.9))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding()

            Spacer()
        }
    }
}

// MARK: - Preview

#Preview {
    let container = DependencyContainer()
    let viewModel = DashboardViewModel(
        accountRepository: container.accountRepository,
        transactionRepository: container.transactionRepository,
        budgetRepository: container.budgetRepository
    )
    return DashboardView(viewModel: viewModel)
}
