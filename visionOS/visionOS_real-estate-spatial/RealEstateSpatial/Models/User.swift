//
//  User.swift
//  RealEstateSpatial
//
//  User entity and profile management
//

import Foundation
import SwiftData

// MARK: - User Entity

@Model
final class User {
    @Attribute(.unique) var id: UUID
    var email: String
    var profile: UserProfile
    var preferences: UserPreferences
    var role: UserRole
    var createdDate: Date
    var lastLoginDate: Date

    @Relationship(deleteRule: .cascade) var savedProperties: [Property]
    @Relationship(deleteRule: .cascade) var viewingSessions: [ViewingSession]
    @Relationship(deleteRule: .cascade) var searchHistory: [SearchQuery]

    init(
        id: UUID = UUID(),
        email: String,
        profile: UserProfile,
        preferences: UserPreferences = UserPreferences(),
        role: UserRole,
        createdDate: Date = Date(),
        lastLoginDate: Date = Date()
    ) {
        self.id = id
        self.email = email
        self.profile = profile
        self.preferences = preferences
        self.role = role
        self.createdDate = createdDate
        self.lastLoginDate = lastLoginDate
        self.savedProperties = []
        self.viewingSessions = []
        self.searchHistory = []
    }

    // Computed Properties
    var fullName: String {
        "\(profile.firstName) \(profile.lastName)"
    }

    var isAgent: Bool {
        role == .agent
    }

    var memberSince: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: createdDate)
    }
}

// MARK: - Supporting Structures

struct UserProfile: Codable, Hashable {
    var firstName: String
    var lastName: String
    var phone: String?
    var agentLicense: String?
    var brokerage: String?
    var bio: String?
    var avatarURL: URL?

    init(
        firstName: String,
        lastName: String,
        phone: String? = nil,
        agentLicense: String? = nil,
        brokerage: String? = nil,
        bio: String? = nil,
        avatarURL: URL? = nil
    ) {
        self.firstName = firstName
        self.lastName = lastName
        self.phone = phone
        self.agentLicense = agentLicense
        self.brokerage = brokerage
        self.bio = bio
        self.avatarURL = avatarURL
    }
}

struct UserPreferences: Codable, Hashable {
    var searchCriteria: SearchCriteria
    var notificationSettings: NotificationSettings
    var measurementSystem: MeasurementSystem
    var preferredCurrency: String

    init(
        searchCriteria: SearchCriteria = SearchCriteria(),
        notificationSettings: NotificationSettings = NotificationSettings(),
        measurementSystem: MeasurementSystem = .imperial,
        preferredCurrency: String = "USD"
    ) {
        self.searchCriteria = searchCriteria
        self.notificationSettings = notificationSettings
        self.measurementSystem = measurementSystem
        self.preferredCurrency = preferredCurrency
    }
}

struct SearchCriteria: Codable, Hashable {
    var priceRange: PriceRange?
    var bedrooms: IntRange?
    var bathrooms: IntRange?
    var squareFeet: IntRange?
    var propertyTypes: [PropertyType]
    var locations: [String]

    init(
        priceRange: PriceRange? = nil,
        bedrooms: IntRange? = nil,
        bathrooms: IntRange? = nil,
        squareFeet: IntRange? = nil,
        propertyTypes: [PropertyType] = [],
        locations: [String] = []
    ) {
        self.priceRange = priceRange
        self.bedrooms = bedrooms
        self.bathrooms = bathrooms
        self.squareFeet = squareFeet
        self.propertyTypes = propertyTypes
        self.locations = locations
    }
}

struct PriceRange: Codable, Hashable {
    var min: Decimal
    var max: Decimal
}

struct IntRange: Codable, Hashable {
    var min: Int
    var max: Int
}

struct NotificationSettings: Codable, Hashable {
    var newListings: Bool
    var priceChanges: Bool
    var openHouses: Bool
    var savedSearchAlerts: Bool
    var emailNotifications: Bool
    var pushNotifications: Bool

    init(
        newListings: Bool = true,
        priceChanges: Bool = true,
        openHouses: Bool = true,
        savedSearchAlerts: Bool = true,
        emailNotifications: Bool = true,
        pushNotifications: Bool = true
    ) {
        self.newListings = newListings
        self.priceChanges = priceChanges
        self.openHouses = openHouses
        self.savedSearchAlerts = savedSearchAlerts
        self.emailNotifications = emailNotifications
        self.pushNotifications = pushNotifications
    }
}

// MARK: - Search Query

@Model
final class SearchQuery {
    @Attribute(.unique) var id: UUID
    var query: String
    var filters: SearchCriteria
    var timestamp: Date
    var resultCount: Int

    @Relationship(inverse: \User.searchHistory) var user: User?

    init(
        id: UUID = UUID(),
        query: String = "",
        filters: SearchCriteria = SearchCriteria(),
        timestamp: Date = Date(),
        resultCount: Int = 0
    ) {
        self.id = id
        self.query = query
        self.filters = filters
        self.timestamp = timestamp
        self.resultCount = resultCount
    }
}

// MARK: - Viewing Session

@Model
final class ViewingSession {
    @Attribute(.unique) var id: UUID
    var propertyID: UUID
    var userID: UUID
    var startTime: Date
    var endTime: Date?
    var duration: TimeInterval
    var roomsVisited: [String]
    var interactions: [InteractionEvent]
    var engagementScore: Double
    var completionPercentage: Double

    @Relationship(inverse: \Property.viewingSessions) var property: Property?
    @Relationship(inverse: \User.viewingSessions) var user: User?

    init(
        id: UUID = UUID(),
        propertyID: UUID,
        userID: UUID,
        startTime: Date = Date(),
        endTime: Date? = nil,
        duration: TimeInterval = 0,
        roomsVisited: [String] = [],
        interactions: [InteractionEvent] = [],
        engagementScore: Double = 0,
        completionPercentage: Double = 0
    ) {
        self.id = id
        self.propertyID = propertyID
        self.userID = userID
        self.startTime = startTime
        self.endTime = endTime
        self.duration = duration
        self.roomsVisited = roomsVisited
        self.interactions = interactions
        self.engagementScore = engagementScore
        self.completionPercentage = completionPercentage
    }

    func endSession() {
        endTime = Date()
        duration = endTime!.timeIntervalSince(startTime)
    }
}

struct InteractionEvent: Codable, Hashable {
    var timestamp: Date
    var type: InteractionType
    var target: String
    var duration: TimeInterval?
    var metadata: [String: String]?

    init(
        timestamp: Date = Date(),
        type: InteractionType,
        target: String,
        duration: TimeInterval? = nil,
        metadata: [String: String]? = nil
    ) {
        self.timestamp = timestamp
        self.type = type
        self.target = target
        self.duration = duration
        self.metadata = metadata
    }
}

// MARK: - Enumerations

enum UserRole: String, Codable {
    case buyer = "Buyer"
    case seller = "Seller"
    case agent = "Agent"
    case propertyManager = "Property Manager"
    case developer = "Developer"
}

enum MeasurementSystem: String, Codable {
    case imperial = "Imperial"  // feet, miles
    case metric = "Metric"      // meters, kilometers
}

enum InteractionType: String, Codable {
    case roomEnter = "Room Enter"
    case roomExit = "Room Exit"
    case measurement = "Measurement"
    case stagingToggle = "Staging Toggle"
    case photoView = "Photo View"
    case shareAction = "Share"
    case favoriteAction = "Favorite"
    case documentView = "Document View"
    case calculatorUse = "Calculator Use"
}

// MARK: - Extensions

extension User {
    static var preview: User {
        User(
            email: "john.smith@example.com",
            profile: UserProfile(
                firstName: "John",
                lastName: "Smith",
                phone: "(555) 123-4567",
                agentLicense: "CA-DRE-12345678",
                brokerage: "Premier Real Estate"
            ),
            role: .agent
        )
    }

    static var buyerPreview: User {
        User(
            email: "sarah.chen@example.com",
            profile: UserProfile(
                firstName: "Sarah",
                lastName: "Chen",
                phone: "(555) 987-6543"
            ),
            preferences: UserPreferences(
                searchCriteria: SearchCriteria(
                    priceRange: PriceRange(min: 500000, max: 1000000),
                    bedrooms: IntRange(min: 2, max: 4),
                    propertyTypes: [.singleFamily, .condo],
                    locations: ["San Francisco, CA", "Oakland, CA"]
                )
            ),
            role: .buyer
        )
    }
}
