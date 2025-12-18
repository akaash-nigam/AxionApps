// AccountEntity+CoreDataClass.swift
// Personal Finance Navigator
// Core Data entity for accounts

import Foundation
import CoreData

@objc(AccountEntity)
public class AccountEntity: NSManagedObject {
    // Managed by Core Data
}

// MARK: - Domain Model Mapping
extension AccountEntity {
    /// Converts Core Data entity to domain model
    func toDomain() -> Account {
        Account(
            id: id ?? UUID(),
            plaidAccountId: plaidAccountId,
            plaidItemId: plaidItemId,
            name: name ?? "",
            officialName: officialName,
            type: AccountType(rawValue: type ?? "checking") ?? .checking,
            subtype: subtype,
            mask: mask,
            currentBalance: currentBalance as Decimal,
            availableBalance: availableBalance?.decimalValue,
            creditLimit: creditLimit?.decimalValue,
            isActive: isActive,
            isHidden: isHidden,
            needsReconnection: needsReconnection,
            institutionName: institutionName,
            institutionLogo: institutionLogo,
            primaryColor: primaryColor,
            lastSyncedAt: lastSyncedAt,
            createdAt: createdAt ?? Date(),
            updatedAt: updatedAt ?? Date()
        )
    }

    /// Updates entity from domain model
    func update(from account: Account) {
        self.id = account.id
        self.plaidAccountId = account.plaidAccountId
        self.plaidItemId = account.plaidItemId
        self.name = account.name
        self.officialName = account.officialName
        self.type = account.type.rawValue
        self.subtype = account.subtype
        self.mask = account.mask
        self.currentBalance = NSDecimalNumber(decimal: account.currentBalance)
        self.availableBalance = account.availableBalance.map { NSDecimalNumber(decimal: $0) }
        self.creditLimit = account.creditLimit.map { NSDecimalNumber(decimal: $0) }
        self.isActive = account.isActive
        self.isHidden = account.isHidden
        self.needsReconnection = account.needsReconnection
        self.institutionName = account.institutionName
        self.institutionLogo = account.institutionLogo
        self.primaryColor = account.primaryColor
        self.lastSyncedAt = account.lastSyncedAt
        self.createdAt = account.createdAt
        self.updatedAt = account.updatedAt
    }

    /// Creates a new entity from domain model
    static func from(_ account: Account, context: NSManagedObjectContext) -> AccountEntity {
        let entity = AccountEntity(context: context)
        entity.update(from: account)
        return entity
    }
}
