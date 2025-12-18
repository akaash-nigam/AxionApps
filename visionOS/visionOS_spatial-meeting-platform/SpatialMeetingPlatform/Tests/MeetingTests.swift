import XCTest
@testable import SpatialMeetingPlatform
import Foundation

final class MeetingTests: XCTestCase {

    // MARK: - Test Meeting Creation

    func testMeetingCreation() {
        // Given
        let title = "Test Meeting"
        let startTime = Date()
        let endTime = Date().addingTimeInterval(3600)
        let organizerId = UUID()

        // When
        let meeting = Meeting(
            title: title,
            startTime: startTime,
            endTime: endTime,
            organizerId: organizerId
        )

        // Then
        XCTAssertEqual(meeting.title, title)
        XCTAssertEqual(meeting.startTime, startTime)
        XCTAssertEqual(meeting.endTime, endTime)
        XCTAssertEqual(meeting.organizerId, organizerId)
        XCTAssertEqual(meeting.status, .scheduled)
        XCTAssertEqual(meeting.participants.count, 0)
        XCTAssertEqual(meeting.privacyLevel, .standard)
        XCTAssertEqual(meeting.maxParticipants, 50)
    }

    func testMeetingDuration() {
        // Given
        let startTime = Date()
        let duration: TimeInterval = 3600 // 1 hour
        let endTime = startTime.addingTimeInterval(duration)

        let meeting = Meeting(
            title: "Test",
            startTime: startTime,
            endTime: endTime,
            organizerId: UUID()
        )

        // When
        let calculatedDuration = meeting.duration

        // Then
        XCTAssertEqual(calculatedDuration, duration, accuracy: 0.01)
    }

    func testMeetingIsActive() {
        // Given
        let meeting = Meeting(
            title: "Test",
            startTime: Date(),
            endTime: Date().addingTimeInterval(3600),
            organizerId: UUID()
        )

        // When
        meeting.status = .live

        // Then
        XCTAssertTrue(meeting.isActive)

        // When
        meeting.status = .scheduled

        // Then
        XCTAssertFalse(meeting.isActive)
    }

    func testMeetingWithDescription() {
        // Given
        let description = "This is a test meeting"

        // When
        let meeting = Meeting(
            title: "Test",
            startTime: Date(),
            endTime: Date().addingTimeInterval(3600),
            organizerId: UUID(),
            description: description
        )

        // Then
        XCTAssertEqual(meeting.description, description)
    }

    func testMeetingWithCustomConfiguration() {
        // Given
        let privacyLevel: PrivacyLevel = .confidential
        let maxParticipants = 25
        let roomConfig: RoomConfiguration = .auditorium
        let layout: SpatialLayout = .theater

        // When
        let meeting = Meeting(
            title: "Test",
            startTime: Date(),
            endTime: Date().addingTimeInterval(3600),
            organizerId: UUID(),
            privacyLevel: privacyLevel,
            maxParticipants: maxParticipants,
            roomConfiguration: roomConfig,
            spatialLayout: layout
        )

        // Then
        XCTAssertEqual(meeting.privacyLevel, privacyLevel)
        XCTAssertEqual(meeting.maxParticipants, maxParticipants)
        XCTAssertEqual(meeting.roomConfiguration, roomConfig)
        XCTAssertEqual(meeting.spatialLayout, layout)
    }
}
