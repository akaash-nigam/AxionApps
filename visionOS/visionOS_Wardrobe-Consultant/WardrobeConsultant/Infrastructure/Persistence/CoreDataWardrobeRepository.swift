//
//  CoreDataWardrobeRepository.swift
//  WardrobeConsultant
//
//  Created by Claude Code
//  Copyright © 2025 Wardrobe Consultant. All rights reserved.
//

import Foundation
import CoreData

/// Core Data implementation of WardrobeRepository
class CoreDataWardrobeRepository: WardrobeRepository {
    static let shared = CoreDataWardrobeRepository()

    private let persistenceController: PersistenceController

    init(persistenceController: PersistenceController = .shared) {
        self.persistenceController = persistenceController
    }

    // MARK: - CRUD Operations
    func fetch(id: UUID) async throws -> WardrobeItem {
        let context = persistenceController.container.viewContext

        return try await context.perform {
            let request = WardrobeItemEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            request.fetchLimit = 1

            guard let entity = try context.fetch(request).first else {
                throw WardrobeRepositoryError.itemNotFound(id)
            }

            return entity.toDomainModel()
        }
    }

    func fetchAll() async throws -> [WardrobeItem] {
        let context = persistenceController.container.viewContext

        return try await context.perform {
            let request = WardrobeItemEntity.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
            request.fetchBatchSize = 50

            let entities = try context.fetch(request)
            return entities.map { $0.toDomainModel() }
        }
    }

    func create(_ item: WardrobeItem) async throws -> WardrobeItem {
        let context = persistenceController.newBackgroundContext()

        return try await context.perform {
            let entity = WardrobeItemEntity(from: item, context: context)

            try context.save()
            return entity.toDomainModel()
        }
    }

    func update(_ item: WardrobeItem) async throws -> WardrobeItem {
        let context = persistenceController.newBackgroundContext()

        return try await context.perform {
            let request = WardrobeItemEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", item.id as CVarArg)
            request.fetchLimit = 1

            guard let entity = try context.fetch(request).first else {
                throw WardrobeRepositoryError.itemNotFound(item.id)
            }

            entity.updateFrom(item)
            try context.save()

            return entity.toDomainModel()
        }
    }

    func delete(id: UUID) async throws {
        let context = persistenceController.newBackgroundContext()

        try await context.perform {
            let request = WardrobeItemEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            request.fetchLimit = 1

            guard let entity = try context.fetch(request).first else {
                throw WardrobeRepositoryError.itemNotFound(id)
            }

            context.delete(entity)
            try context.save()
        }
    }

    // MARK: - Query Operations
    func fetchByCategory(_ category: ClothingCategory) async throws -> [WardrobeItem] {
        let context = persistenceController.container.viewContext

        return try await context.perform {
            let request = WardrobeItemEntity.fetchRequest()
            request.predicate = NSPredicate(format: "category == %@", category.rawValue)
            request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]

            let entities = try context.fetch(request)
            return entities.map { $0.toDomainModel() }
        }
    }

    func fetchBySeason(_ season: Season) async throws -> [WardrobeItem] {
        let context = persistenceController.container.viewContext

        return try await context.perform {
            let request = WardrobeItemEntity.fetchRequest()
            request.predicate = NSPredicate(
                format: "season == %@ OR season == %@",
                season.rawValue,
                Season.allSeason.rawValue
            )
            request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]

            let entities = try context.fetch(request)
            return entities.map { $0.toDomainModel() }
        }
    }

    func fetchByColor(_ color: String) async throws -> [WardrobeItem] {
        let context = persistenceController.container.viewContext

        return try await context.perform {
            let request = WardrobeItemEntity.fetchRequest()
            request.predicate = NSPredicate(
                format: "primaryColor == %@ OR secondaryColor == %@",
                color, color
            )
            request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]

            let entities = try context.fetch(request)
            return entities.map { $0.toDomainModel() }
        }
    }

    func fetchFavorites() async throws -> [WardrobeItem] {
        let context = persistenceController.container.viewContext

        return try await context.perform {
            let request = WardrobeItemEntity.fetchRequest()
            request.predicate = NSPredicate(format: "isFavorite == YES")
            request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]

            let entities = try context.fetch(request)
            return entities.map { $0.toDomainModel() }
        }
    }

    func search(query: String) async throws -> [WardrobeItem] {
        let context = persistenceController.container.viewContext

        return try await context.perform {
            let request = WardrobeItemEntity.fetchRequest()

            // Search in name, brand, category, notes
            let predicates = [
                NSPredicate(format: "name CONTAINS[cd] %@", query),
                NSPredicate(format: "brand CONTAINS[cd] %@", query),
                NSPredicate(format: "category CONTAINS[cd] %@", query),
                NSPredicate(format: "notes CONTAINS[cd] %@", query)
            ]
            request.predicate = NSCompoundPredicate(orPredicateWithSubpredicates: predicates)
            request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]

            let entities = try context.fetch(request)
            return entities.map { $0.toDomainModel() }
        }
    }

    // MARK: - Statistics
    func count() async throws -> Int {
        let context = persistenceController.container.viewContext

        return try await context.perform {
            let request = WardrobeItemEntity.fetchRequest()
            return try context.count(for: request)
        }
    }

    func getRecentlyAdded(limit: Int) async throws -> [WardrobeItem] {
        let context = persistenceController.container.viewContext

        return try await context.perform {
            let request = WardrobeItemEntity.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
            request.fetchLimit = limit

            let entities = try context.fetch(request)
            return entities.map { $0.toDomainModel() }
        }
    }

    func getMostWorn(limit: Int) async throws -> [WardrobeItem] {
        let context = persistenceController.container.viewContext

        return try await context.perform {
            let request = WardrobeItemEntity.fetchRequest()
            request.predicate = NSPredicate(format: "timesWorn > 0")
            request.sortDescriptors = [NSSortDescriptor(key: "timesWorn", ascending: false)]
            request.fetchLimit = limit

            let entities = try context.fetch(request)
            return entities.map { $0.toDomainModel() }
        }
    }

    func getLeastWorn(limit: Int) async throws -> [WardrobeItem] {
        let context = persistenceController.container.viewContext

        return try await context.perform {
            let request = WardrobeItemEntity.fetchRequest()
            request.sortDescriptors = [
                NSSortDescriptor(key: "timesWorn", ascending: true),
                NSSortDescriptor(key: "createdAt", ascending: false)
            ]
            request.fetchLimit = limit

            let entities = try context.fetch(request)
            return entities.map { $0.toDomainModel() }
        }
    }
}
