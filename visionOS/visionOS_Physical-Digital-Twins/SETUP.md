# Xcode Project Setup Instructions

This document provides step-by-step instructions for creating the Xcode project and integrating the source files.

## Prerequisites

- Mac with Apple Silicon (M1 or later)
- macOS Sonoma 14.0+
- Xcode 15.2+
- Apple Developer account
- Vision Pro device or simulator

## Step 1: Create visionOS Project

1. Open Xcode
2. Click "Create New Project"
3. Select **visionOS** → **App**
4. Configure project:
   - **Product Name**: PhysicalDigitalTwins
   - **Team**: Your team
   - **Organization Identifier**: com.yourcompany
   - **Interface**: SwiftUI
   - **Language**: Swift
5. Choose location and create project

## Step 2: Add Source Files

The source files are already created in the `PhysicalDigitalTwins/` directory. You need to add them to your Xcode project:

1. In Xcode, right-click on the `PhysicalDigitalTwins` group in the Project Navigator
2. Select "Add Files to PhysicalDigitalTwins..."
3. Navigate to the `PhysicalDigitalTwins/` directory
4. Select all Swift files and folders
5. **Important**: Ensure "Copy items if needed" is checked
6. Click "Add"

### Folder Structure in Xcode

Your project should have this structure:

```
PhysicalDigitalTwins/
├── App/
│   ├── PhysicalDigitalTwinsApp.swift
│   ├── AppState.swift
│   └── AppDependencies.swift
├── Models/
│   ├── DigitalTwin.swift
│   ├── BookTwin.swift
│   ├── InventoryItem.swift
│   └── AppError.swift
├── Services/
│   ├── VisionService.swift
│   ├── ProductAPIService.swift
│   ├── TwinFactory.swift
│   └── StorageService.swift
├── Persistence/
│   ├── PersistenceController.swift
│   ├── InventoryItemEntity+CoreDataClass.swift
│   └── InventoryItemEntity+CoreDataProperties.swift
├── Views/
│   ├── ContentView.swift
│   ├── HomeView.swift
│   ├── InventoryListView.swift
│   ├── ItemDetailView.swift
│   └── SettingsView.swift
├── Assets.xcassets
└── PhysicalDigitalTwins.xcdatamodeld (you'll create this)
```

## Step 3: Create Core Data Model

1. In Xcode, right-click on the `PhysicalDigitalTwins` group
2. Select **New File** → **Data Model**
3. Name it: `PhysicalDigitalTwins`
4. Click **Create**

### Add Entity

1. Click the **+ (Add Entity)** button at the bottom
2. Name the entity: `InventoryItemEntity`

### Add Attributes

Click on `InventoryItemEntity` and add these attributes:

| Attribute Name | Type | Optional |
|----------------|------|----------|
| id | UUID | No |
| createdAt | Date | No |
| updatedAt | Date | No |
| digitalTwinData | Binary Data | No |
| digitalTwinType | String | Yes |
| purchaseDate | Date | Yes |
| purchasePrice | Decimal | Yes |
| purchaseStore | String | Yes |
| currentValue | Decimal | Yes |
| locationName | String | Yes |
| specificLocation | String | Yes |
| condition | String | Yes |
| conditionNotes | String | Yes |
| photosPaths | Transformable | Yes |
| isLent | Boolean | No (default: NO) |
| lentTo | String | Yes |
| lentDate | Date | Yes |
| expectedReturnDate | Date | Yes |
| notes | String | Yes |
| tags | Transformable | Yes |
| isFavorite | Boolean | No (default: NO) |

### Configure Transformable Attributes

For `photosPaths` and `tags`:
1. Select the attribute
2. In the Data Model Inspector:
   - **Custom Class**: Leave empty (use default)
   - **Transformer**: NSSecureUnarchiveFromDataTransformer

### Set Codegen

1. Select `InventoryItemEntity`
2. In the Data Model Inspector:
   - **Codegen**: Manual/None (we already created the files)

## Step 4: Add Core Data to Target

1. In Project Navigator, select the Xcode project file (top level)
2. Select the **PhysicalDigitalTwins** target
3. Go to **Build Phases**
4. Expand **Compile Sources**
5. Verify that `PhysicalDigitalTwins.xcdatamodeld` is in the list
6. If not, click **+** and add it

## Step 5: Configure Capabilities

### Add Camera Permission

1. Select the project → Target → **Info** tab
2. Add a new key:
   - **Key**: Privacy - Camera Usage Description
   - **Value**: "Camera access is required to scan barcodes and recognize objects"

### Enable Core Data

1. Select Target → **Signing & Capabilities**
2. Verify that iCloud is NOT enabled yet (we'll add in Phase 3)

## Step 6: Configure Build Settings

1. Select Target → **Build Settings**
2. Search for "Swift Language Version"
3. Ensure it's set to **Swift 5** or later

## Step 7: Build and Run

1. Select **Vision Pro** simulator or device as the destination
2. Press **Cmd+R** to build and run
3. The app should launch with an empty home screen

## Step 8: Test Basic Functionality

1. The app should load without crashes
2. Navigate between tabs (Home, Inventory, Settings)
3. The home screen should show "0 Total Items"

## Troubleshooting

### Build Errors

**"Cannot find type 'InventoryItemEntity' in scope"**
- Solution: Ensure Core Data model is added to target (Step 4)

**"Use of unresolved identifier 'AppState'"**
- Solution: Verify all Swift files are added to the target

**Module 'PhysicalDigitalTwins' has no member**
- Solution: Clean build folder (Cmd+Shift+K) and rebuild

### Runtime Errors

**"Failed to load persistent stores"**
- Solution: Delete app from simulator and reinstall

**App crashes on launch**
- Solution: Check console for error messages
- Common fix: Ensure Core Data model entity name matches the class name exactly

## Next Steps

Once the project builds successfully:

1. ✅ Epic 1: Foundation - Complete!
2. 📋 Epic 2: Continue with barcode scanning UI
3. 📋 Epic 3: Add manual item entry
4. 📋 Epic 4: Test with real barcodes

## Getting Help

If you encounter issues:

1. Check the console output in Xcode
2. Verify all files are added to the target
3. Clean build folder and rebuild
4. Delete derived data: `~/Library/Developer/Xcode/DerivedData/`

## Notes for Development

- Run on a real Vision Pro device for best experience
- Simulator works for UI development but not for barcode scanning
- Camera access only works on physical devices
