//
//  EditApplianceViewModel.swift
//  HomeMaintenanceOracle
//
//  Created on 2025-11-24.
//  ViewModel for editing appliance details
//

import Foundation

@MainActor
class EditApplianceViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published var selectedCategory: ApplianceCategory
    @Published var brand: String
    @Published var modelNumber: String
    @Published var serialNumber: String
    @Published var installationDate: Date
    @Published var purchaseDate: Date
    @Published var warrantyExpiry: Date
    @Published var purchasePrice: Double?
    @Published var location: String
    @Published var notes: String

    @Published var validationErrors: [String] = []
    @Published var showSuccessAlert = false
    @Published var showErrorAlert = false
    @Published var errorMessage: String?

    // MARK: - Properties

    private let appliance: Appliance
    private let inventoryService: InventoryServiceProtocol

    // MARK: - Initialization

    init(
        appliance: Appliance,
        inventoryService: InventoryServiceProtocol = AppDependencies.shared.inventoryService
    ) {
        self.appliance = appliance
        self.inventoryService = inventoryService

        // Initialize form fields from appliance
        self.selectedCategory = appliance.category
        self.brand = appliance.brand
        self.modelNumber = appliance.model
        self.serialNumber = appliance.serialNumber ?? ""
        self.installationDate = appliance.installDate ?? Date()
        self.purchaseDate = appliance.purchaseDate ?? Date()
        self.warrantyExpiry = appliance.warrantyExpiry ?? Date().addingTimeInterval(31536000) // +1 year
        self.purchasePrice = appliance.purchasePrice
        self.location = appliance.roomLocation ?? ""
        self.notes = appliance.notes ?? ""
    }

    // MARK: - Computed Properties

    var isValid: Bool {
        validateForm()
        return validationErrors.isEmpty
    }

    // MARK: - Validation

    @discardableResult
    private func validateForm() -> Bool {
        validationErrors.removeAll()

        // Brand is required
        if brand.trimmingCharacters(in: .whitespaces).isEmpty {
            validationErrors.append("Brand is required")
        }

        // Model number is required
        if modelNumber.trimmingCharacters(in: .whitespaces).isEmpty {
            validationErrors.append("Model number is required")
        }

        // Installation date cannot be in the future
        if installationDate > Date() {
            validationErrors.append("Installation date cannot be in the future")
        }

        // Purchase date should be before installation date
        if purchaseDate > installationDate {
            validationErrors.append("Purchase date should be before installation date")
        }

        return validationErrors.isEmpty
    }

    // MARK: - Actions

    func saveChanges() async {
        guard validateForm() else {
            showErrorAlert = true
            errorMessage = "Please fix validation errors"
            return
        }

        do {
            // Create updated appliance
            let updatedAppliance = Appliance(
                id: appliance.id,
                brand: brand.trimmingCharacters(in: .whitespaces),
                model: modelNumber.trimmingCharacters(in: .whitespaces),
                serialNumber: serialNumber.isEmpty ? nil : serialNumber.trimmingCharacters(in: .whitespaces),
                category: selectedCategory,
                installDate: installationDate,
                purchaseDate: purchaseDate,
                purchasePrice: purchasePrice,
                warrantyExpiry: warrantyExpiry,
                notes: notes.isEmpty ? nil : notes.trimmingCharacters(in: .whitespaces),
                roomLocation: location.isEmpty ? nil : location.trimmingCharacters(in: .whitespaces),
                createdAt: appliance.createdAt,
                updatedAt: Date()
            )

            // Update in inventory
            try await inventoryService.updateAppliance(updatedAppliance)

            showSuccessAlert = true

        } catch {
            showErrorAlert = true
            errorMessage = error.localizedDescription
        }
    }
}
