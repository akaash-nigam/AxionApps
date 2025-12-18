//
//  ApplianceEntity+CoreDataProperties.swift
//  HomeMaintenanceOracle
//
//  Created on 2025-11-24.
//

import Foundation
import CoreData

extension ApplianceEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ApplianceEntity> {
        return NSFetchRequest<ApplianceEntity>(entityName: "ApplianceEntity")
    }

    // MARK: - Attributes

    @NSManaged public var id: UUID?
    @NSManaged public var brand: String?
    @NSManaged public var model: String?
    @NSManaged public var serialNumber: String?
    @NSManaged public var category: String?
    @NSManaged public var installDate: Date?
    @NSManaged public var purchaseDate: Date?
    @NSManaged public var purchasePrice: NSDecimalNumber?
    @NSManaged public var warrantyExpiry: Date?
    @NSManaged public var warrantyDuration: Int16
    @NSManaged public var notes: String?
    @NSManaged public var roomLocation: String?
    @NSManaged public var spatialAnchorId: String?
    @NSManaged public var imageData: Data?
    @NSManaged public var createdAt: Date?
    @NSManaged public var updatedAt: Date?

    // MARK: - Relationships

    @NSManaged public var home: HomeEntity?
    @NSManaged public var maintenanceTasks: NSSet?
    @NSManaged public var serviceHistory: NSSet?
    @NSManaged public var manuals: NSSet?
}

// MARK: - Generated accessors for maintenanceTasks

extension ApplianceEntity {

    @objc(addMaintenanceTasksObject:)
    @NSManaged public func addToMaintenanceTasks(_ value: MaintenanceTaskEntity)

    @objc(removeMaintenanceTasksObject:)
    @NSManaged public func removeFromMaintenanceTasks(_ value: MaintenanceTaskEntity)

    @objc(addMaintenanceTasks:)
    @NSManaged public func addToMaintenanceTasks(_ values: NSSet)

    @objc(removeMaintenanceTasks:)
    @NSManaged public func removeFromMaintenanceTasks(_ values: NSSet)
}

// MARK: - Generated accessors for serviceHistory

extension ApplianceEntity {

    @objc(addServiceHistoryObject:)
    @NSManaged public func addToServiceHistory(_ value: ServiceHistoryEntity)

    @objc(removeServiceHistoryObject:)
    @NSManaged public func removeFromServiceHistory(_ value: ServiceHistoryEntity)

    @objc(addServiceHistory:)
    @NSManaged public func addToServiceHistory(_ values: NSSet)

    @objc(removeServiceHistory:)
    @NSManaged public func removeFromServiceHistory(_ values: NSSet)
}

// MARK: - Identifiable Conformance

extension ApplianceEntity: Identifiable {}
