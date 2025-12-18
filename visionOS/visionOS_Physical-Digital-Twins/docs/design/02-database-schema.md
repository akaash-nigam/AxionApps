# Database Schema & Data Model Design

## Overview

This document defines the data models, database schema, and persistence strategy for Physical-Digital Twins. The app uses Core Data for local storage with optional CloudKit synchronization.

## Data Architecture

### Storage Strategy

```
Local Storage (Core Data)
    ↕ (Bidirectional Sync)
Cloud Storage (CloudKit Private Database)
```

**Principles**:
- **Local-First**: All data accessible offline
- **Optional Sync**: Users can opt into cloud sync
- **Conflict Resolution**: Last-write-wins with manual merge for critical data
- **Encryption**: CloudKit encryption at rest, FileProtection for local

## Core Data Schema

### Entity Relationship Diagram

```
┌─────────────────────┐
│  DigitalTwinEntity  │◄──────────────┐
├─────────────────────┤               │
│ id: UUID            │               │
│ objectType: String  │               │
│ createdAt: Date     │               │
│ updatedAt: Date     │         ┌─────┴──────────────┐
│ typeSpecificData    │         │  InventoryItem     │
│ recognitionData     │         ├────────────────────┤
│ cloudKitRecordID    │         │ id: UUID           │
│                     │         │ digitalTwinID: UUID│
└─────────────────────┘         │ locationID: UUID?  │
         △                      │ purchaseDate: Date?│
         │                      │ purchasePrice: $?  │
         │                      │ currentValue: $?   │
         │                      │ condition: String  │
         │                      │ notes: String?     │
         │                      │ photos: [String]   │
         │                      │ isLent: Bool       │
         │                      │ lentTo: String?    │
         │                      │ lentDate: Date?    │
    Inheritance                 └────────────────────┘
         │                               │
    ┌────┴────┬──────────┬───────┐     │
    │         │          │       │     │
┌───┴───┐┌───┴───┐┌────┴───┐┌──┴──┐  │
│ Book  ││ Food  ││Furniture││Elect││  │
│ Twin  ││ Twin  ││  Twin   ││ronic││  │
├───────┤├───────┤├─────────┤├─────┤  │
│title  ││product││category ││model│  │
│author ││barcode││brand    ││specs│  │
│isbn   ││expiry ││assembly ││power│  │
│rating ││opened ││warranty ││etc. │  │
└───────┘└───────┘└─────────┘└─────┘  │
                                        │
         ┌──────────────────────────────┘
         │
         ▼
┌────────────────────┐       ┌─────────────────┐
│   LocationEntity   │       │ RecognitionLog  │
├────────────────────┤       ├─────────────────┤
│ id: UUID           │       │ id: UUID        │
│ name: String       │       │ timestamp: Date │
│ type: String       │       │ imagePath: String│
│ parentLocation: ^  │       │ confidence: Float│
│ items: [Item]      │       │ result: String  │
└────────────────────┘       └─────────────────┘
```

### Core Entities

#### 1. DigitalTwinEntity (Abstract Base)

```swift
@Model
class DigitalTwinEntity {
    @Attribute(.unique) var id: UUID
    var objectType: ObjectCategory
    var createdAt: Date
    var updatedAt: Date

    // Recognition metadata
    var recognitionMethod: RecognitionMethod // .barcode, .vision, .manual
    var recognitionConfidence: Float?
    var primaryImagePath: String?

    // CloudKit sync
    var cloudKitRecordID: String?
    var cloudKitChangeTag: String?
    var needsSync: Bool

    // Relationships
    @Relationship(deleteRule: .cascade) var inventoryItem: InventoryItemEntity?

    init(id: UUID = UUID(), objectType: ObjectCategory) {
        self.id = id
        self.objectType = objectType
        self.createdAt = Date()
        self.updatedAt = Date()
        self.needsSync = true
    }
}

enum ObjectCategory: String, Codable {
    case book, food, furniture, electronics
    case clothing, games, tools, plants
    case unknown
}

enum RecognitionMethod: String, Codable {
    case barcode        // Scanned barcode/QR
    case vision         // Visual recognition
    case manual         // User entered
    case imageSimilarity // Visual search
}
```

#### 2. BookTwinEntity

```swift
@Model
class BookTwinEntity: DigitalTwinEntity {
    var title: String
    var author: String
    var isbn: String?
    var isbn13: String?

    // Metadata
    var publisher: String?
    var publishDate: Date?
    var pageCount: Int?
    var language: String?
    var genre: [String]

    // Ratings & Reviews
    var averageRating: Double?
    var ratingsCount: Int?
    var goodreadsID: String?

    // Reading Status
    var readingStatus: ReadingStatus
    var currentPage: Int?
    var startedReading: Date?
    var finishedReading: Date?

    // Personal
    var personalRating: Int? // 1-5 stars
    var notes: String?
    var isFavorite: Bool
    var tags: [String]

    init(title: String, author: String) {
        self.title = title
        self.author = author
        self.genre = []
        self.tags = []
        self.readingStatus = .unread
        self.isFavorite = false
        super.init(objectType: .book)
    }
}

enum ReadingStatus: String, Codable {
    case unread, reading, finished, dnf // did not finish
}
```

#### 3. FoodTwinEntity

```swift
@Model
class FoodTwinEntity: DigitalTwinEntity {
    var productName: String
    var brand: String?
    var barcode: String?

    // Expiration
    var expirationDate: Date?
    var openedDate: Date?
    var estimatedShelfLife: Int? // days from opening

    // Storage
    var storageLocation: String? // "Fridge", "Pantry", "Freezer"
    var storageInstructions: String?

    // Nutrition
    var servingSize: String?
    var calories: Int?
    var protein: Double?
    var carbs: Double?
    var fat: Double?
    var sugar: Double?
    var sodium: Double?

    // Dietary
    var allergens: [String]
    var isVegan: Bool?
    var isGluten Free: Bool?
    var isOrganic: Bool?

    // Status
    var freshnessStatus: FreshnessStatus
    var quantity: Int // Number of items

    init(productName: String) {
        self.productName = productName
        self.allergens = []
        self.freshnessStatus = .fresh
        self.quantity = 1
        super.init(objectType: .food)
    }
}

enum FreshnessStatus: String, Codable {
    case fresh          // > 7 days or no expiration
    case useSoon        // 3-7 days
    case useToday       // 1-2 days
    case expired        // Past expiration
}
```

#### 4. FurnitureTwinEntity

```swift
@Model
class FurnitureTwinEntity: DigitalTwinEntity {
    var name: String
    var brand: String?
    var category: FurnitureCategory
    var model: String?
    var sku: String?

    // Purchase
    var purchaseStore: String?
    var purchaseURL: String?

    // Assembly
    var requiresAssembly: Bool
    var assemblyInstructionsURL: String?
    var assemblyVideoURL: String?
    var assemblyCompleted: Bool
    var assemblyDate: Date?
    var assemblyTimeMinutes: Int?

    // Specifications
    var dimensions: Dimensions?
    var weight: Double? // kg
    var material: String?
    var color: String?

    // Maintenance
    var careInstructions: String?
    var lastCleaned: Date?
    var maintenanceSchedule: String?

    // Warranty
    var warrantyExpires: Date?
    var warrantyDocument: String?

    init(name: String, category: FurnitureCategory) {
        self.name = name
        self.category = category
        self.requiresAssembly = false
        self.assemblyCompleted = true
        super.init(objectType: .furniture)
    }
}

enum FurnitureCategory: String, Codable {
    case seating, table, storage, bed, desk, outdoor, other
}

struct Dimensions: Codable {
    var width: Double  // cm
    var height: Double // cm
    var depth: Double  // cm
}
```

#### 5. ElectronicsTwinEntity

```swift
@Model
class ElectronicsTwinEntity: DigitalTwinEntity {
    var name: String
    var brand: String
    var model: String
    var serialNumber: String?

    // Category
    var category: ElectronicsCategory

    // Specifications
    var specifications: [String: String] // Key-value specs
    var powerRating: String?
    var connectivity: [String] // ["WiFi", "Bluetooth", "USB-C"]

    // Documentation
    var manualURL: String?
    var manualPDFPath: String?
    var firmwareVersion: String?
    var lastFirmwareCheck: Date?

    // Warranty & Support
    var warrantyExpires: Date?
    var supportURL: String?
    var troubleshootingURL: String?

    // Maintenance
    var lastMaintenance: Date?
    var maintenanceSchedule: String?

    // Disposal
    var recyclingInstructions: String?
    var containsBattery: Bool

    init(name: String, brand: String, model: String, category: ElectronicsCategory) {
        self.name = name
        self.brand = brand
        self.model = model
        self.category = category
        self.connectivity = []
        self.specifications = [:]
        self.containsBattery = false
        super.init(objectType: .electronics)
    }
}

enum ElectronicsCategory: String, Codable {
    case smartphone, tablet, laptop, tv, camera
    case audio, smartHome, gaming, appliance, other
}
```

#### 6. InventoryItemEntity

```swift
@Model
class InventoryItemEntity {
    @Attribute(.unique) var id: UUID

    // Relationship to digital twin
    @Relationship var digitalTwin: DigitalTwinEntity

    // Location
    @Relationship var location: LocationEntity?
    var specificLocation: String? // "Top shelf", "Drawer 2"

    // Financial
    var purchaseDate: Date?
    var purchasePrice: Decimal?
    var purchaseStore: String?
    var currentValue: Decimal?
    var depreciationRate: Double? // Annual %

    // Condition
    var condition: ItemCondition
    var conditionNotes: String?

    // Photos
    var photosPaths: [String] // File paths in cache

    // Lending
    var isLent: Bool
    var lentTo: String?
    var lentDate: Date?
    var expectedReturnDate: Date?

    // User notes
    var notes: String?
    var tags: [String]
    var isFavorite: Bool

    // Sustainability
    var carbonFootprint: Double? // kg CO2
    var recyclabilityScore: Int? // 0-100
    var sustainabilityNotes: String?

    // CloudKit
    var cloudKitRecordID: String?
    var needsSync: Bool

    init(digitalTwin: DigitalTwinEntity) {
        self.id = UUID()
        self.digitalTwin = digitalTwin
        self.condition = .good
        self.photosPaths = []
        self.tags = []
        self.isFavorite = false
        self.isLent = false
        self.needsSync = true
    }
}

enum ItemCondition: String, Codable {
    case new, excellent, good, fair, poor, broken
}
```

#### 7. LocationEntity

```swift
@Model
class LocationEntity {
    @Attribute(.unique) var id: UUID
    var name: String
    var type: LocationType

    // Hierarchy
    @Relationship var parentLocation: LocationEntity?
    @Relationship(deleteRule: .cascade) var subLocations: [LocationEntity]

    // Items at this location
    @Relationship(inverse: \InventoryItemEntity.location)
    var items: [InventoryItemEntity]

    // Metadata
    var createdAt: Date
    var sortOrder: Int

    init(name: String, type: LocationType) {
        self.id = UUID()
        self.name = name
        self.type = type
        self.subLocations = []
        self.items = []
        self.createdAt = Date()
        self.sortOrder = 0
    }
}

enum LocationType: String, Codable {
    case home, room, furniture, container, other
}

// Example hierarchy:
// Home → Kitchen → Pantry → Top Shelf
// Home → Bedroom → Closet → Drawer 1
```

#### 8. RecognitionLogEntity

```swift
@Model
class RecognitionLogEntity {
    @Attribute(.unique) var id: UUID
    var timestamp: Date

    // Input
    var imagePath: String?
    var barcode: String?

    // Result
    var recognitionMethod: RecognitionMethod
    var confidence: Float?
    var detectedObjectType: ObjectCategory?
    var resultingTwinID: UUID?

    // Success
    var wasSuccessful: Bool
    var errorMessage: String?

    // Performance
    var processingTimeMs: Int

    init(method: RecognitionMethod, successful: Bool) {
        self.id = UUID()
        self.timestamp = Date()
        self.recognitionMethod = method
        self.wasSuccessful = successful
        self.processingTimeMs = 0
    }
}
```

#### 9. NotificationScheduleEntity

```swift
@Model
class NotificationScheduleEntity {
    @Attribute(.unique) var id: UUID
    var notificationID: String // System notification ID

    // What to notify about
    var twinID: UUID
    var notificationType: NotificationType

    // When
    var scheduledDate: Date
    var wasSent: Bool
    var sentDate: Date?

    init(twinID: UUID, type: NotificationType, scheduledDate: Date) {
        self.id = UUID()
        self.notificationID = UUID().uuidString
        self.twinID = twinID
        self.notificationType = type
        self.scheduledDate = scheduledDate
        self.wasSent = false
    }
}

enum NotificationType: String, Codable {
    case expirationWarning3Days
    case expirationWarning1Day
    case expired
    case warrantyExpiring
    case maintenanceDue
    case recallAlert
}
```

### Core Data Configuration

#### Persistent Container Setup

```swift
class PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentCloudKitContainer

    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "PhysicalDigitalTwins")

        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        } else {
            // Configure CloudKit
            let description = container.persistentStoreDescriptions.first!
            description.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(
                containerIdentifier: "iCloud.com.yourcompany.physicaldigitaltwins"
            )

            // Set file protection
            description.setOption(
                FileProtectionType.complete as NSObject,
                forKey: NSPersistentStoreFileProtectionKey
            )
        }

        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Unable to load persistent stores: \(error)")
            }
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
}
```

#### Indices for Performance

```swift
// In Core Data model editor, add indices:
// DigitalTwinEntity:
//   - objectType (common query)
//   - updatedAt (sorting, recent items)
//   - needsSync (sync queries)

// InventoryItemEntity:
//   - purchaseDate (sorting)
//   - location (filtering by location)
//   - tags (searching by tag)

// FoodTwinEntity:
//   - expirationDate (frequent expiration queries)
//   - freshnessStatus (dashboard queries)

// NotificationScheduleEntity:
//   - scheduledDate (upcoming notifications)
//   - wasSent (pending notifications)
```

## CloudKit Schema

### Record Types

#### CKDigitalTwin

```swift
// CloudKit Record Type: "DigitalTwin"
{
    recordType: "DigitalTwin",
    fields: {
        twinID: String,              // UUID
        objectType: String,          // ObjectCategory
        createdAt: Date,
        updatedAt: Date,
        recognitionMethod: String,
        recognitionConfidence: Double,
        primaryImage: CKAsset,       // Optional

        // Type-specific data as JSON
        typeSpecificData: String,    // JSON encoded twin data

        // References
        inventoryItemID: String?,    // Reference to inventory item
    }
}
```

#### CKInventoryItem

```swift
// CloudKit Record Type: "InventoryItem"
{
    recordType: "InventoryItem",
    fields: {
        itemID: String,              // UUID
        digitalTwinID: String,       // Reference
        locationName: String?,
        specificLocation: String?,

        purchaseDate: Date?,
        purchasePrice: Double?,
        currentValue: Double?,

        condition: String,
        isLent: Bool,
        lentTo: String?,

        notes: String?,
        tags: [String],

        photos: [CKAsset],           // Item photos

        carbonFootprint: Double?,
        recyclabilityScore: Int?,
    }
}
```

#### CKUserSettings

```swift
// CloudKit Record Type: "UserSettings"
{
    recordType: "UserSettings",
    fields: {
        enableCloudSync: Bool,
        enableNotifications: Bool,
        expirationWarningDays: Int,
        defaultCurrency: String,
        measurementSystem: String,   // "metric" or "imperial"

        // Privacy
        analyticsEnabled: Bool,
    }
}
```

### Sync Strategy

#### Conflict Resolution

```swift
struct SyncConflict {
    let localRecord: any DigitalTwin
    let cloudRecord: CKRecord
    let conflictField: String
}

enum ConflictResolution {
    case useLocal
    case useCloud
    case mergeManual
}

class SyncConflictResolver {
    func resolve(_ conflict: SyncConflict) -> ConflictResolution {
        // For most fields: last-write-wins based on updatedAt
        if conflict.localRecord.updatedAt > conflict.cloudRecord.modificationDate {
            return .useLocal
        }

        // For critical fields (e.g., notes, personal ratings): prompt user
        if isCriticalField(conflict.conflictField) {
            return .mergeManual
        }

        return .useCloud
    }

    private func isCriticalField(_ field: String) -> Bool {
        ["notes", "personalRating", "readingStatus"].contains(field)
    }
}
```

#### Sync Flow

```
1. Fetch changes from CloudKit (CKFetchRecordZoneChangesOperation)
2. Compare with local Core Data
3. Resolve conflicts
4. Apply remote changes to Core Data
5. Push local changes to CloudKit (CKModifyRecordsOperation)
6. Update local cloudKitChangeTag
```

## Data Access Layer

### Repository Pattern

```swift
protocol DigitalTwinRepository {
    func save(_ twin: any DigitalTwin) async throws
    func fetch(id: UUID) async throws -> (any DigitalTwin)?
    func fetchAll(category: ObjectCategory?) async throws -> [any DigitalTwin]
    func search(query: String) async throws -> [any DigitalTwin]
    func delete(id: UUID) async throws
}

class CoreDataDigitalTwinRepository: DigitalTwinRepository {
    private let context: NSManagedObjectContext

    func save(_ twin: any DigitalTwin) async throws {
        let entity = try entity(from: twin)
        try context.save()
    }

    func fetchAll(category: ObjectCategory?) async throws -> [any DigitalTwin] {
        let request = DigitalTwinEntity.fetchRequest()
        if let category {
            request.predicate = NSPredicate(format: "objectType == %@", category.rawValue)
        }
        request.sortDescriptors = [NSSortDescriptor(key: "updatedAt", ascending: false)]

        let entities = try context.fetch(request)
        return entities.compactMap { model(from: $0) }
    }

    // Convert between Swift models and Core Data entities
    private func entity(from twin: any DigitalTwin) throws -> DigitalTwinEntity { ... }
    private func model(from entity: DigitalTwinEntity) -> (any DigitalTwin)? { ... }
}
```

## Migration Strategy

### Version Management

```swift
// Core Data model versions:
// PhysicalDigitalTwins.xcdatamodeld
//   ├── PhysicalDigitalTwins v1.xcdatamodel (initial)
//   ├── PhysicalDigitalTwins v2.xcdatamodel (add sustainability fields)
//   └── PhysicalDigitalTwins v3.xcdatamodel (add notification entity)

// Lightweight migrations for:
// - Adding new attributes
// - Adding new relationships
// - Changing attribute types (compatible conversions)

// Custom migrations for:
// - Data transformations
// - Splitting/merging entities
```

### Backward Compatibility

- Maintain support for 2 previous major versions
- CloudKit schema is append-only (never remove fields)
- Use optional fields for new additions

## Data Size Estimates

### Per Twin

| Entity | Size | Notes |
|--------|------|-------|
| DigitalTwinEntity | ~500 bytes | Base entity |
| BookTwin | +300 bytes | Text fields |
| FoodTwin | +400 bytes | Nutrition data |
| InventoryItem | ~1 KB | With metadata |
| Photo (cached) | ~100 KB | Compressed WebP |

### Scalability

| Items | Estimated Size | Notes |
|-------|---------------|-------|
| 100 items | ~200 KB | Core data only |
| 500 items | ~1 MB | Typical user |
| 5,000 items | ~10 MB | Power user |
| Photos (500 items) | ~50 MB | Compressed images |

**CloudKit Limits**:
- Private database: 1 TB per user
- Asset size: 250 MB per asset
- Request size: 10 MB
- More than sufficient for typical usage

## Queries & Performance

### Common Queries

```swift
// 1. Recent items
let recentRequest = DigitalTwinEntity.fetchRequest()
recentRequest.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
recentRequest.fetchLimit = 20

// 2. Expiring food
let expiringRequest = FoodTwinEntity.fetchRequest()
let threeDaysFromNow = Calendar.current.date(byAdding: .day, value: 3, to: Date())!
expiringRequest.predicate = NSPredicate(
    format: "expirationDate != nil AND expirationDate < %@ AND expirationDate > %@",
    threeDaysFromNow as NSDate,
    Date() as NSDate
)

// 3. Items by location
let locationRequest = InventoryItemEntity.fetchRequest()
locationRequest.predicate = NSPredicate(format: "location.name == %@", "Kitchen")

// 4. Full-text search
let searchRequest = DigitalTwinEntity.fetchRequest()
// Note: Use Core Data's NSCompoundPredicate for multiple fields
```

### Fetch Request Optimization

- Use `fetchLimit` for paginated lists
- Set `propertiesToFetch` for partial objects
- Use `fetchBatchSize` for large result sets
- Prefetch relationships with `relationshipKeyPathsForPrefetching`

## Summary

This database schema provides:
- **Flexible**: Protocol-oriented twin types
- **Scalable**: Efficient indices and pagination
- **Sync-Ready**: CloudKit integration built-in
- **Offline-First**: Full functionality without network
- **Privacy-Focused**: Encrypted storage, optional sync

Next: API Integration and Computer Vision implementation.
