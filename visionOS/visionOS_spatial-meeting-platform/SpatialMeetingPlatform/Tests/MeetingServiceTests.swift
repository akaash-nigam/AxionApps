import XCTest
@testable import SpatialMeetingPlatform
import Foundation

final class MeetingServiceTests: XCTestCase {
    var sut: MeetingService!

    override func setUp() {
        super.setUp()
        sut = MeetingService()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Meeting Lifecycle Tests

    func testInitialState() {
        // Then
        XCTAssertNil(sut.currentMeeting)
        XCTAssertEqual(sut.participants.count, 0)
        XCTAssertEqual(sut.connectionState, .disconnected)
    }

    func testCreateMeeting() async throws {
        // Given
        let meeting = Meeting(
            title: "Test Meeting",
            startTime: Date(),
            endTime: Date().addingTimeInterval(3600),
            organizerId: UUID()
        )

        // When
        let created = try await sut.createMeeting(meeting)

        // Then
        XCTAssertEqual(created.title, meeting.title)
        XCTAssertEqual(created.organizerId, meeting.organizerId)
    }

    func testJoinMeeting() async throws {
        // Given
        let meetingId = UUID()
        let participant = Participant(
            userId: UUID(),
            displayName: "Test User",
            email: "test@example.com"
        )

        // When
        try await sut.joinMeeting(id: meetingId, as: participant)

        // Then
        XCTAssertNotNil(sut.currentMeeting)
        XCTAssertEqual(sut.connectionState, .connected)
        XCTAssertTrue(sut.participants.contains(where: { $0.id == participant.id }))
    }

    func testLeaveMeeting() async throws {
        // Given
        let meetingId = UUID()
        let participant = Participant(
            userId: UUID(),
            displayName: "Test User",
            email: "test@example.com"
        )

        try await sut.joinMeeting(id: meetingId, as: participant)

        // When
        try await sut.leaveMeeting()

        // Then
        XCTAssertNil(sut.currentMeeting)
        XCTAssertEqual(sut.participants.count, 0)
        XCTAssertEqual(sut.connectionState, .disconnected)
    }

    // MARK: - Participant Management Tests

    func testAddParticipant() async throws {
        // Given
        let meetingId = UUID()
        let host = Participant(
            userId: UUID(),
            displayName: "Host",
            email: "host@example.com"
        )

        try await sut.joinMeeting(id: meetingId, as: host)

        let newParticipant = Participant(
            userId: UUID(),
            displayName: "New User",
            email: "new@example.com"
        )

        // When
        try await sut.addParticipant(newParticipant)

        // Then
        XCTAssertEqual(sut.participants.count, 2)
        XCTAssertTrue(sut.participants.contains(where: { $0.id == newParticipant.id }))
    }

    func testRaiseHand() async throws {
        // Given
        let meetingId = UUID()
        let participant = Participant(
            userId: UUID(),
            displayName: "Test User",
            email: "test@example.com"
        )

        try await sut.joinMeeting(id: meetingId, as: participant)

        // When
        try await sut.raiseHand(participant.id)

        // Then
        let updated = sut.participants.first { $0.id == participant.id }
        XCTAssertTrue(updated?.handRaised ?? false)

        // When (toggle again)
        try await sut.raiseHand(participant.id)

        // Then
        let updatedAgain = sut.participants.first { $0.id == participant.id }
        XCTAssertFalse(updatedAgain?.handRaised ?? true)
    }

    func testToggleAudio() async throws {
        // Given
        let meetingId = UUID()
        let participant = Participant(
            userId: UUID(),
            displayName: "Test User",
            email: "test@example.com"
        )

        try await sut.joinMeeting(id: meetingId, as: participant)

        // Initial state
        XCTAssertTrue(participant.audioEnabled)

        // When
        try await sut.toggleAudio(participant.id)

        // Then
        let updated = sut.participants.first { $0.id == participant.id }
        XCTAssertFalse(updated?.audioEnabled ?? true)
    }

    func testUpdateParticipantPosition() async throws {
        // Given
        let meetingId = UUID()
        let participant = Participant(
            userId: UUID(),
            displayName: "Test User",
            email: "test@example.com"
        )

        try await sut.joinMeeting(id: meetingId, as: participant)

        let newPosition = SpatialPosition(x: 1.0, y: 0.5, z: -2.0)

        // When
        try await sut.updateParticipantPosition(participant.id, position: newPosition)

        // Then
        let updated = sut.participants.first { $0.id == participant.id }
        XCTAssertEqual(updated?.spatialPosition?.x, 1.0)
        XCTAssertEqual(updated?.spatialPosition?.y, 0.5)
        XCTAssertEqual(updated?.spatialPosition?.z, -2.0)
    }

    func testGetUpcomingMeetings() async throws {
        // When
        let meetings = try await sut.upcomingMeetings()

        // Then
        XCTAssertGreaterThan(meetings.count, 0)
        XCTAssertTrue(meetings.allSatisfy { $0.status == .scheduled })
    }
}
