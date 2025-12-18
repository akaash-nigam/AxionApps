// AccountEntity+CoreDataProperties.swift
// Personal Finance Navigator
// Core Data properties for AccountEntity

import Foundation
import CoreData

extension AccountEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<AccountEntity> {
        return NSFetchRequest<AccountEntity>(entityName: "AccountEntity")
    }

    // MARK: - Identity
    @NSManaged public var id: UUID?
    @NSManaged public var plaidAccountId: String?
    @NSManaged public var plaidItemId: String?

    // MARK: - Details
    @NSManaged public var name: String?
    @NSManaged public var officialName: String?
    @NSManaged public var type: String?
    @NSManaged public var subtype: String?
    @NSManaged public var mask: String?

    // MARK: - Balance
    @NSManaged public var currentBalance: NSDecimalNumber
    @NSManaged public var availableBalance: NSDecimalNumber?
    @NSManaged public var creditLimit: NSDecimalNumber?

    // MARK: - Status
    @NSManaged public var isActive: Bool
    @NSManaged public var isHidden: Bool
    @NSManaged public var needsReconnection: Bool

    // MARK: - Metadata
    @NSManaged public var institutionName: String?
    @NSManaged public var institutionLogo: Data?
    @NSManaged public var primaryColor: String?
    @NSManaged public var lastSyncedAt: Date?
    @NSManaged public var createdAt: Date?
    @NSManaged public var updatedAt: Date?

    // MARK: - Relationships
    @NSManaged public var transactions: NSSet?
}

// MARK: - Generated accessors for transactions
extension AccountEntity {
    @objc(addTransactionsObject:)
    @NSManaged public func addToTransactions(_ value: TransactionEntity)

    @objc(removeTransactionsObject:)
    @NSManaged public func removeFromTransactions(_ value: TransactionEntity)

    @objc(addTransactions:)
    @NSManaged public func addToTransactions(_ values: NSSet)

    @objc(removeTransactions:)
    @NSManaged public func removeFromTransactions(_ values: NSSet)
}

// MARK: - Identifiable
extension AccountEntity: Identifiable {
}
