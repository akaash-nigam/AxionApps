# Data Models & Schema Design Document

## Document Information
- **Version**: 1.0
- **Last Updated**: 2025-11-24
- **Status**: Draft
- **Owner**: Engineering Team

## 1. Overview

This document defines all data models, database schemas, and persistence strategies for Spatial Code Reviewer. The application uses multiple storage mechanisms optimized for different data types and access patterns.

## 2. Storage Architecture

### 2.1 Storage Systems

| System | Purpose | Data Stored | Persistence |
|--------|---------|-------------|-------------|
| **Core Data** | Local application data | Repositories, sessions, preferences | Device |
| **SQLite** | Code index & search | Parsed code, symbols, dependencies | Device |
| **CloudKit** | Collaboration sync | Session state, shared annotations | Cloud |
| **File System** | Git repositories | Cloned repos, working trees | Device |
| **Keychain** | Secure storage | OAuth tokens, API keys | Device (Encrypted) |
| **UserDefaults** | User preferences | Settings, UI state | Device |

### 2.2 Data Flow

```
User Action
    ↓
Business Logic Layer
    ↓
├─→ Core Data (App metadata)
├─→ SQLite (Code index)
├─→ CloudKit (Shared state)
├─→ File System (Git data)
└─→ Keychain (Secrets)
```

## 3. Core Data Models

### 3.1 Entity Relationship Diagram

```
┌──────────────┐         ┌──────────────┐         ┌──────────────┐
│  Repository  │1──────*│   Session    │*──────*│ Participant  │
└──────────────┘         └──────────────┘         └──────────────┘
       │1                        │1
       │                         │
       │*                        │*
┌──────────────┐         ┌──────────────┐
│   Branch     │         │   Comment    │
└──────────────┘         └──────────────┘
       │1
       │
       │*
┌──────────────┐
│ PullRequest  │
└──────────────┘
       │1
       │
       │*
┌──────────────┐
│  CodeChange  │
└──────────────┘
```

### 3.2 Repository Entity

```swift
@Model
class Repository {
    @Attribute(.unique) var id: UUID
    var name: String
    var url: URL
    var localPath: URL
    var provider: RepositoryProvider // GitHub, GitLab, Bitbucket
    var defaultBranch: String
    var lastSynced: Date
    var isIndexed: Bool
    var indexVersion: Int
    var starCount: Int?
    var description: String?
    var language: String?
    var createdAt: Date
    var updatedAt: Date

    // Relationships
    @Relationship(deleteRule: .cascade) var branches: [Branch] = []
    @Relationship(deleteRule: .cascade) var sessions: [Session] = []

    init(name: String, url: URL, localPath: URL, provider: RepositoryProvider) {
        self.id = UUID()
        self.name = name
        self.url = url
        self.localPath = localPath
        self.provider = provider
        self.defaultBranch = "main"
        self.lastSynced = Date()
        self.isIndexed = false
        self.indexVersion = 0
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

enum RepositoryProvider: String, Codable {
    case github = "github"
    case gitlab = "gitlab"
    case bitbucket = "bitbucket"
    case azureDevOps = "azure_devops"
}
```

### 3.3 Branch Entity

```swift
@Model
class Branch {
    @Attribute(.unique) var id: UUID
    var name: String
    var commitSHA: String
    var lastCommitDate: Date
    var isActive: Bool
    var createdAt: Date

    // Relationships
    var repository: Repository?
    @Relationship(deleteRule: .cascade) var pullRequests: [PullRequest] = []

    init(name: String, commitSHA: String) {
        self.id = UUID()
        self.name = name
        self.commitSHA = commitSHA
        self.lastCommitDate = Date()
        self.isActive = false
        self.createdAt = Date()
    }
}
```

### 3.4 PullRequest Entity

```swift
@Model
class PullRequest {
    @Attribute(.unique) var id: UUID
    var number: Int
    var title: String
    var description: String?
    var state: PRState
    var author: String
    var authorAvatarURL: URL?
    var sourceBranch: String
    var targetBranch: String
    var createdAt: Date
    var updatedAt: Date
    var mergedAt: Date?
    var closedAt: Date?
    var isDraft: Bool
    var changedFiles: Int
    var additions: Int
    var deletions: Int
    var remoteID: String // ID from external system

    // Relationships
    var branch: Branch?
    @Relationship(deleteRule: .cascade) var changes: [CodeChange] = []

    init(number: Int, title: String, author: String, remoteID: String) {
        self.id = UUID()
        self.number = number
        self.title = title
        self.author = author
        self.remoteID = remoteID
        self.state = .open
        self.sourceBranch = ""
        self.targetBranch = ""
        self.isDraft = false
        self.changedFiles = 0
        self.additions = 0
        self.deletions = 0
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

enum PRState: String, Codable {
    case open = "open"
    case closed = "closed"
    case merged = "merged"
}
```

### 3.5 CodeChange Entity

```swift
@Model
class CodeChange {
    @Attribute(.unique) var id: UUID
    var filePath: String
    var changeType: ChangeType
    var additions: Int
    var deletions: Int
    var patch: String?
    var oldContent: String?
    var newContent: String?
    var language: String?

    // Relationships
    var pullRequest: PullRequest?

    init(filePath: String, changeType: ChangeType) {
        self.id = UUID()
        self.filePath = filePath
        self.changeType = changeType
        self.additions = 0
        self.deletions = 0
    }
}

enum ChangeType: String, Codable {
    case added = "added"
    case modified = "modified"
    case deleted = "deleted"
    case renamed = "renamed"
}
```

### 3.6 Session Entity

```swift
@Model
class Session {
    @Attribute(.unique) var id: UUID
    var name: String
    var sessionType: SessionType
    var startedAt: Date
    var endedAt: Date?
    var isActive: Bool
    var cloudKitRecordID: String?

    // Spatial state
    var layoutType: String // "hemisphere", "focus", "comparison", "architecture"
    var cameraPosition: Data? // Encoded Transform
    var openFileIDs: [String] = [] // File paths currently open

    // Relationships
    var repository: Repository?
    @Relationship(deleteRule: .cascade) var comments: [Comment] = []
    @Relationship(deleteRule: .cascade) var participants: [Participant] = []

    init(name: String, sessionType: SessionType) {
        self.id = UUID()
        self.name = name
        self.sessionType = sessionType
        self.startedAt = Date()
        self.isActive = true
        self.layoutType = "hemisphere"
        self.openFileIDs = []
    }
}

enum SessionType: String, Codable {
    case solo = "solo"
    case collaborative = "collaborative"
}
```

### 3.7 Participant Entity

```swift
@Model
class Participant {
    @Attribute(.unique) var id: UUID
    var name: String
    var email: String?
    var avatarURL: URL?
    var joinedAt: Date
    var leftAt: Date?
    var isHost: Bool

    // Spatial state
    var position: Data? // Encoded Transform
    var gazeTarget: String? // File path or entity ID
    var isActive: Bool

    // Relationships
    var session: Session?

    init(name: String, isHost: Bool) {
        self.id = UUID()
        self.name = name
        self.isHost = isHost
        self.joinedAt = Date()
        self.isActive = true
    }
}
```

### 3.8 Comment Entity

```swift
@Model
class Comment {
    @Attribute(.unique) var id: UUID
    var text: String
    var author: String
    var authorAvatarURL: URL?
    var createdAt: Date
    var updatedAt: Date
    var isResolved: Bool
    var remoteID: String? // ID from external system

    // Code location
    var filePath: String
    var lineNumber: Int?
    var lineRange: Range<Int>?

    // Spatial position (for spatial annotations)
    var spatialPosition: Data? // Encoded Transform

    // Relationships
    var session: Session?
    @Relationship(deleteRule: .cascade) var replies: [Comment] = []
    var parentComment: Comment?

    init(text: String, author: String, filePath: String) {
        self.id = UUID()
        self.text = text
        self.author = author
        self.filePath = filePath
        self.createdAt = Date()
        self.updatedAt = Date()
        self.isResolved = false
    }
}
```

### 3.9 Preference Entity

```swift
@Model
class Preference {
    @Attribute(.unique) var id: UUID
    var key: String
    var value: Data // Encoded value
    var updatedAt: Date

    init(key: String, value: Data) {
        self.id = UUID()
        self.key = key
        self.value = value
        self.updatedAt = Date()
    }
}
```

## 4. SQLite Code Index Schema

### 4.1 Purpose
Fast full-text search, symbol lookup, and dependency queries for code analysis.

### 4.2 Tables

#### 4.2.1 files
```sql
CREATE TABLE files (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    repository_id TEXT NOT NULL,
    path TEXT NOT NULL,
    language TEXT,
    size_bytes INTEGER,
    line_count INTEGER,
    content_hash TEXT,
    last_modified TIMESTAMP,
    last_indexed TIMESTAMP,
    UNIQUE(repository_id, path)
);

CREATE INDEX idx_files_repo ON files(repository_id);
CREATE INDEX idx_files_language ON files(language);
CREATE INDEX idx_files_path ON files(path);
```

#### 4.2.2 symbols
```sql
CREATE TABLE symbols (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    file_id INTEGER NOT NULL,
    name TEXT NOT NULL,
    kind TEXT NOT NULL, -- 'function', 'class', 'variable', 'interface', etc.
    line_start INTEGER,
    line_end INTEGER,
    column_start INTEGER,
    column_end INTEGER,
    signature TEXT,
    parent_symbol_id INTEGER,
    FOREIGN KEY (file_id) REFERENCES files(id) ON DELETE CASCADE,
    FOREIGN KEY (parent_symbol_id) REFERENCES symbols(id) ON DELETE CASCADE
);

CREATE INDEX idx_symbols_file ON symbols(file_id);
CREATE INDEX idx_symbols_name ON symbols(name);
CREATE INDEX idx_symbols_kind ON symbols(kind);
CREATE INDEX idx_symbols_parent ON symbols(parent_symbol_id);

-- Full-text search on symbol names
CREATE VIRTUAL TABLE symbols_fts USING fts5(
    name,
    signature,
    content='symbols',
    content_rowid='id'
);
```

#### 4.2.3 dependencies
```sql
CREATE TABLE dependencies (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    source_file_id INTEGER NOT NULL,
    target_file_id INTEGER NOT NULL,
    dependency_type TEXT NOT NULL, -- 'import', 'inheritance', 'call', 'reference'
    source_line INTEGER,
    target_symbol_id INTEGER,
    strength INTEGER DEFAULT 1, -- Number of references
    FOREIGN KEY (source_file_id) REFERENCES files(id) ON DELETE CASCADE,
    FOREIGN KEY (target_file_id) REFERENCES files(id) ON DELETE CASCADE,
    FOREIGN KEY (target_symbol_id) REFERENCES symbols(id) ON DELETE SET NULL,
    UNIQUE(source_file_id, target_file_id, dependency_type, source_line)
);

CREATE INDEX idx_dependencies_source ON dependencies(source_file_id);
CREATE INDEX idx_dependencies_target ON dependencies(target_file_id);
CREATE INDEX idx_dependencies_type ON dependencies(dependency_type);
```

#### 4.2.4 code_content
```sql
-- Full-text search on code content
CREATE VIRTUAL TABLE code_content USING fts5(
    file_path,
    content,
    language
);
```

#### 4.2.5 issues_link
```sql
CREATE TABLE issues_link (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    issue_id TEXT NOT NULL, -- External issue ID
    file_id INTEGER NOT NULL,
    line_start INTEGER,
    line_end INTEGER,
    linked_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (file_id) REFERENCES files(id) ON DELETE CASCADE
);

CREATE INDEX idx_issues_link_issue ON issues_link(issue_id);
CREATE INDEX idx_issues_link_file ON issues_link(file_id);
```

#### 4.2.6 metadata
```sql
CREATE TABLE metadata (
    key TEXT PRIMARY KEY,
    value TEXT,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Store index version, last full index, etc.
INSERT INTO metadata (key, value) VALUES
    ('schema_version', '1'),
    ('last_full_index', NULL);
```

### 4.3 Query Examples

#### Find all dependencies of a file
```sql
SELECT
    f.path,
    d.dependency_type,
    d.strength
FROM dependencies d
JOIN files f ON d.target_file_id = f.id
WHERE d.source_file_id = ?
ORDER BY d.strength DESC;
```

#### Find circular dependencies
```sql
WITH RECURSIVE dependency_chain AS (
    SELECT source_file_id, target_file_id, source_file_id as root_file, 1 as depth
    FROM dependencies
    UNION ALL
    SELECT d.source_file_id, d.target_file_id, dc.root_file, dc.depth + 1
    FROM dependencies d
    JOIN dependency_chain dc ON d.source_file_id = dc.target_file_id
    WHERE dc.depth < 10
)
SELECT DISTINCT
    f1.path as start_file,
    f2.path as end_file
FROM dependency_chain dc
JOIN files f1 ON dc.root_file = f1.id
JOIN files f2 ON dc.target_file_id = f2.id
WHERE dc.root_file = dc.target_file_id AND dc.depth > 1;
```

#### Full-text code search
```sql
SELECT
    f.path,
    snippet(code_content, 1, '<mark>', '</mark>', '...', 30) as snippet
FROM code_content
JOIN files f ON code_content.file_path = f.path
WHERE code_content MATCH ?
ORDER BY rank
LIMIT 50;
```

#### Find symbol references
```sql
SELECT
    f.path,
    s.name,
    s.line_start,
    s.kind
FROM symbols s
JOIN files f ON s.file_id = f.id
WHERE s.name = ?
ORDER BY f.path, s.line_start;
```

## 5. CloudKit Schema

### 5.1 Record Types

#### 5.1.1 CKSession
```swift
struct CKSessionRecord {
    static let recordType = "Session"

    let sessionID: String // Primary key
    let repositoryURL: String
    let branchName: String
    let layoutType: String
    let openFiles: [String]
    let hostParticipantID: String
    let createdAt: Date
    let lastModified: Date
}
```

#### 5.1.2 CKParticipant
```swift
struct CKParticipantRecord {
    static let recordType = "Participant"

    let participantID: String // Primary key
    let sessionID: CKRecord.Reference // Foreign key
    let name: String
    let positionX: Double
    let positionY: Double
    let positionZ: Double
    let rotationX: Double
    let rotationY: Double
    let rotationZ: Double
    let rotationW: Double
    let gazeTarget: String?
    let isActive: Bool
    let lastUpdate: Date
}
```

#### 5.1.3 CKAnnotation
```swift
struct CKAnnotationRecord {
    static let recordType = "Annotation"

    let annotationID: String // Primary key
    let sessionID: CKRecord.Reference // Foreign key
    let authorID: String
    let authorName: String
    let text: String
    let filePath: String
    let lineNumber: Int?
    let spatialPositionX: Double?
    let spatialPositionY: Double?
    let spatialPositionZ: Double?
    let createdAt: Date
    let isResolved: Bool
}
```

#### 5.1.4 CKCodeWindow
```swift
struct CKCodeWindowRecord {
    static let recordType = "CodeWindow"

    let windowID: String // Primary key
    let sessionID: CKRecord.Reference // Foreign key
    let filePath: String
    let positionX: Double
    let positionY: Double
    let positionZ: Double
    let scaleX: Double
    let scaleY: Double
    let scaleZ: Double
    let isVisible: Bool
    let lastModified: Date
}
```

### 5.2 CloudKit Zones

- **Private Database**: User's personal sessions and preferences
- **Shared Database**: Collaborative sessions (using CKShare)

### 5.3 Sync Strategy

```swift
class CloudKitSyncService {
    func syncSession(_ session: Session) async throws {
        let record = CKRecord(recordType: "Session")
        record["sessionID"] = session.id.uuidString
        record["repositoryURL"] = session.repository?.url.absoluteString
        record["layoutType"] = session.layoutType
        record["openFiles"] = session.openFileIDs
        // ... etc

        try await database.save(record)
    }

    func subscribeToSessionChanges(_ sessionID: String) async throws {
        let predicate = NSPredicate(format: "sessionID == %@", sessionID)
        let subscription = CKQuerySubscription(
            recordType: "Participant",
            predicate: predicate,
            options: [.firesOnRecordCreation, .firesOnRecordUpdate]
        )
        try await database.save(subscription)
    }
}
```

## 6. File System Layout

### 6.1 Application Directory Structure

```
~/Library/Application Support/SpatialCodeReviewer/
├── Repositories/
│   ├── {repository_id}/
│   │   ├── .git/              # Git repository
│   │   └── workspace/         # Working tree
├── Cache/
│   ├── SyntaxTrees/           # Cached parse trees
│   ├── Assets/                # Downloaded avatars, etc.
│   └── Thumbnails/            # File previews
├── Index/
│   └── code_index.db          # SQLite code index
└── Logs/
    └── app.log                # Application logs
```

### 6.2 Repository Storage

- Each repository stored in isolated directory
- Git operations use libgit2 pointing to repository path
- Working tree contains checked out files for review

## 7. Keychain Storage

### 7.1 Stored Credentials

```swift
struct KeychainItem {
    enum ItemType: String {
        case githubToken = "com.spatialcodereviewer.github.token"
        case gitlabToken = "com.spatialcodereviewer.gitlab.token"
        case bitbucketToken = "com.spatialcodereviewer.bitbucket.token"
        case jiraToken = "com.spatialcodereviewer.jira.token"
    }

    let service: String
    let account: String
    let type: ItemType
}

class KeychainService {
    func save(_ token: String, for type: KeychainItem.ItemType) throws
    func retrieve(for type: KeychainItem.ItemType) throws -> String
    func delete(for type: KeychainItem.ItemType) throws
}
```

## 8. UserDefaults Keys

### 8.1 Preference Keys

```swift
enum PreferenceKey: String {
    // UI Preferences
    case theme = "ui.theme" // "light", "dark", "auto"
    case fontSize = "ui.fontSize" // 14-18
    case lineHeight = "ui.lineHeight" // 1.5

    // Spatial Preferences
    case defaultLayout = "spatial.defaultLayout"
    case windowOpacity = "spatial.windowOpacity" // 0.7-1.0
    case maxWindowDistance = "spatial.maxWindowDistance" // 2-10 feet

    // Behavior
    case autoSync = "behavior.autoSync"
    case maxCollaborators = "behavior.maxCollaborators" // 2-8
    case enableSpatialAudio = "behavior.enableSpatialAudio"

    // Performance
    case maxConcurrentWindows = "performance.maxConcurrentWindows" // 20-50
    case enableCaching = "performance.enableCaching"
    case indexingStrategy = "performance.indexingStrategy" // "immediate", "background"

    // Privacy
    case enableTelemetry = "privacy.enableTelemetry"
    case shareUsageData = "privacy.shareUsageData"
}
```

## 9. Data Migration Strategy

### 9.1 Core Data Migration

```swift
lazy var persistentContainer: NSPersistentContainer = {
    let container = NSPersistentContainer(name: "SpatialCodeReviewer")

    // Enable lightweight migration
    let description = container.persistentStoreDescriptions.first
    description?.shouldMigrateStoreAutomatically = true
    description?.shouldInferMappingModelAutomatically = true

    container.loadPersistentStores { storeDescription, error in
        if let error = error {
            fatalError("Core Data migration failed: \(error)")
        }
    }

    return container
}()
```

### 9.2 SQLite Migration

```swift
class SQLiteMigrationManager {
    func migrate(from oldVersion: Int, to newVersion: Int) throws {
        for version in (oldVersion + 1)...newVersion {
            try executeMigration(to: version)
        }
    }

    private func executeMigration(to version: Int) throws {
        let sql = try loadMigrationSQL(for: version)
        try database.execute(sql)
        try updateSchemaVersion(to: version)
    }
}

// Migration files:
// Migrations/
//   001_initial_schema.sql
//   002_add_issues_link.sql
//   003_add_fts_indices.sql
```

## 10. Data Validation

### 10.1 Validation Rules

```swift
protocol Validatable {
    func validate() throws
}

extension Repository: Validatable {
    func validate() throws {
        guard !name.isEmpty else {
            throw ValidationError.emptyField("name")
        }
        guard url.scheme == "https" || url.scheme == "http" else {
            throw ValidationError.invalidURL
        }
        guard FileManager.default.fileExists(atPath: localPath.path) else {
            throw ValidationError.pathNotFound
        }
    }
}

enum ValidationError: LocalizedError {
    case emptyField(String)
    case invalidURL
    case pathNotFound
    case invalidFormat(String)

    var errorDescription: String? {
        switch self {
        case .emptyField(let field):
            return "Field '\(field)' cannot be empty"
        case .invalidURL:
            return "Invalid repository URL"
        case .pathNotFound:
            return "Local path does not exist"
        case .invalidFormat(let field):
            return "Invalid format for field '\(field)'"
        }
    }
}
```

## 11. Performance Optimization

### 11.1 Core Data Optimization

```swift
// Batch fetching for relationships
let request = Repository.fetchRequest()
request.relationshipKeyPathsForPrefetching = ["branches", "sessions"]

// Faulting for large objects
let request = Session.fetchRequest()
request.returnsObjectsAsFaults = true

// Batch operations
context.performBatch { batchContext in
    // Bulk updates
}
```

### 11.2 SQLite Optimization

```sql
-- Use prepared statements
PRAGMA journal_mode = WAL; -- Write-Ahead Logging
PRAGMA synchronous = NORMAL;
PRAGMA cache_size = -64000; -- 64MB cache
PRAGMA temp_store = MEMORY;

-- Analyze tables periodically
ANALYZE;
```

### 11.3 Caching Strategy

```swift
class CacheManager {
    private let cache = NSCache<NSString, AnyObject>()

    init() {
        cache.countLimit = 100 // Max 100 items
        cache.totalCostLimit = 50 * 1024 * 1024 // 50 MB
    }

    func cacheParseTree(_ tree: SyntaxTree, for file: String) {
        cache.setObject(tree as AnyObject, forKey: file as NSString)
    }

    func getParseTree(for file: String) -> SyntaxTree? {
        return cache.object(forKey: file as NSString) as? SyntaxTree
    }
}
```

## 12. Data Privacy & Security

### 12.1 Data Classification

| Data Type | Classification | Storage | Encryption |
|-----------|---------------|---------|------------|
| OAuth Tokens | Secret | Keychain | Yes (System) |
| Repository Content | Private | File System | Optional |
| User Comments | Private | Core Data | Optional |
| Session State | Private | CloudKit | Yes (E2E) |
| Usage Telemetry | Anonymous | Cloud | Yes (TLS) |

### 12.2 Data Retention

- Local repositories: Retained until user deletes
- Session history: 90 days (configurable)
- CloudKit sessions: 30 days after end
- Cache data: 7 days
- Logs: 30 days

## 13. Backup & Recovery

### 13.1 Backup Strategy

```swift
class BackupManager {
    func backupUserData() async throws {
        // Backup Core Data
        try await backupCoreData()

        // Backup preferences
        try await backupPreferences()

        // Backup index
        try await backupCodeIndex()

        // Repository data not backed up (can be re-cloned)
    }

    func restoreUserData(from backup: URL) async throws {
        try await restoreCoreData(from: backup)
        try await restorePreferences(from: backup)
        try await restoreCodeIndex(from: backup)
    }
}
```

## 14. Testing Data

### 14.1 Mock Data Generation

```swift
extension Repository {
    static func mockRepository() -> Repository {
        Repository(
            name: "test-repo",
            url: URL(string: "https://github.com/test/repo")!,
            localPath: URL(fileURLWithPath: "/tmp/test-repo"),
            provider: .github
        )
    }
}

class TestDataGenerator {
    func generateMockCodeIndex(fileCount: Int) async throws {
        for i in 0..<fileCount {
            let file = createMockFile(index: i)
            try await insertIntoIndex(file)
        }
    }
}
```

## 15. References

- [System Architecture Document](./01-system-architecture.md)
- [Security Architecture Document](./10-security-architecture.md)
- Apple Core Data Documentation
- SQLite Documentation
- CloudKit Documentation

## 16. Revision History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2025-11-24 | Engineering Team | Initial draft |
