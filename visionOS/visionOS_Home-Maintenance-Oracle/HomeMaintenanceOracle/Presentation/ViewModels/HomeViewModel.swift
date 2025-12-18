//
//  HomeViewModel.swift
//  HomeMaintenanceOracle
//
//  Created on 2025-11-24.
//

import Foundation
import CoreData

@MainActor
class HomeViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published var recentAppliances: [Appliance] = []
    @Published var showingRecognition = false
    @Published var error: Error?

    // MARK: - Dependencies

    private let inventoryService: InventoryServiceProtocol
    private let context: NSManagedObjectContext

    // MARK: - Initialization

    init(
        inventoryService: InventoryServiceProtocol = AppDependencies.shared.inventoryService,
        context: NSManagedObjectContext = PersistenceController.shared.container.viewContext
    ) {
        self.inventoryService = inventoryService
        self.context = context
        loadRecentAppliances()
    }

    // MARK: - Methods

    func loadRecentAppliances() {
        let request: NSFetchRequest<ApplianceEntity> = ApplianceEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \ApplianceEntity.createdAt, ascending: false)]
        request.fetchLimit = 5

        do {
            let entities = try context.fetch(request)
            recentAppliances = entities.map { $0.toAppliance() }
        } catch {
            self.error = error
            print("Error loading recent appliances: \(error)")
        }
    }
}
