# Data Model & Schema Design
## Reality Annotation Platform

**Version**: 1.0
**Date**: November 2024
**Status**: Draft

---

## 1. Overview

This document defines the data models, database schemas, and relationships for the Reality Annotation Platform. It covers both local storage (SwiftData) and cloud storage (CloudKit).

---

## 2. Domain Models

### 2.1 Core Models

#### Annotation

```swift
import Foundation
import SwiftData

@Model
final class Annotation {
    // Identity
    @Attribute(.unique) var id: UUID
    var cloudKitRecordName: String? // CKRecord.ID

    // Content
    var type: AnnotationType
    var content: AnnotationContent
    var title: String?

    // Spatial Properties
    var position: SIMD3<Float> // X, Y, Z in world coordinates
    var orientation: simd_quatf // Rotation quaternion
    var scale: Float // Size multiplier (default: 1.0)
    var anchorID: UUID // Reference to ARWorldMapAnchor

    // Organization
    var layerID: UUID
    @Relationship(deleteRule: .nullify) var layer: Layer?

    // Ownership & Permissions
    var ownerID: String // CloudKit user record name
    var permissions: [Permission]

    // Visibility Rules
    var visibilityRules: VisibilityRules?

    // Metadata
    var createdAt: Date
    var updatedAt: Date
    var isDeleted: Bool // Soft delete for sync
    var lastSyncedAt: Date?

    // Collaboration
    @Relationship(deleteRule: .cascade) var comments: [Comment]
    var reactions: [Reaction]
    var viewedBy: [String] // User IDs who have seen this
    var status: AnnotationStatus

    // Media attachments
    var attachments: [Attachment]

    init(
        id: UUID = UUID(),
        type: AnnotationType,
        content: AnnotationContent,
        position: SIMD3<Float>,
        orientation: simd_quatf = simd_quatf(angle: 0, axis: [0, 1, 0]),
        scale: Float = 1.0,
        layerID: UUID,
        ownerID: String
    ) {
        self.id = id
        self.type = type
        self.content = content
        self.position = position
        self.orientation = orientation
        self.scale = scale
        self.layerID = layerID
        self.ownerID = ownerID
        self.createdAt = Date()
        self.updatedAt = Date()
        self.isDeleted = false
        self.permissions = []
        self.comments = []
        self.reactions = []
        self.viewedBy = []
        self.status = .open
        self.attachments = []
        self.anchorID = UUID() // Will be set when AR anchor is created
    }
}
```

#### AnnotationType

```swift
enum AnnotationType: String, Codable {
    case text
    case drawing
    case photo
    case voiceMemo
    case video
    case object3D // 3D model/USDZ file
}
```

#### AnnotationContent

```swift
struct AnnotationContent: Codable {
    var text: String?
    var drawingData: Data? // PKDrawing serialized
    var mediaURL: URL? // Local file URL
    var cloudAssetID: String? // CKAsset identifier
    var richTextData: Data? // NSAttributedString data

    // Computed
    var isEmpty: Bool {
        text?.isEmpty ?? true &&
        drawingData == nil &&
        mediaURL == nil
    }
}
```

#### AnnotationStatus

```swift
enum AnnotationStatus: String, Codable {
    case open
    case inProgress
    case resolved
    case wontFix
}
```

---

#### Layer

```swift
@Model
final class Layer {
    @Attribute(.unique) var id: UUID
    var cloudKitRecordName: String?

    // Identity
    var name: String
    var icon: String // SF Symbol name
    var color: LayerColor

    // Organization
    var parentLayerID: UUID?
    @Relationship(deleteRule: .nullify) var parentLayer: Layer?
    @Relationship(deleteRule: .cascade) var childLayers: [Layer]

    // Annotations in this layer
    @Relationship(deleteRule: .nullify, inverse: \Annotation.layer)
    var annotations: [Annotation]

    // Permissions
    var ownerID: String
    var permissions: [Permission]
    var isPublic: Bool

    // Settings
    var isVisible: Bool // Toggle on/off
    var autoExpireDays: Int? // Auto-delete annotations after N days
    var defaultPermission: PermissionLevel

    // Metadata
    var createdAt: Date
    var updatedAt: Date
    var isDeleted: Bool

    init(
        id: UUID = UUID(),
        name: String,
        icon: String = "tag.fill",
        color: LayerColor = .blue,
        ownerID: String
    ) {
        self.id = id
        self.name = name
        self.icon = icon
        self.color = color
        self.ownerID = ownerID
        self.permissions = []
        self.isPublic = false
        self.isVisible = true
        self.defaultPermission = .viewer
        self.createdAt = Date()
        self.updatedAt = Date()
        self.isDeleted = false
        self.childLayers = []
        self.annotations = []
    }
}
```

#### LayerColor

```swift
enum LayerColor: String, Codable, CaseIterable {
    case red, orange, yellow, green, blue, purple, pink, gray

    var rgbHex: String {
        switch self {
        case .red: return "#FF3B30"
        case .orange: return "#FF9500"
        case .yellow: return "#FFCC00"
        case .green: return "#34C759"
        case .blue: return "#007AFF"
        case .purple: return "#AF52DE"
        case .pink: return "#FF2D55"
        case .gray: return "#8E8E93"
        }
    }
}
```

---

#### Permission

```swift
struct Permission: Codable, Identifiable {
    var id: UUID
    var userID: String // CloudKit user record name
    var level: PermissionLevel
    var grantedAt: Date
    var grantedBy: String // User ID who granted
    var expiresAt: Date?

    init(
        id: UUID = UUID(),
        userID: String,
        level: PermissionLevel,
        grantedBy: String
    ) {
        self.id = id
        self.userID = userID
        self.level = level
        self.grantedBy = grantedBy
        self.grantedAt = Date()
    }
}

enum PermissionLevel: String, Codable, Comparable {
    case viewer = "viewer"
    case commenter = "commenter"
    case editor = "editor"
    case owner = "owner"

    static func < (lhs: PermissionLevel, rhs: PermissionLevel) -> Bool {
        let order: [PermissionLevel] = [.viewer, .commenter, .editor, .owner]
        return order.firstIndex(of: lhs)! < order.firstIndex(of: rhs)!
    }

    var canView: Bool { true }
    var canComment: Bool { self >= .commenter }
    var canEdit: Bool { self >= .editor }
    var canDelete: Bool { self == .owner }
    var canShare: Bool { self >= .editor }
}
```

---

#### VisibilityRules

```swift
struct VisibilityRules: Codable {
    // Time-based
    var timeRules: [TimeRule]?

    // Condition-based
    var locationRules: [LocationRule]?

    // Expiration
    var expiresAt: Date?
    var expiresAfterViews: Int? // Delete after N views

    var isVisibleNow: Bool {
        // Check if any time rules are active
        if let timeRules = timeRules {
            let now = Date()
            let activeRule = timeRules.first { $0.isActive(at: now) }
            if activeRule == nil { return false }
        }

        // Check expiration
        if let expiresAt = expiresAt, Date() > expiresAt {
            return false
        }

        return true
    }
}

struct TimeRule: Codable, Identifiable {
    var id: UUID
    var type: TimeRuleType
    var startTime: Date?
    var endTime: Date?
    var recurrence: RecurrenceRule?

    func isActive(at date: Date) -> Bool {
        switch type {
        case .always:
            return true
        case .timeRange:
            guard let start = startTime, let end = endTime else { return false }
            return date >= start && date <= end
        case .recurring:
            return recurrence?.matches(date) ?? false
        }
    }
}

enum TimeRuleType: String, Codable {
    case always
    case timeRange
    case recurring
}

struct RecurrenceRule: Codable {
    var frequency: RecurrenceFrequency
    var interval: Int // Every N [frequency]
    var daysOfWeek: [Int]? // 1=Sunday, 7=Saturday
    var timeOfDay: TimeOfDay?

    func matches(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.weekday, .hour, .minute], from: date)

        // Check day of week
        if let daysOfWeek = daysOfWeek {
            guard let weekday = components.weekday,
                  daysOfWeek.contains(weekday) else {
                return false
            }
        }

        // Check time of day
        if let timeOfDay = timeOfDay {
            guard let hour = components.hour,
                  let minute = components.minute else {
                return false
            }
            let currentMinutes = hour * 60 + minute
            let startMinutes = timeOfDay.hour * 60 + timeOfDay.minute
            let endMinutes = timeOfDay.endHour * 60 + timeOfDay.endMinute
            if currentMinutes < startMinutes || currentMinutes > endMinutes {
                return false
            }
        }

        return true
    }
}

enum RecurrenceFrequency: String, Codable {
    case daily
    case weekly
    case monthly
}

struct TimeOfDay: Codable {
    var hour: Int // 0-23
    var minute: Int // 0-59
    var endHour: Int
    var endMinute: Int
}

struct LocationRule: Codable {
    var type: LocationRuleType
    var radiusMeters: Double? // For proximity-based
}

enum LocationRuleType: String, Codable {
    case proximity // Show within X meters
    case always
}
```

---

#### Comment

```swift
@Model
final class Comment {
    @Attribute(.unique) var id: UUID
    var cloudKitRecordName: String?

    // Content
    var text: String
    var authorID: String
    var authorName: String?

    // Relationship
    var annotationID: UUID
    @Relationship(deleteRule: .nullify) var annotation: Annotation?

    // Threading
    var parentCommentID: UUID?
    @Relationship(deleteRule: .nullify) var parentComment: Comment?
    @Relationship(deleteRule: .cascade) var replies: [Comment]

    // Metadata
    var createdAt: Date
    var updatedAt: Date
    var isDeleted: Bool
    var isEdited: Bool

    init(
        id: UUID = UUID(),
        text: String,
        authorID: String,
        annotationID: UUID
    ) {
        self.id = id
        self.text = text
        self.authorID = authorID
        self.annotationID = annotationID
        self.createdAt = Date()
        self.updatedAt = Date()
        self.isDeleted = false
        self.isEdited = false
        self.replies = []
    }
}
```

---

#### Reaction

```swift
struct Reaction: Codable, Identifiable {
    var id: UUID
    var emoji: String // 👍, ❤️, etc.
    var userID: String
    var createdAt: Date

    init(emoji: String, userID: String) {
        self.id = UUID()
        self.emoji = emoji
        self.userID = userID
        self.createdAt = Date()
    }
}
```

---

#### Attachment

```swift
struct Attachment: Codable, Identifiable {
    var id: UUID
    var fileName: String
    var fileType: String // MIME type
    var fileSize: Int64 // Bytes
    var localURL: URL?
    var cloudAssetID: String? // CKAsset reference
    var thumbnailURL: URL?
    var uploadedAt: Date?

    init(
        id: UUID = UUID(),
        fileName: String,
        fileType: String,
        fileSize: Int64,
        localURL: URL
    ) {
        self.id = id
        self.fileName = fileName
        self.fileType = fileType
        self.fileSize = fileSize
        self.localURL = localURL
    }
}
```

---

#### User

```swift
@Model
final class User {
    @Attribute(.unique) var id: String // CloudKit user record name
    var cloudKitRecordName: String?

    // Profile
    var displayName: String?
    var email: String?
    var avatarURL: URL?

    // Settings
    var preferences: UserPreferences

    // Subscription tier
    var subscriptionTier: SubscriptionTier
    var subscriptionExpiresAt: Date?

    // Usage tracking
    var annotationCount: Int
    var layerCount: Int

    // Metadata
    var createdAt: Date
    var lastActiveAt: Date

    init(id: String) {
        self.id = id
        self.preferences = UserPreferences()
        self.subscriptionTier = .free
        self.annotationCount = 0
        self.layerCount = 0
        self.createdAt = Date()
        self.lastActiveAt = Date()
    }
}

struct UserPreferences: Codable {
    var defaultLayerColor: LayerColor = .blue
    var showAnnotationsOnStartup: Bool = true
    var enableNotifications: Bool = true
    var annotationDisplayDistance: Float = 10.0 // meters
    var theme: Theme = .auto
}

enum Theme: String, Codable {
    case light
    case dark
    case auto
}

enum SubscriptionTier: String, Codable {
    case free
    case plus
    case family
    case pro

    var maxAnnotations: Int {
        switch self {
        case .free: return 25
        case .plus: return Int.max
        case .family: return Int.max
        case .pro: return Int.max
        }
    }

    var maxLayers: Int {
        switch self {
        case .free: return 1
        case .plus: return Int.max
        case .family: return Int.max
        case .pro: return Int.max
        }
    }

    var canShare: Bool {
        self != .free
    }
}
```

---

#### ARWorldMapData

```swift
@Model
final class ARWorldMapData {
    @Attribute(.unique) var id: UUID
    var cloudKitRecordName: String?

    // Spatial data
    var worldMapData: Data // Serialized ARWorldMap
    var anchors: [ARAnchorData]

    // Location context (for re-localization)
    var locationName: String? // User-provided name
    var locationDescription: String?
    var thumbnailImage: Data? // Preview image of the space

    // Ownership
    var ownerID: String
    var isShared: Bool
    var sharedWith: [String] // User IDs

    // Metadata
    var createdAt: Date
    var updatedAt: Date
    var lastUsedAt: Date

    init(id: UUID = UUID(), worldMapData: Data, ownerID: String) {
        self.id = id
        self.worldMapData = worldMapData
        self.anchors = []
        self.ownerID = ownerID
        self.isShared = false
        self.sharedWith = []
        self.createdAt = Date()
        self.updatedAt = Date()
        self.lastUsedAt = Date()
    }
}

struct ARAnchorData: Codable, Identifiable {
    var id: UUID
    var transform: simd_float4x4
    var annotationID: UUID?

    init(id: UUID = UUID(), transform: simd_float4x4) {
        self.id = id
        self.transform = transform
    }
}
```

---

## 3. CloudKit Schema

### 3.1 CloudKit Databases

**Private Database**: User's personal annotations, layers, settings
**Shared Database**: Annotations/layers shared with specific users
**Public Database**: Public annotations (future feature)

### 3.2 Record Types

#### Annotation (CKRecord)

```
Record Type: Annotation

Fields:
- id: String (indexed)
- type: String (indexed)
- title: String
- content: String
- contentData: Data (for rich content)

// Spatial
- positionX: Double
- positionY: Double
- positionZ: Double
- orientationW: Double
- orientationX: Double
- orientationY: Double
- orientationZ: Double
- scale: Double
- anchorID: String

// Organization
- layerID: CKRecord.Reference
- ownerID: String (indexed)

// Permissions (JSON encoded)
- permissions: String

// Visibility
- visibilityRules: String (JSON)

// Metadata
- createdAt: Date (indexed)
- updatedAt: Date (indexed)
- isDeleted: Int64 (0 or 1, indexed)
- status: String

// Collaboration
- reactions: String (JSON array)
- viewedBy: [String]

// Media
- mediaAsset: CKAsset
- thumbnailAsset: CKAsset
- attachments: String (JSON array of attachment metadata)

Indexes:
- ownerID
- layerID
- createdAt
- isDeleted
- type

Security:
- World Readable: false
- Creator Readable: true
- Creator Writable: true
```

#### Layer (CKRecord)

```
Record Type: Layer

Fields:
- id: String (indexed)
- name: String (indexed)
- icon: String
- color: String
- parentLayerID: CKRecord.Reference?
- ownerID: String (indexed)
- permissions: String (JSON)
- isPublic: Int64
- isVisible: Int64
- autoExpireDays: Int64?
- defaultPermission: String
- createdAt: Date (indexed)
- updatedAt: Date
- isDeleted: Int64 (indexed)

Indexes:
- ownerID
- name
- isDeleted

Security:
- World Readable: false (unless isPublic)
- Creator Readable: true
- Creator Writable: true
```

#### Comment (CKRecord)

```
Record Type: Comment

Fields:
- id: String (indexed)
- text: String
- authorID: String (indexed)
- authorName: String
- annotationID: CKRecord.Reference (indexed)
- parentCommentID: CKRecord.Reference?
- createdAt: Date (indexed)
- updatedAt: Date
- isDeleted: Int64
- isEdited: Int64

Indexes:
- annotationID
- authorID
- createdAt

Security:
- World Readable: Inherited from annotation
- Creator Writable: true
```

#### User (CKRecord)

```
Record Type: User

Fields:
- id: String (indexed, unique)
- displayName: String
- email: String
- avatarAsset: CKAsset
- preferences: String (JSON)
- subscriptionTier: String
- subscriptionExpiresAt: Date?
- annotationCount: Int64
- layerCount: Int64
- createdAt: Date
- lastActiveAt: Date

Indexes:
- id (unique)
- email

Security:
- World Readable: false
- Creator Readable: true
- Creator Writable: true
```

#### ARWorldMap (CKRecord)

```
Record Type: ARWorldMap

Fields:
- id: String (indexed)
- worldMapAsset: CKAsset (the ARWorldMap data)
- anchors: String (JSON array)
- locationName: String
- locationDescription: String
- thumbnailAsset: CKAsset
- ownerID: String (indexed)
- isShared: Int64
- sharedWith: [String]
- createdAt: Date
- updatedAt: Date
- lastUsedAt: Date

Indexes:
- ownerID
- locationName

Security:
- World Readable: false
- Creator Readable: true
- Shared: Based on sharedWith list
```

### 3.3 Sharing Strategy

**CKShare Records**: For sharing layers/annotations with specific users
**CKQuerySubscription**: For real-time updates
**CKDatabase.Scope**:
- Private: Default for user's content
- Shared: When sharing with others via CKShare
- Public: For future public annotations

---

## 4. SwiftData Schema

### 4.1 ModelContainer Configuration

```swift
import SwiftData

let schema = Schema([
    Annotation.self,
    Layer.self,
    Comment.self,
    User.self,
    ARWorldMapData.self
])

let modelConfiguration = ModelConfiguration(
    schema: schema,
    isStoredInMemoryOnly: false,
    cloudKitDatabase: .none // CloudKit handled separately
)

let modelContainer = try ModelContainer(
    for: schema,
    configurations: [modelConfiguration]
)
```

### 4.2 Indexes

```swift
// SwiftData will automatically index @Attribute(.unique) properties
// Additional indexes for queries:

@Model
final class Annotation {
    @Attribute(.unique) var id: UUID

    // These will be frequently queried
    var layerID: UUID // Index for layer filtering
    var ownerID: String // Index for user's annotations
    var createdAt: Date // Index for sorting
    var isDeleted: Bool // Index for filtering deleted items
}
```

---

## 5. Relationships

### 5.1 Entity Relationship Diagram

```
User (1) ──┬── creates ─→ (N) Annotation
           ├── creates ─→ (N) Layer
           └── writes ─→ (N) Comment

Layer (1) ──── contains ─→ (N) Annotation
Layer (1) ──── contains ─→ (N) Layer (child layers)

Annotation (1) ──── has ─→ (N) Comment
Annotation (1) ──── references ─→ (1) ARWorldMapAnchor

Comment (1) ──── has ─→ (N) Comment (replies)

ARWorldMapData (1) ──── contains ─→ (N) ARAnchorData
```

### 5.2 Cascade Rules

- **Delete Layer** → Nullify Annotations (orphaned annotations move to default layer)
- **Delete Annotation** → Cascade delete Comments
- **Delete User** → Transfer ownership or cascade delete (policy decision)

---

## 6. Data Validation Rules

### 6.1 Annotation Validation

```swift
extension Annotation {
    func validate() throws {
        // Content must not be empty
        guard !content.isEmpty else {
            throw ValidationError.emptyContent
        }

        // Title length
        if let title = title, title.count > 100 {
            throw ValidationError.titleTooLong
        }

        // Scale must be positive
        guard scale > 0 else {
            throw ValidationError.invalidScale
        }

        // Owner must be set
        guard !ownerID.isEmpty else {
            throw ValidationError.missingOwner
        }
    }
}

enum ValidationError: LocalizedError {
    case emptyContent
    case titleTooLong
    case invalidScale
    case missingOwner

    var errorDescription: String? {
        switch self {
        case .emptyContent: return "Annotation content cannot be empty"
        case .titleTooLong: return "Title must be 100 characters or less"
        case .invalidScale: return "Scale must be greater than 0"
        case .missingOwner: return "Annotation must have an owner"
        }
    }
}
```

### 6.2 Layer Validation

```swift
extension Layer {
    func validate() throws {
        guard !name.isEmpty else {
            throw ValidationError.emptyName
        }
        guard name.count <= 50 else {
            throw ValidationError.nameTooLong
        }
    }
}
```

---

## 7. Data Migration Strategy

### 7.1 Version Migration

```swift
// Future schema versions
enum SchemaVersion: Int, CaseIterable {
    case v1 = 1 // Initial release
    case v2 = 2 // Added attachment support
    case v3 = 3 // Added status field

    var schema: Schema {
        switch self {
        case .v1: return SchemaV1.schema
        case .v2: return SchemaV2.schema
        case .v3: return SchemaV3.schema
        }
    }
}

// Migration plan
let versionedSchema = VersionedSchema(
    SchemaV1.schema,
    SchemaV2.schema,
    SchemaV3.schema
)

let migrationPlan = SchemaMigrationPlan(
    [
        MigrationStage(from: SchemaV1.self, to: SchemaV2.self),
        MigrationStage(from: SchemaV2.self, to: SchemaV3.self)
    ]
)
```

### 7.2 CloudKit Schema Changes

- **Never delete fields** (CloudKit doesn't support)
- **Add new fields** with default values
- **Mark deprecated fields** in code comments
- **Maintain backwards compatibility**

---

## 8. Data Size Estimates

### 8.1 Per-Record Sizes

| Record Type | Average Size | Notes |
|-------------|--------------|-------|
| Annotation (text) | 1-5 KB | Without media |
| Annotation (photo) | 500 KB - 5 MB | With CKAsset |
| Layer | 500 bytes | Metadata only |
| Comment | 500 bytes | Text only |
| User | 2 KB | With preferences |
| ARWorldMap | 5-50 MB | Depends on space size |

### 8.2 Storage Limits

**Free Tier**:
- 25 annotations × 5 KB = ~125 KB (metadata)
- Plus media assets (varies)
- 1 layer

**Plus Tier**:
- Unlimited annotations (CloudKit 1GB free, then $0.10/GB)
- Unlimited layers

---

## 9. Query Patterns

### 9.1 Common Queries

```swift
// Fetch all annotations in a layer
let predicate = #Predicate<Annotation> { annotation in
    annotation.layerID == layerID &&
    annotation.isDeleted == false
}
let descriptor = FetchDescriptor<Annotation>(
    predicate: predicate,
    sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
)

// Fetch visible annotations (with time rules)
let now = Date()
let predicate = #Predicate<Annotation> { annotation in
    annotation.isDeleted == false &&
    (annotation.visibilityRules == nil ||
     annotation.visibilityRules!.isVisibleNow)
}

// Search annotations by text
let searchText = "meeting"
let predicate = #Predicate<Annotation> { annotation in
    annotation.content.text?.contains(searchText) ?? false
}
```

### 9.2 CloudKit Queries

```swift
// Fetch recent annotations
let predicate = NSPredicate(
    format: "createdAt > %@ AND isDeleted == 0",
    Date().addingTimeInterval(-7 * 24 * 3600) as NSDate
)
let query = CKQuery(recordType: "Annotation", predicate: predicate)
query.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
```

---

## 10. Sync Metadata

### 10.1 Change Tracking

```swift
struct SyncMetadata: Codable {
    var recordType: String
    var recordID: String
    var changeTag: String? // CloudKit change token
    var lastSyncedAt: Date
    var syncStatus: SyncStatus
    var conflictVersion: Data? // For conflict resolution
}

enum SyncStatus: String, Codable {
    case synced
    case pendingUpload
    case pendingDownload
    case conflict
    case error
}
```

### 10.2 Conflict Resolution Data

```swift
struct ConflictData: Codable {
    var localVersion: Data // Local record data
    var remoteVersion: Data // Remote record data
    var localModifiedAt: Date
    var remoteModifiedAt: Date
    var resolutionStrategy: ConflictResolutionStrategy
}

enum ConflictResolutionStrategy: String, Codable {
    case useLocal
    case useRemote
    case merge
    case manual // User decides
}
```

---

## 11. Privacy & Compliance

### 11.1 PII (Personally Identifiable Information)

**Stored PII**:
- User email (private database only)
- User display name
- CloudKit user record name

**Not Stored**:
- Precise GPS coordinates (use relative spatial anchors instead)
- Device identifiers
- Contact lists

### 11.2 Data Retention

- **Soft Delete**: Set `isDeleted = true`, keep for 30 days
- **Hard Delete**: After 30 days or manual purge
- **User Data Export**: Provide JSON export of all user data
- **Right to be Forgotten**: Complete account deletion endpoint

---

## 12. Appendix

### 12.1 Sample Data

```swift
// Sample annotation
let annotation = Annotation(
    type: .text,
    content: AnnotationContent(text: "Remember to buy milk"),
    position: SIMD3<Float>(0, 1.5, -2),
    layerID: familyLayer.id,
    ownerID: currentUser.id
)

// Sample layer
let familyLayer = Layer(
    name: "Family Messages",
    icon: "person.3.fill",
    color: .blue,
    ownerID: currentUser.id
)

// Sample visibility rule
let bedtimeRule = VisibilityRules(
    timeRules: [
        TimeRule(
            type: .recurring,
            recurrence: RecurrenceRule(
                frequency: .daily,
                interval: 1,
                timeOfDay: TimeOfDay(hour: 20, minute: 0, endHour: 20, endMinute: 30)
            )
        )
    ]
)
```

### 12.2 References

- [SwiftData Documentation](https://developer.apple.com/documentation/swiftdata)
- [CloudKit Schema Design](https://developer.apple.com/documentation/cloudkit/designing_your_schema)
- [ARWorldMap](https://developer.apple.com/documentation/arkit/arworldmap)

---

**Document Status**: ✅ Ready for Implementation
**Dependencies**: System Architecture Document
**Next Steps**: Create Spatial Persistence & AR Architecture document
