//
//  MeetingService.swift
//  SpatialMeetingPlatform
//
//  Meeting management service
//

import Foundation
import Observation

@Observable
class MeetingService: MeetingServiceProtocol {

    // MARK: - Properties

    private let networkService: NetworkServiceProtocol
    private let dataStore: DataStoreProtocol

    private(set) var currentMeeting: Meeting?
    private(set) var participants: [Participant] = []
    private(set) var meetingState: MeetingState = .idle

    // MARK: - Initialization

    init(networkService: NetworkServiceProtocol, dataStore: DataStoreProtocol) {
        self.networkService = networkService
        self.dataStore = dataStore
    }

    // MARK: - MeetingServiceProtocol

    func createMeeting(_ meeting: Meeting) async throws -> Meeting {
        // Save locally
        try dataStore.save(meeting)

        // Sync to backend (placeholder)
        // In real implementation, send to API
        print("Creating meeting: \(meeting.title)")

        return meeting
    }

    func joinMeeting(id: UUID) async throws -> MeetingSession {
        // Fetch meeting details
        let meeting = try await fetchMeeting(id: id)

        // Update state
        meetingState = .connecting

        // Connect to network
        try await networkService.connect()

        // Create session (placeholder for WebRTC setup)
        let session = MeetingSession(
            meetingID: id,
            sessionID: UUID().uuidString,
            joinedAt: Date()
        )

        // Update state
        self.currentMeeting = meeting
        meetingState = .connected

        print("Joined meeting: \(meeting.title)")

        // In real implementation: Set up WebRTC, subscribe to updates
        subscribeToMeetingUpdates(meetingID: id)

        return session
    }

    func leaveMeeting(id: UUID) async throws {
        guard let meeting = currentMeeting, meeting.id == id else {
            throw MeetingError.notInMeeting
        }

        // Disconnect
        try await networkService.disconnect()

        // Clear state
        self.currentMeeting = nil
        self.participants = []
        meetingState = .idle

        print("Left meeting: \(meeting.title)")
    }

    func updateMeetingState(_ state: MeetingState) async throws {
        meetingState = state

        // In real implementation: Sync state to backend
        print("Meeting state updated: \(state.rawValue)")
    }

    func fetchMeetings(filter: MeetingFilter) async throws -> [Meeting] {
        // In real implementation: Fetch from backend API
        // For now, return mock data
        return Meeting.mockMeetings()
    }

    func fetchMeeting(id: UUID) async throws -> Meeting {
        // Try local storage first
        if let meeting = try dataStore.fetch(id: id) {
            return meeting
        }

        // Fetch from backend (placeholder)
        // In real implementation: API call
        throw MeetingError.meetingNotFound
    }

    // MARK: - Private Methods

    private func subscribeToMeetingUpdates(meetingID: UUID) {
        // In real implementation: Subscribe to WebSocket updates for participants
        print("Subscribed to meeting updates for: \(meetingID)")
    }
}

enum MeetingError: LocalizedError {
    case notInMeeting
    case meetingNotFound
    case connectionFailed

    var errorDescription: String? {
        switch self {
        case .notInMeeting:
            return "You are not currently in a meeting"
        case .meetingNotFound:
            return "Meeting not found"
        case .connectionFailed:
            return "Failed to connect to meeting"
        }
    }
}
