# API & Service Contracts
## Reality Annotation Platform

**Version**: 1.0
**Date**: November 2024
**Status**: Draft

---

## 1. Overview

This document defines the internal service interfaces and contracts for the Reality Annotation Platform. These protocols form the boundaries between layers and enable dependency injection, testing, and clean architecture.

---

## 2. Service Layer Architecture

```
ViewModels
    ↓
Service Layer (Business Logic)
    ├── AnnotationService
    ├── LayerService
    ├── PermissionService
    ├── SearchService
    ├── CollaborationService
    ├── UserService
    └── NotificationService
    ↓
Repository Layer (Data Access)
    ├── AnnotationRepository
    ├── LayerRepository
    └── UserRepository
```

---

## 3. Core Service Protocols

### 3.1 AnnotationService

```swift
/// Service for managing annotations
protocol AnnotationService {
    /// Create a new annotation
    /// - Parameters:
    ///   - content: The annotation content
    ///   - position: 3D position in world space
    ///   - layerID: Layer to place annotation in
    /// - Returns: Created annotation
    /// - Throws: `AnnotationError` if creation fails
    func createAnnotation(
        content: AnnotationContent,
        type: AnnotationType,
        position: SIMD3<Float>,
        layerID: UUID
    ) async throws -> Annotation

    /// Fetch all annotations in a layer
    func fetchAnnotations(in layerID: UUID) async throws -> [Annotation]

    /// Fetch annotation by ID
    func fetchAnnotation(id: UUID) async throws -> Annotation?

    /// Update annotation
    func updateAnnotation(_ annotation: Annotation) async throws

    /// Delete annotation
    func deleteAnnotation(id: UUID) async throws

    /// Move annotation to different layer
    func moveAnnotation(id: UUID, to layerID: UUID) async throws

    /// Fetch nearby annotations
    func fetchNearby(
        position: SIMD3<Float>,
        radius: Float
    ) async throws -> [Annotation]

    /// Fetch visible annotations based on rules
    func fetchVisible(at date: Date) async throws -> [Annotation]
}
```

### 3.2 AnnotationService Implementation

```swift
class DefaultAnnotationService: AnnotationService {
    private let repository: AnnotationRepository
    private let permissionService: PermissionService
    private let anchorManager: AnchorManager
    private let syncCoordinator: SyncCoordinator

    init(
        repository: AnnotationRepository,
        permissionService: PermissionService,
        anchorManager: AnchorManager,
        syncCoordinator: SyncCoordinator
    ) {
        self.repository = repository
        self.permissionService = permissionService
        self.anchorManager = anchorManager
        self.syncCoordinator = syncCoordinator
    }

    func createAnnotation(
        content: AnnotationContent,
        type: AnnotationType,
        position: SIMD3<Float>,
        layerID: UUID
    ) async throws -> Annotation {
        // 1. Validate content
        guard !content.isEmpty else {
            throw AnnotationError.emptyContent
        }

        // 2. Check permissions
        try await permissionService.checkCanCreate(in: layerID)

        // 3. Find or create anchor
        let anchorID = try await anchorManager.anchorFor(position: position)

        // 4. Create annotation
        let annotation = Annotation(
            type: type,
            content: content,
            position: position,
            layerID: layerID,
            ownerID: currentUserID,
            anchorID: anchorID
        )

        // 5. Validate
        try annotation.validate()

        // 6. Save to repository
        try await repository.save(annotation)

        // 7. Queue for sync
        await syncCoordinator.queueForSync(annotation)

        return annotation
    }

    func fetchAnnotations(in layerID: UUID) async throws -> [Annotation] {
        let annotations = try await repository.fetchByLayer(layerID)

        // Filter by permissions
        return annotations.filter { annotation in
            permissionService.canView(annotation)
        }
    }

    func updateAnnotation(_ annotation: Annotation) async throws {
        // Check permissions
        try await permissionService.checkCanEdit(annotation)

        // Update timestamp
        var updated = annotation
        updated.updatedAt = Date()

        // Validate
        try updated.validate()

        // Save
        try await repository.update(updated)

        // Queue for sync
        await syncCoordinator.queueForSync(updated)
    }

    func deleteAnnotation(id: UUID) async throws {
        guard let annotation = try await repository.fetch(id) else {
            throw AnnotationError.notFound
        }

        // Check permissions
        try await permissionService.checkCanDelete(annotation)

        // Soft delete
        var deleted = annotation
        deleted.isDeleted = true
        deleted.updatedAt = Date()

        try await repository.update(deleted)
        await syncCoordinator.queueForSync(deleted)
    }

    func fetchNearby(
        position: SIMD3<Float>,
        radius: Float
    ) async throws -> [Annotation] {
        let annotations = try await repository.fetchAll()

        return annotations.filter { annotation in
            let distance = simd_distance(annotation.position, position)
            return distance <= radius && permissionService.canView(annotation)
        }
    }

    func fetchVisible(at date: Date) async throws -> [Annotation] {
        let annotations = try await repository.fetchAll()

        return annotations.filter { annotation in
            guard permissionService.canView(annotation) else { return false }

            if let rules = annotation.visibilityRules {
                return rules.isVisible(at: date)
            }

            return true // No rules = always visible
        }
    }
}
```

---

### 3.3 LayerService

```swift
protocol LayerService {
    /// Create a new layer
    func createLayer(
        name: String,
        icon: String,
        color: LayerColor
    ) async throws -> Layer

    /// Fetch all layers for current user
    func fetchLayers() async throws -> [Layer]

    /// Fetch layer by ID
    func fetchLayer(id: UUID) async throws -> Layer?

    /// Update layer
    func updateLayer(_ layer: Layer) async throws

    /// Delete layer (moves annotations to default layer)
    func deleteLayer(id: UUID) async throws

    /// Toggle layer visibility
    func setLayerVisible(_ layerID: UUID, visible: Bool) async throws

    /// Get active (visible) layers
    func getActiveLayers() async throws -> [Layer]
}

class DefaultLayerService: LayerService {
    private let repository: LayerRepository
    private let annotationRepository: AnnotationRepository
    private let permissionService: PermissionService

    func createLayer(
        name: String,
        icon: String,
        color: LayerColor
    ) async throws -> Layer {
        // Check subscription limits
        let existingCount = try await repository.count(for: currentUserID)
        let limit = currentUser.subscriptionTier.maxLayers

        guard existingCount < limit else {
            throw LayerError.limitExceeded(limit: limit)
        }

        // Create layer
        let layer = Layer(
            name: name,
            icon: icon,
            color: color,
            ownerID: currentUserID
        )

        try await repository.save(layer)
        return layer
    }

    func deleteLayer(id: UUID) async throws {
        guard let layer = try await repository.fetch(id) else {
            throw LayerError.notFound
        }

        // Check permissions
        guard layer.ownerID == currentUserID else {
            throw PermissionError.notOwner
        }

        // Move annotations to default layer
        let annotations = try await annotationRepository.fetchByLayer(id)
        let defaultLayer = try await getOrCreateDefaultLayer()

        for annotation in annotations {
            var updated = annotation
            updated.layerID = defaultLayer.id
            try await annotationRepository.update(updated)
        }

        // Delete layer
        try await repository.delete(id)
    }

    private func getOrCreateDefaultLayer() async throws -> Layer {
        // Implementation
        fatalError("Not implemented")
    }
}
```

---

### 3.4 PermissionService

```swift
protocol PermissionService {
    /// Check if user can view annotation
    func canView(_ annotation: Annotation) -> Bool

    /// Check if user can edit annotation
    func canEdit(_ annotation: Annotation) -> Bool

    /// Check if user can delete annotation
    func canDelete(_ annotation: Annotation) -> Bool

    /// Check if user can comment on annotation
    func canComment(_ annotation: Annotation) -> Bool

    /// Check if user can share annotation
    func canShare(_ annotation: Annotation) -> Bool

    /// Throw error if user cannot create in layer
    func checkCanCreate(in layerID: UUID) async throws

    /// Throw error if user cannot edit annotation
    func checkCanEdit(_ annotation: Annotation) async throws

    /// Throw error if user cannot delete annotation
    func checkCanDelete(_ annotation: Annotation) async throws

    /// Grant permission to user
    func grantPermission(
        to userID: String,
        level: PermissionLevel,
        for annotation: Annotation
    ) async throws

    /// Revoke permission from user
    func revokePermission(
        from userID: String,
        for annotation: Annotation
    ) async throws

    /// Get permission level for user
    func getPermissionLevel(
        for userID: String,
        annotation: Annotation
    ) -> PermissionLevel?
}

class DefaultPermissionService: PermissionService {
    private let currentUserID: String

    init(currentUserID: String) {
        self.currentUserID = currentUserID
    }

    func canView(_ annotation: Annotation) -> Bool {
        // Owner can always view
        if annotation.ownerID == currentUserID {
            return true
        }

        // Check explicit permissions
        if let permission = getPermissionLevel(
            for: currentUserID,
            annotation: annotation
        ) {
            return permission.canView
        }

        // Check if annotation is public (future feature)
        return false
    }

    func canEdit(_ annotation: Annotation) -> Bool {
        if annotation.ownerID == currentUserID {
            return true
        }

        if let permission = getPermissionLevel(
            for: currentUserID,
            annotation: annotation
        ) {
            return permission.canEdit
        }

        return false
    }

    func canDelete(_ annotation: Annotation) -> Bool {
        // Only owner can delete
        return annotation.ownerID == currentUserID
    }

    func checkCanEdit(_ annotation: Annotation) async throws {
        guard canEdit(annotation) else {
            throw PermissionError.cannotEdit
        }
    }

    func getPermissionLevel(
        for userID: String,
        annotation: Annotation
    ) -> PermissionLevel? {
        return annotation.permissions
            .first { $0.userID == userID }?
            .level
    }

    func grantPermission(
        to userID: String,
        level: PermissionLevel,
        for annotation: Annotation
    ) async throws {
        // Only owner can grant permissions
        guard annotation.ownerID == currentUserID else {
            throw PermissionError.notOwner
        }

        // Add permission
        let permission = Permission(
            userID: userID,
            level: level,
            grantedBy: currentUserID
        )

        var updated = annotation
        updated.permissions.append(permission)

        try await annotationRepository.update(updated)
    }
}

enum PermissionError: LocalizedError {
    case cannotView
    case cannotEdit
    case cannotDelete
    case notOwner

    var errorDescription: String? {
        switch self {
        case .cannotView: return "You don't have permission to view this"
        case .cannotEdit: return "You don't have permission to edit this"
        case .cannotDelete: return "You don't have permission to delete this"
        case .notOwner: return "Only the owner can perform this action"
        }
    }
}
```

---

### 3.5 SearchService

```swift
protocol SearchService {
    /// Search annotations by text
    func search(query: String) async throws -> [Annotation]

    /// Search with filters
    func search(
        query: String?,
        layerIDs: [UUID]?,
        types: [AnnotationType]?,
        dateRange: DateInterval?,
        creatorID: String?
    ) async throws -> [Annotation]

    /// Get recent annotations
    func getRecent(limit: Int) async throws -> [Annotation]

    /// Get unread annotations
    func getUnread() async throws -> [Annotation]

    /// Get starred/favorited annotations
    func getStarred() async throws -> [Annotation]

    /// Mark annotation as read
    func markAsRead(_ annotationID: UUID) async throws
}

class DefaultSearchService: SearchService {
    private let repository: AnnotationRepository
    private let permissionService: PermissionService

    func search(query: String) async throws -> [Annotation] {
        let allAnnotations = try await repository.fetchAll()

        return allAnnotations.filter { annotation in
            guard permissionService.canView(annotation) else { return false }

            let searchableText = [
                annotation.title,
                annotation.content.text
            ]
            .compactMap { $0 }
            .joined(separator: " ")
            .lowercased()

            return searchableText.contains(query.lowercased())
        }
    }

    func search(
        query: String?,
        layerIDs: [UUID]?,
        types: [AnnotationType]?,
        dateRange: DateInterval?,
        creatorID: String?
    ) async throws -> [Annotation] {
        var results = try await repository.fetchAll()

        // Apply filters
        if let query = query {
            results = results.filter { annotation in
                let text = [annotation.title, annotation.content.text]
                    .compactMap { $0 }
                    .joined(separator: " ")
                    .lowercased()
                return text.contains(query.lowercased())
            }
        }

        if let layerIDs = layerIDs {
            results = results.filter { layerIDs.contains($0.layerID) }
        }

        if let types = types {
            results = results.filter { types.contains($0.type) }
        }

        if let dateRange = dateRange {
            results = results.filter { annotation in
                dateRange.contains(annotation.createdAt)
            }
        }

        if let creatorID = creatorID {
            results = results.filter { $0.ownerID == creatorID }
        }

        // Filter by permissions
        results = results.filter { permissionService.canView($0) }

        return results
    }

    func getRecent(limit: Int) async throws -> [Annotation] {
        let annotations = try await repository.fetchAll()

        return annotations
            .filter { permissionService.canView($0) }
            .sorted { $0.createdAt > $1.createdAt }
            .prefix(limit)
            .map { $0 }
    }
}
```

---

### 3.6 CollaborationService

```swift
protocol CollaborationService {
    /// Add comment to annotation
    func addComment(
        to annotationID: UUID,
        text: String
    ) async throws -> Comment

    /// Reply to comment
    func replyToComment(
        _ commentID: UUID,
        text: String
    ) async throws -> Comment

    /// Delete comment
    func deleteComment(_ commentID: UUID) async throws

    /// Add reaction to annotation
    func addReaction(
        to annotationID: UUID,
        emoji: String
    ) async throws

    /// Remove reaction
    func removeReaction(
        from annotationID: UUID,
        emoji: String
    ) async throws

    /// Mark annotation as resolved
    func markAsResolved(_ annotationID: UUID) async throws

    /// Get comments for annotation
    func getComments(for annotationID: UUID) async throws -> [Comment]

    /// Get activity feed
    func getActivityFeed(limit: Int) async throws -> [Activity]
}

class DefaultCollaborationService: CollaborationService {
    private let annotationRepository: AnnotationRepository
    private let commentRepository: CommentRepository
    private let notificationService: NotificationService

    func addComment(
        to annotationID: UUID,
        text: String
    ) async throws -> Comment {
        // Fetch annotation
        guard let annotation = try await annotationRepository.fetch(annotationID) else {
            throw CollaborationError.annotationNotFound
        }

        // Check permissions
        guard permissionService.canComment(annotation) else {
            throw PermissionError.cannotComment
        }

        // Create comment
        let comment = Comment(
            text: text,
            authorID: currentUserID,
            annotationID: annotationID
        )

        try await commentRepository.save(comment)

        // Notify annotation owner
        await notificationService.notifyNewComment(
            annotation: annotation,
            comment: comment
        )

        return comment
    }

    func addReaction(
        to annotationID: UUID,
        emoji: String
    ) async throws {
        guard var annotation = try await annotationRepository.fetch(annotationID) else {
            throw CollaborationError.annotationNotFound
        }

        // Check if user already reacted with this emoji
        let alreadyReacted = annotation.reactions.contains { reaction in
            reaction.emoji == emoji && reaction.userID == currentUserID
        }

        guard !alreadyReacted else { return }

        // Add reaction
        let reaction = Reaction(emoji: emoji, userID: currentUserID)
        annotation.reactions.append(reaction)

        try await annotationRepository.update(annotation)
    }
}

enum CollaborationError: LocalizedError {
    case annotationNotFound
    case commentNotFound

    var errorDescription: String? {
        switch self {
        case .annotationNotFound: return "Annotation not found"
        case .commentNotFound: return "Comment not found"
        }
    }
}
```

---

### 3.7 UserService

```swift
protocol UserService {
    /// Get current user
    func getCurrentUser() async throws -> User

    /// Update user profile
    func updateProfile(
        displayName: String?,
        avatarImage: UIImage?
    ) async throws

    /// Update user preferences
    func updatePreferences(_ preferences: UserPreferences) async throws

    /// Check subscription status
    func checkSubscription() async throws -> SubscriptionStatus

    /// Upgrade subscription
    func upgradeSubscription(to tier: SubscriptionTier) async throws

    /// Get usage statistics
    func getUsageStats() async throws -> UsageStats
}

struct SubscriptionStatus {
    var tier: SubscriptionTier
    var expiresAt: Date?
    var isActive: Bool
    var canUpgrade: Bool
}

struct UsageStats {
    var annotationCount: Int
    var layerCount: Int
    var storageUsed: Int64 // bytes
    var limits: UsageLimits
}

struct UsageLimits {
    var maxAnnotations: Int
    var maxLayers: Int
    var maxStorage: Int64
}
```

---

### 3.8 NotificationService

```swift
protocol NotificationService {
    /// Send notification to user
    func send(
        to userID: String,
        title: String,
        body: String,
        data: [String: Any]?
    ) async throws

    /// Notify about new comment
    func notifyNewComment(
        annotation: Annotation,
        comment: Comment
    ) async

    /// Notify about mention
    func notifyMention(
        mentionedUserID: String,
        in annotation: Annotation
    ) async

    /// Notify about shared annotation
    func notifyShared(
        annotation: Annotation,
        sharedWith userIDs: [String]
    ) async

    /// Get user's notifications
    func getNotifications(
        for userID: String,
        limit: Int
    ) async throws -> [Notification]

    /// Mark notification as read
    func markAsRead(_ notificationID: UUID) async throws
}

struct Notification: Identifiable {
    var id: UUID
    var type: NotificationType
    var title: String
    var body: String
    var data: [String: Any]?
    var createdAt: Date
    var isRead: Bool
}

enum NotificationType: String, Codable {
    case comment
    case mention
    case shared
    case reaction
    case statusChange
}
```

---

## 4. Repository Layer

### 4.1 Base Repository Protocol

```swift
protocol Repository {
    associatedtype Entity: Identifiable

    func fetch(_ id: Entity.ID) async throws -> Entity?
    func fetchAll() async throws -> [Entity]
    func save(_ entity: Entity) async throws
    func update(_ entity: Entity) async throws
    func delete(_ id: Entity.ID) async throws
}
```

### 4.2 AnnotationRepository

```swift
protocol AnnotationRepository: Repository where Entity == Annotation {
    /// Fetch annotations by layer
    func fetchByLayer(_ layerID: UUID) async throws -> [Annotation]

    /// Fetch annotations by owner
    func fetchByOwner(_ ownerID: String) async throws -> [Annotation]

    /// Fetch annotations pending sync
    func fetchPendingSync() async throws -> [Annotation]

    /// Mark as synced
    func markSynced(_ annotation: Annotation) async throws

    /// Fetch nearby annotations
    func fetchNearby(
        position: SIMD3<Float>,
        radius: Float
    ) async throws -> [Annotation]
}

class DefaultAnnotationRepository: AnnotationRepository {
    private let localDataSource: LocalDataSource
    private let remoteDataSource: CloudKitDataSource

    func fetch(_ id: UUID) async throws -> Annotation? {
        // Try local first
        if let local = try await localDataSource.fetchAnnotation(id) {
            return local
        }

        // Fall back to remote
        return try await remoteDataSource.fetchAnnotation(id)
    }

    func fetchAll() async throws -> [Annotation] {
        // Fetch from local (fast)
        let annotations = try await localDataSource.fetchAllAnnotations()

        // Trigger background sync
        Task {
            await syncCoordinator.syncNow()
        }

        return annotations
    }

    func save(_ annotation: Annotation) async throws {
        // Save locally
        try await localDataSource.saveAnnotation(annotation)

        // Queue for sync
        await syncCoordinator.queueForSync(annotation)
    }

    func fetchByLayer(_ layerID: UUID) async throws -> [Annotation] {
        return try await localDataSource.fetchAnnotations(layerID: layerID)
    }
}
```

---

## 5. Data Source Protocols

### 5.1 LocalDataSource

```swift
protocol LocalDataSource {
    // Annotations
    func fetchAnnotation(_ id: UUID) async throws -> Annotation?
    func fetchAllAnnotations() async throws -> [Annotation]
    func fetchAnnotations(layerID: UUID) async throws -> [Annotation]
    func saveAnnotation(_ annotation: Annotation) async throws
    func updateAnnotation(_ annotation: Annotation) async throws
    func deleteAnnotation(_ id: UUID) async throws

    // Layers
    func fetchLayer(_ id: UUID) async throws -> Layer?
    func fetchAllLayers() async throws -> [Layer]
    func saveLayer(_ layer: Layer) async throws
    func deleteLayer(_ id: UUID) async throws

    // Sync metadata
    func fetchPendingSync() async throws -> [any Syncable]
    func markSynced(_ item: any Syncable) async throws
}
```

### 5.2 RemoteDataSource (CloudKit)

```swift
protocol RemoteDataSource {
    func fetch<T: Syncable>(_ id: UUID) async throws -> T?
    func save<T: Syncable>(_ item: T) async throws
    func delete(_ recordID: CKRecord.ID) async throws
    func fetchChanges(since token: CKServerChangeToken?) async throws -> [CloudKitChange]
}
```

---

## 6. Error Handling

### 6.1 Service-Level Errors

```swift
enum ServiceError: LocalizedError {
    case notFound
    case unauthorized
    case invalidInput(String)
    case networkError(Error)
    case storageError(Error)
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .notFound:
            return "Item not found"
        case .unauthorized:
            return "You don't have permission"
        case .invalidInput(let message):
            return "Invalid input: \(message)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .storageError(let error):
            return "Storage error: \(error.localizedDescription)"
        case .unknown(let error):
            return "Unknown error: \(error.localizedDescription)"
        }
    }
}
```

---

## 7. Async/Await Patterns

### 7.1 Async Sequences

```swift
protocol AnnotationService {
    /// Stream of annotation updates
    func watchAnnotations(in layerID: UUID) -> AsyncStream<[Annotation]>
}

extension DefaultAnnotationService {
    func watchAnnotations(in layerID: UUID) -> AsyncStream<[Annotation]> {
        AsyncStream { continuation in
            let task = Task {
                // Initial load
                if let annotations = try? await fetchAnnotations(in: layerID) {
                    continuation.yield(annotations)
                }

                // Watch for changes
                for await _ in NotificationCenter.default.notifications(
                    named: .annotationsDidChange
                ) {
                    if let annotations = try? await fetchAnnotations(in: layerID) {
                        continuation.yield(annotations)
                    }
                }
            }

            continuation.onTermination = { _ in
                task.cancel()
            }
        }
    }
}

// Usage
for await annotations in annotationService.watchAnnotations(in: layerID) {
    // Update UI
    print("Annotations updated: \(annotations.count)")
}
```

---

## 8. Testing Contracts

### 8.1 Mock Services

```swift
class MockAnnotationService: AnnotationService {
    var annotations: [Annotation] = []
    var shouldThrowError = false

    func createAnnotation(
        content: AnnotationContent,
        type: AnnotationType,
        position: SIMD3<Float>,
        layerID: UUID
    ) async throws -> Annotation {
        if shouldThrowError {
            throw ServiceError.unknown(NSError(domain: "test", code: 1))
        }

        let annotation = Annotation(
            type: type,
            content: content,
            position: position,
            layerID: layerID,
            ownerID: "test-user"
        )

        annotations.append(annotation)
        return annotation
    }

    func fetchAnnotations(in layerID: UUID) async throws -> [Annotation] {
        return annotations.filter { $0.layerID == layerID }
    }
}

// Test
func testCreateAnnotation() async throws {
    let service = MockAnnotationService()

    let annotation = try await service.createAnnotation(
        content: AnnotationContent(text: "Test"),
        type: .text,
        position: SIMD3(0, 1, -2),
        layerID: UUID()
    )

    XCTAssertEqual(service.annotations.count, 1)
    XCTAssertEqual(service.annotations.first?.content.text, "Test")
}
```

---

## 9. Dependency Injection

### 9.1 Service Container

```swift
@MainActor
class ServiceContainer {
    static let shared = ServiceContainer()

    // Repositories
    lazy var annotationRepository: AnnotationRepository = {
        DefaultAnnotationRepository(
            localDataSource: localDataSource,
            remoteDataSource: cloudKitDataSource,
            syncCoordinator: syncCoordinator
        )
    }()

    // Services
    lazy var annotationService: AnnotationService = {
        DefaultAnnotationService(
            repository: annotationRepository,
            permissionService: permissionService,
            anchorManager: anchorManager,
            syncCoordinator: syncCoordinator
        )
    }()

    lazy var layerService: LayerService = {
        DefaultLayerService(
            repository: layerRepository,
            annotationRepository: annotationRepository,
            permissionService: permissionService
        )
    }()

    lazy var permissionService: PermissionService = {
        DefaultPermissionService(currentUserID: currentUserID)
    }()

    // Infrastructure
    lazy var syncCoordinator: SyncCoordinator = {
        DefaultSyncCoordinator(
            cloudKitService: cloudKitService,
            localDataSource: localDataSource,
            conflictResolver: conflictResolver
        )
    }()

    // Data sources
    private lazy var localDataSource: LocalDataSource = {
        SwiftDataSource(modelContext: modelContext)
    }()

    private lazy var cloudKitDataSource: RemoteDataSource = {
        CloudKitDataSource()
    }()

    private var currentUserID: String {
        // Get from authentication service
        "current-user-id"
    }
}
```

---

## 10. Appendix

### 10.1 Protocol Design Principles

1. **Single Responsibility**: Each service has one clear purpose
2. **Dependency Inversion**: Depend on protocols, not implementations
3. **Interface Segregation**: Small, focused protocols
4. **Async by Default**: All I/O operations are async
5. **Error Handling**: Use typed errors with clear descriptions

### 10.2 Naming Conventions

- **Services**: `AnnotationService`, `LayerService`
- **Repositories**: `AnnotationRepository`, `LayerRepository`
- **Methods**: `fetch`, `save`, `update`, `delete` (CRUD)
- **Async methods**: No "async" suffix (implied by `async` keyword)

### 10.3 References

- [Protocol-Oriented Programming](https://developer.apple.com/videos/play/wwdc2015/408/)
- [Swift Concurrency](https://docs.swift.org/swift-book/LanguageGuide/Concurrency.html)
- [Dependency Injection in Swift](https://www.swiftbysundell.com/articles/dependency-injection-using-factories-in-swift/)

---

**Document Status**: ✅ Ready for Implementation
**Dependencies**: System Architecture, Data Model
**Next Steps**: Create Security & Privacy Architecture document
