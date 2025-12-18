//
//  UserProfileEntity+CoreDataProperties.swift
//  WardrobeConsultant
//
//  Created by Claude Code
//  Copyright © 2025 Wardrobe Consultant. All rights reserved.
//

import Foundation
import CoreData

extension UserProfileEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserProfileEntity> {
        return NSFetchRequest<UserProfileEntity>(entityName: "UserProfileEntity")
    }

    // MARK: - Identity
    @NSManaged public var id: UUID?
    @NSManaged public var createdAt: Date?
    @NSManaged public var updatedAt: Date?

    // MARK: - Size Preferences
    @NSManaged public var topSize: String?
    @NSManaged public var bottomSize: String?
    @NSManaged public var dressSize: String?
    @NSManaged public var shoeSize: String?
    @NSManaged public var fitPreference: String?

    // MARK: - Style Profile
    @NSManaged public var primaryStyle: String?
    @NSManaged public var secondaryStyle: String?
    @NSManaged public var favoriteColorsData: Data?
    @NSManaged public var avoidColorsData: Data?

    // MARK: - Preferences
    @NSManaged public var comfortLevel: String?
    @NSManaged public var budgetRange: String?
    @NSManaged public var sustainabilityPreference: Bool

    // MARK: - Style Icons
    @NSManaged public var styleIconsData: Data?

    // MARK: - Settings
    @NSManaged public var temperatureUnit: String?
    @NSManaged public var enableWeatherIntegration: Bool
    @NSManaged public var enableCalendarIntegration: Bool
    @NSManaged public var enableNotifications: Bool
}
