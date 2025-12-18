//
//  AppModel.swift
//  SpatialMeetingPlatform
//
//  Application-wide state management
//

import Foundation
import Observation
import SwiftUI

@Observable
class AppModel {

    // MARK: - Authentication State

    var currentUser: User?
    var isAuthenticated: Bool { currentUser != nil }

    // MARK: - Meeting State

    var activeMeeting: Meeting?
    var upcomingMeetings: [Meeting] = []
    var meetingHistory: [Meeting] = []

    // MARK: - UI State

    var selectedEnvironment: MeetingType = .boardroom
    var immersiveModeActive: Bool = false
    var showingControls: Bool = true
    var showingParticipantGrid: Bool = false

    // MARK: - Services

    let meetingService: MeetingServiceProtocol
    let spatialService: SpatialServiceProtocol
    let aiService: AIServiceProtocol
    let authService: AuthServiceProtocol

    // MARK: - Initialization

    init() {
        // Initialize services
        let networkService = WebSocketService()
        let dataStore = DataStore()
        let apiClient = APIClient(baseURL: URL(string: "https://api.example.com")!)

        self.meetingService = MeetingService(networkService: networkService, dataStore: dataStore)
        self.spatialService = SpatialService(networkService: networkService)
        self.aiService = AIService(apiClient: apiClient)
        self.authService = AuthService(apiClient: apiClient, dataStore: dataStore)

        // Load cached user if available
        Task {
            await loadCachedUser()
        }
    }

    // MARK: - Actions

    /// Join a meeting
    func joinMeeting(_ meeting: Meeting) async throws {
        let session = try await meetingService.joinMeeting(id: meeting.id)
        self.activeMeeting = meeting

        // Start AI transcription
        try await aiService.startTranscription(meetingID: meeting.id)

        // Open meeting controls window
        await MainActor.run {
            #if os(visionOS)
            openWindow(id: "meeting-controls")
            #endif
        }
    }

    /// Leave current meeting
    func leaveMeeting() async throws {
        guard let meeting = activeMeeting else { return }

        // Stop transcription and generate summary
        let transcript = try await aiService.stopTranscription(meetingID: meeting.id)
        let _ = try await aiService.generateSummary(transcript: transcript)

        // Leave meeting
        try await meetingService.leaveMeeting(id: meeting.id)

        self.activeMeeting = nil

        // Close meeting windows
        await MainActor.run {
            #if os(visionOS)
            dismissWindow(id: "meeting-controls")
            dismissWindow(id: "meeting-volume")
            if immersiveModeActive {
                dismissImmersiveSpace()
                immersiveModeActive = false
            }
            #endif
        }
    }

    /// Toggle immersive mode
    func toggleImmersiveMode() async throws {
        immersiveModeActive.toggle()

        await MainActor.run {
            #if os(visionOS)
            if immersiveModeActive {
                openImmersiveSpace(id: "immersive-meeting")
            } else {
                dismissImmersiveSpace()
            }
            #endif
        }
    }

    /// Schedule a new meeting
    func scheduleMeeting(title: String, startDate: Date, endDate: Date, type: MeetingType) async throws {
        guard let user = currentUser else {
            throw AppError.notAuthenticated
        }

        let meeting = Meeting(
            id: UUID(),
            title: title,
            description: nil,
            scheduledStart: startDate,
            scheduledEnd: endDate,
            status: .scheduled,
            meetingType: type,
            organizer: user,
            participants: [],
            createdAt: Date(),
            updatedAt: Date()
        )

        let created = try await meetingService.createMeeting(meeting)
        upcomingMeetings.append(created)
        upcomingMeetings.sort { $0.scheduledStart < $1.scheduledStart }
    }

    /// Fetch upcoming meetings
    func fetchUpcomingMeetings() async throws {
        let filter = MeetingFilter(
            status: .scheduled,
            startDate: Date(),
            endDate: nil
        )

        upcomingMeetings = try await meetingService.fetchMeetings(filter: filter)
        upcomingMeetings.sort { $0.scheduledStart < $1.scheduledStart }
    }

    /// Authenticate user
    func authenticate(email: String, password: String) async throws {
        currentUser = try await authService.authenticate(email: email, password: password)

        // Fetch user's meetings after authentication
        try await fetchUpcomingMeetings()
    }

    /// Sign out
    func signOut() async throws {
        try await authService.signOut()
        currentUser = nil
        upcomingMeetings = []
        meetingHistory = []
    }

    // MARK: - Private Methods

    private func loadCachedUser() async {
        do {
            currentUser = try await authService.loadCachedUser()
            if currentUser != nil {
                try await fetchUpcomingMeetings()
            }
        } catch {
            print("Failed to load cached user: \(error)")
        }
    }
}

// MARK: - Supporting Types

enum AppError: LocalizedError {
    case notAuthenticated
    case meetingNotFound
    case joinFailed

    var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            return "You must be logged in to perform this action"
        case .meetingNotFound:
            return "The requested meeting could not be found"
        case .joinFailed:
            return "Failed to join the meeting"
        }
    }
}

struct MeetingFilter {
    var status: MeetingStatus?
    var startDate: Date?
    var endDate: Date?
}

// MARK: - Window Management Extensions

#if os(visionOS)
extension AppModel {
    func openWindow(id: String) {
        // Note: In actual implementation, use @Environment(\.openWindow)
        print("Opening window: \(id)")
    }

    func dismissWindow(id: String) {
        // Note: In actual implementation, use @Environment(\.dismissWindow)
        print("Dismissing window: \(id)")
    }

    func openImmersiveSpace(id: String) {
        // Note: In actual implementation, use @Environment(\.openImmersiveSpace)
        print("Opening immersive space: \(id)")
    }

    func dismissImmersiveSpace() {
        // Note: In actual implementation, use @Environment(\.dismissImmersiveSpace)
        print("Dismissing immersive space")
    }
}
#endif
