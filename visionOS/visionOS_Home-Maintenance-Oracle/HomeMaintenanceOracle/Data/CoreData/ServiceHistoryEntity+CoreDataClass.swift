//
//  ServiceHistoryEntity+CoreDataClass.swift
//  HomeMaintenanceOracle
//
//  Created on 2025-11-24.
//

import Foundation
import CoreData

@objc(ServiceHistoryEntity)
public class ServiceHistoryEntity: NSManagedObject {}

extension ServiceHistoryEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ServiceHistoryEntity> {
        return NSFetchRequest<ServiceHistoryEntity>(entityName: "ServiceHistoryEntity")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var date: Date?
    @NSManaged public var title: String?
    @NSManaged public var serviceDescription: String?
    @NSManaged public var serviceType: String?
    @NSManaged public var cost: NSDecimalNumber?
    @NSManaged public var vendor: String?
    @NSManaged public var warrantyWork: Bool
    @NSManaged public var notes: String?
    @NSManaged public var createdAt: Date?

    @NSManaged public var appliance: ApplianceEntity?
    @NSManaged public var maintenanceTask: MaintenanceTaskEntity?
}

extension ServiceHistoryEntity: Identifiable {}
