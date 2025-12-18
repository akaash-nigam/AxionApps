//
//  PersistenceController.swift
//  HomeMaintenanceOracle
//
//  Created on 2025-11-24.
//  Core Data stack with CloudKit sync
//

import CoreData
import CloudKit

struct PersistenceController {

    // MARK: - Shared Instance

    static let shared = PersistenceController()

    // MARK: - Preview Instance

    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        let viewContext = controller.container.viewContext

        // Create sample data for previews
        for i in 0..<5 {
            let appliance = ApplianceEntity(context: viewContext)
            appliance.id = UUID()
            appliance.brand = ["GE", "Whirlpool", "Samsung", "LG", "Bosch"][i]
            appliance.model = "MODEL-\(String(format: "%03d", i))"
            appliance.category = ApplianceCategory.allCases[i % ApplianceCategory.allCases.count].rawValue
            appliance.createdAt = Date()
            appliance.updatedAt = Date()
        }

        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }

        return controller
    }()

    // MARK: - Properties

    let container: NSPersistentCloudKitContainer

    // MARK: - Initialization

    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "HomeMaintenanceOracle")

        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        } else {
            // Configure CloudKit
            guard let description = container.persistentStoreDescriptions.first else {
                fatalError("Failed to retrieve a persistent store description.")
            }

            // Enable persistent history tracking
            description.setOption(true as NSNumber,
                                forKey: NSPersistentHistoryTrackingKey)

            // Enable remote change notifications
            description.setOption(true as NSNumber,
                                forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)

            // CloudKit container options
            let containerIdentifier = "iCloud.com.hmo.HomeMaintenanceOracle"
            let options = NSPersistentCloudKitContainerOptions(containerIdentifier: containerIdentifier)
            description.cloudKitContainerOptions = options

            // File protection
            description.setOption(FileProtectionType.completeUnlessOpen as NSObject,
                                forKey: NSPersistentStoreFileProtectionKey)

            print("📦 CloudKit container: \(containerIdentifier)")
        }

        container.loadPersistentStores { description, error in
            if let error = error as NSError? {
                // Handle error appropriately in production
                print("❌ Core Data error: \(error), \(error.userInfo)")
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }

            print("✅ Core Data loaded: \(description)")
        }

        // Configure view context
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy

        // Set up notifications for remote changes
        NotificationCenter.default.addObserver(
            forName: .NSPersistentStoreRemoteChange,
            object: container.persistentStoreCoordinator,
            queue: .main
        ) { notification in
            print("📡 Remote Core Data change detected")
        }
    }

    // MARK: - Save Context

    func save() {
        let context = container.viewContext

        if context.hasChanges {
            do {
                try context.save()
                print("💾 Core Data saved successfully")
            } catch {
                let nsError = error as NSError
                print("❌ Save error: \(nsError), \(nsError.userInfo)")
                // Handle error appropriately in production
            }
        }
    }

    // MARK: - Background Context

    func newBackgroundContext() -> NSManagedObjectContext {
        let context = container.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }
}
