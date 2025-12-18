//
//  WardrobeItemEntity+CoreDataClass.swift
//  WardrobeConsultant
//
//  Created by Claude Code
//  Copyright © 2025 Wardrobe Consultant. All rights reserved.
//

import Foundation
import CoreData

@objc(WardrobeItemEntity)
public class WardrobeItemEntity: NSManagedObject {

    // MARK: - Convenience Initializer
    convenience init(from item: WardrobeItem, context: NSManagedObjectContext) {
        self.init(context: context)
        updateFrom(item)
    }

    // MARK: - Update From Domain Model
    func updateFrom(_ item: WardrobeItem) {
        self.id = item.id
        self.createdAt = item.createdAt
        self.updatedAt = Date() // Always update timestamp

        self.name = item.name
        self.category = item.category.rawValue
        self.subcategory = item.subcategory
        self.brand = item.brand
        self.size = item.size

        self.primaryColor = item.primaryColor
        self.secondaryColor = item.secondaryColor
        self.pattern = item.pattern?.rawValue
        self.fabric = item.fabric?.rawValue

        self.photoURL = item.photoURL
        self.thumbnailURL = item.thumbnailURL
        self.modelURL = item.modelURL

        self.purchaseDate = item.purchaseDate
        self.purchasePrice = item.purchasePrice as NSDecimalNumber?
        self.retailerName = item.retailerName
        self.productURL = item.productURL

        self.timesWorn = Int32(item.timesWorn)
        self.lastWornDate = item.lastWornDate
        self.firstWornDate = item.firstWornDate

        self.season = item.season?.rawValue
        self.occasion = item.occasion?.rawValue
        self.tags = item.tags as NSSet
        self.isFavorite = item.isFavorite

        self.condition = item.condition.rawValue
        self.needsRepair = item.needsRepair
        self.notes = item.notes
    }

    // MARK: - Convert To Domain Model
    func toDomainModel() -> WardrobeItem {
        WardrobeItem(
            id: id ?? UUID(),
            createdAt: createdAt ?? Date(),
            updatedAt: updatedAt ?? Date(),
            name: name,
            category: ClothingCategory(rawValue: category ?? "") ?? .shirt,
            primaryColor: primaryColor ?? "#000000",
            subcategory: subcategory,
            brand: brand,
            size: size,
            secondaryColor: secondaryColor,
            pattern: pattern.flatMap { ClothingPattern(rawValue: $0) },
            fabric: fabric.flatMap { FabricType(rawValue: $0) },
            photoURL: photoURL,
            thumbnailURL: thumbnailURL,
            modelURL: modelURL,
            purchaseDate: purchaseDate,
            purchasePrice: purchasePrice as Decimal?,
            retailerName: retailerName,
            productURL: productURL,
            timesWorn: Int(timesWorn),
            lastWornDate: lastWornDate,
            firstWornDate: firstWornDate,
            season: season.flatMap { Season(rawValue: $0) },
            occasion: occasion.flatMap { OccasionType(rawValue: $0) },
            tags: (tags as? Set<String>) ?? Set(),
            isFavorite: isFavorite,
            condition: ItemCondition(rawValue: condition ?? "good") ?? .good,
            needsRepair: needsRepair,
            notes: notes
        )
    }
}
