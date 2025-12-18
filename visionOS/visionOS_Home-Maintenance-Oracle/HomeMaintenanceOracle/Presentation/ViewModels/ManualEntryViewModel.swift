//
//  ManualEntryViewModel.swift
//  HomeMaintenanceOracle
//
//  Created on 2025-11-24.
//  ViewModel for manual appliance entry
//

import Foundation
import SwiftUI

@MainActor
class ManualEntryViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published var selectedCategory: ApplianceCategory = .refrigerator
    @Published var brand: String = ""
    @Published var modelNumber: String = ""
    @Published var serialNumber: String = ""
    @Published var installationDate: Date = Date()
    @Published var location: String = ""
    @Published var notes: String = ""
    @Published var selectedImage: UIImage?

    @Published var validationErrors: [String] = []
    @Published var showSuccessAlert = false
    @Published var showErrorAlert = false
    @Published var errorMessage: String?

    // MARK: - Dependencies

    private let inventoryService: InventoryServiceProtocol

    // MARK: - Initialization

    init(inventoryService: InventoryServiceProtocol = AppDependencies.shared.inventoryService) {
        self.inventoryService = inventoryService
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

        return validationErrors.isEmpty
    }

    // MARK: - Actions

    func saveAppliance() async {
        guard validateForm() else {
            showErrorAlert = true
            errorMessage = "Please fix validation errors"
            return
        }

        do {
            // Create appliance
            let appliance = Appliance(
                brand: brand.trimmingCharacters(in: .whitespaces),
                model: modelNumber.trimmingCharacters(in: .whitespaces),
                serialNumber: serialNumber.isEmpty ? nil : serialNumber.trimmingCharacters(in: .whitespaces),
                category: selectedCategory,
                installDate: installationDate,
                notes: notes.isEmpty ? nil : notes.trimmingCharacters(in: .whitespaces),
                roomLocation: location.isEmpty ? nil : location.trimmingCharacters(in: .whitespaces)
            )

            // Save to inventory
            try await inventoryService.addAppliance(appliance)

            // TODO: Save photo if selected
            // This will be implemented when photo storage is added

            showSuccessAlert = true

        } catch {
            showErrorAlert = true
            errorMessage = error.localizedDescription
        }
    }

    func reset() {
        selectedCategory = .refrigerator
        brand = ""
        modelNumber = ""
        serialNumber = ""
        installationDate = Date()
        location = ""
        notes = ""
        selectedImage = nil
        validationErrors.removeAll()
    }
}
