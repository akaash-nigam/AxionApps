// BudgetListView.swift
// Personal Finance Navigator
// List view for all budgets

import SwiftUI

struct BudgetListView: View {
    // MARK: - State
    @State private var viewModel: BudgetViewModel
    @State private var showCreateBudget = false
    @State private var selectedBudget: Budget?
    @State private var showDeleteAlert = false
    @State private var budgetToDelete: Budget?

    // MARK: - Init
    init(viewModel: BudgetViewModel) {
        self._viewModel = State(initialValue: viewModel)
    }

    // MARK: - Body
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading && viewModel.budgets.isEmpty {
                    ProgressView("Loading budgets...")
                } else if viewModel.budgets.isEmpty {
                    emptyState
                } else {
                    budgetsList
                }
            }
            .navigationTitle("Budgets")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showCreateBudget = true
                    } label: {
                        Label("Create Budget", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showCreateBudget) {
                CreateBudgetView(viewModel: viewModel)
            }
            .sheet(item: $selectedBudget) { budget in
                BudgetDetailView(viewModel: viewModel, budget: budget)
            }
            .alert("Delete Budget", isPresented: $showDeleteAlert, presenting: budgetToDelete) { budget in
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    Task {
                        _ = await viewModel.deleteBudget(budget)
                    }
                }
            } message: { budget in
                Text("Are you sure you want to delete \(budget.name)? This action cannot be undone.")
            }
            .task {
                await viewModel.loadBudgets()
            }
            .refreshable {
                await viewModel.refreshBudgets()
            }
        }
    }

    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "chart.bar.doc.horizontal")
                .font(.system(size: 60))
                .foregroundStyle(.orange.gradient)

            Text("No Budgets")
                .font(.title)
                .fontWeight(.bold)

            Text("Create your first budget to track your spending and reach your financial goals")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button {
                showCreateBudget = true
            } label: {
                Label("Create Budget", systemImage: "plus.circle.fill")
                    .font(.headline)
            }
            .buttonStyle(.borderedProminent)
            .padding(.top)
        }
        .padding()
    }

    // MARK: - Budgets List
    private var budgetsList: some View {
        List {
            // Active Budget Section
            if let activeBudget = viewModel.activeBudget {
                Section {
                    ActiveBudgetCard(budget: activeBudget, viewModel: viewModel)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedBudget = activeBudget
                        }
                } header: {
                    Text("Current Budget")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
            }

            // All Budgets Section
            Section {
                ForEach(viewModel.budgets) { budget in
                    BudgetRow(budget: budget, viewModel: viewModel)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedBudget = budget
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                budgetToDelete = budget
                                showDeleteAlert = true
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                }
            } header: {
                Text("All Budgets")
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
        }
        .listStyle(.insetGrouped)
    }
}

// MARK: - Active Budget Card
struct ActiveBudgetCard: View {
    let budget: Budget
    let viewModel: BudgetViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(budget.name)
                        .font(.title3)
                        .fontWeight(.bold)

                    Text(viewModel.formatDateRange(from: budget.startDate, to: budget.endDate))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                // Status Badge
                if let progress = viewModel.activeBudgetProgress {
                    Text(viewModel.formatPercentage(progress.percentage))
                        .font(.headline)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(viewModel.budgetStatusColor.gradient)
                        .cornerRadius(8)
                }
            }

            // Progress Bar
            if let progress = viewModel.activeBudgetProgress {
                VStack(alignment: .leading, spacing: 8) {
                    ProgressView(value: min(progress.percentage / 100, 1.0))
                        .tint(viewModel.budgetStatusColor)
                        .scaleEffect(x: 1, y: 2, anchor: .center)

                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Spent")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(viewModel.getFormattedAmount(progress.spent))
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: 2) {
                            Text("Budget")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(viewModel.getFormattedAmount(progress.allocated))
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        }
                    }
                }
            }

            // Categories Count
            HStack(spacing: 16) {
                Label("\(budget.categories.count) Categories", systemImage: "tag.fill")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if viewModel.isOverBudget {
                    Label("Over Budget", systemImage: "exclamationmark.triangle.fill")
                        .font(.caption)
                        .foregroundStyle(.red)
                }
            }
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Budget Row
struct BudgetRow: View {
    let budget: Budget
    let viewModel: BudgetViewModel

    var body: some View {
        HStack(spacing: 12) {
            // Icon
            Circle()
                .fill(statusColor.opacity(0.2))
                .frame(width: 40, height: 40)
                .overlay {
                    Image(systemName: "chart.bar.doc.horizontal.fill")
                        .foregroundStyle(statusColor)
                }

            // Budget Info
            VStack(alignment: .leading, spacing: 4) {
                Text(budget.name)
                    .font(.body)
                    .fontWeight(.medium)

                Text(viewModel.formatDateRange(from: budget.startDate, to: budget.endDate))
                    .font(.caption)
                    .foregroundStyle(.secondary)

                HStack(spacing: 8) {
                    Text("\(budget.categories.count) categories")
                        .font(.caption2)
                        .foregroundStyle(.secondary)

                    if isActive {
                        Text("Active")
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(.green.opacity(0.2))
                            .foregroundStyle(.green)
                            .cornerRadius(4)
                    }
                }
            }

            Spacer()

            // Total Amount
            Text(viewModel.getFormattedAmount(budget.totalAmount))
                .font(.body)
                .fontWeight(.semibold)
        }
        .padding(.vertical, 4)
    }

    private var isActive: Bool {
        let now = Date()
        return budget.startDate <= now && budget.endDate >= now
    }

    private var statusColor: Color {
        isActive ? .green : .gray
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

    return BudgetListView(viewModel: viewModel)
}
