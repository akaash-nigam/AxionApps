# Core Data Model Definition Guide
# Personal Finance Navigator

**Version**: 1.0
**Date**: 2025-11-24
**Timeline**: Week 1, Day 3-4

## Overview

This guide details how to create all Core Data entities in Xcode's Data Model Editor. Since `.xcdatamodeld` files are binary in Xcode, this document provides the exact specifications to recreate the model.

## How to Create Entities

### Step 1: Open Data Model Editor
1. In Xcode, select `PersonalFinanceNavigator.xcdatamodeld` in Project Navigator
2. The Data Model Editor will open
3. Click "Add Entity" button (+ at bottom left) to add new entities

### Step 2: Configure Entity
For each entity below:
1. Click "Add Entity" button
2. Select the new entity and rename it in the inspector
3. Add attributes using the + button in the Attributes section
4. Set attribute types and properties
5. Add relationships
6. Configure indexes

---

## Entity 1: TransactionEntity

**Name**: `TransactionEntity`
**Class**: Codegen → Manual/None (we'll create custom class)

### Attributes

| Name | Type | Optional | Default | Indexed |
|------|------|----------|---------|---------|
| id | UUID | No | - | Yes |
| plaidTransactionId | String | Yes | - | Yes |
| accountId | UUID | No | - | Yes |
| amount | Decimal | No | 0 | No |
| date | Date | No | - | Yes |
| authorizedDate | Date | Yes | - | No |
| merchantName | String | Yes | - | No |
| name | String | No | - | No |
| pending | Boolean | No | NO | No |
| categoryId | UUID | Yes | - | Yes |
| primaryCategory | String | No | "Uncategorized" | No |
| detailedCategory | String | Yes | - | No |
| isRecurring | Boolean | No | NO | No |
| confidence | Float | Yes | - | No |
| latitude | Double | Yes | - | No |
| longitude | Double | Yes | - | No |
| address | String | Yes | - | No |
| paymentChannel | String | No | "other" | No |
| paymentMethod | String | Yes | - | No |
| isUserModified | Boolean | No | NO | No |
| isHidden | Boolean | No | NO | No |
| isExcludedFromBudget | Boolean | No | NO | No |
| isSplit | Boolean | No | NO | No |
| parentTransactionId | UUID | Yes | - | No |
| notes | String | Yes | - | No |
| tags | Transformable | Yes | - | No |
| createdAt | Date | No | - | No |
| updatedAt | Date | No | - | No |

### Relationships

| Name | Destination | Type | Inverse | Delete Rule |
|------|-------------|------|---------|-------------|
| account | AccountEntity | To One | transactions | Nullify |
| category | CategoryEntity | To One | transactions | Nullify |

### Indexes

**Compound Index 1**: `accountId`, `date` (for transaction history queries)
**Compound Index 2**: `categoryId`, `date` (for category spending queries)
**Single Index**: `plaidTransactionId` (for sync)

---

## Entity 2: AccountEntity

**Name**: `AccountEntity`
**Class**: Codegen → Manual/None

### Attributes

| Name | Type | Optional | Default | Indexed |
|------|------|----------|---------|---------|
| id | UUID | No | - | Yes |
| plaidAccountId | String | Yes | - | Yes |
| plaidItemId | String | Yes | - | Yes |
| name | String | No | - | No |
| officialName | String | Yes | - | No |
| type | String | No | "checking" | No |
| subtype | String | Yes | - | No |
| mask | String | Yes | - | No |
| currentBalance | Decimal | No | 0 | No |
| availableBalance | Decimal | Yes | - | No |
| creditLimit | Decimal | Yes | - | No |
| isActive | Boolean | No | YES | Yes |
| isHidden | Boolean | No | NO | No |
| needsReconnection | Boolean | No | NO | No |
| institutionName | String | Yes | - | No |
| institutionLogo | Binary Data | Yes | - | No |
| primaryColor | String | Yes | - | No |
| lastSyncedAt | Date | Yes | - | No |
| createdAt | Date | No | - | No |
| updatedAt | Date | No | - | No |

### Relationships

| Name | Destination | Type | Inverse | Delete Rule |
|------|-------------|------|---------|-------------|
| transactions | TransactionEntity | To Many | account | Cascade |

### Indexes

**Single Index**: `plaidAccountId`
**Single Index**: `isActive`

---

## Entity 3: CategoryEntity

**Name**: `CategoryEntity`
**Class**: Codegen → Manual/None

### Attributes

| Name | Type | Optional | Default | Indexed |
|------|------|----------|---------|---------|
| id | UUID | No | - | Yes |
| plaidCategoryId | String | Yes | - | No |
| name | String | No | - | No |
| parentId | UUID | Yes | - | Yes |
| level | Integer 16 | No | 0 | No |
| path | String | No | - | No |
| icon | String | No | "folder.fill" | No |
| color | String | No | "#808080" | No |
| sortOrder | Integer 16 | No | 0 | No |
| isIncome | Boolean | No | NO | No |
| isExpense | Boolean | No | YES | No |
| isTransfer | Boolean | No | NO | No |
| isEssential | Boolean | No | NO | No |
| isDiscretionary | Boolean | No | NO | No |
| isDefaultBudgeted | Boolean | No | YES | No |
| suggestedPercentage | Float | Yes | - | No |
| createdAt | Date | No | - | No |
| updatedAt | Date | No | - | No |

### Relationships

| Name | Destination | Type | Inverse | Delete Rule |
|------|-------------|------|---------|-------------|
| transactions | TransactionEntity | To Many | category | Nullify |
| budgetCategories | BudgetCategoryEntity | To Many | category | Cascade |

### Indexes

**Single Index**: `name`
**Single Index**: `parentId`

---

## Entity 4: BudgetEntity

**Name**: `BudgetEntity`
**Class**: Codegen → Manual/None

### Attributes

| Name | Type | Optional | Default | Indexed |
|------|------|----------|---------|---------|
| id | UUID | No | - | Yes |
| name | String | No | - | No |
| type | String | No | "monthly" | No |
| startDate | Date | No | - | Yes |
| endDate | Date | No | - | Yes |
| totalIncome | Decimal | No | 0 | No |
| totalAllocated | Decimal | No | 0 | No |
| totalSpent | Decimal | No | 0 | No |
| isActive | Boolean | No | YES | Yes |
| isTemplate | Boolean | No | NO | No |
| strategy | String | No | "50/30/20" | No |
| createdAt | Date | No | - | No |
| updatedAt | Date | No | - | No |

### Relationships

| Name | Destination | Type | Inverse | Delete Rule |
|------|-------------|------|---------|-------------|
| categories | BudgetCategoryEntity | To Many | budget | Cascade |

### Indexes

**Compound Index**: `isActive`, `startDate`, `endDate`

---

## Entity 5: BudgetCategoryEntity

**Name**: `BudgetCategoryEntity`
**Class**: Codegen → Manual/None

### Attributes

| Name | Type | Optional | Default | Indexed |
|------|------|----------|---------|---------|
| id | UUID | No | - | Yes |
| budgetId | UUID | No | - | Yes |
| categoryId | UUID | No | - | Yes |
| allocated | Decimal | No | 0 | No |
| spent | Decimal | No | 0 | No |
| percentageOfBudget | Float | No | 0 | No |
| isRollover | Boolean | No | NO | No |
| rolledAmount | Decimal | Yes | - | No |
| alertAt75 | Boolean | No | YES | No |
| alertAt90 | Boolean | No | YES | No |
| alertAt100 | Boolean | No | YES | No |
| alertOnOverspend | Boolean | No | YES | No |
| categoryName | String | No | - | No |
| createdAt | Date | No | - | No |
| updatedAt | Date | No | - | No |

### Relationships

| Name | Destination | Type | Inverse | Delete Rule |
|------|-------------|------|---------|-------------|
| budget | BudgetEntity | To One | categories | Nullify |
| category | CategoryEntity | To One | budgetCategories | Nullify |

### Indexes

**Compound Index**: `budgetId`, `categoryId`

---

## Entity 6: UserProfileEntity

**Name**: `UserProfileEntity`
**Class**: Codegen → Manual/None

### Attributes

| Name | Type | Optional | Default | Indexed |
|------|------|----------|---------|---------|
| id | UUID | No | - | Yes |
| userId | String | No | - | Yes |
| displayName | String | Yes | - | No |
| email | String | Yes | - | No |
| currency | String | No | "USD" | No |
| firstDayOfWeek | Integer 16 | No | 0 | No |
| fiscalYearStart | Date | Yes | - | No |
| defaultBudgetStrategy | String | No | "50/30/20" | No |
| monthlyIncome | Decimal | Yes | - | No |
| enableBillReminders | Boolean | No | YES | No |
| enableBudgetAlerts | Boolean | No | YES | No |
| enableGoalAchievements | Boolean | No | YES | No |
| reminderTime | Date | Yes | - | No |
| requireBiometric | Boolean | No | YES | No |
| autoLockMinutes | Integer 16 | No | 5 | No |
| preferredTheme | String | No | "auto" | No |
| showNetWorth | Boolean | No | YES | No |
| hideAccountBalances | Boolean | No | NO | No |
| hasCompletedOnboarding | Boolean | No | NO | No |
| onboardingVersion | String | Yes | - | No |
| createdAt | Date | No | - | No |
| updatedAt | Date | No | - | No |

### Relationships

None (standalone entity)

### Indexes

**Single Index**: `userId` (unique)

---

## CloudKit Configuration

### Step 1: Enable CloudKit Sync
For each entity:
1. Select entity in Data Model Editor
2. Open Data Model Inspector (⌘⌥3)
3. Check "Use with CloudKit" under Synchronization

### Step 2: Configure Sync
- All entities should be marked for CloudKit sync
- Database scope: Private
- Record zone: Default

### Step 3: Handle Conflicts
In PersistenceController (already configured):
- Merge policy: `NSMergeByPropertyObjectTrumpMergePolicy`
- History tracking: Enabled
- Remote change notifications: Enabled

---

## Validation Rules

### TransactionEntity
- `amount` must not be 0
- `date` must not be in the future (more than 1 day)
- If `isSplit` is true, `parentTransactionId` must not be nil

### AccountEntity
- `currentBalance` can be negative (credit cards)
- If `type` is "creditCard", `creditLimit` should not be nil

### BudgetEntity
- `endDate` must be after `startDate`
- `totalIncome` must be positive
- Only one active budget per period

### CategoryEntity
- If `parentId` is set, referenced category must exist
- `level` must match parent hierarchy

---

## After Creating the Model

### Generate NSManagedObject Subclasses

**Option 1: Manual (Recommended)**
1. Editor → Create NSManagedObject Subclass
2. Select entities
3. Choose language: Swift
4. Click Create

**Option 2: Automatic Codegen**
- Set Codegen: Class Definition
- Xcode will auto-generate in DerivedData

We recommend **Manual** so we can customize the classes.

---

## Testing the Model

After creating all entities, test by:

```swift
// In PersistenceController or a test file
let context = persistenceController.container.viewContext

// Create a test category
let category = CategoryEntity(context: context)
category.id = UUID()
category.name = "Test Category"
category.icon = "folder.fill"
category.color = "#FF0000"
category.createdAt = Date()
category.updatedAt = Date()

// Save
try? context.save()

// Fetch
let fetchRequest: NSFetchRequest<CategoryEntity> = CategoryEntity.fetchRequest()
let results = try? context.fetch(fetchRequest)
print("Fetched \(results?.count ?? 0) categories")
```

---

## Troubleshooting

**Issue**: "Entity not found"
- **Fix**: Ensure entity name matches exactly (case-sensitive)

**Issue**: "Relationship destination not found"
- **Fix**: Create all entities before adding relationships

**Issue**: "CloudKit sync not working"
- **Fix**: Verify CloudKit capability is enabled in project settings

**Issue**: "Migration needed"
- **Fix**: We enabled lightweight migration in PersistenceController

---

**Next Steps**: Create NSManagedObject subclasses for all entities

**Status**: Model definition ready for Xcode implementation
