// AddEditTransactionView.swift
// Personal Finance Navigator
// Form for adding/editing transactions

import SwiftUI

struct AddEditTransactionView: View {
    // MARK: - Environment
    @Environment(\.dismiss) private var dismiss

    // MARK: - State
    @State private var viewModel: TransactionViewModel
    @State private var name: String = ""
    @State private var merchantName: String = ""
    @State private var amount: String = ""
    @State private var isExpense: Bool = true
    @State private var date: Date = Date()
    @State private var selectedAccountId: UUID?
    @State private var selectedCategoryId: UUID?
    @State private var notes: String = ""
    @State private var isPending: Bool = false
    @State private var isRecurring: Bool = false
    @State private var isSaving = false
    @State private var showError = false

    // Available accounts and categories
    @State private var accounts: [Account] = []
    @State private var categories: [Category] = []

    private let transaction: Transaction?
    private var isEditing: Bool { transaction != nil }

    // MARK: - Repositories
    private let accountRepository: AccountRepository
    private let categoryRepository: CategoryRepository

    // MARK: - Init
    init(viewModel: TransactionViewModel, transaction: Transaction?) {
        self._viewModel = State(initialValue: viewModel)
        self.transaction = transaction
        self.accountRepository = DependencyContainer.shared.accountRepository
        self.categoryRepository = DependencyContainer.shared.categoryRepository

        if let transaction = transaction {
            self._name = State(initialValue: transaction.name)
            self._merchantName = State(initialValue: transaction.merchantName ?? "")
            self._amount = State(initialValue: "\(abs(transaction.amount))")
            self._isExpense = State(initialValue: transaction.amount < 0)
            self._date = State(initialValue: transaction.date)
            self._selectedAccountId = State(initialValue: transaction.accountId)
            self._selectedCategoryId = State(initialValue: transaction.categoryId)
            self._notes = State(initialValue: transaction.notes ?? "")
            self._isPending = State(initialValue: transaction.isPending)
            self._isRecurring = State(initialValue: transaction.isRecurring)
        }
    }

    // MARK: - Body
    var body: some View {
        NavigationStack {
            Form {
                // MARK: - Basic Information
                Section {
                    TextField("Description", text: $name)

                    TextField("Merchant (optional)", text: $merchantName)
                } header: {
                    Text("Transaction Details")
                }

                // MARK: - Amount
                Section {
                    Picker("Type", selection: $isExpense) {
                        Label("Expense", systemImage: "arrow.up.circle.fill")
                            .tag(true)
                        Label("Income", systemImage: "arrow.down.circle.fill")
                            .tag(false)
                    }
                    .pickerStyle(.segmented)

                    HStack {
                        Text("Amount")
                        Spacer()
                        TextField("$0.00", text: $amount)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 120)
                    }

                    DatePicker("Date", selection: $date, displayedComponents: .date)
                } header: {
                    Text("Amount & Date")
                }

                // MARK: - Account & Category
                Section {
                    Picker("Account", selection: $selectedAccountId) {
                        Text("Select Account").tag(nil as UUID?)
                        ForEach(accounts) { account in
                            HStack {
                                Image(systemName: account.type.icon)
                                Text(account.name)
                            }
                            .tag(account.id as UUID?)
                        }
                    }

                    Picker("Category", selection: $selectedCategoryId) {
                        Text("Select Category").tag(nil as UUID?)
                        ForEach(filteredCategories) { category in
                            HStack {
                                Image(systemName: category.icon)
                                Text(category.name)
                            }
                            .tag(category.id as UUID?)
                        }
                    }
                } header: {
                    Text("Classification")
                }

                // MARK: - Additional Options
                Section {
                    TextField("Notes (optional)", text: $notes, axis: .vertical)
                        .lineLimit(3...6)

                    Toggle("Pending", isOn: $isPending)

                    Toggle("Recurring", isOn: $isRecurring)
                } header: {
                    Text("Additional Info")
                } footer: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("• Pending: Transaction hasn't cleared yet")
                        Text("• Recurring: This transaction repeats regularly")
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
            }
            .navigationTitle(isEditing ? "Edit Transaction" : "Add Transaction")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button(isEditing ? "Save" : "Add") {
                        Task {
                            await saveTransaction()
                        }
                    }
                    .disabled(!isFormValid || isSaving)
                }
            }
            .task {
                await loadAccountsAndCategories()
            }
            .alert("Error", isPresented: $showError) {
                Button("OK") { }
            } message: {
                if let error = viewModel.errorMessage {
                    Text(error)
                }
            }
        }
    }

    // MARK: - Filtered Categories
    private var filteredCategories: [Category] {
        categories.filter { category in
            if isExpense {
                return category.type == .expense
            } else {
                return category.type == .income
            }
        }
    }

    // MARK: - Form Validation
    private var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !amount.isEmpty &&
        Decimal(string: amount) != nil &&
        selectedAccountId != nil &&
        selectedCategoryId != nil
    }

    // MARK: - Load Data
    private func loadAccountsAndCategories() async {
        do {
            accounts = try await accountRepository.fetchActive()
            categories = try await categoryRepository.fetchActive()

            // Auto-select first account if none selected
            if selectedAccountId == nil, let firstAccount = accounts.first {
                selectedAccountId = firstAccount.id
            }
        } catch {
            viewModel.errorMessage = "Failed to load accounts and categories"
            showError = true
        }
    }

    // MARK: - Save Transaction
    private func saveTransaction() async {
        isSaving = true
        viewModel.clearError()

        // Parse amount
        guard let amountValue = Decimal(string: amount) else {
            viewModel.errorMessage = "Invalid amount"
            showError = true
            isSaving = false
            return
        }

        guard let accountId = selectedAccountId else {
            viewModel.errorMessage = "Please select an account"
            showError = true
            isSaving = false
            return
        }

        guard let categoryId = selectedCategoryId else {
            viewModel.errorMessage = "Please select a category"
            showError = true
            isSaving = false
            return
        }

        // Apply sign based on expense/income
        let signedAmount = isExpense ? -abs(amountValue) : abs(amountValue)

        // Create or update transaction
        let transactionToSave: Transaction
        if let existing = transaction {
            transactionToSave = Transaction(
                id: existing.id,
                accountId: accountId,
                amount: signedAmount,
                date: date,
                authorizedDate: date,
                name: name.trimmingCharacters(in: .whitespaces),
                merchantName: merchantName.isEmpty ? nil : merchantName.trimmingCharacters(in: .whitespaces),
                categoryId: categoryId,
                isPending: isPending,
                isRecurring: isRecurring,
                notes: notes.isEmpty ? nil : notes.trimmingCharacters(in: .whitespaces),
                plaidTransactionId: existing.plaidTransactionId,
                plaidAccountId: existing.plaidAccountId,
                accountOwner: existing.accountOwner,
                location: existing.location,
                paymentChannel: existing.paymentChannel,
                transactionCode: existing.transactionCode,
                checkNumber: existing.checkNumber,
                excludeFromBudget: existing.excludeFromBudget,
                tags: existing.tags,
                createdAt: existing.createdAt,
                updatedAt: Date()
            )
        } else {
            transactionToSave = Transaction(
                id: UUID(),
                accountId: accountId,
                amount: signedAmount,
                date: date,
                authorizedDate: date,
                name: name.trimmingCharacters(in: .whitespaces),
                merchantName: merchantName.isEmpty ? nil : merchantName.trimmingCharacters(in: .whitespaces),
                categoryId: categoryId,
                isPending: isPending,
                isRecurring: isRecurring,
                notes: notes.isEmpty ? nil : notes.trimmingCharacters(in: .whitespaces)
            )
        }

        // Save transaction
        let success = if isEditing {
            await viewModel.updateTransaction(transactionToSave)
        } else {
            await viewModel.addTransaction(transactionToSave)
        }

        isSaving = false

        if success {
            dismiss()
        } else {
            showError = true
        }
    }
}

// MARK: - Preview
#Preview("Add Transaction") {
    let transactionRepo = DependencyContainer.shared.transactionRepository
    let accountRepo = DependencyContainer.shared.accountRepository
    let categoryRepo = DependencyContainer.shared.categoryRepository

    let viewModel = TransactionViewModel(
        transactionRepository: transactionRepo,
        accountRepository: accountRepo,
        categoryRepository: categoryRepo
    )

    return AddEditTransactionView(viewModel: viewModel, transaction: nil)
}

#Preview("Edit Transaction") {
    let transactionRepo = DependencyContainer.shared.transactionRepository
    let accountRepo = DependencyContainer.shared.accountRepository
    let categoryRepo = DependencyContainer.shared.categoryRepository

    let viewModel = TransactionViewModel(
        transactionRepository: transactionRepo,
        accountRepository: accountRepo,
        categoryRepository: categoryRepo
    )

    let sampleTransaction = Transaction(
        id: UUID(),
        accountId: UUID(),
        amount: -45.67,
        date: Date(),
        name: "Whole Foods",
        merchantName: "Whole Foods Market",
        categoryId: UUID(),
        isPending: false
    )

    return AddEditTransactionView(viewModel: viewModel, transaction: sampleTransaction)
}
