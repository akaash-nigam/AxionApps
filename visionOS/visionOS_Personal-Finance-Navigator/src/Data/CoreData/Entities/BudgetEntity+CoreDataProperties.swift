// BudgetEntity+CoreDataProperties.swift
import Foundation
import CoreData

extension BudgetEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<BudgetEntity> {
        return NSFetchRequest<BudgetEntity>(entityName: "BudgetEntity")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var type: String?
    @NSManaged public var startDate: Date?
    @NSManaged public var endDate: Date?
    @NSManaged public var totalIncome: NSDecimalNumber
    @NSManaged public var totalAllocated: NSDecimalNumber
    @NSManaged public var totalSpent: NSDecimalNumber
    @NSManaged public var isActive: Bool
    @NSManaged public var isTemplate: Bool
    @NSManaged public var strategy: String?
    @NSManaged public var createdAt: Date?
    @NSManaged public var updatedAt: Date?
    @NSManaged public var categories: NSSet?
}

extension BudgetEntity: Identifiable {}
