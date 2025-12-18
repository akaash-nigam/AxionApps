//
//  Property.swift
//  RealEstateSpatial
//
//  Core property data model
//

import Foundation
import SwiftData

// MARK: - Property Entity

@Model
final class Property {
    @Attribute(.unique) var id: UUID
    var mlsNumber: String
    var address: PropertyAddress
    var pricing: PricingInfo
    var specifications: PropertySpecs
    var media: PropertyMedia
    var spatial: SpatialData
    var metadata: PropertyMetadata
    var analytics: PropertyAnalytics?

    // Relationships
    @Relationship(deleteRule: .cascade) var rooms: [Room]
    @Relationship(deleteRule: .nullify) var viewingSessions: [ViewingSession]

    init(
        id: UUID = UUID(),
        mlsNumber: String,
        address: PropertyAddress,
        pricing: PricingInfo,
        specifications: PropertySpecs,
        media: PropertyMedia = PropertyMedia(),
        spatial: SpatialData = SpatialData(),
        metadata: PropertyMetadata = PropertyMetadata()
    ) {
        self.id = id
        self.mlsNumber = mlsNumber
        self.address = address
        self.pricing = pricing
        self.specifications = specifications
        self.media = media
        self.spatial = spatial
        self.metadata = metadata
        self.rooms = []
    }

    // Computed Properties
    var displayAddress: String {
        "\(address.street), \(address.city), \(address.state)"
    }

    var pricePerSqFt: Decimal {
        guard specifications.squareFeet > 0 else { return 0 }
        return pricing.listPrice / Decimal(specifications.squareFeet)
    }

    var isActive: Bool {
        metadata.status == .active
    }
}

// MARK: - Supporting Structures

struct PropertyAddress: Codable, Hashable {
    var street: String
    var city: String
    var state: String
    var zipCode: String
    var country: String
    var coordinates: GeographicCoordinate

    init(
        street: String,
        city: String,
        state: String,
        zipCode: String,
        country: String = "USA",
        coordinates: GeographicCoordinate
    ) {
        self.street = street
        self.city = city
        self.state = state
        self.zipCode = zipCode
        self.country = country
        self.coordinates = coordinates
    }
}

struct GeographicCoordinate: Codable, Hashable {
    var latitude: Double
    var longitude: Double
}

struct PricingInfo: Codable, Hashable {
    var listPrice: Decimal
    var priceHistory: [PriceChange]
    var estimatedValue: Decimal?
    var pricePerSqFt: Decimal
    var taxAssessment: Decimal
    var monthlyHOA: Decimal?

    init(
        listPrice: Decimal,
        priceHistory: [PriceChange] = [],
        estimatedValue: Decimal? = nil,
        pricePerSqFt: Decimal = 0,
        taxAssessment: Decimal = 0,
        monthlyHOA: Decimal? = nil
    ) {
        self.listPrice = listPrice
        self.priceHistory = priceHistory
        self.estimatedValue = estimatedValue
        self.pricePerSqFt = pricePerSqFt
        self.taxAssessment = taxAssessment
        self.monthlyHOA = monthlyHOA
    }
}

struct PriceChange: Codable, Hashable, Identifiable {
    var id: UUID = UUID()
    var date: Date
    var oldPrice: Decimal
    var newPrice: Decimal
    var changePercent: Double
}

struct PropertySpecs: Codable, Hashable {
    var bedrooms: Int
    var bathrooms: Double
    var squareFeet: Int
    var lotSize: Int?
    var yearBuilt: Int
    var propertyType: PropertyType
    var features: [String]
    var appliances: [String]

    init(
        bedrooms: Int,
        bathrooms: Double,
        squareFeet: Int,
        lotSize: Int? = nil,
        yearBuilt: Int,
        propertyType: PropertyType,
        features: [String] = [],
        appliances: [String] = []
    ) {
        self.bedrooms = bedrooms
        self.bathrooms = bathrooms
        self.squareFeet = squareFeet
        self.lotSize = lotSize
        self.yearBuilt = yearBuilt
        self.propertyType = propertyType
        self.features = features
        self.appliances = appliances
    }
}

struct PropertyMedia: Codable, Hashable {
    var photos: [MediaAsset]
    var virtualTour: VirtualTourAsset?
    var floorPlans: [MediaAsset]
    var videos: [MediaAsset]
    var documents: [DocumentAsset]

    init(
        photos: [MediaAsset] = [],
        virtualTour: VirtualTourAsset? = nil,
        floorPlans: [MediaAsset] = [],
        videos: [MediaAsset] = [],
        documents: [DocumentAsset] = []
    ) {
        self.photos = photos
        self.virtualTour = virtualTour
        self.floorPlans = floorPlans
        self.videos = videos
        self.documents = documents
    }
}

struct MediaAsset: Codable, Hashable, Identifiable {
    var id: UUID = UUID()
    var url: URL
    var thumbnailURL: URL?
    var caption: String?
    var order: Int

    init(url: URL, thumbnailURL: URL? = nil, caption: String? = nil, order: Int = 0) {
        self.url = url
        self.thumbnailURL = thumbnailURL
        self.caption = caption
        self.order = order
    }
}

struct VirtualTourAsset: Codable, Hashable {
    var spatialCaptureID: String
    var captureDate: Date
    var provider: String
}

struct DocumentAsset: Codable, Hashable, Identifiable {
    var id: UUID = UUID()
    var url: URL
    var title: String
    var documentType: DocumentType

    enum DocumentType: String, Codable {
        case disclosure
        case inspection
        case appraisal
        case titleReport
        case other
    }
}

struct SpatialData: Codable, Hashable {
    var spatialCaptureID: String
    var captureDate: Date
    var captureQuality: CaptureQuality
    var roomMeshURLs: [String]
    var textureAtlasURLs: [URL]
    var pointCloudURL: URL?

    init(
        spatialCaptureID: String = UUID().uuidString,
        captureDate: Date = Date(),
        captureQuality: CaptureQuality = .standard,
        roomMeshURLs: [String] = [],
        textureAtlasURLs: [URL] = [],
        pointCloudURL: URL? = nil
    ) {
        self.spatialCaptureID = spatialCaptureID
        self.captureDate = captureDate
        self.captureQuality = captureQuality
        self.roomMeshURLs = roomMeshURLs
        self.textureAtlasURLs = textureAtlasURLs
        self.pointCloudURL = pointCloudURL
    }
}

struct PropertyMetadata: Codable, Hashable {
    var status: PropertyStatus
    var listedDate: Date
    var updatedDate: Date
    var daysOnMarket: Int
    var viewCount: Int
    var favoriteCount: Int

    init(
        status: PropertyStatus = .active,
        listedDate: Date = Date(),
        updatedDate: Date = Date(),
        daysOnMarket: Int = 0,
        viewCount: Int = 0,
        favoriteCount: Int = 0
    ) {
        self.status = status
        self.listedDate = listedDate
        self.updatedDate = updatedDate
        self.daysOnMarket = daysOnMarket
        self.viewCount = viewCount
        self.favoriteCount = favoriteCount
    }
}

struct PropertyAnalytics: Codable, Hashable {
    var totalViews: Int
    var uniqueVisitors: Int
    var averageViewDuration: TimeInterval
    var tourCompletionRate: Double
    var engagementScore: Double
    var leadCount: Int
}

// MARK: - Enumerations

enum PropertyType: String, Codable, CaseIterable {
    case singleFamily = "Single Family"
    case condo = "Condo"
    case townhouse = "Townhouse"
    case multiFamily = "Multi-Family"
    case land = "Land"
    case commercial = "Commercial"
}

enum PropertyStatus: String, Codable {
    case active = "Active"
    case pending = "Pending"
    case sold = "Sold"
    case offMarket = "Off Market"
}

enum CaptureQuality: String, Codable {
    case standard = "Standard"
    case high = "High"
    case ultra = "Ultra"
}

// MARK: - Extensions

extension Property {
    static var preview: Property {
        Property(
            mlsNumber: "MLS123456",
            address: PropertyAddress(
                street: "123 Main Street",
                city: "San Francisco",
                state: "CA",
                zipCode: "94102",
                coordinates: GeographicCoordinate(latitude: 37.7749, longitude: -122.4194)
            ),
            pricing: PricingInfo(
                listPrice: 850000,
                pricePerSqFt: 354,
                taxAssessment: 8500,
                monthlyHOA: 250
            ),
            specifications: PropertySpecs(
                bedrooms: 3,
                bathrooms: 2.0,
                squareFeet: 2400,
                lotSize: 5000,
                yearBuilt: 2015,
                propertyType: .singleFamily,
                features: ["Hardwood floors", "Granite counters", "Central AC"],
                appliances: ["Refrigerator", "Dishwasher", "Microwave"]
            )
        )
    }
}
