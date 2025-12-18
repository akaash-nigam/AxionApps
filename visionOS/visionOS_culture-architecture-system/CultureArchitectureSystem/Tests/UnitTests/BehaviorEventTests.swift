//
//  BehaviorEventTests.swift
//  CultureArchitectureSystemTests
//
//  Created on 2025-01-20
//

import XCTest
@testable import CultureArchitectureSystem

final class BehaviorEventTests: XCTestCase {

    func testBehaviorEventCreation() {
        // Given
        let anonymousId = UUID()
        let teamId = UUID()
        let valueId = UUID()
        let eventType = BehaviorType.collaboration

        // When
        let event = BehaviorEvent(
            anonymousEmployeeId: anonymousId,
            teamId: teamId,
            eventType: eventType,
            valueId: valueId
        )

        // Then
        XCTAssertNotNil(event.id)
        XCTAssertEqual(event.anonymousEmployeeId, anonymousId)
        XCTAssertEqual(event.teamId, teamId)
        XCTAssertEqual(event.eventType, eventType)
        XCTAssertEqual(event.valueId, valueId)
        XCTAssertEqual(event.impact, 1.0)
        XCTAssertFalse(event.isSynced)
        XCTAssertNotNil(event.timestamp)
    }

    func testBehaviorTypes() {
        // Test all behavior types
        let types: [BehaviorType] = [
            .collaboration,
            .innovation,
            .recognition,
            .learning,
            .valuesDemonstration,
            .ritualParticipation,
            .feedback,
            .mentoring,
            .problemSolving,
            .customerFocus
        ]

        for type in types {
            // When
            let event = BehaviorEvent(
                anonymousEmployeeId: UUID(),
                teamId: UUID(),
                eventType: type,
                valueId: UUID()
            )

            // Then
            XCTAssertEqual(event.eventType, type)
        }
    }

    func testBehaviorEventWithCustomImpact() {
        // Given
        let customImpact = 2.5

        // When
        let event = BehaviorEvent(
            anonymousEmployeeId: UUID(),
            teamId: UUID(),
            eventType: .innovation,
            valueId: UUID(),
            impact: customImpact
        )

        // Then
        XCTAssertEqual(event.impact, customImpact)
    }

    func testBehaviorEventCodable() throws {
        // Given
        let event = BehaviorEvent(
            anonymousEmployeeId: UUID(),
            teamId: UUID(),
            eventType: .collaboration,
            valueId: UUID(),
            impact: 1.5
        )

        // When
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(event)

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decoded = try decoder.decode(BehaviorEvent.self, from: data)

        // Then
        XCTAssertEqual(decoded.eventType, event.eventType)
        XCTAssertEqual(decoded.impact, event.impact)
    }
}
