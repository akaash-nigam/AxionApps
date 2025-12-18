//
//  WardrobeItemEntity+CoreDataProperties.swift
//  WardrobeConsultant
//
//  Created by Claude Code
//  Copyright © 2025 Wardrobe Consultant. All rights reserved.
//

import Foundation
import CoreData

extension WardrobeItemEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WardrobeItemEntity> {
        return NSFetchRequest<WardrobeItemEntity>(entityName: "WardrobeItemEntity")
    }

    // MARK: - Identity
    @NSManaged public var id: UUID?
    @NSManaged public var createdAt: Date?
    @NSManaged public var updatedAt: Date?

    // MARK: - Basic Info
    @NSManaged public var name: String?
    @NSManaged public var category: String?
    @NSManaged public var subcategory: String?
    @NSManaged public var brand: String?
    @NSManaged public var size: String?

    // MARK: - Visual Attributes
    @NSManaged public var primaryColor: String?
    @NSManaged public var secondaryColor: String?
    @NSManaged public var pattern: String?
    @NSManaged public var fabric: String?

    // MARK: - Photos & 3D
    @NSManaged public var photoURL: URL?
    @NSManaged public var thumbnailURL: URL?
    @NSManaged public var modelURL: URL?

    // MARK: - Purchase Info
    @NSManaged public var purchaseDate: Date?
    @NSManaged public var purchasePrice: NSDecimalNumber?
    @NSManaged public var retailerName: String?
    @NSManaged public var productURL: URL?

    // MARK: - Usage Tracking
    @NSManaged public var timesWorn: Int32
    @NSManaged public var lastWornDate: Date?
    @NSManaged public var firstWornDate: Date?

    // MARK: - Organization
    @NSManaged public var season: String?
    @NSManaged public var occasion: String?
    @NSManaged public var tags: NSSet?
    @NSManaged public var isFavorite: Bool

    // MARK: - Condition
    @NSManaged public var condition: String?
    @NSManaged public var needsRepair: Bool
    @NSManaged public var notes: String?

    // MARK: - Relationships
    @NSManaged public var outfits: NSSet?
}

// MARK: - Generated accessors for tags
extension WardrobeItemEntity {
    @objc(addTagsObject:)
    @NSManaged public func addToTags(_ value: NSString)

    @objc(removeTagsObject:)
    @NSManaged public func removeFromTags(_ value: NSString)

    @objc(addTags:)
    @NSManaged public func addToTags(_ values: NSSet)

    @objc(removeTags:)
    @NSManaged public func removeFromTags(_ values: NSSet)
}

// MARK: - Generated accessors for outfits
extension WardrobeItemEntity {
    @objc(addOutfitsObject:)
    @NSManaged public func addToOutfits(_ value: OutfitEntity)

    @objc(removeOutfitsObject:)
    @NSManaged public func removeFromOutfits(_ value: OutfitEntity)

    @objc(addOutfits:)
    @NSManaged public func addToOutfits(_ values: NSSet)

    @objc(removeOutfits:)
    @NSManaged public func removeFromOutfits(_ values: NSSet)
}
