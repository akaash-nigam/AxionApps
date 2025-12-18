// PersistenceController.swift
// Personal Finance Navigator
// Core Data stack management with CloudKit sync

import CoreData
import OSLog

private let logger = Logger(subsystem: "com.pfn", category: "persistence")

/// Manages the Core Data stack with CloudKit synchronization
class PersistenceController {
    // MARK: - Singleton
    static let shared = PersistenceController()

    // MARK: - Preview
    /// In-memory instance for SwiftUI previews
    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)

        // Add sample data for previews
        let viewContext = controller.container.viewContext
        // TODO: Add sample entities here for previews

        return controller
    }()

    // MARK: - Container
    let container: NSPersistentCloudKitContainer

    // MARK: - Init
    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "PersonalFinanceNavigator")

        if inMemory {
            // For testing/previews: use in-memory store
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        } else {
            // Configure persistent store for production
            guard let description = container.persistentStoreDescriptions.first else {
                fatalError("Failed to retrieve persistent store description")
            }

            // Enable persistent history tracking (required for CloudKit)
            description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
            description.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)

            // Enable file protection
            description.setOption(
                FileProtectionType.complete as NSObject,
                forKey: NSPersistentStoreFileProtectionKey
            )

            // Configure CloudKit
            let cloudKitOptions = description.cloudKitContainerOptions
            cloudKitOptions?.databaseScope = .private

            logger.info("Configured Core Data with CloudKit sync")
        }

        // Load persistent stores
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                logger.error("Core Data store failed to load: \(error.localizedDescription)")
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }

            logger.info("Core Data store loaded successfully")
        }

        // Configure view context
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy

        // Set up remote change notifications
        setupRemoteChangeNotifications()
    }

    // MARK: - Remote Change Notifications
    private func setupRemoteChangeNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleRemoteChange),
            name: .NSPersistentStoreRemoteChange,
            object: container.persistentStoreCoordinator
        )
    }

    @objc private func handleRemoteChange(_ notification: Notification) {
        logger.info("Remote change detected from CloudKit")

        // Merge changes into view context
        Task { @MainActor in
            container.viewContext.perform {
                self.container.viewContext.mergeChanges(fromContextDidSave: notification)
            }
        }
    }

    // MARK: - Save
    /// Saves changes in the view context
    func save() {
        let context = container.viewContext

        guard context.hasChanges else {
            logger.debug("No changes to save")
            return
        }

        do {
            try context.save()
            logger.info("Successfully saved Core Data changes")
        } catch {
            let nsError = error as NSError
            logger.error("Failed to save Core Data: \(nsError.localizedDescription)")

            // In production, you might want to present this error to the user
            // or attempt recovery
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }

    // MARK: - Background Operations
    /// Performs an operation on a background context
    func performBackgroundTask<T>(_ block: @escaping (NSManagedObjectContext) throws -> T) async throws -> T {
        try await withCheckedThrowingContinuation { continuation in
            container.performBackgroundTask { context in
                do {
                    let result = try block(context)

                    if context.hasChanges {
                        try context.save()
                    }

                    continuation.resume(returning: result)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    // MARK: - Batch Operations
    /// Deletes all data (for testing or user request)
    func deleteAllData() async throws {
        let entities = container.managedObjectModel.entities

        try await performBackgroundTask { context in
            for entity in entities {
                guard let entityName = entity.name else { continue }

                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
                let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

                try context.execute(deleteRequest)
            }
        }

        logger.warning("Deleted all Core Data entities")
    }
}

// MARK: - Preview Helpers
extension PersistenceController {
    /// Creates sample data for previews
    static func createSampleData(in context: NSManagedObjectContext) {
        // TODO: Implement sample data creation
        // This will be used for SwiftUI previews

        // Example:
        // let transaction = TransactionEntity(context: context)
        // transaction.id = UUID()
        // transaction.amount = -50.00
        // transaction.date = Date()
        // ...

        do {
            try context.save()
        } catch {
            logger.error("Failed to create sample data: \(error.localizedDescription)")
        }
    }
}
