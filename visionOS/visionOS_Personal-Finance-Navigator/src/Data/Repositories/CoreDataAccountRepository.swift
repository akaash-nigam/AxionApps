// CoreDataAccountRepository.swift
// Personal Finance Navigator
// Core Data implementation of AccountRepository

import Foundation
import CoreData
import OSLog

private let logger = Logger(subsystem: "com.pfn", category: "repository")

/// Core Data implementation of account repository
final class CoreDataAccountRepository: AccountRepository {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    // MARK: - Fetch Methods

    func fetchAll() async throws -> [Account] {
        try await context.perform {
            let request = AccountEntity.fetchRequest()
            request.sortDescriptors = [
                NSSortDescriptor(key: "isActive", ascending: false),
                NSSortDescriptor(key: "name", ascending: true)
            ]

            let entities = try self.context.fetch(request)
            return entities.map { $0.toDomain() }
        }
    }

    func fetchById(_ id: UUID) async throws -> Account? {
        try await context.perform {
            let request = AccountEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            request.fetchLimit = 1

            guard let entity = try self.context.fetch(request).first else {
                return nil
            }

            return entity.toDomain()
        }
    }

    func fetchActive() async throws -> [Account] {
        try await context.perform {
            let request = AccountEntity.fetchRequest()
            request.predicate = NSPredicate(format: "isActive == YES AND isHidden == NO")
            request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]

            let entities = try self.context.fetch(request)
            return entities.map { $0.toDomain() }
        }
    }

    func fetchByType(_ type: Account.AccountType) async throws -> [Account] {
        try await context.perform {
            let request = AccountEntity.fetchRequest()
            request.predicate = NSPredicate(format: "type == %@", type.rawValue)
            request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]

            let entities = try self.context.fetch(request)
            return entities.map { $0.toDomain() }
        }
    }

    func fetchNeedingReconnection() async throws -> [Account] {
        try await context.perform {
            let request = AccountEntity.fetchRequest()
            request.predicate = NSPredicate(format: "needsReconnection == YES")
            request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]

            let entities = try self.context.fetch(request)
            return entities.map { $0.toDomain() }
        }
    }

    // MARK: - Save Methods

    func save(_ account: Account) async throws {
        try await context.perform {
            let request = AccountEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", account.id as CVarArg)
            request.fetchLimit = 1

            let entity: AccountEntity
            if let existing = try self.context.fetch(request).first {
                entity = existing
                entity.update(from: account)
                logger.debug("Updated account: \(account.id)")
            } else {
                entity = AccountEntity.from(account, context: self.context)
                logger.debug("Created new account: \(account.id)")
            }

            try self.context.save()
        }
    }

    func saveAll(_ accounts: [Account]) async throws {
        try await context.perform {
            for account in accounts {
                let request = AccountEntity.fetchRequest()
                request.predicate = NSPredicate(format: "id == %@", account.id as CVarArg)
                request.fetchLimit = 1

                if let existing = try self.context.fetch(request).first {
                    existing.update(from: account)
                } else {
                    _ = AccountEntity.from(account, context: self.context)
                }
            }

            try self.context.save()
            logger.info("Saved \(accounts.count) accounts")
        }
    }

    // MARK: - Delete Methods

    func delete(_ account: Account) async throws {
        try await context.perform {
            let request = AccountEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", account.id as CVarArg)
            request.fetchLimit = 1

            guard let entity = try self.context.fetch(request).first else {
                logger.warning("Account not found for deletion: \(account.id)")
                return
            }

            self.context.delete(entity)
            try self.context.save()
            logger.debug("Deleted account: \(account.id)")
        }
    }

    func deleteById(_ id: UUID) async throws {
        try await context.perform {
            let request = AccountEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            request.fetchLimit = 1

            guard let entity = try self.context.fetch(request).first else {
                logger.warning("Account not found for deletion: \(id)")
                return
            }

            self.context.delete(entity)
            try self.context.save()
            logger.debug("Deleted account: \(id)")
        }
    }

    // MARK: - Update Methods

    func updateBalance(_ accountId: UUID, current: Decimal, available: Decimal?) async throws {
        try await context.perform {
            let request = AccountEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", accountId as CVarArg)
            request.fetchLimit = 1

            guard let entity = try self.context.fetch(request).first else {
                throw RepositoryError.notFound
            }

            entity.currentBalance = NSDecimalNumber(decimal: current)
            if let available = available {
                entity.availableBalance = NSDecimalNumber(decimal: available)
            }
            entity.updatedAt = Date()

            try self.context.save()
            logger.debug("Updated balance for account: \(accountId)")
        }
    }

    func markNeedsReconnection(_ accountId: UUID) async throws {
        try await context.perform {
            let request = AccountEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", accountId as CVarArg)
            request.fetchLimit = 1

            guard let entity = try self.context.fetch(request).first else {
                throw RepositoryError.notFound
            }

            entity.needsReconnection = true
            entity.updatedAt = Date()

            try self.context.save()
            logger.warning("Marked account needs reconnection: \(accountId)")
        }
    }

    func updateSyncDate(_ accountId: UUID, date: Date) async throws {
        try await context.perform {
            let request = AccountEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", accountId as CVarArg)
            request.fetchLimit = 1

            guard let entity = try self.context.fetch(request).first else {
                throw RepositoryError.notFound
            }

            entity.lastSyncedAt = date
            entity.updatedAt = Date()

            try self.context.save()
            logger.debug("Updated sync date for account: \(accountId)")
        }
    }

    // MARK: - Analytics Methods

    func getTotalNetWorth() async throws -> Decimal {
        try await context.perform {
            let request = AccountEntity.fetchRequest()
            request.predicate = NSPredicate(format: "isActive == YES AND isHidden == NO")

            let entities = try self.context.fetch(request)
            return entities.reduce(Decimal.zero) { total, entity in
                let balance = entity.currentBalance as Decimal
                // Subtract credit card balances (they're stored as positive but are liabilities)
                if entity.type == Account.AccountType.creditCard.rawValue {
                    return total - balance
                } else {
                    return total + balance
                }
            }
        }
    }
}

// MARK: - Repository Error
enum RepositoryError: LocalizedError {
    case notFound
    case saveFailed
    case deleteFailed

    var errorDescription: String? {
        switch self {
        case .notFound:
            return "Item not found"
        case .saveFailed:
            return "Failed to save item"
        case .deleteFailed:
            return "Failed to delete item"
        }
    }
}
