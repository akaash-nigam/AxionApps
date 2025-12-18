//
//  UserProfileEntity+CoreDataClass.swift
//  WardrobeConsultant
//
//  Created by Claude Code
//  Copyright © 2025 Wardrobe Consultant. All rights reserved.
//

import Foundation
import CoreData

@objc(UserProfileEntity)
public class UserProfileEntity: NSManagedObject {

    // MARK: - Convenience Initializer
    convenience init(from profile: UserProfile, context: NSManagedObjectContext) {
        self.init(context: context)
        updateFrom(profile)
    }

    // MARK: - Update From Domain Model
    func updateFrom(_ profile: UserProfile) {
        self.id = profile.id
        self.createdAt = profile.createdAt
        self.updatedAt = Date()

        self.topSize = profile.topSize
        self.bottomSize = profile.bottomSize
        self.dressSize = profile.dressSize
        self.shoeSize = profile.shoeSize
        self.fitPreference = profile.fitPreference.rawValue

        self.primaryStyle = profile.primaryStyle.rawValue
        self.secondaryStyle = profile.secondaryStyle?.rawValue
        self.favoriteColorsData = try? JSONEncoder().encode(profile.favoriteColors)
        self.avoidColorsData = try? JSONEncoder().encode(profile.avoidColors)

        self.comfortLevel = profile.comfortLevel.rawValue
        self.budgetRange = profile.budgetRange.rawValue
        self.sustainabilityPreference = profile.sustainabilityPreference

        self.styleIconsData = try? JSONEncoder().encode(profile.styleIcons)

        self.temperatureUnit = profile.temperatureUnit.rawValue
        self.enableWeatherIntegration = profile.enableWeatherIntegration
        self.enableCalendarIntegration = profile.enableCalendarIntegration
        self.enableNotifications = profile.enableNotifications
    }

    // MARK: - Convert To Domain Model
    func toDomainModel() -> UserProfile {
        let favoriteColors = favoriteColorsData.flatMap {
            try? JSONDecoder().decode([String].self, from: $0)
        } ?? []

        let avoidColors = avoidColorsData.flatMap {
            try? JSONDecoder().decode([String].self, from: $0)
        } ?? []

        let styleIcons = styleIconsData.flatMap {
            try? JSONDecoder().decode([String].self, from: $0)
        } ?? []

        return UserProfile(
            id: id ?? UUID(),
            createdAt: createdAt ?? Date(),
            updatedAt: updatedAt ?? Date(),
            topSize: topSize,
            bottomSize: bottomSize,
            dressSize: dressSize,
            shoeSize: shoeSize,
            fitPreference: FitPreference(rawValue: fitPreference ?? "regular") ?? .regular,
            primaryStyle: StyleType(rawValue: primaryStyle ?? "classic") ?? .classic,
            secondaryStyle: secondaryStyle.flatMap { StyleType(rawValue: $0) },
            favoriteColors: favoriteColors,
            avoidColors: avoidColors,
            comfortLevel: ComfortLevel(rawValue: comfortLevel ?? "balanced") ?? .balanced,
            budgetRange: BudgetRange(rawValue: budgetRange ?? "moderate") ?? .moderate,
            sustainabilityPreference: sustainabilityPreference,
            styleIcons: styleIcons,
            temperatureUnit: TemperatureUnit(rawValue: temperatureUnit ?? "F") ?? .fahrenheit,
            enableWeatherIntegration: enableWeatherIntegration,
            enableCalendarIntegration: enableCalendarIntegration,
            enableNotifications: enableNotifications
        )
    }
}
