// BudgetCategoryEntity+CoreDataProperties.swift
// Personal Finance Navigator
// Core Data properties for BudgetCategoryEntity

import Foundation
import CoreData

extension BudgetCategoryEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<BudgetCategoryEntity> {
        return NSFetchRequest<BudgetCategoryEntity>(entityName: "BudgetCategoryEntity")
    }

    // MARK: - Identity
    @NSManaged public var id: UUID?
    @NSManaged public var budgetId: UUID?
    @NSManaged public var categoryId: UUID?

    // MARK: - Amounts
    @NSManaged public var allocated: NSDecimalNumber
    @NSManaged public var spent: NSDecimalNumber
    @NSManaged public var percentageOfBudget: Double

    // MARK: - Rollover
    @NSManaged public var isRollover: Bool
    @NSManaged public var rolledAmount: NSDecimalNumber?

    // MARK: - Alerts
    @NSManaged public var alertAt75: Bool
    @NSManaged public var alertAt90: Bool
    @NSManaged public var alertAt100: Bool
    @NSManaged public var alertOnOverspend: Bool

    // MARK: - Metadata
    @NSManaged public var categoryName: String?
    @NSManaged public var createdAt: Date?
    @NSManaged public var updatedAt: Date?

    // MARK: - Relationships
    @NSManaged public var budget: BudgetEntity?
}

// MARK: - Identifiable
extension BudgetCategoryEntity: Identifiable {
}
