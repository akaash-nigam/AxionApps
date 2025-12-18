//
//  StorageService.swift
//  PhysicalDigitalTwins
//
//  Protocol for data storage operations
//

import Foundation

protocol StorageService: Sendable {
    func saveItem(_ item: InventoryItem) async throws
    func fetchAllItems() async throws -> [InventoryItem]
    func fetchItem(id: UUID) async throws -> InventoryItem?
    func deleteItem(_ item: InventoryItem) async throws
    func searchItems(query: String) async throws -> [InventoryItem]
}

@MainActor
class CoreDataStorageService: StorageService {
    private let persistenceController: PersistenceController

    init(persistenceController: PersistenceController) {
        self.persistenceController = persistenceController
    }

    func saveItem(_ item: InventoryItem) async throws {
        let context = persistenceController.container.viewContext

        // Check if item already exists
        let fetchRequest = InventoryItemEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", item.id as CVarArg)

        let existingItems = try context.fetch(fetchRequest)

        let entity: InventoryItemEntity
        if let existing = existingItems.first {
            entity = existing
        } else {
            entity = InventoryItemEntity(context: context)
        }

        // Update entity
        entity.id = item.id
        entity.purchaseDate = item.purchaseDate
        entity.purchasePrice = item.purchasePrice as NSDecimalNumber?
        entity.purchaseStore = item.purchaseStore
        entity.currentValue = item.currentValue as NSDecimalNumber?
        entity.locationName = item.locationName
        entity.specificLocation = item.specificLocation
        entity.condition = item.condition.rawValue
        entity.conditionNotes = item.conditionNotes
        entity.photosPaths = item.photosPaths
        entity.isLent = item.isLent
        entity.lentTo = item.lentTo
        entity.lentDate = item.lentDate
        entity.expectedReturnDate = item.expectedReturnDate
        entity.notes = item.notes
        entity.tags = item.tags
        entity.isFavorite = item.isFavorite
        entity.createdAt = item.createdAt
        entity.updatedAt = Date() // Always update timestamp

        // Store digital twin as JSON
        if let twinData = try? JSONEncoder().encode(item.digitalTwin) {
            entity.digitalTwinData = twinData
            entity.digitalTwinType = item.digitalTwin.objectType.rawValue
        }

        try persistenceController.save()
    }

    func fetchAllItems() async throws -> [InventoryItem] {
        let context = persistenceController.container.viewContext
        let fetchRequest = InventoryItemEntity.fetchRequest()

        // Sort by created date, newest first
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]

        let entities = try context.fetch(fetchRequest)
        return try entities.map { try $0.toInventoryItem() }
    }

    func fetchItem(id: UUID) async throws -> InventoryItem? {
        let context = persistenceController.container.viewContext
        let fetchRequest = InventoryItemEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        fetchRequest.fetchLimit = 1

        let entities = try context.fetch(fetchRequest)
        return try entities.first?.toInventoryItem()
    }

    func deleteItem(_ item: InventoryItem) async throws {
        let context = persistenceController.container.viewContext
        let fetchRequest = InventoryItemEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", item.id as CVarArg)

        let entities = try context.fetch(fetchRequest)
        if let entity = entities.first {
            context.delete(entity)
            try persistenceController.save()
        } else {
            throw DataError.notFound
        }
    }

    func searchItems(query: String) async throws -> [InventoryItem] {
        guard !query.isEmpty else {
            return try await fetchAllItems()
        }

        let context = persistenceController.container.viewContext
        let fetchRequest = InventoryItemEntity.fetchRequest()

        // Search in notes, tags, location, and purchase store
        let predicate = NSPredicate(
            format: "notes CONTAINS[cd] %@ OR purchaseStore CONTAINS[cd] %@ OR locationName CONTAINS[cd] %@",
            query, query, query
        )
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]

        let entities = try context.fetch(fetchRequest)
        return try entities.map { try $0.toInventoryItem() }
    }
}
