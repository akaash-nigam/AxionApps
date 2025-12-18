# System Architecture Design Document

## Document Information
- **Version**: 1.0
- **Last Updated**: 2025-11-24
- **Status**: Draft
- **Owner**: Engineering Team

## 1. Executive Summary

This document outlines the system architecture for Spatial Code Reviewer, a visionOS application that provides immersive 3D code review experiences. The architecture prioritizes performance, modularity, and scalability while leveraging native Apple platforms.

## 2. Architecture Overview

### 2.1 High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                     Presentation Layer                           │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────────┐  │
│  │   SwiftUI    │  │  RealityKit  │  │   Gesture & Voice    │  │
│  │     Views    │  │   Entities   │  │      Handlers        │  │
│  └──────────────┘  └──────────────┘  └──────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
                              │
┌─────────────────────────────────────────────────────────────────┐
│                      Business Logic Layer                        │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────────┐  │
│  │   Spatial    │  │  Code Review │  │   Collaboration      │  │
│  │   Manager    │  │   Manager    │  │      Manager         │  │
│  └──────────────┘  └──────────────┘  └──────────────────────┘  │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────────┐  │
│  │  Dependency  │  │  Git History │  │    Issue             │  │
│  │    Graph     │  │   Manager    │  │    Manager           │  │
│  └──────────────┘  └──────────────┘  └──────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
                              │
┌─────────────────────────────────────────────────────────────────┐
│                        Service Layer                             │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────────┐  │
│  │Code Analysis │  │Repository    │  │   External API       │  │
│  │   Service    │  │   Service    │  │     Service          │  │
│  └──────────────┘  └──────────────┘  └──────────────────────┘  │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────────┐  │
│  │   Sync       │  │   Auth       │  │   Notification       │  │
│  │   Service    │  │   Service    │  │     Service          │  │
│  └──────────────┘  └──────────────┘  └──────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
                              │
┌─────────────────────────────────────────────────────────────────┐
│                        Data Layer                                │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────────┐  │
│  │  Core Data   │  │    SQLite    │  │     CloudKit         │  │
│  │  (Local DB)  │  │(Code Index)  │  │  (Sync Storage)      │  │
│  └──────────────┘  └──────────────┘  └──────────────────────┘  │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────────┐  │
│  │  UserDefaults│  │   Keychain   │  │   File System        │  │
│  │ (Preferences)│  │  (Secrets)   │  │  (Git Repos)         │  │
│  └──────────────┘  └──────────────┘  └──────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

### 2.2 Component Overview

| Component | Responsibility | Technologies |
|-----------|---------------|--------------|
| **Presentation Layer** | User interface, 3D rendering, input handling | SwiftUI, RealityKit, ARKit |
| **Business Logic Layer** | Core application logic, state management | Swift, Combine |
| **Service Layer** | External integrations, data processing | URLSession, libgit2, tree-sitter |
| **Data Layer** | Persistence, caching, storage | Core Data, SQLite, CloudKit |

## 3. Component Specifications

### 3.1 Presentation Layer

#### 3.1.1 SwiftUI Views
- **Purpose**: 2D UI overlays, settings, dialogs
- **Key Components**:
  - `MainView`: Root view with immersive space
  - `CodeEditorView`: Text rendering for code
  - `SettingsView`: App configuration
  - `OnboardingView`: Tutorial flow
  - `IssueCardView`: Bug report cards

#### 3.1.2 RealityKit Entities
- **Purpose**: 3D spatial rendering
- **Key Components**:
  - `CodeWindowEntity`: Floating code panels
  - `DependencyLineEntity`: Connection visualization
  - `AvatarEntity`: Team member representations
  - `IssueMarkerEntity`: Bug indicators
  - `TimelineEntity`: Git history scrubber

#### 3.1.3 Gesture & Voice Handlers
- **Purpose**: Input processing
- **Components**:
  - `SpatialGestureRecognizer`: Hand tracking
  - `VoiceCommandProcessor`: Siri/voice input
  - `EyeTrackingHandler`: Gaze interaction

### 3.2 Business Logic Layer

#### 3.2.1 Spatial Manager
```swift
class SpatialManager: ObservableObject {
    // Manages 3D layout and positioning
    func arrangeCodeWindows(_ files: [CodeFile], layout: LayoutType)
    func focusOnFile(_ file: CodeFile)
    func transitionToLayout(_ layout: LayoutType, animated: Bool)
    func calculateOptimalPositions(for entities: [Entity]) -> [Transform]
}
```

**Responsibilities**:
- Window positioning algorithms
- Layout transitions
- Collision avoidance
- Distance-based scaling

#### 3.2.2 Code Review Manager
```swift
class CodeReviewManager: ObservableObject {
    // Manages review sessions and state
    func createReviewSession(for pr: PullRequest) async throws
    func loadCodeFiles(for branch: String) async throws -> [CodeFile]
    func submitReview(_ review: Review) async throws
    func addComment(_ comment: Comment, to file: CodeFile, line: Int)
}
```

**Responsibilities**:
- PR/branch loading
- Review state management
- Comment threading
- Approval workflows

#### 3.2.3 Collaboration Manager
```swift
class CollaborationManager: ObservableObject {
    // Manages multi-user sessions
    func startSession() async throws -> Session
    func inviteParticipants(_ users: [User])
    func syncState(_ state: SessionState)
    func updateParticipantPosition(_ participant: Participant, transform: Transform)
}
```

**Responsibilities**:
- SharePlay integration
- State synchronization
- Avatar positioning
- Spatial audio

#### 3.2.4 Dependency Graph Manager
```swift
class DependencyGraphManager {
    // Analyzes and visualizes dependencies
    func buildGraph(for files: [CodeFile]) async -> DependencyGraph
    func detectCircularDependencies() -> [DependencyCycle]
    func layoutGraph(using algorithm: LayoutAlgorithm) -> GraphLayout
    func filterGraph(by type: DependencyType) -> DependencyGraph
}
```

**Responsibilities**:
- Dependency extraction
- Graph algorithms
- Layout calculation
- Filtering and simplification

#### 3.2.5 Git History Manager
```swift
class GitHistoryManager {
    // Manages git operations and visualization
    func loadHistory(for file: CodeFile) async throws -> [Commit]
    func calculateDiff(from: Commit, to: Commit) -> [FileDiff]
    func animateTransition(from: Commit, to: Commit, duration: TimeInterval)
    func getBlameInfo(for file: CodeFile) async throws -> [BlameLine]
}
```

**Responsibilities**:
- Git history loading
- Diff calculation
- Animation timing
- Blame attribution

#### 3.2.6 Issue Manager
```swift
class IssueManager: ObservableObject {
    // Manages bug reports and issues
    func fetchIssues(for repo: Repository) async throws -> [Issue]
    func linkIssueToCode(_ issue: Issue, file: CodeFile, lines: Range<Int>)
    func syncIssues() async throws
    func createIssue(_ issue: Issue) async throws
}
```

**Responsibilities**:
- Issue loading
- Code linking
- Real-time sync
- Issue creation

### 3.3 Service Layer

#### 3.3.1 Code Analysis Service
```swift
protocol CodeAnalysisService {
    func parseFile(_ file: URL, language: Language) async throws -> SyntaxTree
    func extractDependencies(from tree: SyntaxTree) -> [Dependency]
    func highlightSyntax(for tree: SyntaxTree) -> [SyntaxHighlight]
    func getSymbols(in tree: SyntaxTree) -> [Symbol]
}

class TreeSitterAnalysisService: CodeAnalysisService {
    // Implementation using tree-sitter
}
```

**Supported Languages**: JavaScript, TypeScript, Python, Swift, Java, Go, Rust, C++

#### 3.3.2 Repository Service
```swift
protocol RepositoryService {
    func clone(_ url: URL, to path: URL) async throws
    func fetchChanges() async throws
    func checkoutBranch(_ name: String) async throws
    func listBranches() async throws -> [Branch]
    func getPullRequests() async throws -> [PullRequest]
}

class LibGit2RepositoryService: RepositoryService {
    // Implementation using libgit2
}
```

#### 3.3.3 External API Service
```swift
protocol ExternalAPIService {
    func authenticate() async throws
    func fetchPullRequest(_ id: String) async throws -> PullRequest
    func fetchIssues(repo: String) async throws -> [Issue]
    func postComment(_ comment: Comment) async throws
    func updatePullRequest(_ pr: PullRequest) async throws
}

class GitHubAPIService: ExternalAPIService { }
class GitLabAPIService: ExternalAPIService { }
class BitbucketAPIService: ExternalAPIService { }
```

#### 3.3.4 Sync Service
```swift
class SyncService {
    // CloudKit synchronization
    func syncSessionState(_ session: Session) async throws
    func fetchRemoteChanges() async throws -> [Change]
    func resolveConflicts(_ conflicts: [Conflict]) async throws
}
```

#### 3.3.5 Auth Service
```swift
class AuthService {
    // OAuth and token management
    func authenticate(provider: AuthProvider) async throws -> Token
    func refreshToken() async throws
    func storeToken(_ token: Token, in keychain: Keychain)
    func revokeAccess() async throws
}
```

### 3.4 Data Layer

#### 3.4.1 Core Data Models
- `RepositoryEntity`: Local repository metadata
- `SessionEntity`: Review session state
- `CommentEntity`: User annotations
- `PreferenceEntity`: User settings

#### 3.4.2 SQLite Code Index
- **Schema**: See Data Models document
- **Purpose**: Fast code search and navigation
- **Indexes**: File paths, symbols, dependencies

#### 3.4.3 CloudKit Schema
- `CKSession`: Shared session state
- `CKParticipant`: User positions/state
- `CKAnnotation`: Shared comments

## 4. Data Flow

### 4.1 Code Review Session Flow

```
User Action: Select PR
     ↓
CodeReviewManager.createReviewSession(pr)
     ↓
RepositoryService.fetchChanges()
     ↓
RepositoryService.getPullRequest(pr.id)
     ↓
CodeAnalysisService.parseFile() for each changed file
     ↓
DependencyGraphManager.buildGraph(files)
     ↓
SpatialManager.arrangeCodeWindows(files)
     ↓
RealityKit renders entities
     ↓
User reviews code
```

### 4.2 Collaboration Session Flow

```
User Action: Invite Teammate
     ↓
CollaborationManager.startSession()
     ↓
SharePlay creates group session
     ↓
SyncService.syncSessionState()
     ↓
Remote participant joins
     ↓
CollaborationManager.updateParticipantPosition() (continuous)
     ↓
Avatar rendered in 3D space
     ↓
Spatial audio activated
```

### 4.3 Dependency Graph Flow

```
User Action: Show Dependencies
     ↓
CodeReviewManager.loadCodeFiles()
     ↓
CodeAnalysisService.parseFile() for all files
     ↓
CodeAnalysisService.extractDependencies()
     ↓
DependencyGraphManager.buildGraph()
     ↓
DependencyGraphManager.layoutGraph(forceDirected)
     ↓
SpatialManager.transitionToLayout(.architectureMode)
     ↓
DependencyLineEntity renders connections
```

## 5. Technology Stack

### 5.1 Core Technologies

| Technology | Version | Purpose |
|-----------|---------|---------|
| Swift | 6.0+ | Primary language |
| SwiftUI | visionOS 2.0+ | UI framework |
| RealityKit | visionOS 2.0+ | 3D rendering |
| ARKit | visionOS 2.0+ | Spatial tracking |
| Combine | iOS 17+ | Reactive programming |
| SwiftData | visionOS 2.0+ | Alternative to Core Data |

### 5.2 Third-Party Libraries

| Library | Version | Purpose | License |
|---------|---------|---------|---------|
| tree-sitter | 0.20+ | Code parsing | MIT |
| libgit2 | 1.7+ | Git operations | GPL v2 + Linking Exception |
| SwiftSyntax | 509+ | Swift parsing | Apache 2.0 |

### 5.3 Apple Frameworks

- **GroupActivities**: SharePlay collaboration
- **CloudKit**: State synchronization
- **Core Data**: Local persistence
- **AVFoundation**: Spatial audio
- **Vision**: OCR for code region detection
- **SiriKit**: Voice commands

## 6. Dependency Injection

### 6.1 Service Container

```swift
class ServiceContainer {
    static let shared = ServiceContainer()

    // Services
    lazy var codeAnalysisService: CodeAnalysisService = TreeSitterAnalysisService()
    lazy var repositoryService: RepositoryService = LibGit2RepositoryService()
    lazy var authService: AuthService = AuthService()
    lazy var syncService: SyncService = SyncService()

    // Managers
    lazy var spatialManager: SpatialManager = SpatialManager()
    lazy var codeReviewManager: CodeReviewManager = CodeReviewManager(
        repositoryService: repositoryService,
        codeAnalysisService: codeAnalysisService
    )
    lazy var collaborationManager: CollaborationManager = CollaborationManager(
        syncService: syncService
    )
    lazy var dependencyGraphManager: DependencyGraphManager = DependencyGraphManager(
        codeAnalysisService: codeAnalysisService
    )

    private init() {}
}
```

### 6.2 Dependency Injection Pattern

```swift
// Protocol-based injection for testability
protocol CodeReviewManaging {
    func createReviewSession(for pr: PullRequest) async throws
}

class CodeReviewManager: CodeReviewManaging {
    private let repositoryService: RepositoryService
    private let codeAnalysisService: CodeAnalysisService

    init(repositoryService: RepositoryService,
         codeAnalysisService: CodeAnalysisService) {
        self.repositoryService = repositoryService
        self.codeAnalysisService = codeAnalysisService
    }
}

// Usage in views
struct MainView: View {
    @StateObject private var codeReviewManager = ServiceContainer.shared.codeReviewManager
}
```

## 7. Error Handling Strategy

### 7.1 Error Types

```swift
enum SpatialCodeReviewerError: LocalizedError {
    // Network errors
    case networkUnavailable
    case apiRateLimitExceeded
    case authenticationFailed

    // Repository errors
    case repositoryNotFound
    case cloneFailure(reason: String)
    case gitOperationFailed(operation: String)

    // Parsing errors
    case unsupportedLanguage(Language)
    case parsingFailed(file: String)

    // Collaboration errors
    case sessionCreationFailed
    case participantLimitReached
    case syncConflict

    var errorDescription: String? {
        // User-friendly messages
    }
}
```

### 7.2 Error Propagation

- Use `async throws` for all async operations
- Catch and handle at appropriate boundaries
- Present user-friendly error dialogs
- Log detailed errors for debugging

### 7.3 Retry Logic

```swift
func withRetry<T>(
    maxAttempts: Int = 3,
    delay: TimeInterval = 1.0,
    operation: () async throws -> T
) async throws -> T {
    var lastError: Error?

    for attempt in 1...maxAttempts {
        do {
            return try await operation()
        } catch {
            lastError = error
            if attempt < maxAttempts {
                try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            }
        }
    }

    throw lastError!
}
```

## 8. Performance Considerations

### 8.1 Memory Management

- Use weak references for delegates
- Implement entity pooling for code windows
- Lazy load code content
- Aggressive cleanup of off-screen entities

### 8.2 Rendering Optimization

- Frustum culling
- Distance-based LOD
- Occlusion culling
- Batch rendering of dependencies

### 8.3 Background Processing

- Repository cloning on background queue
- Code parsing on dedicated queue
- Index building asynchronously

### 8.4 Caching Strategy

- Parsed syntax trees cached in memory
- Dependency graph cached in SQLite
- Remote API responses cached with expiry

## 9. Security Architecture Integration

- OAuth tokens stored in Keychain
- Repository data never leaves device
- End-to-end encryption for SharePlay
- Audit logging for enterprise features

## 10. Testing Strategy

### 10.1 Unit Testing
- XCTest for business logic
- Mock implementations of protocols
- Focus on managers and services

### 10.2 Integration Testing
- Test API integrations with test servers
- Test Git operations on sample repos
- Test parsing on various codebases

### 10.3 UI Testing
- XCUITest for SwiftUI flows
- Spatial interaction testing framework
- Screenshot testing for layouts

## 11. Build Configuration

### 11.1 Targets

- **SpatialCodeReviewer**: Main app target
- **SpatialCodeReviewerTests**: Unit tests
- **SpatialCodeReviewerUITests**: UI tests
- **CodeAnalysisKit**: Framework for code analysis
- **GitKit**: Framework for Git operations

### 11.2 Build Schemes

- **Debug**: Full logging, no optimizations
- **Release**: Optimizations enabled, minimal logging
- **TestFlight**: Analytics enabled, beta features

## 12. Deployment

### 12.1 App Store Requirements

- visionOS 2.0+ deployment target
- Required capabilities: GroupActivities, CloudKit
- Privacy manifest for data collection
- Export compliance documentation

### 12.2 Asset Management

- Use Asset Catalog for images
- 3D models in USDZ format
- Sounds in AAC format
- Localization support (en, es, de, fr, ja, zh)

## 13. Future Extensibility

### 13.1 Plugin Architecture (Phase 3)

```swift
protocol CodeAnalysisPlugin {
    var supportedLanguages: [Language] { get }
    func analyze(code: String) async throws -> [AnalysisResult]
}
```

### 13.2 Custom Layout Engines

```swift
protocol LayoutEngine {
    func layout(entities: [Entity]) -> [Transform]
}
```

### 13.3 API for Third-Party Integrations

- REST API for custom tools
- Webhook support for CI/CD integration
- Custom theme engines

## 14. Migration Strategy

### 14.1 Data Migration
- Core Data versioning and migration
- SQLite schema migrations
- CloudKit schema evolution

### 14.2 API Version Management
- Support multiple API versions
- Graceful degradation for old versions

## 15. Monitoring & Observability

### 15.1 Telemetry

```swift
enum TelemetryEvent {
    case sessionStarted
    case codeFileOpened(language: Language)
    case dependencyGraphViewed
    case collaborationSessionJoined
    case reviewSubmitted
}

class TelemetryService {
    func track(_ event: TelemetryEvent, properties: [String: Any] = [:])
}
```

### 15.2 Performance Metrics

- Frame rate monitoring
- Memory usage tracking
- API latency measurement
- Parse time tracking

## 16. Open Issues & Decisions

| Issue | Status | Decision Needed By |
|-------|--------|-------------------|
| SwiftData vs Core Data | Open | Sprint 1 |
| libgit2 vs native Git | Open | Sprint 1 |
| Force-directed vs hierarchical layout | Open | Sprint 2 |
| Max participants in collaboration | Open | Sprint 3 |

## 17. References

- [PRD.md](../PRD.md): Product requirements
- [Data Models Document](./02-data-models.md)
- [Security Architecture Document](./10-security-architecture.md)
- Apple visionOS Documentation: https://developer.apple.com/visionos/

## 18. Revision History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2025-11-24 | Engineering Team | Initial draft |
