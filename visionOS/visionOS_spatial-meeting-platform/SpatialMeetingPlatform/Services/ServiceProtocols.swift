//
//  ServiceProtocols.swift
//  SpatialMeetingPlatform
//
//  Protocol definitions for services
//

import Foundation

// MARK: - Meeting Service Protocol

protocol MeetingServiceProtocol {
    func createMeeting(_ meeting: Meeting) async throws -> Meeting
    func joinMeeting(id: UUID) async throws -> MeetingSession
    func leaveMeeting(id: UUID) async throws
    func updateMeetingState(_ state: MeetingState) async throws
    func fetchMeetings(filter: MeetingFilter) async throws -> [Meeting]
    func fetchMeeting(id: UUID) async throws -> Meeting
}

struct MeetingSession {
    let meetingID: UUID
    let sessionID: String
    let joinedAt: Date
}

enum MeetingState: String, Codable {
    case idle
    case connecting
    case connected
    case reconnecting
    case disconnected
    case error
}

// MARK: - Spatial Service Protocol

protocol SpatialServiceProtocol {
    func updateParticipantPosition(_ position: SpatialPosition) async throws
    func syncSpatialState() async throws -> SpatialScene
    func placeContent(_ content: SharedContent, at: SpatialTransform) async throws
    func removeContent(id: UUID) async throws
}

struct SpatialScene: Codable {
    var entities: [SpatialEntity]
    var lights: [LightConfiguration]
    var materials: [MaterialConfiguration]
    var audioSources: [SpatialAudioSource]
}

struct SpatialEntity: Codable, Identifiable {
    var id: UUID
    var type: EntityType
    var transform: SpatialTransform
    var modelReference: String?
}

enum EntityType: String, Codable {
    case avatar
    case content
    case whiteboard
    case environment
    case decoration
    case control
}

struct LightConfiguration: Codable {
    var type: LightType
    var intensity: Float
    var color: CodableColor
    var position: CodableVector3

    init(type: LightType, intensity: Float, color: CodableColor, position: SIMD3<Float>) {
        self.type = type
        self.intensity = intensity
        self.color = color
        self.position = CodableVector3(position)
    }
}

enum LightType: String, Codable {
    case directional
    case point
    case spot
    case ambient
}

struct MaterialConfiguration: Codable {
    var id: String
    var baseColor: CodableColor
    var metallic: Float
    var roughness: Float
    var emissive: CodableColor?
}

struct CodableColor: Codable {
    var red: Float
    var green: Float
    var blue: Float
    var alpha: Float

    init(red: Float, green: Float, blue: Float, alpha: Float = 1.0) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }
}

struct SpatialAudioSource: Codable, Identifiable {
    var id: UUID
    var position: CodableVector3
    var volume: Float
    var spatializationEnabled: Bool
    var reverbEnabled: Bool

    init(id: UUID, position: SIMD3<Float>, volume: Float, spatializationEnabled: Bool, reverbEnabled: Bool) {
        self.id = id
        self.position = CodableVector3(position)
        self.volume = volume
        self.spatializationEnabled = spatializationEnabled
        self.reverbEnabled = reverbEnabled
    }
}

// MARK: - AI Service Protocol

protocol AIServiceProtocol {
    func startTranscription(meetingID: UUID) async throws
    func stopTranscription(meetingID: UUID) async throws -> Transcript
    func generateSummary(transcript: Transcript) async throws -> String
    func extractActionItems(transcript: Transcript) async throws -> [ActionItem]
    func analyzeEngagement(meetingID: UUID) async throws -> MeetingAnalytics
}

// MARK: - Network Service Protocol

protocol NetworkServiceProtocol {
    func connect() async throws
    func disconnect() async throws
    func send<T: Codable>(_ message: T) async throws
    func subscribe<T: Codable>(to channel: String, handler: @escaping (T) -> Void)
    func fetch<T: Codable>(_ request: T) async throws -> T
}

// MARK: - Auth Service Protocol

protocol AuthServiceProtocol {
    func authenticate(email: String, password: String) async throws -> User
    func signOut() async throws
    func loadCachedUser() async throws -> User?
}

// MARK: - Data Store Protocol

protocol DataStoreProtocol {
    func save(_ meeting: Meeting) throws
    func fetch(id: UUID) throws -> Meeting?
    func fetchAll(filter: MeetingFilter) throws -> [Meeting]
    func delete(id: UUID) throws
}
