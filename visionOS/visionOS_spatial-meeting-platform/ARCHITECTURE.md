# Spatial Meeting Platform - Technical Architecture

## Table of Contents
1. [System Architecture Overview](#system-architecture-overview)
2. [visionOS Architecture Patterns](#visionos-architecture-patterns)
3. [Data Models & Schemas](#data-models--schemas)
4. [Service Layer Architecture](#service-layer-architecture)
5. [RealityKit & ARKit Integration](#realitykit--arkit-integration)
6. [API Design & External Integrations](#api-design--external-integrations)
7. [State Management Strategy](#state-management-strategy)
8. [Performance Optimization Strategy](#performance-optimization-strategy)
9. [Security Architecture](#security-architecture)

---

## System Architecture Overview

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                     Vision Pro Client Layer                      │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │   Windows    │  │   Volumes    │  │  Immersive   │          │
│  │  (2D UI)     │  │  (3D Bounded)│  │   Spaces     │          │
│  └──────────────┘  └──────────────┘  └──────────────┘          │
│                                                                   │
│  ┌──────────────────────────────────────────────────────┐       │
│  │           SwiftUI Presentation Layer                  │       │
│  └──────────────────────────────────────────────────────┘       │
│                                                                   │
│  ┌──────────────────────────────────────────────────────┐       │
│  │              ViewModel Layer (MVVM)                   │       │
│  │          (@Observable, Swift Concurrency)             │       │
│  └──────────────────────────────────────────────────────┘       │
│                                                                   │
│  ┌──────────────────────────────────────────────────────┐       │
│  │              Services & Business Logic                │       │
│  │  ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐        │       │
│  │  │Meeting │ │Spatial │ │   AI   │ │Network │        │       │
│  │  │Service │ │Service │ │Service │ │Service │        │       │
│  │  └────────┘ └────────┘ └────────┘ └────────┘        │       │
│  └──────────────────────────────────────────────────────┘       │
│                                                                   │
│  ┌──────────────────────────────────────────────────────┐       │
│  │      RealityKit Entity Component System (ECS)         │       │
│  │         3D Content & Spatial Rendering                │       │
│  └──────────────────────────────────────────────────────┘       │
│                                                                   │
│  ┌──────────────────────────────────────────────────────┐       │
│  │             Data Layer (SwiftData)                    │       │
│  │      Local Persistence & Cache Management             │       │
│  └──────────────────────────────────────────────────────┘       │
│                                                                   │
└─────────────────────────────────────────────────────────────────┘
                            ▲ │
                            │ │ WebRTC, WebSocket, REST
                            │ ▼
┌─────────────────────────────────────────────────────────────────┐
│                      Backend Services                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │   Signaling  │  │    Media     │  │      AI      │          │
│  │    Server    │  │   Server     │  │   Processing │          │
│  │  (WebSocket) │  │  (WebRTC)    │  │   Service    │          │
│  └──────────────┘  └──────────────┘  └──────────────┘          │
│                                                                   │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │  Recording   │  │  Analytics   │  │ Integration  │          │
│  │   Service    │  │   Service    │  │   Gateway    │          │
│  └──────────────┘  └──────────────┘  └──────────────┘          │
│                                                                   │
│  ┌──────────────────────────────────────────────────────┐       │
│  │           Database Layer (PostgreSQL)                 │       │
│  │      Users, Meetings, Sessions, Analytics             │       │
│  └──────────────────────────────────────────────────────┘       │
│                                                                   │
│  ┌──────────────────────────────────────────────────────┐       │
│  │         Object Storage (S3-compatible)                │       │
│  │    Recordings, Transcripts, Shared Content            │       │
│  └──────────────────────────────────────────────────────┘       │
│                                                                   │
└─────────────────────────────────────────────────────────────────┘
```

### Architecture Principles

1. **Spatial-First Design**: Architecture prioritizes spatial computing paradigms
2. **Progressive Enhancement**: Start with windows, expand to volumes/immersive spaces
3. **Offline-Capable**: Core features work without network connectivity
4. **Real-Time Synchronization**: Sub-150ms latency for all interactions
5. **Scalable**: Support 100 concurrent participants per meeting
6. **Secure by Default**: End-to-end encryption for all communications
7. **AI-Enhanced**: Intelligent assistance throughout user workflows

---

## visionOS Architecture Patterns

### Presentation Modes Strategy

```swift
// App Structure
@main
struct SpatialMeetingApp: App {
    @State private var appModel = AppModel()
    @State private var immersionMode: ImmersionStyle = .mixed

    var body: some Scene {
        // Primary Window - Meeting Dashboard
        WindowGroup(id: "dashboard") {
            DashboardView()
                .environment(appModel)
        }
        .windowStyle(.plain)
        .defaultSize(width: 800, height: 600)

        // Meeting Control Window
        WindowGroup(id: "meeting-controls") {
            MeetingControlsView()
                .environment(appModel)
        }
        .windowStyle(.plain)
        .defaultSize(width: 400, height: 300)

        // 3D Meeting Space Volume
        WindowGroup(id: "meeting-volume") {
            MeetingVolumeView()
                .environment(appModel)
        }
        .windowStyle(.volumetric)
        .defaultSize(width: 1.0, height: 1.0, depth: 1.0, in: .meters)

        // Full Immersive Meeting Space
        ImmersiveSpace(id: "immersive-meeting") {
            ImmersiveMeetingView()
                .environment(appModel)
        }
        .immersionStyle(selection: $immersionMode, in: .mixed, .progressive, .full)
    }
}
```

### Spatial Hierarchy

```
Meeting Experience Architecture
│
├── Windows (2D Floating Panels)
│   ├── Dashboard Window
│   │   ├── Meeting List
│   │   ├── Calendar Integration
│   │   └── Quick Join
│   │
│   ├── Control Panel Window
│   │   ├── Audio/Video Controls
│   │   ├── Participant List
│   │   └── Meeting Settings
│   │
│   └── Content Window
│       ├── Screen Shares
│       ├── Documents
│       └── Presentations
│
├── Volumes (3D Bounded Spaces)
│   ├── Meeting Room Volume
│   │   ├── Participant Avatars (3D)
│   │   ├── Shared Whiteboard
│   │   └── Floating Documents
│   │
│   ├── Collaboration Volume
│   │   ├── 3D Models
│   │   ├── Data Visualizations
│   │   └── Interactive Objects
│   │
│   └── Analytics Volume
│       ├── Real-time Metrics (3D)
│       ├── Engagement Graphs
│       └── AI Insights
│
└── Immersive Spaces (Full Environment)
    ├── Mixed Reality Mode
    │   ├── Virtual Meeting Room
    │   ├── Passthrough Background
    │   └── Spatial Anchors
    │
    ├── Progressive Mode
    │   ├── Enhanced Environment
    │   ├── Partial Passthrough
    │   └── Volumetric Content
    │
    └── Full Immersion
        ├── Custom Environments
        ├── 360° Surroundings
        └── Maximum Presence
```

### Scene Coordination Pattern

```swift
@Observable
class SceneCoordinator {
    var activeScenes: Set<String> = []
    var meetingState: MeetingState = .idle

    // Scene Management
    func presentMeetingControls() async
    func openMeetingVolume() async
    func enterImmersiveMode() async
    func exitImmersiveMode() async

    // Transition Coordination
    func transitionTo(mode: PresentationMode) async

    // State Synchronization
    func syncStateAcrossScenes()
}
```

---

## Data Models & Schemas

### Core Domain Models

```swift
// MARK: - Meeting Domain

@Model
class Meeting {
    @Attribute(.unique) var id: UUID
    var title: String
    var description: String?
    var scheduledStart: Date
    var scheduledEnd: Date
    var actualStart: Date?
    var actualEnd: Date?
    var status: MeetingStatus
    var meetingType: MeetingType
    var environment: MeetingEnvironment

    // Relationships
    @Relationship(deleteRule: .cascade) var participants: [Participant]
    @Relationship(deleteRule: .cascade) var recordings: [Recording]
    @Relationship(deleteRule: .cascade) var transcripts: [Transcript]
    @Relationship(deleteRule: .cascade) var sharedContent: [SharedContent]
    @Relationship var organizer: User

    // Metadata
    var createdAt: Date
    var updatedAt: Date
}

enum MeetingStatus: String, Codable {
    case scheduled
    case inProgress
    case completed
    case cancelled
}

enum MeetingType: String, Codable {
    case boardroom
    case innovationLab
    case auditorium
    case cafe
    case outdoor
    case custom
}

@Model
class MeetingEnvironment {
    var id: UUID
    var name: String
    var environmentType: EnvironmentType
    var capacity: Int
    var customizationData: Data? // JSON configuration
    var realityKitScene: String? // Reality Composer Pro file
}

// MARK: - Participant Domain

@Model
class Participant {
    @Attribute(.unique) var id: UUID
    var user: User
    var role: ParticipantRole
    var joinedAt: Date?
    var leftAt: Date?
    var audioEnabled: Bool
    var videoEnabled: Bool
    var spatialPosition: SpatialPosition?
    var presenceState: PresenceState

    // Engagement Metrics
    var speakingTime: TimeInterval
    var engagementScore: Double
    var interactions: Int
}

enum ParticipantRole: String, Codable {
    case organizer
    case presenter
    case participant
    case observer
}

struct SpatialPosition: Codable {
    var x: Float
    var y: Float
    var z: Float
    var rotation: simd_quatf
    var scale: Float
}

enum PresenceState: String, Codable {
    case active
    case idle
    case speaking
    case away
    case offline
}

// MARK: - User Domain

@Model
class User {
    @Attribute(.unique) var id: UUID
    var email: String
    var displayName: String
    var avatarURL: URL?
    var organization: String?
    var department: String?
    var role: String?

    // Preferences
    var preferences: UserPreferences

    // Relationships
    @Relationship var meetings: [Meeting]
}

struct UserPreferences: Codable {
    var defaultEnvironment: MeetingType
    var spatialAudioEnabled: Bool
    var handTrackingEnabled: Bool
    var eyeTrackingEnabled: Bool
    var preferredPosition: SpatialPosition?
    var accessibilitySettings: AccessibilitySettings
}

struct AccessibilitySettings: Codable {
    var voiceOverEnabled: Bool
    var largeTextEnabled: Bool
    var reduceMotionEnabled: Bool
    var highContrastEnabled: Bool
}

// MARK: - Content Domain

@Model
class SharedContent {
    @Attribute(.unique) var id: UUID
    var type: ContentType
    var title: String
    var url: URL
    var thumbnailURL: URL?
    var spatialTransform: SpatialTransform
    var sharedBy: User
    var sharedAt: Date
    var annotations: [Annotation]
}

enum ContentType: String, Codable {
    case document
    case presentation
    case image
    case video
    case model3D
    case whiteboard
    case screenShare
}

struct SpatialTransform: Codable {
    var position: SIMD3<Float>
    var rotation: simd_quatf
    var scale: SIMD3<Float>
}

@Model
class Annotation {
    var id: UUID
    var content: String
    var position: SIMD3<Float>
    var author: User
    var timestamp: Date
    var type: AnnotationType
}

enum AnnotationType: String, Codable {
    case text
    case drawing
    case voice
    case highlight
}

// MARK: - AI Domain

@Model
class Transcript {
    @Attribute(.unique) var id: UUID
    var meeting: Meeting
    var segments: [TranscriptSegment]
    var summary: String?
    var actionItems: [ActionItem]
    var decisions: [Decision]
    var generatedAt: Date
}

struct TranscriptSegment: Codable {
    var id: UUID
    var speaker: UUID // User ID
    var text: String
    var timestamp: TimeInterval
    var confidence: Double
    var language: String
}

@Model
class ActionItem {
    var id: UUID
    var description: String
    var assignedTo: User?
    var dueDate: Date?
    var status: ActionItemStatus
    var extractedAt: Date
}

enum ActionItemStatus: String, Codable {
    case pending
    case inProgress
    case completed
    case cancelled
}

@Model
class Decision {
    var id: UUID
    var description: String
    var context: String
    var participants: [User]
    var timestamp: Date
    var confidence: Double
}

// MARK: - Analytics Domain

@Model
class MeetingAnalytics {
    @Attribute(.unique) var id: UUID
    var meeting: Meeting
    var totalDuration: TimeInterval
    var participantCount: Int
    var speakingDistribution: [UUID: TimeInterval] // User ID -> Speaking time
    var engagementScore: Double
    var decisionCount: Int
    var actionItemCount: Int
    var aiInsights: [AIInsight]
}

struct AIInsight: Codable {
    var type: InsightType
    var title: String
    var description: String
    var confidence: Double
    var timestamp: Date
}

enum InsightType: String, Codable {
    case participationImbalance
    case meetingTooLong
    case lowEngagement
    case positiveEnergy
    case conflictDetected
    case consensusReached
}

// MARK: - Spatial Domain

struct SpatialScene: Codable {
    var entities: [SpatialEntity]
    var lights: [LightConfiguration]
    var materials: [MaterialConfiguration]
    var audioSources: [SpatialAudioSource]
}

struct SpatialEntity: Codable {
    var id: UUID
    var type: EntityType
    var transform: SpatialTransform
    var modelReference: String?
    var components: [String: Data] // Component configurations
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
    var position: SIMD3<Float>
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
}

struct SpatialAudioSource: Codable {
    var id: UUID
    var position: SIMD3<Float>
    var volume: Float
    var spatializationEnabled: Bool
    var reverbEnabled: Bool
}
```

### Database Schema (Backend)

```sql
-- Users Table
CREATE TABLE users (
    id UUID PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    display_name VARCHAR(255) NOT NULL,
    avatar_url TEXT,
    organization VARCHAR(255),
    department VARCHAR(255),
    role VARCHAR(100),
    preferences JSONB,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Meetings Table
CREATE TABLE meetings (
    id UUID PRIMARY KEY,
    title VARCHAR(500) NOT NULL,
    description TEXT,
    scheduled_start TIMESTAMP NOT NULL,
    scheduled_end TIMESTAMP NOT NULL,
    actual_start TIMESTAMP,
    actual_end TIMESTAMP,
    status VARCHAR(50) NOT NULL,
    meeting_type VARCHAR(50) NOT NULL,
    organizer_id UUID REFERENCES users(id),
    environment_config JSONB,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Participants Table
CREATE TABLE participants (
    id UUID PRIMARY KEY,
    meeting_id UUID REFERENCES meetings(id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(id),
    role VARCHAR(50) NOT NULL,
    joined_at TIMESTAMP,
    left_at TIMESTAMP,
    audio_enabled BOOLEAN DEFAULT TRUE,
    video_enabled BOOLEAN DEFAULT TRUE,
    spatial_position JSONB,
    presence_state VARCHAR(50),
    speaking_time INTERVAL,
    engagement_score FLOAT,
    interactions INTEGER DEFAULT 0
);

-- Shared Content Table
CREATE TABLE shared_content (
    id UUID PRIMARY KEY,
    meeting_id UUID REFERENCES meetings(id) ON DELETE CASCADE,
    type VARCHAR(50) NOT NULL,
    title VARCHAR(500),
    url TEXT NOT NULL,
    thumbnail_url TEXT,
    spatial_transform JSONB,
    shared_by UUID REFERENCES users(id),
    shared_at TIMESTAMP DEFAULT NOW()
);

-- Transcripts Table
CREATE TABLE transcripts (
    id UUID PRIMARY KEY,
    meeting_id UUID REFERENCES meetings(id) ON DELETE CASCADE,
    segments JSONB NOT NULL,
    summary TEXT,
    generated_at TIMESTAMP DEFAULT NOW()
);

-- Action Items Table
CREATE TABLE action_items (
    id UUID PRIMARY KEY,
    meeting_id UUID REFERENCES meetings(id) ON DELETE CASCADE,
    transcript_id UUID REFERENCES transcripts(id),
    description TEXT NOT NULL,
    assigned_to UUID REFERENCES users(id),
    due_date TIMESTAMP,
    status VARCHAR(50) DEFAULT 'pending',
    extracted_at TIMESTAMP DEFAULT NOW()
);

-- Analytics Table
CREATE TABLE meeting_analytics (
    id UUID PRIMARY KEY,
    meeting_id UUID REFERENCES meetings(id) ON DELETE CASCADE,
    total_duration INTERVAL,
    participant_count INTEGER,
    speaking_distribution JSONB,
    engagement_score FLOAT,
    decision_count INTEGER,
    action_item_count INTEGER,
    ai_insights JSONB,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Recordings Table
CREATE TABLE recordings (
    id UUID PRIMARY KEY,
    meeting_id UUID REFERENCES meetings(id) ON DELETE CASCADE,
    storage_url TEXT NOT NULL,
    duration INTERVAL,
    file_size BIGINT,
    format VARCHAR(50),
    created_at TIMESTAMP DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_meetings_organizer ON meetings(organizer_id);
CREATE INDEX idx_meetings_status ON meetings(status);
CREATE INDEX idx_meetings_scheduled_start ON meetings(scheduled_start);
CREATE INDEX idx_participants_meeting ON participants(meeting_id);
CREATE INDEX idx_participants_user ON participants(user_id);
CREATE INDEX idx_shared_content_meeting ON shared_content(meeting_id);
CREATE INDEX idx_action_items_assigned ON action_items(assigned_to);
CREATE INDEX idx_action_items_status ON action_items(status);
```

---

## Service Layer Architecture

### Service Organization

```swift
// MARK: - Protocol Definitions

protocol MeetingServiceProtocol {
    func createMeeting(_ meeting: Meeting) async throws -> Meeting
    func joinMeeting(id: UUID) async throws -> MeetingSession
    func leaveMeeting(id: UUID) async throws
    func updateMeetingState(_ state: MeetingState) async throws
    func fetchMeetings(filter: MeetingFilter) async throws -> [Meeting]
}

protocol SpatialServiceProtocol {
    func updateParticipantPosition(_ position: SpatialPosition) async throws
    func syncSpatialState() async throws -> SpatialScene
    func placeContent(_ content: SharedContent, at: SpatialTransform) async throws
    func removeContent(id: UUID) async throws
}

protocol AIServiceProtocol {
    func startTranscription(meetingID: UUID) async throws
    func stopTranscription(meetingID: UUID) async throws -> Transcript
    func generateSummary(transcript: Transcript) async throws -> String
    func extractActionItems(transcript: Transcript) async throws -> [ActionItem]
    func analyzeEngagement(meetingID: UUID) async throws -> MeetingAnalytics
}

protocol NetworkServiceProtocol {
    func connect() async throws
    func disconnect() async throws
    func send<T: Codable>(_ message: T) async throws
    func subscribe<T: Codable>(to channel: String, handler: @escaping (T) -> Void)
}

// MARK: - Service Implementations

@Observable
class MeetingService: MeetingServiceProtocol {
    private let networkService: NetworkServiceProtocol
    private let dataStore: DataStore
    private let webRTCClient: WebRTCClient

    private(set) var currentMeeting: Meeting?
    private(set) var participants: [Participant] = []

    init(networkService: NetworkServiceProtocol, dataStore: DataStore) {
        self.networkService = networkService
        self.dataStore = dataStore
        self.webRTCClient = WebRTCClient()
    }

    func createMeeting(_ meeting: Meeting) async throws -> Meeting {
        // Save locally
        try await dataStore.save(meeting)

        // Sync to backend
        let response = try await networkService.send(
            CreateMeetingRequest(meeting: meeting)
        )

        return response.meeting
    }

    func joinMeeting(id: UUID) async throws -> MeetingSession {
        // Fetch meeting details
        let meeting = try await fetchMeeting(id: id)

        // Connect to signaling server
        try await networkService.connect()

        // Join WebRTC session
        let session = try await webRTCClient.joinSession(meetingID: id)

        // Update local state
        self.currentMeeting = meeting

        // Subscribe to participant updates
        networkService.subscribe(to: "participants.\(id)") { [weak self] (update: ParticipantUpdate) in
            self?.handleParticipantUpdate(update)
        }

        return session
    }

    func leaveMeeting(id: UUID) async throws {
        guard let meeting = currentMeeting, meeting.id == id else {
            throw MeetingError.notInMeeting
        }

        // Leave WebRTC session
        await webRTCClient.leaveSession()

        // Disconnect from signaling
        try await networkService.disconnect()

        // Update local state
        self.currentMeeting = nil
        self.participants = []
    }

    private func handleParticipantUpdate(_ update: ParticipantUpdate) {
        // Update participant list based on update type
        switch update.type {
        case .joined:
            participants.append(update.participant)
        case .left:
            participants.removeAll { $0.id == update.participant.id }
        case .updated:
            if let index = participants.firstIndex(where: { $0.id == update.participant.id }) {
                participants[index] = update.participant
            }
        }
    }
}

@Observable
class SpatialService: SpatialServiceProtocol {
    private let networkService: NetworkServiceProtocol
    private var spatialScene: SpatialScene?

    // Spatial sync rate limiting
    private var lastSyncTime: Date = .distantPast
    private let minSyncInterval: TimeInterval = 0.05 // 20 Hz max

    func updateParticipantPosition(_ position: SpatialPosition) async throws {
        // Rate limit updates
        let now = Date()
        guard now.timeIntervalSince(lastSyncTime) >= minSyncInterval else {
            return
        }
        lastSyncTime = now

        // Send position update
        try await networkService.send(
            PositionUpdate(position: position, timestamp: now)
        )
    }

    func syncSpatialState() async throws -> SpatialScene {
        let scene = try await networkService.fetch(SpatialSceneRequest())
        self.spatialScene = scene
        return scene
    }

    func placeContent(_ content: SharedContent, at transform: SpatialTransform) async throws {
        var updatedContent = content
        updatedContent.spatialTransform = transform

        try await networkService.send(
            PlaceContentMessage(content: updatedContent)
        )

        // Update local scene
        spatialScene?.entities.append(
            SpatialEntity(
                id: content.id,
                type: .content,
                transform: transform,
                modelReference: content.url.absoluteString,
                components: [:]
            )
        )
    }
}

@Observable
class AIService: AIServiceProtocol {
    private let apiClient: APIClient
    private var transcriptionTask: Task<Void, Error>?

    func startTranscription(meetingID: UUID) async throws {
        transcriptionTask = Task {
            // Stream audio to transcription service
            let stream = try await apiClient.startTranscriptionStream(meetingID: meetingID)

            for try await segment in stream {
                // Process and store transcript segments
                await processTranscriptSegment(segment, meetingID: meetingID)
            }
        }
    }

    func stopTranscription(meetingID: UUID) async throws -> Transcript {
        transcriptionTask?.cancel()
        transcriptionTask = nil

        return try await apiClient.finalizeTranscript(meetingID: meetingID)
    }

    func generateSummary(transcript: Transcript) async throws -> String {
        let request = SummarizationRequest(
            segments: transcript.segments,
            meetingContext: transcript.meeting.description
        )

        let response = try await apiClient.generateSummary(request)
        return response.summary
    }

    func extractActionItems(transcript: Transcript) async throws -> [ActionItem] {
        let request = ActionItemExtractionRequest(
            segments: transcript.segments
        )

        let response = try await apiClient.extractActionItems(request)
        return response.actionItems
    }

    func analyzeEngagement(meetingID: UUID) async throws -> MeetingAnalytics {
        let request = EngagementAnalysisRequest(meetingID: meetingID)
        let response = try await apiClient.analyzeEngagement(request)
        return response.analytics
    }

    private func processTranscriptSegment(_ segment: TranscriptSegment, meetingID: UUID) async {
        // Store segment locally
        // Trigger real-time AI analysis if needed
    }
}

class WebRTCClient {
    private var peerConnection: RTCPeerConnection?
    private var audioTrack: RTCAudioTrack?
    private var videoTrack: RTCVideoTrack?

    func joinSession(meetingID: UUID) async throws -> MeetingSession {
        // Initialize peer connection
        let config = RTCConfiguration()
        config.iceServers = [/* STUN/TURN servers */]

        peerConnection = RTCPeerConnection(configuration: config)

        // Set up media tracks
        setupAudioTrack()
        setupVideoTrack()

        // Exchange ICE candidates and SDP
        try await performSignaling(meetingID: meetingID)

        return MeetingSession(meetingID: meetingID)
    }

    func leaveSession() async {
        audioTrack?.isEnabled = false
        videoTrack?.isEnabled = false
        peerConnection?.close()
        peerConnection = nil
    }

    private func setupAudioTrack() {
        // Configure spatial audio
    }

    private func setupVideoTrack() {
        // Configure video streaming
    }

    private func performSignaling(meetingID: UUID) async throws {
        // SDP offer/answer exchange
        // ICE candidate exchange
    }
}
```

---

## RealityKit & ARKit Integration

### Entity Component System Architecture

```swift
// MARK: - Custom Components

struct ParticipantComponent: Component {
    var userID: UUID
    var displayName: String
    var audioEnabled: Bool
    var videoEnabled: Bool
    var presenceState: PresenceState
}

struct SpeakingIndicatorComponent: Component {
    var isActive: Bool
    var intensity: Float
    var color: SimpleMaterial.Color
}

struct InteractableComponent: Component {
    var isInteractable: Bool
    var interactionType: InteractionType
    var onTap: (() -> Void)?
    var onDrag: ((EntityTranslation) -> Void)?
}

enum InteractionType {
    case tap
    case drag
    case rotate
    case scale
    case longPress
}

struct WhiteboardComponent: Component {
    var strokes: [DrawingStroke]
    var currentColor: Color
    var brushSize: Float
}

struct DrawingStroke: Codable {
    var points: [SIMD3<Float>]
    var color: CodableColor
    var thickness: Float
    var author: UUID
    var timestamp: Date
}

// MARK: - Systems

class ParticipantRenderingSystem: System {
    private static let query = EntityQuery(where: .has(ParticipantComponent.self))

    func update(context: SceneUpdateContext) {
        let entities = context.entities(matching: Self.query, updatingSystemWhen: .rendering)

        for entity in entities {
            guard let component = entity.components[ParticipantComponent.self] else { continue }

            // Update participant visualization based on state
            updateParticipantVisualization(entity: entity, component: component)
        }
    }

    private func updateParticipantVisualization(entity: Entity, component: ParticipantComponent) {
        // Update speaking indicator
        if let speakingComponent = entity.components[SpeakingIndicatorComponent.self] {
            updateSpeakingIndicator(entity: entity, component: speakingComponent)
        }

        // Update presence state visual
        updatePresenceState(entity: entity, state: component.presenceState)
    }

    private func updateSpeakingIndicator(entity: Entity, component: SpeakingIndicatorComponent) {
        // Animate speaking indicator ring
        if component.isActive {
            let animation = FromToByAnimation(
                from: Transform(scale: SIMD3(1.0, 1.0, 1.0)),
                to: Transform(scale: SIMD3(1.2, 1.2, 1.2)),
                duration: 0.5,
                timing: .easeInOut,
                isAdditive: false,
                bindTarget: .transform
            )

            entity.playAnimation(animation.repeat())
        }
    }

    private func updatePresenceState(entity: Entity, state: PresenceState) {
        // Update glow/aura based on presence
        var material = SimpleMaterial()

        switch state {
        case .active:
            material.color = .init(tint: .blue, texture: nil)
        case .speaking:
            material.color = .init(tint: .green, texture: nil)
        case .idle:
            material.color = .init(tint: .gray, texture: nil)
        case .away:
            material.color = .init(tint: .yellow, texture: nil)
        case .offline:
            material.color = .init(tint: .red, texture: nil)
        }

        // Apply to aura entity
        if let auraEntity = entity.findEntity(named: "aura") as? ModelEntity {
            auraEntity.model?.materials = [material]
        }
    }
}

class SpatialAudioSystem: System {
    private static let query = EntityQuery(where: .has(ParticipantComponent.self))

    func update(context: SceneUpdateContext) {
        let entities = context.entities(matching: Self.query, updatingSystemWhen: .rendering)

        for entity in entities {
            // Update spatial audio position based on entity location
            updateAudioPosition(entity: entity)
        }
    }

    private func updateAudioPosition(entity: Entity) {
        // Configure AVAudioEngine with spatial position
        let worldPosition = entity.position(relativeTo: nil)

        // Update audio source position for this participant
        AudioManager.shared.updateParticipantPosition(
            entityID: entity.id,
            position: worldPosition
        )
    }
}

// MARK: - Reality Composer Pro Integration

class MeetingEnvironmentLoader {
    func loadEnvironment(_ type: MeetingType) async throws -> Entity {
        switch type {
        case .boardroom:
            return try await loadBoardroom()
        case .innovationLab:
            return try await loadInnovationLab()
        case .auditorium:
            return try await loadAuditorium()
        case .cafe:
            return try await loadCafe()
        case .outdoor:
            return try await loadOutdoor()
        case .custom:
            return try await loadCustom()
        }
    }

    private func loadBoardroom() async throws -> Entity {
        // Load from Reality Composer Pro
        let scene = try await Entity(named: "BoardroomScene", in: realityKitContentBundle)

        // Configure dynamic elements
        configureLighting(scene)
        configureSeating(scene, capacity: 12)
        configureWhiteboards(scene)

        return scene
    }

    private func configureLighting(_ scene: Entity) {
        // Add dynamic lighting based on time of day
        let sunlight = DirectionalLight()
        sunlight.light.intensity = 1000
        sunlight.light.color = .white
        sunlight.shadow = DirectionalLightComponent.Shadow()

        scene.addChild(sunlight)
    }

    private func configureSeating(_ scene: Entity, capacity: Int) {
        // Arrange participant spawn points in circle
        let radius: Float = 2.0
        let angleStep = (2 * Float.pi) / Float(capacity)

        for i in 0..<capacity {
            let angle = Float(i) * angleStep
            let x = radius * cos(angle)
            let z = radius * sin(angle)

            let seatMarker = Entity()
            seatMarker.position = SIMD3(x, 0, z)
            seatMarker.name = "seat_\(i)"

            scene.addChild(seatMarker)
        }
    }
}

// MARK: - ARKit Integration

class SpatialTrackingManager {
    private var arSession: ARKitSession?
    private var worldTracking: WorldTrackingProvider?
    private var handTracking: HandTrackingProvider?

    func startTracking() async throws {
        arSession = ARKitSession()
        worldTracking = WorldTrackingProvider()
        handTracking = HandTrackingProvider()

        try await arSession?.run([worldTracking!, handTracking!])

        // Monitor tracking updates
        monitorWorldTracking()
        monitorHandTracking()
    }

    private func monitorWorldTracking() {
        Task {
            guard let worldTracking else { return }

            for await update in worldTracking.anchorUpdates {
                handleWorldTrackingUpdate(update)
            }
        }
    }

    private func monitorHandTracking() {
        Task {
            guard let handTracking else { return }

            for await update in handTracking.anchorUpdates {
                handleHandTrackingUpdate(update)
            }
        }
    }

    private func handleWorldTrackingUpdate(_ update: AnchorUpdate<WorldAnchor>) {
        // Process world tracking for spatial positioning
    }

    private func handleHandTrackingUpdate(_ update: AnchorUpdate<HandAnchor>) {
        // Process hand gestures for interactions
        switch update.event {
        case .added:
            break
        case .updated:
            if let anchor = update.anchor {
                processHandGesture(anchor)
            }
        case .removed:
            break
        }
    }

    private func processHandGesture(_ anchor: HandAnchor) {
        // Detect pinch, point, grab gestures
        if anchor.isPinching {
            handlePinchGesture(anchor)
        }
    }

    private func handlePinchGesture(_ anchor: HandAnchor) {
        // Trigger interaction based on pinch target
    }
}
```

---

## API Design & External Integrations

### REST API Design

```swift
// MARK: - API Client

class APIClient {
    private let baseURL: URL
    private let session: URLSession
    private var authToken: String?

    init(baseURL: URL) {
        self.baseURL = baseURL

        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 300

        self.session = URLSession(configuration: config)
    }

    // MARK: - Authentication

    func authenticate(email: String, password: String) async throws -> AuthResponse {
        let endpoint = baseURL.appendingPathComponent("/auth/login")
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = ["email": email, "password": password]
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIError.authenticationFailed
        }

        let authResponse = try JSONDecoder().decode(AuthResponse.self, from: data)
        self.authToken = authResponse.token

        return authResponse
    }

    // MARK: - Meeting APIs

    func fetchMeetings(filter: MeetingFilter) async throws -> [Meeting] {
        var components = URLComponents(url: baseURL.appendingPathComponent("/meetings"), resolvingAgainstBaseURL: true)!

        components.queryItems = [
            URLQueryItem(name: "status", value: filter.status?.rawValue),
            URLQueryItem(name: "from", value: filter.startDate?.ISO8601Format()),
            URLQueryItem(name: "to", value: filter.endDate?.ISO8601Format())
        ].compactMap { $0 }

        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"
        addAuthHeader(&request)

        let (data, _) = try await session.data(for: request)
        return try JSONDecoder().decode([Meeting].self, from: data)
    }

    func createMeeting(_ meeting: Meeting) async throws -> Meeting {
        let endpoint = baseURL.appendingPathComponent("/meetings")
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        addAuthHeader(&request)

        request.httpBody = try JSONEncoder().encode(meeting)

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 201 else {
            throw APIError.createFailed
        }

        return try JSONDecoder().decode(Meeting.self, from: data)
    }

    // MARK: - AI Service APIs

    func generateSummary(_ request: SummarizationRequest) async throws -> SummarizationResponse {
        let endpoint = baseURL.appendingPathComponent("/ai/summarize")
        var urlRequest = URLRequest(url: endpoint)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        addAuthHeader(&urlRequest)

        urlRequest.httpBody = try JSONEncoder().encode(request)

        let (data, _) = try await session.data(for: urlRequest)
        return try JSONDecoder().decode(SummarizationResponse.self, from: data)
    }

    func extractActionItems(_ request: ActionItemExtractionRequest) async throws -> ActionItemExtractionResponse {
        let endpoint = baseURL.appendingPathComponent("/ai/action-items")
        var urlRequest = URLRequest(url: endpoint)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        addAuthHeader(&urlRequest)

        urlRequest.httpBody = try JSONEncoder().encode(request)

        let (data, _) = try await session.data(for: urlRequest)
        return try JSONDecoder().decode(ActionItemExtractionResponse.self, from: data)
    }

    // MARK: - Streaming APIs

    func startTranscriptionStream(meetingID: UUID) async throws -> AsyncThrowingStream<TranscriptSegment, Error> {
        let endpoint = baseURL.appendingPathComponent("/meetings/\(meetingID)/transcribe/stream")
        var request = URLRequest(url: endpoint)
        request.httpMethod = "GET"
        addAuthHeader(&request)

        return AsyncThrowingStream { continuation in
            Task {
                do {
                    let (bytes, _) = try await session.bytes(for: request)

                    for try await line in bytes.lines {
                        if let data = line.data(using: .utf8),
                           let segment = try? JSONDecoder().decode(TranscriptSegment.self, from: data) {
                            continuation.yield(segment)
                        }
                    }

                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }

    private func addAuthHeader(_ request: inout URLRequest) {
        if let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
    }
}

// MARK: - WebSocket Real-Time Communication

class WebSocketService: NetworkServiceProtocol {
    private var webSocket: URLSessionWebSocketTask?
    private var subscriptions: [String: [(Any) -> Void]] = [:]

    func connect() async throws {
        let url = URL(string: "wss://api.example.com/realtime")!
        webSocket = URLSession.shared.webSocketTask(with: url)
        webSocket?.resume()

        // Start receiving messages
        receiveMessages()
    }

    func disconnect() async throws {
        webSocket?.cancel(with: .goingAway, reason: nil)
        webSocket = nil
    }

    func send<T: Codable>(_ message: T) async throws {
        let data = try JSONEncoder().encode(message)
        let string = String(data: data, encoding: .utf8)!

        try await webSocket?.send(.string(string))
    }

    func subscribe<T: Codable>(to channel: String, handler: @escaping (T) -> Void) {
        subscriptions[channel, default: []].append { message in
            if let typedMessage = message as? T {
                handler(typedMessage)
            }
        }
    }

    private func receiveMessages() {
        webSocket?.receive { [weak self] result in
            switch result {
            case .success(let message):
                self?.handleMessage(message)
                self?.receiveMessages() // Continue receiving

            case .failure(let error):
                print("WebSocket error: \(error)")
            }
        }
    }

    private func handleMessage(_ message: URLSessionWebSocketTask.Message) {
        switch message {
        case .string(let text):
            guard let data = text.data(using: .utf8),
                  let envelope = try? JSONDecoder().decode(MessageEnvelope.self, from: data) else {
                return
            }

            // Route to appropriate subscription
            if let handlers = subscriptions[envelope.channel] {
                for handler in handlers {
                    handler(envelope.payload)
                }
            }

        case .data(let data):
            // Handle binary data if needed
            break

        @unknown default:
            break
        }
    }
}

struct MessageEnvelope: Codable {
    let channel: String
    let payload: Data
}

// MARK: - Calendar Integration

class CalendarIntegrationService {
    func syncWithMicrosoft(credentials: OAuthCredentials) async throws -> [Meeting] {
        // Microsoft Graph API integration
        let graphClient = MSGraphClient(credentials: credentials)
        let events = try await graphClient.fetchCalendarEvents()

        return events.compactMap { convertToMeeting($0) }
    }

    func syncWithGoogle(credentials: OAuthCredentials) async throws -> [Meeting] {
        // Google Calendar API integration
        let calendarClient = GoogleCalendarClient(credentials: credentials)
        let events = try await calendarClient.fetchEvents()

        return events.compactMap { convertToMeeting($0) }
    }

    private func convertToMeeting(_ event: CalendarEvent) -> Meeting? {
        // Convert calendar event to Meeting model
        return nil // Implementation
    }
}
```

---

## State Management Strategy

### Observable Architecture

```swift
// MARK: - App-Wide State

@Observable
class AppModel {
    // Authentication
    var currentUser: User?
    var isAuthenticated: Bool { currentUser != nil }

    // Meeting State
    var activeMeeting: Meeting?
    var upcomingMeetings: [Meeting] = []
    var meetingHistory: [Meeting] = []

    // UI State
    var selectedEnvironment: MeetingType = .boardroom
    var immersiveModeActive: Bool = false
    var showingControls: Bool = true

    // Services
    let meetingService: MeetingServiceProtocol
    let spatialService: SpatialServiceProtocol
    let aiService: AIServiceProtocol

    init() {
        let networkService = WebSocketService()
        let dataStore = DataStore()

        self.meetingService = MeetingService(networkService: networkService, dataStore: dataStore)
        self.spatialService = SpatialService(networkService: networkService)
        self.aiService = AIService(apiClient: APIClient(baseURL: URL(string: "https://api.example.com")!))
    }

    // MARK: - Actions

    func joinMeeting(_ meeting: Meeting) async throws {
        let session = try await meetingService.joinMeeting(id: meeting.id)
        self.activeMeeting = meeting

        // Start AI transcription
        try await aiService.startTranscription(meetingID: meeting.id)
    }

    func leaveMeeting() async throws {
        guard let meeting = activeMeeting else { return }

        // Stop transcription
        let transcript = try await aiService.stopTranscription(meetingID: meeting.id)

        // Generate summary
        let summary = try await aiService.generateSummary(transcript: transcript)

        // Leave meeting
        try await meetingService.leaveMeeting(id: meeting.id)

        self.activeMeeting = nil
    }

    func toggleImmersiveMode() async throws {
        immersiveModeActive.toggle()

        if immersiveModeActive {
            // Open immersive space
            await openWindow(id: "immersive-meeting")
        } else {
            // Close immersive space
            await dismissWindow(id: "immersive-meeting")
        }
    }
}

// MARK: - View Models

@Observable
class MeetingViewModel {
    private let appModel: AppModel
    private let meeting: Meeting

    var participants: [Participant] = []
    var sharedContent: [SharedContent] = []
    var transcript: [TranscriptSegment] = []
    var isRecording: Bool = false

    init(appModel: AppModel, meeting: Meeting) {
        self.appModel = appModel
        self.meeting = meeting

        observeParticipantUpdates()
        observeContentUpdates()
        observeTranscriptUpdates()
    }

    func shareScreen() async throws {
        // Capture and share screen
    }

    func shareDocument(_ url: URL) async throws {
        let content = SharedContent(
            id: UUID(),
            type: .document,
            title: url.lastPathComponent,
            url: url,
            thumbnailURL: nil,
            spatialTransform: SpatialTransform(
                position: SIMD3(0, 1.5, -2),
                rotation: simd_quatf(angle: 0, axis: SIMD3(0, 1, 0)),
                scale: SIMD3(1, 1, 1)
            ),
            sharedBy: appModel.currentUser!,
            sharedAt: Date(),
            annotations: []
        )

        try await appModel.spatialService.placeContent(content, at: content.spatialTransform)
        sharedContent.append(content)
    }

    func toggleRecording() async throws {
        isRecording.toggle()

        if isRecording {
            // Start recording
        } else {
            // Stop recording
        }
    }

    private func observeParticipantUpdates() {
        // Subscribe to participant changes
    }

    private func observeContentUpdates() {
        // Subscribe to content changes
    }

    private func observeTranscriptUpdates() {
        // Subscribe to transcript updates
    }
}

@Observable
class SpatialSceneViewModel {
    private let spatialService: SpatialServiceProtocol

    var participantEntities: [UUID: Entity] = [:]
    var contentEntities: [UUID: Entity] = [:]
    var environmentEntity: Entity?

    func updateParticipantPosition(_ participantID: UUID, position: SpatialPosition) async {
        guard let entity = participantEntities[participantID] else { return }

        entity.position = SIMD3(position.x, position.y, position.z)
        entity.orientation = position.rotation

        try? await spatialService.updateParticipantPosition(position)
    }

    func addParticipant(_ participant: Participant) {
        let entity = createParticipantEntity(participant)
        participantEntities[participant.id] = entity
    }

    func removeParticipant(_ participantID: UUID) {
        participantEntities.removeValue(forKey: participantID)?.removeFromParent()
    }

    private func createParticipantEntity(_ participant: Participant) -> Entity {
        let entity = Entity()

        // Add participant component
        entity.components.set(ParticipantComponent(
            userID: participant.user.id,
            displayName: participant.user.displayName,
            audioEnabled: participant.audioEnabled,
            videoEnabled: participant.videoEnabled,
            presenceState: participant.presenceState
        ))

        // Add speaking indicator
        entity.components.set(SpeakingIndicatorComponent(
            isActive: false,
            intensity: 0.0,
            color: .blue
        ))

        // Add visual representation (avatar)
        let avatarEntity = createAvatarMesh()
        entity.addChild(avatarEntity)

        return entity
    }

    private func createAvatarMesh() -> ModelEntity {
        let mesh = MeshResource.generateSphere(radius: 0.2)
        let material = SimpleMaterial(color: .blue, isMetallic: false)
        return ModelEntity(mesh: mesh, materials: [material])
    }
}
```

---

## Performance Optimization Strategy

### Rendering Optimization

1. **Level of Detail (LOD)**
   - Multiple mesh resolutions for participants based on distance
   - Automatic LOD switching at 3m, 5m, 10m thresholds
   - Simplified materials for distant objects

2. **Occlusion Culling**
   - Frustum culling for off-screen entities
   - Distance-based culling beyond 20m
   - Hierarchical culling for complex scenes

3. **Draw Call Reduction**
   - Batch rendering for similar entities
   - Instanced rendering for repeated elements
   - Texture atlasing for UI elements

### Memory Management

```swift
class PerformanceManager {
    // Memory budgets
    private let maxParticipantCount = 100
    private let maxActiveEntities = 500
    private let memoryWarningThreshold: UInt64 = 2_000_000_000 // 2GB

    func optimizeMemoryUsage() {
        // Monitor memory pressure
        let memoryUsage = getCurrentMemoryUsage()

        if memoryUsage > memoryWarningThreshold {
            // Aggressive optimization
            reduceLODQuality()
            unloadDistantAssets()
            clearCaches()
        }
    }

    private func reduceLODQuality() {
        // Switch to lower quality assets
    }

    private func unloadDistantAssets() {
        // Remove entities beyond certain distance
    }

    private func clearCaches() {
        // Clear texture and model caches
    }
}
```

### Network Optimization

1. **Adaptive Bitrate**
   - Adjust video quality based on bandwidth
   - Reduce to audio-only if connection poor
   - Progressive quality enhancement

2. **Data Compression**
   - Protocol buffers for state sync
   - Delta compression for position updates
   - Spatial audio compression

3. **Connection Management**
   - Peer-to-peer for small meetings (<5 participants)
   - SFU (Selective Forwarding Unit) for larger meetings
   - Fallback to audio-only mode

---

## Security Architecture

### End-to-End Encryption

```swift
class EncryptionManager {
    private let keychain = KeychainManager()

    // Generate meeting-specific encryption key
    func generateMeetingKey() -> SymmetricKey {
        return SymmetricKey(size: .bits256)
    }

    // Encrypt meeting data
    func encrypt(data: Data, with key: SymmetricKey) throws -> Data {
        let sealedBox = try AES.GCM.seal(data, using: key)
        return sealedBox.combined!
    }

    // Decrypt meeting data
    func decrypt(data: Data, with key: SymmetricKey) throws -> Data {
        let sealedBox = try AES.GCM.SealedBox(combined: data)
        return try AES.GCM.open(sealedBox, using: key)
    }

    // Store encryption key securely
    func storeMeetingKey(_ key: SymmetricKey, for meetingID: UUID) throws {
        try keychain.save(key.withUnsafeBytes { Data($0) }, for: "meeting_\(meetingID)")
    }
}
```

### Authentication & Authorization

```swift
class AuthenticationManager {
    func authenticateUser(email: String, password: String) async throws -> User {
        // Multi-factor authentication
        let mfaCode = try await requestMFACode(email: email)

        // Verify credentials + MFA
        let user = try await verifyCredentials(email: email, password: password, mfaCode: mfaCode)

        // Generate session token
        let token = try await generateSessionToken(user: user)

        // Store securely
        try KeychainManager().save(token, for: "session_token")

        return user
    }

    func authorizeAction(_ action: Action, for user: User) -> Bool {
        // Role-based access control
        return user.hasPermission(for: action)
    }
}
```

### Privacy Protection

1. **Data Minimization**: Only collect necessary information
2. **Local Processing**: AI processing on-device when possible
3. **Consent Management**: Explicit consent for recording
4. **Data Retention**: Automatic deletion of recordings after 90 days
5. **Anonymization**: Remove PII from analytics

---

## Conclusion

This architecture provides a robust, scalable foundation for the Spatial Meeting Platform on visionOS. Key design decisions:

- **Modular services** for maintainability and testability
- **Observable state** for reactive UI updates
- **Entity Component System** for flexible spatial content
- **Real-time sync** with WebSocket and WebRTC
- **AI integration** throughout the stack
- **Security by default** with E2E encryption
- **Performance optimization** for 90 FPS target

The architecture supports the progressive enhancement pattern, starting with basic windows and scaling to full immersive experiences as user needs evolve.
