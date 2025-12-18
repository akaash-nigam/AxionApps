//
//  PersistenceController.swift
//  WardrobeConsultant
//
//  Created by Claude Code
//  Copyright © 2025 Wardrobe Consultant. All rights reserved.
//

import Foundation
import CoreData

/// Manages Core Data stack
class PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    // MARK: - Initialization
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "WardrobeConsultant")

        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        // Configure store
        if let storeDescription = container.persistentStoreDescriptions.first {
            // Enable file protection
            storeDescription.setOption(
                FileProtectionType.complete as NSObject,
                forKey: NSPersistentStoreFileProtectionKey
            )

            // Enable persistent history tracking
            storeDescription.setOption(true as NSNumber,
                                      forKey: NSPersistentHistoryTrackingKey)

            // Enable remote change notifications
            storeDescription.setOption(true as NSNumber,
                                      forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        }

        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Core Data failed to load: \(error.localizedDescription)")
            }
        }

        // Configure context
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }

    // MARK: - Preview Helper
    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        // Add sample data here for previews
        return controller
    }()

    // MARK: - Background Context
    func newBackgroundContext() -> NSManagedObjectContext {
        let context = container.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }

    // MARK: - Save Context
    func save() throws {
        let context = container.viewContext

        if context.hasChanges {
            try context.save()
        }
    }

    // MARK: - Delete All Data (Testing/Development)
    func deleteAllData() async throws {
        let context = newBackgroundContext()

        try await context.perform {
            let entities = self.container.managedObjectModel.entities

            for entity in entities {
                if let entityName = entity.name {
                    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
                    let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

                    try context.execute(deleteRequest)
                }
            }

            try context.save()
        }
    }
}

// TODO: Create .xcdatamodeld file with the following entities:
// - WardrobeItemEntity
// - OutfitEntity
// - UserProfileEntity
//
// This will be done in Xcode's Data Model Editor
