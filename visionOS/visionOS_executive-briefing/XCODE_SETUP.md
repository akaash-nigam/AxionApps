# Xcode Project Setup Guide

This guide walks you through creating the Xcode project for the Executive Briefing visionOS app.

## Prerequisites

- macOS 14.0 (Sonoma) or later
- Xcode 16.0 or later with visionOS SDK
- Apple Vision Pro Simulator (included with Xcode)

---

## Step 1: Create New visionOS Project

1. Open Xcode 16+
2. Select **File → New → Project** (or press ⌘⇧N)
3. Choose **visionOS** tab
4. Select **App** template
5. Click **Next**

## Step 2: Configure Project Settings

Enter the following details:

- **Product Name**: `ExecutiveBriefing`
- **Team**: Select your development team
- **Organization Identifier**: `com.yourcompany` (or your preference)
- **Bundle Identifier**: Will auto-generate as `com.yourcompany.ExecutiveBriefing`
- **Interface**: **SwiftUI**
- **Language**: **Swift**
- **Include Tests**: ✅ **Checked**

Click **Next**, then choose the repository root directory (`visionOS_executive-briefing/`) to save the project.

---

## Step 3: Remove Default Files

Xcode will create some default files. Delete these:

1. In Project Navigator, select and delete:
   - `ContentView.swift` (we have our own)
   - `ExecutiveBriefingApp.swift` (we have our own)
   - `ImmersiveView.swift` (we have our own)
   - `Assets.xcassets` (optional, can keep for app icon)

2. When prompted, choose **Move to Trash**

---

## Step 4: Add Source Files

### 4.1 Add App Files

1. Right-click on `ExecutiveBriefing` group
2. Select **Add Files to "ExecutiveBriefing"...**
3. Navigate to `ExecutiveBriefing/App/`
4. Select both files:
   - `ExecutiveBriefingApp.swift`
   - `AppState.swift`
5. Ensure **Copy items if needed** is UNCHECKED (files are already in repo)
6. Click **Add**

### 4.2 Add Model Files

1. Right-click on `ExecutiveBriefing` group
2. Select **New Group** and name it `Models`
3. Right-click on `Models` group → **Add Files to "ExecutiveBriefing"...**
4. Navigate to `ExecutiveBriefing/Models/`
5. Select all 9 Swift files
6. Click **Add**

### 4.3 Add Service Files

1. Create `Services` group
2. Add `BriefingContentService.swift` from `ExecutiveBriefing/Services/`

### 4.4 Add View Files

1. Create `Views` group
2. Create subgroups: `Windows`, `Volumes`, `ImmersiveViews`
3. Add files to respective groups:
   - `Windows/`: ContentView.swift, SidebarView.swift, SectionDetailView.swift
   - `Volumes/`: DataVisualizationVolume.swift
   - `ImmersiveViews/`: ImmersiveBriefingView.swift

### 4.5 Add Utility Files

1. Create `Utilities` group
2. Create `Extensions` subgroup
3. Add files:
   - `MarkdownParser.swift`
   - `DataSeeder.swift`
   - Extensions/Logger+Extensions.swift
   - Extensions/String+Extensions.swift
   - Extensions/Color+Extensions.swift
   - Extensions/Date+Extensions.swift

### 4.6 Add Resource Files

1. Create `Resources` group
2. Add `Info.plist` and `ExecutiveBriefing.entitlements`
3. **IMPORTANT**: Add `Executive-Briefing-AR-VR-2025.md` from repository root
   - This file is required for content seeding
   - Ensure it's added to the target

---

## Step 5: Add Test Files

1. In Project Navigator, expand `ExecutiveBriefingTests` group
2. Delete default test file if present
3. Create groups: `ModelTests`, `ServiceTests`, `UtilityTests`
4. Add test files from `ExecutiveBriefingTests/` to respective groups

---

## Step 6: Configure Build Settings

### 6.1 Project Build Settings

1. Select project in Navigator
2. Select `ExecutiveBriefing` target
3. Go to **Build Settings**
4. Search for and configure:

```
Swift Language Version: Swift 6
iOS Deployment Target: (leave empty for visionOS)
```

5. Search for "Concurrency" and set:
```
SWIFT_STRICT_CONCURRENCY = Complete
```

### 6.2 Info.plist Configuration

1. Select `ExecutiveBriefing` target
2. Go to **Info** tab
3. Verify the `Info.plist` file is set correctly
4. Or manually set in Build Settings:
```
INFOPLIST_FILE = ExecutiveBriefing/Resources/Info.plist
```

### 6.3 Entitlements

1. In Build Settings, search for "Code Signing Entitlements"
2. Set to:
```
CODE_SIGN_ENTITLEMENTS = ExecutiveBriefing/Resources/ExecutiveBriefing.entitlements
```

---

## Step 7: Configure Capabilities

1. Select `ExecutiveBriefing` target
2. Go to **Signing & Capabilities**
3. Verify these are present (from entitlements file):
   - ✅ Spatial Tracking
   - ✅ Hand Tracking (optional)
   - ✅ Data Protection

---

## Step 8: Build Configuration

### 8.1 Schemes

1. Click on scheme dropdown (next to device selector)
2. Select **Edit Scheme...**
3. Under **Run** → **Info**:
   - Build Configuration: **Debug**
4. Under **Test** → **Info**:
   - Build Configuration: **Debug**

### 8.2 Build Phases

Verify these are correct:

1. **Target Dependencies**: (none needed for single-target app)
2. **Compile Sources**: Should include all .swift files (36 files)
3. **Copy Bundle Resources**: Should include:
   - `Executive-Briefing-AR-VR-2025.md` ⚠️ **CRITICAL**
   - `Assets.xcassets` (if using)
   - Any other resources

---

## Step 9: First Build

1. Select **visionOS Simulator** from device dropdown
2. Choose **Apple Vision Pro** simulator
3. Press **⌘B** to build

### Expected Output:
```
✅ Build Succeeded
```

### Common Issues:

**Issue**: "Cannot find type 'BriefingSection' in scope"
- **Fix**: Ensure all Model files are added to target

**Issue**: "Cannot find 'Executive-Briefing-AR-VR-2025.md'"
- **Fix**: Verify markdown file is in Copy Bundle Resources

**Issue**: "Type 'X' does not conform to protocol 'Y'"
- **Fix**: Ensure all files are using Swift 6 mode

---

## Step 10: Run the App

1. Press **⌘R** to build and run
2. visionOS Simulator will launch
3. App will open and automatically seed database

### Expected Behavior:

1. **First Launch**:
   - App opens
   - Shows welcome screen
   - Database auto-seeds from markdown file
   - Sidebar shows 8+ sections

2. **Navigation**:
   - Click on section in sidebar
   - Content displays in detail view
   - "View in 3D" button appears for visualization sections

3. **3D Visualization**:
   - Click "View in 3D"
   - New volume window opens
   - Shows 3D chart placeholder

---

## Step 11: Run Tests

1. Press **⌘U** to run all tests
2. Or click individual test diamonds in editor gutter

### Expected Results:
```
✅ All 50+ tests passed
Model Tests: 100% coverage
Service Tests: 90%+ coverage
Utility Tests: 95%+ coverage
```

---

## Step 12: Verify Installation

### Checklist:

- [ ] Project builds without errors
- [ ] App launches in simulator
- [ ] Welcome screen appears
- [ ] Sidebar shows sections
- [ ] Can navigate to section detail
- [ ] Content renders correctly
- [ ] 3D visualization button works
- [ ] All tests pass
- [ ] No runtime warnings

---

## Troubleshooting

### Build Errors

**Error**: `'import SwiftData' failed`
- **Fix**: Ensure visionOS SDK is installed (Xcode 16+)

**Error**: `'@Model' macro requires iOS 17.0 or newer`
- **Fix**: Target should be visionOS 2.0, not iOS

**Error**: Missing file errors
- **Fix**: Ensure all files are added to target (check Target Membership)

### Runtime Errors

**Error**: App crashes on launch
- **Fix**: Check Console for error messages
- Verify `Executive-Briefing-AR-VR-2025.md` is in bundle

**Error**: Empty sidebar
- **Fix**: Database seeding may have failed
- Delete app from simulator and rerun

### Simulator Issues

**Issue**: Simulator won't launch
- **Fix**: Restart Xcode, ensure visionOS simulator is installed

**Issue**: Can't interact with UI
- **Fix**: Use mouse for tap, Option+drag for gesture

---

## Additional Configuration

### App Icon

1. Select `Assets.xcassets` in Navigator
2. Click on `AppIcon`
3. Drag icons (1024x1024 recommended)

### Launch Screen

Configured in `Info.plist` under `UILaunchScreen`

### Debugging

Enable logging in console:
```swift
Logger.app.info("Message")
```

View in Console app or Xcode console.

---

## Next Steps

1. ✅ Build and run successfully
2. ✅ Verify all tests pass
3. 🔲 Customize app icon
4. 🔲 Test on actual Vision Pro device (if available)
5. 🔲 Implement remaining features
6. 🔲 Prepare for TestFlight distribution

---

## Resources

- [visionOS Documentation](https://developer.apple.com/visionos/)
- [SwiftData Guide](https://developer.apple.com/documentation/swiftdata)
- [RealityKit Documentation](https://developer.apple.com/documentation/realitykit/)
- [Xcode Help](https://help.apple.com/xcode/)

---

**Setup Complete!** 🎉

You now have a fully configured Xcode project ready for development.
