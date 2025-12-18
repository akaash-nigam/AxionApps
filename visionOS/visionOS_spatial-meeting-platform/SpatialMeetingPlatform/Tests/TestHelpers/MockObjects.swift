//
//  MockObjects.swift
//  SpatialMeetingPlatformTests
//
//  Mock objects for testing
//

import Foundation
@testable import SpatialMeetingPlatform

// MARK: - Mock Network Service

class MockNetworkService: NetworkServiceProtocol {
    var isConnected = false
    var sentMessages: [Any] = []
    var shouldFailConnection = false
    var shouldFailSend = false

    func connect() async throws {
        if shouldFailConnection {
            throw MockError.connectionFailed
        }
        isConnected = true
    }

    func disconnect() async throws {
        isConnected = false
    }

    func send<T: Codable>(_ message: T) async throws {
        if shouldFailSend {
            throw MockError.sendFailed
        }
        sentMessages.append(message)
    }

    func subscribe<T: Codable>(to channel: String, handler: @escaping (T) -> Void) {
        // Mock implementation
    }

    func fetch<T: Codable>(_ request: T) async throws -> T {
        return request
    }
}

// MARK: - Mock Data Store

class MockDataStore: DataStoreProtocol {
    var savedMeetings: [Meeting] = []
    var shouldFailSave = false
    var shouldFailFetch = false

    func save(_ meeting: Meeting) throws {
        if shouldFailSave {
            throw MockError.saveFailed
        }
        // Remove existing if present
        savedMeetings.removeAll { $0.id == meeting.id }
        savedMeetings.append(meeting)
    }

    func fetch(id: UUID) throws -> Meeting? {
        if shouldFailFetch {
            throw MockError.fetchFailed
        }
        return savedMeetings.first { $0.id == id }
    }

    func fetchAll(filter: MeetingFilter) throws -> [Meeting] {
        if shouldFailFetch {
            throw MockError.fetchFailed
        }

        var results = savedMeetings

        if let status = filter.status {
            results = results.filter { $0.status == status }
        }

        if let startDate = filter.startDate {
            results = results.filter { $0.scheduledStart >= startDate }
        }

        return results
    }

    func delete(id: UUID) throws {
        savedMeetings.removeAll { $0.id == id }
    }
}

// MARK: - Mock API Client

class MockAPIClient {
    var authToken: String?
    var shouldFailLogin = false
    var mockUser: User?

    func setAuthToken(_ token: String) {
        self.authToken = token
    }

    func clearAuthToken() {
        self.authToken = nil
    }

    func login(email: String, password: String) async throws -> AuthResponse {
        if shouldFailLogin {
            throw MockError.authenticationFailed
        }

        let user = mockUser ?? User(
            id: UUID(),
            email: email,
            displayName: "Test User"
        )

        return AuthResponse(
            token: "mock_token_12345",
            user: UserDTO(
                id: user.id,
                email: user.email,
                displayName: user.displayName
            )
        )
    }
}

// MARK: - Mock Errors

enum MockError: Error {
    case connectionFailed
    case sendFailed
    case saveFailed
    case fetchFailed
    case authenticationFailed
}

// MARK: - Test Data Factories

class TestDataFactory {

    static func createMockUser(
        id: UUID = UUID(),
        email: String = "test@example.com",
        displayName: String = "Test User"
    ) -> User {
        return User(
            id: id,
            email: email,
            displayName: displayName,
            organization: "Test Corp"
        )
    }

    static func createMockMeeting(
        id: UUID = UUID(),
        title: String = "Test Meeting",
        status: MeetingStatus = .scheduled,
        type: MeetingType = .boardroom,
        organizer: User? = nil
    ) -> Meeting {
        let user = organizer ?? createMockUser()

        return Meeting(
            id: id,
            title: title,
            description: "Test meeting description",
            scheduledStart: Date().addingTimeInterval(3600),
            scheduledEnd: Date().addingTimeInterval(7200),
            status: status,
            meetingType: type,
            organizer: user
        )
    }

    static func createMockParticipant(
        id: UUID = UUID(),
        user: User? = nil,
        role: ParticipantRole = .participant
    ) -> Participant {
        let testUser = user ?? createMockUser()

        return Participant(
            id: id,
            user: testUser,
            role: role
        )
    }

    static func createMockTranscript(
        meetingID: UUID = UUID(),
        segmentCount: Int = 5
    ) -> Transcript {
        let transcript = Transcript(id: UUID(), meetingID: meetingID)

        var segments: [TranscriptSegment] = []
        for i in 0..<segmentCount {
            segments.append(TranscriptSegment(
                speakerID: UUID(),
                text: "Test segment \(i)",
                timestamp: Double(i * 10),
                confidence: 0.95
            ))
        }

        transcript.segments = segments
        return transcript
    }

    static func createMockSharedContent(
        id: UUID = UUID(),
        type: ContentType = .document,
        sharedBy: User? = nil
    ) -> SharedContent {
        let user = sharedBy ?? createMockUser()

        return SharedContent(
            id: id,
            type: type,
            title: "Test Document",
            url: "https://example.com/doc.pdf",
            sharedBy: user
        )
    }
}

// MARK: - Mock Spatial Scene

extension SpatialScene {
    static func mock() -> SpatialScene {
        return SpatialScene(
            entities: [
                SpatialEntity(
                    id: UUID(),
                    type: .avatar,
                    transform: SpatialTransform(),
                    modelReference: nil
                )
            ],
            lights: [
                LightConfiguration(
                    type: .directional,
                    intensity: 1000,
                    color: CodableColor(red: 1, green: 1, blue: 1),
                    position: SIMD3(0, 5, 0)
                )
            ],
            materials: [],
            audioSources: []
        )
    }
}
