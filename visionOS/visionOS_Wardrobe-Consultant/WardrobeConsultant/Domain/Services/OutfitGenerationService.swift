//
//  OutfitGenerationService.swift
//  WardrobeConsultant
//
//  Created by Claude Code
//  Copyright © 2025 Wardrobe Consultant. All rights reserved.
//

import Foundation

/// Service for generating outfit combinations using AI algorithms
@MainActor
class OutfitGenerationService {
    static let shared = OutfitGenerationService()

    private let colorHarmony = ColorHarmonyService.shared
    private let wardrobeRepository: WardrobeRepository
    private let userProfileRepository: UserProfileRepository

    init(
        wardrobeRepository: WardrobeRepository = CoreDataWardrobeRepository.shared,
        userProfileRepository: UserProfileRepository = CoreDataUserProfileRepository.shared
    ) {
        self.wardrobeRepository = wardrobeRepository
        self.userProfileRepository = userProfileRepository
    }

    // MARK: - Outfit Generation
    /// Generate outfit suggestions for a specific occasion
    func generateOutfits(
        for occasion: OccasionType,
        weather: WeatherCondition? = nil,
        temperature: Int? = nil,
        limit: Int = 5
    ) async throws -> [GeneratedOutfit] {
        let items = try await wardrobeRepository.fetchAll()
        let profile = try await userProfileRepository.fetch()

        // Filter items by occasion
        let suitableItems = items.filter { $0.occasions.contains(occasion) }

        guard !suitableItems.isEmpty else {
            throw OutfitGenerationError.insufficientItems
        }

        var outfits: [GeneratedOutfit] = []

        // Generate multiple outfit combinations
        for _ in 0..<limit {
            if let outfit = try await generateSingleOutfit(
                from: suitableItems,
                occasion: occasion,
                profile: profile,
                weather: weather,
                temperature: temperature
            ) {
                outfits.append(outfit)
            }
        }

        return outfits.sorted { $0.confidenceScore > $1.confidenceScore }
    }

    /// Generate a single outfit combination
    private func generateSingleOutfit(
        from items: [WardrobeItem],
        occasion: OccasionType,
        profile: UserProfile,
        weather: WeatherCondition?,
        temperature: Int?
    ) async throws -> GeneratedOutfit? {
        var selectedItems: [WardrobeItem] = []
        var usedCategories: Set<ClothingCategory> = []

        // Determine required categories based on occasion
        let requiredCategories = getRequiredCategories(for: occasion)

        // 1. Select a base item (usually a top or dress)
        if let baseItem = selectBaseItem(from: items, occasion: occasion, profile: profile) {
            selectedItems.append(baseItem)
            usedCategories.insert(baseItem.category)

            // 2. Select complementary items
            for category in requiredCategories where !usedCategories.contains(category) {
                let categoryItems = items.filter { $0.category == category }

                if let matchingItem = selectMatchingItem(
                    from: categoryItems,
                    toMatch: selectedItems,
                    profile: profile,
                    weather: weather,
                    temperature: temperature
                ) {
                    selectedItems.append(matchingItem)
                    usedCategories.insert(category)
                }
            }

            // 3. Add accessories or outerwear if appropriate
            if let accessory = selectAccessory(from: items, toMatch: selectedItems, occasion: occasion) {
                selectedItems.append(accessory)
            }

            // 4. Calculate confidence score
            let score = calculateConfidenceScore(
                items: selectedItems,
                occasion: occasion,
                profile: profile,
                weather: weather
            )

            return GeneratedOutfit(
                items: selectedItems,
                occasionType: occasion,
                confidenceScore: score,
                reasoning: generateReasoning(items: selectedItems, occasion: occasion)
            )
        }

        return nil
    }

    // MARK: - Item Selection
    private func selectBaseItem(
        from items: [WardrobeItem],
        occasion: OccasionType,
        profile: UserProfile
    ) -> WardrobeItem? {
        // Prefer dresses for certain occasions
        let dressPriority: [OccasionType] = [.formal, .party, .dateNight]

        if dressPriority.contains(occasion) {
            let dresses = items.filter { $0.category == .dress }
            if let dress = selectBestMatch(from: dresses, profile: profile) {
                return dress
            }
        }

        // Otherwise select tops
        let tops = items.filter { TopCategories.contains($0.category) }
        return selectBestMatch(from: tops, profile: profile)
    }

    private func selectMatchingItem(
        from candidates: [WardrobeItem],
        toMatch existingItems: [WardrobeItem],
        profile: UserProfile,
        weather: WeatherCondition?,
        temperature: Int?
    ) -> WardrobeItem? {
        guard !candidates.isEmpty else { return nil }

        var scored: [(item: WardrobeItem, score: Float)] = []

        for candidate in candidates {
            var score: Float = 0.5

            // Color compatibility
            let colorScore = calculateColorCompatibility(candidate, with: existingItems)
            score += colorScore * 0.4

            // Style compatibility
            let styleScore = calculateStyleCompatibility(candidate, with: existingItems, profile: profile)
            score += styleScore * 0.3

            // Weather suitability
            if let weather = weather {
                let weatherScore = calculateWeatherSuitability(candidate, weather: weather, temperature: temperature)
                score += weatherScore * 0.2
            }

            // Freshness (prefer less worn items)
            let freshnessScore = 1.0 - (Float(candidate.timesWorn) / 100.0)
            score += max(freshnessScore, 0) * 0.1

            scored.append((item: candidate, score: score))
        }

        return scored.sorted { $0.score > $1.score }.first?.item
    }

    private func selectBestMatch(from items: [WardrobeItem], profile: UserProfile) -> WardrobeItem? {
        guard !items.isEmpty else { return nil }

        var scored: [(item: WardrobeItem, score: Float)] = []

        for item in items {
            var score: Float = 0.5

            // Favorite colors
            if profile.favoriteColors.contains(item.primaryColor) {
                score += 0.3
            }

            // Avoid colors
            if profile.avoidColors.contains(item.primaryColor) {
                score -= 0.5
            }

            // Condition
            switch item.condition {
            case .excellent: score += 0.1
            case .good: score += 0.05
            default: break
            }

            // Favorites
            if item.isFavorite {
                score += 0.15
            }

            scored.append((item: item, score: score))
        }

        return scored.sorted { $0.score > $1.score }.first?.item
    }

    private func selectAccessory(
        from items: [WardrobeItem],
        toMatch existingItems: [WardrobeItem],
        occasion: OccasionType
    ) -> WardrobeItem? {
        let accessories = items.filter { AccessoryCategories.contains($0.category) }
        let shoes = items.filter { ShoeCategories.contains($0.category) }

        // Prioritize shoes
        if !shoes.isEmpty {
            let appropriateShoes = selectAppropriateShoes(from: shoes, occasion: occasion)
            if let shoe = appropriateShoes.randomElement() {
                return shoe
            }
        }

        // Then other accessories
        return accessories.randomElement()
    }

    private func selectAppropriateShoes(from shoes: [WardrobeItem], occasion: OccasionType) -> [WardrobeItem] {
        switch occasion {
        case .formal, .party, .dateNight:
            return shoes.filter { [.heels, .loafers, .oxfords].contains($0.category) }
        case .workout:
            return shoes.filter { $0.category == .sneakers }
        case .casual:
            return shoes.filter { [.sneakers, .flats, .sandals].contains($0.category) }
        case .work:
            return shoes.filter { [.heels, .flats, .loafers, .oxfords].contains($0.category) }
        default:
            return shoes
        }
    }

    // MARK: - Scoring
    private func calculateColorCompatibility(_ item: WardrobeItem, with items: [WardrobeItem]) -> Float {
        var totalScore: Float = 0
        var count = 0

        for existing in items {
            let score = colorHarmony.compatibilityScore(color1: item.primaryColor, color2: existing.primaryColor)
            totalScore += score
            count += 1
        }

        return count > 0 ? totalScore / Float(count) : 0.5
    }

    private func calculateStyleCompatibility(_ item: WardrobeItem, with items: [WardrobeItem], profile: UserProfile) -> Float {
        var score: Float = 0.5

        // Check fabric compatibility
        let fabrics = items.map { $0.fabricType }
        if fabrics.allSatisfy({ $0 == .cotton || $0 == .linen }) && (item.fabricType == .cotton || item.fabricType == .linen) {
            score += 0.2
        }

        // Check pattern mixing
        let patterns = items.map { $0.pattern }
        let solidCount = patterns.filter { $0 == .solid }.count

        if item.pattern == .solid {
            score += 0.1
        } else if solidCount >= patterns.count - 1 {
            // One patterned item with solids is good
            score += 0.15
        }

        return min(score, 1.0)
    }

    private func calculateWeatherSuitability(_ item: WardrobeItem, weather: WeatherCondition, temperature: Int?) -> Float {
        var score: Float = 0.5

        // Check if item is suitable for weather
        if item.weatherConditions.contains(weather) {
            score += 0.3
        }

        // Check fabric for weather
        switch weather {
        case .rain, .snow:
            if [.synthetic, .waterproof].contains(item.fabricType) {
                score += 0.2
            }
        case .sunny, .hot:
            if [.cotton, .linen].contains(item.fabricType) {
                score += 0.2
            }
        default:
            break
        }

        return min(score, 1.0)
    }

    private func calculateConfidenceScore(
        items: [WardrobeItem],
        occasion: OccasionType,
        profile: UserProfile,
        weather: WeatherCondition?
    ) -> Float {
        var score: Float = 0.6 // Base score

        // Color harmony
        let colors = items.map { $0.primaryColor }
        var colorScore: Float = 0
        var pairs = 0

        for i in 0..<colors.count {
            for j in (i+1)..<colors.count {
                colorScore += colorHarmony.compatibilityScore(color1: colors[i], color2: colors[j])
                pairs += 1
            }
        }

        if pairs > 0 {
            score += (colorScore / Float(pairs)) * 0.3
        }

        // Occasion appropriateness
        let occasionScore = items.filter { $0.occasions.contains(occasion) }.count
        score += Float(occasionScore) / Float(items.count) * 0.1

        // Profile preference
        let favoriteColorCount = items.filter { profile.favoriteColors.contains($0.primaryColor) }.count
        if favoriteColorCount > 0 {
            score += 0.1
        }

        return min(score, 1.0)
    }

    // MARK: - Helper Methods
    private func getRequiredCategories(for occasion: OccasionType) -> [ClothingCategory] {
        switch occasion {
        case .formal:
            return [.blazer, .pants, .heels]
        case .work:
            return [.blouse, .pants, .blazer]
        case .casual:
            return [.tShirt, .jeans, .sneakers]
        case .workout:
            return [.tank, .leggings, .sneakers]
        case .party, .dateNight:
            return [.dress, .heels]
        case .outdoor:
            return [.tShirt, .shorts, .sneakers]
        case .travel:
            return [.tShirt, .jeans, .sneakers, .jacket]
        }
    }

    private func generateReasoning(items: [WardrobeItem], occasion: OccasionType) -> String {
        let categories = items.map { $0.category.rawValue.capitalized }.joined(separator: ", ")
        return "This outfit combines \(categories) perfectly for \(occasion.rawValue) occasions. The colors complement each other well and the style is cohesive."
    }

    // MARK: - Category Sets
    private let TopCategories: Set<ClothingCategory> = [
        .tShirt, .blouse, .sweater, .hoodie, .tank, .polo, .buttonDown
    ]

    private let AccessoryCategories: Set<ClothingCategory> = [
        .hat, .scarf, .belt, .jewelry, .watch, .glasses, .tie, .bag
    ]

    private let ShoeCategories: Set<ClothingCategory> = [
        .sneakers, .boots, .heels, .flats, .sandals, .loafers, .oxfords
    ]
}

// MARK: - Supporting Types
struct GeneratedOutfit {
    let items: [WardrobeItem]
    let occasionType: OccasionType
    let confidenceScore: Float
    let reasoning: String

    var itemIDs: Set<UUID> {
        Set(items.map { $0.id })
    }

    func toOutfit(name: String? = nil) -> Outfit {
        Outfit(
            id: UUID(),
            name: name ?? "AI Generated Outfit",
            occasionType: occasionType,
            itemIDs: itemIDs,
            minTemperature: 15,
            maxTemperature: 25,
            weatherConditions: [.clear],
            styleNotes: reasoning,
            confidenceScore: confidenceScore,
            isAIGenerated: true,
            timesWorn: 0,
            lastWornDate: nil,
            isFavorite: false,
            createdAt: Date(),
            updatedAt: Date()
        )
    }
}

enum OutfitGenerationError: Error {
    case insufficientItems
    case noSuitableItems
}
