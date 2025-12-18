// UserProfileEntity+CoreDataClass.swift
import Foundation
import CoreData

@objc(UserProfileEntity)
public class UserProfileEntity: NSManagedObject {}

extension UserProfileEntity {
    func toDomain() -> UserProfile {
        UserProfile(
            id: id ?? UUID(),
            email: email ?? "",
            displayName: displayName ?? "",
            preferredCurrency: preferredCurrency ?? "USD",
            fiscalYearStart: fiscalYearStart?.intValue ?? 1,
            weekStartDay: weekStartDay?.intValue ?? 1,
            enableNotifications: enableNotifications,
            enableBudgetAlerts: enableBudgetAlerts,
            enableBillReminders: enableBillReminders,
            requireBiometric: requireBiometric,
            autoLockTimeout: autoLockTimeout?.intValue ?? 300,
            enableCloudSync: enableCloudSync,
            theme: theme ?? "system",
            createdAt: createdAt ?? Date(),
            updatedAt: updatedAt ?? Date()
        )
    }

    func update(from profile: UserProfile) {
        self.id = profile.id
        self.email = profile.email
        self.displayName = profile.displayName
        self.preferredCurrency = profile.preferredCurrency
        self.fiscalYearStart = NSNumber(value: profile.fiscalYearStart)
        self.weekStartDay = NSNumber(value: profile.weekStartDay)
        self.enableNotifications = profile.enableNotifications
        self.enableBudgetAlerts = profile.enableBudgetAlerts
        self.enableBillReminders = profile.enableBillReminders
        self.requireBiometric = profile.requireBiometric
        self.autoLockTimeout = NSNumber(value: profile.autoLockTimeout)
        self.enableCloudSync = profile.enableCloudSync
        self.theme = profile.theme
        self.createdAt = profile.createdAt
        self.updatedAt = profile.updatedAt
    }

    static func from(_ profile: UserProfile, context: NSManagedObjectContext) -> UserProfileEntity {
        let entity = UserProfileEntity(context: context)
        entity.update(from: profile)
        return entity
    }
}
