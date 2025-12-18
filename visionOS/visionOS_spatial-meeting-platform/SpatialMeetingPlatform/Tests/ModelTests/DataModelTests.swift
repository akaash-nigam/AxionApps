//
//  DataModelTests.swift
//  SpatialMeetingPlatformTests
//
//  Tests for data models
//

import Testing
import Foundation
@testable import SpatialMeetingPlatform

@Suite("Data Model Tests")
struct DataModelTests {

    // MARK: - Meeting Model Tests

    @Test("Meeting model initializes correctly")
    func testMeetingInitialization() {
        let user = TestDataFactory.createMockUser()
        let meeting = TestDataFactory.createMockMeeting(organizer: user)

        #expect(meeting.title == "Test Meeting")
        #expect(meeting.status == .scheduled)
        #expect(meeting.meetingType == .boardroom)
        #expect(meeting.organizer.id == user.id)
        #expect(meeting.participants.isEmpty)
    }

    @Test("Meeting can add participants")
    func testMeetingAddParticipants() {
        let meeting = TestDataFactory.createMockMeeting()
        let participant1 = TestDataFactory.createMockParticipant()
        let participant2 = TestDataFactory.createMockParticipant()

        meeting.participants = [participant1, participant2]

        #expect(meeting.participants.count == 2)
        #expect(meeting.participants.contains { $0.id == participant1.id })
        #expect(meeting.participants.contains { $0.id == participant2.id })
    }

    @Test("Meeting status enum values")
    func testMeetingStatusEnum() {
        #expect(MeetingStatus.scheduled.rawValue == "scheduled")
        #expect(MeetingStatus.inProgress.rawValue == "inProgress")
        #expect(MeetingStatus.completed.rawValue == "completed")
        #expect(MeetingStatus.cancelled.rawValue == "cancelled")
    }

    @Test("Meeting type has display names and icons")
    func testMeetingTypeProperties() {
        #expect(MeetingType.boardroom.displayName == "Boardroom")
        #expect(MeetingType.innovationLab.displayName == "Innovation Lab")
        #expect(MeetingType.auditorium.displayName == "Auditorium")

        #expect(!MeetingType.boardroom.icon.isEmpty)
        #expect(!MeetingType.innovationLab.icon.isEmpty)
    }

    // MARK: - User Model Tests

    @Test("User model initializes correctly")
    func testUserInitialization() {
        let user = TestDataFactory.createMockUser(
            email: "john@example.com",
            displayName: "John Doe"
        )

        #expect(user.email == "john@example.com")
        #expect(user.displayName == "John Doe")
        #expect(user.organization == "Test Corp")
    }

    @Test("User preferences encode and decode")
    func testUserPreferencesCodable() throws {
        let user = TestDataFactory.createMockUser()

        let preferences = UserPreferences(
            defaultEnvironment: .innovationLab,
            spatialAudioEnabled: true,
            handTrackingEnabled: true,
            eyeTrackingEnabled: false
        )

        user.preferences = preferences

        let retrieved = user.preferences
        #expect(retrieved.defaultEnvironment == .innovationLab)
        #expect(retrieved.spatialAudioEnabled == true)
        #expect(retrieved.handTrackingEnabled == true)
        #expect(retrieved.eyeTrackingEnabled == false)
    }

    // MARK: - Participant Model Tests

    @Test("Participant model initializes correctly")
    func testParticipantInitialization() {
        let user = TestDataFactory.createMockUser()
        let participant = TestDataFactory.createMockParticipant(
            user: user,
            role: .presenter
        )

        #expect(participant.user.id == user.id)
        #expect(participant.role == .presenter)
        #expect(participant.audioEnabled == true)
        #expect(participant.videoEnabled == true)
        #expect(participant.presenceState == .active)
    }

    @Test("Participant spatial position encodes and decodes")
    func testParticipantSpatialPosition() {
        let participant = TestDataFactory.createMockParticipant()

        let position = SpatialPosition(
            x: 2.0,
            y: 1.5,
            z: -1.0,
            scale: 1.0
        )

        participant.spatialPosition = position

        let retrieved = participant.spatialPosition
        #expect(retrieved?.x == 2.0)
        #expect(retrieved?.y == 1.5)
        #expect(retrieved?.z == -1.0)
    }

    @Test("Participant role enum values")
    func testParticipantRoleEnum() {
        #expect(ParticipantRole.organizer.rawValue == "organizer")
        #expect(ParticipantRole.presenter.rawValue == "presenter")
        #expect(ParticipantRole.participant.rawValue == "participant")
        #expect(ParticipantRole.observer.rawValue == "observer")
    }

    // MARK: - Shared Content Model Tests

    @Test("Shared content initializes correctly")
    func testSharedContentInitialization() {
        let user = TestDataFactory.createMockUser()
        let content = TestDataFactory.createMockSharedContent(
            type: .presentation,
            sharedBy: user
        )

        #expect(content.type == .presentation)
        #expect(content.title == "Test Document")
        #expect(content.sharedBy.id == user.id)
    }

    @Test("Shared content spatial transform")
    func testSharedContentSpatialTransform() {
        let content = TestDataFactory.createMockSharedContent()

        let transform = SpatialTransform(
            position: SIMD3(0, 1.5, -2),
            rotation: simd_quatf(angle: 0, axis: SIMD3(0, 1, 0)),
            scale: SIMD3(1, 1, 1)
        )

        content.spatialTransform = transform

        let retrieved = content.spatialTransform
        #expect(retrieved.position.y == 1.5)
        #expect(retrieved.position.z == -2.0)
    }

    // MARK: - Transcript Model Tests

    @Test("Transcript model initializes correctly")
    func testTranscriptInitialization() {
        let transcript = TestDataFactory.createMockTranscript(segmentCount: 3)

        #expect(transcript.segments.count == 3)
        #expect(transcript.segments[0].text == "Test segment 0")
        #expect(transcript.segments[1].timestamp == 10.0)
    }

    @Test("Transcript segment is identifiable")
    func testTranscriptSegmentIdentifiable() {
        let segment = TranscriptSegment(
            id: UUID(),
            speakerID: UUID(),
            text: "Hello world",
            timestamp: 0,
            confidence: 0.98
        )

        #expect(segment.text == "Hello world")
        #expect(segment.confidence == 0.98)
        // ID exists (Identifiable protocol)
        let _ = segment.id
    }

    // MARK: - Action Item Model Tests

    @Test("Action item initializes correctly")
    func testActionItemInitialization() {
        let user = TestDataFactory.createMockUser()
        let actionItem = ActionItem(
            id: UUID(),
            description: "Follow up with client",
            assignedTo: user,
            dueDate: Date().addingTimeInterval(86400),
            status: .pending
        )

        #expect(actionItem.itemDescription == "Follow up with client")
        #expect(actionItem.assignedTo?.id == user.id)
        #expect(actionItem.status == .pending)
    }

    @Test("Action item status transitions")
    func testActionItemStatusTransitions() {
        let actionItem = ActionItem(
            id: UUID(),
            description: "Test task",
            status: .pending
        )

        #expect(actionItem.status == .pending)

        actionItem.status = .inProgress
        #expect(actionItem.status == .inProgress)

        actionItem.status = .completed
        #expect(actionItem.status == .completed)
    }

    // MARK: - Analytics Model Tests

    @Test("Meeting analytics initializes correctly")
    func testMeetingAnalyticsInitialization() {
        let analytics = MeetingAnalytics(
            id: UUID(),
            meetingID: UUID(),
            totalDuration: 3600,
            participantCount: 10,
            engagementScore: 0.85
        )

        #expect(analytics.totalDuration == 3600)
        #expect(analytics.participantCount == 10)
        #expect(analytics.engagementScore == 0.85)
    }

    @Test("AI insights encode and decode")
    func testAIInsightsCodable() {
        let analytics = MeetingAnalytics(
            id: UUID(),
            meetingID: UUID(),
            totalDuration: 1800,
            participantCount: 5,
            engagementScore: 0.75
        )

        let insights = [
            AIInsight(
                type: .positiveEnergy,
                title: "High Engagement",
                description: "Great participation",
                confidence: 0.9
            ),
            AIInsight(
                type: .consensusReached,
                title: "Agreement Achieved",
                description: "Team aligned on next steps",
                confidence: 0.85
            )
        ]

        analytics.aiInsights = insights

        let retrieved = analytics.aiInsights
        #expect(retrieved.count == 2)
        #expect(retrieved[0].type == .positiveEnergy)
        #expect(retrieved[1].confidence == 0.85)
    }
}

// MARK: - Mock Meeting Factory Tests

@Suite("Mock Data Factory Tests")
struct MockDataFactoryTests {

    @Test("Factory creates valid user")
    func testCreateMockUser() {
        let user = TestDataFactory.createMockUser(
            email: "factory@test.com",
            displayName: "Factory User"
        )

        #expect(user.email == "factory@test.com")
        #expect(user.displayName == "Factory User")
    }

    @Test("Factory creates valid meeting")
    func testCreateMockMeeting() {
        let meeting = TestDataFactory.createMockMeeting(
            title: "Factory Meeting",
            status: .inProgress,
            type: .innovationLab
        )

        #expect(meeting.title == "Factory Meeting")
        #expect(meeting.status == .inProgress)
        #expect(meeting.meetingType == .innovationLab)
    }

    @Test("Factory creates valid transcript with segments")
    func testCreateMockTranscript() {
        let transcript = TestDataFactory.createMockTranscript(segmentCount: 10)

        #expect(transcript.segments.count == 10)
        #expect(transcript.segments.last?.text == "Test segment 9")
    }

    @Test("Meeting.mockMeeting creates valid meeting")
    func testMeetingMockMethod() {
        let meeting = Meeting.mockMeeting()

        #expect(meeting.title == "Product Review")
        #expect(meeting.meetingType == .boardroom)
        #expect(meeting.organizer.displayName == "John Doe")
    }

    @Test("Meeting.mockMeetings creates multiple meetings")
    func testMeetingMockMeetingsMethod() {
        let meetings = Meeting.mockMeetings()

        #expect(meetings.count == 3)
        #expect(meetings[0].title == "Product Review")
        #expect(meetings[1].title == "Design Critique")
        #expect(meetings[2].title == "All Hands")
    }
}
