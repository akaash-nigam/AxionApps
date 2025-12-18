import XCTest
@testable import SpatialMeetingPlatform
import Foundation

final class ParticipantTests: XCTestCase {

    func testParticipantCreation() {
        // Given
        let userId = UUID()
        let displayName = "John Doe"
        let email = "john@example.com"

        // When
        let participant = Participant(
            userId: userId,
            displayName: displayName,
            email: email
        )

        // Then
        XCTAssertEqual(participant.userId, userId)
        XCTAssertEqual(participant.displayName, displayName)
        XCTAssertEqual(participant.email, email)
        XCTAssertEqual(participant.role, .attendee)
        XCTAssertEqual(participant.status, .invited)
        XCTAssertTrue(participant.audioEnabled)
        XCTAssertFalse(participant.handRaised)
        XCTAssertEqual(participant.speakingTime, 0)
    }

    func testParticipantIsActive() {
        // Given
        let participant = Participant(
            userId: UUID(),
            displayName: "Test User",
            email: "test@example.com"
        )

        // When
        participant.status = .joined

        // Then
        XCTAssertTrue(participant.isActive)

        // When
        participant.status = .left

        // Then
        XCTAssertFalse(participant.isActive)
    }

    func testParticipantRoles() {
        // Given
        let participant = Participant(
            userId: UUID(),
            displayName: "Test User",
            email: "test@example.com",
            role: .host
        )

        // Then
        XCTAssertEqual(participant.role, .host)

        // When
        participant.role = .presenter

        // Then
        XCTAssertEqual(participant.role, .presenter)
    }

    func testParticipantSpatialPosition() {
        // Given
        let participant = Participant(
            userId: UUID(),
            displayName: "Test User",
            email: "test@example.com"
        )

        let position = SpatialPosition(x: 1.0, y: 0.5, z: -2.0)

        // When
        participant.spatialPosition = position

        // Then
        XCTAssertNotNil(participant.spatialPosition)
        XCTAssertEqual(participant.spatialPosition?.x, 1.0)
        XCTAssertEqual(participant.spatialPosition?.y, 0.5)
        XCTAssertEqual(participant.spatialPosition?.z, -2.0)
    }

    func testParticipantPermissions() {
        // Given
        let participant = Participant(
            userId: UUID(),
            displayName: "Test User",
            email: "test@example.com"
        )

        // Then (defaults)
        XCTAssertTrue(participant.canShare)
        XCTAssertFalse(participant.canRecord)
        XCTAssertFalse(participant.canInvite)

        // When
        participant.canRecord = true
        participant.canInvite = true

        // Then
        XCTAssertTrue(participant.canRecord)
        XCTAssertTrue(participant.canInvite)
    }
}
