import Foundation
import GroupActivities

// MARK: - Collaboration Service Protocol
protocol CollaborationServiceProtocol {
    func startSession(teamID: UUID) async throws -> CollaborationSession
    func endSession(_ sessionID: UUID) async throws
    func inviteUser(_ userID: UUID, to sessionID: UUID) async throws
    func syncChanges(_ changes: [EntityChange]) async throws
    func broadcastGesture(_ gesture: SpatialGesture) async throws
}

// MARK: - Collaboration Service Implementation
@Observable
final class CollaborationService: CollaborationServiceProtocol {
    var activeSessions: [UUID: CollaborationSession] = [:]
    var connectedUsers: [UUID: UserPresence] = [:]

    func startSession(teamID: UUID) async throws -> CollaborationSession {
        let session = CollaborationSession(teamID: teamID)
        activeSessions[session.id] = session

        await AnalyticsService.shared.trackEvent(.collaborationStarted(sessionID: session.id))

        // In production, setup SharePlay group activity
        await initializeSharePlay(session: session)

        return session
    }

    func endSession(_ sessionID: UUID) async throws {
        guard var session = activeSessions[sessionID] else {
            throw ServiceError.notFound
        }

        session.isActive = false
        session.endTime = Date()
        activeSessions.removeValue(forKey: sessionID)

        await AnalyticsService.shared.trackEvent(.collaborationEnded(sessionID: sessionID))
    }

    func inviteUser(_ userID: UUID, to sessionID: UUID) async throws {
        guard var session = activeSessions[sessionID] else {
            throw ServiceError.notFound
        }

        if !session.participants.contains(userID) {
            session.participants.append(userID)
            activeSessions[sessionID] = session
        }
    }

    func syncChanges(_ changes: [EntityChange]) async throws {
        // Broadcast changes to all connected users
        for change in changes {
            // In production, use WebSocket or SharePlay for real-time sync
            await broadcastChange(change)
        }
    }

    func broadcastGesture(_ gesture: SpatialGesture) async throws {
        // Broadcast user gestures to collaborators
        print("Broadcasting gesture: \\(gesture)")
    }

    private func initializeSharePlay(session: CollaborationSession) async {
        // SharePlay implementation would go here
        // This requires GroupActivities framework
        print("Initializing SharePlay for session: \\(session.id)")
    }

    private func broadcastChange(_ change: EntityChange) async {
        // Send change to all connected users
        print("Broadcasting change: \\(change.type)")
    }
}

// MARK: - Entity Change
struct EntityChange: Codable {
    let id: UUID
    let type: ChangeType
    let entityID: UUID
    let timestamp: Date
    let userID: UUID

    enum ChangeType: String, Codable {
        case created
        case updated
        case deleted
        case moved
        case transformed
    }
}

// MARK: - Spatial Gesture
enum SpatialGesture {
    case tap(position: SIMD3<Float>)
    case drag(start: SIMD3<Float>, end: SIMD3<Float>)
    case pinch(scale: Float)
    case rotate(angle: Float, axis: SIMD3<Float>)
    case custom(name: String, data: [String: Any])
}

// MARK: - User Presence
struct UserPresence: Codable {
    let userID: UUID
    let userName: String
    var cursorPosition: SIMD3<Float>?
    var gazeDirection: SIMD3<Float>?
    var isActive: Bool
    var lastUpdate: Date

    init(userID: UUID, userName: String) {
        self.userID = userID
        self.userName = userName
        self.isActive = true
        self.lastUpdate = Date()
    }
}

extension SIMD3: Codable where Scalar == Float {
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        let x = try container.decode(Float.self)
        let y = try container.decode(Float.self)
        let z = try container.decode(Float.self)
        self.init(x, y, z)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(self.x)
        try container.encode(self.y)
        try container.encode(self.z)
    }
}
