# Collaboration Architecture

## Overview

This document defines the real-time collaboration system for Spatial Screenplay Workshop, enabling multiple writers to work together in a shared spatial environment with live updates, conflict resolution, and voice communication.

## Collaboration Goals

1. **Real-time synchronization**: Changes appear within 2 seconds
2. **Conflict resolution**: Gracefully handle concurrent edits
3. **Presence awareness**: See where collaborators are looking/working
4. **Voice communication**: Spatial audio for discussions
5. **Permissions**: Role-based access control
6. **Offline support**: Work offline, sync when online

## Architecture Overview

```
┌─────────────────────────────────────────────────────┐
│                   Client A (Host)                    │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐         │
│  │   App    │→ │  Collab  │→ │  Sync    │         │
│  │   State  │  │  Engine  │  │  Service │         │
│  └──────────┘  └──────────┘  └────┬─────┘         │
└────────────────────────────────────┼───────────────┘
                                     │
                    ┌────────────────┼────────────────┐
                    │    CloudKit Shared Database     │
                    │    + Realtime Subscriptions     │
                    └────────────────┬────────────────┘
                                     │
┌────────────────────────────────────┼───────────────┐
│                   Client B (Collaborator)           │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐         │
│  │  Sync    │→ │  Collab  │→ │   App    │         │
│  │  Service │  │  Engine  │  │   State  │         │
│  └──────────┘  └──────────┘  └──────────┘         │
└─────────────────────────────────────────────────────┘
```

## Collaboration Engine

### Core Components

```swift
@Observable
class CollaborationEngine {
    // Dependencies
    private let syncService: SyncService
    private let conflictResolver: ConflictResolver
    private let presenceManager: PresenceManager
    private let voiceChatService: VoiceChatService

    // State
    var session: CollaborationSession?
    var collaborators: [Collaborator] = []
    var presenceInfo: [UUID: PresenceInfo] = [:]
    var pendingChanges: [Change] = []

    // Public API
    func startSession(projectId: UUID, role: CollaboratorRole)
    func inviteCollaborator(email: String, role: CollaboratorRole)
    func broadcastChange(_ change: Change)
    func updatePresence(_ info: PresenceInfo)
    func sendComment(_ text: String, sceneId: UUID)
}
```

### Collaboration Session

```swift
struct CollaborationSession: Codable, Identifiable {
    let id: UUID
    let projectId: UUID
    let hostId: UUID
    var participants: [Participant]
    var createdAt: Date
    var isActive: Bool

    struct Participant: Codable, Identifiable {
        let id: UUID
        let userId: String  // CloudKit user ID
        let name: String
        let role: CollaboratorRole
        let joinedAt: Date
        var isOnline: Bool
    }
}

enum CollaboratorRole: String, Codable {
    case owner      // Full control
    case coWriter   // Edit all scenes
    case editor     // Edit + comment
    case viewer     // View only
}
```

## Synchronization Strategy

### Change-Based Sync (CRDT-Inspired)

Instead of syncing entire documents, we sync atomic changes.

```swift
struct Change: Codable, Identifiable {
    let id: UUID
    let timestamp: Date
    let authorId: UUID
    let projectId: UUID
    let operation: Operation
    let vectorClock: VectorClock  // For ordering

    enum Operation: Codable {
        case insertScene(scene: Scene, at: Int)
        case deleteScene(sceneId: UUID)
        case updateScene(sceneId: UUID, patch: ScenePatch)
        case moveScene(sceneId: UUID, from: Int, to: Int)
        case insertElement(sceneId: UUID, element: ScriptElement, at: Int)
        case deleteElement(sceneId: UUID, elementId: UUID)
        case updateElement(sceneId: UUID, elementId: UUID, patch: ElementPatch)
    }
}
```

### Vector Clock

For ordering concurrent operations:

```swift
struct VectorClock: Codable, Hashable {
    private var clock: [UUID: Int]  // UserID → Counter

    mutating func increment(for userId: UUID) {
        clock[userId, default: 0] += 1
    }

    func happensBefore(_ other: VectorClock) -> Bool {
        var lessThanOrEqual = true
        var strictlyLess = false

        for (userId, count) in clock {
            let otherCount = other.clock[userId, default: 0]
            if count > otherCount {
                return false
            }
            if count < otherCount {
                strictlyLess = true
            }
        }

        return strictlyLess || clock.count < other.clock.count
    }

    func isConcurrent(with other: VectorClock) -> Bool {
        return !self.happensBefore(other) && !other.happensBefore(self)
    }
}
```

### Operational Transformation (OT)

For text editing within script elements:

```swift
protocol Operation {
    func transform(against: Operation) -> Operation
}

struct InsertTextOp: Operation {
    let position: Int
    let text: String

    func transform(against other: Operation) -> Operation {
        if let otherInsert = other as? InsertTextOp {
            if otherInsert.position <= position {
                // Adjust position
                return InsertTextOp(
                    position: position + otherInsert.text.count,
                    text: text
                )
            }
        } else if let otherDelete = other as? DeleteTextOp {
            if otherDelete.position < position {
                return InsertTextOp(
                    position: position - otherDelete.length,
                    text: text
                )
            }
        }
        return self
    }
}

struct DeleteTextOp: Operation {
    let position: Int
    let length: Int

    func transform(against other: Operation) -> Operation {
        // Similar transformation logic
        // ...
    }
}
```

## Conflict Resolution

### Conflict Types

```swift
enum ConflictType {
    case concurrentSceneEdit      // Two users editing same scene
    case sceneOrderConflict       // Two users reordering scenes
    case deleteEditConflict       // One deletes, one edits
    case characterConflict        // Character changes conflict
}
```

### Resolution Strategies

```swift
class ConflictResolver {
    func resolve(_ conflict: Conflict) -> Resolution {
        switch conflict.type {
        case .concurrentSceneEdit:
            return resolveConcurrentEdit(conflict)

        case .sceneOrderConflict:
            return resolveOrderConflict(conflict)

        case .deleteEditConflict:
            return resolveDeleteEdit(conflict)

        case .characterConflict:
            return resolveCharacterConflict(conflict)
        }
    }

    private func resolveConcurrentEdit(_ conflict: Conflict) -> Resolution {
        // Strategy: Merge at element level
        let changeA = conflict.changeA
        let changeB = conflict.changeB

        // If editing different elements in same scene → merge both
        if changeA.elementId != changeB.elementId {
            return .merge(changes: [changeA, changeB])
        }

        // If editing same element → last-write-wins with notification
        if changeA.timestamp > changeB.timestamp {
            return .acceptA(notifyB: true)
        } else {
            return .acceptB(notifyA: true)
        }
    }

    private func resolveOrderConflict(_ conflict: Conflict) -> Resolution {
        // Strategy: Latest timestamp wins, notify others
        return conflict.changeA.timestamp > conflict.changeB.timestamp
            ? .acceptA(notifyB: true)
            : .acceptB(notifyA: true)
    }

    private func resolveDeleteEdit(_ conflict: Conflict) -> Resolution {
        // Strategy: Delete wins (destructive operation takes precedence)
        // But save edited version in history
        return .acceptDelete(saveEditToHistory: true)
    }
}

enum Resolution {
    case acceptA(notifyB: Bool)
    case acceptB(notifyA: Bool)
    case merge(changes: [Change])
    case acceptDelete(saveEditToHistory: Bool)
    case promptUser  // Show UI to let user choose
}
```

### Conflict Notification

```swift
struct ConflictNotification: Identifiable {
    let id: UUID
    let type: ConflictType
    let message: String
    let actions: [ConflictAction]

    struct ConflictAction {
        let title: String
        let handler: () -> Void
    }
}

// Example usage:
let notification = ConflictNotification(
    id: UUID(),
    type: .concurrentSceneEdit,
    message: "Jane edited Scene 7 while you were editing it. Your changes were preserved.",
    actions: [
        ConflictAction(title: "View Changes", handler: { showDiff() }),
        ConflictAction(title: "Dismiss", handler: { dismiss() })
    ]
)
```

## Presence System

### Presence Information

```swift
struct PresenceInfo: Codable {
    let userId: UUID
    var isOnline: Bool
    var lastSeen: Date
    var currentActivity: Activity
    var spatialPosition: SpatialCoordinates?
    var gazeTarget: UUID?  // Scene card or element being looked at

    enum Activity: Codable {
        case viewingTimeline
        case editingScene(sceneId: UUID)
        case performingDialogue(sceneId: UUID)
        case scoutingLocation(locationId: UUID)
        case idle
    }
}
```

### Presence Manager

```swift
@Observable
class PresenceManager {
    var presenceInfo: [UUID: PresenceInfo] = [:]
    private var heartbeatTimer: Timer?

    func startBroadcasting() {
        // Broadcast presence every 5 seconds
        heartbeatTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
            self.broadcastPresence()
        }
    }

    func updateActivity(_ activity: PresenceInfo.Activity) {
        var myPresence = presenceInfo[currentUserId]!
        myPresence.currentActivity = activity
        myPresence.lastSeen = Date()
        broadcastPresence()
    }

    func updateGaze(target: UUID?) {
        var myPresence = presenceInfo[currentUserId]!
        myPresence.gazeTarget = target
        // High-frequency update, throttle to 10 Hz
        throttledBroadcast()
    }

    private func broadcastPresence() {
        let myPresence = presenceInfo[currentUserId]!
        syncService.broadcast(.presenceUpdate(myPresence))
    }
}
```

### Visualizing Presence

**Timeline View**:
```swift
// Show avatar above scene card being edited
struct SceneCardView: View {
    let scene: Scene
    let collaborators: [Collaborator]

    var body: some View {
        ZStack {
            SceneCard(scene: scene)

            // Show who's editing
            if let editor = collaborators.first(where: {
                $0.presenceInfo?.currentActivity == .editingScene(sceneId: scene.id)
            }) {
                CollaboratorAvatar(editor)
                    .offset(y: -100)
            }
        }
    }
}
```

**Editor View**:
```swift
// Show cursor/selection of other editors
struct CollaboratorCursor: View {
    let collaborator: Collaborator
    let position: CGPoint

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: "arrowtriangle.up.fill")
                .foregroundColor(collaborator.color)
            Text(collaborator.name)
                .font(.caption)
                .padding(4)
                .background(collaborator.color)
                .cornerRadius(4)
        }
        .position(position)
    }
}
```

## Voice Communication

### Voice Chat Service

```swift
protocol VoiceChatService {
    func startVoiceChat(sessionId: UUID) async throws
    func stopVoiceChat()
    func muteUser(_ userId: UUID)
    func setSpatialPosition(_ position: SIMD3<Float>, for userId: UUID)
}
```

### Implementation Options

#### Option A: GroupActivities (SharePlay)

```swift
import GroupActivities

struct ScreenplaySession: GroupActivity {
    let projectId: UUID
    var metadata: GroupActivityMetadata {
        var metadata = GroupActivityMetadata()
        metadata.title = "Screenplay Collaboration"
        metadata.type = .generic
        return metadata
    }
}

class SharePlayVoiceService: VoiceChatService {
    private var session: GroupSession<ScreenplaySession>?
    private var messenger: GroupSessionMessenger?

    func startVoiceChat(sessionId: UUID) async throws {
        let activity = ScreenplaySession(projectId: sessionId)

        // Activate group session
        switch await activity.prepareForActivation() {
        case .activationPreferred:
            try await activity.activate()
        case .activationDisabled:
            throw VoiceError.activationDisabled
        case .cancelled:
            throw VoiceError.cancelled
        }

        // Join session
        for await session in ScreenplaySession.sessions() {
            self.session = session
            self.messenger = GroupSessionMessenger(session: session)
            session.join()
            break
        }
    }
}
```

#### Option B: Custom WebRTC

```swift
import WebRTC

class WebRTCVoiceService: VoiceChatService {
    private var peerConnections: [UUID: RTCPeerConnection] = [:]
    private let audioSession = AVAudioSession.sharedInstance()

    func startVoiceChat(sessionId: UUID) async throws {
        // Configure audio session
        try audioSession.setCategory(.playAndRecord, mode: .voiceChat)
        try audioSession.setActive(true)

        // Create peer connections for each participant
        for participant in session.participants {
            let peerConnection = createPeerConnection(for: participant.id)
            peerConnections[participant.id] = peerConnection
        }

        // Start signaling
        await exchangeSDPs()
    }

    func setSpatialPosition(_ position: SIMD3<Float>, for userId: UUID) {
        // Adjust audio parameters based on position
        guard let connection = peerConnections[userId] else { return }

        // Calculate distance and angle
        let distance = length(position)
        let angle = atan2(position.x, position.z)

        // Apply spatial audio effects
        applySpatialAudio(to: connection, distance: distance, angle: angle)
    }

    private func applySpatialAudio(
        to connection: RTCPeerConnection,
        distance: Float,
        angle: Float
    ) {
        // Adjust volume based on distance (inverse square law)
        let volume = 1.0 / max(distance, 1.0)

        // Apply stereo panning based on angle
        let pan = sin(angle)

        // Apply to audio track
        if let audioTrack = connection.transceivers.first?.receiver.track as? RTCAudioTrack {
            audioTrack.volume = Double(volume)
            // Note: Pan would require audio processing
        }
    }
}
```

### Spatial Audio Configuration

```swift
struct SpatialAudioConfig {
    var maxAudibleDistance: Float = 10.0  // meters
    var volumeFalloff: Float = 2.0        // inverse square
    var enableReverb: Bool = true
    var enableOcclusion: Bool = false      // blocked by virtual objects
}

func calculateAudioLevel(
    listenerPos: SIMD3<Float>,
    speakerPos: SIMD3<Float>,
    config: SpatialAudioConfig
) -> Float {
    let distance = distance(listenerPos, speakerPos)

    if distance > config.maxAudibleDistance {
        return 0.0
    }

    // Inverse square law
    let attenuation = 1.0 / pow(max(distance, 1.0), config.volumeFalloff)

    return attenuation
}
```

## Sync Service

### CloudKit Realtime Sync

```swift
class CloudKitSyncService: SyncService {
    private let database: CKDatabase
    private var subscription: CKDatabaseSubscription?
    private let changeProcessor = ChangeProcessor()

    func startSync(projectId: UUID) async throws {
        // Subscribe to changes
        subscription = createSubscription(for: projectId)
        try await database.save(subscription!)

        // Start listening for notifications
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleRemoteNotification),
            name: .CKAccountChanged,
            object: nil
        )

        // Initial fetch
        try await fetchChanges(since: nil)

        // Start periodic sync
        startPeriodicSync()
    }

    func broadcast(_ change: Change) {
        Task {
            // Save to CloudKit
            let record = changeToRecord(change)
            try await database.save(record)

            // Update local state immediately (optimistic update)
            await changeProcessor.apply(change)
        }
    }

    private func createSubscription(for projectId: UUID) -> CKDatabaseSubscription {
        let subscription = CKDatabaseSubscription(
            subscriptionID: "project-\(projectId)"
        )

        let notificationInfo = CKSubscription.NotificationInfo()
        notificationInfo.shouldSendContentAvailable = true
        subscription.notificationInfo = notificationInfo

        return subscription
    }

    @objc private func handleRemoteNotification(_ notification: Notification) {
        Task {
            try await fetchChanges(since: lastSyncDate)
        }
    }

    private func fetchChanges(since date: Date?) async throws {
        let predicate = date != nil
            ? NSPredicate(format: "modificationDate > %@", date! as CVarArg)
            : NSPredicate(value: true)

        let query = CKQuery(recordType: "Change", predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]

        let results = try await database.records(matching: query)

        for result in results {
            let change = recordToChange(result)
            await changeProcessor.apply(change)
        }

        lastSyncDate = Date()
    }

    private func startPeriodicSync() {
        Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { _ in
            Task {
                try? await self.fetchChanges(since: self.lastSyncDate)
            }
        }
    }
}
```

### Change Processor

```swift
actor ChangeProcessor {
    private var appliedChanges: Set<UUID> = []
    private var pendingChanges: [Change] = []

    func apply(_ change: Change) async {
        // Avoid duplicate application
        guard !appliedChanges.contains(change.id) else { return }

        // Check for conflicts
        let conflicts = detectConflicts(change)

        if conflicts.isEmpty {
            // Apply directly
            await applyChange(change)
            appliedChanges.insert(change.id)
        } else {
            // Resolve conflicts first
            let resolution = conflictResolver.resolve(conflicts.first!)
            await applyResolution(resolution)
        }
    }

    private func applyChange(_ change: Change) async {
        switch change.operation {
        case .insertScene(let scene, let index):
            await MainActor.run {
                projectViewModel.insertScene(scene, at: index)
            }

        case .deleteScene(let sceneId):
            await MainActor.run {
                projectViewModel.deleteScene(id: sceneId)
            }

        case .updateScene(let sceneId, let patch):
            await MainActor.run {
                projectViewModel.updateScene(id: sceneId, with: patch)
            }

        case .moveScene(let sceneId, let from, let to):
            await MainActor.run {
                projectViewModel.moveScene(id: sceneId, from: from, to: to)
            }

        // ... other operations
        }
    }

    private func detectConflicts(_ change: Change) -> [Conflict] {
        var conflicts: [Conflict] = []

        for pending in pendingChanges {
            if pending.isConcurrent(with: change) &&
               pending.affectsSameEntity(as: change) {
                conflicts.append(Conflict(changeA: pending, changeB: change))
            }
        }

        return conflicts
    }
}
```

## Permissions & Security

### Permission Checks

```swift
class PermissionManager {
    func canPerformAction(
        _ action: Action,
        user: Collaborator,
        project: Project
    ) -> Bool {
        switch action {
        case .editScene:
            return user.permissions.canEdit

        case .deleteScene:
            return user.permissions.canEdit && user.role != .viewer

        case .inviteCollaborator:
            return user.permissions.canInviteOthers

        case .changeSettings:
            return user.permissions.canManageSettings

        case .export:
            return user.permissions.canExport

        case .addComment:
            return true  // All roles can comment

        default:
            return user.role == .owner
        }
    }
}

enum Action {
    case editScene
    case deleteScene
    case inviteCollaborator
    case changeSettings
    case export
    case addComment
}
```

### Invitation System

```swift
class InvitationManager {
    func invite(
        email: String,
        to projectId: UUID,
        role: CollaboratorRole
    ) async throws {
        // Lookup user by email
        let userID = try await lookupUserByEmail(email)

        // Create invitation
        let invitation = Invitation(
            id: UUID(),
            projectId: projectId,
            invitedUserId: userID,
            inviterUserId: currentUserId,
            role: role,
            status: .pending,
            createdAt: Date(),
            expiresAt: Date().addingTimeInterval(7 * 24 * 60 * 60)  // 7 days
        )

        // Save invitation
        try await saveInvitation(invitation)

        // Send notification
        try await sendInvitationNotification(invitation, to: email)
    }

    func acceptInvitation(_ invitationId: UUID) async throws {
        let invitation = try await fetchInvitation(invitationId)

        guard invitation.status == .pending else {
            throw InvitationError.alreadyProcessed
        }

        guard invitation.expiresAt > Date() else {
            throw InvitationError.expired
        }

        // Add user to project
        try await addCollaborator(
            userId: invitation.invitedUserId,
            projectId: invitation.projectId,
            role: invitation.role
        )

        // Update invitation status
        var updatedInvitation = invitation
        updatedInvitation.status = .accepted
        try await saveInvitation(updatedInvitation)
    }
}

struct Invitation: Codable, Identifiable {
    let id: UUID
    let projectId: UUID
    let invitedUserId: String
    let inviterUserId: String
    let role: CollaboratorRole
    var status: InvitationStatus
    let createdAt: Date
    let expiresAt: Date
}

enum InvitationStatus: String, Codable {
    case pending
    case accepted
    case declined
    case expired
}
```

## Offline Support

### Offline Queue

```swift
actor OfflineQueue {
    private var queue: [Change] = []

    func enqueue(_ change: Change) {
        queue.append(change)
        saveToStorage()
    }

    func dequeueAll() -> [Change] {
        let changes = queue
        queue.removeAll()
        saveToStorage()
        return changes
    }

    func syncWhenOnline() async {
        guard NetworkMonitor.shared.isConnected else { return }

        let changes = dequeueAll()

        for change in changes {
            do {
                try await syncService.broadcast(change)
            } catch {
                // Re-queue on failure
                enqueue(change)
            }
        }
    }

    private func saveToStorage() {
        // Persist queue to disk
        let data = try? JSONEncoder().encode(queue)
        UserDefaults.standard.set(data, forKey: "offlineQueue")
    }
}
```

### Network Monitor

```swift
import Network

class NetworkMonitor: ObservableObject {
    static let shared = NetworkMonitor()

    @Published var isConnected = true
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")

    init() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied
            }
        }
        monitor.start(queue: queue)
    }
}
```

## Performance Optimization

### Throttling & Debouncing

```swift
actor Throttler {
    private var lastExecutionTime: Date?
    private let interval: TimeInterval

    init(interval: TimeInterval) {
        self.interval = interval
    }

    func execute(_ block: () async -> Void) async {
        let now = Date()

        if let last = lastExecutionTime {
            let elapsed = now.timeIntervalSince(last)
            if elapsed < interval {
                return  // Skip execution
            }
        }

        lastExecutionTime = now
        await block()
    }
}

// Usage:
let presenceThrottler = Throttler(interval: 0.1)  // 10 Hz max

func updateGaze(target: UUID?) {
    Task {
        await presenceThrottler.execute {
            await presenceManager.updateGaze(target: target)
        }
    }
}
```

### Batching

```swift
actor ChangeBatcher {
    private var batch: [Change] = []
    private var batchTimer: Task<Void, Never>?

    func add(_ change: Change) {
        batch.append(change)

        // Start timer if not already running
        if batchTimer == nil {
            batchTimer = Task {
                try? await Task.sleep(nanoseconds: 500_000_000)  // 500ms
                await flush()
            }
        }
    }

    private func flush() {
        guard !batch.isEmpty else { return }

        let changes = batch
        batch.removeAll()
        batchTimer = nil

        // Send batched changes
        Task {
            try? await syncService.broadcastBatch(changes)
        }
    }
}
```

## Testing Strategy

### Unit Tests

```swift
class ConflictResolverTests: XCTestCase {
    func testConcurrentEditResolution() {
        let changeA = Change(
            operation: .updateScene(sceneId: testSceneId, patch: patchA),
            timestamp: Date(),
            vectorClock: vectorClockA
        )

        let changeB = Change(
            operation: .updateScene(sceneId: testSceneId, patch: patchB),
            timestamp: Date().addingTimeInterval(1),
            vectorClock: vectorClockB
        )

        let conflict = Conflict(changeA: changeA, changeB: changeB)
        let resolution = resolver.resolve(conflict)

        XCTAssertEqual(resolution, .acceptB(notifyA: true))
    }
}
```

### Integration Tests

```swift
class CollaborationIntegrationTests: XCTestCase {
    func testRealTimeSync() async throws {
        // Setup two clients
        let clientA = CollaborationEngine(userId: userA)
        let clientB = CollaborationEngine(userId: userB)

        // Client A makes change
        let change = Change(operation: .insertScene(scene, at: 0))
        await clientA.broadcastChange(change)

        // Wait for sync
        try await Task.sleep(nanoseconds: 3_000_000_000)

        // Client B should receive change
        let clientBScenes = await clientB.projectViewModel.project.scenes
        XCTAssertEqual(clientBScenes.first?.id, scene.id)
    }
}
```

---

**Document Version**: 1.0
**Last Updated**: 2025-11-24
**Author**: Collaboration Architecture Team
