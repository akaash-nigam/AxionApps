//
//  AnalyticsServiceTests.swift
//  CultureArchitectureSystemTests
//
//  Created on 2025-01-20
//

import XCTest
@testable import CultureArchitectureSystem

final class AnalyticsServiceTests: XCTestCase {

    var sut: AnalyticsService!
    var mockAPIClient: MockAPIClient!

    override func setUp() {
        super.setUp()
        let mockAuthManager = MockAuthenticationManager()
        mockAPIClient = MockAPIClient(authManager: mockAuthManager)
        sut = AnalyticsService(apiClient: mockAPIClient)
    }

    override func tearDown() {
        sut = nil
        mockAPIClient = nil
        super.tearDown()
    }

    func testCalculateEngagementScore() async throws {
        // When
        let score = try await sut.calculateEngagementScore()

        // Then
        XCTAssertGreaterThanOrEqual(score, 0)
        XCTAssertLessThanOrEqual(score, 100)
    }

    func testCalculateEngagementTrend() async throws {
        // Given
        let days = 30

        // When
        let dataPoints = try await sut.calculateEngagementTrend(days: days)

        // Then
        XCTAssertEqual(dataPoints.count, days)

        // Verify all scores are valid
        for point in dataPoints {
            XCTAssertGreaterThanOrEqual(point.score, 0)
            XCTAssertLessThanOrEqual(point.score, 100)
        }

        // Verify dates are in order (oldest to newest)
        if dataPoints.count > 1 {
            for i in 0..<dataPoints.count-1 {
                XCTAssertLessThanOrEqual(
                    dataPoints[i].date,
                    dataPoints[i+1].date
                )
            }
        }
    }

    func testCalculateEngagementTrendDifferentPeriods() async throws {
        // Test different time periods
        let periods = [7, 30, 90]

        for days in periods {
            // When
            let dataPoints = try await sut.calculateEngagementTrend(days: days)

            // Then
            XCTAssertEqual(
                dataPoints.count,
                days,
                "Should return \(days) data points for \(days)-day period"
            )
        }
    }

    func testCalculateValueAlignment() async throws {
        // Given
        let valueId = UUID()

        // When
        let alignment = try await sut.calculateValueAlignment(for: valueId)

        // Then
        XCTAssertGreaterThanOrEqual(alignment, 0)
        XCTAssertLessThanOrEqual(alignment, 100)
    }

    func testAggregateBehaviorData() async throws {
        // Given
        let teamId = UUID()
        let timeRange = DateInterval(
            start: Date().addingTimeInterval(-30*24*3600),
            end: Date()
        )

        // When
        let summary = try await sut.aggregateBehaviorData(
            teamId: teamId,
            timeRange: timeRange
        )

        // Then
        XCTAssertEqual(summary.teamId, teamId)
        XCTAssertGreaterThan(summary.totalEvents, 0)
        XCTAssertGreaterThan(summary.averageImpact, 0)
        XCTAssertLessThanOrEqual(summary.averageImpact, 1.0)
    }
}
