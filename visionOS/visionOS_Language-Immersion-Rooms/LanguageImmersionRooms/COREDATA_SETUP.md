# CoreData Model Setup Guide

## Overview

This guide walks you through creating the CoreData model file (`.xcdatamodeld`) in Xcode. The schema is fully documented in `Data/Persistence/CoreDataEntities.swift`, and this guide shows you how to create it manually in Xcode.

## Why Manual Setup?

The `.xcdatamodeld` file is a special Xcode file format that cannot be created programmatically. It must be created through Xcode's Data Model Editor.

## Setup Steps

### 1. Create the Data Model File

1. Open the project in Xcode
2. Right-click on `LanguageImmersionRooms/Data/Persistence/` folder
3. Select **New File...**
4. Choose **Data Model** template (under Core Data section)
5. Name it: `LanguageImmersionRooms.xcdatamodeld`
6. Click **Create**

### 2. Create Entities

You'll create 4 entities: **UserEntity**, **VocabularyEntity**, **ConversationEntity**, and **SessionEntity**.

#### Entity 1: UserEntity

1. Click **Add Entity** button (bottom of editor)
2. Rename "Entity" to **UserEntity**
3. Add the following attributes:

| Attribute Name | Type | Optional | Default |
|---|---|---|---|
| id | UUID | No | - |
| username | String | No | - |
| email | String | No | - |
| createdDate | Date | No | - |
| currentStreak | Int 16 | No | 0 |
| longestStreak | Int 16 | No | 0 |
| totalStudyTime | Double | No | 0 |
| currentLevel | String | No | - |
| targetLanguage | String | No | - |
| wordsLearned | Int 16 | No | 0 |
| conversationsCompleted | Int 16 | No | 0 |
| lastActiveDate | Date | Yes | - |

4. Add Relationships:

| Relationship Name | Destination | Type | Inverse |
|---|---|---|---|
| vocabulary | VocabularyEntity | To-Many | user |
| conversations | ConversationEntity | To-Many | user |
| sessions | SessionEntity | To-Many | user |

#### Entity 2: VocabularyEntity

1. Click **Add Entity** button
2. Rename to **VocabularyEntity**
3. Add attributes:

| Attribute Name | Type | Optional | Default |
|---|---|---|---|
| id | UUID | No | - |
| word | String | No | - |
| translation | String | No | - |
| category | String | No | - |
| language | String | No | - |
| firstEncounteredDate | Date | No | - |
| timesEncountered | Int 16 | No | 0 |
| timesReviewed | Int 16 | No | 0 |
| masteryLevel | Int 16 | No | 0 |
| lastReviewedDate | Date | Yes | - |
| audioURL | String | Yes | - |
| imageURL | String | Yes | - |

4. Add Relationships:

| Relationship Name | Destination | Type | Inverse |
|---|---|---|---|
| user | UserEntity | To-One | vocabulary |

#### Entity 3: ConversationEntity

1. Click **Add Entity** button
2. Rename to **ConversationEntity**
3. Add attributes:

| Attribute Name | Type | Optional | Default |
|---|---|---|---|
| id | UUID | No | - |
| startDate | Date | No | - |
| endDate | Date | Yes | - |
| duration | Double | No | 0 |
| characterName | String | No | - |
| messagesJSON | String | No | - |
| wordsUsedCount | Int 16 | No | 0 |
| grammarErrorsCount | Int 16 | No | 0 |
| averageResponseTime | Double | No | 0 |

4. Add Relationships:

| Relationship Name | Destination | Type | Inverse |
|---|---|---|---|
| user | UserEntity | To-One | conversations |

#### Entity 4: SessionEntity

1. Click **Add Entity** button
2. Rename to **SessionEntity**
3. Add attributes:

| Attribute Name | Type | Optional | Default |
|---|---|---|---|
| id | UUID | No | - |
| startDate | Date | No | - |
| endDate | Date | Yes | - |
| duration | Double | No | 0 |
| wordsEncountered | Int 16 | No | 0 |
| conversationTime | Double | No | 0 |
| objectsScanned | Int 16 | No | 0 |

4. Add Relationships:

| Relationship Name | Destination | Type | Inverse |
|---|---|---|---|
| user | UserEntity | To-One | sessions |

### 3. Configure Entity Settings

For each entity:

1. Select the entity in the editor
2. Open the **Data Model Inspector** (right sidebar)
3. Set **Codegen** to: **Manual/None** (we've already created the subclasses)
4. Set **Class Name** to match entity name (UserEntity, VocabularyEntity, etc.)

### 4. Verify the Model

1. Build the project (⌘+B)
2. Check for any errors in the Issue Navigator
3. The PersistenceController should load the model automatically

## Testing the Setup

Run this code in a test or preview:

```swift
let controller = PersistenceController.shared
let context = controller.container.viewContext

// Create a test user
let user = UserEntity(context: context)
user.id = UUID()
user.username = "testuser"
user.email = "test@example.com"
user.createdDate = Date()
user.targetLanguage = "es"
user.currentLevel = "beginner"

do {
    try context.save()
    print("✅ CoreData working correctly")
} catch {
    print("❌ CoreData error: \(error)")
}
```

## CloudKit Sync (Optional)

To enable CloudKit syncing:

1. In Xcode, select the project
2. Go to **Signing & Capabilities** tab
3. Click **+ Capability**
4. Add **iCloud**
5. Enable **CloudKit**
6. Enable **Background Modes** → **Remote notifications**

Update PersistenceController.swift:

```swift
let container: NSPersistentCloudKitContainer // Change from NSPersistentContainer

init(inMemory: Bool = false) {
    container = NSPersistentCloudKitContainer(name: "LanguageImmersionRooms")

    if inMemory {
        container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
    }

    // Enable CloudKit sync
    guard let description = container.persistentStoreDescriptions.first else {
        fatalError("Failed to retrieve persistent store description")
    }
    description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
    description.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)

    container.loadPersistentStores { description, error in
        if let error = error {
            fatalError("Failed to load Core Data stack: \(error)")
        }
    }

    container.viewContext.automaticallyMergesChangesFromParent = true
    container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
}
```

## Troubleshooting

### Model Not Found

**Error**: "The model used to open the store is incompatible with the one used to create the store"

**Solution**:
1. Delete the app from simulator/device
2. Clean build folder (⌘+Shift+K)
3. Rebuild and run

### CloudKit Sync Not Working

**Checklist**:
- [ ] iCloud capability enabled in Xcode
- [ ] Signed in to iCloud on device/simulator
- [ ] Internet connection available
- [ ] NSPersistentCloudKitContainer used instead of NSPersistentContainer

### Attribute Type Mismatch

**Error**: Attribute type doesn't match code

**Solution**:
1. Verify attribute types in Data Model Editor match `CoreDataEntities.swift`
2. Common mismatches: Int16 vs Int32, Double vs Float
3. Use exactly as specified in the tables above

## Migration (Future)

When you need to change the schema:

1. Select the `.xcdatamodeld` file
2. Go to **Editor** → **Add Model Version**
3. Make changes to new version
4. Set new version as current model
5. Implement lightweight or custom migration

## Next Steps

After creating the CoreData model:

1. ✅ Verify the project builds without errors
2. ✅ Test basic CRUD operations
3. ✅ Verify relationships work correctly
4. ⏭️ Consider implementing CloudKit sync
5. ⏭️ Add unit tests for persistence layer

## Reference

- Full entity definitions: `Data/Persistence/CoreDataEntities.swift`
- Repository implementation: `Data/Repositories/UserRepository.swift`
- Persistence controller: `Data/Persistence/PersistenceController.swift`

## Questions?

Refer to Apple's CoreData documentation:
- [Core Data Programming Guide](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/CoreData/index.html)
- [NSPersistentContainer](https://developer.apple.com/documentation/coredata/nspersistentcontainer)
- [CloudKit Integration](https://developer.apple.com/documentation/coredata/mirroring_a_core_data_store_with_cloudkit)
