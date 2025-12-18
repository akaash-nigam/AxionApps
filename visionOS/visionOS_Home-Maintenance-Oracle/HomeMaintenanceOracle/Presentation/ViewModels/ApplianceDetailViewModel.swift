//
//  ApplianceDetailViewModel.swift
//  HomeMaintenanceOracle
//
//  Created on 2025-11-24.
//  ViewModel for appliance detail view
//

import Foundation

@MainActor
class ApplianceDetailViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published var showEditSheet = false
    @Published var showDeleteConfirmation = false
    @Published var showManual = false
    @Published var showPartsLookup = false
    @Published var showAddMaintenanceTask = false
    @Published var showAddServiceRecord = false

    // MARK: - Properties

    let appliance: Appliance
    private let inventoryService: InventoryServiceProtocol

    // MARK: - Initialization

    init(
        appliance: Appliance,
        inventoryService: InventoryServiceProtocol = AppDependencies.shared.inventoryService
    ) {
        self.appliance = appliance
        self.inventoryService = inventoryService
    }

    // MARK: - Actions

    func deleteAppliance() async {
        do {
            try await inventoryService.deleteAppliance(appliance.id)
        } catch {
            print("Failed to delete appliance: \(error)")
            // TODO: Show error alert to user
        }
    }
}
