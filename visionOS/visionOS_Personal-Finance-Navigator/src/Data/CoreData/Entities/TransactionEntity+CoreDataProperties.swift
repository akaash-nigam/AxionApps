// TransactionEntity+CoreDataProperties.swift
// Personal Finance Navigator
// Core Data properties for TransactionEntity

import Foundation
import CoreData

extension TransactionEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<TransactionEntity> {
        return NSFetchRequest<TransactionEntity>(entityName: "TransactionEntity")
    }

    // MARK: - Identity
    @NSManaged public var id: UUID?
    @NSManaged public var plaidTransactionId: String?

    // MARK: - Details
    @NSManaged public var accountId: UUID?
    @NSManaged public var amount: NSDecimalNumber
    @NSManaged public var date: Date?
    @NSManaged public var authorizedDate: Date?
    @NSManaged public var merchantName: String?
    @NSManaged public var name: String?
    @NSManaged public var pending: Bool

    // MARK: - Categorization
    @NSManaged public var categoryId: UUID?
    @NSManaged public var primaryCategory: String?
    @NSManaged public var detailedCategory: String?
    @NSManaged public var isRecurring: Bool
    @NSManaged public var confidence: Float

    // MARK: - Location
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var address: String?

    // MARK: - Payment
    @NSManaged public var paymentChannel: String?
    @NSManaged public var paymentMethod: String?

    // MARK: - Flags
    @NSManaged public var isUserModified: Bool
    @NSManaged public var isHidden: Bool
    @NSManaged public var isExcludedFromBudget: Bool
    @NSManaged public var isSplit: Bool
    @NSManaged public var parentTransactionId: UUID?

    // MARK: - Notes
    @NSManaged public var notes: String?
    @NSManaged public var tags: NSArray?

    // MARK: - Metadata
    @NSManaged public var createdAt: Date?
    @NSManaged public var updatedAt: Date?

    // MARK: - Relationships
    @NSManaged public var account: AccountEntity?
    @NSManaged public var category: CategoryEntity?
}

// MARK: - Identifiable
extension TransactionEntity: Identifiable {
}
