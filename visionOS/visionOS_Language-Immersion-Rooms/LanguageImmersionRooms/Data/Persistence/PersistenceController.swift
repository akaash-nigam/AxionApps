//
//  PersistenceController.swift
//  Language Immersion Rooms
//
//  CoreData persistence management
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "LanguageImmersionRooms")

        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Failed to load Core Data stack: \(error)")
            }
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy

        print("💾 CoreData initialized: \(description.url?.lastPathComponent ?? "unknown")")
    }

    // MARK: - Preview Support

    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        let context = controller.container.viewContext

        // Add sample data for previews
        let user = UserEntity(context: context)
        user.id = UUID()
        user.username = "Demo User"
        user.email = "demo@example.com"
        user.currentStreak = 7
        user.wordsEncounteredToday = 15

        do {
            try context.save()
        } catch {
            print("Preview data creation failed: \(error)")
        }

        return controller
    }()

    // MARK: - Save Context

    func save() {
        let context = container.viewContext

        if context.hasChanges {
            do {
                try context.save()
                print("💾 CoreData saved")
            } catch {
                print("❌ CoreData save error: \(error)")
            }
        }
    }

    // MARK: - Delete All Data

    func deleteAll() {
        let entities = container.managedObjectModel.entities
        for entity in entities {
            guard let entityName = entity.name else { continue }
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

            do {
                try container.viewContext.execute(deleteRequest)
                print("💾 Deleted all \(entityName)")
            } catch {
                print("❌ Delete error for \(entityName): \(error)")
            }
        }

        save()
    }
}
