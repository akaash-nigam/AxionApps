//
//  InventoryService.swift
//  HomeMaintenanceOracle
//
//  Created on 2025-11-24.
//

import Foundation

protocol InventoryServiceProtocol {
    func addAppliance(_ appliance: Appliance) async throws
    func updateAppliance(_ appliance: Appliance) async throws
    func deleteAppliance(_ id: UUID) async throws
}

class InventoryService: InventoryServiceProtocol {
    private let repository: InventoryRepositoryProtocol
    private let recognitionService: RecognitionServiceProtocol

    init(repository: InventoryRepositoryProtocol, recognitionService: RecognitionServiceProtocol) {
        self.repository = repository
        self.recognitionService = recognitionService
    }

    func addAppliance(_ appliance: Appliance) async throws {
        try await repository.create(appliance)
    }

    func updateAppliance(_ appliance: Appliance) async throws {
        try await repository.update(appliance)
    }

    func deleteAppliance(_ id: UUID) async throws {
        try await repository.delete(id)
    }
}

// Repository Protocol
protocol InventoryRepositoryProtocol {
    func create(_ appliance: Appliance) async throws
    func update(_ appliance: Appliance) async throws
    func delete(_ id: UUID) async throws
}

protocol MaintenanceRepositoryProtocol {}

class CoreDataInventoryRepository: InventoryRepositoryProtocol {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func create(_ appliance: Appliance) async throws {}
    func update(_ appliance: Appliance) async throws {}
    func delete(_ id: UUID) async throws {}
}

class CoreDataMaintenanceRepository: MaintenanceRepositoryProtocol {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }
}
