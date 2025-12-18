import Foundation

@Observable
class CollaborationService {
    private var webSocket: URLSessionWebSocketTask?
    private var collaborationSession: CollaborationSession?

    func startCollaborationSession(storeId: UUID) async throws -> CollaborationSession {
        #if DEBUG
        if Configuration.useMockData {
            let session = CollaborationSession(
                id: UUID(),
                storeId: storeId,
                participants: [],
                startTime: Date()
            )
            self.collaborationSession = session
            return session
        }
        #endif

        // Connect to WebSocket server
        // let url = URL(string: "wss://api.retailoptimizer.com/collaborate/\(storeId)")!
        // webSocket = URLSession.shared.webSocketTask(with: url)
        // webSocket?.resume()

        let session = CollaborationSession(
            id: UUID(),
            storeId: storeId,
            participants: [],
            startTime: Date()
        )
        self.collaborationSession = session
        return session
    }

    func endCollaborationSession() async throws {
        webSocket?.cancel(with: .goingAway, reason: nil)
        webSocket = nil
        collaborationSession = nil
    }

    func shareLayout(_ layout: StoreLayout, with users: [User]) async throws {
        #if DEBUG
        if Configuration.useMockData {
            // Simulate sharing
            try await Task.sleep(for: .milliseconds(500))
            return
        }
        #endif

        // Send layout data to users via WebSocket or API
    }

    func syncChanges(_ changes: [LayoutChange]) async throws {
        guard let session = collaborationSession else {
            throw CollaborationError.noActiveSession
        }

        // Send changes to other participants
        for change in changes {
            // webSocket?.send(.string(encoded change))
            print("Syncing change: \(change)")
        }
    }
}

// MARK: - Collaboration Models

struct CollaborationSession: Codable, Identifiable {
    var id: UUID
    var storeId: UUID
    var participants: [User]
    var startTime: Date
}

struct LayoutChange: Codable {
    var type: ChangeType
    var fixtureId: UUID?
    var data: Data?
    var userId: UUID
    var timestamp: Date

    enum ChangeType: String, Codable {
        case fixtureAdded
        case fixtureRemoved
        case fixtureMoved
        case fixtureRotated
        case layoutUpdated
    }
}

// MARK: - Collaboration Errors

enum CollaborationError: LocalizedError {
    case noActiveSession

    var errorDescription: String? {
        switch self {
        case .noActiveSession:
            return "No active collaboration session"
        }
    }
}
