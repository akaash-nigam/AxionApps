# Data Model & Schema Design
## Home Maintenance Oracle

**Version**: 1.0
**Last Updated**: 2025-11-24
**Status**: Draft

---

## Table of Contents

1. [Overview](#overview)
2. [Entity-Relationship Diagram](#entity-relationship-diagram)
3. [Core Data Schema](#core-data-schema)
4. [CloudKit Schema](#cloudkit-schema)
5. [Data Transfer Objects](#data-transfer-objects)
6. [Database Relationships](#database-relationships)
7. [Sync Strategy](#sync-strategy)
8. [Migration Strategy](#migration-strategy)
9. [Query Patterns](#query-patterns)

---

## Overview

### Storage Strategy

| Data Type | Storage | Sync | Reason |
|-----------|---------|------|--------|
| User inventory | Core Data | CloudKit | Persistent, multi-device |
| Maintenance tasks | Core Data | CloudKit | Persistent, multi-device |
| Service history | Core Data | CloudKit | Persistent, multi-device |
| Manual cache | File System | None | Large files, device-specific |
| User preferences | UserDefaults | NSUbiquitousKeyValueStore | Small, simple sync |
| API tokens | Keychain | None | Secure, never sync |
| ML models | Bundle/Download | None | Large, version controlled |
| Spatial anchors | ARKit persistence | None | Device-specific |

---

## Entity-Relationship Diagram

```
┌────────────────────┐
│      Home          │
│ ─────────────────  │
│ id: UUID           │
│ name: String       │
│ address: String?   │
│ purchaseDate: Date?│
│ squareFootage: Int?│
└────────────────────┘
         │
         │ 1:N
         ▼
┌────────────────────┐         ┌────────────────────┐
│    Appliance       │◄────┐   │     Manual         │
│ ───────────────    │     │   │ ──────────────     │
│ id: UUID           │     │   │ id: UUID           │
│ brand: String      │     │   │ applianceId: UUID  │
│ model: String      │     │   │ title: String      │
│ serialNumber: String?    │   │ pdfURL: URL?       │
│ category: String   │     │   │ localPath: String? │
│ installDate: Date? │     │   │ pageCount: Int     │
│ purchasePrice: $?  │     │   │ language: String   │
│ warrantyExpiry: Date?    └───│ fileSize: Int64    │
│ notes: String?     │         │ lastAccessed: Date │
│ roomLocation: String│        └────────────────────┘
│ spatialAnchorId: String?│
└────────────────────┘
         │
         │ 1:N
         ▼
┌────────────────────┐
│  MaintenanceTask   │
│ ──────────────────│
│ id: UUID           │
│ applianceId: UUID  │
│ title: String      │
│ description: String│
│ type: TaskType     │
│ frequency: Interval│
│ dueDate: Date      │
│ completedDate: Date?│
│ isRecurring: Bool  │
│ priority: Priority │
│ estimatedCost: $?  │
│ notificationId: String?│
└────────────────────┘
         │
         │ 1:N
         ▼
┌────────────────────┐
│  ServiceHistory    │
│ ──────────────────│
│ id: UUID           │
│ applianceId: UUID  │
│ maintenanceTaskId: UUID?│
│ date: Date         │
│ title: String      │
│ description: String│
│ serviceType: Type  │
│ cost: Decimal?     │
│ vendor: String?    │
│ warrantyWork: Bool │
│ photos: [Photo]    │
│ notes: String?     │
└────────────────────┘

┌────────────────────┐
│       Photo        │
│ ──────────────────│
│ id: UUID           │
│ serviceHistoryId: UUID│
│ filePath: String   │
│ thumbnailPath: String│
│ captureDate: Date  │
│ notes: String?     │
└────────────────────┘

┌────────────────────┐
│     Tutorial       │
│ ──────────────────│
│ id: UUID           │
│ applianceId: UUID? │
│ title: String      │
│ description: String│
│ videoURL: URL      │
│ thumbnailURL: URL  │
│ duration: Int      │
│ difficulty: Level  │
│ source: String     │
│ toolsRequired: [String]│
│ partsRequired: [String]│
│ viewCount: Int     │
│ isCached: Bool     │
│ cachedPath: String?│
└────────────────────┘

┌────────────────────┐
│       Part         │
│ ──────────────────│
│ id: UUID           │
│ applianceId: UUID? │
│ partNumber: String │
│ name: String       │
│ description: String│
│ category: String   │
│ imageURL: URL?     │
│ compatibleModels: [String]│
└────────────────────┘
         │
         │ 1:N
         ▼
┌────────────────────┐
│   PartListing      │
│ ──────────────────│
│ id: UUID           │
│ partId: UUID       │
│ supplier: String   │
│ price: Decimal     │
│ availability: Status│
│ shippingCost: Decimal?│
│ deliveryDays: Int  │
│ url: URL           │
│ affiliateURL: URL? │
│ isOEM: Bool        │
│ rating: Float?     │
│ reviewCount: Int   │
│ lastUpdated: Date  │
└────────────────────┘

┌────────────────────┐
│  RecognitionCache  │
│ ──────────────────│
│ id: UUID           │
│ imageHash: String  │
│ applianceCategory: String│
│ brand: String?     │
│ model: String?     │
│ confidence: Float  │
│ timestamp: Date    │
└────────────────────┘

┌────────────────────┐
│   UserPreferences  │
│ ──────────────────│
│ notificationsEnabled: Bool│
│ notificationTime: Time│
│ measurementSystem: String│
│ defaultReminder: Days│
│ autoSync: Bool     │
│ dataUsageWifi: Bool│
│ cacheSize: Int64   │
│ selectedHomeId: UUID?│
└────────────────────┘
```

---

## Core Data Schema

### ApplianceEntity

```swift
@objc(ApplianceEntity)
public class ApplianceEntity: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var brand: String
    @NSManaged public var model: String
    @NSManaged public var serialNumber: String?
    @NSManaged public var category: String
    @NSManaged public var installDate: Date?
    @NSManaged public var purchaseDate: Date?
    @NSManaged public var purchasePrice: NSDecimalNumber?
    @NSManaged public var warrantyExpiry: Date?
    @NSManaged public var warrantyDuration: Int16  // months
    @NSManaged public var notes: String?
    @NSManaged public var roomLocation: String?
    @NSManaged public var spatialAnchorId: String?
    @NSManaged public var imageData: Data?
    @NSManaged public var createdAt: Date
    @NSManaged public var updatedAt: Date

    // Relationships
    @NSManaged public var home: HomeEntity?
    @NSManaged public var maintenanceTasks: NSSet?
    @NSManaged public var serviceHistory: NSSet?
    @NSManaged public var manuals: NSSet?
}

// Category enum (stored as String)
enum ApplianceCategory: String, CaseIterable {
    case refrigerator
    case oven
    case dishwasher
    case washer
    case dryer
    case hvac
    case waterHeater
    case furnace
    case garageDoor
    case other
}
```

### HomeEntity

```swift
@objc(HomeEntity)
public class HomeEntity: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var address: String?
    @NSManaged public var purchaseDate: Date?
    @NSManaged public var squareFootage: Int32
    @NSManaged public var yearBuilt: Int16
    @NSManaged public var homeType: String  // single_family, condo, apartment
    @NSManaged public var notes: String?
    @NSManaged public var createdAt: Date
    @NSManaged public var updatedAt: Date

    // Relationships
    @NSManaged public var appliances: NSSet?
}
```

### MaintenanceTaskEntity

```swift
@objc(MaintenanceTaskEntity)
public class MaintenanceTaskEntity: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var title: String
    @NSManaged public var taskDescription: String?
    @NSManaged public var type: String  // TaskType enum
    @NSManaged public var frequency: Int32  // days
    @NSManaged public var dueDate: Date
    @NSManaged public var completedDate: Date?
    @NSManaged public var isRecurring: Bool
    @NSManaged public var priority: String  // low, medium, high, urgent
    @NSManaged public var estimatedCost: NSDecimalNumber?
    @NSManaged public var estimatedDuration: Int16  // minutes
    @NSManaged public var notificationId: String?
    @NSManaged public var createdAt: Date
    @NSManaged public var updatedAt: Date

    // Relationships
    @NSManaged public var appliance: ApplianceEntity?
    @NSManaged public var serviceRecords: NSSet?

    // Computed
    var isOverdue: Bool {
        guard completedDate == nil else { return false }
        return dueDate < Date()
    }
}

enum TaskType: String {
    case inspection
    case cleaning
    case replacement
    case repair
    case calibration
    case seasonal
}

enum Priority: String {
    case low
    case medium
    case high
    case urgent
}
```

### ServiceHistoryEntity

```swift
@objc(ServiceHistoryEntity)
public class ServiceHistoryEntity: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var date: Date
    @NSManaged public var title: String
    @NSManaged public var serviceDescription: String?
    @NSManaged public var serviceType: String  // maintenance, repair, replacement
    @NSManaged public var cost: NSDecimalNumber?
    @NSManaged public var vendor: String?
    @NSManaged public var vendorContact: String?
    @NSManaged public var warrantyWork: Bool
    @NSManaged public var notes: String?
    @NSManaged public var createdAt: Date
    @NSManaged public var updatedAt: Date

    // Relationships
    @NSManaged public var appliance: ApplianceEntity?
    @NSManaged public var maintenanceTask: MaintenanceTaskEntity?
    @NSManaged public var photos: NSSet?
}

enum ServiceType: String {
    case maintenance
    case repair
    case replacement
    case installation
    case inspection
}
```

### ManualEntity

```swift
@objc(ManualEntity)
public class ManualEntity: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var title: String
    @NSManaged public var manualType: String  // owner, service, installation, parts
    @NSManaged public var pdfURL: URL?
    @NSManaged public var localPath: String?
    @NSManaged public var pageCount: Int16
    @NSManaged public var language: String
    @NSManaged public var fileSize: Int64
    @NSManaged public var isDownloaded: Bool
    @NSManaged public var lastAccessed: Date?
    @NSManaged public var bookmarkedPages: Data?  // [Int] encoded
    @NSManaged public var createdAt: Date
    @NSManaged public var updatedAt: Date

    // Relationships
    @NSManaged public var appliance: ApplianceEntity?
}

enum ManualType: String {
    case owner
    case service
    case installation
    case parts
    case troubleshooting
    case quickReference
}
```

### TutorialEntity

```swift
@objc(TutorialEntity)
public class TutorialEntity: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var title: String
    @NSManaged public var tutorialDescription: String?
    @NSManaged public var videoURL: URL
    @NSManaged public var thumbnailURL: URL?
    @NSManaged public var duration: Int32  // seconds
    @NSManaged public var difficulty: String  // easy, medium, hard, expert
    @NSManaged public var source: String  // youtube, vimeo, custom
    @NSManaged public var sourceId: String  // external video ID
    @NSManaged public var toolsRequired: Data?  // [String] encoded
    @NSManaged public var partsRequired: Data?  // [String] encoded
    @NSManaged public var viewCount: Int32
    @NSManaged public var isCached: Bool
    @NSManaged public var cachedPath: String?
    @NSManaged public var lastWatched: Date?
    @NSManaged public var createdAt: Date

    // Relationships
    @NSManaged public var appliances: NSSet?  // Many-to-many
}

enum Difficulty: String {
    case easy
    case medium
    case hard
    case expert
}
```

### PhotoEntity

```swift
@objc(PhotoEntity)
public class PhotoEntity: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var filePath: String
    @NSManaged public var thumbnailPath: String
    @NSManaged public var captureDate: Date
    @NSManaged public var notes: String?
    @NSManaged public var fileSize: Int64
    @NSManaged public var createdAt: Date

    // Relationships
    @NSManaged public var serviceHistory: ServiceHistoryEntity?
}
```

---

## CloudKit Schema

### Container Structure

**Container ID**: `iCloud.com.hmo.HomeMaintenanceOracle`

**Databases**:
- **Private Database**: User's home inventory, tasks, history
- **Public Database**: Shared manuals, tutorials, parts database

### Record Types

#### CKAppliance

```swift
// Private Database
struct CKAppliance {
    let recordID: CKRecord.ID
    var brand: String
    var model: String
    var serialNumber: String?
    var category: String
    var installDate: Date?
    var purchasePrice: Double?
    var warrantyExpiry: Date?
    var notes: String?
    var roomLocation: String?
    var imageAsset: CKAsset?
    var modificationDate: Date

    // References
    var homeReference: CKRecord.Reference?
}
```

#### CKMaintenanceTask

```swift
// Private Database
struct CKMaintenanceTask {
    let recordID: CKRecord.ID
    var title: String
    var description: String?
    var type: String
    var frequency: Int
    var dueDate: Date
    var completedDate: Date?
    var isRecurring: Bool
    var priority: String
    var modificationDate: Date

    // References
    var applianceReference: CKRecord.Reference
}
```

#### CKServiceHistory

```swift
// Private Database
struct CKServiceHistory {
    let recordID: CKRecord.ID
    var date: Date
    var title: String
    var description: String?
    var serviceType: String
    var cost: Double?
    var vendor: String?
    var warrantyWork: Bool
    var photoAssets: [CKAsset]?
    var modificationDate: Date

    // References
    var applianceReference: CKRecord.Reference
}
```

#### CKManualLibrary (Public)

```swift
// Public Database - shared manual library
struct CKManualLibrary {
    let recordID: CKRecord.ID
    var brand: String
    var model: String
    var manualType: String
    var title: String
    var pdfAsset: CKAsset
    var pageCount: Int
    var language: String
    var fileSize: Int
    var uploadDate: Date
}
```

---

## Data Transfer Objects (DTOs)

DTOs for API communication:

```swift
// API Response Models
struct ManualSearchResponse: Codable {
    let manuals: [ManualDTO]
    let totalResults: Int
}

struct ManualDTO: Codable {
    let id: String
    let brand: String
    let model: String
    let title: String
    let type: String
    let downloadURL: URL
    let pageCount: Int
    let language: String
    let fileSize: Int64
}

struct PartSearchResponse: Codable {
    let parts: [PartDTO]
    let totalResults: Int
}

struct PartDTO: Codable {
    let id: String
    let partNumber: String
    let name: String
    let description: String
    let imageURL: URL?
    let compatibleModels: [String]
    let listings: [PartListingDTO]
}

struct PartListingDTO: Codable {
    let supplier: String
    let price: Decimal
    let currency: String
    let availability: String
    let shippingCost: Decimal?
    let deliveryDays: Int
    let productURL: URL
    let affiliateURL: URL?
    let isOEM: Bool
    let rating: Float?
    let reviewCount: Int
}

struct TutorialSearchResponse: Codable {
    let tutorials: [TutorialDTO]
    let totalResults: Int
}

struct TutorialDTO: Codable {
    let id: String
    let title: String
    let description: String
    let videoURL: URL
    let thumbnailURL: URL
    let duration: Int
    let difficulty: String
    let source: String
    let toolsRequired: [String]
    let partsRequired: [String]
}

struct RecognitionResponse: Codable {
    let category: String
    let brand: String?
    let model: String?
    let confidence: Float
    let alternatives: [RecognitionAlternative]
}

struct RecognitionAlternative: Codable {
    let category: String
    let brand: String?
    let model: String?
    let confidence: Float
}
```

---

## Database Relationships

### Relationship Cardinalities

```
Home 1───N Appliance
Appliance 1───N MaintenanceTask
Appliance 1───N ServiceHistory
Appliance 1───N Manual
ServiceHistory 1───N Photo
MaintenanceTask 1───N ServiceHistory
Appliance N───N Tutorial
```

### Delete Rules

| Relationship | Delete Rule | Reason |
|--------------|-------------|--------|
| Home → Appliance | CASCADE | Delete all appliances when home deleted |
| Appliance → MaintenanceTask | CASCADE | Delete tasks when appliance deleted |
| Appliance → ServiceHistory | CASCADE | Delete history when appliance deleted |
| Appliance → Manual | NULLIFY | Manuals can exist independently |
| ServiceHistory → Photo | CASCADE | Delete photos when service record deleted |
| MaintenanceTask → ServiceHistory | NULLIFY | History remains even if task deleted |

---

## Sync Strategy

### CloudKit Sync Architecture

```
Core Data (Local)
       │
       ├─── NSPersistentCloudKitContainer
       │
       └─── CloudKit (Remote)
              ├─── Private Database (User Data)
              └─── Shared Database (Family/Team) [Future]
```

### Sync Rules

**Automatic Sync**:
- Triggered on app launch
- Background fetch every 1 hour
- After significant data changes

**Manual Sync**:
- Pull-to-refresh in inventory view
- Settings → "Sync Now" button

**Conflict Resolution**:
```swift
// Custom merge policy
lazy var persistentContainer: NSPersistentCloudKitContainer = {
    let container = NSPersistentCloudKitContainer(name: "HomeMaintenanceOracle")

    // Conflict resolution: Last writer wins
    let description = container.persistentStoreDescriptions.first
    description?.setOption(true as NSNumber,
                          forKey: NSPersistentHistoryTrackingKey)
    description?.setOption(true as NSNumber,
                          forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)

    // CloudKit container options
    let options = NSPersistentCloudKitContainerOptions(
        containerIdentifier: "iCloud.com.hmo.HomeMaintenanceOracle"
    )
    description?.cloudKitContainerOptions = options

    return container
}()
```

### Sync Conflict Handling

**Strategy**: Last-Write-Wins with user notification on conflicts

```swift
class SyncConflictResolver {
    func resolve(_ conflict: NSMergeConflict) -> NSManagedObject {
        let localObject = conflict.sourceObject
        let remoteObject = conflict.objectSnapshot

        // Compare modification dates
        let localDate = localObject.value(forKey: "updatedAt") as? Date ?? .distantPast
        let remoteDate = remoteObject?["updatedAt"] as? Date ?? .distantPast

        if remoteDate > localDate {
            // Remote wins - notify user of changes
            NotificationCenter.default.post(
                name: .syncConflictResolved,
                object: nil,
                userInfo: ["objectType": type(of: localObject)]
            )
            return conflict.persistedSnapshot as! NSManagedObject
        } else {
            // Local wins
            return localObject
        }
    }
}
```

### Offline Support

**Strategy**: Full offline functionality, sync when online

- All reads from local Core Data
- Writes queued for sync
- Conflict resolution on reconnect
- User notified of sync status

---

## Migration Strategy

### Version Management

```swift
enum SchemaVersion: Int {
    case v1 = 1  // Initial release
    case v2 = 2  // Add spatial anchors
    case v3 = 3  // Add tutorial caching
    // Future versions...

    static var current: SchemaVersion = .v1
}
```

### Lightweight Migration

For simple changes (add attribute, change optional):

```swift
let description = NSPersistentStoreDescription()
description.shouldMigrateStoreAutomatically = true
description.shouldInferMappingModelAutomatically = true
```

### Heavy Migration

For complex changes (entity splitting, relationship changes):

```swift
class MigrationManager {
    func migrateIfNeeded() {
        let storeURL = persistentContainer.persistentStoreDescriptions.first!.url!

        guard let metadata = try? NSPersistentStoreCoordinator.metadataForPersistentStore(
            ofType: NSSQLiteStoreType,
            at: storeURL
        ) else { return }

        let currentModel = persistentContainer.managedObjectModel
        let isCompatible = currentModel.isConfiguration(
            withName: nil,
            compatibleWithStoreMetadata: metadata
        )

        if !isCompatible {
            performMigration(from: storeURL)
        }
    }

    private func performMigration(from storeURL: URL) {
        // Custom migration logic
        // Create mapping model
        // Perform progressive migration if needed
    }
}
```

### Migration Testing

```swift
class MigrationTests: XCTestCase {
    func testMigrationFromV1ToV2() {
        let storeURL = createV1Store()
        let container = NSPersistentContainer(name: "Model_V2")
        // Test migration...
    }
}
```

---

## Query Patterns

### Common Queries

#### Fetch All Appliances for Home

```swift
func fetchAppliances(for home: HomeEntity) -> [ApplianceEntity] {
    let request: NSFetchRequest<ApplianceEntity> = ApplianceEntity.fetchRequest()
    request.predicate = NSPredicate(format: "home == %@", home)
    request.sortDescriptors = [
        NSSortDescriptor(keyPath: \ApplianceEntity.category, ascending: true),
        NSSortDescriptor(keyPath: \ApplianceEntity.brand, ascending: true)
    ]

    return try? context.fetch(request) ?? []
}
```

#### Fetch Upcoming Maintenance Tasks

```swift
func fetchUpcomingTasks(within days: Int) -> [MaintenanceTaskEntity] {
    let request: NSFetchRequest<MaintenanceTaskEntity> = MaintenanceTaskEntity.fetchRequest()

    let startDate = Date()
    let endDate = Calendar.current.date(byAdding: .day, value: days, to: startDate)!

    request.predicate = NSPredicate(
        format: "completedDate == nil AND dueDate >= %@ AND dueDate <= %@",
        startDate as NSDate,
        endDate as NSDate
    )
    request.sortDescriptors = [
        NSSortDescriptor(keyPath: \MaintenanceTaskEntity.dueDate, ascending: true)
    ]

    return try? context.fetch(request) ?? []
}
```

#### Fetch Service History with Photos

```swift
func fetchServiceHistory(for appliance: ApplianceEntity) -> [ServiceHistoryEntity] {
    let request: NSFetchRequest<ServiceHistoryEntity> = ServiceHistoryEntity.fetchRequest()
    request.predicate = NSPredicate(format: "appliance == %@", appliance)
    request.sortDescriptors = [
        NSSortDescriptor(keyPath: \ServiceHistoryEntity.date, ascending: false)
    ]
    request.relationshipKeyPathsForPrefetching = ["photos"]  // Eager load

    return try? context.fetch(request) ?? []
}
```

#### Search Appliances by Category

```swift
func searchAppliances(category: ApplianceCategory, in home: HomeEntity) -> [ApplianceEntity] {
    let request: NSFetchRequest<ApplianceEntity> = ApplianceEntity.fetchRequest()
    request.predicate = NSPredicate(
        format: "home == %@ AND category == %@",
        home,
        category.rawValue
    )
    request.sortDescriptors = [
        NSSortDescriptor(keyPath: \ApplianceEntity.brand, ascending: true)
    ]

    return try? context.fetch(request) ?? []
}
```

### Performance Optimization

#### Batching

```swift
// Batch fetch for large datasets
request.fetchBatchSize = 20

// Batch delete
let batchDelete = NSBatchDeleteRequest(fetchRequest: request)
try context.execute(batchDelete)
```

#### Faulting

```swift
// Reduce memory footprint
request.returnsObjectsAsFaults = true

// Prefetch relationships
request.relationshipKeyPathsForPrefetching = ["appliance", "photos"]
```

#### Indexing

Core Data automatically indexes:
- Primary keys
- Relationship foreign keys

Manual indexing in .xcdatamodeld:
- Frequently queried attributes (category, dueDate)

---

## Data Validation

### Entity Validation

```swift
extension ApplianceEntity {
    public override func validateForInsert() throws {
        try super.validateForInsert()
        try validateBrand()
        try validateModel()
        try validateCategory()
    }

    private func validateBrand() throws {
        guard !brand.isEmpty else {
            throw ValidationError.emptyBrand
        }
    }

    private func validateModel() throws {
        guard !model.isEmpty else {
            throw ValidationError.emptyModel
        }
    }

    private func validateCategory() throws {
        guard ApplianceCategory(rawValue: category) != nil else {
            throw ValidationError.invalidCategory
        }
    }
}
```

---

## Performance Metrics

### Target Metrics

| Operation | Target | Max |
|-----------|--------|-----|
| Fetch 100 appliances | < 50ms | 100ms |
| Insert appliance | < 10ms | 50ms |
| Complex query (joins) | < 100ms | 200ms |
| CloudKit sync (100 records) | < 5s | 10s |
| Database size (1000 appliances) | < 50MB | 100MB |

---

**Document Status**: Ready for Review
**Next Steps**: Implement Core Data stack, create seed data for testing
