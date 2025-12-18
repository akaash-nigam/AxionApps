//
//  PropertyTests.swift
//  RealEstateSpatialTests
//
//  Unit tests for Property model
//

import Testing
import Foundation
@testable import RealEstateSpatial

@Suite("Property Model Tests")
struct PropertyTests {

    @Test("Property creation with valid data")
    func testPropertyCreation() {
        // Arrange
        let address = PropertyAddress(
            street: "123 Main Street",
            city: "San Francisco",
            state: "CA",
            zipCode: "94102",
            coordinates: GeographicCoordinate(latitude: 37.7749, longitude: -122.4194)
        )

        let pricing = PricingInfo(
            listPrice: 850_000,
            pricePerSqFt: 354,
            taxAssessment: 8_500,
            monthlyHOA: 250
        )

        let specs = PropertySpecs(
            bedrooms: 3,
            bathrooms: 2.0,
            squareFeet: 2400,
            yearBuilt: 2015,
            propertyType: .singleFamily,
            features: ["Hardwood floors", "Granite counters"]
        )

        // Act
        let property = Property(
            mlsNumber: "MLS123456",
            address: address,
            pricing: pricing,
            specifications: specs
        )

        // Assert
        #expect(property.mlsNumber == "MLS123456")
        #expect(property.address.city == "San Francisco")
        #expect(property.pricing.listPrice == 850_000)
        #expect(property.specifications.bedrooms == 3)
        #expect(property.specifications.propertyType == .singleFamily)
    }

    @Test("Display address formatting")
    func testDisplayAddress() {
        // Arrange
        let property = Property.preview

        // Act
        let displayAddress = property.displayAddress

        // Assert
        #expect(displayAddress.contains("123 Main Street"))
        #expect(displayAddress.contains("San Francisco"))
        #expect(displayAddress.contains("CA"))
    }

    @Test("Price per square foot calculation")
    func testPricePerSqFt() {
        // Arrange
        let property = Property(
            mlsNumber: "MLS001",
            address: PropertyAddress(
                street: "Test St",
                city: "Test City",
                state: "CA",
                zipCode: "12345",
                coordinates: GeographicCoordinate(latitude: 0, longitude: 0)
            ),
            pricing: PricingInfo(listPrice: 1_000_000),
            specifications: PropertySpecs(
                bedrooms: 3,
                bathrooms: 2,
                squareFeet: 2000,
                yearBuilt: 2020,
                propertyType: .singleFamily
            )
        )

        // Act
        let pricePerSqFt = property.pricePerSqFt

        // Assert
        #expect(pricePerSqFt == 500)
    }

    @Test("Property status check")
    func testPropertyStatus() {
        // Arrange
        var property = Property.preview

        // Act & Assert - Active
        property.metadata.status = .active
        #expect(property.isActive == true)

        // Act & Assert - Pending
        property.metadata.status = .pending
        #expect(property.isActive == false)

        // Act & Assert - Sold
        property.metadata.status = .sold
        #expect(property.isActive == false)
    }

    @Test("Property type enumeration")
    func testPropertyTypes() {
        #expect(PropertyType.singleFamily.rawValue == "Single Family")
        #expect(PropertyType.condo.rawValue == "Condo")
        #expect(PropertyType.townhouse.rawValue == "Townhouse")
        #expect(PropertyType.allCases.count == 6)
    }

    @Test("Geographic coordinate creation")
    func testGeographicCoordinate() {
        // Arrange
        let coordinate = GeographicCoordinate(
            latitude: 37.7749,
            longitude: -122.4194
        )

        // Assert
        #expect(coordinate.latitude == 37.7749)
        #expect(coordinate.longitude == -122.4194)
    }

    @Test("Price change tracking")
    func testPriceChange() {
        // Arrange
        let oldPrice: Decimal = 850_000
        let newPrice: Decimal = 825_000
        let changePercent = -2.94

        let priceChange = PriceChange(
            date: Date(),
            oldPrice: oldPrice,
            newPrice: newPrice,
            changePercent: changePercent
        )

        // Assert
        #expect(priceChange.oldPrice == 850_000)
        #expect(priceChange.newPrice == 825_000)
        #expect(abs(priceChange.changePercent - (-2.94)) < 0.01)
    }

    @Test("Property features and appliances")
    func testPropertyFeatures() {
        // Arrange
        let features = ["Hardwood floors", "Granite counters", "Central AC"]
        let appliances = ["Refrigerator", "Dishwasher", "Microwave"]

        let specs = PropertySpecs(
            bedrooms: 3,
            bathrooms: 2,
            squareFeet: 2000,
            yearBuilt: 2020,
            propertyType: .singleFamily,
            features: features,
            appliances: appliances
        )

        // Assert
        #expect(specs.features.count == 3)
        #expect(specs.appliances.count == 3)
        #expect(specs.features.contains("Hardwood floors"))
        #expect(specs.appliances.contains("Refrigerator"))
    }
}

@Suite("Room Model Tests")
struct RoomTests {

    @Test("Room creation with dimensions")
    func testRoomCreation() {
        // Arrange & Act
        let room = Room(
            name: "Master Bedroom",
            type: .masterBedroom,
            dimensions: RoomDimensions(length: 4.5, width: 3.6, height: 2.7),
            features: ["Carpet flooring", "Walk-in closet"]
        )

        // Assert
        #expect(room.name == "Master Bedroom")
        #expect(room.type == .masterBedroom)
        #expect(room.dimensions.length == 4.5)
        #expect(room.features.count == 2)
    }

    @Test("Room dimensions square feet calculation")
    func testSquareFeetCalculation() {
        // Arrange
        let dimensions = RoomDimensions(length: 5.0, width: 4.0, height: 2.7)

        // Act
        let squareFeet = dimensions.squareFeet

        // Assert
        // 5m × 4m = 20m² × 10.764 = 215.28 sqft
        #expect(abs(squareFeet - 215.28) < 0.1)
    }

    @Test("Room dimensions in feet conversion")
    func testDimensionsInFeet() {
        // Arrange
        let dimensions = RoomDimensions(length: 3.0, width: 3.0, height: 2.7)

        // Assert
        // 3m ≈ 9.84 ft
        #expect(abs(dimensions.lengthInFeet - 9.84) < 0.1)
        #expect(abs(dimensions.widthInFeet - 9.84) < 0.1)
        #expect(abs(dimensions.heightInFeet - 8.86) < 0.1)
    }

    @Test("Room volume calculation")
    func testRoomVolume() {
        // Arrange
        let room = Room(
            name: "Test Room",
            type: .livingRoom,
            dimensions: RoomDimensions(length: 5.0, width: 4.0, height: 3.0)
        )

        // Act
        let volume = room.volume

        // Assert
        #expect(volume == 60.0) // 5 × 4 × 3 = 60 cubic meters
    }

    @Test("Room type icons")
    func testRoomTypeIcons() {
        #expect(RoomType.livingRoom.icon == "sofa.fill")
        #expect(RoomType.bedroom.icon == "bed.double.fill")
        #expect(RoomType.kitchen.icon == "fork.knife")
        #expect(RoomType.bathroom.icon == "shower.fill")
    }

    @Test("Room display name")
    func testRoomDisplayName() {
        // Arrange
        let namedRoom = Room(
            name: "Master Suite",
            type: .masterBedroom,
            dimensions: RoomDimensions(length: 4, width: 3, height: 2.7)
        )

        let unnamedRoom = Room(
            name: "",
            type: .kitchen,
            dimensions: RoomDimensions(length: 3, width: 2.5, height: 2.7)
        )

        // Assert
        #expect(namedRoom.displayName == "Master Suite")
        #expect(unnamedRoom.displayName == "Kitchen")
    }

    @Test("Sample rooms generation")
    func testSampleRoomsGeneration() {
        // Act
        let rooms = Room.createSampleRooms()

        // Assert
        #expect(rooms.count == 5)
        #expect(rooms.contains(where: { $0.type == .livingRoom }))
        #expect(rooms.contains(where: { $0.type == .kitchen }))
        #expect(rooms.contains(where: { $0.type == .masterBedroom }))
    }
}

@Suite("User Model Tests")
struct UserTests {

    @Test("User creation")
    func testUserCreation() {
        // Arrange
        let profile = UserProfile(
            firstName: "John",
            lastName: "Smith",
            phone: "(555) 123-4567"
        )

        // Act
        let user = User(
            email: "john.smith@example.com",
            profile: profile,
            role: .buyer
        )

        // Assert
        #expect(user.email == "john.smith@example.com")
        #expect(user.profile.firstName == "John")
        #expect(user.role == .buyer)
        #expect(user.isAgent == false)
    }

    @Test("Agent user creation")
    func testAgentCreation() {
        // Arrange
        let profile = UserProfile(
            firstName: "Jane",
            lastName: "Doe",
            agentLicense: "CA-DRE-12345",
            brokerage: "Premier Realty"
        )

        // Act
        let agent = User(
            email: "jane.doe@premierrealty.com",
            profile: profile,
            role: .agent
        )

        // Assert
        #expect(agent.isAgent == true)
        #expect(agent.profile.agentLicense == "CA-DRE-12345")
        #expect(agent.profile.brokerage == "Premier Realty")
    }

    @Test("User full name")
    func testUserFullName() {
        // Arrange
        let user = User.preview

        // Act
        let fullName = user.fullName

        // Assert
        #expect(fullName.contains("John"))
        #expect(fullName.contains("Smith"))
    }

    @Test("User preferences")
    func testUserPreferences() {
        // Arrange
        let searchCriteria = SearchCriteria(
            priceRange: PriceRange(min: 500_000, max: 1_000_000),
            bedrooms: IntRange(min: 2, max: 4),
            propertyTypes: [.singleFamily, .condo]
        )

        let preferences = UserPreferences(
            searchCriteria: searchCriteria,
            measurementSystem: .imperial
        )

        // Assert
        #expect(preferences.searchCriteria.priceRange?.min == 500_000)
        #expect(preferences.searchCriteria.bedrooms?.min == 2)
        #expect(preferences.measurementSystem == .imperial)
        #expect(preferences.propertyTypes.count == 2)
    }

    @Test("Notification settings")
    func testNotificationSettings() {
        // Arrange
        let settings = NotificationSettings(
            newListings: true,
            priceChanges: false,
            pushNotifications: true
        )

        // Assert
        #expect(settings.newListings == true)
        #expect(settings.priceChanges == false)
        #expect(settings.pushNotifications == true)
    }
}

@Suite("ViewingSession Model Tests")
struct ViewingSessionTests {

    @Test("Viewing session creation")
    func testViewingSessionCreation() {
        // Arrange
        let propertyID = UUID()
        let userID = UUID()

        // Act
        let session = ViewingSession(
            propertyID: propertyID,
            userID: userID,
            startTime: Date()
        )

        // Assert
        #expect(session.propertyID == propertyID)
        #expect(session.userID == userID)
        #expect(session.duration == 0)
        #expect(session.roomsVisited.isEmpty)
    }

    @Test("End viewing session")
    func testEndSession() {
        // Arrange
        let session = ViewingSession(
            propertyID: UUID(),
            userID: UUID(),
            startTime: Date()
        )

        // Act
        Thread.sleep(forTimeInterval: 0.1) // Sleep for 100ms
        session.endSession()

        // Assert
        #expect(session.endTime != nil)
        #expect(session.duration > 0)
        #expect(session.duration >= 0.1)
    }

    @Test("Interaction event tracking")
    func testInteractionEvents() {
        // Arrange
        let event1 = InteractionEvent(
            type: .roomEnter,
            target: "Living Room"
        )

        let event2 = InteractionEvent(
            type: .measurement,
            target: "Wall",
            duration: 5.0
        )

        // Assert
        #expect(event1.type == .roomEnter)
        #expect(event1.target == "Living Room")
        #expect(event2.type == .measurement)
        #expect(event2.duration == 5.0)
    }
}
