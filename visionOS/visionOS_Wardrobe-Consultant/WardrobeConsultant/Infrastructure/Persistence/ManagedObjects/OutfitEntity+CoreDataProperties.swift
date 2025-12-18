//
//  OutfitEntity+CoreDataProperties.swift
//  WardrobeConsultant
//
//  Created by Claude Code
//  Copyright © 2025 Wardrobe Consultant. All rights reserved.
//

import Foundation
import CoreData

extension OutfitEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<OutfitEntity> {
        return NSFetchRequest<OutfitEntity>(entityName: "OutfitEntity")
    }

    // MARK: - Identity
    @NSManaged public var id: UUID?
    @NSManaged public var createdAt: Date?
    @NSManaged public var updatedAt: Date?

    // MARK: - Basic Info
    @NSManaged public var name: String?
    @NSManaged public var occasionType: String?

    // MARK: - Context
    @NSManaged public var season: String?
    @NSManaged public var weatherCondition: String?
    @NSManaged public var temperatureMin: Int16
    @NSManaged public var temperatureMax: Int16

    // MARK: - Style
    @NSManaged public var styleType: String?
    @NSManaged public var formalityLevel: Int16

    // MARK: - Usage
    @NSManaged public var timesWorn: Int32
    @NSManaged public var lastWornDate: Date?
    @NSManaged public var isFavorite: Bool

    // MARK: - AI Generated
    @NSManaged public var isAIGenerated: Bool
    @NSManaged public var confidenceScore: Float

    // MARK: - Item References
    @NSManaged public var itemIDsData: Data?

    // MARK: - Relationships
    @NSManaged public var items: NSSet?
}

// MARK: - Generated accessors for items
extension OutfitEntity {
    @objc(addItemsObject:)
    @NSManaged public func addToItems(_ value: WardrobeItemEntity)

    @objc(removeItemsObject:)
    @NSManaged public func removeFromItems(_ value: WardrobeItemEntity)

    @objc(addItems:)
    @NSManaged public func addToItems(_ values: NSSet)

    @objc(removeItems:)
    @NSManaged public func removeFromItems(_ values: NSSet)
}
