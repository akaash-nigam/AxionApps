//
//  TestDataFactory.swift
//  WardrobeConsultant
//
//  Created by Claude Code
//  Copyright © 2025 Wardrobe Consultant. All rights reserved.
//

import Foundation
import UIKit

/// Factory for generating test data for unit and integration tests
class TestDataFactory {
    static let shared = TestDataFactory()

    // MARK: - Wardrobe Item Factory

    /// Creates a test wardrobe item with default values
    func createTestWardrobeItem(
        id: UUID = UUID(),
        category: ClothingCategory = .tShirt,
        primaryColor: String = "#0000FF",
        secondaryColor: String? = nil,
        brand: String = "Test Brand",
        size: String = "M",
        fabricType: FabricType = .cotton,
        pattern: ClothingPattern = .solid,
        season: Set<Season> = [.spring, .summer],
        occasions: Set<OccasionType> = [.casual],
        purchaseDate: Date = Date(),
        purchasePrice: Decimal? = 49.99,
        condition: ItemCondition = .excellent,
        timesWorn: Int = 5,
        isFavorite: Bool = false
    ) -> WardrobeItem {
        WardrobeItem(
            id: id,
            category: category,
            primaryColor: primaryColor,
            secondaryColor: secondaryColor,
            brand: brand,
            size: size,
            fabricType: fabricType,
            pattern: pattern,
            season: season,
            occasions: occasions,
            purchaseDate: purchaseDate,
            purchasePrice: purchasePrice,
            condition: condition,
            timesWorn: timesWorn,
            lastWornDate: nil,
            isFavorite: isFavorite,
            photoURL: nil,
            thumbnailURL: nil,
            tags: [],
            notes: nil,
            retailer: nil,
            careInstructions: "Machine wash cold",
            createdAt: Date(),
            updatedAt: Date()
        )
    }

    /// Creates a complete test wardrobe with various items
    func createSampleWardrobe(itemCount: Int = 20) -> [WardrobeItem] {
        var items: [WardrobeItem] = []

        // Tops (40%)
        let topCount = itemCount * 4 / 10
        for i in 0..<topCount {
            let categories: [ClothingCategory] = [.tShirt, .blouse, .sweater, .hoodie]
            let colors = ["#000000", "#FFFFFF", "#FF0000", "#0000FF", "#00FF00"]
            items.append(createTestWardrobeItem(
                category: categories[i % categories.count],
                primaryColor: colors[i % colors.count],
                timesWorn: Int.random(in: 0...20)
            ))
        }

        // Bottoms (30%)
        let bottomCount = itemCount * 3 / 10
        for i in 0..<bottomCount {
            let categories: [ClothingCategory] = [.jeans, .pants, .shorts, .skirt]
            items.append(createTestWardrobeItem(
                category: categories[i % categories.count],
                primaryColor: "#000080",
                timesWorn: Int.random(in: 0...20)
            ))
        }

        // Dresses (10%)
        let dressCount = itemCount * 1 / 10
        for _ in 0..<dressCount {
            items.append(createTestWardrobeItem(
                category: .dress,
                primaryColor: "#FF69B4",
                occasions: [.party, .dateNight]
            ))
        }

        // Outerwear (10%)
        let outerCount = itemCount * 1 / 10
        for i in 0..<outerCount {
            let categories: [ClothingCategory] = [.jacket, .coat, .blazer]
            items.append(createTestWardrobeItem(
                category: categories[i % categories.count],
                primaryColor: "#2F4F4F",
                season: [.fall, .winter]
            ))
        }

        // Shoes (10%)
        let shoeCount = itemCount - (topCount + bottomCount + dressCount + outerCount)
        for i in 0..<shoeCount {
            let categories: [ClothingCategory] = [.sneakers, .boots, .heels, .flats]
            items.append(createTestWardrobeItem(
                category: categories[i % categories.count],
                primaryColor: "#8B4513"
            ))
        }

        return items
    }

    // MARK: - Outfit Factory

    /// Creates a test outfit
    func createTestOutfit(
        id: UUID = UUID(),
        name: String = "Test Outfit",
        occasionType: OccasionType = .casual,
        itemIDs: Set<UUID>,
        minTemperature: Int = 15,
        maxTemperature: Int = 25,
        weatherConditions: Set<WeatherCondition> = [.clear],
        confidenceScore: Float = 0.85,
        isAIGenerated: Bool = true,
        isFavorite: Bool = false
    ) -> Outfit {
        Outfit(
            id: id,
            name: name,
            occasionType: occasionType,
            itemIDs: itemIDs,
            minTemperature: minTemperature,
            maxTemperature: maxTemperature,
            weatherConditions: weatherConditions,
            styleNotes: "Perfect for a casual day out",
            confidenceScore: confidenceScore,
            isAIGenerated: isAIGenerated,
            timesWorn: 0,
            lastWornDate: nil,
            isFavorite: isFavorite,
            createdAt: Date(),
            updatedAt: Date()
        )
    }

    /// Creates sample outfits from a wardrobe
    func createSampleOutfits(from items: [WardrobeItem], count: Int = 5) -> [Outfit] {
        guard items.count >= 3 else { return [] }

        var outfits: [Outfit] = []

        for i in 0..<count {
            // Pick random items (typically 3-4 per outfit)
            let itemCount = Int.random(in: 3...4)
            let selectedItems = items.shuffled().prefix(itemCount)
            let itemIDs = Set(selectedItems.map { $0.id })

            let occasions: [OccasionType] = [.casual, .work, .party, .workout, .dateNight]

            outfits.append(createTestOutfit(
                name: "Outfit \(i + 1)",
                occasionType: occasions[i % occasions.count],
                itemIDs: itemIDs,
                confidenceScore: Float.random(in: 0.7...0.95)
            ))
        }

        return outfits
    }

    // MARK: - User Profile Factory

    /// Creates a test user profile
    func createTestUserProfile(
        id: UUID = UUID(),
        topSize: String = "M",
        bottomSize: String = "32",
        dressSize: String = "8",
        shoeSize: String = "9",
        fitPreference: FitPreference = .regular,
        primaryStyle: StyleProfile = .casual,
        secondaryStyle: StyleProfile? = .minimalist,
        favoriteColors: [String] = ["#0000FF", "#000000", "#FFFFFF"],
        avoidColors: [String] = ["#FFFF00"],
        comfortLevel: ComfortLevel = .moderate,
        budgetRange: BudgetRange = .medium,
        sustainabilityPreference: Bool = true
    ) -> UserProfile {
        UserProfile(
            id: id,
            topSize: topSize,
            bottomSize: bottomSize,
            dressSize: dressSize,
            shoeSize: shoeSize,
            fitPreference: fitPreference,
            primaryStyle: primaryStyle,
            secondaryStyle: secondaryStyle,
            favoriteColors: favoriteColors,
            avoidColors: avoidColors,
            comfortLevel: comfortLevel,
            budgetRange: budgetRange,
            sustainabilityPreference: sustainabilityPreference,
            styleIcons: ["Audrey Hepburn", "Steve Jobs"],
            temperatureUnit: .fahrenheit,
            enableWeatherIntegration: true,
            enableCalendarIntegration: true,
            enableNotifications: true,
            createdAt: Date(),
            updatedAt: Date()
        )
    }

    // MARK: - Body Measurements Factory

    /// Creates test body measurements
    func createTestBodyMeasurements(
        height: Decimal = 170.0,
        weight: Decimal? = 65.0,
        chest: Decimal? = 90.0,
        waist: Decimal? = 75.0,
        hips: Decimal? = 95.0,
        inseam: Decimal? = 80.0
    ) -> BodyMeasurements {
        BodyMeasurements(
            height: height,
            weight: weight,
            chest: chest,
            waist: waist,
            hips: hips,
            inseam: inseam,
            shoulder: 42.0,
            neck: 36.0,
            sleeveLength: 60.0,
            unitSystem: .metric
        )
    }

    // MARK: - Predefined Test Sets

    /// Complete casual weekend outfit
    func casualWeekendOutfit() -> (items: [WardrobeItem], outfit: Outfit) {
        let tshirt = createTestWardrobeItem(
            category: .tShirt,
            primaryColor: "#4169E1",
            brand: "J.Crew",
            fabricType: .cotton
        )

        let jeans = createTestWardrobeItem(
            category: .jeans,
            primaryColor: "#000080",
            brand: "Levi's",
            fabricType: .denim
        )

        let sneakers = createTestWardrobeItem(
            category: .sneakers,
            primaryColor: "#FFFFFF",
            brand: "Nike"
        )

        let items = [tshirt, jeans, sneakers]
        let outfit = createTestOutfit(
            name: "Casual Weekend",
            occasionType: .casual,
            itemIDs: Set(items.map { $0.id }),
            minTemperature: 18,
            maxTemperature: 24,
            weatherConditions: [.clear, .partlyCloudy]
        )

        return (items, outfit)
    }

    /// Professional work outfit
    func professionalWorkOutfit() -> (items: [WardrobeItem], outfit: Outfit) {
        let blazer = createTestWardrobeItem(
            category: .blazer,
            primaryColor: "#2F4F4F",
            brand: "Hugo Boss",
            fabricType: .wool
        )

        let pants = createTestWardrobeItem(
            category: .pants,
            primaryColor: "#000000",
            brand: "Banana Republic",
            fabricType: .cotton
        )

        let blouse = createTestWardrobeItem(
            category: .blouse,
            primaryColor: "#FFFFFF",
            fabricType: .silk
        )

        let heels = createTestWardrobeItem(
            category: .heels,
            primaryColor: "#000000",
            brand: "Cole Haan"
        )

        let items = [blazer, pants, blouse, heels]
        let outfit = createTestOutfit(
            name: "Professional Work",
            occasionType: .work,
            itemIDs: Set(items.map { $0.id }),
            minTemperature: 20,
            maxTemperature: 23,
            weatherConditions: [.clear]
        )

        return (items, outfit)
    }

    /// Date night outfit
    func dateNightOutfit() -> (items: [WardrobeItem], outfit: Outfit) {
        let dress = createTestWardrobeItem(
            category: .dress,
            primaryColor: "#FF69B4",
            brand: "Reformation",
            fabricType: .silk,
            occasions: [.dateNight, .party]
        )

        let heels = createTestWardrobeItem(
            category: .heels,
            primaryColor: "#C0C0C0",
            brand: "Steve Madden"
        )

        let jacket = createTestWardrobeItem(
            category: .jacket,
            primaryColor: "#000000",
            fabricType: .leather
        )

        let items = [dress, heels, jacket]
        let outfit = createTestOutfit(
            name: "Date Night",
            occasionType: .dateNight,
            itemIDs: Set(items.map { $0.id }),
            minTemperature: 15,
            maxTemperature: 20,
            weatherConditions: [.clear, .partlyCloudy]
        )

        return (items, outfit)
    }

    /// Workout outfit
    func workoutOutfit() -> (items: [WardrobeItem], outfit: Outfit) {
        let tank = createTestWardrobeItem(
            category: .tank,
            primaryColor: "#00FF00",
            brand: "Lululemon",
            fabricType: .synthetic,
            occasions: [.workout]
        )

        let leggings = createTestWardrobeItem(
            category: .leggings,
            primaryColor: "#000000",
            brand: "Lululemon",
            fabricType: .synthetic,
            occasions: [.workout]
        )

        let sneakers = createTestWardrobeItem(
            category: .sneakers,
            primaryColor: "#FF0000",
            brand: "Nike"
        )

        let items = [tank, leggings, sneakers]
        let outfit = createTestOutfit(
            name: "Gym Workout",
            occasionType: .workout,
            itemIDs: Set(items.map { $0.id }),
            minTemperature: 18,
            maxTemperature: 25,
            weatherConditions: [.clear]
        )

        return (items, outfit)
    }

    // MARK: - Test Images

    /// Creates a simple test image for photo testing
    func createTestImage(width: Int = 800, height: Int = 1000, color: UIColor = .blue) -> UIImage {
        let size = CGSize(width: width, height: height)
        let renderer = UIGraphicsImageRenderer(size: size)

        return renderer.image { context in
            color.setFill()
            context.fill(CGRect(origin: .zero, size: size))

            // Add some distinguishing marks
            UIColor.white.setStroke()
            let path = UIBezierPath()
            path.move(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: width, y: height))
            path.move(to: CGPoint(x: width, y: 0))
            path.addLine(to: CGPoint(x: 0, y: height))
            path.lineWidth = 5
            path.stroke()
        }
    }
}

// MARK: - Test Data Constants

extension TestDataFactory {
    /// Common test colors as hex strings
    enum TestColors {
        static let black = "#000000"
        static let white = "#FFFFFF"
        static let red = "#FF0000"
        static let blue = "#0000FF"
        static let green = "#00FF00"
        static let navy = "#000080"
        static let gray = "#808080"
        static let beige = "#F5F5DC"
        static let pink = "#FF69B4"
        static let brown = "#8B4513"
    }

    /// Common test brands
    enum TestBrands {
        static let all = [
            "Nike", "Adidas", "J.Crew", "Levi's", "Zara",
            "H&M", "Uniqlo", "Banana Republic", "Gap", "Lululemon",
            "Patagonia", "North Face", "Hugo Boss", "Calvin Klein"
        ]
    }
}
