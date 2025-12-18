// BudgetDetailView.swift
// Personal Finance Navigator
// Detailed budget view with progress tracking

import SwiftUI

struct BudgetDetailView: View {
    // MARK: - Environment
    @Environment(\.dismiss) private var dismiss

    // MARK: - State
    @State private var viewModel: BudgetViewModel
    @State private var budget: Budget
    @State private var isRefreshing = false

    // MARK: - Init
    init(viewModel: BudgetViewModel, budget: Budget) {
        self._viewModel = State(initialValue: viewModel)
        self._budget = State(initialValue: budget)
    }

    // MARK: - Body
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Overall Progress Card
                    overallProgressCard

                    // Category Breakdown
                    categoryBreakdownSection

                    // Budget Info
                    budgetInfoSection
                }
                .padding()
            }
            .navigationTitle(budget.name)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        Task {
                            await refreshBudget()
                        }
                    } label: {
                        Label("Refresh", systemImage: "arrow.clockwise")
                    }
                    .disabled(isRefreshing)
                }
            }
            .task {
                await refreshBudget()
            }
        }
    }

    // MARK: - Overall Progress Card
    private var overallProgressCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Overall Progress")
                .font(.headline)

            if let progress = viewModel.activeBudgetProgress {
                // Progress Circle
                HStack(spacing: 32) {
                    ZStack {
                        Circle()
                            .stroke(Color.gray.opacity(0.2), lineWidth: 12)
                            .frame(width: 120, height: 120)

                        Circle()
                            .trim(from: 0, to: min(progress.percentage / 100, 1.0))
                            .stroke(
                                viewModel.budgetStatusColor.gradient,
                                style: StrokeStyle(lineWidth: 12, lineCap: .round)
                            )
                            .frame(width: 120, height: 120)
                            .rotationEffect(.degrees(-90))

                        VStack(spacing: 4) {
                            Text(viewModel.formatPercentage(progress.percentage))
                                .font(.title)
                                .fontWeight(.bold)

                            Text("spent")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Spent")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(viewModel.getFormattedAmount(progress.spent))
                                .font(.title3)
                                .fontWeight(.semibold)
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Budget")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(viewModel.getFormattedAmount(progress.allocated))
                                .font(.title3)
                                .fontWeight(.semibold)
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text(progress.spent < progress.allocated ? "Remaining" : "Over Budget")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(viewModel.getFormattedAmount(
                                progress.spent < progress.allocated
                                    ? progress.allocated - progress.spent
                                    : progress.spent - progress.allocated
                            ))
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundStyle(progress.spent < progress.allocated ? .green : .red)
                        }
                    }
                }
            } else {
                Text("Loading progress...")
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }

    // MARK: - Category Breakdown
    private var categoryBreakdownSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Categories")
                .font(.headline)

            ForEach(budget.categories) { category in
                CategoryProgressRow(
                    category: category,
                    viewModel: viewModel
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }

    // MARK: - Budget Info
    private var budgetInfoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Budget Information")
                .font(.headline)

            VStack(spacing: 12) {
                InfoRow(label: "Period", value: viewModel.formatDateRange(from: budget.startDate, to: budget.endDate))
                Divider()
                InfoRow(label: "Strategy", value: budget.strategy.displayName)
                Divider()
                InfoRow(label: "Total Budget", value: viewModel.getFormattedAmount(budget.totalAmount))
                Divider()
                InfoRow(label: "Categories", value: "\(budget.categories.count)")
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }

    // MARK: - Refresh
    private func refreshBudget() async {
        isRefreshing = true
        await viewModel.updateBudgetProgress(for: budget)

        // Reload budget to get updated data
        if let updatedBudget = await viewModel.loadBudget(id: budget.id) {
            budget = updatedBudget
        }

        isRefreshing = false
    }
}

// MARK: - Category Progress Row
struct CategoryProgressRow: View {
    let category: BudgetCategory
    let viewModel: BudgetViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(category.categoryName ?? "Unknown")
                    .font(.subheadline)
                    .fontWeight(.medium)

                Spacer()

                Text(viewModel.getFormattedAmount(category.spent))
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Text("of")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(viewModel.getFormattedAmount(category.allocated))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            // Progress Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)
                        .cornerRadius(4)

                    Rectangle()
                        .fill(progressColor.gradient)
                        .frame(width: min(progressWidth(totalWidth: geometry.size.width), geometry.size.width), height: 8)
                        .cornerRadius(4)
                }
            }
            .frame(height: 8)

            // Progress Percentage
            HStack {
                Text(viewModel.formatPercentage(category.percentageOfBudget))
                    .font(.caption)
                    .foregroundStyle(progressColor)

                Spacer()

                if category.spent < category.allocated {
                    Text("\(viewModel.getFormattedAmount(category.allocated - category.spent)) left")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else if category.spent > category.allocated {
                    Text("\(viewModel.getFormattedAmount(category.spent - category.allocated)) over")
                        .font(.caption)
                        .foregroundStyle(.red)
                }
            }
        }
        .padding(.vertical, 4)
    }

    private var progressColor: Color {
        let percentage = category.percentageOfBudget

        if percentage >= 100 {
            return .red
        } else if percentage >= 90 {
            return .orange
        } else if percentage >= 75 {
            return .yellow
        } else {
            return .green
        }
    }

    private func progressWidth(totalWidth: CGFloat) -> CGFloat {
        let percentage = category.percentageOfBudget / 100
        return totalWidth * CGFloat(percentage)
    }
}

// MARK: - Info Row
struct InfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)

            Spacer()

            Text(value)
                .fontWeight(.medium)
        }
        .font(.subheadline)
    }
}

// MARK: - Preview
#Preview {
    let budgetRepo = DependencyContainer.shared.budgetRepository
    let transactionRepo = DependencyContainer.shared.transactionRepository
    let categoryRepo = DependencyContainer.shared.categoryRepository

    let viewModel = BudgetViewModel(
        budgetRepository: budgetRepo,
        transactionRepository: transactionRepo,
        categoryRepository: categoryRepo
    )

    let sampleBudget = Budget(
        id: UUID(),
        name: "Monthly Budget",
        startDate: Date(),
        endDate: Calendar.current.date(byAdding: .month, value: 1, to: Date())!,
        totalAmount: 3000,
        strategy: .fiftyThirtyTwenty,
        categories: [
            BudgetCategory(
                id: UUID(),
                budgetId: UUID(),
                categoryId: UUID(),
                categoryName: "Food & Dining",
                allocated: 400,
                spent: 287.50,
                percentageOfBudget: 71.88,
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
                categoryName: "Transportation",
                allocated: 300,
                spent: 145.00,
                percentageOfBudget: 48.33,
                isRollover: false,
                rolledAmount: nil,
                alertAt75: true,
                alertAt90: true,
                alertAt100: true,
                alertOnOverspend: true
            )
        ]
    )

    return BudgetDetailView(viewModel: viewModel, budget: sampleBudget)
}
