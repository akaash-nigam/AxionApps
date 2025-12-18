//
//  WeatherRecommendationService.swift
//  WardrobeConsultant
//
//  Created by Claude Code
//  Copyright © 2025 Wardrobe Consultant. All rights reserved.
//

import Foundation

/// Service for weather-based outfit recommendations
@MainActor
class WeatherRecommendationService {
    static let shared = WeatherRecommendationService()

    private let outfitGenerator = OutfitGenerationService.shared

    private init() {}

    // MARK: - Weather-Based Recommendations
    /// Get outfit recommendations based on current weather
    func recommendOutfits(
        temperature: Int,
        condition: WeatherCondition,
        occasion: OccasionType = .casual,
        limit: Int = 3
    ) async throws -> [GeneratedOutfit] {
        return try await outfitGenerator.generateOutfits(
            for: occasion,
            weather: condition,
            temperature: temperature,
            limit: limit
        )
    }

    // MARK: - Item Suitability
    /// Calculate how suitable an item is for specific weather
    func weatherSuitability(item: WardrobeItem, temperature: Int, condition: WeatherCondition) -> Float {
        var score: Float = 0.5

        // Temperature suitability
        let tempScore = temperatureSuitability(item: item, temperature: temperature)
        score += tempScore * 0.5

        // Condition suitability
        let conditionScore = conditionSuitability(item: item, condition: condition)
        score += conditionScore * 0.3

        // Fabric appropriateness
        let fabricScore = fabricSuitability(item: item, temperature: temperature, condition: condition)
        score += fabricScore * 0.2

        return min(score, 1.0)
    }

    // MARK: - Temperature Suitability
    private func temperatureSuitability(item: WardrobeItem, temperature: Int) -> Float {
        let tempRange = getTemperatureRange(for: item)

        if temperature >= tempRange.min && temperature <= tempRange.max {
            return 1.0
        }

        // Calculate how far outside the range
        let distance = min(abs(temperature - tempRange.min), abs(temperature - tempRange.max))

        // Degrade score based on distance
        return max(0, 1.0 - Float(distance) / 20.0)
    }

    private func getTemperatureRange(for item: WardrobeItem) -> (min: Int, max: Int) {
        // Base ranges on category
        switch item.category {
        case .tShirt, .tank, .shorts, .sandals, .dress:
            return (min: 20, max: 35) // 68-95°F

        case .sweater, .hoodie, .jacket, .boots:
            return (min: 5, max: 20) // 41-68°F

        case .coat, .parka, .gloves, .scarf:
            return (min: -10, max: 10) // 14-50°F

        case .jeans, .pants, .sneakers, .blouse, .buttonDown:
            return (min: 10, max: 25) // 50-77°F

        case .blazer, .suit:
            return (min: 15, max: 25) // 59-77°F

        default:
            return (min: 10, max: 25)
        }
    }

    // MARK: - Condition Suitability
    private func conditionSuitability(item: WardrobeItem, condition: WeatherCondition) -> Float {
        switch condition {
        case .rain, .thunderstorm:
            return rainSuitability(item)

        case .snow:
            return snowSuitability(item)

        case .sunny, .hot:
            return sunnySuitability(item)

        case .cloudy, .partlyCloudy:
            return 0.8 // Most items work

        case .windy:
            return windySuitability(item)

        case .foggy:
            return 0.7

        case .clear:
            return 0.9
        }
    }

    private func rainSuitability(_ item: WardrobeItem) -> Float {
        // Waterproof items are best
        if item.fabricType == .waterproof {
            return 1.0
        }

        // Synthetic materials handle rain better
        if item.fabricType == .synthetic || item.fabricType == .polyester {
            return 0.7
        }

        // Avoid delicate fabrics
        if [.silk, .suede, .velvet].contains(item.fabricType) {
            return 0.2
        }

        // Jackets and coats provide coverage
        if [.jacket, .coat, .parka, .raincoat].contains(item.category) {
            return 0.8
        }

        return 0.4
    }

    private func snowSuitability(_ item: WardrobeItem) -> Float {
        // Winter-appropriate items
        let winterCategories: Set<ClothingCategory> = [
            .coat, .parka, .sweater, .boots, .gloves, .scarf, .hat
        ]

        if winterCategories.contains(item.category) {
            return 1.0
        }

        // Warm fabrics
        if [.wool, .cashmere, .fleece, .down].contains(item.fabricType) {
            return 0.9
        }

        // Light summer items
        if [.tank, .shorts, .sandals, .dress].contains(item.category) {
            return 0.1
        }

        return 0.5
    }

    private func sunnySuitability(_ item: WardrobeItem) -> Float {
        // Light, breathable items
        let summerCategories: Set<ClothingCategory> = [
            .tShirt, .tank, .shorts, .sandals, .dress, .skirt
        ]

        if summerCategories.contains(item.category) {
            return 1.0
        }

        // Breathable fabrics
        if [.cotton, .linen].contains(item.fabricType) {
            return 0.9
        }

        // Heavy winter items
        if [.coat, .parka, .sweater, .boots].contains(item.category) {
            return 0.2
        }

        return 0.6
    }

    private func windySuitability(_ item: WardrobeItem) -> Float {
        // Jackets and coats provide wind protection
        if [.jacket, .coat, .windbreaker].contains(item.category) {
            return 1.0
        }

        // Avoid loose/flowy items
        if item.category == .dress || item.category == .skirt {
            return 0.4
        }

        return 0.7
    }

    // MARK: - Fabric Suitability
    private func fabricSuitability(item: WardrobeItem, temperature: Int, condition: WeatherCondition) -> Float {
        var score: Float = 0.5

        // Cold weather fabrics
        if temperature < 10 {
            if [.wool, .cashmere, .fleece, .down].contains(item.fabricType) {
                score += 0.5
            } else if [.cotton, .linen].contains(item.fabricType) {
                score -= 0.3
            }
        }

        // Hot weather fabrics
        if temperature > 25 {
            if [.cotton, .linen].contains(item.fabricType) {
                score += 0.5
            } else if [.wool, .fleece].contains(item.fabricType) {
                score -= 0.3
            }
        }

        // Wet conditions
        if [.rain, .snow, .thunderstorm].contains(condition) {
            if item.fabricType == .waterproof {
                score += 0.5
            } else if [.silk, .suede, .velvet].contains(item.fabricType) {
                score -= 0.4
            }
        }

        return max(0, min(score, 1.0))
    }

    // MARK: - Daily Recommendations
    /// Get a full day's worth of outfit recommendations based on weather forecast
    func dailyRecommendations(
        morningTemp: Int,
        afternoonTemp: Int,
        eveningTemp: Int,
        condition: WeatherCondition
    ) async throws -> DailyOutfitRecommendation {
        // Morning outfit (usually casual or work)
        let morningOutfits = try await recommendOutfits(
            temperature: morningTemp,
            condition: condition,
            occasion: .work,
            limit: 2
        )

        // Afternoon outfit (if temperature changes significantly)
        var afternoonOutfits: [GeneratedOutfit]?
        if abs(afternoonTemp - morningTemp) > 5 {
            afternoonOutfits = try await recommendOutfits(
                temperature: afternoonTemp,
                condition: condition,
                occasion: .casual,
                limit: 2
            )
        }

        // Evening outfit (optional, for special occasions)
        var eveningOutfits: [GeneratedOutfit]?
        if abs(eveningTemp - afternoonTemp) > 5 {
            eveningOutfits = try await recommendOutfits(
                temperature: eveningTemp,
                condition: condition,
                occasion: .casual,
                limit: 2
            )
        }

        return DailyOutfitRecommendation(
            morning: morningOutfits.first,
            afternoon: afternoonOutfits?.first,
            evening: eveningOutfits?.first,
            condition: condition,
            advice: generateWeatherAdvice(condition: condition, highTemp: afternoonTemp, lowTemp: morningTemp)
        )
    }

    private func generateWeatherAdvice(condition: WeatherCondition, highTemp: Int, lowTemp: Int) -> String {
        var advice: [String] = []

        // Temperature advice
        let tempDiff = highTemp - lowTemp
        if tempDiff > 10 {
            advice.append("Significant temperature change expected. Consider layering.")
        }

        if highTemp > 30 {
            advice.append("It's going to be hot. Opt for light, breathable fabrics.")
        } else if lowTemp < 5 {
            advice.append("Cold weather ahead. Bundle up with warm layers.")
        }

        // Condition advice
        switch condition {
        case .rain, .thunderstorm:
            advice.append("Rain expected. Bring waterproof outerwear.")
        case .snow:
            advice.append("Snow conditions. Wear warm, waterproof items.")
        case .sunny, .hot:
            advice.append("Sunny day. Don't forget sun protection.")
        case .windy:
            advice.append("Windy conditions. Avoid loose clothing.")
        default:
            break
        }

        return advice.joined(separator: " ")
    }
}

// MARK: - Supporting Types
struct DailyOutfitRecommendation {
    let morning: GeneratedOutfit?
    let afternoon: GeneratedOutfit?
    let evening: GeneratedOutfit?
    let condition: WeatherCondition
    let advice: String
}
