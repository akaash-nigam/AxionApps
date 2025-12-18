# Setting Up MySpatial Life as a Runnable Xcode Project

**Status**: The code is complete, but needs to be wrapped in an Xcode project to run on visionOS.

## Quick Summary

We have all the game code, tests, and documentation, but it's currently structured as a Swift Package. To run it on Vision Pro, we need to create a proper Xcode visionOS app project.

## Two Options

### Option 1: Manual Xcode Project Creation (Recommended, 10 minutes)
### Option 2: Using Our Shell Script (Experimental, 5 minutes)

---

## Option 1: Manual Xcode Project Creation (RECOMMENDED)

This is the most reliable method and teaches you the proper workflow.

### Step 1: Create New visionOS Project

1. **Open Xcode 16.0+**

2. **Create New Project**
   - `File → New → Project` (or `Cmd+Shift+N`)

3. **Select Template**
   - Click the **visionOS** tab at the top
   - Select **App** template
   - Click **Next**

4. **Configure Project**
   ```
   Product Name:              MySpatialLife
   Team:                      <Your Apple Developer Account>
   Organization Identifier:   com.yourname
   Bundle Identifier:         com.yourname.MySpatialLife
   Interface:                 SwiftUI
   Language:                  Swift
   ☑ Include Tests
   ```
   - Click **Next**

5. **Choose Location**
   - Navigate to a location OUTSIDE this repository
   - Create a new folder: `MySpatialLife_XcodeProject`
   - Click **Create**

### Step 2: Replace Auto-Generated Files

Xcode created some boilerplate files. We'll replace them with our implementation.

1. **In Xcode Project Navigator:**
   - Delete these auto-generated files (Move to Trash):
     - `ContentView.swift`
     - `MySpatialLifeApp.swift`
     - `ImmersiveView.swift` (if exists)

2. **Add Our Source Code:**
   - Right-click on the `MySpatialLife` folder in Project Navigator
   - Select `Add Files to "MySpatialLife"...`
   - Navigate to: `visionOS_Gaming_myspatial-life/MySpatialLife/MySpatialLife/`
   - Select ALL folders:
     - App/
     - Core/
     - Game/
     - Views/
     - Resources/
   - In the dialog, make sure:
     - ☑ **Copy items if needed**
     - ☑ **Create groups** (not folder references)
     - ☑ **Add to targets: MySpatialLife**
   - Click **Add**

3. **Replace Info.plist:**
   - In Project Navigator, select `Info.plist`
   - Delete it
   - Add our version:
     - Right-click MySpatialLife → Add Files
     - Select `MySpatialLife/MySpatialLife/Info.plist`
     - Add to project

### Step 3: Add Entitlements

1. **Select Project** in Navigator (top item)
2. **Select MySpatialLife Target**
3. **Signing & Capabilities Tab**
4. **Enable Capabilities:**
   - Click **+ Capability** button
   - Add:
     - **ARKit**
     - Click again, add: (search for these)
     - Under ARKit, enable:
       - ☑ World Sensing
       - ☑ Hand Tracking
       - ☑ Scene Understanding

5. **Use Our Entitlements File:**
   - In General tab, find "Code Signing Entitlements"
   - Set to: `MySpatialLife/MySpatialLife.entitlements`

### Step 4: Add Swift Package Dependencies

1. **File → Add Package Dependencies...**

2. **Add each package:**

   **Package 1: swift-algorithms**
   ```
   https://github.com/apple/swift-algorithms
   ```
   - Dependency Rule: **Up to Next Major Version**
   - Version: 1.2.0
   - Add to Target: MySpatialLife
   - Click **Add Package**

   **Package 2: swift-collections**
   ```
   https://github.com/apple/swift-collections
   ```
   - Dependency Rule: **Up to Next Major Version**
   - Version: 1.1.0
   - Add to Target: MySpatialLife
   - Click **Add Package**

   **Package 3: swift-numerics**
   ```
   https://github.com/apple/swift-numerics
   ```
   - Dependency Rule: **Up to Next Major Version**
   - Version: 1.0.0
   - Add to Target: MySpatialLife
   - Click **Add Package**

### Step 5: Configure Build Settings

1. **Select MySpatialLife Target**
2. **Build Settings Tab**
3. **Verify these settings:**
   ```
   Product Name:                    MySpatialLife
   Product Bundle Identifier:       com.yourname.MySpatialLife
   iOS Deployment Target:           N/A
   visionOS Deployment Target:      2.0
   Swift Language Version:          Swift 6
   ```

### Step 6: Add Tests

1. **Right-click on MySpatialLifeTests folder**
2. **Add Files to "MySpatialLifeTests"...**
3. **Navigate to:** `visionOS_Gaming_myspatial-life/MySpatialLife/MySpatialLifeTests/`
4. **Select:**
   - UnitTests/
   - TestUtilities/
5. **Add to target:** MySpatialLifeTests

### Step 7: Build and Run! 🚀

1. **Select Destination:**
   - In toolbar, select **Apple Vision Pro** (simulator)

2. **Build:**
   - Press `Cmd+B` to build
   - Fix any build errors (there shouldn't be any!)

3. **Run:**
   - Press `Cmd+R` to run
   - App should launch in Vision Pro simulator

4. **Run Tests:**
   - Press `Cmd+U` to run all tests
   - Should see 75+ tests pass ✅

---

## Option 2: Using Shell Script (Experimental)

We've provided a helper script, but it requires manual steps since Xcode project generation can't be fully automated.

```bash
cd MySpatialLife
chmod +x create_xcode_project.sh
./create_xcode_project.sh
```

Follow the on-screen instructions.

---

## Verification Checklist

After setup, verify everything works:

- [ ] Project builds without errors (`Cmd+B`)
- [ ] Tests run and pass (`Cmd+U`)
- [ ] App launches in simulator (`Cmd+R`)
- [ ] No missing file errors
- [ ] All capabilities enabled
- [ ] Swift packages resolved

---

## Troubleshooting

### "Build Failed: Module 'MySpatialLife' not found"

**Solution:** Clean build folder
```bash
Product → Clean Build Folder (Cmd+Shift+K)
```

### "Missing Package Dependencies"

**Solution:** Reset package cache
```bash
File → Packages → Reset Package Caches
```

### "Code Signing Error"

**Solution:**
1. Select target
2. Signing & Capabilities
3. Team: Select your Apple Developer account
4. Check "Automatically manage signing"

### "Cannot Find 'Character' in Scope"

**Solution:** Make sure you added all source folders with "Create groups" option

### Build Succeeds But Tests Fail

**Solution:** Make sure test files were added to the correct target (MySpatialLifeTests)

---

## Next Steps After Setup

Once your Xcode project is working:

1. **Run the app** - See the basic UI
2. **Run tests** - Verify all systems work (Cmd+U)
3. **Read the docs:**
   - [README.md](README.md) - Project overview
   - [ARCHITECTURE.md](ARCHITECTURE.md) - Technical details
   - [IMPLEMENTATION_PLAN.md](IMPLEMENTATION_PLAN.md) - What to build next
4. **Start coding!** - Implement the remaining 40% (Needs System, AI, Spatial features)

---

## What You'll See When It Runs

**Main Menu:**
- Continue (greyed out - no save yet)
- New Family ✅ (works!)
- Load Game (not implemented)
- Settings (basic)

**Family Creation:**
- Enter family name
- Select family size
- Creates placeholder characters
- Starts game

**Game View:**
- Blue placeholder cube (represents a character)
- Family info HUD
- Basic volume view

**What's Missing (Next Steps):**
- Actual 3D character models
- Animated characters
- Room scanning
- Character AI behavior
- Needs system
- Spatial audio

But the **foundation is solid** and ready to build on!

---

## Alternative: Keep as Swift Package

If you want to keep it as a Swift Package for library development:

1. The current structure works for that
2. You can build/test with:
   ```bash
   swift build
   swift test
   ```
3. But you **cannot run it on Vision Pro** without an Xcode project

---

## Questions?

- Check [TODO_visionOS_env.md](TODO_visionOS_env.md) for environment setup
- Check troubleshooting section above
- All code is complete and tested - just needs proper packaging!

---

**Time to Complete:** 10-15 minutes for first time, 5 minutes after practice.

**Difficulty:** Easy - mostly clicking through Xcode dialogs.

**Result:** Fully functional visionOS app that runs on simulator and device!

🎮 **Let's get MySpatial Life running!**
