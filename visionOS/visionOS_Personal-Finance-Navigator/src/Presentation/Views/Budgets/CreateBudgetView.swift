// CreateBudgetView.swift
// Personal Finance Navigator
// Form for creating a new budget

import SwiftUI

struct CreateBudgetView: View {
    // MARK: - Environment
    @Environment(\.dismiss) private var dismiss

    // MARK: - State
    @State private var viewModel: BudgetViewModel
    @State private var name: String = ""
    @State private var startDate: Date = Date()
    @State private var endDate: Date = Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date()
    @State private var strategy: Budget.BudgetStrategy = .fiftyThirtyTwenty
    @State private var totalAmount: String = ""
    @State private var selectedCategories: Set<UUID> = []
    @State private var categoryAllocations: [UUID: String] = [:]

    @State private var categories: [Category] = []
    @State private var isSaving = false
    @State private var showError = false
    @State private var currentStep = 1

    private let categoryRepository: CategoryRepository

    // MARK: - Init
    init(viewModel: BudgetViewModel) {
        self._viewModel = State(initialValue: viewModel)
        self.categoryRepository = DependencyContainer.shared.categoryRepository
    }

    // MARK: - Body
    var body: some View {
        NavigationStack {
            Form {
                switch currentStep {
                case 1:
                    basicInfoStep
                case 2:
                    categorySelectionStep
                case 3:
                    allocationStep
                default:
                    basicInfoStep
                }
            }
            .navigationTitle("Create Budget")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    if currentStep < 3 {
                        Button("Next") {
                            currentStep += 1
                        }
                        .disabled(!isStepValid(currentStep))
                    } else {
                        Button("Create") {
                            Task {
                                await createBudget()
                            }
                        }
                        .disabled(!isStepValid(currentStep) || isSaving)
                    }
                }
            }
            .task {
                await loadCategories()
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

    // MARK: - Step 1: Basic Info
    private var basicInfoStep: some View {
        Group {
            Section {
                TextField("Budget Name", text: $name)

                Picker("Strategy", selection: $strategy) {
                    ForEach(Budget.BudgetStrategy.allCases, id: \.self) { strategy in
                        Text(strategy.displayName).tag(strategy)
                    }
                }
            } header: {
                Text("Budget Details")
            } footer: {
                Text("Choose a budgeting strategy that fits your financial goals.")
            }

            Section {
                DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                    .onChange(of: startDate) { _, newValue in
                        // Ensure end date is after start date
                        if endDate <= newValue {
                            endDate = Calendar.current.date(byAdding: .month, value: 1, to: newValue) ?? newValue
                        }
                    }

                DatePicker("End Date", selection: $endDate, in: startDate..., displayedComponents: .date)
            } header: {
                Text("Budget Period")
            }

            Section {
                HStack {
                    Text("Total Budget")
                    Spacer()
                    TextField("$0.00", text: $totalAmount)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 120)
                }
            } header: {
                Text("Amount")
            } footer: {
                if let amount = Decimal(string: totalAmount), amount > 0 {
                    let suggestions = viewModel.suggestBudgetAmounts(based: amount, strategy: strategy)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Suggested allocations:")
                            .font(.caption)
                            .fontWeight(.semibold)
                        ForEach(Array(suggestions.keys.sorted()), id: \.self) { key in
                            if let value = suggestions[key] {
                                Text("• \(key): \(viewModel.getFormattedAmount(value))")
                                    .font(.caption)
                            }
                        }
                    }
                    .foregroundStyle(.secondary)
                }
            }
        }
    }

    // MARK: - Step 2: Category Selection
    private var categorySelectionStep: some View {
        Group {
            Section {
                if categories.isEmpty {
                    Text("No categories available")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(expenseCategories) { category in
                        Toggle(isOn: Binding(
                            get: { selectedCategories.contains(category.id) },
                            set: { isSelected in
                                if isSelected {
                                    selectedCategories.insert(category.id)
                                    // Initialize allocation to 0
                                    categoryAllocations[category.id] = "0"
                                } else {
                                    selectedCategories.remove(category.id)
                                    categoryAllocations.removeValue(forKey: category.id)
                                }
                            }
                        )) {
                            HStack {
                                Image(systemName: category.icon)
                                    .foregroundStyle(.blue)
                                Text(category.name)
                            }
                        }
                    }
                }
            } header: {
                Text("Select Categories (\(selectedCategories.count) selected)")
            } footer: {
                Text("Choose the expense categories you want to track in this budget.")
            }
        }
    }

    // MARK: - Step 3: Allocations
    private var allocationStep: some View {
        Group {
            Section {
                ForEach(Array(selectedCategories), id: \.self) { categoryId in
                    if let category = categories.first(where: { $0.id == categoryId }) {
                        HStack {
                            HStack(spacing: 8) {
                                Image(systemName: category.icon)
                                    .foregroundStyle(.blue)
                                Text(category.name)
                            }

                            Spacer()

                            TextField("$0.00", text: Binding(
                                get: { categoryAllocations[categoryId] ?? "0" },
                                set: { categoryAllocations[categoryId] = $0 }
                            ))
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 100)
                        }
                    }
                }
            } header: {
                Text("Allocate Budget")
            } footer: {
                VStack(alignment: .leading, spacing: 4) {
                    let total = calculateTotalAllocated()
                    let budgetAmount = Decimal(string: totalAmount) ?? 0
                    let remaining = budgetAmount - total

                    HStack {
                        Text("Total Allocated:")
                        Spacer()
                        Text(viewModel.getFormattedAmount(total))
                            .fontWeight(.semibold)
                    }

                    HStack {
                        Text("Remaining:")
                        Spacer()
                        Text(viewModel.getFormattedAmount(remaining))
                            .fontWeight(.semibold)
                            .foregroundStyle(remaining >= 0 ? .green : .red)
                    }
                }
                .font(.caption)
            }
        }
    }

    // MARK: - Computed Properties
    private var expenseCategories: [Category] {
        categories.filter { $0.type == .expense }
    }

    // MARK: - Validation
    private func isStepValid(_ step: Int) -> Bool {
        switch step {
        case 1:
            return !name.trimmingCharacters(in: .whitespaces).isEmpty &&
                   !totalAmount.isEmpty &&
                   Decimal(string: totalAmount) != nil &&
                   Decimal(string: totalAmount)! > 0 &&
                   endDate > startDate
        case 2:
            return !selectedCategories.isEmpty
        case 3:
            let totalAllocated = calculateTotalAllocated()
            let budgetAmount = Decimal(string: totalAmount) ?? 0
            return totalAllocated <= budgetAmount && totalAllocated > 0
        default:
            return false
        }
    }

    private func calculateTotalAllocated() -> Decimal {
        categoryAllocations.values.compactMap { Decimal(string: $0) }.reduce(0, +)
    }

    // MARK: - Load Data
    private func loadCategories() async {
        do {
            categories = try await categoryRepository.fetchActive()
        } catch {
            viewModel.errorMessage = "Failed to load categories"
            showError = true
        }
    }

    // MARK: - Create Budget
    private func createBudget() async {
        isSaving = true
        viewModel.clearError()

        guard let budgetAmount = Decimal(string: totalAmount), budgetAmount > 0 else {
            viewModel.errorMessage = "Invalid budget amount"
            showError = true
            isSaving = false
            return
        }

        // Create budget categories
        var budgetCategories: [BudgetCategory] = []
        for categoryId in selectedCategories {
            guard let category = categories.first(where: { $0.id == categoryId }),
                  let allocationStr = categoryAllocations[categoryId],
                  let allocation = Decimal(string: allocationStr),
                  allocation > 0 else { continue }

            let percentage = Double(truncating: (allocation / budgetAmount * 100) as NSDecimalNumber)

            let budgetCategory = BudgetCategory(
                id: UUID(),
                budgetId: UUID(), // Will be set when budget is created
                categoryId: categoryId,
                categoryName: category.name,
                allocated: allocation,
                spent: 0,
                percentageOfBudget: percentage,
                isRollover: false,
                rolledAmount: nil,
                alertAt75: true,
                alertAt90: true,
                alertAt100: true,
                alertOnOverspend: true
            )

            budgetCategories.append(budgetCategory)
        }

        // Create budget
        let budget = Budget(
            id: UUID(),
            name: name.trimmingCharacters(in: .whitespaces),
            startDate: startDate,
            endDate: endDate,
            totalAmount: budgetAmount,
            strategy: strategy,
            categories: budgetCategories
        )

        let success = await viewModel.createBudget(budget)

        isSaving = false

        if success {
            dismiss()
        } else {
            showError = true
        }
    }
}

// MARK: - Budget Strategy Extension
extension Budget.BudgetStrategy {
    var displayName: String {
        switch self {
        case .fiftyThirtyTwenty: return "50/30/20 Rule"
        case .zeroBased: return "Zero-Based Budget"
        case .envelope: return "Envelope Method"
        case .percentageBased: return "Percentage-Based"
        }
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

    return CreateBudgetView(viewModel: viewModel)
}
