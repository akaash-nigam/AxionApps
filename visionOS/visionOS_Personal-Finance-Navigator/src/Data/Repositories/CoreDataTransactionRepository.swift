// CoreDataTransactionRepository.swift
// Personal Finance Navigator
// Core Data implementation of TransactionRepository

import Foundation
import CoreData
import OSLog

private let logger = Logger(subsystem: "com.pfn", category: "repository")

/// Core Data implementation of transaction repository
final class CoreDataTransactionRepository: TransactionRepository {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    // MARK: - Fetch Methods

    func fetchAll() async throws -> [Transaction] {
        try await context.perform {
            let request = TransactionEntity.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]

            let entities = try self.context.fetch(request)
            return entities.map { $0.toDomain() }
        }
    }

    func fetchById(_ id: UUID) async throws -> Transaction? {
        try await context.perform {
            let request = TransactionEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            request.fetchLimit = 1

            guard let entity = try self.context.fetch(request).first else {
                return nil
            }

            return entity.toDomain()
        }
    }

    func fetchByAccount(_ accountId: UUID) async throws -> [Transaction] {
        try await context.perform {
            let request = TransactionEntity.fetchRequest()
            request.predicate = NSPredicate(format: "accountId == %@", accountId as CVarArg)
            request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]

            let entities = try self.context.fetch(request)
            return entities.map { $0.toDomain() }
        }
    }

    func fetchByDateRange(from startDate: Date, to endDate: Date) async throws -> [Transaction] {
        try await context.perform {
            let request = TransactionEntity.fetchRequest()
            request.predicate = NSPredicate(
                format: "date >= %@ AND date <= %@",
                startDate as CVarArg,
                endDate as CVarArg
            )
            request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]

            let entities = try self.context.fetch(request)
            return entities.map { $0.toDomain() }
        }
    }

    func fetchByCategory(_ categoryId: UUID) async throws -> [Transaction] {
        try await context.perform {
            let request = TransactionEntity.fetchRequest()
            request.predicate = NSPredicate(format: "categoryId == %@", categoryId as CVarArg)
            request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]

            let entities = try self.context.fetch(request)
            return entities.map { $0.toDomain() }
        }
    }

    func fetchPending() async throws -> [Transaction] {
        try await context.perform {
            let request = TransactionEntity.fetchRequest()
            request.predicate = NSPredicate(format: "isPending == YES")
            request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]

            let entities = try self.context.fetch(request)
            return entities.map { $0.toDomain() }
        }
    }

    func search(query: String) async throws -> [Transaction] {
        try await context.perform {
            let request = TransactionEntity.fetchRequest()
            request.predicate = NSPredicate(
                format: "name CONTAINS[cd] %@ OR merchantName CONTAINS[cd] %@",
                query,
                query
            )
            request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]

            let entities = try self.context.fetch(request)
            return entities.map { $0.toDomain() }
        }
    }

    // MARK: - Save Methods

    func save(_ transaction: Transaction) async throws {
        try await context.perform {
            // Check if transaction already exists
            let request = TransactionEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", transaction.id as CVarArg)
            request.fetchLimit = 1

            let entity: TransactionEntity
            if let existing = try self.context.fetch(request).first {
                // Update existing
                entity = existing
                entity.update(from: transaction)
                logger.debug("Updated transaction: \(transaction.id)")
            } else {
                // Create new
                entity = TransactionEntity.from(transaction, context: self.context)
                logger.debug("Created new transaction: \(transaction.id)")
            }

            try self.context.save()
        }
    }

    func saveAll(_ transactions: [Transaction]) async throws {
        try await context.perform {
            for transaction in transactions {
                // Check if exists
                let request = TransactionEntity.fetchRequest()
                request.predicate = NSPredicate(format: "id == %@", transaction.id as CVarArg)
                request.fetchLimit = 1

                if let existing = try self.context.fetch(request).first {
                    existing.update(from: transaction)
                } else {
                    _ = TransactionEntity.from(transaction, context: self.context)
                }
            }

            try self.context.save()
            logger.info("Saved \(transactions.count) transactions")
        }
    }

    // MARK: - Delete Methods

    func delete(_ transaction: Transaction) async throws {
        try await context.perform {
            let request = TransactionEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", transaction.id as CVarArg)
            request.fetchLimit = 1

            guard let entity = try self.context.fetch(request).first else {
                logger.warning("Transaction not found for deletion: \(transaction.id)")
                return
            }

            self.context.delete(entity)
            try self.context.save()
            logger.debug("Deleted transaction: \(transaction.id)")
        }
    }

    func deleteById(_ id: UUID) async throws {
        try await context.perform {
            let request = TransactionEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            request.fetchLimit = 1

            guard let entity = try self.context.fetch(request).first else {
                logger.warning("Transaction not found for deletion: \(id)")
                return
            }

            self.context.delete(entity)
            try self.context.save()
            logger.debug("Deleted transaction: \(id)")
        }
    }

    func deleteAll() async throws {
        try await context.perform {
            let request: NSFetchRequest<NSFetchRequestResult> = TransactionEntity.fetchRequest()
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)

            try self.context.execute(deleteRequest)
            try self.context.save()
            logger.warning("Deleted all transactions")
        }
    }

    // MARK: - Analytics Methods

    func getTotalSpent(from startDate: Date, to endDate: Date) async throws -> Decimal {
        try await context.perform {
            let request = TransactionEntity.fetchRequest()
            request.predicate = NSPredicate(
                format: "date >= %@ AND date <= %@ AND amount < 0",
                startDate as CVarArg,
                endDate as CVarArg
            )

            let entities = try self.context.fetch(request)
            let total = entities.reduce(Decimal.zero) { $0 + ($1.amount as Decimal) }
            return abs(total)
        }
    }

    func getTotalIncome(from startDate: Date, to endDate: Date) async throws -> Decimal {
        try await context.perform {
            let request = TransactionEntity.fetchRequest()
            request.predicate = NSPredicate(
                format: "date >= %@ AND date <= %@ AND amount > 0",
                startDate as CVarArg,
                endDate as CVarArg
            )

            let entities = try self.context.fetch(request)
            return entities.reduce(Decimal.zero) { $0 + ($1.amount as Decimal) }
        }
    }

    func getSpendingByCategory(from startDate: Date, to endDate: Date) async throws -> [UUID: Decimal] {
        try await context.perform {
            let request = TransactionEntity.fetchRequest()
            request.predicate = NSPredicate(
                format: "date >= %@ AND date <= %@ AND amount < 0",
                startDate as CVarArg,
                endDate as CVarArg
            )

            let entities = try self.context.fetch(request)
            var categoryTotals: [UUID: Decimal] = [:]

            for entity in entities {
                guard let categoryId = entity.categoryId else { continue }
                let amount = abs(entity.amount as Decimal)
                categoryTotals[categoryId, default: 0] += amount
            }

            return categoryTotals
        }
    }
}
