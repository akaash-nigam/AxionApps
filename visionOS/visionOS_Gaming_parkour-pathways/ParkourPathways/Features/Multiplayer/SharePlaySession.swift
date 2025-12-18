//
//  SharePlaySession.swift
//  Parkour Pathways
//
//  SharePlay / GroupActivities integration
//

import Foundation
import GroupActivities
import Combine

/// GroupActivity for shared course playing
struct GroupCourseActivity: GroupActivity {
    static let activityIdentifier = "com.parkourpathways.groupcourse"

    let courseData: CourseData
    let metadata: GroupActivityMetadata

    init(courseData: CourseData) {
        self.courseData = courseData

        var metadata = GroupActivityMetadata()
        metadata.type = .generic
        metadata.title = "Parkour: \(courseData.name)"
        metadata.subtitle = "Difficulty: \(courseData.difficulty.rawValue.capitalized)"
        metadata.previewImage = nil // Could add course thumbnail
        metadata.fallbackURL = URL(string: "https://parkourpathways.app/course/\(courseData.id)")

        self.metadata = metadata
    }
}

/// Manages SharePlay sessions using GroupActivities framework
@MainActor
class SharePlaySession: ObservableObject {

    // MARK: - Published Properties

    @Published var isActive: Bool = false
    @Published var connectedParticipants: [Participant] = []
    @Published var currentActivity: GroupCourseActivity?

    // MARK: - Properties

    private var groupSession: GroupSession<GroupCourseActivity>?
    private var messenger: GroupSessionMessenger?
    private var tasks = Set<Task<Void, Never>>()
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    init() {
        setupActivityListener()
    }

    // MARK: - Setup

    private func setupActivityListener() {
        // Listen for incoming GroupActivity sessions
        Task {
            for await session in GroupCourseActivity.sessions() {
                await configureGroupSession(session)
            }
        }
    }

    // MARK: - Public API

    /// Start a new SharePlay session
    func startSession(activity: GroupCourseActivity) async throws {
        // Activate the activity
        switch await activity.prepareForActivation() {
        case .activationPreferred:
            do {
                _ = try await activity.activate()
                currentActivity = activity
            } catch {
                throw SharePlayError.activationFailed(error)
            }

        case .activationDisabled:
            throw SharePlayError.sharePlayDisabled

        case .cancelled:
            throw SharePlayError.userCancelled

        @unknown default:
            throw SharePlayError.unknownError
        }
    }

    /// Join an existing session
    func joinSession() async throws {
        // Session will be received through the activity listener
        // This is called when user explicitly wants to join
        isActive = true
    }

    /// Leave the current session
    func leaveSession() async {
        groupSession?.leave()
        cleanup()
    }

    /// Invite specific participants
    func inviteParticipants(_ participantIds: [UUID]) async throws {
        // Note: SharePlay automatically handles invitations through FaceTime
        // This method is a placeholder for future explicit invitation features
        print("Inviting participants: \(participantIds)")
    }

    /// Send message to all participants
    func sendMessage<T: Codable>(_ message: T) async throws {
        guard let messenger = messenger else {
            throw SharePlayError.noActiveSession
        }

        try await messenger.send(message)
    }

    /// Receive messages from participants
    func receiveMessages<T: Codable>(ofType type: T.Type) -> AsyncStream<T> {
        guard let messenger = messenger else {
            return AsyncStream { _ in }
        }

        return AsyncStream { continuation in
            let task = Task {
                do {
                    for try await message in messenger.messages(of: type) {
                        continuation.yield(message.0) // First element is the message
                    }
                } catch {
                    print("Error receiving messages: \(error)")
                }
                continuation.finish()
            }

            tasks.insert(task)
        }
    }

    // MARK: - Private Session Management

    private func configureGroupSession(_ session: GroupSession<GroupCourseActivity>) async {
        self.groupSession = session
        self.currentActivity = session.activity
        self.messenger = GroupSessionMessenger(session: session)

        // Observe session state
        session.$state
            .sink { [weak self] state in
                self?.handleSessionStateChanged(state)
            }
            .store(in: &cancellables)

        // Observe participants
        session.$activeParticipants
            .sink { [weak self] participants in
                self?.handleParticipantsChanged(participants)
            }
            .store(in: &cancellables)

        // Join the session
        session.join()
        isActive = true
    }

    private func handleSessionStateChanged(_ state: GroupSession<GroupCourseActivity>.State) {
        switch state {
        case .waiting:
            print("Session waiting")
            isActive = false

        case .joined:
            print("Session joined")
            isActive = true

        case .invalidated(let reason):
            print("Session invalidated: \(reason)")
            cleanup()

        @unknown default:
            print("Unknown session state")
        }
    }

    private func handleParticipantsChanged(_ participants: Set<GroupSession<GroupCourseActivity>.Participant>) {
        connectedParticipants = participants.map { participant in
            Participant(
                id: participant.id,
                username: "Player \(String(participant.id.uuidString.prefix(4)))" // Would fetch real name
            )
        }
    }

    private func cleanup() {
        isActive = false
        connectedParticipants.removeAll()
        currentActivity = nil
        groupSession = nil
        messenger = nil

        // Cancel all tasks
        tasks.forEach { $0.cancel() }
        tasks.removeAll()

        cancellables.removeAll()
    }
}

// MARK: - Supporting Types

enum SharePlayError: Error {
    case sharePlayDisabled
    case activationFailed(Error)
    case userCancelled
    case noActiveSession
    case unknownError
}

extension GroupSession.Participant {
    var id: UUID {
        // Convert participant ID to UUID
        // In real implementation, would use proper participant identification
        return UUID(uuidString: "\(self.hashValue)".padding(toLength: 36, withPad: "0", startingAt: 0)) ?? UUID()
    }
}
