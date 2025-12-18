// CoreDataBudgetRepository.swift
// Personal Finance Navigator
// Core Data implementation of BudgetRepository

import Foundation
import CoreData
import OSLog

private let logger = Logger(subsystem: "com.pfn", category: "repository")

/// Core Data implementation of budget repository
final class CoreDataBudgetRepository: BudgetRepository {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    // MARK: - Fetch Methods

    func fetchAll() async throws -> [Budget] {
        try await context.perform {
            let request = BudgetEntity.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "startDate", ascending: false)]

            let entities = try self.context.fetch(request)
            return entities.map { $0.toDomain() }
        }
    }

    func fetchById(_ id: UUID) async throws -> Budget? {
        try await context.perform {
            let request = BudgetEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            request.fetchLimit = 1

            guard let entity = try self.context.fetch(request).first else {
                return nil
            }

            return entity.toDomain()
        }
    }

    func fetchActive() async throws -> Budget? {
        try await context.perform {
            let now = Date()
            let request = BudgetEntity.fetchRequest()
            request.predicate = NSPredicate(
                format: "startDate <= %@ AND endDate >= %@",
                now as CVarArg,
                now as CVarArg
            )
            request.sortDescriptors = [NSSortDescriptor(key: "startDate", ascending: false)]
            request.fetchLimit = 1

            guard let entity = try self.context.fetch(request).first else {
                return nil
            }

            return entity.toDomain()
        }
    }

    func fetchByDateRange(from startDate: Date, to endDate: Date) async throws -> [Budget] {
        try await context.perform {
            let request = BudgetEntity.fetchRequest()
            request.predicate = NSPredicate(
                format: "(startDate >= %@ AND startDate <= %@) OR (endDate >= %@ AND endDate <= %@) OR (startDate <= %@ AND endDate >= %@)",
                startDate as CVarArg, endDate as CVarArg,
                startDate as CVarArg, endDate as CVarArg,
                startDate as CVarArg, endDate as CVarArg
            )
            request.sortDescriptors = [NSSortDescriptor(key: "startDate", ascending: false)]

            let entities = try self.context.fetch(request)
            return entities.map { $0.toDomain() }
        }
    }

    // MARK: - Save Methods

    func save(_ budget: Budget) async throws {
        try await context.perform {
            let request = BudgetEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", budget.id as CVarArg)
            request.fetchLimit = 1

            let entity: BudgetEntity
            if let existing = try self.context.fetch(request).first {
                entity = existing
                entity.update(from: budget)
                logger.debug("Updated budget: \(budget.id)")
            } else {
                entity = BudgetEntity.from(budget, context: self.context)
                logger.debug("Created new budget: \(budget.id)")
            }

            try self.context.save()
        }
    }

    // MARK: - Delete Methods

    func delete(_ budget: Budget) async throws {
        try await context.perform {
            let request = BudgetEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", budget.id as CVarArg)
            request.fetchLimit = 1

            guard let entity = try self.context.fetch(request).first else {
                logger.warning("Budget not found for deletion: \(budget.id)")
                return
            }

            self.context.delete(entity)
            try self.context.save()
            logger.debug("Deleted budget: \(budget.id)")
        }
    }

    func deleteById(_ id: UUID) async throws {
        try await context.perform {
            let request = BudgetEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            request.fetchLimit = 1

            guard let entity = try self.context.fetch(request).first else {
                logger.warning("Budget not found for deletion: \(id)")
                return
            }

            self.context.delete(entity)
            try self.context.save()
            logger.debug("Deleted budget: \(id)")
        }
    }

    // MARK: - Budget Category Methods

    func updateCategorySpent(_ budgetId: UUID, categoryId: UUID, spent: Decimal) async throws {
        try await context.perform {
            // Fetch the budget
            let budgetRequest = BudgetEntity.fetchRequest()
            budgetRequest.predicate = NSPredicate(format: "id == %@", budgetId as CVarArg)
            budgetRequest.fetchLimit = 1

            guard let budgetEntity = try self.context.fetch(budgetRequest).first else {
                throw RepositoryError.notFound
            }

            // Find the category in the budget
            let categoryRequest = BudgetCategoryEntity.fetchRequest()
            categoryRequest.predicate = NSPredicate(
                format: "budgetId == %@ AND categoryId == %@",
                budgetId as CVarArg,
                categoryId as CVarArg
            )
            categoryRequest.fetchLimit = 1

            guard let categoryEntity = try self.context.fetch(categoryRequest).first else {
                throw RepositoryError.notFound
            }

            // Update spent amount
            categoryEntity.spent = NSDecimalNumber(decimal: spent)
            categoryEntity.updatedAt = Date()

            // Update budget's updated date
            budgetEntity.updatedAt = Date()

            try self.context.save()
            logger.debug("Updated spent for category \(categoryId) in budget \(budgetId)")
        }
    }

    func getBudgetProgress(_ budgetId: UUID) async throws -> (spent: Decimal, allocated: Decimal, percentage: Double) {
        try await context.perform {
            let request = BudgetCategoryEntity.fetchRequest()
            request.predicate = NSPredicate(format: "budgetId == %@", budgetId as CVarArg)

            let entities = try self.context.fetch(request)

            let totalSpent = entities.reduce(Decimal.zero) { $0 + ($1.spent as Decimal) }
            let totalAllocated = entities.reduce(Decimal.zero) { $0 + ($1.allocated as Decimal) }

            let percentage = totalAllocated > 0
                ? Double(truncating: (totalSpent / totalAllocated) as NSDecimalNumber) * 100
                : 0

            return (spent: totalSpent, allocated: totalAllocated, percentage: percentage)
        }
    }

    func getCategoryProgress(_ budgetId: UUID, categoryId: UUID) async throws -> (spent: Decimal, allocated: Decimal, percentage: Double) {
        try await context.perform {
            let request = BudgetCategoryEntity.fetchRequest()
            request.predicate = NSPredicate(
                format: "budgetId == %@ AND categoryId == %@",
                budgetId as CVarArg,
                categoryId as CVarArg
            )
            request.fetchLimit = 1

            guard let entity = try self.context.fetch(request).first else {
                throw RepositoryError.notFound
            }

            let spent = entity.spent as Decimal
            let allocated = entity.allocated as Decimal
            let percentage = entity.percentageOfBudget

            return (spent: spent, allocated: allocated, percentage: percentage)
        }
    }
}
