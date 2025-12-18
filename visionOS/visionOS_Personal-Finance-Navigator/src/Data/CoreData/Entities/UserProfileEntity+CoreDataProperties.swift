// UserProfileEntity+CoreDataProperties.swift
// Personal Finance Navigator
// Core Data properties for UserProfileEntity

import Foundation
import CoreData

extension UserProfileEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserProfileEntity> {
        return NSFetchRequest<UserProfileEntity>(entityName: "UserProfileEntity")
    }

    // MARK: - Identity
    @NSManaged public var id: UUID?
    @NSManaged public var email: String?
    @NSManaged public var displayName: String?

    // MARK: - Preferences
    @NSManaged public var preferredCurrency: String?
    @NSManaged public var fiscalYearStart: NSNumber?
    @NSManaged public var weekStartDay: NSNumber?

    // MARK: - Notifications
    @NSManaged public var enableNotifications: Bool
    @NSManaged public var enableBudgetAlerts: Bool
    @NSManaged public var enableBillReminders: Bool

    // MARK: - Security
    @NSManaged public var requireBiometric: Bool
    @NSManaged public var autoLockTimeout: NSNumber?

    // MARK: - Sync
    @NSManaged public var enableCloudSync: Bool

    // MARK: - Display
    @NSManaged public var theme: String?

    // MARK: - Metadata
    @NSManaged public var createdAt: Date?
    @NSManaged public var updatedAt: Date?
}

// MARK: - Identifiable
extension UserProfileEntity: Identifiable {
}
