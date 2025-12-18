//
//  CollaborationManager.swift
//  AIAgentCoordinator
//
//  Created by AI Agent Coordinator on 2025-01-20.
//

import Foundation
import GroupActivities
import Observation

/// Manager for multi-user collaboration sessions using SharePlay
/// Enables up to 8 participants to share the agent visualization space
@Observable
final class CollaborationManager: @unchecked Sendable {

    // MARK: - Properties

    /// Current collaboration session
    private(set) var session: GroupSession<AgentCoordinatorActivity>?

    /// Active participants
    private(set) var participants: [Participant] = []

    /// Is currently in a collaboration session
    var isCollaborating: Bool {
        session != nil && !participants.isEmpty
    }

    /// Local participant (current user)
    private(set) var localParticipant: Participant?

    /// Shared state messenger for syncing
    private var messenger: GroupSessionMessenger?

    /// Collaboration events stream
    private var eventContinuation: AsyncStream<CollaborationEvent>.Continuation?

    // MARK: - Session Management

    /// Start a new collaboration session
    func startSession() async throws {
        let activity = AgentCoordinatorActivity()

        switch await activity.prepareForActivation() {
        case .activationPreferred:
            _ = try await activity.activate()
        case .activationDisabled:
            throw CollaborationError.activationDisabled
        case .cancelled:
            throw CollaborationError.cancelled
        @unknown default:
            throw CollaborationError.unknown
        }
    }

    /// Join an existing collaboration session
    func joinSession(_ session: GroupSession<AgentCoordinatorActivity>) async {
        self.session = session
        self.messenger = GroupSessionMessenger(session: session)

        session.join()

        // Listen for participant changes
        await observeParticipants()

        // Listen for messages
        await observeMessages()
    }

    /// Leave the current session
    func leaveSession() {
        session?.leave()
        session = nil
        messenger = nil
        participants.removeAll()
        localParticipant = nil
    }

    // MARK: - Participant Management

    /// Observe participant changes
    private func observeParticipants() async {
        guard let session = session else { return }

        for await participants in session.$activeParticipants.values {
            self.participants = participants.map { participant in
                Participant(
                    id: participant.id,
                    isLocal: participant == session.localParticipant
                )
            }

            // Update local participant
            if let local = participants.first(where: { $0 == session.localParticipant }) {
                localParticipant = Participant(id: local.id, isLocal: true)
            }

            eventContinuation?.yield(.participantsChanged(self.participants))
        }
    }

    // MARK: - State Synchronization

    /// Send agent selection to all participants
    func broadcastAgentSelection(_ agentId: UUID) async throws {
        try await messenger?.send(
            CollaborationMessage.agentSelected(agentId, by: localParticipant?.id ?? UUID())
        )
    }

    /// Send view change to all participants
    func broadcastViewChange(_ viewState: ViewState) async throws {
        try await messenger?.send(
            CollaborationMessage.viewChanged(viewState, by: localParticipant?.id ?? UUID())
        )
    }

    /// Send spatial annotation
    func broadcastAnnotation(_ annotation: SpatialAnnotation) async throws {
        try await messenger?.send(
            CollaborationMessage.annotationAdded(annotation)
        )
    }

    /// Send cursor/pointer position (for presence)
    func broadcastCursorPosition(_ position: SIMD3<Float>) async throws {
        try await messenger?.send(
            CollaborationMessage.cursorMoved(position, by: localParticipant?.id ?? UUID())
        )
    }

    // MARK: - Message Handling

    /// Observe incoming messages
    private func observeMessages() async {
        guard let messenger = messenger else { return }

        for await (message, _) in messenger.messages(of: CollaborationMessage.self) {
            handleMessage(message)
        }
    }

    /// Handle received collaboration message
    private func handleMessage(_ message: CollaborationMessage) {
        switch message {
        case .agentSelected(let agentId, let participantId):
            eventContinuation?.yield(.agentSelected(agentId, by: participantId))

        case .viewChanged(let viewState, let participantId):
            eventContinuation?.yield(.viewChanged(viewState, by: participantId))

        case .annotationAdded(let annotation):
            eventContinuation?.yield(.annotationAdded(annotation))

        case .annotationRemoved(let annotationId):
            eventContinuation?.yield(.annotationRemoved(annotationId))

        case .cursorMoved(let position, let participantId):
            eventContinuation?.yield(.cursorMoved(position, by: participantId))

        case .chatMessage(let text, let participantId):
            eventContinuation?.yield(.chatMessage(text, from: participantId))
        }
    }

    // MARK: - Events Stream

    /// Stream collaboration events
    func events() -> AsyncStream<CollaborationEvent> {
        AsyncStream { continuation in
            self.eventContinuation = continuation

            continuation.onTermination = { [weak self] _ in
                self?.eventContinuation = nil
            }
        }
    }

    // MARK: - Spatial Annotations

    /// Add a spatial annotation at a position
    func addAnnotation(text: String, position: SIMD3<Float>, agentId: UUID?) async throws {
        let annotation = SpatialAnnotation(
            id: UUID(),
            text: text,
            position: position,
            agentId: agentId,
            creatorId: localParticipant?.id ?? UUID(),
            timestamp: Date()
        )

        try await broadcastAnnotation(annotation)
    }

    /// Remove a spatial annotation
    func removeAnnotation(_ id: UUID) async throws {
        try await messenger?.send(
            CollaborationMessage.annotationRemoved(id)
        )
    }
}

// MARK: - GroupActivity

/// Group activity for SharePlay integration
struct AgentCoordinatorActivity: GroupActivity {
    static let activityIdentifier = "com.aiagentcoordinator.collaboration"

    var metadata: GroupActivityMetadata {
        var metadata = GroupActivityMetadata()
        metadata.title = "AI Agent Coordinator"
        metadata.subtitle = "Collaborative Agent Monitoring"
        metadata.type = .generic
        metadata.supportsContinuationOnTV = false
        return metadata
    }
}

// MARK: - Supporting Types

/// Participant in collaboration session
struct Participant: Identifiable, Hashable, Sendable {
    let id: UUID
    let isLocal: Bool
}

/// Collaboration messages sent between participants
enum CollaborationMessage: Codable, Sendable {
    case agentSelected(UUID, by: UUID)
    case viewChanged(ViewState, by: UUID)
    case annotationAdded(SpatialAnnotation)
    case annotationRemoved(UUID)
    case cursorMoved(SIMD3<Float>, by: UUID)
    case chatMessage(String, from: UUID)
}

/// View state for synchronization
enum ViewState: Codable, Sendable {
    case controlPanel
    case agentGalaxy
    case performanceLandscape
    case decisionFlow
    case agentDetail(UUID)
}

/// Spatial annotation in 3D space
struct SpatialAnnotation: Identifiable, Codable, Sendable {
    let id: UUID
    let text: String
    let position: SIMD3<Float>
    let agentId: UUID?
    let creatorId: UUID
    let timestamp: Date
}

/// Collaboration events
enum CollaborationEvent: Sendable {
    case participantsChanged([Participant])
    case agentSelected(UUID, by: UUID)
    case viewChanged(ViewState, by: UUID)
    case annotationAdded(SpatialAnnotation)
    case annotationRemoved(UUID)
    case cursorMoved(SIMD3<Float>, by: UUID)
    case chatMessage(String, from: UUID)
}

/// Collaboration errors
enum CollaborationError: Error, LocalizedError {
    case activationDisabled
    case cancelled
    case noSession
    case unknown

    var errorDescription: String? {
        switch self {
        case .activationDisabled:
            return "Collaboration activation is disabled"
        case .cancelled:
            return "Collaboration was cancelled"
        case .noSession:
            return "No active collaboration session"
        case .unknown:
            return "Unknown collaboration error"
        }
    }
}

// MARK: - SIMD Codable Extension

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
