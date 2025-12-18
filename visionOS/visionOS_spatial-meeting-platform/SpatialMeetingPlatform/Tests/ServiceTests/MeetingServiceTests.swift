//
//  MeetingServiceTests.swift
//  SpatialMeetingPlatformTests
//
//  Tests for MeetingService
//

import Testing
import Foundation
@testable import SpatialMeetingPlatform

@Suite("Meeting Service Tests")
struct MeetingServiceTests {

    // MARK: - Setup

    func createTestService() -> (MeetingService, MockNetworkService, MockDataStore) {
        let networkService = MockNetworkService()
        let dataStore = MockDataStore()
        let service = MeetingService(networkService: networkService, dataStore: dataStore)
        return (service, networkService, dataStore)
    }

    // MARK: - Create Meeting Tests

    @Test("Create meeting saves locally")
    func testCreateMeetingSavesLocally() async throws {
        let (service, _, dataStore) = createTestService()
        let meeting = TestDataFactory.createMockMeeting()

        let result = try await service.createMeeting(meeting)

        #expect(result.id == meeting.id)
        #expect(dataStore.savedMeetings.count == 1)
        #expect(dataStore.savedMeetings.first?.id == meeting.id)
    }

    @Test("Create meeting with invalid data throws error")
    func testCreateMeetingWithError() async throws {
        let (service, _, dataStore) = createTestService()
        dataStore.shouldFailSave = true

        let meeting = TestDataFactory.createMockMeeting()

        await #expect(throws: MockError.self) {
            try await service.createMeeting(meeting)
        }
    }

    // MARK: - Join Meeting Tests

    @Test("Join meeting establishes connection")
    func testJoinMeetingConnects() async throws {
        let (service, networkService, dataStore) = createTestService()
        let meeting = TestDataFactory.createMockMeeting()
        try dataStore.save(meeting)

        let session = try await service.joinMeeting(id: meeting.id)

        #expect(networkService.isConnected)
        #expect(session.meetingID == meeting.id)
        #expect(service.currentMeeting?.id == meeting.id)
        #expect(service.meetingState == .connected)
    }

    @Test("Join meeting with connection failure throws error")
    func testJoinMeetingConnectionFailure() async throws {
        let (service, networkService, dataStore) = createTestService()
        let meeting = TestDataFactory.createMockMeeting()
        try dataStore.save(meeting)

        networkService.shouldFailConnection = true

        await #expect(throws: MockError.self) {
            try await service.joinMeeting(id: meeting.id)
        }

        #expect(service.meetingState != .connected)
    }

    @Test("Join meeting with non-existent ID throws error")
    func testJoinNonExistentMeeting() async throws {
        let (service, _, _) = createTestService()
        let randomID = UUID()

        await #expect(throws: MeetingError.self) {
            try await service.joinMeeting(id: randomID)
        }
    }

    // MARK: - Leave Meeting Tests

    @Test("Leave meeting disconnects and clears state")
    func testLeaveMeetingDisconnects() async throws {
        let (service, networkService, dataStore) = createTestService()
        let meeting = TestDataFactory.createMockMeeting()
        try dataStore.save(meeting)

        // First join
        _ = try await service.joinMeeting(id: meeting.id)
        #expect(service.currentMeeting != nil)
        #expect(networkService.isConnected)

        // Then leave
        try await service.leaveMeeting(id: meeting.id)

        #expect(service.currentMeeting == nil)
        #expect(!networkService.isConnected)
        #expect(service.meetingState == .idle)
    }

    @Test("Leave meeting when not in meeting throws error")
    func testLeaveMeetingNotInMeeting() async throws {
        let (service, _, _) = createTestService()
        let randomID = UUID()

        await #expect(throws: MeetingError.self) {
            try await service.leaveMeeting(id: randomID)
        }
    }

    // MARK: - Fetch Meetings Tests

    @Test("Fetch meetings returns mock data")
    func testFetchMeetings() async throws {
        let (service, _, _) = createTestService()
        let filter = MeetingFilter(status: .scheduled, startDate: nil, endDate: nil)

        let meetings = try await service.fetchMeetings(filter: filter)

        #expect(meetings.count > 0)
    }

    @Test("Fetch meeting by ID returns correct meeting")
    func testFetchMeetingByID() async throws {
        let (service, _, dataStore) = createTestService()
        let meeting = TestDataFactory.createMockMeeting(title: "Specific Meeting")
        try dataStore.save(meeting)

        let fetched = try await service.fetchMeeting(id: meeting.id)

        #expect(fetched.id == meeting.id)
        #expect(fetched.title == "Specific Meeting")
    }

    // MARK: - Update Meeting State Tests

    @Test("Update meeting state changes state")
    func testUpdateMeetingState() async throws {
        let (service, _, _) = createTestService()

        try await service.updateMeetingState(.connecting)
        #expect(service.meetingState == .connecting)

        try await service.updateMeetingState(.connected)
        #expect(service.meetingState == .connected)

        try await service.updateMeetingState(.disconnected)
        #expect(service.meetingState == .disconnected)
    }
}

// MARK: - Meeting Flow Integration Tests

@Suite("Meeting Flow Integration Tests")
struct MeetingFlowTests {

    @Test("Complete meeting flow - create, join, leave")
    func testCompleteMeetingFlow() async throws {
        let networkService = MockNetworkService()
        let dataStore = MockDataStore()
        let service = MeetingService(networkService: networkService, dataStore: dataStore)

        // 1. Create meeting
        let meeting = TestDataFactory.createMockMeeting(title: "Integration Test Meeting")
        let created = try await service.createMeeting(meeting)
        #expect(created.id == meeting.id)
        #expect(dataStore.savedMeetings.count == 1)

        // 2. Join meeting
        let session = try await service.joinMeeting(id: meeting.id)
        #expect(session.meetingID == meeting.id)
        #expect(networkService.isConnected)
        #expect(service.meetingState == .connected)

        // 3. Leave meeting
        try await service.leaveMeeting(id: meeting.id)
        #expect(service.currentMeeting == nil)
        #expect(!networkService.isConnected)
        #expect(service.meetingState == .idle)
    }
}
