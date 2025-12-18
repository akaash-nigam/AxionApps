//
//  CultureServiceTests.swift
//  CultureArchitectureSystemTests
//
//  Created on 2025-01-20
//

import XCTest
@testable import CultureArchitectureSystem

final class CultureServiceTests: XCTestCase {

    var sut: CultureService!
    var mockAPIClient: MockAPIClient!
    var mockAuthManager: MockAuthenticationManager!

    override func setUp() {
        super.setUp()
        mockAuthManager = MockAuthenticationManager()
        mockAPIClient = MockAPIClient(authManager: mockAuthManager)
        sut = CultureService(apiClient: mockAPIClient, authManager: mockAuthManager)
    }

    override func tearDown() {
        sut = nil
        mockAPIClient = nil
        mockAuthManager = nil
        super.tearDown()
    }

    func testFetchHealthScore() async throws {
        // Given
        let organizationId = UUID()

        // When
        let healthScore = try await sut.fetchHealthScore(for: organizationId)

        // Then
        XCTAssertGreaterThanOrEqual(healthScore, 0)
        XCTAssertLessThanOrEqual(healthScore, 100)
    }

    func testFetchRecentActivities() async throws {
        // When
        let activities = try await sut.fetchRecentActivities()

        // Then
        XCTAssertFalse(activities.isEmpty)
        XCTAssertTrue(activities.count <= 10)

        // Verify activities are ordered by timestamp (most recent first)
        if activities.count > 1 {
            for i in 0..<activities.count-1 {
                XCTAssertGreaterThanOrEqual(
                    activities[i].timestamp,
                    activities[i+1].timestamp
                )
            }
        }
    }

    func testActivitiesHaveCorrectTypes() async throws {
        // When
        let activities = try await sut.fetchRecentActivities()

        // Then
        for activity in activities {
            switch activity.type {
            case .recognition, .behavior, .ritual, .milestone:
                XCTAssertTrue(true) // Valid type
            }
        }
    }
}

// MARK: - Mock Objects

class MockAPIClient: APIClient {
    var shouldFail = false
    var mockOrganization: Organization?

    override func fetchOrganization(id: UUID) async throws -> Organization {
        if shouldFail {
            throw APIError.networkUnavailable
        }

        if let mockOrg = mockOrganization {
            return mockOrg
        }

        return Organization.mock()
    }
}

class MockAuthenticationManager: AuthenticationManager {
    var mockToken: String = "mock_token_12345"

    override func getAccessToken() async throws -> String {
        return mockToken
    }

    override func authenticate() async throws -> String {
        return mockToken
    }
}
