# CloudKit Sync Strategy
## Reality Annotation Platform

**Version**: 1.0
**Date**: November 2024
**Status**: Draft

---

## 1. Overview

This document defines the synchronization strategy between local SwiftData storage and CloudKit cloud storage. It covers sync patterns, conflict resolution, offline support, and real-time collaboration.

---

## 2. Sync Architecture

### 2.1 High-Level Strategy

```
Local SwiftData (Source of Truth for UI)
         ↕
  Sync Coordinator
         ↕
CloudKit (Source of Truth for Multi-Device)
```

**Philosophy**:
- **Local-first**: App works offline, syncs when online
- **Optimistic updates**: Show changes immediately, sync in background
- **Eventual consistency**: All devices converge to same state
- **Conflict resolution**: Last-write-wins with user override option

### 2.2 Sync Flow Diagram

```
User Action (Create/Edit/Delete)
    ↓
Save to Local DB (Immediate)
    ↓
Update UI (Immediate)
    ↓
Queue for Sync
    ↓
[Background Sync Process]
    ├→ Upload local changes to CloudKit
    ├→ Download remote changes from CloudKit
    ├→ Resolve conflicts
    └→ Update local DB
    ↓
Notify UI of remote changes
```

---

## 3. Sync Coordinator

### 3.1 Core Protocol

```swift
protocol SyncCoordinator {
    /// Start background sync process
    func startSync() async

    /// Stop background sync
    func stopSync()

    /// Force immediate sync
    func syncNow() async throws

    /// Queue item for upload
    func queueForSync<T: Syncable>(_ item: T) async

    /// Check sync status
    var syncStatus: SyncStatus { get }

    /// Last successful sync time
    var lastSyncTime: Date? { get }
}

enum SyncStatus {
    case idle
    case syncing
    case error(Error)
    case offline
}
```

### 3.2 Implementation

```swift
@MainActor
class DefaultSyncCoordinator: SyncCoordinator {
    @Published var syncStatus: SyncStatus = .idle
    @Published var lastSyncTime: Date?

    private let cloudKitService: CloudKitService
    private let localDataSource: LocalDataSource
    private let conflictResolver: ConflictResolver

    private var syncTask: Task<Void, Never>?
    private let syncInterval: TimeInterval = 60 // Sync every 60 seconds

    func startSync() async {
        syncTask = Task {
            while !Task.isCancelled {
                do {
                    try await syncNow()
                    try await Task.sleep(for: .seconds(syncInterval))
                } catch {
                    syncStatus = .error(error)
                    try? await Task.sleep(for: .seconds(syncInterval * 2)) // Back off on error
                }
            }
        }
    }

    func stopSync() {
        syncTask?.cancel()
        syncTask = nil
    }

    func syncNow() async throws {
        guard !Task.isCancelled else { return }

        syncStatus = .syncing

        // 1. Upload local changes
        try await uploadPendingChanges()

        // 2. Download remote changes
        try await downloadRemoteChanges()

        // 3. Update timestamp
        lastSyncTime = Date()
        syncStatus = .idle
    }

    private func uploadPendingChanges() async throws {
        let pending = await localDataSource.fetchPendingSync()

        for item in pending {
            do {
                try await cloudKitService.upload(item)
                await localDataSource.markSynced(item)
            } catch {
                // Log error but continue with other items
                print("Failed to upload \(item.id): \(error)")
            }
        }
    }

    private func downloadRemoteChanges() async throws {
        let changes = try await cloudKitService.fetchChanges(
            since: lastSyncTime
        )

        for change in changes {
            switch change {
            case .created(let record), .updated(let record):
                try await handleRemoteUpdate(record)
            case .deleted(let recordID):
                try await handleRemoteDelete(recordID)
            }
        }
    }

    private func handleRemoteUpdate(_ record: CKRecord) async throws {
        let localItem = await localDataSource.fetch(record.recordID.recordName)

        if let local = localItem {
            // Item exists locally - check for conflict
            if local.updatedAt > record.modificationDate ?? Date.distantPast {
                // Local is newer - conflict!
                try await conflictResolver.resolve(
                    local: local,
                    remote: record
                )
            } else {
                // Remote is newer - apply
                try await localDataSource.update(from: record)
            }
        } else {
            // New item from remote
            try await localDataSource.insert(from: record)
        }
    }

    private func handleRemoteDelete(_ recordID: CKRecord.ID) async throws {
        await localDataSource.delete(recordID.recordName)
    }
}
```

---

## 4. CloudKit Service

### 4.1 CloudKit Operations

```swift
protocol CloudKitService {
    /// Upload record to CloudKit
    func upload<T: Syncable>(_ item: T) async throws

    /// Fetch changes since token
    func fetchChanges(since: Date?) async throws -> [CloudKitChange]

    /// Delete record
    func delete(_ recordID: CKRecord.ID) async throws

    /// Fetch specific record
    func fetch(_ recordID: CKRecord.ID) async throws -> CKRecord

    /// Batch operations
    func uploadBatch<T: Syncable>(_ items: [T]) async throws
}

enum CloudKitChange {
    case created(CKRecord)
    case updated(CKRecord)
    case deleted(CKRecord.ID)
}

class DefaultCloudKitService: CloudKitService {
    private let container = CKContainer.default()
    private let database: CKDatabase

    init(scope: CKDatabase.Scope = .private) {
        self.database = container.database(with: scope)
    }

    func upload<T: Syncable>(_ item: T) async throws {
        let record = try item.toCKRecord()

        // Save to CloudKit
        let savedRecord = try await database.save(record)

        print("✅ Uploaded \(savedRecord.recordType) \(savedRecord.recordID.recordName)")
    }

    func fetchChanges(since: Date?) async throws -> [CloudKitChange] {
        var changes: [CloudKitChange] = []

        // Use CKQueryOperation for fetching changes
        let query = CKQuery(
            recordType: "Annotation", // TODO: Make generic
            predicate: predicateForChanges(since: since)
        )

        let operation = CKQueryOperation(query: query)
        operation.resultsLimit = 100

        operation.recordMatchedBlock = { recordID, result in
            switch result {
            case .success(let record):
                if record.modificationDate ?? Date.distantPast > since ?? Date.distantPast {
                    changes.append(.updated(record))
                } else {
                    changes.append(.created(record))
                }
            case .failure(let error):
                print("Error fetching record: \(error)")
            }
        }

        try await withCheckedThrowingContinuation { continuation in
            operation.queryResultBlock = { result in
                switch result {
                case .success:
                    continuation.resume()
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }

            database.add(operation)
        }

        return changes
    }

    private func predicateForChanges(since: Date?) -> NSPredicate {
        if let since = since {
            return NSPredicate(
                format: "modificationDate > %@",
                since as NSDate
            )
        } else {
            return NSPredicate(value: true) // All records
        }
    }

    func uploadBatch<T: Syncable>(_ items: [T]) async throws {
        let records = try items.map { try $0.toCKRecord() }

        // CloudKit batch limit: 400 records
        let batches = records.chunked(into: 400)

        for batch in batches {
            let operation = CKModifyRecordsOperation(
                recordsToSave: batch,
                recordIDsToDelete: nil
            )

            operation.savePolicy = .changedKeys
            operation.qualityOfService = .userInitiated

            try await withCheckedThrowingContinuation { continuation in
                operation.modifyRecordsResultBlock = { result in
                    switch result {
                    case .success:
                        continuation.resume()
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }

                database.add(operation)
            }
        }
    }
}

// Helper extension
extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}
```

### 4.2 Syncable Protocol

```swift
protocol Syncable {
    var id: UUID { get }
    var updatedAt: Date { get }
    var cloudKitRecordName: String? { get set }
    var syncStatus: SyncItemStatus { get set }

    /// Convert to CloudKit record
    func toCKRecord() throws -> CKRecord

    /// Update from CloudKit record
    mutating func update(from record: CKRecord) throws
}

enum SyncItemStatus: String, Codable {
    case synced
    case pendingUpload
    case pendingDelete
    case conflict
    case error
}

// Example implementation
extension Annotation: Syncable {
    func toCKRecord() throws -> CKRecord {
        let recordID = CKRecord.ID(
            recordName: cloudKitRecordName ?? id.uuidString
        )
        let record = CKRecord(recordType: "Annotation", recordID: recordID)

        // Map fields
        record["id"] = id.uuidString
        record["type"] = type.rawValue
        record["title"] = title
        record["content"] = content.text

        // Spatial data
        record["positionX"] = Double(position.x)
        record["positionY"] = Double(position.y)
        record["positionZ"] = Double(position.z)
        record["scale"] = Double(scale)

        // References
        record["layerID"] = CKRecord.Reference(
            recordID: CKRecord.ID(recordName: layerID.uuidString),
            action: .none
        )

        record["ownerID"] = ownerID

        // Metadata
        record["createdAt"] = createdAt
        record["updatedAt"] = updatedAt
        record["isDeleted"] = isDeleted ? 1 : 0

        // Media asset
        if let mediaURL = content.mediaURL {
            let asset = CKAsset(fileURL: mediaURL)
            record["mediaAsset"] = asset
        }

        return record
    }

    mutating func update(from record: CKRecord) throws {
        guard let idString = record["id"] as? String,
              let uuid = UUID(uuidString: idString) else {
            throw SyncError.invalidRecord
        }

        self.id = uuid
        self.cloudKitRecordName = record.recordID.recordName

        if let typeString = record["type"] as? String,
           let annotationType = AnnotationType(rawValue: typeString) {
            self.type = annotationType
        }

        self.title = record["title"] as? String

        if let text = record["content"] as? String {
            self.content.text = text
        }

        // Spatial data
        if let x = record["positionX"] as? Double,
           let y = record["positionY"] as? Double,
           let z = record["positionZ"] as? Double {
            self.position = SIMD3<Float>(Float(x), Float(y), Float(z))
        }

        if let scale = record["scale"] as? Double {
            self.scale = Float(scale)
        }

        // Metadata
        if let created = record["createdAt"] as? Date {
            self.createdAt = created
        }

        if let updated = record["updatedAt"] as? Date {
            self.updatedAt = updated
        }

        if let deleted = record["isDeleted"] as? Int {
            self.isDeleted = deleted == 1
        }

        // Media asset
        if let asset = record["mediaAsset"] as? CKAsset,
           let fileURL = asset.fileURL {
            self.content.mediaURL = fileURL
        }

        self.syncStatus = .synced
    }
}

enum SyncError: LocalizedError {
    case invalidRecord
    case missingRequiredField(String)
    case conversionFailed

    var errorDescription: String? {
        switch self {
        case .invalidRecord:
            return "Invalid CloudKit record"
        case .missingRequiredField(let field):
            return "Missing required field: \(field)"
        case .conversionFailed:
            return "Failed to convert record"
        }
    }
}
```

---

## 5. Conflict Resolution

### 5.1 Conflict Detection

Conflicts occur when:
1. Local item updated after last sync
2. Remote item updated after last sync
3. Both have changes (both `updatedAt` > `lastSyncTime`)

### 5.2 Resolution Strategies

```swift
protocol ConflictResolver {
    func resolve<T: Syncable>(
        local: T,
        remote: CKRecord
    ) async throws -> T
}

class DefaultConflictResolver: ConflictResolver {
    private let strategy: ConflictResolutionStrategy

    init(strategy: ConflictResolutionStrategy = .lastWriteWins) {
        self.strategy = strategy
    }

    func resolve<T: Syncable>(
        local: T,
        remote: CKRecord
    ) async throws -> T {
        switch strategy {
        case .lastWriteWins:
            return try resolveLastWriteWins(local: local, remote: remote)

        case .remoteWins:
            var updated = local
            try updated.update(from: remote)
            return updated

        case .localWins:
            return local

        case .manual:
            return try await resolveManually(local: local, remote: remote)
        }
    }

    private func resolveLastWriteWins<T: Syncable>(
        local: T,
        remote: CKRecord
    ) throws -> T {
        let remoteModifiedDate = remote.modificationDate ?? Date.distantPast

        if local.updatedAt > remoteModifiedDate {
            // Local wins
            return local
        } else {
            // Remote wins
            var updated = local
            try updated.update(from: remote)
            return updated
        }
    }

    private func resolveManually<T: Syncable>(
        local: T,
        remote: CKRecord
    ) async throws -> T {
        // Present conflict to user via notification
        // Store conflict for later resolution
        // For now, default to last-write-wins

        return try resolveLastWriteWins(local: local, remote: remote)
    }
}

enum ConflictResolutionStrategy {
    case lastWriteWins // Default: Most recent change wins
    case remoteWins // Remote always wins
    case localWins // Local always wins
    case manual // User decides
}
```

### 5.3 Conflict UI

```swift
struct ConflictResolutionView: View {
    let local: Annotation
    let remote: Annotation
    let onResolve: (ConflictResolution) -> Void

    var body: some View {
        VStack {
            Text("Conflict Detected")
                .font(.title)

            HStack {
                VStack {
                    Text("Your Version")
                        .font(.headline)
                    AnnotationPreview(annotation: local)
                    Button("Use This") {
                        onResolve(.useLocal)
                    }
                }

                VStack {
                    Text("Other Version")
                        .font(.headline)
                    AnnotationPreview(annotation: remote)
                    Button("Use This") {
                        onResolve(.useRemote)
                    }
                }
            }
        }
    }
}

enum ConflictResolution {
    case useLocal
    case useRemote
    case merge // Future: Smart merge
}
```

---

## 6. Offline Support

### 6.1 Offline Queue

```swift
class OfflineQueueManager {
    private var pendingOperations: [SyncOperation] = []

    func enqueue(_ operation: SyncOperation) {
        pendingOperations.append(operation)
        saveQueue()
    }

    func processPendingOperations() async throws {
        for operation in pendingOperations {
            do {
                try await execute(operation)
                // Remove from queue on success
                pendingOperations.removeAll { $0.id == operation.id }
            } catch {
                print("Failed to process operation: \(error)")
                // Keep in queue for retry
            }
        }
        saveQueue()
    }

    private func execute(_ operation: SyncOperation) async throws {
        switch operation.type {
        case .create:
            try await cloudKitService.upload(operation.item)
        case .update:
            try await cloudKitService.upload(operation.item)
        case .delete:
            try await cloudKitService.delete(operation.recordID)
        }
    }

    private func saveQueue() {
        // Persist queue to disk for app restart
        UserDefaults.standard.set(
            try? JSONEncoder().encode(pendingOperations),
            forKey: "offlineQueue"
        )
    }

    private func loadQueue() {
        guard let data = UserDefaults.standard.data(forKey: "offlineQueue"),
              let operations = try? JSONDecoder().decode([SyncOperation].self, from: data) else {
            return
        }
        pendingOperations = operations
    }
}

struct SyncOperation: Codable, Identifiable {
    var id: UUID
    var type: OperationType
    var item: Data // Encoded Syncable
    var recordID: String
    var timestamp: Date

    enum OperationType: String, Codable {
        case create
        case update
        case delete
    }
}
```

### 6.2 Network Monitoring

```swift
import Network

@Observable
class NetworkMonitor {
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")

    var isConnected = false
    var connectionType: ConnectionType = .unknown

    init() {
        monitor.pathUpdateHandler = { [weak self] path in
            Task { @MainActor in
                self?.isConnected = path.status == .satisfied
                self?.connectionType = self?.getConnectionType(path) ?? .unknown
            }
        }
        monitor.start(queue: queue)
    }

    private func getConnectionType(_ path: NWPath) -> ConnectionType {
        if path.usesInterfaceType(.wifi) {
            return .wifi
        } else if path.usesInterfaceType(.cellular) {
            return .cellular
        } else {
            return .unknown
        }
    }

    enum ConnectionType {
        case wifi
        case cellular
        case unknown
    }
}

// Usage in SyncCoordinator
class SyncCoordinator {
    private let networkMonitor = NetworkMonitor()

    func startSync() {
        // Only sync when connected
        if networkMonitor.isConnected {
            Task {
                try await syncNow()
            }
        }

        // Listen for network changes
        Task {
            for await isConnected in networkMonitor.$isConnected.values {
                if isConnected {
                    // Network restored, sync now
                    try? await syncNow()
                }
            }
        }
    }
}
```

---

## 7. Real-Time Updates

### 7.1 CloudKit Subscriptions

```swift
class CloudKitSubscriptionManager {
    private let database: CKDatabase
    private var subscriptionIDs: Set<String> = []

    func setupSubscriptions() async throws {
        // Subscribe to annotation changes
        try await subscribeToAnnotations()

        // Subscribe to layer changes
        try await subscribeToLayers()

        // Subscribe to comments
        try await subscribeToComments()
    }

    private func subscribeToAnnotations() async throws {
        let subscription = CKQuerySubscription(
            recordType: "Annotation",
            predicate: NSPredicate(value: true),
            subscriptionID: "annotation-changes",
            options: [.firesOnRecordCreation, .firesOnRecordUpdate, .firesOnRecordDeletion]
        )

        let notificationInfo = CKSubscription.NotificationInfo()
        notificationInfo.shouldSendContentAvailable = true
        subscription.notificationInfo = notificationInfo

        try await database.save(subscription)
        subscriptionIDs.insert("annotation-changes")
    }

    func handleNotification(_ notification: CKQueryNotification) async {
        // Notification received - trigger sync
        await syncCoordinator.syncNow()
    }
}
```

### 7.2 Push Notifications

```swift
class PushNotificationManager: NSObject, UNUserNotificationCenterDelegate {
    func requestAuthorization() async throws {
        let center = UNUserNotificationCenter.current()
        try await center.requestAuthorization(options: [.alert, .badge, .sound])

        // Register for remote notifications
        await UIApplication.shared.registerForRemoteNotifications()
    }

    // In AppDelegate
    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        // CloudKit notification received
        if let notification = CKNotification(fromRemoteNotificationDictionary: userInfo) {
            Task {
                await handleCloudKitNotification(notification)
                completionHandler(.newData)
            }
        } else {
            completionHandler(.noData)
        }
    }

    private func handleCloudKitNotification(_ notification: CKNotification) async {
        guard let queryNotification = notification as? CKQueryNotification else {
            return
        }

        // Trigger sync for changed records
        if let recordID = queryNotification.recordID {
            await syncCoordinator.syncRecord(recordID)
        } else {
            // Full sync if specific record not identified
            await syncCoordinator.syncNow()
        }
    }
}
```

---

## 8. Sharing & Collaboration

### 8.1 CKShare for Shared Layers/Annotations

```swift
protocol SharingService {
    /// Create share for item
    func share(_ item: any Syncable, with users: [String]) async throws -> CKShare

    /// Accept share invitation
    func acceptShare(_ shareMetadata: CKShare.Metadata) async throws

    /// Revoke share
    func revokeShare(_ share: CKShare) async throws
}

class DefaultSharingService: SharingService {
    private let container = CKContainer.default()
    private let sharedDatabase: CKDatabase

    init() {
        self.sharedDatabase = container.sharedCloudDatabase
    }

    func share(_ item: any Syncable, with users: [String]) async throws -> CKShare {
        // 1. Create CKRecord if needed
        let record = try item.toCKRecord()

        // 2. Create CKShare
        let share = CKShare(rootRecord: record)
        share[CKShare.SystemFieldKey.title] = "Shared Annotation"

        // 3. Save both record and share
        let (savedRecords, _) = try await sharedDatabase.modifyRecords(
            saving: [record, share],
            deleting: []
        )

        guard let savedShare = savedRecords.first(where: { $0 is CKShare }) as? CKShare else {
            throw SharingError.shareFailed
        }

        // 4. Send share URL to users
        // (via email, message, etc.)

        return savedShare
    }

    func acceptShare(_ shareMetadata: CKShare.Metadata) async throws {
        // Accept the share invitation
        try await container.accept(shareMetadata)

        // Fetch shared records
        let recordID = shareMetadata.rootRecordID
        let record = try await sharedDatabase.record(for: recordID)

        // Save to local database
        var item = Annotation() // Convert from record
        try item.update(from: record)
        try await localDataSource.save(item)
    }
}

enum SharingError: LocalizedError {
    case shareFailed
    case acceptFailed

    var errorDescription: String? {
        switch self {
        case .shareFailed: return "Failed to create share"
        case .acceptFailed: return "Failed to accept share"
        }
    }
}
```

---

## 9. Sync Performance Optimization

### 9.1 Delta Sync (Only Changed Fields)

```swift
extension CKModifyRecordsOperation {
    func configureDeltaSync() {
        // Only upload changed fields
        self.savePolicy = .changedKeys

        // Atomic operations
        self.isAtomic = false // Continue on partial failure
    }
}
```

### 9.2 Batch Operations

```swift
class BatchSyncManager {
    private let batchSize = 100

    func syncAnnotations(_ annotations: [Annotation]) async throws {
        // Split into batches
        for batch in annotations.chunked(into: batchSize) {
            try await uploadBatch(batch)
        }
    }

    private func uploadBatch(_ batch: [Annotation]) async throws {
        let records = try batch.map { try $0.toCKRecord() }

        let operation = CKModifyRecordsOperation(
            recordsToSave: records,
            recordIDsToDelete: nil
        )

        operation.configureDeltaSync()
        operation.qualityOfService = .userInitiated

        try await database.add(operation)
    }
}
```

### 9.3 Change Tokens

```swift
class ChangeTokenManager {
    private var tokens: [String: CKServerChangeToken] = [:]

    func saveToken(_ token: CKServerChangeToken, for zone: String) {
        tokens[zone] = token

        // Persist to disk
        if let data = try? NSKeyedArchiver.archivedData(
            withRootObject: token,
            requiringSecureCoding: true
        ) {
            UserDefaults.standard.set(data, forKey: "changeToken_\(zone)")
        }
    }

    func loadToken(for zone: String) -> CKServerChangeToken? {
        if let token = tokens[zone] {
            return token
        }

        // Load from disk
        guard let data = UserDefaults.standard.data(forKey: "changeToken_\(zone)"),
              let token = try? NSKeyedUnarchiver.unarchivedObject(
                ofClass: CKServerChangeToken.self,
                from: data
              ) else {
            return nil
        }

        tokens[zone] = token
        return token
    }

    func fetchChanges(since token: CKServerChangeToken?) async throws -> [CloudKitChange] {
        let configuration = CKFetchRecordZoneChangesOperation.ZoneConfiguration()
        configuration.previousServerChangeToken = token

        // Fetch changes...
        // Implementation details...

        return []
    }
}
```

---

## 10. Error Handling & Retry Logic

### 10.1 Retry Strategy

```swift
class RetryManager {
    func retry<T>(
        maxAttempts: Int = 3,
        initialDelay: TimeInterval = 1.0,
        operation: @escaping () async throws -> T
    ) async throws -> T {
        var attempt = 0
        var delay = initialDelay

        while attempt < maxAttempts {
            do {
                return try await operation()
            } catch {
                attempt += 1

                if attempt >= maxAttempts {
                    throw error
                }

                // Check if error is retryable
                if !isRetryable(error) {
                    throw error
                }

                // Exponential backoff
                try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                delay *= 2
            }
        }

        throw SyncError.maxRetriesExceeded
    }

    private func isRetryable(_ error: Error) -> Bool {
        guard let ckError = error as? CKError else {
            return false
        }

        switch ckError.code {
        case .networkUnavailable, .networkFailure, .serviceUnavailable, .requestRateLimited:
            return true
        default:
            return false
        }
    }
}

// Usage
let result = try await retryManager.retry {
    try await cloudKitService.upload(annotation)
}
```

### 10.2 CloudKit Error Handling

```swift
func handleCloudKitError(_ error: Error) async throws {
    guard let ckError = error as? CKError else {
        throw error
    }

    switch ckError.code {
    case .networkUnavailable, .networkFailure:
        // Network issue - queue for later
        syncStatus = .offline
        throw error

    case .requestRateLimited:
        // Rate limited - back off
        if let retryAfter = ckError.userInfo[CKErrorRetryAfterKey] as? TimeInterval {
            try await Task.sleep(nanoseconds: UInt64(retryAfter * 1_000_000_000))
        }
        throw error

    case .quotaExceeded:
        // User quota exceeded
        notifyUserQuotaExceeded()
        throw error

    case .notAuthenticated:
        // Not signed into iCloud
        notifyUserNotAuthenticated()
        throw error

    case .serverRecordChanged:
        // Conflict - handle with conflict resolver
        // Extract server record from error
        if let serverRecord = ckError.userInfo[CKRecordChangedErrorServerRecordKey] as? CKRecord {
            // Trigger conflict resolution
            throw SyncError.conflict(serverRecord)
        }

    default:
        throw error
    }
}
```

---

## 11. Testing Sync Logic

### 11.1 Mock CloudKit Service

```swift
class MockCloudKitService: CloudKitService {
    var records: [CKRecord.ID: CKRecord] = [:]
    var uploadDelay: TimeInterval = 0.1

    func upload<T: Syncable>(_ item: T) async throws {
        try await Task.sleep(nanoseconds: UInt64(uploadDelay * 1_000_000_000))

        let record = try item.toCKRecord()
        records[record.recordID] = record
    }

    func fetchChanges(since: Date?) async throws -> [CloudKitChange] {
        return records.values
            .filter { record in
                guard let since = since else { return true }
                return (record.modificationDate ?? Date.distantPast) > since
            }
            .map { .updated($0) }
    }

    func simulateConflict() {
        // Helper for testing conflicts
    }
}

// Test
func testSyncUpload() async throws {
    let mockService = MockCloudKitService()
    let coordinator = SyncCoordinator(cloudKitService: mockService)

    let annotation = Annotation(...)
    try await coordinator.queueForSync(annotation)
    try await coordinator.syncNow()

    XCTAssertEqual(mockService.records.count, 1)
}
```

---

## 12. Monitoring & Observability

### 12.1 Sync Metrics

```swift
class SyncMetrics {
    var uploadCount = 0
    var downloadCount = 0
    var conflictCount = 0
    var errorCount = 0
    var lastSyncDuration: TimeInterval?

    func recordUpload() {
        uploadCount += 1
    }

    func recordConflict() {
        conflictCount += 1
    }

    func reset() {
        uploadCount = 0
        downloadCount = 0
        conflictCount = 0
        errorCount = 0
    }
}

// Usage
let metrics = SyncMetrics()

func syncNow() async throws {
    let start = Date()

    // ... sync logic ...

    metrics.lastSyncDuration = Date().timeIntervalSince(start)
}
```

---

## 13. Appendix

### 13.1 Best Practices

1. **Sync frequently** (every 60 seconds when active)
2. **Use change tokens** (only fetch what changed)
3. **Batch operations** (max 400 records per batch)
4. **Handle conflicts gracefully** (last-write-wins for MVP)
5. **Support offline** (queue operations, sync when online)
6. **Monitor network** (don't waste battery on failed requests)
7. **Test edge cases** (conflicts, offline, quota exceeded)

### 13.2 Common Pitfalls

- ❌ Syncing too frequently (battery drain)
- ❌ Not using change tokens (fetching everything)
- ❌ Ignoring conflicts (data loss)
- ❌ No offline support (poor UX)
- ❌ Not handling CloudKit errors (crashes)

### 13.3 References

- [CloudKit Sync](https://developer.apple.com/documentation/cloudkit)
- [CKSyncEngine (iOS 17+)](https://developer.apple.com/documentation/cloudkit/cksyncengine)
- [CloudKit Best Practices](https://developer.apple.com/videos/play/wwdc2021/10015/)

---

**Document Status**: ✅ Ready for Implementation
**Dependencies**: System Architecture, Data Model
**Next Steps**: Create API & Service Contracts document
