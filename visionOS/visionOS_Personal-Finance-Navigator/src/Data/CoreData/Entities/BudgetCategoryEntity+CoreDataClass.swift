// BudgetCategoryEntity+CoreDataClass.swift
import Foundation
import CoreData

@objc(BudgetCategoryEntity)
public class BudgetCategoryEntity: NSManagedObject {}

extension BudgetCategoryEntity {
    func toDomain() -> BudgetCategory {
        BudgetCategory(
            id: id ?? UUID(),
            budgetId: budgetId ?? UUID(),
            categoryId: categoryId ?? UUID(),
            allocated: allocated as Decimal,
            spent: spent as Decimal,
            percentageOfBudget: percentageOfBudget,
            isRollover: isRollover,
            rolledAmount: rolledAmount?.decimalValue,
            alertAt75: alertAt75,
            alertAt90: alertAt90,
            alertAt100: alertAt100,
            alertOnOverspend: alertOnOverspend,
            categoryName: categoryName ?? "",
            createdAt: createdAt ?? Date(),
            updatedAt: updatedAt ?? Date()
        )
    }

    func update(from budgetCategory: BudgetCategory) {
        self.id = budgetCategory.id
        self.budgetId = budgetCategory.budgetId
        self.categoryId = budgetCategory.categoryId
        self.allocated = NSDecimalNumber(decimal: budgetCategory.allocated)
        self.spent = NSDecimalNumber(decimal: budgetCategory.spent)
        self.percentageOfBudget = budgetCategory.percentageOfBudget
        self.isRollover = budgetCategory.isRollover
        self.rolledAmount = budgetCategory.rolledAmount.map { NSDecimalNumber(decimal: $0) }
        self.alertAt75 = budgetCategory.alertAt75
        self.alertAt90 = budgetCategory.alertAt90
        self.alertAt100 = budgetCategory.alertAt100
        self.alertOnOverspend = budgetCategory.alertOnOverspend
        self.categoryName = budgetCategory.categoryName
        self.createdAt = budgetCategory.createdAt
        self.updatedAt = budgetCategory.updatedAt
    }

    static func from(_ budgetCategory: BudgetCategory, context: NSManagedObjectContext) -> BudgetCategoryEntity {
        let entity = BudgetCategoryEntity(context: context)
        entity.update(from: budgetCategory)
        return entity
    }
}
