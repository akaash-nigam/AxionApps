// CategoryEntity+CoreDataProperties.swift
import Foundation
import CoreData

extension CategoryEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CategoryEntity> {
        return NSFetchRequest<CategoryEntity>(entityName: "CategoryEntity")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var plaidCategoryId: String?
    @NSManaged public var name: String?
    @NSManaged public var parentId: UUID?
    @NSManaged public var level: Int16
    @NSManaged public var path: String?
    @NSManaged public var icon: String?
    @NSManaged public var color: String?
    @NSManaged public var sortOrder: Int16
    @NSManaged public var isIncome: Bool
    @NSManaged public var isExpense: Bool
    @NSManaged public var isTransfer: Bool
    @NSManaged public var isEssential: Bool
    @NSManaged public var isDiscretionary: Bool
    @NSManaged public var isDefaultBudgeted: Bool
    @NSManaged public var suggestedPercentage: Float
    @NSManaged public var createdAt: Date?
    @NSManaged public var updatedAt: Date?
    @NSManaged public var transactions: NSSet?
    @NSManaged public var budgetCategories: NSSet?
}

extension CategoryEntity: Identifiable {}
