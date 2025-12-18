# Legal Discovery Universe - System Architecture

## 1. Architecture Overview

### 1.1 High-Level Architecture

The Legal Discovery Universe is built on a multi-tier architecture optimized for visionOS spatial computing:

```
┌─────────────────────────────────────────────────────────────┐
│                   visionOS Presentation Layer                │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │   Windows    │  │   Volumes    │  │ Immersive    │      │
│  │  (2D Panels) │  │ (3D Bounded) │  │   Spaces     │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                   Application Layer (SwiftUI)                │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │ View Models  │  │  UI State    │  │  Navigation  │      │
│  │  (@Observable)│  │  Management  │  │  Coordinator │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                      Business Logic Layer                    │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │ Legal AI     │  │ Document     │  │ Discovery    │      │
│  │ Engine       │  │ Processing   │  │ Services     │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                      Data Access Layer                       │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │  SwiftData   │  │   Cache      │  │  Network     │      │
│  │  Repository  │  │   Manager    │  │  Client      │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                      Infrastructure Layer                    │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │  Local DB    │  │   Backend    │  │   Security   │      │
│  │  (SwiftData) │  │   APIs       │  │   Services   │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└─────────────────────────────────────────────────────────────┘
```

### 1.2 Design Principles

1. **Security First**: All data encrypted at rest and in transit
2. **Spatial Native**: Optimized for 3D interaction paradigms
3. **AI-Augmented**: Intelligence layer enhances human decision-making
4. **Scalable Architecture**: Handle 100M+ documents per case
5. **Offline Capable**: Core features work without connectivity
6. **Enterprise Grade**: Bank-level security and compliance

## 2. visionOS-Specific Architecture

### 2.1 Spatial Presentation Modes

#### WindowGroup - Primary Interface
```swift
// Main document review and case management
WindowGroup("Discovery Workspace") {
    DiscoveryWorkspaceView()
}
.defaultSize(width: 1200, height: 900)
.windowResizability(.contentSize)
```

**Use Cases**:
- Document list and search interface
- Case management dashboard
- Settings and preferences
- Document detail view
- Timeline editor

#### Volume - 3D Evidence Visualization
```swift
// 3D document galaxies and relationship maps
WindowGroup("Evidence Universe", id: "evidence-universe") {
    EvidenceUniverseView()
}
.windowStyle(.volumetric)
.defaultSize(width: 1.5, height: 1.5, depth: 1.5, in: .meters)
```

**Use Cases**:
- Document clustering visualization
- Communication network graphs
- Timeline rivers
- Entity constellation maps
- Privilege landscape visualization

#### ImmersiveSpace - Full Investigation Mode
```swift
// Fully immersive case exploration
ImmersiveSpace(id: "case-investigation") {
    CaseInvestigationSpace()
}
.immersionStyle(selection: $immersionLevel, in: .progressive)
```

**Use Cases**:
- Deep case investigation
- Multi-dimensional evidence analysis
- Team collaboration war rooms
- Presentation mode for clients
- Trial preparation environments

### 2.2 Scene Architecture

```
App Scene Hierarchy
├── DiscoveryApp (App)
│   ├── WindowGroup: "Discovery Workspace" (Default)
│   ├── WindowGroup: "Evidence Universe" (Volumetric)
│   ├── WindowGroup: "Timeline View" (Volumetric)
│   ├── WindowGroup: "Network Analysis" (Volumetric)
│   └── ImmersiveSpace: "Case Investigation" (Progressive/Full)
```

### 2.3 Spatial Computing Features

- **Hand Tracking**: Gesture-based document manipulation
- **Eye Tracking**: Focus-aware UI and reading optimization
- **Spatial Audio**: Audio cues for notifications and guidance
- **Anchored Content**: Pin important documents in space
- **Persistent Spaces**: Restore spatial layouts per case

## 3. Data Architecture

### 3.1 Core Data Models

```swift
// Case Model
@Model
class LegalCase {
    @Attribute(.unique) var id: UUID
    var caseNumber: String
    var title: String
    var description: String
    var status: CaseStatus
    var createdDate: Date
    var lastModified: Date

    // Relationships
    @Relationship(deleteRule: .cascade) var documents: [Document]
    @Relationship(deleteRule: .cascade) var entities: [Entity]
    @Relationship(deleteRule: .cascade) var timelines: [Timeline]
    @Relationship(deleteRule: .cascade) var tags: [Tag]
    @Relationship(deleteRule: .cascade) var collaborators: [Collaborator]

    // Metadata
    var metadata: CaseMetadata
    var securityLevel: SecurityLevel
    var privilegeFlags: PrivilegeFlags
}

// Document Model
@Model
class Document {
    @Attribute(.unique) var id: UUID
    var fileName: String
    var fileType: FileType
    var fileSize: Int64
    var contentHash: String

    // Content
    var extractedText: String
    var ocrText: String?
    var metadata: DocumentMetadata

    // AI Analysis
    var relevanceScore: Double
    var privilegeStatus: PrivilegeStatus
    var aiAnalysis: AIAnalysis

    // Relationships
    @Relationship(inverse: \LegalCase.documents) var legalCase: LegalCase?
    @Relationship var relatedDocuments: [Document]
    @Relationship var entities: [Entity]
    @Relationship var tags: [Tag]

    // Spatial Properties
    var spatialPosition: SpatialPosition?
    var visualizationMetadata: VisualizationMetadata

    // Dates
    var documentDate: Date?
    var createdDate: Date
    var modifiedDate: Date
    var reviewedDate: Date?
}

// Entity Model (People, Organizations, etc.)
@Model
class Entity {
    @Attribute(.unique) var id: UUID
    var name: String
    var type: EntityType // Person, Organization, Location, etc.
    var aliases: [String]

    // Relationships
    @Relationship var documents: [Document]
    @Relationship var connections: [EntityConnection]

    // AI Insights
    var importance: Double
    var sentiment: Double
    var role: String?
}

// Timeline Model
@Model
class Timeline {
    @Attribute(.unique) var id: UUID
    var name: String
    var description: String

    @Relationship(deleteRule: .cascade) var events: [TimelineEvent]
    @Relationship(inverse: \LegalCase.timelines) var legalCase: LegalCase?
}

// Tag/Issue Model
@Model
class Tag {
    @Attribute(.unique) var id: UUID
    var name: String
    var color: String
    var category: TagCategory

    @Relationship var documents: [Document]
}
```

### 3.2 Supporting Models

```swift
// Metadata Structures
struct DocumentMetadata: Codable {
    var author: String?
    var recipient: [String]?
    var cc: [String]?
    var bcc: [String]?
    var subject: String?
    var dateCreated: Date?
    var dateModified: Date?
    var custodian: String?
    var source: String?
    var confidentialityLevel: String?
}

struct AIAnalysis: Codable {
    var relevanceScore: Double
    var privilegeConfidence: Double
    var keyPhrases: [String]
    var entities: [String]
    var sentiment: Double
    var topics: [String]
    var suggestedTags: [String]
    var relationships: [String]
}

struct SpatialPosition: Codable {
    var x: Float
    var y: Float
    var z: Float
    var scale: Float
    var rotation: SIMD3<Float>
}

// Enumerations
enum CaseStatus: String, Codable {
    case active, archived, closed
}

enum FileType: String, Codable {
    case email, pdf, word, excel, image, video, audio, other
}

enum PrivilegeStatus: String, Codable {
    case notPrivileged, attorneyClient, workProduct, confidential, contested
}

enum EntityType: String, Codable {
    case person, organization, location, event, product, other
}

enum SecurityLevel: String, Codable {
    case public, internal, confidential, restricted, topSecret
}
```

### 3.3 Data Flow Architecture

```
Data Ingestion Flow:
┌─────────────┐
│  Raw Files  │
└──────┬──────┘
       ↓
┌──────────────────┐
│  File Processor  │
│  - Format detect │
│  - Extract text  │
│  - Extract meta  │
└──────┬───────────┘
       ↓
┌──────────────────┐
│   AI Pipeline    │
│  - Relevance     │
│  - Privilege     │
│  - Entities      │
│  - Relationships │
└──────┬───────────┘
       ↓
┌──────────────────┐
│   SwiftData DB   │
│  - Store docs    │
│  - Index        │
│  - Cache        │
└──────────────────┘
```

## 4. Service Layer Architecture

### 4.1 Core Services

```swift
// Document Service
protocol DocumentService {
    func importDocuments(from urls: [URL]) async throws -> [Document]
    func searchDocuments(query: SearchQuery) async throws -> [Document]
    func analyzeDocument(_ document: Document) async throws -> AIAnalysis
    func exportDocuments(_ documents: [Document], format: ExportFormat) async throws -> URL
}

// AI Service
protocol AIService {
    func analyzeRelevance(_ document: Document) async throws -> Double
    func detectPrivilege(_ document: Document) async throws -> PrivilegeStatus
    func extractEntities(_ document: Document) async throws -> [Entity]
    func findRelationships(between documents: [Document]) async throws -> [DocumentRelationship]
    func generateInsights(for case: LegalCase) async throws -> CaseInsights
}

// Visualization Service
protocol VisualizationService {
    func generateDocumentGalaxy(documents: [Document]) async -> DocumentGalaxy
    func createTimelineVisualization(events: [TimelineEvent]) async -> TimelineVisualization
    func buildNetworkGraph(entities: [Entity]) async -> NetworkGraph
    func renderPrivilegeLandscape(documents: [Document]) async -> PrivilegeLandscape
}

// Collaboration Service
protocol CollaborationService {
    func shareAnnotation(_ annotation: Annotation) async throws
    func syncDocumentState(_ document: Document) async throws
    func notifyTeamMembers(_ notification: TeamNotification) async throws
    func resolveConflicts(_ conflicts: [Conflict]) async throws -> [Resolution]
}

// Security Service
protocol SecurityService {
    func encrypt(_ data: Data) throws -> Data
    func decrypt(_ data: Data) throws -> Data
    func validateAccess(user: User, resource: Resource) async throws -> Bool
    func logAuditEvent(_ event: AuditEvent) async throws
    func detectAnomalies() async throws -> [SecurityAnomaly]
}
```

### 4.2 Service Implementation Architecture

```
Service Layer Pattern:
┌────────────────────────────────────────┐
│         Service Protocol               │
└────────────────┬───────────────────────┘
                 ↓
┌────────────────────────────────────────┐
│    Concrete Implementation             │
│  - Business logic                      │
│  - Data validation                     │
│  - Error handling                      │
└────────────────┬───────────────────────┘
                 ↓
┌────────────────────────────────────────┐
│         Repository Layer               │
│  - Data access abstraction             │
│  - Caching strategy                    │
└────────────────┬───────────────────────┘
                 ↓
┌────────────────────────────────────────┐
│      Data Source (SwiftData/API)       │
└────────────────────────────────────────┘
```

## 5. RealityKit Integration Architecture

### 5.1 Entity Component System

```swift
// Document Entity Components
struct DocumentEntityComponent: Component {
    var documentId: UUID
    var relevanceScore: Double
    var privilegeStatus: PrivilegeStatus
}

struct InteractionComponent: Component {
    var isSelectable: Bool
    var isHoverable: Bool
    var onSelect: (() -> Void)?
}

struct AnimationStateComponent: Component {
    var currentState: AnimationState
    var transitions: [AnimationTransition]
}

struct SpatialAudioComponent: Component {
    var audioResource: AudioFileResource?
    var spatialSettings: SpatialAudioSettings
}
```

### 5.2 3D Visualization Entities

```swift
// Evidence Universe System
class EvidenceUniverseSystem: System {
    static let query = EntityQuery(where: .has(DocumentEntityComponent.self))

    func update(context: SceneUpdateContext) {
        for entity in context.entities(matching: Self.query) {
            // Update document positions based on clustering
            // Apply physics for floating documents
            // Handle user interactions
        }
    }
}

// Document Galaxy Builder
class DocumentGalaxyBuilder {
    func buildGalaxy(from documents: [Document]) -> Entity {
        let galaxy = Entity()

        // Cluster documents by relevance
        let clusters = clusterByRelevance(documents)

        for (index, cluster) in clusters.enumerated() {
            let clusterEntity = createCluster(cluster, at: index)
            galaxy.addChild(clusterEntity)
        }

        return galaxy
    }

    private func createCluster(_ documents: [Document], at index: Int) -> Entity {
        let cluster = Entity()
        cluster.position = calculateClusterPosition(index)

        for document in documents {
            let docEntity = createDocumentEntity(document)
            cluster.addChild(docEntity)
        }

        return cluster
    }
}
```

### 5.3 Spatial Interaction Patterns

```
Interaction Hierarchy:
┌────────────────────────────────────────┐
│     Gesture Recognition                │
│  - Tap (select)                        │
│  - Drag (move)                         │
│  - Pinch (scale)                       │
│  - Custom gestures                     │
└────────────────┬───────────────────────┘
                 ↓
┌────────────────────────────────────────┐
│     Interaction System                 │
│  - Hit testing                         │
│  - State management                    │
│  - Event dispatch                      │
└────────────────┬───────────────────────┘
                 ↓
┌────────────────────────────────────────┐
│     Entity Response                    │
│  - Visual feedback                     │
│  - Haptic feedback                     │
│  - Audio feedback                      │
│  - State transitions                   │
└────────────────────────────────────────┘
```

## 6. State Management Strategy

### 6.1 Application State Architecture

```swift
// App-Level State
@Observable
class AppState {
    var currentUser: User?
    var activeCase: LegalCase?
    var navigationPath: [Route] = []
    var presentedWindows: Set<WindowIdentifier> = []
    var immersiveSpaceActive: Bool = false
    var settings: AppSettings

    // Services
    let documentService: DocumentService
    let aiService: AIService
    let visualizationService: VisualizationService
    let collaborationService: CollaborationService
    let securityService: SecurityService
}

// View-Specific State
@Observable
class DocumentListViewModel {
    var documents: [Document] = []
    var filteredDocuments: [Document] = []
    var searchQuery: String = ""
    var selectedDocument: Document?
    var sortOrder: SortOrder = .relevance
    var filterOptions: FilterOptions = .default

    var isLoading: Bool = false
    var error: Error?

    func loadDocuments() async { /* ... */ }
    func searchDocuments(_ query: String) async { /* ... */ }
    func selectDocument(_ document: Document) { /* ... */ }
}

@Observable
class EvidenceUniverseViewModel {
    var documents: [Document] = []
    var documentGalaxy: DocumentGalaxy?
    var selectedDocuments: Set<Document> = []
    var cameraPosition: SIMD3<Float>
    var visualizationMode: VisualizationMode = .relevance

    func updateVisualization() async { /* ... */ }
    func handleDocumentSelection(_ document: Document) { /* ... */ }
}
```

### 6.2 State Flow Pattern

```
Unidirectional Data Flow:
┌─────────────┐
│  User Input │
└──────┬──────┘
       ↓
┌──────────────┐
│   Action     │
└──────┬───────┘
       ↓
┌──────────────┐
│  ViewModel   │
│  - Logic     │
│  - Services  │
└──────┬───────┘
       ↓
┌──────────────┐
│    State     │
│   Update     │
└──────┬───────┘
       ↓
┌──────────────┐
│   View       │
│  Re-render   │
└──────────────┘
```

## 7. Network Architecture

### 7.1 API Client Design

```swift
// API Client Protocol
protocol APIClient {
    func upload(documents: [Document]) async throws -> UploadResponse
    func download(documentId: UUID) async throws -> Document
    func sync(caseId: UUID) async throws -> SyncResponse
    func search(query: SearchQuery) async throws -> SearchResponse
}

// Network Layer
class NetworkManager {
    private let session: URLSession
    private let baseURL: URL
    private let securityService: SecurityService

    func request<T: Decodable>(
        _ endpoint: Endpoint,
        method: HTTPMethod,
        body: Encodable? = nil
    ) async throws -> T {
        // Build request with authentication
        // Encrypt payload if needed
        // Execute request
        // Decrypt response
        // Parse and return
    }
}
```

### 7.2 Offline Architecture

```
Offline-First Strategy:
┌────────────────────────────────────────┐
│      Local Database (SwiftData)        │
│  - Primary data source                 │
│  - Always available                    │
└────────────────┬───────────────────────┘
                 ↓
┌────────────────────────────────────────┐
│      Sync Manager                      │
│  - Conflict resolution                 │
│  - Queue operations                    │
│  - Background sync                     │
└────────────────┬───────────────────────┘
                 ↓
┌────────────────────────────────────────┐
│      Backend APIs                      │
│  - When connectivity available         │
│  - Sync on schedule                    │
└────────────────────────────────────────┘
```

## 8. Security Architecture

### 8.1 Security Layers

```
Security Stack:
┌────────────────────────────────────────┐
│    Application Security                │
│  - Code obfuscation                    │
│  - Secure coding practices             │
│  - Input validation                    │
└────────────────┬───────────────────────┘
                 ↓
┌────────────────────────────────────────┐
│    Authentication & Authorization      │
│  - Multi-factor authentication         │
│  - Biometric authentication            │
│  - Role-based access control           │
└────────────────┬───────────────────────┘
                 ↓
┌────────────────────────────────────────┐
│    Data Security                       │
│  - AES-256 encryption at rest          │
│  - TLS 1.3 in transit                  │
│  - Secure enclaves for keys            │
└────────────────┬───────────────────────┘
                 ↓
┌────────────────────────────────────────┐
│    Audit & Compliance                  │
│  - Activity logging                    │
│  - Tamper detection                    │
│  - Chain of custody                    │
└────────────────────────────────────────┘
```

### 8.2 Encryption Strategy

```swift
// Encryption Service
class EncryptionService {
    private let keychain: KeychainManager

    func encryptDocument(_ document: Document) throws -> EncryptedDocument {
        // Generate document key
        let documentKey = generateKey()

        // Encrypt content
        let encryptedContent = try encrypt(document.content, with: documentKey)

        // Encrypt document key with master key
        let masterKey = try keychain.getMasterKey()
        let encryptedKey = try encrypt(documentKey, with: masterKey)

        return EncryptedDocument(
            content: encryptedContent,
            encryptedKey: encryptedKey,
            algorithm: .aes256GCM
        )
    }
}
```

## 9. Performance Optimization Strategy

### 9.1 Rendering Optimization

- **Level of Detail (LOD)**: Multiple model versions based on distance
- **Frustum Culling**: Only render visible entities
- **Occlusion Culling**: Skip entities behind others
- **Instancing**: Reuse geometries for similar documents
- **Lazy Loading**: Load 3D models on demand

### 9.2 Data Optimization

- **Pagination**: Load documents in batches
- **Indexing**: Fast search with SwiftData indexes
- **Caching**: Multi-tier cache strategy
  - Memory cache (hot data)
  - Disk cache (warm data)
  - Remote (cold data)
- **Compression**: Compress large text and metadata

### 9.3 Concurrency Strategy

```swift
// Actor-based concurrency for data safety
actor DocumentRepository {
    private var cache: [UUID: Document] = [:]

    func getDocument(id: UUID) async throws -> Document {
        if let cached = cache[id] {
            return cached
        }

        let document = try await loadFromDatabase(id)
        cache[id] = document
        return document
    }
}

// Task groups for parallel processing
func processDocuments(_ documents: [Document]) async throws {
    try await withThrowingTaskGroup(of: Document.self) { group in
        for document in documents {
            group.addTask {
                try await analyzeDocument(document)
            }
        }

        for try await processedDoc in group {
            await updateDocument(processedDoc)
        }
    }
}
```

## 10. Testing Architecture

### 10.1 Testing Strategy

```
Testing Pyramid:
┌─────────────────────────────────────┐
│      E2E Tests (5%)                 │
│  - Critical user flows              │
│  - Integration scenarios            │
└─────────────┬───────────────────────┘
              ↓
┌─────────────────────────────────────┐
│      UI Tests (15%)                 │
│  - View interactions                │
│  - Spatial behaviors                │
│  - Navigation flows                 │
└─────────────┬───────────────────────┘
              ↓
┌─────────────────────────────────────┐
│      Integration Tests (30%)        │
│  - Service integration              │
│  - Repository tests                 │
│  - API client tests                 │
└─────────────┬───────────────────────┘
              ↓
┌─────────────────────────────────────┐
│      Unit Tests (50%)               │
│  - ViewModels                       │
│  - Services                         │
│  - Utilities                        │
│  - Data models                      │
└─────────────────────────────────────┘
```

### 10.2 Testing Tools

- **XCTest**: Unit and UI testing
- **Quick/Nimble**: BDD-style tests
- **Instruments**: Performance profiling
- **XCUITest**: Spatial interaction testing

## 11. Deployment Architecture

### 11.1 Distribution Strategy

- **Enterprise Distribution**: Primary deployment method
- **TestFlight**: Beta testing and staged rollouts
- **App Store**: Potential future public release

### 11.2 Configuration Management

```swift
// Environment Configuration
enum Environment {
    case development, staging, production

    var apiBaseURL: URL {
        switch self {
        case .development: return URL(string: "https://dev-api.discovery.legal")!
        case .staging: return URL(string: "https://staging-api.discovery.legal")!
        case .production: return URL(string: "https://api.discovery.legal")!
        }
    }

    var encryptionLevel: EncryptionLevel {
        switch self {
        case .development: return .standard
        case .staging, .production: return .maximum
        }
    }
}
```

## 12. Scalability Considerations

### 12.1 Document Scaling

- Support 100M+ documents per case
- Distributed indexing and search
- Incremental loading and virtualization
- Cloud storage integration

### 12.2 User Scaling

- Support 500+ concurrent users
- Real-time collaboration infrastructure
- Efficient state synchronization
- Load balancing

### 12.3 Performance Targets

- **FPS**: Maintain 90 FPS minimum
- **Search**: <500ms latency
- **Load Time**: <2 seconds for visualization
- **Import**: 1M documents/hour
- **Memory**: <2GB for typical use

## 13. Monitoring and Observability

### 13.1 Application Metrics

- User session analytics
- Feature usage tracking
- Performance metrics (FPS, memory, CPU)
- Error tracking and crash reporting
- AI model performance

### 13.2 Business Metrics

- Documents processed
- Review efficiency
- Discovery cost savings
- User productivity gains
- Case outcome correlation

## 14. Future Architecture Considerations

### 14.1 Planned Enhancements

- **Quantum Computing**: Advanced pattern matching
- **Neural Interfaces**: Direct thought interaction
- **Blockchain**: Immutable evidence chain
- **Multi-modal AI**: Voice, vision, and text analysis
- **Federated Learning**: Privacy-preserving AI training

### 14.2 Technology Evolution

- Regular updates for latest visionOS features
- Integration with emerging legal tech standards
- Continuous AI model improvements
- Enhanced visualization techniques

---

**Document Version**: 1.0
**Last Updated**: 2025-11-17
**Status**: Initial Architecture Design
