// AddEditAccountView.swift
// Personal Finance Navigator
// Form for adding/editing accounts

import SwiftUI

struct AddEditAccountView: View {
    // MARK: - Environment
    @Environment(\.dismiss) private var dismiss

    // MARK: - State
    @State private var viewModel: AccountViewModel
    @State private var name: String = ""
    @State private var type: Account.AccountType = .checking
    @State private var currentBalance: String = ""
    @State private var availableBalance: String = ""
    @State private var creditLimit: String = ""
    @State private var mask: String = ""
    @State private var institutionName: String = ""
    @State private var notes: String = ""
    @State private var isActive: Bool = true
    @State private var isSaving = false
    @State private var showError = false

    private let account: Account?
    private var isEditing: Bool { account != nil }

    // MARK: - Init
    init(viewModel: AccountViewModel, account: Account?) {
        self._viewModel = State(initialValue: viewModel)
        self.account = account

        if let account = account {
            self._name = State(initialValue: account.name)
            self._type = State(initialValue: account.type)
            self._currentBalance = State(initialValue: "\(account.currentBalance)")
            self._availableBalance = State(initialValue: account.availableBalance.map { "\($0)" } ?? "")
            self._creditLimit = State(initialValue: account.creditLimit.map { "\($0)" } ?? "")
            self._mask = State(initialValue: account.mask ?? "")
            self._institutionName = State(initialValue: account.institutionName ?? "")
            self._notes = State(initialValue: account.notes ?? "")
            self._isActive = State(initialValue: account.isActive)
        }
    }

    // MARK: - Body
    var body: some View {
        NavigationStack {
            Form {
                // MARK: - Basic Information
                Section {
                    TextField("Account Name", text: $name)

                    Picker("Account Type", selection: $type) {
                        ForEach(Account.AccountType.allCases, id: \.self) { type in
                            HStack {
                                Image(systemName: type.icon)
                                Text(type.displayName)
                            }
                            .tag(type)
                        }
                    }

                    TextField("Institution (optional)", text: $institutionName)

                    TextField("Last 4 Digits (optional)", text: $mask)
                        .keyboardType(.numberPad)
                        .onChange(of: mask) { _, newValue in
                            mask = String(newValue.prefix(4))
                        }
                } header: {
                    Text("Account Details")
                }

                // MARK: - Balance Information
                Section {
                    HStack {
                        Text("Current Balance")
                        Spacer()
                        TextField("$0.00", text: $currentBalance)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 120)
                    }

                    if type == .checking || type == .savings {
                        HStack {
                            Text("Available Balance")
                            Spacer()
                            TextField("$0.00", text: $availableBalance)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 120)
                        }
                    }

                    if type == .creditCard {
                        HStack {
                            Text("Credit Limit")
                            Spacer()
                            TextField("$0.00", text: $creditLimit)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 120)
                        }
                    }
                } header: {
                    Text("Balance")
                } footer: {
                    if type == .creditCard {
                        Text("Enter the current balance owed and your total credit limit.")
                    }
                }

                // MARK: - Additional Information
                Section {
                    TextField("Notes (optional)", text: $notes, axis: .vertical)
                        .lineLimit(3...6)

                    Toggle("Active", isOn: $isActive)
                } header: {
                    Text("Additional Info")
                } footer: {
                    Text("Inactive accounts won't appear in your dashboard or reports.")
                }
            }
            .navigationTitle(isEditing ? "Edit Account" : "Add Account")
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
                            await saveAccount()
                        }
                    }
                    .disabled(!isFormValid || isSaving)
                }
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

    // MARK: - Form Validation
    private var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !currentBalance.isEmpty &&
        Decimal(string: currentBalance) != nil
    }

    // MARK: - Save Account
    private func saveAccount() async {
        isSaving = true
        viewModel.clearError()

        // Parse balance values
        guard let balance = Decimal(string: currentBalance) else {
            viewModel.errorMessage = "Invalid balance amount"
            showError = true
            isSaving = false
            return
        }

        let available = availableBalance.isEmpty ? nil : Decimal(string: availableBalance)
        let limit = creditLimit.isEmpty ? nil : Decimal(string: creditLimit)

        // Create or update account
        let accountToSave: Account
        if let existing = account {
            accountToSave = Account(
                id: existing.id,
                name: name.trimmingCharacters(in: .whitespaces),
                officialName: existing.officialName,
                type: type,
                subtype: type.rawValue,
                currentBalance: balance,
                availableBalance: available,
                creditLimit: limit,
                mask: mask.isEmpty ? nil : mask,
                institutionId: existing.institutionId,
                institutionName: institutionName.isEmpty ? nil : institutionName.trimmingCharacters(in: .whitespaces),
                accountNumber: existing.accountNumber,
                routingNumber: existing.routingNumber,
                plaidAccountId: existing.plaidAccountId,
                isActive: isActive,
                isHidden: existing.isHidden,
                needsReconnection: existing.needsReconnection,
                lastSyncedAt: existing.lastSyncedAt,
                notes: notes.isEmpty ? nil : notes.trimmingCharacters(in: .whitespaces),
                createdAt: existing.createdAt,
                updatedAt: Date()
            )
        } else {
            accountToSave = Account(
                id: UUID(),
                name: name.trimmingCharacters(in: .whitespaces),
                type: type,
                currentBalance: balance,
                availableBalance: available,
                creditLimit: limit,
                mask: mask.isEmpty ? nil : mask,
                institutionName: institutionName.isEmpty ? nil : institutionName.trimmingCharacters(in: .whitespaces),
                isActive: isActive,
                notes: notes.isEmpty ? nil : notes.trimmingCharacters(in: .whitespaces)
            )
        }

        // Save account
        let success = if isEditing {
            await viewModel.updateAccount(accountToSave)
        } else {
            await viewModel.addAccount(accountToSave)
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
#Preview("Add Account") {
    let repository = DependencyContainer.shared.accountRepository
    let viewModel = AccountViewModel(repository: repository)

    return AddEditAccountView(viewModel: viewModel, account: nil)
}

#Preview("Edit Account") {
    let repository = DependencyContainer.shared.accountRepository
    let viewModel = AccountViewModel(repository: repository)

    let sampleAccount = Account(
        id: UUID(),
        name: "Chase Checking",
        type: .checking,
        currentBalance: 5432.10,
        availableBalance: 4888.90,
        mask: "1234",
        institutionName: "Chase"
    )

    return AddEditAccountView(viewModel: viewModel, account: sampleAccount)
}
