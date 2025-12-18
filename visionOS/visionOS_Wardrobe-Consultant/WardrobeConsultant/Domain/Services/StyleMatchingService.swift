//
//  StyleMatchingService.swift
//  WardrobeConsultant
//
//  Created by Claude Code
//  Copyright © 2025 Wardrobe Consultant. All rights reserved.
//

import Foundation

/// Service for matching items and outfits based on style preferences
@MainActor
class StyleMatchingService {
    static let shared = StyleMatchingService()

    private init() {}

    // MARK: - Style Scoring
    /// Calculate how well an item matches a user's style profile
    func styleScore(item: WardrobeItem, profile: UserProfile) -> Float {
        var score: Float = 0.5 // Base score

        // Primary style match
        let primaryScore = matchStyleProfile(item: item, style: profile.primaryStyle)
        score += primaryScore * 0.5

        // Secondary style match
        if let secondaryStyle = profile.secondaryStyle {
            let secondaryScore = matchStyleProfile(item: item, style: secondaryStyle)
            score += secondaryScore * 0.2
        }

        // Color preferences
        if profile.favoriteColors.contains(item.primaryColor) {
            score += 0.2
        }

        if profile.avoidColors.contains(item.primaryColor) {
            score -= 0.3
        }

        // Comfort level
        if let comfortLevel = profile.comfortLevel {
            score += comfortScore(item: item, preferredLevel: comfortLevel) * 0.1
        }

        return max(0, min(score, 1.0))
    }

    /// Match an item to a specific style profile
    private func matchStyleProfile(item: WardrobeItem, style: StyleProfile) -> Float {
        switch style {
        case .casual:
            return casualScore(item)
        case .formal:
            return formalScore(item)
        case .business:
            return businessScore(item)
        case .bohemian:
            return bohemianScore(item)
        case .minimalist:
            return minimalistScore(item)
        case .streetwear:
            return streetwearScore(item)
        case .preppy:
            return preppyScore(item)
        case .athletic:
            return athleticScore(item)
        case .vintage:
            return vintageScore(item)
        case .classic:
            return classicScore(item)
        }
    }

    // MARK: - Style Profile Scoring
    private func casualScore(_ item: WardrobeItem) -> Float {
        let casualCategories: Set<ClothingCategory> = [.tShirt, .jeans, .shorts, .sneakers, .hoodie, .tank]
        let casualFabrics: Set<FabricType> = [.cotton, .denim, .fleece]

        var score: Float = 0.5

        if casualCategories.contains(item.category) {
            score += 0.3
        }

        if casualFabrics.contains(item.fabricType) {
            score += 0.2
        }

        return score
    }

    private func formalScore(_ item: WardrobeItem) -> Float {
        let formalCategories: Set<ClothingCategory> = [.suit, .dress, .blazer, .heels, .oxfords, .tie]
        let formalFabrics: Set<FabricType> = [.silk, .wool, .cashmere, .velvet]

        var score: Float = 0.5

        if formalCategories.contains(item.category) {
            score += 0.3
        }

        if formalFabrics.contains(item.fabricType) {
            score += 0.2
        }

        return score
    }

    private func businessScore(_ item: WardrobeItem) -> Float {
        let businessCategories: Set<ClothingCategory> = [.blazer, .pants, .blouse, .buttonDown, .loafers, .heels]
        let businessFabrics: Set<FabricType> = [.wool, .cotton, .polyester]

        var score: Float = 0.5

        if businessCategories.contains(item.category) {
            score += 0.3
        }

        if businessFabrics.contains(item.fabricType) {
            score += 0.1
        }

        if item.pattern == .solid || item.pattern == .pinstripe {
            score += 0.1
        }

        return score
    }

    private func bohemianScore(_ item: WardrobeItem) -> Float {
        let bohemianCategories: Set<ClothingCategory> = [.dress, .skirt, .kimono, .sandals]
        let bohemianFabrics: Set<FabricType> = [.cotton, .linen, .suede]
        let bohemianPatterns: Set<ClothingPattern> = [.floral, .paisley, .tribal]

        var score: Float = 0.5

        if bohemianCategories.contains(item.category) {
            score += 0.2
        }

        if bohemianFabrics.contains(item.fabricType) {
            score += 0.15
        }

        if bohemianPatterns.contains(item.pattern) {
            score += 0.15
        }

        return score
    }

    private func minimalistScore(_ item: WardrobeItem) -> Float {
        var score: Float = 0.5

        if item.pattern == .solid {
            score += 0.3
        }

        // Neutral colors
        let neutrals = ["#000000", "#FFFFFF", "#808080", "#C0C0C0", "#F5F5DC"]
        if neutrals.contains(item.primaryColor) {
            score += 0.2
        }

        return score
    }

    private func streetwearScore(_ item: WardrobeItem) -> Float {
        let streetCategories: Set<ClothingCategory> = [.hoodie, .tShirt, .jeans, .sneakers, .jacket, .hat]
        let streetFabrics: Set<FabricType> = [.cotton, .denim, .synthetic]

        var score: Float = 0.5

        if streetCategories.contains(item.category) {
            score += 0.3
        }

        if streetFabrics.contains(item.fabricType) {
            score += 0.2
        }

        return score
    }

    private func preppyScore(_ item: WardrobeItem) -> Float {
        let preppyCategories: Set<ClothingCategory> = [.polo, .buttonDown, .blazer, .loafers, .oxfords]
        let preppyPatterns: Set<ClothingPattern> = [.plaid, .gingham, .stripes]

        var score: Float = 0.5

        if preppyCategories.contains(item.category) {
            score += 0.3
        }

        if preppyPatterns.contains(item.pattern) {
            score += 0.2
        }

        return score
    }

    private func athleticScore(_ item: WardrobeItem) -> Float {
        let athleticCategories: Set<ClothingCategory> = [.leggings, .tank, .shorts, .sneakers, .hoodie]
        let athleticFabrics: Set<FabricType> = [.synthetic, .spandex]

        var score: Float = 0.5

        if athleticCategories.contains(item.category) {
            score += 0.3
        }

        if athleticFabrics.contains(item.fabricType) {
            score += 0.2
        }

        return score
    }

    private func vintageScore(_ item: WardrobeItem) -> Float {
        let vintageCategories: Set<ClothingCategory> = [.dress, .coat, .blazer, .heels]
        let vintagePatterns: Set<ClothingPattern> = [.floral, .polkaDots, .paisley]

        var score: Float = 0.5

        if vintageCategories.contains(item.category) {
            score += 0.2
        }

        if vintagePatterns.contains(item.pattern) {
            score += 0.2
        }

        // Age bonus
        let yearsSincePurchase = Calendar.current.dateComponents([.year], from: item.purchaseDate, to: Date()).year ?? 0
        if yearsSincePurchase > 5 {
            score += 0.1
        }

        return score
    }

    private func classicScore(_ item: WardrobeItem) -> Float {
        let classicCategories: Set<ClothingCategory> = [.blazer, .pants, .dress, .trenchCoat, .loafers, .heels]
        let classicFabrics: Set<FabricType> = [.wool, .cotton, .silk]

        var score: Float = 0.5

        if classicCategories.contains(item.category) {
            score += 0.3
        }

        if classicFabrics.contains(item.fabricType) {
            score += 0.1
        }

        if item.pattern == .solid || item.pattern == .stripes {
            score += 0.1
        }

        return score
    }

    // MARK: - Comfort Scoring
    private func comfortScore(item: WardrobeItem, preferredLevel: ComfortLevel) -> Float {
        let comfortableFabrics: Set<FabricType> = [.cotton, .fleece, .cashmere]
        let uncomfortableFabrics: Set<FabricType> = [.polyester, .acrylic]

        switch preferredLevel {
        case .veryComfortable:
            if comfortableFabrics.contains(item.fabricType) {
                return 1.0
            }
            return 0.3

        case .comfortable:
            if comfortableFabrics.contains(item.fabricType) {
                return 0.8
            }
            return 0.5

        case .moderate:
            return 0.5

        case .stylishOverComfort:
            if uncomfortableFabrics.contains(item.fabricType) {
                return 0.7
            }
            return 0.5
        }
    }

    // MARK: - Outfit Style Scoring
    /// Calculate style consistency score for an outfit
    func outfitStyleScore(items: [WardrobeItem]) -> Float {
        guard items.count >= 2 else { return 0.5 }

        var score: Float = 0.5

        // Check fabric consistency
        let fabrics = Set(items.map { $0.fabricType })
        if fabrics.count <= 2 {
            score += 0.2
        }

        // Check pattern mixing
        let patterns = items.map { $0.pattern }
        let nonSolidPatterns = patterns.filter { $0 != .solid }

        if nonSolidPatterns.count <= 1 {
            // Good: mostly solid with max one pattern
            score += 0.2
        } else if nonSolidPatterns.count == 2 {
            // Acceptable: two patterns
            score += 0.1
        }

        // Check category balance
        let categories = Set(items.map { $0.category })
        if categories.count == items.count {
            // Good: each item is a different category
            score += 0.1
        }

        return min(score, 1.0)
    }

    // MARK: - Recommendations
    /// Get style-based recommendations for items that would work well with the wardrobe
    func recommendStyleAdditions(
        wardrobe: [WardrobeItem],
        profile: UserProfile
    ) -> [StyleRecommendation] {
        var recommendations: [StyleRecommendation] = []

        // Analyze wardrobe gaps
        let categories = Set(wardrobe.map { $0.category })

        // Check for missing essentials based on style
        let essentials = getStyleEssentials(for: profile.primaryStyle)

        for essential in essentials where !categories.contains(essential.category) {
            recommendations.append(essential)
        }

        return recommendations
    }

    private func getStyleEssentials(for style: StyleProfile) -> [StyleRecommendation] {
        switch style {
        case .casual:
            return [
                StyleRecommendation(category: .jeans, reason: "Essential for casual outfits"),
                StyleRecommendation(category: .tShirt, reason: "Versatile casual staple"),
                StyleRecommendation(category: .sneakers, reason: "Comfortable everyday footwear")
            ]

        case .business:
            return [
                StyleRecommendation(category: .blazer, reason: "Professional essential"),
                StyleRecommendation(category: .pants, reason: "Business appropriate bottoms"),
                StyleRecommendation(category: .buttonDown, reason: "Classic business top")
            ]

        default:
            return []
        }
    }
}

// MARK: - Supporting Types
struct StyleRecommendation {
    let category: ClothingCategory
    let reason: String
}
