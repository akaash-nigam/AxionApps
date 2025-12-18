//
//  WardrobeItem.swift
//  WardrobeConsultant
//
//  Created by Claude Code
//  Copyright © 2025 Wardrobe Consultant. All rights reserved.
//

import Foundation

/// Represents a single clothing item in the user's wardrobe
struct WardrobeItem: Identifiable, Codable, Hashable {
    // MARK: - Identity
    let id: UUID
    var createdAt: Date
    var updatedAt: Date

    // MARK: - Basic Info
    var name: String?
    var category: ClothingCategory
    var subcategory: String?
    var brand: String?
    var size: String?

    // MARK: - Visual Attributes
    var primaryColor: String // Hex color
    var secondaryColor: String?
    var pattern: ClothingPattern?
    var fabric: FabricType?

    // MARK: - Photos & 3D
    var photoURL: URL?
    var thumbnailURL: URL?
    var modelURL: URL?

    // MARK: - Purchase Info
    var purchaseDate: Date?
    var purchasePrice: Decimal?
    var retailerName: String?
    var productURL: URL?

    // MARK: - Usage Tracking
    var timesWorn: Int
    var lastWornDate: Date?
    var firstWornDate: Date?

    // MARK: - Organization
    var season: Season?
    var occasion: OccasionType?
    var tags: Set<String>
    var isFavorite: Bool

    // MARK: - Condition
    var condition: ItemCondition
    var needsRepair: Bool
    var notes: String?

    // MARK: - Initialization
    init(
        id: UUID = UUID(),
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        name: String? = nil,
        category: ClothingCategory,
        primaryColor: String,
        subcategory: String? = nil,
        brand: String? = nil,
        size: String? = nil,
        secondaryColor: String? = nil,
        pattern: ClothingPattern? = nil,
        fabric: FabricType? = nil,
        photoURL: URL? = nil,
        thumbnailURL: URL? = nil,
        modelURL: URL? = nil,
        purchaseDate: Date? = nil,
        purchasePrice: Decimal? = nil,
        retailerName: String? = nil,
        productURL: URL? = nil,
        timesWorn: Int = 0,
        lastWornDate: Date? = nil,
        firstWornDate: Date? = nil,
        season: Season? = nil,
        occasion: OccasionType? = nil,
        tags: Set<String> = [],
        isFavorite: Bool = false,
        condition: ItemCondition = .good,
        needsRepair: Bool = false,
        notes: String? = nil
    ) {
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.name = name
        self.category = category
        self.primaryColor = primaryColor
        self.subcategory = subcategory
        self.brand = brand
        self.size = size
        self.secondaryColor = secondaryColor
        self.pattern = pattern
        self.fabric = fabric
        self.photoURL = photoURL
        self.thumbnailURL = thumbnailURL
        self.modelURL = modelURL
        self.purchaseDate = purchaseDate
        self.purchasePrice = purchasePrice
        self.retailerName = retailerName
        self.productURL = productURL
        self.timesWorn = timesWorn
        self.lastWornDate = lastWornDate
        self.firstWornDate = firstWornDate
        self.season = season
        self.occasion = occasion
        self.tags = tags
        self.isFavorite = isFavorite
        self.condition = condition
        self.needsRepair = needsRepair
        self.notes = notes
    }
}

// MARK: - Enumerations
enum ClothingCategory: String, Codable, CaseIterable {
    case shirt
    case blouse
    case tshirt
    case sweater
    case hoodie
    case jacket
    case coat
    case blazer
    case cardigan

    case pants
    case jeans
    case shorts
    case skirt
    case leggings

    case dress
    case jumpsuit

    case shoes
    case boots
    case sneakers
    case sandals
    case heels

    case accessories
    case scarf
    case hat
    case belt
    case jewelry
    case bag

    var displayName: String {
        rawValue.capitalized
    }

    var parentCategory: ParentCategory {
        switch self {
        case .shirt, .blouse, .tshirt, .sweater, .hoodie, .jacket, .coat, .blazer, .cardigan:
            return .tops
        case .pants, .jeans, .shorts, .skirt, .leggings:
            return .bottoms
        case .dress, .jumpsuit:
            return .dresses
        case .shoes, .boots, .sneakers, .sandals, .heels:
            return .shoes
        case .accessories, .scarf, .hat, .belt, .jewelry, .bag:
            return .accessories
        }
    }

    var isTop: Bool {
        parentCategory == .tops
    }

    var isBottom: Bool {
        parentCategory == .bottoms
    }
}

enum ParentCategory: String, Codable {
    case tops
    case bottoms
    case dresses
    case shoes
    case accessories
}

enum ClothingPattern: String, Codable, CaseIterable {
    case solid
    case striped
    case checkered
    case plaid
    case floral
    case polkaDot
    case geometric
    case animal
    case abstract
    case paisley

    var displayName: String {
        rawValue.capitalized
    }
}

enum FabricType: String, Codable, CaseIterable {
    case cotton
    case polyester
    case wool
    case silk
    case linen
    case denim
    case leather
    case cashmere
    case nylon
    case rayon
    case blend

    var displayName: String {
        rawValue.capitalized
    }

    var breathability: Float {
        switch self {
        case .cotton, .linen: return 0.9
        case .silk, .rayon: return 0.7
        case .wool, .cashmere: return 0.6
        case .polyester, .nylon: return 0.4
        case .denim, .blend: return 0.5
        case .leather: return 0.2
        }
    }

    var warmth: Float {
        switch self {
        case .wool, .cashmere: return 0.9
        case .leather: return 0.8
        case .denim: return 0.6
        case .cotton, .polyester, .blend: return 0.5
        case .silk, .rayon: return 0.4
        case .linen, .nylon: return 0.3
        }
    }
}

enum Season: String, Codable, CaseIterable {
    case spring
    case summer
    case fall
    case winter
    case allSeason

    var displayName: String {
        rawValue.capitalized
    }

    static func current() -> Season {
        let month = Calendar.current.component(.month, from: Date())
        switch month {
        case 3...5: return .spring
        case 6...8: return .summer
        case 9...11: return .fall
        default: return .winter
        }
    }
}

enum OccasionType: String, Codable, CaseIterable {
    case work
    case workPresentation
    case workCasual
    case casual
    case dateNight
    case brunch
    case party
    case wedding
    case formalEvent
    case interview
    case gym
    case athletic
    case loungewear
    case travel
    case outdoor
    case beach

    var displayName: String {
        switch self {
        case .workPresentation: return "Work Presentation"
        case .workCasual: return "Work Casual"
        case .dateNight: return "Date Night"
        case .formalEvent: return "Formal Event"
        default: return rawValue.capitalized
        }
    }

    var formalityLevel: Int {
        switch self {
        case .formalEvent, .wedding: return 9
        case .interview, .workPresentation: return 8
        case .work: return 7
        case .workCasual: return 6
        case .dateNight, .party: return 5
        case .brunch: return 4
        case .casual, .travel: return 3
        case .outdoor: return 2
        case .athletic, .gym, .loungewear, .beach: return 1
        }
    }
}

enum ItemCondition: String, Codable, CaseIterable {
    case new
    case excellent
    case good
    case fair
    case worn
    case damaged

    var displayName: String {
        rawValue.capitalized
    }

    var canWear: Bool {
        self != .damaged
    }
}
