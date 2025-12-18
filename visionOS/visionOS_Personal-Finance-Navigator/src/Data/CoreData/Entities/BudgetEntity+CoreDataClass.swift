// BudgetEntity+CoreDataClass.swift
import Foundation
import CoreData

@objc(BudgetEntity)
public class BudgetEntity: NSManagedObject {}

extension BudgetEntity {
    func toDomain() -> Budget {
        let budgetCategories = (categories as? Set<BudgetCategoryEntity>)?
            .map { $0.toDomain() } ?? []

        return Budget(
            id: id ?? UUID(),
            name: name ?? "",
            type: BudgetType(rawValue: type ?? "monthly") ?? .monthly,
            startDate: startDate ?? Date(),
            endDate: endDate ?? Date(),
            totalIncome: totalIncome as Decimal,
            totalAllocated: totalAllocated as Decimal,
            totalSpent: totalSpent as Decimal,
            isActive: isActive,
            isTemplate: isTemplate,
            strategy: BudgetStrategy(rawValue: strategy ?? "50/30/20") ?? .fiftyThirtyTwenty,
            categories: budgetCategories,
            createdAt: createdAt ?? Date(),
            updatedAt: updatedAt ?? Date()
        )
    }

    func update(from budget: Budget) {
        self.id = budget.id
        self.name = budget.name
        self.type = budget.type.rawValue
        self.startDate = budget.startDate
        self.endDate = budget.endDate
        self.totalIncome = NSDecimalNumber(decimal: budget.totalIncome)
        self.totalAllocated = NSDecimalNumber(decimal: budget.totalAllocated)
        self.totalSpent = NSDecimalNumber(decimal: budget.totalSpent)
        self.isActive = budget.isActive
        self.isTemplate = budget.isTemplate
        self.strategy = budget.strategy.rawValue
        self.createdAt = budget.createdAt
        self.updatedAt = budget.updatedAt
    }

    static func from(_ budget: Budget, context: NSManagedObjectContext) -> BudgetEntity {
        let entity = BudgetEntity(context: context)
        entity.update(from: budget)
        return entity
    }
}
