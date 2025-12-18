# Collaboration Protocol Specification

## Document Information
- **Version**: 1.0
- **Last Updated**: 2025-11-24
- **Status**: Draft
- **Owner**: Engineering Team

## 1. Overview

This document specifies the real-time collaboration protocol for multi-user code review sessions using SharePlay and custom synchronization.

## 2. Session Architecture

### 2.1 Session Lifecycle

```swift
enum SessionState {
    case idle
    case creating
    case active
    case paused
    case ending
    case ended
}

class CollaborationSession {
    let id: UUID
    var state: SessionState
    var participants: [Participant]
    var host: Participant
    var repository: Repository
    var branch: String

    // SharePlay group session
    var groupSession: GroupSession<CodeReviewActivity>?
}
```

### 2.2 SharePlay Integration

```swift
struct CodeReviewActivity: GroupActivity {
    let repositoryURL: URL
    let branchName: String
    let sessionID: UUID

    var metadata: GroupActivityMetadata {
        var metadata = GroupActivityMetadata()
        metadata.title = "Code Review Session"
        metadata.subtitle = repositoryURL.lastPathComponent
        metadata.previewImage = generatePreviewImage()
        metadata.type = .generic
        return metadata
    }
}

class SharePlayManager: ObservableObject {
    @Published var session: GroupSession<CodeReviewActivity>?
    @Published var participants: Set<Participant> = []

    private var messenger: GroupSessionMessenger?
    private var tasks = Set<Task<Void, Never>>()

    func startSession(activity: CodeReviewActivity) async throws {
        // Prepare to start session
        let prepareResult = try await activity.prepareForActivation()

        switch prepareResult {
        case .activationPreferred:
            do {
                _ = try await activity.activate()
            } catch {
                print("Failed to activate: \(error)")
            }

        case .activationDisabled:
            print("SharePlay is disabled")

        case .cancelled:
            print("User cancelled")

        @unknown default:
            break
        }
    }

    func configureSession(_ session: GroupSession<CodeReviewActivity>) {
        self.session = session
        self.messenger = GroupSessionMessenger(session: session)

        let task = Task {
            for await participant in session.$activeParticipants.values {
                self.participants = participant
            }
        }
        tasks.insert(task)

        session.join()

        // Start listening for messages
        startListeningForMessages()
    }
}
```

## 3. Message Protocol

### 3.1 Message Types

```swift
enum CollaborationMessage: Codable {
    case participantJoined(ParticipantInfo)
    case participantLeft(UUID)
    case participantPositionUpdate(UUID, Transform)
    case participantGazeUpdate(UUID, SIMD3<Float>)

    case fileOpened(String, Transform)
    case fileClosed(String)
    case fileRepositioned(String, Transform)

    case codeWindowScroll(String, Float)
    case layoutChanged(LayoutType)

    case commentAdded(Comment)
    case commentUpdated(Comment)
    case commentDeleted(UUID)

    case dependencyHighlighted([UUID])
    case issueSelected(String)

    case gitCommitChanged(String) // Commit SHA

    case cursorPosition(UUID, String, Int) // participant, file, line
}

struct ParticipantInfo: Codable {
    let id: UUID
    let name: String
    let avatarURL: URL?
    let isHost: Bool
}
```

### 3.2 Message Sending

```swift
class MessageSender {
    private let messenger: GroupSessionMessenger

    func send(_ message: CollaborationMessage) async throws {
        let data = try JSONEncoder().encode(message)

        try await messenger.send(
            data,
            to: .all,
            reliability: .reliable
        )
    }

    func sendReliable(_ message: CollaborationMessage) async throws {
        try await send(message)
    }

    func sendUnreliable(_ message: CollaborationMessage) async throws {
        let data = try JSONEncoder().encode(message)

        try await messenger.send(
            data,
            to: .all,
            reliability: .unreliable
        )
    }
}
```

### 3.3 Message Receiving

```swift
class MessageReceiver {
    private let messenger: GroupSessionMessenger
    private let handler: MessageHandler

    func startListening() {
        Task {
            for await (message, context) in messenger.messages(of: Data.self) {
                handleMessage(message, from: context.source)
            }
        }
    }

    private func handleMessage(_ data: Data, from source: Participant.ID) {
        do {
            let message = try JSONDecoder().decode(CollaborationMessage.self, from: data)
            await handler.handle(message, from: source)
        } catch {
            print("Failed to decode message: \(error)")
        }
    }
}

@MainActor
class MessageHandler {
    private let spatialManager: SpatialManager
    private let collaborationManager: CollaborationManager

    func handle(_ message: CollaborationMessage, from source: Participant.ID) {
        switch message {
        case .participantJoined(let info):
            collaborationManager.addParticipant(info)

        case .participantPositionUpdate(let id, let transform):
            collaborationManager.updateParticipantPosition(id, transform: transform)

        case .fileOpened(let path, let transform):
            spatialManager.openFile(path, at: transform)

        case .layoutChanged(let layout):
            spatialManager.transitionToLayout(layout)

        case .commentAdded(let comment):
            collaborationManager.addComment(comment)

        // ... handle other message types
        default:
            break
        }
    }
}
```

## 4. State Synchronization

### 4.1 Session State

```swift
struct SessionState: Codable {
    let sessionID: UUID
    let repositoryURL: URL
    let branch: String
    let commit: String

    var openFiles: [FileState]
    var layout: LayoutType
    var cameraPosition: Transform?

    struct FileState: Codable {
        let path: String
        let position: Transform
        let scrollOffset: Float
        let isVisible: Bool
    }
}

class StateSynchronizer {
    private let cloudKitService: SyncService
    private var lastSync: Date?

    func syncState(_ state: SessionState) async throws {
        try await cloudKitService.syncSessionState(state)
        lastSync = Date()
    }

    func fetchLatestState() async throws -> SessionState {
        return try await cloudKitService.fetchLatestSessionState()
    }

    func startPeriodicSync(interval: TimeInterval = 5.0) {
        Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            Task {
                try await self?.syncState(self?.getCurrentState() ?? SessionState())
            }
        }
    }
}
```

### 4.2 Conflict Resolution

```swift
class ConflictResolver {
    func resolveConflict(
        local: SessionState,
        remote: SessionState
    ) -> SessionState {
        var resolved = local

        // Host wins for layout decisions
        if remote.layout != local.layout {
            resolved.layout = remote.layout // Always use remote
        }

        // Merge open files
        var fileMap: [String: SessionState.FileState] = [:]

        for file in local.openFiles {
            fileMap[file.path] = file
        }

        for file in remote.openFiles {
            // Remote takes precedence for new files
            if fileMap[file.path] == nil {
                fileMap[file.path] = file
            } else {
                // Keep more recent update (would need timestamps)
                fileMap[file.path] = file
            }
        }

        resolved.openFiles = Array(fileMap.values)

        return resolved
    }
}
```

## 5. Spatial Audio

### 5.1 Audio Configuration

```swift
class SpatialAudioManager {
    private let audioEngine = AVAudioEngine()
    private let environmentNode = AVAudioEnvironmentNode()

    func setupSpatialAudio() {
        audioEngine.attach(environmentNode)

        let mixer = audioEngine.mainMixerNode
        audioEngine.connect(environmentNode, to: mixer, format: nil)

        // Configure spatial rendering
        environmentNode.renderingAlgorithm = .HRTF
        environmentNode.distanceAttenuationParameters.maximumDistance = 10.0

        do {
            try audioEngine.start()
        } catch {
            print("Failed to start audio engine: \(error)")
        }
    }

    func addParticipantAudioSource(
        _ participant: Participant,
        at position: SIMD3<Float>
    ) -> AVAudioPlayerNode {
        let player = AVAudioPlayerNode()
        audioEngine.attach(player)

        // Connect to environment node for spatialization
        audioEngine.connect(player, to: environmentNode, format: nil)

        // Set position
        environmentNode.listenerPosition = AVAudio3DPoint(x: 0, y: 0, z: 0)
        player.position = AVAudio3DPoint(
            x: position.x,
            y: position.y,
            z: position.z
        )

        player.play()

        return player
    }

    func updateParticipantPosition(
        _ player: AVAudioPlayerNode,
        position: SIMD3<Float>
    ) {
        player.position = AVAudio3DPoint(
            x: position.x,
            y: position.y,
            z: position.z
        )
    }
}
```

## 6. Network Optimization

### 6.1 Message Throttling

```swift
class MessageThrottler {
    private var lastSent: [String: Date] = [:]
    private let minimumInterval: TimeInterval = 0.05 // 20 Hz

    func shouldSend(_ messageType: String) -> Bool {
        let now = Date()

        if let last = lastSent[messageType] {
            if now.timeIntervalSince(last) < minimumInterval {
                return false
            }
        }

        lastSent[messageType] = now
        return true
    }
}
```

### 6.2 Bandwidth Management

```swift
class BandwidthManager {
    private var bytesSent: Int = 0
    private var resetTime: Date = Date()
    private let maxBytesPerSecond = 100_000 // 100 KB/s

    func canSend(_ dataSize: Int) -> Bool {
        let now = Date()

        // Reset counter every second
        if now.timeIntervalSince(resetTime) > 1.0 {
            bytesSent = 0
            resetTime = now
        }

        if bytesSent + dataSize > maxBytesPerSecond {
            return false
        }

        bytesSent += dataSize
        return true
    }
}
```

## 7. Performance Targets

| Metric | Target | Max Acceptable |
|--------|--------|----------------|
| Message latency | < 50ms | < 100ms |
| State sync frequency | 5s | 10s |
| Position update rate | 20 Hz | 10 Hz |
| Bandwidth per participant | < 100 KB/s | < 200 KB/s |

## 8. Security

### 8.1 End-to-End Encryption

```swift
class MessageEncryption {
    private let symmetricKey: SymmetricKey

    init() {
        // Generate shared key via SharePlay secure channel
        self.symmetricKey = SymmetricKey(size: .bits256)
    }

    func encrypt(_ data: Data) throws -> Data {
        let sealed = try AES.GCM.seal(data, using: symmetricKey)
        return sealed.combined!
    }

    func decrypt(_ data: Data) throws -> Data {
        let sealedBox = try AES.GCM.SealedBox(combined: data)
        return try AES.GCM.open(sealedBox, using: symmetricKey)
    }
}
```

## 9. Testing

### 9.1 Simulation

```swift
class CollaborationSimulator {
    func simulateParticipant() -> SimulatedParticipant {
        return SimulatedParticipant(
            id: UUID(),
            name: "Test User",
            latency: 50 // ms
        )
    }

    func simulateNetworkConditions(
        latency: TimeInterval,
        packetLoss: Double
    ) {
        // Inject artificial delays and drops
    }
}
```

## 10. References

- [System Architecture Document](./01-system-architecture.md)
- [Security Architecture Document](./10-security-architecture.md)
- Apple SharePlay Documentation
- Apple GroupActivities Framework

## 11. Revision History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2025-11-24 | Engineering Team | Initial draft |
