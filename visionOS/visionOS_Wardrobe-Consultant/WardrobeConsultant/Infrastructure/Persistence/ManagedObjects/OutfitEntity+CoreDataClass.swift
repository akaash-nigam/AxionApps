//
//  OutfitEntity+CoreDataClass.swift
//  WardrobeConsultant
//
//  Created by Claude Code
//  Copyright © 2025 Wardrobe Consultant. All rights reserved.
//

import Foundation
import CoreData

@objc(OutfitEntity)
public class OutfitEntity: NSManagedObject {

    // MARK: - Convenience Initializer
    convenience init(from outfit: Outfit, context: NSManagedObjectContext) {
        self.init(context: context)
        updateFrom(outfit)
    }

    // MARK: - Update From Domain Model
    func updateFrom(_ outfit: Outfit) {
        self.id = outfit.id
        self.createdAt = outfit.createdAt
        self.updatedAt = Date()

        self.name = outfit.name
        self.occasionType = outfit.occasionType.rawValue

        self.season = outfit.season?.rawValue
        self.weatherCondition = outfit.weatherCondition?.rawValue
        self.temperatureMin = outfit.temperatureMin
        self.temperatureMax = outfit.temperatureMax

        self.styleType = outfit.styleType?.rawValue
        self.formalityLevel = outfit.formalityLevel

        self.timesWorn = Int32(outfit.timesWorn)
        self.lastWornDate = outfit.lastWornDate
        self.isFavorite = outfit.isFavorite

        self.isAIGenerated = outfit.isAIGenerated
        self.confidenceScore = outfit.confidenceScore

        // Store item IDs as a transformable array
        self.itemIDsData = try? JSONEncoder().encode(Array(outfit.itemIDs))
    }

    // MARK: - Convert To Domain Model
    func toDomainModel() -> Outfit {
        // Decode item IDs
        var itemIDs: Set<UUID> = []
        if let data = itemIDsData {
            itemIDs = Set((try? JSONDecoder().decode([UUID].self, from: data)) ?? [])
        }

        return Outfit(
            id: id ?? UUID(),
            createdAt: createdAt ?? Date(),
            updatedAt: updatedAt ?? Date(),
            name: name,
            occasionType: OccasionType(rawValue: occasionType ?? "casual") ?? .casual,
            season: season.flatMap { Season(rawValue: $0) },
            weatherCondition: weatherCondition.flatMap { WeatherCondition(rawValue: $0) },
            temperatureMin: temperatureMin,
            temperatureMax: temperatureMax,
            styleType: styleType.flatMap { StyleType(rawValue: $0) },
            formalityLevel: formalityLevel,
            timesWorn: Int(timesWorn),
            lastWornDate: lastWornDate,
            isFavorite: isFavorite,
            isAIGenerated: isAIGenerated,
            confidenceScore: confidenceScore,
            itemIDs: itemIDs
        )
    }
}
