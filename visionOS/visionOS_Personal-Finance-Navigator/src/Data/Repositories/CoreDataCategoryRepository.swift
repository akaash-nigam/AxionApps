// CoreDataCategoryRepository.swift
// Personal Finance Navigator
// Core Data implementation of CategoryRepository

import Foundation
import CoreData
import OSLog

private let logger = Logger(subsystem: "com.pfn", category: "repository")

/// Core Data implementation of category repository
final class CoreDataCategoryRepository: CategoryRepository {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    // MARK: - Fetch Methods

    func fetchAll() async throws -> [Category] {
        try await context.perform {
            let request = CategoryEntity.fetchRequest()
            request.sortDescriptors = [
                NSSortDescriptor(key: "displayOrder", ascending: true),
                NSSortDescriptor(key: "name", ascending: true)
            ]

            let entities = try self.context.fetch(request)
            return entities.map { $0.toDomain() }
        }
    }

    func fetchById(_ id: UUID) async throws -> Category? {
        try await context.perform {
            let request = CategoryEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            request.fetchLimit = 1

            guard let entity = try self.context.fetch(request).first else {
                return nil
            }

            return entity.toDomain()
        }
    }

    func fetchByType(_ type: Category.CategoryType) async throws -> [Category] {
        try await context.perform {
            let request = CategoryEntity.fetchRequest()
            request.predicate = NSPredicate(format: "type == %@", type.rawValue)
            request.sortDescriptors = [
                NSSortDescriptor(key: "displayOrder", ascending: true),
                NSSortDescriptor(key: "name", ascending: true)
            ]

            let entities = try self.context.fetch(request)
            return entities.map { $0.toDomain() }
        }
    }

    func fetchParentCategories() async throws -> [Category] {
        try await context.perform {
            let request = CategoryEntity.fetchRequest()
            request.predicate = NSPredicate(format: "parentId == nil")
            request.sortDescriptors = [
                NSSortDescriptor(key: "displayOrder", ascending: true),
                NSSortDescriptor(key: "name", ascending: true)
            ]

            let entities = try self.context.fetch(request)
            return entities.map { $0.toDomain() }
        }
    }

    func fetchSubcategories(_ parentId: UUID) async throws -> [Category] {
        try await context.perform {
            let request = CategoryEntity.fetchRequest()
            request.predicate = NSPredicate(format: "parentId == %@", parentId as CVarArg)
            request.sortDescriptors = [
                NSSortDescriptor(key: "displayOrder", ascending: true),
                NSSortDescriptor(key: "name", ascending: true)
            ]

            let entities = try self.context.fetch(request)
            return entities.map { $0.toDomain() }
        }
    }

    func fetchActive() async throws -> [Category] {
        try await context.perform {
            let request = CategoryEntity.fetchRequest()
            request.predicate = NSPredicate(format: "isActive == YES")
            request.sortDescriptors = [
                NSSortDescriptor(key: "displayOrder", ascending: true),
                NSSortDescriptor(key: "name", ascending: true)
            ]

            let entities = try self.context.fetch(request)
            return entities.map { $0.toDomain() }
        }
    }

    // MARK: - Save Methods

    func save(_ category: Category) async throws {
        try await context.perform {
            let request = CategoryEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", category.id as CVarArg)
            request.fetchLimit = 1

            let entity: CategoryEntity
            if let existing = try self.context.fetch(request).first {
                entity = existing
                entity.update(from: category)
                logger.debug("Updated category: \(category.id)")
            } else {
                entity = CategoryEntity.from(category, context: self.context)
                logger.debug("Created new category: \(category.id)")
            }

            try self.context.save()
        }
    }

    func saveAll(_ categories: [Category]) async throws {
        try await context.perform {
            for category in categories {
                let request = CategoryEntity.fetchRequest()
                request.predicate = NSPredicate(format: "id == %@", category.id as CVarArg)
                request.fetchLimit = 1

                if let existing = try self.context.fetch(request).first {
                    existing.update(from: category)
                } else {
                    _ = CategoryEntity.from(category, context: self.context)
                }
            }

            try self.context.save()
            logger.info("Saved \(categories.count) categories")
        }
    }

    // MARK: - Delete Methods

    func delete(_ category: Category) async throws {
        try await context.perform {
            let request = CategoryEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", category.id as CVarArg)
            request.fetchLimit = 1

            guard let entity = try self.context.fetch(request).first else {
                logger.warning("Category not found for deletion: \(category.id)")
                return
            }

            self.context.delete(entity)
            try self.context.save()
            logger.debug("Deleted category: \(category.id)")
        }
    }

    func deleteById(_ id: UUID) async throws {
        try await context.perform {
            let request = CategoryEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            request.fetchLimit = 1

            guard let entity = try self.context.fetch(request).first else {
                logger.warning("Category not found for deletion: \(id)")
                return
            }

            self.context.delete(entity)
            try self.context.save()
            logger.debug("Deleted category: \(id)")
        }
    }

    // MARK: - Initialize Defaults

    func initializeDefaultCategories() async throws {
        try await context.perform {
            // Check if categories already exist
            let request = CategoryEntity.fetchRequest()
            let count = try self.context.count(for: request)

            if count > 0 {
                logger.info("Categories already initialized, skipping")
                return
            }

            // Create default categories
            let defaults = Category.createDefaultCategories()
            for category in defaults {
                _ = CategoryEntity.from(category, context: self.context)
            }

            try self.context.save()
            logger.info("Initialized \(defaults.count) default categories")
        }
    }
}
