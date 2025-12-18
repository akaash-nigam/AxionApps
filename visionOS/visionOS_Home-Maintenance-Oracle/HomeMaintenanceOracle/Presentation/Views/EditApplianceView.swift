//
//  EditApplianceView.swift
//  HomeMaintenanceOracle
//
//  Created on 2025-11-24.
//  Edit appliance information form
//

import SwiftUI

struct EditApplianceView: View {

    // MARK: - Properties

    @StateObject private var viewModel: EditApplianceViewModel
    @Environment(\.dismiss) private var dismiss

    // MARK: - Initialization

    init(appliance: Appliance) {
        _viewModel = StateObject(wrappedValue: EditApplianceViewModel(appliance: appliance))
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            Form {
                // Basic Info Section
                Section("Basic Information") {
                    TextField("Brand", text: $viewModel.brand)
                        .autocorrectionDisabled()

                    TextField("Model Number", text: $viewModel.modelNumber)
                        .autocorrectionDisabled()

                    Picker("Category", selection: $viewModel.selectedCategory) {
                        ForEach(ApplianceCategory.allCases, id: \.self) { category in
                            Text(category.displayName).tag(category)
                        }
                    }

                    TextField("Serial Number (Optional)", text: $viewModel.serialNumber)
                        .autocorrectionDisabled()
                }

                // Location Section
                Section("Location") {
                    TextField("Location (Optional)", text: $viewModel.location)
                        .autocorrectionDisabled()
                }

                // Dates Section
                Section("Dates") {
                    DatePicker(
                        "Installation Date",
                        selection: $viewModel.installationDate,
                        displayedComponents: .date
                    )

                    DatePicker(
                        "Purchase Date (Optional)",
                        selection: $viewModel.purchaseDate,
                        displayedComponents: .date
                    )

                    DatePicker(
                        "Warranty Expiry (Optional)",
                        selection: $viewModel.warrantyExpiry,
                        displayedComponents: .date
                    )
                }

                // Financial Section
                Section("Financial") {
                    TextField("Purchase Price (Optional)", value: $viewModel.purchasePrice, format: .currency(code: "USD"))
                        .keyboardType(.decimalPad)
                }

                // Notes Section
                Section("Notes") {
                    TextEditor(text: $viewModel.notes)
                        .frame(minHeight: 100)
                }

                // Validation Errors
                if !viewModel.validationErrors.isEmpty {
                    Section {
                        ForEach(viewModel.validationErrors, id: \.self) { error in
                            Label(error, systemImage: "exclamationmark.triangle")
                                .foregroundStyle(.red)
                        }
                    }
                }
            }
            .navigationTitle("Edit Appliance")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveChanges()
                    }
                    .disabled(!viewModel.isValid)
                }
            }
            .alert("Success", isPresented: $viewModel.showSuccessAlert) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("Appliance updated successfully")
            }
            .alert("Error", isPresented: $viewModel.showErrorAlert) {
                Button("OK") {}
            } message: {
                Text(viewModel.errorMessage ?? "Failed to update appliance")
            }
        }
    }

    // MARK: - Actions

    private func saveChanges() {
        Task {
            await viewModel.saveChanges()
        }
    }
}

// MARK: - Preview

#Preview {
    EditApplianceView(
        appliance: Appliance(
            brand: "Samsung",
            model: "RF28R7351SR",
            serialNumber: "12345ABC",
            category: .refrigerator,
            installDate: Date(),
            purchasePrice: 2499.99,
            notes: "High-efficiency model",
            roomLocation: "Kitchen"
        )
    )
}
