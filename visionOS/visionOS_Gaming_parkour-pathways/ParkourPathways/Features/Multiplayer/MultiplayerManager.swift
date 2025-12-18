//
//  MultiplayerManager.swift
//  Parkour Pathways
//
//  Central multiplayer coordination system
//

import Foundation
import GroupActivities
import Combine

/// Central manager for multiplayer functionality
@MainActor
class MultiplayerManager: ObservableObject {

    // MARK: - Published Properties

    @Published var isInMultiplayerSession: Bool = false
    @Published var connectedPlayers: [RemotePlayer] = []
    @Published var sessionState: MultiplayerSessionState = .disconnected
    @Published var localPlayer: PlayerData?

    // MARK: - Dependencies

    private let sharePlaySession: SharePlaySession
    private let networkSync: NetworkSyncManager
    private let leaderboardManager: LeaderboardManager

    // MARK: - State

    private var cancellables = Set<AnyCancellable>()
    private var currentCourseSession: GroupCourseSession?

    // MARK: - Initialization

    init() {
        self.sharePlaySession = SharePlaySession()
        self.networkSync = NetworkSyncManager()
        self.leaderboardManager = LeaderboardManager()

        setupBindings()
    }

    // MARK: - Setup

    private func setupBindings() {
        // Listen for SharePlay session changes
        sharePlaySession.$isActive
            .sink { [weak self] isActive in
                self?.isInMultiplayerSession = isActive
            }
            .store(in: &cancellables)

        // Listen for player connections
        sharePlaySession.$connectedParticipants
            .sink { [weak self] participants in
                self?.handleParticipantsChanged(participants)
            }
            .store(in: &cancellables)

        // Listen for network sync state
        networkSync.$syncState
            .sink { [weak self] state in
                self?.handleSyncStateChanged(state)
            }
            .store(in: &cancellables)
    }

    // MARK: - Public API - Session Management

    /// Start a SharePlay multiplayer session
    func startSharePlaySession() async throws {
        guard let courseData = currentCourseSession?.courseData else {
            throw MultiplayerError.noCourseSelected
        }

        let activity = GroupCourseActivity(courseData: courseData)
        try await sharePlaySession.startSession(activity: activity)

        sessionState = .connecting
    }

    /// Join an existing SharePlay session
    func joinSharePlaySession() async throws {
        try await sharePlaySession.joinSession()
        sessionState = .connecting
    }

    /// Leave the current multiplayer session
    func leaveSession() async {
        await sharePlaySession.leaveSession()
        networkSync.disconnect()
        connectedPlayers.removeAll()
        sessionState = .disconnected
        isInMultiplayerSession = false
    }

    /// Prepare a course for multiplayer
    func prepareCourseSession(courseData: CourseData, localPlayer: PlayerData) async throws {
        self.localPlayer = localPlayer

        let session = GroupCourseSession(
            courseData: courseData,
            hostPlayer: localPlayer
        )

        currentCourseSession = session
    }

    // MARK: - Public API - Gameplay Sync

    /// Send player position update to other players
    func syncPlayerPosition(_ position: SIMD3<Float>, velocity: SIMD3<Float>) {
        guard isInMultiplayerSession else { return }

        let update = PlayerPositionUpdate(
            playerId: localPlayer?.id ?? UUID(),
            position: position,
            velocity: velocity,
            timestamp: Date()
        )

        networkSync.sendUpdate(.playerPosition(update))
    }

    /// Send movement event to other players
    func syncMovementEvent(_ event: MovementEvent) {
        guard isInMultiplayerSession else { return }

        let syncEvent = SyncEvent.movement(
            playerId: localPlayer?.id ?? UUID(),
            event: event,
            timestamp: Date()
        )

        networkSync.sendUpdate(syncEvent)
    }

    /// Send checkpoint reached to other players
    func syncCheckpointReached(_ checkpointIndex: Int, time: TimeInterval) {
        guard isInMultiplayerSession else { return }

        let event = SyncEvent.checkpointReached(
            playerId: localPlayer?.id ?? UUID(),
            checkpointIndex: checkpointIndex,
            time: time,
            timestamp: Date()
        )

        networkSync.sendUpdate(event)
    }

    /// Send course completion to other players
    func syncCourseCompletion(finalTime: TimeInterval, score: Float) async throws {
        guard isInMultiplayerSession else { return }

        let completion = CourseCompletion(
            playerId: localPlayer?.id ?? UUID(),
            courseId: currentCourseSession?.courseData.id ?? UUID(),
            finalTime: finalTime,
            score: score,
            timestamp: Date()
        )

        networkSync.sendUpdate(.courseComplete(completion))

        // Also sync to leaderboard
        try await leaderboardManager.submitScore(
            courseId: completion.courseId,
            score: Int(score * 1000),
            time: finalTime
        )
    }

    // MARK: - Public API - Ghost Racing

    /// Enable ghost racing mode (replay previous runs)
    func enableGhostRacing(courseId: UUID) async throws -> [GhostRecording] {
        // Fetch best runs from leaderboard
        let topScores = try await leaderboardManager.fetchTopScores(
            courseId: courseId,
            limit: 3
        )

        // Convert to ghost recordings
        return topScores.compactMap { score in
            GhostRecording(
                playerId: score.playerId,
                username: score.username,
                recording: score.movementRecording
            )
        }
    }

    /// Start recording for ghost replay
    func startRecording() {
        networkSync.startRecording()
    }

    /// Stop recording and save
    func stopRecording() -> MovementRecording? {
        return networkSync.stopRecording()
    }

    // MARK: - Public API - Leaderboards

    /// Fetch global leaderboard for a course
    func fetchGlobalLeaderboard(courseId: UUID, limit: Int = 100) async throws -> [LeaderboardScore] {
        return try await leaderboardManager.fetchTopScores(courseId: courseId, limit: limit)
    }

    /// Fetch friend leaderboard for a course
    func fetchFriendLeaderboard(courseId: UUID) async throws -> [LeaderboardScore] {
        return try await leaderboardManager.fetchFriendScores(courseId: courseId)
    }

    /// Get player's rank on a course
    func getPlayerRank(courseId: UUID) async throws -> Int {
        guard let playerId = localPlayer?.id else {
            throw MultiplayerError.noLocalPlayer
        }
        return try await leaderboardManager.getPlayerRank(courseId: courseId, playerId: playerId)
    }

    // MARK: - Public API - Social Features

    /// Invite friends to session
    func inviteFriends(_ friendIds: [UUID]) async throws {
        try await sharePlaySession.inviteParticipants(friendIds)
    }

    /// Send chat message to session
    func sendChatMessage(_ message: String) {
        guard isInMultiplayerSession else { return }

        let chatMessage = ChatMessage(
            senderId: localPlayer?.id ?? UUID(),
            senderName: localPlayer?.username ?? "Unknown",
            message: message,
            timestamp: Date()
        )

        networkSync.sendUpdate(.chat(chatMessage))
    }

    /// Send emote/reaction
    func sendEmote(_ emote: EmoteType) {
        guard isInMultiplayerSession else { return }

        let emoteEvent = SyncEvent.emote(
            playerId: localPlayer?.id ?? UUID(),
            emote: emote,
            timestamp: Date()
        )

        networkSync.sendUpdate(emoteEvent)
    }

    // MARK: - Private Handlers

    private func handleParticipantsChanged(_ participants: [Participant]) {
        // Update connected players list
        connectedPlayers = participants.map { participant in
            RemotePlayer(
                id: participant.id,
                username: participant.username,
                position: .zero,
                isReady: false
            )
        }

        if participants.isEmpty {
            sessionState = .disconnected
        } else {
            sessionState = .connected
        }
    }

    private func handleSyncStateChanged(_ state: NetworkSyncState) {
        switch state {
        case .connected:
            sessionState = .connected
        case .connecting:
            sessionState = .connecting
        case .disconnected:
            sessionState = .disconnected
        case .error(let error):
            sessionState = .error(error)
        }
    }

    // MARK: - Cleanup

    func cleanup() {
        Task {
            await leaveSession()
        }
        cancellables.removeAll()
    }
}

// MARK: - Supporting Types

enum MultiplayerSessionState {
    case disconnected
    case connecting
    case connected
    case error(Error)
}

struct RemotePlayer: Identifiable {
    let id: UUID
    let username: String
    var position: SIMD3<Float>
    var isReady: Bool
}

struct GroupCourseSession {
    let id: UUID = UUID()
    let courseData: CourseData
    let hostPlayer: PlayerData
    let startTime: Date = Date()
}

struct PlayerPositionUpdate: Codable {
    let playerId: UUID
    let position: SIMD3<Float>
    let velocity: SIMD3<Float>
    let timestamp: Date
}

enum MovementEvent: Codable {
    case jump(position: SIMD3<Float>, intensity: Float)
    case land(position: SIMD3<Float>, impact: Float)
    case vault(position: SIMD3<Float>, type: String)
    case wallRunStart(position: SIMD3<Float>)
    case wallRunEnd(position: SIMD3<Float>)
}

enum SyncEvent: Codable {
    case playerPosition(PlayerPositionUpdate)
    case movement(playerId: UUID, event: MovementEvent, timestamp: Date)
    case checkpointReached(playerId: UUID, checkpointIndex: Int, time: TimeInterval, timestamp: Date)
    case courseComplete(CourseCompletion)
    case chat(ChatMessage)
    case emote(playerId: UUID, emote: EmoteType, timestamp: Date)
}

struct CourseCompletion: Codable {
    let playerId: UUID
    let courseId: UUID
    let finalTime: TimeInterval
    let score: Float
    let timestamp: Date
}

struct ChatMessage: Codable {
    let id: UUID = UUID()
    let senderId: UUID
    let senderName: String
    let message: String
    let timestamp: Date
}

enum EmoteType: String, Codable {
    case thumbsUp = "👍"
    case celebration = "🎉"
    case fire = "🔥"
    case clap = "👏"
    case wave = "👋"
}

struct GhostRecording {
    let playerId: UUID
    let username: String
    let recording: MovementRecording
}

struct MovementRecording: Codable {
    let positions: [(time: TimeInterval, position: SIMD3<Float>)]
    let duration: TimeInterval
}

enum MultiplayerError: Error {
    case noCourseSelected
    case noLocalPlayer
    case sessionFull
    case connectionFailed
    case syncFailed
}

struct Participant {
    let id: UUID
    let username: String
}
