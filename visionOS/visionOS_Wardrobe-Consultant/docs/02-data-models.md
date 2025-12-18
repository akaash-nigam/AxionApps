# Data Models & Database Schema Design

## Document Overview

**Version**: 1.0
**Last Updated**: 2025-11-24
**Status**: Draft

## 1. Executive Summary

This document defines the data models and database schemas for Wardrobe Consultant. The application uses Core Data for local persistence with CloudKit for cross-device synchronization. The schema is designed to support efficient querying, scalability to 2,000+ wardrobe items, and privacy-first data storage.

## 2. Data Modeling Principles

### 2.1 Design Goals

- **Performance**: Fast queries for outfit generation (< 500ms)
- **Scalability**: Support 2,000+ wardrobe items per user
- **Privacy**: Sensitive data (measurements) isolated and encrypted
- **Sync-Ready**: CloudKit-compatible schema design
- **Extensibility**: Easy to add new attributes without breaking changes

### 2.2 Naming Conventions

- **Entities**: PascalCase, singular (e.g., `WardrobeItem`, not `WardrobeItems`)
- **Attributes**: camelCase (e.g., `purchaseDate`, `lastWornDate`)
- **Relationships**: camelCase, named by role (e.g., `outfits`, `items`)
- **Enums**: PascalCase with prefix (e.g., `ClothingCategory.shirt`)

### 2.3 Core Data + CloudKit Strategy

- **Local**: Core Data (SQLite) for full offline support
- **Sync**: CloudKit Private Database for user data sync
- **Conflict Resolution**: Last-write-wins for most entities
- **Large Assets**: Photos stored as CloudKit CKAssets

## 3. Core Data Entity Schemas

### 3.1 WardrobeItem

**Purpose**: Represents a single clothing item in the user's wardrobe.

```swift
@objc(WardrobeItem)
public class WardrobeItem: NSManagedObject {
    // MARK: - Identity
    @NSManaged public var id: UUID
    @NSManaged public var createdAt: Date
    @NSManaged public var updatedAt: Date

    // MARK: - Basic Info
    @NSManaged public var name: String?
    @NSManaged public var category: String // ClothingCategory enum raw value
    @NSManaged public var subcategory: String?
    @NSManaged public var brand: String?
    @NSManaged public var size: String?

    // MARK: - Visual Attributes
    @NSManaged public var primaryColor: String // Hex color
    @NSManaged public var secondaryColor: String? // Optional accent color
    @NSManaged public var pattern: String? // ClothingPattern enum raw value
    @NSManaged public var fabric: String? // FabricType enum raw value

    // MARK: - Photos & 3D
    @NSManaged public var photoData: Data? // Compressed HEIC
    @NSManaged public var thumbnailData: Data? // Small preview
    @NSManaged public var modelURL: URL? // Optional 3D model (USDZ)

    // MARK: - Purchase Info
    @NSManaged public var purchaseDate: Date?
    @NSManaged public var purchasePrice: Decimal?
    @NSManaged public var retailerName: String?
    @NSManaged public var productURL: URL?

    // MARK: - Usage Tracking
    @NSManaged public var timesWorn: Int32
    @NSManaged public var lastWornDate: Date?
    @NSManaged public var firstWornDate: Date?

    // MARK: - Organization
    @NSManaged public var season: String? // Season enum raw value
    @NSManaged public var occasion: String? // OccasionType enum raw value
    @NSManaged public var tags: Set<String>? // Custom tags
    @NSManaged public var isFavorite: Bool

    // MARK: - Condition
    @NSManaged public var condition: String // ItemCondition enum raw value
    @NSManaged public var needsRepair: Bool
    @NSManaged public var notes: String?

    // MARK: - Relationships
    @NSManaged public var outfits: Set<Outfit>?
    @NSManaged public var wearEvents: Set<WearEvent>?

    // MARK: - CloudKit Sync
    @NSManaged public var cloudKitRecordID: String?
    @NSManaged public var needsSync: Bool
}
```

**Indexes**:
- `category` (frequent filtering)
- `lastWornDate` (sorting for analytics)
- `isFavorite` (quick access)
- `primaryColor` (color-based filtering)

**Validation Rules**:
- `id`: Required, unique
- `category`: Required, must be valid ClothingCategory
- `primaryColor`: Required, must be valid hex color
- `timesWorn`: >= 0
- `condition`: Required, must be valid ItemCondition

### 3.2 Outfit

**Purpose**: Represents a combination of wardrobe items that form a complete outfit.

```swift
@objc(Outfit)
public class Outfit: NSManagedObject {
    // MARK: - Identity
    @NSManaged public var id: UUID
    @NSManaged public var createdAt: Date
    @NSManaged public var updatedAt: Date

    // MARK: - Basic Info
    @NSManaged public var name: String?
    @NSManaged public var occasionType: String // OccasionType enum raw value

    // MARK: - Context
    @NSManaged public var season: String? // Season enum raw value
    @NSManaged public var weatherCondition: String? // WeatherCondition enum
    @NSManaged public var temperatureMin: Int16 // Fahrenheit
    @NSManaged public var temperatureMax: Int16

    // MARK: - Style
    @NSManaged public var styleType: String? // StyleType enum raw value
    @NSManaged public var formalityLevel: Int16 // 1-10 scale

    // MARK: - Usage
    @NSManaged public var timesWorn: Int32
    @NSManaged public var lastWornDate: Date?
    @NSManaged public var isFavorite: Bool

    // MARK: - AI Generated
    @NSManaged public var isAIGenerated: Bool
    @NSManaged public var confidenceScore: Float // 0.0-1.0

    // MARK: - Relationships
    @NSManaged public var items: Set<WardrobeItem>
    @NSManaged public var wearEvents: Set<WearEvent>?
    @NSManaged public var associatedEvent: CalendarEvent?

    // MARK: - CloudKit Sync
    @NSManaged public var cloudKitRecordID: String?
    @NSManaged public var needsSync: Bool
}
```

**Indexes**:
- `occasionType` (filtering by occasion)
- `lastWornDate` (recent outfits)
- `isFavorite` (quick access)

**Validation Rules**:
- `id`: Required, unique
- `items`: Must contain at least 1 item
- `occasionType`: Required
- `temperatureMin` <= `temperatureMax`
- `formalityLevel`: 1-10
- `confidenceScore`: 0.0-1.0

### 3.3 WearEvent

**Purpose**: Records when an outfit or individual item was worn.

```swift
@objc(WearEvent)
public class WearEvent: NSManagedObject {
    // MARK: - Identity
    @NSManaged public var id: UUID
    @NSManaged public var wornDate: Date

    // MARK: - Context
    @NSManaged public var location: String?
    @NSManaged public var weatherCondition: String?
    @NSManaged public var temperature: Int16
    @NSManaged public var eventType: String? // OccasionType

    // MARK: - User Feedback
    @NSManaged public var userRating: Int16? // 1-5 stars
    @NSManaged public var notes: String?
    @NSManaged public var photoURL: URL? // Optional photo from the day

    // MARK: - Relationships
    @NSManaged public var outfit: Outfit?
    @NSManaged public var items: Set<WardrobeItem>?

    // MARK: - CloudKit Sync
    @NSManaged public var cloudKitRecordID: String?
    @NSManaged public var needsSync: Bool
}
```

**Indexes**:
- `wornDate` (chronological queries)
- `eventType` (analytics by occasion)

**Validation Rules**:
- `id`: Required, unique
- `wornDate`: Required, cannot be in future
- `userRating`: 1-5 if present
- Must have either `outfit` or `items` (not both empty)

### 3.4 UserProfile

**Purpose**: Stores user preferences, body measurements, and style profile.

```swift
@objc(UserProfile)
public class UserProfile: NSManagedObject {
    // MARK: - Identity
    @NSManaged public var id: UUID
    @NSManaged public var createdAt: Date
    @NSManaged public var updatedAt: Date

    // MARK: - Body Measurements (Encrypted)
    @NSManaged public var height: Int16? // Inches
    @NSManaged public var weight: Int16? // Pounds
    @NSManaged public var chest: Float? // Inches
    @NSManaged public var waist: Float?
    @NSManaged public var hips: Float?
    @NSManaged public var inseam: Float?
    @NSManaged public var shoulderWidth: Float?

    // MARK: - Size Preferences
    @NSManaged public var topSize: String?
    @NSManaged public var bottomSize: String?
    @NSManaged public var dressSize: String?
    @NSManaged public var shoeSize: String?
    @NSManaged public var fitPreference: String // FitPreference enum

    // MARK: - Style Profile
    @NSManaged public var primaryStyle: String // StyleType enum
    @NSManaged public var secondaryStyle: String?
    @NSManaged public var favoriteColors: [String]? // Array of hex colors
    @NSManaged public var avoidColors: [String]?

    // MARK: - Preferences
    @NSManaged public var comfortLevel: String // ComfortLevel enum
    @NSManaged public var budgetRange: String // BudgetRange enum
    @NSManaged public var sustainabilityPreference: Bool

    // MARK: - Style Icons (Inspiration)
    @NSManaged public var styleIcons: [String]? // Names or URLs

    // MARK: - Settings
    @NSManaged public var temperatureUnit: String // "F" or "C"
    @NSManaged public var enableWeatherIntegration: Bool
    @NSManaged public var enableCalendarIntegration: Bool
    @NSManaged public var enableNotifications: Bool

    // MARK: - CloudKit Sync
    @NSManaged public var cloudKitRecordID: String?
    @NSManaged public var needsSync: Bool
}
```

**Storage**: Body measurements stored in Keychain for extra security, reference stored in Core Data.

**Validation Rules**:
- `id`: Required, unique (typically one per device)
- `height`, `weight`: Positive if present
- `fitPreference`: Required

### 3.5 CalendarEvent

**Purpose**: Cached calendar events with extracted dress code information.

```swift
@objc(CalendarEvent)
public class CalendarEvent: NSManagedObject {
    // MARK: - Identity
    @NSManaged public var id: String // From EventKit
    @NSManaged public var fetchedAt: Date

    // MARK: - Event Info
    @NSManaged public var title: String
    @NSManaged public var startDate: Date
    @NSManaged public var endDate: Date
    @NSManaged public var location: String?
    @NSManaged public var notes: String?

    // MARK: - Dress Code Analysis
    @NSManaged public var extractedDressCode: String? // DressCode enum
    @NSManaged public var formalityLevel: Int16 // 1-10
    @NSManaged public var dressCodeConfidence: Float // 0.0-1.0

    // MARK: - Outfit Association
    @NSManaged public var suggestedOutfits: Set<Outfit>?
    @NSManaged public var selectedOutfit: Outfit?

    // MARK: - Reminder
    @NSManaged public var reminderSent: Bool
}
```

**Indexes**:
- `startDate` (chronological queries)
- `fetchedAt` (cache invalidation)

**Validation Rules**:
- `id`: Required, unique
- `startDate` < `endDate`
- `formalityLevel`: 1-10
- Cache TTL: 15 minutes

### 3.6 WeatherCache

**Purpose**: Cached weather data for outfit suggestions.

```swift
@objc(WeatherCache)
public class WeatherCache: NSManagedObject {
    // MARK: - Identity
    @NSManaged public var id: UUID
    @NSManaged public var fetchedAt: Date

    // MARK: - Location
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var locationName: String

    // MARK: - Current Weather
    @NSManaged public var temperature: Int16 // Fahrenheit
    @NSManaged public var feelsLike: Int16
    @NSManaged public var condition: String // WeatherCondition enum
    @NSManaged public var humidity: Int16 // Percentage
    @NSManaged public var windSpeed: Int16 // MPH
    @NSManaged public var precipitationChance: Int16 // Percentage

    // MARK: - Forecast
    @NSManaged public var forecastData: Data? // JSON for 7-day forecast
}
```

**Indexes**:
- `fetchedAt` (cache invalidation)

**Validation Rules**:
- Cache TTL: 1 hour
- Automatically purge entries older than 24 hours

### 3.7 ShoppingWishlist

**Purpose**: Items user wants to buy, with try-on previews.

```swift
@objc(ShoppingWishlistItem)
public class ShoppingWishlistItem: NSManagedObject {
    // MARK: - Identity
    @NSManaged public var id: UUID
    @NSManaged public var addedAt: Date

    // MARK: - Product Info
    @NSManaged public var productName: String
    @NSManaged public var brand: String?
    @NSManaged public var price: Decimal
    @NSManaged public var productURL: URL
    @NSManaged public var imageURL: URL?

    // MARK: - Try-On
    @NSManaged public var triedOnVirtually: Bool
    @NSManaged public var tryOnPhotoData: Data? // Screenshot of virtual try-on

    // MARK: - Recommendations
    @NSManaged public var recommendedSize: String?
    @NSManaged public var sizeConfidence: Float
    @NSManaged public var matchesWardrobe: Bool // Has complementary items

    // MARK: - Price Tracking
    @NSManaged public var originalPrice: Decimal?
    @NSManaged public var isPriceDropped: Bool
    @NSManaged public var lastPriceCheck: Date?

    // MARK: - Status
    @NSManaged public var isPurchased: Bool
    @NSManaged public var purchasedDate: Date?
}
```

**Indexes**:
- `addedAt` (chronological)
- `isPurchased` (filtering)

## 4. Enumerations

### 4.1 ClothingCategory

```swift
enum ClothingCategory: String, CaseIterable, Codable {
    case shirt
    case blouse
    case tshirt
    case sweater
    case hoodie
    case jacket
    case coat
    case blazer
    case cardigan

    case pants
    case jeans
    case shorts
    case skirt
    case leggings

    case dress
    case jumpsuit

    case shoes
    case boots
    case sneakers
    case sandals
    case heels

    case accessories
    case scarf
    case hat
    case belt
    case jewelry
    case bag

    var displayName: String {
        // User-friendly name
    }

    var parentCategory: ParentCategory {
        // tops, bottoms, dresses, shoes, accessories
    }
}
```

### 4.2 OccasionType

```swift
enum OccasionType: String, CaseIterable, Codable {
    case work
    case workPresentation
    case workCasual
    case casual
    case dateNight
    case brunch
    case party
    case wedding
    case formalEvent
    case interview
    case gym
    case athletic
    case loungewear
    case travel
    case outdoor
    case beach

    var formalityLevel: Int {
        // Return 1-10 based on occasion
    }
}
```

### 4.3 Season

```swift
enum Season: String, CaseIterable, Codable {
    case spring
    case summer
    case fall
    case winter
    case allSeason

    static func current() -> Season {
        // Determine based on current month
    }
}
```

### 4.4 StyleType

```swift
enum StyleType: String, CaseIterable, Codable {
    case minimalist
    case classic
    case trendy
    case edgy
    case bohemian
    case preppy
    case streetwear
    case elegant
    case sporty
    case vintage

    var description: String {
        // User-friendly description
    }
}
```

### 4.5 DressCode

```swift
enum DressCode: String, CaseIterable, Codable {
    case whiteTie
    case blackTie
    case blackTieOptional
    case cocktailAttire
    case businessProfessional
    case businessCasual
    case smartCasual
    case casual

    var formalityLevel: Int {
        // 1-10 scale
    }

    var description: String {
        // Detailed explanation
    }
}
```

### 4.6 WeatherCondition

```swift
enum WeatherCondition: String, CaseIterable, Codable {
    case clear
    case partlyCloudy
    case cloudy
    case rainy
    case snowy
    case stormy
    case windy
    case foggy

    var icon: String {
        // SF Symbol name
    }
}
```

### 4.7 FabricType

```swift
enum FabricType: String, CaseIterable, Codable {
    case cotton
    case polyester
    case wool
    case silk
    case linen
    case denim
    case leather
    case cashmere
    case nylon
    case rayon
    case blend

    var breathability: Float {
        // 0.0-1.0 scale
    }

    var warmth: Float {
        // 0.0-1.0 scale
    }
}
```

### 4.8 ItemCondition

```swift
enum ItemCondition: String, CaseIterable, Codable {
    case new
    case excellent
    case good
    case fair
    case worn
    case damaged

    var canWear: Bool {
        self != .damaged
    }
}
```

## 5. Entity Relationships

### 5.1 Relationship Diagram

```
UserProfile (1) ──────────────────────────────────────┐
                                                       │
WardrobeItem (N) ──┬── Outfit (M) ─────────────────┐ │
                   │                                 │ │
                   └── WearEvent (N) ─┬─────────────┤ │
                                      │             │ │
Outfit (1) ────────────────────────────┤             │ │
                                      │             │ │
CalendarEvent (1) ─────── Outfit (M) ─┘             │ │
                                                     │ │
ShoppingWishlistItem (N) ────────────────────────────┘ │
                                                       │
WeatherCache (N) ───────────────────────────────────────┘
```

### 5.2 Relationship Details

**WardrobeItem ↔ Outfit** (Many-to-Many)
- A wardrobe item can be part of multiple outfits
- An outfit consists of multiple wardrobe items
- Delete rule: Nullify (removing item doesn't delete outfit)

**WardrobeItem ↔ WearEvent** (Many-to-Many)
- Track individual items worn (even without outfit)
- Delete rule: Cascade (deleting item removes its wear events)

**Outfit ↔ WearEvent** (One-to-Many)
- An outfit can be worn multiple times
- Delete rule: Cascade

**CalendarEvent ↔ Outfit** (One-to-Many)
- An event can have multiple suggested outfits
- One selected outfit
- Delete rule: Nullify (deleting event keeps outfit)

## 6. CloudKit Schema

### 6.1 Record Types

**WardrobeItem** (CKRecord)
- Fields: All non-binary attributes
- Asset: `photo` (CKAsset for compressed image)
- Asset: `thumbnail` (CKAsset for small preview)
- Reference: None (standalone records)

**Outfit** (CKRecord)
- Fields: All attributes
- References: Array of WardrobeItem record IDs
- Delete action: Cascade

**WearEvent** (CKRecord)
- Fields: All attributes
- References: Outfit record ID, WardrobeItem record IDs
- Delete action: Nullify

**UserProfile** (CKRecord)
- Fields: All non-sensitive attributes
- Note: Body measurements NOT synced (privacy)
- Single record per user

### 6.2 Sync Strategy

**Push to Cloud**:
- On wardrobe item create/update/delete
- On outfit create/update
- On wear event logged
- Debounced: 5 seconds after last change

**Pull from Cloud**:
- On app launch (if online)
- Every 15 minutes (background)
- On pull-to-refresh

**Conflict Resolution**:
- Last-write-wins (based on `updatedAt`)
- User notified of conflicts for favorites

## 7. Indexes & Query Optimization

### 7.1 Core Data Indexes

```swift
// In .xcdatamodeld file

// WardrobeItem indexes
- category (hash index)
- primaryColor (hash index)
- lastWornDate (btree index, descending)
- isFavorite (hash index)
- season (hash index)

// Outfit indexes
- occasionType (hash index)
- lastWornDate (btree index, descending)
- isFavorite (hash index)

// WearEvent indexes
- wornDate (btree index, descending)

// CalendarEvent indexes
- startDate (btree index, ascending)
```

### 7.2 Common Queries

**Fetch all items for outfit generation**:
```swift
let request: NSFetchRequest<WardrobeItem> = WardrobeItem.fetchRequest()
request.predicate = NSPredicate(format: "condition != %@", ItemCondition.damaged.rawValue)
request.sortDescriptors = [NSSortDescriptor(key: "lastWornDate", ascending: true)]
request.fetchBatchSize = 50
request.returnsObjectsAsFaults = false
```

**Fetch recent outfits**:
```swift
let request: NSFetchRequest<Outfit> = Outfit.fetchRequest()
request.predicate = NSPredicate(format: "lastWornDate != nil")
request.sortDescriptors = [NSSortDescriptor(key: "lastWornDate", ascending: false)]
request.fetchLimit = 20
```

**Fetch items by category and season**:
```swift
let request: NSFetchRequest<WardrobeItem> = WardrobeItem.fetchRequest()
request.predicate = NSPredicate(
    format: "category == %@ AND (season == %@ OR season == %@)",
    ClothingCategory.sweater.rawValue,
    Season.fall.rawValue,
    Season.allSeason.rawValue
)
```

## 8. Data Migrations

### 8.1 Versioning Strategy

- Lightweight migrations for simple changes (add attribute, rename)
- Manual migrations for complex changes (relationship restructure)
- Version 1.0: Initial schema
- Version 1.1: Add `subcategory` to WardrobeItem
- Version 1.2: Add `ShoppingWishlistItem` entity

### 8.2 Migration Plan

```swift
// NSPersistentContainer with migration options
lazy var persistentContainer: NSPersistentContainer = {
    let container = NSPersistentContainer(name: "WardrobeConsultant")

    let description = container.persistentStoreDescriptions.first
    description?.shouldMigrateStoreAutomatically = true
    description?.shouldInferMappingModelAutomatically = true

    container.loadPersistentStores { description, error in
        if let error = error {
            // Handle migration error
            fatalError("Core Data migration failed: \(error)")
        }
    }

    return container
}()
```

### 8.3 Backward Compatibility

- Maintain support for N-1 schema version
- Deprecation period: 2 app versions
- Clear migration messages to user if needed

## 9. Data Privacy & Security

### 9.1 Sensitive Data Handling

**Body Measurements**:
- Stored in iOS Keychain (not Core Data)
- Never synced to CloudKit
- Encrypted at rest
- Access: Biometric authentication required

**Photos**:
- HEIC compression (70% quality)
- Core Data binary storage
- CloudKit CKAsset for sync
- Encrypted in transit

### 9.2 User Data Export

```swift
// GDPR compliance: Export all user data
func exportUserData() async throws -> Data {
    // Fetch all entities
    let items = try await wardrobeRepository.fetchAll()
    let outfits = try await outfitRepository.fetchAll()
    let events = try await wearEventRepository.fetchAll()
    let profile = try await profileRepository.fetch()

    // Convert to JSON
    let export = UserDataExport(
        profile: profile,
        wardrobeItems: items,
        outfits: outfits,
        wearEvents: events,
        exportDate: Date()
    )

    return try JSONEncoder().encode(export)
}
```

### 9.3 Data Deletion

```swift
// Delete all user data (account deletion)
func deleteAllUserData() async throws {
    // Local Core Data
    try await coreDataStack.deleteAllData()

    // CloudKit records
    try await cloudKitSync.deleteAllRecords()

    // Keychain
    try keychainService.deleteAllMeasurements()

    // Cached files
    try fileManager.clearCache()
}
```

## 10. Sample Data & Testing

### 10.1 Test Data Seeding

```swift
func seedTestWardrobe() {
    let context = persistentContainer.viewContext

    // Create test items
    let items = [
        ("Blue Oxford Shirt", ClothingCategory.shirt, "#4169E1"),
        ("Black Slim Jeans", ClothingCategory.jeans, "#000000"),
        ("Gray Wool Blazer", ClothingCategory.blazer, "#808080"),
        // ... more items
    ]

    for (name, category, color) in items {
        let item = WardrobeItem(context: context)
        item.id = UUID()
        item.name = name
        item.category = category.rawValue
        item.primaryColor = color
        item.createdAt = Date()
        item.updatedAt = Date()
        item.condition = ItemCondition.good.rawValue
        item.timesWorn = Int32.random(in: 0...20)
    }

    try? context.save()
}
```

## 11. Performance Considerations

### 11.1 Batch Operations

- Use batch fetch requests for large datasets
- Batch size: 50 items
- Enable prefetching for relationships

### 11.2 Faulting

- Keep objects as faults when not needed
- Prefetch relationships when iterating
- Use `returnsObjectsAsFaults = false` sparingly

### 11.3 Background Contexts

```swift
// Heavy writes on background context
func addMultipleItems(_ items: [WardrobeItemDTO]) async throws {
    let context = persistentContainer.newBackgroundContext()
    context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy

    try await context.perform {
        for itemDTO in items {
            let item = WardrobeItem(context: context)
            // ... populate item
        }
        try context.save()
    }
}
```

## 12. Next Steps

- ✅ Schema defined
- ⬜ Generate Core Data model file (.xcdatamodeld)
- ⬜ Create entity extensions (computed properties, convenience methods)
- ⬜ Implement repository protocols
- ⬜ Setup CloudKit schema in CloudKit Dashboard
- ⬜ Write unit tests for data models

---

**Document Status**: Draft - Ready for Review
**Next Document**: API Design & Integration Specifications
