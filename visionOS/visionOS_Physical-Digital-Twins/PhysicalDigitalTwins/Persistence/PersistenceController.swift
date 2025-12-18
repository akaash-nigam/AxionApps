//
//  PersistenceController.swift
//  PhysicalDigitalTwins
//
//  Core Data stack management
//

import CoreData
import Foundation

@MainActor
class PersistenceController: @unchecked Sendable {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    // Preview instance for SwiftUI previews
    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)

        // Add sample data for previews
        let viewContext = controller.container.viewContext
        // Sample data creation here

        return controller
    }()

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "PhysicalDigitalTwins")

        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        } else {
            // Set file protection for security
            if let description = container.persistentStoreDescriptions.first {
                description.setOption(
                    FileProtectionType.complete as NSObject,
                    forKey: NSPersistentStoreFileProtectionKey
                )
            }
        }

        container.loadPersistentStores { description, error in
            if let error = error {
                // In production, handle this more gracefully
                fatalError("Unable to load persistent stores: \(error)")
            }
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }

    func save() throws {
        let context = container.viewContext
        if context.hasChanges {
            try context.save()
        }
    }
}

// MARK: - Core Data Entity Extensions

extension InventoryItemEntity {
    convenience init(from item: InventoryItem, context: NSManagedObjectContext) {
        self.init(context: context)
        self.id = item.id
        self.purchaseDate = item.purchaseDate
        self.purchasePrice = item.purchasePrice as NSDecimalNumber?
        self.purchaseStore = item.purchaseStore
        self.currentValue = item.currentValue as NSDecimalNumber?
        self.locationName = item.locationName
        self.specificLocation = item.specificLocation
        self.condition = item.condition.rawValue
        self.conditionNotes = item.conditionNotes
        self.photosPaths = item.photosPaths
        self.isLent = item.isLent
        self.lentTo = item.lentTo
        self.lentDate = item.lentDate
        self.expectedReturnDate = item.expectedReturnDate
        self.notes = item.notes
        self.tags = item.tags
        self.isFavorite = item.isFavorite
        self.createdAt = item.createdAt
        self.updatedAt = item.updatedAt

        // Store digital twin as JSON
        if let twinData = try? JSONEncoder().encode(item.digitalTwin) {
            self.digitalTwinData = twinData
            self.digitalTwinType = item.digitalTwin.objectType.rawValue
        }
    }

    func toInventoryItem() throws -> InventoryItem {
        guard let id = self.id,
              let twinData = self.digitalTwinData,
              let createdAt = self.createdAt,
              let updatedAt = self.updatedAt else {
            throw DataError.corruptedData
        }

        let digitalTwin = try JSONDecoder().decode(AnyDigitalTwin.self, from: twinData)

        var item = InventoryItem(
            id: id,
            digitalTwin: digitalTwin,
            createdAt: createdAt,
            updatedAt: updatedAt
        )

        item.purchaseDate = self.purchaseDate
        item.purchasePrice = self.purchasePrice as Decimal?
        item.purchaseStore = self.purchaseStore
        item.currentValue = self.currentValue as Decimal?
        item.locationName = self.locationName
        item.specificLocation = self.specificLocation
        item.condition = ItemCondition(rawValue: self.condition ?? "good") ?? .good
        item.conditionNotes = self.conditionNotes
        item.photosPaths = self.photosPaths ?? []
        item.isLent = self.isLent
        item.lentTo = self.lentTo
        item.lentDate = self.lentDate
        item.expectedReturnDate = self.expectedReturnDate
        item.notes = self.notes
        item.tags = self.tags ?? []
        item.isFavorite = self.isFavorite

        return item
    }
}
