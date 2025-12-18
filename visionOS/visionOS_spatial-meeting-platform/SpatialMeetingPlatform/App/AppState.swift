import Foundation
import Observation

@Observable
class AppState {
    // User session
    var currentUser: User?
    var isAuthenticated: Bool = false

    // Meeting state
    var activeMeeting: Meeting?
    var isInMeeting: Bool = false
    var meetingConnectionState: ConnectionState = .disconnected

    // UI state
    var selectedEnvironment: MeetingEnvironment?
    var showSettings: Bool = false
    var showMeetingHub: Bool = true

    // Participants
    var participants: [Participant] = []
    var localParticipant: Participant?

    // Shared content
    var sharedContent: [SharedContent] = []
    var selectedContent: SharedContent?

    // Services
    let meetingService: MeetingService
    let spatialService: SpatialService
    let contentService: ContentService

    init() {
        // Initialize services
        self.meetingService = MeetingService()
        self.spatialService = SpatialService()
        self.contentService = ContentService()

        // Create mock user for testing
        self.currentUser = User(
            email: "test@spatialmeeting.app",
            displayName: "Test User"
        )
        self.isAuthenticated = true

        print("🎯 AppState initialized")
    }

    // MARK: - Actions

    func joinMeeting(_ meeting: Meeting) async throws {
        print("🚀 Joining meeting: \(meeting.title)")

        guard let user = currentUser else {
            throw AppError.notAuthenticated
        }

        // Create local participant
        let participant = Participant(
            userId: user.id,
            displayName: user.displayName,
            email: user.email,
            role: .host // For testing purposes
        )

        // Join meeting via service
        try await meetingService.joinMeeting(id: meeting.id, as: participant)

        // Update app state
        activeMeeting = meeting
        isInMeeting = true
        localParticipant = participant
        participants = [participant]
        meetingConnectionState = .connected

        // Start spatial tracking
        try await spatialService.startTracking()

        print("✅ Successfully joined meeting")
    }

    func leaveMeeting() async throws {
        print("👋 Leaving meeting...")

        // Leave via service
        try await meetingService.leaveMeeting()

        // Stop spatial tracking
        spatialService.stopTracking()

        // Clear state
        activeMeeting = nil
        isInMeeting = false
        participants = []
        sharedContent = []
        selectedContent = nil
        meetingConnectionState = .disconnected

        print("✅ Left meeting successfully")
    }

    func toggleMute() async throws {
        guard let participant = localParticipant else { return }

        try await meetingService.toggleAudio(participant.id)

        // Update local state
        if let index = participants.firstIndex(where: { $0.id == participant.id }) {
            participants[index].audioEnabled.toggle()
        }
    }

    func raiseHand() async throws {
        guard let participant = localParticipant else { return }

        try await meetingService.raiseHand(participant.id)

        // Update local state
        if let index = participants.firstIndex(where: { $0.id == participant.id }) {
            participants[index].handRaised.toggle()
        }
    }

    func shareContent(_ content: SharedContent) async throws {
        try await contentService.shareContent(content)
        sharedContent.append(content)
    }

    // MARK: - Mock Data

    func loadMockData() async throws {
        print("📊 Loading mock data...")

        // Create some mock meetings if needed for testing
        // This would normally come from the backend
    }
}

enum AppError: LocalizedError {
    case notAuthenticated
    case noActiveMeeting
    case invalidState

    var errorDescription: String? {
        switch self {
        case .notAuthenticated: return "User not authenticated"
        case .noActiveMeeting: return "No active meeting"
        case .invalidState: return "Invalid application state"
        }
    }
}
