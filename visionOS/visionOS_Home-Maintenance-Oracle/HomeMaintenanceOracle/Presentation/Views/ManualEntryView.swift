//
//  ManualEntryView.swift
//  HomeMaintenanceOracle
//
//  Created on 2025-11-24.
//  Manual appliance entry form
//

import SwiftUI
import PhotosUI

struct ManualEntryView: View {

    // MARK: - Properties

    @StateObject private var viewModel = ManualEntryViewModel()
    @Environment(\.dismiss) private var dismiss

    // Photo picker
    @State private var selectedPhotoItem: PhotosPickerItem?

    // MARK: - Body

    var body: some View {
        NavigationStack {
            Form {
                // Category Section
                Section("Appliance Type") {
                    Picker("Category", selection: $viewModel.selectedCategory) {
                        ForEach(ApplianceCategory.allCases, id: \.self) { category in
                            Label(category.displayName, systemImage: category.icon)
                                .tag(category)
                        }
                    }
                    .pickerStyle(.navigationLink)
                }

                // Basic Info Section
                Section("Basic Information") {
                    TextField("Brand", text: $viewModel.brand)
                        .autocorrectionDisabled()

                    TextField("Model Number", text: $viewModel.modelNumber)
                        .autocorrectionDisabled()

                    TextField("Serial Number (Optional)", text: $viewModel.serialNumber)
                        .autocorrectionDisabled()
                }

                // Installation Section
                Section("Installation Details") {
                    DatePicker(
                        "Installation Date",
                        selection: $viewModel.installationDate,
                        displayedComponents: .date
                    )

                    TextField("Location (Optional)", text: $viewModel.location)
                        .autocorrectionDisabled()
                }

                // Photo Section
                Section("Photo") {
                    if let image = viewModel.selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 200)
                            .cornerRadius(8)

                        Button("Remove Photo", role: .destructive) {
                            viewModel.selectedImage = nil
                            selectedPhotoItem = nil
                        }
                    } else {
                        PhotosPicker(
                            selection: $selectedPhotoItem,
                            matching: .images
                        ) {
                            Label("Add Photo", systemImage: "photo.badge.plus")
                        }
                    }
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
            .navigationTitle("Add Appliance")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveAppliance()
                    }
                    .disabled(!viewModel.isValid)
                }
            }
            .onChange(of: selectedPhotoItem) { oldValue, newValue in
                Task {
                    if let data = try? await newValue?.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        viewModel.selectedImage = image
                    }
                }
            }
            .alert("Success", isPresented: $viewModel.showSuccessAlert) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("Appliance added successfully")
            }
            .alert("Error", isPresented: $viewModel.showErrorAlert) {
                Button("OK") {}
            } message: {
                Text(viewModel.errorMessage ?? "Failed to save appliance")
            }
        }
    }

    // MARK: - Actions

    private func saveAppliance() {
        Task {
            await viewModel.saveAppliance()
        }
    }
}

// MARK: - ApplianceCategory Extension

extension ApplianceCategory {
    var displayName: String {
        rawValue.capitalized
    }
}

// MARK: - Preview

#Preview {
    ManualEntryView()
}
