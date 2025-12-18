//
//  CollaborationViewModel.swift
//  AIAgentCoordinator
//
//  Created by AI Agent Coordinator on 2025-01-20.
//

import Foundation
import Observation
import GroupActivities

/// ViewModel for managing collaboration sessions
/// Handles SharePlay integration and multi-user state synchronization
@Observable
@MainActor
final class CollaborationViewModel {

    // MARK: - Properties

    /// Collaboration manager service
    private let collaborationManager: CollaborationManager

    /// Is currently in a collaboration session
    var isCollaborating: Bool {
        collaborationManager.isCollaborating
    }

    /// Active participants
    var participants: [Participant] {
        collaborationManager.participants
    }

    /// Local participant
    var localParticipant: Participant? {
        collaborationManager.localParticipant
    }

    /// Spatial annotations in the scene
    private(set) var annotations: [SpatialAnnotation] = []

    /// Participant cursors/pointers
    private(set) var participantCursors: [UUID: SIMD3<Float>] = [:]

    /// Chat messages
    private(set) var chatMessages: [ChatMessage] = []

    /// Show collaboration UI
    var showCollaborationUI = false

    /// Error state
    private(set) var error: Error?

    /// Event monitoring task
    private var eventTask: Task<Void, Never>?

    // MARK: - Initialization

    init(collaborationManager: CollaborationManager = CollaborationManager()) {
        self.collaborationManager = collaborationManager
    }

    // MARK: - Session Management

    /// Start a new collaboration session
    func startSession() async {
        do {
            try await collaborationManager.startSession()
            showCollaborationUI = true
            startEventMonitoring()
        } catch {
            self.error = error
        }
    }

    /// Join collaboration session
    nonisolated func joinSession(_ session: GroupSession<AgentCoordinatorActivity>) async {
        await collaborationManager.joinSession(session)
        await MainActor.run {
            showCollaborationUI = true
            startEventMonitoring()
        }
    }

    /// Leave current session
    func leaveSession() {
        collaborationManager.leaveSession()
        showCollaborationUI = false
        stopEventMonitoring()
        clearState()
    }

    // MARK: - Event Monitoring

    /// Start monitoring collaboration events
    private func startEventMonitoring() {
        eventTask = Task {
            for await event in collaborationManager.events() {
                handleEvent(event)
            }
        }
    }

    /// Stop monitoring events
    private func stopEventMonitoring() {
        eventTask?.cancel()
        eventTask = nil
    }

    /// Handle collaboration event
    private func handleEvent(_ event: CollaborationEvent) {
        switch event {
        case .participantsChanged:
            // Participants automatically updated through @Observable

            break

        case .agentSelected(let agentId, let participantId):
            // Could show indicator for which participant selected what
            addChatMessage("Participant selected agent", from: participantId)

        case .viewChanged(let viewState, let participantId):
            addChatMessage("Participant changed view", from: participantId)

        case .annotationAdded(let annotation):
            annotations.append(annotation)

        case .annotationRemoved(let annotationId):
            annotations.removeAll { $0.id == annotationId }

        case .cursorMoved(let position, let participantId):
            participantCursors[participantId] = position

        case .chatMessage(let text, let participantId):
            addChatMessage(text, from: participantId)
        }
    }

    // MARK: - Annotations

    /// Add a spatial annotation
    func addAnnotation(text: String, at position: SIMD3<Float>, for agentId: UUID? = nil) async {
        do {
            try await collaborationManager.addAnnotation(
                text: text,
                position: position,
                agentId: agentId
            )
        } catch {
            self.error = error
        }
    }

    /// Remove an annotation
    func removeAnnotation(_ annotation: SpatialAnnotation) async {
        do {
            try await collaborationManager.removeAnnotation(annotation.id)
            annotations.removeAll { $0.id == annotation.id }
        } catch {
            self.error = error
        }
    }

    /// Clear all annotations
    func clearAllAnnotations() async {
        for annotation in annotations {
            await removeAnnotation(annotation)
        }
    }

    // MARK: - State Synchronization

    /// Broadcast agent selection
    func broadcastAgentSelection(_ agentId: UUID) async {
        do {
            try await collaborationManager.broadcastAgentSelection(agentId)
        } catch {
            self.error = error
        }
    }

    /// Broadcast view change
    func broadcastViewChange(_ viewState: ViewState) async {
        do {
            try await collaborationManager.broadcastViewChange(viewState)
        } catch {
            self.error = error
        }
    }

    /// Broadcast cursor position
    func updateCursorPosition(_ position: SIMD3<Float>) async {
        guard let localId = localParticipant?.id else { return }

        participantCursors[localId] = position

        do {
            try await collaborationManager.broadcastCursorPosition(position)
        } catch {
            self.error = error
        }
    }

    // MARK: - Chat

    /// Send a chat message
    func sendChatMessage(_ text: String) async {
        guard let localId = localParticipant?.id else { return }

        let message = ChatMessage(
            id: UUID(),
            text: text,
            senderId: localId,
            timestamp: Date()
        )

        chatMessages.append(message)

        // Broadcast to other participants would happen here
    }

    private func addChatMessage(_ text: String, from participantId: UUID) {
        let message = ChatMessage(
            id: UUID(),
            text: text,
            senderId: participantId,
            timestamp: Date()
        )
        chatMessages.append(message)
    }

    /// Clear chat history
    func clearChatHistory() {
        chatMessages.removeAll()
    }

    // MARK: - Helpers

    /// Clear all collaboration state
    private func clearState() {
        annotations.removeAll()
        participantCursors.removeAll()
        chatMessages.removeAll()
    }

    /// Get participant name
    func participantName(for id: UUID) -> String {
        if id == localParticipant?.id {
            return "You"
        }
        // In production, would fetch actual names
        return "Participant \(id.uuidString.prefix(8))"
    }

    /// Get participant color for visual distinction
    func participantColor(for id: UUID) -> SIMD3<Float> {
        // Generate consistent color from UUID
        let hash = abs(id.hashValue)
        let hue = Float(hash % 360) / 360.0
        return hsvToRGB(h: hue, s: 0.7, v: 0.9)
    }

    private func hsvToRGB(h: Float, s: Float, v: Float) -> SIMD3<Float> {
        let c = v * s
        let x = c * (1 - abs((h * 6).truncatingRemainder(dividingBy: 2) - 1))
        let m = v - c

        var rgb: SIMD3<Float>
        let segment = Int(h * 6)

        switch segment {
        case 0: rgb = SIMD3(c, x, 0)
        case 1: rgb = SIMD3(x, c, 0)
        case 2: rgb = SIMD3(0, c, x)
        case 3: rgb = SIMD3(0, x, c)
        case 4: rgb = SIMD3(x, 0, c)
        default: rgb = SIMD3(c, 0, x)
        }

        return rgb + SIMD3(repeating: m)
    }
}

// MARK: - Supporting Types

/// Chat message
struct ChatMessage: Identifiable {
    let id: UUID
    let text: String
    let senderId: UUID
    let timestamp: Date
}
