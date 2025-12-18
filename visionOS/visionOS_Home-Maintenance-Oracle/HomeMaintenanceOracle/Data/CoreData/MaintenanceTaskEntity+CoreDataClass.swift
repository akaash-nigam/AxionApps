//
//  MaintenanceTaskEntity+CoreDataClass.swift
//  HomeMaintenanceOracle
//
//  Created on 2025-11-24.
//

import Foundation
import CoreData

@objc(MaintenanceTaskEntity)
public class MaintenanceTaskEntity: NSManagedObject {

    // Computed property
    var isOverdue: Bool {
        guard completedDate == nil, let dueDate = dueDate else { return false }
        return dueDate < Date()
    }
}

// MARK: - Properties

extension MaintenanceTaskEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MaintenanceTaskEntity> {
        return NSFetchRequest<MaintenanceTaskEntity>(entityName: "MaintenanceTaskEntity")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var title: String?
    @NSManaged public var taskDescription: String?
    @NSManaged public var type: String?
    @NSManaged public var frequency: Int32
    @NSManaged public var dueDate: Date?
    @NSManaged public var completedDate: Date?
    @NSManaged public var isRecurring: Bool
    @NSManaged public var priority: String?
    @NSManaged public var estimatedCost: NSDecimalNumber?
    @NSManaged public var estimatedDuration: Int16
    @NSManaged public var notificationId: String?
    @NSManaged public var createdAt: Date?
    @NSManaged public var updatedAt: Date?

    @NSManaged public var appliance: ApplianceEntity?
    @NSManaged public var serviceRecords: NSSet?
}

extension MaintenanceTaskEntity: Identifiable {}
