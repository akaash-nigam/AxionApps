// CategoryEntity+CoreDataClass.swift
import Foundation
import CoreData

@objc(CategoryEntity)
public class CategoryEntity: NSManagedObject {}

extension CategoryEntity {
    func toDomain() -> Category {
        Category(
            id: id ?? UUID(),
            plaidCategoryId: plaidCategoryId,
            name: name ?? "",
            parentId: parentId,
            level: level,
            path: path ?? "",
            icon: icon ?? "folder.fill",
            color: color ?? "#808080",
            sortOrder: sortOrder,
            isIncome: isIncome,
            isExpense: isExpense,
            isTransfer: isTransfer,
            isEssential: isEssential,
            isDiscretionary: isDiscretionary,
            isDefaultBudgeted: isDefaultBudgeted,
            suggestedPercentage: suggestedPercentage == 0 ? nil : suggestedPercentage,
            createdAt: createdAt ?? Date(),
            updatedAt: updatedAt ?? Date()
        )
    }

    func update(from category: Category) {
        self.id = category.id
        self.plaidCategoryId = category.plaidCategoryId
        self.name = category.name
        self.parentId = category.parentId
        self.level = category.level
        self.path = category.path
        self.icon = category.icon
        self.color = category.color
        self.sortOrder = category.sortOrder
        self.isIncome = category.isIncome
        self.isExpense = category.isExpense
        self.isTransfer = category.isTransfer
        self.isEssential = category.isEssential
        self.isDiscretionary = category.isDiscretionary
        self.isDefaultBudgeted = category.isDefaultBudgeted
        self.suggestedPercentage = category.suggestedPercentage ?? 0
        self.createdAt = category.createdAt
        self.updatedAt = category.updatedAt
    }

    static func from(_ category: Category, context: NSManagedObjectContext) -> CategoryEntity {
        let entity = CategoryEntity(context: context)
        entity.update(from: category)
        return entity
    }
}
