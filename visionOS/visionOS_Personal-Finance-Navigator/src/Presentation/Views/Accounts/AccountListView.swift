// AccountListView.swift
// Personal Finance Navigator
// List view for all accounts

import SwiftUI

struct AccountListView: View {
    // MARK: - State
    @State private var viewModel: AccountViewModel
    @State private var showAddAccount = false
    @State private var selectedAccount: Account?
    @State private var showDeleteAlert = false
    @State private var accountToDelete: Account?

    // MARK: - Init
    init(viewModel: AccountViewModel) {
        self._viewModel = State(initialValue: viewModel)
    }

    // MARK: - Body
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading && viewModel.accounts.isEmpty {
                    ProgressView("Loading accounts...")
                } else if viewModel.accounts.isEmpty {
                    emptyState
                } else {
                    accountsList
                }
            }
            .navigationTitle("Accounts")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showAddAccount = true
                    } label: {
                        Label("Add Account", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddAccount) {
                AddEditAccountView(viewModel: viewModel, account: nil)
            }
            .sheet(item: $selectedAccount) { account in
                AddEditAccountView(viewModel: viewModel, account: account)
            }
            .alert("Delete Account", isPresented: $showDeleteAlert, presenting: accountToDelete) { account in
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    Task {
                        _ = await viewModel.deleteAccount(account)
                    }
                }
            } message: { account in
                Text("Are you sure you want to delete \(account.name)? This action cannot be undone.")
            }
            .task {
                await viewModel.loadAccounts()
            }
            .refreshable {
                await viewModel.refreshAccounts()
            }
        }
    }

    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "building.columns")
                .font(.system(size: 60))
                .foregroundStyle(.blue.gradient)

            Text("No Accounts")
                .font(.title)
                .fontWeight(.bold)

            Text("Add your first account to start tracking your finances")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button {
                showAddAccount = true
            } label: {
                Label("Add Account", systemImage: "plus.circle.fill")
                    .font(.headline)
            }
            .buttonStyle(.borderedProminent)
            .padding(.top)
        }
        .padding()
    }

    // MARK: - Accounts List
    private var accountsList: some View {
        List {
            // Net Worth Summary
            Section {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Total Net Worth")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        Text(viewModel.getFormattedNetWorth())
                            .font(.title2)
                            .fontWeight(.bold)
                    }

                    Spacer()

                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.title2)
                        .foregroundStyle(.green)
                }
                .padding(.vertical, 8)
            }

            // Accounts by Type
            ForEach(Array(viewModel.accountsByType.keys.sorted(by: { $0.rawValue < $1.rawValue })), id: \.self) { type in
                Section {
                    ForEach(viewModel.accountsByType[type] ?? []) { account in
                        AccountRow(account: account)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedAccount = account
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    accountToDelete = account
                                    showDeleteAlert = true
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }

                                Button {
                                    selectedAccount = account
                                } label: {
                                    Label("Edit", systemImage: "pencil")
                                }
                                .tint(.blue)
                            }
                    }
                } header: {
                    Text(type.displayName)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
            }
        }
        .listStyle(.insetGrouped)
    }
}

// MARK: - Account Row
struct AccountRow: View {
    let account: Account

    var body: some View {
        HStack(spacing: 16) {
            // Icon
            Image(systemName: account.type.icon)
                .font(.title2)
                .foregroundStyle(account.type.color)
                .frame(width: 40, height: 40)
                .background(account.type.color.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))

            // Account info
            VStack(alignment: .leading, spacing: 4) {
                Text(account.name)
                    .font(.body)
                    .fontWeight(.medium)

                if let institution = account.institutionName {
                    Text(institution)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                if let mask = account.mask {
                    Text("••••\(mask)")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }

            Spacer()

            // Balance
            VStack(alignment: .trailing, spacing: 4) {
                Text(formatBalance(account.currentBalance))
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundStyle(account.type == .creditCard ? .red : .primary)

                if let available = account.availableBalance, available != account.currentBalance {
                    Text("Avail: \(formatBalance(available))")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }

    private func formatBalance(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: amount as NSDecimalNumber) ?? "$0.00"
    }
}

// MARK: - Account Type Extensions
extension Account.AccountType {
    var displayName: String {
        switch self {
        case .checking: return "Checking"
        case .savings: return "Savings"
        case .creditCard: return "Credit Cards"
        case .investment: return "Investments"
        case .loan: return "Loans"
        }
    }

    var icon: String {
        switch self {
        case .checking: return "banknote"
        case .savings: return "dollarsign.circle"
        case .creditCard: return "creditcard"
        case .investment: return "chart.line.uptrend.xyaxis"
        case .loan: return "building.columns"
        }
    }

    var color: Color {
        switch self {
        case .checking: return .blue
        case .savings: return .green
        case .creditCard: return .orange
        case .investment: return .purple
        case .loan: return .red
        }
    }
}

// MARK: - Preview
#Preview {
    let repository = DependencyContainer.shared.accountRepository
    let viewModel = AccountViewModel(repository: repository)

    return AccountListView(viewModel: viewModel)
}
