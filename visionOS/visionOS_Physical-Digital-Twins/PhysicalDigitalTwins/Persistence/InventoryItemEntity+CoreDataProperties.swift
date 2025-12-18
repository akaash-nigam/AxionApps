//
//  InventoryItemEntity+CoreDataProperties.swift
//  PhysicalDigitalTwins
//
//  Core Data properties for inventory items
//

import Foundation
import CoreData

extension InventoryItemEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<InventoryItemEntity> {
        return NSFetchRequest<InventoryItemEntity>(entityName: "InventoryItemEntity")
    }

    // Core properties
    @NSManaged public var id: UUID?
    @NSManaged public var createdAt: Date?
    @NSManaged public var updatedAt: Date?

    // Digital Twin (stored as JSON)
    @NSManaged public var digitalTwinData: Data?
    @NSManaged public var digitalTwinType: String? // For faster queries

    // Financial
    @NSManaged public var purchaseDate: Date?
    @NSManaged public var purchasePrice: NSDecimalNumber?
    @NSManaged public var purchaseStore: String?
    @NSManaged public var currentValue: NSDecimalNumber?

    // Location
    @NSManaged public var locationName: String?
    @NSManaged public var specificLocation: String?

    // Condition
    @NSManaged public var condition: String?
    @NSManaged public var conditionNotes: String?

    // Photos
    @NSManaged public var photosPaths: [String]?

    // Lending
    @NSManaged public var isLent: Bool
    @NSManaged public var lentTo: String?
    @NSManaged public var lentDate: Date?
    @NSManaged public var expectedReturnDate: Date?

    // User notes
    @NSManaged public var notes: String?
    @NSManaged public var tags: [String]?
    @NSManaged public var isFavorite: Bool
}

extension InventoryItemEntity: Identifiable {}
