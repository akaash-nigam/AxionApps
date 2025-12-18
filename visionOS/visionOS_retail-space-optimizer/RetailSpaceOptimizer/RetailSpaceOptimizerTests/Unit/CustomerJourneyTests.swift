import XCTest
@testable import RetailSpaceOptimizer

/// Unit tests for CustomerJourney data model
final class CustomerJourneyTests: XCTestCase {

    // MARK: - Initialization Tests

    func testCustomerJourneyInitialization() {
        // Given
        let persona = CustomerPersona(
            demographicProfile: "Adult 25-35",
            shoppingMission: .planned,
            timeConstraint: .moderate,
            priceSensitivity: 0.5,
            brandPreferences: ["Brand A"]
        )

        // When
        let journey = CustomerJourney(
            customerPersona: persona,
            entryPoint: SIMD3(10, 0, 0),
            exitPoint: SIMD3(10, 0, 30),
            totalTime: 480,
            conversionValue: 99.99
        )

        // Then
        XCTAssertNotNil(journey.id)
        XCTAssertEqual(journey.totalTime, 480)
        XCTAssertEqual(journey.conversionValue, 99.99)
        XCTAssertEqual(journey.customerPersona.shoppingMission, .planned)
    }

    // MARK: - CustomerPersona Tests

    func testCustomerPersonaInitialization() {
        // When
        let persona = CustomerPersona(
            demographicProfile: "Senior 65+",
            shoppingMission: .browsing,
            timeConstraint: .none,
            priceSensitivity: 0.3,
            brandPreferences: ["Premium Brand", "Luxury Brand"]
        )

        // Then
        XCTAssertEqual(persona.demographicProfile, "Senior 65+")
        XCTAssertEqual(persona.shoppingMission, .browsing)
        XCTAssertEqual(persona.timeConstraint, .none)
        XCTAssertEqual(persona.priceSensitivity, 0.3)
        XCTAssertEqual(persona.brandPreferences.count, 2)
    }

    func testShoppingMissionTypes() {
        // Given
        let missions: [CustomerPersona.ShoppingMission] = [
            .browsing, .quickShop, .planned, .recreational
        ]

        // Then
        XCTAssertEqual(missions.count, 4)
        XCTAssertEqual(CustomerPersona.ShoppingMission.browsing.rawValue, "Browsing")
        XCTAssertEqual(CustomerPersona.ShoppingMission.planned.rawValue, "Planned Purchase")
    }

    func testTimeConstraintTypes() {
        // Given
        let constraints: [CustomerPersona.TimeConstraint] = [.none, .moderate, .severe]

        // Then
        XCTAssertEqual(constraints.count, 3)
        XCTAssertEqual(CustomerPersona.TimeConstraint.severe.rawValue, "Time Limited")
    }

    // MARK: - PathPoint Tests

    func testPathPointCreation() {
        // When
        let pathPoint = PathPoint(
            position: SIMD3(5, 0, 10),
            timestamp: 120,
            activity: .browsing
        )

        // Then
        XCTAssertNotNil(pathPoint.id)
        XCTAssertEqual(pathPoint.position.x, 5)
        XCTAssertEqual(pathPoint.timestamp, 120)
        XCTAssertEqual(pathPoint.activity, .browsing)
    }

    func testCustomerActivityTypes() {
        // Given
        let activities: [PathPoint.CustomerActivity] = [
            .walking, .browsing, .examining, .deciding, .purchasing, .waiting
        ]

        // Then
        XCTAssertEqual(activities.count, 6)
        XCTAssertEqual(PathPoint.CustomerActivity.purchasing.rawValue, "Purchasing")
    }

    // MARK: - DwellZone Tests

    func testDwellZoneCreation() {
        // When
        let dwellZone = DwellZone(
            position: SIMD3(8, 0, 12),
            duration: 180,
            engagement: 0.85
        )

        // Then
        XCTAssertNotNil(dwellZone.id)
        XCTAssertEqual(dwellZone.duration, 180)
        XCTAssertEqual(dwellZone.engagement, 0.85)
    }

    func testDwellZoneEngagementRange() {
        // Given
        let lowEngagement = DwellZone(position: SIMD3(0, 0, 0), duration: 30, engagement: 0.2)
        let highEngagement = DwellZone(position: SIMD3(0, 0, 0), duration: 300, engagement: 0.95)

        // Then
        XCTAssertGreaterThanOrEqual(lowEngagement.engagement, 0.0)
        XCTAssertLessThanOrEqual(lowEngagement.engagement, 1.0)
        XCTAssertGreaterThanOrEqual(highEngagement.engagement, 0.0)
        XCTAssertLessThanOrEqual(highEngagement.engagement, 1.0)
    }

    // MARK: - PurchasePoint Tests

    func testPurchasePointCreation() {
        // When
        let purchasePoint = PurchasePoint(
            position: SIMD3(15, 0, 20),
            timestamp: 420,
            productSKU: "PRD-001",
            value: 49.99
        )

        // Then
        XCTAssertNotNil(purchasePoint.id)
        XCTAssertEqual(purchasePoint.productSKU, "PRD-001")
        XCTAssertEqual(purchasePoint.value, 49.99)
        XCTAssertEqual(purchasePoint.timestamp, 420)
    }

    // MARK: - Mock Data Tests

    func testMockCustomerJourneyCreation() {
        // When
        let journey = CustomerJourney.mock()

        // Then
        XCTAssertNotNil(journey.id)
        XCTAssertEqual(journey.customerPersona.shoppingMission, .planned)
        XCTAssertGreaterThan(journey.pathPoints.count, 0)
        XCTAssertGreaterThan(journey.dwellZones.count, 0)
        XCTAssertGreaterThan(journey.purchasePoints.count, 0)
    }

    func testMockJourneyArrayCreation() {
        // When
        let journeys = CustomerJourney.mockArray(count: 100)

        // Then
        XCTAssertEqual(journeys.count, 100)

        // Verify unique IDs
        let uniqueIds = Set(journeys.map { $0.id })
        XCTAssertEqual(uniqueIds.count, 100)

        // Verify different missions
        let missions = Set(journeys.map { $0.customerPersona.shoppingMission })
        XCTAssertGreaterThan(missions.count, 1)
    }

    // MARK: - Codable Tests

    func testCustomerPersonaCodable() throws {
        // Given
        let persona = CustomerPersona(
            demographicProfile: "Test Profile",
            shoppingMission: .quickShop,
            timeConstraint: .severe,
            priceSensitivity: 0.7,
            brandPreferences: ["Brand1", "Brand2"]
        )

        // When
        let encoder = JSONEncoder()
        let data = try encoder.encode(persona)
        let decoder = JSONDecoder()
        let decodedPersona = try decoder.decode(CustomerPersona.self, from: data)

        // Then
        XCTAssertEqual(decodedPersona.demographicProfile, persona.demographicProfile)
        XCTAssertEqual(decodedPersona.shoppingMission, persona.shoppingMission)
        XCTAssertEqual(decodedPersona.priceSensitivity, persona.priceSensitivity)
    }

    // MARK: - Journey Analysis Tests

    func testConversionJourney() {
        // Given
        let journey = CustomerJourney.mock()

        // Then - Journey with purchase should have conversion value
        if journey.conversionValue > 0 {
            XCTAssertGreaterThan(journey.purchasePoints.count, 0)
        }
    }

    func testNonConversionJourney() {
        // Given
        let persona = CustomerPersona(
            demographicProfile: "Browsing Shopper",
            shoppingMission: .browsing,
            timeConstraint: .none,
            priceSensitivity: 0.9,
            brandPreferences: []
        )

        let journey = CustomerJourney(
            customerPersona: persona,
            entryPoint: SIMD3(10, 0, 0),
            exitPoint: SIMD3(10, 0, 30),
            totalTime: 300,
            conversionValue: 0
        )

        // Then
        XCTAssertEqual(journey.conversionValue, 0)
    }

    // MARK: - Performance Tests

    func testJourneyArrayCreationPerformance() {
        measure {
            let _ = CustomerJourney.mockArray(count: 1000)
        }
    }
}
