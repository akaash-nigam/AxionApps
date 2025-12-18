//
//  CoreDataOutfitRepository.swift
//  WardrobeConsultant
//
//  Created by Claude Code
//  Copyright © 2025 Wardrobe Consultant. All rights reserved.
//

import Foundation
import CoreData

/// Core Data implementation of OutfitRepository
class CoreDataOutfitRepository: OutfitRepository {
    static let shared = CoreDataOutfitRepository()

    private let persistenceController: PersistenceController

    init(persistenceController: PersistenceController = .shared) {
        self.persistenceController = persistenceController
    }

    // MARK: - CRUD Operations
    func fetch(id: UUID) async throws -> Outfit {
        let context = persistenceController.container.viewContext

        return try await context.perform {
            let request = OutfitEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            request.fetchLimit = 1

            guard let entity = try context.fetch(request).first else {
                throw OutfitRepositoryError.outfitNotFound(id)
            }

            return entity.toDomainModel()
        }
    }

    func fetchAll() async throws -> [Outfit] {
        let context = persistenceController.container.viewContext

        return try await context.perform {
            let request = OutfitEntity.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
            request.fetchBatchSize = 50

            let entities = try context.fetch(request)
            return entities.map { $0.toDomainModel() }
        }
    }

    func create(_ outfit: Outfit) async throws -> Outfit {
        let context = persistenceController.newBackgroundContext()

        return try await context.perform {
            let entity = OutfitEntity(from: outfit, context: context)

            try context.save()
            return entity.toDomainModel()
        }
    }

    func update(_ outfit: Outfit) async throws -> Outfit {
        let context = persistenceController.newBackgroundContext()

        return try await context.perform {
            let request = OutfitEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", outfit.id as CVarArg)
            request.fetchLimit = 1

            guard let entity = try context.fetch(request).first else {
                throw OutfitRepositoryError.outfitNotFound(outfit.id)
            }

            entity.updateFrom(outfit)
            try context.save()

            return entity.toDomainModel()
        }
    }

    func delete(id: UUID) async throws {
        let context = persistenceController.newBackgroundContext()

        try await context.perform {
            let request = OutfitEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            request.fetchLimit = 1

            guard let entity = try context.fetch(request).first else {
                throw OutfitRepositoryError.outfitNotFound(id)
            }

            context.delete(entity)
            try context.save()
        }
    }

    // MARK: - Query Operations
    func fetchByOccasion(_ occasion: OccasionType) async throws -> [Outfit] {
        let context = persistenceController.container.viewContext

        return try await context.perform {
            let request = OutfitEntity.fetchRequest()
            request.predicate = NSPredicate(format: "occasionType == %@", occasion.rawValue)
            request.sortDescriptors = [
                NSSortDescriptor(key: "timesWorn", ascending: false),
                NSSortDescriptor(key: "name", ascending: true)
            ]

            let entities = try context.fetch(request)
            return entities.map { $0.toDomainModel() }
        }
    }

    func fetchFavorites() async throws -> [Outfit] {
        let context = persistenceController.container.viewContext

        return try await context.perform {
            let request = OutfitEntity.fetchRequest()
            request.predicate = NSPredicate(format: "isFavorite == YES")
            request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]

            let entities = try context.fetch(request)
            return entities.map { $0.toDomainModel() }
        }
    }

    func fetchRecent(limit: Int) async throws -> [Outfit] {
        let context = persistenceController.container.viewContext

        return try await context.perform {
            let request = OutfitEntity.fetchRequest()
            request.predicate = NSPredicate(format: "lastWornDate != nil")
            request.sortDescriptors = [NSSortDescriptor(key: "lastWornDate", ascending: false)]
            request.fetchLimit = limit

            let entities = try context.fetch(request)
            return entities.map { $0.toDomainModel() }
        }
    }

    func fetchByWeather(min: Int16, max: Int16) async throws -> [Outfit] {
        let context = persistenceController.container.viewContext

        return try await context.perform {
            let request = OutfitEntity.fetchRequest()
            request.predicate = NSPredicate(
                format: "temperatureMin <= %d AND temperatureMax >= %d",
                max, min
            )
            request.sortDescriptors = [NSSortDescriptor(key: "confidenceScore", ascending: false)]

            let entities = try context.fetch(request)
            return entities.map { $0.toDomainModel() }
        }
    }

    // MARK: - Statistics
    func count() async throws -> Int {
        let context = persistenceController.container.viewContext

        return try await context.perform {
            let request = OutfitEntity.fetchRequest()
            return try context.count(for: request)
        }
    }

    func getMostWorn(limit: Int) async throws -> [Outfit] {
        let context = persistenceController.container.viewContext

        return try await context.perform {
            let request = OutfitEntity.fetchRequest()
            request.predicate = NSPredicate(format: "timesWorn > 0")
            request.sortDescriptors = [NSSortDescriptor(key: "timesWorn", ascending: false)]
            request.fetchLimit = limit

            let entities = try context.fetch(request)
            return entities.map { $0.toDomainModel() }
        }
    }
}
