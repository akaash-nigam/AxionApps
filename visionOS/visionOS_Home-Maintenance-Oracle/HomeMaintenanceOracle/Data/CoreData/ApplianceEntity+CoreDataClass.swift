//
//  ApplianceEntity+CoreDataClass.swift
//  HomeMaintenanceOracle
//
//  Created on 2025-11-24.
//

import Foundation
import CoreData

@objc(ApplianceEntity)
public class ApplianceEntity: NSManagedObject, Identifiable {

    // MARK: - Convenience Initializer

    convenience init(context: NSManagedObjectContext, appliance: Appliance) {
        self.init(context: context)
        self.id = appliance.id
        self.brand = appliance.brand
        self.model = appliance.model
        self.serialNumber = appliance.serialNumber
        self.category = appliance.category.rawValue
        self.installDate = appliance.installDate
        self.purchaseDate = appliance.purchaseDate
        self.purchasePrice = appliance.purchasePrice.map { NSDecimalNumber(value: $0) }
        self.warrantyExpiry = appliance.warrantyExpiry
        self.notes = appliance.notes
        self.roomLocation = appliance.roomLocation
        self.createdAt = appliance.createdAt
        self.updatedAt = Date()
    }

    // MARK: - Domain Model Conversion

    func toAppliance() -> Appliance {
        return Appliance(
            id: self.id ?? UUID(),
            brand: self.brand ?? "Unknown",
            model: self.model ?? "Unknown",
            serialNumber: self.serialNumber,
            category: ApplianceCategory(rawValue: self.category ?? "") ?? .other,
            installDate: self.installDate,
            purchaseDate: self.purchaseDate,
            purchasePrice: self.purchasePrice?.doubleValue,
            warrantyExpiry: self.warrantyExpiry,
            notes: self.notes,
            roomLocation: self.roomLocation,
            createdAt: self.createdAt ?? Date(),
            updatedAt: self.updatedAt ?? Date()
        )
    }
}
