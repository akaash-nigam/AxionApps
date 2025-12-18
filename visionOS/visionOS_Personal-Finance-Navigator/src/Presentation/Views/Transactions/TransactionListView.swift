// TransactionListView.swift
// Personal Finance Navigator
// List view for all transactions

import SwiftUI

struct TransactionListView: View {
    // MARK: - State
    @State private var viewModel: TransactionViewModel
    @State private var showAddTransaction = false
    @State private var selectedTransaction: Transaction?
    @State private var showDeleteAlert = false
    @State private var transactionToDelete: Transaction?
    @State private var showFilterSheet = false

    // MARK: - Init
    init(viewModel: TransactionViewModel) {
        self._viewModel = State(initialValue: viewModel)
    }

    // MARK: - Body
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading && viewModel.transactions.isEmpty {
                    ProgressView("Loading transactions...")
                } else if viewModel.transactions.isEmpty {
                    emptyState
                } else if viewModel.filteredTransactions.isEmpty {
                    noResultsView
                } else {
                    transactionsList
                }
            }
            .navigationTitle("Transactions")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showFilterSheet = true
                    } label: {
                        Label("Filter", systemImage: hasActiveFilters ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                            .foregroundStyle(hasActiveFilters ? .blue : .primary)
                    }
                }

                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showAddTransaction = true
                    } label: {
                        Label("Add Transaction", systemImage: "plus")
                    }
                }
            }
            .searchable(text: $viewModel.searchQuery, prompt: "Search transactions")
            .sheet(isPresented: $showAddTransaction) {
                AddEditTransactionView(viewModel: viewModel, transaction: nil)
            }
            .sheet(item: $selectedTransaction) { transaction in
                AddEditTransactionView(viewModel: viewModel, transaction: transaction)
            }
            .sheet(isPresented: $showFilterSheet) {
                TransactionFilterView(viewModel: viewModel)
            }
            .alert("Delete Transaction", isPresented: $showDeleteAlert, presenting: transactionToDelete) { transaction in
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    Task {
                        _ = await viewModel.deleteTransaction(transaction)
                    }
                }
            } message: { transaction in
                Text("Are you sure you want to delete this transaction? This will also adjust your account balance.")
            }
            .task {
                await viewModel.loadTransactions()
            }
            .refreshable {
                await viewModel.refreshTransactions()
            }
        }
    }

    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 60))
                .foregroundStyle(.green.gradient)

            Text("No Transactions")
                .font(.title)
                .fontWeight(.bold)

            Text("Add your first transaction to start tracking your spending")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button {
                showAddTransaction = true
            } label: {
                Label("Add Transaction", systemImage: "plus.circle.fill")
                    .font(.headline)
            }
            .buttonStyle(.borderedProminent)
            .padding(.top)
        }
        .padding()
    }

    // MARK: - No Results View
    private var noResultsView: some View {
        VStack(spacing: 20) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)

            Text("No Results")
                .font(.title2)
                .fontWeight(.semibold)

            Text("No transactions match your current filters")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button("Clear Filters") {
                viewModel.clearFilters()
            }
            .buttonStyle(.bordered)
        }
        .padding()
    }

    // MARK: - Transactions List
    private var transactionsList: some View {
        List {
            // Summary Section
            if !viewModel.searchQuery.isEmpty || hasActiveFilters {
                Section {
                    SummaryRow(
                        label: "Income",
                        amount: viewModel.totalIncome,
                        color: .green
                    )

                    SummaryRow(
                        label: "Expenses",
                        amount: viewModel.totalExpenses,
                        color: .red
                    )

                    Divider()

                    SummaryRow(
                        label: "Net",
                        amount: viewModel.netAmount,
                        color: viewModel.netAmount >= 0 ? .green : .red,
                        isBold: true
                    )
                }
            }

            // Transactions by Date
            ForEach(viewModel.transactionsByDate, id: \.0) { date, transactions in
                Section {
                    ForEach(transactions) { transaction in
                        TransactionRow(transaction: transaction, viewModel: viewModel)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedTransaction = transaction
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    transactionToDelete = transaction
                                    showDeleteAlert = true
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }

                                Button {
                                    selectedTransaction = transaction
                                } label: {
                                    Label("Edit", systemImage: "pencil")
                                }
                                .tint(.blue)
                            }
                    }
                } header: {
                    Text(viewModel.formatDateSection(date))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
            }
        }
        .listStyle(.insetGrouped)
    }

    // MARK: - Helper Properties
    private var hasActiveFilters: Bool {
        viewModel.selectedAccountId != nil ||
        viewModel.selectedCategoryId != nil ||
        viewModel.showPendingOnly
    }
}

// MARK: - Transaction Row
struct TransactionRow: View {
    let transaction: Transaction
    let viewModel: TransactionViewModel

    var body: some View {
        HStack(spacing: 12) {
            // Category Icon
            Circle()
                .fill(categoryColor.opacity(0.2))
                .frame(width: 40, height: 40)
                .overlay {
                    Image(systemName: categoryIcon)
                        .foregroundStyle(categoryColor)
                }

            // Transaction Info
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.name)
                    .font(.body)
                    .fontWeight(.medium)

                if let merchant = transaction.merchantName, merchant != transaction.name {
                    Text(merchant)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                HStack(spacing: 8) {
                    if transaction.isPending {
                        Text("Pending")
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(.orange.opacity(0.2))
                            .foregroundStyle(.orange)
                            .cornerRadius(4)
                    }

                    if transaction.isRecurring {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .font(.caption2)
                            .foregroundStyle(.blue)
                    }
                }
            }

            Spacer()

            // Amount
            Text(viewModel.getFormattedAmount(transaction.amount))
                .font(.body)
                .fontWeight(.semibold)
                .foregroundStyle(transaction.amount >= 0 ? .green : .primary)
        }
        .padding(.vertical, 4)
    }

    private var categoryColor: Color {
        // TODO: Get actual category color
        transaction.amount >= 0 ? .green : .blue
    }

    private var categoryIcon: String {
        // TODO: Get actual category icon
        transaction.amount >= 0 ? "arrow.down.circle.fill" : "arrow.up.circle.fill"
    }
}

// MARK: - Summary Row
struct SummaryRow: View {
    let label: String
    let amount: Decimal
    let color: Color
    var isBold: Bool = false

    var body: some View {
        HStack {
            Text(label)
                .foregroundStyle(isBold ? .primary : .secondary)

            Spacer()

            Text(formatAmount(amount))
                .fontWeight(isBold ? .bold : .semibold)
                .foregroundStyle(color)
        }
    }

    private func formatAmount(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: amount as NSDecimalNumber) ?? "$0.00"
    }
}

// MARK: - Transaction Filter View
struct TransactionFilterView: View {
    @Environment(\.dismiss) private var dismiss
    @State var viewModel: TransactionViewModel

    var body: some View {
        NavigationStack {
            Form {
                Section("Account") {
                    // TODO: Add account picker
                    if viewModel.selectedAccountId != nil {
                        Button("Clear Account Filter") {
                            viewModel.selectedAccountId = nil
                        }
                    } else {
                        Text("All Accounts")
                            .foregroundStyle(.secondary)
                    }
                }

                Section("Category") {
                    // TODO: Add category picker
                    if viewModel.selectedCategoryId != nil {
                        Button("Clear Category Filter") {
                            viewModel.selectedCategoryId = nil
                        }
                    } else {
                        Text("All Categories")
                            .foregroundStyle(.secondary)
                    }
                }

                Section("Status") {
                    Toggle("Pending Only", isOn: $viewModel.showPendingOnly)
                }

                Section {
                    Button("Clear All Filters") {
                        viewModel.clearFilters()
                        dismiss()
                    }
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(.blue)
                }
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    let transactionRepo = DependencyContainer.shared.transactionRepository
    let accountRepo = DependencyContainer.shared.accountRepository
    let categoryRepo = DependencyContainer.shared.categoryRepository

    let viewModel = TransactionViewModel(
        transactionRepository: transactionRepo,
        accountRepository: accountRepo,
        categoryRepository: categoryRepo
    )

    return TransactionListView(viewModel: viewModel)
}
