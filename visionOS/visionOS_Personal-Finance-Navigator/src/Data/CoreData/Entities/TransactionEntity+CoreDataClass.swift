// TransactionEntity+CoreDataClass.swift
// Personal Finance Navigator
// Core Data entity for transactions

import Foundation
import CoreData

@objc(TransactionEntity)
public class TransactionEntity: NSManagedObject {
    // Managed by Core Data
}

// MARK: - Domain Model Mapping
extension TransactionEntity {
    /// Converts Core Data entity to domain model
    func toDomain() -> Transaction {
        Transaction(
            id: id ?? UUID(),
            plaidTransactionId: plaidTransactionId,
            accountId: accountId ?? UUID(),
            amount: amount as Decimal,
            date: date ?? Date(),
            authorizedDate: authorizedDate,
            merchantName: merchantName,
            name: name ?? "",
            pending: pending,
            categoryId: categoryId,
            primaryCategory: primaryCategory ?? "Uncategorized",
            detailedCategory: detailedCategory,
            isRecurring: isRecurring,
            confidence: confidence == 0 ? nil : confidence,
            latitude: latitude == 0 ? nil : latitude,
            longitude: longitude == 0 ? nil : longitude,
            address: address,
            paymentChannel: PaymentChannel(rawValue: paymentChannel ?? "other") ?? .other,
            paymentMethod: paymentMethod,
            isUserModified: isUserModified,
            isHidden: isHidden,
            isExcludedFromBudget: isExcludedFromBudget,
            isSplit: isSplit,
            parentTransactionId: parentTransactionId,
            notes: notes,
            tags: tags as? [String] ?? [],
            createdAt: createdAt ?? Date(),
            updatedAt: updatedAt ?? Date()
        )
    }

    /// Updates entity from domain model
    func update(from transaction: Transaction) {
        self.id = transaction.id
        self.plaidTransactionId = transaction.plaidTransactionId
        self.accountId = transaction.accountId
        self.amount = NSDecimalNumber(decimal: transaction.amount)
        self.date = transaction.date
        self.authorizedDate = transaction.authorizedDate
        self.merchantName = transaction.merchantName
        self.name = transaction.name
        self.pending = transaction.pending
        self.categoryId = transaction.categoryId
        self.primaryCategory = transaction.primaryCategory
        self.detailedCategory = transaction.detailedCategory
        self.isRecurring = transaction.isRecurring
        self.confidence = transaction.confidence ?? 0
        self.latitude = transaction.latitude ?? 0
        self.longitude = transaction.longitude ?? 0
        self.address = transaction.address
        self.paymentChannel = transaction.paymentChannel.rawValue
        self.paymentMethod = transaction.paymentMethod
        self.isUserModified = transaction.isUserModified
        self.isHidden = transaction.isHidden
        self.isExcludedFromBudget = transaction.isExcludedFromBudget
        self.isSplit = transaction.isSplit
        self.parentTransactionId = transaction.parentTransactionId
        self.notes = transaction.notes
        self.tags = transaction.tags as NSArray
        self.createdAt = transaction.createdAt
        self.updatedAt = transaction.updatedAt
    }

    /// Creates a new entity from domain model
    static func from(_ transaction: Transaction, context: NSManagedObjectContext) -> TransactionEntity {
        let entity = TransactionEntity(context: context)
        entity.update(from: transaction)
        return entity
    }
}
